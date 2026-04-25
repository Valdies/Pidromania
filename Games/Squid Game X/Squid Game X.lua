local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ==============================================================================
-- === ЛОКАЛИЗАЦИЯ ===
-- ==============================================================================
local currentLang = "ru"
local translations = {
	ru = { 
		hubTitle = "Pidromania Hub: Squid Game X", 
		byAuthor = "by @Pidromania", 
		teleports = "Телепорты", 
		settings = "Настройки", 
		utilities = "Полезности",
		languageLabel = "Язык интерфейса:", 
		lang_ru = "Русский", 
		lang_uk = "Українська", 
		lang_kk = "Қазақ", 
		lang_en = "English (US)",
		exitDoorLabel = "Показать выход (ExitDoor)",
		guardCamLabel = "Камера на Guard",
		cloneBridgeLabel = "Создать клонов на мосту",
		teleportPlayersLabel = "Заморозить игроков у себя",
		winGlassLabel = "🏆 Победа в стекле",
		takeBabyLabel = "Взять ребенка (Спам)",
		tugOfWarLabel = "Канатка (Спам)"
	},
	uk = { 
		hubTitle = "Pidromania Hub: Squid Game X", 
		byAuthor = "by @Pidromania", 
		teleports = "Телепорти", 
		settings = "Налаштування", 
		utilities = "Корисності",
		languageLabel = "Мова інтерфейсу:", 
		lang_ru = "Російська", 
		lang_uk = "Українська", 
		lang_kk = "Қазақ", 
		lang_en = "English (US)",
		exitDoorLabel = "Показати вихід (ExitDoor)",
		guardCamLabel = "Камера на Guard",
		cloneBridgeLabel = "Створити клонів на мосту",
		teleportPlayersLabel = "Заморозити гравців біля себе",
		winGlassLabel = "🏆 Перемога у склі",
		takeBabyLabel = "Взяти дитину (Спам)",
		tugOfWarLabel = "Перетягування каната (Спам)"
	},
	kk = { 
		hubTitle = "Pidromania Hub: Squid Game X", 
		byAuthor = "by @Pidromania", 
		teleports = "Телепорттар", 
		settings = "Параметрлер", 
		utilities = "Құралдар",
		languageLabel = "Интерфейс тілі:", 
		lang_ru = "Орыс", 
		lang_uk = "Украин", 
		lang_kk = "Қазақ", 
		lang_en = "Ағылшын (АҚШ)",
		exitDoorLabel = "Шығуды көрсету (ExitDoor)",
		guardCamLabel = "Камера Guard",
		cloneBridgeLabel = "Көпірде клондар жасау",
		teleportPlayersLabel = "Ойыншыларды қатыру",
		winGlassLabel = "🏆 Әйнекте жеңіс",
		takeBabyLabel = "Баланы алу (Спам)",
		tugOfWarLabel = "Арқан тарту (Спам)"
	},
	en = { 
		hubTitle = "Pidromania Hub: Squid Game X", 
		byAuthor = "by @Pidromania", 
		teleports = "Teleports", 
		settings = "Settings", 
		utilities = "Utilities",
		languageLabel = "Interface language:", 
		lang_ru = "Russian", 
		lang_uk = "Ukrainian", 
		lang_kk = "Қазақ", 
		lang_en = "English (US)",
		exitDoorLabel = "Show Exit (ExitDoor)",
		guardCamLabel = "Camera on Guard",
		cloneBridgeLabel = "Spawn Clones on Bridge",
		teleportPlayersLabel = "Freeze Players Near Me",
		winGlassLabel = "🏆 Win Glass",
		takeBabyLabel = "Take Baby (Spam)",
		tugOfWarLabel = "Tug of War (Spam)"
	}
}

local function T(key) 
	return translations[currentLang][key] or ("???" .. key .. "???") 
end

-- ==============================================================================
-- === КООРДИНАТЫ ===
-- ==============================================================================
local CUSTOM_TELEPORTS = {
	{"🎮 Комната фронтмэна", 7944.32, 120.69, 3618.20},
	{"Скакалка", -56.06, 119.97, 3.07},
	{"🛡️ Безопасная зона (Прятки)", -622.17, 183.55, 399.09},
	{"Стекло", 1280.30, 102.11, -955.72},
	{"🍽️ Безопасная зона (Ужин)", 8162.46, 48.53, 23396.95},
	{"Лодки", -2799.48, -785.78, 15508.45}
}

local function teleport(x, y, z)
	local char = player.Character
	if char and char:FindFirstChild("HumanoidRootPart") then
		char.HumanoidRootPart.CFrame = CFrame.new(x, y, z)
	end
end

