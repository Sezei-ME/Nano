return function(env,playerdata)
	if not playerdata then return nil end;
	
	if type(playerdata.FlagGroup) == 'string' then
		return env.Data.Settings.FlagGroups[playerdata.FlagGroup] or nil;
	elseif type(playerdata.FlagGroup) == 'table' then
		return playerdata.FlagGroup
	else
		return nil;
	end
end
