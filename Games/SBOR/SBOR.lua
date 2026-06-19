print("[MAIN] Запуск GameAFK.lua начат...")

getgenv().SBOPIDROMANIA = true
print("[MAIN] Флаг SBOPIDROMANIA установлен в true")
print("[MAIN] Пауза 6 секунд прошла, подгружаю сервисы...")

local Players = game:GetService("Players")
print("[MAIN] Скрипт полностью инициализирован!")

local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

local friendsCache = {}
local function isFriend(targetPlr)
    if targetPlr == player then return true end
    if friendsCache[targetPlr.UserId] ~= nil then
        return friendsCache[targetPlr.UserId]
    end
    
    local success, result = pcall(function()
        return player:IsFriendsWith(targetPlr.UserId)
    end)
    
    if success then
        friendsCache[targetPlr.UserId] = result
        return result
    end
    return false
end

local currentLang = "ru" 
local translations = {
    ru = {
        hubTitle = "Pidromania Hub: Sword Blox Online",
        byAuthor = "by @Pidromania",
        floor = "Этаж",
        teleports = "Телепорт к мобам",
        bossRooms = "Телепорт к локациям",
        bossFarm = "Фарм боссов",
        materialFarm = "Фарм ресурсов",
        paths = "Пути",
        tools = "Инструменты",
        settings = "Настройки",
        selectFloor = "Выберите этаж:",
        unknownFloor = "Ошибка: неизвестный этаж",
        noBosses = "На этом этаже нет боссов",
        bossesOfFloor = "Боссы этажа %d (%s):",
        bossFarms = "Фарм боссов:",
        noFarms = "Нет доступных фармов на этом этаже",
        matAndFish = "Фарм ресурсов и рыбы",
        autoOreSelect = "Выберите руду для сбора:",
        noOresFound = "Ресурсы не найдены на этом этаже.",
        startFarmBtn = "🟢 ЗАПУСТИТЬ АВТО-СБОР",
        warnNoSelection = "⚠️ Выберите хотя бы один тип руды!",
        autoFish = "Авто-ловля рыбы (10 каждые 1 минуту)",
        freezeToggle = "Фриз игрока на месте",
        respawnToggle = "Воскрешение на месте смерти",
        playerListToggle = "Список игроков на сервере",
        safe1Toggle = "Экстренная Эвакуация (Смерть, Блок, Hop)",
        blockAllToggle = "Массовая Блокировка Игроков",
        autoMobWalk = "Автофарм близжайших мобов",
        autoF = "Нажиматор F",
        autoHeal = "Хилка (Здоровье < 70%)",
        languageLabel = "Язык интерфейса:",
        lang_ru = "Русский",
        lang_uk = "Українська",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Загрузка...",
        pathError = "❌ Ошибка!",
        pathSuccess = "✅ Запущен!",
        noPathsForFloor = "Для этого этажа нет путей.",
        roomsAndLocs = "Комнаты и Локации: %s (%s)",
        noExtraLocs = "⚠️ Для этого этажа нет дополнительных локаций.",
        youAreOnFloor = "Вы на этаже: %s (ID: %d)",
        pathsTitle = "Пути (Paths)",
        farmPrefix = "Farm: ",
        forgeTitle = "🛠️ Кузня (Авто-крафт)",
        forgeSelect = "Выбрать предмет",
        forgeRefresh = "Обновить",
        forgeFarmItem = "▶ ФАРМ ПРЕДМЕТА",
        forgeFarmIngots = "💎 ФАРМ СК (Только слитки)",
        forgeStop = "⏹ ОСТАНОВИТЬ",
        forgeMiniTitle = "🛠️ Управление кузней",
        forgeWaiting = "Ожидание...",
        forgeFinishing = "⏳ ЗАКАНЧИВАЮ...",
        forgeChangedTarget = "Сменил цель: ",
        forgeWaitUI = "Жду предмет UI...",
        forgeOpenMenu = "Открываю меню (X)...",
        forgeStarting = "Запуск...",
        forgeMinigame = "Мини-игра...",
        forgeCloseSuccess = "Закрываю окно успеха...",
        forgeResetUI = "Сброс UI...",
        forgeRetry = "Пробуем снова...",
        forgeTakeOther = "Беру другое: ",
        forgeReady = "Готов к крафту",
        forgeStartHint = "⚠️ Запуск фарма находится в мини-панели на экране",
        forgeEmergencyStop = "Экстренная остановка (Открыт HUB)!",
        forgeStoppedTitle = "⚠️ КУЗНЯ ОСТАНОВЛЕНА",
        forgeStoppedDesc = "Авто-кузня была выключена, чтобы избежать мисскликов по Hub'у!",
        errorTitle = "⚠️ Ошибка",
        forgeErrNoItem = "Сначала выбери предмет из списка!",
        farmStopped = "Фарм остановлен",
        forgeErrNoIngots = "Доступные слитки закончились!",
        forgeErrNoMats = "Ресурсы для предмета закончились!",
        forgeErrNoMatsFor = "Ресурсы для %s закончились!",
        forgeItem = "Предмет: ",
        forgeNotSelected = "Не выбран",
        forgeStatusLbl = "Статус: ",
        forgeCycles = "Циклы: ",
        forgeErrors = "Ошибки: "
    },
    uk = {
        hubTitle = "Pidromania Hub: Sword Blox Online",
        byAuthor = "by @Pidromania",
        floor = "Поверх",
        teleports = "Телепорти",
        bossRooms = "Кімнати босів",
        bossFarm = "Фарм босів",
        materialFarm = "Фарм ресурсів",
        paths = "Шляхи",
        tools = "Інструменти",
        settings = "Налаштування",
        selectFloor = "Оберіть поверх:",
        unknownFloor = "Помилка: невідомий поверх",
        noBosses = "На цьому поверсі немає босів",
        bossesOfFloor = "Боси поверху %d (%s):",
        bossFarms = "Фарм босів:",
        noFarms = "Немає доступних фармів на цьому поверсі",
        matAndFish = "Фарм ресурсів і риби",
        autoOreSelect = "Оберіть руду для збору:",
        noOresFound = "Ресурси не знайдено на цьому поверсі.",
        startFarmBtn = "🟢 ЗАПУСТИТИ АВТО-ЗБІР",
        warnNoSelection = "⚠️ Оберіть хоча б один тип руди!",
        autoFish = "Авто-ловля риби (10 кожну хвилину)",
        freezeToggle = "Фріз гравця на місці",
        respawnToggle = "Відродження на місці смерті",
        playerListToggle = "Список гравців на сервері",
        safe1Toggle = "Екстрена Евакуація (Смерть, Блок, Hop)",
        blockAllToggle = "Масове Блокування Гравців",
        autoMobWalk = "Автофарм найближчих мобів",
        autoF = "Авто-натискач F",
        autoHeal = "Авто-лікування (Здоров'я < 70%)",
        languageLabel = "Мова інтерфейсу:",
        lang_ru = "Російська",
        lang_uk = "Українська",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Завантаження...",
        pathError = "❌ Помилка!",
        pathSuccess = "✅ Запущено!",
        noPathsForFloor = "Для цього поверху немає шляхів.",
        roomsAndLocs = "Кімнати та Локації: %s (%s)",
        noExtraLocs = "⚠️ Для цього поверху немає додаткових локацій.",
        youAreOnFloor = "Ви на поверсі: %s (ID: %d)",
        pathsTitle = "Шляхи (Авто-скрипти)",
        farmPrefix = "Фарм: ",
        forgeTitle = "🛠️ Кузня (Авто-крафт)",
        forgeSelect = "Обрати предмет",
        forgeRefresh = "Оновити",
        forgeFarmItem = "▶ ФАРМ ПРЕДМЕТА",
        forgeFarmIngots = "💎 ФАРМ СК (Тільки злитки)",
        forgeStop = "⏹ ЗУПИНИТИ",
        forgeMiniTitle = "🛠️ Керування кузнею",
        forgeWaiting = "Очікування...",
        forgeFinishing = "⏳ ЗАКІНЧУЮ...",
        forgeChangedTarget = "Змінив ціль: ",
        forgeWaitUI = "Чекаю предмет UI...",
        forgeOpenMenu = "Відкриваю меню (X)...",
        forgeStarting = "Запуск...",
        forgeMinigame = "Міні-гра...",
        forgeCloseSuccess = "Закриваю вікно успіху...",
        forgeResetUI = "Скидання UI...",
        forgeRetry = "Пробуємо знову...",
        forgeTakeOther = "Беру інше: ",
        forgeReady = "Готовий до крафту",
        forgeStartHint = "⚠️ Запуск фарму знаходиться в міні-панелі на екрані",
        forgeEmergencyStop = "Екстрена зупинка (Відкрито HUB)!",
        forgeStoppedTitle = "⚠️ КУЗНЮ ЗУПИНЕНО",
        forgeStoppedDesc = "Авто-кузню було вимкнено, щоб уникнути міскліків по Hub'у!",
        errorTitle = "⚠️ Помилка",
        forgeErrNoItem = "Спочатку обери предмет зі списку!",
        farmStopped = "Фарм зупинено",
        forgeErrNoIngots = "Доступні злитки закінчилися!",
        forgeErrNoMats = "Ресурси для предмета закінчилися!",
        forgeErrNoMatsFor = "Ресурси для %s закінчилися!",
        forgeItem = "Предмет: ",
        forgeNotSelected = "Не обрано",
        forgeStatusLbl = "Статус: ",
        forgeCycles = "Цикли: ",
        forgeErrors = "Помилки: "
    },
    en = {
        hubTitle = "Pidromania Hub: Sword Blox Online",
        byAuthor = "by @Pidromania",
        floor = "Floor",
        teleports = "Teleports",
        bossRooms = "Boss Rooms",
        bossFarm = "Boss Farm",
        materialFarm = "Material Farm",
        paths = "Paths",
        tools = "Tools",
        settings = "Settings",
        selectFloor = "Select floor:",
        unknownFloor = "Error: unknown floor",
        noBosses = "No bosses on this floor",
        bossesOfFloor = "Bosses of floor %d (%s):",
        bossFarms = "Boss Farms:",
        noFarms = "No available farms on this floor",
        matAndFish = "Material & Fish Farm",
        autoOreSelect = "Select ore to collect:",
        noOresFound = "No resources found on this floor.",
        startFarmBtn = "🟢 START AUTO-COLLECT",
        warnNoSelection = "⚠️ Select at least one ore type!",
        autoFish = "Auto-fish (10 every 1 minute)",
        freezeToggle = "Freeze player in place",
        respawnToggle = "Respawn at death location",
        playerListToggle = "Player list on server",
        safe1Toggle = "Emergency Evasion (Death, Block, Hop)",
        blockAllToggle = "Mass Player Auto-Block",
        autoMobWalk = "Auto-farm nearest mobs",
        autoF = "Auto Press F",
        autoHeal = "Auto Heal (Health < 70%)",
        languageLabel = "Interface language:",
        lang_ru = "Russian",
        lang_uk = "Ukrainian",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Loading...",
        pathError = "❌ Error!",
        pathSuccess = "✅ Started!",
        noPathsForFloor = "No paths for this floor.",
        roomsAndLocs = "Rooms & Locations: %s (%s)",
        noExtraLocs = "⚠️ No extra locations for this floor.",
        youAreOnFloor = "You are on floor: %s (ID: %d)",
        pathsTitle = "Paths (Scripts)",
        farmPrefix = "Farm: ",
        forgeTitle = "🛠️ Forge (Auto-craft)",
        forgeSelect = "Select item",
        forgeRefresh = "Refresh",
        forgeFarmItem = "▶ FARM ITEM",
        forgeFarmIngots = "💎 FARM INGOTS ONLY",
        forgeStop = "⏹ STOP",
        forgeMiniTitle = "🛠️ Forge Control",
        forgeWaiting = "Waiting...",
        forgeFinishing = "⏳ FINISHING...",
        forgeChangedTarget = "Changed target: ",
        forgeWaitUI = "Waiting for item UI...",
        forgeOpenMenu = "Opening menu (X)...",
        forgeStarting = "Starting...",
        forgeMinigame = "Mini-game...",
        forgeCloseSuccess = "Closing success window...",
        forgeResetUI = "Resetting UI...",
        forgeRetry = "Retrying...",
        forgeTakeOther = "Taking other: ",
        forgeReady = "Ready to craft",
        forgeStartHint = "⚠️ Farm start button is in the mini-panel on screen",
        forgeEmergencyStop = "Emergency stop (HUB Opened)!",
        forgeStoppedTitle = "⚠️ FORGE STOPPED",
        forgeStoppedDesc = "Auto-forge was disabled to prevent misclicks on the Hub!",
        errorTitle = "⚠️ Error",
        forgeErrNoItem = "Select an item from the list first!",
        farmStopped = "Farm stopped",
        forgeErrNoIngots = "No available ingots left!",
        forgeErrNoMats = "Resources for item ran out!",
        forgeErrNoMatsFor = "Resources for %s ran out!",
        forgeItem = "Item: ",
        forgeNotSelected = "Not selected",
        forgeStatusLbl = "Status: ",
        forgeCycles = "Cycles: ",
        forgeErrors = "Errors: "
    }
}
setmetatable(translations, {__index = function(t, k) return t.ru end})

