local env = nil;
local remote = script.AdminGUI_Remote;
local event = script.AdminGUI_Event;
local pingchecks = {};


remote.Parent = game:GetService("ReplicatedStorage");
event.Parent = game:GetService("ReplicatedStorage");

task.spawn(function()
	while task.wait(10) do
		if env then
			for k,v in pairs(pingchecks) do
				local p = game:GetService("Players"):GetPlayerByUserId(k)
				if p then
					if v+30 < os.time() then
						env.MCheat:AddScore(p,5,"Unstable connection to the Server (Non-cooperative Client)");
						pingchecks[k] = os.time();
					end
				end
			end
		end
	end
end)

return function(api)
	if not env then env = api end;
	api.Remote = remote;
	api.Event = event;
	remote.OnServerInvoke = function(player,key,reason)
		api.Bind:Fire("FunctionFired",player,key,reason);
		
		if key == "CanUseUI" then
			return api.GetPlayerHasPermission(api,api.Ingame.Admins[player.UserId],"UI"), api.Build();
		elseif key == "GetSeparator" then
			return api.Data.Settings.ChatCommands.Prefix,api.Data.Settings.ChatCommands.Sep
		elseif key == "GetAvailableCommands" then
			local commands = {};
			for ck,cmd in pairs(api.Data.Commands) do
				if api.GetPlayerHasPermission(api,api.Ingame.Admins[player.UserId],cmd[2].."."..cmd[1].Name) then
					commands[ck] = cmd
				end
			end
			return commands;
		elseif key == "GetString" then
			return api.Strings[reason];
		elseif key == "GetStrings" then
			local tbl = {}
			for _,strkey in pairs(reason) do
				tbl[strkey] = api.Strings[strkey];
			end
			return tbl
		elseif key == "HasPermission" then
			return api.GetPlayerHasPermission(api,player,reason)
		elseif key == "getFavs" then
			return api.Store():Load("favs_"..player.UserId):wait().Data or {};
		elseif key == "updateFavs" then
			task.spawn(function()
				local dat = api.Store():Load("favs_"..player.UserId):wait().Data;
				if not dat then
					dat = {}
				end
				if dat[reason] then
					dat[reason] = nil
				else
					dat[reason] = true
				end
				api.Store():Save("favs_"..player.UserId,dat)
			end)
		elseif key == "GetPlayerData" then
			return api.GetPlayerData(api,reason);
		elseif key == "GetPlayerDataFromId" then
			if game:GetService("Players"):GetPlayerByUserId(reason) then
				return api.GetPlayerData(api,game:GetService("Players"):GetPlayerByUserId(reason));
			end
			return nil
		elseif key == "PingTest" then
			return true;
		elseif key == "PingRes" then
			pingchecks[player.UserId] = os.time();
			if tonumber(reason) and tonumber(reason) >= (math.clamp(1000*(wait()/0.035),1000,1750)) then
				if api.MCheat then
					api.MCheat:AddScore(player,1,"Unstable connection to the Server (Ping is consistantly high)");
				end
			elseif api.playerPings[player.UserId] and math.abs(api.playerPings[player.UserId] - reason) >= (math.clamp(350*(wait()/0.035),350,700)) then
				if api.MCheat then
					api.MCheat:AddScore(player,1,"Unstable connection to the Server (Ping delta is very high)");
				end
			end
			
			if api.MCheat and api.MCheat.Storage and api.MCheat.Storage[player.UserId] and api.MCheat.Storage[player.UserId][1] >= 10 and not api.MCheat.Storage[player.UserId].Notified then
				api.MCheat.Storage[player.UserId].Notified = true;
				api.MetaPlayer(api,player):Notify({"bulb","Your connection to the server is unstable. This might get you kicked!"})
			end
			
			api.playerPings[player.UserId] = reason
			return true
		elseif key == "GetSetting" then
			return api.Data.Settings[reason];
		elseif key == "GetGameSettings" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				local send = {}
				for k,v in pairs(api.Data.Settings) do
					if api.Data.BaseSettings[k] then
						send[k] = v;
					end
				end

				-- Protected Settings
				send["Players"] = nil;
				send["FlagGroups"] = nil;
				send["Datastore"] = nil;
				send["CloudAPI"] = nil;

				-- Return the edited Settings table
				return send;
			end
		elseif key == "GetModSettings" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				local sending = {}
				local amnt = 0;
				for k,v in pairs(api.Data.Settings) do
					if not api.Data.BaseSettings[k] then
						sending[k] = v;
						amnt+=1;
					end
				end
				return sending,amnt
			else
				return {};
			end
		elseif key == "SetGameSetting" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				local set = string.split(reason[1],".");
				api.Data.Settings[set[1]][set[2]] = reason[2];
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","You set \""..reason[1].."\" to "..tostring(reason[2])})
				return -- return after the save
			end
		elseif key == "SetPlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				local plruserid = (api.Data.Settings.Players[reason[1]] and (api.Data.Settings.Players[reason[1]].UserId or api.Data.Settings.Players[reason[1]].Name and game:GetService("Players"):GetUserIdFromNameAsync(api.Data.Settings.Players[reason[1]].Name)))
				if not plruserid then plruserid = 0 end;
				api.Data.Settings.Players[reason[1]].FlagGroup[reason[2]] = reason[3];
				if plruserid ~= 0 and env.Ingame.Admins[plruserid] then
					env.Ingame.Admins[plruserid].FlagGroup = api.Data.Settings.Players[reason[1]].FlagGroup
				end
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","You set key "..reason[1].." ("..plruserid..")'s \""..reason[2].."\" variable to "..reason[3]});
				return -- return after the save for quicker thing
			end
		elseif key == "NewPlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				local plruserid = tonumber(reason) or game:GetService("Players"):GetUserIdFromNameAsync(reason)
				if not plruserid then api.MetaPlayer(api,player):Notify({"bulboff","New key creation for "..plruserid.." has failed."}); return false end;
				table.insert(api.Data.Settings.Players,{UserId = plruserid; FlagGroup = {Key = "Newbie"; Immunity = 1; Flags = "Moderation.Respawn"; UI = true; Chat = true}});
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","You created a new key for "..plruserid..". Refresh the settings to edit the new team member."});
				return -- return after the save for quicker thing
			end
		elseif key == "DeletePlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") then
				table.remove(api.Data.Settings.Players,reason);
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","Key "..reason.." has been removed from the system's storage. Refresh the settings to see the change."});
				return -- return after the save for quicker thing
			end
		elseif key == "IsAuthed" then
			return api.CloudAPI.CheckAuth(player);
		elseif key == "SendCommand" then
			local command = string.split(reason," ")[1]
			if api.Data.Commands[command] then
				-- UI, Player, Command, Args
				local dat = api.ChatCommand(api,player,api.Ingame.Admins[player.UserId],api.Data.Commands[command],reason,true);
				if dat then
					return dat;
				elseif type(dat) == "nil" then
					return;
				else -- if there's a returning and it's NOT nil then there would be an issue:
					return false;
				end
			else
				return false;
			end
		elseif key == "CommandOpened" then
			if api.Data.Commands[string.lower(reason)] then
				if api.Data.Commands[string.lower(reason)][1]["OnOpen"] then
					return api.Data.Commands[string.lower(reason)][1].OnOpen(player, api)
				end
			end
		elseif key == "SendPrivateMessage" then
			return event:FireClient(game:GetService("Players"):GetPlayerByUserId(reason[1]),"PrivateMessage",{player.UserId,reason[2]})
		elseif key == "CommandChangedValue" then
			-- {command, field, value}
			local cmd = reason[1]
			local field = reason[2]
			local newval = reason[3]

			if api.Data.Commands[string.lower(cmd)] then
				cmd = api.Data.Commands[string.lower(cmd)][1]
				if cmd.Fields[field] then
					if cmd.Fields[field]["Changed"] then
						return cmd.Fields[field].Changed(player, api, newval)
					end
				end
			end
		elseif key == "GetCSetting" then
			local d = api.Store():Load("setting_"..player.UserId.."_"..reason):wait().Data
			if type(d) == "string" then
				if string.sub(d,1,9) == "USERDATA_" then
					return game:GetService("HttpService"):JSONDecode(string.sub(d,10))[1];
				elseif string.sub(d,1,8) == "BOOLEAN_" then
					if string.lower(string.sub(d,9)) == "true" then
						return true
					else
						return false
					end
				end
			end
			return d
		elseif key == "SetCSetting" then
			local ev:BindableEvent = api.Bind;
			if type(reason[2]) == "table" then
				reason[2][2] = tostring(reason[2][2])
				reason[2] = "USERDATA_"..game:GetService("HttpService"):JSONEncode({reason[2]})
			elseif type(reason[2]) == "boolean" then
				reason[2] = "BOOLEAN_"..tostring(reason[2])
			end
			api.Store():Save("setting_"..player.UserId.."_"..reason[1],reason[2]):wait();
			ev:Fire("SettingChanged",player,reason[1],reason[2])
		elseif api.RemoteKeys and api.RemoteKeys[key] then
			pcall(function()
				api.RemoteKeys[key](player,reason)
			end)
		else
			api.MCheat:AddScore(player,5,"Attempt to call Nano event with an unknown identifier");
		end
	end
end