-- ==============================================================================
-- === 🔥 СПЕЦИАЛЬНЫЕ ИГРОКИ ===
-- ==============================================================================
local SPECIAL_PLAYERS = {
	["luken_god"] = {
		text = "Даже тут у него 12000 LvL",
		color = Color3.fromRGB(0, 255, 0),
		nickColor = Color3.fromRGB(0, 255, 0)
	},
	["curlycheburashka"] = {
		text = "Викуля Красотуля",
		color = Color3.fromRGB(255, 105, 180),
		nickColor = Color3.fromRGB(255, 105, 180)
	},
	["82lena28"] = {
		text = "Pidromania Dev",
		color = Color3.fromRGB(30, 144, 255),
		nickColor = Color3.fromRGB(30, 144, 255)
	},
	["arrowennos"] = {  -- 🔥 НОВАЯ ЗАПИСЬ ДЛЯ ЭРОВЕНА
		text = "AlHiMiK",
		color = Color3.fromRGB(0, 100, 0), 
		nickColor = Color3.fromRGB(0, 100, 0)
	}
}

-- ==============================================================================
-- === 👥 СПИСОК ДРУЗЕЙ ===
-- ==============================================================================
local FRIENDS_LIST = {
	["luken_god"] = true,
	["curlycheburashka"] = true,
	["82lena28"] = true,
	["arrowennos"] = true,
	["danil7082d"] = true, 
	["minikokosich"] = true
}

local function isFriend(playerName)
	return FRIENDS_LIST[string.lower(playerName)] == true
end

-- ==============================================================================
-- === 🔥 ЗАМОРОЗКА ИГРОКОВ (ТЕЛЕПОРТ + ФИКСАЦИЯ) ===
-- ==============================================================================
local freezePlayersEnabled = false
local freezePlayersConnection = nil
local frozenPlayers = {} -- 🔥 Храним позиции замороженных игроков

local function freezeAllPlayers()
	if freezePlayersEnabled then return end
	
	freezePlayersEnabled = true
	frozenPlayers = {}
	
	local localChar = player.Character
	if not localChar then return end
	local localRoot = localChar:FindFirstChild("HumanoidRootPart")
	if not localRoot then return end
	
	local localPos = localRoot.Position
	
	-- 🔥 Телепортируем всех врагов к себе и запоминаем их позиции
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			if isFriend(plr.Name) then
				continue
			end
			
			local char = plr.Character
			if char then
				local root = char:FindFirstChild("HumanoidRootPart")
				if root then
					-- Телепортируем с небольшим смещением, чтобы не застревали
					local offset = Vector3.new(0, 0, 3)
					local freezePos = localPos + offset
					root.CFrame = CFrame.new(freezePos)
					
					-- 🔥 Запоминаем позицию заморозки для этого игрока
					frozenPlayers[plr] = freezePos
				end
			end
		end
	end
	
	-- 🔥 Постоянно держим их на зафиксированной позиции
	freezePlayersConnection = RunService.RenderStepped:Connect(function()
		for plr, freezePos in pairs(frozenPlayers) do
			if plr and plr.Character then
				local root = plr.Character:FindFirstChild("HumanoidRootPart")
				if root then
					-- 🔥 Держим их замороженными в точке телепорта (не у тебя!)
					root.CFrame = CFrame.new(freezePos)
				end
			end
		end
	end)
end

local function unfreezeAllPlayers()
	if not freezePlayersEnabled then return end
	
	if freezePlayersConnection then
		freezePlayersConnection:Disconnect()
		freezePlayersConnection = nil
	end
	
	frozenPlayers = {}
	freezePlayersEnabled = false
end

local function toggleFreezePlayers(enabled)
	if enabled then
		freezeAllPlayers()
	else
		unfreezeAllPlayers()
	end
end

-- ==============================================================================
-- === КЛОН НА МОСТУ ===
-- ==============================================================================
local MY_USER_ID = 1923012479
local bridgeCloneModels = {}
local cloneCleanupScheduled = false

local bridgePositions = {
    Vector3.new(1276, 100.6, -1071),
    Vector3.new(1286, 100.6, -1071),
    Vector3.new(1276, 100.6, -1061),
    Vector3.new(1286, 100.6, -1061),
    Vector3.new(1276, 100.6, -1051),
    Vector3.new(1286, 100.6, -1051),
    Vector3.new(1276, 100.6, -1041),
    Vector3.new(1286, 100.6, -1041),
    Vector3.new(1276, 100.6, -1031),
    Vector3.new(1286, 100.6, -1031),
    Vector3.new(1276, 100.6, -1021),
    Vector3.new(1286, 100.6, -1021),
    Vector3.new(1276, 100.6, -1011),
    Vector3.new(1286, 100.6, -1011),
    Vector3.new(1276, 100.6, -1001),
    Vector3.new(1286, 100.6, -1001),
    Vector3.new(1276, 100.6, -991),
    Vector3.new(1286, 100.6, -991),
    Vector3.new(1276, 100.6, -981),
    Vector3.new(1286, 100.6, -981),
}

