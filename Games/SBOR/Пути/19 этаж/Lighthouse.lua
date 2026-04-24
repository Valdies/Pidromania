local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Финал_216"
local lineColor = Color3.new(1, 0, 0) -- Красный для основных линий
local pointColor = Color3.new(0, 1, 0) -- Зеленый для точек
local dynamicLineColor = Color3.new(0, 0.5, 1) -- Синий для динамической линии
local lineWidth = 0.2
local pointSize = 0.8 
local activationRadius = 10 -- РАДИУС АКТИВАЦИИ (в студах)
-- =============================================

-- Очистка старого пути
local pathFolder = Workspace:FindFirstChild(folderName)
if pathFolder then
    pathFolder:Destroy()
end
pathFolder = Instance.new("Folder")
pathFolder.Name = folderName
pathFolder.Parent = Workspace

-- КООРДИНАТЫ ПУТИ (216 точек)
local points = {
    Vector3.new(-2964.61, 213.41, 6143.28), -- Старт
    Vector3.new(-2981.23, 209.00, 6101.39),
    Vector3.new(-2997.59, 209.00, 6063.22),
    Vector3.new(-3014.80, 204.86, 6024.68),
    Vector3.new(-3032.66, 199.80, 5984.74),
    Vector3.new(-3048.63, 196.65, 5942.58),
    Vector3.new(-3066.85, 183.54, 5888.82),
    Vector3.new(-3089.89, 181.52, 5847.61),
    Vector3.new(-3115.05, 177.43, 5804.52),
    Vector3.new(-3138.18, 162.93, 5770.10),
    Vector3.new(-3162.31, 141.87, 5737.07),
    Vector3.new(-3178.24, 136.25, 5710.97),
    Vector3.new(-3145.74, 143.69, 5684.66),
    Vector3.new(-3109.65, 151.88, 5653.87),
    Vector3.new(-3077.14, 163.09, 5623.20),
    Vector3.new(-3043.36, 164.93, 5590.52),
    Vector3.new(-3014.68, 164.21, 5560.96),
    Vector3.new(-2981.20, 165.00, 5525.69),
    Vector3.new(-2961.07, 165.01, 5486.96),
    Vector3.new(-2954.02, 164.30, 5446.77),
    Vector3.new(-2957.70, 158.86, 5398.67),
    Vector3.new(-2964.27, 153.00, 5350.99),
    Vector3.new(-2979.29, 152.31, 5307.58),
    Vector3.new(-2998.93, 148.99, 5261.84),
    Vector3.new(-3019.56, 148.17, 5217.46),
    Vector3.new(-3038.84, 154.68, 5174.02),
    Vector3.new(-3051.28, 162.55, 5147.22),
    Vector3.new(-3064.09, 168.65, 5120.02),
    Vector3.new(-3090.75, 168.87, 5070.03),
    Vector3.new(-3112.58, 172.28, 5032.80),
    Vector3.new(-3133.68, 166.92, 5000.18),
    Vector3.new(-3160.05, 153.01, 4962.60),
    Vector3.new(-3182.93, 141.32, 4928.58),
    Vector3.new(-3202.62, 139.23, 4894.46),
    Vector3.new(-3220.20, 135.31, 4857.73),
    Vector3.new(-3233.39, 130.06, 4826.69),
    Vector3.new(-3248.10, 121.01, 4779.32),
    Vector3.new(-3254.07, 117.00, 4745.52),
    Vector3.new(-3257.92, 119.51, 4721.46),
    Vector3.new(-3263.26, 128.98, 4682.42),
    Vector3.new(-3270.82, 128.99, 4629.08),
    Vector3.new(-3280.05, 133.45, 4581.83),
    Vector3.new(-3287.39, 137.64, 4543.55),
    Vector3.new(-3291.95, 133.18, 4509.75),
    Vector3.new(-3292.22, 125.40, 4469.68),
    Vector3.new(-3284.73, 121.60, 4415.25),
    Vector3.new(-3277.54, 112.65, 4369.52),
    Vector3.new(-3272.76, 99.11, 4326.65),
    Vector3.new(-3267.70, 98.93, 4281.03),
    Vector3.new(-3263.45, 97.39, 4231.98),
    Vector3.new(-3266.87, 96.87, 4188.88),
    Vector3.new(-3290.68, 97.00, 4151.45),
    Vector3.new(-3329.41, 98.28, 4134.07),
    Vector3.new(-3376.27, 101.12, 4131.54),
    Vector3.new(-3419.49, 111.09, 4133.81),
    Vector3.new(-3464.65, 115.52, 4134.21),
    Vector3.new(-3504.81, 118.65, 4126.70),
    Vector3.new(-3536.75, 113.06, 4095.80),
    Vector3.new(-3556.05, 113.00, 4059.70),
    Vector3.new(-3563.15, 115.43, 4021.69),
    Vector3.new(-3559.25, 124.41, 3979.64),
    Vector3.new(-3550.25, 125.55, 3936.62),
    Vector3.new(-3539.91, 126.64, 3891.18),
    Vector3.new(-3534.14, 127.43, 3849.88),
    Vector3.new(-3540.41, 127.82, 3807.04),
    Vector3.new(-3549.24, 132.79, 3788.59),
    Vector3.new(-3559.59, 133.00, 3779.69),
    Vector3.new(-3581.27, 132.99, 3771.05),
    Vector3.new(-3606.76, 134.41, 3771.53),
    Vector3.new(-3630.93, 140.49, 3774.49),
    Vector3.new(-3675.92, 141.00, 3781.78),
    Vector3.new(-3715.12, 138.58, 3784.12),
    Vector3.new(-3743.22, 136.93, 3775.72),
    Vector3.new(-3768.41, 128.03, 3754.98),
    Vector3.new(-3796.59, 120.62, 3723.25),
    Vector3.new(-3821.24, 121.68, 3687.51),
    Vector3.new(-3847.85, 119.76, 3648.56),
    Vector3.new(-3874.36, 121.00, 3609.77),
    Vector3.new(-3901.93, 119.17, 3572.26),
    Vector3.new(-3930.80, 116.30, 3541.32),
    Vector3.new(-3947.46, 111.99, 3515.84),
    Vector3.new(-3944.37, 112.93, 3495.51),
    Vector3.new(-3934.96, 113.64, 3475.03),
    Vector3.new(-3905.22, 111.51, 3440.07),
    Vector3.new(-3878.35, 110.29, 3410.13),
    Vector3.new(-3853.15, 101.01, 3379.78),
    Vector3.new(-3824.58, 96.96, 3345.07),
    Vector3.new(-3799.16, 100.18, 3311.05),
    Vector3.new(-3772.86, 107.92, 3268.25),
    Vector3.new(-3747.22, 119.51, 3227.60),
    Vector3.new(-3725.44, 122.00, 3191.80),
    Vector3.new(-3700.98, 129.36, 3150.09),
    Vector3.new(-3673.59, 137.12, 3099.79),
    Vector3.new(-3655.43, 147.33, 3064.46),
    Vector3.new(-3634.74, 156.59, 3021.62),
    Vector3.new(-3613.23, 161.15, 2977.73),
    Vector3.new(-3590.43, 157.17, 2934.08),
    Vector3.new(-3561.51, 143.37, 2882.75),
    Vector3.new(-3530.00, 129.04, 2833.58),
    Vector3.new(-3502.60, 129.00, 2788.76),
    Vector3.new(-3481.93, 134.40, 2749.27),
    Vector3.new(-3456.66, 163.53, 2695.24),
    Vector3.new(-3444.30, 179.43, 2667.25),
    Vector3.new(-3434.74, 190.50, 2645.82),
    Vector3.new(-3426.17, 197.32, 2627.31),
    Vector3.new(-3414.64, 205.76, 2603.42),
    Vector3.new(-3399.69, 217.24, 2570.50),
    Vector3.new(-3385.54, 225.99, 2535.61),
    Vector3.new(-3373.33, 231.63, 2508.11),
    Vector3.new(-3355.11, 237.85, 2470.91),
    Vector3.new(-3338.19, 243.00, 2437.50),
    Vector3.new(-3328.03, 248.58, 2414.98),
    Vector3.new(-3316.22, 248.86, 2385.97),
    Vector3.new(-3302.89, 251.47, 2352.16),
    Vector3.new(-3290.15, 258.67, 2317.83),
    Vector3.new(-3279.64, 263.83, 2289.52),
    Vector3.new(-3268.97, 265.00, 2260.83),
    Vector3.new(-3260.16, 264.46, 2237.11),
    Vector3.new(-3248.87, 262.15, 2206.69),
    Vector3.new(-3240.87, 265.98, 2185.15),
    Vector3.new(-3234.74, 271.80, 2168.59),
    Vector3.new(-3228.21, 277.86, 2151.36),
    Vector3.new(-3216.38, 285.17, 2122.16),
    Vector3.new(-3203.01, 290.26, 2091.44),
    Vector3.new(-3189.31, 297.00, 2058.98),
    Vector3.new(-3177.05, 300.72, 2026.25),
    Vector3.new(-3162.28, 306.76, 1992.55),
    Vector3.new(-3147.56, 315.99, 1961.04),
    Vector3.new(-3129.86, 324.17, 1929.93),
    Vector3.new(-3107.03, 329.39, 1898.05),
    Vector3.new(-3085.93, 336.27, 1870.62),
    Vector3.new(-3060.57, 341.70, 1839.40),
    Vector3.new(-3028.84, 346.25, 1799.46),
    Vector3.new(-2999.00, 357.17, 1765.83),
    Vector3.new(-2967.46, 371.10, 1735.29),
    Vector3.new(-2932.43, 391.54, 1706.50),
    Vector3.new(-2899.69, 408.14, 1691.18),
    Vector3.new(-2868.51, 421.12, 1681.40),
    Vector3.new(-2824.22, 437.56, 1670.31),
    Vector3.new(-2785.19, 444.71, 1667.46),
    Vector3.new(-2755.66, 459.52, 1674.54),
    Vector3.new(-2738.70, 472.57, 1683.20),
    Vector3.new(-2718.55, 488.74, 1692.32),
    Vector3.new(-2698.78, 500.63, 1691.20),
    Vector3.new(-2690.16, 518.25, 1678.55),
    Vector3.new(-2685.11, 525.31, 1679.14),
    Vector3.new(-2682.09, 535.41, 1671.34),
    Vector3.new(-2675.97, 547.20, 1661.04),
    Vector3.new(-2664.07, 559.80, 1657.35),
    Vector3.new(-2657.32, 570.38, 1663.02),
    Vector3.new(-2656.00, 577.42, 1674.77),
    Vector3.new(-2656.86, 582.76, 1691.57),
    Vector3.new(-2652.08, 591.94, 1705.12),
    Vector3.new(-2648.47, 596.81, 1719.43),
    Vector3.new(-2643.51, 602.25, 1729.46),
    Vector3.new(-2634.81, 611.66, 1732.93),
    Vector3.new(-2624.02, 626.99, 1729.00),
    Vector3.new(-2616.13, 642.57, 1718.73),
    Vector3.new(-2608.70, 651.88, 1707.41),
    Vector3.new(-2594.15, 662.58, 1702.46),
    Vector3.new(-2583.20, 676.06, 1704.37),
    Vector3.new(-2571.29, 694.01, 1709.24),
    Vector3.new(-2559.27, 708.70, 1715.14),
    Vector3.new(-2544.51, 721.96, 1718.27),
    Vector3.new(-2524.89, 730.24, 1722.67),
    Vector3.new(-2515.77, 740.92, 1728.85),
    Vector3.new(-2512.40, 747.40, 1734.69),
    Vector3.new(-2509.70, 754.63, 1735.06),
    Vector3.new(-2500.00, 762.40, 1727.16),
    Vector3.new(-2485.52, 776.34, 1721.92),
    Vector3.new(-2466.97, 785.00, 1721.95),
    Vector3.new(-2457.40, 795.70, 1721.30),
    Vector3.new(-2444.67, 807.79, 1720.34),
    Vector3.new(-2422.52, 811.66, 1717.81),
    Vector3.new(-2406.72, 824.31, 1713.90),
    Vector3.new(-2393.46, 837.87, 1712.67),
    Vector3.new(-2380.49, 850.90, 1714.36),
    Vector3.new(-2365.21, 864.41, 1716.41),
    Vector3.new(-2348.85, 872.72, 1719.42),
    Vector3.new(-2334.75, 882.19, 1721.02),
    Vector3.new(-2318.21, 891.15, 1718.88),
    Vector3.new(-2309.25, 900.38, 1708.17),
    Vector3.new(-2309.62, 909.10, 1694.14),
    Vector3.new(-2307.58, 917.48, 1678.64),
    Vector3.new(-2308.38, 919.89, 1672.65),
    Vector3.new(-2301.00, 930.88, 1659.62),
    Vector3.new(-2286.49, 940.85, 1652.66),
    Vector3.new(-2272.09, 951.17, 1657.73),
    Vector3.new(-2264.03, 960.84, 1664.28),
    Vector3.new(-2259.02, 964.86, 1672.11),
    Vector3.new(-2250.27, 971.22, 1679.25),
    Vector3.new(-2235.74, 984.79, 1674.89),
    Vector3.new(-2221.45, 991.99, 1662.01),
    Vector3.new(-2205.29, 996.46, 1649.31),
    Vector3.new(-2172.52, 997.00, 1639.91),
    Vector3.new(-2133.89, 997.00, 1630.16),
    Vector3.new(-2097.43, 997.00, 1621.34),
    Vector3.new(-2055.81, 996.99, 1612.75),
    Vector3.new(-2014.60, 996.99, 1604.69),
    Vector3.new(-1976.80, 997.00, 1595.73),
    Vector3.new(-1950.81, 1003.66, 1589.33),
    Vector3.new(-1925.70, 1004.85, 1582.89),
    Vector3.new(-1891.74, 1004.20, 1576.45),
    Vector3.new(-1860.79, 998.27, 1571.56),
    Vector3.new(-1837.84, 987.80, 1566.40),
    Vector3.new(-1816.81, 994.02, 1560.36),
    Vector3.new(-1802.61, 999.78, 1555.62),
    Vector3.new(-1789.42, 1000.10, 1551.02),
    Vector3.new(-1772.58, 994.63, 1544.18),
    Vector3.new(-1752.03, 983.07, 1531.54),
    Vector3.new(-1726.77, 984.46, 1514.06),
    Vector3.new(-1706.43, 991.26, 1505.05),
    Vector3.new(-1690.21, 1000.82, 1498.95),
    Vector3.new(-1676.18, 1011.25, 1494.78),
    Vector3.new(-1663.70, 1013.08, 1494.89),
    Vector3.new(-1649.51, 1013.00, 1496.98)  -- Финиш
}

