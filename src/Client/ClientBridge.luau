--!strict
local ClientConnection = require(script.Parent.ClientConnection)
local ClientIdentifiers = require(script.Parent.ClientIdentifiers)
local ClientProcess = require(script.Parent.ClientProcess)
local Constants = require(script.Parent.Parent.Constants)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local Types = require(script.Parent.Parent.Types)
local NetworkUtils = require(script.Parent.Parent.Utilities.NetworkUtils)
local tostringData = require(script.Parent.Parent.Utilities.tostringData)

--[=[
	This class handles the client-sided interface of BridgeNet2.

	@class ClientBridge
]=]
local clientBridgePrototype = {}

local CLASS_METATABLE = { __index = clientBridgePrototype }

function CLASS_METATABLE:__tostring()
	return "ClientBridge"
end

--[=[
	Sets the rate limit, cannot be used client-sided.
	
	@within ClientBridge
	@ignore
	@return string
]=]
function clientBridgePrototype:RateLimit()
	Output.warn("cannot call :RateLimit() from client")
end

--[=[
	Disables the rate limit, cannot be used client-sided.

	@within ClientBridge
	@ignore
	@return string
]=]
function clientBridgePrototype:DisableRateLimit()
	Output.warn("cannot call :DisableRateLimit() from client")
end

--[=[
	Sets some middleware to run when a bridge is fired from the server. 

	@within ClientBridge
	@param middlewareTable {(object: any) -> any}
]=]
function clientBridgePrototype:InboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "InboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("InboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._inboundMiddleware = middlewareTable
end

--[=[
	Sets some middleware to run when a bridge is fired from the local client. 

	@within ClientBridge
	@param middlewareTable {(object: any) -> any}
]=]
function clientBridgePrototype:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "OutboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("OutboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._outboundMiddleware = middlewareTable
end

--[=[
	Fires the bridge locally, which can then be recieved from the server along with packet data sent along.

	@within ClientBridge
	@param content any
]=]
function clientBridgePrototype:Fire(content: any)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Fire called with . instead of :")

	if self._outboundMiddleware ~= nil then
		local result = content

		-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
		for _, middlewareFunction: (object: Types.Content) -> any in self._outboundMiddleware do
			local returned = middlewareFunction(result)
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
			Output.log(`{debug.info(2, "s")}:{debug.info(2, "l")}`)
			local logOutput = string.format(
				Constants.CLIENT_FIRE_LOG,
				self._name,
				tostringData(result),
				RemotePacketSizeCounter.GetDataByteSize(result)
			)
			Output.log(logOutput)
		end

		ClientProcess.addToQueue(self._identifier, result)
	else
		if self.Logging then
			Output.log(`{debug.info(2, "s")}:{debug.info(2, "l")}`)
			local logOutput = string.format(
				Constants.CLIENT_FIRE_LOG,
				self._name,
				tostringData(content),
				RemotePacketSizeCounter.GetDataByteSize(content)
			)
			Output.log(logOutput)
		end

		ClientProcess.addToQueue(self._identifier, content)
	end
end

--[=[
	Connects the bridge to any events recieved from the server, this is when inbound middleware is ran. This shares identical behavior with [RemoteEvent.OnServerEvent:Connect].
	
	@within ClientBridge
	@param callback (content: Types.Content) -> ()
	@return RBXScriptConnection
]=]
function clientBridgePrototype:Connect(callback: (content: Types.Content) -> (), name: string?)
	Output.fatalAssert(tostring(self) == "ClientBridge", "connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)

	local line = debug.info(2, "l")
	local scriptName = debug.info(2, "s")

	return ClientConnection(self._identifier, function(content)
		if typeof(content) == "table" then
			if (content :: {})[1] == ClientIdentifiers.ref("REQUEST", 3, false) then
				return
			end
		end

		if self._inboundMiddleware ~= nil then
			local result = content

			-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
			for _, middlewareFunction: (object: any) -> any in self._inboundMiddleware do
				local returned = middlewareFunction(result)
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
					Constants.CLIENT_CONNECT_LOG,
					name or self._name,
					tostringData(result),
					RemotePacketSizeCounter.GetDataByteSize(result),
					scriptName,
					line
				)
				Output.log(logOutput)
			end

			if name then
				debug.profilebegin(name)
			end

			callback(result)

			if name then
				debug.profileend()
			end
		else
			if self.Logging then
				local logOutput = string.format(
					Constants.CLIENT_CONNECT_LOG,
					name or self._name,
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

			callback(content)

			if name then
				debug.profileend()
			end
		end
	end)
end

--[=[
	Connects the bridge to any events recieved from the server, this is when inbound middleware is ran. This shares identical behavior with [RemoteEvent.OnServerEvent:Wait].
	
	@within ClientBridge
	@yields
	@return any
]=]
function clientBridgePrototype:Wait()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Wait called with . instead of :")
	-- Again, very basic QoL implementation of :Wait()
	local thread = coroutine.running()
	self:Once(function(content)
		task.spawn(thread, content)
	end)
	return coroutine.yield()
end

--[=[
	Invokes the server, then returns a value afterwards. This function yields the thread until content is recieved.
	
	@yields
	@within ClientBridge
	@param content any
	@return any
]=]
function clientBridgePrototype:InvokeServerAsync(content: any)
	Output.fatalAssert(tostring(self) == "ClientBridge", "InvokeServerAsync called with . instead of :")

	local id = NetworkUtils.FromHex(NetworkUtils.CreateUUID())

	self:Fire({ ClientIdentifiers.ref("REQUEST", 3, false), id, content })

	local thread = coroutine.running()
	local connection
	connection = ClientProcess.connect(self._identifier, function(reply)
		if typeof(reply) ~= "table" then
			return
		end
		if (reply :: {})[1] == ClientIdentifiers.ref("REQUEST", 3, false) and (reply :: {})[2] == id then
			connection()
			task.spawn(thread, (reply :: {})[3])
		end
	end)
	return coroutine.yield()
end

--[=[
	Connects the bridge to any events recieved from the server, this is when inbound middleware is ran. This shares identical behavior with [clientBridgePrototype:Connect] with the difference being that the event instantly disconnects on recieved.
	
	@within ClientBridge
	@param func (content: Types.Content) -> ()
	@return RBXScriptConnection
]=]
function clientBridgePrototype:Once(func: (content: Types.Content) -> ())
	Output.fatalAssert(tostring(self) == "ClientBridge", "Once called with . instead of :")
	-- Instantly disconnects. Very basic QoL implementation
	local connection
	connection = self:Connect(function(content)
		connection:Disconnect()
		func(content)
	end)

	return connection
end

--[=[
	Destroys the bridge it was called on.
	@within ClientBridge
]=]
function clientBridgePrototype:Destroy()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Destroy called with . instead of :")
	-- Don't actually do any logic here- remember that ClientBridges are really just listening objects that let the end user communicate.
	table.clear(self)
	setmetatable(self, nil)
end

return function(name: string)
	local self = setmetatable({
		Logging = false,

		_identifier = ClientIdentifiers.ref(name, 3, true),
		_name = name,

		_inboundMiddleware = {},
		_outboundMiddleware = {},
	}, CLASS_METATABLE)

	-- Identifiers can be created by the end user too, so we have to tell BridgeNet2 that it's a bridge, not an identifier.
	ClientProcess.registerBridge(self._identifier)

	return self
end
