---
sidebar_position: 1
---

# Getting started with BridgeNet2

## Your first Bridge
Bridges are extremely simple; they're just RemoteEvents, but BridgeNet2-ified! The API is, as said in previous sections, extremely simple and similar to RemoteEvents. The first difference between RemoteEvents and bridges is that bridges are created from strings, and RemoteEvents are instances. You can use the `ReferenceBridge` function under BridgeNet2 to create a bridge like so:
```lua
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")
```

:::info

The variable name and the bridge's name don't need to match (as shown later), but it is a recommended practice when using BridgeNet2.

:::

It's very important to note that the strings must be the **exact same** on both the client and the server. But don't worry; BridgeNet2 will warn and tell you something's wrong if it can't find a bridge on the client!

### But wait, what about client vs. server?
BridgeNet2's surface level API is almost the exact same, regardless of server and client! `ReferenceBridge` is used the exact same way on the server and the client. This is because there's no real reason to make them different, apart from typechecking. If you are interested in more "correct" typechecking/autocomplete, you can use the `ServerBridge` and `ClientBridge` functions like so:
```lua
-- On the client..
local myFirstBridgeClientVersion = BridgeNet2.ClientBridge("myFirstBridge")

-- On the server..
local myFirstBridgeServerVersion = BridgeNet2.ServerBridge("myFirstBridge")
```
:::caution

`ClientBridge` yields, and so does using `ReferenceBridge` on the client! You can set a timeout using the second optional timeout parameter.

:::

### Firing a bridge
The biggest API changes are in the `Fire` method. You can only pass a single argument in, but this argument can be *anything*. A table, a string, a boolean, nothing, whatever you want (this will become important later)! One very important differentation from the client's `Fire` function is that the server's version of the `Fire` method's first parameter is for the player(s)!
```lua
local Players = game:GetService("Players")

local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

-- On the server..
local you = Players.theReader

myFirstBridge:Fire(you, "Hello!")
```

### Firing to every single player
BridgeNet2 has built-in support for firing to multiple players, but there isn't a `FireAllClients` method! Instead, we have the `AllPlayers` function. This returns a "symbol" that says "fire this stuff to every single player". It's used in the same parameter as a singular player, like so:
```lua
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

myFirstBridge:Fire(BridgeNet2.AllPlayers(), "Hello everyone!")
```

### Firing to an array of players
Alongside the `AllPlayers` function there is also the `Players` function. This function lets you easily fire data to a specific set of players like so:
```lua
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

myFirstBridge:Fire(BridgeNet2.Players({ Players.SpecialPlayerA, Players.SpecialPlayerB }), "Hello special players! Only you get to see this.")
```

### Firing to every player except certain players
This function is the inverted version of the `Players` function. You can fire to everyone except certain players- this is useful for things like client-sided prediction. It can be used just like the `Players` function:
```lua
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

myFirstBridge:Fire(BridgeNet2.PlayersExcept({ Players.BadPlayerA }), "Everyone except BadPlayerA gets this!")
```

### Firing from the client
Firing from the client is the exact same as firing on the server, except without the `targetPlayer` parameter:
```lua
local firstClientBridge = BridgeNet2.ClientBridge("myFirstBridge")

firstClientBridge:Fire("Hey, server!")
```

### Connecting to a bridge
Connecting to a bridge and connecting to a RemoteEvent are very similar; one's just way shorter! It's basically the exact same:
```lua
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

-- On the client..
myFirstBridge:Connect(function(message)
	print(message) -- prints "Hello everyone!"
end)

-- On the server..
myFirstBridge:Connect(function(player, message)
	print(`{player.Name} said {message}`) -- prints "Client said Hey, server!"
end)
```

### What if I wanted to send multiple things?
Since BridgeNet2 only allows you to send a singualr argument through `Fire`, you can just pass a table!
```lua
-- On the server..
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

myFirstBridge:Fire(BridgeNet2.AllPlayers(), {
	"This is a fully intact array!",
	"Tables can store any data you need.",
	"You don't need multiple arguments if you can use tables."
})
```
```lua
-- On the client..
local myFirstBridge = BridgeNet2.ReferenceBridge("myFirstBridge")

myFirstBridge:Connect(function(array)
	print(array) -- Prints the array we sent from the server
end)
```