if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Scythe"
SWEP.Instructions = "An axe is an implement that has been used for millennia to shape, split, and cut wood. Can break down doors.\n\nLMB to attack.\nR + LMB to charge.\nRMB to block.\n\nA fully charged hit can sever a limb or explode the head, but drains almost all of your stamina."
SWEP.Category = "Weapons - Melee"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/w_melee_scythe.mdl"
SWEP.WorldModelReal = "models/weapons/ravaged/anim_axe_fire.mdl"
SWEP.WorldModelExchange = "models/weapons/w_melee_scythe.mdl"
SWEP.ViewModel = ""
SWEP.modelscale = 1.2

SWEP.SuicidePos = Vector(5, 13, -35)
SWEP.SuicideAng = Angle(-70, 50, -30)
SWEP.SuicideCutVec = Vector(-2, 4, -3)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "player/flesh/flesh_bullet_impact_03.wav"
SWEP.CanSuicide = true
SWEP.SuicideNoLH = false
SWEP.SuicideHoldType = "slam"

SWEP.Weight = 0
SWEP.weight = 2.5

SWEP.HoldType = "pistol"

SWEP.HoldPos = Vector(-11, -9, -1)
SWEP.HoldAng = Angle(0, 11, 0)

SWEP.AttackTime = 0.51
SWEP.AnimTime1 = 2.45
SWEP.WaitTime1 = 1.3
SWEP.ViewPunch1 = Angle(1, 1, -1)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0, 0, -2)
SWEP.canchargeattack = true
SWEP.ChargeAnimTimeBegin = 1.45
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.65
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.41
SWEP.ChargeWaitTime = 2.5
SWEP.ChargeAttackLen = 70
SWEP.ChargeAttackTimeLength = 0.24
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -78
SWEP.ChargeStamina = 112
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 2.05
SWEP.ChargeBreakBoneMul = 2.1
SWEP.RagdollHitForceMul = 0.2
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(12, 0, 0)
SWEP.ChargeHoldPos = Vector(-7, -5, -1)

SWEP.ArteryChance = 1.45

SWEP.attack_ang = Angle(0, 0, 0)
SWEP.sprint_ang = Angle(15, 0, 0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0.25, 1, -6)
SWEP.weaponAng = Angle(5, -100, 4)

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
    ["charge_begin"] = "Attack_Charge_Begin",
    ["charge_idle"] = "Attack_Charge_Idle",
    ["charge_end"] = "Attack_Charge_End",
}

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 48
SWEP.DamageSecondary = 14
SWEP.HitCooldownEnabled = true
SWEP.HitCooldown = 1.5
SWEP.ComboEnabled = true
SWEP.ComboResetTime = 1.4
SWEP.ComboDamageMul1 = 1
SWEP.ComboDamageMul2 = 1.25
SWEP.ComboDamageMul3 = 1.65


SWEP.PenetrationPrimary = 6
SWEP.PenetrationSecondary = 3

SWEP.MaxPenLen = 10

SWEP.PenetrationSizePrimary = 5.5
SWEP.PenetrationSizeSecondary = 1.5

SWEP.StaminaPrimary = 37
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 100
SWEP.AttackLen2 = 100

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_eft_melee_scythe.png")
	SWEP.IconOverride = "entities/arc9_eft_melee_scythe.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true


SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.ChargeAttackHit = "Canister.ImpactHard"
SWEP.ChargeAttackHitFlesh = "snd_jack_hmcd_axehit.wav"
SWEP.DeploySnd = "physics/wood/wood_plank_impact_soft2.wav"

SWEP.hitsoundbrutalize = {
    {"axe/axehit1.wav", 95, {95, 105}},
    {"axe/axehit2.wav", 95, {95, 105}},
    {"axe/axehit3.wav", 95, {95, 105}},
    {"axe/axehit4.wav", 95, {95, 105}},
}

SWEP.hitsoundextra = {
    {"axe/AxeBigBite-01.wav", 95, {95, 105}},
    {"axe/AxeBigBite-02.wav", 95, {95, 105}},
    {"axe/AxeBigBite-03.wav", 95, {95, 105}},
    {"axe/AxeBigBite-04.wav", 95, {95, 105}},
    {"axe/AxeBigBite-05.wav", 95, {95, 105}},
    {"axe/AxeBigBite-06.wav", 95, {95, 105}},
    {"axe/AxeBigBite-07.wav", 95, {95, 105}},
    {"axe/AxeBigBite-08.wav", 95, {95, 105}},
    {"axe/AxeBigBite-09.wav", 95, {95, 105}},
    {"axe/AxeBigBite-10.wav", 95, {95, 105}},
}

