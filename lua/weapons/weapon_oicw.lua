SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "OICW"
SWEP.Author = "Alliance"
SWEP.Instructions = "Alliance assault rifle with an integrated optic and 20mm underbarrel grenade launcher.\n\n[G] toggles the grenade launcher."
SWEP.Category = "Weapons - Assault Rifles"
SWEP.WeaponRecoilMul = 0.7
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_irifle.mdl"
SWEP.WorldModelFake = "models/weapons/rtb/oicw.mdl"

SWEP.FakePos = Vector(24, -4, 8.8)
SWEP.FakeAng = Angle(0, 180, 0)
SWEP.AttachmentPos = Vector(0, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeEjectBrassATT = "punch"

SWEP.MagModel = "models/Items/combine_rifle_cartridge01.mdl"
SWEP.FakeMagDropBone = 1

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 1000
SWEP.DisableFakeViewPunch = true
SWEP.DisableFakeReloadAnimation = true



-- Integrated optic
SWEP.availableAttachments = {}
SWEP.scopedef = true
SWEP.dort = true
SWEP.mat = Material("combine_sniper/huyhuy")
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_dovetail_npz_nspum_3,5x_marks.png")
SWEP.sizeperekrestie = 2200
SWEP.localScopePos = Vector(10,-0,4)
SWEP.scope_blackout = 70000
SWEP.blackoutsize = 3100000
SWEP.perekrestieSize = true
SWEP.rot = 0
SWEP.FOVMin = 10
SWEP.FOVMax = 20
SWEP.ZoomFOV = 10

if CLIENT then
	local opticMaterialKeywords = {"optic", "scope", "lens", "glass", "screen"}

	function SWEP:ModelCreated(model)
		local materials = model:GetMaterials()

		for _, keyword in ipairs(opticMaterialKeywords) do
			for _, materialName in ipairs(materials) do
				if string.find(string.lower(materialName), keyword, 1, true) then
					self.mat = Material(materialName)
					return
				end
			end
		end
	end
end

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_out1.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_in1.ogg") end,
	},
	["reload_empty"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_out1.ogg") end,
		[0.5] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_mag_in1.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/m4a1/mcx_bolt_in.ogg") end,
	},
}

SWEP.AnimList = {
	["idle"] = "idle",
	["fire"] = "fire",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty",
	["reload_gl"] = "reload_gl",
}

SWEP.FireAnimTime = 0.15
SWEP.FireAnimCandidates = {"fire"}

-- Integrated underbarrel grenade launcher
SWEP.GP25MuzzlePos = Vector(-5, 0, -4)
SWEP.GP25ClipSize = 1

function SWEP:HasGP25()
	return true
end

function SWEP:PlayGP25WeaponAnimation(sequence, duration, looping, reverse)
	-- RTB's OICW sequences move the model root and are unsuitable for view punch.
	if CLIENT then self.OldAngPunch = nil end
	if sequence == "gp34_reload" then
		self:PlayAnim("reload_gl", duration, looping, nil, reverse, true)
	end
end

SWEP.lmagpos = Vector(0, 0, 0)
SWEP.lmagang = Angle(0, 0, 0)
SWEP.lmagpos2 = Vector(5, 1, -1)
SWEP.lmagang2 = Angle(0, -90, 0)

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 44
SWEP.Primary.Spread = 0
SWEP.Primary.Force = 32
SWEP.Primary.Sound = {"weapons/hmcd_ar2/fire1.wav", 85, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/mk18/handling/mk18_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.EjectPos = Vector(5, 20, -4)
SWEP.EjectAng = Angle(15, -90, 0)
SWEP.weight = 4.5
SWEP.NoWINCHESTERFIRE = true
SWEP.punchmul = 0.5
SWEP.punchspeed = 1

SWEP.PPSMuzzleEffect = "pcf_jack_mf_mrifle1"
SWEP.CustomShell = "556"
SWEP.ShellEject = "EjectBrass_556"

SWEP.Primary.Wait = 0.085
SWEP.ReloadTime = 3.5
SWEP.ReloadSoundes = {
	"none",
	"none",
	"none",
	"none",
	"weapons/ar2/ar2_magout.wav",
	"none",
	"none",
	"weapons/ar2/ar2_magin.wav",
	"none",
	"weapons/ar2/ar2_reload_rotate.wav",
	"none",
	"weapons/ar2/ar2_push.wav",
	"none",
	"none",
	"none",
	"none"
}

SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(-21, -0.365, 7.4)


SWEP.DeploySnd = {"weapons/ar2/ar2_deploy.wav", 75, 100, 110}

SWEP.Ergonomics = 0.85
SWEP.Penetration = 19
SWEP.HaveModel = "models/weapons/rtb/oicw.mdl"
SWEP.WorldPos = Vector(15, -0.5, -1.5)
SWEP.WorldAng = Angle(0, 180, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0.7, 0)
SWEP.attAng = Angle(0.2, 0.7, 90)
SWEP.lengthSub = 20
SWEP.DistSound = "weapons/newsndw/fire1.wav"

SWEP.LocalMuzzlePos = Vector(-9.963, -0.818, 3.582)
SWEP.LocalMuzzleAng = Angle(0.4, 180, 0)
SWEP.WeaponEyeAngles = Angle(0, 180, 0)

SWEP.rotatehuy = 180

SWEP.RHPos = Vector(4, -8.5, 5)
SWEP.RHAng = Angle(0, 0, 90)
SWEP.LHPos = Vector(10.5, -3, -9)
SWEP.LHAng = Angle(-10, 0, -90)

function SWEP:PrimaryShootPost()
	if CLIENT then self.OldAngPunch = nil end
end
