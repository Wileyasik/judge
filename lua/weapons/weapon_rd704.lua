SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "RD-704"
SWEP.Author = "Rifle Dynamics"
SWEP.Instructions = "Automatic rifle chambered in 7.62x39 mm\n\nRate of fire 600 rounds per minute"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_rd704.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "RD-704"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/mods/mag_ak_izhmash_ak103_std_762x39_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
	handguard = {
		model = "models/weapons/mods/ak_hg_rd704_ionlite.mdl",
		bonemerge = false,
		bone = "mod_handguard",
		pos = Vector(0, -1.86, 0.55),
		ang = Angle(0, 0, 0)
	},
	pistolgrip = {
		model = "models/weapons/mods/ak_pgrip_tango_down.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -12.3, -1.3),
		ang = Angle(0, 0, 0)
	},
	dustcover = {
		model = "models/weapons/mods/ak_dc_fab_defence_pdc.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, -0.1, -0.1),
		ang = Angle(0, 0, 0)
	},
	stock_tube = {
		model = "models/weapons/mods/ak_stock_utg_sfs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0.62, 9.36, -2.27),
		ang = Angle(0, 0, 0)
	},
	stock_adapter = {
		model = "models/weapons/mods/stock_ar15_stmarms_com_spec_std.mdl",
		bonemerge = false,
		parent = "stock_tube",
		pos = Vector(-0.83, 2.64, 0.2),
		ang = Angle(0, -90, 0)
	},
	stock = {
		model = "models/weapons/mods/stock_ar15_sb_tactical_sba3_lod0.mdl",
		bonemerge = false,
		parent = "stock_adapter",
		pos = Vector(-3.3, 0, -0.95),
		ang = Angle(0, -0, 0)
	},
}

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/ak_hg_rd704_ionlite.mdl"

SWEP.FakePos = Vector(-14, 2.52, 6.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-0, 2.1, -27.95)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.ZoomPos = Vector(0, -1.7712, 5.1528)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
	["reload762"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
	},
	["reload762_empty"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/ak74_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_up.ogg") end,
		[0.83] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_down.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload762",
	["reload_empty"] = "reload762_empty",
	["inspect"] = "look2",
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:ModelCreated(model)
	if not CLIENT then return end
	if not IsValid(model) then return end

	if self.FakeBodyGroups then
		model:SetBodyGroups(self.FakeBodyGroups)
	end

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.10] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(27, vector_origin)
			self:GetWM():ManipulateBoneScale(38, vector_full)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetWM():ManipulateBoneScale(41, vector_origin)
		end,
		[0.35] = function(self, timeMul)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.5 * timeMul, nil, nil, function()
				self:GetWM():ManipulateBoneScale(38, vector_full)
				self:GetWM():ManipulateBoneScale(39, vector_full)
			end)
		end,
		[0.40] = function(self, timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag(self, Vector(50, 10, 10), nil, true)
			end
			self:GetWM():ManipulateBoneScale(57, vector_origin)
			self:GetWM():ManipulateBoneScale(58, vector_origin)
		end,
		[0.70] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(38, vector_origin)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
				self:GetWM():ManipulateBoneScale(38, vector_origin)
				self:GetWM():ManipulateBoneScale(39, vector_origin)
				self:GetWM():ManipulateBoneScale(40, vector_origin)
			end)
		end,
	}
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_ak_izhmash_ak103_std_762x39_30.mdl"
SWEP.lmagpos = Vector(0, 0, 0)
SWEP.lmagang = Angle(0, 0, 0)
SWEP.lmagpos2 = Vector(0, 0, 1)
SWEP.lmagang2 = Angle(90, 0, -90)

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 50
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 50
SWEP.ShockMultiplier = 2
SWEP.animposmul = 2
SWEP.Primary.Sound = {"ak74/ak74_fp.wav", 85, 90, 100}
SWEP.SupressedSound = {"ak74/ak74_suppressed_fp.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/ak47/handling/ak47_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.1
SWEP.ReloadTime = 3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"
SWEP.CustomShell = "762x39"
SWEP.ShellEject = "EjectBrass_762"

SWEP.LocalMuzzlePos = Vector(17.7, -1.7, 3)
SWEP.LocalMuzzleAng = Angle(-0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)
SWEP.HoldType = "rpg"

SWEP.RHandPos = Vector(-12, -1, 4)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 15
SWEP.Spray = {}
for i = 1, 30 do
	SWEP.Spray[i] = Angle(-0.01 - math.cos(i) * 0.02, math.cos(i * i) * 0.02, 0) * 0.5
end

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_rd704.png")
SWEP.WepSelectIcon2box = false
SWEP.IconOverride = "entities/arc9_eft_rd704.png"

SWEP.Ergonomics = 0.85
SWEP.WorldPos = Vector(5, -0.8, -1.1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0.25, -2.1, 28)
SWEP.attAng = Angle(0, 0.4, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(1, -1.5, 0)
SWEP.DistSound = "ak74/ak74_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-17, 0.12, 1.7)},
		["mountAngle"] = Angle(0, 0, 90)
	},
	barrel = {
		[1] = {"supressor8", Vector(0, 0, 0), {}},
		[2] = {"supressor7", Vector(0, 0, 0), {}},
		[3] = {"supressor16", Vector(0, 0, 0), {}},
		[4] = {"supressor15", Vector(0, 0, 0), {}},
		["mount"] = Vector(-0.9, 0, -0.1),
		["mountAngle"] = Angle(0, 2, 0)
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(11.5, 1.35, -1.1)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0, 0, 90)
	},
	underbarrel = {
		["mount"] = Vector(7, -1, -1),
		["mountAngle"] = Angle(0, -0.75,90),
		["mountType"] = "picatinny_small"
	},
	magwell = {
		["mountType"] = {"ak_762", "ak_762_75"},
	},
}

