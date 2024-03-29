local firstCall = true;
local betabuild = false;
local loaded = false;
local env = require(script.BaseEnvironment);
local Decoder = require(script.ErrorCodes);

-- nightly stuff
local loadtime = os.clock();
local loads = 2; -- 2 initial loads (decoder and baseenv)
-- end

local Roblox = {
	warn = warn;
}

if script:FindFirstChild("WARNING - THIS IS A BETA BUILD!") then
	betabuild = true;
	env.NightlyBuild = true;
	env.InternalBuild = "NIGHTLY "..env.TrueBuild;

	local nightlyval = Instance.new("BoolValue",script.NanoUI);
	nightlyval.Name = "NightlyBuild";
	nightlyval.Value = true;
	nightlyval.Parent = script.NanoUI;

	script:FindFirstChild("WARNING - THIS IS A BETA BUILD!"):Remove()
end

function env.warn(code, ...)
	if betabuild then
		if tonumber(code) then
			Roblox.warn("Nano Nightly | Error "..code.." - "..Decoder:ResolveCode(code).." | ",...)
		else
			Roblox.warn("Nano Nightly | ",...)
		end
		return
	end
	if tonumber(code) then
		Roblox.warn("Nano | Error "..code.." - "..Decoder:ResolveCode(code).." | ",...)
	else
		Roblox.warn("Nano | ",...)
	end
end

local function format(originscript,replacementdata)
	local s:string = tostring(originscript);

	for old,new in pairs(replacementdata) do
		s = s:gsub("<"..old..">",tostring(new));
	end

	return s;
end

for _,v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		if betabuild then loads+=1 end
		local success,mod = pcall(function() return require(v) end)
		if success then
			if type(mod) == "table" and mod["_NanoWrapper"] then
				env[v.Name] = mod._NanoWrapper(env);
			else
				env[v.Name] = mod;
			end
		else
			warn('Nano | Failed to compile module: '..v.Name..' with error "'..mod..'"');
			table.insert(env.Logs.Errors,{os.time(),"Module Compilation Failed: "..v.Name..' with error "'..mod..'"'});
		end
	end
end

local mtTemplate = {__tostring = function(tbl)
	return tbl.Name;
end}

env.playerPings = {}

env.RemoteFunctions(env);

function buildRankTable(p,info,...)
	env.Ingame.Admins[p.UserId] = {};
	if type(info["FlagGroup"]) == 'table' then
		env.Ingame.Admins[p.UserId] = info
		env.Ingame.Admins[p.UserId].Player = p
		return
	elseif type(info["FlagGroup"]) == 'string' then
		if env.Data.Settings.FlagGroups[info.FlagGroup] then
			env.Ingame.Admins[p.UserId].FlagGroup = env.Data.Settings.FlagGroups[info["FlagGroup"]]
			env.Ingame.Admins[p.UserId].FlagGroup.Key = info["FlagGroup"] -- Should be the name
			env.Ingame.Admins[p.UserId].Player = p
			return
		end
	end

	env.warn(format("Invalid Data while building RankTable!\np var <p>\ninfo var <info>",{["p"] = p; ["info"] = info}))
end

function buildGroupTable(p,info,...)
	env.Ingame.Admins[p.UserId] = {};
	if type(info) == 'table' then
		env.Ingame.Admins[p.UserId].FlagGroup = info
		env.Ingame.Admins[p.UserId].Player = p
	elseif type(info) == 'string' then
		env.Ingame.Admins[p.UserId].FlagGroup = env.Data.Settings.FlagGroups[info]
		env.Ingame.Admins[p.UserId].FlagGroup.Key = info
		env.Ingame.Admins[p.UserId].Player = p
	end
end

