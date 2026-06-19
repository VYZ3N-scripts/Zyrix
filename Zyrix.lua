--[[
    Zyrix — Complete Script
    Original Arqel key system UI + main cheat UI
    Key: set VALID_KEYS below, put cheat code in OnSuccess
]]

repeat task.wait() until game:IsLoaded()

-- ══════════════════════════════════════════════
-- YOUR KEYS — change these to whatever you want
-- ══════════════════════════════════════════════
local VALID_KEYS = {
    "ZYRIX-FREE-2024",
    "ZYRIX-VIP-ALPHA",
    "ZYRIX-VIP-BETA",
    "zyrix123",
}

-- ══════════════════════════════════════════════
-- LOAD THE ORIGINAL ARQEL KEY SYSTEM
-- ══════════════════════════════════════════════
local Arqel = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Cobruhehe/expert-octo-doodle/main/Arqel.lua"
))()

-- ── Appearance ───────────────────────────────
Arqel.Appearance.Title    = "Zyrix"
Arqel.Appearance.Subtitle = "Enter your key to continue"
Arqel.Appearance.Icon     = "rbxassetid://105436073524298"

-- ── Optional links ───────────────────────────
Arqel.Links.Discord = ""   -- paste discord invite here
Arqel.Links.GetKey  = ""   -- paste key link here

-- ── Optional changelog ───────────────────────
Arqel.Changelog = {
    {
        Version = "v1.0",
        Date    = "2024",
        Changes = {
            "Initial release",
            "Key system added",
            "Main UI added",
        }
    }
}

