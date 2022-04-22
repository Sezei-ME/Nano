local authcache = {}

return function(plr)
	if not plr then return false end
	if authcache[plr.UserId] == true then
		return true
	else
		local succ,data = pcall(function() return game:GetService("HttpService"):JSONDecode(game:GetService("HttpService"):GetAsync("http://api.sezei.me/redefinea/auth/"..plr.UserId.."?gameId="..tostring(game.PlaceId).."&branch=nano")) end);
		if succ and data then
			if data.auth == true or data.usedauthbefore == false then
				authcache[plr.UserId] = true
				return true
			else
				return false
			end
		else
			warn("Redefine:A | Couldn't verify authentication due to CloudAPI being inaccessible: "..data)
			authcache[plr.UserId] = true
			return true
		end
	end
end