local dataModelTree = require("@src/dataModelTree")
local logger = require("@src/logger").new("server identifiers")
local logStrings = require("@src/logStrings")
local identifierMap = require("@src/identifierMap")

local counter: Identifier = 1
local container: Folder

export type Identifier = number

local function assertContainer(func: string): ()
	if not container then
		return logger:fatal(string.format(logStrings.errors.ACCESS_WITHOUT_INITIALIZATION, func))
	end
end

local server = {}

function server.init(tree: dataModelTree.Identity)
	container = tree.container
end

function server.register(name: string): number
	assertContainer("register")

	counter += 1
	local chosenId = counter

	container:SetAttribute(name, chosenId)
	identifierMap.addIdentifier(name, counter)

	return counter
end

return server
