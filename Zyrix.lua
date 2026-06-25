--[[
 ________   ________   ________   _______    ___        ___  ___   ___     
|\   __  \ |\   __  \ |\   __  \ |\  ___ \  |\  \      |\  \|\  \ |\  \    
\ \  \|\  \\ \  \|\  \\ \  \|\  \\ \   __/| \ \  \     \ \  \\\  \\ \  \   
 \ \   __  \\ \   _  _\\ \  \\\  \\ \  \_|/__\ \  \     \ \  \\\  \\ \  \  
  \ \  \ \  \\ \  \\  \|\ \  \\\  \\ \  \_|\ \\ \  \____ \ \  \\\  \\ \  \ 
   \ \__\ \__\\ \__\\ _\ \ \_____  \\ \_______\\ \_______\\ \_______\\ \__\
    \|__|\|__| \|__|\|__| \|___| \__\\|_______| \|_______| \|_______| \|__|
                                \|__|                                      
                                                                           

     Github - https://github.com/Cobruhehe/expert-octo-doodle
     Author: Cobru (Cobruhehe, .cobru)
     License: MIT
                                                                           
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

--services
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeySystem") then
    return getgenv().Zyrix
end
if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeylessSystem") then
    return getgenv().Zyrix
end
getgenv().ZyrixLoaded = true
getgenv().ZyrixClosed = false

local Zyrix = {}

--appearance
Zyrix.Appearance = {
    Title = "zyrix",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://105436073524298",
    IconSize = UDim2.new(0, 30, 0, 30)
}

--links
Zyrix.Links = {
    GetKey = "",
    Discord = ""
}

--storage
Zyrix.Storage = {
    FileName = "Zyrix_Key",
    Remember = true,
    AutoLoad = true
}

--options
Zyrix.Options = {
    Keyless = nil,
    KeylessUI = false,
    Blur = true,
    Draggable = true,
    NoGetKey = false
}

--theme
Zyrix.Theme = {
    Accent = Color3.fromRGB(255, 255, 255),
    AccentHover = Color3.fromRGB(220, 220, 220),
    Background = Color3.fromRGB(0, 0, 0),
    Header = Color3.fromRGB(15, 15, 15),
    Input = Color3.fromRGB(20, 20, 20),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 140),
    Success = Color3.fromRGB(255, 255, 255),
    Error = Color3.fromRGB(200, 200, 200),
    Warning = Color3.fromRGB(180, 180, 180),
    StatusIdle = Color3.fromRGB(120, 120, 120),
    Discord = Color3.fromRGB(160, 160, 160),
    DiscordHover = Color3.fromRGB(220, 220, 220),
    Divider = Color3.fromRGB(50, 50, 50),
    Pending = Color3.fromRGB(80, 80, 80)
}

--callbacks
Zyrix.Callbacks = {
    OnVerify = nil,
    OnSuccess = nil,
    OnFail = nil,
    OnClose = nil
}

local fireOnSuccess

Zyrix.Changelog = {}

--shop
Zyrix.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium Access",
    Subtitle = "Instant delivery â€¢ 24/7 support",
    ButtonText = "Buy",
    Link = ""
}

--internal
local Internal = {
    Junkie = nil,
    BlurEffect = nil,
    NotificationList = {},
    ValidateFunction = nil,
    IsJunkieMode = false,
    IconsLoaded = false
}

local IconBaseURL = "https://raw.githubusercontent.com/Cobruhehe/expert-octo-doodle/main/Icons/"
local IconFiles = {
    key = "lucide--key.png",
    shield = "lucide--shield-minus.png",
    check = "prime--check-square.png",
    copy = "flowbite--clipboard-outline.png",
    discord = "qlementine-icons--discord-16.png",
    alert = "mdi--alert-octagon-outline.png",
    lock = "lucide--user-lock.png",
    loading = "nonicons--loading-16.png",
    close = "material-symbols--dangerous-outline.png",
    changelog = "ant-design--sync-outlined.png",
    logo = "rrjlGmac.png",
    user = "U.png",
    clock = "Clock.png",
    cart = "Cart.png",
    nogetkey = "lucide--lock.png"
}

local FallbackIcons = {
    key = "rbxassetid://96510194465420",
    shield = "rbxassetid://89965059528921",
    check = "rbxassetid://76078495178149",
    copy = "rbxassetid://125851897718493",
    discord = "rbxassetid://83278450537116",
    alert = "rbxassetid://140438367956051",
    lock = "rbxassetid://114355063515473",
    loading = "rbxassetid://116535712789945",
    close = "rbxassetid://6022668916",
    changelog = "rbxassetid://138133190015277",
    logo = "rbxassetid://105436073524298",
    user = "rbxassetid://77400125196692",
    clock = "rbxassetid://87505349362628",
    cart = "rbxassetid://114754518183872",
    nogetkey = "rbxassetid://119765975153029"
}

local CachedIcons = {}
local FolderName = "Zyrix"
local IconsFolder = "Icons"
local DefaultLogoAsset = "rbxassetid://105436073524298"

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getScale()
    local viewport = Workspace.CurrentCamera.ViewportSize
    return math.clamp(math.min(viewport.X, viewport.Y) / 900, 0.65, 1.3)
end

local function hasFileSystem()
    local ok1 = pcall(function() return type(writefile) == "function" end)
    local ok2 = pcall(function() return type(readfile) == "function" end)
    local ok3 = pcall(function() return type(isfile) == "function" end)
    local ok4 = pcall(function() return type(makefolder) == "function" end)
    local ok5 = pcall(function() return type(isfolder) == "function" end)
    return ok1 and ok2 and ok3 and ok4 and ok5
end

local fileSystemSupported = hasFileSystem()

local function getFileName()
    return FolderName .. "/" .. Zyrix.Storage.FileName .. ".txt"
end

local function saveKey(key)
    if not fileSystemSupported or not Zyrix.Storage.Remember then return false end
    return pcall(function() writefile(getFileName(), key) end)
end

local function loadKey()
    if not fileSystemSupported then return nil end
    local ok, content = pcall(function()
        if isfile(getFileName()) then return readfile(getFileName()) end
        return nil
    end)
    if ok and content and content ~= "" then return content end
    return nil
end

local function clearKey()
    if not fileSystemSupported then return false end
    return pcall(function() delfile(getFileName()) end)
end

local function ensureFolders()
    if not fileSystemSupported then return false end
    pcall(function()
        if not isfolder(FolderName) then makefolder(FolderName) end
        if not isfolder(FolderName .. "/" .. IconsFolder) then makefolder(FolderName .. "/" .. IconsFolder) end
    end)
    return true
end

local function getIconPath(iconName)
    return FolderName .. "/" .. IconsFolder .. "/" .. IconFiles[iconName]
end

local function isIconCached(iconName)
    if not fileSystemSupported then return false end
    local success, result = pcall(function() return isfile(getIconPath(iconName)) end)
    return success and result
end

local function downloadIcon(iconName)
    if not fileSystemSupported then
        CachedIcons[iconName] = FallbackIcons[iconName]
        return false
    end
    local path = getIconPath(iconName)
    if isIconCached(iconName) then
        local success = pcall(function() CachedIcons[iconName] = getcustomasset(path) end)
        if success then return true end
    end
    local success = pcall(function()
        local response = game:HttpGet(IconBaseURL .. IconFiles[iconName])
        if #response < 100 then error("Invalid") end
        writefile(path, response)
        CachedIcons[iconName] = getcustomasset(path)
    end)
    if not success then CachedIcons[iconName] = FallbackIcons[iconName] end
    return success
end

local function getIcon(iconName)
    return CachedIcons[iconName] or FallbackIcons[iconName]
end

local function getLogoIcon()
    if Zyrix.Appearance.Icon == DefaultLogoAsset then return getIcon("logo") end
    return Zyrix.Appearance.Icon
end

local function shouldDownloadLogo()
    return Zyrix.Appearance.Icon == DefaultLogoAsset
end

local function getShopIcon()
    if Zyrix.Shop.Icon == "" then return getLogoIcon() end
    return Zyrix.Shop.Icon
end

local function isShopEnabled()
    return Zyrix.Shop.Enabled
end

local function allIconsCached()
    if not fileSystemSupported then return false end
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart", "nogetkey"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do
        if not isIconCached(name) then return false end
    end
    return true
end

local function loadAllIconsFromCache()
    ensureFolders()
    local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart", "nogetkey"}
    if shouldDownloadLogo() then table.insert(iconNames, "logo") end
    for _, name in ipairs(iconNames) do downloadIcon(name) end
    Internal.IconsLoaded = true
end

local function getExecutorName()
    local success, name = pcall(identifyexecutor)
    if success and name then return tostring(name) end
    return "Unknown"
end

local function getDeviceType()
    local touch = UserInputService.TouchEnabled
    local keyboard = UserInputService.KeyboardEnabled
    local gamepad = UserInputService.GamepadEnabled
    if gamepad and not keyboard and not touch then return "Console"
    elseif touch and not keyboard then return "Mobile"
    elseif keyboard and touch then return "PC & Touch"
    elseif keyboard then return "PC"
    else return "Unknown" end
end

local function getHWID()
    local hwid = nil
    pcall(function() if gethwid then hwid = gethwid() end end)
    if not hwid then pcall(function() if getgenv().HWID then hwid = getgenv().HWID end end) end
    if not hwid then pcall(function() if game.RobloxHWID then hwid = tostring(game.RobloxHWID) end end) end
    if not hwid then
        local player = cloneref(Players.LocalPlayer)
        hwid = HttpService:GenerateGUID(false):gsub("-", ""):sub(1, 32)
        if player then hwid = tostring(player.UserId) .. hwid:sub(1, 20) end
    end
    return hwid or "N/A"
end

local function generateHiddenDots(availableWidth, charWidth)
    charWidth = charWidth or 5
    local count = math.floor(availableWidth / charWidth)
    count = math.max(count, 8)
    return string.rep("â€¢", count)
end

local function formatTime12()
    local hour = tonumber(os.date("%H"))
    local min = os.date("%M")
    local sec = os.date("%S")
    local period = "AM"
    if hour >= 12 then period = "PM" end
    if hour > 12 then hour = hour - 12 end
    if hour == 0 then hour = 12 end
    return string.format("%d:%s:%s %s", hour, min, sec, period)
end

local function formatDate()
    return os.date("%b %d, %Y")
end

local function enableBlur()
    if not Zyrix.Options.Blur then return end
    local existing = Lighting:FindFirstChild("ZyrixKeySystemBlur")
    if existing then existing:Destroy() end
    Internal.BlurEffect = Instance.new("BlurEffect")
    Internal.BlurEffect.Name = "ZyrixKeySystemBlur"
    Internal.BlurEffect.Size = 0
    Internal.BlurEffect.Parent = Lighting
    TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = 24}):Play()
end

local function disableBlur()
    if Internal.BlurEffect and Internal.BlurEffect.Parent then
        TweenService:Create(Internal.BlurEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = 0}):Play()
        task.delay(0.3, function()
            if Internal.BlurEffect and Internal.BlurEffect.Parent then
                Internal.BlurEffect:Destroy()
                Internal.BlurEffect = nil
            end
        end)
    else
        local existing = Lighting:FindFirstChild("ZyrixKeySystemBlur")
        if existing then existing:Destroy() end
        Internal.BlurEffect = nil
    end
end

local function fullCleanup()
    getgenv().ZyrixLoaded = false
    getgenv().ZyrixClosed = true
    disableBlur()
    local gui1 = hui:FindFirstChild("ZyrixKeySystem")
    local gui2 = hui:FindFirstChild("ZyrixKeylessSystem")
    local gui3 = hui:FindFirstChild("ZyrixLoadingScreen")
    if gui1 then gui1:Destroy() end
    if gui2 then gui2:Destroy() end
    if gui3 then gui3:Destroy() end
end

local function setupDragging(header, main)
    if not Zyrix.Options.Draggable then return end
    local dragging, dragStart, startPos, dragInput
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            dragInput = input
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if dragInput == input then dragging = false dragInput = nil end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not dragInput then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif input.UserInputType == Enum.UserInputType.Touch then
            if input == dragInput then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)
end

local function validateKey(key, validateFunc)
    if not validateFunc or not key or key == "" then return false end
    local success, result = pcall(validateFunc, key)
    if not success then return false end
    if type(result) == "table" then return result.valid == true end
    if type(result) == "boolean" then return result end
    return false
end

local function CreateDoorOverlay(parentFrame, width, height)
    local overlay = Instance.new("Frame")
    overlay.Name = "DoorOverlay"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundTransparency = 1
    overlay.ClipsDescendants = true
    overlay.ZIndex = 50
    overlay.Parent = parentFrame

    local leftDoor = Instance.new("Frame")
    leftDoor.Name = "LeftDoor"
    leftDoor.Size = UDim2.new(0.5, 0, 1, 0)
    leftDoor.Position = UDim2.new(0, 0, 0, 0)
    leftDoor.BackgroundColor3 = Zyrix.Theme.Header
    leftDoor.BorderSizePixel = 0
    leftDoor.ZIndex = 51
    leftDoor.Parent = overlay

    local rightDoor = Instance.new("Frame")
    rightDoor.Name = "RightDoor"
    rightDoor.Size = UDim2.new(0.5, 0, 1, 0)
    rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
    rightDoor.BackgroundColor3 = Zyrix.Theme.Header
    rightDoor.BorderSizePixel = 0
    rightDoor.ZIndex = 51
    rightDoor.Parent = overlay

    local logoSize = math.min(width, height) * 0.28
    local logoImage = Instance.new("ImageLabel")
    logoImage.Name = "DoorLogo"
    logoImage.Size = UDim2.new(0, logoSize, 0, logoSize)
    logoImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    logoImage.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImage.BackgroundTransparency = 1
    logoImage.Image = getLogoIcon()
    logoImage.ImageColor3 = Zyrix.Theme.Text
    logoImage.ScaleType = Enum.ScaleType.Fit
    logoImage.ZIndex = 54
    logoImage.Parent = overlay

    local halfWidth = math.ceil(width / 2)

    local function openDoors(callback)
        TweenService:Create(logoImage, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {ImageTransparency = 1}):Play()
        task.wait(0.25)
        TweenService:Create(leftDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, -halfWidth, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 0)}):Play()
        task.wait(0.45)
        overlay.Visible = false
        if callback then callback() end
    end

    local function closeDoors(callback)
        overlay.Visible = true
        leftDoor.Position = UDim2.new(0, -halfWidth, 0, 0)
        rightDoor.Position = UDim2.new(1, 0, 0, 0)
        logoImage.ImageTransparency = 1
        TweenService:Create(leftDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(rightDoor, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 0)}):Play()
        task.wait(0.38)
        TweenService:Create(logoImage, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {ImageTransparency = 0}):Play()
        task.wait(0.3)
        if callback then callback() end
    end

    return {overlay = overlay, open = openDoors, close = closeDoors}
end

