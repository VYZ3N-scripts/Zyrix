--[[
    Zyrix v3 — Key System + GUI Library
    • Z-logo toggles TabList with smooth slide animation
    • TabList never overlaps pill bar
    • Full script executor, all elements wired
    • Mobile + PC support
    • No bugs, no visual glitches
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end

local TS  = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS  = cloneref(game:GetService("RunService"))
local LP2 = cloneref(game:GetService("Lighting"))
local PLR = cloneref(game:GetService("Players"))
local HS  = cloneref(game:GetService("HttpService"))
local WS  = cloneref(game:GetService("Workspace"))

local hui = gethui()

if getgenv().__ZyrixActive then return getgenv().__ZyrixLib end
getgenv().__ZyrixActive = true

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

-- ── Palette ──────────────────────────────────────────────────────────────────
local C = {
    WIN      = Color3.fromRGB(0,   0,   0),
    DARK     = Color3.fromRGB(11,  11,  11),
    EL       = Color3.fromRGB(19,  19,  19),
    DARKER   = Color3.fromRGB(9,   9,   9),
    STROKE   = Color3.fromRGB(41,  41,  41),
    WHITE    = Color3.fromRGB(255, 255, 255),
    GREY     = Color3.fromRGB(141, 141, 141),
    PILL_BG  = Color3.fromRGB(11,  11,  11),
    GREEN1   = Color3.fromRGB(0,   171, 0),
    GREEN2   = Color3.fromRGB(0,   121, 0),
    SUCCESS  = Color3.fromRGB(100, 220, 100),
    ERROR    = Color3.fromRGB(255, 80,  80),
}

local FONT_B = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold,   Enum.FontStyle.Normal)
local FONT_M = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)

-- ── Low-level helpers ─────────────────────────────────────────────────────────
local function tw(obj, t, props, style)
    TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p); c.CornerRadius = r or UDim.new(0,4); return c
end

local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.STROKE; s.Thickness = thick or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function mkPad(p, t, b, l, r)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingTop    = UDim.new(0, t or 0); pad.PaddingBottom = UDim.new(0, b or 0)
    pad.PaddingLeft   = UDim.new(0, l or 0); pad.PaddingRight  = UDim.new(0, r or 0)
end

local function mkList(p, spacing, dir)
    local l = Instance.new("UIListLayout", p)
    l.Padding = UDim.new(0, spacing or 5); l.SortOrder = Enum.SortOrder.LayoutOrder
    l.FillDirection = dir or Enum.FillDirection.Vertical
    return l
end

local function mkFrame(props)
    local f = Instance.new("Frame"); f.BorderSizePixel = 0
    for k,v in pairs(props) do f[k] = v end; return f
end

local function mkLabel(props)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1
    for k,v in pairs(props) do l[k] = v end; return l
end

local function mkBtn(props)
    local b = Instance.new("TextButton"); b.AutoButtonColor = false
    b.Text = ""; b.BorderSizePixel = 0
    for k,v in pairs(props) do b[k] = v end; return b
end

local function mkImage(props)
    local i = Instance.new("ImageLabel"); i.BackgroundTransparency = 1
    i.ScaleType = Enum.ScaleType.Fit
    for k,v in pairs(props) do i[k] = v end; return i
end

local function mkScroll(parent, size, pos)
    local sf = Instance.new("ScrollingFrame")
    sf.Size = size or UDim2.new(1,0,1,0)
    sf.Position = pos or UDim2.new(0,0,0,0)
    sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
    sf.ScrollBarThickness = 2; sf.ScrollBarImageColor3 = C.GREY
    sf.ScrollBarImageTransparency = 0.3
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.Parent = parent; return sf
end

local function draggable(handle, root)
    local drag, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = i.Position; dp = root.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            root.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  ZyrixUI
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixUI = {}

-- Layout constants  (all pixel-exact from G2L)
local WIN_W     = 563
local WIN_H     = 354   -- G2L["2"] height
local PILL_H    = 41    -- G2L["41"/"42"] height
local PILL_LOGO = 34    -- logo area width inside pill bar
local EL_X_OFF  = math.floor(WIN_W * 0.00979)  -- G2L elements x offset
local EL_Y_OFF  = 38                             -- below separator
local EL_W      = 546   -- G2L["6"] width
local EL_H      = 311   -- G2L["6"] height

-- State
local _sg        = nil
local _outer     = nil
local _pillFrame = nil
local _pillSF    = nil
local _tablist   = nil
local _elements  = nil
local _tabBtns   = {}
local _tabPanels = {}
local _activeTab = nil
local _tabLO     = 0
local _tlOpen    = true   -- tablist open state

-- ── Tab switcher ─────────────────────────────────────────────────────────────
local function switchTab(name)
    if _activeTab == name then return end
    _activeTab = name
    for n, b in pairs(_tabBtns) do
        local on = n == name
        b.TextColor3       = on and C.WHITE or C.GREY
        b.BackgroundColor3 = on and Color3.fromRGB(28,28,28) or C.EL
        local s = b:FindFirstChildOfClass("UIStroke")
        if s then s.Color = on and Color3.fromRGB(90,90,90) or C.STROKE end
    end
    for n, p in pairs(_tabPanels) do
        p.Visible = n == name
    end
end

-- ── Smooth TabList toggle ─────────────────────────────────────────────────────
-- The outer frame height = PILL_H + WIN_H when open, PILL_H when closed.
-- The TabList just slides down/up inside the outer (ClipsDescendants handles hide).
local function toggleTablist(logoBtn)
    _tlOpen = not _tlOpen
    if _tlOpen then
        -- expand outer, show tablist
        _tablist.Visible = true
        tw(_outer, 0.30, {Size = UDim2.new(0, WIN_W, 0, PILL_H + WIN_H)}, Enum.EasingStyle.Quart)
        tw(_tablist, 0.30, {Position = UDim2.new(0, 0, 0, PILL_H), BackgroundTransparency = 0.1}, Enum.EasingStyle.Quart)
        tw(logoBtn, 0.20, {ImageColor3 = C.WHITE})
    else
        -- collapse outer, slide tablist up
        tw(_outer, 0.28, {Size = UDim2.new(0, WIN_W, 0, PILL_H)}, Enum.EasingStyle.Quart)
        tw(_tablist, 0.28, {Position = UDim2.new(0, 0, 0, PILL_H - WIN_H * 0.05), BackgroundTransparency = 1}, Enum.EasingStyle.Quart)
        tw(logoBtn, 0.20, {ImageColor3 = C.GREY})
        task.delay(0.30, function()
            if not _tlOpen and _tablist then _tablist.Visible = false end
        end)
    end
