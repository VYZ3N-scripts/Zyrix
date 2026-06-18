--[[
    Zyrix v4 — Key System + GUI Library
    Exact G2L layout. Z-logo toggles TabList with smooth animation.
    UICorner radius 12 on main window. Gap between TabList and main.
    All elements visible, no overlaps, no clipping bugs.
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end

local TS  = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS  = cloneref(game:GetService("RunService"))
local LP2 = cloneref(game:GetService("Lighting"))
local PLR = cloneref(game:GetService("Players"))
local WS  = cloneref(game:GetService("Workspace"))

local hui = gethui()
if getgenv().__ZyrixActive then return getgenv().__ZyrixLib end
getgenv().__ZyrixActive = true

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ── Palette (from new G2L) ────────────────────────────────────────────────────
local C = {
    -- Main window gradient: black → RGB(29,29,29)
    WIN_FROM  = Color3.fromRGB(0,   0,   0),
    WIN_TO    = Color3.fromRGB(29,  29,  29),
    -- Tab bar gradient same
    TAB_FROM  = Color3.fromRGB(0,   0,   0),
    TAB_TO    = Color3.fromRGB(29,  29,  29),
    -- Element bg
    EL        = Color3.fromRGB(23,  23,  23),
    -- Slider/switch inner
    INNER     = Color3.fromRGB(31,  31,  31),
    -- Progress/indicator colour
    PROGRESS  = Color3.fromRGB(201, 201, 201),
    -- Dropdown list bg
    DD_BG     = Color3.fromRGB(19,  19,  19),
    DD_ROW    = Color3.fromRGB(27,  27,  27),
    -- Strokes
    STROKE_EL = Color3.fromRGB(41,  41,  41),
    STROKE_IN = Color3.fromRGB(51,  51,  51),
    STROKE_WIN= Color3.fromRGB(36,  36,  36),
    -- Text colours
    TEXT      = Color3.fromRGB(231, 231, 231),
    TEXT_DIM  = Color3.fromRGB(181, 181, 181),
    TEXT_GREY = Color3.fromRGB(131, 131, 131),
    WHITE     = Color3.fromRGB(255, 255, 255),
    -- Toggle on
    GREEN1    = Color3.fromRGB(0,   171, 0),
    GREEN2    = Color3.fromRGB(0,   121, 0),
    -- Misc
    SUCCESS   = Color3.fromRGB(100, 220, 100),
    ERROR     = Color3.fromRGB(255, 80,  80),
}

local FONT_B = Font.new("rbxasset://fonts/families/GothamSSm.json",    Enum.FontWeight.Bold,   Enum.FontStyle.Normal)
local FONT_M = Font.new("rbxasset://fonts/families/GothamSSm.json",    Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local FONT_R = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular,Enum.FontStyle.Normal)

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function tw(obj, t, props, style)
    TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 4); return c
end

local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.STROKE_EL; s.Thickness = thick or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s
end

local function mkGradient(p, from, to, rot)
    local g = Instance.new("UIGradient", p)
    g.Color    = ColorSequence.new(from, to)
    g.Rotation = rot or 0; return g
end

local function mkPad(p, t, b, l, r)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop=UDim.new(0,t or 0); pad.PaddingBottom=UDim.new(0,b or 0)
    pad.PaddingLeft=UDim.new(0,l or 0); pad.PaddingRight=UDim.new(0,r or 0)
end

local function mkList(p, spacing, dir)
    local l = Instance.new("UIListLayout", p)
    l.Padding=UDim.new(0,spacing or 5); l.SortOrder=Enum.SortOrder.LayoutOrder
    l.FillDirection=dir or Enum.FillDirection.Vertical; return l
end

local function mkFrame(props)
    local f = Instance.new("Frame"); f.BorderSizePixel=0
    for k,v in pairs(props) do f[k]=v end; return f
end

local function mkLabel(props)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency=1
    for k,v in pairs(props) do l[k]=v end; return l
end

local function mkBtn(props)
    local b = Instance.new("TextButton"); b.AutoButtonColor=false
    b.Text=""; b.BorderSizePixel=0
    for k,v in pairs(props) do b[k]=v end; return b
end

local function mkImage(props)
    local i = Instance.new("ImageLabel"); i.BackgroundTransparency=1
    i.ScaleType=Enum.ScaleType.Fit
    for k,v in pairs(props) do i[k]=v end; return i
end

local function mkScroll(parent, size, pos)
    local sf = Instance.new("ScrollingFrame")
    sf.Size=size or UDim2.new(1,0,1,0); sf.Position=pos or UDim2.new(0,0,0,0)
    sf.BackgroundTransparency=1; sf.BorderSizePixel=0
    sf.ScrollBarThickness=2; sf.ScrollBarImageColor3=Color3.fromRGB(141,141,141)
    sf.ScrollBarImageTransparency=0.3
    sf.CanvasSize=UDim2.new(0,0,0,0); sf.AutomaticCanvasSize=Enum.AutomaticSize.Y
    sf.Parent=parent; return sf
end

local function draggable(handle, root)
    local drag,ds,dp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; dp=root.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then drag=false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            root.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  ZyrixUI
--  Layout (pixel exact from new G2L):
--    Outer container (no clip, just positions children)
--      ├─ TabFrame  (G2L["3d"])  — pill tab bar, height ~5% screen
--      │    └─ tablistSF (G2L["3e"])  — horizontal scroll, pill buttons
--      └─ MainFrame (G2L["2"])   — main content window, positioned below TabFrame with a gap
--           ├─ Header row  (logo + title text)
--           ├─ Separator line
--           └─ elementsSF (G2L["7"]) — vertical scrolling content
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixUI = {}

-- Fixed pixel sizes (matching G2L proportions at 1920×1080 equivalent)
local WIN_W        = 563   -- main window width
local WIN_H        = 354   -- main window height
local TAB_H        = 42    -- tab bar height
local GAP          = 8     -- gap between tab bar and main window (prevents overlap)
local HDR_H        = 37    -- header row height inside main window
local SEP_Y        = HDR_H -- separator Y position
local EL_X_OFF     = 6     -- elements scroll X offset (0.00979 * WIN_W ≈ 6)
local EL_Y_OFF     = HDR_H + 1  -- elements scroll starts just below separator
local EL_W         = WIN_W - 2*EL_X_OFF  -- ≈ 546
local EL_H         = WIN_H - EL_Y_OFF - 4
local TOTAL_H      = TAB_H + GAP + WIN_H  -- full container height when open

-- State
local _sg          = nil
local _outerFrame  = nil  -- invisible positioning root
local _tabFrame    = nil  -- G2L["3d"] pill bar frame
local _tabSF       = nil  -- G2L["3e"] horizontal scroll inside pill bar
local _mainFrame   = nil  -- G2L["2"] main window
local _elementsSF  = nil  -- G2L["7"] content scroll
local _tabBtns     = {}
local _tabPanels   = {}
local _activeTab   = nil
local _tabLO       = 0
local _tlOpen      = true

-- ── Tab switch ────────────────────────────────────────────────────────────────
local function switchTab(name)
    if _activeTab == name then return end
    _activeTab = name
    for n, b in pairs(_tabBtns) do
        local on = n == name
        -- active: white text + white gradient; inactive: dimmed + dark gradient
        b.TextColor3 = on and C.WHITE or Color3.fromRGB(201,201,201)
        local g = b:FindFirstChildOfClass("UIGradient")
        if g then
            g.Color = ColorSequence.new(C.TAB_FROM, C.TAB_TO)
        end
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then
            s.Color = on and Color3.fromRGB(80,80,80) or C.STROKE_IN
            s.Transparency = on and 0 or 0.3
        end
    end
    for n, p in pairs(_tabPanels) do
        p.Visible = n == name
    end
end

-- ── TabList toggle (smooth slide + fade) ──────────────────────────────────────
local function toggleTablist(logoBtn)
    _tlOpen = not _tlOpen
    if _tlOpen then
        -- open: expand outer, slide main down into view
        _mainFrame.Visible = true
        tw(_outerFrame, 0.30, {Size=UDim2.new(0,WIN_W,0,TOTAL_H)}, Enum.EasingStyle.Quart)
        tw(_mainFrame,  0.30, {Position=UDim2.new(0,0,0,TAB_H+GAP), BackgroundTransparency=0}, Enum.EasingStyle.Quart)
        tw(logoBtn, 0.18, {ImageColor3=C.TEXT})
    else
        -- close: shrink outer, slide main up
        tw(_outerFrame, 0.26, {Size=UDim2.new(0,WIN_W,0,TAB_H)}, Enum.EasingStyle.Quart)
        tw(_mainFrame,  0.22, {BackgroundTransparency=1}, Enum.EasingStyle.Quart)
        tw(logoBtn, 0.18, {ImageColor3=Color3.fromRGB(231,231,231)})
        task.delay(0.24, function()
            if not _tlOpen and _mainFrame then _mainFrame.Visible=false end
        end)
    end
end

-- ── Build shell ───────────────────────────────────────────────────────────────
local function buildShell()
    if _sg then _sg:Destroy() end
    _tabBtns={}; _tabPanels={}; _activeTab=nil; _tabLO=0; _tlOpen=true

    _sg = Instance.new("ScreenGui")
    _sg.Name="ZyrixMainUI"; _sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    _sg.ResetOnSpawn=false; _sg.IgnoreGuiInset=true; _sg.DisplayOrder=50
    _sg.Parent=hui

    -- ── Outer positioning frame ───────────────────────────────────────────────
    -- Not clipping — we let the tab bar and main window be siblings so
    -- they never clip each other. The outer just anchors them together.
    local outer = mkFrame({
        Name="ZyrixOuter",
        Size=UDim2.new(0,WIN_W,0,TOTAL_H),
        Position=UDim2.new(0.5,-WIN_W/2, 0.5,-TOTAL_H/2),
        BackgroundTransparency=1,
        Parent=_sg,
    })
    _outerFrame = outer

    -- ── G2L["3d"] Tab bar frame ───────────────────────────────────────────────
    local tabFrame = mkFrame({
        Name="TabFrame",
        Size=UDim2.new(0,WIN_W,0,TAB_H),
        Position=UDim2.new(0,0,0,0),
        BackgroundColor3=C.WIN_FROM,
        Parent=outer,
    })
    mkCorner(tabFrame, UDim.new(0,1000))  -- fully pill-shaped (G2L["4b"])
    mkStroke(tabFrame, C.STROKE_WIN, 0.5)
    mkGradient(tabFrame, C.TAB_FROM, C.TAB_TO)
    _tabFrame = tabFrame

    -- Z logo / toggle button (G2L["4"] reimagined as the toggle)
    local logoBtn = Instance.new("ImageButton", tabFrame)
    logoBtn.Name="LogoBtn"; logoBtn.BorderSizePixel=0
    logoBtn.BackgroundTransparency=1
    logoBtn.ImageColor3=C.TEXT
    logoBtn.Image="rbxassetid://105436073524298"
    logoBtn.Size=UDim2.new(0,22,0,26)
    logoBtn.Position=UDim2.new(0,8,0.5,0); logoBtn.AnchorPoint=Vector2.new(0,0.5)

    -- Hover pulse on logo
    logoBtn.MouseEnter:Connect(function() tw(logoBtn,0.12,{ImageColor3=C.WHITE}) end)
    logoBtn.MouseLeave:Connect(function()
        tw(logoBtn,0.12,{ImageColor3=_tlOpen and C.TEXT or Color3.fromRGB(100,100,100)})
    end)
    logoBtn.MouseButton1Click:Connect(function() toggleTablist(logoBtn) end)

    -- G2L["3e"] Horizontal pill scroll (tab buttons live here)
    local tabSF = Instance.new("ScrollingFrame", tabFrame)
    tabSF.Name="tablist"; tabSF.Active=true
    tabSF.ScrollingDirection=Enum.ScrollingDirection.X
    tabSF.BorderSizePixel=0
    tabSF.VerticalScrollBarInset=Enum.ScrollBarInset.Always
    tabSF.ElasticBehavior=Enum.ElasticBehavior.Always
    tabSF.BackgroundTransparency=1
    tabSF.Size=UDim2.new(1,-(32+6),1,0)
    tabSF.Position=UDim2.new(0,32+4,0,0)
    tabSF.ScrollBarImageColor3=Color3.fromRGB(141,141,141)
    tabSF.ScrollBarThickness=0
    tabSF.CanvasSize=UDim2.new(0,0,0,0); tabSF.AutomaticCanvasSize=Enum.AutomaticSize.X
    mkCorner(tabSF, UDim.new(0,100))
    mkPad(tabSF,3,3,4,4)
    local tl = mkList(tabSF, 4, Enum.FillDirection.Horizontal)
    tl.VerticalAlignment=Enum.VerticalAlignment.Center
    _tabSF = tabSF

    draggable(tabFrame, outer)

    -- ── G2L["2"] Main window ──────────────────────────────────────────────────
    -- Positioned below tab bar with a GAP so they never overlap
    local mainFrame = mkFrame({
        Name="main",
        Size=UDim2.new(0,WIN_W,0,WIN_H),
        Position=UDim2.new(0,0,0,TAB_H+GAP),  -- clear gap below tab bar
        BackgroundColor3=C.WIN_FROM,
        Parent=outer,
    })
    mkCorner(mainFrame, UDim.new(0,12))   -- ← UICorner radius 12 as requested
    mkStroke(mainFrame, C.STROKE_WIN, 0.5)
    mkGradient(mainFrame, C.WIN_FROM, C.WIN_TO)
    _mainFrame = mainFrame

    -- Title area inside main (G2L["3"] + G2L["4"])
    mkImage({
        Size=UDim2.new(0,24,0,28),
        Position=UDim2.new(0,5,0,5), AnchorPoint=Vector2.new(0,0),
        Image="rbxassetid://105436073524298", ImageColor3=Color3.fromRGB(231,231,231),
        Parent=mainFrame,
    })
    mkLabel({
        Size=UDim2.new(0.85258,0,0,22),
        Position=UDim2.new(0.05684,0,0,6),
        Text="zyrix", TextColor3=C.TEXT, TextSize=15,
        FontFace=FONT_B, TextXAlignment=Enum.TextXAlignment.Left,
        Parent=mainFrame,
    })

    -- Separator (G2L["5"] gradient bar)
    local sep=mkFrame({
        Size=UDim2.new(1,0,0,1),
        Position=UDim2.new(0,0,0,SEP_Y),
        BackgroundColor3=Color3.fromRGB(6,6,6),
        Parent=mainFrame,
    })
    -- G2L["6"] gradient on separator
    local sepG=Instance.new("UIGradient",sep)
    sepG.Color=ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.415,Color3.fromRGB(6,6,6)),
        ColorSequenceKeypoint.new(0.637,Color3.fromRGB(34,34,34)),
        ColorSequenceKeypoint.new(0.78, Color3.fromRGB(50,50,50)),
        ColorSequenceKeypoint.new(0.888,Color3.fromRGB(65,65,65)),
        ColorSequenceKeypoint.new(0.96, Color3.fromRGB(79,79,79)),
        ColorSequenceKeypoint.new(0.995,Color3.fromRGB(98,98,98)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(127,127,127)),
    }

    -- G2L["7"] Elements scroll
    local elements=mkScroll(mainFrame,
        UDim2.new(0,EL_W,0,EL_H),
        UDim2.new(0,EL_X_OFF,0,EL_Y_OFF))
    elements.Name="elements"
    mkPad(elements,6,6,8,8)
    mkList(elements,5)
    _elementsSF=elements

    -- Entrance animation (grow from tab bar height)
    outer.Size=UDim2.new(0,WIN_W,0,TAB_H)
    mainFrame.BackgroundTransparency=1; mainFrame.Visible=false
    task.delay(0.05,function()
        mainFrame.Visible=true
        tw(outer,0.32,{Size=UDim2.new(0,WIN_W,0,TOTAL_H)},Enum.EasingStyle.Back)
        tw(mainFrame,0.30,{BackgroundTransparency=0},Enum.EasingStyle.Quart)
    end)

    -- Keyboard toggle (PC only)
    if not isMobile then
        getgenv().__ZyrixToggleKey=getgenv().__ZyrixToggleKey or Enum.KeyCode.RightShift
        UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if i.KeyCode==getgenv().__ZyrixToggleKey and _sg then
                toggleTablist(logoBtn)
            end
        end)
    end
