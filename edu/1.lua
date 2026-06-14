-- Educational Hub "Pidromania Academy"
-- MAX DETAILED THEORY VERSION

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- ====== БАЗА ЗАДАНИЙ ======
local TESTS = {
    { q = "Какой командой вывести обычный текст в консоль (F9)?", a = "print", hint = "Посмотри в Главе 1." },
    { q = "Какой командой вывести желтое предупреждение?", a = "warn", hint = "Посмотри в Главе 1." },
    { q = "Какая команда выводит красный текст и ОСТАНАВЛИВАЕТ скрипт?", a = "error", hint = "Посмотри в Главе 1." },
    { q = "Как в Luau пишутся комментарии к коду (какие два символа)?", a = "--", hint = "Посмотри в Главе 1." },
    { q = "Где хранятся все физические объекты карты (деревья, здания)?", a = "workspace", hint = "Посмотри в Главе 3." },
    { q = "Где лежат все игроки на сервере (game.***)?", a = "players", hint = "Посмотри в Главе 3." },
    { q = "Какое ключевое слово используется для создания переменной?", a = "local", hint = "Посмотри в Главе 2." },
    { q = "Как называется объект твоего игрока (game.Players.***)?", a = "localplayer", hint = "Посмотри в Главе 4." },
    { q = "Как называется часть персонажа, отвечающая за его здоровье и скорость?", a = "humanoid", hint = "Посмотри в Главе 5." },
    { q = "Как называется главная 'коробка' (деталь) в персонаже, за которую его телепортируют?", a = "humanoidrootpart", hint = "Посмотри в Главе 5." }
}

local PRACTICES = {
    { q = "Выведи в консоль фразу 'Привет мир'.", check = {"print", "Привет мир"}, hint = "Напиши: print('Привет мир')" },
    { q = "Выведи в консоль свое имя через LocalPlayer.", check = {"print", "localplayer.name"}, hint = "Сделай print, а внутри путь: game.Players.LocalPlayer.Name" },
    { q = "Сделай переменную 'a' = 5, 'b' = 10, и выведи их сумму.", check = {"local", "5", "10", "print"}, hint = "Создай через local две переменные, а потом print(a + b)" },
    { q = "Измени скорость (WalkSpeed) своему персонажу на 100.", check = {"localplayer.character.humanoid.walkspeed", "100"}, hint = "Путь: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100" },
    { q = "Удали у своего персонажа правую руку ('Right Arm').", check = {"localplayer.character", "destroy"}, hint = "Найди руку и примени к ней метод :Destroy()" },
    { q = "Напиши цикл for от 1 до 5, который выводит цифры в консоль.", check = {"for", "1, 5", "do", "print"}, hint = "Посмотри Главу 8. Используй for i = 1, 5 do ..." },
    { q = "Вылечи себя (сделай Health = MaxHealth у Humanoid).", check = {"humanoid.health", "humanoid.maxhealth"}, hint = "Нужно приравнять одно свойство Humanoid к другому." },
    { q = "Измени время суток в игре на 14:00 (через game.Lighting.ClockTime).", check = {"game.lighting.clocktime", "14"}, hint = "Приравняй свойство ClockTime в Lighting к 14." },
    { q = "Выведи в консоль красную ошибку 'Взлом жопы'.", check = {"error", "Взлом жопы"}, hint = "Используй функцию error() из Главы 1." },
    { q = "Телепортируй себя на высоту 500 блоков вверх.", check = {"localplayer.character.humanoidrootpart.cframe", "cframe.new"}, hint = "Измени CFrame у HumanoidRootPart на CFrame.new(0, 500, 0)" }
}

local currentTest = 1
local currentPractice = 1
_G.StopScript = false

-- ====== ПОСТРОЕНИЕ ИНТЕРФЕЙСА ======
local screenGuiMain = nil