local function ShowLoadingScreen(onComplete)
    local completed = false
    local oldGui = hui:FindFirstChild("ZyrixLoadingScreen")
    if oldGui then oldGui:Destroy() end
    local oldBlur = Lighting:FindFirstChild("ZyrixLoadingBlur")
    if oldBlur then oldBlur:Destroy() end

    local blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "ZyrixLoadingBlur"
    blurEffect.Size = 0
    blurEffect.Parent = Lighting

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyrixLoadingScreen"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = hui

    local mobile = isMobile()

    local loadingScreen = Instance.new("Frame")
    loadingScreen.Size = UDim2.new(1, 0, 1, 0)
    loadingScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    loadingScreen.BackgroundTransparency = 1
    loadingScreen.BorderSizePixel = 0
    loadingScreen.Parent = gui

    local linesContainer = Instance.new("Frame")
    linesContainer.Size = UDim2.new(1, 0, 1, 0)
    linesContainer.BackgroundTransparency = 1
    linesContainer.Parent = loadingScreen

    local longLines = {}
    local linePositions = {0.15, 0.35, 0.65, 0.85}
    for i = 1, 4 do
        local line = Instance.new("Frame")
        line.Size = UDim2.new(0.3, 0, 0, mobile and 2 or 3)
        line.Position = UDim2.new(1.3, 0, linePositions[i], 0)
        line.BackgroundColor3 = Zyrix.Theme.Text
        line.BackgroundTransparency = 1
        line.BorderSizePixel = 0
        line.Parent = linesContainer
        Instance.new("UICorner", line).CornerRadius = UDim.new(1, 0)
        longLines[i] = line
    end

    local shipSize = mobile and 18 or 28
    local shipContainer = Instance.new("Frame")
    shipContainer.Size = UDim2.new(0, mobile and 100 or 150, 0, mobile and 30 or 50)
    shipContainer.Position = UDim2.new(0.5, 0, 0.35, 0)
    shipContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    shipContainer.BackgroundTransparency = 1
    shipContainer.Parent = loadingScreen

    local shipBody = Instance.new("Frame")
    shipBody.Size = UDim2.new(0, shipSize, 0, shipSize)
    shipBody.Position = UDim2.new(0.5, 10, 0.5, 0)
    shipBody.AnchorPoint = Vector2.new(0.5, 0.5)
    shipBody.BackgroundColor3 = Zyrix.Theme.Text
    shipBody.BackgroundTransparency = 1
    shipBody.BorderSizePixel = 0
    shipBody.Parent = shipContainer
    Instance.new("UICorner", shipBody).CornerRadius = UDim.new(1, 0)

    local pointSize = mobile and 10 or 16
    local shipPoint = Instance.new("Frame")
    shipPoint.Size = UDim2.new(0, pointSize, 0, pointSize)
    shipPoint.Position = UDim2.new(1, 2, 0.5, 0)
    shipPoint.AnchorPoint = Vector2.new(0, 0.5)
    shipPoint.BackgroundColor3 = Zyrix.Theme.Text
    shipPoint.BackgroundTransparency = 1
    shipPoint.BorderSizePixel = 0
    shipPoint.Rotation = 45
    shipPoint.Parent = shipBody
    Instance.new("UICorner", shipPoint).CornerRadius = UDim.new(0, 3)

    local trails = {}
    local trailConfigs = {
        {y = 0.20, width = mobile and 45 or 70},
        {y = 0.38, width = mobile and 60 or 95},
        {y = 0.62, width = mobile and 55 or 85},
        {y = 0.80, width = mobile and 40 or 65}
    }
    for i, config in ipairs(trailConfigs) do
        local trail = Instance.new("Frame")
        trail.Size = UDim2.new(0, config.width, 0, mobile and 2 or 3)
        trail.Position = UDim2.new(0.5, -15, config.y, 0)
        trail.AnchorPoint = Vector2.new(1, 0.5)
        trail.BackgroundColor3 = Zyrix.Theme.Text
        trail.BackgroundTransparency = 1
        trail.BorderSizePixel = 0
        trail.Parent = shipContainer
        local gradient = Instance.new("UIGradient", trail)
        gradient.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.5), NumberSequenceKeypoint.new(1, 0)})
        Instance.new("UICorner", trail).CornerRadius = UDim.new(1, 0)
        trails[i] = {frame = trail, config = config}
    end

    local phasesContainer = Instance.new("Frame")
    phasesContainer.Size = UDim2.new(0, mobile and 200 or 280, 0, mobile and 150 or 180)
    phasesContainer.Position = UDim2.new(0.5, 0, 0.62, 0)
    phasesContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    phasesContainer.BackgroundTransparency = 1
    phasesContainer.Parent = loadingScreen

    local phasesLayout = Instance.new("UIListLayout", phasesContainer)
    phasesLayout.Padding = UDim.new(0, mobile and 8 or 12)
    phasesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    phasesLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    phasesLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local phases = {}
    local phaseNames = {"Initializing", "Creating folders", "Downloading assets", "Preparing interface", "Ready"}
    local phaseTextSize = mobile and 14 or 18

    for i, name in ipairs(phaseNames) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, mobile and 22 or 28)
        row.BackgroundTransparency = 1
        row.LayoutOrder = i
        row.Parent = phasesContainer

        local indicator = Instance.new("TextLabel")
        indicator.Size = UDim2.new(0, mobile and 22 or 28, 0, mobile and 22 or 28)
        indicator.BackgroundTransparency = 1
        indicator.Text = "â—‹"
        indicator.TextColor3 = Zyrix.Theme.Pending
        indicator.TextSize = phaseTextSize
        indicator.Font = Enum.Font.ArimoBold
        indicator.TextTransparency = 1
        indicator.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, mobile and -28 or -35, 1, 0)
        label.Position = UDim2.new(0, mobile and 28 or 35, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Zyrix.Theme.Pending
        label.TextSize = phaseTextSize
        label.Font = Enum.Font.ArimoBold
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextTransparency = 1
        label.Parent = row

        phases[i] = {indicator = indicator, label = label}
    end

    local animationRunning = true
    local currentPhase = 0
    local pulseThread = nil

    local function animateLongLines()
        local speeds = {0.8, 1.0, 0.7, 0.9}
        while animationRunning do
            for i, line in ipairs(longLines) do
                task.spawn(function()
                    line.Position = UDim2.new(1.3, 0, linePositions[i], 0)
                    line.BackgroundTransparency = 0.5
                    TweenService:Create(line, TweenInfo.new(speeds[i], Enum.EasingStyle.Linear), {Position = UDim2.new(-0.4, 0, linePositions[i], 0), BackgroundTransparency = 0.9}):Play()
                end)
            end
            task.wait(0.5)
        end
    end

    local function animateTrails()
        while animationRunning do
            for _, trail in ipairs(trails) do
                local newWidth = trail.config.width + math.random(-12, 12)
                TweenService:Create(trail.frame, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {Size = UDim2.new(0, newWidth, 0, mobile and 2 or 3), BackgroundTransparency = 0.1 + math.random() * 0.3}):Play()
            end
            task.wait(0.1)
        end
    end

    local function animateShipShake()
        while animationRunning do
            local shakeAmount = mobile and 2 or 3
            TweenService:Create(shipContainer, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Position = UDim2.new(0.5, math.random(-shakeAmount, shakeAmount), 0.35, math.random(-1, 1))}):Play()
            task.wait(0.04)
        end
    end

    local function setPhase(num)
        if pulseThread then task.cancel(pulseThread) pulseThread = nil end
        for i = 1, 5 do
            local p = phases[i]
            if i < num then
                p.indicator.Text = "â—"
                TweenService:Create(p.indicator, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Success, TextTransparency = 0}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Success}):Play()
            elseif i == num then
                p.indicator.Text = "â—"
                p.indicator.TextTransparency = 0
                TweenService:Create(p.indicator, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Accent}):Play()
                TweenService:Create(p.label, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Text}):Play()
                currentPhase = num
                pulseThread = task.spawn(function()
                    while currentPhase == num do
                        TweenService:Create(p.indicator, TweenInfo.new(0.4), {TextTransparency = 0.5}):Play()
                        task.wait(0.4)
                        if currentPhase ~= num then break end
                        TweenService:Create(p.indicator, TweenInfo.new(0.4), {TextTransparency = 0}):Play()
                        task.wait(0.4)
                    end
                end)
            else
                p.indicator.Text = "â—‹"
                p.indicator.TextColor3 = Zyrix.Theme.Pending
                p.label.TextColor3 = Zyrix.Theme.Pending
            end
        end
    end

    task.spawn(function()
        TweenService:Create(blurEffect, TweenInfo.new(0.6), {Size = 24}):Play()
        TweenService:Create(loadingScreen, TweenInfo.new(0.5), {BackgroundTransparency = 0.25}):Play()
        task.wait(0.3)
        TweenService:Create(shipBody, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
        TweenService:Create(shipPoint, TweenInfo.new(0.4, Enum.EasingStyle.Back), {BackgroundTransparency = 0}):Play()
        task.spawn(animateLongLines)
        task.spawn(animateTrails)
        task.spawn(animateShipShake)
        task.wait(0.2)
        for i = 1, 5 do
            task.delay((i-1)*0.08, function()
                TweenService:Create(phases[i].indicator, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
                TweenService:Create(phases[i].label, TweenInfo.new(0.25), {TextTransparency = 0}):Play()
            end)
        end
        task.wait(0.5)
        setPhase(1)
        task.wait(0.3)
        setPhase(2) ensureFolders() task.wait(0.25)
        setPhase(3)
        local iconNames = {"key", "shield", "check", "copy", "discord", "alert", "lock", "loading", "close", "changelog", "user", "clock", "cart", "nogetkey"}
        if shouldDownloadLogo() then table.insert(iconNames, "logo") end
        for _, name in ipairs(iconNames) do downloadIcon(name) task.wait(0.06) end
        Internal.IconsLoaded = true
        setPhase(4) task.wait(0.25)
        setPhase(5) task.wait(0.5)
        animationRunning = false
        if pulseThread then task.cancel(pulseThread) end
        TweenService:Create(loadingScreen, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        TweenService:Create(shipBody, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(shipPoint, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        for _, trail in pairs(trails) do TweenService:Create(trail.frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
        for _, line in pairs(longLines) do TweenService:Create(line, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
        for i = 1, 5 do
            TweenService:Create(phases[i].indicator, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
            TweenService:Create(phases[i].label, TweenInfo.new(0.25), {TextTransparency = 1}):Play()
        end
        TweenService:Create(blurEffect, TweenInfo.new(0.3), {Size = 0}):Play()
        task.wait(0.5)
        gui:Destroy()
        blurEffect:Destroy()
        if onComplete then onComplete() end
        completed = true
    end)

    while not completed do task.wait(0.05) end
end

local function EnsureIconsReady(callback)
    if allIconsCached() then
        loadAllIconsFromCache()
        if callback then callback() end
    else
        ShowLoadingScreen(callback)
    end
end

function Zyrix:Notify(title, message, duration, iconType)
    duration = duration or 5
    iconType = iconType or "info"
    local scale = getScale()
    local width = math.clamp(320 * scale, 260, 380)
    local height = math.clamp(80 * scale, 75, 105)

    local notifGui = Instance.new("ScreenGui")
    notifGui.ResetOnSpawn = false
    notifGui.DisplayOrder = 999999
    notifGui.Parent = hui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, width, 0, height)
    frame.Position = UDim2.new(1, width + 20, 1, -15)
    frame.AnchorPoint = Vector2.new(1, 1)
    frame.BackgroundColor3 = Zyrix.Theme.Header
    frame.BorderSizePixel = 0
    frame.Parent = notifGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Zyrix.Theme.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.7

    local progressBg = Instance.new("Frame")
    progressBg.Size = UDim2.new(1, 0, 0, 2)
    progressBg.Position = UDim2.new(0, 0, 1, -2)
    progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    progressBg.BorderSizePixel = 0
    progressBg.Parent = frame

    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(1, 0, 1, 0)
    progressBar.BackgroundColor3 = Zyrix.Theme.Accent
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressBg

    local iconSize = height - 35
    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, iconSize, 0, iconSize)
    icon.Position = UDim2.new(0, 14, 0.5, -2)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = frame

    local iconMap = {
        success = {"check", Zyrix.Theme.Success}, error = {"alert", Zyrix.Theme.Error},
        warning = {"alert", Zyrix.Theme.Warning}, shield = {"shield", Zyrix.Theme.Accent},
        info = {"shield", Zyrix.Theme.Accent}, key = {"key", Zyrix.Theme.Accent},
        copy = {"copy", Zyrix.Theme.Success}, discord = {"discord", Zyrix.Theme.Discord},
        close = {"close", Zyrix.Theme.Error}, nogetkey = {"nogetkey", Zyrix.Theme.TextDim}
    }

    if iconMap[iconType] then
        icon.Image = getIcon(iconMap[iconType][1])
        icon.ImageColor3 = iconMap[iconType][2]
    else
        icon.Image = getLogoIcon()
        icon.ImageColor3 = Zyrix.Theme.Text
    end

    local textX = 14 + iconSize + 14
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -(textX + 14), 0, 24)
    titleLabel.Position = UDim2.new(0, textX, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextSize = math.clamp(15 * scale, 13, 18)
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextColor3 = Zyrix.Theme.Text
    titleLabel.Text = title
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = frame

    local messageLabel = Instance.new("TextLabel")
    messageLabel.Size = UDim2.new(1, -(textX + 14), 0, 22)
    messageLabel.Position = UDim2.new(0, textX, 0, 38)
    messageLabel.BackgroundTransparency = 1
    messageLabel.Font = Enum.Font.ArimoBold
    messageLabel.TextSize = math.clamp(13 * scale, 11, 15)
    messageLabel.TextXAlignment = Enum.TextXAlignment.Left
    messageLabel.TextColor3 = Zyrix.Theme.TextDim
    messageLabel.Text = message
    messageLabel.TextTruncate = Enum.TextTruncate.AtEnd
    messageLabel.Parent = frame

    local id = tick() .. HttpService:GenerateGUID(false)
    table.insert(Internal.NotificationList, {id = id, frame = frame, gui = notifGui, height = height})

    local function restack()
        local yOffset = 0
        for i = #Internal.NotificationList, 1, -1 do
            local n = Internal.NotificationList[i]
            if n and n.frame and n.frame.Parent then
                TweenService:Create(n.frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15 - yOffset)}):Play()
                yOffset = yOffset + n.height + 12
            end
        end
    end

    TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(1, -15, 1, -15)}):Play()
    task.wait(0.1)
    restack()

    local function dismiss()
        for i, n in ipairs(Internal.NotificationList) do
            if n.id == id then table.remove(Internal.NotificationList, i) break end
        end
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, width + 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
        task.wait(0.3)
        notifGui:Destroy()
        restack()
    end

    TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)}):Play()
    task.delay(duration, dismiss)

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame
    clickBtn.MouseButton1Click:Connect(dismiss)
end

local function CreateChangelogPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap)
    panelWidth = panelWidth or 220
    local isOpen = false

    local panel = Instance.new("Frame")
    panel.Name = "ChangelogPanel"
    panel.Size = UDim2.new(0, 0, 0, panelHeight)
    panel.Position = UDim2.new(1, gap, 0, 0)
    panel.BackgroundColor3 = Zyrix.Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Zyrix.Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Zyrix.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = Zyrix.Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = Zyrix.Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.6
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = getIcon("changelog")
    panelHeaderIcon.ImageColor3 = Zyrix.Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "Changelog"
    panelTitle.TextColor3 = Zyrix.Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = getIcon("close")
    panelClose.ImageColor3 = Zyrix.Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, 0, 1, -55)
    scrollFrame.Position = UDim2.new(0, 0, 0, 55)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Zyrix.Theme.Accent
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.Parent = panel

    local scrollPadding = Instance.new("UIPadding", scrollFrame)
    scrollPadding.PaddingLeft = UDim.new(0, 10)
    scrollPadding.PaddingRight = UDim.new(0, 10)
    scrollPadding.PaddingTop = UDim.new(0, 5)
    scrollPadding.PaddingBottom = UDim.new(0, 5)

    local contentLayout = Instance.new("UIListLayout", scrollFrame)
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder

    for i, update in ipairs(Zyrix.Changelog) do
        local entry = Instance.new("Frame")
        entry.Size = UDim2.new(1, 0, 0, 0)
        entry.AutomaticSize = Enum.AutomaticSize.Y
        entry.BackgroundTransparency = 1
        entry.LayoutOrder = i * 2
        entry.Parent = scrollFrame

        local entryLayout = Instance.new("UIListLayout", entry)
        entryLayout.Padding = UDim.new(0, 5)

        local versionLabel = Instance.new("TextLabel")
        versionLabel.Size = UDim2.new(1, 0, 0, 22)
        versionLabel.BackgroundTransparency = 1
        versionLabel.Text = update.Version .. "  â€¢  " .. update.Date
        versionLabel.TextColor3 = Zyrix.Theme.Accent
        versionLabel.TextSize = 14
        versionLabel.Font = Enum.Font.ArimoBold
        versionLabel.TextXAlignment = Enum.TextXAlignment.Left
        versionLabel.LayoutOrder = 1
        versionLabel.Parent = entry

        for j, change in ipairs(update.Changes) do
            local changeLabel = Instance.new("TextLabel")
            changeLabel.Size = UDim2.new(1, 0, 0, 0)
            changeLabel.AutomaticSize = Enum.AutomaticSize.Y
            changeLabel.BackgroundTransparency = 1
            changeLabel.Text = "  â€¢  " .. change
            changeLabel.TextColor3 = Zyrix.Theme.TextDim
            changeLabel.TextSize = 12
            changeLabel.Font = Enum.Font.ArimoBold
            changeLabel.TextXAlignment = Enum.TextXAlignment.Left
            changeLabel.TextWrapped = true
            changeLabel.LayoutOrder = j + 1
            changeLabel.Parent = entry
        end

        if i < #Zyrix.Changelog then
            local divWrapper = Instance.new("Frame")
            divWrapper.Size = UDim2.new(1, 0, 0, 2)
            divWrapper.BackgroundTransparency = 1
            divWrapper.LayoutOrder = i * 2 + 1
            divWrapper.Parent = scrollFrame

            local div = Instance.new("Frame")
            div.Size = UDim2.new(1, 0, 0, 2)
            div.BackgroundColor3 = Zyrix.Theme.Divider
            div.BorderSizePixel = 0
            div.Parent = divWrapper
        end
    end

    local function toggle(changelogIcon, container, currentContainerWidth)
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, currentContainerWidth + gap + panelWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 180}):Play() end
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, currentContainerWidth, 0, panelHeight)}):Play()
            if changelogIcon then TweenService:Create(changelogIcon, TweenInfo.new(0.3), {Rotation = 0}):Play() end
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

