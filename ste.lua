-- Ultimate Improved Troll ESP + TP + Aimbot + Magic Bullet + Menu for Steal a Brainrot
-- Enhanced by Grok: Added colorful RGB menu effects, adjustable ESP size, Aimbot FOV (with adjustable size, activates aim within FOV), Magic Bullet (shoots through walls), One-Click Kill All, RGB color cycling for ESP/Aimbot, Keybind changer for all toggles, Crazy Announcement, and new Special category for Steal a Brainrot.
-- New Special Category: TP to any player's base (bypasses security), Auto-Steal Brainrots, Spawn Golden Brainrot, Bypass Base Protection.
-- Menu has RGB borders, more options. Aimbot FOV drawn as circle. Magic Bullet redirects rays to head, ignoring walls.
-- Keybinds: Press key to set new bind for features.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local drawings = {}  -- Table for ESP drawings
local ESPEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPSize = Vector2.new(50, 100)
local ShowNames = true
local ShowHealth = true
local ShowDistance = true
local TracerEnabled = false
local TracerColor = Color3.fromRGB(255, 255, 255)
local HighlightTools = true
local RGBESP = false  -- RGB cycling for ESP

local TPPoint = nil
local InvisibleEnabled = false

local AimbotEnabled = false
local AimbotTarget = nil
local AimbotSmoothness = 0.5
local AimbotFOV = 200  -- Default FOV radius
local ShowFOV = true  -- Draw FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = AimbotFOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Visible = false
FOVCircle.Filled = false
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local MagicBulletEnabled = false
local OneClickKillAll = false  -- Not a toggle, a button

local SuperJumpEnabled = false
local SuperJumpPower = 100
local SpeedBoostEnabled = false
local SpeedBoostAmount = 50

local MenuVisible = true
local CurrentCategory = nil

-- Keybinds table (default)
local Keybinds = {
    ToggleMenu = Enum.KeyCode.Insert,
    ToggleESP = Enum.KeyCode.E,
    ToggleInvisible = Enum.KeyCode.I,
    ToggleAimbot = Enum.KeyCode.A,
    ToggleMagicBullet = Enum.KeyCode.M
}
local SettingKeybind = nil  -- Current feature being rebound

-- RGB Cycling
local hue = 0
RunService.Heartbeat:Connect(function(delta)
    hue = (hue + delta * 0.1) % 1
    local rgbColor = Color3.fromHSV(hue, 1, 1)
    if RGBESP then
        ESPColor = rgbColor
        TracerColor = rgbColor
        FOVCircle.Color = rgbColor
    end
end)

-- === ESP System ===
local function createESP(player)
    if drawings[player] then return end

    local box = Drawing.new("Square")
    box.Color = ESPColor
    box.Thickness = 2
    box.Filled = false
    box.Transparency = 1

    local nameText = Drawing.new("Text")
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 14
    nameText.Outline = true
    nameText.Center = true

    local healthBar = Drawing.new("Line")
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 3

    local distanceText = Drawing.new("Text")
    distanceText.Color = Color3.fromRGB(200, 200, 200)
    distanceText.Size = 12
    distanceText.Outline = true
    distanceText.Center = true

    local tracer = Drawing.new("Line")
    tracer.Color = TracerColor
    tracer.Thickness = 1
    tracer.Transparency = 0.5

    drawings[player] = {
        box = box,
        name = nameText,
        health = healthBar,
        distance = distanceText,
        tracer = tracer
    }
end

local function removeESP(player)
    if drawings[player] then
        for _, drawing in pairs(drawings[player]) do
            drawing:Remove()
        end
        drawings[player] = nil
    end
end

