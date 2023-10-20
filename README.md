<div align="center">
<img src=".moonwave/static/logo.png" width="256" />
</div>

# BridgeNet2 v1.0.0

## Blazing fast & opinionated networking library designed to reduce bandwidth.

BridgeNet2 is a networking library for Roblox with a focus on performance. It cuts out header data from RemoteEvent calls by 7 bytes, which is beneficial because it cuts down on the total number of packets per player. This in turn decreases server bandwidth used, so you can send more data. Games using BridgeNet2 will never hit the RemoteEvent throttle limit. BridgeNet2 also decreases the amount of time to process packets on the client by approximately 75-80%.

BridgeNet2 has a simplistic API that mirrors RemoteEvents. It does this by using `Bridge:Fire()` instead of `RemoteEvent:FireClient()`, and `Bridge:Connect()` instead of `RemoteEvent.OnServerEvent:Connect()`. BridgeNet2 wraps remoteevents, making the developers job easier, by encapsulating a complex optimization process.

Developers cannot fire a bridge with multiple parameters. This means you have to pass a table into `Bridge:Fire()`, instead of separate arguments. This design choice was chosen because it removes a layer of complexity. This choice is better for performance, stability, and typechecking. Also, doing this means BridgeNet2 never needs to touch the data that's pushed, it can just directly push that data through the RemoteEvent. As a side effect, BridgeNet2 allows developers to group data into an array or dictionary, as found in other Roblox projects.

This library favors performance, and therefore we made choices that resulted in an opinionated library. BridgeNet2 never manipulates your data under the hood, but it does encourage developing in favor of performance.

[Further Documentation](https://ffrostflame.github.io/BridgeNet2/)
