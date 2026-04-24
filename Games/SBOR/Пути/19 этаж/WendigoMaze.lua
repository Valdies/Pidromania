local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Финал_v2"
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

-- ОБНОВЛЕННЫЕ КООРДИНАТЫ ПУТИ (67 точек)
local points = {
    Vector3.new(-3000.11, -565.16, 9126.60), -- Старт
    Vector3.new(-3023.19, -565.16, 9120.55),
    Vector3.new(-3035.88, -562.21, 9117.60),
    Vector3.new(-3039.13, -565.16, 9116.06),
    Vector3.new(-3037.21, -568.98, 9109.86),
    Vector3.new(-3035.02, -574.82, 9102.79),
    Vector3.new(-3033.42, -578.32, 9095.45),
    Vector3.new(-3028.52, -578.32, 9098.90),
    Vector3.new(-3019.48, -578.32, 9101.21),
    Vector3.new(-3014.63, -578.32, 9104.05),
    Vector3.new(-3014.51, -578.32, 9108.55),
    Vector3.new(-3014.66, -578.29, 9116.73),
    Vector3.new(2620.10, -495.20, 8506.08), -- Скачок 1 (Телепорт)
    Vector3.new(2633.42, -495.20, 8505.59),
    Vector3.new(2638.25, -495.20, 8505.53),
    Vector3.new(2648.92, -499.75, 8505.36),
    Vector3.new(2661.13, -504.29, 8505.08),
    Vector3.new(2679.47, -511.97, 8504.65),
    Vector3.new(2698.81, -516.82, 8504.21),
    Vector3.new(2720.81, -516.82, 8504.70),
    Vector3.new(2754.11, -516.82, 8506.46),
    Vector3.new(2774.60, -516.82, 8507.57),
    Vector3.new(2917.10, -491.88, 7408.58), -- Скачок 2 (Длинный переход)
    Vector3.new(2917.49, -491.88, 7385.46),
    Vector3.new(2917.10, -491.88, 7354.99),
    Vector3.new(2916.45, -491.88, 7323.53),
    Vector3.new(2916.16, -491.88, 7288.39),
    Vector3.new(2916.18, -491.88, 7251.60),
    Vector3.new(2931.92, -491.88, 7248.20),
    Vector3.new(2968.40, -491.88, 7249.48),
    Vector3.new(2979.92, -491.88, 7249.22),
    Vector3.new(2979.07, -491.85, 7227.44),
    Vector3.new(2979.32, -492.54, 7199.30),
    Vector3.new(2979.68, -493.46, 7183.96),
    Vector3.new(2994.98, -493.46, 7176.44),
    Vector3.new(3016.62, -493.46, 7173.49),
    Vector3.new(3045.83, -493.46, 7174.19),
    Vector3.new(3073.00, -493.46, 7175.15),
    Vector3.new(3094.46, -493.46, 7182.62),
    Vector3.new(3124.25, -493.27, 7198.87),
    Vector3.new(3153.21, -493.24, 7216.64),
    Vector3.new(3161.97, -493.46, 7221.79),
    Vector3.new(3169.93, -493.46, 7215.47),
    Vector3.new(3172.66, -493.46, 7207.63),
    Vector3.new(3173.50, -493.50, 7187.68),
    Vector3.new(3173.78, -493.40, 7163.07),
    Vector3.new(3172.99, -493.46, 7139.60),
    Vector3.new(3175.72, -493.40, 7132.11),
    Vector3.new(3190.37, -493.46, 7139.73),
    Vector3.new(3214.53, -493.47, 7154.03),
    Vector3.new(3230.21, -493.47, 7161.75),
    Vector3.new(3239.19, -493.39, 7167.39),
    Vector3.new(3266.75, -493.46, 7181.71),
    Vector3.new(3296.01, -493.46, 7182.28),
    Vector3.new(3327.41, -493.47, 7184.36),
    Vector3.new(3352.32, -491.88, 7180.54),
    Vector3.new(3369.05, -491.85, 7171.17),
    Vector3.new(3395.57, -491.88, 7172.92),
    Vector3.new(3411.25, -491.36, 7180.83),
    Vector3.new(3436.87, -493.44, 7181.20),
    Vector3.new(3469.52, -493.40, 7180.97),
    Vector3.new(3482.76, -493.43, 7181.72),
    Vector3.new(3517.13, -880.69, 7151.99), -- Скачок 3 (Изменение высоты)
    Vector3.new(3520.40, -882.73, 7145.71),
    Vector3.new(3527.15, -886.36, 7137.29),
    Vector3.new(3542.75, -889.56, 7137.02),
    Vector3.new(3565.58, -889.56, 7154.20)  -- Финиш
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
print("🔄 Генерация обновленного маршрута...")

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
                    print("🎉 ФИНИШ ДОСТИГНУТ! Маршрут пройден!")
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

print("✅ Обновленный маршрут построен! Всего точек: " .. #points)
print("🔵 Синяя линия указывает на следующую цель.")
print("⚡ Точки удаляются автоматически в радиусе " .. activationRadius .. " студов.")
