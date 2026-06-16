--[[
    Zyrix — Key System + GUI Library
    License: MIT
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end

local TS  = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS  = cloneref(game:GetService("RunService"))
local LP  = cloneref(game:GetService("Lighting"))
local PLR = cloneref(game:GetService("Players"))
local HS  = cloneref(game:GetService("HttpService"))
local WS  = cloneref(game:GetService("Workspace"))

local hui = gethui()

-- prevent duplicate loads
if getgenv().__ZyrixActive then
    warn("[Zyrix] Already loaded, returning existing instance")
    return getgenv().__ZyrixLib
end
getgenv().__ZyrixActive = true

-- ══════════════════════════════════════════════════════════════════════════════
--  SHARED UTILITIES
-- ══════════════════════════════════════════════════════════════════════════════
local function tw(obj, t, props, style)
    TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
end

local function mkFrame(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k] = v end
    return f
end

local function mkLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextScaled = false
    for k,v in pairs(props) do l[k] = v end
    return l
end

local function mkButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    for k,v in pairs(props) do b[k] = v end
    return b
end

local function mkImage(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.ScaleType = Enum.ScaleType.Fit
    for k,v in pairs(props) do i[k] = v end
    return i
end

local function applyCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 6)
    return c
end

local function applyStroke(p, col, thick, trans)
    local s = Instance.new("UIStroke", p)
    s.Color = col or Color3.fromRGB(45,45,45)
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    return s
end

local function mkScroll(parent, size, pos)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = size or UDim2.new(1,0,1,0)
    sf.Position = pos or UDim2.new(0,0,0,0)
    sf.BackgroundTransparency = 1
    sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Parent = parent
    return sf
end

local function mkList(parent, pad, dir)
    local l = Instance.new("UIListLayout", parent)
    l.Padding = UDim.new(0, pad or 6)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = dir or Enum.FillDirection.Vertical
    return l
end

local function mkPad(p, t, b, l, r)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop    = UDim.new(0, t or 0)
    pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0)
    pad.PaddingRight  = UDim.new(0, r or 0)
end

local function draggable(handle, root)
    local drag, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or
           i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; dp = root.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or
           i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            root.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  THEME
-- ══════════════════════════════════════════════════════════════════════════════
local C = {
    BG         = Color3.fromRGB(8,   8,   8),
    BG2        = Color3.fromRGB(13,  13,  13),
    BG3        = Color3.fromRGB(20,  20,  20),
    BG4        = Color3.fromRGB(28,  28,  28),
    Stroke     = Color3.fromRGB(40,  40,  40),
    Accent     = Color3.fromRGB(255, 255, 255),
    AccentDim  = Color3.fromRGB(150, 150, 150),
    Text       = Color3.fromRGB(255, 255, 255),
    TextDim    = Color3.fromRGB(100, 100, 100),
    TextOff    = Color3.fromRGB(50,  50,  50),
    Success    = Color3.fromRGB(120, 255, 120),
    Error      = Color3.fromRGB(255, 80,  80),
    Warning    = Color3.fromRGB(255, 200, 80),
}

-- ══════════════════════════════════════════════════════════════════════════════
--  GUI LIBRARY  (ZyrixUI)
--  Layout: title bar → horizontal pill tab bar → two-column element grid
-- ══════════════════════════════════════════════════════════════════════════════
-- ══════════════════════════════════════════════════════════════════════════════
--  ZyrixUI  —  exact G2L design, wired to a clean Lua API
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixUI = {}

-- internal state
local _sg         = nil   -- ScreenGui
local _tablist    = nil   -- main window frame (G2L["2"])
local _pillScroll = nil   -- horizontal tab scroll (G2L["42"])
local _elements   = nil   -- content scrolling frame (G2L["6"])
local _tabBtns    = {}
local _tabPanels  = {}
local _activeTab  = nil
local _tabLO      = 0

-- ── switch tab ────────────────────────────────────────────────────────────────
local function switchTab(name)
    if _activeTab == name then return end
    _activeTab = name
    for n, b in pairs(_tabBtns) do
        local on = n == name
        b.TextColor3       = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(141,141,141)
        b.BackgroundColor3 = on and Color3.fromRGB(30,30,30)    or Color3.fromRGB(19,19,19)
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then s.Color = on and Color3.fromRGB(80,80,80) or Color3.fromRGB(41,41,41) end
    end
    for n, p in pairs(_tabPanels) do
        p.Visible = n == name
    end
end

-- ── build the shell (exact G2L layout) ───────────────────────────────────────
local function buildShell()
    if _sg then _sg:Destroy() end
    _tabBtns = {} _tabPanels = {} _activeTab = nil _tabLO = 0

    -- ScreenGui
    _sg = Instance.new("ScreenGui")
    _sg.Name           = "Zyrix"
    _sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _sg.ResetOnSpawn   = false
    _sg.IgnoreGuiInset = true
    _sg.DisplayOrder   = 50
    _sg.Parent         = hui

    -- ── G2L["2"]  Tablist (main window) ──────────────────────────────────────
    local tablist = Instance.new("Frame", _sg)
    tablist.BorderSizePixel      = 0
    tablist.BackgroundColor3     = Color3.fromRGB(0,0,0)
    tablist.Size                 = UDim2.new(0,563,0,354)
    tablist.Position             = UDim2.new(0.5,-281,0.5,-177)
    tablist.BackgroundTransparency = 0.1
    tablist.Name                 = "Tablist"
    Instance.new("UICorner", tablist)
    local tStroke = Instance.new("UIStroke", tablist)
    tStroke.Color = Color3.fromRGB(41,41,41)
    tStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _tablist = tablist

    -- ── title text  (G2L["3"]) ────────────────────────────────────────────────
    local titleLbl = Instance.new("TextLabel", tablist)
    titleLbl.BorderSizePixel      = 0
    titleLbl.TextSize             = 14
    titleLbl.TextXAlignment       = Enum.TextXAlignment.Left
    titleLbl.BackgroundTransparency = 1
    titleLbl.FontFace             = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    titleLbl.TextColor3           = Color3.fromRGB(255,255,255)
    titleLbl.Size                 = UDim2.new(0,480,0,23)
    titleLbl.Text                 = "zyrix"
    titleLbl.Position             = UDim2.new(0,32,0,6)

    -- ── logo icon  (G2L["4"]) ────────────────────────────────────────────────
    local logoBtn = Instance.new("ImageButton", tablist)
    logoBtn.BorderSizePixel      = 0
    logoBtn.BackgroundTransparency = 1
    logoBtn.ImageColor3          = Color3.fromRGB(141,141,141)
    logoBtn.Image                = "rbxassetid://105436073524298"
    logoBtn.Size                 = UDim2.new(0,26,0,29)
    logoBtn.Name                 = "openTab"
    logoBtn.Position             = UDim2.new(0,5,0,6)

    -- ── separator line  (G2L["5"]) ────────────────────────────────────────────
    local sepLine = Instance.new("TextLabel", tablist)
    sepLine.BorderSizePixel      = 0
    sepLine.TextSize             = 14
    sepLine.BackgroundColor3     = Color3.fromRGB(31,31,31)
    sepLine.TextColor3           = Color3.fromRGB(0,0,0)
    sepLine.Size                 = UDim2.new(0,563,0,1)
    sepLine.Text                 = ""
    sepLine.Position             = UDim2.new(0,0,0,37)

    -- ── content scroll  (G2L["6"]  elements) ─────────────────────────────────
    local elements = Instance.new("ScrollingFrame", tablist)
    elements.Active              = true
    elements.BorderSizePixel     = 0
    elements.Name                = "elements"
    elements.ScrollBarImageTransparency = 0.3
    elements.BackgroundColor3    = Color3.fromRGB(11,11,11)
    elements.Size                = UDim2.new(0,546,0,272)
    elements.ScrollBarImageColor3 = Color3.fromRGB(141,141,141)
    elements.Position            = UDim2.new(0.00979,0,0.10452,41)
    elements.ScrollBarThickness  = 2
    elements.BackgroundTransparency = 1
    elements.CanvasSize          = UDim2.new(0,0,0,0)
    elements.AutomaticCanvasSize = Enum.AutomaticSize.Y
    _elements = elements

    local elPad = Instance.new("UIPadding", elements)
    elPad.PaddingTop    = UDim.new(0,6)
    elPad.PaddingRight  = UDim.new(0,8)
    elPad.PaddingLeft   = UDim.new(0,8)
    elPad.PaddingBottom = UDim.new(0,6)

    local elLayout = Instance.new("UIListLayout", elements)
    elLayout.Padding    = UDim.new(0,5)
    elLayout.SortOrder  = Enum.SortOrder.LayoutOrder
    elLayout.FillDirection = Enum.FillDirection.Vertical

    -- ── tab bar frame  (G2L["41"]) ────────────────────────────────────────────
    local pillFrame = Instance.new("Frame", tablist)
    pillFrame.BorderSizePixel    = 0
    pillFrame.BackgroundColor3   = Color3.fromRGB(11,11,11)
    pillFrame.Size               = UDim2.new(0,563,0,41)
    pillFrame.Position           = UDim2.new(0,0,0,37)
    local pfStroke = Instance.new("UIStroke", pillFrame)
    pfStroke.Color = Color3.fromRGB(41,41,41)
    pfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    local pfCorner = Instance.new("UICorner", pillFrame)
    pfCorner.CornerRadius = UDim.new(0,100)

    -- ── pill scrolling frame  (G2L["42"]) ────────────────────────────────────
    local pillScroll = Instance.new("ScrollingFrame", pillFrame)
    pillScroll.Active               = true
    pillScroll.ScrollingDirection   = Enum.ScrollingDirection.X
    pillScroll.BorderSizePixel      = 0
    pillScroll.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    pillScroll.ElasticBehavior      = Enum.ElasticBehavior.Always
    pillScroll.BackgroundColor3     = Color3.fromRGB(11,11,11)
    pillScroll.Size                 = UDim2.new(0,563,0,41)
    pillScroll.ScrollBarImageColor3 = Color3.fromRGB(141,141,141)
    pillScroll.Position             = UDim2.new(0,0,-0.01118,0)
    pillScroll.ScrollBarThickness   = 2
    pillScroll.BackgroundTransparency = 0.1
    pillScroll.CanvasSize           = UDim2.new(0,0,0,0)
    pillScroll.AutomaticCanvasSize  = Enum.AutomaticSize.X
    local psCorner = Instance.new("UICorner", pillScroll)
    psCorner.CornerRadius = UDim.new(0,100)
    _pillScroll = pillScroll

    local pillLayout = Instance.new("UIListLayout", pillScroll)
    pillLayout.FillDirection        = Enum.FillDirection.Horizontal
    pillLayout.Padding              = UDim.new(0,4)
    pillLayout.SortOrder            = Enum.SortOrder.LayoutOrder
    pillLayout.VerticalAlignment    = Enum.VerticalAlignment.Center
    local pillPad = Instance.new("UIPadding", pillScroll)
    pillPad.PaddingLeft  = UDim.new(0,6)
    pillPad.PaddingRight = UDim.new(0,6)

    -- draggable by title bar area
    draggable(pillFrame, tablist)

    -- close button (small X top-right)
    local closeBtn = Instance.new("TextButton", tablist)
    closeBtn.Size                = UDim2.new(0,18,0,18)
    closeBtn.Position            = UDim2.new(1,-22,0,9)
    closeBtn.BackgroundColor3    = Color3.fromRGB(30,30,30)
    closeBtn.BorderSizePixel     = 0
    closeBtn.Text                = "✕"
    closeBtn.TextColor3          = Color3.fromRGB(141,141,141)
    closeBtn.TextSize            = 10
    closeBtn.Font                = Enum.Font.GothamBold
    closeBtn.AutoButtonColor     = false
    closeBtn.ZIndex              = 10
    local cbCorner = Instance.new("UICorner", closeBtn)
    cbCorner.CornerRadius = UDim.new(1,0)
    closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3=Color3.fromRGB(255,80,80) end)
    closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3=Color3.fromRGB(141,141,141) end)
    closeBtn.MouseButton1Click:Connect(function()
        if _sg then _sg:Destroy(); _sg=nil end
    end)

    -- entrance animation
    tablist.Size = UDim2.new(0,563,0,0)
    tablist.BackgroundTransparency = 1
    TS:Create(tablist, TweenInfo.new(0.3,Enum.EasingStyle.Back), {
        Size=UDim2.new(0,563,0,354), BackgroundTransparency=0.1
    }):Play()

    -- global toggle keybind
    getgenv().__ZyrixToggleKey = getgenv().__ZyrixToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == getgenv().__ZyrixToggleKey and tablist then
            tablist.Visible = not tablist.Visible
        end
    end)
