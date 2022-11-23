local PATTERN = "[BridgeNet2] %*"

local Output = {}

function Output.log(info: string)
	print(string.format(PATTERN, info))
end

function Output.logAssert(condition: boolean, info: string)
	if not condition then
		Output.Log(info)
	end
end

function Output.warn(info: string)
	warn(string.format(PATTERN, info))
end

function Output.warnAssert(condition: boolean, info: string)
	if not condition then
		Output.Warn(info)
	end
end

function Output.error(info: string)
	task.spawn(error, string.format(PATTERN, info))
end

function Output.errorAssert(condition: boolean, info: string)
	if not condition then
		task.spawn(Output.Error, info)
	end
end

function Output.fatal(info: string)
	error(string.format(PATTERN, info))
end

function Output.fatalAssert(condition: boolean, info: string)
	if not condition then
		Output.Fatal(info)
	end
end

return Output
