local async = require("@vendor/lunePackages/async")
local colorful = require("@vendor/lunePackages/colorful")
local spawnDarklua = require("@ext/spawnDarklua")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local spawnSourcemap = require("@ext/spawnSourcemap")
local task = require("@lune/task")
local process = require("@lune/process")

local function getargs(): {
	timetracing: boolean,
	verbose: boolean,
	testmode: "benchmark" | "dev",
}
	local args = process.args
	return {
		timetracing = table.find(args, "timetracing") ~= nil,
		verbose = table.find(args, "verbose") ~= nil,
		testmode = if table.find(args, "benchmark") ~= nil then "benchmark" else "dev",
	}
end

local args = getargs()
process.env["timetracing"] = tostring(args.timetracing)
process.env["verbose"] = tostring(args.verbose)
process.env["testmode"] = args.testmode

print(colorful.color.blueBright("Starting development server"))

spawnSourcemap(true)

-- avoid sourcemap dependency issues
task.wait(0.5)

spawnDarklua()

async(spawnProcess("rojo", {
	"serve",
	"test-build.project.json",
}))
