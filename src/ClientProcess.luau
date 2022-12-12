local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)

type TData = { [any]: any }

local outboundQueue: { string | {} } = {}
local inboundQueue: { { [string]: { { [any]: any } } } } = {}

local callbackMap: { [string]: { (object: any) -> () } } = {}

local freeThread -- Thread reusage
local func = nil

local function passer(payload)
	local acquiredThread = freeThread
	freeThread = nil
	func(payload)
	freeThread = acquiredThread
end

local function yielder()
	while true do
		passer(coroutine.yield())
	end
end

local function RecycledSpawn(payload)
	if not freeThread then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread)
	end
	coroutine.resume(freeThread, payload)
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
				debug.profilebegin("packet")
				for identifier, data in obj do
					debug.profilebegin("fired: " .. #data)
					local calls = callbackMap[identifier]

					if not calls then
						continue
					end

					if #calls == 1 then
						local callback = calls[1]
						for _, object in data do
							func = callback
							RecycledSpawn(object)
						end
					else
						for _, object in data do
							for _, callback in calls do
								func = callback
								RecycledSpawn(object)
							end
						end
					end
					debug.profileend()
				end
				debug.profileend()
			end
			table.clear(inboundQueue)
		end
		debug.profileend()

		debug.profileend()
	end)

	task.spawn(function()
		-- Wait 5 frames to let other scripts execute.
		-- This is to let connections to bridges appear- there would be no point in the queueing functionality if BridgeNet2 loaded
		-- before your connections could actually connect.
		for _ = 1, 5 do
			task.wait()
		end
		MetaRemoteEvent:FireServer("loaded")
	end)

	Output.log("Loaded")
end

function Client._idIntoBridge(identifier: string)
	callbackMap[identifier] = {}
end

function Client._addToQueue(identifier: string, object: {})
	table.insert(outboundQueue, identifier)
	table.insert(outboundQueue, object)
end

function Client._connect(identifier: string, callback: (object: any) -> ())
	table.insert(callbackMap[identifier], callback)
end

return Client
