--[[
	Private
]]
export type Content = unknown
export type SerializedPacket = {
	events: {
		-- The numbers here don't cost anything, because it's an array.
		[number]: {
			-- Each value here is an individual call to an event.
			[number]: Content,
		},
	},

	-- The IDs are packed into this buffer
	buff: buffer,
}

-- { event, content, event, content, event, content }
export type Queue = { number | Content }

return nil
