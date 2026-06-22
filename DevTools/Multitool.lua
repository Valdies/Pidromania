local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local GlobalENV = getgenv and getgenv() or _G
local Typeof = typeof

local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

local CONFIG = {
    UiOffsetX = -290,      
    MainOffsetY = 15,      
    SettingsOffsetY = 250, 
    SpyOffsetY = 460,      
    DroneSpeed = 90,
    Acceleration = 3,
    HoverHeight = 5,
    Collision = false, -- По умолчанию ВЫКЛЮЧЕНО (проходит сквозь стены)
    TurnSpeed = 2.5,
    Deadzone = 0.05
}

local STYLE = {
    Background = Color3.fromRGB(20, 20, 25),
    Panel = Color3.fromRGB(30, 30, 40),
    Button = Color3.fromRGB(60, 60, 80),
    ButtonHover = Color3.fromRGB(70, 70, 90),
    Accent = Color3.fromRGB(50, 100, 255),   
    ToggleOnColor = Color3.fromRGB(50, 100, 255), 
    TextMain = Color3.fromRGB(200, 220, 255), 
    TextSub = Color3.fromRGB(180, 180, 220),
    Danger = Color3.fromRGB(200, 50, 50),
    InspectColor = Color3.fromRGB(50, 200, 50),
    Success = Color3.fromRGB(0, 200, 100),
    Corner = UDim.new(0, 8),
    Font = Enum.Font.Gotham,
    FontBold = Enum.Font.GothamBold
}

local Settings = { RouteLog = false, Teleport = false, DeleteEnabled = false, InspectEnabled = false, PilotAllowed = false }
local ActiveModes = { Deleting = false, Inspecting = false, Piloting = false }

local listOrder, labelsOrder = {}, {}
local uiName, settingsUiName, spyUiName = "PidromaniaTools", "PidromaniaSettings", "PidromaniaSpy"
local ToggleUpdaters = {}
local isUiVisible = true
local notificationStack = {}
local MAX_NOTIFICATIONS = 3
local NOTIFY_WIDTH = 280
local NOTIFY_HEIGHT = 55
local NOTIFY_GAP = 10

if GlobalENV.QuadcopterConnection then GlobalENV.QuadcopterConnection:Disconnect() end
if Workspace:FindFirstChild("LocalQuadcopter") then pcall(function() Workspace.LocalQuadcopter:Destroy() end) end
if LocalPlayer.PlayerGui:FindFirstChild("DroneUI") then pcall(function() LocalPlayer.PlayerGui.DroneUI:Destroy() end) end

local isPowered = true
local camMode = "Orbit"
local originalStats = {WalkSpeed = 16, JumpPower = 50}
local DroneModel, Hitbox, PrimaryPart, EyePart, linVel, alignOri
local Props = {}
local UI_Elements = {}
local Keys = { W = false, A = false, S = false, D = false, Q = false, E = false }
local currentVelocity = Vector3.zero
local orbitYaw, fpvRotation = 0, CFrame.identity
local propSpin, currentPropSpeed, planeRoll, tiltX, tiltZ = 0, 0, 0, 0, 0

-- Состояния запоминаются и по умолчанию ВКЛЮЧЕНЫ
local DroneState = { Invisible = true, SunMode = true }

local function updateNotificationStack()
    local startY = 75 
    while #notificationStack > MAX_NOTIFICATIONS do
        local oldest = table.remove(notificationStack, 1)
        if oldest and oldest.Frame and oldest.Frame.Parent then
            local tweenOut = TweenService:Create(oldest.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, 1, -oldest.YOffset) })
            tweenOut:Play()
            tweenOut.Completed:Connect(function() pcall(function() oldest.Gui:Destroy() end) end)
        end
    end

    for i, data in ipairs(notificationStack) do
        local frame = data.Frame
        if frame and frame.Parent then
            local offsetIndex = (#notificationStack - i)
            local yPosFromBottom = startY + (offsetIndex * (NOTIFY_HEIGHT + NOTIFY_GAP))
            data.YOffset = yPosFromBottom
            local targetPos = UDim2.new(1, -NOTIFY_WIDTH - 10, 1, -yPosFromBottom)
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
        end
    end
end

local function showNotification(titleText, statusText)
    local notifyId = tick()
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "PidromaniaNotify_" .. tostring(notifyId)
    notificationGui.ResetOnSpawn = false
    notificationGui.IgnoreGuiInset = true 
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, NOTIFY_WIDTH, 0, NOTIFY_HEIGHT)
    frame.Position = UDim2.new(1, 50, 1, -75) 
    frame.BackgroundColor3 = STYLE.Background
    frame.BorderSizePixel = 0
    frame.Parent = notificationGui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local topLabel = Instance.new("TextLabel")
    topLabel.Size = UDim2.new(1, -10, 0, 20); topLabel.Position = UDim2.new(0, 5, 0, 5)
    topLabel.BackgroundTransparency = 1; topLabel.TextColor3 = Color3.fromRGB(180, 180, 220) 
    topLabel.Text = titleText; topLabel.Font = Enum.Font.GothamBold; topLabel.TextSize = 14
    topLabel.TextXAlignment = Enum.TextXAlignment.Center; topLabel.Parent = frame

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -10, 0, 25); nameLabel.Position = UDim2.new(0, 5, 0, 25)
    nameLabel.BackgroundTransparency = 1; nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    nameLabel.Text = statusText; nameLabel.Font = Enum.Font.GothamBold; nameLabel.TextSize = 18
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center; nameLabel.Parent = frame

    table.insert(notificationStack, { Frame = frame, Gui = notificationGui, Id = notifyId, YOffset = 0 })
    updateNotificationStack()

    task.spawn(function()
        task.wait(3) 
        local dataIndex, dataObj
        for i, d in ipairs(notificationStack) do if d.Id == notifyId then dataIndex = i; dataObj = d; break end end
        if dataIndex then
            table.remove(notificationStack, dataIndex)
            updateNotificationStack() 
            if dataObj.Frame and dataObj.Frame.Parent then
                local tweenOut = TweenService:Create(dataObj.Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 50, 1, -dataObj.YOffset) })
                tweenOut:Play()
                tweenOut.Completed:Connect(function() pcall(function() dataObj.Gui:Destroy() end) end)
            end
        end
    end)
end

local function setCharacterState(stateName)
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end

    if stateName == "StartControl" then
        originalStats.WalkSpeed = hum.WalkSpeed
        originalStats.JumpPower = hum.JumpPower
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.Anchored = false 
        hum.PlatformStand = false
    elseif stateName == "Falling" then
        hrp.Anchored = false
        hum.PlatformStand = false
        hum.WalkSpeed = 0
        hum.JumpPower = 0
    elseif stateName == "StopControl" then
        hrp.Anchored = false
        hum.PlatformStand = false
        hum.WalkSpeed = originalStats.WalkSpeed
        hum.JumpPower = originalStats.JumpPower
    end
end

local function updateDroneAppearance()
    if not DroneModel or not Hitbox then return end
    Hitbox.CanCollide = CONFIG.Collision
    
    local alpha = CONFIG.Collision and 0 or 0.4
    if DroneState.Invisible then alpha = 1 end
    
    if PrimaryPart then PrimaryPart.Transparency = alpha end
    if EyePart then EyePart.Transparency = alpha end
    
    for _, p in ipairs(Props) do
        p.Arm.Transparency = alpha
        p.Prop.Transparency = DroneState.Invisible and 1 or (CONFIG.Collision and 0.2 or 0.6)
    end
end

