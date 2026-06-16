--[[
    Patriot Key System + Zyrix UI
    Theme: Black & White
    - Key system launches first
    - On success, opens Zyrix UI
]]

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(obj) return obj end
local gethui = gethui or function() return cloneref(game:GetService("CoreGui")) end

local TweenService     = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService      = cloneref(game:GetService("HttpService"))
local Workspace        = cloneref(game:GetService("Workspace"))
local RunService       = cloneref(game:GetService("RunService"))
local Lighting         = cloneref(game:GetService("Lighting"))
local Players          = cloneref(game:GetService("Players"))

local hui = gethui()

if getgenv().PatriotLoaded and hui:FindFirstChild("PatriotKeySystem") then return getgenv().Patriot end
getgenv().PatriotLoaded = true
getgenv().PatriotClosed = false

-- ═══════════════════════════════════════════════════
--  THEME  (black & white)
-- ═══════════════════════════════════════════════════
local T = {
    Accent        = Color3.fromRGB(220, 220, 220),
    AccentHover   = Color3.fromRGB(255, 255, 255),
    Background    = Color3.fromRGB(10,  10,  10),
    Header        = Color3.fromRGB(18,  18,  18),
    Input         = Color3.fromRGB(24,  24,  24),
    Text          = Color3.fromRGB(255, 255, 255),
    TextDim       = Color3.fromRGB(110, 110, 110),
    Success       = Color3.fromRGB(200, 200, 200),
    Error         = Color3.fromRGB(180, 180, 180),
    Warning       = Color3.fromRGB(160, 160, 160),
    StatusIdle    = Color3.fromRGB(90,  90,  90),
    Divider       = Color3.fromRGB(40,  40,  40),
    Stroke        = Color3.fromRGB(50,  50,  50),
    Active        = Color3.fromRGB(255, 255, 255),   -- toggle ON
    Inactive      = Color3.fromRGB(55,  55,  55),    -- toggle OFF
}

-- ═══════════════════════════════════════════════════
--  HELPERS
-- ═══════════════════════════════════════════════════
local function tw(obj, props, t, style)
    t = t or 0.2; style = style or Enum.EasingStyle.Quad
    TweenService:Create(obj, TweenInfo.new(t, style), props):Play()
end

local function corner(parent, rad)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, rad or 4)
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or T.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function enableBlur()
    local old = Lighting:FindFirstChild("PatKeyBlur")
    if old then old:Destroy() end
    local b = Instance.new("BlurEffect")
    b.Name = "PatKeyBlur"; b.Size = 0; b.Parent = Lighting
    tw(b, {Size = 20}, 0.4, Enum.EasingStyle.Quart)
    return b
end

local function disableBlur(b)
    if b and b.Parent then
        tw(b, {Size = 0}, 0.3, Enum.EasingStyle.Quart)
        task.delay(0.3, function() if b and b.Parent then b:Destroy() end end)
    end
end

local function fullCleanup(blurRef)
    getgenv().PatriotLoaded = false
    getgenv().PatriotClosed = true
    disableBlur(blurRef)
    local g = hui:FindFirstChild("PatriotKeySystem")
    if g then g:Destroy() end
end

-- simple key validation (replace with your real logic)
local function validateKey(key)
    return key == "FREE" or key == "MYKEY-2025"
end

