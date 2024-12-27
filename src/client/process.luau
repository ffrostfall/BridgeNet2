local RunService = game:GetService("RunService")

local serializer = require("@src/core/serializer")
local deserializer = require("@src/core/deserializer")
local types = require("@src/types")
local dataModelTree = require("@src/dataModelTree")
local logger = require("@src/logger").new("main client process")
local logStrings = require("@src/logStrings")

local replicationRate: number = 1 / 61
local lastReplicationTick: number = 0
local queue: types.Queue = {}
local remote: RemoteEvent = nil
local metaRemote: RemoteEvent = nil
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
		deserializer.decode(packed[1], packed[2])
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

function client.step(deltaTime: number)
	if ((os.clock() - lastReplicationTick) >= replicationRate) and (#queue > 0) then
		local serialized = serializer(queue)
		fireServer(remote, { serialized.events :: any, serialized.buff :: any } :: any)
		table.clear(queue)

		lastReplicationTick = os.clock()
	end
end

return client
