local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

local intervalo = 0.03 -- ⏱️ Frecuencia segura permitida
local RemoteFire = ReplicatedStorage:FindFirstChild("LightPunchRemote") or ReplicatedStorage:FindFirstChild("LightPunch")

RunService.RenderStepped:Connect(function()
	if not RemoteFire or not RemoteFire:IsA("RemoteEvent") then return end
	if not char or not root or not player then return end

	local target, closestDist = nil, math.huge

	for _, obj in workspace:GetChildren() do
		local hrp = obj:FindFirstChild("HumanoidRootPart")
		if obj:IsA("Model") and hrp and obj ~= char then
			local dist = (hrp.Position - root.Position).Magnitude
			if dist <= 10 and dist < closestDist then
				closestDist = dist
				target = obj
			end
		end
	end

	if target then
		for i = 1, 3 do
			task.spawn(function()
				pcall(function()
					RemoteFire:FireServer(target)
				end)
			end)
			task.wait(0.01) -- 🧨 Micro delay entre golpes
		end
	end

	task.wait(intervalo)
end)
