--!strict
local constantsTable = {
	IDENTIFIER_CAP = 2 ^ 16 :: number,
	IDENTIFIER_CAP_STRING = "2^16",
}

return table.freeze(constantsTable) :: typeof(constantsTable)
