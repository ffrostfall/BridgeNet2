--!strict
local wallyInstanceManager = require(script.Parent.Parent.Parent.wallyInstanceManager)
local Types = require(script.Parent.Parent.Types)
local Output = require(script.Parent.Parent.Utilities.Output)

local identifierStorage
local fullIdentifierMap = {}
local compressedIdentifierMap = {}
local yieldingThreads = {}

local ClientIdentifiers = {}

function ClientIdentifiers.start()
	-- Wait for IdentifierStorage to exist, since we're on the client and load order isn't guaranteed.
	identifierStorage = wallyInstanceManager.waitForInstance(script.Parent.Parent.Parent, "identifierStorage", 1)

	-- Loop through every single existing identifer, stored as an attribute.
	-- Simply parse them into the system.
	for identifier, value in identifierStorage:GetAttributes() do
		fullIdentifierMap[identifier] = value
		compressedIdentifierMap[value] = identifier
		ClientIdentifiers.loadIdentifier(identifier, value)
	end

	identifierStorage.AttributeChanged:Connect(function(id: string)
		local packed: string = identifierStorage:GetAttribute(id)

		if packed then
			-- Put the identifier into the system.
			fullIdentifierMap[id] = packed
			compressedIdentifierMap[packed] = id

			ClientIdentifiers.loadIdentifier(id, packed)
		else
			-- The identifier was deleted.
			-- TODO why is this here? you can't even delete identifiers atm
			local oldValue = fullIdentifierMap[id]
			fullIdentifierMap[id] = nil
			compressedIdentifierMap[oldValue] = nil
		end
	end)

	ClientIdentifiers.ref("NIL_VALUE", 3, false)
	ClientIdentifiers.ref("REQUEST", 3, false)
end

function ClientIdentifiers.loadIdentifier(identifierName: string, value: string)
	if not yieldingThreads[identifierName] then
		-- There aren't any yielding threads, so we don't need to resume any.
		return
	end

	local indexes = {}

	for index, thread in yieldingThreads[identifierName] do
		-- Resume yielding threads with the compressed identifier.
		-- This will make the function return the compressed identifier
		task.spawn(thread, value)

		-- Insert it to say we aren't yielding this thread anymore
		table.insert(indexes, index)
	end

	-- Since the timeout relies on knowing whether or not the thread is still yielding, we need to remove it.
	for _, index in indexes do
		table.remove(yieldingThreads[identifierName], index)
	end
end

function ClientIdentifiers.waitForIdentifier(identifierName: string, timeout: number, bridgeCall: boolean)
	timeout = timeout or 1

	local identifier = fullIdentifierMap[identifierName]
	if identifier then
		return identifier
	end

	if not yieldingThreads[identifierName] then
		yieldingThreads[identifierName] = {}
	end

	-- This needs to be a variable because the task.delay will run in a separate thread
	local runningThread = coroutine.running()
	table.insert(yieldingThreads[identifierName], runningThread)

	task.delay(timeout, function()
		-- Are we still yielding?
		if table.find(yieldingThreads[identifierName], runningThread) then
			Output.fatal(
				`reached max wait time for {if bridgeCall then "bridge" else "identifier"} {identifierName}, broke yield. Did you forget to implement it on the server?`
			)
		end
	end)

	return coroutine.yield()
end

function ClientIdentifiers.ref(identifierName: string, maxWaitTime: number?, bridgeCall: boolean)
	Output.typecheck("string", "ReferenceIdentifier", "identifierName", identifierName)

	if maxWaitTime ~= nil then
		Output.typecheck("number", "ReferenceIdentifier", "maxWaitTime", maxWaitTime)
	end
	local maxWaitTimeArg = maxWaitTime or 1

	local identifier = fullIdentifierMap[identifierName]
	if identifier then
		return identifier
	end

	return ClientIdentifiers.waitForIdentifier(identifierName, maxWaitTimeArg, bridgeCall)
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
