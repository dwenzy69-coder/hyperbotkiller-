-- // Hyper Realistic Ragdoll - Auto Farm v9
-- // Language: Luau | Platform: Roblox Executor
-- // Style: Blox Fruits Hub UI

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera

local CFG = {
    AutoFarm   = false,
    HeightAbove = 3,
    WaitDeath  = 5,
    FireRate   = 0.15,
    ShowHL     = true,
    Range      = 100,
}

local kills = 0
local HL = {}
local autoOn = false

-- ===== COLORS (Blox Fruits palette) =====
local C = {
    bg       = Color3.fromRGB(18, 18, 28),
    panel    = Color3.fromRGB(25, 25, 40),
    accent   = Color3.fromRGB(255, 180, 0),
    accent2  = Color3.fromRGB(220, 100, 0),
    green    = Color3.fromRGB(0, 200, 80),
    red      = Color3.fromRGB(220, 50, 50),
    blue     = Color3.fromRGB(30, 120, 220),
    text     = Color3.fromRGB(255, 255, 255),
    subtext  = Color3.fromRGB(160, 160, 180),
    dark     = Color3.fromRGB(12, 12, 20),
}

-- ===== UI =====
local SG = Instance.new("ScreenGui")
SG.Name = "BFStyleUI"
SG.ResetOnSpawn = false
SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SG.Parent = game:GetService("CoreGui")

-- Main Window
local Win = Instance.new("Frame", SG)
Win.Size = UDim2.new(0, 300, 0, 420)
Win.Position = UDim2.new(0.5, -150, 0.5, -210)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.Active = true
Win.Draggable = true
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 14)

-- Drop shadow effect
local Shadow = Instance.new("Frame", Win)
Shadow.Size = UDim2.new(1, 20, 1, 20)
Shadow.Position = UDim2.new(0, -10, 0, -10)
Shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Instance.new("UICorner", Shadow).CornerRadius = UDim.new(0, 18)

-- Top gradient bar
local TopBar = Instance.new("Frame", Win)
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = C.dark
TopBar.BorderSizePixel = 0
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TopGrad = Instance.new("UIGradient", TopBar)
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent2),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 60, 0)),
})
TopGrad.Rotation = 90

