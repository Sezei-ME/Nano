local module = {Storage = {}; ScoreDeducing = true;}

function CheckKick(plr:Player)
	if module.Storage[plr.UserId][1] >= 10 then
		plr:Kick("MiniCheat\n\nYou have been kicked for a suspected cheat.\n\nLast Detection:\n"..module.Storage[plr.UserId][2])
	end
end

function module.AddScore(user:Player,score:number,reason:string) -- Add scoring to the user
	if not module.Storage[user.UserId] then 
		module.Storage[user.UserId] = {score,reason} 
		CheckKick(user)
		return
	else
		module.Storage[user.UserId][1] += score
		module.Storage[user.UserId][2] = reason
		return
	end
end

task.spawn(function() -- To reduce false positive kicks, create a loop that lowers one's score every 2 minutes. Ineffective, but helpful. Can be toggled.
	while task.wait(120) do
		if module.ScoreDeducing then
			for k,v in pairs(module.Storage) do
				module.Storage[k][1] = math.max(0,module.Storage[k][1]-1);
			end
		end
	end
end)

return module
