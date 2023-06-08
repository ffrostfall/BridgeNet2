--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Parent.Utilities.Output)
local RecycledSpawn = require(script.Parent.Parent.Utilities.RecycledSpawn)

type TData = { [any]: any }

local outboundQueue: { string | {} } = {}
local inboundQueue: { { [string]: { { [any]: any } } } } = {}

local callbackMap: { [string]: { (object: any) -> () } } = {}

local ClientProcess = {}

function ClientProcess.start()
	debug.setmemorycategory("BridgeNet2")
	Output.log("Loading BridgeNet2")

	-- :WaitForChild() to confirm instances exist, we're in another thread.
	local DataRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("dataRemoteEvent")
	local MetaRemoteEvent: RemoteEvent = ReplicatedStorage:WaitForChild("metaRemoteEvent")

	DataRemoteEvent.OnClientEvent:Connect(function(receivedData: { [string]: { TData } })
		table.insert(inboundQueue, receivedData)
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("BridgeNet2")

		-- Client-sided sending is extremely simple.
		if #outboundQueue > 0 then
			DataRemoteEvent:FireServer(outboundQueue)
			table.clear(outboundQueue)
		end

		debug.profilebegin("BridgeNet2:Receive")
		for _, incomingPacket in inboundQueue do
			for identifier, data in incomingPacket do
				local calls = callbackMap[identifier]

				if not calls then
					continue
				end

				if #calls == 1 then
					local callback = calls[1]
					for _, content in data do
						RecycledSpawn(callback, content)
					end
				else
					for _, content in data do
						for _, callback in calls do
							RecycledSpawn(callback, content)
						end
					end
				end
			end
		end

		table.clear(inboundQueue)
		debug.profileend()
	end)

	task.spawn(function()
		-- Wait 15 frames to let other scripts execute.
		-- This is to let connections to bridges appear- there would be no point in the queueing functionality if BridgeNet2 loaded
		-- before your connections could actually connect.
		for _ = 1, 15 do
			task.wait()
		end
		MetaRemoteEvent:FireServer("1")
	end)

	Output.log("Loaded")
end

function ClientProcess.registerBridge(identifier: string)
	callbackMap[identifier] = {}
end

function ClientProcess.addToQueue(identifier: string, object: {})
	-- Every even number should be content, every odd number should be the identifier.
	table.insert(outboundQueue, identifier)
	table.insert(outboundQueue, object)
end

function ClientProcess.connect(identifier: string, callback: (object: any) -> ())
	table.insert(callbackMap[identifier], callback)

	-- Disconnect function
	return function()
		local index = table.find(callbackMap[identifier], callback)
		table.remove(callbackMap[identifier], index)
		return
	end
end

return ClientProcess
