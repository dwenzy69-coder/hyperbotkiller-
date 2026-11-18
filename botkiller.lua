-- // Hyper Realistic Ragdoll - Headshot Killer v4
-- // Language: Luau | Platform: Roblox Executor
-- // Method: Remote fire via equipped tool → server-side damage

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local CONFIG = {
    AutoKill = false,
    TeleportOffset = 3,  -- stud depan bot
    KillDelay = 0.2,
    HighlightBots = true,
}

local killCount = 0
local highlights = {}

-- // UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HeadshotKillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Color = Color3.fromRGB(255, 60, 60)
UIStroke.Thickness = 1.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)
local TitleLabel = Instance.new("TextLabel", TitleBar)
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🎯 HEADSHOT KILLER v4"
TitleLabel.TextColor3 = Color3.fromRGB(255,255,255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold

local CounterLabel = Instance.new("TextLabel", MainFrame)
CounterLabel.Size = UDim2.new(1,-20,0,28)
CounterLabel.Position = UDim2.new(0,10,0,44)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "Killed: 0"
CounterLabel.TextColor3 = Color3.fromRGB(255,80,80)
CounterLabel.TextScaled = true
CounterLabel.Font = Enum.Font.GothamBold

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1,-20,0,22)
StatusLabel.Position = UDim2.new(0,10,0,76)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150,150,150)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham

local TargetLabel = Instance.new("TextLabel", MainFrame)
TargetLabel.Size = UDim2.new(1,-20,0,22)
TargetLabel.Position = UDim2.new(0,10,0,100)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: -"
TargetLabel.TextColor3 = Color3.fromRGB(255,200,0)
TargetLabel.TextScaled = true
TargetLabel.Font = Enum.Font.Gotham

local function CreateButton(text, posY, color)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(1,-20,0,38)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    return btn
end

local KillOnceBtn = CreateButton("☠ Kill All (Once)", 130, Color3.fromRGB(180,30,30))
local AutoKillBtn = CreateButton("🔁 Auto Kill: OFF", 178, Color3.fromRGB(40,40,120))
local HighlightBtn = CreateButton("🔵 Highlight: ON", 226, Color3.fromRGB(0,80,160))

