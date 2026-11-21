-- Putzz Hub - Hyper Realistic Ragdoll (KO Farm)
-- Game: Hyper Realistic Ragdoll | placeId 101277003916102 | gameId 10773618503
-- Window: RightControl | Panic: End | API: getgenv().PutzzHub

----- Unload a previous copy -----

do
	local existing = getgenv().PutzzHub
	if type(existing) == "table" and type(existing.Destroy) == "function" then
		pcall(existing.Destroy)
	end
end

----- Services -----

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local UserInputService= game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService    = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

----- Splash Screen -----
-- Pop-up muncul di tengah layar, scale dari 0 → 1 (spring bounce),
-- tahan 2.2 detik, fade out, lalu Airflow window muncul.

local function createSplash()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PutzzHubSplash"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

	-- Overlay gelap
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromHex("#00000")
	overlay.BackgroundTransparency = 0
	overlay.ZIndex = 10
	overlay.Parent = screenGui

	-- Card utama
	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5, 0.5)
	card.Position = UDim2.fromScale(0.5, 0.5)
	card.Size = UDim2.fromOffset(0, 0) -- mulai dari nol
	card.BackgroundColor3 = Color3.fromHex("#03010A")
	card.BorderSizePixel = 0
	card.ZIndex = 11
	card.Parent = screenGui

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 18)
	cardCorner.Parent = card

	-- Border nebula
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromHex("#4FC3F7")
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = card

	-- Gradient background card
	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,  Color3.fromHex("#03010A")),
		ColorSequenceKeypoint.new(0.5,Color3.fromHex("#0D0530")),
		ColorSequenceKeypoint.new(1,  Color3.fromHex("#03010A")),
	})
	grad.Rotation = 135
	grad.Parent = card

	-- Logo teks
	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.Position = UDim2.fromScale(0.5, 0.38)
	title.Size = UDim2.fromScale(0.85, 0.28)
	title.BackgroundTransparency = 1
	title.Text = "✦  PUTZZ HUB  ✦"
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = Color3.fromHex("#4FC3F7")
	title.ZIndex = 12
	title.Parent = card

	-- Gradient teks
	local tgrad = Instance.new("UIGradient")
	tgrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromHex("#FFFFFF")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#4FC3F7")),
		ColorSequenceKeypoint.new(1,   Color3.fromHex("#7B61FF")),
	})
	tgrad.Rotation = 90
	tgrad.Parent = title

	-- Subtitle
	local sub = Instance.new("TextLabel")
	sub.AnchorPoint = Vector2.new(0.5, 0.5)
	sub.Position = UDim2.fromScale(0.5, 0.62)
	sub.Size = UDim2.fromScale(0.75, 0.16)
	sub.BackgroundTransparency = 1
	sub.Text = "ko farm  ·  hyper realistic ragdoll"
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromHex("#5B7FA6")
	sub.ZIndex = 12
	sub.Parent = card

	-- Loading bar background
	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5, 1)
	barBg.Position = UDim2.new(0.5, 0, 0.88, 0)
	barBg.Size = UDim2.new(0.75, 0, 0, 3)
	barBg.BackgroundColor3 = Color3.fromHex("#1A1245")
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 12
	barBg.Parent = card
	Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0, 1)
	barFill.BackgroundColor3 = Color3.fromHex("#4FC3F7")
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 13
	barFill.Parent = barBg
	Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

	-- Animasi card: scale dari 0 → target size dengan spring bounce
	local TARGET_W, TARGET_H = 420, 220

	-- Step 1: expand card
	local expandInfo = TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local expandTween = TweenService:Create(card, expandInfo, {
		Size = UDim2.fromOffset(TARGET_W, TARGET_H)
	})
	expandTween:Play()

	-- Step 2: loading bar fill selama 1.8 detik
	task.delay(0.3, function()
		local barInfo = TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(barFill, barInfo, { Size = UDim2.fromScale(1, 1) }):Play()
	end)

	-- Step 3: fade out card + overlay setelah 2.5 detik
	task.delay(2.5, function()
		local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(card, fadeInfo, {
			Size = UDim2.fromOffset(TARGET_W, 0),
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(title, fadeInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(sub,   fadeInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(stroke,fadeInfo, { Transparency = 1 }):Play()
		TweenService:Create(overlay, fadeInfo, { BackgroundTransparency = 1 }):Play()
		task.delay(0.45, function()
			screenGui:Destroy()
		end)
	end)

	-- return total durasi sebelum window boleh muncul
	return 2.95
end

local splashDuration = createSplash()
task.wait(splashDuration)

----- Library -----

local LIBRARY_URLS = {
	"https://raw.githubusercontent.com/bobloscript/Robly_Airflow/main/Source.luau",
	"https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau",
}

local Airflow = nil
local fallbackLibrary = nil
for _, url in ipairs(LIBRARY_URLS) do
	local ok, library = pcall(function()
		return loadstring(game:HttpGet(url))()
	end)
	if ok and type(library) == "table" and type(library.CreateWindow) == "function" then
		if not fallbackLibrary then
			fallbackLibrary = library
		end
		if type(library.ThemePresets) == "table" then
			Airflow = library
			break
		end
	end
end

Airflow = Airflow or fallbackLibrary

if not Airflow then
	error("[Putzz Hub] Airflow UI could not be loaded")
end

----- Theme — Galaxy Black Hole -----

local THEME = {
	Background  = Color3.fromHex("#03010A"),
	Surface     = Color3.fromHex("#070318"),
	Surface2    = Color3.fromHex("#0D0530"),
	Surface3    = Color3.fromHex("#160A45"),
	Stroke      = Color3.fromHex("#1A1245"),
	StrokeHover = Color3.fromHex("#2E2080"),
	Accent      = Color3.fromHex("#4FC3F7"),
	AccentDark  = Color3.fromHex("#001A2E"),
	Text        = Color3.fromHex("#E8F4FD"),
	Muted       = Color3.fromHex("#5B7FA6"),
}

local ThemeValue = THEME
do
	local merged = {}
	for key, value in pairs(Airflow.Theme or {}) do
		merged[key] = value
	end
	for key, value in pairs(THEME) do
		merged[key] = value
	end
	if type(Airflow.AddTheme) == "function" and type(Airflow.SetTheme) == "function" then
		local ok = pcall(function()
			Airflow:AddTheme("Galaxy", merged)
			Airflow:SetTheme("Galaxy")
		end)
		if ok then ThemeValue = "Galaxy" end
	elseif type(Airflow.ThemePresets) == "table" then
		Airflow.ThemePresets.Galaxy = merged
		pcall(function() Airflow:SetDefaultTheme("Galaxy") end)
	end
end

----- Constants -----

local PLATFORM_NAME       = "HRR_KO_Platform"
local AIM_PART            = "Head"
local FALLBACK_AIM_PART   = "UpperTorso"
local DEFAULT_HEIGHT      = 25
local DEFAULT_RANGE       = 260
local DEFAULT_DELAY       = 0.25
local DEFAULT_SEARCH_COOLDOWN = 1.6
local DEFAULT_JITTER      = 0.2
local MAX_SHOTS_PER_TARGET = 5

local KEY_OPTIONS = {
	"None","X","Z","C","V","B","N","M",
	"G","H","J","K","L","Q","E","R","F","T",
	"F1","F2","F3","F4","F5",
	"LeftShift","RightShift","Tab","CapsLock","Delete","End",
}

----- Flags -----

local flagCache = {}

local function resetFlagCache() flagCache = {} end

local function getFlag(name)
	local cached = flagCache[name]
	if cached ~= nil then return cached ~= false and cached or nil end
	local container = Airflow.Flags
	local entry = type(container) == "table" and container[name] or nil
	if type(entry) == "table" then
		flagCache[name] = entry
		return entry
	end
	flagCache[name] = false
	return nil
end

local function flag(name, fallback)
	local entry = getFlag(name)
	if not entry then return fallback end
	local ok, value = pcall(function() return entry:Get() end)
	if ok and value ~= nil then return value end
	return fallback
end

local function setFlag(name, value)
	local entry = getFlag(name)
	if not entry then return false end
	return (pcall(function() entry:Set(value) end))
end

----- State -----

local running = true
local stats = {
	downs   = 0,
	shots   = 0,
	targets = 0,
	kOs     = 0,
	cooldown = DEFAULT_SEARCH_COOLDOWN,
	mode    = "idle",
}

local downedSet    = {}
local shotCounters = {}
local savedWalkSpeed = nil
local savedJumpPower = nil
local platformTopY   = nil
local gameScreens    = {}

----- Game access -----

local function dummyFolder()
	return workspace:FindFirstChild("Dummies")
end

local function currentCharacter()
	local character = LocalPlayer.Character
	if not character or not character.Parent then return nil end
	return character
end

local function characterHead(character)
	local head = character and character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then return head end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then return root end
	return nil
end

local function humanoidOf(character)
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function knockedOut(dummy)
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	if not humanoid then return true end
	if humanoid.Health <= 0 then return true end
	local state = humanoid:GetState()
	return state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.Dead
end

local function aimPartOf(dummy)
	local part = dummy:FindFirstChild(AIM_PART)
	if part and part:IsA("BasePart") then return part end
	part = dummy:FindFirstChild(FALLBACK_AIM_PART)
	if part and part:IsA("BasePart") then return part end
	return nil
end

local function knockoutCount()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	local kOs = leaderstats and leaderstats:FindFirstChild("KOs")
	if kOs and kOs:IsA("ValueBase") then return tonumber(kOs.Value) or 0 end
	return 0
end

----- Targeting -----

local function raycastParams(character, platform)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {}
	if character then table.insert(ignore, character) end
	local camera = workspace.CurrentCamera
	if camera then table.insert(ignore, camera) end
	if platform then table.insert(ignore, platform) end
	params.FilterDescendantsInstances = ignore
	return params
end

local function hasLineOfSight(eye, targetPart, dummy, params)
	local delta = targetPart.Position - eye
	local distance = delta.Magnitude
	if distance < 0.5 then return false end
	local result = workspace:Raycast(eye, delta, params)
	if not result then return true end
	if result.Instance:IsDescendantOf(dummy) then return true end
	return result.Distance >= distance - 0.8
end

local function collectTargets(eye, maxRange, params)
	local folder = dummyFolder()
	if not folder then return {} end
	local list = {}
	for _, dummy in ipairs(folder:GetChildren()) do
		if dummy:IsA("Model") and not knockedOut(dummy) then
			local part = aimPartOf(dummy)
			if part then
				local distance = (part.Position - eye).Magnitude
				if distance > 3 and distance <= maxRange
					and hasLineOfSight(eye, part, dummy, params) then
					list[#list+1] = { dummy=dummy, part=part, distance=distance }
				end
			end
		end
	end
	table.sort(list, function(a,b) return a.distance < b.distance end)
	return list
end

local function trackDowns()
	local folder = dummyFolder()
	if not folder then return end
	for _, dummy in ipairs(folder:GetChildren()) do
		if dummy:IsA("Model") and not downedSet[dummy] and knockedOut(dummy) then
			downedSet[dummy] = true
			stats.downs = stats.downs + 1
		end
	end
	for dummy in pairs(shotCounters) do
		if not dummy.Parent then shotCounters[dummy] = nil end
	end
end

----- Platform -----

local function arenaFloorY()
	local folder = dummyFolder()
	if not folder then return nil end
	local total, count = 0, 0
	for _, dummy in ipairs(folder:GetChildren()) do
		local root = dummy:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			total = total + root.Position.Y
			count = count + 1
		end
	end
	if count == 0 then return nil end
	return total / count
end

local function arenaCenter()
	local folder = dummyFolder()
	if not folder then return nil end
	local sum = Vector3.zero
	local count = 0
	for _, dummy in ipairs(folder:GetChildren()) do
		local root = dummy:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			sum = sum + root.Position
			count = count + 1
		end
	end
	if count == 0 then return nil end
	return sum / count
end

local function buildPlatform()
	local existing = workspace:FindFirstChild(PLATFORM_NAME)
	if existing then
		platformTopY = existing.Position.Y + existing.Size.Y * 0.5
		return existing
	end
	local center = arenaCenter()
	local floorY = arenaFloorY()
	local character = currentCharacter()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if floorY == nil then floorY = root and root.Position.Y or 0 end
	if center == nil then center = root and root.Position or Vector3.zero end
	local height = flag("PlatformHeight", DEFAULT_HEIGHT)
	local part = Instance.new("Part")
	part.Name        = PLATFORM_NAME
	part.Anchored    = true
	part.CanCollide  = true
	part.CanQuery    = false
	part.CanTouch    = false
	part.Material    = Enum.Material.Neon
	part.Color       = Color3.fromHex("#0D0530")
	part.Transparency = 0.35
	part.Size        = Vector3.new(14, 1, 14)
	part.Position    = Vector3.new(center.X, floorY + height, center.Z)
	part.TopSurface  = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent      = workspace
	platformTopY     = part.Position.Y + part.Size.Y * 0.5
	return part
end

local function removePlatform()
	local existing = workspace:FindFirstChild(PLATFORM_NAME)
	if existing then existing:Destroy() end
	platformTopY = nil
end

local function standOnPlatform()
	local part = buildPlatform()
	local character = currentCharacter()
	local humanoid = humanoidOf(character)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not part or not character or not root or not humanoid then return false end
	if humanoid.Health <= 0 then return false end
	local target = Vector3.new(
		part.Position.X,
		part.Position.Y + part.Size.Y * 0.5 + 3.2,
		part.Position.Z
	)
	local flatDist = (Vector3.new(root.Position.X,0,root.Position.Z)
		- Vector3.new(target.X,0,target.Z)).Magnitude
	local vertDist = math.abs(root.Position.Y - target.Y)
	if flatDist > 6 or vertDist > 12 then
		pcall(function() character:PivotTo(CFrame.new(target)) end)
		return true
	end
	return false
end

----- Input -----

local function viewportCenter()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280,720)
	return math.floor(size.X * 0.5), math.floor(size.Y * 0.5)
end

local function interfaceBlocked()
	local x, y = viewportCenter()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then return false end
	local ok, objects = pcall(function()
		return playerGui:GetGuiObjectsAtPosition(x, y)
	end)
	if not ok or type(objects) ~= "table" then return false end
	for _, object in ipairs(objects) do
		if object:IsA("GuiButton") then return true end
		if object:IsA("GuiObject") and object.Visible then
			local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
			if screenGui and gameScreens[screenGui] then
				local background = object:IsA("Frame") and object.BackgroundTransparency or 1
				if background < 0.9 then return true end
			end
		end
	end
	return false
end

local function fireOnce()
	local x, y = viewportCenter()
	local ok = pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
	end)
	task.wait(0.03)
	pcall(function()
		VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
	end)
	if not ok then
		local environment = getgenv()
		if type(environment.mouse1click) == "function" then
			pcall(function() environment.mouse1click() end)
		end
	end
	stats.shots = stats.shots + 1
end

local function aimAt(character, position)
	local camera = workspace.CurrentCamera
	local eye = characterHead(character)
	if not camera or not eye then return false end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end
	camera.CFrame = CFrame.lookAt(eye.Position, position)
	return true
end

local function equipPistol(character, humanoid)
	local pistol = character:FindFirstChild("Pistol")
	if pistol then return true end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	pistol = backpack and backpack:FindFirstChild("Pistol")
	if not pistol then return false end
	pcall(function() humanoid:EquipTool(pistol) end)
	return true
end

local function freezeCharacter(humanoid)
	if not humanoid then return end
	if savedWalkSpeed == nil then
		savedWalkSpeed = humanoid.WalkSpeed
		savedJumpPower = humanoid.JumpPower
	end
	pcall(function()
		humanoid.WalkSpeed  = 0
		humanoid.JumpPower  = 0
		humanoid.JumpHeight = 0
	end)
end

local function releaseCharacter(humanoid)
	if not humanoid then return end
	pcall(function()
		humanoid.WalkSpeed  = savedWalkSpeed or 16
		humanoid.JumpPower  = savedJumpPower or 50
		humanoid.JumpHeight = 7.2
	end)
	savedWalkSpeed = nil
	savedJumpPower = nil
end

local function restoreCamera()
	local camera = workspace.CurrentCamera
	local character = currentCharacter()
	local humanoid = humanoidOf(character)
	if not camera then return end
	pcall(function()
		camera.CameraType = Enum.CameraType.Custom
		if humanoid then camera.CameraSubject = humanoid end
	end)
end

----- Farm cycle -----

local function keyNameToEnum(name)
	if type(name) ~= "string" or name == "" or name == "None" then return nil end
	local ok, keyCode = pcall(function() return Enum.KeyCode[name] end)
	if ok then return keyCode end
	return nil
end

local function nextSearchDelay()
	local base = tonumber(flag("SearchCooldown", DEFAULT_SEARCH_COOLDOWN)) or DEFAULT_SEARCH_COOLDOWN
	if base <= 0 then return 0 end
	if flag("CooldownJitter", true) then
		local spread = tonumber(flag("JitterAmount", DEFAULT_JITTER)) or DEFAULT_JITTER
		return math.max(0.1, base * (1 - spread + math.random() * spread * 2))
	end
	return base
end

local function farmStep()
	local character = currentCharacter()
	local humanoid  = humanoidOf(character)
	local eye       = characterHead(character)
	if not character or not humanoid or not eye then
		stats.mode = "no character"
		return
	end
	if humanoid.Health <= 0 then
		stats.mode = "respawn"
		return
	end
	if flag("KeepPlatform", true) then
		freezeCharacter(humanoid)
		standOnPlatform()
	end
	if not equipPistol(character, humanoid) then
		stats.mode = "no pistol"
		return
	end
	local platform = workspace:FindFirstChild(PLATFORM_NAME)
	local params   = raycastParams(character, platform)
	local maxRange = flag("FarmRange", DEFAULT_RANGE)
	local targets  = collectTargets(eye.Position, maxRange, params)
	stats.targets  = #targets
	stats.kOs      = knockoutCount()
	if #targets == 0 then
		local pause = nextSearchDelay()
		stats.mode  = string.format("no targets, %.1f s", pause)
		stats.cooldown = pause
		task.wait(pause)
		return
	end
	local target = targets[1]
	local dummy  = target.dummy
	if (shotCounters[dummy] or 0) >= MAX_SHOTS_PER_TARGET then
		local alternative = nil
		for index = 2, math.min(#targets, 6) do
			local candidate = targets[index]
			if (shotCounters[candidate