end

-- ── Build shell ───────────────────────────────────────────────────────────────
local function buildShell()
    if _sg then _sg:Destroy() end
    _tabBtns = {}; _tabPanels = {}; _activeTab = nil; _tabLO = 0; _tlOpen = true

    _sg = Instance.new("ScreenGui")
    _sg.Name = "ZyrixMainUI"; _sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _sg.ResetOnSpawn = false; _sg.IgnoreGuiInset = true; _sg.DisplayOrder = 50
    _sg.Parent = hui

    -- ── Outer clipping container ──────────────────────────────────────────────
    -- Height starts at PILL_H + WIN_H (open), shrinks to PILL_H when closed.
    -- ClipsDescendants hides the tablist when collapsing.
    local outer = mkFrame({
        Name = "ZyrixOuter",
        Size = UDim2.new(0, WIN_W, 0, PILL_H + WIN_H),
        Position = UDim2.new(0.5, -WIN_W/2, 0.5, -(PILL_H+WIN_H)/2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = _sg,
    })
    _outer = outer

    -- ── Pill bar (G2L["41"/"42"]) — FIXED, never moves ────────────────────────
    local pillFrame = mkFrame({
        Name = "PillFrame",
        Size = UDim2.new(0, WIN_W, 0, PILL_H),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = C.PILL_BG,
        Parent = outer,
    })
    mkStroke(pillFrame)
    mkCorner(pillFrame, UDim.new(0, 100))
    _pillFrame = pillFrame

    -- Logo / toggle button
    local logoBtn = Instance.new("ImageButton", pillFrame)
    logoBtn.Name = "LogoBtn"; logoBtn.BorderSizePixel = 0
    logoBtn.BackgroundTransparency = 1; logoBtn.ImageColor3 = C.WHITE
    logoBtn.Image = "rbxassetid://105436073524298"
    logoBtn.Size = UDim2.new(0, 24, 0, 28)
    logoBtn.Position = UDim2.new(0, 6, 0.5, 0); logoBtn.AnchorPoint = Vector2.new(0, 0.5)

    -- Hover effect on logo
    logoBtn.MouseEnter:Connect(function() tw(logoBtn, 0.12, {ImageColor3 = C.WHITE}) end)
    logoBtn.MouseLeave:Connect(function()
        tw(logoBtn, 0.12, {ImageColor3 = _tlOpen and C.WHITE or C.GREY})
    end)
    logoBtn.MouseButton1Click:Connect(function() toggleTablist(logoBtn) end)

    -- Pill scrolling frame (G2L["42"])
    local pillSF = Instance.new("ScrollingFrame", pillFrame)
    pillSF.Active = true; pillSF.ScrollingDirection = Enum.ScrollingDirection.X
    pillSF.BorderSizePixel = 0; pillSF.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    pillSF.ElasticBehavior = Enum.ElasticBehavior.Always
    pillSF.BackgroundColor3 = C.PILL_BG; pillSF.BackgroundTransparency = 0.1
    pillSF.Size = UDim2.new(1, -(PILL_LOGO+4), 1, 0)
    pillSF.Position = UDim2.new(0, PILL_LOGO+2, 0, 0)
    pillSF.ScrollBarImageColor3 = C.GREY; pillSF.ScrollBarThickness = 2
    pillSF.CanvasSize = UDim2.new(0,0,0,0); pillSF.AutomaticCanvasSize = Enum.AutomaticSize.X
    mkCorner(pillSF, UDim.new(0,100))
    mkPad(pillSF, 3, 3, 4, 4)
    local pLayout = mkList(pillSF, 4, Enum.FillDirection.Horizontal)
    pLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    _pillSF = pillSF

    draggable(pillFrame, outer)

    -- ── TabList (G2L["2"]) ────────────────────────────────────────────────────
    local tablist = mkFrame({
        Name = "Tablist",
        Size = UDim2.new(0, WIN_W, 0, WIN_H),
        Position = UDim2.new(0, 0, 0, PILL_H),   -- always just below pill bar
        BackgroundColor3 = C.WIN,
        BackgroundTransparency = 0.1,
        Parent = outer,
    })
    mkCorner(tablist)
    mkStroke(tablist, C.STROKE, 1)
    _tablist = tablist

    -- Title area inside tablist (G2L["3"/"4"])
    mkLabel({
        Size=UDim2.new(0,480,0,23), Position=UDim2.new(0,32,0,6),
        Text="zyrix", TextColor3=C.WHITE, TextSize=14, FontFace=FONT_B,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=tablist,
    })
    mkImage({
        Size=UDim2.new(0,26,0,29), Position=UDim2.new(0,5,0,6),
        Image="rbxassetid://105436073524298", ImageColor3=C.GREY, Parent=tablist,
    })

    -- Separator line (G2L["5"])
    mkFrame({
        Size=UDim2.new(0,WIN_W,0,1), Position=UDim2.new(0,0,0,37),
        BackgroundColor3=Color3.fromRGB(31,31,31), Parent=tablist,
    })

    -- Elements scroll (G2L["6"])
    local elements = mkScroll(tablist, UDim2.new(0,EL_W,0,EL_H), UDim2.new(0,EL_X_OFF,0,EL_Y_OFF))
    elements.Name = "elements"
    mkPad(elements, 6, 6, 8, 8)
    mkList(elements, 5)
    _elements = elements

    -- Entrance animation
    outer.Size = UDim2.new(0, WIN_W, 0, 0)
    tw(outer, 0.32, {Size=UDim2.new(0,WIN_W,0,PILL_H+WIN_H)}, Enum.EasingStyle.Back)

    -- Keyboard toggle (PC)
    if not isMobile then
        getgenv().__ZyrixToggleKey = getgenv().__ZyrixToggleKey or Enum.KeyCode.RightShift
        UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if i.KeyCode == getgenv().__ZyrixToggleKey and _sg then
                toggleTablist(logoBtn)
            end
        end)
    end
