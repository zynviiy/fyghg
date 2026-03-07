--[[
    ╔══════════════════════════════════════════════════════════════════╗
    ║                     Massacreme  UILib v1.0                       ║
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
    return UILib
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

--- Create a TextLabel with transparent background
---@param parent   Instance
---@param text     string
---@param font     Enum.Font|nil
---@param size     number|nil
---@param color    Color3|nil
---@param xAlign   Enum.TextXAlignment|nil
function UILib.newLabel(parent, text, font, size, color, xAlign)
    local l                  = Instance.new("TextLabel")
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
    f.BackgroundTransparency = 1
    f.Size                   = UDim2.new(1, 0, 0, 26)
    f.Parent                 = _content

    local line            = Instance.new("Frame")
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
function UILib.rowFrame(height)
    local r            = Instance.new("Frame")
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
    btn.AutoButtonColor = false
    btn.Size            = UDim2.fromOffset(72, 26)
    btn.Position        = UDim2.new(1, -82, 0.5, -13)
    btn.BorderSizePixel = 0
    btn.Font            = Enum.Font.GothamBold
    btn.TextSize        = 12
    btn.Parent          = parent
    UILib.addCorner(btn, 999)

    -- initial can be a boolean OR a getter function () -> boolean
    -- If a getter is provided, clicks always read the live value from it first
    local getter = type(initial) == "function" and initial or nil
    local state  = getter and (getter() and true or false) or (initial and true or false)
    local function sync()
        btn.Text             = state and "ON  " or "OFF  "
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 195, 85) or Color3.fromRGB(55, 58, 78)
        btn.TextColor3       = state and Color3.fromRGB(5, 25, 10)  or _cfg.Muted
    end
    sync()

    btn.MouseButton1Click:Connect(function()
        -- always read the live source of truth before toggling
        if getter then state = getter() end
        state = not state
        sync()
        if onChanged then onChanged(state) end
        pcall(_scheduleSave)
    end)

    -- syncFn: call externally to force-set the visual state
    return btn, function(v) state = not not v; sync() end
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A5 · TOOLTIP
-- Floating tooltip that follows the mouse.
-- ════════════════════════════════════════════════════════════════════

local function _ensureTooltip()
    if _tooltipFrame then return end
    _tooltipFrame = Instance.new("Frame")
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
    pad.PaddingLeft   = UDim.new(0, 8)
    pad.PaddingRight  = UDim.new(0, 8)
    pad.PaddingTop    = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 6)
    _tooltipLabel = Instance.new("TextLabel", _tooltipFrame)
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
    local r   = UILib.rowFrame(40)
    local lbl = UILib.rowLabel(r, text)
    local btn, sync = UILib.togglePill(r, init, function(v)
        onChange(v)
        pcall(_scheduleSave)
    end)
    if tooltip and tooltip ~= "" then
        UILib.attachTooltip(r, tooltip)
        lbl.Text       = text .. "  (i)"
        lbl.TextColor3 = _cfg.Muted
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
    local wrap            = Instance.new("Frame")
    wrap.BackgroundColor3 = _cfg.BG2
    wrap.BorderSizePixel  = 0
    wrap.Size             = UDim2.new(1, 0, 0, 58)
    wrap.Parent           = _content
    UILib.addCorner(wrap, 8)
    UILib.addStroke(wrap, 1, _cfg.Stroke, 0.5)

    local top                  = Instance.new("Frame")
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
    track.Size             = UDim2.new(1, -24, 0, 10)
    track.Position         = UDim2.new(0, 12, 0, 38)
    track.BackgroundColor3 = _cfg.BG3
    track.BorderSizePixel  = 0
    track.Parent           = wrap
    UILib.addCorner(track, 999)
    UILib.addStroke(track, 1, _cfg.Stroke, 0.6)

    local fill            = Instance.new("Frame")
    fill.Size             = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = _cfg.Accent
    fill.BorderSizePixel  = 0
    fill.Parent           = track
    UILib.addCorner(fill, 999)

    local knob              = Instance.new("Frame")
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

    local function fmt(v)
        if decimals and decimals > 0 then
            return string.format("%." .. decimals .. "f", v)
        end
        return tostring(math.floor(v + 0.5))
    end

    local function setVal(v)
        cur           = UILib.clamp(v, minV, maxV)
        local a       = (cur - minV) / (maxV - minV)
        fill.Size     = UDim2.new(a, 0, 1, 0)
        knob.Position = UDim2.new(a, 0, 0.5, 0)
        valLbl.Text   = fmt(cur)
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
    b.AutoButtonColor  = false
    b.Size             = UDim2.fromOffset(width or 80, 26)
    b.Position         = posOverride or UDim2.new(1, -(width or 80) - 6, 0.5, -13)
    b.BackgroundColor3 = _cfg.BG3
    b.TextColor3       = _cfg.Text
    b.Font             = Enum.Font.GothamSemibold
    b.TextSize         = 12
    b.Text             = text
    b.BorderSizePixel  = 0
    b.Parent           = parent
    UILib.addCorner(b, 8)
    UILib.addStroke(b, 1, _cfg.Accent, 0.4)
    b.MouseEnter:Connect(function()  b.BackgroundColor3 = _cfg.AccentDim end)
    b.MouseLeave:Connect(function()  b.BackgroundColor3 = _cfg.BG3       end)
    b.MouseButton1Click:Connect(function() if onClick then onClick() end end)
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
function UILib.keybindToggleRow(title, getKey, setKey, getToggle, setToggle, onToggle)
    local r       = UILib.rowFrame(40)
    UILib.rowLabel(r, title)
    local keyLbl  = UILib.keyChip(r, getKey().Name, -248)
    UILib.actionBtn(r, "Set Key", 68, UDim2.new(1, -172, 0.5, -13), function()
        _keyCapture.active = true
        _keyCapture.action = title
        _keyCapture.label  = keyLbl
        keyLbl.Text        = "..."
    end)
    local _, sync = UILib.togglePill(r, getToggle, function(v)
        setToggle(v)
        if onToggle then onToggle(v) end
    end)
    return { KeyLabel = keyLbl, SyncToggle = sync }
