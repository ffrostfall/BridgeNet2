local fs = require("@lute/fs")
local process = require("@lute/process")
local toml = require("@vendor/toml")

local mirror_configs = fs.listdir("./benches/mirror_list")

-- thank you nick from lute
local function get_git_version(): { major: number, minor: number, path: number }
	local git_ver_string = process.run({ "git", "--version" }).stdout
	local git_ver = string.split(git_ver_string, " ")[3]
	local components = string.split(git_ver, ".")

	return {
		major = tonumber(components[1]) or 0,
		minor = tonumber(components[2]) or 0,
		path = tonumber(components[3]) or 0,
	}
end

local git_version = get_git_version()

local function pretty_run(
	args: string | { string },
	options: process.ProcessRunOptions?
): process.ProcessResult
	local result = process.run(args, options)
	print(result.stdout)

	if result.exitcode ~= 0 then
		print(`Process failed with exit code {result.exitcode}`)
		print(result.stderr)
	end

	return result
end

for _, file in mirror_configs do
	if string.sub(file.name, -5) ~= "toml" then
		continue
	end

	local path = "./benches/mirror_list/" .. file.name

	local config = toml.deserialize(fs.readasync(path))
	assert(type(config) == "table", `[mirror] {path} must be a table`)

	-- Lovely type errors :3
	assert(type(config.revision) == "string", `[mirror] {path} config.revision must be a string`)
	assert(type(config.branch) == "string", `[mirror] {path} config.branch must be a string`)
	assert(type(config.name) == "string", `[mirror] {path} config.name must be a string`)
	assert(type(config.remote) == "string", `[mirror] {path} config.remote must be a string`)

	local mirror_path = "./benches/mirrors/" .. config.name
	local full_mirror_path = mirror_path .. "/src/"
	if fs.type(mirror_path) == "dir" then
		pretty_run(
			{ "git", "fetch", "--depth=1", "origin", config.revision },
			{ cwd = full_mirror_path }
		)

		pretty_run({ "git", "checkout", config.revision }, { cwd = full_mirror_path })

		continue
	end

	if git_version.major >= 3 or (git_version.major == 2 and git_version.minor >= 49) then
		pretty_run({
			"git",
			"clone",
			"--depth=1",
			"--revision",
			config.revision,
			config.remote,
			full_mirror_path,
		})
	else
		pretty_run({
			"git",
			"clone",
			"--depth=1",
			"--branch",
			config.branch,
			config.remote,
			full_mirror_path,
		})
	end
end