local function T(key)
    return translations[currentLang] and translations[currentLang][key] or translations.ru[key] or ("???" .. key .. "???")
end

local isEvading = false 
local isFrozen = false
local freezeConnection = nil
local resurrectionActive = false
local resurrectionConnections = {}
local currentFarmMode = nil
local individualFreezeConnection = nil
local screenGuiMain = nil
local screenGui = nil
local indicator = nil
local playerListGui = nil
local playerListUpdateLoop = nil
local materialFarmActive = false
local fishFarmActive = false
local selectedMaterials = {}
local autoWalkActive = false
local safe1Active = false
local playerListActive = false
local autoFActive = false
local autoFCooldown = 8
local autoHealActive = false
local blockAllRunning = false

local forgeSelectedProduct = nil
local forgeActive = false
local forgeStopping = false
local forgeIngotsMode = false
local forgeMinigameEnabled = false
local forgeIsClicking = false
local forgeClickCount = 0
local forgeCycleCount = 0
local forgeErrorCount = 0
local forgeAutoFarmLoop = nil

local refForgeStatus = nil
local refForgeSelectBtn = nil
local miniForgeGui = nil
local miniForgeStatus = nil
local miniForgeFarmBtn = nil
local miniForgeIngotBtn = nil

local FOLDER_NAME = "PidromaniaHub"
local FILE_NAME = FOLDER_NAME .. "/SBOR_Config.json"

local function SaveConfig()
    if writefile and isfolder then
        if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
        local data = { 
            language = currentLang,
            safe1 = safe1Active,
            respawn = resurrectionActive,
            playerList = playerListActive,
            autoWalk = autoWalkActive,
            fishFarm = fishFarmActive,
            materialFarm = materialFarmActive,
            ores = selectedMaterials,
            farmMode = currentFarmMode,
            autoF = autoFActive,
            autoF_cd = autoFCooldown,
            autoHeal = autoHealActive,
            blockAll = blockAllRunning
        }
        pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(data)) end)
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(FILE_NAME))
            if data.language and translations[data.language] then currentLang = data.language end
            if type(data.safe1) == "boolean" then safe1Active = data.safe1 end
            if type(data.respawn) == "boolean" then resurrectionActive = data.respawn end
            if type(data.playerList) == "boolean" then playerListActive = data.playerList end
            if type(data.autoWalk) == "boolean" then autoWalkActive = data.autoWalk end
            if type(data.fishFarm) == "boolean" then fishFarmActive = data.fishFarm end
            if type(data.materialFarm) == "boolean" then materialFarmActive = data.materialFarm end
            if type(data.ores) == "table" then selectedMaterials = data.ores end
            if type(data.farmMode) == "string" then currentFarmMode = data.farmMode end
            if type(data.autoF) == "boolean" then autoFActive = data.autoF end
            if type(data.autoF_cd) == "number" then autoFCooldown = data.autoF_cd end
            if type(data.autoHeal) == "boolean" then autoHealActive = data.autoHeal end
            if type(data.blockAll) == "boolean" then blockAllRunning = data.blockAll end
        end)
    end
end

local FLOORS = {
    {1,  "Town Of Beginnings", 4733293382},
    {2,  "Swordsman Fields", 4734865416},
    {3,  "Swamp Lands", 4735703075},
    {4,  "Desert Land", 4735718710},
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

local BOSSES = {
    [4734865416] = {{"Shadesworn the Corrupted", 414, -1174, -461},{"Illfang The Kobold Lord", -1003, 1928, -727},{"Зайцы", 635.78, 665.00, -477.40}},
    [4735703075] = {{"Mob farm: in pit", -352.25, -15.14, 1049.83},{"Lord Slug", 988, 2500, 591}},
    [4735718710] = {{"Mob farm: in front of the boss", 1271.97, 1197.97, 12748.28},{"Stallord", 711, 1173, 12457}},
    [4736649014] = {{"Mob farm: in a cave", -2295.05, 386.89, -1851.63},{"X'rphan the White Wyrm", -1585, 404, -1702}},
    [4736759720] = {{"Uakmaroth, the Demon Lord", -1622, 1931, -426}},
    [4736984932] = {{"Storm Atronach", -5849, -368, 9330}},
    [4737916764] = {{"Skeleton Swamp", 326, 74, -1396},{"Bonnz the Skeleton Lord", 2998, -557, -1878}},
    [4740039076] = {{"Guardian of the Gate", -2665, 879, 9127},{"Karth'uk The Crystal Kraken", -2612, 32, 6763}},
    [4747247314] = {{"Hotoke The Enlightened", -3985, -9927, -7179}},
    [5135551944] = {{"Buffed Knight", -1619, 4, -5725},{"Grimlock the Fallen King", -9471, -471, 1962}},
    [5212666689] = {{"Laurellis Convict", 14968, 770, -705},{"Slime Lord Pengonis", -1826, 1111, -9793}},
    [5136611550] = {{"Tormented Spectrum", -94, 1404, 3187},{"The Tormented Soul", -79, 2267, -114}},
    [4733293091] = {{"Leader Grimm", 8128, 2685, 939},{"Super Luo", 2355, 1716, 2364},{"Elder Celatid", 1859, 1714, -2208},{"Young Celestia", -1407, -1462, 1203}},
    [11987483716] = {{"Raios, Sortiliena and Golgorosso", 458, 30, -1211}},
    [11987539001] = {{"Goblins", -584.36, 176.52, 3508.82},{"Goblins cave", -578.07, 178.99, 3519.20},{"Two-Headed Giant", 2742.92, 225.58, 7207.78}},
    [12632324801] = {{"Captain Sweet the Forever Child", 2940, -815, -1949}},
    [94066307314492] = {{"Mob Save Farm", -272.06, 7.42, 74.08},{"Thug Boss", -1493, 6, 8},{"Loan Shark Boss", -553.70, 1.49, -2088.94},{"The Custodian", -989.97, -1472.43, 6025.40},{"Eidolon the Gilded Omen", -352.27, 1043.52, 1549.13},{"The Arbitrator", -498.26, -1503.60, 5515.60}},
    [130463264320898] = {{"Новый Босс", -3501.16, 153.08, 3534.65},{"kvrst", -4313.40, 131.45, -888.28},{"sunstone", -4331.49, 144.00, 349.18},{"minik", -3224.66, 156.07, -1323.25},{"Пингвины", -2397.24, 156.93, 2185.15},{"Големы", 773.03, 112.48, 1246.18},{"Вендиго", 3546.91, -889.56, 7155.80},{"minik 2 location", 2150.95, -1181.13, 4616.98},{"главный босс", 3796.98, -942.65, 6422.02}}
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
        {"MobFarm 18.1", Vector3.new(-502.70, 30.68, -95.50)},
        {"MobFarm Loan Shark Henchman", Vector3.new(-459.56, 25.80, -2173.31)},
        {"MobFarm VIP Scout", Vector3.new(-452.86, 31.93, 1394.72)},
        {"MobFarm 1-st", Vector3.new(-653.05, -1314.71, 5011.60)},
        {"Thug Boss", Vector3.new(-1477.77, 34.66, -224.00)},
        {"Loan Shark Boss", Vector3.new(-543.19, 26.54, -2124.94)},
        {"Eidolon the Gilded Omen", Vector3.new(-159.32, 1045.93, 1695.05)},
        {"The Custodian", Vector3.new(-975.23, -1477.30, 5912.75)},
        {"The Arbitrator", Vector3.new(-578.84, -1477.90, 5316.49)}
    },
    [117852524597461] = {{"Frontman", Vector3.new(-38.32, 80.40, -285.61)}},
    [130463264320898] = {{"Oslund the Hollow Flame", Vector3.new(-3501.16, 153.08, 3534.65)},{"Frostveil Echo", Vector3.new(2275.98, -1175.30, 4579.98)},{"Ice Spirit", Vector3.new(3825.06, -942.65, 6400.30)},{"Владимир Красное Солнышко", Vector3.new(-3183.14, 155.03, -1271.63)},{"Мобфарм медведей", Vector3.new(2765.72, -473.67, 7026.55)},{"Мобфарм крылатых шлюшек", Vector3.new(2935.85, -473.72, 7003.91)},{"Мобофарм у вендиго", Vector3.new(3559.58, -889.56, 7149.98)}}
}

local EXTRA_LOCATIONS = {
    [4734865416] = {{"Город", 415.57, 107.68, -276.72},{"Шахта", -436.26, 128.35, 154.04},{"Комната босса", -540.97, 1917.21, -727.32},{"Комната Минибосса", 178.45, -1174.08, -487.87}},
    [4735703075] = {{"Яма", -341.45, 99.01, 997.13},{"Шахта", -6.24, 27.97, 945.08},{"Магазин", -969.56, 69.00, -895.28},{"Вход в башню", 282.07, -927.82, 838.67},{"Комната босса", 545.77, 2485.72, 591.24}},
    [4735718710] = {{"Шахта", 1339.27, 1826.08, -623.95},{"Вход в башню", 1118.11, 1133.63, 12498.01},{"Комната босса", 347.68, 1188.30, 12457.61}},
    [4736649014] = {{"Шахта", 768.75, 204.93, 687.25},{"Вход в башню", -2367.82, 407.96, -1542.97},{"Комната босса", -2219.23, 400.14, -1873.53}},
    [4736759720] = {{"Шахта", -961.40, 193.43, -1390.09},{"Вход в башню", -1343.48, 1132.88, 138.37},{"Комната босса", -1279.13, 1913.99, -426.48}},
    [4737916764] = {{"Вход в башню", 2687.15, -654.41, 470.80},{"Комната босса", 2783.20, -554.00, -1670.30}},
    [4740039076] = {{"Магазин", 1198.64, 951.67, -174.30},{"Вход в первую локацию", -2691.01, 1184.50, 13916.61},{"Вход в башню", 1236.04, 129.95, 11256.65},{"Комната босса", -2620.99, 32.80, 7070.26}},
    [4747247314] = {{"Шахта", -114.55, 20.66, 966.82},{"Вход в башню", -4000.10, -9989.45, -5859.08},{"Комната босса", -3987.15, -9930.00, -6714.68}},
    [5135551944] = {{"Крыша минибосса", -1674.17, 152.01, -5899.82},{"Вход в башню", -10204.24, -479.34, -491.57},{"Комната босса", -9471.52, -474.34, 1500.44}},
    [5212666689] = {{"Магазин в залупенске", -1618.68, 1359.33, 8325.41},{"Вход в башню", 2065.14, 260.02, -8207.31},{"Комната босса", -1193.62, 1092.96, -9792.50}},
    [4733293091] = {{"Яйцо босса", -1557.81, -1322.58, 1580.20}, {"Кузьня", 9593.29, 3651.69, 1862.28}},
    [11987539001] = {{"Деревня", -991.45, 239.96, -956.28},{"Гигас", -1434.15, 170.36, -2159.10}},
    [94066307314492] = {{"NPC Koshak", -715.74, 14.95, 49.26},{"Тхунг", -1445.02, 253.41, -133.76}},
    [130463264320898] = {{"Комната главного босса", 3940.89, -964.40, 6302.97},{"Ледяной замок", 1028.20, -1218.36, 4146.35},{"Маяк", -1629.58, 1016.57, 1514.95},{"Церковь", -5474.52, 192.08, -1537.69},{"Дом вендиго", -2998.23, -565.16, 9125.64},{"Ключ", 2559.68, 133.57, 592.29},{"Вход в пещеру с пингвинчиками", -2975.91, 353.49, 2394.02},{"Ты не порти мой рассказ", -2904.03, 419.96, 1640.88}}
}

