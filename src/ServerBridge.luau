local ServerProcess = require(script.Parent.ServerProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

local function toStringData(data)
	return TableKit.ToString(data)
end

--[=[
	@class ServerBridge
]=]
local ServerBridge = {}
ServerBridge.__index = ServerBridge

--[=[
	@function OutboundMiddleware
	@within ServerBridge

	Sets the middleware to be used in-between your :Fire() and actually sending it out over the RemoteEvent.

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
function ServerBridge:Connect(callback: (player: Player, object: any) -> nil)
	local methods = {
		Connected = true
	}
	local connection = ServerProcess._connect(self._identifier, function(player, object)
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

			if self._logging then
				Output.log(
					`bridge {self._name} got fired from player {player.Name}:{player.UserId} with data {toStringData(result)}`
				)
			end

			callback(player, result)
		else
			if self._logging then
				Output.log(
					`bridge {self._name} got fired from player {player.Name}:{player.UserId} with data {toStringData(object)}`
				)
			end
			callback(player, object)
		end
	end)
	
	methods["Disconnect"] = function()
		connection()
		methods.Connected = false
	end

	return methods
end

--[=[
	@function StartLogging
	@within ServerBridge
	
	Prints every time this bridge receives or sends data
	
	@return void
]=]
function ServerBridge:StartLogging()
	self._logging = true
end

--[=[
	@function StartLogging
	@within ServerBridge
	
	Stops logging incoming/outgoing data
	
	@return void
]=]
function ServerBridge:StopLogging()
	self._logging = false
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

	Equivalent of RemoteEvent.OnServerEvent:Wait()

	@return ...
]=]
function ServerBridge:Wait()
	local thread = coroutine.running()
	self:Connect(function(player, object)
		coroutine.resume(thread, player, object)
	end)
	return coroutine.yield()
end

function ServerBridge:Once(func: (player: Player | ServerProcess.TPlayerType, object: any) -> ())
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

	Equivalent of RemoteEvent:FireClient(), the ServerBridge:Fire() function takes a player type, or a singular player, and fires the
	data to the client. Important to note that it takes a singular object as a parameter instead of using tuples-
	this is intentional.

	@return void
]=]
function ServerBridge:Fire<_, T>(target: ServerProcess.TPlayerType | Player, object: T)
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

		if self._logging then
			Output.log(`fired {self._name} with data {toStringData(result)}`)
		end

		ServerProcess._addToQueue(target, self._identifier, result)
	else
		if self._logging then
			local targetString
			if typeof(target) == "Instance" then
				targetString = target.Name
			else
				targetString = toStringData(target)
			end

			Output.log(`fired {self._name} with data {toStringData(object)} to players {targetString}`)
		end

		ServerProcess._addToQueue(target, self._identifier, object)
	end
end

-- () -> () means it returns void. Pretty neat trick I learned from Aloroider
--[[export type ServerBridge<T> = {
	Connect: (
		self: ServerBridge<T>,
		((player: Player, object: T) -> ()) | ((player: Player, object: T) -> nil)
	) -> (),
	Fire: (self: ServerBridge<T>, target: ServerProcess.TPlayerType, object: T) -> (),
	InboundMiddleware: (
		self: ServerBridge<T>,
		{
			((player: Player, object: T) -> T)
			| ((player: Player, object: T) -> ())
			| ((player: Player, object: T) -> nil)
		}
	) -> (),
	OutboundMiddleware: (
		self: ServerBridge<T>,
		{
			((target: ServerProcess.TPlayerType, object: T) -> T)
			| ((player: Player, object: T) -> ())
			| ((player: Player, object: T) -> nil)
		}
	) -> (),
	RateLimit: (self: ServerBridge<T>, invokesPerSecond: number, overflowFunction: (player: Player) -> nil) -> (),
	Destroy: (self: ServerBridge<T>) -> (),
}]]

return function(name: string)
	local self = setmetatable({
		-- Since this is the server, ReferenceIdentifier will not yield
		_identifier = Identifiers.ReferenceIdentifier(name),

		-- Middleware
		_outboundMiddleware = nil,
		_inboundMiddleware = nil,

		_name = name,

		-- Rate limiting
		_rateLimiting = false,
		_maxRate = 500,
		_rateMap = {},
		_overflowFunction = function()
			return false
		end,
	} :: {}, ServerBridge)

	ServerProcess._idIntoBridge(self._identifier)

	return self
end
