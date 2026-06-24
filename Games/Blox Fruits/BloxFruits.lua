local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- === ЛОКАЛИЗАЦИЯ ===
local currentLang = "ru"
local translations = {
	ru = {
		hubTitle = "Pidromania Hub: Blox Fruits",
		minimizedTitle = "Pidromania Hub",
		byAuthor = "by @Pidromania",
		floor = "Море",
		farm = "Фарм",
		tools = "Инструменты",
		selectFloor = "Выберите море:",
		freezeToggle = "Фриз игрока на месте",
		questFarmToggle = "Фарм квестов",
		materialFarmToggle = "Фарм предметов",
		autoRaidToggle = "Авто Рейды",
		selectMaterialBtn = "Выбрать материал...",
		noMaterialSelected = "Сначала выберите материал!",
		materialWindowTitle = "Выберите материал для фарма",
		pAtkToggle = "Атака игроков",
		mode1Toggle = "Mode1 (+15Y)",
		mode2Toggle = "Mode2 (-10Y)",
		aimToggle = "Aim",
		stickToggle = "Stick",
		raidFinishedTitle = "Система",
		raidFinishedMsg = "Фарм закончен",
		playerJoinedTitle = "Игрок зашёл",
		friendJoinedTitle = "🌸 Твой друг зашёл! 🌸"
	}
}

local function T(key)
	return translations[currentLang][key] or ("???" .. key .. "???")
end

-- === УВЕДОМЛЕНИЯ (СИНЕ-ФИОЛЕТОВЫЕ, УМЕНЬШЕННЫЕ В 2 РАЗА) ===
local activeNotifications = {}

local function showNotification(titleText, msgText)
	if activeNotifications[msgText] then return end
	activeNotifications[msgText] = true

	local notificationGui = Instance.new("ScreenGui")
	notificationGui.Name = "Notify_" .. msgText
	notificationGui.ResetOnSpawn = false
	notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notificationGui.Parent = game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	-- Размеры уменьшены ровно в 2 раза (было 480x110)
	frame.Size = UDim2.new(0, 240, 0, 55)
	frame.Position = UDim2.new(1, 10, 1, -70) 
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.Parent = notificationGui
	
	-- Сине-фиолетовый градиент
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 100, 255)),  -- Синий
		ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 40, 255))   -- Фиолетовый
	})
	gradient.Rotation = 30
	gradient.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 7) -- Уменьшено в 2 раза
	corner.Parent = frame

	local topLabel = Instance.new("TextLabel")
	topLabel.Size = UDim2.new(1, -8, 0, 20)
	topLabel.Position = UDim2.new(0, 4, 0, 4)
	topLabel.BackgroundTransparency = 1
	topLabel.Font = Enum.Font.GothamBold
	topLabel.TextSize = 11 -- Уменьшено в 2 раза
	topLabel.TextXAlignment = Enum.TextXAlignment.Center
	topLabel.Text = titleText
	topLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	topLabel.Parent = frame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -8, 0, 24)
	nameLabel.Position = UDim2.new(0, 4, 0, 27)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = msgText
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 15 -- Уменьшено в 2 раза
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = frame
	
	-- Анимация появления
	local tweenIn = TweenService:Create(
		frame,
		TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(1, -250, 1, -70) }
	)
	tweenIn:Play()

	-- Удаление через 5 секунд
	task.spawn(function()
		task.wait(5)
		local tweenOut = TweenService:Create(
			frame,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 10, 1, -70) }
		)
		tweenOut:Play()
		tweenOut.Completed:Wait()
		notificationGui:Destroy()
		activeNotifications[msgText] = nil
	end)
end

Players.PlayerAdded:Connect(function(plr)
	if plr == Players.LocalPlayer then return end
	task.wait(0.5)
	local isFriend = false
	pcall(function() isFriend = Players.LocalPlayer:IsFriendsWith(plr.UserId) end)
	
	local titleText = isFriend and T("friendJoinedTitle") or T("playerJoinedTitle")
	showNotification(titleText, plr.Name)
end)

-- === ДАННЫЕ ИГРЫ ===
local FLOORS = {
	{1,   "Первое море",        100117331123089},
	{2,   "Второе море",        79091703265657},
	{3,   "Третье море",        85211729168715}
}