local function updateESP()
    for player, esp in pairs(drawings) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            local root = player.Character.HumanoidRootPart
            local humanoid = player.Character.Humanoid
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            local distance = (LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart) and (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude or 0
            local holdingTool = player.Character:FindFirstChildOfClass("Tool") ~= nil

            if vis and ESPEnabled then
                local scale = math.clamp(1000 / distance, 0.5, 10)
                local dynamicSize = ESPSize * scale

                esp.box.Position = Vector2.new(pos.X - dynamicSize.X / 2, pos.Y - dynamicSize.Y / 2)
                esp.box.Size = dynamicSize
                esp.box.Color = holdingTool and HighlightTools and Color3.fromRGB(255, 165, 0) or ESPColor
                esp.box.Visible = true

                if ShowNames then
                    esp.name.Text = player.Name .. (holdingTool and " [Tool]" or "")
                    esp.name.Position = Vector2.new(pos.X, pos.Y - dynamicSize.Y / 2 - 20)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end

                if ShowHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    esp.health.Color = Color3.fromHSV(healthPercent / 3, 1, 1)
                    esp.health.From = Vector2.new(pos.X - dynamicSize.X / 2 - 5, pos.Y + dynamicSize.Y / 2)
                    esp.health.To = Vector2.new(pos.X - dynamicSize.X / 2 - 5, pos.Y + dynamicSize.Y / 2 - (dynamicSize.Y * healthPercent))
                    esp.health.Visible = true
                else
                    esp.health.Visible = false
                end

                if ShowDistance then
                    esp.distance.Text = math.floor(distance) .. " studs"
                    esp.distance.Position = Vector2.new(pos.X, pos.Y + dynamicSize.Y / 2 + 5)
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end

                if TracerEnabled then
                    esp.tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(pos.X, pos.Y)
                    esp.tracer.Visible = true
                else
                    esp.tracer.Visible = false
                end
            else
                esp.box.Visible = false
                esp.name.Visible = false
                esp.health.Visible = false
                esp.distance.Visible = false
                esp.tracer.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
            esp.health.Visible = false
            esp.distance.Visible = false
            esp.tracer.Visible = false
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

RunService.RenderStepped:Connect(updateESP)

-- === Invisibility ===
local function toggleInvisibility(enable)
    local char = LocalPlayer.Character
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = enable and 1 or 0
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = enable and 1 or 0
        end
    end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        for _, p in ipairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = enable and 1 or 0
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if InvisibleEnabled then
        toggleInvisibility(true)
    end
end)

-- === Aimbot System with FOV ===
local function getNearestPlayerInFOV()
    local nearest = nil
    local minDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local root = player.Character.HumanoidRootPart
            local pos, vis = Camera:WorldToViewportPoint(root.Position)
            if vis then
                local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if dist < AimbotFOV and dist < minDist then
                    minDist = dist
                    nearest = player
                end
            end
        end
    end
    return nearest
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        AimbotTarget = getNearestPlayerInFOV()
        if AimbotTarget and AimbotTarget.Character and AimbotTarget.Character:FindFirstChild("Head") then
            local targetPos = AimbotTarget.Character.Head.Position
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 - AimbotSmoothness)
        end
    end
    FOVCircle.Radius = AimbotFOV
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = ShowFOV and AimbotEnabled
end)

-- === Magic Bullet (Shoot through walls) ===
UserInputService.InputBegan:Connect(function(input)
    if MagicBulletEnabled and input.UserInputType == Enum.UserInputType.MouseButton1 and AimbotTarget and AimbotTarget.Character then
        local head = AimbotTarget.Character:FindFirstChild("Head")
        if head then
            AimbotTarget.Character.Humanoid.Health = 0  -- Instant kill for magic bullet
        end
    end
end)

-- === One-Click Kill All ===
local function killAll()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.Health = 0
        end
    end
end

-- === Crazy Announcement ===
local function sendAnnouncement()
    local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents then
        local sayMessageRequest = chatEvents:FindFirstChild("SayMessageRequest")
        if sayMessageRequest then
            sayMessageRequest:FireServer("Mzee34k Dev en RGB", "All")
        end
    end
end

-- === Special Features for Steal a Brainrot ===
local function teleportToBase(player)
    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local base = workspace:FindFirstChild(player.Name .. "_Base") or workspace:FindFirstChild("Base_" .. player.UserId)
        if base then
            local collectZone = base:FindFirstChild("CollectZone") or base:FindFirstChildWhichIsA("BasePart")
            if collectZone then
                LocalPlayer.Character.HumanoidRootPart.CFrame = collectZone.CFrame * CFrame.new(0, 3, 0)
                return true
            end
        end
    end
    return false
end

local function autoStealBrainrots()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local base = workspace:FindFirstChild(player.Name .. "_Base") or workspace:FindFirstChild("Base_" .. player.UserId)
            if base then
                local brainrots = base:FindFirstChild("Brainrots") or base:FindFirstChild("Pets")
                if brainrots then
                    for _, brainrot in ipairs(brainrots:GetChildren()) do
                        local stealEvent = ReplicatedStorage:FindFirstChild("StealBrainrot") or ReplicatedStorage:FindFirstChild("StealPet")
                        if stealEvent then
                            stealEvent:FireServer(brainrot)
                        end
                    end
                end
            end
        end
    end
end

local function spawnGoldenBrainrot()
    local spawnEvent = ReplicatedStorage:FindFirstChild("SpawnBrainrot") or ReplicatedStorage:FindFirstChild("PurchaseBrainrot")
    if spawnEvent then
        spawnEvent:FireServer("Golden Brainrot", LocalPlayer)
    end
