local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ================= НАСТРОЙКИ =================
local folderName = "Пути_Финал_42" -- Имя папки изменено под количество точек (0-42)
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

-- КООРДИНАТЫ ПУТИ (Сгенерировано из ваших данных: Старт + 42 точки)
local points = {
    Vector3.new(1118.11, 1133.63, 12498.01), -- Старт
    Vector3.new(1127.44, 1133.63, 12498.11), -- 1
    Vector3.new(1147.40, 1133.08, 12497.99), -- 2
    Vector3.new(1161.84, 1133.08, 12497.90), -- 3
    Vector3.new(1174.07, 1133.08, 12497.83), -- 4
    Vector3.new(1195.83, 1133.08, 12497.72), -- 5
    Vector3.new(1213.30, 1133.08, 12498.74), -- 6
    Vector3.new(1238.75, 1133.08, 12499.47), -- 7
    Vector3.new(1239.50, 1133.08, 12514.92), -- 8
    Vector3.new(1240.14, 1133.08, 12539.64), -- 9
    Vector3.new(1239.92, 1133.08, 12564.35), -- 10
    Vector3.new(1239.74, 1133.08, 12585.23), -- 11
    Vector3.new(1239.49, 1133.08, 12613.12), -- 12
    Vector3.new(1240.07, 1133.08, 12640.47), -- 13
    Vector3.new(1239.78, 1133.08, 12673.95), -- 14
    Vector3.new(1239.48, 1133.08, 12704.20), -- 15
    Vector3.new(1239.34, 1133.08, 12727.82), -- 16
    Vector3.new(1267.42, 1133.08, 12729.25), -- 17
    Vector3.new(1306.74, 1133.08, 12731.07), -- 18
    Vector3.new(1355.33, 1133.08, 12729.56), -- 19
    Vector3.new(1377.02, 1133.08, 12730.32), -- 20
    Vector3.new(1377.58, 1133.08, 12754.07), -- 21
    Vector3.new(1377.10, 1133.08, 12790.80), -- 22
    Vector3.new(1377.13, 1133.08, 12830.21), -- 23
    Vector3.new(1376.75, 1133.08, 12873.93), -- 24
    Vector3.new(1361.18, 1133.08, 12875.37), -- 25
    Vector3.new(1318.54, 1133.08, 12875.88), -- 26
    Vector3.new(1270.67, 1133.08, 12875.52), -- 27
    Vector3.new(1224.79, 1147.75, 12875.24), -- 28
    Vector3.new(1183.70, 1165.35, 12876.03), -- 29
    Vector3.new(1166.95, 1166.21, 12875.43), -- 30
    Vector3.new(1165.93, 1166.21, 12853.78), -- 31
    Vector3.new(1166.37, 1166.21, 12812.16), -- 32
    Vector3.new(1178.72, 1166.21, 12811.45), -- 33
    Vector3.new(1200.59, 1174.50, 12810.60), -- 34
    Vector3.new(1229.56, 1187.57, 12810.53), -- 35
    Vector3.new(1255.95, 1197.94, 12809.45), -- 36
    Vector3.new(1272.92, 1197.97, 12809.34), -- 37
    Vector3.new(1273.03, 1197.97, 12779.09), -- 38
    Vector3.new(1273.03, 1197.97, 12747.70), -- 39
    Vector3.new(1295.17, 1197.97, 12743.80), -- 40
    Vector3.new(1328.71, 1197.97, 12744.57), -- 41
    Vector3.new(1339.84, 1197.97, 12745.03)  -- 42 (Финиш)
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