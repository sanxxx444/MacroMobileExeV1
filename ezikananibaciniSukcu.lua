local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local replicated = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")

local punchEvent
local cs = player:FindFirstChild("ClientStorage") or game:FindFirstChild("ClientStorage")
if cs and cs:FindFirstChild("Events") then
	punchEvent = cs.Events:FindFirstChild("Punch")
end
if not punchEvent then
	punchEvent = replicated:FindFirstChild("Punch")
end
if not punchEvent then return end

-- 📡 Detectar enemigo a ≤15 studs
local function hayEnemigoCerca()
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end

	for _, obj in workspace:GetChildren() do
		if obj:IsA("Model") and obj ~= player.Character then
			local hum = obj:FindFirstChildOfClass("Humanoid")
			local hrp = obj:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= 15 then
				return true
			end
		end
	end

	for _, p in players:GetPlayers() do
		if p ~= player then
			local c = p.Character
			local hum = c and c:FindFirstChildOfClass("Humanoid")
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hum and hrp and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= 15 then
				return true
			end
		end
	end

	return false
end

-- ☝️ Ejecutar combo con toque
uis.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not hayEnemigoCerca() then return end

	task.spawn(function()
		local combo = {
			"light","light","extra","light",
			"normal","light","extra","light",
			"normal","extra","light","normal",
			"extra","light","normal","extra",
			"light" -- El golpe 18 va abajo con lógica crítica
		}

		for _, tipo in ipairs(combo) do
			task.wait(0.25)
			task.defer(function()
				if punchEvent then
					local tipoReal = (tipo == "extra") and "Extra" or "Melee"
					pcall(function()
						punchEvent:FireServer(tipoReal)
					end)
				end
			end)
		end

		-- 🧨 Golpe 18: solo "Extra" si el enemigo moriría con el crítico
		task.wait(0.25)
		task.defer(function()
			if not punchEvent then return end
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if not root then return end

			local estimatedExtraDamage = 35 -- Ajustá si sabés cuánto pega el "Extra"
			local objetivoFinal

			for _, obj in workspace:GetChildren() do
				if obj:IsA("Model") and obj ~= player.Character then
					local hum = obj:FindFirstChildOfClass("Humanoid")
					local hrp = obj:FindFirstChild("HumanoidRootPart")
					if hum and hrp and hum.Health > 0 and (hrp.Position - root.Position).Magnitude <= 15 then
						if hum.Health <= estimatedExtraDamage then
							objetivoFinal = true
							break
						end
					end
				end
			end

			pcall(function()
				punchEvent:FireServer(objetivoFinal and "Extra" or "Melee")
			end)
		end)
	end)
end)
