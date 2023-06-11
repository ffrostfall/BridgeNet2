--!strict
local Types = require(script.Parent.Types)

type ServerBridge = {
	Fire: (self: ServerBridge, target: Player | Types.PlayerContainer, content: Types.Content) -> (),
	Connect: (self: ServerBridge, callback: (player: Player, content: Types.Content?) -> ()) -> Connection,
	Once: (self: ServerBridge, callback: (player: Player, content: Types.Content?) -> ()) -> (),
	Wait: (self: ServerBridge, callback: (player: Player, content: Types.Content?) -> ()) -> (Player, Types.Content),

	RateLimitActive: boolean,
}
type ClientBridge = {
	Fire: (self: ClientBridge, content: Types.Content) -> (),
	Connect: (self: ClientBridge, callback: (content: Types.Content) -> ()) -> Connection,
}

type Connection = {
	Disconnect: () -> (),
}

export type Bridge = ServerBridge & ClientBridge & { Logging: boolean }

export type BridgeNet2 = {
	ReferenceBridge: (name: string) -> Bridge,

	ClientBridge: (name: string) -> ClientBridge,
	ServerBridge: (name: string) -> ServerBridge,

	ReferenceIdentifier: (name: string, maxWaitTime: number) -> Types.Identifier,

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
