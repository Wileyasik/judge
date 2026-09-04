--made by lazzy https://steamcommunity.com/id/TimeToFuckinDie
SWEP.Base = "weapon_glock17"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Glock 19x"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "Glock is a brand of polymer-framed, short recoil-operated, striker-fired, locked-breech semi-automatic pistols designed and produced by Austrian manufacturer Glock Ges.m.b.H. Thats version of Glock is subcompact 10 rounds chambered in 9x19 ammo."
SWEP.Category = "Weapons - Pistols"
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.GlockBodygroups = {2, 11, 5, 0, 0, 0, 0, 0, 0, 0}
SWEP.GlockSkin = 2

SWEP.AnimList = {
	["inspect"] = "inspect",
	["reload"] = "reload2",
	["reload_empty"] = "reload_empty2_0",
	["idle"] = "idle",
}

SWEP.ModularParts = {
	magazine = {
		model = "models/weapons/mods/mag_glock_bigstick_31.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
	frontsight = {
		model = "models/weapons/mods/glock_fs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(-0, -0, 00),
		ang = Angle(0, -0, 0),
	},
	rearsight = {
		model = "models/weapons/mods/glock_rs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, 0, 0),
		ang = Angle(0, 0, 0),
	},
}

SWEP.MagModel = "models/weapons/mods/mag_glock_bigstick_31.mdl"
SWEP.HeldMagModel = "models/weapons/mods/mag_glock_bigstick_31.mdl"

SWEP.ReloadTime = 2.8

SWEP.AttachmentPos = Vector(0.2,0,-6.5)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_glock19x.png")
SWEP.IconOverride = "entities/arc9_eft_glock19x.png"

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10

SWEP.weight = 1
SWEP.lengthSub = 20

SWEP.Ergonomics = 2

function SWEP:ModelCreated(model)
	if not IsValid(model) then return end
	for index, value in ipairs(self.GlockBodygroups) do
		model:SetBodygroup(index - 1, value)
	end
	model:SetSkin(self.GlockSkin)
end
