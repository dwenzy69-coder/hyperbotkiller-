-- // Hyper Realistic Ragdoll - Aimbot Killer v5
-- // Language: Luau | Platform: Roblox Executor
-- // Method: CFrame aimlock kepala + simulasi Fire button + tunggu mati

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local CONFIG = {
    AutoKill = false,
    TeleportOffset = 3,
    KillDelay = 0.1,
    WaitForDeath = 3,    -- max detik tunggu bot mati
    FireRate = 0.08,     -- interval tembak
    HighlightBots = true,
}

local killCount = 0
local highlights = {}
local aimbotTarget = nil
local aimbotActive = false

-- // UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotKillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 220, 0, 310)
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
TitleLabel.Text = "🎯 AIMBOT KILLER v5"
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
    if tool then tool.Parent = char task.wait(0.1) end
end

-- // AIMLOCK: paksa kamera lock ke kepala target
local function aimLockHead(headPos)
    local char = LocalPlayer.Character
    if not char then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    -- Rotate karakter ke arah target
    local lookDir = (headPos - myRoot.Position).Unit
    local flatDir = Vector3.new(lookDir.X, 0, lookDir.Z)
    myRoot.CFrame = CFrame.new(myRoot.Position, myRoot.Position + flatDir)
    -- Lock kamera tepat ke kepala
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
end

-- // FIRE: simulasi tap tombol Fire di game
local function fireWeapon(headPos)
    local tool = getEquippedTool()
    if not tool then return end

    -- Method 1: Set mouse hit ke head lalu fire remote
    pcall(function()
        Mouse.Hit = CFrame.new(headPos)
        Mouse.Target = workspace:FindPartOnRay(Ray.new(Camera.CFrame.Position, (headPos - Camera.CFrame.Position).Unit * 1000))
    end)

    -- Method 2: Scan dan fire semua remote dengan head position
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(headPos) end)
            pcall(function() v:FireServer(CFrame.new(headPos)) end)
            pcall(function() v:FireServer(Mouse.Hit) end)
        end
    end

    -- Method 3: Fire tool activated dengan mouse pointing ke head
    pcall(function() tool.Activated:Fire() end)

    -- Method 4: VirtualInputManager simulasi klik
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(
            Camera:WorldToScreenPoint(headPos).X,
            Camera:WorldToScreenPoint(headPos).Y,
            0, true, game, 0
        )
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(
            Camera:WorldToScreenPoint(headPos).X,
            Camera:WorldToScreenPoint(headPos).Y,
            0, false, game, 0
        )
    end)
end

-- // CORE KILL: teleport → aimlock kepala → tembak → tunggu mati → next
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
    myRoot.CFrame = botCF * CFrame.new(0, 0, -CONFIG.TeleportOffset)
    task.wait(0.08)

    -- Step 2: Equip tool
    if not getEquippedTool() then
        equipFirstTool()
        task.wait(0.1)
    end
    if not getEquippedTool() then return false end

    -- Step 3: Aimlock + fire loop — tembak terus sampai mati atau timeout
    local startTime = tick()
    local fired = false

    while hum.Health > 0 and (tick() - startTime) < CONFIG.WaitForDeath do
        -- Refresh head position tiap iterasi (bot bisa gerak)
        local headPos = botHead.Position + Vector3.new(0, 0.1, 0)

        -- Aimlock
        aimLockHead(headPos)
        task.wait(0.03)

        -- Fire
        fireWeapon(headPos)
        fired = true

        task.wait(CONFIG.FireRate)
    end

    -- Cek hasil
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
        if not bot.Parent or not isBot(bot) then continue end
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

print("[AimbotKiller v5] Loaded")
