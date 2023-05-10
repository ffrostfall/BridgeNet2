local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

bridge:StartLogging()

bridge:RateLimit(1, function(player)
	print(player)
end)

task.wait(5)

bridge:Connect(function() end):Disconnect()

bridge:Once(function(_, object)
	print(object)
end)

print(bridge:Wait())

while true do
	bridge:Fire(BridgeNet2.PlayersExcept({ Players:GetPlayers()[2] }), {
		TestField = "PlayersExcept pass",
	})

	bridge:Fire(BridgeNet2.Players({ Players:GetPlayers()[1] }), {
		TestField = "Players pass",
	})

	bridge:Fire(Players:GetPlayers()[1], {
		TestField = "Players pass",
	})
end
