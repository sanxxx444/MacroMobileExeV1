local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local grabEvent = replicatedStorage:FindFirstChild("TelekinesisGrab")
local releaseEvent = replicatedStorage:FindFirstChild("TelekinesisRelease")
local clientStorage = player:FindFirstChild("ClientStorage")
local events = clientStorage and clientStorage:FindFirstChild("Events")
local lightPunchEvent = events and events:FindFirstChild("LightPunch")

local function getClosestEnemy()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    local closest, dist = nil, math.huge
    for _, model in ipairs(workspace:GetChildren()) do
        if model:IsA("Model") and model ~= char and model:FindFirstChild("HumanoidRootPart") then
            local mag = (model.HumanoidRootPart.Position - root.Position).Magnitude
            if mag < dist and mag <= 20 then
                dist = mag
                closest = model
            end
        end
    end
    return closest
end

local function startTelekinesisSystem(target)
    if not (grabEvent and releaseEvent and lightPunchEvent and target) then return end
    local start = tick()
    local duration = 6.5
    local interval = 0.4
    local totalBursts = math.floor(duration / interval)
    local currentBurst = 0

    task.spawn(function()
        while tick() - start < duration do
            grabEvent:FireServer(target)
            task.wait(0.1)  -- ⚡ Más frecuente
        end
    end)

    task.spawn(function()
        while tick() - start < duration do
            currentBurst += 1
            local golpes = 3
            if currentBurst == totalBursts then
                golpes = 4
            elseif math.random() < 0.25 then
                golpes = 4
            end

            for _ = 1, golpes do
                if target
                    and target.Parent
                    and target:FindFirstChild("HumanoidRootPart")
                    and (target.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude <= 20
                    and target:FindFirstChildOfClass("Humanoid")
                    and target:FindFirstChildOfClass("Humanoid").Health > 0
                then
                    lightPunchEvent:FireServer({
                        Target = target,
                        IgnoreDefense = true,
                        Bypass = true,
                        Unblockable = true,
                        ForceDamage = true
                    })
                end
                task.wait(0.015)  -- ⚡ Ultra rápido
            end

            task.wait(interval)
        end
    end)

    task.spawn(function()
        while tick() - start < duration do
            if target:FindFirstChild("Stunned") then
                target.Stunned.Value = true
            end
            if target:FindFirstChild("Blocking") then
                target.Blocking.Value = false
            end
            if target:FindFirstChild("CantAttack") then
                target.CantAttack.Value = true
            end
            if target:FindFirstChild("HumanoidRootPart") then
                target.HumanoidRootPart.Anchored = true
            end
            task.wait(0.1)
        end
        if target:FindFirstChild("HumanoidRootPart") then
            target.HumanoidRootPart.Anchored = false
        end
        if target:FindFirstChild("CantAttack") then
            target.CantAttack.Value = false
        end
    end)

    task.delay(duration, function()
        releaseEvent:FireServer(target)
    end)
end

userInputService.TouchTap:Connect(function(touches, gp)
    if gp then return end
    if #touches >= 2 then
        local target = getClosestEnemy()
        if target then
            startTelekinesisSystem(target)
        else
            warn("❗ No hay enemigos cerca.")
        end
    end
end)

runService.Heartbeat:Connect(function()
    local char = player.Character
    if char then
        if char:FindFirstChild("Stunned") then
            char.Stunned.Value = false
        end
        if char:FindFirstChild("CantAttack") then
            char.CantAttack.Value = false
        end
        local tag = char:FindFirstChild("BypassDefense") or Instance.new("BoolValue")
        tag.Name = "BypassDefense"
        tag.Parent = char
        task.delay(0.1, function() tag:Destroy() end)
    end
end)

task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and root and root.Anchored then
            root.CFrame *= CFrame.new(math.random(-1, 1), 0, math.random(-1, 1)) * CFrame.Angles(0, math.rad(math.random(-10, 10)), 0)

            for _, model in ipairs(workspace:GetChildren()) do
                if model:IsA("Model") and model ~= char and model:FindFirstChild("HumanoidRootPart") then
                    local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist <= 12 then
                        if model:FindFirstChild("Blocking") then
                            model.Blocking.Value = true
                        end
                        if model:FindFirstChild("CantAttack") then
                            model.CantAttack.Value = true
                        end
                    end
                end
            end

            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 20 and root.Anchored then
                root.Anchored = false
                if releaseEvent then
                    releaseEvent:FireServer(char)
                end
            end

            local effects = char:FindFirstChild("ClientEffects")
            if effects then
                local fakeLag = Instance.new("Folder")
                fakeLag.Name = "VisualLag"
                fakeLag.Parent = effects
                task.delay(0.3, function()
                    if fakeLag and fakeLag.Parent then
                        fakeLag:Destroy()
                    end
                end)
            end
        end
        task.wait(0.1)
    end
end)
