--!strict
local Types = require(script.Parent.Types)
local isEditMode = require(script.Parent.Utilities.isEditMode)
local PlayerContainers = require(script.PlayerContainers)
local ServerBridge = require(script.ServerBridge)
local ServerIdentifiers = require(script.ServerIdentifiers)
local ServerProcess = require(script.ServerProcess)

local activeBridges = {}

local Server = {}

function Server.start()
	if isEditMode then
		return
	end

	ServerIdentifiers.start()
	ServerProcess.start()
end

function Server.makeBridge(name: string)
	if activeBridges[name] then
		return activeBridges[name]
	else
		local bridge = ServerBridge(name)

		activeBridges[name] = bridge

		return bridge
	end
end

function Server.ser(identifierName: string): Types.Identifier?
	return ServerIdentifiers.ser(identifierName)
end

function Server.deser(compressedIdentifier: string): Types.Identifier?
	return ServerIdentifiers.deser(compressedIdentifier)
end

function Server.makeIdentifier(name: string)
	return ServerIdentifiers.ref(name)
end

function Server.playerContainers()
	return PlayerContainers
end

function Server.invalidPlayerhandler(func)
	ServerProcess.setInvalidPlayerFunction(func)
end

return Server
