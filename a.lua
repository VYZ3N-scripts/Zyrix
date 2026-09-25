local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local MenuToys = ReplicatedStorage:WaitForChild("MenuToys")
local SpawnToyRF = MenuToys:WaitForChild("SpawnToyRemoteFunction")
local SetNetworkOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
local StickyPartEvent = ReplicatedStorage:WaitForChild("PlayerEvents"):WaitForChild("StickyPartEvent")

local HUGE_CF = CFrame.new(1099511627776, 1099511627776, 1099511627776, 1, 0, 0, 0, 1, 0, 0, 0, 1)

local activeSparklers = {}
local sparklerConfig = {
	Height = 5,
	Speed = 2,
	Radius = 15,
	CurrentShape = "Planet",
}
local sparklersRunning = false
local SelectedPlot = "1"

local function zeroLimits()
	pcall(function()
		local used = LocalPlayer:FindFirstChild("UsedToyPoints")
		local cap = LocalPlayer:FindFirstChild("ToysLimitCap")
		if used then used.Value = 0 end
		if cap then cap.Value = 999999 end
		local can = LocalPlayer:FindFirstChild("CanSpawnToy")
		if can then can.Value = true end
	end)
end

local function getHRP()
	local c = LocalPlayer.Character
	if c and c:FindFirstChild("HumanoidRootPart") then
		return c.HumanoidRootPart
	end
	c = LocalPlayer.CharacterAdded:Wait()
	return c:WaitForChild("HumanoidRootPart")
end

local function getToyFolder()
	return Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
end

local function spawnToy(name, cf)
	zeroLimits()
	return pcall(function()
		SpawnToyRF:InvokeServer(name, cf, Vector3.zero)
	end)
end

local function networkOwn(part, tries)
	if not part then return false end
	tries = tries or 12
	for _ = 1, tries do
		pcall(function() SetNetworkOwner:FireServer(part, part.CFrame) end)
		local po = part:FindFirstChild("PartOwner")
		if po and po.Value == LocalPlayer.Name then return true end
		task.wait(0.02)
	end
	return false
end

function SetupPhysics(obj, list)
    for _, v in ipairs(list) do
        if v == obj then
            return
        end
    end

    mainPart = obj:IsA("BasePart") and obj or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
    if not mainPart then
        return
    end

    pcall(function()
        if mainPart:CanSetNetworkOwnership() then
            mainPart:SetNetworkOwner(LocalPlayer)
        end
    end)

    mainPart.Anchored = false

    bp = mainPart:FindFirstChild("ToyBodyPos") or Instance.new("BodyPosition", mainPart)
    bp.Name = "ToyBodyPos"
    bp.MaxForce = Vector3.new(1e8, 1e8, 1e8)
    bp.P = 100000
    bp.D = 800

    bg = mainPart:FindFirstChild("ToyBodyGyro") or Instance.new("BodyGyro", mainPart)
    bg.Name = "ToyBodyGyro"
    bg.MaxTorque = Vector3.new(1e8, 1e8, 1e8)
    bg.P = 50000

    for _, p in ipairs(obj:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    table.insert(list, obj)
end

TAU = math.pi * 2
sqrt = math.sqrt
sin = math.sin
cos = math.cos
abs = math.abs
pow = function(b, e)
    return b >= 0 and b ^ e or -((-b) ^ e)
end
clamp = math.clamp

function baseAngle(i, n, t, speed)
    return (i / n) * TAU + t * speed
end

Shapes = {}
Shapes.Planet = function(i, n, t, r, h, sp)
    coreN = clamp(math.floor(n * 0.35), 8, 15)
    coreN = math.min(coreN, n)
    ring1N = math.max(math.floor((n - coreN) / 2), 1)
    spin = t * sp

    if i <= coreN then
        phi = math.acos(1 - 2 * (i / coreN))
        theta = i * math.pi * (3 - sqrt(5)) + spin
        cr = r * 0.35
        return Vector3.new(cos(theta) * sin(phi) * cr, cos(phi) * cr + h, sin(theta) * sin(phi) * cr)
    elseif i <= coreN + ring1N then
        idx = i - coreN
        a = (idx / ring1N) * TAU + spin
        rr = r * 0.9
        tilt = math.rad(30)
        return Vector3.new(cos(a) * rr, sin(a) * rr * sin(tilt) + h, sin(a) * rr * cos(tilt))
    else
        idx = i - (coreN + ring1N)
        c = math.max(n - (coreN + ring1N), 1)
        a = (idx / c) * TAU + t * sp * 0.5
        rr = r * 1.3
        tilt = math.rad(-40)
        return Vector3.new(cos(a) * rr, sin(a) * rr * sin(tilt) + h, sin(a) * rr * cos(tilt))
    end
end

Shapes.Sphere = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5)) + t * sp * 2
    return Vector3.new(cos(theta) * sin(phi) * r, cos(phi) * r + h, sin(theta) * sin(phi) * r)