local function updateDroneLighting()
    if not EyePart then return end
    local light = EyePart:FindFirstChildOfClass("PointLight")
    if isPowered then
        if DroneState.SunMode then
            EyePart.Color = Color3.fromRGB(255, 255, 200)
            EyePart.Material = Enum.Material.Neon
            if light then
                light.Color = Color3.fromRGB(255, 255, 200)
                light.Brightness = 15
                light.Range = 60
                light.Shadows = true
                light.Enabled = true
            end
        else
            EyePart.Color = STYLE.ToggleOnColor
            EyePart.Material = Enum.Material.Neon
            if light then
                light.Color = STYLE.ToggleOnColor
                light.Brightness = 2
                light.Range = 12
                light.Shadows = false
                light.Enabled = true
            end
        end
    else
        EyePart.Color = Color3.fromRGB(30, 30, 30)
        EyePart.Material = Enum.Material.Glass
        if light then light.Enabled = false end
    end
end

local function updateDroneUIHints()
    if not ActiveModes.Piloting then return end
    local camText = camMode == "Orbit" and "Орбита" or "Самолет"
    local pwrText = isPowered and "<font color='#00C864'>ВКЛ</font>" or "<font color='#C83232'>ВЫКЛ</font>"
    
    UI_Elements.Status.RichText = true
    UI_Elements.Status.Text = string.format("Кам: %s  |  Питание: %s", camText, pwrText)
    
    if camMode == "Plane" then
        UI_Elements.Hints.Text = "[САМОЛЕТ]\nМышь - Направление\nW / S - Газ / Тормоз\nA / D - Скользить вбок\nJ - Вернуться в орбиту\nB - Выкл/Вкл двигатели"
    else
        UI_Elements.Hints.Text = "[УПРАВЛЕНИЕ]\nW A S D - Движение\nE / Q - Вверх / Вниз\nB - Выкл/Вкл двигатели\nJ - Режим Самолета"
    end
end

local function createDroneVehicle()
    local model = Instance.new("Model")
    model.Name = "LocalQuadcopter"

    Hitbox = Instance.new("Part", model)
    Hitbox.Name = "DroneHitbox"
    Hitbox.Size = Vector3.new(2.2, 0.8, 2.2) 
    Hitbox.Transparency = 1 
    Hitbox.CanCollide = CONFIG.Collision
    Hitbox.Anchored = false
    Hitbox.Massless = false
    Hitbox.CustomPhysicalProperties = PhysicalProperties.new(0.3, 0.1, 0.1, 1, 1)

    local attach = Instance.new("Attachment", Hitbox)
    linVel = Instance.new("LinearVelocity", Hitbox)
    linVel.Attachment0 = attach
    linVel.RelativeTo = Enum.ActuatorRelativeTo.World
    linVel.MaxForce = 150000 
    linVel.VectorVelocity = Vector3.zero

    alignOri = Instance.new("AlignOrientation", Hitbox)
    alignOri.Attachment0 = attach
    alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
    alignOri.MaxTorque = 150000
    alignOri.Responsiveness = 40

    PrimaryPart = Instance.new("Part", model)
    PrimaryPart.Size = Vector3.new(1.2, 0.4, 1.2)
    PrimaryPart.Color = Color3.fromRGB(30, 30, 40)
    PrimaryPart.Anchored = true
    PrimaryPart.CanCollide = false
    PrimaryPart.Massless = true

    EyePart = Instance.new("Part", model)
    EyePart.Size = Vector3.new(0.6, 0.45, 0.6)
    EyePart.Color = STYLE.ToggleOnColor
    EyePart.Material = Enum.Material.Neon
    EyePart.Anchored = true
    EyePart.CanCollide = false
    
    local light = Instance.new("PointLight", EyePart)
    light.Color = STYLE.ToggleOnColor
    light.Brightness = 2
    light.Range = 12

    local offsets = { Vector3.new(0.8, 0.2, 0.8), Vector3.new(-0.8, 0.2, 0.8), Vector3.new(0.8, 0.2, -0.8), Vector3.new(-0.8, 0.2, -0.8) }
    Props = {}
    for i, offset in ipairs(offsets) do
        local arm = Instance.new("Part", model)
        arm.Size = Vector3.new(0.2, 0.2, 1.5)
        arm.Color = STYLE.Button
        arm.Anchored = true
        arm.CanCollide = false

        local prop = Instance.new("Part", model)
        prop.Size = Vector3.new(1.2, 0.1, 1.2)
        prop.Color = Color3.fromRGB(200, 255, 255)
        prop.Material = Enum.Material.ForceField
        prop.Anchored = true
        prop.CanCollide = false
        Instance.new("CylinderMesh", prop)
        
        table.insert(Props, {Arm = arm, Prop = prop, Offset = offset, Index = i})
    end

    model.Parent = Workspace
    return model
end

