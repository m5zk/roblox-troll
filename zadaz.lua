-- Ultimate Improved Troll ESP + TP + Menu
-- Enhanced by Grok: Organized into categories, beautiful UI with rounded corners, invisibility toggle, improved TP (works with tools equipped, safe TP), more ESP options, etc. :)
-- Added: Invisibility for local player (toggles transparency, handles tools), category sections in menu, UI improvements, ESP highlights for players holding tools.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local drawings = {}  -- Table for ESP drawings
local ESPEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0)
local ESPSize = Vector2.new(50, 100)
local ShowNames = true
local ShowHealth = true
local ShowDistance = true
local TracerEnabled = false
local TracerColor = Color3.fromRGB(255, 255, 255)
local HighlightTools = true  -- New: Highlight players holding tools

local TPPoint = nil
local InvisibleEnabled = false
local MenuVisible = true

-- === Improved ESP System ===
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

                -- Box with tool highlight
                esp.box.Position = Vector2.new(pos.X - dynamicSize.X / 2, pos.Y - dynamicSize.Y / 2)
                esp.box.Size = dynamicSize
                esp.box.Color = holdingTool and HighlightTools and Color3.fromRGB(255, 165, 0) or ESPColor  -- Orange if holding tool
                esp.box.Visible = true

                -- Name
                if ShowNames then
                    esp.name.Text = player.Name .. (holdingTool and " [Tool]" or "")
                    esp.name.Position = Vector2.new(pos.X, pos.Y - dynamicSize.Y / 2 - 20)
                    esp.name.Visible = true
                else
                    esp.name.Visible = false
                end

                -- Health Bar
                if ShowHealth then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    esp.health.Color = Color3.fromHSV(healthPercent / 3, 1, 1)
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

-- Initialize ESP
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

-- === Invisibility Function ===
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

    -- Handle tools: Keep tool visible or invisible as per preference
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        for _, p in ipairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Transparency = enable and 1 or 0
            end
        end
    end
end

-- Monitor invisibility state
RunService.Heartbeat:Connect(function()
    if InvisibleEnabled then
        toggleInvisibility(true)  -- Re-apply if needed (e.g., after respawn or tool change)
    end
end)

-- === Improved GUI Menu with Categories ===
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

local title = Instance.new("TextLabel")
title.Parent = mainFrame
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "🔥 Ultimate Troll Menu 🔥"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- Category: ESP Settings
local espFrame = Instance.new("Frame")
espFrame.Parent = mainFrame
espFrame.Size = UDim2.new(1, -20, 0, 250)
espFrame.Position = UDim2.new(0, 10, 0, 50)
espFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
espFrame.BorderSizePixel = 0

local uiCornerESP = Instance.new("UICorner")
uiCornerESP.CornerRadius = UDim.new(0, 8)
uiCornerESP.Parent = espFrame

local espTitle = Instance.new("TextLabel")
espTitle.Parent = espFrame
espTitle.Size = UDim2.new(1, 0, 0, 30)
espTitle.Text = "ESP Settings"
espTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
espTitle.BackgroundTransparency = 1
espTitle.Font = Enum.Font.GothamSemibold
espTitle.TextSize = 16

-- ESP Toggle
local buttonESP = Instance.new("TextButton")
buttonESP.Parent = espFrame
buttonESP.Size = UDim2.new(1, -20, 0, 35)
buttonESP.Position = UDim2.new(0, 10, 0, 40)
buttonESP.Text = "ESP: OFF"
buttonESP.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonESP.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonESP.Font = Enum.Font.Gotham
local uiCornerBtn = Instance.new("UICorner")
uiCornerBtn.CornerRadius = UDim.new(0, 5)
uiCornerBtn.Parent = buttonESP

buttonESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    buttonESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

-- Other ESP buttons (similarly styled)
local buttonNames = Instance.new("TextButton")
buttonNames.Parent = espFrame
buttonNames.Size = UDim2.new(1, -20, 0, 35)
buttonNames.Position = UDim2.new(0, 10, 0, 80)
buttonNames.Text = "Show Names: ON"
buttonNames.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonNames.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonNames

buttonNames.MouseButton1Click:Connect(function()
    ShowNames = not ShowNames
    buttonNames.Text = ShowNames and "Show Names: ON" or "Show Names: OFF"
end)

local buttonHealth = Instance.new("TextButton")
buttonHealth.Parent = espFrame
buttonHealth.Size = UDim2.new(1, -20, 0, 35)
buttonHealth.Position = UDim2.new(0, 10, 0, 120)
buttonHealth.Text = "Show Health: ON"
buttonHealth.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonHealth.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonHealth

buttonHealth.MouseButton1Click:Connect(function()
    ShowHealth = not ShowHealth
    buttonHealth.Text = ShowHealth and "Show Health: ON" or "Show Health: OFF"
end)

local buttonDistance = Instance.new("TextButton")
buttonDistance.Parent = espFrame
buttonDistance.Size = UDim2.new(1, -20, 0, 35)
buttonDistance.Position = UDim2.new(0, 10, 0, 160)
buttonDistance.Text = "Show Distance: ON"
buttonDistance.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonDistance.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonDistance

