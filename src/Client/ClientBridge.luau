--!strict
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

local ClientBridge = {}
ClientBridge.__index = ClientBridge

function ClientBridge:RateLimit()
	Output.warn("cannot call :RateLimit() from client")
end

function ClientBridge:DisableRateLimit()
	Output.warn("cannot call :DisableRateLimit() from client")
end

function ClientBridge:InboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("InboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._inboundMiddleware = middlewareTable
end

function ClientBridge:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("OutboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._outboundMiddleware = middlewareTable
end

function ClientBridge:Fire(content: any)
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

function ClientBridge:Connect(callback: (content: Types.Content) -> ())
	local disconnect = ClientProcess.connect(self._identifier, function(content)
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

	return {
		Disconnect = function()
			disconnect()
		end,
	}
end

function ClientBridge:Wait()
	-- Again, very basic QoL implementation of :Wait()
	local thread = coroutine.running()
	self:Connect(function(content)
		coroutine.resume(thread, content)
	end)
	return coroutine.yield()
end

function ClientBridge:Once(func: (content: Types.Content) -> ())
	-- Instantly disconnects. Very basic QoL implementation
	local connection
	connection = self:Connect(function(content)
		connection:Disconnect()
		func(content)
	end)

	return connection
end

function ClientBridge:Destroy()
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
	}, ClientBridge)

	-- Identifiers can be created by the end user too, so we have to tell BridgeNet2 that it's a bridge, not an identifier.
	ClientProcess.registerBridge(self._identifier)

	return self
end