end

--- Row with just a keybind chip + Set Key button
---@param title  string
---@param getKey function -> Enum.KeyCode
---@return TextLabel  (the key chip label)
function UILib.keybindRow(title, getKey)
    local r      = UILib.rowFrame(40)
    UILib.rowLabel(r, title)
    local keyLbl = UILib.keyChip(r, getKey().Name, -168)
    UILib.actionBtn(r, "Set Key", 68, UDim2.new(1, -82, 0.5, -13), function()
        _keyCapture.active = true
        _keyCapture.action = title
        _keyCapture.label  = keyLbl
        keyLbl.Text        = "..."
    end)
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
    local tabBtns = {}

    local function activateTab(name)
        for t, btn in pairs(tabBtns) do
            local on = (t == name)
            btn.BackgroundColor3 = on and Color3.fromRGB(18, 20, 28) or _cfg.BG3
            btn.TextColor3       = on and _cfg.Accent               or _cfg.Muted
            local s = btn:FindFirstChildOfClass("UIStroke")
            if s then s:Destroy() end
            if on then UILib.addStroke(btn, 1.5, _cfg.Accent, 0.15) end
        end
    end

    for i, def in ipairs(tabDefs) do
        local name, fn = def[1], def[2]
        local b            = Instance.new("TextButton")
        b.AutoButtonColor  = false
        b.BackgroundColor3 = _cfg.BG3
        b.BorderSizePixel  = 0
        b.Font             = Enum.Font.GothamSemibold
        b.TextSize         = 13
        b.TextColor3       = _cfg.Muted
        b.Text             = name
        b.Size             = UDim2.fromOffset(96, 30)
        b.LayoutOrder      = i
        b.Parent           = tabScroller
        UILib.addCorner(b, 8)
        tabBtns[name] = b

        b.MouseButton1Click:Connect(function()
            activateTab(name)
            if onActivate then onActivate(name, fn) end
            fn()
        end)
    end

    return tabBtns, activateTab
