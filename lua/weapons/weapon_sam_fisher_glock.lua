SWEP.Base = "weapon_glock17"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Sam Fisher Glock"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "Sam Fisher's suppressed Glock."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.WorldModelFake = "models/weapons/c_glock.mdl"
SWEP.GlockBodygroups = {1, 10, 4, 0, 0, 0, 0, 0, 0, 1}

SWEP.AnimList = {
	["inspect"] = "inspect",
	["reload"] = "reload2",
	["reload_empty"] = "reload_empty2_0",
	["idle"] = "idle",
}

SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/mods/mag_glock_magex_30.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
	frontsight = {
		model = "models/weapons/mods/glock_fs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, 0, 0.04),
		ang = Angle(0, -90, 0),
	},
	rearsight = {
		model = "models/weapons/mods/glock_rs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
}

SWEP.MagModel = "models/weapons/mods/mag_glock_magex_30.mdl"
SWEP.HeldMagModel = "models/weapons/mods/mag_glock_magex_30.mdl"
SWEP.Primary.Sound = {"weapons/darsu_eft/glock/glock17_close.wav", 75, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/glock/glock17_close_silenced.ogg", 65, 90, 100}
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30

SWEP.WepSelectIcon2 = Material("entities/sam.png")
SWEP.IconOverride = "entities/sam.png"

SWEP.SetSupressor = true
SWEP.SupressorOnly = true
SWEP.StartAtt = {"holo16"}

SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0, 0, 0), {}},
		[2] = {"supressor1", Vector(0, 0, 0), {}},
		["mount"] = Vector(-0.5, 0, -0.05),
		["mountAngle"] = Angle(0, 0, 180),
	},
	magwell = {
		["mountType"] = "glock_mag",
	},
	sight = {
		["mountType"] = "pistolmount",
		["mountBone"] = "mod_reciever",
		["mount"] = Vector(1, 0, 0.2),
		["mountAngle"] = Angle(0, -90, 90),
	},
	underbarrel = {
		["mount"] = Vector(12.8, -2.55, -1),
		["mountAngle"] = Angle(0, -0.6, 90),
		["mountType"] = "picatinny_small",
	},
}

function SWEP:ModelCreated(model)
	if not IsValid(model) then return end

	for index, value in ipairs(self.GlockBodygroups) do
		model:SetBodygroup(index - 1, value)
	end
end