buttonDistance.MouseButton1Click:Connect(function()
    ShowDistance = not ShowDistance
    buttonDistance.Text = ShowDistance and "Show Distance: ON" or "Show Distance: OFF"
end)

local buttonTracers = Instance.new("TextButton")
buttonTracers.Parent = espFrame
buttonTracers.Size = UDim2.new(1, -20, 0, 35)
buttonTracers.Position = UDim2.new(0, 10, 0, 200)
buttonTracers.Text = "Tracers: OFF"
buttonTracers.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonTracers.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonTracers

buttonTracers.MouseButton1Click:Connect(function()
    TracerEnabled = not TracerEnabled
    buttonTracers.Text = TracerEnabled and "Tracers: ON" or "Tracers: OFF"
end)

local buttonHighlightTools = Instance.new("TextButton")
buttonHighlightTools.Parent = espFrame
buttonHighlightTools.Size = UDim2.new(1, -20, 0, 35)
buttonHighlightTools.Position = UDim2.new(0, 10, 0, 240)
buttonHighlightTools.Text = "Highlight Tools: ON"
buttonHighlightTools.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonHighlightTools.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonHighlightTools

buttonHighlightTools.MouseButton1Click:Connect(function()
    HighlightTools = not HighlightTools
    buttonHighlightTools.Text = HighlightTools and "Highlight Tools: ON" or "Highlight Tools: OFF"
end)

-- Category: TP Settings
local tpFrame = Instance.new("Frame")
tpFrame.Parent = mainFrame
tpFrame.Size = UDim2.new(1, -20, 0, 150)
tpFrame.Position = UDim2.new(0, 10, 0, 310)
tpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tpFrame.BorderSizePixel = 0
uiCornerESP:Clone().Parent = tpFrame

local tpTitle = Instance.new("TextLabel")
tpTitle.Parent = tpFrame
tpTitle.Size = UDim2.new(1, 0, 0, 30)
tpTitle.Text = "TP Settings"
tpTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
tpTitle.BackgroundTransparency = 1
tpTitle.Font = Enum.Font.GothamSemibold
tpTitle.TextSize = 16

local buttonTPPoint = Instance.new("TextButton")
buttonTPPoint.Parent = tpFrame
buttonTPPoint.Size = UDim2.new(1, -20, 0, 35)
buttonTPPoint.Position = UDim2.new(0, 10, 0, 40)
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
            -- Safe TP: Temporarily disable physics if needed, but CFrame works with tools
            local root = LocalPlayer.Character.HumanoidRootPart
            root.CFrame = CFrame.new(TPPoint + Vector3.new(0, 3, 0))
            -- Wait a bit to prevent falling
            wait(0.1)
            root.Velocity = Vector3.new(0, 0, 0)
            TPPoint = nil
            buttonTPPoint.Text = "TP: Set Custom Point"
        end
    end
end)

-- Player List for TP (Scrolling)
local tpList = Instance.new("ScrollingFrame")
tpList.Parent = tpFrame
tpList.Size = UDim2.new(1, -20, 0, 90)
tpList.Position = UDim2.new(0, 10, 0, 80)
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

-- Category: Misc Settings (Invisibility, etc.)
local miscFrame = Instance.new("Frame")
miscFrame.Parent = mainFrame
miscFrame.Size = UDim2.new(1, -20, 0, 100)
miscFrame.Position = UDim2.new(0, 10, 0, 470)
miscFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
miscFrame.BorderSizePixel = 0
uiCornerESP:Clone().Parent = miscFrame

local miscTitle = Instance.new("TextLabel")
miscTitle.Parent = miscFrame
miscTitle.Size = UDim2.new(1, 0, 0, 30)
miscTitle.Text = "Misc Settings"
miscTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
miscTitle.BackgroundTransparency = 1
miscTitle.Font = Enum.Font.GothamSemibold
miscTitle.TextSize = 16

local buttonInvisible = Instance.new("TextButton")
buttonInvisible.Parent = miscFrame
buttonInvisible.Size = UDim2.new(1, -20, 0, 35)
buttonInvisible.Position = UDim2.new(0, 10, 0, 40)
buttonInvisible.Text = "Invisibility: OFF"
buttonInvisible.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
buttonInvisible.TextColor3 = Color3.fromRGB(255, 255, 255)
uiCornerBtn:Clone().Parent = buttonInvisible

buttonInvisible.MouseButton1Click:Connect(function()
    InvisibleEnabled = not InvisibleEnabled
    toggleInvisibility(InvisibleEnabled)
    buttonInvisible.Text = InvisibleEnabled and "Invisibility: ON" or "Invisibility: OFF"
end)

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
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.Insert then
            buttonClose:Fire("MouseButton1Click")
        elseif input.KeyCode == Enum.KeyCode.E then
            buttonESP:Fire("MouseButton1Click")
        elseif input.KeyCode == Enum.KeyCode.I then
            buttonInvisible:Fire("MouseButton1Click")
        end
    end
end)

-- Handle Character Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    TPPoint = nil
    buttonTPPoint.Text = "TP: Set Custom Point"
    if InvisibleEnabled then
        toggleInvisibility(true)
    end
end)

-- Initial State
mainFrame.Visible = true 