function toCommands(folder,stack)
	if not folder then return nil end; -- Return nothing if there is no folder.
	if not stack then stack = "" end -- If there isn't a stack, force a string anyways.
	for _,v in pairs(folder:GetChildren()) do
		if v:IsA('ModuleScript') then
			local s,f = pcall(function()
				loads+=1
				local mv = require(v) -- mv: module table
				if mv.OnLoad then -- if OnLoad exists in the table, load it now
					local suc,res = pcall(function() mv.OnLoad(env) end);
					if not suc then
						env.warn(3, "An OnLoad function has failed; Source: ".. v.Parent.Name .. "." .. v.Name.." ; "..res);
						table.insert(env.Logs.Errors,{os.time(),"An OnLoad function has failed; Source: ".. v.Parent.Name .. "." .. v.Name.." ; "..res});
					end
					mv.OnLoad = nil;
				end
				
				if env.Data.Commands[string.lower(mv.Name)] then
					warn("A command has been overwritten by a different one due to the same name >> "..env.Data.Commands[string.lower(mv.Name)][2].."."..env.Data.Commands[string.lower(mv.Name)][1].Name.." has been rewritten by "..stack.."."..mv.Name)
				end
				-- Set the command in place: [name] = {module,stack}
				env.Data.Commands[string.lower(mv.Name)] = {mv,stack}
			end)
			if not s then
				env.warn(3, "A command was failed to compile; "..f)
				table.insert(env.Logs.Errors,{os.time(),"A command was failed to compile "..f});
			end
		elseif v:IsA('Folder') then
			toCommands(v,((stack~="" and stack.."." or "") .. v.Name))
		end
	end
	return true
end

