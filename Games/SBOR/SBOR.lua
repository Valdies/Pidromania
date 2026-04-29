-- ==============================================================================
-- === ПОДКЛЮЧЕНИЕ СЕРВИСОВ ИГРЫ ===
-- ==============================================================================
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ==============================================================================
-- === ЛОКАЛИЗАЦИЯ (ПЕРЕВОДЫ) ===
-- ==============================================================================
local currentLang = "ru" -- Язык по умолчанию
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
        safe1Toggle = "Safe 1 (Смерть при 2+ игроках)",
        autoMobWalk = "Автофарм близжайших мобов",
        languageLabel = "Язык интерфейса:",
        lang_ru = "Русский",
        lang_uk = "Українська",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Загрузка...",
        pathError = "❌ Ошибка!",
        pathSuccess = "✅ Запущен!",
        noPathsForFloor = "Для этого этажа нет путей."
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
        safe1Toggle = "Safe 1 (Смерть при 2+ гравцях)",
        autoMobWalk = "Автофарм найближчих мобів",
        languageLabel = "Мова інтерфейсу:",
        lang_ru = "Російська",
        lang_uk = "Українська",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Завантаження...",
        pathError = "❌ Помилка!",
        pathSuccess = "✅ Запущено!",
        noPathsForFloor = "Для цього поверху немає шляхів."
    },
    kk = {
        hubTitle = "Pidromania Hub: Sword Blox Online",
        byAuthor = "by @Pidromania",
        floor = "Қабат",
        teleports = "Телепорттар",
        bossRooms = "Босс бөлмелері",
        bossFarm = "Босс фармі",
        materialFarm = "Ресурстарды фармдау",
        paths = "Жолдар",
        tools = "Құралдар",
        settings = "Параметрлер",
        selectFloor = "Қабатты таңдаңыз:",
        unknownFloor = "Қате: белгісіз қабат",
        noBosses = "Бұл қабатта босстар жоқ",
        bossesOfFloor = "Қабат %d (%s) босстары:",
        bossFarms = "Босс фармдары:",
        noFarms = "Бұл қабатта фармдар жоқ",
        matAndFish = "Ресурс пен балық фармі",
        autoOreSelect = "Жинау үшін кенді таңдаңыз:",
        noOresFound = "Бұл қабатта ресурстар табылмады.",
        startFarmBtn = "🟢 АВТО-ЖИНАУДЫ ІСКЕ ҚОСУ",
        warnNoSelection = "⚠️ Кем дегенде бір кен түрін таңдаңыз!",
        autoFish = "Авто-балық аулау (әр минут сайын 10)",
        freezeToggle = "Ойыншыны орнында тоқтату",
        respawnToggle = "Өлген жерде қайта туу",
        playerListToggle = "Сервердегі ойыншылар тізімі",
        safe1Toggle = "Safe 1 (2+ ойыншыда өлу)",
        autoMobWalk = "Ең жақын мобтарды авто-фармдау",
        languageLabel = "Интерфейс тілі:",
        lang_ru = "Орыс",
        lang_uk = "Украин",
        lang_kk = "Қазақ",
        lang_en = "Ағылшын (АҚШ)",
        pathLoading = "⏳ Жүктеу...",
        pathError = "❌ Қате!",
        pathSuccess = "✅ Іске қосылды!",
        noPathsForFloor = "Бұл қабатқа жолдар жоқ."
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
        safe1Toggle = "Safe 1 (Kill on 2+ players)",
        autoMobWalk = "Auto-farm nearest mobs",
        languageLabel = "Interface language:",
        lang_ru = "Russian",
        lang_uk = "Ukrainian",
        lang_kk = "Қазақ",
        lang_en = "English (US)",
        pathLoading = "⏳ Loading...",
        pathError = "❌ Error!",
        pathSuccess = "✅ Started!",
        noPathsForFloor = "No paths for this floor."
    }
}

-- Функция для получения строки перевода по ключу
local function T(key)
    return translations[currentLang][key] or ("???" .. key .. "???")
end

-- ==============================================================================
-- === БАЗЫ ДАННЫХ ИГРЫ (Этажи, Боссы, Координаты) ===
-- ==============================================================================
local FLOORS = {
    --{-2,  "Зимний ивент", 86400682391969}, НИ В КОЕМ СЛУЧАЕ НЕ УДАЛЯТЬ
    --{-1, "Пасхальный ивент", 10299594856}, НИ В КОЕМ СЛУЧАЕ НЕ УДАЛЯТЬ
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
    [86400682391969] = {
		{"Gingervale Attendant", -312, 21, 1984},
		{"Gingervale Warden", -93, 22, 2015},
		{"Aurelius Starless", -422, 132, 2420},
		{"Kringlewrath The Iron Saint", -265, 21, 2679},
		{"Аврора ебаная", -2, 72, -1010}
	},

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
        {"Goblins cave", -578.07, 178.99, 3519.20},
        {"Two-Headed Giant", 2742.92, 225.58, 7207.78}
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
    },
    [130463264320898] = {
        {"Новый Босс", -3501.16, 153.08, 3534.65},
        {"kvrst", -4313.40, 131.45, -888.28},
        {"sunstone", -4331.49, 144.00, 349.18},
        {"minik", -3224.66, 156.07, -1323.25},
        {"Пингвины", -2397.24, 156.93, 2185.15},
        {"Големы", 773.03, 112.48, 1246.18},
        {"Вендиго", 3546.91, -889.56, 7155.80},
        {"minik 2 location", 2150.95, -1181.13, 4616.98},
        {"главный босс", 3796.98, -942.65, 6422.02}
    }
}

