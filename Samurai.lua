local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | Samurai & Adamantite",
   LoadingTitle = "Loading Asia Biome Scripts...",
   ConfigurationSaving = {Enabled = true, FolderName = "SurvivalElite"}
})

-- Configuration
local Settings = {
    AutoFarm = false,
    TweenSpeed = 48,
    SafeHeight = 11,
    SwordSlot = "4",
    PickaxeSlot = "3"
}

-- Utility Functions
local function Equip(slot)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[slot], false, game)
    task.wait(0.1)
end

local function TweenTo(cf)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local dist = (cf.p - hrp.Position).Magnitude
    local info = TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(hrp, info, {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

-- Main Farming Loop
local function StartSamuraiLoop()
    while Settings.AutoFarm do
        -- 1. SEARCH FOR SAMURAI BOSS (Based on your Dex Screenshot)
        local samurai = workspace:FindFirstChild("AI_Client") and workspace.AI_Client:FindFirstChild("The Samurai")
        
        if samurai and samurai:FindFirstChild("Head") and samurai:FindFirstChild("Humanoid") and samurai.Humanoid.Health > 0 then
            print("Samurai Spawned! Engaging...")
            Equip(Settings.SwordSlot)
            
            -- Stay above head to safe-spot him
            while samurai and samurai.Humanoid.Health > 0 and Settings.AutoFarm do
                TweenTo(samurai.Head.CFrame * CFrame.new(0, Settings.SafeHeight, 0))
                -- Trigger Click/Attack
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                task.wait(0.1)
            end
            print("Samurai Defeated.")
        else
            -- 2. IF BOSS IS GONE, FARM ADAMANTITE (Based on your Dex Screenshot)
            local mineable = workspace:WaitForChild("worldResources"):WaitForChild("mineable")
            local foundOre = false
            
            for _, folder in pairs(mineable:GetChildren()) do
                for _, ore in pairs(folder:GetChildren()) do
                    if ore.Name == "Adamantite Ore" and ore:GetAttribute("health") > 0 then
                        foundOre = true
                        print("Mining Adamantite...")
                        Equip(Settings.PickaxeSlot)
                        
                        local hb = ore:FindFirstChild("hitbox")
                        if hb then
                            TweenTo(hb.CFrame * CFrame.new(0, 5, 0))
                            -- Mine until broken or Boss spawns
                            while ore:GetAttribute("health") > 0 and Settings.AutoFarm do
                                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                task.wait(0.1)
                                -- Check if Samurai spawned mid-mine
                                if workspace.AI_Client:FindFirstChild("The Samurai") then break end
                            end
                        end
                    end
                    if not Settings.AutoFarm or workspace.AI_Client:FindFirstChild("The Samurai") then break end
                end
                if not Settings.AutoFarm or workspace.AI_Client:FindFirstChild("The Samurai") then break end
            end
            
            if not foundOre then
                print("No Ores or Boss found. Waiting...")
                task.wait(2)
            end
        end
        task.wait(0.5)
    end
end

-- UI Setup
local MainTab = Window:CreateTab("Samurai Farm", 4483362458)

MainTab:CreateToggle({
   Name = "Enable Asia Biome Farm",
   CurrentValue = false,
   Callback = function(Value)
      Settings.AutoFarm = Value
      if Value then
          task.spawn(StartSamuraiLoop)
      end
   end,
})

MainTab:CreateSlider({
   Name = "Tween Speed",
   Range = {20, 100},
   Increment = 1,
   CurrentValue = 48,
   Callback = function(Value) Settings.TweenSpeed = Value end,
})

MainTab:CreateSlider({
   Name = "Safe Height (Attack)",
   Range = {8, 20},
   Increment = 1,
   CurrentValue = 11,
   Callback = function(Value) Settings.SafeHeight = Value end,
})