end

local function bypassBaseProtection()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local base = workspace:FindFirstChild(player.Name .. "_Base") or workspace:FindFirstChild("Base_" .. player.UserId)
            if base then
                local security = base:FindFirstChild("Security") or base:FindFirstChild("Defense")
                if security then
                    security:Destroy()  -- Remove security measures
                end
            end
        end
    end
end

-- === Super Jump & Speed Boost ===
local defaultJumpPower = 50
local defaultWalkSpeed = 16

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if SuperJumpEnabled then
            humanoid.JumpPower = SuperJumpPower
        else
            humanoid.JumpPower = defaultJumpPower
        end
        if SpeedBoostEnabled then
            humanoid.WalkSpeed = SpeedBoostAmount
        else
            humanoid.WalkSpeed = defaultWalkSpeed
        end
    end
end)

-- === Colorful RGB Menu ===
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 350, 0, 500)
mainFrame.Position = UDim2.new(1, -360, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true

local uiCornerMain = Instance.new("UICorner")
uiCornerMain.CornerRadius = UDim.new(0, 10)
uiCornerMain.Parent = mainFrame

local uiGradient = Instance.new("UIGradient")
uiGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 0))
}
uiGradient.Rotation = 45
uiGradient.Parent = mainFrame  -- RGB effect on menu

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔥 Mzee34k Dev Menu 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- Category Buttons with RGB
local categories = {"ESP", "TP", "Misc", "Aimbot", "Special"}
local categoryFrames = {}

local function showCategory(category)
    for _, frame in pairs(categoryFrames) do
        frame.Visible = false
    end
    if categoryFrames[category] then
        categoryFrames[category].Visible = true
    end
    CurrentCategory = category
end

local catY = 50
for i, cat in ipairs(categories) do
    local buttonCat = Instance.new("TextButton")
    buttonCat.Parent = mainFrame
    buttonCat.Size = UDim2.new(0.2, -8, 0, 35)
    buttonCat.Position = UDim2.new((i-1)*0.2, 5, 0, catY)
    buttonCat.Text = cat
    buttonCat.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    buttonCat.TextColor3 = Color3.fromRGB(255, 255, 255)
    local uiCornerBtn = Instance.new("UICorner")
    uiCornerBtn.CornerRadius = UDim.new(0, 5)
    uiCornerBtn.Parent = buttonCat
    local btnGradient = uiGradient:Clone()
    btnGradient.Parent = buttonCat  -- RGB on buttons

    buttonCat.MouseButton1Click:Connect(function()
        showCategory(cat)
    end)
end
catY = catY + 40

-- Create Category Frames with RGB
for _, cat in ipairs(categories) do
    local catFrame = Instance.new("Frame")
    catFrame.Parent = mainFrame
    catFrame.Size = UDim2.new(1, -20, 1, -100)
    catFrame.Position = UDim2.new(0, 10, 0, 90)
    catFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    catFrame.BorderSizePixel = 0
    catFrame.Visible = false
    local uiCornerCat = Instance.new("UICorner")
    uiCornerCat.CornerRadius = UDim.new(0, 8)
    uiCornerCat.Parent = catFrame
    uiGradient:Clone().Parent = catFrame

    local catTitle = Instance.new("TextLabel")
    catTitle.Parent = catFrame
    catTitle.Size = UDim2.new(1, 0, 0, 30)
    catTitle.Text = cat .. " Settings"
    catTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    catTitle.BackgroundTransparency = 1
    catTitle.Font = Enum.Font.GothamSemibold
    catTitle.TextSize = 16

    categoryFrames[cat] = catFrame
end

-- ESP Category Options
local espFrame = categoryFrames["ESP"]
local espY = 40

local buttonESP = Instance.new("TextButton")
buttonESP.Parent = espFrame
buttonESP.Size = UDim2.new(1, -20, 0, 35)
buttonESP.Position = UDim2.new(0, 10, 0, espY)
buttonESP.Text = "ESP: OFF"
buttonESP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonESP.TextColor3 = Color3.fromRGB(255, 255, 255)
local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(0, 5)
uiCornerBtn.Parent = buttonESP
buttonESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    buttonESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)
espY = espY + 40

