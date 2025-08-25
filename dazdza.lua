-- Improved Troll ESP + TP + Menu
-- Enhanced by Grok: Better performance, more features, improved UI, error handling, and additional options :)
-- Added: Player list for TP, health bars in ESP, distance display, keybinds, smoother animations, and more customization.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local drawings = {}  -- Table for ESP drawings (boxes, texts, health bars)
local ESPEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPSize = Vector2.new(50, 100)
local ShowNames = true
local ShowHealth = true
local ShowDistance = true
local TracerEnabled = false
local TracerColor = Color3.fromRGB(255, 255, 255)

local TPPoint = nil
local TPToPlayer = nil  -- For teleporting to specific players
local MenuVisible = true

-- === Improved ESP System ===
local function createESP(player)
    if drawings[player] then return end  -- Avoid duplicates

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

            if vis and ESPEnabled then
                -- Calculate dynamic size based on distance for better visuals
                local scale = math.clamp(1000 / distance, 0.5, 10)
                local dynamicSize = ESPSize * scale

                -- Box
                esp.box.Position = Vector2.new(pos.X - dynamicSize.X / 2, pos.Y - dynamicSize.Y / 2)
                esp.box.Size = dynamicSize
                esp.box.Color = ESPColor
                esp.box.Visible = true

                -- Name
                if ShowNames then
                    esp.name.Text = player.Name
                    esp.name.Position = Vector2.new(pos.X, pos.Y - dynamicSize.Y / 2 - 20)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end

                -- Health Bar
                if ShowHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    esp.health.Color = Color3.fromHSV(healthPercent / 3, 1, 1)  -- Green to red gradient
                    esp.health.From = Vector2.new(pos.X - dynamicSize.X / 2 - 5, pos.Y + dynamicSize.Y / 2)
                    esp.health.To = Vector2.new(pos.X - dynamicSize.X / 2 - 5, pos.Y + dynamicSize.Y / 2 - (dynamicSize.Y * healthPercent))
                    esp.health.Visible = true
                else
                    esp.health.Visible = false
                end

                -- Distance
                if ShowDistance then
                    esp.distance.Text = math.floor(distance) .. " studs"
                    esp.distance.Position = Vector2.new(pos.X, pos.Y + dynamicSize.Y / 2 + 5)
                    esp.distance.Visible = true
                else
                    esp.distance.Visible = false
                end

                -- Tracer
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

-- Initialize ESP for existing players
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

-- === Improved GUI Menu ===
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(1, -310, 0.5, -200)  -- Positioned on the right side
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true  -- Make menu draggable

-- Add smooth open/close animation
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔥 Ultimate Troll Menu 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20

-- ESP Toggle
local buttonESP = Instance.new("TextButton")
buttonESP.Parent = frame
buttonESP.Size = UDim2.new(1, -20, 0, 35)
buttonESP.Position = UDim2.new(0, 10, 0, 50)
buttonESP.Text = "ESP: OFF"
buttonESP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonESP.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonESP.Font = Enum.Font.Gotham

buttonESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    buttonESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

-- Toggle Names
local buttonNames = Instance.new("TextButton")
buttonNames.Parent = frame
buttonNames.Size = UDim2.new(1, -20, 0, 35)
buttonNames.Position = UDim2.new(0, 10, 0, 90)
buttonNames.Text = "Show Names: ON"
buttonNames.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonNames.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonNames.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    buttonNames.Text = ShowNames and "Show Names: ON" or "Show Names: OFF"
end)

-- Toggle Health
local buttonHealth = Instance.new("TextButton")
buttonHealth.Parent = frame
buttonHealth.Size = UDim2.new(1, -20, 0, 35)
buttonHealth.Position = UDim2.new(0, 10, 0, 130)
buttonHealth.Text = "Show Health: ON"
buttonHealth.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonHealth.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonHealth.MouseButton1Click:Connect(function()
    ShowHealth = not ShowHealth
    buttonHealth.Text = ShowHealth and "Show Health: ON" or "Show Health: OFF"
end)

-- Toggle Distance
local buttonDistance = Instance.new("TextButton")
buttonDistance.Parent = frame
buttonDistance.Size = UDim2.new(1, -20, 0, 35)
buttonDistance.Position = UDim2.new(0, 10, 0, 170)
buttonDistance.Text = "Show Distance: ON"
buttonDistance.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonDistance.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonDistance.MouseButton1Click:Connect(function()
    ShowDistance = not ShowDistance
    buttonDistance.Text = ShowDistance and "Show Distance: ON" or "Show Distance: OFF"
end)

