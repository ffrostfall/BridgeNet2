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

function NetworkUtils.ToReadableHex(toConvert: string): string
	Output.fatalAssert(
		typeof(toConvert) == "string",
		string.format("ToReadableHex takes string, got %*", typeof(toConvert))
	)
	return string.gsub(toConvert, ".", function(c)
		return string.format("%02X ", string.byte(c :: any))
	end) :: string
end

function NetworkUtils.NumberToBestForm(num: number): number | string
	if string.len(tostring(num)) <= 7 then
		return tostring(num)
	else
		return num
	end
end

return NetworkUtils
