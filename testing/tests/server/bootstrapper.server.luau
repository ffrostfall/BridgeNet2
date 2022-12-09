local ReplicatedStorage = game:GetService("ReplicatedStorage")

local framework = require(ReplicatedStorage.framework)

framework.bootstrapper:start({
	directories = {
		script.Parent.serverTests,
	},
	options = {
		context = framework,
	},
})
