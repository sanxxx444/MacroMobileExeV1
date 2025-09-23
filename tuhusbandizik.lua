local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local clientStorage = player:FindFirstChild("ClientStorage") or game:FindFirstChild("ClientStorage")

if clientStorage then
    local events = clientStorage:FindFirstChild("Events")
    if events then
        local punchEvent = events:FindFirstChild("Punch")
        if punchEvent then
            print("✅ Macro activada: Ráfagas paralelas ultra-agresivas sin límites.")

            userInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end

                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    -- Lanzar ráfagas simultáneas en paralelo
                    for _ = 1, 3 do  -- 3 ráfagas por input
                        task.spawn(function()
                            local burstid = tostring(math.random(100000,999999))
                            for _ = 1, 6 do  -- 6 golpes por ráfaga (ajustable)
                                punchEvent:FireServer(burstid)
                            end
                        end)
                    end
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
