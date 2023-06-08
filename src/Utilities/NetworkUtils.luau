--!strict
local HttpService = game:GetService("HttpService")

local Output = require(script.Parent.Output)

local NetworkUtils = {}

function NetworkUtils.CreateUUID(): string
	-- Create a GUID, then remove the dashes. This can be converted to a binary form using .ToHex()
	return string.gsub(HttpService:GenerateGUID(false), "-", "") :: string
end

function NetworkUtils.FromHex(toConvert: string): string
	-- String black magic I don't remember
	return string.gsub(toConvert, "..", function(cc)
		return string.char(tonumber(cc, 16) :: number)
	end) :: string
end

function NetworkUtils.ToHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", `ToHex takes string, got {toConvert}`)
	-- String black magic I don't remember as of commenting
	return string.gsub(toConvert, ".", function(c)
		return string.format("%02X", string.byte(c :: any))
	end) :: string
end

function NetworkUtils.ToReadableHex(toConvert: string): string
	Output.fatalAssert(typeof(toConvert) == "string", `ToReadableHex takes string, got {toConvert}`)
	-- Also string magic I don't remember
	return string.format(string.rep("%02X ", #toConvert), string.byte(toConvert, 1, -1))
end

return NetworkUtils
