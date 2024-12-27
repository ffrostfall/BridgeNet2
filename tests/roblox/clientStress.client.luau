if _G.__testmode__ ~= "benchmark" then
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local _BridgeNet2 = require(ReplicatedStorage.Packages.BridgeNet2)
local clientProcess = require("@src/client/process")

clientProcess.registerEvent(1)

clientProcess.connect(1, function(data) end)