-- Title
local TitleLbl = Instance.new("TextLabel", TopBar)
TitleLbl.Size = UDim2.new(1, -20, 1, 0)
TitleLbl.Position = UDim2.new(0, 14, 0, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "⚔️  AUTO FARM"
TitleLbl.TextColor3 = C.text
TitleLbl.TextScaled = true
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Subtitle
local SubLbl = Instance.new("TextLabel", Win)
SubLbl.Size = UDim2.new(1, -20, 0, 20)
SubLbl.Position = UDim2.new(0, 14, 0, 56)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Hyper Realistic Ragdoll"
SubLbl.TextColor3 = C.accent
SubLbl.TextScaled = true
SubLbl.Font = Enum.Font.GothamSemibold
SubLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Divider
local Div = Instance.new("Frame", Win)
Div.Size = UDim2.new(1, -28, 0, 1)
Div.Position = UDim2.new(0, 14, 0, 82)
Div.BackgroundColor3 = C.accent
Div.BackgroundTransparency = 0.7
Div.BorderSizePixel = 0

-- Stats panel
local StatPanel = Instance.new("Frame", Win)
StatPanel.Size = UDim2.new(1, -28, 0, 56)
StatPanel.Position = UDim2.new(0, 14, 0, 90)
StatPanel.BackgroundColor3 = C.panel
StatPanel.BorderSizePixel = 0
Instance.new("UICorner", StatPanel).CornerRadius = UDim.new(0, 10)

-- Kill count
local KillIcon = Instance.new("TextLabel", StatPanel)
KillIcon.Size = UDim2.new(0.5, 0, 1, 0)
KillIcon.Position = UDim2.new(0, 0, 0, 0)
KillIcon.BackgroundTransparency = 1
KillIcon.Text = "☠  0"
KillIcon.Name = "KillLbl"
KillIcon.TextColor3 = C.accent
KillIcon.TextScaled = true
KillIcon.Font = Enum.Font.GothamBold

-- Status
local StatLbl = Instance.new("TextLabel", StatPanel)
StatLbl.Size = UDim2.new(0.5, 0, 1, 0)
StatLbl.Position = UDim2.new(0.5, 0, 0, 0)
StatLbl.BackgroundTransparency = 1
StatLbl.Text = "● Idle"
StatLbl.TextColor3 = C.subtext
StatLbl.TextScaled = true
StatLbl.Font = Enum.Font.Gotham

-- Target label
local TgPanel = Instance.new("Frame", Win)
TgPanel.Size = UDim2.new(1, -28, 0, 36)
TgPanel.Position = UDim2.new(0, 14, 0, 154)
TgPanel.BackgroundColor3 = C.panel
TgPanel.BorderSizePixel = 0
Instance.new("UICorner", TgPanel).CornerRadius = UDim.new(0, 8)

local TgLbl = Instance.new("TextLabel", TgPanel)
TgLbl.Size = UDim2.new(1, -10, 1, 0)
TgLbl.Position = UDim2.new(0, 8, 0, 0)
TgLbl.BackgroundTransparency = 1
TgLbl.Text = "🎯  Target: Scanning..."
TgLbl.TextColor3 = C.subtext
TgLbl.TextScaled = true
TgLbl.Font = Enum.Font.Gotham
TgLbl.TextXAlignment = Enum.TextXAlignment.Left

-- ===== TOGGLE BUTTON FACTORY =====
local function MakeToggle(labelText, y, onColor)
    local row = Instance.new("Frame", Win)
    row.Size = UDim2.new(1, -28, 0, 44)
    row.Position = UDim2.new(0, 14, 0, y)
    row.BackgroundColor3 = C.panel
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.7, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = C.text
    lbl.TextScaled = true
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Toggle pill
    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0, 46, 0, 24)
    pill.Position = UDim2.new(1, -58, 0.5, -12)
    pill.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", pill)
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = UDim2.new(0, 3, 0.5, -9)
    dot.BackgroundColor3 = C.subtext
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = false
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 25, 0.5, -9),
                BackgroundColor3 = C.text,
            }):Play()
            TweenService:Create(pill, TweenInfo.new(0.2), {
                BackgroundColor3 = onColor,
            }):Play()
        else
            TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = UDim2.new(0, 3, 0.5, -9),
                BackgroundColor3 = C.subtext,
            }):Play()
            TweenService:Create(pill, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(60,60,80),
            }):Play()
        end
    end)

    return btn, function() return state end
end

local BtnFarm,   FarmOn   = MakeToggle("⚔️  Auto Farm",      200, C.green)
local BtnHL,     HLOn     = MakeToggle("🔵  Highlight Bots",  252, C.blue)
local BtnTP,     TPOn     = MakeToggle("⚡  Auto Teleport",   304, C.accent)

-- Kill Once button
local KillOnce = Instance.new("TextButton", Win)
KillOnce.Size = UDim2.new(1, -28, 0, 42)
KillOnce.Position = UDim2.new(0, 14, 0, 358)
KillOnce.BackgroundColor3 = C.red
KillOnce.BorderSizePixel = 0
KillOnce.Text = "☠   Kill All Once"
KillOnce.TextColor3 = C.text
KillOnce.TextScaled = true
KillOnce.Font = Enum.Font.GothamBold
Instance.new("UICorner", KillOnce).CornerRadius = UDim.new(0, 10)
local KOGrad = Instance.new("UIGradient", KillOnce)
KOGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.red),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 20, 20)),
})
KOGrad.Rotation = 90

