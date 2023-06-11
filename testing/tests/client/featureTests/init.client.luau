local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")

bridge:Connect(function(object)
	print(object.TestField)
end)

bridge.Logging = true

while true do
	bridge:Fire()
	bridge:Fire()
	bridge:Fire({
		"teststststst",
	})
	bridge:Fire(555)
	bridge:Fire(true)
	bridge:Fire({ tteeee = 5 })
	bridge:Fire(nil)
	bridge:Fire(CFrame.new(500, 500, 500))
	task.wait(1)
end
