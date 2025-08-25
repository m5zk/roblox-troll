-- Troll ESP + TP + Menu
-- Pas ouf mais marche bien :)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local drawings = {}
local ESPEnabled = false
local ESPColor = Color3.fromRGB(255,0,0)
local ESPSize = Vector2.new(50,100)

local TPPoint = nil
local MenuVisible = true

-- === ESP System ===
local function makeBox(player)
    local box = Drawing.new("Square")
    box.Color = ESPColor
    box.Thickness = 1
    box.Filled = false
    box.Size = ESPSize
    drawings[player] = box
end

local function removeBox(player)
    if drawings[player] then
        drawings[player]:Remove()
        drawings[player] = nil
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        makeBox(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then makeBox(p) end
end)

Players.PlayerRemoving:Connect(function(p)
    removeBox(p)
end)

RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for player, box in pairs(drawings) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    box.Position = Vector2.new(pos.X - ESPSize.X/2, pos.Y - ESPSize.Y/2)
                    box.Size = ESPSize
                    box.Color = ESPColor
                    box.Visible = true
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    else
        for _, box in pairs(drawings) do
            box.Visible = false
        end
    end
end)

-- === GUI Menu ===
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 250, 0, 220)
frame.Position = UDim2.new(0.5, -125, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🔥 Fake Cheat Menu 🔥"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

-- ESP Toggle
local buttonESP = Instance.new("TextButton", frame)
buttonESP.Size = UDim2.new(1, -20, 0, 30)
buttonESP.Position = UDim2.new(0, 10, 0, 40)
buttonESP.Text = "ESP: OFF"
buttonESP.BackgroundColor3 = Color3.fromRGB(60,60,60)
buttonESP.TextColor3 = Color3.fromRGB(255,255,255)

buttonESP.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    buttonESP.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)

-- ESP Size
local buttonSize = Instance.new("TextButton", frame)
buttonSize.Size = UDim2.new(1, -20, 0, 30)
buttonSize.Position = UDim2.new(0, 10, 0, 80)
buttonSize.Text = "Change Box Size"
buttonSize.BackgroundColor3 = Color3.fromRGB(60,60,60)
buttonSize.TextColor3 = Color3.fromRGB(255,255,255)

buttonSize.MouseButton1Click:Connect(function()
    if ESPSize.X == 50 then
        ESPSize = Vector2.new(80,160)
    else
        ESPSize = Vector2.new(50,100)
    end
end)

-- ESP Color
local buttonColor = Instance.new("TextButton", frame)
buttonColor.Size = UDim2.new(1, -20, 0, 30)
buttonColor.Position = UDim2.new(0, 10, 0, 120)
buttonColor.Text = "Change ESP Color"
buttonColor.BackgroundColor3 = Color3.fromRGB(60,60,60)
buttonColor.TextColor3 = Color3.fromRGB(255,255,255)

buttonColor.MouseButton1Click:Connect(function()
    if ESPColor == Color3.fromRGB(255,0,0) then
        ESPColor = Color3.fromRGB(0,255,0)
    else
        ESPColor = Color3.fromRGB(255,0,0)
    end
end)

-- TP Button
local buttonTP = Instance.new("TextButton", frame)
buttonTP.Size = UDim2.new(1, -20, 0, 30)
buttonTP.Position = UDim2.new(0, 10, 0, 160)
buttonTP.Text = "TP: Set Point"
buttonTP.BackgroundColor3 = Color3.fromRGB(60,60,60)
buttonTP.TextColor3 = Color3.fromRGB(255,255,255)

buttonTP.MouseButton1Click:Connect(function()
    if not TPPoint then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            TPPoint = LocalPlayer.Character.HumanoidRootPart.Position
            buttonTP.Text = "TP: Teleport"
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(TPPoint)
            TPPoint = nil
            buttonTP.Text = "TP: Set Point"
        end
    end
end)

-- Close Menu
local buttonClose = Instance.new("TextButton", frame)
buttonClose.Size = UDim2.new(1, -20, 0, 30)
buttonClose.Position = UDim2.new(0, 10, 0, 200)
buttonClose.Text = "Close Menu"
buttonClose.BackgroundColor3 = Color3.fromRGB(200,50,50)
buttonClose.TextColor3 = Color3.fromRGB(255,255,255)

buttonClose.MouseButton1Click:Connect(function()
    MenuVisible = not MenuVisible
    frame.Visible = MenuVisible
end)
