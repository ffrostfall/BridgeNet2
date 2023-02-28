--!strict

---@diagnostic disable: unused-local, unused-vararg
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)
local TableKit = require(script.Parent.Parent.TableKit)

export type TPlayerType = {
	type: "set",
	plrVal: (Player | { Player }),
} | {
	type: "all",
} | {
	type: "except",
	plrVal: (Player | { Player }),
}
type TMetaMessage = "/1"
type TOutboundPacket = {
	plrs: TPlayerType,
	id: string,
	payload: { any },
}
type TInboundPacket = { string | {} }

local INVALID_PACKET_MESSAGE =
	"Player %*:%* sent an invalid packet. Likely exploiter- or something interacted with the internal BridgeNet API."
local PACKET_LIMIT_OVERFLOW =
	"Player %*:%* has reached the packet limit of 12. Likely exploiter- or you're firing more than 12 times in the same frame."

local isServer = RunService:IsServer()

local playerList: { [Player]: boolean } = {}
local loadingPlayers: { [Player]: number } = {}
local loadingPlayersQueue: { [Player]: {} } = {}

local outboundQueue: { [number]: TOutboundPacket } = {}
local inboundQueue: { [Player]: TInboundPacket } = {}

local callbackMap: { [string]: { (...any) -> () } } = {}

-- Placeholder functions
type TIncorrectFormatHandler = (plr: Player) -> ()
local incorrectFormatHandler: TIncorrectFormatHandler = function(...)
	return ...
end

type TIncorrectTypeHandler = (plr: Player) -> ()
local incorrectTypeHandler: TIncorrectTypeHandler = function(...)
	return ...
end

type TPacketOverflowHandler = (plr: Player, packetOverflowAmount: number) -> ()
local packetOverflowHandler: TPacketOverflowHandler = function(...)
	return ...
end

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

		MetaRemoteEvent.OnServerEvent:Connect(function(plr, meta: TMetaMessage)
			if meta == "/1" then -- Different meta messages for the future
				loadingPlayers[plr] = nil
				DataRemoteEvent:FireClient(plr, loadingPlayersQueue[plr])
				loadingPlayersQueue[plr] = nil
			end
		end)

		DataRemoteEvent.OnServerEvent:Connect(function(plr, tbl)
			-- Do typechecking before inserting it into the queue- minimize errors in the queue.
			if (typeof(tbl) ~= "table") or (not TableKit.IsArray(tbl)) then -- Invalid packet
				incorrectTypeHandler(plr)
				Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
				return
			end

			for _, packet: TInboundPacket in tbl do
				local packetType = typeof(packet)
				if packetType ~= "table" and packetType ~= "string" then
					incorrectTypeHandler(plr)
					Output.warn(string.format(INVALID_PACKET_MESSAGE, plr.Name, plr.UserId))
					return
				end

				table.insert(inboundQueue[plr], packet)
			end
		end)

		local sendStructure = {}
		RunService.PostSimulation:Connect(function()
			debug.profilebegin("BridgeNet2")

			debug.profilebegin("BridgeNet2.send")

			for _, outbound: TOutboundPacket in outboundQueue do
				local plrVal: TPlayerType = outbound.plrs
				local identifier: string = outbound.id
				local contents: { any } = outbound.payload

				if typeof(plrVal) == "Instance" then
					local plr = plrVal
					local structurePlr = sendStructure[plr]
					if not structurePlr then
						sendStructure[plr] = { [identifier] = { contents } }
					else
						if not structurePlr[identifier] then
							structurePlr[identifier] = { contents }
						else
							table.insert(structurePlr[identifier], contents)
						end
					end
				end

				if plrVal.type == "all" then -- Who to send the payload to
					for plr in playerList do
						local structurePlr = sendStructure[plr]
						if not structurePlr then -- If a structure doesn't exist for that player, create one
							sendStructure[plr] = { [identifier] = { contents } }
						else
							-- If a structure doesn't exist for that identifier,
							-- create one
							if not structurePlr[identifier] then
								structurePlr[identifier] = { contents }
							else
								table.insert(structurePlr[identifier], contents)
							end
						end
					end
				elseif plrVal.type == "except" then
					for _, plr in plrVal.plrVal :: { Player } do -- Set every single blacklisted player to false
						playerList[plr] = false
					end

					for plr, give in playerList do
						local structurePlr = sendStructure[plr]
						if give == true then -- Put the payload in every single players data, **if** they're not blacklisted
							if not structurePlr then
								sendStructure[plr] = { [identifier] = { contents } }
							else
								if not structurePlr[identifier] then
									structurePlr[identifier] = { contents }
								else
									table.insert(structurePlr[identifier], contents)
								end
							end
						else
							playerList[plr] = true
						end
					end
					-- Code execution is completely linear, so this is an ultra-fast way of doing blacklisted players
					-- in huge servers.
				elseif plrVal.type == "set" then
					for _, plr in plrVal.plrVal :: { Player } do
						local structurePlr = sendStructure[plr]
						if not structurePlr then
							sendStructure[plr] = { [identifier] = { contents } }
						else
							if not structurePlr[identifier] then
								structurePlr[identifier] = { contents }
							else
								table.insert(structurePlr[identifier], contents)
							end
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
				local dataLen = #data

				for i = 1, dataLen, 2 do
					local identifier, passed = data[i], data[i + 1]
					local callbacks = callbackMap[identifier]
					if not callbacks then
						continue
					end
					if typeof(passed) ~= "table" then
						incorrectFormatHandler(plr)
						Output.warn(string.format("Incorrect format from player: %*:%*", plr.Name, plr.UserId))
						break
					end
					for _, callback in callbacks do
						RecycledSpawn(callback, plr, passed)
					end
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

function Server._addToQueue(plrs: TPlayerType | Player, identifier: string, payload: { [any]: any })
	table.insert(outboundQueue, {
		plrs = plrs,
		id = identifier,
		payload = payload,
	})
end

function Server._incorrectFormatHandler(func: (plr: Player) -> ())
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectFormatHandler takes a function, got %*", typeof(func))
	)
	incorrectFormatHandler = func
end

function Server._incorrectTypeHandler(func: (plr: Player) -> ())
	Output.fatalAssert(
		typeof(func) == "function",
		string.format("incorrectTypeHandler takes a function, got %*", typeof(func))
	)
	incorrectTypeHandler = func
end

function Server._packetOverflowHandler(func: (plr: Player, num: number) -> ())
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
	return { type = "all" }
end

function Server.PlayersExcept(blacklistedPlayers: { Player }): TPlayerType
	Output.fatalAssert(isServer, "Cannot call .PlayersExcept() from client")
	Output.fatalAssert(
		typeof(blacklistedPlayers) == "table" and TableKit.IsArray(blacklistedPlayers),
		string.format("PlayersExcept takes an array of players, got %*", typeof(blacklistedPlayers))
	)
	return { type = "except", plrVal = blacklistedPlayers }
end

function Server.Players(setOfPlayers: { Player }): TPlayerType
	Output.fatalAssert(isServer, "Cannot call .Players() from client")
	Output.fatalAssert(
		typeof(setOfPlayers) == "table" and TableKit.IsArray(setOfPlayers),
		string.format("Players takes an array of players, got %*", typeof(setOfPlayers))
	)
	return { type = "set", plrVal = setOfPlayers }
end

return Server
