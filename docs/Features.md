
### BridgeNet2 offers a variety of features to improve performance, security, abstraction, and the API of your roblox game.

## Performance:

- [x] Significantly faster than the default systems in Roblox.
- [x] Reduces the overhead of remote calls: client to server takes 5 bytes, server to client takes 2 bytes.
- [x] Uses an identifier system to reduce bandwidth usage for static strings, which take 3 or 4 bytes regardless of size.
- [x] Includes utilities for optimization such as `FromHex`, `ToHex`, and `DictionaryToTable`.
- [x] Reuses threads on connections for increased efficiency.

## Security:

- [x] Customizable rate limiting for all bridges to prevent remote spamming.
- [x] Provides middleware for easy typechecking and security implementation.
- [x] Internally secure to protect against exploitation.

## Abstraction:

- [x] Queues up remote calls to a player until they are loaded, eliminating the need to worry about the invocation queue.
- [x] Abstracts instances, eliminating the need to use RemoteEvents.
- [x] Abstracts away optimization tasks, allowing for easy conversion between dictionaries and arrays.
- [x] Removes the need to consider client/server boundaries when defining remotes using ReferenceBridge and CreateTree.

## API:

- [x] Fully typed in strict Luau.
- [x] Highly performant.
- [x] Easy to learn and use.
- [x] Replaces tuples with a more user-friendly system for strict typing.
- [x] Designed to be extendable, allowing for the implementation of custom systems and whitelists.
- [x] Includes a testing mode that activates a mock mode that never yields when BridgeNet.Testing(boolean) is called.
