-- ════════════════════════════════════════════════════════════════
-- UILib V5  —  Attach Hub UI Framework
-- Usage:  local UILib = loadstring(...)()
--         local win   = UILib.new({ title="Attach Hub", credits="by vqv" })
--         local tab   = win:AddTab({ label="Attach", color=Color3.fromRGB(255,210,0), icon="≡" })
--         local sec   = tab:AddSection("Position", "rbxassetid://71917905228308")
--         local sl    = sec:AddSlider({ label="X", min=-10, max=10, default=0, color=Color3.fromRGB(255,210,0), onChange=function(v) end })
--         local btn   = sec:AddButton({ label="Attach", icon="rbxassetid://...", color=Color3.fromRGB(255,210,0), onClick=function() end })
--         local sel   = sec:AddSelector({ options={"A","B"}, default=1, onChange=function(opt,idx) end })
--         sl:SetValue(5)   -- programmatically move slider
-- ════════════════════════════════════════════════════════════════

local UILib = {}
UILib.__index = UILib

-- ── Services ──────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")

-- ── Fonts ─────────────────────────────────────────────────────
local FONT_BOLD    = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold,    Enum.FontStyle.Normal)
local FONT_REG     = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular,  Enum.FontStyle.Normal)
local FONT_SRC     = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

-- ── Layout constants ──────────────────────────────────────────
local PAD_X        = 15   -- horizontal inset from page edges
local SLIDER_H     = 5    -- slider track height
local SLIDER_BTN_W = 2    -- thumb width
local SLIDER_BTN_H = 10   -- thumb overhang (each side)
local BOX_W        = 40   -- value textbox width
local BOX_H        = 20
local LABEL_W      = 30   -- axis label width
local LABEL_OFFSET = -5   -- label X offset from track left
local BTN_H        = 25   -- action button height
local SEL_H        = 30   -- selector row height
local SUBTITLE_H   = 20   -- section title height
local GAP_AFTER_SUBTITLE = 10  -- gap between subtitle bottom and first element
local GAP_BETWEEN        = 20  -- gap between consecutive elements
local GAP_AFTER_SECTION  = 15  -- extra gap before next section subtitle

-- ── Helpers ───────────────────────────────────────────────────
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(radius or 0, 0)
    c.Parent = parent
    return c
end

local function px(parent, radius)
    corner(parent, 0)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function icon(parent, img, sz)
    local il = Instance.new("ImageLabel")
    il.Image = img
    il.BackgroundTransparency = 1
    il.BorderSizePixel = 0
    il.Size = UDim2.new(0, sz or 20, 0, sz or 20)
    il.Parent = parent
    return il
end

local function hlist(parent, padding)
    local l = Instance.new("UIListLayout")
    l.FillDirection   = Enum.FillDirection.Horizontal
    l.VerticalAlignment  = Enum.VerticalAlignment.Center
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.Padding   = UDim.new(0, padding or 5)
    l.Parent    = parent
    return l
end

local function makeDrag(obj)
    task.spawn(function()
        local dragging, dragStart, startPos
        obj.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging  = true
                dragStart = inp.Position
                startPos  = obj.Position
                local conn; conn = inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragging = false; conn:Disconnect()
                    end
                end)
            end
        end)
        local dragInput
        obj.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragInput = inp
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging then
                local delta = inp.Position - dragStart
                TweenService:Create(obj, TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
                    { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                           startPos.Y.Scale, startPos.Y.Offset + delta.Y) }):Play()
            end
        end)
    end)
end

