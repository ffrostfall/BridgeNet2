local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge: BridgeNet2.TServerBridge<{
	TestField: string,
}> = BridgeNet2.ReferenceBridge("tester")

bridge:Connect(function()
	print("this should only print once")
	return
end)

bridge:RateLimit(1, function(player)
	print(player)
end)

task.wait(5)

--while true do
bridge:Fire(BridgeNet2.PlayersExcept({ Players:GetPlayers()[2] }), {
	TestField = "PlayersExcept pass",
})

bridge:Fire(BridgeNet2.Players({ Players:GetPlayers()[1] }), {
	TestField = "Players pass",
})
--end