local function spawnBridgeClone(position, index)
    local success, model = pcall(function()
        return Players:CreateHumanoidModelFromUserId(MY_USER_ID)
    end)
    
    if not success or not model then
        return false
    end
    
    model.Name = "82Lena28_Bridge_" .. index
    model.Parent = Workspace
    
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        rootPart = model:FindFirstChild("Torso")
    end
    if not rootPart then
        for _, v in ipairs(model:GetChildren()) do
            if v:IsA("BasePart") then
                rootPart = v
                break
            end
        end
    end
    
    if not rootPart then
        model:Destroy()
        return false
    end
    
    model.PrimaryPart = rootPart
    rootPart.CFrame = CFrame.new(position.X, position.Y + 2, position.Z)
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineTransparency = 0
    highlight.FillTransparency = 0.5
    highlight.Adornee = model
    highlight.Parent = model
    
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    for _, item in ipairs(model:GetChildren()) do
        if item:IsA("Tool") then item:Destroy() end
    end
    
    table.insert(bridgeCloneModels, model)
    
    return true
end

local function cleanupBridgeClones()
    for i, model in ipairs(bridgeCloneModels) do
        if model and model.Parent then
            model:Destroy()
        end
    end
    bridgeCloneModels = {}
end

local function spawnAllBridgeClones()
    if #bridgeCloneModels > 0 then
        cleanupBridgeClones()
        task.wait(0.5)
    end
    
    local startTime = tick()
    local successCount = 0
    
    for index, position in ipairs(bridgePositions) do
        if spawnBridgeClone(position, index) then
            successCount += 1
        end
        task.wait(0.05)
    end
    
    local endTime = tick()
    local duration = math.round((endTime - startTime) * 100) / 100
    
    if not cloneCleanupScheduled then
        cloneCleanupScheduled = true
        task.delay(120, function()
            cleanupBridgeClones()
            cloneCleanupScheduled = false
        end)
    end
end

-- ==============================================================================
-- === ESP ИГРОКОВ + HIGHLIGHT ===
-- ==============================================================================
local Camera = workspace.CurrentCamera
local EspObjects = {}
local PlayerHighlights = {}

local function toScreen(pos)
	if not Camera then return Vector2.new(0,0), false end
	local vp, on = Camera:WorldToViewportPoint(pos)
	return Vector2.new(vp.X, vp.Y), on
end

local function createEspObjects()
	local esp = {
		box = Drawing.new("Square"),
		name = Drawing.new("Text"),
		customLabel = Drawing.new("Text"),
		healthBarBg = Drawing.new("Square"),
		healthBar = Drawing.new("Square")
	}

	esp.box.Color = Color3.fromRGB(255, 0, 0)
	esp.box.Thickness = 3
	esp.box.Filled = false
	esp.box.Visible = false

	esp.name.Color = Color3.fromRGB(255, 255, 255)
	esp.name.Outline = true
	esp.name.OutlineColor = Color3.fromRGB(0, 0, 0)
	esp.name.Center = true
	esp.name.Size = 24
	esp.name.Font = 2
	esp.name.Visible = false

	esp.customLabel.Color = Color3.fromRGB(255, 255, 255)
	esp.customLabel.Outline = true
	esp.customLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
	esp.customLabel.Center = true
	esp.customLabel.Size = 27
	esp.customLabel.Font = 2
	esp.customLabel.Visible = false
	esp.customLabel.Text = ""

	esp.healthBarBg.Color = Color3.fromRGB(40, 40, 40)
	esp.healthBarBg.Filled = true
	esp.healthBarBg.Thickness = 0
	esp.healthBarBg.Visible = false

	esp.healthBar.Color = Color3.fromRGB(0, 255, 0)
	esp.healthBar.Filled = true
	esp.healthBar.Thickness = 0
	esp.healthBar.Visible = false

	return esp
end

local function updatePlayerHighlight(plr, specialData)
	if not plr.Character then return end
	
	local oldHighlight = PlayerHighlights[plr]
	if oldHighlight and (not oldHighlight.Parent or not oldHighlight.Adornee or oldHighlight.Adornee ~= plr.Character) then
		PlayerHighlights[plr] = nil
		oldHighlight = nil
	end
	
	if PlayerHighlights[plr] then
		local highlight = PlayerHighlights[plr]
		if highlight and highlight.Parent then
			highlight.OutlineColor = specialData.color
			highlight.FillColor = specialData.color
			return
		end
	end
	
	local highlight = Instance.new("Highlight")
	highlight.OutlineColor = specialData.color
	highlight.FillColor = specialData.color
	highlight.OutlineTransparency = 0
	highlight.FillTransparency = 0.7
	highlight.Adornee = plr.Character
	highlight.Parent = plr.Character
	
	PlayerHighlights[plr] = highlight
end

local function removePlayerHighlight(plr)
	if PlayerHighlights[plr] then
		local highlight = PlayerHighlights[plr]
		if highlight and highlight.Parent then
			highlight:Destroy()
		end
		PlayerHighlights[plr] = nil
	end
end

