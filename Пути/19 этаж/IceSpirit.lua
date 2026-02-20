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

-- ОБНОВЛЕННЫЕ КООРДИНАТЫ ПУТИ
local points = {
    Vector3.new(1025.89, -1216.77, 4143.80), -- Старт
    Vector3.new(1109.67, -1223.00, 4157.17),
    Vector3.new(1161.30, -1210.57, 4165.72),
    Vector3.new(1240.79, -1210.99, 4158.58),
    Vector3.new(1342.91, -1223.35, 4165.08),
    Vector3.new(1462.90, -1223.00, 4156.08),
    Vector3.new(1520.07, -1209.95, 4155.73),
    Vector3.new(1537.03, -1188.15, 4154.35),
    Vector3.new(1570.66, -1209.97, 4156.22),
    Vector3.new(1736.05, -1210.62, 4158.16),
    Vector3.new(1736.40, -1209.51, 3983.17),
    Vector3.new(1738.61, -1210.62, 3854.71),
    Vector3.new(1738.99, -1210.67, 3646.77),
    Vector3.new(1866.26, -1210.62, 3650.90),
    Vector3.new(1860.75, -1209.00, 3550.55),
    Vector3.new(1861.89, -1210.48, 3436.70),
    Vector3.new(1861.60, -1209.97, 3317.32),
    Vector3.new(1859.44, -1209.97, 3203.88),
    Vector3.new(1859.86, -1210.62, 3131.60),
    Vector3.new(1984.54, -1210.62, 3136.62),
    Vector3.new(1979.86, -1209.67, 3045.12),
    Vector3.new(1979.85, -1207.56, 2893.88),
    Vector3.new(1980.89, -1209.97, 2765.18),
    Vector3.new(1980.85, -1207.97, 2715.79),
    Vector3.new(2114.49, -1209.82, 2717.84),
    Vector3.new(2367.20, -1210.63, 2720.84),
    Vector3.new(2372.28, -1207.56, 2510.99),
    Vector3.new(2486.84, -1209.11, 2508.24),
    Vector3.new(2498.05, -1115.04, 2506.47),
    Vector3.new(2608.97, -1111.56, 2509.38),
    Vector3.new(2611.88, -1113.57, 2390.96),
    Vector3.new(2818.34, -1114.49, 2389.86),
    Vector3.new(2819.96, -1114.62, 2508.73),
    Vector3.new(2819.86, -1112.98, 2593.70),
    Vector3.new(2820.31, -1113.97, 2678.50),
    Vector3.new(2819.35, -1113.97, 2748.77),
    Vector3.new(2818.98, -1111.56, 2841.82),
    Vector3.new(2820.53, -1114.62, 2890.30),
    Vector3.new(2683.10, -1113.97, 2893.50),
    Vector3.new(2526.64, -1114.62, 2894.89),
    Vector3.new(2524.07, -1111.56, 3016.94),
    Vector3.new(2643.66, -1111.56, 3016.37),
    Vector3.new(2645.08, -1111.18, 3127.27),
    Vector3.new(2643.75, -1111.02, 3214.80),
    Vector3.new(2658.30, -1074.79, 3350.15),
    Vector3.new(2644.20, -1069.01, 3432.07),
    Vector3.new(2645.29, -1071.39, 3545.87),
    Vector3.new(2523.41, -1072.62, 3542.20),
    Vector3.new(2526.35, -1072.62, 3427.69),
    Vector3.new(2318.17, -1072.62, 3425.25),
    Vector3.new(2317.22, -1071.40, 3609.52),
    Vector3.new(2314.78, -1072.63, 3718.35),
    Vector3.new(2470.20, -1069.81, 3717.09),
    Vector3.new(2611.75, -1072.62, 3724.57),
    Vector3.new(2715.84, -1070.74, 3721.01),
    Vector3.new(2821.41, -1072.62, 3721.39),
    Vector3.new(2826.69, -1069.89, 3812.26),
    Vector3.new(2821.12, -1072.79, 3848.02),
    Vector3.new(2826.45, -1080.10, 3889.79),
    Vector3.new(2844.85, -1087.60, 3932.34),
    Vector3.new(2856.81, -1093.87, 3968.17),
    Vector3.new(2862.78, -1101.87, 4013.51),
    Vector3.new(2864.99, -1112.39, 4073.17),
    Vector3.new(2864.52, -1114.47, 4166.01),
    Vector3.new(2860.91, -1113.08, 4283.90),
    Vector3.new(2863.65, -1114.63, 4388.80),
    Vector3.new(2863.41, -1112.06, 4487.88),
    Vector3.new(2862.48, -1112.31, 4587.81),
    Vector3.new(2862.33, -1114.48, 4657.93),
    Vector3.new(2863.51, -1113.08, 4782.25)  -- Финиш
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

-- Функция создания точки (без Touched события, так как проверка будет в Heartbeat)
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
                    print("🎉 ФИНИШ ДОСТИГНУТ!")
                    dynamicLinePart.Transparency = 1
                else
                    -- Опционально: можно вывести сообщение в консоль при прохождении точки
                    -- print("✅ Точка " .. data.label .. " пройдена.")
                end
                
                -- Прерываем цикл, так как структура пути изменилась (точки удалены)
                break 
            end
        end
    end

    -- Отрисовка синей линии к следующей цели
    if targetPos and activePoints[targetIndex] then -- Проверяем, не удалилась ли точка прямо сейчас
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
