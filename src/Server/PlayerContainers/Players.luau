--!strict
local Types = require(script.Parent.Parent.Parent.Types)

return function(players: Types.Array<Player>): Types.PlayerContainer
	return { kind = "set", value = players }
end
