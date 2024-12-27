local async = require("@vendor/lunePackages/async")
local fs = require("@lune/fs")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("./data/styles")

return function()
	print(styles.header("Cloning git repositories"))
	async(spawnProcess("git", {
		"clone",
		"https://github.com/ffrostfall/lunePackages.git",
		"vendor/lunePackagesRepo",
	}))

	print(styles.header("Copying repositories to vendor"))
	if fs.isDir("vendor/lunePackages") then fs.removeDir("vendor/lunePackages") end
	fs.copy("vendor/lunePackagesRepo", "vendor/lunePackages")

	fs.removeDir("vendor/lunePackagesRepo")
end
