local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Босс_ВторойЭтаж"
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
    Vector3.new(-639.33, -297.93, -470.55),
    Vector3.new(-684.28, -297.83, -469.52),
    Vector3.new(-684.93, -297.93, -431.60),
    Vector3.new(-728.12, -297.85, -431.04),
    Vector3.new(-784.92, -297.86, -431.28),
    Vector3.new(-855.42, -297.85, -431.50),
    Vector3.new(-890.79, -297.87, -431.36),
    Vector3.new(-889.60, -297.87, -492.21),
    Vector3.new(-890.33, -297.93, -552.86),
    Vector3.new(-924.69, -297.75, -553.73),
    Vector3.new(-978.02, -298.18, -553.66),
    Vector3.new(-1028.03, -298.09, -553.83),
    Vector3.new(-1079.35, -298.18, -553.69),
    Vector3.new(-1125.56, -296.00, -553.93),
    Vector3.new(-1159.86, -287.00, -542.20),
    Vector3.new(-1195.22, -287.00, -518.70),
    Vector3.new(-1231.10, -287.00, -508.80),
    Vector3.new(34.40 , -311.67, 932.60),
    Vector3.new(36.48, -311.67, 912.08),
    Vector3.new(34.69, -316.62, 876.93),
    Vector3.new(33.48, -323.09, 836.65),
    Vector3.new(32.28, -322.87, 798.02),
    Vector3.new(20.06, -322.83, 760.91),
    Vector3.new(-0.77, -322.66, 725.99),
    Vector3.new(-18.75, -322.90, 691.07),
    Vector3.new(-27.83, -322.43, 648.97),
    Vector3.new(-27.00, -322.50, 611.67),
    Vector3.new(-1.43, -322.51, 597.39),
    Vector3.new(40.49, -322.53, 597.56),
    Vector3.new(81.78, -322.54, 597.49),
    Vector3.new(123.69, -322.56, 597.30),
    Vector3.new(163.02, -322.50, 596.86),
    Vector3.new(204.34, -322.55, 596.01),
    Vector3.new(241.67, -322.56, 596.79),
    Vector3.new(261.28, -322.45, 596.58),
    Vector3.new(260.03, -322.41, 571.62),
    Vector3.new(259.80, -322.44, 531.47),
    Vector3.new(259.44, -322.44, 491.82),
    Vector3.new(258.56, -322.41, 453.49),
    Vector3.new(258.78, -322.45, 419.53),
    Vector3.new(260.40, -322.42, 377.21),
    Vector3.new(260.17, -322.56, 350.32),
    Vector3.new(281.50, -322.56, 344.58),
    Vector3.new(301.31, -322.56, 347.20),
    Vector3.new(300.62, -322.41, 372.70),
    Vector3.new(299.97, -322.41, 413.33),
    Vector3.new(301.24, -322.54, 447.21),
    Vector3.new(301.16, -322.56, 450.95),
    Vector3.new(1722.92, -251.54, 134.56),
    Vector3.new(1713.78, -251.54, 119.61),
    Vector3.new(1697.64, -251.54, 85.52),
    Vector3.new(-794.91, -380.27, 946.26),
    Vector3.new(-794.85, -380.32, 929.23),
    Vector3.new(-794.74, -380.29, 890.56),
    Vector3.new(-795.30, -380.31, 853.23),
    Vector3.new(-794.42, -380.31, 813.92),
    Vector3.new(-794.02, -380.32, 772.60),
    Vector3.new(-794.71, -380.32, 727.44),
    Vector3.new(-794.55, -380.29, 683.94),
    Vector3.new(-825.58, -380.14, 676.05),
    Vector3.new(-866.87, -380.18, 677.55),
    Vector3.new(-909.36, -381.05, 678.14),
    Vector3.new(-949.52, -381.02, 677.82),
    Vector3.new(-1002.18, -381.08, 677.26),
    Vector3.new(-1039.39, -374.05, 686.59),
    Vector3.new(-1073.55, -369.87, 700.41),
    Vector3.new(-1113.36, -369.87, 710.85),
    Vector3.new(-1154.88, -369.87, 711.14),
    Vector3.new(-1198.31, -369.87, 700.97),
    Vector3.new(-1235.49, -377.29, 689.46),
    Vector3.new(-1277.16, -381.11, 680.39),
    Vector3.new(-1319.78, -381.01, 678.63),
    Vector3.new(-1359.77, -381.02, 678.81),
    Vector3.new(-1393.06, -381.02, 679.31),
    Vector3.new(-540.97, 1917.21, -727.32),
    Vector3.new(-545.63, 1917.21, -727.13)
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