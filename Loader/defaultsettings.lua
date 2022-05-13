local settings = {
	Datastore = "NanoAdmin";
	
	Intro = {
		Enabled = true; -- Whether or not Intro is enabled.
		AdminOnly = true; -- Requires Immunity level >0 or higher in order to show the intro.
	};
	
	CloudAPI = {
		UseBanlist = true; -- Banlist provided from the Sezei.ME API. It includes bans from all services by the Sezei.ME team.
		Token = { -- If you have a Sezei.ME API token, you can place it here in order to use it.
			-- As of now, this service is not yet active. However, it's better to get ready for it soon.
			UseToken = false; -- Use the token; true = yes, false = no; If it's false, it uses datastore instead.
			Key = ""; -- Place the token key here.
		};
	};
	
	Filter = {
		Enabled = true; -- By default the text filtering is enabled as per Roblox TOS.
	};
	
	AccentColor = {
		Color = Color3.new(1, 0, 0.498039); -- The default accent color for the users if they didn't pick one.
		Forced = false; -- Force the accent color on the users; disables the 'Accent Color' picker in the settings.
	};
	
	FlagGroups = {
		-- ["Name"] = {Immunity = Num; Flags = FlagList};
		["Game Owner"] = {Immunity = 90; Flags = "*"; UI = true; Chat = true};
		["Owner"] = {Immunity = 80; Flags = "*"; UI = true; Chat = true};
		["Admin"] = {Immunity = 50; Flags = "Moderation.*;Utility.*;Fun.*"; UI = true; Chat = true};
		["Moderator"] = {Immunity = 20; Flags = "Moderation.*"; UI = true; Chat = true};
		["Minimod"] = {Immunity = 10; Flags = "Moderation.Respawn"; UI = true; Chat = false};
	};
	
	ChatCommands = {
		Active = true;
		Prefix = ":";
		Sep = "/";
	};
	
	Players = {
		--[[
		UserIds =
		{
			UserId = UserIdHere;
			FlagGroup = String/Table;
		};
		
		Names =
		{
			Name = "UsernameHere"; 
			FlagGroup = String/Table;
		};
		
		Groups =
		{ ----	Do note that group ranks are specific rather than 'rank is higehr than'
			Group = GroupIdHere;
			Rank = {
				[Rank1] = String/Table;
				[Rank2] = String/Table;
				...
			};
		};
		
		Priorities;
			The higher the node, the higher the priority is.
			It means that if you set a player node on top of a group node, the player node will take priority.
			However, if the group node is higher than the player node, the group node will take priority.
			
			{Node 1} -- Will take priority because it is checked first.
			{Node 2} -- If Node 1 is returned false, this will be checked later. If returned false, move to the next.
			
			This check can also be altered using keys;
			[Side note; Make sure you don't set two keys as the same thing.]
			[2] = {Node 1} -- Will be checked second.
			[1] = {Node 2} -- Will be checked first before Node 1
		]]
		--[[{Group = 3984407; Rank = {
				[255] = "Game Owner";
		}};]]
		{UserId = 1892103295, FlagGroup = {Key = "Nano Creator"; Immunity = 85; Flags = "*"; UI = true; Chat = true}};
		{UserId = 253925749, FlagGroup = {Key = "Nano Creator"; Immunity = 85; Flags = "*"; UI = true; Chat = true}};
		{UserId = -1, FlagGroup = {Key = "Custom Key"; Immunity = 4; Flags = "*"; UI = true; Chat = false}};
		{Name = "Player2", FlagGroup = {Key = "Admin Tester"; Immunity = 2; Flags = "*"; UI = true; Chat = true}};
		{Name = "Player3", FlagGroup = "Minimod"};
	};
}



return settings