local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge: BridgeNet2.TServerBridge<{
	TestField: number,
}> = BridgeNet2.ReferenceBridge("tester")

bridge:Connect(function()
	print("this should only print once")
	return
end)

bridge:RateLimit(1, function(player)
	print(player)
end)