end

Shapes.Cylinder = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    y = (i / n) * r * 1.5 - r * 0.75
    return Vector3.new(cos(a) * r, h + y, sin(a) * r)
end

Shapes["Double Ring"] = function(i, n, t, r, h, sp)
    a = (i / (n / 2)) * TAU + t * sp
    if i % 2 == 0 then
        return Vector3.new(cos(a) * r, h, sin(a) * r)
    else
        return Vector3.new(0, h + cos(a) * r, sin(a) * r)
    end
end

Shapes.Star = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    rr = (i % 2 == 0) and r or r * 0.38
    return Vector3.new(cos(a) * rr, h + sin(t * sp * 1.5 + i * 0.3) * 1.5, sin(a) * rr)
end

Shapes.Infinity = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    d = 1 + sin(a) ^ 2
    return Vector3.new((r * cos(a)) / d, h + sin(t * sp + i * 0.2) * 1.2, (r * sin(a) * cos(a)) / d)
end

Shapes.Heart = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    pulse = 1 + 0.12 * sin(t * sp * 2)
    scale = (r / 15) * pulse
    x = 16 * sin(a) ^ 3
    z = -(13 * cos(a) - 5 * cos(2 * a) - 2 * cos(3 * a) - cos(4 * a))
    return Vector3.new(x * scale, h + sin(t * sp * 2) * 0.5, z * scale)
end

Shapes["DNA Helix"] = function(i, n, t, r, h, sp)
    y = (i / n) * r * 2 - r
    a = baseAngle(i, n, t, sp) + y * 0.5
    side = (i % 2 == 0) and 1 or -1
    return Vector3.new(cos(a) * r * side, h + y, sin(a) * r * side)
end

Shapes["Triple Helix"] = function(i, n, t, r, h, sp)
    y = (i / n) * r * 2 - r
    a = baseAngle(i, n, t, sp) + y * 0.5
    phase = (i % 3) * (TAU / 3)
    return Vector3.new(cos(a + phase) * r, h + y, sin(a + phase) * r)
end

Shapes.Tornado = function(i, n, t, r, h, sp)
    y = (i / n) * r * 2 - r
    rr = ((y + r) / (r * 2)) * r + 2
    a = baseAngle(i, n, t, sp) + y * 0.5
    return Vector3.new(cos(a) * rr, h + y, sin(a) * rr)
end

