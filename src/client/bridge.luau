local ClientBridge = {}
local metatable = { __index = ClientBridge }
export type Identity = typeof(setmetatable({} :: {}, metatable))

local function constructor(name: string): Identity
	local self = setmetatable({}, metatable)

	return self
end

function ClientBridge.Fire() end

function ClientBridge.Connect() end

function ClientBridge.InvokeServer() end

function ClientBridge.OutboundMiddleware() end

function ClientBridge.InboundMiddleware() end

function ClientBridge.Wait() end

function ClientBridge.Once() end

return {
	new = constructor,
}
