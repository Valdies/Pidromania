local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Ultimate"
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

-- ФИНАЛЬНЫЕ КООРДИНАТЫ (266 точек)
local points = {
    Vector3.new(-2965.20, 214.06, 6200.91), -- Старт
    Vector3.new(-2966.81, 214.07, 6181.27),
    Vector3.new(-2968.85, 214.06, 6153.33),
    Vector3.new(-2972.50, 209.00, 6122.49),
    Vector3.new(-2987.32, 209.00, 6081.92),
    Vector3.new(-3002.93, 208.93, 6052.48),
    Vector3.new(-3021.48, 203.86, 6016.69),
    Vector3.new(-3034.23, 199.06, 5980.08),
    Vector3.new(-3044.97, 196.96, 5946.43),
    Vector3.new(-3054.90, 192.58, 5918.75),
    Vector3.new(-3075.09, 183.03, 5877.53),
    Vector3.new(-3094.36, 181.74, 5843.14),
    Vector3.new(-3117.82, 177.50, 5803.12),
    Vector3.new(-3140.80, 163.14, 5771.84),
    Vector3.new(-3158.71, 147.73, 5751.04),
    Vector3.new(-3174.63, 136.70, 5718.90),
    Vector3.new(-3153.54, 139.94, 5688.32),
    Vector3.new(-3128.22, 148.92, 5667.21),
    Vector3.new(-3103.56, 154.49, 5643.81),
    Vector3.new(-3075.16, 164.41, 5617.34),
    Vector3.new(-3044.45, 164.84, 5589.02),
    Vector3.new(-3015.46, 164.12, 5559.67),
    Vector3.new(-2993.19, 165.00, 5537.95),
    Vector3.new(-2971.03, 165.04, 5508.03),
    Vector3.new(-2961.35, 165.12, 5480.18),
    Vector3.new(-2960.09, 164.87, 5446.32),
    Vector3.new(-2956.95, 160.29, 5410.33),
    Vector3.new(-2958.74, 156.67, 5374.52),
    Vector3.new(-2967.29, 153.00, 5342.52),
    Vector3.new(-2981.89, 152.28, 5301.74),
    Vector3.new(-2999.78, 148.98, 5261.98),
    Vector3.new(-3018.69, 148.24, 5217.60),
    Vector3.new(-3035.93, 154.77, 5175.85),
    Vector3.new(-3052.75, 165.22, 5137.05),
    Vector3.new(-3070.49, 169.38, 5103.10),
    Vector3.new(-3092.43, 169.49, 5063.45),
    Vector3.new(-3117.79, 171.83, 5020.60),
    Vector3.new(-3138.58, 163.83, 4989.05),
    Vector3.new(-3162.24, 150.90, 4954.29),
    Vector3.new(-3189.95, 140.98, 4913.57),
    Vector3.new(-3210.34, 137.01, 4876.66),
    Vector3.new(-3231.98, 131.12, 4832.46),
    Vector3.new(-3244.04, 125.14, 4797.95),
    Vector3.new(-3251.97, 117.14, 4753.49),
    Vector3.new(-3261.93, 128.19, 4690.54),
    Vector3.new(-3272.95, 128.98, 4629.35),
    Vector3.new(-3282.27, 133.92, 4580.62),
    Vector3.new(-3291.74, 137.52, 4528.44),
    Vector3.new(-3293.44, 126.79, 4487.93),
    Vector3.new(-3290.91, 125.64, 4450.94),
    Vector3.new(-3284.32, 119.91, 4400.64),
    Vector3.new(-3277.54, 101.81, 4346.47),
    Vector3.new(-3273.05, 98.78, 4301.79),
    Vector3.new(-3267.04, 98.83, 4252.83),
    Vector3.new(-3262.44, 92.51, 4212.58),
    Vector3.new(-3265.61, 97.33, 4180.67),
    Vector3.new(-3289.03, 96.99, 4148.56),
    Vector3.new(-3334.08, 98.52, 4136.09),
    Vector3.new(-3376.38, 100.96, 4133.87),
    Vector3.new(-3419.46, 111.08, 4133.93),
    Vector3.new(-3463.93, 115.61, 4135.08),
    Vector3.new(-3503.66, 118.63, 4126.95),
    Vector3.new(-3530.01, 115.23, 4102.32),
    Vector3.new(-3554.78, 112.94, 4067.17),
    Vector3.new(-3566.01, 113.22, 4030.07),
    Vector3.new(-3562.36, 123.08, 3986.02),
    Vector3.new(-3554.06, 125.36, 3943.76),
    Vector3.new(-3544.65, 125.51, 3909.75),
    Vector3.new(-3537.14, 127.10, 3876.81),
    Vector3.new(-3533.79, 127.48, 3843.56),
    Vector3.new(-3540.66, 127.83, 3807.03),
    Vector3.new(-3559.17, 132.99, 3781.95),
    Vector3.new(-3591.97, 132.26, 3769.75),
    Vector3.new(-3629.12, 140.09, 3771.93),
    Vector3.new(-3670.83, 141.07, 3783.36),
    Vector3.new(-3702.39, 137.61, 3786.42),
    Vector3.new(-3736.42, 138.19, 3779.22),
    Vector3.new(-3763.87, 129.79, 3761.07),
    Vector3.new(-3787.14, 123.99, 3734.78),
    Vector3.new(-3805.93, 120.19, 3707.58),
    Vector3.new(-3832.50, 121.67, 3667.76),
    Vector3.new(-3857.37, 118.78, 3630.68),
    Vector3.new(-3880.10, 121.12, 3600.75),
    Vector3.new(-3912.93, 118.35, 3566.04),
    Vector3.new(-3943.19, 116.23, 3539.45),
    Vector3.new(-3981.20, 108.87, 3517.80),
    Vector3.new(-4016.47, 108.06, 3504.99),
    Vector3.new(-4059.39, 106.56, 3502.28),
    Vector3.new(-4098.90, 101.00, 3514.68),
    Vector3.new(-4134.67, 99.20, 3529.29),
    Vector3.new(-4168.48, 97.01, 3534.28),
    Vector3.new(-4198.68, 99.55, 3521.84),
    Vector3.new(-4240.49, 95.72, 3500.87),
    Vector3.new(-4270.93, 95.72, 3479.79),
    Vector3.new(-4301.19, 99.35, 3459.75),
    Vector3.new(-4332.30, 110.77, 3435.25),
    Vector3.new(-4356.76, 113.08, 3409.87),
    Vector3.new(-4377.10, 112.99, 3371.04),
    Vector3.new(-4386.12, 115.83, 3324.80),
    Vector3.new(-4384.17, 119.88, 3285.37),
    Vector3.new(-4388.16, 130.85, 3249.43),
    Vector3.new(-4401.19, 137.27, 3221.35),
    Vector3.new(-4426.98, 137.71, 3196.28),
    Vector3.new(-4461.96, 135.85, 3183.78),
    Vector3.new(-4491.11, 129.52, 3181.67),
    Vector3.new(-4519.58, 126.74, 3194.16),
    Vector3.new(-4555.67, 126.89, 3206.27),
    Vector3.new(-4599.10, 124.98, 3214.63),
    Vector3.new(-4647.37, 125.03, 3224.53),
    Vector3.new(-4683.85, 123.39, 3233.22),
    Vector3.new(-4722.34, 113.60, 3242.13),
    Vector3.new(-4759.77, 104.95, 3264.30),
    Vector3.new(-4787.56, 96.96, 3299.52),
    Vector3.new(-4810.13, 96.73, 3345.69),
    Vector3.new(-4836.00, 99.93, 3383.65),
    Vector3.new(-4871.61, 101.10, 3417.73),
    Vector3.new(-4897.99, 101.10, 3451.86),
    Vector3.new(-4934.39, 101.05, 3479.64),
    Vector3.new(-4963.60, 102.67, 3512.57),
    Vector3.new(-5001.49, 105.00, 3548.68),
    Vector3.new(-5039.45, 111.95, 3575.45),
    Vector3.new(-5082.64, 113.00, 3601.91),
    Vector3.new(-5120.35, 111.98, 3624.56),
    Vector3.new(-5147.41, 105.52, 3638.93),
    Vector3.new(-5189.27, 96.45, 3660.33),
    Vector3.new(-5236.82, 97.54, 3672.15),
    Vector3.new(-5278.51, 97.03, 3655.31),
    Vector3.new(-5309.78, 101.00, 3627.28),
    Vector3.new(-5332.73, 105.00, 3590.22),
    Vector3.new(-5346.09, 109.83, 3549.78),
    Vector3.new(-5351.83, 115.51, 3503.92),
    Vector3.new(-5353.30, 115.85, 3452.11),
    Vector3.new(-5353.54, 104.59, 3409.89),
    Vector3.new(-5356.88, 105.15, 3358.06),
    Vector3.new(-5374.94, 109.75, 3316.20),
    Vector3.new(-5398.36, 104.88, 3279.44),
    Vector3.new(-5432.08, 103.29, 3260.83),
    Vector3.new(-5473.17, 107.48, 3247.31),
    Vector3.new(-5512.86, 107.92, 3236.00),
    Vector3.new(-5548.40, 117.08, 3219.29),
    Vector3.new(-5573.65, 112.59, 3191.05),
    Vector3.new(-5599.08, 102.00, 3149.19),
    Vector3.new(-5617.07, 94.95, 3101.99),
    Vector3.new(-5631.94, 97.62, 3058.54),
    Vector3.new(-5645.02, 105.25, 3024.64),
    Vector3.new(-5658.91, 111.20, 2990.61),
    Vector3.new(-5673.98, 120.03, 2956.58),
    Vector3.new(-5696.91, 118.29, 2907.08),
    Vector3.new(-5716.54, 117.49, 2854.64),
    Vector3.new(-5737.07, 119.52, 2798.31),
    Vector3.new(-5758.99, 123.98, 2739.13),
    Vector3.new(-5775.46, 125.00, 2694.78),
    Vector3.new(-5797.26, 132.24, 2640.65),
    Vector3.new(-5817.05, 136.80, 2597.05),
    Vector3.new(-5840.27, 135.25, 2551.37),
    Vector3.new(-5860.24, 140.97, 2508.44),
    Vector3.new(-5875.35, 141.75, 2464.57),
    Vector3.new(-5880.94, 142.24, 2419.08),
    Vector3.new(-5882.45, 148.54, 2368.50),
    Vector3.new(-5883.77, 149.21, 2320.08),
    Vector3.new(-5896.69, 148.97, 2283.17),
    Vector3.new(-5909.96, 144.97, 2256.65),
    Vector3.new(-5926.67, 142.98, 2221.73),
    Vector3.new(-5941.45, 133.01, 2176.31),
    Vector3.new(-5949.29, 133.24, 2135.71),
    Vector3.new(-5953.57, 137.70, 2087.45),
    Vector3.new(-5951.78, 140.22, 2044.39),
    Vector3.new(-5937.48, 145.56, 2005.16),
    Vector3.new(-5912.19, 152.93, 1957.46),
    Vector3.new(-5893.90, 148.10, 1928.94),
    Vector3.new(-5869.45, 164.13, 1910.49),
    Vector3.new(-5834.02, 173.11, 1890.57),
    Vector3.new(-5787.71, 186.18, 1875.09),
    Vector3.new(-5749.22, 192.22, 1858.39),
    Vector3.new(-5699.86, 186.51, 1824.08),
    Vector3.new(-5662.62, 184.85, 1793.11),
    Vector3.new(-5623.31, 180.94, 1761.74),
    Vector3.new(-5586.31, 175.62, 1729.90),
    Vector3.new(-5549.80, 181.42, 1698.47),
    Vector3.new(-5516.17, 188.99, 1669.25),
    Vector3.new(-5486.70, 192.71, 1635.23),
    Vector3.new(-5463.76, 189.05, 1601.44),
    Vector3.new(-5434.49, 182.25, 1555.95),
    Vector3.new(-5407.12, 178.29, 1512.81),
    Vector3.new(-5386.90, 176.79, 1476.71),
    Vector3.new(-5362.96, 175.07, 1434.56),
    Vector3.new(-5339.99, 160.23, 1391.91),
    Vector3.new(-5321.18, 143.22, 1356.25),
    Vector3.new(-5299.79, 118.34, 1318.56),
    Vector3.new(-5268.39, 112.26, 1282.28),
    Vector3.new(-5234.73, 115.22, 1251.83),
    Vector3.new(-5197.16, 112.27, 1217.82),
    Vector3.new(-5163.26, 112.27, 1186.61),
    Vector3.new(-5125.49, 111.77, 1151.55),
    Vector3.new(-5094.29, 112.38, 1122.53),
    Vector3.new(-5058.41, 112.27, 1088.77),
    Vector3.new(-5025.24, 111.90, 1056.38),
    Vector3.new(-4993.19, 112.29, 1022.83),
    Vector3.new(-4964.40, 113.00, 985.28),
    Vector3.new(-4942.28, 121.74, 942.55),
    Vector3.new(-4926.36, 132.28, 897.31),
    Vector3.new(-4914.45, 147.52, 856.40),
    Vector3.new(-4914.07, 160.22, 810.55),
    Vector3.new(-4918.18, 161.00, 761.29),
    Vector3.new(-4926.45, 159.26, 714.83),
    Vector3.new(-4938.72, 145.43, 661.37),
    Vector3.new(-4952.03, 135.27, 611.21),
    Vector3.new(-4967.03, 137.00, 560.79),
    Vector3.new(-4977.73, 150.12, 515.48),
    Vector3.new(-4976.73, 157.00, 476.11),
    Vector3.new(-4964.92, 153.05, 427.23),
    Vector3.new(-4952.00, 153.00, 391.54),
    Vector3.new(-4930.00, 145.00, 343.87),
    Vector3.new(-4902.61, 150.48, 292.66),
    Vector3.new(-4878.46, 158.77, 249.00),
    Vector3.new(-4887.65, 165.51, 198.28),
    Vector3.new(-4906.87, 171.97, 149.99),
    Vector3.new(-4926.15, 186.90, 101.85),
    Vector3.new(-4941.84, 189.00, 52.10),
    Vector3.new(-4949.16, 185.02, -0.22),
    Vector3.new(-4947.68, 187.15, -49.95),
    Vector3.new(-4940.49, 188.48, -97.86),
    Vector3.new(-4923.97, 174.22, -146.32),
    Vector3.new(-4905.08, 169.99, -177.56),
    Vector3.new(-4871.02, 166.29, -199.95),
    Vector3.new(-4824.99, 158.77, -222.27),
    Vector3.new(-4777.21, 146.34, -241.23),
    Vector3.new(-4741.27, 142.28, -256.25),
    Vector3.new(-4711.30, 132.48, -273.41),
    Vector3.new(-4677.32, 118.81, -298.87),
    Vector3.new(-4646.29, 112.25, -331.40),
    Vector3.new(-4615.56, 113.57, -372.40),
    Vector3.new(-4585.97, 112.11, -412.50),
    Vector3.new(-4551.44, 112.23, -458.82),
    Vector3.new(-4521.67, 112.23, -498.73),
    Vector3.new(-4484.69, 112.54, -548.33),
    Vector3.new(-4447.68, 112.19, -597.97),
    Vector3.new(-4416.62, 112.15, -639.62),
	Vector3.new(-4374.49, 111.97, -690.74),
	Vector3.new(-4367.31, 112.99, -740.81),
	Vector3.new(-4366.55, 117.74, -790.30),
	Vector3.new(-4372.98, 129.93, -832.39),
	Vector3.new(-4379.47, 135.81, -855.28),
	Vector3.new(-4395.76, 137.04, -883.94),
	Vector3.new(-4429.40, 148.43, -922.87),
	Vector3.new(-4462.28, 151.34, -960.91),
	Vector3.new(-4500.28, 153.02, -1002.46),
	Vector3.new(-4534.83, 160.62, -1037.53),
	Vector3.new(-4576.85, 165.11, -1074.09),
	Vector3.new(-4619.04, 172.59, -1106.74),
	Vector3.new(-4654.66, 173.00, -1144.40),
	Vector3.new(-4681.74, 174.52, -1177.18),
	Vector3.new(-4704.76, 166.65, -1218.84),
	Vector3.new(-4719.35, 155.34, -1267.37),
	Vector3.new(-4726.19, 153.00, -1311.21),
	Vector3.new(-4734.05, 155.66, -1356.99),
	Vector3.new(-4761.45, 155.31, -1406.84),
	Vector3.new(-4782.32, 150.68, -1438.94),
	Vector3.new(-4806.55, 142.18, -1479.02),
	Vector3.new(-4830.83, 144.96, -1498.51),
	Vector3.new(-4877.23, 144.21, -1519.99),
	Vector3.new(-4927.81, 141.00, -1534.36),
	Vector3.new(-4977.43, 135.57, -1537.78),
	Vector3.new(-5028.25, 140.91, -1536.07),
	Vector3.new(-5078.62, 142.28, -1532.90),
	Vector3.new(-5118.10, 139.44, -1531.05),
	Vector3.new(-5172.74, 141.10, -1534.43),
	Vector3.new(-5228.57, 154.55, -1539.01),
	Vector3.new(-5271.11, 159.93, -1542.29),
	Vector3.new(-5318.89, 171.49, -1545.69),
	Vector3.new(-5352.29, 190.16, -1541.26),
	Vector3.new(-5379.92, 191.50, -1540.39),
	Vector3.new(-5437.20, 191.50, -1541.02),
	Vector3.new(-5486.46, 192.83, -1541.01),
	Vector3.new(-5523.20, 191.50, -1540.22)  -- Финиш
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
print("🔄 Генерация ультра-маршрута...")

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
                    print("🎉 ФИНИШ ДОСТИГНУТ! Ультра-маршрут пройден!")
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

print("✅ Ультра-маршрут построен! Всего точек: " .. #points)
print("🔵 Синяя линия указывает на следующую цель.")
print("⚡ Точки удаляются автоматически в радиусе " .. activationRadius .. " студов.")
