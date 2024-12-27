local logger = require("@src/logger").new("client (parallel)")
local logStrings = require("@src/logStrings")
local identifierMap = require("@src/identifierMap")
local dataModelTree = require("@src/dataModelTree")

local tree: dataModelTree.Identity

local function disallowed(name: string): never
	return logger:fatal(string.format(logStrings.errors.PARALLEL_DISALLOWED, name))
end

local ClientBridge = {}
local metatable = { __index = ClientBridge }
export type Identity = typeof(setmetatable(
	{} :: {
		_id: number,
	},
	metatable
))

local function constructor(name: string, timeout: number?): Identity
	if not tree then
		return logger:fatal(logStrings.errors.ACCESS_WITHOUT_INITIALIZATION)
	end

	local self = setmetatable({}, metatable)

	local start = os.clock()
	while (not identifierMap.fromName(name)) and (os.clock() - start <= (timeout or 1)) do
		task.wait()
	end

	local id = identifierMap.fromName(name)
	if not id then
		return logger:fatal(logStrings.errors.ID_TIMEOUT_EXHAUSTED)
	end

	self._id = id

	return self
end

function ClientBridge.Fire(self: Identity, value: any)
	tree.parallel:Fire(self._id, value)
end

function ClientBridge.Connect(self: Identity) end

function ClientBridge.InvokeServer()
	disallowed("ParallelClientBridge:InvokeServer")
end

function ClientBridge.OutboundMiddleware()
	disallowed("ParallelClientBridge:OutboundMiddleware")
end

function ClientBridge.InboundMiddleware()
	disallowed("ParallelClientBridge:InboundMiddleware")
end

function ClientBridge.Wait()
	disallowed("ParallelClientBridge:Wait")
end

function ClientBridge.Once()
	disallowed("ParallelClientBridge:Once")
end

return {
	new = constructor,
	tree = function(passed: dataModelTree.Identity)
		tree = passed
	end,
}
