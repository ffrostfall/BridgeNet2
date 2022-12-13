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
local SEVERITY_LEVELS: TSeverityLevelEnum = {
	Log = "log",
	Warn = "warn",
	Error = "error",
	Fatal = "fatal",
}
local logs: { TOutputObject } = {}

local function logSeverity(severity: ESeverityLevel, info: string)
	local OutputObject: TOutputObject = {
		Severity = severity,
		Text = string.format(PATTERN, info),
	}
	table.insert(logs, OutputObject)
end

local Output = {}

function Output.Hook()
	return logs
end

function Output.silent(info: string)
	logSeverity(SEVERITY_LEVELS.Log, info)
end

function Output.log(info: string)
	logSeverity(SEVERITY_LEVELS.Log, info)
	print(string.format(PATTERN, info))
end

function Output.logAssert(condition: boolean, info: string)
	if not condition then
		Output.log(info)
	end
end

function Output.warn(info: string)
	logSeverity(SEVERITY_LEVELS.Warn, info)
	warn(string.format(PATTERN, info))
end

function Output.warnAssert(condition: boolean, info: string)
	if not condition then
		Output.warn(info)
	end
end

function Output.error(info: string)
	logSeverity(SEVERITY_LEVELS.Error, info)
	task.spawn(error, string.format(ERROR_PATTERN, info))
end

function Output.errorAssert(condition: boolean, info: string)
	if not condition then
		task.spawn(Output.error, info)
	end
end

function Output.fatal(info: string)
	logSeverity(SEVERITY_LEVELS.Fatal, info)
	error(string.format(ERROR_PATTERN, info))
end

function Output.fatalAssert(condition: boolean, info: string)
	if not condition then
		Output.fatal(info)
	end
end

return Output
