return function(icon)
	if not icon then return "http://www.roblox.com/asset/?id=0" end;
	if string.lower(icon) == "success" or string.lower(icon) == "done" then
		return "http://www.roblox.com/asset/?id=6023426945";
	elseif string.lower(icon) == "unsuccessful" or string.lower(icon) == "failed" then
		return "http://www.roblox.com/asset/?id=6031094677";
	elseif string.lower(icon) == "error" then
		return "http://www.roblox.com/asset/?id=6031071057";
	elseif string.lower(icon) == "no_permission" then
		return "http://www.roblox.com/asset/?id=6035047387";
	elseif string.lower(icon) == "script_error" or string.lower(icon) == "bug" then
		if math.random(1,10) == 10 then
			return (math.random(1,2) == 1 and "http://www.roblox.com/asset/?id=6034470803" or "http://www.roblox.com/asset/?id=6034470809")
		else
			return "http://www.roblox.com/asset/?id=6022852107";
		end
	elseif string.lower(icon) == "notification" then
		return "http://www.roblox.com/asset/?id=6023426923";
	elseif string.lower(icon) == "hint" or string.lower(icon) == "bulb" then
		return "http://www.roblox.com/asset/?id=6026568247";
	elseif string.lower(icon) == "bulboff" then
		return "http://www.roblox.com/asset/?id=6026568254"
	elseif string.lower(icon) == "star" then
		return "http://www.roblox.com/asset/?id=6026568189"
	elseif string.lower(icon) == "problem" then
		return "http://www.roblox.com/asset/?id=6031086176"
	elseif string.lower(icon) == "celebration" then
		return "http://www.roblox.com/asset/?id=6034767613"
	else
		return icon;
	end
end