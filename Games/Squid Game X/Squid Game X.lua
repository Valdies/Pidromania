-- Pidromania Hub: Squid Game X (оптимизированная версия, UI как в SBO:R)

-- Если хаб уже запущен в этой сессии - гасим старый экземпляр
if getgenv().SquidHubStop then pcall(getgenv().SquidHubStop) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RepStor = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

------------------------------------------------------------------
-- Утилиты
------------------------------------------------------------------
local connections = {}
local function track(conn) connections[#connections + 1] = conn return conn end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

local function round(obj, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function myRoot()
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function ApplyMobileScale(gui, baseWidth)
    local uiScale = new("UIScale", nil, gui)
    local cam = Workspace.CurrentCamera
    local function update()
        local w = cam.ViewportSize.X
        uiScale.Scale = w < baseWidth and w / (baseWidth + 50) or 1
    end
    update()
    local c = cam:GetPropertyChangedSignal("ViewportSize"):Connect(update)
    gui.Destroying:Connect(function() c:Disconnect() end)
end

local function MakeDraggableTouch(topbar, target)
    local dragging, dragInput, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then dragInput = input end
    end)
    local conn = UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local d = input.Position - dragStart
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    topbar.Destroying:Connect(function() conn:Disconnect() end)
end

-- Один именованный RenderStepped-хук на функцию (повторный вызов заменяет старый)
local hooks = {}
local function setHook(name, on, fn)
    if hooks[name] then hooks[name]:Disconnect() hooks[name] = nil end
    if on then hooks[name] = RunService.RenderStepped:Connect(fn) end
end

------------------------------------------------------------------
-- Состояние, конфиг, локализация
------------------------------------------------------------------
local S = {
    language = "ru", exitEsp = false, freezePlayers = false, baby = false, tug = false,
    selfFreeze = false, magnet = false, friend = nil,
}

local FOLDER_NAME = "PidromaniaHub"
local FILE_NAME = FOLDER_NAME .. "/SquidGame_Config.json"

local function SaveConfig()
    if not (writefile and isfolder) then return end
    if not isfolder(FOLDER_NAME) then makefolder(FOLDER_NAME) end
    pcall(function() writefile(FILE_NAME, HttpService:JSONEncode({language = S.language})) end)
end

-- L(ru, uk, kk, en) - название на четырёх языках, N(x) - выбрать нужное
local function L(ru, uk, kk, en) return {ru = ru, uk = uk, kk = kk, en = en} end
local function N(v)
    if type(v) ~= "table" then return v end
    return v[S.language] or v.en or v.ru
end

-- hubTitle, byAuthor, lang_* одинаковые для всех языков, поэтому лежат только в ru
local translations = {
    ru = {
        hubTitle = "Pidromania Hub: Squid Game X", byAuthor = "by @Pidromania",
        lang_ru = "Русский", lang_uk = "Українська", lang_kk = "Қазақ", lang_en = "English",
        teleports = "Телепорты", utilities = "Полезности", saveFriend = "Спасти друга", settings = "Настройки",
        languageLabel = "Язык интерфейса:",
        exitDoorLabel = "Показать выход (ExitDoor)", cloneBridgeLabel = "Создать клонов на мосту",
        teleportPlayersLabel = "Заморозить игроков у себя", takeBabyLabel = "Взять ребёнка (спам)",
        tugOfWarLabel = "Перетягивание каната (спам)", afkLabel = "АФК (телепорт в бездну)",
        instruction = "Инструкция", selectFriendLabel = "1) Выберите друга:", freezeSelfLabel = "2) Заморозить себя",
        danceHint = "3) Попросите друга станцевать «танец с другом»", tpFriendLabel = "4) Телепортировать друга (магнит)",
        noPlayers = "На сервере нет других игроков", exitLabel = "ВЫХОД #%d",
    },
    uk = {
        teleports = "Телепорти", utilities = "Корисності", saveFriend = "Врятувати друга", settings = "Налаштування",
        languageLabel = "Мова інтерфейсу:",
        exitDoorLabel = "Показати вихід (ExitDoor)", cloneBridgeLabel = "Створити клонів на мосту",
        teleportPlayersLabel = "Заморозити гравців біля себе", takeBabyLabel = "Взяти дитину (спам)",
        tugOfWarLabel = "Перетягування канату (спам)", afkLabel = "АФК (телепорт у прірву)",
        instruction = "Інструкція", selectFriendLabel = "1) Оберіть друга:", freezeSelfLabel = "2) Заморозити себе",
        danceHint = "3) Попросіть друга станцювати «танець з другом»", tpFriendLabel = "4) Телепортувати друга (магніт)",
        noPlayers = "На сервері немає інших гравців", exitLabel = "ВИХІД #%d",
    },
    kk = {
        teleports = "Телепорттар", utilities = "Құралдар", saveFriend = "Досты құтқару", settings = "Параметрлер",
        languageLabel = "Интерфейс тілі:",
        exitDoorLabel = "Шығуды көрсету (ExitDoor)", cloneBridgeLabel = "Көпірде клондар жасау",
        teleportPlayersLabel = "Ойыншыларды қатыру", takeBabyLabel = "Баланы алу (спам)",
        tugOfWarLabel = "Арқан тарту (спам)", afkLabel = "АФК (түпсіз тұңғиыққа телепорт)",
        instruction = "Нұсқаулық", selectFriendLabel = "1) Досты таңдаңыз:", freezeSelfLabel = "2) Өзіңізді қатыру",
        danceHint = "3) Досыңыздан «доспен би» билеуін сұраңыз", tpFriendLabel = "4) Досты телепорттау (магнит)",
        noPlayers = "Серверде басқа ойыншылар жоқ", exitLabel = "ШЫҒУ #%d",
    },
    en = {
        teleports = "Teleports", utilities = "Utilities", saveFriend = "Save friend", settings = "Settings",
        languageLabel = "Interface language:",
        exitDoorLabel = "Show exit (ExitDoor)", cloneBridgeLabel = "Spawn clones on the bridge",
        teleportPlayersLabel = "Freeze players next to me", takeBabyLabel = "Take baby (spam)",
        tugOfWarLabel = "Tug of war (spam)", afkLabel = "AFK (teleport to the void)",
        instruction = "Instructions", selectFriendLabel = "1) Select a friend:", freezeSelfLabel = "2) Freeze myself",
        danceHint = "3) Ask your friend to do the \"friend dance\"", tpFriendLabel = "4) Teleport friend (magnet)",
        noPlayers = "No other players on the server", exitLabel = "EXIT #%d",
    },
}

local function T(key)
    local l = translations[S.language]
    return (l and l[key]) or translations.ru[key] or ("???" .. key .. "???")
end

pcall(function()
    if readfile and isfile and isfile(FILE_NAME) then
        local data = HttpService:JSONDecode(readfile(FILE_NAME))
        if type(data.language) == "string" and translations[data.language] then S.language = data.language end
    end
end)

------------------------------------------------------------------
-- Данные
------------------------------------------------------------------
local TELEPORTS = {
    {L("🎮 Комната Фронтмена", "🎮 Кімната Фронтмена", "🎮 Фронтмен бөлмесі", "🎮 Frontman's room"), 7944.32, 120.69, 3618.20},
    {L("Скакалка", "Скакалка", "Секіртпе", "Jump rope"), -56.06, 119.97, 3.07},
    {L("🛡️ Безопасная зона (Прятки)", "🛡️ Безпечна зона (Хованки)", "🛡️ Қауіпсіз аймақ (Тығылмақ)", "🛡️ Safe zone (Hide & Seek)"), -622.17, 183.55, 399.09},
    {L("Стекло", "Скло", "Әйнек", "Glass bridge"), 1280.30, 102.11, -955.72},
    {L("🍽️ Безопасная зона (Ужин)", "🍽️ Безпечна зона (Вечеря)", "🍽️ Қауіпсіз аймақ (Кешкі ас)", "🍽️ Safe zone (Dinner)"), 8162.46, 48.53, 23396.95},
    {L("Лодки", "Човни", "Қайықтар", "Boats"), -2799.48, -785.78, 15508.45},
    {L("Лодки: финиш", "Човни: фініш", "Қайықтар: мәре", "Boats: finish"), -4158.55, -788.55, 15585.78},
}

local AFK_POSITION = Vector3.new(8037.54, -20000, 3718.87)

-- Особые игроки (подсветка и подпись в ESP)
local SPECIAL_PLAYERS = {
    ["luken_god"] = {text = "Даже тут у него 12000 LvL", color = Color3.fromRGB(0, 255, 0)},
    ["curlycheburashka"] = {text = "Викуля Красотуля", color = Color3.fromRGB(255, 105, 180)},
    ["82lena28"] = {text = "Pidromania Dev", color = Color3.fromRGB(30, 144, 255)},
    ["arrowennos"] = {text = "AlHiMiK", color = Color3.fromRGB(0, 100, 0)},
}

-- Свои друзья: не замораживаем и подсвечиваем в списке (плюс друзья по Roblox)
local FRIENDS_LIST = {
    ["luken_god"] = true, ["curlycheburashka"] = true, ["82lena28"] = true,
    ["arrowennos"] = true, ["danil7082d"] = true, ["minikokosich"] = true,
}

local friendsCache = {}
local function isFriend(plr)
    if FRIENDS_LIST[string.lower(plr.Name)] then return true end
    local cached = friendsCache[plr.UserId]
    if cached ~= nil then return cached end
    local ok, res = pcall(function() return player:IsFriendsWith(plr.UserId) end)
    if ok then friendsCache[plr.UserId] = res return res end
    return false
end

------------------------------------------------------------------
-- Функции: телепорт, заморозка, магнит, АФК
------------------------------------------------------------------
local function teleport(x, y, z)
    local root = myRoot()
    if root then root.CFrame = CFrame.new(x, y, z) end
end

-- Заморозка чужих игроков на точке рядом с собой (позиции фиксируются в момент включения)
local frozen = {}
local function setFreezePlayers(on)
    frozen = {}
    setHook("freezePlayers", false)
    if not on then return true end
    local root = myRoot()
    if not root then return false end
    local base = root.Position + Vector3.new(0, 0, 3)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and not isFriend(plr) then
            local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame = CFrame.new(base) frozen[plr] = base end
        end
    end
    setHook("freezePlayers", true, function()
        for plr, pos in pairs(frozen) do
            local r = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame = CFrame.new(pos) end
        end
    end)
    return true
end

local function setSelfFreeze(on)
    setHook("selfFreeze", false)
    if not on then return true end
    local root = myRoot()
    if not root then return false end
    local cf = root.CFrame
    setHook("selfFreeze", true, function()
        local r = myRoot()
        if r then r.CFrame = cf else S.selfFreeze = false setHook("selfFreeze", false) end
    end)
    return true
end

-- Магнит: выбранный друг постоянно телепортируется к нам
local function setMagnet(on)
    setHook("magnet", false)
    if not on then return true end
    if not S.friend then return false end
    setHook("magnet", true, function()
        local target = Players:FindFirstChild(S.friend)
        local tRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        local root = myRoot()
        if not target then S.magnet = false setHook("magnet", false) return end
        if tRoot and root then tRoot.CFrame = CFrame.new(root.Position + Vector3.new(0, 0, 3)) end
    end)
    return true
end

local function goAfk()
    local root = myRoot()
    if root then root.CFrame = CFrame.new(AFK_POSITION) end
end

-- Спам удалённым событием (generation-счётчик вместо task.cancel)
local function makeSpam(resolve, delay)
    local gen = 0
    return function(on)
        gen = gen + 1
        if not on then return end
        local my = gen
        task.spawn(function()
            local remote = resolve()
            if not remote then return end
            while gen == my do
                pcall(function() remote:FireServer() end)
                task.wait(delay)
            end
        end)
    end
end

local setBabySpam = makeSpam(function()
    local remotes = RepStor:WaitForChild("Remotes", 5)
    return remotes and remotes:WaitForChild("BabyAction", 5)
end, 0.1)

local setTugSpam = makeSpam(function()
    local map = Workspace:WaitForChild("Map", 5)
    local tow = map and map:WaitForChild("TugOfWar", 5)
    local remotes = tow and tow:WaitForChild("Remotes", 5)
    return remotes and remotes:WaitForChild("Tester228505", 5)
end, 1 / 30)

------------------------------------------------------------------
-- Клоны на мосту (клиентские, исчезают через 2 минуты)
------------------------------------------------------------------
local MY_USER_ID = 1923012479
local bridgeClones = {}
local cleanupScheduled = false

local BRIDGE_POSITIONS = {}
for i = 0, 9 do
    local z = -1071 + i * 10
    BRIDGE_POSITIONS[#BRIDGE_POSITIONS + 1] = Vector3.new(1276, 100.6, z)
    BRIDGE_POSITIONS[#BRIDGE_POSITIONS + 1] = Vector3.new(1286, 100.6, z)
end

local function cleanupClones()
    for _, m in ipairs(bridgeClones) do
        if m and m.Parent then m:Destroy() end
    end
    bridgeClones = {}
end

local function spawnClone(position, index)
    local ok, model = pcall(function() return Players:CreateHumanoidModelFromUserId(MY_USER_ID) end)
    if not ok or not model then return false end
    model.Name = "Pidro_Bridge_" .. index
    model.Parent = Workspace
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChildWhichIsA("BasePart")
    if not root then model:Destroy() return false end
    model.PrimaryPart = root
    root.CFrame = CFrame.new(position.X, position.Y + 2, position.Z)
    new("Highlight", {FillColor = Color3.fromRGB(255, 0, 0), OutlineColor = Color3.fromRGB(255, 0, 0), FillTransparency = 0.5, Adornee = model}, model)
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then d.CanCollide = false
        elseif d:IsA("Tool") then d:Destroy() end
    end
    bridgeClones[#bridgeClones + 1] = model
    return true
end

local function spawnAllClones()
    if #bridgeClones > 0 then cleanupClones() task.wait(0.5) end
    for i, pos in ipairs(BRIDGE_POSITIONS) do
        spawnClone(pos, i)
        task.wait(0.05)
    end
    if not cleanupScheduled then
        cleanupScheduled = true
        task.delay(120, function() cleanupClones() cleanupScheduled = false end)
    end
end

------------------------------------------------------------------
-- ESP игроков (один общий RenderStepped) + подсветка особых игроков
------------------------------------------------------------------
local hasDrawing = (Drawing and Drawing.new) and true or false
local espObjects, highlights = {}, {}
local WHITE, RED, GREEN = Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0)

local function newText(size)
    local t = Drawing.new("Text")
    t.Outline, t.OutlineColor, t.Center, t.Size, t.Font, t.Visible = true, Color3.new(0, 0, 0), true, size, 2, false
    return t
end

local function newEsp()
    local e = {box = Drawing.new("Square"), name = newText(24), label = newText(27),
        hpBg = Drawing.new("Square"), hp = Drawing.new("Square")}
    e.box.Color, e.box.Thickness, e.box.Filled, e.box.Visible = RED, 3, false, false
    e.hpBg.Color, e.hpBg.Filled, e.hpBg.Thickness, e.hpBg.Visible = Color3.fromRGB(40, 40, 40), true, 0, false
    e.hp.Color, e.hp.Filled, e.hp.Thickness, e.hp.Visible = GREEN, true, 0, false
    return e
end

local function hideEsp(e)
    e.box.Visible, e.name.Visible, e.label.Visible, e.hp.Visible, e.hpBg.Visible = false, false, false, false, false
end

local function removeEsp(plr)
    local e = espObjects[plr]
    if e then
        for _, d in pairs(e) do pcall(function() d:Remove() end) end
        espObjects[plr] = nil
    end
    local h = highlights[plr]
    if h then h:Destroy() highlights[plr] = nil end
end

local function applyHighlight(plr)
    local special = SPECIAL_PLAYERS[string.lower(plr.Name)]
    local char = plr.Character
    if not (special and char) then return end
    local h = highlights[plr]
    if not (h and h.Parent and h.Adornee == char) then
        if h then h:Destroy() end
        h = new("Highlight", {OutlineTransparency = 0, FillTransparency = 0.7, Adornee = char}, char)
        highlights[plr] = h
    end
    h.OutlineColor, h.FillColor = special.color, special.color
end

local function updateEsp(plr, cam)
    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    local e = espObjects[plr]
    if not (head and root and hum) then
        if e then hideEsp(e) end
        return
    end
    local hv, hVis = cam:WorldToViewportPoint(head.Position)
    local _, rVis = cam:WorldToViewportPoint(root.Position)
    if not (hVis and rVis) then
        if e then hideEsp(e) end
        return
    end
    if not e then e = newEsp() espObjects[plr] = e end

    local special = SPECIAL_PLAYERS[string.lower(plr.Name)]
    local rv = cam:WorldToViewportPoint(root.Position)
    local height = math.abs(hv.Y - rv.Y) * 2.8
    local width = height * 0.65
    e.box.Color = special and special.color or RED
    e.box.Size = Vector2.new(width, height)
    e.box.Position = Vector2.new(hv.X - width / 2, hv.Y - height * 0.15)
    e.name.Text, e.name.Color = plr.Name, special and special.color or WHITE
    e.name.Position = Vector2.new(hv.X, hv.Y - 30)

    if special then
        e.box.Visible, e.name.Visible, e.hp.Visible, e.hpBg.Visible = false, false, false, false
        e.label.Text, e.label.Color = special.text, special.color
        e.label.Position = Vector2.new(hv.X, hv.Y - 55)
        e.label.Visible = true
    else
        e.label.Visible = false
        e.box.Visible, e.name.Visible, e.hp.Visible, e.hpBg.Visible = true, true, true, true
        local pct = hum.MaxHealth > 0 and math.clamp(hum.Health / hum.MaxHealth, 0, 1) or 0
        local barW = width * 0.9
        e.hp.Color = pct < 0.3 and Color3.fromRGB(255, 50, 50) or GREEN
        e.hpBg.Size, e.hpBg.Position = Vector2.new(barW, 6), Vector2.new(hv.X - barW / 2, hv.Y - 8)
        e.hp.Size, e.hp.Position = Vector2.new(barW * pct, 6), e.hpBg.Position
    end
end

local function watchPlayer(plr)
    if plr == player then return end
    track(plr.CharacterAdded:Connect(function() task.wait(0.5) applyHighlight(plr) end))
    applyHighlight(plr)
end

for _, plr in ipairs(Players:GetPlayers()) do watchPlayer(plr) end
track(Players.PlayerAdded:Connect(watchPlayer))
track(Players.PlayerRemoving:Connect(removeEsp))

if hasDrawing then
    track(RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then updateEsp(plr, cam) end
        end
    end))
end

------------------------------------------------------------------
-- ESP выхода (ExitDoor)
------------------------------------------------------------------
local exitDrawings = {}

local function clearExitEsp()
    setHook("exitEsp", false)
    for _, d in ipairs(exitDrawings) do
        pcall(function() d.box:Remove() d.label:Remove() end)
    end
    exitDrawings = {}
end

local function setExitEsp(on)
    clearExitEsp()
    if not on or not hasDrawing then return end
    local root = Workspace:FindFirstChild("Map")
    root = root and root:FindFirstChild("HideNSeek")
    root = root and root:FindFirstChild("Elements") or Workspace
    for _, obj in ipairs(root:GetDescendants()) do
        if obj.Name == "ExitDoor" then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then
                local i = #exitDrawings + 1
                local box = Drawing.new("Square")
                box.Color, box.Thickness, box.Filled, box.Visible = GREEN, 4, false, false
                local label = newText(24)
                label.Text, label.Color = string.format(T("exitLabel"), i), Color3.fromRGB(50, 255, 50)
                exitDrawings[i] = {part = part, box = box, label = label}
            end
        end
    end
    if #exitDrawings == 0 then return end
    setHook("exitEsp", true, function()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        for _, d in ipairs(exitDrawings) do
            local pos = d.part.Parent and d.part.Position
            local sp, onScreen
            if pos then sp, onScreen = cam:WorldToViewportPoint(pos) end
            if onScreen then
                local size = math.clamp(7000 / (cam.CFrame.Position - pos).Magnitude, 60, 500)
                d.box.Position, d.box.Size, d.box.Visible = Vector2.new(sp.X - size / 2, sp.Y - size / 2), Vector2.new(size, size), true
                d.label.Position, d.label.Visible = Vector2.new(sp.X, sp.Y - size / 2 - 30), true
            else
                d.box.Visible, d.label.Visible = false, false
            end
        end
    end)
end

------------------------------------------------------------------
-- UI (такой же, как в хабе SBO:R)
------------------------------------------------------------------
local UI = {}
local pageOrder = 0
local COL_BTN, COL_TXT, COL_TITLE = Color3.fromRGB(60, 60, 80), Color3.fromRGB(240, 240, 255), Color3.fromRGB(200, 200, 255)
local COL_ACTIVE = Color3.fromRGB(50, 120, 70)
local screenGuiMain

local function put(obj)
    pageOrder = pageOrder + 1
    obj.LayoutOrder = pageOrder
    obj.Parent = UI.content
    return obj
end

local function clearContent()
    for _, c in ipairs(UI.content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    pageOrder = 0
end

local function title(text, color)
    return put(new("TextLabel", {Text = text, Size = UDim2.new(1, 0, 0, 37.5), BackgroundTransparency = 1, TextColor3 = color or COL_TITLE, Font = Enum.Font.GothamBold, TextSize = 21}))
end

local function note(text, color)
    return put(new("TextLabel", {Text = text, Size = UDim2.new(1, -15, 0, 30), BackgroundTransparency = 1, TextColor3 = color or Color3.fromRGB(180, 180, 220), Font = Enum.Font.GothamSemibold, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true}))
end

local function button(text, cb, color)
    local b = new("TextButton", {Text = text, Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = color or COL_BTN, TextColor3 = COL_TXT, Font = Enum.Font.GothamSemibold, TextSize = 21, AutoButtonColor = true})
    round(b, 9)
    b.MouseButton1Click:Connect(cb)
    return put(b)
end

local function toggle(label, initial, onToggle)
    local frame = new("Frame", {Size = UDim2.new(1, -15, 0, 45), BackgroundColor3 = COL_BTN, BorderSizePixel = 0})
    round(frame, 9)
    new("TextLabel", {Text = label, Size = UDim2.new(1, -90, 1, 0), Position = UDim2.new(0, 7.5, 0, 0), BackgroundTransparency = 1, TextColor3 = COL_TXT, Font = Enum.Font.GothamSemibold, TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left}, frame)
    local bg = new("Frame", {Size = UDim2.new(0, 60, 0, 30), Position = UDim2.new(1, -67.5, 0.5, -15), BorderSizePixel = 0}, frame)
    round(bg, 15)
    local knob = new("Frame", {Size = UDim2.new(0, 24, 0, 24), BorderSizePixel = 0}, bg)
    round(knob, 12)
    local enabled = initial
    local function refresh()
        bg.BackgroundColor3 = enabled and Color3.fromRGB(50, 100, 255) or Color3.fromRGB(80, 80, 90)
        knob.BackgroundColor3 = enabled and Color3.new(1, 1, 1) or Color3.fromRGB(200, 200, 200)
        knob.Position = enabled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
    end
    refresh()
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            enabled = not enabled
            onToggle(enabled)
            refresh()
        end
    end)
    put(frame)
    return frame, function(state) enabled = state refresh() end
end

-- Переключатель с проверкой: если действие не удалось (нет персонажа/друга) - возвращаем в выключенное
local function checkedToggle(label, initial, key, action)
    local _, set
    _, set = toggle(label, initial, function(on)
        S[key] = on
        if action(on) == false then S[key] = false set(false) end
    end)
end

------------------------------------------------------------------
-- UI: страницы
------------------------------------------------------------------
local function showTeleports()
    clearContent()
    title(T("teleports"))
    for _, d in ipairs(TELEPORTS) do
        local x, y, z = d[2], d[3], d[4]
        button(N(d[1]), function() teleport(x, y, z) end)
    end
end

local function showUtilities()
    clearContent()
    title(T("utilities"))
    button("🎭 " .. T("cloneBridgeLabel"), function() task.spawn(spawnAllClones) end, Color3.fromRGB(80, 50, 100))
    toggle(T("exitDoorLabel"), S.exitEsp, function(on) S.exitEsp = on setExitEsp(on) end)
    checkedToggle(T("teleportPlayersLabel"), S.freezePlayers, "freezePlayers", setFreezePlayers)
    toggle(T("takeBabyLabel"), S.baby, function(on) S.baby = on setBabySpam(on) end)
    toggle(T("tugOfWarLabel"), S.tug, function(on) S.tug = on setTugSpam(on) end)
    button("🌌 " .. T("afkLabel"), goAfk)
end

local function showSaveFriend()
    clearContent()
    title(T("instruction"))
    note(T("selectFriendLabel"))

    -- Список игроков в прокручиваемой рамке; друзья зелёные, выбранный с рамкой
    local list = put(new("ScrollingFrame", {Size = UDim2.new(1, -15, 0, 180), BackgroundColor3 = Color3.fromRGB(40, 40, 50), BorderSizePixel = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 4}))
    round(list, 9)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, list)
    new("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, list)

    local plrs = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then plrs[#plrs + 1] = plr end
    end
    table.sort(plrs, function(a, b) return a.Name < b.Name end)
    if #plrs == 0 then
        new("TextLabel", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Text = T("noPlayers"), TextColor3 = Color3.fromRGB(180, 180, 200), Font = Enum.Font.Gotham, TextSize = 16}, list)
    end
    for _, plr in ipairs(plrs) do
        local friend = isFriend(plr)
        local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = friend and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(50, 50, 70),
            TextColor3 = friend and Color3.fromRGB(200, 255, 200) or Color3.new(1, 1, 1), Text = plr.Name, Font = Enum.Font.Gotham, TextSize = 18}, list)
        round(b, 6)
        if plr.Name == S.friend then new("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2}, b) end
        b.MouseButton1Click:Connect(function() S.friend = plr.Name showSaveFriend() end)
    end

    checkedToggle(T("freezeSelfLabel"), S.selfFreeze, "selfFreeze", setSelfFreeze)
    note(T("danceHint"), Color3.fromRGB(255, 200, 100))
    checkedToggle(T("tpFriendLabel"), S.magnet, "magnet", setMagnet)
end

local function showSettings()
    clearContent()
    title(T("languageLabel"))
    for _, code in ipairs({"ru", "uk", "kk", "en"}) do
        button(T("lang_" .. code), function()
            S.language = code
            SaveConfig()
            UI.rebuild()
        end, code == S.language and COL_ACTIVE or nil)
    end
end

------------------------------------------------------------------
-- UI: главное окно
------------------------------------------------------------------
function UI.rebuild()
    if screenGuiMain then screenGuiMain:Destroy() end
    screenGuiMain = new("ScreenGui", {Name = "PidromaniaHub_SquidGame", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, playerGui)
    ApplyMobileScale(screenGuiMain, 1250)

    local main = new("Frame", {Size = UDim2.new(0, 1200, 0, 750), Position = UDim2.new(0.5, -600, 0.5, -375), BackgroundColor3 = Color3.fromRGB(20, 20, 25), BorderSizePixel = 0, Active = true}, screenGuiMain)
    round(main, 15)
    local mini = new("Frame", {Size = UDim2.new(0, 150, 0, 45), Position = UDim2.new(0, 10, 0, 10), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Visible = false, Active = true}, screenGuiMain)
    round(mini, 9)
    MakeDraggableTouch(mini, mini)
    new("TextLabel", {Text = "Pidromania Hub", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = COL_TITLE, Font = Enum.Font.GothamBold, TextSize = 18}, mini)
    mini.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            main.Visible, mini.Visible = true, false
        end
    end)
    UI.main, UI.mini = main, mini

    -- Шапка
    local header = new("Frame", {Size = UDim2.new(1, 0, 0, 52.5), BackgroundColor3 = Color3.fromRGB(30, 30, 40), BorderSizePixel = 0, Active = true}, main)
    round(header, 9)
    MakeDraggableTouch(header, main)
    local titleLbl = new("TextLabel", {Text = T("hubTitle"), Font = Enum.Font.GothamBold, TextSize = 21, BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220, 220, 255), Position = UDim2.new(0, 5, 0, 10.5)}, header)
    local ts = TextService:GetTextSize(titleLbl.Text, 21, Enum.Font.GothamBold, Vector2.new(math.huge, math.huge))
    titleLbl.Size = UDim2.new(0, ts.X * 1.1, 0, 30)
    local authorLbl = new("TextLabel", {Text = T("byAuthor"), Font = Enum.Font.GothamSemibold, TextSize = 18, BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 180)}, header)
    local as = TextService:GetTextSize(authorLbl.Text, 18, Enum.Font.GothamSemibold, Vector2.new(math.huge, math.huge))
    authorLbl.Size = UDim2.new(0, as.X * 1.1, 0, 30)
    authorLbl.Position = UDim2.new(0, 5 + ts.X * 1.1 - 15, 0, 10.5)
    local minBtn = new("TextButton", {Text = "—", Size = UDim2.new(0, 37.5, 0, 37.5), Position = UDim2.new(1, -45, 0, 7.5), BackgroundColor3 = Color3.fromRGB(60, 60, 70), TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 21}, header)
    minBtn.MouseButton1Click:Connect(function() main.Visible, mini.Visible = false, true end)

    -- Панели
    local left = new("Frame", {Size = UDim2.new(0, 300, 1, -52.5), Position = UDim2.new(0, 0, 0, 52.5), BackgroundColor3 = Color3.fromRGB(25, 25, 30), BorderSizePixel = 0}, main)
    round(left, 12)
    new("UIListLayout", {Padding = UDim.new(0, 4.5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, left)
    new("UIPadding", {PaddingTop = UDim.new(0, 7.5)}, left)

    local right = new("Frame", {Size = UDim2.new(1, -315, 1, -52.5), Position = UDim2.new(0, 315, 0, 52.5), BackgroundColor3 = Color3.fromRGB(30, 30, 35), BorderSizePixel = 0}, main)
    round(right, 12)
    UI.content = new("ScrollingFrame", {Size = UDim2.new(1, -15, 1, -15), Position = UDim2.new(0, 7.5, 0, 7.5), CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 6, BackgroundTransparency = 1}, right)
    round(UI.content, 9)
    new("UIListLayout", {Padding = UDim.new(0, 7.5), HorizontalAlignment = Enum.HorizontalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder}, UI.content)

    -- Меню
    local menu = {}
    local function addMenu(text, icon, pageFn)
        local btn = new("TextButton", {Text = "  " .. icon .. "  " .. text, Size = UDim2.new(1, -15, 0, 52.5), LayoutOrder = #menu + 1, BackgroundColor3 = Color3.fromRGB(50, 50, 60), TextColor3 = Color3.fromRGB(220, 220, 255), Font = Enum.Font.GothamSemibold, TextSize = 21, AutoButtonColor = true}, left)
        round(btn, 9)
        btn.MouseButton1Click:Connect(function()
            for _, b in ipairs(menu) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
            btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            pageFn()
        end)
        menu[#menu + 1] = btn
        return btn
    end
    local first = addMenu(T("teleports"), "🌐", showTeleports)
    addMenu(T("utilities"), "🛠️", showUtilities)
    addMenu(T("saveFriend"), "💾", showSaveFriend)
    addMenu(T("settings"), "⚙️", showSettings)

    first.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    showTeleports()
end

-- Горячая клавиша G: показать/скрыть хаб
track(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.G then return end
    if UI.main and UI.mini then
        local show = not UI.main.Visible
        UI.main.Visible, UI.mini.Visible = show, not show
    end
end))

------------------------------------------------------------------
-- Остановка этого экземпляра при повторном запуске
------------------------------------------------------------------
getgenv().SquidHubStop = function()
    for name in pairs(hooks) do setHook(name, false) end
    setBabySpam(false) setTugSpam(false)
    clearExitEsp()
    cleanupClones()
    for _, c in ipairs(connections) do c:Disconnect() end
    for plr in pairs(espObjects) do removeEsp(plr) end
    for plr in pairs(highlights) do removeEsp(plr) end
    if screenGuiMain then screenGuiMain:Destroy() end
end

UI.rebuild()