local function updateEsp(plr)
	if plr == player then return end
	if not plr.Character then return end
	
	local head = plr.Character:FindFirstChild("Head")
	local root = plr.Character:FindFirstChild("HumanoidRootPart")
	local humanoid = plr.Character:FindFirstChild("Humanoid")
	
	if not head or not root or not humanoid then return end
	
	local headPos, headVis = toScreen(head.Position)
	local rootPos, rootVis = toScreen(root.Position)
	
	local playerNameLower = string.lower(plr.Name)
	local specialData = SPECIAL_PLAYERS[playerNameLower]
	
	if EspObjects[plr] then
		if specialData then
			EspObjects[plr].name.Color = specialData.nickColor
		else
			EspObjects[plr].name.Color = Color3.fromRGB(255, 255, 255)
		end
	end
	
	if not (headVis and rootVis) then
		if EspObjects[plr] then
			EspObjects[plr].box.Visible = false
			EspObjects[plr].name.Visible = false
			EspObjects[plr].customLabel.Visible = false
			EspObjects[plr].healthBar.Visible = false
			EspObjects[plr].healthBarBg.Visible = false
		end
		return
	end
	
	if not EspObjects[plr] then
		EspObjects[plr] = createEspObjects()
	end
	
	local esp = EspObjects[plr]
	
	esp.box.Color = specialData and specialData.color or Color3.fromRGB(255, 0, 0)
	esp.name.Color = specialData and specialData.nickColor or Color3.fromRGB(255, 255, 255)
	esp.name.Size = 24
	esp.healthBar.Color = humanoid.Health < humanoid.MaxHealth * 0.3 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 0)

	local baseHeight = math.abs(headPos.Y - rootPos.Y)
	local height = baseHeight * 2.8 
	local width = height * 0.65
	local topLeft = Vector2.new(headPos.X - width/2, headPos.Y - (height * 0.15))
	
	esp.box.Size = Vector2.new(width, height)
	esp.box.Position = topLeft
	
	esp.name.Text = plr.Name
	esp.name.Position = Vector2.new(headPos.X, headPos.Y - 30) 
	
	if specialData then
		esp.box.Visible = false
		esp.name.Visible = false
		esp.healthBar.Visible = false
		esp.healthBarBg.Visible = false
		
		esp.customLabel.Text = specialData.text
		esp.customLabel.Color = specialData.color
		esp.customLabel.Position = Vector2.new(headPos.X, headPos.Y - 55)
		esp.customLabel.Visible = true
	else
		esp.box.Visible = true
		esp.name.Visible = true
		esp.healthBar.Visible = true
		esp.healthBarBg.Visible = true
		esp.customLabel.Visible = false
		esp.customLabel.Text = ""
	end
	
	local hpPercent = humanoid.Health / humanoid.MaxHealth
	local barWidth = width * 0.9 
	local barHeight = 6 
	local barX = headPos.X - (barWidth / 2)
	local barY = headPos.Y - 8 
	
	esp.healthBarBg.Size = Vector2.new(barWidth, barHeight)
	esp.healthBarBg.Position = Vector2.new(barX, barY)
	
	esp.healthBar.Size = Vector2.new(barWidth * hpPercent, barHeight)
	esp.healthBar.Position = Vector2.new(barX, barY)
end

local function cleanupEsp(plr)
	if EspObjects[plr] then
		for _, obj in pairs(EspObjects[plr]) do
			if obj.Remove then obj:Remove() end
		end
		EspObjects[plr] = nil
	end
	removePlayerHighlight(plr)
end

local function connectCharacterHighlight(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(0.5)
		local playerNameLower = string.lower(plr.Name)
		local specialData = SPECIAL_PLAYERS[playerNameLower]
		if specialData then
			updatePlayerHighlight(plr, specialData)
		end
	end)
	
	if plr.Character then
		local playerNameLower = string.lower(plr.Name)
		local specialData = SPECIAL_PLAYERS[playerNameLower]
		if specialData then
			updatePlayerHighlight(plr, specialData)
		end
	end
end

spawn(function()
	while not workspace.CurrentCamera do task.wait() end
	Camera = workspace.CurrentCamera
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			EspObjects[plr] = createEspObjects()
			connectCharacterHighlight(plr)
		end
	end
	
	Players.PlayerAdded:Connect(function(plr)
		if plr ~= player then
			task.wait(0.1)
			if plr.Character then 
				EspObjects[plr] = createEspObjects() 
			end
			connectCharacterHighlight(plr)
		end
	end)
	
	Players.PlayerRemoving:Connect(cleanupEsp)
	
	while true do
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then 
				updateEsp(plr) 
			end
		end
		RunService.RenderStepped:Wait()
	end
end)

-- ==============================================================================
-- === ESP ВЫХОДА ===
-- ==============================================================================
local exitDoorESPEnabled = false
local exitDoorConnection = nil
local exitDoorDrawings = {}

local function findExitDoors()
    local foundDoors = {}
    local hideSeekFolder = Workspace:FindFirstChild("Map") 
        and Workspace.Map:FindFirstChild("HideNSeek") 
        and Workspace.Map.HideNSeek:FindFirstChild("Elements")
        
    if not hideSeekFolder then
        hideSeekFolder = Workspace
    end

    for _, obj in ipairs(hideSeekFolder:GetDescendants()) do
        if obj.Name == "ExitDoor" then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then
                table.insert(foundDoors, {model = obj, part = part})
            end
        end
    end
    return foundDoors
