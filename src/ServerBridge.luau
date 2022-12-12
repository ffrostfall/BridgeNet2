--!strict
local ServerProcess = require(script.Parent.ServerProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

--[[
	@class ServerBridge
]]
local ServerBridge = {}
ServerBridge.__index = ServerBridge

function ServerBridge._new(name: string)
	local self = setmetatable({}, ServerBridge)

	-- Since this is the server, ReferenceIdentifier will not yield
	self._identifier = Identifiers.ReferenceIdentifier(name)

	-- Middleware
	self._outboundMiddleware = nil
	self._inboundMiddleware = nil

	self._name = name

	-- Rate limiting
	self._rateLimiting = false
	self._maxRate = 500
	self._rateMap = {}
	self._overflowFunction = function()
		return false
	end

	ServerProcess._idIntoBridge(self._identifier)

	return self
end

function ServerBridge:InboundMiddleware(middlewareTable: { (player: Player, object: any) -> any })
	self._inboundMiddleware = middlewareTable
end

function ServerBridge:OutboundMiddleware(middlewareTable: { (target: ServerProcess.TPlayerType, object: any) -> any })
	self._outboundMiddleware = middlewareTable
end

function ServerBridge:Connect<T>(callback: (player: Player, object: T) -> nil)
	ServerProcess._connect(self._identifier, function(player, object)
		if self._rateLimiting then
			if self._rateMap[player] ~= nil then
				self._rateMap[player] += 1
			else
				self._rateMap[player] = 1
			end

			if self._rateMap[player] > self._maxRate then
				if not self._overflowFunction(player) then
					return
				end
			end
		end

		if self._inboundMiddlewares ~= nil then
			local result = object

			-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
			for _, middlewareFunction: (player: Player, object: any) -> any in self._inboundMiddlewares do
				result = middlewareFunction(player, result)
					or (
						Output.silent(
							string.format(
								"Inbound middleware on bridge %* returned nil, defaulting to object.",
								self._name
							)
						) or object
					)
			end

			callback(player, result)
		else
			callback(player, object)
		end
	end)
end

function ServerBridge:RateLimit(invokesPerSecond: number, overflowFunction: (player: Player) -> nil)
	self._rateLimiting = true
	self._overflowFunction = overflowFunction
	self._maxRate = invokesPerSecond
end

function ServerBridge:DisableRateLimit()
	self._rateLimiting = false
end

function ServerBridge:Fire<T>(target: ServerProcess.TPlayerType, object: T)
	if self._outboundMiddleware ~= nil then
		local result = object

		-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
		for _, middlewareFunction: (player: ServerProcess.TPlayerType, object: any) -> any in self._outboundMiddlewares do
			result = middlewareFunction(result)
				or (
					Output.silent(
						string.format(
							"Outbound middleware on bridge %* returned nil, defaulting to object.",
							self._name
						)
					) or object
				)
		end

		ServerProcess._addToQueue(target, self._identifier, result)
	else
		ServerProcess._addToQueue(target, self._identifier, object)
	end
end

function ServerBridge:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

-- () -> () means it returns void. Pretty neat trick I learned from Aloroider
export type ServerBridge<T> =
	{
		Connect: (
			self: ServerBridge<T>,
			((player: Player, object: T) -> ()) | ((player: Player, object: T) -> nil)
		) -> (),
		Fire: (self: ServerBridge<T>, target: ServerProcess.TPlayerType, object: T) -> (),
		InboundMiddleware: (
			self: ServerBridge<T>,
			{ ((player: Player, object: T) -> T) | ((player: Player, object: T) -> ()) | ((player: Player, object: T) -> nil) }
		) -> (),
		OutboundMiddleware: (
			self: ServerBridge<T>,
			{ ((target: ServerProcess.TPlayerType, object: T) -> T) | ((player: Player, object: T) -> ()) | ((player: Player, object: T) -> nil) }
		) -> (),
		RateLimit: (self: ServerBridge<T>, invokesPerSecond: number, overflowFunction: (player: Player) -> nil) -> (),
		Destroy: (self: ServerBridge<T>) -> (),
	}

return ServerBridge
