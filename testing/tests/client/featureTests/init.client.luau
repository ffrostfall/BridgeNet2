local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge: BridgeNet2.TClientBridge<{
	TestField: number,
}> = BridgeNet2.ReferenceBridge("tester")

bridge:OutboundMiddlewares({
	function(obj)
		print("should print every fire")
		return obj
	end,
})

bridge:InboundMiddlewares({
	function(obj)
		print("should print every fire")
		return obj
	end,
})

while true do
	print("firing once")
	bridge:Fire({
		TestField = 5,
	})

	task.wait(1)
end
