-- 🔗 Servicios base
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local char, root, hum

-- 🔁 Asignar personaje
local function actualizar()
	char = player.Character or player.CharacterAdded:Wait()
	root = char:WaitForChild("HumanoidRootPart")
	hum = char:FindFirstChildOfClass("Humanoid")
end
if player.Character then actualizar() end
player.CharacterAdded:Connect(actualizar)

-- 🛡️ Blindaje físico por frame (anti telekinesis)
RunService.Heartbeat:Connect(function()
	if hum then
		pcall(function()
			for _, estado in {
				Enum.HumanoidStateType.FallingDown,
				Enum.HumanoidStateType.Ragdoll,
				Enum.HumanoidStateType.Physics,
				Enum.HumanoidStateType.PlatformStanding,
				Enum.HumanoidStateType.Seated
			} do hum:SetStateEnabled(estado, false) end
			hum.PlatformStand = false
			hum.Sit = false
			if hum:GetState() == Enum.HumanoidStateType.Ragdoll then
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
			end
		end)
	end
end)

-- 🎬 Cancelación rápida de animaciones Punch
task.spawn(function()
	while true do
		if hum then
			for _, track in hum:GetPlayingAnimationTracks() do
				if track.Animation and track.IsPlaying and string.find(track.Animation.Name, "Punch") then
					pcall(function()
						track:AdjustSpeed(10)
						track:Stop(0.01)
					end)
				end
			end
		end
		task.wait(0.004)
	end
end)

-- ⚔️ FastAttack — agresivo con Anti Macro
task.spawn(function()
	local remote = ReplicatedStorage:FindFirstChild("LightPunchRemote") or ReplicatedStorage:FindFirstChild("LightPunch")
	local cooldowns = {}
	while true do
		if remote and root then
			for _, obj in workspace:GetChildren() do
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				local h = obj:FindFirstChildOfClass("Humanoid")
				if hrp and h and h.Health > 0 and obj ~= char then
					local now = tick()
					if not cooldowns[obj] or now - cooldowns[obj] >= 0.06 then
						cooldowns[obj] = now
						local ghost = now + math.random() * 0.003
						task.defer(function()
							pcall(function()
								remote:FireServer({
									0, 0.1, 1,
									GhostID = ghost,
									Target = hrp,
									Strength = 3,
									Impact = 3
								})
							end)
						end)
					end
				end
			end
		end
		task.wait(0.005)
	end
end)

-- ⚔️ LightPunch — paralelo con Anti Macro
task.spawn(function()
	local remote = ReplicatedStorage:FindFirstChild("LightPunchRemote") or ReplicatedStorage:FindFirstChild("LightPunch")
	local cooldowns = {}
	while true do
		if remote and root then
			for _, obj in workspace:GetChildren() do
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				local h = obj:FindFirstChildOfClass("Humanoid")
				if hrp and h and h.Health > 0 and obj ~= char then
					local now = tick()
					if not cooldowns[obj] or now - cooldowns[obj] >= 0.06 then
						cooldowns[obj] = now
						local ghost = now + math.random() * 0.003
						task.defer(function()
							pcall(function()
								remote:FireServer({
									0, 0.1, 1,
									GhostID = ghost,
									Target = hrp,
									Strength = 3,
									Impact = 3
								})
							end)
						end)
					end
				end
			end
		end
		task.wait(0.006)
	end
end)

-- 🔒 Auto Punch — intacto, ejecuta golpes invisibles por ciclo
task.spawn(function()
	while true do
		if not char or not root then wait(1) continue end
		local punchRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Punch")
		if punchRemote then
			for _, obj in pairs(workspace:GetChildren()) do
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				if obj:IsA("Model") and hrp and obj ~= char then
					local dist = (hrp.Position - root.Position).Magnitude
					if dist >= 1 and dist <= 10 then
						local args = {0, 0.2, 1}
						local extra = {["GhostID"] = tick()}
						pcall(function()
							punchRemote:FireServer(unpack(args))
							wait(0.4)
							punchRemote:FireServer(extra)
						end)
						break
					end
				end
			end
		end
		wait(3.2)
	end
end)

-- 🧲 Telekinesis reforzada — agarre real de 7s, fluido y sin lag
task.spawn(function()
	while true do
		task.wait(0.05)
		if char and root then
			for _, obj in workspace:GetChildren() do
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				local hum = obj:FindFirstChildOfClass("Humanoid")
				if obj:IsA("Model") and hrp and hum and obj ~= char then
					local dist = (hrp.Position - root.Position).Magnitude
					local weld = hrp:FindFirstChildWhichIsA("Weld") or hrp:FindFirstChild("WeldConstraint")
					if dist <= 5 and weld then
						local start = tick()
						while tick() - start < 7 and weld.Parent == hrp and hum.Health > 0 do
							pcall(function()
								hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
								hum:Move(Vector3.zero)
								hum.PlatformStand = true
								for _, track in hum:GetPlayingAnimationTracks() do
									if track.Animation and string.find(track.Animation.Name, "Punch") then
										track:AdjustSpeed(0.01)
										track:Stop(0.05)
									end
								end
							end)
							task.wait(0.05)
						end
						pcall(function()
							hum.PlatformStand = false
							hum:ChangeState(Enum.HumanoidStateType.GettingUp)
						end)
					end
				end
			end
		end
	end
end)
