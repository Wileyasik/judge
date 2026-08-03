SWEP.Base = "homigrad_base"
SWEP.ARC9ActionLHIKFadeOutTime = 0.1
SWEP.ARC9ActionLHIKFadeInTime = 0.5
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "TX-15"
SWEP.Author = "Lone Star Arms"
SWEP.Instructions = "Lightweight semi-automatic rifle chambered in 5.56x45 mm\n\nRate of fire 600 rounds per minute"
SWEP.Category = "Weapons - Carbines"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_tx15.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "TX-15"

SWEP.UseARC9Parts = true

SWEP.ARC9Parts = {
	receiver = {
		model = "models/weapons/mods/reciever_ar15_lone_star_tx15_lightweight.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0)
	},
	magazine = {
		model = "models/weapons/mods/mag_stanag_hk_416_steel_maritime_556x45_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 1.1, 0),
		ang = Angle(0, -90, 0)
	},
	pistolgrip = {
		model = "models/weapons/mods/pistolgrip_ar15_hera_arms_hg15.mdl",
		bonemerge = false,
		bone = "mod_pistol_grip",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0)
	},
	stock = {
		model = "models/weapons/mods/stock_ar15_cgnl_stock_tube.mdl",
		bonemerge = false,
		bone = "mod_stock",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0)
	},
	stock2 = {
		model = "models/weapons/mods/stock_ar15_hk_slim_line.mdl",
		bonemerge = false,
		bone = "mod_stock",
		pos = Vector(0, 2.25, -0.8),
		ang = Angle(0, -90, 0)
	},
	charge = {
		model = "models/weapons/mods/charge_ar15_colt_charging_handle.mdl",
		bonemerge = false,
		bone = "mod_charge",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0)
	},
	barrel = {
		model = "models/weapons/mods/barrel_ar15_457mm.mdl",
		bonemerge = false,
		bone = "mod_stock",
		pos = Vector(0, -9, 0),
		ang = Angle(0, -90, 0)
	},
	handguard = {
		model = "models/weapons/mods/handguard_ar15_sai_qd_rail_long.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, -0.26, 1),
		ang = Angle(0, 0, 0)
	},
}

SWEP.FakePos = Vector(-12, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-2, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.ZoomPos = Vector(0, -1.7726, 5.3837)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 1

local path = "weapons/darsu_eft/m4a1/"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload3"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_out1.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in3.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_in1.ogg") end,
	},
	["reload_empty3"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_out1.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_in1.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_bolt_in.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload3",
	["reload_empty"] = "reload_empty3",
	["inspect"] = "look_1",
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
end

SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/handguard_ar15_sai_qd_rail_long.mdl"

SWEP.HeldReceiverModel = "models/weapons/mods/reciever_ar15_lone_star_tx15_lightweight.mdl"
SWEP.HeldReceiverBone = "mod_reciever"
SWEP.HeldReceiverOffsetPos = Vector(0, 0, 0)
SWEP.HeldReceiverOffsetAng = Angle(0, -90, 0)

SWEP.HeldMagModel = "models/weapons/mods/mag_stanag_hk_416_steel_maritime_556x45_30.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_stanag_colt_ar15_std_556x45_30.mdl"

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
				self:GetWM():ManipulateBoneScale(38, vector_origin)
				self:GetWM():ManipulateBoneScale(39, vector_origin)
				self:GetWM():ManipulateBoneScale(40, vector_origin)
			end)
		end,
	}
end

SWEP.HeldPistolgripModel = "models/weapons/mods/pistolgrip_ar15_hera_arms_hg15.mdl"
SWEP.HeldPistolgripBone = "mod_pistol_grip"
SWEP.HeldPistolgripOffsetPos = Vector(0, 0, 0)
SWEP.HeldPistolgripOffsetAng = Angle(0, -90, 0)

SWEP.HeldStockModel = "models/weapons/mods/stock_ar15_cgnl_stock_tube.mdl"
SWEP.HeldStockBone = "mod_stock"
SWEP.HeldStockOffsetPos = Vector(0, 0, 0)
SWEP.HeldStockOffsetAng = Angle(0, -90, 0)

SWEP.HeldStock1Model = "models/weapons/mods/stock_ar15_hk_slim_line.mdl"
SWEP.HeldStock1Bone = "mod_stock"
SWEP.HeldStock1OffsetPos = Vector(0, 2.8, -0.8)
SWEP.HeldStock1OffsetAng = Angle(0, -90, 0)

