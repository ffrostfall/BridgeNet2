-- For unit testing. This doesn't get ran by Roblox.
local dataset_type = require("../dataset_type")
local serdes = require("@bridgenet2/serdes")

local data: dataset_type.T = function()
	local isHi, isHuh = false, false

	return {
		check = function()
			return isHi and isHuh
		end,

		make_events = function()
			local function first_event_callback(content: unknown, player: Player?)
				isHi = content == "hi"
			end

			local function second_event_callback(content: unknown, player: Player?)
				isHuh = content == "huh"
			end

			return {
				[1] = { first_event_callback },
				[2] = { second_event_callback },
			}
		end,

		make_raw = function(): { { unknown } }
			return { { "hi" }, { "huh" } }
		end,
	}
end

return data
