local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === ДАННЫЕ УРОВНЕЙ И БОССОВ ===
local FLOORS = {
{1,   "Town Of Beginnings",       4733293382},
{2,   "Swordsman Fields",          4734865416},
{3,   "Swamp Lands",               4735703075},
{4,   "Desert Land",               4735718710},
{5,   "Icy Caverns",               4736649014},
{6,   "Hellfire Wasteland",        4736759720},
{7,   "Luminara Grove",            4736984932},
{8,   "Graves",                    4737916764},
{9,   "Tropical Sea",              4740039076},
{10,  "Sakura Serenity",           4747247314},
{11,  "Fallen Kingdom",            5135551944},
{12,  "The Flower Garden",         5212666689},
{13,  "Ghost Forest",              5136611550},
{14,  "Floating Islands",          4733293091},
{15,  "College Campus",            11987483716},
{16,  "Rulid Village",             11987539001},
{17,  "Candy Lands",               12632324801},
{18,  "Early Crownvein",           94066307314492},
{18,  "Early Crownvein: Arena",    117852524597461}
}

-- === BOSSES FOR TELEPORTS (UNCHANGED) ===
local BOSSES = {
[4734865416] = {
{"Shadesworn the Corrupted", 414, -1174, -461},
{"Illfang The Kobold Lord", -1003, 1928, -727}
},
[4735703075] = {
{"Mob farm: in pit", -352.25, -15.14, 1049.83},
{"Lord Slug", 988, 2500, 591}
},
[4735718710] = {
{"Mob farm: in front of the boss", 1271.97, 1197.97, 12748.28},
{"Stallord", 711, 1173, 12457}
},
[4736649014] = {
{"Mob farm: in a cave", -2295.05, 386.89, -1851.63},
{"X'rphan the White Wyrm", -1585, 404, -1702}
},
[4736759720] = {
{"Uakmaroth, the Demon Lord", -1622, 1931, -426}
},
[4736984932] = {
{"Storm Atronach", -5849, -368, 9330}
},
[4737916764] = {
{"Skeleton Swamp", 326, 74, -1396},
{"Bonnz the Skeleton Lord", 2998, -557, -1878}
},
[4740039076] = {
{"Guardian of the Gate", -2665, 879, 9127},
{"Karth'uk The Crystal Kraken", -2612, 32, 6763}
},
[4747247314] = {
{"Hotoke The Enlightened", -3985, -9927, -7179}
},
[5135551944] = {
{"Buffed Knight", -1619, 4, -5725},
{"Grimlock the Fallen King", -9471, -471, 1962}
},
[5212666689] = {
{"Laurellis Convict", 14968, 770, -705},
{"Slime Lord Pengonis", -1826, 1111, -9793}
},
[5136611550] = {
{"Tormented Spectrum", -94, 1404, 3187},
{"The Tormented Soul", -79, 2267, -114}
},
[4733293091] = {
{"Leader Grimm", 8128, 2685, 939},
{"Super Luo", 2355, 1716, 2364},
{"Elder Celatid", 1859, 1714, -2208},
{"Young Celestia", -1407, -1462, 1203}
},
[11987483716] = {
{"Raios, Sortiliena and Golgorosso", 458, 30, -1211}
},
[11987539001] = {
{"Leader Goblin", -1751, 181, 2608},
{"Two-Headed Giant and autofarm", 2742, 225, 7207}
},
[12632324801] = {
{"Captain Sweet the Forever Child", 2940, -815, -1949}
},
[94066307314492] = {
{"Mob Save Farm", -272.06, 7.42, 74.08},
{"Thug Boss", -1493, 6, 8},
{"Loan Shark Boss", -553.70, 1.49, -2088.94},
{"The Custodian", -989.97, -1472.43, 6025.40},
{"Eidolon the Gilded Omen", -352.27, 1043.52, 1549.13},
{"The Arbitrator", -498.26, -1503.60, 5515.60}
}
}

