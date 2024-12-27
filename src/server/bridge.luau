local signal = require("@pkg/signal")
local process = require("@src/server/process")
local identifiers = require("@src/server/identifiers")
local identifierMap = require("@src/identifierMap")
local deserializer = require("@src/core/deserializer")

local ServerBridge = {}
local metatable = { __index = ServerBridge }
export type Identity = typeof(setmetatable(
	{} :: {
		_id: number,
		_signal: signal.Identity<...any>,
	},
	metatable
))

local function constructor(name: string): Identity
	local self = setmetatable({
		_id = identifierMap.fromName(name) or identifiers.register(name),
	}, metatable)

	self._signal = if deserializer.exists(self._id)
		then deserializer.fetchEventSignal(self._id)
		else deserializer.registerId(self._id)

	return self
end

function ServerBridge.Fire(self: Identity, player: Player, value: any)
	process.firePlayer(player, self._id, value)
end

function ServerBridge.FireAllExcept(self: Identity, exception: Player, value: any) end

function ServerBridge.FireGroup(self: Identity, players: { Player }, value: any)
	for _, player in players do
		process.firePlayer(player, self._id, value)
	end
end

function ServerBridge.FireAll(self: Identity)
	process.fireAll(self._id)
end

function ServerBridge.Connect(self: Identity, callback: (player: Player, data: unknown) -> ()): () -> ()
	return self._signal:connect(callback)
end

function ServerBridge.OnInvoke(self: Identity) end

function ServerBridge.OutboundMiddleware(self: Identity) end

function ServerBridge.InboundMiddleware(self: Identity) end

function ServerBridge.Wait(self: Identity) end

function ServerBridge.Once(self: Identity, callback: (player: Player, data: unknown) -> ()): () -> ()
	return self._signal:once(callback)
end

return {
	new = constructor,
}