local function createDroneUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "DroneUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true 
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 280, 0, 395)
    mainFrame.Position = UDim2.new(0, 15, 1, -410)
    mainFrame.BackgroundColor3 = STYLE.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    Instance.new("UICorner", mainFrame).CornerRadius = STYLE.Corner
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = STYLE.Panel
    header.Parent = mainFrame
    Instance.new("UICorner", header).CornerRadius = STYLE.Corner
    
    local headerFiller = Instance.new("Frame")
    headerFiller.Size = UDim2.new(1, 0, 0, 10)
    headerFiller.Position = UDim2.new(0, 0, 1, -10)
    headerFiller.BackgroundColor3 = STYLE.Panel
    headerFiller.BorderSizePixel = 0
    headerFiller.Parent = header

    local title = Instance.new("TextLabel")
    title.Text = "Quadcopter Control"
    title.Size = UDim2.new(1, -15, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = STYLE.TextMain
    title.Font = STYLE.FontBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local listLayout = Instance.new("UIListLayout", contentFrame)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    
    UI_Elements.Status = Instance.new("TextLabel", contentFrame)
    UI_Elements.Status.Size = UDim2.new(1, 0, 0, 20)
    UI_Elements.Status.BackgroundTransparency = 1
    UI_Elements.Status.TextColor3 = STYLE.TextMain
    UI_Elements.Status.Font = STYLE.Font
    UI_Elements.Status.TextSize = 13
    UI_Elements.Status.TextXAlignment = Enum.TextXAlignment.Left

    UI_Elements.Speed = Instance.new("TextLabel", contentFrame)
    UI_Elements.Speed.Size = UDim2.new(1, 0, 0, 20)
    UI_Elements.Speed.BackgroundTransparency = 1
    UI_Elements.Speed.TextColor3 = Color3.fromRGB(100, 200, 255)
    UI_Elements.Speed.Font = STYLE.FontBold
    UI_Elements.Speed.TextSize = 13
    UI_Elements.Speed.TextXAlignment = Enum.TextXAlignment.Left
    
    local speedFrame = Instance.new("Frame", contentFrame)
    speedFrame.Size = UDim2.new(1, 0, 0, 30)
    speedFrame.BackgroundTransparency = 1
    
    local btnMinus = Instance.new("TextButton", speedFrame)
    btnMinus.Size = UDim2.new(0, 35, 1, 0)
    btnMinus.Text = "-"
    btnMinus.BackgroundColor3 = STYLE.Button
    btnMinus.TextColor3 = Color3.new(1, 1, 1)
    btnMinus.Font = STYLE.FontBold
    btnMinus.TextSize = 18
    Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 6)
    
    UI_Elements.MaxSpeedTxt = Instance.new("TextLabel", speedFrame)
    UI_Elements.MaxSpeedTxt.Size = UDim2.new(1, -80, 1, 0)
    UI_Elements.MaxSpeedTxt.Position = UDim2.new(0, 40, 0, 0)
    UI_Elements.MaxSpeedTxt.BackgroundTransparency = 1
    UI_Elements.MaxSpeedTxt.TextColor3 = STYLE.TextMain
    UI_Elements.MaxSpeedTxt.Font = STYLE.FontBold
    UI_Elements.MaxSpeedTxt.TextSize = 13
    
    local btnPlus = Instance.new("TextButton", speedFrame)
    btnPlus.Size = UDim2.new(0, 35, 1, 0)
    btnPlus.Position = UDim2.new(1, -35, 0, 0)
    btnPlus.Text = "+"
    btnPlus.BackgroundColor3 = STYLE.Button
    btnPlus.TextColor3 = Color3.new(1, 1, 1)
    btnPlus.Font = STYLE.FontBold
    btnPlus.TextSize = 18
    Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 6)

    local function updateSpeedUI() UI_Elements.MaxSpeedTxt.Text = "Лимит: " .. CONFIG.DroneSpeed end
    local function changeSpeed(amount)
        if amount > 0 then CONFIG.DroneSpeed = CONFIG.DroneSpeed == 1 and 5 or math.min(300, CONFIG.DroneSpeed + 5)
        else CONFIG.DroneSpeed = CONFIG.DroneSpeed == 5 and 1 or math.max(1, CONFIG.DroneSpeed - 5) end
        updateSpeedUI()
    end

    btnMinus.MouseButton1Click:Connect(function() changeSpeed(-5) end)
    btnPlus.MouseButton1Click:Connect(function() changeSpeed(5) end)

    -- КНОПКА КОЛЛИЗИИ
    local btnCol = Instance.new("TextButton", contentFrame)
    btnCol.Size = UDim2.new(1, 0, 0, 30)
    btnCol.Text = CONFIG.Collision and "Коллизия: ВКЛ" or "Коллизия: ВЫКЛ"
    btnCol.BackgroundColor3 = CONFIG.Collision and STYLE.Success or STYLE.Danger
    btnCol.TextColor3 = Color3.new(1, 1, 1)
    btnCol.Font = STYLE.FontBold
    btnCol.TextSize = 12
    Instance.new("UICorner", btnCol).CornerRadius = UDim.new(0, 6)

    btnCol.MouseButton1Click:Connect(function()
        CONFIG.Collision = not CONFIG.Collision
        btnCol.Text = CONFIG.Collision and "Коллизия: ВКЛ" or "Коллизия: ВЫКЛ"
        btnCol.BackgroundColor3 = CONFIG.Collision and STYLE.Success or STYLE.Danger
        updateDroneAppearance()
    end)
    
    -- КНОПКА НЕВИДИМОСТИ
    local btnInvis = Instance.new("TextButton", contentFrame)
    btnInvis.Size = UDim2.new(1, 0, 0, 30)
    btnInvis.Text = DroneState.Invisible and "Невидимость: ВКЛ" or "Невидимость: ВЫКЛ"
    btnInvis.BackgroundColor3 = DroneState.Invisible and STYLE.Success or STYLE.Danger
    btnInvis.TextColor3 = Color3.new(1, 1, 1)
    btnInvis.Font = STYLE.FontBold
    btnInvis.TextSize = 12
    Instance.new("UICorner", btnInvis).CornerRadius = UDim.new(0, 6)

    btnInvis.MouseButton1Click:Connect(function()
        DroneState.Invisible = not DroneState.Invisible
        btnInvis.Text = DroneState.Invisible and "Невидимость: ВКЛ" or "Невидимость: ВЫКЛ"
        btnInvis.BackgroundColor3 = DroneState.Invisible and STYLE.Success or STYLE.Danger
        updateDroneAppearance()
    end)

    -- КНОПКА СОЛНЦА
    local btnSun = Instance.new("TextButton", contentFrame)
    btnSun.Size = UDim2.new(1, 0, 0, 30)
    btnSun.Text = DroneState.SunMode and "Солнце: ВКЛ" or "Солнце: ВЫКЛ"
    btnSun.BackgroundColor3 = DroneState.SunMode and STYLE.Success or STYLE.Danger
    btnSun.TextColor3 = Color3.new(1, 1, 1)
    btnSun.Font = STYLE.FontBold
    btnSun.TextSize = 12
    Instance.new("UICorner", btnSun).CornerRadius = UDim.new(0, 6)

    btnSun.MouseButton1Click:Connect(function()
        DroneState.SunMode = not DroneState.SunMode
        btnSun.Text = DroneState.SunMode and "Солнце: ВКЛ" or "Солнце: ВЫКЛ"
        btnSun.BackgroundColor3 = DroneState.SunMode and STYLE.Success or STYLE.Danger
        updateDroneLighting()
    end)
    
    local separator = Instance.new("Frame", contentFrame)
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.BackgroundColor3 = STYLE.Button
    separator.BorderSizePixel = 0

    UI_Elements.Hints = Instance.new("TextLabel", contentFrame)
    UI_Elements.Hints.Size = UDim2.new(1, 0, 0, 120)
    UI_Elements.Hints.BackgroundTransparency = 1
    UI_Elements.Hints.TextColor3 = STYLE.TextSub
    UI_Elements.Hints.TextXAlignment = Enum.TextXAlignment.Left
    UI_Elements.Hints.TextYAlignment = Enum.TextYAlignment.Top
    UI_Elements.Hints.Font = STYLE.Font
    UI_Elements.Hints.TextSize = 12

    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    updateSpeedUI()
    return screenGui
end

local function getSafeDronePosition()
    local pos = Camera.CFrame.Position
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pos = LocalPlayer.Character.HumanoidRootPart.Position
    end
    if pos.Y < -400 or pos.Y ~= pos.Y then
        local spawns = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("SpawnLocation") then table.insert(spawns, obj) end
        end
        if #spawns > 0 then return spawns[math.random(1, #spawns)].Position + Vector3.new(0, 15, 0)
        else return Vector3.new(0, 150, 0) end
    end
    return pos + Vector3.new(0, CONFIG.HoverHeight, 0)
end

local function handleDroneInput(actionName, inputState, inputObject)
    if not ActiveModes.Piloting then return Enum.ContextActionResult.Pass end
    local isPressed = (inputState == Enum.UserInputState.Begin)
    local key = inputObject.KeyCode
    
    if key == Enum.KeyCode.W then Keys.W = isPressed
    elseif key == Enum.KeyCode.A then Keys.A = isPressed
    elseif key == Enum.KeyCode.S then Keys.S = isPressed
    elseif key == Enum.KeyCode.D then Keys.D = isPressed
    elseif key == Enum.KeyCode.Q then Keys.Q = isPressed
    elseif key == Enum.KeyCode.E then Keys.E = isPressed
    elseif key == Enum.KeyCode.B and isPressed then
        isPowered = not isPowered
        updateDroneLighting()
        updateDroneUIHints()
    elseif key == Enum.KeyCode.J and isPressed then
        camMode = camMode == "Orbit" and "Plane" or "Orbit"
        if camMode == "Orbit" then
            Camera.CameraType = Enum.CameraType.Custom
            Camera.CameraSubject = PrimaryPart
            local _, y, _ = fpvRotation:ToOrientation()
            orbitYaw = y
        else
            Camera.CameraType = Enum.CameraType.Scriptable
            fpvRotation = CFrame.Angles(0, orbitYaw, 0)
        end
        updateDroneUIHints()
    end
    return Enum.ContextActionResult.Sink 
end

local function toggleDroneSystem(state)
    if state then
        isPowered = true
        
        -- Настройки (DroneState.Invisible, DroneState.SunMode, CONFIG.Collision) 
        -- теперь не сбрасываются и сохраняют свои значения.
        
        DroneModel = createDroneVehicle()
        createDroneUI()
        updateDroneAppearance()
        updateDroneLighting()
        
        Hitbox.Position = getSafeDronePosition()
        orbitYaw = math.atan2(-Camera.CFrame.LookVector.X, -Camera.CFrame.LookVector.Z)
        fpvRotation = CFrame.Angles(0, orbitYaw, 0)
        tiltX, tiltZ = 0, 0 
        
        Camera.CameraType = Enum.CameraType.Custom
        Camera.CameraSubject = PrimaryPart
        
        setCharacterState("StartControl")
        updateDroneUIHints()
        
        ContextActionService:BindActionAtPriority(
            "DroneControlsOverride", handleDroneInput, false, Enum.ContextActionPriority.High.Value + 10,
            Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D, Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.B, Enum.KeyCode.J
        )
    else
        Camera.CameraType = Enum.CameraType.Custom
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        setCharacterState("StopControl") 
        ContextActionService:UnbindAction("DroneControlsOverride")
        
        if DroneModel then DroneModel:Destroy() end
        if LocalPlayer.PlayerGui:FindFirstChild("DroneUI") then LocalPlayer.PlayerGui.DroneUI:Destroy() end
        for k in pairs(Keys) do Keys[k] = false end
    end
