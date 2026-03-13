--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                     Massacreme  UI Lib v1.0                      ║
    ║        Standalone UI helper library extracted from masscrem      ║
    ║                                                                  ║
    ║  USAGE:                                                          ║
    ║    local UILib = require(script.UILib)                           ║
    ║    -- or paste this file contents at the top of _buildUI         ║
    ║                                                                  ║
    ║  All functions are available via the returned UILib table.       ║
    ║  Pass in the shared `cfg`, `content`, and `ScreenGui` upvalues   ║
    ║  when calling UILib.init(cfg, content, ScreenGui, services).     ║
    ╚══════════════════════════════════════════════════════════════════╝
--]]

-- ═══════════════════════════════════════════════════════════════════
-- ░░░  SECTION A: LIBRARY FACTORY  ░░░
-- ═══════════════════════════════════════════════════════════════════
-- Call UILib.init() once to bind the library to your GUI context.
-- After init, all methods are ready to use.

local UILib = {}
UILib.__index = UILib

-- ── Internal state (populated by init) ──────────────────────────────
local _cfg           -- shared config table (cfg)
local _content       -- the main ScrollingFrame that tabs render into
local _ScreenGui     -- root ScreenGui (used for tooltips, dropdowns)
local _UIS           -- UserInputService
local _Camera        -- workspace.CurrentCamera
local _scheduleSave  -- optional callback: called after toggle/slider changes
local _keyCapture    -- optional shared keyCapture state table
local _keybinds      -- the live keybinds table (set via init)

-- ── Feature registry (auto-populated by widget functions) ────────────
-- _activeTabName is set by UILib.setActiveTab() before each render fn runs.
-- createToggle/createSlider/keybindToggleRow/keybindRow all register their
-- label automatically so the search bar can find individual features.
local _tabFeatures   = {}   -- { tabName = { "Speed Toggle", "Noclip Toggle", ... } }
local _activeTabName = nil

-- ── Keybind registry ─────────────────────────────────────────────────
-- Each entry: { keybindKey = string, action = function() }
-- "keybindKey" is the field name inside the `keybinds` table (e.g. "SpeedToggle")
local _keybindActions = {}

-- ── Tooltip singleton ────────────────────────────────────────────────
local _tooltipFrame, _tooltipLabel, _tooltipMoveConn = nil, nil, nil

-- ════════════════════════════════════════════════════════════════════
-- SECTION A1 · INIT
-- Bind the library to the live GUI context.
--   cfg        : the shared config table
--   content    : the main ScrollingFrame (tab content area)
--   ScreenGui  : the root ScreenGui
--   services   : { UIS=UserInputService, Camera=workspace.CurrentCamera,
--                  scheduleSave=fn (optional), keyCapture=tbl (optional) }
-- ════════════════════════════════════════════════════════════════════
function UILib.init(cfg, content, ScreenGui, services)
    _cfg          = cfg
    _content      = content
    _ScreenGui    = ScreenGui
    _UIS          = services.UIS          or game:GetService("UserInputService")
    _Camera       = services.Camera       or workspace.CurrentCamera
    _scheduleSave = services.scheduleSave or function() end
    _keyCapture   = services.keyCapture   or { active = false }
    _keybinds     = services.keybinds     or {}
    return UILib
end

--- Call this just before invoking a tab's render function so that
--- any sectionLabel() calls inside it are recorded under the right tab.
---@param name string  the tab name (must match renderMap keys)
function UILib.setActiveTab(name)
    _activeTabName = name
    _tabFeatures[name] = {}  -- reset instead of only initializing if nil
end

--- Returns the auto-built feature table for use in buildSearchBar.
function UILib.getTabFeatures()
    return _tabFeatures
end

--- Internal helper: register a feature label under the current active tab.
local function _registerFeature(label)
    if not _activeTabName then return end
    if not _tabFeatures[_activeTabName] then _tabFeatures[_activeTabName] = {} end
    for _, s in ipairs(_tabFeatures[_activeTabName]) do
        if s == label then return end  -- already registered (tab re-rendered)
    end
    table.insert(_tabFeatures[_activeTabName], label)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A1b · KEYBIND REGISTRY
-- Register a keybind that will be handled inside the shared InputBegan
-- connection built in _buildUI.
--
--   keybindKey : string  – field name in the `keybinds` table
--                          e.g. "SpeedToggle", "NoclipToggle"
--   action     : function() – called when that key is pressed
--
-- Usage (after _buildUI has called UILib.init):
--   UILib.registerKeybind("SpeedToggle",   function() cfg.SpeedEnabled = not cfg.SpeedEnabled end)
--   UILib.registerKeybind("NoclipToggle",  function() cfg.NoclipEnabled = not cfg.NoclipEnabled end)
-- ════════════════════════════════════════════════════════════════════
function UILib.registerKeybind(keybindKey, action)
    _keybindActions[keybindKey] = action
end

--- Dispatch a KeyCode against every registered keybind.
--- Called internally by the InputBegan handler; exposed so custom
--- handlers can also forward inputs if needed.
function UILib.dispatchKeybind(keyCode, keybinds)
    for keybindKey, action in pairs(_keybindActions) do
        if keybinds[keybindKey] and keyCode == keybinds[keybindKey] then
            action()
            return true   -- consumed
        end
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A2 · PRIMITIVES
-- Low-level Instance helpers.  These do NOT depend on _content;
-- they just decorate any Instance you pass in.
-- ════════════════════════════════════════════════════════════════════

--- Clamp helper
function UILib.clamp(n, a, b) return math.max(a, math.min(b, n)) end

--- Add a UICorner to inst
---@param inst Instance
---@param radius number|nil  pixel radius (default 8)
function UILib.addCorner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = inst
    return c
end

--- Add (or replace) a UIStroke on inst
---@param inst      Instance
---@param thickness number|nil
---@param color     Color3|nil
---@param trans     number|nil  transparency 0-1
function UILib.addStroke(inst, thickness, color, trans)
    local old = inst:FindFirstChildOfClass("UIStroke")
    if old then old:Destroy() end
    local s = Instance.new("UIStroke")
    s.Thickness    = thickness or 1
    s.Color        = color     or _cfg.Stroke
    s.Transparency = trans     or 0.4
    s.Parent       = inst
    return s
end

--- Wire a satisfying press-bounce onto any TextButton.
--- Shrinks to ~92 % on MouseButton1Down, springs back overshooting to ~104 %,
--- then settles at 100 % — all via TweenService so it never blocks.
--- TextSize on the button is also scaled so the label moves with the bounce.
---@param btn       TextButton
---@param baseSize  UDim2          the button's resting size (captured at wire time)
---@param enabled   function|nil   optional guard: bounce only fires when this returns true
function UILib.attachBounce(btn, baseSize, enabled)
    local TS          = game:GetService("TweenService")
    local BASE        = baseSize or btn.Size
    local BASE_TSIZE  = btn.TextSize  -- capture resting TextSize for proportional scaling

    local function sizeFrom(s)
        return UDim2.new(
            BASE.X.Scale * s, math.floor(BASE.X.Offset * s + 0.5),
            BASE.Y.Scale * s, math.floor(BASE.Y.Offset * s + 0.5)
        )
    end
    local function tsizeFrom(s)
        return math.max(6, math.floor(BASE_TSIZE * s + 0.5))
    end

    -- Three-phase spring: squish → overshoot → settle
    local SQUISH    = TweenInfo.new(0.07, Enum.EasingStyle.Quad,   Enum.EasingDirection.Out)
    local OVERSHOOT = TweenInfo.new(0.12, Enum.EasingStyle.Back,   Enum.EasingDirection.Out)
    local SETTLE    = TweenInfo.new(0.08, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

    -- Keep the anchor point central so it scales around the button's midpoint
    btn.AnchorPoint = Vector2.new(0.5, 0.5)
    btn.Position    = UDim2.new(
        btn.Position.X.Scale,
        btn.Position.X.Offset + math.floor(BASE.X.Offset * 0.5 + 0.5),
        btn.Position.Y.Scale,
        btn.Position.Y.Offset + math.floor(BASE.Y.Offset * 0.5 + 0.5)
    )

    local activeTween = nil
    local function play(info, s)
        if activeTween then activeTween:Cancel() end
        activeTween = TS:Create(btn, info, { Size = sizeFrom(s), TextSize = tsizeFrom(s) })
        activeTween:Play()
    end

    btn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if enabled and not enabled() then return end
        play(SQUISH, 0.92)
    end)

    btn.InputEnded:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1
        and inp.UserInputType ~= Enum.UserInputType.Touch then return end
        if enabled and not enabled() then return end
        play(OVERSHOOT, 1.06)
        task.delay(0.12, function() play(SETTLE, 1.00) end)
    end)

    -- Exposed so keybinds can trigger the same spring without a mouse event
    local function triggerBounce()
        play(SQUISH, 0.92)
        task.delay(0.07, function()
            play(OVERSHOOT, 1.06)
            task.delay(0.12, function() play(SETTLE, 1.00) end)
        end)
    end

    return triggerBounce
end

--- Create a TextLabel with transparent background
---@param parent   Instance
---@param text     string
---@param font     Enum.Font|nil
---@param size     number|nil
---@param color    Color3|nil
---@param xAlign   Enum.TextXAlignment|nil
function UILib.newLabel(parent, text, font, size, color, xAlign)
    local l                  = Instance.new("TextLabel")
    l.Name = "Label"
    l.BackgroundTransparency = 1
    l.Font                   = font   or Enum.Font.GothamBold
    l.TextSize               = size   or 14
    l.TextColor3             = color  or _cfg.Text
    l.Text                   = text
    l.TextXAlignment         = xAlign or Enum.TextXAlignment.Left
    l.Parent                 = parent
    return l
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A3 · CONTENT ROW HELPERS
-- These add children to _content (the active tab scroll frame).
-- ════════════════════════════════════════════════════════════════════

