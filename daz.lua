-- TP All (fake)
local buttonTPAll = Instance.new("TextButton", frame)
buttonTPAll.Size = UDim2.new(1, -20, 0, 30)
buttonTPAll.Position = UDim2.new(0, 10, 0, 200) -- place au-dessus du Close Menu
buttonTPAll.Text = "TP All (Troll)"
buttonTPAll.BackgroundColor3 = Color3.fromRGB(100,60,200)
buttonTPAll.TextColor3 = Color3.fromRGB(255,255,255)

buttonTPAll.MouseButton1Click:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p ~= LocalPlayer then
            -- Déplace les joueurs VISUELLEMENT (local fake)
            p.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-5,5),0,math.random(-5,5))
        end
    end
end)

-- ⚠️ Attention : ça ne déplace que localement (fake), pas sur le vrai serveur