end

-- ── AddTab ────────────────────────────────────────────────────────────────────
function ZyrixUI:AddTab(name, icon)
    if not _sg then warn("[ZyrixUI] Call Open() first"); return {} end
    _tabLO=_tabLO+1

    -- Pill button (G2L["3f"/"44"] style)
    local pill=mkBtn({
        BorderSizePixel=0, TextSize=11,
        TextColor3=Color3.fromRGB(201,201,201),
        BackgroundColor3=C.WIN_FROM,
        FontFace=FONT_B,
        Size=UDim2.new(0,math.max(60,#name*7+20),0,math.floor(TAB_H*0.41)),
        Text=(icon and icon.." " or "")..name,
        LayoutOrder=_tabLO,
        Parent=_tabSF,
    })
    mkCorner(pill,UDim.new(0,100))
    mkStroke(pill,C.STROKE_IN,0.5)
    mkGradient(pill,C.TAB_FROM,C.TAB_TO)
    mkPad(pill,4,4,8,8)

    pill.MouseButton1Click:Connect(function()
        -- auto-open if closed
        if not _tlOpen then
            local logo=_tabFrame and _tabFrame:FindFirstChild("LogoBtn")
            if logo then toggleTablist(logo) end
        end
        switchTab(name)
    end)
    _tabBtns[name]=pill

    -- Content panel
    local panel=mkFrame({
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Visible=false,LayoutOrder=_tabLO,
        Parent=_elementsSF,
    })
    mkList(panel,5)
    _tabPanels[name]=panel

    if _tabLO==1 then switchTab(name) end

    -- ── Element builders ──────────────────────────────────────────────────────
    local lo=0
    local function nlo() lo=lo+1; return lo end

    -- Base element (matches G2L element frames: dark bg, stroke, padding)
    local function baseEl(h)
        local f=mkFrame({Size=UDim2.new(1,0,0,h),BackgroundColor3=C.EL,LayoutOrder=nlo(),Parent=panel})
        mkCorner(f,UDim.new(0,4))
        local s=mkStroke(f,C.STROKE_EL,0.5)
        -- gradient on stroke (matches G2L design — elements use solid, no gradient on stroke usually)
        mkPad(f,6,6,10,10)
        return f,s
    end

    local tab={}

    -- Section header
    function tab:Section(title)
        lo=lo+1
        local s=mkFrame({Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=lo,Parent=panel})
        mkLabel({Size=UDim2.new(1,0,1,0),Text=title:upper(),TextColor3=Color3.fromRGB(90,90,90),TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=s})
        mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.STROKE_EL,Parent=s})
    end

    -- Toggle (G2L["29"] exact)
    function tab:Toggle(title, desc, default, callback)
        local state=default or false
        local h=desc and 50 or 37
        local el,elStr=baseEl(h)

        -- Title label (G2L["2a"])
        mkLabel({TextWrapped=true,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.TEXT,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0.80307,0,0,14),Text=title,
            Position=UDim2.new(0.80346,0,desc and 0.3 or 0.5,0),
            Parent=el})
        if desc then
            mkLabel({Size=UDim2.new(0.75,0,0,12),Position=UDim2.new(0,0,1,-18),
                Text=desc,TextColor3=Color3.fromRGB(100,100,100),TextSize=10,
                Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        end

        -- Switch (G2L["2c"])
        local sw=mkFrame({BackgroundColor3=C.INNER,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0.1768,0,0,21),Position=UDim2.new(1.01129,0,0.5,0),Parent=el})
        mkCorner(sw,UDim.new(1,0))
        mkStroke(sw,C.STROKE_IN,0.5)

        -- Indicator dot (G2L["2d"])
        local dot=mkFrame({BackgroundColor3=state and C.WHITE or C.PROGRESS,
            AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0.42249,0,0,17),
            Position=UDim2.new(state and 1 or 0.0059,0,0.5,0),Parent=sw})
        mkCorner(dot,UDim.new(1,0))
        local ds=Instance.new("UIStroke",dot); ds.Thickness=0.5; ds.Color=Color3.fromRGB(61,61,61)

        -- Active stroke (green gradient when on)
        local function updateStyle()
            -- No gradient on stroke by default; green stroke when active
            elStr.Color = state and C.GREEN1 or C.STROKE_EL
        end
        updateStyle()

        -- Interact hit (G2L["2b"])
        local hit=mkBtn({ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.36935,0,1,0),Position=UDim2.new(0.81532,0,0.5,0),Parent=el})
        hit.MouseButton1Click:Connect(function()
            state=not state
            tw(dot,0.15,{Position=UDim2.new(state and 1 or 0.0059,0,0.5,0),
                BackgroundColor3=state and C.WHITE or C.PROGRESS})
            updateStyle()
            if callback then pcall(callback,state) end
        end)
        return {
            GetValue=function() return state end,
            SetValue=function(v)
                state=v
                dot.Position=UDim2.new(v and 1 or 0.0059,0,0.5,0)
                dot.BackgroundColor3=v and C.WHITE or C.PROGRESS
                updateStyle()
            end,
        }
    end

    -- Slider (G2L["1d"] exact)
    function tab:Slider(title, min, max, default, suffix, callback)
        if type(suffix)=="function" then callback=suffix; suffix="units" end
        suffix=suffix or "units"; min=min or 0; max=max or 100
        default=math.clamp(default or min,min,max)
        local value=default
        local el,_=baseEl(47)

        -- Title left (G2L["1e"])
        mkLabel({TextWrapped=true,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.TEXT,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.64246,0,0,14),Text=title,Position=UDim2.new(0.32525,0,0.5,0),Parent=el})

        -- Slider main box (G2L["1f"])
        local main=mkFrame({BackgroundColor3=C.INNER,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.71313,0,0,30),Position=UDim2.new(0.65419,0,0.5,0),Parent=el})
        local ms=Instance.new("UIStroke",main); ms.Transparency=0.2; ms.Color=C.STROKE_IN
        ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        mkCorner(main,UDim.new(0,4))

        -- Progress fill (G2L["21"])
        local prog=mkFrame({BackgroundColor3=C.PROGRESS,
            Size=UDim2.new((value-min)/(max-min),0,1,0),Parent=main})
        local ps=Instance.new("UIStroke",prog); ps.Transparency=0.2; ps.Thickness=0.5; ps.Color=C.STROKE_IN
        mkCorner(prog,UDim.new(0,4))

        -- Info label (G2L["24"])
        local info=mkLabel({ZIndex=5,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
            TextTransparency=0.3,FontFace=FONT_M,TextColor3=Color3.fromRGB(131,131,131),
            AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0.80871,0,0,14),
            Text=tostring(value).." "..suffix,Position=UDim2.new(0.4536,0,0.5,0),Parent=main})

        -- Interact (G2L["25"])
        local hit=mkBtn({ZIndex=10,Size=UDim2.new(1,0,1,0),Parent=main})
        local drag=false
        local function update(x)
            local rel=math.clamp((x-main.AbsolutePosition.X)/main.AbsoluteSize.X,0,1)
            value=math.floor(min+(max-min)*rel+0.5)
            prog.Size=UDim2.new((value-min)/(max-min),0,1,0)
            info.Text=tostring(value).." "..suffix
            if callback then pcall(callback,value) end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                drag=true; update(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not drag then return end
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

    -- Button (G2L["17"] exact)
    function tab:Button(title, callback)
        local el,_=baseEl(35)
        -- Title (G2L["19"])
        mkLabel({TextWrapped=true,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.TEXT,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.98617,0,0,14),Text=title,Position=UDim2.new(0.50604,0,0.47561,0),Parent=el})
        -- Indicator (G2L["1a"])
        mkLabel({TextWrapped=true,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,
            TextTransparency=0.5,FontFace=FONT_M,TextColor3=Color3.fromRGB(131,131,131),
            AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0.34693,0,0,13),Text="Button",
            Position=UDim2.new(0.77168,0,0.47561,0),Parent=el})
        -- Interact (G2L["1b"])
        local hit=mkBtn({ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),Parent=el})
        hit.MouseButton1Click:Connect(function()
            tw(el,0.07,{BackgroundColor3=Color3.fromRGB(32,32,32)})
            task.delay(0.12,function() tw(el,0.1,{BackgroundColor3=C.EL}) end)
            if callback then pcall(callback) end
        end)
    end

    -- Keybind (G2L["32"] exact)
    function tab:Keybind(title, default, callback)
        local key=default or Enum.KeyCode.Unknown
        local el,_=baseEl(37)

        -- Title (G2L["33"])
        mkLabel({TextWrapped=true,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.TEXT,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.63935,0,0,14),Text=title,Position=UDim2.new(0.31842,0,0.5,0),Parent=el})

        -- KeybindFrame (G2L["34"])
        local kbf=mkFrame({BackgroundColor3=C.INNER,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0.10436,0,1.0,0),Position=UDim2.new(1.01366,0,0.5,0),Parent=el})
        mkStroke(kbf,C.STROKE_IN,0.5)
        mkCorner(kbf,UDim.new(0,4))

        -- KeybindBox (G2L["35"])
        local kbBox=Instance.new("TextBox",kbf)
        kbBox.BorderSizePixel=0; kbBox.TextSize=12; kbBox.TextColor3=C.TEXT
        kbBox.BackgroundColor3=Color3.fromRGB(9,9,9); kbBox.BackgroundTransparency=1
        kbBox.FontFace=FONT_M; kbBox.AnchorPoint=Vector2.new(0.5,0.5)
        kbBox.ClearTextOnFocus=false; kbBox.PlaceholderText="Key"
        kbBox.PlaceholderColor3=Color3.fromRGB(179,179,179)
        kbBox.Size=UDim2.new(0.8,0,0,14); kbBox.Position=UDim2.new(0.5,0,0.5,0)
        kbBox.Text=tostring(key):gsub("Enum.KeyCode.","")

        local conn2
        kbBox.Focused:Connect(function()
            kbBox.Text="..."
            conn2=UIS.InputBegan:Connect(function(i,gp)
                if gp then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; kbBox.Text=tostring(key):gsub("Enum.KeyCode.","")
                    kbBox:ReleaseFocus()
                    if conn2 then conn2:Disconnect() end
                    if callback then pcall(callback,key) end
                end
            end)
        end)
        return {GetValue=function() return key end}
    end

    -- Dropdown (G2L["8"] exact)
    function tab:Dropdown(title, options, default, callback)
        local selected=default or (options and options[1]) or ""
        local isOpen=false; local ITEM_H=30
        local el,elStr=baseEl(37)
        el.ClipsDescendants=false; el.ZIndex=5

        -- Title (G2L["9"])
        mkLabel({TextWrapped=true,ZIndex=3,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.TEXT,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.99361,0,0,14),Text=title,Position=UDim2.new(0.48939,0,0.03386,0),Parent=el})

        -- Selected label (G2L["12"])
        local selLbl=mkLabel({TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,
            FontFace=FONT_M,TextColor3=Color3.fromRGB(181,181,181),AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.83048,0,0,14),Text=selected,Position=UDim2.new(0.36581,0,0.03386,0),Parent=el})

        -- Arrow
        local arrow=mkLabel({Size=UDim2.new(0,18,0,14),Position=UDim2.new(1,-20,0,10),
            Text="▾",TextColor3=Color3.fromRGB(161,161,161),TextSize=12,Font=Enum.Font.GothamBold,ZIndex=3,Parent=el})

        -- List scroll (G2L["a"])
        local listF=mkFrame({BackgroundColor3=C.DD_BG,
            Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,4),
            ClipsDescendants=true,ZIndex=10,Parent=el})
        mkStroke(listF,C.STROKE_EL,0.5)
        mkCorner(listF,UDim.new(0,4))

        local listSF=mkScroll(listF,UDim2.new(0.90463,0,1,0))
        listSF.ZIndex=11; listSF.BackgroundColor3=C.DD_BG
        listSF.BackgroundTransparency=1
        mkList(listSF,2)

        for _,opt in ipairs(options or {}) do
            -- Template row (G2L["c"] style)
            local row=mkFrame({BackgroundColor3=C.DD_ROW,Size=UDim2.new(1.02819,0,0,ITEM_H-2),Parent=listSF})
            local rs=Instance.new("UIStroke",row); rs.Color=Color3.fromRGB(51,51,51); rs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            mkCorner(row,UDim.new(0,4))
            -- Option label (G2L["d"])
            mkLabel({TextWrapped=true,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,FontFace=FONT_M,
                TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),ZIndex=12,
                Size=UDim2.new(1.04226,0,0,14),Text=opt,Position=UDim2.new(0.53226,0,0.49281,0),Parent=row})
            -- Interact (G2L["e"])
            local rh=mkBtn({ZIndex=5,Size=UDim2.new(1,0,1,0),Parent=row})
            rh.MouseEnter:Connect(function() tw(row,0.08,{BackgroundColor3=Color3.fromRGB(35,35,35)}) end)
            rh.MouseLeave:Connect(function() tw(row,0.08,{BackgroundColor3=C.DD_ROW}) end)
            rh.MouseButton1Click:Connect(function()
                selected=opt; selLbl.Text=opt; isOpen=false
                tw(arrow,0.12,{Rotation=0}); tw(listF,0.15,{Size=UDim2.new(1,0,0,0)})
                el.Size=UDim2.new(1,0,0,37)
                if callback then pcall(callback,opt) end
            end)
        end

        local maxH=ITEM_H*math.min(#(options or {}),5)+6
        -- Interact (G2L["14"])
        local hit=mkBtn({ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),Parent=el})
        hit.MouseButton1Click:Connect(function()
            isOpen=not isOpen
            if isOpen then
                tw(arrow,0.12,{Rotation=180}); tw(listF,0.15,{Size=UDim2.new(1,0,0,maxH)})
                el.Size=UDim2.new(1,0,0,37+maxH+4)
            else
                tw(arrow,0.12,{Rotation=0}); tw(listF,0.15,{Size=UDim2.new(1,0,0,0)})
                el.Size=UDim2.new(1,0,0,37)
            end
        end)
        return {GetValue=function() return selected end, SetValue=function(v) selected=v; selLbl.Text=v end}
    end

    -- TextBox
    function tab:TextBox(title, placeholder, default, callback)
        local el,_=baseEl(58)
        mkLabel({Size=UDim2.new(1,0,0,14),Text=title,TextColor3=C.TEXT,TextSize=13,
            FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        local ibg=mkFrame({Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,18),
            BackgroundColor3=C.INNER,Parent=el})
        mkCorner(ibg); local ibs=mkStroke(ibg,C.STROKE_IN)
        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-8,1,0); tb.Position=UDim2.new(0,4,0,0)
        tb.BackgroundTransparency=1; tb.Text=default or ""
        tb.PlaceholderText=placeholder or ""; tb.PlaceholderColor3=Color3.fromRGB(80,80,80)
        tb.TextColor3=C.TEXT; tb.TextSize=12; tb.FontFace=FONT_M
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.Focused:Connect(function() ibs.Color=Color3.fromRGB(120,120,120) end)
        tb.FocusLost:Connect(function(enter)
            ibs.Color=C.STROKE_IN
            if enter and callback then pcall(callback,tb.Text) end
        end)
        return {GetValue=function() return tb.Text end, SetValue=function(v) tb.Text=v end}
    end

    -- Script Executor (multiline, working execute + clear)
    function tab:Executor(placeholder)
        lo=lo+1
        local cont=mkFrame({Size=UDim2.new(1,0,0,130),BackgroundColor3=C.EL,LayoutOrder=lo,Parent=panel})
        mkCorner(cont); mkStroke(cont,C.STROKE_EL); mkPad(cont,6,6,10,10)
        mkLabel({Size=UDim2.new(1,0,0,14),Text="Script Executor",TextColor3=C.TEXT,
            TextSize=13,FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=cont})
        local ibg=mkFrame({Size=UDim2.new(1,0,0,76),Position=UDim2.new(0,0,0,18),
            BackgroundColor3=C.INNER,Parent=cont})
        mkCorner(ibg); mkStroke(ibg,C.STROKE_IN)
        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-8,1,-4); tb.Position=UDim2.new(0,4,0,2)
        tb.BackgroundTransparency=1; tb.Text=""
        tb.PlaceholderText=placeholder or "-- Enter script here..."
        tb.PlaceholderColor3=Color3.fromRGB(70,70,70)
        tb.TextColor3=Color3.fromRGB(220,220,220); tb.TextSize=11; tb.FontFace=FONT_M
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.TextYAlignment=Enum.TextYAlignment.Top; tb.MultiLine=true; tb.TextWrapped=true
        -- Run
        local runBtn=mkBtn({Size=UDim2.new(0.49,0,0,20),Position=UDim2.new(0,0,1,-22),
            AnchorPoint=Vector2.new(0,1),BackgroundColor3=C.INNER,
            TextColor3=C.TEXT,TextSize=11,FontFace=FONT_M,Text="▶  Execute",Parent=cont})
        mkCorner(runBtn); mkStroke(runBtn,C.STROKE_IN)
        -- Clear
        local clrBtn=mkBtn({Size=UDim2.new(0.49,0,0,20),Position=UDim2.new(1,0,1,-22),
            AnchorPoint=Vector2.new(1,1),BackgroundColor3=C.INNER,
            TextColor3=Color3.fromRGB(131,131,131),TextSize=11,FontFace=FONT_M,Text="✕  Clear",Parent=cont})
        mkCorner(clrBtn); mkStroke(clrBtn,C.STROKE_IN)
        local function flash(btn,col)
            tw(btn,0.08,{TextColor3=col})
            task.delay(1.2,function() tw(btn,0.2,{TextColor3=btn==runBtn and C.TEXT or Color3.fromRGB(131,131,131)}) end)
        end
        runBtn.MouseButton1Click:Connect(function()
            local code=tb.Text
            if code=="" or code:match("^%s*$") then return end
            local fn,err=loadstring(code)
            if not fn then flash(runBtn,C.ERROR); warn("[ZyrixUI Executor] Syntax:",err)
            else local ok,rerr=pcall(fn)
                if ok then flash(runBtn,C.SUCCESS) else flash(runBtn,C.ERROR); warn("[ZyrixUI Executor] Runtime:",rerr) end
            end
        end)
        clrBtn.MouseButton1Click:Connect(function() tb.Text="" end)
        runBtn.MouseEnter:Connect(function() tw(runBtn,0.1,{BackgroundColor3=Color3.fromRGB(32,32,32)}) end)
        runBtn.MouseLeave:Connect(function() tw(runBtn,0.1,{BackgroundColor3=C.INNER}) end)
        clrBtn.MouseEnter:Connect(function() tw(clrBtn,0.1,{BackgroundColor3=Color3.fromRGB(32,32,32)}) end)
        clrBtn.MouseLeave:Connect(function() tw(clrBtn,0.1,{BackgroundColor3=C.INNER}) end)
        return {
            GetValue=function() return tb.Text end,
            SetValue=function(v) tb.Text=v end,
            Execute=function() local fn,err=loadstring(tb.Text); if fn then pcall(fn) else warn("[ZyrixUI Executor]",err) end end,
        }
    end

    -- Label
    function tab:Label(text, col)
        lo=lo+1
        local lbl=mkLabel({Size=UDim2.new(1,0,0,22),Text=text,
            TextColor3=col or Color3.fromRGB(131,131,131),TextSize=11,FontFace=FONT_M,
            TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=lo,Parent=panel})
        return {SetText=function(t) lbl.Text=t end}
    end

    -- In-panel notification
    function tab:Notify(msg, dur)
        dur=dur or 3; lo=lo+1
        local n=mkFrame({Size=UDim2.new(1,0,0,30),BackgroundColor3=C.INNER,LayoutOrder=lo,Parent=panel})
        mkCorner(n); mkStroke(n,C.STROKE_IN); mkPad(n,0,0,8,8)
        mkLabel({Size=UDim2.new(1,0,1,0),Text=msg,TextColor3=C.TEXT,TextSize=11,
            FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=n})
        task.delay(dur,function()
            if n and n.Parent then tw(n,0.2,{BackgroundTransparency=1}); task.wait(0.22); n:Destroy() end
        end)
    end

    return tab
