local focused = true;
local uiInUse = false;
local script = script;
local bind = script.Bind;
local main = script.Parent.Main;
local mfollow = script.Parent.MouseFollow;
local scroll = main.Scroll_Main;
local command = main.InCommand;
local notification = script.Parent.Notification;
local Assets = script.Assets;
local players = game:GetService("Players");
local localplayer = players.LocalPlayer;
local mouse = players.LocalPlayer:GetMouse(); -- wew old tech :troll:
local sendEvent;
local resolveCache = {};
local interactDebounce = false;
local MouseOverModule = require(script.HoverClient);
local NanoWorks = require(script.NanoWorks);
local TickerModule = require(script.SLTT);
local commandContributions = {};
local UIS = game:GetService("UserInputService");
local sendEvents = true;
local inTargetMode = false; -- For player-targeting mode when clicking on the cursor
-- Get Remote
local remote:RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("AdminGUI_Remote");
local event:RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("AdminGUI_Event");

script.Parent:WaitForChild("ErrorCodes") -- Await server detection of the client

local Roblox = {
	warn = warn;
}

local function warn(code, ...)
	if tonumber(code) then
		Roblox.warn("Nano Client | Error "..code.." - "..require(script.Parent.ErrorCodes):ResolveCode(code).." | ",...)
	else
		Roblox.warn("Nano Client | ", code, ...)
	end
end

local notificationsqueue = {}
-- Queue; {icon,message,inprogress};

local function playSound(soundId)
	if type(soundId) == "string" then
		local sound = Instance.new("Sound");
		sound.SoundId = soundId;
		sound.Parent = script.Parent;
		local loaded = false;
		task.spawn(function()
			task.wait(5)
			if not loaded then
				sound:Destroy();
			end
		end)
		sound.Loaded:Connect(function()
			loaded = true;
			sound:Play();
		end)
		sound.Ended:Connect(function()
			sound:Destroy();
			return true;
		end)
	else
		return false;
	end
end

local function asyncFunc(func)
	task.spawn(function()
		func()
	end)
end

