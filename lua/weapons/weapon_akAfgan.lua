SWEP.Base = "homigrad_base"
SWEP.ARC9ActionLHIKFadeOutTime = 0.1
SWEP.ARC9ActionLHIKFadeInTime = 0.3
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AK-74 Afgan"
SWEP.Author = "Molot-Oruzhie"
SWEP.Instructions = "Civilian carbine chambered in 5.45x39 mm\n\nRate of fire 400 rounds per minute, semi-automatic only"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.WeaponRecoilMul = 0.7
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_ak74.mdl"


SWEP.ModularParts = {
	magazine = {
		model = "models/weapons/mods/mag_ak74_izhmash_6l23_plum_545x39_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, -0.15),
		ang = Angle(0, 0, 0)
	},
	handguard = {
		model = "models/weapons/mods/ak_hg_wasr.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -19.41, 0.5),
		ang = Angle(0, 0, 0)
	},
	pistolgrip = {
		model = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -12.3, -1.3),
		ang = Angle(0, 0, 0)
	},
	stock = {
		model = "models/weapons/mods/ak_stock_ak74_std_plastic.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0.65, -9.6, -0.8),
		ang = Angle(0, 0, 0)
	},
	stock_mount = {
		model = "models/weapons/mods/ak_stock_zenit_pt1_lock.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0.65, -9.6, -0.8),
		ang = Angle(0, 0, 0)
	},
}
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, 0, 0)

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/ak_hg_wasr.mdl"

SWEP.FakePos = Vector(-13, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "11020"
SWEP.ZoomPos = Vector(0, -1.7688, 6.0696)


SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 150

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_ak74_izhmash_6l23_545x39_30.mdl"

local path = "weapons/darsu_eft/ak/"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload545"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in3.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.55] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
	},
	["reload545_empty"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/ak74_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_up.ogg") end,
		[0.82] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_down.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload545",
	["reload_empty"] = "reload545_empty",
	["inspect"] = "look1",
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
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_full)
				wm:ManipulateBoneScale(39, vector_full)
				end
			end)
		end,
		[0.40] = function(self, timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(50,10,10), nil, true )
			end
			self:GetWM():ManipulateBoneScale(57, vector_origin)
			self:GetWM():ManipulateBoneScale(58, vector_origin)
		end,
		[0.70] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(38, vector_origin)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_origin)
				wm:ManipulateBoneScale(39, vector_origin)
				wm:ManipulateBoneScale(40, vector_origin)
				end
			end)
		end,
	}
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false


SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.45x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 39
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 32
SWEP.animposmul = 2
SWEP.Primary.Sound = {"weapons/darsu_eft/ak/fire_new/ak74_outdoor_close_loop_1.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/ak/fire_new/ak74_loop_outdoor_close_silenced_4.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.09091
SWEP.ReloadTime = 3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.CustomShell = "762x39"
SWEP.ShellEject = "EjectBrass_762"

SWEP.LocalMuzzlePos = Vector(22, -1.8, 4)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ak74.png")
SWEP.IconOverride = "entities/arc9_eft_ak74.png"

SWEP.weight = 3.6
SWEP.ScrappersSlot = "Primary"

SWEP.DistSound = "weapons/newakm/akmm_dist.wav"

local sightProfile, sightMountProfile = hg.GetAK74SightProfile()
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor3", Vector(0, 0, 0), {}},
		[2] = {"supressor4", Vector(0, 0, 0), {}},
		[3] = {"supressor15", Vector(1.3, 0, 0), {}},
		["mount"] = Vector(-1, 0, 0),
	},
	sight = sightProfile,
	mount = sightMountProfile,
	magwell = {
		["mountType"] = {"ak_545_60", "ak_545"},
	},
	stock = {
		[1] = {"stock_ak74_std", Vector(0, 0, 0), {}},
		["mountType"] = "ak_stock",
		["mountBone"] = "weapon",
		["mount"] = Vector(0.65, -9.6, -0.8),
	},
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 19
SWEP.Spray = {}
for i = 1, 30 do
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