end

-- ── Public ────────────────────────────────────────────────────────────────────
function ZyrixUI:Open()  buildShell() end
function ZyrixUI:Close() if _sg then _sg:Destroy(); _sg=nil end end
function ZyrixUI:Toggle()
    if _tabFrame then
        local logo=_tabFrame:FindFirstChild("LogoBtn")
        if logo then toggleTablist(logo) end
    end
end
function ZyrixUI:SetTitle(text)
    if _mainFrame then
        local lbl=_mainFrame:FindFirstChildWhichIsA("TextLabel")
        if lbl then lbl.Text=text end
    end
end

getgenv().ZyrixUI=ZyrixUI

-- ══════════════════════════════════════════════════════════════════════════════
--  KEY SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════
local function hasFS()
    return type(writefile)=="function" and type(readfile)=="function"
       and type(isfile)=="function"    and type(makefolder)=="function"
       and type(isfolder)=="function"
end
local FS=hasFS(); local KF="Zyrix"
local function saveKey(name,key)
    if not FS then return end
    pcall(function() if not isfolder(KF) then makefolder(KF) end; writefile(KF.."/"..name..".txt",key) end)
end
local function loadKey(name)
    if not FS then return nil end
    local ok,v=pcall(function() local p=KF.."/"..name..".txt"; return isfile(p) and readfile(p) or nil end)
    return (ok and v and v~="") and v or nil
