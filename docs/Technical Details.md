---
sidebar_position: 5
---

# Technical Details
BridgeNet creates a few instances in the ReplicatedStorage root:
	- MetaRemoteEvent (RemoteEvent)
		This is how BridgeNet2 handles meta messages (e.g. connecting players)
	- DataRemoteEvent (RemoteEvent)
		This is the actual remote that sends data through
	- IdentifierStorage (Folder)
		This is the folder that identifiers are passed through- it uses attributes to store them
Don't touch any of these instances unless you know what you're doing. They can easily break BridgeNet2 if they're even slightly altered.

It's worth noting that `Reference` functions (`ReferenceBridge` and `ReferenceIdentifier`) have very different behavior depending on if the caller is the client or the server. For example: `ReferenceIdentifier` can yield on the client, but will never yield on the server.

## Process
- Thread reuse is utilized- this is why there's a few extra functions in the stack trace. Task.spawn is used over coroutine.resume because of
continuations and intact stack traces, however there's a dramatic increase in speed. If you really need it, you can switch the task.spawn
to utilize coroutine.resume for extra performance, although note this will hide errors.
- Both processes handle both incoming and receiving objects as a singular reference- this means you can substitute the table for, say, a Vector3.

## ServerProcess
- The format for server-to-client communication is as so: { [identifierName] = { {uniqueMessage}, {otherUniqueMessage} } }. While this
does technically mean you can send strings through, you really shouldn't, although support for that may be added in the future.
- Yes, that does mean that firing separate bridges has more overhead than firing the same bridge. Identifiers can be used to get around this, if you organize your netcode effectively. (the format in question: [identifierName] = {identifier, uniqueMessage}, which is the format the predecessor to this library [BridgeNet] used. )

## ClientProcess
- The format for client-to-server communication is as so: { [even] = "identifier", [odd] = {uniqueMessage} }. While it's two table.insert
calls, it's better because you don't need to pack or unpack anything- and you're not touching user data.

## Identifiers
- Identifiers rely on attributes, and `string.pack("B", identifierSerial)`. This means that if you would prefer 65536 possible IDs/bridges, you
can switch out "B" with "H". This will, however, degrade bandwidth- hence the "B", which means an unsigned bytes. It's 1 character in length.
- On the client, identifiers are automatically received and put into a table. This means technically, you can reference them with .FromIdentifier(). This is unsafe though- it's like using `.` to index instances in Roblox. If you're 100% sure it's loaded- do it. If not, then just use .ReferenceIdentifier(), as it yields.
- The server keeps track of how many identifiers there are, and uses this to generate a unique number to pass in to `string.pack`. It wasn't
a good idea to make this dynamic in the original BridgeNet.

You can find a lot of general knowledge on how Roblox does networking here: https://devforum.roblox.com/t/in-depth-information-about-robloxs-remoteevents-instance-replication-and-physics-replication-w-sources/1847340