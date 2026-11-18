-- // Hyper Realistic Ragdoll - Bot Killer Script
-- // Language: Luau | Platform: Roblox Executor
-- // Target: NPC/Bot entities in-game

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- // CONFIG
local CONFIG = {
    AutoKill = false,
    KillDelay = 0.1,
    Range = 500,
    HighlightBots = true,
}

-- // UI SETUP
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BotKillerUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0, 20, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(0, 180, 255)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ BOT KILLER"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = TitleBar

-- Kill Counter Label
local CounterLabel = Instance.new("TextLabel")
CounterLabel.Size = UDim2.new(1, -20, 0, 30)
CounterLabel.Position = UDim2.new(0, 10, 0, 44)
CounterLabel.BackgroundTransparency = 1
CounterLabel.Text = "Killed: 0 | Found: 0"
CounterLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
CounterLabel.TextScaled = true
CounterLabel.Font = Enum.Font.GothamSemibold
CounterLabel.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 24)
StatusLabel.Position = UDim2.new(0, 10, 0, 78)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- // Helper: Create Button
local function CreateButton(text, posY, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, posY)
    btn.BackgroundColor3 = color or Color3.fromRGB(0, 100, 180)
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    -- Hover effect
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(color.R * 255 + 40, 255),
                math.min(color.G * 255 + 40, 255),
                math.min(color.B * 255 + 40, 255)
            )
        }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = color
        }):Play()
    end)

    return btn
end

local KillOnceBtn  = CreateButton("☠ Kill All Bots (Once)", 110, Color3.fromRGB(180, 30, 30))
local AutoKillBtn  = CreateButton("🔁 Auto Kill: OFF", 158, Color3.fromRGB(30, 100, 30))
local HighlightBtn = CreateButton("🔵 Highlight: ON", 206, Color3.fromRGB(0, 80, 160))

-- // BOT DETECTION
-- Bots = karakter di workspace yang bukan player
local function isBot(model)
    if not model:IsA("Model") then return false end
    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    if not rootPart then return false end

    -- Pastikan bukan player
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
local highlights = {}
local function applyHighlight(bot)
    if not CONFIG.HighlightBots then return end
    if highlights[bot] then return end
    local hl = Instance.new("SelectionBox")
    hl.Adornee = bot
    hl.Color3 = Color3.fromRGB(255, 50, 50)
    hl.LineThickness = 0.08
    hl.SurfaceTransparency = 0.7
    hl.SurfaceColor3 = Color3.fromRGB(255, 80, 80)
    hl.Parent = ScreenGui
    highlights[bot] = hl
end

local function clearHighlights()
    for bot, hl in pairs(highlights) do
        hl:Destroy()
        highlights[bot] = nil
    end
end

-- // KILL LOGIC
local killCount = 0

local function killBot(bot)
    local humanoid = bot:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
        killCount += 1
    end

    -- Fallback: coba via HumanoidRootPart (some games protect Health)
    local root = bot:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(0, -9999, 0)
    end
end

local function killAllBots()
    local bots = getBots()
    StatusLabel.Text = "Status: Killing..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)

    local found = #bots
    for _, bot in ipairs(bots) do
        killBot(bot)
        task.wait(CONFIG.KillDelay)
    end

    CounterLabel.Text = string.format("Killed: %d | Found: %d", killCount, found)
    StatusLabel.Text = "Status: Done ✓"
    StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
    clearHighlights()
end

-- // BUTTON LOGIC
KillOnceBtn.MouseButton1Click:Connect(function()
    task.spawn(killAllBots)
end)

local autoLoop = nil
AutoKillBtn.MouseButton1Click:Connect(function()
    CONFIG.AutoKill = not CONFIG.AutoKill
    if CONFIG.AutoKill then
        AutoKillBtn.Text = "🔁 Auto Kill: ON"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(30, 180, 30)
        StatusLabel.Text = "Status: Auto Running"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 0)

        autoLoop = task.spawn(function()
            while CONFIG.AutoKill do
                local bots = getBots()
                local found = #bots
                for _, bot in ipairs(bots) do
                    if not CONFIG.AutoKill then break end
                    killBot(bot)
                    task.wait(CONFIG.KillDelay)
                end
                CounterLabel.Text = string.format("Killed: %d | Found: %d", killCount, found)
                task.wait(0.5)
            end
        end)
    else
        CONFIG.AutoKill = false
        AutoKillBtn.Text = "🔁 Auto Kill: OFF"
        AutoKillBtn.BackgroundColor3 = Color3.fromRGB(30, 100, 30)
        StatusLabel.Text = "Status: Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

HighlightBtn.MouseButton1Click:Connect(function()
    CONFIG.HighlightBots = not CONFIG.HighlightBots
    if CONFIG.HighlightBots then
        HighlightBtn.Text = "🔵 Highlight: ON"
        -- Apply to current bots
        for _, bot in ipairs(getBots()) do
            applyHighlight(bot)
        end
    else
        HighlightBtn.Text = "⚫ Highlight: OFF"
        clearHighlights()
    end
end)

-- // REALTIME BOT SCAN (highlight + counter update)
RunService.Heartbeat:Connect(function()
    if CONFIG.HighlightBots then
        local bots = getBots()
        for _, bot in ipairs(bots) do
            applyHighlight(bot)
        end
        -- Cleanup dead highlights
        for bot, hl in pairs(highlights) do
            if not bot.Parent then
                hl:Destroy()
                highlights[bot] = nil
            end
        end
    end
end)

print("[BotKiller] Script loaded - UI injected via CoreGui")
