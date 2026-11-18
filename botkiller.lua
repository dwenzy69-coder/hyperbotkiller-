-- // Hyper Realistic Ragdoll - Killer v7
-- // Language: Luau | Platform: Roblox Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local CONFIG = {
    StandDist  = 4,    -- stud depan bot
    WaitDeath  = 5,    -- max detik tunggu mati
    FireRate   = 0.12, -- interval tembak
    AutoKill   = false,
    HighlightBots = true,
}

local killCount = 0
local highlights = {}

-- ======= UI =======
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 210, 0, 290)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255, 60, 60)
Stroke.Thickness = 1.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1, 0, 1, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "🎯 KILLER v7"
TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLbl.TextScaled = true
TitleLbl.Font = Enum.Font.GothamBold

local KillLbl = Instance.new("TextLabel", MainFrame)
KillLbl.Size = UDim2.new(1,-20,0,28)
KillLbl.Position = UDim2.new(0,10,0,44)
KillLbl.BackgroundTransparency = 1
KillLbl.Text = "Killed: 0"
KillLbl.TextColor3 = Color3.fromRGB(255,80,80)
KillLbl.TextScaled = true
KillLbl.Font = Enum.Font.GothamBold

local StatusLbl = Instance.new("TextLabel", MainFrame)
StatusLbl.Size = UDim2.new(1,-20,0,22)
StatusLbl.Position = UDim2.new(0,10,0,76)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: Idle"
StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
StatusLbl.TextScaled = true
StatusLbl.Font = Enum.Font.Gotham

local TargetLbl = Instance.new("TextLabel", MainFrame)
TargetLbl.Size = UDim2.new(1,-20,0,22)
TargetLbl.Position = UDim2.new(0,10,0,100)
TargetLbl.BackgroundTransparency = 1
TargetLbl.Text = "Target: -"
TargetLbl.TextColor3 = Color3.fromRGB(255,200,0)
TargetLbl.TextScaled = true
TargetLbl.Font = Enum.Font.Gotham

local function MakeBtn(text, y, col)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = col
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    return b
end

local BtnOnce = MakeBtn("☠ Kill All (Once)", 130, Color3.fromRGB(180,30,30))
local BtnAuto = MakeBtn("🔁 Auto Kill: OFF",  178, Color3.fromRGB(40,40,120))
local BtnHL   = MakeBtn("🔵 Highlight: ON",   226, Color3.fromRGB(0,80,160))

-- ======= DETECT =======
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

-- ======= HIGHLIGHT =======
local function addHL(bot)
    if not CONFIG.HighlightBots or highlights[bot] then return end
    local s = Instance.new("SelectionBox", ScreenGui)
    s.Adornee = bot
    s.Color3 = Color3.fromRGB(255,50,50)
    s.LineThickness = 0.06
    s.SurfaceTransparency = 0.85
    highlights[bot] = s
end

local function clearHL()
    for b,s in pairs(highlights) do s:Destroy() highlights[b]=nil end
end

-- ======= TOOL =======
local function getTool()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Tool")
end

local function equipTool()
    local c = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not c or not bp then return end
    local t = bp:FindFirstChildOfClass("Tool")
    if t then t.Parent = c task.wait(0.15) end
end

-- ======= CORE: aim + fire =======
-- Kamera di-set CFrame dari posisi karakter lo ke tepat kepala bot
-- Ini yang paling akurat — ga ada offset aneh
local function aimAndFire(headPos)
    local c = LocalPlayer.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local tool = getTool()
    if not tool then return end

    -- Posisi kamera = setinggi kepala lo, dari situ ngarah ke head bot
    local camPos = root.Position + Vector3.new(0, 1.5, 0)
    Camera.CFrame = CFrame.lookAt(camPos, headPos)

    -- Mouse.Hit = tepat di head
    pcall(function()
        Mouse.Hit = CFrame.new(headPos)
    end)

    -- Fire remote di tool — pakai Mouse.Hit (bukan manual position)
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(Mouse.Hit) end)
        end
    end

    -- Activated fallback
    pcall(function() tool.Activated:Fire() end)
