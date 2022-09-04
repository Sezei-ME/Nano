return function(env,playerdata,permissionneeded)
	if type(playerdata) == 'userdata' then -- Likely they sent the player instead of the playerdata, better not punish the devs over it.
		playerdata = env.GetPlayerData(env,playerdata)
	end
	local info = env.GetGroupInfo(env,playerdata);
	local perms = string.split(info.Flags,";");
	local permissionfolder = string.split(string.lower(permissionneeded),".");

	env.Bind:Fire("PermissionChecked",playerdata.UserId,permissionneeded);

	if permissionneeded == "Chat" then
		return info.Chat or false
	elseif permissionneeded == "UI" then
		return info.UI or false
	end
	
	-- Disallow GameSettings in VIP Servers; It's safer that way, even with the sandboxed datastore.
	if permissionneeded == "Nano.GameSettings" then
		if (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
			return false;
		end
	end	

	for _,v in pairs(perms) do
		if v == "*" then -- Giving root admin is extremely dangerous; it ignores negatives.
			return true;
		else
			local localperm = string.split(string.lower(v),".");
			local negative = (localperm[1]:sub(1,1) == "-")
			if negative then
				localperm[1] = localperm[1]:sub(2);
			end
			if localperm[1] == permissionfolder[1] then
				if localperm[2] == "*" then
					if negative then return false end;
					return true;
				elseif localperm[2] == permissionfolder[2] then
					if permissionfolder[3] then
						if localperm[3] and localperm[3] == permissionfolder[3] or localperm[3] == "*" then
							if negative then return false end;
							return true;
						end
					else
						if negative then return false end;
						return true;
					end
				end
			end
		end
	end

	return false;
end