--- Add a section heading with a hairline rule below
---@param text string
---@return Frame
function UILib.sectionLabel(text)
    local f                  = Instance.new("Frame")
    f.Name = "Section_" .. text:gsub("[^%w]", "_")
    f.BackgroundTransparency = 1
    f.Size                   = UDim2.new(1, 0, 0, 26)
    f.Parent                 = _content

    local line            = Instance.new("Frame")
    line.Name = "Hairline"
    line.Size             = UDim2.new(1, 0, 0, 1)
    line.Position         = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = _cfg.Stroke
    line.BorderSizePixel  = 0
    line.Parent           = f

    local lbl = UILib.newLabel(f, text:upper(), Enum.Font.GothamBold, 11, _cfg.Accent)
    lbl.Size  = UDim2.new(1, 0, 1, 0)
    return f
end

--- Add a small muted informational text line
---@param text string
---@return TextLabel
function UILib.mutedText(text)
    local lbl = UILib.newLabel(_content, text, Enum.Font.Gotham, 12, _cfg.Muted)
    lbl.Size  = UDim2.new(1, 0, 0, 16)
    return lbl
end

--- Create a generic row frame added to _content
---@param height number|nil  (default 40)
---@return Frame
function UILib.rowFrame(height, name)
    local r            = Instance.new("Frame")
    r.Name = name or "Row"
    r.BackgroundColor3 = _cfg.BG2
    r.BorderSizePixel  = 0
    r.Size             = UDim2.new(1, 0, 0, height or 40)
    r.Parent           = _content
    UILib.addCorner(r, 8)
    UILib.addStroke(r, 1, _cfg.Stroke, 0.5)
    return r
end

--- Add a row label (left side of a row)
---@param parent Instance
---@param text   string
---@return TextLabel
function UILib.rowLabel(parent, text)
    local lbl         = UILib.newLabel(parent, text, Enum.Font.GothamSemibold, 14, _cfg.Text)
    lbl.Size          = UDim2.new(0.55, -8, 1, 0)
    lbl.Position      = UDim2.fromOffset(12, 0)
    lbl.TextTruncate  = Enum.TextTruncate.AtEnd
    return lbl
end

--- Clear all non-layout children from _content
function UILib.clearContent()
    for _, c in ipairs(_content:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
            c:Destroy()
        end
    end
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A4 · TOGGLE PILL
-- ON/OFF pill button, positioned on the right side of a row.
-- ════════════════════════════════════════════════════════════════════

--- Create an ON/OFF toggle pill
---@param parent    Instance   (typically a rowFrame)
---@param initial   boolean
---@param onChanged function(newValue: boolean)
---@return button: TextButton, syncFn: function(bool)
function UILib.togglePill(parent, initial, onChanged)
    local btn           = Instance.new("TextButton")
    btn.Name = "TogglePill"
    btn.AutoButtonColor = false
    btn.Size            = UDim2.fromOffset(72, 26)
    btn.Position        = UDim2.new(1, -82, 0.5, -13)
    btn.BorderSizePixel = 0
    btn.Font            = Enum.Font.GothamBold
    btn.TextSize        = 12
    btn.TextXAlignment  = Enum.TextXAlignment.Center
    btn.Parent          = parent
    UILib.addCorner(btn, 999)

    -- Small dot indicator on the left side of the pill
    local dot              = Instance.new("Frame", btn)
    dot.Name               = "PillDot"
    dot.Size               = UDim2.fromOffset(7, 7)
    dot.AnchorPoint        = Vector2.new(0, 0.5)
    dot.Position           = UDim2.new(0, 8, 0.5, 0)
    dot.BorderSizePixel    = 0
    UILib.addCorner(dot, 999)

    local state = initial and true or false
    local function sync()
        btn.Text             = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 195, 85) or Color3.fromRGB(55, 58, 78)
        btn.TextColor3       = state and Color3.fromRGB(5, 25, 10)  or _cfg.Muted
        dot.BackgroundColor3 = state and Color3.fromRGB(180, 255, 200) or Color3.fromRGB(100, 104, 130)
    end
    sync()

    btn.MouseButton1Click:Connect(function()
        state = not state
        sync()
        if onChanged then onChanged(state) end
        pcall(_scheduleSave)
    end)

    local triggerBounce = UILib.attachBounce(btn, btn.Size)

    -- syncFn: call externally to force-set the visual state
    -- triggerBounce: call externally to animate (e.g. from a keybind)
    return btn, function(v) state = not not v; sync() end, triggerBounce
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A5 · TOOLTIP
-- Floating tooltip that follows the mouse.
-- ════════════════════════════════════════════════════════════════════

local function _ensureTooltip()
    if _tooltipFrame then return end
    _tooltipFrame = Instance.new("Frame")
    _tooltipFrame.Name = "Tooltip"
    _tooltipFrame.Name            = "UILib_Tooltip"
    _tooltipFrame.Size            = UDim2.new(0, 240, 0, 0)
    _tooltipFrame.AutomaticSize   = Enum.AutomaticSize.Y
    _tooltipFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    _tooltipFrame.BorderSizePixel  = 0
    _tooltipFrame.ZIndex           = 50
    _tooltipFrame.Visible          = false
    _tooltipFrame.Parent           = _ScreenGui
    UILib.addCorner(_tooltipFrame, 6)
    UILib.addStroke(_tooltipFrame, 1, _cfg.Accent, 0.3)
    local pad = Instance.new("UIPadding", _tooltipFrame)
    pad.Name = "Padding"
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    _tooltipLabel = Instance.new("TextLabel", _tooltipFrame)
    _tooltipLabel.Name = "TooltipText"
    _tooltipLabel.Size                 = UDim2.new(1, 0, 0, 0)
    _tooltipLabel.AutomaticSize        = Enum.AutomaticSize.Y
    _tooltipLabel.BackgroundTransparency = 1
    _tooltipLabel.Font                 = Enum.Font.Gotham
    _tooltipLabel.TextSize             = 11
    _tooltipLabel.TextColor3           = _cfg.Muted
    _tooltipLabel.TextWrapped          = true
    _tooltipLabel.TextXAlignment       = Enum.TextXAlignment.Left
    _tooltipLabel.ZIndex               = 51
end

--- Attach a hover tooltip to any GuiObject
---@param inst    GuiObject
---@param tipText string
function UILib.attachTooltip(inst, tipText)
    _ensureTooltip()
    inst.MouseEnter:Connect(function()
        if not tipText or tipText == "" then return end
        _tooltipLabel.Text  = tipText
        _tooltipFrame.Visible = true
        if _tooltipMoveConn then _tooltipMoveConn:Disconnect() end
        _tooltipMoveConn = _UIS.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                local mx = inp.Position.X + 14
                local my = inp.Position.Y - 10
                local sw = _Camera.ViewportSize.X
                local sh = _Camera.ViewportSize.Y
                local tw = 244
                local th = _tooltipFrame.AbsoluteSize.Y > 0 and _tooltipFrame.AbsoluteSize.Y or 40
                if mx + tw > sw then mx = inp.Position.X - tw - 6 end
                if my + th > sh then my = sh - th - 4 end
                if my < 4 then my = 4 end
                _tooltipFrame.Position = UDim2.fromOffset(mx, my)
            end
        end)
        local ms = _UIS:GetMouseLocation()
        local mx = ms.X + 14
        local my = ms.Y - 10
        if mx + 244 > _Camera.ViewportSize.X then mx = ms.X - 244 - 6 end
        _tooltipFrame.Position = UDim2.fromOffset(mx, my)
    end)
    inst.MouseLeave:Connect(function()
        _tooltipFrame.Visible = false
        if _tooltipMoveConn then _tooltipMoveConn:Disconnect(); _tooltipMoveConn = nil end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A6 · COMPOSITE WIDGETS
-- High-level elements built from the primitives above.
-- These are the ones used most often inside tab render functions.
-- ════════════════════════════════════════════════════════════════════

--- Create a full toggle row (label + pill) added to _content
---@param text     string
---@param init     boolean        current value
---@param onChange function(bool) called on change
---@param tooltip  string|nil     optional hover tip
---@return { Button: TextButton, Sync: function }
function UILib.createToggle(text, init, onChange, tooltip)
    _registerFeature(text)
    local r   = UILib.rowFrame(40, text:gsub("[^%w]", "_"))
    local lbl = UILib.rowLabel(r, text)
    local btn, sync = UILib.togglePill(r, init, function(v)
        onChange(v)
        pcall(_scheduleSave)
    end)
    if tooltip and tooltip ~= "" then
        UILib.attachTooltip(r, tooltip)
        lbl.Text       = text .. "  (i)"
        lbl.TextColor3 = _cfg.Text
    end
    return { Button = btn, Sync = sync }
end

--- Create a horizontal slider row added to _content
---@param labelText string
---@param minV      number
---@param maxV      number
---@param defV      number
---@param decimals  number|nil  decimal places (0 = integer)
---@param onChange  function(value: number)|nil
---@return { Set: function, Get: function }
function UILib.createSlider(labelText, minV, maxV, defV, decimals, onChange)
    _registerFeature(labelText)
    local wrap            = Instance.new("Frame")
    wrap.Name = labelText:gsub("[^%w]", "_")
    wrap.BackgroundColor3 = _cfg.BG2
    wrap.BorderSizePixel  = 0
    wrap.Size             = UDim2.new(1, 0, 0, 58)
    wrap.Parent           = _content
    UILib.addCorner(wrap, 8)
    UILib.addStroke(wrap, 1, _cfg.Stroke, 0.5)

    local top                  = Instance.new("Frame")
    top.Name = "SliderTop"
    top.BackgroundTransparency = 1
    top.Size                   = UDim2.new(1, -16, 0, 20)
    top.Position               = UDim2.fromOffset(12, 8)
    top.Parent                 = wrap

    local lbl    = UILib.newLabel(top, labelText, Enum.Font.GothamSemibold, 13, _cfg.Muted)
    lbl.Size     = UDim2.new(0.7, 0, 1, 0)

    local valLbl = UILib.newLabel(top, "", Enum.Font.GothamBold, 13, _cfg.Text, Enum.TextXAlignment.Right)
    valLbl.Size     = UDim2.new(0.3, 0, 1, 0)
    valLbl.Position = UDim2.new(0.7, 0, 0, 0)

    local track            = Instance.new("Frame")
    track.Name = "Track"
    track.Size             = UDim2.new(1, -24, 0, 10)
    track.Position         = UDim2.new(0, 12, 0, 38)
    track.BackgroundColor3 = _cfg.BG3
    track.BorderSizePixel  = 0
    track.Parent           = wrap
    UILib.addCorner(track, 999)
    UILib.addStroke(track, 1, _cfg.Stroke, 0.6)

    local fill            = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size             = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = _cfg.Accent
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    UILib.addCorner(fill, 999)

    local knob              = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size               = UDim2.fromOffset(16, 16)
    knob.AnchorPoint        = Vector2.new(0.5, 0.5)
    knob.Position           = UDim2.new(0, 0, 0.5, 0)
    knob.BackgroundColor3   = Color3.fromRGB(235, 240, 255)
    knob.BorderSizePixel    = 0
    knob.Parent             = track
    UILib.addCorner(knob, 999)
    UILib.addStroke(knob, 1, _cfg.Accent, 0.2)

    local dragging = false
    local cur      = defV
    local _TS      = game:GetService("TweenService")
    local _sliderTweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)

    local function fmt(v)
        if decimals and decimals > 0 then
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring(math.floor(v + 0.5))
    end

    local function setVal(v)
        cur         = UILib.clamp(v, minV, maxV)
        local a     = (cur - minV) / (maxV - minV)
        _TS:Create(fill, _sliderTweenInfo, { Size = UDim2.new(a, 0, 1, 0) }):Play()
        _TS:Create(knob, _sliderTweenInfo, { Position = UDim2.new(a, 0, 0.5, 0) }):Play()
        valLbl.Text = fmt(cur)
        if onChange then onChange(cur); pcall(_scheduleSave) end
    end

    local function fromX(x)
        local rel = UILib.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        setVal(minV + (rel / track.AbsoluteSize.X) * (maxV - minV))
    end

    track.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; fromX(inp.Position.X)
        end
    end)
    track.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    _UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            fromX(inp.Position.X)
        end
    end)

    setVal(defV)
    return { Set = setVal, Get = function() return cur end }