local BOSS_FARMS = {
    [10299594856] = {
        {"Фарм: Центр (Пасха)", Vector3.new(24.45, 267.77, 400.73)}
    },
    [4734865416] = {
        {"Illfang The Kobold Lord", Vector3.new(-972.62, 1933.95, -727.67)},
        {"Shadesworn the Corrupted", Vector3.new(421.36, -1174.06, -467.49)}
    },
    [4735703075] = {
        {"MobFarm", Vector3.new(-367.31, 0.75, 1007.91)},
        {"Lord Slug", Vector3.new(747.68, 2485.53, 52)}
    },
    [4735718710] = {
        {"Stallord", Vector3.new(571.00, 1188.82, 12513.01)}
    },
    [4736649014] = {
        {"MobFarm", Vector3.new(498.27, 701.39, 608.80)},
        {"X'rphan the White Wyrm", Vector3.new(-1695.54, 402.80, -1718.85)}
    },
    [4736759720] = {
        {"Uakmaroth, the Demon Lord", Vector3.new(-1532.07, 1914.88, -384.36)}
    },
    [4736984932] = {
        {"Storm Atronach", Vector3.new(-5849, -368, 9330)}
    },
    [4737916764] = {
        {"Bonnz the Skeleton Lord", Vector3.new(2737.84, -548.03, -1699.97)},
        {"MobFarm", Vector3.new(271.30, 34, -1441.69)}
    },
    [4740039076] = {
        {"MobFarm", Vector3.new(-2666.91, 893.12, 9499.35)},
        {"Guardian of the Gate", Vector3.new(-2666.33, 899.55, 9119.14)},
        {"Karth'uk The Crystal Kraken", Vector3.new(-2549.95, 53.51, 6823.25)}
    },
    [4747247314] = {
        {"Hotoke The Enlightened", Vector3.new(-3973.63, -9910.32, -7164.26)}
    },
    [5135551944] = {
        {"Buffed Knight", Vector3.new(-1605.13, 38.42, -5727.90)},
        {"Grimlock the Fallen King", Vector3.new(-9471.73, -443.34, 1915.18)}
    },
    [5212666689] = {
        {"Laurellis Convict", Vector3.new(14969.86, 770.86, -708.19)},
        {"Slime Lord Pengonis", Vector3.new(-1803.66, 1108.39, -9831.81)}
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
        {"Raios", Vector3.new(4846.71, -3051.62, -1168.02)},
        {"Sortiliena", Vector3.new(4846.71, -2025.62, -1168.02)},
        {"Golgorosso", Vector3.new(4846.71, -1005.58, -1168.02)}
    },
    [11987539001] = {
        {"Leader Goblin", Vector3.new(-1751, 181, 2608)},
        {"Two-Headed Giant", Vector3.new(2835.94, 251.57, 6077.73)}
    },
    [12632324801] = {
        {"Captain Sweet the Forever Child", Vector3.new(2993.59, -833.45, -1959.57)}
    },
    [94066307314492] = {
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
    [117852524597461] = {
        {"Frontman", Vector3.new(-38.32, 80.40, -285.61)},
    },
    [130463264320898] = {
        {"Oslund the Hollow Flame", Vector3.new(-3501.16, 153.08, 3534.65)},
        {"Frostveil Echo", Vector3.new(2275.98, -1175.30, 4579.98)},
        {"Ice Spirit", Vector3.new(3825.06, -942.65, 6400.30)},
        {"Владимир Красное Солнышко", Vector3.new(-3183.14, 155.03, -1271.63)},
        {"Мобфарм медведей", Vector3.new(2765.72, -473.67, 7026.55)},
        {"Мобфарм крылатых шлюшек", Vector3.new(2935.85, -473.72, 7003.91)},
        {"Мобофарм у вендиго", Vector3.new(3559.58, -889.56, 7149.98)}
    }
}

-- === ТАБЛИЦА ДОПОЛНИТЕЛЬНЫХ ЛОКАЦИЙ ===
local EXTRA_LOCATIONS = {
    [10299594856] = {
        {"Камни",  -270.87, 255.73, 325.78},
        {"Центр", 23.92, 237.75, 400.89}
    },
    [4734865416] = {
        {"Город", 415.57, 107.68, -276.72},
        {"Шахта", -436.26, 128.35, 154.04},
        {"Комната босса", -540.97, 1917.21, -727.32},
        {"Комната Минибосса", 178.45, -1174.08, -487.87}
    },
    [4735703075] = {
        {"Яма", -341.45, 99.01, 997.13},
        {"Шахта", -6.24, 27.97, 945.08},
        {"Магазин", -969.56, 69.00, -895.28},
        {"Вход в башню", 282.07, -927.82, 838.67},
        {"Комната босса", 545.77, 2485.72, 591.24},
    },
    [4735718710] = {
        {"Шахта", 1339.27, 1826.08, -623.95},
        {"Вход в башню", 1118.11, 1133.63, 12498.01},
        {"Комната босса", 347.68, 1188.30, 12457.61}
    },
    [4736649014] = {
        {"Шахта", 768.75, 204.93, 687.25},
        {"Вход в башню", -2367.82, 407.96, -1542.97},
        {"Комната босса", -2219.23, 400.14, -1873.53}
    },
    [4736759720] = {
        {"Шахта", -961.40, 193.43, -1390.09},
        {"Вход в башню", -1343.48, 1132.88, 138.37},
        {"Комната босса", -1279.13, 1913.99, -426.48}
    },
    [4736984932] = {
        {"None", 0.0, 0.0, 0.0}
    },
    [4737916764] = {
        {"Вход в башню", 2687.15, -654.41, 470.80},
        {"Комната босса", 2783.20, -554.00, -1670.30}
    },
    [4740039076] = {
        {"Магазин", 1198.64, 951.67, -174.30},
        {"Вход в первую локацию", -2691.01, 1184.50, 13916.61},
        {"Вход в башню", 1236.04, 129.95, 11256.65},
        {"Комната босса", -2620.99, 32.80, 7070.26}
    },
    [4747247314] = {
        {"Шахта", -114.55, 20.66, 966.82},
        {"Вход в башню", -4000.10, -9989.45, -5859.08},
        {"Комната босса", -3987.15, -9930.00, -6714.68}
    },
    [5135551944] = {
        {"Крыша минибосса", -1674.17, 152.01, -5899.82},
        {"Вход в башню", -10204.24, -479.34, -491.57},
        {"Комната босса", -9471.52, -474.34, 1500.44}
    },
    [5212666689] = {
        {"Магазин в залупенске", -1618.68, 1359.33, 8325.41},
        {"Вход в башню", 2065.14, 260.02, -8207.31},
        {"Комната босса", -1193.62, 1092.96, -9792.50}
    },
    [5136611550] = {
        {"None", 0.0, 0.0, 0.0}
    },
    [4733293091] = {
        {"Яйцо босса", -1557.81, -1322.58, 1580.20}
    },
    [11987483716] = {
        {"None", 0.0, 0.0, 0.0}
    },
    [11987539001] = {
        {"Деревня", -991.45, 239.96, -956.28},
        {"Гигас", -1434.15, 170.36, -2159.10}
    },
    [12632324801] = {
        {"None", 0.0, 0.0, 0.0}
    },
    [94066307314492] = {
        {"NPC Кошак", -715.74, 14.95, 49.26},
        {"Тхунг", -1445.02, 253.41, -133.76}
    },
    [130463264320898] = {
        {"Комната главного босса", 3940.89, -964.40, 6302.97},
        {"Ледяной замок", 1028.20, -1218.36, 4146.35},
        {"Маяк", -1629.58, 1016.57, 1514.95},
        {"Церковь", -5474.52, 192.08, -1537.69},
        {"Дом вендиго", -2998.23, -565.16, 9125.64},
        {"Ключ", 2559.68, 133.57, 592.29},
        {"Вход в пещеру с пингвинчиками", -2975.91, 353.49, 2394.02},
        {"Ты не порти мой рассказ", -2904.03, 419.96, 1640.88}
    },
}

-- ==============================================================================
-- === КОНФИГУРАЦИЯ ПУТЕЙ (Загрузка файлов с GitHub) ===
-- ==============================================================================
local FLOOR_2_PATHS = {
    ["Boss2"] = "Boss2",
    ["Miniboss"] = "Miniboss"
}
local PATH_BASE_URL_2 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/2%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_3_PATHS = {
    ["Башня"] = "Башня",
    ["Магазин"] = "Магазин"
}
local PATH_BASE_URL_3 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/3%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_4_PATHS = {
    ["Лабиринт"] = "Labirint",
    ["Шахта"] = "Shaxta"
}
local PATH_BASE_URL_4 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/4%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_5_PATHS = {
    ["Лабиринт"] = "Лабиринт"
}
local PATH_BASE_URL_5 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/5%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_8_PATHS = {
    ["Boss"] = "Boss"
}
local PATH_BASE_URL_8 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/8%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_14_PATHS = {
    ["BlueCristal"] = "BlueCristal",
    ["Boss1LeaderGrimm"] = "Boss1LeaderGrimm",
    ["RedCristal"] = "RedCristal"
}
local PATH_BASE_URL_14 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/14%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_16_PATHS = {
    ["LeaderGoblin"] = "LeaderGoblin",
    ["Two-HeadedGiant"] = "Two-HeadedGiant"
}
local PATH_BASE_URL_16 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/16%20%D1%8D%D1%82%D0%B0%D0%B6/"

local FLOOR_19_PATHS = {
    ["Frostveil Echo"] = "FrostveilEcho",
    ["Ice Spirit"] = "IceSpirit",
    ["Владимир К.С."] = "Vladimir",
    ["Дом вендиго"] = "WendigoHouse",
    ["Лабиринт вендиго"] = "WendigoMaze",
    ["Ледяной замок"] = "IceCastle",
    ["Маяк"] = "Lighthouse",
    ["Церковь"] = "Church"
}
local PATH_BASE_URL_19 = "https://raw.githubusercontent.com/Valdies/Pidromania/main/Games/SBOR/%D0%9F%D1%83%D1%82%D0%B8/19%20%D1%8D%D1%82%D0%B0%D0%B6/"

-- ==============================================================================
-- === ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ СОСТОЯНИЙ ===
-- ==============================================================================
local isFrozen = false
local freezeConnection = nil
local resurrectionActive = false
local resurrectionConnections = {}
local currentFarmMode = nil
local individualFreezeConnection = nil
local screenGui = nil
local indicator = nil
local playerListGui = nil
local playerListUpdateLoop = nil
local materialFarmActive = false
local fishFarmActive = false
local selectedMaterials = {}
local autoWalkActive = false
local autoWalkConnection = nil
local mobsFolder = nil
local safe1Active = false -- Переменная для Safe 1

-- Настройки для авто-ходьбы к мобам
local AUTO_WALK_CONFIG = {
    WalkSpeed = 30,
    NormalSpeed = 16,
    MaxDistance = 1500,
    StopDistance = 6.5
}

-- ==============================================================================
-- === ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ===
-- ==============================================================================

-- Функция телепортации игрока по координатам
local function teleport(pos)
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Создание платформы в воздухе (для фарма некоторых боссов)
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

-- Заморозка персонажа в одной точке (сохраняет позицию каждый кадр)
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

-- Снятие заморозки
local function unfreezePlayer()
    if individualFreezeConnection then
        individualFreezeConnection:Disconnect()
        individualFreezeConnection = nil
    end
end

-- Инициализация индикатора фарма (квадратик сбоку)
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

-- Обновление цвета индикатора (зеленый - моб найден, красный - нет)
local function updateIndicator(isNear)
    if indicator then
        indicator.BackgroundColor3 = isNear and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
    end
end

-- Поиск папки с мобами в Workspace
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

-- Получение уровня игрока из различных параметров (для списка игроков и ESP)
local function getPlayerLevel(plr)
    local stats = plr:FindFirstChild("PlayerStats")
    if stats then
        local levelObj = stats:FindFirstChild("Level")
        if levelObj and (levelObj:IsA("IntValue") or levelObj:IsA("NumberValue")) then
            return levelObj.Value
        elseif levelObj and levelObj:IsA("StringValue") and tonumber(levelObj.Value) then
            return tonumber(levelObj.Value)
        end
    end
    
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local lvl = leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("lvl") or leaderstats:FindFirstChild("level")
        if lvl and (lvl:IsA("IntValue") or lvl:IsA("NumberValue")) then
            return lvl.Value
        elseif lvl and lvl:IsA("StringValue") and tonumber(lvl.Value) then
            return tonumber(lvl.Value)
        end
    end
    
    local attr = plr:GetAttribute("Level")
    if type(attr) == "number" then
        return attr
    elseif type(attr) == "string" and tonumber(attr) then
        return tonumber(attr)
    end
    
    return "?"
end

-- ==============================================================================
-- === ИНТЕРФЕЙС СПИСКА ИГРОКОВ (Player List) ===
-- ==============================================================================
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
    frame.BackgroundTransparency = 0
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    frame.BorderSizePixel = 0
    frame.Parent = playerListGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local header = Instance.new("TextLabel")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundTransparency = 1
    header.Text = T("playerListToggle")
    header.TextColor3 = Color3.fromRGB(180, 180, 220)
    header.Font = Enum.Font.GothamBold
    header.TextSize = 16
    header.TextXAlignment = Enum.TextXAlignment.Center
    header.Parent = frame
    
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -42)
    scroll.Position = UDim2.new(0, 6, 0, 32)
    scroll.BackgroundTransparency = 1
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    scroll.Parent = frame
    
    local function updateList()
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextLabel") then
                child:Destroy()
            end
        end
        
        local y = 0
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local level = getPlayerLevel(plr)
                local txt = string.format("%s — [%s]", plr.Name, tostring(level))
                
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -8, 0, 24)
                lbl.Position = UDim2.new(0, 4, 0, y)
                lbl.BackgroundTransparency = 1
                lbl.Text = txt
                lbl.TextColor3 = Color3.fromRGB(240, 240, 255)
                lbl.Font = Enum.Font.GothamBold
                lbl.TextSize = 16
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.Parent = scroll
                
                y = y + 28
            end
        end
        scroll.CanvasSize = UDim2.new(0, 0, 0, y)
    end
    
    updateList()
    
    -- Цикл обновления списка каждые 5 секунд
    playerListUpdateLoop = spawn(function()
        while playerListGui and playerListGui.Parent do
            task.wait(5)
            if playerListGui then
                updateList()
            end
        end
    end)
    
    Players.PlayerAdded:Connect(updateList)
    Players.PlayerRemoving:Connect(updateList)
