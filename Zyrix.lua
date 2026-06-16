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
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixUI = {}

local _guiRoot    = nil
local _win        = nil
local _sideScroll = nil
local _contentArea= nil
local _tabBtns    = {}
local _tabPanels  = {}
local _activeTab  = nil
local _tabLO      = 0
local _notifHolder= nil

local WIN_W    = 680
local WIN_H    = 440
local SIDE_W   = 155
local TAB_H    = 34

-- ── switch active tab ─────────────────────────────────────────────────────────
local function switchTab(name)
    if _activeTab == name then return end
    _activeTab = name
    for n, t in pairs(_tabBtns) do
        local on = n == name
        tw(t.bg,  0.15, {BackgroundColor3 = on and C.BG3 or C.BG2})
        tw(t.bar, 0.15, {BackgroundTransparency = on and 0 or 1})
        tw(t.lbl, 0.15, {TextColor3 = on and C.Text or C.TextDim})
    end
    for n, p in pairs(_tabPanels) do
        p.Visible = n == name
    end
end

-- ── build the window shell ────────────────────────────────────────────────────
local function buildShell()
    if _guiRoot then _guiRoot:Destroy() end
    _tabBtns   = {}
    _tabPanels = {}
    _activeTab = nil
    _tabLO     = 0

    local sg = Instance.new("ScreenGui")
    sg.Name           = "ZyrixMainUI"
    sg.ResetOnSpawn   = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder   = 50
    sg.Parent         = hui
    _guiRoot = sg

    -- window
    local win = mkFrame({
        Name             = "Window",
        Size             = UDim2.new(0, WIN_W, 0, WIN_H),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.BG,
        Parent           = sg,
    })
    applyCorner(win, UDim.new(0,8))
    applyStroke(win, C.Stroke, 1.5, 0)
    _win = win

    -- title bar
    local bar = mkFrame({
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = C.BG2,
        Parent           = win,
    })
    applyCorner(bar, UDim.new(0,8))
    mkFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=C.BG2,Parent=bar})
    mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=C.Stroke,Parent=bar})

    mkImage({
        Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(0,12,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Image="rbxassetid://105436073524298",
        ImageColor3=C.Text, Parent=bar,
    })
    mkLabel({
        Size=UDim2.new(1,-130,1,0),
        Position=UDim2.new(0,38,0,0),
        Text="Zyrix", TextColor3=C.Text,
        TextSize=15, TextXAlignment=Enum.TextXAlignment.Left,
        Parent=bar,
    })

    -- close / minimise buttons
    local function ctrlBtn(xOff, symbol, col)
        local b = mkButton({
            Size=UDim2.new(0,24,0,24),
            Position=UDim2.new(1,xOff,0.5,0), AnchorPoint=Vector2.new(1,0.5),
            BackgroundColor3=C.BG3, Parent=bar,
        })
        applyCorner(b, UDim.new(1,0))
        mkLabel({Size=UDim2.new(1,0,1,0),Text=symbol,TextColor3=col,TextSize=12,Parent=b})
        b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundColor3=C.BG4}) end)
        b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundColor3=C.BG3}) end)
        return b
    end

    local btnClose = ctrlBtn(-10, "✕", C.Error)
    local btnMin   = ctrlBtn(-40, "−", C.TextDim)

    btnClose.MouseButton1Click:Connect(function()
        tw(win, 0.2, {Size=UDim2.new(0,WIN_W,0,0), BackgroundTransparency=1})
        task.wait(0.22) sg:Destroy() _guiRoot=nil
    end)
    local minimised = false
    btnMin.MouseButton1Click:Connect(function()
        minimised = not minimised
        tw(win, 0.25, {Size = minimised and UDim2.new(0,WIN_W,0,42) or UDim2.new(0,WIN_W,0,WIN_H)})
    end)

    draggable(bar, win)

    -- body
    local body = mkFrame({
        Size=UDim2.new(1,0,1,-42),
        Position=UDim2.new(0,0,0,42),
        BackgroundTransparency=1,
        Parent=win,
    })

    -- sidebar
    local side = mkFrame({
        Size=UDim2.new(0,SIDE_W,1,0),
        BackgroundColor3=C.BG2,
        Parent=body,
    })
    mkFrame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=C.Stroke,Parent=side})

    _sideScroll = mkScroll(side, UDim2.new(1,0,1,0), UDim2.new(0,0,0,0))
    _sideScroll.ScrollBarThickness = 0
    mkList(_sideScroll, 2)
    mkPad(_sideScroll, 6, 6, 6, 6)

    -- content
    _contentArea = mkFrame({
        Size=UDim2.new(1,-SIDE_W,1,0),
        Position=UDim2.new(0,SIDE_W,0,0),
        BackgroundColor3=C.BG,
        Parent=body,
    })

    -- notification holder (top right inside content)
    _notifHolder = mkFrame({
        Size=UDim2.new(0,190,0,0),
        Position=UDim2.new(1,-196,0,6),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        ZIndex=30,
        Parent=_contentArea,
    })
    mkList(_notifHolder, 4)

    -- entrance anim
    win.Size = UDim2.new(0,WIN_W,0,0)
    win.BackgroundTransparency = 1
    tw(win, 0.3, {Size=UDim2.new(0,WIN_W,0,WIN_H), BackgroundTransparency=0}, Enum.EasingStyle.Back)

    -- global keybind toggle
    getgenv().__ZyrixToggleKey = getgenv().__ZyrixToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == getgenv().__ZyrixToggleKey and _win then
            _win.Visible = not _win.Visible
        end
    end)
