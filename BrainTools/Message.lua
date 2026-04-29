local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local activeNotifications = {}

local function showJoinNotification(player)
	local playerName = player.Name
	if activeNotifications[playerName] then return end
	
	-- Проверка на дружбу (нужен pcall, так как это запрос к API)
	local isFriend = false
	local success, result = pcall(function()
		return Players.LocalPlayer:IsFriendsWith(player.UserId)
	end)
	if success then isFriend = result end

	local notificationGui = Instance.new("ScreenGui")
	notificationGui.Name = "JoinNotify_" .. playerName
	notificationGui.ResetOnSpawn = false
	notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	notificationGui.Parent = game:GetService("CoreGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 480, 0, 110)
	frame.Position = UDim2.new(1, 10, 1, -120) -- Начальная позиция за экраном
	frame.BorderSizePixel = 0
	frame.Parent = notificationGui
	
	-- Дизайн в зависимости от статуса
	if isFriend then
		-- Розово-фиолетовый стиль для друзей
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		local gradient = Instance.new("UIGradient")
		gradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 120, 200)), -- Розовый
			ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 80, 255))   -- Фиолетовый
		})
		gradient.Rotation = 30
		gradient.Parent = frame
	else
		-- Старый темный стиль для обычных челов
		frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	end

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = frame

	local topLabel = Instance.new("TextLabel")
	topLabel.Size = UDim2.new(1, -16, 0, 40)
	topLabel.Position = UDim2.new(0, 8, 0, 8)
	topLabel.BackgroundTransparency = 1
	topLabel.Font = Enum.Font.GothamBold
	topLabel.TextSize = 22
	topLabel.TextXAlignment = Enum.TextXAlignment.Center
	
	-- Текст и цвет заголовка
	if isFriend then
		topLabel.Text = "🌸 Твой друг зашёл! 🌸"
		topLabel.TextColor3 = Color3.fromRGB(180, 240, 255) -- Голубенький
	else
		topLabel.Text = "Игрок зашёл на сервер"
		topLabel.TextColor3 = Color3.fromRGB(180, 180, 220) -- Старый цвет
	end
	topLabel.Parent = frame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -16, 0, 48)
	nameLabel.Position = UDim2.new(0, 8, 0, 54)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = playerName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextSize = 30
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = frame

	activeNotifications[playerName] = true
	
	-- Анимация появления
	local tweenIn = TweenService:Create(
		frame,
		TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Position = UDim2.new(1, -490, 1, -120) }
	)
	tweenIn:Play()

	-- Поток для удаления
	task.spawn(function()
		task.wait(5)
		local tweenOut = TweenService:Create(
			frame,
			TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(1, 10, 1, -120) }
		)
		tweenOut:Play()
		tweenOut.Completed:Wait()
		notificationGui:Destroy()
		activeNotifications[playerName] = nil
	end)
end

Players.PlayerAdded:Connect(function(player)
	if player == Players.LocalPlayer then return end
	-- Ждем немного, чтобы данные о друзьях прогрузились
	task.wait(0.5)
	showJoinNotification(player)
end)