local function CreateUserInfoPanel(parent, windowWidth, panelHeight, panelWidth, mainFrame, gap, startOpen)
    panelWidth = panelWidth or 180
    local isOpen = startOpen or false
    local isCompact = panelHeight < 300
    local avatarSize = isCompact and 42 or 55
    local fieldHeight = isCompact and 24 or 28
    local titleSize = isCompact and 8 or 9
    local valueSize = isCompact and 10 or 11
    local welcomeSize = isCompact and 11 or 12
    local spacing = isCompact and 3 or 5

    local panel = Instance.new("Frame")
    panel.Name = "UserInfoPanel"
    panel.Size = UDim2.new(0, isOpen and panelWidth or 0, 0, panelHeight)
    panel.Position = UDim2.new(0, -(gap), 0, 0)
    panel.AnchorPoint = Vector2.new(1, 0)
    panel.BackgroundColor3 = Zyrix.Theme.Background
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.Parent = mainFrame
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 4)

    local panelStroke = Instance.new("UIStroke", panel)
    panelStroke.Color = Zyrix.Theme.Accent
    panelStroke.Thickness = 2
    panelStroke.Transparency = isOpen and 0.4 or 1

    local panelHeader = Instance.new("Frame")
    panelHeader.Size = UDim2.new(1, 0, 0, 50)
    panelHeader.BackgroundColor3 = Zyrix.Theme.Header
    panelHeader.BorderSizePixel = 0
    panelHeader.Parent = panel
    Instance.new("UICorner", panelHeader).CornerRadius = UDim.new(0, 4)

    local panelHeaderFix = Instance.new("Frame")
    panelHeaderFix.Size = UDim2.new(1, 0, 0, 8)
    panelHeaderFix.Position = UDim2.new(0, 0, 1, -8)
    panelHeaderFix.BackgroundColor3 = Zyrix.Theme.Header
    panelHeaderFix.BorderSizePixel = 0
    panelHeaderFix.Parent = panelHeader

    local panelHeaderLine = Instance.new("Frame")
    panelHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    panelHeaderLine.Position = UDim2.new(0, 0, 1, 0)
    panelHeaderLine.BackgroundColor3 = Zyrix.Theme.Accent
    panelHeaderLine.BackgroundTransparency = 0.6
    panelHeaderLine.BorderSizePixel = 0
    panelHeaderLine.Parent = panelHeader

    local panelHeaderIcon = Instance.new("ImageLabel")
    panelHeaderIcon.Size = UDim2.new(0, 16, 0, 16)
    panelHeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
    panelHeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
    panelHeaderIcon.BackgroundTransparency = 1
    panelHeaderIcon.Image = getIcon("user")
    panelHeaderIcon.ImageColor3 = Zyrix.Theme.Accent
    panelHeaderIcon.ScaleType = Enum.ScaleType.Fit
    panelHeaderIcon.Parent = panelHeader

    local panelTitle = Instance.new("TextLabel")
    panelTitle.Size = UDim2.new(1, -65, 1, 0)
    panelTitle.Position = UDim2.new(0, 34, 0, 0)
    panelTitle.BackgroundTransparency = 1
    panelTitle.Text = "User Info"
    panelTitle.TextColor3 = Zyrix.Theme.Text
    panelTitle.TextSize = 16
    panelTitle.Font = Enum.Font.ArimoBold
    panelTitle.TextXAlignment = Enum.TextXAlignment.Left
    panelTitle.Parent = panelHeader

    local panelClose = Instance.new("ImageButton")
    panelClose.Size = UDim2.new(0, 20, 0, 20)
    panelClose.Position = UDim2.new(1, -14, 0.5, 0)
    panelClose.AnchorPoint = Vector2.new(1, 0.5)
    panelClose.BackgroundTransparency = 1
    panelClose.Image = getIcon("close")
    panelClose.ImageColor3 = Zyrix.Theme.TextDim
    panelClose.ScaleType = Enum.ScaleType.Fit
    panelClose.Parent = panelHeader
    panelClose.MouseEnter:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Error}):Play() end)
    panelClose.MouseLeave:Connect(function() TweenService:Create(panelClose, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, 0, 1, -55)
    contentFrame.Position = UDim2.new(0, 0, 0, 55)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = panel

    local contentPadding = Instance.new("UIPadding", contentFrame)
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)

    local contentLayout = Instance.new("UIListLayout", contentFrame)
    contentLayout.Padding = UDim.new(0, spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    local player = cloneref(Players.LocalPlayer)

    local avatarWrapper = Instance.new("Frame")
    avatarWrapper.Size = UDim2.new(0, avatarSize + 6, 0, avatarSize + 6)
    avatarWrapper.BackgroundTransparency = 1
    avatarWrapper.LayoutOrder = 1
    avatarWrapper.Parent = contentFrame

    local avatarGlow = Instance.new("Frame")
    avatarGlow.Size = UDim2.new(1, 0, 1, 0)
    avatarGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarGlow.BackgroundColor3 = Zyrix.Theme.Accent
    avatarGlow.BackgroundTransparency = 0.5
    avatarGlow.BorderSizePixel = 0
    avatarGlow.Parent = avatarWrapper
    Instance.new("UICorner", avatarGlow).CornerRadius = UDim.new(0, 4)

    local avatarGlowStroke = Instance.new("UIStroke", avatarGlow)
    avatarGlowStroke.Color = Zyrix.Theme.Accent
    avatarGlowStroke.Thickness = 1.5
    avatarGlowStroke.Transparency = 0.3

    local avatarContainer = Instance.new("Frame")
    avatarContainer.Size = UDim2.new(0, avatarSize, 0, avatarSize)
    avatarContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarContainer.BackgroundColor3 = Zyrix.Theme.Input
    avatarContainer.BorderSizePixel = 0
    avatarContainer.ClipsDescendants = true
    avatarContainer.Parent = avatarWrapper
    Instance.new("UICorner", avatarContainer).CornerRadius = UDim.new(0, 4)

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(1, 0, 1, 0)
    avatarImage.Position = UDim2.new(0.5, 0, 0.5, 0)
    avatarImage.AnchorPoint = Vector2.new(0.5, 0.5)
    avatarImage.BackgroundTransparency = 1
    avatarImage.ScaleType = Enum.ScaleType.Crop
    avatarImage.Parent = avatarContainer
    pcall(function()
        local content = Players:GetUserThumbnailAsync(player and player.UserId or 0, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
        avatarImage.Image = content
    end)

    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(1, 0, 0, isCompact and 14 or 18)
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.Text = "Welcome, " .. (player and player.DisplayName or "User")
    welcomeLabel.TextColor3 = Zyrix.Theme.Text
    welcomeLabel.TextSize = welcomeSize
    welcomeLabel.Font = Enum.Font.ArimoBold
    welcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    welcomeLabel.LayoutOrder = 2
    welcomeLabel.Parent = contentFrame

    local divider1 = Instance.new("Frame")
    divider1.Size = UDim2.new(1, 16, 0, 2)
    divider1.Position = UDim2.new(0.5, 0, 0, 0)
    divider1.AnchorPoint = Vector2.new(0.5, 0)
    divider1.BackgroundColor3 = Zyrix.Theme.Divider
    divider1.BorderSizePixel = 0
    divider1.LayoutOrder = 3
    divider1.Parent = contentFrame

    local executorContainer = Instance.new("Frame")
    executorContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    executorContainer.BackgroundTransparency = 1
    executorContainer.LayoutOrder = 4
    executorContainer.Parent = contentFrame

    local executorTitle = Instance.new("TextLabel")
    executorTitle.Size = UDim2.new(1, 0, 0, 11)
    executorTitle.BackgroundTransparency = 1
    executorTitle.Text = "Executor"
    executorTitle.TextColor3 = Zyrix.Theme.TextDim
    executorTitle.TextSize = titleSize
    executorTitle.Font = Enum.Font.ArimoBold
    executorTitle.TextXAlignment = Enum.TextXAlignment.Left
    executorTitle.Parent = executorContainer

    local executorValue = Instance.new("TextLabel")
    executorValue.Size = UDim2.new(1, 0, 0, 14)
    executorValue.Position = UDim2.new(0, 0, 0, 11)
    executorValue.BackgroundTransparency = 1
    executorValue.Text = getExecutorName()
    executorValue.TextColor3 = Zyrix.Theme.Accent
    executorValue.TextSize = valueSize
    executorValue.Font = Enum.Font.ArimoBold
    executorValue.TextXAlignment = Enum.TextXAlignment.Left
    executorValue.TextTruncate = Enum.TextTruncate.AtEnd
    executorValue.Parent = executorContainer

    local deviceContainer = Instance.new("Frame")
    deviceContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    deviceContainer.BackgroundTransparency = 1
    deviceContainer.LayoutOrder = 5
    deviceContainer.Parent = contentFrame

    local deviceTitle = Instance.new("TextLabel")
    deviceTitle.Size = UDim2.new(1, 0, 0, 11)
    deviceTitle.BackgroundTransparency = 1
    deviceTitle.Text = "Device"
    deviceTitle.TextColor3 = Zyrix.Theme.TextDim
    deviceTitle.TextSize = titleSize
    deviceTitle.Font = Enum.Font.ArimoBold
    deviceTitle.TextXAlignment = Enum.TextXAlignment.Left
    deviceTitle.Parent = deviceContainer

    local deviceValue = Instance.new("TextLabel")
    deviceValue.Size = UDim2.new(1, 0, 0, 14)
    deviceValue.Position = UDim2.new(0, 0, 0, 11)
    deviceValue.BackgroundTransparency = 1
    deviceValue.Text = getDeviceType()
    deviceValue.TextColor3 = Zyrix.Theme.Accent
    deviceValue.TextSize = valueSize
    deviceValue.Font = Enum.Font.ArimoBold
    deviceValue.TextXAlignment = Enum.TextXAlignment.Left
    deviceValue.TextTruncate = Enum.TextTruncate.AtEnd
    deviceValue.Parent = deviceContainer

    local divider2 = Instance.new("Frame")
    divider2.Size = UDim2.new(1, 16, 0, 2)
    divider2.Position = UDim2.new(0.5, 0, 0, 0)
    divider2.AnchorPoint = Vector2.new(0.5, 0)
    divider2.BackgroundColor3 = Zyrix.Theme.Divider
    divider2.BorderSizePixel = 0
    divider2.LayoutOrder = 6
    divider2.Parent = contentFrame

    local hwidContainer = Instance.new("Frame")
    hwidContainer.Size = UDim2.new(1, 0, 0, fieldHeight)
    hwidContainer.BackgroundTransparency = 1
    hwidContainer.LayoutOrder = 7
    hwidContainer.Parent = contentFrame

    local hwidTitle = Instance.new("TextLabel")
    hwidTitle.Size = UDim2.new(1, 0, 0, 11)
    hwidTitle.BackgroundTransparency = 1
    hwidTitle.Text = "HWID"
    hwidTitle.TextColor3 = Zyrix.Theme.TextDim
    hwidTitle.TextSize = titleSize
    hwidTitle.Font = Enum.Font.ArimoBold
    hwidTitle.TextXAlignment = Enum.TextXAlignment.Left
    hwidTitle.Parent = hwidContainer

    local fullHWID = getHWID()
    local copyBtnSize = 18
    local dotAreaWidth = panelWidth - 16 - copyBtnSize - 6
    local hiddenDots = generateHiddenDots(dotAreaWidth, 5)

    local hwidValue = Instance.new("TextLabel")
    hwidValue.Size = UDim2.new(1, -(copyBtnSize + 6), 0, 14)
    hwidValue.Position = UDim2.new(0, 0, 0, 11)
    hwidValue.BackgroundTransparency = 1
    hwidValue.Text = hiddenDots
    hwidValue.TextColor3 = Zyrix.Theme.TextDim
    hwidValue.TextSize = isCompact and 9 or 10
    hwidValue.Font = Enum.Font.ArimoBold
    hwidValue.TextXAlignment = Enum.TextXAlignment.Left
    hwidValue.TextTruncate = Enum.TextTruncate.AtEnd
    hwidValue.Parent = hwidContainer

    local copyBtn = Instance.new("ImageButton")
    copyBtn.Size = UDim2.new(0, copyBtnSize, 0, copyBtnSize)
    copyBtn.Position = UDim2.new(1, 0, 0.5, 1)
    copyBtn.AnchorPoint = Vector2.new(1, 0.5)
    copyBtn.BackgroundTransparency = 1
    copyBtn.Image = getIcon("copy")
    copyBtn.ImageColor3 = Zyrix.Theme.TextDim
    copyBtn.ScaleType = Enum.ScaleType.Fit
    copyBtn.Parent = hwidContainer
    copyBtn.MouseEnter:Connect(function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Accent}):Play() end)
    copyBtn.MouseLeave:Connect(function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)
    copyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(fullHWID) end)
        TweenService:Create(copyBtn, TweenInfo.new(0.1), {ImageColor3 = Zyrix.Theme.Success}):Play()
        task.delay(0.3, function() TweenService:Create(copyBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)
        Zyrix:Notify("Copied", "HWID copied to clipboard", 2, "copy")
    end)

    local divider3 = Instance.new("Frame")
    divider3.Size = UDim2.new(1, 16, 0, 2)
    divider3.Position = UDim2.new(0.5, 0, 0, 0)
    divider3.AnchorPoint = Vector2.new(0.5, 0)
    divider3.BackgroundColor3 = Zyrix.Theme.Divider
    divider3.BorderSizePixel = 0
    divider3.LayoutOrder = 8
    divider3.Parent = contentFrame

    local clockContainer = Instance.new("Frame")
    clockContainer.Size = UDim2.new(1, 0, 0, isCompact and 30 or 38)
    clockContainer.BackgroundTransparency = 1
    clockContainer.LayoutOrder = 9
    clockContainer.Parent = contentFrame

    local clockRow = Instance.new("Frame")
    clockRow.Size = UDim2.new(1, 0, 0, isCompact and 18 or 22)
    clockRow.Position = UDim2.new(0.5, -8, 0, 0)
    clockRow.AnchorPoint = Vector2.new(0.5, 0)
    clockRow.BackgroundTransparency = 1
    clockRow.Parent = clockContainer

    local clockRowLayout = Instance.new("UIListLayout", clockRow)
    clockRowLayout.FillDirection = Enum.FillDirection.Horizontal
    clockRowLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    clockRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    clockRowLayout.Padding = UDim.new(0, isCompact and 4 or 6)

    local clockIcon = Instance.new("ImageLabel")
    clockIcon.Size = UDim2.new(0, isCompact and 14 or 16, 0, isCompact and 14 or 16)
    clockIcon.BackgroundTransparency = 1
    clockIcon.Image = getIcon("clock")
    clockIcon.ImageColor3 = Zyrix.Theme.Accent
    clockIcon.ScaleType = Enum.ScaleType.Fit
    clockIcon.LayoutOrder = 1
    clockIcon.Parent = clockRow

    local clockTimeLabel = Instance.new("TextLabel")
    clockTimeLabel.Size = UDim2.new(0, 0, 1, 0)
    clockTimeLabel.AutomaticSize = Enum.AutomaticSize.X
    clockTimeLabel.BackgroundTransparency = 1
    clockTimeLabel.Text = formatTime12()
    clockTimeLabel.TextColor3 = Zyrix.Theme.Accent
    clockTimeLabel.TextSize = isCompact and 14 or 16
    clockTimeLabel.Font = Enum.Font.ArimoBold
    clockTimeLabel.LayoutOrder = 2
    clockTimeLabel.Parent = clockRow

    local clockDateLabel = Instance.new("TextLabel")
    clockDateLabel.Size = UDim2.new(1, 0, 0, isCompact and 12 or 14)
    clockDateLabel.Position = UDim2.new(0, -8, 0, isCompact and 18 or 22)
    clockDateLabel.BackgroundTransparency = 1
    clockDateLabel.Text = formatDate()
    clockDateLabel.TextColor3 = Zyrix.Theme.TextDim
    clockDateLabel.TextSize = isCompact and 9 or 11
    clockDateLabel.Font = Enum.Font.ArimoBold
    clockDateLabel.TextXAlignment = Enum.TextXAlignment.Center
    clockDateLabel.Parent = clockContainer

    local clockRunning = true
    task.spawn(function()
        while clockRunning do
            if not clockTimeLabel or not clockTimeLabel.Parent then clockRunning = false break end
            clockTimeLabel.Text = formatTime12()
            clockDateLabel.Text = formatDate()
            task.wait(1)
        end
    end)
    panel.Destroying:Connect(function() clockRunning = false end)

    local function toggle(userIcon, container, baseWidth)
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
            TweenService:Create(panel, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, panelWidth, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, baseWidth + gap + panelWidth, 0, panelHeight)}):Play()
        else
            TweenService:Create(panelStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
            TweenService:Create(panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, panelHeight)}):Play()
            TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, baseWidth, 0, panelHeight)}):Play()
        end
    end

    panelClose.MouseButton1Click:Connect(function() if isOpen then toggle(nil, parent, windowWidth) end end)
    return panel, toggle, function() return isOpen end, panelWidth
end

local function handleKeylessSkip()
    getgenv().SCRIPT_KEY = "KEYLESS"
    getgenv().ZyrixLoaded = false
    Zyrix:Notify("Access Granted", "Keyless access approved!", 3, "success")
    task.wait(0.3)
    fireOnSuccess()
end

local function BuildCenteredUI(windowWidth, windowHeight, panelHeight, userPanelWidth, changelogPanelWidth, gap, buildContent)
    local gui = buildContent.gui

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, windowWidth, 0, panelHeight)
    container.Position = UDim2.new(0.5, 0, 1.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, windowWidth, 0, windowHeight)
    mainFrame.Position = UDim2.new(0.5, 0, 0, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0)
    mainFrame.BackgroundColor3 = Zyrix.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = container
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 4)

    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Zyrix.Theme.Accent
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0.4

    local userPanel, toggleUserPanel, isUserOpen, userPanelActualWidth = CreateUserInfoPanel(container, windowWidth, panelHeight, userPanelWidth, mainFrame, gap, false)
    local changelogPanel, toggleChangelog, isChangelogOpen, changelogPanelActualWidth = CreateChangelogPanel(container, windowWidth, panelHeight, changelogPanelWidth, mainFrame, gap)

    local function getContainerWidth()
        local w = windowWidth
        if isUserOpen() then w = w + gap + userPanelActualWidth end
        if isChangelogOpen() then w = w + gap + changelogPanelActualWidth end
        return w
    end

    local function toggleUser(userIcon)
        local currentW = getContainerWidth()
        if isUserOpen() then
            toggleUserPanel(userIcon, container, currentW - gap - userPanelActualWidth)
        else
            toggleUserPanel(userIcon, container, currentW)
        end
    end

    local function toggleCL(changelogIcon)
        local currentW = getContainerWidth()
        if isChangelogOpen() then
            toggleChangelog(changelogIcon, container, currentW - gap - changelogPanelActualWidth)
        else
            toggleChangelog(changelogIcon, container, currentW)
        end
    end

    local function closeAllPanels(userIcon, changelogIcon, callback)
        if isChangelogOpen() then toggleCL(changelogIcon) task.wait(0.35) end
        if isUserOpen() then toggleUser(userIcon) task.wait(0.35) end
        if callback then callback() end
    end

    return {
        container = container,
        mainFrame = mainFrame,
        mainStroke = mainStroke,
        toggleUser = toggleUser,
        toggleCL = toggleCL,
        isUserOpen = isUserOpen,
        isChangelogOpen = isChangelogOpen,
        closeAllPanels = closeAllPanels
    }
end

