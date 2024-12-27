local idToName: { [number]: string } = {}
local nameToId: { [string]: number } = {}

export type Identifier = number

local map = {}

function map.addIdentifier(name: string, id: Identifier)
	idToName[id] = name
	nameToId[name] = id
end

function map.removeIdentifier(name: string)
	local id = nameToId[name]

	idToName[id] = nil
	nameToId[name] = nil
end

function map.fromName(name: string): Identifier?
	return nameToId[name]
end

function map.fromId(id: Identifier): string?
	return idToName[id]
end

return map
