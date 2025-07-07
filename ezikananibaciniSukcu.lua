local success, err = pcall(function()
    local player = game.Players.LocalPlayer
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local runService = game:GetService("RunService")
    local userInputService = game:GetService("UserInputService")

    local grabEvent = replicatedStorage:WaitForChild("TelekinesisGrab")
    local releaseEvent = replicatedStorage:WaitForChild("TelekinesisRelease")
    local clientStorage = player:WaitForChild("ClientStorage")
    local events = clientStorage:WaitForChild("Events")
    local lightPunchEvent = events:WaitForChild("LightPunch")

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
        local duration = 6
        local interval = duration / 18

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local boosted = root and root.Anchored
        if boosted then interval /= 1.4 end

        if not boosted and target then
            if target:FindFirstChild("CantAttack") then target.CantAttack.Value = true end
        end

        -- Golpes principales
        task.spawn(function()
            for i = 1, 18 do
                if target and target:FindFirstChild("HumanoidRootPart") and target:FindFirstChildOfClass("Humanoid") then
                    lightPunchEvent:FireServer({
                        Target = target,
                        IgnoreDefense = true,
                        Bypass = true,
                        BypassHitbox = true,
                        Unblockable = true,
                        ForceDamage = true,
                        Crit = true,
                        Visual = (i == 1 or i == 18)
                    })
                end
                task.wait(interval)
            end
        end)

        -- Ecos invisibles
        task.spawn(function()
            for i = 1, 18 do
                for j = 1, 2 do
                    lightPunchEvent:FireServer({
                        Target = target,
                        IgnoreDefense = true,
                        Bypass = true,
                        BypassHitbox = true,
                        Unblockable = true,
                        ForceDamage = true,
                        Crit = true,
                        Visual = false,
                        Ghost = true,
                        Silent = true
                    })
                    task.wait(0.003)
                end
                task.wait(interval)
            end
        end)

        -- Control total del objetivo
        task.spawn(function()
            while tick() - start < duration do
                if target:FindFirstChild("Stunned") then target.Stunned.Value = true end
                if target:FindFirstChild("Blocking") then target.Blocking.Value = false end
                if target:FindFirstChild("CantAttack") then target.CantAttack.Value = true end
                if target:FindFirstChild("HumanoidRootPart") then
                    target.HumanoidRootPart.Anchored = true
                    target.HumanoidRootPart.CFrame *= CFrame.new(math.random(-0.2, 0.2), 0, math.random(-0.2, 0.2))
                end
                task.wait(0.08)
            end
            if target:FindFirstChild("HumanoidRootPart") then target.HumanoidRootPart.Anchored = false end
            if target:FindFirstChild("CantAttack") then target.CantAttack.Value = false end
        end)

        -- Anti-predicción
        task.spawn(function()
            while tick() - start < duration do
                if target and target:FindFirstChild("HumanoidRootPart") then
                    target.HumanoidRootPart.CFrame *= CFrame.new(math.random(-0.3,0.3),0,math.random(-0.3,0.3))
                end
                task.wait(0.4)
            end
        end)

        -- Refuerzo de agarre
        task.delay(0.2, function()
            local t0 = tick()
            while tick() - t0 < 1.3 and target and target:FindFirstChild("HumanoidRootPart") do
                grabEvent:FireServer(target)
                task.wait(0.1)
            end
        end)

        -- Remate
        task.delay(duration, function()
            lightPunchEvent:FireServer({
                Target = target,
                Crit = true,
                ForceDamage = true,
                Visual = true,
                Bypass = true,
                BypassHitbox = true,
                Unblockable = true
            })
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

    -- Defensa automática
    runService.Heartbeat:Connect(function()
        local char = player.Character
        if char then
            if char:FindFirstChild("Stunned") then char.Stunned.Value = false end
            if char:FindFirstChild("CantAttack") then char.CantAttack.Value = false end
        end
    end)

    -- Castigo si me agarran
    task.spawn(function()
        while true do
            task.wait(0.1)
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if char and root and root.Anchored then
                for _, model in ipairs(workspace:GetChildren()) do
                    if model:IsA("Model") and model ~= char and model:FindFirstChild("HumanoidRootPart") then
                        local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if dist <= 20 and hum and hum.Health > 0 then
                            task.spawn(function()
                                local t = tick()
                                while tick() - t < 3.5 do
                                    local part = model:FindFirstChild("HumanoidRootPart")
                                    if part then
                                        part.CFrame *= CFrame.Angles(0, math.rad(math.random(-60, 60)), 0)
                                        part.CFrame *= CFrame.new(math.random(-1,1), 0, math.random(-1,1))
                                    end
                                    task.wait(0.08)
                                end
                            end)
                            local freeze = Instance.new("BoolValue", model) freeze.Name = "InputFrozen"
                            local cd = Instance.new("BoolValue", model) cd.Name = "PowerBlocked"
                            local inv = Instance.new("StringValue", model) inv.Name = "DirectionInverted" inv.Value = "true"
                            local tag = Instance.new("StringValue", model) tag.Name = "TeleBacklash" tag.Value = "LagSpike_" .. tostring(os.clock())
                            task.delay(3, function() if freeze.Parent then freeze:Destroy() end end)
                            task.delay(4, function() if cd.Parent then cd:Destroy() end end)
                            task.delay(3, function() if inv.Parent then inv:Destroy() end end)
                            task.delay(2.3, function() if tag.Parent then tag:Destroy() end end)
                            break
                        end
                    end
                end
            end
        end
    end)
end)

if not success then
    warn("⚠️ Error al ejecutar el script: " .. tostring(err))
end
