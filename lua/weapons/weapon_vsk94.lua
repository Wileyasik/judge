SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "VSK-94"
SWEP.Author = "KBP Instrument Design Bureau"
SWEP.Instructions = "Suppressed rifle chambered in 9x39 mm"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_vsk94.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "VSK-94"



SWEP.FakePos = Vector(-13, 2.52, 7.5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(11, 0, 0.5)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "111122311600"
SWEP.ZoomPos = Vector(0, -1.764, 6.1512)

SWEP.GunCamPos = Vector(4, -15, -6)
SWEP.GunCamAng = Angle(190, -5, -100)

SWEP.FakeEjectBrassATT = "2"

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 70

SWEP.DOZVUK = true
SWEP.dwr_customIsSuppressed = true
SWEP.Supressor = true
SWEP.SupressorOnly = true
SWEP.SetSupressor = true

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_val2_30.mdl"

local path = "weapons/darsu_eft/val/"

SWEP.AnimsEvents = {
	["look0"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/val/val_magout.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/val/val_magin.ogg") end,
	},
	["reload_empty0_0"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/val/val_magout.ogg") end,
		[0.35] = function(self) self:EmitSound("weapons/darsu_eft/val/val_magin.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/val/val_boltout.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/val/val_boltin.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
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


SWEP.weaponInvCategory = 1
SWEP.CustomEjectAngle = Angle(0, 0, 90)
SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9x39 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 42
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 42
SWEP.animposmul = 2
SWEP.Primary.Sound = {"weapons/darsu_eft/val/fire_new/vss_loop_close2.wav", 65, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/val/fire_new/vss_loop_close2.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"weapons/darsu_eft/val/val_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.066
SWEP.ReloadTime = 3.3

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"

SWEP.CustomShell = "9x39"
SWEP.ShellEject = "EjectBrass_9x39"

SWEP.LocalMuzzlePos = Vector(22.5, -1.75, 4.7)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.HoldType = "rpg"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_vsk94.png")
SWEP.IconOverride = "entities/arc9_eft_vsk94.png"

SWEP.weight = 3.0
SWEP.ScrappersSlot = "Primary"

SWEP.ShockMultiplier = 3

SWEP.DistSound = "weapons/darsu_eft/val/val_dist.wav"

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"dovetail", "picatinny"},
		["mount"] = {["dovetail"] = Vector(-22, -0.4, 1.8), ["picatinny"] = Vector(-22, 0.05, 2)},
		["mountAngle"] = Angle(0,0,90),
	},

	mount = {
		mountAngle = Angle(0, 90, 0),
		["picatinny"] = {"mount3", Vector(-23, 0.9, -0.1), {}, mountType = "picatinny"},
		["dovetail"] = {"empty", Vector(1, 0, 0), {}, mountType = "dovetail"},
	},
}

SWEP.RHandPos = Vector(4, -5.5, 3.5)
SWEP.LHandPos = Vector(12, 0.2, -3.5)
SWEP.Penetration = 15
SWEP.Spray = {}
for i = 1, 20 do
	SWEP.Spray[i] = Angle(-0.03 - math.cos(i) * 0.02, math.cos(i * i) * 0.06, 0) * 1
end

SWEP.Ergonomics = 0.9
SWEP.WorldPos = Vector(3, -1, 1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, -0.5)
SWEP.attAng = Angle(-0, 0.05, 0)
SWEP.lengthSub = 15
SWEP.handsAng = Angle(0, 0, 0)

SWEP.RHPos = Vector(4, -5.5, 3.5)
SWEP.RHAng = Angle(0, -15, 90)
SWEP.LHPos = Vector(12, 0.2, -3.5)
SWEP.LHAng = Angle(-110, -180, 5)

SWEP.ShootAnimMul = 4

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