SWEP.hitsoundplus = {
    {"axe/AxeBigOut-01.wav", 70, {95, 105}},
    {"axe/AxeBigOut-02.wav", 75, {95, 105}},
    {"axe/AxeBigOut-03.wav", 75, {95, 105}},
    {"axe/AxeBigOut-04.wav", 75, {95, 105}},
    {"axe/AxeBigOut-05.wav", 70, {95, 105}},
    {"axe/AxeBigOut-06.wav", 75, {95, 105}},
    {"axe/AxeBigOut-07.wav", 75, {95, 105}},
    {"axe/AxeBigOut-08.wav", 75, {95, 105}},
    {"axe/AxeBigOut-09.wav", 70, {95, 105}},
    {"axe/AxeBigOut-10.wav", 75, {95, 105}},
}

SWEP.swingsoundextra = {
    {"weapons/darsu_eft/melee/scythe_whoosh_01.ogg", 90, {95, 100}},
    {"weapons/darsu_eft/melee/scythe_whoosh_02.ogg", 90, {95, 100}},
    {"weapons/darsu_eft/melee/scythe_whoosh_03.ogg", 90, {95, 100}},
    {"weapons/darsu_eft/melee/scythe_whoosh_04.ogg", 90, {95, 100}},
    {"weapons/darsu_eft/melee/scythe_whoosh_05.ogg", 90, {95, 100}},
}

SWEP.AttackPos = Vector(0,0,0)
SWEP.BlockTier = 4
SWEP.BlockMaterial = "wood"
SWEP.BlockSound = {"physics/wood/wood_plank_impact_hard1.wav", 70, {96, 104}}
SWEP.BlockDirectionalCharge = "overhead"

SWEP.NoHolster = true

SWEP.AnimAlwaysBack = true

SWEP.AttackTimeLength = 0.28
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 75
SWEP.AttackRads2 = 0

SWEP.SwingAng = -5
SWEP.SwingAng2 = 0

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end

function SWEP:CanChargeAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    self.ChargeAttackHit = "Canister.ImpactHard"
    self.ChargeAttackHitFlesh = "snd_jack_hmcd_axehit.wav"
    return true
end

function SWEP:PrimaryAttackAdd(ent)
    if hgIsDoor(ent) and math.random(7) > 3 then
        hgBlastThatDoor(ent,self:GetOwner():GetAimVector() * 50 + self:GetOwner():GetVelocity())
    end
end

SWEP.ChargeDismemberChance = 0.45
SWEP.ChargeHeadExplodeChance = 0.35

local chargeHitGroupToLimb = {
    [HITGROUP_LEFTLEG] = "lleg",
    [HITGROUP_RIGHTLEG] = "rleg",
    [HITGROUP_LEFTARM] = "larm",
    [HITGROUP_RIGHTARM] = "rarm",
}

local function GetChargeHitBoneName(ent, trace)
    if not IsValid(ent) or not trace then return end

    if trace.PhysicsBone ~= nil and ent.TranslatePhysBoneToBone and ent.GetBoneName then
        local bone = ent:TranslatePhysBoneToBone(trace.PhysicsBone)
        if bone and bone >= 0 then
            local name = ent:GetBoneName(bone)
            if name then return name end
        end
    end

    if trace.HitBoxBone ~= nil and ent.GetBoneName then
        return ent:GetBoneName(trace.HitBoxBone)
    end
end

function SWEP:ChargeAttackAdd(ent, trace)
    self:PrimaryAttackAdd(ent)

    if CLIENT then return end
    if not IsValid(ent) then return end

    local org = ent.organism
    if not org or org.superfighter then return end

    if self:IsHeadHit(ent, trace) then
        if not org.headamputated and not ent.headexploded and math.Rand(0, 1) <= (self.ChargeHeadExplodeChance or 0.35) then
            hg.ExplodeHead(ent)
        end

        return
    end

    local bonename = GetChargeHitBoneName(ent, trace)
    local limb

    if bonename and hg.amputeetable and hg.amputeetable[bonename] then
        limb = hg.amputeetable[bonename]
    elseif trace and chargeHitGroupToLimb[trace.HitGroup or -1] then
        limb = chargeHitGroupToLimb[trace.HitGroup]
    elseif bonename and hg.bonetohitgroup then
        limb = chargeHitGroupToLimb[hg.bonetohitgroup[bonename] or -1]
    end

    if limb and not org[limb .. "amputated"] and math.Rand(0, 1) <= (self.ChargeDismemberChance or 0.45) then
        hg.organism.AmputateLimb(org, limb)
    end
end

SWEP.MinSensivity = 0.7

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBaseBone = "base"
SWEP.ViewPunchDiv = 1
