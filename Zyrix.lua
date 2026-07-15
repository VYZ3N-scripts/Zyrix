--[[

███████╗██╗   ██╗██████╗ ██╗██╗  ██╗
╚══███╔╝╚██╗ ██╔╝██╔══██╗██║╚██╗██╔╝
  ███╔╝  ╚████╔╝ ██████╔╝██║ ╚███╔╝
 ███╔╝    ╚██╔╝  ██╔══██╗██║ ██╔██╗
███████╗   ██║   ██║  ██║██║██╔╝ ██╗
╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝

    GitHub - https://github.com/VYZ3N-scripts
    Author - Z4ITH
]]

repeat task.wait() until game:IsLoaded()
local genv = (getgenv and getgenv()) or _G
local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function()
	local ok, core = pcall(function() return cloneref(game:GetService("CoreGui")) end)
	if ok and core then return core end
	return nil
end
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local Lighting = cloneref(game:GetService("Lighting"))
local Players = cloneref(game:GetService("Players"))
local function resolveGuiParent()
	local player = Players.LocalPlayer
	if not player then
		player = Players.PlayerAdded:Wait()
	end
	local playerGui = player:FindFirstChildOfClass("PlayerGui") or player:WaitForChild("PlayerGui", 15)
	if playerGui then
		return cloneref(playerGui)
	end
	local ok, parent = pcall(gethui)
	if ok and parent then return parent end
	return cloneref(game:GetService("CoreGui"))
end
local function protectGui(gui)
	if not gui then return end
	pcall(function()
		if syn and syn.protect_gui then syn.protect_gui(gui) end
	end)
	pcall(function()
		if protectgui then protectgui(gui) end
	end)
end
local hui = resolveGuiParent()
if genv.ZyrixLibraryOnly and genv.ZyrixLoaded and genv.Zyrix then
	return genv.Zyrix
end
if genv.ZyrixLoaded and genv.Zyrix and hui:FindFirstChild("ZyrixKeySystem") and not genv.ZyrixForceReload then
	return genv.Zyrix
end
if genv.ZyrixLoaded and genv.Zyrix and hui:FindFirstChild("ZyrixKeylessSystem") and not genv.ZyrixForceReload then
	return genv.Zyrix
end
if genv.ZyrixLoaded and not hui:FindFirstChild("ZyrixKeySystem") and not hui:FindFirstChild("ZyrixKeylessSystem") and not hui:FindFirstChild("ZyrixMainUI") then
	genv.ZyrixLoaded = false
end
genv.ZyrixLoaded = true
genv.ZyrixClosed = false
local Zyrix = {}
Zyrix.Appearance = {
	Title = "B4TMAN // Interface",
	Subtitle = "TACTICAL OPERATING SYSTEM",
	Icon = "rbxassetid://333658348",
	IconSize = UDim2.new(0, 30, 0, 30)
}
Zyrix.Links = {
	GetKey = "",
	Discord = ""
}
Zyrix.Storage = {
	FileName = "Zyrix_Key",
	Remember = true,
	AutoLoad = true
}
Zyrix.Options = {
	Keyless = nil,
	KeylessUI = false,
	Blur = true,
	Draggable = true,
	NoGetKey = false
}
Zyrix.BatmanTheme = {
	Accent = Color3.fromRGB(170, 170, 170),
	AccentHover = Color3.fromRGB(140, 140, 140),
	Background = Color3.fromRGB(6, 6, 6),
	TabBar = Color3.fromRGB(12, 12, 12),
	TabIdle = Color3.fromRGB(6, 6, 6),
	TabActive = Color3.fromRGB(18, 18, 18),
	Panel = Color3.fromRGB(12, 12, 12),
	Element = Color3.fromRGB(8, 8, 8),
	Inner = Color3.fromRGB(18, 18, 18),
	Progress = Color3.fromRGB(170, 170, 170),
	KnobOn = Color3.fromRGB(170, 170, 170),
	KnobOff = Color3.fromRGB(80, 80, 80),
	Stroke = Color3.fromRGB(45, 45, 45),
	StrokeIn = Color3.fromRGB(55, 55, 55),
	Divider = Color3.fromRGB(35, 35, 35),
	Text = Color3.fromRGB(235, 235, 235),
	TextDim = Color3.fromRGB(130, 130, 130),
	TextGrey = Color3.fromRGB(100, 100, 100),
	White = Color3.fromRGB(170, 170, 170),
	Hover = Color3.fromRGB(22, 22, 22),
	Door = Color3.fromRGB(6, 6, 6),
}
Zyrix.Theme = {
	Accent = Color3.fromRGB(170, 170, 170),
	AccentHover = Color3.fromRGB(140, 140, 140),
	Background = Color3.fromRGB(6, 6, 6),
	Header = Color3.fromRGB(12, 12, 12),
	Input = Color3.fromRGB(18, 18, 18),
	Text = Color3.fromRGB(235, 235, 235),
	TextDim = Color3.fromRGB(130, 130, 130),
	Success = Color3.fromRGB(170, 170, 170),
	Error = Color3.fromRGB(80, 40, 40),
	Warning = Color3.fromRGB(70, 55, 35),
	StatusIdle = Color3.fromRGB(80, 80, 80),
	Discord = Color3.fromRGB(120, 120, 120),
	DiscordHover = Color3.fromRGB(170, 170, 170),
	Divider = Color3.fromRGB(35, 35, 35),
	Pending = Color3.fromRGB(50, 50, 50)
}
Zyrix.Callbacks = {
	OnVerify = nil,
	OnSuccess = nil,
	OnFail = nil,
	OnClose = nil
}
local fireOnSuccess
Zyrix.Changelog = {}
Zyrix.Shop = {
	Enabled = false,
	Icon = "",
	Title = "Get Premium Access",
	Subtitle = "Instant delivery • 24/7 support",
	ButtonText = "Buy",
	Link = ""
}
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
	logo = "rbxassetid://333658348",
	user = "rbxassetid://77400125196692",
	clock = "rbxassetid://87505349362628",
	cart = "rbxassetid://114754518183872",
	nogetkey = "rbxassetid://119765975153029"
}
local CachedIcons = {}
local TrackedConnections = {}
local function trackConnection(conn)
	table.insert(TrackedConnections, conn)
	return conn
end
local function disconnectAllTracked()
	for i = #TrackedConnections, 1, -1 do
		local conn = TrackedConnections[i]
		if conn then pcall(function() conn:Disconnect() end) end
		TrackedConnections[i] = nil
	end
end
local FolderName = "Zyrix"
local IconsFolder = "Icons"
local DefaultLogoAsset = "rbxassetid://333658348"
local function isMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function getScale()
	local viewport = Workspace.CurrentCamera.ViewportSize
	return math.clamp(math.min(viewport.X, viewport.Y) / 900, 0.65, 1.3)
end
local function hasFileSystem()
	local ok1, r1 = pcall(function() return type(writefile) == "function" end)
	local ok2, r2 = pcall(function() return type(readfile) == "function" end)
	local ok3, r3 = pcall(function() return type(isfile) == "function" end)
	local ok4, r4 = pcall(function() return type(makefolder) == "function" end)
	local ok5, r5 = pcall(function() return type(isfolder) == "function" end)
	local ok6, r6 = pcall(function() return type(delfile) == "function" end)
	return ok1 and r1 and ok2 and r2 and ok3 and r3 and ok4 and r4 and ok5 and r5 and ok6 and r6
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
	if not hwid then pcall(function() if genv.HWID then hwid = genv.HWID end end) end
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
	return string.rep("•", count)
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
	genv.ZyrixLoaded = false
	genv.ZyrixClosed = true
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
	trackConnection(UserInputService.InputChanged:Connect(function(input)
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
	end))
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
	local parentCorner = parentFrame:FindFirstChildOfClass("UICorner")
	local parentRadius = (parentCorner and parentCorner.CornerRadius.Offset) or 16
	local leftDoor = Instance.new("Frame")
	leftDoor.Name = "LeftDoor"
	leftDoor.Size = UDim2.new(0.5, 0, 1, 0)
	leftDoor.Position = UDim2.new(0, 0, 0, 0)
	leftDoor.BackgroundColor3 = Zyrix.Theme.Header
	leftDoor.BorderSizePixel = 0
	leftDoor.ZIndex = 51
	leftDoor.Parent = overlay
	local ldc = Instance.new("UICorner", leftDoor)
	ldc.CornerRadius = UDim.new(0, 0)
	ldc.TopLeftRadius = UDim.new(0, parentRadius)
	ldc.BottomLeftRadius = UDim.new(0, parentRadius)
	ldc.TopRightRadius = UDim.new(0, 0)
	ldc.BottomRightRadius = UDim.new(0, 0)
	local rightDoor = Instance.new("Frame")
	rightDoor.Name = "RightDoor"
	rightDoor.Size = UDim2.new(0.5, 0, 1, 0)
	rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
	rightDoor.BackgroundColor3 = Zyrix.Theme.Header
	rightDoor.BorderSizePixel = 0
	rightDoor.ZIndex = 51
	rightDoor.Parent = overlay
	local rdc = Instance.new("UICorner", rightDoor)
	rdc.CornerRadius = UDim.new(0, 0)
	rdc.TopRightRadius = UDim.new(0, parentRadius)
	rdc.BottomRightRadius = UDim.new(0, parentRadius)
	rdc.TopLeftRadius = UDim.new(0, 0)
	rdc.BottomLeftRadius = UDim.new(0, 0)
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
local loadIconsFast
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
	protectGui(gui)
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
		indicator.Text = "○"
		indicator.TextColor3 = Zyrix.Theme.Pending
		indicator.TextSize = phaseTextSize
		indicator.Font = Enum.Font.GothamMedium
		indicator.TextTransparency = 1
		indicator.Parent = row
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, mobile and -28 or -35, 1, 0)
		label.Position = UDim2.new(0, mobile and 28 or 35, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = name
		label.TextColor3 = Zyrix.Theme.Pending
		label.TextSize = phaseTextSize
		label.Font = Enum.Font.GothamMedium
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
				p.indicator.Text = "●"
				TweenService:Create(p.indicator, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Success, TextTransparency = 0}):Play()
				TweenService:Create(p.label, TweenInfo.new(0.2), {TextColor3 = Zyrix.Theme.Success}):Play()
			elseif i == num then
				p.indicator.Text = "●"
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
				p.indicator.Text = "○"
				p.indicator.TextColor3 = Zyrix.Theme.Pending
				p.label.TextColor3 = Zyrix.Theme.Pending
			end
		end
	end
	task.spawn(function()
		local ok, err = pcall(function()
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
		end)
		if not ok then warn("[Zyrix] Loading screen error:", err) end
		if onComplete then onComplete() end
		completed = true
	end)
	local deadline = os.clock() + 45
	while not completed and os.clock() < deadline do task.wait(0.05) end
	if not completed then
		animationRunning = false
		warn("[Zyrix] Loading timed out — continuing with fallback icons")
		loadIconsFast()
		if onComplete then onComplete() end
	end
end
loadIconsFast = function()
	for name, asset in pairs(FallbackIcons) do
		if not CachedIcons[name] then CachedIcons[name] = asset end
	end
	Internal.IconsLoaded = true
	task.spawn(function()
		pcall(loadAllIconsFromCache)
	end)
end
local function EnsureIconsReady(callback, fastMode)
	if fastMode then
		loadIconsFast()
		if callback then callback() end
		return
	end
	if allIconsCached() then
		loadAllIconsFromCache()
		if callback then callback() end
	else
		ShowLoadingScreen(callback)
	end