-- ══════════════════════════════════════════════
-- KEY CHECKER
-- ══════════════════════════════════════════════
Arqel.Callbacks.OnVerify = function(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then return true end
    end
    return false
end

-- ══════════════════════════════════════════════
-- MAIN CHEAT UI — builds after key is accepted
-- ══════════════════════════════════════════════
Arqel.Callbacks.OnSuccess = function()
    local TS  = game:GetService("TweenService")
    local UIS = game:GetService("UserInputService")
    local RS  = game:GetService("RunService")
    local lp  = game:GetService("Players").LocalPlayer

    -- ── palette ──────────────────────────────
    local C = {
        WIN       = Color3.fromRGB(20, 20, 20),
        TAB       = Color3.fromRGB(23, 23, 23),
        EL        = Color3.fromRGB(25, 25, 25),
        INNER     = Color3.fromRGB(31, 31, 31),
        PROGRESS  = Color3.fromRGB(201, 201, 201),
        DD_BG     = Color3.fromRGB(19, 19, 19),
        DD_ROW    = Color3.fromRGB(27, 27, 27),
        STROKE_EL = Color3.fromRGB(41, 41, 41),
        STROKE_IN = Color3.fromRGB(51, 51, 51),
        STROKE_WIN= Color3.fromRGB(36, 36, 36),
        TEXT      = Color3.fromRGB(231, 231, 231),
        TEXT_DIM  = Color3.fromRGB(181, 181, 181),
        TEXT_GREY = Color3.fromRGB(131, 131, 131),
        WHITE     = Color3.fromRGB(255, 255, 255),
        GREEN1    = Color3.fromRGB(0, 171, 0),
        HOVER     = Color3.fromRGB(45, 45, 45),
        LOGO_OFF  = Color3.fromRGB(100, 100, 100),
        OFF       = Color3.fromRGB(60, 60, 60),
        BLACK     = Color3.fromRGB(0, 0, 0),
    }

    -- ── helpers ───────────────────────────────
    local function tw(obj, t, props, style, dir)
        TS:Create(obj, TweenInfo.new(t,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out), props):Play()
    end
    local function mkCorner(p, r)
        local c = Instance.new("UICorner", p)
        c.CornerRadius = r or UDim.new(0, 4); return c
    end
    local function mkStroke(p, col, thick)
        local s = Instance.new("UIStroke", p)
        s.Color = col or C.STROKE_EL
        s.Thickness = thick or 1
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        return s
    end
    local function mkPad(p, t, b, l, r)
        local u = Instance.new("UIPadding", p)
        u.PaddingTop    = UDim.new(0, t or 0)
        u.PaddingBottom = UDim.new(0, b or 0)
        u.PaddingLeft   = UDim.new(0, l or 0)
        u.PaddingRight  = UDim.new(0, r or 0)
    end
    local function mkGradient(p, from, to)
        local g = Instance.new("UIGradient", p)
        g.Color = ColorSequence.new(from or C.BLACK, to or C.WIN)
    end
    local function mkBtn(props)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = false
        b.BackgroundTransparency = 1
        b.Size = UDim2.new(1,0,1,0)
        b.Text = ""; b.BorderSizePixel = 0
        for k,v in pairs(props or {}) do
            if k ~= "Parent" and k ~= "Size" then b[k]=v end
        end
        if props and props.Size   then b.Size   = props.Size   end
        if props and props.Parent then b.Parent = props.Parent end
        return b
    end
    local function mkLabel(props)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1; l.BorderSizePixel = 0
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextWrapped = true; l.RichText = false
        for k,v in pairs(props or {}) do l[k]=v end
        return l
    end
    local function mkFrame(parent, props)
        local f = Instance.new("Frame"); f.BorderSizePixel = 0
        for k,v in pairs(props or {}) do f[k]=v end
        f.Parent = parent; return f
    end
    local function mkScroll(parent, props)
        local s = Instance.new("ScrollingFrame")
        s.BorderSizePixel = 0; s.BackgroundTransparency = 1
        s.ScrollBarThickness = 2
        s.ScrollBarImageColor3 = Color3.fromRGB(141,141,141)
        s.ScrollBarImageTransparency = 0.3
        s.CanvasSize = UDim2.new(0,0,0,0)
        s.AutomaticCanvasSize = Enum.AutomaticSize.Y
        for k,v in pairs(props or {}) do s[k]=v end
        s.Parent = parent; return s
    end
    local function mkList(parent, props)
        local l = Instance.new("UIListLayout", parent)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        for k,v in pairs(props or {}) do l[k]=v end
        return l
    end

    -- ── screen gui ────────────────────────────
    local playerGui = lp:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixMainUI"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 50; sg.Parent = playerGui

    -- ── layout constants ──────────────────────
    local WIN_W  = 563; local WIN_H  = 354
    local TAB_H  = 42;  local GAP    = 8
    local TOTAL_H = TAB_H + GAP + WIN_H

    -- ── outer container ───────────────────────
    local outer = mkFrame(sg, {
        Name = "ZyrixOuter",
        Size = UDim2.new(0, WIN_W, 0, TAB_H),
        Position = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(outer, UDim.new(0,8))
    mkStroke(outer, C.STROKE_WIN, 1)
    mkGradient(outer, C.BLACK, C.TAB)

    -- ── tab bar ───────────────────────────────
    local tabFrame = mkFrame(outer, {
        Name = "TabFrame",
        BackgroundColor3 = C.TAB,
        Size = UDim2.new(1,0,0,TAB_H),
    })
    mkCorner(tabFrame, UDim.new(0,8))
    mkGradient(tabFrame, C.BLACK, C.TAB)

    -- Z logo toggle button
    local logoBtn = mkBtn({
        Parent = tabFrame,
        Name = "LogoBtn",
        Size = UDim2.new(0,36,0,36),
        Position = UDim2.new(0,4,0.5,-18),
        BackgroundColor3 = C.TEXT,
        BackgroundTransparency = 0,
    })
    mkCorner(logoBtn, UDim.new(0,6))

    local logoImg = Instance.new("ImageLabel", logoBtn)
    logoImg.Size = UDim2.new(0,22,0,22)
    logoImg.Position = UDim2.new(0.5,0,0.5,0)
    logoImg.AnchorPoint = Vector2.new(0.5,0.5)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = "rbxassetid://105436073524298"
    logoImg.ImageColor3 = C.WIN
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = logoBtn.ZIndex + 1

    -- tab scroll frame
    local tabSF = Instance.new("ScrollingFrame")
    tabSF.Name = "tablist"
    tabSF.Size = UDim2.new(1,-46,1,0)
    tabSF.Position = UDim2.new(0,42,0,0)
    tabSF.BackgroundTransparency = 1; tabSF.BorderSizePixel = 0
    tabSF.ScrollBarThickness = 0
    tabSF.ScrollingDirection = Enum.ScrollingDirection.X
    tabSF.AutomaticCanvasSize = Enum.AutomaticSize.X
    tabSF.CanvasSize = UDim2.new(0,0,0,0)
    tabSF.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    tabSF.Parent = tabFrame

    local tabLL = mkList(tabSF, {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0,4),
    })
    mkPad(tabSF, 3, 3, 3, 0)

    -- ── main panel ────────────────────────────
    local mainFrame = mkFrame(outer, {
        Name = "main",
        Size = UDim2.new(0,WIN_W,0,0),
        Position = UDim2.new(0,0,0,TAB_H+GAP),
        BackgroundColor3 = C.WIN,
        ClipsDescendants = true,
        Visible = false,
    })
    mkCorner(mainFrame, UDim.new(0,8))
    mkGradient(mainFrame, C.BLACK, C.WIN)

    -- header
    local hdr = mkFrame(mainFrame, {
        Name = "Header",
        Size = UDim2.new(1,0,0,34),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(hdr, UDim.new(0,6))
    mkFrame(hdr, {
        Size = UDim2.new(1,0,0,6), Position = UDim2.new(0,0,1,-6),
        BackgroundColor3 = C.TAB,
    })

    mkLabel({
        Parent = hdr, Text = "Zyrix",
        Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,10,0,0),
        Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.WHITE,
    })

    local closeBtn = mkBtn({
        Parent = hdr,
        Size = UDim2.new(0,24,0,24),
        Position = UDim2.new(1,-28,0.5,-12),
        BackgroundColor3 = C.HOVER, BackgroundTransparency = 0,
    })
    mkCorner(closeBtn, UDim.new(0,4))
    mkLabel({
        Parent = closeBtn, Text = "✕",
        Size = UDim2.new(1,0,1,0),
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = C.TEXT,
        TextXAlignment = Enum.TextXAlignment.Center,
    })
    closeBtn.MouseEnter:Connect(function() tw(closeBtn,.12,{BackgroundColor3=C.EL}) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn,.12,{BackgroundColor3=C.HOVER}) end)

    mkFrame(mainFrame, {
        Name = "Sep",
        Size = UDim2.new(1,-20,0,1), Position = UDim2.new(0,10,0,34),
        BackgroundColor3 = C.STROKE_IN,
    })

    -- page host
    local pageHost = mkFrame(mainFrame, {
        Size = UDim2.new(1,0,1,-38), Position = UDim2.new(0,0,0,38),
        BackgroundTransparency = 1, ClipsDescendants = true,
    })

    -- ── element builders ──────────────────────
    local function elemFrame(parent, titleText)
        local f = mkFrame(parent, {
            Name = titleText or "Element",
            Size = UDim2.new(1,-4,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.EL,
        })
        mkCorner(f, UDim.new(0,4)); mkStroke(f, C.STROKE_EL, 1)
        mkPad(f, 8, 8, 8, 8)
        mkLabel({
            Parent=f, Name="Title", Text=titleText or "",
            Size=UDim2.new(1,0,0,14),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT_DIM,
        })
        local cp = Instance.new("UIPadding", f)
        cp.Name = "ContentPad"; cp.PaddingTop = UDim.new(0,22)
        return f
    end

    local function mkSection(parent, label)
        local f = mkFrame(parent, {
            Size=UDim2.new(1,-4,0,24), BackgroundTransparency=1,
        })
        mkLabel({
            Parent=f, Text=label:upper(),
            Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,2,0,6),
            Font=Enum.Font.GothamBold, TextSize=9, TextColor3=C.TEXT_GREY,
        })
        mkFrame(f, {
            Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1),
            BackgroundColor3=C.STROKE_EL,
        })
    end

    local function mkToggle(parent, label, default, callback)
        local f = elemFrame(parent, label)
        local row = mkBtn({
            Parent=f, Size=UDim2.new(1,-2,0,30),
            BackgroundColor3=C.INNER, BackgroundTransparency=0,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)
        mkLabel({
            Parent=row, Text=label,
            Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,8,0,0),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })
        local track = mkFrame(row, {
            Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-44,0.5,-10),
            BackgroundColor3=C.OFF,
        })
        mkCorner(track, UDim.new(0,10))
        local thumb = mkFrame(track, {
            Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,1,0.5,-9),
            BackgroundColor3=Color3.fromRGB(178,178,178),
        })
        mkCorner(thumb, UDim.new(0,9))
        local state = default == true
        local function refresh()
            if state then
                tw(track,.18,{BackgroundColor3=C.GREEN1})
                tw(thumb,.18,{Position=UDim2.new(1,-19,0.5,-9), BackgroundColor3=C.WHITE})
            else
                tw(track,.18,{BackgroundColor3=C.OFF})
                tw(thumb,.18,{Position=UDim2.new(0,1,0.5,-9), BackgroundColor3=Color3.fromRGB(178,178,178)})
            end
        end
        refresh()
        row.MouseButton1Click:Connect(function()
            state = not state; refresh()
            if callback then pcall(callback, state) end
        end)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)
        return {Get=function() return state end, Set=function(v) state=v; refresh(); if callback then pcall(callback,v) end end}
    end

    local function mkSlider(parent, label, min, max, default, suffix, callback)
        local f = elemFrame(parent, label)
        local track = mkFrame(f, {
            Name="Main", Size=UDim2.new(1,-2,0,26), BackgroundColor3=C.INNER,
        })
        mkCorner(track, UDim.new(0,4)); mkStroke(track, C.STROKE_IN, 1)
        local fill = mkFrame(track, {
            Name="Progress", Size=UDim2.new(0,0,1,0), BackgroundColor3=C.PROGRESS,
        })
        mkCorner(fill, UDim.new(0,4))
        local valLbl = mkLabel({
            Parent=f, Text="",
            Size=UDim2.new(0,100,0,14), Position=UDim2.new(1,-102,0,23),
            Font=Enum.Font.GothamMedium, TextSize=12,
            TextColor3=C.TEXT_DIM, TextXAlignment=Enum.TextXAlignment.Right,
        })
        local val = default or min
        local dragging = false
        local function setVal(v)
            val = math.clamp(math.round(v), min, max)
            local pct = (val-min)/math.max(1,max-min)
            tw(fill,.08,{Size=UDim2.new(pct,0,1,0)}, Enum.EasingStyle.Quad)
            valLbl.Text = tostring(val)..(suffix or "")
            if callback then pcall(callback,val) end
        end
        setVal(val)
        local interact = mkBtn({Parent=track}); interact.ZIndex = 10
        interact.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging = true
                local abs=track.AbsolutePosition; local sz=track.AbsoluteSize
                setVal(min+math.clamp((i.Position.X-abs.X)/math.max(1,sz.X),0,1)*(max-min))
                tw(track,.08,{Size=UDim2.new(1,-2,0,30)}, Enum.EasingStyle.Back)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch then
                local abs=track.AbsolutePosition; local sz=track.AbsoluteSize
                setVal(min+math.clamp((i.Position.X-abs.X)/math.max(1,sz.X),0,1)*(max-min))
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging = false
                tw(track,.20,{Size=UDim2.new(1,-2,0,26)}, Enum.EasingStyle.Back)
            end
        end)
        track.MouseEnter:Connect(function() tw(track,.12,{BackgroundColor3=C.HOVER}) end)
        track.MouseLeave:Connect(function() tw(track,.12,{BackgroundColor3=C.INNER}) end)
        return {Get=function() return val end, Set=setVal}
    end

    local function mkButton(parent, label, callback)
        local f = elemFrame(parent, label)
        local row = mkBtn({
            Parent=f, Size=UDim2.new(1,-2,0,32),
            BackgroundColor3=C.EL, BackgroundTransparency=0,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)
        mkLabel({
            Parent=row, Text="★",
            Size=UDim2.new(0,32,0,20), Position=UDim2.new(0,8,0.5,-10),
            Font=Enum.Font.SourceSans, TextSize=16, TextColor3=C.TEXT_GREY,
            TextXAlignment=Enum.TextXAlignment.Center,
        })
        mkLabel({
            Parent=row, Text=label,
            Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,42,0,0),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })
        row.MouseButton1Click:Connect(function()
            tw(row,.10,{BackgroundColor3=Color3.fromRGB(150,150,150)})
            task.delay(.15, function() tw(row,.20,{BackgroundColor3=C.EL}) end)
            if callback then pcall(callback) end
        end)
        row.MouseButton1Down:Connect(function()
            tw(row,.06,{Size=UDim2.new(1,-2,0,29)},Enum.EasingStyle.Back,Enum.EasingDirection.In)
        end)
        row.MouseButton1Up:Connect(function()
            tw(row,.20,{Size=UDim2.new(1,-2,0,32)},Enum.EasingStyle.Back)
        end)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.EL}) end)
    end

    local function mkDropdown(parent, label, opts, default, callback)
        local CH=38; local IH=30
        local f = elemFrame(parent, label)
        f.ClipsDescendants = true
        local row = mkBtn({
            Parent=f, Size=UDim2.new(1,-2,0,30),
            BackgroundColor3=C.INNER, BackgroundTransparency=0,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)
        local selLbl = mkLabel({
            Parent=row, Text=default or (opts[1] or ""),
            Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,8,0,0),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })
        local arrowBg = mkFrame(row, {
            Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-26,0.5,-11),
            BackgroundColor3=C.OFF,
        })
        mkCorner(arrowBg, UDim.new(0,4))
        mkLabel({
            Parent=arrowBg, Text="▼",
            Size=UDim2.new(1,0,1,0),
            Font=Enum.Font.SourceSans, TextSize=11, TextColor3=C.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center,
        })
        local list = mkFrame(f, {
            Size=UDim2.new(1,-2,0,0), Position=UDim2.new(0,0,0,52),
            BackgroundColor3=C.DD_BG, ClipsDescendants=true, Visible=false, ZIndex=20,
        })
        mkCorner(list, UDim.new(0,4)); mkStroke(list, C.STROKE_IN, 1)
        mkPad(list, 4, 4, 4, 4)
        mkList(list, {Padding=UDim.new(0,3)})
        local current = default or (opts[1] or "")
        local isOpen = false
        local fullH = #opts*(IH+3)+8
        for _, opt in ipairs(opts) do
            local item = mkBtn({
                Parent=list, Size=UDim2.new(1,0,0,IH),
                BackgroundColor3=C.DD_ROW, BackgroundTransparency=0,
            })
            mkCorner(item, UDim.new(0,4))
            mkLabel({
                Parent=item, Text=opt,
                Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
                Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
            })
            item.MouseEnter:Connect(function() tw(item,.12,{BackgroundColor3=C.HOVER}) end)
            item.MouseLeave:Connect(function() tw(item,.12,{BackgroundColor3=C.DD_ROW}) end)
            item.MouseButton1Click:Connect(function()
                current=opt; selLbl.Text=opt; isOpen=false
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible=false end)
                if callback then pcall(callback,opt) end
            end)
        end
        local function toggleDD()
            isOpen = not isOpen
            if isOpen then
                list.Visible=true; list.Size=UDim2.new(1,-2,0,0)
                tw(arrowBg,.15,{Rotation=180})
                tw(list,.20,{Size=UDim2.new(1,-2,0,fullH)})
            else
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},Enum.EasingStyle.Quart,Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible=false end)
            end
        end
        row.MouseButton1Click:Connect(toggleDD)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)
        return {Get=function() return current end, Set=function(v) current=v; selLbl.Text=v end}
    end

    local function mkKeybind(parent, label, default, callback)
        local f = elemFrame(parent, label)
        local row = mkFrame(f, {
            Size=UDim2.new(1,-2,0,30), BackgroundColor3=C.INNER,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)
        mkLabel({
            Parent=row, Text=label,
            Size=UDim2.new(1,-86,1,0), Position=UDim2.new(0,8,0,0),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT_DIM,
        })
        local keyBox = mkBtn({
            Parent=row,
            Size=UDim2.new(0,70,0,22), Position=UDim2.new(1,-76,0.5,-11),
            BackgroundColor3=C.EL, BackgroundTransparency=0,
        })
        mkCorner(keyBox, UDim.new(0,4)); mkStroke(keyBox, C.STROKE_IN, 1)
        local keyLbl = mkLabel({
            Parent=keyBox, Text=(default and default.Name) or "None",
            Size=UDim2.new(1,0,1,0),
            Font=Enum.Font.GothamBold, TextSize=12, TextColor3=C.TEXT,
            TextXAlignment=Enum.TextXAlignment.Center,
        })
        local capturing = false; local curKey = default or Enum.KeyCode.Unknown
        keyBox.MouseButton1Click:Connect(function()
            capturing=true; keyLbl.Text="…"
            tw(keyBox,.12,{BackgroundColor3=C.HOVER})
        end)
        UIS.InputBegan:Connect(function(i,gp)
            if gp then return end
            if capturing and i.UserInputType==Enum.UserInputType.Keyboard
            and i.KeyCode~=Enum.KeyCode.Escape then
                curKey=i.KeyCode; keyLbl.Text=curKey.Name
                capturing=false; tw(keyBox,.12,{BackgroundColor3=C.EL}); return
            end
            if i.KeyCode==curKey and callback then pcall(callback,true) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.KeyCode==curKey and callback then pcall(callback,false) end
        end)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)
    end

    -- ── create tab pages ──────────────────────
    local tabPages = {}
    local tabBtns  = {}
    local activeTab = nil

    local TABS = {
        {Name="Combat",   Icon="⚔"},
        {Name="Visual",   Icon="👁"},
        {Name="Misc",     Icon="⚙"},
        {Name="Settings", Icon="🔧"},
        {Name="Player",   Icon="🧑"},
    }

    local function newPage(name)
        local page = mkFrame(pageHost, {
            Name=name.."Page", Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1, Visible=false,
        })
        local scroll = mkScroll(page, {
            Name="Scroll", Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=2,
        })
        mkList(scroll, {Padding=UDim.new(0,6)})
        mkPad(scroll, 6, 6, 6, 6)
        tabPages[name] = {page=page, scroll=scroll}
        return scroll
    end

    local combatSc   = newPage("Combat")
    local visualSc   = newPage("Visual")
    local miscSc     = newPage("Misc")
    local settingsSc = newPage("Settings")
    local playerSc   = newPage("Player")

    -- ── populate tabs ─────────────────────────
    mkSection(combatSc, "Aimbot")
    mkToggle  (combatSc, "Enable Aimbot",   false)
    mkSlider  (combatSc, "FOV",             10, 360, 90, "°")
    mkSlider  (combatSc, "Smoothness",      1, 100, 20, "%")
    mkDropdown(combatSc, "Aim Part", {"Head","Neck","Torso","HumanoidRootPart"}, "Head")
    mkKeybind (combatSc, "Hold to Aim",     Enum.KeyCode.Q)
    mkSection (combatSc, "Silent Aim")
    mkToggle  (combatSc, "Silent Aim",      false)
    mkSlider  (combatSc, "Hit Chance",      0, 100, 75, "%")
    mkSection (combatSc, "Actions")
    mkButton  (combatSc, "Reset Aimbot",    function() Arqel:Notify("Combat","Aimbot reset!",2,"success") end)

    mkSection (visualSc, "ESP")
    mkToggle  (visualSc, "Enable ESP",      false)
    mkSlider  (visualSc, "Range",           50, 2000, 500, " st")
    mkToggle  (visualSc, "Show Names",      true)
    mkToggle  (visualSc, "Show Distance",   false)
    mkToggle  (visualSc, "Show Health",     true)
    mkDropdown(visualSc, "Box Type", {"2D Box","3D Box","Corner Box"}, "2D Box")
    mkSection (visualSc, "World")
    mkToggle  (visualSc, "No Fog", false, function(on)
        game:GetService("Lighting").FogEnd = on and 1e6 or 1000
    end)
    mkToggle  (visualSc, "Full Bright", false, function(on)
        local lt = game:GetService("Lighting")
        lt.Brightness = on and 5 or 1
        if on then lt.ClockTime = 14 end
    end)

    mkSection (miscSc, "Movement")
    mkToggle  (miscSc, "Speed Hack", false, function(on)
        local char = lp.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = on and 60 or 16
        end
    end)
    mkSlider  (miscSc, "Walk Speed", 16, 150, 16, "")
    mkToggle  (miscSc, "Infinite Jump", false, function(on)
        if on then
            UIS.JumpRequest:Connect(function()
                local c = lp.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
    end)
    mkToggle  (miscSc, "No Clip", false, function(on)
        RS.Stepped:Connect(function()
            if not on then return end
            local c = lp.Character; if not c then return end
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end)
    mkSection (miscSc, "Utility")
    mkButton  (miscSc, "Anti-AFK", function()
        lp.Idled:Connect(function()
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(.1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end)
        Arqel:Notify("Misc","Anti-AFK enabled",3,"success")
    end)
    mkButton  (miscSc, "Copy Player ID", function()
        pcall(function() setclipboard(tostring(lp.UserId)) end)
        Arqel:Notify("Misc","Player ID copied!",2,"copy")
    end)
    mkButton  (miscSc, "Rejoin Server", function()
        Arqel:Notify("Misc","Rejoining…",2,"shield")
        task.delay(1, function()
            pcall(function()
                local ts = game:GetService("TeleportService")
                ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
            end)
        end)
    end)

    mkSection (settingsSc, "Key")
    mkButton  (settingsSc, "Clear Saved Key", function()
        Arqel:ClearSavedKey()
        Arqel:Notify("Settings","Saved key cleared",3,"warning")
    end)
    mkSection (settingsSc, "About")
    mkButton  (settingsSc, "Version", function()
        Arqel:Notify("Zyrix","v1.0 · RightShift = toggle",4,"info")
    end)

    mkSection (playerSc, "Info")
    mkButton  (playerSc, "Show Username",     function() Arqel:Notify("Player",lp.Name,4,"info") end)
    mkButton  (playerSc, "Show Display Name", function() Arqel:Notify("Player",lp.DisplayName,4,"info") end)
    mkButton  (playerSc, "Show User ID",      function() Arqel:Notify("Player",tostring(lp.UserId),4,"info") end)

    -- ── tab buttons ───────────────────────────
    local function selectTab(name)
        if activeTab == name then return end
        activeTab = name
        for _, t in ipairs(TABS) do
            local btn = tabBtns[t.Name]; if not btn then break end
            local on  = t.Name == name
            local txt = btn:FindFirstChild("Text")
            local ico = btn:FindFirstChild("Icon")
            local str = btn:FindFirstChildOfClass("UIStroke")
            tw(btn,.25,{BackgroundColor3 = on and C.EL or C.TAB})
            if txt then tw(txt,.25,{TextColor3 = on and C.WHITE or C.TEXT_DIM}) end
            if ico then tw(ico,.25,{TextColor3 = on and C.WHITE or C.TEXT_DIM}) end
            if str then tw(str,.25,{Transparency = on and 0 or .5}) end
            local td = tabPages[t.Name]
            if td then td.page.Visible = on end
        end
    end

    for i, t in ipairs(TABS) do
        local btn = mkBtn({
            Name = t.Name.."Tab",
            Parent = tabSF,
            Size = UDim2.new(0,80,1,-4),
            BackgroundColor3 = C.EL, BackgroundTransparency = 0,
        })
        btn.LayoutOrder = i
        mkCorner(btn, UDim.new(0,5)); mkStroke(btn, C.STROKE_IN, 1)
        mkPad(btn, 4, 4, 6, 6)
        mkLabel({
            Parent=btn, Name="Icon", Text=t.Icon,
            Size=UDim2.new(0,20,1,0),
            Font=Enum.Font.SourceSans, TextSize=16, TextColor3=C.TEXT_DIM,
            TextYAlignment=Enum.TextYAlignment.Center,
        })
        mkLabel({
            Parent=btn, Name="Text", Text=t.Name,
            Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,22,0,0),
            Font=Enum.Font.GothamMedium, TextSize=12, TextColor3=C.TEXT_DIM,
        })
        btn.MouseEnter:Connect(function()
            if activeTab ~= t.Name then
                tw(btn,.15,{BackgroundColor3=C.HOVER})
                tw(btn:FindFirstChild("Text"),.15,{TextColor3=C.TEXT})
                tw(btn:FindFirstChild("Icon"),.15,{TextColor3=C.WHITE})
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTab ~= t.Name then
                tw(btn,.15,{BackgroundColor3=C.EL})
                tw(btn:FindFirstChild("Text"),.15,{TextColor3=C.TEXT_DIM})
                tw(btn:FindFirstChild("Icon"),.15,{TextColor3=C.TEXT_DIM})
            end
        end)
        btn.MouseButton1Click:Connect(function() selectTab(t.Name) end)
        tabBtns[t.Name] = btn
    end
    selectTab("Combat")

    -- ── open / close ──────────────────────────
    local panelOpen = false

    local function openPanel()
        panelOpen = true
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(0,WIN_W,0,0)
        tw(outer,     .30, {Size=UDim2.new(0,WIN_W,0,TOTAL_H)}, Enum.EasingStyle.Back)
        tw(mainFrame, .30, {Size=UDim2.new(0,WIN_W,0,WIN_H)},   Enum.EasingStyle.Back)
        tw(logoBtn,   .18, {BackgroundColor3=C.TEXT})
        logoImg.ImageColor3 = C.WIN
    end

    local function closePanel()
        panelOpen = false
        tw(outer,     .26, {Size=UDim2.new(0,WIN_W,0,TAB_H)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        tw(mainFrame, .26, {Size=UDim2.new(0,WIN_W,0,0)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        tw(logoBtn,   .18, {BackgroundColor3=C.LOGO_OFF})
        task.delay(.27, function() mainFrame.Visible = false end)
    end

    logoBtn.MouseEnter:Connect(function()
        tw(logoBtn,.12,{BackgroundColor3 = panelOpen and C.WHITE or C.HOVER})
    end)
    logoBtn.MouseLeave:Connect(function()
        tw(logoBtn,.12,{BackgroundColor3 = panelOpen and C.TEXT or C.LOGO_OFF})
    end)
    logoBtn.MouseButton1Click:Connect(function()
        if panelOpen then closePanel() else openPanel() end
    end)
    closeBtn.MouseButton1Click:Connect(closePanel)
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            if panelOpen then closePanel() else openPanel() end
        end
    end)

    -- drag
    local drag, ds, dp = false, nil, nil
    for _, handle in ipairs({tabFrame, hdr}) do
        handle.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                drag=true; ds=i.Position; dp=outer.Position
                i.Changed:Connect(function()
                    if i.UserInputState==Enum.UserInputState.End then drag=false end
                end)
            end
        end)
    end
    UIS.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then
            local d = i.Position - ds
            outer.Position = UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
        end
    end)

    -- open on load
    openPanel()
    Arqel:Notify("Zyrix","UI loaded! Z = toggle panel",4,"success")
    print("[Zyrix] Main UI loaded for", lp.Name)
end

-- fires when wrong key entered
Arqel.Callbacks.OnFail = function(msg)
    warn("[Zyrix] Key rejected:", msg)
end

-- fires when key window is closed without entering a key
Arqel.Callbacks.OnClose = function()
    print("[Zyrix] Key window closed")
end

-- ══════════════════════════════════════════════
-- LAUNCH — always last
-- ══════════════════════════════════════════════
Arqel:Launch()
