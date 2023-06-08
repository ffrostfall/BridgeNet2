--!strict
local Types = require(script.Parent.Parent.Parent.Types)

return function(player: Player): Types.PlayerContainer
	return { kind = "single", value = player }
end
