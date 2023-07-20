---
sidebar_position: 1
---

# Intro

BridgeNet2 is a networking library for Roblox that focuses on performance. It's meant to have a simplistic API that mirrors RemoteEvents, with the changes of `Bridge:Fire` instead of `RemoteEvent:FireClient`, and `Bridge:Connect` instead of `RemoteEvent.OnServerEvent:Connect`. This is because BridgeNet2's optimization process is super complex, and bridges need to have a simplistic API or else I will go insane as the person maintaining this library.

## API Design

When using BridgeNet2, you can't fire a bridge with multiple arguments. This means you need to pass a table into Bridge:Fire if you want to send multiple arguments, instead of separate arguments. This design choice was chosen because it removes a layer of complexity, alongside being better for performance, stability, and typechecking. Doing this also means BridgeNet2 never needs to manipulate the data that's pushed, the library can just directly send that data through the RemoteEvent.

## Singular parameter for `:Fire()`

This library favors performance, and therefore we made choices that resulted in an opinionated library. This is shown with a few decisions: cutting out varargs, opting for thread reusage which clutters the stack trace, and the `PlayerContainer`s: `BridgeNet2.Players()`, `BridgeNet2.ExceptPlayers()`, etc.
