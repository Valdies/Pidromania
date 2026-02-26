local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_Grimm"
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
    Vector3.new(8891.63, 2955.59, 1848.44),
    Vector3.new(8874.70, 2953.00, 1855.38),
    Vector3.new(8861.01, 2951.13, 1861.38),
    Vector3.new(8849.95, 2943.07, 1866.42),
    Vector3.new(8834.71, 2933.78, 1873.29),
    Vector3.new(8822.79, 2925.97, 1878.48),
    Vector3.new(8808.62, 2916.43, 1884.81),
    Vector3.new(8796.63, 2909.02, 1890.65),
    Vector3.new(8784.25, 2897.91, 1896.80),
    Vector3.new(8772.15, 2887.18, 1902.84),
    Vector3.new(8761.63, 2873.46, 1908.08),
    Vector3.new(8749.56, 2864.91, 1914.12),
    Vector3.new(8736.34, 2859.64, 1920.70),
    Vector3.new(8719.92, 2850.04, 1928.90),
    Vector3.new(8706.96, 2840.11, 1935.37),
    Vector3.new(8692.25, 2842.13, 1942.75),
    Vector3.new(8676.51, 2837.08, 1950.98),
    Vector3.new(8661.54, 2828.16, 1960.44),
    Vector3.new(8649.51, 2817.22, 1968.03),
    Vector3.new(8636.29, 2808.28, 1976.30),
    Vector3.new(8619.89, 2798.80, 1986.07),
    Vector3.new(8602.96, 2789.14, 1994.65),
    Vector3.new(8590.87, 2775.70, 1999.66),
    Vector3.new(8579.27, 2766.16, 2003.20),
    Vector3.new(8564.52, 2757.29, 2006.35),
    Vector3.new(8550.78, 2758.03, 2007.51),
    Vector3.new(8536.35, 2760.84, 2007.28),
    Vector3.new(8520.49, 2762.76, 2006.73),
    Vector3.new(8502.54, 2763.73, 2006.03),
    Vector3.new(8485.89, 2763.36, 2006.54),
    Vector3.new(8469.94, 2762.04, 2006.79),
    Vector3.new(8443.59, 2757.99, 2007.02),
    Vector3.new(8429.95, 2754.91, 2007.07),
    Vector3.new(8416.03, 2750.41, 2007.06),
    Vector3.new(8407.76, 2746.83, 2007.02),
    Vector3.new(8372.86, 2731.44, 2006.73),
    Vector3.new(8334.15, 2725.29, 2006.07),
    Vector3.new(8322.06, 2723.87, 2005.87),
    Vector3.new(8303.97, 2719.46, 2005.56),
    Vector3.new(8288.28, 2713.98, 2005.29),
    Vector3.new(8269.40, 2705.59, 2004.74),
    Vector3.new(8255.25, 2698.49, 2004.08),
    Vector3.new(8240.00, 2688.93, 2002.14),
    Vector3.new(8224.77, 2679.17, 2000.03),
    Vector3.new(8212.75, 2669.67, 1998.19),
    Vector3.new(8198.14, 2674.55, 1990.55),
    Vector3.new(8187.98, 2668.61, 1976.65),
    Vector3.new(8185.57, 2669.43, 1961.81),
    Vector3.new(8179.85, 2673.03, 1941.83),
    Vector3.new(8175.58, 2674.75, 1925.91),
    Vector3.new(8172.43, 2673.14, 1909.56),
    Vector3.new(8169.33, 2670.10, 1894.32),
    Vector3.new(8166.32, 2673.31, 1879.70),
    Vector3.new(8162.05, 2672.21, 1863.05),
    Vector3.new(8156.80, 2674.48, 1843.97),
    Vector3.new(8151.63, 2674.00, 1823.49),
    Vector3.new(8145.49, 2678.70, 1806.69),
    Vector3.new(8134.85, 2679.30, 1786.28),
    Vector3.new(8127.69, 2676.36, 1773.13),
    Vector3.new(8119.68, 2669.18, 1759.53),
    Vector3.new(8110.09, 2666.49, 1743.26),
    Vector3.new(8101.61, 2664.81, 1729.11),
    Vector3.new(8089.74, 2660.45, 1712.10),
    Vector3.new(8077.00, 2655.69, 1698.98),
    Vector3.new(8063.57, 2650.72, 1686.70),
    Vector3.new(8050.49, 2647.20, 1674.98),
    Vector3.new(8035.30, 2641.69, 1661.56),
    Vector3.new(8028.77, 2635.92, 1646.55),
    Vector3.new(8028.88, 2624.84, 1632.28),
    Vector3.new(8030.58, 2618.53, 1617.61),
    Vector3.new(8032.38, 2610.60, 1599.80),
    Vector3.new(8035.05, 2605.91, 1589.48),
    Vector3.new(8053.72, 2592.57, 1541.06),
    Vector3.new(8058.30, 2590.24, 1527.33),
    Vector3.new(8063.50, 2593.90, 1514.43),
    Vector3.new(8070.78, 2587.19, 1497.24),
    Vector3.new(8077.12, 2586.28, 1481.88),
    Vector3.new(8081.92, 2586.21, 1468.76),
    Vector3.new(8086.16, 2586.64, 1456.86),
    Vector3.new(8093.72, 2590.29, 1435.50),
    Vector3.new(8099.60, 2591.12, 1418.74),
    Vector3.new(8105.69, 2595.39, 1401.53),
    Vector3.new(8111.88, 2601.18, 1384.05),
    Vector3.new(8114.60, 2605.73, 1366.28),
    Vector3.new(8118.39, 2611.27, 1351.96),
    Vector3.new(8127.12, 2619.51, 1337.06),
    Vector3.new(8132.17, 2626.89, 1328.31),
    Vector3.new(8129.51, 2626.58, 1305.94),
    Vector3.new(8124.87, 2626.59, 1290.10),
    Vector3.new(8121.96, 2629.63, 1270.80),
    Vector3.new(8123.04, 2633.10, 1256.19),
    Vector3.new(8129.65, 2638.48, 1237.92),
    Vector3.new(8138.67, 2642.19, 1222.10),
    Vector3.new(8149.77, 2651.68, 1208.98),
    Vector3.new(8156.03, 2660.98, 1197.77),
    Vector3.new(8165.07, 2668.50, 1182.55),
    Vector3.new(8173.34, 2672.03, 1169.31),
    Vector3.new(8180.17, 2673.22, 1155.90),
    Vector3.new(8187.22, 2676.40, 1142.28),
    Vector3.new(8195.55, 2680.92, 1128.68),
    Vector3.new(8204.75, 2683.35, 1114.41),
    Vector3.new(8213.62, 2685.00, 1100.58),
    Vector3.new(8222.14, 2685.04, 1086.03),
    Vector3.new(8230.15, 2691.04, 1072.14),
    Vector3.new(8237.83, 2698.61, 1058.82),
    Vector3.new(8248.26, 2704.77, 1043.14),
    Vector3.new(8257.48, 2708.45, 1033.46),
    Vector3.new(8265.61, 2708.87, 1021.29)
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