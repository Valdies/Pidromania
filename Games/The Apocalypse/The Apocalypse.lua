local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer

local function getGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return player:WaitForChild("PlayerGui")
end

local function DBG(msg)
    warn("[ОТЛАДКА ФАРМА] " .. tostring(msg))
end

-- ====== СЛОВАРЬ ПЕРЕВОДА ПРЕДМЕТОВ ======
local ITEM_TRANSLATIONS = {
    ["IronOre"] = "Железная Руда", ["CopperOre"] = "Медная Руда", ["Coal"] = "Уголь", 
    ["Stone"] = "Камень", ["Sandstone"] = "Песчаник", ["Tree1"] = "Дерево 1",
    ["BlueberryBush"] = "Черника", ["StrawberryBush"] = "Клубника", ["PotatoPlant"] = "Картошка",
    ["CommonLoot"] = "Обычный Сундук", ["UncommonLoot"] = "Необычный Сундук", ["RareLoot"] = "Редкий Сундук",
    ["AirDrop"] = "Аирдроп", ["Bandage"] = "Бинт", ["Medkit"] = "Аптечка", 
    ["Wood"] = "Доски", ["Scrap"] = "Металлолом", ["Cloth"] = "Ткань", 
    ["Gunpowder"] = "Порох", ["Plastic"] = "Пластик", ["MRE"] = "Сухпаек", 
    ["Painkillers"] = "Обезболивающее", ["Blood Bag"] = "Пакет крови",
    
    -- Группы мусорных предметов
    ["Group_Keycard"] = "🗑️ Ключ-карты (Все)",
    ["Group_Bottle"] = "🗑️ Бутылки/Вода (Все)",
    ["Group_Canned"] = "🗑️ Консервы/Бобы (Все)"
}

local function GetTrans(engName)
    return ITEM_TRANSLATIONS[engName] or engName
end

-- ====== ЛОГИКА ГРУППИРОВКИ (ОБЪЕДИНЕНИЕ МУСОРА) ======
local function GetItemGroup(name)
    local lowerName = string.lower(name)
    if string.find(lowerName, "keycard") then return "Group_Keycard"
    elseif string.find(lowerName, "bottle") or string.find(lowerName, "water") or string.find(lowerName, "soda") then return "Group_Bottle"
    elseif string.find(lowerName, "canned") or string.find(lowerName, "beans") or string.find(lowerName, "soup") then return "Group_Canned"
    end
    return name
end

-- ====== КАСТОМНЫЙ КУРСОР ======
local cursorGui = Instance.new("ScreenGui")
cursorGui.Name = "ApocCustomCursor"
cursorGui.ResetOnSpawn = false
cursorGui.DisplayOrder = 9999999
cursorGui.IgnoreGuiInset = true
cursorGui.Parent = getGuiParent()

local cursorDot = Instance.new("Frame")
cursorDot.Size = UDim2.new(0, 6, 0, 6)
cursorDot.AnchorPoint = Vector2.new(0.5, 0.5)
cursorDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
cursorDot.BorderSizePixel = 0
Instance.new("UICorner", cursorDot).CornerRadius = UDim.new(1, 0)
cursorDot.Parent = cursorGui

RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    cursorDot.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)
end)
UserInputService.MouseIconEnabled = false

-- ====== БАЗА ОБЪЕКТОВ ======
local GAME_OBJECTS = {
    Trees = {"Tree1", "Tree2", "Tree3", "Tree4", "Tree5", "Palm1", "Palm2", "Palm3", "DeadTree1", "DeadTree2", "DeadTree3"},
    Ores = {"IronOre", "CopperOre", "Coal", "Stone", "Sandstone"},
    Loot = {"CommonLoot", "UncommonLoot", "RareLoot", "AirDrop"},
    Plants = {"BlueberryBush", "StrawberryBush", "PotatoPlant"},
    Zombies = {"Zombie", "Mutant Zombie", "Headless", "Radioactive", "Charged", "Infected"}
}

local keyMap = {
    ["1"] = "One", ["2"] = "Two", ["3"] = "Three", ["4"] = "Four", ["5"] = "Five",
    ["6"] = "Six", ["7"] = "Seven", ["8"] = "Eight", ["9"] = "Nine", ["0"] = "Zero"
}
local function parseKey(str) return keyMap[str] or str end

-- ====== НАСТРОЙКИ СИСТЕМЫ ======
local currentLang = "ru"
local FOLDER_NAME = "PidromaniaHub"
local FILE_NAME = FOLDER_NAME .. "/Config.json"

local Settings = {
    TreeKey = "One", OreKey = "Four", WeaponKey = "Three",
    MasterFarm = false, AutoSaveLife = false,
    BaseTracker = {}, 
    EnableESP = false, TargetESP = "",
    EnableBossESP = false, 
    EnableSort = false, TargetSort = "",
    EnableMassSort = false,
    IgnoreList = {},
    SavedWaypoints = {}
}

local SelectedTargets = {
    Trees = false, IronOre = false, CopperOre = false, Coal = false, Stone = false, Sandstone = false,
    CommonLoot = false, UncommonLoot = false, RareLoot = false, AirDrop = false, Plants = false,
    Zombies = false
}

local ActiveWaypoints = {}
local targetWaypoint = nil 
local tempFarmCFrame = nil 

-- ====== ЯЗЫКИ И ПЕРЕВОДЫ ======
local translations = {
    ru = {
        hubTitle = "Pidromania Hub: Apocalypse",
        helpTab = "Помощь", farmTab = "Фарм", sortTab = "Сортировка", tpTab = "Телепорты", protectTab = "Защита", settingsTab = "Настройки",
        helpText = "ИНСТРУКЦИЯ:\n\n1. E -> G = Открыть/Закрыть меню.\n2. E -> C = Создать Вейпоинт.\n3. Вкладка 'Телепорты' = ТП к точкам.\n4. T = Быстрый ТП к ближайшей точке.\n5. СТАРТ / СТОП на кнопку 'H'.\n6. СОРТИРОВКА: Авто-сетка (змейка), предметы ложатся ровно в ряд.\n7. АВТО-СБРОС: Скрипт сам выкидывает вещи когда нет места.",
        trees = "Деревья (Все типы)", plants = "Растения (Ягоды и др.)", zombies = "Зомби (Walk Авто-Атака)",
        keyTrees = "Кнопка (Деревья):", keyOres = "Кнопка (Руды/Камни):", keyWeapon = "Кнопка (Оружие):",
        masterFarm = "Старт / Стоп", autoSaveLife = "Авто-Сейв (< 30% ХП)",
        catTrees = "Деревья, Листья", catOres = "Руды и Камни", catPlantsChests = "Растения и Сундуки", catZombies = "Враги (Enemies)", catProtection = "Автоматическая защита",
        langSettings = "--- Язык / Language ---",
        catSaved = "--- Сохраненные точки ---", noSaved = "Нет сохраненных точек", btnDel = "Удалить", btnTp = "Телепортироваться",
        catFriends = "--- Друзья на сервере ---", noFriends = "Нет друзей на сервере", btnTpFriend = "ТП к другу",
        catBase = "--- База (Умный Дом) ---", btnResetBase = "Сбросить память Умного Дома",
        catEspModes = "--- Управление ESP ---", catSortModes = "--- Режимы Сортировки ---", catSelectItems = "--- Выбор предметов (Англ. названия переведены) ---",
        btnScan = "🔍 Сканировать предметы (Вокруг и Инвентарь)", btnClear = "🗑 Очистить Игнор-лист",
        wpTitle = "Новая Точка (Waypoint)", wpInput = "Введите название...", btnNormal = "Обычная", btnPerm = "Вечная ⭐", btnCancel = "Отмена",
        confirmDel = "Точно удалить?", btnYes = "Да, удалить", btnNo = "Нет, не удалять", baseFound = "Найден дом на координатах: %d, %d, %d", baseWait = "Скрипт еще изучает карту... Постой на базе без фарма 30 сек."
    },
    en = {
        hubTitle = "Pidromania Hub: Apocalypse",
        helpTab = "Help", farmTab = "Farm", sortTab = "Sort", tpTab = "Teleports", protectTab = "Protect", settingsTab = "Settings",
        helpText = "INSTRUCTIONS:\n\n1. E -> G = Open/Close Menu.\n2. E -> C = Create Waypoint.\n3. 'Teleports' Tab = TP to waypoints.\n4. T = Quick TP to nearest point.\n5. START / STOP on 'H' key.\n6. SORTING: Auto-grid (snake), items line up perfectly.\n7. AUTO-DROP: Script drops trash when inventory is full.",
        trees = "Trees (All types)", plants = "Plants (Berries, etc.)", zombies = "Zombies (Walk Auto-Attack)",
        keyTrees = "Key (Trees):", keyOres = "Key (Ores/Stones):", keyWeapon = "Key (Weapon):",
        masterFarm = "Start / Stop", autoSaveLife = "Auto-Save (< 30% HP)",
        catTrees = "Trees, Leaves", catOres = "Ores and Stones", catPlantsChests = "Plants and Chests", catZombies = "Enemies", catProtection = "Automatic Protection",
        langSettings = "--- Язык / Language ---",
        catSaved = "--- Saved Waypoints ---", noSaved = "No saved waypoints", btnDel = "Delete", btnTp = "Teleport",
        catFriends = "--- Friends on server ---", noFriends = "No friends on server", btnTpFriend = "TP to friend",
        catBase = "--- Base (Smart Home) ---", btnResetBase = "Reset Smart Home Memory",
        catEspModes = "--- ESP Management ---", catSortModes = "--- Sorting Modes ---", catSelectItems = "--- Item Selection ---",
        btnScan = "🔍 Scan Items (Around & Inventory)", btnClear = "🗑 Clear Ignore List",
        wpTitle = "New Waypoint", wpInput = "Enter name...", btnNormal = "Normal", btnPerm = "Permanent ⭐", btnCancel = "Cancel",
        confirmDel = "Are you sure?", btnYes = "Yes, delete", btnNo = "No, cancel", baseFound = "Home found at coordinates: %d, %d, %d", baseWait = "Script is learning the map... Stand still at your base for 30s."
    }
}
setmetatable(translations, {__index = function(t, k) return t.ru end})
local function T(key) return translations[currentLang] and translations[currentLang][key] or translations.ru[key] or key end

