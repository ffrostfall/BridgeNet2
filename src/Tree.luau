local Tree = {}
Tree.__index = Tree

function Tree.new()
	local self = setmetatable({}, Tree)

	return self
end

function Tree:Destroy()
	setmetatable(self, nil)
end

return Tree
