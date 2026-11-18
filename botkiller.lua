-- // Hyper Realistic Ragdoll - Headshot Killer v3
-- // Language: Luau | Platform: Roblox Executor
-- // Target: NPC/Bot entities in-game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local CONFIG = {
    AutoKill = false,
    TeleportOffset = Vector3.new(0, 0, 4), -- jarak depan bot
    HeadOffset = Vector3.new(0, 1.5, 0),   -- tinggi kepala
    KillDelay = 0.15,                       -- jeda antar bot
    HighlightBots = true,
}

local killCount = 0
local killed = {}
local highlights = {}

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeadshotKillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 270)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 60, 60)
UIStroke.Thickness = 1.5

-- Title
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎯 HEADSHOT KILLER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold

-- Counter
local CounterLabel = Instance.new("TextLabel", MainFrame)
CounterLabel.Size = UDim2.new(1, -20, 0, 30)
CounterLabel.Position = UDim2.new(0, 10, 0, 44)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "Killed: 0"
CounterLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
CounterLabel.TextScaled = true
CounterLabel.Font = Enum.Font.GothamBold

-- Status
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 24)
StatusLabel.Position = UDim2.new(0, 10, 0, 78)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham

-- Current Target
local TargetLabel = Instance.new("TextLabel", MainFrame)
TargetLabel.Size = UDim2.new(1, -20, 0, 24)
TargetLabel.Position = UDim2.new(0, 10, 0, 104)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: -"
TargetLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
TargetLabel.TextScaled = true
TargetLabel.Font = Enum.Font.Gotham

