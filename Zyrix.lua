--[[
  ███████╗██╗   ██╗██████╗ ██╗██╗  ██╗
  ╚══███╔╝╚██╗ ██╔╝██╔══██╗██║╚██╗██╔╝
    ███╔╝  ╚████╔╝ ██████╔╝██║ ╚███╔╝
   ███╔╝    ╚██╔╝  ██╔══██╗██║ ██╔██╗
  ███████╗   ██║   ██║  ██║██║██╔╝ ██╗
  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝
  v3 — Key System + Full UI, all-in-one
  B&W theme · Z-logo toggle · fold-out animation
]]

-- ══════════════════════════════════════════════════════════════════════════════
-- GUARD
-- ══════════════════════════════════════════════════════════════════════════════
repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end
local hui      = gethui()

if getgenv().ZyrixLoaded then
    if hui:FindFirstChild("ZyrixKeySystem") then return getgenv().Zyrix end
    if hui:FindFirstChild("ZyrixMainUI")    then return getgenv().Zyrix end
end
getgenv().ZyrixLoaded  = true
getgenv().ZyrixVisible = true

-- ══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ══════════════════════════════════════════════════════════════════════════════
local TS  = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS  = cloneref(game:GetService("RunService"))
local HS  = cloneref(game:GetService("HttpService"))
local LT  = cloneref(game:GetService("Lighting"))
local PL  = cloneref(game:GetService("Players"))
local LP  = cloneref(PL.LocalPlayer)

-- ══════════════════════════════════════════════════════════════════════════════
-- ╔══════════════════════════════════╗
-- ║  USER CONFIGURATION              ║
-- ╚══════════════════════════════════╝
-- ══════════════════════════════════════════════════════════════════════════════
local CFG = {
    Title       = "Zyrix",
    Logo        = "rbxassetid://105436073524298",
    Subtitle    = "Enter your key to continue",
    GetKeyLink  = "",        -- e.g. "https://linkvertise.com/…"
    DiscordLink = "",        -- e.g. "https://discord.gg/…"
    FileName    = "Zyrix_Key",
    Remember    = true,
    AutoLoad    = true,
    Blur        = true,
    Draggable   = true,
    ToggleKey   = Enum.KeyCode.RightShift,  -- keyboard shortcut to show/hide
}

-- Callbacks — set these BEFORE calling Zyrix:Launch()
local CB = {
    OnVerify  = nil,   -- function(key) → bool  or  {valid=bool,error="CODE"}
    OnSuccess = nil,   -- function()
    OnFail    = nil,   -- function(msg)
    OnClose   = nil,   -- function()
}

-- ══════════════════════════════════════════════════════════════════════════════
-- PALETTE
-- ══════════════════════════════════════════════════════════════════════════════
local C = {
    BG      = Color3.fromRGB(10,  10,  10),
    PANEL   = Color3.fromRGB(18,  18,  18),
    ELEM    = Color3.fromRGB(24,  24,  24),
    INPUT   = Color3.fromRGB(28,  28,  28),
    STROKE  = Color3.fromRGB(42,  42,  42),
    DIM     = Color3.fromRGB(110, 110, 110),
    MID     = Color3.fromRGB(160, 160, 160),
    WHITE   = Color3.fromRGB(255, 255, 255),
    BLACK   = Color3.fromRGB(0,   0,   0),
    SUCCESS = Color3.fromRGB(200, 200, 200),
    ERR     = Color3.fromRGB(70,  70,  70),
}

-- ══════════════════════════════════════════════════════════════════════════════
-- TINY HELPERS
-- ══════════════════════════════════════════════════════════════════════════════
local FONT_BOLD = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Bold,
    Enum.FontStyle.Normal)
local FONT_MED = Font.new(
    "rbxasset://fonts/families/GothamSSm.json",
    Enum.FontWeight.Medium,
    Enum.FontStyle.Normal)

local function tw(obj, t, goal)
    TS:Create(obj, t, goal):Play()