local function SaveConfig()
    if writefile and isfolder then
        if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
        local data = { lang = currentLang, Settings = Settings, SelectedTargets = SelectedTargets }
        pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(data)) end)
    end
end
local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(FILE_NAME))
            if data.lang then currentLang = data.lang end
            if data.Settings then 
                for k,v in pairs(data.Settings) do Settings[k] = v end 
                if type(Settings.IgnoreList) ~= "table" then Settings.IgnoreList = {} end
                if type(Settings.SavedWaypoints) ~= "table" then Settings.SavedWaypoints = {} end
            end
            if data.SelectedTargets then for k,v in pairs(data.SelectedTargets) do SelectedTargets[k] = v end end
        end)
    end
end
LoadConfig()

-- ====== СИСТЕМА ВЕЙПОИНТОВ ======
local waypointFolder = Instance.new("Folder")
waypointFolder.Name = "ApocWaypoints"
waypointFolder.Parent = Workspace

local function CreateWaypoint(name, color, customPos, isPermanent)
    local pos = customPos
    if not pos then
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        pos = char.HumanoidRootPart.Position + Vector3.new(0, 12, 0) 
    end
    
    local wpPart = Instance.new("Part")
    wpPart.Size = Vector3.new(3, 3, 3)
    wpPart.Position = pos
    wpPart.Anchored = true
    wpPart.CanCollide = false
    wpPart.Material = Enum.Material.Neon
    wpPart.Color = color
    wpPart.Transparency = 0.2
    wpPart.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(45), math.rad(45), math.rad(45)) 
    wpPart.Parent = waypointFolder
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = wpPart
    highlight.Adornee = wpPart
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.4 
    highlight.OutlineTransparency = 0.4
    
    local bgui = Instance.new("BillboardGui")
    bgui.Parent = wpPart
    bgui.Adornee = wpPart
    bgui.Size = UDim2.new(0, 150, 0, 40)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Parent = bgui
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    
    table.insert(ActiveWaypoints, { part = wpPart, highlight = highlight, label = label, position = pos, isPermanent = isPermanent or false })
end

local function SpawnSavedWaypoints()
    for _, wpData in ipairs(Settings.SavedWaypoints) do
        if wpData.name and wpData.color and wpData.pos then
            local c = Color3.new(wpData.color.r, wpData.color.g, wpData.color.b)
            local p = Vector3.new(wpData.pos.x, wpData.pos.y, wpData.pos.z)
            CreateWaypoint(wpData.name, c, p, true)
        end
    end
end
SpawnSavedWaypoints()

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local bestDot = -1
    local bestWp = nil
    
    for _, wp in ipairs(ActiveWaypoints) do
        if wp.part and wp.part.Parent then
            wp.part.CFrame = wp.part.CFrame * CFrame.Angles(0, math.rad(1), 0)
            local dir = (wp.part.Position - cam.CFrame.Position).Unit
            local dot = cam.CFrame.LookVector:Dot(dir)
            
            if dot > 0.96 then 
                wp.highlight.FillTransparency = 0.05
                wp.highlight.OutlineTransparency = 0
                wp.label.TextSize = 24
                if dot > bestDot then bestDot = dot; bestWp = wp end
            else 
                wp.highlight.FillTransparency = 0.4
                wp.highlight.OutlineTransparency = 0.4
                wp.label.TextSize = 18
            end
        end
    end
    targetWaypoint = bestWp
end)

-- ====== АНТИ-ЛАГ СИСТЕМА ======
local cachedTargets = { tree = {}, ore = {}, plant = {}, loot = {}, zombie = {} }

local function refreshCache()
    for k, v in pairs(cachedTargets) do table.clear(v) end
    
    local activeNames = {}
    if SelectedTargets.Trees then for _,v in ipairs(GAME_OBJECTS.Trees) do activeNames[v] = "tree" end end
    if SelectedTargets.Plants then for _,v in ipairs(GAME_OBJECTS.Plants) do activeNames[v] = "plant" end end
    if SelectedTargets.Zombies then for _,v in ipairs(GAME_OBJECTS.Zombies) do activeNames[v] = "zombie" end end
    
    for _, ore in ipairs(GAME_OBJECTS.Ores) do if SelectedTargets[ore] then activeNames[ore] = "ore" end end
    for _, loot in ipairs(GAME_OBJECTS.Loot) do if SelectedTargets[loot] then activeNames[loot] = "loot" end end

    if next(activeNames) == nil then return end

    local function scanFolder(folder)
        if not folder then return end
        local descendants = folder:GetDescendants()
        for i = 1, #descendants do
            if i % 800 == 0 then task.wait() end 
            local obj = descendants[i]
            local cat = activeNames[obj.Name]
            if cat and (obj:IsA("Model") or obj:IsA("BasePart")) then
                table.insert(cachedTargets[cat], obj)
            end
        end
    end

    scanFolder(Workspace:FindFirstChild("Spawned"))
    scanFolder(Workspace:FindFirstChild("Temporal"))
    scanFolder(Workspace:FindFirstChild("Enemies"))
end

task.spawn(function()
    while true do
        if Settings.MasterFarm then refreshCache() end
        task.wait(2)
    end
end)

local function getValidPosition(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("Model") then
        return obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

local updateMasterToggleVisual = nil
local toggleMasterFarm

-- ====== СИСТЕМА УМНЫЙ ДОМ ======
local GRID_SIZE = 50 

local function getGridKey(pos)
    return string.format("%d,%d,%d", math.floor(pos.X / GRID_SIZE), math.floor(pos.Y / GRID_SIZE), math.floor(pos.Z / GRID_SIZE))
end

local function getBestBaseLocation()
    local bestKey = nil
    local maxCount = 0
    for key, data in pairs(Settings.BaseTracker) do
        if data.count > maxCount then
            maxCount = data.count
            bestKey = key
        end
    end
    if bestKey and maxCount >= 5 then 
        local d = Settings.BaseTracker[bestKey]
        return Vector3.new(d.x, d.y + 3, d.z)
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(5)
        if not Settings.MasterFarm then
            local char = player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 and hum.FloorMaterial ~= Enum.Material.Air then
                    local pos = hrp.Position
                    local key = getGridKey(pos)
                    
                    if not Settings.BaseTracker[key] then
                        Settings.BaseTracker[key] = {count = 0, x = pos.X, y = pos.Y, z = pos.Z}
                    end
                    Settings.BaseTracker[key].count = Settings.BaseTracker[key].count + 1
                    
                    if Settings.BaseTracker[key].count % 6 == 0 then SaveConfig() end
                end
            end
        end
    end
end)

-- ====== АВТО-СЕЙВ ======
local autoSaveCooldown = false
local autoSaveTpCount = 0 -- Счетчик телепортов для авто-сейва

task.spawn(function()
    while true do
        task.wait(0.2) 
        if Settings.AutoSaveLife and not autoSaveCooldown then
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                
                if hum and hrp and hum.Health > 0 and hum.MaxHealth > 0 then
                    -- Сброс счетчика сейвов, если здоровье больше 40%
                    if (hum.Health / hum.MaxHealth) > 0.40 then
                        autoSaveTpCount = 0
                    end

                    if (hum.Health / hum.MaxHealth) <= 0.30 then
                        autoSaveCooldown = true
                        if Settings.MasterFarm and toggleMasterFarm then
                            toggleMasterFarm(false)
                            if updateMasterToggleVisual then updateMasterToggleVisual(false) end
                        end
                        
                        -- Проверка лимита на 2 спасительных телепорта
                        if autoSaveTpCount < 2 then
                            autoSaveTpCount = autoSaveTpCount + 1
                            
                            local targetPos = nil
                            
                            -- ПРИОРИТЕТ 1: Ищем точку ДОМ
                            for _, wp in ipairs(ActiveWaypoints) do
                                if wp.label.Text == "ДОМ" then 
                                    targetPos = wp.position + Vector3.new(0, 5, 0)
                                    break
                                end
                            end
                            
                            -- ПРИОРИТЕТ 2: Если дома нет, ищем ближайшую точку
                            if not targetPos then
                                local bestWp = nil
                                local bestDist = math.huge
                                for _, wp in ipairs(ActiveWaypoints) do
                                    if wp.label.Text ~= "TEMP" then 
                                        local dist = (wp.position - hrp.Position).Magnitude
                                        if dist < bestDist then
                                            bestDist = dist
                                            bestWp = wp
                                        end
                                    end
                                end
                                if bestWp then targetPos = bestWp.position + Vector3.new(0, 5, 0) end
                            end
                            
                            if targetPos then
                                hrp.CFrame = CFrame.new(targetPos)
                            else
                                local autoBase = getBestBaseLocation()
                                if autoBase then
                                    hrp.CFrame = CFrame.new(autoBase)
                                else
                                    hrp.CFrame = hrp.CFrame + Vector3.new(0, 1000, 0)
                                end
                            end
                        else
                            DBG("Авто-сейв: лимит телепортов исчерпан (2/2). Ждем воскрешения.")
                        end
                        
                        task.delay(5, function() autoSaveCooldown = false end)
                    end
                end
            end
        end
    end
end)

