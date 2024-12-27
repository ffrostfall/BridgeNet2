local types = require("@src/types")

local function encode(queue: types.Queue): types.SerializedPacket
	local outgoingEvents: types.SerializedPacket = {
		events = {},
		buff = buffer.create(0),
	}

	local idToIndex: { [number]: number } = {}
	local indexToId: { [number]: number } = {}

	for i = 1, #queue, 2 do
		local id = queue[i] :: number
		local content = queue[i + 1] :: Content
		local index = idToIndex[id]

		if index then
			table.insert(outgoingEvents.events[index], content)
		else
			table.insert(indexToId, id)
			index = #indexToId
			idToIndex[id] = index

			outgoingEvents.events[index :: any] = { content }
		end
	end

	local buff = buffer.create(#indexToId)
	for index, id in indexToId do
		buffer.writeu8(buff, index - 1, id)
	end

	outgoingEvents.buff = buff

	return outgoingEvents
end

return encode
