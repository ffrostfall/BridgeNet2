--!strict
local Types = require(script.Parent.Types)

type ServerBridge = {
	Fire: (self: ServerBridge, target: Player | Types.PlayerContainer, content: Types.Content) -> (),
	Connect: (self: ServerBridge, callback: <T, K>(player: Player, content: Types.Content?) -> ()) -> (),
}
type ClientBridge = {
	Fire: (self: ClientBridge, content: Types.Content) -> (),
	Connect: (self: ClientBridge, callback: (content: Types.Content) -> ()) -> (),
}

type Connection = {
	Disconnect: () -> (),
}

export type Bridge = ServerBridge & ClientBridge

export type BridgeNet2 = {
	ReferenceBridge: (name: string) -> Bridge,

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
