--!strict
local RunService = game:GetService("RunService")

local Client = require(script.Client)
local PublicTypes = require(script.PublicTypes)
local Server = require(script.Server)
local NetworkUtils = require(script.Utilities.NetworkUtils)
local Output = require(script.Utilities.Output)

local isServer = RunService:IsServer()

task.spawn(function()
	if isServer then
		Server.start()
	else
		Client.start()
	end
end)

local BridgeNet2 = {
	ToHex = NetworkUtils.ToHex,
	ToReadableHex = NetworkUtils.ToReadableHex,
	FromHex = NetworkUtils.FromHex,
	CreateUUID = NetworkUtils.CreateUUID,

	--- Identifiers
	ReferenceIdentifier = if isServer then Server.makeIdentifier else Client.makeIdentifier,
	Deserialize = if isServer then Server.deser else Client.deser,
	Serialize = if isServer then Server.ser else Client.ser,

	-- PlayerContainers
	AllPlayers = Server.playerContainers().All,
	PlayersExcept = Server.playerContainers().Except,
	Players = Server.playerContainers().Players,

	ReferenceBridge = if isServer then Server.makeBridge else Client.makeBridge,
	ServerBridge = if isServer then Server.makeBridge else nil,
	ClientBridge = if not isServer then Client.makeBridge else nil,

	HandleInvalidPlayer = function(handler: (player: Player) -> ())
		Output.fatalAssert(isServer, "Cannot call from client")
		Server.invalidPlayerhandler(handler)
	end,
} :: {}

table.freeze(BridgeNet2)

return BridgeNet2 :: PublicTypes.BridgeNet2
