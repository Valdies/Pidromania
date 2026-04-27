local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local placeId = game.PlaceId

local function teleportToY(yPos)
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            local currentPos = HumanoidRootPart.Position
            HumanoidRootPart.CFrame = CFrame.new(currentPos.X, yPos, currentPos.Z)
        end
    end
end

if placeId == 7554888362 then
    -- Если уже там, просто ставим на точку
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = CFrame.new(313.93, 18.07, -619.43)
    end
    
elseif placeId == 7559074529 then
    -- Падаем
    task.wait(60)
    teleportToY(-20000)
    task.wait(0.5)
    teleportToY(-30000)
    task.wait(0.5)
    teleportToY(-40000)
    task.wait(0.5)
    teleportToY(-49000)

    -- Ждем 1600 секунд
    task.wait(1600)

    -- Телепортируем в другой мир (тихо, без ошибок в консоли)
    -- Используем pcall, чтобы скрыть возможные ошибки
    pcall(function()
        -- Попробуй одну из этих строк, раскомментируй нужную под свой инжектор:
        
        -- Вариант для большинства современных эксплоитов (Synapse, Script-Ware, Fluxus):
        if syn and syn.teleport then syn.teleport(7554888362) return end
        
        -- Вариант для некоторых других:
        if teleport then teleport(7554888362) return end
        
        -- Стандартный (часто не работает на клиенте, но попробуем):
        game:GetService("TeleportService"):Teleport(7554888362, LocalPlayer)
    end)
end
