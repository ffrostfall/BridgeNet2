local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

BridgeNet2.ReferenceIdentifier("bridge")

BridgeNet2.clientIdentifier(BridgeNet2.FromIdentifier("bridge"))

BridgeNet2.clientConnect(BridgeNet2.FromIdentifier("bridge"), function() end)