-- ════════════════════════════════════════════════════════════════
-- Window
-- ════════════════════════════════════════════════════════════════
function UILib.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, UILib)
    self._tabs      = {}
    self._pages     = {}
    self._tabBtns   = {}   -- mini ≡ tab buttons in Window header
    self._activeTab = 0

    local CoreGui = (pcall(function() return gethui() end) and gethui()) or game:GetService("CoreGui")

    -- ScreenGui
    local sg = Instance.new("ScreenGui")
    sg.Name = cfg.name or "AttachHubUI"
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui
    self.ScreenGui = sg

    local root = Instance.new("Frame")
    root.BackgroundTransparency = 1
    root.Size = UDim2.new(1,0,1,0)
    root.Parent = sg

    -- Main window frame
    local win = Instance.new("Frame")
    win.Name = "UIContainer"
    win.AnchorPoint = Vector2.new(0.5,0.5)
    win.Position    = UDim2.new(0.5,0,0.5,0)
    win.Size        = UDim2.new(0,500,0,400)
    win.BackgroundColor3 = Color3.fromRGB(17,20,27)
    win.BackgroundTransparency = 0.25
    win.BorderSizePixel = 0
    win.Parent = root
    corner(win, 0.075)
    self.WinFrame = win
    makeDrag(win)

    -- Left panel (player list host — kept as-is, script fills it)
    local left = Instance.new("Frame")
    left.Name = "LeftContainer"
    left.Size = UDim2.new(0,200,1,0)
    left.BackgroundTransparency = 1
    left.BorderSizePixel = 0
    left.Parent = win
    self.LeftContainer = left

    -- Right panel
    local right = Instance.new("Frame")
    right.Name = "RightContainer"
    right.AnchorPoint = Vector2.new(1,0)
    right.Position = UDim2.new(1,0,0,0)
    right.Size = UDim2.new(0,300,1,0)
    right.BackgroundTransparency = 1
    right.BorderSizePixel = 0
    right.Parent = win
    self.RightContainer = right

    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Text = ""
    closeBtn.AnchorPoint = Vector2.new(1,0)
    closeBtn.Position = UDim2.new(1,-15,0,15)
    closeBtn.Size = UDim2.new(0,30,0,30)
    closeBtn.BackgroundTransparency = 1
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.FontFace = FONT_SRC
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = Color3.fromRGB(0,0,0)
    closeBtn.Parent = right
    corner(closeBtn, 0.25)
    icon(closeBtn, "rbxassetid://110786993356448", 16).AnchorPoint = Vector2.new(0.5,0.5)
    local ci = closeBtn:FindFirstChildWhichIsA("ImageLabel")
    if ci then ci.Position = UDim2.new(0.5,0,0.5,0) end
    self.CloseButton = closeBtn

    -- Minimize button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Text = ""
    minBtn.AnchorPoint = Vector2.new(1,0)
    minBtn.Position = UDim2.new(1,-50,0,15)
    minBtn.Size = UDim2.new(0,30,0,30)
    minBtn.BackgroundTransparency = 1
    minBtn.BorderSizePixel = 0
    minBtn.AutoButtonColor = false
    minBtn.FontFace = FONT_SRC
    minBtn.TextSize = 14
    minBtn.TextColor3 = Color3.fromRGB(0,0,0)
    minBtn.Parent = right
    corner(minBtn, 0.25)
    local mi = icon(minBtn, "rbxassetid://118026365011536", 16)
    mi.AnchorPoint = Vector2.new(0.5,0.5)
    mi.Position = UDim2.new(0.5,0,0.5,0)
    self.MinimizeButton = minBtn

    -- Window content area (below close/minimize)
    local windowContent = Instance.new("Frame")
    windowContent.Name = "Window"
    windowContent.Position = UDim2.new(0,0,0,50)
    windowContent.Size = UDim2.new(1,-10,1,-60)
    windowContent.BackgroundTransparency = 0.9
    windowContent.BackgroundColor3 = Color3.fromRGB(255,255,255)
    windowContent.BorderSizePixel = 0
    windowContent.Parent = right
    self.Window = windowContent

    -- Tab action-button row occupies Y=0..130 inside Window
    -- Pages (ScrollingFrames) start at Y=130

    return self
end

-- ── Close/Minimize wiring (call from main script) ──────────────
function UILib:OnClose(fn)   self.CloseButton.MouseButton1Click:Connect(fn) end
function UILib:OnMinimize(fn) self.MinimizeButton.MouseButton1Click:Connect(fn) end

function UILib:Destroy()
    self.ScreenGui:Destroy()
end

