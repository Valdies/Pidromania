-- Pidromania Hub: Sword Blox Online (оптимизированная версия, официальные названия + полный перевод)
task.wait(5)

-- Если хаб уже запущен в этой сессии - гасим старый экземпляр
if getgenv().PidromaniaHubStop then pcall(getgenv().PidromaniaHubStop) end

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RepStor = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local KEY = Enum.KeyCode
local CLICK_Y_OFFSET = 58 -- смещение для кликов по GUI (как было в оригинале)

------------------------------------------------------------------
-- Утилиты
------------------------------------------------------------------
local connections = {}
local function track(conn) connections[#connections + 1] = conn return conn end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local function round(obj, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function tapKey(key, hold)
    VIM:SendKeyEvent(true, key, false, game)
    task.wait(hold or 0.1)
    VIM:SendKeyEvent(false, key, false, game)
end

local function clickMouse()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
end

local function ApplyMobileScale(gui, baseWidth)
    local uiScale = new("UIScale", nil, gui)
    local cam = Workspace.CurrentCamera
    local function update()
        local w = cam.ViewportSize.X
        uiScale.Scale = w < baseWidth and w / (baseWidth + 50) or 1
    end
    update()
    local c = cam:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    gui.Destroying:Connect(function() c:Disconnect() end)
end

local function MakeDraggableTouch(topbar, target)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then dragInput = input end
    end)
    local conn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    topbar.Destroying:Connect(function() conn:Disconnect() end)
end

local friendsCache = {}
local function isFriend(target)
    if target == player then return true end
    local cached = friendsCache[target.UserId]
    if cached ~= nil then return cached end
    local ok, res = pcall(function() return player:IsFriendsWith(target.UserId) end)
    if ok then friendsCache[target.UserId] = res return res end
    return false
end

------------------------------------------------------------------
-- Состояние и конфиг
------------------------------------------------------------------
local S = {
    language = "ru", safe1 = false, respawn = false, playerList = false,
    autoWalk = false, fishFarm = false, materialFarm = false, ores = {},
    farmMode = nil, autoF = false, autoF_cd = 8, autoHeal = false, blockAll = false, questEsp = false,
    clickCps = 2.8, flagName = "",
}
local CONFIG_TYPES = {
    language = "string", safe1 = "boolean", respawn = "boolean", playerList = "boolean",
    autoWalk = "boolean", fishFarm = "boolean", materialFarm = "boolean", ores = "table",
    farmMode = "string", autoF = "boolean", autoF_cd = "number", autoHeal = "boolean", blockAll = "boolean", questEsp = "boolean",
    clickCps = "number", flagName = "string",
}

local isEvading, isFrozen = false, false
local screenGuiMain, playerListGui, screenGui, indicator

local FOLDER_NAME = "PidromaniaHub"
local FILE_NAME = FOLDER_NAME .. "/SBOR_Config.json"

------------------------------------------------------------------
-- Локализация: L(ru, uk, en) - название на трёх языках, N(x) - выбрать нужное
-- Если название одинаково на всех языках (имя босса) - просто строка
------------------------------------------------------------------
local function L(ru, uk, en) return {ru = ru, uk = uk, en = en} end
local function N(v)
    if type(v) ~= "table" then return v end
    return v[S.language] or v.en or v.ru
end

-- ============ ПЕРЕВОДЫ ИНТЕРФЕЙСА ============
-- hubTitle, byAuthor, lang_* одинаковые для всех языков, поэтому лежат только в ru (T() берёт их оттуда)
local translations = {
    ru = {
        hubTitle = "Pidromania Hub: Sword Blox Online", byAuthor = "by @Pidromania",
        lang_ru = "Русский", lang_uk = "Українська", lang_en = "English",
        floorBtn = "Этаж %d — %s",
        floor = "Этаж", teleports = "Телепорт к мобам", bossRooms = "Телепорт к локациям",
        bossFarm = "Фарм боссов", materialFarm = "Фарм ресурсов", paths = "Пути",
        tools = "Инструменты", settings = "Настройки", selectFloor = "Выберите этаж:",
        unknownFloor = "Ошибка: неизвестный этаж", noBosses = "На этом этаже нет боссов и мобов для телепорта",
        bossesOfFloor = "Боссы и мобы этажа %d (%s):", bossFarms = "Фарм боссов и мобов:",
        noFarms = "На этом этаже нет доступных фармов", matAndFish = "Ресурсы, рыбалка и кузня",
        autoOreSelect = "Выберите ресурсы для сбора:", noOresFound = "Ресурсы не найдены на этом этаже или вы слишком далеко от них.",
        startFarmBtn = "🟢 Запустить авто-сбор", autoFish = "Авто-рыбалка (мини-игра)",
        freezeToggle = "Заморозка персонажа на месте", respawnToggle = "Возрождение на месте смерти",
        playerListToggle = "Список игроков на сервере", safe1Toggle = "Экстренная эвакуация (смерть, блок, смена сервера)",
        blockAllToggle = "Массовая блокировка игроков", autoMobWalk = "Автофарм ближайших мобов",
        autoF = "Автоскилл", autoClicker = "Автокликер (кликов в секунду)", autoHeal = "Авто-зелье лечения (HP < 70%)",
        questEspToggle = "ESP квестодателя", customFlag = "Свой флаг (пусто = выкл.)", flagHint = "название флага",
        languageLabel = "Язык интерфейса:",
        pathLoading = "⏳ Загрузка...", pathError = "Ошибка!", pathSuccess = "Запущен!",
        noPathsForFloor = "Для этого этажа нет путей.", roomsAndLocs = "Локации этажа %d (%s):",
        noExtraLocs = "⚠️ Для этого этажа нет дополнительных локаций.",
        youAreOnFloor = "Вы здесь: %s (этаж %d)", pathsTitle = "Пути",
        forgeTitle = "🛠️ Кузня (авто-крафт)", forgeSelect = "Выбрать предмет", forgeFarmItem = "▶ ФАРМ ПРЕДМЕТА",
        forgeFarmIngots = "💎 ФАРМ SK", forgeStop = "⏹ ОСТАНОВИТЬ", forgeStopSC = "⏹ ОСТАНОВИТЬ SK",
        forgeMiniTitle = "🛠️ Управление кузней", forgeWaiting = "Ожидание...", forgeFinishing = "⏳ ЗАВЕРШАЮ...",
        forgeChangedTarget = "Новая цель: ", forgeWaitUI = "Жду появления предмета в меню...", forgeOpenMenu = "Открываю меню (X)...",
        forgeStarting = "Запуск...", forgeMinigame = "Мини-игра...", forgeCloseSuccess = "Закрываю окно успеха...",
        forgeResetUI = "Сброс интерфейса...", forgeRetry = "Пробую снова...", forgeTakeOther = "Беру другой предмет: ",
        forgeReady = "Готов к крафту", forgeStartHint = "⚠️ Запуск фарма — в мини-панели на экране",
        forgeEmergencyStop = "Экстренная остановка (открыт хаб)!", forgeErrNoItem = "Сначала выбери предмет из списка!",
        farmStopped = "Фарм остановлен", forgeErrNoIngots = "Подходящие предметы для SK-фарма закончились!",
        forgeErrNoMats = "Ресурсы для предмета закончились!", forgeErrNoMatsFor = "Ресурсы для %s закончились!",
        forgeItem = "Предмет: ", forgeNotSelected = "Не выбран", forgeStatusLbl = "Статус: ",
        forgeCycles = "Циклы: ", forgeErrors = "Ошибки: ",
        lockDefault = "ВЫПОЛНЯЕТСЯ ОПЕРАЦИЯ...", lockBlock = "МАССОВАЯ БЛОКИРОВКА... ПОДОЖДИТЕ",
        lockEvade = "ЭКСТРЕННАЯ ЭВАКУАЦИЯ: БЛОКИРОВКА И СМЕНА СЕРВЕРА...", lockBtn = "ЭКСТРЕННО ОТКЛЮЧИТЬ ЗАЩИТУ",
    },
    uk = {
        floorBtn = "Поверх %d — %s",
        floor = "Поверх", teleports = "Телепорт до мобів", bossRooms = "Телепорт до локацій",
        bossFarm = "Фарм босів", materialFarm = "Фарм ресурсів", paths = "Шляхи",
        tools = "Інструменти", settings = "Налаштування", selectFloor = "Оберіть поверх:",
        unknownFloor = "Помилка: невідомий поверх", noBosses = "На цьому поверсі немає босів і мобів для телепорту",
        bossesOfFloor = "Боси та моби поверху %d (%s):", bossFarms = "Фарм босів і мобів:",
        noFarms = "На цьому поверсі немає доступних фармів", matAndFish = "Ресурси, рибалка та кузня",
        autoOreSelect = "Оберіть ресурси для збору:", noOresFound = "Ресурси не знайдено на цьому поверсі або ви занадто далеко від них.",
        startFarmBtn = "🟢 Запустити авто-збір", autoFish = "Авто-рибалка (міні-гра)",
        freezeToggle = "Заморожування персонажа на місці", respawnToggle = "Відродження на місці смерті",
        playerListToggle = "Список гравців на сервері", safe1Toggle = "Екстрена евакуація (смерть, блок, зміна сервера)",
        blockAllToggle = "Масове блокування гравців", autoMobWalk = "Автофарм найближчих мобів",
        autoF = "Автоскіл", autoClicker = "Автоклікер (кліків за секунду)", autoHeal = "Авто-зілля лікування (HP < 70%)",
        questEspToggle = "ESP квестодавця", customFlag = "Свій прапор (порожньо = вимк.)", flagHint = "назва прапора",
        languageLabel = "Мова інтерфейсу:",
        pathLoading = "⏳ Завантаження...", pathError = "Помилка!", pathSuccess = "Запущено!",
        noPathsForFloor = "Для цього поверху немає шляхів.", roomsAndLocs = "Локації поверху %d (%s):",
        noExtraLocs = "⚠️ Для цього поверху немає додаткових локацій.",
        youAreOnFloor = "Ви тут: %s (поверх %d)", pathsTitle = "Шляхи",
        forgeTitle = "🛠️ Кузня (авто-крафт)", forgeSelect = "Обрати предмет", forgeFarmItem = "▶ ФАРМ ПРЕДМЕТА",
        forgeFarmIngots = "💎 ФАРМ SK", forgeStop = "⏹ ЗУПИНИТИ", forgeStopSC = "⏹ ЗУПИНИТИ SK",
        forgeMiniTitle = "🛠️ Керування кузнею", forgeWaiting = "Очікування...", forgeFinishing = "⏳ ЗАВЕРШУЮ...",
        forgeChangedTarget = "Нова ціль: ", forgeWaitUI = "Чекаю появи предмета в меню...", forgeOpenMenu = "Відкриваю меню (X)...",
        forgeStarting = "Запуск...", forgeMinigame = "Міні-гра...", forgeCloseSuccess = "Закриваю вікно успіху...",
        forgeResetUI = "Скидання інтерфейсу...", forgeRetry = "Пробую знову...", forgeTakeOther = "Беру інший предмет: ",
        forgeReady = "Готовий до крафту", forgeStartHint = "⚠️ Запуск фарму — у міні-панелі на екрані",
        forgeEmergencyStop = "Екстрена зупинка (відкрито хаб)!", forgeErrNoItem = "Спочатку обери предмет зі списку!",
        farmStopped = "Фарм зупинено", forgeErrNoIngots = "Відповідні предмети для SK-фарму закінчилися!",
        forgeErrNoMats = "Ресурси для предмета закінчилися!", forgeErrNoMatsFor = "Ресурси для %s закінчилися!",
        forgeItem = "Предмет: ", forgeNotSelected = "Не обрано", forgeStatusLbl = "Статус: ",
        forgeCycles = "Цикли: ", forgeErrors = "Помилки: ",
        lockDefault = "ВИКОНУЄТЬСЯ ОПЕРАЦІЯ...", lockBlock = "МАСОВЕ БЛОКУВАННЯ... ЗАЧЕКАЙТЕ",
        lockEvade = "ЕКСТРЕНА ЕВАКУАЦІЯ: БЛОКУВАННЯ ТА ЗМІНА СЕРВЕРА...", lockBtn = "ЕКСТРЕНО ВИМКНУТИ ЗАХИСТ",
    },
    en = {
        floorBtn = "Floor %d — %s",
        floor = "Floor", teleports = "Teleport to mobs", bossRooms = "Teleport to locations",
        bossFarm = "Boss farm", materialFarm = "Resource farm", paths = "Paths",
        tools = "Tools", settings = "Settings", selectFloor = "Select a floor:",
        unknownFloor = "Error: unknown floor", noBosses = "No bosses or mobs to teleport to on this floor",
        bossesOfFloor = "Bosses & mobs of floor %d (%s):", bossFarms = "Boss & mob farms:",
        noFarms = "No farms available on this floor", matAndFish = "Resources, fishing & forge",
        autoOreSelect = "Select resources to collect:", noOresFound = "No resources found on this floor, or you are too far from them.",
        startFarmBtn = "🟢 Start auto-collect", autoFish = "Auto-fishing (mini-game)",
        freezeToggle = "Freeze character in place", respawnToggle = "Respawn at death location",
        playerListToggle = "Server player list", safe1Toggle = "Emergency evacuation (death, block, server hop)",
        blockAllToggle = "Mass player block", autoMobWalk = "Auto-farm nearest mobs",
        autoF = "Auto-skill", autoClicker = "Auto-clicker (clicks per second)", autoHeal = "Auto healing potion (HP < 70%)",
        questEspToggle = "Quest giver ESP", customFlag = "Custom flag (empty = off)", flagHint = "flag name",
        languageLabel = "Interface language:",
        pathLoading = "⏳ Loading...", pathError = "Error!", pathSuccess = "Started!",
        noPathsForFloor = "No paths for this floor.", roomsAndLocs = "Locations of floor %d (%s):",
        noExtraLocs = "⚠️ No extra locations for this floor.",
        youAreOnFloor = "You are here: %s (floor %d)", pathsTitle = "Paths",
        forgeTitle = "🛠️ Forge (auto-craft)", forgeSelect = "Select item", forgeFarmItem = "▶ FARM ITEM",
        forgeFarmIngots = "💎 SK FARM", forgeStop = "⏹ STOP", forgeStopSC = "⏹ STOP SK",
        forgeMiniTitle = "🛠️ Forge control", forgeWaiting = "Waiting...", forgeFinishing = "⏳ FINISHING...",
        forgeChangedTarget = "New target: ", forgeWaitUI = "Waiting for the item in the menu...", forgeOpenMenu = "Opening menu (X)...",
        forgeStarting = "Starting...", forgeMinigame = "Mini-game...", forgeCloseSuccess = "Closing success window...",
        forgeResetUI = "Resetting interface...", forgeRetry = "Retrying...", forgeTakeOther = "Taking another item: ",
        forgeReady = "Ready to craft", forgeStartHint = "⚠️ The farm start button is in the mini-panel on screen",
        forgeEmergencyStop = "Emergency stop (hub opened)!", forgeErrNoItem = "Select an item from the list first!",
        farmStopped = "Farm stopped", forgeErrNoIngots = "No suitable items for SK farming left!",
        forgeErrNoMats = "Resources for this item ran out!", forgeErrNoMatsFor = "Resources for %s ran out!",
        forgeItem = "Item: ", forgeNotSelected = "Not selected", forgeStatusLbl = "Status: ",
        forgeCycles = "Cycles: ", forgeErrors = "Errors: ",
        lockDefault = "OPERATION IN PROGRESS...", lockBlock = "MASS BLOCKING... PLEASE WAIT",
        lockEvade = "EMERGENCY EVACUATION: BLOCKING AND SERVER HOP...", lockBtn = "EMERGENCY PROTECTION SHUTDOWN",
    },
}

