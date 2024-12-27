--!native
local signal = require("@pkg/signal")

local idToSignal: { [number]: signal.Identity<...any> } = {}

local deserializer = {}

function deserializer.exists(id: number)
	return idToSignal[id] ~= nil
end

function deserializer.registerId(id: number): signal.Identity<...any>
	idToSignal[id] = signal()
	return idToSignal[id]
end

function deserializer.fetchEventSignal(id: number): signal.Identity<...any>
	return idToSignal[id]
end

function deserializer.decode(events: { [number]: { unknown } }, buff: buffer, player: Player?)
	if _G.__timetracing__ == "true" then
		debug.profilebegin("event begin")
	end

	if _G.__verbose__ == "true" then
		print("remote call", player, events, buff)
	end

	-- it's duplicate but its best performing so
	if player then
		-- copypaste this one though
		for index, calls in events do
			local id = buffer.readu8(buff, index - 1)
			local eventSignal = idToSignal[id]
			if not eventSignal then
				warn("todo: handle this case")
				continue
			end

			for _, value in calls do
				-- Event logic
				eventSignal:fire(player, value)
			end
		end
	else
		for index, calls in events do
			local id = buffer.readu8(buff, index - 1)
			local eventSignal = idToSignal[id]
			if not eventSignal then
				warn("todo: handle this case")
				continue
			end

			for _, value in calls do
				-- Event logic
				eventSignal:fire(value)
			end
		end
	end

	if _G.__timetracing__ then
		debug.profilebegin("server event end")
	end
end

return deserializer
