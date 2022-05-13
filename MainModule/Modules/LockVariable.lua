local freezetbl = {}
local vars = {}

function vars:Set(var,data)
	if freezetbl[var] then
		return freezetbl[var]
	else
		freezetbl[var] = data
		return data
	end
end

function vars:Get(var)
	return freezetbl[var]
end

return table.freeze(vars)