end

-- ── AddTab ─────────────────────────────────────────────────────────────────────
function ZyrixUI:AddTab(name, icon)
    if not _sg then warn("[ZyrixUI] Call ZyrixUI:Open() first") return {} end

    _tabLO = _tabLO + 1

    -- pill button  (G2L["43"] style)
    local pill = Instance.new("TextButton", _pillScroll)
    pill.BorderSizePixel     = 0
    pill.TextSize            = 12
    pill.TextColor3          = Color3.fromRGB(141,141,141)
    pill.BackgroundColor3    = Color3.fromRGB(19,19,19)
    pill.FontFace            = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    pill.Size                = UDim2.new(0, math.max(60, #name*8+20), 0, 35)
    pill.Text                = (icon and icon.." " or "")..name
    pill.AutoButtonColor     = false
    pill.LayoutOrder         = _tabLO
    local pillCorner = Instance.new("UICorner", pill)
    pillCorner.CornerRadius = UDim.new(0,100)
    local pillStroke = Instance.new("UIStroke", pill)
    pillStroke.Thickness        = 0.5
    pillStroke.Color            = Color3.fromRGB(41,41,41)
    pillStroke.ApplyStrokeMode  = Enum.ApplyStrokeMode.Border
    local pillPad2 = Instance.new("UIPadding", pill)
    pillPad2.PaddingTop    = UDim.new(0,4)
    pillPad2.PaddingBottom = UDim.new(0,4)
    pillPad2.PaddingLeft   = UDim.new(0,8)
    pillPad2.PaddingRight  = UDim.new(0,8)

    pill.MouseButton1Click:Connect(function() switchTab(name) end)
    _tabBtns[name] = pill

    -- each tab gets its own UIListLayout inside _elements
    -- we swap visibility of a "panel" frame that contains a layout
    local panel = Instance.new("Frame", _elements)
    panel.Size               = UDim2.new(1,0,0,0)
    panel.AutomaticSize      = Enum.AutomaticSize.Y
    panel.BackgroundTransparency = 1
    panel.BorderSizePixel    = 0
    panel.Visible            = false
    panel.LayoutOrder        = _tabLO
    local panelLayout = Instance.new("UIListLayout", panel)
    panelLayout.Padding      = UDim.new(0,5)
    panelLayout.SortOrder    = Enum.SortOrder.LayoutOrder
    panelLayout.FillDirection = Enum.FillDirection.Vertical
    _tabPanels[name] = panel

    if _tabLO == 1 then switchTab(name) end

    -- ── element helpers ───────────────────────────────────────────────────────
    local lo = 0
    local function nlo() lo=lo+1 return lo end

    local DARK   = Color3.fromRGB(19,19,19)
    local DARKER = Color3.fromRGB(9,9,9)
    local STROKE = Color3.fromRGB(41,41,41)
    local WHITE  = Color3.fromRGB(255,255,255)
    local GREY   = Color3.fromRGB(141,141,141)

    local function baseEl(h)
        local f = Instance.new("Frame", panel)
        f.BorderSizePixel     = 0
        f.BackgroundColor3    = DARK
        f.Size                = UDim2.new(1,0,0,h)
        f.LayoutOrder         = nlo()
        local s = Instance.new("UIStroke", f)
        s.Thickness           = 0.5
        s.Color               = STROKE
        s.ApplyStrokeMode     = Enum.ApplyStrokeMode.Border
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
        }
        local p = Instance.new("UIPadding", f)
        p.PaddingTop    = UDim.new(0,6)
        p.PaddingBottom = UDim.new(0,6)
        p.PaddingLeft   = UDim.new(0,10)
        p.PaddingRight  = UDim.new(0,10)
        return f, s
    end

    local tab = {}

    -- Section header
    function tab:Section(title)
        lo = lo + 1
        local s = Instance.new("Frame", panel)
        s.Size = UDim2.new(1,0,0,22)
        s.BackgroundTransparency = 1
        s.BorderSizePixel = 0
        s.LayoutOrder = lo
        local lbl = Instance.new("TextLabel", s)
        lbl.Size = UDim2.new(1,0,1,0)
        lbl.BackgroundTransparency = 1
        lbl.BorderSizePixel = 0
        lbl.Text = title:upper()
        lbl.TextColor3 = Color3.fromRGB(100,100,100)
        lbl.TextSize = 9
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        local line = Instance.new("Frame", s)
        line.Size = UDim2.new(1,0,0,1)
        line.Position = UDim2.new(0,0,1,-1)
        line.BackgroundColor3 = STROKE
        line.BorderSizePixel = 0
    end

    -- Toggle  (G2L["2c"] style)
    function tab:Toggle(title, desc, default, callback)
        local state = default or false
        local el, elStr = baseEl(desc and 50 or 37)

        -- title label
        local titleLbl2 = Instance.new("TextLabel", el)
        titleLbl2.TextWrapped        = true
        titleLbl2.BorderSizePixel    = 0
        titleLbl2.TextSize           = 12
        titleLbl2.TextXAlignment     = Enum.TextXAlignment.Left
        titleLbl2.BackgroundColor3   = WHITE
        titleLbl2.FontFace           = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        titleLbl2.TextColor3         = WHITE
        titleLbl2.BackgroundTransparency = 1
        titleLbl2.AnchorPoint        = Vector2.new(1,0.5)
        titleLbl2.Size               = UDim2.new(0,250,0,14)
        titleLbl2.Text               = title
        titleLbl2.Position           = UDim2.new(0.65,0,0.5,desc and -8 or 0)

        if desc then
            local d = Instance.new("TextLabel", el)
            d.Size=UDim2.new(0.65,0,0,12) d.Position=UDim2.new(0,0,1,-18)
            d.BackgroundTransparency=1 d.BorderSizePixel=0
            d.Text=desc d.TextColor3=Color3.fromRGB(100,100,100)
            d.TextSize=10 d.Font=Enum.Font.Gotham
            d.TextXAlignment=Enum.TextXAlignment.Left
        end

        -- switch  (G2L["2f"] style)
        local sw = Instance.new("Frame", el)
        sw.BorderSizePixel     = 0
        sw.BackgroundColor3    = DARKER
        sw.AnchorPoint         = Vector2.new(1,0.5)
        sw.Size                = UDim2.new(0,43,0,21)
        sw.Position            = UDim2.new(1,0,0.5,0)
        local swStr = Instance.new("UIStroke", sw)
        swStr.Thickness=0.5 swStr.Color=STROKE swStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local swCorner = Instance.new("UICorner", sw)
        swCorner.CornerRadius = UDim.new(1,0)

        -- indicator dot  (G2L["30"])
        local dot = Instance.new("Frame", sw)
        dot.BorderSizePixel  = 0
        dot.BackgroundColor3 = state and WHITE or GREY
        dot.AnchorPoint      = Vector2.new(0,0.5)
        dot.Size             = UDim2.new(0,17,0,17)
        dot.Position         = UDim2.new(state and 1 or 0, state and -19 or 2, 0.5, 0)
        local dotStr = Instance.new("UIStroke", dot) dotStr.Thickness=1.2
        local dotCorner = Instance.new("UICorner", dot) dotCorner.CornerRadius=UDim.new(1,0)

        -- active stroke gradient (green when on, invisible when off — exact G2L["34"])
        local activeGrad = Instance.new("UIGradient", elStr)
        activeGrad.Color = state
            and ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,171,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,121,0))}
            or  ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),   ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}

        -- interact button
        local hit = Instance.new("TextButton", el)
        hit.BorderSizePixel=0 hit.TextTransparency=1 hit.TextSize=12
        hit.TextColor3=WHITE hit.BackgroundColor3=WHITE
        hit.ZIndex=5 hit.AnchorPoint=Vector2.new(0.5,0.5)
        hit.BackgroundTransparency=1 hit.Size=UDim2.new(1,0,1,0)
        hit.Text="" hit.Position=UDim2.new(0.5,0,0.5,0)

        hit.MouseButton1Click:Connect(function()
            state = not state
            TS:Create(dot,TweenInfo.new(0.18),{
                Position=UDim2.new(state and 1 or 0, state and -19 or 2, 0.5, 0),
                BackgroundColor3 = state and WHITE or GREY,
            }):Play()
            activeGrad.Color = state
                and ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,171,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,121,0))}
                or  ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),   ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
            if callback then pcall(callback, state) end
        end)

        return {
            GetValue = function() return state end,
            SetValue = function(v)
                state = v
                dot.Position = UDim2.new(v and 1 or 0, v and -19 or 2, 0.5, 0)
                dot.BackgroundColor3 = v and WHITE or GREY
                activeGrad.Color = v
                    and ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,171,0)),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,121,0))}
                    or  ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),   ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))}
            end,
        }
    end

    -- Slider  (G2L["1f"] style)
    function tab:Slider(title, min, max, default, suffix, callback)
        if type(suffix) == "function" then callback=suffix; suffix="units" end
        suffix = suffix or "units"
        min=min or 0; max=max or 100; default=math.clamp(default or min,min,max)
        local value = default
        local el, _ = baseEl(47)

        -- left title
        local tl = Instance.new("TextLabel", el)
        tl.TextWrapped=true tl.BorderSizePixel=0 tl.TextSize=12
        tl.TextXAlignment=Enum.TextXAlignment.Left tl.TextScaled=false
        tl.BackgroundTransparency=1
        tl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        tl.TextColor3=WHITE tl.AnchorPoint=Vector2.new(0.5,0.5)
        tl.Size=UDim2.new(0,200,0,14) tl.Text=title
        tl.Position=UDim2.new(0.32525,0,0.5,0)

        -- main slider box  (G2L["21"])
        local main = Instance.new("Frame", el)
        main.BorderSizePixel=0 main.BackgroundColor3=DARKER
        main.AnchorPoint=Vector2.new(0.5,0.5)
        main.Size=UDim2.new(0,222,0,30)
        main.Position=UDim2.new(0.61986,0,0.5,0)
        local mStr=Instance.new("UIStroke",main) mStr.Transparency=0.2 mStr.Thickness=0.5 mStr.Color=STROKE mStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local mCorner=Instance.new("UICorner",main)

        -- progress fill  (G2L["23"])
        local pct0=(value-min)/(max-min)
        local prog=Instance.new("Frame",main)
        prog.BorderSizePixel=0 prog.BackgroundColor3=WHITE
        prog.Size=UDim2.new(pct0,0,1,0)
        local pStr=Instance.new("UIStroke",prog) pStr.Transparency=0.2 pStr.Thickness=1.2
        local pCorner=Instance.new("UICorner",prog)

        -- info label  (G2L["26"])
        local info=Instance.new("TextLabel",main)
        info.TextWrapped=true info.ZIndex=5 info.BorderSizePixel=0
        info.TextSize=10 info.TextXAlignment=Enum.TextXAlignment.Left
        info.TextTransparency=0.3
        info.BackgroundTransparency=1
        info.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        info.TextColor3=GREY info.AnchorPoint=Vector2.new(0.5,0.5)
        info.Size=UDim2.new(0,168,0,15)
        info.Text=tostring(value).." "..suffix
        info.Position=UDim2.new(0.4536,0,0.5,0)

        -- interact  (G2L["27"])
        local hit=Instance.new("TextButton",main)
        hit.BorderSizePixel=0 hit.TextSize=14 hit.TextColor3=Color3.fromRGB(0,0,0)
        hit.BackgroundColor3=WHITE hit.ZIndex=10 hit.BackgroundTransparency=1
        hit.Size=UDim2.new(1,0,1,0) hit.Text=""

        local dragging=false
        local function update(x)
            local rel=math.clamp((x-main.AbsolutePosition.X)/main.AbsoluteSize.X,0,1)
            value=math.floor(min+(max-min)*rel+0.5)
            prog.Size=UDim2.new((value-min)/(max-min),0,1,0)
            info.Text=tostring(value).." "..suffix
            if callback then pcall(callback,value) end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; update(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then update(i.Position.X) end
        end)

        return {
            GetValue=function() return value end,
            SetValue=function(v)
                value=math.clamp(v,min,max)
                prog.Size=UDim2.new((value-min)/(max-min),0,1,0)
                info.Text=tostring(value).." "..suffix
            end,
        }
    end

    -- Button  (G2L["18"] style)
    function tab:Button(title, callback)
        local el, _ = baseEl(35)

        local tl=Instance.new("TextLabel",el)
        tl.TextWrapped=true tl.BorderSizePixel=0 tl.TextSize=12
        tl.TextXAlignment=Enum.TextXAlignment.Left tl.TextScaled=false
        tl.BackgroundTransparency=1
        tl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        tl.TextColor3=WHITE tl.AnchorPoint=Vector2.new(0.5,0.5)
        tl.Size=UDim2.new(0,307,0,14) tl.Text=title
        tl.Position=UDim2.new(0.50604,0,0.47561,0) tl.Name="Title"

        local ind=Instance.new("TextLabel",el)
        ind.TextWrapped=true ind.BorderSizePixel=0 ind.TextSize=10
        ind.TextXAlignment=Enum.TextXAlignment.Right ind.TextTransparency=0.5
        ind.BackgroundTransparency=1
        ind.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        ind.TextColor3=GREY ind.AnchorPoint=Vector2.new(0.5,0.5)
        ind.Size=UDim2.new(0,108,0,13) ind.Text="Button"
        ind.Position=UDim2.new(0.77168,0,0.47561,0) ind.Name="ElementIndicator"

        local hit=Instance.new("TextButton",el)
        hit.BorderSizePixel=0 hit.TextTransparency=1 hit.TextSize=12
        hit.TextColor3=WHITE hit.BackgroundColor3=WHITE
        hit.ZIndex=5 hit.AnchorPoint=Vector2.new(0.5,0.5)
        hit.BackgroundTransparency=1 hit.Size=UDim2.new(1,0,1,0)
        hit.Text="" hit.Position=UDim2.new(0.5,0,0.5,0)

        hit.MouseButton1Click:Connect(function()
            TS:Create(el,TweenInfo.new(0.06),{BackgroundColor3=Color3.fromRGB(30,30,30)}):Play()
            task.delay(0.1,function() TS:Create(el,TweenInfo.new(0.1),{BackgroundColor3=DARK}):Play() end)
            if callback then pcall(callback) end
        end)
    end

    -- Keybind  (G2L["36"] style)
    function tab:Keybind(title, default, callback)
        local key = default or Enum.KeyCode.Unknown
        local listening = false
        local el, _ = baseEl(37)

        local tl=Instance.new("TextLabel",el)
        tl.TextWrapped=true tl.BorderSizePixel=0 tl.TextSize=12
        tl.TextXAlignment=Enum.TextXAlignment.Left tl.TextScaled=false
        tl.BackgroundTransparency=1
        tl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        tl.TextColor3=WHITE tl.AnchorPoint=Vector2.new(0.5,0.5)
        tl.Size=UDim2.new(0,200,0,14) tl.Text=title
        tl.Position=UDim2.new(0.32525,0,0.5,0) tl.Name="Title"

        -- keybind box  (G2L["38"])
        local kbFrame=Instance.new("Frame",el)
        kbFrame.BorderSizePixel=0 kbFrame.BackgroundColor3=DARKER
        kbFrame.AnchorPoint=Vector2.new(1,0.5)
        kbFrame.Size=UDim2.new(0,36,0,21)
        kbFrame.Position=UDim2.new(1,0,0.5,0)
        kbFrame.Name="KeybindFrame"
        local kbStr=Instance.new("UIStroke",kbFrame) kbStr.Thickness=0.5 kbStr.Color=STROKE kbStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local kbCorner=Instance.new("UICorner",kbFrame) kbCorner.CornerRadius=UDim.new(0,4)

        local kbBox=Instance.new("TextBox",kbFrame)
        kbBox.Name="KeybindBox"
        kbBox.PlaceholderColor3=Color3.fromRGB(179,179,179)
        kbBox.BorderSizePixel=0 kbBox.TextSize=11 kbBox.TextColor3=WHITE
        kbBox.BackgroundColor3=DARKER kbBox.BackgroundTransparency=1
        kbBox.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        kbBox.AnchorPoint=Vector2.new(0.5,0.5)
        kbBox.ClearTextOnFocus=false
        kbBox.PlaceholderText="Key"
        kbBox.Size=UDim2.new(1,-4,0,14)
        kbBox.Position=UDim2.new(0.5,0,0.5,0)
        kbBox.Text=tostring(key):gsub("Enum.KeyCode.","")

        local conn2
        kbBox.Focused:Connect(function()
            kbBox.Text="..."
            listening=true
            conn2=UIS.InputBegan:Connect(function(i,gp)
                if gp then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode
                    kbBox.Text=tostring(key):gsub("Enum.KeyCode.","")
                    listening=false kbBox:ReleaseFocus()
                    if conn2 then conn2:Disconnect() end
                    if callback then pcall(callback,key) end
                end
            end)
        end)

        return {GetValue=function() return key end}
    end

    -- Dropdown  (G2L["7"] style)
    function tab:Dropdown(title, options, default, callback)
        local selected = default or (options and options[1]) or ""
        local isOpen   = false
        local ITEM_H   = 35

        local el, _ = baseEl(37)
        el.ClipsDescendants = false
        el.ZIndex = 5

        -- title  (G2L["8"])
        local tl=Instance.new("TextLabel",el)
        tl.TextWrapped=true tl.ZIndex=3 tl.BorderSizePixel=0
        tl.TextSize=12 tl.TextXAlignment=Enum.TextXAlignment.Left
        tl.BackgroundTransparency=1
        tl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        tl.TextColor3=WHITE tl.AnchorPoint=Vector2.new(0.5,0.5)
        tl.Size=UDim2.new(0,201,0,14) tl.Text=title
        tl.Position=UDim2.new(0,99,0,12) tl.Name="Title"

        -- selected label  (G2L["11"])
        local selLbl=Instance.new("TextLabel",el)
        selLbl.TextWrapped=true selLbl.BorderSizePixel=0
        selLbl.TextSize=11 selLbl.TextXAlignment=Enum.TextXAlignment.Right
        selLbl.BackgroundTransparency=1
        selLbl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
        selLbl.TextColor3=WHITE selLbl.AnchorPoint=Vector2.new(0.5,0.5)
        selLbl.Size=UDim2.new(0,168,0,14) selLbl.Text=selected
        selLbl.Position=UDim2.new(0,74,0,12) selLbl.Name="Selected"

        -- arrow toggle  (uses arrow char instead of image)
        local arrow=Instance.new("TextLabel",el)
        arrow.Size=UDim2.new(0,20,0,14) arrow.Position=UDim2.new(1,-20,0,10)
        arrow.BackgroundTransparency=1 arrow.BorderSizePixel=0
        arrow.Text="▾" arrow.TextColor3=GREY arrow.TextSize=11
        arrow.Font=Enum.Font.GothamBold

        -- list frame  (G2L["9"])
        local listFrame=Instance.new("Frame",el)
        listFrame.BorderSizePixel=0 listFrame.BackgroundColor3=DARK
        listFrame.Size=UDim2.new(1,0,0,0)
        listFrame.Position=UDim2.new(0,0,1,3)
        listFrame.ClipsDescendants=true listFrame.ZIndex=10
        local lfStr=Instance.new("UIStroke",listFrame)
        lfStr.Thickness=0.5 lfStr.Color=STROKE lfStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        local lfCorner=Instance.new("UICorner",listFrame) lfCorner.CornerRadius=UDim.new(0,4)

        local listScroll=Instance.new("ScrollingFrame",listFrame)
        listScroll.Size=UDim2.new(1,0,1,0) listScroll.BackgroundTransparency=1
        listScroll.BorderSizePixel=0 listScroll.ScrollBarThickness=2
        listScroll.ScrollBarImageColor3=GREY listScroll.ScrollBarImageTransparency=0.7
        listScroll.CanvasSize=UDim2.new(0,0,0,0) listScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        listScroll.ZIndex=11
        local lLayout=Instance.new("UIListLayout",listScroll) lLayout.Padding=UDim.new(0,2) lLayout.SortOrder=Enum.SortOrder.LayoutOrder

        for _,opt in ipairs(options or {}) do
            -- template row  (G2L["b"] style)
            local row=Instance.new("Frame",listScroll)
            row.BorderSizePixel=0 row.BackgroundColor3=DARKER
            row.Size=UDim2.new(0.97745,0,0,ITEM_H-2)
            row.LayoutOrder=0
            local rStr=Instance.new("UIStroke",row) rStr.Thickness=0.8 rStr.Color=WHITE rStr.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            local rCorner=Instance.new("UICorner",row)

            local rowLbl=Instance.new("TextLabel",row)
            rowLbl.TextWrapped=true rowLbl.BorderSizePixel=0 rowLbl.TextSize=11
            rowLbl.TextXAlignment=Enum.TextXAlignment.Left rowLbl.BackgroundTransparency=1
            rowLbl.FontFace=Font.new("rbxasset://fonts/families/GothamSSm.json",Enum.FontWeight.Medium,Enum.FontStyle.Normal)
            rowLbl.TextColor3=WHITE rowLbl.AnchorPoint=Vector2.new(0.5,0.5)
            rowLbl.Size=UDim2.new(0,168,0,15) rowLbl.Text=opt
            rowLbl.Position=UDim2.new(0.49503,0,0.42125,0) rowLbl.Name="Title"

            local rowHit=Instance.new("TextButton",row)
            rowHit.BorderSizePixel=0 rowHit.TextSize=1 rowHit.TextColor3=Color3.fromRGB(0,0,0)
            rowHit.BackgroundColor3=WHITE rowHit.ZIndex=5 rowHit.BackgroundTransparency=1
            rowHit.Size=UDim2.new(1,0,1,0) rowHit.Text="" rowHit.Name="Interact"

            rowHit.MouseEnter:Connect(function() TS:Create(row,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(19,19,19)}):Play() end)
            rowHit.MouseLeave:Connect(function() TS:Create(row,TweenInfo.new(0.08),{BackgroundColor3=DARKER}):Play() end)
            rowHit.MouseButton1Click:Connect(function()
                selected=opt selLbl.Text=opt isOpen=false
                TS:Create(arrow,TweenInfo.new(0.12),{Rotation=0}):Play()
                TS:Create(listFrame,TweenInfo.new(0.15),{Size=UDim2.new(1,0,0,0)}):Play()
                el.Size=UDim2.new(1,0,0,37)
                if callback then pcall(callback,opt) end
            end)
        end

        local maxH=ITEM_H*math.min(#(options or {}),5)+6

        -- interact  (G2L["13"])
        local hit=Instance.new("TextButton",el)
        hit.BorderSizePixel=0 hit.TextTransparency=1 hit.TextSize=12
        hit.TextColor3=WHITE hit.BackgroundColor3=WHITE
        hit.ZIndex=5 hit.AnchorPoint=Vector2.new(0.5,0.5)
        hit.BackgroundTransparency=1 hit.Size=UDim2.new(1,0,1,0)
        hit.Text="" hit.Position=UDim2.new(0.5,0,0.5,0) hit.Name="Interact"

        hit.MouseButton1Click:Connect(function()
            isOpen=not isOpen
            if isOpen then
                TS:Create(arrow,TweenInfo.new(0.12),{Rotation=180}):Play()
                TS:Create(listFrame,TweenInfo.new(0.15),{Size=UDim2.new(1,0,0,maxH)}):Play()
                el.Size=UDim2.new(1,0,0,37+maxH+4)
            else
                TS:Create(arrow,TweenInfo.new(0.12),{Rotation=0}):Play()
                TS:Create(listFrame,TweenInfo.new(0.15),{Size=UDim2.new(1,0,0,0)}):Play()
                el.Size=UDim2.new(1,0,0,37)
            end
        end)

        return {
            GetValue=function() return selected end,
            SetValue=function(v) selected=v; selLbl.Text=v end,
        }
    end

    -- TextBox
    function tab:TextBox(title, placeholder, default, callback)
        local el, _ = baseEl(58)

        local tl=Instance.new("TextLabel",el)
        tl.Size=UDim2.new(1,0,0,14) tl.Position=UDim2.new(0,0,0,0)
        tl.BackgroundTransparency=1 tl.BorderSizePixel=0
        tl.Text=title tl.TextColor3=WHITE tl.TextSize=12
        tl.Font=Enum.Font.GothamBold tl.TextXAlignment=Enum.TextXAlignment.Left

        local inputBG=Instance.new("Frame",el)
        inputBG.Size=UDim2.new(1,0,0,26) inputBG.Position=UDim2.new(0,0,0,18)
        inputBG.BackgroundColor3=DARKER inputBG.BorderSizePixel=0
        local iBGCorner=Instance.new("UICorner",inputBG) iBGCorner.CornerRadius=UDim.new(0,4)
        local iBGStr=Instance.new("UIStroke",inputBG) iBGStr.Thickness=0.5 iBGStr.Color=STROKE

        local tb=Instance.new("TextBox",inputBG)
        tb.Size=UDim2.new(1,-8,1,0) tb.Position=UDim2.new(0,4,0,0)
        tb.BackgroundTransparency=1 tb.Text=default or ""
        tb.PlaceholderText=placeholder or "" tb.PlaceholderColor3=Color3.fromRGB(100,100,100)
        tb.TextColor3=WHITE tb.TextSize=11 tb.Font=Enum.Font.Gotham
        tb.ClearTextOnFocus=false tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.Focused:Connect(function()   iBGStr.Color=WHITE end)
        tb.FocusLost:Connect(function(enter) iBGStr.Color=STROKE
            if enter and callback then pcall(callback,tb.Text) end
        end)
        return {GetValue=function() return tb.Text end, SetValue=function(v) tb.Text=v end}
    end

    -- Notify (in-panel toast)
    function tab:Notify(msg, dur)
        dur = dur or 3
        lo = lo + 1
        local n=Instance.new("Frame",panel)
        n.Size=UDim2.new(1,0,0,30) n.BackgroundColor3=DARKER
        n.BorderSizePixel=0 n.LayoutOrder=lo
        local nCorner=Instance.new("UICorner",n) nCorner.CornerRadius=UDim.new(0,4)
        local nStr=Instance.new("UIStroke",n) nStr.Thickness=0.5 nStr.Color=STROKE
        local nLbl=Instance.new("TextLabel",n)
        nLbl.Size=UDim2.new(1,-12,1,0) nLbl.Position=UDim2.new(0,6,0,0)
        nLbl.BackgroundTransparency=1 nLbl.BorderSizePixel=0
        nLbl.Text=msg nLbl.TextColor3=WHITE nLbl.TextSize=11
        nLbl.Font=Enum.Font.Gotham nLbl.TextXAlignment=Enum.TextXAlignment.Left
        task.delay(dur,function()
            if n and n.Parent then
                TS:Create(n,TweenInfo.new(0.2),{BackgroundTransparency=1}):Play()
                task.wait(0.22) n:Destroy()
            end
        end)
    end

    return tab
end

-- ── public ─────────────────────────────────────────────────────────────────────
function ZyrixUI:Open()
    buildShell()
end

function ZyrixUI:Close()
    if _sg then _sg:Destroy(); _sg=nil end
end

function ZyrixUI:Toggle()
    if _tablist then _tablist.Visible = not _tablist.Visible end
end

-- expose globally
getgenv().ZyrixUI = ZyrixUI


-- ══════════════════════════════════════════════════════════════════════════════
--  KEY SYSTEM FILES / HELPERS
-- ══════════════════════════════════════════════════════════════════════════════
local function hasFS()
    return type(writefile)=="function" and type(readfile)=="function"
        and type(isfile)=="function"   and type(makefolder)=="function"
        and type(isfolder)=="function"
end
local FS = hasFS()
local FOLDER = "Zyrix"
local function getKeyFile(name) return FOLDER.."/"..name..".txt" end
local function saveKey(name,key)
    if not FS then return end
    pcall(function() if not isfolder(FOLDER) then makefolder(FOLDER) end end)
    pcall(writefile, getKeyFile(name), key)
end
local function loadKey(name)
    if not FS then return nil end
    local ok,v=pcall(function() return isfile(getKeyFile(name)) and readfile(getKeyFile(name)) or nil end)
    return (ok and v and v~="") and v or nil
end
local function clearKey(name)
    if not FS then return end
    pcall(delfile, getKeyFile(name))
end

-- fallback icon downloads
local IconFallback = {
    key      = "rbxassetid://96510194465420",
    shield   = "rbxassetid://89965059528921",
    check    = "rbxassetid://76078495178149",
    copy     = "rbxassetid://125851897718493",
    discord  = "rbxassetid://83278450537116",
    alert    = "rbxassetid://140438367956051",
    lock     = "rbxassetid://114355063515473",
    loading  = "rbxassetid://116535712789945",
    close    = "rbxassetid://6022668916",
    user     = "rbxassetid://77400125196692",
    logo     = "rbxassetid://105436073524298",
}
local function icon(name) return IconFallback[name] or "" end

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

local function formatTime()
    local h=tonumber(os.date("%H"))
    local p=h>=12 and "PM" or "AM"
    h=h>12 and h-12 or (h==0 and 12 or h)
    return string.format("%d:%s:%s %s",h,os.date("%M"),os.date("%S"),p)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  ZYRIX (KEY SYSTEM MODULE)
-- ══════════════════════════════════════════════════════════════════════════════
local Zyrix = {}

Zyrix.Appearance = {
    Title    = "Zyrix",
    Subtitle = "Enter your key to continue",
    Icon     = "rbxassetid://105436073524298",
    IconSize = UDim2.new(0,28,0,28),
}
Zyrix.Links     = {GetKey="", Discord=""}
Zyrix.Storage   = {FileName="Zyrix_Key", Remember=true, AutoLoad=true}
Zyrix.Options   = {Blur=true, Draggable=true}
Zyrix.Theme     = {
    Accent=Color3.fromRGB(255,255,255), AccentHover=Color3.fromRGB(200,200,200),
    Background=Color3.fromRGB(8,8,8),  Header=Color3.fromRGB(14,14,14),
    Input=Color3.fromRGB(20,20,20),    Text=Color3.fromRGB(255,255,255),
    TextDim=Color3.fromRGB(100,100,100), Success=Color3.fromRGB(180,255,180),
    Error=Color3.fromRGB(255,100,100), StatusIdle=Color3.fromRGB(70,70,70),
    Divider=Color3.fromRGB(28,28,28),  Discord=Color3.fromRGB(180,180,255),
}
Zyrix.Callbacks = {OnVerify=nil, OnSuccess=nil, OnFail=nil, OnClose=nil}
Zyrix.Changelog = {}

local T = Zyrix.Theme

-- blur
local function enableBlur()
    if not Zyrix.Options.Blur then return end
    local b=Instance.new("BlurEffect")
    b.Name="ZyrixBlur" b.Size=0 b.Parent=LP
    tw(b,0.4,{Size=20})
end
local function disableBlur()
    local b=LP:FindFirstChild("ZyrixBlur")
    if not b then return end
    tw(b,0.3,{Size=0})
    task.delay(0.3,function() if b and b.Parent then b:Destroy() end end)
end

-- notifications
local _notifs = {}
function Zyrix:Notify(title,msg,dur,itype)
    dur=dur or 4
    local W,H=290,70
    local ng=Instance.new("ScreenGui")
    ng.ResetOnSpawn=false ng.DisplayOrder=999 ng.Parent=hui

    local f=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(1,W+10,1,-12),AnchorPoint=Vector2.new(1,1),BackgroundColor3=T.Header,Parent=ng})
    applyCorner(f,UDim.new(0,6)) applyStroke(f,T.Accent,1,0.85)

    local iconMap={success={icon("check"),T.Success},error={icon("alert"),T.Error},warning={icon("alert"),T.TextDim},info={icon("shield"),T.Accent},copy={icon("copy"),T.Success},discord={icon("discord"),T.Discord},close={icon("close"),T.Error}}
    local im=iconMap[itype or "info"] or iconMap["info"]
    mkImage({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,12,0.5,-1),AnchorPoint=Vector2.new(0,0.5),Image=im[1],ImageColor3=im[2],Parent=f})
    mkLabel({Size=UDim2.new(1,-56,0,20),Position=UDim2.new(0,44,0,10),Text=title,TextColor3=T.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    mkLabel({Size=UDim2.new(1,-56,0,16),Position=UDim2.new(0,44,0,32),Text=msg,TextColor3=T.TextDim,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})

    local pb=mkFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.BG4,Parent=f})
    applyCorner(pb,UDim.new(1,0))
    local pf=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,Parent=pb})
    applyCorner(pf,UDim.new(1,0))

    local id=tostring(tick())
    table.insert(_notifs,{id=id,f=f,gui=ng,h=H})

    local function restack()
        local y=0
        for i=#_notifs,1,-1 do
            local n=_notifs[i]
            if n and n.f and n.f.Parent then
                tw(n.f,0.25,{Position=UDim2.new(1,-12,1,-12-y)})
                y=y+n.h+8
            end
        end
    end
    local function dismiss()
        for i,n in ipairs(_notifs) do if n.id==id then table.remove(_notifs,i) break end end
        tw(f,0.25,{Position=UDim2.new(1,W+10,f.Position.Y.Scale,f.Position.Y.Offset)})
        task.wait(0.28) ng:Destroy() restack()
    end

    tw(f,0.3,{Position=UDim2.new(1,-12,1,-12)})
    task.wait(0.05) restack()
    TS:Create(pf,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(dur,dismiss)
    local cb2=mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=f})
    cb2.MouseButton1Click:Connect(dismiss)
