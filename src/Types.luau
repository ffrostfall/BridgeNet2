--!strict
export type Set<T> = { [T]: true | false }
export type Array<T> = { [number]: T }
export type Callback = (...unknown) -> ()
export type Map<T, K> = { [T]: K }

export type MetaMessage = "1"

export type ServerConnectionCallback = (Player, Content) -> ()
export type Content = unknown
export type Identifier = string

-- Player containers
export type PlayerContainerTypes = "all" | "set" | "except" | "single"

export type SetPlayerContainer = {
	kind: "set",
	value: Array<Player>,
}

export type ExceptPlayerContainer = {
	kind: "except",
	value: { [number]: Player },
}

export type SinglePlayerContainer = {
	kind: "single",
	value: Player,
}

export type AllPlayerContainer = {
	kind: "all",
	value: nil,
}

export type PlayerContainer = SetPlayerContainer | ExceptPlayerContainer | SinglePlayerContainer | AllPlayerContainer

export type PlayerContainerIndexes = {
	All: () -> AllPlayerContainer,
	Except: (excludedPlayers: Array<Player>) -> ExceptPlayerContainer,
	Single: (player: Player) -> SinglePlayerContainer,
	Players: (players: Array<Player>) -> SetPlayerContainer,
}

export type ServerInboundPacket = {}
export type ServerOutboundPacket = {
	playerContainer: PlayerContainer,
	content: unknown,
	id: Identifier,
}

return nil
