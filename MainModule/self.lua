local firstCall = true
local env = require(script.BaseEnvironment);
local Decoder = require(script.ErrorCodes);

local Roblox = {
	warn = warn;
}

local function warn(code, ...)
	if tonumber(code) then
		Roblox.warn("Nano | Error "..code.." - "..Decoder:ResolveCode(code).." | ",...)
	else
		Roblox.warn("Nano | ",...)
	end
end

for _,v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		mod = require(v)
		if type(mod) == "table" and mod["_NanoWrapper"] then
			env[v.Name] = mod._NanoWrapper(env);
		else
			env[v.Name] = mod;
		end
	end
end

local mtTemplate = {__tostring = function(tbl)
	return tbl.Name;
end}

env.playerPings = {}

env.RemoteFunctions(env);

function buildRankTable(p,info,key)
	env.Ingame.Admins[p.UserId] = info;
	if type(info["FlagGroup"]) == 'table' then
		env.Ingame.Admins[p.UserId].FlagGroup.Key = key
		env.Ingame.Admins[p.UserId].Player = p
	elseif type(info["FlagGroup"]) == 'string' then
		env.Ingame.Admins[p.UserId].FlagGroup = env.Data.Settings.FlagGroups[info["FlagGroup"]]
		env.Ingame.Admins[p.UserId].FlagGroup.Key = info["FlagGroup"]
		env.Ingame.Admins[p.UserId].Player = p
	end
end

function buildGroupTable(p,info,key)
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
				local mv = require(v) -- mv: module table
				if mv.OnLoad then -- if OnLoad exists in the table, load it now
					local suc,res = pcall(function() mv.OnLoad(env) end);
					if not suc then
						warn(3, "An OnLoad function has failed; Source: ".. v.Parent.Name .. "." .. v.Name.." ; "..res);
					end
					mv.OnLoad = nil;
				end
				-- Set the command in place: [name] = {module,stack}
				env.Data.Commands[string.lower(mv.Name)] = {mv,stack}
			end)
			if not s then
				warn(3, "A command has failed to get compiled; "..f)
			end
		elseif v:IsA('Folder') then
			toCommands(v,((stack~="" and stack.."." or "") .. v.Name))
		end
	end
	return true
end

