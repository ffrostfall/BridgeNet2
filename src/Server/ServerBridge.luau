--!strict
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local ServerProcess = require(script.Parent.ServerProcess)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local PlayerContainers = require(script.Parent.PlayerContainers)
local ServerIdentifiers = require(script.Parent.ServerIdentifiers)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

-- luau requires typecasts here
local function toStringData(data: any)
	return TableKit.ToString(data :: {})
end

local ServerBridge = {}
ServerBridge.__index = ServerBridge

--[=[
	@function OutboundMiddleware
	@within ServerBridge

	Sets the middleware to be used in-between your :Fire() and actually sending it out over the RemoteEvent.

	@param middlewareTable { (player: Player, object: any) -> any }
	@return void
]=]
function ServerBridge:InboundMiddleware(middlewareTable: { (player: Player, object: Types.Content) -> any })
	self._inboundMiddleware = middlewareTable
end

--[=[
	@function OutboundMiddleware
	@within ServerBridge


	@param middlewareTable { (target: ServerProcess.TPlayerType, object: any) -> any }
	@return void
]=]
function ServerBridge:OutboundMiddleware(middlewareTable: { (target: Types.PlayerContainer, object: any) -> any })
	self._outboundMiddleware = middlewareTable
end

--[=[
	@function Connect
	@within ServerBridge

	

	@param middlewareTable (player: Player, object: T) -> nil
	@return void
]=]
function ServerBridge:Connect(callback: (player: Player, object: any) -> nil)
	local connection = ServerProcess.connect(self._identifier, function(player, object)
		if self._rateLimiting then
			if self._rateMap[player] ~= nil then
				local currentCount: number = self._rateMap[player]
				self._rateMap[player] = currentCount + 1
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

			if self.Logging then
				Output.log(
					`bridge {self._name} got fired from player {player.Name}:{player.UserId} with data \n---------------\n{toStringData(result)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
						result
					)})\n`
				)
			end

			callback(player, result)
		else
			if self.Logging then
				Output.log(
					`bridge {self._name} got fired from player {player.Name}:{player.UserId} with data \n---------------\n{toStringData(object)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
						object
					)})\n`
				)
			end
			callback(player, object)
		end
	end)

	return {
		Disconnect = function()
			connection()
		end,
	}
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

function ServerBridge:Once(func: (player: Player, object: any) -> ())
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
function ServerBridge:Fire<_, T>(target: Player | Types.PlayerContainer, object: T)
	local playerContainer: Types.PlayerContainer

	-- if it's a single player, then create a player container w/ type "single"
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			playerContainer = PlayerContainers.Single(target)
		else
			Output.fatal("non-player instance passed into :Fire()")
		end
	else
		Output.typecheck("table", "Fire", "target", target)
		playerContainer = target
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

		if self.Logging then
			Output.log(
				`fired {self._name} with data \n---------------\n{toStringData(result)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
					result
				)})\n`
			)
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, result)
	else
		if self.Logging then
			local targetString
			if typeof(target) == "Instance" then
				targetString = target.Name
			else
				targetString = toStringData(target)
			end

			Output.log(
				`fired {self._name} with data \n---------------\n{toStringData(object)}\n---------------\n to players {targetString} ({RemotePacketSizeCounter.GetDataByteSize(
					object
				)})\n`
			)
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, object)
	end
end

--[=[
	@class ServerBridge
]=]
return function(name: string)
	local self = setmetatable({
		-- Since this is the server, ReferenceIdentifier will not yield
		_identifier = ServerIdentifiers.ref(name),

		-- Middleware
		_outboundMiddleware = nil,
		_inboundMiddleware = nil,

		_name = name,

		Logging = false,

		-- Rate limiting
		_rateLimiting = false,
		_maxRate = 500,
		_rateMap = {} :: { [Player]: number },
		_overflowFunction = function()
			return false
		end,
	}, ServerBridge)

	ServerProcess.registerBridge(self._identifier)

	return self
end
