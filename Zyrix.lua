repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

local TS = cloneref(game:GetService("TweenService"))
local UIS = cloneref(game:GetService("UserInputService"))
local RS = cloneref(game:GetService("RunService"))
local LP = cloneref(game:GetService("Lighting"))
local PLR = cloneref(game:GetService("Players"))
local HS = cloneref(game:GetService("HttpService"))

local hui = gethui()

if getgenv().__ZyrixActive then
    warn("[Zyrix] Already loaded")
    return getgenv().__ZyrixLib
end
getgenv().__ZyrixActive = true

-- ====================== SHARED UTILITIES ======================
local function tw(obj, t, props)
    TS:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart), props):Play()
end

local function mkFrame(props)
    local f = Instance.new("Frame")
    f.BorderSizePixel = 0
    for k,v in pairs(props or {}) do f[k] = v end
    return f
end

local function mkLabel(props)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamMedium
    for k,v in pairs(props or {}) do l[k] = v end
    return l
end

local function mkButton(props)
    local b = Instance.new("TextButton")
    b.AutoButtonColor = false
    b.Text = ""
    b.BorderSizePixel = 0
    for k,v in pairs(props or {}) do b[k] = v end
    return b
end

local function applyCorner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = r or UDim.new(0, 6)
    return c
end

local function applyStroke(p, col, thick)
    local s = Instance.new("UIStroke", p)
    s.Color = col or Color3.fromRGB(41,41,41)
    s.Thickness = thick or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local C = {
    BG = Color3.fromRGB(19,19,19),
    BG2 = Color3.fromRGB(11,11,11),
    Accent = Color3.fromRGB(255,255,255),
    Text = Color3.fromRGB(255,255,255),
    TextDim = Color3.fromRGB(141,141,141),
    Stroke = Color3.fromRGB(41,41,41),
}

-- ====================== GUI LIBRARY (Updated) ======================
local ZyrixUI = {}

local _guiRoot, _win, _tabBar, _contentArea = nil

function ZyrixUI:Open()
    if _guiRoot then return end

    local sg = Instance.new("ScreenGui")
    sg.Name = "Zyrix"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 50
    sg.Parent = hui
    _guiRoot = sg

    _win = mkFrame({
        Name = "Tablist",
        Size = UDim2.new(0, 563, 0, 395),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.1,
        Parent = sg,
    })
    applyCorner(_win)
    applyStroke(_win)

    -- Title Bar
    local titleBar = mkFrame({Size = UDim2.new(1,0,0,41), BackgroundColor3 = Color3.fromRGB(11,11,11), Parent = _win})
    applyCorner(titleBar, UDim.new(0,8))

    mkLabel({
        Size = UDim2.new(0,480,0,23), Position = UDim2.new(0,32,0,6),
        Text = "zyrix", TextColor3 = C.Text, TextSize = 14,
        Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar,
    })

    local logo = Instance.new("ImageLabel", titleBar)
    logo.Size = UDim2.new(0,26,0,29)
    logo.Position = UDim2.new(0,5,0,6)
    logo.BackgroundTransparency = 1
    logo.Image = "rbxassetid://105436073524298"
    logo.ImageColor3 = Color3.fromRGB(141,141,141)

    -- Tab Bar
    _tabBar = Instance.new("ScrollingFrame", _win)
    _tabBar.Size = UDim2.new(1,0,0,41)
    _tabBar.Position = UDim2.new(0,0,0,41)
    _tabBar.BackgroundColor3 = Color3.fromRGB(11,11,11)
    _tabBar.ScrollBarThickness = 2
    _tabBar.ScrollingDirection = Enum.ScrollingDirection.X
    _tabBar.AutomaticCanvasSize = Enum.AutomaticSize.X
    _tabBar.BackgroundTransparency = 0.1
    applyCorner(_tabBar, UDim.new(0,100))

    local tabLayout = Instance.new("UIListLayout", _tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0,6)
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center

    -- Content Area
    _contentArea = Instance.new("ScrollingFrame", _win)
    _contentArea.Name = "elements"
    _contentArea.Size = UDim2.new(1,-16,1,-98)
    _contentArea.Position = UDim2.new(0,8,0,82)
    _contentArea.BackgroundTransparency = 1
    _contentArea.ScrollBarThickness = 2
    _contentArea.ScrollBarImageColor3 = Color3.fromRGB(141,141,141)
    _contentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local contentList = Instance.new("UIListLayout", _contentArea)
    contentList.Padding = UDim.new(0,8)
    contentList.SortOrder = Enum.SortOrder.LayoutOrder

    Instance.new("UIPadding", _contentArea).PaddingAll = UDim.new(0,8)
end