end
function Zyrix:Notify(title, message, duration, iconType)
	if type(title) == "table" then
		local opts = title
		return Zyrix:Notify(opts.Title, opts.Content, opts.Duration, opts.Image)
	end
	duration = duration or 5
	iconType = iconType or "info"
	local scale = getScale()
	local width = math.clamp(320 * scale, 260, 380)
	local height = math.clamp(80 * scale, 75, 105)
	local notifGui = Instance.new("ScreenGui")
	notifGui.ResetOnSpawn = false
	notifGui.DisplayOrder = 999999
	notifGui.Parent = hui
	protectGui(notifGui)
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
	progressBg.BackgroundColor3 = Zyrix.Theme.Divider
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
	titleLabel.Font = Enum.Font.GothamBold
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
	messageLabel.Font = Enum.Font.GothamMedium
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
	task.spawn(function()
		task.wait(0.1)
		restack()
	end)
	local function dismiss()
		for i, n in ipairs(Internal.NotificationList) do
			if n.id == id then table.remove(Internal.NotificationList, i) break end
		end
		TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, width + 20, frame.Position.Y.Scale, frame.Position.Y.Offset)}):Play()
		task.spawn(function()
			task.wait(0.3)
			notifGui:Destroy()
			restack()
		end)
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
	panelTitle.Font = Enum.Font.GothamBold
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
		versionLabel.Text = update.Version .. "  •  " .. update.Date
		versionLabel.TextColor3 = Zyrix.Theme.Accent
		versionLabel.TextSize = 14
		versionLabel.Font = Enum.Font.GothamBold
		versionLabel.TextXAlignment = Enum.TextXAlignment.Left
		versionLabel.LayoutOrder = 1
		versionLabel.Parent = entry
		for j, change in ipairs(update.Changes) do
			local changeLabel = Instance.new("TextLabel")
			changeLabel.Size = UDim2.new(1, 0, 0, 0)
			changeLabel.AutomaticSize = Enum.AutomaticSize.Y
			changeLabel.BackgroundTransparency = 1
			changeLabel.Text = "  •  " .. change
			changeLabel.TextColor3 = Zyrix.Theme.TextDim
			changeLabel.TextSize = 12
			changeLabel.Font = Enum.Font.GothamMedium
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
	panelTitle.Font = Enum.Font.GothamBold
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
	welcomeLabel.Font = Enum.Font.GothamBold
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
	executorTitle.Font = Enum.Font.GothamMedium
	executorTitle.TextXAlignment = Enum.TextXAlignment.Left
	executorTitle.Parent = executorContainer
	local executorValue = Instance.new("TextLabel")
	executorValue.Size = UDim2.new(1, 0, 0, 14)
	executorValue.Position = UDim2.new(0, 0, 0, 11)
	executorValue.BackgroundTransparency = 1
	executorValue.Text = getExecutorName()
	executorValue.TextColor3 = Zyrix.Theme.Accent
	executorValue.TextSize = valueSize
	executorValue.Font = Enum.Font.GothamBold
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
	deviceTitle.Font = Enum.Font.GothamMedium
	deviceTitle.TextXAlignment = Enum.TextXAlignment.Left
	deviceTitle.Parent = deviceContainer
	local deviceValue = Instance.new("TextLabel")
	deviceValue.Size = UDim2.new(1, 0, 0, 14)
	deviceValue.Position = UDim2.new(0, 0, 0, 11)
	deviceValue.BackgroundTransparency = 1
	deviceValue.Text = getDeviceType()
	deviceValue.TextColor3 = Zyrix.Theme.Accent
	deviceValue.TextSize = valueSize
	deviceValue.Font = Enum.Font.GothamBold
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
	hwidTitle.Font = Enum.Font.GothamMedium
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
	hwidValue.Font = Enum.Font.GothamMedium
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
	clockTimeLabel.Font = Enum.Font.GothamBold
	clockTimeLabel.LayoutOrder = 2
	clockTimeLabel.Parent = clockRow
	local clockDateLabel = Instance.new("TextLabel")
	clockDateLabel.Size = UDim2.new(1, 0, 0, isCompact and 12 or 14)
	clockDateLabel.Position = UDim2.new(0, -8, 0, isCompact and 18 or 22)
	clockDateLabel.BackgroundTransparency = 1
	clockDateLabel.Text = formatDate()
	clockDateLabel.TextColor3 = Zyrix.Theme.TextDim
	clockDateLabel.TextSize = isCompact and 9 or 11
	clockDateLabel.Font = Enum.Font.GothamMedium
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
	genv.SCRIPT_KEY = "KEYLESS"
	genv.ZyrixLoaded = false
	task.spawn(function()
		pcall(function() Zyrix:Notify("Access Granted", "Keyless access approved!", 3, "success") end)
		fireOnSuccess()
	end)
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
	protectGui(gui)
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
	title.Font = Enum.Font.GothamBold
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
	successText.Font = Enum.Font.GothamMedium
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
	keylessText.Font = Enum.Font.GothamMedium
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
	launchLabel.Font = Enum.Font.GothamBold
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
		genv.SCRIPT_KEY = "KEYLESS"
		genv.ZyrixLoaded = false
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
	protectGui(screenGui)
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
	titleLabel.Font = Enum.Font.GothamBold
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
	statusLabel.Font = Enum.Font.GothamMedium
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
	textBox.Font = Enum.Font.GothamMedium
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
		iconImg.ImageColor3 = isPrimary and Zyrix.Theme.Background or Zyrix.Theme.Text
		iconImg.ScaleType = Enum.ScaleType.Fit
		iconImg.LayoutOrder = 1
		iconImg.Parent = content
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 0, 0, 20)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = isPrimary and Zyrix.Theme.Background or Zyrix.Theme.Text
		label.TextSize = mobile and 14 or 15
		label.Font = Enum.Font.GothamMedium
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
		shopTitle.Font = Enum.Font.GothamBold
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
		shopSubtitle.Font = Enum.Font.GothamMedium
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
		buyLabel.Font = Enum.Font.GothamBold
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
	screenGui.Destroying:Connect(function()
		if spinConnection then spinConnection:Disconnect() spinConnection = nil end
		if dotsThread then task.cancel(dotsThread) dotsThread = nil end
	end)
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
			saveKey(key) genv.SCRIPT_KEY = key genv.ZyrixLoaded = false
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
	doors.open(function() end)
end
function Zyrix:Launch()
	Internal.IsJunkieMode = false
	Internal.ValidateFunction = Zyrix.Callbacks.OnVerify
	local hubOnly = Zyrix.Options.Keyless == true and Zyrix.Options.KeylessUI == false
	local existingKey = genv.SCRIPT_KEY
	local function openHub()
		EnsureIconsReady(function()
			fireOnSuccess()
		end, true)
	end
	if existingKey and existingKey ~= "" then
		if existingKey == "KEYLESS" and hubOnly then
			openHub()
			return
		elseif existingKey == "KEYLESS" then
			EnsureIconsReady(function() fireOnSuccess() end, true)
			return
		elseif Internal.ValidateFunction and validateKey(existingKey, Internal.ValidateFunction) then
			task.spawn(function()
				pcall(function() Zyrix:Notify("Executed", "Script loaded successfully!", 2, "success") end)
				fireOnSuccess()
			end)
			return
		end
		genv.SCRIPT_KEY = nil
	end
	genv.ZyrixClosed = false
	if hubOnly then
		genv.SCRIPT_KEY = "KEYLESS"
		genv.ZyrixLoaded = false
		openHub()
		return
	end
	EnsureIconsReady(function()
		if Zyrix.Options.Keyless == true then
			if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
			BuildKeylessUI()
			while not genv.SCRIPT_KEY do task.wait(0.1) end
			return
		end
		if Zyrix.Storage.AutoLoad and Internal.ValidateFunction then
			local savedKey = loadKey()
			if savedKey and savedKey ~= "" then
				Zyrix:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
				if validateKey(savedKey, Internal.ValidateFunction) then
					genv.SCRIPT_KEY = savedKey
					Zyrix:Notify("Welcome Back", "Key validated!", 2, "success")
					fireOnSuccess() return
				else clearKey() Zyrix:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
			end
		end
		BuildKeyUI()
		while not genv.SCRIPT_KEY do task.wait(0.1) end
	end, true)
end
function Zyrix:LaunchJunkie(config)
	assert(config and config.Service and config.Identifier and config.Provider, "Config required: Service, Identifier, Provider")
	Internal.IsJunkieMode = true
	local existingKey = genv.SCRIPT_KEY
	if existingKey and existingKey ~= "" then
		Zyrix:Notify("Executed", "Script loaded successfully!", 2, "success")
		fireOnSuccess() return
	end
	genv.ZyrixClosed = false
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
			if ks and kr and type(kr) == "table" and kr.valid then
				if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
				BuildKeylessUI()
				while not genv.SCRIPT_KEY do task.wait(0.1) end
				return
			end
		elseif Zyrix.Options.Keyless == true then
			if Zyrix.Options.KeylessUI == false then handleKeylessSkip() return end
			BuildKeylessUI()
			while not genv.SCRIPT_KEY do task.wait(0.1) end
			return
		end
		if Zyrix.Storage.AutoLoad then
			local savedKey = loadKey()
			if savedKey and savedKey ~= "" then
				Zyrix:Notify("Checking", "Validating saved key...", 2, "shield") task.wait(0.5)
				local vs, vr = pcall(function() return Junkie.check_key(savedKey) end)
				if vs and vr and type(vr) == "table" and vr.valid then
					genv.SCRIPT_KEY = savedKey
					Zyrix:Notify("Welcome Back", "Key validated!", 2, "success")
					fireOnSuccess() return
				else clearKey() Zyrix:Notify("Expired", "Saved key is no longer valid", 3, "warning") task.wait(1) end
			end
		end
		BuildKeyUI()
		while not genv.SCRIPT_KEY do task.wait(0.1) end
	end)
end
function Zyrix:GetSavedKey() return loadKey() end
function Zyrix:ClearSavedKey() return clearKey() end
function Zyrix:Refresh()
	if genv.ZyrixUI and genv.ZyrixUI.Refresh then
		return genv.ZyrixUI:Refresh()
	end
	return false
end
function Zyrix:Reset()
	genv.ZyrixLoaded = false
	genv.ZyrixClosed = false
	genv.SCRIPT_KEY = nil
	pcall(function()
		if genv.ZyrixUI and genv.ZyrixUI._reset then
			genv.ZyrixUI._reset()
		end
	end)
	disableBlur()
	local loadingBlur = Lighting:FindFirstChild("ZyrixLoadingBlur")
	if loadingBlur then pcall(function() loadingBlur:Destroy() end) end
	for _, guiName in ipairs({"ZyrixKeySystem", "ZyrixKeylessSystem", "ZyrixMainUI", "ZyrixLoadingScreen"}) do
		local gui = hui:FindFirstChild(guiName)
		if gui then pcall(function() gui:Destroy() end) end
	end
	pcall(function()
		local parents = {game:GetService("CoreGui")}
		if gethui then pcall(function() table.insert(parents, gethui()) end) end
		for _, parent in ipairs(parents) do
			for _, guiName in ipairs({"ZyrixKeySystem", "ZyrixKeylessSystem", "ZyrixMainUI", "ZyrixLoadingScreen"}) do
				local gui = parent:FindFirstChild(guiName)
				if gui then pcall(function() gui:Destroy() end) end
			end
		end
	end)
end
genv.Zyrix = Zyrix
local HubRegistry = {
	tabs = {},
	windowConfig = nil,
	toggleKeybind = "K",
}
local function applyWindowConfig(config)
	if not config then return end
	if config.Name then Zyrix.Appearance.Title = config.Name end
	if config.LoadingTitle then Zyrix.Appearance.Title = config.LoadingTitle end
	if config.LoadingSubtitle then Zyrix.Appearance.Subtitle = config.LoadingSubtitle end
	if config.Icon and type(config.Icon) == "string" and config.Icon:find("rbxasset") then
		Zyrix.Appearance.Icon = config.Icon
	end
	if config.ToggleUIKeybind then HubRegistry.toggleKeybind = config.ToggleUIKeybind end
	if config.KeySystem == false then
		Zyrix.Options.Keyless = true
		Zyrix.Options.KeylessUI = false
	elseif config.KeySystem == true and config.KeySettings then
		Zyrix.Options.Keyless = false
		local ks = config.KeySettings
		if ks.Title then Zyrix.Appearance.Title = ks.Title end
		if ks.Subtitle then Zyrix.Appearance.Subtitle = ks.Subtitle end
		if ks.Note then Zyrix.Appearance.Subtitle = ks.Note end
		if ks.FileName then Zyrix.Storage.FileName = ks.FileName end
		if ks.SaveKey ~= nil then Zyrix.Storage.Remember = ks.SaveKey end
		if ks.Key and type(ks.Key) == "table" then
			Zyrix.Callbacks.OnVerify = function(key)
				for _, validKey in ipairs(ks.Key) do
					if key == validKey then return true end
				end
				return false
			end
		end
	end