local handlequeue = {};
function handleJoin(p)
	local success, err = pcall(function()
		local p:Player = p;
		local agr = script.NanoUI:Clone();
		script.ErrorCodes:Clone().Parent = agr;
		task.spawn(function() -- Check bans in the background while the rest is being handled.
			if env.Ingame.Bans[p.UserId] then
				local baninfo = env.Ingame.Bans[p.UserId];
				local origintime = baninfo[1];
				local bantime = baninfo[2];
				local banreason = baninfo[3];
				local moderator = baninfo[4];

				if bantime == math.huge then
					env.Bind:Fire("JoinWhileBanned",p.UserId,banreason);

					p:Kick("You are server-banned for \""..banreason.."\". This ban is active until the server will shutdown.");
					return;
				end

				if os.time() <= origintime + bantime then
					env.Bind:Fire("JoinWhileBanned",p.UserId,banreason);

					p:Kick("You are server-banned for \""..banreason.."\". Estimated time left: ".. tostring( math.abs( os.time() - (origintime + bantime) ) / 60 ) .." minutes." );
					return;
				end
			end

			local baninfo = env.Store():Load("ban_"..tostring(p.UserId)):wait().Data;
			if baninfo then
				local origintime = baninfo[1];
				local bantime = baninfo[2];
				local banreason = baninfo[3];
				local moderator = baninfo[4];

				if bantime == math.huge then
					env.Bind:Fire("JoinWhileBanned",p.UserId,banreason);

					p:Kick("You are game-banned for \""..banreason.."\". This ban is permanent.");
					return;
				end

				if os.time() <= math.abs(origintime + bantime) then
					env.Bind:Fire("JoinWhileBanned",p.UserId,banreason);

					p:Kick("You are game-banned for \""..banreason.."\". Estimated time left: ".. tostring( math.abs( os.time() - (origintime + bantime) ) / 60 ) .." minutes." );
					return;
				end
			end

			if env.Data.Settings.CloudAPI.UseBanlist then
				local bandata = env.GlobalBanlist;

				if bandata then
					if bandata[p.UserId] then
						local pinfo = bandata[p.UserId];
						if pinfo.active and pinfo.active == true then
							env.Bind:Fire("JoinWhileBanned",p.UserId,"Cloudban: "..pinfo.reason);
							p:Kick("\nSezei.me API\n----------------\n\nYou are cloud banned from all games with Sezei.me products.\n\nReason:\n"..pinfo.reason)
						else
							-- The player was banned before, but the ban is no longer active. We will keep track on them using task.spawn.
							task.spawn(function()
								repeat 
									task.wait(60)
									pinfo = bandata[p.UserId];
								until pinfo.active or not p;
								if pinfo.active and p then
									p:Kick("\nSezei.me API\n----------------\n\nYou are cloud banned from all games with Sezei.me products.\n\nReason:\n"..pinfo.reason)
								end
							end)
						end
					else
						-- Player isn't banned, but it's better to still keep track on them using task.spawn in-case that changes.
						task.spawn(function()
							local pinfo = bandata[p.UserId];
							repeat 
								task.wait(120) -- Because they have no history of being banned, we can increase the check time from 60 seconds to 120 seconds because usually it means they have no reason to be checked again.
								pinfo = bandata[p.UserId];
							until (pinfo and pinfo.active) or not p;
							if pinfo.active and p then
								p:Kick("\nSezei.me API\n----------------\n\nYou are cloud banned from all games with Sezei.me products.\n\nReason:\n"..pinfo.reason)
							end
						end)
					end
				else
					env.warn(4, "Couldn't verify whether "..p.Name.." is Cloud-Banned or not due to not being able to fetch the banlist.");
				end
			end

			if env.Data.Gamelocked then
				if env.Data.Gamelocked[1] == true then
					env.Bind:Fire("JoinWhileBanned",p.UserId,"Server is locked");
					p:Kick(env.Data.Gamelocked[2]);
				end
			end
		end)

		if game.CreatorType == Enum.CreatorType.User then
			if p.UserId == game.CreatorId then
				env.Ingame.Admins[p.UserId] = {FlagGroup = {Key = "Game Owner"; Immunity = 255; Flags = "*"; UI = true; Chat = true}};
			end
		elseif game.CreatorType == Enum.CreatorType.Group then
			if p:GetRankInGroup(game.CreatorId) == 255 then
				env.Ingame.Admins[p.UserId] = {FlagGroup = {Key = "Game Owner"; Immunity = 255; Flags = "*"; UI = true; Chat = true}};
			end
		end

		-- Version BETA_PRE3#6 (58); Added VIP Owner and Default FlagGroups.
		-- Normal -> Groups -> VIPOwner -> Gamepasses -> Default -> Non-Admin

		local groups = {};
		local gamepasses = {};
		local vipowner = nil;
		local default = nil;

		if not env.Ingame.Admins[p.UserId] then
			for key,v in pairs(env.Data.Settings.Players) do
				if v["UserId"] then
					if v["UserId"] == p.UserId then
						buildRankTable(p,v,key);
						break;
					end
				elseif v["Name"] then
					if v["Name"] == p.Name then
						buildRankTable(p,v,key);
						break;
					end
				elseif v["Gamepass"] then
					table.insert(gamepasses,v);
				--[[
				if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(p.UserId,v["Gamepass"]) then
					buildRankTable(p,v,key);
					break;
				end]]
				elseif v["Group"] then
					table.insert(groups,v);

				elseif v["VIPOwner"] then
					vipowner = v;

				elseif v["Default"] then
					default = v;
				--[[
				local rank = p:GetRankInGroup(tonumber(v["Group"]));
				if not v["Rank"] then
					warn(2,"Malformed Settings: 'Group' flags require a rank table.")
				elseif type(v["Rank"]) ~= "table" then
					warn(2,"Nano | Malformed Settings: 'Rank' flag must be a table type.")
				else
					for rnk,vv in pairs(v["Rank"]) do
						if rank == tonumber(rnk) then
							buildGroupTable(p,vv,rnk);
							break;
						end
					end
				end]]
				end
			end;
		end

		-- Check groups.
		if not env.Ingame.Admins[p.UserId] then
			for key,v in pairs(groups) do
				local rank = p:GetRankInGroup(tonumber(v["Group"]));
				if not v["Rank"] then
					env.warn(2,"Malformed Settings: 'Group' flags require a rank table.")
					table.insert(env.Logs.Errors,{os.time(),"Malformed Settings: 'Group' flags require a rank table."});
				elseif type(v["Rank"]) ~= "table" then
					env.warn(2,"Nano | Malformed Settings: 'Rank' flag must be a table type.")
					table.insert(env.Logs.Errors,{os.time(),"Malformed Settings: 'Rank' flag must be a table type."});
				else
					if v["Rank"] then
						for rnk,vv in pairs(v["Rank"]) do
							if rank == tonumber(rnk) then
								buildGroupTable(p,vv,rnk);
								break;
							end
						end
					elseif v["Ranks"] then
						for rnk,vv in pairs(v["Ranks"]) do 
							if rank == tonumber(rnk) then
								buildGroupTable(p,vv,rnk);
								break;
							end
						end
					end
				end
			end
		end

		-- VIP Ownership.
		if game.PrivateServerId ~= "" and game.PrivateServerOwnerId ~= 0 then -- Check VIP Server status
			if p.UserId == game.PrivateServerOwnerId and not env.Ingame.Admins[p.UserId] then
				env.Ingame.Admins[p.UserId] = vipowner;
			end
		end

		-- Check gamepasses.
		if not env.Ingame.Admins[p.UserId] then
			for key,v in pairs(gamepasses) do
				if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(p.UserId,v["Gamepass"]) then
					buildRankTable(p,v,key);
					break;
				end
			end
		end

		-- There might be a default key?
		if default and not env.Ingame.Admins[p.UserId] then
			env.Ingame.Admins[p.UserId] = default;
		end

		-- Give up and give the Non-Admin key.
		if not env.Ingame.Admins[p.UserId] then
			env.Ingame.Admins[p.UserId] = {FlagGroup = {Key = "Non-Admin"; Immunity = 0; Flags = ""; UI = false; Chat = false}};
		end

		if not env.Ingame.Admins[p.UserId].FlagGroup.UI then
			agr.Main.Visible = false;
			agr.MouseFollow.Visible = false;
		end

		local function handleMsg(msg)
			if string.sub(msg,1,#env.Data.Settings.ChatCommands.Prefix) == env.Data.Settings.ChatCommands.Prefix then
				local command = string.split(msg," ")[1]
				command = string.lower(string.sub(command,#env.Data.Settings.ChatCommands.Prefix+1))
				if env.Data.Commands[command] then
					local s,f = pcall(function()
						env.ChatCommand(env,p,env.Ingame.Admins[p.UserId],env.Data.Commands[command],msg);
					end)
					if not s then
						env.Notify(p,{"bug","An error has occured with the command: "..f})
					end
				else
					table.insert(env.Logs.Chat,1,{os.time(),p.UserId,env.TextFilter(msg,p)});
				end
			else
				table.insert(env.Logs.Chat,1,{os.time(),p.UserId,env.TextFilter(msg,p)});
			end
		end

		agr.Parent = p.PlayerGui;
		agr.MainHandler.Disabled = false;

		p.Chatted:Connect(function(msg)
			handleMsg(msg);
		end)

		env.Bind:Fire("SuccessfulJoin",p.UserId);

		if env.Data.Settings.Intro.Enabled then
			if env.Data.Settings.Intro.AdminOnly then
				if env.Ingame.Admins[p.UserId].FlagGroup.Flags ~= "" then
					env.Intro(p)
				end
			else
				env.Intro(p)
			end
		end
	end)

	-- An error has occured.
	if not success then
		if err == "Player not in datamodel" and not p.Parent then
			warn("Failed to handle player "..p.Name.." due to them not being detected within the server; Not attempting a retry due to the error.");
			table.insert(env.Logs.Errors,{os.time(),"Failed to handle player "..p.Name});
		else
			warn("Failed to handle player "..p.Name.." with error \""..err.."\"; Retrying in 2 seconds");
			table.insert(env.Logs.Errors,{os.time(),"Failed to handle player "..p.Name});
			task.wait(2);
			return handleJoin(p);
		end
	end

	-- No error has occured but they still have no admin role..?!?
	if not env.Ingame.Admins[p.UserId] then
		warn("Failed to handle player "..p.Name.." without an error (User has no admin role); Retrying in 2 seconds");
		table.insert(env.Logs.Errors,{os.time(),"Failed to handle player "..p.Name});
		task.wait(2);
		return handleJoin(p);
	end

	return true;
end

task.spawn(function()
	-- Initial check of the banlist.
	local suc,dat = pcall(env.CloudAPI.Get,"/redefinea/banlist");
	if suc and dat and dat.success then
		env.GlobalBanlist = dat;
	else
		warn("Failed to update the global banlist! Is HTTPService enabled?");
	end

	local ticks = 4000; -- 60 seconds because task.wait() is ~0.015 seconds; 60/0.015 = 4000.
	while task.wait() do
		if loaded then
			-- Check for new players.
			if handlequeue[1] then
				local success = handleJoin(game:GetService("Players"):GetPlayerByUserId(handlequeue[1]));
				if success then
					table.remove(handlequeue,1);
				end
			end
		end
		
		ticks -= 1;

		if ticks <= 0 then
			-- Check the banlist again to see if any bans have updated.
			ticks = 4000; -- Return the ticks counter to 60 before updating the banlist again.
			local suc,dat = pcall(env.CloudAPI.Get,"/redefinea/banlist");
			if suc and dat and dat.success then
				env.GlobalBanlist = dat;
			else
				warn("Failed to update the global banlist!");
			end
		end
	end
end)

if firstCall then
	firstCall = false
	return function(loader:Script)
		loader.Parent = game:GetService("ServerScriptService")
		env.Loader = loader


		if loader:FindFirstChild('Settings') then
			loads+=1
			local sets = require(loader:FindFirstChild('Settings'))
			env.Data.Settings = sets;
		else
			env.warn(1,"The settings module is missing.");
			table.insert(env.Logs.Errors,{os.time(),"The settings module is missing."});
			return
		end

		env.Data.BaseSettings = {}
		for k,v in pairs(env.Data.Settings) do
			env.Data.BaseSettings[k] = v;
		end

		local savedsettings = env.Store():Load("Nano_Settings"):wait().Data or {}

		-- Settings that should be easily changable in the settings file;
		if not savedsettings.AccentColor then savedsettings.AccentColor = {Color = env.Data.BaseSettings.AccentColor.Color; Forced = env.Data.BaseSettings.AccentColor.Forced;} end;
		savedsettings.CloudAPI = env.Data.BaseSettings.CloudAPI
		savedsettings.AccentColor.Color = env.Data.BaseSettings.AccentColor.Color
		savedsettings.FlagGroups = env.Data.BaseSettings.FlagGroups
		--savedsettings.Players = env.Data.BaseSettings.Players -- disabled because players category working :troll:
		-- end of those settings

		if savedsettings then
			for k,v in pairs(savedsettings) do
				env.Data.Settings[k] = v;
			end
		end

		local settingsvalid = env.SettingsValidator(env.Data.Settings)

		if not settingsvalid and not savedsettings then
			env.warn(2,"Due to a settings error, your support attempt will be voided.\nPlease fix the above issues before contacting support if any issues indeed occur.")
		elseif savedsettings and not settingsvalid then
			env.warn(2,"Nano | Your datastore key's settings are corrupted.\nPlease attempt to switch the datastore key before contacting support.")
		end

		if loader:FindFirstChild("Functions") then
			for _,v in pairs(loader:FindFirstChild("Functions"):GetChildren()) do
				if v:IsA("ModuleScript") then
					local s,f = pcall(function()
						loads+=1
						local r = require(v) -- returned data
						if r["_nano"] then
							if not (type(r["_nano"]["addtoEnv"]) == "boolean") or not r._nano.addtoEnv then
								if r["_nano"]["name"] then
									env[r["_nano"]["name"]] = r
								else
									env[v.Name] = r
								end
							end
							if r["_nano"]["load"] then
								local f = r["_nano"].load(env);
								if r["_nano"]["loadcomplete"] then
									r["_nano"].loadcomplete(f);
								end
							end
						else
							env[v.Name] = r
						end
					end)

					if not s then
						warn('Nano | Failed to compile module: '..f);
						table.insert(env.Logs.Errors,{os.time(),"Module compilation failed: "..f});
					end
				end
			end
		end

		script.NanoUI.Main.Size = UDim2.fromOffset((tonumber(env.Data.Settings.UI.Size.Width) or 258),(tonumber(env.Data.Settings.UI.Size.Height) or 245))
		script.NanoUI.Main.Position = UDim2.new(0, -(env.Data.Settings.UI.Size.Width), 1, -10)

		env.Data.Commands = {}
		local s = toCommands(loader:FindFirstChild("Commands"));
		if not s then
			env.warn("No commands were loaded. Attempting to fetch basic commands.")
			table.insert(env.Logs.Errors,{os.time(),"No commands were loaded."});
			env.Data.Commands = env.BaseCommands;
		end

		-- Joins
		game:GetService("Players").PlayerAdded:Connect(function(p)
			table.insert(handlequeue,p.UserId);
		end);
		for _,p in pairs(game:GetService("Players"):GetPlayers()) do
			table.insert(handlequeue,p.UserId);
			--handleJoin(p);
		end
		game:GetService("Players").PlayerRemoving:Connect(function(p)
			env.Ingame.Admins[p.UserId] = nil;
		end)
		if betabuild then print("Nano Nightly | Loaded successfully in "..math.round(math.abs(loadtime-os.clock())*1000).."ms "..(game:GetService("RunService"):IsStudio() and "(In Studio)" or "(In a Live Server)") .. " with "..loads.." loads of modules.") end;
		env.Bind:Fire("NanoLoaded");
		loaded = true;
	end
else
	env.Bind:Fire("LoadAttempt"); -- they tried :shrug:
	return -- Return nothing, but don't init the admin again either.
		function(loader:Script|ModuleScript)
			if typeof(loader) == "Instance" then
			print("Nano | Attempt to load Nano after it loaded caught. Source: "..loader.Name);
		end
		end

	-- If you want to return the environment, or literally anything else, you will need to fork the module; I do not allow this with a "vanilla"
	-- module, since it could result in bad actors getting into the environment without your knowledge.
	-- Do so at your own risk only; and remember; forking the main module rather than using functions will void any attempt to support you.
end