function handleJoin(p)
	local p:Player = p;
	task.spawn(function() -- Check bans in the background while the rest is being handled.
		if env.Ingame.Bans[p.UserId] then
			local baninfo = env.Ingame.Bans[p.UserId];
			local origintime = baninfo[1];
			local bantime = baninfo[2];
			local banreason = baninfo[3];
			local moderator = baninfo[4];

			if bantime == math.huge then
				p:Kick("You are server-banned for \""..banreason.."\". This ban is active until the server will shutdown.");
				return;
			end

			if os.time() <= origintime + bantime then
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
				p:Kick("You are game-banned for \""..banreason.."\". This ban is permanent.");
				return;
			end

			if os.time() <= math.abs(origintime + bantime) then
				p:Kick("You are game-banned for \""..banreason.."\". Estimated time left: ".. tostring( math.abs( os.time() - (origintime + bantime) ) / 60 ) .." minutes." );
				return;
			end
		end

		if env.Data.Settings.CloudAPI.UseBanlist then
			local suc,dat = pcall(env.CloudAPI.Get,"/redefinea/banlist/"..p.UserId);
			if suc then
				if dat then
					if dat.success then
						if dat.active and dat.active == true then
							p:Kick("\nSezei.me API\n----------------\n\nYou are cloud banned from all games with Sezei.me products.\n\nReason:\n"..dat.reason)
						else
							task.spawn(function()
								local suc,ndat = pcall(env.CloudAPI.ListenForChange,"/redefinea/banlist/"..p.UserId,dat);
								if suc then
									repeat task.wait(5) until ndat.Data or not p;
									ndat:Cancel();
									ndat = ndat.Data;
									if ndat and ndat.success and ndat.active and ndat.active == true then
										p:Kick("\nSezei.me API\n----------------\n\nYou are cloud banned from all games with Sezei.me products.\n\nReason:\n"..ndat.reason)
										return
									end
								end
							end)
						end
					end
				end
			else
				warn(4, "Couldn't verify whether "..p.Name.." is Cloud-Banned or not due to an error: "..dat)
			end
		end

		if env.Data.Gamelocked then
			if env.Data.Gamelocked[1] == true then
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
				if game:GetService("MarketplaceService"):UserOwnsGamePassAsync(p.UserId,v["Gamepass"]) then
					buildRankTable(p,v,key);
					break;
				end
			elseif v["Group"] then
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
				end
			end
		end;
	end

	if not env.Ingame.Admins[p.UserId] then
		env.Ingame.Admins[p.UserId] = {FlagGroup = {Key = "Non-Admin"; Immunity = 0; Flags = ""; UI = false; Chat = false}};
	end

	local agr = script.NanoUI:Clone();
	script.ErrorCodes:Clone().Parent = agr;
	agr.Parent = p.PlayerGui;
	agr.MainHandler.Disabled = false;

	if env.Data.Settings.Intro.Enabled then
		if env.Data.Settings.Intro.AdminOnly then
			if env.Ingame.Admins[p.UserId].FlagGroup.Immunity > 0 then
				env.Intro(p)
			end
		else
			env.Intro(p)
		end
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
			end
		end
	end
	p.Chatted:Connect(function(msg)
		handleMsg(msg);
	end)
end

if firstCall then
	firstCall = false
	return function(loader)
		env.Loader = loader
		if loader:FindFirstChild('Settings') then
			local sets = require(loader:FindFirstChild('Settings'))
			env.Data.Settings = sets;
		else
			warn(1,"The settings module is missing.");
			return
		end

		env.Data.BaseSettings = {}
		for k,v in pairs(env.Data.Settings) do
			env.Data.BaseSettings[k] = v;
		end
		
		local savedsettings = env.Store():Load("Nano_Settings"):wait().Data or {}
		
		-- Settings that should be easily changable in the settings file;
		savedsettings.AccentColor.Color = env.Data.BaseSettings.AccentColor.Color
		savedsettings.FlagGroups = env.Data.BaseSettings.FlagGroups
		-- end of those settings
		
		if savedsettings then
			for k,v in pairs(savedsettings) do
				env.Data.Settings[k] = v;
			end
		end
		
		local settingsvalid = env.SettingsValidator(env.Data.Settings)
		
		if not settingsvalid and not savedsettings then
			warn(2,"Due to a settings error, your support attempt will be voided.\nPlease fix the above issues before contacting support if any issues indeed occur.")
		elseif savedsettings and not settingsvalid then
			warn(2,"Nano | Your datastore key's settings are corrupted.\nPlease attempt to switch the datastore key before contacting support.")
		end

		if loader:FindFirstChild("Functions") then
			for _,v in pairs(loader:FindFirstChild("Functions"):GetChildren()) do
				if v:IsA("ModuleScript") then
					pcall(function()
						local r = require(v) -- returned data
						if r["_nano"] then
							if not type(r["_nano"]["addtoEnv"]) == "boolean" or not r._nano.addtoEnv then
								if r["_nano"]["name"] then
									env[r["_nano"]["name"]] = r
								else
									env[v.Name] = r
								end
							end
							if r["_nano"]["load"] then
								local f = r["_nano"].load(env)
								if r["_nano"]["loadcomplete"] then
									r["_nano"].loadcomplete(f);
								end
							end
						else
							env[v.Name] = r
						end
					end)
				end
			end
		end

		env.Data.Commands = {}
		local s = toCommands(loader:FindFirstChild("Commands"));
		if not s then
			warn("No commands were loaded. Attempting to fetch basic commands.")
			env.Data.Commands = env.BaseCommands;
		end

		-- Joins
		game:GetService("Players").PlayerAdded:Connect(handleJoin);
		for _,p in pairs(game:GetService("Players"):GetPlayers()) do
			handleJoin(p);
		end
		game:GetService("Players").PlayerRemoving:Connect(function(p)
			env.Ingame.Admins[p.UserId] = nil;
		end)
	end
else
	return -- Return nothing, but don't init the admin again either.

		-- If you want to return the environment, or literally anything else, you will need to fork the module; I do not allow this with a "vanilla"
		-- module, since it could result in bad actors getting into the environment without your knowledge.
		-- Do so at your own risk only; and remember; forking the main module rather than using functions will void any attempt to support you.
end

