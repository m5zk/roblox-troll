-- Troll ESP avec toggle
-- Pas ouf mais ça marche : une box rouge sur les joueurs avec bouton ON/OFF

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

local drawings = {}
local ESPEnabled = false

-- Créer box Drawing
local function makeBox(player)
    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1
    box.Filled = false
    box.Size = Vector2.new(50, 100)
    drawings[player] = box
end

-- Supprimer box
local function removeBox(player)
    if drawings[player] then
        drawings[player]:Remove()
        drawings[player] = nil
    end
end

-- Ajouter ESP aux joueurs déjà présents
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        makeBox(p)
    end
end

-- Quand un nouveau joueur rejoint
Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        makeBox(p)
    end
end)

-- Quand un joueur quitte
Players.PlayerRemoving:Connect(function(p)
    removeBox(p)
end)

-- Update des box
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        for player, box in pairs(drawings) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local root = player.Character.HumanoidRootPart
                local pos, vis = Camera:WorldToViewportPoint(root.Position)
                if vis then
                    box.Position = Vector2.new(pos.X - 25, pos.Y - 50)
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

-- === GUI Troll avec bouton toggle ===
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui", PlayerGui)
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.8, -50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,30)
title.Text = "Fake ESP Menu"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18

local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1, -20, 0, 40)
button.Position = UDim2.new(0, 10, 0, 40)
button.Text = "ESP: OFF"
button.BackgroundColor3 = Color3.fromRGB(60,60,60)
button.TextColor3 = Color3.fromRGB(255,255,255)
button.Font = Enum.Font.Gotham
button.TextSize = 16

button.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    button.Text = ESPEnabled and "ESP: ON" or "ESP: OFF"
end)
