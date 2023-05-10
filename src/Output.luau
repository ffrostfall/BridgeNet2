--!strict
local RunService = game:GetService("RunService")

type ESeverityLevel = "log" | "warn" | "error" | "fatal"
type TOutputObject = {
	Severity: ESeverityLevel,
	Text: string,
}
type TSeverityLevelEnum = {
	Log: "log",
	Warn: "warn",
	Error: "error",
	Fatal: "fatal",
}

local PATTERN = if RunService:IsServer() then "[BridgeNet2] %*" else "[BridgeNet2] %*"
local ERROR_PATTERN = if RunService:IsServer() then "[BridgeNet2:S] %*" else "[BridgeNet2:C] %*"

local Output = {}

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

function Output.error(info: string)
	task.spawn(error, string.format(ERROR_PATTERN, info))
end

function Output.errorAssert(condition: boolean, info: string)
	if not condition then
		task.spawn(Output.error, info)
	end
end

function Output.fatal(info: string)
	error(string.format(ERROR_PATTERN, info))
end

function Output.fatalAssert(condition: boolean, info: string)
	if not condition then
		Output.fatal(info)
	end
end

return Output