-- ===== DETECT =====
local function isBot(m)
    if not m:IsA("Model") then return false end
    local h = m:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if not (m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")) then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return false end
    end
    return true
end

local function getBots()
    local t = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if isBot(o) then table.insert(t, o) end
    end
    return t
end

-- Sort by distance
local function getNearestBot()
    local c = LP.Character
    if not c then return nil end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local nearest, dist = nil, math.huge
    for _, o in ipairs(workspace:GetDescendants()) do
        if isBot(o) then
            local r = o:FindFirstChild("HumanoidRootPart") or o:FindFirstChild("Torso")
            if r then
                local d = (r.Position - root.Position).Magnitude
                if d < dist then dist = d nearest = o end
            end
        end
    end
    return nearest
end

-- ===== HIGHLIGHT =====
local function addHL(bot)
    if not HLOn() or HL[bot] then return end
    local s = Instance.new("SelectionBox", SG)
    s.Adornee = bot
    s.Color3 = C.accent
    s.LineThickness = 0.06
    s.SurfaceTransparency = 0.85
    HL[bot] = s
end

local function clearHL()
    for b,s in pairs(HL) do s:Destroy() HL[b]=nil end
end

-- ===== TOOL =====
local function getTool()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Tool")
end

local function equipTool()
    local c = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    if not c or not bp then return end
    local t = bp:FindFirstChildOfClass("Tool")
    if t then t.Parent = c task.wait(0.15) end
end

-- ===== FIRE =====
local function fireAt(worldPos)
    local screenPos, onScreen = Cam:WorldToScreenPoint(worldPos)
    if not onScreen then return false end
    local sx = math.floor(screenPos.X)
    local sy = math.floor(screenPos.Y)
    pcall(function() Mouse.Hit = CFrame.new(worldPos) end)
    pcall(function()
        VIM:SendMouseButtonEvent(sx, sy, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(sx, sy, 0, false, game, 0)
    end)
    return true
end

-- ===== KILL =====
local function killBot(bot)
    local c = LP.Character
    if not c then return false end
    local myRoot = c:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    local botHead = bot:FindFirstChild("Head")
    local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
    local hum = bot:FindFirstChildOfClass("Humanoid")
    if not botHead or not botRoot or not hum or hum.Health <= 0 then return false end

    -- Teleport atas kepala
    local above = botHead.Position + Vector3.new(0, CFG.HeightAbove, 0)
    myRoot.CFrame = CFrame.new(above, botHead.Position)
    task.wait(0.1)

    if not getTool() then equipTool() end
    if not getTool() then return false end

    -- Update status
    StatLbl.Text = "● Farming"
    StatLbl.TextColor3 = C.green

    local t0 = tick()
    while hum.Health > 0 and (tick() - t0) < CFG.WaitDeath do
        local headNow = botHead.Position
        local aboveNow = headNow + Vector3.new(0, CFG.HeightAbove, 0)
        myRoot.CFrame = CFrame.new(aboveNow, headNow)
        Cam.CFrame = CFrame.lookAt(aboveNow + Vector3.new(0,0.5,0), headNow)
        fireAt(headNow)
        task.wait(CFG.FireRate)
    end

    if hum.Health <= 0 then
        kills += 1
        KillIcon.Text = "☠  " .. kills
        return true
    end
    return false
end

-- ===== SEQUENCES =====
local function killAll()
    local bots = getBots()
    if #bots == 0 then
        TgLbl.Text = "🎯  Target: No bots found"
        StatLbl.Text = "● Idle"
        StatLbl.TextColor3 = C.subtext
        return
    end
    for i, bot in ipairs(bots) do
        if not bot.Parent or not isBot(bot) then continue end
        local name = bot.Name or ("Bot " .. i)
        TgLbl.Text = string.format("🎯  %s  [%d/%d]", name, i, #bots)
        killBot(bot)
        if HL[bot] then HL[bot]:Destroy() HL[bot]=nil end
        task.wait(0.05)
    end
    TgLbl.Text = "🎯  Target: Done"
    StatLbl.Text = "● Idle"
    StatLbl.TextColor3 = C.subtext
end

-- Auto farm loop — nearest bot first
local function autoFarmLoop()
    while FarmOn() do
        local bot = getNearestBot()
        if bot then
            local name = bot.Name or "Bot"
            TgLbl.Text = "🎯  " .. name .. " (nearest)"
            killBot(bot)
            if HL[bot] then HL[bot]:Destroy() HL[bot]=nil end
        else
            TgLbl.Text = "🎯  Scanning..."
            StatLbl.Text = "● Scanning"
            StatLbl.TextColor3 = C.accent
        end
        task.wait(0.2)
    end
    StatLbl.Text = "● Idle"
    StatLbl.TextColor3 = C.subtext
    TgLbl.Text = "🎯  Target: -"
end

-- ===== BUTTON EVENTS =====
KillOnce.MouseButton1Click:Connect(function()
    task.spawn(killAll)
end)

BtnFarm.MouseButton1Click:Connect(function()
    task.wait(0.05)
    if FarmOn() then
        task.spawn(autoFarmLoop)
    end
end)

-- ===== REALTIME =====
RunService.Heartbeat:Connect(function()
    -- Highlight sync
    if HLOn() then
        for _, b in ipairs(getBots()) do addHL(b) end
        for b,s in pairs(HL) do
            if not b.Parent or not isBot(b) then s:Destroy() HL[b]=nil end
        end
    else
        clearHL()
    end
end)

print("[AutoFarm v9 BF-Style] Loaded")
