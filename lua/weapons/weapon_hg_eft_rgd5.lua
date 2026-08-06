if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_hg_eft_grenade_base"
SWEP.PrintName = "RGD-5"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = [[RGD-5 is an offensive fragmentation grenade.

LMB - High throw
RMB - Low throw
R on surface - Set tripwire]]
SWEP.Spawnable = true

SWEP.WorldModel = "models/weapons/w_rgd5_unthrowed.mdl"
SWEP.WorldModelReal = "models/weapons/c_rgd5_2.mdl"
SWEP.ENT = "ent_hg_eft_rgd5"

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_eft_rgd5.png")
	SWEP.IconOverride = "entities/arc9_eft_rgd5.png"
	SWEP.BounceWeaponIcon = false
end
