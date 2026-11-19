-- // Hyper Realistic Ragdoll - Killer v8
-- // Language: Luau | Platform: Roblox Executor
-- // Fix: Teleport atas kepala + Mouse.Button1Down simulasi

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VIM = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()
local Cam = workspace.CurrentCamera

local CFG = {
    HeightAbove = 3,     -- stud diatas kepala bot
    WaitDeath   = 5,     -- max detik tunggu mati
    FireRate    = 0.15,  -- interval fire
    AutoKill    = false,
    ShowHL      = true,
}

local kills = 0
local HL = {}

-- ===== UI =====
local SG = Instance.new("ScreenGui")
SG.Name = "KillerUI"
SG.ResetOnSpawn = false
SG.Parent = game:GetService("CoreGui")

local F = Instance.new("Frame", SG)
F.Size = UDim2.new(0,210,0,280)
F.Position = UDim2.new(0,20,0.3,0)
F.BackgroundColor3 = Color3.fromRGB(15,15,20)
F.BorderSizePixel = 0
F.Active = true
F.Draggable = true
Instance.new("UICorner",F).CornerRadius = UDim.new(0,10)
local St = Instance.new("UIStroke",F)
St.Color = Color3.fromRGB(255,60,60)
St.Thickness = 1.5

local TB = Instance.new("Frame",F)
TB.Size = UDim2.new(1,0,0,36)
TB.BackgroundColor3 = Color3.fromRGB(180,20,20)
TB.BorderSizePixel = 0
Instance.new("UICorner",TB).CornerRadius = UDim.new(0,10)
local TL = Instance.new("TextLabel",TB)
TL.Size = UDim2.new(1,0,1,0)
TL.BackgroundTransparency = 1
TL.Text = "🎯 KILLER v8"
TL.TextColor3 = Color3.fromRGB(255,255,255)
TL.TextScaled = true
TL.Font = Enum.Font.GothamBold

local KL = Instance.new("TextLabel",F)
KL.Size = UDim2.new(1,-20,0,28)
KL.Position = UDim2.new(0,10,0,44)
KL.BackgroundTransparency = 1
KL.Text = "Killed: 0"
KL.TextColor3 = Color3.fromRGB(255,80,80)
KL.TextScaled = true
KL.Font = Enum.Font.GothamBold

local SL = Instance.new("TextLabel",F)
SL.Size = UDim2.new(1,-20,0,22)
SL.Position = UDim2.new(0,10,0,76)
SL.BackgroundTransparency = 1
SL.Text = "Status: Idle"
SL.TextColor3 = Color3.fromRGB(150,150,150)
SL.TextScaled = true
SL.Font = Enum.Font.Gotham

local TgL = Instance.new("TextLabel",F)
TgL.Size = UDim2.new(1,-20,0,22)
TgL.Position = UDim2.new(0,10,0,100)
TgL.BackgroundTransparency = 1
TgL.Text = "Target: -"
TgL.TextColor3 = Color3.fromRGB(255,200,0)
TgL.TextScaled = true
TgL.Font = Enum.Font.Gotham

local function Btn(txt,y,c)
    local b = Instance.new("TextButton",F)
    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = c
    b.BorderSizePixel = 0
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    return b
end

local BOnce = Btn("☠ Kill All (Once)", 128, Color3.fromRGB(180,30,30))
local BAuto = Btn("🔁 Auto Kill: OFF",  174, Color3.fromRGB(40,40,120))
local BHL   = Btn("🔵 Highlight: ON",   220, Color3.fromRGB(0,80,160))