end

local function clearExitDoorESP()
    if exitDoorConnection then 
        exitDoorConnection:Disconnect() 
        exitDoorConnection = nil 
    end
    for _, espData in pairs(exitDoorDrawings) do
        if espData.box and espData.box.Remove then espData.box:Remove() end
        if espData.label and espData.label.Remove then espData.label:Remove() end
    end
    exitDoorDrawings = {}
end

local function toggleExitDoorESP(enabled)
    if enabled == exitDoorESPEnabled then return end
    
    if enabled then
        clearExitDoorESP()
        
        local exitDoors = findExitDoors()
        if #exitDoors == 0 then
            return
        end

        for i, data in ipairs(exitDoors) do
            local doorModel = data.model
            local doorPart = data.part
            
            local box = Drawing.new("Square")
            box.Color = Color3.fromRGB(0, 255, 0) 
            box.Thickness = 4
            box.Filled = false
            box.Visible = false
            
            local label = Drawing.new("Text")
            label.Text = "EXIT #" .. i
            label.Size = 24
            label.Color = Color3.fromRGB(50, 255, 50)
            label.Outline = true
            label.OutlineColor = Color3.fromRGB(0, 0, 0)
            label.Center = true
            label.Visible = false
            
            table.insert(exitDoorDrawings, {
                model = doorModel,
                part = doorPart,
                box = box,
                label = label
            })
        end
        
        exitDoorConnection = RunService.RenderStepped:Connect(function()
            if not Camera then Camera = workspace.CurrentCamera end
            if not Camera then return end
            
            for _, esp in ipairs(exitDoorDrawings) do
                if not esp.part or not esp.part.Parent then
                    esp.box.Visible = false
                    esp.label.Visible = false
                    continue
                end
                
                local pos = esp.part.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
                
                if onScreen then
                    local distance = (Camera.CFrame.Position - pos).Magnitude
                    local size = math.clamp(7000 / distance, 60, 500) 
                    
                    esp.box.Position = Vector2.new(screenPos.X - size/2, screenPos.Y - size/2)
                    esp.box.Size = Vector2.new(size, size)
                    esp.box.Visible = true
                    
                    esp.label.Position = Vector2.new(screenPos.X, screenPos.Y - size/2 - 30)
                    esp.label.Visible = true
                else
                    esp.box.Visible = false
                    esp.label.Visible = false
                end
            end
        end)
        
        exitDoorESPEnabled = true
    else
        clearExitDoorESP()
        exitDoorESPEnabled = false
    end
end

-- ==============================================================================
-- === 🔥 КАМЕРА НА GUARD ===
-- ==============================================================================
local guardCamEnabled = false
local guardCamConnection = nil
local guardLine = nil

local function getPlayerTeam(plr)
    local team = plr.Team
    if team then
        return team.Name
    end
    return nil
end

local function findNearestGuard()
    local nearestGuard = nil
    local nearestDistance = math.huge
    local localCharacter = player.Character
    
    if not localCharacter then return nil end
    
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return nil end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local teamName = getPlayerTeam(plr)
            if teamName == "Guard" then
                local character = plr.Character
                if character then
                    local root = character:FindFirstChild("HumanoidRootPart")
                    if root then
                        local distance = (localRoot.Position - root.Position).Magnitude
                        if distance < nearestDistance then
                            nearestDistance = distance
                            nearestGuard = plr
                        end
                    end
                end
            end
        end
    end
    
    return nearestGuard
end

local function updateGuardCamera()
    local guard = findNearestGuard()
    local localCharacter = player.Character
    
    if not localCharacter then return end
    local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    if not Camera then Camera = workspace.CurrentCamera end
    if not Camera then return end
    
    if guard and guard.Character then
        local guardRoot = guard.Character:FindFirstChild("HumanoidRootPart")
        if guardRoot then
            local offset = Vector3.new(0, 2, 0)
            Camera.CFrame = CFrame.lookAt(localRoot.Position + offset, guardRoot.Position + offset)
            
            local lookDirection = (guardRoot.Position - localRoot.Position).Unit
            local targetCFrame = CFrame.new(localRoot.Position, localRoot.Position + lookDirection)
            local currentCFrame = localRoot.CFrame
            localRoot.CFrame = CFrame.new(currentCFrame.Position, lookDirection)
            
            if guardLine then guardLine:Remove() end
            guardLine = Drawing.new("Line")
            guardLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            
            local guardScreenPos, onScreen = Camera:WorldToViewportPoint(guardRoot.Position)
            if onScreen then
                guardLine.To = Vector2.new(guardScreenPos.X, guardScreenPos.Y)
                guardLine.Color = Color3.fromRGB(255, 50, 50)
                guardLine.Thickness = 3
                guardLine.Transparency = 0.5
                guardLine.Visible = true
            else
                guardLine.Visible = false
            end
        end
    else
        if guardLine then 
            guardLine:Remove() 
            guardLine = nil 
        end
    end
end

