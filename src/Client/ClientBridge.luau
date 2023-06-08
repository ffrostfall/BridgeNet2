--!strict
local ClientIdentifiers = require(script.Parent.ClientIdentifiers)
local ClientProcess = require(script.Parent.ClientProcess)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)

local function toStringData(data)
	return TableKit.ToString(data)
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

function ClientBridge:Fire(object)
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
				`fired {self._name} with data \n---------------\n{toStringData(result)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
					result
				)})\n`
			)
		end

		ClientProcess.addToQueue(self._identifier, result)
	else
		if self.Logging then
			Output.log(
				`fired {self._name} with data \n---------------\n{toStringData(object)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
					object
				)})\n`
			)
		end

		ClientProcess.addToQueue(self._identifier, object)
	end
end

function ClientBridge:Connect(callback: (object: any) -> ())
	local disconnect = ClientProcess.connect(self._identifier, function(object)
		if self._inboundMiddleware ~= nil then
			local result = object

			-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
			for _, middlewareFunction: (player: Player, object: any) -> any in self._inboundMiddleware do
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
				Output.log(
					`bridge {self._name} got fired from server with data \n---------------\n{toStringData(result)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
						result
					)})\n`
				)
			end

			callback(result)
		else
			if self.Logging then
				Output.log(
					`bridge {self._name} got fired from server with data \n---------------\n{toStringData(object)}\n---------------\n({RemotePacketSizeCounter.GetDataByteSize(
						object
					)})\n`
				)
			end

			callback(object)
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
	self:Connect(function(object)
		coroutine.resume(thread, object)
	end)
	return coroutine.yield()
end

function ClientBridge:Once(func: (object: any) -> ())
	-- Instantly disconnects. Very basic QoL implementation
	local connection
	connection = self:Connect(function(object)
		connection:Disconnect()
		func(object)
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
		_identifier = ClientIdentifiers.ref(name),
		_name = name,

		Logging = false,

		-- middleware
		_inboundMiddleware = {},
		_outboundMiddleware = {},
	}, ClientBridge)

	-- Identifiers can be created by the end user too, so we have to tell BridgeNet2 that it's a bridge, not an identifier.
	ClientProcess.registerBridge(self._identifier)

	return self
end