local function T(key)
    local l = translations[S.language]
    return (l and l[key]) or translations.ru[key] or ("???" .. key .. "???")
end

local function SaveConfig()
    if not (writefile and isfolder) then return end
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    local data = {}
    for k in pairs(CONFIG_TYPES) do data[k] = S[k] end
    pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(data)) end)
end

local function LoadConfig()
    if not (readfile and isfile and isfile(FILE_NAME)) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(FILE_NAME))
        for k, t in pairs(CONFIG_TYPES) do
            if type(data[k]) == t then S[k] = data[k] end
        end
        if not translations[S.language] then S.language = "ru" end
    end)
end

-- Свой флаг: по умолчанию выключен, пользователь задаёт имя сам (Инструменты)
local function applyFlag(name)
    local g = getgenv()
    if S.flagName ~= "" then g[S.flagName] = nil end
    S.flagName = name
    if name ~= "" then g[name] = true end
    SaveConfig()
end

-- Пауза после клика, чтобы получилось S.clickCps кликов в секунду (клик сам занимает 0.05с)
local function clickDelay()
    local iv = 1 / math.clamp(tonumber(S.clickCps) or 2.8, 0.1, 50)
    return math.max(iv * (0.95 + math.random() * 0.1) - 0.05, 0.02)
end

------------------------------------------------------------------
-- ДАННЫЕ
------------------------------------------------------------------
local FLOORS = {
    {1,  "Town Of Beginnings", 4733293382},
    {2,  "Swordsman Fields", 4734865416},
    {3,  "Swamp Lands", 4735703075},
    {4,  "Perfidious Desert", 4735718710},
    {5,  "Icy Caverns", 4736649014},
    {6,  "Hellfire Wasteland", 4736759720},
    {7,  "Luminara Grove", 4736984932},
    {8,  "Graves", 4737916764},
    {9,  "Tropical Sea", 4740039076},
    {10, "Sakura Serenity", 4747247314},
    {11, "Fallen Kingdom", 5135551944},
    {12, "The Flower Garden", 5212666689},
    {13, "Ghost Forest", 5136611550},
    {14, "Floating Islands", 4733293091},
    {15, "College Campus", 11987483716},
    {16, "Rulid Village", 11987539001},
    {17, "Candy Lands", 12632324801},
    {18, "Early Crownvein", 94066307314492},
    {18, "Early Crownvein: Arena", 117852524597461},
    {19, "Glacialis Ward", 130463264320898}
}

-- Часто повторяющиеся названия локаций
local LOC = {
    town      = L("Город", "Місто", "Town"),
    mine      = L("Шахта", "Шахта", "Mine"),
    pit       = L("Яма", "Яма", "Pit"),
    shop      = L("Магазин", "Магазин", "Shop"),
    tower     = L("Вход в башню", "Вхід у вежу", "Tower entrance"),
    bossRoom  = L("Комната босса", "Кімната боса", "Boss room"),
    miniRoom  = L("Комната минибосса", "Кімната мінібоса", "Miniboss room"),
    fish      = L("Рыбалка", "Рибалка", "Fishing spot"),
    maze      = L("Лабиринт", "Лабіринт", "Maze"),
    lighthouse = L("Маяк", "Маяк", "Lighthouse"),
    church    = L("Церковь", "Церква", "Church"),
    mobFarm   = L("Мобфарм", "Мобфарм", "Mob farm"),
}

-- Телепорт к мобам/боссам: {название, x, y, z}
local BOSSES = {
    [4734865416] = {{"Shadesworn the Corrupted", 414, -1174, -461},{"Illfang The Kobold Lord", -1003, 1928, -727},{L("Зайцы", "Зайці", "Rabbits"), 635.78, 665.00, -477.40}},
    [4735703075] = {{L("Мобфарм: в яме", "Мобфарм: у ямі", "Mob farm: in the pit"), -352.25, -15.14, 1049.83},{"Lord Slug", 988, 2500, 591}},
    [4735718710] = {{LOC.mobFarm, 3712.00, 1596.65, 948.40},{"Scorpion Rajah", 2731.06, 1624.14, 1297.88},{"Stallord", 332.03, 2249.15, 12821.01}},
    [4736649014] = {{L("Мобфарм: в пещере", "Мобфарм: у печері", "Mob farm: in the cave"), -2295.05, 386.89, -1851.63},{"X'rphan the White Wyrm", -1585, 404, -1702}},
    [4736759720] = {{"Uakmaroth, the Demon Lord", -1622, 1931, -426}},
    [4736984932] = {{"Father Shroom", -1497.77, -1340.78, 3222.65},{"Storm Atronach", -5849, -368, 9330}},
    [4737916764] = {{L("Болото скелетов", "Болото скелетів", "Skeleton Swamp"), 326, 74, -1396},{"Bonnz the Skeleton Lord", 2998, -557, -1878}},
    [4740039076] = {{"Guardian of the Gate", -2665, 879, 9127},{"Karth'uk The Crystal Kraken", -2612, 32, 6763}},
    [4747247314] = {{"Hotoke The Enlightened", -3985, -9927, -7179}},
    [5135551944] = {{"Buffed Knight", -1619, 4, -5725},{"Grimlock the Fallen King", -9471, -471, 1962}},
    [5212666689] = {{"Laurellis Convict", 14968, 770, -705},{"Slime Lord Pengonis", -1826, 1111, -9793}},
    [5136611550] = {{"Tormented Spectrum", -94, 1404, 3187},{"The Tormented Soul", -79, 2267, -114}},
    [4733293091] = {{"Leader Grimm", 8128, 2685, 939},{"Super Luo", 2355, 1716, 2364},{"Elder Celatid", 1859, 1714, -2208},{"Young Celestia", -1407, -1462, 1203}},
    [11987483716] = {{L("Raios, Sortiliena и Golgorosso", "Raios, Sortiliena та Golgorosso", "Raios, Sortiliena and Golgorosso"), 458, 30, -1211}},
    [11987539001] = {{L("Гоблины", "Гобліни", "Goblins"), -584.36, 176.52, 3508.82},{L("Пещера гоблинов", "Печера гоблінів", "Goblin cave"), -1305.50, 179.92, 1896.98},{"Two-Headed Giant", 2742.92, 225.58, 7207.78},{"Leader Goblin", -1559.62, 176.98, 2563.71}},
    [12632324801] = {{"Captain Sweet the Forever Child", 2940, -815, -1949}},
    [94066307314492] = {{L("Мобфарм (безопасный)", "Мобфарм (безпечний)", "Mob farm (safe)"), -272.06, 7.42, 74.08},{"Thug Boss", -1493, 6, 8},{"Loan Shark Boss", -553.70, 1.49, -2088.94},{"The Custodian", -989.97, -1472.43, 6025.40},{"Eidolon the Gilded Omen", -352.27, 1043.52, 1549.13},{"The Arbitrator", -498.26, -1503.60, 5515.60}},
    [130463264320898] = {
        {"Oslund the Hollow Flame", -3501.16, 153.08, 3534.65},
        {"Sunwarden Caelis", -3224.66, 156.07, -1323.25},
        {"Frostveil Echo", 2150.95, -1181.13, 4616.98},
        {"Wendigo", 3546.91, -889.56, 7155.80},
        {"Ice Spirit", 3796.98, -942.65, 6422.02},
        {L("Пингвины", "Пінгвіни", "Penguins"), -2397.24, 156.93, 2185.15},
        {L("Големы", "Големи", "Golems"), 773.03, 112.48, 1246.18}
    }
}

-- Названия фармов для интерфейса (ключ = внутренний id фарма, его не менять!)
-- Если id нет в таблице, показывается он сам
local FARM_NAMES = {
    MobFarm = LOC.mobFarm,
    ["Thug Boss (Server Hop)"] = L("Thug Boss (смена сервера)", "Thug Boss (зміна сервера)", "Thug Boss (server hop)"),
    ["MobFarm Exit Pillar"] = L("Мобфарм: столб на выходе", "Мобфарм: стовп на виході", "Mob farm: pillar at the exit"),
    ["MobFarm Loan Shark Henchman"] = L("Мобфарм: Loan Shark Henchman", "Мобфарм: Loan Shark Henchman", "Mob farm: Loan Shark Henchman"),
    ["MobFarm VIP Scout"] = L("Мобфарм: VIP Scout", "Мобфарм: VIP Scout", "Mob farm: VIP Scout"),
    Goblins = L("Гоблины", "Гобліни", "Goblins"),
    Frontman = "The Frontman",
    ["Sunwarden Caelis"] = L("Владимир красное солнышко (Sunwarden Caelis)", "Володимир Красне Сонечко (Sunwarden Caelis)", "Sunwarden Caelis (Vladimir)"),
}

