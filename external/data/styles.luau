local colorful = require("@vendor/lunePackages/colorful")

local style = colorful.combineStyles
local colors = colorful.color
local modifiers = colorful.modifier

return {
	header = style({ colors.blue, modifiers.bold }),
	detail = style({ colors.white, modifiers.dim }),

	success = style({ colors.green, modifiers.bold }),
	error = style({ colors.red, modifiers.bold }),
	warning = style({ colors.yellow, modifiers.bold }),
}
