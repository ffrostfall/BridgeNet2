--!strict
local Types = require(script.Parent.Types)
local PlayerContainers = require(script.PlayerContainers)
local ServerBridge = require(script.ServerBridge)
local ServerIdentifiers = require(script.ServerIdentifiers)
local ServerProcess = require(script.ServerProcess)

local Server = {}

function Server.start()
	ServerProcess.start()
	ServerIdentifiers.start()
end

function Server.makeBridge(name: string)
	return ServerBridge(name)
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
