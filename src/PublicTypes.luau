--!strict
local Types = require(script.Parent.Types)

export type ServerBridge<send> = {
	Fire: (
		self: ServerBridge<send>,
		target: Player | (Types.AllPlayerContainer | Types.SetPlayerContainer),
		content: send
	) -> (),
	Connect: (
		self: ServerBridge<send>,
		callback: (player: Player, content: Types.Content?) -> (),
		name: string?
	) -> Connection,
	Once: (self: ServerBridge<send>, callback: (player: Player, content: Types.Content?) -> ()) -> (),
	Wait: (self: ServerBridge<send>) -> (Player, Types.Content?),

	OnServerInvoke: ((player: Player, content: Types.Content) -> ...any)?,
	RateLimitActive: boolean,
	Logging: boolean,
}
export type ClientBridge<send, receive> = {
	Fire: (self: ClientBridge<send, receive>, content: send) -> (),
	Connect: (self: ClientBridge<send, receive>, callback: (content: receive) -> (), name: string?) -> Connection,
	Once: (self: ClientBridge<send, receive>, callback: (content: receive) -> ()) -> (),
	Wait: (self: ClientBridge<send, receive>, callback: (content: receive) -> ()) -> receive,

	InvokeServerAsync: (self: ClientBridge<send, receive>, content: send) -> receive,

	Logging: boolean,
}

type Connection = {
	Disconnect: () -> (),
}

export type Bridge = ServerBridge<any> & ClientBridge<any, any>

export type BridgeNet2 = {
	ReferenceBridge: (name: string) -> Bridge,

	ClientBridge: (name: string) -> ClientBridge<any, any>,
	ServerBridge: (name: string) -> ServerBridge<any>,

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
