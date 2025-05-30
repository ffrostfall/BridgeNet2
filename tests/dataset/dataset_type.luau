-- ???
--stylua: ignore
export type T = () -> {
	check: () -> boolean,

	-- event_id: { item }
	make_raw: () -> { [number]: { unknown } },

	make_events: () -> { [number]: { (content: unknown, player: Player?) -> () } },
}

return nil
