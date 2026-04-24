local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Финал"
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

-- ФИНАЛЬНЫЕ КООРДИНАТЫ ПУТИ (217 точек)
local points = {
    Vector3.new(-2965.55, 214.06, 6202.02), -- Старт
    Vector3.new(-2970.06, 214.05, 6166.40),
    Vector3.new(-2977.57, 209.00, 6108.47),
    Vector3.new(-2997.07, 209.00, 6062.69),
    Vector3.new(-3016.90, 204.81, 6023.73),
    Vector3.new(-3034.43, 199.72, 5983.13),
    Vector3.new(-3048.18, 196.64, 5941.77),
    Vector3.new(-3061.69, 187.86, 5903.67),
    Vector3.new(-3079.05, 182.39, 5867.63),
    Vector3.new(-3102.53, 180.88, 5828.42),
    Vector3.new(-3125.04, 172.40, 5787.68),
    Vector3.new(-3148.75, 149.51, 5750.48),
    Vector3.new(-3168.34, 136.10, 5710.85),
    Vector3.new(-3147.06, 142.73, 5691.55),
    Vector3.new(-3117.16, 149.79, 5658.61),
    Vector3.new(-3092.68, 158.28, 5634.72),
    Vector3.new(-3073.16, 164.53, 5617.66),
    Vector3.new(-3033.48, 163.37, 5579.32),
    Vector3.new(-3002.67, 165.00, 5548.08),
    Vector3.new(-2980.55, 165.15, 5519.72),
    Vector3.new(-2963.05, 165.00, 5491.51),
    Vector3.new(-2961.26, 165.70, 5470.04),
    Vector3.new(-2958.74, 161.98, 5429.59),
    Vector3.new(-2959.23, 158.36, 5393.05),
    Vector3.new(-2966.93, 153.99, 5355.75),
    Vector3.new(-2980.20, 152.08, 5314.48),
    Vector3.new(-2993.39, 149.45, 5280.64),
    Vector3.new(-3017.68, 146.85, 5224.77),
    Vector3.new(-3033.19, 152.76, 5189.87),
    Vector3.new(-3046.17, 156.48, 5164.49),
    Vector3.new(-3057.46, 164.00, 5141.79),
    Vector3.new(-3070.98, 168.76, 5114.54),
    Vector3.new(-3083.70, 168.72, 5091.12),
    Vector3.new(-3106.92, 170.77, 5047.97),
    Vector3.new(-3127.02, 169.09, 5010.57),
    Vector3.new(-3151.22, 157.42, 4972.18),
    Vector3.new(-3177.04, 144.14, 4938.35),
    Vector3.new(-3195.51, 139.79, 4899.43),
    Vector3.new(-3210.73, 134.43, 4862.23),
    Vector3.new(-3203.09, 128.10, 4832.66),
    Vector3.new(-3176.61, 126.76, 4807.20),
    Vector3.new(-3140.03, 129.02, 4788.69),
    Vector3.new(-3092.42, 129.00, 4773.49),
    Vector3.new(-3049.15, 132.49, 4761.41),
    Vector3.new(-3014.89, 140.88, 4751.81),
    Vector3.new(-2975.74, 147.99, 4740.86),
    Vector3.new(-2941.97, 161.83, 4731.40),
    Vector3.new(-2915.61, 168.67, 4725.04),
    Vector3.new(-2854.33, 176.89, 4713.85),
    Vector3.new(-2808.43, 187.63, 4701.49),
    Vector3.new(-2755.57, 201.74, 4685.20),
    Vector3.new(-2709.07, 211.67, 4670.54),
    Vector3.new(-2678.68, 216.90, 4662.81),
    Vector3.new(-2636.41, 216.81, 4650.55),
    Vector3.new(-2598.15, 206.45, 4640.84),
    Vector3.new(-2559.48, 190.95, 4629.67),
    Vector3.new(-2516.80, 172.00, 4613.67),
    Vector3.new(-2475.41, 160.93, 4592.70),
    Vector3.new(-2439.67, 153.27, 4572.18),
    Vector3.new(-2403.14, 153.00, 4550.20),
    Vector3.new(-2364.57, 153.00, 4524.87),
    Vector3.new(-2331.53, 153.01, 4497.21),
    Vector3.new(-2311.36, 159.73, 4466.75),
    Vector3.new(-2296.14, 172.83, 4435.39),
    Vector3.new(-2279.54, 178.91, 4404.16),
    Vector3.new(-2258.41, 179.79, 4366.38),
    Vector3.new(-2241.03, 184.36, 4350.12),
    Vector3.new(-2218.60, 185.00, 4345.33),
    Vector3.new(-2176.15, 185.00, 4341.34),
    Vector3.new(-2132.69, 184.91, 4334.51),
    Vector3.new(-2089.07, 187.86, 4323.13),
    Vector3.new(-2049.45, 188.96, 4297.73),
    Vector3.new(-2029.65, 197.22, 4272.43),
    Vector3.new(-2016.77, 197.73, 4253.84),
    Vector3.new(-2005.93, 193.56, 4231.54),
    Vector3.new(-1997.28, 185.35, 4202.06),
    Vector3.new(-1981.75, 179.86, 4161.66),
    Vector3.new(-1966.05, 167.41, 4123.80),
    Vector3.new(-1949.81, 161.54, 4087.82),
    Vector3.new(-1934.77, 155.37, 4060.66),
    Vector3.new(-1917.49, 145.47, 4032.64),
    Vector3.new(-1895.33, 149.38, 4009.87),
    Vector3.new(-1866.70, 149.24, 3985.21),
    Vector3.new(-1850.20, 150.13, 3971.49),
    Vector3.new(-1823.27, 145.17, 3949.09),
    Vector3.new(-1796.25, 134.08, 3925.88),
    Vector3.new(-1776.02, 130.94, 3900.54),
    Vector3.new(-1751.82, 127.64, 3863.31),
    Vector3.new(-1733.34, 127.48, 3833.67),
    Vector3.new(-1710.77, 129.56, 3804.10),
    Vector3.new(-1685.37, 139.25, 3782.34),
    Vector3.new(-1665.30, 145.46, 3774.08),
    Vector3.new(-1630.25, 149.17, 3764.88),
    Vector3.new(-1600.32, 153.86, 3758.67),
    Vector3.new(-1568.64, 152.98, 3751.17),
    Vector3.new(-1536.37, 153.27, 3743.01),
    Vector3.new(-1500.21, 145.93, 3734.87),
    Vector3.new(-1466.77, 141.44, 3726.44),
    Vector3.new(-1431.35, 144.91, 3716.80),
    Vector3.new(-1394.06, 151.47, 3706.15),
    Vector3.new(-1364.54, 156.93, 3697.47),
    Vector3.new(-1336.14, 158.38, 3688.38),
    Vector3.new(-1305.48, 153.26, 3678.54),
    Vector3.new(-1271.92, 140.65, 3667.77),
    Vector3.new(-1238.13, 140.14, 3656.92),
    Vector3.new(-1212.80, 149.10, 3648.85),
    Vector3.new(-1171.53, 151.73, 3636.27),
    Vector3.new(-1119.34, 148.77, 3620.57),
    Vector3.new(-1068.60, 148.25, 3604.70),
    Vector3.new(-1020.97, 145.00, 3592.79),
    Vector3.new(-969.68, 152.79, 3580.46),
    Vector3.new(-925.75, 151.82, 3568.75),
    Vector3.new(-878.97, 144.90, 3552.94),
    Vector3.new(-840.41, 142.66, 3538.94),
    Vector3.new(-797.92, 135.40, 3523.87),
    Vector3.new(-767.88, 125.37, 3513.08),
    Vector3.new(-725.19, 110.65, 3497.69),
    Vector3.new(-679.55, 112.18, 3481.45),
    Vector3.new(-639.11, 121.66, 3467.72),
    Vector3.new(-607.17, 131.07, 3457.69),
    Vector3.new(-566.64, 135.90, 3444.52),
    Vector3.new(-532.98, 134.80, 3433.57),
    Vector3.new(-494.17, 128.59, 3422.16),
    Vector3.new(-453.89, 118.48, 3411.52),
    Vector3.new(-410.38, 109.09, 3404.74),
    Vector3.new(-375.99, 107.30, 3405.57),
    Vector3.new(-339.93, 113.94, 3413.61),
    Vector3.new(-315.36, 121.98, 3421.90),
    Vector3.new(-278.46, 125.92, 3436.40),
    Vector3.new(-278.31, 125.88, 3439.20),
    Vector3.new(-249.26, 126.86, 3412.20),
    Vector3.new(-211.87, 123.63, 3388.60),
    Vector3.new(-168.50, 109.38, 3366.29),
    Vector3.new(-118.54, 115.29, 3344.99),
    Vector3.new(-71.24, 125.01, 3326.16),
    Vector3.new(-25.93, 123.45, 3308.36),
    Vector3.new(20.69, 118.56, 3288.12),
    Vector3.new(69.42, 118.93, 3264.12),
    Vector3.new(113.22, 127.23, 3238.60),
    Vector3.new(151.95, 130.47, 3212.05),
    Vector3.new(187.32, 124.33, 3185.85),
    Vector3.new(225.60, 117.00, 3153.08),
    Vector3.new(255.55, 122.94, 3123.27),
    Vector3.new(287.38, 129.00, 3085.98),
    Vector3.new(313.30, 135.42, 3040.05),
    Vector3.new(332.04, 142.62, 2998.75),
    Vector3.new(348.99, 156.83, 2968.90),
    Vector3.new(369.09, 159.67, 2935.30),
    Vector3.new(388.09, 158.27, 2905.19),
    Vector3.new(408.64, 141.27, 2872.65),
    Vector3.new(427.83, 141.89, 2844.76),
    Vector3.new(444.07, 153.09, 2822.81),
    Vector3.new(474.48, 157.00, 2786.90),
    Vector3.new(505.79, 160.26, 2761.82),
    Vector3.new(537.83, 164.25, 2737.83),
    Vector3.new(563.25, 164.87, 2718.26),
    Vector3.new(587.99, 162.00, 2699.02),
    Vector3.new(620.37, 162.09, 2672.50),
    Vector3.new(651.95, 167.60, 2644.16),
    Vector3.new(676.48, 164.69, 2619.50),
    Vector3.new(701.60, 153.38, 2594.23),
    Vector3.new(726.12, 138.76, 2569.31),
    Vector3.new(750.39, 130.20, 2540.48),
    Vector3.new(769.99, 128.33, 2509.94),
    Vector3.new(780.35, 128.61, 2472.85),
    Vector3.new(783.91, 122.62, 2430.49),
    Vector3.new(784.70, 116.93, 2395.85),
    Vector3.new(784.83, 112.92, 2357.58),
    Vector3.new(786.53, 108.14, 2322.02),
    Vector3.new(793.29, 106.53, 2273.24),
    Vector3.new(802.10, 110.99, 2225.16),
    Vector3.new(814.28, 114.96, 2178.63),
    Vector3.new(825.76, 116.50, 2135.82),
    Vector3.new(834.07, 108.98, 2093.12),
    Vector3.new(842.37, 106.45, 2050.40),
    Vector3.new(849.92, 102.67, 2011.58),
    Vector3.new(857.57, 105.93, 1978.39),
    Vector3.new(870.18, 106.41, 1929.18),
    Vector3.new(876.40, 111.68, 1903.31),
    Vector3.new(885.24, 111.16, 1863.75),
    Vector3.new(890.00, 109.27, 1834.33),
    Vector3.new(891.92, 106.56, 1796.14),
    Vector3.new(884.69, 111.07, 1762.76),
    Vector3.new(874.90, 122.55, 1728.93),
    Vector3.new(862.18, 124.06, 1696.21),
    Vector3.new(838.82, 115.77, 1663.51),
    Vector3.new(806.48, 104.33, 1635.52),
    Vector3.new(776.60, 96.50, 1616.07),
    Vector3.new(751.87, 97.69, 1602.09),
    Vector3.new(733.54, 102.17, 1592.08),
    Vector3.new(717.47, 103.27, 1583.30),
    Vector3.new(699.08, 106.67, 1573.26),
    Vector3.new(681.11, 108.29, 1563.27),
    Vector3.new(666.07, 111.76, 1554.22),
    Vector3.new(645.92, 109.63, 1541.55),
    Vector3.new(622.04, 109.42, 1525.94),
    Vector3.new(581.21, 105.83, 1498.74),
    Vector3.new(551.78, 104.79, 1488.32),
    Vector3.new(524.64, 103.36, 1479.01),
    Vector3.new(491.58, 102.14, 1467.68),
    Vector3.new(458.86, 100.49, 1456.79),
    Vector3.new(433.67, 99.93, 1448.68),
    Vector3.new(414.07, 101.42, 1442.37),
    Vector3.new(364.14, 104.83, 1426.16),
    Vector3.new(328.33, 104.49, 1414.55),
    Vector3.new(304.50, 108.00, 1408.07),
    Vector3.new(274.23, 109.26, 1400.38),
    Vector3.new(239.20, 103.58, 1397.04),
    Vector3.new(200.26, 100.22, 1399.99),
    Vector3.new(158.83, 105.77, 1403.76),
    Vector3.new(125.36, 107.82, 1406.81),
    Vector3.new(104.67, 110.92, 1408.69),
    Vector3.new(83.43, 108.61, 1408.40),
    Vector3.new(70.37, 108.94, 1400.82),
    Vector3.new(64.65, 108.54, 1388.51),
    Vector3.new(64.20, 110.94, 1376.34),
    Vector3.new(65.96, 112.05, 1367.30)  -- Финиш
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
print("🔄 Генерация финального пути...")

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
                    print("🎉 ФИНИШ ДОСТИГНУТ! Маршрут успешно пройден!")
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

print("✅ Финальный путь построен! Всего точек: " .. #points)
print("🔵 Синяя линия указывает на следующую цель.")
print("⚡ Точки удаляются автоматически в радиусе " .. activationRadius .. " студов.")
