local module = {}

-- << VARIABLES >>
local humanoidDescriptions = {}
local accessoryTypes = {
	[8] = "HatAccessory",
	[41] = "HairAccessory",
	[42] = "FaceAccessory",
	[43] = "NeckAccessory",
	[44] = "ShouldersAccessory",
	[45] = "FrontAccessory",
	[46] = "BackAccessory",
	[47] = "WaistAccessory",
}
local correspondingBodyParts = {
	["Torso"]		= {"UpperTorso","LowerTorso"};
	["Left Arm"] 	= {"LeftHand","LeftLowerArm","LeftUpperArm"};
	["Right Arm"]	= {"RightHand","RightLowerArm","RightUpperArm"};
	["Left Leg"]	= {"LeftFoot","LeftLowerLeg","LeftUpperLeg"};
	["Right Leg"]	= {"RightFoot","RightLowerLeg","RightUpperLeg"};
}


-- << FUNCTIONS >>

function module:GetChar(plr)
	if plr then
		return plr.Character
	end
end

function module:GetHRP(plr)
	if plr and plr.Character then
		local head = plr.Character:FindFirstChild("HumanoidRootPart")
		return head
	end
end

function module:GetHumanoid(plr)
	if plr and plr.Character then
		local humanoid = plr.Character:FindFirstChild("Humanoid")
		return humanoid
	end
end

function module:CheckBodyPart(part)
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and string.sub(part.Name,1,4) ~= "Fake" then
		return true
	else
		return false
	end
end

function module:GetHead(plr) print"got head"
	if plr and plr.Character then
		local head = plr.Character:FindFirstChild("Head")
		return head
	end
end

function module:GetName(plr) print"got name"
	for a,b in pairs(plr.Character:GetChildren()) do
		if b:IsA("Model") and b:FindFirstChild("FakeHumanoid") then
			return b
		end
	end
end

function module:SetName(plr, name) print"rawr"
	local head = module:GetHead(plr)
	if head then
		local fakename = module:GetName(plr)
		if not fakename then
			fakename = Instance.new("Model")
			local fakeHead = head:Clone()
			fakeHead.Name = "Head"
			fakeHead.Parent = fakename
			fakeHead.face.Transparency = 1
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = fakeHead
			weld.Part1 = head
			weld.Parent = fakeHead
			local fakeHumanoid = Instance.new("Humanoid")
			fakeHumanoid.Name = "FakeHumanoid"
			fakeHumanoid.Parent = fakename
			fakename.Parent = plr.Character
			head.Transparency = 1
		end
		if name then
			fakename.Name = name
		end
	end
end

function module:ResetName(plr)
	local head = module:GetHead(plr)
	local fakename = module:GetName(plr)
	if head and fakename then
		fakename:Destroy()
		head.Transparency = 0
	end
end

function module:CreateClone(character)
	local humanoid = character:FindFirstChild("Humanoid")
	if humanoid then

		--Setup clone
		character.Archivable = true
		local clone = character:Clone()
		local cloneHumanoid = clone.Humanoid
		clone.Name = character.Name.."'s NANOClone"
		local specialChar = false
		if clone:FindFirstChild("Chest") then
			specialChar = true
		end
		for a,b in pairs(clone:GetDescendants()) do
			if b:IsA("Humanoid") then
				b.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			elseif b:IsA("BillboardGui") then
				b:Destroy()
			elseif b:IsA("Weld") and b.Part1 ~= nil then
				b.Part0 = b.Parent
				if clone:FindFirstChild(b.Part1.Name) then
					b.Part1 = clone[b.Part1.Name]
				elseif not specialChar then
					b:Destroy()
				end
			end
		end

		--Make clone visible
		--module:SetTransparency(clone, 0)
		clone.Parent = workspace

		--Animations
		local tracks = {}
		local desc = humanoid:GetAppliedDescription()
		local animate = clone:FindFirstChild("Animate")
		if animate then
			for i,v in pairs(clone.Animate:GetChildren()) do
				local anim = (v:GetChildren()[1])
				if anim then
					--anim.Parent = clone
					tracks[v.Name] = cloneHumanoid:LoadAnimation(anim)
				end
			end
			tracks.idle:Play()
		end

		return clone, tracks
	end