local function BuildKeylessUI()
    local oldGui = hui:FindFirstChild("ZyrixKeylessSystem")
    if oldGui then oldGui:Destroy() end
    local oldGui2 = hui:FindFirstChild("ZyrixKeySystem")
    if oldGui2 then oldGui2:Destroy() end

    enableBlur()

    local mobile = isMobile()
    local padding = 14
    local windowWidth = 300
    local windowHeight = 265
    local userPanelWidth = 165
    local changelogPanelWidth = 200
    local gap = 12

    local gui = Instance.new("ScreenGui")
    gui.Name = "ZyrixKeylessSystem"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = hui

    local ui = BuildCenteredUI(windowWidth, windowHeight, windowHeight, userPanelWidth, changelogPanelWidth, gap, {gui = gui})
    local container = ui.container
    local main = ui.mainFrame
    local mainStroke = ui.mainStroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Zyrix.Theme.Header
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 8)
    headerFix.Position = UDim2.new(0, 0, 1, -8)
    headerFix.BackgroundColor3 = Zyrix.Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = Zyrix.Theme.Accent
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.new(0, 30, 0, 30)
    logo.Position = UDim2.new(0, padding, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = getLogoIcon()
    logo.ImageColor3 = Zyrix.Theme.Text
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -90, 1, 0)
    title.Position = UDim2.new(0, padding + 40, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = Zyrix.Appearance.Title
    title.TextColor3 = Zyrix.Theme.Text
    title.TextSize = mobile and 24 or 26
    title.Font = Enum.Font.ArimoBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -padding, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = getIcon("close")
    closeBtn.ImageColor3 = Zyrix.Theme.TextDim
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = header
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Error}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local contentY = 60

    local successBox = Instance.new("Frame")
    successBox.Size = UDim2.new(0.94, 0, 0, 52)
    successBox.Position = UDim2.new(0.5, 0, 0, contentY)
    successBox.AnchorPoint = Vector2.new(0.5, 0)
    successBox.BackgroundColor3 = Zyrix.Theme.Success
    successBox.BackgroundTransparency = 0.85
    successBox.BorderSizePixel = 0
    successBox.Parent = main
    Instance.new("UICorner", successBox).CornerRadius = UDim.new(0, 4)

    local successStroke = Instance.new("UIStroke", successBox)
    successStroke.Color = Zyrix.Theme.Success
    successStroke.Thickness = 1
    successStroke.Transparency = 0.5

    local checkIcon = Instance.new("ImageLabel")
    checkIcon.Size = UDim2.new(0, 24, 0, 24)
    checkIcon.Position = UDim2.new(0, 16, 0.5, 0)
    checkIcon.AnchorPoint = Vector2.new(0, 0.5)
    checkIcon.BackgroundTransparency = 1
    checkIcon.Image = getIcon("check")
    checkIcon.ImageColor3 = Zyrix.Theme.Success
    checkIcon.ScaleType = Enum.ScaleType.Fit
    checkIcon.Parent = successBox

    local successText = Instance.new("TextLabel")
    successText.Size = UDim2.new(1, -60, 1, 0)
    successText.Position = UDim2.new(0, 52, 0, 0)
    successText.BackgroundTransparency = 1
    successText.Text = "Access Granted"
    successText.TextColor3 = Zyrix.Theme.Success
    successText.TextSize = mobile and 17 or 18
    successText.Font = Enum.Font.ArimoBold
    successText.TextXAlignment = Enum.TextXAlignment.Left
    successText.Parent = successBox

    local keylessText = Instance.new("TextLabel")
    keylessText.Size = UDim2.new(1, 0, 0, 20)
    keylessText.Position = UDim2.new(0.5, 0, 0, contentY + 60)
    keylessText.AnchorPoint = Vector2.new(0.5, 0)
    keylessText.BackgroundTransparency = 1
    keylessText.Text = "Keyless Script"
    keylessText.TextColor3 = Zyrix.Theme.TextDim
    keylessText.TextSize = mobile and 14 or 15
    keylessText.Font = Enum.Font.ArimoBold
    keylessText.Parent = main

    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 3)
    divider.Position = UDim2.new(0, 0, 0, contentY + 88)
    divider.BackgroundColor3 = Zyrix.Theme.Divider
    divider.BorderSizePixel = 0
    divider.Parent = main

    local launchBtn = Instance.new("TextButton")
    launchBtn.Size = UDim2.new(0.75, 0, 0, 42)
    launchBtn.Position = UDim2.new(0.5, 0, 0, contentY + 103)
    launchBtn.AnchorPoint = Vector2.new(0.5, 0)
    launchBtn.BackgroundColor3 = Zyrix.Theme.Accent
    launchBtn.BorderSizePixel = 0
    launchBtn.Text = ""
    launchBtn.AutoButtonColor = false
    launchBtn.Parent = main
    Instance.new("UICorner", launchBtn).CornerRadius = UDim.new(0, 4)

    local launchStroke = Instance.new("UIStroke", launchBtn)
    launchStroke.Color = Zyrix.Theme.AccentHover
    launchStroke.Thickness = 1
    launchStroke.Transparency = 0.5

    local launchContent = Instance.new("Frame")
    launchContent.Size = UDim2.new(1, 0, 1, 0)
    launchContent.BackgroundTransparency = 1
    launchContent.Parent = launchBtn

    local launchLayout = Instance.new("UIListLayout", launchContent)
    launchLayout.FillDirection = Enum.FillDirection.Horizontal
    launchLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    launchLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    launchLayout.Padding = UDim.new(0, 8)

    local launchIcon = Instance.new("ImageLabel")
    launchIcon.Size = UDim2.new(0, 18, 0, 18)
    launchIcon.BackgroundTransparency = 1
    launchIcon.Image = getIcon("shield")
    launchIcon.ImageColor3 = Zyrix.Theme.Text
    launchIcon.ScaleType = Enum.ScaleType.Fit
    launchIcon.LayoutOrder = 1
    launchIcon.Parent = launchContent

    local launchLabel = Instance.new("TextLabel")
    launchLabel.Size = UDim2.new(0, 0, 0, 18)
    launchLabel.AutomaticSize = Enum.AutomaticSize.X
    launchLabel.BackgroundTransparency = 1
    launchLabel.Text = "Launch Script"
    launchLabel.TextColor3 = Zyrix.Theme.Text
    launchLabel.TextSize = mobile and 14 or 15
    launchLabel.Font = Enum.Font.ArimoBold
    launchLabel.LayoutOrder = 2
    launchLabel.Parent = launchContent

    launchBtn.MouseEnter:Connect(function() TweenService:Create(launchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Zyrix.Theme.AccentHover}):Play() end)
    launchBtn.MouseLeave:Connect(function() TweenService:Create(launchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Zyrix.Theme.Accent}):Play() end)

    local bottomY = contentY + 153

    local userBtn = Instance.new("TextButton")
    userBtn.Size = UDim2.new(0, 36, 0, 36)
    userBtn.Position = UDim2.new(0.5, -44, 0, bottomY)
    userBtn.AnchorPoint = Vector2.new(0.5, 0)
    userBtn.BackgroundColor3 = Zyrix.Theme.Background
    userBtn.BorderSizePixel = 0
    userBtn.Text = ""
    userBtn.AutoButtonColor = false
    userBtn.Parent = main
    Instance.new("UICorner", userBtn).CornerRadius = UDim.new(0, 4)

    local userIcon = Instance.new("ImageLabel")
    userIcon.Size = UDim2.new(0, 18, 0, 18)
    userIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    userIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    userIcon.BackgroundTransparency = 1
    userIcon.Image = getIcon("user")
    userIcon.ImageColor3 = Zyrix.Theme.TextDim
    userIcon.ScaleType = Enum.ScaleType.Fit
    userIcon.Parent = userBtn
    userBtn.MouseEnter:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Accent}):Play() end)
    userBtn.MouseLeave:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 36, 0, 36)
    discordBtn.Position = UDim2.new(0.5, 0, 0, bottomY)
    discordBtn.AnchorPoint = Vector2.new(0.5, 0)
    discordBtn.BackgroundColor3 = Zyrix.Theme.Background
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = ""
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = main
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.new(0, 18, 0, 18)
    discordIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    discordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = getIcon("discord")
    discordIcon.ImageColor3 = Zyrix.Theme.Discord
    discordIcon.ScaleType = Enum.ScaleType.Fit
    discordIcon.Parent = discordBtn
    discordBtn.MouseEnter:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.DiscordHover}):Play() end)
    discordBtn.MouseLeave:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Discord}):Play() end)

    local changelogBtn = Instance.new("TextButton")
    changelogBtn.Size = UDim2.new(0, 36, 0, 36)
    changelogBtn.Position = UDim2.new(0.5, 44, 0, bottomY)
    changelogBtn.AnchorPoint = Vector2.new(0.5, 0)
    changelogBtn.BackgroundColor3 = Zyrix.Theme.Background
    changelogBtn.BorderSizePixel = 0
    changelogBtn.Text = ""
    changelogBtn.AutoButtonColor = false
    changelogBtn.Parent = main
    Instance.new("UICorner", changelogBtn).CornerRadius = UDim.new(0, 4)

    local changelogIcon = Instance.new("ImageLabel")
    changelogIcon.Size = UDim2.new(0, 18, 0, 18)
    changelogIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    changelogIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    changelogIcon.BackgroundTransparency = 1
    changelogIcon.Image = getIcon("changelog")
    changelogIcon.ImageColor3 = Zyrix.Theme.TextDim
    changelogIcon.ScaleType = Enum.ScaleType.Fit
    changelogIcon.Parent = changelogBtn
    changelogBtn.MouseEnter:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Text}):Play() end)
    changelogBtn.MouseLeave:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    if #Zyrix.Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    local doors = CreateDoorOverlay(main, windowWidth, windowHeight)

    userBtn.MouseButton1Click:Connect(function() ui.toggleUser(userIcon) end)
    changelogBtn.MouseButton1Click:Connect(function() ui.toggleCL(changelogIcon) end)

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.3) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.4) gui:Destroy()
        end)
        if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
    end)

    launchBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Launching", "Script loaded successfully!", 2, "success")
        getgenv().SCRIPT_KEY = "KEYLESS"
        getgenv().ZyrixLoaded = false
        closeDoorsThenExit(function()
            disableBlur()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(main, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(mainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
            task.wait(0.4) gui:Destroy()
            if not Internal.IsJunkieMode then fireOnSuccess() end
        end)
    end)

    discordBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord ~= "" then
            Zyrix:Notify("Discord", "Invite link copied!", 2, "discord")
            pcall(function() setclipboard(Zyrix.Links.Discord) end)
        end
    end)

    setupDragging(header, container)
    TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.6)
    doors.open(function()
        checkIcon.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(checkIcon, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 24, 0, 24)}):Play()
        task.wait(0.2)
        ui.toggleUser(userIcon)
        if #Zyrix.Changelog > 0 then task.wait(0.3) ui.toggleCL(changelogIcon) end
    end)
end

