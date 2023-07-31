--!strict
local ClientBridge = require(script.ClientBridge)
local ClientIdentifiers = require(script.ClientIdentifiers)
local ClientProcess = require(script.ClientProcess)
local Types = require(script.Parent.Types)
local isEditMode = require(script.Parent.Utilities.isEditMode)

local activeBridges = {}

local Client = {}

function Client.start()
	if isEditMode then
		return
	end

	ClientProcess.start()
	ClientIdentifiers.start()
end

function Client.ser(identifierName: Types.Identifier): Types.Identifier?
	if isEditMode then
		return identifierName
	end

	return ClientIdentifiers.ser(identifierName)
end

function Client.deser(compressedIdentifier: Types.Identifier): Types.Identifier?
	if isEditMode then
		return compressedIdentifier
	end

	return ClientIdentifiers.deser(compressedIdentifier)
end

function Client.makeIdentifier(name: string, timeout: number?)
	if isEditMode then
		return name
	end

	return ClientIdentifiers.ref(name, timeout, false)
end

function Client.makeBridge(name: string)
	if activeBridges[name] then
		return activeBridges[name]
	else
		local bridge = ClientBridge(name)

		activeBridges[name] = bridge

		return bridge
	end
end

return Client