local FLOOR_2_PATHS = {["Boss2"] = "Boss2", ["Miniboss"] = "Miniboss"}
local PATH_BASE_URL_2 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/2%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_3_PATHS = {["Башня"] = "Башня", ["Магазин"] = "Магазин"}
local PATH_BASE_URL_3 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/3%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_4_PATHS = {["Лабиринт"] = "Labirint", ["Шахта"] = "Shaxta"}
local PATH_BASE_URL_4 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/4%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_5_PATHS = {["Лабиринт"] = "Лабиринт"}
local PATH_BASE_URL_5 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/5%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_8_PATHS = {["Boss"] = "Boss"}
local PATH_BASE_URL_8 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/8%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_14_PATHS = {["BlueCristal"] = "BlueCristal", ["Boss1LeaderGrimm"] = "Boss1LeaderGrimm", ["RedCristal"] = "RedCristal"}
local PATH_BASE_URL_14 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/14%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_16_PATHS = {["LeaderGoblin"] = "LeaderGoblin", ["Two-HeadedGiant"] = "Two-HeadedGiant"}
local PATH_BASE_URL_16 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/16%20%D1%8D%D1%82%D0%B0%D0%B6/"
local FLOOR_19_PATHS = {["Frostveil Echo"] = "FrostveilEcho", ["Ice Spirit"] = "IceSpirit", ["Владимир К.С."] = "Vladimir", ["Дом вендиго"] = "WendigoHouse", ["Лабиринт вендиго"] = "WendigoMaze", ["Ледяной замок"] = "IceCastle", ["Маяк"] = "Lighthouse", ["Церковь"] = "Church"}
local PATH_BASE_URL_19 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/19%20%D1%8D%D1%82%D0%B0%D0%B6/"

local AUTO_WALK_CONFIG = { WalkSpeed = 30, NormalSpeed = 16, MaxDistance = 1500, AttackDistance = 13, WalkStopDistance = 3 }

local lockScreenGui = nil

local function setUILocked(isLocked, msg)
    if not lockScreenGui then
        lockScreenGui = Instance.new("ScreenGui")
        lockScreenGui.Name = "PidromaniaLockScreen"
        lockScreenGui.ResetOnSpawn = false
        lockScreenGui.DisplayOrder = 99999
        
        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        bg.BackgroundTransparency = 0.4
        bg.Active = true 
        bg.Parent = lockScreenGui
        
        local txt = Instance.new("TextLabel")
        txt.Name = "Msg"
        txt.Size = UDim2.new(1, 0, 0, 100)
        txt.Position = UDim2.new(0, 0, 0.4, -50)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(255, 80, 80)
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 26
        txt.Parent = bg
        
        local btn = Instance.new("TextButton")
        btn.Name = "EmergencyBtn"
        btn.Size = UDim2.new(0, 400, 0, 50)
        btn.Position = UDim2.new(0.5, -200, 0.6, 0)
        btn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = "ЭКСТРЕННОЕ ОТКЛЮЧЕНИЕ ЗАЩИТЫ"
        btn.Parent = bg
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            isEvading = false
            blockAllRunning = false
            safe1Active = false
            setUILocked(false)
        end)
    end
    
    if isLocked then
        lockScreenGui.Frame.Msg.Text = msg or "ВЫПОЛНЯЕТСЯ ОПЕРАЦИЯ..."
        lockScreenGui.Parent = player:WaitForChild("PlayerGui")
        
        if screenGuiMain then screenGuiMain.Enabled = false end
        if playerListGui then playerListGui.Enabled = false end
    else
        lockScreenGui.Parent = nil
        if screenGuiMain then screenGuiMain.Enabled = true end
        if playerListGui then playerListGui.Enabled = true end
    end
end

player.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
    pcall(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

local function minimizeHub()
    if screenGuiMain then
        local mFrame, minFrame
        for _, child in ipairs(screenGuiMain:GetChildren()) do
            if child.Name == "Frame" and child.Size.X.Offset == 1200 then
                mFrame = child
            elseif child.Name == "Frame" and child.Size.X.Offset == 150 then
                minFrame = child
            end
        end
        if mFrame and minFrame and mFrame.Visible then
            mFrame.Visible = false
            minFrame.Visible = true
        end
    end
end

local function ServerHop()
    local placeId = game.PlaceId
    spawn(function()
        while true do
            pcall(function() TeleportService:Teleport(placeId, player) end)
            task.wait(5)
        end
    end)
end

local blockedUsersCache = {}
local blockAllLoopRunning = false

local function startBlockAll()
    blockAllRunning = true
    if blockAllLoopRunning then return end
    blockAllLoopRunning = true
    
    task.spawn(function()
        while blockAllRunning do
            local playersToBlock = {}
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= player and not blockedUsersCache[target.UserId] and not isFriend(target) then
                    table.insert(playersToBlock, target)
                end
            end
            
            if #playersToBlock > 0 then
                setUILocked(true, "МАССОВАЯ БЛОКИРОВКА... ПОЖАЛУЙСТА ПОДОЖДИТЕ")
                for _, target in ipairs(playersToBlock) do
                    if not blockAllRunning then break end
                    local viewportSize = workspace.CurrentCamera.ViewportSize
                    local centerX = viewportSize.X / 2
                    local centerY = viewportSize.Y / 2
                    
                    pcall(function() game:GetService("StarterGui"):SetCore("PromptBlockPlayer", target) end)
                    task.wait(0.7)
                    if not blockAllRunning then break end

                    local confirmButtonX = centerX + (viewportSize.X * 0.05)
                    local confirmButtonY = centerY + (viewportSize.Y * 0.04)
                    
                    VIM:SendMouseButtonEvent(confirmButtonX, confirmButtonY, 0, true, game, 0)
                    task.wait(0.05)
                    VIM:SendMouseButtonEvent(confirmButtonX, confirmButtonY, 0, false, game, 0)
                    
                    blockedUsersCache[target.UserId] = true
                    task.wait(2.2 + math.random())
                end
                if blockAllRunning then setUILocked(false) end
            end
            task.wait(2)
        end
        setUILocked(false)
        blockAllLoopRunning = false
    end)
end

local function stopBlockAll() blockAllRunning = false end

local function triggerEvasion()
    if isEvading then return end
    isEvading = true
    setUILocked(true, "ЭКСТРЕННАЯ ЭВАКУАЦИЯ: БЛОКИРОВКА И ПРЫЖОК...")
    
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then char:BreakJoints() end
    end
    
    task.spawn(function()
        local playerList = Players:GetPlayers()
        for _, target in ipairs(playerList) do
            if target ~= player and not isFriend(target) then
                if not isEvading then break end
                local viewportSize = workspace.CurrentCamera.ViewportSize
                local centerX = viewportSize.X / 2
                local centerY = viewportSize.Y / 2
                
                pcall(function() game:GetService("StarterGui"):SetCore("PromptBlockPlayer", target) end)
                task.wait(0.7)
                if not isEvading then break end
                
                local confirmButtonX = centerX + (viewportSize.X * 0.05)
                local confirmButtonY = centerY + (viewportSize.Y * 0.04)
                
                VIM:SendMouseButtonEvent(confirmButtonX, confirmButtonY, 0, true, game, 0)
                task.wait(0.05)
                VIM:SendMouseButtonEvent(confirmButtonX, confirmButtonY, 0, false, game, 0)
                task.wait(1.5)
            end
        end
        if isEvading then ServerHop() end
    end)
end

local safe1LoopRunning = false
local function startSafe1()
    safe1Active = true
    if safe1LoopRunning then return end
    safe1LoopRunning = true
    task.spawn(function()
        while safe1Active do
            local dangerPlayers = 0
            for _, target in ipairs(Players:GetPlayers()) do
                if target ~= player and not isFriend(target) then dangerPlayers = dangerPlayers + 1 end
            end
            if dangerPlayers > 0 then triggerEvasion() break end
            task.wait(1)
        end
        safe1LoopRunning = false
    end)
end

local function stopSafe1() safe1Active = false end

local function teleport(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

local function spawnPlatform(pos)
    local platform = Instance.new("Part")
    platform.Name = "PidromaniaPlatform"
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = pos
    platform.Color = Color3.fromRGB(0, 170, 255)
    platform.Material = Enum.Material.SmoothPlastic
    platform.Anchored = true
    platform.CanCollide = true
    platform.Parent = Workspace
    return platform
end

local function freezePlayer()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local freezePos = hrp.CFrame
    if individualFreezeConnection then individualFreezeConnection:Disconnect() end
    
    individualFreezeConnection = RunService.RenderStepped:Connect(function()
        if hrp and hrp.Parent then hrp.CFrame = freezePos end
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
    indicator.Parent = screenGui
end

local function updateIndicator(isNear)
    if indicator then indicator.BackgroundColor3 = isNear and Color3.new(0, 1, 0) or Color3.new(1, 0, 0) end
end

local function findMobsFolder()
    local folder = Workspace:FindFirstChild("Mobs")
    if not folder then
        for _, child in ipairs(Workspace:GetDescendants()) do
            if child.Name == "Mobs" and child:IsA("Folder") then return child end
        end
    end
    return folder
end

local function getPlayerLevel(plr)
    local stats = plr:FindFirstChild("PlayerStats")
    if stats then
        local levelObj = stats:FindFirstChild("Level")
        if levelObj and (levelObj:IsA("IntValue") or levelObj:IsA("NumberValue")) then return levelObj.Value
        elseif levelObj and levelObj:IsA("StringValue") and tonumber(levelObj.Value) then return tonumber(levelObj.Value) end
    end
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local lvl = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("lvl") or leaderstats:FindFirstChild("level")
        if lvl and (lvl:IsA("IntValue") or lvl:IsA("NumberValue")) then return lvl.Value
        elseif lvl and lvl:IsA("StringValue") and tonumber(lvl.Value) then return tonumber(lvl.Value) end
    end
    local attr = plr:GetAttribute("Level")
    if type(attr) == "number" then return attr
    elseif type(attr) == "string" and tonumber(attr) then return tonumber(attr) end
    return "?"
end

local function createPlayerListGui()
    if playerListGui then return end
    playerListGui = Instance.new("ScreenGui")
    playerListGui.Name = "PidromaniaPlayerList"
    playerListGui.ResetOnSpawn = false
    playerListGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    playerListGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 280)
    frame.Position = UDim2.new(1, -330, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = playerListGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = T("playerListToggle")
    header.TextColor3 = Color3.fromRGB(180, 180, 220)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -42)
    scroll.Position = UDim2.new(0, 6, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.Parent = frame
    
    local function updateList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        local y = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local level = getPlayerLevel(plr)
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -8, 0, 24)
                lbl.Position = UDim2.new(0, 4, 0, y)
                lbl.BackgroundTransparency = 1
                lbl.Text = string.format("%s — [%s]", plr.Name, tostring(level))
                lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 16
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = scroll
                y = y + 28
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    updateList()
    playerListUpdateLoop = spawn(function()
        while playerListGui and playerListGui.Parent do
            task.wait(5)
            if playerListGui then updateList() end
        end
    end)
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)
end

local function destroyPlayerListGui()
    if playerListUpdateLoop then playerListUpdateLoop = nil end
    if playerListGui then playerListGui:Destroy() playerListGui = nil end
end

local function toggleFreeze()
    isFrozen = not isFrozen
    if isFrozen then
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local freezePosition = hrp.CFrame
                if freezeConnection then freezeConnection:Disconnect() end
                freezeConnection = RunService.RenderStepped:Connect(function()
                    if hrp and hrp.Parent then hrp.CFrame = freezePosition end
                end)
            else
                isFrozen = false
            end
        else
            isFrozen = false
        end
    else
        if freezeConnection then freezeConnection:Disconnect() freezeConnection = nil end
    end
end

local savedDeathPosition = nil
local function cleanupResurrection()
    for _, conn in ipairs(resurrectionConnections) do
        if conn and conn.Disconnect then conn:Disconnect() end
    end
    resurrectionConnections = {}
    savedDeathPosition = nil
end

local function setupResurrection()
    cleanupResurrection()
    resurrectionActive = true
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 10)
        local rootPart = character:WaitForChild("HumanoidRootPart", 10)
        if not humanoid or not rootPart then return end

        if savedDeathPosition then
            task.delay(0.5, function()
                local currentRoot = character:FindFirstChild("HumanoidRootPart")
                if currentRoot then currentRoot.CFrame = savedDeathPosition end
                savedDeathPosition = nil
            end)
        end

        local diedConn = humanoid.Died:Connect(function()
            if rootPart then savedDeathPosition = rootPart.CFrame end
        end)
        table.insert(resurrectionConnections, diedConn)
    end
    
    local charAddedConn = player.CharacterAdded:Connect(onCharacterAdded)
    table.insert(resurrectionConnections, charAddedConn)
    if player.Character then onCharacterAdded(player.Character) end
