local installGitDependencies = require("@ext/installGitDependencies")
local installWallyDependencies = require("@ext/installWallyDependencies")
local process = require("@lune/process")

if #process.args == 0 then
	installGitDependencies()
	installWallyDependencies()
elseif process.args[1] == "git" then
	installGitDependencies()
elseif process.args[1] == "wally" then
	installWallyDependencies()
end
