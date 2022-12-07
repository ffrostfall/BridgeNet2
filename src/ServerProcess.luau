---@diagnostic disable: unused-local, unused-vararg
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

export type TPlayerType = {
	[number]: string | { Player },
}
type TMetaMessage = "loaded"
type TOutboundPacket = { [number]: { TPlayerType } | string | { any } }
type TInboundPacket = { string | {} }

local INVALID_PACKET_MESSAGE =
	"Player %*:%* sent an invalid packet. Likely exploiter- or something interacted with the internal BridgeNet API."
local PACKET_LIMIT_OVERFLOW =
	"Player %*:%* has reached the packet limit of 12. Likely exploiter- or you're firing more than 12 times in the same frame."

local isServer = RunService:IsServer()

local playerList: { [Player]: boolean? } = {}
local loadingPlayers: { [Player]: number? } = {}
local loadingPlayersQueue: { [Player]: {}? } = {}

local outboundQueue: { [number]: TOutboundPacket } = {}
local inboundQueue: { [Player]: TInboundPacket? } = {}

local callbackMap: { [string]: { () -> nil } } = {}

-- Placeholder functions
local incorrectFormatHandler: (plr: Player) -> () = function(...)
	return ...
end
local incorrectTypeHandler: (plr: Player) -> () = function(...)
	return ...
end
local packetOverflowHandler: (plr: Player, number) -> () = function(...)
	return ...
end

local freeThread -- Thread reusage

local function passer(fn, ...)
	local acquiredThread = freeThread
	freeThread = nil
	fn(...)
	freeThread = acquiredThread
end

local function yielder()
	while true do
		passer(coroutine.yield())
	end
end

local function RecycledSpawn(fn, ...)
	if not freeThread then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread)
	end
	task.spawn(freeThread, fn, ...)
end

local Server = {}