end

-- =====================================
-- СОЗДАНИЕ ИНТЕРФЕЙСОВ...
-- =====================================
local function createMainUI()
    if CoreGui:FindFirstChild(uiName) then CoreGui[uiName]:Destroy() end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = uiName; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true; screenGui.Parent = CoreGui
    local frame = Instance.new("Frame"); frame.Name = "MainFrame"; frame.Size = UDim2.new(0, 280, 0, 230); frame.Position = UDim2.new(1, CONFIG.UiOffsetX, 0, CONFIG.MainOffsetY); frame.BackgroundColor3 = STYLE.Background; frame.BorderSizePixel = 0; frame.Parent = screenGui; Instance.new("UICorner", frame).CornerRadius = STYLE.Corner
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 40); header.BackgroundColor3 = STYLE.Panel; header.Parent = frame; Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel"); title.Text = "Pidromania Tools"; title.Size = UDim2.new(1, -15, 1, 0); title.Position = UDim2.new(0, 15, 0, 0); title.BackgroundTransparency = 1; title.TextColor3 = STYLE.TextMain; title.Font = STYLE.FontBold; title.TextSize = 16; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Name = "ListContainer"; scrollFrame.Size = UDim2.new(1, -10, 1, -90); scrollFrame.Position = UDim2.new(0, 5, 0, 45); scrollFrame.BackgroundTransparency = 1; scrollFrame.ScrollBarThickness = 4; scrollFrame.ScrollBarImageColor3 = STYLE.Button; scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y; scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0); scrollFrame.Parent = frame; Instance.new("UIListLayout", scrollFrame).Padding = UDim.new(0, 4)
    local copyBtnFrame = Instance.new("Frame"); copyBtnFrame.Size = UDim2.new(1, -10, 0, 35); copyBtnFrame.Position = UDim2.new(0, 5, 1, -40); copyBtnFrame.BackgroundTransparency = 1; copyBtnFrame.Parent = frame
    local copyBtn = Instance.new("TextButton"); copyBtn.Name = "CopyAllBtn"; copyBtn.Size = UDim2.new(1, 0, 1, 0); copyBtn.BackgroundColor3 = STYLE.Button; copyBtn.TextColor3 = Color3.fromRGB(240, 245, 255); copyBtn.Text = "COPY DATA"; copyBtn.Font = STYLE.FontBold; copyBtn.TextSize = 14; copyBtn.Parent = copyBtnFrame; Instance.new("UICorner", copyBtn).CornerRadius = STYLE.Corner
    copyBtn.MouseButton1Click:Connect(function()
        if #listOrder == 0 then copyBtn.BackgroundColor3 = STYLE.Danger; copyBtn.Text = "EMPTY!"; task.delay(1, function() copyBtn.BackgroundColor3 = STYLE.Button; copyBtn.Text = "COPY DATA" end); return end
        local fullText = ""
        for i, coords in ipairs(listOrder) do fullText ..= labelsOrder[i] .. " - " .. coords .. "\n" end
        if setclipboard then setclipboard(fullText:sub(1, -2)) end
        copyBtn.BackgroundColor3 = STYLE.Success; copyBtn.Text = "COPIED"
        task.delay(1, function() copyBtn.BackgroundColor3 = STYLE.Button; copyBtn.Text = "COPY DATA" end)
    end)
end

local function addCoordinateToUI(coordsString, label)
    local container = CoreGui:FindFirstChild(uiName):FindFirstChild("MainFrame"):FindFirstChild("ListContainer")
    if not container then return end
    local entry = Instance.new("Frame"); entry.Size = UDim2.new(1, 0, 0, 24); entry.BackgroundTransparency = 1; entry.Parent = container
    local textLabel = Instance.new("TextLabel"); textLabel.Text = label .. " - " .. coordsString; textLabel.Size = UDim2.new(1, -5, 1, 0); textLabel.Position = UDim2.new(0, 5, 0, 0); textLabel.BackgroundTransparency = 1; textLabel.TextColor3 = Color3.fromRGB(255, 255, 255); textLabel.Font = STYLE.Font; textLabel.TextSize = 16; textLabel.TextXAlignment = Enum.TextXAlignment.Left; textLabel.Parent = entry
    task.wait(); container.CanvasPosition = Vector2.new(0, container.AbsoluteCanvasSize.Y)
end

local function createSettingsUI()
    if CoreGui:FindFirstChild(settingsUiName) then CoreGui[settingsUiName]:Destroy() end
    local screenGui = Instance.new("ScreenGui"); screenGui.Name = settingsUiName; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true; screenGui.Parent = CoreGui
    local frame = Instance.new("Frame"); frame.Name = "SettingsFrame"; frame.Size = UDim2.new(0, 280, 0, 200); frame.Position = UDim2.new(1, CONFIG.UiOffsetX, 0, CONFIG.SettingsOffsetY); frame.BackgroundColor3 = STYLE.Background; frame.Parent = screenGui; Instance.new("UICorner", frame).CornerRadius = STYLE.Corner
    local header = Instance.new("Frame"); header.Size = UDim2.new(1, 0, 0, 30); header.BackgroundColor3 = STYLE.Panel; header.Parent = frame; Instance.new("UICorner", header).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel"); title.Text = "System Controls"; title.Size = UDim2.new(1, -15, 1, 0); title.Position = UDim2.new(0, 15, 0, 0); title.BackgroundTransparency = 1; title.TextColor3 = STYLE.TextMain; title.Font = STYLE.FontBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = header
    local listContainer = Instance.new("Frame"); listContainer.Size = UDim2.new(1, -10, 1, -35); listContainer.Position = UDim2.new(0, 5, 0, 32); listContainer.BackgroundTransparency = 1; listContainer.Parent = frame; Instance.new("UIListLayout", listContainer).Padding = UDim.new(0, 5)

    local function createToggle(name, settingKey)
        local row = Instance.new("Frame"); row.Size = UDim2.new(1, 0, 0, 28); row.BackgroundTransparency = 1; row.Parent = listContainer
        local label = Instance.new("TextLabel"); label.Text = name; label.Size = UDim2.new(0.6, 0, 1, 0); label.BackgroundTransparency = 1; label.TextColor3 = Color3.fromRGB(255, 255, 255); label.Font = STYLE.Font; label.TextSize = 16; label.TextXAlignment = Enum.TextXAlignment.Left; label.Parent = row
        local toggleBg = Instance.new("Frame"); toggleBg.Size = UDim2.new(0, 40, 0, 20); toggleBg.Position = UDim2.new(1, -45, 0.5, -10); toggleBg.BackgroundColor3 = STYLE.Button; toggleBg.Parent = row; Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(0, 10)
        local toggleKnob = Instance.new("Frame"); toggleKnob.Size = UDim2.new(0, 16, 0, 16); toggleKnob.Position = UDim2.new(0, 2, 0.5, -8); toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200); toggleKnob.Parent = toggleBg; Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(0, 8)

        local function updateState()
            if Settings[settingKey] then
                toggleBg.BackgroundColor3 = STYLE.ToggleOnColor; toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)}):Play()
            else
                toggleBg.BackgroundColor3 = STYLE.Button; toggleKnob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                TweenService:Create(toggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)}):Play()
            end
        end

        row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                Settings[settingKey] = not Settings[settingKey]
                updateState()
                if settingKey == "DeleteEnabled" and not Settings.DeleteEnabled then ActiveModes.Deleting = false
                elseif settingKey == "InspectEnabled" and not Settings.InspectEnabled then ActiveModes.Inspecting = false 
                elseif settingKey == "PilotAllowed" and not Settings.PilotAllowed then
                    if ActiveModes.Piloting then ActiveModes.Piloting = false; toggleDroneSystem(false); showNotification("КВАДРОКОПТЕР", "ОТКЛЮЧЕН") end
                end
            end
        end)
        ToggleUpdaters[settingKey] = updateState; updateState()
    end
    createToggle("Log Coords (Z)", "RouteLog"); createToggle("Teleport (X)", "Teleport"); createToggle("Delete (C)", "DeleteEnabled"); createToggle("Inspect (V)", "InspectEnabled"); createToggle("Allow Pilot (H)", "PilotAllowed")
