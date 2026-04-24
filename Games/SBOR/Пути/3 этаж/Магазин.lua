local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_Тест"
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

-- Новые координаты от Леночки
local points = {
    Vector3.new(-1059.60, 106.37, -9.47),
    Vector3.new(-1041.86, 106.52, -8.25),
    Vector3.new(-1017.29, 112.44, -28.28),
    Vector3.new(-1004.98, 114.03, -66.16),
    Vector3.new(-1007.27, 112.03, -106.41),
    Vector3.new(-1012.24, 104.87, -159.18),
    Vector3.new(-1015.79, 115.48, -194.03),
    Vector3.new(-1017.68, 117.16, -212.50),
    Vector3.new(-1014.97, 109.65, -240.30),
    Vector3.new(-1000.21, 107.10, -274.81),
    Vector3.new(-991.09, 114.53, -294.17),
    Vector3.new(-974.71, 125.47, -318.20),
    Vector3.new(-949.65, 129.27, -342.65),
    Vector3.new(-922.91, 118.68, -354.76),
    Vector3.new(-901.01, 116.94, -374.08),
    Vector3.new(-881.59, 109.36, -392.44),
    Vector3.new(-854.07, 103.32, -409.90),
    Vector3.new(-821.84, 104.28, -430.97),
    Vector3.new(-785.18, 102.30, -451.12),
    Vector3.new(-749.52, 98.88, -467.12),
    Vector3.new(-713.89, 100.94, -481.72),
    Vector3.new(-685.28, 102.78, -498.08),
    Vector3.new(-654.37, 101.01, -523.22),
    Vector3.new(-634.57, 102.05, -543.64),
    Vector3.new(-610.18, 106.39, -578.17),
    Vector3.new(-590.95, 109.78, -607.98),
    Vector3.new(-575.83, 114.80, -640.01),
    Vector3.new(-567.33, 115.83, -673.93),
    Vector3.new(-572.55, 111.67, -709.66),
    Vector3.new(-588.52, 101.17, -735.03),
    Vector3.new(-608.30, 83.23, -761.68),
    Vector3.new(-628.81, 77.78, -793.04),
    Vector3.new(-643.28, 76.34, -823.60),
    Vector3.new(-657.73, 76.21, -856.64),
    Vector3.new(-665.64, 70.82, -895.41),
    Vector3.new(-689.13, 78.40, -935.80),
    Vector3.new(-724.42, 76.08, -934.25),
    Vector3.new(-769.56, 73.86, -934.93),
    Vector3.new(-809.44, 78.31, -930.31),
    Vector3.new(-852.58, 77.14, -929.28),
    Vector3.new(-893.65, 74.63, -924.26),
    Vector3.new(-934.13, 70.74, -915.12),
    Vector3.new(-968.25, 67.82, -906.06)
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