print("[MAIN] Запуск TheApocalypse Hub (Магнит 150 + DeadTrees)...")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer

local function getGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then return coreGui end
    return player:WaitForChild("PlayerGui")
end

-- ====== КАСТОМНЫЙ КУРСОР ======
local cursorGui = Instance.new("ScreenGui")
cursorGui.Name = "ApocCustomCursor"
cursorGui.ResetOnSpawn = false
cursorGui.DisplayOrder = 9999999
cursorGui.IgnoreGuiInset = true
cursorGui.Parent = getGuiParent()

local cursorDot = Instance.new("Frame")
cursorDot.Size = UDim2.new(0, 6, 0, 6)
cursorDot.AnchorPoint = Vector2.new(0.5, 0.5)
cursorDot.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
cursorDot.BorderSizePixel = 0
Instance.new("UICorner", cursorDot).CornerRadius = UDim.new(1, 0)
cursorDot.Parent = cursorGui

RunService.RenderStepped:Connect(function()
    local mouseLoc = UserInputService:GetMouseLocation()
    cursorDot.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)
end)
UserInputService.MouseIconEnabled = false

-- ====== БАЗА ОБЪЕКТОВ ======
local GAME_OBJECTS = {
    Trees = {"Tree1", "Tree2", "Tree3", "Tree4", "Tree5", "Palm1", "Palm2", "Palm3", "DeadTree1", "DeadTree2", "DeadTree3"},
    Ores = {"IronOre", "CopperOre", "Coal", "Stone", "Sandstone"},
    Loot = {"CommonLoot", "UncommonLoot", "RareLoot"},
    Plants = {"BlueberryBush", "StrawberryBush", "PotatoPlant"}
}

local keyMap = {
    ["1"] = "One", ["2"] = "Two", ["3"] = "Three", ["4"] = "Four", ["5"] = "Five",
    ["6"] = "Six", ["7"] = "Seven", ["8"] = "Eight", ["9"] = "Nine", ["0"] = "Zero"
}
local function parseKey(str) return keyMap[str] or str end

-- ====== НАСТРОЙКИ СИСТЕМЫ ======
local currentLang = "ru"
local FOLDER_NAME = "ApocalypseHub"
local FILE_NAME = FOLDER_NAME .. "/Config.json"

local Settings = {
    TreeKey = "One", OreKey = "Four",
    MasterFarm = false
}

local SelectedTargets = {
    Trees = false, IronOre = false, CopperOre = false, Coal = false, Stone = false, Sandstone = false,
    CommonLoot = false, UncommonLoot = false, RareLoot = false, Plants = false
}

local ActiveWaypoints = {}
local targetWaypoint = nil 

local translations = {
    ru = {
        hubTitle = "Apocalypse Hub",
        helpTab = "Помощь", farmTab = "Фарм", settingsTab = "Настройки", langTab = "Язык",
        helpText = "ИНСТРУКЦИЯ:\n\n1. E -> G = Открыть/Закрыть меню.\n2. E -> C = Создать Вейпоинт (точку).\n3. T = Телепорт к точке (в прицеле).\n4. Мастер-Фарм вкл/выкл на 'H'.\n5. АУРА: Деревья и руды сами прилетают к тебе (радиус 150, до 10 шт. за раз).\n6. К сундукам и растениям персонаж телепортируется сам.",
        trees = "Деревья (Все типы)", plants = "Растения (Ягоды и др.)",
        keyTrees = "Кнопка (Деревья):", keyOres = "Кнопка (Руды/Камни):",
        masterFarm = "МАСТЕР-ФАРМ (ВКЛ/ВЫКЛ 'H')",
        catTrees = "Деревья, Листья", catOres = "Руды и Камни", catPlantsChests = "Растения и Сундуки",
        clearWaypoints = "Очистить все Вейпоинты"
    },
    en = {
        hubTitle = "Apocalypse Hub",
        helpTab = "Help", farmTab = "Farm", settingsTab = "Settings", langTab = "Language",
        helpText = "INSTRUCTIONS:\n\n1. E -> G = Open menu.\n2. E -> C = Create Waypoint.\n3. T = Teleport to Waypoint.\n4. Master Farm toggle via 'H'.\n5. AURA: Trees & Ores fly to you (150 studs, max 10).\n6. Auto-teleport to Chests & Plants.",
        trees = "Trees (All types)", plants = "Plants (Berries etc.)",
        keyTrees = "Key (Trees):", keyOres = "Key (Ores/Stones):",
        masterFarm = "MASTER FARM (Toggle 'H')",
        catTrees = "Trees, Leaves", catOres = "Ores and Stones", catPlantsChests = "Plants & Chests",
        clearWaypoints = "Clear all Waypoints"
    }
}
setmetatable(translations, {__index = function(t, k) return t.ru end})
local function T(key) return translations[currentLang] and translations[currentLang][key] or translations.ru[key] or key end