local BOSS_FARMS = {
    [4734865416] = {{"Illfang The Kobold Lord", Vector3.new(-972.62, 1933.95, -727.67)},{"Shadesworn the Corrupted", Vector3.new(421.36, -1174.06, -467.49)}},
    [4735703075] = {{"MobFarm", Vector3.new(-367.31, 0.75, 1007.91)},{"Lord Slug", Vector3.new(747.68, 2485.53, 52)}},
    [4735718710] = {{"Stallord", Vector3.new(571.00, 1188.82, 12513.01)}},
    [4736649014] = {{"MobFarm", Vector3.new(498.27, 701.39, 608.80)},{"X'rphan the White Wyrm", Vector3.new(-1844.69, 404.36, -1547.97)}},
    [4736759720] = {{"Uakmaroth, the Demon Lord", Vector3.new(-1532.07, 1914.88, -384.36)}},
    [4736984932] = {{"Storm Atronach", Vector3.new(-5849, -368, 9330)}},
    [4737916764] = {{"Bonnz the Skeleton Lord", Vector3.new(2737.84, -548.03, -1699.97)},{"MobFarm", Vector3.new(271.30, 34, -1441.69)}},
    [4740039076] = {{"MobFarm", Vector3.new(-2666.91, 893.12, 9499.35)},{"Guardian of the Gate", Vector3.new(-2666.33, 899.55, 9119.14)},{"Karth'uk The Crystal Kraken", Vector3.new(-2549.95, 53.51, 6823.25)}},
    [4747247314] = {{"Hotoke The Enlightened", Vector3.new(-3973.63, -9910.32, -7164.26)}},
    [5135551944] = {{"Buffed Knight", Vector3.new(-1605.13, 38.42, -5727.90)},{"Grimlock the Fallen King", Vector3.new(-9471.73, -443.34, 1915.18)}},
    [5212666689] = {{"Laurellis Convict", Vector3.new(14969.86, 770.86, -708.19)},{"Slime Lord Pengonis", Vector3.new(-1803.66, 1108.39, -9831.81)},{"MobFarm", Vector3.new(1368.50, 1619.78, -4720.19)}},
    [5136611550] = {{"Tormented Spectrum", Vector3.new(-89.75, 1419.62, 3102.39)},{"The Tormented Soul", Vector3.new(-43.48, 2290.75, -39.05)}},
    [4733293091] = {{"Leader Grimm", Vector3.new(8091.00, 2675.98, 678.44)},{"Super Luo", Vector3.new(2451.71, 1746.34, 2114.21)},{"Elder Celatid", Vector3.new(1833.24, 1762.81, -2241.65)},{"Young Celestia", Vector3.new(-1555.34, -1322.91, 1577.24)}},
    [11987483716] = {{"Raios", Vector3.new(4846.71, -3051.62, -1168.02)},{"Sortiliena", Vector3.new(4846.71, -2025.62, -1168.02)},{"Golgorosso", Vector3.new(4846.71, -1005.58, -1168.02)}},
    [11987539001] = {{"Goblins", Vector3.new(-584.36, 176.52, 3508.82)},{"Two-Headed Giant", Vector3.new(2835.94, 251.57, 6077.73)}},
    [12632324801] = {{"Captain Sweet the Forever Child", Vector3.new(2993.59, -833.45, -1959.57)}},
    [94066307314492] = {
        {"Thug Boss (Server Hop)", Vector3.new(-1490.44, -9, -183.62)},
        {"MobFarm Exit Pillar", Vector3.new(-502.70, 30.68, -95.50)},
        {"MobFarm Loan Shark Henchman", Vector3.new(-459.56, 25.80, -2173.31)},
        {"MobFarm VIP Scout", Vector3.new(-452.86, 31.93, 1394.72)},
        {"Rookie Guard", Vector3.new(-653.05, -1314.71, 5011.60)},
        {"Thug Boss", Vector3.new(-1477.77, 34.66, -224.00)},
        {"Loan Shark Boss", Vector3.new(-543.19, 26.54, -2124.94)},
        {"Eidolon the Gilded Omen", Vector3.new(-159.32, 1045.93, 1695.05)},
        {"The Custodian", Vector3.new(-975.23, -1477.30, 5912.75)},
        {"The Arbitrator", Vector3.new(-578.84, -1477.90, 5316.49)}
    },
    [117852524597461] = {{"Frontman", Vector3.new(-38.32, 80.40, -285.61)}},
    [130463264320898] = {
        {"Oslund the Hollow Flame", Vector3.new(-3501.16, 153.08, 3534.65)},
        {"Sunwarden Caelis", Vector3.new(-3183.14, 155.03, -1271.63)},
        {"Frostveil Echo", Vector3.new(2275.98, -1175.30, 4579.98)},
        {"Ice Spirit", Vector3.new(3825.06, -942.65, 6400.30)},
        {"Boneclaw Feral", Vector3.new(2765.72, -473.67, 7026.55)},
        {"Strong Corrupted Traveler", Vector3.new(2935.85, -473.72, 7003.91)}
    }
}

-- Дополнительные локации: {название, x, y, z}
local EXTRA_LOCATIONS = {
    [4734865416] = {{LOC.town, 415.57, 107.68, -276.72},{LOC.mine, -436.26, 128.35, 154.04},{LOC.bossRoom, -540.97, 1917.21, -727.32},{LOC.miniRoom, 178.45, -1174.08, -487.87}},
    [4735703075] = {{LOC.pit, -341.45, 99.01, 997.13},{LOC.mine, -6.24, 27.97, 945.08},{LOC.shop, -969.56, 69.00, -895.28},{LOC.tower, 282.07, -927.82, 838.67},{LOC.bossRoom, 545.77, 2485.72, 591.24}},
    [4735718710] = {{LOC.mine, 1339.27, 1826.08, -623.95},{LOC.tower, 4622.89, 1637.00, 1213.31},{LOC.bossRoom, 1900.30, 2175.11, 12787.67}},
    [4736649014] = {{LOC.mine, 768.75, 204.93, 687.25},{LOC.tower, -2367.82, 407.96, -1542.97},{LOC.bossRoom, -2219.23, 400.14, -1873.53}},
    [4736759720] = {{LOC.mine, -961.40, 193.43, -1390.09},{LOC.tower, -1343.48, 1132.88, 138.37},{LOC.bossRoom, -1279.13, 1913.99, -426.48},{LOC.fish, -1565.62, 167.85, -426.65}},
    [4737916764] = {{LOC.tower, 2687.15, -654.41, 470.80},{LOC.bossRoom, 2783.20, -554.00, -1670.30},{LOC.fish, -357.06, 125.73, -955.36}},
    [4736984932] = {{LOC.tower, -196.82, -1572.34, 2326.80},{LOC.bossRoom, -6470.27, -371.00, 9485.21}},
    [4740039076] = {{LOC.shop, 1198.64, 951.67, -174.30},{L("Вход в первую локацию", "Вхід у першу локацію", "First area entrance"), -2691.01, 1184.50, 13916.61},{LOC.tower, 1236.04, 129.95, 11256.65},{LOC.bossRoom, -2620.99, 32.80, 7070.26}},
    [5136611550] = {{LOC.fish, 291.24, 2267.31, 1833.63}},
    [4747247314] = {{LOC.mine, -114.55, 20.66, 966.82},{LOC.tower, -4000.10, -9989.45, -5859.08},{LOC.bossRoom, -3987.15, -9930.00, -6714.68},{LOC.fish, 1951.53, 38.91, 663.37}},
    [5135551944] = {{L("Крыша минибосса", "Дах мінібоса", "Miniboss rooftop"), -1674.17, 152.01, -5899.82},{LOC.tower, -10204.24, -479.34, -491.57},{LOC.bossRoom, -9471.52, -474.34, 1500.44}},
    [5212666689] = {{LOC.shop, -1618.68, 1359.33, 8325.41},{LOC.tower, 2065.14, 260.02, -8207.31},{LOC.bossRoom, -1193.62, 1092.96, -9792.50}},
    [4733293091] = {{L("Яйцо босса", "Яйце боса", "Boss egg"), -1557.81, -1322.58, 1580.20},{L("Кузница", "Кузня", "Forge"), 9593.29, 3651.69, 1862.28},{LOC.fish, 453.82, 1547.54, 2332.68}},
    [11987539001] = {{L("Деревня", "Село", "Village"), -991.45, 239.96, -956.28},{"Gigas", -1434.15, 170.36, -2159.10},{LOC.fish, -1211.50, 203.43, 399.37}},
    [12632324801] = {{LOC.fish, 3756.86, 152.85, -1766.02}},
    [94066307314492] = {{"NPC Koshak", -715.74, 14.95, 49.26},{"Thug", -1445.02, 253.41, -133.76},{LOC.fish, 270.23, -54.66, 179.51}},
    [130463264320898] = {
        {L("Ice Sanctuary (комната финального босса)", "Ice Sanctuary (кімната фінального боса)", "Ice Sanctuary (final boss room)"), 3940.89, -964.40, 6302.97},
        {"Ice Domain", 1028.20, -1218.36, 4146.35},
        {LOC.lighthouse, -1629.58, 1016.57, 1514.95},
        {LOC.church, -5474.52, 192.08, -1537.69},
        {"Cabin", -2998.23, -565.16, 9125.64},
        {L("Красный ключ (для квеста)", "Червоний ключ (для квесту)", "Red key (for quest)"), 2559.68, 133.57, 592.29},
        {L("Вход в пещеру с пингвинами", "Вхід у печеру з пінгвінами", "Penguin cave entrance"), -2975.91, 353.49, 2394.02},
        {L("Статуя", "Статуя", "Statue"), -2904.03, 419.96, 1640.88},
        {"Sunstone", -4331.49, 144.00, 349.18}
    }
}

-- Пути: [номер этажа] = {{название кнопки, имя файла в репозитории}, ...}
local PATH_BASE = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/"
local PATH_SUFFIX = "%20%D1%8D%D1%82%D0%B0%D0%B6/"
local PATHS = {
    [2]  = {{"Illfang The Kobold Lord", "Boss2"}, {"Shadesworn the Corrupted", "Miniboss"}},
    [3]  = {{LOC.tower, "Башня"}, {LOC.shop, "Магазин"}},
    [4]  = {{LOC.maze, "Labirint"}, {LOC.mine, "Shaxta"}},
    [5]  = {{LOC.maze, "Лабиринт"}},
    [8]  = {{"Bonnz the Skeleton Lord", "Boss"}},
    [14] = {{L("Синий кристалл", "Синій кристал", "Blue crystal"), "BlueCristal"}, {"Leader Grimm", "Boss1LeaderGrimm"}, {L("Красный кристалл", "Червоний кристал", "Red crystal"), "RedCristal"}},
    [16] = {{"Leader Goblin", "LeaderGoblin"}, {"Two-Headed Giant", "Two-HeadedGiant"}},
    [19] = {
        {"Frostveil Echo", "FrostveilEcho"},
        {"Ice Spirit", "IceSpirit"},
        {FARM_NAMES["Sunwarden Caelis"], "Vladimir"},
        {"Cabin", "WendigoHouse"},
        {L("Лабиринт Wendigo", "Лабіринт Wendigo", "Wendigo maze"), "WendigoMaze"},
        {"Ice Domain", "IceCastle"},
        {LOC.lighthouse, "Lighthouse"},
        {LOC.church, "Church"},
    },
}

-- StandDistance: на каком расстоянии от центра моба останавливаться (не лезть на него), StuckTime/BlackTime: если цель не получает урон дольше StuckTime - пропускаем её на BlackTime
local AUTO_WALK = {MaxDistance = 1500, AttackDistance = 13, StandDistance = 7, StuckTime = 12, BlackTime = 15}

local function currentFloorData()
    for _, f in ipairs(FLOORS) do
        if f[3] == game.PlaceId then return f end
    end
end

------------------------------------------------------------------
-- Универсальный цикл с флагом S[flag]
-- step() возвращает паузу в секундах или false (остановить цикл)
------------------------------------------------------------------
local function makeLoop(flag, step, onEnd)
    local running = false
    local function start()
        S[flag] = true
        if running then return end
        running = true
        task.spawn(function()
            while S[flag] do
                local ok, w = pcall(step)
                if ok and w == false then break end
                task.wait((ok and tonumber(w)) or 1)
            end
            running = false
            if onEnd then onEnd() end
        end)
    end
    local function stop() S[flag] = false end
    return start, stop
end

------------------------------------------------------------------
-- Блокировка экрана, блокировка игроков, эвакуация
------------------------------------------------------------------
local lockGui, lockMsg, lockBtn
local function setUILocked(locked, msg)
    if not lockGui then
        lockGui = new("ScreenGui", {Name = "PidromaniaLockScreen", ResetOnSpawn = false, DisplayOrder = 99999})
        local bg = new("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundColor3 = Color3.fromRGB(15, 15, 20), BackgroundTransparency = 0.4, Active = true}, lockGui)
        lockMsg = new("TextLabel", {Size = UDim2.new(1, 0, 0, 100), Position = UDim2.new(0, 0, 0.4, -50), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 80, 80), Font = Enum.Font.GothamBold, TextSize = 26, TextWrapped = true}, bg)
        lockBtn = new("TextButton", {Name = "EmergencyBtn", Size = UDim2.new(0.8, 0, 0, 50), Position = UDim2.new(0.1, 0, 0.6, 0), BackgroundColor3 = Color3.fromRGB(200, 40, 40), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 18}, bg)
        round(lockBtn, 8)
        lockBtn.MouseButton1Click:Connect(function()
            isEvading, S.blockAll, S.safe1 = false, false, false
            setUILocked(false)
        end)
    end
    if locked then
        lockMsg.Text = msg or T("lockDefault")
        lockBtn.Text = T("lockBtn")
        lockGui.Parent = playerGui
    else
        lockGui.Parent = nil
    end
    if screenGuiMain then screenGuiMain.Enabled = not locked end
    if playerListGui then playerListGui.Enabled = not locked end
end

local function promptBlock(target, stillActive)
    pcall(function() StarterGui:SetCore("PromptBlockPlayer", target) end)
    task.wait(0.7)
    if not stillActive() then return false end
    local vp = Workspace.CurrentCamera.ViewportSize
    local x, y = vp.X / 2 + vp.X * 0.05, vp.Y / 2 + vp.Y * 0.04
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    return true
end

local function loopTeleport(placeId)
    task.spawn(function()
        while true do
            pcall(function() TeleportService:Teleport(placeId, player) end)
            task.wait(5)
        end
    end)
end
local function ServerHop() loopTeleport(game.PlaceId) end
-- Thug Boss: 17 <-> 18 этаж (сброс таймера респавна босса)
local HOP_TARGET = {[12632324801] = 94066307314492, [94066307314492] = 12632324801}
local function thugHop() loopTeleport(HOP_TARGET[game.PlaceId] or game.PlaceId) end