end

-- key validation
local function validateKey(key,fn)
    if not fn or not key or key=="" then return false end
    local ok,r=pcall(fn,key)
    if not ok then return false end
    if type(r)=="table" then return r.valid==true end
    if type(r)=="boolean" then return r end
    return false
end

-- background
local function buildBackground()
    local ex=hui:FindFirstChild("ZyrixBackground")
    if ex then ex:Destroy() end

    local bg=Instance.new("ScreenGui")
    bg.Name="ZyrixBackground" bg.ResetOnSpawn=false
    bg.IgnoreGuiInset=true bg.DisplayOrder=-10 bg.Parent=hui

    local canvas=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(4,4,4),BackgroundTransparency=1,Parent=bg})

    local vp=WS.CurrentCamera.ViewportSize
    local cell=55
    local cols=math.ceil(vp.X/cell)+2
    local rows=math.ceil(vp.Y/cell)+2
    local grid=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,Parent=canvas})
    for i=0,cols do mkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(0,i*cell,0,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid}) end
    for i=0,rows do mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,i*cell),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid}) end

    local offset=0
    RS.Heartbeat:Connect(function(dt)
        if not grid or not grid.Parent then return end
        offset=(offset+dt*5)%cell
        grid.Position=UDim2.new(0,-offset,0,-offset)
    end)

    -- particles
    local pc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,Parent=canvas})
    local function spawnParticle(instant)
        local sz=math.random(2,4)
        local px=math.random(0,100)/100
        local py=instant and math.random(0,100)/100 or 1.05
        local spd=math.random(20,50)
        local drift=(math.random(-20,20))/1000
        local p=mkFrame({Size=UDim2.new(0,sz,0,sz),Position=UDim2.new(px,0,py,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.6+math.random()*0.3,ZIndex=2,Parent=pc})
        applyCorner(p,UDim.new(1,0))
        local conn2
        conn2=RS.Heartbeat:Connect(function(dt)
            if not p or not p.Parent then if conn2 then conn2:Disconnect() end return end
            py=py-dt/spd; px=px+drift*dt
            p.Position=UDim2.new(px,0,py,0)
            local fade=math.clamp(py*5,0,1)*math.clamp((1-py)*5,0,1)
            p.BackgroundTransparency=1-(1-(0.6+math.random()*0.1))*fade
            if py<-0.05 then
                conn2:Disconnect() p:Destroy()
                task.delay(math.random(1,3),function() spawnParticle(false) end)
            end
        end)
    end
    for i=1,22 do task.delay(i*0.1,function() spawnParticle(true) end) end

    -- watermark
    local wm=mkFrame({Size=UDim2.new(0,120,0,34),Position=UDim2.new(0,12,0,8),BackgroundColor3=Color3.fromRGB(10,10,10),BackgroundTransparency=0.35,ZIndex=5,Parent=canvas})
    applyCorner(wm,UDim.new(0,6)) applyStroke(wm,Color3.fromRGB(40,40,40),1,0)
    mkImage({Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,8,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,ZIndex=6,Parent=wm})
    mkLabel({Size=UDim2.new(1,-32,1,0),Position=UDim2.new(0,30,0,0),Text=Zyrix.Appearance.Title,TextColor3=Color3.new(1,1,1),TextSize=14,ZIndex=6,Parent=wm})

    -- status bar
    local sb=mkFrame({Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-26),BackgroundColor3=Color3.fromRGB(8,8,8),BackgroundTransparency=0.25,ZIndex=5,Parent=canvas})
    mkFrame({Size=UDim2.new(1,0,0,1),BackgroundColor3=Color3.fromRGB(40,40,40),ZIndex=6,Parent=sb})
    mkLabel({Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),Text="AUTHENTICATION REQUIRED",TextColor3=Color3.fromRGB(80,80,80),TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,Parent=sb})
    local clk=mkLabel({Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,-12,0,0),Text=formatTime(),TextColor3=Color3.fromRGB(80,80,80),TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=6,Parent=sb})
    task.spawn(function() while clk and clk.Parent do clk.Text=formatTime() task.wait(1) end end)

    tw(canvas,0.5,{BackgroundTransparency=0})
    return bg
