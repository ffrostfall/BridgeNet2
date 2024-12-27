local WFC_TIMEOUT = 3

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local result = require("@src/util/result")
local logStrings = require("@src/logStrings")

local cached: Identity? = nil

export type Identity = {
	container: Folder,
	remote: RemoteEvent,
	meta: RemoteEvent,
	parallel: BindableEvent,
	parallelConnections: Camera,

	identifiers: Folder,
}

local function create(): Identity
	local container = Instance.new("Folder")
	local remote = Instance.new("RemoteEvent")
	local meta = Instance.new("RemoteEvent")
	local identifiers = Instance.new("Folder")
	local parallel = Instance.new("BindableEvent")
	local parallelConnections = Instance.new("Camera")

	identifiers.Name = "identifiers"
	meta.Name = "meta"
	remote.Name = "remote"
	container.Name = "bridgenet2"
	parallel.Name = "parallel"
	parallelConnections.Name = "parallelConnections"

	identifiers.Parent = container
	meta.Parent = container
	remote.Parent = container
	parallel.Parent = container
	parallelConnections.Parent = container

	container.Parent = ReplicatedStorage

	local tree = {
		container = container,
		remote = remote,
		meta = meta,
		parallel = parallel,
		identifiers = identifiers,
		parallelConnections = parallelConnections,
	}
	cached = tree

	return tree
end

local function find(): result.Identity<Identity>
	local container = ReplicatedStorage:WaitForChild("bridgenet2", WFC_TIMEOUT)
	if not container then
		return result(false, logStrings.errors.INSTANCE_NOT_FOUND)
	end

	if not container:IsA("Folder") then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local remote = container:WaitForChild("remote", WFC_TIMEOUT)
	if not (remote and remote:IsA("RemoteEvent")) then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local meta = container:WaitForChild("meta", WFC_TIMEOUT)
	if not (meta and meta:IsA("RemoteEvent")) then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local parallel = container:WaitForChild("parallel", WFC_TIMEOUT)
	if not (parallel and parallel:IsA("BindableEvent")) then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local identifiers = container:WaitForChild("identifiers", WFC_TIMEOUT)
	if not (identifiers and identifiers:IsA("Folder")) then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local parallelConnections = container:WaitForChild("parallelConnections", WFC_TIMEOUT)
	if not (parallelConnections and parallelConnections:IsA("Camera")) then
		return result(false, logStrings.errors.INSTANCE_NOT_VALID)
	end

	local tree = {
		container = container,
		remote = remote,
		parallel = parallel,
		meta = meta,
		parallelConnections = parallelConnections,
		identifiers = identifiers,
	}
	cached = tree

	return result(true, tree)
end

return function(fresh: boolean?): result.Identity<Identity>
	if cached then
		return result(true, cached)
	end

	if RunService:IsServer() then
		if fresh then
			return result(true, create())
		else
			return find()
		end
	else
		return find()
	end
end
