local ClientProcess = require(script.Parent.ClientProcess)
local Identifiers = require(script.Parent.Identifiers)

local ClientBridge = {}
ClientBridge.__index = ClientBridge

-- Can't have functional class-specific typings within the actual class sadly
function ClientBridge._new(name: string)
	local self = setmetatable({}, ClientBridge)

	-- Default max wait time is fine
	self._identifier = Identifiers.ReferenceIdentifier(name)
	ClientProcess._idIntoBridge(self._identifier)

	return self
end

function ClientBridge:Fire(object)
	ClientProcess._addToQueue(self._identifier, object)
end

function ClientBridge:Connect(callback: (obj: any) -> ())
	ClientProcess._connect(self._identifier, callback)
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
	Destroy: () -> (),
}

return ClientBridge
