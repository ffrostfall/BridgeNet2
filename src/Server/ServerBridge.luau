--!strict
local Constants = require(script.Parent.Parent.Constants)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local ServerProcess = require(script.Parent.ServerProcess)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local tostringData = require(script.Parent.Parent.Utilities.tostringData)
local PlayerContainers = require(script.Parent.PlayerContainers)
local ServerConnection = require(script.Parent.ServerConnection)
local ServerIdentifiers = require(script.Parent.ServerIdentifiers)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

--[=[
	This class handles the server-sided interface of BridgeNet2.

	@class ServerBridge
]=]
local serverBridgePrototype = {}

--[=[
	Sets a function that runs when the server is invoked by the client, should return some values.

	@within ServerBridge
	@prop OnServerInvoke (player: Player, content: Types.Content?) -> ...any
]=]

local CLASS_METATABLE = { __index = serverBridgePrototype }

function CLASS_METATABLE:__tostring()
	return "ServerBridge"
end

--[=[
	Sets some middleware to run when a bridge is fired from the client. 

	@within ServerBridge
	@param middlewareTable {(player: Player, content: Types.Content) -> any}
]=]
function serverBridgePrototype:InboundMiddleware(middlewareTable: { (player: Player, content: Types.Content) -> any })
	Output.fatalAssert(tostring(self) == "ServerBridge", "InboundMiddleware called with . instead of :")
	self._inboundMiddleware = middlewareTable
end

--[=[
	Sets some middleware to run when a bridge is fired from the backend server.

	@within ServerBridge
	@param middlewareTable {(target: Types.PlayerContainer, content: Types.Content) -> any}
]=]
function serverBridgePrototype:OutboundMiddleware(
	middlewareTable: { (target: Types.PlayerContainer, content: Types.Content) -> any }
)
	Output.fatalAssert(tostring(self) == "ServerBridge", "OutboundMiddleware called with . instead of :")
	self._outboundMiddleware = middlewareTable
end