-- ===== DETECT =====
local function isBot(m)
    if not m:IsA("Model") then return false end
    local h = m:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end
    if not (m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Torso")) then return false end
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Character == m then return false end
    end
    return true
end

local function getBots()
    local t = {}
    for _,o in ipairs(workspace:GetDescendants()) do
        if isBot(o) then table.insert(t,o) end
    end
    return t
end

-- ===== HIGHLIGHT =====
local function addHL(bot)
    if not CFG.ShowHL or HL[bot] then return end
    local s = Instance.new("SelectionBox",SG)
    s.Adornee = bot
    s.Color3 = Color3.fromRGB(255,50,50)
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
-- Konversi head ke screen → simulasi Mouse1Down di titik itu
local function fireAtScreenPos(worldPos)
    local screenPos, onScreen = Cam:WorldToScreenPoint(worldPos)
    if not onScreen then return false end

    local sx = math.floor(screenPos.X)
    local sy = math.floor(screenPos.Y)

    -- Set Mouse.Hit ke target dulu
    pcall(function() Mouse.Hit = CFrame.new(worldPos) end)

    -- Simulasi mouse down + up di screen coordinate head
    pcall(function()
        VIM:SendMouseButtonEvent(sx, sy, 0, true, game, 0)
    end)
    task.wait(0.05)
    pcall(function()
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

    -- Teleport TEPAT di atas kepala bot
    local aboveHead = botHead.Position + Vector3.new(0, CFG.HeightAbove, 0)
    myRoot.CFrame = CFrame.new(aboveHead, botHead.Position)
    task.wait(0.1)

    -- Equip tool
    if not getTool() then equipTool() end
    if not getTool() then return false end

    -- Kamera ngarah tepat ke kepala dari atas
    Cam.CFrame = CFrame.lookAt(aboveHead + Vector3.new(0,1,0), botHead.Position)
    task.wait(0.05)

    -- Fire loop — tembak ke head sampai mati
    local t0 = tick()
    while hum.Health > 0 and (tick() - t0) < CFG.WaitDeath do
        -- Update posisi atas kepala (bot bisa gerak)
        local headNow = botHead.Position
        local above = headNow + Vector3.new(0, CFG.HeightAbove, 0)

        -- Paksa karakter + kamera tetap ngarah ke head
        myRoot.CFrame = CFrame.new(above, headNow)
        Cam.CFrame = CFrame.lookAt(above + Vector3.new(0,1,0), headNow)

        -- Fire di screen pos kepala
        fireAtScreenPos(headNow)

        task.wait(CFG.FireRate)
    end

    if hum.Health <= 0 then
        kills += 1
        KL.Text = "Killed: " .. kills
        return true
    end
    return false
end

-- ===== SEQUENCE =====
local function killAll()
    SL.Text = "Status: Hunting..."
    SL.TextColor3 = Color3.fromRGB(255,80,80)
    local bots = getBots()
    if #bots == 0 then
        SL.Text = "Status: No bots"
        SL.TextColor3 = Color3.fromRGB(150,150,150)
        return
    end
    for i,bot in ipairs(bots) do
        if not bot.Parent or not isBot(bot) then continue end
        TgL.Text = string.format("Target: %d / %d", i, #bots)
        killBot(bot)
        if HL[bot] then HL[bot]:Destroy() HL[bot]=nil end
        task.wait(0.05)
    end
    TgL.Text = "Target: -"
    SL.Text = string.format("Done ✓ — %d killed", kills)
    SL.TextColor3 = Color3.fromRGB(80,255,80)
end

-- ===== BUTTONS =====
local autoOn = false

BOnce.MouseButton1Click:Connect(function() task.spawn(killAll) end)

BAuto.MouseButton1Click:Connect(function()
    CFG.AutoKill = not CFG.AutoKill
    if CFG.AutoKill then
        BAuto.Text = "🔁 Auto Kill: ON"
        BAuto.BackgroundColor3 = Color3.fromRGB(180,30,30)
        autoOn = true
        task.spawn(function()
            while autoOn do killAll() task.wait(0.2) end
        end)
    else
        autoOn = false
        BAuto.Text = "🔁 Auto Kill: OFF"
        BAuto.BackgroundColor3 = Color3.fromRGB(40,40,120)
        SL.Text = "Status: Stopped"
        SL.TextColor3 = Color3.fromRGB(150,150,150)
        TgL.Text = "Target: -"
    end
end)

BHL.MouseButton1Click:Connect(function()
    CFG.ShowHL = not CFG.ShowHL
    if CFG.ShowHL then
        BHL.Text = "🔵 Highlight: ON"
        for _,b in ipairs(getBots()) do addHL(b) end
    else
        BHL.Text = "⚫ Highlight: OFF"
        clearHL()
    end
end)

RunService.Heartbeat:Connect(function()
    if CFG.ShowHL then
        for _,b in ipairs(getBots()) do addHL(b) end
        for b,s in pairs(HL) do
            if not b.Parent or not isBot(b) then s:Destroy() HL[b]=nil end
        end
    end
end)

print("[Killer v8] Loaded")
