local function FindPlayers(Runner,Name)
	local matches = {}
	if string.len(Name) == 0 then return nil end
	for i,v in next,game:GetService("Players"):GetPlayers() do
		local matched = false;
		local s1 = string.lower("@"..v.Name)
		if s1:sub(1, #Name) == string.lower(Name) then
			if not matched then
				matches[#matches+1] = v
				matched = true;
			end
		end
		local s1 = string.lower(v.DisplayName)
		if s1:sub(1, #Name) == string.lower(Name) then
			if not matched then
				matches[#matches+1] = v
				matched = true;
			end
		end
		local s1 = string.lower(v.Name)
		if s1:sub(1, #Name) == string.lower(Name) then
			if not matched then
				matches[#matches+1] = v
				matched = true;
			end
		end
	end
	return matches
end

return function(env,player,commanddata,fullmsg,ignorechatperm)
	local playerdata = env.GetPlayerData(env,player);
	
	if not ignorechatperm and not env.Data.Settings.ChatCommands.Active then -- Chat has been used while it's disabled;
		return;
	end
	
	local logmsg = {};
	for k,v in pairs(fullmsg) do
		logmsg[k] = tostring(v);
	end
	local concat = table.concat(logmsg,"/")
	table.insert(env.Logs.Commands,1,{os.time(),player.UserId,"Panel",concat});
	
	local hasPerm = false
	local group = env.GetGroupInfo(env,playerdata)
	if not group then env.Notify(player,{"script_error","A group was not found for "..player.Name}) end;
	
	if group.UI then
		local args = fullmsg;
		local command = commanddata[1];
		if not commanddata[1].ForEveryone then
			if commanddata[1].SpecificPerm then
				if not env.GetPlayerHasPermission(env,playerdata,commanddata[1].SpecificPerm) then env.Notify(player,{"no_permission","Specific permission for this command is missing: "..commanddata[1].SpecificPerm}); return false end;
			else
				if not env.GetPlayerHasPermission(env,playerdata,commanddata[2].."."..commanddata[1].Name) then env.Notify(player,{"no_permission","Permission for this command is missing."}); return false end;
			end
		end
		
		local commanddata = commanddata[1]
		local fields = {}
		
		for k,v in pairs(commanddata.Fields) do
			if v.Required and not args[k] or v.Required and args[k] == "" or v.Required and args[k] == " " then 
				env.Notify(player,{"unsuccessful","A required argument is missing; "..v.Text.." of type "..v.Type});
				return false;
			elseif v.Default and not args[k] then 
				fields[v.Internal] = v.Default 
				env.Notify(player,{"hint","A default value has been applied; "..v.Text.." of type "..v.Type.."; "..tostring(v.Default)})
			end;
		end
		for k,v in pairs(args) do
			if commanddata.Fields[k] then
				local field = commanddata.Fields[k]
				if string.lower(field.Type) == "string" or string.lower(field.Type) == "dropdown" then
					fields[field.Internal] = v;
				elseif string.lower(field.Type) == "number" then
					if tonumber(v) then
						fields[field.Internal] = tonumber(v);
					else
						fields[field.Internal] = 0;
					end
				elseif string.lower(field.Type) == "time" then
					if tonumber(v) then
						local field_value = tonumber(v)
						fields[field.Internal] = field_value*60;
					else
						fields[field.Internal] = 0;
					end
				elseif string.lower(field.Type) == "boolean" then
					fields[field.Internal] = v;
				elseif string.lower(field.Type) == "color" then
					if typeof(v) == "BrickColor" then
						fields[field.Internal] = v.Color;
					else
						fields[field.Internal] = BrickColor.Random().Color;
					end
				elseif string.lower(field.Type) == "slider" then
					if tonumber(v) then
						fields[field.Internal] = tonumber(v);
					else
						fields[field.Internal] = 0;
					end
				elseif string.lower(field.Type) == "player" or string.lower(field.Type) == "players" then
					local plr = FindPlayers(player,v);
					if plr and plr[1] then
						fields[field.Internal] = plr[1]
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found with a matching name."}) ;return false end
						fields[field.Internal] = nil
					end
				elseif string.lower(field.Type) == "safeplayer" or string.lower(field.Type) == "safeplayers" then
					local plr = FindPlayers(player,v)[1] or nil;
					if plr then
						local othergroup = env.Ingame.Admins[plr.UserId].FlagGroup
						if tonumber(othergroup.Immunity) < tonumber(group.Immunity) then
							fields[field.Internal] = plr
						else
							if field.Required then env.Notify(player,{"no_permission","You cannot target "..plr.Name.." due to them having a higher immunity level than yours."});return false end
							env.Notify(player,{"hint","You cannot target "..plr.Name.." due to them having a higher immunity level than yours."})
							fields[field.Internal] = nil
						end
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found matching the name."});return false; end
						fields[field.Internal] = nil
					end
				elseif string.lower(field.Type) == "metaplayer" then
					local plr = FindPlayers(player,v);
					if plr and plr[1] then
						fields[field.Internal] = env.MetaPlayer(env,plr[1]);
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found with a matching name."}) ;return false end
						fields[field.Internal] = nil
					end
				elseif string.lower(field.Type) == "safemetaplayer" then
					local plr = FindPlayers(player,v)[1] or nil;
					if plr then
						local othergroup = env.Ingame.Admins[plr.UserId].FlagGroup
						if tonumber(othergroup.Immunity) < tonumber(group.Immunity) then
							fields[field.Internal] = env.MetaPlayer(env,plr);
						else
							if field.Required then env.Notify(player,{"no_permission","You cannot target "..plr.Name.." due to them having a higher immunity level than yours."});return false end
							env.Notify(player,{"hint","You cannot target "..plr.Name.." due to them having a higher immunity level than yours."})
							fields[field.Internal] = nil
						end
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found matching the name."});return false; end
						fields[field.Internal] = nil
					end
				end
			end
		end
		if env.CloudAPI.CheckAuth(player) then
			local success,result = pcall(function()
				local res,extra = commanddata.OnRun(player,fields,env)
				return {res,extra};
			end)
			if success then
				env.Bind:Fire("CommandFired",true,player,command,fields,result);
				return unpack(result);
			else
				warn("A script error has occured with a requested command: "..result);
				env.Bind:Fire("CommandError",true,player,command,fields,result);
				env.MetaPlayer(env,player):Notify({"script_error","An error has occured with the requested command: "..result});
				return false, "Script Error";
			end
		else
			return false, "Not Authenticated";
		end
	else
		return false, "You don't have UI permissions.";
	end
end