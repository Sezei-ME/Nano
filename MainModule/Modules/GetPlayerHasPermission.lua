return function(env,playerdata,permissionneeded)
	if type(playerdata) == 'userdata' then -- Likely they sent the player instead of the playerdata, better not punish the devs over it.
		playerdata = env.GetPlayerData(env,playerdata)
	end
	local info = env.GetGroupInfo(env,playerdata);
	local perms = string.split(info.Flags,";");
	local permissionfolder = string.split(permissionneeded,".");
	
	if permissionneeded == "Chat" then
		return info.Chat or false
	elseif permissionneeded == "UI" then
		return info.UI or false
	end
	
	for _,v in pairs(perms) do
		if v == "*" then -- It's a root admin .-.
			return true;
		else
			local localperm = string.split(v,".");
			if localperm[1] == permissionfolder[1] then
				if localperm[2] == "*" then
					return true;
				elseif localperm[2] == permissionfolder[2] then
					if permissionfolder[3] then
						if localperm[3] and localperm[3] == permissionfolder[3] or localperm[3] == "*" then
							return true;
						end
					else
						return true;
					end
				end
			end
		end
	end
	
	return false;
end