local function SaveConfig()
    if writefile and isfolder then
        if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
        local data = { lang = currentLang, Settings = Settings, SelectedTargets = SelectedTargets }
        pcall(function() writefile(FILE_NAME, HttpService:JSONEncode(data)) end)
    end
end
local function LoadConfig()
    if readfile and isfile and isfile(FILE_NAME) then
        pcall(function()
            local data = HttpService:JSONDecode(readfile(FILE_NAME))
            if data.lang then currentLang = data.lang end
            if data.Settings then for k,v in pairs(data.Settings) do Settings[k] = v end end
            if data.SelectedTargets then for k,v in pairs(data.SelectedTargets) do SelectedTargets[k] = v end end
        end)
    end
end
LoadConfig()

-- ====== СИСТЕМА ВЕЙПОИНТОВ ======
local waypointFolder = Instance.new("Folder")
waypointFolder.Name = "ApocWaypoints"
waypointFolder.Parent = Workspace

local function CreateWaypoint(name, color)
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local pos = char.HumanoidRootPart.Position + Vector3.new(0, 12, 0) 
    
    local wpPart = Instance.new("Part")
    wpPart.Size = Vector3.new(3, 3, 3)
    wpPart.Position = pos
    wpPart.Anchored = true
    wpPart.CanCollide = false
    wpPart.Material = Enum.Material.Neon
    wpPart.Color = color
    wpPart.Transparency = 0.2
    wpPart.CFrame = CFrame.new(pos) * CFrame.Angles(math.rad(45), math.rad(45), math.rad(45)) 
    wpPart.Parent = waypointFolder
    
    local highlight = Instance.new("Highlight")
    highlight.Parent = wpPart
    highlight.Adornee = wpPart
    highlight.FillColor = color
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillTransparency = 0.4 
    highlight.OutlineTransparency = 0.4
    
    local bgui = Instance.new("BillboardGui")
    bgui.Parent = wpPart
    bgui.Adornee = wpPart
    bgui.Size = UDim2.new(0, 150, 0, 40)
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    
    local label = Instance.new("TextLabel")
    label.Parent = bgui
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 20
    
    table.insert(ActiveWaypoints, { part = wpPart, highlight = highlight, label = label, position = pos })
end

local function ClearWaypoints()
    for _, wp in ipairs(ActiveWaypoints) do
        if wp.part then wp.part:Destroy() end
    end
    table.clear(ActiveWaypoints)
end

RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local bestDot = -1
    local bestWp = nil
    
    for _, wp in ipairs(ActiveWaypoints) do
        if wp.part and wp.part.Parent then
            wp.part.CFrame = wp.part.CFrame * CFrame.Angles(0, math.rad(1), 0)
            local dir = (wp.part.Position - cam.CFrame.Position).Unit
            local dot = cam.CFrame.LookVector:Dot(dir)
            
            if dot > 0.96 then 
                wp.highlight.FillTransparency = 0.05
                wp.highlight.OutlineTransparency = 0
                wp.label.TextSize = 24
                if dot > bestDot then bestDot = dot; bestWp = wp end
            else 
                wp.highlight.FillTransparency = 0.4
                wp.highlight.OutlineTransparency = 0.4
                wp.label.TextSize = 18
            end
        end
    end
    targetWaypoint = bestWp
end)

-- ====== АНТИ-ЛАГ СИСТЕМА (КЭШИРОВАНИЕ) ======
local cachedTargets = { tree = {}, ore = {}, plant = {}, loot = {} }

