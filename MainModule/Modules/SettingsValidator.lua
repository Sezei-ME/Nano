local HttpService = game:GetService("HttpService")
local function HttpGet(url)
	return pcall(function()
		return HttpService:GetAsync(url)
	end)
end

return function(settings)
	local deprecation = false;
	local info = {};
	
	if type(settings.UI) == "table" then
		-- It's a new loader!
		if type(settings.UI.Size) == "table" then
			if not type(settings.UI.Size.Width) == "number" then
				settings.UI.Size.Width = 258;
				table.insert(info,"UI Width was missing");
			end
			if not type(settings.UI.Size.Height) == "number" then
				settings.UI.Size.Height = 245;
				table.insert(info,"UI Height was missing");
			end
			if settings.UI.Size.Width < 230 then
				settings.UI.Size.Width = 230;
				table.insert(info,"UI Width was below 230");
			end
			if settings.UI.Size.Height < 245 then
				settings.UI.Size.Height = 250;
				table.insert(info,"UI Height was below 245");
			end
		else
			settings.UI = {
				Size = {
					Width = 258;
					Height = 245;
				};
			}
			table.insert(info,"UI setting was not a valid table");
		end
	else
		settings.UI = {
			Size = {
				Width = 258;
				Height = 245;
			};
		}
	end
	
	if type(settings.CloudAPI) == "table" and type(settings.CloudAPI.UseGlobalBanlist) == "boolean" then
		-- Not a deprecation, it's a mistake from my side, therefore this will not be removed, nor changed. - Binary
		settings.CloudAPI.UseBanlist = settings.CloudAPI.UseGlobalBanlist;
	end
	
	if type(settings.UseGlobalBanlist) == "boolean" then
		deprecation = true;
		table.insert(info,"UseGlobalBanlist - Replaced by CloudAPI.UseBanlist");
		settings.CloudAPI = {
			UseBanlist = settings.UseGlobalBanlist;
			Token = (settings.CloudAPI.Token or {
				UseToken = false;
				Key = "";
			});
		}
	end
	
	if type(settings.CloudAPI) == "table" and type(settings.CloudAPI.Token) == "table" then
		if settings.CloudAPI.Token.UseToken and settings.CloudAPI.Token.Key ~= "" then
			local success, response = HttpGet("http://api.sezei.me/tokenapi/"..settings.CloudAPI.Token.Key.."?gameId="..tostring(game.PlaceId).."&branch=nano")
			if success then
				local res = HttpService:JSONDecode(response);
				if not res.success then
					warn("Invalid token - "..res.message);
				end
			else
				warn("Token validation failed.")
			end
		end
	end
	
	if type(settings.Filter) == "nil" then
		deprecation = true;
		table.insert(info,"'Filter' table is missing; Setting to default");
		settings.Filter = {
			Enabled = true;
		};
		
	end
	
	if type(settings.AccentColor) == "nil" then
		deprecation = true;
		table.insert(info,"'AccentColor' table is missing; Setting to default");
		settings.AccentColor = {
			Color = Color3.new(0, 0.666667, 1);
			Forced = false;
		};
	end
	
	if type(settings.AccentColor.Color) == "nil" then
		-- Fix silently, for some reason it happens a lot and it's like.. roblox fault or smthn idek at this point.
		settings.AccentColor.Color = Color3.new(0,0.666667,1);
	end
	
	if type(settings.AccentColor.Forced) == "nil" then
		-- Same as above
		settings.AccentColor.Forced = false;
	end
	
	if type(settings.ChatCommands) ~= "table" then
		deprecation = true;
		table.insert(info,"'ChatCommands' table is missing; Settings to default");
		settings.ChatCommands = {
			Active = true;
			Prefix = ":";
			Sep = "/";
		};
	end
	
	if deprecation then
		warn("------------\nNano | Deprecation warning: You are still using an older version of the settings. The following needs to be changed;")
		for _,v in pairs(info) do
			warn(v);
		end
		warn("This does NOT require any immediate action as of now, since the SettingsValidator module fixes the table automatically, but a notification over it is necessary in-case the fix is not automatically applied.\nIf any issues occur, please simply replace the old settings module with a newer one, or report the issue to the Sezei.me team.\n------------")
	elseif info[1] then
		warn("Some errors have been found when the settings were validated; however, these might not be your fault. Please report the following message to the developers of Nano.\n\n");
		for _,v in pairs(info) do
			warn(v);
		end
	end
	
	info = nil; -- Clear from memory.
	
	local erroring = false;
	local errors = {};
	
	for k,v in pairs(settings.FlagGroups) do
		-- ["Name"] = {Immunity = Num; Flags = FlagList};
		if not v.Immunity then
			erroring = true;
			table.insert(errors,"FlagGroup \""..k.."\": Missing Immunity.");
		end
		
		if not v.Flags then
			erroring = true;
			table.insert(errors,"FlagGroup \""..k.."\": Missing Flags.");
		end
	end
	
	for k,v in pairs(settings.Players) do
		if not v.UserId and not v.Name and not v.Group and not v.Gamepass and not v.VIPOwner and not v.Default then
			erroring = true;
			table.insert(errors,"Player key \""..k.."\": Missing check type.");
		end
		
		if not v.Group then
			if not v.FlagGroup then
				erroring = true;
				table.insert(errors,"Player key \""..k.."\": Missing FlagGroup variable.");
			elseif type(v.FlagGroup) == "string" then
				if not settings.FlagGroups[v.FlagGroup] then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": No such FlagGroup exists: \""..v.FlagGroup.."\"");
				end
			elseif type(v.FlagGroup) == "table" then
				if not v.FlagGroup.Key then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": Custom FlagGroup error: Key variable not provided.");
				end
				
				if not v.FlagGroup.Immunity then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": Custom FlagGroup error: Immunity variable not provided.");
				end
				
				if not v.FlagGroup.Flags then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": Custom FlagGroup error: Flags not provided.");
				end
			end
		else
			if tonumber(v.Group) then
				if v.Ranks and not v.Rank then
					v.Rank = {};
					for k,v in pairs(v.Ranks) do
						v.Rank[k] = v;
					end	
					
					v.Ranks = nil; -- Clear unneeded data to save space in the table.
				end;
				
				if not v.Rank then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": Group Ranking table was not provided.");
				elseif type(v.Rank) ~= "table" then
					erroring = true;
					table.insert(errors,"Player key \""..k.."\": Group Ranking table is malformed; expected table, got "..(v.Rank and typeof(v.Rank))..".");
				else
					if v.Rank then
						for rank,flag in pairs(v.Rank) do
							if not tonumber(rank) then
								erroring = true;
								table.insert(errors,"Player key \""..k.."\": Malformed rank: Expected a number.");
							elseif tonumber(rank) >= 256 or tonumber(rank) <= -1 then
								erroring = true;
								table.insert(errors,"Player key \""..k.."\": Malformed rank: Rank must be between 0 and 255.");
							elseif type(flag) == "string" then
								if not settings.FlagGroups[flag] then
									erroring = true;
									table.insert(errors,"Group key \""..rank.."\": No such FlagGroup exists: \""..flag.."\"");
								end
							elseif type(flag) == "table" then
								if not flag.Key then
									erroring = true;
									table.insert(errors,"Group key \""..rank.."\": Custom FlagGroup error: Key variable not provided.");
								end

								if not flag.Immunity then
									erroring = true;
									table.insert(errors,"Group key \""..rank.."\": Custom FlagGroup error: Immunity variable not provided.");
								end

								if not flag.Flags then
									erroring = true;
									table.insert(errors,"Group key \""..rank.."\": Custom FlagGroup error: Flags not provided.");
								end
							end
						end
					end
				end
			else
				erroring = true;
				table.insert(errors,"Player key \""..k.."\": Group ID was wrongly provided.");
			end
		end
	end
	
	if erroring then
		warn("------------\nNano | Setting Errors: You have a corrupted settings module. The following needs to be changed or else the system will not work as expected;")
		for _,v in pairs(errors) do
			warn(v);
		end
		warn("This requires immediate action; Please change the above in order to avoid future errors in the system.\n------------");
		return false;
	end
	
	return true;
end