-- === QUEST & MATERIALS ===
local QUESTList = {
	-- Первое море
	{Name = "JungleQuest", Stage = 1, MinLevel = 10, MaxLevel = 14, Target = "Monkey", Count = 6, SpawnLocation = Vector3.new(-1612.6, 37.2, 141.5)},
	{Name = "JungleQuest", Stage = 2, MinLevel = 15, MaxLevel = 29, Target = "Gorilla", Count = 8, SpawnLocation = Vector3.new(-1307.2, 19.0, -479.4)},
	{Name = "PirateQuest", Stage = 1, MinLevel = 30, MaxLevel = 39, Target = "Pirate", Count = 8, SpawnLocation = Vector3.new(-1214.9, 5.1, 3910.1)},
	{Name = "PirateQuest", Stage = 2, MinLevel = 40, MaxLevel = 59, Target = "Brute", Count = 8, SpawnLocation = Vector3.new(-1098.0, 15.2, 4317.9)},
	{Name = "DesertQuest", Stage = 1, MinLevel = 60, MaxLevel = 74, Target = "Desert Bandit", Count = 8, SpawnLocation = Vector3.new(920.2, 6.8, 4485.6)},
	{Name = "DesertQuest", Stage = 2, MinLevel = 75, MaxLevel = 89, Target = "Desert Officer", Count = 6, SpawnLocation = Vector3.new(1609.4, 2.0, 4349.6)},
	{Name = "SnowQuest", Stage = 1, MinLevel = 90, MaxLevel = 100, Target = "Snow Bandit", Count = 7, SpawnLocation = Vector3.new(1271.5, 87.7, -1365.3)},
	{Name = "SnowQuest", Stage = 2, MinLevel = 100, MaxLevel = 119, Target = "Snowman", Count = 8, SpawnLocation = Vector3.new(1190.2, 106.2, -1441.8)},
	{Name = "MarineQuest", Stage = 1, MinLevel = 120, MaxLevel = 149, Target = "Chief Petty Officer", Count = 8, SpawnLocation = Vector3.new(-4651.6, 21.0, 4463.8)},
	{Name = "SkyQuest", Stage = 1, MinLevel = 150, MaxLevel = 174, Target = "Sky Bandit", Count = 7, SpawnLocation = Vector3.new(-4996.3, 278.5, -2843.2)},
	{Name = "SkyQuest", Stage = 2, MinLevel = 175, MaxLevel = 189, Target = "Dark Master", Count = 8, SpawnLocation = Vector3.new(-5225.9, 389.0, -2284.3)},
	{Name = "PrisonerQuest", Stage = 1, MinLevel = 190, MaxLevel = 209, Target = "Prisoner", Count = 8, SpawnLocation = Vector3.new(5320.4, 2.0, 403.0)},
	{Name = "PrisonerQuest", Stage = 2, MinLevel = 210, MaxLevel = 249, Target = "Dangerous Prisoner", Count = 8, SpawnLocation = Vector3.new(5619.6, 2.0, 683.6)},
	{Name = "ColosseumQuest", Stage = 1, MinLevel = 250, MaxLevel = 274, Target = "Toga Warrior", Count = 7, SpawnLocation = Vector3.new(-1829.4, 7.7, -2761.9)},
	{Name = "ColosseumQuest", Stage = 2, MinLevel = 275, MaxLevel = 299, Target = "Gladiator", Count = 8, SpawnLocation = Vector3.new(-1358.7, 7.8, -3210.9)},
	{Name = "MagmaQuest", Stage = 1, MinLevel = 300, MaxLevel = 324, Target = "Military Soldier", Count = 7, SpawnLocation = Vector3.new(-5318.0, 9.3, 8614.6)},
	{Name = "MagmaQuest", Stage = 2, MinLevel = 325, MaxLevel = 374, Target = "Military Spy", Count = 8, SpawnLocation = Vector3.new(-5852.9, 77.6, 8821.4)},
	{Name = "FishmanQuest", Stage = 1, MinLevel = 375, MaxLevel = 399, Target = "Fishman Warrior", Count = 8, SpawnLocation = Vector3.new(60886.9, 18.9, 1590.9)},
	{Name = "FishmanQuest", Stage = 2, MinLevel = 400, MaxLevel = 449, Target = "Fishman Commando", Count = 7, SpawnLocation = Vector3.new(61924.1, 18.9, 1480.8)},
	{Name = "SkyExp1Quest", Stage = 1, MinLevel = 450, MaxLevel = 474, Target = "God's Guard", Count = 7, SpawnLocation = Vector3.new(-4729.7, 845.7, -1915.7)},
	{Name = "SkyExp1Quest", Stage = 2, MinLevel = 475, MaxLevel = 524, Target = "Shanda", Count = 9, SpawnLocation = Vector3.new(-7691.4, 5545.9, -513.9)},
	{Name = "SkyExp2Quest", Stage = 1, MinLevel = 525, MaxLevel = 549, Target = "Royal Squad", Count = 8, SpawnLocation = Vector3.new(-7616.7, 5607.3, -1467.8)},
	{Name = "SkyExp2Quest", Stage = 2, MinLevel = 550, MaxLevel = 624, Target = "Royal Soldier", Count = 8, SpawnLocation = Vector3.new(-7851.8, 5607.3, -1728.9)},
	{Name = "FountainQuest", Stage = 1, MinLevel = 625, MaxLevel = 649, Target = "Galley Pirate", Count = 8, SpawnLocation = Vector3.new(5698.5, 38.9, 3964.0)},
	{Name = "FountainQuest", Stage = 2, MinLevel = 650, MaxLevel = 699, Target = "Galley Captain", Count = 9, SpawnLocation = Vector3.new(5503.0, 38.9, 4923.6)},

	-- Второе море
	{Name = "Area1Quest", Stage = 1, MinLevel = 700, MaxLevel = 724, Target = "Raider", Count = 8, SpawnLocation = Vector3.new(381.62, 39.23, 2347.52)},
	{Name = "Area1Quest", Stage = 2, MinLevel = 725, MaxLevel = 774, Target = "Mercenary", Count = 8, SpawnLocation = Vector3.new(-1029.28, 73.03, 1413.74)},
	{Name = "Area2Quest", Stage = 1, MinLevel = 775, MaxLevel = 799, Target = "Swan Pirate", Count = 8, SpawnLocation = Vector3.new(1017.12, 76.82, 1298.27)},
	{Name = "Area2Quest", Stage = 2, MinLevel = 800, MaxLevel = 899, Target = "Factory Staff", Count = 8, SpawnLocation = Vector3.new(-71.25, 76.75, -408.97)},
	{Name = "MarineQuest3", Stage = 1, MinLevel = 875, MaxLevel = 899, Target = "Marine Lieutenant", Count = 8, SpawnLocation = Vector3.new(-2915.35, 76.87, -3040.90)},
	{Name = "MarineQuest3", Stage = 2, MinLevel = 900, MaxLevel = 949, Target = "Marine Captain", Count = 9, SpawnLocation = Vector3.new(-1812.42, 76.76, -3240.19)},
	{Name = "ZombieQuest", Stage = 1, MinLevel = 950, MaxLevel = 974, Target = "Zombie", Count = 8, SpawnLocation = Vector3.new(-5581.22, 52.27, -884.49)},
	{Name = "ZombieQuest", Stage = 2, MinLevel = 975, MaxLevel = 999, Target = "Vampire", Count = 8, SpawnLocation = Vector3.new(-6063.41, 10.20, -1346.91)},
	{Name = "SnowMountainQuest", Stage = 1, MinLevel = 1000, MaxLevel = 1049, Target = "Snow Trooper", Count = 8, SpawnLocation = Vector3.new(574.84, 405.22, -5542.23)},
	{Name = "SnowMountainQuest", Stage = 2, MinLevel = 1050, MaxLevel = 1099, Target = "Winter Warrior", Count = 9, SpawnLocation = Vector3.new(1296.86, 433.22, -5311.17)},
	{Name = "IceSideQuest", Stage = 1, MinLevel = 1100, MaxLevel = 1124, Target = "Lab Subordinate", Count = 8, SpawnLocation = Vector3.new(-5722.64, 19.75, -4498.96)},
	{Name = "IceSideQuest", Stage = 2, MinLevel = 1125, MaxLevel = 1199, Target = "Horned Warrior", Count = 9, SpawnLocation = Vector3.new(-6415.25, 19.75, -5793.57)},
	{Name = "FireSideQuest", Stage = 1, MinLevel = 1175, MaxLevel = 1199, Target = "Magma Ninja", Count = 8, SpawnLocation = Vector3.new(-5188.06, 19.75, -6088.37)},
	{Name = "FireSideQuest", Stage = 2, MinLevel = 1200, MaxLevel = 1249, Target = "Lava Pirate", Count = 8, SpawnLocation = Vector3.new(-5152.00, 19.75, -4738.19)},
	{Name = "ShipQuest1", Stage = 1, MinLevel = 1250, MaxLevel = 1274, Target = "Ship Deckhand", Count = 8, SpawnLocation = Vector3.new(1174.38, 129.52, 32986.25)},
	{Name = "ShipQuest1", Stage = 2, MinLevel = 1275, MaxLevel = 1299, Target = "Ship Engineer", Count = 8, SpawnLocation = Vector3.new(920.70, 43.85, 32744.49)},
	{Name = "ShipQuest2", Stage = 1, MinLevel = 1300, MaxLevel = 1324, Target = "Ship Steward", Count = 8, SpawnLocation = Vector3.new(920.34, 148.26, 33443.54)},
	{Name = "ShipQuest2", Stage = 2, MinLevel = 1325, MaxLevel = 1349, Target = "Ship Officer", Count = 8, SpawnLocation = Vector3.new(923.78, 184.85, 33346.15)},
	{Name = "FrostQuest", Stage = 1, MinLevel = 1350, MaxLevel = 1374, Target = "Arctic Warrior", Count = 8, SpawnLocation = Vector3.new(6155.74, 32.16, -6193.88)},
	{Name = "FrostQuest", Stage = 2, MinLevel = 1375, MaxLevel = 1424, Target = "Snow Lurker", Count = 8, SpawnLocation = Vector3.new(5491.06, 32.62, -6885.48)},
	{Name = "ForgottenQuest", Stage = 1, MinLevel = 1425, MaxLevel = 1449, Target = "Sea Soldier", Count = 8, SpawnLocation = Vector3.new(-3374.31, 30.55, -9767.11)},
	{Name = "ForgottenQuest", Stage = 2, MinLevel = 1450, MaxLevel = 1499, Target = "Water Fighter", Count = 8, SpawnLocation = Vector3.new(-3287.43, 243.20, -10423.24)},

	-- Третье море
	{Name = "PiratePortQuest", Stage = 1, MinLevel = 1500, MaxLevel = 1524, Target = "Pirate Millionaire", Count = 8, SpawnLocation = Vector3.new(-130.78, 57.35, 5762.56)},
	{Name = "PiratePortQuest", Stage = 1, MinLevel = 1500, MaxLevel = 1524, Target = "Pirate Millionaire", Count = 8, SpawnLocation = Vector3.new(-638.50, 57.35, 5628.00)},
	{Name = "PiratePortQuest", Stage = 2, MinLevel = 1525, MaxLevel = 1574, Target = "Pistol Billionaire", Count = 8, SpawnLocation = Vector3.new(-803.98, 85.15, 6028.94)},
	{Name = "PiratePortQuest", Stage = 2, MinLevel = 1525, MaxLevel = 1574, Target = "Pistol Billionaire", Count = 8, SpawnLocation = Vector3.new(-124.92, 85.06, 6223.58)},
	{Name = "DragonCrewQuest", Stage = 1, MinLevel = 1575, MaxLevel = 1599, Target = "Dragon Crew Warrior", Count = 8, SpawnLocation = Vector3.new(6862.10, 56.10, -809.83)},
	{Name = "DragonCrewQuest", Stage = 2, MinLevel = 1600, MaxLevel = 1624, Target = "Dragon Crew Archer", Count = 8, SpawnLocation = Vector3.new(6821.57, 484.74, 409.51)},
	{Name = "VenomCrewQuest", Stage = 1, MinLevel = 1625, MaxLevel = 1649, Target = "Hydra Enforcer", Count = 8, SpawnLocation = Vector3.new(4548.66, 1002.60, 436.52)},
	{Name = "VenomCrewQuest", Stage = 2, MinLevel = 1650, MaxLevel = 1699, Target = "Venomous Assailant", Count = 8, SpawnLocation = Vector3.new(4569.75, 1144.72, 874.96)},
	{Name = "MarineTreeIsland", Stage = 1, MinLevel = 1700, MaxLevel = 1724, Target = "Marine Commodore", Count = 8, SpawnLocation = Vector3.new(2610.59, 129.47, -7934.55)},
	{Name = "MarineTreeIsland", Stage = 2, MinLevel = 1725, MaxLevel = 1774, Target = "Marine Rear Admiral", Count = 8, SpawnLocation = Vector3.new(3726.02, 124.31, -7144.17)},
	{Name = "DeepForestIsland3", Stage = 1, MinLevel = 1775, MaxLevel = 1799, Target = "Fishman Raider", Count = 8, SpawnLocation = Vector3.new(-10408.46, 332.14, -8377.39)},
	{Name = "DeepForestIsland3", Stage = 2, MinLevel = 1800, MaxLevel = 1824, Target = "Fishman Captain", Count = 8, SpawnLocation = Vector3.new(-11028.33, 332.14, -8953.12)},
	{Name = "DeepForestIsland", Stage = 1, MinLevel = 1825, MaxLevel = 1849, Target = "Forest Pirate", Count = 8, SpawnLocation = Vector3.new(-13347.04, 332.75, -7782.38)},
	{Name = "DeepForestIsland", Stage = 2, MinLevel = 1850, MaxLevel = 1899, Target = "Mythological Pirate", Count = 8, SpawnLocation = Vector3.new(-13554.56, 469.96, -6820.59)},
	{Name = "DeepForestIsland2", Stage = 1, MinLevel = 1900, MaxLevel = 1924, Target = "Jungle Pirate", Count = 8, SpawnLocation = Vector3.new(-11692.78, 332.11, -10593.83)},
	{Name = "DeepForestIsland2", Stage = 2, MinLevel = 1925, MaxLevel = 1974, Target = "Musketeer Pirate", Count = 8, SpawnLocation = Vector3.new(-13268.80, 391.34, -9767.33)},
	{Name = "HauntedQuest1", Stage = 1, MinLevel = 1975, MaxLevel = 1999, Target = "Reborn Skeleton", Count = 8, SpawnLocation = Vector3.new(-8763.04, 142.48, 5998.68)},
	{Name = "HauntedQuest1", Stage = 2, MinLevel = 2000, MaxLevel = 2024, Target = "Living Zombie", Count = 8, SpawnLocation = Vector3.new(-10160.25, 139.00, 5980.26)},
	{Name = "HauntedQuest2", Stage = 1, MinLevel = 2025, MaxLevel = 2049, Target = "Demonic Soul", Count = 8, SpawnLocation = Vector3.new(-9475.51, 172.48, 6143.71)},
	{Name = "HauntedQuest2", Stage = 2, MinLevel = 2050, MaxLevel = 2449, Target = "Posessed Mummy", Count = 8, SpawnLocation = Vector3.new(-9571.32, 6.17, 6214.69)},
	{Name = "TikiQuest1", Stage = 1, MinLevel = 2450, MaxLevel = 2474, Target = "Isle Outlaw", Count = 8, SpawnLocation = Vector3.new(-16248.34, 22.04, -214.92)},
	{Name = "TikiQuest1", Stage = 2, MinLevel = 2475, MaxLevel = 2449, Target = "Island Boy", Count = 8, SpawnLocation = Vector3.new(-16849.87, 22.04, -191.95)},
	{Name = "TikiQuest2", Stage = 1, MinLevel = 2500, MaxLevel = 2524, Target = "Sun-kissed Warrior", Count = 8, SpawnLocation = Vector3.new(-16278.05, 22.04, 1054.83)},
	{Name = "TikiQuest2", Stage = 2, MinLevel = 2525, MaxLevel = 2549, Target = "Isle Champion", Count = 8, SpawnLocation = Vector3.new(-16774.46, 22.04, 1053.09)},
	{Name = "TikiQuest3", Stage = 1, MinLevel = 2550, MaxLevel = 2574, Target = "Serpent Hunter", Count = 8, SpawnLocation = Vector3.new(-16584.82, 107.40, 1393.16)},
	{Name = "TikiQuest3", Stage = 2, MinLevel = 2575, MaxLevel = 3000, Target = "Skull Slayer", Count = 8, SpawnLocation = Vector3.new(-16837.36, 71.62, 1644.85)}
}