end

local dropdownMode, spectatingPlayer, originalCameraSubject = nil, nil, nil
local activeSpyPage = "http"
local spectateCharConn, teleportingToPlayer, originalPosition = nil, nil, nil
local pages, buttons = {}, {}
local dropdownList, dropdownLayout, remoteSpyList, remoteSpyLayout, httpSpyPage, httpSpyLayout

local function createSpyUI()
    if CoreGui:FindFirstChild(spyUiName) then CoreGui[spyUiName]:Destroy() end
    local screenGui = Instance.new("ScreenGui"); screenGui.Name = spyUiName; screenGui.ResetOnSpawn = false; screenGui.IgnoreGuiInset = true; screenGui.Parent = CoreGui
    local frame = Instance.new("Frame"); frame.Name = "SpyFrame"; frame.Size = UDim2.new(0, 280, 0, 340); frame.Position = UDim2.new(1, CONFIG.UiOffsetX, 0, CONFIG.SpyOffsetY); frame.BackgroundColor3 = STYLE.Background; frame.Parent = screenGui; frame.ClipsDescendants = true; Instance.new("UICorner", frame).CornerRadius = STYLE.Corner
    local topBar = Instance.new("Frame"); topBar.Size = UDim2.new(1, 0, 0, 30); topBar.BackgroundColor3 = STYLE.Panel; topBar.Parent = frame; Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel"); title.Text = "Spy Utility | Pidromania"; title.Size = UDim2.new(1, -15, 1, 0); title.Position = UDim2.new(0, 15, 0, 0); title.BackgroundTransparency = 1; title.TextColor3 = STYLE.TextMain; title.Font = STYLE.FontBold; title.TextSize = 14; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = topBar
    local toolBar = Instance.new("Frame"); toolBar.Size = UDim2.new(1, 0, 0, 35); toolBar.Position = UDim2.new(0, 0, 0, 30); toolBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30); toolBar.Parent = frame
    local toolBarLayout = Instance.new("UIListLayout"); toolBarLayout.Parent = toolBar; toolBarLayout.FillDirection = Enum.FillDirection.Horizontal; toolBarLayout.Padding = UDim.new(0, 4); toolBarLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    local toolBarPadding = Instance.new("UIPadding", toolBar); toolBarPadding.PaddingLeft = UDim.new(0, 6)

    local function createToolbarButton(name, text)
        local btn = Instance.new("TextButton"); btn.Name = name; btn.Parent = toolBar; btn.Size = UDim2.new(0, 64, 0, 24); btn.BackgroundColor3 = STYLE.Button; btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = STYLE.TextMain; btn.Text = text; btn.TextSize = 11; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        return btn
    end
    buttons.spectate = createToolbarButton("SpectateButton", "👁 Spec"); buttons.teleport = createToolbarButton("TeleportButton", "⚡ TP"); buttons.remote = createToolbarButton("RemoteSpyButton", "📡 R.Spy"); buttons.http = createToolbarButton("HttpSpyButton", "🌐 HTTP")

    local pagesFrame = Instance.new("Frame"); pagesFrame.Name = "PagesFrame"; pagesFrame.Size = UDim2.new(1, 0, 1, -65); pagesFrame.Position = UDim2.new(0, 0, 0, 65); pagesFrame.BackgroundTransparency = 1; pagesFrame.Parent = frame
    local function createPage(name)
        local sf = Instance.new("ScrollingFrame"); sf.Name = name; sf.Parent = pagesFrame; sf.Size = UDim2.new(1, 0, 1, 0); sf.BackgroundTransparency = 1; sf.BorderSizePixel = 0; sf.Visible = false; sf.ScrollBarImageColor3 = STYLE.Button; sf.ScrollBarThickness = 4; local layout = Instance.new("UIListLayout", sf); layout.Padding = UDim.new(0, 4); local pad = Instance.new("UIPadding", sf); pad.PaddingLeft = UDim.new(0, 5); pad.PaddingRight = UDim.new(0, 5); pad.PaddingTop = UDim.new(0, 5); pad.PaddingBottom = UDim.new(0, 5); return sf, layout
    end
    dropdownList, dropdownLayout = createPage("DropdownList"); remoteSpyList, remoteSpyLayout = createPage("RemoteSpyList"); httpSpyPage, httpSpyLayout = createPage("HttpSpyPage")
    pages.spectate, pages.teleport, pages.remote, pages.http = dropdownList, dropdownList, remoteSpyList, httpSpyPage

    local httpClearBtn = Instance.new("TextButton"); httpClearBtn.Parent = httpSpyPage; httpClearBtn.Size = UDim2.new(1, 0, 0, 25); httpClearBtn.BackgroundColor3 = STYLE.Danger; httpClearBtn.Font = STYLE.FontBold; httpClearBtn.TextColor3 = Color3.fromRGB(255, 220, 220); httpClearBtn.Text = "🗑️ Clear HTTP Logs"; httpClearBtn.TextSize = 12; httpClearBtn.LayoutOrder = -1; Instance.new("UICorner", httpClearBtn).CornerRadius = UDim.new(0, 4)
    httpClearBtn.MouseButton1Click:Connect(function() for _, c in ipairs(httpSpyPage:GetChildren()) do if c.Name == "HttpLogEntry" then c:Destroy() end end; task.wait(); httpSpyPage.CanvasSize = UDim2.new(0, 0, 0, httpSpyLayout.AbsoluteContentSize.Y + 10) end)

    local remoteCopyAllBtn = Instance.new("TextButton")
    remoteCopyAllBtn.Parent = remoteSpyList
    remoteCopyAllBtn.Size = UDim2.new(1, 0, 0, 25)
    remoteCopyAllBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140)
    remoteCopyAllBtn.Font = STYLE.FontBold
    remoteCopyAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    remoteCopyAllBtn.Text = "📋 Copy All Remotes"
    remoteCopyAllBtn.TextSize = 12
    remoteCopyAllBtn.LayoutOrder = -1
    Instance.new("UICorner", remoteCopyAllBtn).CornerRadius = UDim.new(0, 4)

    remoteCopyAllBtn.MouseButton1Click:Connect(function()
        local allRemotes = {}
        for _, r in ipairs(game:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local rType = r:IsA("RemoteEvent") and "RE" or "RF"
                table.insert(allRemotes, string.format("[%s] %s", rType, r:GetFullName()))
            end
        end
        table.sort(allRemotes)
        
        if setclipboard and #allRemotes > 0 then
            setclipboard(table.concat(allRemotes, "\n"))
            local oldText = remoteCopyAllBtn.Text
            local oldColor = remoteCopyAllBtn.BackgroundColor3
            remoteCopyAllBtn.Text = "✅ СКОПИРОВАНО!"
            remoteCopyAllBtn.BackgroundColor3 = STYLE.Success
            task.delay(1.5, function()
                remoteCopyAllBtn.Text = oldText
                remoteCopyAllBtn.BackgroundColor3 = oldColor
            end)
        elseif #allRemotes == 0 then
            local oldText = remoteCopyAllBtn.Text
            remoteCopyAllBtn.Text = "❌ НИЧЕГО НЕ НАЙДЕНО"
            remoteCopyAllBtn.BackgroundColor3 = STYLE.Danger
            task.delay(1.5, function() 
                remoteCopyAllBtn.Text = oldText
                remoteCopyAllBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140) 
            end)
        end
    end)
