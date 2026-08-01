SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MK11 Taupe"
SWEP.Author = "Knight's Armament Company"
SWEP.Instructions = "Semi-automatic DMR chambered in 7.62x51 NATO\n\nRate of fire ~200 rounds per minute"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 11
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_sr25.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "MK11"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/mods/mag_fal_mmw_fal_sa58_762x51_20.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 2, -2),
		ang = Angle(0, -90, 0)
	},
	handguard = {
		model = "models/weapons/mods/handguard_ar10_kac_sr25_urx_2_125_inch.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -17.23, 0.165),
		ang = Angle(0, 0, 0),
		skin = 1,
		bodygroups = {[1] = 1},
	},
	pistolgrip = {
		model = "models/weapons/mods/pistolgrip_ar15_hk_grip_v2.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -11.2, -2),
		ang = Angle(0, -90, 0)
	},
	stock = {
		model = "models/weapons/mods/stock_ar15_cgnl_stock_tube.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -8.1, 0),
		ang = Angle(0, -90, 0)
	},
	stock1 = {
		model = "models/weapons/mods/stock_ar15_kac_m110_sass.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -4.27, -0.9),
		ang = Angle(0, -90, 0)
	},
	suppressor = {
		model = "models/weapons/mods/silencer_base_kac_sr25_mk11_suppressor_762x51.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -25, 0),
		ang = Angle(0, -90, 0),
		skin = 1,
	},
}

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/handguard_ar10_kac_sr25_urx_2_125_inch.mdl"

SWEP.FakePos = Vector(-13, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(9, 0, -0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "112100"
SWEP.FakeSkin = 1
SWEP.ZoomPos = Vector(0, -1.7731, 5.9203)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.Podkid = 25
SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 45
SWEP.punchmul = 4
SWEP.punchspeed = 0.7

SWEP.AnimShootMul = 2
SWEP.AnimShootHandMul = 6

local path_reload = "weapons/darsu_eft/sa58/"

SWEP.AnimsEvents = {
	["inspect0"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_out.ogg") end,
		[0.55] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_in.ogg") end,
	},
	["reload_empty0_0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_release_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_out.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_release_button.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["inspect"] = "inspect0",
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

	if self.FakeSkin then
		model:SetSkin(self.FakeSkin)
	end

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.HeldMagModel = "models/weapons/mods/mag_fal_mmw_fal_sa58_762x51_20.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, -0.8, -1.4)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_ar10_lancer_l7_awm_762x51_25.mdl"

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
end

SWEP.HeldGripModel = "models/weapons/mods/pistolgrip_ar15_hk_grip_v2.mdl"
SWEP.HeldGripBone = "weapon"
SWEP.HeldGripOffsetPos = Vector(0, -11.2, -2)
SWEP.HeldGripOffsetAng = Angle(0, -90, 0)

SWEP.HeldStockModel = "models/weapons/mods/stock_ar15_cgnl_stock_tube.mdl"
SWEP.HeldStockBone = "weapon"
SWEP.HeldStockOffsetPos = Vector(0, -8.1, 0)
SWEP.HeldStockOffsetAng = Angle(0, -90, 0)

SWEP.HeldHandguardModel = "models/weapons/mods/handguard_ar10_kac_sr25_urx_2_125_inch.mdl"
SWEP.HeldHandguardBone = "weapon"
SWEP.HeldHandguardOffsetPos = Vector(0, -17.23, 0.165)
SWEP.HeldHandguardOffsetAng = Angle(0, 0, 0)

SWEP.HeldStock1Model = "models/weapons/mods/stock_ar15_kac_m110_sass.mdl"
SWEP.HeldStock1Bone = "weapon"
SWEP.HeldStock1OffsetPos = Vector(0, -4.27, -0.9)
SWEP.HeldStock1OffsetAng = Angle(0, -90, 0)

SWEP.HeldSuppressorModel = "models/weapons/mods/silencer_base_kac_sr25_mk11_suppressor_762x51.mdl"
SWEP.HeldSuppressorBone = "weapon"
SWEP.HeldSuppressorOffsetPos = Vector(0, -25, 0.05)
SWEP.HeldSuppressorOffsetAng = Angle(0, -90, 0)
SWEP.HeldSuppressorSkin = 1

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 65
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 30
SWEP.Primary.Sound = {"weapons/darsu_eft/sr25/sr25_fire_outdoor_close.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/sr25/sr25_fire_outdoor_silenced_close.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/mk18/mk18_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.2
SWEP.ReloadTime = 3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_suppressed"

SWEP.CustomShell = "762x51"
SWEP.ShellEject = "EjectBrass_762"

SWEP.LocalMuzzlePos = Vector(25.2, -1.75, 4.2)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_sr25.png")
SWEP.IconOverride = "entities/arc9_eft_sr25.png"

SWEP.weight = 4.3
SWEP.ScrappersSlot = "Primary"

SWEP.DistSound = "weapons/darsu_eft/sr25/sr25_fire_outdoor_distant.wav"
SWEP.SupressorOnly = true

SWEP.SetSupressor = true
SWEP.StartAtt = {"optic5"}
SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-21.5, 1.45, 0.05)},
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(2, 0.3, 0.15)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0, 0, 0)
	},
	underbarrel = {
		["mount"] = Vector(3.1, -0.15, 0.15),
		["mountAngle"] = Angle(0, -0.75,0),
		["mountType"] = "picatinny_small"
	},
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 15
SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.03 - math.cos(i) * 0.02, math.cos(i * i) * 0.04, 0) * 1.5
end