end

--- Create a generic action button, right-aligned in a parent row
---@param parent      Instance
---@param text        string
---@param width       number|nil   (default 80)
---@param posOverride UDim2|nil
---@param onClick     function|nil
---@return TextButton
function UILib.actionBtn(parent, text, width, posOverride, onClick)
    local b            = Instance.new("TextButton")
    b.Name = "ActionBtn"
    b.AutoButtonColor  = false
    b.Size             = UDim2.fromOffset(width or 80, 26)
    b.Position         = posOverride or UDim2.new(1, -(width or 80) - 6, 0.5, -13)
    b.BackgroundColor3 = _cfg.BG3
    b.TextColor3       = _cfg.Accent
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 12
    b.Text             = text
    b.BorderSizePixel  = 0
    b.Parent           = parent
    UILib.addCorner(b, 8)
    b.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
    b.TextStrokeTransparency = 1
    b.MouseEnter:Connect(function()  b.BackgroundColor3 = _cfg.AccentDim; b.TextStrokeTransparency = 0.4 end)
    b.MouseLeave:Connect(function()  b.BackgroundColor3 = _cfg.BG3;       b.TextStrokeTransparency = 1   end)
    b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
    UILib.attachBounce(b, b.Size)
    return b
end

--- Create a keyboard shortcut display chip
---@param parent   Instance
---@param text     string
---@param xOffset  number  (e.g. -168, offsets from right edge of parent)
---@return TextLabel
function UILib.keyChip(parent, text, xOffset)
    local lbl               = UILib.newLabel(parent, text, Enum.Font.GothamBold, 11, _cfg.Accent, Enum.TextXAlignment.Center)
    lbl.Size                = UDim2.fromOffset(66, 22)
    lbl.Position            = UDim2.new(1, xOffset, 0.5, -11)
    lbl.BackgroundColor3    = _cfg.BG3
    lbl.BackgroundTransparency = 0
    UILib.addCorner(lbl, 6)
    UILib.addStroke(lbl, 1, _cfg.Stroke, 0.4)
    return lbl
end

--- Row with a keybind chip + Set Key button + toggle pill
---@param title     string
---@param getKey    function -> Enum.KeyCode
---@param setKey    function(Enum.KeyCode)
---@param getToggle function -> boolean
---@param setToggle function(boolean)
---@param onToggle  function(boolean)|nil
---@return { KeyLabel: TextLabel, SyncToggle: function }
-- ════════════════════════════════════════════════════════════════════
-- keybindToggleRow  –  simplified string-key API
--
--   title      : string   display label
--   keybindKey : string   field in keybinds table  e.g. "SpeedToggle"
--   cfgKey     : string   field in cfg table        e.g. "SpeedEnabled"
--   action     : function()|nil   extra code to run on keypress (optional)
--                The toggle flip + syncFn call is handled automatically.
--                Use this only if you need something extra, e.g. print().
--
-- Usage:
--   local row = UILib.keybindToggleRow("Speed Toggle", "SpeedToggle", "SpeedEnabled")
--   syncFns.SpeedEnabled = row.SyncToggle
-- ════════════════════════════════════════════════════════════════════
function UILib.keybindToggleRow(title, keybindKey, cfgKey, action)
    _registerFeature(title)
    local r      = UILib.rowFrame(40, title:gsub("[^%w]", "_"))
    UILib.rowLabel(r, title)
    local keyLbl = UILib.keyChip(r, _keybinds[keybindKey].Name, -248)
    UILib.actionBtn(r, "Set Key", 68, UDim2.new(1, -172, 0.5, -13), function()
        _keyCapture.active     = true
        _keyCapture.keybindKey = keybindKey
        _keyCapture.label      = keyLbl
        keyLbl.Text            = "..."
    end)
    local _, sync, triggerBounce = UILib.togglePill(r, _cfg[cfgKey], function(v)
        _cfg[cfgKey] = v
        if action then action() end
    end)
    _keybindActions[keybindKey] = function()
        _cfg[cfgKey] = not _cfg[cfgKey]
        if sync then sync(_cfg[cfgKey]) end
        if triggerBounce then triggerBounce() end
        if action then action() end
    end
    return { KeyLabel = keyLbl, SyncToggle = sync }
end

--- Row with just a keybind chip + Set Key button (no toggle pill)
--
--   title      : string   display label
--   keybindKey : string   field in keybinds table  e.g. "TriggerToggle"
--   action     : function()   code to run when key is pressed
--
-- Usage:
--   UILib.keybindRow("Trigger Toggle", "TriggerToggle", function()
--       cfg.TriggerBotEnabled = not cfg.TriggerBotEnabled
--       if syncFns.TriggerBotEnabled then syncFns.TriggerBotEnabled(cfg.TriggerBotEnabled) end
--   end)
function UILib.keybindRow(title, keybindKey, action)
    _registerFeature(title)
    local r      = UILib.rowFrame(40, title:gsub("[^%w]", "_"))
    UILib.rowLabel(r, title)
    local keyLbl = UILib.keyChip(r, _keybinds[keybindKey].Name, -168)
    UILib.actionBtn(r, "Set Key", 68, UDim2.new(1, -82, 0.5, -13), function()
        _keyCapture.active     = true
        _keyCapture.keybindKey = keybindKey
        _keyCapture.label      = keyLbl
        keyLbl.Text            = "..."
    end)
    if keybindKey and action then
        _keybindActions[keybindKey] = action
    end
    return keyLbl
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A7 · TAB SYSTEM
-- Creates and manages tab navigation buttons.
-- ════════════════════════════════════════════════════════════════════