end

local autoFLoopRunning = false
local function startAutoF()
    autoFActive = true
    if autoFLoopRunning then return end
    autoFLoopRunning = true
    task.spawn(function()
        while autoFActive do
            if isEvading then task.wait(1) continue end
            if autoWalkActive then
                VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            end
            local baseCd = tonumber(autoFCooldown) or 8
            local randomAdd = math.random(0, 50) / 100
            task.wait(baseCd + randomAdd)
        end
        autoFLoopRunning = false
    end)
end
local function stopAutoF() autoFActive = false end

local autoHealLoopRunning = false
local function startAutoHeal()
    autoHealActive = true
    if autoHealLoopRunning then return end
    autoHealLoopRunning = true
    task.spawn(function()
        while autoHealActive do
            if isEvading then task.wait(1) continue end
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 and hum.MaxHealth > 0 then
                if (hum.Health / hum.MaxHealth) < 0.7 then
                    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game) task.wait(0.5)
                    VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) task.wait(0.2)
                    VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.R, false, game) task.wait(2.5) 
                    VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                    task.wait(35)
                end
            end
            task.wait(0.5)
        end
        autoHealLoopRunning = false
    end)
end
local function stopAutoHeal() autoHealActive = false end

local autoWalkLoopRunning = false
local function startAutoWalk()
    autoWalkActive = true
    if autoWalkLoopRunning then return end
    autoWalkLoopRunning = true
    task.spawn(function()
        while autoWalkActive do
            if isEvading then task.wait(1) continue end
            local char = player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoid.Health > 0 and hrp then
                local mobsFolder = findMobsFolder()
                if mobsFolder then
                    local nearestMob = nil
                    local nearestHorizontalDist = AUTO_WALK_CONFIG.MaxDistance
                    
                    for _, mob in ipairs(mobsFolder:GetChildren()) do
                        local targetPart = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                        local mobHum = mob:FindFirstChild("Humanoid")
                        
                        if targetPart and (not mobHum or mobHum.Health > 0) then
                            local delta = targetPart.Position - hrp.Position
                            local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                            local verticalDist = delta.Y 
                            
                            if verticalDist <= 25 and verticalDist >= -15 then
                                if horizontalDist < nearestHorizontalDist then
                                    nearestHorizontalDist = horizontalDist
                                    nearestMob = mob
                                end
                            end
                        end
                    end
                    
                    if nearestMob then
                        local targetPart = nearestMob:FindFirstChild("HumanoidRootPart") or nearestMob.PrimaryPart
                        if targetPart then
                            if nearestHorizontalDist > AUTO_WALK_CONFIG.AttackDistance then
                                humanoid:MoveTo(targetPart.Position)
                            else
                                hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(targetPart.Position.X, hrp.Position.Y, targetPart.Position.Z))
                                VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1) task.wait(0.05) VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                                
                                if nearestHorizontalDist > AUTO_WALK_CONFIG.WalkStopDistance then
                                    humanoid:MoveTo(targetPart.Position)
                                else
                                    humanoid:MoveTo(hrp.Position)
                                end
                                task.wait(math.random(850, 900) / 1000) 
                            end
                        end
                    end
                end
            end
            task.wait(0.1) 
        end
        autoWalkLoopRunning = false
    end)
end

local function stopAutoWalk()
    autoWalkActive = false
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        char.Humanoid:MoveTo(char.HumanoidRootPart.Position)
    end
end

player.CharacterAdded:Connect(function(character)
    if autoWalkActive and not isEvading then
        task.delay(2, function()
            if autoWalkActive and not isEvading and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                task.wait(0.1)
                VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            end
        end)
    end
end)

local function startGenericFarm(bossName, farmPos)
    currentFarmMode = bossName
    initGUI()
    updateIndicator(false)
    
    local isThugHop = (bossName == "Thug Boss (Server Hop)")
    local isFrontman = (bossName == "Frontman")
    local isCurrentlyVladimir = (bossName == "Владимир Красное Солнышко")
    local isCurrentlyFrostveil = (bossName == "Frostveil Echo")
    local isCurrentlyFloor8Mob = (bossName == "MobFarm" and game.PlaceId == 4737916764)
    local isFloor10 = (game.PlaceId == 4747247314)
    local isFloor11 = (game.PlaceId == 5135551944)
    local isFloor12Slime = (game.PlaceId == 5212666689 and bossName == "Slime Lord Pengonis")
    local isGoblins = (game.PlaceId == 11987539001 and bossName == "Goblins")
    local isFloor12MobFarm = (game.PlaceId == 5212666689 and bossName == "MobFarm")
    local isFloor13Soul = (game.PlaceId == 5136611550 and bossName == "The Tormented Soul")
    local isFloor13Spectrum = (game.PlaceId == 5136611550 and bossName == "Tormented Spectrum")
    
    local platform = nil
    local activePlatformPos = nil
    
    if isThugHop then
        spawn(function()
            task.wait(3)
            if currentFarmMode ~= bossName or isEvading then return end
            
            local platformPos = Vector3.new(-1490.44, -9, -183.62)
            platform = spawnPlatform(platformPos)
            task.wait(1)
            if currentFarmMode ~= bossName or isEvading then return end
            
            local playerPos = platformPos + Vector3.new(0, 2, 0)
            teleport(playerPos)
            task.wait(3)
            if currentFarmMode ~= bossName or isEvading then return end
            
            freezePlayer()
            VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
            
            local hasSeenBoss = false
            local nextFPress = 0 
            
            local clickLoopActive = true
            spawn(function()
                while clickLoopActive and currentFarmMode == bossName do
                    if isEvading then task.wait(1) continue end
                    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1) task.wait(0.05) VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                    task.wait(0.55)
                end
            end)
            
            while currentFarmMode == bossName do
                if isEvading then task.wait(1) continue end
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then break end
                
                if os.time() >= nextFPress then
                    VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
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
                                    torso.CFrame = hrp.CFrame * CFrame.new(0, 0, -6)
                                end
                            end
                        end
                    end
                end
                updateIndicator(bossFoundThisTick)
                if not bossFoundThisTick and hasSeenBoss then
                    currentFarmMode = nil clickLoopActive = false unfreezePlayer()
                    if platform then platform:Destroy() end
                    ServerHop() return
                end
                task.wait(0.1)
            end
            clickLoopActive = false
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
            local rock = game.Workspace:FindFirstChild("PlayerBarriers")
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
    
    spawn(function()
        if isFloor10 or isFloor11 then task.wait(2) else task.wait(1) end
        if not isEvading then freezePlayer() end
        
        if isGoblins and not isEvading then
            task.wait(0.5) 
            VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game) task.wait(0.1) VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
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
        
        while currentFarmMode == bossName do
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
                                else
                                    local targetPos = hrp.Position + hrp.CFrame.LookVector * 5
                                    torso.CFrame = CFrame.fromMatrix(targetPos, hrp.CFrame.RightVector, hrp.CFrame.UpVector, hrp.CFrame.LookVector)
                                end
                                if not (isFloor14 or isFloor18 or isCurrentlyFrontman or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or customPosCondition) then
                                    break
                                end
                            end
                        end
                    end
                end
            end
            updateIndicator(foundAny)
            if isFloor14 or isFloor18 or isCurrentlyFrontman or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or customPosCondition or isGoblins then
                task.wait(3)
            else
                task.wait(0.1)
            end
        end
        unfreezePlayer()
        if platform then platform:Destroy() end
        updateIndicator(false)
    end)
end

local function stopAllFarms()
    currentFarmMode = nil
    unfreezePlayer()
    if indicator then updateIndicator(false) end
end

local materialLoopRunning = false
local function startMaterialFarm()
    materialFarmActive = true
    if materialLoopRunning then return end
    local anySelected = false
    for _, state in pairs(selectedMaterials) do
        if state then anySelected = true break end
    end
    if not anySelected then return end
    materialLoopRunning = true
    spawn(function()
        while materialFarmActive do
            if not isEvading then
                pcall(function()
                    local RepStor = game:GetService("ReplicatedStorage")
                    local MaterialsFolder = workspace:FindFirstChild("Materials")
                    if MaterialsFolder and RepStor:FindFirstChild("ClaimMaterial") then
                        for _, material in ipairs(MaterialsFolder:GetChildren()) do
                            if material:IsA("Model") and material:FindFirstChild("Owner") and material:FindFirstChild("Id") then
                                local matName = material.Name
                                if selectedMaterials[matName] then
                                    if material.Owner.Value == "" then
                                        RepStor.ClaimMaterial:InvokeServer(material.Id.Value)
                                        task.wait(0.5)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
            task.wait(7)
        end
        materialLoopRunning = false
    end)
end
local function stopMaterialFarm() materialFarmActive = false end

local fishLoopRunning = false
local function startFishFarm()
    fishFarmActive = true
    if fishLoopRunning then return end
    fishLoopRunning = true
    spawn(function()
        while fishFarmActive do
            if not isEvading then
                pcall(function()
                    local RepStor = game:GetService("ReplicatedStorage")
                    if RepStor:FindFirstChild("CatchFish") then RepStor.CatchFish:FireServer(10) end
                end)
            end
            task.wait(60)
        end
        fishLoopRunning = false
    end)
end
local function stopFishFarm() fishFarmActive = false end

local function notify(title, text)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 3}) end)
end

local function updateForgeUI(statusText, color)
    local selText = forgeSelectedProduct and T("forgeItem") .. forgeSelectedProduct or T("forgeItem") .. T("forgeNotSelected")
    local stats = string.format(" | " .. T("forgeCycles") .. "%d | " .. T("forgeErrors") .. "%d", forgeCycleCount, forgeErrorCount)
    local finalStatus = T("forgeStatusLbl") .. (statusText or T("forgeWaiting")) .. stats

    if refForgeStatus then
        refForgeStatus.Text = selText .. "\n" .. finalStatus
        refForgeStatus.TextColor3 = color or Color3.fromRGB(100, 200, 255)
    end

    if miniForgeStatus then
        miniForgeStatus.Text = selText .. "\n" .. finalStatus
        miniForgeStatus.TextColor3 = color or Color3.fromRGB(100, 200, 255)
    end

    if miniForgeFarmBtn then
        if forgeStopping then
            miniForgeFarmBtn.Text = T("forgeFinishing")
            miniForgeFarmBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
        elseif forgeActive and not forgeIngotsMode then
            miniForgeFarmBtn.Text = T("forgeStop")
            miniForgeFarmBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        else
            miniForgeFarmBtn.Text = T("forgeFarmItem")
            miniForgeFarmBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        end
    end
    if miniForgeIngotBtn then
        if forgeStopping then
            miniForgeIngotBtn.Text = T("forgeFinishing")
            miniForgeIngotBtn.BackgroundColor3 = Color3.fromRGB(200, 120, 0)
        elseif forgeActive and forgeIngotsMode then
            miniForgeIngotBtn.Text = T("forgeStop") .. " СК"
            miniForgeIngotBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        else
            miniForgeIngotBtn.Text = T("forgeFarmIngots")
            miniForgeIngotBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
        end
    end
