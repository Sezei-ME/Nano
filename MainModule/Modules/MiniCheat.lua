-- QA_Build 45; Increased leniency at the cost of more time to deduct the detection score. (Leniency is now 15 (was 10), Interval is now 240 (was 120))
local RunService = game:GetService("RunService")
local module = {Storage = {}; ScoreDeducing = true; lastDeduction = tick(); deductionInterval = 240}

local function CheckKick(plr : Player)
	if module.Storage[plr.UserId][1] >= 15 then
		plr:Kick("MiniCheat\n\nYou have been kicked for a suspected cheat.\n\nLast Detection:\n"..module.Storage[plr.UserId][2])
	end
end

function module:AddScore(user : Player, score : number, reason : string) -- Add scoring to the user
	if not module.Storage[user.UserId] then 
		module.Storage[user.UserId] = {score, reason} 
	else
		module.Storage[user.UserId][1] += score
		module.Storage[user.UserId][2] = reason
	end
	CheckKick(user)
	return
end

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

return module
