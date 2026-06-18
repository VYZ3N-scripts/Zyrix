--[[
  ███████╗██╗   ██╗██████╗ ██╗██╗  ██╗
  ╚══███╔╝╚██╗ ██╔╝██╔══██╗██║╚██╗██╔╝
    ███╔╝  ╚████╔╝ ██████╔╝██║ ╚███╔╝
   ███╔╝    ╚██╔╝  ██╔══██╗██║ ██╔██╗
  ███████╗   ██║   ██║  ██║██║██╔╝ ██╗
  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
  v5 — Key System + Full UI
  Uses the provided tab-bar design exactly.
  Z-logo toggles main panel open/closed.
  All element builders (Toggle, Slider, Dropdown, Keybind, Button) functional.
]]

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- GUARD
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end
local hui      = gethui()

if getgenv().ZyrixLoaded then
    if hui:FindFirstChild("ZyrixKeySystem") then return getgenv().Zyrix end
    if hui:FindFirstChild("ZyrixMainUI")    then return getgenv().Zyrix end
end
getgenv().ZyrixLoaded = true

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- SERVICES
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local TS  = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS  = cloneref(game:GetService("RunService"))
local HS  = cloneref(game:GetService("HttpService"))
local LT  = cloneref(game:GetService("Lighting"))
local PL  = cloneref(game:GetService("Players"))
local LP  = cloneref(PL.LocalPlayer)

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- CONFIG
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local CFG = {
    Title       = "Zyrix",
    Logo        = "rbxassetid://105436073524298",
    Subtitle    = "Enter your key to continue",
    GetKeyLink  = "",
    DiscordLink = "",
    FileName    = "Zyrix_Key",
    Remember    = true,
    AutoLoad    = true,
    Blur        = true,
    Draggable   = true,
    ToggleKey   = Enum.KeyCode.RightShift,
}

local CB = {
    OnVerify  = nil,
    OnSuccess = nil,
    OnFail    = nil,
    OnClose   = nil,
}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- PALETTE  (from reference script, extended)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
    GREEN2    = Color3.fromRGB(0,   121, 0),
    HOVER     = Color3.fromRGB(45,  45,  45),
    LOGO_OFF  = Color3.fromRGB(100, 100, 100),
    OFF       = Color3.fromRGB(60,  60,  60),
    BLACK     = Color3.fromRGB(0,   0,   0),
}

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- TWEEN / FACTORY HELPERS  (matching reference style exactly)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local function tw(obj, t, props, style, dir)
    TS:Create(obj,
        TweenInfo.new(t,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out),
        props):Play()
end

local function mkCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0,4)
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
    return u
end

local function mkGradient(p, from, to, rot)
    local g = Instance.new("UIGradient", p)
    g.Color    = ColorSequence.new(from or C.BLACK, to or C.WIN)
    g.Rotation = rot or 0
    return g
end

