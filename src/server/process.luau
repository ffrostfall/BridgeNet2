--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local dataModelTree = require("@src/dataModelTree")
local types = require("@src/types")
local serializer = require("@src/core/serializer")
local deserializer = require("@src/core/deserializer")

local remote: RemoteEvent
local playerQueues: { [Player]: types.Queue } = {}
local readyPlayers: { [Player]: true } = {}
local fireClient = Instance.new("RemoteEvent").FireClient

local server = {}

function server.init(tree: dataModelTree.Identity)
	tree.meta.OnServerEvent:Connect(function(player, str)
		if str == "\0" then
			readyPlayers[player] = true

			server.emptyPlayerQueue(player)

			if _G.__verbose__ then
				print(`player {player.Name} readied`)
			end
		end
	end)

	remote = tree.remote

	for _, player in Players:GetPlayers() do
		playerQueues[player] = {}
	end

	Players.PlayerAdded:Connect(function(player)
		playerQueues[player] = {}
	end)

	Players.PlayerRemoving:Connect(function(player)
		readyPlayers[player] = nil
		playerQueues[player] = nil
	end)

	RunService.PostSimulation:Connect(server.step)
	tree.remote.OnServerEvent:Connect(function(player, packed)
		deserializer.decode(packed[1], packed[2], player)
	end)
end

function server.firePlayer(player: Player, id: number, content: unknown)
	local queue = playerQueues[player]

	table.insert(queue, id)
	table.insert(queue, content)
end

function server.fireAll(id: number, content: unknown)
	for _, queue in playerQueues do
		table.insert(queue, id)
		table.insert(queue, content)
	end
end

function server.emptyPlayerQueue(player: Player)
	if #playerQueues[player] == 0 then
		return
	end

	if _G.__verbose__ == "true" then
		print(`emptying {player.Name} queue`)
	end

	local serialized = serializer(playerQueues[player])
	fireClient(remote, player, { serialized.events, serialized.buff :: any } :: any)
	table.clear(playerQueues[player])
end

function server.step()
	if _G.__timetracing__ == "true" then
		debug.profilebegin("server begin")
	end

	for player in readyPlayers do
		server.emptyPlayerQueue(player)
	end

	if _G.__timetracing__ == "true" then
		debug.profileend()
	end
end

return server
