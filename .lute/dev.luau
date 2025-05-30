local process = require("@lute/process")
local task = require("@lute/task")

local c = coroutine.create(function()
	-- cast away the evil luau scheduler
	task.defer()

	process.run({
		"rojo",
		"sourcemap",
		"roblox-tests.project.json",
		"--output",
		"sourcemap.json",
		"--watch",
		"--include-non-scripts",
	})
end)

coroutine.resume(c)

process.run("rojo", { "serve", "roblox-tests.project.json" }, { stdio = "forward" })