local MATERIALS = {
	["PLASMA"] = {
		mobs = {
			["Ship Deckhand"] = true,
			["Ship Engineer"] = true,
			["Ship Steward"] = true,
			["Ship Officer"] = true
		},
		spawnLocation = Vector3.new(1174.38, 129.52, 32986.25)
	},
	["BONES"] = {
		mobs = {
			["Reborn Skeleton"] = true,
			["Living Zombie"] = true,
			["Demonic Soul"] = true,
			["Posessed Mummy"] = true
		},
		spawnLocation = Vector3.new(-9475.51, 172.48, 6143.71)
	},
	["FISH_TAIL"] = {
		mobs = {
			["Raider"] = true,
			["Mercenary"] = true
		},
		spawnLocation = Vector3.new(381.62, 39.23, 2347.52)
	},
	["MYSTIC_DROP"] = {
		mobs = {
			["Sea Soldier"] = true,
			["Water Fighter"] = true
		},
		spawnLocation = Vector3.new(-3374.31, 30.55, -9767.11)
	},
	["DEMONIC_FLAME"] = {
		mobs = {
			["Demonic Soul"] = true
		},
		spawnLocation = Vector3.new(-9502.15, 175.90, 6157.83)
	},
	["DRAGON_SCALES"] = {
		mobs = {
			["Dragon Crew Warrior"] = true,
			["Dragon Crew Archer"] = true
		},
		spawnLocation = Vector3.new(6862.10, 56.10, -809.83)
	},
	["ENCHANTED_COCOA"] = {
		mobs = {
			["Hydra Enforcer"] = true,
			["Venomous Assailant"] = true
		},
		spawnLocation = Vector3.new(4562.26, 1006.05, 619.54)
	},
	["MINI_TUSK"] = {
		mobs = {
			["Mythological Pirate"] = true
		},
		spawnLocation = Vector3.new(-13554.56, 469.96, -6820.59)
	},
	["GUNPOWDER"] = {
		mobs = {
			["Pistol Billionaire"] = true
		},
		spawnLocation = Vector3.new(-124.92, 85.06, 6223.58)
	},
	["RADIOACTIVE_MATERIAL"] = {
		mobs = {
			["Factory Staff"] = true
		},
		spawnLocation = Vector3.new(-71.25, 76.75, -408.97)
	},
	["VAMPIRE_FANG"] = {
		mobs = {
			["Vampire"] = true
		},
		spawnLocation = Vector3.new(-6063.41, 10.20, -1346.91)
	}
}

-- === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ===
local isFrozen = false
local freezeConnection = nil
local isQuestFarming = false
local isMaterialFarming = false
local isAutoRaiding = false
local selectedMaterialType = nil
local materialWindow = nil

-- Ghost Hunter
local flyingMode1Active = false
local flyingMode2Active = false
local aimbotActive = false
local playerAttackEnabled = false
local stickToPlayerActive = false

local flyConnection1 = nil
local flyConnection2 = nil
local aimbotConnection = nil
local stickConnection = nil

-- Фарм
local flightConnection = nil
local MAX_FLIGHT_SPEED = 150

-- GUI
local guiToggleConnection = nil

-- === ФУНКЦИИ ===
local function stopFlight()
	if flightConnection then
		flightConnection:Disconnect()
		flightConnection = nil
	end
end

local function flyTo(targetPos, onComplete)
	stopFlight()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local startPos = hrp.Position
	local lastPos = startPos
	local goalPos = Vector3.new(targetPos.X, targetPos.Y + 20, targetPos.Z)

	flightConnection = RunService.Heartbeat:Connect(function(dt)
		if not (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then
			stopFlight()
			return
		end
		local root = player.Character.HumanoidRootPart
		local dir = (goalPos - lastPos).Unit
		local dist = (goalPos - lastPos).Magnitude
		local move = MAX_FLIGHT_SPEED * dt
		if move >= dist then
			root.CFrame = CFrame.new(goalPos)
			stopFlight()
			if onComplete then onComplete() end
		else
			local newPos = lastPos + dir * move
			root.CFrame = CFrame.new(newPos)
			lastPos = newPos
		end
	end)
end

local function freezePlayer()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local freezePos = hrp.CFrame
	if freezeConnection then
		freezeConnection:Disconnect()
	end
	freezeConnection = RunService.RenderStepped:Connect(function()
		if hrp and hrp.Parent then
			hrp.CFrame = freezePos
		end
	end)
end

local function unfreezePlayer()
	if freezeConnection then
		freezeConnection:Disconnect()
		freezeConnection = nil
	end
end

local function getLevelFromGUI()
	local gui = player:FindFirstChild("PlayerGui")
	if not gui then return nil end
	local main = gui:FindFirstChild("Main")
	if not main then return nil end
	local levelText = main:FindFirstChild("Level")
	if not levelText then return nil end
	local num = string.match(levelText.Text, "%d+")
	return num and tonumber(num) or nil
end

local function findQuestByLevel(level)
	for _, q in ipairs(QUESTList) do
		if level >= q.MinLevel and level <= q.MaxLevel then
			return q
		end
	end
	return nil
end

local function takeQuest(name, stage)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local commF = remotes and remotes:FindFirstChild("CommF_")
	if not commF then return false end
	pcall(function() commF:InvokeServer("StartQuest", name, stage) end)
	return true
end

local function getToken()
	local character = player.Character
	if character then
		local token = character:FindFirstChild("AttackToken")
		if token then return token.Value end
	end
	return "10388e88"
end

local function attackTarget(target)
	if not (target and target.Parent) then return end
	local hum = target:FindFirstChild("Humanoid")
	local hitPart = target:FindFirstChild("RightFoot") or target:FindFirstChild("HumanoidRootPart")
	if not (hum and hitPart) then return end
	local RegisterHit = ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Net"):FindFirstChild("RE/RegisterHit")
	local RegisterAttack = ReplicatedStorage:FindFirstChild("Modules"):FindFirstChild("Net"):FindFirstChild("RE/RegisterAttack")
	pcall(function()
		if RegisterAttack then RegisterAttack:FireServer(0.25) end
		if RegisterHit then
			local args = {
				[1] = hitPart,
				[2] = { Damage = 10, Knockback = 0.5, HitEffect = true },
				[4] = getToken()
			}
			RegisterHit:FireServer(unpack(args))
		end
	end)
end

local function findNearestMobByTable(tbl)
	local char = player.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local nearest = nil
	local minDist = math.huge
	if not Workspace:FindFirstChild("Enemies") then return nil end
	for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
		if tbl[enemy.Name] and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart")
			if eRoot then
				local dist = (root.Position - eRoot.Position).Magnitude
				if dist < minDist then
					minDist = dist
					nearest = enemy
				end
			end
		end
	end
	return nearest
end

local function getNearestTarget()
	local char = player.Character
	if not char then return nil end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local nearest = nil
	local minDist = math.huge
	local maxRadius = 500

	if Workspace:FindFirstChild("Enemies") then
		for _, e in ipairs(Workspace.Enemies:GetChildren()) do
			if e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
				local eRoot = e.HumanoidRootPart
				local dist = (root.Position - eRoot.Position).Magnitude
				if dist <= maxRadius and dist < minDist then
					minDist = dist
					nearest = e
				end
			end
		end
	end

	if playerAttackEnabled then
		local friendIds = {8171079849}
		local friendNames = {"SaLatik_Hunter"}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == player then continue end
			local isFriend = false
			for _, id in ipairs(friendIds) do
				if plr.UserId == id then isFriend = true break end
			end
			for _, name in ipairs(friendNames) do
				if plr.Name == name then isFriend = true break end
			end
			if isFriend then continue end

			local pChar = plr.Character
			if pChar and pChar:FindFirstChild("Humanoid") and pChar.Humanoid.Health > 0 and pChar:FindFirstChild("HumanoidRootPart") then
				local pRoot = pChar.HumanoidRootPart
				local dist = (root.Position - pRoot.Position).Magnitude
				if dist <= maxRadius and dist < minDist then
					minDist = dist
					nearest = pChar
				end
			end
		end
	end

	return nearest
end

local function flyToTarget(target, yOffset)
	local character = player.Character
	if not character then return end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	local targetRoot = target:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end
	
	local targetPos = targetRoot.Position
	local flyPos = Vector3.new(targetPos.X, targetPos.Y + yOffset, targetPos.Z)
	
	rootPart.CFrame = CFrame.new(flyPos)
	rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

-- === ФАРМ КВЕСТОВ ===
local function startQuestFarm()
	isQuestFarming = true
	spawn(function()
		while isQuestFarming do
			local lvl = getLevelFromGUI()
			if not lvl then break end
			local q = findQuestByLevel(lvl)
			if not q then break end
			takeQuest(q.Name, q.Stage)
			task.wait(1)

			local arrived = false
			flyTo(q.SpawnLocation, function() arrived = true end)
			repeat task.wait() until arrived or not isQuestFarming
			if not isQuestFarming then break end

			local targets = {[q.Target] = true}
			local count = 0
			local maxCount = q.Count
			local trackedMobs = {}
			local countedMobs = {}

			local function trackMob(mob)
				if not mob or trackedMobs[mob] then return end
				local hum = mob:FindFirstChild("Humanoid")
				if not hum then return end
				trackedMobs[mob] = true

				local diedConn = hum.Died:Connect(function()
					if isQuestFarming and targets[mob.Name] and not countedMobs[mob] then
						count += 1
						countedMobs[mob] = true
					end
					trackedMobs[mob] = nil
				end)
			end

			while count < maxCount and isQuestFarming do
				if Workspace:FindFirstChild("Enemies") then
					for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
						if targets[enemy.Name] and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 and not trackedMobs[enemy] then
							trackMob(enemy)
						end
					end
				end
				local mob = findNearestMobByTable(targets)
				if mob then
					flyToTarget(mob, 15) 
				end
				RunService.Heartbeat:Wait()
			end
		end
		isQuestFarming = false
	end)
end

local function stopQuestFarm()
	isQuestFarming = false
	stopFlight()
end

-- === ФАРМ МАТЕРИАЛОВ ===
local function startMaterialsFarm(materialType)
	local matData = MATERIALS[materialType]
	if not matData then return end
	isMaterialFarming = true
	spawn(function()
		while isMaterialFarming do
			local arrived = false
			flyTo(matData.spawnLocation, function() arrived = true end)
			repeat task.wait() until arrived or not isMaterialFarming
			if not isMaterialFarming then break end

			while isMaterialFarming do
				local mob = findNearestMobByTable(matData.mobs)
				if mob then
					flyToTarget(mob, 15)
				else
					task.wait(2)
					break
				end
				RunService.Heartbeat:Wait()
			end
		end
	end)
end

local function stopMaterialsFarm()
	isMaterialFarming = false
	stopFlight()
end

-- === MODE1 ===
local function startFlyingMode1()
	if flyingMode1Active then return end
	flyingMode1Active = true
	flyConnection1 = RunService.Heartbeat:Connect(function()
		local target = getNearestTarget()
		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then return end
		
		flyToTarget(target, 15)
	end)
end

local function stopFlyingMode1()
	if flyConnection1 then flyConnection1:Disconnect() flyConnection1 = nil end
	flyingMode1Active = false
end

-- === MODE2 ===
local function startFlyingMode2()
	if flyingMode2Active then return end
	flyingMode2Active = true
	flyConnection2 = RunService.Heartbeat:Connect(function()
		local target = getNearestTarget()
		if not target or not target:FindFirstChild("Humanoid") or target.Humanoid.Health <= 0 then return end
		
		flyToTarget(target, -10)
	end)
end

local function stopFlyingMode2()
	if flyConnection2 then flyConnection2:Disconnect() flyConnection2 = nil end
	flyingMode2Active = false
end

-- === АВТО РЕЙДЫ ===
local function getRaidIslandCenter(n)
	local raidMap = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("RaidMap")
	if not raidMap then return nil end
	
	local island = raidMap:FindFirstChild("RaidIsland" .. tostring(n))
	if not island then return nil end
	
	for _, obj in ipairs(island:GetDescendants()) do
		if obj:IsA("BasePart") then
			return obj.Position
		end
	end
	return nil
end

local function startAutoRaid()
	isAutoRaiding = true
	task.spawn(function()
		local n = 1
		while isAutoRaiding do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then task.wait(1) continue end

			local island1Pos = getRaidIslandCenter(1)
			
			if not island1Pos or (hrp.Position - island1Pos).Magnitude > 3000 then
				local startPos = Vector3.new(-5005.37, 315.21, -2820.61)
				local arrived = false
				flyTo(startPos, function() arrived = true end)
				repeat task.wait() until arrived or not isAutoRaiding
				
				if not isAutoRaiding then break end
				task.wait(2)
				continue
			else
				if n == 1 and (hrp.Position - island1Pos).Magnitude < 3000 then
					n = 1 
				end
			end

			local currentIslandPos = getRaidIslandCenter(n)
			if not currentIslandPos then task.wait(1) continue end

			local hasMobs = false
			if Workspace:FindFirstChild("Enemies") then
				for _, enemy in ipairs(Workspace.Enemies:GetChildren()) do
					if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
						local eRoot = enemy:FindFirstChild("HumanoidRootPart")
						if eRoot and (eRoot.Position - currentIslandPos).Magnitude < 1000 then
							hasMobs = true
							break
						end
					end
				end
			end

			if not hasMobs then
				if n >= 5 then
					showNotification(T("raidFinishedTitle"), T("raidFinishedMsg"))
					isAutoRaiding = false
					break
				else
					local mode1WasActive = flyingMode1Active
					stopFlyingMode1()
					
					hrp.CFrame = CFrame.new(currentIslandPos.X, currentIslandPos.Y + 25, currentIslandPos.Z)
					task.wait(0.5)

					n = n + 1
					local nextIslandPos = getRaidIslandCenter(n)
					if nextIslandPos then
						local arrived = false
						flyTo(Vector3.new(nextIslandPos.X, nextIslandPos.Y + 25, nextIslandPos.Z), function()
							arrived = true
						end)
						repeat task.wait() until arrived or not isAutoRaiding
						
						task.wait(1.5)
						startFlyingMode1()
					end
				end
			else
				if not flyingMode1Active and isAutoRaiding then
					startFlyingMode1()
				end
				task.wait(1)
			end
		end
	end)
end

local function stopAutoRaid()
	isAutoRaiding = false
	stopFlight()
end

-- === AIMBOT ===
local function getNearestPlayer()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local nearest = nil
	local minDist = math.huge
	local friendIds = {8171079849}
	local friendNames = {"SaLatik_Hunter"}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == player then continue end
		local isFriend = false
		for _, id in ipairs(friendIds) do
			if plr.UserId == id then isFriend = true break end
		end
		for _, name in ipairs(friendNames) do
			if plr.Name == name then isFriend = true break end
		end
		if isFriend then continue end

		local pChar = plr.Character
		if pChar and pChar:FindFirstChild("HumanoidRootPart") and pChar.Humanoid and pChar.Humanoid.Health > 0 then
			local pRoot = pChar.HumanoidRootPart
			local dist = (root.Position - pRoot.Position).Magnitude
			if dist <= 1000 and dist < minDist then
				minDist = dist
				nearest = pChar
			end
		end
	end
	return nearest
end

local function startAimbot()
	if aimbotActive then return end
	aimbotActive = true
	aimbotConnection = RunService.Heartbeat:Connect(function()
		local p = getNearestPlayer()
		if p and p:FindFirstChild("HumanoidRootPart") then
			local cam = Workspace.CurrentCamera
			local head = player.Character and player.Character:FindFirstChild("Head")
			if cam and head then
				cam.CFrame = CFrame.lookAt(head.Position, p.HumanoidRootPart.Position)
			end
		end
	end)
end

local function stopAimbot()
	if aimbotConnection then aimbotConnection:Disconnect() aimbotConnection = nil end
	aimbotActive = false
end

-- === STICK TO PLAYER ===
local function startStickToPlayer()
	if stickToPlayerActive then return end
	stickToPlayerActive = true
	stickConnection = RunService.Heartbeat:Connect(function()
		local p = getNearestPlayer()
		if p and p:FindFirstChild("HumanoidRootPart") and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local root = player.Character.HumanoidRootPart
			root.CFrame = CFrame.new(p.HumanoidRootPart.Position)
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function stopStickToPlayer()
	if stickConnection then stickConnection:Disconnect() stickConnection = nil end
	stickToPlayerActive = false
end

-- === ГЛОБАЛЬНАЯ НЕЗАВИСИМАЯ АТАКА ===
task.spawn(function()
	while true do
		if isQuestFarming or isMaterialFarming or isAutoRaiding or flyingMode1Active or flyingMode2Active or playerAttackEnabled then
			local target = getNearestTarget()
			if target then
				attackTarget(target)
			end
		end
		task.wait(0.1)
	end
end)

-- === ОБЩИЙ ЭЛЕМЕНТ - ПЕРЕКЛЮЧАТЕЛЬ ===
local function createToggleSwitch(parent, label, initialEnabled, onToggle)
	local switchFrame = Instance.new("Frame")
	switchFrame.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
	switchFrame.Position = UDim2.new(0, 5 * 1.5, 0, 0)
	switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
	switchFrame.BorderSizePixel = 0
	switchFrame.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6 * 1.5)
	corner.Parent = switchFrame
	
	local labelText = Instance.new("TextLabel")
	labelText.Text = label
	labelText.Size = UDim2.new(0, 180 * 1.5, 1, 0)
	labelText.BackgroundTransparency = 1
	labelText.TextColor3 = Color3.fromRGB(240, 240, 255)
	labelText.Font = Enum.Font.GothamSemibold
	labelText.TextSize = 14 * 1.5
	labelText.TextXAlignment = Enum.TextXAlignment.Left
	labelText.Position = UDim2.new(0, 5 * 1.5, 0, 0)
	labelText.Parent = switchFrame
	
	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 40 * 1.5, 0, 20 * 1.5)
	toggleBg.Position = UDim2.new(1, -45 * 1.5, 0.5, -10 * 1.5)
	toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = switchFrame
	
	local cornerBg = Instance.new("UICorner")
	cornerBg.CornerRadius = UDim.new(0, 10 * 1.5)
	cornerBg.Parent = toggleBg
	
	local toggleKnob = Instance.new("Frame")
	toggleKnob.Size = UDim2.new(0, 16 * 1.5, 0, 16 * 1.5)
	toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	toggleKnob.BorderSizePixel = 0
	toggleKnob.Parent = toggleBg
	
	local cornerKnob = Instance.new("UICorner")
	cornerKnob.CornerRadius = UDim.new(0, 8 * 1.5)
	cornerKnob.Parent = toggleKnob
	
	local isEnabled = initialEnabled
	
	local function updateToggle()
		if isEnabled then
			toggleBg.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
			toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			toggleKnob.Position = UDim2.new(1, -18 * 1.5, 0.5, -8 * 1.5)
		else
			toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
			toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
			toggleKnob.Position = UDim2.new(0, 2 * 1.5, 0.5, -8 * 1.5)
		end
	end
	updateToggle()
	
	switchFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			isEnabled = not isEnabled
			onToggle(isEnabled)
			updateToggle()
		end
	end)
	
	return switchFrame, function(state)
		isEnabled = state
		updateToggle()
	end
