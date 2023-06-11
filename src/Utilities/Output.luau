--!strict
local RunService = game:GetService("RunService")

local PATTERN = if RunService:IsServer() then "[BridgeNet2] %*" else "[BridgeNet2] %*"

local Output = {}

type allTypes = "string" | "number" | "function" | "table"

function Output.silent(info: string)
	if RunService:IsStudio() then
		print(string.format(PATTERN, info))
	end
end

function Output.log(info: string)
	print(string.format(PATTERN, info))
end

function Output.logAssert(condition: boolean, info: string)
	if not condition then
		Output.log(info)
	end
end

function Output.warn(info: string)
	warn(string.format(PATTERN, info))
end

function Output.warnAssert(condition: boolean, info: string)
	if not condition then
		Output.warn(info)
	end
end

function Output.typecheck(expectedType: allTypes, funcName: string, paramName: string, param: unknown)
	local resultType: allTypes = typeof(param) :: allTypes
	Output.fatalAssert(
		resultType == expectedType,
		`{funcName} parameter {paramName} takes {expectedType}, got {resultType}`
	)
end

function Output.fatal(info: string)
	error(`\n[BridgeNet2:{if RunService:IsServer() then "S" else "C"}]: {info}`)
end

function Output.fatalAssert(condition: boolean, info: string)
	if not condition then
		Output.fatal(info)
	end
end

return Output
