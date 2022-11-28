local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

BridgeNet2.ReferenceIdentifier("bridge")

BridgeNet2.serverIdentifier(BridgeNet2.FromIdentifier("bridge"))

RunService.Heartbeat:Connect(function()
	for i = 1, 200 do
		BridgeNet2.serverAddToQueue(BridgeNet2.AllPlayers(), BridgeNet2.FromIdentifier("bridge"), {})
	end
end)
