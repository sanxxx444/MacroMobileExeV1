local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- 👊 LightMacro — Golpe táctil con intervalo mínimo
local intervalo = 0.03

UIS.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local lpRemote = ReplicatedStorage:FindFirstChild("LightPunchRemote") or ReplicatedStorage:FindFirstChild("LightPunch")
		if lpRemote and lpRemote:IsA("RemoteEvent") then
			for _, obj in pairs(workspace:GetChildren()) do
				local hrp = obj:FindFirstChild("HumanoidRootPart")
				if obj:IsA("Model") and hrp and obj ~= char and (hrp.Position - root.Position).Magnitude <= 10 then
					task.spawn(function()
						local extra = {["GhostID"] = tick()}
						pcall(function()
							lpRemote:FireServer(obj, extra)
						end)
					end)
					wait(intervalo) -- ⚡ Pausa mínima entre impactos
					break
				end
			end
		end
	end
end)