local function refreshCache()
    for k, v in pairs(cachedTargets) do table.clear(v) end
    local folder = Workspace:FindFirstChild("Spawned")
    if not folder then return end
    
    local activeNames = {}
    if SelectedTargets.Trees then for _,v in ipairs(GAME_OBJECTS.Trees) do activeNames[v] = "tree" end end
    if SelectedTargets.Plants then for _,v in ipairs(GAME_OBJECTS.Plants) do activeNames[v] = "plant" end end
    for _, ore in ipairs(GAME_OBJECTS.Ores) do if SelectedTargets[ore] then activeNames[ore] = "ore" end end
    for _, loot in ipairs(GAME_OBJECTS.Loot) do if SelectedTargets[loot] then activeNames[loot] = "loot" end end

    if next(activeNames) == nil then return end

    local descendants = folder:GetDescendants()
    for i = 1, #descendants do
        if i % 800 == 0 then task.wait() end 
        local obj = descendants[i]
        local cat = activeNames[obj.Name]
        if cat and (obj:IsA("Model") or obj:IsA("BasePart")) then
            table.insert(cachedTargets[cat], obj)
        end
    end
end

task.spawn(function()
    while true do
        if Settings.MasterFarm then refreshCache() end
        task.wait(2)
    end
end)

local function getValidPosition(obj)
    if not obj or not obj.Parent then return nil end
    if obj:IsA("Model") then
        return obj.PrimaryPart and obj.PrimaryPart.Position or obj:GetPivot().Position
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

-- ====== ЛОГИКА ФАРМА И СУПЕР-КЛИКЕРА ======
local farmLoopActive = false
local isAttacking = false
local activeKeyStr = nil

-- КЛИКЕР 15 CPS
task.spawn(function()
    while true do
        if Settings.MasterFarm and isAttacking then
            pcall(function()
                local character = player.Character
                if character and activeKeyStr and Enum.KeyCode[activeKeyStr] then
                    local hasTool = character:FindFirstChildOfClass("Tool")
                    if not hasTool then
                        VIM:SendKeyEvent(true, Enum.KeyCode[activeKeyStr], false, game)
                        task.wait(0.02)
                        VIM:SendKeyEvent(false, Enum.KeyCode[activeKeyStr], false, game)
                    end
                end

                local viewportSize = workspace.CurrentCamera.ViewportSize
                local clickX = math.floor(viewportSize.X / 2)
                local clickY = math.floor(viewportSize.Y / 2)
                
                VIM:SendMouseButtonEvent(clickX, clickY, 0, true, game, 0)
                task.wait(0.01)
                VIM:SendMouseButtonEvent(clickX, clickY, 0, false, game, 0)
            end)
            task.wait(0.056)
        else
            task.wait(0.1)
        end
    end
end)