SWEP.weight = 3.6
SWEP.RHPos = Vector(3, -6, 3.5)
SWEP.RHAng = Angle(0, -12, 90)
SWEP.LHPos = Vector(15, 1, -3.3)
SWEP.LHAng = Angle(-110, -180, 0)
SWEP.ShootAnimMul = 2

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	local wm = self:GetWM()
	if not IsValid(wm) then return end

	self.HeldARC9PartModels = self.HeldARC9PartModels or {}
	self.HeldARC9PartPaths = self.HeldARC9PartPaths or {}
	local positioned = {}

	local function positionPart(partName)
		if positioned[partName] then return positioned[partName] end
		local partData = self.ARC9Parts and self.ARC9Parts[partName]
		if not istable(partData) then return end

		local modelPath = partName == "magazine" and self:GetActiveMagazineModel(partData.model, "held") or partData.model
		if not isstring(modelPath) or modelPath == "" then return end
		local model = self.HeldARC9PartModels[partName]
		if IsValid(model) and self.HeldARC9PartPaths[partName] ~= modelPath then
			model:Remove()
			model = nil
		end
		if not IsValid(model) then
			model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
			if not IsValid(model) then return end
			model:SetNoDraw(true)
			self.HeldARC9PartModels[partName] = model
			self.HeldARC9PartPaths[partName] = modelPath
		end

		local basePos, baseAng
		if partData.parent then
			local parent = positionPart(partData.parent)
			if not IsValid(parent) then return end
			basePos, baseAng = parent:GetPos(), parent:GetAngles()
		else
			local boneID = wm:LookupBone(partData.bone or "")
			local matrix = boneID and wm:GetBoneMatrix(boneID)
			if not matrix then return end
			basePos, baseAng = matrix:GetTranslation(), matrix:GetAngles()
		end

		local pos, ang = LocalToWorld(partData.pos or vector_origin, partData.ang or angle_zero, basePos, baseAng)
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetPos(pos)
		model:SetAngles(ang)
		if partData.skin ~= nil then model:SetSkin(partData.skin) end
		if isstring(partData.bodygroups) then model:SetBodyGroups(partData.bodygroups) end
		model:SetupBones()
		positioned[partName] = model
		return model
	end

	for partName in pairs(self.ARC9Parts or {}) do positionPart(partName) end
	for partName in pairs(self.ARC9Parts or {}) do
		local model = positioned[partName]
		if IsValid(model) then model:DrawModel() end
	end

	self.HeldMagCSModel = positioned.magazine
