local dataModelTree = require("@src/dataModelTree")
local logStrings = require("@src/logStrings")
local logger = require("@src/logger").new()
local map = require("@src/identifiers/map")

local client = {}

function client.init(tree: dataModelTree.Identity)
	for name, id in tree.identifiers:GetAttributes() do
		if typeof(id) ~= "number" then
			logger:warn(string.format(logStrings.errors.ID_PROPERTY_INCORRECT_TYPE, typeof(id)))
			continue
		end

		map.addIdentifier(name, id)
	end

	tree.identifiers.AttributeChanged:Connect(function(name)
		local id = tree.identifiers:GetAttribute(name)

		if typeof(id) == "number" then
			-- Added case
			map.addIdentifier(name, id)
		elseif not id then
			-- Removed case
			map.removeIdentifier(name)
		end
	end)
end

return client
