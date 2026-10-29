-- Rayfield UI Library (Mobil uyumlu ve en şık arayüz kütüphanelerinden biri)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu'))()

local Window = Rayfield:CreateWindow({
   Name = "Savaş Tycoon Hub | Delta",
   LoadingTitle = "Script Hazırlanıyor...",
   LoadingSubtitle = "by AI Developer",
   ConfigurationSaving = {
      Enabled = false
   }
})

-- SEKMELER
local MainTab = Window:CreateTab("Ana Özellikler", 4483345998)
local CombatTab = Window:CreateTab("Savaş & Aim", 4483345998)

-- DEĞİŞKENLER (Uçma ve Aim için)
local Player = game.Players.LocalPlayer
local Camera = game.Workspace.CurrentCamera
local Mouse = Player:GetMouse()

local Flying = false
local FlySpeed = 50
local AimbotEnabled = false
local SilentAimEnabled = false

-- --- 1. ÖZELLİK: UÇMA (FLY) ---
local function startFlying()
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Root = Character:WaitForChild("HumanoidRootPart")
    local Humanoid = Character:WaitForChild("Humanoid")
    
    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Parent = Root
    
    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.CFrame = Root.CFrame
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.Parent = Root
    
    Humanoid.PlatformStand = true
    
    task.spawn(function()
        while Flying and Character:FindFirstChild("HumanoidRootPart") do
            task.wait()
            local moveDirection = Humanoid.MoveDirection
            if moveDirection.Magnitude > 0 then
                BodyVelocity.Velocity = moveDirection * FlySpeed
            else
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
            BodyGyro.CFrame = Camera.CFrame
        end
        BodyVelocity:Destroy()
        BodyGyro:Destroy()
        Humanoid.PlatformStand = false
    end)
end

MainTab:CreateToggle({
   Name = "Uçma Hilesi (Fly)",
   CurrentValue = false,
   Callback = function(Value)
      Flying = Value
      if Flying then startFlying() end
   end,
})

MainTab:CreateSlider({
   Name = "Uçma Hızı",
   Min = 10,
   Max = 150,
   CurrentValue = 50,
   Flag = "FlySpeedSlider",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

-- --- EN YAKIN OYUNCUYU BULMA (AIM İÇİN) ---
local function getClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local distance = (Player.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestPlayer = v
                shortestDistance = distance
            end
        end
    end
    return closestPlayer
end

-- --- 2. ÖZELLİK: AIMBOT (KAMERAYI KİLİTLEME) ---
task.spawn(function()
    while task.wait() do
        if AimbotEnabled then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
            end
        end
    end
end)

CombatTab:CreateToggle({
   Name = "Aimbot (Kamerayı Odakla)",
   CurrentValue = false,
   Callback = function(Value)
      AimbotEnabled = Value
   end,
})

-- --- 3. ÖZELLİK: SILENT AIM (MERMİLERİ YÖNLENDİRME) ---
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if SilentAimEnabled and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" or method == "Raycast") then
        local target = getClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            return target.Character.Head, target.Character.Head.Position, target.Character.Head.CFrame.LookVector, target.Character.Head.Material
        end
    end
    
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

CombatTab:CreateToggle({
   Name = "Silent Aim (Sihirli Mermi)",
   CurrentValue = false,
   Callback = function(Value)
      SilentAimEnabled = Value
   end,
})

Rayfield:Notify({
   Title = "Yüklendi!",
   Content = "Savaş Tycoon hilesi başarıyla çalıştı. İyi oyunlar!",
   Duration = 5,
   Image = 4483345998,
})
