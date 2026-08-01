SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Saiga-12K"
SWEP.Author = "Izhevsk Machine-Building Plant"
SWEP.Instructions = "Automatic shotgun chambered in 12/70\n\nRate of fire 400 rounds per minute"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_saiga12k.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "Saiga-12K"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	pistolgrip = {
		model = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl",
		bonemerge = false,
		bone = "mod_pistol_grip",
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
	},
}

SWEP.FakePos = Vector(-11.5, 1, 10)
SWEP.FakeAng = Angle(0, 0, -0.5)
SWEP.AttachmentPos = Vector(0,0,-0)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "1120201101001"
SWEP.ZoomPos = Vector(0, -3.2616, 8.6141)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 50

SWEP.MagModel = "models/weapons/mods/mag_ak_molot_556x45_45.mdl"
SWEP.FakeMagDropBone = 50

local path = "weapons/darsu_eft/saiga12/"

SWEP.AnimsEvents = {
	["look0"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_magout_plastic.ogg") end,
		[0.50] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_magin_plastic.ogg") end,
	},
	["reload0_empty"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_magout_plastic.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_magin_plastic.ogg") end,
		[0.70] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_slider_down.ogg") end,
		[0.85] = function(self) self:EmitSound("weapons/darsu_eft/ak/saiga_slider_up.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload0_empty",
	["inspect"] = "look0",
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
	if not self.FakeBodyGroups then return end

	model:SetBodyGroups(self.FakeBodyGroups)

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.HeldGripModel = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl"
SWEP.HeldGripBone = "mod_pistol_grip"
SWEP.HeldGripOffsetPos = Vector(0, 0, 0)
SWEP.HeldGripOffsetAng = Angle(0, 0, 0)

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 16
SWEP.Primary.Spread = Vector(0.01, 0.01, 0.01)
SWEP.Primary.Force = 12
SWEP.Primary.Sound = {"weapons/darsu_eft/saiga12/fire_close.wav", 80, 70, 75}
SWEP.Primary.Wait = 0.15
SWEP.NumBullet = 8
SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.ReloadTime = 3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mshotgun"

SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_saiga12k.png")
SWEP.IconOverride = "entities/arc9_eft_saiga12k.png"

SWEP.weight = 3.6
SWEP.ScrappersSlot = "Primary"

SWEP.CustomShell = "12x70"
SWEP.ShellEject = "ShotgunShellEject"

SWEP.LocalMuzzlePos = Vector(25,-3.28,6.55)
SWEP.LocalMuzzleAng = Angle(0,0,0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.DistSound = "weapons/darsu_eft/saiga12/saiga12_dist.wav"

SWEP.StartAtt = {"holo7"}
SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-22.5, 0.12, 2)},
		["mountAngle"] = Angle(0,0,90) 
	},
    barrel = {
        [1] = {"supressor13", Vector(0, 0, 0), {}},
        [2] = {"supressor12", Vector(0, 0, 0), {}},
        ["mount"] = Vector(-0.5, -0, 0),
        ["mountAngle"] = Angle(0, -0, 90),
    },
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 7
SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.0, 0, 0) * 1
end

SWEP.Ergonomics = 0.75
SWEP.WorldPos = Vector(4, -0.8, 4)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(1, 0, 0)
SWEP.attAng = Angle(-0.02, 0, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(7, 2, 0)

SWEP.RHPos = Vector(3, -7, 3.5)
SWEP.RHAng = Angle(0, -8, 90)
SWEP.LHPos = Vector(11, 1.6, -3)
SWEP.LHAng = Angle(-110, -180, 5)

SWEP.ShootAnimMul = 2

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(3, 8, -12)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.punchmul = 4
SWEP.punchspeed = 0.5
SWEP.addSprayMul = 1

function SWEP:AnimHoldPost(model)
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	local wm = self:GetWM()
	if not IsValid(wm) then return end

	-- Pistol Grip
	if not IsValid(self.HeldGripCSModel) then
		self.HeldGripCSModel = ClientsideModel(self.HeldGripModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldGripCSModel) then self.HeldGripCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldGripCSModel) then
		local boneID = wm:LookupBone(self.HeldGripBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldGripOffsetPos, self.HeldGripOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldGripCSModel:SetRenderOrigin(lpos)
				self.HeldGripCSModel:SetRenderAngles(lang)
				self.HeldGripCSModel:SetPos(lpos)
				self.HeldGripCSModel:SetAngles(lang)
				self.HeldGripCSModel:SetupBones()
				self.HeldGripCSModel:DrawModel()
			end
		end
	end
end


--========================================================
-- DROPPED EFT MODEL + MODULAR PARTS
--========================================================

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)

SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.10] = function(self, timeMul)
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
				hg.CreateMag( self, Vector(50,10,10), nil, true )
			end
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

	local BC_VECTOR_ZERO = Vector(0, 0, 0)
	local BC_ANGLE_ZERO = Angle(0, 0, 0)

	function SWEP:BC_CreateDroppedFakeWorldModel()
		if not self.WorldModelFake then return end
		if IsValid(self.BC_DroppedFakeWorldModel) then return end

		local model = ClientsideModel(self.WorldModelFake, RENDERGROUP_BOTH)
		if not IsValid(model) then return end

		model:SetNoDraw(true)
		model:DrawShadow(true)

		if self.FakeScale then
			model:SetModelScale(self.FakeScale, 0)
		end

		if self.FakeBodyGroups then
			model:SetBodyGroups(self.FakeBodyGroups)
		end

		if self.ModelCreated then
			self:ModelCreated(model)
		end

		self.BC_DroppedFakeWorldModel = model
	end

	function SWEP:BC_CreateDroppedPartModels()
		if not istable(self.ARC9Parts) then return end

		self.BC_DroppedPartModels = self.BC_DroppedPartModels or {}
		self.BC_DroppedPartPaths = self.BC_DroppedPartPaths or {}

		for partName, partData in pairs(self.ARC9Parts) do
			if not istable(partData) or not isstring(partData.model) or partData.model == "" then
				continue
			end

			local model = self.BC_DroppedPartModels[partName]
			local oldPath = self.BC_DroppedPartPaths[partName]

			if IsValid(model) and oldPath ~= partData.model then
				model:Remove()
				model = nil
			end

			if not IsValid(model) then
				model = ClientsideModel(partData.model, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.BC_DroppedPartModels[partName] = model
					self.BC_DroppedPartPaths[partName] = partData.model
				end
			end
		end
	end

	function SWEP:BC_RemoveDroppedModels()
		if self.BC_DroppedPartModels then
			for partName, model in pairs(self.BC_DroppedPartModels) do
				if IsValid(model) then model:Remove() end
			end
		end
		self.BC_DroppedPartModels = nil
		self.BC_DroppedPartPaths = nil

		if IsValid(self.BC_DroppedFakeWorldModel) then
			self.BC_DroppedFakeWorldModel:Remove()
		end
		self.BC_DroppedFakeWorldModel = nil
	end

	local function BC_ApplyPartAppearance(model, partData)
		if not IsValid(model) or not istable(partData) then return end

		if partData.skin ~= nil then
			model:SetSkin(partData.skin)
		end

		if istable(partData.bodygroups) then
			for bodygroupID, value in pairs(partData.bodygroups) do
				model:SetBodygroup(tonumber(bodygroupID) or bodygroupID, tonumber(value) or 0)
			end
		end

		if istable(partData.submaterials) then
			for materialID, materialPath in pairs(partData.submaterials) do
				model:SetSubMaterial(tonumber(materialID) or materialID, materialPath or "")
			end
		end
	end

	function SWEP:BC_DrawDroppedFakeWorldAndParts()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end

		if not IsValid(self.BC_DroppedFakeWorldModel) then
			self:BC_CreateDroppedFakeWorldModel()
		end

		self:BC_CreateDroppedPartModels()

		local basePosition, baseAngles = LocalToWorld(
			self.WorldPartsOffsetPos or BC_VECTOR_ZERO,
			self.WorldPartsOffsetAng or BC_ANGLE_ZERO,
			self:GetPos(),
			self:GetAngles()
		)

		local fake = self.BC_DroppedFakeWorldModel

		if IsValid(fake) then
			fake:SetRenderOrigin(basePosition)
			fake:SetRenderAngles(baseAngles)
			fake:SetPos(basePosition)
			fake:SetAngles(baseAngles)
			fake:SetupBones()
		end

		if istable(self.ARC9Parts) and istable(self.BC_DroppedPartModels) then
			for partName, partData in pairs(self.ARC9Parts) do
				local model = self.BC_DroppedPartModels[partName]
				if not IsValid(model) or not istable(partData) then continue end

				local boneName = partData.bone or ""
				local extraPosition = BC_VECTOR_ZERO
				local extraAngles = BC_ANGLE_ZERO

				if partName == "magazine" and self.WorldMagazineBoneOverride then
					boneName = self.WorldMagazineBoneOverride
					extraPosition = self.WorldMagazineOffsetPos or BC_VECTOR_ZERO
					extraAngles = self.WorldMagazineOffsetAng or BC_ANGLE_ZERO
				end

				local partBasePosition = basePosition
				local partBaseAngles = baseAngles

				if IsValid(fake) and isstring(boneName) and boneName ~= "" then
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
				local localAngles = Angle(
					(partData.ang or BC_ANGLE_ZERO).p,
					(partData.ang or BC_ANGLE_ZERO).y,
					(partData.ang or BC_ANGLE_ZERO).r
				)
				localAngles:Add(extraAngles)

				local position, angles = LocalToWorld(localPosition, localAngles, partBasePosition, partBaseAngles)

				model:SetRenderOrigin(position)
				model:SetRenderAngles(angles)
				model:SetPos(position)
				model:SetAngles(angles)
				model:SetupBones()

				BC_ApplyPartAppearance(model, partData)
			end
		end

		if IsValid(fake) then
			fake:DrawModel()
		end

		if istable(self.ARC9Parts) and istable(self.BC_DroppedPartModels) then
			for partName, partData in pairs(self.ARC9Parts) do
				local model = self.BC_DroppedPartModels[partName]
				if IsValid(model) then
					model:DrawModel()
				end
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
		if IsValid(self.HeldGripCSModel) then self.HeldGripCSModel:Remove() end
	end
end

--========================================================
-- FIRE ANIMATION
--========================================================

SWEP.FireAnimTime = 0.15
SWEP.FireAnimCandidates = {"fire"}

function SWEP:PrimaryShootPost()
	self.drawBullet = true

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
