local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- ==============================================================================
-- === GUI BUILDING ===
-- ==============================================================================
local screenGuiMain = nil

-- Список советов, которые будут меняться
local tips = {
	"Проверяем наличие скрипта...",
	"Ломаем систему безопасности...",
	"Ебём админов...",
	"Почти готово..."
}

local function rebuildGUI()
	if screenGuiMain then
		screenGuiMain:Destroy()
	end

	screenGuiMain = Instance.new("ScreenGui")
	screenGuiMain.Name = "PidromaniaHub_Loader"
	screenGuiMain.ResetOnSpawn = false
	screenGuiMain.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGuiMain.DisplayOrder = 10000 
	screenGuiMain.IgnoreGuiInset = true 
	screenGuiMain.Parent = player:WaitForChild("PlayerGui")

	-- Блокер ввода (прозрачный слой на весь экран)
	local blocker = Instance.new("Frame")
	blocker.Size = UDim2.new(1, 0, 1, 0)
	blocker.BackgroundTransparency = 1
	blocker.ZIndex = 100
	blocker.Parent = screenGuiMain

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 1200, 0, 750)
	mainFrame.Position = UDim2.new(0.5, -600, 0.5, -346)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.ZIndex = 200
	mainFrame.Parent = screenGuiMain

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

	-- 2. Текст "Загрузка" (сдвинут левее центра)
	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "LoadingText"
	loadingText.Text = "Загрузка"
	loadingText.Size = UDim2.new(0, 200, 0, 50)
	
	-- Позиция: Центр экрана (0.5) минус смещение влево (-140).
	-- Правый край этого блока будет на отметке: -140 + 200 = +60 от центра.
	loadingText.Position = UDim2.new(0.5, -140, 0.45, 0) 
	
	loadingText.BackgroundTransparency = 1
	loadingText.TextColor3 = Color3.fromRGB(180, 180, 200)
	loadingText.Font = Enum.Font.Gotham
	loadingText.TextSize = 36
	-- Прижимаем текст вправо внутри блока, чтобы он "лип" к точкам
	loadingText.TextXAlignment = Enum.TextXAlignment.Right 
	loadingText.TextYAlignment = Enum.TextYAlignment.Center
	loadingText.ZIndex = 201
	loadingText.Parent = mainFrame

	-- 3. Точки "..." (стоят вплотную к слову)
	local dotsText = Instance.new("TextLabel")
	dotsText.Name = "DotsText"
	dotsText.Text = "..."
	dotsText.Size = UDim2.new(0, 60, 0, 50) -- Ширина блока под точки
	
	-- Позиция: Начинается ровно там, где закончился предыдущий блок (+60 от центра).
	dotsText.Position = UDim2.new(0.5, 60, 0.45, 0) 
	
	dotsText.BackgroundTransparency = 1
	dotsText.TextColor3 = Color3.fromRGB(180, 180, 200)
	dotsText.Font = Enum.Font.Gotham
	dotsText.TextSize = 36
	-- Прижимаем текст влево внутри блока
	dotsText.TextXAlignment = Enum.TextXAlignment.Left 
	dotsText.TextYAlignment = Enum.TextYAlignment.Center
	dotsText.ZIndex = 201
	dotsText.Parent = mainFrame

	-- 4. Советы (по центру внизу)
	local tipLabel = Instance.new("TextLabel")
	tipLabel.Name = "TipLabel"
	tipLabel.Text = "Подготовка..."
	tipLabel.Size = UDim2.new(1, 0, 0.2, 0)
	tipLabel.Position = UDim2.new(0, 0, 0.65, 0)
	tipLabel.BackgroundTransparency = 1
	tipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	tipLabel.Font = Enum.Font.GothamBold
	tipLabel.TextSize = 32
	tipLabel.TextXAlignment = Enum.TextXAlignment.Center
	tipLabel.TextYAlignment = Enum.TextYAlignment.Center
	tipLabel.ZIndex = 201
	tipLabel.Parent = mainFrame

	-- ==============================================================================
	-- === SKIP BUTTON ===
	-- ==============================================================================
	local skipButton = Instance.new("TextButton")
	skipButton.Name = "SkipButton"
	skipButton.Text = "Skip"
	skipButton.Size = UDim2.new(0, 100, 0, 40)
	skipButton.Position = UDim2.new(1, -120, 1, -60) -- Правый нижний угол
	skipButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	skipButton.BorderSizePixel = 0
	skipButton.TextColor3 = Color3.fromRGB(200, 200, 255)
	skipButton.Font = Enum.Font.GothamBold
	skipButton.TextSize = 24
	skipButton.ZIndex = 201
	skipButton.Parent = mainFrame

	local skipCorner = Instance.new("UICorner")
	skipCorner.CornerRadius = UDim.new(0, 8)
	skipCorner.Parent = skipButton

	-- Эффект при наведении
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
		if not screenGuiMain then return end

		-- Запускаем ту же финальную анимацию, что и в конце цикла
		local finalTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

		TweenService:Create(mainFrame, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(centerLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(loadingText, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(dotsText, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(tipLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
		TweenService:Create(blocker, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
		TweenService:Create(skipButton, finalTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

		task.wait(0.5)
		screenGuiMain:Destroy()
	end)

	-- Логика анимации
	task.spawn(function()
		-- 1. Анимация точек (пульсация)
		task.spawn(function()
			while dotsText.Parent do
				local tweenIn = TweenService:Create(dotsText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0 })
				local tweenOut = TweenService:Create(dotsText, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.8 })
				
				tweenIn:Play()
				tweenIn.Completed:Wait()
				if not dotsText.Parent then break end
				tweenOut:Play()
				tweenOut.Completed:Wait()
			end
		end)

		-- 2. Смена советов
		for i, tip in ipairs(tips) do
			if not tipLabel.Parent then break end
			
			tipLabel.TextTransparency = 1
			tipLabel.Text = tip
			
			local fadeIn = TweenService:Create(tipLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
			fadeIn:Play()
			fadeIn.Completed:Wait()
			
			task.wait(1.5)
			
			if tipLabel.Parent then
				local fadeOut = TweenService:Create(tipLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 })
				fadeOut:Play()
				fadeOut.Completed:Wait()
			end
		end

		-- 3. Финальное исчезновение всего UI (если не был пропущен)
		if screenGuiMain and screenGuiMain.Parent then
			local finalTweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			
			TweenService:Create(mainFrame, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(centerLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(loadingText, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(dotsText, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(tipLabel, finalTweenInfo, { TextTransparency = 1 }):Play()
			TweenService:Create(blocker, finalTweenInfo, { BackgroundTransparency = 1 }):Play()
			TweenService:Create(skipButton, finalTweenInfo, { BackgroundTransparency = 1, TextTransparency = 1 }):Play()

			task.wait(0.5)
			screenGuiMain:Destroy()
		end
	end)
end

rebuildGUI()
