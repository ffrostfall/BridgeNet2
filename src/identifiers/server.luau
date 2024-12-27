local dataModelTree = require("@src/dataModelTree")
local logger = require("@src/logger").new("server identifiers")
local logStrings = require("@src/logStrings")
local map = require("@src/identifiers/map")

local counter: Identifier = 1
local container: Folder = nil

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

function server.register(name: string)
	assertContainer("register")

	counter += 1
	local chosenId = counter

	container:SetAttribute(name, chosenId)
	map.addIdentifier(name, counter)
end

return server