local function executeFarmStep()
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local charPos = rootPart.Position
    local frontCF = rootPart.CFrame * CFrame.new(0, 0, -4)
    local foundList = {}

    -- 1. МАГНИТ (Деревья и Руды - Радиус 150)
    for _, obj in ipairs(cachedTargets.tree) do
        local pos = getValidPosition(obj)
        if pos then
            local dist = (pos - charPos).Magnitude
            if dist <= 150 then table.insert(foundList, {obj = obj, dist = dist, cat = "tree"}) end
        end
    end
    for _, obj in ipairs(cachedTargets.ore) do
        local pos = getValidPosition(obj)
        if pos then
            local dist = (pos - charPos).Magnitude
            if dist <= 150 then table.insert(foundList, {obj = obj, dist = dist, cat = "ore"}) end
        end
    end

    local pulledCount = 0
    local hasTree, hasOre = false, false

    if #foundList > 0 then
        table.sort(foundList, function(a, b) return a.dist < b.dist end)
        for i = 1, math.min(10, #foundList) do
            local item = foundList[i]
            local obj = item.obj
            if item.cat == "tree" then hasTree = true end
            if item.cat == "ore" then hasOre = true end
            
            pcall(function()
                for _, d in ipairs(obj:GetDescendants()) do
                    if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
                end
                if obj:IsA("BasePart") then obj.Anchored = true; obj.CanCollide = false end
                if obj:IsA("Model") then obj:PivotTo(frontCF) else obj.CFrame = frontCF end
            end)
            pulledCount = pulledCount + 1
        end
    end

    if pulledCount > 0 then
        activeKeyStr = hasTree and Settings.TreeKey or Settings.OreKey
        isAttacking = true
        return 
    end

    -- 2. ТЕЛЕПОРТ (Сундуки и Растения)
    isAttacking = false
    activeKeyStr = nil
    
    local nearestObj = nil
    local nearestDist = math.huge
    
    local function checkTeleportTargets(list)
        for _, obj in ipairs(list) do
            local pos = getValidPosition(obj)
            if pos then
                local dist = (pos - charPos).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestObj = obj
                end
            end
        end
    end
    
    checkTeleportTargets(cachedTargets.plant)
    checkTeleportTargets(cachedTargets.loot)
    
    if nearestObj then
        local tPos = getValidPosition(nearestObj)
        rootPart.CFrame = CFrame.new(tPos + Vector3.new(0, 3, 0))
        VIM:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

local function toggleMasterFarm(state)
    Settings.MasterFarm = state
    
    if not state then
        isAttacking = false
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.Anchored = false
        end
    else
        refreshCache() 
    end

    if state and not farmLoopActive then
        farmLoopActive = true
        task.spawn(function()
            while Settings.MasterFarm do
                executeFarmStep()
                task.wait(0.15) 
            end
            farmLoopActive = false
            isAttacking = false
        end)
    end
    SaveConfig()
end

local updateMasterToggleVisual = nil

-- ====== ПОСТРОЕНИЕ UI ======
local screenGuiMain = nil
local miniGui = nil
local mainFrame = nil
local waypointFrame = nil

local function createToggleSwitch(parent, label, initialEnabled, onToggle)
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(1, -15, 0, 45)
    switchFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = parent
    Instance.new("UICorner", switchFrame).CornerRadius = UDim.new(0, 9)
    
    local labelText = Instance.new("TextLabel")
    labelText.Text = label
    labelText.Size = UDim2.new(0, 270, 1, 0)
    labelText.BackgroundTransparency = 1
    labelText.TextColor3 = Color3.fromRGB(240, 240, 255)
    labelText.Font = Enum.Font.GothamSemibold
    labelText.TextSize = 16
    labelText.TextXAlignment = Enum.TextXAlignment.Left
    labelText.Position = UDim2.new(0, 15, 0, 0)
    labelText.Parent = switchFrame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 60, 0, 30)
    toggleBg.Position = UDim2.new(1, -70, 0.5, -15)
    toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = switchFrame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 15)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 24, 0, 24)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleBg
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 12)
    
    local isEnabled = initialEnabled
    
    local function updateToggle(forcedState)
        if forcedState ~= nil then isEnabled = forcedState end
        if isEnabled then
            toggleBg.BackgroundColor3 = Color3.fromRGB(50, 100, 255)
            toggleKnob.Position = UDim2.new(1, -27, 0.5, -12)
        else
            toggleBg.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
            toggleKnob.Position = UDim2.new(0, 3, 0.5, -12)
        end
    end
    updateToggle()
    
    switchFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isEnabled = not isEnabled
            updateToggle()
            onToggle(isEnabled)
        end
    end)
    return switchFrame, updateToggle
end

