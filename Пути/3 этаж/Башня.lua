local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_Финал_216"
local lineColor = Color3.new(1, 0, 0)
local pointColor = Color3.new(0, 1, 0)
local dynamicLineColor = Color3.new(0, 0.5, 1)
local lineWidth = 0.2
local pointSize = 0.8
local activationRadius = 10

local pathFolder = Workspace:FindFirstChild(folderName)
if pathFolder then
    pathFolder:Destroy()
end
pathFolder = Instance.new("Folder")
pathFolder.Name = folderName
pathFolder.Parent = Workspace

local points = {
    Vector3.new(-1062.84, 109.42, -16.72),
    Vector3.new(-1045.77, 106.40, -10.92),
    Vector3.new(-1005.55, 104.93, -2.92),
    Vector3.new(-964.08, 104.84, 2.23),
    Vector3.new(-938.71, 101.00, 7.69),
    Vector3.new(-901.89, 95.28, 20.17),
    Vector3.new(-866.82, 92.06, 40.13),
    Vector3.new(-832.55, 92.27, 56.43),
    Vector3.new(-806.79, 98.34, 70.29),
    Vector3.new(-775.61, 108.02, 87.30),
    Vector3.new(-740.30, 112.22, 109.32),
    Vector3.new(-705.96, 120.19, 131.40),
    Vector3.new(-668.30, 117.52, 147.97),
    Vector3.new(-633.73, 114.60, 161.67),
    Vector3.new(-595.04, 109.46, 176.38),
    Vector3.new(-557.25, 97.57, 187.13),
    Vector3.new(-539.73, 90.54, 186.44),
    Vector3.new(-493.41, 89.00, 184.73),
    Vector3.new(-460.18, 92.20, 183.78),
    Vector3.new(-418.70, 94.09, 182.69),
    Vector3.new(-382.22, 100.03, 183.81),
    Vector3.new(-331.29, 109.19, 198.28),
    Vector3.new(-292.26, 101.40, 211.43),
    Vector3.new(-254.64, 102.69, 224.32),
    Vector3.new(-216.93, 104.28, 239.05),
    Vector3.new(-184.98, 98.72, 256.31),
    Vector3.new(-150.78, 91.70, 280.75),
    Vector3.new(-122.10, 90.67, 306.33),
    Vector3.new(-85.31, 92.03, 317.88),
    Vector3.new(-46.40, 96.30, 333.81),
    Vector3.new(-6.93, 101.00, 349.45),
    Vector3.new(25.62, 97.56, 362.02),
    Vector3.new(55.95, 94.24, 373.65),
    Vector3.new(77.84, 97.01, 381.60),
    Vector3.new(100.77, 100.37, 388.26),
    Vector3.new(130.76, 97.42, 393.30),
    Vector3.new(159.36, 104.37, 399.11),
    Vector3.new(202.79, 108.03, 412.57),
    Vector3.new(243.72, 103.80, 423.87),
    Vector3.new(287.43, 101.18, 430.63),
    Vector3.new(325.73, 99.78, 435.13),
    Vector3.new(363.65, 102.02, 439.94),
    Vector3.new(401.66, 100.13, 438.45),
    Vector3.new(444.96, 106.16, 435.26),
    Vector3.new(485.70, 105.04, 431.92),
    Vector3.new(526.13, 112.31, 431.58),
    Vector3.new(568.65, 113.54, 434.20),
    Vector3.new(607.90, 115.32, 437.92),
    Vector3.new(643.80, 115.17, 445.64),
    Vector3.new(680.59, 119.88, 462.33),
    Vector3.new(709.18, 114.40, 481.84),
    Vector3.new(738.32, 106.93, 503.90),
    Vector3.new(765.35, 99.11, 531.23),
    Vector3.new(790.61, 96.33, 557.03),
    Vector3.new(816.78, 99.12, 583.58),
    Vector3.new(848.88, 92.78, 609.79),
    Vector3.new(884.58, 83.60, 629.82),
    Vector3.new(921.31, 80.71, 646.63),
    Vector3.new(961.71, 74.81, 660.49),
    Vector3.new(997.72, 80.74, 671.25)
}