end
local function tq(obj, dur, goal)
    tw(obj, TweenInfo.new(dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
end
local function tqi(obj, dur, goal)
    tw(obj, TweenInfo.new(dur, Enum.EasingStyle.Quart, Enum.EasingDirection.In), goal)
end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 5)
    return c
end
local function stroke(p, th, col)
    local s = Instance.new("UIStroke", p)
    s.Thickness       = th  or 0.8
    s.Color           = col or C.STROKE
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end
local function pad(p, px, py)
    py = py or px
    local u = Instance.new("UIPadding", p)
    u.PaddingLeft   = UDim.new(0, px)
    u.PaddingRight  = UDim.new(0, px)
    u.PaddingTop    = UDim.new(0, py)
    u.PaddingBottom = UDim.new(0, py)
    return u
end
local function listLayout(p, dir, halign, valign, gap)
    local l = Instance.new("UIListLayout", p)
    l.FillDirection       = dir    or Enum.FillDirection.Vertical
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.Padding             = UDim.new(0, gap or 0)
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    return l
end

local function newFrame(parent, props)
    local f = Instance.new("Frame", parent)
    f.BorderSizePixel = 0
    for k, v in pairs(props or {}) do f[k] = v end
    return f
end
local function newLabel(parent, props)
    local l = Instance.new("TextLabel", parent)
    l.BackgroundTransparency = 1
    l.BorderSizePixel        = 0
    l.TextColor3             = C.WHITE
    l.FontFace               = FONT_MED
    l.TextSize               = 12
    l.TextXAlignment         = Enum.TextXAlignment.Left
    l.TextWrapped            = true
    for k, v in pairs(props or {}) do l[k] = v end
    return l
end
local function newBtn(parent, props)
    local b = Instance.new("TextButton", parent)
    b.BorderSizePixel    = 0
    b.AutoButtonColor    = false
    b.BackgroundColor3   = C.ELEM
    b.TextColor3         = C.WHITE
    b.FontFace           = FONT_BOLD
    b.TextSize           = 12
    for k, v in pairs(props or {}) do b[k] = v end
    return b
end
local function ghostBtn(parent)     -- invisible click-catcher
    local b = Instance.new("TextButton", parent)
    b.Size                  = UDim2.new(1,0,1,0)
    b.BackgroundTransparency = 1
    b.Text                  = ""
    b.ZIndex                = 10
    b.BorderSizePixel       = 0
    return b
end

local function hover(btn, normalBG, hoverBG, normalTxt, hoverTxt)
    btn.MouseEnter:Connect(function()
        tq(btn, .12, {BackgroundColor3 = hoverBG or C.INPUT})
        if hoverTxt  then tq(btn, .12, {TextColor3 = hoverTxt}) end
    end)
    btn.MouseLeave:Connect(function()
        tq(btn, .12, {BackgroundColor3 = normalBG or C.ELEM})
        if normalTxt then tq(btn, .12, {TextColor3 = normalTxt}) end
    end)
end

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

-- ══════════════════════════════════════════════════════════════════════════════
-- FILE SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════
local FS_OK = pcall(function()
    assert(type(writefile) == "function")
    assert(type(readfile)  == "function")
    assert(type(isfile)    == "function")
    assert(type(isfolder)  == "function")
    assert(type(makefolder)== "function")
end)

local function ensureDir()
    if not FS_OK then return end
    pcall(function() if not isfolder("Zyrix") then makefolder("Zyrix") end end)
end
local function saveKey(k)
    if not FS_OK or not CFG.Remember then return end
    ensureDir()
    pcall(function() writefile("Zyrix/"..CFG.FileName..".txt", k) end)
end
local function loadKey()
    if not FS_OK then return nil end
    local ok, v = pcall(function()
        local p = "Zyrix/"..CFG.FileName..".txt"
        return isfile(p) and readfile(p) or nil
    end)
    return ok and v ~= "" and v or nil
end
local function clearKey()
    if not FS_OK then return end
    pcall(function() delfile("Zyrix/"..CFG.FileName..".txt") end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- BLUR
-- ══════════════════════════════════════════════════════════════════════════════
local blurFx
local function enableBlur()
    if not CFG.Blur then return end
    pcall(function() if LT:FindFirstChild("ZyrixBlur") then LT.ZyrixBlur:Destroy() end end)
    blurFx = Instance.new("BlurEffect")
    blurFx.Name = "ZyrixBlur"; blurFx.Size = 0; blurFx.Parent = LT
    tq(blurFx, .4, {Size = 20})
end
local function disableBlur()
    local fx = blurFx or LT:FindFirstChild("ZyrixBlur")
    if not fx then return end
    tqi(fx, .3, {Size = 0})
    task.delay(.35, function() pcall(function() fx:Destroy() end) end)
    blurFx = nil
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ══════════════════════════════════════════════════════════════════════════════
local NOTIFS = {}
local function notify(title, msg, dur)
    dur = dur or 4
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixNotif"; sg.ResetOnSpawn = false
    sg.DisplayOrder = 99; sg.Parent = hui

    local f = newFrame(sg, {
        Size = UDim2.new(0,290,0,66),
        Position = UDim2.new(1,310,1,-12),
        AnchorPoint = Vector2.new(1,1),
        BackgroundColor3 = C.PANEL,
    })
    corner(f, UDim.new(0,6)); stroke(f, .8, C.STROKE)

    -- accent line
    newFrame(f, {
        Size = UDim2.new(0,3,1,-12),
        Position = UDim2.new(0,0,0,6),
        BackgroundColor3 = C.MID,
    }).BorderSizePixel = 0

    newLabel(f, {
        Text = title, Size = UDim2.new(1,-24,0,18),
        Position = UDim2.new(0,14,0,10),
        TextSize = 13, FontFace = FONT_BOLD, TextColor3 = C.WHITE,
    })
    newLabel(f, {
        Text = msg, Size = UDim2.new(1,-24,0,16),
        Position = UDim2.new(0,14,0,30),
        TextSize = 11, TextColor3 = C.DIM,
    })

    -- timer bar
    local bar = newFrame(f, {
        Size = UDim2.new(1,0,0,2),
        Position = UDim2.new(0,0,1,-2),
        BackgroundColor3 = C.MID,
    })
    corner(bar, UDim.new(0,2))

    local id = HS:GenerateGUID(false)
    table.insert(NOTIFS, {id=id, f=f, g=sg})

    local function restack()
        local y = 0
        for i = #NOTIFS, 1, -1 do
            local n = NOTIFS[i]
            if n and n.f and n.f.Parent then
                tq(n.f, .25, {Position = UDim2.new(1,-12,1,-12-y)})
                y = y + 78
            end
        end
    end

    tq(f, .35, {Position = UDim2.new(1,-12,1,-12)}); task.wait(.05); restack()

    local function dismiss()
        for i, n in ipairs(NOTIFS) do
            if n.id == id then table.remove(NOTIFS,i); break end
        end
        tqi(f, .25, {Position = UDim2.new(1,310,f.Position.Y.Scale,f.Position.Y.Offset)})
        task.delay(.3, function() sg:Destroy(); restack() end)
    end

    tw(bar, TweenInfo.new(dur, Enum.EasingStyle.Linear), {Size = UDim2.new(0,0,0,2)})
    task.delay(dur, dismiss)
    ghostBtn(f).MouseButton1Click:Connect(dismiss)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- DRAG
-- ══════════════════════════════════════════════════════════════════════════════
local function makeDraggable(handle, target)
    if not CFG.Draggable then return end
    local dragging, ds, do_ = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; ds = i.Position; do_ = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - ds
            target.Position = UDim2.new(
                do_.X.Scale, do_.X.Offset + d.X,
                do_.Y.Scale, do_.Y.Offset + d.Y)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════
local function buildKeyUI(onValid)
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixKeySystem"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = hui

    enableBlur()

    local W, H = 370, 280

    local win = newFrame(sg, {
        Size = UDim2.new(0,W,0,H),
        Position = UDim2.new(.5,0,1.6,0),
        AnchorPoint = Vector2.new(.5,.5),
        BackgroundColor3 = C.BG,
    })
    corner(win, UDim.new(0,8)); stroke(win, 1.2, C.STROKE)

    -- ── header ──────────────────────────────────────────────────────────────
    local hdr = newFrame(win, {
        Size = UDim2.new(1,0,0,48),
        BackgroundColor3 = C.PANEL,
    })
    corner(hdr, UDim.new(0,8))
    newFrame(hdr, {    -- square the bottom corners
        Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,1,-8),
        BackgroundColor3 = C.PANEL,
    })
    newFrame(hdr, {    -- bottom border line
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,0),
        BackgroundColor3 = C.STROKE,
    })

    local logoImg = Instance.new("ImageLabel", hdr)
    logoImg.Size = UDim2.new(0,26,0,26)
    logoImg.Position = UDim2.new(0,12,0.5,0); logoImg.AnchorPoint = Vector2.new(0,.5)
    logoImg.BackgroundTransparency = 1; logoImg.Image = CFG.Logo
    logoImg.ImageColor3 = C.WHITE; logoImg.ScaleType = Enum.ScaleType.Fit

    newLabel(hdr, {
        Text = CFG.Title, Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,46,0,0), TextSize = 20,
        FontFace = FONT_BOLD, TextColor3 = C.WHITE,
    })

    local xBtn = newBtn(hdr, {
        Size = UDim2.new(0,26,0,26),
        Position = UDim2.new(1,-10,0.5,0), AnchorPoint = Vector2.new(1,.5),
        BackgroundColor3 = C.ELEM, TextColor3 = C.DIM,
        Text = "✕", TextSize = 12,
    })
    corner(xBtn, UDim.new(0,5))
    hover(xBtn, C.ELEM, C.INPUT, C.DIM, C.WHITE)

    -- ── status ──────────────────────────────────────────────────────────────
    local statBox = newFrame(win, {
        Size = UDim2.new(.92,0,0,52),
        Position = UDim2.new(.5,0,0,58), AnchorPoint = Vector2.new(.5,0),
        BackgroundColor3 = C.ELEM,
    })
    corner(statBox); stroke(statBox, .8, C.STROKE)

    local statL = newLabel(statBox, {
        Text = CFG.Subtitle,
        Size = UDim2.new(1,-16,1,0), Position = UDim2.new(0,8,0,0),
        TextColor3 = C.DIM, TextSize = 13, TextWrapped = true,
    })

    -- ── input ───────────────────────────────────────────────────────────────
    local inpFrame = newFrame(win, {
        Size = UDim2.new(.92,0,0,42),
        Position = UDim2.new(.5,0,0,120), AnchorPoint = Vector2.new(.5,0),
        BackgroundColor3 = C.ELEM,
    })
    corner(inpFrame)
    local inpStroke = stroke(inpFrame, .8, C.STROKE)

    local tb = Instance.new("TextBox", inpFrame)
    tb.Size = UDim2.new(1,-20,1,0); tb.Position = UDim2.new(0,10,0,0)
    tb.BackgroundTransparency = 1; tb.TextColor3 = C.WHITE
    tb.PlaceholderColor3 = C.DIM; tb.PlaceholderText = "Enter your key…"
    tb.TextSize = 14; tb.FontFace = FONT_MED
    tb.ClearTextOnFocus = false; tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.Text = ""
    tb.Focused:Connect(function()  tq(inpStroke,.15,{Color=C.MID,  Transparency=0}) end)
    tb.FocusLost:Connect(function() tq(inpStroke,.15,{Color=C.STROKE,Transparency=0}) end)

    -- ── divider ──────────────────────────────────────────────────────────────
    newFrame(win, {
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,0,174),
        BackgroundColor3 = C.STROKE,
    })

    -- ── buttons ──────────────────────────────────────────────────────────────
    local function mkBtn(lbl, y, primary)
        local b = newBtn(win, {
            Size = UDim2.new(.72,0,0,38),
            Position = UDim2.new(.5,0,0,y), AnchorPoint = Vector2.new(.5,0),
            Text = lbl, TextSize = 13,
            BackgroundColor3 = primary and C.WHITE or C.ELEM,
            TextColor3       = primary and C.BLACK or C.DIM,
        })
        corner(b)
        if primary then
            stroke(b,.8,C.MID)
            hover(b, C.WHITE, Color3.fromRGB(220,220,220), C.BLACK, C.BLACK)
        else
            stroke(b,.8,C.STROKE)
            hover(b, C.ELEM, C.INPUT, C.DIM, C.WHITE)
        end
        return b
    end

    local redeemBtn = mkBtn("Redeem Key", 186, true)
    local getKeyBtn = mkBtn("Get Key",    232, false)

    -- ── small discord link ───────────────────────────────────────────────────
    local dcBtn = newBtn(win, {
        Size = UDim2.new(0,56,0,22),
        Position = UDim2.new(.5,0,1,-8), AnchorPoint = Vector2.new(.5,1),
        Text = "Discord", TextSize = 10, TextColor3 = C.DIM,
        BackgroundColor3 = C.ELEM,
    })
    corner(dcBtn, UDim.new(0,4)); stroke(dcBtn,.5,C.STROKE)
    hover(dcBtn, C.ELEM, C.INPUT, C.DIM, C.WHITE)

    -- ── status helper ────────────────────────────────────────────────────────
    local dotThread
    local function setStatus(state, msg)
        if dotThread then task.cancel(dotThread); dotThread = nil end
        local col, txt = C.DIM, msg or CFG.Subtitle
        if state == "ok"  then col = C.SUCCESS
        elseif state == "err" then col = C.ERR; col = C.MID
        elseif state == "busy" then
            col = C.WHITE; txt = msg or "Verifying"
            dotThread = task.spawn(function()
                local d = {".","..","..."}; local i = 1
                while statL and statL.Parent do
                    statL.Text = (msg or "Verifying") .. d[i]
                    i = (i % 3) + 1; task.wait(.45)
                end
            end)
        end
        if state ~= "busy" then statL.Text = txt end
        tq(statL, .18, {TextColor3 = col})
    end

    -- ── redeem ───────────────────────────────────────────────────────────────
    local function doRedeem()
        local key = tb.Text:gsub("%s+","")
        if key == "" then
            setStatus("err","Please enter a key first")
            notify("Error","No key entered",3); return
        end
        setStatus("busy")
        redeemBtn.Active = false; task.wait(.25)

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
        else
            -- no validator supplied → accept any non-empty key in demo mode
            valid = true
        end

        redeemBtn.Active = true

        if valid then
            saveKey(key)
            getgenv().SCRIPT_KEY = key
            setStatus("ok","Access granted!")
            notify("Success","Welcome to Zyrix!",3)
            task.wait(.7)
            tqi(win,.4,{Position = UDim2.new(.5,0,-0.6,0)})
            task.wait(.42); disableBlur(); sg:Destroy()
            if onValid then onValid() end
            if CB.OnSuccess then CB.OnSuccess() end
        else
            setStatus("err", errMsg)
            notify("Rejected", errMsg, 4)
            if CB.OnFail then CB.OnFail(errMsg) end
            -- shake
            local ox = win.Position.X.Offset
            for _, dx in ipairs({-8,8,-5,5,-2,0}) do
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
            notify("Get Key","Link copied to clipboard!",3)
        else notify("Get Key","No link configured",3) end
    end)
    dcBtn.MouseButton1Click:Connect(function()
        if CFG.DiscordLink ~= "" then
            pcall(function() setclipboard(CFG.DiscordLink) end)
            notify("Discord","Invite copied!",3)
        else notify("Discord","No link configured",3) end
    end)
    xBtn.MouseButton1Click:Connect(function()
        tqi(win,.35,{Position=UDim2.new(.5,0,-0.6,0)})
        task.wait(.36); disableBlur(); sg:Destroy()
        if CB.OnClose then CB.OnClose() end
    end)

    makeDraggable(hdr, win)
    tq(win,.48,{Position=UDim2.new(.5,0,.5,0)})