end

-- ======= KILL LOOP =======
local function killBot(bot)
    local c = LocalPlayer.Character
    if not c then return false end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
    local botHead = bot:FindFirstChild("Head")
    local hum = bot:FindFirstChildOfClass("Humanoid")
    if not botRoot or not botHead or not hum or hum.Health <= 0 then return false end

    -- Teleport: posisi depan bot, badan lo ngarah ke bot
    local targetPos = botRoot.Position + botRoot.CFrame.LookVector * CONFIG.StandDist
    targetPos = Vector3.new(targetPos.X, botRoot.Position.Y, targetPos.Z)
    root.CFrame = CFrame.new(targetPos, botRoot.Position)
    task.wait(0.1)

    -- Equip tool
    if not getTool() then equipTool() end
    if not getTool() then return false end

    -- Fire loop
    local t0 = tick()
    while hum.Health > 0 and (tick() - t0) < CONFIG.WaitDeath do
        -- Refresh head position tiap iterasi (bot gerak)
        aimAndFire(botHead.Position)
        task.wait(CONFIG.FireRate)
    end

    if hum.Health <= 0 then
        killCount += 1
        KillLbl.Text = "Killed: " .. killCount
        return true
    end
    return false
end

-- ======= SEQUENCE =======
local function killAll()
    StatusLbl.Text = "Status: Hunting..."
    StatusLbl.TextColor3 = Color3.fromRGB(255,80,80)
    local bots = getBots()
    if #bots == 0 then
        StatusLbl.Text = "Status: No bots"
        StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
        return
    end
    for i, bot in ipairs(bots) do
        if not bot.Parent or not isBot(bot) then continue end
        TargetLbl.Text = string.format("Target: %d / %d", i, #bots)
        killBot(bot)
        if highlights[bot] then highlights[bot]:Destroy() highlights[bot]=nil end
        task.wait(0.05)
    end
    TargetLbl.Text = "Target: -"
    StatusLbl.Text = string.format("Done ✓ — %d killed", killCount)
    StatusLbl.TextColor3 = Color3.fromRGB(80,255,80)
end

-- ======= BUTTONS =======
local autoRunning = false

BtnOnce.MouseButton1Click:Connect(function() task.spawn(killAll) end)

BtnAuto.MouseButton1Click:Connect(function()
    CONFIG.AutoKill = not CONFIG.AutoKill
    if CONFIG.AutoKill then
        BtnAuto.Text = "🔁 Auto Kill: ON"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(180,30,30)
        autoRunning = true
        task.spawn(function()
            while autoRunning do killAll() task.wait(0.2) end
        end)
    else
        autoRunning = false
        BtnAuto.Text = "🔁 Auto Kill: OFF"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(40,40,120)
        StatusLbl.Text = "Status: Stopped"
        StatusLbl.TextColor3 = Color3.fromRGB(150,150,150)
        TargetLbl.Text = "Target: -"
    end
end)

BtnHL.MouseButton1Click:Connect(function()
    CONFIG.HighlightBots = not CONFIG.HighlightBots
    if CONFIG.HighlightBots then
        BtnHL.Text = "🔵 Highlight: ON"
        for _, b in ipairs(getBots()) do addHL(b) end
    else
        BtnHL.Text = "⚫ Highlight: OFF"
        clearHL()
    end
end)

RunService.Heartbeat:Connect(function()
    if CONFIG.HighlightBots then
        for _, b in ipairs(getBots()) do addHL(b) end
        for b,s in pairs(highlights) do
            if not b.Parent or not isBot(b) then s:Destroy() highlights[b]=nil end
        end
    end
end)

print("[Killer v7] Loaded")