-- // Helper: Button
local function CreateButton(text, posY, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local KillOnceBtn = CreateButton("☠ Kill All (Once)", 136, Color3.fromRGB(180, 30, 30))
local AutoKillBtn = CreateButton("🔁 Auto Kill: OFF", 184, Color3.fromRGB(40, 40, 120))
local HighlightBtn = CreateButton("🔵 Highlight: ON", 230, Color3.fromRGB(0, 80, 160))

-- // BOT DETECTION
local function isBot(model)
    if not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    if humanoid.Health <= 0 then return false end
    if not (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")) then return false end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return false end
    end
    return true
end

local function getBots()
    local bots = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isBot(obj) then
            table.insert(bots, obj)
        end
    end
    return bots
end

-- // HIGHLIGHT
local function applyHighlight(bot)
    if not CONFIG.HighlightBots or highlights[bot] then return end
    local hl = Instance.new("SelectionBox", ScreenGui)
    hl.Adornee = bot
    hl.Color3 = Color3.fromRGB(255, 50, 50)
    hl.LineThickness = 0.08
    hl.SurfaceTransparency = 0.8
    hl.SurfaceColor3 = Color3.fromRGB(255, 80, 80)
    highlights[bot] = hl
end

local function clearHighlights()
    for bot, hl in pairs(highlights) do
        hl:Destroy()
        highlights[bot] = nil
    end
end

-- // CORE: Teleport ke depan bot → aim kepala → tembak
local function getHead(bot)
    return bot:FindFirstChild("Head")
end

local function getRoot(bot)
    return bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
end

local function getTool()
    -- Ambil tool pertama yang ada di karakter (senjata)
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function equipTool()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local tool = backpack:FindFirstChildOfClass("Tool")
    if tool then
        -- Pindah tool ke karakter (equip)
        tool.Parent = LocalPlayer.Character
        task.wait(0.05)
    end
end

local function aimAtHead(headPos)
    -- Set kamera look ke arah kepala bot
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
end

local function fireTool()
    -- Simulasi klik mouse (tembak)
    local tool = getTool()
    if not tool then return end

    -- Coba via RemoteEvent (game-specific) atau mouse click
    local fireRemote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Fire")
    if fireRemote and fireRemote:IsA("RemoteEvent") then
        fireRemote:FireServer()
    end

    -- Fallback: simulasi mouse1click via tool activated
    local activated = tool.Activated
    if activated then
        tool.Activated:Fire()
    end

    -- Fallback universal: set mouse target ke head
    Mouse.Hit = CFrame.new(Mouse.Hit.Position)
end

local function killBot(bot)
    local char = LocalPlayer.Character
    if not char then return false end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    local botRoot = getRoot(bot)
    local botHead = getHead(bot)
    if not botRoot or not botHead then return false end

    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    -- Step 1: Teleport ke depan bot
    local botCF = botRoot.CFrame
    local teleportPos = botCF * CFrame.new(0, 0, -CONFIG.TeleportOffset.Z)
    myRoot.CFrame = teleportPos + Vector3.new(0, 0.1, 0)
    task.wait(0.05)

    -- Step 2: Aim ke kepala
    local headWorldPos = botHead.Position + CONFIG.HeadOffset
    aimAtHead(headWorldPos)
    task.wait(0.05)

    -- Step 3: Equip tool jika belum
    if not getTool() then
        equipTool()
        task.wait(0.1)
    end

    -- Step 4: Direct damage ke head (most reliable di ragdoll games)
    -- Ragdoll game biasanya pake head damage multiplier
    if botHead:FindFirstChild("ClickDetector") then
        fireTool()
    end

    -- Step 5: Fallback langsung set health (kalau game allow)
    humanoid.Health = 0

    -- Pastikan mati via head CFrame juga
    botHead.CFrame = CFrame.new(botHead.Position + Vector3.new(0, -999, 0))

    killCount += 1
    killed[bot] = true
    return true
end

-- // KILL SEQUENCE
local function killAllBots()
    local char = LocalPlayer.Character
    if not char then return end

    StatusLabel.Text = "Status: Hunting..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)

    local bots = getBots()
    local total = #bots

    if total == 0 then
        StatusLabel.Text = "Status: No bots found"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return
    end

    for i, bot in ipairs(bots) do
        if not bot.Parent then continue end

        TargetLabel.Text = string.format("Target: Bot %d/%d", i, total)

        local success = killBot(bot)
        if success then
            CounterLabel.Text = string.format("Killed: %d", killCount)
        end

        -- Bersihkan highlight bot yang udah mati
        if highlights[bot] then
            highlights[bot]:Destroy()
            highlights[bot] = nil
        end

        task.wait(CONFIG.KillDelay)
    end

    TargetLabel.Text = "Target: -"
    StatusLabel.Text = string.format("Status: Done ✓ (%d killed)", killCount)
    StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
end

-- // AUTO KILL LOOP
local autoRunning = false

local function startAutoKill()
    autoRunning = true
    task.spawn(function()
        while autoRunning do
            -- Reset killed table tiap loop (spawn baru)
            killed = {}
            killAllBots()
            task.wait(0.3)
        end
    end)
end

-- // BUTTON EVENTS
KillOnceBtn.MouseButton1Click:Connect(function()
    task.spawn(killAllBots)
end)

AutoKillBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoKill = not CONFIG.AutoKill
    if CONFIG.AutoKill then
        AutoKillBtn.Text = "🔁 Auto Kill: ON"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
        StatusLabel.Text = "Status: Auto Running"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
        startAutoKill()
    else
        autoRunning = false
        CONFIG.AutoKill = false
        AutoKillBtn.Text = "🔁 Auto Kill: OFF"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 120)
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        TargetLabel.Text = "Target: -"
    end
end)

HighlightBtn.MouseButton1Click:Connect(function()
    CONFIG.HighlightBots = not CONFIG.HighlightBots
    if CONFIG.HighlightBots then
        HighlightBtn.Text = "🔵 Highlight: ON"
        for _, bot in ipairs(getBots()) do applyHighlight(bot) end
    else
        HighlightBtn.Text = "⚫ Highlight: OFF"
        clearHighlights()
    end
end)

-- // REALTIME HIGHLIGHT SCAN
RunService.Heartbeat:Connect(function()
    if CONFIG.HighlightBots then
        for _, bot in ipairs(getBots()) do
            applyHighlight(bot)
        end
        for bot, hl in pairs(highlights) do
            if not bot.Parent or not isBot(bot) then
                hl:Destroy()
                highlights[bot] = nil
            end
        end
    end
end)

print("[HeadshotKiller v3] Loaded")