Shapes["Galaxy Spiral"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * 12 + t * sp
    return Vector3.new(cos(a) * r * (frac ^ 1.5), h + sin(t * sp * 2 + frac * 10), sin(a) * r * (frac ^ 1.5))
end

Shapes["Fibonacci Spiral"] = function(i, n, t, r, h, sp)
    frac = i / n
    angle = frac * TAU * 6.18 + t * sp
    dist = frac * r
    wave = sin(t * sp + frac * TAU) * 2
    return Vector3.new(cos(angle) * dist, h + wave, sin(angle) * dist)
end

Shapes["Spring Coil"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU * 5 + t * sp
    y = frac * r * 2 - r
    return Vector3.new(cos(a) * r * 0.5, h + y, sin(a) * r * 0.5)
end

Shapes["Vortex Funnel"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU * 4 + t * sp
    rr = frac * r
    y = (1 - frac) * r * 1.5
    return Vector3.new(cos(a) * rr, h + y, sin(a) * rr)
end

Shapes.Seashell = function(i, n, t, r, h, sp)
    frac = i / n
    u = frac * TAU * 3 + t * sp
    v = frac * TAU
    growth = math.exp(0.15 * u)
    x = growth * cos(u) * (1 + cos(v)) * r * 0.15
    y = growth * sin(u) * (1 + cos(v)) * r * 0.15
    z = growth * sin(v) * r * 0.15
    return Vector3.new(x, h + y, z)
end

Shapes.Box = function(i, n, t, r, h, sp)
    face = i % 6
    a = baseAngle(i, n, t, sp)
    wb = sin(t * sp + i) * 0.3
    s = r
    edges = {
        Vector3.new(s, sin(a) * s, cos(a) * s),
        Vector3.new(-s, sin(a) * s, cos(a) * s),
        Vector3.new(sin(a) * s, s, cos(a) * s),
        Vector3.new(sin(a) * s, -s, cos(a) * s),
        Vector3.new(sin(a) * s, cos(a) * s, s),
        Vector3.new(sin(a) * s, cos(a) * s, -s),
    }
    v = edges[face + 1]
    return Vector3.new(v.X, v.Y + h + wb, v.Z)
end

Shapes["Rounded Cube"] = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    x = pow(cos(a) * r, 0.85)
    y = pow(sin(a * 1.3) * r * 0.6, 0.85)
    z = pow(cos(a * 0.7) * r, 0.85)
    return Vector3.new(x, y + h, z)
end

Shapes.Torus = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    b = baseAngle(i, n, t * 3, sp)
    R = r
    rt = r * 0.35
    return Vector3.new((R + rt * cos(b)) * cos(a), rt * sin(b) + h, (R + rt * cos(b)) * sin(a))
end

Shapes["Torus Knot"] = function(i, n, t, r, h, sp)
    p, q = 2, 3
    a = baseAngle(i, n, t, sp)
    phi = a * q
    R = r * (1 + 0.35 * cos(p * a))
    return Vector3.new(R * cos(phi), r * 0.35 * sin(p * a) + h, R * sin(phi))
end

Shapes["Möbius Strip"] = function(i, n, t, r, h, sp)
    frac = i / n
    u = frac * TAU + t * sp
    v = (i % 2 == 0) and 0.5 or -0.5
    w = r * 0.35
    return Vector3.new((r + w * v * cos(u / 2)) * cos(u), w * v * sin(u / 2) + h, (r + w * v * cos(u / 2)) * sin(u))
end

Shapes.Saturn = function(i, n, t, r, h, sp)
    spin = t * sp
    if i <= n * 0.6 then
        phi = math.acos(1 - 2 * (i / (n * 0.6)))
        theta = i * math.pi * (3 - sqrt(5)) + spin
        pr = r * 0.45
        return Vector3.new(cos(theta) * sin(phi) * pr, cos(phi) * pr + h, sin(theta) * sin(phi) * pr)
    else
        idx = i - n * 0.6
        c = n - n * 0.6
        a = (idx / c) * TAU + spin
        rr = r * 1.2
        return Vector3.new(cos(a) * rr, sin(a) * rr * sin(math.rad(25)) + h, sin(a) * rr * cos(math.rad(25)))
    end
end

Shapes["Ice Cube"] = function(i, n, t, r, h, sp)
    face = i % 6
    frac = (i % math.max(math.floor(n / 6), 1)) / math.max(math.floor(n / 6), 1)
    a = frac * TAU
    s = r * 0.8
    crack = sin(t * sp * 2 + i * 0.5) * 0.4
    pts = {
        Vector3.new(s + crack, cos(a) * s, sin(a) * s),
        Vector3.new(-s - crack, cos(a) * s, sin(a) * s),
        Vector3.new(cos(a) * s, s + crack, sin(a) * s),
        Vector3.new(cos(a) * s, -s - crack, sin(a) * s),
        Vector3.new(cos(a) * s, sin(a) * s, s + crack),
        Vector3.new(cos(a) * s, sin(a) * s, -s - crack),
    }
    v = pts[face + 1]
    return Vector3.new(v.X, v.Y + h, v.Z)
end

Shapes["Black Hole"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU * 3 + t * sp
    dist = r * (1 - frac * 0.7)
    suck = sin(t * sp * 2) * 0.5
    return Vector3.new(cos(a) * dist, h + suck * frac * 3, sin(a) * dist)
end

Shapes["Hyper Sphere"] = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5)) + t * sp
    pulse = r + sin(t * sp + i * 0.3) * r * 0.25
    return Vector3.new(cos(theta) * sin(phi) * pulse, cos(phi) * pulse + h, sin(theta) * sin(phi) * pulse)
end

Shapes["Orbital Rings"] = function(i, n, t, r, h, sp)
    ring = i % 3
    a = baseAngle(i, n, t, sp)
    tilts = { math.rad(0), math.rad(60), math.rad(-60) }
    tilt = tilts[ring + 1]
    return Vector3.new(cos(a) * r, sin(a) * r * sin(tilt) + h, sin(a) * r * cos(tilt))
end

Shapes["Lightning Tornado"] = function(i, n, t, r, h, sp)
    y = (i / n) * r * 2 - r
    rr = ((y + r) / (r * 2)) * r + 2
    bolt = sin(i * 7.3 + t * sp * 5) * 3
    a = baseAngle(i, n, t, sp) + y * 0.5
    return Vector3.new(cos(a) * rr + bolt, h + y, sin(a) * rr + bolt)
end

Shapes["Plasma Cage"] = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5))
    arc = sin(t * sp * 2 + phi * 6) * r * 0.2
    rr = r + arc
    return Vector3.new(cos(theta) * sin(phi) * rr, cos(phi) * rr + h, sin(theta) * sin(phi) * rr)