local cleanupTable = {} 
local activePoints = {} 

-- Объект для динамической линии
local dynamicLinePart = Instance.new("Part")
dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, 0)
dynamicLinePart.Anchored = true
dynamicLinePart.CanCollide = false
dynamicLinePart.Color = dynamicLineColor
dynamicLinePart.Material = Enum.Material.Neon
dynamicLinePart.Name = "DynamicLine_PlayerToTarget"
dynamicLinePart.Parent = pathFolder

-- Функция создания статической линии
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

-- Функция создания точки
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
    
    -- Подсветка
    local light = Instance.new("PointLight")
    light.Color = pointColor
    light.Brightness = 2
    light.Range = 10
    light.Parent = pointPart
    
    local partsToDelete = {pointPart, light}

    -- Добавляем в список активных точек
    activePoints[index] = {
        pos = pos,
        label = labelText,
        part = pointPart
    }
    
    return partsToDelete
end

-- ================= ГЕНЕРАЦИЯ ПУТИ =================
print("🔄 Генерация маршрута...")

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

    -- 1. Создаем точку
    local pointParts = createPoint(pos, pointLabel, currentIndex)
    for _, p in ipairs(pointParts) do
        table.insert(cleanupTable[currentIndex], p)
    end

    -- 2. Создаем линию
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

