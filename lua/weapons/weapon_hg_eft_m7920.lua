if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_hg_eft_grenade_base"
SWEP.PrintName = "M7920"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = [[M7920 is a non-lethal flashbang grenade.

LMB - High throw
RMB - Low throw
R on surface - Set tripwire]]
SWEP.Spawnable = true

SWEP.WorldModel = "models/weapons/w_m7920_unthrowed.mdl"
SWEP.WorldModelReal = "models/weapons/c_m7920_2.mdl"
SWEP.ENT = "ent_hg_eft_m7290"

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_eft_m7290.png")
	SWEP.IconOverride = "entities/arc9_eft_m7290.png"
	SWEP.BounceWeaponIcon = false
end
