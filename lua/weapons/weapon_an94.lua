SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AN-94"
SWEP.Author = "Izmash"
SWEP.Instructions = "Experimental assault rifle chambered in 5.45x39 mm\n\nTwo-round burst hyperburst capability"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/arc9/zwei/c_an94.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "AN-94"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/mods/mag_ak74_izhmash_6l26_545x39_45.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, -0.15),
		ang = Angle(0, 0, 0)
	},
	pistolgrip = {
		model = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -12.3, -1.3),
		ang = Angle(0, 0, 0)
	},
}

SWEP.ARC9DefaultLHIKPart = "weapon"
SWEP.ARC9DefaultLHIKUseWorldModel = true

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_an94.png")
SWEP.IconOverride = "entities/arc9_eft_an94.png"


SWEP.FakePos = Vector(-13, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-2.2, 0.5, 0.3)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "111"
SWEP.ZoomPos = Vector(0, -2.5104, 4.9776)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_ak74_izhmash_6l26_545x39_45.mdl"

local path = "weapons/darsu_eft/ak/"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reloadlong545"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
	},
	["reloadlong545_empty"] = {
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
	["reload"] = "reloadlong545",
	["reload_empty"] = "reloadlong545_empty",
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

SWEP.HeldMagModel = "models/weapons/mods/mag_ak74_izhmash_6l26_545x39_45.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, 0, 0)

SWEP.HeldPistolgripModel = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl"
SWEP.HeldPistolgripBone = "weapon"
SWEP.HeldPistolgripOffsetPos = Vector(0, -12.3, -1.3)
SWEP.HeldPistolgripOffsetAng = Angle(0, 0, 0)

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 45
SWEP.Primary.DefaultClip = 45
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.45x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 35
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 32
SWEP.animposmul = 2
SWEP.Primary.Sound = {"weapons/darsu_eft/ak/fire_new/ak74_outdoor_close_loop_1.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/ak/fire_new/ak74_loop_outdoor_close_silenced_4.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/newakm/akmm_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.085
SWEP.ReloadTime = 3.5
SWEP.ViewPunchDiv = 1000



SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.CustomShell = "762x39"
SWEP.ShellEject = "EjectBrass_762"

SWEP.LocalMuzzlePos = Vector(23.4, -2.5, 3.45)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.weight = 3.85
SWEP.ScrappersSlot = "Primary"

SWEP.DistSound = "weapons/newakm/akmm_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"dovetail", "picatinny"},
		["mount"] = {["dovetail"] = Vector(-22, -0.25, 1.8),  ["picatinny"] = Vector(-21, 0, 2.35)},
		["mountAngle"] = Angle(0,0,90)
	},
	mount = {
		mountAngle = Angle(0, 90, 0),
		["picatinny"] = {"mount3", Vector(-22, 0.85, 0.3), {}, mountType = "picatinny"},
		["dovetail"] = {"empty", Vector(0, 0, 0), {}, mountType = "dovetail"},
	},
	magwell = {
		["mountType"] = "ak_545_60",
	},
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 15
SWEP.Spray = {}
for i = 1, 45 do
	SWEP.Spray[i] = Angle(-0.0, 0, 0) * 1
end

SWEP.Ergonomics = 0.85
SWEP.WorldPos = Vector(4, -0.8, -0.5)
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

	local heldMagModel = self:GetActiveMagazineModel(self.HeldMagModel, "held")
	if IsValid(self.HeldMagCSModel) and self.HeldMagCSModelPath ~= heldMagModel then
		self.HeldMagCSModel:Remove()
	end
	if not IsValid(self.HeldMagCSModel) then
		self.HeldMagCSModel = ClientsideModel(heldMagModel, RENDERGROUP_BOTH)
		self.HeldMagCSModelPath = heldMagModel
		if IsValid(self.HeldMagCSModel) then self.HeldMagCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldMagCSModel) then
		local boneID = wm:LookupBone(self.HeldMagBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldMagOffsetPos, self.HeldMagOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldMagCSModel:SetRenderOrigin(lpos)
				self.HeldMagCSModel:SetRenderAngles(lang)
				self.HeldMagCSModel:SetPos(lpos)
				self.HeldMagCSModel:SetAngles(lang)
				self.HeldMagCSModel:SetupBones()
				self.HeldMagCSModel:DrawModel()
			end
		end
	end

	if not IsValid(self.HeldPistolgripCSModel) then
		self.HeldPistolgripCSModel = ClientsideModel(self.HeldPistolgripModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldPistolgripCSModel) then self.HeldPistolgripCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldPistolgripCSModel) then
		local boneID = wm:LookupBone(self.HeldPistolgripBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldPistolgripOffsetPos, self.HeldPistolgripOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldPistolgripCSModel:SetRenderOrigin(lpos)
				self.HeldPistolgripCSModel:SetRenderAngles(lang)
				self.HeldPistolgripCSModel:SetPos(lpos)
				self.HeldPistolgripCSModel:SetAngles(lang)
				self.HeldPistolgripCSModel:SetupBones()
				self.HeldPistolgripCSModel:DrawModel()
			end
		end
	end
end

--========================================================

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
			local modelPath = partName == "magazine" and self:GetActiveMagazineModel(partData.model, "world") or partData.model

			local model = self.BC_DroppedPartModels[partName]
			local oldPath = self.BC_DroppedPartPaths[partName]

			if IsValid(model) and oldPath ~= modelPath then
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
		self:CleanupARC9DefaultLHIKSource()
		if IsValid(self.HeldMagCSModel) then self.HeldMagCSModel:Remove() end
		if IsValid(self.HeldPistolgripCSModel) then self.HeldPistolgripCSModel:Remove() end
	end
end

--========================================================

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