end

Shapes.Wormhole = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU + t * sp
    y = (frac - 0.5) * r * 3
    neck = r * (1 - math.exp(-((y / (r * 0.8)) ^ 2))) + 0.5
    return Vector3.new(cos(a) * neck, h + y, sin(a) * neck)
end

Shapes["Quantum Lattice"] = function(i, n, t, r, h, sp)
    grid = math.ceil(n ^ (0.3333333333333333))
    gx = i % grid
    gy = math.floor(i / grid) % grid
    gz = math.floor(i / (grid * grid)) % grid
    scale = r * 2 / grid
    jitter = sin(t * sp + i * 1.7) * 0.3
    return Vector3.new((gx - grid / 2) * scale + jitter, (gy - grid / 2) * scale + h, (gz - grid / 2) * scale + jitter)
end

Shapes["Neutron Burst"] = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5))
    burst = r * abs(sin(t * sp + i * 0.4))
    return Vector3.new(cos(theta) * sin(phi) * burst, cos(phi) * burst + h, sin(theta) * sin(phi) * burst)
end

Shapes["Arc Discharge"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU
    arc = sin(frac * math.pi) * r
    zap = sin(t * sp * 8 + i * 2.1) * r * 0.15
    return Vector3.new(cos(a) * r + zap, h + arc + zap, sin(a) * r + zap)
end

Shapes["Event Horizon"] = function(i, n, t, r, h, sp)
    frac = i / n
    a = frac * TAU * 5 + t * sp
    dist = r * (0.2 + 0.8 * abs(sin(frac * math.pi)))
    warp = sin(t * sp * 3 + frac * TAU) * r * 0.1
    return Vector3.new(cos(a) * dist, h + warp, sin(a) * dist)
end

Shapes.Butterfly = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp * 0.5)
    ex = math.exp(cos(a)) - 2 * cos(4 * a) - sin(a / 12) ^ 5
    rr = ex * r * 0.4
    return Vector3.new(cos(a) * rr, h + sin(t * sp + i * 0.1) * 1.5, sin(a) * rr)
