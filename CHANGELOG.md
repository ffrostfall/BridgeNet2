# BridgeNet2

This project uses [semver](https://semver.org/spec/v2.0.0.html).

## version 0.3.0: 6/8/2023

- Added Hoarcekat support
- Massive internal re-structuring
- Renamed `FromIdentifier` and `FromCompressed` to `Serialize` and `Deserialize`
- NumberToBestForm removed (feature bloat)
- StartLogging and StopLogging have been removed in favor of `object.Logging =`
- Logging now displays the packet size in bytes (using @PysephWasntAvailable's [RemotePacketSizeCounter](https://github.com/PysephWasntAvailable/RemotePacketSizeCounter) package)
- Compliant with strict Luau typing
- Type improvements
- Internally commented the entire project
- Removed SetSecurity and SecurityEnums in favor of `HandleInvalidPlayer`
- Literally dozens of bugfixes

## version 0.2.2

- Hotfix

## version 0.2.1

- Fixed a bug w/ :Wait() on ClientBridge
- Default format/type security errors no longer throw
- Added :Once() and :Wait() to ClientBridge

## version 0.2.0

- Removed .Hook()
- Added :Once()
- Added :Wait()
- Added :StartLogging() and :StopLogging()
- Added :Disconnect() to connections
- "Silent" logs will display only in studio
- Added single-player targeting

## version 0.1.0

- Release
