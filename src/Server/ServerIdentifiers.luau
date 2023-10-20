--!strict
local Constants = require(script.Parent.Parent.Constants)
local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)

local ServerIdentifiers = {}

local identifierCount: number = 0
local fullIdentifierMap = {}
local compressedIdentifierMap = {}
local identifierStorage: Folder

function ServerIdentifiers.start()
	local potentialIdentifierStorage = wallyInstanceManager.get(script.Parent.Parent.Parent, "identifierStorage")
	if potentialIdentifierStorage then
		identifierStorage = potentialIdentifierStorage
	else
		identifierStorage = Instance.new("Folder")
		identifierStorage.Name = "identifierStorage"
		wallyInstanceManager.add(script.Parent.Parent.Parent, identifierStorage)
	end

	ServerIdentifiers.ref("NIL_VALUE")
	ServerIdentifiers.ref("REQUEST")
end

function ServerIdentifiers.ref(identifierName: string): Types.Identifier
	if fullIdentifierMap[identifierName] ~= nil then
		return fullIdentifierMap[identifierName]
	end

	Output.fatalAssert(
		identifierCount <= Constants.IDENTIFIER_CAP,
		`cannot create any more identifiers - over {Constants.IDENTIFIER_CAP_STRING} cap.`
	)

	-- optimization for under 255 identifiers
	local packed = if identifierCount <= 255
		then string.pack("B", identifierCount)
		else string.pack("H", identifierCount)

	identifierCount += 1
	identifierStorage:SetAttribute(identifierName, packed)

	fullIdentifierMap[identifierName] = packed
	compressedIdentifierMap[packed] = identifierName

	return packed
end

function ServerIdentifiers.deser(compressedIdentifier: Types.Identifier): Types.Identifier?
	Output.fatalAssert(
		typeof(compressedIdentifier) == "string",
		string.format("Deserialize takes string, got %*", typeof(compressedIdentifier))
	)
	return compressedIdentifierMap[compressedIdentifier]
end

function ServerIdentifiers.ser(identifierName: Types.Identifier): Types.Identifier?
	Output.fatalAssert(
		typeof(identifierName) == "string",
		string.format("Serialize takes string, got %*", typeof(identifierName))
	)
	return fullIdentifierMap[identifierName]
end

return ServerIdentifiers
