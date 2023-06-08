--!strict
local RunService = game:GetService("RunService")

local BridgeNet2 = require(script.BridgeNet2)
local Client = require(script.Client)
local Server = require(script.Server)
local NetworkUtils = require(script.Utilities.NetworkUtils)
local Output = require(script.Utilities.Output)

local isServer = RunService:IsServer()

task.spawn(function()
	if isServer then
		Server.start()
	else
		Client.start()
	end
end)

--[=[
	@class BridgeNet2
	
	The root namespace of BridgeNet2.
]=]

--[=[
	@function ToHex
	@within BridgeNet2

	Converts a string consisting of ASCII characters into hexadecimal. This is useful for representing
	binary strings and other human unreadable data (for example, connection IDs) into strings, which
	is easier to understand than say, a binary string which when directly converted into ASCII may have things
	like line breaks, and other weird character codes. The function uses string.format and string.byte()
	to convert the characters byte numerical code into hexadecimal.

	```lua
	-- "Example hexadecimal string" in ASCII
	local asciiString = "Example hexadecimal string"
	local hexString = BridgeNet2.ToHex(asciiString)

	print(hexString) -- Prints the hexadecimal form of 'Example hexadecimal string'
	```

	@param regularAscii string
	@return string
]=]

--[=[
	@function ToReadableHex
	@within BridgeNet2

	Converts a string consisting of ASCII characters into a more readable (bytes are separated) string of hex. This is mostly used for
	debugging binary strings- it looks nicer than ToHex. There are practical applications where ToHex is used internally and never revealed
	for debugging- but when hexadecimal is needed for debugging (as output strings can get cluttered very very quickly), this function
	should be used instead.

	```lua
	-- "Example hexadecimal string" in ASCII
	local asciiString = "Example hexadecimal string"
	local hexString = BridgeNet2.ToReadableHex(asciiString)

	print(hexString) -- Prints the hexadecimal form of 'Example hexadecimal string', but with spaces.
	```

	@param regularAscii string
	@return string
]=]

--[=[
	@function FromHex
	@within BridgeNet2

	Converts a hexadecimal string into a string of ASCII characters. This can be used for various purposes,
	for example, converting a globally uniue identifier (GUID) into a binary string, which saves data. Or you
	could convert a thread ID, or a memory address into a string for debugging purposes. Hexadecimal can be used
	for a variety of purposes. The function uses string.char alongside tonumber(string, 16) to convert the
	hexadecimal into a character code, which is converted into ASCII.

	```lua
	-- "Example hexadecimal string" in hex
	local hexString = "4578616D706C652068657861646563696D616C20737472696E67"
	local asciiString = BridgeNet2.FromHex(hexString)

	print(asciiString) -- Prints 'Example hexadecimal string'
	```

	@param hexadecimal string
	@return string
]=]

--[=[
	@function CreateUUID
	@within BridgeNet2

	Generates a new UUID (Universally Unique Identifier) in string format. This function uses the `GenerateGUID`
	method provided by the HttpService object to create a new UUID, and then removes the hyphens from the string
	before returning it.

	```lua
	-- "Example of creating a uuid string"
	local UUID = BridgeNet2.CreateUUID()

	print(UUID) -- Example output: "F7B64066F6B94012AA5FEFCEB38352E4"
	```

	@return string
]=]

--[=[
	@function ReferenceIdentifier
	@within BridgeNet2

	Assuming you have previous knowledge on the identifier system- which, if you do not, there is a small article written in the
	documentation site for BridgeNet2, `.ReferenceIdentifier` is how you initialize an identifier on the server.
	
	On the client, it simply reads from the already-existing dictionary to figure out what it should return. The only difference between
	`.FromIdentifier` and `.ReferenceIdentifier` on the client, is that ReferenceIdentifier will yield for up to 1 second until it
	breaks and returns the default name.
	
	```lua title="spellHandler.client.lua"
	local SpellCaster = BridgeNet2.ReferenceBridge("SpellCaster")

	local Fireball = BridgeNet2.ReferenceIdentifier("Fireball")

	SomeUserInputSignalHere:Connect(function(...)
		SpellCaster:Fire(Fireball) -- Fires a 1 or 2 character string, much smaller than an 8-character string.
	end)
	```
	
	@param identifierName string
	@return string
]=]

