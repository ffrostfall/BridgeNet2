# BridgeNet2

This project uses [semantic versioning](https://semver.org/spec/v2.0.0.html).

## [version 1.0.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v1.0.0): 10/20/2023

### Added

- Added an easy way to type payloads using generics. This will be elaborated on in documentation later

### Fixes

- Fixed sending singular nil values with nothing else in the frame
- Fixed a bug w/ the loading queue. Finally got around to that (https://github.com/ffrostflame/BridgeNet2/issues/35)
- Type improvements

### Improvements

- Added unique IDs to the invoke functionality. Should fix a multitude of bugs.
- Re-did rate limiting. I'm confident that it's stable.

## [version 0.5.6](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.6): 9/25/2023

### Added

- Now uses a system to manage package version control w/ instances. This ensures that even if you're running 2 separate versions of BridgeNet2, it will communicate correctly, and everything will work as expected.

## [version 0.5.5](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.5): 8/26/2023

### Fixes

- All coroutine.resume instances have been replaced with task.spawn. This fixes a lot of obscure bugs.

## [version 0.5.4](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.4): 8/19/2023

### Added

- You can now name connections, which will show up in logging and in the microprofiler.
- Calling script and line are now shown for connections and firing bridges

### Improvements

- Type improvements

## [version 0.5.3](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.3): 7/31/2023

### Added

- A mock API for when BridgeNet2 is ran in edit mode. Limitations: InvokeServerAsync will infinitely yield, connections will never run.

### Improvements

- BridgeNet2 nows prints the current version upon being loaded
- Improved output readability
- **Potentially breaking:** Bridges now are cached- this means you will have the same bridge object across scripts. This should be more expected behavior, and should overall be an improvement.

### Fixes

- Potentially fixed some issues with loading and identifiers?
- Fixed a bug where referencing a bridge multiple times clearing connections each time (Except on the client this time)

## [version 0.5.2](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.2): 7/15/2023

### Improvements

- PlayerContainers now error if an incorrect amount of arguments is passed

### **Fixes**

- Fixed a bug where referencing a bridge multiple times clearing connections each time
- Fixed a bug where the player loading before BridgeNet2 starts would never initialize the player

## [version 0.5.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.5.0): 6/21/2023

### **Added**

- Added `ServerBridge.OnServerInvoke` and `ClientBridge:InvokeServer()`
- Added `.Connected` to connections

### **Fixes**

- Fixed a bug with `Bridge:Wait`

### **Improvements**

- Refactored the object-oriented programming pattern used w/ Bridges
- Connections are now their own class
- Calling methods with `.` instead of `:` will now error
- Type improvements
- `tostring()`-ing a bridge will now return its class type

## [version 0.4.1](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.4.1): 6/11/2023

### **Fixes**

- Fixed some behavior w/ nil values

## [version 0.4.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.4.0): 6/10/2023

### **Added**

- Added `BridgeNet2.ServerBridge` and `BridgeNet2.ClientBridge` constructors- they are identical to ReferenceBridge, just with better types. The current ReferenceBridge will not be deprecated or affected by this.
- Instead of being limited to tables, you can now pass any type into :Fire(). This means you can finally pass in nil values to :Fire() too.

### **Fixes**

- Fixed rate limiting
- Re-added methods on the `Bridge` type to types

### **Improvements**

- Added `Connection` type to `Bridge:Connect()` functions
- `RateLimitActive` is now a public boolean that can be set by the user
- Improved error messages
- Improved logger readability.
- I made a script to automate releases- there should hopefully be less inconsistencies with releases from now on.

## [version 0.3.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.3.0): 6/8/2023

### **Added**

- Added Hoarcekat support

### **Removed**

- NumberToBestForm removed (feature bloat)
- StartLogging and StopLogging have been removed in favor of `object.Logging =`

### **Fixes**

- Literally dozens of bugfixes

### **Improvements**

- Massive internal re-structuring
- Renamed `FromIdentifier` and `FromCompressed` to `Serialize` and `Deserialize`
- Internally commented the entire project
- Removed SetSecurity and SecurityEnums in favor of `HandleInvalidPlayer`
- Type improvements
- Logging now displays the packet size in bytes (using @PysephWasntAvailable's [RemotePacketSizeCounter](https://github.com/PysephWasntAvailable/RemotePacketSizeCounter) package)
- Compliant with strict Luau typing

## version 0.2.2

### **Fixes**

- Hotfix

## [version 0.2.1](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.2.1): 6/3/2023

### **Added**

- Added :Once() and :Wait() to ClientBridge

### **Fixes**

- Fixed a bug w/ :Wait() on ClientBridge

### **Improvements**

- Default format/type security errors no longer throw

## [version 0.2.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.2.0): 5/11/2023

### **Added**

- Added :Once()
- Added :Wait()
- Added :StartLogging() and :StopLogging()
- Added :Disconnect() to connections

### **Removed**

- Removed .Hook()

### **Improvements**

- Added single-player targeting
- "Silent" logs will display only in studio

## [version 0.1.0](https://github.com/ffrostflame/BridgeNet2/releases/tag/v0.1.0): 2/19/2023

- Release