end

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)
SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local BC_VECTOR_ZERO = Vector(0, 0, 0)
	local BC_ANGLE_ZERO = Angle(0, 0, 0)

	function SWEP:BC_CreateDroppedFakeWorldModel()
		if not self.WorldModelFake then return end
		if IsValid(self.BC_DroppedFakeWorldModel) then return end

		local model = ClientsideModel(self.WorldModelFake, RENDERGROUP_BOTH)
		if not IsValid(model) then return end

		model:SetNoDraw(true)
		model:DrawShadow(true)
		if self.FakeBodyGroups then model:SetBodyGroups(self.FakeBodyGroups) end
		if self.ModelCreated then self:ModelCreated(model) end

		self.BC_DroppedFakeWorldModel = model
	end

	function SWEP:BC_CreateDroppedPartModels()
		if not istable(self.ARC9Parts) then return end
		self.BC_DroppedPartModels = self.BC_DroppedPartModels or {}
		self.BC_DroppedPartPaths = self.BC_DroppedPartPaths or {}

		for partName, partData in pairs(self.ARC9Parts) do
			if not istable(partData) or not isstring(partData.model) or partData.model == "" then continue end
			local modelPath = partName == "magazine" and self:GetActiveMagazineModel(partData.model, "world") or partData.model
			local model = self.BC_DroppedPartModels[partName]

			if IsValid(model) and self.BC_DroppedPartPaths[partName] ~= modelPath then
				model:Remove()
				model = nil
			end

			if not IsValid(model) then
				model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.BC_DroppedPartModels[partName] = model
					self.BC_DroppedPartPaths[partName] = modelPath
				end
			end
		end
	end

	function SWEP:BC_RemoveDroppedModels()
		if self.BC_DroppedPartModels then
			for _, model in pairs(self.BC_DroppedPartModels) do
				if IsValid(model) then model:Remove() end
			end
		end
		self.BC_DroppedPartModels = nil
		self.BC_DroppedPartPaths = nil

		if IsValid(self.BC_DroppedFakeWorldModel) then self.BC_DroppedFakeWorldModel:Remove() end
		self.BC_DroppedFakeWorldModel = nil
	end

	function SWEP:BC_DrawDroppedFakeWorldAndParts()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end

		if not IsValid(self.BC_DroppedFakeWorldModel) then self:BC_CreateDroppedFakeWorldModel() end
		self:BC_CreateDroppedPartModels()

		local basePosition, baseAngles = LocalToWorld(self.WorldPartsOffsetPos or BC_VECTOR_ZERO, self.WorldPartsOffsetAng or BC_ANGLE_ZERO, self:GetPos(), self:GetAngles())
		local fake = self.BC_DroppedFakeWorldModel

		if IsValid(fake) then
			fake:SetRenderOrigin(basePosition)
			fake:SetRenderAngles(baseAngles)
			fake:SetPos(basePosition)
			fake:SetAngles(baseAngles)
			fake:SetupBones()
		end

		if istable(self.ARC9Parts) and istable(self.BC_DroppedPartModels) then
			local positioned = {}
			local function positionPart(partName)
				if positioned[partName] then return positioned[partName] end
				local partData = self.ARC9Parts[partName]
				local model = self.BC_DroppedPartModels[partName]
				if not IsValid(model) or not istable(partData) then return end

				local boneName = partData.bone or ""
				local extraPosition = BC_VECTOR_ZERO
				local extraAngles = BC_ANGLE_ZERO

				if partName == "magazine" and self.WorldMagazineBoneOverride then
					boneName = self.WorldMagazineBoneOverride
					extraPosition = self.WorldMagazineOffsetPos or BC_VECTOR_ZERO
					extraAngles = self.WorldMagazineOffsetAng or BC_ANGLE_ZERO
				end

				local partBasePosition, partBaseAngles = basePosition, baseAngles
				if partData.parent then
					local parent = positionPart(partData.parent)
					if not IsValid(parent) then return end
					partBasePosition, partBaseAngles = parent:GetPos(), parent:GetAngles()
				elseif IsValid(fake) and isstring(boneName) and boneName ~= "" then
					local boneID = fake:LookupBone(boneName)
					if boneID ~= nil then
						local boneMatrix = fake:GetBoneMatrix(boneID)
						if boneMatrix then
							partBasePosition = boneMatrix:GetTranslation()
							partBaseAngles = boneMatrix:GetAngles()
						end
					end
				end

				local localPosition = (partData.pos or BC_VECTOR_ZERO) + extraPosition
				local localAngles = Angle((partData.ang or BC_ANGLE_ZERO).p, (partData.ang or BC_ANGLE_ZERO).y, (partData.ang or BC_ANGLE_ZERO).r)
				localAngles:Add(extraAngles)
				local position, angles = LocalToWorld(localPosition, localAngles, partBasePosition, partBaseAngles)

				model:SetRenderOrigin(position)
				model:SetRenderAngles(angles)
				model:SetPos(position)
				model:SetAngles(angles)
				if partData.skin ~= nil then model:SetSkin(partData.skin) end
				if isstring(partData.bodygroups) then model:SetBodyGroups(partData.bodygroups) end
				model:SetupBones()
				positioned[partName] = model
				return model
			end

			for partName in pairs(self.ARC9Parts) do
				positionPart(partName)
			end
		end

		if IsValid(fake) then fake:DrawModel() end
		if istable(self.BC_DroppedPartModels) then
			for _, model in pairs(self.BC_DroppedPartModels) do
				if IsValid(model) then model:DrawModel() end
			end
		end

		local originalWorldModel = self.worldModel
		self.worldModel = fake
		self:DrawAttachments()
		self.worldModel = originalWorldModel
	end

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:BC_DrawDroppedFakeWorldAndParts()
	end

	function SWEP:DrawWorldModelTranslucent()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:BC_DrawDroppedFakeWorldAndParts()
	end

	function SWEP:OnRemove()
		self:BC_RemoveDroppedModels()
		self:CleanupARC9DefaultLHIKSource()
		for _, model in pairs(self.HeldARC9PartModels or {}) do
			if IsValid(model) then model:Remove() end
		end
		self.HeldARC9PartModels = nil
		self.HeldARC9PartPaths = nil
		self.HeldMagCSModel = nil
	end
end

SWEP.FireAnimTime = 0.15
SWEP.FireAnimCandidates = {"fire", "fire1"}

function SWEP:PrimaryShootPost()
	if not CLIENT then return end
	if self.reload then return end
	if not self:ShouldUseFakeModel() then return end

	local worldModel = self:GetWM()
	if not IsValid(worldModel) then return end

	local selectedSequence
	for _, sequenceName in ipairs(self.FireAnimCandidates) do
		local sequenceID = worldModel:LookupSequence(sequenceName)
		if sequenceID ~= nil and sequenceID >= 0 then
			selectedSequence = sequenceName
			break
		end
	end

	if not selectedSequence then return end

	self.AnimList.fire = selectedSequence
	self:PlayAnim("fire", self.FireAnimTime, false)

	local timerName = "BC_FireAnimation_" .. self:EntIndex()
	timer.Create(timerName, self.FireAnimTime, 1, function()
		if not IsValid(self) or self.reload then return end
		if self.Primary and (self.Primary.Next or 0) > CurTime() then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end