-- Toggle Tracers
local buttonTracers = Instance.new("TextButton")
buttonTracers.Parent = frame
buttonTracers.Size = UDim2.new(1, -20, 0, 35)
buttonTracers.Position = UDim2.new(0, 10, 0, 210)
buttonTracers.Text = "Tracers: OFF"
buttonTracers.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonTracers.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonTracers.MouseButton1Click:Connect(function()
    TracerEnabled = not TracerEnabled
    buttonTracers.Text = TracerEnabled and "Tracers: ON" or "Tracers: OFF"
end)

-- Change ESP Size (Cycle through sizes)
local sizes = {Vector2.new(50, 100), Vector2.new(80, 160), Vector2.new(100, 200)}
local currentSizeIndex = 1
local buttonSize = Instance.new("TextButton")
buttonSize.Parent = frame
buttonSize.Size = UDim2.new(1, -20, 0, 35)
buttonSize.Position = UDim2.new(0, 10, 0, 250)
buttonSize.Text = "ESP Size: Small"
buttonSize.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonSize.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonSize.MouseButton1Click:Connect(function()
    currentSizeIndex = (currentSizeIndex % #sizes) + 1
    ESPSize = sizes[currentSizeIndex]
    buttonSize.Text = "ESP Size: " .. (currentSizeIndex == 1 and "Small" or currentSizeIndex == 2 and "Medium" or "Large")
end)

-- Change ESP Color (Cycle through colors)
local colors = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255), Color3.fromRGB(255, 255, 0)}
local currentColorIndex = 1
local buttonColor = Instance.new("TextButton")
buttonColor.Parent = frame
buttonColor.Size = UDim2.new(1, -20, 0, 35)
buttonColor.Position = UDim2.new(0, 10, 0, 290)
buttonColor.Text = "ESP Color: Red"
buttonColor.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonColor.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonColor.MouseButton1Click:Connect(function()
    currentColorIndex = (currentColorIndex % #colors) + 1
    ESPColor = colors[currentColorIndex]
    buttonColor.Text = "ESP Color: " .. (currentColorIndex == 1 and "Red" or currentColorIndex == 2 and "Green" or currentColorIndex == 3 and "Blue" or "Yellow")
end)

-- TP Section: Set Point or TP to Player
local buttonTPPoint = Instance.new("TextButton")
buttonTPPoint.Parent = frame
buttonTPPoint.Size = UDim2.new(1, -20, 0, 35)
buttonTPPoint.Position = UDim2.new(0, 10, 0, 330)
buttonTPPoint.Text = "TP: Set Custom Point"
buttonTPPoint.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonTPPoint.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonTPPoint.MouseButton1Click:Connect(function()
    if not TPPoint then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            TPPoint = LocalPlayer.Character.HumanoidRootPart.Position
            buttonTPPoint.Text = "TP: Teleport to Point"
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TPPoint + Vector3.new(0, 3, 0))  -- Slight offset to avoid clipping
            TPPoint = nil
            buttonTPPoint.Text = "TP: Set Custom Point"
        end
    end
end)

-- Player List for TP
local tpList = Instance.new("ScrollingFrame")
tpList.Parent = frame
tpList.Size = UDim2.new(1, -20, 0, 100)
tpList.Position = UDim2.new(0, 10, 0, 370)  -- Adjusted position
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

            button.MouseButton1Click:Connect(function()
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -2)  -- TP behind them for troll
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

-- Close/Open Menu with Animation
local buttonClose = Instance.new("TextButton")
buttonClose.Parent = frame
buttonClose.Size = UDim2.new(0, 30, 0, 30)
buttonClose.Position = UDim2.new(1, -35, 0, 5)
buttonClose.Text = "X"
buttonClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
buttonClose.TextColor3 = Color3.fromRGB(255, 255, 255)

buttonClose.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    if MenuVisible then
        TweenService:Create(frame, tweenInfo, {Position = UDim2.new(1, -310, 0.5, -200)}):Play()
    else
        TweenService:Create(frame, tweenInfo, {Position = UDim2.new(1, 10, 0.5, -200)}):Play()  -- Slide out
    end
end)

-- Keybinds (e.g., Toggle Menu with Insert key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            buttonClose:Fire("MouseButton1Click")  -- Simulate close button click
        elseif input.KeyCode == Enum.KeyCode.E then
            buttonESP:Fire("MouseButton1Click")  -- Toggle ESP with E
        end
    end
end)

-- Error Handling for Character Respawn
LocalPlayer.CharacterAdded:Connect(function()
    -- Reset TP if needed
    TPPoint = nil
    buttonTPPoint.Text = "TP: Set Custom Point"
end)

-- Initial Menu State
frame.Visible = true