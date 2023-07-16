--!strict
local Types = require(script.Parent.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Parent.Utilities.Output)

return function(players: Types.Array<Player>, ...): Types.PlayerContainer
	Output.warnAssert(select("#", ...) == 0, "incorrect number of arguments passed to player container")

	return { kind = "set", value = players }
end
