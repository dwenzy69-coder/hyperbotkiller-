-- Putzz Hub - Hyper Realistic Ragdoll (KO Farm)
-- Game: Hyper Realistic Ragdoll | placeId 101277003916102 | gameId 10773618503
-- Window: RightControl | Panic: End | API: getgenv().PutzzHub

do
	local existing = getgenv().PutzzHub
	if type(existing) == "table" and type(existing.Destroy) == "function" then
		pcall(existing.Destroy)
	end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

do
	local sg = Instance.new("ScreenGui")
	sg.Name = "PutzzSplash"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

	local ov = Instance.new("Frame")
	ov.Size = UDim2.fromScale(1,1)
	ov.BackgroundColor3 = Color3.fromHex("#000000")
	ov.BackgroundTransparency = 0
	ov.ZIndex = 10
	ov.Parent = sg

	local card = Instance.new("Frame")
	card.AnchorPoint = Vector2.new(0.5,0.5)
	card.Position = UDim2.fromScale(0.5,0.5)
	card.Size = UDim2.fromOffset(0,0)
	card.BackgroundColor3 = Color3.fromHex("#03010A")
	card.BorderSizePixel = 0
	card.ZIndex = 11
	card.Parent = sg
	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0,18)
	cc.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromHex("#4FC3F7")
	stroke.Thickness = 1.5
	stroke.Transparency = 0.3
	stroke.Parent = card

	local grad = Instance.new("UIGradient")
	grad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#03010A")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#0D0530")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#03010A")),
	})
	grad.Rotation = 135
	grad.Parent = card

	local title = Instance.new("TextLabel")
	title.AnchorPoint = Vector2.new(0.5,0.5)
	title.Position = UDim2.fromScale(0.5,0.38)
	title.Size = UDim2.fromScale(0.85,0.28)
	title.BackgroundTransparency = 1
	title.Text = "✦  PUTZZ HUB  ✦"
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.TextColor3 = Color3.fromHex("#4FC3F7")
	title.ZIndex = 12
	title.Parent = card

	local tg = Instance.new("UIGradient")
	tg.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromHex("#FFFFFF")),
		ColorSequenceKeypoint.new(0.5, Color3.fromHex("#4FC3F7")),
		ColorSequenceKeypoint.new(1, Color3.fromHex("#7B61FF")),
	})
	tg.Rotation = 90
	tg.Parent = title

	local sub = Instance.new("TextLabel")
	sub.AnchorPoint = Vector2.new(0.5,0.5)
	sub.Position = UDim2.fromScale(0.5,0.62)
	sub.Size = UDim2.fromScale(0.75,0.16)
	sub.BackgroundTransparency = 1
	sub.Text = "ko farm  ·  hyper realistic ragdoll"
	sub.Font = Enum.Font.Gotham
	sub.TextScaled = true
	sub.TextColor3 = Color3.fromHex("#5B7FA6")
	sub.ZIndex = 12
	sub.Parent = card

	local barBg = Instance.new("Frame")
	barBg.AnchorPoint = Vector2.new(0.5,1)
	barBg.Position = UDim2.new(0.5,0,0.88,0)
	barBg.Size = UDim2.new(0.75,0,0,3)
	barBg.BackgroundColor3 = Color3.fromHex("#1A1245")
	barBg.BorderSizePixel = 0
	barBg.ZIndex = 12
	barBg.Parent = card
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1,0)
	bc.Parent = barBg

	local barFill = Instance.new("Frame")
	barFill.Size = UDim2.fromScale(0,1)
	barFill.BackgroundColor3 = Color3.fromHex("#4FC3F7")
	barFill.BorderSizePixel = 0
	barFill.ZIndex = 13
	barFill.Parent = barBg
	local bfc = Instance.new("UICorner")
	bfc.CornerRadius = UDim.new(1,0)
	bfc.Parent = barFill

	TweenService:Create(card, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(420,220)}):Play()
	task.delay(0.3, function()
		TweenService:Create(barFill, TweenInfo.new(1.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(1,1)}):Play()
	end)
	task.delay(2.5, function()
		local fi = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(card, fi, {Size = UDim2.fromOffset(420,0), BackgroundTransparency = 1}):Play()
		TweenService:Create(title, fi, {TextTransparency = 1}):Play()
		TweenService:Create(sub, fi, {TextTransparency = 1}):Play()
		TweenService:Create(stroke, fi, {Transparency = 1}):Play()
		TweenService:Create(ov, fi, {BackgroundTransparency = 1}):Play()
		task.delay(0.45, function()
			sg:Destroy()
		end)
	end)
