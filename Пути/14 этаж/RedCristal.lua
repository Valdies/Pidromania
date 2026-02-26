local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local folderName = "Пути_RedCrystal"
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
    Vector3.new(5161.21, 1773.77, 2901.12),
    Vector3.new(5069.72, 1808.62, 2974.80),
    Vector3.new(5001.01, 1823.51, 2985.64),
    Vector3.new(4977.25, 1837.17, 2995.09),
    Vector3.new(4958.51, 1836.84, 3004.43),
    Vector3.new(4937.34, 1839.21, 3015.32),
    Vector3.new(4915.13, 1842.65, 3029.30),
    Vector3.new(4894.12, 1855.77, 3043.47),
    Vector3.new(4869.11, 1858.38, 3059.74),
    Vector3.new(4843.83, 1848.75, 3077.28),
    Vector3.new(4825.01, 1832.70, 3096.43),
    Vector3.new(4816.29, 1833.73, 3107.70),
    Vector3.new(4807.22, 1837.01, 3133.25),
    Vector3.new(4799.11, 1835.82, 3154.92),
    Vector3.new(4791.52, 1831.81, 3167.42),
    Vector3.new(4783.14, 1824.70, 3176.10),
    Vector3.new(4773.77, 1814.15, 3185.30),
    Vector3.new(4762.91, 1806.87, 3196.53),
    Vector3.new(4752.29, 1799.66, 3208.15),
    Vector3.new(4744.71, 1788.83, 3221.35),
    Vector3.new(4741.63, 1774.55, 3234.23),
    Vector3.new(4736.21, 1759.88, 3245.74),
    Vector3.new(4733.28, 1756.33, 3260.85),
    Vector3.new(4731.49, 1753.14, 3271.52),
    Vector3.new(4729.25, 1750.56, 3283.58),
    Vector3.new(4726.00, 1747.08, 3301.09),
    Vector3.new(4722.33, 1744.29, 3320.41),
    Vector3.new(4717.78, 1740.97, 3340.16),
    Vector3.new(4706.27, 1741.85, 3378.77),
    Vector3.new(4703.03, 1735.45, 3389.59),
    Vector3.new(4699.92, 1734.21, 3408.52),
    Vector3.new(4695.05, 1733.89, 3427.79),
    Vector3.new(4691.47, 1733.86, 3444.61),
    Vector3.new(4688.32, 1734.67, 3459.42),
    Vector3.new(4684.75, 1738.08, 3476.16),
    Vector3.new(4680.29, 1737.77, 3497.14),
    Vector3.new(4678.26, 1738.34, 3514.68),
    Vector3.new(4675.79, 1740.75, 3534.23),
    Vector3.new(4673.21, 1743.64, 3551.47),
    Vector3.new(4670.39, 1746.84, 3570.24),
    Vector3.new(4667.68, 1749.74, 3586.03),
    Vector3.new(4664.76, 1754.16, 3606.54),
    Vector3.new(4661.25, 1762.10, 3639.68),
    Vector3.new(4657.33, 1770.54, 3667.34),
    Vector3.new(4655.19, 1776.33, 3684.34),
    Vector3.new(4653.93, 1782.79, 3701.61),
    Vector3.new(4648.62, 1789.62, 3719.63),
    Vector3.new(4641.60, 1796.25, 3735.05),
    Vector3.new(4634.23, 1807.42, 3758.99),
    Vector3.new(4632.64, 1816.24, 3775.72),
    Vector3.new(4627.18, 1830.99, 3804.99),
    Vector3.new(4623.53, 1839.74, 3819.03),
    Vector3.new(4621.81, 1849.03, 3834.59),
    Vector3.new(4621.85, 1860.01, 3851.53),
    Vector3.new(4620.34, 1870.36, 3867.29),
    Vector3.new(4618.81, 1881.60, 3883.08),
    Vector3.new(4616.45, 1893.70, 3899.36),
    Vector3.new(4612.44, 1907.81, 3915.50),
    Vector3.new(4609.03, 1922.83, 3928.07),
    Vector3.new(4601.58, 1932.16, 3947.16),
    Vector3.new(4593.13, 1936.59, 3969.73),
    Vector3.new(4585.22, 1950.75, 3989.41),
    Vector3.new(4576.99, 1959.85, 4011.68),
    Vector3.new(4569.66, 1972.72, 4034.21),
    Vector3.new(4562.64, 1982.85, 4055.75),
    Vector3.new(4558.42, 1988.62, 4071.93),
    Vector3.new(4567.07, 1992.86, 4088.58),
    Vector3.new(4577.53, 2001.30, 4108.71),
    Vector3.new(4575.62, 2024.11, 4134.26),
    Vector3.new(4577.53, 2036.69, 4149.26),
    Vector3.new(4583.64, 2047.31, 4160.85),
    Vector3.new(4590.75, 2052.58, 4174.53),
    Vector3.new(4592.86, 2060.61, 4188.83),
    Vector3.new(4587.12, 2068.75, 4207.04),
    Vector3.new(4581.47, 2077.52, 4224.91),
    Vector3.new(4574.03, 2084.57, 4245.33),
    Vector3.new(4567.96, 2089.33, 4260.31),
    Vector3.new(4561.68, 2096.06, 4276.89),
    Vector3.new(4555.80, 2105.20, 4294.80),
    Vector3.new(4551.92, 2112.47, 4311.21),
    Vector3.new(4547.69, 2119.15, 4317.12),
    Vector3.new(4539.85, 2128.98, 4335.15),
    Vector3.new(4531.38, 2132.63, 4353.63),
    Vector3.new(4522.42, 2137.95, 4371.58),
    Vector3.new(4514.07, 2145.19, 4388.29),
    Vector3.new(4504.96, 2147.95, 4406.55),
    Vector3.new(4491.17, 2148.23, 4426.73)
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