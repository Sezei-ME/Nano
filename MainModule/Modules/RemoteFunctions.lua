local env = nil;
local remote = script.AdminGUI_Remote;
local event = script.AdminGUI_Event;
local pingchecks = {};


remote.Parent = game:GetService("ReplicatedStorage");
event.Parent = game:GetService("ReplicatedStorage");

return function(api)
	if not env then env = api end;
	api.Remote = remote;
	api.Event = event;
	remote.OnServerInvoke = function(player,key,reason,anotherreason)
		api.Bind:Fire("FunctionFired",player,key,reason,anotherreason);
		
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
			local tck = task.wait();
			local tps = 1/tck;
			--[[
			if tonumber(reason) and tonumber(reason) >= 2500 then
				if api.MCheat then
					api.MCheat:AddScore(player,1,"Unstable connection to the Server (Ping is abnormally high; Last one: "..math.round(reason).."ms)");
				end
			elseif api.playerPings[player.UserId] and math.abs(api.playerPings[player.UserId] - reason) >= 750 then
				if api.MCheat then
					api.MCheat:AddScore(player,1,"Unstable connection to the Server (Ping difference is abnormally high; Last one: "..math.round(math.abs(api.playerPings[player.UserId] - reason)).."ms)");
				end
			end
			
			if api.MCheat and api.MCheat.Storage and api.MCheat.Storage[player.UserId] and api.MCheat.Storage[player.UserId][1] >= 10 and not api.MCheat.Storage[player.UserId].Notified then
				api.MCheat.Storage[player.UserId].Notified = true;
				api.MetaPlayer(api,player):Notify({"bulb","Your connection to the server is unstable. This might get you kicked!"})
			end]]
			
			if reason >= 2500 then
				api.Bind:Fire("AbnormalPing",player,math.round(reason));
			elseif api.playerPings[player.UserId] and math.abs(api.playerPings[player.UserId] - reason) >= 750 then
				api.Bind:Fire("UnstablePing",player,math.round(math.abs(api.playerPings[player.UserId] - reason)));
			end
			
			
			api.playerPings[player.UserId] = reason
			return tostring(api.BetterBasics.math.fround(tps,3)) .. " (" ..(game:GetService("RunService"):IsStudio() and "Studio)" or "Live)")
		elseif key == "GetSetting" then
			if reason == "CloudAPI" then return {UseBanlist = api.Data.BaseSettings.CloudAPI.UseBanlist; Token = {UseToken = api.Data.BaseSettings.CloudAPI.UseToken; Key = "REDACTED"}} end; -- Don't send REAL cloudAPI data for security reasons.
			return api.Data.Settings[reason];
		elseif key == "GetGameSettings" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
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
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
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
		elseif key == "GetChatlogs" then
			if api.GetPlayerHasPermission(api,player,"Nano.Logs.Chat") then
				return api.Logs.Chat
			else
				return false;
			end
		elseif key == "GetErrorlogs" then
			if api.GetPlayerHasPermission(api,player,"Nano.Logs.Errors") then
				return api.Logs.Errors
			else
				return false;
			end
		elseif key == "GetCmdlogs" then
			if api.GetPlayerHasPermission(api,player,"Nano.Logs.Commands") then
				return api.Logs.Commands
			else
				return false;
			end
		elseif key == "SetGameSetting" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
				local set = string.split(reason[1],".");
				api.Data.Settings[set[1]][set[2]] = reason[2];
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","You set \""..reason[1].."\" to "..tostring(reason[2])})
				return -- return after the save
			end
		elseif key == "GetAPIStatus" then
			return api.BetterBasics.bool.tobool(api.CloudAPI.Get('/redefinea'));
		elseif key == "SetPlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
				if api.Data.Settings.Players[reason[1]].UserId or api.Data.Settings.Players[reason[1]].Name then
					local plruserid = (api.Data.Settings.Players[reason[1]] and (api.Data.Settings.Players[reason[1]].UserId or api.Data.Settings.Players[reason[1]].Name and game:GetService("Players"):GetUserIdFromNameAsync(api.Data.Settings.Players[reason[1]].Name)))
					if not plruserid then plruserid = 0 end;
					
					if plruserid == player.UserId then
						api.MetaPlayer(api,player):Notify({"bulboff","You can't edit your own administration flags!"});
						return
					end
					
					if type(api.Data.Settings.Players[reason[1]].FlagGroup) == "table" then
						api.Data.Settings.Players[reason[1]].FlagGroup[reason[2]] = reason[3];
						if plruserid ~= 0 and env.Ingame.Admins[plruserid] then
							env.Ingame.Admins[plruserid].FlagGroup = api.Data.Settings.Players[reason[1]].FlagGroup
						end
						api.Store():Save("Nano_Settings",api.Data.Settings):wait();
						api.MetaPlayer(api,player):Notify({"bulb","You set key "..reason[1].." ("..plruserid..")'s \""..reason[2].."\" variable to "..tostring(reason[3])});
						return
					elseif type(api.Data.Settings.Players[reason[1]].FlagGroup) == "string" then
						api.Data.Settings.Players[reason[1]].FlagGroup = reason[2];
						if not api.Data.Settings.FlagGroups[reason[2]] then
							api.MetaPlayer(api,player):Notify({"bulboff","Something went wrong attempting to set key "..reason[1].." FlagGroup."});
						end
						if plruserid ~= 0 and env.Ingame.Admins[plruserid] then
							env.Ingame.Admins[plruserid].FlagGroup = api.Data.Settings.FlagGroups[reason[2]];
						end
						api.Store():Save("Nano_Settings",api.Data.Settings):wait();
						api.MetaPlayer(api,player):Notify({"bulb","You set key "..reason[1].." ("..plruserid..")'s group to "..reason[2]});
						return
					else
						api.MetaPlayer(api,player):Notify({"failed","An error has occured while attempting to set key "..reason[1]});
					end
				elseif api.Data.Settings.Players[reason[1]].Group then
					local groupdata = game:GetService("GroupService"):GetGroupInfoAsync(api.Data.Settings.Players[reason[1]].Group)
					
					--TODO--
				elseif api.Data.Settings.Players[reason[1]].Default then
					if type(api.Data.Settings.Players[reason[1]].FlagGroup) == "table" then
						api.Data.Settings.Players[reason[1]].FlagGroup[reason[2]] = reason[3];
						api.Store():Save("Nano_Settings",api.Data.Settings):wait();
						api.MetaPlayer(api,player):Notify({"bulb","You set key "..reason[1].." (Default Key) \""..reason[2].."\" variable to "..tostring(reason[3])});
						return
					elseif type(api.Data.Settings.Players[reason[1]].FlagGroup) == "string" then
						api.Data.Settings.Players[reason[1]].FlagGroup = reason[2];
						if not api.Data.Settings.FlagGroups[reason[2]] then
							api.MetaPlayer(api,player):Notify({"bulboff","Something went wrong attempting to set key "..reason[1].." FlagGroup."});
						end
						api.Store():Save("Nano_Settings",api.Data.Settings):wait();
						api.MetaPlayer(api,player):Notify({"bulb","You set key "..reason[1].." (Default Key) group to "..reason[2]});
						return
					else
						api.MetaPlayer(api,player):Notify({"failed","An error has occured while attempting to set key "..reason[1]});
					end
				else
					api.MetaPlayer(api,player):Notify({"failed","An error has occurred attempting to get key "..reason[1].." flag type"});
				end
			end
		elseif key == "NewPlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
				for akey, ranked in pairs(api.Data.Settings.Players) do
					-- actual fix (it was literally just missing the parentheses)
					if (ranked and (ranked.UserId or ranked.Name and game:GetService("Players"):GetUserIdFromNameAsync(ranked.Name))) == (tonumber(reason) or game:GetService("Players"):GetUserIdFromNameAsync(reason)) then
						api.MetaPlayer(api,player):Notify({"bulboff","New key creation for "..reason.." was prevented: User already exists."});
						return
					end
				end
				
				local plruserid = tonumber(reason) or game:GetService("Players"):GetUserIdFromNameAsync(reason)
				if not plruserid then api.MetaPlayer(api,player):Notify({"bulboff","New key creation for "..reason.." has failed: Couldn't find user."}); return false end;
				
				if anotherreason == "Custom" then
					table.insert(api.Data.Settings.Players,{UserId = plruserid; FlagGroup = {Key = "Newbie"; Immunity = 1; Flags = "Moderation.Respawn"; UI = true; Chat = true}});
					api.Store():Save("Nano_Settings",api.Data.Settings):wait();
					api.MetaPlayer(api,player):Notify({"bulb","You created a new key for "..plruserid..". Refresh the settings to edit the new team member."});
					if game:GetService("Players"):GetPlayerByUserId(plruserid) then
						api.MetaPlayer(api,game:GetService("Players"):GetPlayerByUserId(plruserid)):Notify({"celebrate","Welcome to the team! You were assigned an administration key which will take effect on rejoin."});
						env.Ingame.Admins[plruserid] = {Key = "Newbie"; Immunity = 1; Flags = "Moderation.Respawn"; UI = true; Chat = true}
					end
					return -- return after the save for quicker thing
				else
					if api.Data.Settings.FlagGroups[anotherreason] then
						table.insert(api.Data.Settings.Players,{UserId = plruserid; FlagGroup = anotherreason});
						api.Store():Save("Nano_Settings",api.Data.Settings):wait();
						api.MetaPlayer(api,player):Notify({"bulb","You added "..plruserid.." to group \""..anotherreason.."\"."});
						if game:GetService("Players"):GetPlayerByUserId(plruserid) then
							api.MetaPlayer(api,game:GetService("Players"):GetPlayerByUserId(plruserid)):Notify({"celebrate","Welcome to the team! You were assigned into group \""..anotherreason.."\" which will take effect on rejoin."});
							env.Ingame.Admins[plruserid].FlagGroup = api.Data.Settings.FlagGroups[anotherreason];
						end
						return -- return after the save for quicker thing
					else
						api.MetaPlayer(api,player):Notify({"bulboff","New key creation for "..reason.." has failed: No such group exists."});
					end
				end
			end
		elseif key == "DeletePlayerData" then
			if api.GetPlayerHasPermission(api,player,"Nano.GameSettings") and not (game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0) then
				table.remove(api.Data.Settings.Players,reason);
				api.Store():Save("Nano_Settings",api.Data.Settings):wait();
				api.MetaPlayer(api,player):Notify({"bulb","Key "..reason.." has been removed from the system's storage. Refresh the settings to see the change."});
				return -- return after the save for quicker thing
			end
		elseif key == "IsAuthed" then
			return api.CloudAPI.CheckAuth(player);
		elseif key == "SendCommand" then
			--[[
			local command = string.split(reason," ")[1]
			if api.Data.Commands[command] then
				-- UI, Player, Command, Args
				local dat = api.UICommand(api,player,api.Data.Commands[command],reason,true);
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
			]]
			local command = reason[1];
			if api.Data.Commands[command] then
				-- UI, Player, Command, Args
				local dat = api.UICommand(api,player,api.Data.Commands[command],reason[2],true);
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
		elseif key == "ReturnJoinHandle" then
			
			return api.GetPlayerHasPermission(api,api.Ingame.Admins[player.UserId],"UI"), api.Build(), {api.Strings["Intro_Top"],api.Strings["Intro_Middle"]}, api.Store():Load("favs_"..player.UserId):wait().Data or {}, api.CloudAPI.CheckAuth(player), api.Data.Settings["AccentColor"];
		elseif api.RemoteKeys and api.RemoteKeys[key] then
			pcall(function()
				api.RemoteKeys[key](player,reason)
			end)
		else
			api.MCheat:AddScore(player,5,"Attempt to call Nano event with an unknown identifier");
		end
	end
end