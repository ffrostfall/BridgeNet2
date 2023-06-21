local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local TestType: StringValue = ReplicatedStorage:WaitForChild("StressTestValue") :: StringValue

if TestType.Value == "roblox" then
	local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent") :: RemoteEvent

	RemoteEvent.OnClientEvent:Connect(function()
		debug.profilebegin("ack")
		debug.profileend()
	end)
elseif TestType.Value == "bridgenet2" then
	local Bridge = BridgeNet2.ReferenceBridge("test")

	Bridge:Connect(function(_, _)
		debug.profilebegin("ack")
		debug.profileend()
	end)
end
