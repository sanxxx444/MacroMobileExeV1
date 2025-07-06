local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local grabEvent = replicatedStorage:FindFirstChild("TelekinesisGrab")
local releaseEvent = replicatedStorage:FindFirstChild("TelekinesisRelease")
local clientStorage = player:FindFirstChild("ClientStorage")
local events = clientStorage and clientStorage:FindFirstChild("Events")
local lightPunchEvent = events and events:FindFirstChild("LightPunch")

-- 🔍 Encuentra al enemigo más cercano
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

-- 💥 Activar telekinesis con ráfagas inteligentes
local function startTelekinesisSystem(target)
    if not (grabEvent and releaseEvent and lightPunchEvent and target) then return end
    local start = tick()
    local duration = 6
    local interval = 0.6
    local totalBursts = math.floor(duration / interval)
    local currentBurst = 0

    -- 🌀 Mantener agarre activo
    task.spawn(function()
        while tick() - start < duration do
            grabEvent:FireServer(target)
            task.wait(0.15)
        end
    end)

    -- ⚔️ Ráfagas de 3 con chance de 4, y última ráfaga con 4 garantizados
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
                task.wait(0.03)
            end

            task.wait(interval)
        end
    end)

    -- 🔒 Control del objetivo (sin defensa ni ataque)
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

    -- ⏳ Soltar agarre después de 6 s
    task.delay(duration, function()
        releaseEvent:FireServer(target)
    end)
end

-- 📱 Activación con doble toque
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

-- 🛡️ Protección personal (antistun + bypass continuo)
runService.Heartbeat:Connect(function()
    local char = player.Character
    if char then
        if char:FindFirstChild("Stunned") then
            char.Stunned.Value = false
        end
        if char:FindFirstChild("CantAttack") then
            char.CantAttack.Value = false
        end
        local tag = Instance.new("BoolValue")
        tag.Name = "BypassDefense"
        tag.Parent = char
        task.delay(0.1, function() tag:Destroy() end)
    end
end)

-- 😈 Defensa caótica si te agarran (evasión visual + saboteo enemigo)
task.spawn(function()
    while true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if char and root and root.Anchored then
            root.CFrame *= CFrame.new(math.random(-0.5, 0.5), 0, math.random(-0.5, 0.5))
            for _, model in ipairs(workspace:GetChildren()) do
                if model:IsA("Model") and model ~= char and model:FindFirstChild("HumanoidRootPart") then
                    local dist = (model.HumanoidRootPart.Position - root.Position).Magnitude
                    if dist <= 12 then
                        if model:FindFirstChild("Blocking") then
                            model.Blocking.Value
