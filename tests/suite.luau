local colorful = require("@vendor/lunePackages/colorful/init")
local utils = require("@tests/utils")

local blue = colorful.color.blueBright
local bold = colorful.modifier.bold
local red = colorful.color.redBright
local errorStyle = colorful.combineStyles({ red })
local infoStyle = colorful.combineStyles({ blue })
local logStyle = colorful.combineStyles({ bold })

local failureFormatStrings = {
	equality = `\t{infoStyle("Left:    ") .. "%*"}\n\t{infoStyle("Right:   ") .. "%*"}\n\n\t{logStyle(
		"Expected values to be equal"
	)}`,

	truthy = `\t{"Expected value [%*] to be truthy"}\n`,
}

export type Interface = {
	expect: {
		equal: <T>(left: T, right: T) -> (),
		truthy: <T>(value: T) -> (),
	},
}

local function printTable(tbl: { [unknown]: unknown })
	local lines = {}

	for key, value in tbl do
		if typeof(value) ~= "table" and typeof(value) ~= "buffer" then
			table.insert(lines, `\t\[{key}] = {value}`)
		elseif typeof(value) == "table" then
			local result = printTable(value :: {})
			local replaced = string.gsub(result, "\n", "\n\t")

			table.insert(lines, `\t\[{key}] = {replaced}`)
		elseif typeof(value) == "buffer" then
			return utils.bufferFormatted(value)
		end
	end

	return `\{\n{table.concat(lines, ",\n")}\n\}`
end

local function prettytostring(value: unknown): string
	if typeof(value) == "table" then
		return printTable(value :: any)
	elseif typeof(value) == "buffer" then
		return utils.bufferFormatted(value)
	else
		return tostring(value)
	end
end

-- Taken from Roact: https://github.com/Roblox/roact/blob/master/src/assertDeepEqual.lua
local function deepEqual(a: any, b: any): (boolean, string?)
	if typeof(a) ~= typeof(b) then
		local message = ("{1} is of type %s, but {2} is of type %s"):format(typeof(a), typeof(b))
		return false, message
	end

	if typeof(a) == "number" then
		-- Floating point error!
		return math.abs(a - b) < 0.0001
	end

	if typeof(a) == "table" then
		local visitedKeys = {}

		for key, value in a do
			visitedKeys[key] = true

			local success, innerMessage = deepEqual(value, b[key])
			if not success and innerMessage then
				local message = innerMessage
					:gsub("{1}", ("{1}[%s]"):format(prettytostring(key)))
					:gsub("{2}", ("{2}[%s]"):format(prettytostring(key)))

				return false, message
			end
		end

		for key, value in b do
			if not visitedKeys[key] then
				local success, innerMessage = deepEqual(value, a[key])

				if not success and innerMessage then
					local message = innerMessage
						:gsub("{1}", ("{1}[%s]"):format(prettytostring(key)))
						:gsub("{2}", ("{2}[%s]"):format(prettytostring(key)))

					return false, message
				end
			end
		end

		return true, nil
	end

	if typeof(a) == "buffer" then
		if buffer.len(a) ~= buffer.len(b) then
			return false, "{1} ~= {2}"
		end

		for i = 0, buffer.len(a) - 1 do
			if buffer.readu8(a, i) ~= buffer.readu8(b, i) then
				print("false")
				return false, `\{1\}[{i}] ~= \{2\}[{i}]`
			end
		end

		return true
	end

	if a == b then
		return true, nil
	end

	local message = "{1} ~= {2}"
	return false, message
end

local function interface(failCallback: (err: string) -> (), successCallback: () -> ()): Interface
	local function expectEqual<T>(left: T, right: T)
		local equality = deepEqual(left, right)

		if equality then
			successCallback()
			return
		end

		failCallback(string.format(failureFormatStrings.equality, prettytostring(left), prettytostring(right)))
	end

	local function expectTruthy<T>(value: T)
		if value then
			successCallback()
			return
		end

		failCallback(string.format(failureFormatStrings.truthy, prettytostring(value)))
	end

	return {
		expect = {
			equal = expectEqual,
			truthy = expectTruthy,
		},
	}
end

local function case(name: string, test: (interface: Interface) -> ()): () -> boolean
	local checks: { boolean } = {}
	local failureMessages: { string } = {}

	local caseInterface = interface(function(err)
		table.insert(checks, false)
		table.insert(failureMessages, err)
	end, function()
		table.insert(checks, true)
	end)

	return function(): boolean
		local success, err: any = pcall(test, caseInterface)

		if success and not table.find(checks, false) then
			print(infoStyle("\t- Test case passed: ") .. name)
			return true
		elseif success and table.find(checks, false) then
			print(`\t{errorStyle("- Test case failed: ")}{name}`)
			for _, message in failureMessages do
				print(message)
			end
			return false
		elseif not success then
			print(errorStyle("\t- Error in test case: ") .. name .. "\n\n", err, "\n")
		end

		return false
	end
end

return function()
	local cases: { () -> boolean } = {}

	return function(name: string, test: (interface: Interface) -> ())
		table.insert(cases, case(name, test))
	end, function()
		return cases
	end
end
