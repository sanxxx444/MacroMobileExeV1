local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local UserInputService = game:GetService("UserInputService")

local tapActive = false
local lastHits = {}
local ignoredTargets = {}

-- 🎮 Detectar toque manual
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		tapActive = true
		task.delay(0.4, function()
			tapActive = false
		end)
	end
end)

-- 🛡️ AntiMacro — bloqueo de enemigos que spamean golpes
function registerHit(target)
	local now = tick()
	lastHits[target] = lastHits[target] or {}
	table.insert(lastHits[target], now)
	for i = #lastHits[target], 1, -1 do
		if now - lastHits[target][i] > 0.5 then table.remove(lastHits[target], i) end
	end
	if #lastHits[target] >= 3 and not ignoredTargets[target] then
		ignoredTargets[target] = true
		task.delay(2, function() ignoredTargets[target] = nil end)
	end
end

-- ⚔️ FastAttack Twin — 2 golpes tras tu toque
spawn(function()
	while wait(0.01) do
		if tapActive then
			for _, obj in pairs(workspace:GetChildren()) do
				if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= player.Name then
					local dist = (obj.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
					if dist <= 9 and not ignoredTargets[obj] then
						local remote = game:GetService("ReplicatedStorage"):FindFirstChild("LightPunch")
						if remote then
							for i = 0, 1 do
								task.delay(i * 0.03, function()
									registerHit(obj)
									pcall(function()
										remote:FireServer(obj)
									end)
								end)
							end
						end
						break
					end
				end
			end
		end
	end
end)

-- 🔁 ConstantStrike — fuego continuo cada 0.07 s si hay target cercano
spawn(function()
	while wait(0.07) do
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= player.Name then
				local dist = (obj.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
				if dist <= 30 and not ignoredTargets[obj] then
					registerHit(obj)
					local punchEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Punch")
					if punchEvent then
						pcall(function()
							punchEvent:FireServer(true, 0.25, 2)
						end)
					end
					break
				end
			end
		end
	end
end)

-- 📦 LightPunchMacro — golpe táctico cada 0.3 s con flags
spawn(function()
	while wait(0.3) do
		local punchEvent = game:GetService("ReplicatedStorage"):FindFirstChild("Punch")
		if punchEvent then
			pcall(function()
				punchEvent:FireServer(true, 0.25, 2)
			end)
		end
	end
end)

-- 🌀 AutoPunch — doble impacto cada 1.2 s al target más cercano
spawn(function()
	while wait(1.2) do
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= player.Name then
				local dist = (obj.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
				if dist <= 30 and not ignoredTargets[obj] then
					registerHit(obj)
					local remote = game:GetService("ReplicatedStorage"):FindFirstChild("LightPunch")
					if remote then
						for i = 0, 1 do
							task.delay(i * 0.12, function()
								pcall(function()
									remote:FireServer(obj)
								end)
							end)
						end
					end
					break
				end
			end
		end
	end
end)

-- ⚡ Rapid Proxima Twin — fuego automático al acercarse (2 golpes)
spawn(function()
	while wait(0.03) do
		for _, obj in pairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj:FindFirstChild("HumanoidRootPart") and obj.Name ~= player.Name then
				local dist = (obj.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
				if dist <= 10 then
					local remote = game:GetService("ReplicatedStorage"):FindFirstChild("LightPunch")
					if remote then
						for i = 0, 1 do
							task.delay(i * 0.03, function()
								pcall(function()
									remote:FireServer(obj)
								end)
							end)
						end
					end
					break
				end
			end
		end
	end
end)
