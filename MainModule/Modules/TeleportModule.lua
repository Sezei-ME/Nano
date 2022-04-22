local module = {}

local tween_service = game:GetService("TweenService")

local tween_info = TweenInfo.new(
	0.5, 
	Enum.EasingStyle.Sine, 
	Enum.EasingDirection.Out, 
	0, 
	true,
	0
)

local teleport_effect_enabled = false

function module.teleport_effect(target_player_1: any, target_player_2: any)

	local new_teleport_effect = script.Effect:Clone()
	new_teleport_effect.CFrame = target_player_1.Character.PrimaryPart.CFrame
	new_teleport_effect.Parent = workspace
	local new_tween_effect_1 = tween_service:Create(new_teleport_effect, tween_info, {Size = Vector3.new(13, 13, 13)})

	local new_teleport_effect = script.Effect:Clone()
	new_teleport_effect.CFrame = target_player_2.Character.PrimaryPart.CFrame
	new_teleport_effect.Parent = workspace
	local new_tween_effect_2 = tween_service:Create(new_teleport_effect, tween_info, {Size = Vector3.new(13, 13, 13)})
	
	local new_teleport_effect = script.Effect:Clone()
	new_teleport_effect.CFrame = target_player_2.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -3)
	new_teleport_effect.Parent = workspace
	local new_tween_effect_3 = tween_service:Create(new_teleport_effect, tween_info, {Size = Vector3.new(13, 13, 13)})
	
	if teleport_effect_enabled == true then
		local new_teleport_sound = script.Teleport:Clone()
		new_teleport_sound.Parent = target_player_1.Character
		new_teleport_sound:Play()

		new_teleport_sound.Ended:Connect(function()
			new_teleport_sound:Destroy()
		end)

		local new_teleport_sound = script.Teleport:Clone()
		new_teleport_sound.Parent = target_player_2.Character
		new_teleport_sound:Play()

		new_teleport_sound.Ended:Connect(function()
			new_teleport_sound:Destroy()
		end)
		new_tween_effect_1:Play()
		new_tween_effect_2:Play()
		wait(0.25)
		new_tween_effect_3:Play()
	end

	target_player_1.Character.HumanoidRootPart.CFrame = target_player_2.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3) * CFrame.Angles(0, math.rad(180), 0)

	new_tween_effect_1.Completed:Connect(function()
		new_teleport_effect:Destroy()
		new_teleport_effect:Destroy()
	end)

end

return module
