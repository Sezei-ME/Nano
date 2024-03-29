local ds = nil;

local TextService = game:GetService("TextService")
local env = {
	InternalBuild = "BETA_3";
	TrueBuild = 68; -- QA_BUILD[n]
	Data = {};
	RemoteKeys = {};
	Ingame = {Admins = {}; Bans = {}; };
	Client = {Modules = {}; Assets = {}}; -- Modules are being sent to all clients in order to create custom functions.
	Strings = {
		Ban_Server_Permanent = "You are server-banned for \"<banreason>\". This ban is active until the server will shutdown.";
		Ban_Server_Temporary = "You are server-banned for \"<banreason>\". Estimated time left: <timeleft> minutes.";
		Ban_Game_Permanent = "You are game-banned for \"<banreason>\". This ban is permanent.";
		Ban_Game_Temporary = "You are game-banned for \"<banreason>\". Estimated time left: <timeleft> minutes.";
		Intro_Top = "Nano";
		Intro_Middle = "Created by Sezei.Me and Axelius";
	};
	GlobalBanlist = {};
	MainModule = script.Parent;
	Bind = script.Parent._Event;
	-- Replaced the Errors = {} with this;
	Logs = {
		Errors = {}; 	-- Template: {time, error}
		Chat = {};		-- Template: {time, playerid, message}
		Commands = {};	-- Template: {time, playerid, source, command}
	}
}

-- Legacy functions: Use env.MetaPlayer(env, plr)
function env.Notify(player,data) env.Event:FireClient(player,"Notify",data) end
function env.Message(player,data) env.Event:FireClient(player,"Message",data) end
function env.Hint(player,data) env.Event:FireClient(player,"Hint",data) end

-- Standard functions
function env.Intro(player) env.Event:FireClient(player, "Intro") end
function env.HintAll(data) env.Event:FireAllClients("Hint",data) end
function env.MessageAll(data) env.Event:FireAllClients("Message",data) end
function env.NotifyAll(data) env.Event:FireAllClients("Notify",data) end
function env.Build() return env.InternalBuild end
function env.Store()
	ds = ds or env.Datastore(env.Data.Settings.Datastore,env,true) --|| Checks if 'ds' already exists so it can return it before (re-)opening a new datastore table.
	return ds
end

function env.TextFilter(txt,sender)
	if type(env.Data.Settings.Filter) == "table" and not env.Data.Settings.Filter.Enabled then return txt end; -- Filtering is disabled in the settings!
	local tx:TextFilterResult = TextService:FilterStringAsync(txt,sender.UserId,Enum.TextFilterContext.PrivateChat);
	return tx:GetChatForUserAsync(sender.UserId);
end

-- Deprecated; Using the BetterBasics.string.placeholders function now.
function env.BuildBanReason(player,bantype,banreason,timeleft)
	if bantype == "server" then
		if timeleft == math.huge then
			return env.Strings.Ban_Server_Permanent:gsub("{arg:banreason}",tostring(banreason));
		else
			local a = env.Strings.Ban_Server_Temporary:gsub("{arg:banreason}",tostring(banreason));
			return a:gsub("{arg:timeleft}",tostring(timeleft));
		end
	elseif bantype == "game" then
		if timeleft == math.huge then
			return env.Strings.Ban_Game_Permanent:gsub("{arg:banreason}",tostring(banreason));
		else
			local a = env.Strings.Ban_Game_Temporary:gsub("{arg:banreason}",tostring(banreason));
			return a:gsub("{arg:timeleft}",tostring(timeleft));
		end
	end
end

function env.Client:AddAsset(asset)
	local success, folder = pcall(function()
		return env.MainModule:FindFirstChild("NanoUI"):FindFirstChild("MainHandler"):FindFirstChild("Assets")
	end);
	
	if success then
		asset:Clone().Parent = folder;
	end
end

return env