end

local function destroyPlayerListGui()
    if playerListUpdateLoop then
        playerListUpdateLoop = nil
    end
    if playerListGui then
        playerListGui:Destroy()
        playerListGui = nil
    end
end

-- ==============================================================================
-- === ФУНКЦИИ УТИЛИТ (Фриз, Воскрешение, Safe 1) ===
-- ==============================================================================

-- Логика Safe 1 (Смерть при 2+ игроках)
local function startSafe1()
    if safe1Active then return end
    safe1Active = true
    spawn(function()
        while safe1Active do
            if #Players:GetPlayers() >= 2 then
                local char = player.Character
                if char then
                    local humanoid = char:FindFirstChild("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        humanoid.Health = 0 -- Убиваем персонажа
                    end
                end
            end
            task.wait(5) -- Проверка каждые 5 секунд
        end
    end)
end

local function stopSafe1()
    safe1Active = false
end

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
                isFrozen = false
            end
        else
            isFrozen = false
        end
    else
        if freezeConnection then
            freezeConnection:Disconnect()
            freezeConnection = nil
        end
    end
end

local function cleanupResurrection()
    for _, conn in ipairs(resurrectionConnections) do
        if conn and conn.Disconnect then
            conn:Disconnect()
        end
    end
    resurrectionConnections = {}
    resurrectionActive = false
end

-- Сохраняет позицию каждую секунду и возвращает туда при смерти
local function setupResurrection()
    if resurrectionActive then return end
    cleanupResurrection()
    resurrectionActive = true
    
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

-- ==============================================================================
-- === ЛОГИКА AUTO-WALK (Авто-ходьба к мобам) ===
-- ==============================================================================
local function startAutoWalk()
    if autoWalkActive then return end
    mobsFolder = findMobsFolder()
    
    if not mobsFolder then return end
    
    autoWalkActive = true
    autoWalkConnection = RunService.RenderStepped:Connect(function()
        if not autoWalkActive then return end
        if not mobsFolder then
            mobsFolder = findMobsFolder()
            if not mobsFolder then return end
        end
        
        local char = player.Character
        if not char then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return end
        
        local playerPos = hrp.Position
        local nearestMob = nil
        local nearestDist = AUTO_WALK_CONFIG.MaxDistance
        
        -- Поиск ближайшего моба
        for _, mob in ipairs(mobsFolder:GetChildren()) do
            if mob:IsA("Model") or mob:IsA("BasePart") then
                local targetPart = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
                if targetPart then
                    local dist = (playerPos - targetPart.Position).Magnitude
                    if dist < nearestDist then
                        nearestDist = dist
                        nearestMob = mob
                    end
                end
            end
        end
        
        -- Движение к найденному мобу
        if nearestMob then
            local targetPart = nearestMob:FindFirstChild("HumanoidRootPart") or nearestMob.PrimaryPart
            if targetPart then
                if nearestDist > AUTO_WALK_CONFIG.StopDistance then
                    humanoid:MoveTo(targetPart.Position)
                else
                    humanoid:MoveTo(hrp.Position)
                end
            end
        end
    end)
end

local function stopAutoWalk()
    if not autoWalkActive then return end
    autoWalkActive = false
    if autoWalkConnection then
        autoWalkConnection:Disconnect()
        autoWalkConnection = nil
    end
end

player.CharacterAdded:Connect(function(char)
    task.wait(1)
    local humanoid = char:FindFirstChild("Humanoid")
end)

-- ==============================================================================
-- === ЛОГИКА ФАРМА БОССОВ (Телепорт мобов к игроку) ===
-- ==============================================================================
local function startGenericFarm(bossName, farmPos)
    currentFarmMode = bossName
    initGUI()
    updateIndicator(false)
    
    local isFrontman = (bossName == "Frontman")
    local isCurrentlyVladimir = (bossName == "Владимир Красное Солнышко")
    local isCurrentlyFrostveil = (bossName == "Frostveil Echo")
    local isCurrentlyFloor8Mob = (bossName == "MobFarm" and game.PlaceId == 4737916764)
    local isEasterFarm = (bossName == "Фарм: Центр (Пасха)" and game.PlaceId == 10299594856)
    local platform = nil
    
    -- Спавн платформ и телепорт для специфичных боссов
    if isFrontman then
        local platformPos = Vector3.new(-38.32, 80.40, -285.61)
        platform = spawnPlatform(platformPos)
        teleport(platformPos + Vector3.new(0, 5, 0))
    elseif isCurrentlyVladimir then
        local platformPos = Vector3.new(-3183.14, 150.03, -1271.63)
        local playerPos = Vector3.new(-3183.14, 152.03, -1271.63)
        farmPos = playerPos
        platform = spawnPlatform(platformPos)
        teleport(playerPos)
    elseif isCurrentlyFrostveil then
        local platformPos = Vector3.new(2203.02, -1192, 4586.85)
        local playerPos = Vector3.new(2203.02, -1190.33, 4586.85)
        farmPos = playerPos
        platform = spawnPlatform(platformPos)
        teleport(playerPos)
    elseif isCurrentlyFloor8Mob then
        local platformPos = Vector3.new(271.30, 34, -1441.69)
        local playerPos = Vector3.new(271.30, 36, -1441.69)
        farmPos = playerPos
        platform = spawnPlatform(platformPos)
        teleport(playerPos)
    elseif isEasterFarm then
        local platformPos = Vector3.new(24.45, 262, 400.73)
        local playerPos = platformPos + Vector3.new(0, 5, 0)
        farmPos = playerPos
        platform = spawnPlatform(platformPos)
        teleport(playerPos)
    else
        teleport(farmPos)
        task.wait(0.3)
    end
    
    spawn(function()
        task.wait(1)
        freezePlayer()
        
        local placeId = game.PlaceId
        local isFloor14 = (placeId == 4733293091)
        local isFloor18 = (placeId == 94066307314492)
        local isFloor13 = (placeId == 5136611550)
        local isFloor17 = (placeId == 12632324801)
        local isArena18_2 = (placeId == 117852524597461)
        local isFloor19 = (placeId == 130463264320898)
        local isCurrentlyFrontman = (bossName == "Frontman")
        
        -- Главный цикл фарма
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
                            
                            -- Логика проверок дистанции для разных боссов и этажей
                            if (isCurrentlyFrontman and isArena18_2) or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or isEasterFarm then
                                local delta = torso.Position - farmPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = delta.Y
                                
                                -- Отдельная логика для Frostveil (тянем мобов снизу)
                                if isCurrentlyFrostveil then
                                    if horizontalDist <= 10 and verticalDelta >= -50 and verticalDelta <= 0 then
                                        shouldProcess = true
                                    end
                                -- Логика для Пасхи (радиус 15, только те, что ниже)
                                elseif isEasterFarm then
                                    if horizontalDist <= 4 and verticalDelta <= 0 then
                                        shouldProcess = true
                                    end
                                else
                                    -- Старая логика для остальных боссов
                                    if horizontalDist <= 15 then
                                        if isCurrentlyVladimir or isCurrentlyFloor8Mob then
                                            if verticalDelta >= 0 and verticalDelta <= 50 then
                                                shouldProcess = true
                                            end
                                        elseif isCurrentlyFrontman then
                                            if verticalDelta >= -50 and verticalDelta <= 0 then
                                                shouldProcess = true
                                            end
                                        end
                                    end
                                end
                            elseif isFloor14 or isFloor18 or isFloor17 or isFloor19 or isArena18_2 then
                                local delta = torso.Position - farmPos
                                local horizontalDist = Vector2.new(delta.X, delta.Z).Magnitude
                                local verticalDelta = delta.Y
                                
                                if horizontalDist <= 15 and verticalDelta >= -50 and verticalDelta <= 0 then
                                    shouldProcess = true
                                end
                            else
                                local searchRadius = isFloor13 and 50 or 30
                                if (torso.Position - farmPos).Magnitude <= searchRadius then
                                    shouldProcess = true
                                end
                            end
                            
                            -- Если моб в зоне видимости, телепортируем его к игроку
                            if shouldProcess then
                                foundAny = true
                                torso.Anchored = true
                                torso.CanCollide = false
                                local targetPos = hrp.Position + hrp.CFrame.LookVector * 5
                                torso.CFrame = CFrame.fromMatrix(targetPos, hrp.CFrame.RightVector, hrp.CFrame.UpVector, hrp.CFrame.LookVector)
                                
                                if not (isFloor14 or isFloor18 or isCurrentlyFrontman or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or isEasterFarm) then
                                    break
                                end
                            end
                        end
                    end
                end
            end
            
            updateIndicator(foundAny)
            
            if isFloor14 or isFloor18 or isCurrentlyFrontman or isCurrentlyVladimir or isCurrentlyFrostveil or isCurrentlyFloor8Mob or isEasterFarm then
                task.wait(3)
            else
                task.wait(0.1)
            end
        end
        
        unfreezePlayer()
        if platform then
            platform:Destroy()
        end
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

-- ==============================================================================
-- === ФАРМ РЕСУРСОВ И РЫБЫ ===
-- ==============================================================================
local function startMaterialFarm()
    if materialFarmActive then return end
    
    local anySelected = false
    for _, state in pairs(selectedMaterials) do
        if state then
            anySelected = true
            break
        end
    end
    
    if not anySelected then
        return
    end
    
    materialFarmActive = true
    spawn(function()
        while materialFarmActive do
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
            task.wait(7)
        end
    end)
end

local function stopMaterialFarm()
    materialFarmActive = false
end

local function startFishFarm()
    if fishFarmActive then return end
    fishFarmActive = true
    spawn(function()
        while fishFarmActive do
            pcall(function()
                local RepStor = game:GetService("ReplicatedStorage")
                if RepStor:FindFirstChild("CatchFish") then
                    RepStor.CatchFish:FireServer(10)
                end
            end)
            task.wait(60)
        end
    end)
end

local function stopFishFarm()
    fishFarmActive = false
end

-- Вспомогательная функция для создания кнопок-переключателей
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
-- === ГЕНЕРАЦИЯ ГЛАВНОГО GUI МЕНЮ ===
-- ==============================================================================
local screenGuiMain = nil

local function rebuildGUI()
    if screenGuiMain then
        screenGuiMain:Destroy()
    end
    
    -- Главный слой интерфейса
    screenGuiMain = Instance.new("ScreenGui")
    screenGuiMain.Name = "PidromaniaHub"
    screenGuiMain.ResetOnSpawn = false
    screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGuiMain.Parent = player:WaitForChild("PlayerGui")
    
    -- Основное окно (можно перемещать)
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
    
    -- Невидимый слой для корректного перетаскивания окна
    local dragDetector = Instance.new("Frame")
    dragDetector.Size = UDim2.new(1, -50 * 1.5, 1, 0)
    dragDetector.Position = UDim2.new(0, 0, 0, 0)
    dragDetector.BackgroundTransparency = 1
    dragDetector.Parent = mainFrame
    
    -- Свернутая панель
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
    minimizedLabel.Text = T("hubTitle")
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
    
    -- Шапка основного меню (Верхняя полоса)
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
    
    -- Кнопка сворачивания меню
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
    
    -- Создание левой панели навигации
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 200 * 1.5, 1, -35 * 1.5)
    leftPanel.Position = UDim2.new(0, 0, 0, 35 * 1.5)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainFrame
    
    local cornerLeft = Instance.new("UICorner")
    cornerLeft.CornerRadius = UDim.new(0, 8 * 1.5)
    cornerLeft.Parent = leftPanel
    
    -- Правая панель, где отображается выбранный контент (кнопки, тоглы и т.д.)
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
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
    
    -- Раздел "Этажи"
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
                pcall(function()
                    TeleportService:Teleport(placeId, player)
                end)
            end)
            btn.Parent = contentContainer
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, #FLOORS * (35 * 1.5) + (40 * 1.5))
    end
    
    -- Раздел "Телепорты к мобам"
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
            title.Text = T("noBosses")
            title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(200, 200, 255)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14 * 1.5
            title.Parent = contentContainer
            return
        end
        
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Text = string.format(T("bossesOfFloor"), currentFloor[1], currentFloor[2])
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
                    end
                end
            end)
            btn.Parent = contentContainer
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, #bosses * (35 * 1.5) + (40 * 1.5))
    end
    
    -- Раздел "Телепорт к локациям"
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
            title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
            title.BackgroundTransparency = 1
            title.TextColor3 = Color3.fromRGB(255, 100, 100)
            title.Font = Enum.Font.GothamBold
            title.TextSize = 14 * 1.5
            title.Parent = contentContainer
            return
        end
        
        local headerLabel = Instance.new("TextLabel")
        headerLabel.Text = "Комнаты и Локации: " .. currentFloor[1] .. " (" .. currentFloor[2] .. ")"
        headerLabel.Size = UDim2.new(1, 0, 0, 25 * 1.5)
        headerLabel.BackgroundTransparency = 1
        headerLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
        headerLabel.Font = Enum.Font.GothamBold
        headerLabel.TextSize = 14 * 1.5
        headerLabel.Parent = contentContainer
        
        local extraLocations = EXTRA_LOCATIONS[currentPlaceId] or {}
        local yOffset = 30 * 1.5
        
        if #extraLocations == 0 then
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = "⚠️ Для этого этажа нет дополнительных локаций."
            infoLabel.Size = UDim2.new(1, 0, 0, 20 * 1.5)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 12 * 1.5
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 25 * 1.5
        else
            for i, locData in ipairs(extraLocations) do
                local name, x, y, z = unpack(locData)
                local btn = Instance.new("TextButton")
                btn.Name = "Loc" .. i
                btn.Text = name
                btn.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
                btn.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
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
                        end
                    end
                end)
                btn.Parent = contentContainer
                yOffset = yOffset + 35 * 1.5
            end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    end
    
    -- Раздел "Фарм боссов"
    local function showBossFarms()
        clearContent()
        local currentPlaceId = game.PlaceId
        local farms = BOSS_FARMS[currentPlaceId]
        
        local title = Instance.new("TextLabel")
        title.Text = T("bossFarms")
        title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14 * 1.5
        title.Parent = contentContainer
        
        if not farms or #farms == 0 then
            local noBossLabel = Instance.new("TextLabel")
            noBossLabel.Text = T("noFarms")
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
    
    -- Раздел "Фарм ресурсов"
    local function showMaterialFarm()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("matAndFish")
        title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14 * 1.5
        title.Parent = contentContainer
        
        local selectLabel = Instance.new("TextLabel")
        selectLabel.Text = T("autoOreSelect")
        selectLabel.Size = UDim2.new(1, 0, 0, 20 * 1.5)
        selectLabel.BackgroundTransparency = 1
        selectLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
        selectLabel.Font = Enum.Font.GothamSemibold
        selectLabel.TextSize = 12 * 1.5
        selectLabel.TextXAlignment = Enum.TextXAlignment.Left
        selectLabel.Position = UDim2.new(0, 5 * 1.5, 0, 30 * 1.5)
        selectLabel.Parent = contentContainer
        
        local yOffset = 30 * 1.5 + 25 * 1.5
        local materialsFolder = workspace:FindFirstChild("Materials")
        local foundMaterials = {}
        
        if materialsFolder then
            for _, mat in ipairs(materialsFolder:GetChildren()) do
                if not table.find(foundMaterials, mat.Name) then
                    table.insert(foundMaterials, mat.Name)
                end
            end
        end
        table.sort(foundMaterials)
        
        if #foundMaterials == 0 then
            local noMatLabel = Instance.new("TextLabel")
            noMatLabel.Text = T("noOresFound")
            noMatLabel.Size = UDim2.new(1, 0, 0, 20 * 1.5)
            noMatLabel.BackgroundTransparency = 1
            noMatLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            noMatLabel.Font = Enum.Font.Gotham
            noMatLabel.TextSize = 12 * 1.5
            noMatLabel.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
            noMatLabel.Parent = contentContainer
            yOffset = yOffset + 25 * 1.5
        else
            for _, matName in ipairs(foundMaterials) do
                if selectedMaterials[matName] == nil then
                    selectedMaterials[matName] = false
                end
                
                local switchFrame, _ = createToggleSwitch(
                    contentContainer,
                    matName,
                    selectedMaterials[matName],
                    function(enabled)
                        selectedMaterials[matName] = enabled
                    end
                )
                switchFrame.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
                yOffset = yOffset + 35 * 1.5
            end
        end
        
        local activeSwitch, _ = createToggleSwitch(
            contentContainer,
            T("startFarmBtn"),
            materialFarmActive,
            function(enabled)
                if enabled then
                    local anySelected = false
                    for _, state in pairs(selectedMaterials) do
                        if state then anySelected = true break end
                    end
                    if not anySelected then
                        enabled = false
                    else
                        startMaterialFarm()
                    end
                else
                    stopMaterialFarm()
                end
            end
        )
        activeSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset + 10 * 1.5)
        
        local fishToggle, _ = createToggleSwitch(
            contentContainer,
            T("autoFish"),
            fishFarmActive,
            function(enabled)
                if enabled then
                    startFishFarm()
                else
                    stopFishFarm()
                end
            end
        )
        fishToggle.Position = UDim2.new(0, 5 * 1.5, 0, yOffset + 10 * 1.5 + 45 * 1.5)
        
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10 * 1.5 + 45 * 1.5 + 45 * 1.5)
    end
    
    -- Раздел "Пути" (Загрузка скриптов-путей с GitHub)
    local function showPaths()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = "Пути (Paths)"
        title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14 * 1.5
        title.Parent = contentContainer
        
        local currentPlaceId = game.PlaceId
        local currentFloorData = nil
        
        for _, floorData in ipairs(FLOORS) do
            if floorData[3] == currentPlaceId then
                currentFloorData = floorData
                break
            end
        end
        
        local yOffset = 30 * 1.5
        if not currentFloorData then
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = T("unknownFloor")
            infoLabel.Size = UDim2.new(1, 0, 0, 25 * 1.5)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 14 * 1.5
            infoLabel.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 30 * 1.5
        else
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Text = string.format("Вы на этаже: %s (ID: %d)", currentFloorData[2], currentFloorData[1])
            infoLabel.Size = UDim2.new(1, 0, 0, 20 * 1.5)
            infoLabel.BackgroundTransparency = 1
            infoLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
            infoLabel.Font = Enum.Font.GothamSemibold
            infoLabel.TextSize = 12 * 1.5
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
            infoLabel.Parent = contentContainer
            yOffset = yOffset + 25 * 1.5
            
            local pathsForFloor = nil
            local pathBaseUrl = nil
            
            -- Выбор путей в зависимости от текущего этажа
            if currentFloorData[1] == 2 then
                pathsForFloor = FLOOR_2_PATHS
                pathBaseUrl = PATH_BASE_URL_2
            elseif currentFloorData[1] == 3 then
                pathsForFloor = FLOOR_3_PATHS
                pathBaseUrl = PATH_BASE_URL_3
            elseif currentFloorData[1] == 4 then
                pathsForFloor = FLOOR_4_PATHS
                pathBaseUrl = PATH_BASE_URL_4
            elseif currentFloorData[1] == 5 then
                pathsForFloor = FLOOR_5_PATHS
                pathBaseUrl = PATH_BASE_URL_5
            elseif currentFloorData[1] == 8 then
                pathsForFloor = FLOOR_8_PATHS
                pathBaseUrl = PATH_BASE_URL_8
            elseif currentFloorData[1] == 14 then
                pathsForFloor = FLOOR_14_PATHS
                pathBaseUrl = PATH_BASE_URL_14
            elseif currentFloorData[1] == 16 then
                pathsForFloor = FLOOR_16_PATHS
                pathBaseUrl = PATH_BASE_URL_16
            elseif currentFloorData[1] == 19 then
                pathsForFloor = FLOOR_19_PATHS
                pathBaseUrl = PATH_BASE_URL_19
            end
            
            if not pathsForFloor or next(pathsForFloor) == nil then
                local noPathLabel = Instance.new("TextLabel")
                noPathLabel.Text = T("noPathsForFloor")
                noPathLabel.Size = UDim2.new(1, 0, 0, 1.5)
                noPathLabel.BackgroundTransparency = 1
                noPathLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                noPathLabel.Font = Enum.Font.GothamSemibold
                noPathLabel.TextSize = 14 * 1.5
                noPathLabel.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
                noPathLabel.Parent = contentContainer
                yOffset = yOffset + 30 * 1.5
            else
                for pathName, fileName in pairs(pathsForFloor) do
                    local pathBtn = Instance.new("TextButton")
                    pathBtn.Text = "🗺️ " .. pathName
                    pathBtn.Size = UDim2.new(1, -10 * 1.5, 0, 35 * 1.5)
                    pathBtn.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
                    pathBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    pathBtn.TextColor3 = Color3.fromRGB(200, 255, 200)
                    pathBtn.Font = Enum.Font.GothamBold
                    pathBtn.TextSize = 14 * 1.5
                    pathBtn.AutoButtonColor = true
                    
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 6 * 1.5)
                    corner.Parent = pathBtn
                    
                    -- Загрузка и запуск файла
                    pathBtn.MouseButton1Click:Connect(function()
                        local originalText = pathBtn.Text
                        pathBtn.Text = T("pathLoading")
                        pathBtn.Interactable = false
                        local url = pathBaseUrl .. fileName .. ".lua"
                        
                        local success, result = pcall(function()
                            local scriptCode = game:HttpGet(url)
                            if not scriptCode or scriptCode == "" then
                                error("Файл пуст или не найден (404). Проверь имя файла на GitHub!")
                            end
                            local func = loadstring(scriptCode)
                            if func then
                                func()
                                return true
                            else
                                error("loadstring вернул nil")
                            end
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
                    yOffset = yOffset + 40 * 1.5
                end
            end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset + 10)
    end
    
    -- Раздел "Инструменты" (Фриз, Воскрешение, ESP)
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
        
        -- === НОВОЕ: Кнопка Safe 1 ===
        local safe1Switch, _ = createToggleSwitch(
            contentContainer,
            T("safe1Toggle"),
            safe1Active,
            function(enabled)
                if enabled then
                    startSafe1()
                else
                    stopSafe1()
                end
            end
        )
        safe1Switch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
        yOffset = yOffset + 35 * 1.5
        -- ===========================
        
        local autoWalkSwitch, setAutoWalkState = createToggleSwitch(
            contentContainer,
            T("autoMobWalk"),
            autoWalkActive,
            function(enabled)
                if enabled then
                    startAutoWalk()
                else
                    stopAutoWalk()
                end
            end
        )
        autoWalkSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
        yOffset = yOffset + 35 * 1.5
        
        local freezeSwitch, setFreezeState = createToggleSwitch(contentContainer, T("freezeToggle"), isFrozen, function(enabled)
            toggleFreeze()
        end)
        freezeSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
        yOffset = yOffset + 35 * 1.5
        
        local resSwitch, setResState = createToggleSwitch(contentContainer, T("respawnToggle"), resurrectionActive, function(enabled)
            if enabled then
                setupResurrection()
            else
                cleanupResurrection()
            end
        end)
        resSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
        yOffset = yOffset + 35 * 1.5
        
        local playerListSwitch, _ = createToggleSwitch(contentContainer, T("playerListToggle"), playerListGui ~= nil, function(enabled)
            if enabled then
                createPlayerListGui()
            else
                destroyPlayerListGui()
            end
        end)
        playerListSwitch.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
        yOffset = yOffset + 35 * 1.5
        
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Раздел "Настройки" (Смена языка)
    local function showSettings()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Text = T("languageLabel")
        title.Size = UDim2.new(1, 0, 0, 25 * 1.5)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 14 * 1.5
        title.Parent = contentContainer
        
        local langs = {
            {code = "ru", name = T("lang_ru")},
            {code = "uk", name = T("lang_uk")},
            {code = "kk", name = T("lang_kk")},
            {code = "en", name = T("lang_en")}
        }
        
        local yOffset = 30 * 1.5
        for _, lang in ipairs(langs) do
            local btn = Instance.new("TextButton")
            btn.Text = lang.name
            btn.Size = UDim2.new(1, -10 * 1.5, 0, 30 * 1.5)
            btn.Position = UDim2.new(0, 5 * 1.5, 0, yOffset)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.TextColor3 = Color3.fromRGB(240, 240, 255)
            btn.Font = Enum.Font.GothamSemibold
            btn.TextSize = 14 * 1.5
            btn.AutoButtonColor = true
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 6 * 1.5)
            corner.Parent = btn
            
            btn.MouseButton1Click:Connect(function()
                currentLang = lang.code
                rebuildGUI() -- Полностью перестраиваем GUI на новом языке
            end)
            btn.Parent = contentContainer
            yOffset = yOffset + 35 * 1.5
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, yOffset)
    end
    
    -- Создание кнопок навигации слева
    local floorBtn = createMenuItem(T("floor"), "🌍")
    local teleportsBtn = createMenuItem(T("teleports"), "🌐")
    local bossRoomsBtn = createMenuItem(T("bossRooms"), "🚪")
    local bossFarmBtn = createMenuItem(T("bossFarm"), "👹")
    local materialFarmBtn = createMenuItem(T("materialFarm"), "📦")
    local pathsBtn = createMenuItem(T("paths"), "🗺️")
    local toolsBtn = createMenuItem(T("tools"), "🛠️")
    local settingsBtn = createMenuItem(T("settings"), "⚙️")
    
    -- Подсветка выбранной вкладки
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
    bossRoomsBtn.MouseButton1Click:Connect(function()
        selectButton(bossRoomsBtn)
        showBossRooms()
    end)
    bossFarmBtn.MouseButton1Click:Connect(function()
        selectButton(bossFarmBtn)
        showBossFarms()
    end)
    materialFarmBtn.MouseButton1Click:Connect(function()
        selectButton(materialFarmBtn)
        showMaterialFarm()
    end)
    pathsBtn.MouseButton1Click:Connect(function()
        selectButton(pathsBtn)
        showPaths()
    end)
    toolsBtn.MouseButton1Click:Connect(function()
        selectButton(toolsBtn)
        showConvenience()
    end)
    settingsBtn.MouseButton1Click:Connect(function()
        selectButton(settingsBtn)
        showSettings()
    end)
    
    -- Инициализация первой вкладки при запуске
    selectButton(floorBtn)
    showFloors()
    
    -- Бинд на "G" для скрытия/показа меню
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
end

