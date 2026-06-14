-- Educational Hub "Pidromania Academy"
-- MAX DETAILED THEORY + RU/UK TRANSLATION

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Текущий язык (по умолчанию русский)
local currentLang = "ru"

-- База переводов интерфейса
local LOC = {
    ru = {
        hubTitle = "Pidromania Academy: Учим Luau",
        minimized = "Pidromania Academy",
        tabTheory = "Теория",
        tabTests = "Тесты (1-10)",
        tabPractice = "Практика (11-20)",
        tabControl = "Очистка / Сброс",
        testTitle = "Тест %d из 10",
        practiceTitle = "Практика %d из 20",
        inputHintTest = "Введи ответ сюда...",
        inputHintPractice = "-- Пиши код здесь\n",
        btnHint = "Подсказка",
        btnCheck = "Проверить",
        btnExecute = "Выполнить и Проверить",
        btnStop = "ОСТАНОВИТЬ СКРИПТЫ",
        msgCorrect = "✅ Правильно!",
        msgTestDone = "🎉 ТЕСТЫ ПРОЙДЕНЫ! Переходи к Практике.",
        msgWrong = "❌ Неверно. Подумай еще.",
        msgHint = "💡 Подсказка: ",
        msgCodeError = "❌ Ошибка в коде! Проверь F9.",
        msgPerfect = "✅ Идеально! Код сработал.",
        msgPracticeDone = "🎉 ПОЗДРАВЛЯЮ! ТЫ ПРОШЕЛ АКАДЕМИЮ!",
        msgWrongCommands = "⚠️ Код сработал, но задание не выполнено (не те команды).",
        ctrlTitle = "Экстренная Остановка",
        ctrlDesc = "Если ты случайно запустил бесконечный цикл (спам в консоль), нажми кнопку ниже. \n\nВАЖНО: Это сработает, только если в твоем цикле есть проверка: \n`while not _G.StopScript do`",
        ctrlSent = "Сигнал остановки отправлен!",
        ctrlReady = "Готово к новым скриптам.",
        pressF9 = "(Нажми F9 чтобы видеть консоль)"
    },
    uk = {
        hubTitle = "Pidromania Academy: Вчимо Luau",
        minimized = "Pidromania Academy",
        tabTheory = "Теорія",
        tabTests = "Тести (1-10)",
        tabPractice = "Практика (11-20)",
        tabControl = "Очищення / Скидання",
        testTitle = "Тест %d з 10",
        practiceTitle = "Практика %d з 20",
        inputHintTest = "Введи відповідь сюди...",
        inputHintPractice = "-- Пиши код тут\n",
        btnHint = "Підказка",
        btnCheck = "Перевірити",
        btnExecute = "Виконати та Перевірити",
        btnStop = "ЗУПИНИТИ СКРИПТИ",
        msgCorrect = "✅ Правильно!",
        msgTestDone = "🎉 ТЕСТИ ПРОЙДЕНО! Переходь до Практики.",
        msgWrong = "❌ Невірно. Подумай ще.",
        msgHint = "💡 Підказка: ",
        msgCodeError = "❌ Помилка в коді! Перевір F9.",
        msgPerfect = "✅ Ідеально! Код спрацював.",
        msgPracticeDone = "🎉 ВІТАЮ! ТИ ПРОЙШОВ АКАДЕМІЮ!",
        msgWrongCommands = "⚠️ Код спрацював, але завдання не виконано (не ті команди).",
        ctrlTitle = "Екстрена Зупинка",
        ctrlDesc = "Якщо ти випадково запустив нескінченний цикл (спам у консоль), натисни кнопку нижче. \n\nВАЖЛИВО: Це спрацює, лише якщо у твоєму циклі є перевірка: \n`while not _G.StopScript do`",
        ctrlSent = "Сигнал зупинки надіслано!",
        ctrlReady = "Готово до нових скриптів.",
        pressF9 = "(Натисни F9 щоб бачити консоль)"
    }
}

