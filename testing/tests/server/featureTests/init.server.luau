local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

bridge:StartLogging()

task.wait(5)

bridge
	:Connect(function()
		print("should never print")
	end)
	:Disconnect()

bridge:Once(function()
	print("should print once")
end)

print(bridge:Wait())

while true do
	--[[bridge:Fire(BridgeNet2.PlayersExcept({ Players:GetPlayers()[2] }), {
		TestField = "PlayersExcept pass",
	})]]

	bridge:Fire(BridgeNet2.Players({ Players:GetPlayers()[1] }), {
		TestField = "Players pass",
	})

	bridge:Fire(Players:GetPlayers()[1], {
		TestField = "Player pass",
	})

	task.wait(1)
end
