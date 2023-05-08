--!strict
local ServerProcess = require(script.Parent.ServerProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

--[=[
	@class ServerBridge
]=]
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

--[=[
	@function OutboundMiddleware
		@within ServerBridge


		@param middlewareTable { (player: Player, object: any) -> any }
		@return void
]=]
function ServerBridge:InboundMiddleware(middlewareTable: { (player: Player, object: any) -> any })
	self._inboundMiddleware = middlewareTable
end

--[=[
	@function OutboundMiddleware
		@within ServerBridge


		@param middlewareTable { (target: ServerProcess.TPlayerType, object: any) -> any }
		@return void
]=]
function ServerBridge:OutboundMiddleware(middlewareTable: { (target: ServerProcess.TPlayerType, object: any) -> any })
	self._outboundMiddleware = middlewareTable
end

--[=[
	@function Connect
		@within ServerBridge

		

		@param middlewareTable (player: Player, object: T) -> nil
		@return void
]=]
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

		if self._inboundMiddleware ~= nil then
			local result = object

			-- Loop through the middleware functions- raise a silent log if any of them don't return a table for debugging.
			for _, middlewareFunction: (player: Player, object: any) -> any in self._inboundMiddleware do
				local returned = middlewareFunction(player, result)
				if typeof(returned) ~= "table" then
					Output.silent(
						string.format(
							"Inbound middleware on bridge %* did not return a table; ignoring the return.",
							self._name
						)
					)
				else
					result = returned
				end
			end

			callback(player, result)
		else
			callback(player, object)
		end
	end)
end

--[=[
	@function RateLimit
		@within ServerBridge


		@param invokesPerSecond number
		@param overflowFunction (player: Player) -> nil
		@return void
]=]
function ServerBridge:RateLimit(invokesPerSecond: number, overflowFunction: (player: Player) -> nil)
	self._rateLimiting = true
	self._overflowFunction = overflowFunction
	self._maxRate = invokesPerSecond
end

--[=[
	@function DisableRateLimit
		@within ServerBridge

		@return void
]=]
function ServerBridge:DisableRateLimit()
	self._rateLimiting = false
end

--[=[
	@function Wait
		@within ServerBridge

		@return ...
]=]
function ServerBridge:Wait()
	local thread = coroutine.running()
	self:Connect(function(player, object)
		coroutine.resume(thread, player, object)
	end)
	return coroutine.yield()
end

function ServerBridge:Once<T>(func: (player: Player | ServerProcess.TPlayerType, object: T & {}) -> ())
	local connection
	connection = self:Connect(function(player, object)
		connection:Disconnect()
		func(player, object)
	end)
	return connection
end

--[=[
	@function Fire
		@within ServerBridge

		@return void
]=]
function ServerBridge:Fire<T>(target: ServerProcess.TPlayerType | Player, object: T & {})
	if not object then
		object = {}
	end

	if self._outboundMiddleware ~= nil then
		local result = object

		-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
		for _, middlewareFunction: (object: any) -> any in self._outboundMiddleware do
			local returned = middlewareFunction(result)
			if typeof(returned) ~= "table" then
				Output.silent(
					string.format(
						"Outbound middleware on bridge %* did not return a table; ignoring the return.",
						self._name
					)
				)
			else
				result = returned
			end
		end

		ServerProcess._addToQueue(target, self._identifier, result)
	else
		ServerProcess._addToQueue(target, self._identifier, object)
	end
end

--[=[
	@function Destroy
		@within ServerBridge

		@return void
]=]
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
