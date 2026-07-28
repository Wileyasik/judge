if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Akula Dagger"
SWEP.Instructions = "As dangerous as the fish its named after."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_melee_dagger.mdl"
SWEP.WorldModelReal = "models/weapons/c_melee_dagger.mdl"
SWEP.DontChangeDropped = true
SWEP.modelscale = 1.0
SWEP.modelscale2 = 1

SWEP.BleedMultiplier = 1.3
SWEP.PainMultiplier = 1.8

SWEP.DamagePrimary = 16
SWEP.DamageSecondary = 5

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.basebone = 78

SWEP.HoldPos = Vector(-5,1,-1)
SWEP.HoldAng = Angle(0,0,0)

SWEP.SuicidePos = Vector(-10, 5, -7)
SWEP.SuicideAng = Angle(-30, 0, 0)
SWEP.SuicideCutVec = Vector(-1, -5, 1)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.CanSuicide = true
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.BreakBoneMul = 0.25
SWEP.AttackPos = Vector(0,0,0)
SWEP.AttackingPos = Vector(0,0,0)

SWEP.weaponPos = Vector(0.7,-0,0.2)
SWEP.weaponAng = Angle(80,130,-140)

SWEP.HoldType = "melee"

--SWEP.InstantPainMul = 0.25

--models/weapons/gleb/c_knife_t.mdl
if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_eft_melee_akula.png")
	SWEP.IconOverride = "entities/arc9_eft_melee_akula.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.BreakBoneMul = 0.5
SWEP.ImmobilizationMul = 0.45
SWEP.StaminaMul = 0.5
SWEP.HadBackBonus = true

SWEP.attack_ang = Angle(0,0,0)
function SWEP:Initialize()
    self.attackanim = 0
    self.sprintanim = 0
    self.animtime = 0
    self.animspeed = 1
    self.reverseanim = false
    self.Initialzed = true
    self:PlayAnim("idle",10,true)

    self:SetHold(self.HoldType)

    self:InitAdd()
end

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 0.7
SWEP.WaitTime1 = 0.1

SWEP.AnimTime2 = 0.6
SWEP.WaitTime2 = 0.6

SWEP.AnimList = {
    ["idle"] = "idle",
    ["deploy"] = "draw",
    ["attack"] = "fire2",
    ["attack2"] = "fire1",

}



function SWEP:Reload()
    if SERVER then
        if self:GetOwner():KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            self:GetOwner():ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end
    end
end

function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_RELOAD) then return end
    if not self:GetNetVar("mode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    return false
end

function SWEP:CanSecondaryAttack()
    return self.allowsec and true or false
end

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 35
SWEP.AttackRads2 = 85

SWEP.SwingAng = -90
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = false
SWEP.MultiDmg2 = true

SWEP.AttackSwing = "weapons/darsu_eft/melee/scythe_whoosh_04.ogg" 
SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2HitFlesh = "snd_jack_hmcd_knifehit.wav"
SWEP.DeploySnd = "weapons/darsu_eft/knife_bayonet_equip.ogg"