-- === BOSS FARMS ===
local BOSS_FARMS = {
[4734865416] = {
{"Illfang The Kobold Lord", Vector3.new(-972.62, 1933.95, -727.67)},
{"Shadesworn the Corrupted", Vector3.new(421.36, -1174.06, -467.49)}
},
[4735703075] = {
{"Lord Slug", Vector3.new(818.91, 2485.72, 601.92)}
},
[4735718710] = {
{"Stallord", Vector3.new(571.00, 1188.82, 12513.01)}
},
[4736649014] = {
{"X'rphan the White Wyrm", Vector3.new(-1695.54, 402.80, -1718.85)}
},
[4736759720] = {
{"Uakmaroth, the Demon Lord", Vector3.new(-1532.07, 1914.88, -384.36)}
},
[4736984932] = {
{"Storm Atronach", Vector3.new(-5823.41, -306.12, 9285.34)}
},
[4737916764] = {
{"Bonnz the Skeleton Lord", Vector3.new(2737.84, -548.03, -1699.97)}
},
[4740039076] = {
{"Guardian of the Gate", Vector3.new(-2666.33, 899.55, 9119.14)},
{"Karth'uk The Crystal Kraken", Vector3.new(-2549.95, 53.51, 6823.25)}
},
[4747247314] = {
{"Hotoke The Enlightened", Vector3.new(-3973.10, -9909.64, -7192.87)}
},
[5135551944] = {
{"Buffed Knight", Vector3.new(-1605.13, 38.42, -5727.90)},
{"Grimlock the Fallen King", Vector3.new(-9477.22, -474.34, 1983.57)}
},
[5212666689] = {
{"Laurellis Convict", Vector3.new(14969.86, 770.86, -708.19)},
{"Slime Lord Pengonis", Vector3.new(-1814.80, 1108.39, -9849.32)}
},
[5136611550] = {
{"Tormented Spectrum", Vector3.new(-94.10, 1404.62, 3186.31)},
{"The Tormented Soul", Vector3.new(-82.75, 2319.43, -97.59)}
},
[4733293091] = {
{"Leader Grimm", Vector3.new(8091.00, 2675.98, 678.44)},
{"Super Luo", Vector3.new(2451.71, 1746.34, 2114.21)},
{"Elder Celatid", Vector3.new(1833.24, 1762.81, -2241.65)},
{"Young Celestia", Vector3.new(-1555.34, -1322.91, 1577.24)}
},
[11987483716] = {
{"Raios, Sortiliena and Golgorosso", Vector3.new(458, 30, -1211)}
},
[11987539001] = {
{"Leader Goblin", Vector3.new(-1751, 181, 2608)},
{"Two-Headed Giant", Vector3.new(2742, 225, 7207)} -- убрано "and autofarm"
},
[12632324801] = {
{"Captain Sweet the Forever Child", Vector3.new(2940, -815, -1949)}
}
}

-- === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ===
local isFrozen = false
local freezePosition = nil
local freezeConnection = nil
local resurrectionActive = false
local resurrectionConnections = {}
local currentFarmMode = nil
local individualFreezeConnection = nil
local screenGui = nil
local indicator = nil

-- === ФУНКЦИИ ===
local function teleport(pos)
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(pos)
	end
end

local function freezePlayer()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local freezePos = hrp.CFrame
	if individualFreezeConnection then
		individualFreezeConnection:Disconnect()
	end
	individualFreezeConnection = RunService.RenderStepped:Connect(function()
		if hrp and hrp.Parent then
			hrp.CFrame = freezePos
		end
	end)
end

local function unfreezePlayer()
	if individualFreezeConnection then
		individualFreezeConnection:Disconnect()
		individualFreezeConnection = nil
	end
end

local function initGUI()
	if screenGui then return end
	screenGui = Instance.new("ScreenGui")
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")
	indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 40, 0, 40)
	indicator.Position = UDim2.new(0, 49, 0, 249)
	indicator.BackgroundColor3 = Color3.new(1, 0, 0)
	indicator.BorderSizePixel = 0
	indicator.BackgroundTransparency = 0
	indicator.Parent = screenGui
end

local function updateIndicator(isNear)
	if indicator then
		indicator.BackgroundColor3 = isNear and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
	end
end

local function findMobsFolder()
	local folder = Workspace:FindFirstChild("Mobs")
	if not folder then
		for _, child in ipairs(Workspace:GetDescendants()) do
			if child.Name == "Mobs" and child:IsA("Folder") then
				return child
			end
		end
	end
	return folder
end