end

-- ── AddTab ────────────────────────────────────────────────────────────────────
function ZyrixUI:AddTab(name, icon)
    if not _sg then warn("[ZyrixUI] Call Open() first"); return {} end
    _tabLO = _tabLO + 1

    -- Pill button (G2L["43"])
    local pill = Instance.new("TextButton", _pillSF)
    pill.BorderSizePixel = 0; pill.TextSize = 12
    pill.TextColor3 = C.GREY; pill.BackgroundColor3 = C.EL
    pill.FontFace = FONT_M
    pill.Size = UDim2.new(0, math.max(60, #name*7+20), 0, 35)
    pill.Text = (icon and icon.." " or "")..name
    pill.AutoButtonColor = false; pill.LayoutOrder = _tabLO
    mkCorner(pill, UDim.new(0,100)); mkStroke(pill)
    mkPad(pill, 4, 4, 8, 8)
    pill.MouseButton1Click:Connect(function()
        -- also open tablist if closed
        if not _tlOpen then
            local logo = _pillFrame and _pillFrame:FindFirstChild("LogoBtn")
            if logo then toggleTablist(logo) end
        end
        switchTab(name)
    end)
    _tabBtns[name] = pill

    -- Content panel
    local panel = mkFrame({
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1, Visible=false, LayoutOrder=_tabLO,
        Parent=_elements,
    })
    mkList(panel, 5)
    _tabPanels[name] = panel

    if _tabLO == 1 then switchTab(name) end

    -- ── Element builders ──────────────────────────────────────────────────────
    local lo = 0
    local function nlo() lo=lo+1; return lo end

    -- Base element frame
    local function baseEl(h)
        local f = mkFrame({Size=UDim2.new(1,0,0,h), BackgroundColor3=C.EL, LayoutOrder=nlo(), Parent=panel})
        mkCorner(f)
        local s = mkStroke(f)
        local g = Instance.new("UIGradient", s)
        g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
        mkPad(f, 6, 6, 10, 10)
        return f, s, g
    end

    local tab = {}

    -- Section header
    function tab:Section(title)
        lo = lo + 1
        local s = mkFrame({Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=lo,Parent=panel})
        mkLabel({Size=UDim2.new(1,0,1,0),Text=title:upper(),TextColor3=Color3.fromRGB(90,90,90),TextSize=9,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=s})
        mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.STROKE,Parent=s})
    end

    -- Toggle (G2L["2c"] exact)
    function tab:Toggle(title, desc, default, callback)
        local state = default or false
        local h = desc and 50 or 37
        local el, elStr, elGrad = baseEl(h)

        -- title label
        local tl = mkLabel({
            TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0,250,0,14),Text=title,
            Position=UDim2.new(1.06076,-63,desc and 0 or 0.5,desc and 8 or 0),
            Parent=el,
        })
        if desc then
            mkLabel({Size=UDim2.new(0.7,0,0,12),Position=UDim2.new(0,0,1,-18),
                Text=desc,TextColor3=Color3.fromRGB(100,100,100),TextSize=10,
                Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        end

        -- Switch (G2L["2f"])
        local sw = mkFrame({
            BackgroundColor3=C.DARKER,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0,43,0,21),
            Position=UDim2.new(1.05371,-10,desc and 0 or 0.5,desc and 10 or 0),
            Parent=el,
        })
        mkStroke(sw); mkCorner(sw,UDim.new(1,0))

        -- Indicator dot (G2L["30"])
        local dot = mkFrame({
            BackgroundColor3=state and C.WHITE or C.GREY,
            AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(0,17,0,17),
            Position=UDim2.new(state and 1 or 0,state and -19 or 2,0.5,0),
            Parent=sw,
        })
        local ds = Instance.new("UIStroke",dot); ds.Thickness=1.2
        mkCorner(dot,UDim.new(1,0))

        if state then
            elGrad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0,C.GREEN1),ColorSequenceKeypoint.new(1,C.GREEN2)}
        end

        -- Interact hit zone (G2L["2e"])
        local hit = mkBtn({
            ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0.36935,0,1,0),Position=UDim2.new(0.81532,0,0.5,0),
            Parent=el,
        })
        hit.MouseButton1Click:Connect(function()
            state = not state
            tw(dot,0.15,{Position=UDim2.new(state and 1 or 0,state and -19 or 2,0.5,0),BackgroundColor3=state and C.WHITE or C.GREY})
            elGrad.Color = state
                and ColorSequence.new{ColorSequenceKeypoint.new(0,C.GREEN1),ColorSequenceKeypoint.new(1,C.GREEN2)}
                or  ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
            if callback then pcall(callback,state) end
        end)
        return {
            GetValue=function() return state end,
            SetValue=function(v)
                state=v
                dot.Position=UDim2.new(v and 1 or 0,v and -19 or 2,0.5,0)
                dot.BackgroundColor3=v and C.WHITE or C.GREY
                elGrad.Color=v
                    and ColorSequence.new{ColorSequenceKeypoint.new(0,C.GREEN1),ColorSequenceKeypoint.new(1,C.GREEN2)}
                    or  ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.new(0,0,0)),ColorSequenceKeypoint.new(1,Color3.new(0,0,0))}
            end,
        }
    end

    -- Slider (G2L["1f"] exact)
    function tab:Slider(title, min, max, default, suffix, callback)
        if type(suffix)=="function" then callback=suffix; suffix="units" end
        suffix=suffix or "units"; min=min or 0; max=max or 100
        default=math.clamp(default or min,min,max)
        local value=default
        local el,_,_ = baseEl(47)

        mkLabel({TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,200,0,14),Text=title,Position=UDim2.new(0.32525,0,0.5,0),Parent=el})

        -- Slider box (G2L["21"])
        local main = mkFrame({BackgroundColor3=C.DARKER,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,222,0,30),Position=UDim2.new(0.61986,0,0.5,0),Parent=el})
        local ms=Instance.new("UIStroke",main); ms.Transparency=0.2; ms.Thickness=0.5
        ms.Color=C.STROKE; ms.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
        mkCorner(main)

        -- Progress fill (G2L["23"])
        local prog=mkFrame({BackgroundColor3=C.WHITE,
            Size=UDim2.new((value-min)/(max-min),0,1,0),Parent=main})
        local ps=Instance.new("UIStroke",prog); ps.Transparency=0.2; ps.Thickness=1.2
        mkCorner(prog)

        -- Info label (G2L["26"])
        local info=mkLabel({ZIndex=5,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,
            TextTransparency=0.3,FontFace=FONT_M,TextColor3=C.GREY,
            AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,168,0,15),
            Text=tostring(value).." "..suffix,Position=UDim2.new(0.4536,0,0.5,0),Parent=main})

        -- Hit zone (G2L["27"])
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

    -- Button (G2L["18"] exact)
    function tab:Button(title, callback)
        local el,_,_ = baseEl(35)
        mkLabel({TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,307,0,14),Text=title,Position=UDim2.new(0.50604,0,0.47561,0),Parent=el})
        mkLabel({TextWrapped=true,TextSize=10,TextXAlignment=Enum.TextXAlignment.Right,
            TextTransparency=0.5,FontFace=FONT_M,TextColor3=C.GREY,
            AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(0,108,0,13),Text="Button",
            Position=UDim2.new(0.77168,0,0.47561,0),Parent=el})
        local hit=mkBtn({ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),Parent=el})
        hit.MouseButton1Click:Connect(function()
            tw(el,0.06,{BackgroundColor3=Color3.fromRGB(30,30,30)})
            task.delay(0.1,function() tw(el,0.1,{BackgroundColor3=C.EL}) end)
            if callback then pcall(callback) end
        end)
    end

    -- Keybind (G2L["36"] exact)
    function tab:Keybind(title, default, callback)
        local key=default or Enum.KeyCode.Unknown
        local el,_,_ = baseEl(37)
        mkLabel({TextWrapped=true,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,200,0,14),Text=title,Position=UDim2.new(0.32525,0,0.5,0),Parent=el})

        local kbf=mkFrame({BackgroundColor3=C.DARKER,AnchorPoint=Vector2.new(1,0.5),
            Size=UDim2.new(0,40,0,21),Position=UDim2.new(1.04045,-7,0.5,0),Parent=el})
        mkStroke(kbf); mkCorner(kbf)

        local kbBox=Instance.new("TextBox",kbf)
        kbBox.BorderSizePixel=0; kbBox.TextSize=11; kbBox.TextColor3=C.WHITE
        kbBox.BackgroundTransparency=1; kbBox.FontFace=FONT_M
        kbBox.AnchorPoint=Vector2.new(0.5,0.5); kbBox.ClearTextOnFocus=false
        kbBox.PlaceholderText="Key"; kbBox.PlaceholderColor3=Color3.fromRGB(179,179,179)
        kbBox.Size=UDim2.new(1,-4,0,14); kbBox.Position=UDim2.new(0.5,0,0.5,0)
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

    -- Dropdown (G2L["7"] exact)
    function tab:Dropdown(title, options, default, callback)
        local selected=default or (options and options[1]) or ""
        local isOpen=false; local ITEM_H=35
        local el,elStr,_ = baseEl(37)
        el.ClipsDescendants=false; el.ZIndex=5

        -- Stroke gradient (G2L["15"])
        local dg=Instance.new("UIGradient",elStr)
        dg.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(90,90,90)),ColorSequenceKeypoint.new(1,Color3.fromRGB(90,90,90))}

        -- Title (G2L["8"])
        mkLabel({TextWrapped=true,ZIndex=3,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,201,0,14),Text=title,Position=UDim2.new(0,99,0,12),Parent=el})

        -- Selected label (G2L["11"])
        local selLbl=mkLabel({TextWrapped=true,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,
            FontFace=FONT_M,TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),
            Size=UDim2.new(0,168,0,14),Text=selected,Position=UDim2.new(0,74,0,12),Parent=el})

        -- Arrow
        local arrow=mkLabel({Size=UDim2.new(0,20,0,14),Position=UDim2.new(1,-22,0,10),
            Text="▾",TextColor3=C.GREY,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=3,Parent=el})

        -- List frame (G2L["9"])
        local listF=mkFrame({BackgroundColor3=C.EL,
            Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,3),
            ClipsDescendants=true,ZIndex=10,Parent=el})
        mkStroke(listF); mkCorner(listF)

        local listSF=mkScroll(listF,UDim2.new(1,0,1,0))
        listSF.ZIndex=11; listSF.ScrollBarImageTransparency=0.7
        mkList(listSF,2)

        for _,opt in ipairs(options or {}) do
            local row=mkFrame({BackgroundColor3=C.DARKER,Size=UDim2.new(0.97745,0,0,ITEM_H-2),Parent=listSF})
            local rs=Instance.new("UIStroke",row); rs.Thickness=0.8; rs.Color=C.WHITE; rs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
            mkCorner(row)
            mkLabel({TextWrapped=true,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,FontFace=FONT_M,
                TextColor3=C.WHITE,AnchorPoint=Vector2.new(0.5,0.5),ZIndex=12,
                Size=UDim2.new(0,168,0,15),Text=opt,Position=UDim2.new(0.49503,0,0.42125,0),Parent=row})
            local rh=mkBtn({ZIndex=5,Size=UDim2.new(1,0,1,0),Parent=row})
            rh.MouseEnter:Connect(function() tw(row,0.08,{BackgroundColor3=C.EL}) end)
            rh.MouseLeave:Connect(function() tw(row,0.08,{BackgroundColor3=C.DARKER}) end)
            rh.MouseButton1Click:Connect(function()
                selected=opt; selLbl.Text=opt; isOpen=false
                tw(arrow,0.12,{Rotation=0}); tw(listF,0.15,{Size=UDim2.new(1,0,0,0)})
                el.Size=UDim2.new(1,0,0,37)
                if callback then pcall(callback,opt) end
            end)
        end

        local maxH=ITEM_H*math.min(#(options or {}),5)+6
        local hit=mkBtn({ZIndex=5,AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),Parent=el})
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
        local el,_,_ = baseEl(58)
        mkLabel({Size=UDim2.new(1,0,0,14),Text=title,TextColor3=C.WHITE,TextSize=12,
            FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        local ibg=mkFrame({Size=UDim2.new(1,0,0,28),Position=UDim2.new(0,0,0,18),
            BackgroundColor3=C.DARKER,Parent=el})
        mkCorner(ibg); local ibs=mkStroke(ibg)
        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-8,1,0); tb.Position=UDim2.new(0,4,0,0)
        tb.BackgroundTransparency=1; tb.Text=default or ""
        tb.PlaceholderText=placeholder or ""; tb.PlaceholderColor3=Color3.fromRGB(80,80,80)
        tb.TextColor3=C.WHITE; tb.TextSize=12; tb.FontFace=FONT_M
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.Focused:Connect(function() ibs.Color=C.WHITE end)
        tb.FocusLost:Connect(function(enter)
            ibs.Color=C.STROKE
            if enter and callback then pcall(callback,tb.Text) end
        end)
        return {GetValue=function() return tb.Text end, SetValue=function(v) tb.Text=v end}
    end

    -- Script Executor (multiline, working execute + clear)
    function tab:Executor(placeholder)
        lo=lo+1
        local cont=mkFrame({Size=UDim2.new(1,0,0,130),BackgroundColor3=C.EL,
            LayoutOrder=lo,Parent=panel})
        mkCorner(cont); mkStroke(cont); mkPad(cont,6,6,10,10)

        mkLabel({Size=UDim2.new(1,0,0,14),Text="Script Executor",TextColor3=C.WHITE,
            TextSize=12,FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=cont})

        local ibg=mkFrame({Size=UDim2.new(1,0,0,76),Position=UDim2.new(0,0,0,18),
            BackgroundColor3=C.DARKER,Parent=cont})
        mkCorner(ibg); mkStroke(ibg)

        local tb=Instance.new("TextBox",ibg)
        tb.Size=UDim2.new(1,-8,1,-4); tb.Position=UDim2.new(0,4,0,2)
        tb.BackgroundTransparency=1; tb.Text=""
        tb.PlaceholderText=placeholder or "-- Enter script here..."
        tb.PlaceholderColor3=Color3.fromRGB(80,80,80)
        tb.TextColor3=C.WHITE; tb.TextSize=11; tb.FontFace=FONT_M
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.TextYAlignment=Enum.TextYAlignment.Top
        tb.MultiLine=true; tb.TextWrapped=true

        -- Run button
        local runBtn=mkBtn({Size=UDim2.new(0.49,0,0,20),Position=UDim2.new(0,0,1,-22),
            AnchorPoint=Vector2.new(0,1),BackgroundColor3=C.DARKER,
            TextColor3=C.WHITE,TextSize=11,FontFace=FONT_M,Text="▶  Execute",Parent=cont})
        mkCorner(runBtn); mkStroke(runBtn)

        -- Clear button
        local clrBtn=mkBtn({Size=UDim2.new(0.49,0,0,20),Position=UDim2.new(1,0,1,-22),
            AnchorPoint=Vector2.new(1,1),BackgroundColor3=C.DARKER,
            TextColor3=C.GREY,TextSize=11,FontFace=FONT_M,Text="✕  Clear",Parent=cont})
        mkCorner(clrBtn); mkStroke(clrBtn)

        local function flashBtn(btn, col)
            tw(btn,0.08,{TextColor3=col})
            task.delay(1.2, function() tw(btn,0.2,{TextColor3=btn==runBtn and C.WHITE or C.GREY}) end)
        end

        runBtn.MouseButton1Click:Connect(function()
            local code=tb.Text
            if code=="" or code:match("^%s*$") then return end
            local fn,err=loadstring(code)
            if not fn then
                flashBtn(runBtn,C.ERROR)
                warn("[ZyrixUI Executor] Syntax error: "..tostring(err))
            else
                local ok,rerr=pcall(fn)
                if ok then flashBtn(runBtn,C.SUCCESS)
                else
                    flashBtn(runBtn,C.ERROR)
                    warn("[ZyrixUI Executor] Runtime error: "..tostring(rerr))
                end
            end
        end)
        clrBtn.MouseButton1Click:Connect(function() tb.Text="" end)

        runBtn.MouseEnter:Connect(function() tw(runBtn,0.1,{BackgroundColor3=C.EL}) end)
        runBtn.MouseLeave:Connect(function() tw(runBtn,0.1,{BackgroundColor3=C.DARKER}) end)
        clrBtn.MouseEnter:Connect(function() tw(clrBtn,0.1,{BackgroundColor3=C.EL}) end)
        clrBtn.MouseLeave:Connect(function() tw(clrBtn,0.1,{BackgroundColor3=C.DARKER}) end)

        return {
            GetValue = function() return tb.Text end,
            SetValue = function(v) tb.Text=v end,
            Execute  = function()
                local fn,err=loadstring(tb.Text)
                if fn then pcall(fn) else warn("[ZyrixUI Executor]",err) end
            end,
        }
    end

    -- Label
    function tab:Label(text, col)
        lo=lo+1
        local lbl=mkLabel({Size=UDim2.new(1,0,0,22),Text=text,
            TextColor3=col or C.GREY,TextSize=11,FontFace=FONT_M,
            TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=lo,Parent=panel})
        return {SetText=function(t) lbl.Text=t end}
    end

    -- In-panel toast notification
    function tab:Notify(msg, dur)
        dur=dur or 3; lo=lo+1
        local n=mkFrame({Size=UDim2.new(1,0,0,30),BackgroundColor3=C.DARKER,LayoutOrder=lo,Parent=panel})
        mkCorner(n); mkStroke(n); mkPad(n,0,0,8,8)
        mkLabel({Size=UDim2.new(1,0,1,0),Text=msg,TextColor3=C.WHITE,TextSize=11,
            FontFace=FONT_M,TextXAlignment=Enum.TextXAlignment.Left,Parent=n})
        task.delay(dur,function()
            if n and n.Parent then
                tw(n,0.2,{BackgroundTransparency=1})
                task.wait(0.22); n:Destroy()
            end
        end)
    end

    return tab
end

-- ── Public API ────────────────────────────────────────────────────────────────
function ZyrixUI:Open()  buildShell() end
function ZyrixUI:Close() if _sg then _sg:Destroy(); _sg=nil end end
function ZyrixUI:Toggle()
    if _pillFrame then
        local logo=_pillFrame:FindFirstChild("LogoBtn")
        if logo then toggleTablist(logo) end
    end
end
function ZyrixUI:SetTitle(text)
    if _tablist then
        local lbl=_tablist:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text=text end
    end
end

getgenv().ZyrixUI = ZyrixUI

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
    pcall(function()
        if not isfolder(KF) then makefolder(KF) end
        writefile(KF.."/"..name..".txt",key)
    end)
end
local function loadKey(name)
    if not FS then return nil end
    local ok,v=pcall(function()
        local p=KF.."/"..name..".txt"
        return isfile(p) and readfile(p) or nil
    end)
    return (ok and v and v~="") and v or nil
end
local function clearKey(name)
    if not FS then return end
    pcall(delfile,KF.."/"..name..".txt")
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
    bg.Name="ZyrixBackground";bg.ResetOnSpawn=false
    bg.IgnoreGuiInset=true;bg.DisplayOrder=-10;bg.Parent=hui

    local canvas=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(4,4,4),BackgroundTransparency=1,Parent=bg})

    local vp=WS.CurrentCamera.ViewportSize; local cell=55
    local grid=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,Parent=canvas})
    for i=0,math.ceil(vp.X/cell)+2 do
        mkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(0,i*cell,0,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid})
    end
    for i=0,math.ceil(vp.Y/cell)+2 do
        mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,i*cell),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94,Parent=grid})
    end
    local off=0
    RS.Heartbeat:Connect(function(dt)
        if not grid or not grid.Parent then return end
        off=(off+dt*5)%cell; grid.Position=UDim2.new(0,-off,0,-off)
    end)

    local pc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=2,Parent=canvas})
    local function spawnP(instant)
        local sz=math.random(2,4);local px=math.random(0,100)/100
        local py=instant and math.random(0,100)/100 or 1.05
        local spd=math.random(20,50);local drift=(math.random(-20,20))/1000
        local p=mkFrame({Size=UDim2.new(0,sz,0,sz),Position=UDim2.new(px,0,py,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.65,ZIndex=2,Parent=pc})
        mkCorner(p,UDim.new(1,0))
        local c3
        c3=RS.Heartbeat:Connect(function(dt)
            if not p or not p.Parent then if c3 then c3:Disconnect() end;return end
            py=py-dt/spd;px=px+drift*dt;p.Position=UDim2.new(px,0,py,0)
            p.BackgroundTransparency=1-(0.35)*math.clamp(py*5,0,1)*math.clamp((1-py)*5,0,1)
            if py<-0.05 then c3:Disconnect();p:Destroy();task.delay(math.random(1,3),function() spawnP(false) end) end
        end)
    end
    for i=1,20 do task.delay(i*0.1,function() spawnP(true) end) end

    local wm=mkFrame({Size=UDim2.new(0,115,0,32),Position=UDim2.new(0,10,0,8),BackgroundColor3=Color3.fromRGB(10,10,10),BackgroundTransparency=0.35,ZIndex=5,Parent=canvas})
    mkCorner(wm,UDim.new(0,6));mkStroke(wm,Color3.fromRGB(40,40,40),1)
    mkImage({Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,7,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,ZIndex=6,Parent=wm})
    mkLabel({Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,28,0,0),Text=Zyrix.Appearance.Title,TextColor3=Color3.new(1,1,1),TextSize=13,Font=Enum.Font.GothamBold,ZIndex=6,Parent=wm})

    TS:Create(canvas,TweenInfo.new(0.5),{BackgroundTransparency=0}):Play()
    return bg
