local RunService = game:GetService("RunService")

local Identifiers = require(script.Identifiers)
local Server = require(script.ServerProcess)
local Client = require(script.ClientProcess)
local NetworkUtils = require(script.NetworkUtils)

local isServer = RunService:IsServer()

Identifiers._startProcess()
if isServer then
	Server._startProcess()
else
	Client._startProcess()
end

return {
	-- NetworkUtils
	NumberToBestForm = NetworkUtils.NumberToBestForm,
	ToHex = NetworkUtils.ToHex,
	FromHex = NetworkUtils.FromHex,
	CreateUUID = NetworkUtils.CreateUUID,
	DictionaryToTable = NetworkUtils.DictionaryToTable,

	-- Identifiers
	ReferenceIdentifier = Identifiers.ReferenceIdentifier,
	FromCompressed = Identifiers.FromCompressed,
	FromIdentifier = Identifiers.FromIdentifier,
}
