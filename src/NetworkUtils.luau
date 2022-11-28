local HttpService = game:GetService("HttpService")

local Output = require(script.Parent.Output)

local NUMBERS = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" }
local TYPECHECK = {}

local function specialNumCheck(num: any)
	local objType = typeof(num)

	if objType == "string" or objType == "number" then
		if objType == "string" then
			for i = 1, string.len(objType) do
				if not table.find(NUMBERS, string.sub(string.sub(objType, 1, 1), i, i)) then
					return false
				end
			end

			return true
		else
			return true
		end
	else
		return false
	end
end

local function getTypecheck()
	return if TYPECHECK then specialNumCheck else typeof
end

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

return NetworkUtils
