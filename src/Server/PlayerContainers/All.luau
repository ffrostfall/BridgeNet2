--!strict
local Types = require(script.Parent.Parent.Parent.Types)

local ALL_PLAYERS = { kind = "all", value = nil } :: Types.PlayerContainer

-- Freeze the constant, as it is exposed to the user.
table.freeze(ALL_PLAYERS)

return function(): Types.PlayerContainer
	-- Just send a reference. No point making a new table.
	return ALL_PLAYERS
end
