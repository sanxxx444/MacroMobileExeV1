-- ✅ Delta-Compatible Punch Macro
local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")

-- 🔍 Buscar RemoteEvent de golpe
local punchEvent = nil
for _, obj in pairs(replicatedStorage:GetDescendants()) do
	if obj:IsA("RemoteEvent") and obj.Name:lower():find("punch") then
		punchEvent = obj
		break
	end
end

if punchEvent then
	print("✅ Macro activada: Golpes instantáneos en Delta.")

	-- 🧪 Activación por toque o clic
	userInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			task.spawn(function()
				for _ = 1, 5 do
					punchEvent:FireServer()
					task.wait(0.01)
				end
			end)
		end
	end)
else
	warn("⚠️ No se encontró ningún RemoteEvent de tipo 'Punch' en ReplicatedStorage.")
end
