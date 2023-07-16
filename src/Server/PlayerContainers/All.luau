--!strict
local Types = require(script.Parent.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Parent.Utilities.Output)

local ALL_PLAYERS = { kind = "all", value = nil } :: Types.PlayerContainer

-- Freeze the constant, as it is exposed to the user.
table.freeze(ALL_PLAYERS)

return function(...): Types.PlayerContainer
	Output.warnAssert(select("#", ...) == 0, "incorrect number of arguments passed to player container")

	-- Just send a reference. No point making a new table.
	return ALL_PLAYERS
end
