-- Pidromania Hub: Apocalypse (оптимизированная версия, компактный UI сохранён)

-- Если хаб уже запущен в этой сессии - гасим старый экземпляр
if getgenv().ApocHubStop then pcall(getgenv().ApocHubStop) end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local DEBUG = false
local function DBG(msg) if DEBUG then warn("[Apocalypse] " .. tostring(msg)) end end

------------------------------------------------------------------
-- Утилиты
------------------------------------------------------------------
local connections = {}
local function track(conn) connections[#connections + 1] = conn return conn end

local function guiParent()
    local ok, core = pcall(function() return game:GetService("CoreGui") end)
    if ok and core then return core end
    return playerGui
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local function round(obj, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj) end

-- Безопасное получение Enum.KeyCode по имени (неверное имя не роняет цикл фарма)
local function keyCode(name)
    local ok, kc = pcall(function() return Enum.KeyCode[name] end)
    return ok and kc or nil
end

local function tapKey(kc, hold)
    if not kc then return end
    VIM:SendKeyEvent(true, kc, false, game)
    task.wait(hold or 0.05)
    VIM:SendKeyEvent(false, kc, false, game)
end

local function clickAt(x, y, hold)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(hold or 0.02)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

local function charParts()
    local c = player.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChild("Humanoid")
end

local function getValidPosition(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("Model") then
        return obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

-- Фоновые циклы с общим флагом остановки
local alive = true
local function loop(interval, fn)
    task.spawn(function()
        while alive do
            pcall(fn)
            task.wait(interval)
        end
    end)
end

------------------------------------------------------------------
-- Локализация
------------------------------------------------------------------
local currentLang = "ru"
local function L(ru, uk, en) return {ru = ru, uk = uk, en = en} end

local FOLDER_NAME = "PidromaniaHub"
local FILE_NAME = FOLDER_NAME .. "/Config.json"

-- Названия предметов: если нет в таблице, показывается английское имя из игры
local ITEMS = {
    IronOre = L("Железная руда", "Залізна руда", "Iron Ore"), CopperOre = L("Медная руда", "Мідна руда", "Copper Ore"),
    Coal = L("Уголь", "Вугілля", "Coal"), Stone = L("Камень", "Камінь", "Stone"), Sandstone = L("Песчаник", "Пісковик", "Sandstone"),
    Tree1 = L("Дерево 1", "Дерево 1", "Tree 1"), BlueberryBush = L("Черника", "Чорниця", "Blueberries"),
    StrawberryBush = L("Клубника", "Полуниця", "Strawberries"), PotatoPlant = L("Картошка", "Картопля", "Potatoes"),
    CommonLoot = L("Обычный сундук", "Звичайна скриня", "Common chest"), UncommonLoot = L("Необычный сундук", "Незвичайна скриня", "Uncommon chest"),
    RareLoot = L("Редкий сундук", "Рідкісна скриня", "Rare chest"), AirDrop = L("Аирдроп", "Аірдроп", "Airdrop"),
    Bandage = L("Бинт", "Бинт", "Bandage"), Medkit = L("Аптечка", "Аптечка", "Medkit"), Wood = L("Доски", "Дошки", "Planks"),
    Scrap = L("Металлолом", "Металобрухт", "Scrap"), Cloth = L("Ткань", "Тканина", "Cloth"), Gunpowder = L("Порох", "Порох", "Gunpowder"),
    Plastic = L("Пластик", "Пластик", "Plastic"), MRE = L("Сухпаёк", "Сухпайок", "MRE"), Painkillers = L("Обезболивающее", "Знеболювальне", "Painkillers"),
    ["Blood Bag"] = L("Пакет крови", "Пакет крові", "Blood bag"),
    Group_Keycard = L("🗑️ Ключ-карты (все)", "🗑️ Ключ-карти (усі)", "🗑️ Keycards (all)"),
    Group_Bottle = L("🗑️ Бутылки/вода (все)", "🗑️ Пляшки/вода (усі)", "🗑️ Bottles/water (all)"),
    Group_Canned = L("🗑️ Консервы/бобы (все)", "🗑️ Консерви/боби (усі)", "🗑️ Canned food (all)"),
}
local function GetTrans(name)
    local v = ITEMS[name]
    return v and (v[currentLang] or v.en or v.ru) or name
end

local translations = {
    ru = {
        hubTitle = "Pidromania Hub: Apocalypse", langSettings = "--- Язык / Language ---",
        helpTab = "Помощь", farmTab = "Фарм", sortTab = "Сортировка", tpTab = "Телепорты", protectTab = "Защита", settingsTab = "Настройки",
        helpText = "ИНСТРУКЦИЯ:\n\n1. E -> G = открыть/закрыть меню.\n2. E -> C = создать вейпоинт.\n3. Вкладка «Телепорты» = ТП к точкам.\n4. T = быстрый ТП к ближайшей точке.\n5. СТАРТ / СТОП на клавишу H.\n6. СОРТИРОВКА: авто-сетка (змейка), предметы ложатся ровно в ряд.\n7. АВТО-СБРОС: скрипт сам выкидывает вещи, когда нет места.",
        trees = "Деревья (все типы)", plants = "Растения (ягоды и др.)", zombies = "Зомби (ходьба и авто-атака)",
        keyTrees = "Кнопка (деревья):", keyOres = "Кнопка (руды/камни):", keyWeapon = "Кнопка (оружие):",
        masterFarm = "Старт / Стоп", autoSaveLife = "Авто-сейв (< 30% ХП)",
        catTrees = "Деревья, листья", catOres = "Руды и камни", catPlantsChests = "Растения и сундуки", catZombies = "Враги", catProtection = "Автоматическая защита",
        catSaved = "--- Сохранённые точки ---", noSaved = "Нет сохранённых точек", btnDel = "Удалить", btnTp = "Телепортироваться",
        catFriends = "--- Друзья на сервере ---", noFriends = "Нет друзей на сервере", btnTpFriend = "ТП к другу",
        catBase = "--- База (умный дом) ---", btnResetBase = "Сбросить память умного дома",
        catEspModes = "--- Управление ESP ---", catSortModes = "--- Режимы сортировки ---", catSelectItems = "--- Выбор предметов ---",
        btnScan = "🔍 Сканировать предметы (вокруг и инвентарь)", btnClear = "🗑 Очистить игнор-лист",
        wpTitle = "Новая точка (вейпоинт)", wpInput = "Введите название...", wpDefault = "Точка", homeName = "ДОМ",
        btnNormal = "Обычная", btnPerm = "Вечная ⭐", btnHome = "Дом 🏠", btnCancel = "Отмена",
        confirmDel = "Точно удалить?", btnYes = "Да, удалить", btnNo = "Нет, не удалять",
        baseFound = "Найден дом на координатах: %d, %d, %d", baseWait = "Скрипт ещё изучает карту... Постой на базе без фарма 30 сек.",
        espLabel = "ESP: %s", espNone = "ESP: ...", bossEsp = "ESP: 👹 Алтарь босса", bossAltar = "👹 Алтарь босса",
        sort1Label = "1 ПРЕДМЕТ: %s (H)", sort1None = "1 ПРЕДМЕТ: ... (H)", massSort = "МАССОВАЯ СОРТИРОВКА (авто-сетка) (H)",
        btnSort1 = "Сорт. 1", btnIgnore = "Игнор ❌", emptyList = "Пусто (или всё в игноре).",
        langRu = "Русский", langUk = "Українська", langEn = "English",
    },
    uk = {
        helpTab = "Допомога", farmTab = "Фарм", sortTab = "Сортування", tpTab = "Телепорти", protectTab = "Захист", settingsTab = "Налаштування",
        helpText = "ІНСТРУКЦІЯ:\n\n1. E -> G = відкрити/закрити меню.\n2. E -> C = створити вейпоінт.\n3. Вкладка «Телепорти» = ТП до точок.\n4. T = швидкий ТП до найближчої точки.\n5. СТАРТ / СТОП на клавішу H.\n6. СОРТУВАННЯ: авто-сітка (змійка), предмети лягають рівно в ряд.\n7. АВТО-СКИДАННЯ: скрипт сам викидає речі, коли немає місця.",
        trees = "Дерева (усі типи)", plants = "Рослини (ягоди та ін.)", zombies = "Зомбі (ходьба та авто-атака)",
        keyTrees = "Кнопка (дерева):", keyOres = "Кнопка (руди/каміння):", keyWeapon = "Кнопка (зброя):",
        masterFarm = "Старт / Стоп", autoSaveLife = "Авто-сейв (< 30% ХП)",
        catTrees = "Дерева, листя", catOres = "Руди та каміння", catPlantsChests = "Рослини та скрині", catZombies = "Вороги", catProtection = "Автоматичний захист",
        catSaved = "--- Збережені точки ---", noSaved = "Немає збережених точок", btnDel = "Видалити", btnTp = "Телепортуватися",
        catFriends = "--- Друзі на сервері ---", noFriends = "Немає друзів на сервері", btnTpFriend = "ТП до друга",
        catBase = "--- База (розумний дім) ---", btnResetBase = "Скинути пам'ять розумного дому",
        catEspModes = "--- Керування ESP ---", catSortModes = "--- Режими сортування ---", catSelectItems = "--- Вибір предметів ---",
        btnScan = "🔍 Сканувати предмети (навколо та інвентар)", btnClear = "🗑 Очистити ігнор-лист",
        wpTitle = "Нова точка (вейпоінт)", wpInput = "Введіть назву...", wpDefault = "Точка", homeName = "ДІМ",
        btnNormal = "Звичайна", btnPerm = "Вічна ⭐", btnHome = "Дім 🏠", btnCancel = "Скасувати",
        confirmDel = "Точно видалити?", btnYes = "Так, видалити", btnNo = "Ні, не видаляти",
        baseFound = "Знайдено дім за координатами: %d, %d, %d", baseWait = "Скрипт ще вивчає карту... Постій на базі без фарму 30 сек.",
        espNone = "ESP: ...", bossEsp = "ESP: 👹 Вівтар боса", bossAltar = "👹 Вівтар боса",
        sort1Label = "1 ПРЕДМЕТ: %s (H)", sort1None = "1 ПРЕДМЕТ: ... (H)", massSort = "МАСОВЕ СОРТУВАННЯ (авто-сітка) (H)",
        btnSort1 = "Сорт. 1", btnIgnore = "Ігнор ❌", emptyList = "Порожньо (або все в ігнорі).",
    },
    en = {
        helpTab = "Help", farmTab = "Farm", sortTab = "Sort", tpTab = "Teleports", protectTab = "Protect", settingsTab = "Settings",
        helpText = "INSTRUCTIONS:\n\n1. E -> G = open/close the menu.\n2. E -> C = create a waypoint.\n3. 'Teleports' tab = TP to waypoints.\n4. T = quick TP to the nearest waypoint.\n5. START / STOP on the H key.\n6. SORTING: auto-grid (snake), items line up in a row.\n7. AUTO-DROP: the script drops items when your inventory is full.",
        trees = "Trees (all types)", plants = "Plants (berries etc.)", zombies = "Zombies (walk and auto-attack)",
        keyTrees = "Key (trees):", keyOres = "Key (ores/stones):", keyWeapon = "Key (weapon):",
        masterFarm = "Start / Stop", autoSaveLife = "Auto-save (< 30% HP)",
        catTrees = "Trees, leaves", catOres = "Ores and stones", catPlantsChests = "Plants and chests", catZombies = "Enemies", catProtection = "Automatic protection",
        catSaved = "--- Saved waypoints ---", noSaved = "No saved waypoints", btnDel = "Delete", btnTp = "Teleport",
        catFriends = "--- Friends on server ---", noFriends = "No friends on the server", btnTpFriend = "TP to friend",
        catBase = "--- Base (smart home) ---", btnResetBase = "Reset smart home memory",
        catEspModes = "--- ESP control ---", catSortModes = "--- Sorting modes ---", catSelectItems = "--- Item selection ---",
        btnScan = "🔍 Scan items (around and inventory)", btnClear = "🗑 Clear ignore list",
        wpTitle = "New waypoint", wpInput = "Enter a name...", wpDefault = "Waypoint", homeName = "HOME",
        btnNormal = "Normal", btnPerm = "Permanent ⭐", btnHome = "Home 🏠", btnCancel = "Cancel",
        confirmDel = "Are you sure?", btnYes = "Yes, delete", btnNo = "No, cancel",
        baseFound = "Home found at coordinates: %d, %d, %d", baseWait = "The script is learning the map... Stand at your base without farming for 30 s.",
        espNone = "ESP: ...", bossEsp = "ESP: 👹 Boss altar", bossAltar = "👹 Boss altar",
        sort1Label = "1 ITEM: %s (H)", sort1None = "1 ITEM: ... (H)", massSort = "MASS SORT (auto-grid) (H)",
        btnSort1 = "Sort 1", btnIgnore = "Ignore ❌", emptyList = "Empty (or all ignored).",
    },
}

local function T(key)
    local l = translations[currentLang]
    return (l and l[key]) or translations.ru[key] or key
end

------------------------------------------------------------------
-- Настройки и конфиг
------------------------------------------------------------------
local GAME_OBJECTS = {
    Trees = {"Tree1", "Tree2", "Tree3", "Tree4", "Tree5", "Palm1", "Palm2", "Palm3", "DeadTree1", "DeadTree2", "DeadTree3"},
    Ores = {"IronOre", "CopperOre", "Coal", "Stone", "Sandstone"},
    Loot = {"CommonLoot", "UncommonLoot", "RareLoot", "AirDrop"},
    Plants = {"BlueberryBush", "StrawberryBush", "PotatoPlant"},
    Zombies = {"Zombie", "Mutant Zombie", "Headless", "Radioactive", "Charged", "Infected"},
}

local KEY_MAP = {["1"] = "One", ["2"] = "Two", ["3"] = "Three", ["4"] = "Four", ["5"] = "Five",
    ["6"] = "Six", ["7"] = "Seven", ["8"] = "Eight", ["9"] = "Nine", ["0"] = "Zero"}
local KEY_MAP_REVERSE = {}
for num, name in pairs(KEY_MAP) do KEY_MAP_REVERSE[name] = num end
local function parseKey(str) return KEY_MAP[str] or str end

local Settings = {
    TreeKey = "One", OreKey = "Four", WeaponKey = "Three",
    MasterFarm = false, AutoSaveLife = false,
    BaseTracker = {},
    EnableESP = false, TargetESP = "",
    EnableBossESP = false,
    EnableSort = false, TargetSort = "",
    EnableMassSort = false,
    IgnoreList = {},
    SavedWaypoints = {},
}

local SelectedTargets = {
    Trees = false, IronOre = false, CopperOre = false, Coal = false, Stone = false, Sandstone = false,
    CommonLoot = false, UncommonLoot = false, RareLoot = false, AirDrop = false, Plants = false,
    Zombies = false,
}

local function SaveConfig()
    if not (writefile and isfolder) then return end
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    pcall(function()
        writefile(FILE_NAME, HttpService:JSONEncode({lang = currentLang, Settings = Settings, SelectedTargets = SelectedTargets}))
    end)
end

pcall(function()
    if not (readfile and isfile and isfile(FILE_NAME)) then return end
    local data = HttpService:JSONDecode(readfile(FILE_NAME))
    if translations[data.lang] then currentLang = data.lang end
    if type(data.Settings) == "table" then
        for k, v in pairs(data.Settings) do Settings[k] = v end
        if type(Settings.IgnoreList) ~= "table" then Settings.IgnoreList = {} end
        if type(Settings.SavedWaypoints) ~= "table" then Settings.SavedWaypoints = {} end
        if type(Settings.BaseTracker) ~= "table" then Settings.BaseTracker = {} end
    end
    if type(data.SelectedTargets) == "table" then
        for k, v in pairs(data.SelectedTargets) do SelectedTargets[k] = v end
    end
end)

-- Группировка мусорных предметов
local function GetItemGroup(name)
    local n = string.lower(name)
    if string.find(n, "keycard", 1, true) then return "Group_Keycard"
    elseif string.find(n, "bottle", 1, true) or string.find(n, "water", 1, true) or string.find(n, "soda", 1, true) then return "Group_Bottle"
    elseif string.find(n, "canned", 1, true) or string.find(n, "beans", 1, true) or string.find(n, "soup", 1, true) then return "Group_Canned"
    end
    return name
end

------------------------------------------------------------------
-- Кастомный курсор
------------------------------------------------------------------
local cursorGui = new("ScreenGui", {Name = "ApocCustomCursor", ResetOnSpawn = false, DisplayOrder = 9999999, IgnoreGuiInset = true}, guiParent())
local cursorDot = new("Frame", {Size = UDim2.new(0, 6, 0, 6), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = Color3.fromRGB(255, 50, 50), BorderSizePixel = 0}, cursorGui)
round(cursorDot, 100)
UserInputService.MouseIconEnabled = false

------------------------------------------------------------------
-- Вейпоинты
------------------------------------------------------------------
local waypointFolder = new("Folder", {Name = "ApocWaypoints"}, Workspace)
local ActiveWaypoints = {}
local targetWaypoint = nil
local tempFarmCFrame = nil

-- kind: "normal" | "temp" | "home"
local function CreateWaypoint(name, color, customPos, isPermanent, kind)
    local pos = customPos
    if not pos then
        local _, hrp = charParts()
        if not hrp then return end
        pos = hrp.Position + Vector3.new(0, 12, 0)
    end
    local part = new("Part", {Size = Vector3.new(3, 3, 3), Anchored = true, CanCollide = false, Material = Enum.Material.Neon, Color = color, Transparency = 0.2,
        CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(45), math.rad(45), math.rad(45))}, waypointFolder)
    local highlight = new("Highlight", {Adornee = part, FillColor = color, OutlineColor = Color3.new(1, 1, 1), DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = 0.4, OutlineTransparency = 0.4}, part)
    local bgui = new("BillboardGui", {Adornee = part, Size = UDim2.new(0, 150, 0, 40), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true}, part)
    local label = new("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = name, TextColor3 = color, TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextSize = 20}, bgui)
    ActiveWaypoints[#ActiveWaypoints + 1] = {part = part, highlight = highlight, label = label, position = pos, isPermanent = isPermanent or false, kind = kind or "normal"}
end

for _, wp in ipairs(Settings.SavedWaypoints) do
    if wp.name and wp.color and wp.pos then
        local isHome = wp.home or wp.name == "ДОМ"
        CreateWaypoint(isHome and T("homeName") or wp.name, Color3.new(wp.color.r, wp.color.g, wp.color.b),
            Vector3.new(wp.pos.x, wp.pos.y, wp.pos.z), true, isHome and "home" or "normal")
    end
end

-- Один RenderStepped: вращение вейпоинтов, выбор того, на который смотрим, и курсор
track(RunService.RenderStepped:Connect(function()
    local mouse = UserInputService:GetMouseLocation()
    cursorDot.Position = UDim2.new(0, mouse.X, 0, mouse.Y)

    local cam = Workspace.CurrentCamera
    local bestDot, bestWp = -1, nil
    for _, wp in ipairs(ActiveWaypoints) do
        if wp.part and wp.part.Parent then
            wp.part.CFrame = wp.part.CFrame * CFrame.Angles(0, math.rad(1), 0)
            local dot = cam.CFrame.LookVector:Dot((wp.part.Position - cam.CFrame.Position).Unit)
            if dot > 0.96 then
                wp.highlight.FillTransparency, wp.highlight.OutlineTransparency, wp.label.TextSize = 0.05, 0, 24
                if dot > bestDot then bestDot, bestWp = dot, wp end
            else
                wp.highlight.FillTransparency, wp.highlight.OutlineTransparency, wp.label.TextSize = 0.4, 0.4, 18
            end
        end
    end
    targetWaypoint = bestWp
end))

local function removeTempWaypoints()
    for i = #ActiveWaypoints, 1, -1 do
        if ActiveWaypoints[i].kind == "temp" then
            if ActiveWaypoints[i].part then ActiveWaypoints[i].part:Destroy() end
            table.remove(ActiveWaypoints, i)
        end
    end
end

------------------------------------------------------------------
-- Кэш целей (анти-лаг)
------------------------------------------------------------------
local cachedTargets = {tree = {}, ore = {}, plant = {}, loot = {}, zombie = {}}

local function refreshCache()
    for _, v in pairs(cachedTargets) do table.clear(v) end
    local active = {}
    if SelectedTargets.Trees then for _, n in ipairs(GAME_OBJECTS.Trees) do active[n] = "tree" end end
    if SelectedTargets.Plants then for _, n in ipairs(GAME_OBJECTS.Plants) do active[n] = "plant" end end
    if SelectedTargets.Zombies then for _, n in ipairs(GAME_OBJECTS.Zombies) do active[n] = "zombie" end end
    for _, n in ipairs(GAME_OBJECTS.Ores) do if SelectedTargets[n] then active[n] = "ore" end end
    for _, n in ipairs(GAME_OBJECTS.Loot) do if SelectedTargets[n] then active[n] = "loot" end end
    if next(active) == nil then return end

    for _, folderName in ipairs({"Spawned", "Temporal", "Enemies"}) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            local desc = folder:GetDescendants()
            for i = 1, #desc do
                if i % 800 == 0 then task.wait() end
                local obj = desc[i]
                local cat = active[obj.Name]
                if cat and (obj:IsA("Model") or obj:IsA("BasePart")) then table.insert(cachedTargets[cat], obj) end
            end
        end
    end
end

loop(2, function() if Settings.MasterFarm then refreshCache() end end)

------------------------------------------------------------------
-- Умный дом (где игрок проводит больше всего времени)
------------------------------------------------------------------
local GRID_SIZE = 50

local function getBestBaseLocation()
    local bestKey, maxCount = nil, 0
    for key, data in pairs(Settings.BaseTracker) do
        if data.count > maxCount then maxCount, bestKey = data.count, key end
    end
    if bestKey and maxCount >= 5 then
        local d = Settings.BaseTracker[bestKey]
        return Vector3.new(d.x, d.y + 3, d.z)
    end
end

loop(5, function()
    if Settings.MasterFarm then return end
    local _, hrp, hum = charParts()
    if not (hrp and hum and hum.Health > 0 and hum.FloorMaterial ~= Enum.Material.Air) then return end
    local pos = hrp.Position
    local key = string.format("%d,%d,%d", math.floor(pos.X / GRID_SIZE), math.floor(pos.Y / GRID_SIZE), math.floor(pos.Z / GRID_SIZE))
    local entry = Settings.BaseTracker[key]
    if not entry then entry = {count = 0, x = pos.X, y = pos.Y, z = pos.Z} Settings.BaseTracker[key] = entry end
    entry.count = entry.count + 1
    if entry.count % 6 == 0 then SaveConfig() end
end)

------------------------------------------------------------------
-- Авто-сейв
------------------------------------------------------------------
local toggleMasterFarm, updateMasterToggleVisual
local autoSaveCooldown, autoSaveTpCount = false, 0

loop(0.2, function()
    if not Settings.AutoSaveLife or autoSaveCooldown then return end
    local _, hrp, hum = charParts()
    if not (hrp and hum and hum.Health > 0 and hum.MaxHealth > 0) then return end
    local ratio = hum.Health / hum.MaxHealth
    if ratio > 0.40 then autoSaveTpCount = 0 end
    if ratio > 0.30 then return end

    autoSaveCooldown = true
    if Settings.MasterFarm and toggleMasterFarm then
        toggleMasterFarm(false)
        if updateMasterToggleVisual then updateMasterToggleVisual(false) end
    end

    -- Не больше двух спасительных телепортов подряд
    if autoSaveTpCount < 2 then
        autoSaveTpCount = autoSaveTpCount + 1
        local targetPos
        for _, wp in ipairs(ActiveWaypoints) do                       -- приоритет 1: точка «дом»
            if wp.kind == "home" then targetPos = wp.position + Vector3.new(0, 5, 0) break end
        end
        if not targetPos then                                          -- приоритет 2: ближайшая точка
            local bestWp, bestDist = nil, math.huge
            for _, wp in ipairs(ActiveWaypoints) do
                if wp.kind ~= "temp" then
                    local d = (wp.position - hrp.Position).Magnitude
                    if d < bestDist then bestDist, bestWp = d, wp end
                end
            end
            if bestWp then targetPos = bestWp.position + Vector3.new(0, 5, 0) end
        end
        if targetPos then
            hrp.CFrame = CFrame.new(targetPos)
        else
            local autoBase = getBestBaseLocation()
            hrp.CFrame = autoBase and CFrame.new(autoBase) or (hrp.CFrame + Vector3.new(0, 1000, 0))
        end
    else
        DBG("Авто-сейв: лимит телепортов исчерпан (2/2)")
    end
    task.delay(5, function() autoSaveCooldown = false end)
end)

------------------------------------------------------------------
-- ESP предметов и алтаря босса
------------------------------------------------------------------
local itemsFolder = Workspace:WaitForChild("Items", 10)
local espItemConns = {}

local function addBillboard(parent, adornee, name, text, color, offset)
    local bb = new("BillboardGui", {Name = name, Adornee = adornee, Size = UDim2.new(0, 200, 0, 50), StudsOffset = Vector3.new(0, offset, 0), AlwaysOnTop = true}, nil)
    new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = text, TextColor3 = color, TextStrokeTransparency = 0, TextStrokeColor3 = Color3.new(0, 0, 0), Font = Enum.Font.GothamBold, TextSize = 20}, bb)
    bb.Parent = parent
end

local function createTargetESP(item)
    if not Settings.EnableESP or Settings.TargetESP == "" then return end
    if not item:IsA("Model") or GetItemGroup(item.Name) ~= Settings.TargetESP then return end
    if item:FindFirstChild("TargetItemESP") then return end
    task.wait(0.1)
    local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
    if part then addBillboard(item, part, "TargetItemESP", GetTrans(Settings.TargetESP), Color3.fromRGB(0, 255, 127), 1.5) end
end

local function updateESPLogic()
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            local old = item:FindFirstChild("TargetItemESP")
            if old then old:Destroy() end
        end
    end
    for _, c in ipairs(espItemConns) do c:Disconnect() end
    table.clear(espItemConns)
    if Settings.EnableESP and Settings.TargetESP ~= "" and itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do task.spawn(createTargetESP, item) end
        espItemConns[1] = itemsFolder.ChildAdded:Connect(function(item) createTargetESP(item) end)
    end
end

loop(2, function()
    local map = Workspace:FindFirstChild("Map")
    local enemies = map and map:FindFirstChild("Enemies")
    local spawners = enemies and enemies:FindFirstChild("Spawners")
    if not spawners then return end
    for _, obj in ipairs(spawners:GetChildren()) do
        if string.find(string.lower(obj.Name), "boss altar", 1, true) then
            local old = obj:FindFirstChild("BossAltarESP")
            if Settings.EnableBossESP then
                if not old then
                    local part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    if part then addBillboard(obj, part, "BossAltarESP", T("bossAltar"), Color3.fromRGB(255, 50, 50), 5) end
                else
                    old:FindFirstChildOfClass("TextLabel").Text = T("bossAltar")
                end
            elseif old then
                old:Destroy()
            end
        end
    end
end)

------------------------------------------------------------------
-- Инвентарь: авто-сброс и сортировка
------------------------------------------------------------------
local INVENTORY_KEY, DROP_KEY = Enum.KeyCode.E, Enum.KeyCode.G
local isAutoDumping = false
local SKIP_NAMES = {Icon = true, Locked = true, Lock = true, UIListLayout = true, UICorner = true, Image = true, Background = true}
local LAYOUT_NAMES = {UIListLayout = true, UIGridLayout = true, UIPadding = true}

local function getInvRoot()
    local menu = playerGui:FindFirstChild("Menu")
    local inv = menu and menu:FindFirstChild("Inventory")
    return inv and inv:FindFirstChild("Inventory")
end

local function isSlot(s)
    return (s:IsA("Frame") or s:IsA("ImageLabel") or s:IsA("ImageButton")) and not LAYOUT_NAMES[s.Name]
end

local function isSlotLocked(slot)
    for _, d in ipairs(slot:GetDescendants()) do
        if (d.Name == "Locked" or d.Name == "Lock") and d:IsA("GuiObject") and d.Visible then
            if d.BackgroundTransparency < 0.9 or (d:IsA("ImageLabel") and d.ImageTransparency < 0.9) then return true end
        end
    end
    return false
end

-- Имена предметов в ячейке (картинки, которые не служебные)
local function slotItemNames(slot)
    local names = {}
    for _, d in ipairs(slot:GetDescendants()) do
        if d:IsA("ImageLabel") and not SKIP_NAMES[d.Name] then names[#names + 1] = d.Name end
    end
    return names
end

-- true, если нет ни одной свободной разблокированной ячейки
local function inventoryFull()
    local inv = getInvRoot()
    if not inv then return false end
    local total, empty = 0, 0
    for _, slot in ipairs(inv:GetChildren()) do
        if isSlot(slot) and not isSlotLocked(slot) then
            total = total + 1
            if #slotItemNames(slot) == 0 then empty = empty + 1 end
        end
    end
    return total > 0 and empty == 0
end

local function slotCenter(slot)
    return slot.AbsolutePosition.X + slot.AbsoluteSize.X / 2,
        slot.AbsolutePosition.Y + slot.AbsoluteSize.Y / 2 + GuiService:GetGuiInset().Y
end

local function toggleInventory(wait) tapKey(INVENTORY_KEY) task.wait(wait) end

local function performAutoDump()
    if isAutoDumping then return end
    isAutoDumping = true
    DBG("Авто-сброс: освобождаем все ячейки")
    tapKey(Enum.KeyCode.R)
    task.wait(0.4)
    toggleInventory(1.5)

    local inv = getInvRoot()
    if inv then
        for _, slot in ipairs(inv:GetChildren()) do
            if not Settings.MasterFarm then break end
            if isSlot(slot) and not isSlotLocked(slot) then
                local x, y = slotCenter(slot)
                VIM:SendMouseMoveEvent(0, 0, game)
                task.wait(0.05)
                VIM:SendMouseMoveEvent(x, y, game)
                task.wait(0.2)
                tapKey(DROP_KEY, 0.1)
                task.wait(0.2)
            end
        end
    end
    task.wait(0.3)
    toggleInventory(0.8)
    isAutoDumping = false
end

local isSortingBusy, cancelSorting = false, false

local function scanAllItems()
    local found, list = {}, {}
    local function add(name)
        local grp = GetItemGroup(name)
        if not found[grp] and not Settings.IgnoreList[grp] then found[grp] = true list[#list + 1] = grp end
    end
    local inv = getInvRoot()
    if inv then
        for _, slot in ipairs(inv:GetChildren()) do
            if isSlot(slot) then
                for _, n in ipairs(slotItemNames(slot)) do add(n) end
            end
        end
    end
    if itemsFolder then
        for _, item in ipairs(itemsFolder:GetChildren()) do
            if item:IsA("Model") then add(item.Name) end
        end
    end
    table.sort(list)
    return list
end

local function setItemPhysics(item, anchored, collide, cframe)
    for _, part in ipairs(item:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored, part.CanCollide = anchored, collide
            if cframe then part.CFrame = cframe end
        end
    end
end

local function performSingleSort(targetName)
    local _, root = charParts()
    local cam = Workspace.CurrentCamera
    if not root or not itemsFolder then return end

    local found = {}
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") and GetItemGroup(item.Name) == targetName then found[#found + 1] = item end
    end

    if #found > 0 then
        -- Собираем все предметы в одну точку перед собой и подбираем кликами
        local targetPos = (root.CFrame * CFrame.new(0, 1.5, -3.5)).Position
        for _, item in ipairs(found) do setItemPhysics(item, true, false, CFrame.new(targetPos)) end
        task.wait(1.5)
        if cancelSorting then return end

        cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
        task.wait(0.1)
        local cx, cy = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
        for _ = 1, math.ceil(#found * 1.5) do
            if cancelSorting then break end
            clickAt(cx, cy, 0.02)
            task.wait(0.4)
        end
        for _, item in ipairs(found) do
            if item and item.Parent then setItemPhysics(item, false, true) end
        end
        if cancelSorting then return end
        task.wait(1)
    end
    if cancelSorting then return end

    toggleInventory(0.6)
    local inv = getInvRoot()
    if inv then
        while not cancelSorting do
            local targetSlot
            for _, slot in ipairs(inv:GetChildren()) do
                if isSlot(slot) then
                    local names = slotItemNames(slot)
                    local last = names[#names]
                    if last and GetItemGroup(last) == targetName then targetSlot = slot break end
                end
            end
            if not targetSlot then break end
            local x, y = slotCenter(targetSlot)
            VIM:SendMouseMoveEvent(x, y, game)
            task.wait(0.1)
            if cancelSorting then break end
            tapKey(DROP_KEY, 0.05)
            task.wait(0.3)
        end
    end
    task.wait(0.3)
    toggleInventory(0.4)
end

local function executeSortingLogic()
    if isSortingBusy then return end
    isSortingBusy, cancelSorting = true, false
    if updateMasterToggleVisual then updateMasterToggleVisual(true) end

    if Settings.EnableMassSort then
        local items = scanAllItems()
        local _, root = charParts()
        if root then
            local startCF = root.CFrame
            local gridWidth = 4
            for i, name in ipairs(items) do
                if cancelSorting then break end
                local idx = i - 1
                local row, col = math.floor(idx / gridWidth), idx % gridWidth
                if row % 2 ~= 0 then col = (gridWidth - 1) - col end -- змейка
                root.CFrame = startCF * CFrame.new(col * 5, 2, row * 5)
                task.wait(0.2)
                if cancelSorting then break end
                performSingleSort(name)
            end
        end
    elseif Settings.EnableSort and Settings.TargetSort ~= "" then
        performSingleSort(Settings.TargetSort)
    end

    isSortingBusy = false
    if updateMasterToggleVisual then updateMasterToggleVisual(false) end
end

------------------------------------------------------------------
-- Логика фарма
------------------------------------------------------------------
local farmLoopActive, isAttacking = false, false
local activeKeyStr, currentFocusTarget = nil, nil

-- Поворот к зомби
track(RunService.Heartbeat:Connect(function()
    local target = currentFocusTarget
    if Settings.MasterFarm and target and target.Parent then
        local zHum = target:FindFirstChildOfClass("Humanoid")
        if zHum and zHum.Health > 0 then
            local tPos = getValidPosition(target)
            local _, hrp = charParts()
            if tPos and hrp then hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(tPos.X, hrp.Position.Y, tPos.Z)) end
            return
        end
    end
    currentFocusTarget = nil
end))

-- Атака: если в руках нет инструмента - достаём нужный, затем клик в центр экрана
loop(0.056, function()
    if not (Settings.MasterFarm and isAttacking) then task.wait(0.05) return end
    local char = player.Character
    local kc = activeKeyStr and keyCode(activeKeyStr)
    if char and kc and not char:FindFirstChildOfClass("Tool") then tapKey(kc, 0.02) end
    local vs = Workspace.CurrentCamera.ViewportSize
    clickAt(math.floor(vs.X / 2), math.floor(vs.Y / 2), 0.01)
end)

local function dumpIfFull(humanoid, rootPart)
    if inventoryFull() then
        humanoid:MoveTo(rootPart.Position)
        isAttacking, activeKeyStr = false, nil
        performAutoDump()
        return true
    end
    return false
end

local function nearestOf(list, charPos)
    local best, bestDist = nil, math.huge
    for _, obj in ipairs(list) do
        local pos = getValidPosition(obj)
        if pos then
            local d = (pos - charPos).Magnitude
            if d < bestDist then best, bestDist = obj, d end
        end
    end
    return best
end

local function executeFarmStep()
    if isAutoDumping then return end
    local character, rootPart, humanoid = charParts()
    if not (character and rootPart and humanoid) then return end
    local charPos = rootPart.Position

    -- 1) Зомби: подходим и бьём
    if SelectedTargets.Zombies then
        local nearest, minDist = nil, 100
        for _, z in ipairs(cachedTargets.zombie) do
            local zHum = z:FindFirstChildOfClass("Humanoid")
            local zPos = zHum and zHum.Health > 0 and getValidPosition(z)
            if zPos then
                local d = (zPos - charPos).Magnitude
                if d <= minDist then minDist, nearest = d, z end
            end
        end
        if nearest then
            currentFocusTarget = nearest
            local wkc = keyCode(Settings.WeaponKey or "Three")
            if wkc and not character:FindFirstChildOfClass("Tool") then tapKey(wkc) end
            if minDist > 6 then humanoid:MoveTo(getValidPosition(nearest)) else humanoid:MoveTo(charPos) end
            activeKeyStr, isAttacking = nil, true
            return
        end
    end
    currentFocusTarget = nil
    if isAttacking and activeKeyStr == nil then isAttacking = false end

    -- 2) Деревья и руды: подтягиваем до 10 ближайших перед собой
    local found = {}
    for _, cat in ipairs({"tree", "ore"}) do
        for _, obj in ipairs(cachedTargets[cat]) do
            local pos = getValidPosition(obj)
            if pos then
                local d = (pos - charPos).Magnitude
                if d <= 150 then found[#found + 1] = {obj = obj, dist = d, cat = cat} end
            end
        end
    end
    if #found > 0 then
        table.sort(found, function(a, b) return a.dist < b.dist end)
        local frontCF = rootPart.CFrame * CFrame.new(0, 0, -4)
        local hasTree = false
        for i = 1, math.min(10, #found) do
            local item = found[i]
            if item.cat == "tree" then hasTree = true end
            pcall(function()
                setItemPhysics(item.obj, true, false)
                if item.obj:IsA("BasePart") then item.obj.Anchored, item.obj.CanCollide = true, false end
                if item.obj:IsA("Model") then item.obj:PivotTo(frontCF) else item.obj.CFrame = frontCF end
            end)
        end
        activeKeyStr = hasTree and Settings.TreeKey or Settings.OreKey
        isAttacking = true
        return
    end
    isAttacking, activeKeyStr = false, nil

    -- 3) Сундуки: телепорт, два F, затем возврат в точку фарма
    local nearestLoot = nearestOf(cachedTargets.loot, charPos)
    if nearestLoot then
        if dumpIfFull(humanoid, rootPart) then return end
        local tPos = getValidPosition(nearestLoot)
        if tPos and tempFarmCFrame then
            rootPart.CFrame = CFrame.new(tPos + Vector3.new(0, 4, 0))
            task.wait(0.3)
            if not Settings.MasterFarm then return end

            local cam = Workspace.CurrentCamera
            cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(math.rad(-89), 0, 0)
            task.wait(0.2)
            if not Settings.MasterFarm then return end

            tapKey(Enum.KeyCode.F)
            task.wait(0.15)
            tapKey(Enum.KeyCode.F)
            task.wait(2.0)
            if not Settings.MasterFarm then return end

            tapKey(Enum.KeyCode.C)
            task.wait(0.2)
            if not Settings.MasterFarm or not tempFarmCFrame then return end
            rootPart.CFrame = tempFarmCFrame
            task.wait(0.3)
            if not Settings.MasterFarm then return end

            tapKey(Enum.KeyCode.E)
            task.wait(0.3)
            if not Settings.MasterFarm then return end
            tapKey(Enum.KeyCode.E)
            task.wait(0.5)
        end
        return
    end

    -- 4) Растения
    local nearestPlant = nearestOf(cachedTargets.plant, charPos)
    if nearestPlant then
        if dumpIfFull(humanoid, rootPart) then return end
        rootPart.CFrame = CFrame.new(getValidPosition(nearestPlant) + Vector3.new(0, 3, 0))
        tapKey(Enum.KeyCode.F)
    end
end

toggleMasterFarm = function(state)
    Settings.MasterFarm = state
    if not state then
        isAttacking, currentFocusTarget = false, nil
        local _, hrp, hum = charParts()
        if hrp then
            hrp.Anchored = false
            if hum then hum:MoveTo(hrp.Position) end
        end
        tempFarmCFrame = nil
        removeTempWaypoints()
    else
        local farmingLoot = false
        for _, loot in ipairs(GAME_OBJECTS.Loot) do if SelectedTargets[loot] then farmingLoot = true break end end
        local _, hrp = charParts()
        if farmingLoot and hrp then
            tempFarmCFrame = hrp.CFrame
            CreateWaypoint("TEMP", Color3.fromRGB(200, 200, 200), tempFarmCFrame.Position + Vector3.new(0, 12, 0), false, "temp")
        end
        task.spawn(refreshCache)
    end

    if state and not farmLoopActive then
        farmLoopActive = true
        task.spawn(function()
            while Settings.MasterFarm and alive do
                local ok, err = pcall(executeFarmStep)
                if not ok then DBG("Ошибка шага фарма: " .. tostring(err)) end
                task.wait(0.15)
            end
            farmLoopActive, isAttacking, currentFocusTarget = false, false, nil
        end)
    end
    SaveConfig()
end

------------------------------------------------------------------
-- UI: хелперы (внешний вид прежний, компактный)
------------------------------------------------------------------
local screenGuiMain, miniGui, mainFrame, waypointFrame, confirmOverlay
local pendingDeleteAction = nil

local function drag(frame)
    local dragging, dragStart, startPos, dragInput
    frame.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then dragInput = input end
    end)
    local conn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    frame.Destroying:Connect(function() conn:Disconnect() end)
end

local function textLabel(parent, text, size, pos, props)
    local p = {Text = text, Size = size, Position = pos, BackgroundTransparency = 1}
    for k, v in pairs(props or {}) do p[k] = v end
    return new("TextLabel", p, parent)
end

-- Кнопка со скруглением: opts = {size, pos, color, textSize, font, textColor, align, zindex}
local function makeButton(parent, text, opts, cb)
    local b = new("TextButton", {Text = text, Size = opts.size, Position = opts.pos or UDim2.new(), BackgroundColor3 = opts.color,
        TextColor3 = opts.textColor or Color3.new(1, 1, 1), Font = opts.font or Enum.Font.GothamBold, TextSize = opts.textSize or 13,
        TextXAlignment = opts.align or Enum.TextXAlignment.Center, ZIndex = opts.zindex or 1}, parent)
    round(b, opts.radius or 6)
    if cb then b.MouseButton1Click:Connect(cb) end
    return b
end

local function createToggleSwitch(parent, label, initialEnabled, onToggle)
    local sw = new("TextButton", {Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = Color3.fromRGB(60, 60, 80), BorderSizePixel = 0, Text = "", AutoButtonColor = false}, parent)
    round(sw, 9)
    local lbl = textLabel(sw, label, UDim2.new(0, 320, 1, 0), UDim2.new(0, 15, 0, 0), {TextColor3 = Color3.fromRGB(240, 240, 255), Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    local bg = new("Frame", {Size = UDim2.new(0, 60, 0, 30), Position = UDim2.new(1, -70, 0.5, -15), BackgroundColor3 = Color3.fromRGB(80, 80, 90), BorderSizePixel = 0}, sw)
    round(bg, 15)
    local knob = new("Frame", {Size = UDim2.new(0, 24, 0, 24), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0}, bg)
    round(knob, 12)
    local enabled = initialEnabled
    local function refresh(forced)
        if forced ~= nil then enabled = forced end
        bg.BackgroundColor3 = enabled and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(80, 80, 90)
        knob.Position = enabled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    end
    refresh()
    sw.MouseButton1Click:Connect(function() enabled = not enabled refresh() onToggle(enabled) end)
    return sw, refresh, lbl
end

local function buildMiniUI()
    if miniGui then miniGui:Destroy() end
    miniGui = new("ScreenGui", {Name = "ApocMiniHub", ResetOnSpawn = false, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent())
    local frame = new("Frame", {Size = UDim2.new(0, 270, 0, 60), Position = UDim2.new(1, -290, 1, -80), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0}, miniGui)
    round(frame, 10)
    local sw, update = createToggleSwitch(frame, T("masterFarm"), Settings.MasterFarm, function(state)
        if Settings.EnableMassSort or Settings.EnableSort then
            if state then task.spawn(executeSortingLogic)
            else cancelSorting = true if updateMasterToggleVisual then updateMasterToggleVisual(false) end end
        else
            toggleMasterFarm(state)
        end
    end)
    sw.Size, sw.Position = UDim2.new(1, -10, 1, -10), UDim2.new(0, 5, 0, 5)
    updateMasterToggleVisual = update
end

local function categoryHeader(parent, text, y)
    textLabel(parent, text, UDim2.new(1, 0, 0, 25), UDim2.new(0, 10, 0, y), {TextColor3 = Color3.fromRGB(150, 150, 160), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
    return y + 30
end

local UI_REBUILD

local function setLanguage(code, tab)
    currentLang = code
    for _, wp in ipairs(ActiveWaypoints) do
        if wp.kind == "home" then wp.label.Text = T("homeName") end
    end
    SaveConfig()
    UI_REBUILD(tab)
end

------------------------------------------------------------------
-- UI: главное окно
------------------------------------------------------------------
function UI_REBUILD(startTab)
    if screenGuiMain then screenGuiMain:Destroy() end
    screenGuiMain = new("ScreenGui", {Name = "PidromaniaHubMain", ResetOnSpawn = false, DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, guiParent())

    mainFrame = new("Frame", {Size = UDim2.new(0, 780, 0, 520), Position = UDim2.new(0.5, -390, 0.5, -260), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, Active = true, Visible = false}, screenGuiMain)
    round(mainFrame, 15)
    drag(mainFrame)

    local header = new("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(30, 30, 40)}, mainFrame)
    round(header, 15)
    textLabel(header, T("hubTitle"), UDim2.new(0, 400, 1, 0), UDim2.new(0, 15, 0, 0), {Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = Color3.fromRGB(220, 220, 255), TextXAlignment = Enum.TextXAlignment.Left})

    local leftPanel = new("Frame", {Size = UDim2.new(0, 200, 1, -50), Position = UDim2.new(0, 0, 0, 50), BackgroundColor3 = Color3.fromRGB(25, 25, 30)}, mainFrame)
    round(leftPanel, 12)
    local rightPanel = new("Frame", {Size = UDim2.new(1, -210, 1, -60), Position = UDim2.new(0, 205, 0, 55), BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, mainFrame)
    round(rightPanel, 12)
    local content = new("ScrollingFrame", {Size = UDim2.new(1, -10, 1, -10), Position = UDim2.new(0, 5, 0, 5), BackgroundTransparency = 1, ScrollBarThickness = 4}, rightPanel)

    -- Подтверждение удаления
    confirmOverlay = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.5, Visible = false, Active = true, ZIndex = 50}, mainFrame)
    round(confirmOverlay, 15)
    local confirmBox = new("Frame", {Size = UDim2.new(0, 300, 0, 150), Position = UDim2.new(0.5, -150, 0.5, -75), BackgroundColor3 = Color3.fromRGB(35, 35, 45), ZIndex = 51}, confirmOverlay)
    round(confirmBox, 10)
    textLabel(confirmBox, T("confirmDel"), UDim2.new(1, 0, 0, 50), UDim2.new(0, 0, 0, 15), {TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 20, ZIndex = 51})
    makeButton(confirmBox, T("btnYes"), {size = UDim2.new(0.4, 0, 0, 40), pos = UDim2.new(0.06, 0, 0, 90), color = Color3.fromRGB(180, 50, 50), textSize = 14, zindex = 51}, function()
        if pendingDeleteAction then pendingDeleteAction() end
        confirmOverlay.Visible, pendingDeleteAction = false, nil
    end)
    makeButton(confirmBox, T("btnNo"), {size = UDim2.new(0.4, 0, 0, 40), pos = UDim2.new(0.54, 0, 0, 90), color = Color3.fromRGB(70, 70, 90), textSize = 14, zindex = 51}, function()
        confirmOverlay.Visible, pendingDeleteAction = false, nil
    end)

    -- Панель создания точки
    waypointFrame = new("Frame", {Size = UDim2.new(0, 350, 0, 220), Position = UDim2.new(0.5, -175, 0.5, -110), BackgroundColor3 = Color3.fromRGB(25, 25, 30), Active = true, Visible = false}, screenGuiMain)
    round(waypointFrame, 12)
    drag(waypointFrame)
    textLabel(waypointFrame, T("wpTitle"), UDim2.new(1, 0, 0, 40), nil, {TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 18})
    local wpInput = new("TextBox", {Size = UDim2.new(1, -40, 0, 40), Position = UDim2.new(0, 20, 0, 50), BackgroundColor3 = Color3.fromRGB(40, 40, 50), TextColor3 = Color3.new(1, 1, 1), PlaceholderText = T("wpInput"), Text = "", Font = Enum.Font.GothamSemibold, TextSize = 16}, waypointFrame)
    round(wpInput, 8)

    local colors = {Color3.fromRGB(255, 50, 50), Color3.fromRGB(50, 255, 50), Color3.fromRGB(50, 150, 255), Color3.fromRGB(255, 255, 50), Color3.fromRGB(200, 50, 255)}
    local selectedColor = colors[1]
    local colorRow = new("Frame", {Size = UDim2.new(1, -40, 0, 30), Position = UDim2.new(0, 20, 0, 100), BackgroundTransparency = 1}, waypointFrame)
    local colorBtns = {}
    for i, c in ipairs(colors) do
        local cb = new("TextButton", {Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0, (i - 1) * 40, 0, 0), BackgroundColor3 = c, Text = ""}, colorRow)
        round(cb, 100)
        cb.MouseButton1Click:Connect(function()
            selectedColor = c
            for _, b in ipairs(colorBtns) do b.BorderSizePixel = 0 end
            cb.BorderSizePixel, cb.BorderColor3 = 3, Color3.new(1, 1, 1)
        end)
        colorBtns[i] = cb
    end
    colorBtns[1].BorderSizePixel, colorBtns[1].BorderColor3 = 3, Color3.new(1, 1, 1)

    local function closeWaypointPanel() waypointFrame.Visible = false wpInput.Text = "" end
    local function saveWaypoint(name, home)
        local _, hrp = charParts()
        if not hrp then return end
        local pos = hrp.Position + Vector3.new(0, 12, 0)
        table.insert(Settings.SavedWaypoints, {name = name, home = home or nil, color = {r = selectedColor.R, g = selectedColor.G, b = selectedColor.B}, pos = {x = pos.X, y = pos.Y, z = pos.Z}})
        SaveConfig()
        CreateWaypoint(name, selectedColor, pos, true, home and "home" or "normal")
        closeWaypointPanel()
    end
    local function wpName() return wpInput.Text ~= "" and wpInput.Text or T("wpDefault") end

    makeButton(waypointFrame, T("btnNormal"), {size = UDim2.new(0, 75, 0, 40), pos = UDim2.new(0, 10, 0, 150), color = Color3.fromRGB(50, 150, 70), radius = 8}, function()
        CreateWaypoint(wpName(), selectedColor)
        closeWaypointPanel()
    end)
    makeButton(waypointFrame, T("btnPerm"), {size = UDim2.new(0, 80, 0, 40), pos = UDim2.new(0, 90, 0, 150), color = Color3.fromRGB(150, 100, 50), radius = 8}, function() saveWaypoint(wpName(), false) end)
    makeButton(waypointFrame, T("btnHome"), {size = UDim2.new(0, 80, 0, 40), pos = UDim2.new(0, 175, 0, 150), color = Color3.fromRGB(50, 100, 200), radius = 8}, function() saveWaypoint(T("homeName"), true) end)
    makeButton(waypointFrame, T("btnCancel"), {size = UDim2.new(0, 75, 0, 40), pos = UDim2.new(0, 260, 0, 150), color = Color3.fromRGB(150, 50, 50), radius = 8}, closeWaypointPanel)

    ------------------------------------------------------------------
    -- Вкладки
    ------------------------------------------------------------------
    local function clearContent()
        for _, child in ipairs(content:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end

    local function addSwitch(y, label, state, cb)
        local sw = createToggleSwitch(content, label, state, cb)
        sw.Position = UDim2.new(0, 5, 0, y)
        return y + 55
    end

    local function emptyNote(y, text)
        textLabel(content, text, UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, y), {TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham, TextSize = 14})
        return y + 30
    end

    local function showHelp()
        clearContent()
        textLabel(content, T("helpText"), UDim2.new(1, -20, 1, -20), UDim2.new(0, 10, 0, 10), {TextColor3 = Color3.fromRGB(220, 220, 255), Font = Enum.Font.Gotham, TextSize = 16, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top})
        content.CanvasSize = UDim2.new()
    end

    local function showFarm()
        clearContent()
        local function target(key) return function(s) SelectedTargets[key] = s SaveConfig() end end
        local y = 10
        y = categoryHeader(content, "--- " .. T("catZombies") .. " ---", y)
        y = addSwitch(y, T("zombies"), SelectedTargets.Zombies, target("Zombies"))
        y = categoryHeader(content, "--- " .. T("catTrees") .. " ---", y)
        y = addSwitch(y, T("trees"), SelectedTargets.Trees, target("Trees"))
        y = categoryHeader(content, "--- " .. T("catOres") .. " ---", y)
        for _, ore in ipairs(GAME_OBJECTS.Ores) do y = addSwitch(y, GetTrans(ore), SelectedTargets[ore], target(ore)) end
        y = categoryHeader(content, "--- " .. T("catPlantsChests") .. " ---", y)
        y = addSwitch(y, T("plants"), SelectedTargets.Plants, target("Plants"))
        for _, loot in ipairs(GAME_OBJECTS.Loot) do y = addSwitch(y, GetTrans(loot), SelectedTargets[loot], target(loot)) end
        content.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local showTeleports
    showTeleports = function()
        clearContent()
        local y = 10
        y = categoryHeader(content, T("catSaved"), y)

        local function row(titleText, titleWidth)
            local frame = new("Frame", {Size = UDim2.new(1, -20, 0, 45), Position = UDim2.new(0, 10, 0, y), BackgroundColor3 = Color3.fromRGB(50, 50, 60)}, content)
            round(frame, 8)
            textLabel(frame, titleText, UDim2.new(0, titleWidth, 1, 0), UDim2.new(0, 15, 0, 0), {TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
            return frame
        end

        if #ActiveWaypoints == 0 then
            y = emptyNote(y, T("noSaved"))
        else
            for i, wp in ipairs(ActiveWaypoints) do
                local frame = row((wp.isPermanent and "⭐ " or "") .. wp.label.Text, 180)
                makeButton(frame, T("btnTp"), {size = UDim2.new(0, 140, 0, 30), pos = UDim2.new(1, -240, 0.5, -15), color = Color3.fromRGB(50, 150, 70)}, function()
                    local _, hrp = charParts()
                    if hrp then hrp.CFrame = CFrame.new(wp.position - Vector3.new(0, 9, 0)) end
                end)
                makeButton(frame, T("btnDel"), {size = UDim2.new(0, 80, 0, 30), pos = UDim2.new(1, -90, 0.5, -15), color = Color3.fromRGB(150, 50, 50)}, function()
                    pendingDeleteAction = function()
                        if wp.isPermanent then
                            for idx, swp in ipairs(Settings.SavedWaypoints) do
                                if (Vector3.new(swp.pos.x, swp.pos.y, swp.pos.z) - wp.position).Magnitude < 1 then table.remove(Settings.SavedWaypoints, idx) break end
                            end
                            SaveConfig()
                        end
                        if wp.part then wp.part:Destroy() end
                        local idx = table.find(ActiveWaypoints, wp)
                        if idx then table.remove(ActiveWaypoints, idx) end
                        showTeleports()
                    end
                    confirmOverlay.Visible = true
                end)
                y = y + 50
            end
        end

        y = categoryHeader(content, T("catFriends"), y + 10)
        local anyFriend = false
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and player:IsFriendsWith(p.UserId) then
                anyFriend = true
                local frame = row(p.DisplayName .. " (@" .. p.Name .. ")", 200)
                makeButton(frame, T("btnTpFriend"), {size = UDim2.new(0, 140, 0, 30), pos = UDim2.new(1, -150, 0.5, -15), color = Color3.fromRGB(50, 150, 70)}, function()
                    local _, hrp = charParts()
                    local fr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and fr then hrp.CFrame = CFrame.new(fr.Position + Vector3.new(0, 3, 0)) end
                end)
                y = y + 50
            end
        end
        if not anyFriend then y = emptyNote(y, T("noFriends")) end
        content.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local showProtect
    showProtect = function()
        clearContent()
        local y = 10
        y = categoryHeader(content, "--- " .. T("catProtection") .. " ---", y)
        local sw = createToggleSwitch(content, T("autoSaveLife"), Settings.AutoSaveLife, function(s) Settings.AutoSaveLife = s SaveConfig() end)
        sw.Position = UDim2.new(0, 5, 0, y)
        y = categoryHeader(content, T("catBase"), y + 65)

        local basePos = getBestBaseLocation()
        textLabel(content, basePos and string.format(T("baseFound"), basePos.X, basePos.Y, basePos.Z) or T("baseWait"), UDim2.new(1, -20, 0, 30), UDim2.new(0, 15, 0, y),
            {TextColor3 = basePos and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(200, 200, 200), Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        y = y + 40
        makeButton(content, T("btnResetBase"), {size = UDim2.new(0, 280, 0, 35), pos = UDim2.new(0, 15, 0, y), color = Color3.fromRGB(150, 50, 50), textSize = 14}, function()
            Settings.BaseTracker = {}
            SaveConfig()
            showProtect()
        end)
        content.CanvasSize = UDim2.new(0, 0, 0, y + 70)
    end

    local function showSettings()
        clearContent()
        local y = categoryHeader(content, T("langSettings"), 10)
        local langFrame = new("Frame", {Size = UDim2.new(1, -20, 0, 40), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1}, content)
        for i, code in ipairs({"ru", "uk", "en"}) do
            makeButton(langFrame, T(code == "ru" and "langRu" or code == "uk" and "langUk" or "langEn"),
                {size = UDim2.new(0.32, 0, 1, 0), pos = UDim2.new((i - 1) * 0.34, 0, 0, 0), textSize = 14,
                    color = currentLang == code and Color3.fromRGB(50, 150, 70) or Color3.fromRGB(60, 60, 70)},
                function() if currentLang ~= code then setLanguage(code, "Settings") end end)
        end
        y = y + 60

        local function keybind(label, settingKey)
            textLabel(content, label, UDim2.new(0, 300, 0, 40), UDim2.new(0, 10, 0, y), {TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamSemibold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left})
            local box = new("TextBox", {Size = UDim2.new(0, 100, 0, 35), Position = UDim2.new(1, -120, 0, y + 2), BackgroundColor3 = Color3.fromRGB(50, 50, 60), TextColor3 = Color3.new(1, 1, 1),
                Text = KEY_MAP_REVERSE[Settings[settingKey]] or Settings[settingKey], Font = Enum.Font.GothamBold, TextSize = 16}, content)
            round(box, 6)
            box.FocusLost:Connect(function() Settings[settingKey] = parseKey(box.Text) SaveConfig() end)
            y = y + 50
        end
        keybind(T("keyTrees"), "TreeKey")
        keybind(T("keyOres"), "OreKey")
        keybind(T("keyWeapon"), "WeaponKey")
        content.CanvasSize = UDim2.new(0, 0, 0, y + 20)
    end

    local function showSort()
        clearContent()
        local y = 10
        y = categoryHeader(content, T("catEspModes"), y)

        local function espText() return Settings.TargetESP == "" and T("espNone") or string.format(T("espLabel"), GetTrans(Settings.TargetESP)) end
        local function sortText() return Settings.TargetSort == "" and T("sort1None") or string.format(T("sort1Label"), GetTrans(Settings.TargetSort)) end

        local swESP, _, lblESP = createToggleSwitch(content, espText(), Settings.EnableESP, function(s) Settings.EnableESP = s SaveConfig() updateESPLogic() end)
        swESP.Position = UDim2.new(0, 5, 0, y) y = y + 55
        y = addSwitch(y, T("bossEsp"), Settings.EnableBossESP, function(s) Settings.EnableBossESP = s SaveConfig() end)

        y = categoryHeader(content, T("catSortModes"), y)
        local function sortModeSwitch(label, state, setMode)
            local sw, _, lbl = createToggleSwitch(content, label, state, function(s)
                setMode(s)
                if s and Settings.MasterFarm then
                    toggleMasterFarm(false)
                    if updateMasterToggleVisual then updateMasterToggleVisual(false) end
                end
                SaveConfig()
                showSort()
            end)
            sw.Position = UDim2.new(0, 5, 0, y)
            y = y + 55
            return lbl
        end
        local lblSort = sortModeSwitch(sortText(), Settings.EnableSort, function(s) Settings.EnableSort = s if s then Settings.EnableMassSort = false end end)
        sortModeSwitch(T("massSort"), Settings.EnableMassSort, function(s) Settings.EnableMassSort = s if s then Settings.EnableSort = false end end)
        y = y + 10

        y = categoryHeader(content, T("catSelectItems"), y)
        local btnScan = makeButton(content, T("btnScan"), {size = UDim2.new(0, 300, 0, 40), pos = UDim2.new(0, 10, 0, y), color = Color3.fromRGB(50, 100, 150), radius = 8})
        local btnClear = makeButton(content, T("btnClear"), {size = UDim2.new(0, 220, 0, 40), pos = UDim2.new(0, 320, 0, y), color = Color3.fromRGB(150, 80, 50), radius = 8})
        y = y + 50

        local listContainer = new("Frame", {Size = UDim2.new(1, -20, 0, 0), Position = UDim2.new(0, 10, 0, y), BackgroundTransparency = 1}, content)
        local function populateList()
            for _, c in ipairs(listContainer:GetChildren()) do
                if c:IsA("Frame") or c:IsA("TextLabel") then c:Destroy() end
            end
            local items = scanAllItems()
            local listY = 0
            if #items == 0 then
                textLabel(listContainer, T("emptyList"), UDim2.new(1, 0, 0, 30), nil, {TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham, TextSize = 14})
                listY = 30
            else
                for _, name in ipairs(items) do
                    local r = new("Frame", {Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0, listY), BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, listContainer)
                    round(r, 6)
                    textLabel(r, GetTrans(name), UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), {TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamSemibold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                    makeButton(r, "ESP", {size = UDim2.new(0, 60, 0, 28), pos = UDim2.new(1, -260, 0.5, -14), color = Color3.fromRGB(50, 150, 70), textSize = 11, radius = 5}, function()
                        Settings.TargetESP = name
                        lblESP.Text = espText()
                        SaveConfig() updateESPLogic()
                    end)
                    makeButton(r, T("btnSort1"), {size = UDim2.new(0, 90, 0, 28), pos = UDim2.new(1, -190, 0.5, -14), color = Color3.fromRGB(150, 100, 50), textSize = 11, radius = 5}, function()
                        Settings.TargetSort = name
                        lblSort.Text = sortText()
                        SaveConfig()
                    end)
                    makeButton(r, T("btnIgnore"), {size = UDim2.new(0, 90, 0, 28), pos = UDim2.new(1, -95, 0.5, -14), color = Color3.fromRGB(150, 50, 50), textSize = 11, radius = 5}, function()
                        Settings.IgnoreList[name] = true
                        SaveConfig() populateList()
                    end)
                    listY = listY + 45
                end
            end
            listContainer.Size = UDim2.new(1, -20, 0, listY)
            content.CanvasSize = UDim2.new(0, 0, 0, y + listY + 20)
        end
        btnScan.MouseButton1Click:Connect(populateList)
        btnClear.MouseButton1Click:Connect(function() Settings.IgnoreList = {} SaveConfig() populateList() end)
        populateList()
    end

    -- Левое меню
    local tabs = {
        {"Help", "helpTab", "❓", showHelp}, {"Farm", "farmTab", "⛏️", showFarm}, {"Sort", "sortTab", "📦", showSort},
        {"Tp", "tpTab", "🌌", showTeleports}, {"Protect", "protectTab", "🛡️", showProtect}, {"Settings", "settingsTab", "⚙️", showSettings},
    }
    local menuButtons = {}
    local function select(tabId)
        for _, t in ipairs(tabs) do
            menuButtons[t[1]].BackgroundColor3 = t[1] == tabId and Color3.fromRGB(70, 70, 90) or Color3.fromRGB(50, 50, 60)
            if t[1] == tabId then t[4]() end
        end
    end
    for i, t in ipairs(tabs) do
        local btn = makeButton(leftPanel, "  " .. t[3] .. "  " .. T(t[2]),
            {size = UDim2.new(1, -20, 0, 45), pos = UDim2.new(0, 10, 0, 10 + (i - 1) * 55), color = Color3.fromRGB(50, 50, 60),
                textColor = Color3.fromRGB(220, 220, 255), font = Enum.Font.GothamSemibold, textSize = 16, align = Enum.TextXAlignment.Left, radius = 9},
            function() select(t[1]) end)
        menuButtons[t[1]] = btn
    end
    select(startTab or "Help")
    buildMiniUI()
end

UI_REBUILD()

------------------------------------------------------------------
-- Горячие клавиши
------------------------------------------------------------------
local ePressedTime = 0
local TIME_WINDOW = 0.5

track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local kc = input.KeyCode

    -- T / Q / G останавливают фарм (игрок взял управление)
    if Settings.MasterFarm and not isAutoDumping and (kc == Enum.KeyCode.T or kc == Enum.KeyCode.Q or kc == Enum.KeyCode.G) then
        if updateMasterToggleVisual then updateMasterToggleVisual(false) end
        toggleMasterFarm(false)
    end

    if kc == Enum.KeyCode.E then
        ePressedTime = tick()
        if mainFrame and mainFrame.Visible then mainFrame.Visible = false end
        if waypointFrame and waypointFrame.Visible then waypointFrame.Visible = false end
    elseif kc == Enum.KeyCode.G then
        if not isAutoDumping and (tick() - ePressedTime) <= TIME_WINDOW and mainFrame and not mainFrame.Visible then
            waypointFrame.Visible = false
            mainFrame.Visible = true
        end
    elseif kc == Enum.KeyCode.C then
        if not isAutoDumping and (tick() - ePressedTime) <= TIME_WINDOW and waypointFrame and not waypointFrame.Visible then
            mainFrame.Visible = false
            waypointFrame.Visible = true
        end
    elseif kc == Enum.KeyCode.T then
        local _, hrp = charParts()
        if targetWaypoint and hrp and not isAutoDumping then hrp.CFrame = CFrame.new(targetWaypoint.position - Vector3.new(0, 9, 0)) end
    elseif kc == Enum.KeyCode.H then
        if isAutoDumping then return end
        if Settings.EnableMassSort or Settings.EnableSort then
            if isSortingBusy then
                cancelSorting = true
                if updateMasterToggleVisual then updateMasterToggleVisual(false) end
            else
                task.spawn(executeSortingLogic)
            end
        else
            local newState = not Settings.MasterFarm
            if updateMasterToggleVisual then updateMasterToggleVisual(newState) end
            toggleMasterFarm(newState)
        end
    end
end))

------------------------------------------------------------------
-- Остановка этого экземпляра при повторном запуске
------------------------------------------------------------------
getgenv().ApocHubStop = function()
    alive = false
    Settings.MasterFarm, cancelSorting = false, true
    for _, c in ipairs(connections) do c:Disconnect() end
    for _, c in ipairs(espItemConns) do c:Disconnect() end
    for _, g in ipairs({screenGuiMain, miniGui, cursorGui, waypointFolder}) do
        if g then pcall(function() g:Destroy() end) end
    end
    UserInputService.MouseIconEnabled = true
end

updateESPLogic()
if Settings.MasterFarm then toggleMasterFarm(true) end
