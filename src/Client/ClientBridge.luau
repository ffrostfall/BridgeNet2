--!strict
local ClientConnection = require(script.Parent.ClientConnection)
local ClientIdentifiers = require(script.Parent.ClientIdentifiers)
local ClientProcess = require(script.Parent.ClientProcess)
local Constants = require(script.Parent.Parent.Constants)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local Types = require(script.Parent.Parent.Types)

local function toStringData(data: unknown)
	if typeof(data) == "table" then
		return TableKit.ToString(data :: {})
	else
		return tostring(data)
	end
end

local clientBridgePrototype = {}

local CLASS_METATABLE = { __index = clientBridgePrototype }

function CLASS_METATABLE:__tostring()
	return "ClientBridge"
end

function clientBridgePrototype:RateLimit()
	Output.warn("cannot call :RateLimit() from client")
end

function clientBridgePrototype:DisableRateLimit()
	Output.warn("cannot call :DisableRateLimit() from client")
end

function clientBridgePrototype:InboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "InboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("InboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._inboundMiddleware = middlewareTable
end

function clientBridgePrototype:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "OutboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("OutboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._outboundMiddleware = middlewareTable
end

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
			local logOutput = string.format(
				Constants.CLIENT_FIRE_LOG,
				self._name,
				toStringData(result),
				RemotePacketSizeCounter.GetDataByteSize(result)
			)
			Output.log(logOutput)
		end

		ClientProcess.addToQueue(self._identifier, result)
	else
		if self.Logging then
			local logOutput = string.format(
				Constants.CLIENT_FIRE_LOG,
				self._name,
				toStringData(content),
				RemotePacketSizeCounter.GetDataByteSize(content)
			)
			Output.log(logOutput)
		end

		ClientProcess.addToQueue(self._identifier, content)
	end
end

function clientBridgePrototype:Connect(callback: (content: Types.Content) -> ()): RBXScriptConnection
	Output.fatalAssert(tostring(self) == "ClientBridge", "connect called with . instead of :")

	return ClientConnection(self._identifier, function(content)
		if typeof(content) == "table" then
			if (content :: {})[1] == ClientIdentifiers.ref("REQUEST") then
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
					self._name,
					toStringData(result),
					RemotePacketSizeCounter.GetDataByteSize(result)
				)
				Output.log(logOutput)
			end

			callback(result)
		else
			if self.Logging then
				local logOutput = string.format(
					Constants.CLIENT_CONNECT_LOG,
					self._name,
					toStringData(content),
					RemotePacketSizeCounter.GetDataByteSize(content)
				)
				Output.log(logOutput)
			end

			callback(content)
		end
	end)
end

function clientBridgePrototype:Wait()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Wait called with . instead of :")
	-- Again, very basic QoL implementation of :Wait()
	local thread = coroutine.running()
	self:Once(function(content)
		coroutine.resume(thread, content)
	end)
	return coroutine.yield()
end

function clientBridgePrototype:InvokeServerAsync(content: any)
	Output.fatalAssert(tostring(self) == "ClientBridge", "InvokeServerAsync called with . instead of :")
	self:Fire({ ClientIdentifiers.ref("REQUEST"), content })
	local thread = coroutine.running()
	local connection
	connection = ClientProcess.connect(self._identifier, function(reply)
		if typeof(reply) ~= "table" then
			return
		end
		if (reply :: {})[1] == ClientIdentifiers.ref("REQUEST") then
			connection()
			coroutine.resume(thread, (reply :: {})[2])
		end
	end)
	return coroutine.yield()
end

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

function clientBridgePrototype:Destroy()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Destroy called with . instead of :")
	-- Don't actually do any logic here- remember that ClientBridges are really just listening objects that let the end user communicate.
	table.clear(self)
	setmetatable(self, nil)
end

--[=[
	@class ClientBridge
]=]
return function(name: string)
	local self = setmetatable({
		Logging = false,

		_identifier = ClientIdentifiers.ref(name),
		_name = name,

		_inboundMiddleware = {},
		_outboundMiddleware = {},
	}, CLASS_METATABLE)

	-- Identifiers can be created by the end user too, so we have to tell BridgeNet2 that it's a bridge, not an identifier.
	ClientProcess.registerBridge(self._identifier)

	return self
end