local function buildMiniUI()
    if miniGui then miniGui:Destroy() end
    miniGui = Instance.new("ScreenGui")
    miniGui.Name = "ApocMiniHub"
    miniGui.ResetOnSpawn = false
    miniGui.DisplayOrder = 100 
    miniGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    miniGui.Parent = getGuiParent()

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 270, 0, 60)
    frame.Position = UDim2.new(1, -290, 1, -80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = miniGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local switchFrame, updateFunc = createToggleSwitch(frame, T("masterFarm"), Settings.MasterFarm, function(state)
        toggleMasterFarm(state)
    end)
    
    switchFrame.Size = UDim2.new(1, -10, 1, -10)
    switchFrame.Position = UDim2.new(0, 5, 0, 5)
    updateMasterToggleVisual = updateFunc
end

local function createCategoryHeader(parent, text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Text = text
    lbl.Size = UDim2.new(1, 0, 0, 25)
    lbl.Position = UDim2.new(0, 10, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(150, 150, 160)
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = parent
    return yPos + 30
end

local function rebuildGUI()
    if screenGuiMain then screenGuiMain:Destroy() end
    
    screenGuiMain = Instance.new("ScreenGui")
    screenGuiMain.Name = "ApocalypseHubMain"
    screenGuiMain.ResetOnSpawn = false
    screenGuiMain.DisplayOrder = 100 
    screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGuiMain.Parent = getGuiParent()
    
    mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 700, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Visible = false
    mainFrame.Parent = screenGuiMain
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 15)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 15)
    
    local title = Instance.new("TextLabel")
    title.Text = T("hubTitle")
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Size = UDim2.new(0, 300, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 200, 1, -50)
    leftPanel.Position = UDim2.new(0, 0, 0, 50)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    leftPanel.Parent = mainFrame
    Instance.new("UICorner", leftPanel).CornerRadius = UDim.new(0, 12)
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -210, 1, -60)
    rightPanel.Position = UDim2.new(0, 205, 0, 55)
    rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    rightPanel.Parent = mainFrame
    Instance.new("UICorner", rightPanel).CornerRadius = UDim.new(0, 12)
    
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -10, 1, -10)
    contentContainer.Position = UDim2.new(0, 5, 0, 5)
    contentContainer.BackgroundTransparency = 1
    contentContainer.ScrollBarThickness = 4
    contentContainer.Parent = rightPanel

    waypointFrame = Instance.new("Frame")
    waypointFrame.Size = UDim2.new(0, 350, 0, 220)
    waypointFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
    waypointFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    waypointFrame.Active = true
    waypointFrame.Draggable = true
    waypointFrame.Visible = false
    waypointFrame.Parent = screenGuiMain
    Instance.new("UICorner", waypointFrame).CornerRadius = UDim.new(0, 12)
    
    local wpTitle = Instance.new("TextLabel")
    wpTitle.Text = "Новая Точка (Waypoint)"
    wpTitle.Size = UDim2.new(1, 0, 0, 40)
    wpTitle.BackgroundTransparency = 1
    wpTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpTitle.Font = Enum.Font.GothamBold
    wpTitle.TextSize = 18
    wpTitle.Parent = waypointFrame
    
    local wpInput = Instance.new("TextBox")
    wpInput.Size = UDim2.new(1, -40, 0, 40)
    wpInput.Position = UDim2.new(0, 20, 0, 50)
    wpInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    wpInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    wpInput.PlaceholderText = "Введите название..."
    wpInput.Font = Enum.Font.GothamSemibold
    wpInput.TextSize = 16
    wpInput.Parent = waypointFrame
    Instance.new("UICorner", wpInput).CornerRadius = UDim.new(0, 8)
    
    local colors = { Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50), Color3.fromRGB(50,150,255), Color3.fromRGB(255,255,50), Color3.fromRGB(200,50,255) }
    local selectedColor = colors[1]
    local colorSelectorFrame = Instance.new("Frame")
    colorSelectorFrame.Size = UDim2.new(1, -40, 0, 30)
    colorSelectorFrame.Position = UDim2.new(0, 20, 0, 100)
    colorSelectorFrame.BackgroundTransparency = 1
    colorSelectorFrame.Parent = waypointFrame
    
    local colorBtns = {}
    for i, c in ipairs(colors) do
        local cBtn = Instance.new("TextButton")
        cBtn.Size = UDim2.new(0, 30, 0, 30)
        cBtn.Position = UDim2.new(0, (i-1)*40, 0, 0)
        cBtn.BackgroundColor3 = c
        cBtn.Text = ""
        cBtn.Parent = colorSelectorFrame
        Instance.new("UICorner", cBtn).CornerRadius = UDim.new(1, 0)
        
        cBtn.MouseButton1Click:Connect(function()
            selectedColor = c
            for _, b in ipairs(colorBtns) do b.BorderSizePixel = 0 end
            cBtn.BorderSizePixel = 3
            cBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
        end)
        table.insert(colorBtns, cBtn)
    end
    colorBtns[1].BorderSizePixel = 3
    colorBtns[1].BorderColor3 = Color3.fromRGB(255, 255, 255)
    
    local btnWpCreate = Instance.new("TextButton")
    btnWpCreate.Size = UDim2.new(0.5, -25, 0, 40)
    btnWpCreate.Position = UDim2.new(0, 20, 0, 150)
    btnWpCreate.BackgroundColor3 = Color3.fromRGB(50, 150, 70)
    btnWpCreate.TextColor3 = Color3.new(1,1,1)
    btnWpCreate.Font = Enum.Font.GothamBold
    btnWpCreate.TextSize = 16
    btnWpCreate.Text = "Создать"
    btnWpCreate.Parent = waypointFrame
    Instance.new("UICorner", btnWpCreate).CornerRadius = UDim.new(0, 8)
    
    local btnWpCancel = Instance.new("TextButton")
    btnWpCancel.Size = UDim2.new(0.5, -25, 0, 40)
    btnWpCancel.Position = UDim2.new(0.5, 5, 0, 150)
    btnWpCancel.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    btnWpCancel.TextColor3 = Color3.new(1,1,1)
    btnWpCancel.Font = Enum.Font.GothamBold
    btnWpCancel.TextSize = 16
    btnWpCancel.Text = "Отмена"
    btnWpCancel.Parent = waypointFrame
    Instance.new("UICorner", btnWpCancel).CornerRadius = UDim.new(0, 8)
    
    btnWpCreate.MouseButton1Click:Connect(function()
        local name = wpInput.Text
        if name == "" then name = "Точка" end
        CreateWaypoint(name, selectedColor)
        waypointFrame.Visible = false
        wpInput.Text = ""
    end)
    btnWpCancel.MouseButton1Click:Connect(function() waypointFrame.Visible = false end)

    local menuItems = {}
    local function createMenuBtn(name, icon, index)
        local btn = Instance.new("TextButton")
        btn.Text = "  " .. icon .. "  " .. name
        btn.Size = UDim2.new(1, -20, 0, 45)
        btn.Position = UDim2.new(0, 10, 0, 10 + (index * 55))
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 16
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = leftPanel
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)
        table.insert(menuItems, btn)
        return btn
    end

    local function clearContent()
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end

    local function showHelp()
        clearContent()
        local txt = Instance.new("TextLabel")
        txt.Text = T("helpText")
        txt.Size = UDim2.new(1, -20, 1, -20)
        txt.Position = UDim2.new(0, 10, 0, 10)
        txt.BackgroundTransparency = 1
        txt.TextColor3 = Color3.fromRGB(220, 220, 255)
        txt.Font = Enum.Font.Gotham
        txt.TextSize = 16
        txt.TextWrapped = true
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.TextYAlignment = Enum.TextYAlignment.Top
        txt.Parent = contentContainer
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    end

    local function showFarm()
        clearContent()
        local y = 10
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catTrees") .. " ---", y)
        local swTrees = createToggleSwitch(contentContainer, T("trees"), SelectedTargets.Trees, function(s)
            SelectedTargets.Trees = s; SaveConfig()
        end)
        swTrees.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catOres") .. " ---", y)
        for _, ore in ipairs(GAME_OBJECTS.Ores) do
            local sw = createToggleSwitch(contentContainer, "Руда: " .. ore, SelectedTargets[ore], function(s)
                SelectedTargets[ore] = s; SaveConfig()
            end)
            sw.Position = UDim2.new(0, 5, 0, y); y = y + 55
        end
        
        y = createCategoryHeader(contentContainer, "--- " .. T("catPlantsChests") .. " ---", y)
        local swPlants = createToggleSwitch(contentContainer, T("plants"), SelectedTargets.Plants, function(s)
            SelectedTargets.Plants = s; SaveConfig()
        end)
        swPlants.Position = UDim2.new(0, 5, 0, y); y = y + 55
        
        for _, loot in ipairs(GAME_OBJECTS.Loot) do
            local sw = createToggleSwitch(contentContainer, "Сундук: " .. loot, SelectedTargets[loot], function(s)
                SelectedTargets[loot] = s; SaveConfig()
            end)
            sw.Position = UDim2.new(0, 5, 0, y); y = y + 55
        end

        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    local function showSettings()
        clearContent()
        local y = 10
        local function makeKeybind(label, settingKey)
            local lbl = Instance.new("TextLabel")
            lbl.Text = label
            lbl.Size = UDim2.new(0, 300, 0, 40)
            lbl.Position = UDim2.new(0, 10, 0, y)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.Font = Enum.Font.GothamSemibold
            lbl.TextSize = 16
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = contentContainer

            local box = Instance.new("TextBox")
            box.Size = UDim2.new(0, 100, 0, 35)
            box.Position = UDim2.new(1, -120, 0, y + 2)
            box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            box.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            local displayVal = Settings[settingKey]
            for numStr, enumStr in pairs(keyMap) do if enumStr == Settings[settingKey] then displayVal = numStr break end end
            box.Text = displayVal
            
            box.Font = Enum.Font.GothamBold
            box.TextSize = 16
            box.Parent = contentContainer
            Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)

            box.FocusLost:Connect(function()
                Settings[settingKey] = parseKey(box.Text)
                SaveConfig()
            end)
            y = y + 50
        end

        makeKeybind(T("keyTrees"), "TreeKey")
        makeKeybind(T("keyOres"), "OreKey")
        
        local btnClear = Instance.new("TextButton")
        btnClear.Text = "🗑️ " .. T("clearWaypoints")
        btnClear.Size = UDim2.new(1, -20, 0, 45)
        btnClear.Position = UDim2.new(0, 10, 0, y + 20)
        btnClear.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        btnClear.TextColor3 = Color3.fromRGB(255, 255, 255)
        btnClear.Font = Enum.Font.GothamBold
        btnClear.TextSize = 16
        btnClear.Parent = contentContainer
        Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 8)
        
        btnClear.MouseButton1Click:Connect(function() ClearWaypoints() end)
        
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y + 80)
    end

    local function showLanguage()
        clearContent()
        local langs = { {id="ru", name="Русский"}, {id="en", name="English"} }
        local y = 10
        for _, l in ipairs(langs) do
            local btn = Instance.new("TextButton")
            btn.Text = l.name
            btn.Size = UDim2.new(1, -20, 0, 45)
            btn.Position = UDim2.new(0, 10, 0, y)
            btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 18
            btn.Parent = contentContainer
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

            btn.MouseButton1Click:Connect(function()
                currentLang = l.id
                SaveConfig()
                rebuildGUI()
            end)
            y = y + 55
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, y)
    end

    local btnHelp = createMenuBtn(T("helpTab"), "❓", 0)
    local btnFarm = createMenuBtn(T("farmTab"), "⛏️", 1)
    local btnSettings = createMenuBtn(T("settingsTab"), "⚙️", 2)
    local btnLang = createMenuBtn(T("langTab"), "🌍", 3)

    local function selectBtn(targetBtn)
        for _, b in ipairs(menuItems) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        targetBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end

    btnHelp.MouseButton1Click:Connect(function() selectBtn(btnHelp) showHelp() end)
    btnFarm.MouseButton1Click:Connect(function() selectBtn(btnFarm) showFarm() end)
    btnSettings.MouseButton1Click:Connect(function() selectBtn(btnSettings) showSettings() end)
    btnLang.MouseButton1Click:Connect(function() selectBtn(btnLang) showLanguage() end)

    selectBtn(btnHelp)
    showHelp()
    buildMiniUI()
