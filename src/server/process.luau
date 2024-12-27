--!native
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local dataModelTree = require("@src/dataModelTree")
local types = require("@src/types")
local encode = require("@src/core/encode")
local signal = require("@pkg/signal")
local logger = require("@src/logger").new("server process")
local logStrings = require("@src/logStrings")

local remote: RemoteEvent = nil
local playerQueues: { [Player]: types.Queue } = {}
local readyPlayers: { [Player]: true } = {}
local idToSignal: { [number]: signal.Identity<...any> } = {}
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

	Players.PlayerAdded:Connect(function(player)
		playerQueues[player] = {}
	end)

	Players.PlayerRemoving:Connect(function(player)
		readyPlayers[player] = nil
		playerQueues[player] = nil
	end)

	RunService.PostSimulation:Connect(server.step)
	tree.remote.OnServerEvent:Connect(function(player, packed)
		local events: { [number]: { unknown } }, buff: buffer = packed[1], packed[2]

		if _G.__timetracing__ == "true" then
			debug.profilebegin("server event begin")
		end

		if _G.__verbose__ == "true" then
			print("remote call", player, events, buff)
		end

		for index, calls in events do
			local id = buffer.readu8(buff, index - 1)
			local eventSignal = idToSignal[id]
			if not eventSignal then
				warn("todo: handle this case")
				continue
			end

			for _, value in calls do
				-- Event logic
				eventSignal:fire(value)
			end
		end

		if _G.__timetracing__ then
			debug.profilebegin("server event end")
		end
	end)
end

function server.addEvent(id: number)
	if _G.__verbose__ == "true" then
		print("registering event", id)
	end

	local eventSignal = signal()

	idToSignal[id] = eventSignal
end

function server.connect(id: number, callback: (content: unknown) -> ()): () -> ()
	if _G.__verbose__ == "true" then
		print("connection to", id)
	end

	local eventSignal = idToSignal[id]
	if not eventSignal then
		return logger:fatal(string.format(logStrings.errors.SIGNAL_NOT_INITIALIZED, tostring(id)))
	end

	return eventSignal:connect(callback)
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

	local serialized = encode(playerQueues[player])
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
