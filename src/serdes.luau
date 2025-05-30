export type TrafficArray = {
	-- { [event_id]: { event_call } }
	[number]: { unknown },
}
export type TrafficMetadata = buffer

local serdes = {}

function serdes.serialize(events: { [number]: { unknown } }): (TrafficArray, TrafficMetadata)
	local traffic_array: TrafficArray = {}
	-- { [real_id]: temp_id }
	local used_keys: { [number]: number }, used_key_counter: number = {}, 0

	for key, event_queue in events do
		local index = used_keys[key]

		if not index then
			used_key_counter += 1
			used_keys[key] = used_key_counter
		end

		traffic_array[index] = event_queue
	end

	local buff = buffer.create(used_key_counter * 2)

	for real_id, temp_id in used_keys do
		buffer.writeu16(buff, temp_id * 2, real_id)
	end

	return traffic_array, buff
end

function serdes.deserialize(
	traffic_array: TrafficArray,
	traffic_metadata: TrafficMetadata,
	events: { [number]: { (data: unknown, player: Player?) -> () } },
	player: Player?
)
	local event_id_count = buffer.len(traffic_metadata) // 2
	local array_index_event_id_map: { [number]: number } = table.create(event_id_count, 0)

	for temp_id = 0, event_id_count do
		array_index_event_id_map[temp_id] = buffer.readu16(traffic_metadata, temp_id)
	end

	for temp_id, event_queue in traffic_array do
		for _, callback in events[array_index_event_id_map[temp_id]] do
			for _, item in event_queue do
				callback(item, player)
			end
		end
	end
end

return serdes
