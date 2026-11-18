-- // Hyper Realistic Ragdoll - Killer v6
-- // Language: Luau | Platform: Roblox Executor
-- // Method: Teleport depan → CFrame aim head → simulasi Fire button

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local CONFIG = {
    AutoKill   = false,
    StandDist  = 2.5,     -- stud depan bot
    WaitDeath  = 4,       -- max detik tunggu mati
    FireRate   = 0.1,     -- interval tembak
    HighlightBots = true,
}

local killCount = 0
local highlights = {}

-- ===================== UI =====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KillerUI"
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
local Stroke = Instance.new("UIStroke", MainFrame)
Stroke.Color = Color3.fromRGB(255,60,60)
Stroke.Thickness = 1.5

local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = Color3.fromRGB(180,20,20)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0,10)
local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1,0,1,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "🎯 KILLER v6"
TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
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

-- ===================== DETECT =====================
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

-- ===================== HIGHLIGHT =====================
local function hl(bot)
    if not CONFIG.HighlightBots or highlights[bot] then return end
    local s = Instance.new("SelectionBox", ScreenGui)
    s.Adornee = bot
    s.Color3 = Color3.fromRGB(255,50,50)
    s.LineThickness = 0.08
    s.SurfaceTransparency = 0.8
    highlights[bot] = s
end

local function clearHL()
    for b,s in pairs(highlights) do s:Destroy() highlights[b]=nil end
end

-- ===================== TOOL =====================
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

-- ===================== AIM =====================
-- Paksa kamera dan karakter ngarah TEPAT ke head
local function aimAtHead(headPos)
    local c = LocalPlayer.Character
    if not c then return end
    local root = c:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Putar badan karakter ke arah head (flat, ignore Y)
    local flat = Vector3.new(headPos.X - root.Position.X, 0, headPos.Z - root.Position.Z)
    if flat.Magnitude > 0 then
        root.CFrame = CFrame.new(root.Position, root.Position + flat)
    end

    -- Set kamera CFrame ngarah tepat ke head dari posisi kamera sekarang
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, headPos)
end

-- ===================== FIRE =====================
-- Pakai screen coordinate kepala → VirtualInput tap di titik itu
local function fireAtHead(headPos)
    local tool = getTool()
    if not tool then return end

    -- Konversi world pos kepala ke screen pos
    local screenPos, onScreen = Camera:WorldToScreenPoint(headPos)
    if not onScreen then return end

    local sx = math.floor(screenPos.X)
    local sy = math.floor(screenPos.Y)

    -- Set mouse hit ke kepala dulu
    pcall(function() Mouse.Hit = CFrame.new(headPos) end)

    -- Simulasi tap di screen coordinate kepala
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(sx, sy, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(sx, sy, 0, false, game, 0)
    end)

    -- Fire remote di tool dengan head position
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(function() v:FireServer(Mouse.Hit) end)
        end
    end
end

-- ===================== KILL =====================
local function killBot(bot)
    local c = LocalPlayer.Character
    if not c then return false end
    local myRoot = c:FindFirstChild("HumanoidRootPart")
    if not myRoot then return false end

    local botRoot = bot:FindFirstChild("HumanoidRootPart") or bot:FindFirstChild("Torso")
    local botHead = bot:FindFirstChild("Head")
    local hum = bot:FindFirstChildOfClass("Humanoid")
    if not botRoot or not botHead or not hum or hum.Health <= 0 then return false end

    -- Teleport tepat depan bot, sama tinggi
    local botCF = botRoot.CFrame
    -- Posisi depan = arah -Z dari bot (muka bot)
    local spawnPos = botCF.Position + botCF.LookVector * CONFIG.StandDist
    spawnPos = Vector3.new(spawnPos.X, botRoot.Position.Y, spawnPos.Z)
    myRoot.CFrame = CFrame.new(spawnPos, botRoot.Position)
    task.wait(0.1)

    -- Equip tool
    if not getTool() then equipTool() end
    if not getTool() then return false end

    -- Fire loop: aim → tembak → cek mati
    local t0 = tick()
    while hum.Health > 0 and (tick() - t0) < CONFIG.WaitDeath do
        local headPos = botHead.Position
        aimAtHead(headPos)
        task.wait(0.05)
        fireAtHead(headPos)
        task.wait(CONFIG.FireRate)
    end

    if hum.Health <= 0 then
        killCount += 1
        KillLbl.Text = "Killed: " .. killCount
        return true
    end
    return false
end

-- ===================== SEQUENCE =====================
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
        task.wait(CONFIG.KillDelay or 0.1)
    end
    TargetLbl.Text = "Target: -"
    StatusLbl.Text = string.format("Done ✓ — %d killed", killCount)
    StatusLbl.TextColor3 = Color3.fromRGB(80,255,80)
end

-- ===================== BUTTONS =====================
local autoRunning = false

BtnOnce.MouseButton1Click:Connect(function() task.spawn(killAll) end)

BtnAuto.MouseButton1Click:Connect(function()
    CONFIG.AutoKill = not CONFIG.AutoKill
    if CONFIG.AutoKill then
        BtnAuto.Text = "🔁 Auto Kill: ON"
        BtnAuto.BackgroundColor3 = Color3.fromRGB(180,30,30)
        autoRunning = true
        task.spawn(function()
            while autoRunning do killAll() task.wait(0.3) end
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
        for _, b in ipairs(getBots()) do hl(b) end
    else
        BtnHL.Text = "⚫ Highlight: OFF"
        clearHL()
    end
end)

RunService.Heartbeat:Connect(function()
    if CONFIG.HighlightBots then
        for _, b in ipairs(getBots()) do hl(b) end
        for b,s in pairs(highlights) do
            if not b.Parent or not isBot(b) then s:Destroy() highlights[b]=nil end
        end
    end
end)

print("[Killer v6] Loaded")
