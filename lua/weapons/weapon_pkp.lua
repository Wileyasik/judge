SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PKP"
SWEP.Author = "Degtyarev plant"
SWEP.Instructions = "Machine gun chambered in 7.62x54 mm\n\nRate of fire 650 rounds per minute"
SWEP.Category = "Weapons - Machineguns"
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_pk.mdl"
SWEP.FakeAttachment = "1"
SWEP.FakePos = Vector(-8, 2.85, 6.7)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(1, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 90)

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_pkp.png")
SWEP.IconOverride = "entities/arc9_eft_pkp.png"

SWEP.CustomShell = "762x51"
SWEP.CustomSecShell = "m60len"
SWEP.EjectPos = Vector(5.2, 17, -4.5)
SWEP.EjectAng = Angle(0, -90, 0)

SWEP.CanSuicide = false

SWEP.ScrappersSlot = "Primary"
SWEP.weight = 5

SWEP.ShockMultiplier = 2

SWEP.Primary.ClipSize = 150
SWEP.Primary.DefaultClip = 150
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "7.62x54 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 68
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 65
SWEP.Primary.Sound = {"weapons/darsu_eft/pkm/pkm_outdoor_close_loop1.wav", 75, 80, 90}
SWEP.SupressedSound = {"weapons/darsu_eft/rpd/fire/rpd_outdoor_silenced_close_loop4.wav", 75, 80, 90}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.09091
SWEP.ReloadTime = 8

SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.4064, 5.0074)
SWEP.RHandPos = Vector(4, -2, 0)
SWEP.LHandPos = Vector(7, -2, -2)
SWEP.ShellEject = "EjectBrass_762Nato"
SWEP.Spray = {}
for i = 1, 150 do
	SWEP.Spray[i] = Angle(-0.04 - math.cos(i) * 0.03, math.cos(i * i) * 0.05, 0) * 2
end

SWEP.LocalMuzzlePos = Vector(38, -1.4, 2.4)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.weaponInvCategory = 1
SWEP.Ergonomics = 0.5
SWEP.OpenBolt = true
SWEP.Penetration = 23
SWEP.WorldPos = Vector(-1, -0.5, 0)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(-0.05, -0.2, 0)
SWEP.AimHands = Vector(0, 1, -3.5)
SWEP.lengthSub = 15
SWEP.DistSound = "weapons/darsu_eft/pkm/fire/pkm_indoor_distant_loop1.wav"
SWEP.bipodAvailable = true
SWEP.bipodsub = 15

SWEP.RecoilMul = 1

SWEP.FakeVPShouldUseHand = true
SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "reload_m",
	["reload_empty"] = "reload_empty_m",
	["inspect"] = "look",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
    ["reload"] = {
        [0.10] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_cover_open.ogg") end,
        [0.20] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_belt_out.wav") end,
		[0.30] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_mag_out.ogg") end,
		[0.55] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_belt_in.wav") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_cover_close.ogg") end,
    },
    ["reload_empty"] = {
        [0.10] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_cover_open.ogg") end,
        [0.20] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_belt_out.wav") end,
		[0.30] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_mag_out.ogg") end,
		[0.48] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_belt_in.wav") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_cover_close.ogg") end,
		[0.82] = function(self) self:EmitSound("weapons/darsu_eft/pkm/pk_charge_full.ogg") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end


SWEP.GunCamPos = Vector(6, -17, -4)
SWEP.GunCamAng = Angle(190, 0, -90)
SWEP.FakeBodyGroups = "0111101022131"
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 1

SWEP.NoIdleLoop = true
SWEP.GetDebug = false

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_pkm_dropped.mdl"

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
		[0.5] = function(self, timeMul)
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

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"dovetail", "picatinny"},
		["mountBone"] = "mod_scope",
		["mount"] = {["dovetail"] = Vector(0.8, 1.5, 2.9), ["picatinny"] = Vector(-1.35, -0.5, 3)},
		["mountAngle"] = Angle(0, -90, 90),
	},
	mount = {
		mountAngle = Angle(0, 0, 0),
		["mountBone"] = "mod_scope",
		["picatinny"] = {"mount3", Vector(-0.5, 0.5, 1), {}, mountType = "picatinny"},
		["dovetail"] = {"empty", Vector(0, 0, 0), {}, mountType = "dovetail"},
	},
	grip = {
		["mount"] = {["picatinny"] = Vector(-1, -0.85, 0)},
		["mountType"] = {"picatinny"},
		["mountAngle"] = Angle(0,0,0)
	},
	underbarrel = {
		["mount"] = Vector(-1, -0.6, -2),
		["mountAngle"] = Angle(0, -0.75, 180),
		["mountType"] = "picatinny_small"
	},
}

SWEP.RHPos = Vector(4, -7, 4)
SWEP.RHAng = Angle(0, -12, 90)
SWEP.LHPos = Vector(9, -4, -5)
SWEP.LHAng = Angle(-10, 10, -120)

local ang1 = Angle(30, -15, 0)
local ang2 = Angle(0, 10, 0)

function SWEP:AnimHoldPost()
end
