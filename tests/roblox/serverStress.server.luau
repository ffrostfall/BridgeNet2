if _G.__testmode__ ~= "benchmark" then
	return
end

print("running stress test")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local _BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local serverProcess = require("@src/server/process")

serverProcess.addEvent(1)
serverProcess.connect(1, print)

RunService.Heartbeat:Connect(function()
	debug.profilebegin("benchmark")
	for i = 1, 200 do
		serverProcess.fireAll(1, "")
	end
	debug.profileend()
end)
