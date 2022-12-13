--!strict

---@diagnostic disable: unused-local, unused-vararg
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

export type TPlayerType = { string & { Player } }

type TOutboundPacket = { { TPlayerType } & string & { any } }
type TInboundPacket = { string & {} }

local INVALID_PACKET_MESSAGE =
	"Player %*:%* sent an invalid packet. Likely exploiter- or something interacted with the internal BridgeNet API."
local INVALID_META_MESSAGE =
	"Player %*:%* sent an invalid meta message. Likely exploiter- or something interacted with the internal BridgeNet API."
local PACKET_LIMIT_OVERFLOW =
	"Player %*:%* has reached the packet limit of 12. Likely exploiter- or you're firing more than 12 times in the same frame."

local playerList: { [Player]: boolean } = {}
local loadingPlayers: { [Player]: number? } = {}
local loadingPlayersQueue: { [Player]: {}? } = {}

local outboundQueue: { [number]: TOutboundPacket } = {}
local inboundQueue: { [Player]: TInboundPacket? } = {}

local callbackMap: { [string]: { (...any) -> () } } = {}

-- Placeholder functions
type incorrectFormatHandler = (plr: Player) -> ()
local incorrectFormatHandler: incorrectFormatHandler = function() end

type incorrectTypeHandler = (plr: Player) -> ()
local incorrectTypeHandler: incorrectTypeHandler = function() end

type packetOverflowHandler = (plr: Player, packetCount: number) -> ()
local packetOverflowHandler: packetOverflowHandler = function() end

type incorrectMetaHandler = (plr: Player) -> ()
local incorrectMetaHandler: incorrectMetaHandler = function() end

local freeThread: thread? -- Thread reusage

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
	if freeThread == nil then
		freeThread = coroutine.create(yielder)
		coroutine.resume(freeThread :: thread)
	end
	task.spawn(freeThread :: thread, fn, ...)
end

local assertServer = if RunService:IsServer() then function() end else function(message)
	Output.fatal(message)
end

local Server = {}

function Server._startProcess()
	task.spawn(function()
		debug.setmemorycategory("BridgeNet2")
		Output.log("Loading")

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

		MetaRemoteEvent.OnServerEvent:Connect(function(plr, meta)
			if meta == "\1" then
				loadingPlayers[plr] = nil

				local queued = loadingPlayersQueue[plr]
				if queued then
					DataRemoteEvent:FireClient(plr, queued)
					loadingPlayersQueue[plr] = nil
				end
				--elseif meta == "\2" then
				-- Different meta messages for the future
			else
				incorrectMetaHandler(plr)
				Output.warn(string.format(INVALID_META_MESSAGE, plr.Name, plr.UserId))
			end
		end)

		DataRemoteEvent.OnServerEvent:Connect(
			function(plr, tbl)
				-- Do typechecking before inserting it into the queue- minimize errors in the queue.

				if typeof(tbl) ~= "table" then -- Invalid packet
					incorrectTypeHandler(plr)
					Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
					return
				end

				for _, v: TInboundPacket in tbl do
					local vType = typeof(v)
					if vType ~= "table" and vType ~= "string" then
						incorrectTypeHandler(plr)
						Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
						return
					end

					-- Insert
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
				
				-- Get who to send the payload to
				--if typeof(plrVal[1]) == "string" then
				if plrVal[1] == "all" then
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
				--end
			end

			for plr, toSend in sendStructure do
				if loadingPlayers[plr] then
					-- Isn't loaded yet, queue the call.
					local queuedRemotes = loadingPlayersQueue[plr]
					if queuedRemotes == nil then
						-- Create a queue
						loadingPlayersQueue[plr] = toSend
					else
						-- Add to queue
						for identifier, value in toSend do
							local queuedPackets = queuedRemotes[identifier]
							if queuedPackets == nil then -- Reconciliation
								queuedRemotes[identifier] = value
							else
								TableKit.MergeArray(queuedPackets, value)
							end
						end
					end
				else
					-- Already loaded, send the data.
					DataRemoteEvent:FireClient(plr, toSend)
				end

				sendStructure[plr] = nil
			end

			table.clear(outboundQueue)
			-- End BridgeNet2 send profile
			debug.profileend()

			debug.profilebegin("BridgeNet2.receive")

			for plr, data in inboundQueue do
				local dataLen = #data
				if dataLen >= 12 then
					packetOverflowHandler(plr, dataLen)
					Output.warn(string.format(PACKET_LIMIT_OVERFLOW, plr.Name, plr.UserId))
					continue
				end

				-- data should be an array like {identifier, packet} repeating
				local identifier: string?
				for _, value in data do
					local valueType = typeof(value) -- string = identifier, table = packet

					if valueType == "string" then
						identifier = value
						continue
					end

					if valueType == "table" then
						if not identifier then
							incorrectFormatHandler(plr)
							Output.warn(string.format("Incorrect format from player: %*:%*", plr.Name, plr.UserId))
							break
						end
						for _, callback in callbackMap[identifier] do
							RecycledSpawn(callback, plr, value)
						end
						identifier = nil
					else
						break
					end
				end
				if identifier then
					-- Identifier left over that was not followed by a valid packet
					incorrectFormatHandler(plr)
					Output.warn(string.format("Incorrect format from player: %*:%*", plr.Name, plr.UserId))
				end

				table.clear(data)
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

function Server._incorrectFormatHandler(func: incorrectFormatHandler)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectFormatHandler takes a function, got %*", typeof(func))
	)
	incorrectFormatHandler = func
end

function Server._incorrectTypeHandler(func: incorrectTypeHandler)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectTypeHandler takes a function, got %*", typeof(func))
	)
	incorrectTypeHandler = func
end

function Server._packetOverflowHandler(func: packetOverflowHandler)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("packetOverflowHandler takes a function, got %*", typeof(func))
	)
	packetOverflowHandler = func
end

function Server._packetMetaHandler(func: incorrectMetaHandler)
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectMetaHandler takes a function, got %*", typeof(func))
	)
	incorrectMetaHandler = func
end

function Server._idIntoBridge(identifier: string)
	callbackMap[identifier] = {}
end

function Server._connect(identifier: string, callback: (player: Player, object: any) -> nil)
	table.insert(callbackMap[identifier], callback)
end

function Server.AllPlayers(): TPlayerType
	assertServer("Cannot call .AllPlayers() from client")
	return { "all" }
end

function Server.PlayersExcept(blacklistedPlayers: { Player }): TPlayerType
	assertServer("Cannot call .PlayersExcept() from client")
	Output.fatalAssert(
		typeof(blacklistedPlayers) == "table" and TableKit.IsArray(blacklistedPlayers),
		string.format("PlayersExcept takes an array of players, got <%*> %*", typeof(blacklistedPlayers), blacklistedPlayers)
	)
	return { "except", blacklistedPlayers }
end

function Server.Players(setOfPlayers: { Player }): TPlayerType
	assertServer("Cannot call .Players() from client")
	Output.fatalAssert(
		typeof(setOfPlayers) == "table" and TableKit.IsArray(setOfPlayers),
		string.format("Players takes an array of players, got <%*> %*", typeof(setOfPlayers), setOfPlayers)
	)
	return { "set", setOfPlayers }
end

return Server
