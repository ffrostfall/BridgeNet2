local Output = require(script.Parent.Output)

local roots = {}

local Root = {}
Root.__index = Root

function Root._new(structure: { [string]: any })
	Output.fatalAssert(
		typeof(structure) == "table",
		string.format("Root first arg takes table, got %*", typeof(structure))
	)

	local self = setmetatable({}, Root)

	for key, bridge in structure do
	end

	return self
end

function Root:Server() end

function Root:Client() end

return {
	create = function(name: string, structure: { [string]: { any } | string })
		Output.fatalAssert(
			typeof(name) == "string",
			string.format("Root second arg takes string, got %*", typeof(structure))
		)

		local RootObject = Root._new(structure)
		roots[name] = RootObject
		return RootObject
	end,
	get = function(name: string)
		Output.logAssert(roots[name] ~= nil, "Attempted to get a null root space")
		return roots[name]
	end,
}
