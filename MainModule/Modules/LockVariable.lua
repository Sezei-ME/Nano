-- DEPRECATION WARNING: Upon the release of the 4th phase of the beta, this module will be removed!

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