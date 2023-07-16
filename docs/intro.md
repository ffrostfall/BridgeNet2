---
sidebar_position: 1
---

# Intro

BridgeNet2 is a networking library for Roblox with a focus on performance. It cuts out the overhead on RemoteEvent calls by 7 bytes. This decreases server bandwidth used, so devs using BridgeNet2 can use more data.

## API Design

It's a simplistic API that mirrors RemoteEvents. It does this by using `Bridge:Fire` instead of `RemoteEvent:FireClient`, and `Bridge:Connect` instead of `RemoteEvent.OnServerEvent:Connect`. BridgeNet2 wraps RemoteEvents, making the developers job easier, by encapsulating a complex optimization process.

## Singular parameter for `:Fire()`

Developers cannot fire a bridge with multiple parameters. This means you have to pass a table into Bridge:Fire, instead of separate arguments. This design choice was chosen because it removes a layer of complexity. This is better for performance, stability, and typechecking. Also, doing this means BridgeNet2 never needs to touch the data that's pushed, it can just directly push that data through the RemoteEvent. As a side effect, BridgeNet2 allows developers to group data into an array or dictionary, as found in other Roblox projects.

## How is BridgeNet2 opinionated?

This library favors performance; therefore we made choices that resulted in an opinionated library. This is shown with `PlayerContainer`s, singular `Fire` parameter, identifiers, and opting for thread reusage over stack traces.
