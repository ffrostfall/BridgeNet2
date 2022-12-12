--!strict
local HttpService = game:GetService("HttpService")

local Output = require(script.Parent.Output)

local NetworkUtils = {}

function NetworkUtils.CreateUUID(): string
	return string.gsub(HttpService:GenerateGUID(false), "-", "") :: string
end

function NetworkUtils.FromHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", string.format("FromHex takes string, got %*", typeof(toConvert)))
	local len = #toConvert
	local result = table.create(len/2)
	for i = 1, len, 2 do
		result[(i + 1)/2] = tonumber(string.sub(toConvert, i, i + 1), 16)
	end
	return string.char(unpack(result))
end

function NetworkUtils.ToHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", string.format("ToHex takes string, got %*", typeof(toConvert)))
	return string.format(string.rep("%02X", #toConvert), string.byte(toConvert, 1, -1))
end

function NetworkUtils.ToReadableHex(toConvert: string): string
	Output.fatalAssert(
		typeof(toConvert) == "string",
		string.format("ToReadableHex takes string, got %*", typeof(toConvert))
	)
	return string.format(string.rep("%02X ", #toConvert), string.byte(toConvert, 1, -1))
end

function NetworkUtils.NumberToBestForm(num: number): number | string
	local asString = tostring(num)
	if #asString <= 7 then
		return asString
	else
		return num
	end
end

return NetworkUtils
