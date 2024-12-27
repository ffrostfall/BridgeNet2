local spawnProcess = require("@vendor/lunePackages/spawnProcess")

return function()
	spawnProcess("darklua", {
		"process",
		"src/",
		"build/package/",
		"--watch",
	})

	spawnProcess("darklua", {
		"process",
		"tests/roblox/",
		"build/tests/",
		"--watch",
	})
end
