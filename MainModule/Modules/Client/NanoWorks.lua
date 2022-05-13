-- This is a module made for the UI framework of Nano. For now, it only manages Game Settings stuff.
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

		if options.Name then
			asset.Btn.Text = options.Name
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
	elseif string.lower(typ) == "message" then
		local asset = assets.Description:Clone()
		
		if options.Text then
			asset.Txt.Text = options.Text
		end
		
		if options.Color then
			asset.Txt.TextColor3 = options.Color
		end
		
		asset.Visible = true;
		
		return {self = asset};
	elseif string.lower(typ) == "boolean" then
		local asset = assets.Boolean:Clone()
		
		if options.Name then
			asset.Txt.Text = options.Name
		end
		
		if options.Default then
			asset.Value.Value = options.Default;
			asset.Btn.Image = (options.Default and "http://www.roblox.com/asset/?id=6031068421" or "http://www.roblox.com/asset/?id=6031068420");
		end
		
		asset.Visible = true;
		
		return {self = asset, event = asset.Value.Changed}
	elseif string.lower(typ) == "string" or string.lower(typ) == "number" then
		local asset = assets.Msg:Clone();
		
		if string.lower(typ) == "number" then
			asset.TextBox.PlaceholderText = "number"
		end
		
		if options.Name then
			asset.Txt.Text = options.Name
		end
		
		if options.Default then
			asset.TextBox.Text = options.Default
		end
		
		asset.Visible = true;
		
		return {self = asset, event = asset.Value.Changed}
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
