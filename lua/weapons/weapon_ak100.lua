SWEP.Base = "weapon_ak74"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AK-100"
SWEP.Author = "Izhmash"
SWEP.Instructions = "Assault rifle chambered in 5.56x45 mm"
SWEP.Category = "Weapons - Assault Rifles"
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.WorldModelFake = "models/weapons/c_ak100.mdl"
SWEP.CustomizeCategory = "AK-101"
SWEP.FakeBodyGroups = "0011030"

SWEP.ModularParts = {
	receiver = {
		model = "models/weapons/mods/ak_dc_fab_defence_pdc.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, -0.1, -0.1),
		ang = Angle(0, 0, 0)
	},
	magazine = {
		model = "models/weapons/mods/mag_ak_arsenal_cwp_mag_556x45_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, -0.15),
		ang = Angle(0, 0, 0)
	},
	handguard = {
		model = "models/weapons/mods/ak_hg_magpul_moe.mdl",
		bonemerge = false,
		bone = "weapon",
		pos = Vector(0, -19.41, 0.5),
		ang = Angle(0, 0, 0)
	},
	pistolgrip = {
		model = "models/weapons/mods/ak_pgrip_aeroknox_scorpius.mdl",
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

SWEP.ARC9DefaultLHIKPart = "handguard"
SWEP.ARC9DefaultLHIKSourceModel = "models/weapons/mods/ak_hg_magpul_moe.mdl"
SWEP.StartAtt = {"stock_ak74_std"}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload556"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in3.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.55] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
	},
	["reload556_empty"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/ak/ak74_magrelease_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magout_metal.ogg") end,
		[0.25] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out3.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/ak/akm_magin_metal.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_up.ogg") end,
		[0.82] = function(self) self:EmitSound("weapons/darsu_eft/ak/akms_slider_down.ogg") end,
	},
}

SWEP.AnimList = {
	["fire"] = "fire",
	["idle"] = "idle",
	["reload"] = "reload556",
	["reload_empty"] = "reload556_empty",
	["inspect"] = "look2",
}

SWEP.MagModel = "models/weapons/mods/mag_ak_arsenal_cwp_mag_556x45_30.mdl"

SWEP.HeldReceiverModel = "models/weapons/mods/ak_dc_fab_defence_pdc.mdl"
SWEP.HeldReceiverBone = "mod_reciever"
SWEP.HeldReceiverOffsetPos = Vector(0, -0.1, -0.1)
SWEP.HeldReceiverOffsetAng = Angle(0, 0, 0)

SWEP.HeldMagModel = "models/weapons/mods/mag_ak_arsenal_cwp_mag_556x45_30.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, 0, -0.15)
SWEP.HeldMagOffsetAng = Angle(0, 0, 0)

SWEP.HeldHandguardModel = "models/weapons/mods/ak_hg_magpul_moe.mdl"
SWEP.HeldHandguardBone = "weapon"
SWEP.HeldHandguardOffsetPos = Vector(0, -19.41, 0.5)
SWEP.HeldHandguardOffsetAng = Angle(0, 0, 0)

SWEP.HeldPistolgripModel = "models/weapons/mods/ak_pgrip_aeroknox_scorpius.mdl"
SWEP.HeldPistolgripBone = "weapon"
SWEP.HeldPistolgripOffsetPos = Vector(0, -12.3, -1.3)
SWEP.HeldPistolgripOffsetAng = Angle(0, 0, 0)

SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "5.56x45 mm"
SWEP.Primary.Damage = 33
SWEP.Primary.Force = 28
SWEP.Primary.Wait = 0.1

SWEP.CustomShell = "556"
SWEP.ShellEject = "EjectBrass_556"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ak101.png")
SWEP.IconOverride = "entities/arc9_eft_ak101.png"

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor5", Vector(0, 0, 0), {}},
		[2] = {"supressor6", Vector(0, 0, 0), {}},
		[3] = {"supressor15", Vector(1.3, 0, 0), {}},
		["mount"] = Vector(-1, 0, 0),
	},
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {picatinny = Vector(-20, 0, 1.83)},
		["mountAngle"] = Angle(0, 0, 90),
		["akScopeCorrections"] = true,
	},
	mount = false,
	magwell = false,
	stock = {
		[1] = {"stock_ak74_std", Vector(0, 0, 0), {}},
		["mountType"] = "ak_stock",
		["mountBone"] = "weapon",
		["mount"] = Vector(0.65, -9.6, -0.8),
	},
}