local function toggleGuardCamera(enabled)
    if enabled == guardCamEnabled then return end
    
    if enabled then
        if guardCamConnection then guardCamConnection:Disconnect() end
        guardCamConnection = RunService.RenderStepped:Connect(updateGuardCamera)
        guardCamEnabled = true
    else
        if guardCamConnection then 
            guardCamConnection:Disconnect() 
            guardCamConnection = nil 
        end
        guardCamEnabled = false
        if guardLine then 
            guardLine:Remove() 
            guardLine = nil 
        end
    end
end

-- ==============================================================================
-- === 🏆 ПОБЕДА В СТЕКЛЕ ===
-- ==============================================================================
local function winGlass()
    local success, err = pcall(function()
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
        if not remotes then warn("Remotes not found"); return end
        local glassRemote = remotes:WaitForChild("Glass", 5)
        if not glassRemote then warn("Glass remote not found"); return end
        
        glassRemote:InvokeServer("PlayerWin")
    end)
    if not success then
        warn("Win Glass Error: " .. tostring(err))
    end
end

-- ==============================================================================
-- === 👶 ВЗЯТЬ РЕБЕНКА (СПАМ) ===
-- ==============================================================================
local takeBabyEnabled = false
local takeBabyThread = nil

local function toggleTakeBaby(enabled)
    if enabled == takeBabyEnabled then return end
    takeBabyEnabled = enabled
    
    if enabled then
        takeBabyThread = task.spawn(function()
            local remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
            if not remotes then return end
            local babyRemote = remotes:WaitForChild("BabyAction", 5)
            if not babyRemote then return end
            
            while takeBabyEnabled do
                pcall(function()
                    babyRemote:FireServer()
                end)
                task.wait(0.1) -- 10 раз в секунду
            end
        end)
    else
        if takeBabyThread then
            task.cancel(takeBabyThread)
            takeBabyThread = nil
        end
    end
end

-- ==============================================================================
-- === 🧶 КАНАТКА (СПАМ) ===
-- ==============================================================================
local tugOfWarEnabled = false
local tugOfWarThread = nil

local function toggleTugOfWar(enabled)
    if enabled == tugOfWarEnabled then return end
    tugOfWarEnabled = enabled
    
    if enabled then
        tugOfWarThread = task.spawn(function()
            local map = Workspace:WaitForChild("Map", 5)
            if not map then return end
            local tow = map:WaitForChild("TugOfWar", 5)
            if not tow then return end
            local remote = tow:WaitForChild("Remotes", 5):WaitForChild("Tester228505", 5)
            if not remote then return end
            
            while tugOfWarEnabled do
                pcall(function()
                    remote:FireServer()
                end)
                task.wait(1/30) -- 30 раз в секунду
            end
        end)
    else
        if tugOfWarThread then
            task.cancel(tugOfWarThread)
            tugOfWarThread = nil
        end
    end
end

-- ==============================================================================
-- === ПЕРЕКЛЮЧАТЕЛЬ ===
-- ==============================================================================
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

-- ==============================================================================
-- === КНОПКА ДЛЯ СПАВНА КЛОНОВ ===
-- ==============================================================================
local function createCloneButton(parent, label, yPosition)
    local btn = Instance.new("TextButton")
    btn.Text = "🎭 " .. label
    btn.Size = UDim2.new(1, -10, 0, 35 * 1.5)
    btn.Position = UDim2.new(0, 5, 0, yPosition)
    btn.BackgroundColor3 = Color3.fromRGB(80, 50, 100)
    btn.TextColor3 = Color3.fromRGB(255, 220, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14 * 1.5
    btn.AutoButtonColor = true
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        spawnAllBridgeClones()
    end)
    
    btn.Parent = parent
    return btn
end

-- ==============================================================================
-- === КНОПКА ПОБЕДЫ ===
-- ==============================================================================
local function createWinButton(parent, label, yPosition)
    local btn = Instance.new("TextButton")
    btn.Text = label
    btn.Size = UDim2.new(1, -10, 0, 35 * 1.5)
    btn.Position = UDim2.new(0, 5, 0, yPosition)
    btn.BackgroundColor3 = Color3.fromRGB(50, 150, 50) -- Зеленый цвет для победы
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14 * 1.5
    btn.AutoButtonColor = true
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 6)
    bCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        winGlass()
    end)
    
    btn.Parent = parent
    return btn
end

-- ==============================================================================
-- === GUI ===
-- ==============================================================================
local screenGui, mainFrame, contentContainer, leftPanel, minimizedFrame