end

local function removeBG()
    local bg=hui:FindFirstChild("ZyrixBackground");if not bg then return end
    local c=bg:FindFirstChildOfClass("Frame")
    if c then TS:Create(c,TweenInfo.new(0.4),{BackgroundTransparency=1}):Play() end
    task.delay(0.45,function() if bg and bg.Parent then bg:Destroy() end end)
end

-- Notifications
local _notifs={}
function Zyrix:Notify(title,msg,dur,itype)
    dur=dur or 4; local W,H=280,66
    local ng=Instance.new("ScreenGui");ng.ResetOnSpawn=false;ng.DisplayOrder=999;ng.Parent=hui
    local f=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(1,W+10,1,-12),AnchorPoint=Vector2.new(1,1),BackgroundColor3=T.Header,Parent=ng})
    mkCorner(f,UDim.new(0,6));mkStroke(f,T.Accent,1)
    local imap={success={ico("check"),T.Success},error={ico("alert"),T.Error},warning={ico("alert"),T.TextDim},info={ico("shield"),T.Accent},copy={ico("copy"),T.Success},discord={ico("discord"),Color3.fromRGB(180,180,255)},close={ico("close"),T.Error}}
    local im=imap[itype or "info"] or imap["info"]
    mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,11,0.5,-1),AnchorPoint=Vector2.new(0,0.5),Image=im[1],ImageColor3=im[2],Parent=f})
    mkLabel({Size=UDim2.new(1,-46,0,18),Position=UDim2.new(0,40,0,10),Text=title,TextColor3=T.Text,TextSize=12,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    mkLabel({Size=UDim2.new(1,-46,0,16),Position=UDim2.new(0,40,0,30),Text=msg,TextColor3=T.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=f})
    local pb=mkFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=Color3.fromRGB(30,30,30),Parent=f})
    local pf=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,Parent=pb})
    mkCorner(pb,UDim.new(1,0));mkCorner(pf,UDim.new(1,0))
    local id=tostring(tick()); table.insert(_notifs,{id=id,f=f,gui=ng,h=H})
    local function restack()
        local y=0
        for i=#_notifs,1,-1 do local n=_notifs[i]
            if n and n.f and n.f.Parent then
                TS:Create(n.f,TweenInfo.new(0.22),{Position=UDim2.new(1,-12,1,-12-y)}):Play()
                y=y+n.h+8 end end
    end
    local function dismiss()
        for i,n in ipairs(_notifs) do if n.id==id then table.remove(_notifs,i);break end end
        TS:Create(f,TweenInfo.new(0.22),{Position=UDim2.new(1,W+10,f.Position.Y.Scale,f.Position.Y.Offset)}):Play()
        task.wait(0.25);ng:Destroy();restack()
    end
    TS:Create(f,TweenInfo.new(0.28),{Position=UDim2.new(1,-12,1,-12)}):Play()
    task.wait(0.05);restack()
    TS:Create(pf,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(dur,dismiss)
    local cb2=mkBtn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=f})
    cb2.MouseButton1Click:Connect(dismiss)