-- ═══════════════════════════════════════════════════
--  ZYRIX UI  (opens after key success)
-- ═══════════════════════════════════════════════════
local function BuildZyrixUI()
    local old = hui:FindFirstChild("ZyrixUI")
    if old then old:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZyrixUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = hui

    -- ── state ──────────────────────────────────────
    local tabs = {}
    local activeTab = nil
    local elements = {}          -- elements[tabName] = list of element frames
    local toggleStates = {}
    local sliderValues = {}
    local dropdownStates = {}

    -- ── main window ────────────────────────────────
    local mainW, mainH = 563, 395
    local tabBarH = 41

    local root = Instance.new("Frame", screenGui)
    root.Name       = "Root"
    root.Size       = UDim2.new(0, mainW, 0, mainH + tabBarH)
    root.Position   = UDim2.new(0.5, -mainW/2, 0.5, -(mainH+tabBarH)/2)
    root.BackgroundColor3 = T.Background
    root.BorderSizePixel  = 0
    root.ClipsDescendants = true
    corner(root, 6)
    stroke(root, T.Stroke, 1)

    -- drag
    do
        local drag, ds, sp
        root.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; ds = i.Position; sp = root.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                root.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
    end

    -- ── title bar ──────────────────────────────────
    local titleBar = Instance.new("Frame", root)
    titleBar.Size             = UDim2.new(1, 0, 0, 36)
    titleBar.BackgroundColor3 = T.Header
    titleBar.BorderSizePixel  = 0

    local divLine = Instance.new("Frame", titleBar)
    divLine.Size             = UDim2.new(1, 0, 0, 1)
    divLine.Position         = UDim2.new(0, 0, 1, 0)
    divLine.BackgroundColor3 = T.Stroke
    divLine.BorderSizePixel  = 0

    local titleLbl = Instance.new("TextLabel", titleBar)
    titleLbl.Size                = UDim2.new(1, -80, 1, 0)
    titleLbl.Position            = UDim2.new(0, 14, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text                = "zyrix"
    titleLbl.TextColor3          = T.Text
    titleLbl.TextSize            = 15
    titleLbl.Font                = Enum.Font.GothamBold
    titleLbl.TextXAlignment      = Enum.TextXAlignment.Left

    -- close button
    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size             = UDim2.new(0, 28, 0, 28)
    closeBtn.Position         = UDim2.new(1, -34, 0.5, -14)
    closeBtn.BackgroundColor3 = T.Header
    closeBtn.BorderSizePixel  = 0
    closeBtn.Text             = "✕"
    closeBtn.TextColor3       = T.TextDim
    closeBtn.TextSize         = 13
    closeBtn.Font             = Enum.Font.GothamBold
    corner(closeBtn, 4)
    closeBtn.MouseEnter:Connect(function()
        tw(closeBtn, {TextColor3 = T.Text, BackgroundColor3 = T.Input})
    end)
    closeBtn.MouseLeave:Connect(function()
        tw(closeBtn, {TextColor3 = T.TextDim, BackgroundColor3 = T.Header})
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tw(root, {BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        screenGui:Destroy()
    end)

    -- minimise
    local minBtn = Instance.new("TextButton", titleBar)
    minBtn.Size             = UDim2.new(0, 28, 0, 28)
    minBtn.Position         = UDim2.new(1, -66, 0.5, -14)
    minBtn.BackgroundColor3 = T.Header
    minBtn.BorderSizePixel  = 0
    minBtn.Text             = "─"
    minBtn.TextColor3       = T.TextDim
    minBtn.TextSize         = 13
    minBtn.Font             = Enum.Font.GothamBold
    corner(minBtn, 4)
    local minimised = false
    minBtn.MouseEnter:Connect(function()  tw(minBtn, {TextColor3 = T.Text, BackgroundColor3 = T.Input}) end)
    minBtn.MouseLeave:Connect(function()  tw(minBtn, {TextColor3 = T.TextDim, BackgroundColor3 = T.Header}) end)
    minBtn.MouseButton1Click:Connect(function()
        minimised = not minimised
        if minimised then
            tw(root, {Size = UDim2.new(0, mainW, 0, 36)}, 0.25, Enum.EasingStyle.Quart)
        else
            tw(root, {Size = UDim2.new(0, mainW, 0, mainH + tabBarH)}, 0.25, Enum.EasingStyle.Quart)
        end
    end)

    -- ── tab bar ────────────────────────────────────
    local tabBar = Instance.new("Frame", root)
    tabBar.Size             = UDim2.new(1, 0, 0, tabBarH)
    tabBar.Position         = UDim2.new(0, 0, 0, 36)
    tabBar.BackgroundColor3 = T.Header
    tabBar.BorderSizePixel  = 0
    tabBar.ClipsDescendants = true

    local tabScroll = Instance.new("ScrollingFrame", tabBar)
    tabScroll.Size                = UDim2.new(1, 0, 1, 0)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel     = 0
    tabScroll.ScrollingDirection  = Enum.ScrollingDirection.X
    tabScroll.ScrollBarThickness  = 0
    tabScroll.CanvasSize          = UDim2.new(0, 0, 0, 0)
    tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.X

    local tabLayout = Instance.new("UIListLayout", tabScroll)
    tabLayout.FillDirection       = Enum.FillDirection.Horizontal
    tabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
    tabLayout.Padding             = UDim.new(0, 4)

    local tabPad = Instance.new("UIPadding", tabScroll)
    tabPad.PaddingLeft = UDim.new(0, 8)

    local tabDivider = Instance.new("Frame", tabBar)
    tabDivider.Size             = UDim2.new(1, 0, 0, 1)
    tabDivider.Position         = UDim2.new(0, 0, 1, -1)
    tabDivider.BackgroundColor3 = T.Stroke
    tabDivider.BorderSizePixel  = 0

    -- ── content area ───────────────────────────────
    local content = Instance.new("Frame", root)
    content.Size             = UDim2.new(1, 0, 1, -(36 + tabBarH))
    content.Position         = UDim2.new(0, 0, 0, 36 + tabBarH)
    content.BackgroundColor3 = T.Background
    content.BorderSizePixel  = 0
    content.ClipsDescendants = true

    -- ── element builder ────────────────────────────
    local function makeElementScroll(tabName)
        local sf = Instance.new("ScrollingFrame", content)
        sf.Name                  = "Scroll_" .. tabName
        sf.Size                  = UDim2.new(1, 0, 1, 0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel       = 0
        sf.ScrollBarThickness    = 2
        sf.ScrollBarImageColor3  = T.Stroke
        sf.CanvasSize            = UDim2.new(0, 0, 0, 0)
        sf.AutomaticCanvasSize   = Enum.AutomaticSize.Y
        sf.Visible               = false

        local layout = Instance.new("UIListLayout", sf)
        layout.Padding           = UDim.new(0, 6)
        layout.SortOrder         = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding", sf)
        pad.PaddingTop    = UDim.new(0, 8)
        pad.PaddingLeft   = UDim.new(0, 8)
        pad.PaddingRight  = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)

        return sf
    end

    local function rowBase(scroll, h)
        local f = Instance.new("Frame", scroll)
        f.Size             = UDim2.new(1, 0, 0, h or 36)
        f.BackgroundColor3 = T.Header
        f.BorderSizePixel  = 0
        corner(f, 4)
        stroke(f, T.Stroke, 0.8)
        return f
    end

    -- TOGGLE
    local function addToggle(scroll, labelText, default, callback)
        toggleStates[labelText] = default or false
        local row = rowBase(scroll, 36)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(1, -60, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelText
        lbl.TextColor3         = T.Text
        lbl.TextSize           = 12
        lbl.Font               = Enum.Font.GothamMedium
        lbl.TextXAlignment     = Enum.TextXAlignment.Left

        -- switch track
        local track = Instance.new("Frame", row)
        track.Size             = UDim2.new(0, 44, 0, 22)
        track.Position         = UDim2.new(1, -44, 0.5, -11)
        track.BackgroundColor3 = toggleStates[labelText] and T.Active or T.Inactive
        track.BorderSizePixel  = 0
        corner(track, 11)
        stroke(track, T.Stroke, 0.8)

        local knob = Instance.new("Frame", track)
        knob.Size             = UDim2.new(0, 16, 0, 16)
        knob.Position         = toggleStates[labelText] and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        knob.BackgroundColor3 = toggleStates[labelText] and T.Background or T.TextDim
        knob.BorderSizePixel  = 0
        corner(knob, 8)

        local btn = Instance.new("TextButton", row)
        btn.Size               = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text               = ""
        btn.ZIndex             = 5
        btn.MouseButton1Click:Connect(function()
            toggleStates[labelText] = not toggleStates[labelText]
            local on = toggleStates[labelText]
            tw(track, {BackgroundColor3 = on and T.Active or T.Inactive})
            tw(knob,  {Position = on and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)})
            tw(knob,  {BackgroundColor3 = on and T.Background or T.TextDim})
            if callback then callback(on) end
        end)
        return row
    end

    -- BUTTON
    local function addButton(scroll, labelText, callback)
        local row = rowBase(scroll, 36)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(1, -80, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelText
        lbl.TextColor3         = T.Text
        lbl.TextSize           = 12
        lbl.Font               = Enum.Font.GothamMedium
        lbl.TextXAlignment     = Enum.TextXAlignment.Left

        local typeLbl = Instance.new("TextLabel", row)
        typeLbl.Size               = UDim2.new(0, 50, 1, 0)
        typeLbl.Position           = UDim2.new(1, -55, 0, 0)
        typeLbl.BackgroundTransparency = 1
        typeLbl.Text               = "Button"
        typeLbl.TextColor3         = T.TextDim
        typeLbl.TextSize           = 10
        typeLbl.Font               = Enum.Font.GothamMedium
        typeLbl.TextXAlignment     = Enum.TextXAlignment.Right

        local btn = Instance.new("TextButton", row)
        btn.Size               = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text               = ""
        btn.ZIndex             = 5
        btn.MouseEnter:Connect(function()  tw(row, {BackgroundColor3 = T.Input}) end)
        btn.MouseLeave:Connect(function()  tw(row, {BackgroundColor3 = T.Header}) end)
        btn.MouseButton1Click:Connect(function()
            tw(row, {BackgroundColor3 = T.Stroke})
            task.delay(0.12, function() tw(row, {BackgroundColor3 = T.Input}) end)
            if callback then callback() end
        end)
        return row
    end

    -- SLIDER
    local function addSlider(scroll, labelText, min, max, default, suffix, callback)
        sliderValues[labelText] = default or min
        local row = rowBase(scroll, 44)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(0.45, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelText
        lbl.TextColor3         = T.Text
        lbl.TextSize           = 12
        lbl.Font               = Enum.Font.GothamMedium
        lbl.TextXAlignment     = Enum.TextXAlignment.Left

        local trackBg = Instance.new("Frame", row)
        trackBg.Size             = UDim2.new(0.52, 0, 0, 6)
        trackBg.Position         = UDim2.new(0.46, 0, 0.5, -3)
        trackBg.BackgroundColor3 = T.Inactive
        trackBg.BorderSizePixel  = 0
        corner(trackBg, 3)

        local fill = Instance.new("Frame", trackBg)
        fill.Size             = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = T.Text
        fill.BorderSizePixel  = 0
        corner(fill, 3)

        local valLbl = Instance.new("TextLabel", row)
        valLbl.Size               = UDim2.new(0, 0, 0, 14)
        valLbl.AutomaticSize      = Enum.AutomaticSize.X
        valLbl.Position           = UDim2.new(1, 0, 0.5, -7)
        valLbl.AnchorPoint        = Vector2.new(1, 0)
        valLbl.BackgroundTransparency = 1
        valLbl.Text               = tostring(default) .. (suffix or "")
        valLbl.TextColor3         = T.TextDim
        valLbl.TextSize           = 10
        valLbl.Font               = Enum.Font.GothamMedium

        local interact = Instance.new("TextButton", row)
        interact.Size               = UDim2.new(0.52, 0, 1, 0)
        interact.Position           = UDim2.new(0.46, 0, 0, 0)
        interact.BackgroundTransparency = 1
        interact.Text               = ""
        interact.ZIndex             = 5

        local dragging = false
        interact.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = trackBg.AbsolutePosition
                local sz  = trackBg.AbsoluteSize
                local t   = math.clamp((i.Position.X - abs.X) / sz.X, 0, 1)
                local val = math.floor(min + t*(max-min) + 0.5)
                sliderValues[labelText] = val
                fill.Size    = UDim2.new(t, 0, 1, 0)
                valLbl.Text  = tostring(val) .. (suffix or "")
                if callback then callback(val) end
            end
        end)
        return row
    end

    -- DROPDOWN
    local function addDropdown(scroll, labelText, options, default, callback)
        dropdownStates[labelText] = default or (options[1])
        local closed_h = 36
        local item_h   = 30
        local open_h   = closed_h + #options * item_h + 6

        local row = rowBase(scroll, closed_h)
        row.ClipsDescendants = true
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(0.5, 0, 0, closed_h)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelText
        lbl.TextColor3         = T.Text
        lbl.TextSize           = 12
        lbl.Font               = Enum.Font.GothamMedium
        lbl.TextXAlignment     = Enum.TextXAlignment.Left

        local selLbl = Instance.new("TextLabel", row)
        selLbl.Size               = UDim2.new(0.45, -24, 0, closed_h)
        selLbl.Position           = UDim2.new(0.5, 0, 0, 0)
        selLbl.BackgroundTransparency = 1
        selLbl.Text               = dropdownStates[labelText]
        selLbl.TextColor3         = T.TextDim
        selLbl.TextSize           = 11
        selLbl.Font               = Enum.Font.GothamMedium
        selLbl.TextXAlignment     = Enum.TextXAlignment.Right

        local arrow = Instance.new("TextLabel", row)
        arrow.Size               = UDim2.new(0, 20, 0, closed_h)
        arrow.Position           = UDim2.new(1, -20, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text               = "▾"
        arrow.TextColor3         = T.TextDim
        arrow.TextSize           = 12
        arrow.Font               = Enum.Font.GothamMedium

        -- option list
        local listFrame = Instance.new("Frame", row)
        listFrame.Size             = UDim2.new(1, 0, 0, #options * item_h + 6)
        listFrame.Position         = UDim2.new(0, 0, 0, closed_h + 2)
        listFrame.BackgroundColor3 = T.Input
        listFrame.BorderSizePixel  = 0
        corner(listFrame, 4)
        stroke(listFrame, T.Stroke, 0.8)

        local listPad = Instance.new("UIPadding", listFrame)
        listPad.PaddingTop = UDim.new(0, 3); listPad.PaddingBottom = UDim.new(0, 3)
        listPad.PaddingLeft = UDim.new(0, 3); listPad.PaddingRight = UDim.new(0, 3)

        local listLayout = Instance.new("UIListLayout", listFrame)
        listLayout.Padding = UDim.new(0, 2)

        for _, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton", listFrame)
            optBtn.Size             = UDim2.new(1, 0, 0, item_h - 4)
            optBtn.BackgroundColor3 = T.Input
            optBtn.BorderSizePixel  = 0
            optBtn.Text             = opt
            optBtn.TextColor3       = opt == dropdownStates[labelText] and T.Text or T.TextDim
            optBtn.TextSize         = 11
            optBtn.Font             = Enum.Font.GothamMedium
            corner(optBtn, 3)
            optBtn.MouseEnter:Connect(function()  tw(optBtn, {BackgroundColor3 = T.Header}) end)
            optBtn.MouseLeave:Connect(function()  tw(optBtn, {BackgroundColor3 = T.Input}) end)
            optBtn.MouseButton1Click:Connect(function()
                dropdownStates[labelText] = opt
                selLbl.Text = opt
                -- reset colours
                for _, ch in ipairs(listFrame:GetChildren()) do
                    if ch:IsA("TextButton") then
                        ch.TextColor3 = ch.Text == opt and T.Text or T.TextDim
                    end
                end
                tw(row, {Size = UDim2.new(1, 0, 0, closed_h)}, 0.2, Enum.EasingStyle.Quart)
                arrow.Text = "▾"
                if callback then callback(opt) end
            end)
        end

        local isOpen = false
        local headerBtn = Instance.new("TextButton", row)
        headerBtn.Size               = UDim2.new(1, 0, 0, closed_h)
        headerBtn.BackgroundTransparency = 1
        headerBtn.Text               = ""
        headerBtn.ZIndex             = 10
        headerBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                tw(row, {Size = UDim2.new(1, 0, 0, open_h)}, 0.2, Enum.EasingStyle.Quart)
                arrow.Text = "▴"
            else
                tw(row, {Size = UDim2.new(1, 0, 0, closed_h)}, 0.2, Enum.EasingStyle.Quart)
                arrow.Text = "▾"
            end
        end)
        return row
    end

    -- KEYBIND
    local function addKeybind(scroll, labelText, default, callback)
        local row = rowBase(scroll, 36)
        local pad = Instance.new("UIPadding", row)
        pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size               = UDim2.new(0.6, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text               = labelText
        lbl.TextColor3         = T.Text
        lbl.TextSize           = 12
        lbl.Font               = Enum.Font.GothamMedium
        lbl.TextXAlignment     = Enum.TextXAlignment.Left

        local kbox = Instance.new("Frame", row)
        kbox.Size             = UDim2.new(0, 34, 0, 22)
        kbox.Position         = UDim2.new(1, -34, 0.5, -11)
        kbox.BackgroundColor3 = T.Input
        kbox.BorderSizePixel  = 0
        corner(kbox, 4)
        stroke(kbox, T.Stroke, 0.8)

        local ktxt = Instance.new("TextLabel", kbox)
        ktxt.Size               = UDim2.new(1, 0, 1, 0)
        ktxt.BackgroundTransparency = 1
        ktxt.Text               = default or "None"
        ktxt.TextColor3         = T.Text
        ktxt.TextSize           = 11
        ktxt.Font               = Enum.Font.GothamMedium

        local listening = false
        local btn = Instance.new("TextButton", row)
        btn.Size               = UDim2.new(0, 34, 0, 22)
        btn.Position           = UDim2.new(1, -34, 0.5, -11)
        btn.BackgroundTransparency = 1
        btn.Text               = ""
        btn.ZIndex             = 5
        btn.MouseButton1Click:Connect(function()
            listening = true
            ktxt.Text = "..."
            tw(kbox, {BackgroundColor3 = T.Header})
        end)
        UserInputService.InputBegan:Connect(function(i, gp)
            if gp or not listening then return end
            if i.UserInputType == Enum.UserInputType.Keyboard then
                local name = tostring(i.KeyCode):gsub("Enum.KeyCode.", "")
                ktxt.Text = name
                listening = false
                tw(kbox, {BackgroundColor3 = T.Input})
                if callback then callback(i.KeyCode) end
            end
        end)
        return row
    end

    -- ── tab builder ────────────────────────────────
    local function addTab(name)
        local scroll = makeElementScroll(name)
        tabs[name] = scroll

        local tabBtn = Instance.new("TextButton", tabScroll)
        tabBtn.Size             = UDim2.new(0, 0, 0, 30)
        tabBtn.AutomaticSize    = Enum.AutomaticSize.X
        tabBtn.BackgroundColor3 = T.Header
        tabBtn.BorderSizePixel  = 0
        tabBtn.Text             = name
        tabBtn.TextColor3       = T.TextDim
        tabBtn.TextSize         = 12
        tabBtn.Font             = Enum.Font.GothamMedium
        corner(tabBtn, 100)
        stroke(tabBtn, T.Stroke, 0.8)

        local tabPadding = Instance.new("UIPadding", tabBtn)
        tabPadding.PaddingLeft  = UDim.new(0, 14)
        tabPadding.PaddingRight = UDim.new(0, 14)

        tabBtn.MouseButton1Click:Connect(function()
            if activeTab == name then return end
            -- deselect old
            if activeTab and tabs[activeTab] then
                tabs[activeTab].Visible = false
            end
            -- deactivate all tab buttons
            for _, ch in ipairs(tabScroll:GetChildren()) do
                if ch:IsA("TextButton") then
                    tw(ch, {BackgroundColor3 = T.Header, TextColor3 = T.TextDim})
                end
            end
            activeTab = name
            scroll.Visible = true
            tw(tabBtn, {BackgroundColor3 = T.Input, TextColor3 = T.Text})
        end)

        -- activate first tab automatically
        if not activeTab then
            activeTab = name
            scroll.Visible = true
            tw(tabBtn, {BackgroundColor3 = T.Input, TextColor3 = T.Text})
        end

        return {
            Toggle   = function(lbl, def, cb) return addToggle(scroll, lbl, def, cb) end,
            Button   = function(lbl, cb)       return addButton(scroll, lbl, cb) end,
            Slider   = function(lbl, mn, mx, def, sfx, cb) return addSlider(scroll, lbl, mn, mx, def, sfx, cb) end,
            Dropdown = function(lbl, opts, def, cb) return addDropdown(scroll, lbl, opts, def, cb) end,
            Keybind  = function(lbl, def, cb)  return addKeybind(scroll, lbl, def, cb) end,
        }
    end

    -- ── entrance animation ─────────────────────────
    root.Position = UDim2.new(0.5, -mainW/2, 1.5, 0)
    tw(root, {Position = UDim2.new(0.5, -mainW/2, 0.5, -(mainH+tabBarH)/2)}, 0.45, Enum.EasingStyle.Quart)

    return {
        AddTab = addTab,
        Close  = function() screenGui:Destroy() end,
    }
end

-- ═══════════════════════════════════════════════════
--  KEY SYSTEM UI
-- ═══════════════════════════════════════════════════
local function BuildKeyUI(onSuccess)
    local old = hui:FindFirstChild("PatriotKeySystem")
    if old then old:Destroy() end

    local blurRef = enableBlur()

    local W, H = 380, 320

    local gui = Instance.new("ScreenGui")
    gui.Name             = "PatriotKeySystem"
    gui.ResetOnSpawn     = false
    gui.IgnoreGuiInset   = true
    gui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
    gui.Parent           = hui

    -- container (for slide animation)
    local container = Instance.new("Frame", gui)
    container.Size             = UDim2.new(0, W, 0, H)
    container.Position         = UDim2.new(0.5, -W/2, 1.5, 0)
    container.BackgroundTransparency = 1

    -- main window
    local main = Instance.new("Frame", container)
    main.Size             = UDim2.new(1, 0, 1, 0)
    main.BackgroundColor3 = T.Background
    main.BorderSizePixel  = 0
    corner(main, 6)
    stroke(main, T.Stroke, 1.2)

    -- drag
    do
        local drag, ds, sp
        main.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                drag = true; ds = i.Position; sp = container.Position
                i.Changed:Connect(function()
                    if i.UserInputState == Enum.UserInputState.End then drag = false end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                local d = i.Position - ds
                container.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
            end
        end)
    end

    -- header
    local header = Instance.new("Frame", main)
    header.Size             = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = T.Header
    header.BorderSizePixel  = 0
    corner(header, 6)

    local hFix = Instance.new("Frame", header)
    hFix.Size             = UDim2.new(1, 0, 0, 8)
    hFix.Position         = UDim2.new(0, 0, 1, -8)
    hFix.BackgroundColor3 = T.Header
    hFix.BorderSizePixel  = 0

    local hLine = Instance.new("Frame", header)
    hLine.Size             = UDim2.new(1, 0, 0, 1)
    hLine.Position         = UDim2.new(0, 0, 1, 0)
    hLine.BackgroundColor3 = T.Stroke
    hLine.BorderSizePixel  = 0

    local titleLbl = Instance.new("TextLabel", header)
    titleLbl.Size               = UDim2.new(1, -80, 1, 0)
    titleLbl.Position           = UDim2.new(0, 16, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text               = "Key System"
    titleLbl.TextColor3         = T.Text
    titleLbl.TextSize           = 20
    titleLbl.Font               = Enum.Font.GothamBold
    titleLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local subLbl = Instance.new("TextLabel", header)
    subLbl.Size               = UDim2.new(1, -80, 0, 16)
    subLbl.Position           = UDim2.new(0, 16, 1, -20)
    subLbl.BackgroundTransparency = 1
    subLbl.Text               = "Enter your key to continue"
    subLbl.TextColor3         = T.TextDim
    subLbl.TextSize           = 11
    subLbl.Font               = Enum.Font.GothamMedium
    subLbl.TextXAlignment     = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size             = UDim2.new(0, 24, 0, 24)
    closeBtn.Position         = UDim2.new(1, -14, 0.5, -12)
    closeBtn.AnchorPoint      = Vector2.new(1, 0)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Text             = "✕"
    closeBtn.TextColor3       = T.TextDim
    closeBtn.TextSize         = 14
    closeBtn.Font             = Enum.Font.GothamBold
    closeBtn.MouseEnter:Connect(function()  tw(closeBtn, {TextColor3 = T.Text}) end)
    closeBtn.MouseLeave:Connect(function()  tw(closeBtn, {TextColor3 = T.TextDim}) end)
    closeBtn.MouseButton1Click:Connect(function()
        fullCleanup(blurRef)
        tw(container, {Position = UDim2.new(0.5, -W/2, -0.6, 0)}, 0.4, Enum.EasingStyle.Quart)
        task.wait(0.4); gui:Destroy()
    end)

    -- status box
    local statusY = 64
    local statusBox = Instance.new("Frame", main)
    statusBox.Size             = UDim2.new(0.92, 0, 0, 52)
    statusBox.Position         = UDim2.new(0.04, 0, 0, statusY)
    statusBox.BackgroundColor3 = T.Input
    statusBox.BorderSizePixel  = 0
    corner(statusBox, 4)
    stroke(statusBox, T.Stroke, 1)

    local statusIcon = Instance.new("TextLabel", statusBox)
    statusIcon.Size               = UDim2.new(0, 36, 1, 0)
    statusIcon.Position           = UDim2.new(0, 8, 0, 0)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Text               = "🔒"
    statusIcon.TextSize           = 18
    statusIcon.Font               = Enum.Font.GothamBold

    local statusLbl = Instance.new("TextLabel", statusBox)
    statusLbl.Size               = UDim2.new(1, -54, 1, 0)
    statusLbl.Position           = UDim2.new(0, 50, 0, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.Text               = "Awaiting key..."
    statusLbl.TextColor3         = T.TextDim
    statusLbl.TextSize           = 14
    statusLbl.Font               = Enum.Font.GothamMedium
    statusLbl.TextXAlignment     = Enum.TextXAlignment.Left

    -- input
    local inputY = statusY + 62
    local inputBox = Instance.new("Frame", main)
    inputBox.Size             = UDim2.new(0.92, 0, 0, 44)
    inputBox.Position         = UDim2.new(0.04, 0, 0, inputY)
    inputBox.BackgroundColor3 = T.Input
    inputBox.BorderSizePixel  = 0
    corner(inputBox, 4)
    local inputStroke = stroke(inputBox, T.Stroke, 1)

    local textBox = Instance.new("TextBox", inputBox)
    textBox.Size               = UDim2.new(1, -20, 1, 0)
    textBox.Position           = UDim2.new(0, 12, 0, 0)
    textBox.BackgroundTransparency = 1
    textBox.Text               = ""
    textBox.PlaceholderText    = "Enter your key..."
    textBox.PlaceholderColor3  = T.TextDim
    textBox.TextColor3         = T.Text
    textBox.TextSize           = 14
    textBox.Font               = Enum.Font.GothamMedium
    textBox.ClearTextOnFocus   = false
    textBox.TextXAlignment     = Enum.TextXAlignment.Left
    textBox.Focused:Connect(function()   tw(inputStroke, {Color = T.Text, Transparency = 0.5}) end)
    textBox.FocusLost:Connect(function() tw(inputStroke, {Color = T.Stroke, Transparency = 0}) end)

    -- divider
    local divY = inputY + 54
    local divider = Instance.new("Frame", main)
    divider.Size             = UDim2.new(1, 0, 0, 1)
    divider.Position         = UDim2.new(0, 0, 0, divY)
    divider.BackgroundColor3 = T.Stroke
    divider.BorderSizePixel  = 0

    -- buttons
    local btnY = divY + 14

    local function makeBtn(label, yOff, primary)
        local btn = Instance.new("TextButton", main)
        btn.Size             = UDim2.new(0.88, 0, 0, 40)
        btn.Position         = UDim2.new(0.06, 0, 0, yOff)
        btn.BackgroundColor3 = primary and T.Text or T.Input
        btn.BorderSizePixel  = 0
        btn.Text             = label
        btn.TextColor3       = primary and T.Background or T.Text
        btn.TextSize         = 13
        btn.Font             = Enum.Font.GothamBold
        btn.AutoButtonColor  = false
        corner(btn, 4)
        stroke(btn, T.Stroke, primary and 0.6 or 0.8)
        btn.MouseEnter:Connect(function()
            tw(btn, {BackgroundColor3 = primary and Color3.fromRGB(220,220,220) or T.Header})
        end)
        btn.MouseLeave:Connect(function()
            tw(btn, {BackgroundColor3 = primary and T.Text or T.Input})
        end)
        return btn
    end

    local verifyBtn = makeBtn("Verify Key", btnY, true)
    local getKeyBtn = makeBtn("Get Key", btnY + 48, false)

    -- status update helper
    local spinConn
    local function setStatus(state, msg)
        if spinConn then spinConn:Disconnect(); spinConn = nil end
        if state == "idle" then
            statusIcon.Text  = "🔒"; statusLbl.Text = msg or "Awaiting key..."
            statusLbl.TextColor3 = T.TextDim
        elseif state == "checking" then
            statusIcon.Text  = "⟳"; statusLbl.TextColor3 = T.Text
            local dots, i = {".", "..", "...", ""}, 1
            spinConn = RunService.Heartbeat:Connect(function()
                statusIcon.Rotation = (statusIcon.Rotation + 3) % 360
            end)
            task.spawn(function()
                while state == "checking" do
                    statusLbl.Text = "Verifying" .. dots[i]; i = (i%4)+1; task.wait(0.35)
                end
            end)
        elseif state == "success" then
            statusIcon.Text  = "✓"; statusLbl.Text = msg or "Access granted!"
            statusLbl.TextColor3 = T.Text; statusIcon.Rotation = 0
        elseif state == "error" then
            statusIcon.Text  = "✕"; statusLbl.Text = msg or "Invalid key"
            statusLbl.TextColor3 = Color3.fromRGB(160,160,160); statusIcon.Rotation = 0
        end
    end

    -- verify logic
    local function doVerify()
        local key = textBox.Text:gsub("%s+", "")
        if key == "" then setStatus("error", "Please enter a key"); return end
        setStatus("checking")
        verifyBtn.Active = false
        task.wait(0.6) -- simulate network check

        local ok = validateKey(key)
        verifyBtn.Active = true

        if ok then
            setStatus("success", "Access granted!")
            getgenv().SCRIPT_KEY = key
            task.wait(0.8)
            -- close key UI
            fullCleanup(blurRef)
            tw(container, {Position = UDim2.new(0.5, -W/2, -0.6, 0)}, 0.4, Enum.EasingStyle.Quart)
            task.delay(0.4, function()
                gui:Destroy()
                onSuccess()
            end)
        else
            setStatus("error", "Key not recognised")
        end
    end

    verifyBtn.MouseButton1Click:Connect(doVerify)
    textBox.FocusLost:Connect(function(enter) if enter then doVerify() end end)
    getKeyBtn.MouseButton1Click:Connect(function()
        -- replace with your actual key link
        pcall(function() setclipboard("https://example.com/getkey") end)
        setStatus("idle", "Key link copied!")
        task.delay(2, function() setStatus("idle") end)
    end)

    -- entrance
    tw(container, {Position = UDim2.new(0.5, -W/2, 0.5, -H/2)}, 0.45, Enum.EasingStyle.Quart)
end

-- ═══════════════════════════════════════════════════
--  ENTRY POINT
-- ═══════════════════════════════════════════════════
local function Launch()
    -- If key already validated this session, skip straight to UI
    if getgenv().SCRIPT_KEY and getgenv().SCRIPT_KEY ~= "" then
        local zyrix = BuildZyrixUI()
        -- ── populate your tabs & elements here ──────
        local combat = zyrix.AddTab("Combat")
        combat.Toggle("Aimbot", false, function(v) print("Aimbot:", v) end)
        combat.Slider("FOV", 1, 360, 90, "°", function(v) print("FOV:", v) end)
        combat.Keybind("Target Key", "Q", function(k) print("Keybind:", k) end)
        combat.Button("Reset Aimbot", function() print("Reset!") end)

        local visuals = zyrix.AddTab("Visuals")
        visuals.Toggle("ESP", false, function(v) print("ESP:", v) end)
        visuals.Slider("ESP Range", 0, 2000, 750, " studs", function(v) print("ESP Range:", v) end)
        visuals.Dropdown("Box Type", {"2D Box", "3D Box", "Corner Box"}, "2D Box", function(v) print("Box:", v) end)

        local misc = zyrix.AddTab("Misc")
        misc.Toggle("Infinite Jump", false, function(v) print("InfJump:", v) end)
        misc.Toggle("No Clip", false, function(v) print("NoClip:", v) end)
        misc.Button("Rejoin Server", function() print("Rejoin") end)
        return
    end

    BuildKeyUI(function()
        -- ── after key success, open Zyrix ────────────
        local zyrix = BuildZyrixUI()

        local combat = zyrix.AddTab("Combat")
        combat.Toggle("Aimbot", false, function(v) print("Aimbot:", v) end)
        combat.Slider("FOV", 1, 360, 90, "°", function(v) print("FOV:", v) end)
        combat.Keybind("Target Key", "Q", function(k) print("Keybind:", k) end)
        combat.Button("Reset Aimbot", function() print("Reset!") end)
        combat.Dropdown("Aimpart", {"Head", "Torso", "Nearest"}, "Head", function(v) print("Aimpart:", v) end)

        local visuals = zyrix.AddTab("Visuals")
        visuals.Toggle("ESP", false, function(v) print("ESP:", v) end)
        visuals.Slider("ESP Range", 0, 2000, 750, " studs", function(v) print("ESP Range:", v) end)
        visuals.Dropdown("Box Type", {"2D Box", "3D Box", "Corner Box"}, "2D Box", function(v) print("Box:", v) end)
        visuals.Toggle("Tracers", false, function(v) print("Tracers:", v) end)
        visuals.Toggle("Name Tags", true, function(v) print("Names:", v) end)

        local misc = zyrix.AddTab("Misc")
        misc.Toggle("Infinite Jump", false, function(v) print("InfJump:", v) end)
        misc.Toggle("No Clip", false, function(v) print("NoClip:", v) end)
        misc.Button("Rejoin Server", function() print("Rejoin") end)
        misc.Keybind("Open/Close GUI", "RightShift", function(k) print("GUI key:", k) end)
    end)
end

Launch()
