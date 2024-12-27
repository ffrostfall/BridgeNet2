--!optimize 1
export type LogLevel = "trace" | "log" | "warn" | "fatal" | "halt"

local function getNameFromStack()
	local name = debug.info(3, "s")
	local split = string.split(name, ".")

	return `{split[#split - 1]}/{split[#split]}`
end

local logger = {}
local metatable = { __index = logger }
export type Identity = typeof(setmetatable(
	{} :: {
		_name: string,
	},
	metatable
))

local function constructor(name: string?): Identity
	local self = setmetatable({}, metatable)

	self._name = name or getNameFromStack()

	return self
end

function logger.log(self: Identity, text: string)
	print(`[bn2/{self._name}] {text}`)
end

function logger.warn(self: Identity, text: string)
	warn(`[bn2/{self._name}] {text}`)
end

function logger.fatal(self: Identity, text: string): never
	return error(`[bn2/{self._name}] {text}`, 0)
end

return {
	new = constructor,
}
