local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local BridgeNet2 = require(ReplicatedStorage.Packages.bridgenet2)

local TestType: StringValue = ReplicatedStorage:WaitForChild("StressTestValue") :: StringValue

local ALL_PLAYERS = BridgeNet2.AllPlayers()
local PAYLOAD = {}

if TestType.Value == "roblox" then
	local Remote = Instance.new("RemoteEvent")
	Remote.Parent = ReplicatedStorage

	RunService.Heartbeat:Connect(function()
		for _ = 1, 200 do
			Remote:FireAllClients()
		end
	end)
elseif TestType.Value == "bridgenet2" then
	local Bridge = BridgeNet2.ReferenceBridge("test")

	RunService.Heartbeat:Connect(function()
		for _ = 1, 200 do
			Bridge:Fire(ALL_PLAYERS, PAYLOAD)
		end
	end)
end
