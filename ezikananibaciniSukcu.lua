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

    -- Estado de protección durante ataque
    local invulnerable = false
    local modeFuria = false

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
        local totalHits = 17
        local interval = 0.17

        invulnerable = true
        task.delay(duration, function() invulnerable = false end)

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local boosted = root and root.Anchored
        if boosted then interval /= 1.4 end

        if not boosted and target and target:FindFirstChild("CantAttack") then
            target.CantAttack.Value = true
        end

        -- Golpes principales
        task.spawn(function()
            for i = 1, totalHits do
                if target and target:FindFirstChild("HumanoidRootPart") then
                    local crit = (i == 1 or i == totalHits)
                    lightPunchEvent:FireServer({
                        Target = target,
                        IgnoreDefense = true,
                        Bypass = true,
                        BypassHitbox = true,
                        Unblockable = true,
                        ForceDamage = true,
                        Crit = crit,
                        Visual = false
                    })
                end
                task.wait(interval)
            end
        end)

        -- Triple ghost punch
        task.spawn(function()
            for _ = 1, totalHits do
                for _ = 1, 3 do
                    lightPunchEvent:FireServer({
                        Target = target,
                        IgnoreDefense = true,
                        Bypass = true,
                        BypassHitbox = true,
                        Unblockable = true,
                        ForceDamage = true,
                        Crit = false,
                        Ghost = true,
                        Silent = true,
                        Visual = false
                    })
                    task.wait(0.0015)
                end
                task.wait(interval)
            end
        end)

        -- Extras invisibles
        task.spawn(function()
            while tick() - start < duration do
                lightPunchEvent:FireServer({
                    Target = target,
                    IgnoreDefense = true,
                    Bypass = true,
                    BypassHitbox = true,
                    Unblockable = true,
                    ForceDamage = true,
                    Ghost = true,
                    Silent = true,
                    Visual = false,
                    Extra = true,
                    Id = tostring(math.random(100000,999999))
                })
                task.wait(0.025)
            end
        end)

        -- Control total del enemigo
        task.spawn(function()
            while tick() - start < duration do
                if target:FindFirstChild("Stunned") then target.Stunned.Value = true end
                if target:FindFirstChild("Blocking") then target.Blocking.Value = false end
                if target:FindFirstChild("CantAttack") then target.CantAttack.Value = true end
                if target:FindFirstChild("HumanoidRootPart") then
                    target.HumanoidRootPart.Anchored = true
                    target.HumanoidRootPart.CFrame *= CFrame.new(math.random(-0.2,0.2), 0, math.random(-0.2,0.2))
                end
                task.wait(0.08)
            end
            if target:FindFirstChild("HumanoidRootPart") then target.HumanoidRootPart.Anchored = false end
            if target:FindFirstChild("CantAttack") then target.CantAttack.Value = false end
        end)

        -- Levitación aleatoria
        task.spawn(function()
            while tick() - start < duration do
                if target and target:FindFirstChild("HumanoidRootPart") then
                    target.HumanoidRootPart.CFrame *= CFrame.new(math.random(-0.3,0.3), 0, math.random(-0.3,0.3))
                end
                task.wait(0.4)
            end
        end)

        -- Agarre reforzado
        task.delay(0.2, function()
            local t0 = tick()
            while tick() - t0 < 1.3 and target and target:FindFirstChild("HumanoidRootPart") do
                grabEvent:FireServer(target)
                task.wait(0.1)
            end
        end)

        -- Golpe final + release
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

    -- Activación táctil
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

    -- Defensa y modo furia
    runService.Heartbeat:Connect(function()
        local char = player.Character
        if char then
            if char:FindFirstChild("Stunned") then char.Stunned.Value = false end
            if char:FindFirstChild("CantAttack") then char.CantAttack.Value = false end

            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Anchored then
                -- Defensa evasiva mientras estás anclado
                hrp.CFrame *= CFrame.Angles(0, math.rad(math.random(-5,5)), 0)
                hrp.CFrame *= CFrame.new(math.random(-0.4,0.4), 0, math.random(-0.4,0.4))

                -- Contraataque automático (modo furia)
                if not modeFuria then
                    modeFuria = true
                    for i = 1, 40 do
                        lightPunchEvent:FireServer({
                            Target = nil,
                            ForceDamage = true,
                            Crit = true,
                            Ghost = true,
                            Silent = true,
                            Visual = false,
                            IgnoreDefense = true,
                            Unblockable = true,
                            Bypass = true,
                            BypassHitbox = true
                        })
                        task.wait(0.01)
                    end
                    task.delay(3, function() modeFuria = false end)
                end
            end
        end
    end)
end)

if not success then
    warn("⚠️ Error al ejecutar el script: " .. tostring(err))
end
