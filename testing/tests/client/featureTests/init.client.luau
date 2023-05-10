local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

bridge:StartLogging()

bridge:OutboundMiddleware({
	function(obj)
		print("should print every fire")
		return obj
	end,
})

bridge:InboundMiddleware({
	function(obj)
		print("should print every receive")
		return obj
	end,
})

bridge:Connect(function(object)
	print(object.TestField)
end)

while true do
	bridge:Fire({
		TestField = "server pass",
	})

	task.wait(1)
end