--- Build the full tab button bar.
---@param tabScroller  ScrollingFrame   the horizontal tab scroll frame
---@param tabDefs      table            { {name, renderFn}, ... }
---@param onActivate   function(name, fn)  called when a tab is clicked
---@return tabBtns: table<string, TextButton>, activateTab: function(name)
function UILib.buildTabBar(tabScroller, tabDefs, onActivate)
    local tabBtns    = {}
    local tabOrder   = {}   -- ordered list of names so we can compute distance
    local currentTab = nil
    local switching  = false
    local TS         = game:GetService("TweenService")
    local RS         = game:GetService("RunService")
    local FADE_IN    = TweenInfo.new(0.13, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- slideBg lives in tabScroller's PARENT (tabShell) so it is in screen space,
    -- not the scrolling canvas. This means:
    --   • UIListLayout never touches it (no layout pollution)
    --   • CanvasPosition changes don't drift it — we track the button's AbsolutePosition directly
    local tabShell = tabScroller.Parent
    local slideBg = Instance.new("Frame")
    slideBg.Name             = "TabSlideBg"
    slideBg.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    slideBg.BorderSizePixel  = 0
    slideBg.ZIndex           = 0  -- behind tabScroller (ZIndex 1) so button text shows on top
    slideBg.Size             = UDim2.fromOffset(96, 30)
    slideBg.Position         = UDim2.fromOffset(0, 0)
    slideBg.Parent           = tabShell
    UILib.addCorner(slideBg, 8)

    local SLIDE_TWEEN     = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local slideTween      = nil
    local slideReady      = false
    local activeBtn       = nil
    local scrollTrackConn = nil
    local scrollTween     = nil

    -- slideBg is a sibling of tabScroller inside tabShell (screen space).
    -- btn.AbsolutePosition already reflects canvas scrolling, so we just
    -- subtract tabShell's origin to get tabShell-local coords.
    local function getBgFrame(btn)
        local ox = tabShell.AbsolutePosition.X
        local oy = tabShell.AbsolutePosition.Y
        return btn.AbsolutePosition.X - ox,
               btn.AbsolutePosition.Y - oy,
               btn.AbsoluteSize.X,
               btn.AbsoluteSize.Y
    end

    -- Snap or tween slideBg to a button's current screen position.
    -- Only call this when no scroll is in progress (scroll uses Heartbeat instead).
    local function slideTo(btn, snap)
        local x, y, w, h = getBgFrame(btn)
        if snap or not slideReady then
            slideBg.Position = UDim2.fromOffset(x, y)
            slideBg.Size     = UDim2.fromOffset(w, h)
            slideReady = true
            return
        end
        if slideTween then slideTween:Cancel() end
        slideTween = TS:Create(slideBg, SLIDE_TWEEN, {
            Position = UDim2.fromOffset(x, y),
            Size     = UDim2.fromOffset(w, h),
        })
        slideTween:Play()
    end

    local function activateTab(name)
        currentTab = name
        for t, btn in pairs(tabBtns) do
            local on = (t == name)
            TS:Create(btn, SLIDE_TWEEN, { TextColor3 = on and _cfg.Accent or _cfg.Muted }):Play()
            if on then activeBtn = btn end
        end
        -- slideTo is NOT called here — scrollToTab handles positioning so there's
        -- no conflict between a slide tween and the Heartbeat scroll tracker.
    end

    -- Scroll the tab bar to center the active tab, and simultaneously drive
    -- slideBg via Heartbeat so it stays locked to the button as the canvas moves.
    -- No task.defer — positions are read immediately so scroll starts this frame.
    local function scrollToTab(name)
        local btn = tabBtns[name]
        if not btn then return end

        -- Cancel any prior scroll + tracker
        if scrollTween then scrollTween:Cancel() end
        if scrollTrackConn then scrollTrackConn:Disconnect(); scrollTrackConn = nil end

        local btnX    = btn.AbsolutePosition.X - tabScroller.AbsolutePosition.X
                      + tabScroller.CanvasPosition.X
        local center  = btnX - (tabScroller.AbsoluteSize.X / 2) + (btn.AbsoluteSize.X / 2)
        local maxX    = tabScroller.AbsoluteCanvasSize.X - tabScroller.AbsoluteSize.X
        local targetX = math.clamp(center, 0, math.max(0, maxX))
        local dist    = math.abs(targetX - tabScroller.CanvasPosition.X)

        if dist < 1 then
            -- No scroll needed — just slide the indicator directly
            slideTo(btn)
            return
        end

        local dur  = math.clamp(dist / 600, 0.12, 0.30)
        local info = TweenInfo.new(dur, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        scrollTween = TS:Create(tabScroller, info, { CanvasPosition = Vector2.new(targetX, 0) })
        scrollTween:Play()

        -- While the canvas scrolls, btn.AbsolutePosition updates each frame.
        -- Pin slideBg to it live so the dark bg glides in sync with the scroll.
        scrollTrackConn = RS.Heartbeat:Connect(function()
            if activeBtn then
                local x, y, w, h = getBgFrame(activeBtn)
                slideBg.Position = UDim2.fromOffset(x, y)
                slideBg.Size     = UDim2.fromOffset(w, h)
                slideReady = true
            end
        end)
        scrollTween.Completed:Connect(function()
            if scrollTrackConn then scrollTrackConn:Disconnect(); scrollTrackConn = nil end
            if activeBtn then slideTo(activeBtn, true) end  -- final snap after scroll settles
        end)
    end

    -- Recursively collect every GuiObject under a parent
    local function collectDescendants(parent, out)
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("GuiObject") then
                table.insert(out, child)
                collectDescendants(child, out)
            end
        end
    end

    local function switchTab(name, fn)
        if switching then return end
        switching = true

        UILib.closeColorPicker()
        _content.CanvasPosition = Vector2.new(0, 0)
        UILib.setActiveTab(name)  -- ensure features register under the correct tab
        fn()

        -- Snapshot real transparency values, force invisible, then tween back in
        local objs = {}
        collectDescendants(_content, objs)
        local snapshots = {}
        for _, obj in ipairs(objs) do
            local snap = { obj = obj }
            snap.BackgroundTransparency = obj.BackgroundTransparency
            obj.BackgroundTransparency  = 1
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                snap.TextTransparency = obj.TextTransparency
                obj.TextTransparency  = 1
            end
            table.insert(snapshots, snap)
        end

        task.defer(function()
            local pending = #snapshots
            if pending == 0 then switching = false return end
            for _, snap in ipairs(snapshots) do
                local props = { BackgroundTransparency = snap.BackgroundTransparency }
                if snap.TextTransparency then props.TextTransparency = snap.TextTransparency end
                local t = TS:Create(snap.obj, FADE_IN, props)
                t:Play()
                t.Completed:Connect(function()
                    pending -= 1
                    if pending <= 0 then switching = false end
                end)
            end
        end)
    end

    for i, def in ipairs(tabDefs) do
        local name, fn = def[1], def[2]
        local b            = Instance.new("TextButton")
        b.Name = name
        b.AutoButtonColor        = false
        b.BackgroundColor3       = _cfg.BG3
        b.BackgroundTransparency = 0
        b.BorderSizePixel        = 0
        b.Font             = Enum.Font.GothamBold
        b.TextSize         = 13
        b.TextColor3       = _cfg.Muted
        b.Text             = name
        b.Size             = UDim2.fromOffset(96, 30)
        b.LayoutOrder      = i
        b.Parent           = tabScroller
        UILib.addCorner(b, 8)
        tabBtns[name] = b
        table.insert(tabOrder, name)

        b.MouseButton1Click:Connect(function()
            if currentTab == name then return end
            activateTab(name)
            scrollToTab(name)
            if onActivate then onActivate(name, fn) end
            switchTab(name, fn)
        end)
    end

    -- Expose scrollToTab so external activateTab calls (e.g. search bar) also scroll
    UILib._scrollToTab = scrollToTab

    return tabBtns, function(name)
        activateTab(name)
        task.defer(function() scrollToTab(name) end)
    end
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A8 · GLOBAL FEATURE SEARCH
-- Floating search bar that jumps to sections by keyword.
-- ════════════════════════════════════════════════════════════════════

---@param main          Frame                      the main panel Frame
---@param renderMap     table<string, function>    tab name -> render function
---@param activateTabFn function(name)
function UILib.buildSearchBar(main, renderMap, activateTabFn)
    -- SEARCH_INDEX is rebuilt on every keystroke so newly-registered
    -- sections (added after the first render) are always included.
    local function buildIndex()
        local idx = {}
        for tab, features in pairs(_tabFeatures) do
            for _, feat in ipairs(features) do
                table.insert(idx, { text = feat, tab = tab, keyword = feat:lower() })
            end
        end
        return idx
    end

    -- Frame
    local sbFrame = Instance.new("Frame", main)
    sbFrame.Name = "SbFrame"
    sbFrame.Size             = UDim2.fromOffset(168, 28)
    sbFrame.Position         = UDim2.new(1, -176, 0, 7)
    sbFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
    sbFrame.BorderSizePixel  = 0
    UILib.addCorner(sbFrame, 8)
    UILib.addStroke(sbFrame, 1, _cfg.Accent, 0.5)

    local sbIcon = Instance.new("TextLabel", sbFrame)
    sbIcon.Name = "SearchIcon"
    sbIcon.Size                 = UDim2.fromOffset(24, 28)
    sbIcon.BackgroundTransparency = 1
    sbIcon.Text                 = "S"
    sbIcon.Font                 = Enum.Font.GothamBold
    sbIcon.TextSize             = 14
    sbIcon.TextColor3           = _cfg.Accent
    sbIcon.BorderSizePixel      = 0

    local sbBox = Instance.new("TextBox", sbFrame)
    sbBox.Name = "SearchInput"
    sbBox.Size                  = UDim2.new(1, -28, 1, 0)
    sbBox.Position              = UDim2.fromOffset(24, 0)
    sbBox.BackgroundTransparency = 1
    sbBox.Text                  = ""
    sbBox.PlaceholderText       = "Search features..."
    sbBox.Font                  = Enum.Font.GothamSemibold
    sbBox.TextSize              = 12
    sbBox.ClearTextOnFocus      = true
    sbBox.TextColor3            = _cfg.Text
    sbBox.PlaceholderColor3     = _cfg.Muted
    sbBox.BorderSizePixel       = 0
    sbBox.TextXAlignment        = Enum.TextXAlignment.Left
    sbBox.ClipsDescendants = true
    sbBox.TextTruncate = Enum.TextTruncate.AtEnd

    -- Dropdown
    local sbDropdown = Instance.new("Frame", _ScreenGui)
    sbDropdown.Name = "SearchDropdown"
    sbDropdown.Size             = UDim2.fromOffset(200, 0)
    sbDropdown.BackgroundColor3 = Color3.fromRGB(18, 20, 32)
    sbDropdown.BorderSizePixel  = 0
    sbDropdown.Visible          = false
    sbDropdown.ZIndex           = 50
    UILib.addCorner(sbDropdown, 8)
    UILib.addStroke(sbDropdown, 1.5, _cfg.Accent, 0.2)

    local sbLayout = Instance.new("UIListLayout", sbDropdown)
    sbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    sbLayout.Padding   = UDim.new(0, 2)
    local sbPad = Instance.new("UIPadding", sbDropdown)
    sbPad.PaddingTop    = UDim.new(0, 4); sbPad.PaddingBottom = UDim.new(0, 4)
    sbPad.PaddingLeft   = UDim.new(0, 4); sbPad.PaddingRight  = UDim.new(0, 4)

    local function updateDropdownPos()
        local abs = sbFrame.AbsolutePosition
        local sz  = sbFrame.AbsoluteSize
        sbDropdown.Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 65)
    end
    sbFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateDropdownPos)
    sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sbDropdown.Size = UDim2.fromOffset(280, math.min(sbLayout.AbsoluteContentSize.Y + 8, 10000))
    end)
    task.defer(updateDropdownPos)

    local _sbHovering = false

    local function rebuildDropdown(query)
        for _, c in ipairs(sbDropdown:GetChildren()) do
            if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end
        end
        if query == "" then sbDropdown.Visible = false; return end
        local q       = query:lower()
        local matches = {}
        for _, entry in ipairs(buildIndex()) do
            if entry.keyword:find(q, 1, true) then table.insert(matches, entry) end
        end
        if #matches == 0 then
            local noLbl = Instance.new("TextLabel", sbDropdown)
            noLbl.Name = "NoResults"
            noLbl.Size                 = UDim2.new(1, 0, 0, 28)
            noLbl.BackgroundTransparency = 1
            noLbl.Text                 = 'No results for "' .. query .. '"'
            noLbl.Font                 = Enum.Font.Gotham
            noLbl.TextSize             = 11
            noLbl.TextColor3           = _cfg.Muted
            noLbl.BorderSizePixel      = 0
            noLbl.ZIndex               = 51
            noLbl.TextTruncate = Enum.TextTruncate.AtEnd
            sbDropdown.Visible = true
            return
        end
        for _, entry in ipairs(matches) do
            local btn = Instance.new("TextButton", sbDropdown)
            btn.Name = "ResultBtn"
            btn.Size             = UDim2.new(1, 0, 0, 30)
            btn.AutoButtonColor  = false
            btn.BackgroundColor3 = Color3.fromRGB(26, 28, 42)
            btn.TextColor3       = _cfg.Text
            btn.Font             = Enum.Font.GothamSemibold
            btn.TextSize         = 11
            btn.Text             = "  [" .. entry.tab .. "]  " .. entry.text
            btn.TextXAlignment   = Enum.TextXAlignment.Left
            btn.BorderSizePixel  = 0
            btn.ZIndex           = 51
            UILib.addCorner(btn, 6)
            local cap = entry
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = _cfg.AccentDim; _sbHovering = true  end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(26,28,42); _sbHovering = false end)
            btn.MouseButton1Down:Connect(function()
                _sbHovering      = false
                sbBox.Text       = ""
                sbDropdown.Visible = false
                if activeTab ~= cap.tab then
                    activateTabFn(cap.tab)
                    local fn = renderMap[cap.tab]
                    if fn then fn() end
                end

            -- Scroll to feature row and flash it green
                task.spawn(function()
                    local timeout = 0
                    local layout = _content:FindFirstChildOfClass("UIListLayout")
                    while (not layout or layout.AbsoluteContentSize.Y == 0) and timeout < 10 do
                        task.wait()
                        timeout += 1
                    end
                    task.wait() -- one extra frame for layout to finalize

                    local targetText = cap.text
                    for _, child in ipairs(_content:GetChildren()) do
                        if child:IsA("Frame") then
                            for _, lbl in ipairs(child:GetDescendants()) do
                                if lbl:IsA("TextLabel") and (lbl.Text == targetText or lbl.Text == targetText .. "  (i)") then
                                    -- Scroll to it
                                    local targetY = child.AbsolutePosition.Y
                                                  - _content.AbsolutePosition.Y
                                                  + _content.CanvasPosition.Y
                                    _content.CanvasPosition = Vector2.new(0, math.max(0, targetY - 8))

                                    -- Flash all TextLabels in the row green then fade back

                                    local origColors = {}
                                    for _, d in ipairs(child:GetDescendants()) do
                                        if d:IsA("TextLabel") then
                                            origColors[d] = d.TextColor3
                                        end
                                    end
                                    task.spawn(function()
                                        local steps   = 20
                                        local fadeIn  = 0.5
                                        local fadeOut = 0.5
                                        -- Fade in to green
                                        task.wait(0.2)
                                        for s = 1, steps do
                                            task.wait(fadeIn / steps)
                                            local t = s / steps
                                            for d, orig in pairs(origColors) do
                                                if d and d.Parent then
                                                    d.TextColor3 = Color3.fromRGB(
                                                        math.floor(orig.R * 255 + (0   - orig.R * 255) * t),
                                                        math.floor(orig.G * 255 + (220 - orig.G * 255) * t),
                                                        math.floor(orig.B * 255 + (90  - orig.B * 255) * t)
                                                    )
                                                end
                                            end
                                        end
                                        -- Fade out back to original
                                        for s = 1, steps do
                                            task.wait(fadeOut / steps)
                                            local t = s / steps
                                            for d, orig in pairs(origColors) do
                                                if d and d.Parent then
                                                    d.TextColor3 = Color3.fromRGB(
                                                        math.floor(0   + (orig.R * 255) * t),
                                                        math.floor(220 + (orig.G * 255 - 220) * t),
                                                        math.floor(90  + (orig.B * 255 - 90)  * t)
                                                    )
                                                end
                                            end
                                        end
                                        -- Restore exact original colors
                                        for d, orig in pairs(origColors) do
                                            if d and d.Parent then d.TextColor3 = orig end
                                        end
                                    end)

                                    break
                                end
                            end
                        end
                    end
                end) -- closes task.spawn
            end)
        end
        sbDropdown.Visible = true
    end

    sbBox:GetPropertyChangedSignal("Text"):Connect(function() rebuildDropdown(sbBox.Text) end)
    sbBox.FocusLost:Connect(function()
        task.wait(0.12)
        if not _sbHovering then sbDropdown.Visible = false end
    end)
    sbBox.Focused:Connect(function()
        if sbBox.Text ~= "" then rebuildDropdown(sbBox.Text) end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A9 · DRAGGABLE WINDOW
-- Makes any Frame draggable by an attached header.
-- ════════════════════════════════════════════════════════════════════

--- Wire up smooth lerp-based drag behaviour on `window` using `handle` as the drag target.
--- The window glides toward the cursor with momentum and settles smoothly on release.
---@param window    Frame
---@param handle    GuiObject
---@param dragSpeed number|nil  lerp speed multiplier (default 8)
function UILib.makeDraggable(window, handle, dragSpeed)
    local DRAG_SPEED  = dragSpeed or 8
    local dragging    = false
    local startPos    = nil   -- window.Position at drag start
    local lastMousePos = nil  -- mouse position at drag start
    local lastGoalPos = nil   -- last computed goal UDim2

    local function lerp(a, b, m) return a + (b - a) * m end

    -- Grab drag start state
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging      = true
            startPos      = window.Position
            lastMousePos  = _UIS:GetMouseLocation()
            lastGoalPos   = nil
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    -- Per-frame update: lerp window toward goal
    game:GetService("RunService").Heartbeat:Connect(function(dt)
        if not startPos then return end

        if not dragging and lastGoalPos then
            -- Settle: lerp toward goal, snap + stop once close enough
            local newX  = lerp(window.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED)
            local newY  = lerp(window.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED)
            if math.abs(newX - lastGoalPos.X.Offset) < 0.5 and math.abs(newY - lastGoalPos.Y.Offset) < 0.5 then
                window.Position = lastGoalPos
                lastGoalPos     = nil
                startPos        = nil
            else
                window.Position = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)
            end
            return
        end

        if dragging and lastMousePos then
            local delta = lastMousePos - _UIS:GetMouseLocation()
            local xGoal = startPos.X.Offset - delta.X
            local yGoal = startPos.Y.Offset - delta.Y
            lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)
            window.Position = UDim2.new(
                startPos.X.Scale,
                lerp(window.Position.X.Offset, xGoal, dt * DRAG_SPEED),
                startPos.Y.Scale,
                lerp(window.Position.Y.Offset, yGoal, dt * DRAG_SPEED)
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A10 · NOTIFICATION
-- Thin wrapper around StarterGui SetCore SendNotification.
-- ════════════════════════════════════════════════════════════════════

---@param title    string
---@param text     string
---@param duration number|nil  (default 3)
function UILib.notify(title, text, duration)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title    = title or "",
            Text     = text  or "",
            Duration = duration or 3,
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A11 · COLOR PICKER ROW  (basic RGB, no wheel)
-- ════════════════════════════════════════════════════════════════════

---@param labelText  string
---@param initColor  Color3
---@param onChange   function(Color3)
---@return { SetColor: function }
-- ════════════════════════════════════════════════════════════════════
-- SECTION A11b · HSV COLOR PICKER
-- Compact row widget that opens a floating HSV color picker popup.
-- The popup contains:
--   • Saturation/Value square  (H-tinted background, white→black gradients)
--   • Hue bar                  (rainbow gradient)
--   • Alpha bar                (checkerboard → color gradient)
--   • RGBA text readout        (e.g. "157, 46, 46, 1")
-- Clicking anywhere outside the popup closes it.
-- ════════════════════════════════════════════════════════════════════

-- Track the currently open color picker so only one is open at a time.
local _openColorPicker = nil
-- Closes whatever color picker popup is currently open (called on tab switch)
function UILib.closeColorPicker()
    if _openColorPicker then
        _openColorPicker.Visible = false
        _openColorPicker = nil
    end
end

function UILib.createColorRow(labelText, initColor, onChange)
    -- ── Row ────────────────────────────────────────────────────────
    local row            = Instance.new("Frame")
    row.Name             = "ColorRow_" .. labelText:gsub("%s", "_")
    row.BackgroundColor3 = _cfg.BG2
    row.BorderSizePixel  = 0
    row.Size             = UDim2.new(1, 0, 0, 40)
    row.Parent           = _content
    UILib.addCorner(row, 8)
    UILib.addStroke(row, 1, _cfg.Stroke, 0.5)

    -- Label
    local lbl          = UILib.newLabel(row, labelText, Enum.Font.GothamSemibold, 13, _cfg.Text)
    lbl.Size           = UDim2.new(1, -60, 1, 0)
    lbl.Position       = UDim2.fromOffset(12, 0)
    lbl.TextYAlignment = Enum.TextYAlignment.Center

    -- Color swatch button
    local swatchBtn            = Instance.new("TextButton")
    swatchBtn.Name             = "Swatch"
    swatchBtn.Size             = UDim2.fromOffset(32, 22)
    swatchBtn.AnchorPoint      = Vector2.new(1, 0.5)
    swatchBtn.Position         = UDim2.new(1, -10, 0.5, 0)
    swatchBtn.BackgroundColor3 = initColor
    swatchBtn.BorderSizePixel  = 0
    swatchBtn.Text             = ""
    swatchBtn.AutoButtonColor  = false
    swatchBtn.Parent           = row
    UILib.addCorner(swatchBtn, 5)
    UILib.addStroke(swatchBtn, 1, _cfg.Stroke, 0.2)

    -- HSV state (initialize from initColor)
    local h, s, v = initColor:ToHSV()
    local a       = 0  -- millenium convention: 0 = fully opaque, 1 = fully transparent

    -- ── Popup ──────────────────────────────────────────────────────
    -- Popup is parented to ScreenGui so it floats above everything.
    local POPUP_W, POPUP_H = 180, 209

    local popup            = Instance.new("Frame")
    popup.Name             = "ColorPickerPopup"
    popup.Size             = UDim2.fromOffset(POPUP_W, POPUP_H)
    popup.BackgroundColor3 = _cfg.BG
    popup.BorderSizePixel  = 0
    popup.Visible          = false
    popup.ZIndex           = 500
    popup.Parent           = _ScreenGui
    UILib.addCorner(popup, 8)
    UILib.addStroke(popup, 1, _cfg.Stroke, 0.2)

    -- Fade overlay — sits on top, tweens transparent on open (millenium pattern)
    local popupFade                   = Instance.new("Frame", popup)
    popupFade.Name                    = "Fade"
    popupFade.Size                    = UDim2.new(1, 0, 1, 0)
    popupFade.BackgroundColor3        = _cfg.BG
    popupFade.BorderSizePixel         = 0
    popupFade.BackgroundTransparency  = 1  -- starts transparent (hidden until open)
    popupFade.ZIndex                  = 600
    UILib.addCorner(popupFade, 8)

    -- ── Sat/Val square ─────────────────────────────────────────────
    local SV_SIZE = 160
    local SV_H    = 110

    local svHolder            = Instance.new("Frame", popup)
    svHolder.Name             = "SVHolder"
    svHolder.Size             = UDim2.fromOffset(SV_SIZE, SV_H)
    svHolder.Position         = UDim2.fromOffset(10, 10)
    svHolder.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    svHolder.BorderSizePixel  = 0
    svHolder.ZIndex           = 501
    UILib.addCorner(svHolder, 5)

    -- White (left→right saturation)
    local svWhite              = Instance.new("Frame", svHolder)
    svWhite.Name               = "SVWhite"
    svWhite.Size               = UDim2.new(1, 0, 1, 0)
    svWhite.BackgroundColor3   = Color3.new(1, 1, 1)
    svWhite.BorderSizePixel    = 0
    svWhite.ZIndex             = 502
    UILib.addCorner(svWhite, 5)
    local svWhiteGrad          = Instance.new("UIGradient", svWhite)
    svWhiteGrad.Color          = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(1,1,1))
    }
    svWhiteGrad.Transparency   = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1)
    }

    -- Black overlay (top→bottom value)
    local svBlack              = Instance.new("Frame", svHolder)
    svBlack.Name               = "SVBlack"
    svBlack.Size               = UDim2.new(1, 0, 1, 0)
    svBlack.BackgroundColor3   = Color3.new(0, 0, 0)
    svBlack.BorderSizePixel    = 0
    svBlack.ZIndex             = 503
    UILib.addCorner(svBlack, 5)
    local svBlackGrad          = Instance.new("UIGradient", svBlack)
    svBlackGrad.Rotation       = 90
    svBlackGrad.Transparency   = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    }

    -- SV drag surface (transparent button on top)
    local svBtn                = Instance.new("TextButton", svHolder)
    svBtn.Name                 = "SVBtn"
    svBtn.Size                 = UDim2.new(1, 0, 1, 0)
    svBtn.BackgroundTransparency = 1
    svBtn.Text                 = ""
    svBtn.AutoButtonColor      = false
    svBtn.ZIndex               = 505
    UILib.addCorner(svBtn, 5)

    -- SV cursor
    local svCursor             = Instance.new("Frame", svHolder)
    svCursor.Name              = "SVCursor"
    svCursor.Size              = UDim2.fromOffset(10, 10)
    svCursor.AnchorPoint       = Vector2.new(0.5, 0.5)
    svCursor.BackgroundColor3  = Color3.new(1, 1, 1)
    svCursor.BorderSizePixel   = 0
    svCursor.ZIndex            = 506
    UILib.addCorner(svCursor, 999)
    UILib.addStroke(svCursor, 1.5, Color3.new(1,1,1), 0)

    -- ── Hue bar ────────────────────────────────────────────────────
    local HUE_Y = SV_H + 18

    local hueBar            = Instance.new("Frame", popup)
    hueBar.Name             = "HueBar"
    hueBar.Size             = UDim2.fromOffset(SV_SIZE, 10)
    hueBar.Position         = UDim2.fromOffset(10, HUE_Y)
    hueBar.BackgroundColor3 = Color3.new(1, 1, 1)  -- must be white so UIGradient colors aren't tinted
    hueBar.BorderSizePixel  = 0
    hueBar.ZIndex           = 501
    UILib.addCorner(hueBar, 999)

    local hueGrad    = Instance.new("UIGradient", hueBar)
    do
        local kps = {}
        local steps = 18
        for i = 0, steps do
            local t = i / steps
            kps[i + 1] = ColorSequenceKeypoint.new(t, Color3.fromHSV(t, 1, 1))
        end
        hueGrad.Color = ColorSequence.new(kps)
    end

    local hueBtn               = Instance.new("TextButton", hueBar)
    hueBtn.Name                = "HueBtn"
    hueBtn.Size                = UDim2.new(1, 0, 1, 0)
    hueBtn.BackgroundTransparency = 1
    hueBtn.Text                = ""
    hueBtn.AutoButtonColor     = false
    hueBtn.ZIndex              = 502

    local hueCursor            = Instance.new("Frame", hueBar)
    hueCursor.Name             = "HueCursor"
    hueCursor.Size             = UDim2.fromOffset(10, 10)
    hueCursor.AnchorPoint      = Vector2.new(0.5, 0.5)
    hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCursor.BorderSizePixel  = 0
    hueCursor.ZIndex           = 503
    UILib.addCorner(hueCursor, 999)
    UILib.addStroke(hueCursor, 1.5, Color3.new(1,1,1), 0)

    -- ── Alpha bar ──────────────────────────────────────────────────
    local ALPHA_Y = HUE_Y + 20

    -- Alpha bar: same size as hue bar (SV_SIZE x 10)
    -- Millenium convention: a=0 = fully opaque (cursor far right), a=1 = transparent (cursor far left)
    -- RGBA displays (1 - a) so right = 1, left = 0
    local alphaBack            = Instance.new("Frame", popup)
    alphaBack.Name             = "AlphaBack"
    alphaBack.Size             = UDim2.fromOffset(SV_SIZE, 10)
    alphaBack.Position         = UDim2.fromOffset(10, ALPHA_Y)
    alphaBack.BackgroundColor3 = Color3.fromRGB(25, 25, 29)
    alphaBack.BorderSizePixel  = 0
    alphaBack.ZIndex           = 501
    UILib.addCorner(alphaBack, 999)

    -- Checkerboard tile (same Millenium asset) visible on the transparent (left) side
    local alphaChecker         = Instance.new("ImageLabel", alphaBack)
    alphaChecker.Name          = "AlphaChecker"
    alphaChecker.Size          = UDim2.new(1, 0, 1, 0)
    alphaChecker.BackgroundTransparency = 1
    alphaChecker.Image         = "rbxassetid://18274452449"
    alphaChecker.ScaleType     = Enum.ScaleType.Tile
    alphaChecker.TileSize      = UDim2.fromOffset(6, 6)
    alphaChecker.BorderSizePixel = 0
    alphaChecker.ZIndex        = 502
    UILib.addCorner(alphaChecker, 999)

    -- Color overlay: grey (left/transparent) -> hue color (right/opaque)
    local alphaGrad            = Instance.new("UIGradient", alphaChecker)
    alphaGrad.Color            = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(112, 112, 112)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
    }
    alphaGrad.Transparency     = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.806),
        NumberSequenceKeypoint.new(1, 0)
    }

    local alphaBtn             = Instance.new("TextButton", alphaBack)
    alphaBtn.Name              = "AlphaBtn"
    alphaBtn.Size              = UDim2.new(1, 0, 1, 0)
    alphaBtn.BackgroundTransparency = 1
    alphaBtn.Text              = ""
    alphaBtn.AutoButtonColor   = false
    alphaBtn.ZIndex            = 505

    -- AnchorPoint=(0,0.5) matching Millenium; starts far right (a=0 = opaque)
    local alphaCursor          = Instance.new("Frame", alphaBack)
    alphaCursor.Name           = "AlphaCursor"
    alphaCursor.Size           = UDim2.fromOffset(10, 10)
    alphaCursor.AnchorPoint    = Vector2.new(0, 0.5)
    alphaCursor.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    alphaCursor.BorderSizePixel  = 0
    alphaCursor.ZIndex         = 506
    UILib.addCorner(alphaCursor, 999)
    UILib.addStroke(alphaCursor, 1.5, Color3.new(1,1,1), 0)

    -- ── RGBA text input (editable, like millenium) ─────────────────
    local RGBA_Y = ALPHA_Y + 22

    local rgbaBox              = Instance.new("Frame", popup)
    rgbaBox.Name               = "RGBABox"
    rgbaBox.Size               = UDim2.fromOffset(SV_SIZE, 26)
    rgbaBox.Position           = UDim2.fromOffset(10, RGBA_Y)
    rgbaBox.BackgroundColor3   = _cfg.BG2
    rgbaBox.BorderSizePixel    = 0
    rgbaBox.ZIndex             = 501
    UILib.addCorner(rgbaBox, 4)
    UILib.addStroke(rgbaBox, 1, _cfg.Stroke, 0.4)

    local rgbaBox_inner        = Instance.new("TextBox", rgbaBox)
    rgbaBox_inner.Name         = "RGBAInput"
    rgbaBox_inner.Size         = UDim2.new(1, 0, 1, 0)
    rgbaBox_inner.Position     = UDim2.fromOffset(0, 0)
    rgbaBox_inner.BackgroundTransparency = 1
    rgbaBox_inner.Font         = Enum.Font.GothamBold
    rgbaBox_inner.TextSize     = 11
    rgbaBox_inner.TextColor3   = _cfg.Muted
    rgbaBox_inner.TextXAlignment = Enum.TextXAlignment.Center
    rgbaBox_inner.TextYAlignment = Enum.TextYAlignment.Center
    rgbaBox_inner.ZIndex       = 502
    rgbaBox_inner.ClearTextOnFocus = false
    rgbaBox_inner.Text         = ""

    -- Alias so updateAll can write to it
    local rgbaLbl = rgbaBox_inner

    -- GuiInset: GetMouseLocation() is screen-space, AbsolutePosition is viewport-space
    local _guiInsetY = game:GetService("GuiService"):GetGuiInset().Y
    local _TS        = game:GetService("TweenService")
    local _tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear)

    local function getMousePos()
        local mp = _UIS:GetMouseLocation()
        return Vector2.new(mp.X, mp.Y - _guiInsetY)
    end

    -- Tween a cursor to a position, exactly like millenium does it
    local function tweenCursor(cursor, targetPos)
        _TS:Create(cursor, _tweenInfo, { Position = targetPos }):Play()
    end

    -- ── Internal update ────────────────────────────────────────────
    local function updateAll()
        local color = Color3.fromHSV(h, s, v)

        swatchBtn.BackgroundColor3 = color
        svHolder.BackgroundColor3  = Color3.fromHSV(h, 1, 1)
        svCursor.BackgroundColor3  = color

        -- SV cursor: AnchorPoint=0.5,0.5; clamp so cursor never overflows the square
        local sw  = svHolder.AbsoluteSize.X
        local sh  = svHolder.AbsoluteSize.Y
        local scw = svCursor.AbsoluteSize.X
        local sch = svCursor.AbsoluteSize.Y
        tweenCursor(svCursor, UDim2.fromOffset(
            scw/2 + s * (sw - scw),
            sch/2 + (1 - v) * (sh - sch)
        ))

        -- Hue cursor: AnchorPoint=0.5,0.5; clamp so cursor never overflows the bar
        local hw  = hueBar.AbsoluteSize.X
        local hcw = hueCursor.AbsoluteSize.X
        tweenCursor(hueCursor, UDim2.new(0, hcw/2 + h * (hw - hcw), 0.5, 0))
        hueCursor.BackgroundColor3 = Color3.fromHSV(h, 1, 1)

        -- Alpha cursor: a=0=opaque at far right, a=1=transparent at far left
        -- AnchorPoint=(0,0.5): position offset = a * (barWidth - cursorWidth)
        local aw  = alphaBack.AbsoluteSize.X
        local cw  = alphaCursor.AbsoluteSize.X
        tweenCursor(alphaCursor, UDim2.new(0, math.clamp((aw - cw) * (1 - a), 0, aw - cw), 0.5, 0))
        alphaCursor.BackgroundColor3 = Color3.fromHSV(h, 1, 1 - a)

        -- Alpha gradient: grey (left/transparent) -> current hue (right/opaque)
        alphaGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(112, 112, 112)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1))
        }

        -- RGBA text: display (1-a) for opacity so right cursor = 1, left = 0
        rgbaLbl.Text = string.format("%d, %d, %d, %s",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5),
            string.format("%.2f", 1 - a):gsub("%.?0+$", "")
        )

        if onChange then pcall(onChange, color) end
        pcall(_scheduleSave)
    end

    -- Snap all cursors instantly (no tween) — used on popup open
    local function snapCursors()
        local sw = svHolder.AbsoluteSize.X
        local sh = svHolder.AbsoluteSize.Y
        local hw = hueBar.AbsoluteSize.X
        local aw = alphaBack.AbsoluteSize.X
        local scw = svCursor.AbsoluteSize.X
        local sch = svCursor.AbsoluteSize.Y
        local hcw = hueCursor.AbsoluteSize.X
        svCursor.Position    = UDim2.fromOffset(scw/2 + s*(sw-scw), sch/2 + (1-v)*(sh-sch))
        hueCursor.Position   = UDim2.new(0, hcw/2 + h*(hw-hcw), 0.5, 0)
        alphaCursor.Position = UDim2.new(0, math.clamp((aw - alphaCursor.AbsoluteSize.X) * (1 - a), 0, aw - alphaCursor.AbsoluteSize.X), 0.5, 0)
    end

    -- ── Drag state ─────────────────────────────────────────────────
    local dragSV    = false
    local dragHue   = false
    local dragAlpha = false

    svBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragSV = true
        local offset = getMousePos()
        s = math.clamp((offset - svHolder.AbsolutePosition).X / svHolder.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp((offset - svHolder.AbsolutePosition).Y / svHolder.AbsoluteSize.Y, 0, 1)
        updateAll()
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragSV = false end
        end)
    end)

    hueBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragHue = true
        local offset = getMousePos()
        h = math.clamp((offset - hueBar.AbsolutePosition).X / hueBar.AbsoluteSize.X, 0, 1)
        updateAll()
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragHue = false end
        end)
    end)

    alphaBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        dragAlpha = true
        local offset = getMousePos()
        a = 1 - math.clamp((offset - alphaBack.AbsolutePosition).X / alphaBack.AbsoluteSize.X, 0, 1)
        updateAll()
        inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then dragAlpha = false end
        end)
    end)

    _UIS.InputChanged:Connect(function(inp)
        if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        if not (dragSV or dragHue or dragAlpha) then return end
        local offset = getMousePos()
        if dragSV then
            s = math.clamp((offset - svHolder.AbsolutePosition).X / svHolder.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp((offset - svHolder.AbsolutePosition).Y / svHolder.AbsoluteSize.Y, 0, 1)
        elseif dragHue then
            h = math.clamp((offset - hueBar.AbsolutePosition).X / hueBar.AbsoluteSize.X, 0, 1)
        elseif dragAlpha then
            a = 1 - math.clamp((offset - alphaBack.AbsolutePosition).X / alphaBack.AbsoluteSize.X, 0, 1)
        end
        updateAll()
    end)

    _UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragSV = false; dragHue = false; dragAlpha = false
        end
    end)

    -- ── Open / close logic ─────────────────────────────────────────
    local isOpen   = false
    local _TS_anim = game:GetService("TweenService")

    local function closePopup()
        isOpen = false
        -- Fade back in (cover the popup), then hide
        local t = _TS_anim:Create(popupFade,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 0 }
        )
        t:Play()
        t.Completed:Connect(function()
            popup.Visible = false
            popupFade.BackgroundTransparency = 1  -- reset for next open
        end)
        if _openColorPicker == popup then
            _openColorPicker = nil
        end
    end

    local function openPopup()
        -- Close any other open picker instantly
        if _openColorPicker and _openColorPicker ~= popup then
            _openColorPicker.Visible = false
        end
        _openColorPicker = popup
        isOpen = true

        -- Position popup, starting 20px above final position (millenium slide-in)
        local absPos  = swatchBtn.AbsolutePosition
        local absSize = swatchBtn.AbsoluteSize
        local sx      = _ScreenGui.AbsoluteSize.X
        local sy      = _ScreenGui.AbsoluteSize.Y

        local px = math.clamp(absPos.X - POPUP_W + absSize.X - 50, 4, sx - POPUP_W - 4)
        local py = absPos.Y + absSize.Y + 20
        if py + POPUP_H > sy - 4 then
            py = absPos.Y - POPUP_H - 4
        end

        -- Start 20px above, fade covering — matching millenium exactly
        popupFade.BackgroundTransparency = 0
        popup.Position = UDim2.fromOffset(px, py - 20)
        popup.Visible  = true

        -- Slide down 20px (Quint InOut 0.25s) — millenium default tween
        _TS_anim:Create(popup,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
            { Position = UDim2.fromOffset(px, py) }
        ):Play()

        -- Fade reveal (Quad InOut 0.4s) — millenium colorpicker_fade tween
        _TS_anim:Create(popupFade,
            TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
            { BackgroundTransparency = 1 }
        ):Play()

        -- Snap cursors then update after a frame so AbsoluteSize is valid
        task.defer(function()
            snapCursors()
            updateAll()
        end)
    end

    swatchBtn.MouseButton1Click:Connect(function()
        if isOpen then closePopup() else openPopup() end
    end)

    -- RGBA input: FocusLost parses "R, G, B, A" and updates color (millenium pattern)
    rgbaBox_inner.Focused:Connect(function()
        _TS:Create(rgbaBox_inner,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
            { TextColor3 = Color3.new(1, 1, 1) }
        ):Play()
    end)

    rgbaBox_inner.FocusLost:Connect(function()
        _TS:Create(rgbaBox_inner,
            TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
            { TextColor3 = _cfg.Muted }
        ):Play()
        -- Parse "R, G, B, A" — same logic as millenium's library:convert
        local values = {}
        for val in rgbaBox_inner.Text:gmatch("[^,]+") do
            table.insert(values, tonumber(val))
        end
        if #values == 4 and values[1] and values[2] and values[3] and values[4] then
            local r, g, b, alpha = values[1], values[2], values[3], values[4]
            r = math.clamp(r, 0, 255)
            g = math.clamp(g, 0, 255)
            b = math.clamp(b, 0, 255)
            alpha = math.clamp(alpha, 0, 1)
            h, s, v = Color3.fromRGB(r, g, b):ToHSV()
            a = alpha
            updateAll()  -- tweenCursor inside updateAll animates cursors smoothly
        else
            -- Restore the current valid text if input was invalid
            updateAll()
        end
    end)

    -- Click-outside to close
    _UIS.InputBegan:Connect(function(inp, gp)
        if gp then return end
        if not isOpen then return end
        if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        local mp = _UIS:GetMouseLocation()
        -- Check if click is inside popup
        local pp = popup.AbsolutePosition
        local ps = popup.AbsoluteSize
        if mp.X >= pp.X and mp.X <= pp.X + ps.X and
           mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y then
            return
        end
        -- Check if click is on the swatch itself (handled by MouseButton1Click)
        local sp = swatchBtn.AbsolutePosition
        local ss = swatchBtn.AbsoluteSize
        if mp.X >= sp.X and mp.X <= sp.X + ss.X and
           mp.Y >= sp.Y and mp.Y <= sp.Y + ss.Y then
            return
        end
        closePopup()
    end)

    -- Initial sync
    h, s, v = initColor:ToHSV()
    task.defer(function() snapCursors(); updateAll() end)

    return {
        SetColor = function(c3)
            h, s, v = c3:ToHSV()
            swatchBtn.BackgroundColor3 = c3
        end
    }
