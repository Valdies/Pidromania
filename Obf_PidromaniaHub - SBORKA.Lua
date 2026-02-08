local whitelistedUserIds = {
    [2964047089] = true,
    [9103392112] = true,
    [493337194]  = true,
    [4607304028] = true,
    [3270959865] = true,
    [7947437575] = true 
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

if whitelistedUserIds[LocalPlayer.UserId] then
    -- Загрузка основных скриптов для друзей
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/PidHubWork"))()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/Message"))()
else
    -- Загрузка "BanNahuy" для остальных
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Valdies/Pidromania/refs/heads/main/BanNahuy"))()
end

