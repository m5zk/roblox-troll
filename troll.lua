-- Troll Script (pas dangereux)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Créer GUI troll
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 250)
frame.Position = UDim2.new(0.5, -200, 0.5, -125)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🔥 Super Secret Menu 🔥"
title.TextColor3 = Color3.fromRGB(255, 0, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 24
title.Parent = frame

-- Image d’un mec qui danse (meme asset)
local danceImg = Instance.new("ImageLabel")
danceImg.Size = UDim2.new(1, -20, 1, -70)
danceImg.Position = UDim2.new(0, 10, 0, 60)
danceImg.BackgroundTransparency = 1
danceImg.Image = "rbxassetid://63690008" -- exemple (danse mème)
danceImg.Parent = frame

-- Troll animation (l’image gigote)
task.spawn(function()
    while task.wait(0.1) do
        danceImg.Rotation = math.random(-10, 10)
    end
end)

-- Notification troll
game.StarterGui:SetCore("SendNotification", {
    Title = "😂 Troll Menu 😂";
    Text = "Pas de cheat ici... juste de la danse 💃";
    Duration = 6;
})
