local freeThread: thread? -- Thread reusage

local function passer(fn: (...unknown) -> (), ...): ()
	local acquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = acquiredThread
end

local function yielder(): ()
	while true do
		passer(coroutine.yield())
	end
end

return function(fn: (...any) -> (), ...): ()
	if freeThread == nil then
		freeThread = coroutine.create(yielder)
		task.spawn(freeThread :: thread)
	end
	task.spawn(freeThread :: thread, fn, ...)
end
