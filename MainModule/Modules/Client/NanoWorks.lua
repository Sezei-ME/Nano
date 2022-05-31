-- It has been added mainly for beta 2 of Nano. Feel free to use it for your own stuff, i don't mind :ok_hand:

local assets = script.Parent:FindFirstChild("Assets")

local module = {}

local function isBright(color:Color3)
	local brightness = (color.R * 0.45) + (color.G * 0.65) + (color.B * 0.55);
	if brightness >= 1 then
		return true
	else
		return false
	end
end

function module:FullClear(frame:Instance)
	for _,item in pairs(frame:GetChildren()) do
		item:Destroy();
	end
end

function module:ClearFrame(frame:Instance)
	for _,item in pairs(frame:GetChildren()) do
		if item:IsA("Frame") or item:IsA("ScrollingFrame") or item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("ImageButton") or item:IsA("ImageLabel") then
			item:Destroy();
		end
	end
end

function module:NewAsset(typ,options)
	if not options then options = {} end
	if string.lower(typ) == "button" then
		local asset = assets.Button:Clone()
		asset.Name = options.Key or options.Name or typ;
		if options.Name then
			asset.Btn.Text = options.Name or ""
		end
		if options.Color then
			asset.Btn.BackgroundColor3 = options.Color
			if isBright(options.Color) then
				asset.Btn.TextColor3 = Color3.new(0,0,0);
			else
				asset.Btn.TextColor3 = Color3.new(1,1,1);
				asset.Btn.TextStrokeTransparency = 0.7;
			end
		end
		asset.Visible = true;
		return {self = asset, event = asset.Btn.MouseButton1Click}
	elseif string.lower(typ) == "command" then
		local asset = assets.CommandButton:Clone()
		asset.Name = options.Key;
		asset.Text = options.Text;
		asset:SetAttribute("Category",options.Category);
		asset.HoverHint.Value = options.Hint or "";
		asset.decoration.BackgroundColor3 = options.Color or Color3.new(math.random(),math.random(),math.random());
		asset.decoration.Frame.BackgroundColor3 = asset.decoration.BackgroundColor3;
		asset.Visible = true;
		return {self = asset, event = asset.MouseButton1Click}
	elseif string.lower(typ) == "message" or string.lower(typ) == "description" then
		local asset = assets.Description:Clone()
		asset.Name = options.Key or options.Name or typ;
		if options.Text then
			asset.Txt.Text = options.Text or ""
		end
		if options.Color then
			asset.Txt.TextColor3 = options.Color
		end
		asset.Visible = true;
		return {self = asset};
	elseif string.lower(typ) == "playerdropdown" then
		local asset = assets.Player_Dropdown:Clone();
		asset.Name = options.Key or options.Name or typ;
		asset.Txt.Text = options.Text or options.Name;
		local num = (#game:GetService("Players"):GetPlayers() * 20) - 2
		for _,plr in pairs(game:GetService("Players"):GetPlayers()) do
			local choice = asset.TextButton.Dropdown.ScrollingFrame.Template:Clone();
			choice.Parent = asset.TextButton.Dropdown.ScrollingFrame;
			choice.Name = plr.Name;
			if plr.DisplayName ~= plr.Name then
				choice.Text = plr.DisplayName.." (@"..plr.Name..")";
			else
				choice.Text = "@"..plr.Name;
			end
			choice.Visible = true;
		end
		asset.TextButton.Dropdown.Size = UDim2.new(1,0,0,math.clamp(num,18,80));
		asset.TextButton.Dropdown.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,num);
		asset.Visible = true;
		return {self = asset; event = asset.Value.Changed};
	elseif string.lower(typ) == "customdropdown" then
		local asset = assets.CustomDropdown:Clone();
		asset.Name = options.Key or options.Name or typ;
		asset.Txt.Text = options.Text or options.Name;
		if options.Default then
			asset.Value.Value = options.Default;
			asset.TextButton.Text = options.Default;
		end
		local num = (#options.Options * 20) - 2
		for _,ch in pairs(options.Options) do
			local choice = asset.TextButton.Dropdown.ScrollingFrame.Template:Clone();
			choice.Parent = asset.TextButton.Dropdown.ScrollingFrame
			choice.Name = ch;
			choice.Text = ch;
			choice.Visible = true;
		end
		asset.TextButton.Dropdown.Size = UDim2.new(1,0,0,math.clamp(num,18,80))
		asset.TextButton.Dropdown.ScrollingFrame.CanvasSize = UDim2.new(0,0,0,num);
		asset.Visible = true;
		return {self = asset; event = asset.Value.Changed};
	elseif string.lower(typ) == "boolean" then
		local asset = assets.Boolean:Clone()
		asset.Name = options.Key or options.Name or typ;
		if options.Name then
			asset.Txt.Text = options.Name or ""
		end
		if options.Default then
			asset.Value.Value = options.Default;
			asset.Btn.Image = (options.Default and "http://www.roblox.com/asset/?id=6031068421" or "http://www.roblox.com/asset/?id=6031068420");
		end
		asset.Visible = true;
		return {self = asset, event = asset.Value.Changed}
	elseif string.lower(typ) == "color3" then
		local asset = assets.Color3:Clone()
		asset.Name = options.Key or options.Name or typ;
		if options.Name then
			asset.Txt.Text = options.Name or ""
		end
		asset.Visible = true;
		return {self = asset, event = asset.Value.Changed}
	elseif string.lower(typ) == "color" then
		local asset = assets.Color:Clone()
		asset.Name = options.Key or options.Name or typ;
		if options.Name then
			asset.Txt.Text = options.Name or ""
		end
		asset.Visible = true;
		return {self = asset, event = asset.Value.Changed}
	elseif string.lower(typ) == "string" or string.lower(typ) == "number" then
		local asset = assets.Msg:Clone();
		asset.Name = options.Key or options.Name or typ;
		if string.lower(typ) == "number" then
			asset.TextBox.PlaceholderText = "number"
		end
		if options.Name then
			asset.Txt.Text = options.Name or ""
		end
		if options.Default then
			asset.TextBox.Text = options.Default
		end
		asset.Visible = true;
		return {self = asset, event = asset.Value.Changed}
	elseif string.lower(typ) == "slider" then
		local asset = assets.Slider:Clone();
		asset.Name = options.Key or options.Name or typ;
		asset.Txt.Text = options.Name or typ;
		if options.Maximum then
			asset.Max.Value = options.Maximum;
		else
			asset.Max.Value = 100;
		end
		if options.Minimum then
			asset.Min.Value = options.Minimum;
			asset.Value.Value = options.Minimum;
			asset.TextLabel.Text = tonumber(options.Minimum);
		else
			asset.Min.Value = 0;
		end
		asset.Visible = true;
		return {self = asset; event = asset.Value.Changed}
	else
		local s, rtrn = pcall(function()
			local asset = Instance.new(typ);
			asset.Name = options.Key or options.Name or typ;
			return asset
		end)
		if not s then
			warn(rtrn);
		end
		return {self = rtrn}
	end
end

function module:CreateBubble(name)
	local bubble = {}
	
	bubble.self = assets.Bubble:Clone();
	if name then
		bubble.self.Outer.Inner.Title.TextLabel.Text = name
	else
		bubble.self.Outer.Inner.Title.Visible = false;
	end
	function bubble:Insert(asset:Instance)
		asset.Parent = bubble.self.Outer.Inner
	end
	function bubble:AddAsset(typ,options)
		local asset = module:NewAsset(typ,options);
		bubble:Insert(asset);
		asset.self.Visible = true;
		return asset
	end
	
	bubble.self.Outer.Inner.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		bubble.self.Size = UDim2.new(1,-10,0,bubble.self.Outer.Inner.UIListLayout.AbsoluteContentSize.Y+12);
	end)
	
	bubble.self.Visible = true;
	
	function bubble:getn()
		return ((#bubble.self.Outer.Inner:GetChildren())-2)
	end
	
	return bubble
end

return module
