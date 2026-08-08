SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "SIG Sauer P226"
SWEP.Author = "SIG Sauer"
SWEP.Instructions = "A Swiss-German service pistol chambered in 9x19mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_p226_2.mdl"

SWEP.FakePos = Vector(-23, 2, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-0.37, 0, 0.2)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "11202111011"
SWEP.FakeBodyGroupsPresets = {
	"11202111011",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 1

SWEP.AnimList = {
	["idle"] = "base_idle",
	["idle_empty"] = "idle_empty",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["inspect"] = "inspect",
}

function SWEP:PrimaryShootPost()
	if self:Clip1() <= 0 then
		self:PlayAnim("idle_empty", 1, true)
	end
end

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
    ["reload"] = {
        [0.1] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magout.wav") end,
        [0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in1.ogg") end,
        [0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
        [0.6] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magin.wav") end,
    },
    ["reload_empty"] = {
        [0.025] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav") end,
		[0.1] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magout.wav") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.5] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_magin.wav") end,
		[0.8] = function(self) self:EmitSound("zcitysnd/sound/weapons/m9/handling/m9_boltrelease.wav") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_p226_20.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_p226r.png")
SWEP.IconOverride = "entities/arc9_eft_p226r.png"
SWEP.WepSelectIcon2box = true

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(4.5, 3, -21.5)
SWEP.EjectAng = Angle(0,0,0)


SWEP.weight = 1
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 21
SWEP.Primary.Sound = {"weapons/darsu_eft/p226/p226_fire_close.ogg", 75, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_hammer.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 22
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3.5

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.2911, 2.8963)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.02, -0.02, 0), Angle(-0.03, 0.02, 0)}
SWEP.Ergonomics = 1.3
SWEP.Penetration = 11.5
SWEP.ShockMultiplier = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3

SWEP.LocalMuzzlePos = Vector(2.57, -2.28, 2.42)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

SWEP.WorldPos = Vector(3.5, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 22
SWEP.DistSound = "zcitysnd/sound/weapons/makarov/makarov_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 4
SWEP.AnimShootMul = 3

SWEP.podkid = 1

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0, 0.0, 0), {}},
		[2] = {"supressor1", Vector(0, 0.0, 0), {}},
		["mount"] = Vector(-0.5, 0, -0.05),
		["mountAngle"] = Angle(0, 0, 180),
	},
	sight = {
		["mountType"] = "pistolmount",
		["mountBone"] = "mod_reciever",
		["mount"] = Vector(1, -2.3, 0.7),
		["mountAngle"] = Angle(900, 90, -90),
	},
	underbarrel = {
		["mount"] = Vector(12.2, -0.2, 0),
		["mountAngle"] = Angle(0, -0.75, 0),
		["mountType"] = "picatinny_small"
	},
}

if CLIENT then
	local vector_origin = Vector(0, 0, 0)
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
			hg.CreateMag( self, Vector(50,10,10), nil, true )
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
