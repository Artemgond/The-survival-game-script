local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | FORCE FARM",
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

-- Target Finding (Checks EVERYTHING in workspace)
local function GetTarget()
    -- Priority 1: Samurai
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "The Samurai" and v:IsA("Model") then
            local hp = v:FindFirstChild("Humanoid")
            if (hp and hp.Health > 0) or (not hp) then -- Some versions don't show HP in Dex
                return v, "Boss"
            end
        end
    end
    
    -- Priority 2: Adamantite
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "Adamantite Ore" and v:IsA("Model") then
            if v:GetAttribute("health") and v:GetAttribute("health") > 0 then
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
    local distance = (targetCF.p - hrp.Position).Magnitude
    local info = TweenInfo.new(distance / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local tween = game:GetService("TweenService"):Create(hrp, info, {CFrame = targetCF})
    tween:Play()
    return tween
end

local function StartFarm()
    while Settings.AutoFarm do
        local target, kind = GetTarget()
        
        if target then
            if kind == "Boss" then
                print("Samurai Found!")
                Equip(Settings.SwordSlot)
                local pivot = target:GetPivot()
                local t = MoveTo(pivot * CFrame.new(0, Settings.SafeHeight, 0))
                t.Completed:Wait()
                
                -- Attack Loop
                while target and target.Parent and Settings.AutoFarm do
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, Settings.SafeHeight, 0)
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    task.wait(0.1)
                    if not target.Parent then break end
                end
            elseif kind == "Ore" then
                print("Ore Found!")
                Equip(Settings.PickaxeSlot)
                local pivot = target:GetPivot()
                local t = MoveTo(pivot * CFrame.new(0, 5, 0))
                t.Completed:Wait()
                
                while target and target:GetAttribute("health") > 0 and Settings.AutoFarm do
                    game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
                    task.wait(0.1)
                    -- Check if boss spawned while mining
                    local bossCheck = GetTarget()
                    if bossCheck and bossCheck.Name == "The Samurai" then break end
                end
            end
        else
            print("Searching for targets...")
            task.wait(2)
        end
        task.wait(0.5)
    end
end

local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateToggle({
   Name = "Start Auto Farm",
   CurrentValue = false,
   Callback = function(v)
       Settings.AutoFarm = v
       if v then task.spawn(StartFarm) end
   end,
})