end

Shapes["Rose Petal"] = function(i, n, t, r, h, sp)
    k = 5
    a = baseAngle(i, n, t, sp * 0.3)
    rr = r * cos(k * a)
    return Vector3.new(cos(a) * rr, h + sin(t * sp + i * 0.2) * 2, sin(a) * rr)
end

Shapes.Snowflake = function(i, n, t, r, h, sp)
    arm = i % 6
    frac = (i % math.max(math.floor(n / 6), 1)) / math.max(math.floor(n / 6), 1)
    baseA = arm * (TAU / 6) + t * sp * 0.2
    dist = frac * r
    branch = sin(frac * math.pi * 4) * r * 0.2
    return Vector3.new(cos(baseA) * dist + cos(baseA + math.pi / 2) * branch, h + cos(t * sp) * 0.5, sin(baseA) * dist + sin(baseA + math.pi / 2) * branch)
end

Shapes["Crystal Bloom"] = function(i, n, t, r, h, sp)
    petals = 8
    arm = i % petals
    frac = (i % math.max(math.floor(n / petals), 1)) / math.max(math.floor(n / petals), 1)
    baseA = arm * (TAU / petals) + t * sp * 0.3
    dist = frac * r
    lift = sin(frac * math.pi) * r * 0.5
    return Vector3.new(cos(baseA) * dist, h + lift, sin(baseA) * dist)
end

Shapes["Vine Wrap"] = function(i, n, t, r, h, sp)
    frac = i / n
    turns = 4
    a = frac * TAU * turns + t * sp
    y = frac * r * 2 - r
    bulge = 1 + 0.3 * sin(frac * TAU * turns * 2)
    rr = r * 0.5 * bulge
    return Vector3.new(cos(a) * rr, h + y, sin(a) * rr)
end

Shapes["Flower Bloom"] = function(i, n, t, r, h, sp)
    petals = 6
    a = baseAngle(i, n, t, sp * 0.4)
    rr = r * abs(cos(petals * a * 0.5))
    bloom = 1 + 0.2 * sin(t * sp * 2)
    return Vector3.new(cos(a) * rr * bloom, h + sin(t * sp + a) * 1.5, sin(a) * rr * bloom)
end

Shapes.Jellyfish = function(i, n, t, r, h, sp)
    bell = math.floor(n * 0.4)
    if i <= bell then
        phi = (i / bell) * math.pi * 0.5
        theta = baseAngle(i, bell, t, sp)
        pulse = r * (1 + 0.2 * sin(t * sp * 3))
        return Vector3.new(cos(theta) * sin(phi) * pulse, cos(phi) * pulse * 0.5 + h, sin(theta) * sin(phi) * pulse)
    else
        idx = i - bell
        c = n - bell
        a = (idx / c) * TAU + t * sp
        drop = (idx / c) * r * 1.5
        wave = sin(t * sp * 4 + a * 3) * r * 0.15
        return Vector3.new(cos(a) * r * 0.2 + wave, h - drop, sin(a) * r * 0.2 + wave)
    end
end

Shapes["Coral Reef"] = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp * 0.2)
    frac = i / n
    y = sin(frac * TAU * 3 + t * sp) * r * 0.8
    rr = r * (0.5 + 0.5 * sin(frac * TAU * 5))
    sway = sin(t * sp + frac * 12) * r * 0.1
    return Vector3.new(cos(a) * rr + sway, h + y, sin(a) * rr + sway)
end

Shapes["Volcano Burst"] = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    burst = abs(sin(t * sp + i)) * r * 2
    return Vector3.new(cos(a) * burst, h + burst, sin(a) * burst)
end

Shapes["Fluxy Explosion"] = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    wave = abs(sin(t * sp * 2 - i * 0.1))
    return Vector3.new(cos(a) * r * wave * 3, h + wave * 5, sin(a) * r * wave * 3)
end

