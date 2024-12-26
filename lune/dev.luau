local process = require("@lune/process")

process.spawn("rojo", {
	"sourcemap",
	"default.project.json",
	"--output",
	"sourcemap.json",
	"--watch",
})
