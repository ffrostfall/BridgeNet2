local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

return {
	["should create a Bridge object"] = function(tester)
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
			bridge:Fire(BridgeNet2.AllPlayers(), { "successful" })
		end).to.never.throw()
	end,
	["should be able to connect, and eventually receive a firing"] = function(tester)
		local expect = tester.expect

		local thisThread = coroutine.running()

		local bridge = BridgeNet2.ReferenceBridge("bridge")

		bridge:Connect(function(player, successful)
			coroutine.resume(thisThread, player, successful)
		end)
		local player, successful = coroutine.yield()
		expect(successful[1]).to.equal("successful")
		expect(player).to.equal(Players:GetPlayers()[1])
	end,
	["rate limiting should work and set the corret values"] = function(tester)
		local expect = tester.expect

		local bridge = BridgeNet2.ReferenceBridge("bridge")

		expect(function()
			bridge:RateLimit(2, function(player)
				
			end)
		end).to.never.throw()
	end,
}
