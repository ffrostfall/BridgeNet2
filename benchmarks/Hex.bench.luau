--!optimize 2
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local alphabet = "abcdefghijklmnopqrstuvwxyz"
local hexAlphabet = BridgeNet2.ToHex(alphabet)

return {
	ParameterGenerator = function()
		return
	end,

	Functions = {
		["ToHex"] = function() -- You can change "Sample A" to a descriptive name for your function
			BridgeNet2.ToHex(alphabet)
		end,

		["FromHex"] = function()
			BridgeNet2.FromHex(hexAlphabet)
		end,

		["ToReadableHex"] = function()
			BridgeNet2.ToReadableHex(alphabet)
		end,

		["CreateUUID"] = function()
			BridgeNet2.CreateUUID()
		end,
		-- You can add as many functions as you like!
	},
}
