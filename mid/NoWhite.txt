local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ==============================================================================
-- === GUI BUILDING: NOT IN WHITELIST MESSAGE + TIMER ===
-- ==============================================================================
local screenGuiWhitelist = nil

local function createWhitelistGUI()
	if screenGuiWhitelist then
		screenGuiWhitelist:Destroy()
	end

	screenGuiWhitelist = Instance.new("ScreenGui")
	screenGuiWhitelist.Name = "PidromaniaHub_Whitelist"
	screenGuiWhitelist.ResetOnSpawn = false
	screenGuiWhitelist.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGuiWhitelist.DisplayOrder = 10000 -- Поверх всего
	screenGuiWhitelist.IgnoreGuiInset = true 
	screenGuiWhitelist.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 1200, 0, 750)
	mainFrame.Position = UDim2.new(0.5, -600, 0.5, -346)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.ZIndex = 200
	mainFrame.Parent = screenGuiWhitelist

	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 15)
	mainFrameCorner.Parent = mainFrame

	-- 1. Заголовок (брендинг)
	local centerLabel = Instance.new("TextLabel")
	centerLabel.Name = "TitleLabel"
	centerLabel.Text = "Pidromania Airlinies"
	centerLabel.Size = UDim2.new(1, 0, 0.4, 0)
	centerLabel.Position = UDim2.new(0, 0, 0.1, 0)
	centerLabel.BackgroundTransparency = 1
	centerLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
	centerLabel.Font = Enum.Font.GothamBold
	centerLabel.TextSize = 54
	centerLabel.TextXAlignment = Enum.TextXAlignment.Center
	centerLabel.TextYAlignment = Enum.TextYAlignment.Center
	centerLabel.ZIndex = 201
	centerLabel.Parent = mainFrame

	-- 2. Основное сообщение: "Вы не в вайтлисте"
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "MessageLabel"
	messageLabel.Text = "⚠️ Вы не в вайтлисте"
	messageLabel.Size = UDim2.new(1, 0, 0.2, 0)
	messageLabel.Position = UDim2.new(0, 0, 0.45, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextColor3 = Color3.fromRGB(255, 180, 50) -- Оранжево-красный для предупреждения
	messageLabel.Font = Enum.Font.GothamBold
	messageLabel.TextSize = 36
	messageLabel.TextXAlignment = Enum.TextXAlignment.Center
	messageLabel.TextYAlignment = Enum.TextYAlignment.Center
	messageLabel.ZIndex = 201
	messageLabel.Parent = mainFrame

	-- 3. Инструкция: "Напишите мне в Telegram для проверки и добавления"
	local telegramLabel = Instance.new("TextLabel")
	telegramLabel.Name = "TelegramLabel"
	telegramLabel.Text = "Напишите мне в Telegram: @Pidromania\nдля проверки и добавления в whitelist"
	telegramLabel.Size = UDim2.new(1, 0, 0.25, 0)
	telegramLabel.Position = UDim2.new(0, 0, 0.6, 0)
	telegramLabel.BackgroundTransparency = 1
	telegramLabel.TextColor3 = Color3.fromRGB(100, 200, 255) -- Голубой, как Telegram
	telegramLabel.Font = Enum.Font.GothamBold
	telegramLabel.TextSize = 32
	telegramLabel.TextXAlignment = Enum.TextXAlignment.Center
	telegramLabel.TextYAlignment = Enum.TextYAlignment.Center
	telegramLabel.ZIndex = 201
	telegramLabel.Parent = mainFrame

	-- 4. Дополнительная подсказка
	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "HintLabel"
	hintLabel.Text = "(Без этого вы не сможете использовать читы команды Pidromania Airlinies)"
	hintLabel.Size = UDim2.new(1, 0, 0.1, 0)
	hintLabel.Position = UDim2.new(0, 0, 0.8, 0)
	hintLabel.BackgroundTransparency = 1
	hintLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
	hintLabel.Font = Enum.Font.Gotham
	hintLabel.TextSize = 24
	hintLabel.TextXAlignment = Enum.TextXAlignment.Center
	hintLabel.TextYAlignment = Enum.TextYAlignment.Center
	hintLabel.ZIndex = 201
	hintLabel.Parent = mainFrame

	-- ==============================================================================
	-- === КРУГОВОЙ ТАЙМЕР В ПРАВОМ НИЖНЕМ УГЛУ ===
	-- ==============================================================================
	
	-- Контейнер для таймера (правый нижний угол)
	local timerContainer = Instance.new("Frame")
	timerContainer.Size = UDim2.new(0, 100, 0, 100) -- Размер круга
	timerContainer.Position = UDim2.new(1, -120, 1, -120) -- Правый нижний угол с отступом
	timerContainer.BackgroundTransparency = 1
	timerContainer.ZIndex = 300
	timerContainer.Parent = mainFrame

	-- Фоновый круг (серый, неподвижный)
	local bgCircle = Instance.new("ImageLabel")
	bgCircle.Size = UDim2.new(1, 0, 1, 0)
	bgCircle.BackgroundTransparency = 1
	bgCircle.Image = "rbxassetid://4897627777" -- ID белого круга
	bgCircle.ImageColor3 = Color3.fromRGB(60, 60, 70)
	bgCircle.ZIndex = 301
	bgCircle.Parent = timerContainer

	-- Прогресс-круг (исчезающий по часовой стрелке)
	local progressCircle = Instance.new("ImageLabel")
	progressCircle.Size = UDim2.new(1, 0, 1, 0)
	progressCircle.BackgroundTransparency = 1
	progressCircle.Image = "rbxassetid://4897627777" -- Тот же круг
	progressCircle.ImageColor3 = Color3.fromRGB(100, 200, 255) -- Голубой, как Telegram
	progressCircle.ZIndex = 302
	progressCircle.Parent = timerContainer

	-- Цифры внутри круга
	local timerText = Instance.new("TextLabel")
	timerText.Size = UDim2.new(1, 0, 1, 0)
	timerText.BackgroundTransparency = 1
	timerText.Text = "10"
	timerText.Font = Enum.Font.GothamBold
	timerText.TextSize = 32
	timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerText.TextXAlignment = Enum.TextXAlignment.Center
	timerText.TextYAlignment = Enum.TextYAlignment.Center
	timerText.ZIndex = 303
	timerText.Parent = timerContainer

	-- Логика таймера
	task.spawn(function()
		for i = 10, 0, -1 do
			timerText.Text = tostring(i)
			
			-- Анимируем исчезновение круга через поворот (эффект "стирания" справа налево)
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local rotationGoal = { Rotation = -360 * ((10 - i) / 10) }
			
			TweenService:Create(progressCircle, tweenInfo, rotationGoal):Play()
			
			task.wait(1)
		end
		
		-- После окончания таймера — плавное исчезновение всего окна
		local finalTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		TweenService:Create(mainFrame, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(centerLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(messageLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(telegramLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(hintLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(timerContainer, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
		
		task.wait(0.5)
		screenGuiWhitelist:Destroy()
	end)
end

createWhitelistGUI()
