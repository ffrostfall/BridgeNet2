--!strict
local Constants = require(script.Parent.Parent.Constants)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local ServerProcess = require(script.Parent.ServerProcess)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local PlayerContainers = require(script.Parent.PlayerContainers)
local ServerConnection = require(script.Parent.ServerConnection)
local ServerIdentifiers = require(script.Parent.ServerIdentifiers)

type TOptionalCallback<T> = (() -> T) | (() -> nil) | (() -> ())

-- luau requires typecasts here
local function toStringData(data: any)
	if typeof(data) == "table" then
		if TableKit.IsArray(data) then
			return TableKit.ToArrayString(data)
		else
			return TableKit.ToString(data)
		end
	else
		local prefix = ""
		local suffix = ""
		if typeof(data) == "CFrame" then
			prefix = "CFrame("
			suffix = ")"
		elseif typeof(data) == "Vector3" then
			prefix = "Vector3("
			suffix = ")"
		end
		return `{prefix}{tostring(data)}{suffix}`
	end
end

local serverBridgePrototype = {}

local CLASS_METATABLE = { __index = serverBridgePrototype }

function CLASS_METATABLE:__tostring()
	return "ServerBridge"
end

--[=[
	@function OutboundMiddleware
	@within ServerBridge

	Sets the middleware to be used in-between your :Fire() and actually sending it out over the RemoteEvent.

	@param middlewareTable { (player: Player, object: any) -> any }
	@return void
]=]
function serverBridgePrototype:InboundMiddleware(middlewareTable: { (player: Player, content: Types.Content) -> any })
	Output.fatalAssert(tostring(self) == "ServerBridge", "InboundMiddleware called with . instead of :")
	self._inboundMiddleware = middlewareTable
end

--[=[
	@function OutboundMiddleware
	@within ServerBridge


	@param middlewareTable { (target: ServerProcess.TPlayerType, object: any) -> any }
	@return void
]=]
function serverBridgePrototype:OutboundMiddleware(
	middlewareTable: { (target: Types.PlayerContainer, content: Types.Content) -> any }
)
	Output.fatalAssert(tostring(self) == "ServerBridge", "OutboundMiddleware called with . instead of :")
	self._outboundMiddleware = middlewareTable
end

--[=[
	@function Connect
	@within ServerBridge

	

	@param middlewareTable (player: Player, object: T) -> nil
	@return void
]=]
function serverBridgePrototype:Connect(callback: (player: Player, content: Types.Content) -> nil): RBXScriptConnection
	Output.fatalAssert(tostring(self) == "ServerBridge", "Connect called with . instead of :")

	return ServerConnection(self._identifier, function(player, content)
		if typeof(content) == "table" then
			if (content :: {})[1] == ServerIdentifiers.ref("REQUEST") then
				return
			end
		end
		if self.RateLimitActive then
			if self._rateMap[player] ~= nil then
				local currentCount: number = self._rateMap[player]
				self._rateMap[player] = currentCount + 1
			else
				self._rateMap[player] = 1
			end

			task.delay(1, function()
				local currentCount: number = self._rateMap[player]
				self._rateMap[player] = math.min(0, currentCount - 1)
			end)

			if self._rateMap[player] >= self._maxRate then
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
				if self.Logging then
					local logOutput = string.format(
						Constants.SERVER_CONNECT_LOG,
						self._name,
						player.Name,
						toStringData(content),
						RemotePacketSizeCounter.GetDataByteSize(content)
					)
					Output.log(logOutput)
				end
			end

			callback(player, result)
		else
			if self.Logging then
				local logOutput = string.format(
					Constants.SERVER_CONNECT_LOG,
					self._name,
					player.Name,
					toStringData(content),
					RemotePacketSizeCounter.GetDataByteSize(content)
				)
				Output.log(logOutput)
			end

			callback(player, content)
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
function serverBridgePrototype:RateLimit(invokesPerSecond: number, overflowFunction: (player: Player) -> nil)
	Output.fatalAssert(tostring(self) == "ServerBridge", "RateLimit called with . instead of :")
	self.RateLimitActive = true
	self._overflowFunction = overflowFunction
	self._maxRate = invokesPerSecond
end

--[=[
	@function DisableRateLimit
	@within ServerBridge

	@return void
]=]
function serverBridgePrototype:DisableRateLimit()
	Output.fatalAssert(tostring(self) == "ServerBridge", "DisableRateLimit called with . instead of :")
	self.RateLimitActive = false
end

--[=[
	@function Wait
	@within ServerBridge

	Equivalent of RemoteEvent.OnServerEvent:Wait()

	@return ...
]=]
function serverBridgePrototype:Wait()
	Output.fatalAssert(tostring(self) == "ServerBridge", "Wait called with . instead of :")
	local thread = coroutine.running()
	self:Connect(function(player, content)
		coroutine.resume(thread, player, content)
	end)
	return coroutine.yield()
end

--[=[
	@function Once
	@within ServerBridge

	Equivalent of RemoteEvent.OnServerEvent:Once()

	@param callback (player: Player, object: unknown) -> ()
	@return ...
]=]
function serverBridgePrototype:Once(callback: (player: Player, content: Types.Content) -> ())
	Output.fatalAssert(tostring(self) == "ServerBridge", "Once called with . instead of :")
	local connection
	connection = self:Connect(function(player, content)
		connection:Disconnect()
		callback(player, content)
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
			local logOutput = string.format(
				Constants.SERVER_FIRE_LOG,
				self._name,
				if playerContainer.kind == "all"
					then "{all}"
					elseif playerContainer.kind == "single" then playerContainer.value.Name
					else TableKit.ToArrayString(playerContainer.value),
				toStringData(result),
				RemotePacketSizeCounter.GetDataByteSize(result)
			)
			Output.log(logOutput)
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, result)
	else
		if self.Logging then
			if self.Logging then
				local logOutput = string.format(
					Constants.SERVER_FIRE_LOG,
					self._name,
					if playerContainer.kind == "all"
						then "{all}"
						elseif playerContainer.kind == "single" then playerContainer.value.Name
						else TableKit.ToArrayString(playerContainer.value),
					toStringData(content),
					RemotePacketSizeCounter.GetDataByteSize(content)
				)
				Output.log(logOutput)
			end
		end

		ServerProcess.addToQueue(playerContainer, self._identifier, content)
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
		OnServerInvoke = function() end :: (player: Player, content: Types.Content?) -> ...any,

		-- Rate limiting
		RateLimitActive = false,
		_maxRate = 500,
		_rateMap = {} :: { [Player]: number },
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
				local reply = self.OnServerInvoke(player, (content :: {})[2])
				print(reply)
				self:Fire(player, { ServerIdentifiers.ref("REQUEST"), reply })
			end
		end
	end)

	return self
end
