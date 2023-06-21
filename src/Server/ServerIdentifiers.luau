--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Constants = require(script.Parent.Parent.Constants)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)

local ServerIdentifiers = {}

local identifierCount: number = 0
local fullIdentifierMap = {}
local compressedIdentifierMap = {}
local identifierStorage: Folder

function ServerIdentifiers.start()
	identifierStorage = Instance.new("Folder")
	identifierStorage.Name = "identifierStorage"
	identifierStorage.Parent = ReplicatedStorage

	ServerIdentifiers.ref("NIL_VALUE")
	ServerIdentifiers.ref("REQUEST")
end

function ServerIdentifiers.ref(identifierName: string): Types.Identifier
	if RunService:IsStudio() then
		fullIdentifierMap[identifierName] = identifierName
		compressedIdentifierMap[identifierName] = identifierName
		return identifierName
	end

	if fullIdentifierMap[identifierName] ~= nil then
		return fullIdentifierMap[identifierName]
	end

	Output.fatalAssert(
		identifierCount <= Constants.IDENTIFIER_CAP,
		`cannot create any more identifiers - over {Constants.IDENTIFIER_CAP_STRING} cap.`
	)
	Output.silent(`creating identifier: {identifierName}, identifier count: {identifierCount + 1}`)

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
