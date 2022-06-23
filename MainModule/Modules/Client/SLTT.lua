local SLTT = {}

function SLTT:Smoothify(Text:string,UI:TextLabel,ScrollSpeed:number)
	UI.Text = tostring(Text)
	if UI.TextFits == false then
		local frame = Instance.new("Frame",UI)
		frame.Size = UDim2.new(1,0,1,0)
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = UI.BackgroundColor3
		frame.ZIndex = 2
		local UIGradient = Instance.new("UIGradient",frame)
		UIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0),
			NumberSequenceKeypoint.new(.1,1),
			NumberSequenceKeypoint.new(.25,1),
			NumberSequenceKeypoint.new(.75,1),
			NumberSequenceKeypoint.new(.9,1),
			NumberSequenceKeypoint.new(1,0)
		})
		local textlabel = Instance.new("TextLabel",UI)
		textlabel.BackgroundTransparency = UI.BackgroundTransparency
		textlabel.TextTransparency = 0
		textlabel.TextColor3 = UI.TextColor3
		textlabel.Font = UI.Font
		textlabel.Text = Text.." "..Text
		textlabel.RichText = true
		textlabel.TextSize = UI.TextSize
		textlabel.TextWrapped = false
		textlabel.Size = UDim2.new(0,textlabel.TextBounds.X,1,0)
		UI.Text = ""
		UI.ClipsDescendants = true
		repeat 
			textlabel.Position = UDim2.new(0,-((textlabel.TextBounds.X/2)-UI.AbsoluteSize.X),0,0)
			textlabel:TweenPosition(UDim2.new(0,-(textlabel.TextBounds.X-UI.AbsoluteSize.X),0,0),"Out","Linear",ScrollSpeed)
			task.wait(ScrollSpeed)
		until self.Cancel
	end
end

return SLTT