local cleanupTable = {}
local activePoints = {}

local dynamicLinePart = Instance.new("Part")
dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, 0)
dynamicLinePart.Anchored = true
dynamicLinePart.CanCollide = false
dynamicLinePart.Color = dynamicLineColor
dynamicLinePart.Material = Enum.Material.Neon
dynamicLinePart.Name = "DynamicLine_PlayerToTarget"
dynamicLinePart.Parent = pathFolder

local function createLine(part0, part1, index)
    local distance = (part1 - part0).Magnitude
    local middleCFrame = CFrame.lookAt(part0, part1) * CFrame.new(0, 0, -distance / 2)
    local linePart = Instance.new("Part")
    linePart.Size = Vector3.new(lineWidth, lineWidth, distance)
    linePart.CFrame = middleCFrame
    linePart.Anchored = true
    linePart.CanCollide = false
    linePart.Color = lineColor
    linePart.Material = Enum.Material.Neon
    linePart.Name = "Line_Segment_" .. index
    linePart.Parent = pathFolder
    return {linePart}
end

local function createPoint(pos, labelText, index)
    local pointPart = Instance.new("Part")
    pointPart.Shape = Enum.PartType.Ball
    pointPart.Size = Vector3.new(pointSize, pointSize, pointSize)
    pointPart.CFrame = CFrame.new(pos)
    pointPart.Anchored = true
    pointPart.CanCollide = false
    pointPart.Color = pointColor
    pointPart.Material = Enum.Material.Neon
    pointPart.Name = "Point_" .. labelText
    pointPart.Parent = pathFolder

    local light = Instance.new("PointLight")
    light.Color = pointColor
    light.Brightness = 2
    light.Range = 10
    light.Parent = pointPart

    local partsToDelete = {pointPart, light}

    activePoints[index] = {
        pos = pos,
        label = labelText,
        part = pointPart
    }

    return partsToDelete
end

for i = 1, #points do
    local currentIndex = i - 1
    local pos = points[i]
    local pointLabel = ""
    if currentIndex == 0 then
        pointLabel = "Start"
    elseif currentIndex == #points - 1 then
        pointLabel = "Finish"
    else
        pointLabel = tostring(currentIndex)
    end

    if not cleanupTable[currentIndex] then
        cleanupTable[currentIndex] = {}
    end

    local pointParts = createPoint(pos, pointLabel, currentIndex)
    for _, p in ipairs(pointParts) do
        table.insert(cleanupTable[currentIndex], p)
    end

    if i > 1 then
        local prevIndex = currentIndex - 1
        local lineParts = createLine(points[i-1], pos, currentIndex)
        
        if cleanupTable[prevIndex] then
            for _, p in ipairs(lineParts) do
                table.insert(cleanupTable[prevIndex], p)
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local playerPos = rootPart.Position
    local closestDist = math.huge
    local targetPos = nil
    local targetIndex = nil

    for idx, data in pairs(activePoints) do
        if data.part and data.part.Parent then
            local dist = (data.pos - playerPos).Magnitude
            
            if dist < closestDist then
                closestDist = dist
                targetPos = data.pos
                targetIndex = idx
            end

            if dist <= activationRadius then
                activePoints[idx] = nil
                
                for i = 0, idx do
                    if cleanupTable[i] then
                        for _, part in ipairs(cleanupTable[i]) do
                            if part and part.Parent then
                                part:Destroy()
                            end
                        end
                        cleanupTable[i] = nil
                    end
                end
                
                if data.label == "Finish" then
                    dynamicLinePart.Transparency = 1
                end
                
                break 
            end
        end
    end

    if targetPos and activePoints[targetIndex] then
        dynamicLinePart.Transparency = 0
        local distance = (targetPos - playerPos).Magnitude
        
        dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, distance)
        dynamicLinePart.CFrame = CFrame.lookAt(playerPos, targetPos) * CFrame.new(0, 0, -distance / 2)
    else
        dynamicLinePart.Transparency = 1
    end
end)