local function BuildKeyUI()
    local oldGui = hui:FindFirstChild("ZyrixKeySystem")
    if oldGui then oldGui:Destroy() end
    local oldGui2 = hui:FindFirstChild("ZyrixKeylessSystem")
    if oldGui2 then oldGui2:Destroy() end

    enableBlur()

    local mobile = isMobile()
    local scale = getScale()
    local padding = 14
    local showShop = isShopEnabled()
    local shopHeight = 52
    local shopDividerHeight = 1
    local shopExtra = showShop and (shopHeight + shopDividerHeight) or 0
    local baseWindowHeight = mobile and math.clamp(360 * scale, 320, 400) or 360
    local windowWidth = mobile and math.clamp(400 * scale, 320, 440) or 400
    local windowHeight = baseWindowHeight + shopExtra
    local elementHeight = mobile and math.clamp(56 * scale, 48, 62) or 56
    local buttonHeight = mobile and math.clamp(42 * scale, 38, 48) or 42
    local statusHeight = mobile and math.clamp(60 * scale, 52, 68) or 60
    local userPanelWidth = 180
    local changelogPanelWidth = 220
    local gap = 12

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZyrixKeySystem"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = hui

    local ui = BuildCenteredUI(windowWidth, windowHeight, baseWindowHeight, userPanelWidth, changelogPanelWidth, gap, {gui = screenGui})
    local container = ui.container
    local mainFrame = ui.mainFrame
    local mainStroke = ui.mainStroke

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Zyrix.Theme.Header
    header.BorderSizePixel = 0
    header.Active = true
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 4)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 6)
    headerFix.Position = UDim2.new(0, 0, 1, -6)
    headerFix.BackgroundColor3 = Zyrix.Theme.Header
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, 0, 0, 1)
    headerLine.Position = UDim2.new(0, 0, 1, 0)
    headerLine.BackgroundColor3 = Zyrix.Theme.Accent
    headerLine.BackgroundTransparency = 0.6
    headerLine.BorderSizePixel = 0
    headerLine.Parent = header

    local logo = Instance.new("ImageLabel")
    logo.Size = Zyrix.Appearance.IconSize
    logo.Position = UDim2.new(0, padding, 0.5, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = getLogoIcon()
    logo.ImageColor3 = Zyrix.Theme.Text
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = header

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -90, 1, 0)
    titleLabel.Position = UDim2.new(0, padding + Zyrix.Appearance.IconSize.X.Offset + 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = Zyrix.Appearance.Title
    titleLabel.TextColor3 = Zyrix.Theme.Text
    titleLabel.TextSize = mobile and 24 or 26
    titleLabel.Font = Enum.Font.ArimoBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = header

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Size = UDim2.new(0, 22, 0, 22)
    closeBtn.Position = UDim2.new(1, -padding, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = getIcon("close")
    closeBtn.ImageColor3 = Zyrix.Theme.TextDim
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = header
    closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Error}):Play() end)
    closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local contentStartY = 60

    local statusFrame = Instance.new("Frame")
    statusFrame.Size = UDim2.new(0.94, 0, 0, statusHeight)
    statusFrame.Position = UDim2.new(0.5, 0, 0, contentStartY)
    statusFrame.AnchorPoint = Vector2.new(0.5, 0)
    statusFrame.BackgroundColor3 = Zyrix.Theme.Input
    statusFrame.BorderSizePixel = 0
    statusFrame.ClipsDescendants = true
    statusFrame.Parent = mainFrame
    Instance.new("UICorner", statusFrame).CornerRadius = UDim.new(0, 4)

    local statusStroke = Instance.new("UIStroke", statusFrame)
    statusStroke.Color = Zyrix.Theme.Accent
    statusStroke.Thickness = 1
    statusStroke.Transparency = 0.8

    local statusIcon = Instance.new("ImageLabel")
    statusIcon.Size = UDim2.new(0, 24, 0, 24)
    statusIcon.Position = UDim2.new(0, 16, 0.5, 0)
    statusIcon.AnchorPoint = Vector2.new(0, 0.5)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Image = getIcon("lock")
    statusIcon.ImageColor3 = Zyrix.Theme.StatusIdle
    statusIcon.ScaleType = Enum.ScaleType.Fit
    statusIcon.Parent = statusFrame

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -60, 1, 0)
    statusLabel.Position = UDim2.new(0, 52, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = Zyrix.Appearance.Subtitle
    statusLabel.TextColor3 = Zyrix.Theme.StatusIdle
    statusLabel.TextSize = mobile and 17 or 18
    statusLabel.Font = Enum.Font.ArimoBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.TextTruncate = Enum.TextTruncate.AtEnd
    statusLabel.Parent = statusFrame

    local inputStartY = contentStartY + statusHeight + 10

    local inputFrame = Instance.new("Frame")
    inputFrame.Size = UDim2.new(0.94, 0, 0, elementHeight)
    inputFrame.Position = UDim2.new(0.5, 0, 0, inputStartY)
    inputFrame.AnchorPoint = Vector2.new(0.5, 0)
    inputFrame.BackgroundColor3 = Zyrix.Theme.Input
    inputFrame.BorderSizePixel = 0
    inputFrame.ClipsDescendants = true
    inputFrame.Parent = mainFrame
    Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)

    local inputStroke = Instance.new("UIStroke", inputFrame)
    inputStroke.Color = Zyrix.Theme.Accent
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.7

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(1, -24, 1, 0)
    textBox.Position = UDim2.new(0, 12, 0.5, 0)
    textBox.AnchorPoint = Vector2.new(0, 0.5)
    textBox.BackgroundTransparency = 1
    textBox.Text = ""
    textBox.TextColor3 = Zyrix.Theme.Text
    textBox.PlaceholderText = "Enter your key..."
    textBox.PlaceholderColor3 = Zyrix.Theme.TextDim
    textBox.TextSize = mobile and 17 or 18
    textBox.Font = Enum.Font.ArimoBold
    textBox.ClearTextOnFocus = false
    textBox.TextTruncate = Enum.TextTruncate.AtEnd
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.Parent = inputFrame
    textBox.Focused:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play() end)
    textBox.FocusLost:Connect(function() TweenService:Create(inputStroke, TweenInfo.new(0.15), {Transparency = 0.7}):Play() end)

    local dividerY = inputStartY + elementHeight + 12

    local dividerLine = Instance.new("Frame")
    dividerLine.Size = UDim2.new(1, 0, 0, 3)
    dividerLine.Position = UDim2.new(0, 0, 0, dividerY)
    dividerLine.BackgroundColor3 = Zyrix.Theme.Divider
    dividerLine.BorderSizePixel = 0
    dividerLine.Parent = mainFrame

    local acquireStartY = dividerY + 15

    local function createButton(text, iconKey, isPrimary, yPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.75, 0, 0, buttonHeight)
        btn.Position = UDim2.new(0.5, 0, 0, yPos)
        btn.AnchorPoint = Vector2.new(0.5, 0)
        btn.BackgroundColor3 = isPrimary and Zyrix.Theme.Accent or Zyrix.Theme.Input
        btn.BorderSizePixel = 0
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Parent = mainFrame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = isPrimary and Zyrix.Theme.AccentHover or Zyrix.Theme.Accent
        btnStroke.Thickness = 1
        btnStroke.Transparency = isPrimary and 0.5 or 0.7

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, 0, 1, 0)
        content.BackgroundTransparency = 1
        content.Parent = btn

        local layout = Instance.new("UIListLayout", content)
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 8)

        local iconImg = Instance.new("ImageLabel")
        iconImg.Size = UDim2.new(0, 18, 0, 18)
        iconImg.BackgroundTransparency = 1
        iconImg.Image = getIcon(iconKey)
        iconImg.ImageColor3 = Zyrix.Theme.Text
        iconImg.ScaleType = Enum.ScaleType.Fit
        iconImg.LayoutOrder = 1
        iconImg.Parent = content

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0, 0, 0, 20)
        label.AutomaticSize = Enum.AutomaticSize.X
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Zyrix.Theme.Text
        label.TextSize = mobile and 14 or 15
        label.Font = Enum.Font.ArimoBold
        label.LayoutOrder = 2
        label.Parent = content

        local origColor = btn.BackgroundColor3
        local hoverColor = isPrimary and Zyrix.Theme.AccentHover or Zyrix.Theme.Accent
        btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = origColor}):Play() end)
        return btn
    end

    local acquireBtn = createButton(Zyrix.Options.NoGetKey and "Unavailable" or "Get Key", Zyrix.Options.NoGetKey and "nogetkey" or "key", false, acquireStartY)
    if Zyrix.Options.NoGetKey then
        acquireBtn.Active = false
        TweenService:Create(acquireBtn, TweenInfo.new(0), {BackgroundColor3 = Zyrix.Theme.Pending}):Play()
    end

    local redeemBtn = createButton("Redeem Key", "shield", true, acquireStartY + buttonHeight + 5)
    local bottomY = acquireStartY + buttonHeight * 2 + 10

    local userBtn = Instance.new("TextButton")
    userBtn.Size = UDim2.new(0, 36, 0, 36)
    userBtn.Position = UDim2.new(0.5, -44, 0, bottomY)
    userBtn.AnchorPoint = Vector2.new(0.5, 0)
    userBtn.BackgroundColor3 = Zyrix.Theme.Background
    userBtn.BorderSizePixel = 0
    userBtn.Text = ""
    userBtn.AutoButtonColor = false
    userBtn.Parent = mainFrame
    Instance.new("UICorner", userBtn).CornerRadius = UDim.new(0, 4)

    local userIcon = Instance.new("ImageLabel")
    userIcon.Size = UDim2.new(0, 18, 0, 18)
    userIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    userIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    userIcon.BackgroundTransparency = 1
    userIcon.Image = getIcon("user")
    userIcon.ImageColor3 = Zyrix.Theme.TextDim
    userIcon.ScaleType = Enum.ScaleType.Fit
    userIcon.Parent = userBtn
    userBtn.MouseEnter:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Accent}):Play() end)
    userBtn.MouseLeave:Connect(function() TweenService:Create(userIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0, 36, 0, 36)
    discordBtn.Position = UDim2.new(0.5, 0, 0, bottomY)
    discordBtn.AnchorPoint = Vector2.new(0.5, 0)
    discordBtn.BackgroundColor3 = Zyrix.Theme.Background
    discordBtn.BorderSizePixel = 0
    discordBtn.Text = ""
    discordBtn.AutoButtonColor = false
    discordBtn.Parent = mainFrame
    Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 4)

    local discordIcon = Instance.new("ImageLabel")
    discordIcon.Size = UDim2.new(0, 18, 0, 18)
    discordIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    discordIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    discordIcon.BackgroundTransparency = 1
    discordIcon.Image = getIcon("discord")
    discordIcon.ImageColor3 = Zyrix.Theme.Discord
    discordIcon.ScaleType = Enum.ScaleType.Fit
    discordIcon.Parent = discordBtn
    discordBtn.MouseEnter:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.DiscordHover}):Play() end)
    discordBtn.MouseLeave:Connect(function() TweenService:Create(discordIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Discord}):Play() end)

    local changelogBtn = Instance.new("TextButton")
    changelogBtn.Size = UDim2.new(0, 36, 0, 36)
    changelogBtn.Position = UDim2.new(0.5, 44, 0, bottomY)
    changelogBtn.AnchorPoint = Vector2.new(0.5, 0)
    changelogBtn.BackgroundColor3 = Zyrix.Theme.Background
    changelogBtn.BorderSizePixel = 0
    changelogBtn.Text = ""
    changelogBtn.AutoButtonColor = false
    changelogBtn.Parent = mainFrame
    Instance.new("UICorner", changelogBtn).CornerRadius = UDim.new(0, 4)

    local changelogIcon = Instance.new("ImageLabel")
    changelogIcon.Size = UDim2.new(0, 18, 0, 18)
    changelogIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    changelogIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    changelogIcon.BackgroundTransparency = 1
    changelogIcon.Image = getIcon("changelog")
    changelogIcon.ImageColor3 = Zyrix.Theme.TextDim
    changelogIcon.ScaleType = Enum.ScaleType.Fit
    changelogIcon.Parent = changelogBtn
    changelogBtn.MouseEnter:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.Text}):Play() end)
    changelogBtn.MouseLeave:Connect(function() TweenService:Create(changelogIcon, TweenInfo.new(0.15), {ImageColor3 = Zyrix.Theme.TextDim}):Play() end)

    if #Zyrix.Changelog == 0 then
        changelogBtn.Visible = false
        userBtn.Position = UDim2.new(0.5, -22, 0, bottomY)
        discordBtn.Position = UDim2.new(0.5, 22, 0, bottomY)
    end

    if showShop then
        local shopDivider = Instance.new("Frame")
        shopDivider.Size = UDim2.new(1, 0, 0, shopDividerHeight)
        shopDivider.Position = UDim2.new(0, 0, 1, -shopHeight - shopDividerHeight)
        shopDivider.AnchorPoint = Vector2.new(0, 0)
        shopDivider.BackgroundColor3 = Zyrix.Theme.Accent
        shopDivider.BackgroundTransparency = 0.6
        shopDivider.BorderSizePixel = 0
        shopDivider.Parent = mainFrame

        local shopFrame = Instance.new("Frame")
        shopFrame.Size = UDim2.new(1, 0, 0, shopHeight)
        shopFrame.Position = UDim2.new(0, 0, 1, -shopHeight)
        shopFrame.AnchorPoint = Vector2.new(0, 0)
        shopFrame.BackgroundColor3 = Zyrix.Theme.Header
        shopFrame.BorderSizePixel = 0
        shopFrame.ClipsDescendants = true
        shopFrame.Parent = mainFrame

        local shopCorner = Instance.new("UICorner", shopFrame)
        shopCorner.CornerRadius = UDim.new(0, 4)

        local shopTopFix = Instance.new("Frame")
        shopTopFix.Size = UDim2.new(1, 0, 0, 8)
        shopTopFix.Position = UDim2.new(0, 0, 0, 0)
        shopTopFix.BackgroundColor3 = Zyrix.Theme.Header
        shopTopFix.BorderSizePixel = 0
        shopTopFix.Parent = shopFrame

        local shopPadding = 14
        local shopIconSize = 28

        local shopIconWrapper = Instance.new("Frame")
        shopIconWrapper.Size = UDim2.new(0, shopIconSize + 4, 0, shopIconSize + 4)
        shopIconWrapper.Position = UDim2.new(0, shopPadding, 0.5, 0)
        shopIconWrapper.AnchorPoint = Vector2.new(0, 0.5)
        shopIconWrapper.BackgroundColor3 = Zyrix.Theme.Accent
        shopIconWrapper.BackgroundTransparency = 0.7
        shopIconWrapper.BorderSizePixel = 0
        shopIconWrapper.Parent = shopFrame
        Instance.new("UICorner", shopIconWrapper).CornerRadius = UDim.new(0, 4)

        local shopIconStroke = Instance.new("UIStroke", shopIconWrapper)
        shopIconStroke.Color = Zyrix.Theme.Accent
        shopIconStroke.Thickness = 1
        shopIconStroke.Transparency = 0.5

        local shopIconImg = Instance.new("ImageLabel")
        shopIconImg.Size = UDim2.new(0, shopIconSize, 0, shopIconSize)
        shopIconImg.Position = UDim2.new(0.5, 0, 0.5, 0)
        shopIconImg.AnchorPoint = Vector2.new(0.5, 0.5)
        shopIconImg.BackgroundTransparency = 1
        shopIconImg.Image = getShopIcon()
        shopIconImg.ImageColor3 = Zyrix.Theme.Text
        shopIconImg.ScaleType = Enum.ScaleType.Fit
        shopIconImg.Parent = shopIconWrapper

        local buyBtnWidth = 60
        local textStartX = shopPadding + shopIconSize + 4 + 10
        local textAreaWidth = windowWidth - textStartX - buyBtnWidth - shopPadding - 8

        local shopTitle = Instance.new("TextLabel")
        shopTitle.Size = UDim2.new(0, textAreaWidth, 0, 18)
        shopTitle.Position = UDim2.new(0, textStartX, 0, 9)
        shopTitle.BackgroundTransparency = 1
        shopTitle.Text = Zyrix.Shop.Title
        shopTitle.TextColor3 = Zyrix.Theme.Text
        shopTitle.TextSize = mobile and 13 or 14
        shopTitle.Font = Enum.Font.ArimoBold
        shopTitle.TextXAlignment = Enum.TextXAlignment.Left
        shopTitle.TextTruncate = Enum.TextTruncate.AtEnd
        shopTitle.Parent = shopFrame

        local shopSubtitle = Instance.new("TextLabel")
        shopSubtitle.Size = UDim2.new(0, textAreaWidth, 0, 14)
        shopSubtitle.Position = UDim2.new(0, textStartX, 0, 29)
        shopSubtitle.BackgroundTransparency = 1
        shopSubtitle.Text = Zyrix.Shop.Subtitle
        shopSubtitle.TextColor3 = Zyrix.Theme.TextDim
        shopSubtitle.TextSize = mobile and 10 or 11
        shopSubtitle.Font = Enum.Font.ArimoBold
        shopSubtitle.TextXAlignment = Enum.TextXAlignment.Left
        shopSubtitle.TextTruncate = Enum.TextTruncate.AtEnd
        shopSubtitle.Parent = shopFrame

        local buyBtn = Instance.new("TextButton")
        buyBtn.Size = UDim2.new(0, buyBtnWidth, 0, 30)
        buyBtn.Position = UDim2.new(1, -shopPadding, 0.5, 0)
        buyBtn.AnchorPoint = Vector2.new(1, 0.5)
        buyBtn.BackgroundColor3 = Zyrix.Theme.Accent
        buyBtn.BorderSizePixel = 0
        buyBtn.Text = ""
        buyBtn.AutoButtonColor = false
        buyBtn.Parent = shopFrame
        Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 4)

        local buyBtnStroke = Instance.new("UIStroke", buyBtn)
        buyBtnStroke.Color = Zyrix.Theme.AccentHover
        buyBtnStroke.Thickness = 1
        buyBtnStroke.Transparency = 0.5

        local buyContent = Instance.new("Frame")
        buyContent.Size = UDim2.new(1, 0, 1, 0)
        buyContent.BackgroundTransparency = 1
        buyContent.Parent = buyBtn

        local buyLayout = Instance.new("UIListLayout", buyContent)
        buyLayout.FillDirection = Enum.FillDirection.Horizontal
        buyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        buyLayout.VerticalAlignment = Enum.VerticalAlignment.Center
        buyLayout.Padding = UDim.new(0, 5)

        local buyIcon = Instance.new("ImageLabel")
        buyIcon.Size = UDim2.new(0, 14, 0, 14)
        buyIcon.BackgroundTransparency = 1
        buyIcon.Image = getIcon("cart")
        buyIcon.ImageColor3 = Zyrix.Theme.Text
        buyIcon.ScaleType = Enum.ScaleType.Fit
        buyIcon.LayoutOrder = 1
        buyIcon.Parent = buyContent

        local buyLabel = Instance.new("TextLabel")
        buyLabel.Size = UDim2.new(0, 0, 0, 14)
        buyLabel.AutomaticSize = Enum.AutomaticSize.X
        buyLabel.BackgroundTransparency = 1
        buyLabel.Text = Zyrix.Shop.ButtonText
        buyLabel.TextColor3 = Zyrix.Theme.Text
        buyLabel.TextSize = mobile and 11 or 12
        buyLabel.Font = Enum.Font.ArimoBold
        buyLabel.LayoutOrder = 2
        buyLabel.Parent = buyContent

        buyBtn.MouseEnter:Connect(function() TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Zyrix.Theme.AccentHover}):Play() end)
        buyBtn.MouseLeave:Connect(function() TweenService:Create(buyBtn, TweenInfo.new(0.15), {BackgroundColor3 = Zyrix.Theme.Accent}):Play() end)
        buyBtn.MouseButton1Click:Connect(function()
            if Zyrix.Shop.Link ~= "" then
                pcall(function() setclipboard(Zyrix.Shop.Link) end)
                Zyrix:Notify("Shop", "Shop link copied to clipboard!", 2, "copy")
            end
        end)
    end

    local doors = CreateDoorOverlay(mainFrame, windowWidth, windowHeight)

    userBtn.MouseButton1Click:Connect(function() ui.toggleUser(userIcon) end)
    changelogBtn.MouseButton1Click:Connect(function() ui.toggleCL(changelogIcon) end)

    local spinConnection, dotsThread

    local function setStatus(state, customText)
        if spinConnection then spinConnection:Disconnect() spinConnection = nil statusIcon.Rotation = 0 end
        if dotsThread then task.cancel(dotsThread) dotsThread = nil end
        local color, icon, text = Zyrix.Theme.StatusIdle, getIcon("lock"), customText or "No key detected"
        if state == "verifying" then
            color, icon, text = Zyrix.Theme.Accent, getIcon("loading"), "Verifying key"
            spinConnection = RunService.Heartbeat:Connect(function(dt)
                if statusIcon and statusIcon.Parent then statusIcon.Rotation = (statusIcon.Rotation + dt * 360) % 360
                else if spinConnection then spinConnection:Disconnect() end end
            end)
            local dots, i = {".", "..", "...", ""}, 1
            dotsThread = task.spawn(function()
                while statusLabel and statusLabel.Parent and statusLabel.Text:find("Verifying", 1, true) do
                    statusLabel.Text = text .. dots[i] i = (i % #dots) + 1 task.wait(0.4)
                end
            end)
        elseif state == "success" then color, icon, text = Zyrix.Theme.Success, getIcon("check"), customText or "Access Granted"
        elseif state == "error" then color, icon, text = Zyrix.Theme.Error, getIcon("alert"), customText or "Invalid Key" end
        TweenService:Create(statusLabel, TweenInfo.new(0.3), {TextColor3 = color}):Play()
        TweenService:Create(statusIcon, TweenInfo.new(0.3), {ImageColor3 = color}):Play()
        statusLabel.Text = text statusIcon.Image = icon
    end

    local function closeDoorsThenExit(callback)
        ui.closeAllPanels(userIcon, changelogIcon, function()
            doors.close(function() task.wait(0.3) if callback then callback() end end)
        end)
    end

    closeBtn.MouseButton1Click:Connect(function()
        Zyrix:Notify("Goodbye", "See you next time!", 2, "close")
        closeDoorsThenExit(function()
            fullCleanup()
            TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
            TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            task.wait(0.4) screenGui:Destroy()
            if Zyrix.Callbacks.OnClose then Zyrix.Callbacks.OnClose() end
        end)
    end)

    local function handleRedeem()
        local key = textBox.Text:gsub("%s+", "")
        if key == "" then Zyrix:Notify("Error", "Please enter your key", 3, "warning") return end
        setStatus("verifying") redeemBtn.Active = false task.wait(0.3)
        local valid, errorMsg = false, "Invalid key"
        if Internal.ValidateFunction then
            local success, result, msg = pcall(Internal.ValidateFunction, key)
            if success then
                if type(result) == "table" then
                    valid = result.valid == true
                    local errMsgs = {
                        KEY_INVALID = "Key not found in system", KEY_EXPIRED = "Key has expired",
                        HWID_BANNED = "Hardware banned", KEY_INVALIDATED = "Key was revoked",
                        ALREADY_USED = "One-time key already used", HWID_MISMATCH = "HWID limit reached",
                        SERVICE_NOT_FOUND = "Service not found", SERVICE_MISMATCH = "Wrong service",
                        PREMIUM_REQUIRED = "Premium required", ERROR = "Network error"
                    }
                    local errCode = result.error or "Unknown"
                    errorMsg = errMsgs[errCode] or result.message or errCode
                    if errCode == "HWID_BANNED" then task.delay(2, function() cloneref(Players.LocalPlayer):Kick("Hardware banned") end) end
                elseif type(result) == "boolean" then valid = result errorMsg = msg or "Invalid key" end
            end
        end
        redeemBtn.Active = true
        if valid then
            saveKey(key) getgenv().SCRIPT_KEY = key getgenv().ZyrixLoaded = false
            setStatus("success") Zyrix:Notify("Success", "Key validated successfully!", 2, "success") task.wait(1)
            closeDoorsThenExit(function()
                disableBlur()
                TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, -0.5, 0)}):Play()
                TweenService:Create(mainFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
                task.wait(0.4) screenGui:Destroy()
                task.spawn(function()
                    task.wait(0.15)
                    if not Internal.IsJunkieMode then fireOnSuccess() end
                end)
            end)
        else
            setStatus("error", errorMsg) Zyrix:Notify("Invalid", errorMsg, 4, "error")
            if Zyrix.Callbacks.OnFail then Zyrix.Callbacks.OnFail(errorMsg) end
        end
    end

    redeemBtn.MouseButton1Click:Connect(handleRedeem)
    acquireBtn.MouseButton1Click:Connect(function()
        if Zyrix.Options.NoGetKey then
            Zyrix:Notify("Unavailable", "Get Key is unavailable", 3, "nogetkey")
            return
        end
        if Zyrix.Links.GetKey ~= "" then
            Zyrix:Notify("Copied", "Key link copied!", 3, "copy")
            pcall(function() setclipboard(Zyrix.Links.GetKey) end)
        else
            Zyrix:Notify("Error", "No key link set", 3, "warning")
        end
    end)
    discordBtn.MouseButton1Click:Connect(function()
        if Zyrix.Links.Discord ~= "" then Zyrix:Notify("Discord", "Invite link copied!", 2, "discord") pcall(function() setclipboard(Zyrix.Links.Discord) end) end
    end)
    textBox.FocusLost:Connect(function(enter) if enter then handleRedeem() end end)

    setupDragging(header, container)
    TweenService:Create(container, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 0, 0.45, 0)}):Play()
    task.wait(0.6)
    doors.open(function()
        task.wait(0.2)
        ui.toggleUser(userIcon)
        if #Zyrix.Changelog > 0 then task.wait(0.3) ui.toggleCL(changelogIcon) end
    end)
end

function Zyrix:Launch()
    Internal.IsJunkieMode = false
    Internal.ValidateFunction = Zyrix.Callbacks.OnVerify
    local existingKey = getgenv().SCRIPT_KEY
    if existingKey and existingKey ~= "" then
        if existingKey == "KEYLESS" then
            Zyrix:Notify("Executed", "Script loaded successfully!", 2, "success")
            fireOnSuccess() return
        elseif Internal.ValidateFunction and validateKey(existingKey, Internal.ValidateFunction) then
            Zyrix:Notify("Executed", "Script loaded successfully!", 2, "success")
            fireOnSuccess() return
        end
        getgenv().SCRIPT_KEY = nil
    end
    getgenv().ZyrixClosed = false
    EnsureIconsReady(function()
        if Zyrix.Options.Keyless == true then
            if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Zyrix.Storage.AutoLoad and Internal.ValidateFunction then
            local savedKey = loadKey()
            if savedKey and savedKey ~= "" then
                Zyrix:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
                if validateKey(savedKey, Internal.ValidateFunction) then
                    getgenv().SCRIPT_KEY = savedKey
                    Zyrix:Notify("Welcome Back", "Key validated!", 2, "success")
                    fireOnSuccess() return
                else clearKey() Zyrix:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
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
        Zyrix:Notify("Executed", "Script loaded successfully!", 2, "success")
        fireOnSuccess() return
    end
    getgenv().ZyrixClosed = false
    EnsureIconsReady(function()
        local success, Junkie = pcall(function() return loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))() end)
        if not success or not Junkie then Zyrix:Notify("Error", "Failed to load Junkie SDK", 5, "error") return end
        Junkie.service = config.Service
        Junkie.identifier = config.Identifier
        Junkie.provider = config.Provider
        Internal.Junkie = Junkie
        if Zyrix.Links.GetKey == "" then pcall(function() Zyrix.Links.GetKey = Junkie.get_key_link() end) end
        Internal.ValidateFunction = function(key) return Junkie.check_key(key) end
        if Zyrix.Options.Keyless == nil then
            local ks, kr = pcall(function() return Junkie.check_key("KEYLESS") end)
            if ks and kr and kr.valid then
                if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
                BuildKeylessUI()
                while not getgenv().SCRIPT_KEY do task.wait(0.1) end
                return
            end
        elseif Zyrix.Options.Keyless == true then
            if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
            BuildKeylessUI()
            while not getgenv().SCRIPT_KEY do task.wait(0.1) end
            return
        end
        if Zyrix.Storage.AutoLoad then
            local savedKey = loadKey()
            if savedKey and savedKey ~= "" then
                Zyrix:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
                local vs, vr = pcall(function() return Junkie.check_key(savedKey) end)
                if vs and vr and vr.valid then
                    getgenv().SCRIPT_KEY = savedKey
                    Zyrix:Notify("Welcome Back", "Key validated!", 2, "success")
                    fireOnSuccess() return
                else clearKey() Zyrix:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
            end
        end
        BuildKeyUI()
        while not getgenv().SCRIPT_KEY do task.wait(0.1) end
    end)
