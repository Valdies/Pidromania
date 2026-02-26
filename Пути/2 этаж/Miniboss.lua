local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Миник_ВторойЭтаж"
local lineColor = Color3.new(1, 0, 0)
local pointColor = Color3.new(0, 1, 0)
local dynamicLineColor = Color3.new(0, 0.5, 1)
local lineWidth = 0.2
local pointSize = 0.8
local activationRadius = 10

local pathFolder = Workspace:FindFirstChild(folderName)
if pathFolder then
    pathFolder:Destroy()
end
pathFolder = Instance.new("Folder")
pathFolder.Name = folderName
pathFolder.Parent = Workspace

local points = {
    Vector3.new(-628.47, -297.93, -470.80),
    Vector3.new(-648.83, -297.93, -470.86),
    Vector3.new(-668.17, -297.93, -470.83),
    Vector3.new(-687.50, -297.83, -470.55),
    Vector3.new(-684.96, -297.86, -450.36),
    Vector3.new(-690.23, -297.90, -430.21),
    Vector3.new(-705.92, -297.89, -430.67),
    Vector3.new(-749.24, -297.78, -431.57),
    Vector3.new(-786.57, -297.82, -432.23),
    Vector3.new(-824.31, -297.80, -431.36),
    Vector3.new(-866.98, -297.83, -431.12),
    Vector3.new(-888.61, -297.87, -431.00),
    Vector3.new(-889.92, -297.90, -488.20),
    Vector3.new(-890.01, -297.93, -549.39),
    Vector3.new(-938.96, -297.76, -552.54),
    Vector3.new(-984.95, -298.10, -552.32),
    Vector3.new(-1031.60, -298.09, -553.27),
    Vector3.new(-1072.26, -298.09, -553.97),
    Vector3.new(-1122.63, -297.09, -553.70),
    Vector3.new(-1155.95, -287.00, -553.51),
    Vector3.new(-1172.09, -287.00, -530.13),
    Vector3.new(-1215.07, -287.00, -512.20),
    Vector3.new(-1233.34, -287.00, -507.72),
    Vector3.new(34.62, -311.67, 932.11),
    Vector3.new(26.20, -311.67, 933.75),
    Vector3.new(5.40, -311.67, 932.88),
    Vector3.new(-22.67, -311.67, 926.87),
    Vector3.new(-46.95, -315.19, 927.13),
    Vector3.new(-70.47, -322.62, 927.97),
    Vector3.new(-101.59, -322.57, 931.03),
    Vector3.new(-129.08, -322.69, 936.28),
    Vector3.new(-159.11, -322.86, 942.52),
    Vector3.new(-185.57, -323.03, 949.24),
    Vector3.new(-215.34, -322.65, 958.99),
    Vector3.new(-234.65, -322.46, 970.59),
    Vector3.new(-261.84, -322.40, 975.28),
    Vector3.new(-296.96, -322.47, 975.84),
    Vector3.new(-305.91, -322.56, 976.28),
    Vector3.new(-306.28, -322.50, 956.09),
    Vector3.new(-305.37, -322.50, 917.44),
    Vector3.new(-305.68, -322.54, 882.12),
    Vector3.new(-306.27, -322.50, 856.49),
    Vector3.new(-336.91, -322.41, 859.09),
    Vector3.new(-372.87, -322.47, 858.16),
    Vector3.new(-410.86, -322.48, 859.04),
    Vector3.new(-448.19, -322.41, 859.27),
    Vector3.new(-485.52, -322.56, 859.47),
    Vector3.new(-508.48, -322.55, 859.60),
    Vector3.new(-509.98, -322.49, 880.88),
    Vector3.new(-510.43, -322.54, 903.09),
    Vector3.new(-529.18, -322.56, 901.00),
    Vector3.new(-566.57, -322.56, 898.21)
}

local cleanupTable = {}
local activePoints = {}

local dynamicLinePart = Instance.new("Part")
dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, 0)
dynamicLinePart.Anchored = true
dynamicLinePart.CanCollide = false
dynamicLinePart.Color = dynamicLineColor
dynamicLinePart.Material = Enum.Material.Neon
dynamicLinePart.Name = "DynamicLine_PlayerToTarget"
dynamicLinePart.Parent = pathFolder

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

    local light = Instance.new("PointLight")
    light.Color = pointColor
    light.Brightness = 2
    light.Range = 10
    light.Parent = pointPart

    local partsToDelete = {pointPart, light}

    activePoints[index] = {
        pos = pos,
        label = labelText,
        part = pointPart
    }

    return partsToDelete
end

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

    local pointParts = createPoint(pos, pointLabel, currentIndex)
    for _, p in ipairs(pointParts) do
        table.insert(cleanupTable[currentIndex], p)
    end

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

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local playerPos = rootPart.Position
    local closestDist = math.huge
    local targetPos = nil
    local targetIndex = nil

    for idx, data in pairs(activePoints) do
        if data.part and data.part.Parent then
            local dist = (data.pos - playerPos).Magnitude
            
            if dist < closestDist then
                closestDist = dist
                targetPos = data.pos
                targetIndex = idx
            end

            if dist <= activationRadius then
                activePoints[idx] = nil
                
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
                    dynamicLinePart.Transparency = 1
                end
                
                break 
            end
        end
    end

    if targetPos and activePoints[targetIndex] then
        dynamicLinePart.Transparency = 0
        local distance = (targetPos - playerPos).Magnitude
        
        dynamicLinePart.Size = Vector3.new(lineWidth, lineWidth, distance)
        dynamicLinePart.CFrame = CFrame.lookAt(playerPos, targetPos) * CFrame.new(0, 0, -distance / 2)
    else
        dynamicLinePart.Transparency = 1
    end
end)