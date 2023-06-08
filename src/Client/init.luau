--!strict
local ClientBridge = require(script.ClientBridge)
local ClientIdentifiers = require(script.ClientIdentifiers)
local ClientProcess = require(script.ClientProcess)
local Types = require(script.Parent.Types)

local Client = {}

function Client.start()
	ClientProcess.start()
	ClientIdentifiers.start()
end

function Client.ser(identifierName: Types.Identifier): Types.Identifier?
	return ClientIdentifiers.ser(identifierName)
end

function Client.deser(compressedIdentifier: Types.Identifier): Types.Identifier?
	return ClientIdentifiers.deser(compressedIdentifier)
end

function Client.makeIdentifier(name: string, timeout: number?)
	return ClientIdentifiers.ref(name, timeout)
end

function Client.makeBridge(name: string)
	return ClientBridge(name)
end

return Client
