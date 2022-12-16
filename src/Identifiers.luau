--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Output = require(script.Parent.Output)

type recursiveTree = {
	[string]: recursiveTree | string,
}

local testingMode = false
local identifierCount = 0
local compressedIdentifierMap: { [string]: string } = {}
local fullIdentifierMap: { [string]: string } = {}
local IdentifierStorage

local Identifiers = {}

function Identifiers._startProcess()
	if RunService:IsServer() then
		IdentifierStorage = Instance.new("Folder")
		IdentifierStorage.Name = "IdentifierStorage"
		IdentifierStorage.Parent = ReplicatedStorage
	else
		IdentifierStorage = ReplicatedStorage:WaitForChild("IdentifierStorage")
		for id, value in IdentifierStorage:GetAttributes() do
			fullIdentifierMap[id] = value
			compressedIdentifierMap[value] = id
		end
		IdentifierStorage.AttributeChanged:Connect(function(id: string)
			local packed: string = IdentifierStorage:GetAttribute(id)
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

function Identifiers._testingMode() -- For testing w/ Hoarcekat and other similar things where yielding isn't an option
	testingMode = true
end

function Identifiers.ReferenceIdentifier(name: string, maxWaitTime: number?): string
	Output.fatalAssert(
		typeof(name) == "string",
		string.format("ReferenceIdentifier takes string, got %*", typeof(name))
	)
	
	if maxWaitTime == nil then
		maxWaitTime = 1
	else
		Output.fatalAssert(
			typeof(maxWaitTime) == "number",
			string.format("ReferenceIdentifier second arg maxWaitTime takes number, got %*", typeof(name))
		)
	end
	
	if testingMode then
		fullIdentifierMap[name] = name
		compressedIdentifierMap[name] = name
		return name
	end

	if RunService:IsServer() then
		Output.fatalAssert(identifierCount <= 1114111, "cannot create any more identifiers - over 1114111 cap.")
		Output.silent(string.format("creating identifier: %*, identifier count: %*", name, identifierCount))

		local packed = utf8.char(identifierCount)
		identifierCount += 1
		IdentifierStorage:SetAttribute(name, packed)

		fullIdentifierMap[name] = packed
		compressedIdentifierMap[packed] = name

		return packed
	else
		local waitingTime = 0
		
		while true do
			local identifier = fullIdentifierMap[name]
			if identifier then
				return identifier
			end
			waitingTime += task.wait()
			if waitingTime >= maxWaitTime then
				Output.warn(string.format("reached max wait time for identifier %*, broke yield.", name))
				return ""
			end
		end
	end
end

function Identifiers.Tree(tree: recursiveTree, waitTime: number?)
	Output.fatalAssert(typeof(tree) == "table", string.format("tree takes a table, not a %*", typeof(tree)))

	local identifierTree = {}

	for name, value in tree do
		Output.errorAssert(typeof(name) == "string", "you should not pass a non-string value in your tree table")
		if typeof(value) == "table" then
			Identifiers.Tree(value, waitTime or 0.8)
		else
			identifierTree[name] = Identifiers.ReferenceIdentifier(value, waitTime or 0.8)
		end
	end

	return identifierTree
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
