local ServerProcess = require(script.Parent.ServerProcess)
local Identifiers = require(script.Parent.Identifiers)
local Output = require(script.Parent.Output)

local ServerBridge = {}
ServerBridge.__index = ServerBridge

function ServerBridge._new(name: string)
	local self = setmetatable({}, ServerBridge)

	-- Since this is the server, ReferenceIdentifier will not yield
	self._identifier = Identifiers.ReferenceIdentifier(name)

	self._inboundMiddlewares = nil
	self._name = name

	ServerProcess._idIntoBridge(self._identifier)

	return self
end

function ServerBridge:InboundMiddleware(middlewareTable: { (player: Player, object: any) -> any })
	self._inboundMiddlewares = middlewareTable
end

function ServerBridge:OutboundMiddleware(middlewareTable: { (target: ServerProcess.TPlayerType, object: any) -> any })
	self._outboundMiddlewares = middlewareTable
end

function ServerBridge:Connect<T>(callback: (player: Player, object: T) -> nil)
	ServerProcess._connect(self._identifier, function(player, object)
		if self._inboundMiddlewares ~= nil then
			local result = object

			-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
			for _, middlewareFunction: (player: Player, object: any) -> any in self._inboundMiddlewares do
				result = middlewareFunction(player, result)
					or (
						Output.silent(
							string.format(
								"Inbound middleware on bridge %* returned nil, defaulting to object.",
								self._name
							)
						) or object
					)
			end

			callback(player, result)
		else
			callback(player, object)
		end
	end)
end

function ServerBridge:Fire<T>(target: ServerProcess.TPlayerType, object: T)
	if self._outboundMiddleware ~= nil then
		local result = object

		-- Loop through the middleware functions- raise a silent log if any of them return nil for debugging.
		for _, middlewareFunction: (player: ServerProcess.TPlayerType, object: any) -> any in self._outboundMiddlewares do
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

		ServerProcess._addToQueue(target, self._identifier, result)
	else
		ServerProcess._addToQueue(target, self._identifier, object)
	end
end

function ServerBridge:Destroy()
	for key, _ in self do
		-- We don't have any complex instances in ServerBridge, so not much clean-up code is required.
		self[key] = nil
	end
	setmetatable(self, nil)
end

-- () -> () means it returns void. Pretty neat trick I learned from Aloroider
export type ServerBridge<T> = {
	Connect: (self: ServerBridge<T>, (player: Player, object: T) -> T?) -> (),
	Fire: (self: ServerBridge<T>, target: ServerProcess.TPlayerType, object: T) -> (),
	InboundMiddlewares: (self: ServerBridge<T>, { (player: Player, object: T) -> T? }) -> (),
	OutboundMiddlewares: (self: ServerBridge<T>, { (target: ServerProcess.TPlayerType, object: T) -> T? }) -> (),
	Destroy: (self: ServerBridge<T>) -> (),
}

return ServerBridge
