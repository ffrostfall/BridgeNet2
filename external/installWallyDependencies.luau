local async = require("@vendor/lunePackages/async")
local process = require("@lune/process")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local spawnSourcemap = require("@ext/spawnSourcemap")
local styles = require("./data/styles")

return function()
	print(styles.header("Installing Wally dependencies"))
	async(spawnProcess("wally", { "install" }))

	print(styles.header("Building sourcemap"))

	async(spawnSourcemap(false))

	print(styles.header("Exporting types"))

	process.spawn("wally-package-types", { "--sourcemap", "sourcemap.json", "Packages" }, {
		stdio = "forward",
	})

	print("\n" .. styles.success("Done!"))
end