end

-- === ОКНО ВЫБОРА МАТЕРИАЛА ===
local function createMaterialWindow()
	if materialWindow then materialWindow:Destroy() end
	materialWindow = Instance.new("ScreenGui")
	materialWindow.Name = "MaterialSelector"
	materialWindow.ResetOnSpawn = false
	materialWindow.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	materialWindow.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 200 * 1.5, 0, 266 * 1.5)
	frame.Position = UDim2.new(0.5, -(200 * 1.5)/2, 0.5, -(266 * 1.5)/2)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = materialWindow

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8 * 1.5)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Text = T("materialWindowTitle")
	title.Size = UDim2.new(1, 0, 0, 30 * 1.5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13 * 1.5
	title.Parent = frame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -10 * 1.5, 1, -35 * 1.5)
	scroll.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.ScrollBarThickness = 4 * 1.5
	scroll.BackgroundTransparency = 1
	scroll.Parent = frame

	local y = 0
	for matName, _ in pairs(MATERIALS) do
		local btn = Instance.new("TextButton")
		btn.Text = matName
		btn.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
		btn.Position = UDim2.new(0, 5 * 1.5, 0, y)
		btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		btn.TextColor3 = Color3.fromRGB(240, 240, 255)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 13 * 1.5
		btn.Parent = scroll

		local cornerBtn = Instance.new("UICorner")
		cornerBtn.CornerRadius = UDim.new(0, 6 * 1.5)
		cornerBtn.Parent = btn

		btn.MouseButton1Click:Connect(function()
			selectedMaterialType = matName
			materialWindow:Destroy()
			materialWindow = nil
		end)

		y += 35 * 1.5
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- === ОСНОВНОЙ GUI ===
local screenGuiMain = nil