--[=[
	@function FromCompressed
	@within BridgeNet2
	
	The function returns a string representing the corresponding uncompressed identifier if the compressed
	identifier exists in BridgeNet2. If the identifier is not found, the function returns nil.
	
	```lua
	local Identifier = BridgeNet2.ReferenceIdentifier("FullIdentifierHere")
	
	print(BridgeNet2.FromCompressed(Identifier)) -- Prints "FullIdentifierHere"
	```
	
	@param compressedIdentifier string
	@return string
]=]

--[=[
	@function FromIdentifier
	@within BridgeNet2
	
	The function returns a string representing the compressed form of the identifier
	if it exists in BridgeNet2. If the identifier is not found, the function returns `nil`.
	
	```lua
	local Identifier = BridgeNet2.ReferenceIdentifier("FullIdentifierHere")
	
	print(BridgeNet2.FromIdentifier("FullIdentifierHere")) -- prints the compressed form of the identifier
	```
	
	@param identifierName string
	@return string
]=]

--[=[
	@function AllPlayers
	@within BridgeNet2
	
	Returns a symbol that when passed into ServerBridge:Fire(), tells the internal server process
	to send this data to every single player.
	
	@return PlayerSet
]=]

--[=[
	@function PlayersExcept
	@within BridgeNet2
	
	This function takes a list of players, and tells the internal server process to send this data to everyone
	except the specified blacklisted players.
	
	@param blacklistedPlayers { Players }
	@return PlayerSet
]=]

--[=[
	@function Players
	@within BridgeNet2
	
	This function takes a list of players, and tells the internal server process to send this data to everyone
	except the specified blacklisted players.
	
	@return PlayerSet
]=]

--[=[
	@function ReferenceBridge
	@within BridgeNet2
	
	The `ReferenceBridge` function creates a new instance of a bridge with the specified name.
	The `name` argument is a string representing the name of the `ServerBridge` or `ClientBridge` instance, respectively. The name is used to create a unique identifier for the instance within the system.
	
	```lua
	local Bridge = BridgeNet2.ReferenceBridge("MyBridge")
	
	Bridge:Connect(function() end)
	```
	
	@param name string
	@return ServerBridge | ClientBridge
]=]

--[=[
	@function HandleInvalidPlayer
	@within BridgeNet2
	
	Allows you to set a custom function for when a client sends an incorrect format.
	This should be used to implement something like a ban system, or a logging system.
	
	@return void
]=]

return (
	table.freeze({
		ToHex = NetworkUtils.ToHex,
		ToReadableHex = NetworkUtils.ToReadableHex,
		FromHex = NetworkUtils.FromHex,
		CreateUUID = NetworkUtils.CreateUUID,

		--- Identifiers
		ReferenceIdentifier = if isServer then Server.makeIdentifier else Client.makeIdentifier,
		Deserialize = if isServer then Server.deser else Client.deser,
		Serialize = if isServer then Server.ser else Client.ser,

		-- PlayerContainers
		AllPlayers = Server.playerContainers().All,
		PlayersExcept = Server.playerContainers().Except,
		Players = Server.playerContainers().Players,

		--- test
		ReferenceBridge = if isServer then Server.makeBridge else Client.makeBridge,

		HandleInvalidPlayer = function(handler: (player: Player) -> ())
			Output.fatalAssert(isServer, "Cannot call from client")
			Server.invalidPlayerhandler(handler)
		end,
	}) :: unknown
) :: BridgeNet2.BridgeNet2