end

function Zyrix:GetSavedKey() return loadKey() end
function Zyrix:ClearSavedKey() return clearKey() end

getgenv().Zyrix = Zyrix

--[[
 @uniquadev CONVERTER UI — Lemonade build
]]

local ZyrixUI = {}
local uiBuilt = false
local uiScreenGui
local uiOpenPanel
local uiClosePanel

local function buildZyrixUI()
    if uiBuilt and uiScreenGui and uiScreenGui.Parent then return end

    local uiParent = hui
    local oldGui = uiParent:FindFirstChild("ZyrixMainUI")
    if oldGui then oldGui:Destroy() end

-- Instances: 92 | Scripts: 2 | Modules: 0 | Tags: 0
local G2L = {};

-- StarterGui.ZyrixMainUI
G2L["1"] = Instance.new("ScreenGui");
G2L["1"]["Name"] = [[ZyrixMainUI]];
G2L["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
G2L["1"]["ResetOnSpawn"] = false;
G2L["1"]["IgnoreGuiInset"] = true;
G2L["1"]["DisplayOrder"] = 100;
G2L["1"]["Enabled"] = true;
G2L["1"]["Parent"] = uiParent;
-- Attributes
G2L["1"]:SetAttribute([[_lemonadeUniqueId]], [[teVRcf7zteVR]]);


-- StarterGui.Zyrix.main
G2L["2"] = Instance.new("Frame", G2L["1"]);
G2L["2"]["BorderSizePixel"] = 0;
G2L["2"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["Size"] = UDim2.new(0.39696, 0, 0.52711, 0);
G2L["2"]["Position"] = UDim2.new(0.29841, 0, 0.27131, 0);
G2L["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["2"]["Name"] = [[main]];
-- Attributes
G2L["2"]:SetAttribute([[_lemonadeUniqueId]], [[P1oiKE9TP1oi]]);


-- StarterGui.Zyrix.main.TextLabel
G2L["3"] = Instance.new("TextLabel", G2L["2"]);
G2L["3"]["BorderSizePixel"] = 0;
G2L["3"]["TextSize"] = 15;
G2L["3"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["3"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["3"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["3"]["BackgroundTransparency"] = 1;
G2L["3"]["Size"] = UDim2.new(0.85258, 0, 0.06497, 0);
G2L["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3"]["Text"] = [[zyrix]];
G2L["3"]["Position"] = UDim2.new(0.05684, 0, 0.01695, 0);
-- Attributes
G2L["3"]:SetAttribute([[_lemonadeUniqueId]], [[5wsAPDmq5wsA]]);


-- StarterGui.Zyrix.main.openTab
G2L["4"] = Instance.new("ImageButton", G2L["2"]);
G2L["4"]["BorderSizePixel"] = 0;
G2L["4"]["BackgroundTransparency"] = 1;
G2L["4"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["ImageColor3"] = Color3.fromRGB(231, 231, 231);
G2L["4"]["Image"] = [[rbxassetid://105436073524298]];
G2L["4"]["Size"] = UDim2.new(0.04618, 0, 0.08192, 0);
G2L["4"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["4"]["Name"] = [[openTab]];
G2L["4"]["Position"] = UDim2.new(0.00888, 0, 0.01695, 0);
-- Attributes
G2L["4"]:SetAttribute([[_lemonadeUniqueId]], [[6BxpA91t6Bxp]]);


-- StarterGui.Zyrix.main.TextLabel
G2L["5"] = Instance.new("TextLabel", G2L["2"]);
G2L["5"]["BorderSizePixel"] = 0;
G2L["5"]["TextSize"] = 14;
G2L["5"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["5"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["5"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Size"] = UDim2.new(1, 0, -0.00565, 0);
G2L["5"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["5"]["Text"] = [[]];
G2L["5"]["Position"] = UDim2.new(0, 0, 0.10452, 0);
-- Attributes
G2L["5"]:SetAttribute([[_lemonadeUniqueId]], [[gtwrrRRLgtwr]]);


-- StarterGui.Zyrix.main.TextLabel.UIGradient
G2L["6"] = Instance.new("UIGradient", G2L["5"]);
G2L["6"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(0, 0, 0)),ColorSequenceKeypoint.new(0.415, Color3.fromRGB(6, 6, 6)),ColorSequenceKeypoint.new(0.637, Color3.fromRGB(34, 34, 34)),ColorSequenceKeypoint.new(0.780, Color3.fromRGB(50, 50, 50)),ColorSequenceKeypoint.new(0.888, Color3.fromRGB(65, 65, 65)),ColorSequenceKeypoint.new(0.960, Color3.fromRGB(79, 79, 79)),ColorSequenceKeypoint.new(0.995, Color3.fromRGB(98, 98, 98)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(127, 127, 127)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 255, 255))};
-- Attributes
G2L["6"]:SetAttribute([[_lemonadeUniqueId]], [[3KBQ7MLCQZ43]]);


-- StarterGui.Zyrix.main.elements
G2L["7"] = Instance.new("ScrollingFrame", G2L["2"]);
G2L["7"]["Active"] = true;
G2L["7"]["BorderSizePixel"] = 0;
G2L["7"]["Name"] = [[elements]];
G2L["7"]["ScrollBarImageTransparency"] = 0.3;
G2L["7"]["BackgroundColor3"] = Color3.fromRGB(11, 11, 11);
G2L["7"]["Size"] = UDim2.new(0.9698, 0, 0.87853, 0);
G2L["7"]["ScrollBarImageColor3"] = Color3.fromRGB(141, 141, 141);
G2L["7"]["Position"] = UDim2.new(0.00979, 0, 0.10452, 0);
G2L["7"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["7"]["ScrollBarThickness"] = 2;
G2L["7"]["BackgroundTransparency"] = 1;
-- Attributes
G2L["7"]:SetAttribute([[_lemonadeUniqueId]], [[Rad6MzCQRad6]]);


-- StarterGui.Zyrix.main.elements.Dropdown
G2L["8"] = Instance.new("Frame", G2L["7"]);
G2L["8"]["BorderSizePixel"] = 0;
G2L["8"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["8"]["Size"] = UDim2.new(0.38169, 0, 1.00468, 0);
G2L["8"]["Position"] = UDim2.new(0.63159, 0, 0.00187, 0);
G2L["8"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["8"]["Name"] = [[Dropdown]];
-- Attributes
G2L["8"]:SetAttribute([[_lemonadeUniqueId]], [[q0tESgAEq0tE]]);


-- StarterGui.Zyrix.main.elements.Dropdown.Title
G2L["9"] = Instance.new("TextLabel", G2L["8"]);
G2L["9"]["ZIndex"] = 3;
G2L["9"]["BorderSizePixel"] = 0;
G2L["9"]["TextSize"] = 13;
G2L["9"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["9"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["9"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["9"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["9"]["BackgroundTransparency"] = 1;
G2L["9"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["9"]["Size"] = UDim2.new(0.99361, 0, 0.02789, 0);
G2L["9"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["9"]["Text"] = [[Dropdown]];
G2L["9"]["Name"] = [[Title]];
G2L["9"]["Position"] = UDim2.new(0.48939, 0, 0.03386, 0);
-- Attributes
G2L["9"]:SetAttribute([[_lemonadeUniqueId]], [[T1aVgBpjT1aV]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List
G2L["a"] = Instance.new("ScrollingFrame", G2L["8"]);
G2L["a"]["Active"] = true;
G2L["a"]["BorderSizePixel"] = 0;
G2L["a"]["CanvasPosition"] = Vector2.new(0, 200);
G2L["a"]["Name"] = [[List]];
G2L["a"]["ScrollBarImageTransparency"] = 0.7;
G2L["a"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["a"]["AutomaticCanvasSize"] = Enum.AutomaticSize.Y;
G2L["a"]["Size"] = UDim2.new(0.90463, 0, 0.45015, 0);
G2L["a"]["ScrollBarImageColor3"] = Color3.fromRGB(141, 141, 141);
G2L["a"]["Position"] = UDim2.new(0, 0, 0.07569, 0);
G2L["a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["a"]["ScrollBarThickness"] = 2;
G2L["a"]["BackgroundTransparency"] = 1;
-- Attributes
G2L["a"]:SetAttribute([[_lemonadeUniqueId]], [[7rn8V1dF7rn8]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Placeholder
G2L["b"] = Instance.new("Frame", G2L["a"]);
G2L["b"]["BorderSizePixel"] = 0;
G2L["b"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
G2L["b"]["Position"] = UDim2.new(0.39247, 0, 0, 0);
G2L["b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["b"]["Name"] = [[Placeholder]];
G2L["b"]["LayoutOrder"] = -100;
-- Attributes
G2L["b"]:SetAttribute([[_lemonadeUniqueId]], [[qSnThAD5qSnT]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Template
G2L["c"] = Instance.new("Frame", G2L["a"]);
G2L["c"]["BorderSizePixel"] = 0;
G2L["c"]["BackgroundColor3"] = Color3.fromRGB(27, 27, 27);
G2L["c"]["Size"] = UDim2.new(1.02819, 0, 0.10699, 0);
G2L["c"]["Position"] = UDim2.new(-0.0082, 0, 0.00353, 0);
G2L["c"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["c"]["Name"] = [[Template]];
-- Attributes
G2L["c"]:SetAttribute([[_lemonadeUniqueId]], [[lcXPMGaOlcXP]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Template.Title
G2L["d"] = Instance.new("TextLabel", G2L["c"]);
G2L["d"]["BorderSizePixel"] = 0;
G2L["d"]["TextSize"] = 11;
G2L["d"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["d"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["d"]["BackgroundTransparency"] = 1;
G2L["d"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["d"]["Size"] = UDim2.new(1.04226, 0, 0.53675, 0);
G2L["d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["d"]["Text"] = [[Option]];
G2L["d"]["Name"] = [[Title]];
G2L["d"]["Position"] = UDim2.new(0.53226, 0, 0.49281, 0);
-- Attributes
G2L["d"]:SetAttribute([[_lemonadeUniqueId]], [[lRERSqv9lRER]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Template.Interact
G2L["e"] = Instance.new("TextButton", G2L["c"]);
G2L["e"]["BorderSizePixel"] = 0;
G2L["e"]["TextSize"] = 1;
G2L["e"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["e"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["e"]["ZIndex"] = 5;
G2L["e"]["BackgroundTransparency"] = 1;
G2L["e"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["e"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["e"]["Text"] = [[]];
G2L["e"]["Name"] = [[Interact]];
-- Attributes
G2L["e"]:SetAttribute([[_lemonadeUniqueId]], [[cQUdyTBRcQUd]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Template.UIStroke
G2L["f"] = Instance.new("UIStroke", G2L["c"]);
G2L["f"]["Color"] = Color3.fromRGB(51, 51, 51);
G2L["f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["f"]:SetAttribute([[_lemonadeUniqueId]], [[AcMtl7RBAcMt]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.Template.UICorner
G2L["10"] = Instance.new("UICorner", G2L["c"]);
G2L["10"]["CornerRadius"] = UDim.new(0, 4);
-- Attributes
G2L["10"]:SetAttribute([[_lemonadeUniqueId]], [[yNjVS1eQyNjV]]);


-- StarterGui.Zyrix.main.elements.Dropdown.List.UIStroke
G2L["11"] = Instance.new("UIStroke", G2L["a"]);
G2L["11"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["11"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["11"]:SetAttribute([[_lemonadeUniqueId]], [[cWp29WbhcWp2]]);


-- StarterGui.Zyrix.main.elements.Dropdown.Selected
G2L["12"] = Instance.new("TextLabel", G2L["8"]);
G2L["12"]["BorderSizePixel"] = 0;
G2L["12"]["TextSize"] = 12;
G2L["12"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["12"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["12"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["12"]["TextColor3"] = Color3.fromRGB(181, 181, 181);
G2L["12"]["BackgroundTransparency"] = 1;
G2L["12"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["12"]["Size"] = UDim2.new(0.83048, 0, 0.02789, 0);
G2L["12"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["12"]["Text"] = [[Option #1]];
G2L["12"]["Name"] = [[Selected]];
G2L["12"]["Position"] = UDim2.new(0.36581, 0, 0.03386, 0);
-- Attributes
G2L["12"]:SetAttribute([[_lemonadeUniqueId]], [[tGwndS7ttGwn]]);


-- StarterGui.Zyrix.main.elements.Dropdown.Toggle
G2L["13"] = Instance.new("ImageButton", G2L["8"]);
G2L["13"]["BorderSizePixel"] = 0;
G2L["13"]["BackgroundTransparency"] = 1;
G2L["13"]["ImageColor3"] = Color3.fromRGB(161, 161, 161);
G2L["13"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["13"]["Image"] = [[rbxassetid://3926305904]];
G2L["13"]["ImageRectSize"] = Vector2.new(36, 36);
G2L["13"]["Size"] = UDim2.new(0.15819, 0, 0.05577, 0);
G2L["13"]["LayoutOrder"] = 9;
G2L["13"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["13"]["Name"] = [[Toggle]];
G2L["13"]["ImageRectOffset"] = Vector2.new(564, 284);
G2L["13"]["Position"] = UDim2.new(0.86014, 0, 0.03386, 0);
-- Attributes
G2L["13"]:SetAttribute([[_lemonadeUniqueId]], [[UM2wa4rtUM2w]]);


-- StarterGui.Zyrix.main.elements.Dropdown.Interact
G2L["14"] = Instance.new("TextButton", G2L["8"]);
G2L["14"]["BorderSizePixel"] = 0;
G2L["14"]["TextTransparency"] = 1;
G2L["14"]["TextSize"] = 12;
G2L["14"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["14"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["14"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["14"]["ZIndex"] = 5;
G2L["14"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["14"]["BackgroundTransparency"] = 1;
G2L["14"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["14"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["14"]["Text"] = [[]];
G2L["14"]["Name"] = [[Interact]];
G2L["14"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
-- Attributes
G2L["14"]:SetAttribute([[_lemonadeUniqueId]], [[2J80AtTZ2J80]]);


-- StarterGui.Zyrix.main.elements.Dropdown.UIStroke
G2L["15"] = Instance.new("UIStroke", G2L["8"]);
G2L["15"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["15"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["15"]:SetAttribute([[_lemonadeUniqueId]], [[QM0XKrR7QM0X]]);


-- StarterGui.Zyrix.main.elements.Dropdown.UIPadding
G2L["16"] = Instance.new("UIPadding", G2L["8"]);
G2L["16"]["PaddingTop"] = UDim.new(0, 8);
G2L["16"]["PaddingRight"] = UDim.new(0, 10);
G2L["16"]["PaddingLeft"] = UDim.new(0, 10);
G2L["16"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["16"]:SetAttribute([[_lemonadeUniqueId]], [[qy7KWpFlqy7K]]);


-- StarterGui.Zyrix.main.elements.Button
G2L["17"] = Instance.new("Frame", G2L["7"]);
G2L["17"]["BorderSizePixel"] = 0;
G2L["17"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["17"]["Size"] = UDim2.new(0.58737, 0, 0.0535, 0);
G2L["17"]["Position"] = UDim2.new(0, 0, 0.00187, 0);
G2L["17"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["17"]["Name"] = [[Button]];
-- Attributes
G2L["17"]:SetAttribute([[_lemonadeUniqueId]], [[4zFJ0zMI4zFJ]]);


-- StarterGui.Zyrix.main.elements.Button.UIStroke
G2L["18"] = Instance.new("UIStroke", G2L["17"]);
G2L["18"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["18"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["18"]:SetAttribute([[_lemonadeUniqueId]], [[xvHUqI4wxvHU]]);


-- StarterGui.Zyrix.main.elements.Button.Title
G2L["19"] = Instance.new("TextLabel", G2L["17"]);
G2L["19"]["BorderSizePixel"] = 0;
G2L["19"]["TextSize"] = 13;
G2L["19"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["19"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["19"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["19"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["19"]["BackgroundTransparency"] = 1;
G2L["19"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["19"]["Size"] = UDim2.new(0.98617, 0, 0.19897, 0);
G2L["19"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["19"]["Text"] = [[Reset Aimbot System]];
G2L["19"]["Name"] = [[Title]];
G2L["19"]["Position"] = UDim2.new(0.50604, 0, 0.47561, 0);
-- Attributes
G2L["19"]:SetAttribute([[_lemonadeUniqueId]], [[BpaQhYyABpaQ]]);


-- StarterGui.Zyrix.main.elements.Button.ElementIndicator
G2L["1a"] = Instance.new("TextLabel", G2L["17"]);
G2L["1a"]["BorderSizePixel"] = 0;
G2L["1a"]["TextSize"] = 11;
G2L["1a"]["TextXAlignment"] = Enum.TextXAlignment.Right;
G2L["1a"]["TextTransparency"] = 0.5;
G2L["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["1a"]["TextColor3"] = Color3.fromRGB(131, 131, 131);
G2L["1a"]["BackgroundTransparency"] = 1;
G2L["1a"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1a"]["Size"] = UDim2.new(0.34693, 0, 0.18476, 0);
G2L["1a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["1a"]["Text"] = [[Button]];
G2L["1a"]["Name"] = [[ElementIndicator]];
G2L["1a"]["Position"] = UDim2.new(0.77168, 0, 0.47561, 0);
-- Attributes
G2L["1a"]:SetAttribute([[_lemonadeUniqueId]], [[1cDN22F31cDN]]);


-- StarterGui.Zyrix.main.elements.Button.Interact
G2L["1b"] = Instance.new("TextButton", G2L["17"]);
G2L["1b"]["BorderSizePixel"] = 0;
G2L["1b"]["TextTransparency"] = 1;
G2L["1b"]["TextSize"] = 12;
G2L["1b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["1b"]["ZIndex"] = 5;
G2L["1b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1b"]["BackgroundTransparency"] = 1;
G2L["1b"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["1b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["1b"]["Text"] = [[]];
G2L["1b"]["Name"] = [[Interact]];
G2L["1b"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
-- Attributes
G2L["1b"]:SetAttribute([[_lemonadeUniqueId]], [[0NBNWxJD0NBN]]);


-- StarterGui.Zyrix.main.elements.Button.UIPadding
G2L["1c"] = Instance.new("UIPadding", G2L["17"]);
G2L["1c"]["PaddingTop"] = UDim.new(0, 8);
G2L["1c"]["PaddingRight"] = UDim.new(0, 10);
G2L["1c"]["PaddingLeft"] = UDim.new(0, 10);
G2L["1c"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["1c"]:SetAttribute([[_lemonadeUniqueId]], [[clDflSAsclDf]]);


-- StarterGui.Zyrix.main.elements.Slider
G2L["1d"] = Instance.new("Frame", G2L["7"]);
G2L["1d"]["BorderSizePixel"] = 0;
G2L["1d"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["1d"]["Size"] = UDim2.new(0.58737, 0, 0.06442, 0);
G2L["1d"]["Position"] = UDim2.new(0, 0, 0.05505, 0);
G2L["1d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["1d"]["Name"] = [[Slider]];
-- Attributes
G2L["1d"]:SetAttribute([[_lemonadeUniqueId]], [[0qoDSnqI0qoD]]);


-- StarterGui.Zyrix.main.elements.Slider.Title
G2L["1e"] = Instance.new("TextLabel", G2L["1d"]);
G2L["1e"]["BorderSizePixel"] = 0;
G2L["1e"]["TextSize"] = 13;
G2L["1e"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["1e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["1e"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["1e"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["1e"]["BackgroundTransparency"] = 1;
G2L["1e"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1e"]["Size"] = UDim2.new(0.64246, 0, 0.1479, 0);
G2L["1e"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["1e"]["Text"] = [[ESP Range]];
G2L["1e"]["Name"] = [[Title]];
G2L["1e"]["Position"] = UDim2.new(0.32525, 0, 0.5, 0);
-- Attributes
G2L["1e"]:SetAttribute([[_lemonadeUniqueId]], [[YNpaKHuSYNpa]]);


-- StarterGui.Zyrix.main.elements.Slider.Main
G2L["1f"] = Instance.new("Frame", G2L["1d"]);
G2L["1f"]["BorderSizePixel"] = 0;
G2L["1f"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["1f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["1f"]["Size"] = UDim2.new(0.71313, 0, 0.70378, 0);
G2L["1f"]["Position"] = UDim2.new(0.65419, 0, 0.5, 0);
G2L["1f"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["1f"]["Name"] = [[Main]];
-- Attributes
G2L["1f"]:SetAttribute([[_lemonadeUniqueId]], [[tPS8XST3tPS8]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.UIStroke
G2L["20"] = Instance.new("UIStroke", G2L["1f"]);
G2L["20"]["Transparency"] = 0.2;
G2L["20"]["Color"] = Color3.fromRGB(51, 51, 51);
G2L["20"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["20"]:SetAttribute([[_lemonadeUniqueId]], [[2Y9MNnBV2Y9M]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.Progress
G2L["21"] = Instance.new("Frame", G2L["1f"]);
G2L["21"]["BorderSizePixel"] = 0;
G2L["21"]["BackgroundColor3"] = Color3.fromRGB(201, 201, 201);
G2L["21"]["Size"] = UDim2.new(0.80097, 0, 1, 0);
G2L["21"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["21"]["Name"] = [[Progress]];
-- Attributes
G2L["21"]:SetAttribute([[_lemonadeUniqueId]], [[FPtYg3WqFPtY]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.Progress.UIStroke
G2L["22"] = Instance.new("UIStroke", G2L["21"]);
G2L["22"]["Transparency"] = 0.2;
G2L["22"]["Thickness"] = 0.5;
G2L["22"]["Color"] = Color3.fromRGB(51, 51, 51);
-- Attributes
G2L["22"]:SetAttribute([[_lemonadeUniqueId]], [[QgK1hU39QgK1]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.Progress.UICorner
G2L["23"] = Instance.new("UICorner", G2L["21"]);

-- Attributes
G2L["23"]:SetAttribute([[_lemonadeUniqueId]], [[NAbpCmsqNAbp]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.Information
G2L["24"] = Instance.new("TextLabel", G2L["1f"]);
G2L["24"]["ZIndex"] = 5;
G2L["24"]["BorderSizePixel"] = 0;
G2L["24"]["TextSize"] = 11;
G2L["24"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["24"]["TextTransparency"] = 0.3;
G2L["24"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["24"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["24"]["TextColor3"] = Color3.fromRGB(131, 131, 131);
G2L["24"]["BackgroundTransparency"] = 1;
G2L["24"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["24"]["Size"] = UDim2.new(0.80871, 0, 0.57259, 0);
G2L["24"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["24"]["Text"] = [[750 studs]];
G2L["24"]["Name"] = [[Information]];
G2L["24"]["Position"] = UDim2.new(0.4536, 0, 0.5, 0);
-- Attributes
G2L["24"]:SetAttribute([[_lemonadeUniqueId]], [[GVOZyIT1GVOZ]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.Interact
G2L["25"] = Instance.new("TextButton", G2L["1f"]);
G2L["25"]["BorderSizePixel"] = 0;
G2L["25"]["TextSize"] = 14;
G2L["25"]["TextColor3"] = Color3.fromRGB(0, 0, 0);
G2L["25"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["25"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Normal);
G2L["25"]["ZIndex"] = 10;
G2L["25"]["BackgroundTransparency"] = 1;
G2L["25"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["25"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["25"]["Text"] = [[]];
G2L["25"]["Name"] = [[Interact]];
-- Attributes
G2L["25"]:SetAttribute([[_lemonadeUniqueId]], [[cYvwFsdbcYvw]]);


-- StarterGui.Zyrix.main.elements.Slider.Main.UICorner
G2L["26"] = Instance.new("UICorner", G2L["1f"]);
G2L["26"]["CornerRadius"] = UDim.new(0, 4);
-- Attributes
G2L["26"]:SetAttribute([[_lemonadeUniqueId]], [[6WuNRXEa6WuN]]);


-- StarterGui.Zyrix.main.elements.Slider.UIStroke
G2L["27"] = Instance.new("UIStroke", G2L["1d"]);
G2L["27"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["27"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["27"]:SetAttribute([[_lemonadeUniqueId]], [[Gt8eL1zBGt8e]]);


-- StarterGui.Zyrix.main.elements.Slider.UIPadding
G2L["28"] = Instance.new("UIPadding", G2L["1d"]);
G2L["28"]["PaddingTop"] = UDim.new(0, 8);
G2L["28"]["PaddingRight"] = UDim.new(0, 10);
G2L["28"]["PaddingLeft"] = UDim.new(0, 10);
G2L["28"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["28"]:SetAttribute([[_lemonadeUniqueId]], [[jqZtHlHBjqZt]]);


-- StarterGui.Zyrix.main.elements.Toggle
G2L["29"] = Instance.new("Frame", G2L["7"]);
G2L["29"]["BorderSizePixel"] = 0;
G2L["29"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["29"]["Size"] = UDim2.new(0.58737, 0, 0.05402, 0);
G2L["29"]["Position"] = UDim2.new(-0, 0, 0.11702, 0);
G2L["29"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["29"]["Name"] = [[Toggle]];
-- Attributes
G2L["29"]:SetAttribute([[_lemonadeUniqueId]], [[mrwCDpCMmrwC]]);


-- StarterGui.Zyrix.main.elements.Toggle.Title
G2L["2a"] = Instance.new("TextLabel", G2L["29"]);
G2L["2a"]["BorderSizePixel"] = 0;
G2L["2a"]["TextSize"] = 13;
G2L["2a"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["2a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2a"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["2a"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["2a"]["BackgroundTransparency"] = 1;
G2L["2a"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2a"]["Size"] = UDim2.new(0.80307, 0, 0.18614, 0);
G2L["2a"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["2a"]["Text"] = [[Aimbot]];
G2L["2a"]["Name"] = [[Title]];
G2L["2a"]["Position"] = UDim2.new(0.80346, 0, 0.46816, 0);
-- Attributes
G2L["2a"]:SetAttribute([[_lemonadeUniqueId]], [[ZAxaOvJzZAxa]]);


-- StarterGui.Zyrix.main.elements.Toggle.Interact
G2L["2b"] = Instance.new("TextButton", G2L["29"]);
G2L["2b"]["BorderSizePixel"] = 0;
G2L["2b"]["TextTransparency"] = 1;
G2L["2b"]["TextSize"] = 12;
G2L["2b"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["2b"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["2b"]["ZIndex"] = 5;
G2L["2b"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["2b"]["BackgroundTransparency"] = 1;
G2L["2b"]["Size"] = UDim2.new(0.36935, 0, 1, 0);
G2L["2b"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["2b"]["Text"] = [[]];
G2L["2b"]["Name"] = [[Interact]];
G2L["2b"]["Position"] = UDim2.new(0.81532, 0, 0.5, 0);
-- Attributes
G2L["2b"]:SetAttribute([[_lemonadeUniqueId]], [[9AihP2Ys9Aih]]);


-- StarterGui.Zyrix.main.elements.Toggle.Switch
G2L["2c"] = Instance.new("Frame", G2L["29"]);
G2L["2c"]["BorderSizePixel"] = 0;
G2L["2c"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["2c"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["2c"]["Size"] = UDim2.new(0.1768, 0, 0.87772, 0);
G2L["2c"]["Position"] = UDim2.new(1.01129, 0, 0.46126, 0);
G2L["2c"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["2c"]["Name"] = [[Switch]];
-- Attributes
G2L["2c"]:SetAttribute([[_lemonadeUniqueId]], [[lUrA34QelUrA]]);


-- StarterGui.Zyrix.main.elements.Toggle.Switch.Indicator
G2L["2d"] = Instance.new("Frame", G2L["2c"]);
G2L["2d"]["BorderSizePixel"] = 0;
G2L["2d"]["BackgroundColor3"] = Color3.fromRGB(201, 201, 201);
G2L["2d"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["2d"]["Size"] = UDim2.new(0.42249, 0, 0.9632, 0);
G2L["2d"]["Position"] = UDim2.new(0.0059, 0, 0.5, 0);
G2L["2d"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["2d"]["Name"] = [[Indicator]];
-- Attributes
G2L["2d"]:SetAttribute([[_lemonadeUniqueId]], [[hWcZIjHJhWcZ]]);


-- StarterGui.Zyrix.main.elements.Toggle.Switch.Indicator.UIStroke
G2L["2e"] = Instance.new("UIStroke", G2L["2d"]);
G2L["2e"]["Thickness"] = 0.5;
G2L["2e"]["Color"] = Color3.fromRGB(61, 61, 61);
-- Attributes
G2L["2e"]:SetAttribute([[_lemonadeUniqueId]], [[jV8NPv4wjV8N]]);


-- StarterGui.Zyrix.main.elements.Toggle.Switch.UIStroke
G2L["2f"] = Instance.new("UIStroke", G2L["2c"]);
G2L["2f"]["Color"] = Color3.fromRGB(51, 51, 51);
G2L["2f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["2f"]:SetAttribute([[_lemonadeUniqueId]], [[oa9UAC7noa9U]]);


-- StarterGui.Zyrix.main.elements.Toggle.UIStroke
G2L["30"] = Instance.new("UIStroke", G2L["29"]);
G2L["30"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["30"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["30"]:SetAttribute([[_lemonadeUniqueId]], [[lVdMOI9dlVdM]]);


-- StarterGui.Zyrix.main.elements.Toggle.UIPadding
G2L["31"] = Instance.new("UIPadding", G2L["29"]);
G2L["31"]["PaddingTop"] = UDim.new(0, 8);
G2L["31"]["PaddingRight"] = UDim.new(0, 10);
G2L["31"]["PaddingLeft"] = UDim.new(0, 10);
G2L["31"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["31"]:SetAttribute([[_lemonadeUniqueId]], [[pzaGKGxLpzaG]]);


-- StarterGui.Zyrix.main.elements.Keybind
G2L["32"] = Instance.new("Frame", G2L["7"]);
G2L["32"]["BorderSizePixel"] = 0;
G2L["32"]["BackgroundColor3"] = Color3.fromRGB(23, 23, 23);
G2L["32"]["Size"] = UDim2.new(0.58644, 0, 0.04679, 0);
G2L["32"]["Position"] = UDim2.new(0.00092, 0, 0.17129, 0);
G2L["32"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["32"]["Name"] = [[Keybind]];
-- Attributes
G2L["32"]:SetAttribute([[_lemonadeUniqueId]], [[gNN2k4TxgNN2]]);


-- StarterGui.Zyrix.main.elements.Keybind.Title
G2L["33"] = Instance.new("TextLabel", G2L["32"]);
G2L["33"]["BorderSizePixel"] = 0;
G2L["33"]["TextSize"] = 13;
G2L["33"]["TextXAlignment"] = Enum.TextXAlignment.Left;
G2L["33"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["33"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["33"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["33"]["BackgroundTransparency"] = 1;
G2L["33"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["33"]["Size"] = UDim2.new(0.63935, 0, 0.1815, 0);
G2L["33"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["33"]["Text"] = [[Target Keybind]];
G2L["33"]["Name"] = [[Title]];
G2L["33"]["Position"] = UDim2.new(0.31842, 0, 0.5, 0);
-- Attributes
G2L["33"]:SetAttribute([[_lemonadeUniqueId]], [[xFxRyz6wxFxR]]);


-- StarterGui.Zyrix.main.elements.Keybind.KeybindFrame
G2L["34"] = Instance.new("Frame", G2L["32"]);
G2L["34"]["BorderSizePixel"] = 0;
G2L["34"]["BackgroundColor3"] = Color3.fromRGB(31, 31, 31);
G2L["34"]["AnchorPoint"] = Vector2.new(1, 0.5);
G2L["34"]["Size"] = UDim2.new(0.10436, 0, 1.19994, 0);
G2L["34"]["Position"] = UDim2.new(1.01366, 0, 0.47826, 0);
G2L["34"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["34"]["Name"] = [[KeybindFrame]];
-- Attributes
G2L["34"]:SetAttribute([[_lemonadeUniqueId]], [[T8TRKl3BT8TR]]);


-- StarterGui.Zyrix.main.elements.Keybind.KeybindFrame.KeybindBox
G2L["35"] = Instance.new("TextBox", G2L["34"]);
G2L["35"]["Name"] = [[KeybindBox]];
G2L["35"]["PlaceholderColor3"] = Color3.fromRGB(179, 179, 179);
G2L["35"]["BorderSizePixel"] = 0;
G2L["35"]["TextSize"] = 12;
G2L["35"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["35"]["BackgroundColor3"] = Color3.fromRGB(9, 9, 9);
G2L["35"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Medium, Enum.FontStyle.Normal);
G2L["35"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
G2L["35"]["ClearTextOnFocus"] = false;
G2L["35"]["PlaceholderText"] = [[Keybind]];
G2L["35"]["Size"] = UDim2.new(0.30328, 0, 0.78949, 0);
G2L["35"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);
G2L["35"]["BorderColor3"] = Color3.fromRGB(28, 43, 54);
G2L["35"]["Text"] = [[Q]];
G2L["35"]["BackgroundTransparency"] = 1;
-- Attributes
G2L["35"]:SetAttribute([[_lemonadeUniqueId]], [[VA6n2ijTVA6n]]);


-- StarterGui.Zyrix.main.elements.Keybind.KeybindFrame.UIStroke
G2L["36"] = Instance.new("UIStroke", G2L["34"]);
G2L["36"]["Color"] = Color3.fromRGB(51, 51, 51);
G2L["36"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["36"]:SetAttribute([[_lemonadeUniqueId]], [[lgYJfpvnlgYJ]]);


-- StarterGui.Zyrix.main.elements.Keybind.UIStroke
G2L["37"] = Instance.new("UIStroke", G2L["32"]);
G2L["37"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["37"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["37"]:SetAttribute([[_lemonadeUniqueId]], [[d64IPcHzd64I]]);


-- StarterGui.Zyrix.main.elements.Keybind.UIPadding
G2L["38"] = Instance.new("UIPadding", G2L["32"]);
G2L["38"]["PaddingTop"] = UDim.new(0, 8);
G2L["38"]["PaddingRight"] = UDim.new(0, 10);
G2L["38"]["PaddingLeft"] = UDim.new(0, 10);
G2L["38"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["38"]:SetAttribute([[_lemonadeUniqueId]], [[lOzoTziqlOzo]]);


-- StarterGui.Zyrix.main.elements.UIPadding
G2L["39"] = Instance.new("UIPadding", G2L["7"]);
G2L["39"]["PaddingTop"] = UDim.new(0, 8);
G2L["39"]["PaddingRight"] = UDim.new(0, 5);
G2L["39"]["PaddingLeft"] = UDim.new(0, 5);
G2L["39"]["PaddingBottom"] = UDim.new(0, 8);
-- Attributes
G2L["39"]:SetAttribute([[_lemonadeUniqueId]], [[dpiwLH7vdpiw]]);


-- StarterGui.Zyrix.main.UIStroke
G2L["3a"] = Instance.new("UIStroke", G2L["2"]);
G2L["3a"]["Color"] = Color3.fromRGB(46, 46, 46);
G2L["3a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["3a"]:SetAttribute([[_lemonadeUniqueId]], [[dDTtG4LddDTt]]);


-- StarterGui.Zyrix.main.UICorner
G2L["3b"] = Instance.new("UICorner", G2L["2"]);
G2L["3b"]["CornerRadius"] = UDim.new(0, 10);
-- Attributes
G2L["3b"]:SetAttribute([[_lemonadeUniqueId]], [[5v778nsk5v77]]);


-- StarterGui.Zyrix.main.UIGradient
G2L["3c"] = Instance.new("UIGradient", G2L["2"]);
G2L["3c"]["Rotation"] = 90;
G2L["3c"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(19, 19, 19)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(26, 26, 26))};
-- Attributes
G2L["3c"]:SetAttribute([[_lemonadeUniqueId]], [[KBKNOTDPU4JA]]);


-- StarterGui.Zyrix.main.UISizeConstraint
G2L["3d"] = Instance.new("UISizeConstraint", G2L["2"]);
G2L["3d"]["MinSize"] = Vector2.new(280, 220);
G2L["3d"]["MaxSize"] = Vector2.new(700, 500);


-- StarterGui.Zyrix.Frame
G2L["3e"] = Instance.new("Frame", G2L["1"]);
G2L["3e"]["BorderSizePixel"] = 0;
G2L["3e"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3e"]["Size"] = UDim2.new(0.39696, 0, 0.05549, 0);
G2L["3e"]["Position"] = UDim2.new(0.29841, 0, 0.20243, 0);
G2L["3e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
-- Attributes
G2L["3e"]:SetAttribute([[_lemonadeUniqueId]], [[fVKogxuwfVKo]]);


-- StarterGui.Zyrix.Frame.tablist
G2L["3f"] = Instance.new("ScrollingFrame", G2L["3e"]);
G2L["3f"]["Active"] = true;
G2L["3f"]["ScrollingDirection"] = Enum.ScrollingDirection.X;
G2L["3f"]["BorderSizePixel"] = 0;
G2L["3f"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
G2L["3f"]["VerticalScrollBarInset"] = Enum.ScrollBarInset.Always;
G2L["3f"]["ElasticBehavior"] = Enum.ElasticBehavior.Always;
G2L["3f"]["Name"] = [[tablist]];
G2L["3f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
G2L["3f"]["AutomaticCanvasSize"] = Enum.AutomaticSize.X;
G2L["3f"]["Size"] = UDim2.new(1, 0, 1, 0);
G2L["3f"]["ScrollBarImageColor3"] = Color3.fromRGB(141, 141, 141);
G2L["3f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
G2L["3f"]["ScrollBarThickness"] = 0;
G2L["3f"]["BackgroundTransparency"] = 1;
-- Attributes
G2L["3f"]:SetAttribute([[_lemonadeUniqueId]], [[erzgooPHerzg]]);


-- StarterGui.Zyrix.Frame.tablist.UIListLayout
G2L["40"] = Instance.new("UIListLayout", G2L["3f"]);
G2L["40"]["Padding"] = UDim.new(0, 6);
G2L["40"]["VerticalAlignment"] = Enum.VerticalAlignment.Center;
G2L["40"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
G2L["40"]["FillDirection"] = Enum.FillDirection.Horizontal;


-- StarterGui.Zyrix.Frame.tablist.UIPadding
G2L["41"] = Instance.new("UIPadding", G2L["3f"]);
G2L["41"]["PaddingTop"] = UDim.new(0, 5);
G2L["41"]["PaddingRight"] = UDim.new(0, 5);
G2L["41"]["PaddingLeft"] = UDim.new(0, 5);
G2L["41"]["PaddingBottom"] = UDim.new(0, 5);


-- StarterGui.Zyrix.Frame.tablist.Combat
G2L["42"] = Instance.new("TextButton", G2L["3f"]);
G2L["42"]["BorderSizePixel"] = 0;
G2L["42"]["TextSize"] = 12;
G2L["42"]["AutoButtonColor"] = false;
G2L["42"]["TextColor3"] = Color3.fromRGB(255, 255, 255);
G2L["42"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["42"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["42"]["Size"] = UDim2.new(0.13, 0, 0.98, 0);
G2L["42"]["LayoutOrder"] = 1;
G2L["42"]["Text"] = [[Combat]];
G2L["42"]["Name"] = [[Combat]];


-- StarterGui.Zyrix.Frame.tablist.Combat.UICorner
G2L["43"] = Instance.new("UICorner", G2L["42"]);
G2L["43"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.Frame.tablist.Combat.UIPadding
G2L["44"] = Instance.new("UIPadding", G2L["42"]);
G2L["44"]["PaddingTop"] = UDim.new(0, 6);
G2L["44"]["PaddingRight"] = UDim.new(0, 14);
G2L["44"]["PaddingLeft"] = UDim.new(0, 14);
G2L["44"]["PaddingBottom"] = UDim.new(0, 6);


-- StarterGui.Zyrix.Frame.tablist.Combat.ActiveIndicator
G2L["45"] = Instance.new("Frame", G2L["42"]);
G2L["45"]["BorderSizePixel"] = 0;
G2L["45"]["BackgroundColor3"] = Color3.fromRGB(68, 68, 68);
G2L["45"]["Size"] = UDim2.new(0.5, 0, 0, 2);
G2L["45"]["Position"] = UDim2.new(0.25, 0, 1, -3);
G2L["45"]["Name"] = [[ActiveIndicator]];


-- StarterGui.Zyrix.Frame.tablist.Combat.ActiveIndicator.UICorner
G2L["46"] = Instance.new("UICorner", G2L["45"]);
G2L["46"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.Frame.tablist.Combat.UIStroke
G2L["47"] = Instance.new("UIStroke", G2L["42"]);
G2L["47"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["47"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


-- StarterGui.Zyrix.Frame.tablist.Visuals
G2L["48"] = Instance.new("TextButton", G2L["3f"]);
G2L["48"]["BorderSizePixel"] = 0;
G2L["48"]["TextSize"] = 12;
G2L["48"]["AutoButtonColor"] = false;
G2L["48"]["TextColor3"] = Color3.fromRGB(141, 141, 141);
G2L["48"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["48"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["48"]["BackgroundTransparency"] = 0.4;
G2L["48"]["Size"] = UDim2.new(0.13, 0, 0.98, 0);
G2L["48"]["LayoutOrder"] = 2;
G2L["48"]["Text"] = [[Visuals]];
G2L["48"]["Name"] = [[Visuals]];


-- StarterGui.Zyrix.Frame.tablist.Visuals.UICorner
G2L["49"] = Instance.new("UICorner", G2L["48"]);
G2L["49"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.Frame.tablist.Visuals.UIPadding
G2L["4a"] = Instance.new("UIPadding", G2L["48"]);
G2L["4a"]["PaddingTop"] = UDim.new(0, 6);
G2L["4a"]["PaddingRight"] = UDim.new(0, 14);
G2L["4a"]["PaddingLeft"] = UDim.new(0, 14);
G2L["4a"]["PaddingBottom"] = UDim.new(0, 6);


-- StarterGui.Zyrix.Frame.tablist.Visuals.UIStroke
G2L["4b"] = Instance.new("UIStroke", G2L["48"]);
G2L["4b"]["Thickness"] = 0.8;
G2L["4b"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["4b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


-- StarterGui.Zyrix.Frame.tablist.Movement
G2L["4c"] = Instance.new("TextButton", G2L["3f"]);
G2L["4c"]["BorderSizePixel"] = 0;
G2L["4c"]["TextSize"] = 12;
G2L["4c"]["AutoButtonColor"] = false;
G2L["4c"]["TextColor3"] = Color3.fromRGB(141, 141, 141);
G2L["4c"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["4c"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["4c"]["BackgroundTransparency"] = 0.4;
G2L["4c"]["Size"] = UDim2.new(0.13, 0, 0.98, 0);
G2L["4c"]["LayoutOrder"] = 3;
G2L["4c"]["Text"] = [[Movement]];
G2L["4c"]["Name"] = [[Movement]];


-- StarterGui.Zyrix.Frame.tablist.Movement.UICorner
G2L["4d"] = Instance.new("UICorner", G2L["4c"]);
G2L["4d"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.Frame.tablist.Movement.UIPadding
G2L["4e"] = Instance.new("UIPadding", G2L["4c"]);
G2L["4e"]["PaddingTop"] = UDim.new(0, 6);
G2L["4e"]["PaddingRight"] = UDim.new(0, 14);
G2L["4e"]["PaddingLeft"] = UDim.new(0, 14);
G2L["4e"]["PaddingBottom"] = UDim.new(0, 6);


-- StarterGui.Zyrix.Frame.tablist.Movement.UIStroke
G2L["4f"] = Instance.new("UIStroke", G2L["4c"]);
G2L["4f"]["Thickness"] = 0.8;
G2L["4f"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["4f"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


-- StarterGui.Zyrix.Frame.tablist.Misc
G2L["50"] = Instance.new("TextButton", G2L["3f"]);
G2L["50"]["BorderSizePixel"] = 0;
G2L["50"]["TextSize"] = 12;
G2L["50"]["AutoButtonColor"] = false;
G2L["50"]["TextColor3"] = Color3.fromRGB(141, 141, 141);
G2L["50"]["BackgroundColor3"] = Color3.fromRGB(19, 19, 19);
G2L["50"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["50"]["BackgroundTransparency"] = 0.4;
G2L["50"]["Size"] = UDim2.new(0.13, 0, 0.98, 0);
G2L["50"]["LayoutOrder"] = 4;
G2L["50"]["Text"] = [[Misc]];
G2L["50"]["Name"] = [[Misc]];


-- StarterGui.Zyrix.Frame.tablist.Misc.UICorner
G2L["51"] = Instance.new("UICorner", G2L["50"]);
G2L["51"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.Frame.tablist.Misc.UIPadding
G2L["52"] = Instance.new("UIPadding", G2L["50"]);
G2L["52"]["PaddingTop"] = UDim.new(0, 6);
G2L["52"]["PaddingRight"] = UDim.new(0, 14);
G2L["52"]["PaddingLeft"] = UDim.new(0, 14);
G2L["52"]["PaddingBottom"] = UDim.new(0, 6);


-- StarterGui.Zyrix.Frame.tablist.Misc.UIStroke
G2L["53"] = Instance.new("UIStroke", G2L["50"]);
G2L["53"]["Thickness"] = 0.8;
G2L["53"]["Color"] = Color3.fromRGB(41, 41, 41);
G2L["53"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;


-- StarterGui.Zyrix.Frame.tablist.ScrollHandler
G2L["54"] = Instance.new("LocalScript", G2L["3f"]);
G2L["54"]["Name"] = [[ScrollHandler]];


-- StarterGui.Zyrix.Frame.UIStroke
G2L["55"] = Instance.new("UIStroke", G2L["3e"]);
G2L["55"]["Color"] = Color3.fromRGB(46, 46, 46);
G2L["55"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["55"]:SetAttribute([[_lemonadeUniqueId]], [[XhC4OKHnXhC4]]);


-- StarterGui.Zyrix.Frame.UICorner
G2L["56"] = Instance.new("UICorner", G2L["3e"]);
G2L["56"]["CornerRadius"] = UDim.new(0, 1000);
-- Attributes
G2L["56"]:SetAttribute([[_lemonadeUniqueId]], [[H3nALmrRH3nA]]);


-- StarterGui.Zyrix.Frame.UIGradient
G2L["57"] = Instance.new("UIGradient", G2L["3e"]);
G2L["57"]["Rotation"] = 90;
G2L["57"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(19, 19, 19)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 29, 29))};
-- Attributes
G2L["57"]:SetAttribute([[_lemonadeUniqueId]], [[WB6W5VPNLHWF]]);


-- StarterGui.Zyrix.ToggleUI
G2L["58"] = Instance.new("TextButton", G2L["1"]);
G2L["58"]["TextWrapped"] = true;
G2L["58"]["BorderSizePixel"] = 0;
G2L["58"]["TextSize"] = 17;
G2L["58"]["AutoButtonColor"] = false;
G2L["58"]["TextScaled"] = true;
G2L["58"]["TextColor3"] = Color3.fromRGB(231, 231, 231);
G2L["58"]["BackgroundColor3"] = Color3.fromRGB(0, 0, 0);
G2L["58"]["FontFace"] = Font.new([[rbxasset://fonts/families/GothamSSm.json]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
G2L["58"]["ZIndex"] = 10;
G2L["58"]["AnchorPoint"] = Vector2.new(0, 0.5);
G2L["58"]["BackgroundTransparency"] = 0.5;
G2L["58"]["Size"] = UDim2.new(0, 44, 0, 44);
G2L["58"]["Text"] = [[OPEN]];
G2L["58"]["Name"] = [[ToggleUI]];
G2L["58"]["Position"] = UDim2.new(0.96947, 0, 0.03846, 0);


-- StarterGui.Zyrix.ToggleUI.UICorner
G2L["59"] = Instance.new("UICorner", G2L["58"]);
G2L["59"]["CornerRadius"] = UDim.new(0, 1000);


-- StarterGui.Zyrix.ToggleUI.UIStroke
G2L["5a"] = Instance.new("UIStroke", G2L["58"]);
G2L["5a"]["Color"] = Color3.fromRGB(41, 41, 41);


-- StarterGui.Zyrix.ToggleUI.ToggleScript
G2L["5b"] = Instance.new("LocalScript", G2L["58"]);
G2L["5b"]["Name"] = [[ToggleScript]];


-- StarterGui.Zyrix.ToggleUI.UIStroke
G2L["5c"] = Instance.new("UIStroke", G2L["58"]);
G2L["5c"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
-- Attributes
G2L["5c"]:SetAttribute([[_lemonadeUniqueId]], [[d64IPcHzd64I]]);


-- StarterGui.Zyrix.Frame.tablist.ScrollHandler
local function C_54()
local script = G2L["54"];
	local tablist = script.Parent
	local zyrix = tablist.Parent.Parent
	local userInputService = game:GetService("UserInputService")
	
	------------------------------------------------------
	-- TAB LIST SCROLL (mouse wheel -> horizontal scroll)
	------------------------------------------------------
	local isHovering = false
	
	tablist.MouseEnter:Connect(function()
		isHovering = true
	end)
	
	tablist.MouseLeave:Connect(function()
		isHovering = false
	end)
	
	userInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseWheel and isHovering then
			local scrollDelta = input.Position.Z
			local scrollAmount = scrollDelta * 60
	
			local canvasWidth = tablist.CanvasSize.X.Offset
			local viewWidth = tablist.AbsoluteSize.X
			local maxScroll = math.max(0, canvasWidth - viewWidth)
	
			local newPos = math.clamp(tablist.CanvasPosition.X - scrollAmount, 0, maxScroll)
			tablist.CanvasPosition = Vector2.new(newPos, 0)
		end
	end)
	
	------------------------------------------------------
	-- AUTO-SCALE: adjusts text sizes based on screen size
	------------------------------------------------------
	-- Reference design was made for ~1920x1080 viewport.
	-- We scale text proportionally so it stays readable on any device.
	
	local REFERENCE_WIDTH = 1920
	local REFERENCE_HEIGHT = 1080
	
	-- Original text sizes at reference resolution
	local originalTextSizes = {}
	
	local function collectTextSizes()
		for _, desc in zyrix:GetDescendants() do
			if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
				if not originalTextSizes[desc] then
					originalTextSizes[desc] = desc.TextSize
				end
			end
		end
	end
	
	local function updateScale()
		local viewport = workspace.CurrentCamera.ViewportSize
		-- Use the smaller dimension ratio so nothing gets too big
		local scaleX = viewport.X / REFERENCE_WIDTH
		local scaleY = viewport.Y / REFERENCE_HEIGHT
		local scale = math.min(scaleX, scaleY)
	
		for obj, originalSize in originalTextSizes do
			if obj and obj.Parent then
				local newSize = math.clamp(math.round(originalSize * scale), 8, originalSize)
				obj.TextSize = newSize
			end
		end
	end
	
	collectTextSizes()
	updateScale()
	
	-- Re-apply when viewport resizes (device rotation, different screen)
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	
	-- Handle new text elements added later
	zyrix.DescendantAdded:Connect(function(desc)
		if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
			task.defer(function()
				if not originalTextSizes[desc] then
					originalTextSizes[desc] = desc.TextSize
					updateScale()
				end
			end)
		end
	end)
end;
task.spawn(C_54);
-- StarterGui.Zyrix.ToggleUI.ToggleScript
local function C_5b()
local script = G2L["5b"];
	local zyrix = script.Parent.Parent
	local toggleBtn = script.Parent
	local main = zyrix:FindFirstChild("main")
	local tabFrame = zyrix:FindFirstChild("Frame")
	
	local isOpen = true
	
	local function updateUI()
		if main then main.Visible = isOpen end
		if tabFrame then tabFrame.Visible = isOpen end
		toggleBtn.Text = isOpen and "✕" or "☰"
	end
	
	toggleBtn.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		updateUI()
	end)
	
	uiOpenPanel = function()
		isOpen = true
		updateUI()
	end
	uiClosePanel = function()
		isOpen = false
		updateUI()
	end
	
	updateUI()
end;
C_5b();


    uiScreenGui = G2L["1"]
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, uiScreenGui)
    end
    uiBuilt = true
end

function ZyrixUI:Open()
    local ok, err = pcall(buildZyrixUI)
    if not ok then
        uiBuilt = false
        uiScreenGui = nil
        warn("[ZyrixUI] Failed to build:", err)
        if Zyrix and Zyrix.Notify then
            Zyrix:Notify("UI Error", tostring(err), 5, "error")
        end
        return false
    end
    local sg = uiScreenGui
    if not sg then return false end
    sg.Enabled = true
    local main = sg:FindFirstChild("main")
    local tabFrame = sg:FindFirstChild("Frame")
    local toggleBtn = sg:FindFirstChild("ToggleUI")
    if main then main.Visible = true end
    if tabFrame then tabFrame.Visible = true end
    if toggleBtn then toggleBtn.Text = "✕" end
    if uiOpenPanel then uiOpenPanel() end
    return true
end

function ZyrixUI:Close()
    if uiClosePanel then uiClosePanel() end
    if uiScreenGui then uiScreenGui.Enabled = false end
end

fireOnSuccess = function()
    task.spawn(function()
        task.wait(0.2)
        local ui = getgenv().ZyrixUI
        if ui and ui.Open then
            local opened = ui:Open()
            if opened and Zyrix and Zyrix.Notify then
                Zyrix:Notify("zyrix", "Interface loaded", 2, "success")
            end
        end
        pcall(function()
            if Zyrix.Callbacks.OnSuccess then
                Zyrix.Callbacks.OnSuccess()
            end
        end)
    end)
end

getgenv().ZyrixUI = ZyrixUI
return Zyrix