end
createMainUI(); createSettingsUI(); createSpyUI()

local function updateDropdownList()
    for _, c in ipairs(dropdownList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local players = Players:GetPlayers()
    table.sort(players, function(a, b) return a.Name:lower() < b.Name:lower() end)
    for _, plr in ipairs(players) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton"); btn.Parent = dropdownList; btn.Size = UDim2.new(1, -5, 0, 25); btn.BackgroundColor3 = STYLE.Button; btn.Font = Enum.Font.GothamSemibold; btn.TextColor3 = STYLE.TextMain; btn.Text = string.format(" %s (@%s)", plr.DisplayName, plr.Name); btn.TextSize = 11; btn.TextXAlignment = Enum.TextXAlignment.Left; btn.TextTruncate = Enum.TextTruncate.AtEnd; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            if (dropdownMode == "spectate" and spectatingPlayer == plr) or (dropdownMode == "teleport" and teleportingToPlayer == plr) then btn.BackgroundColor3 = STYLE.InspectColor; btn.TextColor3 = Color3.fromRGB(200, 255, 200) end
            btn.MouseButton1Click:Connect(function()
                if dropdownMode == "spectate" then
                    if spectatingPlayer == plr then if spectateCharConn then spectateCharConn:Disconnect(); spectateCharConn = nil end; if originalCameraSubject then workspace.CurrentCamera.CameraSubject = originalCameraSubject end; spectatingPlayer, originalCameraSubject = nil, nil; updateDropdownList(); return end
                    if not spectatingPlayer and not originalCameraSubject then originalCameraSubject = workspace.CurrentCamera.CameraSubject end; spectatingPlayer = plr; if spectateCharConn then spectateCharConn:Disconnect(); spectateCharConn = nil end
                    local function setCam(char) local hum = char:FindFirstChildOfClass("Humanoid") or char; workspace.CurrentCamera.CameraSubject = hum end
                    if plr.Character then setCam(plr.Character) end; spectateCharConn = plr.CharacterAdded:Connect(setCam); updateDropdownList()
                elseif dropdownMode == "teleport" then
                    local lChar = LocalPlayer.Character; if not lChar or not lChar:FindFirstChild("HumanoidRootPart") then return end
                    local lHRP = lChar.HumanoidRootPart
                    if teleportingToPlayer == plr then if originalPosition then lHRP.CFrame = originalPosition end; teleportingToPlayer, originalPosition = nil, nil; updateDropdownList(); return end
                    local tChar = plr.Character; if tChar and tChar:FindFirstChild("HumanoidRootPart") then if not originalPosition then originalPosition = lHRP.CFrame end; lHRP.CFrame = tChar.HumanoidRootPart.CFrame; teleportingToPlayer = plr; updateDropdownList() end
                end
            end)
        end
    end
    dropdownList.CanvasSize = UDim2.new(0, 0, 0, dropdownLayout.AbsoluteContentSize.Y + 10)
end

local function updateRemoteSpyList()
    for _, c in ipairs(remoteSpyList:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    local remotes = {}; for _, r in ipairs(game:GetDescendants()) do if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then table.insert(remotes, r) end end
    table.sort(remotes, function(a, b) return a:GetFullName() < b:GetFullName() end)
    for _, r in ipairs(remotes) do
        local rf = Instance.new("Frame"); rf.Name = r.Name; rf.Parent = remoteSpyList; rf.Size = UDim2.new(1, -5, 0, 30); rf.BackgroundColor3 = Color3.fromRGB(40, 40, 50); rf.BorderSizePixel = 0; Instance.new("UICorner", rf).CornerRadius = UDim.new(0, 4)
        local rPath, rType = r:GetFullName(), r:IsA("RemoteEvent") and "RE" or "RF"
        local pathLbl = Instance.new("TextLabel"); pathLbl.Parent = rf; pathLbl.Size = UDim2.new(1, -105, 1, 0); pathLbl.Position = UDim2.new(0, 4, 0, 0); pathLbl.BackgroundTransparency = 1; pathLbl.Font = Enum.Font.Gotham; pathLbl.TextColor3 = STYLE.TextSub; pathLbl.TextSize = 10; pathLbl.TextXAlignment = Enum.TextXAlignment.Left; pathLbl.Text = string.format("[%s] %s", rType, rPath); pathLbl.TextTruncate = Enum.TextTruncate.AtEnd
        local fireBtn = Instance.new("TextButton"); fireBtn.Parent = rf; fireBtn.Size = UDim2.new(0, 40, 0, 22); fireBtn.Position = UDim2.new(1, -44, 0.5, -11); fireBtn.BackgroundColor3 = STYLE.Danger; fireBtn.Font = STYLE.FontBold; fireBtn.TextColor3 = Color3.fromRGB(255, 255, 255); fireBtn.Text = "Fire"; fireBtn.TextSize = 10; Instance.new("UICorner", fireBtn).CornerRadius = UDim.new(0, 4)
        fireBtn.MouseButton1Click:Connect(function() pcall(function() if r:IsA("RemoteEvent") then r:FireServer() else r:InvokeServer() end end) end)
        local copyBtn = Instance.new("TextButton"); copyBtn.Parent = rf; copyBtn.Size = UDim2.new(0, 55, 0, 22); copyBtn.Position = UDim2.new(1, -102, 0.5, -11); copyBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 140); copyBtn.Font = STYLE.FontBold; copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255); copyBtn.Text = "Copy"; copyBtn.TextSize = 10; Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0, 4)
        copyBtn.MouseButton1Click:Connect(function() if setclipboard then setclipboard(rPath) end end)
    end
    remoteSpyList.CanvasSize = UDim2.new(0, 0, 0, remoteSpyLayout.AbsoluteContentSize.Y + 10)
end

local function setActiveSpyPage(pageName)
    if pageName == "spectate" or pageName == "teleport" then dropdownMode = pageName; updateDropdownList() end
    if pageName == "remote" then updateRemoteSpyList() end
    activeSpyPage = pageName; for name, page in pairs(pages) do page.Visible = (name == pageName or (pageName == "teleport" and name == "spectate")) end
    for name, btn in pairs(buttons) do if name == pageName then btn.BackgroundColor3 = Color3.fromRGB(80, 50, 100); btn.TextColor3 = Color3.fromRGB(255, 255, 255) else btn.BackgroundColor3 = STYLE.Button; btn.TextColor3 = STYLE.TextMain end end
end
buttons.spectate.MouseButton1Click:Connect(function() setActiveSpyPage("spectate") end); buttons.teleport.MouseButton1Click:Connect(function() setActiveSpyPage("teleport") end); buttons.remote.MouseButton1Click:Connect(function() setActiveSpyPage("remote") end); buttons.http.MouseButton1Click:Connect(function() setActiveSpyPage("http") end)

local function logHttpRequest(...)
    local parts = {...}; local logLabel = Instance.new("TextLabel"); logLabel.Name = "HttpLogEntry"; logLabel.Parent = httpSpyPage; logLabel.Size = UDim2.new(1, -5, 0, 0); logLabel.AutomaticSize = Enum.AutomaticSize.Y; logLabel.BackgroundTransparency = 1; logLabel.Font = Enum.Font.Gotham; logLabel.TextColor3 = Color3.fromRGB(200, 255, 200); logLabel.TextSize = 11; logLabel.TextWrapped = true; logLabel.TextXAlignment = Enum.TextXAlignment.Left; logLabel.Text = table.concat(parts, " "); task.wait(); httpSpyPage.CanvasSize = UDim2.new(0, 0, 0, httpSpyLayout.AbsoluteContentSize.Y + 10)
