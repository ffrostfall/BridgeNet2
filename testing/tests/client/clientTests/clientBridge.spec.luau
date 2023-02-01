local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

return {
	--[[["should be able to reference the bridge"] = function(tester)
		local expect = tester.expect

		local bridge
		expect(function()
			bridge = BridgeNet2.ReferenceBridge("bridge")
		end).to.never.throw()

		expect(typeof(bridge["_identifier"])).to.equal("string")
	end,
	["should be able to fire the Bridge object"] = function(tester)
		local expect = tester.expect

		local bridge = BridgeNet2.ReferenceBridge("bridge")

		expect(function()
			bridge:Fire({ "successful" })
		end).to.never.throw()
	end,
	["should be able to receive a connection"] = function(tester)
		local expect = tester.expect

		expect(function() end).to.never.throw()
	end,]]
}
