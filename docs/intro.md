---
sidebar_position: 1
---

# Intro

<<<<<<< HEAD
BridgeNet2 is a networking library for Roblox with a focus on performance. It cuts out the overhead on RemoteEvent calls by 7 bytes. This decreases server bandwidth used, so devs using BridgeNet2 can use more data.
=======
BridgeNet2 is a networking library for Roblox that focuses on performance. It's meant to have a simplistic API that mirrors RemoteEvents, with the changes of `Bridge:Fire` instead of `RemoteEvent:FireClient`, and `Bridge:Connect` instead of `RemoteEvent.OnServerEvent:Connect`. This is because BridgeNet2's optimization process is super complex, and bridges need to have a simplistic API or else I will go insane as the person maintaining this library.
>>>>>>> 1d7d36f8f9215bcbfdc768c10733084b4265beae

## API Design

<<<<<<< HEAD
It's a simplistic API that mirrors RemoteEvents. It does this by using `Bridge:Fire` instead of `RemoteEvent:FireClient`, and `Bridge:Connect` instead of `RemoteEvent.OnServerEvent:Connect`. BridgeNet2 wraps RemoteEvents, making the developers job easier, by encapsulating a complex optimization process.
=======
When using BridgeNet2, you can't fire a bridge with multiple arguments. This means you need to pass a table into Bridge:Fire if you want to send multiple arguments, instead of separate arguments. This design choice was chosen because it removes a layer of complexity, alongside being better for performance, stability, and typechecking. Doing this also means BridgeNet2 never needs to manipulate the data that's pushed, the library can just directly send that data through the RemoteEvent.
>>>>>>> 1d7d36f8f9215bcbfdc768c10733084b4265beae

## Singular parameter for `:Fire()`

<<<<<<< HEAD
Developers cannot fire a bridge with multiple parameters. This means you have to pass a table into Bridge:Fire, instead of separate arguments. This design choice was chosen because it removes a layer of complexity. This is better for performance, stability, and typechecking. Also, doing this means BridgeNet2 never needs to touch the data that's pushed, it can just directly push that data through the RemoteEvent. As a side effect, BridgeNet2 allows developers to group data into an array or dictionary, as found in other Roblox projects.

## How is BridgeNet2 opinionated?

This library favors performance; therefore we made choices that resulted in an opinionated library. This is shown with `PlayerContainer`s, singular `Fire` parameter, identifiers, and opting for thread reusage over stack traces.
=======
This library favors performance, and therefore we made choices that resulted in an opinionated library. This is shown with a few decisions: cutting out varargs, opting for thread reusage which clutters the stack trace, and the `PlayerContainer`s: `BridgeNet2.Players()`, `BridgeNet2.ExceptPlayers()`, etc.
>>>>>>> 1d7d36f8f9215bcbfdc768c10733084b4265beae