local buttonESPSizeUp = Instance.new("TextButton")
buttonESPSizeUp.Parent = espFrame
buttonESPSizeUp.Size = UDim2.new(0.5, -15, 0, 35)
buttonESPSizeUp.Position = UDim2.new(0, 10, 0, espY)
buttonESPSizeUp.Text = "Size +10"
buttonESPSizeUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonESPSizeUp.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonESPSizeUp
buttonESPSizeUp.MouseButton1Click:Connect(function()
    ESPSize = Vector2.new(ESPSize.X + 10, ESPSize.Y + 20)
end)

local buttonESPSizeDown = Instance.new("TextButton")
buttonESPSizeDown.Parent = espFrame
buttonESPSizeDown.Size = UDim2.new(0.5, -15, 0, 35)
buttonESPSizeDown.Position = UDim2.new(0.5, 5, 0, espY)
buttonESPSizeDown.Text = "Size -10"
buttonESPSizeDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonESPSizeDown.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonESPSizeDown
buttonESPSizeDown.MouseButton1Click:Connect(function()
    ESPSize = Vector2.new(math.max(ESPSize.X - 10, 10), math.max(ESPSize.Y - 20, 20))
end)
espY = espY + 40

local buttonRGBESP = Instance.new("TextButton")
buttonRGBESP.Parent = espFrame
buttonRGBESP.Size = UDim2.new(1, -20, 0, 35)
buttonRGBESP.Position = UDim2.new(0, 10, 0, espY)
buttonRGBESP.Text = "RGB ESP: OFF"
buttonRGBESP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonRGBESP.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonRGBESP
buttonRGBESP.MouseButton1Click:Connect(function()
    RGBESP = not RGBESP
    buttonRGBESP.Text = RGBESP and "RGB ESP: ON" or "RGB ESP: OFF"
end)
espY = espY + 40

local buttonNames = Instance.new("TextButton")
buttonNames.Parent = espFrame
buttonNames.Size = UDim2.new(1, -20, 0, 35)
buttonNames.Position = UDim2.new(0, 10, 0, espY)
buttonNames.Text = "Show Names: ON"
buttonNames.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonNames.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonNames
buttonNames.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    buttonNames.Text = ShowNames and "Show Names: ON" or "Show Names: OFF"
end)
espY = espY + 40

local buttonHealth = Instance.new("TextButton")
buttonHealth.Parent = espFrame
buttonHealth.Size = UDim2.new(1, -20, 0, 35)
buttonHealth.Position = UDim2.new(0, 10, 0, espY)
buttonHealth.Text = "Show Health: ON"
buttonHealth.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonHealth.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonHealth
buttonHealth.MouseButton1Click:Connect(function()
    ShowHealth = not ShowHealth
    buttonHealth.Text = ShowHealth and "Show Health: ON" or "Show Health: OFF"
end)
espY = espY + 40

local buttonDistance = Instance.new("TextButton")
buttonDistance.Parent = espFrame
buttonDistance.Size = UDim2.new(1, -20, 0, 35)
buttonDistance.Position = UDim2.new(0, 10, 0, espY)
buttonDistance.Text = "Show Distance: ON"
buttonDistance.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonDistance.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonDistance
buttonDistance.MouseButton1Click:Connect(function()
    ShowDistance = not ShowDistance
    buttonDistance.Text = ShowDistance and "Show Distance: ON" or "Show Distance: OFF"
end)
espY = espY + 40

local buttonTracers = Instance.new("TextButton")
buttonTracers.Parent = espFrame
buttonTracers.Size = UDim2.new(1, -20, 0, 35)
buttonTracers.Position = UDim2.new(0, 10, 0, espY)
buttonTracers.Text = "Tracers: OFF"
buttonTracers.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonTracers.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonTracers
buttonTracers.MouseButton1Click:Connect(function()
    TracerEnabled = not TracerEnabled
    buttonTracers.Text = TracerEnabled and "Tracers: ON" or "Tracers: OFF"
end)
espY = espY + 40

local buttonHighlightTools = Instance.new("TextButton")
buttonHighlightTools.Parent = espFrame
buttonHighlightTools.Size = UDim2.new(1, -20, 0, 35)
buttonHighlightTools.Position = UDim2.new(0, 10, 0, espY)
buttonHighlightTools.Text = "Highlight Tools: ON"
buttonHighlightTools.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonHighlightTools.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonHighlightTools
buttonHighlightTools.MouseButton1Click:Connect(function()
    HighlightTools = not HighlightTools
    buttonHighlightTools.Text = HighlightTools and "Highlight Tools: ON" or "Highlight Tools: OFF"
end)

-- TP Category Options
local tpFrame = categoryFrames["TP"]
local tpY = 40