-- === ГЛОБАЛЬНЫЙ ФРИЗ ===
local function toggleFreeze()
	isFrozen = not isFrozen
	if isFrozen then
		local character = player.Character
		if character then
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if hrp then
				freezePosition = hrp.CFrame
				if freezeConnection then freezeConnection:Disconnect() end
				freezeConnection = RunService.RenderStepped:Connect(function()
					if hrp and hrp.Parent then
						hrp.CFrame = freezePosition
					end
				end)
			else
				warn("HumanoidRootPart не найден для фриза!")
				isFrozen = false
			end
		else
			warn("Персонаж не загружен!")
			isFrozen = false
		end
	else
		if freezeConnection then
			freezeConnection:Disconnect()
			freezeConnection = nil
		end
	end
end

-- === ВОСКРЕШЕНИЕ ===
local function cleanupResurrection()
	for _, conn in ipairs(resurrectionConnections) do
		if conn and conn.Disconnect then
			conn:Disconnect()
		end
	end
	resurrectionConnections = {}
	resurrectionActive = false
end

local function setupResurrection()
	if resurrectionActive then return end
	cleanupResurrection()
	resurrectionActive = true
	local player = game:GetService("Players").LocalPlayer
	local runService = game:GetService("RunService")
	local function onCharacterAdded(character)
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		local lastPos = rootPart.Position
		local posConn = runService.Heartbeat:Connect(function()
			if rootPart and rootPart.Parent then
				lastPos = rootPart.Position
			end
		end)
		table.insert(resurrectionConnections, posConn)
		local diedConn = humanoid.Died:Connect(function()
			if posConn.Connected then
				posConn:Disconnect()
			end
			task.delay(5, function()
				local currentChar = player.Character
				if not currentChar then return end
				local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
				if currentRoot then
					currentRoot.CFrame = CFrame.new(lastPos)
				end
			end)
		end)
		table.insert(resurrectionConnections, diedConn)
		local ancestryConn = character.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if posConn.Connected then posConn:Disconnect() end
				if diedConn.Connected then diedConn:Disconnect() end
			end
		end)
		table.insert(resurrectionConnections, ancestryConn)
	end
	local charAddedConn = player.CharacterAdded:Connect(onCharacterAdded)
	table.insert(resurrectionConnections, charAddedConn)
	if player.Character then
		onCharacterAdded(player.Character)
	end
end

-- === ОБЩАЯ ФУНКЦИЯ ФАРМА ===
local function startGenericFarm(bossName, farmPos)
    currentFarmMode = bossName
    initGUI()
    updateIndicator(false)
    teleport(farmPos)
    wait(0.3)
    freezePlayer()

    spawn(function()
        local placeId = game.PlaceId
        local isFloor14 = (placeId == 4733293091)
        local isFloor13 = (placeId == 5136611550)

        while currentFarmMode == bossName do
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then break end

            local mobsFolder = findMobsFolder()
            local foundAny = false

            if mobsFolder then
                for _, mob in ipairs(mobsFolder:GetChildren()) do
                    if mob:IsA("Model") then
                        local torso = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("UpperTorso") or mob:FindFirstChild("Torso")
                        if torso and torso:IsA("BasePart") then
                            local shouldProcess = false

                            if isFloor14 then
                                -- ЦИЛИНДРИЧЕСКАЯ ЗОНА: радиус 15, высота вниз 40
                                local delta = torso.Position - farmPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = delta.Y  -- положительное = выше, отрицательное = ниже

                                if horizontalDist <= 20 and verticalDelta >= -40 and verticalDelta <= 0 then
                                    shouldProcess = true
                                end
                            else
                                -- СТАНДАРТНЫЙ РАДИУС
                                local searchRadius = isFloor13 and 50 or 30
                                if (torso.Position - farmPos).Magnitude <= searchRadius then
                                    shouldProcess = true
                                end
                            end

                            if shouldProcess then
                                foundAny = true
                                torso.Anchored = true
                                torso.CanCollide = false
                                local targetPos = hrp.Position + hrp.CFrame.LookVector * 5
                                torso.CFrame = CFrame.fromMatrix(targetPos, hrp.CFrame.RightVector, hrp.CFrame.UpVector, hrp.CFrame.LookVector)

                                if not isFloor14 then
                                    break
                                end
                            end
                        end
                    end
                end
            end

            updateIndicator(foundAny)

            if isFloor14 then
                wait(2.5)
            else
                wait(0.1)
            end
        end

        unfreezePlayer()
        updateIndicator(false)
    end)
