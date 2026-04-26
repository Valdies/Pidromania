local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local placeId = game.PlaceId

-- Функция для безопасной телепортации
local function teleportToY(yPos)
    -- Обновляем ссылку на персонажа и корень, на случай респауна
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            -- Сохраняем X и Z координаты, меняем только Y
            local currentPos = HumanoidRootPart.Position
            local targetCFrame = CFrame.new(currentPos.X, yPos, currentPos.Z)
            HumanoidRootPart.CFrame = targetCFrame
        end
    end
end

if placeId == 7554888362 then
    local targetCFrame = CFrame.new(313.93, 18.07, -619.43)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = targetCFrame
    end
elseif placeId == 7559074529 then
    task.wait(60)
    teleportToY(-20000)
    task.wait(0.5)
    
    teleportToY(-30000)
    task.wait(0.5)
    
    teleportToY(-40000)
    task.wait(0.5)
    
    teleportToY(-49000)
end