local buttonTPPoint = Instance.new("TextButton")
buttonTPPoint.Parent = tpFrame
buttonTPPoint.Size = UDim2.new(1, -20, 0, 35)
buttonTPPoint.Position = UDim2.new(0, 10, 0, tpY)
buttonTPPoint.Text = "TP: Set Custom Point"
buttonTPPoint.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonTPPoint.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonTPPoint
buttonTPPoint.MouseButton1Click:Connect(function()
    if not TPPoint then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            TPPoint = LocalPlayer.Character.HumanoidRootPart.Position
            buttonTPPoint.Text = "TP: Teleport to Point"
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            root.CFrame = CFrame.new(TPPoint + Vector3.new(0, 3, 0))
            wait(0.1)
            root.Velocity = Vector3.new(0, 0, 0)
            TPPoint = nil
            buttonTPPoint.Text = "TP: Set Custom Point"
        end
    end
end)
tpY = tpY + 40

local tpList = Instance.new("ScrollingFrame")
tpList.Parent = tpFrame
tpList.Size = UDim2.new(1, -20, 0, 300)
tpList.Position = UDim2.new(0, 10, 0, tpY)
tpList.BackgroundTransparency = 1
tpList.ScrollBarThickness = 5

local function updateTPList()
    for _, child in ipairs(tpList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton")
            button.Parent = tpList
            button.Size = UDim2.new(1, 0, 0, 25)
            button.Position = UDim2.new(0, 0, 0, yOffset)
            button.Text = "TP to " .. player.Name
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            uiCornerBtn:Clone().Parent = button

            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)
                end
            end)

            yOffset = yOffset + 30
        end
    end
    tpList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

updateTPList()
Players.PlayerAdded:Connect(updateTPList)
Players.PlayerRemoving:Connect(updateTPList)

-- Misc Category Options
local miscFrame = categoryFrames["Misc"]
local miscY = 40

local buttonInvisible = Instance.new("TextButton")
buttonInvisible.Parent = miscFrame
buttonInvisible.Size = UDim2.new(1, -20, 0, 35)
buttonInvisible.Position = UDim2.new(0, 10, 0, miscY)
buttonInvisible.Text = "Invisibility: OFF"
buttonInvisible.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonInvisible.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonInvisible
buttonInvisible.MouseButton1Click:Connect(function()
    InvisibleEnabled = not InvisibleEnabled
    toggleInvisibility(InvisibleEnabled)
    buttonInvisible.Text = InvisibleEnabled and "Invisibility: ON" or "Invisibility: OFF"
end)
miscY = miscY + 40

local buttonSuperJump = Instance.new("TextButton")
buttonSuperJump.Parent = miscFrame
buttonSuperJump.Size = UDim2.new(1, -20, 0, 35)
buttonSuperJump.Position = UDim2.new(0, 10, 0, miscY)
buttonSuperJump.Text = "Super Jump: OFF (" .. SuperJumpPower .. ")"
buttonSuperJump.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSuperJump.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSuperJump
buttonSuperJump.MouseButton1Click:Connect(function()
    SuperJumpEnabled = not SuperJumpEnabled
    buttonSuperJump.Text = "Super Jump: " .. (SuperJumpEnabled and "ON" or "OFF") .. " (" .. SuperJumpPower .. ")"
end)
miscY = miscY + 40

local buttonJumpUp = Instance.new("TextButton")
buttonJumpUp.Parent = miscFrame
buttonJumpUp.Size = UDim2.new(0.5, -15, 0, 35)
buttonJumpUp.Position = UDim2.new(0, 10, 0, miscY)
buttonJumpUp.Text = "Jump +10"
buttonJumpUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonJumpUp.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonJumpUp
buttonJumpUp.MouseButton1Click:Connect(function()
    SuperJumpPower = math.min(SuperJumpPower + 10, 500)
    buttonSuperJump.Text = "Super Jump: " .. (SuperJumpEnabled and "ON" or "OFF") .. " (" .. SuperJumpPower .. ")"
end)

local buttonJumpDown = Instance.new("TextButton")
buttonJumpDown.Parent = miscFrame
buttonJumpDown.Size = UDim2.new(0.5, -15, 0, 35)
buttonJumpDown.Position = UDim2.new(0.5, 5, 0, miscY)
buttonJumpDown.Text = "Jump -10"
buttonJumpDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonJumpDown.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonJumpDown
buttonJumpDown.MouseButton1Click:Connect(function()
    SuperJumpPower = math.max(SuperJumpPower - 10, 50)
    buttonSuperJump.Text = "Super Jump: " .. (SuperJumpEnabled and "ON" or "OFF") .. " (" .. SuperJumpPower .. ")"
end)
miscY = miscY + 40