end

function module:SetTransparency(model, value, force)
	local plr = game.Players:GetPlayerFromCharacter(model)
	local fakeParts = false
	if model:FindFirstChild("FakeHead") then
		fakeParts = true
	end
	for a,b in pairs(model:GetDescendants()) do
		if (b:IsA("BasePart") and b.Name ~= "HumanoidRootPart") or (b.Name == "face" and b:IsA("Decal")) then
			local ot = b:FindFirstChild("OriginalTransparency")
			if value == 1 and b.Transparency ~= 0 and not ot then
				ot = Instance.new("IntValue")
				ot.Name = "OriginalTransparency"
				ot.Value = b.Transparency
				ot.Parent = b
			elseif value == 0 and ot then
				b.Transparency = ot.Value
				ot:Destroy()
			elseif not fakeParts or model:FindFirstChild(b.Name.."Fake") == nil then
				b.Transparency = value
			end
		elseif (b:IsA("ParticleEmitter") and b.Name == "BodyEffect") or b:IsA("PointLight") or b:IsA("BillboardGui") then
			if value == 1 then
				b.Enabled = false
			elseif value == 0 then
				b.Enabled = true
			end
		elseif b:IsA("BillboardGui") then
			if value == 1 then
				b.Enabled = false
			elseif value == 0 then
				b.Enabled = true
			end
		end
	end
end

function module:SetFakeBodyParts(char, info)
for a,b in pairs(char:GetChildren()) do
	if module:CheckBodyPart(b) then
		local fakePart = module:CreateFakeBodyPart(char, b)
		for pName, pValue in pairs(info) do
			if pName == "Material" then
				fakePart.Material = pValue
				if pValue == Enum.Material.Glass then
					fakePart.Transparency = 0.5
				else
					fakePart.Transparency = 0
				end
			elseif pName == "Reflectance" then
				fakePart.Reflectance = pValue
			elseif pName == "Transparency" then
				fakePart.Transparency = pValue
			elseif pName == "Color" then
				fakePart.Color = pValue
			end
		end
	end
end
end

function module:ConvertRig(plr, rig_type)
	local character = plr.Character or plr.CharacterAdded:Wait()
	local head = character.Head
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and head then
		local newRig = script:FindFirstChild("Rig"..rig_type):Clone()
		local newHumanoid = newRig.Humanoid
		local originalCFrame = head.CFrame
		newRig.Name = plr.Name
		for a,b in pairs(plr.Character:GetChildren()) do
			if b:IsA("Accessory") or b:IsA("Pants") or b:IsA("Shirt") or b:IsA("ShirtGraphic") or b:IsA("BodyColors") then
				b.Parent = newRig
			elseif b.Name == "Head" and b:FindFirstChild("face") then
				newRig.Head.face.Texture = b.face.Texture
			end
		end
		plr.Character = newRig
		newRig.Parent = workspace
		newRig.Head.CFrame = originalCFrame
	end
end

