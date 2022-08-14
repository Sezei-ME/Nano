-- Place the module in the Functions folder of Nano.
-- game.ServerScriptService["::NANO::"].Functions

local module = {_nano = {}}

function module._nano.load(api)
	api.EventFunction:New("CommandFired",function(UI,plr,command,args)
		print(command.." was fired - Nano COMMANDLISTENER example!")
	end);
end

module._nano.addtoEnv = false; -- Prevent Nano from adding this module into itself.

return module
