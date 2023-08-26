--!strict
local MockConnection = require(script.Parent.MockConnection)
local Constants = require(script.Parent.Parent.Constants)
local Output = require(script.Parent.Parent.Utilities.Output)
local TableKit = require(script.Parent.Parent.Parent.TableKit)
local RemotePacketSizeCounter = require(script.Parent.Parent.Parent.RemotePacketSizeCounter)
local Types = require(script.Parent.Parent.Types)
local tostringData = require(script.Parent.Parent.Utilities.tostringData)

local mockBridgePrototype = {}

local CLASS_METATABLE = { __index = mockBridgePrototype }

function CLASS_METATABLE:__tostring()
	return "ClientBridge"
end

function mockBridgePrototype:RateLimit()
	Output.warn("cannot call :RateLimit() from client")
end

function mockBridgePrototype:DisableRateLimit()
	Output.warn("cannot call :DisableRateLimit() from client")
end

function mockBridgePrototype:InboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "InboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("InboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._inboundMiddleware = middlewareTable
end

function mockBridgePrototype:OutboundMiddleware(middlewareTable: { (object: any) -> any })
	Output.fatalAssert(tostring(self) == "ClientBridge", "OutboundMiddleware called with . instead of :")
	Output.fatalAssert(
		typeof(middlewareTable) == "table",
		string.format("OutboundMiddleware takes table, got %*", typeof(middlewareTable))
	)
	Output.warnAssert(TableKit.IsArray(middlewareTable), "InboundMiddleware takes array, got dictionary.")

	self._outboundMiddleware = middlewareTable
end

function mockBridgePrototype:Fire(content: any)
	Output.fatalAssert(tostring(self) == "ClientBridge", "Fire called with . instead of :")

	if self.Logging then
		local logOutput = string.format(
			Constants.CLIENT_FIRE_LOG,
			self._name,
			tostringData(content),
			RemotePacketSizeCounter.GetDataByteSize(content)
		)
		Output.log(logOutput)
	end
end

function mockBridgePrototype:Connect(callback: (content: Types.Content) -> ())
	Output.fatalAssert(tostring(self) == "ClientBridge", "connect called with . instead of :")
	Output.typecheck("function", "Connect", "callback", callback)

	return MockConnection()
end

function mockBridgePrototype:Wait()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Wait called with . instead of :")
	-- Again, very basic QoL implementation of :Wait()
	local thread = coroutine.running()
	self:Once(function(content)
		task.spawn(thread, content)
	end)
	return coroutine.yield()
end

function mockBridgePrototype:InvokeServerAsync(_: any)
	Output.fatalAssert(tostring(self) == "ClientBridge", "InvokeServerAsync called with . instead of :")

	return coroutine.yield()
end

function mockBridgePrototype:Once(_: (content: Types.Content) -> ())
	Output.fatalAssert(tostring(self) == "ClientBridge", "Once called with . instead of :")

	return MockConnection()
end

function mockBridgePrototype:Destroy()
	Output.fatalAssert(tostring(self) == "ClientBridge", "Destroy called with . instead of :")
	-- Don't actually do any logic here- remember that ClientBridges are really just listening objects that let the end user communicate.
	table.clear(self)
	setmetatable(self, nil)
end

return function(name: string)
	local self = setmetatable({
		Logging = false,

		_identifier = name,
		_name = name,

		_inboundMiddleware = {},
		_outboundMiddleware = {},
	}, CLASS_METATABLE)

	return self
end
