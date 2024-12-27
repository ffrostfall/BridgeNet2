if _G.__testmode__ == "benchmark" then
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local serverProcess = require("@src/server/process")

serverProcess.addEvent(1)
serverProcess.connect(1, print)

while true do
	serverProcess.fireAll(1, "testing")

	task.wait(1)
end