function Server._startProcess()
	task.spawn(function()
		debug.setmemorycategory("BridgeNet2")
		Output.log("Loading BridgeNet2")

		local MetaRemoteEvent = Instance.new("RemoteEvent")
		local DataRemoteEvent = Instance.new("RemoteEvent")

		MetaRemoteEvent.Name = "MetaRemoteEvent"
		DataRemoteEvent.Name = "DataRemoteEvent"

		MetaRemoteEvent.Parent = ReplicatedStorage
		DataRemoteEvent.Parent = ReplicatedStorage

		Players.PlayerAdded:Connect(function(plr)
			playerList[plr] = true
			loadingPlayers[plr] = 0
			loadingPlayersQueue[plr] = {}
			inboundQueue[plr] = {}
		end)

		Players.PlayerRemoving:Connect(function(plr)
			playerList[plr] = nil
			loadingPlayers[plr] = nil
			loadingPlayersQueue[plr] = nil
			inboundQueue[plr] = nil
		end)

		MetaRemoteEvent.OnServerEvent:Connect(function(plr, meta: TMetaMessage)
			if meta == "loaded" then -- Different meta messages for the future
				loadingPlayers[plr] = nil
				DataRemoteEvent:FireClient(plr, loadingPlayersQueue[plr])
				loadingPlayersQueue[plr] = nil
			end
		end)

		DataRemoteEvent.OnServerEvent:Connect(
			function(plr, tbl) -- Do typechecking before inserting it into the queue- minimize errors in the queue.
				print(tbl)
				if typeof(tbl) ~= "table" then -- Invalid packet
					incorrectTypeHandler(plr)
					Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
					return
				end

				for _, v: TInboundPacket in tbl do
					if typeof(v) ~= "table" and typeof(v) ~= "string" then
						incorrectTypeHandler(plr)
						Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
						return
					end

					table.insert(inboundQueue[plr], v)
				end
			end
		)

		local sendStructure = {}
		RunService.PostSimulation:Connect(function()
			debug.profilebegin("BridgeNet2")

			debug.profilebegin("BridgeNet2.send")

			for _, outbound: TOutboundPacket in outboundQueue do
				local plrVal: { TPlayerType } = outbound[1]
				local identifier: string = outbound[2]
				local contents: { any } = outbound[3]

				if typeof(plrVal[1]) == "string" then
					if plrVal[1] == "all" then -- Who to send the payload to
						for plr in playerList do
							if not sendStructure[plr] then -- If a structure doesn't exist for that player, create one
								sendStructure[plr] = { [identifier] = { contents } }
							else
								-- If a structure doesn't exist for that identifier,
								-- create one
								if not sendStructure[plr][identifier] then
									sendStructure[plr][identifier] = { contents }
								else
									table.insert(sendStructure[plr][identifier], contents)
								end
							end
						end
					elseif plrVal[1] == "except" then
						for _, plr in plrVal[2] do -- Set every single blacklisted player to false
							playerList[plr] = false
						end

						for plr, give in playerList do
							if give == true then -- Put the payload in every single players data, **if** they're not blacklisted
								if not sendStructure[plr] then
									sendStructure[plr] = { [identifier] = { contents } }
								else
									if not sendStructure[plr][identifier] then
										sendStructure[plr][identifier] = { contents }
									else
										table.insert(sendStructure[plr][identifier], contents)
									end
								end
							else
								playerList[plr] = true
							end
						end
						-- Code execution is completely linear, so this is an ultra-fast way of doing blacklisted players
						-- in huge servers.
					elseif plrVal[1] == "set" then
						for _, plr in plrVal[2] do
							if not sendStructure[plr] then
								sendStructure[plr] = { [identifier] = { contents } }
							else
								if not sendStructure[plr][identifier] then
									sendStructure[plr][identifier] = { contents }
								else
									table.insert(sendStructure[plr][identifier], contents)
								end
							end
						end
					end
				else
					local plr = plrVal[2]
					if not sendStructure[plr] then
						sendStructure[plr] = { [identifier] = { contents } }
					else
						if not sendStructure[plr][identifier] then -- Reconciliation
							sendStructure[plr][identifier] = { contents }
						else
							table.insert(sendStructure[plr][identifier], contents)
						end
					end
				end
			end

			for plr, toSend in sendStructure do
				if loadingPlayers[plr] then -- Detect if player isn't loaded yet. If not, queue the call.
					if loadingPlayersQueue[plr] == nil then
						loadingPlayersQueue[plr] = toSend
					else
						for identifier, value in toSend do
							if loadingPlayersQueue[plr][identifier] == nil then -- Reconciliation
								loadingPlayersQueue[plr][identifier] = value
							else
								TableKit.MergeArray(loadingPlayersQueue[plr][identifier], value)
							end
						end
					end
				else
					DataRemoteEvent:FireClient(plr, toSend)
				end

				sendStructure[plr] = nil
			end

			table.clear(outboundQueue)
			-- End BridgeNet2 send profile
			debug.profileend()

			debug.profilebegin("BridgeNet2.receive")

			for plr, data in inboundQueue do
				if #data >= 12 then
					packetOverflowHandler(plr, #data)
					Output.warn(string.format(PACKET_LIMIT_OVERFLOW, plr.Name, plr.UserId))
					continue
				end

				local skip = false
				for position, value in data do
					-- Got skipped because last one was an identifier
					if skip == true then
						skip = false
						continue
					end
					if typeof(value) == "string" then
						skip = true
					else
						incorrectFormatHandler(plr)
						Output.warn(string.format("Incorrect format from player: %*:%*", plr.Name, plr.UserId))
						continue
					end

					if typeof(data[position + 1]) ~= "table" then
						incorrectFormatHandler(plr)
						Output.warn(string.format("Incorrect format from player: %*:%*", plr.Name, plr.UserId))
						continue
					end

					local passed = data[position + 1]
					for _, callback in callbackMap[value] do
						RecycledSpawn(callback, plr, passed)
					end
				end

				table.clear(inboundQueue[plr])
			end

			-- End BridgeNet2 receive profile
			debug.profileend()

			-- End BridgeNet2 debug profile
			debug.profileend()
		end)

		Output.log("Loaded")
	end)
end

function Server._addToQueue(plrs: TPlayerType, identifier: string, payload: { [any]: any })
	table.insert(outboundQueue, {
		plrs,
		identifier,
		payload,
	})
end

function Server._incorrectFormatHandler(func: (plr: Player) -> nil)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectFormatHandler takes a function, got %*", typeof(func))
	)
	incorrectFormatHandler = func
end

function Server._incorrectTypeHandler(func: (plr: Player) -> nil)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectTypeHandler takes a function, got %*", typeof(func))
	)
	incorrectTypeHandler = func
end

function Server._packetOverflowHandler(func: (plr: Player, num: number) -> nil)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("packetOverflowHandler takes a function, got %*", typeof(func))
	)
	packetOverflowHandler = func
end

function Server._idIntoBridge(identifier: string)
	callbackMap[identifier] = {}
end

function Server._connect(identifier: string, callback: (player: Player, object: any) -> nil)
	table.insert(callbackMap[identifier], callback)
end

function Server.AllPlayers(): TPlayerType
	Output.fatalAssert(isServer, "Cannot call .AllPlayers() from client")
	return { "all" }
end

function Server.PlayersExcept(blacklistedPlayers: { Player }): TPlayerType
	Output.fatalAssert(isServer, "Cannot call .AllPlayers() from client")
	Output.fatalAssert(
		typeof(blacklistedPlayers) == "table",
		string.format("PlayersExcept takes an array of players, got %*", typeof(blacklistedPlayers))
	)
	return { "except", blacklistedPlayers }
end

function Server.Players(setOfPlayers: { Player }): TPlayerType
	Output.fatalAssert(isServer, "Cannot call .AllPlayers() from client")
	Output.fatalAssert(
		typeof(setOfPlayers) == "table",
		string.format("Players takes an array of players, got %*", typeof(setOfPlayers))
	)
	return { "set", setOfPlayers }
end

return Server
