local RunService = game:GetService("RunService")

local encode = require("@src/core/encode")
local types = require("@src/types")
local dataModelTree = require("@src/dataModelTree")
local logger = require("@src/logger").new("main client process")
local logStrings = require("@src/logStrings")
local signal = require("@pkg/signal")

local replicationRate: number = 1 / 61
local lastReplicationTick: number = 0
local queue: types.Queue = {}
local remote: RemoteEvent = nil
local metaRemote: RemoteEvent = nil
local idToSignal: { [number]: signal.Identity<...any> } = {}
local invocationQueue: { [number]: {} } = {}
local fireServer = Instance.new("RemoteEvent").FireServer

local function _assertRemote(func: string): ()
	if not (metaRemote and remote) then
		return logger:fatal(string.format(logStrings.errors.ACCESS_WITHOUT_INITIALIZATION, func))
	end
end

local client = {}

function client.init(tree: dataModelTree.Identity)
	remote = tree.remote
	metaRemote = tree.meta

	tree.parallel.Event:Connect(client.addEventCall)
	RunService.PostSimulation:Connect(client.step)
	remote.OnClientEvent:Connect(function(packed)
		local events: { [number]: { unknown } }, buff: buffer = packed[1], packed[2]

		if _G.__timetracing__ == "true" then
			debug.profilebegin("client event begin")
		end

		if _G.__verbose__ == "true" then
			print("remote call", events, buff)
		end

		for index, calls in events do
			local id = buffer.readu8(buff, index - 1)
			local eventSignal = idToSignal[id]
			if not eventSignal then
				warn("todo: handle this case")
				continue
			end

			-- Invocation queue logic
			-- gets if there are no connections to the table. Super hacky approach!
			if next(eventSignal) == nil then
				for _, value in calls do
					table.insert(invocationQueue[id], value)
				end

				continue
			end

			for _, value in calls do
				-- Event logic
				eventSignal:fire(value)
			end
		end

		if _G.__timetracing__ == "true" then
			debug.profilebegin("client event end")
		end
	end)

	metaRemote:FireServer("\0")
end

function client.setReplicationRate(newRate: number)
	replicationRate = 1 / newRate
end

function client.addEventCall(id: number, content: unknown)
	table.insert(queue, id)
	table.insert(queue, content)
end

function client.registerEvent(id: number)
	if _G.__verbose__ == "true" then
		print("registering event", id)
	end
	local eventSignal = signal()

	idToSignal[id] = eventSignal
end

function client.connect(id: number, callback: (content: unknown) -> ()): () -> ()
	if _G.__verbose__ == "true" then
		print("connection to", id)
	end
	local eventSignal = idToSignal[id]
	if not eventSignal then
		return logger:fatal(string.format(logStrings.errors.SIGNAL_NOT_INITIALIZED, tostring(id)))
	end

	return eventSignal:connect(callback)
end

function client.step(deltaTime: number)
	if ((os.clock() - lastReplicationTick) >= replicationRate) and (#queue > 0) then
		local serialized = encode(queue)
		fireServer(remote, { serialized.events :: any, serialized.buff :: any } :: any)
		table.clear(queue)

		lastReplicationTick = os.clock()
	end
end

return client