-- ====== ДИНАМИЧЕСКИЙ ESP ПРЕДМЕТОВ ======
local itemsFolder = workspace:WaitForChild("Items", 10)
local espItemsConnections = {}

local function createTargetESP(item)
    if not Settings.EnableESP or Settings.TargetESP == "" then return end
    if not item:IsA("Model") then return end
    if GetItemGroup(item.Name) ~= Settings.TargetESP then return end
    if item:FindFirstChild("TargetItemESP") then return end

    task.wait(0.1)
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
    if part then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "TargetItemESP"
        billboard.Adornee = part
        billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 1.5, 0)
        billboard.AlwaysOnTop = true

        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = GetTrans(Settings.TargetESP)
        textLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextSize = 20
        billboard.Parent = item
    end
end

local function updateESPLogic()
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local oldEsp = item:FindFirstChild("TargetItemESP")
            if oldEsp then oldEsp:Destroy() end
        end
    end
    for _, conn in ipairs(espItemsConnections) do conn:Disconnect() end
    table.clear(espItemsConnections)

    if Settings.EnableESP and Settings.TargetESP ~= "" and itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do createTargetESP(item) end
        table.insert(espItemsConnections, itemsFolder.ChildAdded:Connect(function(item) createTargetESP(item) end))
    end
end

-- ====== ESP АЛТАРЯ БОССА ======
task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local spawners = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Enemies") and workspace.Map.Enemies:FindFirstChild("Spawners")
            if spawners then
                for _, obj in ipairs(spawners:GetChildren()) do
                    if string.find(string.lower(obj.Name), "boss altar") then
                        local oldEsp = obj:FindFirstChild("BossAltarESP")
                        if Settings.EnableBossESP then
                            if not oldEsp then
                                local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if part then
                                    local billboard = Instance.new("BillboardGui")
                                    billboard.Name = "BossAltarESP"
                                    billboard.Adornee = part
                                    billboard.Size = UDim2.new(0, 200, 0, 50)
                                    billboard.StudsOffset = Vector3.new(0, 5, 0)
                                    billboard.AlwaysOnTop = true

                                    local textLabel = Instance.new("TextLabel")
                                    textLabel.Parent = billboard
                                    textLabel.BackgroundTransparency = 1
                                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                                    textLabel.Text = "👹 Алтарь Босса"
                                    textLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                                    textLabel.TextStrokeTransparency = 0
                                    textLabel.Font = Enum.Font.GothamBold
                                    textLabel.TextSize = 20
                                    billboard.Parent = obj
                                end
                            end
                        else
                            if oldEsp then oldEsp:Destroy() end
                        end
                    end
                end
            end
        end)
    end
end)

-- ====== СИСТЕМА ВШИТОГО АВТО-СБРОСА ======
local INVENTORY_KEY = Enum.KeyCode.E
local DROP_KEY = Enum.KeyCode.G
local isAutoDumping = false

local function checkInventoryState()
    local pGui = player:FindFirstChild("PlayerGui")
    if not pGui then return false, 0, 0, "ОШИБКА: PlayerGui не найден" end
    local invPath = pGui:FindFirstChild("Menu") and pGui.Menu:FindFirstChild("Inventory") and pGui.Menu.Inventory:FindFirstChild("Inventory")
    if not invPath then return false, 0, 0, "ОШИБКА: Путь к UI не найден" end
    
    local totalSlots, emptyCount, occupiedCount = 0, 0, 0
    for _, slot in ipairs(invPath:GetChildren()) do
        if (slot:IsA("Frame") or slot:IsA("ImageLabel") or slot:IsA("ImageButton")) and slot.Name ~= "UIListLayout" and slot.Name ~= "UIGridLayout" and slot.Name ~= "UIPadding" then
            local isLocked = false
            for _, child in ipairs(slot:GetDescendants()) do
                if (child.Name == "Locked" or child.Name == "Lock") and child:IsA("GuiObject") and child.Visible then
                    if child.BackgroundTransparency < 0.9 or (child:IsA("ImageLabel") and child.ImageTransparency < 0.9) then isLocked = true break end
                end
            end
            if not isLocked then
                totalSlots = totalSlots + 1
                local isEmpty = true
                for _, obj in ipairs(slot:GetDescendants()) do
                    if obj:IsA("ImageLabel") and obj.Name ~= "Icon" and obj.Name ~= "Locked" and obj.Name ~= "Lock" and obj.Name ~= "UIListLayout" and obj.Name ~= "UICorner" and obj.Name ~= "Image" and obj.Name ~= "Background" then
                        isEmpty = false break
                    end
                end
                if isEmpty then emptyCount = emptyCount + 1 else occupiedCount = occupiedCount + 1 end
            end
        end
    end
    local isFull = (totalSlots > 0 and emptyCount == 0)
    return isFull, occupiedCount, totalSlots, "OK"
end

local function performAutoDump()
    if isAutoDumping then return end
    isAutoDumping = true 
    DBG("Приостанавливаем телепорты. Начинаем слепой сброс ВСЕХ ячеек...")
    
    VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game)
    task.wait(0.4)
    VIM:SendKeyEvent(true, INVENTORY_KEY, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, INVENTORY_KEY, false, game)
    task.wait(1.5) 
    
    local pGui = player:FindFirstChild("PlayerGui")
    local invPath = pGui and pGui:FindFirstChild("Menu") and pGui.Menu:FindFirstChild("Inventory") and pGui.Menu.Inventory:FindFirstChild("Inventory")
    
    if invPath then
        for _, slot in ipairs(invPath:GetChildren()) do
            if not Settings.MasterFarm then break end 
            if (slot:IsA("Frame") or slot:IsA("ImageLabel") or slot:IsA("ImageButton")) and slot.Name ~= "UIListLayout" and slot.Name ~= "UIGridLayout" and slot.Name ~= "UIPadding" then
                local isLocked = false
                for _, child in ipairs(slot:GetDescendants()) do
                    if (child.Name == "Locked" or child.Name == "Lock") and child:IsA("GuiObject") and child.Visible then
                        if child.BackgroundTransparency < 0.9 or (child:IsA("ImageLabel") and child.ImageTransparency < 0.9) then isLocked = true break end
                    end
                end
                if not isLocked then
                    local inset = GuiService:GetGuiInset()
                    local tX = slot.AbsolutePosition.X + (slot.AbsoluteSize.X / 2)
                    local tY = slot.AbsolutePosition.Y + (slot.AbsoluteSize.Y / 2) + inset.Y
                    VIM:SendMouseMoveEvent(0, 0, game)
                    task.wait(0.05) 
                    VIM:SendMouseMoveEvent(tX, tY, game)
                    task.wait(0.2) 
                    VIM:SendKeyEvent(true, DROP_KEY, false, game)
                    task.wait(0.1) 
                    VIM:SendKeyEvent(false, DROP_KEY, false, game)
                    task.wait(0.2) 
                end
            end
        end
    end
    task.wait(0.3)
    VIM:SendKeyEvent(true, INVENTORY_KEY, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, INVENTORY_KEY, false, game)
    task.wait(0.8)
    isAutoDumping = false 
end

-- ====== СИСТЕМА СОРТИРОВКИ ======
local isSortingBusy = false
local cancelSorting = false

local function scanAllItems()
    local foundHash = {}
    local itemsList = {}
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("Menu") and pGui.Menu:FindFirstChild("Inventory") then
        local inv = pGui.Menu.Inventory:FindFirstChild("Inventory")
        if inv then
            for _, slot in ipairs(inv:GetChildren()) do
                if slot:IsA("Frame") or slot:IsA("ImageLabel") or slot:IsA("ImageButton") then
                    for _, obj in ipairs(slot:GetDescendants()) do
                        if obj:IsA("ImageLabel") and obj.Name ~= "Icon" and obj.Name ~= "Locked" and obj.Name ~= "UIListLayout" and obj.Name ~= "UICorner" and obj.Name ~= "Image" and obj.Name ~= "Background" then
                            local grp = GetItemGroup(obj.Name)
                            if not foundHash[grp] and not Settings.IgnoreList[grp] then foundHash[grp] = true; table.insert(itemsList, grp) end
                        end
                    end
                end
            end
        end
    end

    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if item:IsA("Model") then
                local grp = GetItemGroup(item.Name)
                if not foundHash[grp] and not Settings.IgnoreList[grp] then foundHash[grp] = true; table.insert(itemsList, grp) end
            end
        end
    end
    table.sort(itemsList)
    return itemsList
end

