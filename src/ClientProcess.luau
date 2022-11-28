local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)

type TData = { [any]: any }

local outboundQueue: { string | {} } = {}
local inboundQueue: { { [string]: { { [any]: any } } } } = {}

local callbackMap: { [string]: { () -> nil } } = {}

local freeThread -- Thread reusage

local function Passer(fn, payload)
	local acquiredThread = freeThread
	freeThread = nil
	fn(payload)
	freeThread = acquiredThread
end

local function yielder()
	while true do
		Passer(coroutine.yield())
	end
end

local function RecycledSpawn(fn, payload)
	if not freeThread then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread)
	end
	task.spawn(freeThread, fn, payload)
end

local Client = {}

function Client._startProcess()
	debug.setmemorycategory("BridgeNet2")
	Output.log("Loading BridgeNet2")

	local DataRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("DataRemoteEvent")
	local MetaRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("MetaRemoteEvent")

	DataRemoteEvent.OnClientEvent:Connect(function(receivedData: { [string]: { TData } })
		table.insert(inboundQueue, receivedData)
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("BridgeNet2")

		debug.profilebegin("BridgeNet2.Send")

		if #outboundQueue > 0 then
			DataRemoteEvent:FireServer(outboundQueue)
			table.clear(outboundQueue)
		end

		debug.profileend()

		debug.profilebegin("BridgeNet2.Receive")
		if #inboundQueue > 0 then
			for _, obj in inboundQueue do
				for identifier, data in obj do
					local calls = callbackMap[identifier]
					if #calls == 1 then
						local callback = calls[1]
						for _, object in data do
							RecycledSpawn(callback, object)
						end
					else
						for _, object in data do
							for _, callback in calls do
								RecycledSpawn(callback, object)
							end
						end
					end
				end
			end
			table.clear(inboundQueue)
		end
		debug.profileend()

		debug.profileend()
	end)

	MetaRemoteEvent:FireServer("loaded")

	Output.log("Loaded")
end

function Client._idIntoBridge(identifier: string)
	callbackMap[identifier] = {}
end

function Client._addToQueue(identifier: string, object: {})
	table.insert(outboundQueue, identifier)
	table.insert(outboundQueue, object)
end

function Client._connect(identifier: string, callback: () -> nil)
	table.insert(callbackMap[identifier], callback)
end

return Client
