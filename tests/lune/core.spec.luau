local case, eof = require("@tests/suite")()
local encode = require("@src/core/encode")
local utils = require("@tests/utils")

case("encodes data correctly", function(interface)
	interface.expect.equal(encode({ 1, "test", 2, "test" }), {
		buff = buffer.fromstring(string.char(1) .. string.char(2)),
		events = {
			{ "test" },
			{ "test" },
		},
	})
end)

return eof()