function ZyrixUI:AddTab(name, icon)
    if not _guiRoot then ZyrixUI:Open() end

    local tabBtn = mkButton({
        Size = UDim2.new(0, 90, 0, 35),
        BackgroundColor3 = C.BG,
        Text = (icon or "") .. " " .. name,
        TextColor3 = C.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        Parent = _tabBar,
    })
    applyCorner(tabBtn, UDim.new(0,100))
    applyStroke(tabBtn)

    local panel = mkFrame({
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = _contentArea,
    })

    local tab = { Content = panel }

    tabBtn.MouseButton1Click:Connect(function()
        for _, btn in pairs(_tabBar:GetChildren()) do
            if btn:IsA("TextButton") then
                btn.BackgroundColor3 = (btn == tabBtn) and Color3.fromRGB(30,30,30) or C.BG
                btn.TextColor3 = (btn == tabBtn) and C.Text or C.TextDim
            end
        end
        for _, p in pairs(_contentArea:GetChildren()) do
            if p:IsA("Frame") then p.Visible = (p == panel) end
        end
    end)

    -- Elements
    function tab:Button(title, callback)
        local el = mkFrame({
            Size = UDim2.new(1,0,0,40),
            BackgroundColor3 = C.BG,
            Parent = panel,
        })
        applyCorner(el)
        applyStroke(el)

        mkLabel({
            Size = UDim2.new(1,-40,1,0),
            Position = UDim2.new(0,12,0,0),
            Text = title,
            TextColor3 = C.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = el,
        })

        local hit = mkButton({Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = el})
        hit.MouseButton1Click:Connect(function()
            tw(el, 0.08, {BackgroundColor3 = Color3.fromRGB(40,40,40)})
            task.delay(0.1, function() tw(el, 0.1, {BackgroundColor3 = C.BG}) end)
            if callback then pcall(callback) end
        end)
    end

    function tab:Toggle(title, default, callback)
        local state = default or false
        local el = mkFrame({Size = UDim2.new(1,0,0,40), BackgroundColor3 = C.BG, Parent = panel})
        applyCorner(el) applyStroke(el)

        mkLabel({Size = UDim2.new(1,-70,1,0), Position = UDim2.new(0,12,0,0), Text = title, TextColor3 = C.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = el})

        local toggleFrame = mkFrame({Size = UDim2.new(0,43,0,21), Position = UDim2.new(1,-55,0.5,0), AnchorPoint = Vector2.new(1,0.5), BackgroundColor3 = state and Color3.fromRGB(0,170,0) or C.BG2, Parent = el})
        applyCorner(toggleFrame, UDim.new(1,0))
        applyStroke(toggleFrame)

        local knob = mkFrame({Size = UDim2.new(0,17,0,17), Position = UDim2.new(state and 1 or 0, state and -19 or 2, 0.5,0), AnchorPoint = Vector2.new(0,0.5), BackgroundColor3 = C.Text, Parent = toggleFrame})
        applyCorner(knob, UDim.new(1,0))

        local hit = mkButton({Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=el})
        hit.MouseButton1Click:Connect(function()
            state = not state
            tw(toggleFrame, 0.2, {BackgroundColor3 = state and Color3.fromRGB(0,170,0) or C.BG2})
            tw(knob, 0.2, {Position = UDim2.new(state and 1 or 0, state and -19 or 2, 0.5,0)})
            if callback then pcall(callback, state) end
        end)
    end

    -- Add more elements (Slider, Dropdown, etc.) as needed...

    -- Auto activate first tab
    if not _contentArea:FindFirstChildWhichIsA("Frame") then
        panel.Visible = true
        tabBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        tabBtn.TextColor3 = C.Text
    end

    return tab
end

function ZyrixUI:Close()
    if _guiRoot then _guiRoot:Destroy() _guiRoot = nil end
end

getgenv().ZyrixUI = ZyrixUI

-- ====================== KEY SYSTEM (UNCHANGED) ======================
-- [Paste your full original Zyrix key system code here]
-- For brevity, I'm keeping it as-is from your original file.

local Zyrix = {} -- ... (full key system from your original paste)

-- (All the key system code you provided earlier goes here: Appearance, Theme, buildKeyUI, Launch, etc.)

-- Keep everything from "local Zyrix = {}" to the end of your original file.

getgenv().__ZyrixLib = Zyrix
getgenv().ZyrixUI = ZyrixUI

return Zyrix

Example Usage
Lualocal Zyrix = loadstring(game:HttpGet("https://raw.githubusercontent.com/VYZ3N-scripts/Zyrix/refs/heads/main/Zyrix.lua"))()
local ZyrixUI = getgenv().ZyrixUI

Zyrix.Callbacks.OnVerify = function(key)
    return key == "mykey13"
end

Zyrix.Callbacks.OnSuccess = function()
    ZyrixUI:Open()

    local Combat = ZyrixUI:AddTab("Combat", "⚔️")
    Combat:Button("Reset Aimbot", function()
        print("Aimbot Reset")
    end)

    Combat:Toggle("Aimbot", true, function(v)
        print("Aimbot:", v)
    end)

    local Misc = ZyrixUI:AddTab("Misc", "⚙️")
    Misc:Button("Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end)
end

Zyrix:Launch()
