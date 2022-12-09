local Tree = {}
Tree.__index = Tree

function Tree._new()
	local self = setmetatable({}, Tree)

	self._tree = {}

	return self
end

function Tree:Get(str: string)
	
end

function Tree:Destroy()
	setmetatable(self, nil)
end

return Tree
