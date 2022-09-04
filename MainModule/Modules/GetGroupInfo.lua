return function(env,playerdata)
	-- This function checks what permissions the player has. Due to the nature of the permissions system, it checks for a group that already exists (if it's a string containing the group name), or simply returns the table of the permissions if it's a table.
	if not playerdata then return nil end;

	if type(playerdata.FlagGroup) == 'string' then
		return env.Data.Settings.FlagGroups[playerdata.FlagGroup] or nil;
	elseif type(playerdata.FlagGroup) == 'table' then
		return playerdata.FlagGroup
	else
		return nil;
	end
end