SWEP.HeldChargeModel = "models/weapons/mods/charge_ar15_colt_charging_handle.mdl"
SWEP.HeldChargeBone = "mod_charge"
SWEP.HeldChargeOffsetPos = Vector(0, 0, 0)
SWEP.HeldChargeOffsetAng = Angle(0, -90, 0)

SWEP.HeldBarrelModel = "models/weapons/mods/barrel_ar15_457mm.mdl"
SWEP.HeldBarrelBone = "mod_reciever"
SWEP.HeldBarrelOffsetPos = Vector(0, 0, 1)
SWEP.HeldBarrelOffsetAng = Angle(0, -90, 0)

SWEP.HeldHandguardModel = "models/weapons/mods/handguard_ar15_sai_qd_rail_long.mdl"
SWEP.HeldHandguardBone = "mod_reciever"
SWEP.HeldHandguardOffsetPos = Vector(0, -0.26, 1)
SWEP.HeldHandguardOffsetAng = Angle(0, 0, 0)

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 33
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 28
SWEP.animposmul = 2
SWEP.Primary.Sound = {"weapons/darsu_eft/m4a1/fire_new/tx15_fire_outdoor_close.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/m4a1/fire_new/tx15_fire_outdoor_silenced_close.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.1
SWEP.ReloadTime = 3

SWEP.PPSMuzzleEffect = "muzzleflash_m3"

SWEP.CustomShell = "556"
SWEP.ShellEject = "EjectBrass_556"

SWEP.LocalMuzzlePos = Vector(21, -1.7, 4.2)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_tx15.png")
SWEP.IconOverride = "entities/arc9_eft_tx15.png"

SWEP.weight = 3.2
SWEP.ScrappersSlot = "Primary"

SWEP.DistSound = "weapons/darsu_eft/m4a1/fire_new/tx15_fire_outdoor_close.wav"

SWEP.StartAtt = {"optic8", "stock_ar15_hk_slim_line"}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor5", Vector(-0.4, 0, 0), {}},
		[2] = {"supressor6", Vector(-0.3, 0, 0), {}},
		[3] = {"supressor15", Vector(1, 0, 0), {}},
		["mount"] = Vector(-0.5, 0.05, 0),
	},
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-20, 1.2, 0.045)},
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(7, 0.4, 0.15)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0,0,0)
	},
	underbarrel = {
		["mount"] = Vector(4.5, -0.1, -0.2),
		["mountAngle"] = Angle(0, -0.75,0),
		["mountType"] = "picatinny_small"
	},
	magwell = {
		["mountType"] = {"stanag_556_60", "stanag_556_100"},
	},
	stock = hg.GetAR15StockProfile("stock_ar15_hk_slim_line"),
}

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.Penetration = 15
SWEP.Spray = {}
for i = 1, 20 do
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

	-- Receiver
	if not IsValid(self.HeldReceiverCSModel) then
		self.HeldReceiverCSModel = ClientsideModel(self.HeldReceiverModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldReceiverCSModel) then self.HeldReceiverCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldReceiverCSModel) then
		local boneID = wm:LookupBone(self.HeldReceiverBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldReceiverOffsetPos, self.HeldReceiverOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldReceiverCSModel:SetRenderOrigin(lpos)
				self.HeldReceiverCSModel:SetRenderAngles(lang)
				self.HeldReceiverCSModel:SetPos(lpos)
				self.HeldReceiverCSModel:SetAngles(lang)
				self.HeldReceiverCSModel:SetupBones()
				self.HeldReceiverCSModel:DrawModel()
			end
		end
	end

	-- Magazine
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

	-- Pistolgrip
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
	local heldStockModel = self:GetActiveStockModel(self.HeldStock1Model)
	if IsValid(self.HeldStock1CSModel) and self.HeldStock1CSModelPath ~= heldStockModel then
		self.HeldStock1CSModel:Remove()
	end
	if heldStockModel ~= "" and not IsValid(self.HeldStock1CSModel) then
		self.HeldStock1CSModel = ClientsideModel(heldStockModel, RENDERGROUP_BOTH)
		self.HeldStock1CSModelPath = heldStockModel
		if IsValid(self.HeldStock1CSModel) then self.HeldStock1CSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldStock1CSModel) then
		local boneID = wm:LookupBone(self.HeldStock1Bone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldStock1OffsetPos, self.HeldStock1OffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				lpos, lang = self:ApplyStockAttachmentOffset(lpos, lang)
				self.HeldStock1CSModel:SetRenderOrigin(lpos)
				self.HeldStock1CSModel:SetRenderAngles(lang)
				self.HeldStock1CSModel:SetPos(lpos)
				self.HeldStock1CSModel:SetAngles(lang)
				self.HeldStock1CSModel:SetupBones()
				self.HeldStock1CSModel:DrawModel()
			end
		end
	end

	-- Charge
	if not IsValid(self.HeldChargeCSModel) then
		self.HeldChargeCSModel = ClientsideModel(self.HeldChargeModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldChargeCSModel) then self.HeldChargeCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldChargeCSModel) then
		local boneID = wm:LookupBone(self.HeldChargeBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldChargeOffsetPos, self.HeldChargeOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldChargeCSModel:SetRenderOrigin(lpos)
				self.HeldChargeCSModel:SetRenderAngles(lang)
				self.HeldChargeCSModel:SetPos(lpos)
				self.HeldChargeCSModel:SetAngles(lang)
				self.HeldChargeCSModel:SetupBones()
				self.HeldChargeCSModel:DrawModel()
			end
		end
	end

	-- Barrel
	if not IsValid(self.HeldBarrelCSModel) then
		self.HeldBarrelCSModel = ClientsideModel(self.HeldBarrelModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldBarrelCSModel) then self.HeldBarrelCSModel:SetNoDraw(true) end
	end
	if IsValid(self.HeldBarrelCSModel) then
		local boneID = wm:LookupBone(self.HeldBarrelBone)
		if boneID then
			local boneMatrix = wm:GetBoneMatrix(boneID)
			if boneMatrix then
				local lpos, lang = LocalToWorld(self.HeldBarrelOffsetPos, self.HeldBarrelOffsetAng, boneMatrix:GetTranslation(), boneMatrix:GetAngles())
				self.HeldBarrelCSModel:SetRenderOrigin(lpos)
				self.HeldBarrelCSModel:SetRenderAngles(lang)
				self.HeldBarrelCSModel:SetPos(lpos)
				self.HeldBarrelCSModel:SetAngles(lang)
				self.HeldBarrelCSModel:SetupBones()
				self.HeldBarrelCSModel:DrawModel()
			end
		end
	end

	-- Handguard
	if not IsValid(self.HeldHandguardCSModel) then
		self.HeldHandguardCSModel = ClientsideModel(self.HeldHandguardModel, RENDERGROUP_BOTH)
		if IsValid(self.HeldHandguardCSModel) then self.HeldHandguardCSModel:SetNoDraw(true) end
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
			if partName == "stock2" then modelPath = self:GetActiveStockModel(modelPath) end

			local model = self.BC_DroppedPartModels[partName]
			local oldPath = self.BC_DroppedPartPaths[partName]

			if IsValid(model) and oldPath ~= modelPath then
				model:Remove()
				model = nil
			end

			if modelPath ~= "" and not IsValid(model) then
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
				position, angles = self:ApplyManagedStockPartOffset(partName, position, angles)

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
		if IsValid(self.HeldReceiverCSModel) then self.HeldReceiverCSModel:Remove() end
		if IsValid(self.HeldMagCSModel) then self.HeldMagCSModel:Remove() end
		if IsValid(self.HeldPistolgripCSModel) then self.HeldPistolgripCSModel:Remove() end
		if IsValid(self.HeldStockCSModel) then self.HeldStockCSModel:Remove() end
		if IsValid(self.HeldStock1CSModel) then self.HeldStock1CSModel:Remove() end
		if IsValid(self.HeldChargeCSModel) then self.HeldChargeCSModel:Remove() end
		if IsValid(self.HeldBarrelCSModel) then self.HeldBarrelCSModel:Remove() end
		if IsValid(self.HeldHandguardCSModel) then self.HeldHandguardCSModel:Remove() end
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
	self:PlayAnim("fire", self.FireAnimTime, false)

	local timerName = "BC_FireAnimation_" .. self:EntIndex()
	timer.Create(timerName, self.FireAnimTime, 1, function()
		if not IsValid(self) or self.reload then return end
		if self.Primary and (self.Primary.Next or 0) > CurTime() then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end
