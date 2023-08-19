local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")
local bridge2 = BridgeNet2.ReferenceBridge("tester2")

bridge.Logging = true

bridge:Connect(function(data)
	print(data)
end, "test")

bridge2:Connect(function(data)
	print(data)
end, "test")

while true do
	print(bridge2:InvokeServerAsync({ "Hello!" }))
	task.wait(1)
end