end
local function stopAllFarms()
	currentFarmMode = nil
	unfreezePlayer()
	if indicator then
		updateIndicator(false)
	end
end

-- === GUI ===
local screenGuiMain = Instance.new("ScreenGui")
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
minimizedLabel.Text = "Pidromania Hub"
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

-- HEADER
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 35 * 1.5)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
header.BorderSizePixel = 0
header.Parent = mainFrame

local cornerHeader = Instance.new("UICorner")
cornerHeader.CornerRadius = UDim.new(0, 6 * 1.5)
cornerHeader.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Pidromania Hub: Sword Blox Online"
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
author.Text = "by @Pidromania"
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

-- ПАНЕЛИ
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

-- МЕНЮ
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

local floorBtn = createMenuItem("Floor", "🌍")
local teleportsBtn = createMenuItem("Teleports", "🌐")
local bossFarmBtn = createMenuItem("Boss Farm", "👹")
local materialFarmBtn = createMenuItem("Material Farm", "📦")
local toolsBtn = createMenuItem("Tools", "🛠️")

local function clearContent()
	for _, child in ipairs(contentContainer:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- FLOOR
local function showFloors()
	clearContent()
	local title = Instance.new("TextLabel")
	title.Text = "Выберите этаж:"
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
			pcall(function()
				TeleportService:Teleport(placeId, player)
			end)
		end)
		btn.Parent = contentContainer
	end
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, #FLOORS * (35 * 1.5) + (40 * 1.5))
end

-- TELEPORTS
local function showBosses()
	clearContent()
	local currentPlaceId = game.PlaceId
	local currentFloor = nil
	for _, floorData in ipairs(FLOORS) do
		if floorData[3] == currentPlaceId then
			currentFloor = floorData
			break
		end
	end
	if not currentFloor then
		local title = Instance.new("TextLabel")
		title.Text = "Ошибка: неизвестный этаж"
		title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Color3.fromRGB(255, 100, 100)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14 * 1.5
		title.Parent = contentContainer
		return
	end
	local bosses = BOSSES[currentPlaceId]
	if not bosses or #bosses == 0 then
		local title = Instance.new("TextLabel")
		title.Text = "На этом этаже нет боссов"
		title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		title.BackgroundTransparency = 1
		title.TextColor3 = Color3.fromRGB(200, 200, 255)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 14 * 1.5
		title.Parent = contentContainer
		return
	end
	local headerLabel = Instance.new("TextLabel")
	headerLabel.Text = "Боссы этажа " .. currentFloor[1] .. " (" .. currentFloor[2] .. "):"
	headerLabel.Size = UDim2.new(1, 0, 0, 25 * 1.5)
	headerLabel.BackgroundTransparency = 1
	headerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	headerLabel.Font = Enum.Font.GothamBold
	headerLabel.TextSize = 14 * 1.5
	headerLabel.Parent = contentContainer
	for i, boss in ipairs(bosses) do
		local name, x, y, z = unpack(boss)
		local btn = Instance.new("TextButton")
		btn.Name = "Boss" .. i
		btn.Text = name
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
			if player.Character then
				local hrp = player.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					hrp.CFrame = CFrame.new(x, y, z)
				else
					warn("HumanoidRootPart не найден!")
				end
			else
				warn("Персонаж не существует!")
			end
		end)
		btn.Parent = contentContainer
	end
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, #bosses * (35 * 1.5) + (40 * 1.5))
end

