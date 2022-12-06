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

return {
	-- NetworkUtils
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

	print(asciiString) -- Prints the hexadecimal form of 'Example hexadecimal string'
	```

	@param regularAscii string
	@return string
	]]
	ToHex = NetworkUtils.ToHex,
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
	-- "Example hexadecimal string" in ASCII
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
}
