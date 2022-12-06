local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local test: BridgeNet2.ClientBridge<{ number }> = BridgeNet2.ReferenceBridge("Test")

print(test)

test:Connect(function(obj)
	print(obj)
end)

while true do
	test:Fire({
		os.clock(),
	})
	ReplicatedStorage.RemoteEvent:FireServer(os.clock())
	task.wait(1)
end