SWEP.SprayRand = {Angle(-0.08, -0.06, 0), Angle(-0.12, 0.06, 0)}

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

SWEP.ShootAnimMul = 4


function SWEP:AnimHoldPost(model)
end

local vector_full = Vector(1,1,1)
local vecPochtiZero = Vector(0.01,0.01,0.01)

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	local wm = self:GetWM()
	if not IsValid(wm) then return end

	-- Bolt manipulation on empty reload
	self.shooanim = LerpFT(0.4, self.shooanim or 0, self:Clip1() > 0 and 0 or 0)
	wep:ManipulateBonePosition(54, Vector(0, 1.8 * self.shooanim, 0), false)

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

	-- Stock
	if not IsValid(self.HeldStockCSModel) then
		self.HeldStockCSModel = ClientsideModel(self.HeldStockModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldStockCSModel) then self.HeldStockCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldStockCSModel) then
		local boneID = wm:LookupBone(self.HeldStockBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldStockOffsetPos, self.HeldStockOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldStockCSModel:SetRenderOrigin(lpos)
				self.HeldStockCSModel:SetRenderAngles(lang)
				self.HeldStockCSModel:SetPos(lpos)
				self.HeldStockCSModel:SetAngles(lang)
				self.HeldStockCSModel:SetupBones()
				self.HeldStockCSModel:DrawModel()
			end
		end
	end

	-- Stock1
	if not IsValid(self.HeldStock1CSModel) then
		self.HeldStock1CSModel = ClientsideModel(self.HeldStock1Model, RENDERGROUP_BOTH)
		if IsValid(self.HeldStock1CSModel) then self.HeldStock1CSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldStock1CSModel) then
		local boneID = wm:LookupBone(self.HeldStock1Bone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldStock1OffsetPos, self.HeldStock1OffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldStock1CSModel:SetRenderOrigin(lpos)
				self.HeldStock1CSModel:SetRenderAngles(lang)
				self.HeldStock1CSModel:SetPos(lpos)
				self.HeldStock1CSModel:SetAngles(lang)
				self.HeldStock1CSModel:SetupBones()
				self.HeldStock1CSModel:DrawModel()
			end
		end
	end

	-- Magazine
	if not IsValid(self.HeldMagCSModel) then
		self.HeldMagCSModel = ClientsideModel(self.HeldMagModel, RENDERGROUP_BOTH)
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

	-- Handguard
	if not IsValid(self.HeldHandguardCSModel) then
		self.HeldHandguardCSModel = ClientsideModel(self.HeldHandguardModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldHandguardCSModel) then
			self.HeldHandguardCSModel:SetNoDraw(true)
			self.HeldHandguardCSModel:SetSkin(1)
			self.HeldHandguardCSModel:SetBodygroup(1, 1)
		end
	end
	if IsValid(self.HeldHandguardCSModel) then
		local boneID = wm:LookupBone(self.HeldHandguardBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldHandguardOffsetPos, self.HeldHandguardOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldHandguardCSModel:SetRenderOrigin(lpos)
				self.HeldHandguardCSModel:SetRenderAngles(lang)
				self.HeldHandguardCSModel:SetPos(lpos)
				self.HeldHandguardCSModel:SetAngles(lang)
				self.HeldHandguardCSModel:SetupBones()
				self.HeldHandguardCSModel:DrawModel()
			end
		end
	end

	-- Suppressor
	if not IsValid(self.HeldSuppressorCSModel) then
		self.HeldSuppressorCSModel = ClientsideModel(self.HeldSuppressorModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldSuppressorCSModel) then
			self.HeldSuppressorCSModel:SetNoDraw(true)
			if self.HeldSuppressorSkin then
				self.HeldSuppressorCSModel:SetSkin(self.HeldSuppressorSkin)
			end
		end
	end
	if IsValid(self.HeldSuppressorCSModel) then
		local boneID = wm:LookupBone(self.HeldSuppressorBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldSuppressorOffsetPos, self.HeldSuppressorOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldSuppressorCSModel:SetRenderOrigin(lpos)
				self.HeldSuppressorCSModel:SetRenderAngles(lang)
				self.HeldSuppressorCSModel:SetPos(lpos)
				self.HeldSuppressorCSModel:SetAngles(lang)
				self.HeldSuppressorCSModel:SetupBones()
				self.HeldSuppressorCSModel:DrawModel()
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

		if self.FakeSkin then
			model:SetSkin(self.FakeSkin)
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
		if IsValid(self.HeldMagCSModel) then self.HeldMagCSModel:Remove() end
		if IsValid(self.HeldGripCSModel) then self.HeldGripCSModel:Remove() end
		if IsValid(self.HeldHandguardCSModel) then self.HeldHandguardCSModel:Remove() end
		if IsValid(self.HeldStockCSModel) then self.HeldStockCSModel:Remove() end
		if IsValid(self.HeldStock1CSModel) then self.HeldStock1CSModel:Remove() end
		if IsValid(self.HeldSuppressorCSModel) then self.HeldSuppressorCSModel:Remove() end
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
