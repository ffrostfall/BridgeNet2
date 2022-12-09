local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

return {
	["making an identifier should produce a 1-char string"] = function(tester)
		local expect = tester.expect

		local identifier = BridgeNet2.ReferenceIdentifier("unique")

		expect(#identifier).to.equal(1)
	end,
	["getting the compressed version from the name should return the compressed version"] = function(tester)
		BridgeNet2.ReferenceIdentifier("test")
		local expect = tester.expect

		local compressed = BridgeNet2.FromIdentifier("test")

		expect(#compressed).to.equal(1)
	end,
	["getting the full version from the compressed version should return the full version"] = function(tester)
		BridgeNet2.ReferenceIdentifier("test")
		local expect = tester.expect

		local compressed = BridgeNet2.FromIdentifier("test")
		local full = BridgeNet2.FromCompressed(compressed)

		expect(full).to.equal("test")
	end,
}