function module:UpdateHipHeight(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local leftFoot = character:FindFirstChild("LeftFoot")
		if leftFoot then
			humanoid:BuildRigFromAttachments()
		else
			humanoid.HipHeight = 0
		end
	end
end
function module:ChangeAllBodyColors(plr, newColor)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:GetAppliedDescription()
		desc.HeadColor = newColor
		desc.LeftArmColor = newColor
		desc.RightArmColor = newColor
		desc.LeftLegColor = newColor
		desc.RightLegColor = newColor
		desc.TorsoColor = newColor
		pcall(function() humanoid:ApplyDescription(desc) end)
		if plr.Character:FindFirstChild("FakeHead") then
			for a,b in pairs(plr.Character:GetChildren()) do
				if string.sub(b.Name,1,4) == "Fake" and b:IsA("BasePart") then
					b.Color = newColor
				end
			end
		end
	end
end

function module:ChangeProperty(plr, propertyName, propertyValue)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:GetAppliedDescription()
		desc[propertyName] = propertyValue
		pcall(function() humanoid:ApplyDescription(desc) end)
	end
end

function module:ChangeProperties(plr, properties)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		for a,b in pairs(humanoid:GetChildren()) do
			local targetName = string.lower(b.Name)
			for propName, propValue in pairs(properties) do
				propName = string.lower(propName)
				if string.sub(targetName, -#propName) == propName then
					b.Value = propValue
					break
				end
			end
		end
	end
end

function module:ClearProperty(plr, propertyName)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:GetAppliedDescription()
		desc[propertyName] = ""
		pcall(function() humanoid:ApplyDescription(desc) end)
	end
end

function module:ResetProperty(plr, propertyName)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local mainDesc = game.Players:GetHumanoidDescriptionFromUserId(plr.UserId)
		local desc = humanoid:GetAppliedDescription()
		desc[propertyName] = mainDesc[propertyName]
		pcall(function() humanoid:ApplyDescription(desc) end)
	end
end

function module:SetScale(plr, scaleType, scaleValue)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:GetAppliedDescription()
		desc[scaleType.."Scale"] = scaleValue
		pcall(function() humanoid:ApplyDescription(desc) end)
	end
end

function module:AddAccessory(plr, accessoryId)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local info = game:GetService("MarketplaceService"):GetProductInfo(accessoryId)
		if info.AssetTypeId then
			local propertyName = accessoryTypes[info.AssetTypeId]
			if propertyName and info.AssetTypeId then
				local desc = humanoid:GetAppliedDescription()
				desc[propertyName] = desc[propertyName]..","..accessoryId
				pcall(function() humanoid:ApplyDescription(desc) end)
			end
		end
	end
end

function module:ClearAccessories(plr)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local desc = humanoid:GetAppliedDescription()
		for i,v in pairs(accessoryTypes) do
			desc[v] = ""
		end
		desc.HatAccessory = ""
		pcall(function() humanoid:ApplyDescription(desc) end)
	end
end

function module:CreateFakeBodyPart(character, bodyPart)
	local fakePartName = "Fake"..bodyPart.Name
	local fakePart = character:FindFirstChild(fakePartName)
	if not fakePart then
		local mesh = bodyPart:FindFirstChildOfClass("SpecialMesh")
		if bodyPart.Name == "Head" and mesh then
			if mesh.MeshType == Enum.MeshType.Head then
				fakePart = script:FindFirstChild("FakeHead"):Clone()
				local size = bodyPart.Size
				local scaleUp = mesh.Scale.Y/1.25
				fakePart.Size = Vector3.new(size.X*0.6*scaleUp, size.Y*1.2*scaleUp, size.Z*1.19*scaleUp)
				fakePart.CFrame = bodyPart.CFrame * CFrame.new(0, mesh.Offset.Y, 0)
			else
				fakePart = bodyPart:Clone()
				fakePart:ClearAllChildren()
				mesh:Clone().Parent = fakePart
			end
		else
			fakePart = bodyPart:Clone()
			fakePart:ClearAllChildren()
		end
		fakePart.CanCollide = false
		fakePart.Name = "Fake"..bodyPart.Name
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = fakePart
		weld.Part1 = bodyPart
		weld.Parent = fakePart
		bodyPart.Transparency = 1
		fakePart.Parent = character
	end
	fakePart.Color = bodyPart.Color
	return fakePart
end

function module:ClearFakeBodyParts(character)
	for a,b in pairs(character:GetChildren()) do
		if b:IsA("BasePart") then
			if string.sub(b.Name, 1, 4) == "Fake" then
				b:Destroy()
			elseif b.Name ~= "HumanoidRootPart" then
				b.Transparency = 0
			end
		end
	end
end

function module:SetHeadMeshSize(plr, scale)
	local head = plr.Character:FindFirstChild("Head")
	if head then
		local mesh = head:FindFirstChildOfClass("SpecialMesh")
		if mesh then
			local osize = mesh:FindFirstChild("OriginalSize")
			if not osize then
				osize = Instance.new("Vector3Value")
				osize.Name = "OriginalSize"
				osize.Value = mesh.Scale
				osize.Parent = mesh
			end
			module:ClearAccessories(plr)
			mesh.Scale = Vector3.new(osize.Value.X*scale.X, osize.Value.Y*scale.Y, osize.Value.Z*scale.Z)
			local yOffset = 0
			if scale.Y == 0.75 then
				yOffset = -0.15
			elseif scale.Y == 2 then
				yOffset = 0.45
			end
			mesh.Offset = Vector3.new(0, yOffset, 0)
		end
	end
end

function module:ChangeFace(char, faceId)
	local head = char:FindFirstChild("Head")
	if head then
		local face = head:FindFirstChild("face")
		if face then
			face.Texture = "rbxassetid://"..faceId
		end
	end
end

function module:BecomeTargetPlayer(player, targetId)
	local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local success, desc
		success, desc = pcall(function() return game.Players:GetHumanoidDescriptionFromUserId(targetId) end)
		if success then
			pcall(function() humanoid:ApplyDescription(desc) end)
		end
	end
end

function module:ClearCharacter(character)
	for a,b in pairs(character:GetDescendants()) do
		if b:IsA("Shirt") or b:IsA("ShirtGraphic") or b:IsA("Pants") or b:IsA("Accessory") or b:IsA("Hat") or b:IsA("CharacterMesh") or b:IsA("BodyColors") then
			b:Destroy()
		elseif b.Name == "Chest" or b.Name == "Arm1" or b.Name == "Arm2" or b.Name == "Leg1" or b.Name == "Leg2" or b.Name == "ExtraFeatures" or b.Name == "ExtraFace" then
			b:Destroy()
		end
	end
end

function module:AddExtraFeatures(plr, char, morph)
	if morph:FindFirstChild("ExtraFeatures") then
		local g = morph.ExtraFeatures:clone()
		g.Name = "ExtraFeatures"
		g.Parent = char
		for a,b in pairs(g:GetChildren()) do
			if b.className == "Part" or b.className == "UnionOperation" then
				local W = Instance.new("Weld")
				W.Part0 = g.Middle
				W.Part1 = b
				local CJ = CFrame.new(g.Middle.Position)
				local C0 = g.Middle.CFrame:inverse()*CJ
				local C1 = b.CFrame:inverse()*CJ
				W.C0 = C0
				W.C1 = C1
				W.Parent = g.Middle
			end
			local Y = Instance.new("Weld")
			Y.Part0 = char["Head"]
			Y.Part1 = g.Middle
			Y.C0 = CFrame.new(0, 0, 0)
			Y.Parent = Y.Part0
		end
		for a,b in pairs(g:GetChildren()) do
			b.Anchored = false
			b.CanCollide = false
		end
	end
end

local function prepareJointVerifier(humanoid)
	local verifyJoints = humanoid:FindFirstChild("VerifyJoints")
	if not verifyJoints then
		local disableDeath = Instance.new("RemoteFunction")
		disableDeath.Name = "SetDeathEnabled"
		disableDeath.Parent = humanoid
		local validator = script:FindFirstChild("PackageValidator"):Clone()
		validator.Parent = humanoid	
		verifyJoints = Instance.new("RemoteFunction")
		verifyJoints.Name = "VerifyJoints"
		verifyJoints.Parent = humanoid
		validator.Disabled = false
	end
	return verifyJoints
end

function module:Morph(plr, morph)
	local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local char = plr.Character
		local rigType = humanoid.RigType
		local tag = char:FindFirstChild("CharTag")
		if tag == nil or tag.Value ~= morph.Name then
			module:ClearFakeBodyParts(char)
			module:ClearCharacter(char)
			if morph:FindFirstChild("Chest") then
				module:OldMorphHandler(plr, char, morph, rigType)
				char = plr.Character
			else
				----------------------------------------------------------------
				local tag = Instance.new("StringValue")
				tag.Name = "CharTag"
				tag.Parent = char
				--Humanoid
				local model = morph:Clone()
				local hum_values = {}
				for a,b in pairs(model.Humanoid:GetChildren()) do
					if b:IsA("NumberValue") then
						hum_values[b.Name] = b.Value
					end
				end
				for a,b in pairs(model:GetDescendants()) do
					if b:IsA("BasePart") then
						b.Anchored = false
					end
				end
				model.Humanoid:Destroy()
				----- << GET PACKAGE >>
				local package = Instance.new("Folder")
				local r15 = Instance.new("Folder")
				r15.Name = "R15"
				r15.Parent = package
				for a,r15_part in pairs(model:GetChildren()) do
					if r15_part:IsA("BasePart") and r15_part.Name ~= "Head" and r15_part.Name ~= "HumanoidRootPart"  then
						r15_part:Clone().Parent = r15
					end
				end
				---- << APPLY PACKAGE >>
				if rigType == Enum.HumanoidRigType.R15 then
					local verifyJoints
					local player = game.Players:GetPlayerFromCharacter(char)
					if player then
						verifyJoints = prepareJointVerifier(humanoid)
						humanoid:UnequipTools()
					end
					local accessories = {}
					for _,child in pairs(char:GetChildren()) do
						if child:IsA("Accoutrement") then
							child.Parent = nil
							table.insert(accessories,child)
						end
					end
					setDeathEnabled(humanoid,false)
					for _,newLimb in pairs(package.R15:GetChildren()) do
						local oldLimb = char:FindFirstChild(newLimb.Name)
						if oldLimb then
							newLimb.BrickColor = oldLimb.BrickColor
							newLimb.CFrame = oldLimb.CFrame
							oldLimb:Destroy()
						end
						newLimb.Parent = char
					end
					humanoid:BuildRigFromAttachments()
					if player then
						pcall(function ()
							local attempts = 0
							while attempts < 10 do
								local success = verifyJoints:InvokeClient(player)
								if success then
									break
								else
									attempts = attempts + 1
								end
							end
							if attempts == 10 then
								warn("Failed to apply package to ",player)
							end
						end)
					end
					for _,accessory in pairs(accessories) do
						accessory.Parent = char
					end
					setDeathEnabled(humanoid,true)
					package:Destroy()
				end
				-- Clear
				wait()
				for a,b in pairs(char:GetChildren()) do
					if b:IsA("Accessory") or b:IsA("Hat") or b:IsA("ForceField") or b:IsA("Clothing") or b.Name == "Body Colors" or b.ClassName == "ShirtGraphic" then
						b:Destroy()
					end
					if b.Name == "Head" then
						for c,d in pairs(b:GetChildren()) do
							if d:IsA("SpecialMesh") then
								--d:Destroy()
							end
						end
					end
					if b:FindFirstChild("BodyEffect") then
						b.BodyEffect:Destroy()
					end
				end
				-- Apply
				if char:WaitForChild("Head"):FindFirstChild("face") then
					char.Head.face:Destroy()
				end
				for a,b in pairs(hum_values) do
					if char.Humanoid:FindFirstChild(a) == nil then
						local val = Instance.new("NumberValue")
						val.Name = a
						val.Parent = char.Humanoid
					end
					char.Humanoid[a].Value = b
				end
				char.Head.Transparency = morph.Head.Transparency
				tag.Value = morph.Name
				if model.Head:FindFirstChild("face") then
					model.Head.face.Parent = char.Head
				end
				--local scale = model.Head.Mesh.Scale
				local plrMesh = char.Head:FindFirstChildOfClass("SpecialMesh")
				if not plrMesh then
					plrMesh = Instance.new("SpecialMesh")
					plrMesh.Parent = char.Head
				end
				local headMesh = model.Head.Mesh
				if headMesh then
					if string.match(headMesh.MeshId, "%d") == nil then
						plrMesh.MeshType = Enum.MeshType.Head
					else
						plrMesh.MeshId = headMesh.MeshId
					end
					plrMesh.TextureId = headMesh.TextureId
					plrMesh.Offset = headMesh.Offset
					plrMesh.Scale = headMesh.Scale
				end
				for a,b in pairs(model:GetChildren()) do
					if b.Name == "Shirt" or b.Name == "Pants" or b.Name == "Body Colors" or b.ClassName == "ShirtGraphic" then
						b.Parent = char
					elseif b.Name == "face" then
						b.Parent = char.Head
					elseif b.ClassName == "Accessory" or b.ClassName == "Hat" then
						humanoid:AddAccessory(b)
						local handle = b:FindFirstChild("Handle")
						if handle and handle:FindFirstChild("Mesh") == nil then
							handle.Transparency = 1
						end
					elseif b:IsA("BasePart") then
						if b:FindFirstChild("BodyEffect") then
							b.BodyEffect:Clone().Parent = char.HumanoidRootPart
						end
					end
				end

				---------------------------
				local modelRigType = Enum.HumanoidRigType.R15
				if model:FindFirstChild("Torso") then
					modelRigType = Enum.HumanoidRigType.R6
				end
				if rigType ~= modelRigType then
					local function updateCorrespondingPart(cPart, mPart)
						cPart.Transparency = mPart.Transparency
					end
					for r6Name, r15Table in pairs(correspondingBodyParts) do
						local modelBodyPart = model:FindFirstChild(r6Name)
						if modelBodyPart then
							for i, correspondingPartName in pairs(r15Table) do
								local correspondingPart = char:FindFirstChild(correspondingPartName)
								if correspondingPart then
									updateCorrespondingPart(correspondingPart, modelBodyPart)
								end
							end
						else
							local correspondingPart = char:FindFirstChild(r6Name)
							if correspondingPart then
								for i, modelBodyPartName in pairs(r15Table) do
									local modelBodyPart = model:FindFirstChild(modelBodyPartName)
									if modelBodyPart then
										updateCorrespondingPart(correspondingPart, modelBodyPart)
									end
								end
							end
						end
					end
				end
				module:UpdateHipHeight(char)
				----------------------------------------------------------------
				model:Destroy()
			end
		end
		module:AddExtraFeatures(plr, char, morph)
		if tag then
			tag:Destroy()
		end
		------------------
		if char.Head:FindFirstChild("face") == nil then
			local decal = Instance.new("Decal")
			decal.Name = "face"
			decal.Texture = ""
			decal.Parent = char.Head
		end
		if char then
			if morph.Name == "Domo" or morph.Name == "Minion" or morph.Name == "MachoObliviousHD" or morph.Name == "Slender" or morph.Name == "EvilObliviousHD" or morph.Name == "BigMomma" then
				char.Head.Transparency = 1
				if char.Head:FindFirstChild("face") then
					char.Head.face.Transparency = 1
				end
			else
				char.Head.Transparency = 0
				if char.Head:FindFirstChild("face") then
					char.Head.face.Transparency = 0
				end
			end
			if morph.Name == "Golden Bob" then
				char.Head.Reflectance = 0.5
			else
				char.Head.Reflectance = 0
			end
		end
		---------------
	end
end

local bundleCache = {}
function module:ApplyBundle(humanoid, bundleId)
	local HumanoidDescription = bundleCache[bundleId]
	if not HumanoidDescription then
		local success, bundleDetails = pcall(function() return game:GetService("AssetService"):GetBundleDetailsAsync(bundleId) end)
		if success and bundleDetails then
			for _, item in next, bundleDetails.Items do
				if item.Type == "UserOutfit" then
					success, HumanoidDescription = pcall(function() return game.Players:GetHumanoidDescriptionFromOutfitId(item.Id) end)
					bundleCache[bundleId] = HumanoidDescription
					break
				end
			end
		end
	end
	if not HumanoidDescription then return end
	local newDescription = humanoid:GetAppliedDescription()
	local defaultDescription = Instance.new("HumanoidDescription")
	for _, property in next, {"BackAccessory", "BodyTypeScale", "ClimbAnimation", "DepthScale", "Face", "FaceAccessory", "FallAnimation", "FrontAccessory", "GraphicTShirt", "HairAccessory", "HatAccessory", "Head", "HeadColor", "HeadScale", "HeightScale", "IdleAnimation", "JumpAnimation", "LeftArm", "LeftArmColor", "LeftLeg", "LeftLegColor", "NeckAccessory", "Pants", "ProportionScale", "RightArm", "RightArmColor", "RightLeg", "RightLegColor", "RunAnimation", "Shirt", "ShouldersAccessory", "SwimAnimation", "Torso", "TorsoColor", "WaistAccessory", "WalkAnimation", "WidthScale"} do
		if HumanoidDescription[property] ~= defaultDescription[property] then
			newDescription[property] = HumanoidDescription[property]
		end
	end
	humanoid:ApplyDescription(newDescription)
end

return module