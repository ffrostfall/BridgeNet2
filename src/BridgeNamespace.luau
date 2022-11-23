local BridgeNamespace = {}
BridgeNamespace.__index = BridgeNamespace

function BridgeNamespace.new()
	local self = setmetatable({}, BridgeNamespace)

	return self
end

function BridgeNamespace:Get() end

function BridgeNamespace:Create() end

return BridgeNamespace
