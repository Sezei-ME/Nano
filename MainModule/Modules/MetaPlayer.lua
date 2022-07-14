local ids = {}
local plrs = {}

local senv; -- Stored Environment

local function CreateMeta(env:any, plr:Player?)
	-- if it's suddenly just a player rather than the full env (requires the env to be sent in the first place)
	if not senv and typeof(env) == "Instance" then return nil end;
	if senv and typeof(env) == "Instance" then plr = env end;
	senv = env;
	if not plr then return {} end;
	if plrs[plr.UserId] then return plrs[plr.UserId] end;

	local player = {};
	player.LocalId = #ids+1;
	ids[#ids+1] = plr.UserId;

	player.self = plr;
	player.Data = {};
	player.Name = plr.Name;
	player.DisplayName = plr.DisplayName;
	player.UserId = plr.UserId;
	player.AccountAge = plr.AccountAge;
	player.InGame = true;
	player.Muted = false;
	player.MuteLength = 0;

	senv.Bind:Fire("MetaPlayerCreated",plr.UserId);

	function player:HasPermission(permissionneeded)
		return senv.GetPlayerHasPermission(senv,senv.GetPlayerData(senv,player.self),permissionneeded)
	end

	function player:GetFlagGroup()
		return senv.Ingame.Admins[player.UserId].FlagGroup
	end

	function player:Kick(...)
		if not player.InGame then return end;
		player.self:Kick(...);
	end

	function player:Kill() -- Meta alias for Character.Humanoid.Health = -100;
		if not player.self then return end;
		player.self.Character.Humanoid.Health = -100;
	end

	function player:Respawn() -- Meta alias for LoadCharacter
		if not player.InGame then return end;
		player.self:LoadCharacter();
	end

	function player:Refresh()
		if not player.InGame then return end;
		local pos = player.self.Character.HumanoidRootPart.CFrame;
		player.self:LoadCharacter();
		player.self.Character:WaitForChild("HumanoidRootPart").CFrame = pos;
	end

	function player:GetData()
		return senv.GetPlayerData(player.UserId);
	end

	function player:Message(data)
		if not player.InGame then return end;
		senv.Event:FireClient(player.self,"Message",data);
	end

	function player:Hint(data)
		if not player.InGame then return end;
		senv.Event:FireClient(player.self,"Hint",data);
	end

	function player:Notify(data)
		if not player.InGame then return end;
		senv.Event:FireClient(player.self,"Notify",data);
	end
	
	function player:Highlight(instance)
		if not player.InGame then return end;
		senv.Event:FireClient(player.self,"Highlight",instance); -- Requires to be a path that is in the client too tho!
	end

	function player.Data:Set(key,value)
		senv.Store():Save(player.UserId.."_"..key,value):wait();
	end

	function player.Data:Get(key)
		return senv.Store():Load(player.UserId.."_"..key):wait().Data;
	end

	function player.Data:Delete(key)
		senv.Store():Nullify(player.UserId.."_"..key):wait();
	end

	function player:Mute(reason,length)
		if not reason then reason = "[Unstated]" end;
		if not length then length = 1800 end; -- 30 minutes mute by default
		player.Muted = true;
		player.MuteLength = length;
		player:Notify({"bulb","You have been muted for " .. tostring(math.floor(length/60)) .. " minutes! Reason: " ..reason });
		senv.Event:FireClient(player.self,"Mute");
	end

	function player:Unmute(reason)
		if not reason then reason = "[Unstated]" end;
		player.Muted = false;
		player.MuteLength = 0;
		player:Notify({"bulb","You have been unmuted. Reason: " ..reason });
		senv.Event:FireClient(player.self,"Unmute");
	end

	table.insert(plrs,player);

	setmetatable(player,{__call = function()
		return player.self
	end})

	return player;
end

game:GetService("Players").PlayerRemoving:Connect(function(plr)
	if plrs[plr.UserId] then
		plrs[plr.UserId].InGame = false;
		plrs[plr.UserId].self = nil; -- Player disconnected! No point in holding a useless 'notnil' object.
	end
end)

game:GetService("Players").PlayerAdded:Connect(function(plr)
	if plrs[plr.UserId] then
		plrs[plr.UserId].InGame = true;
		plrs[plr.UserId].self = plr; -- Player reconnected! Undo the nil

		if plrs[plr.UserId].Muted then
			plrs[plr.UserId]:Mute("Previously disconnected while muted.",plrs[plr.UserId].MuteLength+120); -- Add 2 minutes of punishment for leaving while muted.
		end
	end

	plr.Chatted:Connect(function()
		if plrs[plr.UserId] and plrs[plr.UserId].Muted then -- Chatting while muted? NUH UH!
			if senv then
				senv.MCheat:AddScore(plr, 5, "Chatting while muted")
			end
		end
	end)
end)

task.spawn(function()
	while task.wait(1) do
		for _,plr in pairs(plrs) do
			if plr.InGame and plr.Muted then
				if plr.MuteLength >= 1 then
					plr.MuteLength -= 1;
				else
					plr:Unmute("Mute expired.")
				end
			end
		end
	end	
end)

return CreateMeta