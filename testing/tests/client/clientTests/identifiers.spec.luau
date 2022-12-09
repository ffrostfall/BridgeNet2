local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

return {
	["identifiers should be replicated without need for reference"] = function(tester)
		local expect = tester.expect

		local unique = BridgeNet2.FromIdentifier("unique")

		expect(unique).to.never.equal(nil)
		expect(#unique).to.equal(1)
	end,
	["identifiers should be replicated"] = function(tester)
		local expect = tester.expect

		local unique = BridgeNet2.ReferenceIdentifier("unique", 3)

		expect(#unique).to.equal(1)
	end,
}
