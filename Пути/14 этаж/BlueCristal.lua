local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_Кристалл"
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
    Vector3.new(8888.20, 2955.69, 1839.83),
    Vector3.new(8894.50, 2958.12, 1901.99),
    Vector3.new(8903.80, 2952.39, 1919.38),
    Vector3.new(8912.44, 2939.40, 1938.63),
    Vector3.new(8920.87, 2920.51, 1958.28),
    Vector3.new(8926.01, 2900.30, 1972.83),
    Vector3.new(8932.85, 2888.23, 1993.95),
    Vector3.new(8939.26, 2880.47, 2015.73),
    Vector3.new(8945.05, 2876.66, 2040.34),
    Vector3.new(8950.16, 2864.32, 2063.42),
    Vector3.new(8954.31, 2858.41, 2084.74),
    Vector3.new(8958.46, 2858.93, 2110.83),
    Vector3.new(8960.36, 2854.33, 2136.74),
    Vector3.new(8962.32, 2842.44, 2161.79),
    Vector3.new(8965.37, 2827.57, 2186.80),
    Vector3.new(8967.64, 2817.97, 2205.26),
    Vector3.new(8971.07, 2816.53, 2233.04),
    Vector3.new(8974.47, 2823.64, 2261.00),
    Vector3.new(8977.61, 2827.52, 2286.69),
    Vector3.new(8980.78, 2827.46, 2312.17),
    Vector3.new(8985.58, 2817.75, 2336.42),
    Vector3.new(8994.15, 2807.77, 2360.37),
    Vector3.new(9000.76, 2799.81, 2384.15),
    Vector3.new(9006.75, 2791.45, 2410.59),
    Vector3.new(9012.13, 2778.47, 2435.68),
    Vector3.new(9016.73, 2769.18, 2460.41),
    Vector3.new(9021.57, 2765.67, 2488.03),
    Vector3.new(9025.58, 2778.77, 2510.78),
    Vector3.new(9029.44, 2784.26, 2538.55),
    Vector3.new(9039.55, 2788.30, 2561.48),
    Vector3.new(9042.64, 2803.33, 2582.18),
    Vector3.new(9047.24, 2818.86, 2606.76),
    Vector3.new(9055.83, 2829.63, 2629.91),
    Vector3.new(9060.96, 2834.54, 2655.52),
    Vector3.new(9071.24, 2845.11, 2678.14),
    Vector3.new(9082.63, 2851.92, 2705.45),
    Vector3.new(9087.93, 2861.67, 2728.88),
    Vector3.new(9090.27, 2871.64, 2752.54),
    Vector3.new(9093.78, 2877.75, 2781.58),
    Vector3.new(9096.75, 2877.89, 2804.60),
    Vector3.new(9103.54, 2875.44, 2832.37),
    Vector3.new(9109.92, 2866.24, 2856.75),
    Vector3.new(9115.73, 2851.52, 2875.96),
    Vector3.new(9127.84, 2833.79, 2891.51),
    Vector3.new(9142.55, 2824.08, 2908.17),
    Vector3.new(9146.75, 2822.23, 2918.98),
    Vector3.new(9144.07, 2817.27, 2929.14),
    Vector3.new(9148.36, 2812.64, 2944.51),
    Vector3.new(9159.51, 2773.10, 2965.75),
    Vector3.new(9170.79, 2768.51, 2984.62),
    Vector3.new(9184.26, 2765.05, 3004.67),
    Vector3.new(9192.23, 2773.11, 3030.44),
    Vector3.new(9197.37, 2765.05, 3053.65),
    Vector3.new(9202.92, 2771.23, 3070.18),
    Vector3.new(9206.22, 2773.11, 3089.92),
    Vector3.new(9215.57, 2765.05, 3129.32)
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