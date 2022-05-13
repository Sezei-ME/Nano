local module = {}

function module:ResolveCode(code:number)
	-- Negative Values: Game/Roblox fault
	if code == -1 then
		return "Server is taking too long to respond."
	-- Positive Values: User's fault
	elseif code == 1 then
		return "This should not be visible for you!!!!"		
	-- Zero value: Unknown error
	elseif code == 0 then
		return "A unique error has occured! Make sure to report this to the development team!"
	end
end

return module
