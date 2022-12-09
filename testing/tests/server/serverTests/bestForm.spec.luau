local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

return {
	["number less than 7 characters should be string"] = function(tester)
		local expect = tester.expect

		local shouldBeString
		expect(function()
			shouldBeString = BridgeNet2.NumberToBestForm(100000)
		end).to.never.throw()

		expect(typeof(shouldBeString)).to.equal("string")
	end,
	["numbers over 7 characters should be number"] = function(tester)
		local expect = tester.expect

		local shouldBeNumber
		expect(function()
			shouldBeNumber = BridgeNet2.NumberToBestForm(100000000)
		end).to.never.throw()

		expect(typeof(shouldBeNumber)).to.equal("number")
	end,
}
