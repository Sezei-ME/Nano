-- QA_Build 45; Increased leniency at the cost of more time to deduct the detection score. (Leniency is now 15 (was 10), Interval is now 240 (was 120))
-- QA_Build 54; Opened MiniCheat API so external scripts can access it.

local env = nil;
local RunService = game:GetService("RunService")
local module = {Storage = {}; ScoreDeducing = true; lastDeduction = tick(); deductionInterval = 240}

local function CheckKick(plr : Player)
	if module.Storage[plr.UserId][1] >= env.Data.Settings.MiniCheat.Leniency then
		env.Bind:Fire("MCheatEvent",plr.UserId,module.Storage[plr.UserId][2])
		plr:Kick("MiniCheat\n\nYou have been kicked for a suspected cheat.\n\nLast Detection:\n"..module.Storage[plr.UserId][2])
	end
end

function module:AddScore(user : Player, score : number, reason : string) -- Add scoring to the user
	if not env.Data.Settings.MiniCheat then
		env.Data.Settings.MiniCheat = {
			Enabled = true;
			Leniency = 15;
		}
	end
	if not module.Storage[user.UserId] then 
		module.Storage[user.UserId] = {score, reason} 
	else
		module.Storage[user.UserId][1] += score
		module.Storage[user.UserId][2] = reason
	end
	if env.Data.Settings.MiniCheat.Enabled then
		CheckKick(user)
	end
	return
end

local Event:BindableEvent = Instance.new("BindableEvent");
Event.Parent = game:GetService("ServerStorage");

Event.Event:Connect(function(user : Player , score : number , reason: string)
	if not env.Data.Settings.MiniCheat then
		env.Data.Settings.MiniCheat = {
			Enabled = true;
			Leniency = 15;
		}
	end
	if not module.Storage[user.UserId] then 
		module.Storage[user.UserId] = {score, reason} 
	else
		module.Storage[user.UserId][1] += score
		module.Storage[user.UserId][2] = reason.." (External Scoring)"
	end
	if env.Data.Settings.MiniCheat.Enabled then
		CheckKick(user)
	end
	return
end)

--[[
task.spawn(function() -- To reduce false positive kicks, create a loop that lowers one's score every 2 minutes. Ineffective, but helpful. Can be toggled.
	while task.wait(120) do
		if module.ScoreDeducing then
			for k,v in pairs(module.Storage) do
				module.Storage[k][1] = math.max(0,module.Storage[k][1]-1);
			end
		end
	end
end)
--]]

RunService.Heartbeat:Connect(function()
	if module.ScoreDeducing and tick() - module.lastDeduction >= module.deductionInterval then
		for key, value in pairs(module.Storage) do
			local newValue = math.max(0, module.Storage[key][1] - 1)
			module.Storage[key][1] = newValue
		end

		module.lastDeduction = tick()
	end
end)

function module._NanoWrapper(api)
	env = api;
	return module; -- we still have to return it or it'll keep erroring with no reason
end

return module
