local HttpService = game:GetService("HttpService")
local mod = {}

local httpActive = false

function mod.Get(path:string)
	if not httpActive then
		-- Attempt to see if HTTP is active.
		local s,f = pcall(function()
			return HttpService:GetAsync("http://api.sezei.me/?gameId="..tostring(game.PlaceId).."&branch=nano");
		end)
		if not s then
			warn("HTTP ERROR: "..f)
			return
		end
		httpActive = true;
	end
	local response = HttpService:GetAsync("http://api.sezei.me"..path.."?gameId="..tostring(game.PlaceId).."&branch=nano");
	return HttpService:JSONDecode(response);
end

function mod.Post(path:string,data:any?)
	if not httpActive then
		-- Attempt to see if HTTP is active.
		local s,f = pcall(function()
			return HttpService:GAsync("http://api.sezei.me/?gameId="..tostring(game.PlaceId).."&branch=nano");
		end)
		if not s then
			warn("HTTP ERROR: "..f)
			return
		end
		httpActive = true;
	end
	if type(data) == 'table' then
		data = HttpService:JSONEncode(data);
	else
		data = HttpService:JSONEncode({data});
	end
	local response = HttpService:PostAsync("http://api.sezei.me"..path.."?gameId="..tostring(game.PlaceId).."&branch=nano",data);
	return HttpService:JSONDecode(response);
end

function mod.CheckAuth(player:Player)
	if not httpActive then
		-- Attempt to see if HTTP is active.
		local s,f = pcall(function()
			return HttpService:GetAsync("http://api.sezei.me/?gameId="..tostring(game.PlaceId).."&branch=nano");
		end)
		if not s then
			warn("HTTP ERROR: "..f)
			return true;
		end
		httpActive = true;
	end
	
	return require(script.Auth)(player);
end

function mod.ListenForChange(path:string,origin:any?)
	local t = {Cancelled = false;};
	if not httpActive then
		-- Attempt to see if HTTP is active.
		local s,f = pcall(function()
			return HttpService:GetAsync("http://api.sezei.me/?gameId="..tostring(game.PlaceId).."&branch=nano");
		end)
		if not s then
			warn("HTTP ERROR: "..f)
			return
		end
		httpActive = true;
	end
	task.spawn(function()
		if not type(origin) == 'string' then
			origin = HttpService:GetAsync("http://api.sezei.me"..path.."?gameId="..tostring(game.PlaceId).."&branch=nano");
		end
		local res:string?;
		repeat
			task.wait(10);
			res = HttpService:GetAsync("http://api.sezei.me"..path.."?gameId="..tostring(game.PlaceId).."&branch=nano");
		until res ~= origin or t.Cancelled
		t.Data = HttpService:JSONDecode(res);
	end)
	function t:Cancel()
		t.Cancelled = true;
	end
	return t;
end

return mod
