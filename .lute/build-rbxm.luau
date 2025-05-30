local process = require("@lute/process")

local result = process.run({ "rojo", "build", "--output", "bridgenet2.rbxm" })
print(result.stdout)