end
local function clearKey(name)
    if not FS then return end; pcall(delfile,KF.."/"..name..".txt")
end

local ICONS={
    key="rbxassetid://96510194465420",shield="rbxassetid://89965059528921",
    check="rbxassetid://76078495178149",copy="rbxassetid://125851897718493",
    discord="rbxassetid://83278450537116",alert="rbxassetid://140438367956051",
    lock="rbxassetid://114355063515473",close="rbxassetid://6022668916",
    logo="rbxassetid://105436073524298",
}
local function ico(n) return ICONS[n] or "" end

local Zyrix={}
Zyrix.Appearance={Title="Zyrix",Subtitle="Enter your key to continue",Icon="rbxassetid://105436073524298",IconSize=UDim2.new(0,28,0,28)}
Zyrix.Links={GetKey="",Discord=""}
Zyrix.Storage={FileName="Zyrix_Key",Remember=true,AutoLoad=true}
Zyrix.Options={Blur=true,Draggable=true}
Zyrix.Theme={
    Accent=Color3.fromRGB(255,255,255),AccentHover=Color3.fromRGB(200,200,200),
    Background=Color3.fromRGB(8,8,8),Header=Color3.fromRGB(14,14,14),
    Input=Color3.fromRGB(20,20,20),Text=Color3.fromRGB(255,255,255),
    TextDim=Color3.fromRGB(100,100,100),Success=Color3.fromRGB(180,255,180),
    Error=Color3.fromRGB(255,100,100),StatusIdle=Color3.fromRGB(70,70,70),
    Divider=Color3.fromRGB(28,28,28),
}
Zyrix.Callbacks={OnVerify=nil,OnSuccess=nil,OnFail=nil,OnClose=nil}
local T=Zyrix.Theme

local function enableBlur()
    if not Zyrix.Options.Blur then return end
    local b=LP2:FindFirstChild("ZyrixBlur") or Instance.new("BlurEffect")
    b.Name="ZyrixBlur";b.Size=0;b.Parent=LP2
    TS:Create(b,TweenInfo.new(0.4),{Size=20}):Play()
end
local function disableBlur()
    local b=LP2:FindFirstChild("ZyrixBlur");if not b then return end
    TS:Create(b,TweenInfo.new(0.3),{Size=0}):Play()
    task.delay(0.3,function() if b and b.Parent then b:Destroy() end end)
end

-- Background (grid + particles)
local function buildBG()
    local ex=hui:FindFirstChild("ZyrixBackground");if ex then ex:Destroy() end
    local bg=Instance.new("ScreenGui")
    bg.Name="ZyrixBackground";bg.ResetOnSpawn=false;bg.IgnoreGuiInset=true;bg.DisplayOrder=-10;bg.Parent=hui
    local canvas=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(4,4,4),BackgroundTransparency=1,Parent=bg})
    local vp=WS.CurrentCamera.ViewportSize; local cell=55
    local grid=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,Parent=canvas})
    for i=0,math.ceil(vp.X/cell)+2 do mkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(0,i*cell,0,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid}) end
    for i=0,math.ceil(vp.Y/cell)+2 do mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,i*cell),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid}) end
    local off=0
    RS.Heartbeat:Connect(function(dt) if not grid or not grid.Parent then return end; off=(off+dt*5)%cell; grid.Position=UDim2.new(0,-off,0,-off) end)
    local pc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,Parent=canvas})
    local function spawnP(instant)
        local sz=math.random(2,4); local px=math.random(0,100)/100; local py=instant and math.random(0,100)/100 or 1.05
        local spd=math.random(20,50); local drift=(math.random(-20,20))/1000
        local p=mkFrame({Size=UDim2.new(0,sz,0,sz),Position=UDim2.new(px,0,py,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.65,ZIndex=2,Parent=pc})
        mkCorner(p,UDim.new(1,0))
        local c3; c3=RS.Heartbeat:Connect(function(dt)
            if not p or not p.Parent then if c3 then c3:Disconnect() end; return end
            py=py-dt/spd; px=px+drift*dt; p.Position=UDim2.new(px,0,py,0)
            p.BackgroundTransparency=1-(0.35)*math.clamp(py*5,0,1)*math.clamp((1-py)*5,0,1)
            if py<-0.05 then c3:Disconnect(); p:Destroy(); task.delay(math.random(1,3),function() spawnP(false) end) end
        end)
    end
    for i=1,20 do task.delay(i*0.1,function() spawnP(true) end) end
    local wm=mkFrame({Size=UDim2.new(0,115,0,32),Position=UDim2.new(0,10,0,8),BackgroundColor3=Color3.fromRGB(10,10,10),BackgroundTransparency=0.35,ZIndex=5,Parent=canvas})
    mkCorner(wm,UDim.new(0,6)); mkStroke(wm,Color3.fromRGB(40,40,40),1)
    mkImage({Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,7,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,ZIndex=6,Parent=wm})
    mkLabel({Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,28,0,0),Text=Zyrix.Appearance.Title,TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.GothamBold,ZIndex=6,Parent=wm})
    TS:Create(canvas,TweenInfo.new(0.5),{BackgroundTransparency=0}):Play()
end

local function removeBG()
    local bg=hui:FindFirstChild("ZyrixBackground"); if not bg then return end
    local c=bg:FindFirstChildOfClass("Frame")
    if c then TS:Create(c,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
    task.delay(0.45,function() if bg and bg.Parent then bg:Destroy() end end)
end

-- Notifications
local _notifs={}
function Zyrix:Notify(title,msg,dur,itype)
    dur=dur or 4; local W,H=280,66
    local ng=Instance.new("ScreenGui"); ng.ResetOnSpawn=false; ng.DisplayOrder=999; ng.Parent=hui
    local f=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(1,W+10,1,-12),AnchorPoint=Vector2.new(1,1),BackgroundColor3=T.Header,Parent=ng})
    mkCorner(f,UDim.new(0,6)); mkStroke(f,T.Accent,1)
    local imap={success={ico("check"),T.Success},error={ico("alert"),T.Error},warning={ico("alert"),T.TextDim},info={ico("shield"),T.Accent},copy={ico("copy"),T.Success},discord={ico("discord"),Color3.fromRGB(180,180,255)},close={ico("close"),T.Error}}
    local im=imap[itype or "info"] or imap["info"]
    mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,11,0.5,-1),AnchorPoint=Vector2.new(0,0.5),Image=im[1],ImageColor3=im[2],Parent=f})
    mkLabel({Size=UDim2.new(1,-46,0,18),Position=UDim2.new(0,40,0,10),Text=title,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    mkLabel({Size=UDim2.new(1,-46,0,16),Position=UDim2.new(0,40,0,30),Text=msg,TextColor3=T.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    local pb=mkFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Color3.fromRGB(30,30,30),Parent=f})
    local pf=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,Parent=pb})
    mkCorner(pb,UDim.new(1,0)); mkCorner(pf,UDim.new(1,0))
    local id=tostring(tick()); table.insert(_notifs,{id=id,f=f,gui=ng,h=H})
    local function restack()
        local y=0
        for i=#_notifs,1,-1 do local n=_notifs[i]
            if n and n.f and n.f.Parent then TS:Create(n.f,TweenInfo.new(0.22),{Position=UDim2.new(1,-12,1,-12-y)}):Play(); y=y+n.h+8 end
        end
    end
    local function dismiss()
        for i,n in ipairs(_notifs) do if n.id==id then table.remove(_notifs,i); break end end
        TS:Create(f,TweenInfo.new(0.22),{Position=UDim2.new(1,W+10,f.Position.Y.Scale,f.Position.Y.Offset)}):Play()
        task.wait(0.25); ng:Destroy(); restack()
    end
    TS:Create(f,TweenInfo.new(0.28),{Position=UDim2.new(1,-12,1,-12)}):Play()
    task.wait(0.05); restack()
    TS:Create(pf,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(dur,dismiss)
    local cb2=mkBtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=f}); cb2.MouseButton1Click:Connect(dismiss)
end

local function validateKey(key,fn)
    if not fn or not key or key=="" then return false end
    local ok,r=pcall(fn,key); if not ok then return false end
    if type(r)=="table" then return r.valid==true end
    if type(r)=="boolean" then return r end
    return false
end