local function rebuildGUI()
    if screenGuiMain then screenGuiMain:Destroy() end
    
    local pGui = player:FindFirstChild("PlayerGui")
    if pGui then
        for _, v in ipairs(pGui:GetChildren()) do
            if v.Name == "PidromaniaEduHub" then v:Destroy() end
        end
    end
    
    screenGuiMain = Instance.new("ScreenGui")
    screenGuiMain.Name = "PidromaniaEduHub"
    screenGuiMain.ResetOnSpawn = false
    screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGuiMain.Parent = pGui
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 1100, 0, 700)
    mainFrame.Position = UDim2.new(0.5, -550, 0.5, -350)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGuiMain
    
    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 15)
    mainFrameCorner.Parent = mainFrame
    
    local minimizedFrame = Instance.new("Frame")
    minimizedFrame.Size = UDim2.new(0, 200, 0, 45)
    minimizedFrame.Position = UDim2.new(0, 10, 0, 10)
    minimizedFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    minimizedFrame.BorderSizePixel = 0
    minimizedFrame.Visible = false
    minimizedFrame.Active = true
    minimizedFrame.Draggable = true
    minimizedFrame.Parent = screenGuiMain
    
    local cornerMinimized = Instance.new("UICorner")
    cornerMinimized.CornerRadius = UDim.new(0, 9)
    cornerMinimized.Parent = minimizedFrame
    
    local minimizedLabel = Instance.new("TextLabel")
    minimizedLabel.Text = "Pidromania Academy"
    minimizedLabel.Size = UDim2.new(1, 0, 1, 0)
    minimizedLabel.BackgroundTransparency = 1
    minimizedLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    minimizedLabel.Font = Enum.Font.GothamBold
    minimizedLabel.TextSize = 14
    minimizedLabel.Parent = minimizedFrame
    
    minimizedFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            mainFrame.Visible = true
            minimizedFrame.Visible = false
        end
    end)
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 52.5)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local cornerHeader = Instance.new("UICorner")
    cornerHeader.CornerRadius = UDim.new(0, 9)
    cornerHeader.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Text = "Pidromania Academy: Учим Luau"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    title.Size = UDim2.new(0, 400, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 10.5)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Text = "--"
    minimizeBtn.Size = UDim2.new(0, 37.5, 0, 37.5)
    minimizeBtn.Position = UDim2.new(1, -45, 0, 7.5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 21
    minimizeBtn.Parent = header
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 9)
    btnCorner.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        minimizedFrame.Visible = true
    end)
    
    local leftPanel = Instance.new("Frame")
    leftPanel.Size = UDim2.new(0, 250, 1, -52.5)
    leftPanel.Position = UDim2.new(0, 0, 0, 52.5)
    leftPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    leftPanel.BorderSizePixel = 0
    leftPanel.Parent = mainFrame
    
    local cornerLeft = Instance.new("UICorner")
    cornerLeft.CornerRadius = UDim.new(0, 12)
    cornerLeft.Parent = leftPanel
    
    local rightPanel = Instance.new("Frame")
    rightPanel.Size = UDim2.new(1, -265, 1, -52.5)
    rightPanel.Position = UDim2.new(0, 265, 0, 52.5)
    rightPanel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    rightPanel.BorderSizePixel = 0
    rightPanel.Parent = mainFrame
    
    local cornerRight = Instance.new("UICorner")
    cornerRight.CornerRadius = UDim.new(0, 12)
    cornerRight.Parent = rightPanel
    
    local contentContainer = Instance.new("ScrollingFrame")
    contentContainer.Size = UDim2.new(1, -15, 1, -15)
    contentContainer.Position = UDim2.new(0, 7.5, 0, 7.5)
    contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentContainer.ScrollBarThickness = 6
    contentContainer.BackgroundTransparency = 1
    contentContainer.Parent = rightPanel
    
    local menuItems = {}
    local function createMenuItem(name, icon)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Text = "  " .. (icon or "") .. "  " .. name
        btn.Size = UDim2.new(1, -15, 0, 52.5)
        btn.Position = UDim2.new(0, 7.5, 0, (#menuItems * 57) + 7.5)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        btn.TextColor3 = Color3.fromRGB(220, 220, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 18
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = true
        btn.Parent = leftPanel
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 9)
        corner.Parent = btn
        
        table.insert(menuItems, btn)
        return btn
    end
    
    local function clearContent()
        for _, child in ipairs(contentContainer:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    end
    
    -- ===== 1. ТЕОРИЯ (МАКСИМАЛЬНО ПОДРОБНАЯ) =====
    local function showTheory()
        clearContent()
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -10, 0, 4800) -- Огромный размер под книгу
        text.Position = UDim2.new(0, 5, 0, 5)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(220, 220, 220)
        text.Font = Enum.Font.Gotham
        text.TextSize = 16
        text.TextWrapped = true
        text.RichText = true -- Позволяет использовать HTML теги для цвета
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextYAlignment = Enum.TextYAlignment.Top
        text.Text = [[
Добро пожаловать в <font color="#50FF50"><b>Академию Разработчиков Pidromania!</b></font>
Если ты хочешь писать читы (скрипты) для Роблокса через экзекьюторы (Xeno, Solara и др.), тебе нужно понять язык <b>Luau</b> и то, как устроена игра изнутри.

Твой самый главный инструмент — это <font color="#FF5050"><b>Консоль разработчика</b></font>. Чтобы ее открыть, нажми клавишу <b>F9</b> прямо в Роблоксе. В ней будут появляться все тексты, которые ты выводишь, и, самое главное, ошибки!

<font color="#50FF50"><b>ГЛАВА 1: ВЫВОД В КОНСОЛЬ И КОММЕНТАРИИ</b></font>
Чтобы скрипт "поговорил" с тобой, мы выводим слова в консоль.
В Luau есть 3 функции вывода:

<b>1. print</b> (от англ. "печать") — Выводит обычный белый текст. Помогает проверить, работает ли скрипт.
Пример: <font color="#AADDFF">print("Я крутой хакер!")</font>

<b>2. warn</b> (от англ. "предупреждать") — Выводит <font color="#FFFF50">ЖЕЛТЫЙ ТЕКСТ</font>. Читеры используют его, чтобы выделить важную информацию в консоли (например: "Игрок найден!").
Пример: <font color="#AADDFF">warn("Внимание! Здоровье на нуле!")</font>

<b>3. error</b> (от англ. "ошибка") — Выводит <font color="#FF5050">КРАСНЫЙ ТЕКСТ</font> и <b>ПОЛНОСТЬЮ ОСТАНАВЛИВАЕТ</b> скрипт. Используется, когда что-то сломалось и скрипту нельзя работать дальше.
Пример: <font color="#AADDFF">error("Взлом жопы не удался!")</font>

<b>Комментарии:</b>
Иногда нужно оставить записку для себя в коде, чтобы Роблокс её не читал. Комментарии пишутся двумя минусами (дефисами) подряд: <b>--</b>
Пример: <font color="#AAAAAA">-- Это просто текст, игра его проигнорирует</font>

<font color="#50FF50"><b>ГЛАВА 2: ПЕРЕМЕННЫЕ И МАТЕМАТИКА</b></font>
Переменная — это коробка, в которую мы кладем значение (число или текст), чтобы потом его использовать. В Luau переменные создаются ключевым словом <b>local</b> (локальный).

Пример:
<font color="#AADDFF">local a = 5
local b = 10
print(a + b)</font> -- В консоль выведет число 15!

<font color="#50FF50"><b>ГЛАВА 3: КАК УСТРОЕН МИР (ИЕРАРХИЯ)</b></font>
Вся игра Роблокс — это огромный объект под названием <b>game</b>. Внутри него лежат "папки" (сервисы). Самые важные для нас:

1. <b>workspace</b> (или game.Workspace) — Здесь лежит ВСЯ физика. Земля, дома, деревья, модельки игроков. Всё, что можно увидеть и потрогать, находится в workspace.
2. <b>game.Players</b> — Здесь лежат ДАННЫЕ игроков (их ники, аккаунты, деньги).
3. <b>game.Lighting</b> — Здесь лежит свет, небо и время суток.
Например, если ты напишешь: <font color="#AADDFF">game.Lighting.ClockTime = 14</font> — в игре мгновенно станет 14:00 (день)!

<font color="#50FF50"><b>ГЛАВА 4: ИГРОК VS ПЕРСОНАЖ</b></font>
Это самая частая ошибка новичков. Игрок и Персонаж — это ДВЕ РАЗНЫЕ ВЕЩИ.

<b>LocalPlayer</b> — это ты (Твой аккаунт, твои данные). Он лежит в game.Players.
Как его получить: <font color="#AADDFF">local player = game.Players.LocalPlayer</font>
У него есть свойства:
- player.Name (Твой никнейм)
- player.UserId (Твой ID)

<b>Character</b> — это твоя физическая моделька из кубиков, которая бегает по workspace.
Как её получить: <font color="#AADDFF">local char = game.Players.LocalPlayer.Character</font>
Если Character умрет, LocalPlayer останется жить и просто заспавнит новый Character!

<font color="#50FF50"><b>ГЛАВА 5: АНАТОМИЯ ПЕРСОНАЖА (CHARACTER)</b></font>
Твоя моделька (Character) состоит из деталей. Две самые важные детали для написания читов:

<b>1. Humanoid</b> (Хьюманоид / Человекоподобный)
Это "душа" персонажа. В нем хранятся настройки жизни и движения.
Если обратиться к: <font color="#AADDFF">game.Players.LocalPlayer.Character.Humanoid</font>
То можно поменять свойства:
- <b>WalkSpeed</b> — Скорость бега (обычно 16). Поставь 100 и будешь летать как флэш.
- <b>Health</b> — Текущее здоровье.
- <b>MaxHealth</b> — Максимальное здоровье. 
Чтобы вылечить себя кодом, напиши: <font color="#AADDFF">Humanoid.Health = Humanoid.MaxHealth</font>

<b>2. HumanoidRootPart</b> (Корневая часть)
Это прозрачный кубик внутри твоего живота. Он держит все остальные части тела.
<b>В ЧИТАХ ВСЕ ТЕЛЕПОРТЫ ДЕЛАЮТСЯ ЧЕРЕЗ НЕГО!</b>
За позицию в пространстве отвечает свойство <b>CFrame</b>.
Чтобы телепортироваться, мы пишем:
<font color="#AADDFF">game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 500, 0)</font>
<i>(CFrame.new означает "Создать новую координату", цифры — это X, Y, Z. Высота — это средняя цифра Y).</i>

<font color="#50FF50"><b>ГЛАВА 6: СВОЙСТВА И МЕТОДЫ</b></font>
В Роблоксе мы используем точку (.) и двоеточие (:). В чем разница?
- <b>Точка (.)</b> обращается к СВОЙСТВАМ (настройкам). Свойства можно менять через знак равно (=).
- <b>Двоеточие (:)</b> обращается к МЕТОДАМ (действиям). Объект что-то ДЕЛАЕТ.

Например, у нас есть правая рука персонажа: "Right Arm" (или "RightHand" в R15).
Если мы применим метод <b>:Destroy()</b>, объект уничтожится навсегда!
Пример отрыва руки:
<font color="#AADDFF">game.Players.LocalPlayer.Character["Right Arm"]:Destroy()</font>

Другой крутой метод: <b>:GetPlayers()</b>
Если применить его к папке Players, он вернет ТАБЛИЦУ (список) всех игроков на сервере.
<font color="#AADDFF">local all_players = game.Players:GetPlayers()</font>

А чтобы узнать <b>КОЛИЧЕСТВО</b> элементов в таблице (сколько игроков), используется символ <b>#</b> (решетка).
<font color="#AADDFF">print( #game.Players:GetPlayers() )</font> — Выведет в консоль число игроков!

<font color="#50FF50"><b>ГЛАВА 7: ЦИКЛЫ (ПОВТОРЕНИЕ КОДА)</b></font>
Циклы заставляют код выполняться много раз.

<b>Цикл FOR (Для)</b>: Повторяет код заданное количество раз.
<font color="#AADDFF">for i = 1, 5 do
    print(i)
end</font>
<i>(Этот код выведет в консоль 1, 2, 3, 4, 5)</i>

<b>БЕСКОНЕЧНЫЙ ЦИКЛ WHILE (Пока):</b>
В читах (автофармах) код должен работать вечно. Используют while true do.
<font color="#FF5050"><b>ВНИМАНИЕ! КРИТИЧЕСКАЯ ОШИБКА НОВИЧКОВ!</b></font>
Если ты напишешь бесконечный цикл и не добавишь туда паузу (задержку), игра зависнет НАМЕРТВО за 1 миллисекунду, потому что скрипт попытается выполнить код бесконечное количество раз в секунду.
Обязательно используй <b>task.wait()</b> внутри цикла!

Для безопасности в обучении мы используем переменную _G.StopScript:
<font color="#AADDFF">while not _G.StopScript do
    print("Автофарм работает...")
    task.wait(1) -- Ждем 1 секунду! Без этого игра умрет!
end</font>

Теперь ты знаешь всю базу! Переходи во вкладку 'Тесты', чтобы проверить себя, а затем приступай к Практике!
]]
        text.Parent = contentContainer
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 2200)
    end
    
    -- ===== 2. ТЕСТЫ =====
    local function showTests()
        clearContent()
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 24
        title.Text = "Тест " .. currentTest .. " из 10"
        title.Parent = contentContainer
        
        local question = Instance.new("TextLabel")
        question.Size = UDim2.new(1, -20, 0, 100)
        question.Position = UDim2.new(0, 10, 0, 60)
        question.BackgroundTransparency = 1
        question.TextColor3 = Color3.fromRGB(255, 255, 255)
        question.Font = Enum.Font.GothamSemibold
        question.TextSize = 20
        question.TextWrapped = true
        question.Text = TESTS[currentTest].q
        question.Parent = contentContainer
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -40, 0, 50)
        input.Position = UDim2.new(0, 20, 0, 180)
        input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        input.TextColor3 = Color3.fromRGB(0, 255, 0)
        input.Font = Enum.Font.Code
        input.TextSize = 18
        input.Text = ""
        input.PlaceholderText = "Введи ответ сюда..."
        input.ClearTextOnFocus = false
        input.Parent = contentContainer
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 8)
        inputCorner.Parent = input
        
        local resultMsg = Instance.new("TextLabel")
        resultMsg.Size = UDim2.new(1, 0, 0, 30)
        resultMsg.Position = UDim2.new(0, 0, 0, 320)
        resultMsg.BackgroundTransparency = 1
        resultMsg.Font = Enum.Font.GothamBold
        resultMsg.TextSize = 18
        resultMsg.Text = ""
        resultMsg.Parent = contentContainer
        
        -- Кнопка Подсказки
        local hintBtn = Instance.new("TextButton")
        hintBtn.Size = UDim2.new(0, 140, 0, 50)
        hintBtn.Position = UDim2.new(0.5, 60, 0, 250)
        hintBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        hintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hintBtn.Font = Enum.Font.GothamBold
        hintBtn.TextSize = 16
        hintBtn.Text = "Подсказка"
        hintBtn.Parent = contentContainer
        local hintCorner = Instance.new("UICorner") hintCorner.CornerRadius = UDim.new(0, 8) hintCorner.Parent = hintBtn
        
        -- Кнопка Проверки
        local submitBtn = Instance.new("TextButton")
        submitBtn.Size = UDim2.new(0, 200, 0, 50)
        submitBtn.Position = UDim2.new(0.5, -150, 0, 250)
        submitBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitBtn.Font = Enum.Font.GothamBold
        submitBtn.TextSize = 18
        submitBtn.Text = "Проверить"
        submitBtn.Parent = contentContainer
        local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 8) btnCorner.Parent = submitBtn
        
        -- Текст подсказки
        local hintText = Instance.new("TextLabel")
        hintText.Size = UDim2.new(1, -20, 0, 50)
        hintText.Position = UDim2.new(0, 10, 0, 360)
        hintText.BackgroundTransparency = 1
        hintText.TextColor3 = Color3.fromRGB(255, 255, 100)
        hintText.Font = Enum.Font.GothamSemibold
        hintText.TextSize = 16
        hintText.TextWrapped = true
        hintText.Text = ""
        hintText.Parent = contentContainer

        hintBtn.MouseButton1Click:Connect(function()
            hintText.Text = "💡 Подсказка: " .. TESTS[currentTest].hint
        end)
        
        submitBtn.MouseButton1Click:Connect(function()
            local ans = string.lower(string.match(input.Text, "^%s*(.-)%s*$"))
            if ans == string.lower(TESTS[currentTest].a) then
                resultMsg.TextColor3 = Color3.fromRGB(50, 255, 50)
                resultMsg.Text = "✅ Правильно!"
                task.wait(1.5)
                if currentTest < 10 then
                    currentTest = currentTest + 1
                    showTests()
                else
                    resultMsg.Text = "🎉 ТЕСТЫ ПРОЙДЕНЫ! Переходи к Практике."
                end
            else
                resultMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
                resultMsg.Text = "❌ Неверно. Подумай еще."
            end
        end)
    end
    
    -- ===== 3. ПРАКТИКА =====
    local function showPractice()
        clearContent()
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(200, 200, 255)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 24
        title.Text = "Практика " .. (currentPractice + 10) .. " из 20"
        title.Parent = contentContainer
        
        local question = Instance.new("TextLabel")
        question.Size = UDim2.new(1, -20, 0, 80)
        question.Position = UDim2.new(0, 10, 0, 60)
        question.BackgroundTransparency = 1
        question.TextColor3 = Color3.fromRGB(255, 200, 100)
        question.Font = Enum.Font.GothamSemibold
        question.TextSize = 18
        question.TextWrapped = true
        question.Text = PRACTICES[currentPractice].q .. "\n(Нажми F9 чтобы видеть консоль)"
        question.Parent = contentContainer
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -40, 0, 150)
        input.Position = UDim2.new(0, 20, 0, 150)
        input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        input.TextColor3 = Color3.fromRGB(0, 255, 255)
        input.Font = Enum.Font.Code
        input.TextSize = 16
        input.TextXAlignment = Enum.TextXAlignment.Left
        input.TextYAlignment = Enum.TextYAlignment.Top
        input.Text = "-- Пиши код здесь\n"
        input.MultiLine = true
        input.ClearTextOnFocus = false
        input.Parent = contentContainer
        local inputCorner = Instance.new("UICorner") inputCorner.CornerRadius = UDim.new(0, 8) inputCorner.Parent = input
        
        local resultMsg = Instance.new("TextLabel")
        resultMsg.Size = UDim2.new(1, 0, 0, 30)
        resultMsg.Position = UDim2.new(0, 0, 0, 390)
        resultMsg.BackgroundTransparency = 1
        resultMsg.Font = Enum.Font.GothamBold
        resultMsg.TextSize = 18
        resultMsg.Text = ""
        resultMsg.Parent = contentContainer
        
        -- Кнопка Подсказки
        local hintBtn = Instance.new("TextButton")
        hintBtn.Size = UDim2.new(0, 140, 0, 50)
        hintBtn.Position = UDim2.new(0.5, 130, 0, 320)
        hintBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        hintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hintBtn.Font = Enum.Font.GothamBold
        hintBtn.TextSize = 16
        hintBtn.Text = "Подсказка"
        hintBtn.Parent = contentContainer
        local hintCorner = Instance.new("UICorner") hintCorner.CornerRadius = UDim.new(0, 8) hintCorner.Parent = hintBtn

        -- Кнопка Выполнить
        local executeBtn = Instance.new("TextButton")
        executeBtn.Size = UDim2.new(0, 250, 0, 50)
        executeBtn.Position = UDim2.new(0.5, -135, 0, 320)
        executeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
        executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        executeBtn.Font = Enum.Font.GothamBold
        executeBtn.TextSize = 18
        executeBtn.Text = "Выполнить и Проверить"
        executeBtn.Parent = contentContainer
        local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 8) btnCorner.Parent = executeBtn
        
        -- Текст подсказки
        local hintText = Instance.new("TextLabel")
        hintText.Size = UDim2.new(1, -20, 0, 80)
        hintText.Position = UDim2.new(0, 10, 0, 430)
        hintText.BackgroundTransparency = 1
        hintText.TextColor3 = Color3.fromRGB(255, 255, 100)
        hintText.Font = Enum.Font.GothamSemibold
        hintText.TextSize = 16
        hintText.TextWrapped = true
        hintText.Text = ""
        hintText.Parent = contentContainer

        hintBtn.MouseButton1Click:Connect(function()
            hintText.Text = "💡 Подсказка: \n" .. PRACTICES[currentPractice].hint
        end)

        executeBtn.MouseButton1Click:Connect(function()
            local code = input.Text
            local passed = true
            
            for _, req in ipairs(PRACTICES[currentPractice].check) do
                local lowerCode = string.lower(code)
                local lowerReq = string.lower(req)
                local found = string.find(lowerCode, lowerReq, 1, true) or string.find(code, req, 1, true)
                
                if not found then
                    passed = false
                    break
                end
            end
            
            local success, err = pcall(function()
                if loadstring then
                    local func = loadstring(code)
                    if func then func() else error("Синтаксическая ошибка") end
                else
                    warn("Executor не поддерживает loadstring. Проверка только по тексту.")
                end
            end)
            
            if not success then
                resultMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
                resultMsg.Text = "❌ Ошибка в коде! Проверь F9."
                warn("Ошибка в обучении: " .. tostring(err))
            elseif passed then
                resultMsg.TextColor3 = Color3.fromRGB(50, 255, 50)
                resultMsg.Text = "✅ Идеально! Код сработал."
                task.wait(2)
                if currentPractice < 10 then
                    currentPractice = currentPractice + 1
                    showPractice()
                else
                    resultMsg.Text = "🎉 ПОЗДРАВЛЯЮ! ТЫ ПРОШЕЛ АКАДЕМИЮ!"
                end
            else
                resultMsg.TextColor3 = Color3.fromRGB(255, 150, 50)
                resultMsg.Text = "⚠️ Код сработал, но задание не выполнено (не те команды)."
            end
        end)
    end

    -- ===== 4. УПРАВЛЕНИЕ =====
    local function showControl()
        clearContent()
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 50)
        title.BackgroundTransparency = 1
        title.TextColor3 = Color3.fromRGB(255, 100, 100)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 24
        title.Text = "Экстренная Остановка"
        title.Parent = contentContainer
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 100)
        desc.Position = UDim2.new(0, 10, 0, 60)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(220, 220, 220)
        desc.Font = Enum.Font.GothamSemibold
        desc.TextSize = 16
        desc.TextWrapped = true
        desc.Text = "Если ты случайно запустил бесконечный цикл (спам в консоль), нажми кнопку ниже. \n\nВАЖНО: Это сработает, только если в твоем цикле есть проверка: \n`while not _G.StopScript do`"
        desc.Parent = contentContainer
        
        local stopBtn = Instance.new("TextButton")
        stopBtn.Size = UDim2.new(0, 300, 0, 60)
        stopBtn.Position = UDim2.new(0.5, -150, 0, 180)
        stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.TextSize = 20
        stopBtn.Text = "ОСТАНОВИТЬ СКРИПТЫ"
        stopBtn.Parent = contentContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = stopBtn
        
        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, 0, 0, 30)
        msg.Position = UDim2.new(0, 0, 0, 260)
        msg.BackgroundTransparency = 1
        msg.Font = Enum.Font.GothamBold
        msg.TextSize = 18
        msg.Text = ""
        msg.Parent = contentContainer
        
        stopBtn.MouseButton1Click:Connect(function()
            _G.StopScript = true
            msg.TextColor3 = Color3.fromRGB(50, 255, 50)
            msg.Text = "Сигнал остановки отправлен!"
            task.wait(1)
            _G.StopScript = false
            msg.Text = "Готово к новым скриптам."
        end)
    end
    
    local theoryBtn = createMenuItem("Теория", "📚")
    local testBtn = createMenuItem("Тесты (1-10)", "📝")
    local practiceBtn = createMenuItem("Практика (11-20)", "💻")
    local controlBtn = createMenuItem("Очистка / Сброс", "🛑")
    
    local function selectButton(btn)
        for _, b in ipairs(menuItems) do b.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
    end
    
    theoryBtn.MouseButton1Click:Connect(function() selectButton(theoryBtn) showTheory() end)
    testBtn.MouseButton1Click:Connect(function() selectButton(testBtn) showTests() end)
    practiceBtn.MouseButton1Click:Connect(function() selectButton(practiceBtn) showPractice() end)
    controlBtn.MouseButton1Click:Connect(function() selectButton(controlBtn) showControl() end)
    
    selectButton(theoryBtn)
    showTheory()
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.G then
            if mainFrame.Visible then
                mainFrame.Visible = false
                minimizedFrame.Visible = true
            else
                mainFrame.Visible = true
                minimizedFrame.Visible = false
            end
        end
    end)
end

rebuildGUI()
