---
sidebar_position: 1
---

# Introduction

BridgeNet2 is a networking library for Roblox that focuses on performance. It is meant to have a simplistic API that mirrors RemoteEvents, with the change of `Bridge:Fire` instead of `RemoteEvent:FireClient`, and `Bridge:Connect` instead of `RemoteEvent.OnServerEvent:Connect`. This is because BridgeNet2's optimization process is relatively complex, and bridges need to have a simplistic API for the internal process.

## No varargs

You cannot fire a bridge with multiple things. This means you cannot do `Bridge:Fire(1, 2, 3)`. Instead, you need to do `Bridge:Fire({1, 2, 3})`. This design choice is because it removes a layer- doing this means BridgeNet2 never needs to touch what you send through, it can just directly pass that data through the RemoteEvent. This is better for performance, stability, and it means typechecking is easier. It's a common pattern in Roblox to group up data into an array, or a dictionary anyways; this design choice just turns that into the standard.

## Why is BridgeNet2 opinionated?

This library is opinionated for performance- it encourages, and orients itself around the most performant way of doing things. This is shown with the removal of varargs, and just the general design of the library. BridgeNet2 never touches your data, but it encourages doing things in the best way possible.
