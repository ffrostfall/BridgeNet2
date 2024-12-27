local idToName: { [number]: string } = {}
local nameToId: { [string]: number } = {}

export type Identifier = number

local identifierMap = {}

function identifierMap.addIdentifier(name: string, id: Identifier)
	idToName[id] = name
	nameToId[name] = id
end

function identifierMap.removeIdentifier(name: string)
	local id = nameToId[name]

	idToName[id] = nil
	nameToId[name] = nil
end

function identifierMap.fromName(name: string): Identifier?
	return nameToId[name]
end

function identifierMap.fromId(id: Identifier): string?
	return idToName[id]
end

return identifierMap
