-- Конфигурация путей
local baseUrl = "https://raw.githubusercontent.com/Valdies/Pidromania/main/"

-- Таблицы идентификаторов (оставь свои актуальные данные)
local SBOR_IDS = {
    [10299594856] = true, [4733278992] = true, [4733293382] = true,
    [4734865416] = true, [4735703075] = true, [4735718710] = true,
    [4736649014] = true, [4736759720] = true, [4736984932] = true,
    [4737916764] = true, [4740039076] = true, [4747247314] = true,
    [5135551944] = true, [5212666689] = true, [5136611550] = true,
    [4733293091] = true, [11987483716] = true, [11987539001] = true,
    [12632324801] = true, [94066307314492] = true, [117852524597461] = true,
    [130463264320898] = true
}

local BF_IDS = {
    [100117331123089] = true, [79091703265657] = true, [85211729168715] = true
}

local whitelistedUserIds = {
    [2964047089] = true, [493337194]  = true, [4607304028] = true,
    [3270959865] = true, [4550232169] = true, [7947437575] = true,
    [1205348792] = true, [10462778979] = true, [9715547061] = true,
    [9103392112] = true, [1923012479] = true, [8656482649] = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Универсальная функция загрузки
local function exec(path)
    loadstring(game:HttpGet(baseUrl .. path))()
end

-- ПРОВЕРКА ДОСТУПА И ЗАПУСК
if whitelistedUserIds[LocalPlayer.UserId] then
    -- Запуск загрузочного экрана из BrainTools 
    exec("BrainTools/Loading.lua") 
    task.wait(8.5)

    -- Логика выбора игры согласно твоим новым папкам [cite: 6]
    if game.PlaceId == 136599248168660 then
        print("Pidromania Hub soon")

    elseif game.PlaceId == 7554888362 or game.PlaceId == 7559074529 then
        -- Squid Game X [cite: 11]
        exec("Games/Squid%20Game%20X/Squid%20Game%20X.lua")

    elseif BF_IDS[game.PlaceId] then
        -- Blox Fruits [cite: 7]
        exec("Games/Blox%20Fruits/BloxFruits.lua")

    elseif SBOR_IDS[game.PlaceId] then
        -- SBO:R (теперь с правильным названием файла) 
        exec("Games/SBOR/SBOR.lua")
        exec("BrainTools/Message.lua")

    else
        -- Если игра не поддерживается 
        exec("BrainTools/NoGame.lua")
    end
else
    -- Если игрока нет в вайтлисте 
    exec("BrainTools/NoWhite.lua")
end
