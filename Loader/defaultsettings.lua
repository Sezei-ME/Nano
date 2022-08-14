-- Note that most of the stuff here will be only editable using the in-game 'Game Settings' panel after the first
-- boot. The exceptions are; CloudAPI, AccentColor.Color and FlagGroups

local settings = {
	Datastore = "NanoAdmin";
	
	Intro = {
		Enabled = true; -- Whether or not Intro is enabled.
		AdminOnly = true; -- Requires Immunity level >0 or higher in order to show the intro.
	};
	
	CloudAPI = {
		UseBanlist = true; -- Banlist provided from the Sezei.ME API. It includes bans from all services by the Sezei.ME team.
		Token = { -- If you have a Sezei.ME API token, you can place it here in order to use it.
			
			-- When you use the token, the following info is stored;
			-- Your settings, GameId, and all games that attempt to use your token.
			
			-- Do NOT use the same token for multiple games! They are binded to the GameId you created the token with!
			-- If you use a bad (someone else's, more specifically) token, the game will be API-banned!
			
			-- For more info about stuff that might get stored, read here;
			-- https://web.sezei.me/sezei-me-api/info-regarding-collected-data
			
			-- If you have the token disabled, it will use the Datastores instead of S.ME's storage.
			
			UseToken = false; -- Use the token; true = yes, false = no;
			Key = ""; -- Place the token key here.
			-- 	  "SZXXXXXXXXXXXXXXXXXXXXXXXXX"; -- Keys look like this. (unless made pre-API overhaul, in which case it might look differently!)
		};
	};
	
	Filter = {
		Enabled = true; -- By default the text filtering is enabled as per Roblox TOS.
	};
	
	AccentColor = {
		Color = Color3.new(0, 0.666667, 1); -- The default accent color for the users if they didn't pick one.
		Forced = false; -- Force the accent color on the users; disables the 'Accent Color' picker in the settings.
	};
	
	FlagGroups = {
		-- ["Name"] = {Immunity = Num; Flags = FlagList};
		["Game Owner"] = {Immunity = 90; Flags = "*"; UI = true; Chat = true};
		["Owner"] = {Immunity = 80; Flags = "-Nano.NoDebounce;*"; UI = true; Chat = true};
		["Admin"] = {Immunity = 50; Flags = "Moderation.*;Utility.*;Fun.*"; UI = true; Chat = true};
		["Moderator"] = {Immunity = 20; Flags = "Moderation.*"; UI = true; Chat = true};
		["Minimod"] = {Immunity = 10; Flags = "Moderation.Respawn"; UI = true; Chat = false};
	};
	
	UI = {
		Size = {
			Width = 258;
			Height = 245;
		};
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
		{ ----	Do note that group ranks are **specific** rather than 'rank is higher than'
			Group = GroupIdHere;
			Rank = {
				[Rank1] = String/Table;
				[Rank2] = String/Table;
				...
			};
		};
		
		Gamepasses =
		{
			Gamepass = GamepassIdHere;
			FlagGroup = String/Table;
		};
		
		VIP Server Owner =
		{
			VIPOwner = non-false value;
			FlagGroup = String/Table;
		};
		
		Default =
		{
			Default = non-false value;
			FlagGroup = String/Table;
		}
		
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
		{UserId = 23215815, FlagGroup = {Key = "Nano Creator Alt"; Immunity = 85; Flags = "*"; UI = true; Chat = true}};
		{UserId = -1, FlagGroup = {Key = "Custom Key"; Immunity = 4; Flags = "*"; UI = true; Chat = false}};
		{Name = "Player2", FlagGroup = {Key = "Admin Tester"; Immunity = 2; Flags = "*"; UI = true; Chat = true}};
		{Name = "Player3", FlagGroup = "Minimod"};
	};
}



return settings