-- Key UI
local function buildKeyUI()
    local old=hui:FindFirstChild("ZyrixKeySystem"); if old then old:Destroy() end
    enableBlur()
    local W=isMobile and 320 or 380; local H=isMobile and 280 or 300

    local sg=Instance.new("ScreenGui"); sg.Name="ZyrixKeySystem"; sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true; sg.DisplayOrder=10; sg.Parent=hui

    local cont=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,1.5,0),BackgroundTransparency=1,Parent=sg})
    local main=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Background,Parent=cont})
    mkCorner(main,UDim.new(0,12)); mkStroke(main,T.Accent,1)
    mkGradient(main,T.Background,Color3.fromRGB(18,18,18))

    local hdr=mkFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,Parent=main})
    mkCorner(hdr,UDim.new(0,12))
    mkFrame({Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,1,-12),BackgroundColor3=T.Header,Parent=hdr})
    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,Parent=hdr})
    mkImage({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,Parent=hdr})
    mkLabel({Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Title,TextColor3=T.Text,TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})
    local closeBtnI=mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),Image=ico("close"),ImageColor3=T.TextDim,Parent=hdr})
    local closeBtnH=mkBtn({Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,Parent=hdr})
    closeBtnH.MouseEnter:Connect(function() TS:Create(closeBtnI,TweenInfo.new(0.1),{ImageColor3=T.Error}):Play() end)
    closeBtnH.MouseLeave:Connect(function() TS:Create(closeBtnI,TweenInfo.new(0.1),{ImageColor3=T.TextDim}):Play() end)

    local statBox=mkFrame({Size=UDim2.new(0.92,0,0,52),Position=UDim2.new(0.5,0,0,58),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    mkCorner(statBox,UDim.new(0,6)); mkStroke(statBox,T.Accent,1)
    local statIcon=mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=ico("lock"),ImageColor3=T.StatusIdle,Parent=statBox})
    local statLbl=mkLabel({Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Subtitle,TextColor3=T.StatusIdle,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=statBox})

    local inpBox=mkFrame({Size=UDim2.new(0.92,0,0,44),Position=UDim2.new(0.5,0,0,120),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    mkCorner(inpBox,UDim.new(0,6)); local ibs=mkStroke(inpBox,T.Accent,1)
    mkImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=ico("key"),ImageColor3=T.TextDim,Parent=inpBox})
    local tb=Instance.new("TextBox"); tb.Size=UDim2.new(1,-34,1,0); tb.Position=UDim2.new(0,28,0,0)
    tb.BackgroundTransparency=1; tb.Text=""; tb.PlaceholderText="Enter your key..."
    tb.PlaceholderColor3=T.TextDim; tb.TextColor3=T.Text; tb.TextSize=14
    tb.Font=Enum.Font.Gotham; tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left; tb.Parent=inpBox
    tb.Focused:Connect(function() ibs.Transparency=0.4 end)
    tb.FocusLost:Connect(function() ibs.Transparency=0.82 end)

    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,174),BackgroundColor3=T.Divider,Parent=main})

    local function actionBtn(lbl2,ic,primary,y)
        local b=mkBtn({Size=UDim2.new(0.78,0,0,36),Position=UDim2.new(0.5,0,0,y),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=primary and T.Accent or T.Input,Parent=main})
        mkCorner(b,UDim.new(0,6)); mkStroke(b,primary and T.AccentHover or T.Accent,1)
        local fc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=b})
        local fl=Instance.new("UIListLayout",fc); fl.FillDirection=Enum.FillDirection.Horizontal; fl.HorizontalAlignment=Enum.HorizontalAlignment.Center; fl.VerticalAlignment=Enum.VerticalAlignment.Center; fl.Padding=UDim.new(0,6)
        mkImage({Size=UDim2.new(0,14,0,14),Image=ico(ic),ImageColor3=primary and T.Background or T.Text,LayoutOrder=1,Parent=fc})
        mkLabel({Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Text=lbl2,TextColor3=primary and T.Background or T.Text,TextSize=13,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=fc})
        b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=primary and T.AccentHover or Color3.fromRGB(28,28,28)}):Play() end)
        b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=primary and T.Accent or T.Input}):Play() end)
        return b
    end
    local getKeyBtn=actionBtn("Get Key","key",false,186)
    local redeemBtn=actionBtn("Redeem Key","shield",true,228)

    local function icoBtn(ic,x,nc)
        local b=mkBtn({Size=UDim2.new(0,30,0,30),Position=UDim2.new(0.5,x,0,H-44),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
        mkCorner(b,UDim.new(0,6)); mkStroke(b,T.Accent,1)
        local im2=mkImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Image=ico(ic),ImageColor3=nc,Parent=b})
        b.MouseEnter:Connect(function() TS:Create(im2,TweenInfo.new(0.1),{ImageColor3=T.Accent}):Play() end)
        b.MouseLeave:Connect(function() TS:Create(im2,TweenInfo.new(0.1),{ImageColor3=nc}):Play() end)
        return b
    end
    icoBtn("discord",-20,T.TextDim).MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord~="" then pcall(setclipboard,Zyrix.Links.Discord); Zyrix:Notify("Discord","Invite copied",2,"discord") end
    end)
    icoBtn("key",20,T.TextDim).MouseButton1Click:Connect(function()
        if Zyrix.Links.GetKey~="" then pcall(setclipboard,Zyrix.Links.GetKey); Zyrix:Notify("Copied","Key link copied",2,"copy")
        else Zyrix:Notify("Error","No key link set",3,"error") end
    end)

    local spinC,dotT
    local function setStatus(state,custom)
        if spinC then spinC:Disconnect();spinC=nil;statIcon.Rotation=0 end
        if dotT  then task.cancel(dotT);dotT=nil end
        local col,ic2,txt=T.StatusIdle,ico("lock"),custom or "No key detected"
        if state=="verifying" then
            col,ic2,txt=T.Accent,ico("lock"),"Verifying key"
            local dots,di={".","..","...",""},1
            dotT=task.spawn(function()
                while statLbl and statLbl.Parent do statLbl.Text="Verifying key"..dots[di]; di=(di%4)+1; task.wait(0.35) end
            end)
        elseif state=="success" then col,ic2,txt=T.Success,ico("check"),custom or "Access Granted"
        elseif state=="error"   then col,ic2,txt=T.Error,  ico("alert"),custom or "Invalid Key" end
        TS:Create(statLbl,TweenInfo.new(0.2),{TextColor3=col}):Play()
        TS:Create(statIcon,TweenInfo.new(0.2),{ImageColor3=col}):Play()
        statLbl.Text=txt; statIcon.Image=ic2
    end

    local function closeAndClean(cb)
        disableBlur()
        TS:Create(cont,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-W/2,-0.6,0)}):Play()
        TS:Create(main,TweenInfo.new(0.22),{BackgroundTransparency=1}):Play()
        task.wait(0.32); sg:Destroy(); if cb then cb() end
    end

    closeBtnH.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        closeAndClean(function()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end; removeBG()
        end)
    end)

    local function handleRedeem()
        local key=tb.Text:gsub("%s+","")
        if key=="" then Zyrix:Notify("Error","Please enter a key",3,"error"); return end
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
            setStatus("success"); Zyrix:Notify("Success","Key validated!",2,"success"); task.wait(0.8)
            closeAndClean(function() removeBG(); if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end end)
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

    if Zyrix.Options.Draggable then draggable(hdr,cont) end
    TS:Create(cont,TweenInfo.new(0.4,Enum.EasingStyle.Back),{Position=UDim2.new(0.5,-W/2,0.5,-H/2)}):Play()
end

function Zyrix:Launch()
    local ek=getgenv().__ZyrixKey
    if ek and ek~="" then
        if validateKey(ek,self.Callbacks.OnVerify) then
            self:Notify("Welcome Back","Key still valid",2,"success")
            if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end; return
        end
        getgenv().__ZyrixKey=nil
    end
    if self.Storage.AutoLoad and self.Callbacks.OnVerify then
        local saved=loadKey(self.Storage.FileName)
        if saved then
            self:Notify("Checking","Validating saved key...",2,"info"); task.wait(0.4)
            if validateKey(saved,self.Callbacks.OnVerify) then
                getgenv().__ZyrixKey=saved
                self:Notify("Welcome Back","Key validated!",2,"success")
                if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end; return
            else
                clearKey(self.Storage.FileName); self:Notify("Expired","Saved key expired",3,"error"); task.wait(0.6)
            end
        end
    end
    buildBG(); buildKeyUI()
end

function Zyrix:GetSavedKey()   return loadKey(self.Storage.FileName) end
function Zyrix:ClearSavedKey() clearKey(self.Storage.FileName) end

getgenv().__ZyrixLib = Zyrix
getgenv().ZyrixUI    = ZyrixUI

-- ══════════════════════════════════════════════════════════════════════════════
--  ZyrixPanel  —  the main GUI that opens after the key is accepted
--  Exact design from the provided script. Call ZyrixPanel:Open() in OnSuccess.
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixPanel = {}