end

task.wait(2.95)

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

local THEME = {
	Background = Color3.fromHex("#03010A"),
	Surface = Color3.fromHex("#070318"),
	Surface2 = Color3.fromHex("#0D0530"),
	Surface3 = Color3.fromHex("#160A45"),
	Stroke = Color3.fromHex("#1A1245"),
	StrokeHover = Color3.fromHex("#2E2080"),
	Accent = Color3.fromHex("#4FC3F7"),
	AccentDark = Color3.fromHex("#001A2E"),
	Text = Color3.fromHex("#E8F4FD"),
	Muted = Color3.fromHex("#5B7FA6"),
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
		if ok then
			ThemeValue = "Galaxy"
		end
	elseif type(Airflow.ThemePresets) == "table" then
		Airflow.ThemePresets.Galaxy = merged
		pcall(function()
			Airflow:SetDefaultTheme("Galaxy")
		end)
	end
end

local PLATFORM_NAME = "HRR_KO_Platform"
local AIM_PART = "Head"
local FALLBACK_AIM_PART = "UpperTorso"
local DEFAULT_HEIGHT = 25
local DEFAULT_RANGE = 260
local DEFAULT_DELAY = 0.25
local DEFAULT_SEARCH_COOLDOWN = 1.6
local DEFAULT_JITTER = 0.2
local MAX_SHOTS_PER_TARGET = 5

local KEY_OPTIONS = {
	"None", "X", "Z", "C", "V", "B", "N", "M",
	"G", "H", "J", "K", "L", "Q", "E", "R", "F", "T",
	"F1", "F2", "F3", "F4", "F5",
	"LeftShift", "RightShift", "Tab", "CapsLock", "Delete", "End",
}

local flagCache = {}
local function resetFlagCache()
	flagCache = {}
end
local function getFlag(name)
	local cached = flagCache[name]
	if cached ~= nil then
		return cached ~= false and cached or nil
	end
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
	if not entry then
		return fallback
	end
	local ok, value = pcall(function()
		return entry:Get()
	end)
	if ok and value ~= nil then
		return value
	end
	return fallback
end
local function setFlag(name, value)
	local entry = getFlag(name)
	if not entry then
		return false
	end
	return (pcall(function()
		entry:Set(value)
	end))
end

local running = true
local stats = {
	downs = 0,
	shots = 0,
	targets = 0,
	kOs = 0,
	cooldown = DEFAULT_SEARCH_COOLDOWN,
	mode = "idle",
}
local downedSet = {}
local shotCounters = {}
local savedWalkSpeed = nil
local savedJumpPower = nil
local platformTopY = nil
local gameScreens = {}

local function dummyFolder()
	return workspace:FindFirstChild("Dummies")
end
local function currentCharacter()
	local character = LocalPlayer.Character
	if not character or not character.Parent then
		return nil
	end
	return character
end
local function characterHead(character)
	local head = character and character:FindFirstChild("Head")
	if head and head:IsA("BasePart") then
		return head
	end
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end
local function humanoidOf(character)
	return character and character:FindFirstChildOfClass("Humanoid")
end
local function knockedOut(dummy)
	local humanoid = dummy:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return true
	end
	if humanoid.Health <= 0 then
		return true
	end
	local state = humanoid:GetState()
	return state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.Dead
end
local function aimPartOf(dummy)
	local part = dummy:FindFirstChild(AIM_PART)
	if part and part:IsA("BasePart") then
		return part
	end
	part = dummy:FindFirstChild(FALLBACK_AIM_PART)
	if part and part:IsA("BasePart") then
		return part
	end
	return nil
end
local function knockoutCount()
	local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
	local kOs = leaderstats and leaderstats:FindFirstChild("KOs")
	if kOs and kOs:IsA("ValueBase") then
		return tonumber(kOs.Value) or 0
	end
	return 0
endlocal function raycastParams(character, platform)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local ignore = {}
	if character then
		table.insert(ignore, character)
	end
	local camera = workspace.CurrentCamera
	if camera then
		table.insert(ignore, camera)
	end
	if platform then
		table.insert(ignore, platform)
	end
	params.FilterDescendantsInstances = ignore
	return params
end
local function hasLineOfSight(eye, targetPart, dummy, params)
	local delta = targetPart.Position - eye
	local distance = delta.Magnitude
	if distance < 0.5 then
		return false
	end
	local result = workspace:Raycast(eye, delta, params)
	if not result then
		return true
	end
	if result.Instance:IsDescendantOf(dummy) then
		return true
	end
	return result.Distance >= distance - 0.8
end
local function collectTargets(eye, maxRange, params)
	local folder = dummyFolder()
	if not folder then
		return {}
	end
	local list = {}
	for _, dummy in ipairs(folder:GetChildren()) do
		if dummy:IsA("Model") and not knockedOut(dummy) then
			local part = aimPartOf(dummy)
			if part then
				local distance = (part.Position - eye).Magnitude
				if distance > 3 and distance <= maxRange and hasLineOfSight(eye, part, dummy, params) then
					list[#list + 1] = { dummy = dummy, part = part, distance = distance }
				end
			end
		end
	end
	table.sort(list, function(a, b)
		return a.distance < b.distance
	end)
	return list
end
local function trackDowns()
	local folder = dummyFolder()
	if not folder then
		return
	end
	for _, dummy in ipairs(folder:GetChildren()) do
		if dummy:IsA("Model") and not downedSet[dummy] and knockedOut(dummy) then
			downedSet[dummy] = true
			stats.downs = stats.downs + 1
		end
	end
	for dummy in pairs(shotCounters) do
		if not dummy.Parent then
			shotCounters[dummy] = nil
		end
	end
end

local function arenaFloorY()
	local folder = dummyFolder()
	if not folder then
		return nil
	end
	local total, count = 0, 0
	for _, dummy in ipairs(folder:GetChildren()) do
		local root = dummy:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			total = total + root.Position.Y
			count = count + 1
		end
	end
	if count == 0 then
		return nil
	end
	return total / count
end
local function arenaCenter()
	local folder = dummyFolder()
	if not folder then
		return nil
	end
	local sum = Vector3.zero
	local count = 0
	for _, dummy in ipairs(folder:GetChildren()) do
		local root = dummy:FindFirstChild("HumanoidRootPart")
		if root and root:IsA("BasePart") then
			sum = sum + root.Position
			count = count + 1
		end
	end
	if count == 0 then
		return nil
	end
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
	if floorY == nil then
		floorY = root and root.Position.Y or 0
	end
	if center == nil then
		center = root and root.Position or Vector3.zero
	end
	local height = flag("PlatformHeight", DEFAULT_HEIGHT)
	local part = Instance.new("Part")
	part.Name = PLATFORM_NAME
	part.Anchored = true
	part.CanCollide = true
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Metal
	part.Color = Color3.fromRGB(38, 38, 46)
	part.Transparency = 0.45
	part.Size = Vector3.new(14, 1, 14)
	part.Position = Vector3.new(center.X, floorY + height, center.Z)
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = workspace
	platformTopY = part.Position.Y + part.Size.Y * 0.5
	return part
end
local function removePlatform()
	local existing = workspace:FindFirstChild(PLATFORM_NAME)
	if existing then
		existing:Destroy()
	end
	platformTopY = nil
end
local function standOnPlatform()
	local part = buildPlatform()
	local character = currentCharacter()
	local humanoid = humanoidOf(character)
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not part or not character or not root or not humanoid then
		return false
	end
	if humanoid.Health <= 0 then
		return false
	end
	local target = Vector3.new(part.Position.X, part.Position.Y + part.Size.Y * 0.5 + 3.2, part.Position.Z)
	local flatDistance = (Vector3.new(root.Position.X, 0, root.Position.Z) - Vector3.new(target.X, 0, target.Z)).Magnitude
	local verticalDistance = math.abs(root.Position.Y - target.Y)
	if flatDistance > 6 or verticalDistance > 12 then
		pcall(function()
			character:PivotTo(CFrame.new(target))
		end)
		return true
	end
	return false
end

local function viewportCenter()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(1280, 720)
	return math.floor(size.X * 0.5), math.floor(size.Y * 0.5)
end
local function interfaceBlocked()
	local x, y = viewportCenter()
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return false
	end
	local ok, objects = pcall(function()
		return playerGui:GetGuiObjectsAtPosition(x, y)
	end)
	if not ok or type(objects) ~= "table" then
		return false
	end
	for _, object in ipairs(objects) do
		if object:IsA("GuiButton") then
			return true
		end
		if object:IsA("GuiObject") and object.Visible then
			local screenGui = object:FindFirstAncestorWhichIsA("ScreenGui")
			if screenGui and gameScreens[screenGui] then
				local background = object:IsA("Frame") and object.BackgroundTransparency or 1
				if background < 0.9 then
					return true
				end
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
			pcall(function()
				environment.mouse1click()
			end)
		end
	end
	stats.shots = stats.shots + 1
end
local function aimAt(character, position)
	local camera = workspace.CurrentCamera
	local eye = characterHead(character)
	if not camera or not eye then
		return false
	end
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		camera.CameraType = Enum.CameraType.Scriptable
	end
	camera.CFrame = CFrame.lookAt(eye.Position, position)
	return true
end
local function equipPistol(character, humanoid)
	local pistol = character:FindFirstChild("Pistol")
	if pistol then
		return true
	end
	local backpack = LocalPlayer:FindFirstChild("Backpack")
	pistol = backpack and backpack:FindFirstChild("Pistol")
	if not pistol then
		return false
	end
	pcall(function()
		humanoid:EquipTool(pistol)
	end)
	return true
end
local function freezeCharacter(humanoid)
	if not humanoid then
		return
	end
	if savedWalkSpeed == nil then
		savedWalkSpeed = humanoid.WalkSpeed
		savedJumpPower = humanoid.JumpPower
	end
	pcall(function()
		humanoid.WalkSpeed = 0
		humanoid.JumpPower = 0
		humanoid.JumpHeight = 0
	end)
end
local function releaseCharacter(humanoid)
	if not humanoid then
		return
	end
	pcall(function()
		humanoid.WalkSpeed = savedWalkSpeed or 16
		humanoid.JumpPower = savedJumpPower or 50
		humanoid.JumpHeight = 7.2
	end)
	savedWalkSpeed = nil
	savedJumpPower = nil
end
local function restoreCamera()
	local camera = workspace.CurrentCamera
	local character = currentCharacter()
	local humanoid = humanoidOf(character)
	if not camera then
		return
	end
	pcall(function()
		camera.CameraType = Enum.CameraType.Custom
		if humanoid then
			camera.CameraSubject = humanoid
		end
	end)
end

local function keyNameToEnum(name)
	if type(name) ~= "string" or name == "" or name == "None" then
		return nil
	end
	local ok, keyCode = pcall(function()
		return Enum.KeyCode[name]
	end)
	if ok then
		return keyCode
	end
	return nil
end
local function nextSearchDelay()
	local base = tonumber(flag("SearchCooldown", DEFAULT_SEARCH_COOLDOWN)) or DEFAULT_SEARCH_COOLDOWN
	if base <= 0 then
		return 0
	end
	if flag("CooldownJitter", true) then
		local spread = tonumber(flag("JitterAmount", DEFAULT_JITTER)) or DEFAULT_JITTER
		return math.max(0.1, base * (1 - spread + math.random() * spread * 2))
	end
	return base
end
local function farmStep()
	local character = currentCharacter()
	local humanoid = humanoidOf(character)
	local eye = characterHead(character)
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
	local params = raycastParams(character, platform)
	local maxRange = flag("FarmRange", DEFAULT_RANGE)
	local targets = collectTargets(eye.Position, maxRange, params)
	stats.targets = #targets
	stats.kOs = knockoutCount()
	if #targets == 0 then
		local pause = nextSearchDelay()
		stats.mode = string.format("no targets, %.1f s", pause)
		stats.cooldown = pause
		task.wait(pause)
		return
	end
	local target = targets[1]
	local dummy = target.dummy
	if (shotCounters[dummy] or 0) >= MAX_SHOTS_PER_TARGET then
		local alternative = nil
		for index = 2, math.min(#targets, 6) do
			local candidate = targets[index]
			if (shotCounters[candidate.dummy] or 0) < MAX_SHOTS_PER_TARGET then
				alternative = candidate
				break
			end
		end
		if not alternative then
			shotCounters = {}
			stats.mode = "resetting aim"
			return
		end
		target = alternative
		dummy = target.dummy
	end
	if interfaceBlocked() then
		stats.mode = "interface open"
		return
	end
	aimAt(character, target.part.Position)
	fireOnce()
	shotCounters[dummy] = (shotCounters[dummy] or 0) + 1
	local down = knockedOut(dummy)
	if down then
		shotCounters[dummy] = nil
		trackDowns()
		local pause = nextSearchDelay()
		stats.mode = string.format("cooldown %.1f s", pause)
		stats.cooldown = pause
		task.wait(pause)
	else
		stats.mode = string.format("shooting %.0f", target.distance)
		task.wait(flag("FireDelay", DEFAULT_DELAY))
	end
end

do
	local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
	if playerGui then
		for _, gui in ipairs(playerGui:GetChildren()) do
			if gui:IsA("ScreenGui") then
				gameScreens[gui] = true
			end
		end
	end
end

local Window = Airflow:CreateWindow({
	Name = "Putzz Hub",
	LoadingSubtitle = "galaxy edition  ·  ko farm",
	ToggleUIKeybind = "RightControl",
	Size = UDim2.fromOffset(780, 540),
	Theme = ThemeValue,
	Density = "Compact",
	Backdrop = { Weather = "Stars", Tint = 0.25 },
	ConfigurationSaving = { Enabled = true, FolderName = "PutzzHub" },
	Home = {
		Title = "✦ Putzz Hub ✦",
		Welcome = "selamat datang,",
		Tier = "GALAXY EDITION",
		Stats = { "Players", "Session", "FPS", "Ping", "Game", "Executor" },
	},
})

local FarmTab = Window:CreateTab({ Name = "Farm", Icon = "target" })
local FarmBox = FarmTab:CreateGroupbox({ Name = "Automatic", Side = "Left" })
local AimBox = FarmTab:CreateGroupbox({ Name = "Aim", Side = "Right" })

FarmBox:CreateToggle({ Name = "KO Farm", Desc = "Knock out dummies with the pistol one after another", Flag = "KOFarm", CurrentValue = false })
FarmBox:CreateToggle({ Name = "Air platform", Desc = "Lift the player above the arena and shoot down from there", Flag = "KeepPlatform", CurrentValue = true, DependsOn = "KOFarm" })
FarmBox:CreateSlider({ Name = "Platform height", Range = { 10, 120 }, Increment = 5, Suffix = " studs", CurrentValue = DEFAULT_HEIGHT, Flag = "PlatformHeight", DependsOn = "KOFarm" })
FarmBox:CreateDivider()
FarmBox:CreateButton({ Name = "Rebuild platform", Desc = "Move the platform over the current arena", Callback = function() removePlatform(); buildPlatform(); Window:Notify({ Title = "Putzz Hub", Content = "Platform rebuilt ✦", Type = "Info" }) end })
FarmBox:CreateButton({ Name = "Remove platform", Desc = "Delete the platform and let the player fall back", Callback = function() removePlatform(); Window:Notify({ Title = "Putzz Hub", Content = "Platform removed", Type = "Info" }) end })
FarmBox:CreateStatus({ Name = "State", Style = "Row", UpdateRate = 0.4, Update = function() return string.format("<Success>%s</Success> <Muted>| %d targets</Muted>", stats.mode, stats.targets) end })

AimBox:CreateSlider({ Name = "Reach", Range = { 60, 600 }, Increment = 20, Suffix = " studs", CurrentValue = DEFAULT_RANGE, Flag = "FarmRange", DependsOn = "KOFarm" })
AimBox:CreateSlider({ Name = "Fire delay", Range = { 0.1, 1 }, Increment = 0.02, Suffix = " s", CurrentValue = DEFAULT_DELAY, Flag = "FireDelay", DependsOn = "KOFarm" })
AimBox:CreateSlider({ Name = "Search cooldown", Desc = "Pause after every knock-out before the next dummy is searched for", Range = { 0, 8 }, Increment = 0.1, Suffix = " s", CurrentValue = DEFAULT_SEARCH_COOLDOWN, Flag = "SearchCooldown", DependsOn = "KOFarm" })
AimBox:CreateToggle({ Name = "Cooldown jitter", Desc = "Vary the pause so the rhythm is not perfectly even", Flag = "CooldownJitter", CurrentValue = true, DependsOn = "KOFarm" })
AimBox:CreateSlider({ Name = "Jitter", Range = { 0, 0.5 }, Increment = 0.05, Suffix = " x", CurrentValue = DEFAULT_JITTER, Flag = "JitterAmount", DependsOn = "CooldownJitter" })
AimBox:CreateDivider()
AimBox:CreateStatus({ Name = "Downs", Style = "Row", UpdateRate = 0.5, Update = function() return string.format("<Success>%d</Success> <Muted>knocked out this session</Muted>", stats.downs) end })
AimBox:CreateStatus({ Name = "KOs", Style = "Row", UpdateRate = 0.5, Update = function() return string.format("<Success>%d</Success> <Muted>on the account</Muted>", stats.kOs) end })
AimBox:CreateStatus({ Name = "Shots", Style = "Row", UpdateRate = 0.5, Update = function() return string.format("<Success>%d</Success> <Muted>fired</Muted>", stats.shots) end })
AimBox:CreateStatus({ Name = "Cooldown", Style = "Row", UpdateRate = 0.5, Update = function() return string.format("<Success>%.1f s</Success> <Muted>until next target</Muted>", stats.cooldown) end })

local InfoTab = Window:CreateTab({ Name = "Info", Icon = "info" })
local HubBox = InfoTab:CreateGroupbox({ Name = "✦ Putzz Hub", Side = "Left" })
local TeamBox = InfoTab:CreateGroupbox({ Name = "Team", Side = "Right" })
HubBox:CreateLabel({ Text = "Putzz Hub — Galaxy Edition" })
HubBox:CreateLabel({ Text = "Script : KO Farm v1.0" })
HubBox:CreateLabel({ Text = "Game   : Hyper Realistic Ragdoll" })
HubBox:CreateDivider()
HubBox:CreateLabel({ Text = "Toggle UI  →  RightControl" })
HubBox:CreateLabel({ Text = "Panic key  →  End" })
HubBox:CreateLabel({ Text = "Farm key   →  X  (rebindable)" })
TeamBox:CreateLabel({ Text = "Founder" })
TeamBox:CreateLabel({ Text = "✦  putzz" })
TeamBox:CreateDivider()
TeamBox:CreateLabel({ Text = "UI Library  :  Airflow" })
TeamBox:CreateLabel({ Text = "Theme       :  Galaxy Black Hole" })

local SettingsTab = Window:CreateTab({ Name = "Settings", Icon = "settings" })
local InfoBox = SettingsTab:CreateGroupbox({ Name = "Session", Side = "Left" })
local ManageBox = SettingsTab:CreateGroupbox({ Name = "Control", Side = "Right" })
InfoBox:CreateStatus({ Name = "Game", Style = "Row", UpdateRate = 2, Update = function() return string.format("<Success>%s</Success> <Muted>%d</Muted>", game.Name, game.PlaceId) end })
InfoBox:CreateStatus({ Name = "Dummies", Style = "Row", UpdateRate = 1, Update = function()
	local folder = dummyFolder()
	local total, fresh = 0, 0
	if folder then
		for _, dummy in ipairs(folder:GetChildren()) do
			total = total + 1
			if not knockedOut(dummy) then fresh = fresh + 1 end
		end
	end
	return string.format("<Success>%d</Success> <Muted>awake of %d</Muted>", fresh, total)
end })
ManageBox:CreateDropdown({ Name = "Farm key", Desc = "Toggles the KO farm on and off", Options = KEY_OPTIONS, CurrentOption = "X", Flag = "FarmKey" })
ManageBox:CreateDropdown({ Name = "Panic key", Desc = "Stops the farm and gives control back", Options = KEY_OPTIONS, CurrentOption = "End", Flag = "PanicKey" })
ManageBox:CreateDivider()
ManageBox:CreateButton({ Name = "Reset counters", Desc = "Clear the session numbers", Callback = function() stats.downs = 0; stats.shots = 0; downedSet = {}; shotCounters = {} end })
ManageBox:CreateButton({ Name = "Stop farm", Desc = "Turn the farm off and return control", Callback = function() setFlag("KOFarm", false) end })
ManageBox:CreateButton({ Name = "Unload", Desc = "Close the interface and stop everything", Style = "Primary", Callback = function()
	local api = getgenv().PutzzHub
	if type(api) == "table" and type(api.Destroy) == "function" then
		api.Destroy()
	end
end })

resetFlagCache()
stats.kOs = knockoutCount()

local loopThread = task.spawn(function()
	while running do
		if flag("KOFarm", false) then
			local ok, err = pcall(farmStep)
			if not ok then
				stats.mode = "error"
				warn("[Putzz Hub] farm step failed: " .. tostring(err))
			end
		else
			stats.mode = "idle"
			local character = currentCharacter()
			local humanoid = humanoidOf(character)
			if humanoid and savedWalkSpeed ~= nil then
				releaseCharacter(humanoid)
			end
			if workspace.CurrentCamera and workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
				restoreCamera()
			end
			task.wait(0.4)
		end
	end
end)

local inputConnection = UserInputService.InputBegan:Connect(function(input, processed)
	if not running then return end
	local farmKey = keyNameToEnum(flag("FarmKey", "X"))
	local panicKey = keyNameToEnum(flag("PanicKey", "End"))
	if panicKey and input.KeyCode == panicKey then
		pcall(function()
			setFlag("KOFarm", false)
			setFlag("KeepPlatform", false)
			local character = currentCharacter()
			releaseCharacter(humanoidOf(character))
			restoreCamera()
		end)
		stats.mode = "idle"
		Window:Notify({ Title = "Putzz Hub", Content = "Farm stopped, control returned", Type = "Warning" })
		return
	end
	if processed then return end
	if farmKey and input.KeyCode == farmKey then
		local enabled = not flag("KOFarm", false)
		setFlag("KOFarm", enabled)
		Window:Notify({
			Title = "Putzz Hub",
			Content = enabled and "✦ Farm started" or "Farm stopped",
			Type = enabled and "Success" or "Info",
		})
	end
end)

local function destroy()
	if not running then return end
	running = false
	pcall(function() inputConnection:Disconnect() end)
	pcall(function() task.cancel(loopThread) end)
	local character = currentCharacter()
	releaseCharacter(humanoidOf(character))
	restoreCamera()
	pcall(function() removePlatform() end)
	pcall(function() Window:Destroy() end)
	Airflow = nil
	if getgenv().PutzzHub then
		getgenv().PutzzHub = nil
	end
end

getgenv().PutzzHub = {
	Version = "1.0",
	Set = function(name, value) return setFlag(name, value) end,
	Get = function(name, fallback) return flag(name, fallback) end,
	GetStats = function()
		return { downs = stats.downs, shots = stats.shots, kOs = stats.kOs, targets = stats.targets, mode = stats.mode }
	end,
	Platform = { Build = buildPlatform, Remove = removePlatform, Stand = standOnPlatform },
	Destroy = destroy,
}

pcall(function() Window:LoadAutoload() end)
Window:Notify({ Title = "✦ Putzz Hub", Content = "Galaxy Edition loaded — ready to farm", Type = "Success" })

return getgenv().PutzzHub
