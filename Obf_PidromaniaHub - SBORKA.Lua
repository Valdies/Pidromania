local baseUrl = "https://raw.githubusercontent.com/Valdies/Pidromania/main/"
local WL_PAH_ID = 10880639270

local GAME_REGISTRY = {
    -- Squid Game X
    [7554888362] = "Games/Squid%20Game%20X/Squid%20Game%20X.lua",
    [7559074529] = "Games/Squid%20Game%20X/Squid%20Game%20X.lua",
    
    -- Blox Fruits
    [100117331123089] = "Games/Blox%20Fruits/BloxFruits.lua",
    [79091703265657] = "Games/Blox%20Fruits/BloxFruits.lua",
    [85211729168715] = "Games/Blox%20Fruits/BloxFruits.lua",
    [73902483975735] = "Games/Blox%20Fruits/BloxFruits.lua",
    
    -- The Apocalypse
    [75519253084635] = "Games/The%20Apocalypse/The%20Apocalypse.lua",
    
    -- SBOR
    [10299594856] = "Games/SBOR/SBOR.lua", [4733278992] = "Games/SBOR/SBOR.lua",
    [4733293382] = "Games/SBOR/SBOR.lua", [4734865416] = "Games/SBOR/SBOR.lua",
    [4735703075] = "Games/SBOR/SBOR.lua", [4735718710] = "Games/SBOR/SBOR.lua",
    [4736649014] = "Games/SBOR/SBOR.lua", [4736759720] = "Games/SBOR/SBOR.lua",
    [4736984932] = "Games/SBOR/SBOR.lua", [4737916764] = "Games/SBOR/SBOR.lua",
    [4740039076] = "Games/SBOR/SBOR.lua", [4747247314] = "Games/SBOR/SBOR.lua",
    [5135551944] = "Games/SBOR/SBOR.lua", [5212666689] = "Games/SBOR/SBOR.lua",
    [5136611550] = "Games/SBOR/SBOR.lua", [4733293091] = "Games/SBOR/SBOR.lua",
    [11987483716] = "Games/SBOR/SBOR.lua", [11987539001] = "Games/SBOR/SBOR.lua",
    [12632324801] = "Games/SBOR/SBOR.lua", [94066307314492] = "Games/SBOR/SBOR.lua",
    [117852524597461] = "Games/SBOR/SBOR.lua", [130463264320898] = "Games/SBOR/SBOR.lua"
}

local whitelistedUserIds = {
    [10829797796] = true,
    [1923012479] = true,
    [8656482649] = true
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function exec(path)
    local s, res = pcall(function() return game:HttpGet(baseUrl .. path) end)
    if s and res then
        loadstring(res)()
    end
end

local isVip = whitelistedUserIds[LocalPlayer.UserId]
local isFriend = false
pcall(function() isFriend = LocalPlayer:IsFriendsWith(WL_PAH_ID) end)

if isFriend or isVip then
    local scriptPath = GAME_REGISTRY[game.PlaceId]
    
    if scriptPath then
        exec(scriptPath)
        if string.find(scriptPath, "SBOR") then
            exec("BrainTools/Message.lua")
        end
    else
        exec("BrainTools/NoGame.lua")
    end
else
    exec("BrainTools/NoWhite.lua")
    task.wait(5)
    LocalPlayer:Kick("\n[Pidromania Airlines]\nAccess Denied. Write to @Pidromania")
end
