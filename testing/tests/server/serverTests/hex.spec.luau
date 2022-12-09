local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local theAlphabet = "abcdefghijklmnopqrstuvwxyz"
local theAlphabetStartingAtG = "ghijklmnopqrstuvwxyz"

return {
	["toHex should be hexadecimal"] = function(tester)
		local expect = tester.expect

		local hexadecimal = BridgeNet2.ToHex(theAlphabet)

		local invalidHex = false
		for i = 1, #theAlphabetStartingAtG do
			local character = string.sub(theAlphabetStartingAtG, i, i)

			if string.find(hexadecimal, character) then
				invalidHex = true
			end
		end

		expect(invalidHex).to.equal(false)
	end,
	["fromHex should be ascii"] = function(tester)
		local expect = tester.expect

		local lengthOfAlphabet = #theAlphabet
		local hexadecimal = BridgeNet2.ToHex(theAlphabet)
		local ascii = BridgeNet2.FromHex(hexadecimal)

		expect(#ascii).to.equal(lengthOfAlphabet)
	end,
	["toReadableHex should contain spaces"] = function(tester)
		local expect = tester.expect

		local readableHex = BridgeNet2.ToReadableHex(theAlphabet)

		expect(string.find(readableHex, " "))
	end,
}
