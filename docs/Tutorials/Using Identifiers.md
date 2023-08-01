---
sidebar_position: 3
---

# Identifiers
Identifiers are one of the cooler parts about BridgeNet2- they basically take a string you can understand and read, then assign it a three-byte identifier that both the client and server can understand! This is important because it lets you organize your data in a readable *and* efficient way. For example, take the following code:
```lua
local sendSomeData = BridgeNet2.ReferenceBridge("sendSomeData")

sendSomeData:Fire({
	firstThingToSend = 5,
	anotherThing = false,
})
```

:::tip

If you'd like to know more about bandwidth usage w/ networking on Roblox, [you can check out this link here](https://devforum.roblox.com/t/in-depth-information-about-robloxs-remoteevents-instance-replication-and-physics-replication-w-sources/1847340).

:::

## What's the problem?
We can understand `firstThingToSend` and `anotherThingToSend` as humans, but they take more bandwidth than our actual data, *three times over!* Bandwidth is valuable, and we don't really want to shorten the names we see just because it takes a lot of bandwidth to send. That just makes our code harder to read.

## What's the solution?
This is where identifiers come in:
```lua
local sendSomeData = BridgeNet2.ReferenceBridge("sendSomeData")

local firstThingToSend = BridgeNet2.ReferenceIdentifier("firstThingToSend")
local anotherThing = BridgeNet2.ReferenceIdentifier("anotherThing")

sendSomeData:Fire({
	[firstThingToSend] = 5,
	[anotherThing] = false,
})
```
At the cost of 2 lines of code, we completely solved the problem! Our code is now both readable and efficient.
