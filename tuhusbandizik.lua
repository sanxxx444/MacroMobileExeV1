local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local clientStorage = player:FindFirstChild("ClientStorage") or game:FindFirstChild("ClientStorage")
local runService = game:GetService("RunService")

if clientStorage then
    local events = clientStorage:FindFirstChild("Events")
    if events then
        local punchEvent = events:FindFirstChild("Punch")
        if punchEvent then
            -- Solo imprimir una vez para confirmar que la macro está activada
            print("✅ Macro activada: Golpes instantáneos.")

            userInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end  

                -- Verificar si es un toque o clic
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then  
                    -- Usar Heartbeat para enviar los golpes
                    task.spawn(function()
                        for _ = 1, 5 do  
                            punchEvent:FireServer()  -- Enviar golpe
                        end
                    end)
                end
            end)
        else
            print("⚠️ No se encontró el evento Punch en ClientStorage/Events.")
        end
    else
        print("⚠️ No se encontró Events dentro de ClientStorage.")
    end
else
    print("⚠️ No se encontró ClientStorage en el jugador ni en el juego.")
end
