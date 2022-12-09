---
sidebar_position: 2
---

# Features
BridgeNet2 is packed with a ton of features to make your life easier, and make your game have higher code quality.

## Features: Performance
- [x] **A lot faster** than Roblox's default systems. 
- [x] **Reduces Roblox's overhead per remote call: client to server takes 5 bytes, server to client takes 2 bytes.** 
- [x] Identifier system to help reduce bandwidth used on static strings; any size string will take 3 or 4 bytes. 
- [x] Utilities for optimization: FromHex, ToHex, DictionaryToTable, and more. 
- [x] Thread reusage on connections for extreme efficiency. 

## Features: Security
- [] Customizable rate limiting across all bridges- never worry about remote spamming again. 
- [x] Supports middleware for easy typechecking and security implementation. 
- [x] Internally secure. It is impossible to cause an error in the library as an exploiter. 

## Features: Abstraction
- [x] Queues up remote calls to a player until they are loaded- never worry about the invocation queue again. 
- [x] Instances are abstracted away- never worry about RemoteEvents again. 
- [] Abstract any optimization needed away from you- convert dictionaries to arrays and back easily. 
- [] Don't worry about client/server boundaries when defining remotes. ReferenceBridge and CreateTree have you!  

## Features: API
- [x] Fully typed in strict Luau. 
- [x] Extremely performant. Never worry about API performance, ever.
- [x] Very easy to pick up. 
- [x] No more tuples- which means a much easier time using strict typing.
- [x] API is built to be extendable; you can implement your own systems and whitelists.
- [x] A new testing mode has been added; when you call BridgeNet.Testing(boolean), it will activate a mock-mode that never yields.
