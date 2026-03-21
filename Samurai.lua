local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | Asia Elite V5",
   LoadingTitle = "Mobile Optimized...",
   ConfigurationSaving = {Enabled = true, FolderName = "SurvivalElite"}
})

local Settings = {
    KillAura = false,
    AutoMine = false,
    SafeHeight = 12,
    AuraRange = 80, -- Increased range to find him easier
    AsiaPos = Vector3.new(-1670, 520, 7280) 
}

-- THE "SUPER SEARCH" (Finds anything containing 'samurai')
local function GetSamurai()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("Model") and v.Name:lower():find("samurai") then
            -- Verify it has a Hitbox or RootPart to TP to
            if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Hitbox") or v.PrimaryPart then
                return v
            end
        end
    end
    return nil
end

-- TOOL SWITCHER (Delta / Mobile Compatible)
local function Equip(slot)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[slot], false, game)
end

-- SKY-PATH TP (Launch up, fly across, drop down)
local function SkyTP(target)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    print("Launching to Sky...")
    
    -- 1. Up
    hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
    task.wait(0.5)
    
    -- 2. Across
    local dist = (Vector3.new(target.X, 500, target.Z) - hrp.Position).Magnitude
    local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(dist/65, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target.X, 500, target.Z)})
    tween:Play()
    tween.Completed:Wait()
    
    -- 3. Down
    hrp.CFrame = CFrame.new(target)
    print("Landed in Asia.")
end

-- KILL AURA MODULE (Independent Loop)
task.spawn(function()
    while task.wait(0.1) do
        if Settings.KillAura then
            local boss = GetSamurai()
            local hrp = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            
            if boss and hrp then
                local bossPos = boss:GetPivot()
                local dist = (bossPos.p - hrp.Position).Magnitude
                
                if dist < Settings.AuraRange then
                    -- LOCK POSITION ABOVE BOSS
                    hrp.CFrame = bossPos * CFrame.new(0, Settings.SafeHeight, 0)
                    -- EQUIP SWORD (Slot 4)
                    Equip("Four")
                    -- ATTACK
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                end
            end
        end
    end
end)

-- AUTO MINE MODULE (Independent Loop)
task.spawn(function()
    while task.wait(0.2) do
        if Settings.AutoMine and not Settings.KillAura then
            for _, v in pairs(workspace:GetDescendants()) do
                if v.Name == "Adamantite Ore" and v:IsA("Model") and v:GetAttribute("health") and v:GetAttribute("health") > 0 then
                    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
                    local orePos = v:GetPivot()
                    if (orePos.p - hrp.Position).Magnitude < 40 then
                        hrp.CFrame = orePos * CFrame.new(0, 5, 0)
                        Equip("Three") -- Pickaxe
                        game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                        break
                    end
                end
            end
        end
    end
end)

-- UI TABS
local MainTab = Window:CreateTab("Combat & Farm", 4483362458)

MainTab:CreateButton({
   Name = "1. Sky-TP to Asia Biome",
   Callback = function() SkyTP(Settings.AsiaPos) end,
})

MainTab:CreateToggle({
   Name = "2. Enable Kill Aura (Samurai)",
   CurrentValue = false,
   Callback = function(v) 
       Settings.KillAura = v 
       if v then print("Aura: Scanning for Samurai...") end
   end,
})

MainTab:CreateToggle({
   Name = "3. Auto Mine Adamantite",
   CurrentValue = false,
   Callback = function(v) Settings.AutoMine = v end,
})

MainTab:CreateSlider({
   Name = "Aura/Kill Height",
   Range = {8, 25},
   Increment = 1,
   CurrentValue = 12,
   Callback = function(v) Settings.SafeHeight = v end,
})

MainTab:CreateSlider({
   Name = "Aura Range",
   Range = {30, 200},
   Increment = 5,
   CurrentValue = 80,
   Callback = function(v) Settings.AuraRange = v end,
})
