local HttpService = game:GetService("HttpService")

local Output = require(script.Parent.Output)

local NetworkUtils = {}

function NetworkUtils.CreateUUID(): string
	return string.gsub(HttpService:GenerateGUID(false), "-", "") :: string
end

function NetworkUtils.FromHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", string.format("FromHex takes string, got %*", typeof(toConvert)))
	return string.gsub(toConvert, "..", function(cc)
		return string.char(tonumber(cc, 16))
	end) :: string
end

function NetworkUtils.ToHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", string.format("ToHex takes string, got %*", typeof(toConvert)))
	return string.gsub(toConvert, ".", function(c)
		return string.format("%02X", string.byte(c :: any))
	end) :: string
end

function NetworkUtils.NumberToBestForm(num: number): number | string
	if string.len(tostring(num)) <= 7 then
		return tostring(num)
	else
		return num
	end
end

function NetworkUtils.DictionaryToTable(dict: { [string]: any })
	Output.fatalAssert(typeof(dict) == "table", "dict must be a dictionary")
	Output.warnAssert(getmetatable(dict) == nil, "passed dictionary has a metatable, this is not recommended")

	local keys = {}
	for key, _ in dict do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		return string.lower(a) < string.lower(b)
	end)

	local toReturn = {}
	for _, v in keys do
		table.insert(toReturn, dict[v])
	end

	return toReturn
end

return NetworkUtils