end
function Zyrix:CreateWindow(config)
	HubRegistry.tabs = {}
	HubRegistry.windowConfig = config or {}
	applyWindowConfig(config)
	if genv.ZyrixUI and genv.ZyrixUI._reset then
		genv.ZyrixUI._reset()
	end
	local window = {}
	function window:CreateTab(name, icon)
		local tabData = { Name = name, Icon = icon, Elements = {} }
		table.insert(HubRegistry.tabs, tabData)
		local tab = {}
		function tab:CreateSection(title)
			table.insert(tabData.Elements, { Type = "section", Text = title })
		end
		function tab:CreateButton(opts)
			local el = { Type = "button", Text = opts.Name, Callback = opts.Callback, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return { Set = function(_, val) el.Text = val end }
		end
		function tab:CreateToggle(opts)
			local el = { Type = "toggle", Text = opts.Name, Default = opts.CurrentValue == true, Callback = opts.Callback, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return { Set = function(_, val) el.Default = val == true; if el._apply then el._apply(el.Default, true) end end }
		end
		function tab:CreateSlider(opts)
			local range = opts.Range or {0, 100}
			local minV, maxV = range[1], range[2]
			local el = { Type = "slider", Text = opts.Name, Min = minV, Max = maxV, Default = (opts.CurrentValue - minV) / math.max(maxV - minV, 1), Callback = opts.Callback, Suffix = opts.Suffix, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return { Set = function(_, val) el.Default = (val - minV) / math.max(maxV - minV, 1); if el._apply then el._apply(el.Default, true) end end }
		end
		function tab:CreateInput(opts)
			local el = { Type = "input", Text = opts.Name, Placeholder = opts.PlaceholderText or "", Callback = opts.Callback, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return { Set = function(_, val) if el._box then el._box.Text = tostring(val) end end }
		end
		function tab:CreateDropdown(opts)
			local options = opts.Options or {}
			local current = opts.CurrentOption
			local defaultIndex = 1
			if type(current) == "table" and current[1] then
				for i, opt in ipairs(options) do if opt == current[1] then defaultIndex = i break end end
			end
			local el = { Type = "dropdown", Text = opts.Name, Options = options, Default = defaultIndex, Callback = function(opt) if opts.Callback then opts.Callback({opt}) end end, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return {
				Set = function(_, val) local pick = type(val) == "table" and val[1] or val; if el._apply then el._apply(pick) end end,
				SetOptions = function(_, newOptions) if el._setOptions then el._setOptions(newOptions) end end,
			}
		end
		function tab:CreateKeybind(opts)
			local el = { Type = "keybind", Text = opts.Name, Default = opts.CurrentKeybind or "Q", Callback = opts.Callback, Side = opts.Side }
			table.insert(tabData.Elements, el)
			return { Set = function(_, val) if el._apply then el._apply(val) end end }
		end
		function tab:CreateLabel(text)
			table.insert(tabData.Elements, { Type = "label", Text = text, Side = nil })
			return { Set = function(_, val) end }
		end
		function tab:CreateDivider()
			table.insert(tabData.Elements, { Type = "divider" })
		end
		return tab
	end
	return window
end
local ZyrixUI = {}
local uiBuilt = false
local uiScreenGui
local uiOpenPanel
local uiClosePanel
local uiExpandPanel
local function buildZyrixUI()
	local uiParent = hui
	local oldGui = uiParent:FindFirstChild("ZyrixMainUI")
	if oldGui then oldGui:Destroy() end
	local _ddCopy = uiParent:FindFirstChild("dropdownn")
	if _ddCopy then _ddCopy.Enabled = false end
	uiBuilt = false
	local TS = TweenService
	local UIS = UserInputService
	local starterGui = cloneref(game:GetService("StarterGui"))
	local template = starterGui and starterGui:FindFirstChild("ZyrixMainUI")
	local _ddTemplate = starterGui and starterGui:FindFirstChild("dropdownn")
	_ddTemplate = _ddTemplate and _ddTemplate:FindFirstChild("Dropdown") or nil
	local sg
	if template then
		sg = template:Clone()
		sg.Enabled = true 
		sg.Parent = uiParent
		protectGui(sg)
	else
		sg = Instance.new("ScreenGui")
		sg.Name = "ZyrixMainUI"
		sg.ResetOnSpawn = false
		sg.IgnoreGuiInset = true
		sg.DisplayOrder = 1000
		sg.Enabled = true
		sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		sg.Parent = uiParent
		protectGui(sg)
	end
	local root = sg:FindFirstChild("Root")
	local _templateRoot = root
	local function readColor(attrName, fallback)
		if _templateRoot then
			local v = _templateRoot:GetAttribute(attrName)
			if v and typeof(v) == "Color3" then return v end
		end
		return fallback
	end
	local function readNum(attrName, fallback)
		if _templateRoot then
			local v = _templateRoot:GetAttribute(attrName)
			if v and typeof(v) == "number" then return v end
		end
		return fallback
	end
	local C = {
		WIN = readColor("Color_WIN", Color3.fromRGB(6, 6, 6)),
		TAB_BAR = readColor("Color_TAB_BAR", Color3.fromRGB(12, 12, 12)),
		TAB_IDLE = readColor("Color_TAB_IDLE", Color3.fromRGB(6, 6, 6)),
		TAB_ACTIVE = readColor("Color_TAB_ACTIVE", Color3.fromRGB(18, 18, 18)),
		PANEL = readColor("Color_PANEL", Color3.fromRGB(12, 12, 12)),
		EL = readColor("Color_EL", Color3.fromRGB(8, 8, 8)),
		INNER = readColor("Color_INNER", Color3.fromRGB(18, 18, 18)),
		PROGRESS = readColor("Color_PROGRESS", Color3.fromRGB(170, 170, 170)),
		KNOB_ON = readColor("Color_KNOB_ON", Color3.fromRGB(170, 170, 170)),
		KNOB_OFF = readColor("Color_KNOB_OFF", Color3.fromRGB(80, 80, 80)),
		DD_ITEM = readColor("Color_DD_ITEM", Color3.fromRGB(18, 18, 18)),
		DD_LIST = readColor("Color_DD_LIST", Color3.fromRGB(12, 12, 12)),
		STROKE = readColor("Color_STROKE", Color3.fromRGB(45, 45, 45)),
		STROKE_IN = readColor("Color_STROKE_IN", Color3.fromRGB(55, 55, 55)),
		DIVIDER = readColor("Color_DIVIDER", Color3.fromRGB(35, 35, 35)),
		TEXT = readColor("Color_TEXT", Color3.fromRGB(235, 235, 235)),
		TEXT_DIM = readColor("Color_TEXT_DIM", Color3.fromRGB(130, 130, 130)),
		TEXT_GREY = readColor("Color_TEXT_GREY", Color3.fromRGB(100, 100, 100)),
		WHITE = readColor("Color_WHITE", Color3.fromRGB(170, 170, 170)),
		HOVER = readColor("Color_HOVER", Color3.fromRGB(22, 22, 22)),
		DOOR = readColor("Color_DOOR", Color3.fromRGB(6, 6, 6)),
	}
	local function tw(obj, t, props, style, dir)
		TS:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out), props):Play()
	end
	local function corner(p, r)
		local c = Instance.new("UICorner", p)
		c.CornerRadius = r or UDim.new(0, 6)
		return c
	end
	local function stroke(p, col, thick)
		local s = Instance.new("UIStroke", p)
		s.Color = col or C.STROKE
		s.Thickness = thick or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		return s
	end
	local function pad(p, t, b, l, r)
		local ui = Instance.new("UIPadding", p)
		ui.PaddingTop = UDim.new(0, t or 0)
		ui.PaddingBottom = UDim.new(0, b or 0)
		ui.PaddingLeft = UDim.new(0, l or 0)
		ui.PaddingRight = UDim.new(0, r or 0)
	end
	local function btn(props)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.BackgroundTransparency = 1
		b.Text = ""
		b.BorderSizePixel = 0
		for k, v in pairs(props) do b[k] = v end
		return b
	end
	local function lbl(props)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.BorderSizePixel = 0
		l.TextXAlignment = Enum.TextXAlignment.Left
		for k, v in pairs(props) do l[k] = v end
		return l
	end
	local function frame(props)
		local f = Instance.new("Frame")
		f.BorderSizePixel = 0
		for k, v in pairs(props) do f[k] = v end
		return f
	end
	local WIN_W = readNum("Size_WIN_W", 660)
	local WIN_H = readNum("Size_WIN_H", 440)
	local TAB_H = readNum("Size_TAB_H", 44)
	local GAP = readNum("Size_GAP", 10)
	local ROW_H = readNum("Size_ROW_H", 44)
	local SLIDER_ROW_H = readNum("Size_SLIDER_ROW_H", 52)
	local CONTENT_H = readNum("Size_CONTENT_H", 380)
	local TAB_INNER = TAB_H - 8
	local openDropdown = nil
	local sliderDragTrack = nil
	local sliderRegistry = {}
	local keybindCapture = nil
	local S = {} 
	if root then
		local _main = root:FindFirstChild("main")
		local _elements = _main and _main:FindFirstChild("elements")
		local _pageHost = _elements and _elements:FindFirstChild("PageHost")
		if _pageHost then
			for _, _page in ipairs(_pageHost:GetChildren()) do
				local _body = _page:FindFirstChild("Body")
				if not _body then continue end
				local _left = _body:FindFirstChild("LeftCol")
				local _right = _body:FindFirstChild("RightCol")
				if _left then
					local _toggle = _left:FindFirstChild("Toggle")
					if _toggle then
						local _label = _toggle:FindFirstChild("Label")
						if _label then
							S.ToggleFont = _label.Font
							S.ToggleTextSize = _label.TextSize
							S.ToggleTextColor = _label.TextColor3
						end
						local _switch = _toggle:FindFirstChild("Switch")
						if _switch then
							S.SwitchBgColor = _switch.BackgroundColor3
							S.SwitchSize = _switch.Size
							S.SwitchPos = _switch.Position
							local _ss = _switch:FindFirstChildOfClass("UIStroke")
							if _ss then S.SwitchStrokeColor = _ss.Color end
							local _knob = _switch:FindFirstChild("Knob")
							if _knob then
								S.KnobSize = _knob.Size
								S.KnobOffPos = _knob.Position
								S.KnobOffColor = _knob.BackgroundColor3
							end
						end
					end
					local _slider = _left:FindFirstChild("Slider")
					if _slider then
						local _slabel = _slider:FindFirstChild("Label")
						if _slabel then
							S.SliderFont = _slabel.Font
							S.SliderTextSize = _slabel.TextSize
							S.SliderTextColor = _slabel.TextColor3
						end
						local _track = _slider:FindFirstChild("SliderTrack")
						if _track then
							S.SliderTrackSize = _track.Size
							S.SliderTrackPos = _track.Position
							S.SliderTrackBgColor = _track.BackgroundColor3
							local _fill = _track:FindFirstChild("Progress")
							if _fill then S.SliderProgressColor = _fill.BackgroundColor3 end
							local _val = _track:FindFirstChild("Value")
							if _val then
								S.SliderValueFont = _val.Font
								S.SliderValueTextSize = _val.TextSize
								S.SliderValueTextColor = _val.TextColor3
							end
						end
					end
					local _btn = _left:FindFirstChild("Button")
					if _btn then
						local _blabel = _btn:FindFirstChild("Label")
						if _blabel then
							S.ButtonFont = _blabel.Font
							S.ButtonTextSize = _blabel.TextSize
							S.ButtonTextColor = _blabel.TextColor3
						end
						local _hint = _btn:FindFirstChild("Hint")
						if _hint then
							S.ButtonHintFont = _hint.Font
							S.ButtonHintTextSize = _hint.TextSize
							S.ButtonHintTextColor = _hint.TextColor3
						end
					end
					local _kb = _left:FindFirstChild("Keybind")
					if _kb then
						local _kblabel = _kb:FindFirstChild("Label")
						if _kblabel then
							S.KeybindFont = _kblabel.Font
							S.KeybindTextSize = _kblabel.TextSize
							S.KeybindTextColor = _kblabel.TextColor3
						end
						local _kbbox = _kb:FindFirstChild("KeyBox")
						if _kbbox then
							S.KeyBoxBgColor = _kbbox.BackgroundColor3
							S.KeyBoxFont = _kbbox.Font
							S.KeyBoxTextSize = _kbbox.TextSize
							S.KeyBoxTextColor = _kbbox.TextColor3
							S.KeyBoxSize = _kbbox.Size
							S.KeyBoxPos = _kbbox.Position
						end
					end
					local _inp = _left:FindFirstChild("Input")
					if _inp then
						local _inplabel = _inp:FindFirstChild("Label")
						if _inplabel then
							S.InputFont = _inplabel.Font
							S.InputTextSize = _inplabel.TextSize
							S.InputTextColor = _inplabel.TextColor3
						end
						local _inpbox = _inp:FindFirstChild("InputBox")
						if _inpbox then
							S.InputBoxBgColor = _inpbox.BackgroundColor3
							S.InputBoxFont = _inpbox.Font
							S.InputBoxTextSize = _inpbox.TextSize
							S.InputBoxTextColor = _inpbox.TextColor3
							S.InputBoxSize = _inpbox.Size
							S.InputBoxPos = _inpbox.Position
						end
					end
					local _sec = _left:FindFirstChild("SectionLabel")
					if _sec then
						S.SectionFont = _sec.Font
						S.SectionTextSize = _sec.TextSize
						S.SectionTextColor = _sec.TextColor3
					end
				end
				break 
			end
		end
	end
	local DD = {}
	if _ddTemplate then
		DD.bgColor = _ddTemplate.BackgroundColor3
		DD.bgTransparency = _ddTemplate.BackgroundTransparency
		local _dcc = _ddTemplate:FindFirstChild("UICorner")
		if _dcc then DD.containerCorner = _dcc.CornerRadius end
		local _ddp = _ddTemplate:FindFirstChild("UIPadding")
		if _ddp then DD.padL = _ddp.PaddingLeft DD.padR = _ddp.PaddingRight DD.padT = _ddp.PaddingTop DD.padB = _ddp.PaddingBottom end
		local _ds = _ddTemplate:FindFirstChild("UIStroke")
		if _ds then DD.strokeColor = _ds.Color DD.strokeThickness = _ds.Thickness DD.strokeTransparency = _ds.Transparency end
		local _dt = _ddTemplate:FindFirstChild("Title")
		if _dt then DD.titleFont = _dt.Font DD.titleSize = _dt.TextSize DD.titleColor = _dt.TextColor3 DD.titlePos = _dt.Position DD.titleSizeFrame = _dt.Size DD.titleXAlign = _dt.TextXAlignment DD.titleYAlign = _dt.TextYAlignment DD.titleBgTransparency = _dt.BackgroundTransparency end
		local _dsel = _ddTemplate:FindFirstChild("Selected")
		if _dsel then DD.selFont = _dsel.Font DD.selSize = _dsel.TextSize DD.selColor = _dsel.TextColor3 DD.selPos = _dsel.Position DD.selSizeFrame = _dsel.Size DD.selAnchor = _dsel.AnchorPoint DD.selXAlign = _dsel.TextXAlignment end
		local _dtg = _ddTemplate:FindFirstChild("Toggle")
		if _dtg then DD.arrowImage = _dtg.Image DD.arrowRectOffset = _dtg.ImageRectOffset DD.arrowRectSize = _dtg.ImageRectSize DD.arrowColor = _dtg.ImageColor3 DD.arrowScale = _dtg.ScaleType DD.arrowPos = _dtg.Position DD.arrowAnchor = _dtg.AnchorPoint DD.arrowSize = _dtg.Size DD.arrowAutoButtonColor = _dtg.AutoButtonColor end
		local _dinter = _ddTemplate:FindFirstChild("Interact")
		if _dinter then DD.interactZIndex = _dinter.ZIndex end
		local _dlst = _ddTemplate:FindFirstChild("List")
		if _dlst then
			DD.listBgColor = _dlst.BackgroundColor3
			DD.listBgTransparency = _dlst.BackgroundTransparency
			DD.listMaxH = _dlst.Size.Y.Offset
			local _dll = _dlst:FindFirstChild("UIListLayout")
			if _dll then DD.listLayoutPad = _dll.Padding end
			local _dlp = _dlst:FindFirstChild("UIPadding")
			if _dlp then DD.listPadL = _dlp.PaddingLeft DD.listPadR = _dlp.PaddingRight DD.listPadT = _dlp.PaddingTop DD.listPadB = _dlp.PaddingBottom end
			local _dls = _dlst:FindFirstChild("UIStroke")
			if _dls then DD.listStrokeColor = _dls.Color DD.listStrokeTransparency = _dls.Transparency DD.listStrokeThickness = _dls.Thickness end
			if _dlst:IsA("ScrollingFrame") then
				DD.scrollBarThickness = _dlst.ScrollBarThickness
				DD.scrollBarColor = _dlst.ScrollBarImageColor3
				DD.scrollBarTrans = _dlst.ScrollBarImageTransparency
			end
			local _dopt = _dlst:FindFirstChild("Template")
			if _dopt then
				DD.itemBgColor = _dopt.BackgroundColor3
				DD.itemBgTransparency = _dopt.BackgroundTransparency
				DD.itemH = _dopt.Size.Y.Offset
				DD.itemPos = _dopt.Position
				DD.itemZIndex = _dopt.ZIndex
				local _dos = _dopt:FindFirstChild("UIStroke")
				if _dos then DD.itemStrokeColor = _dos.Color DD.itemStrokeTransparency = _dos.Transparency DD.itemStrokeThickness = _dos.Thickness end
				local _doc = _dopt:FindFirstChild("UICorner")
				if _doc then DD.itemCorner = _doc.CornerRadius end
				local _dot = _dopt:FindFirstChild("Title")
				if _dot then DD.itemFont = _dot.Font DD.itemSize = _dot.TextSize DD.itemColor = _dot.TextColor3 DD.itemTextXAlign = _dot.TextXAlignment DD.itemTitlePos = _dot.Position DD.itemTitleSize = _dot.Size end
				local _dointer = _dopt:FindFirstChild("Interact")
				if _dointer then DD.itemInteractZIndex = _dointer.ZIndex end
			end
		end
	end
	local templateTabBar = root and root:FindFirstChild("TabBar")
	if templateTabBar then
		TAB_H = templateTabBar.Size.Y.Offset
		TAB_INNER = TAB_H - 6
	end
	if not root then
		root = frame({
			Name = "Root",
			Size = UDim2.new(0, WIN_W, 0, TAB_H + GAP + WIN_H),
			Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -(TAB_H + GAP + WIN_H) / 2),
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = sg,
		})
	else
		root.Size = UDim2.new(0, WIN_W, 0, TAB_H + GAP + WIN_H)
		root.Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -(TAB_H + GAP + WIN_H) / 2)
		root.BackgroundTransparency = 1
		root.ClipsDescendants = true 
	end
	local tabBar = root:FindFirstChild("TabBar")
	if not tabBar then
		tabBar = frame({
			Name = "TabBar",
			Size = UDim2.new(0, WIN_W, 0, TAB_H),
			BackgroundColor3 = C.TAB_BAR,
			Active = true,
			Parent = root,
		})
		corner(tabBar, UDim.new(1, 0))
		stroke(tabBar, C.STROKE)
	else
		tabBar.Position = UDim2.new(0, 0, 0, 0)
		tabBar.Active = true
		if not _templateRoot:GetAttribute("Color_TAB_BAR") then
			C.TAB_BAR = tabBar.BackgroundColor3
		end
		local ts = tabBar:FindFirstChildOfClass("UIStroke")
		if ts then
			if not _templateRoot:GetAttribute("Color_STROKE") then
				C.STROKE = ts.Color
			end
		end
	end
	tabBar.ZIndex = 10
	local tabScroll = tabBar:FindFirstChild("tablist")
	if not tabScroll then
		tabScroll = Instance.new("ScrollingFrame")
		tabScroll.Name = "tablist"
		tabScroll.Size = UDim2.new(1, -12, 1, -8)
		tabScroll.Position = UDim2.new(0, 6, 0, 4)
		tabScroll.BackgroundTransparency = 1
		tabScroll.BorderSizePixel = 0
		tabScroll.ScrollBarThickness = 2
		tabScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
		tabScroll.ScrollBarImageTransparency = 0.4
		tabScroll.ScrollingDirection = Enum.ScrollingDirection.X
		tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
		tabScroll.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		tabScroll.ScrollingEnabled = true
		tabScroll.Active = true
		tabScroll.Parent = tabBar
		pad(tabScroll, 0, 0, 4, 4)
	end
	tabScroll.CanvasSize = UDim2.new()
	local tabLayout = tabScroll:FindFirstChildOfClass("UIListLayout")
	if not tabLayout then
		tabLayout = Instance.new("UIListLayout", tabScroll)
		tabLayout.FillDirection = Enum.FillDirection.Horizontal
		tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tabLayout.Padding = UDim.new(0, 8)
		tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	end
	local hubConfig = genv.ZyrixHubConfig
	local tabNames = {}
	local elementsByTab = nil
	if #HubRegistry.tabs > 0 then
		for _, tab in ipairs(HubRegistry.tabs) do
			table.insert(tabNames, tab.Name)
		end
	elseif hubConfig and hubConfig.Tabs then
		tabNames = hubConfig.Tabs
		elementsByTab = hubConfig.Elements
	else
		tabNames = { "Combat", "Visuals", "Movement", "Misc" }
	end
	local tabButtons = {}
	local tabPages = {}
	local tabPageCols = {}
	local syncPageHeight
	local activeTab = tabNames[1] or "Combat"
	local uiExpanded = false
	local uiAnimating = false
	local firstOpen = true
	local expandPanel, collapsePanel, hideUI, showUI
	local main = root:FindFirstChild("main")
	if not main then
		main = frame({
			Name = "main",
			Size = UDim2.new(0, WIN_W, 0, WIN_H),
			Position = UDim2.new(0, 0, 0, TAB_H + GAP),
			BackgroundColor3 = C.WIN,
			ClipsDescendants = true,
			Active = true,
			Parent = root,
		})
		corner(main, UDim.new(0, 16))
		stroke(main, C.STROKE)
	else
		main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
		if not root:FindFirstChildOfClass("UIListLayout") then
			main.Position = UDim2.new(0, 0, 0, TAB_H + GAP)
		end
		main.ClipsDescendants = true
		main.Active = true
		if not _templateRoot:GetAttribute("Color_WIN") then
			C.WIN = main.BackgroundColor3
		end
		local ms = main:FindFirstChildOfClass("UIStroke")
		if ms then
			if not _templateRoot:GetAttribute("Color_STROKE") then
				C.STROKE = ms.Color
			end
		end
	end
	local function styleTab(name, selected)
		local b = tabButtons[name]
		if not b then return end
		local activeCol = b:GetAttribute("ActiveColor") or C.TAB_ACTIVE
		local idleCol = b:GetAttribute("IdleColor") or C.TAB_IDLE
		local activeText = b:GetAttribute("ActiveTextColor") or C.WHITE
		local idleText = b:GetAttribute("IdleTextColor") or C.TEXT_DIM
		tw(b, 0.18, {
			BackgroundColor3 = selected and activeCol or idleCol,
			TextColor3 = selected and activeText or idleText,
		})
		local ind = b:FindFirstChild("ActiveIndicator")
		if ind then
			ind.Visible = selected
			tw(ind, 0.18, {BackgroundTransparency = selected and 0 or 1})
		end
	end
	local elements
	local function refreshScroll()
		if elements and elements.Parent then
			local saved = elements.CanvasPosition
			elements.CanvasPosition = Vector2.new(0, 0)
			task.defer(function()
				if elements and elements.Parent then
					elements.CanvasPosition = saved
				end
			end)
		end
	end
	local function selectTab(name, shouldExpand)
		activeTab = name
		for _, n in ipairs(tabNames) do
			styleTab(n, n == name)
			local page = tabPages[n]
			if page then page.Visible = (n == name) end
		end
		if openDropdown then openDropdown:SetAttribute("ForceClose", true) end
		elements.CanvasPosition = Vector2.new(0, 0)
		if syncPageHeight then syncPageHeight(name) end
		refreshScroll()
		if shouldExpand and not uiExpanded and not uiAnimating and expandPanel then
			task.spawn(expandPanel)
		end
	end
	for _, child in ipairs(tabScroll:GetChildren()) do
		if child:IsA("TextButton") then
			local found = false
			for _, name in ipairs(tabNames) do
				if child.Name == name then found = true break end
			end
			if not found then
				child:Destroy()
			end
		end
	end
	for i, name in ipairs(tabNames) do
		local t = tabScroll:FindFirstChild(name)
		if t and t:IsA("TextButton") and not t:GetAttribute("_zyrixConnected") then
			t.LayoutOrder = i
			t.Size = UDim2.new(0, 91, 0, 33)
			t.AutomaticSize = Enum.AutomaticSize.None
			t.TextSize = 13
			t.Font = Enum.Font.GothamMedium
			t.TextXAlignment = Enum.TextXAlignment.Center
			t.TextYAlignment = Enum.TextYAlignment.Center
			local activeCol = t:GetAttribute("ActiveColor") or C.TAB_ACTIVE
			local idleCol = t:GetAttribute("IdleColor") or C.TAB_IDLE
			local activeText = t:GetAttribute("ActiveTextColor") or C.WHITE
			local idleText = t:GetAttribute("IdleTextColor") or C.TEXT_DIM
			t.BackgroundColor3 = name == activeTab and activeCol or idleCol
			t.TextColor3 = name == activeTab and activeText or idleText
		else
			t = btn({
				Name = name,
				Parent = tabScroll,
				Size = UDim2.new(0, 91, 0, 33),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundColor3 = name == activeTab and C.TAB_ACTIVE or C.TAB_IDLE,
				BackgroundTransparency = 0,
				LayoutOrder = i,
				Font = Enum.Font.GothamMedium,
				TextSize = 13,
				Text = name,
				TextColor3 = name == activeTab and C.WHITE or C.TEXT_DIM,
			})
			corner(t, UDim.new(1, 0))
			stroke(t, C.STROKE_IN, 0.8)
			pad(t, 0, 0, 14, 14)
			local ind = frame({
				Name = "ActiveIndicator",
				Size = UDim2.new(0.55, 0, 0, 2),
				Position = UDim2.new(0.225, 0, 1, -4),
				BackgroundColor3 = C.WHITE,
				BackgroundTransparency = name == activeTab and 0 or 1,
				Visible = name == activeTab,
				Parent = t,
			})
			corner(ind, UDim.new(1, 0))
		end
		t.MouseButton1Click:Connect(function() selectTab(name, true) end)
		t.MouseEnter:Connect(function()
			if activeTab ~= name then
				local hoverCol = t:GetAttribute("HoverColor") or C.HOVER
				tw(t, 0.12, {BackgroundColor3 = hoverCol})
			end
		end)
		t.MouseLeave:Connect(function()
			if activeTab ~= name then
				local idleCol = t:GetAttribute("IdleColor") or C.TAB_IDLE
				tw(t, 0.12, {BackgroundColor3 = idleCol})
			end
		end)
		t:SetAttribute("_zyrixConnected", true)
		tabButtons[name] = t
	end
	local doorOverlay = main:FindFirstChild("DoorOverlay")
	if not doorOverlay or doorOverlay.ClassName ~= "Frame" then
		if doorOverlay then doorOverlay:Destroy() end
		doorOverlay = Instance.new("Frame")
		doorOverlay.Name = "DoorOverlay"
		doorOverlay.BorderSizePixel = 0
		doorOverlay.Size = UDim2.new(1, 0, 1, 0)
		doorOverlay.BackgroundTransparency = 1
		doorOverlay.ClipsDescendants = true
		doorOverlay.ZIndex = 50
		doorOverlay.Active = false
		doorOverlay.Parent = main
	end
	local leftDoor = doorOverlay:FindFirstChild("LeftDoor")
	if not leftDoor then
		leftDoor = frame({ Name = "LeftDoor", Size = UDim2.new(0.5, 0, 1, 0), BackgroundColor3 = C.DOOR, ZIndex = 51, Parent = doorOverlay })
	else
		if not _templateRoot:GetAttribute("Color_DOOR") then
			C.DOOR = leftDoor.BackgroundColor3
		end
	end
	local mainCornerRadius = (main:FindFirstChildOfClass("UICorner") and main:FindFirstChildOfClass("UICorner").CornerRadius.Offset) or 16
	local doc = doorOverlay:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", doorOverlay)
	doc.CornerRadius = UDim.new(0, mainCornerRadius)
	local ldc = leftDoor:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", leftDoor)
	ldc.CornerRadius = UDim.new(0, 0)
	ldc.TopLeftRadius = UDim.new(0, mainCornerRadius)
	ldc.BottomLeftRadius = UDim.new(0, mainCornerRadius)
	ldc.TopRightRadius = UDim.new(0, 0)
	ldc.BottomRightRadius = UDim.new(0, 0)
	local rightDoor = doorOverlay:FindFirstChild("RightDoor")
	if not rightDoor then
		rightDoor = frame({ Name = "RightDoor", Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), BackgroundColor3 = C.DOOR, ZIndex = 51, Parent = doorOverlay })
	else
		if not _templateRoot:GetAttribute("Color_DOOR") then
			C.DOOR = rightDoor.BackgroundColor3
		end
	end
	local rdc = rightDoor:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", rightDoor)
	rdc.CornerRadius = UDim.new(0, 0)
	rdc.TopRightRadius = UDim.new(0, mainCornerRadius)
	rdc.BottomRightRadius = UDim.new(0, mainCornerRadius)
	rdc.TopLeftRadius = UDim.new(0, 0)
	rdc.BottomLeftRadius = UDim.new(0, 0)
	local doorLogo = doorOverlay:FindFirstChild("DoorLogo")
	if not doorLogo then
		doorLogo = Instance.new("ImageLabel")
		doorLogo.Name = "DoorLogo"
		doorLogo.Size = UDim2.new(0, 72, 0, 72)
		doorLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
		doorLogo.AnchorPoint = Vector2.new(0.5, 0.5)
		doorLogo.BackgroundTransparency = 1
		doorLogo.ScaleType = Enum.ScaleType.Fit
		doorLogo.ZIndex = 54
		doorLogo.Parent = doorOverlay
	end
	doorLogo.Image = Zyrix.Appearance.Icon
	if not (_templateRoot and _templateRoot:GetAttribute("Color_WHITE")) then
		doorLogo.ImageColor3 = C.WHITE
	end
	local halfW = math.ceil(WIN_W / 2)
	local function resetDoorsClosed()
		doorOverlay.Visible = true
		doorOverlay.Active = true
		leftDoor.Position = UDim2.new(0, 0, 0, 0)
		rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
		doorLogo.ImageTransparency = 0
	end
	local function playOpenDoors(done)
		task.spawn(function()
			tw(doorLogo, 0.2, {ImageTransparency = 1})
			task.wait(0.22)
			tw(leftDoor, 0.42, {Position = UDim2.new(0, -halfW, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			tw(rightDoor, 0.42, {Position = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			task.wait(0.44)
			doorOverlay.Visible = false
			doorOverlay.Active = false
			if done then done() end
		end)
	end
	local function playCloseDoors(done)
		task.spawn(function()
			doorOverlay.Visible = true
			doorOverlay.Active = true
			leftDoor.Position = UDim2.new(0, -halfW, 0, 0)
			rightDoor.Position = UDim2.new(1, 0, 0, 0)
			doorLogo.ImageTransparency = 1
			tw(leftDoor, 0.36, {Position = UDim2.new(0, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			tw(rightDoor, 0.36, {Position = UDim2.new(0.5, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			task.wait(0.38)
			tw(doorLogo, 0.25, {ImageTransparency = 0})
			task.wait(0.28)
			if done then done() end
		end)
	end
	resetDoorsClosed()
	local header = main:FindFirstChild("Header")
	if not header then
		header = frame({ Name = "Header", Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1, Active = true, Parent = main })
	else
		header.Active = true
	end
	local logoBtn = header:FindFirstChild("openTab")
	if not logoBtn then
		logoBtn = btn({ Name = "openTab", Parent = header, Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 8, 0.5, -16), BackgroundTransparency = 1 })
	end
	local logoImg = logoBtn:FindFirstChildOfClass("ImageLabel")
	if not logoImg then
		logoImg = Instance.new("ImageLabel")
		logoImg.Size = UDim2.new(1, 0, 1, 0)
		logoImg.BackgroundTransparency = 1
		logoImg.ScaleType = Enum.ScaleType.Fit
		logoImg.Parent = logoBtn
	end
	logoImg.Image = Zyrix.Appearance.Icon
	if not (_templateRoot and _templateRoot:GetAttribute("Color_TEXT")) then
		logoImg.ImageColor3 = C.TEXT
	end
	local hubTitle = (HubRegistry.windowConfig and HubRegistry.windowConfig.Name) or Zyrix.Appearance.Title or "B4TMAN // Interface"
	local titleLabel = header:FindFirstChild("Title")
	if not titleLabel then
		titleLabel = lbl({ Parent = header, Name = "Title", Size = UDim2.new(1, -58, 0, 20), Position = UDim2.new(0, 48, 0, 2), Text = hubTitle, Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = C.TEXT })
	else
		titleLabel.Text = hubTitle
		if not _templateRoot:GetAttribute("Color_TEXT") then
			C.TEXT = titleLabel.TextColor3
		end
	end
	local subtitleLabel = header:FindFirstChild("Subtitle")
	if not subtitleLabel then
		subtitleLabel = lbl({ Parent = header, Name = "Subtitle", Size = UDim2.new(1, -58, 0, 14), Position = UDim2.new(0, 48, 0, 20), Text = Zyrix.Appearance.Subtitle or "TACTICAL OPERATING SYSTEM", Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = C.TEXT_DIM })
	else
		subtitleLabel.Text = Zyrix.Appearance.Subtitle or "TACTICAL OPERATING SYSTEM"
	end
	local headerDivider = main:FindFirstChild("HeaderDivider")
	if not headerDivider then
		headerDivider = frame({ Name = "HeaderDivider", Size = UDim2.new(1, -16, 0, 1), Position = UDim2.new(0, 8, 0, 38), BackgroundColor3 = C.STROKE_IN, BackgroundTransparency = 0.35, Parent = main })
	else
		if not _templateRoot:GetAttribute("Color_STROKE_IN") then
			C.STROKE_IN = headerDivider.BackgroundColor3
		end
	end
	elements = main:FindFirstChild("elements")
	if not elements then
		elements = Instance.new("ScrollingFrame")
		elements.Name = "elements"
		elements.Size = UDim2.new(1, -16, 1, -48)
		elements.Position = UDim2.new(0, 8, 0, 44)
		elements.BackgroundTransparency = 1
		elements.BorderSizePixel = 0
		elements.ScrollBarThickness = 3
		elements.ScrollBarImageColor3 = C.TEXT_GREY
		elements.ScrollBarImageTransparency = 0.25
		elements.AutomaticCanvasSize = Enum.AutomaticSize.Y
		elements.ScrollingEnabled = true
		elements.Active = true
		elements.ClipsDescendants = true
		elements.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		elements.ScrollingDirection = Enum.ScrollingDirection.Y
		elements.Parent = main
		pad(elements, 6, 10, 4, 4)
	end
	elements.CanvasSize = UDim2.new(0, 0, 0, CONTENT_H)
	for _, child in ipairs(elements:GetChildren()) do
		local n = child.Name
		if n ~= "PageHost" and not child:IsA("UIPadding") and not child:IsA("UIListLayout") then
			child:Destroy()
		end
	end
	local pageHost = elements:FindFirstChild("PageHost")
	if not pageHost then
		pageHost = frame({
			Name = "PageHost",
			Size = UDim2.new(1, 0, 0, CONTENT_H),
			BackgroundTransparency = 1,
			Parent = elements,
		})
	else
		pageHost:ClearAllChildren()
	end
	pageHost.Size = UDim2.new(1, 0, 0, CONTENT_H)
	pageHost.BackgroundTransparency = 1
	syncPageHeight = function(tabName)
		local cols = tabPageCols[tabName]
		local page = tabPages[tabName]
		if not cols or not page then return end
		local body = page:FindFirstChild("Body")
		if not body then return end
		local contentH = math.max(cols.left.AbsoluteSize.Y, cols.right.AbsoluteSize.Y, 1)
		local h = math.max(contentH, CONTENT_H)
		body.Size = UDim2.new(1, 0, 0, h)
		page.Size = UDim2.new(1, 0, 0, h)
		if tabName == activeTab then
			pageHost.Size = UDim2.new(1, 0, 0, h)
			elements.CanvasSize = UDim2.new(0, 0, 0, h)
			refreshScroll()
		end
	end
	local function bindColumnAutoHeight(tabName, col, layout)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			col.Size = UDim2.new(col.Size.X.Scale, col.Size.X.Offset, 0, layout.AbsoluteContentSize.Y)
			syncPageHeight(tabName)
		end)
	end
	local function makePage(tabName)
		local page = frame({
			Name = tabName .. "Page",
			Size = UDim2.new(1, 0, 0, CONTENT_H),
			BackgroundTransparency = 1,
			Visible = tabName == activeTab,
			Parent = pageHost,
		})
		local body = frame({
			Name = "Body",
			Size = UDim2.new(1, 0, 0, CONTENT_H),
			BackgroundTransparency = 1,
			Parent = page,
		})
		local leftCol = frame({
			Name = "LeftCol",
			Size = UDim2.new(0.55, -4, 0, 0),
			BackgroundColor3 = C.PANEL,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			Parent = body,
		})
		corner(leftCol, UDim.new(0, 2))
		local leftList = Instance.new("UIListLayout", leftCol)
		leftList.SortOrder = Enum.SortOrder.LayoutOrder
		leftList.Padding = UDim.new(0, 2)
		local rightCol = frame({
			Name = "RightCol",
			Size = UDim2.new(0.45, -4, 0, 0),
			Position = UDim2.new(0.55, 4, 0, 0),
			BackgroundTransparency = 1,
			Parent = body,
		})
		local rightList = Instance.new("UIListLayout", rightCol)
		rightList.SortOrder = Enum.SortOrder.LayoutOrder
		rightList.Padding = UDim.new(0, 2)
		bindColumnAutoHeight(tabName, leftCol, leftList)
		bindColumnAutoHeight(tabName, rightCol, rightList)
		tabPages[tabName] = page
		tabPageCols[tabName] = { left = leftCol, right = rightCol }
		return leftCol, rightCol
	end
	local function getElementParent(tabName, itemType, side)
		local cols = tabPageCols[tabName]
		if not cols then return nil end
		local s = string.lower(side or "")
		if s == "right" then return cols.right end
		if s == "left" then return cols.left end
		if string.lower(itemType or "") == "dropdown" then return cols.right end
		return cols.left
	end
	local function row(parent, name, height, order)
		local hasContent = false
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("GuiObject") and not child:IsA("UIPadding") and not child:IsA("UIListLayout") then
				hasContent = true
				break
			end
		end
		if hasContent then
			frame({
				Name = "Divider",
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = C.DIVIDER,
				BackgroundTransparency = 0.3,
				LayoutOrder = order * 2 - 1,
				Parent = parent,
			})
		end
		local f = frame({
			Name = name,
			Size = UDim2.new(1, 0, 0, height or ROW_H),
			BackgroundColor3 = C.PANEL,
			BackgroundTransparency = 0,
			LayoutOrder = order * 2,
			Parent = parent,
		})
		pad(f, 8, 8, 14, 14)
		return f
	end
	local function sectionLabel(parent, text, order)
		lbl({
			Parent = parent,
			Size = UDim2.new(1, 0, 0, 20),
			LayoutOrder = order,
			Text = text,
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = C.TEXT_DIM,
		})
	end
	local function addToggle(parent, title, order, defaultOn, callback, el)
		local toggleRow = row(parent, "Toggle", ROW_H, order)
		lbl({ Parent = toggleRow, Size = UDim2.new(1, -56, 1, 0), Text = title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.TEXT })
		local switch = frame({ Parent = toggleRow, Size = UDim2.new(0, 42, 0, 22), Position = UDim2.new(1, -48, 0.5, -11), BackgroundColor3 = defaultOn and C.STROKE_IN or C.INNER })
		corner(switch, UDim.new(1, 0))
		stroke(switch, C.STROKE_IN)
		local knob = frame({
			Parent = switch,
			Size = UDim2.new(0, 18, 0, 18),
			Position = defaultOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
			BackgroundColor3 = defaultOn and C.KNOB_ON or C.KNOB_OFF,
		})
		corner(knob, UDim.new(1, 0))
		local on = defaultOn == true
		local function applyState(state, skipCb)
			on = state == true
			tw(knob, 0.15, {
				Position = on and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
				BackgroundColor3 = on and C.KNOB_ON or C.KNOB_OFF,
			})
			tw(switch, 0.15, {
				BackgroundColor3 = on and C.STROKE_IN or C.INNER,
			})
			if callback and not skipCb then callback(on) end
		end
		if el then el._apply = applyState end
		local toggleBtn = btn({ Parent = toggleRow, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2 })
		toggleBtn.MouseEnter:Connect(function() tw(toggleRow, 0.12, {BackgroundColor3 = C.INNER}) end)
		toggleBtn.MouseLeave:Connect(function() tw(toggleRow, 0.12, {BackgroundColor3 = C.PANEL}) end)
		toggleBtn.MouseButton1Click:Connect(function()
			applyState(not on)
		end)
	end
	local function addSlider(parent, title, order, defaultPct, callback, suffix, maxValue, el)
		local sliderRow = row(parent, "Slider", SLIDER_ROW_H, order)
		lbl({ Parent = sliderRow, Size = UDim2.new(0.45, 0, 1, 0), Text = title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.TEXT })
		local sliderTrack = frame({ Name = "SliderTrack", Parent = sliderRow, Size = UDim2.new(0.52, 0, 0, 24), Position = UDim2.new(0.46, 0, 0.5, -12), BackgroundColor3 = C.INNER })
		corner(sliderTrack, UDim.new(0, 4))
		stroke(sliderTrack, C.STROKE_IN)
		local sliderFill = frame({ Name = "Progress", Parent = sliderTrack, Size = UDim2.new(defaultPct, 0, 1, 0), BackgroundColor3 = C.PROGRESS })
		corner(sliderFill, UDim.new(0, 4))
		maxValue = maxValue or (suffix and 1000 or 100)
		local minValue = (el and el.Min) or 0
		if el and el.Max and el.Min then
			maxValue = math.max(el.Max - el.Min, 1)
		end
		local function formatSlider(pct)
			local val = math.floor(minValue + pct * maxValue)
			if suffix then return tostring(val) .. suffix end
			return tostring(val) .. "%"
		end
		local sliderInfo = lbl({
			Parent = sliderTrack,
			Size = UDim2.new(1, -8, 1, 0),
			Position = UDim2.new(0, 4, 0, 0),
			Text = formatSlider(defaultPct),
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = C.TEXT_GREY,
			TextTransparency = 0.3,
			ZIndex = 2,
		})
		local function setSlider(pct, skipCb, instant)
			pct = math.clamp(pct, 0, 1)
			if instant then
				sliderFill.Size = UDim2.new(pct, 0, 1, 0)
			else
				tw(sliderFill, 0.12, {Size = UDim2.new(pct, 0, 1, 0)})
			end
			sliderInfo.Text = formatSlider(pct)
			if callback and not skipCb then
				local val = minValue + pct * maxValue
				callback(val)
			end
		end
		if el then el._apply = function(pct, skipCb) setSlider(pct, skipCb) end end
		sliderRegistry[sliderTrack] = setSlider
		setSlider(defaultPct, true, true)
		btn({ Parent = sliderTrack, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3 }).InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliderDragTrack = sliderTrack
				local ax, aw = sliderTrack.AbsolutePosition.X, sliderTrack.AbsoluteSize.X
				setSlider((input.Position.X - ax) / aw, nil, true)
			end
		end)
	end
	local function addButton(parent, title, order, callback)
		local btnRow = row(parent, "Button", ROW_H, order)
		lbl({ Parent = btnRow, Size = UDim2.new(0.7, 0, 1, 0), Text = title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.TEXT })
		local btnHint = lbl({
			Parent = btnRow,
			Size = UDim2.new(0.3, 0, 1, 0),
			Position = UDim2.new(0.7, 0, 0, 0),
			Text = "Button",
			TextXAlignment = Enum.TextXAlignment.Right,
			TextTransparency = 0.5,
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = C.TEXT_GREY,
		})
		local hoverBtn = btn({ Parent = btnRow, Size = UDim2.new(1, 0, 1, 0), ZIndex = 2 })
		hoverBtn.MouseEnter:Connect(function()
			tw(btnRow, 0.12, {BackgroundColor3 = C.INNER})
			tw(btnHint, 0.12, {TextTransparency = 0})
		end)
		hoverBtn.MouseLeave:Connect(function()
			tw(btnRow, 0.12, {BackgroundColor3 = C.PANEL})
			tw(btnHint, 0.12, {TextTransparency = 0.5})
		end)
		hoverBtn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)
	end
	local function addDropdown(parent, title, order, options, defaultIndex, callback, el)
		local ddContainer, ddTitle, ddSelected, ddArrow, ddInteract, ddList
		ddContainer = Instance.new("Frame")
		ddContainer.Name = "Dropdown"
		ddContainer.Size = UDim2.new(1, 0, 0, 0)
		ddContainer.AutomaticSize = Enum.AutomaticSize.Y
		ddContainer.BackgroundColor3 = C.PANEL
		ddContainer.BorderSizePixel = 0
		ddContainer.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddContainer.LayoutOrder = order * 2
		ddContainer.Parent = parent
		local hasContent = false
		for _, child in ipairs(parent:GetChildren()) do
			if child:IsA("GuiObject") and not child:IsA("UIPadding") and not child:IsA("UIListLayout") and child ~= ddContainer then
				hasContent = true
				break
			end
		end
		if hasContent then
			frame({
				Name = "Divider",
				Size = UDim2.new(1, 0, 0, 2),
				BackgroundColor3 = C.DIVIDER,
				BackgroundTransparency = 0.3,
				LayoutOrder = order * 2 - 1,
				Parent = parent,
			})
		end
		local ddStroke = Instance.new("UIStroke")
		ddStroke.Color = C.STROKE
		ddStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ddStroke.Parent = ddContainer
		local ddPad = Instance.new("UIPadding")
		ddPad.PaddingTop = UDim.new(0, 8)
		ddPad.PaddingRight = UDim.new(0, 14)
		ddPad.PaddingLeft = UDim.new(0, 14)
		ddPad.PaddingBottom = UDim.new(0, 8)
		ddPad.Parent = ddContainer
		ddTitle = Instance.new("TextLabel")
		ddTitle.Name = "Title"
		ddTitle.ZIndex = 2
		ddTitle.BorderSizePixel = 0
		ddTitle.TextSize = 13
		ddTitle.TextXAlignment = Enum.TextXAlignment.Left
		ddTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ddTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		ddTitle.TextColor3 = Color3.fromRGB(235, 235, 235)
		ddTitle.BackgroundTransparency = 1
		ddTitle.Size = UDim2.new(0, 100, 0, 24)
		ddTitle.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddTitle.Text = title
		ddTitle.Position = UDim2.new(0, 0, 0, 0)
		ddTitle.Parent = ddContainer
		ddSelected = Instance.new("TextLabel")
		ddSelected.Name = "Selected"
		ddSelected.ZIndex = 2
		ddSelected.BorderSizePixel = 0
		ddSelected.TextSize = 12
		ddSelected.TextXAlignment = Enum.TextXAlignment.Right
		ddSelected.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ddSelected.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		ddSelected.TextColor3 = Color3.fromRGB(170, 170, 170)
		ddSelected.BackgroundTransparency = 1
		ddSelected.AnchorPoint = Vector2.new(1, 0)
		ddSelected.Size = UDim2.new(0, 70, 0, 24)
		ddSelected.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddSelected.Text = options[defaultIndex or 1] or options[1] or ""
		ddSelected.Position = UDim2.new(1, -32, 0, 0)
		ddSelected.Parent = ddContainer
		ddArrow = Instance.new("ImageButton")
		ddArrow.Name = "Toggle"
		ddArrow.BorderSizePixel = 0
		ddArrow.ScaleType = Enum.ScaleType.Fit
		ddArrow.BackgroundTransparency = 1
		ddArrow.ImageColor3 = Color3.fromRGB(170, 170, 170)
		ddArrow.ZIndex = 2
		ddArrow.Image = "rbxassetid://3926305904"
		ddArrow.ImageRectSize = Vector2.new(36, 36)
		ddArrow.Size = UDim2.new(0, 20, 0, 20)
		ddArrow.LayoutOrder = 9
		ddArrow.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddArrow.ImageRectOffset = Vector2.new(564, 284)
		ddArrow.Position = UDim2.new(1, -24, 0, 2)
		ddArrow.Parent = ddContainer
		ddInteract = Instance.new("TextButton")
		ddInteract.Name = "Interact"
		ddInteract.BorderSizePixel = 0
		ddInteract.TextTransparency = 1
		ddInteract.TextSize = 12
		ddInteract.AutoButtonColor = false
		ddInteract.TextColor3 = Color3.fromRGB(255, 255, 255)
		ddInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ddInteract.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		ddInteract.ZIndex = 5
		ddInteract.BackgroundTransparency = 1
		ddInteract.Size = UDim2.new(1, 0, 0, 24)
		ddInteract.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddInteract.Text = ""
		ddInteract.Parent = ddContainer
		local clipFrame = Instance.new("Frame")
		clipFrame.Name = "Clip"
		clipFrame.ZIndex = 2
		clipFrame.BorderSizePixel = 0
		clipFrame.BackgroundTransparency = 0
		clipFrame.BackgroundColor3 = C.DD_LIST
		clipFrame.Size = UDim2.new(1, 0, 0, 0)
		clipFrame.Position = UDim2.new(0, 0, 0, 24)
		clipFrame.ClipsDescendants = true
		clipFrame.Visible = false
		clipFrame.Parent = ddContainer
		local clipCorner = Instance.new("UICorner")
		clipCorner.CornerRadius = UDim.new(0, 6)
		clipCorner.Parent = clipFrame
		local clipStroke = Instance.new("UIStroke")
		clipStroke.Color = C.STROKE
		clipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		clipStroke.Parent = clipFrame
		ddList = Instance.new("ScrollingFrame")
		ddList.Name = "List"
		ddList.Active = true
		ddList.ZIndex = 2
		ddList.BorderSizePixel = 0
		ddList.CanvasSize = UDim2.new(0, 0, 0, 0)
		ddList.ScrollBarImageTransparency = 0.7
		ddList.BackgroundColor3 = C.DD_LIST
		ddList.AutomaticCanvasSize = Enum.AutomaticSize.Y
		ddList.Size = UDim2.new(1, 0, 0, 0)
		ddList.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
		ddList.Position = UDim2.new(0, 0, 0, 0)
		ddList.BorderColor3 = Color3.fromRGB(28, 43, 54)
		ddList.ScrollBarThickness = 2
		ddList.ClipsDescendants = true
		ddList.Visible = true
		ddList.ScrollingEnabled = true
		ddList.ScrollingDirection = Enum.ScrollingDirection.Y
		ddList.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		ddList.Parent = clipFrame
		local ddListCorner = Instance.new("UICorner")
		ddListCorner.CornerRadius = UDim.new(0, 6)
		ddListCorner.Parent = ddList
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 4)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = ddList
		local listPad = Instance.new("UIPadding")
		listPad.PaddingTop = UDim.new(0, 4)
		listPad.PaddingRight = UDim.new(0, 4)
		listPad.PaddingLeft = UDim.new(0, 4)
		listPad.PaddingBottom = UDim.new(0, 4)
		listPad.Parent = ddList
		local ddOpen = false
		local function setOpen(state)
			if state and openDropdown and openDropdown ~= ddContainer then
				openDropdown:SetAttribute("ForceClose", true)
			end
			ddOpen = state
			if elements then elements.ScrollingEnabled = not state end
			if state then
				clipFrame.Visible = true
				local contentH = 0
				local ll = ddList:FindFirstChildOfClass("UIListLayout")
				if ll then contentH = ll.AbsoluteContentSize.Y end
				local padH = 0
				local dp = ddList:FindFirstChildOfClass("UIPadding")
				if dp then padH = dp.PaddingTop.Offset + dp.PaddingBottom.Offset end
				local maxH = 150
				local targetH = math.min(contentH + padH, maxH)
				ddList.Size = UDim2.new(1, 0, 0, targetH)
				ddList.CanvasSize = UDim2.new(0, 0, 0, contentH + padH)
				clipFrame.Size = UDim2.new(1, 0, 0, 0)
				tw(clipFrame, 0.18, {Size = UDim2.new(1, 0, 0, targetH)})
			else
				tw(clipFrame, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
				task.delay(0.15, function()
					if not ddOpen then clipFrame.Visible = false end
				end)
			end
			if ddArrow then tw(ddArrow, 0.12, {Rotation = state and 180 or 0}) end
			openDropdown = state and ddContainer or (openDropdown == ddContainer and nil or openDropdown)
			refreshScroll()
		end
		ddContainer:GetAttributeChangedSignal("ForceClose"):Connect(function()
			if ddContainer:GetAttribute("ForceClose") then
				ddContainer:SetAttribute("ForceClose", false)
				setOpen(false)
			end
		end)
		local function createOptionItem(i, opt)
			local item = Instance.new("Frame")
			item.Name = "Option" .. i
			item.ZIndex = 3
			item.BorderSizePixel = 0
			item.BackgroundColor3 = C.DD_ITEM
			item.Size = UDim2.new(1, 0, 0, 36)
			item.BorderColor3 = Color3.fromRGB(28, 43, 54)
			item.LayoutOrder = i
			item.Parent = ddList
			local itemStroke = Instance.new("UIStroke")
			itemStroke.Color = C.STROKE_IN
			itemStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			itemStroke.Parent = item
			local itemCorner = Instance.new("UICorner")
			itemCorner.CornerRadius = UDim.new(0, 4)
			itemCorner.Parent = item
			local itemTitle = Instance.new("TextLabel")
			itemTitle.Name = "Title"
			itemTitle.ZIndex = 4
			itemTitle.BorderSizePixel = 0
			itemTitle.TextSize = 12
			itemTitle.TextXAlignment = Enum.TextXAlignment.Left
			itemTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			itemTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			itemTitle.TextColor3 = Color3.fromRGB(235, 235, 235)
			itemTitle.BackgroundTransparency = 1
			itemTitle.Size = UDim2.new(1, -12, 1, 0)
			itemTitle.BorderColor3 = Color3.fromRGB(28, 43, 54)
			itemTitle.Text = opt
			itemTitle.Position = UDim2.new(0, 6, 0, 0)
			itemTitle.Parent = item
			local itemInteract = Instance.new("TextButton")
			itemInteract.Name = "Interact"
			itemInteract.BorderSizePixel = 0
			itemInteract.TextSize = 1
			itemInteract.AutoButtonColor = false
			itemInteract.TextColor3 = Color3.fromRGB(0, 0, 0)
			itemInteract.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			itemInteract.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
			itemInteract.ZIndex = 4
			itemInteract.BackgroundTransparency = 1
			itemInteract.Size = UDim2.new(1, 0, 1, 0)
			itemInteract.BorderColor3 = Color3.fromRGB(28, 43, 54)
			itemInteract.Text = ""
			itemInteract.Parent = item
			itemInteract.MouseButton1Click:Connect(function()
				if ddSelected then ddSelected.Text = opt end
				setOpen(false)
				if callback then callback(opt) end
			end)
			itemInteract.MouseEnter:Connect(function() tw(item, 0.1, {BackgroundColor3 = C.STROKE}) end)
			itemInteract.MouseLeave:Connect(function() tw(item, 0.1, {BackgroundColor3 = C.DD_ITEM}) end)
		end
		for i, opt in ipairs(options) do
			createOptionItem(i, opt)
		end
		local function setOptions(newOptions)
			for _, child in ipairs(ddList:GetChildren()) do
				if child:IsA("Frame") and child.Name:match("^Option") then
					child:Destroy()
				end
			end
			for i, opt in ipairs(newOptions) do
				createOptionItem(i, opt)
			end
			if ddSelected then ddSelected.Text = newOptions[1] or options[defaultIndex or 1] or "" end
		end
		if el then
			el._apply = function(opt)
				if ddSelected then ddSelected.Text = tostring(opt) end
				if callback then callback(opt) end
			end
			el._setOptions = setOptions
		end
		local function toggleDropdown() setOpen(not ddOpen) end
		if ddInteract then ddInteract.MouseButton1Click:Connect(toggleDropdown) end
		if ddArrow then ddArrow.MouseButton1Click:Connect(toggleDropdown) end
	end
	local function resolveKeyCode(key)
		if typeof(key) == "EnumItem" then return key end
		if type(key) == "string" and Enum.KeyCode[key] then return Enum.KeyCode[key] end
		return Enum.KeyCode.Q
	end
	local function addKeybind(parent, title, order, defaultKey, callback)
		local keyRow = row(parent, "Keybind", ROW_H, order)
		lbl({ Parent = keyRow, Size = UDim2.new(1, -60, 1, 0), Text = title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.TEXT })
		local keyBox = frame({
			Parent = keyRow,
			Size = UDim2.new(0, 38, 0, 26),
			Position = UDim2.new(1, -44, 0.5, -13),
			BackgroundColor3 = C.INNER,
		})
		corner(keyBox, UDim.new(0, 4))
		stroke(keyBox, C.STROKE_IN)
		local currentKey = resolveKeyCode(defaultKey)
		local keyLabel = lbl({
			Parent = keyBox,
			Size = UDim2.new(1, 0, 1, 0),
			Text = currentKey.Name,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center,
			Font = Enum.Font.GothamMedium,
			TextSize = 13,
			TextColor3 = C.TEXT_DIM,
		})
		local capturing = false
		btn({ Parent = keyBox, Size = UDim2.new(1, 0, 1, 0), ZIndex = 3 }).MouseButton1Click:Connect(function()
			capturing = true
			keybindCapture = function(input)
				if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
					if input.KeyCode ~= Enum.KeyCode.Escape then
						currentKey = input.KeyCode
						keyLabel.Text = currentKey.Name
						if callback then callback(currentKey) end
					end
					capturing = false
					keybindCapture = nil
					return true
				end
				return false
			end
			keyLabel.Text = "..."
		end)
	end
	local function addInput(parent, title, order, placeholder, callback, el)
		local inputRow = row(parent, "Input", ROW_H, order)
		lbl({ Parent = inputRow, Size = UDim2.new(0.45, 0, 1, 0), Text = title, Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = C.TEXT })
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0.5, -8, 0, 26)
		box.Position = UDim2.new(0.5, 0, 0.5, -13)
		box.BackgroundColor3 = C.INNER
		box.TextColor3 = C.TEXT
		box.PlaceholderText = placeholder or ""
		box.PlaceholderColor3 = C.TEXT_DIM
		box.Font = Enum.Font.GothamMedium
		box.TextSize = 13
		box.Text = ""
		box.ClearTextOnFocus = false
		box.Parent = inputRow
		corner(box, UDim.new(0, 4))
		stroke(box, C.STROKE_IN)
		pad(box, 0, 0, 8, 8)
		if el then el._box = box end
		box.FocusLost:Connect(function()
			if callback then callback(box.Text) end
		end)
	end
	local function renderHubItem(tabName, i, item)
		local parent = getElementParent(tabName, item.Type, item.Side)
		if not parent then return end
		local t = string.lower(item.Type or "")
		if t == "section" then
			sectionLabel(parent, item.Text or "Section", i)
		elseif t == "toggle" then
			addToggle(parent, item.Text or "Toggle", i, item.Default == true, item.Callback, item)
		elseif t == "slider" then
			local minV = item.Min or 0
			local maxV = item.Max or 100
			local span = math.max(maxV - minV, 1)
			local cb = item.Callback
			addSlider(parent, item.Text or "Slider", i, item.Default or 0.5, cb, item.Suffix, span, item)
		elseif t == "keybind" then
			addKeybind(parent, item.Text or "Keybind", i, item.Default or "Q", item.Callback)
		elseif t == "dropdown" then
			addDropdown(parent, item.Text or "Dropdown", i, item.Options or {"Option 1"}, item.Default or 1, item.Callback, item)
		elseif t == "button" then
			addButton(parent, item.Text or "Button", i, item.Callback)
		elseif t == "input" then
			addInput(parent, item.Text or "Input", i, item.Placeholder, item.Callback, item)
		elseif t == "label" then
			lbl({ Parent = parent, Size = UDim2.new(1, 0, 0, 20), LayoutOrder = i, Text = item.Text or "", Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = C.TEXT_DIM })
		elseif t == "divider" then
			frame({ Parent = parent, Size = UDim2.new(1, 0, 0, 2), LayoutOrder = i, BackgroundColor3 = C.STROKE_IN, BackgroundTransparency = 0.35 })
		end
	end
	local function buildHubElements()
		if #HubRegistry.tabs > 0 then
			for _, tab in ipairs(HubRegistry.tabs) do
				makePage(tab.Name)
				for i, item in ipairs(tab.Elements) do
					renderHubItem(tab.Name, i, item)
				end
			end
			return true
		end
		if not elementsByTab then return false end
		local hasContent = false
		for _, tabName in ipairs(tabNames) do
			makePage(tabName)
			local items = elementsByTab[tabName]
			if items and #items > 0 then
				hasContent = true
				for i, item in ipairs(items) do
					renderHubItem(tabName, i, item)
				end
			end
		end
		return hasContent
	end
	if not buildHubElements() then
		local Demo = genv.ZyrixDemoState or {}
		genv.ZyrixDemoState = Demo
		Demo.Aimbot = Demo.Aimbot or false
		Demo.ESPRange = Demo.ESPRange or 750
		Demo.TargetPart = Demo.TargetPart or "Head"
		Demo.TargetKey = Demo.TargetKey or Enum.KeyCode.Q
		local combatLeft, combatRight = makePage("Combat")
		addButton(combatLeft, "Reset Aimbot System", 1, function()
			Demo.Aimbot = false
			Demo.ESPRange = 750
			Demo.TargetPart = "Head"
			Zyrix:Notify("Combat", "Aimbot reset", 2, "success")
		end)
		addSlider(combatLeft, "ESP Range", 2, Demo.ESPRange / 1000, function(v)
			Demo.ESPRange = math.floor(v)
		end, " studs", 1000)
		addToggle(combatLeft, "Aimbot", 3, Demo.Aimbot, function(on)
			Demo.Aimbot = on
		end)
		addKeybind(combatLeft, "Target Keybind", 4, Demo.TargetKey, function(key)
			Demo.TargetKey = key
		end)
		addDropdown(combatRight, "Dropdown", 1, {"Option #1", "Option #2", "Option #3", "Option #4"}, 1, function(opt)
			Demo.TargetPart = opt
		end)
		local visualsLeft, visualsRight = makePage("Visuals")
		sectionLabel(visualsLeft, "ESP", 1)
		addToggle(visualsLeft, "Player ESP", 2, false, function(on) Demo.ESP = on end)
		addSlider(visualsLeft, "ESP Range", 3, 0.75, function(v) Demo.ESPRange = math.floor(v) end, " studs", 1000)
		addDropdown(visualsRight, "ESP Style", 1, {"Box", "Corner", "Skeleton", "Highlight"}, 2, function(opt) Demo.ESPStyle = opt end)
		local movementLeft = makePage("Movement")
		sectionLabel(movementLeft, "Character", 1)
		addToggle(movementLeft, "Speed Boost", 2, false, function(on)
			Demo.SpeedBoost = on
			local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = on and 50 or 16 end
		end)
		addSlider(movementLeft, "Walk Speed", 3, 0.16, function(v)
			local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = 16 + math.floor(v * 0.84) end
		end, "", 100)
		addToggle(movementLeft, "Infinite Jump", 4, false, function(on) Demo.InfiniteJump = on end)
		local miscLeft, miscRight = makePage("Misc")
		sectionLabel(miscLeft, "Utility", 1)
		addButton(miscLeft, "Rejoin Server", 2, function()
			Zyrix:Notify("Misc", "Action triggered", 2, "copy")
		end)
		addDropdown(miscRight, "Theme Accent", 1, {"White", "Blue", "Purple", "Green"}, 1, function(opt) Demo.Theme = opt end)
	end
	for _, tabName in ipairs(tabNames) do
		task.defer(function() syncPageHeight(tabName) end)
	end
	selectTab(activeTab)
	local closeBtn = sg:FindFirstChild("CloseToggle")
	if not closeBtn then
		closeBtn = btn({
			Name = "CloseToggle",
			Parent = sg,
			Size = UDim2.new(0, 40, 0, 40),
			Position = UDim2.new(1, -14, 0, 14),
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = C.TAB_BAR,
			BackgroundTransparency = 0.05,
			Text = "OPEN",
			Font = Enum.Font.GothamBold,
			TextSize = 9,
			TextColor3 = C.TEXT,
			ZIndex = 20,
		})
		corner(closeBtn, UDim.new(1, 0))
		stroke(closeBtn, C.STROKE)
	else
		closeBtn.ZIndex = 20
		if not _templateRoot:GetAttribute("Color_TAB_BAR") then
			C.TAB_BAR = closeBtn.BackgroundColor3
		end
		if not _templateRoot:GetAttribute("Color_TEXT") then
			C.TEXT = closeBtn.TextColor3
		end
		local cs = closeBtn:FindFirstChildOfClass("UIStroke")
		if cs and not _templateRoot:GetAttribute("Color_STROKE") then
			C.STROKE = cs.Color
		end
	end
	closeBtn.MouseEnter:Connect(function() tw(closeBtn, 0.12, {BackgroundColor3 = C.HOVER}) end)
	closeBtn.MouseLeave:Connect(function() tw(closeBtn, 0.12, {BackgroundColor3 = C.TAB_BAR}) end)
	local TOTAL_H = TAB_H + GAP + WIN_H
	local dragging, dragStart, startPos = false, nil, nil
	local function updateCloseBtn()
		if not root.Visible or not uiExpanded then
			closeBtn.Text = "OPEN"
		else
			closeBtn.Text = "CLOSE"
		end
	end
	trackConnection(UIS.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		elseif sliderDragTrack and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local ax, aw = sliderDragTrack.AbsolutePosition.X, sliderDragTrack.AbsoluteSize.X
			local pct = math.clamp((input.Position.X - ax) / aw, 0, 1)
			local setSlider = sliderRegistry[sliderDragTrack]
			if setSlider then setSlider(pct, nil, true) end
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			local mouse = UIS:GetMouseLocation()
			local elemAp, elemAs = elements.AbsolutePosition, elements.AbsoluteSize
			if mouse.X >= elemAp.X and mouse.X <= elemAp.X + elemAs.X and mouse.Y >= elemAp.Y and mouse.Y <= elemAp.Y + elemAs.Y then
				local maxScroll = math.max(0, elements.AbsoluteCanvasSize.Y - elemAs.Y)
				if maxScroll > 0 then
					local scrollDelta = input.Position.Z
					if scrollDelta == 0 then scrollDelta = 1 end
					elements.CanvasPosition = Vector2.new(0, math.clamp(elements.CanvasPosition.Y - scrollDelta * 28, 0, maxScroll))
				end
			else
				local ap, as = tabScroll.AbsolutePosition, tabScroll.AbsoluteSize
				if mouse.X >= ap.X and mouse.X <= ap.X + as.X and mouse.Y >= ap.Y and mouse.Y <= ap.Y + as.Y then
					local maxScroll = math.max(0, tabScroll.AbsoluteCanvasSize.X - as.X)
					if maxScroll > 0 then
						local scrollDelta = input.Position.Z
						if scrollDelta == 0 then scrollDelta = 1 end
						tabScroll.CanvasPosition = Vector2.new(math.clamp(tabScroll.CanvasPosition.X - scrollDelta * 48, 0, maxScroll), 0)
					end
				end
			end
		end
	end))
	trackConnection(UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			sliderDragTrack = nil
			dragging = false
		end
	end))
	local function beginDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = root.Position
		end
	end
	local function isOverGuiObject(pos, guiObj)
		local ap, as = guiObj.AbsolutePosition, guiObj.AbsoluteSize
		return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
	end
	tabBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local pos = input.Position
		for _, child in ipairs(tabScroll:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible and isOverGuiObject(pos, child) then
				return
			end
		end
		beginDrag(input)
	end)
	header.InputBegan:Connect(beginDrag)
	main.InputBegan:Connect(function(input)
		if not uiExpanded then return end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local pos = input.Position
		if isOverGuiObject(pos, header) then return end
		if isOverGuiObject(pos, elements) then return end
		beginDrag(input)
	end)
	local function setCollapsed()
		root.Size = UDim2.new(0, WIN_W, 0, TAB_H)
		main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
		main.Position = UDim2.new(0, 0, 0, TAB_H + GAP)
		main.Visible = false
		doorOverlay.Visible = false
		doorOverlay.Active = false
		uiExpanded = false
		updateCloseBtn()
	end
	expandPanel = function(done)
		if uiAnimating then return end
		if uiExpanded then if done then done() end return end
		uiAnimating = true
		task.spawn(function()
			root.Visible = true
			root.Size = UDim2.new(0, WIN_W, 0, TAB_H)
			main.Visible = true
			main.Size = UDim2.new(0, WIN_W, 0, WIN_H)
			main.Position = UDim2.new(0, 0, 0, TAB_H + GAP - WIN_H)
			doorOverlay.Visible = true
			doorOverlay.Active = true
			leftDoor.Position = UDim2.new(0, 0, 0, 0)
			rightDoor.Position = UDim2.new(0.5, 0, 0, 0)
			doorLogo.ImageTransparency = 0
			tw(root, 0.4, {Size = UDim2.new(0, WIN_W, 0, TOTAL_H)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			tw(main, 0.4, {Position = UDim2.new(0, 0, 0, TAB_H + GAP)}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			task.wait(0.42)
			playOpenDoors(function()
				uiExpanded = true
				uiAnimating = false
				updateCloseBtn()
				if done then done() end
			end)
		end)
	end
	collapsePanel = function(done)
		if uiAnimating then return end
		if not uiExpanded then
			setCollapsed()
			if done then done() end
			return
		end
		uiAnimating = true
		if openDropdown then openDropdown:SetAttribute("ForceClose", true) end
		task.spawn(function()
			playCloseDoors(function()
				tw(main, 0.3, {Position = UDim2.new(0, 0, 0, TAB_H + GAP - WIN_H)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				tw(root, 0.3, {Size = UDim2.new(0, WIN_W, 0, TAB_H)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				task.wait(0.32)
				main.Visible = false
				main.Position = UDim2.new(0, 0, 0, TAB_H + GAP)
				root.Size = UDim2.new(0, WIN_W, 0, TAB_H)
				uiExpanded = false
				uiAnimating = false
				updateCloseBtn()
				if done then done() end
			end)
		end)
	end
	hideUI = function(done)
		if uiAnimating then return end
		local function finish()
			root.Visible = false
			setCollapsed()
			updateCloseBtn()
			if done then done() end
		end
		if uiExpanded then
			collapsePanel(finish)
		else
			finish()
		end
	end
	showUI = function()
		root.Visible = true
		setCollapsed()
		updateCloseBtn()
	end
	uiOpenPanel = function()
		showUI()
		if firstOpen then
			firstOpen = false
			task.defer(function()
				if expandPanel then task.spawn(expandPanel) end
			end)
		end
	end
	uiExpandPanel = function()
		if not root.Visible then showUI() end
		if expandPanel and not uiExpanded then task.spawn(expandPanel) end
	end
	uiClosePanel = function()
		hideUI()
	end
	local function handleToggleInput()
		if uiAnimating then return end
		if not root.Visible then
			showUI()
			task.spawn(expandPanel)
		elseif uiExpanded then
			hideUI()
		else
			task.spawn(expandPanel)
		end
	end
	closeBtn.MouseButton1Click:Connect(handleToggleInput)
	logoBtn.MouseButton1Click:Connect(function()
		if uiAnimating then return end
		if not root.Visible then
			showUI()
		elseif uiExpanded then
			task.spawn(collapsePanel)
		else
			task.spawn(expandPanel)
		end
	end)
	local function resolveToggleKey(key)
		if typeof(key) == "EnumItem" then return key end
		if type(key) == "string" and Enum.KeyCode[key] then return Enum.KeyCode[key] end
		return Enum.KeyCode.K
	end
	local toggleKey = resolveToggleKey(HubRegistry.toggleKeybind or "K")
	trackConnection(UIS.InputBegan:Connect(function(input, gp)
		if keybindCapture and keybindCapture(input) then return end
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
			handleToggleInput()
		end
	end))
	setCollapsed()
	root.Visible = true
	updateCloseBtn()
	uiScreenGui = sg
	uiBuilt = true
end
function ZyrixUI:Open()
	local ok, err = pcall(buildZyrixUI)
	if not ok then
		uiBuilt = false
		uiScreenGui = nil
		warn("[ZyrixUI] Failed to build:", err)
		if Zyrix and Zyrix.Notify then
			task.spawn(function() Zyrix:Notify("UI Error", tostring(err), 5, "error") end)
		end
		return false
	end
	if not uiScreenGui then return false end
	uiScreenGui.Enabled = true
	if uiOpenPanel then uiOpenPanel() end
	return true
end
function ZyrixUI:Expand()
	if uiExpandPanel then uiExpandPanel() end
end
function ZyrixUI:Close()
	if uiClosePanel then uiClosePanel() end
end
function ZyrixUI:Refresh()
	ZyrixUI._reset()
	return ZyrixUI:Open()
end
function ZyrixUI._reset()
	uiBuilt = false
	uiOpenPanel = nil
	uiClosePanel = nil
	uiExpandPanel = nil
	disconnectAllTracked()
	if uiScreenGui then
		pcall(function() uiScreenGui:Destroy() end)
		uiScreenGui = nil
	end
end
genv.ZyrixUI = ZyrixUI
fireOnSuccess = function()
	task.spawn(function()
		local ui = genv.ZyrixUI
		if ui and ui.Open then
			local opened = ui:Open()
			if opened and ui.Expand then
				task.wait(0.35)
				ui:Expand()
			end
		end
		pcall(function()
			if Zyrix.Callbacks.OnSuccess then
				Zyrix.Callbacks.OnSuccess()
			end
		end)
		task.spawn(function()
			if Zyrix and Zyrix.Notify then
				Zyrix:Notify("B4TMAN // Interface", "Interface loaded — press K to toggle", 3, "success")
			end
		end)
	end)
end
if not genv.ZyrixSkipDefaultHub then
	local prevForceReload = genv.ZyrixForceReload
	genv.ZyrixForceReload = true
	if Zyrix.Reset then pcall(function() Zyrix:Reset() end) end
	genv.ZyrixLoaded = false
	genv.SCRIPT_KEY = nil
	genv.ZyrixForceReload = prevForceReload or false
	local Demo = genv.ZyrixDemoState or {}
	genv.ZyrixDemoState = Demo
	Demo.Aimbot = Demo.Aimbot or false
	Demo.ESPRange = Demo.ESPRange or 750
	Demo.TargetPart = Demo.TargetPart or "Head"
	Demo.TargetKey = Demo.TargetKey or Enum.KeyCode.Q
	local Window = Zyrix:CreateWindow({
		Name = "B4TMAN // Interface",
		ToggleUIKeybind = "K",
		KeySystem = false,
	})
	local Combat = Window:CreateTab("Combat")
	local Visuals = Window:CreateTab("Visuals")
	local Movement = Window:CreateTab("Movement")
	local Misc = Window:CreateTab("Misc")
	Combat:CreateButton({
		Name = "Reset Aimbot System",
		Side = "Right",
		Callback = function()
			Demo.Aimbot = false
			Demo.ESPRange = 750
			Demo.TargetPart = "Head"
			Zyrix:Notify("Combat", "Aimbot reset", 2, "success")
		end,
	})
	Combat:CreateSlider({
		Name = "ESP Range",
		Range = {0, 1000},
		CurrentValue = Demo.ESPRange,
		Suffix = " studs",
		Side = "Right",
		Callback = function(v)
			Demo.ESPRange = math.floor(v)
		end,
	})
	Combat:CreateToggle({
		Name = "Aimbot",
		CurrentValue = Demo.Aimbot,
		Side = "Right",
		Callback = function(on)
			Demo.Aimbot = on
		end,
	})
	Combat:CreateKeybind({
		Name = "Target Keybind",
		CurrentKeybind = "Q",
		Callback = function(key)
			Demo.TargetKey = key
		end,
	})
	Combat:CreateDropdown({
		Name = "Dropdown",
		Options = {"Option #1", "Option #2", "Option #3", "Option #4"},
		CurrentOption = {"Option #1"},
		Callback = function(o)
			Demo.TargetPart = o[1]
		end,
	})
	Visuals:CreateSection("ESP")
	Visuals:CreateToggle({
		Name = "Player ESP",
		CurrentValue = false,
		Callback = function(on) Demo.ESP = on end,
	})
	Visuals:CreateSlider({
		Name = "ESP Range",
		Range = {0, 1000},
		CurrentValue = 750,
		Suffix = " studs",
		Callback = function(v) Demo.ESPRange = math.floor(v) end,
	})
	Visuals:CreateDropdown({
		Name = "ESP Style",
		Options = {"Box", "Corner", "Skeleton", "Highlight"},
		CurrentOption = {"Corner"},
		Callback = function(o) Demo.ESPStyle = o[1] end,
	})
	Movement:CreateSection("Character")
	Movement:CreateToggle({
		Name = "Speed Boost",
		CurrentValue = false,
		Callback = function(on)
			Demo.SpeedBoost = on
			local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = on and 50 or 16 end
		end,
	})
	Movement:CreateSlider({
		Name = "Walk Speed",
		Range = {16, 100},
		CurrentValue = 16,
		Callback = function(v)
			local hum = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then hum.WalkSpeed = math.floor(v) end
		end,
	})
	Movement:CreateToggle({
		Name = "Infinite Jump",
		CurrentValue = false,
		Side = "Right",
		Callback = function(on) Demo.InfiniteJump = on end,
	})
	Misc:CreateSection("Utility")
	Misc:CreateButton({
		Name = "Rejoin Server",
		Callback = function()
			Zyrix:Notify("Misc", "Action triggered", 2, "copy")
		end,
	})
	Misc:CreateDropdown({
		Name = "Theme Accent",
		Options = {"White", "Blue", "Purple", "Green"},
		CurrentOption = {"White"},
		Callback = function(o) Demo.Theme = o[1] end,
	})
	Zyrix.Callbacks.OnSuccess = function()
		print("[B4TMAN] Hub loaded! Press K to toggle.")
	end
	print("[B4TMAN] Launching hub...")
	Zyrix:Launch()
end
return Zyrix