end

local Hook = { Hooks = {}, Cache = setmetatable({}, {__mode = "k"}) }; local Http = {}; local UrlIntercepts = { ["http://127.0.0.1:6463/rpc?v=1"] = { Callback = function() return "" end } }
local function HttpCallback(OldFunc, ...)
    local Args = {...}; local Request = Http:ScanHTTPRequest(Args)
    if not Request or not Request.Url then return OldFunc(...) end
    logHttpRequest(string.format("[%s]: %s", Request.IsPost and "POST" or "GET", Request.Url)); if Request.Body then logHttpRequest(string.format("  ↳ [Body] %s", tostring(Request.Body))) end
    local Responce, Intercept = nil, Http:FindIntercept(Request.Url); if not Intercept or Intercept.PassResponce then local s, r = pcall(OldFunc, ...); Responce = r end
    if not Intercept then return Responce end
    local Spoofed = Intercept.Callback; if Typeof(Spoofed) == "function" then Spoofed = Intercept.PassResponce and Spoofed(Responce, Request) or Spoofed(Request) end
    if Request.IsTable then return Hook:Hook(Responce or {}, { ["Body"] = Spoofed }) end; return Spoofed
end
Hook.Alliases = { ["HTTP_HOOK"] = HttpCallback }
function Http:ScanHTTPRequest(Args)
    local Request = {}; for _, Arg in next, Args do if Typeof(Arg) == "string" then Request.Url = Arg; break elseif Typeof(Arg) == "table" then local Url = Arg.Url or Arg.url; if not Url then continue end; Request.Url = Url; Request.Body = Arg.Body or Arg.body; Request.IsPost = Request.Body and true or false; Request.IsTable = true; Request.Headers = Arg.Headers; break end end; return Request
end
function Http:FindIntercept(Url) for UrlMatch, Data in next, UrlIntercepts do if Url:match(UrlMatch) then return Data end end return end
function Hook:IsObject(Obj) return Typeof(Obj) == "Instance" end; function Hook:AddRefernce(Inst, Hooks) if Inst then self.Hooks[Inst] = Hooks end end; function Hook:GetCached(Inst) return self.Cache[Inst] end; function Hook:AddCached(Inst, Proxy) self.Cache[Inst] = Proxy end
function Hook:Hook(Object, HooksList)
    if self:GetCached(Object) then return self:GetCached(Object) end; local Proxy = newproxy(true); local Meta = getmetatable(Proxy); Meta.__index = function(self, Key) local HookFunc = HooksList[Key]; if HookFunc then return HookFunc end; local Value = Object[Key]; if type(Value) == "function" then return function(self, ...) return Value(Object, ...) end end; return Value end; Meta.__newindex = function(self, Key, New) Object[Key] = New end; Meta.__tostring = function() return tostring(Object) end; Meta.__metatable = getmetatable(Object); self:AddCached(Object, Proxy); return Proxy
end
function Hook:ApplyHooks()
    for Object, Data in next, self.Hooks do
        local IsObject = self:IsObject(Object); local IsReadOnly = type(Object) == "table" and table.isfrozen(Object); if IsReadOnly then setreadonly(Object, false) end
        for Key, Value in next, Data.Hooks do
            local Success, OldValue = pcall(function() return Object[Key] end); if not Success then continue end
            if Typeof(OldValue) == "function" then if IsObject then local OldFunc = OldValue; OldValue = function(self, ...) return OldFunc(Object, ...) end end; if iscclosure(OldValue) then OldValue = newcclosure(OldValue) end end
            if typeof(Value) == "string" and self.Alliases[Value] then local CB = self.Alliases[Value]; Value = function(...) return CB(OldValue, ...) end end; Data.Hooks[Key] = Value; if not IsObject then Object[Key] = Value end
        end
        if IsObject then local Proxy = self:Hook(Object, Data.Hooks); if Data.Globals then for _, Global in next, Data.Globals do GlobalENV[Global] = Proxy end end elseif IsReadOnly then setreadonly(Object, true) end
    end
end
Hook:AddRefernce(game, { Globals = {"game", "Game"}, Hooks = { ["HttpGet"] = "HTTP_HOOK", ["HttpGetAsync"] = "HTTP_HOOK", ["HttpPost"] = "HTTP_HOOK", ["HttpPostAsync"] = "HTTP_HOOK" } })
Hook:AddRefernce(GlobalENV, { Hooks = { ["http_request"] = "HTTP_HOOK", ["request"] = "HTTP_HOOK" } }); if http then Hook:AddRefernce(http, { Hooks = { ["request"] = "HTTP_HOOK" } }) end; if syn then Hook:AddRefernce(syn, { Hooks = { ["request"] = "HTTP_HOOK" } }) end
Hook:ApplyHooks(); setActiveSpyPage("http")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if UserInputService:GetFocusedTextBox() then return end

    if input.KeyCode == Enum.KeyCode.Z then
        if Settings.RouteLog then 
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local pos = hrp.Position
                    local coords = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
                    table.insert(listOrder, coords)
                    local lbl = #listOrder == 1 and "Start" or tostring(#listOrder - 1)
                    table.insert(labelsOrder, lbl); addCoordinateToUI(coords, lbl)
                    if setclipboard then setclipboard(coords) end
                end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        if Settings.Teleport then 
            local char = LocalPlayer.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hit = mouse.Hit.Position
                    if hit.Y ~= math.huge and hit == hit then char.HumanoidRootPart.CFrame = CFrame.new(hit.X, hit.Y + 2, hit.Z) end
                end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.C and Settings.DeleteEnabled then ActiveModes.Deleting = not ActiveModes.Deleting; showNotification("УДАЛЕНИЕ", ActiveModes.Deleting and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО")
    elseif input.KeyCode == Enum.KeyCode.V and Settings.InspectEnabled then ActiveModes.Inspecting = not ActiveModes.Inspecting; showNotification("ИНСПЕКТОР", ActiveModes.Inspecting and "ВКЛЮЧЕНО" or "ВЫКЛЮЧЕНО")
    elseif input.KeyCode == Enum.KeyCode.H then
        if Settings.PilotAllowed then
            ActiveModes.Piloting = not ActiveModes.Piloting
            toggleDroneSystem(ActiveModes.Piloting)
            showNotification("КВАДРОКОПТЕР", ActiveModes.Piloting and "АКТИВИРОВАН" or "ОТКЛЮЧЕН")
        else
            showNotification("КВАДРОКОПТЕР", "СНАЧАЛА РАЗРЕШИТЕ В НАСТРОЙКАХ")
        end
    elseif input.KeyCode == Enum.KeyCode.G then
        isUiVisible = not isUiVisible 
        local mainGui = CoreGui:FindFirstChild(uiName); local setGui = CoreGui:FindFirstChild(settingsUiName); local spyGui = CoreGui:FindFirstChild(spyUiName)
        local twInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local function toggleFrame(guiObj, targetY) if guiObj then local frame = guiObj:FindFirstChildOfClass("Frame"); if frame then TweenService:Create(frame, twInfo, {Position = UDim2.new(1, isUiVisible and CONFIG.UiOffsetX or 50, 0, targetY)}):Play() end end end
        toggleFrame(mainGui, CONFIG.MainOffsetY); toggleFrame(setGui, CONFIG.SettingsOffsetY); toggleFrame(spyGui, CONFIG.SpyOffsetY)
    end
end)

