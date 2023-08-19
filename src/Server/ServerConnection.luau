--!strict
local ServerProcess = require(script.Parent.ServerProcess)

type connectionType = { Connected: boolean }

local Connection = {}

local CLASS_METATABLE = { __index = Connection }

function CLASS_METATABLE:__tostring()
	return "ServerConnection"
end

function Connection:Disconnect()
	self.Connected = nil

	self._disconnectCallback()

	table.clear(self)
	setmetatable(self, nil)
end

return function(identifier, callback)
	local self = setmetatable({
		Connected = true,

		_disconnectCallback = function() end,
	}, CLASS_METATABLE)

	self._disconnectCallback = ServerProcess.connect(identifier, callback)

	return self :: unknown
end
