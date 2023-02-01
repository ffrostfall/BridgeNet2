--!strict
local HttpService = game:GetService("HttpService")

local Output = require(script.Parent.Output)

local NetworkUtils = {}

function NetworkUtils.CreateUUID(): string
	return string.gsub(HttpService:GenerateGUID(false), "-", "") :: string
end

function NetworkUtils.FromHex(toConvert: string): string
	return string.gsub(toConvert, "..", function(cc)
		return string.char(tonumber(cc, 16) :: number)
	end) :: string
end

function NetworkUtils.ToHex(toConvert: string): string
	return string.gsub(toConvert, ".", function(c)
		return string.format("%02X", string.byte(c :: any))
	end) :: string
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