-- // BOT DETECTION
local function isBot(model)
    if not model:IsA("Model") then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if not (model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")) then return false end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == model then return false end
    end
    return true
end

local function getBots()
    local bots = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if isBot(obj) then table.insert(bots, obj) end
    end
    return bots
end

-- // HIGHLIGHT
local function applyHighlight(bot)
    if not CONFIG.HighlightBots or highlights[bot] then return end
    local hl = Instance.new("SelectionBox", ScreenGui)
    hl.Adornee = bot
    hl.Color3 = Color3.fromRGB(255,50,50)
    hl.LineThickness = 0.08
    hl.SurfaceTransparency = 0.8
    hl.SurfaceColor3 = Color3.fromRGB(255,80,80)
    highlights[bot] = hl
end

local function clearHighlights()
    for bot, hl in pairs(highlights) do hl:Destroy() highlights[bot] = nil end
end

-- // TOOL UTILS
local function getEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Tool")
end

local function equipFirstTool()
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not char or not bp then return end
    local tool = bp:FindFirstChildOfClass("Tool")
    if tool then
        tool.Parent = char
        task.wait(0.1)
    end
end

-- // SCAN REMOTES DI TOOL
local function getFireRemote(tool)
    -- Cari semua RemoteEvent di dalam tool
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            -- Prioritas: nama yang mengandung kata fire/shoot/damage/attack
            local name = v.Name:lower()
            if name:find("fire") or name:find("shoot") or name:find("damage") 
               or name:find("attack") or name:find("hit") then
                return v
            end
        end
    end
    -- Fallback: remote pertama yang ada
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then return v end
    end
    return nil
end

-- // CORE KILL: teleport → aim → fire remote dengan target head
local function killBot(bot)
    local char = LocalPlayer.Character
    if not char then return false end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
    local botHead = bot:FindFirstChild("Head")
    local hum = bot:FindFirstChildOfClass("Humanoid")
    if not botRoot or not botHead or not hum or hum.Health <= 0 then return false end

    -- Step 1: Teleport ke depan bot
    local botCF = botRoot.CFrame
    local spawnCF = botCF * CFrame.new(0, 0, -CONFIG.TeleportOffset)
    myRoot.CFrame = spawnCF
    task.wait(0.05)

    -- Step 2: Aim kamera ke kepala
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, botHead.Position)
    task.wait(0.05)

    -- Step 3: Equip tool
    if not getEquippedTool() then
        equipFirstTool()
    end

    local tool = getEquippedTool()
    if not tool then return false end

    -- Step 4: Fire remote dengan head position sebagai target
    local remote = getFireRemote(tool)
    if remote then
        -- Coba berbagai signature yang umum di ragdoll games
        -- Signature 1: FireServer(targetPosition)
        pcall(function() remote:FireServer(botHead.Position) end)
        task.wait(0.05)
        -- Signature 2: FireServer(targetInstance)
        pcall(function() remote:FireServer(botHead) end)
        task.wait(0.05)
        -- Signature 3: FireServer(CFrame)
        pcall(function() remote:FireServer(CFrame.new(botHead.Position)) end)
        task.wait(0.05)
        -- Signature 4: FireServer(target, position)
        pcall(function() remote:FireServer(bot, botHead.Position) end)
        task.wait(0.05)
        -- Signature 5: FireServer(humanoid, position)
        pcall(function() remote:FireServer(hum, botHead.Position) end)
    end

    -- Step 5: Simulasi mouse click via tool activated
    pcall(function()
        Mouse.Hit = CFrame.new(botHead.Position)
        Mouse.Target = botHead
    end)

    -- Step 6: Fire tool.Activated langsung
    pcall(function() tool.Activated:Fire() end)

    -- Step 7: Cek apakah mati setelah fire
    task.wait(0.1)
    if hum.Health <= 0 then
        killCount += 1
        CounterLabel.Text = string.format("Killed: %d", killCount)
        return true
    end

    return false
end

-- // KILL SEQUENCE
local function killAllBots()
    StatusLabel.Text = "Status: Hunting..."
    StatusLabel.TextColor3 = Color3.fromRGB(255,80,80)

    local bots = getBots()
    if #bots == 0 then
        StatusLabel.Text = "Status: No bots"
        StatusLabel.TextColor3 = Color3.fromRGB(150,150,150)
        return
    end

    for i, bot in ipairs(bots) do
        if not bot.Parent then continue end
        TargetLabel.Text = string.format("Target: %d / %d", i, #bots)
        killBot(bot)
        if highlights[bot] then
            highlights[bot]:Destroy()
            highlights[bot] = nil
        end
        task.wait(CONFIG.KillDelay)
    end

    TargetLabel.Text = "Target: -"
    StatusLabel.Text = string.format("Done ✓ — %d killed", killCount)
    StatusLabel.TextColor3 = Color3.fromRGB(80,255,80)
end

-- // AUTO KILL
local autoRunning = false

KillOnceBtn.MouseButton1Click:Connect(function()
    task.spawn(killAllBots)
end)

AutoKillBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoKill = not CONFIG.AutoKill
    if CONFIG.AutoKill then
        AutoKillBtn.Text = "🔁 Auto Kill: ON"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(180,30,30)
        autoRunning = true
        task.spawn(function()
            while autoRunning do
                killAllBots()
                task.wait(0.3)
            end
        end)
    else
        autoRunning = false
        CONFIG.AutoKill = false
        AutoKillBtn.Text = "🔁 Auto Kill: OFF"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(40,40,120)
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(150,150,150)
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

-- // REALTIME HIGHLIGHT
RunService.Heartbeat:Connect(function()
    if CONFIG.HighlightBots then
        for _, bot in ipairs(getBots()) do applyHighlight(bot) end
        for bot, hl in pairs(highlights) do
            if not bot.Parent or not isBot(bot) then
                hl:Destroy()
                highlights[bot] = nil
            end
        end
    end
end)

print("[HeadshotKiller v4] Loaded — Remote scanner active")