local function performSingleSort(targetItemName)
    local char = player.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart") 
    local cam = workspace.CurrentCamera
    if not rootPart or not itemsFolder then return end
    
    local foundItems = {}
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") and GetItemGroup(item.Name) == targetItemName then table.insert(foundItems, item) end
    end
    
    local itemsCount = #foundItems
    if itemsCount > 0 then
        local freezeCFrame = rootPart.CFrame * CFrame.new(0, 1.5, -3.5)
        local targetPosition = freezeCFrame.Position
        
        for _, item in ipairs(foundItems) do
            for _, part in ipairs(item:GetDescendants()) do
                if part:IsA("BasePart") then part.Anchored = true; part.CanCollide = false; part.CFrame = CFrame.new(targetPosition) end
            end
        end
        
        task.wait(1.5) 
        if cancelSorting then return end
        
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPosition)
        task.wait(0.1)
        
        local centerX, centerY = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
        
        -- Увеличиваем количество кликов в 1.5 раза
        local clickCount = math.ceil(itemsCount * 1.5)
        for i = 1, clickCount do
            if cancelSorting then break end
            VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
            task.wait(0.02)
            VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
            task.wait(0.4) 
        end
        
        for _, item in ipairs(foundItems) do
            if item and item.Parent then
                for _, part in ipairs(item:GetDescendants()) do
                    if part:IsA("BasePart") then part.Anchored = false; part.CanCollide = true end
                end
            end
        end
        if cancelSorting then return end
        task.wait(1) 
    end
    
    if cancelSorting then return end
    VIM:SendKeyEvent(true, INVENTORY_KEY, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, INVENTORY_KEY, false, game)
    task.wait(0.6) 
    
    local invPath = player.PlayerGui:FindFirstChild("Menu") and player.PlayerGui.Menu:FindFirstChild("Inventory") and player.PlayerGui.Menu.Inventory:FindFirstChild("Inventory")
    if invPath then
        while not cancelSorting do
            local targetSlot = nil
            for _, slot in ipairs(invPath:GetChildren()) do
                if slot:IsA("Frame") or slot:IsA("ImageLabel") or slot:IsA("ImageButton") then
                    local itemName = nil
                    for _, obj in ipairs(slot:GetDescendants()) do
                        if obj:IsA("ImageLabel") and obj.Name ~= "Icon" and obj.Name ~= "Locked" and obj.Name ~= "UIListLayout" and obj.Name ~= "UICorner" and obj.Name ~= "Image" and obj.Name ~= "Background" then itemName = obj.Name end
                    end
                    if itemName and GetItemGroup(itemName) == targetItemName then targetSlot = slot; break end
                end
            end
            
            if targetSlot then
                local tX = targetSlot.AbsolutePosition.X + (targetSlot.AbsoluteSize.X / 2)
                local tY = targetSlot.AbsolutePosition.Y + (targetSlot.AbsoluteSize.Y / 2) + GuiService:GetGuiInset().Y
                VIM:SendMouseMoveEvent(tX, tY, game)
                task.wait(0.1) 
                if cancelSorting then break end
                VIM:SendKeyEvent(true, DROP_KEY, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, DROP_KEY, false, game)
                task.wait(0.3) 
            else break end
        end
    end
    task.wait(0.3)
    VIM:SendKeyEvent(true, INVENTORY_KEY, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, INVENTORY_KEY, false, game)
    task.wait(0.4) 
end

local function executeSortingLogic()
    if isSortingBusy then return end
    isSortingBusy = true
    cancelSorting = false
    if updateMasterToggleVisual then updateMasterToggleVisual(true) end
    
    if Settings.EnableMassSort then
        local itemsList = scanAllItems()
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local startCFrame = root.CFrame
            local gridWidth = 4 
            for i, itemName in ipairs(itemsList) do
                if cancelSorting then break end
                local idx = i - 1
                local row = math.floor(idx / gridWidth)
                local col = idx % gridWidth
                if row % 2 ~= 0 then col = (gridWidth - 1) - col end
                root.CFrame = startCFrame * CFrame.new(col * 5, 2, row * 5)
                task.wait(0.2)
                if cancelSorting then break end
                performSingleSort(itemName)
            end
        end
    elseif Settings.EnableSort and Settings.TargetSort ~= "" then
        performSingleSort(Settings.TargetSort)
    end
    
    isSortingBusy = false
    if updateMasterToggleVisual then updateMasterToggleVisual(false) end
end

-- ====== ЛОГИКА ФАРМА ======
local farmLoopActive = false
local isAttacking = false
local activeKeyStr = nil
local currentFocusTarget = nil 

RunService.Heartbeat:Connect(function()
    if Settings.MasterFarm and currentFocusTarget and currentFocusTarget.Parent then
        local zHum = currentFocusTarget:FindFirstChildOfClass("Humanoid")
        if zHum and zHum.Health > 0 then
            local tPos = getValidPosition(currentFocusTarget)
            local char = player.Character
            if tPos and char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tPos.X, hrp.Position.Y, tPos.Z))
            end
        else currentFocusTarget = nil end
    else currentFocusTarget = nil end
end)

task.spawn(function()
    while true do
        if Settings.MasterFarm and isAttacking then
            pcall(function()
                local character = player.Character
                if character and activeKeyStr and Enum.KeyCode[activeKeyStr] then
                    if not character:FindFirstChildOfClass("Tool") then
                        VIM:SendKeyEvent(true, Enum.KeyCode[activeKeyStr], false, game)
                        task.wait(0.02)
                        VIM:SendKeyEvent(false, Enum.KeyCode[activeKeyStr], false, game)
                    end
                end
                local vS = workspace.CurrentCamera.ViewportSize
                VIM:SendMouseButtonEvent(math.floor(vS.X / 2), math.floor(vS.Y / 2), 0, true, game, 0)
                task.wait(0.01)
                VIM:SendMouseButtonEvent(math.floor(vS.X / 2), math.floor(vS.Y / 2), 0, false, game, 0)
            end)
            task.wait(0.056)
        else task.wait(0.1) end
    end
end)

local function executeFarmStep()
    if isAutoDumping then return end
    local character = player.Character
    if not character then return end
    local rootPart, humanoid = character:FindFirstChild("HumanoidRootPart"), character:FindFirstChild("Humanoid")
    if not rootPart or not humanoid then return end

    local charPos = rootPart.Position
    local frontCF = rootPart.CFrame * CFrame.new(0, 0, -4)
    
    if SelectedTargets.Zombies then
        local nearestZombie, minZDist = nil, 100 
        for _, zModel in ipairs(cachedTargets.zombie) do
            local zHum = zModel:FindFirstChildOfClass("Humanoid")
            if zHum and zHum.Health > 0 then
                local zPos = getValidPosition(zModel)
                if zPos then
                    local dist = (zPos - charPos).Magnitude
                    if dist <= minZDist then minZDist = dist; nearestZombie = zModel end
                end
            end
        end

        if nearestZombie then
            currentFocusTarget = nearestZombie 
            local targetPos = getValidPosition(nearestZombie)
            local weaponStr = Settings.WeaponKey or "Three"
            if not character:FindFirstChildOfClass("Tool") and Enum.KeyCode[weaponStr] then
                VIM:SendKeyEvent(true, Enum.KeyCode[weaponStr], false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode[weaponStr], false, game)
            end
            if minZDist > 6 then humanoid:MoveTo(targetPos) else humanoid:MoveTo(charPos) end
            activeKeyStr = nil; isAttacking = true
            return 
        end
    end
    currentFocusTarget = nil
    if isAttacking and activeKeyStr == nil then isAttacking = false end

    local foundList = {}
    for _, obj in ipairs(cachedTargets.tree) do
        local pos = getValidPosition(obj)
        if pos and (pos - charPos).Magnitude <= 150 then table.insert(foundList, {obj = obj, dist = (pos - charPos).Magnitude, cat = "tree"}) end
    end
    for _, obj in ipairs(cachedTargets.ore) do
        local pos = getValidPosition(obj)
        if pos and (pos - charPos).Magnitude <= 150 then table.insert(foundList, {obj = obj, dist = (pos - charPos).Magnitude, cat = "ore"}) end
    end

    local pulledCount, hasTree, hasOre = 0, false, false
    if #foundList > 0 then
        table.sort(foundList, function(a, b) return a.dist < b.dist end)
        for i = 1, math.min(10, #foundList) do
            local item = foundList[i]
            if item.cat == "tree" then hasTree = true end
            if item.cat == "ore" then hasOre = true end
            pcall(function()
                for _, d in ipairs(item.obj:GetDescendants()) do if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end end
                if item.obj:IsA("BasePart") then item.obj.Anchored = true; item.obj.CanCollide = false end
                if item.obj:IsA("Model") then item.obj:PivotTo(frontCF) else item.obj.CFrame = frontCF end
            end)
            pulledCount = pulledCount + 1
        end
    end

    if pulledCount > 0 then
        activeKeyStr = hasTree and Settings.TreeKey or Settings.OreKey
        isAttacking = true
        return 
    end

    isAttacking = false
    activeKeyStr = nil
    
    local function getNearestFromList(list)
        local nearestObj, nearestDist = nil, math.huge
        for _, obj in ipairs(list) do
            local pos = getValidPosition(obj)
            if pos and (pos - charPos).Magnitude < nearestDist then nearestDist = (pos - charPos).Magnitude; nearestObj = obj end
        end
        return nearestObj
    end

    local nearestLoot = getNearestFromList(cachedTargets.loot)
    local nearestPlant = getNearestFromList(cachedTargets.plant)

    if nearestLoot then
        local isFull, occ, tot, msg = checkInventoryState()
        if msg == "OK" and isFull then
            if character and humanoid and rootPart then humanoid:MoveTo(rootPart.Position) end
            isAttacking = false; activeKeyStr = nil; performAutoDump()
            return 
        end
        local tPos = getValidPosition(nearestLoot)
        if tPos and tempFarmCFrame then
            rootPart.CFrame = CFrame.new(tPos + Vector3.new(0, 4, 0)) 
            task.wait(0.3)
            if not Settings.MasterFarm then return end 
            
            local cam = workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(math.rad(-89), 0, 0)
            task.wait(0.2)
            if not Settings.MasterFarm then return end 
            
            -- Два нажатия F подряд
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            task.wait(0.15) 
            VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            
            -- Увеличенное время ожидания (с 1.5 до 2.0)
            task.wait(2.0)
            if not Settings.MasterFarm then return end 
            VIM:SendKeyEvent(true, Enum.KeyCode.C, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.C, false, game)
            task.wait(0.2)
            if not Settings.MasterFarm or not tempFarmCFrame then return end 
            rootPart.CFrame = tempFarmCFrame
            task.wait(0.3)
            if not Settings.MasterFarm then return end 
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.3)
            if not Settings.MasterFarm then return end 
            VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.5)
        end
        return
    end

    if nearestPlant then
        local isFull, occ, tot, msg = checkInventoryState()
        if msg == "OK" and isFull then
            if character and humanoid and rootPart then humanoid:MoveTo(rootPart.Position) end
            isAttacking = false; activeKeyStr = nil; performAutoDump()
            return
        end
        local tPos = getValidPosition(nearestPlant)
        rootPart.CFrame = CFrame.new(tPos + Vector3.new(0, 3, 0))
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game); task.wait(0.05); VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

