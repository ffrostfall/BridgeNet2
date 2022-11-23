local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)

local identifierCount = 0
local testingMode = false
local compressedIdentifierMap: { [string]: string } = {}
local fullIdentifierMap: { [string]: string } = {}
local autoSerde

local Identifiers = {}

function Identifiers._startProcess()
	if RunService:IsServer() then
		autoSerde = Instance.new("Folder")
		autoSerde.Name = "autoSerde"
		autoSerde.Parent = ReplicatedStorage
	else
		autoSerde = ReplicatedStorage:WaitForChild("autoSerde")
		for id, value in autoSerde:GetAttributes() do
			fullIdentifierMap[id] = value
			compressedIdentifierMap[value] = id
		end
		autoSerde.AttributeChanged:Connect(function(id: string)
			local packed: string = autoSerde:GetAttribute(id)
			if packed then
				fullIdentifierMap[id] = packed
				compressedIdentifierMap[packed] = id
			else
				local oldValue = fullIdentifierMap[id]
				fullIdentifierMap[id] = nil
				compressedIdentifierMap[oldValue] = nil
			end
		end)
	end
end

function Identifiers.TestingMode() -- For testing w/ Hoarcekat and other similar things where yielding isn't an option
end

function Identifiers.ReferenceIdentifier(name: string, maxWaitTime: number?): string?
	Output.fatalAssert(
		typeof(name) == "string",
		string.format("ReferenceIdentifier takes string, got %*", typeof(name))
	)
	Output.fatalAssert(
		typeof(maxWaitTime) ~= "nil" and typeof(maxWaitTime) ~= "number",
		string.format("ReferenceIdentifier second arg maxWaitTime takes number, got %*", typeof(name))
	)

	if RunService:IsServer() then
		-- 2^16 is the number of combinations in 2 bytes
		Output.fatalAssert(identifierCount >= 2 ^ 16, "cannot create any more identifiers, over 2^16 cap")

		identifierCount += 1
		local packed: string = string.pack("H", identifierCount)
		autoSerde:SetAttribute(name, packed)

		fullIdentifierMap[packed] = packed
		compressedIdentifierMap[packed] = name
	else
		if not fullIdentifierMap[name] then
			local timeout = 0

			while not fullIdentifierMap[name] do
				task.wait()
				if timeout >= maxWaitTime then
					break
				end
			end

			return if fullIdentifierMap[name]
				then fullIdentifierMap[name]
				else Output.Warn(string.format("infinite yield waiting for identifier %*", maxWaitTime))
		end
	end
end

function Identifiers.FromCompressed(compressed: string): string?
	Output.fatalAssert(
		typeof(compressed) == "string",
		string.format("FromCompressed takes string, got %*", typeof(compressed))
	)
	return compressedIdentifierMap[compressed]
end

function Identifiers.FromIdentifier(identifier: string): string?
	Output.fatalAssert(
		typeof(identifier) == "string",
		string.format("FromIdentifier takes string, got %*", typeof(identifier))
	)
	return fullIdentifierMap[identifier]
end

return Identifiers