-- ================= ПРОВЕРКА ДИСТАНЦИИ И ДИНАМИЧЕСКАЯ ЛИНИЯ =================
RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local playerPos = rootPart.Position
    local closestDist = math.huge
    local targetPos = nil
    local targetIndex = nil

    -- 1. Поиск ближайшей активной точки
    for idx, data in pairs(activePoints) do
        if data.part and data.part.Parent then
            local dist = (data.pos - playerPos).Magnitude
            
            -- Обновляем цель для синей линии
            if dist < closestDist then
                closestDist = dist
                targetPos = data.pos
                targetIndex = idx
            end

            -- 2. ПРОВЕРКА РАДИУСА (Автоматическое удаление)
            if dist <= activationRadius then
                -- Удаляем из активных
                activePoints[idx] = nil
                
                -- Логика удаления пути
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
                    print("🎉 ФИНИШ ДОСТИГНУТ!")
                    dynamicLinePart.Transparency = 1
                end
                
                break 
            end
        end
    end

    -- Отрисовка синей линии
    if targetPos and activePoints[targetIndex] then
        dynamicLinePart.Transparency = 0
        local distance = (targetPos - playerPos).Magnitude
        
        dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, distance)
        dynamicLinePart.CFrame = CFrame.lookAt(playerPos, targetPos) * CFrame.new(0, 0, -distance / 2)
    else
        dynamicLinePart.Transparency = 1
    end
end)

print("✅ Маршрут построен! Всего точек: " .. #points)
print("🔵 Синяя линия указывает на следующую цель.")
print("⚡ Точки удаляются автоматически в радиусе " .. activationRadius .. " студов.")
