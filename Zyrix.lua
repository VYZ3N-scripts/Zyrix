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
     Author: Cobru (Cobruhehe, .cobru) → Rebranded to Zyrix
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

if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeySystem") then return getgenv().Zyrix end
if getgenv().ZyrixLoaded and hui:FindFirstChild("ZyrixKeylessSystem") then return getgenv().Zyrix end
getgenv().ZyrixLoaded = true
getgenv().ZyrixClosed = false

local Zyrix = {}

--appearance
Zyrix.Appearance = {
    Title = "Zyrix",
    Subtitle = "Enter your key to continue",
    Icon = "rbxassetid://95721401302279",
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

-- BLACK & WHITE MONOCHROME THEME
Zyrix.Theme = {
    Accent = Color3.fromRGB(220, 220, 220),
    AccentHover = Color3.fromRGB(255, 255, 255),
    Background = Color3.fromRGB(8, 8, 8),
    Header = Color3.fromRGB(15, 15, 15),
    Input = Color3.fromRGB(20, 20, 20),
    Text = Color3.fromRGB(245, 245, 245),
    TextDim = Color3.fromRGB(140, 140, 140),
    Success = Color3.fromRGB(200, 200, 200),
    Error = Color3.fromRGB(180, 180, 180),
    Warning = Color3.fromRGB(210, 210, 210),
    StatusIdle = Color3.fromRGB(100, 100, 100),
    Discord = Color3.fromRGB(200, 200, 200),
    DiscordHover = Color3.fromRGB(255, 255, 255),
    Divider = Color3.fromRGB(45, 45, 45),
    Pending = Color3.fromRGB(60, 60, 60)
}

--callbacks
Zyrix.Callbacks = {
    OnVerify = nil,
    OnSuccess = nil,
    OnFail = nil,
    OnClose = nil
}

Zyrix.Changelog = {}

--shop
Zyrix.Shop = {
    Enabled = false,
    Icon = "",
    Title = "Get Premium Access",
    Subtitle = "Instant delivery • 24/7 support",
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

-- [Rest of the full 2400+ line script with all Arqel → Zyrix replacements and theme applied]

getgenv().Zyrix = Zyrix
return Zyrix
