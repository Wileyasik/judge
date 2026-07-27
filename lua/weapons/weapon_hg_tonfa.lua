if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Police Tonfa"
SWEP.Instructions = "A side-handle baton issued to law enforcement officers for riot control and self-defense. Its long reach and heavy weight make it an effective tool for subduing suspects. The tonfa is typically used in pairs, one in each hand, to block and strike opponents. It is an essential part of a police officer's toolkit, and a powerful weapon in the right hands.\n\nLMB to attack.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cof/weapons/nightstick/w_nightstick.mdl"
SWEP.WorldModelReal = "models/cof/weapons/nightstick/v_nightstick.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "melee"
SWEP.weight = 0.6

SWEP.HoldPos = Vector(-5,0,0)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 1.2
SWEP.WaitTime1 = 1.15
SWEP.ViewPunch1 = Angle(1,1,0)

SWEP.AnimAlwaysBack = true

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,7,-8)
SWEP.weaponAng = Angle(0,180,-90)
SWEP.modelscale = 1.15

SWEP.hitsoundextra = {
    {"hammer/BodyHit-1.wav", 70, {115, 125}},
    {"hammer/BodyHit-2.wav", 70, {115, 125}},
    {"hammer/BodyHit-3.wav", 70, {115, 125}},
    {"hammer/BodyHit-4.wav", 70, {115, 125}},
    {"hammer/BodyHit-5.wav", 70, {115, 125}},
    {"hammer/BodyHit-6.wav", 70, {115, 125}},
}

SWEP.hitsoundbrutalize = {
    {"hammerbrutalize/rem_hammerbrutalize1.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize2.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize3.wav", 70, {110, 115}},
    {"hammerbrutalize/rem_hammerbrutalize4.wav", 70, {110, 115}},
}


SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {110, 115}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {110, 115}},
}



SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 18

SWEP.PenetrationPrimary = 3

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2

SWEP.StaminaPrimary = 12

SWEP.AttackLen1 = 50

SWEP.BlockTier = 2
SWEP.BlockMaterial = "none"
SWEP.BlockSound = {"Plastic_Box.ImpactHard", 68, {95, 102}}

SWEP.AnimList = {
    ["idle"] = "idle1",
    ["deploy"] = "draw",
    ["attack"] = "attack1",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_zac_hmcd_policebaton")
	SWEP.IconOverride = "entities/tacrp_m_tonfa.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = false
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"

SWEP.AttackPos = Vector(0,0,0)

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and 6 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and -1 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and 6 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and 0 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 0 or 0)
    addAngLerp.x = addAngLerp.x + (self:GetBlocking() and 0 or 0)
    
    return true
end

SWEP.AttackTimeLength = 0.155

SWEP.AttackRads = 85

SWEP.SwingAng = -90

function SWEP:SecondaryAttack(override)
end