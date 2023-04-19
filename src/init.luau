--!strict
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Identifiers = require(script.Identifiers)
local Server = require(script.ServerProcess)
local Client = require(script.ClientProcess)
local NetworkUtils = require(script.NetworkUtils)
local Output = require(script.Output)
local ServerBridge = require(script.ServerBridge)
local ClientBridge = require(script.ClientBridge)

local isServer = RunService:IsServer()

if isServer then
	-- Duplicate module check
	local module = CollectionService:GetTagged("BridgeNet2")[1]
	if module then
		Output.warn(
			"Duplicate dependency found. Centralize your packages so that dependency duping doesn't occur, or use Wally, a package manager for roblox."
		)
		assert(module:IsA("ModuleScript"))
		return require(module)
	else
		-- This module will be the center one
		Output.warnAssert(
			script:IsDescendantOf(ReplicatedStorage),
			"It is strongly recommended to put the BridgeNet module in ReplicatedStorage, where both the client and server can access it."
		)
		CollectionService:AddTag(script, "BridgeNet2")
	end
else
	-- Server should add the tag, we will just wait for it
	local module = CollectionService:GetTagged("BridgeNet2")[1]
		or CollectionService:GetInstanceAddedSignal("BridgeNet2"):Wait()
	if module ~= script then
		assert(module:IsA("ModuleScript"))
		return require(module)
	end
end

task.spawn(function()
	Output.silent("Starting BridgeNet2 identifier process")
	Identifiers._startProcess()
	Output.silent("Starting BridgeNet2 object format process")
	if isServer then
		Output.log("Starting BridgeNet2 server process")
		Server._startProcess()
	else
		Output.log("Starting BridgeNet2 client process")
		Client._startProcess()
	end
end)

export type ESeverityLevel = "log" | "warn" | "error" | "fatal"
export type TOutputObject = {
	Severity: ESeverityLevel,
	Text: string,
}

export type TClientBridge<T> = ClientBridge.ClientBridge<T>
export type TServerBridge<T> = ServerBridge.ServerBridge<T>

export type ESecurityMeasures = "incorrectFormat" | "incorrectType" | "packetOverflow"
-- We have to have this type because Luau has no string literal inference and the type will resolve to "string"
type TSecurityMeasuresEnum = {
	IncorrectFormat: "incorrectFormat",
	IncorrectType: "incorrectType",
	PacketOverflow: "packetOverflow",
}

local SecurityMeasures: TSecurityMeasuresEnum = {
	IncorrectFormat = "incorrectFormat",
	IncorrectType = "incorrectType",
	PacketOverflow = "packetOverflow",
}

--[=[
	@class BridgeNet2
	
	The root namespace of BridgeNet2.
]=]

--[=[
	@function NumberToBestForm
	@within BridgeNet2

	Takes a number, and converts it into its most network efficient form. This works because a number is 9 bytes- but strings are (stringLen)+2,
	so a 1-character string to store a 1-digit number is more efficient than sending it as an actual number. This is way better- and it shows up
	at any real, practical scale. If you send this number over, you should **always** be calling tonumber on it! That is NOT optional.

	```lua
	-- "Example hexadecimal string" in ASCII
	local smallNumber = 4
	local bigNumber = 1000000000

	local smallNumberBestForm = BridgeNet2.NumberToBestForm(smallNumber)
	print(typeof(smallNumberBestForm)) -- prints "string"
	
	local bigNumberBestForm = BridgeNet2.NumberToBestForm(bigNumber)
	print(typeof(bigNumberBestForm)) -- prints "number"
	```

	@param number number
	@return string | number
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
	
	
	@return PlayerSet
]=]

--[=[
	@function PlayersExcept
	@within BridgeNet2
	
	
	@return PlayerSet
]=]

--[=[
		@function Players
		@within BridgeNet2
		
		
		@return PlayerSet
	]=]

--[=[
		@function ReadOutput
		@within BridgeNet2
		
		The BridgeNet2.ReadOutput function returns the logs table that stores all the output objects created by the logging functions. It is used to retrieve the log data so that it can be processed or displayed in some way. The logs table contains objects with two properties: Severity and Text. Severity represents the severity level of the log (log, warn, error, or fatal), while Text contains the string message associated with the log. By calling BridgeNet2.ReadOutput() in code, the logs table can be accessed and the data can be processed or analyzed.
			
		@return OutputLog
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
		@function SetSecurity
		@within BridgeNet2
		
		
		
		@return void
	]=]

--[=[
		@function SecurityMeasuresEnum
		@within BridgeNet2
		
		
		@return void
	]=]

local ReturnValue = {
	-- NetworkUtils

	NumberToBestForm = NetworkUtils.NumberToBestForm,

	ToHex = NetworkUtils.ToHex,

	ToReadableHex = NetworkUtils.ToReadableHex,

	FromHex = NetworkUtils.FromHex,

	CreateUUID = NetworkUtils.CreateUUID,

	-- Identifiers
	ReferenceIdentifier = Identifiers.ReferenceIdentifier,
	FromCompressed = Identifiers.FromCompressed,

	FromIdentifier = Identifiers.FromIdentifier,

	-- Players

	AllPlayers = Server.AllPlayers,
	PlayersExcept = Server.PlayersExcept,

	Players = Server.Players,

	ReadOutput = Output.Hook,

	ReferenceBridge = (
			((if isServer then ServerBridge._new else ClientBridge._new) :: any) :: () -> any
		) :: (name: string) -> (TClientBridge<any> | TServerBridge<any>),

	SetSecurity = function(
		securityMeasure: ESecurityMeasures,
		handler: (player: Player) -> () | (player: Player, num: number?) -> ()
	)
		Output.fatalAssert(isServer, "Cannot call SetSecurity from client")

		if securityMeasure == "incorrectType" then
			Server._incorrectTypeHandler(handler)
		elseif securityMeasure == "incorrectFormat" then
			Server._incorrectFormatHandler(handler)
		elseif securityMeasure == "packetOverflow" then
			Server._packetOverflowHandler(handler)
		end
	end,

	SecurityMeasuresEnum = SecurityMeasures,
}

return ReturnValue
