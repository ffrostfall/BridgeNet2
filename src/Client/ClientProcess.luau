--!strict
local RunService = game:GetService("RunService")

local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)
local RecycledSpawn = require(script.Parent.Parent.Utilities.RecycledSpawn)
local version = require(script.Parent.Parent.version)

local outboundQueue: { string | any } = {}
local outboundQueueLength: number = 0 -- Cannot use # operator because of potentially nil values
local inboundQueue: { { [string]: { { [any]: any } } } } = {}
local callbackMap: { [string]: { (object: any) -> () } } = {}

local ClientProcess = {}

function ClientProcess.start()
	debug.setmemorycategory("BridgeNet2")
	Output.log(`Loading client version {version}`)

	-- :WaitForChild() to confirm instances exist, we're in another thread.
	local DataRemoteEvent: RemoteEvent =
		wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "dataRemoteEvent", 1)
	local MetaRemoteEvent: RemoteEvent =
		wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "metaRemoteEvent", 1)

	DataRemoteEvent.OnClientEvent:Connect(function(receivedData)
		table.insert(inboundQueue, receivedData)
	end)

	RunService.PostSimulation:Connect(function()
		debug.profilebegin("BridgeNet2")

		-- Client-sided sending is extremely simple.
		-- Cannot use # operator because nil values...
		if outboundQueueLength > 0 then
			-- We need to do this or else Roblox will tostring the table indexes.
			-- dont even. just dont. i dont want to know.
			DataRemoteEvent:FireServer({ table.unpack(outboundQueue, 1, outboundQueueLength) })
			outboundQueueLength = 0
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
					if #data == 0 then
						RecycledSpawn(callback)
					else
						for _, content in data do
							RecycledSpawn(callback, content)
						end
					end
				else
					if #data == 0 then
						for _, callback in calls do
							RecycledSpawn(callback)
						end
					else
						for _, callback in calls do
							for _, content in data do
								RecycledSpawn(callback, content)
							end
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

function ClientProcess.registerBridge(identifier: Types.Identifier)
	-- This is here because bridges can be registered multiple times
	if not callbackMap[identifier] then
		callbackMap[identifier] = {}
	end
end

function ClientProcess.addToQueue(identifier: Types.Identifier, object: any)
	-- Every even number should be content, every odd number should be the identifier.
	-- Can't use table.insert because of potential nil values
	-- Can't use # operator because of potential nil values
	outboundQueue[outboundQueueLength + 1] = object
	outboundQueue[outboundQueueLength + 2] = identifier
	outboundQueueLength += 2
end

function ClientProcess.connect(identifier: Types.Identifier, callback: (content: Types.Content) -> ())
	table.insert(callbackMap[identifier], callback)

	-- Disconnect function
	return function()
		local index = table.find(callbackMap[identifier], callback)
		table.remove(callbackMap[identifier], index)
		return
	end
end

return ClientProcess
