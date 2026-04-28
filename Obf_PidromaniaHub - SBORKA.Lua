-- Конфигурация путей
local baseUrl = "https://raw.githubusercontent.com/Valdies/Pidromania/main/"

-- Таблицы идентификаторов игр (Place IDs)
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

-- Список близких друзей (VIP)
local whitelistedUserIds = {
    [2964047089] = true, -- Кент
    [493337194]  = true, -- Кокосик
    [4607304028] = true, -- Саня
    [3270959865] = true, -- Влад
    [4550232169] = true, -- Петя
    [7947437575] = true, -- Вика
    [1205348792] = true, -- vvcbbhg
    [10462778979] = true, -- Отсосаня 2.0
    [9715547061] = true, -- Тянка какая то
    [9103392112] = true, -- Я
    [1923012479] = true, -- Лена1
    [8656482649] = true  -- Лена2
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Универсальная функция загрузки
local function exec(path)
    local s, res = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if s and res then
        loadstring(res)()
    end
end

---------------------------------------------------------
-- ЛОГИКА РАСПРЕДЕЛЕНИЯ
---------------------------------------------------------

if whitelistedUserIds[LocalPlayer.UserId] then
    -- ДЛЯ ДРУЗЕЙ: Мгновенный запуск без Loading
    
    if game.PlaceId == 136599248168660 then
        print("Pidromania Hub soon")

    elseif game.PlaceId == 7554888362 or game.PlaceId == 7559074529 then
        -- Squid Game X
        exec("Games/Squid%20Game%20X/Squid%20Game%20X.lua")

    elseif BF_IDS[game.PlaceId] then
        -- Blox Fruits
        exec("Games/Blox%20Fruits/BloxFruits.lua")

    elseif SBOR_IDS[game.PlaceId] then
        -- SBO:R
        exec("Games/SBOR/SBOR.lua")
        exec("BrainTools/Message.lua")

    else
        -- Если игры нет в списке поддержки
        exec("BrainTools/NoGame.lua")
    end
else
    -- ДЛЯ ЧУЖИХ (если запустили мозг напрямую):
    -- Подгружаем NoWhite, ждем 5 сек и кикаем
    exec("BrainTools/NoWhite.lua")
    task.wait(5)
    LocalPlayer:Kick("\n[Pidromania Airlines]\nAccess Denied. Write to @Pidromania")
end