Shapes.Supernova = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5)) + t * sp
    blast = r * (1 + sin(t * sp * 0.5) * 0.5)
    eject = sin(phi * 3 + t * sp * 4) * r * 0.3
    return Vector3.new(cos(theta) * sin(phi) * (blast + eject), cos(phi) * (blast + eject) + h, sin(theta) * sin(phi) * (blast + eject))
end

Shapes["Firework Pop"] = function(i, n, t, r, h, sp)
    phi = math.acos(1 - 2 * (i / n))
    theta = i * math.pi * (3 - sqrt(5))
    trail = abs(sin(t * sp * 3 + i * 0.7))
    rr = r * trail
    sparkle = sin(t * sp * 10 + i) * 0.8
    return Vector3.new(cos(theta) * sin(phi) * rr, cos(phi) * rr + h + sparkle, sin(theta) * sin(phi) * rr)
end

Shapes.Shockwave = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    ring = sin(t * sp * 3) * r
    y = cos(t * sp * 2 + i * 0.2) * r * 0.3
    return Vector3.new(cos(a) * ring, h + y, sin(a) * ring)
end

Shapes.Lissajous = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    p, q = 3, 2
    d = math.pi / 2
    return Vector3.new(r * sin(p * a + d), h + r * 0.4 * sin(t * sp + i * 0.1), r * sin(q * a))
end

Shapes.Hypotrochoid = function(i, n, t, r, h, sp)
    R, rd, d = r, r * 0.4, r * 0.7
    a = baseAngle(i, n, t, sp)
    x = (R - rd) * cos(a) + d * cos((R - rd) / rd * a)
    z = (R - rd) * sin(a) - d * sin((R - rd) / rd * a)
    return Vector3.new(x * 0.7, h + sin(t * sp + i * 0.2) * 2, z * 0.7)
end

Shapes.Epitrochoid = function(i, n, t, r, h, sp)
    R, rd, d = r * 0.6, r * 0.35, r * 0.5
    a = baseAngle(i, n, t, sp)
    x = (R + rd) * cos(a) - d * cos((R + rd) / rd * a)
    z = (R + rd) * sin(a) - d * sin((R + rd) / rd * a)
    return Vector3.new(x * 0.7, h + sin(t * sp + i * 0.15) * 2, z * 0.7)
end

Shapes.Trefoil = function(i, n, t, r, h, sp)
    a = baseAngle(i, n, t, sp)
    x = sin(a) + 2 * sin(2 * a)
    y = cos(a) - 2 * cos(2 * a)
    z = -sin(3 * a)
    sc = r / 3
    return Vector3.new(x * sc, y * sc + h, z * sc)
end

Shapes["Klein Bottle Slice"] = function(i, n, t, r, h, sp)
    u = baseAngle(i, n, t, sp)
    v = baseAngle(i, math.max(n, 1), t * 2, sp)
    a = r * 0.3
    x = (a + a * cos(v)) * cos(u)
    y = (a + a * cos(v)) * sin(u)
    z = a * sin(v) + sin(t * sp + i * 0.2) * 2
    return Vector3.new(x, y + h, z)
end

Shapes.Harmonograph = function(i, n, t, r, h, sp)
    frac = i / n
    decay = math.exp(-frac * 0.5)
    f1, f2, f3, f4 = 3, 2, 3, 2
    p1, p2 = math.pi / 4, math.pi / 6
    a = frac * TAU * 8 + t * sp
    x = r * decay * (sin(f1 * a + p1) + sin(f2 * a))
    z = r * decay * (sin(f3 * a + p2) + sin(f4 * a))
    return Vector3.new(x * 0.5, h + sin(t * sp + frac * 12) * 1.5, z * 0.5)
end

function GetShapeOffset(index, total, t, cfg)
    fn = Shapes[cfg.CurrentShape]
    if fn then
        return fn(index, total, t, cfg.Radius, cfg.Height, cfg.Speed)
    end
    a = (index / total) * TAU + t * cfg.Speed
    return Vector3.new(cos(a) * cfg.Radius, cfg.Height, sin(a) * cfg.Radius)
