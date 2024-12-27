local fs = require("@lune/fs")
local process = require("@lune/process")

if not fs.isDir("vendor/") then fs.writeDir("vendor/") end

process.spawn("git", {
	"clone",
	"https://github.com/ffrostfall/lunePackages.git",
	"vendor/lunePackagesRepo",
}, {
	stdio = "forward",
})

if fs.isDir("vendor/lunePackages") then fs.removeDir("vendor/lunePackages") end
fs.copy("vendor/lunePackagesRepo", "vendor/lunePackages")
fs.removeDir("vendor/lunePackagesRepo")