local function rebuildGUI()
	if screenGui then screenGui:Destroy() end
	
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PidromaniaHub_SquidGame"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	minimizedFrame = Instance.new("Frame")
	minimizedFrame.Size = UDim2.new(0, 120, 0, 30)
	minimizedFrame.Position = UDim2.new(0, 10, 0, 10)
	minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	minimizedFrame.BorderSizePixel = 0
	minimizedFrame.Visible = false
	minimizedFrame.Active = true
	minimizedFrame.Draggable = true
	minimizedFrame.Parent = screenGui
	
	local minCorner = Instance.new("UICorner")
	minCorner.CornerRadius = UDim.new(0, 6)
	minCorner.Parent = minimizedFrame
	
	local minLabel = Instance.new("TextLabel")
	minLabel.Text = "Squid Game X"
	minLabel.Size = UDim2.new(1, 0, 1, 0)
	minLabel.BackgroundTransparency = 1
	minLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
	minLabel.Font = Enum.Font.GothamBold
	minLabel.TextSize = 14
	minLabel.Parent = minimizedFrame
	
	minimizedFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			mainFrame.Visible = true
			minimizedFrame.Visible = false
		end
	end)
	
	mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 800 * 1.5, 0, 500 * 1.5)
	mainFrame.Position = UDim2.new(0.5, -(800 * 1.5)/2, 0.5, -(500 * 1.5)/2)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = mainFrame
	
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 35 * 1.5)
	header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = UDim.new(0, 6)
	hCorner.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Text = T("hubTitle")
	title.Size = UDim2.new(0, 0, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.TextColor3 = Color3.fromRGB(220, 220, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14 * 1.5
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.None
	title.Parent = header
	
	local titleTextBounds = TextService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(math.huge, math.huge))
	title.Size = UDim2.new(0, titleTextBounds.X, 1, 0)

	local author = Instance.new("TextLabel")
	author.Text = "  " .. T("byAuthor")
	author.Size = UDim2.new(0, 0, 1, 0)
	author.Position = UDim2.new(0, 10 + titleTextBounds.X, 0, 0) 
	author.BackgroundTransparency = 1
	author.TextColor3 = Color3.fromRGB(150, 150, 180)
	author.Font = Enum.Font.GothamSemibold
	author.TextSize = 12 * 1.5
	author.TextXAlignment = Enum.TextXAlignment.Left
	author.Parent = header
	
	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Text = "--"
	minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
	minimizeBtn.Position = UDim2.new(1, -35, 0, 2)
	minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	minimizeBtn.Font = Enum.Font.GothamBold
	minimizeBtn.TextSize = 18
	minimizeBtn.Parent = header
	
	minimizeBtn.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		minimizedFrame.Visible = true
	end)
	
	leftPanel = Instance.new("Frame")
	leftPanel.Size = UDim2.new(0, 200 * 1.5, 1, -35 * 1.5)
	leftPanel.Position = UDim2.new(0, 0, 0, 35 * 1.5)
	leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	leftPanel.BorderSizePixel = 0
	leftPanel.Parent = mainFrame
	local lCorner = Instance.new("UICorner")
	lCorner.CornerRadius = UDim.new(0, 8)
	lCorner.Parent = leftPanel
	
	local rightPanel = Instance.new("Frame")
	rightPanel.Size = UDim2.new(1, -210 * 1.5, 1, -35 * 1.5)
	rightPanel.Position = UDim2.new(0, 210 * 1.5, 0, 35 * 1.5)
	rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	rightPanel.BorderSizePixel = 0
	rightPanel.Parent = mainFrame
	local rCorner = Instance.new("UICorner")
	rCorner.CornerRadius = UDim.new(0, 8)
	rCorner.Parent = rightPanel
	
	contentContainer = Instance.new("ScrollingFrame")
	contentContainer.Size = UDim2.new(1, -10, 1, -10)
	contentContainer.Position = UDim2.new(0, 5, 0, 5)
	contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentContainer.ScrollBarThickness = 4
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = rightPanel
	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 6)
	cCorner.Parent = contentContainer
	
	local function clearContent()
		for _, c in ipairs(contentContainer:GetChildren()) do
			if c:IsA("GuiObject") then c:Destroy() end
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	end
	
	local function showTeleports()
		clearContent()
		local lbl = Instance.new("TextLabel")
		lbl.Text = T("teleports")
		lbl.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(200, 200, 255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 14 * 1.5
		lbl.Parent = contentContainer
		
		for i, data in ipairs(CUSTOM_TELEPORTS) do
			local name, x, y, z = unpack(data)
			local btn = Instance.new("TextButton")
			btn.Text = name
			btn.Size = UDim2.new(1, -10, 0, 30 * 1.5)
			btn.Position = UDim2.new(0, 5, 0, 30 * 1.5 + (i-1) * 35 * 1.5)
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			btn.TextColor3 = Color3.fromRGB(240, 240, 255)
			btn.Font = Enum.Font.GothamSemibold
			btn.TextSize = 14 * 1.5
			btn.AutoButtonColor = true
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 6)
			bCorner.Parent = btn
			btn.MouseButton1Click:Connect(function() teleport(x,y,z) end)
			btn.Parent = contentContainer
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, #CUSTOM_TELEPORTS * 35 * 1.5 + 40)
	end
	
	local function showSettings()
		clearContent()
		local lbl = Instance.new("TextLabel")
		lbl.Text = T("languageLabel")
		lbl.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(200, 200, 255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 14 * 1.5
		lbl.Parent = contentContainer
		
		local langs = {
			{code="ru", name=T("lang_ru")}, 
			{code="uk", name=T("lang_uk")},
			{code="kk", name=T("lang_kk")}, 
			{code="en", name=T("lang_en")}
		}
		local y = 30 * 1.5
		for _, lang in ipairs(langs) do
			local btn = Instance.new("TextButton")
			btn.Text = lang.name
			btn.Size = UDim2.new(1, -10, 0, 30 * 1.5)
			btn.Position = UDim2.new(0, 5, 0, y)
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			btn.TextColor3 = Color3.fromRGB(240, 240, 255)
			btn.Font = Enum.Font.GothamSemibold
			btn.TextSize = 14 * 1.5
			btn.AutoButtonColor = true
			local bCorner = Instance.new("UICorner")
			bCorner.CornerRadius = UDim.new(0, 6)
			bCorner.Parent = btn
			btn.MouseButton1Click:Connect(function()
				currentLang = lang.code
				rebuildGUI()
			end)
			btn.Parent = contentContainer
			y = y + 35 * 1.5
		end
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, y)
	end

	local function showUtilities()
		clearContent()
		local lbl = Instance.new("TextLabel")
		lbl.Text = T("utilities")
		lbl.Size = UDim2.new(1, 0, 0, 25 * 1.5)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(200, 200, 255)
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 14 * 1.5
		lbl.Parent = contentContainer
		
		local y = 30 * 1.5
		
		-- 1. Кнопка Победы
		local winBtn = createWinButton(
			contentContainer,
			T("winGlassLabel"),
			y
		)
		y = y + 45 * 1.5
		
		local exitSwitch = createToggleSwitch(
			contentContainer,
			T("exitDoorLabel"),
			exitDoorESPEnabled,
			function(enabled)
				toggleExitDoorESP(enabled)
			end
		)
		exitSwitch.Position = UDim2.new(0, 5 * 1.5, 0, y)
		y = y + 45 * 1.5
		
		local guardSwitch = createToggleSwitch(
			contentContainer,
			T("guardCamLabel"),
			guardCamEnabled,
			function(enabled)
				toggleGuardCamera(enabled)
			end
		)
		guardSwitch.Position = UDim2.new(0, 5 * 1.5, 0, y)
		y = y + 45 * 1.5
		
		local cloneBtn = createCloneButton(
			contentContainer,
			T("cloneBridgeLabel"),
			y
		)
		y = y + 45 * 1.5
		
		-- 🔥 ПЕРЕКЛЮЧАТЕЛЬ: Заморозка игроков
		local freezeSwitch = createToggleSwitch(
			contentContainer,
			T("teleportPlayersLabel"),
			freezePlayersEnabled,
			function(enabled)
				toggleFreezePlayers(enabled)
			end
		)
		freezeSwitch.Position = UDim2.new(0, 5 * 1.5, 0, y)
		y = y + 45 * 1.5

		-- 👶 ПЕРЕКЛЮЧАТЕЛЬ: Взять ребенка
		local babySwitch = createToggleSwitch(
			contentContainer,
			T("takeBabyLabel"),
			takeBabyEnabled,
			function(enabled)
				toggleTakeBaby(enabled)
			end
		)
		babySwitch.Position = UDim2.new(0, 5 * 1.5, 0, y)
		y = y + 45 * 1.5

		-- 🧶 ПЕРЕКЛЮЧАТЕЛЬ: Канатка
		local towSwitch = createToggleSwitch(
			contentContainer,
			T("tugOfWarLabel"),
			tugOfWarEnabled,
			function(enabled)
				toggleTugOfWar(enabled)
			end
		)
		towSwitch.Position = UDim2.new(0, 5 * 1.5, 0, y)
		y = y + 45 * 1.5
		
		contentContainer.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	
	local menuY = 5
	local function makeBtn(text, icon, cb)
		local btn = Instance.new("TextButton")
		btn.Text = "  "..icon.."  "..text
		btn.Size = UDim2.new(1, -10, 0, 35 * 1.5)
		btn.Position = UDim2.new(0, 5, 0, menuY)
		menuY = menuY + (38 * 1.5)
		btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		btn.TextColor3 = Color3.fromRGB(220, 220, 255)
		btn.Font = Enum.Font.GothamSemibold
		btn.TextSize = 14 * 1.5
		btn.AutoButtonColor = true
		btn.Parent = leftPanel
		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn
		btn.MouseButton1Click:Connect(cb)
		return btn
	end
	
	makeBtn(T("teleports"), "🌐", showTeleports)
	makeBtn(T("utilities"), "🛠️", showUtilities)
	makeBtn(T("settings"), "⚙️", showSettings)
	
	showTeleports()
end

rebuildGUI()

UserInputService.InputBegan:Connect(function(inp, gp)
	if gp then return end
	if inp.KeyCode == Enum.KeyCode.G then
		if mainFrame then
			if mainFrame.Visible then
				mainFrame.Visible = false
				if minimizedFrame then minimizedFrame.Visible = true end
			else
				mainFrame.Visible = true
				if minimizedFrame then minimizedFrame.Visible = false end
			end
		end
	end
end)
