local process = require("@src/server/process")
local identifiers = require("@src/server/identifiers")
local dataModelTree = require("@src/dataModelTree")
local logger = require("@src/logger").new("server")
local logStrings = require("@src/logStrings")

return function(): ()
	local treeRes = dataModelTree(true)
	if not treeRes.success then
		logger:warn(string.format(logStrings.errors.TREE_FAILURE, treeRes.err))
		print(treeRes.trace)
		return logger:fatal("exiting bridgenet2")
	end

	process.init(treeRes.value)
	identifiers.init(treeRes.value)

	logger:log(logStrings.logs.SERIAL_LOADED)
end