-- transparent full-size click catcher
local function mkBtn(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor    = false
    b.BackgroundTransparency = 1
    b.Size               = UDim2.new(1,0,1,0)
    b.Text               = ""
    b.BorderSizePixel    = 0
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then b[k] = v end
    end
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
    for k,v in pairs(props or {}) do l[k] = v end
    return l
end

local function mkFrame(parent, props)
    local f = Instance.new("Frame")
    f.BorderSizePixel       = 0
    f.BackgroundTransparency = 0
    for k,v in pairs(props or {}) do f[k] = v end
    f.Parent = parent
    return f
end

local function mkScrollFrame(parent, props)
    local s = Instance.new("ScrollingFrame")
    s.BorderSizePixel          = 0
    s.BackgroundTransparency   = 1
    s.ScrollBarThickness       = 2
    s.ScrollBarImageColor3     = Color3.fromRGB(141,141,141)
    s.ScrollBarImageTransparency = 0.3
    s.CanvasSize               = UDim2.new(0,0,0,0)
    s.AutomaticCanvasSize      = Enum.AutomaticSize.Y
    for k,v in pairs(props or {}) do s[k] = v end
    s.Parent = parent
    return s
end

local function mkListLayout(parent, props)
    local l = Instance.new("UIListLayout", parent)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    for k,v in pairs(props or {}) do l[k] = v end
    return l
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- FILE SYSTEM
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local FS = pcall(function()
    assert(type(writefile)=="function" and type(readfile)=="function"
        and type(isfile)=="function"   and type(isfolder)=="function"
        and type(makefolder)=="function")
end)

local function fsEnsure()
    if not FS then return end
    pcall(function() if not isfolder("Zyrix") then makefolder("Zyrix") end end)
end
local function fsSave(k)
    if not FS or not CFG.Remember then return end
    fsEnsure(); pcall(function() writefile("Zyrix/"..CFG.FileName..".txt", k) end)
end
local function fsLoad()
    if not FS then return nil end
    local ok,v = pcall(function()
        local p = "Zyrix/"..CFG.FileName..".txt"
        return isfile(p) and readfile(p) or nil
    end)
    return (ok and v and v ~= "") and v or nil
end
local function fsClear()
    if not FS then return end
    pcall(function() delfile("Zyrix/"..CFG.FileName..".txt") end)
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- BLUR
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local _blur
local function blurOn()
    if not CFG.Blur then return end
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

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- NOTIFICATIONS
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
local NOTIFS = {}
local function notify(title, msg, dur)
    dur = dur or 4
    local sg2 = Instance.new("ScreenGui")
    sg2.Name         = "ZyrixNotif"
    sg2.ResetOnSpawn = false
    sg2.DisplayOrder = 200
    sg2.Parent       = hui

    local f = mkFrame(sg2, {
        Size             = UDim2.new(0,300,0,68),
        Position         = UDim2.new(1,320,1,-14),
        AnchorPoint      = Vector2.new(1,1),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(f, UDim.new(0,7)); mkStroke(f, C.STROKE_WIN, .8)

    local accent = mkFrame(f, {
        Size             = UDim2.new(0,3,1,-14),
        Position         = UDim2.new(0,0,0,7),
        BackgroundColor3 = Color3.fromRGB(180,180,180),
    })
    mkCorner(accent, UDim.new(0,2))

    mkLabel({
        Parent = f, Text = title,
        Size = UDim2.new(1,-22,0,20), Position = UDim2.new(0,14,0,8),
        TextSize = 13, Font = Enum.Font.GothamBold, TextColor3 = C.WHITE,
    })
    mkLabel({
        Parent = f, Text = msg,
        Size = UDim2.new(1,-22,0,18), Position = UDim2.new(0,14,0,30),
        TextSize = 11, Font = Enum.Font.GothamMedium, TextColor3 = C.TEXT_DIM,
    })

    local prog = mkFrame(f, {
        Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = Color3.fromRGB(160,160,160),
    })
    mkCorner(prog, UDim.new(0,2))

    local id = HS:GenerateGUID(false)
    table.insert(NOTIFS, {id=id, f=f, g=sg2})

    local function restack()
        local y = 0
        for i = #NOTIFS, 1, -1 do
            local n = NOTIFS[i]
            if n and n.f and n.f.Parent then
                tw(n.f, .22, {Position = UDim2.new(1,-14,1,-14-y)})
                y = y + 80
            end
        end
    end

    tw(f, .32, {Position = UDim2.new(1,-14,1,-14)})
    task.wait(.04); restack()

    local function dismiss()
        for i,n in ipairs(NOTIFS) do
            if n.id == id then table.remove(NOTIFS,i); break end
        end
        tw(f, .22, {Position = UDim2.new(1,320,f.Position.Y.Scale,f.Position.Y.Offset)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(.25, function() sg2:Destroy(); restack() end)
    end

    tw(prog, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,0,2)})
    task.delay(dur, dismiss)
    local gb = mkBtn({Parent=f}); gb.ZIndex=10
    gb.MouseButton1Click:Connect(dismiss)
end

--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- DRAG  (shared, moves outer container)
--━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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

-- ═══════════════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ═══════════════════════════════════════════════════════════════════════
local function buildKeyUI(onValid)
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixKeySystem"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = hui

    blurOn()

    local W, H = 380, 296

    local win = mkFrame(sg, {
        Size             = UDim2.new(0,W,0,H),
        Position         = UDim2.new(.5,0,1.8,0),
        AnchorPoint      = Vector2.new(.5,.5),
        BackgroundColor3 = C.WIN,
    })
    mkCorner(win, UDim.new(0,10)); mkStroke(win, C.STROKE_WIN, 1)

    -- header
    local hdr = mkFrame(win, {
        Size = UDim2.new(1,0,0,50), BackgroundColor3 = C.TAB,
    })
    mkCorner(hdr, UDim.new(0,10))
    mkFrame(hdr, { Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10),
        BackgroundColor3=C.TAB })
    mkFrame(win, { Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,50),
        BackgroundColor3=C.STROKE_IN })

    local keyLogo = Instance.new("ImageLabel", hdr)
    keyLogo.Size=UDim2.new(0,26,0,26); keyLogo.BackgroundTransparency=1
    keyLogo.Image=CFG.Logo; keyLogo.ImageColor3=C.WHITE
    keyLogo.ScaleType=Enum.ScaleType.Fit
    keyLogo.Position=UDim2.new(0,13,0.5,0); keyLogo.AnchorPoint=Vector2.new(0,.5)

    mkLabel({
        Parent=hdr, Text=CFG.Title,
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,47,0,0),
        TextSize=19, Font=Enum.Font.GothamBold, TextColor3=C.WHITE,
    })

    local xBtn = mkBtn({
        Parent=hdr,
        Size=UDim2.new(0,26,0,26), Position=UDim2.new(1,-12,0.5,0),
        AnchorPoint=Vector2.new(1,.5), BackgroundColor3=C.HOVER,
        BackgroundTransparency=0,
    })
    mkCorner(xBtn, UDim.new(0,5))
    mkLabel({
        Parent=xBtn, Text="✕", Size=UDim2.new(1,0,1,0),
        Font=Enum.Font.GothamBold, TextSize=13, TextColor3=C.TEXT,
        TextXAlignment=Enum.TextXAlignment.Center,
    })
    xBtn.MouseEnter:Connect(function() tw(xBtn,.12,{BackgroundColor3=C.EL}) end)
    xBtn.MouseLeave:Connect(function() tw(xBtn,.12,{BackgroundColor3=C.HOVER}) end)

    -- status
    local sBg = mkFrame(win, {
        Size=UDim2.new(0,W-28,0,52), Position=UDim2.new(0,14,0,62),
        BackgroundColor3=C.EL,
    })
    mkCorner(sBg); mkStroke(sBg, C.STROKE_EL, .7)
    local sLbl = mkLabel({
        Parent=sBg, Text=CFG.Subtitle,
        Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
        TextSize=13, Font=Enum.Font.GothamMedium,
        TextColor3=C.TEXT_DIM, TextWrapped=true,
    })

    -- input
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

    mkFrame(win, { Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,0,180),
        BackgroundColor3=C.STROKE_IN })

    local function mkKeyBtn(lbl, y, primary)
        local b = mkBtn({
            Parent=win,
            Size=UDim2.new(0,W-56,0,38), Position=UDim2.new(.5,0,0,y),
            AnchorPoint=Vector2.new(.5,0),
            BackgroundColor3 = primary and C.TEXT or C.EL,
            BackgroundTransparency = 0,
        })
        mkCorner(b)
        mkLabel({
            Parent=b, Text=lbl,
            Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamBold, TextSize=13,
            TextColor3 = primary and C.BLACK or C.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Center,
        })
        mkStroke(b, primary and C.TEXT_DIM or C.STROKE_EL, .8)
        if primary then
            b.MouseEnter:Connect(function()  tw(b,.12,{BackgroundColor3=Color3.fromRGB(220,220,220)}) end)
            b.MouseLeave:Connect(function()  tw(b,.12,{BackgroundColor3=C.TEXT}) end)
        else
            b.MouseEnter:Connect(function()  tw(b,.12,{BackgroundColor3=C.HOVER}) end)
            b.MouseLeave:Connect(function()  tw(b,.12,{BackgroundColor3=C.EL}) end)
        end
        return b
    end

    local redeemBtn = mkKeyBtn("Redeem Key", 192, true)
    local getKeyBtn = mkKeyBtn("Get Key",    238, false)

    local dcBtn = mkBtn({
        Parent=win,
        Size=UDim2.new(0,64,0,22), Position=UDim2.new(.5,0,1,-10),
        AnchorPoint=Vector2.new(.5,1), BackgroundColor3=C.EL,
        BackgroundTransparency=0,
    })
    mkCorner(dcBtn, UDim.new(0,4)); mkStroke(dcBtn, C.STROKE_EL, .5)
    mkLabel({
        Parent=dcBtn, Text="Discord",
        Size=UDim2.new(1,0,1,0), Font=Enum.Font.GothamMedium, TextSize=10,
        TextColor3=C.TEXT_GREY, TextXAlignment=Enum.TextXAlignment.Center,
    })
    dcBtn.MouseEnter:Connect(function()  tw(dcBtn,.12,{BackgroundColor3=C.HOVER}) end)
    dcBtn.MouseLeave:Connect(function()  tw(dcBtn,.12,{BackgroundColor3=C.EL}) end)

    -- status helper
    local _dt
    local function setStatus(state, msg)
        if _dt then task.cancel(_dt); _dt = nil end
        local col = C.TEXT_DIM
        if state == "ok"   then col = Color3.fromRGB(180,180,180); sLbl.Text = msg or "Access granted!"
        elseif state == "err"  then col = C.TEXT_GREY; sLbl.Text = msg or "Invalid key"
        elseif state == "busy" then
            col = C.TEXT
            _dt = task.spawn(function()
                local d = {".","..","..."}; local i = 1
                while sLbl and sLbl.Parent do
                    sLbl.Text = (msg or "Verifying") .. d[i]; i = (i%3)+1; task.wait(.4)
                end
            end)
        else sLbl.Text = msg or CFG.Subtitle end
        tw(sLbl, .15, {TextColor3 = col})
    end

    local function doRedeem()
        local key = tb.Text:gsub("%s+","")
        if key == "" then
            setStatus("err","Please enter a key first")
            notify("Error","No key entered",3); return
        end
        setStatus("busy","Verifying"); redeemBtn.Active = false; task.wait(.28)

        local valid, errMsg = false, "Invalid key"
        if CB.OnVerify then
            local ok, res = pcall(CB.OnVerify, key)
            if ok then
                if type(res) == "table" then
                    valid = res.valid == true
                    local map = {
                        KEY_INVALID="Key not found", KEY_EXPIRED="Key has expired",
                        HWID_BANNED="Hardware banned", KEY_INVALIDATED="Key revoked",
                        ALREADY_USED="One-time key used", HWID_MISMATCH="Device limit reached",
                    }
                    errMsg = map[res.error or ""] or res.message or res.error or "Invalid key"
                else valid = res == true end
            else errMsg = "Verify error" end
        else valid = true end   -- no validator = demo mode

        redeemBtn.Active = true

        if valid then
            fsSave(key); getgenv().SCRIPT_KEY = key
            setStatus("ok","Access granted!")
            notify("Success","Welcome to Zyrix!",3)
            task.wait(.8)
            tw(win, .38, {Position=UDim2.new(.5,0,-0.7,0)},
                Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.delay(.4, function()
                blurOff(); sg:Destroy()
                if onValid then onValid() end
                if CB.OnSuccess then CB.OnSuccess() end
            end)
        else
            setStatus("err", errMsg)
            notify("Rejected", errMsg, 4)
            if CB.OnFail then CB.OnFail(errMsg) end
            local ox = win.Position.X.Offset
            for _, dx in ipairs({-9,9,-6,6,-3,0}) do
                tw(win, TweenInfo.new(.05,Enum.EasingStyle.Linear),
                    {Position=UDim2.new(.5,ox+dx,win.Position.Y.Scale,win.Position.Y.Offset)})
                task.wait(.055)
            end
        end
    end

    redeemBtn.MouseButton1Click:Connect(function() task.spawn(doRedeem) end)
    tb.FocusLost:Connect(function(enter) if enter then task.spawn(doRedeem) end end)
    getKeyBtn.MouseButton1Click:Connect(function()
        if CFG.GetKeyLink ~= "" then
            pcall(function() setclipboard(CFG.GetKeyLink) end)
            notify("Get Key","Link copied!",3)
        else notify("Get Key","No link configured",3) end
    end)
    dcBtn.MouseButton1Click:Connect(function()
        if CFG.DiscordLink ~= "" then
            pcall(function() setclipboard(CFG.DiscordLink) end)
            notify("Discord","Invite copied!",3)
        else notify("Discord","No link configured",3) end
    end)
    xBtn.MouseButton1Click:Connect(function()
        tw(win, .32, {Position=UDim2.new(.5,0,-0.7,0)},
            Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.delay(.34, function()
            blurOff(); sg:Destroy()
            if CB.OnClose then CB.OnClose() end
        end)
    end)

    makeDrag(hdr, win)
    tw(win, .46, {Position=UDim2.new(.5,0,.5,0)})
end

-- ═══════════════════════════════════════════════════════════════════════
-- MAIN UI
-- ═══════════════════════════════════════════════════════════════════════
local function buildMainUI()
    pcall(function()
        local o = hui:FindFirstChild("ZyrixMainUI"); if o then o:Destroy() end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixMainUI"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = hui

    -- ── Layout constants (from reference) ──────────────────────────────
    local WIN_W  = 563
    local WIN_H  = 354
    local TAB_H  = 42
    local GAP    = 8
    local TOTAL_H = TAB_H + GAP + WIN_H

    -- ── Outer container  (tab-bar + main panel, same as reference) ─────
    -- Positioned top-left as in reference (draggable)
    local outer = mkFrame(sg, {
        Name             = "ZyrixOuter",
        Size             = UDim2.new(0, WIN_W, 0, TAB_H),   -- collapsed initially
        Position         = UDim2.new(0, 20, 0, 20),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(outer, UDim.new(0,8)); mkStroke(outer, C.STROKE_WIN, 1)
    mkGradient(outer, C.BLACK, C.TAB)

    -- ══════════════════════════════════════════════════════════════════
    -- TAB BAR  (exact replica of reference design)
    -- ══════════════════════════════════════════════════════════════════
    local tabFrame = mkFrame(outer, {
        Name             = "TabFrame",
        BackgroundColor3 = C.TAB,
        Size             = UDim2.new(1,0,0,TAB_H),
        Position         = UDim2.new(0,0,0,0),
    })
    mkCorner(tabFrame, UDim.new(0,8))
    mkGradient(tabFrame, C.BLACK, C.TAB)

    -- Z-logo button (left side of tab bar)
    local logoBtn = mkBtn({
        Parent           = tabFrame,
        Size             = UDim2.new(0,36,0,36),
        Position         = UDim2.new(0,4,0.5,-18),
        BackgroundColor3 = C.TEXT,
        BackgroundTransparency = 0,
    })
    mkCorner(logoBtn, UDim.new(0,6))

    local logoImg = Instance.new("ImageLabel", logoBtn)
    logoImg.Size                = UDim2.new(0,22,0,22)
    logoImg.Position            = UDim2.new(0.5,0,0.5,0)
    logoImg.AnchorPoint         = Vector2.new(.5,.5)
    logoImg.BackgroundTransparency = 1
    logoImg.Image               = CFG.Logo
    logoImg.ImageColor3         = C.WIN
    logoImg.ScaleType           = Enum.ScaleType.Fit
    logoImg.ZIndex              = logoBtn.ZIndex + 1

    -- Tab scrolling frame (right of logo)
    local tabSF = mkScrollFrame(tabFrame, {
        Name                  = "tablist",
        Size                  = UDim2.new(1,-46,1,0),
        Position              = UDim2.new(0,42,0,0),
        ScrollBarThickness    = 0,
        ScrollingDirection    = Enum.ScrollingDirection.X,
        AutomaticCanvasSize   = Enum.AutomaticSize.X,
        CanvasSize            = UDim2.new(0,0,0,0),
        VerticalScrollBarInset = Enum.ScrollBarInset.Always,
    })

    local tabListLayout = mkListLayout(tabSF, {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding             = UDim.new(0,4),
    })
    mkPad(tabSF, 3, 3, 3, 3)

    -- Tab definitions
    local TABS = {
        {Name="Combat",   Icon="⚔"},
        {Name="Visual",   Icon="👁"},
        {Name="Misc",     Icon="⚙"},
        {Name="Settings", Icon="🔧"},
        {Name="Player",   Icon="🧑"},
    }

    local tabBtns  = {}   -- name → btn
    local tabPages = {}   -- name → scrollingFrame inside mainFrame

    -- ══════════════════════════════════════════════════════════════════
    -- MAIN PANEL  (appears below tab bar with GAP)
    -- ══════════════════════════════════════════════════════════════════
    local mainFrame = mkFrame(outer, {
        Name             = "main",
        Size             = UDim2.new(0,WIN_W,0,0),   -- collapsed
        Position         = UDim2.new(0,0,0,TAB_H+GAP),
        BackgroundColor3 = C.WIN,
        ClipsDescendants = true,
    })
    mkCorner(mainFrame, UDim.new(0,8))
    mkGradient(mainFrame, C.BLACK, C.WIN)

    -- Main frame header
    local hdr = mkFrame(mainFrame, {
        Name             = "Header",
        Size             = UDim2.new(1,0,0,36),
        BackgroundColor3 = C.TAB,
    })
    mkCorner(hdr, UDim.new(0,6))
    -- patch bottom of rounded header
    mkFrame(hdr, {
        Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,1,-6),
        BackgroundColor3=C.TAB,
    })

    mkLabel({
        Parent=hdr, Text=CFG.Title,
        Size=UDim2.new(1,-80,1,0), Position=UDim2.new(0,12,0,0),
        Font=Enum.Font.GothamBold, TextSize=16, TextColor3=C.WHITE,
    })

    local closeBtn = mkBtn({
        Parent=hdr,
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

    -- separator line
    mkFrame(mainFrame, {
        Name="Sep",
        Size=UDim2.new(1,-20,0,1), Position=UDim2.new(0,10,0,36),
        BackgroundColor3=C.STROKE_IN,
    })

    -- ══════════════════════════════════════════════════════════════════
    -- TAB PAGE CONTAINER  (all pages live here, one visible at a time)
    -- ══════════════════════════════════════════════════════════════════
    local pageHost = mkFrame(mainFrame, {
        Size             = UDim2.new(1,0,1,-40),
        Position         = UDim2.new(0,0,0,40),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    })

    -- ══════════════════════════════════════════════════════════════════
    -- ELEMENT BUILDERS
    -- (each returns a scroll frame for that tab that callers add to)
    -- ══════════════════════════════════════════════════════════════════

    -- Generic element wrapper  (title label + padding)
    local function elementFrame(parent, titleText)
        local f = mkFrame(parent, {
            Name             = titleText or "Element",
            Size             = UDim2.new(1,-2,0,0),
            AutomaticSize    = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.EL,
        })
        mkCorner(f, UDim.new(0,4)); mkStroke(f, C.STROKE_EL, 1)
        mkPad(f, 8, 8, 8, 8)

        mkLabel({
            Parent=f, Text=titleText or "",
            Size=UDim2.new(1,0,0,14),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT_DIM,
        })

        -- push content below the title label
        local cp = Instance.new("UIPadding", f)
        cp.Name       = "ContentPad"
        cp.PaddingTop = UDim.new(0,22)

        return f
    end

    -- TOGGLE
    local function buildToggle(parent, label, default, callback)
        local f = elementFrame(parent, label)

        local interact = mkBtn({
            Parent=f,
            Size=UDim2.new(1,-2,0,30),
            BackgroundColor3=C.INNER, BackgroundTransparency=0,
        })
        mkCorner(interact, UDim.new(0,4)); mkStroke(interact, C.STROKE_IN, 1)

        mkLabel({
            Parent=interact,
            Size=UDim2.new(1,-52,1,0), Position=UDim2.new(0,8,0,0),
            Text=label, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })

        local switchBg = mkFrame(interact, {
            Size=UDim2.new(0,40,0,20), Position=UDim2.new(1,-44,0.5,-10),
            BackgroundColor3=C.OFF,
        })
        mkCorner(switchBg, UDim.new(0,10))

        local thumb = mkFrame(switchBg, {
            Size=UDim2.new(0,18,0,18), Position=UDim2.new(0,1,0.5,-9),
            BackgroundColor3=Color3.fromRGB(178,178,178),
        })
        mkCorner(thumb, UDim.new(0,9))

        local state = default == true
        local function refresh()
            if state then
                tw(switchBg,.18,{BackgroundColor3=C.GREEN1})
                tw(thumb,.18,{Position=UDim2.new(1,-19,0.5,-9), BackgroundColor3=C.WHITE})
            else
                tw(switchBg,.18,{BackgroundColor3=C.OFF})
                tw(thumb,.18,{Position=UDim2.new(0,1,0.5,-9), BackgroundColor3=Color3.fromRGB(178,178,178)})
            end
        end
        refresh()

        interact.MouseButton1Click:Connect(function()
            state = not state; refresh()
            if callback then pcall(callback, state) end
        end)
        interact.MouseEnter:Connect(function() tw(interact,.12,{BackgroundColor3=C.HOVER}) end)
        interact.MouseLeave:Connect(function() tw(interact,.12,{BackgroundColor3=C.INNER}) end)

        return {
            Get = function() return state end,
            Set = function(v) state=v; refresh(); if callback then pcall(callback,v) end end,
        }
    end

    -- SLIDER
    local function buildSlider(parent, label, min, max, default, suffix, callback)
        local f = elementFrame(parent, label)

        local track = mkFrame(f, {
            Name="Main",
            Size=UDim2.new(1,-2,0,26), BackgroundColor3=C.INNER,
        })
        mkCorner(track, UDim.new(0,4)); mkStroke(track, C.STROKE_IN, 1)

        local fill = mkFrame(track, {
            Name="Progress",
            Size=UDim2.new(0,0,1,0), BackgroundColor3=C.PROGRESS,
        })
        mkCorner(fill, UDim.new(0,4))

        local valLbl = mkLabel({
            Parent=f,
            Size=UDim2.new(0,100,0,14), Position=UDim2.new(1,-102,0,23),
            Text="", Font=Enum.Font.GothamMedium, TextSize=12,
            TextColor3=C.TEXT_DIM, TextXAlignment=Enum.TextXAlignment.Right,
        })

        local val = default or min
        local dragging = false

        local function setVal(v, anim)
            val = math.clamp(math.round(v), min, max)
            local pct = (val - min) / math.max(1, max - min)
            if anim then
                tw(fill, .08, {Size=UDim2.new(pct,0,1,0)}, Enum.EasingStyle.Quad)
            else fill.Size = UDim2.new(pct,0,1,0) end
            valLbl.Text = tostring(val) .. (suffix or "")
            if callback then pcall(callback, val) end
        end
        setVal(val, false)

        local interact = mkBtn({Parent=track}); interact.ZIndex = 10

        interact.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging = true
                local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
                setVal(min + math.clamp((i.Position.X-abs.X)/math.max(1,sz.X),0,1)*(max-min), true)
                tw(track,.08,{Size=UDim2.new(1,-2,0,30)}, Enum.EasingStyle.Back)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch then
                local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
                setVal(min + math.clamp((i.Position.X-abs.X)/math.max(1,sz.X),0,1)*(max-min), true)
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

    -- DROPDOWN
    local function buildDropdown(parent, label, options, default, callback)
        local f = elementFrame(parent, label)
        f.ClipsDescendants = false   -- list expands outside row

        local interact = mkBtn({
            Parent=f,
            Size=UDim2.new(1,-2,0,30),
            BackgroundColor3=C.INNER, BackgroundTransparency=0,
        })
        mkCorner(interact, UDim.new(0,4)); mkStroke(interact, C.STROKE_IN, 1)

        local selLbl = mkLabel({
            Parent=interact,
            Size=UDim2.new(1,-38,1,0), Position=UDim2.new(0,8,0,0),
            Text=default or (options[1] or ""),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })

        local arrowBg = mkFrame(interact, {
            Size=UDim2.new(0,22,0,22), Position=UDim2.new(1,-26,0.5,-11),
            BackgroundColor3=C.OFF,
        })
        mkCorner(arrowBg, UDim.new(0,4))
        local arrowLbl = mkLabel({
            Parent=arrowBg, Text="▼",
            Size=UDim2.new(1,0,1,0),
            Font=Enum.Font.SourceSans, TextSize=11, TextColor3=C.TEXT_DIM,
            TextXAlignment=Enum.TextXAlignment.Center,
            TextYAlignment=Enum.TextYAlignment.Center,
        })

        -- dropdown list (positioned below interact, outside f so no clipping)
        local list = mkFrame(f, {
            Name    = "DropList",
            Size    = UDim2.new(1,-2,0,0),
            Position= UDim2.new(0,0,0,52),   -- below the interact row
            BackgroundColor3 = C.DD_BG,
            ClipsDescendants = true,
            Visible = false,
            ZIndex  = 20,
        })
        mkCorner(list, UDim.new(0,4)); mkStroke(list, C.STROKE_IN, 1)
        mkPad(list, 4, 4, 4, 4)
        mkListLayout(list, {Padding=UDim.new(0,3)})

        local current = default or (options[1] or "")
        local isOpen  = false
        local ITEM_H  = 30
        local fullH   = #options * (ITEM_H + 3) + 8

        for i, optName in ipairs(options) do
            local item = mkBtn({
                Parent=list,
                Size=UDim2.new(1,0,0,ITEM_H),
                BackgroundColor3 = (i==1) and C.EL or C.DD_ROW,
                BackgroundTransparency = 0,
            })
            mkCorner(item, UDim.new(0,4))
            mkLabel({
                Parent=item, Text=optName,
                Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
                Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
            })
            item.MouseEnter:Connect(function() tw(item,.12,{BackgroundColor3=C.HOVER}) end)
            item.MouseLeave:Connect(function()
                tw(item,.12,{BackgroundColor3=(i==1 and current==optName) and C.EL or C.DD_ROW})
            end)
            item.MouseButton1Click:Connect(function()
                current    = optName
                selLbl.Text = optName
                isOpen = false
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},
                    Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible = false end)
                if callback then pcall(callback, optName) end
            end)
        end

        local function toggleDD()
            isOpen = not isOpen
            if isOpen then
                list.Visible = true
                list.Size    = UDim2.new(1,-2,0,0)
                tw(arrowBg,.15,{Rotation=180})
                tw(list,.20,{Size=UDim2.new(1,-2,0,fullH)})
            else
                tw(arrowBg,.15,{Rotation=0})
                tw(list,.16,{Size=UDim2.new(1,-2,0,0)},
                    Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                task.delay(.17, function() list.Visible = false end)
            end
        end

        interact.MouseButton1Click:Connect(toggleDD)
        arrowBg.MouseButton1Click:Connect(function() end)  -- propagate to interact
        interact.MouseEnter:Connect(function() tw(interact,.12,{BackgroundColor3=C.HOVER}) end)
        interact.MouseLeave:Connect(function() tw(interact,.12,{BackgroundColor3=C.INNER}) end)

        return {
            Get = function() return current end,
            Set = function(v) current=v; selLbl.Text=v end,
        }
    end

    -- KEYBIND
    local function buildKeybind(parent, label, default, callback)
        local f = elementFrame(parent, label)

        local row = mkFrame(f, {
            Size=UDim2.new(1,-2,0,30), BackgroundColor3=C.INNER,
        })
        mkCorner(row, UDim.new(0,4)); mkStroke(row, C.STROKE_IN, 1)

        mkLabel({
            Parent=row,
            Size=UDim2.new(1,-86,1,0), Position=UDim2.new(0,8,0,0),
            Text=label, Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT_DIM,
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
                capturing = false; tw(keyBox,.12,{BackgroundColor3=C.EL})
                return
            end
            if i.KeyCode == curKey and callback then pcall(callback, true) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.KeyCode == curKey and callback then pcall(callback, false) end
        end)

        row.MouseEnter:Connect(function() tw(row,.12,{BackgroundColor3=C.HOVER}) end)
        row.MouseLeave:Connect(function() tw(row,.12,{BackgroundColor3=C.INNER}) end)
    end

    -- BUTTON
    local function buildButton(parent, label, callback)
        local f = elementFrame(parent, label)

        local interact = mkBtn({
            Parent=f,
            Size=UDim2.new(1,-2,0,32),
            BackgroundColor3=C.EL, BackgroundTransparency=0,
        })
        mkCorner(interact, UDim.new(0,4)); mkStroke(interact, C.STROKE_IN, 1)

        mkLabel({
            Parent=interact, Text="★",
            Size=UDim2.new(0,32,0,20), Position=UDim2.new(0,8,0.5,-10),
            Font=Enum.Font.SourceSans, TextSize=16, TextColor3=C.TEXT_GREY,
            TextXAlignment=Enum.TextXAlignment.Center,
        })
        local btnLbl = mkLabel({
            Parent=interact, Text=label,
            Size=UDim2.new(1,-50,1,0), Position=UDim2.new(0,42,0,0),
            Font=Enum.Font.GothamMedium, TextSize=13, TextColor3=C.TEXT,
        })

        interact.MouseButton1Click:Connect(function()
            tw(interact,.10,{BackgroundColor3=Color3.fromRGB(150,150,150)})
            task.delay(.15, function() tw(interact,.20,{BackgroundColor3=C.EL}) end)
            if callback then pcall(callback) end
        end)
        interact.MouseButton1Down:Connect(function()
            tw(interact,.06,{Size=UDim2.new(1,-2,0,30)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        end)
        interact.MouseButton1Up:Connect(function()
            tw(interact,.20,{Size=UDim2.new(1,-2,0,32)}, Enum.EasingStyle.Back)
        end)
        interact.MouseEnter:Connect(function() tw(interact,.12,{BackgroundColor3=C.HOVER}) end)
        interact.MouseLeave:Connect(function() tw(interact,.12,{BackgroundColor3=C.EL}) end)
    end

    -- SECTION LABEL
    local function buildSection(parent, label)
        local f = mkFrame(parent, {
            Size=UDim2.new(1,-2,0,24), BackgroundTransparency=1,
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

    -- ══════════════════════════════════════════════════════════════════
    -- CREATE TAB PAGES
    -- ══════════════════════════════════════════════════════════════════
    local function newTabPage(name)
        local page = mkFrame(pageHost, {
            Name=name.."Page",
            Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
            Visible=false,
        })
        local scroll = mkScrollFrame(page, {
            Name="Scroll",
            Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=2,
        })
        mkListLayout(scroll, {Padding=UDim.new(0,6)})
        mkPad(scroll, 6, 6, 6, 6)
        tabPages[name] = {page=page, scroll=scroll}
        return scroll
    end

    local combatSc   = newTabPage("Combat")
    local visualSc   = newTabPage("Visual")
    local miscSc     = newTabPage("Misc")
    local settingsSc = newTabPage("Settings")
    local playerSc   = newTabPage("Player")

    -- ── Combat ──────────────────────────────────────────────────────
    buildSection(combatSc, "Aimbot")
    buildToggle  (combatSc, "Enable Aimbot",  false, nil)
    buildSlider  (combatSc, "FOV",            10, 360, 90,  "°",  nil)
    buildSlider  (combatSc, "Smoothness",     1,  100, 20,  "%",  nil)
    buildDropdown(combatSc, "Aim Part",
        {"Head","Neck","Torso","HumanoidRootPart"}, "Head", nil)
    buildKeybind (combatSc, "Hold to Aim",    Enum.KeyCode.Q, nil)
    buildSection (combatSc, "Silent Aim")
    buildToggle  (combatSc, "Silent Aim",     false, nil)
    buildSlider  (combatSc, "Hit Chance",     0, 100, 75, "%", nil)
    buildSection (combatSc, "Actions")
    buildButton  (combatSc, "Reset Aimbot",   function()
        notify("Combat","Aimbot reset!",2) end)

    -- ── Visual ──────────────────────────────────────────────────────
    buildSection (visualSc, "ESP")
    buildToggle  (visualSc, "Enable ESP",      false, nil)
    buildSlider  (visualSc, "Range",           50, 2000, 500, " st", nil)
    buildToggle  (visualSc, "Show Names",      true,  nil)
    buildToggle  (visualSc, "Show Distance",   false, nil)
    buildToggle  (visualSc, "Show Health",     true,  nil)
    buildDropdown(visualSc, "Box Type",
        {"2D Box","3D Box","Corner Box"}, "2D Box", nil)
    buildSection (visualSc, "World")
    buildToggle  (visualSc, "No Fog",          false, nil)
    buildToggle  (visualSc, "Full Bright",     false, nil)

    -- ── Misc ────────────────────────────────────────────────────────
    buildSection (miscSc, "Movement")
    buildToggle  (miscSc, "Speed Hack",        false, nil)
    buildSlider  (miscSc, "Walk Speed",        16, 150, 16, "",   nil)
    buildToggle  (miscSc, "Fly",               false, nil)
    buildSlider  (miscSc, "Fly Speed",         10, 200, 50, "",   nil)
    buildToggle  (miscSc, "Infinite Jump",     false, nil)
    buildToggle  (miscSc, "No Clip",           false, nil)
    buildSection (miscSc, "Utility")
    buildButton  (miscSc, "Copy Player ID", function()
        pcall(function() setclipboard(tostring(LP.UserId)) end)
        notify("Misc","Player ID copied!",2) end)
    buildButton  (miscSc, "Rejoin Server", function()
        pcall(function()
            local ts = cloneref(game:GetService("TeleportService"))
            ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
        end); notify("Misc","Rejoining…",2) end)

    -- ── Settings ────────────────────────────────────────────────────
    buildSection  (settingsSc, "Interface")
    buildToggle   (settingsSc, "Blur Effect", CFG.Blur,
        function(v) CFG.Blur = v end)
    buildToggle   (settingsSc, "Draggable",   CFG.Draggable,
        function(v) CFG.Draggable = v end)
    buildKeybind  (settingsSc, "Toggle UI",   CFG.ToggleKey, nil)
    buildSection  (settingsSc, "Key System")
    buildButton   (settingsSc, "Clear Saved Key", function()
        fsClear(); getgenv().SCRIPT_KEY = nil
        notify("Settings","Saved key cleared",3) end)

    -- ── Player ──────────────────────────────────────────────────────
    buildSection  (playerSc, "Info")
    buildButton   (playerSc, "Show Username", function()
        notify("Player", LP.Name, 4) end)
    buildButton   (playerSc, "Show Display Name", function()
        notify("Player", LP.DisplayName, 4) end)
    buildButton   (playerSc, "Show User ID", function()
        notify("Player", tostring(LP.UserId), 4) end)

    -- ══════════════════════════════════════════════════════════════════
    -- BUILD TAB BUTTONS  (in scroll frame after pages exist)
    -- ══════════════════════════════════════════════════════════════════
    local activeTabName = nil

    local function selectTab(name)
        if activeTabName == name then return end
        activeTabName = name
        for _, t in ipairs(TABS) do
            local btn = tabBtns[t.Name]
            if not btn then break end
            local isAct = (t.Name == name)
            local txt   = btn:FindFirstChild("Text")
            local ico   = btn:FindFirstChild("Icon")
            local str   = btn:FindFirstChildOfClass("UIStroke")
            tw(btn,  .25, {BackgroundColor3 = isAct and C.EL or C.TAB})
            if txt then tw(txt, .25, {TextColor3 = isAct and C.WHITE or C.TEXT_DIM}) end
            if ico then tw(ico, .25, {TextColor3 = isAct and C.WHITE or C.TEXT_DIM}) end
            if str then tw(str, .25, {Transparency = isAct and 0 or .6}) end
            -- show / hide page
            local td = tabPages[t.Name]
            if td then td.page.Visible = isAct end
        end
    end

    for i, t in ipairs(TABS) do
        local btn = mkBtn({
            Parent           = tabSF,
            Name             = t.Name .. "Tab",
            Size             = UDim2.new(0,78,1,-4),
            BackgroundColor3 = C.EL,
            BackgroundTransparency = 0,
        })
        btn.LayoutOrder = i
        mkCorner(btn, UDim.new(0,5))
        mkStroke(btn, C.STROKE_IN, 1)
        mkPad(btn, 4, 4, 6, 6)

        local ico = mkLabel({
            Parent=btn, Name="Icon",
            Size=UDim2.new(0,20,1,0),
            Text=t.Icon, Font=Enum.Font.SourceSans, TextSize=16,
            TextColor3=C.TEXT_DIM, TextYAlignment=Enum.TextYAlignment.Center,
        })
        local txt = mkLabel({
            Parent=btn, Name="Text",
            Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,22,0,0),
            Text=t.Name, Font=Enum.Font.GothamMedium, TextSize=12,
            TextColor3=C.TEXT_DIM,
        })

        btn.MouseEnter:Connect(function()
            if btn.Name ~= (activeTabName or "").."Tab" then
                tw(btn, .15, {BackgroundColor3=C.HOVER})
                tw(txt, .15, {TextColor3=C.TEXT})
                tw(ico, .15, {TextColor3=C.WHITE})
            end
        end)
        btn.MouseLeave:Connect(function()
            if btn.Name ~= (activeTabName or "").."Tab" then
                tw(btn, .15, {BackgroundColor3=C.EL})
                tw(txt, .15, {TextColor3=C.TEXT_DIM})
                tw(ico, .15, {TextColor3=C.TEXT_DIM})
            end
        end)
        btn.MouseButton1Click:Connect(function()
            selectTab(t.Name)
        end)

        tabBtns[t.Name] = btn
    end

    selectTab("Combat")   -- default

    -- ══════════════════════════════════════════════════════════════════
    -- OPEN / CLOSE ANIMATION  (Z-logo toggle)
    -- ══════════════════════════════════════════════════════════════════
    local panelOpen = false

    local function openPanel()
        panelOpen = true
        mainFrame.Visible = true
        mainFrame.Size    = UDim2.new(0,WIN_W,0,0)
        mainFrame.Position= UDim2.new(0,0,0,TAB_H+GAP)
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

    -- Z-logo hover / click
    logoBtn.MouseEnter:Connect(function()
        tw(logoBtn,.12,{BackgroundColor3 = panelOpen and C.WHITE or C.HOVER})
    end)
    logoBtn.MouseLeave:Connect(function()
        tw(logoBtn,.12,{BackgroundColor3 = panelOpen and C.TEXT or C.LOGO_OFF})
    end)
    logoBtn.MouseButton1Click:Connect(function()
        if panelOpen then closePanel() else openPanel() end
    end)

    -- Header close button → close panel
    closeBtn.MouseButton1Click:Connect(closePanel)

    -- Keyboard toggle
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == CFG.ToggleKey then
            if panelOpen then closePanel() else openPanel() end
        end
    end)

    -- Drag — both handles move outer
    makeDrag(tabFrame,  outer)
    makeDrag(hdr,       outer)

    -- Open immediately
    openPanel()

    return {
        Open   = openPanel,
        Close  = closePanel,
        Notify = notify,
        -- expose builders for external use:
        AddToggle    = buildToggle,
        AddSlider    = buildSlider,
        AddButton    = buildButton,
        AddDropdown  = buildDropdown,
        AddKeybind   = buildKeybind,
        AddSection   = buildSection,
        Scrolls = {
            combat   = combatSc,
            visual   = visualSc,
            misc     = miscSc,
            settings = settingsSc,
            player   = playerSc,
        },
    }
end

-- ═══════════════════════════════════════════════════════════════════════
-- LAUNCH
-- ═══════════════════════════════════════════════════════════════════════
local Zyrix = {}
Zyrix.Config    = CFG
Zyrix.Callbacks = CB
Zyrix.Notify    = notify

function Zyrix:Launch()
    local existing = getgenv().SCRIPT_KEY
    if existing and existing ~= "" then
        local ui = buildMainUI(); getgenv()._ZyrixUI = ui
        if CB.OnSuccess then CB.OnSuccess() end
        return
    end

    if CFG.AutoLoad then
        local saved = fsLoad()
        if saved and saved ~= "" then
            if CB.OnVerify then
                notify("Checking","Validating saved key…",3); task.wait(.3)
                local ok,res = pcall(CB.OnVerify, saved)
                local valid  = ok and (type(res)=="table" and res.valid or res==true)
                if valid then
                    getgenv().SCRIPT_KEY = saved
                    notify("Welcome back!","Key validated ✓",3)
                    local ui = buildMainUI(); getgenv()._ZyrixUI = ui
                    if CB.OnSuccess then CB.OnSuccess() end
                    return
                else
                    fsClear()
                    notify("Expired","Saved key is no longer valid",3); task.wait(.9)
                end
            else
                getgenv().SCRIPT_KEY = saved
                local ui = buildMainUI(); getgenv()._ZyrixUI = ui
                if CB.OnSuccess then CB.OnSuccess() end
                return
            end
        end
    end

    buildKeyUI(function()
        local ui = buildMainUI(); getgenv()._ZyrixUI = ui
    end)
end

getgenv().Zyrix = Zyrix

-- ══════════════════════════════════════════════════════════════════════
-- KEYS  ← add, remove or change keys here
-- ══════════════════════════════════════════════════════════════════════
local VALID_KEYS = {
    "ZYRIX-KEY1-ABCD",
    "ZYRIX-KEY2-EFGH",
    "ZYRIX-KEY3-IJKL",
    -- add as many as you want:
    -- "ZYRIX-KEY4-MNOP",
}

-- ── Verify: check if what the user typed is in the list above ──────
Zyrix.Callbacks.OnVerify = function(key)
    for _, v in ipairs(VALID_KEYS) do
        if key == v then return true end
    end
    return false
end

-- ── Success: runs once the key passes (or a saved key auto-loads) ──
Zyrix.Callbacks.OnSuccess = function()
    -- your cheat logic goes here, e.g.:
    -- local ui = getgenv()._ZyrixUI
    -- ui.AddToggle(ui.Scrolls.combat, "Speed Hack", false, function(v)
    --     game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v and 50 or 16
    -- end)
    print("[Zyrix] Key accepted — loading scripts...")
end

-- ── Fail: runs when a wrong key is entered ─────────────────────────
Zyrix.Callbacks.OnFail = function(msg)
    warn("[Zyrix] Key rejected:", msg)
end

-- ── Close: runs when the user closes the key window ───────────────
Zyrix.Callbacks.OnClose = function()
    print("[Zyrix] Key window closed.")
end

-- ══════════════════════════════════════════════════════════════════════
-- LAUNCH
-- ══════════════════════════════════════════════════════════════════════
Zyrix:Launch()

--[[
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HOW TO MANAGE KEYS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Add a key:
      Add a new line inside VALID_KEYS:
          "ZYRIX-NEWKEY-XXXX",

  Remove a key:
      Delete or comment out that line:
          -- "ZYRIX-KEY1-ABCD",

  Change a key:
      Just edit the string directly.

  Keys are case-sensitive.
  The user types their key into the key system box exactly as written.
  Once accepted the key is saved locally so they are not asked again.
  To force re-entry: call  fsClear()  or delete the saved file.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Z logo      → open / close main panel
  RightShift  → keyboard shortcut to show/hide
  ✕ button    → collapse panel
  Drag from tab bar or header to reposition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
]]