end

-- ════════════════════════════════════════════════════════════════════
-- SECTION A8 · GLOBAL FEATURE SEARCH
-- Floating search bar that jumps to sections by keyword.
-- ════════════════════════════════════════════════════════════════════

---@param main        Frame             the main panel Frame
---@param TAB_SECTIONS table<string, string[]>  tab name -> section names
---@param renderMap   table<string, function>   tab name -> render function
---@param activateTabFn function(name)
function UILib.buildSearchBar(main, TAB_SECTIONS, renderMap, activateTabFn)
    local SEARCH_INDEX = {}
    for tab, sections in pairs(TAB_SECTIONS) do
        for _, sec in ipairs(sections) do
            table.insert(SEARCH_INDEX, { text = sec, tab = tab, keyword = sec:lower() })
        end
    end

    -- Frame
    local sbFrame = Instance.new("Frame", main)
    sbFrame.Size             = UDim2.fromOffset(168, 28)
    sbFrame.Position         = UDim2.new(1, -178, 0, 5)
    sbFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 38)
    sbFrame.BorderSizePixel  = 0
    UILib.addCorner(sbFrame, 8)
    UILib.addStroke(sbFrame, 1, _cfg.Accent, 0.5)

    local sbIcon = Instance.new("TextLabel", sbFrame)
    sbIcon.Size                 = UDim2.fromOffset(24, 28)
    sbIcon.BackgroundTransparency = 1
    sbIcon.Text                 = "S"
    sbIcon.Font                 = Enum.Font.GothamBold
    sbIcon.TextSize             = 14
    sbIcon.TextColor3           = _cfg.Accent
    sbIcon.BorderSizePixel      = 0

    local sbBox = Instance.new("TextBox", sbFrame)
    sbBox.Size                  = UDim2.new(1, -28, 1, 0)
    sbBox.Position              = UDim2.fromOffset(24, 0)
    sbBox.BackgroundTransparency = 1
    sbBox.Text                  = ""
    sbBox.PlaceholderText       = "Search features..."
    sbBox.Font                  = Enum.Font.GothamSemibold
    sbBox.TextSize              = 12
    sbBox.ClearTextOnFocus      = false
    sbBox.TextColor3            = _cfg.Text
    sbBox.PlaceholderColor3     = _cfg.Muted
    sbBox.BorderSizePixel       = 0
    sbBox.TextXAlignment        = Enum.TextXAlignment.Left

    -- Dropdown
    local sbDropdown = Instance.new("Frame", _ScreenGui)
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
        sbDropdown.Position = UDim2.fromOffset(abs.X, abs.Y + sz.Y + 4)
    end
    sbFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateDropdownPos)
    sbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        sbDropdown.Size = UDim2.fromOffset(200, math.min(sbLayout.AbsoluteContentSize.Y + 8, 180))
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
        for _, entry in ipairs(SEARCH_INDEX) do
            if entry.keyword:find(q, 1, true) then table.insert(matches, entry) end
        end
        if #matches == 0 then
            local noLbl = Instance.new("TextLabel", sbDropdown)
            noLbl.Size                 = UDim2.new(1, 0, 0, 28)
            noLbl.BackgroundTransparency = 1
            noLbl.Text                 = 'No results for "' .. query .. '"'
            noLbl.Font                 = Enum.Font.Gotham
            noLbl.TextSize             = 11
            noLbl.TextColor3           = _cfg.Muted
            noLbl.BorderSizePixel      = 0
            noLbl.ZIndex               = 51
            sbDropdown.Visible = true
            return
        end
        for _, entry in ipairs(matches) do
            local btn = Instance.new("TextButton", sbDropdown)
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
                activateTabFn(cap.tab)
                local fn = renderMap[cap.tab]
                if fn then fn() end
                -- Scroll to matching section heading
                task.wait(0.05)
                local targetText = cap.text:upper()
                for _, child in ipairs(_content:GetChildren()) do
                    if child:IsA("Frame") then
                        local lbl = child:FindFirstChildOfClass("TextLabel")
                        if lbl and lbl.Text == targetText then
                            local targetY = child.AbsolutePosition.Y
                                          - _content.AbsolutePosition.Y
                                          + _content.CanvasPosition.Y
                            _content.CanvasPosition = Vector2.new(0, math.max(0, targetY - 8))
                            break
                        end
                    end
                end
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

