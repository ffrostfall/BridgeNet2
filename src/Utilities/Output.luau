--!strict
local RunService = game:GetService("RunService")

local PATTERN = "[BridgeNet2] "

local Output = {}

type allTypes = "string" | "number" | "function" | "table"

function Output.silent(info: string)
	if RunService:IsStudio() then
		print(`{PATTERN}{info}`)
	end
end

function Output.log(info: string)
	print(`{PATTERN}{info}`)
end

function Output.logAssert(condition: boolean, info: string)
	if not condition then
		Output.log(info)
	end
end

function Output.warn(info: string)
	warn(`{PATTERN}{info}`)
end

function Output.warnAssert(condition: boolean, info: string)
	if not condition then
		Output.warn(info)
	end
end

--[[
	PLEASE READ:

	If you were taken here by the stack trace, go a few traces down! BridgeNet2 sadly clutters the stack trace
	because it does thread reusage and because it has these logging utility functions.
]]

function Output.typecheck(expectedType: allTypes, funcName: string, paramName: string, param: unknown)
	local resultType: allTypes = typeof(param) :: allTypes

	if not (resultType == expectedType) then
		error(`{PATTERN}{funcName} parameter {paramName} takes {expectedType}, got {resultType}`, 0)
	end
end

function Output.fatal(info: string)
	error(`{PATTERN}{info}`, 0)
end

function Output.fatalAssert(condition: boolean, info: string)
	if not condition then
		error(`{PATTERN}{info}`, 0)
	end
end

--[[
	PLEASE READ:
	
	If you were taken here by the stack trace, go a few traces down! BridgeNet2 sadly clutters the stack trace
	because it does thread reusage and because it has these logging utility functions.
]]

return Output
