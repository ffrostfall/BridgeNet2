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

	The BridgeNet2 namespace which contains all of the functions included in the library. Luau and typescript APIs
	are completely separate- you cannot use the typescript API in Luau, and vice versa.
]]

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

	print(asciiString) -- Prints the hexadecimal form of 'Example hexadecimal string'
	```

	@param regularAscii string
	@return string
]]

--[[
	@function FromHex
	@within BridgeNet2

	Converts a hexadecimal string into a string of ASCII characters. This can be used for various purposes,
	for example, converting a globally uniue identifier (GUID) into a binary string, which saves data. Or you
	could convert a thread ID, or a memory address into a string for debugging purposes. Hexadecimal can be used
	for a variety of purposes. The function uses string.char alongside tonumber(string, 16) to convert the
	hexadecimal into a character code, which is converted into ASCII.

	```lua
	-- "Example hexadecimal string" in ASCII
	local hexString = "4578616D706C652068657861646563696D616C20737472696E67"
	local asciiString = BridgeNet2.FromHex(hexString)

	print(asciiString) -- Prints 'Example hexadecimal string'
	```

	@param hexadecimal string
	@return string
]]

--[[
	@function NumberToBestForm
	@within BridgeNet2

	@param num number
	@return number | string
]]

--[[
	@function CreateUUID
	@within BridgeNet2

	@return string
]]

--[[
	@function ReferenceIdentifier
	@within BridgeNet2

	@return string
]]

--[[
	@function FromCompressed
	@within BridgeNet2
]]

--[[
	@function FromIdentifier
	@within BridgeNet2
]]

--[[
	@function AllPlayers
	@within BridgeNet2
]]

--[[
	@function PlayersExcept
	@within BridgeNet2
]]

--[[
	@function Players
	@within BridgeNet2
]]

--[[
	@function Hook
	@within BridgeNet2
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
		return require(exists.Value)
	else
		local value = Instance.new("ObjectValue")
		value.Value = script
		value.Name = "BridgeNet2"
		value.Parent = ReplicatedStorage
	end
end

--[[
	return {
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

	-- Output
	Hook = Output.Hook,

	-- ReferenceBridge, pretty hacky.
	ServerBridge = ServerBridge,
	ClientBridge = ClientBridge,

	ReferenceBridge = (function()
		if isServer then
			return ServerBridge
		else
			return ClientBridge
		end
	end)(),
}

]]

export type ClientBridge<T> = ClientBridge.ClientBridge<T>
export type ServerBridge<T> = ServerBridge.ServerBridge<T>

export type TSecurityMeasures = "incorrectFormat" | "incorrectType" | "packetOverflow"
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
	local hexString = BridgeNet2.ToHex(asciiString)

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
	CreateUUID = NetworkUtils.CreateUUID,

	-- Identifiers
	ReferenceIdentifier = Identifiers.ReferenceIdentifier,
	FromCompressed = Identifiers.FromCompressed,
	FromIdentifier = Identifiers.FromIdentifier,

	-- Players
	AllPlayers = Server.AllPlayers,
	PlayersExcept = Server.PlayersExcept,
	Players = Server.Players,

	DebugMode = (function() end)(),

	-- Output
	Hook = Output.Hook,

	ReferenceBridge = (function()
		if isServer then
			return ServerBridge._new
		else
			return ClientBridge._new
		end
	end)() :: (name: string) -> (ClientBridge<any> | ServerBridge<any>),

	SetSecurity = function(
		securityMeasure: TSecurityMeasures,
		func: (player: Player) -> () | (player: Player, num: number) -> ()
	)
		Output.fatalAssert(isServer, "Cannot call SetSecurity from client")

		if securityMeasure == "incorrectType" then
			Server._incorrectTypeHandler(func)
		elseif securityMeasure == "incorrectFormat" then
			Server._incorrectFormatHandler(func)
		elseif securityMeasure == "packetOverflow" then
			Server._packetOverflowHandler(func)
		end
	end,
	SecurityMeasuresEnum = SecurityMeasures,
}

return ReturnValue
