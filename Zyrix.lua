--[[
    Zyrix v5 — Key System + Main UI
    Key system runs first. On success the main UI opens.
    Z-logo toggles panel. All elements functional.
]]

repeat task.wait() until game:IsLoaded()

local TS  = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local PLR = game:GetService("Players")
local LT  = game:GetService("Lighting")
local HS  = game:GetService("HttpService")

local player    = PLR.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════
-- YOUR KEYS — change these
-- ══════════════════════════════════════════════════════════
local VALID_KEYS = {
    "ZYRIX-FREE-2024",
    "ZYRIX-VIP-ALPHA",
    "ZYRIX-VIP-BETA",
    "zyrix123",
}

-- ══════════════════════════════════════════════════════════
-- PALETTE
-- ══════════════════════════════════════════════════════════
local C = {
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
    LOGO_OFF  = Color3.fromRGB(100, 100, 100),
    OFF       = Color3.fromRGB(60,  60,  60),
    BLACK     = Color3.fromRGB(0,   0,   0),
}

-- ══════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════
local function tw(obj, t, props, style, dir)
    TS:Create(obj,
        TweenInfo.new(t,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out),
        props):Play()
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 4)
    return c
end

local function mkStroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color           = col   or C.STROKE_EL
    s.Thickness       = thick or 1
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

local function mkGradient(p, from, to, rot)
    local g = Instance.new("UIGradient", p)
    g.Color    = ColorSequence.new(from or C.BLACK, to or C.WIN)
    g.Rotation = rot or 0
    return g
end