end

local function clickGUI(obj)
    if not obj or not obj:IsA("GuiObject") or not obj.Visible then return false end
    local x = obj.AbsolutePosition.X + obj.AbsoluteSize.X / 2
    local y = obj.AbsolutePosition.Y + obj.AbsoluteSize.Y / 2 + 58
    if obj:IsA("TextButton") or obj:IsA("ImageButton") then
        pcall(function() firesignal(obj.MouseButton1Click) end)
        pcall(function() firesignal(obj.Activated) end)
    end
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
    return true
end

local function pressX()
    VIM:SendKeyEvent(true, Enum.KeyCode.X, false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, Enum.KeyCode.X, false, game)
end

local function getForgeElement(type, name)
    local playerGuiLocal = player:FindFirstChild("PlayerGui")
    if not playerGuiLocal then return nil end
    local gg = playerGuiLocal:FindFirstChild("GameGui")
    if not gg then return nil end
    local cr = gg:FindFirstChild("Crafting")
    if not cr then return nil end
    if type == "Product" then return cr:FindFirstChild("Products") and cr.Products:FindFirstChild(name)
    elseif type == "CraftBtn" then return cr:FindFirstChild("Craft")
    elseif type == "CloseBtn" then return cr:FindFirstChild("Close") end
    return nil
end

local function clickSuccessExit()
    local playerGuiLocal = player:FindFirstChild("PlayerGui")
    if not playerGuiLocal then return false end
    local cg = playerGuiLocal:FindFirstChild("CraftingGame")
    if not cg then return false end
    local main = cg:FindFirstChild("Main")
    if not main then return false end
    local successUi = main:FindFirstChild("Success")
    if successUi and successUi.Visible then
        local exitBtn = successUi:FindFirstChild("Exit")
        if exitBtn then clickGUI(exitBtn) return true end
    end
    return false
end

local function getAvailableProducts(filter)
    local playerGuiLocal = player:FindFirstChild("PlayerGui")
    if not playerGuiLocal then return {} end
    local gameGui = playerGuiLocal:FindFirstChild("GameGui")
    if not gameGui then return {} end
    local crafting = gameGui:FindFirstChild("Crafting")
    if not crafting then return {} end
    local products = crafting:FindFirstChild("Products")
    if not products then return {} end

    local available = {}
    for _, btn in ipairs(products:GetChildren()) do
        if btn:IsA("TextButton") and btn.Name ~= "Template" then
            if btn.BackgroundTransparency < 0.5 then
                if not filter or filter == "" or string.find(string.lower(btn.Name), string.lower(filter)) then
                    table.insert(available, btn.Name)
                end
            end
        end
    end
    table.sort(available)
    return available
end

local function getMiniGameUI()
    local playerGuiLocal = player:FindFirstChild("PlayerGui")
    if not playerGuiLocal then return nil end
    local cg = playerGuiLocal:FindFirstChild("CraftingGame")
    if not cg then return nil end
    local main = cg:FindFirstChild("Main")
    if not main or not main.Visible then return nil end
    local area = main:FindFirstChild("ClickArea")
    local mover = main:FindFirstChild("Mover")
    if not area or not mover or area.AbsoluteSize.X == 0 then return nil end
    local strike = main:FindFirstChild("Strike") or main:FindFirstChild("StrikeButton") or main:FindFirstChildOfClass("TextButton")
    return { area = area, mover = mover, strike = strike }
end

local function requestForgeStop()
    if not forgeActive then return end
    forgeStopping = true
    forgeMinigameEnabled = false
    updateForgeUI(T("forgeFinishing"), Color3.fromRGB(200, 120, 0))
end

local function stopForgeAutoFarm()
    forgeActive = false
    forgeStopping = false
    forgeIngotsMode = false
    forgeMinigameEnabled = false
    updateForgeUI(T("farmStopped"), Color3.fromRGB(255, 100, 100))
    if forgeAutoFarmLoop and coroutine.running() ~= forgeAutoFarmLoop then
        pcall(function() task.cancel(forgeAutoFarmLoop) end)
    end
end

local function safeWait(seconds)
    local waited = 0
    while waited < seconds do
        task.wait(0.2)
        waited = waited + 0.2
        if forgeStopping then return false end
    end
    return true
end

local function startForgeAutoFarm(isIngotMode)
    if forgeActive then requestForgeStop() return end
    if not isIngotMode and not forgeSelectedProduct then
        notify(T("errorTitle"), T("forgeErrNoItem"))
        return
    end

    minimizeHub() 

    forgeActive = true
    forgeStopping = false
    forgeIngotsMode = isIngotMode
    forgeCycleCount = 0
    forgeErrorCount = 0
    updateForgeUI(T("forgeStarting"), Color3.fromRGB(0, 255, 0))
    
    forgeAutoFarmLoop = task.spawn(function()
        while forgeActive do
            if forgeStopping then stopForgeAutoFarm() break end
            local availableItems = getAvailableProducts(forgeIngotsMode and "ingot" or "")
            local isCurrentAvailable = false
            for _, v in ipairs(availableItems) do
                if v == forgeSelectedProduct then isCurrentAvailable = true break end
            end

            if not isCurrentAvailable then
                if forgeIngotsMode then
                    if #availableItems > 0 then
                        forgeSelectedProduct = availableItems[1]
                        updateForgeUI(T("forgeChangedTarget") .. forgeSelectedProduct, Color3.fromRGB(255, 150, 0))
                        if refForgeSelectBtn then refForgeSelectBtn.Text = "[[" .. forgeSelectedProduct .. "]]" end
                    else
                        notify(T("farmStopped"), T("forgeErrNoIngots"))
                        stopForgeAutoFarm()
                        break
                    end
                else
                    notify(T("farmStopped"), T("forgeErrNoMats"))
                    stopForgeAutoFarm()
                    break
                end
            end
            
            updateForgeUI(T("forgeWaitUI"), Color3.fromRGB(255, 200, 0))
            local waitTimer = 0
            while forgeActive and not forgeStopping do
                local prodBtn = getForgeElement("Product", forgeSelectedProduct)
                if prodBtn and prodBtn.BackgroundTransparency < 0.5 then break end
                task.wait(0.5)
                waitTimer = waitTimer + 0.5
                if waitTimer >= 3 then
                    updateForgeUI(T("forgeOpenMenu"), Color3.fromRGB(200, 200, 200))
                    pressX()
                    waitTimer = 0
                    if not safeWait(1.5) then break end
                end
            end

            if forgeStopping or not forgeActive then stopForgeAutoFarm() break end

            local prodBtn = getForgeElement("Product", forgeSelectedProduct)
            local craftBtn = getForgeElement("CraftBtn")
            
            if prodBtn and craftBtn then
                clickGUI(prodBtn)
                if not safeWait(0.5) then stopForgeAutoFarm() break end
                clickGUI(craftBtn)
                if not safeWait(1.5) then stopForgeAutoFarm() break end
                
                if getMiniGameUI() then
                    forgeMinigameEnabled = true
                    forgeClickCount = 0
                    forgeErrorCount = 0
                    updateForgeUI(T("forgeMinigame"), Color3.fromRGB(0, 200, 255))
                    
                    local farmTime = 0
                    while forgeMinigameEnabled and forgeActive and not forgeStopping do
                        task.wait(0.1)
                        farmTime = farmTime + 0.1
                        if farmTime > 15 then forgeMinigameEnabled = false break end
                    end
                    
                    if not forgeStopping then
                        forgeCycleCount = forgeCycleCount + 1
                        updateForgeUI(T("forgeCloseSuccess"), Color3.fromRGB(0, 255, 0))
                        local exitTimer = 0
                        while exitTimer < 5 and not forgeStopping do
                            if clickSuccessExit() then break end
                            task.wait(0.2)
                            exitTimer = exitTimer + 0.2
                        end
                        if not safeWait(0.5) then stopForgeAutoFarm() break end
                    end
                else
                    forgeErrorCount = forgeErrorCount + 1
                    updateForgeUI(T("forgeResetUI"), Color3.fromRGB(255, 100, 0))
                    local closeBtn = getForgeElement("CloseBtn")
                    if closeBtn then clickGUI(closeBtn) end
                    if not safeWait(2) then stopForgeAutoFarm() break end
                    pressX()
                    
                    if not forgeIngotsMode then
                        if not safeWait(1) then stopForgeAutoFarm() break end
                        local canCraft = false
                        for _, v in ipairs(getAvailableProducts()) do
                            if v == forgeSelectedProduct then canCraft = true break end
                        end
                        if canCraft then
                            updateForgeUI(T("forgeRetry"), Color3.fromRGB(200, 150, 255))
                        else
                            notify(T("farmStopped"), string.format(T("forgeErrNoMatsFor"), forgeSelectedProduct))
                            stopForgeAutoFarm()
                            break
                        end
                    else
                        if not safeWait(2) then stopForgeAutoFarm() break end
                        local foundNew = false
                        for _, v in ipairs(getAvailableProducts("ingot")) do
                            if v ~= forgeSelectedProduct then
                                forgeSelectedProduct = v
                                foundNew = true
                                updateForgeUI(T("forgeTakeOther") .. forgeSelectedProduct, Color3.fromRGB(200, 150, 255))
                                if refForgeSelectBtn then refForgeSelectBtn.Text = "[[" .. forgeSelectedProduct .. "]]" end
                                break
                            end
                        end
                        if not foundNew then
                            notify(T("farmStopped"), T("forgeErrNoIngots"))
                            stopForgeAutoFarm()
                            break
                        end
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

local function createMiniForgeUI()
    if miniForgeGui then return end
    
    miniForgeGui = Instance.new("ScreenGui")
    miniForgeGui.Name = "PidromaniaMiniForge"
    miniForgeGui.ResetOnSpawn = false
    miniForgeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    miniForgeGui.Enabled = (forgeSelectedProduct ~= nil) 
    miniForgeGui.Parent = player:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 260, 0, 130)
    frame.Position = UDim2.new(1, -280, 0, 320)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true 
    frame.Parent = miniForgeGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 25)
    header.BackgroundTransparency = 1
    header.Text = T("forgeMiniTitle")
    header.TextColor3 = Color3.fromRGB(255, 200, 100)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 14
    header.Parent = frame
    
    miniForgeStatus = Instance.new("TextLabel")
    miniForgeStatus.Size = UDim2.new(1, -10, 0, 35)
    miniForgeStatus.Position = UDim2.new(0, 5, 0, 25)
    miniForgeStatus.BackgroundTransparency = 1
    miniForgeStatus.Text = T("forgeWaiting")
    miniForgeStatus.TextColor3 = Color3.fromRGB(100, 200, 255)
    miniForgeStatus.Font = Enum.Font.Gotham
    miniForgeStatus.TextSize = 12
    miniForgeStatus.TextWrapped = true
    miniForgeStatus.Parent = frame

    miniForgeFarmBtn = Instance.new("TextButton")
    miniForgeFarmBtn.Size = UDim2.new(1, -10, 0, 30)
    miniForgeFarmBtn.Position = UDim2.new(0, 5, 0, 60)
    miniForgeFarmBtn.Font = Enum.Font.GothamBold
    miniForgeFarmBtn.TextSize = 14
    miniForgeFarmBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", miniForgeFarmBtn).CornerRadius = UDim.new(0, 6)
    miniForgeFarmBtn.Parent = frame

    miniForgeIngotBtn = Instance.new("TextButton")
    miniForgeIngotBtn.Size = UDim2.new(1, -10, 0, 30)
    miniForgeIngotBtn.Position = UDim2.new(0, 5, 0, 95)
    miniForgeIngotBtn.Font = Enum.Font.GothamBold
    miniForgeIngotBtn.TextSize = 14
    miniForgeIngotBtn.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", miniForgeIngotBtn).CornerRadius = UDim.new(0, 6)
    miniForgeIngotBtn.Parent = frame

    miniForgeFarmBtn.MouseButton1Click:Connect(function()
        if forgeActive and not forgeIngotsMode then requestForgeStop() else startForgeAutoFarm(false) end
    end)
    
    miniForgeIngotBtn.MouseButton1Click:Connect(function()
        if forgeActive and forgeIngotsMode then requestForgeStop() else startForgeAutoFarm(true) end
    end)
    
    updateForgeUI()