end

rebuildGUI()

local ePressedTime = 0
local TIME_WINDOW = 0.5 

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    local kc = input.KeyCode

    if Settings.MasterFarm and (kc == Enum.KeyCode.T or kc == Enum.KeyCode.E or kc == Enum.KeyCode.Q or kc == Enum.KeyCode.G) then
        if updateMasterToggleVisual then updateMasterToggleVisual(false) end
        toggleMasterFarm(false)
    end

    if kc == Enum.KeyCode.E then
        ePressedTime = tick()
        if mainFrame and mainFrame.Visible then mainFrame.Visible = false end
        if waypointFrame and waypointFrame.Visible then waypointFrame.Visible = false end
        
    elseif kc == Enum.KeyCode.G then
        if (tick() - ePressedTime) <= TIME_WINDOW then
            if mainFrame and not mainFrame.Visible then
                waypointFrame.Visible = false
                mainFrame.Visible = true 
            end
        end
        
    elseif kc == Enum.KeyCode.C then
        if (tick() - ePressedTime) <= TIME_WINDOW then
            if waypointFrame and not waypointFrame.Visible then
                mainFrame.Visible = false
                waypointFrame.Visible = true
            end
        end
        
    elseif kc == Enum.KeyCode.T then
        if targetWaypoint and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(targetWaypoint.position - Vector3.new(0, 9, 0))
        end
        
    elseif kc == Enum.KeyCode.H then
        local newState = not Settings.MasterFarm
        if updateMasterToggleVisual then updateMasterToggleVisual(newState) end
        toggleMasterFarm(newState) 
    end
end)

if Settings.MasterFarm then toggleMasterFarm(true) end