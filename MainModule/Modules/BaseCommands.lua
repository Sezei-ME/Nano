return {
	["shutdown"] = {
		{
			InGui = true;
			Name = "Shutdown";
			Credit = {1892103295};
			Description = {
				Short = "Shutdown Server."; -- Description that is shown when you hover over the command in the UI.
				Long = "Shutdown the current server."; -- Description that is shown when you click on the command in the UI.
			};
			Color = Color3.new(1, 1, 1);
			Fields = {
				[1] = {
					Default = "No reason provided.";
					Internal = "reason";
					Text = "Reason";
					Type = "String";
				};
			};
			OnRun = function(sender,fields,api)
				for index, player in pairs(game.Players:GetPlayers()) do
					player:Kick("\n\nModeration Message\n\nType: Shutdown\n\nMessage: \""..fields.reason.."\"\n\nBy: "..sender.Name.."\n\n")
				end
			end;
		}
		, "Emergency"
	};
	["kick"] = {
		{
			InGui = true;
			Name = "Kick";
			Credit = {253925749};
			Description = {
				Short = "Kick a player."; -- Description that is shown when you hover over the command in the UI.
				Long = "Kick the target player from the game."; -- Description that is shown when you click on the command in the UI.
			};
			Color = Color3.new(1, 0.466667, 0);
			Fields = {
				[1] = {
					Required = true;
					Internal = "target";
					Text = "Target";
					Type = "Player";
				};
				[2] = {
					Default = "No reason provided.";
					Required = true;
					Internal = "reason";
					Text = "Reason";
					Type = "String";
				};
			};
			OnRun = function(player,fields,api)
				if fields.target then
					local target_player: any = fields.target

					target_player:Kick("\n\nModeration Message\n\nType: Kick\n\nMessage: \""..fields.reason.."\"\n\nBy: "..player.Name.."\n\n")
					return true;
				else
					return false;
				end
			end;
		}
		, "Emergency"
	};
	["ban"] = {
		{
			InGui = true; -- Whether or not this is a GUI command. Regardless of true or false, the command is still available to be used as a chat command if active.
			Name = "Ban";
			Credit = {253925749,1892103295};
			Description = {
				Short = "Bans a player."; -- Description that is shown when you hover over the command in the UI.
				Long = "Ban a player for a timed period for any reason."; -- Description that is shown when you click on the command in the UI.
			};
			Color = Color3.new(1, 0.054902, 0.054902);
			Fields = {
				[1] = {
					Required = true;
					Internal = "target";
					Text = "Player";
					Type = "SafePlayer"; -- Make sure the immunity is at least equal before going along with it.
				};
				[2] = {
					Default = "Reason was not provided.";
					Internal = "reason";
					Text = "Ban Reason";
					Type = "String";
				};
				[3] = {
					Default = 1440;
					Internal = "time";
					Text = "Ban Length";
					Type = "Time";
				};
				[4] = {
					Default = false;
					Internal = "server_only";
					Text = "This Server Only";
					Type = "Boolean";
				};
				[5] = {
					Default = false;
					Internal = "perm";
					Text = "Permanent Ban";
					Type = "Boolean";
				}
			};
			OnRun = function(player,fields,api)
				if fields.target then
					if fields.perm then
						fields.time = math.huge;
					end
					fields.target:Kick("\n\nModeration Message\n\nType: Ban\n\nMessage: \""..fields.reason.."\"\n\nBy: "..player.Name.."\n\n")
					api.Notify(player,{"success","You successfully banned "..fields.target.Name.." for "..tostring(fields.time).." minutes."});
					if fields.server_only then
						api.Ingame.Bans[fields.target.UserId] = {os.time(),(fields.time),fields.reason,player.UserId};
					else
						api.Store():Save("ban_"..tostring(fields.target.UserId),{os.time(),(fields.time),fields.reason,player.UserId});
					end
					return true;
				else
					return false;
				end
			end;
		}
		, "Emergency"
	};
	["unban"] = {
		{
			InGui = true; -- Whether or not this is a GUI command. Regardless of true or false, the command is still available to be used as a chat command if active.
			Name = "Unban";
			Credit = {253925749};
			Description = {
				Short = "Unbans a player."; -- Description that is shown when you hover over the command in the UI.
				Long = "Unban the stated player."; -- Description that is shown when you click on the command in the UI.
			};
			Color = Color3.new(0.168627, 1, 0.168627);
			Fields = {
				[1] = {
					Required = true;
					Internal = "userid";
					Text = "Player UserId";
					Type = "number";
				};
			};
			OnRun = function(player,fields,api)
				api.Ingame.Bans[fields.userid] = nil;
				api.Store():Nullify("ban_"..tostring(fields.userid));

				task.spawn(function()
					local data = game:GetService("Players"):GetNameFromUserIdAsync(fields.userid);
					api.Notify(player,{"success","You successfully unbanned "..data.."."});
					return true;
				end)
			end;	
		}
		, "Emergency"
	};
}