end


-- ════════════════════════════════════════════════════════════════════
-- SECTION A12 · LOADING SCREEN
-- Standalone animated loading overlay.
-- ════════════════════════════════════════════════════════════════════

---@param playerGui    Instance   e.g. LocalPlayer:FindFirstChildOfClass("PlayerGui")
---@param title        string
---@param subtitle     string
---@param tips         string[]
---@param onComplete   function|nil  called when loading finishes
function UILib.showLoadingScreen(playerGui, title, subtitle, tips, onComplete)
    local loadGui                  = Instance.new("ScreenGui")
    loadGui.Name = "MP_Loading"
    loadGui.Name                   = "MP_Loading"
    loadGui.DisplayOrder           = 9999
    loadGui.ResetOnSpawn           = false
    loadGui.IgnoreGuiInset         = true
    loadGui.Parent                 = playerGui

    local overlay                  = Instance.new("Frame", loadGui)
    overlay.Name = "Overlay"
    overlay.Size                   = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3       = Color3.fromRGB(8, 9, 14)
    overlay.BackgroundTransparency = 0
    overlay.BorderSizePixel        = 0

    local logo                     = Instance.new("TextLabel", overlay)
    logo.Name = "LogoText"
    logo.Size                      = UDim2.new(0, 400, 0, 60)
    logo.Position                  = UDim2.new(0.5, -200, 0.38, 0)
    logo.BackgroundTransparency    = 1
    logo.Font                      = Enum.Font.GothamBold
    logo.TextSize                  = 40
    logo.TextColor3                = Color3.fromRGB(0, 220, 100)
    logo.Text                      = title

    local sub                      = Instance.new("TextLabel", overlay)
    sub.Name = "Subtitle"
    sub.Size                       = UDim2.new(0, 400, 0, 28)
    sub.Position                   = UDim2.new(0.5, -200, 0.50, 0)
    sub.BackgroundTransparency     = 1
    sub.Font                       = Enum.Font.Gotham
    sub.TextSize                   = 15
    sub.TextColor3                 = Color3.fromRGB(100, 108, 140)
    sub.Text                       = subtitle

    local barTrack                 = Instance.new("Frame", overlay)
    barTrack.Name = "ProgressTrack"
    barTrack.Size                  = UDim2.new(0, 320, 0, 4)
    barTrack.Position              = UDim2.new(0.5, -160, 0.58, 0)
    barTrack.BackgroundColor3      = Color3.fromRGB(30, 32, 45)
    barTrack.BorderSizePixel       = 0
    UILib.addCorner(barTrack, 999)

    local barFill                  = Instance.new("Frame", barTrack)
    barFill.Name = "ProgressFill"
    barFill.Size                   = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3       = Color3.fromRGB(0, 220, 100)
    barFill.BorderSizePixel        = 0
    UILib.addCorner(barFill, 999)

    local loadTip                  = Instance.new("TextLabel", overlay)
    loadTip.Name = "LoadTip"
    loadTip.Size                   = UDim2.new(0, 500, 0, 24)
    loadTip.Position               = UDim2.new(0.5, -250, 0.65, 0)
    loadTip.BackgroundTransparency = 1
    loadTip.Font                   = Enum.Font.Gotham
    loadTip.TextSize               = 13
    loadTip.TextColor3             = Color3.fromRGB(140, 148, 180)
    loadTip.TextWrapped            = true
    loadTip.Text                   = (tips and tips[1]) or ""

    task.spawn(function()
        local steps  = 40
        local tipIdx = 1
        for i = 1, steps do
            barFill.Size = UDim2.new(i / steps, 0, 1, 0)
            if tips and i % 8 == 0 then
                tipIdx = (tipIdx % #tips) + 1
                loadTip.Text = tips[tipIdx]
            end
            task.wait(0.04)
        end
        sub.Text = "Ready."
        task.wait(0.4)
        for t = 0, 1, 0.05 do
            overlay.BackgroundTransparency = t
            logo.TextTransparency          = t
            sub.TextTransparency           = t
            loadTip.TextTransparency       = t
            barTrack.BackgroundTransparency = t
            barFill.BackgroundTransparency  = t
            task.wait(0.03)
        end
        loadGui:Destroy()
        if onComplete then onComplete() end
    end)
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A13 · TIP TICKER
-- Small rotating tip strip at the bottom-right corner.
-- ════════════════════════════════════════════════════════════════════

---@param playerGui  Instance
---@param tips       string[]
---@param getCfgEnabled function -> boolean  (controls visibility)
---@return Frame (the ticker frame, so you can hide it)
function UILib.createTipTicker(playerGui, tips, getCfgEnabled)
    local tipGui              = Instance.new("ScreenGui")
    tipGui.Name = "MP_TipTicker"
    tipGui.Name               = "MP_TipTicker"
    tipGui.DisplayOrder       = 5
    tipGui.ResetOnSpawn       = false
    tipGui.IgnoreGuiInset     = true
    tipGui.Parent             = playerGui

    local tipFrame            = Instance.new("Frame", tipGui)
    tipFrame.Name = "TipFrame"
    tipFrame.Size             = UDim2.new(0, 320, 0, 36)
    tipFrame.Position         = UDim2.new(1, -330, 1, -46)
    tipFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    tipFrame.BackgroundTransparency = 0.25
    tipFrame.BorderSizePixel  = 0
    UILib.addCorner(tipFrame, 8)

    local tipStroke           = Instance.new("UIStroke", tipFrame)
    tipStroke.Name = "Stroke"
    tipStroke.Color           = Color3.fromRGB(0, 180, 70)
    tipStroke.Thickness       = 1
    tipStroke.Transparency    = 0.5

    local tipLabel            = Instance.new("TextLabel", tipFrame)
    tipLabel.Name = "TipLabel"
    tipLabel.Size             = UDim2.new(1, -12, 1, 0)
    tipLabel.Position         = UDim2.fromOffset(6, 0)
    tipLabel.BackgroundTransparency = 1
    tipLabel.Font             = Enum.Font.Gotham
    tipLabel.TextSize         = 11
    tipLabel.TextColor3       = Color3.fromRGB(140, 148, 180)
    tipLabel.TextXAlignment   = Enum.TextXAlignment.Left
    tipLabel.TextTruncate     = Enum.TextTruncate.AtEnd
    tipLabel.Text             = (tips and tips[1]) or ""

    task.spawn(function()
        local idx = 1
        while tipGui and tipGui.Parent do
            task.wait(8)
            local enabled = getCfgEnabled and getCfgEnabled() or true
            if not enabled then
                tipFrame.Visible = false
            else
                tipFrame.Visible = true
                idx = (idx % #tips) + 1
                for t = 0, 1, 0.1 do tipLabel.TextTransparency = t; task.wait(0.03) end
                tipLabel.Text = tips[idx]
                for t = 1, 0, -0.1 do tipLabel.TextTransparency = t; task.wait(0.03) end
            end
        end
    end)

    return tipFrame
end

return UILib
