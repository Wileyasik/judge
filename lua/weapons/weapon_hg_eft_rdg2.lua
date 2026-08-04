if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_hg_eft_grenade_base"
SWEP.PrintName = "RDG-2"
SWEP.Category = "Weapons - Explosive"
SWEP.Instructions = [[RDG-2 is a smoke grenade used for concealment.

LMB - High throw
RMB - Low throw]]
SWEP.Spawnable = true
SWEP.NoTrap = true

SWEP.WorldModel = "models/weapons/w_rdg2_unthrowed.mdl"
SWEP.WorldModelReal = "models/weapons/c_rdg2.mdl"
SWEP.ENT = "ent_hg_eft_rdg2b"

SWEP.AnimList = {
	["deploy"] = {"draw", 1.1, false},
	["attack"] = {"fire1", 1, false, false, function(self) self:ThrowHigh() end, 0.65},
	["attack2"] = {"fire2", 0.8, false, false, function(self) self:ThrowLow() end, 0.6},
	["pullbackhigh"] = {"idle", 0.1, false, false, function(self) self.ReadyToThrow = true end},
	["pullbacklow"] = {"idle", 0.1, false, false, function(self)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end},
	["revers_pullbackhigh"] = {"idle", 0.1, false},
	["revers_pullbacklow"] = {"idle", 0.1, false},
	["idle"] = {"idle", 1, true},
}
