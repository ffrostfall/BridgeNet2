local ReplicatedStorage = game:GetService("ReplicatedStorage")
local framework = require(ReplicatedStorage.framework)

framework.bootstrapper:start({
	directories = {
		script.Parent:WaitForChild("clientTests"),
	},
	options = {
		context = framework,
	},
})
