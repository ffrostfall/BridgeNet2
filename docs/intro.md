---
sidebar_position: 1
---

# BridgeNet2
BridgeNet2 is a blazingly fast networking library, fully equipped with middleware, multiple security functions, and a lot of utility functions.

# Why you should use BridgeNet, the short version
- Performance: faster than roblox, less bandwidth used than Roblox.
- Utility features: Middleware, rate limiting, hexadecimal functions, optimization functions, and more.
- Fully strictly typed: this lets you typecheck what you're sending in, and typecheck what you're sending out.
- Botches RemoteSpy logs: Because BridgeNet2 sends a special format, it botches RemoteSpy logs and makes the output less readable for exploiters.
- Security: BridgeNet2 lets you have control over network security, and what the contents of your messages are.
- Debugging: Tons of useful features for debugging your netcode.
- Natively written for Luau: There's no leftover features, or half-baked features meant for typescript.
- **No other networking library offers all of these things.**

# Improvements from prior version (BridgeNet)
BridgeNet2 is the successor of BridgeNet (without the 2), and as such there are a ton of improvements.

- Better cutting off of Roblox overhead- about half the size for the 200-remotes-a-frame stress test. This means BridgeNet is 75% better than Roblox!
- More efficient,
- API call times are faster.
- Better API:
	- Better naming
	- Better functionality
	- Better typings
	- Better runtime typechecking (less errors)
- Completely strictly typed in Luau.
- More utility functions, and better utility functions:
	- ToReadableHex, NumberToBestForm, etc. (with more coming)
- A lot simpler, which means better, faster, less error-prone, and better maintainability.
- Better security within the module:
	- Actual rate-limiting
	- Better runtime typechecking
	- Better format checking