local function runNotification(icon,message,sound)
	if not message then warn(-2,"Attempting to send an empty runNotification message.") return end
	pcall(function() script.Parent.Queue.Inner:FindFirstChild("1"):Destroy(); end);
	if not notificationsqueue[2] then
		script.Parent.Queue:TweenPosition(UDim2.new(1,-20,1,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true);
	end
	notification.ImageLabel.Image = icon;
	notification.Message.Text = message;
	-- Start of notification;
	notification.fill.Size = UDim2.new(1,0,1,0);
	notification:TweenPosition(UDim2.new(0.5,0,1,-30),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,false,function()
		task.wait(0.07);
		if sound and settings and settings.Sounds and settings.Sounds[2] == true then
			playSound(sound)
		end;
		notification:TweenSize(UDim2.new(0,notification.Message.TextBounds.X+38,0,30),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,false,function()
			notification.fill:TweenSize(UDim2.new(0,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Linear,math.clamp((notification.Message.TextBounds.X/70),5,15),true);
			task.wait(math.clamp((notification.Message.TextBounds.X/70),5,15)); -- All Notifications to be 5 to 15 seconds.
			notification:TweenSize(UDim2.new(0,30,0,30),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,false,function()
				task.wait(0.07);
				notification:TweenPosition(UDim2.new(0.5,0,1,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,false,function()
					notification.fill.Size = UDim2.new(1,0,1,0);
					task.wait(0.75); -- Cooldown
					table.remove(notificationsqueue,1);
					bind:Fire("NotificationEnded");
					if notificationsqueue[1] then
						pcall(function()
							for _,v in pairs(script.Parent.Queue.Inner:GetChildren()) do if tonumber(v.Name) then v.Name = tostring( tonumber(v.Name) - 1 ) end; end;
						end)
						notificationsqueue[1][3] = true;
						runNotification(notificationsqueue[1][1],notificationsqueue[1][2],notificationsqueue[1][4]);
					end
				end)
			end);
		end);
	end)
end

local function queueNotification(icon:string,message:string,sound:string?)
	if not notificationsqueue[1] then -- If the notifications queue is non existent;
		table.insert(notificationsqueue,{icon,message,true,sound});
		local l = script.Parent.Queue.Inner.Template:Clone();
		l.Parent = script.Parent.Queue.Inner
		l.Visible = true;
		l.Name = "1";
		l.Image = icon;
		l.MouseButton1Down:Connect(function()
			script.CircleAnim:Invoke(l);
		end)
		l.MouseButton1Click:Connect(function()
			table.remove(notificationsqueue,tonumber(l.Name));
			l:Destroy();
			if not notificationsqueue[2] then
				script.Parent.Queue:TweenPosition(UDim2.new(1,-20,1,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true);
			end
		end)
		runNotification(icon,message,sound);
	elseif notificationsqueue[1][3] == false then -- If for whatever reason the notifications queue's being held by the 1st instance.
		table.insert(notificationsqueue,{icon,message,false,sound});
		local l = script.Parent.Queue.Inner.Template:Clone();
		l.Parent = script.Parent.Queue.Inner
		l.Visible = true;
		l.Name = tostring(#notificationsqueue);
		l.Image = icon;
		l.MouseButton1Down:Connect(function()
			script.CircleAnim:Invoke(l);
		end)
		l.MouseButton1Click:Connect(function()
			table.remove(notificationsqueue,tonumber(l.Name));
			l:Destroy();
			if not notificationsqueue[2] then
				script.Parent.Queue:TweenPosition(UDim2.new(1,-20,1,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true);
			end
		end)
		runNotification(notificationsqueue[1][1],notificationsqueue[1][2],notificationsqueue[1][4]);
	else
		table.insert(notificationsqueue,{icon,message,false,sound});
		local l = script.Parent.Queue.Inner.Template:Clone();
		l.Parent = script.Parent.Queue.Inner
		l.Visible = true;
		l.Name = tostring(#notificationsqueue);
		l.Image = icon;
		l.MouseButton1Down:Connect(function()
			script.CircleAnim:Invoke(l);
		end)
		l.MouseButton1Click:Connect(function()
			table.remove(notificationsqueue,tonumber(l.Name));
			l:Destroy();
			if not notificationsqueue[2] then
				script.Parent.Queue:TweenPosition(UDim2.new(1,-20,1,40),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true);
			end
		end)
		script.Parent.Queue:TweenPosition(UDim2.new(1,-20,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.3,true);
	end
end

local canUse,Build,introstr,favs,auth,serverAccentColor;

local waitingforserver=true;
task.spawn(function()
	if main.Visible then
		local function missing()
			local s = "";
			
			if not canUse or not Build then
				s ..= "\nCanUseUI";
				canUse = main.Visible;
				Build = "BETA"
			end
			
			if not introstr then
				s ..= "\nGetStrings";
				-- Already handled.
			end
			
			if not favs then
				s ..= "\ngetFavs";
				favs = {};
			end
			
			if not auth then
				s ..= "\nIsAuthed";
				auth = true;
			end
			
			if not serverAccentColor then
				s ..= "\nGetSetting"
			end
			
			return s;
		end
		
		if game:GetService("RunService"):IsStudio() then
			task.wait(12.5);
		else
			task.wait(5);
		end

		if waitingforserver then
			warn(-1,"Nano will stay dormant until the server successfully wakes. It might take a while.")
			queueNotification("http://www.roblox.com/asset/?id=6031071057","Looks like the server is taking a while to respond. Nano can not run without the server, hence it will stay dormant.")
		end
		
		if task.wait(20) and waitingforserver then
			warn(-1,"The server is taking too long to respond. Missing responses:"..missing());
			queueNotification("http://www.roblox.com/asset/?id=6031071057","Applied default data to missing data. Open Developer Console and look for what changed.")
		end
	end;
end)
--[[
canUse,Build = remote:InvokeServer("CanUseUI");
introstr = remote:InvokeServer("GetStrings",{"Intro_Top","Intro_Middle"});
favs = remote:InvokeServer("getFavs");
auth = remote:InvokeServer("IsAuthed");
serverAccentColor = remote:InvokeServer("GetSetting","AccentColor");
]]
canUse,Build,introstr,favs,auth,serverAccentColor = remote:InvokeServer("ReturnJoinHandle")
waitingforserver = false

if not serverAccentColor then
	serverAccentColor = {
		Color = Color3.new(0, 0.666667, 1);
		Forced = false;
	}
end

-- Attempt to get custom assets from the server.
-- TODO

-- Once attempt ends, fill in the emptiness.
for _,v in pairs(script.DefaultAssets:GetChildren()) do
	if not Assets:FindFirstChild(v.Name) then
		v.Parent = Assets;
	end
end

-- Clean up so less VRAM will be taken. (yes, it's still taken even if not rendered for some reason.)
NanoWorks:FullClear(script.DefaultAssets);
game:GetService("Debris"):AddItem(script.DefaultAssets,1);


local function isBright(color:Color3)
	local brightness = (color.R * 0.45) + (color.G * 0.65) + (color.B * 0.55);
	if brightness >= 1 then
		return true
	else
		return false
	end
end

local settings = {
	-- Normal Types: {isLocal (Not saved; but not sending SettingChanged to server either), Value, CustomName, Changed function}
	-- Userdata Types: {isLocal, {Type, Value}, CustomName}
	ShowCommandContributions = {false,false,"Show Contributors"};
	ShowTargetmodeHint = {false,true,"Target Mode Hinting"};
	Sounds = {false,true,"Nano Sounds"};
	--UIPosition = {true,{"dropdown",{Default = "Left"; Options = {"Left", "Right", "Center"}}},"UI Position",function(val)
	--	print(val);
	--end};
}

if not serverAccentColor.Forced then
	settings.AccentColor = {false,{"Color",Color3.new(0,0.666667,1)},"Accent Color", function(val)
		val = val[2];
		if type(val) == "string" then
			val = BrickColor.new(val);
		end
		main.SearchBar.Toggle.BackgroundColor3 = val.Color;
		main.SearchBar.Toggle.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
		Assets.Intro.BackgroundColor3 = val.Color;
		Assets.Intro.Image.BackgroundColor3 = val.Color;
		Assets.Intro.Image.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
		Assets.Hint.BackgroundColor3 = val.Color;
		Assets.Hint.Frame.BackgroundColor3 = val.Color;
		Assets.Hint.Image.BackgroundColor3 = val.Color;
		Assets.Message.BackgroundColor3 = val.Color;
		Assets.Message.Image.BackgroundColor3 = val.Color;

		if script.Parent:FindFirstChild("Intro") then
			script.Parent.Intro.BackgroundColor3 = val.Color;
			script.Parent.Intro.Image.BackgroundColor3 = val.Color;
			script.Parent.Intro.Image.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
		end

		if script.Parent:FindFirstChild("Message") then
			script.Parent.Message.BackgroundColor3 = val.Color;
			script.Parent.Message.Image.BackgroundColor3 = val.Color;
		end

		if script.Parent:FindFirstChild("Hint") then
			script.Parent.Hint.BackgroundColor3 = val.Color;
			script.Parent.Hint.Image.BackgroundColor3 = val.Color;
			script.Parent.Hint.Frame.BackgroundColor3 = val.Color;
		end
	end};
else
	local val = serverAccentColor
	main.SearchBar.Toggle.BackgroundColor3 = val.Color;
	main.SearchBar.Toggle.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
	Assets.Intro.BackgroundColor3 = val.Color;
	Assets.Intro.Image.BackgroundColor3 = val.Color;
	Assets.Intro.Image.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
	Assets.Hint.BackgroundColor3 = val.Color;
	Assets.Hint.Frame.BackgroundColor3 = val.Color;
	Assets.Hint.Image.BackgroundColor3 = val.Color;
	Assets.Message.BackgroundColor3 = val.Color;
	Assets.Message.Image.BackgroundColor3 = val.Color;

	if script.Parent:FindFirstChild("Intro") then
		script.Parent.Intro.BackgroundColor3 = val.Color;
		script.Parent.Intro.Image.BackgroundColor3 = val.Color;
		script.Parent.Intro.Image.ImageColor3 = (isBright(val.Color) and Color3.new(0,0,0) or Color3.new(1,1,1));
	end

	if script.Parent:FindFirstChild("Message") then
		script.Parent.Message.BackgroundColor3 = val.Color;
		script.Parent.Message.Image.BackgroundColor3 = val.Color;
	end

	if script.Parent:FindFirstChild("Hint") then
		script.Parent.Hint.BackgroundColor3 = val.Color;
		script.Parent.Hint.Image.BackgroundColor3 = val.Color;
		script.Parent.Hint.Frame.BackgroundColor3 = val.Color;
	end
end

for key,val in pairs(settings) do
	local dat = remote:InvokeServer("GetCSetting",key)
	if dat then
		settings[key][2] = dat;
		if settings[key][4] and type(settings[key][4]) == "function" then
			settings[key][4](dat)
		end
	end
end

mfollow.Visible = false;

task.spawn(function()
	main.Version.Text = Build;
	main.Version.TextTransparency = 1
	TickerModule:Smoothify("You are running NANO "..Build,main.Version,5)
end)

if not canUse then
	main.Visible = false;
end

local contributions = {
	-- [id] = {Contribution, Color3, AssetURL};
	[253925749] = {"System Backend", Color3.new(1, 0.0588235, 0.466667),"http://www.roblox.com/asset/?id=6023426938"};
	[1892103295] = {"System Frontend", Color3.new(1, 0.333333, 1),"http://www.roblox.com/asset/?id=6023426938"};
	[259773550] = {"Notable Feedback", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668946"};
	[177424228] = {"Notable Feedback", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668946"};
	[73885696] = {"S.ME Administrator", Color3.new(1, 0.333333, 0),"http://www.roblox.com/asset/?id=6022668911"};
	[173471724] = {"Base AGB\n(2002 - 2021)", Color3.new(0.623529, 0.572549, 1),"http://www.roblox.com/asset/?id=6023426974"};
	[441169726] = {"QA Tester", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668880"};
	[1094977] = {"Datastore Module", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668911"};
	[82347291] = {"Open-Source Modules", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668911"};
	[711971214] = {"QA Tester", Color3.new(0.227451, 0.12549, 1),"http://www.roblox.com/asset/?id=6022668880"};
	[153503346] = {"S.ME Administrator", Color3.new(1, 0.333333, 0),"http://www.roblox.com/asset/?id=6035078889"};
	[163986693] = {"Code Optimising\nS.ME Administrator", Color3.new(1, 0.333333, 0),"http://www.roblox.com/asset/?id=6022668911"};
}

UIS.WindowFocused:Connect(function()
	focused = true;
end)

UIS.WindowFocusReleased:Connect(function()
	focused = false;
end)

local function runIntro()
	task.spawn(function()
		if script.Parent:FindFirstChild("Intro") then script.Parent["Intro"]:Destroy() end;
		local asset = script.Assets:FindFirstChild("Intro"):Clone();
		asset.Parent = script.Parent;
		asset.Visible = true;
		asset.Inner.Title.Text = introstr["Intro_Top"] or "Nano";
		asset.Inner.Msg.Text = introstr["Intro_Middle"] or "Created by Sezei.Me and Axelius"
		asset.Inner.Msg.Position = UDim2.new(0.503,0,0.67,0)
		asset.Inner.EffectHolder.BG:TweenPosition(UDim2.new(-1,0,-1,0),"Out","Linear",10,true)
		asset:TweenPosition(UDim2.new(1, -15,1, -45),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true,function()
			asset:TweenPosition(UDim2.new(1,-15,1,-92),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true);
			asset.Inner:TweenSize(UDim2.fromOffset(300,80),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.5,true);
			asset.Inner.Time:TweenSize(UDim2.new(0,0,0,4),Enum.EasingDirection.InOut,Enum.EasingStyle.Linear,math.clamp((#asset.Inner.Msg.Text / 10),5,20),true,function()
				asset.Inner:TweenSize(UDim2.new(0,300,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true);
				asset:TweenPosition(UDim2.new(1, -15,1, -45),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true);
				task.wait(0.75);
				asset:TweenPosition(UDim2.new(1.5,0,1,-45),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true,function()
					task.wait(0.25);
					asset:Destroy();
				end);
			end)
		end);
	end)
end

local function runMessage(title,message,icon)
	if script.Parent:FindFirstChild("Message") then script.Parent["Message"]:Destroy() end;
	local asset = script.Assets:FindFirstChild("Message"):Clone();
	asset.Parent = script.Parent;
	asset.Visible = true;
	asset.Inner.Title.Text = title;
	asset.Inner.Msg.Text = message
	if not icon then 
		asset.Image.Visible = false; 
	else
		asset.Image.Image = icon;
	end;
	asset:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true,function()
		asset:TweenPosition(UDim2.new(0.5,0,0.5,-47),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true);
		asset.Inner:TweenSize(UDim2.fromOffset(500,133),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.2,true);
		asset.Inner.Time:TweenSize(UDim2.new(0,0,0,4),Enum.EasingDirection.InOut,Enum.EasingStyle.Linear,math.clamp((#message / 10),5,20),true,function()
			asset.Inner:TweenSize(UDim2.new(0,500,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true);
			asset:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true);
			task.wait(0.55);
			asset:TweenPosition(UDim2.new(-0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true,function()
				task.wait(0.25);
				asset:Destroy();
			end);
		end)
	end);
end

local function messageReceived(senderId,message)
	local asset = script.Assets:FindFirstChild("PrivateMessage"):Clone();
	asset.Parent = script.Parent;
	asset.Visible = true;
	asset.Inner.Title.Text = "Private Conversation with "..players:GetNameFromUserIdAsync(senderId)
	asset.Inner.Msg.Text = message
	asset:TweenPosition(UDim2.new(0.5,0,0.5,-47),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true)

	asset.Inner.Frame.TextBox:GetPropertyChangedSignal("Text"):Connect(function() -- Limit characters to 90 (bruteforce way)
		if asset.Inner.Frame.TextBox.Text.len() >= 90 then
			asset.Inner.Frame.TextBox.Text = string.sub(1,90);
		end
	end)

	asset.Inner.Frame.DeleteMessage.MouseButton1Click:Connect(function()
		asset:TweenPosition(UDim2.new(-0.5,0,0.5,-47),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true,function()
			task.wait(0.5)
			asset:Destroy();
		end)
	end)

	asset.Inner.Frame.SendMessage.MouseButton1Click:Connect(function()
		-- send the message before all of the crazy tweens and visuals
		remote:InvokeServer("SendPrivateMessage",{senderId,asset.Inner.Frame.TextBox.Text});

		-- proceed with the visuals
		asset.Inner:TweenSize(UDim2.new(1,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true)
		asset:TweenPosition(UDim2.new(0.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true,function()
			task.wait(0.15);
			asset:TweenPosition(UDim2.new(0.5,0,-0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.4,true,function()
				task.wait(0.5)
				asset:Destroy();
			end)
		end)
	end)
end

local function runHint(title,message,icon)
	if script.Parent:FindFirstChild("Hint") then script.Parent["Hint"]:Destroy() end;
	local asset = script.Assets:FindFirstChild("Hint"):Clone();
	asset.Parent = script.Parent;
	asset.Visible = true;
	asset.Inner.Title.Text = title;
	asset.Inner.Msg.Text = message
	if not icon then 
		asset.Image.Visible = false; 
	else
		asset.Image.Image = icon;
	end;
	asset:TweenPosition(UDim2.new(0.5,0,0.018,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true,function()
		asset.Inner.Time:TweenSize(UDim2.new(0,0,0,4),Enum.EasingDirection.InOut,Enum.EasingStyle.Linear,math.clamp((#message / 10),5,20),true,function()
			asset:TweenPosition(UDim2.new(-0.5,0,0.018,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.7,true,function()
				task.wait(0.25);
				asset:Destroy();
			end);
		end)
	end);
end

local function buildButtons(cmds) -- Build the UI button.
	local commands_layout = {}
	for _,v in pairs(scroll:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy();
		end
	end

	local titl = Assets.CommandTitle:Clone();
	local items = {}
	titl.Name = "_Favourites";
	titl.Text = "Starred Commands";
	titl.Parent = scroll;
	titl.Visible = false;
	titl.LayoutOrder = 0;

	local folders = {}
	for key,cmd in pairs(cmds) do -- Sort the commands into their respective folders.
		if not folders[cmd[2]] then
			folders[cmd[2]] = {};
			folders[cmd[2]][key] = cmd;
		else
			folders[cmd[2]][key] = cmd;
		end
	end
	for _,pfolder in pairs(folders) do
		table.sort(commands_layout, function(first, second)
			return first:lower() < second:lower()
		end)
	end
	local highestOrder = 0;
	for title, folder in pairs(folders) do -- For each folder; Build the title first, and then the commands.
		local titl = Assets.CommandTitle:Clone();
		local items = {}
		titl.Name = "_"..title;
		titl.Text = string.gsub(title,"_"," "); -- Replace all '_'s with spaces for good look.
		titl.Parent = scroll;
		titl.Visible = true;
		titl.LayoutOrder = highestOrder;
		local vis = true;
		titl.MouseButton1Click:Connect(function()
			if vis then
				for _,v in pairs(items) do
					v.Visible = false;
				end
				titl.Frame.BackgroundColor3 = Color3.new(0.427451, 0.427451, 0.427451)
				titl.TextColor3 = Color3.new(0.427451, 0.427451, 0.427451)
				vis = false;
			else
				for _,v in pairs(items) do
					v.Visible = true;
				end
				titl.Frame.BackgroundColor3 = Color3.new(1, 1, 1)
				titl.TextColor3 = Color3.new(1, 1, 1)
				vis = true;
			end
		end)
		for k, cmd in pairs(folder) do -- For each command; Commands are built like this; {{commanddata}, "parentfolder"}
			if cmd[1].InGui then -- Check if the command should be built in the UI in the first place. Usually disabled for debug commands only.
				
				local parentfolder = cmd[2]; -- QoL; Get the parent folder.
				local cmd = cmd[1]; -- QoL; No need to use cmd[1] everytime. Besides, we already got the parent folder.
				local btn = NanoWorks:NewAsset("command",{Key = k; Text = string.gsub(cmd.Name,"_"," "); Category = titl.Name; Hint = cmd.Description and cmd.Description.Short or nil; Color = cmd.Color})
				items[#items+1] = btn.self
				btn.self.LayoutOrder = highestOrder + string.byte(k);
				btn.self.Parent = scroll;
				table.sort(folder, function(first, second)
					return first.Name:lower() < second.Name:lower()
				end)

				if favs[btn.self.Name] then
					btn.self.Starred.Image = "http://www.roblox.com/asset/?id=6031068423";
				else
					btn.self.Starred.Image = "http://www.roblox.com/asset/?id=6031068425";
				end

				if type(cmd.Credit) == "table" and cmd.Credit[1] then
					for _,uid in pairs(cmd.Credit) do
						if commandContributions[uid] then
							commandContributions[uid] += 1
						else
							commandContributions[uid] = 1
						end
					end

				end

				task.spawn(function()
					if type(cmd.Credit) == "table" and cmd.Credit[1] and settings.ShowCommandContributions[2] then
						local building = "";
						local users = game:GetService("UserService"):GetUserInfosByUserIdsAsync(cmd.Credit)
						for pos,user in pairs(users) do
							if not resolveCache[user.Id] then resolveCache[user.Id] = user.Username end;
							if pos == 1 then
								building = "By "..user.Username
							elseif pos == #users then
								building ..= " and "..user.Username
							else
								building ..= ", "..user.Username
							end
						end
						btn.self:WaitForChild("Credit").Text = building
					else
						btn.self:WaitForChild("Credit").Visible = false;
						btn.self.TextSize += 2
					end
				end)

				btn.self.Starred.MouseButton1Click:Connect(function()
					task.spawn(function()
						remote:InvokeServer("updateFavs",btn.self.Name)
						if favs[btn.self.Name] then
							favs[btn.self.Name] = nil;
							btn.self.Starred.Image = "http://www.roblox.com/asset/?id=6031068425";
						else
							favs[btn.self.Name] = true;
							btn.self.Starred.Image = "http://www.roblox.com/asset/?id=6031068423";
							main.Frame.Starred.Visible = true;
						end
					end)
				end)

				btn.event:Connect(function()
					command.Visible = true;
					scroll.Visible = false;

					command.Top.Title.Text = cmd.Name;

					local inn = command.InnerStuff

					for _,v in pairs(inn:GetChildren()) do
						if not v:IsA("UIListLayout") and v.Name ~= "-" then -- Ignore UIListLayout and the '-' thing.
							v:Destroy();
						end
					end

					if cmd.Description and cmd.Description.Long then
						local p = script.Assets.Description:Clone();
						p.Name = k;
						p.Txt.Text = cmd.Description.Long;
						p.Txt.Size = UDim2.new(0,186,0, math.max(25,p.Txt.TextBounds.Y+9));
						p.Size = UDim2.new(1,0,0,math.max(40,p.Txt.Size.Y.Offset+5));
						p.Visible = true;
						p.Parent = inn;
					end

					if type(cmd.Sendable) == "boolean" and not cmd.Sendable then
						command.Send.Visible = false;
					else
						command.Send.Visible = true;
					end

					for k,field in pairs(cmd.Fields) do
						local p;
						if string.lower(field.Type) == "player" or string.lower(field.Type) == "safeplayer" or string.lower(field.Type) == "players" or string.lower(field.Type) == "safeplayers" or string.lower(field.Type) == "metaplayer" or string.lower(field.Type) == "safemetaplayer" then
							--[[ -- Legacy Player
							p = script.Assets.PlayerOLD:Clone();
							p.Name = k;
							p.Txt.Text = field.Text;
							if field.Required then
								p.Txt.Text = p.Txt.Text.."<font color=\"#ff2121\"><b>*</b></font>"
							end
							p.Visible = true;
							p.Parent = inn;
							]]
							p = NanoWorks:NewAsset("PlayerDropdown",{Key = k; Text = field.Text;})
							
							if field.Required then
								p.self.Txt.Text ..= "<font color=\"#ff2121\"><b>*</b></font>"
							end
							if localplayer.DisplayName ~= localplayer.Name then
								p.self.TextButton.Text = localplayer.DisplayName.." (@"..localplayer.Name..")";
							else
								p.self.TextButton.Text = "@"..localplayer.Name;
							end
							p.self.Value.Value = localplayer.Name
							p.self.TextButton.Text = game:GetService("Players").LocalPlayer.Name
							p.self.Value.Value = game:GetService("Players").LocalPlayer.Name
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "description" and not cmd.Sendable then
							p = NanoWorks:NewAsset("description",{Key = k;Text = field.Text;})
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "dropdown" then
							p = NanoWorks:NewAsset("customdropdown",{Key = k, Text = field.Text; Default = field.Default; Options = field.Options})
							if field.Required then
								p.self.Txt.Text ..= "<font color=\"#ff2121\"><b>*</b></font>"
							end
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "string" or string.lower(field.Type) == "number" then
							p = NanoWorks:NewAsset(field.Type,{Key = k;Name = field.Text;Default = field.Default})
							if field.Required then
								p.self.Txt.Text ..= "<font color=\"#ff2121\"><b>*</b></font>"
							end
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "time" then
							-- Exclude from framework: Probably won't be used in stuff that isn't commands.
							p = script.Assets.Time:Clone();
							p.Name = k;
							p.Txt.Text = field.Text;
							if field.Required then
								p.Txt.Text ..= "<font color=\"#ff2121\"><b>*</b></font>"
							end
							p.TextBox.Text = "1";
							p.Value.Value = "1";
							p.Visible = true;
							p.Parent = inn;
						elseif string.lower(field.Type) == "boolean" then
							p = NanoWorks:NewAsset("Boolean",{Key = k;Name = field.Text;Default = field.Default})
							if field.Required then
								p.self.Txt.Text ..= "<font color=\"#ff2121\"><b>*</b></font>"
							end
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "color" then
							p = NanoWorks:NewAsset("color",{Key = k;Name = field.Text;})
							p.self.Parent = inn;
						elseif string.lower(field.Type) == "slider" then
							p = NanoWorks:NewAsset("Slider",{Key = k; Name = field.Text; Minimum = field.Minimum or 0; Maximum = field.Maximum or 100})
							p.self.Parent = inn;
						end

						if p and typeof(p) ~= "Instance" and p.self and typeof(p.self) ~= "string" then
							p.self:SetAttribute("InternalKey",field.Internal)
							if field.Permission then
								if not remote:InvokeServer("HasPermission",field.Permission) then
									p.Visible = false;
								end
							end
							
							p.self:FindFirstChild("Value").Changed:Connect(function(newval)
								bind:Fire("CommandChangedValue",remote:InvokeServer("CommandChangedValue",{cmd.Name,k,newval}));
							end)
						end

						
					end

					local receiveddata = remote:InvokeServer("CommandOpened",cmd.Name);
					
					local pressed = false;
					sendEvent = command.Send.MouseButton1Click:Connect(function()
						if pressed then return end;
						pressed = true
						if remote:InvokeServer("HasPermission","Nano.NoDebounce") then
							task.delay(0.25,function() -- Still needs to have some debounce anyways to avoid SOMEONE from spamming
								pressed = false;
							end);
						end
						if settings and settings.Sounds and settings.Sounds[2] == true then
							script.Sounds.SendingData:Play();
						end
						local prefix,sep = remote:InvokeServer("GetSeparator");
						local readyfields = {}
						for _,v in pairs(inn:GetChildren()) do
							if tonumber(v.Name) then
								if string.sub(v.Txt.ContentText,string.len(v.Txt.ContentText)) == "*" then -- Prevent unwanted empty strings.
									if v.Value:IsA("StringValue") then
										if v.Value.Value == "" then
											v.Txt.TextColor3 = Color3.new(1,0,0)
											game:GetService("TweenService"):Create(v.Txt, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),
											{
												TextColor3 = Color3.new(1,1,1);		
											}
											):Play()
											return
										end
									end
								end
								readyfields[tonumber(v.Name)] = v.Value.Value;
							end
						end
						local strin = {k,readyfields};
						command.CommandSent.Visible = true
						local done = {false}
						task.spawn(function()
							command.CommandSent.TextLabel.Text = "Command Data is being sent.."
							repeat
								command.CommandSent.Spinner.Rotation += 10
								task.wait();
							until done[1] == true
							if type(done[2]) == "boolean" and done[2] then
								local times = 10
								repeat
									command.CommandSent.Spinner.Rotation += 35
									task.wait();
									times -= 1
								until times == 0
								command.CommandSent.TextLabel.Text = "Success!"
								if settings and settings.Sounds and settings.Sounds[2] == true then
									script.Sounds.SendingData:Stop();
									script.Sounds.DataSent:Play();
								end
								command.CommandSent.Spinner.Visible = false
								command.CommandSent.Done.Visible = true
							elseif type(done[2]) == "nil" then
								local times = 10
								repeat
									command.CommandSent.Spinner.Rotation += 35
									task.wait();
									times -= 1
								until times == 0
								command.CommandSent.TextLabel.Text = "No status returned."
								if settings and settings.Sounds and settings.Sounds[2] == true then
									script.Sounds.SendingData:Stop();
									script.Sounds.DataSent:Play();
								end
								command.CommandSent.Spinner.Visible = false
								command.CommandSent.Nil.Visible = true
							elseif type(done[2]) == "boolean" then
								local times = 10
								repeat
									command.CommandSent.Spinner.Rotation += 35
									task.wait();
									times -= 1
								until times == 0
								command.CommandSent.TextLabel.Text = "An error has occured!"
								if settings and settings.Sounds and settings.Sounds[2] == true then
									script.Sounds.SendingData:Stop();
									script.Sounds.DataSent:Play();
								end
								command.CommandSent.Spinner.Visible = false
								command.CommandSent.Error.Visible = true
								
							else
								local times = 10
								repeat
									command.CommandSent.Spinner.Rotation += 35
									task.wait();
									times -= 1
								until times == 0
								command.CommandSent.TextLabel.Text = tostring(done[2]);
								command.CommandSent.Spinner.Visible = false
								command.CommandSent.Nil.Visible = true
							end
						end)
						local r = remote:InvokeServer("SendCommand",strin)
						done = {true,r};
						task.wait(2.5)
						command.Visible = false;
						command.CommandSent.Visible = false
						command.CommandSent.Spinner.Visible = true
						command.CommandSent.Error.Visible = false
						command.CommandSent.Done.Visible = false
						command.CommandSent.Nil.Visible = false
						scroll.Visible = true;
						sendEvent:Disconnect();
					end)
				end)
			end
		end
		highestOrder+=256;
	end
end

command.Top.ImageButton.MouseButton1Click:Connect(function()
	command.Visible = false;
	scroll.Visible = true;
	if sendEvent then
		sendEvent:Disconnect();
	end
end)

local cmds = remote:InvokeServer("GetAvailableCommands");
buildButtons(cmds);

main.Frame.Refresh.MouseButton1Click:Connect(function()
	if interactDebounce == true then return end
	interactDebounce = true
	cmds = remote:InvokeServer("GetAvailableCommands");
	buildButtons(cmds);
	if remote:InvokeServer("IsAuthed") then
		main.AuthLock.Visible = false;
	else
		main.AuthLock.Visible = true;
	end
	task.wait(2.5);
	interactDebounce = false
end)
main.Frame.Refresh.ImageColor3 = Color3.new(1,1,1)

local function NewHighlight(character:Instance)
	
	if character:FindFirstChildOfClass("Highlight") then
		character:FindFirstChildOfClass("Highlight"):Destroy();
		character:FindFirstChild("Nano_Highlight"):Destroy();
		return
	end
	local Title = Assets.Nano_Highlight:Clone();
	local Highlight = Assets.Highlight:Clone();

	Title.Parent = character;
	Title.TextLabel.Text = character.Name.."\nV";
	Title.Adornee = (character:FindFirstChild("Head") or character);
	Title.TextLabel.Visible = true;

	Highlight.Parent = character;
end

event.OnClientEvent:Connect(function(reason,detail)
	if reason == "Message" then
		-- detail1 = title
		-- detail2 = message
		-- detail3 = icon
		runMessage(detail[1],detail[2],detail[3]);
	elseif reason == "Intro" then
		runIntro()
	elseif reason == "Hint" then
		-- detail1 = title
		-- detail2 = message
		-- detail3 = icon
		runHint(detail[1],detail[2],detail[3]);
	elseif reason == "PrivateMessage" then
		-- detail1 = sender
		-- detail2 = message
		messageReceived(detail[1],detail[2]);
	elseif reason == "Notify" then
		local icon = detail[1];
		local message = detail[2];

		-- Success: http://www.roblox.com/asset/?id=6023426945
		-- Unsuccessful: http://www.roblox.com/asset/?id=6031094677
		-- Error: http://www.roblox.com/asset/?id=6031071057
		-- No permission: http://www.roblox.com/asset/?id=6035047387
		-- Script error: http://www.roblox.com/asset/?id=6022668916
		-- Notification: http://www.roblox.com/asset/?id=6023426923
		-- Hint: http://www.roblox.com/asset/?id=6026568247

		local icon = require(script.Icons)(icon);
		queueNotification(icon,message);
	elseif reason == "Highlight" then
		NewHighlight(detail);
	elseif reason == "Mute" then
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,false);
	elseif reason == "Unmute" then
		game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat,true);
	else
		local newasset = NanoWorks:NewAsset(reason,detail);
		if newasset.run then
			newasset.run(script.Parent);
		end
	end
end)

scroll.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	local absolute_size = scroll.UIListLayout.AbsoluteContentSize
	scroll.CanvasSize = UDim2.new(0, absolute_size.X, 0, absolute_size.Y)
end)

local mouseinUI = false;

local MouseEnter, MouseLeave = MouseOverModule.MouseEnterLeaveEvent(main)

MouseEnter:Connect(function()
	mouseinUI = true;
end)

MouseLeave:Connect(function()
	mouseinUI = false;
end)


for _,v in pairs(scroll:GetChildren()) do
	if v:IsA("TextButton") and v:FindFirstChild("HoverHint") then
		local MouseEnter, MouseLeave = MouseOverModule.MouseEnterLeaveEvent(v)

		MouseEnter:Connect(function()
			if mouseinUI and scroll.Visible and v.Visible then
				mfollow.Hover_2d.Text = " <b>"..v.Text.."</b>\n"..v.HoverHint.Value;
				mfollow.Hover_2d.Visible = true;
			end
		end)

		MouseLeave:Connect(function()
			mfollow.Hover_2d.Visible = false;
		end)
	end
end

local rankCache = {};

mouse.Move:Connect(function()
	mfollow.Position = UDim2.fromOffset(mouse.X+3,mouse.Y+40);
	if mouse.Target and mouse.Target:FindFirstAncestorWhichIsA("Model"):FindFirstChild("Humanoid") and mouse.Target:FindFirstAncestorOfClass("Model"):FindFirstChild("Humanoid") and not mouseinUI then
		local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
		local pos1 = char.HumanoidRootPart.Position
		if not mouse.Target:FindFirstAncestorWhichIsA("Model").HumanoidRootPart then mfollow.Hover_3d.Text = ""; mfollow.Hover_3d.Visible = false; end;
		local pos2 = mouse.Target:FindFirstAncestorWhichIsA("Model").HumanoidRootPart.Position
		mfollow.Hover_3d.Text = " <b>"..mouse.Target:FindFirstAncestorWhichIsA("Model").Name.. "</b>\nDistance: "..math.floor((pos1 - pos2).magnitude).." Studs"
		if game:GetService("Players"):GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model")) then
			local p = game:GetService("Players"):GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model"))
			if not rankCache[p.UserId] then rankCache[p.UserId] = remote:InvokeServer("GetPlayerDataFromId",p.UserId); end
			local pdata = rankCache[p.UserId];
			mfollow.Hover_3d.Text ..= "\nUserId: "..p.UserId
				.. "\nGroup: "..tostring(pdata.FlagGroup.Key)
				.. "\nImmunity: "..tostring(pdata.FlagGroup.Immunity)
			if inTargetMode then
				if pdata.FlagGroup.Immunity > 0 then
					mfollow.Hover_3d.Text ..= "\n<font color=\"#ff9900\">Potentially Targetable</font>"
				else
					mfollow.Hover_3d.Text ..= "\n<font color=\"#00ff00\">Targetable</font>"
				end
			end
		else
			mfollow.Hover_3d.Text ..= "\n<font color=\"#ff2a2a\">Not a player</font>"
			if inTargetMode then
				mfollow.Hover_3d.Text ..= "\n<font color=\"#ff2a2a\">Not Targetable</font>"
			end
		end
		mfollow.Hover_3d.Visible = true;
	else
		mfollow.Hover_3d.Text = "";
		mfollow.Hover_3d.Visible = false;
	end
end)

local ev;
bind.Event:Connect(function(event,inst)
	if not canUse then return end
	if event == "EnterTargeting" then
		if inTargetMode then
			queueNotification("http://www.roblox.com/asset/?id=6026568247","You already are in targeting mode!");
			return
		end
		if settings.ShowTargetmodeHint[2] then
			queueNotification("http://www.roblox.com/asset/?id=6026568247","You have entered Mouse Targeting mode!");
		end
		inTargetMode=true;
		main.TargetMode.Visible = true;
		ev = mouse.Button1Down:Connect(function()
			if not focused then return end
			if game:GetService("Players"):GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model")) then
				ev:Disconnect();
				if settings.ShowTargetmodeHint[2] then
					queueNotification("http://www.roblox.com/asset/?id=6026568247","Target has been selected: "..game:GetService("Players"):GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model")).Name);
				end
				inTargetMode=false;
				main.TargetMode.Visible = false;
				inst.Text = game:GetService("Players"):GetPlayerFromCharacter(mouse.Target:FindFirstAncestorWhichIsA("Model")).Name;
			else
				if settings.ShowTargetmodeHint[2] then
					queueNotification("http://www.roblox.com/asset/?id=6026568247","You left Mouse Targeting mode since you clicked on a non-player object.");
				end
				ev:Disconnect();
				inTargetMode=false;
				main.TargetMode.Visible = false;
				inst.Text = "";
			end
		end)
	elseif event == "ToggleInUse" then
		uiInUse = inst
		mfollow.Visible = uiInUse;
	elseif event == "SettingChanged" then -- {setting,value}
		-- Settings structure: [name] = {isLocal, value}
		settings[inst[1]][2] = inst[2]

		if settings[inst[1]][1] == false then
			remote:InvokeServer("SetCSetting",{inst[1],inst[2]});
		end
	end
end)

if not auth then
	main.AuthLock.Visible = true;
end

-- Build TopUI sections
local function InsertToC(C:Instance,inst:Instance)
	inst.Parent = C;
end
--Credits
local C = main.TopUI.Credits

-- Organise positions by contributions. (Command Contributions > System Contributions)
-- Do the stuff for the already organised contributors
for uid,conts in pairs(commandContributions) do
	local inst = script.Assets.CreditTemplate:Clone();
	inst.Name = uid
	inst.LayoutOrder = 500 - conts
	local t = "";
	if contributions[uid] then
		t = contributions[uid][1]
		inst.BackgroundColor3 = contributions[uid][2]
		inst.SideColor.BackgroundColor3 = contributions[uid][2]
		inst.RoleImage.Image = contributions[uid][3] or "0";
		inst.RoleImage.Visible = true
	else
		inst.RoleImage.Visible = false;
	end
	if game:GetService("Players").LocalPlayer.UserId == uid then
		inst.name.Text = "You"
		inst.BackgroundColor3 = Color3.new(0.333333, 1, 0);
		inst.SideColor.BackgroundColor3 = Color3.new(0.333333, 1, 0);
	else
		task.spawn(function()
			inst.name.Text = resolveCache[uid] or game:GetService("Players"):GetNameFromUserIdAsync(uid);
		end)
	end
	if conts > 100 then
		if t == "" then t = "Commands Hacker ("..conts..")" else t..="\nCommands Hacker ("..conts..")" end
	elseif conts > 50 then
		if t == "" then t = "Command Master ("..conts..")" else t..="\nCommand Master ("..conts..")" end
	elseif conts > 25 then
		if t == "" then t = "Command Developer ("..conts..")" else t..="\nCommand Developer ("..conts..")" end
	elseif conts > 10 then -- Someone has been busy, huh? Wouldn't be fair to make it all in vain. (Rewards 'Command Maker' title in the credits section, unless they already have a title.)
		if t == "" then t = "Command Maker ("..conts..")" else t..="\nCommand Maker ("..conts..")" end
	else
		if t == "" then t = "Command Contributions: "..conts else t..="\nCommand Contributions: "..conts end
	end
	inst.Creations.Text = t;
	inst.Creations:GetPropertyChangedSignal("TextBounds"):Connect(function()
		local y = inst.Creations.TextBounds.Y
		inst.Size = UDim2.new(1,-8,0,math.max(50,y+27)) -- Size + 6 Pixel Spacing
	end);	
	inst.Image.Image = game:GetService("Players"):GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
	inst.Visible = true;	
	InsertToC(C,inst);
end

for uid,tbl in pairs(contributions) do
	if not C:FindFirstChild(tostring(uid)) then
		local inst = script.Assets.CreditTemplate:Clone();
		inst.Name = tostring(uid)
		t = tbl[1]
		inst.BackgroundColor3 = tbl[2];
		inst.SideColor.BackgroundColor3 = tbl[2];
		inst.RoleImage.Image = tbl[3];
		inst.RoleImage.Visible = true
		if game:GetService("Players").LocalPlayer.UserId == uid then
			inst.name.Text = "You"
			inst.BackgroundColor3 = Color3.new(0.333333, 1, 0);
			inst.SideColor.BackgroundColor3 = Color3.new(0.333333, 1, 0);
		else
			inst.name.Text = game:GetService("Players"):GetNameFromUserIdAsync(uid);
		end
		inst.Creations.Text = t;
		inst.Image.Image = game:GetService("Players"):GetUserThumbnailAsync(uid,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48);
		inst.Visible = true;
		inst.Size = UDim2.new(1,-8,0,math.max(50,inst.Creations.TextBounds.Y+27)) -- Position + 6 Pixel Spacing
		inst.LayoutOrder = 500 + string.byte(inst.name.Text:sub(1,1));
		InsertToC(C,inst);
	end
end

C.CanvasSize = UDim2.new(0,0,0,C.UIListLayout.AbsoluteContentSize.Y)

main.Frame.Credits.MouseButton1Click:Connect(function()
	if main.TopUI.Visible == true and main.TopUI.Credits.Visible == true then
		main.TopUI.Visible = false;
	else
		main.TopUI.Visible = true;
		for _,v in pairs(main.TopUI:GetChildren()) do
			if v:IsA("Frame") or v:IsA("ScrollingFrame") then
				v.Visible = false;
			end
		end
		main.TopUI.Credits.Visible = true;
		main.TopUI.Title.Text = "Credits";
	end
end)
main.Frame.Credits.ImageColor3 = Color3.new(1,1,1)

main.Frame.Settings.MouseButton1Click:Connect(function()
	if main.TopUI.Visible == true and main.TopUI.Settings.Visible == true then
		main.TopUI.Visible = false;
	else
		main.TopUI.Visible = true;
		for _,v in pairs(main.TopUI:GetChildren()) do
			if v:IsA("Frame") or v:IsA("ScrollingFrame") then
				v.Visible = false;
			end
		end
		main.TopUI.Settings.Visible = true;
		main.TopUI.Title.Text = "Settings";
	end
end)
main.Frame.Settings.ImageColor3 = Color3.new(1,1,1)

--[[
main.Frame.Chatlogs.MouseButton1Click:Connect(function()
	if main.TopUI.Visible == true and main.TopUI.Connection.Visible == true then
		main.TopUI.Visible = false;
	else
		main.TopUI.Visible = true;
		for _,v in pairs(main.TopUI:GetChildren()) do
			if v:IsA("Frame") or v:IsA("ScrollingFrame") then
				v.Visible = false;
			end
		end
		main.TopUI.Chatlogs.Visible = true;
		main.TopUI.Title.Text = "Chatlogs";
	end
end)
--]]

local lookingAtStarred = false
main.Frame.Starred.MouseButton1Click:Connect(function()
	lookingAtStarred = not lookingAtStarred
	if lookingAtStarred then
		for i,v in pairs(scroll:GetChildren()) do
			if v:IsA"TextButton" then
				v.Visible = (favs[v.Name] or v.Name == "_Favourites") 
			end
		end
	else
		for i,v in pairs(scroll:GetChildren()) do
			if v:IsA"TextButton" then
				v.Visible = (v.Name ~= "_Favourites")
			end
		end
	end
end)
main.Frame.Starred.ImageColor3 = Color3.new(1,1,1)

local s = main.TopUI.Settings
local trueI = "http://www.roblox.com/asset/?id=6031068421";
local falseI = "http://www.roblox.com/asset/?id=6031068420";
for sKey,Value in pairs(settings) do -- Build the settings thing
	if type(Value[2]) == "nil" then
		-- Skip
	elseif type(Value[2]) == "boolean" then
		local set = Assets:FindFirstChild("Setting_Boolean"):Clone();
		set.Parent = s;
		set.Name = sKey;
		if Value[3] then
			set.Txt.Text = Value[3]
		else
			set.Txt.Text = sKey;
		end
		if Value[4] and type(Value[4]) == "function" then
			Value[4](Value[2]);
		end
		set.Value.Value = Value[2]
		set.Btn.Image = (set.Value.Value and trueI or falseI)
		set.Btn.MouseButton1Click:Connect(function()
			set.Value.Value = not set.Value.Value
			set.Btn.Image = (set.Value.Value and trueI or falseI)
			bind:Fire("SettingChanged",{sKey,set.Value.Value});
		end)
		set.Visible = true;
	elseif type(Value[2]) == "string" then
		warn(-2,"Unsupported settings type: String [Key: "..sKey.."]");
		-- Skip: Unsupported yet
	elseif type(Value[2]) == "number" then
		warn(-2,"Unsupported settings type: Number [Key: "..sKey.."]");
		-- Skip: Unsupported yet
	elseif type(Value[2]) == "table" then
		if string.lower(Value[2][1]) == "color" then
			local set = Assets:FindFirstChild("Color"):Clone();
			set.Parent = s;
			set.Name = sKey;
			if Value[3] then
				set.Txt.Text = Value[3]
			else
				set.Txt.Text = sKey;
			end
			set.Value.Value = BrickColor.new(Value[2][2] or Color3.new(0, 0.666667, 1));
			set.Value.Changed:Connect(function(val)
				bind:Fire("SettingChanged",{sKey,{"color",set.Value.Value}});
				if Value[4] and type(Value[4]) == "function" then
					Value[4]({nil,set.Value.Value});
				end
			end)
			set.Visible = true;
		elseif string.lower(Value[2][1]) == "dropdown" then
			local set = Assets:FindFirstChild("CustomDropdown"):Clone();
			set.Parent = s;
			set.Name = sKey;
			if Value[3] then
				set.Txt.Text = Value[3]
			else
				set.Txt.Text = sKey;
			end
			set.TextButton.Text = Value[2][2].Default;
			for _,option in pairs(Value[2][2].Options) do
				local t = set.TextButton.Dropdown.ScrollingFrame.Template:Clone();
				t.Text = option;
				t.Name = option;
				t.Parent = set.TextButton.Dropdown.ScrollingFrame
				t.Visible = true;
			end
			set.Value.Value = Value[2][2].Default;
			set.Value.Changed:Connect(function(val)
				bind:Fire("SettingChanged",{sKey,{"dropdown",{Default = set.Value.Value, Options = Value[2][2].Options}}});
				if Value[4] and type(Value[4]) == "function" then
					Value[4](set.Value.Value);
				end
			end);
			set.Visible = true;
		else
			warn(-2,"Unsupported settings type: "..Value[2][1].." [Key: "..sKey.."]");
		end
		-- {truetype,data}
		-- Skip: Unsupported yet
	elseif type(Value[2]) == "userdata" then
		warn(-2,"Malformed settings type at "..sKey);
		-- Malformed type: If it's userdata, it should be in a table.
	end
end

-- Generate the game settings.
if remote:InvokeServer("HasPermission","Nano.GameSettings") then
	local button = NanoWorks:NewAsset("Button",{Name = "Open Game Settings", Color = Assets.Intro.BackgroundColor3});
	Assets.Intro:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		button.self.BackgroundColor3 = Assets.Intro.BackgroundColor3;
	end)
	
	button.self.Parent = s;
	button.self.LayoutOrder = 1;
	button.event:Connect(function()
		script.Parent.Settings.Visible = true;
	end)
	local function settingsRefresh()
		sendEvents = false;
		local sets = remote:InvokeServer("GetGameSettings"); -- double check moment?
		local plrs = remote:InvokeServer("GetSetting","Players"); -- oof
		local mods,modsactive = remote:InvokeServer("GetModSettings");
		
		if remote:InvokeServer("GetSetting","CloudAPI").Token.UseToken then
			script.Parent.Settings.API_Status.Visible = true;
			script.Parent.Settings.API_Status.Text = 'CloudAPI Status: <font color="#ff7700">Checking</font>'
			
			task.spawn(function()
				local s,val = pcall(function()
					return remote:InvokeServer("GetAPIStatus")
				end)
				
				if s then
					if val == true then
						script.Parent.Settings.API_Status.Text = 'CloudAPI Status: <font color="#00ff00">Active</font>'
					else
						script.Parent.Settings.API_Status.Text = 'CloudAPI Status: <font color="#ff4444">Inactive</font>'
					end
				else
					script.Parent.Settings.API_Status.Text = 'CloudAPI Status: <font color="#ff0000">Check failed</font>'
				end
			end)
			
		else
			script.Parent.Settings.API_Status.Visible = false;
		end
		
		-- returns;
		--[[
		
		Sets = {
			[Category] = {
				[Name] = {StoredValue}
			};
		}
		
		]]

		NanoWorks:ClearFrame(script.Parent.Settings.InnerHolder.Content.Admins);
		NanoWorks:ClearFrame(script.Parent.Settings.InnerHolder.Content.General);
		NanoWorks:ClearFrame(script.Parent.Settings.InnerHolder.Content.Mods);

		local function gameBubble(tbl,prev,parent,stack,name)
			for category:string,setting:any in pairs(tbl) do
				local bubble = NanoWorks:CreateBubble(category)
				bubble.self.Parent = parent
				bubble.self.Visible = true;
				bubble.self.Outer.BackgroundColor3 = Color3.new(1-(stack*0.2),0.33333-(stack*0.06666),0);
				if type(setting) == "table" then				
					gameBubble(setting,prev..category..".",bubble.self.Outer.Inner,stack+1,name);
				else
					bubble.self:Destroy();
					bubble = nil;
					local asset = nil;
					if type(setting) ~= "userdata" then
						asset = NanoWorks:NewAsset(type(setting),{Name = category,Default = setting});
					elseif typeof(setting) ~= "Color3" then -- For some reason it won't accept Color3 in the server.
						asset = NanoWorks:NewAsset(typeof(setting),{Name = category});
					end
					
					if asset then
						asset.self.Parent = parent;
						asset.event:Connect(function(newval)
							if sendEvents then
								remote:InvokeServer("SetGameSetting",{prev..category,newval})
							end
						end)
					elseif typeof(setting) == "Color3" then
						
					elseif type(setting) == "table" then
						gameBubble(setting,prev..category..".",parent,stack+1);
					end
				end
			end
		end

		local function permBubble(tbl,prev,parent,stack,name)
			NanoWorks:NewAsset("message",{Text = "Warning: Giving a '*' permission is dangerous! They can remove other's permissions too, regardless of immunity!",Color = Color3.new(1, 1, 0.498039)}).self.Parent = parent
			local res = remote:InvokeServer("GetSetting","Players");
			local availablegroups = remote:InvokeServer("GetSetting","FlagGroups");
			for k,v in pairs(res) do
				local bubble = nil;
				if v["UserId"] then
					local s,f = pcall(function()
						players:GetNameFromUserIdAsync(v.UserId);
					end)
					if s then
						bubble = NanoWorks:CreateBubble(players:GetNameFromUserIdAsync(v.UserId));
					else
						bubble = NanoWorks:CreateBubble(v.UserId);
						bubble:AddAsset("message",{Text = "Failed to fetch name.",Color = Color3.new(1, 0.266667, 0.266667)})
					end
				elseif v["Name"] then
					bubble = NanoWorks:CreateBubble(v.Name);
				elseif v["Group"] then
					-- That's a group thing :eyes:
					local group = game:GetService("GroupService"):GetGroupInfoAsync(v.Group);
					bubble = NanoWorks:CreateBubble("Group - "..group.Name);
					bubble:AddAsset("message",{Text = "Group editing is not (yet) supported. Sorry for the inconvenience."});
					bubble.self.Parent = parent
					continue
				elseif v["Gamepass"] then
					-- Gamepass thing :eyes:
					bubble = NanoWorks:CreateBubble("Gamepass ("..v.Gamepass..")");
					bubble:AddAsset("message",{Text = "Gamepass editing is not supported. Use a datastore editor instead."});
					bubble.self.Parent = parent
					continue
				elseif v["VIPOwner"] then
					bubble = NanoWorks:CreateBubble("VIP Server Owner");
					bubble:AddAsset("message",{Text = "VIP editing is not supported. Use a datastore editor instead."});
					bubble.self.Parent = parent
					continue
				elseif v["Default"] then
					bubble = NanoWorks:CreateBubble("Non-Admin / Default");
				else
					continue -- SINCE WHEN DID THIS EXIST?!
					-- Serious note: Skips anything that 
				end
				bubble.self.Name = k;
				bubble.self.Parent = parent;
				bubble.self.Visible = true;
				
				local vals = {
					Chat = false;
					UI = false;
					Flags = "";
					Key = "Non-Admin";
					Immunity = 1; -- Considering they're here, it SHOULD be at least 1.
				}
				
				if type(v.FlagGroup) == "table" then
					for var,val in pairs(v.FlagGroup) do
						vals[var] = val;
					end
					
					local chatp = bubble:AddAsset("Boolean",{Key = "Chat", Name = "Can use the Chat for commands", Default = vals.Chat});
					local uip = bubble:AddAsset("Boolean",{Key = "UI", Name = "Can use Nano's Panel", Default = vals.UI});
					local flagsp = bubble:AddAsset("String",{Key = "Flags", Name = "Permissions / Flags", Default = vals.Flags});
					local keyp = bubble:AddAsset("String",{Key = "Key", Name = "Custom Group Name", Default = vals.Key});
					local immunityp = bubble:AddAsset("Number",{Key = "Immunity", Name = "Immunity Level (0 - 255)", Default = vals.Immunity});
					local delete = bubble:AddAsset("Button",{Key = "Delete", Name = "Delete Administration Key", Color = Color3.new(1, 0.266667, 0.266667)})
					
					chatp.event:Connect(function(newval)
						vals.Chat = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),"Chat",newval})
						end
					end)
					uip.event:Connect(function(newval)
						vals.UI = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),"UI",newval})
						end
					end)
					flagsp.event:Connect(function(newval)
						vals.Flags = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),"Flags",newval})
						end
					end)
					keyp.event:Connect(function(newval)
						vals.Key = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),"Key",newval})
						end
					end)
					immunityp.event:Connect(function(newval)
						vals.Immunity = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),"Immunity",newval})
						end
					end)
					delete.event:Connect(function()
						if delete.self.Btn.Text == "Delete Administration Key" then
							delete.self.Btn.Text = "Are you sure? Click again to delete."
							task.spawn(function()
								task.wait(3)
								if delete.self.Btn.Text == "Are you sure? Click again to delete." then
									delete.self.Btn.Text = "Delete Administration Key"
								end
							end)
						elseif delete.self.Btn.Text == "Are you sure? Click again to delete." then
							delete.self.Btn.Text = "Delete request sent. Refresh the settings."
							remote:InvokeServer("DeletePlayerData",tonumber(k));
						end
					end)
				elseif type(v.FlagGroup) == "string" then
					local groups = {}
					for group,_ in pairs(availablegroups) do
						table.insert(groups,group);
					end
					
					local changer = bubble:AddAsset("CustomDropdown",{Name = "User FlagGroup"; Default = v.FlagGroup; Options = groups});
					changer.event:Connect(function(newval)
						vals.Flags = newval
						if sendEvents then
							remote:InvokeServer("SetPlayerData",{tonumber(k),newval})
						end
					end)
					
					local delete = bubble:AddAsset("Button",{Key = "Delete", Name = "Delete Administration Key", Color = Color3.new(1, 0.266667, 0.266667)})
					delete.event:Connect(function()
						if delete.self.Btn.Text == "Delete Administration Key" then
							delete.self.Btn.Text = "Are you sure? Click again to delete."
							task.spawn(function()
								task.wait(3)
								if delete.self.Btn.Text == "Are you sure? Click again to delete." then
									delete.self.Btn.Text = "Delete Administration Key"
								end
							end)
						elseif delete.self.Btn.Text == "Are you sure? Click again to delete." then
							delete.self.Btn.Text = "Delete request sent. Refresh the settings."
							remote:InvokeServer("DeletePlayerData",tonumber(k));
						end
					end)
				else
					bubble:AddAsset("message",{Text = "This user has a corrupted administration key.",Color = Color3.new(1, 0.266667, 0.266667)})
					local delete = bubble:AddAsset("Button",{Key = "Delete", Name = "Delete Administration Key", Color = Color3.new(1, 0.266667, 0.266667)})
					delete.event:Connect(function()
						if delete.self.Btn.Text == "Delete Administration Key" then
							delete.self.Btn.Text = "Are you sure? Click again to delete."
							task.spawn(function()
								task.wait(3)
								if delete.self.Btn.Text == "Are you sure? Click again to delete." then
									delete.self.Btn.Text = "Delete Administration Key"
								end
							end)
						elseif delete.self.Btn.Text == "Are you sure? Click again to delete." then
							delete.self.Btn.Text = "Delete request sent. Refresh the settings."
							remote:InvokeServer("DeletePlayerData",tonumber(k));
						end
					end)
				end
			end
			
			local bubble = NanoWorks:CreateBubble("Create New Key")
			bubble.self.Name = "newmember";
			bubble.self.Parent = parent;
			bubble.self.Visible = true;
			
			local groups = {"Custom"};
			for k,_ in pairs(availablegroups) do
				table.insert(groups,k);
			end
			
			local useridf = bubble:AddAsset("String",{Key = "useridf", Name = "Player Identifier (Username | ID)"});
			local groupf = bubble:AddAsset("CustomDropdown",{Name = "User FlagGroup"; Default = "Custom"; Options = groups});
			local btn = bubble:AddAsset("Button",{Key = "create",Name = "Click here to create the new key!", Color = Color3.new(1, 0.333333, 0)});
			
			local debounce = false;
			btn.event:Connect(function()
				if debounce then return end;
				debounce = true;
				task.spawn(function()
					task.wait(10);
					debounce = false;
				end)
				
				remote:InvokeServer("NewPlayerData",useridf.self.Value.Value,groupf.self.Value.Value);
			end)
		end

		local function modsBubble(tbl,prev,parent,stack,name)
			for category:string,setting:any in pairs(tbl) do
				local bubble = NanoWorks:CreateBubble(category)
				bubble.self.Parent = parent
				bubble.self.Visible = true;
				bubble.self.Outer.BackgroundColor3 = Color3.new(1-(stack*0.2),0.33333-(stack*0.06666),0);
				if type(setting) == "table" then				
					gameBubble(setting,prev..category..".",bubble.self.Outer.Inner,stack+1,name);
				else
					bubble.self:Destroy();
					bubble = nil;
					local asset;
					if string.split(category,"")[1] == "_" then
						asset = NanoWorks:NewAsset("message",{Text = category..": "..setting});
					else
						asset = NanoWorks:NewAsset(type(setting),{Name = category,Default = setting});
					end
					if asset then
						asset.self.Parent = parent;
						asset.event:Connect(function(newval)
							remote:InvokeServer("SetGameSetting",{prev..category,newval})
						end)
					elseif type(setting) == "table" then
						gameBubble(setting,prev..category..".",parent,stack+1);
					end
				end
			end
		end

		gameBubble(sets,"",script.Parent.Settings.InnerHolder.Content.General,0)
		permBubble(plrs,"Players.",script.Parent.Settings.InnerHolder.Content.Admins,0)
		modsBubble(mods,"",script.Parent.Settings.InnerHolder.Content.Mods,0)

		script.Parent.Settings.InnerHolder.Categories.General.MouseButton1Click:Connect(function()
			script.Parent.Settings.InnerHolder.Content.General.Visible = true;
			script.Parent.Settings.InnerHolder.Content.Admins.Visible = false;
			script.Parent.Settings.InnerHolder.Categories.General.BackgroundColor3 = Color3.fromRGB(255, 85, 0);
			script.Parent.Settings.InnerHolder.Categories.Admins.BackgroundColor3 = Color3.fromRGB(77,77,77);
			if modsactive >= 1 then
				script.Parent.Settings.InnerHolder.Categories.Mods.BackgroundColor3 = Color3.fromRGB(77,77,77)
				script.Parent.Settings.InnerHolder.Content.Mods.Visible = false;
			end
		end)
		script.Parent.Settings.InnerHolder.Categories.Admins.MouseButton1Click:Connect(function()
			script.Parent.Settings.InnerHolder.Content.General.Visible = false;
			script.Parent.Settings.InnerHolder.Content.Admins.Visible = true;
			script.Parent.Settings.InnerHolder.Categories.General.BackgroundColor3 = Color3.fromRGB(77, 77, 77);
			script.Parent.Settings.InnerHolder.Categories.Admins.BackgroundColor3 = Color3.fromRGB(255, 85, 0);
			if modsactive >= 1 then
				script.Parent.Settings.InnerHolder.Categories.Mods.BackgroundColor3 = Color3.fromRGB(77,77,77)
				script.Parent.Settings.InnerHolder.Content.Mods.Visible = false;
			end
		end)

		if modsactive >= 1 then
			script.Parent.Settings.InnerHolder.Categories.Mods.BackgroundColor3 = Color3.fromRGB(77,77,77)
			script.Parent.Settings.InnerHolder.Categories.Mods.MouseButton1Click:Connect(function()
				script.Parent.Settings.InnerHolder.Content.General.Visible = false;
				script.Parent.Settings.InnerHolder.Content.Admins.Visible = false;
				script.Parent.Settings.InnerHolder.Content.Mods.Visible = true;
				script.Parent.Settings.InnerHolder.Categories.General.BackgroundColor3 = Color3.fromRGB(77, 77, 77);
				script.Parent.Settings.InnerHolder.Categories.Admins.BackgroundColor3 = Color3.fromRGB(77, 77, 77);
				script.Parent.Settings.InnerHolder.Categories.Mods.BackgroundColor3 = Color3.fromRGB(255,85,0);
			end)
		end
		sendEvents = true;
	end

	settingsRefresh();
	script.Parent.Settings.InnerHolder.Categories.Refresh.MouseButton1Click:Connect(function()
		settingsRefresh();
	end)
else
	script.Parent.Settings:Destroy();
end

main.Frame.Chatlogs.MouseButton1Click:Connect(function()
	local response = remote:InvokeServer("GetChatlogs");
	NanoWorks:ClearFrame(main.TopUI.Chatlogs);
	if type(response) == "boolean" then
		if response == false then
			NanoWorks:NewAsset("message",{Text = "You don't have permission to see chatlogs!",Color = Color3.new(1, 1, 1)}).self.Parent = main.TopUI.Chatlogs
		end
	elseif type(response) == "table" then
		for k,v in ipairs(response) do
			if k > 100 then
				break;
			end
			
			NanoWorks:NewAsset("message",{Text = os.date("%X",v[1]).. " | "..game:GetService("Players"):GetNameFromUserIdAsync(v[2]).." | "..v[3]}).self.Parent = main.TopUI.Chatlogs;
		end
	end
	
	if main.TopUI.Visible == true and main.TopUI.Chatlogs.Visible == true then
		main.TopUI.Visible = false;
	else
		main.TopUI.Visible = true;
		for _,v in pairs(main.TopUI:GetChildren()) do
			if v:IsA("Frame") or v:IsA("ScrollingFrame") then
				v.Visible = false;
			end
		end
		main.TopUI.Chatlogs.Visible = true;
		main.TopUI.Title.Text = "Chatlogs";
	end
end)
main.Frame.Chatlogs.ImageColor3 = Color3.new(1,1,1);

main.Frame.Errorlogs.MouseButton1Click:Connect(function()
	local response = remote:InvokeServer("GetErrorlogs");
	NanoWorks:ClearFrame(main.TopUI.Chatlogs);
	if type(response) == "boolean" then
		if response == false then
			NanoWorks:NewAsset("message",{Text = "You don't have permission to see errorlogs!",Color = Color3.new(1, 1, 1)}).self.Parent = main.TopUI.Errorlogs;
		end
	elseif type(response) == "table" then
		for k,v in ipairs(response) do
			if k > 100 then
				break;
			end

			NanoWorks:NewAsset("message",{Text = os.date("%X",v[1]).. " | "..v[2]}).self.Parent = main.TopUI.Errorlogs;
		end
	end

	if main.TopUI.Visible == true and main.TopUI.Errorlogs.Visible == true then
		main.TopUI.Visible = false;
	else
		main.TopUI.Visible = true;
		for _,v in pairs(main.TopUI:GetChildren()) do
			if v:IsA("Frame") or v:IsA("ScrollingFrame") then
				v.Visible = false;
			end
		end
		main.TopUI.Errorlogs.Visible = true;
		main.TopUI.Title.Text = "Errorlogs";
	end
end)
main.Frame.Errorlogs.ImageColor3 = Color3.new(1,1,1);

--Check if any button is loaded improperly and mark them as red; Likely because they weren't scripted.
for _,v in pairs(main.Frame:GetChildren()) do
	if v:IsA("ImageButton") then
		if v.ImageColor3 ~= Color3.new(1,1,1) then
			v.ImageColor3 = Color3.new(1, 0.266667, 0.266667);
			warn("Improper scripting for the "..v.Name.." button! Button set as inactive.");
		end
	end
end

--Initial ping update
local starttick = tick();
local res = math.floor(math.abs(tick() - starttick) * 1000)
remote:InvokeServer("PingRes",res) -- Let the server know what ping the player is at.
main.Ping.ms.Text = tostring(res).."ms"

task.spawn(function()
	while task.wait(2) do -- PINGER
		local starttick = os.clock();
		local reply = remote:InvokeServer("PingTest");
		local rawres = math.abs(os.clock() - starttick) * 1000;
		local res = math.floor(rawres)
		remote:InvokeServer("PingRes",res) -- Let the server know what ping the player is at.
		main.Ping.ms.Text = tostring(res).."ms"
		-- Get image by category; Low, Med, High or V.High
		if res >= 1000 then
			main.Ping.ms.Text = ">999ms"
			main.Ping.ImageColor3 = Color3.new(0.470588, 0, 0)
		elseif res >= 500 then -- Critically High
			main.Ping.Image = "rbxassetid://9189318676"
			main.Ping.ImageColor3 = Color3.new(0.666667,0,0)
		elseif res >= 350 then -- Very High
			main.Ping.Image = "rbxassetid://9189318676"
			main.Ping.ImageColor3 = Color3.new(1,0.266667,0.266667)
		elseif res >= 200 then -- High
			main.Ping.Image = "rbxassetid://9189319364"
			main.Ping.ImageColor3 = Color3.new(1,0.666667,0.2)
		elseif res >= 125 then -- Medium
			main.Ping.Image = "rbxassetid://9189318742"
			main.Ping.ImageColor3 = Color3.new(1,1,0.498039)
		elseif res <= 50 then -- Very Low
			main.Ping.Image = "rbxassetid://9189319213"
			main.Ping.ImageColor3 = Color3.new(0.635294,1,0.909804)
		else -- Low
			main.Ping.Image = "rbxassetid://9189319213"
			main.Ping.ImageColor3 = Color3.new(1,1,1)
		end
		
		-- Get errors and chatlogs from the server.
		
	end
end)