end

-- Select Shape + Shape Radius created at top of Toys tab (early register)
if sparklerConfig and ((getgenv and getgenv()) or _G).sparklerConfig then
    sparklerConfig = ((getgenv and getgenv()) or _G).sparklerConfig
end

SparklerGroup:CreateSlider({
    Name = "Height Offset",
    Default = 5,
    Min = -20,
    Max = 150,
    Callback = function(v)
        sparklerConfig.Height = v
    end
})

SparklerGroup:CreateSlider({
    Name = "Rotation Speed",
    Default = 2,
    Min = 0,
    Max = 20,
    Callback = function(v)
        sparklerConfig.Speed = v
    end
})

SparklerGroup:CreateButton({
    Name = "Synchronize All Sparklers",
    Callback = function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:find("FireworkSparkler") then
                SetupPhysics(obj, activeSparklers)
            end
        end
    end
})

SparklerGroup:CreateButton({
    Name = "Unsynchronize All Sparklers",
    Callback = function()
        activeSparklers = {}
    end
})

RunService.RenderStepped:Connect(function()
	if not sparklersRunning then return end
    char = LocalPlayer.Character
    targetRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end

    t = tick()
    prediction = targetRoot.AssemblyLinearVelocity * 0.12
    rot = targetRoot.CFrame.Rotation

    for i = #activeSparklers, 1, -1 do
        obj = activeSparklers[i]
        if obj and obj.Parent then
            main = obj:IsA("BasePart") and obj or obj.PrimaryPart
            bp = main and main:FindFirstChild("ToyBodyPos")
            bg = main and main:FindFirstChild("ToyBodyGyro")
            if bp and bg then
                offset = GetShapeOffset(i, #activeSparklers, t, sparklerConfig)
                bp.Position = targetRoot.Position + prediction + (rot * offset)
                bg.CFrame = CFrame.new(main.Position, targetRoot.Position + prediction)
            end
        else
            table.remove(activeSparklers, i)
        end
    end
end)
end

function startSparklers()
	sparklersRunning = true
	activeSparklers = {}
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj.Name:find("FireworkSparkler") then
			SetupPhysics(obj, activeSparklers)
		end
	end
end

function stopSparklers()
	sparklersRunning = false
	activeSparklers = {}
end

function setSparklerShape(name)
	sparklerConfig.CurrentShape = name
end

function setSparklerRadius(v)
	sparklerConfig.Radius = v
end

function setSparklerHeight(v)
	sparklerConfig.Height = v
end

function setSparklerSpeed(v)
	sparklerConfig.Speed = v
end

function spawnFireworkSparklers(count, atCF)
	count = count or 5
	local hrp = getHRP()
	local base = atCF or (hrp and hrp.CFrame * CFrame.new(0, 3, -8)) or CFrame.new(0, 10, 0)
	local n = 0
	for i = 1, count do
		local offset = CFrame.new(((i - 1) % 4) * 2.5, 1, math.floor((i - 1) / 4) * 2.5)
		if spawnToy("FireworkSparkler", base * offset) then
			n = n + 1
		end
		task.wait(0.04)
	end
	task.wait(0.2)
	if sparklersRunning then
		startSparklers()
	end
	return n
end

function spawnSparklersOnPlot(plotId, count)
	count = count or 5
	local plots = Workspace:FindFirstChild("Plots")
	local plot = plots and plots:FindFirstChild("Plot" .. tostring(plotId))
	if not plot then return 0 end
	local area = plot:FindFirstChild("PlotArea")
	local base
	if area and area:IsA("BasePart") then
		base = area.CFrame * CFrame.new(0, 3, 0)
	else
		local part = plot:FindFirstChildWhichIsA("BasePart", true)
		base = part and part.CFrame * CFrame.new(0, 5, 0)
	end
	if not base then return 0 end
	local folder = getToyFolder()
	local before = {}
	if folder then
		for _, ch in ipairs(folder:GetChildren()) do before[ch] = true end
	end
	local spawned = 0
	for i = 1, count do
		local offset = CFrame.new(((i - 1) % 4) * 2.5, 1, math.floor((i - 1) / 4) * 2.5)
		spawnToy("FireworkSparkler", base * offset)
		local t0 = tick()
		local spark
		while tick() - t0 < 2 do
			folder = getToyFolder()
			if folder then
				for _, ch in ipairs(folder:GetChildren()) do
					if (ch.Name == "FireworkSparkler" or ch.Name:find("Sparkler")) and not before[ch] then
						spark = ch
						break
					end
				end
			end
			if spark then break end
			task.wait(0.04)
		end
		if spark then
			before[spark] = true
			spawned = spawned + 1
			local sticky = spark:FindFirstChild("StickyPart") or spark:FindFirstChildWhichIsA("BasePart", true)
			if sticky and area then
				networkOwn(sticky, 10)
				pcall(function() StickyPartEvent:FireServer(sticky, area, CFrame.new()) end)
			end
			if sparklersRunning then
				SetupPhysics(spark, activeSparklers)
			end
		end
		task.wait(0.04)
	end
	return spawned
end

local function getOrCreateShuriken()
	local inv = getToyFolder()
	local hrp = getHRP()
	if not hrp then return nil end
	if inv then
		for _, obj in pairs(inv:GetChildren()) do
			if (obj.Name == "NinjaShuriken" or obj.Name == "Noclipped") and obj:FindFirstChild("StickyPart") then
				return obj
			end
		end
	end
	spawnToy("NinjaShuriken", hrp.CFrame * CFrame.new(5, 8, 20))
	inv = getToyFolder() or Workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 4)
	if not inv then return nil end
	local t0 = tick()
	local shur
	while tick() - t0 < 3 do
		shur = inv:FindFirstChild("NinjaShuriken")
		if shur and shur:FindFirstChild("StickyPart") then return shur end
		task.wait(0.04)
	end
	return inv:FindFirstChild("NinjaShuriken")
