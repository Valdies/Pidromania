local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local placeId = game.PlaceId
if placeId == 7554888362 then
    local targetCFrame = CFrame.new(313.93, 18.07, -619.43)
    if HumanoidRootPart then
        HumanoidRootPart.CFrame = targetCFrame
    end
elseif placeId == 7559074529 then
    task.wait(30)
    local targetCFrame = CFrame.new(8037.54, -20000, 3718.87)
    Character = LocalPlayer.Character
    if Character then
        HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart then
            HumanoidRootPart.CFrame = targetCFrame
        end
    end
end
