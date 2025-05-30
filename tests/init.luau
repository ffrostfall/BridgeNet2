local TEST, CASE, CHECK, FINISH = require("@vendor/testkit").test()
local dataset_type = require("@tests/dataset/dataset_type")
local serdes = require("@bridgenet2/serdes")

local function check_dataset(dataset: dataset_type.T): boolean
	local fresh_dataset = dataset()

	local raw_data, events = fresh_dataset.make_raw(), fresh_dataset.make_events()

	local traffic_array, traffic_metadata = serdes.serialize(raw_data)

	serdes.deserialize(traffic_array, traffic_metadata, events)

	return fresh_dataset.check()
end

TEST("Serdes", function()
	CASE("test1")
	do
		CHECK(check_dataset(require("@tests/dataset/traffic/test1")))
	end

	CASE("one value")
end)

FINISH()
