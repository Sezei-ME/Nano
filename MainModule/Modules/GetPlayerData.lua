return function(api,player)
	-- Shortcut function, basically.
	local i = api.Ingame.Admins[player.UserId]
	return i
end
