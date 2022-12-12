--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Identifiers = require(script.Identifiers)
local Server = require(script.ServerProcess)
local Client = require(script.ClientProcess)
local NetworkUtils = require(script.NetworkUtils)
local Output = require(script.Output)
local ObjectFormat = require(script.ObjectFormat)
local ServerBridge = require(script.ServerBridge)
local ClientBridge = require(script.ClientBridge)

local isServer = RunService:IsServer()

--[[
	@class BridgeNet2

	The BridgeNet2 root namespace which contains all of the functions included in the library. Luau and typescript APIs
	are completely separate- you cannot use the typescript API in Luau, and vice versa.
]]

task.spawn(function()
	Output.silent("Starting BridgeNet2 identifier process")
	Identifiers._startProcess()
	Output.silent("Starting BridgeNet2 object format process")
	ObjectFormat._startProcess()
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

-- Dependency dupe prevention
if isServer then
	Output.warnAssert(
		script:IsDescendantOf(ReplicatedStorage),
		"It is strongly recommended to put the BridgeNet module in ReplicatedStorage, where both the client and server can access it."
	)

	local exists = ReplicatedStorage:FindFirstChild("BridgeNet2") :: ObjectValue
	if exists then
		Output.warn(
			"Duplicate dependency found. Either use Wally, a package manager for roblox, or centralize your packages so dependency duping doesn't occur,"
		)
		return require(exists.Value :: ModuleScript)
	else
		local value = Instance.new("ObjectValue")
		value.Value = script
		value.Name = "BridgeNet2"
		value.Parent = ReplicatedStorage
	end
end

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

local ReturnValue = {
	-- NetworkUtils

	--[[
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
	]]
	NumberToBestForm = NetworkUtils.NumberToBestForm,

	--[[
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
	]]
	ToHex = NetworkUtils.ToHex,

	--[[
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
	]]
	ToReadableHex = NetworkUtils.ToReadableHex,

	--[[
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
	]]
	FromHex = NetworkUtils.FromHex,

	--[[
		@function CreateUUID
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

		@return string
	]]
	CreateUUID = NetworkUtils.CreateUUID,

	-- Identifiers
	--[[
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
	]]
	ReferenceIdentifier = Identifiers.ReferenceIdentifier,

	--[[
		@function FromCompressed
		@within BridgeNet2
		
		
		
		@param compressedIdentifier
		@return string
	]]
	FromCompressed = Identifiers.FromCompressed,

	--[[
		@function FromIdentifier
		@within BridgeNet2
		
		
		
		@param identifierName
		@return string
	]]
	FromIdentifier = Identifiers.FromIdentifier,

	-- Players

	--[[
		@function AllPlayers
		@within BridgeNet2
		
		
		@return PlayerSet
	]]
	AllPlayers = Server.AllPlayers,

	--[[
		@function PlayersExcept
		@within BridgeNet2
		
		
		@return PlayerSet
	]]
	PlayersExcept = Server.PlayersExcept,

	--[[
		@function Players
		@within BridgeNet2
		
		
		@return PlayerSet
	]]
	Players = Server.Players,

	--[[
		@function ReadOutput
		@within BridgeNet2
		
		
		@return OutputLog
	]]
	ReadOutput = Output.Hook,

	--[[
		@function ReferenceBridge
		@within BridgeNet2
		
		
		@return ServerBridge | ClientBridge
	]]
	ReferenceBridge = ((function()
		if isServer then
			return ServerBridge._new :: any
		else
			return ClientBridge._new :: any
		end
	end)() :: () -> any) :: (name: string) -> (TClientBridge<any> | TServerBridge<any>),

	--[[
		@function SetSecurity
		@within BridgeNet2
		
		
		@return void
	]]
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
