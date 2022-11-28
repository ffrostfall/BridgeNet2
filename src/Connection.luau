local Connection = {}
Connection.__index = Connection

local function directPass()
	coroutine.yield()
end

function Connection.new(func: (...any) -> nil)
	 local self = setmetatable({}, Connection)
	 
	 self.Function = func
	 
	 return self
end

function Connection:Spawn<T>(payload: T)
	
end

return Connection