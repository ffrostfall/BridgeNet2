local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local test: BridgeNet2.ServerBridge<{}> = BridgeNet2.ReferenceBridge("Test")

print(test)

test:Connect(function(plr, obj)
	print(plr, os.clock() - obj[1])
end)

ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(plr, tim)
	print(os.clock() - tim)
end)

while true do
	test:Fire(BridgeNet2.AllPlayers(), {})
	task.wait(1)
end
