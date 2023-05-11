local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

bridge:StartLogging()

bridge:Connect(function(object)
	print(object.TestField)
end)

while true do
	bridge:Fire({
		TestField = "server pass",
	})

	task.wait(1)
end