end

RunService.Heartbeat:Connect(function()
    if not forgeMinigameEnabled or forgeIsClicking or forgeStopping then return end
    local ui = getMiniGameUI()
    if not ui then forgeMinigameEnabled = false return end
    
    local areaLeft = ui.area.AbsolutePosition.X
    local areaRight = areaLeft + ui.area.AbsoluteSize.X
    local moverCenter = ui.mover.AbsolutePosition.X + (ui.mover.AbsoluteSize.X / 2)
    
    if moverCenter >= areaLeft and moverCenter <= areaRight then
        forgeIsClicking = true
        forgeClickCount = forgeClickCount + 1
        
        local target = ui.strike or ui.area
        local x = target.AbsolutePosition.X + target.AbsoluteSize.X / 2
        local y = target.AbsolutePosition.Y + target.AbsoluteSize.Y / 2 + 58
        
        if ui.strike and ui.strike:IsA("TextButton") then
            pcall(function() firesignal(ui.strike.MouseButton1Click) end)
        end
        
        VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
        
        if forgeClickCount >= 2 then
            task.wait(0.3)
            forgeMinigameEnabled = false
            forgeIsClicking = false
            forgeClickCount = 0
        else
            task.wait(0.3)
            forgeIsClicking = false
        end
    end
end)

LoadConfig()
createMiniForgeUI()

local hasStrangers = false
if safe1Active then
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= player and not isFriend(target) then hasStrangers = true break end
    end
end

if safe1Active and hasStrangers then
    triggerEvasion() 
else
    if safe1Active then startSafe1() end
    if resurrectionActive then setupResurrection() end
    if autoWalkActive then startAutoWalk() end
    if materialFarmActive then startMaterialFarm() end
    if fishFarmActive then startFishFarm() end
    if playerListActive then createPlayerListGui() end
    if autoFActive then startAutoF() end
    if autoHealActive then startAutoHeal() end
    if blockAllRunning then startBlockAll() end

    if currentFarmMode then
        local farms = BOSS_FARMS[game.PlaceId]
        if farms then
            for _, farmData in ipairs(farms) do
                if farmData[1] == currentFarmMode then
                    startGenericFarm(currentFarmMode, farmData[2])
                    task.delay(4, function()
                        if not isEvading then
                            VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                            task.wait(0.1)
                            VIM:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
                            
                            if not autoWalkActive then
                                autoWalkActive = true
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
end

local function createToggleSwitch(parent, label, initialEnabled, onToggle)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(1, -15, 0, 45)
    switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 9)
    corner.Parent = switchFrame
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0, 270, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(240, 240, 255)
    labelText.Font = Enum.Font.GothamSemibold
    labelText.TextSize = 21
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Position = UDim2.new(0, 7.5, 0, 0)
    labelText.Parent = switchFrame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -67.5, 0.5, -15)
    toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = switchFrame
    
    local cornerBg = Instance.new("UICorner")
    cornerBg.CornerRadius = UDim.new(0, 15)
    cornerBg.Parent = toggleBg
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 24, 0, 24)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    
    local cornerKnob = Instance.new("UICorner")
    cornerKnob.CornerRadius = UDim.new(0, 12)
    cornerKnob.Parent = toggleKnob
    
    local isEnabled = initialEnabled
    
    local function updateToggle()
        if isEnabled then
            toggleBg.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleKnob.Position = UDim2.new(1, -27, 0.5, -12)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            toggleKnob.Position = UDim2.new(0, 3, 0.5, -12)
        end
    end
    updateToggle()
    
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isEnabled = not isEnabled
            onToggle(isEnabled)
            updateToggle()
            SaveConfig()
        end
    end)
    
    return switchFrame, function(state) isEnabled = state updateToggle() end
