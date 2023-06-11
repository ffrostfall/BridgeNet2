local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

local t = BridgeNet2.ReferenceBridge("test")

t:Connect(function(_, _) end)

--[[bridge
	:Connect(function()
		print("should never print")
	end)
	:Disconnect()]]

--[[bridge:Once(function()
	print("should print once")
end)]]

bridge:Connect(function()
	--print(plr)
	--print(data)
end)

bridge.Logging = true

task.wait(1)

while true do
	--[[bridge:Fire(BridgeNet2.PlayersExcept({ Players:GetPlayers()[2] }), {
		TestField = "PlayersExcept pass",
	})]]

	bridge:Fire(BridgeNet2.Players({ Players:GetPlayers()[1] }), {
		TestField = "Players pass",
	})

	--[[bridge:Fire(Players:GetPlayers()[1], {
		TestField = "Player pass",
	})]]

	task.wait(1)
end
