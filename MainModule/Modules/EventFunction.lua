local t = {events = {},strict = false}

function t:New(name,funct,event) -- event is optional. do it if you have errors with the errors below.
	local ev = {};
	
	if t.events[name] then
		if t.strict then
			warn("Nano | Notice: An event already exists under key \""..name.."\". Overwriting protection is active, therefore new entries are not allowed.");
			ev = nil;
			return nil;
		else
			repeat
				name = name.."_"
			until not t.events[name]
			warn("Nano | Notice: An event already exists under key \""..name.."\". Overwriting protection is disabled, therefore the new key for this event is \""..name.."\".");
		end
	end
	
	function ev:Disconnect()
		t.events[name] = nil;
	end
	
	t.events[name] = {funct,event};
	
	return ev;
end

function t._NanoWrapper(api)
	local event:BindableEvent = api.Bind
	event.Event:Connect(function(name,...)
		if t.events[name] then
			t.events[name][1](...);
		end
		
		for _,fired in pairs(t.events) do
			if fired[2] == name then
				fired[1]()
			end
		end
	end)
	
	return t;
end

return t;