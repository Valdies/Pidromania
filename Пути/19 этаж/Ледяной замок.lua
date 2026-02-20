local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Тест"
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

-- ГИГАНТСКИЙ МАРШРУТ (226 точек)
local points = {
    Vector3.new(-2965.72, 214.06, 6201.30), -- Старт
    Vector3.new(-2968.53, 214.06, 6158.94),
    Vector3.new(-2975.86, 209.00, 6111.78),
    Vector3.new(-3009.53, 208.03, 6041.51),
    Vector3.new(-3035.76, 199.31, 5980.30),
    Vector3.new(-3057.10, 191.46, 5914.43),
    Vector3.new(-3102.76, 182.51, 5836.09),
    Vector3.new(-3127.82, 173.13, 5789.60),
    Vector3.new(-3171.99, 135.58, 5702.43),
    Vector3.new(-3127.08, 148.97, 5671.17),
    Vector3.new(-3072.25, 164.70, 5616.58),
    Vector3.new(-3023.91, 162.76, 5565.34),
    Vector3.new(-2979.13, 165.75, 5512.82),
    Vector3.new(-2960.20, 165.67, 5463.62),
    Vector3.new(-2956.53, 158.48, 5397.77),
    Vector3.new(-2977.53, 152.28, 5314.06),
    Vector3.new(-2998.17, 149.00, 5264.40),
    Vector3.new(-3020.73, 149.38, 5211.45),
    Vector3.new(-3046.81, 161.12, 5152.19),
    Vector3.new(-3068.15, 169.01, 5111.61),
    Vector3.new(-3103.40, 169.19, 5057.65),
    Vector3.new(-3133.86, 168.68, 5012.68),
    Vector3.new(-3158.63, 155.40, 4972.00),
    Vector3.new(-3194.06, 140.97, 4913.79),
    Vector3.new(-3215.81, 137.41, 4874.67),
    Vector3.new(-3236.85, 128.67, 4818.43),
    Vector3.new(-3251.04, 120.27, 4769.44),
    Vector3.new(-3259.74, 120.32, 4718.23),
    Vector3.new(-3266.24, 129.68, 4657.82),
    Vector3.new(-3274.28, 129.35, 4605.72),
    Vector3.new(-3280.70, 136.18, 4571.13),
    Vector3.new(-3289.29, 137.25, 4526.67),
    Vector3.new(-3289.42, 125.28, 4471.87),
    Vector3.new(-3280.36, 120.31, 4406.19),
    Vector3.new(-3273.38, 102.79, 4349.80),
    Vector3.new(-3266.17, 98.92, 4293.53),
    Vector3.new(-3263.21, 99.25, 4261.27),
    Vector3.new(-3264.67, 93.72, 4203.14),
    Vector3.new(-3284.76, 97.46, 4160.02),
    Vector3.new(-3323.05, 97.89, 4139.18),
    Vector3.new(-3371.47, 100.47, 4134.21),
    Vector3.new(-3410.85, 109.03, 4137.24),
    Vector3.new(-3450.31, 114.10, 4138.75),
    Vector3.new(-3493.19, 117.92, 4128.67),
    Vector3.new(-3531.78, 114.71, 4101.56),
    Vector3.new(-3559.78, 113.00, 4059.59),
    Vector3.new(-3565.66, 116.88, 4012.34),
    Vector3.new(-3560.03, 124.97, 3974.16),
    Vector3.new(-3545.77, 125.09, 3924.90),
    Vector3.new(-3535.37, 127.36, 3855.13),
    Vector3.new(-3547.77, 127.77, 3809.02),
    Vector3.new(-3574.76, 133.18, 3777.61),
    Vector3.new(-3618.61, 136.99, 3773.44),
    Vector3.new(-3671.01, 140.96, 3780.99),
    Vector3.new(-3721.82, 138.65, 3782.02),
    Vector3.new(-3755.71, 132.81, 3767.03),
    Vector3.new(-3790.16, 122.62, 3731.87),
    Vector3.new(-3819.22, 121.10, 3693.18),
    Vector3.new(-3851.87, 118.95, 3642.12),
    Vector3.new(-3886.88, 121.03, 3599.35),
    Vector3.new(-3937.08, 115.14, 3553.00),
    Vector3.new(-3987.06, 108.43, 3516.22),
    Vector3.new(-4040.38, 108.36, 3500.60),
    Vector3.new(-4097.51, 101.00, 3510.37),
    Vector3.new(-4147.84, 97.61, 3522.18),
    Vector3.new(-4194.90, 98.57, 3524.54),
    Vector3.new(-4257.40, 95.72, 3485.28),
    Vector3.new(-4305.61, 102.28, 3455.40),
    Vector3.new(-4353.54, 112.96, 3421.38),
    Vector3.new(-4376.62, 113.00, 3369.13),
    Vector3.new(-4381.71, 113.21, 3336.87),
    Vector3.new(-4382.36, 119.89, 3285.97),
    Vector3.new(-4385.05, 128.83, 3253.60),
    Vector3.new(-4393.69, 136.81, 3227.52),
    Vector3.new(-4412.56, 138.23, 3206.31),
    Vector3.new(-4448.69, 137.00, 3187.14),
    Vector3.new(-4473.94, 133.32, 3183.18),
    Vector3.new(-4498.24, 127.49, 3186.56),
    Vector3.new(-4522.33, 126.77, 3196.12),
    Vector3.new(-4556.85, 126.81, 3206.68),
    Vector3.new(-4582.41, 124.91, 3211.99),
    Vector3.new(-4624.34, 125.00, 3216.07),
    Vector3.new(-4673.36, 123.79, 3224.39),
    Vector3.new(-4705.13, 119.92, 3230.65),
    Vector3.new(-4736.55, 108.73, 3255.87),
    Vector3.new(-4762.75, 103.64, 3272.69),
    Vector3.new(-4782.97, 97.77, 3294.59),
    Vector3.new(-4815.29, 96.44, 3339.84),
    Vector3.new(-4830.81, 97.49, 3372.73),
    Vector3.new(-4854.56, 101.09, 3404.88),
    Vector3.new(-4884.74, 101.10, 3447.32),
    Vector3.new(-4922.60, 101.09, 3472.00),
    Vector3.new(-4949.87, 101.40, 3501.18),
    Vector3.new(-4985.50, 103.73, 3534.77),
    Vector3.new(-5021.51, 108.98, 3566.67),
    Vector3.new(-5046.18, 112.92, 3586.31),
    Vector3.new(-5096.22, 112.99, 3615.61),
    Vector3.new(-5127.74, 109.76, 3632.41),
    Vector3.new(-5173.82, 98.43, 3655.13),
    Vector3.new(-5216.53, 97.00, 3668.86),
    Vector3.new(-5264.40, 97.69, 3659.47),
    Vector3.new(-5299.24, 101.00, 3633.71),
    Vector3.new(-5329.08, 104.74, 3597.52),
    Vector3.new(-5345.87, 110.05, 3553.91),
    Vector3.new(-5354.35, 113.84, 3511.51),
    Vector3.new(-5354.35, 116.01, 3452.55),
    Vector3.new(-5354.24, 104.63, 3403.67),
    Vector3.new(-5358.91, 107.24, 3352.47),
    Vector3.new(-5375.54, 109.05, 3308.15),
    Vector3.new(-5412.17, 102.69, 3272.59),
    Vector3.new(-5464.43, 107.40, 3253.18),
    Vector3.new(-5516.82, 108.43, 3233.79),
    Vector3.new(-5545.09, 116.74, 3221.45),
    Vector3.new(-5567.71, 116.84, 3206.48),
    Vector3.new(-5595.44, 104.12, 3164.95),
    Vector3.new(-5611.80, 95.86, 3118.65),
    Vector3.new(-5631.84, 97.62, 3060.27),
    Vector3.new(-5641.59, 103.56, 3034.98),
    Vector3.new(-5659.03, 110.26, 2994.54),
    Vector3.new(-5669.73, 118.03, 2972.38),
    Vector3.new(-5687.98, 118.87, 2928.97),
    Vector3.new(-5711.42, 117.29, 2883.16),
    Vector3.new(-5736.82, 119.38, 2802.81),
    Vector3.new(-5763.35, 124.60, 2727.61),
    Vector3.new(-5782.49, 125.02, 2674.09),
    Vector3.new(-5796.14, 132.83, 2638.51),
    Vector3.new(-5810.95, 136.79, 2605.07),
    Vector3.new(-5842.55, 136.17, 2543.46),
    Vector3.new(-5865.30, 144.09, 2487.19),
    Vector3.new(-5878.72, 141.22, 2407.48),
    Vector3.new(-5881.65, 147.37, 2376.38),
    Vector3.new(-5886.87, 150.36, 2324.91),
    Vector3.new(-5900.20, 148.90, 2280.99),
    Vector3.new(-5920.99, 143.98, 2232.15),
    Vector3.new(-5938.99, 134.24, 2191.90),
    Vector3.new(-5947.93, 133.21, 2113.43),
    Vector3.new(-5945.47, 142.00, 2028.47),
    Vector3.new(-5915.62, 152.71, 1962.15),
    Vector3.new(-5883.59, 156.63, 1919.57),
    Vector3.new(-5836.00, 172.46, 1891.64),
    Vector3.new(-5784.92, 187.08, 1872.44),
    Vector3.new(-5751.43, 192.14, 1860.51),
    Vector3.new(-5711.06, 186.37, 1830.26),
    Vector3.new(-5671.95, 185.68, 1800.56),
    Vector3.new(-5639.86, 184.35, 1775.69),
    Vector3.new(-5580.75, 175.94, 1726.20),
    Vector3.new(-5524.76, 188.01, 1678.65),
    Vector3.new(-5473.13, 193.00, 1625.18),
    Vector3.new(-5427.94, 181.09, 1548.63),
    Vector3.new(-5388.16, 177.87, 1480.79),
    Vector3.new(-5368.79, 176.98, 1446.68),
    Vector3.new(-5351.54, 167.36, 1412.09),
    Vector3.new(-5329.49, 145.76, 1358.55),
    Vector3.new(-5302.52, 117.93, 1311.35),
    Vector3.new(-5261.61, 112.41, 1273.84),
    Vector3.new(-5216.95, 112.27, 1230.92),
    Vector3.new(-5158.64, 112.27, 1179.26),
    Vector3.new(-4998.72, 112.25, 1044.32),
    Vector3.new(-4960.74, 113.00, 994.97),
    Vector3.new(-4935.33, 122.51, 947.65),
    Vector3.new(-4904.90, 143.99, 871.59),
    Vector3.new(-4903.25, 161.00, 799.77),
    Vector3.new(-4919.99, 160.92, 722.02),
    Vector3.new(-4941.54, 142.49, 654.64),
    Vector3.new(-4960.35, 136.88, 586.46),
    Vector3.new(-4976.77, 150.76, 513.71),
    Vector3.new(-4970.09, 156.78, 455.08),
    Vector3.new(-4949.76, 153.00, 394.95),
    Vector3.new(-4931.44, 145.00, 338.53),
    Vector3.new(-4892.37, 153.00, 279.66),
    Vector3.new(-4858.65, 156.87, 244.21),
    Vector3.new(-4807.58, 150.31, 212.88),
    Vector3.new(-4769.65, 151.63, 197.20),
    Vector3.new(-4711.71, 150.73, 196.36),
    Vector3.new(-4656.59, 145.95, 212.64),
    Vector3.new(-4603.17, 140.99, 237.42),
    Vector3.new(-4548.33, 141.00, 269.66),
    Vector3.new(-4499.91, 141.00, 290.33),
    Vector3.new(-4439.30, 140.03, 310.76),
    Vector3.new(-4375.31, 140.17, 329.20),
    Vector3.new(-4314.76, 147.49, 342.51),
    Vector3.new(-4264.74, 154.37, 350.89),
    Vector3.new(-4210.13, 159.81, 352.74),
    Vector3.new(-4158.92, 160.52, 341.37),
    Vector3.new(-4118.49, 153.76, 327.44),
    Vector3.new(-4052.98, 145.00, 304.91),
    Vector3.new(-3994.05, 136.70, 280.50),
    Vector3.new(-3932.98, 137.00, 253.81),
    Vector3.new(-3881.90, 142.28, 230.86),
    Vector3.new(-3838.54, 152.37, 209.69),
    Vector3.new(-3791.92, 150.86, 189.32),
    Vector3.new(-3739.12, 129.75, 173.11),
    Vector3.new(-3664.33, 113.71, 156.86),
    Vector3.new(-3592.65, 126.62, 150.75),
    Vector3.new(-3540.92, 133.00, 146.19),
    Vector3.new(-3457.85, 132.85, 138.87),
    Vector3.new(-3420.36, 128.43, 135.80),
    Vector3.new(-3359.98, 132.29, 131.30),
    Vector3.new(-3331.41, 144.40, 128.61),
    Vector3.new(-3313.10, 150.86, 126.88),
    Vector3.new(-3269.54, 158.76, 122.76),
    Vector3.new(-3220.26, 171.97, 118.10),
    Vector3.new(-3184.28, 177.81, 114.72),
    Vector3.new(-3138.43, 186.70, 112.89),
    Vector3.new(-3085.28, 193.61, 113.40),
    Vector3.new(-3048.22, 190.15, 114.51),
    Vector3.new(-3002.65, 176.48, 115.89),
    Vector3.new(-2962.15, 164.58, 115.27),
    Vector3.new(-2909.17, 152.29, 115.86),
    Vector3.new(-2871.50, 149.84, 117.76),
    Vector3.new(-2825.73, 156.99, 119.66),
    Vector3.new(-2775.47, 163.15, 115.82),
    Vector3.new(-2730.21, 162.73, 106.04),
    Vector3.new(-2688.76, 160.84, 97.34),
    Vector3.new(-2648.53, 151.17, 87.95),
    Vector3.new(-2594.35, 149.34, 75.04),
    Vector3.new(-2549.65, 156.37, 67.58),
    Vector3.new(-2503.55, 161.24, 67.30),
    Vector3.new(-2464.97, 163.98, 76.45),
    Vector3.new(-2422.11, 161.64, 91.57),
    Vector3.new(-2382.27, 150.61, 119.50),
    Vector3.new(-2336.37, 144.98, 146.92),
    Vector3.new(-2276.57, 144.62, 182.93),
    Vector3.new(-2249.56, 136.61, 221.16),
    Vector3.new(-2236.48, 146.86, 258.29),
    Vector3.new(-2233.77, 148.97, 305.32)  -- Финиш
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
print("🔄 Генерация пути... (Это может занять пару секунд)")

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
                -- Удаляем из активных, чтобы не проверять снова
                activePoints[idx] = nil
                
                -- Логика удаления пути (точка и все линии до неё)
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
                    print("🎉 ФИНИШ ДОСТИГНУТ! Маршрут из 225 точек пройден!")
                    dynamicLinePart.Transparency = 1
                end
                
                -- Прерываем цикл, так как структура пути изменилась
                break 
            end
        end
    end

    -- Отрисовка синей линии к следующей цели
    if targetPos and activePoints[targetIndex] then
        dynamicLinePart.Transparency = 0
        local distance = (targetPos - playerPos).Magnitude
        
        dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, distance)
        dynamicLinePart.CFrame = CFrame.lookAt(playerPos, targetPos) * CFrame.new(0, 0, -distance / 2)
    else
        dynamicLinePart.Transparency = 1
    end
end)

print("✅ Путь построен! Всего точек: " .. #points)
print("🔵 Синяя линия указывает на следующую цель.")
print("⚡ Точки удаляются автоматически в радиусе " .. activationRadius .. " студов.")