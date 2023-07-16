--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)

local identifierStorage
local fullIdentifierMap = {}
local compressedIdentifierMap = {}
local yieldingThreads = {}

local ClientIdentifiers = {}

function ClientIdentifiers.start()
	-- Wait for IdentifierStorage to exist, since we're on the client and load order isn't guaranteed.
	identifierStorage = ReplicatedStorage:WaitForChild("identifierStorage")

	-- Loop through every single existing identifer, stored as an attribute.
	-- Simply parse them into the system.
	for id, value in identifierStorage:GetAttributes() do
		fullIdentifierMap[id] = value
		compressedIdentifierMap[value] = id
	end

	identifierStorage.AttributeChanged:Connect(function(id: string)
		local packed: string = identifierStorage:GetAttribute(id)

		if packed then
			-- If there's any threads waiting for an identifer, resume them, then delete the reference entirely.
			local waitingThreads = yieldingThreads[id]
			if waitingThreads then
				for thread in waitingThreads do
					task.spawn(thread, packed)
				end

				yieldingThreads[id] = nil
			end

			-- Put the identifier into the system.
			fullIdentifierMap[id] = packed
			compressedIdentifierMap[packed] = id
		else
			-- The identifier was deleted.
			-- TODO why is this here? you can't even delete identifiers atm
			local oldValue = fullIdentifierMap[id]
			fullIdentifierMap[id] = nil
			compressedIdentifierMap[oldValue] = nil
		end
	end)

	ClientIdentifiers.ref("NIL_VALUE")
end

function ClientIdentifiers.ref(identifierName: string, maxWaitTime: number?)
	Output.typecheck("string", "ReferenceIdentifier", "identifierName", identifierName)

	if RunService:IsStudio() then
		fullIdentifierMap[identifierName] = identifierName
		compressedIdentifierMap[identifierName] = identifierName
		return identifierName
	end

	if maxWaitTime ~= nil then
		Output.typecheck("number", "ReferenceIdentifier", "maxWaitTime", maxWaitTime)
	end
	local maxWaitTimeArg = maxWaitTime or 1

	local identifier = fullIdentifierMap[identifierName]
	if identifier then
		return identifier
	end

	local thread = coroutine.running()

	local threads = yieldingThreads[identifierName]
	if threads then
		threads[thread] = true
	else
		threads = { [thread] = true }
		yieldingThreads[identifierName] = threads
	end

	-- Simple timeout implementation
	local timeOut = task.delay(maxWaitTimeArg, function()
		threads[thread] = nil

		task.spawn(thread, nil)
	end)

	local retrievedIdentifier = coroutine.yield()
	-- cancel the timeout thread

	if retrievedIdentifier == nil then
		Output.fatal(
			`reached max wait time for identifier {identifierName}, broke yield. Did you forget to implement it on the server?`
		)
	else
		task.cancel(timeOut)
	end

	return retrievedIdentifier
end

function ClientIdentifiers.deser(compressedIdentifier: Types.Identifier): Types.Identifier?
	Output.fatalAssert(
		typeof(compressedIdentifier) == "string",
		string.format("Deserialize takes string, got %*", typeof(compressedIdentifier))
	)
	return compressedIdentifierMap[compressedIdentifier]
end

function ClientIdentifiers.ser(identifierName: Types.Identifier): Types.Identifier?
	Output.fatalAssert(
		typeof(identifierName) == "string",
		string.format("Serialize takes string, got %*", typeof(identifierName))
	)
	return fullIdentifierMap[identifierName]
end

return ClientIdentifiers