local function rebuildGUI()
	if screenGuiMain then screenGuiMain:Destroy() end
	
	local pGui = player:FindFirstChild("PlayerGui")
	if pGui then
		for _, v in ipairs(pGui:GetChildren()) do
			if v.Name == "PidromaniaHub" then v:Destroy() end
		end
	end
	
	screenGuiMain = Instance.new("ScreenGui")
	screenGuiMain.Name = "PidromaniaHub"
	screenGuiMain.ResetOnSpawn = false
	screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGuiMain.Parent = player:WaitForChild("PlayerGui")
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 800 * 1.5, 0, 500 * 1.5)
	mainFrame.Position = UDim2.new(0.5, -(800 * 1.5)/2, 0.5, -(500 * 1.5)/2)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGuiMain
	
	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 10 * 1.5)
	mainFrameCorner.Parent = mainFrame
	
	local dragDetector = Instance.new("Frame")
	dragDetector.Size = UDim2.new(1, -50 * 1.5, 1, 0)
	dragDetector.Position = UDim2.new(0, 0, 0, 0)
	dragDetector.BackgroundTransparency = 1
	dragDetector.Parent = mainFrame
	
	local minimizedFrame = Instance.new("Frame")
	minimizedFrame.Size = UDim2.new(0, 100 * 1.5, 0, 30 * 1.5)
	minimizedFrame.Position = UDim2.new(0, 10, 0, 10)
	minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	minimizedFrame.BorderSizePixel = 0
	minimizedFrame.Visible = false
	minimizedFrame.Active = true
	minimizedFrame.Draggable = true
	minimizedFrame.Parent = screenGuiMain
	
	local cornerMinimized = Instance.new("UICorner")
	cornerMinimized.CornerRadius = UDim.new(0, 6 * 1.5)
	cornerMinimized.Parent = minimizedFrame
	
	local minimizedLabel = Instance.new("TextLabel")
	minimizedLabel.Text = T("minimizedTitle")
	minimizedLabel.Size = UDim2.new(1, 0, 1, 0)
	minimizedLabel.BackgroundTransparency = 1
	minimizedLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
	minimizedLabel.Font = Enum.Font.GothamBold
	minimizedLabel.TextSize = 12 * 1.5
	minimizedLabel.Parent = minimizedFrame
	
	minimizedFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mainFrame.Visible = true
			minimizedFrame.Visible = false
		end
	end)
	
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 35 * 1.5)
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	
	local cornerHeader = Instance.new("UICorner")
	cornerHeader.CornerRadius = UDim.new(0, 6 * 1.5)
	cornerHeader.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Text = T("hubTitle")
	title.TextScaled = false
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14 * 1.5
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	local textSize = TextService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(math.huge, math.huge))
	title.Size = UDim2.new(0, textSize.X * 1.1, 0, 20 * 1.5)
	title.Position = UDim2.new(0, 5, 0, 7 * 1.5)
	title.Parent = header
	
	local author = Instance.new("TextLabel")
	author.Text = T("byAuthor")
	author.TextScaled = false
	author.Font = Enum.Font.GothamSemibold
	author.TextSize = 12 * 1.5
	author.BackgroundTransparency = 1
	author.TextColor3 = Color3.fromRGB(150, 150, 180)
	local authorTextSize = TextService:GetTextSize(author.Text, author.TextSize, author.Font, Vector2.new(math.huge, math.huge))
	author.Size = UDim2.new(0, authorTextSize.X * 1.1, 0, 20 * 1.5)
	local offset = -15
	author.Position = UDim2.new(0, title.Position.X.Offset + title.Size.X.Offset + offset, 0, 7 * 1.5)
	author.Parent = header
	
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Text = "--"
	minimizeBtn.Size = UDim2.new(0, 25 * 1.5, 0, 25 * 1.5)
	minimizeBtn.Position = UDim2.new(1, -30 * 1.5, 0, 5 * 1.5)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 14 * 1.5
	minimizeBtn.Parent = header
	
	minimizeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		minimizedFrame.Visible = true
	end)
	
	local leftPanel = Instance.new("Frame")
	leftPanel.Size = UDim2.new(0, 200 * 1.5, 1, -35 * 1.5)
	leftPanel.Position = UDim2.new(0, 0, 0, 35 * 1.5)
	leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	leftPanel.BorderSizePixel = 0
	leftPanel.Parent = mainFrame
	
	local cornerLeft = Instance.new("UICorner")
	cornerLeft.CornerRadius = UDim.new(0, 8 * 1.5)
	cornerLeft.Parent = leftPanel
	
	local rightPanel = Instance.new("Frame")
	rightPanel.Size = UDim2.new(1, -210 * 1.5, 1, -35 * 1.5)
	rightPanel.Position = UDim2.new(0, 210 * 1.5, 0, 35 * 1.5)
	rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	rightPanel.BorderSizePixel = 0
	rightPanel.Parent = mainFrame
	
	local cornerRight = Instance.new("UICorner")
	cornerRight.CornerRadius = UDim.new(0, 8 * 1.5)
	cornerRight.Parent = rightPanel
	
	local contentContainer = Instance.new("ScrollingFrame")
	contentContainer.Size = UDim2.new(1, -10 * 1.5, 1, -10 * 1.5)
	contentContainer.Position = UDim2.new(0, 5 * 1.5, 0, 5 * 1.5)
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentContainer.ScrollBarThickness = 4 * 1.5
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = rightPanel
	
	local cornerContent = Instance.new("UICorner")
	cornerContent.CornerRadius = UDim.new(0, 6 * 1.5)
	cornerContent.Parent = contentContainer
	
	local menuItems = {}
	local function createMenuItem(name, icon)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Text = "  " .. (icon or "") .. "  " .. name
		btn.Size = UDim2.new(1, -10 * 1.5, 0, 35 * 1.5)
		btn.Position = UDim2.new(0, 5 * 1.5, 0, (#menuItems * (38 * 1.5)) + (5 * 1.5))
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		btn.TextColor3 = Color3.fromRGB(220, 220, 255)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 14 * 1.5
		btn.AutoButtonColor = true
		btn.Parent = leftPanel
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 6 * 1.5)
		corner.Parent = btn
		
		table.insert(menuItems, btn)
		return btn
	end

	local function clearContent()
		for _, child in ipairs(contentContainer:GetChildren()) do
			if child:IsA("GuiObject") then child:Destroy() end
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	end

	-- ВКЛАДКИ
	local function showFloors()
		clearContent()
		local title = Instance.new("TextLabel")
		title.Text = T("selectFloor")
		title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Color3.fromRGB(200, 200, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14 * 1.5
		title.Parent = contentContainer

		for i, data in ipairs(FLOORS) do
			local floorNum, name, placeId = unpack(data)
			local btn = Instance.new("TextButton")
			btn.Name = "Floor" .. floorNum
			btn.Text = string.format("Floor %d — %s", floorNum, name)
			btn.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
			btn.Position = UDim2.new(0, 5 * 1.5, 0, (30 * 1.5) + (i - 1) * (35 * 1.5))
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			btn.TextColor3 = Color3.fromRGB(240, 240, 255)
			btn.Font = Enum.Font.GothamSemibold
			btn.TextSize = 14 * 1.5
			btn.AutoButtonColor = true

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 6 * 1.5)
			corner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				local safePos = Vector3.new(0, 100, 0)
				flyTo(safePos, function()
					pcall(function()
						TeleportService:Teleport(placeId, player)
					end)
				end)
			end)
			btn.Parent = contentContainer
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, #FLOORS * (35 * 1.5) + (40 * 1.5))
	end

	local function showFarm()
		clearContent()
		local yOffset = 0

		local title = Instance.new("TextLabel")
		title.Text = T("farm") .. ":"
		title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Color3.fromRGB(200, 200, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14 * 1.5
		title.Parent = contentContainer
		yOffset += 30 * 1.5

		local selectMatBtn = Instance.new("TextButton")
		selectMatBtn.Text = T("selectMaterialBtn")
		selectMatBtn.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
		selectMatBtn.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		selectMatBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
		selectMatBtn.TextColor3 = Color3.fromRGB(240, 240, 255)
		selectMatBtn.Font = Enum.Font.GothamSemibold
		selectMatBtn.TextSize = 14 * 1.5
		selectMatBtn.Parent = contentContainer
		local cornerBtn = Instance.new("UICorner")
		cornerBtn.CornerRadius = UDim.new(0, 6 * 1.5)
		cornerBtn.Parent = selectMatBtn
		selectMatBtn.MouseButton1Click:Connect(createMaterialWindow)
		yOffset += 35 * 1.5

		local materialToggle, _ = createToggleSwitch(contentContainer, T("materialFarmToggle"), isMaterialFarming, function(enabled)
			if enabled then
				if not selectedMaterialType then
					player:SendChatMessage(T("noMaterialSelected"))
					return
				end
				startMaterialsFarm(selectedMaterialType)
			else
				stopMaterialsFarm()
			end
		end)
		materialToggle.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local questToggle, _ = createToggleSwitch(contentContainer, T("questFarmToggle"), isQuestFarming, function(enabled)
			if enabled then
				startQuestFarm()
			else
				stopQuestFarm()
			end
		end)
		questToggle.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		-- НОВЫЙ ТУМБЛЕР АВТО РЕЙДОВ
		local autoRaidToggleSwitch, _ = createToggleSwitch(contentContainer, T("autoRaidToggle"), isAutoRaiding, function(enabled)
			if enabled then
				startAutoRaid()
			else
				stopAutoRaid()
			end
		end)
		autoRaidToggleSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10 * 1.5)
	end

	local function showConvenience()
		clearContent()
		local title = Instance.new("TextLabel")
		title.Text = T("tools") .. ":"
		title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Color3.fromRGB(200, 200, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14 * 1.5
		title.Parent = contentContainer
		
		local yOffset = 30 * 1.5

		local freezeSwitch, _ = createToggleSwitch(contentContainer, T("freezeToggle"), isFrozen, function(enabled)
			isFrozen = enabled
			if enabled then
				freezePlayer()
			else
				unfreezePlayer()
			end
		end)
		freezeSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local pAtkSwitch, _ = createToggleSwitch(contentContainer, T("pAtkToggle"), playerAttackEnabled, function(enabled)
			playerAttackEnabled = enabled
		end)
		pAtkSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local mode1Switch, _ = createToggleSwitch(contentContainer, T("mode1Toggle"), flyingMode1Active, function(enabled)
			if enabled then
				startFlyingMode1()
			else
				stopFlyingMode1()
			end
		end)
		mode1Switch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local mode2Switch, _ = createToggleSwitch(contentContainer, T("mode2Toggle"), flyingMode2Active, function(enabled)
			if enabled then
				startFlyingMode2()
			else
				stopFlyingMode2()
			end
		end)
		mode2Switch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local aimSwitch, _ = createToggleSwitch(contentContainer, T("aimToggle"), aimbotActive, function(enabled)
			if enabled then
				startAimbot()
			else
				stopAimbot()
			end
		end)
		aimSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		local stickSwitch, _ = createToggleSwitch(contentContainer, T("stickToggle"), stickToPlayerActive, function(enabled)
			if enabled then
				startStickToPlayer()
			else
				stopStickToPlayer()
			end
		end)
		stickSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset += 35 * 1.5

		contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10 * 1.5)
	end

	-- МЕНЮ КНОПКИ
	local floorBtn = createMenuItem(T("floor"), "🌍")
	local farmBtn = createMenuItem(T("farm"), "⚔️")
	local toolsBtn = createMenuItem(T("tools"), "🛠️")

	local function selectButton(btn)
		for _, b in ipairs(menuItems) do
			b.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		end
		btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
	end

	floorBtn.MouseButton1Click:Connect(function()
		selectButton(floorBtn)
		showFloors()
	end)
	farmBtn.MouseButton1Click:Connect(function()
		selectButton(farmBtn)
		showFarm()
	end)
	toolsBtn.MouseButton1Click:Connect(function()
		selectButton(toolsBtn)
		showConvenience()
	end)

	selectButton(floorBtn)
	showFloors()

	if guiToggleConnection then
		guiToggleConnection:Disconnect()
	end
	guiToggleConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.G then
			if mainFrame.Visible then
				mainFrame.Visible = false
				minimizedFrame.Visible = true
			else
				mainFrame.Visible = true
				minimizedFrame.Visible = false
			end
		end
	end)
end

-- ЗАПУСК
rebuildGUI()
