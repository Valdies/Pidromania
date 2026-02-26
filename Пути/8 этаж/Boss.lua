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

-- Огромный маршрут от Леночки (114 точек)
local points = {
    Vector3.new(2691.75, -654.41, 467.35), -- Старт (Точка 1)
    Vector3.new(2693.90, -654.41, 457.21),
    Vector3.new(2698.80, -654.41, 430.84),
    Vector3.new(2703.41, -662.06, 398.00),
    Vector3.new(2707.87, -662.45, 366.14),
    Vector3.new(2712.78, -662.45, 329.80),
    Vector3.new(2717.15, -662.45, 295.58),
    Vector3.new(2721.78, -662.45, 260.38),
    Vector3.new(2726.82, -662.45, 222.04),
    Vector3.new(2731.95, -662.45, 183.04),
    Vector3.new(2736.90, -662.45, 145.37),
    Vector3.new(2741.78, -662.93, 111.71),
    Vector3.new(2748.72, -653.27, 94.19),
    Vector3.new(2748.31, -646.98, 89.57),
    Vector3.new(2748.78, -640.76, 85.97),
    Vector3.new(2750.95, -634.35, 69.47),
    Vector3.new(2755.48, -651.12, 35.90),
    Vector3.new(2757.20, -663.28, 16.95),
    Vector3.new(2758.38, -663.18, -1.31),
    Vector3.new(2777.40, -663.18, -4.63),
    Vector3.new(2799.38, -663.32, -22.73),
    Vector3.new(2764.74, -663.32, -50.21),
    Vector3.new(2747.79, -663.32, -83.91),
    Vector3.new(2778.14, -663.32, -113.93),
    Vector3.new(2748.01, -663.32, -143.45),
    Vector3.new(2748.71, -663.18, -166.40),
    Vector3.new(2751.24, -663.13, -190.63),
    Vector3.new(2752.55, -663.13, -217.93),
    Vector3.new(2753.60, -663.13, -247.91),
    Vector3.new(2755.26, -663.13, -279.20),
    Vector3.new(2758.51, -663.16, -307.64),
    Vector3.new(2763.47, -663.13, -334.51),
    Vector3.new(2769.37, -663.16, -360.51),
    Vector3.new(2777.79, -663.16, -387.91),
    Vector3.new(2787.87, -663.16, -413.31),
    Vector3.new(2799.01, -663.17, -440.44),
    Vector3.new(2811.99, -663.18, -471.88),
    Vector3.new(2823.27, -663.16, -498.23),
    Vector3.new(2837.19, -663.19, -528.52),
    Vector3.new(2848.89, -663.13, -553.96),
    Vector3.new(2861.16, -663.16, -581.65),
    Vector3.new(2865.42, -663.18, -600.09),
    Vector3.new(2861.22, -663.18, -622.78),
    Vector3.new(2857.47, -663.13, -635.89),
    Vector3.new(2855.43, -655.76, -644.02),
    Vector3.new(2856.16, -649.58, -647.07),
    Vector3.new(2857.81, -648.30, -650.80),
    Vector3.new(2851.64, -643.77, -652.37),
    Vector3.new(2845.90, -638.86, -655.03),
    Vector3.new(2840.74, -635.02, -659.03),
    Vector3.new(2832.79, -632.62, -669.26),
    Vector3.new(2826.78, -630.55, -680.95),
    Vector3.new(2821.62, -628.48, -690.86),
    Vector3.new(2814.40, -625.47, -694.58),
    Vector3.new(2810.26, -623.73, -696.33),
    Vector3.new(2804.30, -622.20, -714.11),
    Vector3.new(2803.89, -622.64, -720.75),
    Vector3.new(2803.02, -626.45, -737.27),
    Vector3.new(2790.73, -637.05, -759.21),
    Vector3.new(2798.07, -637.12, -772.16),
    Vector3.new(2760.31, -636.36, -795.11),
    Vector3.new(2769.89, -643.24, -807.61),
    Vector3.new(2772.71, -636.94, -811.28),
    Vector3.new(2770.74, -630.76, -828.20),
    Vector3.new(2773.64, -633.54, -847.13),
    Vector3.new(2777.31, -632.51, -858.54),
    Vector3.new(2781.54, -631.68, -865.24),
    Vector3.new(2804.63, -627.18, -871.06),
    Vector3.new(2816.60, -626.16, -865.33),
    Vector3.new(2827.41, -625.39, -862.03),
    Vector3.new(2835.96, -630.18, -856.16),
    Vector3.new(2843.50, -629.62, -853.55),
    Vector3.new(2851.51, -629.70, -856.11),
    Vector3.new(2858.43, -625.87, -864.22),
    Vector3.new(2861.07, -624.50, -866.90),
    Vector3.new(2873.18, -635.40, -867.33),
    Vector3.new(2883.12, -631.55, -871.16),
    Vector3.new(2889.83, -628.84, -874.58),
    Vector3.new(2891.89, -627.84, -876.99),
    Vector3.new(2879.39, -624.85, -894.68),
    Vector3.new(2881.99, -622.94, -897.40),
    Vector3.new(2887.04, -620.51, -903.11),
    Vector3.new(2900.75, -632.79, -914.75),
    Vector3.new(2895.40, -626.82, -926.88),
    Vector3.new(2885.86, -623.69, -931.11),
    Vector3.new(2883.13, -630.27, -940.54),
    Vector3.new(2878.05, -623.96, -950.86),
    Vector3.new(2892.81, -615.75, -947.56),
    Vector3.new(2896.34, -608.60, -945.12),
    Vector3.new(2900.05, -604.38, -950.02),
    Vector3.new(2894.21, -603.89, -960.16),
    Vector3.new(2890.39, -615.67, -968.51),
    Vector3.new(2890.23, -610.64, -974.68),
    Vector3.new(2890.65, -606.79, -983.47),
    Vector3.new(2892.22, -601.42, -996.82),
    Vector3.new(2894.96, -601.00, -1007.81),
    Vector3.new(2898.15, -600.37, -1012.84),
    Vector3.new(2907.87, -663.10, -1030.22),
    Vector3.new(2914.32, -654.09, -1033.53),
    Vector3.new(2924.16, -642.25, -1042.32),
    Vector3.new(2918.12, -636.98, -1046.03),
    Vector3.new(2920.62, -637.02, -1054.50),
    Vector3.new(2922.12, -633.32, -1070.68),
    Vector3.new(2922.77, -633.82, -1078.13),
    Vector3.new(2923.66, -647.82, -1088.43),
    Vector3.new(2926.29, -662.00, -1101.93),
    Vector3.new(2925.64, -663.15, -1115.77),
    Vector3.new(2921.70, -663.18, -1140.07),
    Vector3.new(2910.17, -663.18, -1174.03),
    Vector3.new(2896.32, -663.15, -1207.96),
    Vector3.new(2881.96, -663.18, -1244.31),
    Vector3.new(2864.99, -663.02, -1277.00),
    Vector3.new(2845.85, -663.00, -1311.35),
    Vector3.new(2829.38, -663.27, -1340.47) -- Финиш (Точка 114)
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