end

local function removeBackground()
    local bg=hui:FindFirstChild("ZyrixBackground")
    if not bg then return end
    local c=bg:FindFirstChildOfClass("Frame")
    if c then tw(c,0.4,{BackgroundTransparency=1}) end
    task.delay(0.45,function() if bg and bg.Parent then bg:Destroy() end end)
end

-- key UI
local function buildKeyUI()
    local old=hui:FindFirstChild("ZyrixKeySystem")
    if old then old:Destroy() end

    enableBlur()
    local mobile=isMobile()
    local W,H=380,330

    local sg=Instance.new("ScreenGui")
    sg.Name="ZyrixKeySystem" sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true sg.DisplayOrder=10 sg.Parent=hui

    local cont=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,0,1.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Parent=sg})

    local main=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Background,Parent=cont})
    applyCorner(main,UDim.new(0,8)) applyStroke(main,T.Accent,1,0.85)

    -- header
    local hdr=mkFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,Parent=main})
    applyCorner(hdr,UDim.new(0,8))
    mkFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,Parent=hdr})
    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,Parent=hdr})
    mkImage({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,Parent=hdr})
    mkLabel({Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Title,TextColor3=T.Text,TextSize=18,TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})

    local closeBtn=mkButton({Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,Parent=hdr})
    mkImage({Size=UDim2.new(1,0,1,0),Image=icon("close"),ImageColor3=T.TextDim,Parent=closeBtn})
    closeBtn.MouseEnter:Connect(function() tw(closeBtn:FindFirstChildOfClass("ImageLabel"),0.12,{ImageColor3=T.Error}) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn:FindFirstChildOfClass("ImageLabel"),0.12,{ImageColor3=T.TextDim}) end)

    -- status box
    local statBox=mkFrame({Size=UDim2.new(0.92,0,0,54),Position=UDim2.new(0.5,0,0,58),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    applyCorner(statBox,UDim.new(0,6)) applyStroke(statBox,T.Accent,1,0.9)
    local statIcon=mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=icon("lock"),ImageColor3=T.StatusIdle,Parent=statBox})
    local statLbl=mkLabel({Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Subtitle,TextColor3=T.StatusIdle,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,Parent=statBox})

    -- input
    local inputBox=mkFrame({Size=UDim2.new(0.92,0,0,46),Position=UDim2.new(0.5,0,0,122),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    applyCorner(inputBox,UDim.new(0,6))
    local inputStr=applyStroke(inputBox,T.Accent,1,0.85)
    mkImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=icon("key"),ImageColor3=T.TextDim,Parent=inputBox})
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-38,1,0); tb.Position=UDim2.new(0,30,0,0)
    tb.BackgroundTransparency=1; tb.Text=""
    tb.PlaceholderText="Enter your key..."; tb.PlaceholderColor3=T.TextDim
    tb.TextColor3=T.Text; tb.TextSize=14; tb.Font=Enum.Font.Gotham
    tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.Parent=inputBox
    tb.Focused:Connect(function() tw(inputStr,0.12,{Transparency=0.4}) end)
    tb.FocusLost:Connect(function() tw(inputStr,0.12,{Transparency=0.85}) end)

    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,178),BackgroundColor3=T.Divider,Parent=main})

    -- buttons
    local function actionBtn(label2,ico,primary,y)
        local b=mkButton({Size=UDim2.new(0.78,0,0,38),Position=UDim2.new(0.5,0,0,y),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=primary and T.Accent or T.Input,Parent=main})
        applyCorner(b,UDim.new(0,6)) applyStroke(b,primary and T.AccentHover or T.Accent,1,primary and 0.7 or 0.88)
        local fc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=b})
        local fl=Instance.new("UIListLayout",fc) fl.FillDirection=Enum.FillDirection.Horizontal fl.HorizontalAlignment=Enum.HorizontalAlignment.Center fl.VerticalAlignment=Enum.VerticalAlignment.Center fl.Padding=UDim.new(0,7)
        mkImage({Size=UDim2.new(0,14,0,14),Image=icon(ico),ImageColor3=primary and T.Background or T.Text,LayoutOrder=1,Parent=fc})
        mkLabel({Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Text=label2,TextColor3=primary and T.Background or T.Text,TextSize=13,LayoutOrder=2,Parent=fc})
        b.MouseEnter:Connect(function() tw(b,0.12,{BackgroundColor3=primary and T.AccentHover or Color3.fromRGB(30,30,30)}) end)
        b.MouseLeave:Connect(function() tw(b,0.12,{BackgroundColor3=primary and T.Accent or T.Input}) end)
        return b
    end

    local getKeyBtn = actionBtn("Get Key",    "key",    false, 190)
    local redeemBtn = actionBtn("Redeem Key", "shield", true,  234)

    -- icon row
    local function iconBtn(ico,x,nc,hc)
        local b=mkButton({Size=UDim2.new(0,32,0,32),Position=UDim2.new(0.5,x,0,280),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
        applyCorner(b,UDim.new(0,6)) applyStroke(b,T.Accent,1,0.9)
        local im2=mkImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Image=icon(ico),ImageColor3=nc,Parent=b})
        b.MouseEnter:Connect(function() tw(im2,0.12,{ImageColor3=hc}) end)
        b.MouseLeave:Connect(function() tw(im2,0.12,{ImageColor3=nc}) end)
        return b,im2
    end
    local discordBtn,_ = iconBtn("discord",-22, T.TextDim, Color3.fromRGB(180,180,255))
    local keyLinkBtn,_ = iconBtn("key",     22, T.TextDim, T.Accent)

    -- status helper
    local spinConn,dotThread
    local function setStatus(state,custom)
        if spinConn then spinConn:Disconnect(); spinConn=nil; statIcon.Rotation=0 end
        if dotThread then task.cancel(dotThread); dotThread=nil end
        local col,ic,txt=T.StatusIdle,icon("lock"),custom or "No key detected"
        if state=="verifying" then
            col,ic,txt=T.Accent,icon("loading"),"Verifying key"
            spinConn=RS.Heartbeat:Connect(function(dt)
                if statIcon and statIcon.Parent then statIcon.Rotation=(statIcon.Rotation+dt*360)%360 end
            end)
            local dots,di={".","..","...",""},1
            dotThread=task.spawn(function()
                while statLbl and statLbl.Parent and statLbl.Text:find("Verifying",1,true) do
                    statLbl.Text="Verifying key"..dots[di]; di=(di%4)+1; task.wait(0.35)
                end
            end)
        elseif state=="success" then col,ic,txt=T.Success,icon("check"),custom or "Access Granted"
        elseif state=="error"   then col,ic,txt=T.Error,  icon("alert"),custom or "Invalid Key" end
        tw(statLbl,0.2,{TextColor3=col}); tw(statIcon,0.2,{ImageColor3=col})
        statLbl.Text=txt; statIcon.Image=ic
    end

    local function closeAndClean(cb)
        disableBlur()
        tw(cont,0.3,{Position=UDim2.new(0.5,0,-0.6,0)})
        tw(main,0.2,{BackgroundTransparency=1})
        task.wait(0.32)
        sg:Destroy()
        if cb then cb() end
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        closeAndClean(function()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
            removeBackground()
        end)
    end)

    local function handleRedeem()
        local key=tb.Text:gsub("%s+","")
        if key=="" then Zyrix:Notify("Error","Please enter a key",3,"error") return end
        setStatus("verifying"); redeemBtn.Active=false; task.wait(0.3)
        local valid,errMsg=false,"Invalid key"
        if Zyrix.Callbacks.OnVerify then
            local ok,res=pcall(Zyrix.Callbacks.OnVerify,key)
            if ok then
                if type(res)=="boolean" then valid=res
                elseif type(res)=="table" then valid=res.valid==true; errMsg=res.message or errMsg end
            end
        end
        redeemBtn.Active=true
        if valid then
            if Zyrix.Storage.Remember then saveKey(Zyrix.Storage.FileName,key) end
            getgenv().__ZyrixKey=key
            setStatus("success"); Zyrix:Notify("Success","Key validated!",2,"success")
            task.wait(0.8)
            closeAndClean(function()
                removeBackground()
                if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
            end)
        else
            setStatus("error",errMsg); Zyrix:Notify("Invalid",errMsg,4,"error")
            if Zyrix.Callbacks.OnFail then Zyrix.Callbacks.OnFail(errMsg) end
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)
    tb.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)
    getKeyBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.GetKey~="" then pcall(setclipboard,Zyrix.Links.GetKey); Zyrix:Notify("Copied","Key link copied",2,"copy")
        else Zyrix:Notify("Error","No key link set",3,"error") end
    end)
    discordBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord~="" then pcall(setclipboard,Zyrix.Links.Discord); Zyrix:Notify("Discord","Invite copied",2,"discord") end
    end)

    if Zyrix.Options.Draggable then draggable(hdr,cont) end

    -- entrance
    tw(cont,0.4,{Position=UDim2.new(0.5,0,0.48,0)},Enum.EasingStyle.Back)
end

function Zyrix:Launch()
    local existKey = getgenv().__ZyrixKey
    if existKey and existKey~="" then
        if validateKey(existKey, self.Callbacks.OnVerify) then
            self:Notify("Welcome Back","Key still valid",2,"success")
            if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end
            return
        end
        getgenv().__ZyrixKey=nil
    end

    if self.Storage.AutoLoad and self.Callbacks.OnVerify then
        local saved=loadKey(self.Storage.FileName)
        if saved then
            self:Notify("Checking","Validating saved key...",2,"info")
            task.wait(0.4)
            if validateKey(saved, self.Callbacks.OnVerify) then
                getgenv().__ZyrixKey=saved
                self:Notify("Welcome Back","Key validated!",2,"success")
                if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end
                return
            else
                clearKey(self.Storage.FileName)
                self:Notify("Expired","Saved key expired",3,"error")
                task.wait(0.6)
            end
        end
    end

    buildBackground()
    buildKeyUI()
end

function Zyrix:GetSavedKey()   return loadKey(self.Storage.FileName) end
function Zyrix:ClearSavedKey() clearKey(self.Storage.FileName) end

getgenv().__ZyrixLib = Zyrix
getgenv().ZyrixUI    = ZyrixUI

return Zyrix