end

-- ── AddTab ────────────────────────────────────────────────────────────────────
function ZyrixUI:AddTab(name, icon)
    if not _guiRoot then
        warn("[ZyrixUI] Call ZyrixUI:Open() before AddTab")
        return {}
    end

    _tabLO = _tabLO + 1

    -- sidebar button
    local tbBG = mkFrame({
        Size=UDim2.new(1,0,0,TAB_H),
        BackgroundColor3=C.BG2,
        LayoutOrder=_tabLO,
        Parent=_sideScroll,
    })
    applyCorner(tbBG, UDim.new(0,4))

    local bar = mkFrame({
        Size=UDim2.new(0,3,0.6,0),
        Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        BackgroundColor3=C.Accent,
        BackgroundTransparency=1,
        Parent=tbBG,
    })
    applyCorner(bar, UDim.new(1,0))

    local lbl = mkLabel({
        Size=UDim2.new(1,-12,1,0),
        Position=UDim2.new(0,12,0,0),
        Text=(icon and icon.." " or "")..name,
        TextColor3=C.TextDim, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=tbBG,
    })

    local clickZone = mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=tbBG})
    clickZone.MouseButton1Click:Connect(function() switchTab(name) end)
    tbBG.MouseEnter:Connect(function()
        if _activeTab ~= name then tw(tbBG,0.12,{BackgroundColor3=C.BG3}) end
    end)
    tbBG.MouseLeave:Connect(function()
        if _activeTab ~= name then tw(tbBG,0.12,{BackgroundColor3=C.BG2}) end
    end)

    _tabBtns[name] = {bg=tbBG, bar=bar, lbl=lbl}

    -- content panel
    local panel = mkFrame({
        Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1,
        Visible=false,
        Parent=_contentArea,
    })
    local scroll = mkScroll(panel, UDim2.new(1,-8,1,-8), UDim2.new(0,4,0,4))
    mkList(scroll, 5)
    mkPad(scroll, 4, 8, 4, 4)
    _tabPanels[name] = panel

    if _tabLO == 1 then switchTab(name) end

    -- ── element builders scoped to this tab ──────────────────────────────────
    local lo = 0
    local function nlo() lo=lo+1 return lo end

    local tab = {}

    function tab:Section(title)
        lo = lo + 1
        local s = mkFrame({
            Size=UDim2.new(1,0,0,26),
            BackgroundTransparency=1,
            LayoutOrder=lo, Parent=scroll,
        })
        mkLabel({
            Size=UDim2.new(1,0,1,0),
            Text=title:upper(), TextColor3=C.TextOff,
            TextSize=10, Font=Enum.Font.Gotham,
            TextXAlignment=Enum.TextXAlignment.Left,
            Parent=s,
        })
        mkFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.Stroke,Parent=s})
    end

    function tab:Toggle(title, desc, default, callback)
        local state = default or false
        local h = desc and 52 or 38
        local el = mkFrame({Size=UDim2.new(1,0,0,h),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(1,-60,0,18),Position=UDim2.new(0,12,0,desc and 8 or 10),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        if desc then
            mkLabel({Size=UDim2.new(1,-60,0,14),Position=UDim2.new(0,12,0,28),Text=desc,TextColor3=C.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        end

        local pill = mkFrame({Size=UDim2.new(0,34,0,18),Position=UDim2.new(1,-44,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=state and C.Accent or C.BG4,Parent=el})
        applyCorner(pill,UDim.new(1,0))
        local knob = mkFrame({Size=UDim2.new(0,12,0,12),Position=UDim2.new(state and 1 or 0,state and -15 or 3,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=state and C.BG or C.TextOff,Parent=pill})
        applyCorner(knob,UDim.new(1,0))

        local hit = mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=el})
        hit.MouseButton1Click:Connect(function()
            state = not state
            tw(pill,0.18,{BackgroundColor3=state and C.Accent or C.BG4})
            tw(knob,0.18,{Position=UDim2.new(state and 1 or 0,state and -15 or 3,0.5,0),BackgroundColor3=state and C.BG or C.TextOff})
            if callback then pcall(callback,state) end
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)

        return {
            GetValue = function() return state end,
            SetValue = function(v)
                state=v
                tw(pill,0.18,{BackgroundColor3=v and C.Accent or C.BG4})
                tw(knob,0.18,{Position=UDim2.new(v and 1 or 0,v and -15 or 3,0.5,0),BackgroundColor3=v and C.BG or C.TextOff})
            end,
        }
    end

    function tab:Slider(title, min, max, default, callback)
        min=min or 0; max=max or 100; default=math.clamp(default or min,min,max)
        local value = default
        local el = mkFrame({Size=UDim2.new(1,0,0,56),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(0.7,0,0,18),Position=UDim2.new(0,12,0,8),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        local vLbl = mkLabel({Size=UDim2.new(0.3,0,0,18),Position=UDim2.new(0.7,-12,0,8),Text=tostring(value),TextColor3=C.AccentDim,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,Parent=el})

        local track = mkFrame({Size=UDim2.new(1,-24,0,4),Position=UDim2.new(0,12,0,34),BackgroundColor3=C.BG4,Parent=el})
        applyCorner(track,UDim.new(1,0))
        local fill = mkFrame({Size=UDim2.new((value-min)/(max-min),0,1,0),BackgroundColor3=C.Accent,Parent=track})
        applyCorner(fill,UDim.new(1,0))
        local knob = mkFrame({Size=UDim2.new(0,12,0,12),Position=UDim2.new((value-min)/(max-min),0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=C.Accent,Parent=track})
        applyCorner(knob,UDim.new(1,0))

        local dragging = false
        local function update(x)
            local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=math.floor(min+(max-min)*rel+0.5)
            local pct=(value-min)/(max-min)
            fill.Size=UDim2.new(pct,0,1,0)
            knob.Position=UDim2.new(pct,0,0.5,0)
            vLbl.Text=tostring(value)
            if callback then pcall(callback,value) end
        end

        local hit = mkButton({Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Parent=el})
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
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)

        return {
            GetValue=function() return value end,
            SetValue=function(v)
                value=math.clamp(v,min,max)
                local pct=(value-min)/(max-min)
                fill.Size=UDim2.new(pct,0,1,0)
                knob.Position=UDim2.new(pct,0,0.5,0)
                vLbl.Text=tostring(value)
            end,
        }
    end

    function tab:Button(title, desc, callback)
        local h = desc and 52 or 38
        local el = mkFrame({Size=UDim2.new(1,0,0,h),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(1,-36,0,18),Position=UDim2.new(0,12,0,desc and 8 or 10),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        if desc then
            mkLabel({Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,28),Text=desc,TextColor3=C.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        end
        mkLabel({Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-26,0,0),Text="›",TextColor3=C.TextDim,TextSize=18,Parent=el})

        local hit = mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=el})
        hit.MouseButton1Click:Connect(function()
            tw(el,0.07,{BackgroundColor3=C.Stroke})
            task.delay(0.1,function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)
            if callback then pcall(callback) end
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)
    end

    function tab:TextBox(title, placeholder, default, callback)
        local el = mkFrame({Size=UDim2.new(1,0,0,60),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(1,-12,0,18),Position=UDim2.new(0,12,0,6),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})

        local inputBG = mkFrame({Size=UDim2.new(1,-24,0,24),Position=UDim2.new(0,12,0,28),BackgroundColor3=C.BG,Parent=el})
        applyCorner(inputBG,UDim.new(0,4))
        local inputStr = applyStroke(inputBG,C.Stroke,1,0)

        local tb = Instance.new("TextBox")
        tb.Size=UDim2.new(1,-16,1,0); tb.Position=UDim2.new(0,8,0,0)
        tb.BackgroundTransparency=1; tb.Text=default or ""
        tb.PlaceholderText=placeholder or ""; tb.PlaceholderColor3=C.TextOff
        tb.TextColor3=C.Text; tb.TextSize=12; tb.Font=Enum.Font.Gotham
        tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
        tb.Parent=inputBG
        tb.Focused:Connect(function()   tw(inputStr,0.12,{Color=C.Accent}) end)
        tb.FocusLost:Connect(function(enter)
            tw(inputStr,0.12,{Color=C.Stroke})
            if enter and callback then pcall(callback,tb.Text) end
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)

        return {GetValue=function() return tb.Text end, SetValue=function(v) tb.Text=v end}
    end

    function tab:Dropdown(title, options, default, callback)
        local selected = default or (options and options[1]) or ""
        local isOpen   = false
        local ITEM_H   = 28

        local el = mkFrame({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.BG3,LayoutOrder=nlo(),ClipsDescendants=false,ZIndex=5,Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,12,0,0),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,Parent=el})
        local vLbl = mkLabel({Size=UDim2.new(0.4,0,1,0),Position=UDim2.new(0.5,-18,0,0),Text=selected,TextColor3=C.AccentDim,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5,Parent=el})
        local arrow = mkLabel({Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-24,0,0),Text="▾",TextColor3=C.TextDim,TextSize=12,ZIndex=5,Parent=el})

        local list = mkFrame({Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,3),BackgroundColor3=C.BG2,ClipsDescendants=true,ZIndex=10,Parent=el})
        applyCorner(list) applyStroke(list,C.Stroke,1,0)
        mkList(list,0)

        for _,opt in ipairs(options or {}) do
            local row = mkButton({Size=UDim2.new(1,0,0,ITEM_H),BackgroundColor3=C.BG2,ZIndex=11,Parent=list})
            mkLabel({Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,12,0,0),Text=opt,TextColor3=C.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11,Parent=row})
            row.MouseEnter:Connect(function() tw(row,0.1,{BackgroundColor3=C.BG3}) end)
            row.MouseLeave:Connect(function() tw(row,0.1,{BackgroundColor3=C.BG2}) end)
            row.MouseButton1Click:Connect(function()
                selected=opt; vLbl.Text=opt; isOpen=false
                tw(arrow,0.12,{Rotation=0}); tw(list,0.15,{Size=UDim2.new(1,0,0,0)})
                el.Size=UDim2.new(1,0,0,38)
                if callback then pcall(callback,opt) end
            end)
        end

        local maxH = ITEM_H * math.min(#options,5)
        local hit = mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Parent=el})
        hit.MouseButton1Click:Connect(function()
            isOpen=not isOpen
            if isOpen then
                tw(arrow,0.12,{Rotation=180}); tw(list,0.15,{Size=UDim2.new(1,0,0,maxH)})
                el.Size=UDim2.new(1,0,0,38+maxH+3)
            else
                tw(arrow,0.12,{Rotation=0}); tw(list,0.15,{Size=UDim2.new(1,0,0,0)})
                el.Size=UDim2.new(1,0,0,38)
            end
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)

        return {GetValue=function() return selected end, SetValue=function(v) selected=v; vLbl.Text=v end}
    end

    function tab:Keybind(title, default, callback)
        local key = default or Enum.KeyCode.Unknown
        local listening = false
        local el = mkFrame({Size=UDim2.new(1,0,0,38),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,12,0,0),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        local pill = mkFrame({Size=UDim2.new(0,68,0,22),Position=UDim2.new(1,-76,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=C.BG,Parent=el})
        applyCorner(pill,UDim.new(0,4)) applyStroke(pill,C.Stroke,1,0)
        local kLbl = mkLabel({Size=UDim2.new(1,0,1,0),Text=tostring(key):gsub("Enum.KeyCode.",""),TextColor3=C.AccentDim,TextSize=10,Parent=pill})

        local conn
        local hit = mkButton({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=el})
        hit.MouseButton1Click:Connect(function()
            if listening then return end
            listening=true; kLbl.Text="..."
            conn=UIS.InputBegan:Connect(function(i,gp)
                if gp then return end
                if i.UserInputType==Enum.UserInputType.Keyboard then
                    key=i.KeyCode; kLbl.Text=tostring(key):gsub("Enum.KeyCode.","")
                    listening=false; if conn then conn:Disconnect() end
                    if callback then pcall(callback,key) end
                end
            end)
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)
        return {GetValue=function() return key end}
    end

    function tab:ColorPicker(title, default, callback)
        local value = default or Color3.new(1,1,1)
        local el = mkFrame({Size=UDim2.new(1,0,0,50),BackgroundColor3=C.BG3,LayoutOrder=nlo(),Parent=scroll})
        applyCorner(el) applyStroke(el,C.Stroke,1,0)

        mkLabel({Size=UDim2.new(0.7,0,0,18),Position=UDim2.new(0,12,0,8),Text=title,TextColor3=C.Text,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,Parent=el})
        local preview = mkFrame({Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-30,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=value,Parent=el})
        applyCorner(preview,UDim.new(0,4)) applyStroke(preview,C.Stroke,1,0)

        local track = mkFrame({Size=UDim2.new(1,-24,0,4),Position=UDim2.new(0,12,0,34),BackgroundColor3=C.BG4,Parent=el})
        applyCorner(track,UDim.new(1,0))
        local grad = Instance.new("UIGradient",track)
        grad.Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(1,1,1))
        local lum = (value.R+value.G+value.B)/3
        local knob = mkFrame({Size=UDim2.new(0,10,0,10),Position=UDim2.new(lum,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=C.Accent,Parent=track})
        applyCorner(knob,UDim.new(1,0))

        local dragging2=false
        local function upd(x)
            local rel=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            value=Color3.new(rel,rel,rel); knob.Position=UDim2.new(rel,0,0.5,0)
            preview.BackgroundColor3=value
            if callback then pcall(callback,value) end
        end
        local hit=mkButton({Size=UDim2.new(1,0,0,20),Position=UDim2.new(0,0,0,28),BackgroundTransparency=1,Parent=el})
        hit.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=true; upd(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging2 and (i.UserInputType==Enum.UserInputType.MouseMovement) then upd(i.Position.X) end
        end)
        el.MouseEnter:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG4}) end)
        el.MouseLeave:Connect(function() tw(el,0.12,{BackgroundColor3=C.BG3}) end)
        return {GetValue=function() return value end}
    end

    function tab:Notify(title, msg, dur)
        if not _notifHolder then return end
        dur = dur or 3
        local n = mkFrame({
            Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=C.BG3, ZIndex=30, Parent=_notifHolder,
        })
        applyCorner(n) applyStroke(n,C.Stroke,1,0)
        mkList(n,2)
        mkPad(n,6,6,10,10)
        mkLabel({Size=UDim2.new(1,0,0,14),Text=title,TextColor3=C.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31,LayoutOrder=1,Parent=n})
        mkLabel({Size=UDim2.new(1,0,0,12),Text=msg,TextColor3=C.TextDim,TextSize=10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=31,LayoutOrder=2,Parent=n})
        task.delay(dur,function()
            if n and n.Parent then
                tw(n,0.2,{BackgroundTransparency=1})
                task.wait(0.22) n:Destroy()
            end
        end)
    end

    return tab
end

-- ── public methods ─────────────────────────────────────────────────────────────
function ZyrixUI:Open()
    buildShell()
end

function ZyrixUI:Close()
    if _guiRoot then _guiRoot:Destroy(); _guiRoot=nil end
end

function ZyrixUI:Toggle()
    if _win then _win.Visible = not _win.Visible end
end

function ZyrixUI:SetTitle(t)
    -- update title bar label if window is open
    if _win then
        local bar = _win:FindFirstChild("Frame")
        if bar then
            for _,v in ipairs(bar:GetChildren()) do
                if v:IsA("TextLabel") then v.Text=t break end
            end
        end
    end
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
