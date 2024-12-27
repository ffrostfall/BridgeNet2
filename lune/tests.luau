local colorful = require("@vendor/lunePackages/colorful")
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local process = require("@lune/process")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local task = require("@lune/task")

local tests = fs.readDir("tests/lune/")
local luaurc = serde.decode("json", fs.readFile(".luaurc"))
local Vector3 = ((roblox :: any).Vector3) :: typeof(Vector3)
local CFrame = (roblox :: any).CFrame :: typeof(CFrame)

local testCases = {}

function injectedRequire(path: string): any
	if string.sub(path, 1, 5) == "@lune" then
		return require(path) :: any
	end

	local workingPath = ""
	local parts = string.split(path, "/")

	if string.sub(parts[1], 1, 1) == "@" then
		workingPath = luaurc.aliases[string.sub(parts[1], 2, -1)]
		table.remove(parts, 1)

		workingPath ..= table.concat(parts, "/")

		local filePath = ""
		if fs.isDir(workingPath) then
			filePath = workingPath .. "/init.luau"
		else
			filePath = workingPath .. ".luau"
		end

		local compiled = luau.compile(fs.readFile(filePath))
		local loaded = luau.load(compiled, {
			environment = env(),
		})

		process.env["__currentModule"] = workingPath
		local result = loaded()
		process.env["__currentModule"] = nil

		return result
	else
		assert(process.env["__currentModule"], "Cannot require non-aliased modules outside of a module context")

		local currentModule = process.env["__currentModule"]

		local source = fs.readFile(currentModule .. path .. ".luau")

		local compiled = luau.compile(source)
		local loaded = luau.load(compiled, {
			environment = env(),
		})

		process.env["__currentModule"] = currentModule .. path
		local result = loaded()
		process.env["__currentModule"] = currentModule

		return result
	end
end

function env()
	return {
		Vector3 = Vector3,
		task = task,
		CFrame = CFrame,

		require = injectedRequire,
	}
end

for _, fileName in tests do
	testCases[fileName] = luau.load(luau.compile(fs.readFile(`tests/lune/{fileName}`)), {
		environment = env(),
	})
end

for fileName, runner in testCases do
	local results = runner()
	print(colorful.modifier.bold(fileName))

	for _, case in results do
		case()
	end
end