end

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
    mainFrame.Size = UDim2.new(0, 1200, 0, 750)
    mainFrame.Position = UDim2.new(0.5, -600, 0.5, -375)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGuiMain
    
    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 15)
    mainFrameCorner.Parent = mainFrame
    
    local dragDetector = Instance.new("Frame")
    dragDetector.Size = UDim2.new(1, -75, 1, 0)
    dragDetector.Position = UDim2.new(0, 0, 0, 0)
    dragDetector.BackgroundTransparency = 1
    dragDetector.Parent = mainFrame
    
    local minimizedFrame = Instance.new("Frame")
    minimizedFrame.Size = UDim2.new(0, 150, 0, 45)
    minimizedFrame.Position = UDim2.new(0, 10, 0, 10)
    minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    minimizedFrame.BorderSizePixel = 0
    minimizedFrame.Visible = false
    minimizedFrame.Active = true
    minimizedFrame.Draggable = true
    minimizedFrame.Parent = screenGuiMain
    
    local cornerMinimized = Instance.new("UICorner")
    cornerMinimized.CornerRadius = UDim.new(0, 9)
    cornerMinimized.Parent = minimizedFrame
    
    local minimizedLabel = Instance.new("TextLabel")
    minimizedLabel.Text = T("hubTitle")
    minimizedLabel.Size = UDim2.new(1, 0, 1, 0)
    minimizedLabel.BackgroundTransparency = 1
    minimizedLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    minimizedLabel.Font = Enum.Font.GothamBold
    minimizedLabel.TextSize = 18
    minimizedLabel.Parent = minimizedFrame
    
    minimizedFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainFrame.Visible = true
            minimizedFrame.Visible = false
        end
    end)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 52.5)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local cornerHeader = Instance.new("UICorner")
    cornerHeader.CornerRadius = UDim.new(0, 9)
    cornerHeader.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Text = T("hubTitle")
    title.TextScaled = false
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    local textSize = TextService:GetTextSize(title.Text, title.TextSize, title.Font, Vector2.new(math.huge, math.huge))
    title.Size = UDim2.new(0, textSize.X * 1.1, 0, 30)
    title.Position = UDim2.new(0, 5, 0, 10.5)
    title.Parent = header
    
    local author = Instance.new("TextLabel")
    author.Text = T("byAuthor")
    author.TextScaled = false
    author.Font = Enum.Font.GothamSemibold
    author.TextSize = 18
    author.BackgroundTransparency = 1
    author.TextColor3 = Color3.fromRGB(150, 150, 180)
    local authorTextSize = TextService:GetTextSize(author.Text, author.TextSize, author.Font, Vector2.new(math.huge, math.huge))
    author.Size = UDim2.new(0, authorTextSize.X * 1.1, 0, 30)
    local offset = -15
    author.Position = UDim2.new(0, title.Position.X.Offset + title.Size.X.Offset + offset, 0, 10.5)
    author.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "--"
    minimizeBtn.Size = UDim2.new(0, 37.5, 0, 37.5)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 7.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 21
    minimizeBtn.Parent = header
    
    minimizeBtn.MouseButton1Click:Connect(function()
        minimizeHub()
    end)
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 300, 1, -52.5)
    leftPanel.Position = UDim2.new(0, 0, 0, 52.5)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainFrame
    
    local cornerLeft = Instance.new("UICorner")
    cornerLeft.CornerRadius = UDim.new(0, 12)
    cornerLeft.Parent = leftPanel
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -315, 1, -52.5)
    rightPanel.Position = UDim2.new(0, 315, 0, 52.5)
    rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainFrame
    
    local cornerRight = Instance.new("UICorner")
    cornerRight.CornerRadius = UDim.new(0, 12)
    cornerRight.Parent = rightPanel
    
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -15, 1, -15)
    contentContainer.Position = UDim2.new(0, 7.5, 0, 7.5)
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.ScrollBarThickness = 6
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = rightPanel
    
    local cornerContent = Instance.new("UICorner")
    cornerContent.CornerRadius = UDim.new(0, 9)
    cornerContent.Parent = contentContainer
    
    local menuItems = {}
    local function createMenuItem(name, icon)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Text = "  " .. (icon or "") .. "  " .. name
        btn.Size = UDim2.new(1, -15, 0, 52.5)
        btn.Position = UDim2.new(0, 7.5, 0, (#menuItems * 57) + 7.5)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 21
        btn.AutoButtonColor = true
        btn.Parent = leftPanel
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
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
    
    local function showFloors()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("selectFloor")
        title.Size = UDim2.new(1, 0, 0, 37.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.Parent = contentContainer
        
        for i, data in ipairs(FLOORS) do
            local floorNum, name, placeId = unpack(data)
            local btn = Instance.new("TextButton")
            btn.Name = "Floor" .. floorNum
            btn.Text = string.format("Floor %d — %s", floorNum, name)
            btn.Size = UDim2.new(1, -15, 0, 45)
            btn.Position = UDim2.new(0, 7.5, 0, 45 + (i - 1) * 52.5)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 21
            btn.AutoButtonColor = true
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 9)
            corner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                pcall(function() TeleportService:Teleport(placeId, player) end)
            end)
            btn.Parent = contentContainer
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, #FLOORS * 52.5 + 60)
    end
    
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
            title.Text = T("unknownFloor")
            title.Size = UDim2.new(1, 0, 0, 37.5)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 21
            title.Parent = contentContainer
            return
        end
        
        local bosses = BOSSES[currentPlaceId]
        if not bosses or #bosses == 0 then
            local title = Instance.new("TextLabel")
            title.Text = T("noBosses")
            title.Size = UDim2.new(1, 0, 0, 37.5)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(200, 200, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 21
            title.Parent = contentContainer
            return
        end
        
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Text = string.format(T("bossesOfFloor"), currentFloor[1], currentFloor[2])
        headerLabel.Size = UDim2.new(1, 0, 0, 37.5)
        headerLabel.BackgroundTransparency = 1
        headerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextSize = 21
        headerLabel.Parent = contentContainer
        
        for i, boss in ipairs(bosses) do
            local name, x, y, z = unpack(boss)
            local btn = Instance.new("TextButton")
            btn.Name = "Boss" .. i
            btn.Text = name
            btn.Size = UDim2.new(1, -15, 0, 45)
            btn.Position = UDim2.new(0, 7.5, 0, 45 + (i - 1) * 52.5)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 21
            btn.AutoButtonColor = true
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 9)
            corner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                if player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(x, y, z) end
                end
            end)
            btn.Parent = contentContainer
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, #bosses * 52.5 + 60)
    end
    
    local function showBossRooms()
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
            title.Text = T("unknownFloor")
            title.Size = UDim2.new(1, 0, 0, 37.5)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 21
            title.Parent = contentContainer
            return
        end
        
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Text = string.format(T("roomsAndLocs"), currentFloor[1], currentFloor[2])
        headerLabel.Size = UDim2.new(1, 0, 0, 37.5)
        headerLabel.BackgroundTransparency = 1
        headerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextSize = 21
        headerLabel.Parent = contentContainer
        
        local extraLocations = EXTRA_LOCATIONS[currentPlaceId] or {}
        local yOffset = 45
        
        if #extraLocations == 0 then
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = T("noExtraLocs")
            infoLabel.Size = UDim2.new(1, 0, 0, 30)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 18
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Position = UDim2.new(0, 7.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 37.5
        else
            for i, locData in ipairs(extraLocations) do
                local name, x, y, z = unpack(locData)
                local btn = Instance.new("TextButton")
                btn.Name = "Loc" .. i
                btn.Text = name
                btn.Size = UDim2.new(1, -15, 0, 45)
                btn.Position = UDim2.new(0, 7.5, 0, yOffset)
                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                btn.TextColor3 = Color3.fromRGB(240, 240, 255)
                btn.Font = Enum.Font.GothamSemibold
                btn.TextSize = 21
                btn.AutoButtonColor = true
                
                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 9)
                corner.Parent = btn
                
                btn.MouseButton1Click:Connect(function()
                    if player.Character then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame = CFrame.new(x, y, z) end
                    end
                end)
                btn.Parent = contentContainer
                yOffset = yOffset + 52.5
            end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    end
    
    local function showBossFarms()
        clearContent()
        local currentPlaceId = game.PlaceId
        local farms = BOSS_FARMS[currentPlaceId]
        
        local title = Instance.new("TextLabel")
        title.Text = T("bossFarms")
        title.Size = UDim2.new(1, 0, 0, 37.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.Parent = contentContainer
        
        if not farms or #farms == 0 then
            local noBossLabel = Instance.new("TextLabel")
            noBossLabel.Text = T("noFarms")
            noBossLabel.Size = UDim2.new(1, 0, 0, 37.5)
            noBossLabel.BackgroundTransparency = 1
            noBossLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
            noBossLabel.Font = Enum.Font.GothamSemibold
            noBossLabel.TextSize = 21
            noBossLabel.Position = UDim2.new(0, 0, 0, 45)
            noBossLabel.Parent = contentContainer
            contentContainer.CanvasSize = UDim2.new(0, 0, 0, 90)
            return
        end
        
        local yOffset = 45
        for _, farmData in ipairs(farms) do
            local bossName, farmPos = unpack(farmData)
            local isActive = (currentFarmMode == bossName)
            
            local switchFrame, setState = createToggleSwitch(contentContainer, T("farmPrefix") .. bossName, isActive, function(enabled)
                stopAllFarms()
                if enabled then startGenericFarm(bossName, farmPos) else currentFarmMode = nil end
                SaveConfig()
            end)
            switchFrame.Position = UDim2.new(0, 7.5, 0, yOffset)
            yOffset = yOffset + 52.5
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    local function showMaterialFarm()
        clearContent()
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = contentContainer

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)

        local orderCounter = 1

        local title = Instance.new("TextLabel")
        title.Text = T("matAndFish")
        title.Size = UDim2.new(1, 0, 0, 35)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        title.Parent = contentContainer
        
        local selectLabel = Instance.new("TextLabel")
        selectLabel.Text = T("autoOreSelect")
        selectLabel.Size = UDim2.new(1, 0, 0, 30)
        selectLabel.BackgroundTransparency = 1
        selectLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
        selectLabel.Font = Enum.Font.GothamSemibold
        selectLabel.TextSize = 18
        selectLabel.TextXAlignment = Enum.TextXAlignment.Left
        selectLabel.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        selectLabel.Parent = contentContainer
        
        local materialsFolder = workspace:FindFirstChild("Materials")
        local foundMaterials = {}
        if materialsFolder then
            for _, mat in ipairs(materialsFolder:GetChildren()) do
                if not table.find(foundMaterials, mat.Name) then table.insert(foundMaterials, mat.Name) end
            end
        end
        table.sort(foundMaterials)
        
        if #foundMaterials == 0 then
            local noMatLabel = Instance.new("TextLabel")
            noMatLabel.Text = T("noOresFound")
            noMatLabel.Size = UDim2.new(1, 0, 0, 30)
            noMatLabel.BackgroundTransparency = 1
            noMatLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            noMatLabel.Font = Enum.Font.Gotham
            noMatLabel.TextSize = 18
            noMatLabel.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
            noMatLabel.Parent = contentContainer
        else
            for _, matName in ipairs(foundMaterials) do
                if selectedMaterials[matName] == nil then selectedMaterials[matName] = false end
                local switchFrame, _ = createToggleSwitch(
                    contentContainer,
                    matName,
                    selectedMaterials[matName],
                    function(enabled)
                        selectedMaterials[matName] = enabled
                        SaveConfig()
                    end
                )
                switchFrame.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
            end
        end
        
        local activeSwitch, _ = createToggleSwitch(
            contentContainer,
            T("startFarmBtn"),
            materialFarmActive,
            function(enabled)
                materialFarmActive = enabled
                if enabled then
                    local anySelected = false
                    for _, state in pairs(selectedMaterials) do
                        if state then anySelected = true break end
                    end
                    if not anySelected then materialFarmActive = false else startMaterialFarm() end
                else
                    stopMaterialFarm()
                end
                SaveConfig()
            end
        )
        activeSwitch.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        
        local fishToggle, _ = createToggleSwitch(
            contentContainer,
            T("autoFish"),
            fishFarmActive,
            function(enabled)
                fishFarmActive = enabled
                if enabled then startFishFarm() else stopFishFarm() end
                SaveConfig()
            end
        )
        fishToggle.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        
        local spacer = Instance.new("Frame")
        spacer.Size = UDim2.new(1, 0, 0, 10)
        spacer.BackgroundTransparency = 1
        spacer.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        spacer.Parent = contentContainer

        local forgeTitle = Instance.new("TextLabel")
        forgeTitle.Text = T("forgeTitle")
        forgeTitle.Size = UDim2.new(1, 0, 0, 40)
        forgeTitle.BackgroundTransparency = 1
        forgeTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
        forgeTitle.Font = Enum.Font.GothamBold
        forgeTitle.TextSize = 21
        forgeTitle.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        forgeTitle.Parent = contentContainer
        
        local topRow = Instance.new("Frame")
        topRow.Size = UDim2.new(1, -15, 0, 45) 
        topRow.BackgroundTransparency = 1
        topRow.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        topRow.Parent = contentContainer
        
        refForgeSelectBtn = Instance.new("TextButton")
        refForgeSelectBtn.Size = UDim2.new(1, -60, 1, 0)
        refForgeSelectBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        refForgeSelectBtn.Text = forgeSelectedProduct and ("[["..forgeSelectedProduct.."]]") or T("forgeSelect")
        refForgeSelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        refForgeSelectBtn.Font = Enum.Font.GothamBold
        refForgeSelectBtn.TextSize = 18
        Instance.new("UICorner", refForgeSelectBtn).CornerRadius = UDim.new(0, 8)
        refForgeSelectBtn.Parent = topRow
        
        local refreshBtn = Instance.new("TextButton")
        refreshBtn.Size = UDim2.new(0, 50, 1, 0)
        refreshBtn.Position = UDim2.new(1, -50, 0, 0)
        refreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        refreshBtn.Text = "🔄"
        refreshBtn.TextSize = 20
        Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 8)
        refreshBtn.Parent = topRow

        local gridContainer = Instance.new("Frame")
        gridContainer.Size = UDim2.new(1, -15, 0, 0)
        gridContainer.BackgroundTransparency = 1
        gridContainer.Visible = false
        gridContainer.ClipsDescendants = true 
        gridContainer.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        gridContainer.Parent = contentContainer
        
        local gridLayout = Instance.new("UIGridLayout")
        gridLayout.CellSize = UDim2.new(0.32, 0, 0, 35)
        gridLayout.CellPadding = UDim2.new(0.02, 0, 0, 10)
        gridLayout.Parent = gridContainer

        local function populateForgeGrid()
            for _, c in ipairs(gridContainer:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            local items = getAvailableProducts()
            for _, name in ipairs(items) do
                local itemBtn = Instance.new("TextButton")
                itemBtn.Text = name
                itemBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                itemBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                itemBtn.Font = Enum.Font.Gotham
                itemBtn.TextSize = 14
                Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 6)
                itemBtn.MouseButton1Click:Connect(function()
                    forgeSelectedProduct = name
                    refForgeSelectBtn.Text = "[[" .. name .. "]]"
                    gridContainer.Visible = false
                    gridContainer.Size = UDim2.new(1, -15, 0, 0)
                    updateForgeUI(T("forgeReady"), Color3.fromRGB(0, 255, 0))
                    
                    if miniForgeGui then
                        miniForgeGui.Enabled = true
                    end
                end)
                itemBtn.Parent = gridContainer
            end
            gridContainer.Size = UDim2.new(1, -15, 0, gridLayout.AbsoluteContentSize.Y)
        end

        refForgeSelectBtn.MouseButton1Click:Connect(function()
            gridContainer.Visible = not gridContainer.Visible
            if gridContainer.Visible then populateForgeGrid() else gridContainer.Size = UDim2.new(1, -15, 0, 0) end
        end)
        
        refreshBtn.MouseButton1Click:Connect(function()
            gridContainer.Visible = true
            populateForgeGrid()
        end)

        refForgeStatus = Instance.new("TextLabel")
        refForgeStatus.Size = UDim2.new(1, -15, 0, 45)
        refForgeStatus.BackgroundTransparency = 1
        refForgeStatus.Font = Enum.Font.GothamBold
        refForgeStatus.TextSize = 16
        refForgeStatus.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        refForgeStatus.Parent = contentContainer

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Size = UDim2.new(1, -15, 0, 20)
        infoLabel.BackgroundTransparency = 1
        infoLabel.Text = T("forgeStartHint")
        infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        infoLabel.Font = Enum.Font.Gotham
        infoLabel.TextSize = 14
        infoLabel.LayoutOrder = orderCounter; orderCounter = orderCounter + 1
        infoLabel.Parent = contentContainer

        updateForgeUI(forgeActive and T("forgeStarting") or T("forgeWaiting"))
        
        task.delay(0.05, function()
            contentContainer.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
        end)
    end
    
    local function showPaths()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("pathsTitle")
        title.Size = UDim2.new(1, 0, 0, 37.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.Parent = contentContainer
        
        local currentPlaceId = game.PlaceId
        local currentFloorData = nil
        
        for _, floorData in ipairs(FLOORS) do
            if floorData[3] == currentPlaceId then
                currentFloorData = floorData
                break
            end
        end
        
        local yOffset = 45
        if not currentFloorData then
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = T("unknownFloor")
            infoLabel.Size = UDim2.new(1, 0, 0, 37.5)
            infoLabel.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 21
            infoLabel.Position = UDim2.new(0, 7.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 45
        else
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = string.format(T("youAreOnFloor"), currentFloorData[2], currentFloorData[1])
            infoLabel.Size = UDim2.new(1, 0, 0, 30)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 18
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Position = UDim2.new(0, 7.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 37.5
            
            local pathsForFloor = nil
            local pathBaseUrl = nil
            
            if currentFloorData[1] == 2 then pathsForFloor = FLOOR_2_PATHS pathBaseUrl = PATH_BASE_URL_2
            elseif currentFloorData[1] == 3 then pathsForFloor = FLOOR_3_PATHS pathBaseUrl = PATH_BASE_URL_3
            elseif currentFloorData[1] == 4 then pathsForFloor = FLOOR_4_PATHS pathBaseUrl = PATH_BASE_URL_4
            elseif currentFloorData[1] == 5 then pathsForFloor = FLOOR_5_PATHS pathBaseUrl = PATH_BASE_URL_5
            elseif currentFloorData[1] == 8 then pathsForFloor = FLOOR_8_PATHS pathBaseUrl = PATH_BASE_URL_8
            elseif currentFloorData[1] == 14 then pathsForFloor = FLOOR_14_PATHS pathBaseUrl = PATH_BASE_URL_14
            elseif currentFloorData[1] == 16 then pathsForFloor = FLOOR_16_PATHS pathBaseUrl = PATH_BASE_URL_16
            elseif currentFloorData[1] == 19 then pathsForFloor = FLOOR_19_PATHS pathBaseUrl = PATH_BASE_URL_19 end
            
            if not pathsForFloor or next(pathsForFloor) == nil then
                local noPathLabel = Instance.new("TextLabel")
                noPathLabel.Text = T("noPathsForFloor")
                noPathLabel.Size = UDim2.new(1, 0, 0, 1.5)
                noPathLabel.BackgroundTransparency = 1
                noPathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                noPathLabel.Font = Enum.Font.GothamSemibold
                noPathLabel.TextSize = 21
                noPathLabel.Position = UDim2.new(0, 7.5, 0, yOffset)
                noPathLabel.Parent = contentContainer
                yOffset = yOffset + 45
            else
                for pathName, fileName in pairs(pathsForFloor) do
                    local pathBtn = Instance.new("TextButton")
                    pathBtn.Text = "🗺️ " .. pathName
                    pathBtn.Size = UDim2.new(1, -15, 0, 52.5)
                    pathBtn.Position = UDim2.new(0, 7.5, 0, yOffset)
                    pathBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    pathBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
                    pathBtn.Font = Enum.Font.GothamBold
                    pathBtn.TextSize = 21
                    pathBtn.AutoButtonColor = true
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 9)
                    corner.Parent = pathBtn
                    
                    pathBtn.MouseButton1Click:Connect(function()
                        local originalText = pathBtn.Text
                        pathBtn.Text = T("pathLoading")
                        pathBtn.Interactable = false
                        local url = pathBaseUrl .. fileName .. ".lua"
                        
                        local success, result = pcall(function()
                            local scriptCode = game:HttpGet(url)
                            if not scriptCode or scriptCode == "" then error("Error 404") end
                            local func = loadstring(scriptCode)
                            if func then func() return true else error("loadstring nil") end
                        end)
                        
                        if success and result then
                            pathBtn.Text = "✅ " .. pathName .. " (" .. T("pathSuccess") .. ")"
                            pathBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 40)
                        else
                            pathBtn.Text = "❌ " .. pathName .. " (" .. T("pathError") .. ")"
                            pathBtn.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
                        end
                        
                        task.delay(2, function()
                            if pathBtn and pathBtn.Parent then
                                pathBtn.Text = originalText
                                pathBtn.Interactable = true
                                pathBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                            end
                        end)
                    end)
                    pathBtn.Parent = contentContainer
                    yOffset = yOffset + 60
                end
            end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    end
    
    local function showConvenience()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("tools") .. ":"
        title.Size = UDim2.new(1, 0, 0, 37.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.Parent = contentContainer
        
        local yOffset = 45
        
        local safe1Switch, _ = createToggleSwitch(contentContainer, T("safe1Toggle"), safe1Active, function(enabled)
            safe1Active = enabled
            if enabled then startSafe1() else stopSafe1() end
            SaveConfig()
        end)
        safe1Switch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        local autoWalkSwitch, _ = createToggleSwitch(contentContainer, T("autoMobWalk"), autoWalkActive, function(enabled)
            autoWalkActive = enabled
            if enabled then startAutoWalk() else stopAutoWalk() end
            SaveConfig()
        end)
        autoWalkSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        local freezeSwitch, _ = createToggleSwitch(contentContainer, T("freezeToggle"), isFrozen, function(enabled) toggleFreeze() end)
        freezeSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        local resSwitch, _ = createToggleSwitch(contentContainer, T("respawnToggle"), resurrectionActive, function(enabled)
            resurrectionActive = enabled
            if enabled then setupResurrection() else cleanupResurrection() end
            SaveConfig()
        end)
        resSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        local playerListSwitch, _ = createToggleSwitch(contentContainer, T("playerListToggle"), playerListActive, function(enabled)
            playerListActive = enabled
            if enabled then createPlayerListGui() else destroyPlayerListGui() end
            SaveConfig()
        end)
        playerListSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        local blockAllSwitch, _ = createToggleSwitch(contentContainer, T("blockAllToggle"), blockAllRunning, function(enabled)
            blockAllRunning = enabled
            if enabled then startBlockAll() else stopBlockAll() end
            SaveConfig()
        end)
        blockAllSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5

        local autoFSwitch, _ = createToggleSwitch(contentContainer, T("autoF"), autoFActive, function(enabled)
            autoFActive = enabled
            if enabled then startAutoF() else stopAutoF() end
            SaveConfig()
        end)
        autoFSwitch.Position = UDim2.new(0, 7.5, 0, yOffset)
        
        local cdBox = Instance.new("TextBox")
        cdBox.Size = UDim2.new(0, 52.5, 0, 30)
        cdBox.Position = UDim2.new(1, -142.5, 0.5, -15)
        cdBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        cdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        cdBox.Text = tostring(autoFCooldown)
        cdBox.Font = Enum.Font.GothamSemibold
        cdBox.TextSize = 18
        cdBox.ClearTextOnFocus = false
        cdBox.Parent = autoFSwitch
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = cdBox
        
        cdBox.FocusLost:Connect(function()
            local num = tonumber(cdBox.Text)
            if num and num >= 0 then autoFCooldown = num else cdBox.Text = tostring(autoFCooldown) end
            SaveConfig()
        end)
        
        yOffset = yOffset + 52.5
        
        local healSwitch, _ = createToggleSwitch(contentContainer, T("autoHeal"), autoHealActive, function(enabled)
            autoHealActive = enabled
            if enabled then startAutoHeal() else stopAutoHeal() end
            SaveConfig()
        end)
        healSwitch.Position = UDim2.new(0, 7.5, 0, yOffset) yOffset = yOffset + 52.5
        
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 15)
    end
    
    local function showSettings()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("languageLabel")
        title.Size = UDim2.new(1, 0, 0, 37.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 21
        title.Parent = contentContainer
        
        local langs = {
            {code = "ru", name = T("lang_ru")},
            {code = "uk", name = T("lang_uk")},
            {code = "en", name = T("lang_en")}
        }
        
        local yOffset = 45
        for _, lang in ipairs(langs) do
            local btn = Instance.new("TextButton")
            btn.Text = lang.name
            btn.Size = UDim2.new(1, -15, 0, 45)
            btn.Position = UDim2.new(0, 7.5, 0, yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 21
            btn.AutoButtonColor = true
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 9)
            corner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                currentLang = lang.code
                SaveConfig()
                rebuildGUI()
                createMiniForgeUI() 
            end)
            btn.Parent = contentContainer
            yOffset = yOffset + 52.5
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    local floorBtn = createMenuItem(T("floor"), "🌍")
    local teleportsBtn = createMenuItem(T("teleports"), "🌐")
    local bossRoomsBtn = createMenuItem(T("bossRooms"), "🚪")
    local bossFarmBtn = createMenuItem(T("bossFarm"), "👹")
    local materialFarmBtn = createMenuItem(T("materialFarm"), "📦")
    local pathsBtn = createMenuItem(T("paths"), "🗺️")
    local toolsBtn = createMenuItem(T("tools"), "🛠️")
    local settingsBtn = createMenuItem(T("settings"), "⚙️")
    
    local function selectButton(btn)
        for _, b in ipairs(menuItems) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end
    
    floorBtn.MouseButton1Click:Connect(function() selectButton(floorBtn) showFloors() end)
    teleportsBtn.MouseButton1Click:Connect(function() selectButton(teleportsBtn) showBosses() end)
    bossRoomsBtn.MouseButton1Click:Connect(function() selectButton(bossRoomsBtn) showBossRooms() end)
    bossFarmBtn.MouseButton1Click:Connect(function() selectButton(bossFarmBtn) showBossFarms() end)
    materialFarmBtn.MouseButton1Click:Connect(function() selectButton(materialFarmBtn) showMaterialFarm() end)
    pathsBtn.MouseButton1Click:Connect(function() selectButton(pathsBtn) showPaths() end)
    toolsBtn.MouseButton1Click:Connect(function() selectButton(toolsBtn) showConvenience() end)
    settingsBtn.MouseButton1Click:Connect(function() selectButton(settingsBtn) showSettings() end)
    
    selectButton(floorBtn)
    showFloors()
end

rebuildGUI()

local Camera = Workspace.CurrentCamera
if not Camera then
    Camera = Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    Camera = Workspace.CurrentCamera
end
local LocalPlayer = Players.LocalPlayer
local EspObjects = {}

local SPECIAL_PLAYERS = {
    ["huesos880055535"] = { text = "Lvl: Dominus", color = Color3.fromRGB(138, 43, 226) }
}

local function removeEsp(playerName)
    if EspObjects[playerName] then
        for _, drawing in pairs(EspObjects[playerName]) do
            if drawing.Remove then drawing.Visible = false drawing:Remove() end
        end
        EspObjects[playerName] = nil
    end
end

Players.PlayerRemoving:Connect(function(plr) removeEsp(plr.Name) end)

local function toScreen(pos, CameraObj)
    if not CameraObj then return Vector2.new(0,0), false end
    local vp, on = CameraObj:WorldToViewportPoint(pos)
    return Vector2.new(vp.X, vp.Y), on
end

spawn(function()
    while true do
        local Cam = workspace.CurrentCamera
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer then continue end
            
            local pName = plr.Name
            local char = plr.Character
            local hum = char and char:FindFirstChild("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")

            if not char or not hum or not root or not head or hum.Health <= 0 then
                if EspObjects[pName] then
                    for _, d in pairs(EspObjects[pName]) do d.Visible = false end
                end
                continue
            end

            local pNameLower = string.lower(pName)
            local specialData = SPECIAL_PLAYERS[pNameLower]
            
            if specialData and not char:FindFirstChild("EspHighlight") then
                local hl = Instance.new("Highlight") 
                hl.Name = "EspHighlight" 
                hl.FillColor = specialData.color 
                hl.OutlineColor = specialData.color 
                hl.FillTransparency = 0.7 
                hl.Parent = char
            end

            if not EspObjects[pName] then
                EspObjects[pName] = {
                    box = Drawing.new("Square"), 
                    name = Drawing.new("Text"), 
                    level = Drawing.new("Text")
                }
                EspObjects[pName].box.Thickness = 2 
                EspObjects[pName].box.Filled = false
                EspObjects[pName].name.Size = 20 
                EspObjects[pName].name.Outline = true 
                EspObjects[pName].name.Center = true
                EspObjects[pName].level.Size = 18 
                EspObjects[pName].level.Outline = true 
                EspObjects[pName].level.Center = true
            end

            local e = EspObjects[pName]
            local hPos, hVis = toScreen(head.Position, Cam)
            local rPos, rVis = toScreen(root.Position - Vector3.new(0, 3, 0), Cam)

            if hVis and rVis then
                local height = math.abs(hPos.Y - rPos.Y) * 1.5
                local width = height * 0.6
                
                e.box.Size = Vector2.new(width, height) 
                e.box.Position = Vector2.new(hPos.X - width/2, hPos.Y - height*0.15)
                e.box.Color = specialData and specialData.color or Color3.fromRGB(255, 0, 0)
                e.box.Visible = true
                
                e.name.Text = pName 
                e.name.Color = Color3.fromRGB(255, 255, 255)
                e.name.Position = Vector2.new(hPos.X, hPos.Y - 25)
                e.name.Visible = true

                if specialData then
                    e.level.Text = specialData.text 
                    e.level.Color = specialData.color 
                else
                    e.level.Text = "Lvl: " .. tostring(getPlayerLevel(plr))
                    e.level.Color = Color3.fromRGB(0, 255, 255) 
                end
                e.level.Position = Vector2.new(hPos.X, hPos.Y - 5) 
                e.level.Visible = true
            else
                e.box.Visible = false 
                e.name.Visible = false 
                e.level.Visible = false 
            end
        end
        RunService.RenderStepped:Wait()
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.G then
        
        if forgeActive then
            forgeActive = false
            forgeStopping = false
            forgeMinigameEnabled = false
            forgeIsClicking = false
            if forgeAutoFarmLoop and coroutine.running() ~= forgeAutoFarmLoop then
                pcall(function() task.cancel(forgeAutoFarmLoop) end)
            end
            updateForgeUI(T("forgeEmergencyStop"), Color3.fromRGB(255, 50, 50))
            notify(T("forgeStoppedTitle"), T("forgeStoppedDesc"))
        end

        if screenGuiMain then
            local mainFrame = screenGuiMain:FindFirstChild("Frame")
            local minimizedFrame = screenGuiMain:FindFirstChild("Frame", true)
            
            for _, child in ipairs(screenGuiMain:GetChildren()) do
                if child.Name == "Frame" and child.Size.X.Offset == 1200 then
                    mainFrame = child
                elseif child.Name == "Frame" and child.Size.X.Offset == 150 then
                    minimizedFrame = child
                end
            end

            if mainFrame and minimizedFrame then
                if mainFrame.Visible then
                    mainFrame.Visible = false
                    minimizedFrame.Visible = true
                else
                    mainFrame.Visible = true
                    minimizedFrame.Visible = false
                end
            end
        end
    end
end)
