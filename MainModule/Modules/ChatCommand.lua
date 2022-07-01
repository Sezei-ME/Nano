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
		
		if not matched then
			if string.lower(Name) == "me" then
				matches[#matches+1] = Runner
				matched = true;
			elseif string.lower(Name) == "all" then
				matches[#matches+1] = v
				matched = true;
			elseif string.lower(Name) == "others" then
				if v.Name ~= Runner.Name then
					matches[#matches+1] = v
					matched = true;
				end
			end
		end
	end
	return matches
end

return function(env,player,playerdata,commanddata,fullmsg,ignorechatperm)
	if not ignorechatperm and not env.Data.Settings.ChatCommands.Active then -- Chat has been used while it's disabled;
		return;
	end
	local hasPerm = false
	local group = env.GetGroupInfo(env,playerdata)
	if not group then env.Notify(player,{"script_error","A group was not found for "..player.Name}) end;
	
	if group.Chat or ignorechatperm then
		if not ignorechatperm and commanddata[1].ChatDisabled then return env.Notify(player,{"bulb","This command is disabled for chat invokes."}) end
		local fmsg = string.split(fullmsg," ");
		table.remove(fmsg,1);
		fullmsg = table.concat(fmsg," ");
		
		local args = string.split(fullmsg,env.Data.Settings.ChatCommands.Sep);
		local command = commanddata[1];
		if commanddata[1].SpecificPerm then
			if not env.GetPlayerHasPermission(env,playerdata,commanddata[1].SpecificPerm) then env.Notify(player,{"no_permission","Specific permission for this command is missing: "..commanddata[1].SpecificPerm}); return false end;
		else
			if not env.GetPlayerHasPermission(env,playerdata,commanddata[2]) then env.Notify(player,{"no_permission","Permission for this command is missing."}); return false end;
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
					if string.lower(v) == "true" or string.lower(v) == "yes" or string.lower(v) == "1" then
						fields[field.Internal] = true;
					elseif string.lower(v) == "false" or string.lower(v) == "no" or string.lower(v) == "0" then
						fields[field.Internal] = false;
					end
				elseif string.lower(field.Type) == "color" then
					if Color3.fromRGB(v) then
						fields[field.Internal] = BrickColor.new(v).Color;
					else
						fields[field.Internal] = BrickColor.Random().Color;
					end
				elseif string.lower(field.Type) == "slider" then
					if tonumber(v) then
						fields[field.Internal] = tonumber(v);
					else
						fields[field.Internal] = 0;
					end
				elseif string.lower(field.Type) == "player" then
					local plr = FindPlayers(player,v);
					if plr and plr[1] then
						fields[field.Internal] = plr[1]
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found with a matching name."}) ;return false end
						fields[field.Internal] = nil
					end
				elseif string.lower(field.Type) == "players" then
					fields[field.Internal] = FindPlayers(player,v) or {};
				elseif string.lower(field.Type) == "safeplayer" then
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
				elseif string.lower(field.Type) == "safeplayers" then
					local plrs = FindPlayers(player,v) or nil;
					if plrs[1] then
						for num,plr in pairs(plrs) do
							local othergroup = env.Ingame.Admins[plr.UserId]
							if not (tonumber(othergroup.Immunity) < tonumber(group.Immunity)) then
								table.remove(plrs,num)
							end
						end
						fields[field.Internal] = plrs
					else
						if field.Required then env.Notify(player,{"unsuccessful","No player has been found matching the name."}); return false; end
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
				return commanddata.OnRun(player,fields,env);
			end)
			if success then
				env.Bind:Fire("CommandFired",true,player,command,fields,result);
				return result
			else
				warn("A script error has occured with a requested command: "..result);
				env.Bind:Fire("CommandError",true,player,command,fields,result);
				env.MetaPlayer(env,player):Notify({"script_error","An error has occured with the requested command: "..result});
				return "Script Error";
			end
		else
			return "Not Authenticated";
		end
	else
		return false;
	end
end