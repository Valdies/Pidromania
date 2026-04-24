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

-- НОВЫЕ КООРДИНАТЫ ПУТИ (Детализированные)
local points = {
    Vector3.new(1027.23, -1217.62, 4144.53), -- Старт
    Vector3.new(1070.43, -1223.00, 4152.26),
    Vector3.new(1156.01, -1212.07, 4166.36),
    Vector3.new(1228.32, -1209.03, 4152.75),
    Vector3.new(1306.51, -1223.00, 4163.91),
    Vector3.new(1401.11, -1221.46, 4158.93),
    Vector3.new(1498.69, -1210.37, 4157.01),
    Vector3.new(1536.41, -1187.65, 4153.20),
    Vector3.new(1558.88, -1209.97, 4156.14),
    Vector3.new(1608.14, -1209.97, 4157.79),
    Vector3.new(1673.86, -1208.15, 4159.80),
    Vector3.new(1729.91, -1210.43, 4160.76),
    Vector3.new(1738.81, -1207.56, 4099.53),
    Vector3.new(1739.74, -1207.56, 4044.18),
    Vector3.new(1736.23, -1209.31, 3985.81),
    Vector3.new(1737.78, -1207.56, 3912.22),
    Vector3.new(1736.12, -1210.62, 3858.66),
    Vector3.new(1795.68, -1208.61, 3857.56),
    Vector3.new(1862.15, -1210.62, 3859.61),
    Vector3.new(1859.29, -1207.74, 3914.19),
    Vector3.new(1858.65, -1212.07, 3997.54),
    Vector3.new(1883.78, -1212.07, 4021.50),
    Vector3.new(1863.06, -1211.30, 4060.21),
    Vector3.new(1861.16, -1210.09, 4087.02),
    Vector3.new(1859.90, -1209.97, 4156.71),
    Vector3.new(1857.90, -1209.97, 4253.76),
    Vector3.new(1858.91, -1209.97, 4340.46),
    Vector3.new(1858.54, -1207.78, 4410.99),
    Vector3.new(1858.26, -1209.97, 4487.23),
    Vector3.new(1859.66, -1209.97, 4575.74),
    Vector3.new(1858.28, -1209.97, 4633.37),
    Vector3.new(1858.40, -1208.10, 4662.30),
    Vector3.new(1919.32, -1209.97, 4663.53),
    Vector3.new(1974.62, -1207.59, 4661.15),
    Vector3.new(1978.15, -1209.97, 4597.61),
    Vector3.new(1979.90, -1210.63, 4546.20),
    Vector3.new(2040.86, -1207.64, 4544.89),
    Vector3.new(2088.95, -1208.32, 4543.76),
    Vector3.new(2134.65, -1208.11, 4559.16),
    Vector3.new(2184.10, -1209.08, 4577.39)  -- Финиш
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
                    print("🎉 ФИНИШ ДОСТИГНУТ!")
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