--[=[
	Connects the bridge to any events recieved from the client, this is when inbound middleware is ran. This shares identical behavior with [RemoteEvent.OnClientEvent].

	@within ServerBridge
	@param callback (player: Player, content: Types.Content) -> nil
	@return RBXScriptConnection
]=]
function serverBridgePrototype:Connect(callback: (player: Player, content: Types.Content) -> nil, name: string?)
	Output.fatalAssert(tostring(self) == "ServerBridge", "Connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)

	local line = debug.info(2, "l")
	local scriptName = debug.info(2, "s")

	return ServerConnection(self._identifier, function(player, content)
		if typeof(content) == "table" then
			if (content :: {})[1] == ServerIdentifiers.ref("REQUEST") then
				return
			end
		end

		if self.RateLimitActive then
			-- get the current second
			local thisSecond = math.round(os.clock() - os.clock() % 1)

			if self._rateMap[player] ~= nil then
				local lastSecond = self._rateMap[player][1] or 0

				if lastSecond ~= thisSecond then
					self._rateMap[player][2] = 0

					self._rateMap[player][1] = thisSecond
				else
					self._rateMap[player][2] += 1
				end
			else
				self._rateMap[player] = { thisSecond, 1 }
			end

			if self._rateMap[player][2] >= self._maxRate then
				if not self._overflowFunction(player) then
					return
				end
			end
		end

		if self._inboundMiddleware ~= nil then
			local result = content

			-- Loop through the middleware functions- raise a silent log if any of them don't return a table for debugging.
			for _, middlewareFunction: (player: Player, content: Types.Content) -> any in self._inboundMiddleware do
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
				local logOutput = string.format(
					Constants.SERVER_CONNECT_LOG,
					name or self._name,
					player.Name,
					tostringData(content),
					RemotePacketSizeCounter.GetDataByteSize(content),
					scriptName,
					line
				)
				Output.log(logOutput)
			end

			if name then
				debug.profilebegin(name)
			end
			callback(player, result)
			if name then
				debug.profileend()
			end
		else
			if self.Logging then
				local logOutput = string.format(
					Constants.SERVER_CONNECT_LOG,
					name or self._name,
					player.Name,
					tostringData(content),
					RemotePacketSizeCounter.GetDataByteSize(content),
					scriptName,
					line
				)
				Output.log(logOutput)
			end

			if name then
				debug.profilebegin(name)
			end
			callback(player, content)
			if name then
				debug.profileend()
			end
		end
	end)
end

--[=[
	Sets the rate limit, which makes a bridge only allow `invokesPerSecond` invoke per second.

	@within ServerBridge
	@param invokesPerSecond number -- The maximum invokes per second allowed from the client
	@param overflowFunction (player: Player) -> nil -- The function to run if the client runs over the maximum amount of request
]=]
function serverBridgePrototype:RateLimit(invokesPerSecond: number, overflowFunction: (player: Player) -> nil)
	Output.fatalAssert(tostring(self) == "ServerBridge", "RateLimit called with . instead of :")
	self.RateLimitActive = true
	self._overflowFunction = overflowFunction
	self._maxRate = invokesPerSecond
end

--[=[
	Disables the set rate limit for the bridge.
	@within ServerBridge
]=]
function serverBridgePrototype:DisableRateLimit()
	Output.fatalAssert(tostring(self) == "ServerBridge", "DisableRateLimit called with . instead of :")
	self.RateLimitActive = false
end

--[=[
	Connects the bridge to any events recieved from the client, this is when inbound middleware is ran. This shares identical behavior with [RemoteEvent.OnClientEvent].

	@within ServerBridge
	@yields
	@return Player, any
]=]
function serverBridgePrototype:Wait()
	Output.fatalAssert(tostring(self) == "ServerBridge", "Wait called with . instead of :")
	local thread = coroutine.running()
	self:Connect(function(player, content)
		task.spawn(thread, player, content)
	end)
	return coroutine.yield()
end

--[=[
	Connects the bridge to any events recieved from the client, this is when inbound middleware is ran. This shares identical behavior with [ClientBridge:Connect] with the difference being that the event instantly disconnects on recieved.

	@within ServerBridge
	@param callback (player: Player, content: Types.Content) -> ()
	@return RBXScriptConnection
]=]
function serverBridgePrototype:Once(callback: (player: Player, content: Types.Content) -> ())
	Output.fatalAssert(tostring(self) == "ServerBridge", "Once called with . instead of :")
	Output.typecheck("function", "Once", "callback", callback)

	local connection
	connection = self:Connect(function(player, content)
		connection:Disconnect()
		callback(player, content)
	end)
	return connection
end

--[=[
	Fires the bridge from the backend server, which can then be recieved from the client along with packet data sent along.

	@within ServerBridge
	@param target Player | Types.PlayerContainer -- The player which the event should be fired to
	@param content any -- The packet data which should be sent along
]=]
function serverBridgePrototype:Fire(target: Player | Types.PlayerContainer, content: any)
	Output.fatalAssert(tostring(self) == "ServerBridge", "Fire called with . instead of :")
	local playerContainer: Types.PlayerContainer

	-- if it's a single player, then create a player container w/ type "single"
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			playerContainer = PlayerContainers.Single(target)
		else
			Output.fatal("non-player instance passed into :Fire()")
		end
	else
		if typeof(target) == "nil" then
			Output.fatal("target parameter passed into ServerBridge:Fire() is nil")
		end
		Output.typecheck("table", "Fire", "target", target)
		playerContainer = target
	end

	if self._outboundMiddleware ~= nil then
		local result = content

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
			Output.log(`{debug.info(2, "s")}:{debug.info(2, "l")}`)
			local logOutput = string.format(
				Constants.SERVER_FIRE_LOG,
				self._name,
				if playerContainer.kind == "all"
					then "{all}"
					elseif playerContainer.kind == "single" then playerContainer.value.Name
					else TableKit.ToArrayString(playerContainer.value),
				tostringData(result),
				RemotePacketSizeCounter.GetDataByteSize(result)
			)
			Output.log(logOutput)
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, result)
	else
		if self.Logging then
			Output.log(`{debug.info(2, "s")}:{debug.info(2, "l")}`)
			local logOutput = string.format(
				Constants.SERVER_FIRE_LOG,
				self._name,
				if playerContainer.kind == "all"
					then "{all}"
					elseif playerContainer.kind == "single" then playerContainer.value.Name
					else TableKit.ToArrayString(playerContainer.value),
				tostringData(content),
				RemotePacketSizeCounter.GetDataByteSize(content)
			)
			Output.log(logOutput)
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, content)
	end
end

return function(name: string)
	local self = setmetatable({
		-- Since this is the server, ReferenceIdentifier will not yield
		_identifier = ServerIdentifiers.ref(name),

		-- Middleware
		_outboundMiddleware = nil,
		_inboundMiddleware = nil,

		_name = name,

		Logging = false,
		OnServerInvoke = function() end :: (player: Player, content: Types.Content?) -> ...any,

		-- Rate limiting
		RateLimitActive = false,
		_maxRate = 500,
		_rateMap = {} :: { [Player]: { number } },
		_overflowFunction = function()
			return false
		end,
	}, CLASS_METATABLE)

	ServerProcess.registerBridge(self._identifier)

	ServerProcess.connect(self._identifier, function(player, content)
		if typeof(content) ~= "table" then
			return
		end

		if self.OnServerInvoke ~= nil then
			if (content :: {})[1] == ServerIdentifiers.ref("REQUEST") then
				local reply = self.OnServerInvoke(player, (content :: {})[3])

				self:Fire(player, { ServerIdentifiers.ref("REQUEST"), (content :: {})[2], reply })
			end
		end
	end)

	return self
end
