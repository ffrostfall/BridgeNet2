--!strict
local Output = require(script.Parent.Parent.Utilities.Output)

local INVALID_PACKET_MESSAGE =
	"Player %*:%* sent an invalid packet. Likely exploiter- or something interacted with the internal BridgeNet API."

-- Placeholder function for an invalid format/type in internal BridgeNet2 stuff
return function(plr: Player)
	Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
end
