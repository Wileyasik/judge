--made by lazzy https://steamcommunity.com/id/TimeToFuckinDie
SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "DSA SA58"
SWEP.Author = "DS Arms"
SWEP.Instructions = "Semi-automatic battle rifle chambered in 7.62x51 mm\n\nRate of fire 400 rounds per minute"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.WeaponRecoilMul = 0.7
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/handguard_fal_vltor_casv_fas.mdl"

SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_dsa_sa58.mdl"

SWEP.FakePos = Vector(-13, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-1, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "1113110"
SWEP.ZoomPos = Vector(0, -1.7755, 6.3946)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 150

SWEP.ModularParts = {
	magazine = {
		model = "models/weapons/mods/mag_fal_sarco_fal_l1a1_orig_762x51_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, -3, -1),
		ang = Angle(0, -90, 0)
	},
	handguard = {
		model = "models/weapons/mods/handguard_fal_vltor_casv_fas.mdl",
		bonemerge = false,
		bone = "mod_handguard",
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0)
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
SWEP.MagModel = "models/weapons/mods/mag_fal_sarco_fal_l1a1_orig_762x51_30.mdl"

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_out.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in3.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_in.ogg") end,
	},
	["reload_empty0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_release_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_out.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/sa58/fal_mag_release_button.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "look",
}

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x51 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 52
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 45
SWEP.Primary.Sound = {"weapons/darsu_eft/sa58/fire_new/fal_outdoor_close_loop3.wav", 85, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/sa58/fire_new/fal_outdoor_close_silenced_loop3.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.090
SWEP.ReloadTime = 3
SWEP.ReloadHold = nil
SWEP.FakeVPShouldUseHand = false
SWEP.animposmul = 2

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"
SWEP.CustomShell = "762x51"
SWEP.ShellEject = "EjectBrass_762"

SWEP.LocalMuzzlePos = Vector(21.7, -1.7, 4.6)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"
SWEP.weight = 4.2
SWEP.ScrappersSlot = "Primary"

SWEP.WorldPos = Vector(4, -0.8, -0.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(1, 0, 0)
SWEP.attAng = Angle(-0.02, 0, 0)
SWEP.lengthSub = 30
SWEP.handsAng = Angle(7, 2, 0)
SWEP.DistSound = "weapons/darsu_eft/sa58/fire_new/fal_outdoor_close_loop3.wav"

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

SWEP.Ergonomics = 0.80

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_sa58.png")
SWEP.IconOverride = "entities/arc9_eft_sa58.png"

SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)

SWEP.StartAtt = {}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor9", Vector(1, 0, 0), {}},
		[2] = {"supressor16", Vector(0.2, 0, 0), {}},
		[3] = {"supressor15", Vector(0.2, 0, 0), {}},
		["mount"] = Vector(-0.8, 0, 0),
	},
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-16, 1.6, 0.050)},
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(10, 0.55, 0.15)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0,0,0)
	},
	underbarrel = {
		["mount"] = Vector(8, -0.1, -0.1),
		["mountAngle"] = Angle(0, -0.75,0),
		["mountType"] = "picatinny_small"
	},
}

local path = "weapons/darsu_eft/sa58/"

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
