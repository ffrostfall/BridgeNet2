--!strict
local constantsTable = {
	IDENTIFIER_CAP = 2 ^ 16 :: number,
	IDENTIFIER_CAP_STRING = "2^16",

	SERVER_CONNECT_LOG = "bridge '%*' was fired by [%*] with data: \n===============\n%* (%*B)\n===============\n",
	SERVER_FIRE_LOG = "fired bridge '%*' to players: %* with data: \n===============\n%* (%*B)\n===============\n",

	CLIENT_CONNECT_LOG = "bridge '%*' was fired with data: \n===============\n%* (%*B)\n===============\n",
	CLIENT_FIRE_LOG = "fired bridge '%*' with data: \n===============\n%* (%*B)\n===============\n",
}

return table.freeze(constantsTable) :: typeof(constantsTable)