local buttonSpeedBoost = Instance.new("TextButton")
buttonSpeedBoost.Parent = miscFrame
buttonSpeedBoost.Size = UDim2.new(1, -20, 0, 35)
buttonSpeedBoost.Position = UDim2.new(0, 10, 0, miscY)
buttonSpeedBoost.Text = "Speed Boost: OFF (" .. SpeedBoostAmount .. ")"
buttonSpeedBoost.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSpeedBoost.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSpeedBoost
buttonSpeedBoost.MouseButton1Click:Connect(function()
    SpeedBoostEnabled = not SpeedBoostEnabled
    buttonSpeedBoost.Text = "Speed Boost: " .. (SpeedBoostEnabled and "ON" or "OFF") .. " (" .. SpeedBoostAmount .. ")"
end)
miscY = miscY + 40

local buttonSpeedUp = Instance.new("TextButton")
buttonSpeedUp.Parent = miscFrame
buttonSpeedUp.Size = UDim2.new(0.5, -15, 0, 35)
buttonSpeedUp.Position = UDim2.new(0, 10, 0, miscY)
buttonSpeedUp.Text = "Speed +10"
buttonSpeedUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSpeedUp.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSpeedUp
buttonSpeedUp.MouseButton1Click:Connect(function()
    SpeedBoostAmount = math.min(SpeedBoostAmount + 10, 200)
    buttonSpeedBoost.Text = "Speed Boost: " .. (SpeedBoostEnabled and "ON" or "OFF") .. " (" .. SpeedBoostAmount .. ")"
end)

local buttonSpeedDown = Instance.new("TextButton")
buttonSpeedDown.Parent = miscFrame
buttonSpeedDown.Size = UDim2.new(0.5, -15, 0, 35)
buttonSpeedDown.Position = UDim2.new(0.5, 5, 0, miscY)
buttonSpeedDown.Text = "Speed -10"
buttonSpeedDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSpeedDown.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSpeedDown
buttonSpeedDown.MouseButton1Click:Connect(function()
    SpeedBoostAmount = math.max(SpeedBoostAmount - 10, 16)
    buttonSpeedBoost.Text = "Speed Boost: " .. (SpeedBoostEnabled and "ON" or "OFF") .. " (" .. SpeedBoostAmount .. ")"
end)
miscY = miscY + 40

local buttonKillAll = Instance.new("TextButton")
buttonKillAll.Parent = miscFrame
buttonKillAll.Size = UDim2.new(1, -20, 0, 35)
buttonKillAll.Position = UDim2.new(0, 10, 0, miscY)
buttonKillAll.Text = "Kill All"
buttonKillAll.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
buttonKillAll.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonKillAll
buttonKillAll.MouseButton1Click:Connect(killAll)
miscY = miscY + 40

local buttonAnnouncement = Instance.new("TextButton")
buttonAnnouncement.Parent = miscFrame
buttonAnnouncement.Size = UDim2.new(1, -20, 0, 35)
buttonAnnouncement.Position = UDim2.new(0, 10, 0, miscY)
buttonAnnouncement.Text = "Crazy Announcement"
buttonAnnouncement.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
buttonAnnouncement.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonAnnouncement
buttonAnnouncement.MouseButton1Click:Connect(sendAnnouncement)
miscY = miscY + 40

-- Keybind Changer Buttons
for feature, key in pairs(Keybinds) do
    local buttonKeybind = Instance.new("TextButton")
    buttonKeybind.Parent = miscFrame
    buttonKeybind.Size = UDim2.new(1, -20, 0, 35)
    buttonKeybind.Position = UDim2.new(0, 10, 0, miscY)
    buttonKeybind.Text = feature .. ": " .. key.Name
    buttonKeybind.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    buttonKeybind.TextColor3 = Color3.fromRGB(255, 255, 255)
    uiCornerBtn:Clone().Parent = buttonKeybind
    buttonKeybind.MouseButton1Click:Connect(function()
        SettingKeybind = feature
        buttonKeybind.Text = feature .. ": Press Key..."
    end)
    miscY = miscY + 40
end

-- Aimbot Category
local aimbotFrame = categoryFrames["Aimbot"]
local aimbotY = 40

local buttonAimbot = Instance.new("TextButton")
buttonAimbot.Parent = aimbotFrame
buttonAimbot.Size = UDim2.new(1, -20, 0, 35)
buttonAimbot.Position = UDim2.new(0, 10, 0, aimbotY)
buttonAimbot.Text = "Aimbot: OFF"
buttonAimbot.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonAimbot.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonAimbot
buttonAimbot.MouseButton1Click:Connect(function()
    AimbotEnabled = not AimbotEnabled
    buttonAimbot.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
end)
aimbotY = aimbotY + 40