local blockedCache = {}
local startBlockAll, stopBlockAll = makeLoop("blockAll", function()
    local list = {}
    for _, t in ipairs(Players:GetPlayers()) do
        if t ~= player and not blockedCache[t.UserId] and not isFriend(t) then list[#list + 1] = t end
    end
    if #list > 0 then
        setUILocked(true, T("lockBlock"))
        for _, t in ipairs(list) do
            if not S.blockAll then break end
            if not promptBlock(t, function() return S.blockAll end) then break end
            blockedCache[t.UserId] = true
            task.wait(2.2 + math.random())
        end
        if S.blockAll then setUILocked(false) end
    end
    return 2
end, function() if not isEvading then setUILocked(false) end end)

local function triggerEvasion()
    if isEvading then return end
    isEvading = true
    setUILocked(true, T("lockEvade"))
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") then char:BreakJoints() end
    task.spawn(function()
        for _, t in ipairs(Players:GetPlayers()) do
            if t ~= player and not isFriend(t) then
                if not isEvading then break end
                if not promptBlock(t, function() return isEvading end) then break end
                task.wait(1.5)
            end
        end
        if isEvading then ServerHop() end
    end)
end

local startSafe1, stopSafe1 = makeLoop("safe1", function()
    for _, t in ipairs(Players:GetPlayers()) do
        if t ~= player and not isFriend(t) then triggerEvasion() return false end
    end
    return 1
end)

------------------------------------------------------------------
-- Телепорт, платформа, заморозка, индикатор, мобы
------------------------------------------------------------------
local function teleport(pos)
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = CFrame.new(pos) end
end

local function spawnPlatform(pos)
    return new("Part", {Name = "PidromaniaPlatform", Size = Vector3.new(10, 1, 10), Position = pos,
        Color = Color3.fromRGB(0, 170, 255), Material = Enum.Material.SmoothPlastic, Anchored = true, CanCollide = true}, Workspace)
end

local function makeFreezer()
    local conn
    return function(on)
        if conn then conn:Disconnect() conn = nil end
        if not on then return true end
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local cf = hrp.CFrame
        conn = RunService.RenderStepped:Connect(function()
            if hrp.Parent then hrp.CFrame = cf end
        end)
        return true
    end
end
local setFarmFreeze, setManualFreeze = makeFreezer(), makeFreezer()

local function toggleFreeze()
    isFrozen = not isFrozen
    if not setManualFreeze(isFrozen) then isFrozen = false end
end

local function initGUI()
    if screenGui then return end
    screenGui = new("ScreenGui", {ResetOnSpawn = false}, playerGui)
    indicator = new("Frame", {Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 49, 0, 249), BackgroundColor3 = Color3.new(1, 0, 0), BorderSizePixel = 0}, screenGui)
end

local function updateIndicator(isNear)
    if indicator then indicator.BackgroundColor3 = isNear and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) end
end

local mobsCache, lastMobScan = nil, 0
local function findMobsFolder()
    if mobsCache and mobsCache.Parent then return mobsCache end
    mobsCache = Workspace:FindFirstChild("Mobs")
    if not mobsCache and os.clock() - lastMobScan > 5 then
        lastMobScan = os.clock()
        for _, c in ipairs(Workspace:GetDescendants()) do
            if c.Name == "Mobs" and c:IsA("Folder") then mobsCache = c break end
        end
    end
    return mobsCache
end

local function toNum(v)
    if not v then return nil end
    if v:IsA("IntValue") or v:IsA("NumberValue") then return v.Value end
    if v:IsA("StringValue") then return tonumber(v.Value) end
end

local function getPlayerLevel(plr)
    local stats = plr:FindFirstChild("PlayerStats")
    local n = stats and toNum(stats:FindFirstChild("Level"))
    if n then return n end
    local ls = plr:FindFirstChild("leaderstats")
    if ls then
        n = toNum(ls:FindFirstChild("Level") or ls:FindFirstChild("lvl") or ls:FindFirstChild("level"))
        if n then return n end
    end
    return tonumber(plr:GetAttribute("Level")) or "?"
end

------------------------------------------------------------------
-- Список игроков
------------------------------------------------------------------
local playerListConns = {}
local function destroyPlayerListGui()
    for _, c in ipairs(playerListConns) do c:Disconnect() end
    playerListConns = {}
    if playerListGui then playerListGui:Destroy() playerListGui = nil end
end

