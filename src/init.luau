--!strict
local RunService = game:GetService("RunService")

local Client = require(script.Client)
local PublicTypes = require(script.PublicTypes)
local Server = require(script.Server)
local MockBridge = require(script.Studio.MockBridge)
local NetworkUtils = require(script.Utilities.NetworkUtils)
local Output = require(script.Utilities.Output)
local isEditMode = require(script.Utilities.isEditMode)
local version = require(script.version)

local isServer = RunService:IsServer()

task.spawn(function()
	if not isEditMode then
		if isServer then
			Server.start()
		else
			Client.start()
		end
	end
end)

--[=[
	The parent of all classes.

	@class BridgeNet2
]=]

--[=[
	Generates a new UUID, removing all dashes (-).

	@prop CreateUUID () -> (string)
	@within BridgeNet2
]=]

--[=[
	References an identifier.

	@prop ReferenceIdentifer (name: string) -> (Types.Identifier?)
	@within BridgeNet2
]=]

--[=[
	Allows you to send a bridge event to all players.

	@prop AllPlayers any
	@within BridgeNet2
]=]

--[=[
	Allows you to send a bridge event to all players except for the listed players.

	@prop PlayersExcept any
	@within BridgeNet2
]=]

--[=[
	Allows you to send a bridge event to specific players only.

	@prop Players any
	@within BridgeNet2
]=]

--[=[
	References a bridge.

	@prop ReferenceBridge (name: string) -> (any)
	@within BridgeNet2
]=]

--[=[
	References a server bridge directly.

	@prop ServerBridge (name: string) -> (any)
	@within BridgeNet2
]=]

--[=[
	References a server bridge directly.

	@prop ClientBridge (name: string) -> (any)
	@within BridgeNet2
]=]

--[=[
	The function to handle invalid packets with.

	@prop HandleInvalidPlayer (handler: (player: Player) -> ()) -> ()
	@within BridgeNet2
]=]

local BridgeNet2 = {
	ToHex = NetworkUtils.ToHex,
	ToReadableHex = NetworkUtils.ToReadableHex,
	FromHex = NetworkUtils.FromHex,

	CreateUUID = NetworkUtils.CreateUUID,

	ReferenceIdentifier = if isServer then Server.makeIdentifier else Client.makeIdentifier,
	Deserialize = if isServer then Server.deser else Client.deser,
	Serialize = if isServer then Server.ser else Client.ser,

	AllPlayers = Server.playerContainers().All,

	PlayersExcept = Server.playerContainers().Except,

	Players = Server.playerContainers().Players,

	ReferenceBridge = if isServer then Server.makeBridge else Client.makeBridge,
	ServerBridge = if isServer then Server.makeBridge else nil,
	ClientBridge = if not isServer then Client.makeBridge else nil,

	Types = script.ExportedTypes,

	HandleInvalidPlayer = function(handler: (player: Player) -> ())
		Output.fatalAssert(isServer, "Cannot call from client")

		Server.invalidPlayerhandler(handler)
	end,

	version = version,
}

if isEditMode then
	Output.log("running BridgeNet2 in mock mode")

	BridgeNet2.ClientBridge = MockBridge
	BridgeNet2.ServerBridge = nil
	BridgeNet2.ReferenceBridge = MockBridge

	function BridgeNet2.ReferenceIdentifier(identifier)
		return identifier
	end

	function BridgeNet2.Serialize(identifier)
		return identifier
	end

	function BridgeNet2.Deserialize(identifier)
		return identifier
	end
end

table.freeze(BridgeNet2)

return (BridgeNet2 :: {}) :: PublicTypes.BridgeNet2