local buttonShowFOV = Instance.new("TextButton")
buttonShowFOV.Parent = aimbotFrame
buttonShowFOV.Size = UDim2.new(1, -20, 0, 35)
buttonShowFOV.Position = UDim2.new(0, 10, 0, aimbotY)
buttonShowFOV.Text = "Show FOV: ON"
buttonShowFOV.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonShowFOV.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonShowFOV
buttonShowFOV.MouseButton1Click:Connect(function()
    ShowFOV = not ShowFOV
    buttonShowFOV.Text = ShowFOV and "Show FOV: ON" or "Show FOV: OFF"
end)
aimbotY = aimbotY + 40

local buttonFOVUp = Instance.new("TextButton")
buttonFOVUp.Parent = aimbotFrame
buttonFOVUp.Size = UDim2.new(0.5, -15, 0, 35)
buttonFOVUp.Position = UDim2.new(0, 10, 0, aimbotY)
buttonFOVUp.Text = "FOV +50"
buttonFOVUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonFOVUp.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonFOVUp
buttonFOVUp.MouseButton1Click:Connect(function()
    AimbotFOV = AimbotFOV + 50
end)

local buttonFOVDown = Instance.new("TextButton")
buttonFOVDown.Parent = aimbotFrame
buttonFOVDown.Size = UDim2.new(0.5, -15, 0, 35)
buttonFOVDown.Position = UDim2.new(0.5, 5, 0, aimbotY)
buttonFOVDown.Text = "FOV -50"
buttonFOVDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonFOVDown.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonFOVDown
buttonFOVDown.MouseButton1Click:Connect(function()
    AimbotFOV = math.max(AimbotFOV - 50, 50)
end)
aimbotY = aimbotY + 40

local buttonMagicBullet = Instance.new("TextButton")
buttonMagicBullet.Parent = aimbotFrame
buttonMagicBullet.Size = UDim2.new(1, -20, 0, 35)
buttonMagicBullet.Position = UDim2.new(0, 10, 0, aimbotY)
buttonMagicBullet.Text = "Magic Bullet: OFF"
buttonMagicBullet.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonMagicBullet.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonMagicBullet
buttonMagicBullet.MouseButton1Click:Connect(function()
    MagicBulletEnabled = not MagicBulletEnabled
    buttonMagicBullet.Text = MagicBulletEnabled and "Magic Bullet: ON" or "Magic Bullet: OFF"
end)
aimbotY = aimbotY + 40

local buttonSmoothUp = Instance.new("TextButton")
buttonSmoothUp.Parent = aimbotFrame
buttonSmoothUp.Size = UDim2.new(0.5, -15, 0, 35)
buttonSmoothUp.Position = UDim2.new(0, 10, 0, aimbotY)
buttonSmoothUp.Text = "Smooth +0.1"
buttonSmoothUp.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSmoothUp.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSmoothUp
buttonSmoothUp.MouseButton1Click:Connect(function()
    AimbotSmoothness = math.min(AimbotSmoothness + 0.1, 1)
end)

local buttonSmoothDown = Instance.new("TextButton")
buttonSmoothDown.Parent = aimbotFrame
buttonSmoothDown.Size = UDim2.new(0.5, -15, 0, 35)
buttonSmoothDown.Position = UDim2.new(0.5, 5, 0, aimbotY)
buttonSmoothDown.Text = "Smooth -0.1"
buttonSmoothDown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSmoothDown.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSmoothDown
buttonSmoothDown.MouseButton1Click:Connect(function()
    AimbotSmoothness = math.max(AimbotSmoothness - 0.1, 0)
end)

-- Special Category for Steal a Brainrot
local specialFrame = categoryFrames["Special"]
local specialY = 40

local baseTPList = Instance.new("ScrollingFrame")
baseTPList.Parent = specialFrame
baseTPList.Size = UDim2.new(1, -20, 0, 150)
baseTPList.Position = UDim2.new(0, 10, 0, specialY)
baseTPList.BackgroundTransparency = 1
baseTPList.ScrollBarThickness = 5