toggleMasterFarm = function(state)
    Settings.MasterFarm = state
    if not state then
        isAttacking = false
        currentFocusTarget = nil
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
            if player.Character:FindFirstChild("Humanoid") then player.Character.Humanoid:MoveTo(player.Character.HumanoidRootPart.Position) end
        end
        tempFarmCFrame = nil
        for i = #ActiveWaypoints, 1, -1 do
            if ActiveWaypoints[i].label.Text == "TEMP" then
                if ActiveWaypoints[i].part then ActiveWaypoints[i].part:Destroy() end
                table.remove(ActiveWaypoints, i)
            end
        end
    else
        local isFarmingLoot = false
        for _, loot in ipairs(GAME_OBJECTS.Loot) do if SelectedTargets[loot] then isFarmingLoot = true break end end
        if isFarmingLoot and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            tempFarmCFrame = player.Character.HumanoidRootPart.CFrame
            CreateWaypoint("TEMP", Color3.fromRGB(200, 200, 200), tempFarmCFrame.Position + Vector3.new(0, 12, 0))
        end
        refreshCache() 
    end

    if state and not farmLoopActive then
        farmLoopActive = true
        task.spawn(function()
            while Settings.MasterFarm do executeFarmStep(); task.wait(0.15) end
            farmLoopActive = false; isAttacking = false; currentFocusTarget = nil
        end)
    end
    SaveConfig()
end

-- ====== ПОСТРОЕНИЕ UI ======
local screenGuiMain = nil
local miniGui = nil
local mainFrame = nil
local waypointFrame = nil
local confirmOverlay = nil
local pendingDeleteAction = nil

local function createToggleSwitch(parent, label, initialEnabled, onToggle)
    local switchFrame = Instance.new("TextButton")
    switchFrame.Size = UDim2.new(1, -15, 0, 45)
    switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchFrame.BorderSizePixel = 0
    switchFrame.Text = ""
    switchFrame.AutoButtonColor = false
    switchFrame.Parent = parent
    Instance.new("UICorner", switchFrame).CornerRadius = UDim.new(0, 9)
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0, 320, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(240, 240, 255)
    labelText.Font = Enum.Font.GothamSemibold
    labelText.TextSize = 14
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Position = UDim2.new(0, 15, 0, 0)
    labelText.Parent = switchFrame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -15)
    toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = switchFrame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 15)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 24, 0, 24)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 12)
    
    local isEnabled = initialEnabled
    local function updateToggle(forcedState)
        if forcedState ~= nil then isEnabled = forcedState end
        if isEnabled then
            toggleBg.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
            toggleKnob.Position = UDim2.new(1, -27, 0.5, -12)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            toggleKnob.Position = UDim2.new(0, 3, 0.5, -12)
        end
    end
    updateToggle()
    switchFrame.MouseButton1Click:Connect(function() isEnabled = not isEnabled; updateToggle(); onToggle(isEnabled) end)
    return switchFrame, updateToggle, labelText
end

