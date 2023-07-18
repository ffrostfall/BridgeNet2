local TableKit = require(script.Parent.Parent.Parent.TableKit)

-- luau requires typecasts here
return function(data: any)
	if typeof(data) == "table" then
		if TableKit.IsArray(data) then
			return TableKit.ToArrayString(data)
		else
			return TableKit.ToString(data)
		end
	else
		local prefix = ""
		local suffix = ""
		if typeof(data) == "CFrame" then
			prefix = "CFrame("
			suffix = ")"
		elseif typeof(data) == "Vector3" then
			prefix = "Vector3("
			suffix = ")"
		end
		return `{prefix}{tostring(data)}{suffix}`
	end
end
