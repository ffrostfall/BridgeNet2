local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)

type TData = { [any]: any }

local outboundQueue: { string | {} } = {}

local callbackMap: { [string]: { () -> nil } } = {}

local freeThread -- Thread reusage

local function Passer(fn, ...)
	local acquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = acquiredThread
end

local function yielder()
	while true do
		Passer(coroutine.yield())
	end
end

local function RecycledSpawn(fn, ...)
	if not freeThread then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread)
	end
	task.spawn(freeThread, fn, ...)
end

local Client = {}

function Client._startProcess()
	task.spawn(function()
		debug.setmemorycategory("BridgeNet2")
		Output.log("Loading BridgeNet2")

		local DataRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("DataRemoteEvent")
		local MetaRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("MetaRemoteEvent")

		DataRemoteEvent.OnClientEvent:Connect(function(receivedData: { [string]: { TData } })
			for identifier, data in receivedData do
				for _, object in data do
					RecycledSpawn(callbackMap[identifier], object)
				end
			end
		end)

		RunService.PostSimulation:Connect(function()
			debug.profilebegin("BridgeNet2")

			debug.profilebegin("BridgeNet2.Send")

			DataRemoteEvent:FireServer(outboundQueue)
			table.clear(outboundQueue)

			debug.profileend()

			debug.profileend()
		end)

		MetaRemoteEvent:FireServer("loaded")

		Output.log("Loaded")
	end)
end

function Client._addToQueue(identifier: string, object: {})
	table.insert(outboundQueue, identifier)
	table.insert(outboundQueue, object)
end

function Client._connect(identifier: string, callback: () -> nil)
	table.insert(callbackMap[identifier], callback)
end

return Client