local function buildMiniUI()
    if miniGui then miniGui:Destroy() end
    miniGui = Instance.new("ScreenGui")
    miniGui.Name = "ApocMiniHub"
    miniGui.ResetOnSpawn = false
    miniGui.DisplayOrder = 100 
    miniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    miniGui.Parent = getGuiParent()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 270, 0, 60)
    frame.Position = UDim2.new(1, -290, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = miniGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local switchFrame, updateFunc = createToggleSwitch(frame, T("masterFarm"), Settings.MasterFarm, function(state)
        if Settings.EnableMassSort or Settings.EnableSort then
            if state then task.spawn(executeSortingLogic) else cancelSorting = true; if updateMasterToggleVisual then updateMasterToggleVisual(false) end end
        else toggleMasterFarm(state) end
    end)
    switchFrame.Size = UDim2.new(1, -10, 1, -10)
    switchFrame.Position = UDim2.new(0, 5, 0, 5)
    updateMasterToggleVisual = updateFunc
end

local function createCategoryHeader(parent, text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return yPos + 30
end

local function rebuildGUI(startTab)
    if screenGuiMain then screenGuiMain:Destroy() end
    
    screenGuiMain = Instance.new("ScreenGui")
    screenGuiMain.Name = "PidromaniaHubMain"
    screenGuiMain.ResetOnSpawn = false
    screenGuiMain.DisplayOrder = 100 
    screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGuiMain.Parent = getGuiParent()
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 780, 0, 520)
    mainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGuiMain
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Text = T("hubTitle")
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Size = UDim2.new(0, 400, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 200, 1, -50)
    leftPanel.Position = UDim2.new(0, 0, 0, 50)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    leftPanel.Parent = mainFrame
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -210, 1, -60)
    rightPanel.Position = UDim2.new(0, 205, 0, 55)
    rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    rightPanel.Parent = mainFrame
    Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 12)
    
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -10, 1, -10)
    contentContainer.Position = UDim2.new(0, 5, 0, 5)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ScrollBarThickness = 4
    contentContainer.Parent = rightPanel

    confirmOverlay = Instance.new("Frame")
    confirmOverlay.Size = UDim2.new(1, 0, 1, 0)
    confirmOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    confirmOverlay.BackgroundTransparency = 0.5
    confirmOverlay.Visible = false
    confirmOverlay.Active = true
    confirmOverlay.ZIndex = 50
    confirmOverlay.Parent = mainFrame
    Instance.new("UICorner", confirmOverlay).CornerRadius = UDim.new(0, 15)

    local confirmBox = Instance.new("Frame")
    confirmBox.Size = UDim2.new(0, 300, 0, 150)
    confirmBox.Position = UDim2.new(0.5, -150, 0.5, -75)
    confirmBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    confirmBox.ZIndex = 51
    confirmBox.Parent = confirmOverlay
    Instance.new("UICorner", confirmBox).CornerRadius = UDim.new(0, 10)

    local confirmLabel = Instance.new("TextLabel")
    confirmLabel.Text = T("confirmDel")
    confirmLabel.Size = UDim2.new(1, 0, 0, 50)
    confirmLabel.Position = UDim2.new(0, 0, 0, 15)
    confirmLabel.BackgroundTransparency = 1
    confirmLabel.TextColor3 = Color3.new(1, 1, 1)
    confirmLabel.Font = Enum.Font.GothamBold
    confirmLabel.TextSize = 20
    confirmLabel.ZIndex = 51
    confirmLabel.Parent = confirmBox

    local btnConfirmYes = Instance.new("TextButton")
    btnConfirmYes.Text = T("btnYes")
    btnConfirmYes.Size = UDim2.new(0.4, 0, 0, 40)
    btnConfirmYes.Position = UDim2.new(0.06, 0, 0, 90)
    btnConfirmYes.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    btnConfirmYes.TextColor3 = Color3.new(1, 1, 1)
    btnConfirmYes.Font = Enum.Font.GothamBold
    btnConfirmYes.TextSize = 14
    btnConfirmYes.ZIndex = 51
    btnConfirmYes.Parent = confirmBox
    Instance.new("UICorner", btnConfirmYes).CornerRadius = UDim.new(0, 6)

    local btnConfirmNo = Instance.new("TextButton")
    btnConfirmNo.Text = T("btnNo")
    btnConfirmNo.Size = UDim2.new(0.4, 0, 0, 40)
    btnConfirmNo.Position = UDim2.new(0.54, 0, 0, 90)
    btnConfirmNo.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    btnConfirmNo.TextColor3 = Color3.new(1, 1, 1)
    btnConfirmNo.Font = Enum.Font.GothamBold
    btnConfirmNo.TextSize = 14
    btnConfirmNo.ZIndex = 51
    btnConfirmNo.Parent = confirmBox
    Instance.new("UICorner", btnConfirmNo).CornerRadius = UDim.new(0, 6)

    btnConfirmYes.MouseButton1Click:Connect(function()
        if pendingDeleteAction then pendingDeleteAction() end
        confirmOverlay.Visible = false; pendingDeleteAction = nil
    end)
    btnConfirmNo.MouseButton1Click:Connect(function() confirmOverlay.Visible = false; pendingDeleteAction = nil end)

    -- ====== ПАНЕЛЬ СОЗДАНИЯ ТОЧКИ ======
    waypointFrame = Instance.new("Frame")
    waypointFrame.Size = UDim2.new(0, 350, 0, 220)
    waypointFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    waypointFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    waypointFrame.Active = true
    waypointFrame.Draggable = true
    waypointFrame.Visible = false
    waypointFrame.Parent = screenGuiMain
    Instance.new("UICorner", waypointFrame).CornerRadius = UDim.new(0, 12)
    
    local wpTitle = Instance.new("TextLabel")
    wpTitle.Text = T("wpTitle")
    wpTitle.Size = UDim2.new(1, 0, 0, 40)
    wpTitle.BackgroundTransparency = 1
    wpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpTitle.Font = Enum.Font.GothamBold
    wpTitle.TextSize = 18
    wpTitle.Parent = waypointFrame
    
    local wpInput = Instance.new("TextBox")
    wpInput.Size = UDim2.new(1, -40, 0, 40)
    wpInput.Position = UDim2.new(0, 20, 0, 50)
    wpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    wpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpInput.PlaceholderText = T("wpInput")
    wpInput.Font = Enum.Font.GothamSemibold
    wpInput.TextSize = 16
    wpInput.Parent = waypointFrame
    Instance.new("UICorner", wpInput).CornerRadius = UDim.new(0, 8)
    
    local colors = { Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50), Color3.fromRGB(50,150,255), Color3.fromRGB(255,255,50), Color3.fromRGB(200,50,255) }
    local selectedColor = colors[1]
    local colorSelectorFrame = Instance.new("Frame")
    colorSelectorFrame.Size = UDim2.new(1, -40, 0, 30)
    colorSelectorFrame.Position = UDim2.new(0, 20, 0, 100)
    colorSelectorFrame.BackgroundTransparency = 1
    colorSelectorFrame.Parent = waypointFrame
    
    local colorBtns = {}
    for i, c in ipairs(colors) do
        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(0, 30, 0, 30)
        cBtn.Position = UDim2.new(0, (i-1)*40, 0, 0)
        cBtn.BackgroundColor3 = c
        cBtn.Text = ""
        cBtn.Parent = colorSelectorFrame
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0)
        cBtn.MouseButton1Click:Connect(function()
            selectedColor = c
            for _, b in ipairs(colorBtns) do b.BorderSizePixel = 0 end
            cBtn.BorderSizePixel = 3; cBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        end)
        table.insert(colorBtns, cBtn)
    end
    colorBtns[1].BorderSizePixel = 3; colorBtns[1].BorderColor3 = Color3.fromRGB(255, 255, 255)
    
    local btnWpCreate = Instance.new("TextButton")
    btnWpCreate.Size = UDim2.new(0, 75, 0, 40)
    btnWpCreate.Position = UDim2.new(0, 10, 0, 150)
    btnWpCreate.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
    btnWpCreate.TextColor3 = Color3.new(1,1,1)
    btnWpCreate.Font = Enum.Font.GothamBold
    btnWpCreate.TextSize = 13
    btnWpCreate.Text = T("btnNormal")
    btnWpCreate.Parent = waypointFrame
    Instance.new("UICorner", btnWpCreate).CornerRadius = UDim.new(0, 8)

    local btnWpPerm = Instance.new("TextButton")
    btnWpPerm.Size = UDim2.new(0, 80, 0, 40)
    btnWpPerm.Position = UDim2.new(0, 90, 0, 150)
    btnWpPerm.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
    btnWpPerm.TextColor3 = Color3.new(1,1,1)
    btnWpPerm.Font = Enum.Font.GothamBold
    btnWpPerm.TextSize = 13
    btnWpPerm.Text = T("btnPerm")
    btnWpPerm.Parent = waypointFrame
    Instance.new("UICorner", btnWpPerm).CornerRadius = UDim.new(0, 8)
    
    local btnWpHome = Instance.new("TextButton")
    btnWpHome.Size = UDim2.new(0, 80, 0, 40)
    btnWpHome.Position = UDim2.new(0, 175, 0, 150)
    btnWpHome.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    btnWpHome.TextColor3 = Color3.new(1,1,1)
    btnWpHome.Font = Enum.Font.GothamBold
    btnWpHome.TextSize = 13
    btnWpHome.Text = "Дом 🏠"
    btnWpHome.Parent = waypointFrame
    Instance.new("UICorner", btnWpHome).CornerRadius = UDim.new(0, 8)

    local btnWpCancel = Instance.new("TextButton")
    btnWpCancel.Size = UDim2.new(0, 75, 0, 40)
    btnWpCancel.Position = UDim2.new(0, 260, 0, 150)
    btnWpCancel.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btnWpCancel.TextColor3 = Color3.new(1,1,1)
    btnWpCancel.Font = Enum.Font.GothamBold
    btnWpCancel.TextSize = 13
    btnWpCancel.Text = T("btnCancel")
    btnWpCancel.Parent = waypointFrame
    Instance.new("UICorner", btnWpCancel).CornerRadius = UDim.new(0, 8)
    
    btnWpCreate.MouseButton1Click:Connect(function()
        local name = wpInput.Text; if name == "" then name = "Точка" end
        CreateWaypoint(name, selectedColor)
        if waypointFrame then waypointFrame.Visible = false end; wpInput.Text = ""
    end)

    btnWpPerm.MouseButton1Click:Connect(function()
        local name = wpInput.Text; if name == "" then name = "Точка" end
        local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pos = char.HumanoidRootPart.Position + Vector3.new(0, 12, 0)
        table.insert(Settings.SavedWaypoints, {name = name, color = {r = selectedColor.R, g = selectedColor.G, b = selectedColor.B}, pos = {x = pos.X, y = pos.Y, z = pos.Z}})
        SaveConfig()
        CreateWaypoint(name, selectedColor, pos, true)
        if waypointFrame then waypointFrame.Visible = false end; wpInput.Text = ""
    end)

    btnWpHome.MouseButton1Click:Connect(function()
        local name = "ДОМ"
        local char = player.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local pos = char.HumanoidRootPart.Position + Vector3.new(0, 12, 0)
        table.insert(Settings.SavedWaypoints, {name = name, color = {r = selectedColor.R, g = selectedColor.G, b = selectedColor.B}, pos = {x = pos.X, y = pos.Y, z = pos.Z}})
        SaveConfig()
        CreateWaypoint(name, selectedColor, pos, true)
        if waypointFrame then waypointFrame.Visible = false end; wpInput.Text = ""
    end)

    btnWpCancel.MouseButton1Click:Connect(function() if waypointFrame then waypointFrame.Visible = false end end)

    local function clearContent()
        for _, child in ipairs(contentContainer:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
    end

    local function showHelp()
        clearContent()
        local txt = Instance.new("TextLabel")
        txt.Text = T("helpText")
        txt.Size = UDim2.new(1, -20, 1, -20)
        txt.Position = UDim2.new(0, 10, 0, 10)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(220, 220, 255)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 16
        txt.TextWrapped = true
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextYAlignment = Enum.TextYAlignment.Top
        txt.Parent = contentContainer
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    end

    local function showFarm()
        clearContent()
        local y = 10
        y = createCategoryHeader(contentContainer, "--- " .. T("catZombies") .. " ---", y)
        local swZombies = createToggleSwitch(contentContainer, T("zombies"), SelectedTargets.Zombies, function(s) SelectedTargets.Zombies = s; SaveConfig() end)
        swZombies.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catTrees") .. " ---", y)
        local swTrees = createToggleSwitch(contentContainer, T("trees"), SelectedTargets.Trees, function(s) SelectedTargets.Trees = s; SaveConfig() end)
        swTrees.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catOres") .. " ---", y)
        for _, ore in ipairs(GAME_OBJECTS.Ores) do
            local sw = createToggleSwitch(contentContainer, GetTrans(ore), SelectedTargets[ore], function(s) SelectedTargets[ore] = s; SaveConfig() end)
            sw.Position = UDim2.new(0, 5, 0, y); y = y + 55
        end
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catPlantsChests") .. " ---", y)
        local swPlants = createToggleSwitch(contentContainer, T("plants"), SelectedTargets.Plants, function(s) SelectedTargets.Plants = s; SaveConfig() end)
        swPlants.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        for _, loot in ipairs(GAME_OBJECTS.Loot) do
            local sw = createToggleSwitch(contentContainer, GetTrans(loot), SelectedTargets[loot], function(s) SelectedTargets[loot] = s; SaveConfig() end)
            sw.Position = UDim2.new(0, 5, 0, y); y = y + 55
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local showTeleports 
    showTeleports = function()
        clearContent()
        local y = 10
        y = createCategoryHeader(contentContainer, T("catSaved"), y)
        
        if #ActiveWaypoints == 0 then
            local lbl = Instance.new("TextLabel")
            lbl.Text = T("noSaved")
            lbl.Size = UDim2.new(1, -20, 0, 30)
            lbl.Position = UDim2.new(0, 10, 0, y)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.Parent = contentContainer
            y = y + 30
        else
            for i, wp in ipairs(ActiveWaypoints) do
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -20, 0, 45)
                frame.Position = UDim2.new(0, 10, 0, y)
                frame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                frame.Parent = contentContainer
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
                
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Text = (wp.isPermanent and "⭐ " or "") .. wp.label.Text
                nameLbl.Size = UDim2.new(0, 180, 1, 0)
                nameLbl.Position = UDim2.new(0, 15, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.TextColor3 = Color3.new(1, 1, 1)
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 14
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = frame
                
                local btnDel = Instance.new("TextButton")
                btnDel.Text = T("btnDel")
                btnDel.Size = UDim2.new(0, 80, 0, 30)
                btnDel.Position = UDim2.new(1, -90, 0.5, -15)
                btnDel.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                btnDel.TextColor3 = Color3.new(1, 1, 1)
                btnDel.Font = Enum.Font.GothamBold
                btnDel.TextSize = 13
                btnDel.Parent = frame
                Instance.new("UICorner", btnDel).CornerRadius = UDim.new(0, 6)
                
                local btnTp = Instance.new("TextButton")
                btnTp.Text = T("btnTp")
                btnTp.Size = UDim2.new(0, 140, 0, 30)
                btnTp.Position = UDim2.new(1, -240, 0.5, -15)
                btnTp.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
                btnTp.TextColor3 = Color3.new(1, 1, 1)
                btnTp.Font = Enum.Font.GothamBold
                btnTp.TextSize = 13
                btnTp.Parent = frame
                Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 6)

                btnTp.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then player.Character.HumanoidRootPart.CFrame = CFrame.new(wp.position - Vector3.new(0, 9, 0)) end
                end)
                btnDel.MouseButton1Click:Connect(function()
                    pendingDeleteAction = function()
                        if wp.isPermanent then
                            for idx, swp in ipairs(Settings.SavedWaypoints) do
                                local dist = (Vector3.new(swp.pos.x, swp.pos.y, swp.pos.z) - wp.position).Magnitude
                                if dist < 1 then table.remove(Settings.SavedWaypoints, idx) break end
                            end
                            SaveConfig()
                        end
                        if wp.part then wp.part:Destroy() end
                        table.remove(ActiveWaypoints, i)
                        showTeleports()
                    end
                    if confirmOverlay then confirmOverlay.Visible = true end
                end)
                y = y + 50
            end
        end

        y = y + 10
        y = createCategoryHeader(contentContainer, T("catFriends"), y)
        
        local friendsFound = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and player:IsFriendsWith(p.UserId) then
                friendsFound = true
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, -20, 0, 45)
                frame.Position = UDim2.new(0, 10, 0, y)
                frame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                frame.Parent = contentContainer
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
                
                local nameLbl = Instance.new("TextLabel")
                nameLbl.Text = p.DisplayName .. " (@" .. p.Name .. ")"
                nameLbl.Size = UDim2.new(0, 200, 1, 0)
                nameLbl.Position = UDim2.new(0, 15, 0, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.TextColor3 = Color3.new(1, 1, 1)
                nameLbl.Font = Enum.Font.GothamBold
                nameLbl.TextSize = 14
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.Parent = frame
                
                local btnTp = Instance.new("TextButton")
                btnTp.Text = T("btnTpFriend")
                btnTp.Size = UDim2.new(0, 140, 0, 30)
                btnTp.Position = UDim2.new(1, -150, 0.5, -15)
                btnTp.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
                btnTp.TextColor3 = Color3.new(1, 1, 1)
                btnTp.Font = Enum.Font.GothamBold
                btnTp.TextSize = 13
                btnTp.Parent = frame
                Instance.new("UICorner", btnTp).CornerRadius = UDim.new(0, 6)

                btnTp.MouseButton1Click:Connect(function()
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        player.Character.HumanoidRootPart.CFrame = CFrame.new(p.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
                    end
                end)
                y = y + 50
            end
        end

        if not friendsFound then
            local lbl = Instance.new("TextLabel")
            lbl.Text = T("noFriends")
            lbl.Size = UDim2.new(1, -20, 0, 30)
            lbl.Position = UDim2.new(0, 10, 0, y)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(150, 150, 150)
            lbl.Font = Enum.Font.Gotham
            lbl.TextSize = 14
            lbl.Parent = contentContainer
            y = y + 30
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local function showProtect()
        clearContent()
        local y = 10
        y = createCategoryHeader(contentContainer, "--- " .. T("catProtection") .. " ---", y)
        
        local swAutoSave = createToggleSwitch(contentContainer, T("autoSaveLife"), Settings.AutoSaveLife, function(s) Settings.AutoSaveLife = s; SaveConfig() end)
        swAutoSave.Position = UDim2.new(0, 5, 0, y)
        y = y + 65
        
        y = createCategoryHeader(contentContainer, T("catBase"), y)
        
        local infoLbl = Instance.new("TextLabel")
        local basePos = getBestBaseLocation()
        if basePos then
            infoLbl.Text = string.format(T("baseFound"), basePos.X, basePos.Y, basePos.Z)
            infoLbl.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            infoLbl.Text = T("baseWait")
            infoLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        infoLbl.Size = UDim2.new(1, -20, 0, 30)
        infoLbl.Position = UDim2.new(0, 15, 0, y)
        infoLbl.BackgroundTransparency = 1
        infoLbl.Font = Enum.Font.GothamSemibold
        infoLbl.TextSize = 14
        infoLbl.TextXAlignment = Enum.TextXAlignment.Left
        infoLbl.Parent = contentContainer
        y = y + 40
        
        local btnResetBase = Instance.new("TextButton")
        btnResetBase.Text = T("btnResetBase")
        btnResetBase.Size = UDim2.new(0, 280, 0, 35)
        btnResetBase.Position = UDim2.new(0, 15, 0, y)
        btnResetBase.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        btnResetBase.TextColor3 = Color3.new(1, 1, 1)
        btnResetBase.Font = Enum.Font.GothamBold
        btnResetBase.TextSize = 14
        btnResetBase.Parent = contentContainer
        Instance.new("UICorner", btnResetBase).CornerRadius = UDim.new(0, 6)
        
        btnResetBase.MouseButton1Click:Connect(function() Settings.BaseTracker = {}; SaveConfig(); showProtect() end)
        y = y + 50
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local function showSettings()
        clearContent()
        local y = 10
        
        y = createCategoryHeader(contentContainer, T("langSettings"), y)
        local langFrame = Instance.new("Frame")
        langFrame.Size = UDim2.new(1, -20, 0, 40)
        langFrame.Position = UDim2.new(0, 10, 0, y)
        langFrame.BackgroundTransparency = 1
        langFrame.Parent = contentContainer

        local btnRu = Instance.new("TextButton")
        btnRu.Size = UDim2.new(0.48, 0, 1, 0)
        btnRu.BackgroundColor3 = currentLang == "ru" and Color3.fromRGB(50, 150, 70) or Color3.fromRGB(60, 60, 70)
        btnRu.Text = "Русский"
        btnRu.TextColor3 = Color3.new(1, 1, 1)
        btnRu.Font = Enum.Font.GothamBold
        btnRu.TextSize = 14
        btnRu.Parent = langFrame
        Instance.new("UICorner", btnRu).CornerRadius = UDim.new(0, 6)

        local btnEn = Instance.new("TextButton")
        btnEn.Size = UDim2.new(0.48, 0, 1, 0)
        btnEn.Position = UDim2.new(0.52, 0, 0, 0)
        btnEn.BackgroundColor3 = currentLang == "en" and Color3.fromRGB(50, 150, 70) or Color3.fromRGB(60, 60, 70)
        btnEn.Text = "English"
        btnEn.TextColor3 = Color3.new(1, 1, 1)
        btnEn.Font = Enum.Font.GothamBold
        btnEn.TextSize = 14
        btnEn.Parent = langFrame
        Instance.new("UICorner", btnEn).CornerRadius = UDim.new(0, 6)

        btnRu.MouseButton1Click:Connect(function()
            if currentLang ~= "ru" then currentLang = "ru"; SaveConfig(); rebuildGUI("Settings") end
        end)
        btnEn.MouseButton1Click:Connect(function()
            if currentLang ~= "en" then currentLang = "en"; SaveConfig(); rebuildGUI("Settings") end
        end)
        
        y = y + 60

        local function makeKeybind(label, settingKey)
            local lbl = Instance.new("TextLabel")
            lbl.Text = label
            lbl.Size = UDim2.new(0, 300, 0, 40)
            lbl.Position = UDim2.new(0, 10, 0, y)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = contentContainer

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 100, 0, 35)
            box.Position = UDim2.new(1, -120, 0, y + 2)
            box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            local displayVal = Settings[settingKey]
            for numStr, enumStr in pairs(keyMap) do if enumStr == Settings[settingKey] then displayVal = numStr break end end
            box.Text = displayVal
            box.Font = Enum.Font.GothamBold
            box.TextSize = 16
            box.Parent = contentContainer
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

            box.FocusLost:Connect(function() Settings[settingKey] = parseKey(box.Text); SaveConfig() end)
            y = y + 50
        end

        makeKeybind(T("keyTrees"), "TreeKey")
        makeKeybind(T("keyOres"), "OreKey")
        makeKeybind(T("keyWeapon"), "WeaponKey")
        
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local function showSort()
        clearContent()
        local y = 10
        
        y = createCategoryHeader(contentContainer, T("catEspModes"), y)
        local swESP, _, lblESP = createToggleSwitch(contentContainer, "ESP: " .. (Settings.TargetESP == "" and "..." or GetTrans(Settings.TargetESP)), Settings.EnableESP, function(s)
            Settings.EnableESP = s; SaveConfig(); updateESPLogic()
        end)
        swESP.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        local swBossESP = createToggleSwitch(contentContainer, "ESP: 👹 Boss Altar", Settings.EnableBossESP, function(s) Settings.EnableBossESP = s; SaveConfig() end)
        swBossESP.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        y = createCategoryHeader(contentContainer, T("catSortModes"), y)
        
        local swSort, _, lblSort = createToggleSwitch(contentContainer, "1 ITEM: " .. (Settings.TargetSort == "" and "..." or GetTrans(Settings.TargetSort)) .. " (H)", Settings.EnableSort, function(s)
            Settings.EnableSort = s
            if s then Settings.EnableMassSort = false end
            if s and Settings.MasterFarm then toggleMasterFarm(false); if updateMasterToggleVisual then updateMasterToggleVisual(false) end end
            SaveConfig(); showSort()
        end)
        swSort.Position = UDim2.new(0, 5, 0, y); y = y + 55

        local swMassSort = createToggleSwitch(contentContainer, "MASS SORT (Auto-Grid) (H)", Settings.EnableMassSort, function(s)
            Settings.EnableMassSort = s
            if s then Settings.EnableSort = false end
            if s and Settings.MasterFarm then toggleMasterFarm(false); if updateMasterToggleVisual then updateMasterToggleVisual(false) end end
            SaveConfig(); showSort() 
        end)
        swMassSort.Position = UDim2.new(0, 5, 0, y); y = y + 65

        y = createCategoryHeader(contentContainer, T("catSelectItems"), y)
        
        local btnScan = Instance.new("TextButton")
        btnScan.Text = T("btnScan")
        btnScan.Size = UDim2.new(0, 300, 0, 40)
        btnScan.Position = UDim2.new(0, 10, 0, y)
        btnScan.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
        btnScan.TextColor3 = Color3.new(1, 1, 1)
        btnScan.Font = Enum.Font.GothamBold
        btnScan.TextSize = 13
        btnScan.Parent = contentContainer
        Instance.new("UICorner", btnScan).CornerRadius = UDim.new(0, 8)

        local btnClearIgnore = Instance.new("TextButton")
        btnClearIgnore.Text = T("btnClear")
        btnClearIgnore.Size = UDim2.new(0, 220, 0, 40)
        btnClearIgnore.Position = UDim2.new(0, 320, 0, y)
        btnClearIgnore.BackgroundColor3 = Color3.fromRGB(150, 80, 50)
        btnClearIgnore.TextColor3 = Color3.new(1, 1, 1)
        btnClearIgnore.Font = Enum.Font.GothamBold
        btnClearIgnore.TextSize = 13
        btnClearIgnore.Parent = contentContainer
        Instance.new("UICorner", btnClearIgnore).CornerRadius = UDim.new(0, 8)
        
        y = y + 50

        local listContainer = Instance.new("Frame")
        listContainer.Size = UDim2.new(1, -20, 0, 0)
        listContainer.Position = UDim2.new(0, 10, 0, y)
        listContainer.BackgroundTransparency = 1
        listContainer.Parent = contentContainer

        local function populateList()
            for _, c in ipairs(listContainer:GetChildren()) do if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end end
            
            local itemsList = scanAllItems()
            local listY = 0
            
            if #itemsList == 0 then
                local txt = Instance.new("TextLabel")
                txt.Text = "Empty (or ignored)."
                txt.Size = UDim2.new(1, 0, 0, 30)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = Color3.fromRGB(150, 150, 150)
                txt.Font = Enum.Font.Gotham
                txt.TextSize = 14
                txt.Parent = listContainer
                listY = 30
            else
                for _, itemName in ipairs(itemsList) do
                    local row = Instance.new("Frame")
                    row.Size = UDim2.new(1, 0, 0, 40)
                    row.Position = UDim2.new(0, 0, 0, listY)
                    row.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                    row.Parent = listContainer
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                    local nameLbl = Instance.new("TextLabel")
                    nameLbl.Text = GetTrans(itemName)
                    nameLbl.Size = UDim2.new(0, 200, 1, 0)
                    nameLbl.Position = UDim2.new(0, 10, 0, 0)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.TextColor3 = Color3.new(1, 1, 1)
                    nameLbl.Font = Enum.Font.GothamSemibold
                    nameLbl.TextSize = 14
                    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                    nameLbl.Parent = row

                    local btnEsp = Instance.new("TextButton")
                    btnEsp.Text = "ESP"
                    btnEsp.Size = UDim2.new(0, 60, 0, 28)
                    btnEsp.Position = UDim2.new(1, -260, 0.5, -14)
                    btnEsp.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
                    btnEsp.TextColor3 = Color3.new(1, 1, 1)
                    btnEsp.Font = Enum.Font.GothamBold
                    btnEsp.TextSize = 11
                    btnEsp.Parent = row
                    Instance.new("UICorner", btnEsp).CornerRadius = UDim.new(0, 5)

                    local btnSort = Instance.new("TextButton")
                    btnSort.Text = "Sort 1"
                    btnSort.Size = UDim2.new(0, 90, 0, 28)
                    btnSort.Position = UDim2.new(1, -190, 0.5, -14)
                    btnSort.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
                    btnSort.TextColor3 = Color3.new(1, 1, 1)
                    btnSort.Font = Enum.Font.GothamBold
                    btnSort.TextSize = 11
                    btnSort.Parent = row
                    Instance.new("UICorner", btnSort).CornerRadius = UDim.new(0, 5)

                    local btnIgnore = Instance.new("TextButton")
                    btnIgnore.Text = "Ignore ❌"
                    btnIgnore.Size = UDim2.new(0, 90, 0, 28)
                    btnIgnore.Position = UDim2.new(1, -95, 0.5, -14)
                    btnIgnore.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
                    btnIgnore.TextColor3 = Color3.new(1, 1, 1)
                    btnIgnore.Font = Enum.Font.GothamBold
                    btnIgnore.TextSize = 11
                    btnIgnore.Parent = row
                    Instance.new("UICorner", btnIgnore).CornerRadius = UDim.new(0, 5)

                    btnEsp.MouseButton1Click:Connect(function() Settings.TargetESP = itemName; lblESP.Text = "ESP: " .. GetTrans(itemName); SaveConfig(); updateESPLogic() end)
                    btnSort.MouseButton1Click:Connect(function() Settings.TargetSort = itemName; lblSort.Text = "1 ITEM: " .. GetTrans(itemName) .. " (H)"; SaveConfig() end)
                    btnIgnore.MouseButton1Click:Connect(function() Settings.IgnoreList[itemName] = true; SaveConfig(); populateList() end)
                    listY = listY + 45
                end
            end
            listContainer.Size = UDim2.new(1, -20, 0, listY)
            contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + listY + 20)
        end

        btnScan.MouseButton1Click:Connect(populateList)
        btnClearIgnore.MouseButton1Click:Connect(function() Settings.IgnoreList = {}; SaveConfig(); populateList() end)
        populateList() 
    end

    local menuItems = {}
    local function createMenuBtn(name, icon, index)
        local btn = Instance.new("TextButton")
        btn.Text = "  " .. icon .. "  " .. name
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.Position = UDim2.new(0, 10, 0, 10 + (index * 55))
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 16
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = leftPanel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
        table.insert(menuItems, btn)
        return btn
    end

    local btnHelp     = createMenuBtn(T("helpTab"), "❓", 0)
    local btnFarm     = createMenuBtn(T("farmTab"), "⛏️", 1)
    local btnSort     = createMenuBtn(T("sortTab"), "📦", 2)
    local btnTp       = createMenuBtn(T("tpTab"), "🌌", 3)
    local btnProtect  = createMenuBtn(T("protectTab"), "🛡️", 4)
    local btnSettings = createMenuBtn(T("settingsTab"), "⚙️", 5)

    local function selectBtn(targetBtn)
        for _, b in ipairs(menuItems) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        targetBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end

    local currentTab = startTab or "Help"
    
    btnHelp.MouseButton1Click:Connect(function() currentTab = "Help"; selectBtn(btnHelp) showHelp() end)
    btnFarm.MouseButton1Click:Connect(function() currentTab = "Farm"; selectBtn(btnFarm) showFarm() end)
    btnSort.MouseButton1Click:Connect(function() currentTab = "Sort"; selectBtn(btnSort) showSort() end)
    btnTp.MouseButton1Click:Connect(function() currentTab = "Tp"; selectBtn(btnTp) showTeleports() end)
    btnProtect.MouseButton1Click:Connect(function() currentTab = "Protect"; selectBtn(btnProtect) showProtect() end)
    btnSettings.MouseButton1Click:Connect(function() currentTab = "Settings"; selectBtn(btnSettings) showSettings() end)

    if currentTab == "Help" then selectBtn(btnHelp); showHelp()
    elseif currentTab == "Farm" then selectBtn(btnFarm); showFarm()
    elseif currentTab == "Sort" then selectBtn(btnSort); showSort()
    elseif currentTab == "Tp" then selectBtn(btnTp); showTeleports()
    elseif currentTab == "Protect" then selectBtn(btnProtect); showProtect()
    elseif currentTab == "Settings" then selectBtn(btnSettings); showSettings()
    end
    
    buildMiniUI()
