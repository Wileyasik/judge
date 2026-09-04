--made by lazzy https://steamcommunity.com/id/TimeToFuckinDie
SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "SCAR-L"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Selective-fire assault rifle chambered in 5.56x45 mm\n\nRate of fire 600 rounds per minute"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.WeaponRecoilMul = 0.7
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_scarl.mdl"

SWEP.FakePos = Vector(-12, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-4.5, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "122175522221"
SWEP.FakeSkin = 1
SWEP.ZoomPos = Vector(0, -1.7659, 6.4406)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 1

SWEP.ModularParts = {
	pistolgrip = {
		model = "models/weapons/mods/pistolgrip_ar15_hk_grip_v2.mdl",
		bonemerge = false,
		bone = "mod_pistol_grip",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0)
	},
	magazine = {
		model = "models/weapons/mods/mag_stanag_magpul_pmag_gen_m3_window_556x45_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 1, 0),
		ang = Angle(0, -90, 0),
		skin = 1
	},
}

SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)
SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_stanag_magpul_pmag_gen_m3_window_556x45_30.mdl"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_mag_out.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in3.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_mag_in.ogg") end,
	},
	["reload_empty0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_mag_release_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_mag_out.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/scar/scar_hammer_release.wav") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "look0",
}

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 48
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 40
SWEP.Primary.Sound = {"weapons/darsu_eft/scar/fire_new/scar_h_outdoor_close1.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/scar/fire_new/scar_h_outdoor_silenced_close3.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.09917
SWEP.ReloadTime = 3
SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false
SWEP.animposmul = 2

SWEP.PPSMuzzleEffect = "muzzleflash_m3"
SWEP.CustomShell = "556x45"
SWEP.ShellEject = "EjectBrass_556"

SWEP.LocalMuzzlePos = Vector(20.2, -1.75, 4.3)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"
SWEP.weight = 3.6
SWEP.ScrappersSlot = "Primary"

SWEP.WorldPos = Vector(4, -0.8, -0.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(1, 0, 0)
SWEP.attAng = Angle(-0.02, 0, 0)
SWEP.lengthSub = 25
SWEP.handsAng = Angle(7, 2, 0)
SWEP.DistSound = "weapons/darsu_eft/scarh/scarh_dist.wav"

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)

SWEP.RHandPos = Vector(0, -1, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.RHPos = Vector(3, -7, 3.5)
SWEP.RHAng = Angle(0, -8, 90)
SWEP.LHPos = Vector(11, 1.6, -3)
SWEP.LHAng = Angle(-110, -180, 5)
SWEP.ShootAnimMul = 2

SWEP.Penetration = 19

SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.0, 0, 0) * 1
end

SWEP.Ergonomics = 0.85

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_scarl.png")
SWEP.IconOverride = "entities/arc9_eft_scarl.png"

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)

SWEP.StartAtt = {}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor5", Vector(0, 0, 0), {}},
		[2] = {"supressor6", Vector(0, 0, 0), {}},
		[3] = {"supressor15", Vector(1.3, 0, 0), {}},
		["mount"] = Vector(-1, 0.15, 0),
	},
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-18, 2, 0.05)},
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(8.5, 0.3, 0)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0,0,0)
	},
	underbarrel = {
		["mount"] = Vector(8, 0, 0.2),
		["mountAngle"] = Angle(0, -0.75,0),
		["mountType"] = "picatinny_small"
	},
	magwell = {
		["mountType"] = "stanag_556_60",
	},
}

local path = "weapons/darsu_eft/scarl/"

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

	if self.FakeSkin ~= nil then
		model:SetSkin(self.FakeSkin)
	end

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

function SWEP:AnimHoldPost(model)
end

function SWEP:GetModularPartModel(partName, fallback, role)
	if partName == "magazine" then
		return self:GetActiveMagazineModel(fallback, role)
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