-- tpik hand positions
SWEP.RHPos = Vector(3, -7, 3.5)
SWEP.RHAng = Angle(0, -8, 90)
SWEP.LHPos = Vector(11, 1.6, -3)
SWEP.LHAng = Angle(-110, -180, 5)

SWEP.ShootAnimMul = 2

function SWEP:AnimHoldPost(model)
end

function SWEP:GetModularPartModel(partName, fallback, role)
	if partName == "magazine" then
		return self:GetActiveMagazineModel(fallback, role)
	elseif partName == "stock" then
		return self:GetActiveStockModel(fallback)
	elseif partName == "stock_mount" then
		return self:GetActiveStockMountModel(fallback)
	end
	return fallback
end

function SWEP:DrawModularParts()
	local wm = self:GetWM()
	if not IsValid(wm) then return end

	local parts = self.ModularParts
	if not istable(parts) then return end

	self.ModularHeldPartModels = self.ModularHeldPartModels or {}
	self.ModularHeldPartPaths = self.ModularHeldPartPaths or {}
	local positioned = {}

	local function positionPart(partName)
		if positioned[partName] then return positioned[partName] end
		local partData = parts[partName]
		if not istable(partData) then return end

		local modelPath = self:GetModularPartModel(partName, partData.model, "held")
		local model = self.ModularHeldPartModels[partName]
		if not isstring(modelPath) or modelPath == "" then
			if IsValid(model) then model:Remove() end
			self.ModularHeldPartModels[partName] = nil
			self.ModularHeldPartPaths[partName] = nil
			return
		end
		if IsValid(model) and self.ModularHeldPartPaths[partName] ~= modelPath then
			model:Remove()
			model = nil
		end
		if not IsValid(model) then
			model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
			if not IsValid(model) then return end
			model:SetNoDraw(true)
			self.ModularHeldPartModels[partName] = model
			self.ModularHeldPartPaths[partName] = modelPath
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

		local partPos, partAng = partData.pos or vector_origin, partData.ang or angle_zero
		if partName == "magazine" and self.HeldMagOffsetPos then
			partPos, partAng = self.HeldMagOffsetPos, self.HeldMagOffsetAng or partAng
		end
		local pos, ang = LocalToWorld(partPos, partAng, basePos, baseAng)
		pos, ang = self:ApplyManagedStockPartOffset(partName, pos, ang)
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

	for partName in pairs(parts) do positionPart(partName) end
	for partName in pairs(parts) do
		local model = positioned[partName]
		if IsValid(model) then model:DrawModel() end
	end

	self.HeldMagCSModel = positioned.magazine
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	self:DrawModularParts()
end

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)

SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local MOD_VECTOR_ZERO = Vector(0, 0, 0)
	local MOD_ANGLE_ZERO = Angle(0, 0, 0)

	function SWEP:ModularCreateDroppedFakeModel()
		if not self.WorldModelFake then return end
		if IsValid(self.ModularDroppedFakeWorldModel) then return end

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
		if self.FakeSkin ~= nil then model:SetSkin(self.FakeSkin) end

		if self.ModelCreated then
			self:ModelCreated(model)
		end

		self.ModularDroppedFakeWorldModel = model
	end

	function SWEP:ModularCreateDroppedModels()
		local parts = self.ModularParts
		if not istable(parts) then return end

		self.ModularDroppedPartModels = self.ModularDroppedPartModels or {}
		self.ModularDroppedPartPaths = self.ModularDroppedPartPaths or {}

		for partName, partData in pairs(parts) do
			if not istable(partData) or not isstring(partData.model) or partData.model == "" then
				continue
			end
			local modelPath = self:GetModularPartModel(partName, partData.model, "world")

			local model = self.ModularDroppedPartModels[partName]
			local oldPath = self.ModularDroppedPartPaths[partName]
			if not isstring(modelPath) or modelPath == "" then
				if IsValid(model) then model:Remove() end
				self.ModularDroppedPartModels[partName] = nil
				self.ModularDroppedPartPaths[partName] = nil
				continue
			end

			if IsValid(model) and oldPath ~= modelPath then
				model:Remove()
				model = nil
			end

			if not IsValid(model) then
				model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.ModularDroppedPartModels[partName] = model
					self.ModularDroppedPartPaths[partName] = modelPath
				end
			end
		end
	end

	function SWEP:ModularRemoveDroppedModels()
		if self.ModularDroppedPartModels then
			for partName, model in pairs(self.ModularDroppedPartModels) do
				if IsValid(model) then model:Remove() end
			end
		end
		self.ModularDroppedPartModels = nil
		self.ModularDroppedPartPaths = nil

		if IsValid(self.ModularDroppedFakeWorldModel) then
			self.ModularDroppedFakeWorldModel:Remove()
		end
		self.ModularDroppedFakeWorldModel = nil
	end

	local function ModularApplyPartAppearance(model, partData)
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

	function SWEP:ModularDrawDroppedModel()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end

		if not IsValid(self.ModularDroppedFakeWorldModel) then
			self:ModularCreateDroppedFakeModel()
		end

		self:ModularCreateDroppedModels()

		local basePosition, baseAngles = LocalToWorld(
			self.WorldPartsOffsetPos or MOD_VECTOR_ZERO,
			self.WorldPartsOffsetAng or MOD_ANGLE_ZERO,
			self:GetPos(),
			self:GetAngles()
		)

		local fake = self.ModularDroppedFakeWorldModel
		local parts = self.ModularParts

		if IsValid(fake) then
			fake:SetRenderOrigin(basePosition)
			fake:SetRenderAngles(baseAngles)
			fake:SetPos(basePosition)
			fake:SetAngles(baseAngles)
			fake:SetupBones()
		end

		if istable(parts) and istable(self.ModularDroppedPartModels) then
			local positioned = {}
			local function positionPart(partName)
				if positioned[partName] then return positioned[partName] end
				local partData = parts[partName]
				local model = self.ModularDroppedPartModels[partName]
				if not IsValid(model) or not istable(partData) then return end

				local boneName = partData.bone or ""
				local extraPosition = MOD_VECTOR_ZERO
				local extraAngles = MOD_ANGLE_ZERO

				if partName == "magazine" and self.WorldMagazineBoneOverride then
					boneName = self.WorldMagazineBoneOverride
					extraPosition = self.WorldMagazineOffsetPos or MOD_VECTOR_ZERO
					extraAngles = self.WorldMagazineOffsetAng or MOD_ANGLE_ZERO
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

				local localPosition = (partData.pos or MOD_VECTOR_ZERO) + extraPosition
				local localAngles = Angle(
					(partData.ang or MOD_ANGLE_ZERO).p,
					(partData.ang or MOD_ANGLE_ZERO).y,
					(partData.ang or MOD_ANGLE_ZERO).r
				)
				localAngles:Add(extraAngles)

				local position, angles = LocalToWorld(localPosition, localAngles, partBasePosition, partBaseAngles)
				position, angles = self:ApplyManagedStockPartOffset(partName, position, angles)

				model:SetRenderOrigin(position)
				model:SetRenderAngles(angles)
				model:SetPos(position)
				model:SetAngles(angles)
				model:SetupBones()

				ModularApplyPartAppearance(model, partData)
				positioned[partName] = model
				return model
			end

			for partName in pairs(parts) do
				positionPart(partName)
			end
		end

		if IsValid(fake) then
			fake:DrawModel()
		end

		if istable(parts) and istable(self.ModularDroppedPartModels) then
			for partName, partData in pairs(parts) do
				local model = self.ModularDroppedPartModels[partName]
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
		self:ModularDrawDroppedModel()
	end

	function SWEP:DrawWorldModelTranslucent()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:ModularDrawDroppedModel()
	end

	function SWEP:OnRemove()
		self:ModularRemoveDroppedModels()
		self:CleanupARC9DefaultLHIKSource()
		for _, model in pairs(self.ModularHeldPartModels or {}) do
			if IsValid(model) then model:Remove() end
		end
		self.ModularHeldPartModels = nil
		self.ModularHeldPartPaths = nil
		self.HeldMagCSModel = nil
	end
end

--========================================================
-- FIRE ANIMATION
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
	self:PlayAnim("fire", self.FireAnimTime, false, function()
		if not IsValid(self) then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end
