local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local bridge = BridgeNet2.ReferenceBridge("tester")
local bridge2 = BridgeNet2.ServerBridge("tester2")

local t = BridgeNet2.ReferenceBridge("test")

bridge2.OnServerInvoke = function(plr, content)
	print(plr)
	print(content)
	return "Reply"
end

t:Connect(function(_, _) end)

--[[bridge
	:Connect(function()
		print("should never print")
	end)
	:Disconnect()]]

--[[bridge:Once(function()
	print("should print once")
end)]]

bridge.Logging = true

bridge2:Connect(function(_, data)
	print(data)
end)

bridge:Connect(function(_, data)
	print(data)
end)

task.wait(1)

while true do
	local plr = Players:GetPlayers()[1]
	bridge:Fire(plr, 1)
	bridge2:Fire(plr, 2)
	bridge:Fire(plr, 3)
	bridge2:Fire(plr, 4)
	task.wait(1)
end