-- ════════════════════════════════════════════════════════════════
-- Tab   (a tab = an action button in the header + a page frame)
-- cfg = { label, color, icon (assetid string), tabIcon ("≡" etc.) }
-- Tabs are arranged in a 2-column grid inside Window at Y=80/105
-- Col 0 = left half, Col 1 = right half
-- ════════════════════════════════════════════════════════════════
local TAB_ROWS = {
    -- { xScale, xOff, yOff }   for up to 6 tabs (2 cols × 3 rows)
    { 0,   10,  80 }, { 0.5,  5,  80 },
    { 0,   10, 105 }, { 0.5,  5, 105 },
    { 0,   10, 130 }, { 0.5,  5, 130 },
}
local TAB_SIZES = {
    -- { wScale, wOff }
    { 0.5, -15 }, { 0.5, -38 },
    { 0.5, -15 }, { 0.5, -38 },
    { 0.5, -15 }, { 0.5, -38 },
}

function UILib:AddTab(cfg)
    cfg = cfg or {}
    local idx = #self._tabs + 1
    local pos  = TAB_ROWS[idx]  or { 0, 10, 80 }
    local siz  = TAB_SIZES[idx] or { 0.5, -15 }

    -- Action button
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_"..idx
    btn.Text = ""
    btn.AnchorPoint = Vector2.new(0,0)
    btn.Position = UDim2.new(pos[1], pos[2], 0, pos[3])
    btn.Size     = UDim2.new(siz[1], siz[2], 0, 20)
    btn.BackgroundTransparency = 0.9
    btn.BackgroundColor3 = cfg.color or Color3.fromRGB(200,200,200)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.FontFace = FONT_SRC
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.Parent = self.Window
    corner(btn, 0.2)
    hlist(btn, 5)

    if cfg.assetIcon then
        local ic = icon(btn, cfg.assetIcon, 15)
        ic.AnchorPoint = Vector2.new(0.5,0.5)
    end
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.FontFace = FONT_REG
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = cfg.label or "Tab"
    lbl.Size = UDim2.new(0, math.max(40, #(cfg.label or "Tab") * 8), 0, 20)
    lbl.Parent = btn
    self["Tab"..idx.."Label"] = lbl   -- expose for toggling text

    -- Mini ≡ tab-switcher icon to the right of the button
    -- It sits at x=(pos[1]+siz[1]), same Y
    local miniX   = pos[1] + siz[1]
    local miniXOff = pos[2] + siz[2] + 2
    local mini = Instance.new("TextButton")
    mini.Name = "MiniTab_"..idx
    mini.Text = cfg.tabIcon or "≡"
    mini.FontFace = FONT_BOLD
    mini.TextScaled = false
    mini.TextSize = 14
    mini.TextColor3 = Color3.fromRGB(255,255,255)
    mini.BorderSizePixel = 0
    mini.BackgroundColor3 = cfg.color or Color3.fromRGB(200,200,200)
    mini.BackgroundTransparency = 0.9
    mini.AutoButtonColor = false
    mini.TextXAlignment = Enum.TextXAlignment.Center
    mini.TextYAlignment = Enum.TextYAlignment.Center
    mini.Size = UDim2.new(0,20,0,20)
    mini.Position = UDim2.new(miniX, miniXOff, 0, pos[3])
    mini.Parent = self.Window
    corner(mini, 0.3)

    -- Page (ScrollingFrame)
    local page = Instance.new("ScrollingFrame")
    page.Name = "Page_"..idx
    page.Active = true
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(180,180,180)
    page.ScrollBarImageTransparency = 0.4
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Size = UDim2.new(1,0,1,-130)
    page.AnchorPoint = Vector2.new(0,0)
    page.Position = UDim2.new(0,0,0,130)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Visible = false
    page.Parent = self.Window

    -- UIListLayout drives auto-stacking inside the page
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 0)  -- sections control their own internal gaps
    layout.Parent = page

    -- Bottom padding
    local pad = Instance.new("UIPadding")
    pad.PaddingBottom = UDim.new(0,40)
    pad.PaddingLeft   = UDim.new(0, PAD_X)
    pad.PaddingRight  = UDim.new(0, PAD_X)
    pad.Parent = page

    local tabObj = {
        _win      = self,
        _page     = page,
        _btn      = btn,
        _mini     = mini,
        _miniBtn  = mini,
        _idx      = idx,
        _sections = {},
        _color    = cfg.color,
        label     = lbl,
    }
    setmetatable(tabObj, { __index = _TabMeta })

    -- Wire click → switchTab
    local function activate()
        self:_switchTab(idx)
    end
    btn.MouseButton1Click:Connect(activate)
    mini.MouseButton1Click:Connect(activate)

    self._tabs[idx]   = tabObj
    self._pages[idx]  = page
    self._tabBtns[idx] = mini

    -- Default: first tab visible
    if idx == 1 then
        self:_switchTab(1)
    end

    return tabObj
end

function UILib:_switchTab(index)
    self._activeTab = index
    for i, page in ipairs(self._pages) do
        page.Visible = (i == index)
        local mini = self._tabBtns[i]
        if mini then
            mini.BackgroundTransparency = (i == index) and 0.7 or 0.9
        end
    end
end

function UILib:SwitchTab(index)
    self:_switchTab(index)
end

-- ════════════════════════════════════════════════════════════════
-- Tab methods (Section)
-- ════════════════════════════════════════════════════════════════
_TabMeta = {}
_TabMeta.__index = _TabMeta

-- AddSection(title, iconAsset?)  → Section object
-- Sections stack vertically; each section is a Frame with its own
-- UIListLayout for its children.
function _TabMeta:AddSection(title, iconAsset)
    local page = self._page

    local secFrame = Instance.new("Frame")
    secFrame.Name = "Section_"..title
    secFrame.BackgroundTransparency = 1
    secFrame.BorderSizePixel = 0
    secFrame.AutomaticSize = Enum.AutomaticSize.Y
    secFrame.Size = UDim2.new(1, 0, 0, 0)
    secFrame.Parent = page

    -- Internal list layout
    local lay = Instance.new("UIListLayout")
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.FillDirection = Enum.FillDirection.Vertical
    lay.Padding = UDim.new(0, 0)
    lay.Parent = secFrame

    -- Section gap from previous section
    local topPad = Instance.new("Frame")
    topPad.Name = "SectionGap"
    topPad.BackgroundTransparency = 1
    topPad.BorderSizePixel = 0
    topPad.Size = UDim2.new(1, 0, 0, #self._sections == 0 and 5 or GAP_AFTER_SECTION)
    topPad.LayoutOrder = 0
    topPad.Parent = secFrame

    -- Subtitle row
    local row = Instance.new("Frame")
    row.Name = "SubtitleRow"
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, SUBTITLE_H)
    row.LayoutOrder = 1
    row.Parent = secFrame

    if iconAsset then
        local ic = icon(row, iconAsset, 20)
        ic.Position = UDim2.new(0, 0, 0, 0)
        ic.AnchorPoint = Vector2.new(0, 0)
    end
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.BorderSizePixel = 0
    titleLbl.Size = UDim2.new(1, -25, 1, 0)
    titleLbl.Position = UDim2.new(0, 25, 0, 0)
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255,255,255)
    titleLbl.FontFace = FONT_BOLD
    titleLbl.TextSize = 14
    titleLbl.TextScaled = true
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = row

    -- Gap after subtitle
    local afterSub = Instance.new("Frame")
    afterSub.Name = "AfterSubtitle"
    afterSub.BackgroundTransparency = 1
    afterSub.BorderSizePixel = 0
    afterSub.Size = UDim2.new(1, 0, 0, GAP_AFTER_SUBTITLE)
    afterSub.LayoutOrder = 2
    afterSub.Parent = secFrame

    local secObj = {
        _tab      = self,
        _page     = page,
        _frame    = secFrame,
        _order    = 3,   -- next LayoutOrder inside secFrame
        _itemCount = 0,
    }
    setmetatable(secObj, { __index = _SectionMeta })

    self._sections[#self._sections+1] = secObj
    return secObj
end

-- ════════════════════════════════════════════════════════════════
-- Section methods
-- ════════════════════════════════════════════════════════════════
_SectionMeta = {}
_SectionMeta.__index = _SectionMeta

function _SectionMeta:_nextOrder()
    local o = self._order
    self._order = o + 1
    return o
end

function _SectionMeta:_addGap(h)
    if self._itemCount > 0 then
        local g = Instance.new("Frame")
        g.BackgroundTransparency = 1
        g.BorderSizePixel = 0
        g.Size = UDim2.new(1, 0, 0, h or GAP_BETWEEN)
        g.LayoutOrder = self:_nextOrder()
        g.Parent = self._frame
    end
end

-- ── AddSlider ─────────────────────────────────────────────────
-- cfg = { label, min, max, default, color, onChange(value:number) }
-- returns { SetValue(n), GetValue(), Fill, Box, Track }
function _SectionMeta:AddSlider(cfg)
    cfg = cfg or {}
    local min     = cfg.min     or 0
    local max     = cfg.max     or 10
    local default = cfg.default or min
    local color   = cfg.color   or Color3.fromRGB(255,100,0)
    local label   = cfg.label   or "?"

    self:_addGap()

    -- Wrapper row (full width, SLIDER_H tall — slider handle overhangs visually)
    local wrapper = Instance.new("Frame")
    wrapper.Name = "Slider_"..label
    wrapper.BackgroundTransparency = 1
    wrapper.BorderSizePixel = 0
    wrapper.Size = UDim2.new(1, 0, 0, BOX_H)   -- tall enough to click the box
    wrapper.LayoutOrder = self:_nextOrder()
    wrapper.Parent = self._frame

    -- Axis label (left of track)
    local axisLbl = Instance.new("TextLabel")
    axisLbl.Name = "Axis"
    axisLbl.Text = label
    axisLbl.BackgroundTransparency = 1
    axisLbl.BorderSizePixel = 0
    axisLbl.Size = UDim2.new(0, LABEL_W, 0, BOX_H)
    axisLbl.Position = UDim2.new(0, 0, 0, 0)
    axisLbl.AnchorPoint = Vector2.new(0, 0)
    axisLbl.TextColor3 = Color3.fromRGB(255,255,255)
    axisLbl.FontFace = FONT_BOLD
    axisLbl.TextSize = 14
    axisLbl.TextScaled = true
    axisLbl.TextXAlignment = Enum.TextXAlignment.Left
    axisLbl.Parent = wrapper

    -- Track
    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.Text = ""
    track.AutoButtonColor = false
    track.BackgroundTransparency = 0.9
    track.BackgroundColor3 = Color3.fromRGB(255,255,255)
    track.BorderSizePixel = 0
    track.FontFace = FONT_SRC
    track.TextSize = 14
    track.TextColor3 = Color3.fromRGB(0,0,0)
    -- track spans from after axis label to before box
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.Position = UDim2.new(0, LABEL_W + 5, 0.5, 0)
    track.Size = UDim2.new(1, -(LABEL_W + 5 + BOX_W + 15), 0, SLIDER_H)
    track.Parent = wrapper

    -- Fill
    local initPct = (default - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = color
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    fill.Parent = track

    -- Thumb
    local thumb = Instance.new("TextButton")
    thumb.Name = "Thumb"
    thumb.Text = ""
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.Position = UDim2.new(1, 0, 0.5, 0)
    thumb.Size = UDim2.new(0, SLIDER_BTN_W, 1, SLIDER_BTN_H)
    thumb.BackgroundColor3 = Color3.fromRGB(112,112,112)
    thumb.BorderSizePixel = 0
    thumb.FontFace = FONT_SRC
    thumb.TextSize = 14
    thumb.TextColor3 = Color3.fromRGB(0,0,0)
    thumb.Parent = fill

    -- Value box
    local box = Instance.new("TextBox")
    box.Name = "Box"
    box.FontFace = FONT_SRC
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.BackgroundTransparency = 0.9
    box.BackgroundColor3 = Color3.fromRGB(255,255,255)
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.AnchorPoint = Vector2.new(0, 0.5)
    box.Position = UDim2.new(1, 10, 0.5, 0)
    box.Size = UDim2.new(0, BOX_W, 0, BOX_H)
    box.Text = string.format("%.2f", default)
    box.PlaceholderText = tostring(default)
    box.TextSize = 14
    box.ClipsDescendants = true
    box.Parent = track
    do local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0.2,0); c.Parent = box end

    -- Slider logic
    local dragging = false
    local value = default

    local function updateFromPct(pct)
        pct = math.clamp(pct, 0, 1)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        value = min + pct * (max - min)
        local fmt = string.format("%.2f", value)
        box.Text = fmt
        if cfg.onChange then cfg.onChange(value) end
    end

    local function updateFromInput(inp)
        local rel = math.clamp(inp.Position.X - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        updateFromPct(rel / track.AbsoluteSize.X)
    end

    local function beginDrag(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(inp)
            local conn; conn = inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    dragging = false; conn:Disconnect()
                end
            end)
        end
    end

    track.InputBegan:Connect(beginDrag)
    thumb.InputBegan:Connect(beginDrag)
    track.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(inp)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(inp)
        end
    end)

    box:GetPropertyChangedSignal("Text"):Connect(function()
        local v = tonumber(box.Text)
        if v then
            v = math.clamp(v, min, max)
            value = v
            fill.Size = UDim2.new((v - min)/(max - min), 0, 1, 0)
            if cfg.onChange then cfg.onChange(v) end
        end
    end)

    self._itemCount = self._itemCount + 1

    local sliderObj = {
        Track = track,
        Fill  = fill,
        Box   = box,
        _value = function() return value end,
    }

    function sliderObj:SetValue(v)
        v = math.clamp(v, min, max)
        value = v
        local pct = (v - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        box.Text = string.format("%.2f", v)
        if cfg.onChange then cfg.onChange(v) end
    end

    function sliderObj:GetValue()
        return value
    end

    return sliderObj
end

-- ── AddButton ─────────────────────────────────────────────────
-- cfg = { label, assetIcon, color, onClick() }
-- returns { SetLabel(str), Button }
function _SectionMeta:AddButton(cfg)
    cfg = cfg or {}
    local color = cfg.color or Color3.fromRGB(200,0,0)

    self:_addGap()

    local btn = Instance.new("TextButton")
    btn.Name = "Btn_"..(cfg.label or "?")
    btn.Text = ""
    btn.AnchorPoint = Vector2.new(0.5, 0)
    btn.Position = UDim2.new(0.5, 0, 0, 0)
    btn.Size = UDim2.new(1, 0, 0, BTN_H)
    btn.BackgroundTransparency = 0.9
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.FontFace = FONT_SRC
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.LayoutOrder = self:_nextOrder()
    btn.Parent = self._frame
    corner(btn, 0.2)
    hlist(btn, 5)

    if cfg.assetIcon then
        local ic = icon(btn, cfg.assetIcon, 15)
        ic.LayoutOrder = 1
    end

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.FontFace = FONT_REG
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Text = cfg.label or "Button"
    lbl.Size = UDim2.new(0, math.max(40, #(cfg.label or "Button") * 8), 0, 20)
    lbl.LayoutOrder = 2
    lbl.Parent = btn

    if cfg.onClick then
        btn.MouseButton1Click:Connect(cfg.onClick)
    end

    self._itemCount = self._itemCount + 1

    local btnObj = {
        Button = btn,
        _lbl   = lbl,
    }
    function btnObj:SetLabel(s) lbl.Text = s end
    function btnObj:SetColor(c) btn.BackgroundColor3 = c end

    return btnObj
end

-- ── AddSelector ───────────────────────────────────────────────
-- cfg = { options={}, default=1, onChange(option, index) }
-- returns { SetIndex(n), GetIndex(), GetOption(), Label }
function _SectionMeta:AddSelector(cfg)
    cfg = cfg or {}
    local options = cfg.options or {"?"}
    local idx     = cfg.default or 1

    self:_addGap()

    local container = Instance.new("Frame")
    container.Name = "Selector"
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.Size = UDim2.new(1, 0, 0, SEL_H)
    container.LayoutOrder = self:_nextOrder()
    container.Parent = self._frame

    local prevBtn = Instance.new("TextButton")
    prevBtn.Name = "Prev"
    prevBtn.Text = "<"
    prevBtn.FontFace = FONT_BOLD
    prevBtn.TextScaled = true
    prevBtn.TextColor3 = Color3.fromRGB(255,255,255)
    prevBtn.BackgroundTransparency = 1
    prevBtn.BorderSizePixel = 0
    prevBtn.AutoButtonColor = false
    prevBtn.Size = UDim2.new(0, 20, 1, 0)
    prevBtn.Position = UDim2.new(0, 0, 0, 0)
    prevBtn.Parent = container

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.BackgroundTransparency = 1
    lbl.BorderSizePixel = 0
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 20, 0, 0)
    lbl.TextColor3 = Color3.fromRGB(255,255,255)
    lbl.FontFace = FONT_REG
    lbl.TextSize = 14
    lbl.TextScaled = true
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.Text = options[idx] or "?"
    lbl.Parent = container

    local nextBtn = Instance.new("TextButton")
    nextBtn.Name = "Next"
    nextBtn.Text = ">"
    nextBtn.FontFace = FONT_BOLD
    nextBtn.TextScaled = true
    nextBtn.TextColor3 = Color3.fromRGB(255,255,255)
    nextBtn.BackgroundTransparency = 1
    nextBtn.BorderSizePixel = 0
    nextBtn.AutoButtonColor = false
    nextBtn.Size = UDim2.new(0, 20, 1, 0)
    nextBtn.Position = UDim2.new(1, -20, 0, 0)
    nextBtn.Parent = container

    local selObj = {
        Label   = lbl,
        Prev    = prevBtn,
        Next    = nextBtn,
        _idx    = idx,
        _opts   = options,
    }

    local function select(newIdx)
        newIdx = ((newIdx - 1) % #options) + 1
        selObj._idx = newIdx
        lbl.Text = options[newIdx] or "?"
        if cfg.onChange then cfg.onChange(options[newIdx], newIdx) end
    end

    prevBtn.MouseButton1Click:Connect(function() select(selObj._idx - 1) end)
    nextBtn.MouseButton1Click:Connect(function() select(selObj._idx + 1) end)

    function selObj:SetIndex(n) select(n) end
    function selObj:GetIndex()  return self._idx end
    function selObj:GetOption() return options[self._idx] end

    self._itemCount = self._itemCount + 1
    return selObj
end

-- ── AddPresetGrid ─────────────────────────────────────────────
-- Wrapping grid of small preset buttons.
-- cfg = { presets={{name,...}}, color, onSelect(preset) }
-- returns { container Frame }
function _SectionMeta:AddPresetGrid(cfg)
    cfg = cfg or {}
    local color = cfg.color or Color3.fromRGB(200,200,200)

    self:_addGap()

    local grid = Instance.new("Frame")
    grid.Name = "PresetGrid"
    grid.BackgroundTransparency = 1
    grid.BorderSizePixel = 0
    grid.AutomaticSize = Enum.AutomaticSize.Y
    grid.Size = UDim2.new(1, 0, 0, 0)
    grid.LayoutOrder = self:_nextOrder()
    grid.Parent = self._frame

    local lay = Instance.new("UIListLayout")
    lay.FillDirection = Enum.FillDirection.Horizontal
    lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    lay.Wraps = true
    lay.Padding = UDim.new(0, 5)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = grid

    for i, preset in ipairs(cfg.presets or {}) do
        local pb = Instance.new("TextButton")
        pb.Name = "Preset_"..preset.name
        pb.Text = preset.name
        pb.FontFace = FONT_REG
        pb.TextColor3 = Color3.fromRGB(255,255,255)
        pb.TextSize = 12
        pb.TextScaled = false
        pb.BackgroundTransparency = 0.9
        pb.BackgroundColor3 = color
        pb.BorderSizePixel = 0
        pb.AutoButtonColor = false
        pb.Size = UDim2.new(0, 60, 0, 20)
        pb.LayoutOrder = i
        pb.Parent = grid
        corner(pb, 0.2)
        if cfg.onSelect then
            pb.MouseButton1Click:Connect(function() cfg.onSelect(preset) end)
        end
    end

    self._itemCount = self._itemCount + 1
    return { Container = grid }
end

return UILib