end

local function validateKey(key,fn)
    if not fn or not key or key=="" then return false end
    local ok,r=pcall(fn,key);if not ok then return false end
    if type(r)=="table" then return r.valid==true end
    if type(r)=="boolean" then return r end
    return false
end

-- Key UI
local function buildKeyUI()
    local old=hui:FindFirstChild("ZyrixKeySystem");if old then old:Destroy() end
    enableBlur()
    local W=isMobile and 320 or 380; local H=isMobile and 280 or 300

    local sg=Instance.new("ScreenGui")
    sg.Name="ZyrixKeySystem";sg.ResetOnSpawn=false
    sg.IgnoreGuiInset=true;sg.DisplayOrder=10;sg.Parent=hui

    local cont=mkFrame({Size=UDim2.new(0,W,0,H),Position=UDim2.new(0.5,-W/2,0.5,-H/2),BackgroundTransparency=1,Parent=sg})
    cont.Position=UDim2.new(0.5,-W/2,1.5,0)

    local main=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Background,Parent=cont})
    mkCorner(main,UDim.new(0,8));mkStroke(main,T.Accent,1)

    -- Header
    local hdr=mkFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,Parent=main})
    mkCorner(hdr,UDim.new(0,8))
    mkFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,Parent=hdr})
    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,Parent=hdr})
    mkImage({Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=Zyrix.Appearance.Icon,Parent=hdr})
    mkLabel({Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Title,TextColor3=T.Text,TextSize=18,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})
    local closeBtnI=mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),Image=ico("close"),ImageColor3=T.TextDim,Parent=hdr})
    local closeBtnH=mkBtn({Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundTransparency=1,Parent=hdr})
    closeBtnH.MouseEnter:Connect(function() tw(closeBtnI,0.1,{ImageColor3=T.Error}) end)
    closeBtnH.MouseLeave:Connect(function() tw(closeBtnI,0.1,{ImageColor3=T.TextDim}) end)

    -- Status box
    local statBox=mkFrame({Size=UDim2.new(0.92,0,0,52),Position=UDim2.new(0.5,0,0,58),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    mkCorner(statBox,UDim.new(0,6));mkStroke(statBox,T.Accent,1)
    local statIcon=mkImage({Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=ico("lock"),ImageColor3=T.StatusIdle,Parent=statBox})
    local statLbl=mkLabel({Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,42,0,0),Text=Zyrix.Appearance.Subtitle,TextColor3=T.StatusIdle,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=statBox})

    -- Input
    local inpBox=mkFrame({Size=UDim2.new(0.92,0,0,44),Position=UDim2.new(0.5,0,0,120),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
    mkCorner(inpBox,UDim.new(0,6));local ibs=mkStroke(inpBox,T.Accent,1)
    mkImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,10,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=ico("key"),ImageColor3=T.TextDim,Parent=inpBox})
    local tb=Instance.new("TextBox");tb.Size=UDim2.new(1,-34,1,0);tb.Position=UDim2.new(0,28,0,0)
    tb.BackgroundTransparency=1;tb.Text="";tb.PlaceholderText="Enter your key..."
    tb.PlaceholderColor3=T.TextDim;tb.TextColor3=T.Text;tb.TextSize=14
    tb.Font=Enum.Font.Gotham;tb.ClearTextOnFocus=false;tb.TextXAlignment=Enum.TextXAlignment.Left;tb.Parent=inpBox
    tb.Focused:Connect(function() ibs.Transparency=0.4 end)
    tb.FocusLost:Connect(function() ibs.Transparency=0.82 end)

    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,174),BackgroundColor3=T.Divider,Parent=main})

    -- Action buttons
    local function actionBtn(lbl2,ic,primary,y)
        local b=mkBtn({Size=UDim2.new(0.78,0,0,36),Position=UDim2.new(0.5,0,0,y),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=primary and T.Accent or T.Input,Parent=main})
        mkCorner(b,UDim.new(0,6));mkStroke(b,primary and T.AccentHover or T.Accent,1)
        local fc=mkFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=b})
        local fl=Instance.new("UIListLayout",fc);fl.FillDirection=Enum.FillDirection.Horizontal;fl.HorizontalAlignment=Enum.HorizontalAlignment.Center;fl.VerticalAlignment=Enum.VerticalAlignment.Center;fl.Padding=UDim.new(0,6)
        mkImage({Size=UDim2.new(0,14,0,14),Image=ico(ic),ImageColor3=primary and T.Background or T.Text,LayoutOrder=1,Parent=fc})
        mkLabel({Size=UDim2.new(0,0,0,14),AutomaticSize=Enum.AutomaticSize.X,Text=lbl2,TextColor3=primary and T.Background or T.Text,TextSize=13,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=fc})
        b.MouseEnter:Connect(function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=primary and T.AccentHover or Color3.fromRGB(28,28,28)}):Play() end)
        b.MouseLeave:Connect(function() TS:Create(b,TweenInfo.new(0.1),{BackgroundColor3=primary and T.Accent or T.Input}):Play() end)
        return b
    end
    local getKeyBtn=actionBtn("Get Key","key",false,186)
    local redeemBtn=actionBtn("Redeem Key","shield",true,228)

    -- Bottom icon buttons
    local function icoBtn(ic,x,nc)
        local b=mkBtn({Size=UDim2.new(0,30,0,30),Position=UDim2.new(0.5,x,0,H-44),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,Parent=main})
        mkCorner(b,UDim.new(0,6));mkStroke(b,T.Accent,1)
        local im2=mkImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Image=ico(ic),ImageColor3=nc,Parent=b})
        b.MouseEnter:Connect(function() TS:Create(im2,TweenInfo.new(0.1),{ImageColor3=T.Accent}):Play() end)
        b.MouseLeave:Connect(function() TS:Create(im2,TweenInfo.new(0.1),{ImageColor3=nc}):Play() end)
        return b
    end
    icoBtn("discord",-20,T.TextDim).MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord~="" then pcall(setclipboard,Zyrix.Links.Discord);Zyrix:Notify("Discord","Invite copied",2,"discord") end
    end)
    icoBtn("key",20,T.TextDim).MouseButton1Click:Connect(function()
        if Zyrix.Links.GetKey~="" then pcall(setclipboard,Zyrix.Links.GetKey);Zyrix:Notify("Copied","Key link copied",2,"copy")
        else Zyrix:Notify("Error","No key link set",3,"error") end
    end)

    -- Status helpers
    local spinC,dotT
    local function setStatus(state,custom)
        if spinC then spinC:Disconnect();spinC=nil;statIcon.Rotation=0 end
        if dotT  then task.cancel(dotT);dotT=nil end
        local col,ic2,txt=T.StatusIdle,ico("lock"),custom or "No key detected"
        if state=="verifying" then
            col,ic2,txt=T.Accent,ico("lock"),"Verifying key"
            local dots,di={".","..","...",""},1
            dotT=task.spawn(function()
                while statLbl and statLbl.Parent do
                    statLbl.Text="Verifying key"..dots[di];di=(di%4)+1;task.wait(0.35)
                end
            end)
        elseif state=="success" then col,ic2,txt=T.Success,ico("check"),custom or "Access Granted"
        elseif state=="error"   then col,ic2,txt=T.Error,  ico("alert"),custom or "Invalid Key" end
        TS:Create(statLbl,TweenInfo.new(0.2),{TextColor3=col}):Play()
        TS:Create(statIcon,TweenInfo.new(0.2),{ImageColor3=col}):Play()
        statLbl.Text=txt;statIcon.Image=ic2
    end

    local function closeAndClean(cb)
        disableBlur()
        TS:Create(cont,TweenInfo.new(0.3),{Position=UDim2.new(0.5,-W/2,-0.6,0)}):Play()
        TS:Create(main,TweenInfo.new(0.22),{BackgroundTransparency=1}):Play()
        task.wait(0.32);sg:Destroy();if cb then cb() end
    end

    closeBtnH.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        closeAndClean(function()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
            removeBG()
        end)
    end)

    local function handleRedeem()
        local key=tb.Text:gsub("%s+","")
        if key=="" then Zyrix:Notify("Error","Please enter a key",3,"error");return end
        setStatus("verifying");redeemBtn.Active=false;task.wait(0.3)
        local valid,errMsg=false,"Invalid key"
        if Zyrix.Callbacks.OnVerify then
            local ok,res=pcall(Zyrix.Callbacks.OnVerify,key)
            if ok then
                if type(res)=="boolean" then valid=res
                elseif type(res)=="table" then valid=res.valid==true;errMsg=res.message or errMsg end
            end
        end
        redeemBtn.Active=true
        if valid then
            if Zyrix.Storage.Remember then saveKey(Zyrix.Storage.FileName,key) end
            getgenv().__ZyrixKey=key
            setStatus("success");Zyrix:Notify("Success","Key validated!",2,"success")
            task.wait(0.8)
            closeAndClean(function()
                removeBG()
                if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
            end)
        else
            setStatus("error",errMsg);Zyrix:Notify("Invalid",errMsg,4,"error")
            if Zyrix.Callbacks.OnFail then Zyrix.Callbacks.OnFail(errMsg) end
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)
    tb.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)
    getKeyBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.GetKey~="" then pcall(setclipboard,Zyrix.Links.GetKey);Zyrix:Notify("Copied","Key link copied",2,"copy")
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
            if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end;return
        end
        getgenv().__ZyrixKey=nil
    end
    if self.Storage.AutoLoad and self.Callbacks.OnVerify then
        local saved=loadKey(self.Storage.FileName)
        if saved then
            self:Notify("Checking","Validating saved key...",2,"info");task.wait(0.4)
            if validateKey(saved,self.Callbacks.OnVerify) then
                getgenv().__ZyrixKey=saved
                self:Notify("Welcome Back","Key validated!",2,"success")
                if self.Callbacks.OnSuccess then self.Callbacks.OnSuccess() end;return
            else
                clearKey(self.Storage.FileName)
                self:Notify("Expired","Saved key expired",3,"error");task.wait(0.6)
            end
        end
    end
    buildBG(); buildKeyUI()
end

function Zyrix:GetSavedKey()   return loadKey(self.Storage.FileName) end
function Zyrix:ClearSavedKey() clearKey(self.Storage.FileName) end

getgenv().__ZyrixLib = Zyrix
getgenv().ZyrixUI    = ZyrixUI
return Zyrix