end

rebuildGUI()

local ePressedTime = 0
local TIME_WINDOW = 0.5 

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local kc = input.KeyCode

    if Settings.MasterFarm and not isAutoDumping and (kc == Enum.KeyCode.T or kc == Enum.KeyCode.Q or kc == Enum.KeyCode.G) then
        if updateMasterToggleVisual then updateMasterToggleVisual(false) end
        toggleMasterFarm(false)
    end

    if kc == Enum.KeyCode.E then
        ePressedTime = tick()
        if mainFrame and mainFrame.Visible then mainFrame.Visible = false end
        if waypointFrame and waypointFrame.Visible then waypointFrame.Visible = false end
    elseif kc == Enum.KeyCode.G then
        if not isAutoDumping and (tick() - ePressedTime) <= TIME_WINDOW then
            if mainFrame and not mainFrame.Visible then
                if waypointFrame then waypointFrame.Visible = false end
                mainFrame.Visible = true 
            end
        end
    elseif kc == Enum.KeyCode.C then
        if not isAutoDumping and (tick() - ePressedTime) <= TIME_WINDOW then
            if waypointFrame and not waypointFrame.Visible then
                if mainFrame then mainFrame.Visible = false end
                waypointFrame.Visible = true
            end
        end
    elseif kc == Enum.KeyCode.T then
        if targetWaypoint and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and not isAutoDumping then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetWaypoint.position - Vector3.new(0, 9, 0))
        end
    elseif kc == Enum.KeyCode.H then
        if not isAutoDumping then
            if Settings.EnableMassSort or Settings.EnableSort then
                if isSortingBusy then cancelSorting = true; if updateMasterToggleVisual then updateMasterToggleVisual(false) end else task.spawn(executeSortingLogic) end
            else
                local newState = not Settings.MasterFarm
                if updateMasterToggleVisual then updateMasterToggleVisual(newState) end
                toggleMasterFarm(newState) 
            end
        end
    end
end)

updateESPLogic()
if Settings.MasterFarm then toggleMasterFarm(true) end
