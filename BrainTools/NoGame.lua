local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ==============================================================================
-- === GUI BUILDING: NO CHEAT MESSAGE + TIMER (LEFT) + SKIP (RIGHT) ===
-- ==============================================================================
local screenGuiNoCheat = nil

local function createNoCheatGUI()
	if screenGuiNoCheat then
		screenGuiNoCheat:Destroy()
	end

	screenGuiNoCheat = Instance.new("ScreenGui")
	screenGuiNoCheat.Name = "PidromaniaHub_NoCheat"
	screenGuiNoCheat.ResetOnSpawn = false
	screenGuiNoCheat.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGuiNoCheat.DisplayOrder = 10000
	screenGuiNoCheat.IgnoreGuiInset = true 
	screenGuiNoCheat.Parent = player:WaitForChild("PlayerGui")

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 1200, 0, 750)
	mainFrame.Position = UDim2.new(0.5, -600, 0.5, -346)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.ZIndex = 200
	mainFrame.Parent = screenGuiNoCheat

	local mainFrameCorner = Instance.new("UICorner")
	mainFrameCorner.CornerRadius = UDim.new(0, 15)
	mainFrameCorner.Parent = mainFrame

	-- 1. Заголовок
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

	-- 2. Сообщение об отсутствии чита
	local messageLabel = Instance.new("TextLabel")
	messageLabel.Name = "MessageLabel"
	messageLabel.Text = "Для этой игры пока что нет чита"
	messageLabel.Size = UDim2.new(1, 0, 0.2, 0)
	messageLabel.Position = UDim2.new(0, 0, 0.45, 0)
	messageLabel.BackgroundTransparency = 1
	messageLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
	messageLabel.Font = Enum.Font.GothamBold
	messageLabel.TextSize = 36
	messageLabel.TextXAlignment = Enum.TextXAlignment.Center
	messageLabel.TextYAlignment = Enum.TextYAlignment.Center
	messageLabel.ZIndex = 201
	messageLabel.Parent = mainFrame

	-- 3. Telegram
	local telegramLabel = Instance.new("TextLabel")
	telegramLabel.Name = "TelegramLabel"
	telegramLabel.Text = "Напишите мне в Telegram: @Pidromania"
	telegramLabel.Size = UDim2.new(1, 0, 0.2, 0)
	telegramLabel.Position = UDim2.new(0, 0, 0.65, 0)
	telegramLabel.BackgroundTransparency = 1
	telegramLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	telegramLabel.Font = Enum.Font.GothamBold
	telegramLabel.TextSize = 32
	telegramLabel.TextXAlignment = Enum.TextXAlignment.Center
	telegramLabel.TextYAlignment = Enum.TextYAlignment.Center
	telegramLabel.ZIndex = 201
	telegramLabel.Parent = mainFrame

	-- 4. Подсказка
	local hintLabel = Instance.new("TextLabel")
	hintLabel.Name = "HintLabel"
	hintLabel.Text = "(Я сделаю чит по вашему запросу)"
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
	-- === SKIP BUTTON (ПРАВЫЙ НИЖНИЙ УГОЛ) ===
	-- ==============================================================================
	local skipButton = Instance.new("TextButton")
	skipButton.Name = "SkipButton"
	skipButton.Text = "Skip"
	skipButton.Size = UDim2.new(0, 100, 0, 40)
	-- Позиция: Правый нижний угол
	skipButton.Position = UDim2.new(1, -120, 1, -60) 
	skipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	skipButton.BorderSizePixel = 0
	skipButton.TextColor3 = Color3.fromRGB(200, 200, 255)
	skipButton.Font = Enum.Font.GothamBold
	skipButton.TextSize = 24
	skipButton.ZIndex = 305
	skipButton.Parent = mainFrame

	local skipCorner = Instance.new("UICorner")
	skipCorner.CornerRadius = UDim.new(0, 8)
	skipCorner.Parent = skipButton

	-- Эффекты кнопки
	skipButton.MouseEnter:Connect(function()
		if skipButton.Parent then
			TweenService:Create(skipButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(70, 70, 90) }):Play()
		end
	end)

	skipButton.MouseLeave:Connect(function()
		if skipButton.Parent then
			TweenService:Create(skipButton, TweenInfo.new(0.2), { BackgroundColor3 = Color3.fromRGB(50, 50, 60) }):Play()
		end
	end)

	-- Логика пропуска
	skipButton.MouseButton1Click:Connect(function()
		if not screenGuiNoCheat then return end

		-- Мгновенное скрытие
		local finalTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
		
		TweenService:Create(mainFrame, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(centerLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(messageLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(telegramLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(hintLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(skipButton, finalTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
		
		task.wait(0.3)
		screenGuiNoCheat:Destroy()
	end)


	-- ==============================================================================
	-- === КРУГОВОЙ ТАЙМЕР (ЛЕВЫЙ НИЖНИЙ УГОЛ) ===
	-- ==============================================================================
	
	-- Контейнер для таймера
	local timerContainer = Instance.new("Frame")
	timerContainer.Size = UDim2.new(0, 100, 0, 100) -- Размер круга
	-- Позиция: Левый нижний угол (Отступ 20 слева, 120 снизу)
	timerContainer.Position = UDim2.new(0, 20, 1, -120) 
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
	progressCircle.ImageColor3 = Color3.fromRGB(100, 200, 255) -- Голубой
	progressCircle.ZIndex = 302
	progressCircle.Parent = timerContainer

	-- Цифры внутри круга
	local timerText = Instance.new("TextLabel")
	timerText.Size = UDim2.new(1, 0, 1, 0)
	timerText.BackgroundTransparency = 1
	timerText.Text = "4"
	timerText.Font = Enum.Font.GothamBold
	timerText.TextSize = 32
	timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerText.TextXAlignment = Enum.TextXAlignment.Center
	timerText.TextYAlignment = Enum.TextYAlignment.Center
	timerText.ZIndex = 303
	timerText.Parent = timerContainer

	-- Логика таймера
	task.spawn(function()
		for i = 4, 0, -1 do
			if not screenGuiNoCheat or not screenGuiNoCheat.Parent then break end 
			
			timerText.Text = tostring(i)
			
			local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			local rotationGoal = { Rotation = -360 * ((10 - i) / 10) }
			
			TweenService:Create(progressCircle, tweenInfo, rotationGoal):Play()
			
			task.wait(1)
		end
		
		-- После окончания таймера скрываем всё окно
		if screenGuiNoCheat and screenGuiNoCheat.Parent then
			local finalTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			TweenService:Create(mainFrame, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(centerLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(messageLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(telegramLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(hintLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(timerContainer, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(skipButton, finalTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()
			
			task.wait(0.5)
			screenGuiNoCheat:Destroy()
		end
	end)
end

createNoCheatGUI()
