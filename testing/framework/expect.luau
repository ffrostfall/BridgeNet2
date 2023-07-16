--[[
    We use a "cases" table for storing assertion method so that
    we can add more methods and alias later on without being in elseif's hell
]]

local cases = {
	equal = function(self)
		return function(expectedThing: any)
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = value == expectedThing

			if never then
				result = not result
			end

			assert(
				result,
				string.format(
					"Expected value to %sbe %s, got %s",
					never and " never" or "",
					tostring(expectedThing),
					tostring(value)
				)
			)
		end
	end,

	never = function(self)
		rawset(self, "_never", not rawget(self, "_never"))
		return self
	end,

	exist = function(self)
		return function()
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = value ~= nil

			if never then
				result = not result
			end

			assert(
				result,
				string.format("Expected value to%s exist, got %s", never and " never" or "", tostring(value))
			)
		end
	end,

	throw = function(self)
		return function()
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = pcall(value)
			result = not result

			if never then
				result = not result
			end

			assert(result, string.format("Expected value to %serror", never and " never" or ""))
		end
	end,

	match = function(self)
		return function(expectedPattern: string)
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = string.match(value, expectedPattern) ~= nil

			if never then
				result = not result
			end

			assert(
				result,
				string.format(
					"Expected %s to %smatch '%s'",
					tostring(value),
					never and " never" or "",
					tostring(expectedPattern)
				)
			)
		end
	end,

	near = function(self)
		return function(expectToBeNear: number)
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = math.round(value) == math.round(expectToBeNear)

			if never then
				result = not result
			end

			assert(
				result,
				string.format(
					"Expected %s to %sbe near '%s'",
					tostring(value),
					never and " never" or "",
					tostring(expectToBeNear)
				)
			)
		end
	end,
	a = function(self)
		return function(expectedType: string)
			local never = rawget(self, "_never")
			local value = rawget(self, "_value")

			local result = (typeof(value) == expectedType) or (typeof(value) == "Instance" and value:IsA(expectedType))

			if never then
				result = not result
			end

			assert(
				result,
				string.format(
					"Expected %s to%s be %s",
					tostring(value),
					never and " never" or "",
					tostring(expectedType)
				)
			)
		end
	end,
}

-- alias
cases.equals = cases.equal
cases.exists = cases.exist
cases.throws = cases.throw
cases.fail = cases.throw
cases.fails = cases.throw
cases.matches = cases.match

return function(this: any)
	local query = setmetatable({
		_value = this,
		_never = false,
	}, {
		__index = function(self, queryName)
			local func = cases[queryName]

			if func then
				return func(self)
			end

			return self
		end,
	})

	return query
end