local function createPlayerListGui()
    if playerListGui then return end
    local gui = new("ScreenGui", {Name = "PidromaniaPlayerList", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, playerGui)
    playerListGui = gui
    local frame = new("Frame", {Size = UDim2.new(0, 320, 0, 280), Position = UDim2.new(1, -330, 0, 20), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0}, gui)
    round(frame, 8)
    new("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = T("playerListToggle"), TextColor3 = Color3.fromRGB(180, 180, 220), Font = Enum.Font.GothamBold, TextSize = 16}, frame)
    local scroll = new("ScrollingFrame", {Size = UDim2.new(1, -12, 1, -42), Position = UDim2.new(0, 6, 0, 32), BackgroundTransparency = 1, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4}, frame)
    new("UIListLayout", {Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center}, scroll)

    local function updateList()
        for _, c in ipairs(scroll:GetChildren()) do
            if c:IsA("TextLabel") then c:Destroy() end
        end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                new("TextLabel", {Size = UDim2.new(1, -8, 0, 24), BackgroundTransparency = 1, Text = string.format("%s — [%s]", plr.Name, tostring(getPlayerLevel(plr))),
                    TextColor3 = Color3.fromRGB(240, 240, 255), Font = Enum.Font.GothamBold, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left}, scroll)
            end
        end
    end
    updateList()
    playerListConns[1] = Players.PlayerAdded:Connect(function() task.defer(updateList) end)
    playerListConns[2] = Players.PlayerRemoving:Connect(function() task.defer(updateList) end)
    task.spawn(function()
        while gui.Parent do
            task.wait(5)
            if gui.Parent then updateList() end
        end
    end)
end

------------------------------------------------------------------
-- Воскрешение на месте смерти
------------------------------------------------------------------
local resConns, savedDeathPosition = {}, nil
local function cleanupResurrection()
    for _, c in ipairs(resConns) do c:Disconnect() end
    resConns, savedDeathPosition = {}, nil
end

local function setupResurrection()
    cleanupResurrection()
    S.respawn = true
    local function onCharacter(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if not humanoid or not root then return end
        if savedDeathPosition then
            local pos = savedDeathPosition
            savedDeathPosition = nil
            task.spawn(function()
                task.wait(1.5)
                local r = character:FindFirstChild("HumanoidRootPart")
                if r then
                    for _ = 1, 4 do
                        if character.Parent and humanoid.Health > 0 then r.CFrame = pos + Vector3.new(0, 5, 0) end
                        task.wait(0.5)
                    end
                end
            end)
        end
        resConns[#resConns + 1] = humanoid.Died:Connect(function() savedDeathPosition = root.CFrame end)
    end
    resConns[#resConns + 1] = player.CharacterAdded:Connect(onCharacter)
    if player.Character then onCharacter(player.Character) end
end

------------------------------------------------------------------
-- Авто-циклы
------------------------------------------------------------------
local startAutoF, stopAutoF = makeLoop("autoF", function()
    if isEvading then return 1 end
    if S.autoWalk or S.farmMode then tapKey(KEY.F) end
    return (tonumber(S.autoF_cd) or 8) + math.random(0, 50) / 100
end)

local startAutoHeal, stopAutoHeal = makeLoop("autoHeal", function()
    if isEvading then return 1 end
    local hum = player.Character and player.Character:FindFirstChild("Humanoid")
    if hum and hum.Health > 0 and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth < 0.7 then
        -- Q убирает оружие, R + R используют зелье лечения, Q достаёт оружие обратно
        tapKey(KEY.Q) task.wait(0.25)
        tapKey(KEY.R) task.wait(0.25)
        tapKey(KEY.R) task.wait(0.25)
        tapKey(KEY.Q) task.wait(35)
    end
    return 0.5
end)

local awTarget, awSince, awLastHp = nil, 0, nil
local awBlack = {}

-- Проверяет цель; возвращает part, горизонтальную дистанцию, вектор до цели, Humanoid моба
local function awCheck(mob, hrp, now)
    if not mob or not mob.Parent then return nil end
    if awBlack[mob] and awBlack[mob] > now then return nil end
    local part = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
    local mh = mob:FindFirstChild("Humanoid")
    if not part or (mh and mh.Health <= 0) then return nil end
    local d = part.Position - hrp.Position
    if d.Y > 25 or d.Y < -15 then return nil end
    local h = Vector2.new(d.X, d.Z).Magnitude
    if h > AUTO_WALK.MaxDistance then return nil end
    return part, h, d, mh
end

local startAutoWalk, stopAutoWalkFlag = makeLoop("autoWalk", function()
    if isEvading then return 1 end
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not (hum and hum.Health > 0 and hrp) then return 0.1 end
    local folder = findMobsFolder()
    if not folder then return 0.1 end
    local now = os.clock()

    -- держим текущую цель, пока она жива, и не прыгаем между мобами
    local part, dist, d, mh = awCheck(awTarget, hrp, now)
    if part then
        local hp = mh and mh.Health
        if hp ~= awLastHp then
            awLastHp, awSince = hp, now
        elseif now - awSince > AUTO_WALK.StuckTime then
            awBlack[awTarget] = now + AUTO_WALK.BlackTime -- не получается ударить - берём другого
            part = nil
        end
    end
    if not part then
        awTarget = nil
        local best = AUTO_WALK.MaxDistance
        for _, mob in ipairs(folder:GetChildren()) do
            local p2, h2 = awCheck(mob, hrp, now)
            if p2 and h2 < best then best, awTarget = h2, mob end
        end
        if awTarget then
            part, dist, d, mh = awCheck(awTarget, hrp, now)
            awSince, awLastHp = now, mh and mh.Health
        end
    end
    if not part then return 0.1 end

    local p = part.Position
    -- слишком близко и выше моба: мы на нём стоим, слезаем
    if dist < 4 and d.Y < -2.5 then
        local away = Vector3.new(-d.X, 0, -d.Z)
        away = away.Magnitude > 0.1 and away.Unit or -hrp.CFrame.LookVector
        hum:MoveTo(hrp.Position + away * 8)
        return 0.15
    end

    -- для крупных мобов останавливаемся дальше от центра
    local stand = AUTO_WALK.StandDistance
    if awTarget:IsA("Model") then
        local ok, size = pcall(function() return awTarget:GetExtentsSize() end)
        if ok then stand = math.clamp(math.max(stand, math.max(size.X, size.Z) / 2 + 3), stand, AUTO_WALK.AttackDistance - 1) end
    end

    if dist > AUTO_WALK.AttackDistance then
        hum:MoveTo(p)
        return 0.1
    end
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(p.X, hrp.Position.Y, p.Z))
    clickMouse()
    hum:MoveTo(dist > stand and p or hrp.Position)
    return clickDelay()
end)

local function stopAutoWalk()
    stopAutoWalkFlag()
    awTarget = nil
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp then hum:MoveTo(hrp.Position) end
end

track(player.CharacterAdded:Connect(function(character)
    if S.autoWalk and not isEvading then
        task.delay(2, function()
            if S.autoWalk and not isEvading and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                tapKey(KEY.Q)
            end
        end)
    end
end))

-- ESP квестодателей (Workspace.QuestGivers)
local questEspObjs = {}
local function clearQuestEsp()
    for _, e in pairs(questEspObjs) do e.gui:Destroy() end
    questEspObjs = {}
end

local function questGiverPart(m)
    if m:IsA("BasePart") then return m end
    return m.PrimaryPart or m:FindFirstChild("HumanoidRootPart") or m:FindFirstChild("Head") or m:FindFirstChildWhichIsA("BasePart", true)
end

local startQuestEsp, stopQuestEsp = makeLoop("questEsp", function()
    local folder = Workspace:FindFirstChild("QuestGivers")
    if not folder then clearQuestEsp() return 3 end
    for m, e in pairs(questEspObjs) do
        if not m.Parent or not e.part.Parent then e.gui:Destroy() questEspObjs[m] = nil end
    end
    for _, m in ipairs(folder:GetChildren()) do
        if not questEspObjs[m] then
            local part = questGiverPart(m)
            if part then
                local hum = m:FindFirstChildOfClass("Humanoid")
                local name = (hum and hum.DisplayName ~= "" and hum.DisplayName) or m:GetAttribute("DisplayName") or m.Name
                local gui = new("BillboardGui", {Size = UDim2.new(0, 180, 0, 40), StudsOffset = Vector3.new(0, 3, 0), AlwaysOnTop = true, ResetOnSpawn = false, Adornee = part}, playerGui)
                local label = new("TextLabel", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(255, 220, 80), TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextSize = 16}, gui)
                name = tostring(name)
                name = string.match(name, "^(Q%d+)_") or name -- Q3_1792921666.63 -> Q3
                questEspObjs[m] = {gui = gui, label = label, part = part, name = name}
            end
        end
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    for _, e in pairs(questEspObjs) do
        local dist = hrp and math.floor((e.part.Position - hrp.Position).Magnitude) or 0
        e.label.Text = string.format("%s\n[%d]", e.name, dist)
    end
    return 0.5
end, clearQuestEsp)

-- Сбор ресурсов
local startMatLoop, stopMaterialFarm = makeLoop("materialFarm", function()
    if not isEvading then
        pcall(function()
            local mats = Workspace:FindFirstChild("Materials")
            local claim = RepStor:FindFirstChild("ClaimMaterial")
            if mats and claim then
                for _, m in ipairs(mats:GetChildren()) do
                    if m:IsA("Model") and S.ores[m.Name] then
                        local owner, id = m:FindFirstChild("Owner"), m:FindFirstChild("Id")
                        if owner and id and owner.Value == "" then
                            claim:InvokeServer(id.Value)
                            task.wait(0.5)
                        end
                    end
                end
            end
        end)
    end
    return 7
end)

local function startMaterialFarm()
    for _, v in pairs(S.ores) do
        if v then startMatLoop() return end
    end
end

------------------------------------------------------------------
-- РЫБАЛКА (мини-игра): хук выравнивается по рыбе, после окончания жмём X
------------------------------------------------------------------
local F = {active = false, stopping = false, ingots = false, minigame = false, clicking = false, clicks = 0, cycles = 0, errors = 0}

local function getFishingObjects()
    local g = playerGui:FindFirstChild("FishingGame")
    local frame = g and g:FindFirstChild("FishingScreenFrame")
    local tank = frame and frame:FindFirstChild("Tank")
    local layer = tank and tank:FindFirstChild("HookLayer")
    return layer and layer:FindFirstChild("Hook"), tank and tank:FindFirstChild("Fish")
end

local function alignHookWithFish()
    local hook, fish = getFishingObjects()
    if not (hook and fish) then return end
    local fp, hp = fish.Position, hook.Position
    if math.abs(fp.X.Scale) > 0.001 or math.abs(fp.X.Offset) > 0 then
        hook.Position = UDim2.new(fp.X.Scale, fp.X.Offset, hp.Y.Scale, hp.Y.Offset)
    else
        hook.Position = UDim2.new(hp.X.Scale, hp.X.Offset, fp.Y.Scale, fp.Y.Offset)
    end
end

local fishConn, isFishing, fishRunning = nil, false, false
local function stopFishConn()
    if fishConn then fishConn:Disconnect() fishConn = nil end
    isFishing = false
end

local function stopFishFarm()
    S.fishFarm = false
    stopFishConn()
end

local function startFishFarm()
    S.fishFarm = true
    if fishRunning then return end
    fishRunning = true
    task.spawn(function()
        while S.fishFarm do
            local hook, fish = getFishingObjects()
            local active = hook ~= nil and fish ~= nil
            if active and not isFishing then
                isFishing = true
                fishConn = RunService.RenderStepped:Connect(function() pcall(alignHookWithFish) end)
            elseif not active and isFishing then
                stopFishConn()
                task.wait(0.2)
                -- X не жмём во время эвакуации и работы кузни (в кузне X открывает меню)
                if S.fishFarm and not isEvading and not F.active then pcall(tapKey, KEY.X, 0.05) end
            end
            task.wait(0.2)
        end
        stopFishConn()
        fishRunning = false
    end)
end

------------------------------------------------------------------
-- ФАРМ БОССОВ / МОБОВ (логика сохранена как в оригинале)
-- bossName - внутренний id фарма (см. BOSS_FARMS / FARM_NAMES)
------------------------------------------------------------------
local function startGenericFarm(bossName, farmPos)
    S.farmMode = bossName
    initGUI()
    updateIndicator(false)

    local isThugHop = (bossName == "Thug Boss (Server Hop)")
    local isFrontman = (bossName == "Frontman")
    local isCurrentlyVladimir = (bossName == "Sunwarden Caelis")
    local isCurrentlyFrostveil = (bossName == "Frostveil Echo")
    local isCurrentlyFloor8Mob = (bossName == "MobFarm" and game.PlaceId == 4737916764)
    local isFloor10 = (game.PlaceId == 4747247314)
    local isFloor11 = (game.PlaceId == 5135551944)
    local isFloor12Slime = (game.PlaceId == 5212666689 and bossName == "Slime Lord Pengonis")
    local isGoblins = (game.PlaceId == 11987539001 and bossName == "Goblins")
    local isFloor12MobFarm = (game.PlaceId == 5212666689 and bossName == "MobFarm")
    local isFloor13Soul = (game.PlaceId == 5136611550 and bossName == "The Tormented Soul")
    local isFloor13Spectrum = (game.PlaceId == 5136611550 and bossName == "Tormented Spectrum")

    local platform, activePlatformPos = nil, nil

    if isThugHop then
        task.spawn(function()
            pcall(stopAutoWalk) -- не бегать, пока готовим платформу
            task.wait(1)
            if S.farmMode ~= bossName or isEvading then return end

            local platformPos = Vector3.new(-1490.44, -9, -183.62)
            platform = spawnPlatform(platformPos)
            task.wait(1)
            if S.farmMode ~= bossName or isEvading then return end

            teleport(platformPos + Vector3.new(0, 3, 0))
            task.wait(1.15)
            if S.farmMode ~= bossName or isEvading then return end

            setFarmFreeze(true)
            task.wait(1.12)
            tapKey(KEY.Q)

            -- Автофарм мобов включается строго после телепорта на платформу
            pcall(startAutoWalk)

            local hasSeenBoss = false
            local nextFPress = 0
            local clickLoopActive = true
            task.spawn(function()
                while clickLoopActive and S.farmMode == bossName do
                    if isEvading then task.wait(1) continue end
                    clickMouse()
                    task.wait(clickDelay())
                end
            end)

            while S.farmMode == bossName do
                if isEvading then task.wait(1) continue end
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then break end

                if os.time() >= nextFPress then
                    tapKey(KEY.F)
                    nextFPress = os.time() + math.random(33, 34)
                end

                local mobsFolder = findMobsFolder()
                local bossFoundThisTick = false
                if mobsFolder then
                    for _, mob in ipairs(mobsFolder:GetChildren()) do
                        if mob:IsA("Model") then
                            local torso = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                            local mobHum = mob:FindFirstChild("Humanoid")
                            if torso and torso:IsA("BasePart") and (not mobHum or mobHum.Health > 0) then
                                local delta = torso.Position - platformPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = torso.Position.Y - platformPos.Y
                                local inCylinder = (horizontalDist <= 10 and verticalDelta >= 0 and verticalDelta <= 50)
                                if inCylinder or mob:GetAttribute("IsThugTarget") then
                                    mob:SetAttribute("IsThugTarget", true)
                                    bossFoundThisTick = true
                                    hasSeenBoss = true
                                    torso.Anchored = true
                                    torso.CanCollide = false
                                    torso.CFrame = hrp.CFrame * CFrame.new(1, -2, -6.75)
                                end
                            end
                        end
                    end
                end
                updateIndicator(bossFoundThisTick)

                if not bossFoundThisTick and hasSeenBoss then
                    clickLoopActive = false
                    S.farmMode = nil
                    pcall(stopAutoWalk) -- автофарм мобов выключаем сразу после убийства босса
                    task.wait(20) -- спокойно стоим 20 секунд на платформе
                    setFarmFreeze(false)
                    if platform then platform:Destroy() end
                    thugHop()
                    return
                end
                task.wait(0.1)
            end
            clickLoopActive = false
            pcall(stopAutoWalk)
        end)
        return
    end

    if isFrontman then
        local platformPos = Vector3.new(-38.32, 80.40, -285.61)
        platform = spawnPlatform(platformPos) teleport(platformPos + Vector3.new(0, 5, 0))
    elseif isFloor10 then
        activePlatformPos = Vector3.new(-3987.27, -9905.00, -7024.24)
        local playerPos = activePlatformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(activePlatformPos) teleport(playerPos)
    elseif isFloor11 then
        if bossName == "Grimlock the Fallen King" then activePlatformPos = Vector3.new(-9477.86, -455.52, 1878.47)
        elseif bossName == "Buffed Knight" then activePlatformPos = Vector3.new(-1676.96, 23.03, -5764.05)
        else activePlatformPos = farmPos end
        local playerPos = activePlatformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(activePlatformPos) teleport(playerPos)
    elseif isCurrentlyVladimir then
        local platformPos = Vector3.new(-3183.14, 150.03, -1271.63)
        local playerPos = Vector3.new(-3183.14, 152.03, -1271.63)
        farmPos = playerPos platform = spawnPlatform(platformPos) teleport(playerPos)
    elseif isCurrentlyFrostveil then
        local platformPos = Vector3.new(2203.02, -1192, 4586.85)
        local playerPos = Vector3.new(2203.02, -1190.33, 4586.85)
        farmPos = playerPos platform = spawnPlatform(platformPos) teleport(playerPos)
    elseif isCurrentlyFloor8Mob then
        local platformPos = Vector3.new(271.30, 34, -1441.69)
        local playerPos = Vector3.new(271.30, 36, -1441.69)
        farmPos = playerPos platform = spawnPlatform(platformPos) teleport(playerPos)
    elseif isGoblins then
        pcall(function()
            local rock = Workspace:FindFirstChild("PlayerBarriers")
            if rock then rock = rock:FindFirstChild("BossBarrier-Action")
                if rock then rock = rock:FindFirstChild("Rock3-Action")
                    if rock then rock:Destroy() end
                end
            end
        end)
        local playerPos = Vector3.new(-584.36, 176.52, 3508.82)
        local platformPos = playerPos - Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(platformPos) teleport(playerPos)
    elseif isFloor12MobFarm then
        activePlatformPos = Vector3.new(1368.50, 1619.78, -4720.19)
        local playerPos = activePlatformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(activePlatformPos) teleport(playerPos)
    elseif isFloor13Soul then
        activePlatformPos = Vector3.new(-43.48, 2290.75, -39.05)
        local playerPos = activePlatformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(activePlatformPos) teleport(playerPos)
    elseif isFloor13Spectrum then
        activePlatformPos = Vector3.new(-89.75, 1419.62, 3102.39)
        local playerPos = activePlatformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos platform = spawnPlatform(activePlatformPos) teleport(playerPos)
    else
        teleport(farmPos) task.wait(0.3)
    end

    -- Клики по мобам рядом, пока идёт фарм (если включён автофарм ближайших мобов - он кликает сам)
    local targetNear = false
    task.spawn(function()
        while S.farmMode == bossName do
            if targetNear and not isEvading and not S.autoWalk then
                clickMouse()
                task.wait(clickDelay())
            else
                task.wait(0.1)
            end
        end
    end)

    task.spawn(function()
        if isFloor10 or isFloor11 then task.wait(2) else task.wait(1) end
        if not isEvading then setFarmFreeze(true) end

        if isGoblins and not isEvading then
            task.wait(0.5)
            tapKey(KEY.Q)
        end

        local placeId = game.PlaceId
        local isFloor14 = (placeId == 4733293091)
        local isFloor18 = (placeId == 94066307314492)
        local isFloor13 = (placeId == 5136611550)
        local isFloor17 = (placeId == 12632324801)
        local isArena18_2 = (placeId == 117852524597461)
        local isFloor19 = (placeId == 130463264320898)
        local isCurrentlyFrontman = (bossName == "Frontman")
        local customPosCondition = isFloor10 or isFloor11 or isFloor12Slime or isFloor12MobFarm or isFloor13Soul or isFloor13Spectrum

        while S.farmMode == bossName do
            if isEvading then task.wait(1) continue end
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then break end

            local mobsFolder = findMobsFolder()
            local foundAny = false

            if mobsFolder then
                for _, mob in ipairs(mobsFolder:GetChildren()) do
                    if mob:IsA("Model") then
                        local torso = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("UpperTorso") or mob:FindFirstChild("Torso")
                        local mobHum = mob:FindFirstChild("Humanoid")
                        if torso and torso:IsA("BasePart") and (not mobHum or mobHum.Health > 0) then
                            if isGoblins then
                                if (torso.Position - farmPos).Magnitude <= 50 then foundAny = true end
                                continue
                            end
                            local shouldProcess = false
                            if (isCurrentlyFrontman and isArena18_2) or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or isFloor10 or isFloor11 then
                                local delta = torso.Position - ((isFloor10 or isFloor11) and activePlatformPos or farmPos)
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = delta.Y
                                if isFloor10 or isFloor11 then
                                    if horizontalDist <= 15 and verticalDelta >= -50 and verticalDelta <= 0 then shouldProcess = true end
                                elseif isCurrentlyFrostveil then
                                    if horizontalDist <= 10 and verticalDelta >= -50 and verticalDelta <= 0 then shouldProcess = true end
                                else
                                    if horizontalDist <= 15 then
                                        if isCurrentlyVladimir or isCurrentlyFloor8Mob then
                                            if verticalDelta >= 0 and verticalDelta <= 50 then shouldProcess = true end
                                        elseif isCurrentlyFrontman then
                                            if verticalDelta >= -50 and verticalDelta <= 0 then shouldProcess = true end
                                        end
                                    end
                                end
                            elseif isFloor12MobFarm or isFloor13Soul or isFloor13Spectrum then
                                local delta = torso.Position - activePlatformPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = torso.Position.Y - activePlatformPos.Y
                                if horizontalDist <= 15 and verticalDelta >= -50 and verticalDelta <= 0 then shouldProcess = true end
                            elseif isFloor14 or isFloor18 or isFloor17 or isFloor19 or isArena18_2 then
                                local delta = torso.Position - farmPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = delta.Y
                                if horizontalDist <= 15 and verticalDelta >= -50 and verticalDelta <= 0 then shouldProcess = true end
                            else
                                local searchRadius = isFloor13 and 50 or 30
                                if (torso.Position - farmPos).Magnitude <= searchRadius then shouldProcess = true end
                            end

                            if shouldProcess then
                                foundAny = true
                                torso.Anchored = true
                                torso.CanCollide = false
                                if customPosCondition then
                                    local dist = 8
                                    if isFloor13Soul then dist = 13 elseif isFloor12MobFarm then dist = 11 end
                                    local targetPos = hrp.Position + hrp.CFrame.LookVector * dist
                                    local vY = (isFloor12Slime or isFloor13Spectrum) and -hrp.CFrame.LookVector or hrp.CFrame.LookVector
                                    local vZ = Vector3.new(0, -1, 0)
                                    local vX = vY:Cross(vZ)
                                    if vX.Magnitude < 0.001 then vX = hrp.CFrame.RightVector else vX = vX.Unit end
                                    torso.CFrame = CFrame.fromMatrix(targetPos, vX, vY, vZ)
                                elseif bossName == "Ice Spirit" then
                                    -- 6.75 studs вперёд, спиной к игроку
                                    torso.CFrame = hrp.CFrame * CFrame.new(0, 0, -6.75)
                                else
                                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 5
                                    torso.CFrame = CFrame.fromMatrix(targetPos, hrp.CFrame.RightVector, hrp.CFrame.UpVector, hrp.CFrame.LookVector)
                                end
                            end
                        end
                    end
                end
            end
            updateIndicator(foundAny)
            targetNear = foundAny
            if isFloor14 or isFloor18 or isCurrentlyFrontman or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or customPosCondition or isGoblins then
                task.wait(3)
            else
                task.wait(0.1)
            end
        end
        setFarmFreeze(false)
        if platform then platform:Destroy() end
        updateIndicator(false)
    end)
end

local function stopAllFarms()
    S.farmMode = nil
    setFarmFreeze(false)
    updateIndicator(false)
end

------------------------------------------------------------------
-- КУЗНЯ (Auto-craft)
------------------------------------------------------------------
local refForgeStatus, refForgeSelectBtn
local miniForgeGui, miniForgeStatus, miniForgeFarmBtn, miniForgeIngotBtn
local minimizeHub -- объявлена ниже (UI)

local function setForgeBtn(btn, stopText, startText, startColor, isMine)
    if not btn then return end
    if F.stopping then
        btn.Text, btn.BackgroundColor3 = T("forgeFinishing"), Color3.fromRGB(200, 120, 0)
    elseif F.active and isMine then
        btn.Text, btn.BackgroundColor3 = stopText, Color3.fromRGB(180, 60, 60)
    else
        btn.Text, btn.BackgroundColor3 = startText, startColor
    end
end

local function updateForgeUI(statusText, color)
    color = color or Color3.fromRGB(100, 200, 255)
    local text = T("forgeItem") .. (F.product or T("forgeNotSelected")) .. "\n" .. T("forgeStatusLbl") .. (statusText or T("forgeWaiting"))
        .. string.format(" | %s%d | %s%d", T("forgeCycles"), F.cycles, T("forgeErrors"), F.errors)
    if refForgeStatus then refForgeStatus.Text, refForgeStatus.TextColor3 = text, color end
    if miniForgeStatus then miniForgeStatus.Text, miniForgeStatus.TextColor3 = text, color end
    setForgeBtn(miniForgeFarmBtn, T("forgeStop"), T("forgeFarmItem"), Color3.fromRGB(60, 120, 60), not F.ingots)
    setForgeBtn(miniForgeIngotBtn, T("forgeStopSC"), T("forgeFarmIngots"), Color3.fromRGB(0, 100, 200), F.ingots)
end

local function clickGUI(obj)
    if not obj or not obj:IsA("GuiObject") or not obj.Visible then return false end
    local x = obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2
    local y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2 + CLICK_Y_OFFSET
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        pcall(function() firesignal(obj.MouseButton1Click) end)
        pcall(function() firesignal(obj.Activated) end)
    end
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    return true
end

local function pressX() tapKey(KEY.X, 0.05) end

local function getForgeElement(kind, name)
    local gg = playerGui:FindFirstChild("GameGui")
    local cr = gg and gg:FindFirstChild("Crafting")
    if not cr then return nil end
    if kind == "Product" then
        local p = cr:FindFirstChild("Products")
        return p and name and p:FindFirstChild(name)
    elseif kind == "CraftBtn" then return cr:FindFirstChild("Craft")
    elseif kind == "CloseBtn" then return cr:FindFirstChild("Close") end
end

local function clickSuccessExit()
    local cg = playerGui:FindFirstChild("CraftingGame")
    local main = cg and cg:FindFirstChild("Main")
    local success = main and main:FindFirstChild("Success")
    if success and success.Visible then
        local exitBtn = success:FindFirstChild("Exit")
        if exitBtn then clickGUI(exitBtn) return true end
    end
    return false
end

local SC_KEYWORDS = {"ingot", "fish", "candy bar", "refined obsidium", "refined gem"}
local function getAvailableProducts(isSCMode)
    local gg = playerGui:FindFirstChild("GameGui")
    local cr = gg and gg:FindFirstChild("Crafting")
    local products = cr and cr:FindFirstChild("Products")
    local list = {}
    if not products then return list end
    for _, btn in ipairs(products:GetChildren()) do
        if btn:IsA("TextButton") and btn.Name ~= "Template" and btn.BackgroundTransparency < 0.5 then
            if not isSCMode then
                list[#list + 1] = btn.Name
            else
                local n = string.lower(btn.Name)
                if n ~= "heavenly ingot" then
                    for _, kw in ipairs(SC_KEYWORDS) do
                        if string.find(n, kw, 1, true) then list[#list + 1] = btn.Name break end
                    end
                end
            end
        end
    end
    table.sort(list)
    return list
end

local function getMiniGameUI()
    local cg = playerGui:FindFirstChild("CraftingGame")
    local main = cg and cg:FindFirstChild("Main")
    if not main or not main.Visible then return nil end
    local area, mover = main:FindFirstChild("ClickArea"), main:FindFirstChild("Mover")
    if not area or not mover or area.AbsoluteSize.X == 0 then return nil end
    local strike = main:FindFirstChild("Strike") or main:FindFirstChild("StrikeButton") or main:FindFirstChildOfClass("TextButton")
    return {area = area, mover = mover, strike = strike}
end

local function requestForgeStop()
    if not F.active then return end
    F.stopping, F.minigame = true, false
    updateForgeUI(T("forgeFinishing"), Color3.fromRGB(200, 120, 0))
end

local function stopForgeAutoFarm(reason, color)
    F.active, F.stopping, F.ingots, F.minigame = false, false, false, false
    updateForgeUI(reason or T("farmStopped"), color or Color3.fromRGB(255, 100, 100))
    if F.loop and coroutine.running() ~= F.loop then pcall(task.cancel, F.loop) end
end

local function safeWait(seconds)
    local waited = 0
    while waited < seconds do
        task.wait(0.2)
        waited += 0.2
        if F.stopping then return false end
    end
    return true
end

local function startForgeAutoFarm(isIngotMode)
    if F.active then requestForgeStop() return end
    if not isIngotMode and not F.product then
        updateForgeUI(T("forgeErrNoItem"), Color3.fromRGB(255, 100, 0))
        return
    end
    minimizeHub()
    F.active, F.stopping, F.ingots, F.cycles, F.errors = true, false, isIngotMode, 0, 0
    updateForgeUI(T("forgeStarting"), Color3.fromRGB(0, 255, 0))

    F.loop = task.spawn(function()
        while F.active do
            if F.stopping then stopForgeAutoFarm() break end

            -- 1. Проверяем, что целевой предмет ещё доступен
            local items = getAvailableProducts(F.ingots)
            if not (F.product and table.find(items, F.product)) then
                if F.ingots and #items > 0 then
                    F.product = items[1]
                    updateForgeUI(T("forgeChangedTarget") .. F.product, Color3.fromRGB(255, 150, 0))
                    if refForgeSelectBtn then refForgeSelectBtn.Text = F.product end
                else
                    stopForgeAutoFarm(T(F.ingots and "forgeErrNoIngots" or "forgeErrNoMats"))
                    break
                end
            end

            -- 2. Ждём кнопку предмета (при необходимости открываем меню на X)
            updateForgeUI(T("forgeWaitUI"), Color3.fromRGB(255, 200, 0))
            local waited = 0
            while F.active and not F.stopping do
                local b = getForgeElement("Product", F.product)
                if b and b.BackgroundTransparency < 0.5 then break end
                task.wait(0.5)
                waited += 0.5
                if waited >= 3 then
                    updateForgeUI(T("forgeOpenMenu"), Color3.fromRGB(200, 200, 200))
                    pressX()
                    waited = 0
                    if not safeWait(1.5) then break end
                end
            end
            if F.stopping or not F.active then stopForgeAutoFarm() break end

            -- 3. Крафт
            local prodBtn, craftBtn = getForgeElement("Product", F.product), getForgeElement("CraftBtn")
            if prodBtn and craftBtn then
                clickGUI(prodBtn)
                if not safeWait(0.5) then stopForgeAutoFarm() break end
                clickGUI(craftBtn)
                if not safeWait(1.5) then stopForgeAutoFarm() break end

                if getMiniGameUI() then
                    F.minigame, F.clicks, F.errors = true, 0, 0
                    updateForgeUI(T("forgeMinigame"), Color3.fromRGB(0, 200, 255))
                    local farmTime = 0
                    while F.minigame and F.active and not F.stopping do
                        task.wait(0.1)
                        farmTime += 0.1
                        if farmTime > 15 then F.minigame = false break end
                    end
                    if not F.stopping then
                        F.cycles += 1
                        updateForgeUI(T("forgeCloseSuccess"), Color3.fromRGB(0, 255, 0))
                        local exitTimer = 0
                        while exitTimer < 5 and not F.stopping do
                            if clickSuccessExit() then break end
                            task.wait(0.2)
                            exitTimer += 0.2
                        end
                        if not safeWait(0.5) then stopForgeAutoFarm() break end
                    end
                else
                    F.errors += 1
                    updateForgeUI(T("forgeResetUI"), Color3.fromRGB(255, 100, 0))
                    local closeBtn = getForgeElement("CloseBtn")
                    if closeBtn then clickGUI(closeBtn) end
                    if not safeWait(2) then stopForgeAutoFarm() break end
                    pressX()

                    if not F.ingots then
                        if not safeWait(1) then stopForgeAutoFarm() break end
                        if table.find(getAvailableProducts(false), F.product) then
                            updateForgeUI(T("forgeRetry"), Color3.fromRGB(200, 150, 255))
                        else
                            stopForgeAutoFarm(string.format(T("forgeErrNoMatsFor"), F.product))
                            break
                        end
                    else
                        if not safeWait(2) then stopForgeAutoFarm() break end
                        local foundNew = false
                        for _, v in ipairs(getAvailableProducts(true)) do
                            if v ~= F.product then
                                F.product, foundNew = v, true
                                updateForgeUI(T("forgeTakeOther") .. F.product, Color3.fromRGB(200, 150, 255))
                                if refForgeSelectBtn then refForgeSelectBtn.Text = F.product end
                                break
                            end
                        end
                        if not foundNew then stopForgeAutoFarm(T("forgeErrNoIngots")) break end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

-- Авто-клик мини-игры кузни
track(RunService.Heartbeat:Connect(function()
    if not F.minigame or F.clicking or F.stopping then return end
    local ui = getMiniGameUI()
    if not ui then F.minigame = false return end
    local left = ui.area.AbsolutePosition.X
    local right = left + ui.area.AbsoluteSize.X
    local center = ui.mover.AbsolutePosition.X + ui.mover.AbsoluteSize.X / 2
    if center >= left and center <= right then
        F.clicking = true
        F.clicks += 1
        local target = ui.strike or ui.area
        local x = target.AbsolutePosition.X + target.AbsoluteSize.X / 2
        local y = target.AbsolutePosition.Y + target.AbsoluteSize.Y / 2 + CLICK_Y_OFFSET
        if ui.strike and ui.strike:IsA("TextButton") then
            pcall(function() firesignal(ui.strike.MouseButton1Click) end)
        end
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
        task.wait(0.3)
        if F.clicks >= 2 then F.minigame, F.clicks = false, 0 end
        F.clicking = false
    end
end))

local function createMiniForgeUI()
    if miniForgeGui then miniForgeGui:Destroy() end
    miniForgeGui = new("ScreenGui", {Name = "PidromaniaMiniForge", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = (F.product ~= nil)}, playerGui)
    local frame = new("Frame", {Size = UDim2.new(0, 260, 0, 130), Position = UDim2.new(0.5, -130, 0, 20), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, Active = true}, miniForgeGui)
    round(frame, 8)
    local header = new("TextLabel", {Size = UDim2.new(1, 0, 0, 25), BackgroundTransparency = 1, Text = T("forgeMiniTitle"), TextColor3 = Color3.fromRGB(255, 200, 100), Font = Enum.Font.GothamBold, TextSize = 14, Active = true}, frame)
    MakeDraggableTouch(header, frame)
    miniForgeStatus = new("TextLabel", {Size = UDim2.new(1, -10, 0, 35), Position = UDim2.new(0, 5, 0, 25), BackgroundTransparency = 1, Text = T("forgeWaiting"), TextColor3 = Color3.fromRGB(100, 200, 255), Font = Enum.Font.Gotham, TextSize = 12, TextWrapped = true}, frame)
    local function mkBtn(y)
        local b = new("TextButton", {Size = UDim2.new(1, -10, 0, 30), Position = UDim2.new(0, 5, 0, y), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Color3.new(1, 1, 1)}, frame)
        round(b, 6)
        return b
    end
    miniForgeFarmBtn, miniForgeIngotBtn = mkBtn(60), mkBtn(95)
    miniForgeFarmBtn.MouseButton1Click:Connect(function()
        if F.active and not F.ingots then requestForgeStop() else startForgeAutoFarm(false) end
    end)
    miniForgeIngotBtn.MouseButton1Click:Connect(function()
        if F.active and F.ingots then requestForgeStop() else startForgeAutoFarm(true) end
    end)
    updateForgeUI()
end

------------------------------------------------------------------
-- UI: хелперы страниц
------------------------------------------------------------------
local UI = {}                       -- main, mini, content
local pageOrder = 0
local COL_BTN, COL_TXT, COL_TITLE = Color3.fromRGB(60, 60, 80), Color3.fromRGB(240, 240, 255), Color3.fromRGB(200, 200, 255)
local COL_RED = Color3.fromRGB(255, 100, 100)

local function put(obj)
    pageOrder += 1
    obj.LayoutOrder = pageOrder
    obj.Parent = UI.content
    return obj
end

local function clearContent()
    for _, c in ipairs(UI.content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    pageOrder = 0
end

local function title(text, color)
    return put(new("TextLabel", {Text = text, Size = UDim2.new(1, 0, 0, 37.5), BackgroundTransparency = 1, TextColor3 = color or COL_TITLE, Font = Enum.Font.GothamBold, TextSize = 21}))
end

local function note(text, color)
    return put(new("TextLabel", {Text = text, Size = UDim2.new(1, -15, 0, 30), BackgroundTransparency = 1, TextColor3 = color or Color3.fromRGB(180, 180, 220), Font = Enum.Font.GothamSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left}))
end

local function button(text, cb)
    local b = new("TextButton", {Text = text, Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = COL_BTN, TextColor3 = COL_TXT, Font = Enum.Font.GothamSemibold, TextSize = 21, AutoButtonColor = true})
    round(b, 9)
    b.MouseButton1Click:Connect(cb)
    return put(b)
end

local function createToggleSwitch(label, initial, onToggle)
    local frame = new("Frame", {Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = COL_BTN, BorderSizePixel = 0})
    round(frame, 9)
    new("TextLabel", {Text = label, Size = UDim2.new(0, 270, 1, 0), Position = UDim2.new(0, 7.5, 0, 0), BackgroundTransparency = 1, TextColor3 = COL_TXT, Font = Enum.Font.GothamSemibold, TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    local bg = new("Frame", {Size = UDim2.new(0, 60, 0, 30), Position = UDim2.new(1, -67.5, 0.5, -15), BorderSizePixel = 0}, frame)
    round(bg, 15)
    local knob = new("Frame", {Size = UDim2.new(0, 24, 0, 24), BorderSizePixel = 0}, bg)
    round(knob, 12)
    local enabled = initial
    local function refresh()
        bg.BackgroundColor3 = enabled and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(80, 80, 90)
        knob.BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
        knob.Position = enabled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    end
    refresh()
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            onToggle(enabled)
            refresh()
            SaveConfig()
        end
    end)
    return frame, function(state) enabled = state refresh() end
end

local function toggle(label, initial, cb)
    local frame, set = createToggleSwitch(label, initial, cb)
    put(frame)
    return frame, set
end

-- Строка с полем ввода (без переключателя)
local function inputRow(label, value, boxWidth, placeholder, onCommit)
    local frame = new("Frame", {Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = COL_BTN, BorderSizePixel = 0})
    round(frame, 9)
    new("TextLabel", {Text = label, Size = UDim2.new(1, -(boxWidth + 25), 1, 0), Position = UDim2.new(0, 7.5, 0, 0), BackgroundTransparency = 1, TextColor3 = COL_TXT, Font = Enum.Font.GothamSemibold, TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    local box = new("TextBox", {Size = UDim2.new(0, boxWidth, 0, 30), Position = UDim2.new(1, -(boxWidth + 7.5), 0.5, -15), BackgroundColor3 = Color3.fromRGB(40, 40, 50), TextColor3 = Color3.new(1, 1, 1), PlaceholderText = placeholder or "", PlaceholderColor3 = Color3.fromRGB(140, 140, 150), Text = value, Font = Enum.Font.GothamSemibold, TextSize = 18, ClearTextOnFocus = false}, frame)
    round(box, 6)
    box.FocusLost:Connect(function() onCommit(box) end)
    put(frame)
    return frame, box
end

------------------------------------------------------------------
-- UI: страницы
------------------------------------------------------------------
-- Максимальный открытый этаж. Ищем в данных игрока значения вида "MaxFloor/HighestFloor/UnlockedFloor".
-- Если ничего не нашли - возвращаем nil, и показываются все этажи.
local FLOOR_KEY_HINTS = {"max", "highest", "unlock", "best", "top", "reach"}
local function getUnlockedMaxFloor()
    local stats = player:FindFirstChild("PlayerStats")
    local hf = stats and stats:FindFirstChild("HighestFloor")
    if hf and tonumber(hf.Value) then return tonumber(hf.Value) end
    local best
    local function consider(name, v)
        name = string.lower(name)
        if not string.find(name, "floor", 1, true) then return end
        for _, h in ipairs(FLOOR_KEY_HINTS) do
            if string.find(name, h, 1, true) then
                local n = tonumber(v)
                if n and (not best or n > best) then best = n end
                return
            end
        end
    end
    for _, root in ipairs(player:GetChildren()) do
        if root ~= playerGui then
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("IntValue") or d:IsA("NumberValue") or d:IsA("StringValue") then consider(d.Name, d.Value) end
            end
        end
    end
    for k, v in pairs(player:GetAttributes()) do consider(k, v) end
    return best
end

local cachedMaxFloor, cachedMaxAt = nil, -10
local function isFloorUnlocked(floorNum, placeId)
    if os.clock() - cachedMaxAt > 2 then cachedMaxFloor, cachedMaxAt = getUnlockedMaxFloor(), os.clock() end
    return not cachedMaxFloor or floorNum <= cachedMaxFloor
end

local function showFloors()
    clearContent()
    title(T("selectFloor"))
    for _, f in ipairs(FLOORS) do
        if f[3] == game.PlaceId or isFloorUnlocked(f[1], f[3]) then
            button(string.format(T("floorBtn"), f[1], f[2]), function()
                pcall(function() TeleportService:Teleport(f[3], player) end)
            end)
        end
    end
end

-- Страница со списком телепортов (боссы / локации)
local function teleportPage(headerKey, headerColor, source, emptyKey)
    clearContent()
    local fd = currentFloorData()
    if not fd then title(T("unknownFloor"), COL_RED) return end
    title(string.format(T(headerKey), fd[1], fd[2]), headerColor)
    local list = source[game.PlaceId]
    if not list or #list == 0 then note(T(emptyKey), Color3.fromRGB(255, 255, 100)) return end
    for _, d in ipairs(list) do
        local x, y, z = d[2], d[3], d[4]
        button(N(d[1]), function() teleport(Vector3.new(x, y, z)) end)
    end
end
local function showBosses() teleportPage("bossesOfFloor", COL_TITLE, BOSSES, "noBosses") end
local function showBossRooms() teleportPage("roomsAndLocs", Color3.fromRGB(255, 200, 100), EXTRA_LOCATIONS, "noExtraLocs") end

local function showBossFarms()
    clearContent()
    title(T("bossFarms"))
    local farms = BOSS_FARMS[game.PlaceId]
    if not farms or #farms == 0 then title(T("noFarms")) return end
    for _, d in ipairs(farms) do
        local id, pos = d[1], d[2]
        toggle(N(FARM_NAMES[id] or id), S.farmMode == id, function(on)
            stopAllFarms()
            if on then startGenericFarm(id, pos) end
            SaveConfig()
        end)
    end
end

local function showMaterialFarm()
    clearContent()
    title(T("matAndFish"))
    note(T("autoOreSelect"))

    local names, seen = {}, {}
    local folder = Workspace:FindFirstChild("Materials")
    if folder then
        for _, m in ipairs(folder:GetChildren()) do
            if not seen[m.Name] then seen[m.Name] = true names[#names + 1] = m.Name end
        end
    end
    table.sort(names)
    if #names == 0 then note(T("noOresFound"), COL_RED) end
    for _, name in ipairs(names) do
        if S.ores[name] == nil then S.ores[name] = false end
        toggle(name, S.ores[name], function(on) S.ores[name] = on end)
    end

    local _, setMat
    _, setMat = toggle(T("startFarmBtn"), S.materialFarm, function(on)
        if not on then stopMaterialFarm() SaveConfig() return end
        local any = false
        for _, v in pairs(S.ores) do if v then any = true break end end
        if any then startMaterialFarm() else S.materialFarm = false setMat(false) end
    end)

    toggle(T("autoFish"), S.fishFarm, function(on)
        if on then startFishFarm() else stopFishFarm() end
    end)

    -- Кузня
    title(T("forgeTitle"))
    local topRow = put(new("Frame", {Size = UDim2.new(1, -15, 0, 40), BackgroundTransparency = 1}))
    refForgeSelectBtn = new("TextButton", {Size = UDim2.new(1, -45, 1, 0), BackgroundColor3 = COL_BTN, Text = F.product or T("forgeSelect"), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 18}, topRow)
    round(refForgeSelectBtn, 8)
    local refreshBtn = new("TextButton", {Size = UDim2.new(0, 40, 1, 0), Position = UDim2.new(1, -40, 0, 0), BackgroundColor3 = Color3.fromRGB(80, 80, 100), Text = "🔄", TextSize = 20}, topRow)
    round(refreshBtn, 8)

    local grid = put(new("Frame", {Size = UDim2.new(1, -15, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Visible = false}))
    new("UIGridLayout", {CellSize = UDim2.new(0.31, 0, 0, 35), CellPadding = UDim2.new(0.02, 0, 0, 10)}, grid)

    local function populate()
        for _, c in ipairs(grid:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        for _, name in ipairs(getAvailableProducts(false)) do
            local b = new("TextButton", {Text = name, BackgroundColor3 = Color3.fromRGB(50, 50, 70), TextColor3 = Color3.fromRGB(220, 220, 220), Font = Enum.Font.Gotham, TextSize = 14}, grid)
            round(b, 6)
            b.MouseButton1Click:Connect(function()
                F.product = name
                refForgeSelectBtn.Text = name
                grid.Visible = false
                updateForgeUI(T("forgeReady"), Color3.fromRGB(0, 255, 0))
                if miniForgeGui then miniForgeGui.Enabled = true end
            end)
        end
    end
    refForgeSelectBtn.MouseButton1Click:Connect(function()
        grid.Visible = not grid.Visible
        if grid.Visible then populate() end
    end)
    refreshBtn.MouseButton1Click:Connect(function() grid.Visible = true populate() end)

    refForgeStatus = put(new("TextLabel", {Size = UDim2.new(1, -15, 0, 45), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16}))
    put(new("TextLabel", {Size = UDim2.new(1, -15, 0, 20), BackgroundTransparency = 1, Text = T("forgeStartHint"), TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Gotham, TextSize = 14}))
    updateForgeUI(F.active and T("forgeStarting") or T("forgeWaiting"))
end

local function showPaths()
    clearContent()
    title(T("pathsTitle"))
    local fd = currentFloorData()
    if not fd then title(T("unknownFloor"), COL_RED) return end
    note(string.format(T("youAreOnFloor"), fd[2], fd[1]))
    local entries = PATHS[fd[1]]
    if not entries then note(T("noPathsForFloor"), Color3.fromRGB(200, 200, 200)) return end

    for _, e in ipairs(entries) do
        local label, file = N(e[1]), e[2]
        local url = PATH_BASE .. fd[1] .. PATH_SUFFIX .. file .. ".lua"
        local btn
        btn = button("🗺️ " .. label, function()
            local original = btn.Text
            btn.Text, btn.Interactable = T("pathLoading"), false
            local ok = pcall(function()
                local code = game:HttpGet(url)
                if not code or code == "" then error("Error 404") end
                local fn = loadstring(code)
                if not fn then error("loadstring nil") end
                fn()
            end)
            btn.Text = (ok and "✅ " or "❌ ") .. label .. " (" .. T(ok and "pathSuccess" or "pathError") .. ")"
            btn.BackgroundColor3 = ok and Color3.fromRGB(40, 100, 40) or Color3.fromRGB(100, 40, 40)
            task.delay(2, function()
                if btn.Parent then
                    btn.Text, btn.Interactable, btn.BackgroundColor3 = original, true, COL_BTN
                end
            end)
        end)
        btn.TextColor3, btn.Font = Color3.fromRGB(200, 255, 200), Enum.Font.GothamBold
    end
end

local function showTools()
    clearContent()
    title(T("tools") .. ":")
    toggle(T("safe1Toggle"), S.safe1, function(on) if on then startSafe1() else stopSafe1() end end)
    toggle(T("autoMobWalk"), S.autoWalk, function(on) if on then startAutoWalk() else stopAutoWalk() end end)
    toggle(T("freezeToggle"), isFrozen, function() toggleFreeze() end)
    toggle(T("respawnToggle"), S.respawn, function(on)
        S.respawn = on
        if on then setupResurrection() else cleanupResurrection() end
    end)
    toggle(T("playerListToggle"), S.playerList, function(on)
        S.playerList = on
        if on then createPlayerListGui() else destroyPlayerListGui() end
    end)
    toggle(T("blockAllToggle"), S.blockAll, function(on) if on then startBlockAll() else stopBlockAll() end end)

    local autoFFrame = toggle(T("autoF"), S.autoF, function(on) if on then startAutoF() else stopAutoF() end end)
    local cdBox = new("TextBox", {Size = UDim2.new(0, 52.5, 0, 30), Position = UDim2.new(1, -142.5, 0.5, -15), BackgroundColor3 = Color3.fromRGB(40, 40, 50), TextColor3 = Color3.new(1, 1, 1), Text = tostring(S.autoF_cd), Font = Enum.Font.GothamSemibold, TextSize = 18, ClearTextOnFocus = false}, autoFFrame)
    round(cdBox, 6)
    cdBox.FocusLost:Connect(function()
        local n = tonumber(cdBox.Text)
        if n and n >= 0 then S.autoF_cd = n else cdBox.Text = tostring(S.autoF_cd) end
        SaveConfig()
    end)

    inputRow(T("autoClicker"), tostring(S.clickCps), 90, "2.8", function(box)
        local n = tonumber(box.Text)
        if n and n >= 0.1 and n <= 50 then S.clickCps = n else box.Text = tostring(S.clickCps) end
        SaveConfig()
    end)

    toggle(T("autoHeal"), S.autoHeal, function(on) if on then startAutoHeal() else stopAutoHeal() end end)
    toggle(T("questEspToggle"), S.questEsp, function(on) if on then startQuestEsp() else stopQuestEsp() end end)

    inputRow(T("customFlag"), S.flagName, 260, T("flagHint"), function(box)
        local name = (box.Text:gsub("%s+", ""))
        applyFlag(name)
        box.Text = name
    end)
end

local rebuildGUI
local function showSettings()
    clearContent()
    title(T("languageLabel"))
    for _, code in ipairs({"ru", "uk", "en"}) do
        button(T("lang_" .. code), function()
            S.language = code
            SaveConfig()
            rebuildGUI()
            createMiniForgeUI()
        end)
    end
end

------------------------------------------------------------------
-- UI: главное окно
------------------------------------------------------------------
function minimizeHub()
    if UI.main and UI.mini and UI.main.Visible then
        UI.main.Visible, UI.mini.Visible = false, true
    end
end

function rebuildGUI()
    if screenGuiMain then screenGuiMain:Destroy() end
    for _, v in ipairs(playerGui:GetChildren()) do
        if v.Name == "PidromaniaHub" then v:Destroy() end
    end
    screenGuiMain = new("ScreenGui", {Name = "PidromaniaHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Enabled = not isEvading}, playerGui)
    ApplyMobileScale(screenGuiMain, 1250)

    local main = new("Frame", {Size = UDim2.new(0, 1200, 0, 750), Position = UDim2.new(0.5, -600, 0.5, -375), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, Active = true}, screenGuiMain)
    round(main, 15)
    local mini = new("Frame", {Size = UDim2.new(0, 150, 0, 45), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Visible = false, Active = true}, screenGuiMain)
    round(mini, 9)
    MakeDraggableTouch(mini, mini)
    new("TextLabel", {Text = "Pidromania Hub", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = COL_TITLE, Font = Enum.Font.GothamBold, TextSize = 18}, mini)
    mini.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            main.Visible, mini.Visible = true, false
        end
    end)
    UI.main, UI.mini = main, mini

    -- Шапка
    local header = new("Frame", {Size = UDim2.new(1, 0, 0, 52.5), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Active = true}, main)
    round(header, 9)
    MakeDraggableTouch(header, main)
    local titleLbl = new("TextLabel", {Text = T("hubTitle"), Font = Enum.Font.GothamBold, TextSize = 21, BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220, 220, 255), Position = UDim2.new(0, 5, 0, 10.5)}, header)
    local ts = TextService:GetTextSize(titleLbl.Text, 21, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge))
    titleLbl.Size = UDim2.new(0, ts.X * 1.1, 0, 30)
    local authorLbl = new("TextLabel", {Text = T("byAuthor"), Font = Enum.Font.GothamSemibold, TextSize = 18, BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 180)}, header)
    local as = TextService:GetTextSize(authorLbl.Text, 18, Enum.Font.GothamSemibold, Vector2.new(math.huge, math.huge))
    authorLbl.Size = UDim2.new(0, as.X * 1.1, 0, 30)
    authorLbl.Position = UDim2.new(0, 5 + ts.X * 1.1 - 15, 0, 10.5)
    new("TextButton", {Text = "—", Size = UDim2.new(0, 37.5, 0, 37.5), Position = UDim2.new(1, -45, 0, 7.5), BackgroundColor3 = Color3.fromRGB(60, 60, 70), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 21}, header)
        .MouseButton1Click:Connect(minimizeHub)

    -- Панели
    local left = new("Frame", {Size = UDim2.new(0, 300, 1, -52.5), Position = UDim2.new(0, 0, 0, 52.5), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0}, main)
    round(left, 12)
    new("UIListLayout", {Padding = UDim.new(0, 4.5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, left)
    new("UIPadding", {PaddingTop = UDim.new(0, 7.5)}, left)

    local right = new("Frame", {Size = UDim2.new(1, -315, 1, -52.5), Position = UDim2.new(0, 315, 0, 52.5), BackgroundColor3 = Color3.fromRGB(30, 30, 35), BorderSizePixel = 0}, main)
    round(right, 12)
    UI.content = new("ScrollingFrame", {Size = UDim2.new(1, -15, 1, -15), Position = UDim2.new(0, 7.5, 0, 7.5), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BackgroundTransparency = 1}, right)
    round(UI.content, 9)
    new("UIListLayout", {Padding = UDim.new(0, 7.5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, UI.content)

    -- Меню
    local menu = {}
    local function select(btn)
        for _, b in ipairs(menu) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end
    local function addMenu(text, icon, pageFn)
        local btn = new("TextButton", {Text = "  " .. icon .. "  " .. text, Size = UDim2.new(1, -15, 0, 52.5), LayoutOrder = #menu + 1, BackgroundColor3 = Color3.fromRGB(50, 50, 60), TextColor3 = Color3.fromRGB(220, 220, 255), Font = Enum.Font.GothamSemibold, TextSize = 21, AutoButtonColor = true}, left)
        round(btn, 9)
        btn.MouseButton1Click:Connect(function() select(btn) pageFn() end)
        menu[#menu + 1] = btn
        return btn
    end
    local first = addMenu(T("floor"), "🌍", showFloors)
    addMenu(T("teleports"), "🌐", showBosses)
    addMenu(T("bossRooms"), "🚪", showBossRooms)
    addMenu(T("bossFarm"), "👹", showBossFarms)
    addMenu(T("materialFarm"), "📦", showMaterialFarm)
    addMenu(T("paths"), "🗺️", showPaths)
    addMenu(T("tools"), "🛠️", showTools)
    addMenu(T("settings"), "⚙️", showSettings)

    select(first)
    showFloors()
end

------------------------------------------------------------------
-- Anti-AFK
------------------------------------------------------------------
track(player.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    pcall(function()
        local cf = Workspace.CurrentCamera.CFrame
        VirtualUser:Button2Down(Vector2.new(0, 0), cf)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), cf)
    end)
end))

------------------------------------------------------------------
-- ESP
------------------------------------------------------------------
local SPECIAL_PLAYERS = {
    ["huesos880055535"] = {text = "Lvl: Dominus", color = Color3.fromRGB(138, 43, 226)}
}
local espObjects = {}

local function removeEsp(name)
    local e = espObjects[name]
    if e then
        for _, d in pairs(e) do
            d.Visible = false
            pcall(function() d:Remove() end)
        end
        espObjects[name] = nil
    end
end

local function hideEsp(e) e.box.Visible, e.name.Visible, e.level.Visible = false, false, false end

local function newEsp()
    local e = {box = Drawing.new("Square"), name = Drawing.new("Text"), level = Drawing.new("Text")}
    e.box.Thickness, e.box.Filled = 2, false
    e.name.Size, e.name.Outline, e.name.Center = 20, true, true
    e.level.Size, e.level.Outline, e.level.Center = 18, true, true
    return e
end

track(Players.PlayerRemoving:Connect(function(plr) removeEsp(plr.Name) end))

if Drawing and Drawing.new then
    track(RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local name = plr.Name
                local char = plr.Character
                local hum = char and char:FindFirstChild("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                local head = char and char:FindFirstChild("Head")
                local e = espObjects[name]

                if not (hum and root and head) or hum.Health <= 0 then
                    if e then hideEsp(e) end
                else
                    local special = SPECIAL_PLAYERS[string.lower(name)]
                    if special and not char:FindFirstChild("EspHighlight") then
                        new("Highlight", {Name = "EspHighlight", FillColor = special.color, OutlineColor = special.color, FillTransparency = 0.7}, char)
                    end
                    if not e then e = newEsp() espObjects[name] = e end

                    local hv, hVis = cam:WorldToViewportPoint(head.Position)
                    local rv, rVis = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    if hVis and rVis then
                        local height = math.abs(hv.Y - rv.Y) * 1.5
                        local width = height * 0.6
                        e.box.Size = Vector2.new(width, height)
                        e.box.Position = Vector2.new(hv.X - width / 2, hv.Y - height * 0.15)
                        e.box.Color = special and special.color or Color3.fromRGB(255, 0, 0)
                        e.box.Visible = true

                        e.name.Text = name
                        e.name.Color = Color3.new(1, 1, 1)
                        e.name.Position = Vector2.new(hv.X, hv.Y - 25)
                        e.name.Visible = true

                        e.level.Text = special and special.text or ("Lvl: " .. tostring(getPlayerLevel(plr)))
                        e.level.Color = special and special.color or Color3.fromRGB(0, 255, 255)
                        e.level.Position = Vector2.new(hv.X, hv.Y - 5)
                        e.level.Visible = true
                    else
                        hideEsp(e)
                    end
                end
            end
        end
    end))
end

------------------------------------------------------------------
-- Горячая клавиша G: показать/скрыть хаб (+ аварийная остановка кузни)
------------------------------------------------------------------
track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= KEY.G then return end
    if F.active then
        stopForgeAutoFarm(T("forgeEmergencyStop"), Color3.fromRGB(255, 50, 50))
    end
    if UI.main and UI.mini then
        local show = not UI.main.Visible
        UI.main.Visible, UI.mini.Visible = show, not show
    end
end))

------------------------------------------------------------------
-- Остановка этого экземпляра при повторном запуске скрипта
------------------------------------------------------------------
getgenv().PidromaniaHubStop = function()
    for _, k in ipairs({"safe1", "autoWalk", "fishFarm", "materialFarm", "autoF", "autoHeal", "blockAll", "questEsp"}) do S[k] = false end
    if S.flagName ~= "" then getgenv()[S.flagName] = nil end
    S.farmMode = nil
    F.active, F.stopping, F.minigame = false, false, false
    isEvading = false
    setFarmFreeze(false) setManualFreeze(false)
    stopFishConn()
    cleanupResurrection()
    destroyPlayerListGui()
    clearQuestEsp()
    for _, c in ipairs(connections) do c:Disconnect() end
    for name in pairs(espObjects) do removeEsp(name) end
    if F.loop then pcall(task.cancel, F.loop) end
    local function kill(g) if g then g:Destroy() end end
    kill(screenGuiMain) kill(miniForgeGui) kill(screenGui) kill(lockGui)
end

------------------------------------------------------------------
-- ЗАПУСК
------------------------------------------------------------------
LoadConfig()
if S.flagName ~= "" then getgenv()[S.flagName] = true end
createMiniForgeUI()

local hasStrangers = false
if S.safe1 then
    for _, t in ipairs(Players:GetPlayers()) do
        if t ~= player and not isFriend(t) then hasStrangers = true break end
    end
end

if S.safe1 and hasStrangers then
    triggerEvasion()
else
    if S.safe1 then startSafe1() end
    if S.respawn then setupResurrection() end
    if S.autoWalk then startAutoWalk() end
    if S.materialFarm then startMaterialFarm() end
    if S.fishFarm then startFishFarm() end
    if S.playerList then createPlayerListGui() end
    if S.autoF then startAutoF() end
    if S.autoHeal then startAutoHeal() end
    if S.blockAll then startBlockAll() end
    if S.questEsp then startQuestEsp() end

    if S.farmMode then
        for _, d in ipairs(BOSS_FARMS[game.PlaceId] or {}) do
            if d[1] == S.farmMode then
                startGenericFarm(S.farmMode, d[2])
                task.delay(4, function()
                    if not isEvading then
                        tapKey(KEY.Q)
                        if not S.autoWalk then
                            startAutoWalk()
                            SaveConfig()
                        end
                    end
                end)
                break
            end
        end
    end
end

rebuildGUI()

-- АВТО-ВОЗВРАТ С 17 НА 18
task.spawn(function()
    task.wait(2)
    if game.PlaceId == 12632324801 and S.farmMode == "Thug Boss (Server Hop)" and not isEvading then
        thugHop()
    end
end)
