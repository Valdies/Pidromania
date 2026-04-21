local SBOR = {
    [4733278992] = true,
    [4733293382] = true,
    [4734865416] = true,
    [4735703075] = true,
    [4735718710] = true,
    [4736649014] = true,
    [4736759720] = true,
    [4736984932] = true,
    [4737916764] = true,
    [4740039076] = true,
    [4747247314] = true,
    [5135551944] = true,
    [5212666689] = true,
    [5136611550] = true,
    [4733293091] = true,
    [11987483716] = true,
    [11987539001] = true,
    [12632324801] = true,
    [94066307314492] = true,
    [117852524597461] = true,
    [130463264320898] = true
}

local BF = {
    [100117331123089] = true,
    [79091703265657] = true,
    [85211729168715] = true
}

local whitelistedUserIds = {
    [2964047089] = true, -- Кент (@VanAstrales)
    [9103392112] = true, -- Я (@huesos880055535)
    [493337194]  = true, -- Кокосик (@Minikokosich)
    [4607304028] = true, -- Саня (@ArRoWeNn)
    [3270959865] = true, -- Влад (@luken_god)
    [8656482649] = true, -- Лена2 (@TaCamayaLena28)
    [4550232169] = true, -- Петя (@Dog03071)
    [7947437575] = true, -- Вика (@CuRLyCHeBuRaSHKa)
    [1205348792] = true,
    [10462778979] = true, -- Отсосаня 2.0
    [9715547061] = true, -- Тянка какая то (@make_legend2)
    [1923012479] = true  -- Лена1 (@82Lena28)
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if whitelistedUserIds[LocalPlayer.UserId] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/mid/Loading.txt"))()
    wait(10)
    if game.PlaceId == 136599248168660 then
        print("Pidromania Hub soon")

    elseif game.PlaceId == 7554888362 or game.PlaceId == 7559074529 then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/Squid%20Game%20X"))()

    elseif BF[game.PlaceId] then
        -- loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/obf_PidromaniaHub%20-%20BloxFruits.lua"))()

    elseif SBOR[game.PlaceId] then
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/PidHubWork"))()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/Message"))()

    else
        print("Pidromania Hub soon")
    end

else
    --loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/PidHubWork"))()
    --loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/BanNahuy"))()
end