local function buildPanel()
    -- remove any existing instance
    local plr    = PLR.LocalPlayer
    local pg     = plr:WaitForChild("PlayerGui")
    local oldSG  = pg:FindFirstChild("ZyrixPanel")
    if oldSG then oldSG:Destroy() end

    local pSG = Instance.new("ScreenGui")
    pSG.Name           = "ZyrixPanel"
    pSG.ResetOnSpawn   = false
    pSG.IgnoreGuiInset = true
    pSG.DisplayOrder   = 60          -- above key system overlay
    pSG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pSG.Parent         = pg

    -- ── Palette ────────────────────────────────────────────────────────────────
    local P = {
        WIN       = Color3.fromRGB(20,  20,  20),
        TAB       = Color3.fromRGB(23,  23,  23),
        EL        = Color3.fromRGB(25,  25,  25),
        INNER     = Color3.fromRGB(31,  31,  31),
        PROGRESS  = Color3.fromRGB(201, 201, 201),
        DD_BG     = Color3.fromRGB(19,  19,  19),
        DD_ROW    = Color3.fromRGB(27,  27,  27),
        STROKE_EL = Color3.fromRGB(41,  41,  41),
        STROKE_IN = Color3.fromRGB(51,  51,  51),
        STROKE_WIN= Color3.fromRGB(36,  36,  36),
        TEXT      = Color3.fromRGB(231, 231, 231),
        TEXT_DIM  = Color3.fromRGB(181, 181, 181),
        TEXT_GREY = Color3.fromRGB(131, 131, 131),
        WHITE     = Color3.fromRGB(255, 255, 255),
        GREEN1    = Color3.fromRGB(0,   171, 0),
        HOVER     = Color3.fromRGB(45,  45,  45),
        OFF       = Color3.fromRGB(60,  60,  60),
        LOGO_OFF  = Color3.fromRGB(100, 100, 100),
    }

    local FONT_B = Enum.Font.GothamBold
    local FONT_M = Enum.Font.GothamMedium

    -- ── Helpers ────────────────────────────────────────────────────────────────
    local function pt(obj, t, props, style, dir)
        TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
    end

    local function pCorner(p, r)
        local c = Instance.new("UICorner", p); c.CornerRadius = r or UDim.new(0,4); return c
    end
    local function pStroke(p, col, thick)
        local s = Instance.new("UIStroke", p)
        s.Color = col or P.STROKE_EL; s.Thickness = thick or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; return s
    end
    local function pPad(p, t, b, l, r)
        local pad = Instance.new("UIPadding", p)
        pad.PaddingTop=UDim.new(0,t or 0); pad.PaddingBottom=UDim.new(0,b or 0)
        pad.PaddingLeft=UDim.new(0,l or 0); pad.PaddingRight=UDim.new(0,r or 0)
    end
    local function pGrad(p, from, to, rot)
        local g = Instance.new("UIGradient", p)
        g.Color = ColorSequence.new(from or Color3.new(0,0,0), to or P.WIN)
        g.Rotation = rot or 0; return g
    end
    local function pLabel(props)
        local l = Instance.new("TextLabel"); l.BackgroundTransparency=1
        l.TextXAlignment=Enum.TextXAlignment.Left; l.TextWrapped=true
        for k,v in pairs(props) do l[k]=v end; return l
    end
    local function pBtn(parent, size, pos, bgCol)
        local b = Instance.new("TextButton", parent)
        b.AutoButtonColor=false; b.BackgroundTransparency=1
        b.Size=size; b.Position=pos or UDim2.new(0,0,0,0)
        b.Text=""; b.BorderSizePixel=0
        if bgCol then b.BackgroundColor3=bgCol; b.BackgroundTransparency=0 end
        return b
    end
    local function pFrame(parent, size, pos, col, trans)
        local f = Instance.new("Frame", parent); f.BorderSizePixel=0
        f.Size=size; f.Position=pos or UDim2.new(0,0,0,0)
        f.BackgroundColor3=col or P.WIN
        f.BackgroundTransparency=trans or 0
        return f
    end
    local function pList(parent, spacing, dir)
        local l = Instance.new("UIListLayout", parent)
        l.Padding=UDim.new(0,spacing or 5); l.SortOrder=Enum.SortOrder.LayoutOrder
        l.FillDirection=dir or Enum.FillDirection.Vertical; return l
    end

    -- ── Layout ─────────────────────────────────────────────────────────────────
    local WIN_W=563; local WIN_H=354; local TAB_H=42; local GAP=8
    local TOTAL_H=TAB_H+GAP+WIN_H

    -- Outer container
    local outer = pFrame(pSG, UDim2.new(0,WIN_W,0,TAB_H), UDim2.new(0,20,0,20), P.TAB)
    outer.Name="ZyrixOuter"; outer.ClipsDescendants=false
    pCorner(outer, UDim.new(0,8))
    pStroke(outer, P.STROKE_WIN, 1)
    pGrad(outer, Color3.new(0,0,0), P.TAB)

    -- ── Tab bar ────────────────────────────────────────────────────────────────
    local tabFrame = pFrame(outer, UDim2.new(1,0,0,TAB_H), UDim2.new(0,0,0,0), P.TAB)
    tabFrame.Name="TabFrame"; tabFrame.ClipsDescendants=false
    pCorner(tabFrame, UDim.new(0,8))
    pGrad(tabFrame, Color3.new(0,0,0), P.TAB)

    -- Z logo button
    local logoBtn = pBtn(tabFrame, UDim2.new(0,36,0,36), UDim2.new(0,4,0.5,-18), P.TEXT)
    logoBtn.BackgroundTransparency=0; logoBtn.Name="LogoBtn"
    pCorner(logoBtn, UDim.new(0,6))
    local logoText = pLabel({
        Parent=logoBtn, Size=UDim2.new(1,0,1,0),
        Text="Z", Font=FONT_B, TextSize=22,
        TextColor3=P.WHITE, TextXAlignment=Enum.TextXAlignment.Center,
        TextYAlignment=Enum.TextYAlignment.Center,
    })
    logoText.ZIndex = logoBtn.ZIndex+1

    -- Pill scroll (tabs)
    local tabSF = Instance.new("ScrollingFrame", tabFrame)
    tabSF.Name="tablist"; tabSF.Size=UDim2.new(1,-50,1,0)
    tabSF.Position=UDim2.new(0,46,0,0)
    tabSF.BackgroundTransparency=1; tabSF.BorderSizePixel=0
    tabSF.ScrollBarThickness=0
    tabSF.ScrollingDirection=Enum.ScrollingDirection.X
    tabSF.VerticalScrollBarInset=Enum.ScrollBarInset.Always
    tabSF.AutomaticCanvasSize=Enum.AutomaticSize.X
    tabSF.CanvasSize=UDim2.new(0,0,0,0)
    pCorner(tabSF, UDim.new(0,100))
    local tLayout=pList(tabSF,4,Enum.FillDirection.Horizontal)
    tLayout.VerticalAlignment=Enum.VerticalAlignment.Center
    pPad(tabSF,3,3,3,3)

    -- ── Main window ────────────────────────────────────────────────────────────
    local mainFrame = pFrame(outer, UDim2.new(0,WIN_W,0,WIN_H),
        UDim2.new(0,0,0,TAB_H+GAP), P.WIN)
    mainFrame.Name="main"; mainFrame.Visible=false
    pCorner(mainFrame, UDim.new(0,12))   -- radius 12 as specified
    pGrad(mainFrame, Color3.new(0,0,0), P.WIN)

    -- drop-shadow effect via UIStroke
    local mainStroke = pStroke(mainFrame, P.STROKE_WIN, 1.5)
    mainStroke.Transparency = 0.4

    -- Header
    local hdr = pFrame(mainFrame, UDim2.new(1,0,0,36), UDim2.new(0,0,0,0), P.TAB)
    hdr.Name="Header"; pCorner(hdr, UDim.new(0,12))
    -- fill bottom corners
    pFrame(hdr, UDim2.new(1,0,0,12), UDim2.new(0,0,1,-12), P.TAB)

    pLabel({Parent=hdr, Size=UDim2.new(1,-42,1,-6), Position=UDim2.new(0,10,0,3),
        Text="Zyrix", Font=FONT_B, TextSize=16, TextColor3=P.WHITE,
        TextXAlignment=Enum.TextXAlignment.Left})

    local closeBtn = pBtn(hdr, UDim2.new(0,26,0,26), UDim2.new(1,-30,0.5,-13), P.HOVER)
    closeBtn.BackgroundTransparency=0; closeBtn.Name="CloseBtn"
    pCorner(closeBtn, UDim.new(0,5))
    pLabel({Parent=closeBtn, Size=UDim2.new(1,0,1,0), Text="✕",
        Font=FONT_B, TextSize=13, TextColor3=P.TEXT,
        TextXAlignment=Enum.TextXAlignment.Center, TextYAlignment=Enum.TextYAlignment.Center})
    closeBtn.MouseEnter:Connect(function() pt(closeBtn,0.1,{BackgroundColor3=Color3.fromRGB(80,20,20)}) end)
    closeBtn.MouseLeave:Connect(function() pt(closeBtn,0.1,{BackgroundColor3=P.HOVER}) end)

    -- Separator
    local sep = pFrame(mainFrame, UDim2.new(1,-20,0,1), UDim2.new(0,10,0,36), P.STROKE_IN)

    -- Elements scroll
    local elements = Instance.new("ScrollingFrame", mainFrame)
    elements.Name="elements"
    elements.Size=UDim2.new(1,-10,1,-42)
    elements.Position=UDim2.new(0,5,0,40)
    elements.BackgroundTransparency=1; elements.BorderSizePixel=0
    elements.ScrollBarThickness=2
    elements.ScrollBarImageColor3=Color3.fromRGB(141,141,141)
    elements.ScrollBarImageTransparency=0.3
    elements.CanvasSize=UDim2.new(0,0,0,0)
    elements.AutomaticCanvasSize=Enum.AutomaticSize.Y
    elements.ScrollingDirection=Enum.ScrollingDirection.Y
    pPad(elements,4,6,4,4)
    pList(elements,6)

    -- ── Element builders ───────────────────────────────────────────────────────
    local _tabPanels = {}
    local _tabBtns   = {}
    local _activeTab = nil
    local _loMap     = {}   -- per-tab layout order counter

    -- Section header
    local function addSection(panel, title)
        _loMap[panel] = (_loMap[panel] or 0) + 1
        local s = pFrame(panel, UDim2.new(1,0,0,24), nil, P.WIN, 1)
        s.LayoutOrder=_loMap[panel]
        pLabel({Parent=s, Size=UDim2.new(1,0,1,0),
            Text=title:upper(), Font=Enum.Font.Gotham, TextSize=9,
            TextColor3=Color3.fromRGB(90,90,90), TextXAlignment=Enum.TextXAlignment.Left})
        local ln=pFrame(s,UDim2.new(1,0,0,1),UDim2.new(0,0,1,-1),P.STROKE_EL)
    end

    -- Element wrapper
    local function elBase(panel, h)
        _loMap[panel] = (_loMap[panel] or 0) + 1
        local f = pFrame(panel, UDim2.new(1,0,0,h), nil, P.EL)
        f.LayoutOrder=_loMap[panel]
        pCorner(f, UDim.new(0,5))
        pStroke(f, P.STROKE_EL, 1)
        pPad(f, 8, 8, 10, 10)
        return f
    end

    -- Toggle (exact match to the provided script)
    local function addToggle(panel, label, desc, default, callback)
        local h = desc and 52 or 38
        local f = elBase(panel, h)

        -- Title
        pLabel({Parent=f, Size=UDim2.new(1,-54,0,14),
            Position=UDim2.new(0,0,0,desc and 2 or 0),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})
        if desc then
            pLabel({Parent=f, Size=UDim2.new(1,-54,0,12),
                Position=UDim2.new(0,0,0,18),
                Text=desc, Font=Enum.Font.Gotham, TextSize=10,
                TextColor3=Color3.fromRGB(100,100,100),
                TextXAlignment=Enum.TextXAlignment.Left})
        end

        -- Switch frame
        local sw = pFrame(f, UDim2.new(0,42,0,22), UDim2.new(1,-42,0.5,-11), P.OFF)
        pCorner(sw, UDim.new(0,11))
        pStroke(sw, P.STROKE_IN, 1)

        -- Indicator dot
        local dot = pFrame(sw, UDim2.new(0,18,0,18), UDim2.new(0,1,0.5,-9), Color3.fromRGB(178,178,178))
        pCorner(dot, UDim.new(0,9))

        local state = default or false
        local function applyState(v, animate)
            if animate then
                pt(sw, 0.18, {BackgroundColor3=v and P.GREEN1 or P.OFF})
                pt(dot, 0.18, {Position=UDim2.new(v and 1 or 0, v and -19 or 1, 0.5,-9),
                    BackgroundColor3=v and P.WHITE or Color3.fromRGB(178,178,178)})
            else
                sw.BackgroundColor3=v and P.GREEN1 or P.OFF
                dot.Position=UDim2.new(v and 1 or 0, v and -19 or 1, 0.5,-9)
                dot.BackgroundColor3=v and P.WHITE or Color3.fromRGB(178,178,178)
            end
        end
        applyState(state, false)

        -- Hit zone covers the whole element
        local hit = pBtn(f, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
        hit.ZIndex = 5
        hit.MouseButton1Click:Connect(function()
            state=not state; applyState(state,true)
            if callback then pcall(callback,state) end
        end)
        f.MouseEnter:Connect(function() pt(f,0.12,{BackgroundColor3=P.HOVER}) end)
        f.MouseLeave:Connect(function() pt(f,0.12,{BackgroundColor3=P.EL}) end)

        return {
            GetValue=function() return state end,
            SetValue=function(v) state=v; applyState(v,true) end,
        }
    end

    -- Slider (exact match to provided script)
    local function addSlider(panel, label, min, max, default, suffix, callback)
        if type(suffix)=="function" then callback=suffix; suffix="units" end
        suffix=suffix or "units"; min=min or 0; max=max or 100
        default=math.clamp(default or min,min,max)
        local value=default
        local f=elBase(panel,52)

        -- Label + value text
        pLabel({Parent=f, Size=UDim2.new(0.55,0,0,14),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})
        local infoLbl=pLabel({Parent=f, Size=UDim2.new(0.45,0,0,14),
            Position=UDim2.new(0.55,0,0,0),
            Text=tostring(value).." "..suffix,
            Font=FONT_M, TextSize=12, TextColor3=P.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Right})

        -- Track box (matches G2L["1f"])
        local main=pFrame(f, UDim2.new(1,0,0,26), UDim2.new(0,0,0,20), P.INNER)
        pCorner(main, UDim.new(0,4))
        pStroke(main, P.STROKE_IN, 1)

        -- Progress fill (G2L["21"])
        local prog=pFrame(main, UDim2.new((value-min)/(max-min),0,1,0), nil, P.PROGRESS)
        pCorner(prog, UDim.new(0,4))
        local ps=Instance.new("UIStroke",prog); ps.Transparency=0.2; ps.Thickness=0.5; ps.Color=P.STROKE_IN

        -- Info label over bar (G2L["24"])
        local barInfo=pLabel({Parent=main, ZIndex=5, TextSize=11,
            TextXAlignment=Enum.TextXAlignment.Left, TextTransparency=0.3,
            Font=Enum.Font.GothamMedium, TextColor3=Color3.fromRGB(131,131,131),
            AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.9,0,0,14),
            Text=tostring(value).." "..suffix,
            Position=UDim2.new(0.45,0,0.5,0)})

        local function updateSlider(x)
            local rel=math.clamp((x-main.AbsolutePosition.X)/main.AbsoluteSize.X,0,1)
            value=math.floor(min+(max-min)*rel+0.5)
            prog.Size=UDim2.new((value-min)/(max-min),0,1,0)
            local txt=tostring(value).." "..suffix
            infoLbl.Text=txt; barInfo.Text=txt
            if callback then pcall(callback,value) end
        end

        local dragging=false
        local hit=pBtn(main, UDim2.new(1,0,1,0))
        hit.ZIndex=10
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; updateSlider(i.Position.X)
                pt(main,0.08,{BackgroundColor3=P.HOVER})
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging=false; pt(main,0.15,{BackgroundColor3=P.INNER}) end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                updateSlider(i.Position.X) end
        end)
        f.MouseEnter:Connect(function() pt(f,0.12,{BackgroundColor3=P.HOVER}) end)
        f.MouseLeave:Connect(function() pt(f,0.12,{BackgroundColor3=P.EL}) end)

        return {
            GetValue=function() return value end,
            SetValue=function(v)
                value=math.clamp(v,min,max)
                prog.Size=UDim2.new((value-min)/(max-min),0,1,0)
                local txt=tostring(value).." "..suffix
                infoLbl.Text=txt; barInfo.Text=txt
            end,
        }
    end

    -- Button (exact match to provided script)
    local function addButton(panel, label, desc, callback)
        local h=desc and 52 or 38
        local f=elBase(panel,h)

        -- Star icon on left
        pLabel({Parent=f, Size=UDim2.new(0,26,0,26),
            Position=UDim2.new(0,0,0.5,-13),
            Text="★", Font=Enum.Font.SourceSans, TextSize=18,
            TextColor3=P.TEXT_GREY, TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center})
        -- Title
        pLabel({Parent=f, Size=UDim2.new(1,-36,0,14),
            Position=UDim2.new(0,30,0,desc and 2 or 0),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})
        if desc then
            pLabel({Parent=f, Size=UDim2.new(1,-36,0,12),
                Position=UDim2.new(0,30,0,18),
                Text=desc, Font=Enum.Font.Gotham, TextSize=10,
                TextColor3=Color3.fromRGB(100,100,100),
                TextXAlignment=Enum.TextXAlignment.Left})
        end
        -- Type indicator right
        pLabel({Parent=f, Size=UDim2.new(0,80,0,13),
            Position=UDim2.new(1,-80,0.5,-6),
            Text="Button", Font=FONT_M, TextSize=11,
            TextTransparency=0.5, TextColor3=P.TEXT_GREY,
            TextXAlignment=Enum.TextXAlignment.Right})

        local hit=pBtn(f,UDim2.new(1,0,1,0))
        hit.ZIndex=5
        hit.MouseButton1Click:Connect(function()
            pt(f,0.07,{BackgroundColor3=Color3.fromRGB(38,38,38)})
            task.delay(0.1,function() pt(f,0.12,{BackgroundColor3=P.EL}) end)
            if callback then pcall(callback) end
        end)
        hit.MouseButton1Down:Connect(function() pt(f,0.06,{Size=UDim2.new(0.99,0,0,h-2)}) end)
        hit.MouseButton1Up:Connect(function()   pt(f,0.15,{Size=UDim2.new(1,0,0,h)},Enum.EasingStyle.Back) end)
        f.MouseEnter:Connect(function() pt(f,0.12,{BackgroundColor3=P.HOVER}) end)
        f.MouseLeave:Connect(function() pt(f,0.12,{BackgroundColor3=P.EL}) end)
    end

    -- Keybind (exact match to provided script)
    local function addKeybind(panel, label, default, callback)
        local key=default or Enum.KeyCode.Q
        local f=elBase(panel,38)

        pLabel({Parent=f, Size=UDim2.new(1,-90,1,0),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})

        -- Keybind pill
        local kbFrame=pFrame(f, UDim2.new(0,70,0,24), UDim2.new(1,-70,0.5,-12), P.EL)
        pCorner(kbFrame, UDim.new(0,4))
        pStroke(kbFrame, P.STROKE_IN, 1)
        local kbLbl=pLabel({Parent=kbFrame, Size=UDim2.new(1,0,1,0),
            Text=tostring(key):gsub("Enum.KeyCode.",""),
            Font=FONT_B, TextSize=12, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center})

        local hit=pBtn(f,UDim2.new(1,0,1,0))
        hit.ZIndex=5
        local capturing=false; local conn2
        hit.MouseButton1Click:Connect(function()
            if capturing then return end
            capturing=true; kbLbl.Text="..."
            pt(kbFrame,0.1,{BackgroundColor3=P.HOVER})
            conn2=UIS.InputBegan:Connect(function(i,gp)
                if gp then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; kbLbl.Text=tostring(key):gsub("Enum.KeyCode.","")
                    capturing=false; pt(kbFrame,0.1,{BackgroundColor3=P.EL})
                    if conn2 then conn2:Disconnect() end
                    if callback then pcall(callback,key) end
                end
            end)
        end)
        f.MouseEnter:Connect(function() pt(f,0.12,{BackgroundColor3=P.HOVER}) end)
        f.MouseLeave:Connect(function() pt(f,0.12,{BackgroundColor3=P.EL}) end)
        return {GetValue=function() return key end}
    end

    -- Dropdown (exact match to provided script)
    local function addDropdown(panel, label, options, default, callback)
        local selected=default or (options and options[1]) or ""
        local isOpen=false; local ITEM_H=32
        local f=elBase(panel,38)
        f.ClipsDescendants=false; f.ZIndex=5

        pLabel({Parent=f, Size=UDim2.new(0.5,0,0,14),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})

        -- Interact bar
        local interact=pFrame(f, UDim2.new(0.5,-4,0,26), UDim2.new(0.5,4,0,0), P.INNER)
        pCorner(interact, UDim.new(0,4))
        pStroke(interact, P.STROKE_IN, 1)

        local selLbl=pLabel({Parent=interact, Size=UDim2.new(1,-28,1,0),
            Position=UDim2.new(0,8,0,0), Text=selected,
            Font=FONT_M, TextSize=12, TextColor3=P.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Left})

        local arrowFrame=pFrame(interact, UDim2.new(0,20,0,20), UDim2.new(1,-24,0.5,-10), P.OFF)
        pCorner(arrowFrame, UDim.new(0,4))
        local arrowLbl=pLabel({Parent=arrowFrame, Size=UDim2.new(1,0,1,0),
            Text="▼", Font=Enum.Font.SourceSans, TextSize=11, TextColor3=P.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Center, TextYAlignment=Enum.TextYAlignment.Center})

        -- Dropdown list (positioned below the element, no clipping issues)
        local listHolder=pFrame(f, UDim2.new(1,0,0,0), UDim2.new(0,0,1,4), P.DD_BG)
        listHolder.ZIndex=20; listHolder.ClipsDescendants=true
        pCorner(listHolder, UDim.new(0,5))
        pStroke(listHolder, P.STROKE_EL, 1)
        local listLayout2=pList(listHolder,2)
        pPad(listHolder,4,4,4,4)

        for _,opt in ipairs(options or {}) do
            local row=pFrame(listHolder, UDim2.new(1,0,0,ITEM_H-2), nil, P.DD_ROW)
            pCorner(row, UDim.new(0,4))
            pLabel({Parent=row, Size=UDim2.new(1,-16,1,0),
                Position=UDim2.new(0,8,0,0), Text=opt,
                Font=FONT_M, TextSize=12, TextColor3=P.TEXT,
                TextXAlignment=Enum.TextXAlignment.Left})
            local rh=pBtn(row, UDim2.new(1,0,1,0))
            rh.ZIndex=21
            rh.MouseEnter:Connect(function() pt(row,0.08,{BackgroundColor3=P.HOVER}) end)
            rh.MouseLeave:Connect(function() pt(row,0.08,{BackgroundColor3=P.DD_ROW}) end)
            rh.MouseButton1Click:Connect(function()
                selected=opt; selLbl.Text=opt; isOpen=false
                pt(arrowLbl,0.12,{Rotation=0}); pt(arrowFrame,0.12,{BackgroundColor3=P.OFF})
                pt(listHolder,0.15,{Size=UDim2.new(1,0,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
                f.Size=UDim2.new(1,0,0,38)
                if callback then pcall(callback,opt) end
            end)
        end

        local maxH=ITEM_H*math.min(#(options or {}),5)+8
        local hit=pBtn(f, UDim2.new(1,0,1,0)); hit.ZIndex=6
        hit.MouseButton1Click:Connect(function()
            isOpen=not isOpen
            if isOpen then
                pt(arrowLbl,0.12,{Rotation=180}); pt(arrowFrame,0.12,{BackgroundColor3=P.EL})
                pt(listHolder,0.18,{Size=UDim2.new(1,0,0,maxH)},Enum.EasingStyle.Back)
                f.Size=UDim2.new(1,0,0,38+maxH+4)
            else
                pt(arrowLbl,0.12,{Rotation=0}); pt(arrowFrame,0.12,{BackgroundColor3=P.OFF})
                pt(listHolder,0.15,{Size=UDim2.new(1,0,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
                f.Size=UDim2.new(1,0,0,38)
            end
        end)
        interact.MouseEnter:Connect(function() pt(interact,0.12,{BackgroundColor3=P.HOVER}) end)
        interact.MouseLeave:Connect(function() pt(interact,0.12,{BackgroundColor3=P.INNER}) end)
        return {GetValue=function() return selected end, SetValue=function(v) selected=v; selLbl.Text=v end}
    end

    -- TextBox
    local function addTextBox(panel, label, placeholder, default, callback)
        local f=elBase(panel,62)
        pLabel({Parent=f, Size=UDim2.new(1,0,0,14),
            Text=label, Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})
        local ibg=pFrame(f, UDim2.new(1,0,0,28), UDim2.new(0,0,0,18), P.INNER)
        pCorner(ibg); local ibs=pStroke(ibg, P.STROKE_IN, 1)
        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-10,1,0); tb.Position=UDim2.new(0,5,0,0)
        tb.BackgroundTransparency=1; tb.Text=default or ""
        tb.PlaceholderText=placeholder or ""; tb.PlaceholderColor3=Color3.fromRGB(80,80,80)
        tb.TextColor3=P.TEXT; tb.TextSize=12; tb.Font=Enum.Font.GothamMedium
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.Focused:Connect(function() ibs.Color=Color3.fromRGB(130,130,130) end)
        tb.FocusLost:Connect(function(enter)
            ibs.Color=P.STROKE_IN
            if enter and callback then pcall(callback,tb.Text) end
        end)
        f.MouseEnter:Connect(function() pt(f,0.12,{BackgroundColor3=P.HOVER}) end)
        f.MouseLeave:Connect(function() pt(f,0.12,{BackgroundColor3=P.EL}) end)
        return {GetValue=function() return tb.Text end, SetValue=function(v) tb.Text=v end}
    end

    -- Script Executor
    local function addExecutor(panel, placeholder)
        _loMap[panel]=(_loMap[panel] or 0)+1
        local cont=pFrame(panel, UDim2.new(1,0,0,134), nil, P.EL)
        cont.LayoutOrder=_loMap[panel]
        pCorner(cont,UDim.new(0,5)); pStroke(cont,P.STROKE_EL,1); pPad(cont,8,8,10,10)
        pLabel({Parent=cont, Size=UDim2.new(1,0,0,14),
            Text="Script Executor", Font=FONT_M, TextSize=13, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Left})
        local ibg=pFrame(cont, UDim2.new(1,0,0,78), UDim2.new(0,0,0,18), P.INNER)
        pCorner(ibg); pStroke(ibg,P.STROKE_IN,1)
        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-10,1,-4); tb.Position=UDim2.new(0,5,0,2)
        tb.BackgroundTransparency=1; tb.Text=""
        tb.PlaceholderText=placeholder or "-- Enter script here..."
        tb.PlaceholderColor3=Color3.fromRGB(70,70,70)
        tb.TextColor3=Color3.fromRGB(220,220,220); tb.TextSize=11
        tb.Font=Enum.Font.GothamMedium; tb.ClearTextOnFocus=false
        tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.TextYAlignment=Enum.TextYAlignment.Top
        tb.MultiLine=true; tb.TextWrapped=true
        local runBtn=pBtn(cont, UDim2.new(0.49,0,0,22), UDim2.new(0,0,1,-24), P.INNER)
        runBtn.BackgroundTransparency=0; pCorner(runBtn); pStroke(runBtn,P.STROKE_IN,1)
        pLabel({Parent=runBtn, Size=UDim2.new(1,0,1,0), Text="▶  Execute",
            Font=FONT_M, TextSize=11, TextColor3=P.TEXT,
            TextXAlignment=Enum.TextXAlignment.Center, TextYAlignment=Enum.TextYAlignment.Center})
        local clrBtn=pBtn(cont, UDim2.new(0.49,0,0,22), UDim2.new(0.51,0,1,-24), P.INNER)
        clrBtn.BackgroundTransparency=0; pCorner(clrBtn); pStroke(clrBtn,P.STROKE_IN,1)
        pLabel({Parent=clrBtn, Size=UDim2.new(1,0,1,0), Text="✕  Clear",
            Font=FONT_M, TextSize=11, TextColor3=P.TEXT_GREY,
            TextXAlignment=Enum.TextXAlignment.Center, TextYAlignment=Enum.TextYAlignment.Center})
        local function flash(btn,col)
            pt(btn,0.08,{BackgroundColor3=col})
            task.delay(1.2,function() pt(btn,0.2,{BackgroundColor3=P.INNER}) end)
        end
        runBtn.MouseButton1Click:Connect(function()
            local code=tb.Text; if code=="" or code:match("^%s*$") then return end
            local fn,err=loadstring(code)
            if not fn then flash(runBtn,Color3.fromRGB(80,20,20)); warn("[ZyrixPanel Executor] Syntax:",err)
            else local ok,rerr=pcall(fn)
                if ok then flash(runBtn,Color3.fromRGB(20,80,20))
                else flash(runBtn,Color3.fromRGB(80,20,20)); warn("[ZyrixPanel Executor] Runtime:",rerr) end
            end
        end)
        clrBtn.MouseButton1Click:Connect(function() tb.Text="" end)
        runBtn.MouseEnter:Connect(function() pt(runBtn,0.1,{BackgroundColor3=P.HOVER}) end)
        runBtn.MouseLeave:Connect(function() pt(runBtn,0.1,{BackgroundColor3=P.INNER}) end)
        clrBtn.MouseEnter:Connect(function()  pt(clrBtn,0.1,{BackgroundColor3=P.HOVER}) end)
        clrBtn.MouseLeave:Connect(function()  pt(clrBtn,0.1,{BackgroundColor3=P.INNER}) end)
        return {
            GetValue=function() return tb.Text end,
            SetValue=function(v) tb.Text=v end,
            Execute=function()
                local fn,err=loadstring(tb.Text); if fn then pcall(fn) else warn("[ZyrixPanel Executor]",err) end
            end,
        }
    end

    -- Label
    local function addLabel(panel, text, col)
        _loMap[panel]=(_loMap[panel] or 0)+1
        local lbl=pLabel({Parent=panel, Size=UDim2.new(1,0,0,22),
            Text=text, Font=Enum.Font.Gotham, TextSize=11,
            TextColor3=col or P.TEXT_GREY, TextXAlignment=Enum.TextXAlignment.Left,
            LayoutOrder=_loMap[panel]})
        return {SetText=function(t) lbl.Text=t end}
    end

    -- ── Tab management ─────────────────────────────────────────────────────────
    local _tabLO = 0

    local function setActiveTab(name)
        _activeTab = name
        for n, b in pairs(_tabBtns) do
            local on = n == name
            local txt = b:FindFirstChild("Text")
            local ic  = b:FindFirstChild("Icon")
            local str = b:FindFirstChildOfClass("UIStroke")
            pt(b, 0.22, {BackgroundColor3 = on and P.EL or P.TAB})
            if txt then pt(txt, 0.22, {TextColor3 = on and P.WHITE or P.TEXT_DIM}) end
            if ic  then pt(ic,  0.22, {TextColor3 = on and P.WHITE or P.TEXT_DIM}) end
            if str then pt(str, 0.22, {Transparency = on and 0 or 0.5}) end
        end
        for n, p in pairs(_tabPanels) do p.Visible = n == name end
    end

    -- AddTab returns a table of element builders
    local function addTab(name, icon)
        _tabLO = _tabLO + 1

        -- Pill button
        local pill = pBtn(tabSF, UDim2.new(0,math.max(64,#name*7+24),0,math.floor(TAB_H*0.75)))
        pill.BackgroundColor3=P.EL; pill.BackgroundTransparency=0
        pill.LayoutOrder=_tabLO; pill.Name=name.."Tab"
        pCorner(pill, UDim.new(0,100))
        pStroke(pill, P.STROKE_IN, 1)
        pPad(pill, 4, 4, 8, 8)

        local ic=pLabel({Parent=pill, Size=UDim2.new(0,18,1,0),
            Text=icon or "", Font=Enum.Font.SourceSans, TextSize=15,
            TextColor3=P.TEXT_DIM, TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center, Name="Icon"})
        local txt=pLabel({Parent=pill, Size=UDim2.new(1,icon and -20 or 0,1,0),
            Position=UDim2.new(0,icon and 18 or 0,0,0),
            Text=name, Font=FONT_M, TextSize=12,
            TextColor3=P.TEXT_DIM, TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center, Name="Text"})

        pill.MouseEnter:Connect(function()
            if _activeTab ~= name then pt(pill,0.12,{BackgroundColor3=P.HOVER}) end
        end)
        pill.MouseLeave:Connect(function()
            if _activeTab ~= name then pt(pill,0.12,{BackgroundColor3=P.EL}) end
        end)
        pill.MouseButton1Click:Connect(function()
            -- auto-open panel if closed
            if not _tlOpen then openPanel() end
            setActiveTab(name)
        end)
        _tabBtns[name] = pill

        -- Panel (a Frame inside elements)
        local panel = pFrame(elements, UDim2.new(1,0,0,0), nil, P.WIN, 1)
        panel.AutomaticSize=Enum.AutomaticSize.Y; panel.Visible=false
        panel.LayoutOrder=_tabLO; panel.Name=name.."Panel"
        pList(panel, 6)
        _tabPanels[name] = panel

        if _tabLO == 1 then setActiveTab(name) end

        -- Return builder API
        return {
            Section   = function(t)                  addSection(panel,t) end,
            Toggle    = function(t,d,def,cb)          return addToggle(panel,t,d,def,cb) end,
            Slider    = function(t,mn,mx,def,sfx,cb) return addSlider(panel,t,mn,mx,def,sfx,cb) end,
            Button    = function(t,d,cb)              addButton(panel,t,d,cb) end,
            Keybind   = function(t,def,cb)            return addKeybind(panel,t,def,cb) end,
            Dropdown  = function(t,opts,def,cb)       return addDropdown(panel,t,opts,def,cb) end,
            TextBox   = function(t,ph,def,cb)         return addTextBox(panel,t,ph,def,cb) end,
            Executor  = function(ph)                  return addExecutor(panel,ph) end,
            Label     = function(t,col)               return addLabel(panel,t,col) end,
        }
    end

    -- ── Open / Close panel ──────────────────────────────────────────────────────
    local _tlOpen = false   -- start closed; openPanel() called below

    local function openPanel()
        _tlOpen=true
        mainFrame.Visible=true
        mainFrame.Size=UDim2.new(0,WIN_W,0,0)
        outer.Size=UDim2.new(0,WIN_W,0,TAB_H)
        pt(outer,0.30,{Size=UDim2.new(0,WIN_W,0,TOTAL_H)},Enum.EasingStyle.Back)
        pt(mainFrame,0.30,{Size=UDim2.new(0,WIN_W,0,WIN_H)},Enum.EasingStyle.Back)
        pt(logoBtn,0.18,{BackgroundColor3=P.TEXT})
    end

    local function closePanel()
        _tlOpen=false
        pt(outer,0.26,{Size=UDim2.new(0,WIN_W,0,TAB_H)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        pt(mainFrame,0.26,{Size=UDim2.new(0,WIN_W,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
        pt(logoBtn,0.18,{BackgroundColor3=P.LOGO_OFF})
        task.delay(0.28,function() if not _tlOpen and mainFrame then mainFrame.Visible=false end end)
    end

    logoBtn.MouseEnter:Connect(function()
        pt(logoBtn,0.12,{BackgroundColor3=_tlOpen and P.WHITE or P.HOVER})
    end)
    logoBtn.MouseLeave:Connect(function()
        pt(logoBtn,0.12,{BackgroundColor3=_tlOpen and P.TEXT or P.LOGO_OFF})
    end)
    logoBtn.MouseButton1Click:Connect(function()
        if _tlOpen then closePanel() else openPanel() end
    end)
    closeBtn.MouseButton1Click:Connect(function() closePanel() end)

    -- Keyboard shortcut
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == (getgenv().__ZyrixPanelKey or Enum.KeyCode.RightControl) then
            if _tlOpen then closePanel() else openPanel() end
        end
    end)

    -- Drag (tab bar + main frame header)
    local drag,ds,dp=false,nil,nil
    local function startDrag(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; dp=outer.Position
            i.Changed:Connect(function()
                if i.UserInputState==Enum.UserInputState.End then drag=false end
            end)
        end
    end
    tabFrame.InputBegan:Connect(startDrag)
    hdr.InputBegan:Connect(startDrag)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
            local d=i.Position-ds
            outer.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)

    -- Open the panel
    openPanel()

    -- ── Return the public API ──────────────────────────────────────────────────
    return {
        AddTab  = addTab,
        Open    = openPanel,
        Close   = closePanel,
        Toggle  = function() if _tlOpen then closePanel() else openPanel() end end,
        Destroy = function() if pSG then pSG:Destroy() end end,
        SetToggleKey = function(k) getgenv().__ZyrixPanelKey = k end,
    }
end

-- ZyrixPanel:Open() builds and shows the panel, returns the API
function ZyrixPanel:Open()
    return buildPanel()
end

getgenv().ZyrixPanel = ZyrixPanel

return Zyrix