-- BOSS FARM
local function showBossFarms()
	clearContent()
	local currentPlaceId = game.PlaceId
	local farms = BOSS_FARMS[currentPlaceId]
	local title = Instance.new("TextLabel")
	title.Text = "Boss Farms:"
	title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(200, 200, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14 * 1.5
	title.Parent = contentContainer
	if not farms or #farms == 0 then
		local noBossLabel = Instance.new("TextLabel")
		noBossLabel.Text = "Нет доступных фармов на этом этаже"
		noBossLabel.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		noBossLabel.BackgroundTransparency = 1
		noBossLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
		noBossLabel.Font = Enum.Font.GothamSemibold
		noBossLabel.TextSize = 14 * 1.5
		noBossLabel.Position = UDim2.new(0, 0, 0, 30 * 1.5)
		noBossLabel.Parent = contentContainer
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, 60 * 1.5)
		return
	end
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
	local yOffset = 30 * 1.5
	for _, farmData in ipairs(farms) do
		local bossName, farmPos = unpack(farmData)
		local isActive = (currentFarmMode == bossName)
		local switchFrame, setState = createToggleSwitch(contentContainer, "Farm: " .. bossName, isActive, function(enabled)
			stopAllFarms()
			if enabled then
				startGenericFarm(bossName, farmPos)
			else
				currentFarmMode = nil
			end
		end)
		switchFrame.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
		yOffset = yOffset + 35 * 1.5
	end
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- MATERIAL FARM
local materialFarmActive = false
local function startMaterialFarm()
	if materialFarmActive then return end
	materialFarmActive = true
	spawn(function()
		while materialFarmActive do
			pcall(function()
				local RepStor = game:GetService("ReplicatedStorage")
				local Materials = workspace:FindFirstChild("Materials")
				if Materials and RepStor:FindFirstChild("ClaimMaterial") then
					for _, material in ipairs(Materials:GetChildren()) do
						if material:IsA("Model") and material:FindFirstChild("Owner") and material:FindFirstChild("Id") then
							if material.Owner.Value == "" then
								RepStor.ClaimMaterial:InvokeServer(material.Id.Value)
								task.wait(0.5)
							end
						end
					end
				end
			end)
			task.wait(7)
		end
	end)
end
local function stopMaterialFarm()
	materialFarmActive = false
end
local function showMaterialFarm()
	clearContent()
	local title = Instance.new("TextLabel")
	title.Text = "Material Farm"
	title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(200, 200, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14 * 1.5
	title.Parent = contentContainer
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
	local toggleFrame, _ = createToggleSwitch(
		contentContainer,
		"Автофарм всех материалов",
		materialFarmActive,
		function(enabled)
			if enabled then
				startMaterialFarm()
			else
				stopMaterialFarm()
			end
		end
	)
	toggleFrame.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5)
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 70 * 1.5)
end

-- TOOLS
local function showConvenience()
	clearContent()
	local title = Instance.new("TextLabel")
	title.Text = "Tools:"
	title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(200, 200, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14 * 1.5
	title.Parent = contentContainer
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
	local freezeSwitch, setFreezeState = createToggleSwitch(contentContainer, "Фриз игрока на месте", isFrozen, function(enabled)
		if enabled then
			toggleFreeze()
		else
			toggleFreeze()
		end
	end)
	freezeSwitch.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5)
	local resSwitch, setResState = createToggleSwitch(contentContainer, "Воскрешение на месте смерти", resurrectionActive, function(enabled)
		if enabled then
			setupResurrection()
		else
			cleanupResurrection()
		end
	end)
	resSwitch.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5 + 35 * 1.5)
	local autofarmSwitch, setAutofarmState = createToggleSwitch(contentContainer, "Автобосс-фарм", false, function(enabled)
		if enabled then
			warn("Старый автобосс временно отключен. Используйте новые фармы.")
			setAutofarmState(false)
		end
	end)
	autofarmSwitch.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5 + 35 * 1.5 + 35 * 1.5)
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 30 * 1.5 + 35 * 1.5 * 3)
end

-- ВЫБОР ВКЛАДКИ
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
teleportsBtn.MouseButton1Click:Connect(function()
	selectButton(teleportsBtn)
	showBosses()
end)
bossFarmBtn.MouseButton1Click:Connect(function()
	selectButton(bossFarmBtn)
	showBossFarms()
end)
materialFarmBtn.MouseButton1Click:Connect(function()
	selectButton(materialFarmBtn)
	showMaterialFarm()
end)
toolsBtn.MouseButton1Click:Connect(function()
	selectButton(toolsBtn)
	showConvenience()
end)

selectButton(floorBtn)
showFloors()