local canInteract = true
mouse.Button1Down:Connect(function()
    if not canInteract then return end
    local target = mouse.Target; if not target then return end
    if ActiveModes.Deleting then
        if target:IsA("BasePart") and target.Anchored then pcall(function() target:Destroy() end); canInteract = false; task.spawn(function() task.wait(0.3); canInteract = true end) end
    elseif ActiveModes.Inspecting then
        warn("--- [ 🔍 ИНСПЕКТОР ] ---"); print("Имя: " .. target.Name); print("Класс: " .. target.ClassName); print("Полный путь: " .. target:GetFullName())
        if target:IsA("BasePart") then print(string.format("Позиция: %.2f, %.2f, %.2f", target.Position.X, target.Position.Y, target.Position.Z)) end
        print("------------------------"); canInteract = false; task.spawn(function() task.wait(0.3); canInteract = true end)
    end
end)

local function onCharAdded(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        if spectatingPlayer then if spectateCharConn then spectateCharConn:Disconnect(); spectateCharConn = nil end; spectatingPlayer, originalCameraSubject = nil, nil end
        if teleportingToPlayer then teleportingToPlayer, originalPosition = nil, nil end
        if activeSpyPage == "spectate" or activeSpyPage == "teleport" then updateDropdownList() end
        if ActiveModes.Piloting then ActiveModes.Piloting = false; toggleDroneSystem(false) end
    end)
end
if LocalPlayer.Character then onCharAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharAdded)
Players.PlayerAdded:Connect(function() if activeSpyPage == "spectate" or activeSpyPage == "teleport" then updateDropdownList() end end)
Players.PlayerRemoving:Connect(function(p)
    if spectatingPlayer == p then if originalCameraSubject then workspace.CurrentCamera.CameraSubject = originalCameraSubject end; spectatingPlayer, originalCameraSubject = nil, nil end
    if teleportingToPlayer == p then if originalPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition end; teleportingToPlayer, originalPosition = nil, nil end
    if activeSpyPage == "spectate" or activeSpyPage == "teleport" then updateDropdownList() end
end)

-- ==========================================
-- ИДЕАЛЬНАЯ ФИЗИКА ДРОНА С LINEARVELOCITY
-- ==========================================
GlobalENV.QuadcopterConnection = RunService.RenderStepped:Connect(function(dt)
    if not ActiveModes.Piloting or not Hitbox then return end

    local moveInput = Vector3.zero
    local droneRotationMatrix = CFrame.identity

    if isPowered then
        linVel.Enabled = true
        alignOri.Enabled = true

        if camMode == "Plane" then
            local screenSize = Camera.ViewportSize
            local mouseX, mouseY = mouse.X, mouse.Y
            local centerX, centerY = screenSize.X / 2, screenSize.Y / 2
            
            local offsetX = (mouseX - centerX) / centerX
            local offsetY = (mouseY - centerY) / centerY
            
            if math.abs(offsetX) < CONFIG.Deadzone then offsetX = 0 else offsetX = offsetX - math.sign(offsetX) * CONFIG.Deadzone end
            if math.abs(offsetY) < CONFIG.Deadzone then offsetY = 0 else offsetY = offsetY - math.sign(offsetY) * CONFIG.Deadzone end
            
            fpvRotation = fpvRotation * CFrame.Angles(-offsetY * CONFIG.TurnSpeed * dt, -offsetX * CONFIG.TurnSpeed * dt, 0)
            
            local lookDir = fpvRotation.LookVector
            local rightDir = fpvRotation.RightVector
            local upDir = fpvRotation.UpVector
            
            if Keys.W then moveInput += lookDir end
            if Keys.S then moveInput -= lookDir end
            if Keys.D then moveInput += rightDir end
            if Keys.A then moveInput -= rightDir end
            if Keys.E then moveInput += upDir end
            if Keys.Q then moveInput -= upDir end

            planeRoll = planeRoll + ((-offsetX * math.rad(60)) - planeRoll) * 0.1
            droneRotationMatrix = fpvRotation * CFrame.Angles(0, 0, planeRoll)
        else
            local flatLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
            local lookDir = flatLook.Magnitude > 0.001 and flatLook.Unit or Vector3.new(0, 0, -1)
            
            local flatRight = Vector3.new(Camera.CFrame.RightVector.X, 0, Camera.CFrame.RightVector.Z)
            local rightDir = flatRight.Magnitude > 0.001 and flatRight.Unit or Vector3.new(1, 0, 0)
            
            if Keys.W then moveInput += lookDir end
            if Keys.S then moveInput -= lookDir end
            if Keys.D then moveInput += rightDir end
            if Keys.A then moveInput -= rightDir end
            if Keys.E then moveInput += Vector3.new(0, 1, 0) end
            if Keys.Q then moveInput -= Vector3.new(0, 1, 0) end

            if Keys.W or Keys.S or Keys.A or Keys.D then
                local targetYaw = math.atan2(-lookDir.X, -lookDir.Z)
                local diff = (targetYaw - orbitYaw)
                diff = (diff + math.pi) % (math.pi * 2) - math.pi
                orbitYaw = orbitYaw + (diff * 0.15)
            end

            droneRotationMatrix = CFrame.Angles(0, orbitYaw, 0)
            
            local localVel = droneRotationMatrix:VectorToObjectSpace(currentVelocity)
            local tiltMult = 35 
            tiltX = tiltX + (math.clamp((localVel.Z / CONFIG.DroneSpeed) * tiltMult, -tiltMult, tiltMult) - tiltX) * 0.1
            tiltZ = tiltZ + (math.clamp((localVel.X / CONFIG.DroneSpeed) * -tiltMult, -tiltMult, tiltMult) - tiltZ) * 0.1
            
            droneRotationMatrix = droneRotationMatrix * CFrame.Angles(math.rad(tiltX), 0, math.rad(tiltZ))
        end

        if moveInput.Magnitude > 0.001 then moveInput = moveInput.Unit else moveInput = Vector3.zero end
        
        local targetVelocity = moveInput * CONFIG.DroneSpeed
        currentVelocity = currentVelocity:Lerp(targetVelocity, CONFIG.Acceleration * dt)

        linVel.VectorVelocity = currentVelocity
        alignOri.CFrame = droneRotationMatrix

        currentPropSpeed = math.min(2000, currentPropSpeed + 4000 * dt)
    else
        linVel.Enabled = false
        alignOri.Enabled = false
        
        currentVelocity = Hitbox.AssemblyLinearVelocity
        local tumbleCFrame = Hitbox.CFrame - Hitbox.Position
        
        orbitYaw = math.atan2(-tumbleCFrame.LookVector.X, -tumbleCFrame.LookVector.Z)
        fpvRotation = tumbleCFrame
        tiltX, tiltZ, planeRoll = 0, 0, 0

        currentPropSpeed = math.max(0, currentPropSpeed - 1500 * dt)
    end

    local finalCFrame = Hitbox.CFrame
    PrimaryPart.CFrame = finalCFrame
    EyePart.CFrame = finalCFrame * CFrame.new(0, 0, -0.3)
    
    propSpin = (propSpin + currentPropSpeed * dt) % 360
    for _, p in ipairs(Props) do
        local angle = (p.Index == 1 or p.Index == 4) and 45 or -45
        p.Arm.CFrame = finalCFrame * CFrame.new(p.Offset.X/2, 0, p.Offset.Z/2) * CFrame.Angles(0, math.rad(angle), 0)
        local propBase = finalCFrame * CFrame.new(p.Offset)
        local dir = (p.Index % 2 == 0) and 1 or -1
        p.Prop.CFrame = propBase * CFrame.Angles(0, math.rad(propSpin * dir), 0)
    end

    if camMode == "Plane" then Camera.CFrame = Camera.CFrame:Lerp(finalCFrame * CFrame.new(0, 3, 12), 10 * dt) end
    if UI_Elements.Speed then UI_Elements.Speed.Text = "СКОРОСТЬ: " .. math.floor(currentVelocity.Magnitude) .. " km/h" end
end)
