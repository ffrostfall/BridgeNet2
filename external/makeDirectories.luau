local fs = require("@lune/fs")

local function reconcileDirectory(path: string)
	if not fs.isDir(path) then
		fs.writeDir(path)
	end
end

return function()
	reconcileDirectory("build/")
	reconcileDirectory("build/package/")
	reconcileDirectory("build/tests/")
end
