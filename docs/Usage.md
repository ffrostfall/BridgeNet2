---
sidebar_position: 4
---

# Usage

After [installation](./Installation), you can proceed with using it.
This tutorial will assume the BridgeNet2 module is located in `game.ReplicatedStorage.Packages`

## Basic Usage
`BridgeNet2.ReferenceBridge()` is used in place of `RemoteEvents`. They are extremely similar, expect for a few minor changes.

In both a script on the server, and the client:
```lua
local BridgeNet2 = require(game.ReplicatedStorage.Packages.BridgeNet2)

-- Calling ReferenceBridge() will return either a ServerBridge or ClientBridge instance depending on the enviroment.
local bridge = BridgeNet2.ReferenceBridge("Example")
```

You can connect to an event using `:Connect()` as any normal Roblox event.
```lua
-- Instead of defining multiple arguments, they are all grouped into a single table.
-- Omit the player argument for usage on the client.
bridge:Connect(function(player, args)
    print("Received event from "..player.Name)
	for _, argument in args do
        print(argument)
    end
end)
```

`:Fire()` can be used to send data on both the client and the server, it requires a `TPlayerType` value as the first argument when used server.
```lua
-- On the server
bridge:Fire(BridgeNet2.AllPlayers(), {"abc", 1, true})
-- or the client
bridge:Fire({"Hello", "Server"})
```

### Ratelimiting
On the server, you can call `:RateLimit()` to set how many requests can be processed per second.
```lua
bridge:RateLimit(10, function(player)
	-- Setting a rate limit also allows you to have a callback function.
    -- If this function returns true, then the rate limit will be ignored.
	if player.Name == "Roblox" then
        return true
	end
    print(player.Name .. " triggered the ratelimiter")
end)
```

### Cleaning up
If you need to destroy a `ClientBridge` or `ServerBridge`, both objects have a `:Destroy()` method.