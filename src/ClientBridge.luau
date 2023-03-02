--!strict
local ClientProcess = require(script.Parent.ClientProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

--[=[
	@class ClientBridge
]=]
local ClientBridge = {}
ClientBridge.__index = ClientBridge

-- Can't have functional class-specific typings within the actual class sadly
function ClientBridge._new(name: string)
	local self = setmetatable({}, ClientBridge)

	-- Default max wait time is fine
	self._identifier = Identifiers.ReferenceIdentifier(name)

	ClientProcess._idIntoBridge(self._identifier)

	self._name = name

	-- Middleware
	self._inboundMiddleware = {}
	self._outboundMiddleware = {}

	return self
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

		ClientProcess._addToQueue(self._identifier, result)
	else
		ClientProcess._addToQueue(self._identifier, object)
	end
end

function ClientBridge:Connect(callback: (object: any) -> ())
	ClientProcess._connect(self._identifier, function(object)
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

			callback(result)
		else
			callback(object)
		end
	end)
end

function ClientBridge:Once<T>(func: (object: T & {}) -> ())
	local connection
	connection = self:Connect(function(object)
		connection:Disconnect()
		func(object)
	end)
	return connection
end

function ClientBridge:Wait()
	local thread = coroutine.running()
	self:Connect(function(object)
		coroutine.resume(thread, object)
	end)
	return coroutine.yield()
end


function ClientBridge:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

export type ClientBridge<T> = {
	Fire: (self: ClientBridge<T>, object: T) -> (),
	Connect: (self: ClientBridge<T>, callback: (object: T) -> ()) -> (),
	InboundMiddleware: (
		self: ClientBridge<T>,
		{ ((object: T) -> T) | ((object: T) -> ()) | ((object: T) -> nil) }
	) -> (),
	OutboundMiddleware: (
		self: ClientBridge<T>,
		{ ((object: T) -> T) | ((object: T) -> ()) | ((object: T) -> nil) }
	) -> (),
	Destroy: () -> (),
}

return ClientBridge