-- Горячая клавиша G
UserInputService.InputBegan:Connect(function(input, gameProcessed)
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

-- ==================================================
-- ESP С ИМЕНЕМ И УРОВНЕМ
-- ==================================================
local Camera = Workspace.CurrentCamera
if not Camera then
	Camera = Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
	Camera = Workspace.CurrentCamera
end
local LocalPlayer = Players.LocalPlayer
local EspObjects = {}

local function removeEsp(player)
	if EspObjects[player] then
		for _, obj in pairs(EspObjects[player]) do
			if obj and obj.Destroy then
				obj:Destroy()
			end
		end
		EspObjects[player] = nil
	end
end

local function toScreen(point)
	local pos, onScreen = Camera:WorldToViewportPoint(point)
	return Vector2.new(pos.X, pos.Y), onScreen
end

local function getPlayerLevel(player)
	local stats = player:FindFirstChild("PlayerStats")
	if stats then
		local levelObj = stats:FindFirstChild("Level")
		if levelObj and (levelObj:IsA("IntValue") or levelObj:IsA("NumberValue")) then
			return levelObj.Value
		elseif levelObj and levelObj:IsA("StringValue") and tonumber(levelObj.Value) then
			return tonumber(levelObj.Value)
		end
	end
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local lvl = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("lvl") or leaderstats:FindFirstChild("level")
		if lvl and (lvl:IsA("IntValue") or lvl:IsA("NumberValue")) then
			return lvl.Value
		elseif lvl and lvl:IsA("StringValue") and tonumber(lvl.Value) then
			return tonumber(lvl.Value)
		end
	end
	local attr = player:GetAttribute("Level")
	if type(attr) == "number" then
		return attr
	elseif type(attr) == "string" and tonumber(attr) then
		return tonumber(attr)
	end
	return "?"
end

local function updateEsp(player)
	if player == LocalPlayer or not player.Character then return end
	local character = player.Character
	local head = character:FindFirstChild("Head")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not head or not rootPart then return end
	local headPos, headVisible = toScreen(head.Position)
	local rootPos, rootVisible = toScreen(rootPart.Position)
	if not (headVisible and rootVisible) then
		if EspObjects[player] then
			for _, obj in pairs(EspObjects[player]) do
				if obj then obj.Visible = false end
			end
		end
		return
	end
	local footOffset = Vector3.new(0, -3, 0)
	local feetWorld = rootPart.Position + footOffset
	local feetPos, _ = toScreen(feetWorld)
	local fullHeight = math.abs(headPos.Y - feetPos.Y)
	local scaledHeight = fullHeight * 1.5
	local width = scaledHeight * 0.6
	local centerY = (headPos.Y + feetPos.Y) / 2
	local boxY = centerY - scaledHeight / 2
	local boxX = headPos.X - width / 2
	if not EspObjects[player] then
		local box = Drawing.new("Square")
		box.Color = Color3.fromRGB(255, 0, 0)
		box.Thickness = 2
		box.Filled = false
		local nameText = Drawing.new("Text")
		nameText.Color = Color3.fromRGB(255, 255, 255)
		nameText.Outline = true
		nameText.Center = true
		nameText.Size = 20
		local levelText = Drawing.new("Text")
		levelText.Color = Color3.fromRGB(0, 255, 255)
		levelText.Outline = true
		levelText.Center = true
		levelText.Size = 18
		EspObjects[player] = { box = box, name = nameText, level = levelText }
	end
	local esp = EspObjects[player]
	esp.box.Size = Vector2.new(width, scaledHeight)
	esp.box.Position = Vector2.new(boxX, boxY)
	esp.box.Visible = true
	esp.name.Text = player.Name
	esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
	esp.name.Visible = true
	if player.Name == "ArRoWeNn" then
		esp.level.Text = "Lvl: Immortal"
		esp.level.Color = Color3.fromRGB(255, 215, 0)
		esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
		esp.level.Visible = true
	else
		local level = getPlayerLevel(player)
		esp.level.Text = "Lvl: " .. tostring(level)
		esp.level.Color = Color3.fromRGB(0, 255, 255)
		esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
		esp.level.Visible = true
	end
end

Players.PlayerRemoving:Connect(removeEsp)
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		spawn(function()
			while player and player.Character do
				updateEsp(player)
				RunService.RenderStepped:Wait()
			end
		end)
	end
end

Players.PlayerAdded:Connect(function(player)
	if player == LocalPlayer then return end
	spawn(function()
		while player and player.Character do
			updateEsp(player)
			RunService.RenderStepped:Wait()
		end
	end)
end)

RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		updateEsp(player)
	end
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		removeEsp(player)
	end
	if freezeConnection then
		freezeConnection:Disconnect()
	end
	if individualFreezeConnection then
		individualFreezeConnection:Disconnect()
	end
	cleanupResurrection()
end)