-- Огромная теория
local THEORY = {
    ru = [[
Добро пожаловать в <font color="#50FF50"><b>Академию Разработчиков Pidromania!</b></font>
Если ты хочешь писать читы (скрипты) для Роблокса через экзекьюторы (Xeno, Solara и др.), тебе нужно понять язык <b>Luau</b> и то, как устроена игра изнутри.

Твой самый главный инструмент — это <font color="#FF5050"><b>Консоль разработчика</b></font>. Чтобы ее открыть, нажми клавишу <b>F9</b> прямо в Роблоксе. В ней будут появляться все тексты, которые ты выводишь, и, самое главное, ошибки!

<font color="#50FF50"><b>ГЛАВА 1: ВЫВОД В КОНСОЛЬ И КОММЕНТАРИИ</b></font>
В Luau есть 3 функции вывода:
<b>1. print</b> (от англ. "печать") — Выводит обычный белый текст. Помогает проверить, работает ли скрипт. Пример: <font color="#AADDFF">print("Я хакер!")</font>
<b>2. warn</b> (от англ. "предупреждать") — Выводит <font color="#FFFF50">ЖЕЛТЫЙ ТЕКСТ</font>. Читеры используют его, чтобы выделить важную инфу. Пример: <font color="#AADDFF">warn("Мало ХП!")</font>
<b>3. error</b> (от англ. "ошибка") — Выводит <font color="#FF5050">КРАСНЫЙ ТЕКСТ</font> и <b>ПОЛНОСТЬЮ ОСТАНАВЛИВАЕТ</b> скрипт. Пример: <font color="#AADDFF">error("Взлом не удался!")</font>

<b>Комментарии:</b> Пишутся двумя минусами: <b>--</b>
<font color="#AAAAAA">-- Этот текст игра проигнорирует</font>

<font color="#50FF50"><b>ГЛАВА 2: ПЕРЕМЕННЫЕ</b></font>
Создаются словом <b>local</b>.
<font color="#AADDFF">local a = 5
local b = 10
print(a + b)</font> -- В консоль выведет 15!

<font color="#50FF50"><b>ГЛАВА 3: ИЕРАРХИЯ (game)</b></font>
1. <b>workspace</b> — Здесь лежит ВСЯ физика. Земля, дома, модельки игроков.
2. <b>game.Players</b> — Здесь лежат ДАННЫЕ игроков (их ники, аккаунты, деньги).
3. <b>game.Lighting</b> — Здесь лежит свет и время суток (<font color="#AADDFF">game.Lighting.ClockTime = 14</font>).

<font color="#50FF50"><b>ГЛАВА 4: LocalPlayer</b></font>
LocalPlayer — это ты. Лежит в game.Players.
<font color="#AADDFF">local player = game.Players.LocalPlayer</font>
Свойства: player.Name (Ник), player.Character (Моделька в игре).

<font color="#50FF50"><b>ГЛАВА 5: CHARACTER (Твоя моделька)</b></font>
<b>1. Humanoid</b> — Настройки жизни и движения (<font color="#AADDFF">WalkSpeed</font>, <font color="#AADDFF">Health</font>).
<b>2. HumanoidRootPart</b> — Невидимый кубик в центре живота. <b>В ЧИТАХ ВСЕ ТЕЛЕПОРТЫ ДЕЛАЮТСЯ ЧЕРЕЗ НЕГО!</b>
<font color="#AADDFF">game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 500, 0)</font>

<font color="#50FF50"><b>ГЛАВА 6: СВОЙСТВА И МЕТОДЫ</b></font>
- <b>Точка (.)</b> — Свойства. Пример: <font color="#AADDFF">Part.Transparency = 0.5</font>
- <b>Двоеточие (:)</b> — Методы (действия). Пример: <font color="#AADDFF">Part:Destroy()</font> (Уничтожить).
Чтобы узнать количество элементов в таблице, используй <b>#</b>:
<font color="#AADDFF">print( #game.Players:GetPlayers() )</font> — Выведет число игроков!

<font color="#50FF50"><b>ГЛАВА 7: ЦИКЛЫ</b></font>
<font color="#AADDFF">for i = 1, 5 do print(i) end</font>
Для бесконечных циклов в читах (автофарм) ОСТРОЖНО! Если не добавить паузу <font color="#AADDFF">task.wait()</font> — игра зависнет!
Для безопасности используй:
<font color="#AADDFF">while not _G.StopScript do
    print("Автофарм...")
    task.wait(1)
end</font>

Переходи во вкладку 'Тесты', чтобы проверить себя!
]],
    uk = [[
Ласкаво просимо до <font color="#50FF50"><b>Академії Розробників Pidromania!</b></font>
Якщо ти хочеш писати чіти (скрипти) для Роблокса через екзек'ютори (Xeno, Solara тощо), тобі потрібно зрозуміти мову <b>Luau</b> і те, як влаштована гра.

Твій найголовніший інструмент — це <font color="#FF5050"><b>Консоль розробника</b></font>. Щоб її відкрити, натисни <b>F9</b> прямо в грі. У ній будуть з'являтися всі тексти, які ти виводиш, і, головне, помилки!

<font color="#50FF50"><b>ГЛАВА 1: ВИВІД У КОНСОЛЬ ТА КОМЕНТАРІ</b></font>
У Luau є 3 функції виводу:
<b>1. print</b> (друк) — Виводить звичайний білий текст. Приклад: <font color="#AADDFF">print("Я хакер!")</font>
<b>2. warn</b> (попередження) — Виводить <font color="#FFFF50">ЖОВТИЙ ТЕКСТ</font>. Використовується для виділення важливої інфи. Приклад: <font color="#AADDFF">warn("Мало ХП!")</font>
<b>3. error</b> (помилка) — Виводить <font color="#FF5050">ЧЕРВОНИЙ ТЕКСТ</font> і <b>ПОВНІСТЮ ЗУПИНЯЄ</b> скрипт. Приклад: <font color="#AADDFF">error("Злам не вдався!")</font>

<b>Коментарі:</b> Пишуться двома мінусами: <b>--</b>
<font color="#AAAAAA">-- Цей текст гра проігнорує</font>

<font color="#50FF50"><b>ГЛАВА 2: ЗМІННІ</b></font>
Створюються словом <b>local</b>.
<font color="#AADDFF">local a = 5
local b = 10
print(a + b)</font> -- У консоль виведе 15!

<font color="#50FF50"><b>ГЛАВА 3: ІЄРАРХІЯ (game)</b></font>
1. <b>workspace</b> — Тут лежить УСЯ фізика. Земля, будинки, модельки гравців.
2. <b>game.Players</b> — Тут лежать ДАНІ гравців (їхні ніки, акаунти, гроші).
3. <b>game.Lighting</b> — Тут лежить світло і час доби (<font color="#AADDFF">game.Lighting.ClockTime = 14</font>).

<font color="#50FF50"><b>ГЛАВА 4: LocalPlayer</b></font>
LocalPlayer — це ти. Лежить у game.Players.
<font color="#AADDFF">local player = game.Players.LocalPlayer</font>
Властивості: player.Name (Нік), player.Character (Моделька у грі).

<font color="#50FF50"><b>ГЛАВА 5: CHARACTER (Твоя моделька)</b></font>
<b>1. Humanoid</b> — Налаштування життя та руху (<font color="#AADDFF">WalkSpeed</font>, <font color="#AADDFF">Health</font>).
<b>2. HumanoidRootPart</b> — Невидимий кубик у центрі живота. <b>У ЧІТАХ УСІ ТЕЛЕПОРТИ РОБЛЯТЬСЯ ЧЕРЕЗ НЬОГО!</b>
<font color="#AADDFF">game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(0, 500, 0)</font>

<font color="#50FF50"><b>ГЛАВА 6: ВЛАСТИВОСТІ ТА МЕТОДИ</b></font>
- <b>Крапка (.)</b> — Властивості. Приклад: <font color="#AADDFF">Part.Transparency = 0.5</font>
- <b>Двокрапка (:)</b> — Методи (дії). Приклад: <font color="#AADDFF">Part:Destroy()</font> (Знищити).
Щоб дізнатися кількість елементів у таблиці, використовуй <b>#</b>:
<font color="#AADDFF">print( #game.Players:GetPlayers() )</font> — Виведе кількість гравців!

<font color="#50FF50"><b>ГЛАВА 7: ЦИКЛИ</b></font>
<font color="#AADDFF">for i = 1, 5 do print(i) end</font>
Для нескінченних циклів у чітах (автофарм) ОБЕРЕЖНО! Якщо не додати паузу <font color="#AADDFF">task.wait()</font> — гра зависне!
Для безпеки використовуй:
<font color="#AADDFF">while not _G.StopScript do
    print("Автофарм...")
    task.wait(1)
end</font>

Переходь у вкладку 'Тести', щоб перевірити себе!
]]
}

-- ====== БАЗА ЗАДАНИЙ ======
local TESTS = {
    { 
        q = {ru = "Какой командой вывести обычный текст в консоль (F9)?", uk = "Якою командою вивести звичайний текст у консоль (F9)?"}, 
        a = "print", 
        hint = {ru = "Посмотри в Главе 1.", uk = "Подивись у Главі 1."}
    },
    { 
        q = {ru = "Какой командой вывести желтое предупреждение?", uk = "Якою командою вивести жовте попередження?"}, 
        a = "warn", 
        hint = {ru = "Посмотри в Главе 1.", uk = "Подивись у Главі 1."}
    },
    { 
        q = {ru = "Какая команда выводит красный текст и ОСТАНАВЛИВАЕТ скрипт?", uk = "Яка команда виводить червоний текст і ЗУПИНЯЄ скрипт?"}, 
        a = "error", 
        hint = {ru = "Посмотри в Главе 1.", uk = "Подивись у Главі 1."}
    },
    { 
        q = {ru = "Как пишутся комментарии (какие два символа)?", uk = "Як пишуться коментарі (які два символи)?"}, 
        a = "--", 
        hint = {ru = "Посмотри в Главе 1.", uk = "Подивись у Главі 1."}
    },
    { 
        q = {ru = "Где хранятся все физические объекты карты (деревья, здания)?", uk = "Де зберігаються всі фізичні об'єкти карти (дерева, будинки)?"}, 
        a = "workspace", 
        hint = {ru = "Посмотри в Главе 3.", uk = "Подивись у Главі 3."}
    },
    { 
        q = {ru = "Где лежат все игроки на сервере (game.***)?", uk = "Де лежать всі гравці на сервері (game.***)?"}, 
        a = "players", 
        hint = {ru = "Посмотри в Главе 3.", uk = "Подивись у Главі 3."}
    },
    { 
        q = {ru = "Какое ключевое слово используется для создания переменной?", uk = "Яке ключове слово використовується для створення змінної?"}, 
        a = "local", 
        hint = {ru = "Посмотри в Главе 2.", uk = "Подивись у Главі 2."}
    },
    { 
        q = {ru = "Как называется объект твоего игрока (game.Players.***)?", uk = "Як називається об'єкт твого гравця (game.Players.***)?"}, 
        a = "localplayer", 
        hint = {ru = "Посмотри в Главе 4.", uk = "Подивись у Главі 4."}
    },
    { 
        q = {ru = "Как называется часть персонажа, отвечающая за его здоровье и скорость?", uk = "Як називається частина персонажа, що відповідає за його здоров'я та швидкість?"}, 
        a = "humanoid", 
        hint = {ru = "Посмотри в Главе 5.", uk = "Подивись у Главі 5."}
    },
    { 
        q = {ru = "Как называется главная деталь в персонаже, за которую его телепортируют?", uk = "Як називається головна деталь у персонажі, за яку його телепортують?"}, 
        a = "humanoidrootpart", 
        hint = {ru = "Посмотри в Главе 5.", uk = "Подивись у Главі 5."}
    }
}

local PRACTICES = {
    { 
        q = {ru = "Выведи в консоль фразу 'Привет мир'.", uk = "Виведи в консоль фразу 'Привіт світ'."}, 
        check = {ru = {"print", "Привет мир"}, uk = {"print", "Привіт світ"}}, 
        hint = {ru = "Напиши: print('Привет мир')", uk = "Напиши: print('Привіт світ')"}
    },
    { 
        q = {ru = "Выведи в консоль свое имя через LocalPlayer.", uk = "Виведи в консоль своє ім'я через LocalPlayer."}, 
        check = {ru = {"print", "localplayer.name"}, uk = {"print", "localplayer.name"}}, 
        hint = {ru = "Сделай print, а внутри путь: game.Players.LocalPlayer.Name", uk = "Зроби print, а всередині шлях: game.Players.LocalPlayer.Name"}
    },
    { 
        q = {ru = "Сделай переменную 'a' = 5, 'b' = 10, и выведи их сумму.", uk = "Зроби змінну 'a' = 5, 'b' = 10, і виведи їхню суму."}, 
        check = {ru = {"local", "5", "10", "print"}, uk = {"local", "5", "10", "print"}}, 
        hint = {ru = "Создай через local две переменные, а потом print(a + b)", uk = "Створи через local дві змінні, а потім print(a + b)"}
    },
    { 
        q = {ru = "Измени скорость (WalkSpeed) персонажу на 100.", uk = "Зміни швидкість (WalkSpeed) персонажу на 100."}, 
        check = {ru = {"localplayer.character.humanoid.walkspeed", "100"}, uk = {"localplayer.character.humanoid.walkspeed", "100"}}, 
        hint = {ru = "Путь: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100", uk = "Шлях: game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100"}
    },
    { 
        q = {ru = "Удали у своего персонажа правую руку ('Right Arm').", uk = "Видали у свого персонажа праву руку ('Right Arm')."}, 
        check = {ru = {"localplayer.character", "destroy"}, uk = {"localplayer.character", "destroy"}}, 
        hint = {ru = "Найди руку и примени к ней метод :Destroy()", uk = "Знайди руку і застосуй до неї метод :Destroy()"}
    },
    { 
        q = {ru = "Напиши цикл for от 1 до 5, который выводит цифры в консоль.", uk = "Напиши цикл for від 1 до 5, який виводить цифри в консоль."}, 
        check = {ru = {"for", "1, 5", "do", "print"}, uk = {"for", "1, 5", "do", "print"}}, 
        hint = {ru = "Посмотри Главу 7. Используй for i = 1, 5 do ...", uk = "Подивись Главу 7. Використовуй for i = 1, 5 do ..."}
    },
    { 
        q = {ru = "Вылечи себя (сделай Health = MaxHealth у Humanoid).", uk = "Вилікуй себе (зроби Health = MaxHealth у Humanoid)."}, 
        check = {ru = {"humanoid.health", "humanoid.maxhealth"}, uk = {"humanoid.health", "humanoid.maxhealth"}}, 
        hint = {ru = "Нужно приравнять одно свойство Humanoid к другому.", uk = "Потрібно прирівняти одну властивість Humanoid до іншої."}
    },
    { 
        q = {ru = "Измени время суток на 14:00 (через game.Lighting.ClockTime).", uk = "Зміни час доби на 14:00 (через game.Lighting.ClockTime)."}, 
        check = {ru = {"game.lighting.clocktime", "14"}, uk = {"game.lighting.clocktime", "14"}}, 
        hint = {ru = "Приравняй свойство ClockTime в Lighting к 14.", uk = "Прирівняй властивість ClockTime у Lighting до 14."}
    },
    { 
        q = {ru = "Выведи красную ошибку 'Взлом'.", uk = "Виведи червону помилку 'Злам'."}, 
        check = {ru = {"error", "Взлом"}, uk = {"error", "Злам"}}, 
        hint = {ru = "Используй функцию error('Взлом')", uk = "Використовуй функцію error('Злам')"}
    },
    { 
        q = {ru = "Телепортируй себя на высоту 500 блоков вверх.", uk = "Телепортуй себе на висоту 500 блоків вгору."}, 
        check = {ru = {"localplayer.character.humanoidrootpart.cframe", "cframe.new"}, uk = {"localplayer.character.humanoidrootpart.cframe", "cframe.new"}}, 
        hint = {ru = "Измени CFrame у HumanoidRootPart на CFrame.new(0, 500, 0)", uk = "Зміни CFrame у HumanoidRootPart на CFrame.new(0, 500, 0)"}
    }
}

local currentTest = 1
local currentPractice = 1
_G.StopScript = false

-- Функция для получения перевода
local function L(key)
    return LOC[currentLang][key] or key
end

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
    minimizedLabel.Text = L("minimized")
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
    title.Text = L("hubTitle")
    title.Font = Enum.Font.GothamBold
    title.TextSize = 21
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    title.Size = UDim2.new(0, 400, 0, 30)
    title.Position = UDim2.new(0, 15, 0, 10.5)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Кнопка языка
    local langBtn = Instance.new("TextButton")
    langBtn.Text = currentLang == "ru" and "RU 🇷🇺" or "UK 🇺🇦"
    langBtn.Size = UDim2.new(0, 80, 0, 37.5)
    langBtn.Position = UDim2.new(1, -135, 0, 7.5)
    langBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    langBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    langBtn.Font = Enum.Font.GothamBold
    langBtn.TextSize = 18
    langBtn.Parent = header
    
    local langCorner = Instance.new("UICorner")
    langCorner.CornerRadius = UDim.new(0, 9)
    langCorner.Parent = langBtn
    
    langBtn.MouseButton1Click:Connect(function()
        currentLang = currentLang == "ru" and "uk" or "ru"
        rebuildGUI()
    end)
    
    -- Кнопка сворачивания
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
    
    -- ===== 1. ТЕОРИЯ =====
    local function showTheory()
        clearContent()
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1, -10, 0, 3200) 
        text.Position = UDim2.new(0, 5, 0, 5)
        text.BackgroundTransparency = 1
        text.TextColor3 = Color3.fromRGB(220, 220, 220)
        text.Font = Enum.Font.Gotham
        text.TextSize = 16
        text.TextWrapped = true
        text.RichText = true
        text.TextXAlignment = Enum.TextXAlignment.Left
        text.TextYAlignment = Enum.TextYAlignment.Top
        text.Text = THEORY[currentLang]
        text.Parent = contentContainer
        contentContainer.CanvasSize = UDim2.new(0, 0, 0, 3200)
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
        title.Text = string.format(L("testTitle"), currentTest)
        title.Parent = contentContainer
        
        local question = Instance.new("TextLabel")
        question.Size = UDim2.new(1, -20, 0, 100)
        question.Position = UDim2.new(0, 10, 0, 60)
        question.BackgroundTransparency = 1
        question.TextColor3 = Color3.fromRGB(255, 255, 255)
        question.Font = Enum.Font.GothamSemibold
        question.TextSize = 20
        question.TextWrapped = true
        question.Text = TESTS[currentTest].q[currentLang]
        question.Parent = contentContainer
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(1, -40, 0, 50)
        input.Position = UDim2.new(0, 20, 0, 180)
        input.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        input.TextColor3 = Color3.fromRGB(0, 255, 0)
        input.Font = Enum.Font.Code
        input.TextSize = 18
        input.Text = ""
        input.PlaceholderText = L("inputHintTest")
        input.ClearTextOnFocus = false
        input.Parent = contentContainer
        
        local inputCorner = Instance.new("UICorner") inputCorner.CornerRadius = UDim.new(0, 8) inputCorner.Parent = input
        
        local resultMsg = Instance.new("TextLabel")
        resultMsg.Size = UDim2.new(1, 0, 0, 30)
        resultMsg.Position = UDim2.new(0, 0, 0, 320)
        resultMsg.BackgroundTransparency = 1
        resultMsg.Font = Enum.Font.GothamBold
        resultMsg.TextSize = 18
        resultMsg.Text = ""
        resultMsg.Parent = contentContainer
        
        local hintBtn = Instance.new("TextButton")
        hintBtn.Size = UDim2.new(0, 140, 0, 50)
        hintBtn.Position = UDim2.new(0.5, 60, 0, 250)
        hintBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        hintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hintBtn.Font = Enum.Font.GothamBold
        hintBtn.TextSize = 16
        hintBtn.Text = L("btnHint")
        hintBtn.Parent = contentContainer
        local hintCorner = Instance.new("UICorner") hintCorner.CornerRadius = UDim.new(0, 8) hintCorner.Parent = hintBtn
        
        local submitBtn = Instance.new("TextButton")
        submitBtn.Size = UDim2.new(0, 200, 0, 50)
        submitBtn.Position = UDim2.new(0.5, -150, 0, 250)
        submitBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 60)
        submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        submitBtn.Font = Enum.Font.GothamBold
        submitBtn.TextSize = 18
        submitBtn.Text = L("btnCheck")
        submitBtn.Parent = contentContainer
        local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 8) btnCorner.Parent = submitBtn
        
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
            hintText.Text = L("msgHint") .. TESTS[currentTest].hint[currentLang]
        end)
        
        submitBtn.MouseButton1Click:Connect(function()
            local ans = string.lower(string.match(input.Text, "^%s*(.-)%s*$"))
            if ans == string.lower(TESTS[currentTest].a) then
                resultMsg.TextColor3 = Color3.fromRGB(50, 255, 50)
                resultMsg.Text = L("msgCorrect")
                task.wait(1.5)
                if currentTest < 10 then
                    currentTest = currentTest + 1
                    showTests()
                else
                    resultMsg.Text = L("msgTestDone")
                end
            else
                resultMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
                resultMsg.Text = L("msgWrong")
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
        title.Text = string.format(L("practiceTitle"), currentPractice + 10)
        title.Parent = contentContainer
        
        local question = Instance.new("TextLabel")
        question.Size = UDim2.new(1, -20, 0, 80)
        question.Position = UDim2.new(0, 10, 0, 60)
        question.BackgroundTransparency = 1
        question.TextColor3 = Color3.fromRGB(255, 200, 100)
        question.Font = Enum.Font.GothamSemibold
        question.TextSize = 18
        question.TextWrapped = true
        question.Text = PRACTICES[currentPractice].q[currentLang] .. "\n" .. L("pressF9")
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
        input.Text = L("inputHintPractice")
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
        
        local hintBtn = Instance.new("TextButton")
        hintBtn.Size = UDim2.new(0, 140, 0, 50)
        hintBtn.Position = UDim2.new(0.5, 130, 0, 320)
        hintBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        hintBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        hintBtn.Font = Enum.Font.GothamBold
        hintBtn.TextSize = 16
        hintBtn.Text = L("btnHint")
        hintBtn.Parent = contentContainer
        local hintCorner = Instance.new("UICorner") hintCorner.CornerRadius = UDim.new(0, 8) hintCorner.Parent = hintBtn

        local executeBtn = Instance.new("TextButton")
        executeBtn.Size = UDim2.new(0, 250, 0, 50)
        executeBtn.Position = UDim2.new(0.5, -135, 0, 320)
        executeBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
        executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        executeBtn.Font = Enum.Font.GothamBold
        executeBtn.TextSize = 18
        executeBtn.Text = L("btnExecute")
        executeBtn.Parent = contentContainer
        local btnCorner = Instance.new("UICorner") btnCorner.CornerRadius = UDim.new(0, 8) btnCorner.Parent = executeBtn
        
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
            hintText.Text = L("msgHint") .. "\n" .. PRACTICES[currentPractice].hint[currentLang]
        end)

        executeBtn.MouseButton1Click:Connect(function()
            local code = input.Text
            local passed = true
            
            for _, req in ipairs(PRACTICES[currentPractice].check[currentLang]) do
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
                    if func then func() else error("Syntax Error") end
                else
                    warn("Executor doesn't support loadstring.")
                end
            end)
            
            if not success then
                resultMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
                resultMsg.Text = L("msgCodeError")
                warn("Ошибка: " .. tostring(err))
            elseif passed then
                resultMsg.TextColor3 = Color3.fromRGB(50, 255, 50)
                resultMsg.Text = L("msgPerfect")
                task.wait(2)
                if currentPractice < 10 then
                    currentPractice = currentPractice + 1
                    showPractice()
                else
                    resultMsg.Text = L("msgPracticeDone")
                end
            else
                resultMsg.TextColor3 = Color3.fromRGB(255, 150, 50)
                resultMsg.Text = L("msgWrongCommands")
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
        title.Text = L("ctrlTitle")
        title.Parent = contentContainer
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -20, 0, 100)
        desc.Position = UDim2.new(0, 10, 0, 60)
        desc.BackgroundTransparency = 1
        desc.TextColor3 = Color3.fromRGB(220, 220, 220)
        desc.Font = Enum.Font.GothamSemibold
        desc.TextSize = 16
        desc.TextWrapped = true
        desc.Text = L("ctrlDesc")
        desc.Parent = contentContainer
        
        local stopBtn = Instance.new("TextButton")
        stopBtn.Size = UDim2.new(0, 300, 0, 60)
        stopBtn.Position = UDim2.new(0.5, -150, 0, 180)
        stopBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        stopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        stopBtn.Font = Enum.Font.GothamBold
        stopBtn.TextSize = 20
        stopBtn.Text = L("btnStop")
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
            msg.Text = L("ctrlSent")
            task.wait(1)
            _G.StopScript = false
            msg.Text = L("ctrlReady")
        end)
    end
    
    local theoryBtn = createMenuItem(L("tabTheory"), "📚")
    local testBtn = createMenuItem(L("tabTests"), "📝")
    local practiceBtn = createMenuItem(L("tabPractice"), "💻")
    local controlBtn = createMenuItem(L("tabControl"), "🛑")
    
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
