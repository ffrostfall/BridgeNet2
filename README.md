# BridgeNet2 v0.1.0-alpha

Blazing fast networking library for Roblox.

---

## Features: Performance
- [x] **A lot faster** than Roblox's default systems. [Done]
- **Reduces Roblox's overhead per remote call: client to server takes 5 bytes, server to client takes 2 bytes.** [Done]
- Identifier system to help reduce bandwidth used on static strings; any size string will take 3 or 4 bytes. [Done]
- Utilities for optimization: FromHex, ToHex, DictionaryToTable, and more. [Done]
- Thread reusage on connections for extreme efficiency. [Done]

## Features: Security
- Customizable rate limiting across all bridges- never worry about remote spamming again. [Partially]
- Supports middleware for easy typechecking and security implementation. [Done]
- Internally secure. It is impossible to cause an error in the library as an exploiter. [Done]

## Features: Abstraction
- Queues up remote calls to a player until they are loaded- never worry about the invocation queue again. [Done]
- Instances are abstracted away- never worry about RemoteEvents again. [Done]
- Abstract any optimization needed away from you- convert dictionaries to arrays and back easily. [Partially]
- Don't worry about client/server boundaries when defining remotes. ReferenceBridge and CreateTree have you!  [Partially]

## Features: API
- Fully typed in strict Luau. [Done]
- Extremely performant. Never worry about API performance, ever. [Done]
- Very easy to pick up. [Done]
- No more tuples- which means a much easier time using strict typing. [Done]
- API is built to be extendable; you can implement your own systems and whitelists. [Done]
- A new testing mode has been added; when you call BridgeNet.Testing(boolean), it will activate a mock-mode that never yields. [Partially]

---

## Documentation

## Improvements from BridgeNet 1

- Better compression
- More efficient, better frame times.
- API call times are faster.
- Better API
-

---

## Stress Tests

---

## Design Decisions/Explanations

There's a lot of design decisions I made with a lot of complexity behind them.

### Removing Tuples

### ReferenceIdentifier

In any library interface, you should always strive to have accurate, descriptive function names. CreateIdentifier in the original BridgeNet was almost misleading.

###