end

-- ══════════════════════════════════════════════════════════════════════════════
-- MAIN UI
-- ══════════════════════════════════════════════════════════════════════════════
local function buildMainUI()
    pcall(function()
        local old = hui:FindFirstChild("ZyrixMainUI")
        if old then old:Destroy() end
    end)

    -- ── ScreenGui ────────────────────────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name = "ZyrixMainUI"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = hui

    -- ══════════════════════════════════════════════════════════════════════
    -- LAYOUT CONSTANTS
    -- ══════════════════════════════════════════════════════════════════════
    local WIN_W  = 560    -- main window width
    local WIN_H  = 360    -- main window height
    local HDR_H  = 40     -- top header bar height
    local TAB_W  = 120    -- left tab-list width
    local BODY_H = WIN_H - HDR_H  -- content area height

    -- window is centered on screen
    local WIN_POS = UDim2.new(.5, -(WIN_W/2), .5, -(WIN_H/2))

    -- ── root window ──────────────────────────────────────────────────────────
    local win = newFrame(sg, {
        Size = UDim2.new(0,WIN_W,0,WIN_H),
        Position = WIN_POS,
        BackgroundColor3 = C.BG,
        ClipsDescendants = false,
    })
    corner(win, UDim.new(0,8)); stroke(win, 1, C.STROKE)
    win.Visible = false   -- revealed by animation

    -- ── header bar ───────────────────────────────────────────────────────────
    local hdr = newFrame(win, {
        Size = UDim2.new(1,0,0,HDR_H),
        BackgroundColor3 = C.PANEL,
        ZIndex = 5,
    })
    corner(hdr, UDim.new(0,8))
    newFrame(hdr, {    -- square bottom corners
        Size = UDim2.new(1,0,0,8), Position = UDim2.new(0,0,1,-8),
        BackgroundColor3 = C.PANEL, ZIndex = 5,
    })
    newFrame(hdr, {    -- bottom divider
        Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,0),
        BackgroundColor3 = C.STROKE,
    })

    -- Z-logo (toggle button)
    local zLogo = Instance.new("ImageButton", hdr)
    zLogo.Name = "ZLogo"
    zLogo.Size = UDim2.new(0,24,0,24)
    zLogo.Position = UDim2.new(0,10,0.5,0); zLogo.AnchorPoint = Vector2.new(0,.5)
    zLogo.BackgroundTransparency = 1
    zLogo.Image = CFG.Logo; zLogo.ImageColor3 = C.WHITE
    zLogo.ScaleType = Enum.ScaleType.Fit
    zLogo.ZIndex = 6
    -- subtle glow ring that pulses when tablist is open
    local zRing = Instance.new("UIStroke", zLogo)
    zRing.Thickness = 1.5; zRing.Color = C.STROKE; zRing.Transparency = 1

    newLabel(hdr, {
        Text = CFG.Title, Size = UDim2.new(0,120,1,0),
        Position = UDim2.new(0,42,0,0),
        TextSize = 16, FontFace = FONT_BOLD, TextColor3 = C.WHITE,
        ZIndex = 6,
    })

    -- right-side header buttons
    local function hdrBtn(ico, xRight)
        local b = newBtn(hdr, {
            Size = UDim2.new(0,26,0,26),
            Position = UDim2.new(1,xRight,0.5,0), AnchorPoint = Vector2.new(1,.5),
            BackgroundColor3 = C.ELEM, TextColor3 = C.DIM,
            Text = ico, TextSize = 13, ZIndex = 6,
        })
        corner(b, UDim.new(0,5))
        hover(b, C.ELEM, C.INPUT, C.DIM, C.WHITE)
        return b
    end
    local closeWinBtn = hdrBtn("✕", -8)
    local hideWinBtn  = hdrBtn("–", -38)

    -- ── body: left tab-list + right content ──────────────────────────────────
    local body = newFrame(win, {
        Size = UDim2.new(1,0,0,BODY_H),
        Position = UDim2.new(0,0,0,HDR_H),
        BackgroundColor3 = C.BG,
        ClipsDescendants = true,
    })
    corner(body, UDim.new(0,8))
    newFrame(body, {  -- square top corners
        Size = UDim2.new(1,0,0,8),
        BackgroundColor3 = C.BG,
    })

    -- LEFT: tab-list sidebar
    local sidebar = newFrame(body, {
        Size = UDim2.new(0,TAB_W,1,0),
        BackgroundColor3 = C.PANEL,
        ClipsDescendants = true,
    })
    newFrame(sidebar, {  -- right border
        Size = UDim2.new(0,1,1,0), Position = UDim2.new(1,-1,0,0),
        BackgroundColor3 = C.STROKE,
    })

    local sideScroll = Instance.new("ScrollingFrame", sidebar)
    sideScroll.Size = UDim2.new(1,0,1,0)
    sideScroll.BackgroundTransparency = 1; sideScroll.BorderSizePixel = 0
    sideScroll.ScrollBarThickness = 0; sideScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sideScroll.CanvasSize = UDim2.new(0,0,0,0)
    listLayout(sideScroll, Enum.FillDirection.Vertical,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 2)
    pad(sideScroll, 6, 6)

    -- RIGHT: content area
    local content = newFrame(body, {
        Size = UDim2.new(1,-TAB_W,1,0),
        Position = UDim2.new(0,TAB_W,0,0),
        BackgroundColor3 = C.BG,
        ClipsDescendants = true,
    })

    -- ══════════════════════════════════════════════════════════════════════
    -- TAB SYSTEM
    -- ══════════════════════════════════════════════════════════════════════
    local tabPages  = {}   -- name → {btn, page}
    local activeTab = nil

    local function selectTab(name)
        if activeTab == name then return end
        activeTab = name
        for tname, td in pairs(tabPages) do
            local on = (tname == name)
            tq(td.btn, .15, {
                BackgroundColor3 = on and C.ELEM    or C.PANEL,
                TextColor3       = on and C.WHITE   or C.DIM,
            })
            td.page.Visible = on
        end
    end

    local function addTab(name, icon, order)
        -- sidebar button
        local btn = newBtn(sideScroll, {
            Size = UDim2.new(1,-12,0,32),
            BackgroundColor3 = C.PANEL, TextColor3 = C.DIM,
            Text = (icon and (icon.."  ") or "") .. name,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order or (#tabPages + 1),
        })
        corner(btn, UDim.new(0,5))
        pad(btn, 10, 0)
        hover(btn, C.PANEL, C.ELEM, C.DIM, C.WHITE)

        -- content page
        local page = newFrame(content, {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
        })

        -- scrolling inner list
        local scroll = Instance.new("ScrollingFrame", page)
        scroll.Name = "Scroll"
        scroll.Size = UDim2.new(1,0,1,0)
        scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = C.DIM
        scroll.ScrollBarImageTransparency = .4
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.CanvasSize = UDim2.new(0,0,0,0)
        listLayout(scroll, Enum.FillDirection.Vertical,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 4)
        pad(scroll, 10, 8)

        tabPages[name] = {btn = btn, page = page, scroll = scroll}

        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        return scroll  -- caller adds elements into scroll
    end

    -- ══════════════════════════════════════════════════════════════════════
    -- ELEMENT BUILDERS  (all add to a given scroll/container)
    -- ══════════════════════════════════════════════════════════════════════

    -- section header
    local function addSection(container, title, order)
        local f = newFrame(container, {
            Size = UDim2.new(1,0,0,22),
            BackgroundTransparency = 1, LayoutOrder = order or 0,
        })
        newLabel(f, {
            Text = title:upper(), Size = UDim2.new(1,0,1,0),
            TextColor3 = C.DIM, TextSize = 9, FontFace = FONT_BOLD,
        })
        newFrame(f, {
            Size = UDim2.new(1,0,0,1), Position = UDim2.new(0,0,1,-1),
            BackgroundColor3 = C.STROKE,
        })
    end

    -- generic row frame
    local function elemRow(container, h, order)
        local f = newFrame(container, {
            Size = UDim2.new(1,0,0,h or 38),
            BackgroundColor3 = C.ELEM, LayoutOrder = order or 0,
        })
        corner(f); stroke(f, .5, C.STROKE)
        pad(f, 10, 0)
        return f
    end

    -- TOGGLE
    local function addToggle(container, name, default, callback, order)
        local f = elemRow(container, 38, order)
        newLabel(f, {
            Text = name, Size = UDim2.new(1,-54,1,0),
            TextColor3 = C.WHITE, TextSize = 12,
        })

        local track = newFrame(f, {
            Size = UDim2.new(0,40,0,20),
            Position = UDim2.new(1,0,0.5,0), AnchorPoint = Vector2.new(1,.5),
            BackgroundColor3 = C.INPUT,
        })
        corner(track, UDim.new(1,0)); stroke(track, .5, C.STROKE)

        local thumb = newFrame(track, {
            Size = UDim2.new(0,16,0,16),
            Position = UDim2.new(0,2,0.5,0), AnchorPoint = Vector2.new(0,.5),
            BackgroundColor3 = C.DIM,
        })
        corner(thumb, UDim.new(1,0))

        local state = default == true
        local function refresh(animate)
            local onP  = UDim2.new(1,-18,0.5,0)
            local offP = UDim2.new(0,2,0.5,0)
            local col  = state and C.WHITE or C.DIM
            if animate then
                tq(thumb,.18,{Position = state and onP or offP, BackgroundColor3 = col})
                tq(track,.18,{BackgroundColor3 = state and C.INPUT or C.INPUT})
            else
                thumb.Position = state and onP or offP
                thumb.BackgroundColor3 = col
            end
        end
        refresh(false)

        local g = ghostBtn(f)
        g.MouseButton1Click:Connect(function()
            state = not state; refresh(true)
            if callback then pcall(callback, state) end
        end)
        hover(f, C.ELEM, C.INPUT)

        return {
            Get = function() return state end,
            Set = function(v) state = v; refresh(true); if callback then pcall(callback,v) end end,
        }
    end

    -- SLIDER
    local function addSlider(container, name, min, max, default, suffix, callback, order)
        local f = elemRow(container, 54, order)
        f.Size = UDim2.new(1,0,0,54)

        newLabel(f, {
            Text = name, Size = UDim2.new(1,0,0,16),
            TextColor3 = C.WHITE, TextSize = 12,
            Position = UDim2.new(0,0,0,10),
        })

        local track = newFrame(f, {
            Size = UDim2.new(1,0,0,18),
            Position = UDim2.new(0,0,0,30),
            BackgroundColor3 = C.INPUT,
        })
        corner(track, UDim.new(1,0)); stroke(track,.5,C.STROKE)

        local fill = newFrame(track, {
            Size = UDim2.new(0,0,1,0), BackgroundColor3 = C.WHITE,
        })
        corner(fill, UDim.new(1,0))

        local valL = newLabel(f, {
            Text = "", Size = UDim2.new(0,60,0,14),
            Position = UDim2.new(1,-60,0,12), AnchorPoint = Vector2.new(0,0),
            TextColor3 = C.DIM, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local val = default or min
        local dragging = false

        local function setVal(v, anim)
            val = math.clamp(math.round(v), min, max)
            local pct = (val - min) / math.max(1, max - min)
            if anim then
                tq(fill,.1,{Size=UDim2.new(pct,0,1,0)})
            else fill.Size = UDim2.new(pct,0,1,0) end
            valL.Text = tostring(val) .. (suffix or "")
            if callback then pcall(callback, val) end
        end
        setVal(val, false)

        local g = ghostBtn(track); g.ZIndex = 10
        g.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        RS.RenderStepped:Connect(function()
            if not dragging then return end
            if not track or not track.Parent then dragging = false; return end
            local mp  = UIS:GetMouseLocation()
            local abs = track.AbsolutePosition; local sz = track.AbsoluteSize
            local pct = math.clamp((mp.X - abs.X) / math.max(1,sz.X), 0, 1)
            setVal(min + pct * (max - min), true)
        end)

        return { Get = function() return val end, Set = setVal }
    end

    -- BUTTON
    local function addButton(container, name, callback, order)
        local f = elemRow(container, 38, order)
        newLabel(f, {
            Text = name, Size = UDim2.new(1,-50,1,0), TextColor3 = C.WHITE, TextSize = 12,
        })
        newLabel(f, {
            Text = "CLICK", Size = UDim2.new(0,44,1,0),
            Position = UDim2.new(1,-44,0,0), AnchorPoint = Vector2.new(0,0),
            TextColor3 = C.DIM, TextSize = 9, FontFace = FONT_BOLD,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local g = ghostBtn(f)
        g.MouseButton1Click:Connect(function()
            tq(f,.07,{BackgroundColor3=C.INPUT})
            task.delay(.14, function() tq(f,.12,{BackgroundColor3=C.ELEM}) end)
            if callback then pcall(callback) end
        end)
        hover(f, C.ELEM, C.INPUT)
    end

    -- DROPDOWN
    local function addDropdown(container, name, opts, default, callback, order)
        local CLOSED_H = 38
        local ITEM_H   = 30
        local f = elemRow(container, CLOSED_H, order)
        f.ClipsDescendants = true

        newLabel(f, {
            Text = name, Size = UDim2.new(.5,0,0,CLOSED_H),
            TextColor3 = C.WHITE, TextSize = 12,
        })

        local selL = newLabel(f, {
            Text = default or (opts[1] or ""), Size = UDim2.new(.42,0,0,CLOSED_H),
            Position = UDim2.new(.5,0,0,0),
            TextColor3 = C.DIM, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local arrowL = newLabel(f, {
            Text = "▾", Size = UDim2.new(0,14,0,CLOSED_H),
            Position = UDim2.new(1,-14,0,0),
            TextColor3 = C.DIM, TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local list = newFrame(f, {
            Size = UDim2.new(1,0,0,0),
            Position = UDim2.new(0,0,0,CLOSED_H-6),
            BackgroundColor3 = C.INPUT,
            ClipsDescendants = true,
        })
        corner(list, UDim.new(0,5))
        listLayout(list, Enum.FillDirection.Vertical,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top, 2)
        pad(list, 4, 4)

        local current = default or (opts[1] or "")
        local isOpen = false
        local FULL_H = CLOSED_H + 6 + #opts * (ITEM_H + 2) + 8

        for _, opt in ipairs(opts) do
            local ib = newBtn(list, {
                Size = UDim2.new(1,0,0,ITEM_H),
                BackgroundColor3 = C.INPUT, TextColor3 = C.DIM,
                Text = opt, TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            corner(ib, UDim.new(0,4)); pad(ib,8,0)
            hover(ib, C.INPUT, C.ELEM, C.DIM, C.WHITE)
            ib.MouseButton1Click:Connect(function()
                current = opt; selL.Text = opt
                isOpen = false
                tq(arrowL,.15,{Rotation=0})
                tq(f,.22,{Size=UDim2.new(1,0,0,CLOSED_H)})
                tq(list,.18,{Size=UDim2.new(1,0,0,0)})
                if callback then pcall(callback, opt) end
            end)
        end

        local hdrG = ghostBtn(f); hdrG.Size = UDim2.new(1,0,0,CLOSED_H); hdrG.ZIndex = 8
        hdrG.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                tq(arrowL,.15,{Rotation=180})
                tq(f,.25,{Size=UDim2.new(1,0,0,FULL_H)})
                tq(list,.25,{Size=UDim2.new(1,0,0,FULL_H-CLOSED_H-6)})
            else
                tq(arrowL,.15,{Rotation=0})
                tq(f,.2,{Size=UDim2.new(1,0,0,CLOSED_H)})
                tq(list,.18,{Size=UDim2.new(1,0,0,0)})
            end
        end)
        hover(f, C.ELEM, C.INPUT)

        return {
            Get = function() return current end,
            Set = function(v) current = v; selL.Text = v end,
        }
    end

    -- KEYBIND
    local function addKeybind(container, name, default, callback, order)
        local f = elemRow(container, 38, order)
        newLabel(f, {
            Text = name, Size = UDim2.new(1,-70,1,0),
            TextColor3 = C.WHITE, TextSize = 12,
        })

        local kbox = newFrame(f, {
            Size = UDim2.new(0,50,0,22),
            Position = UDim2.new(1,0,0.5,0), AnchorPoint = Vector2.new(1,.5),
            BackgroundColor3 = C.INPUT,
        })
        corner(kbox, UDim.new(0,4)); stroke(kbox,.5,C.STROKE)

        local ktb = Instance.new("TextBox", kbox)
        ktb.Size = UDim2.new(1,0,1,0); ktb.BackgroundTransparency = 1
        ktb.TextColor3 = C.WHITE; ktb.TextSize = 10; ktb.FontFace = FONT_BOLD
        ktb.TextXAlignment = Enum.TextXAlignment.Center
        ktb.ClearTextOnFocus = false
        ktb.Text = (default and default.Name) or "None"

        local listening = false
        local curKey    = default or Enum.KeyCode.Unknown

        ktb.Focused:Connect(function()
            listening = true; ktb.Text = "…"
            tq(kbox,.12,{BackgroundColor3 = C.ELEM})
        end)
        ktb.FocusLost:Connect(function()
            listening = false; ktb.Text = curKey.Name
            tq(kbox,.12,{BackgroundColor3 = C.INPUT})
        end)
        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                curKey = i.KeyCode; ktb.Text = curKey.Name; ktb:ReleaseFocus(); return
            end
            if i.KeyCode == curKey and callback then pcall(callback, true) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.KeyCode == curKey and callback then pcall(callback, false) end
        end)

        hover(f, C.ELEM, C.INPUT)
    end

    -- COLOR PICKER (simple B&W brightness slider)
    local function addColorPicker(container, name, default, callback, order)
        local f = elemRow(container, 38, order)
        newLabel(f, {
            Text = name, Size = UDim2.new(.6,0,1,0),
            TextColor3 = C.WHITE, TextSize = 12,
        })

        local preview = newFrame(f, {
            Size = UDim2.new(0,22,0,22),
            Position = UDim2.new(1,-28,0.5,0), AnchorPoint = Vector2.new(1,.5),
            BackgroundColor3 = default or C.WHITE,
        })
        corner(preview, UDim.new(0,4)); stroke(preview,.5,C.STROKE)

        hover(f, C.ELEM, C.INPUT)

        local cur = default or C.WHITE
        local g = ghostBtn(f)
        g.MouseButton1Click:Connect(function()
            -- cycle through a few grey shades for demonstration
            local greys = {C.WHITE, C.MID, C.DIM, C.BLACK}
            local idx = 1
            for i,v in ipairs(greys) do if v == cur then idx = i; break end end
            idx = (idx % #greys) + 1
            cur = greys[idx]
            tq(preview,.2,{BackgroundColor3 = cur})
            if callback then pcall(callback, cur) end
        end)

        return {
            Get = function() return cur end,
            Set = function(v) cur = v; preview.BackgroundColor3 = v
                if callback then pcall(callback,v) end end,
        }
    end

    -- TEXT INPUT
    local function addTextInput(container, name, placeholder, callback, order)
        local f = elemRow(container, 38, order)
        newLabel(f, {
            Text = name, Size = UDim2.new(.35,0,1,0),
            TextColor3 = C.WHITE, TextSize = 12,
        })

        local box = newFrame(f, {
            Size = UDim2.new(.62,0,0,24),
            Position = UDim2.new(1,0,0.5,0), AnchorPoint = Vector2.new(1,.5),
            BackgroundColor3 = C.INPUT,
        })
        corner(box, UDim.new(0,4))
        local bs = stroke(box,.5,C.STROKE)

        local tb2 = Instance.new("TextBox", box)
        tb2.Size = UDim2.new(1,-8,1,0); tb2.Position = UDim2.new(0,4,0,0)
        tb2.BackgroundTransparency = 1; tb2.TextColor3 = C.WHITE
        tb2.PlaceholderColor3 = C.DIM; tb2.PlaceholderText = placeholder or ""
        tb2.TextSize = 11; tb2.FontFace = FONT_MED
        tb2.ClearTextOnFocus = false; tb2.Text = ""
        tb2.Focused:Connect(function()  tq(bs,.12,{Color=C.MID}) end)
        tb2.FocusLost:Connect(function(enter)
            tq(bs,.12,{Color=C.STROKE})
            if enter and callback then pcall(callback, tb2.Text) end
        end)

        hover(f, C.ELEM, C.INPUT)
        return {
            Get = function() return tb2.Text end,
            Set = function(v) tb2.Text = v end,
        }
    end

    -- ══════════════════════════════════════════════════════════════════════
    -- TABS & CONTENT
    -- ══════════════════════════════════════════════════════════════════════
    local combatScroll  = addTab("Combat",   nil, 1)
    local visualsScroll = addTab("Visuals",  nil, 2)
    local miscScroll    = addTab("Misc",     nil, 3)
    local settingsScroll= addTab("Settings", nil, 4)

    -- ── COMBAT TAB ────────────────────────────────────────────────────────
    addSection(combatScroll, "Aimbot")
    addToggle(combatScroll,  "Enable Aimbot",    false, nil, 10)
    addSlider(combatScroll,  "FOV",              10, 360, 90, "°", nil, 11)
    addSlider(combatScroll,  "Smoothness",       1, 100, 20, "%", nil, 12)
    addDropdown(combatScroll,"Aim Part", {"Head","Neck","Torso","HumanoidRootPart"}, "Head", nil, 13)
    addKeybind(combatScroll, "Hold to Aim", Enum.KeyCode.Q, nil, 14)

    addSection(combatScroll, "Silent Aim")
    addToggle(combatScroll,  "Silent Aim",       false, nil, 20)
    addSlider(combatScroll,  "Hit Chance",       0, 100, 75, "%", nil, 21)

    addSection(combatScroll, "Actions")
    addButton(combatScroll,  "Reset Aimbot",     function() notify("Combat","Aimbot reset!",2) end, 30)

    -- ── VISUALS TAB ───────────────────────────────────────────────────────
    addSection(visualsScroll, "ESP")
    addToggle(visualsScroll,  "Enable ESP",      false, nil, 10)
    addSlider(visualsScroll,  "ESP Range",       50, 2000, 500, " st", nil, 11)
    addToggle(visualsScroll,  "Show Names",      true,  nil, 12)
    addToggle(visualsScroll,  "Show Distance",   false, nil, 13)
    addToggle(visualsScroll,  "Show Health",     true,  nil, 14)
    addDropdown(visualsScroll,"Box Type", {"2D Box","3D Box","Corner Box"}, "2D Box", nil, 15)
    addColorPicker(visualsScroll,"ESP Colour",   C.WHITE, nil, 16)

    addSection(visualsScroll, "Chams")
    addToggle(visualsScroll,  "Enable Chams",    false, nil, 20)
    addColorPicker(visualsScroll,"Chams Colour", C.MID, nil, 21)

    addSection(visualsScroll, "World")
    addToggle(visualsScroll,  "No Fog",          false, nil, 30)
    addToggle(visualsScroll,  "Full Bright",     false, nil, 31)

    -- ── MISC TAB ──────────────────────────────────────────────────────────
    addSection(miscScroll, "Movement")
    addToggle(miscScroll,  "Speed Hack",         false, nil, 10)
    addSlider(miscScroll,  "Walk Speed",         16, 150, 16, "",  nil, 11)
    addToggle(miscScroll,  "Fly",                false, nil, 12)
    addSlider(miscScroll,  "Fly Speed",          10, 200, 50, "",  nil, 13)
    addToggle(miscScroll,  "Infinite Jump",      false, nil, 14)
    addToggle(miscScroll,  "No Clip",            false, nil, 15)

    addSection(miscScroll, "Player")
    addToggle(miscScroll,  "Anti-AFK",           true,  nil, 20)
    addToggle(miscScroll,  "Auto-Rejoin",        false, nil, 21)

    addSection(miscScroll, "Utility")
    addButton(miscScroll,  "Copy Player ID", function()
        pcall(function() setclipboard(tostring(LP.UserId)) end)
        notify("Misc","User ID copied!",2)
    end, 30)
    addButton(miscScroll,  "Rejoin Server", function()
        local ts = cloneref(game:GetService("TeleportService"))
        pcall(function() ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
    end, 31)

    -- ── SETTINGS TAB ──────────────────────────────────────────────────────
    addSection(settingsScroll, "Interface")
    addKeybind(settingsScroll, "Toggle UI", CFG.ToggleKey, nil, 10)
    addToggle(settingsScroll,  "Blur Background", CFG.Blur, function(v)
        CFG.Blur = v
    end, 11)
    addToggle(settingsScroll,  "Draggable Window", CFG.Draggable, function(v)
        CFG.Draggable = v
    end, 12)

    addSection(settingsScroll, "Key System")
    addButton(settingsScroll, "Clear Saved Key", function()
        clearKey(); getgenv().SCRIPT_KEY = nil
        notify("Settings","Saved key cleared",3)
    end, 20)

    addSection(settingsScroll, "Credits")
    newLabel(settingsScroll, {
        Text = "Zyrix v3  ·  Black & White Edition",
        Size = UDim2.new(1,0,0,28),
        TextColor3 = C.DIM, TextSize = 11,
        LayoutOrder = 30,
    })

    -- select first tab
    selectTab("Combat")

    -- ══════════════════════════════════════════════════════════════════════
    -- Z-LOGO TABLIST TOGGLE
    -- The TabList (sidebar) is ALWAYS visible inside the window.
    -- The Z-logo collapses/expands the entire left sidebar.
    -- ══════════════════════════════════════════════════════════════════════
    local sidebarOpen = true
    local ANIM_T = TweenInfo.new(.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local ANIM_TI= TweenInfo.new(.25,Enum.EasingStyle.Quart, Enum.EasingDirection.In)

    local function setSidebar(open, animate)
        sidebarOpen = open
        local sW    = open and TAB_W or 0
        local cX    = open and TAB_W or 0
        local cW    = open and (WIN_W - TAB_W) or WIN_W
        local info  = (animate ~= false) and (open and ANIM_T or ANIM_TI) or TweenInfo.new(0)

        tw(sidebar, info, {Size = UDim2.new(0,sW,1,0)})
        tw(content, info, {
            Size     = UDim2.new(0,cW,1,0),
            Position = UDim2.new(0,cX,0,0),
        })
        -- ring highlight when open
        tq(zRing, .2, {Transparency = open and 0.3 or 1})
        tw(zLogo, TweenInfo.new(.2), {ImageColor3 = open and C.WHITE or C.MID})
    end

    setSidebar(true, false)  -- start open without animation

    zLogo.MouseButton1Click:Connect(function()
        setSidebar(not sidebarOpen, true)
    end)
    zLogo.MouseEnter:Connect(function() tq(zLogo,.12,{ImageColor3 = C.WHITE}) end)
    zLogo.MouseLeave:Connect(function()
        if not sidebarOpen then tq(zLogo,.12,{ImageColor3 = C.MID}) end
    end)

    -- ══════════════════════════════════════════════════════════════════════
    -- WINDOW OPEN / CLOSE ANIMATION
    -- ══════════════════════════════════════════════════════════════════════
    local visible = false

    local function openUI()
        if visible then return end
        visible = true
        win.Visible = true
        win.Size    = UDim2.new(0,WIN_W,0,0)
        win.BackgroundTransparency = .6
        tq(win,.38,{
            Size = UDim2.new(0,WIN_W,0,WIN_H),
            BackgroundTransparency = 0,
        })
    end

    local function closeUI(cb)
        if not visible then return end
        visible = false
        tqi(win,.28,{
            Size = UDim2.new(0,WIN_W,0,0),
            BackgroundTransparency = .6,
        })
        task.delay(.3, function()
            win.Visible = false
            if cb then cb() end
        end)
    end

    local function toggleUI()
        if visible then closeUI() else openUI() end
    end

    -- header buttons
    hideWinBtn.MouseButton1Click:Connect(toggleUI)
    closeWinBtn.MouseButton1Click:Connect(function()
        closeUI(function()
            getgenv().ZyrixLoaded = false
            sg:Destroy()
        end)
    end)

    -- keyboard toggle
    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == CFG.ToggleKey then toggleUI() end
    end)

    -- dragging
    makeDraggable(hdr, win)

    -- open on first build
    openUI()

    return {
        Open    = openUI,
        Close   = closeUI,
        Toggle  = toggleUI,
        Notify  = notify,
        -- element builders exposed for external scripting:
        AddToggle    = addToggle,
        AddSlider    = addSlider,
        AddButton    = addButton,
        AddDropdown  = addDropdown,
        AddKeybind   = addKeybind,
        AddColor     = addColorPicker,
        AddInput     = addTextInput,
        AddSection   = addSection,
        Tabs         = tabPages,
        Scrolls      = {
            combat   = combatScroll,
            visuals  = visualsScroll,
            misc     = miscScroll,
            settings = settingsScroll,
        },
    }
end

-- ══════════════════════════════════════════════════════════════════════════════
-- LAUNCH
-- ══════════════════════════════════════════════════════════════════════════════
local ZyrixPublic = {}
ZyrixPublic.Config    = CFG
ZyrixPublic.Callbacks = CB
ZyrixPublic.Notify    = notify

function ZyrixPublic:Launch()
    -- Already have a valid cached key?
    local existing = getgenv().SCRIPT_KEY
    if existing and existing ~= "" then
        local ui = buildMainUI()
        getgenv()._ZyrixUI = ui
        if CB.OnSuccess then CB.OnSuccess() end
        return
    end

    -- Try auto-loading saved key
    if CFG.AutoLoad then
        local saved = loadKey()
        if saved and saved ~= "" then
            if CB.OnVerify then
                notify("Checking","Validating saved key…",3)
                task.wait(.3)
                local ok2, res2 = pcall(CB.OnVerify, saved)
                local valid2 = ok2 and (type(res2)=="table" and res2.valid or res2 == true)
                if valid2 then
                    getgenv().SCRIPT_KEY = saved
                    notify("Welcome back!","Key validated ✓",3)
                    local ui = buildMainUI()
                    getgenv()._ZyrixUI = ui
                    if CB.OnSuccess then CB.OnSuccess() end
                    return
                else
                    clearKey()
                    notify("Expired","Saved key is no longer valid",3)
                    task.wait(.9)
                end
            else
                -- no verifier → just trust the saved key
                getgenv().SCRIPT_KEY = saved
                local ui = buildMainUI()
                getgenv()._ZyrixUI = ui
                if CB.OnSuccess then CB.OnSuccess() end
                return
            end
        end
    end

    -- Show key system, then open main UI on success
    buildKeyUI(function()
        local ui = buildMainUI()
        getgenv()._ZyrixUI = ui
    end)
end

getgenv().Zyrix = ZyrixPublic
return ZyrixPublic
