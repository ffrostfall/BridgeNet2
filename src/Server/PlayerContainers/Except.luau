--!strict
local Types = require(script.Parent.Parent.Parent.Types)

return function(excludedPlayers: Types.Array<Player>): Types.PlayerContainer
	return { kind = "except", value = excludedPlayers }
end
