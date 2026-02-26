local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_Тест"
local lineColor = Color3.new(1, 0, 0) -- Красный цвет линий пути
local pointColor = Color3.new(0, 1, 0) -- Зеленый цвет точек
local dynamicLineColor = Color3.new(0, 0.5, 1) -- Синий цвет линии до игрока
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

-- Новые координаты от Леночки (Старт + 53 точки)
local points = {
    Vector3.new(-140.92, 2421.37, -75.23), -- Старт
    Vector3.new(-124.93, 2421.25, -74.68),
    Vector3.new(-83.12, 2421.25, -73.55),
    Vector3.new(-34.95, 2421.25, -73.13),
    Vector3.new(10.88, 2421.25, -72.73),
    Vector3.new(37.70, 2421.25, -61.69),
    Vector3.new(70.82, 2421.25, -70.54),
    Vector3.new(110.78, 2421.25, -73.96),
    Vector3.new(151.44, 2421.25, -72.89),
    Vector3.new(191.93, 2421.25, -72.59),
    Vector3.new(232.59, 2421.25, -72.94),
    Vector3.new(274.38, 2422.60, -75.04),
    Vector3.new(314.34, 2426.72, -82.56),
    Vector3.new(350.93, 2424.58, -91.66),
    Vector3.new(389.19, 2415.60, -101.79),
    Vector3.new(431.44, 2417.98, -113.34),
    Vector3.new(468.41, 2412.48, -123.60),
    Vector3.new(503.56, 2408.77, -133.34),
    Vector3.new(537.86, 2418.11, -143.74),
    Vector3.new(569.94, 2412.02, -155.45),
    Vector3.new(608.99, 2411.23, -170.67),
    Vector3.new(645.81, 2415.79, -185.54),
    Vector3.new(679.14, 2425.33, -199.01),
    Vector3.new(700.39, 2430.58, -207.59),
    Vector3.new(723.08, 2431.37, -216.76),
    Vector3.new(747.07, 2431.10, -226.46),
    Vector3.new(776.65, 2424.35, -238.41),
    Vector3.new(807.85, 2416.41, -251.01),
    Vector3.new(830.53, 2402.76, -260.17),
    Vector3.new(847.58, 2392.83, -267.06),
    Vector3.new(876.10, 2382.54, -278.82),
    Vector3.new(895.57, 2378.54, -286.89),
    Vector3.new(930.52, 2375.98, -301.37),
    Vector3.new(964.72, 2368.99, -315.53),
    Vector3.new(995.27, 2359.00, -328.19),
    Vector3.new(1025.77, 2351.42, -341.36),
    Vector3.new(1047.01, 2318.94, -349.37),
    Vector3.new(1062.43, 2291.01, -353.80),
    Vector3.new(1092.31, 2199.47, -359.48),
    Vector3.new(1118.60, 2206.59, -369.57),
    Vector3.new(1146.10, 2206.77, -382.58),
    Vector3.new(1167.65, 2198.34, -402.87),
    Vector3.new(1193.36, 2199.12, -425.18),
    Vector3.new(1223.74, 2201.21, -439.09),
    Vector3.new(1258.63, 2208.16, -451.45),
    Vector3.new(1296.12, 2201.35, -464.98),
    Vector3.new(1326.96, 2202.29, -483.95),
    Vector3.new(1354.06, 2200.43, -504.10),
    Vector3.new(1378.25, 2198.48, -525.79),
    Vector3.new(1400.31, 2204.92, -550.10),
    Vector3.new(1421.64, 2203.88, -575.72),
    Vector3.new(1441.97, 2204.50, -603.00),
    Vector3.new(1459.18, 2213.15, -637.00),
    Vector3.new(1450.53, 2212.04, -668.92) -- Финиш
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