--!strict
local ClientProcess = require(script.Parent.ClientProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)

--[[
	@class ClientBridge
]]
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
	self._inboundMiddleware = middlewareTable
end

function ClientBridge:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	self._outboundMiddleware = middlewareTable
end

function ClientBridge:Fire(object)
	Output.fatalAssert(
		typeof(object) == "table",
		string.format("ClientBridge:Fire takes a table, got %*", typeof(object))
	)

	if self._outboundMiddleware ~= nil then
		local result = object

		-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
		for _, middlewareFunction: (object: any) -> any in self._outboundMiddleware do
			result = middlewareFunction(result)
				or (
					Output.silent(
						string.format(
							"Outbound middleware on bridge %* returned nil, defaulting to object.",
							self._name
						)
					) or object
				)
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
				result = middlewareFunction(result)
					or (
						Output.silent(
							string.format(
								"Inbound middleware on bridge %* returned nil, defaulting to object.",
								self._name
							)
						) or object
					)
			end

			callback(result)
		else
			callback(object)
		end
	end)
end

function ClientBridge:Destroy()
	for key, _ in self do
		-- No complex instances here either, just set everything to nil.
		self[key] = nil
	end
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
