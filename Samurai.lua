local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | Asia Elite",
   LoadingTitle = "Loading Asia Farm...",
   ConfigurationSaving = {Enabled = true, FolderName = "SurvivalElite"}
})

local Settings = {
    AutoFarm = false,
    TweenSpeed = 45,
    SafeHeight = 10,
    SwordSlot = "4",
    PickaxeSlot = "3"
}

-- ASIA BIOME COORDINATES (Approximate center of Bamboo area)
local AsiaPosition = CFrame.new(-1700, 520, 7300) 

-- The "Force Search" Logic
local function GetTarget()
    -- We look for ANY model named "The Samurai" regardless of folder
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "The Samurai" and v:IsA("Model") then
            -- Check if it has a parts we can fly to
            if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Hitbox") or v.PrimaryPart then
                return v, "Boss"
            end
        end
    end
    
    -- Look for Adamantite Ores
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Adamantite Ore" and v:IsA("Model") then
            -- Use Attribute 'health' from your Dex screenshot
            local hp = v:GetAttribute("health")
            if hp and hp > 0 then
                return v, "Ore"
            end
        end
    end
    return nil, nil
end

local function Equip(slot)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[slot], false, game)
    task.wait(0.3)
end

local function MoveTo(targetCF)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local info = TweenInfo.new((targetCF.p - hrp.Position).Magnitude / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(hrp, info, {CFrame = targetCF})
    tween:Play()
    return tween
end

local function StartFarm()
    while Settings.AutoFarm do
        local target, kind = GetTarget()
        
        if target then
            if kind == "Boss" then
                Equip(Settings.SwordSlot)
                local t = MoveTo(target:GetPivot() * CFrame.new(0, Settings.SafeHeight, 0))
                t.Completed:Wait()
                
                while target and target.Parent and Settings.AutoFarm do
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, Settings.SafeHeight, 0)
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    task.wait(0.1)
                end
            elseif kind == "Ore" then
                Equip(Settings.PickaxeSlot)
                local t = MoveTo(target:GetPivot() * CFrame.new(0, 5, 0))
                t.Completed:Wait()
                
                while target and target:GetAttribute("health") > 0 and Settings.AutoFarm do
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    task.wait(0.1)
                    -- If samurai spawns, stop mining
                    local check, checkKind = GetTarget()
                    if checkKind == "Boss" then break end
                end
            end
        else
            print("Searching for targets in Asia...")
            task.wait(2)
        end
        task.wait(0.5)
    end
end

-- UI TABS --
local MainTab = Window:CreateTab("Main Farm", 4483362458)

MainTab:CreateButton({
   Name = "TP to Asia Biome (Fix Search)",
   Callback = function()
       MoveTo(AsiaPosition)
   end,
})

MainTab:CreateToggle({
   Name = "Start Auto Farm",
   CurrentValue = false,
   Callback = function(v)
       Settings.AutoFarm = v
       if v then task.spawn(StartFarm) end
   end,
})

MainTab:CreateSlider({
   Name = "Tween Speed",
   Range = {20, 100},
   Increment = 1,
   CurrentValue = 45,
   Callback = function(v) Settings.TweenSpeed = v end,
})
