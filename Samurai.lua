local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | Samurai Elite",
   LoadingTitle = "Loading Asia Farm...",
   ConfigurationSaving = {Enabled = true, FolderName = "SurvivalElite"}
})

local Settings = {
    AutoFarm = false,
    TweenSpeed = 48,
    SafeHeight = 11,
    SwordSlot = "4",
    PickaxeSlot = "3"
}

-- Target Function (Updated for AI_Server)
local function FindSamurai()
    -- Check AI_Server (from your new screenshot)
    local aiServer = workspace:FindFirstChild("AI_Server")
    if aiServer then
        local boss = aiServer:FindFirstChild("The Samurai")
        if boss then return boss end
    end
    
    -- Check AI_Client (from your old screenshot)
    local aiClient = workspace:FindFirstChild("AI_Client")
    if aiClient then
        local boss = aiClient:FindFirstChild("The Samurai")
        if boss then return boss end
    end

    -- Last resort: search everywhere
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "The Samurai" and v:IsA("Model") then
            return v
        end
    end
    return nil
end

local function Equip(slot)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode[slot], false, game)
    task.wait(0.3)
end

local function TweenTo(cf)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    local info = TweenInfo.new((cf.p - hrp.Position).Magnitude / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(hrp, info, {CFrame = cf})
    tween:Play()
    tween.Completed:Wait()
end

local function StartLoop()
    while Settings.AutoFarm do
        local samurai = FindSamurai()
        
        if samurai then
            -- We found him!
            Equip(Settings.SwordSlot)
            -- Use HumanoidRootPart or Hitbox for targeting
            local targetPart = samurai:FindFirstChild("HumanoidRootPart") or samurai:FindFirstChild("Hitbox") or samurai:FindFirstChild("Head")
            
            if targetPart then
                while samurai and targetPart.Parent and Settings.AutoFarm do
                    TweenTo(targetPart.CFrame * CFrame.new(0, Settings.SafeHeight, 0))
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    task.wait(0.1)
                    -- Check if he's dead (if he despawns or falls over)
                    if not samurai:IsDescendantOf(workspace) then break end
                end
            end
        else
            -- No Samurai? Farm Ores.
            local mineable = workspace:FindFirstChild("worldResources") and workspace.worldResources:FindFirstChild("mineable")
            if mineable then
                for _, folder in pairs(mineable:GetChildren()) do
                    for _, ore in pairs(folder:GetChildren()) do
                        if ore.Name == "Adamantite Ore" and ore:GetAttribute("health") > 0 then
                            Equip(Settings.PickaxeSlot)
                            local hb = ore:FindFirstChild("hitbox")
                            if hb then
                                TweenTo(hb.CFrame * CFrame.new(0, 5, 0))
                                while ore:GetAttribute("health") > 0 and Settings.AutoFarm do
                                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                                    task.wait(0.1)
                                    if FindSamurai() then break end
                                end
                            end
                        end
                        if not Settings.AutoFarm or FindSamurai() then break end
                    end
                    if not Settings.AutoFarm or FindSamurai() then break end
                end
            end
        end
        task.wait(1)
    end
end

local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateToggle({
   Name = "Auto Farm Samurai/Adamantite",
   CurrentValue = false,
   Callback = function(v)
       Settings.AutoFarm = v
       if v then task.spawn(StartLoop) end
   end,
})

MainTab:CreateSlider({
   Name = "Speed",
   Range = {20, 100},
   Increment = 1,
   CurrentValue = 48,
   Callback = function(v) Settings.TweenSpeed = v end,
})
