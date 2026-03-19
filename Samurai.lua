local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Survival Game | DEBUG EDITION",
   LoadingTitle = "Checking Objects...",
   ConfigurationSaving = {Enabled = true, FolderName = "SurvivalElite"}
})

local Settings = {
    AutoFarm = false,
    TweenSpeed = 55,
    SafeHeight = 12,
    AsiaPos = Vector3.new(-1670, 520, 7280) 
}

-- 1. THE SEARCH (Checking for names specifically)
local function GetTarget()
    local allItems = workspace:GetDescendants()
    for _, v in pairs(allItems) do
        -- Check for Samurai
        if v.Name == "The Samurai" then
            print("FOUND SAMURAI IN: " .. v.Parent.Name)
            return v, "Boss"
        end
        -- Check for Adamantite
        if v.Name == "Adamantite Ore" then
            local hp = v:GetAttribute("health")
            if hp and hp > 0 then
                return v, "Ore"
            end
        end
    end
    return nil, nil
end

-- 2. THE MOVEMENT (Sky-Path)
local function SkyTP(targetPos)
    local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
    -- Up
    hrp.CFrame = hrp.CFrame * CFrame.new(0, 500, 0)
    task.wait(0.5)
    -- Across
    local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos.X, 500, targetPos.Z)})
    tween:Play()
    tween.Completed:Wait()
    -- Down
    hrp.CFrame = CFrame.new(targetPos)
    print("Arrived in Asia.")
end

-- 3. THE FARMING LOGIC
local function StartFarm()
    print("Farm Started. Searching...")
    while Settings.AutoFarm do
        local target, kind = GetTarget()
        
        if target then
            if kind == "Boss" then
                -- Direct TP to Boss
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, Settings.SafeHeight, 0)
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
            elseif kind == "Ore" then
                -- Direct TP to Ore
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = target:GetPivot() * CFrame.new(0, 5, 0)
                game:GetService("VirtualUser"):ClickButton1(Vector2.new(0,0))
            end
        else
            warn("Script can't see any targets. Are you in the Asia Biome?")
        end
        task.wait(0.2)
    end
end

-- UI
local MainTab = Window:CreateTab("Asia Farm", 4483362458)

MainTab:CreateButton({
   Name = "TP to Asia (Sky-Path)",
   Callback = function() SkyTP(Settings.AsiaPos) end,
})

MainTab:CreateToggle({
   Name = "Start Auto Farm",
   CurrentValue = false,
   Callback = function(v)
       Settings.AutoFarm = v
       if v then task.spawn(StartFarm) end
   end,
})