end

local function prepShuriken(shur)
	if not shur then return nil end
	local sticky = shur:FindFirstChild("StickyPart")
	local sound = shur:FindFirstChild("SoundPart")
	if not sticky then return nil end
	if sound then networkOwn(sound, 10) end
	networkOwn(sticky, 10)
	for _, obj in pairs(shur:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj.CanTouch = false
			obj.CanCollide = false
			obj.CanQuery = false
			if obj.Transparency == 0 then obj.Transparency = 1 end
		end
	end
	shur.Name = "Noclipped"
	return sticky
end

function breakPlot(plotId)
	plotId = tostring(plotId or SelectedPlot)
	SelectedPlot = plotId
	local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild("Plot" .. plotId)
	if not plot then return false end
	local plotArea = plot:FindFirstChild("PlotArea")
	if not plotArea then return false end
	local shur = getOrCreateShuriken()
	local sticky = prepShuriken(shur)
	if not sticky then return false end
	return pcall(function()
		StickyPartEvent:FireServer(sticky, plotArea, HUGE_CF)
	end)
end

function breakHouse(plotId)
	return breakPlot(plotId)
end

function breakAllPlots()
	for i = 1, 5 do
		breakPlot(i)
		task.wait(0.25)
	end
end

function setPlotBarriers(enabled)
	local plots = Workspace:FindFirstChild("Plots")
	if not plots then return end
	for i = 1, 5 do
		local plot = plots:FindFirstChild("Plot" .. i)
		local barrier = plot and plot:FindFirstChild("Barrier")
		if barrier then
			for _, part in ipairs(barrier:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = enabled and true or false
				end
			end
		end
	end
end

function togglePlotBarriers()
	local plots = Workspace:FindFirstChild("Plots")
	if not plots then return end
	for i = 1, 5 do
		local plot = plots:FindFirstChild("Plot" .. i)
		local barrier = plot and plot:FindFirstChild("Barrier")
		if barrier then
			for _, part in ipairs(barrier:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = not part.CanCollide
				end
			end
		end
	end
end
