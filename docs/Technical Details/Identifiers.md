---
sidebar_position: 1
---

# Identifiers

Identifiers are actually extremely simple: it's a shared key-value list. The key is the compressed identifier, the value is the string value. The list is stored as attributes under the BridgeNet2 RemoteEvent. Identifiers are actually just numbers compressed using `string.pack`- every time you create an identifier, it increments that number by one and creates the attribute.

```lua title="/src/Server/ServerIdentifiers.luau" showLineNumbers
-- optimization for under 255 identifiers
local packed = if identifierCount <= 255
	then string.pack("B", identifierCount)
	else string.pack("H", identifierCount)

identifierCount += 1
identifierStorage:SetAttribute(identifierName, packed)

fullIdentifierMap[identifierName] = packed
compressedIdentifierMap[packed] = identifierName
```

On the client, the client listens for new attributes added and attribute changes. It then stores these identifiers locally- the `Serialize` and `Deserialize` functions just directly interface with that table. This is why the `ReferenceIdentifier` function yields- it basically just waits a bit to see if the attribute loads in. If it already exists, it just accesses that in the local table.

```lua title="/src/Client/ClientIdentifiers.luau" {2-3} showLineNumbers
for id, value in identifierStorage:GetAttributes() do
	fullIdentifierMap[id] = value
	compressedIdentifierMap[value] = id
end
```