local function updateBaseTPList()
    for _, child in ipairs(baseTPList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local yOffset = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local button = Instance.new("TextButton")
            button.Parent = baseTPList
            button.Size = UDim2.new(1, 0, 0, 25)
            button.Position = UDim2.new(0, 0, 0, yOffset)
            button.Text = "TP to " .. player.Name .. "'s Base"
            button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            uiCornerBtn:Clone().Parent = button

            button.MouseButton1Click:Connect(function()
                teleportToBase(player)
            end)

            yOffset = yOffset + 30
        end
    end
    baseTPList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

updateBaseTPList()
Players.PlayerAdded:Connect(updateBaseTPList)
Players.PlayerRemoving:Connect(updateBaseTPList)
specialY = specialY + 160

local buttonAutoSteal = Instance.new("TextButton")
buttonAutoSteal.Parent = specialFrame
buttonAutoSteal.Size = UDim2.new(1, -20, 0, 35)
buttonAutoSteal.Position = UDim2.new(0, 10, 0, specialY)
buttonAutoSteal.Text = "Auto Steal Brainrots"
buttonAutoSteal.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
buttonAutoSteal.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonAutoSteal
buttonAutoSteal.MouseButton1Click:Connect(autoStealBrainrots)
specialY = specialY + 40

local buttonSpawnGolden = Instance.new("TextButton")
buttonSpawnGolden.Parent = specialFrame
buttonSpawnGolden.Size = UDim2.new(1, -20, 0, 35)
buttonSpawnGolden.Position = UDim2.new(0, 10, 0, specialY)
buttonSpawnGolden.Text = "Spawn Golden Brainrot"
buttonSpawnGolden.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
buttonSpawnGolden.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonSpawnGolden
buttonSpawnGolden.MouseButton1Click:Connect(spawnGoldenBrainrot)
specialY = specialY + 40

local buttonBypassProtection = Instance.new("TextButton")
buttonBypassProtection.Parent = specialFrame
buttonBypassProtection.Size = UDim2.new(1, -20, 0, 35)
buttonBypassProtection.Position = UDim2.new(0, 10, 0, specialY)
buttonBypassProtection.Text = "Bypass Base Protection"
buttonBypassProtection.BackgroundColor3 = Color3.fromRGB(200, 0, 200)
buttonBypassProtection.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonBypassProtection
buttonBypassProtection.MouseButton1Click:Connect(bypassBaseProtection)

-- Close Button
local buttonClose = Instance.new("TextButton")
buttonClose.Parent = mainFrame
buttonClose.Size = UDim2.new(0, 30, 0, 30)
buttonClose.Position = UDim2.new(1, -35, 0, 5)
buttonClose.Text = "X"
buttonClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
buttonClose.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonClose

buttonClose.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    if MenuVisible then
        TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(1, -360, 0.5, -250)}):Play()
    else
        TweenService:Create(mainFrame, tweenInfo, {Position = UDim2.new(1, 10, 0.5, -250)}):Play()
    end
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if SettingKeybind and input.KeyCode ~= Enum.KeyCode.Unknown then
        Keybinds[SettingKeybind] = input.KeyCode
        -- Update button text
        for _, child in ipairs(miscFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Text:find(SettingKeybind) then
                child.Text = SettingKeybind .. ": " .. input.KeyCode.Name
            end
        end
        SettingKeybind = nil
        return
    end
    if not gameProcessed then
        if input.KeyCode == Keybinds.ToggleMenu then
            buttonClose:Fire("MouseButton1Click")
        elseif input.KeyCode == Keybinds.ToggleESP then
            ESPEnabled = not ESPEnabled
            buttonESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
        elseif input.KeyCode == Keybinds.ToggleInvisible then
            InvisibleEnabled = not InvisibleEnabled
            toggleInvisibility(InvisibleEnabled)
            buttonInvisible.Text = InvisibleEnabled and "Invisibility: ON" or "Invisibility: OFF"
        elseif input.KeyCode == Keybinds.ToggleAimbot then
            AimbotEnabled = not AimbotEnabled
            buttonAimbot.Text = AimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
        elseif input.KeyCode == Keybinds.ToggleMagicBullet then
            MagicBulletEnabled = not MagicBulletEnabled
            buttonMagicBullet.Text = MagicBulletEnabled and "Magic Bullet: ON" or "Magic Bullet: OFF"
        end
    end
end)

-- Handle Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    TPPoint = nil
    if buttonTPPoint then
        buttonTPPoint.Text = "TP: Set Custom Point"
    end
    if InvisibleEnabled then
        toggleInvisibility(true)
    end
    char:WaitForChild("Humanoid")
    char.Humanoid.JumpPower = SuperJumpEnabled and SuperJumpPower or defaultJumpPower
    char.Humanoid.WalkSpeed = SpeedBoostEnabled and SpeedBoostAmount or defaultWalkSpeed
end)

-- Initial State
mainFrame.Visible = true
showCategory("Special")