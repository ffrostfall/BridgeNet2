local dataModelTree = require("@src/dataModelTree")
local logStrings = require("@src/logStrings")
local logger = require("@src/logger").new()
local identifierMap = require("@src/identifierMap")

local client = {}

function client.init(tree: dataModelTree.Identity)
	for name, id in tree.identifiers:GetAttributes() do
		if typeof(id) ~= "number" then
			logger:warn(string.format(logStrings.errors.ID_PROPERTY_INCORRECT_TYPE, typeof(id)))
			continue
		end

		identifierMap.addIdentifier(name, id)
	end

	tree.identifiers.AttributeChanged:Connect(function(name)
		local id = tree.identifiers:GetAttribute(name)

		if typeof(id) == "number" then
			-- Added case
			identifierMap.addIdentifier(name, id)
		elseif not id then
			-- Removed case
			identifierMap.removeIdentifier(name)
		end
	end)
end

return client
