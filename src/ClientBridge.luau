local ClientProcess = require(script.Parent.ClientProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

--[=[
	@class ClientBridge
]=]

local function toStringData(data)
	return TableKit.ToString(data)
end

local ClientBridge = {}
ClientBridge.__index = ClientBridge

function ClientBridge:RateLimit()
	Output.error("cannot call :RateLimit() from client")
end

function ClientBridge:DisableRateLimit()
	Output.error("cannot call :DisableRateLimit() from client")
end

function ClientBridge:InboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("InboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.errorAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._inboundMiddleware = middlewareTable
end

function ClientBridge:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("OutboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.errorAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

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

		if self._logging then
			Output.log(`fired {self._name} with data {toStringData(result)}`)
		end

		ClientProcess._addToQueue(self._identifier, result)
	else
		if self._logging then
			Output.log(`fired {self._name} with data {toStringData(object)}`)
		end

		ClientProcess._addToQueue(self._identifier, object)
	end
end

function ClientBridge:Connect(callback: (object: any) -> ())
	local methods = {
		Connected = true,
	}
	local disconnect = ClientProcess._connect(self._identifier, function(object)
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

			if self._logging then
				Output.log(`bridge {self._name} got fired from server with data {toStringData(result)}`)
			end

			callback(result)
		else
			if self._logging then
				Output.log(`bridge {self._name} got fired from server with data {toStringData(object)}`)
			end

			callback(object)
		end
	end)

	methods["Disconnect"] = function()
		disconnect()
		methods.Connected = false
	end

	return methods
end

function ClientBridge:StartLogging()
	self._logging = true
end

function ClientBridge:StopLogging()
	self._logging = false
end

function ClientBridge:Wait()
	local thread = coroutine.running()
	self:Connect(function(player, object)
		coroutine.resume(thread, player, object)
	end)
	return coroutine.yield()
end

function ClientBridge:Once(func: (object: any) -> ())
	local connection
	connection = self:Connect(function(object)
		connection:Disconnect()
		func(object)
	end)
	return connection
end

function ClientBridge:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return function(name: string)
	local self = setmetatable({
		_identifier = Identifiers.ReferenceIdentifier(name),
		_name = name,

		-- middleware
		_inboundMiddleware = {},
		_outboundMiddleware = {},
	} :: {}, ClientBridge)

	ClientProcess._idIntoBridge(self._identifier)

	return self
end
