--!strict
local Types = require(script.Parent.Types)

type ServerBridge = {
	Fire: (
		self: ServerBridge,
		target: Player | (Types.AllPlayerContainer | Types.SetPlayerContainer),
		content: Types.Content
	) -> (),
	Connect: (
		self: ServerBridge,
		callback: (player: Player, content: Types.Content?) -> (),
		name: string?
	) -> Connection,
	Once: (self: ServerBridge, callback: (player: Player, content: Types.Content?) -> ()) -> (),
	Wait: (self: ServerBridge, callback: (player: Player, content: Types.Content?) -> ()) -> (Player, Types.Content?),

	OnServerInvoke: ((player: Player, content: Types.Content) -> ...any)?,
	RateLimitActive: boolean,
	Logging: boolean,
}
type ClientBridge = {
	Fire: (self: ClientBridge, content: any?) -> (),
	Connect: (self: ClientBridge, callback: (content: Types.Content?) -> (), name: string?) -> Connection,
	Once: (self: ClientBridge, callback: (content: Types.Content?) -> ()) -> (),
	Wait: (self: ClientBridge, callback: (content: Types.Content?) -> ()) -> Types.Content?,

	InvokeServerAsync: (self: ClientBridge, content: any?) -> ...Types.Content?,

	Logging: boolean,
}

type Connection = {
	Disconnect: () -> (),
}

export type Bridge = ServerBridge & ClientBridge

export type BridgeNet2 = {
	ReferenceBridge: (name: string) -> Bridge,

	ClientBridge: (name: string) -> ClientBridge,
	ServerBridge: (name: string) -> ServerBridge,

	ReferenceIdentifier: (name: string, maxWaitTime: number?) -> Types.Identifier,

	Serialize: (identifierName: string) -> Types.Identifier,
	Deserialize: (compressedIdentifier: string) -> Types.Identifier,

	ToHex: (regularString: string) -> string,
	ToReadableHex: (regularString: string) -> string,
	FromHex: (hexadecimal: string) -> string,

	Players: (players: Types.Array<Player>) -> Types.SetPlayerContainer,
	AllPlayers: () -> Types.AllPlayerContainer,
	PlayersExcept: (excludedPlayers: Types.Array<Player>) -> Types.ExceptPlayerContainer,

	CreateUUID: () -> string,

	HandleInvalidPlayer: (handler: (player: Player) -> ()) -> (),
}

return nil