local function mkBtn(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor    = false
    b.BackgroundTransparency = 1
    b.Size               = UDim2.new(1, 0, 1, 0)
    b.Text               = ""
    b.BorderSizePixel    = 0
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Size" then b[k] = v end
    end
    if props and props.Size   then b.Size   = props.Size   end
    if props and props.Parent then b.Parent = props.Parent end
    return b
end

local function mkLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.TextWrapped            = true
    l.RichText               = false
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end

local function mkFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel        = 0
    f.BackgroundTransparency = 0
    for k, v in pairs(props or {}) do f[k] = v end
    f.Parent = parent
    return f
end

-- ══════════════════════════════════════════════════════════
-- FILE SYSTEM  (save/load key so user only types it once)
-- ══════════════════════════════════════════════════════════
local FS = pcall(function()
    assert(type(writefile)  == "function")
    assert(type(readfile)   == "function")
    assert(type(isfile)     == "function")
    assert(type(isfolder)   == "function")
    assert(type(makefolder) == "function")
end)

local KEY_PATH = "Zyrix/saved_key.txt"

local function fsSave(k)
    if not FS then return end
    pcall(function()
        if not isfolder("Zyrix") then makefolder("Zyrix") end
        writefile(KEY_PATH, k)
    end)
end

local function fsLoad()
    if not FS then return nil end
    local ok, v = pcall(function()
        return isfile(KEY_PATH) and readfile(KEY_PATH) or nil
    end)
    return (ok and v and v ~= "") and v or nil
end

local function fsClear()
    if not FS then return end
    pcall(function() delfile(KEY_PATH) end)
end

-- ══════════════════════════════════════════════════════════
-- BLUR
-- ══════════════════════════════════════════════════════════
local _blur
local function blurOn()
    pcall(function()
        if LT:FindFirstChild("ZyrixBlur") then LT.ZyrixBlur:Destroy() end
    end)
    _blur = Instance.new("BlurEffect")
    _blur.Name = "ZyrixBlur"; _blur.Size = 0; _blur.Parent = LT
    tw(_blur, .4, {Size = 18})
end
local function blurOff()
    local fx = _blur or LT:FindFirstChild("ZyrixBlur")
    if not fx then return end
    tw(fx, .3, {Size = 0}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    task.delay(.35, function() pcall(function() fx:Destroy() end) end)
    _blur = nil
end

-- ══════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ══════════════════════════════════════════════════════════
local NOTIFS = {}
local function notify(title, msg, dur)
    dur = dur or 4
    local nsg = Instance.new("ScreenGui")
    nsg.Name = "ZyrixNotif"; nsg.ResetOnSpawn = false
    nsg.DisplayOrder = 200; nsg.Parent = playerGui

    local f = mkFrame(nsg, {
        Size             = UDim2.new(0, 300, 0, 68),
        Position         = UDim2.new(1, 320, 1, -14),
        AnchorPoint      = Vector2.new(1, 1),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(f, UDim.new(0, 7)); mkStroke(f, C.STROKE_WIN, .8)

    -- accent bar
    local accent = mkFrame(f, {
        Size = UDim2.new(0, 3, 1, -14), Position = UDim2.new(0, 0, 0, 7),
        BackgroundColor3 = Color3.fromRGB(180, 180, 180),
    })
    mkCorner(accent, UDim.new(0, 2))

    mkLabel({ Parent=f, Text=title,
        Size=UDim2.new(1,-20,0,20), Position=UDim2.new(0,14,0,8),
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=C.WHITE })
    mkLabel({ Parent=f, Text=msg,
        Size=UDim2.new(1,-20,0,18), Position=UDim2.new(0,14,0,30),
        Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=C.TEXT_DIM })

    local bar = mkFrame(f, {
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),
        BackgroundColor3=Color3.fromRGB(160,160,160),
    })
    mkCorner(bar, UDim.new(0,2))

    local id = HS:GenerateGUID(false)
    table.insert(NOTIFS, {id=id, f=f, g=nsg})

    local function restack()
        local y = 0
        for i = #NOTIFS, 1, -1 do
            local n = NOTIFS[i]
            if n and n.f and n.f.Parent then
                tw(n.f, .22, {Position=UDim2.new(1,-14,1,-14-y)}); y = y + 80
            end
        end
    end

    tw(f, .32, {Position=UDim2.new(1,-14,1,-14)}); task.wait(.04); restack()

    local function dismiss()
        for i, n in ipairs(NOTIFS) do
            if n.id == id then table.remove(NOTIFS,i); break end
        end
        tw(f, .22, {Position=UDim2.new(1,320,f.Position.Y.Scale,f.Position.Y.Offset)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(.25, function() nsg:Destroy(); restack() end)
    end

    tw(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,0,2)})
    task.delay(dur, dismiss)
    local gb = mkBtn({Parent=f}); gb.ZIndex = 10
    gb.MouseButton1Click:Connect(dismiss)
end

-- ══════════════════════════════════════════════════════════
-- DRAG
-- ══════════════════════════════════════════════════════════
local function makeDrag(handle, target)
    local down, ds, dp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            down = true; ds = i.Position; dp = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then down = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not down then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            target.Position = UDim2.new(
                dp.X.Scale, dp.X.Offset + d.X,
                dp.Y.Scale, dp.Y.Offset + d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════════════════════════════════
local function checkKey(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then return true end
    end
    return false
end

local function buildKeyUI(onSuccess)
    -- clean up any old instance
    pcall(function()
        local old = playerGui:FindFirstChild("ZyrixKeyUI")
        if old then old:Destroy() end
    end)

    local ksg = Instance.new("ScreenGui")
    ksg.Name = "ZyrixKeyUI"; ksg.ResetOnSpawn = false
    ksg.IgnoreGuiInset = true; ksg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ksg.Parent = playerGui

    blurOn()

    -- window
    local W, H = 380, 290
    local win = mkFrame(ksg, {
        Size             = UDim2.new(0, W, 0, H),
        Position         = UDim2.new(.5, 0, 1.8, 0),
        AnchorPoint      = Vector2.new(.5, .5),
        BackgroundColor3 = C.WIN,
    })
    mkCorner(win, UDim.new(0, 10)); mkStroke(win, C.STROKE_WIN, 1)

    -- header
    local hdr = mkFrame(win, {
        Size=UDim2.new(1,0,0,50), BackgroundColor3=C.TAB,
    })
    mkCorner(hdr, UDim.new(0,10))
    -- square off the bottom of the header
    mkFrame(hdr, {
        Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10),
        BackgroundColor3=C.TAB,
    })
    -- divider line
    mkFrame(win, {
        Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,50),
        BackgroundColor3=C.STROKE_IN,
    })

    -- logo Z
    local kLogo = mkBtn({
        Parent=hdr,
        Size=UDim2.new(0,30,0,30), Position=UDim2.new(0,12,0.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.TEXT, BackgroundTransparency=0,
    })
    mkCorner(kLogo, UDim.new(0,6))
    mkLabel({
        Parent=kLogo, Text="Z",
        Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold, TextSize=18, TextColor3=C.WIN,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextYAlignment=Enum.TextYAlignment.Center,
    })

    mkLabel({
        Parent=hdr, Text="Zyrix",
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,50,0,0),
        Font=Enum.Font.GothamBold, TextSize=19, TextColor3=C.WHITE,
    })

    -- close X
    local xBtn = mkBtn({
        Parent=hdr,
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-12,0.5,0),
        AnchorPoint=Vector2.new(1,.5),
        BackgroundColor3=C.HOVER, BackgroundTransparency=0,
    })
    mkCorner(xBtn, UDim.new(0,5))
    mkLabel({
        Parent=xBtn, Text="✕",
        Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=C.TEXT,
        TextXAlignment=Enum.TextXAlignment.Center,
    })
    xBtn.MouseEnter:Connect(function() tw(xBtn,.12,{BackgroundColor3=C.EL}) end)
    xBtn.MouseLeave:Connect(function() tw(xBtn,.12,{BackgroundColor3=C.HOVER}) end)

    -- status box
    local sBg = mkFrame(win, {
        Size=UDim2.new(0,W-28,0,52), Position=UDim2.new(0,14,0,62),
        BackgroundColor3=C.EL,
    })
    mkCorner(sBg); mkStroke(sBg, C.STROKE_EL, .7)
    local sLbl = mkLabel({
        Parent=sBg, Text="Enter your key to continue",
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
        Font=Enum.Font.GothamMedium, TextSize=13,
        TextColor3=C.TEXT_DIM, TextWrapped=true,
    })

    -- input box
    local inBg = mkFrame(win, {
        Size=UDim2.new(0,W-28,0,42), Position=UDim2.new(0,14,0,126),
        BackgroundColor3=C.EL,
    })
    mkCorner(inBg)
    local inStr = mkStroke(inBg, C.STROKE_EL, .8)

    local tb = Instance.new("TextBox", inBg)
    tb.Size=UDim2.new(1,-20,1,0); tb.Position=UDim2.new(0,10,0,0)
    tb.BackgroundTransparency=1; tb.TextColor3=C.TEXT
    tb.PlaceholderColor3=C.TEXT_GREY; tb.PlaceholderText="Enter your key…"
    tb.TextSize=14; tb.Font=Enum.Font.GothamMedium
    tb.ClearTextOnFocus=false; tb.TextXAlignment=Enum.TextXAlignment.Left
    tb.Text=""
    tb.Focused:Connect(function()  tw(inStr,.14,{Color=C.TEXT_DIM})  end)
    tb.FocusLost:Connect(function() tw(inStr,.14,{Color=C.STROKE_EL}) end)

    -- divider
    mkFrame(win, {
        Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,180),
        BackgroundColor3=C.STROKE_IN,
    })

    -- Redeem button
    local redeemBtn = mkBtn({
        Parent=win,
        Size=UDim2.new(0,W-56,0,38), Position=UDim2.new(.5,0,0,192),
        AnchorPoint=Vector2.new(.5,0),
        BackgroundColor3=C.TEXT, BackgroundTransparency=0,
    })
    mkCorner(redeemBtn)
    mkLabel({
        Parent=redeemBtn, Text="Redeem Key",
        Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=C.WIN,
        TextXAlignment=Enum.TextXAlignment.Center,
    })
    mkStroke(redeemBtn, C.TEXT_DIM, .8)
    redeemBtn.MouseEnter:Connect(function()
        tw(redeemBtn,.12,{BackgroundColor3=Color3.fromRGB(220,220,220)})
    end)
    redeemBtn.MouseLeave:Connect(function()
        tw(redeemBtn,.12,{BackgroundColor3=C.TEXT})
    end)

    -- status helpers
    local _dt
    local function setStatus(state, msg)
        if _dt then task.cancel(_dt); _dt = nil end
        local col = C.TEXT_DIM
        if state == "ok" then
            col = Color3.fromRGB(180,180,180)
            sLbl.Text = msg or "Access granted!"
        elseif state == "err" then
            col = C.TEXT_GREY
            sLbl.Text = msg or "Invalid key"
        elseif state == "busy" then
            col = C.WHITE
            _dt = task.spawn(function()
                local dots = {".","..","..."}; local i = 1
                while sLbl and sLbl.Parent do
                    sLbl.Text = (msg or "Verifying") .. dots[i]
                    i = (i % 3) + 1; task.wait(.4)
                end
            end)
        else
            sLbl.Text = msg or "Enter your key to continue"
        end
        tw(sLbl, .15, {TextColor3 = col})
    end

    -- redeem logic
    local function doRedeem()
        local key = tb.Text:gsub("%s+", "")
        if key == "" then
            setStatus("err","Please enter a key first")
            notify("Error","No key entered",3)
            return
        end

        setStatus("busy","Verifying")
        redeemBtn.Active = false
        task.wait(.3)

        if checkKey(key) then
            fsSave(key)
            setStatus("ok","Access granted!")
            notify("Success","Welcome to Zyrix!",3)
            task.wait(.8)
            -- animate window out
            tw(win, .35, {Position=UDim2.new(.5,0,-0.7,0)},
                Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(.38, function()
                blurOff()
                ksg:Destroy()
                onSuccess()   -- <<< THIS IS WHAT OPENS THE MAIN UI
            end)
        else
            redeemBtn.Active = true
            setStatus("err","That key is not valid")
            notify("Rejected","Key not found",4)
            -- shake
            local ox = win.Position.X.Offset
            for _, dx in ipairs({-9,9,-6,6,-3,0}) do
                tw(win, TweenInfo.new(.05,Enum.EasingStyle.Linear),
                    {Position=UDim2.new(.5,ox+dx,win.Position.Y.Scale,win.Position.Y.Offset)})
                task.wait(.055)
            end
        end
    end

    redeemBtn.MouseButton1Click:Connect(function() task.spawn(doRedeem) end)
    tb.FocusLost:Connect(function(enter)
        if enter then task.spawn(doRedeem) end
    end)

    xBtn.MouseButton1Click:Connect(function()
        tw(win,.32,{Position=UDim2.new(.5,0,-0.7,0)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(.34, function() blurOff(); ksg:Destroy() end)
    end)

    makeDrag(hdr, win)
    -- slide in
    tw(win, .46, {Position=UDim2.new(.5,0,.5,0)})
end

-- ══════════════════════════════════════════════════════════════════════
-- MAIN UI  (the reference design, bugs fixed)
-- ══════════════════════════════════════════════════════════════════════
local function buildMainUI()
    pcall(function()
        local old = playerGui:FindFirstChild("ZyrixMainUI")
        if old then old:Destroy() end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixMainUI"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 50; sg.Parent = playerGui

    -- layout constants (from reference)
    local WIN_W  = 563
    local WIN_H  = 354
    local TAB_H  = 42
    local GAP    = 8
    local TOTAL_H = TAB_H + GAP + WIN_H

    -- outer container
    local outer = mkFrame(sg, {
        Name             = "ZyrixOuter",
        Size             = UDim2.new(0, WIN_W, 0, TAB_H),
        Position         = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(outer, UDim.new(0,8)); mkStroke(outer, C.STROKE_WIN, 1)
    mkGradient(outer, C.BLACK, C.TAB)

    -- ── TAB BAR ──────────────────────────────────────────────────────
    local tabFrame = mkFrame(outer, {
        Name             = "TabFrame",
        BackgroundColor3 = C.TAB,
        Size             = UDim2.new(1,0,0,TAB_H),
        Position         = UDim2.new(0,0,0,0),
    })
    mkCorner(tabFrame, UDim.new(0,8))
    mkGradient(tabFrame, C.BLACK, C.TAB)

    -- Z logo button
    local logoBtn = mkBtn({
        Name             = "LogoBtn",
        Parent           = tabFrame,
        Size             = UDim2.new(0,36,0,36),
        Position         = UDim2.new(0,4,0.5,-18),
        BackgroundColor3 = C.TEXT,
        BackgroundTransparency = 0,
    })
    mkCorner(logoBtn, UDim.new(0,6))

    local logoText = mkLabel({
        Name      = "LogoText",
        Parent    = logoBtn,
        Size      = UDim2.new(1,0,1,0),
        Text      = "Z",
        Font      = Enum.Font.GothamBold,
        TextSize  = 22,
        TextColor3 = C.WIN,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    logoText.ZIndex = logoBtn.ZIndex + 1

    -- tab scrolling frame
    local tabSF = Instance.new("ScrollingFrame")
    tabSF.Name                   = "tablist"
    tabSF.Size                   = UDim2.new(1,-46,1,0)
    tabSF.Position               = UDim2.new(0,42,0,0)
    tabSF.BackgroundTransparency = 1
    tabSF.BorderSizePixel        = 0
    tabSF.ScrollBarThickness     = 0
    tabSF.ScrollingDirection     = Enum.ScrollingDirection.X
    tabSF.VerticalScrollBarInset = Enum.ScrollBarInset.Always
    tabSF.AutomaticCanvasSize    = Enum.AutomaticSize.X
    tabSF.CanvasSize             = UDim2.new(0,0,0,0)
    tabSF.Parent                 = tabFrame

    local tabListLayout = Instance.new("UIListLayout", tabSF)
    tabListLayout.FillDirection       = Enum.FillDirection.Horizontal
    tabListLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding             = UDim.new(0,4)
    tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local tabPad = Instance.new("UIPadding", tabSF)
    tabPad.PaddingLeft = UDim.new(0,3)

    -- tab definitions
    local TABS = {
        {Name="Combat",   Icon="⚔"},
        {Name="Visual",   Icon="👁"},
        {Name="Misc",     Icon="⚙"},
        {Name="Settings", Icon="🔧"},
        {Name="Player",   Icon="🧑"},
    }

    local tabBtns  = {}
    local tabPages = {}
    local activeTabName = nil

    -- ── MAIN FRAME ───────────────────────────────────────────────────
    local mainFrame = mkFrame(outer, {
        Name             = "main",
        Size             = UDim2.new(0,WIN_W,0,0),    -- closed by default
        Position         = UDim2.new(0,0,0,TAB_H+GAP),
        BackgroundColor3 = C.WIN,
        ClipsDescendants = true,
        Visible          = false,
    })
    mkCorner(mainFrame, UDim.new(0,8))
    mkGradient(mainFrame, C.BLACK, C.WIN)

    -- main frame header
    local hdr = mkFrame(mainFrame, {
        Name             = "Header",
        Size             = UDim2.new(1,0,0,34),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(hdr, UDim.new(0,6))
    -- square bottom of header
    mkFrame(hdr, {
        Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,1,-6),
        BackgroundColor3=C.TAB,
    })

    mkLabel({
        Name="Title", Parent=hdr,
        Size=UDim2.new(1,-40,1,0), Position=UDim2.new(0,10,0,0),
        Text="Zyrix", Font=Enum.Font.GothamBold, TextSize=16, TextColor3=C.WHITE,
    })

    local closeBtn = mkBtn({
        Name="CloseBtn", Parent=hdr,
        Size=UDim2.new(0,24,0,24), Position=UDim2.new(1,-28,0.5,-12),
        BackgroundColor3=C.HOVER, BackgroundTransparency=0,
    })
    mkCorner(closeBtn, UDim.new(0,4))
    mkLabel({
        Parent=closeBtn, Text="✕",
        Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold, TextSize=13,
        TextColor3=C.TEXT, TextXAlignment=Enum.TextXAlignment.Center,
    })
    closeBtn.MouseEnter:Connect(function() tw(closeBtn,.12,{BackgroundColor3=C.EL}) end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn,.12,{BackgroundColor3=C.HOVER}) end)

    -- separator
    local sep = Instance.new("Frame")
    sep.Name="Sep"; sep.Size=UDim2.new(1,-20,0,1); sep.Position=UDim2.new(0,10,0,34)
    sep.BackgroundColor3=C.STROKE_IN; sep.BorderSizePixel=0; sep.Parent=mainFrame

    -- page host — all tab pages go here
    local pageHost = mkFrame(mainFrame, {
        Size=UDim2.new(1,0,1,-38), Position=UDim2.new(0,0,0,38),
        BackgroundTransparency=1, ClipsDescendants=true,
    })

    -- ── ELEMENT BUILDERS ─────────────────────────────────────────────

    local function elementFrame(parent, titleText)
        local f = mkFrame(parent, {
            Name=titleText or "Element",
            Size=UDim2.new(1,-4,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=C.EL,
        })
        mkCorner(f, UDim.new(0,4)); mkStroke(f, C.STROKE_EL, 1)
        mkPad(f, 8, 8, 8, 8)
        mkLabel({
            Parent=f, Name="Title", Text=titleText or "",
            Size=UDim2.new(1,0,0,14),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT_DIM,
        })
        local cp = Instance.new("UIPadding", f)
        cp.Name="ContentPad"; cp.PaddingTop=UDim.new(0,22)
        return f
    end

    local function buildSection(parent, label)
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

    local function buildToggle(parent, label, default, callback)
        local f = elementFrame(parent, label)

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

        return {
            Get = function() return state end,
            Set = function(v)
                state = v; refresh()
                if callback then pcall(callback, v) end
            end,
        }
    end

    local function buildSlider(parent, label, min, max, default, suffix, callback)
        local f = elementFrame(parent, label)

        local track = mkFrame(f, {
            Name="Main", Size=UDim2.new(1,-2,0,26),
            BackgroundColor3=C.INNER,
        })
        mkCorner(track, UDim.new(0,4)); mkStroke(track, C.STROKE_IN, 1)

        local fill = mkFrame(track, {
            Name="Progress", Size=UDim2.new(0,0,1,0),
            BackgroundColor3=C.PROGRESS,
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
            local pct = (val - min) / math.max(1, max - min)
            tw(fill, .08, {Size=UDim2.new(pct,0,1,0)}, Enum.EasingStyle.Quad)
            valLbl.Text = tostring(val) .. (suffix or "")
            if callback then pcall(callback, val) end
        end
        setVal(val)

        local interact = mkBtn({Parent=track}); interact.ZIndex = 10

        interact.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                local abs = track.AbsolutePosition
                local sz  = track.AbsoluteSize
                setVal(min + math.clamp((i.Position.X - abs.X) / math.max(1,sz.X), 0, 1) * (max - min))
                tw(track,.08,{Size=UDim2.new(1,-2,0,30)}, Enum.EasingStyle.Back)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then
                local abs = track.AbsolutePosition
                local sz  = track.AbsoluteSize
                setVal(min + math.clamp((i.Position.X - abs.X) / math.max(1,sz.X), 0, 1) * (max - min))
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                tw(track,.20,{Size=UDim2.new(1,-2,0,26)}, Enum.EasingStyle.Back)
            end
        end)
        track.MouseEnter:Connect(function() tw(track,.12,{BackgroundColor3=C.HOVER}) end)
        track.MouseLeave:Connect(function() tw(track,.12,{BackgroundColor3=C.INNER}) end)

        return {Get=function() return val end, Set=setVal}
    end

    local function buildDropdown(parent, label, options, default, callback)
        local f = elementFrame(parent, label)
        f.ClipsDescendants = true

        local row = mkBtn({
            Parent=f, Size=UDim2.new(1,-2,0,30),
            BackgroundColor3=C.INNER, BackgroundTransparency=0,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)

        local selLbl = mkLabel({
            Parent=row, Text=default or (options[1] or ""),
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
            BackgroundColor3=C.DD_BG, ClipsDescendants=true, Visible=false,
            ZIndex=20,
        })
        mkCorner(list, UDim.new(0,4)); mkStroke(list, C.STROKE_IN, 1)
        mkPad(list, 4, 4, 4, 4)
        local ll = Instance.new("UIListLayout", list)
        ll.Padding=UDim.new(0,3); ll.SortOrder=Enum.SortOrder.LayoutOrder

        local current = default or (options[1] or "")
        local isOpen  = false
        local ITEM_H  = 30
        local fullH   = #options * (ITEM_H+3) + 8

        for _, opt in ipairs(options) do
            local item = mkBtn({
                Parent=list, Size=UDim2.new(1,0,0,ITEM_H),
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
                current = opt; selLbl.Text = opt; isOpen = false
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},
                    Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible = false end)
                if callback then pcall(callback, opt) end
            end)
        end

        local function toggleDD()
            isOpen = not isOpen
            if isOpen then
                list.Visible = true; list.Size = UDim2.new(1,-2,0,0)
                tw(arrowBg,.15,{Rotation=180})
                tw(list,.20,{Size=UDim2.new(1,-2,0,fullH)})
            else
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},
                    Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible = false end)
            end
        end

        row.MouseButton1Click:Connect(toggleDD)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)

        return {
            Get=function() return current end,
            Set=function(v) current=v; selLbl.Text=v end,
        }
    end

    local function buildKeybind(parent, label, default, callback)
        local f = elementFrame(parent, label)

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

        local capturing = false
        local curKey    = default or Enum.KeyCode.Unknown

        keyBox.MouseButton1Click:Connect(function()
            capturing = true; keyLbl.Text = "…"
            tw(keyBox,.12,{BackgroundColor3=C.HOVER})
        end)
        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if capturing and i.UserInputType==Enum.UserInputType.Keyboard
            and i.KeyCode ~= Enum.KeyCode.Escape then
                curKey = i.KeyCode; keyLbl.Text = curKey.Name
                capturing = false; tw(keyBox,.12,{BackgroundColor3=C.EL}); return
            end
            if i.KeyCode == curKey and callback then pcall(callback, true) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.KeyCode == curKey and callback then pcall(callback, false) end
        end)

        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)
    end

    local function buildButton(parent, label, callback)
        local f = elementFrame(parent, label)

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
            tw(row,.06,{Size=UDim2.new(1,-2,0,29)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        end)
        row.MouseButton1Up:Connect(function()
            tw(row,.20,{Size=UDim2.new(1,-2,0,32)}, Enum.EasingStyle.Back)
        end)
        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.EL}) end)
    end

    -- ── CREATE TAB PAGES ─────────────────────────────────────────────
    local function newPage(name)
        local page = mkFrame(pageHost, {
            Name=name.."Page", Size=UDim2.new(1,0,1,0),
            BackgroundTransparency=1, Visible=false,
        })
        local scroll = Instance.new("ScrollingFrame", page)
        scroll.Name="Scroll"; scroll.Size=UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
        scroll.ScrollBarThickness=2
        scroll.ScrollBarImageColor3=Color3.fromRGB(141,141,141)
        scroll.ScrollBarImageTransparency=0.3
        scroll.CanvasSize=UDim2.new(0,0,0,0)
        scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
        scroll.ScrollingDirection=Enum.ScrollingDirection.Y
        local ll = Instance.new("UIListLayout", scroll)
        ll.Padding=UDim.new(0,6); ll.SortOrder=Enum.SortOrder.LayoutOrder
        mkPad(scroll, 6, 6, 6, 6)
        tabPages[name] = {page=page, scroll=scroll}
        return scroll
    end

    local combatSc   = newPage("Combat")
    local visualSc   = newPage("Visual")
    local miscSc     = newPage("Misc")
    local settingsSc = newPage("Settings")
    local playerSc   = newPage("Player")

    -- ── COMBAT ───────────────────────────────────────────────────────
    buildSection(combatSc,  "Aimbot")
    buildToggle (combatSc,  "Enable Aimbot",  false)
    buildSlider (combatSc,  "FOV",            10, 360, 90,  "°")
    buildSlider (combatSc,  "Smoothness",     1,  100, 20,  "%")
    buildDropdown(combatSc, "Aim Part",
        {"Head","Neck","Torso","HumanoidRootPart"}, "Head")
    buildKeybind(combatSc,  "Hold to Aim",   Enum.KeyCode.Q)
    buildSection(combatSc,  "Silent Aim")
    buildToggle (combatSc,  "Silent Aim",     false)
    buildSlider (combatSc,  "Hit Chance",     0, 100, 75, "%")
    buildSection(combatSc,  "Actions")
    buildButton (combatSc,  "Reset Aimbot",   function() notify("Combat","Aimbot reset!",2) end)

    -- ── VISUAL ───────────────────────────────────────────────────────
    buildSection(visualSc,  "ESP")
    buildToggle (visualSc,  "Enable ESP",     false)
    buildSlider (visualSc,  "Range",          50, 2000, 500, " st")
    buildToggle (visualSc,  "Show Names",     true)
    buildToggle (visualSc,  "Show Distance",  false)
    buildToggle (visualSc,  "Show Health",    true)
    buildDropdown(visualSc, "Box Type",
        {"2D Box","3D Box","Corner Box"}, "2D Box")
    buildSection(visualSc,  "World")
    buildToggle (visualSc,  "No Fog",         false)
    buildToggle (visualSc,  "Full Bright",    false)

    -- ── MISC ─────────────────────────────────────────────────────────
    buildSection(miscSc,    "Movement")
    buildToggle (miscSc,    "Speed Hack",     false)
    buildSlider (miscSc,    "Walk Speed",     16, 150, 16, "")
    buildToggle (miscSc,    "Fly",            false)
    buildSlider (miscSc,    "Fly Speed",      10, 200, 50, "")
    buildToggle (miscSc,    "Infinite Jump",  false)
    buildToggle (miscSc,    "No Clip",        false)
    buildSection(miscSc,    "Utility")
    buildButton (miscSc,    "Copy Player ID", function()
        pcall(function() setclipboard(tostring(player.UserId)) end)
        notify("Misc","Player ID copied!",2) end)
    buildButton (miscSc,    "Rejoin Server",  function()
        pcall(function()
            local ts = game:GetService("TeleportService")
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end); notify("Misc","Rejoining…",2) end)

    -- ── SETTINGS ─────────────────────────────────────────────────────
    buildSection(settingsSc, "Key")
    buildButton (settingsSc, "Clear Saved Key", function()
        fsClear(); notify("Settings","Saved key cleared — restart to re-enter",4) end)
    buildSection(settingsSc, "Info")
    mkLabel({
        Parent=settingsSc,
        Text="Zyrix v5  ·  RightShift = toggle UI",
        Size=UDim2.new(1,-4,0,24),
        Font=Enum.Font.GothamMedium, TextSize=11, TextColor3=C.TEXT_GREY,
    })

    -- ── PLAYER ───────────────────────────────────────────────────────
    buildSection(playerSc,  "Info")
    buildButton (playerSc,  "Show Username",     function() notify("Player",player.Name,4) end)
    buildButton (playerSc,  "Show Display Name", function() notify("Player",player.DisplayName,4) end)
    buildButton (playerSc,  "Show User ID",      function() notify("Player",tostring(player.UserId),4) end)

    -- ── TAB BUTTONS ──────────────────────────────────────────────────
    local function selectTab(name)
        if activeTabName == name then return end
        activeTabName = name
        for _, t in ipairs(TABS) do
            local btn   = tabBtns[t.Name]; if not btn then break end
            local isAct = (t.Name == name)
            local txt   = btn:FindFirstChild("Text")
            local ico   = btn:FindFirstChild("Icon")
            local str   = btn:FindFirstChildOfClass("UIStroke")
            tw(btn,.25,{BackgroundColor3 = isAct and C.EL or C.TAB})
            if txt then tw(txt,.25,{TextColor3 = isAct and C.WHITE or C.TEXT_DIM}) end
            if ico then tw(ico,.25,{TextColor3 = isAct and C.WHITE or C.TEXT_DIM}) end
            if str then tw(str,.25,{Transparency = isAct and 0 or .5}) end
            local td = tabPages[t.Name]
            if td then td.page.Visible = isAct end
        end
    end

    for i, t in ipairs(TABS) do
        local btn = mkBtn({
            Name            = t.Name.."Tab",
            Parent          = tabSF,
            Size            = UDim2.new(0,80,1,-4),
            BackgroundColor3 = C.EL,
            BackgroundTransparency = 0,
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
            if activeTabName ~= t.Name then
                tw(btn,.15,{BackgroundColor3=C.HOVER})
                tw(btn:FindFirstChild("Text"),.15,{TextColor3=C.TEXT})
                tw(btn:FindFirstChild("Icon"),.15,{TextColor3=C.WHITE})
            end
        end)
        btn.MouseLeave:Connect(function()
            if activeTabName ~= t.Name then
                tw(btn,.15,{BackgroundColor3=C.EL})
                tw(btn:FindFirstChild("Text"),.15,{TextColor3=C.TEXT_DIM})
                tw(btn:FindFirstChild("Icon"),.15,{TextColor3=C.TEXT_DIM})
            end
        end)
        btn.MouseButton1Click:Connect(function() selectTab(t.Name) end)
        tabBtns[t.Name] = btn
    end

    selectTab("Combat")

    -- ── OPEN / CLOSE (Z logo) ────────────────────────────────────────
    local panelOpen = false

    local function openPanel()
        panelOpen     = true
        mainFrame.Visible = true
        mainFrame.Size    = UDim2.new(0,WIN_W,0,0)
        tw(outer,     .30, {Size=UDim2.new(0,WIN_W,0,TOTAL_H)}, Enum.EasingStyle.Back)
        tw(mainFrame, .30, {Size=UDim2.new(0,WIN_W,0,WIN_H)},   Enum.EasingStyle.Back)
        tw(logoBtn,   .18, {BackgroundColor3=C.TEXT})
        logoText.TextColor3 = C.WIN
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

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.RightShift then
            if panelOpen then closePanel() else openPanel() end
        end
    end)

    -- drag
    makeDrag(tabFrame, outer)
    makeDrag(hdr,      outer)

    -- open immediately after key success
    openPanel()

    notify("Welcome","Zyrix loaded! Z = toggle panel.",4)

    return {
        Open    = openPanel,
        Close   = closePanel,
        Notify  = notify,
        Scrolls = {
            combat   = combatSc,
            visual   = visualSc,
            misc     = miscSc,
            settings = settingsSc,
            player   = playerSc,
        },
        Builders = {
            Toggle   = buildToggle,
            Slider   = buildSlider,
            Dropdown = buildDropdown,
            Keybind  = buildKeybind,
            Button   = buildButton,
            Section  = buildSection,
        },
    }
end

-- ══════════════════════════════════════════════════════════════════════
-- ENTRY POINT
-- Show key UI first. On success open main UI.
-- If a saved valid key exists, skip straight to main UI.
-- ══════════════════════════════════════════════════════════════════════
local function launch()
    -- check saved key first
    local saved = fsLoad()
    if saved and checkKey(saved) then
        notify("Welcome back!","Key validated ✓",3)
        local ui = buildMainUI()
        getgenv()._ZyrixUI = ui
        return
    elseif saved then
        -- saved key is no longer in the list
        fsClear()
    end

    -- show key system, open main UI after success
    buildKeyUI(function()
        local ui = buildMainUI()
        getgenv()._ZyrixUI = ui
    end)
end

launch()