-- Запуск сборки интерфейса
rebuildGUI()

-- ==============================================================================
-- === ESP (ПОДСВЕТКА ИГРОКОВ: ИМЯ И УРОВЕНЬ) ===
-- ==============================================================================
local Camera = Workspace.CurrentCamera
if not Camera then
    Camera = Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    Camera = Workspace.CurrentCamera
end
local LocalPlayer = Players.LocalPlayer
local EspObjects = {}

-- Удаление ESP при выходе игрока
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

-- Перевод 3D-координат в 2D (координаты экрана)
local function toScreen(point)
    local pos, onScreen = Camera:WorldToViewportPoint(point)
    return Vector2.new(pos.X, pos.Y), onScreen
end

-- Обновление ESP рамок и текста
local function updateEsp(player)
    if player == LocalPlayer or not player.Character then return end
    local character = player.Character
    local head = character:FindFirstChild("Head")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    
    if not head or not rootPart then return end
    
    local headPos, headVisible = toScreen(head.Position)
    local rootPos, rootVisible = toScreen(rootPart.Position)
    
    -- Если игрок не на экране, скрываем ESP
    if not (headVisible and rootVisible) then
        if EspObjects[player] then
            for _, obj in pairs(EspObjects[player]) do
                if obj then obj.Visible = false end
            end
        end
        return
    end
    
    -- Расчеты для рамки
    local footOffset = Vector3.new(0, -3, 0)
    local feetWorld = rootPart.Position + footOffset
    local feetPos, _ = toScreen(feetWorld)
    local fullHeight = math.abs(headPos.Y - feetPos.Y)
    local scaledHeight = fullHeight * 1.5
    local width = scaledHeight * 0.6
    local centerY = (headPos.Y + feetPos.Y) / 2
    local boxY = centerY - scaledHeight / 2
    local boxX = headPos.X - width / 2
    
    -- Создаем объекты Drawing, если их еще нет
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
        
        EspObjects[player] = {box = box, name = nameText, level = levelText}
    end
    
    -- Применяем координаты и размеры
    local esp = EspObjects[player]
    esp.box.Size = Vector2.new(width, scaledHeight)
    esp.box.Position = Vector2.new(boxX, boxY)
    esp.box.Visible = true
    
    -- Логика подсветки особых игроков (по никам)
    if player.Name == "huesos880055535" then
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        esp.level.Text = "Lvl: Dominus"
        esp.level.Color = Color3.fromRGB(138, 43, 226)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    elseif player.Name == "ArRoWeNn" then
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        esp.level.Text = "Lvl: Immortal"
        esp.level.Color = Color3.fromRGB(255, 215, 0)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    elseif player.Name == "Minikokosich" then
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        esp.level.Text = "Lvl: Guardian"
        esp.level.Color = Color3.fromRGB(30, 144, 255)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    elseif player.Name == "CuRLyCHeBuRaSHKa" then
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        esp.level.Text = "Lvl: Cuddle"
        esp.level.Color = Color3.fromRGB(255, 20, 147)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    elseif player.Name == "luken_god" then
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        esp.level.Text = "Lvl: 12000"
        esp.level.Color = Color3.fromRGB(0, 255, 0)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    else
        esp.name.Text = player.Name
        esp.name.Position = Vector2.new(headPos.X, headPos.Y - 25)
        esp.name.Visible = true
        local level = getPlayerLevel(player)
        esp.level.Text = "Lvl: " .. tostring(level)
        esp.level.Color = Color3.fromRGB(0, 255, 255)
        esp.level.Position = Vector2.new(headPos.X, headPos.Y - 5)
        esp.level.Visible = true
    end
end

-- Удаление ESP при выходе игрока
Players.PlayerRemoving:Connect(removeEsp)

-- Подключение ESP ко всем текущим игрокам
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

-- Подключение ESP к заходящим игрокам
Players.PlayerAdded:Connect(function(player)
    if player == LocalPlayer then return end
    spawn(function()
        while player and player.Character do
            updateEsp(player)
            RunService.RenderStepped:Wait()
        end
    end)
end)

-- Основной цикл обновления ESP каждый кадр
RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateEsp(player)
    end
end)