--- Wire up drag behaviour on `window` using `handle` as the drag target.
---@param window Frame
---@param handle GuiObject
function UILib.makeDraggable(window, handle)
    local dragging, dragStart, startPos, dragInput = false, nil, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            dragStart = inp.Position
            startPos  = window.Position
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseMovement then dragInput = inp end
    end)
    _UIS.InputChanged:Connect(function(inp)
        if dragging and inp == dragInput then
            local d = inp.Position - dragStart
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
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
function UILib.createColorRow(labelText, initColor, onChange)
    local wrap            = Instance.new("Frame")
    wrap.BackgroundColor3 = _cfg.BG2
    wrap.BorderSizePixel  = 0
    wrap.Size             = UDim2.new(1, 0, 0, 98)
    wrap.Parent           = _content
    UILib.addCorner(wrap, 8)
    UILib.addStroke(wrap, 1, _cfg.Stroke, 0.5)

    local lbl = UILib.newLabel(wrap, labelText, Enum.Font.GothamSemibold, 13, _cfg.Muted)
    lbl.Size  = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.fromOffset(12, 6)

    local preview            = Instance.new("Frame", wrap)
    preview.Size             = UDim2.fromOffset(28, 28)
    preview.Position         = UDim2.new(1, -42, 0, 4)
    preview.BackgroundColor3 = initColor
    preview.BorderSizePixel  = 0
    UILib.addCorner(preview, 6)
    UILib.addStroke(preview, 1, _cfg.Stroke, 0.3)

    local cur = { R = initColor.R, G = initColor.G, B = initColor.B }

    local function makeChannel(label, yOff, getV, setV)
        local row                  = Instance.new("Frame", wrap)
        row.BackgroundTransparency = 1
        row.Size                   = UDim2.new(1, -16, 0, 20)
        row.Position               = UDim2.fromOffset(8, yOff)

        local cLbl = UILib.newLabel(row, label, Enum.Font.GothamSemibold, 11, _cfg.Muted)
        cLbl.Size  = UDim2.fromOffset(16, 20)

        local track            = Instance.new("Frame", row)
        track.Size             = UDim2.new(1, -60, 0, 8)
        track.Position         = UDim2.fromOffset(18, 6)
        track.BackgroundColor3 = _cfg.BG3
        track.BorderSizePixel  = 0
        UILib.addCorner(track, 999)

        local fill            = Instance.new("Frame", track)
        fill.Size             = UDim2.new(getV(), 0, 1, 0)
        fill.BackgroundColor3 = _cfg.Accent
        fill.BorderSizePixel  = 0
        UILib.addCorner(fill, 999)

        local valLbl = UILib.newLabel(row, math.floor(getV() * 255) .. "", Enum.Font.GothamBold, 11, _cfg.Text, Enum.TextXAlignment.Right)
        valLbl.Size  = UDim2.fromOffset(36, 20)
        valLbl.Position = UDim2.new(1, -36, 0, 0)

        local dragging = false
        local function fromX(x)
            local rel = UILib.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
            local v   = rel / track.AbsoluteSize.X
            setV(v)
            fill.Size    = UDim2.new(v, 0, 1, 0)
            valLbl.Text  = math.floor(v * 255) .. ""
            preview.BackgroundColor3 = Color3.new(cur.R, cur.G, cur.B)
            if onChange then onChange(Color3.new(cur.R, cur.G, cur.B)) end
            pcall(_scheduleSave)
        end
        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; fromX(inp.Position.X) end
        end)
        track.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        _UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then fromX(inp.Position.X) end
        end)
    end

    makeChannel("R", 28, function() return cur.R end, function(v) cur.R = v end)
    makeChannel("G", 50, function() return cur.G end, function(v) cur.G = v end)
    makeChannel("B", 72, function() return cur.B end, function(v) cur.B = v end)

    return {
        SetColor = function(c3)
            cur.R = c3.R; cur.G = c3.G; cur.B = c3.B
            preview.BackgroundColor3 = c3
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
    loadGui.Name                   = "MP_Loading"
    loadGui.DisplayOrder           = 9999
    loadGui.ResetOnSpawn           = false
    loadGui.IgnoreGuiInset         = true
    loadGui.Parent                 = playerGui

    local overlay                  = Instance.new("Frame", loadGui)
    overlay.Size                   = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3       = Color3.fromRGB(8, 9, 14)
    overlay.BackgroundTransparency = 0
    overlay.BorderSizePixel        = 0

    local logo                     = Instance.new("TextLabel", overlay)
    logo.Size                      = UDim2.new(0, 400, 0, 60)
    logo.Position                  = UDim2.new(0.5, -200, 0.38, 0)
    logo.BackgroundTransparency    = 1
    logo.Font                      = Enum.Font.GothamBold
    logo.TextSize                  = 40
    logo.TextColor3                = Color3.fromRGB(0, 220, 100)
    logo.Text                      = title

    local sub                      = Instance.new("TextLabel", overlay)
    sub.Size                       = UDim2.new(0, 400, 0, 28)
    sub.Position                   = UDim2.new(0.5, -200, 0.50, 0)
    sub.BackgroundTransparency     = 1
    sub.Font                       = Enum.Font.Gotham
    sub.TextSize                   = 15
    sub.TextColor3                 = Color3.fromRGB(100, 108, 140)
    sub.Text                       = subtitle

    local barTrack                 = Instance.new("Frame", overlay)
    barTrack.Size                  = UDim2.new(0, 320, 0, 4)
    barTrack.Position              = UDim2.new(0.5, -160, 0.58, 0)
    barTrack.BackgroundColor3      = Color3.fromRGB(30, 32, 45)
    barTrack.BorderSizePixel       = 0
    Instance.new("UICorner", barTrack).CornerRadius = UDim.new(0, 999)

    local barFill                  = Instance.new("Frame", barTrack)
    barFill.Size                   = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3       = Color3.fromRGB(0, 220, 100)
    barFill.BorderSizePixel        = 0
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(0, 999)

    local loadTip                  = Instance.new("TextLabel", overlay)
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
    tipGui.Name               = "MP_TipTicker"
    tipGui.DisplayOrder       = 5
    tipGui.ResetOnSpawn       = false
    tipGui.IgnoreGuiInset     = true
    tipGui.Parent             = playerGui

    local tipFrame            = Instance.new("Frame", tipGui)
    tipFrame.Size             = UDim2.new(0, 320, 0, 36)
    tipFrame.Position         = UDim2.new(1, -330, 1, -46)
    tipFrame.BackgroundColor3 = Color3.fromRGB(10, 11, 16)
    tipFrame.BackgroundTransparency = 0.25
    tipFrame.BorderSizePixel  = 0
    Instance.new("UICorner", tipFrame).CornerRadius = UDim.new(0, 8)

    local tipStroke           = Instance.new("UIStroke", tipFrame)
    tipStroke.Color           = Color3.fromRGB(0, 180, 70)
    tipStroke.Thickness       = 1
    tipStroke.Transparency    = 0.5

    local tipLabel            = Instance.new("TextLabel", tipFrame)
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
