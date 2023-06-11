--!strict
local Constants = require(script.Parent.Parent.Constants)
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

local ServerBridge = {}
ServerBridge.__index = ServerBridge

--[=[
	@function OutboundMiddleware
	@within ServerBridge

	Sets the middleware to be used in-between your :Fire() and actually sending it out over the RemoteEvent.

	@param middlewareTable { (player: Player, object: any) -> any }
	@return void
]=]
function ServerBridge:InboundMiddleware(middlewareTable: { (player: Player, content: Types.Content) -> any })
	self._inboundMiddleware = middlewareTable
end

--[=[
	@function OutboundMiddleware
	@within ServerBridge


	@param middlewareTable { (target: ServerProcess.TPlayerType, object: any) -> any }
	@return void
]=]
function ServerBridge:OutboundMiddleware(
	middlewareTable: { (target: Types.PlayerContainer, content: Types.Content) -> any }
)
	self._outboundMiddleware = middlewareTable
end

--[=[
	@function Connect
	@within ServerBridge

	

	@param middlewareTable (player: Player, object: T) -> nil
	@return void
]=]
function ServerBridge:Connect(callback: (player: Player, content: Types.Content) -> nil)
	local connection = ServerProcess.connect(self._identifier, function(player, content)
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
	self.RateLimitActive = true
	self._overflowFunction = overflowFunction
	self._maxRate = invokesPerSecond
end

--[=[
	@function DisableRateLimit
	@within ServerBridge

	@return void
]=]
function ServerBridge:DisableRateLimit()
	self.RateLimitActive = false
end

--[=[
	@function Wait
	@within ServerBridge

	Equivalent of RemoteEvent.OnServerEvent:Wait()

	@return ...
]=]
function ServerBridge:Wait()
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
function ServerBridge:Once(callback: (player: Player, content: Types.Content) -> ())
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
function ServerBridge:Fire(target: Player | Types.PlayerContainer, content: any)
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

		-- Rate limiting
		RateLimitActive = false,
		_maxRate = 500,
		_rateMap = {} :: { [Player]: number },
		_overflowFunction = function()
			return false
		end,
	}, ServerBridge)

	ServerProcess.registerBridge(self._identifier)

	return self
end
