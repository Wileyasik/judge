if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Chainsaw"
SWEP.Instructions = "chainsawbrrttt aysss, we wont need a description since remorse doesnt have it"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/melee/chainsaws/w_me_chainsaw.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_me_chainsaw.mdl"
--SWEP.WorldModelExchange = "models/weapons/tfa_nmrih/w_me_machete.mdl"
SWEP.ViewModel = ""

SWEP.SuicidePos = Vector(20, 1, -27)
SWEP.SuicideAng = Angle(-90, -180, 90)
SWEP.SuicideCutVec = Vector(3, -6, 0)
SWEP.SuicideCutAng = Angle(10, 0, 0)
SWEP.SuicideTime = 0.5
SWEP.SuicideSound = "weapons/knife/knife_hit1.wav"
SWEP.CanSuicide = false
SWEP.SuicideNoLH = true
SWEP.SuicidePunchAng = Angle(5, -15, 0)

SWEP.CantClash = true

SWEP.bloodID = 3

SWEP.BlockTier = 5
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {145, 155}}

SWEP.NoHolster = true

SWEP.HoldType = "melee"

SWEP.DamageType = DMG_SLASH

SWEP.HoldPos = Vector(-7,1,-4)
SWEP.HoldAng = Angle(-2,0,-4)

SWEP.AttackTime = 0.35
SWEP.AnimTime1 = 1.4
SWEP.WaitTime1 = 1.45
SWEP.ViewPunch1 = Angle(1,2,0)
SWEP.CantClash = true

SWEP.Attack2Time = 0.15
SWEP.AnimTime2 = 0.7
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(1,2,-2)

SWEP.ViewPunchDiv = 1

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94

SWEP.weaponPos = Vector(0,0,0)
SWEP.weaponAng = Angle(0,0,0)

SWEP.DamageType = DMG_SLASH
SWEP.DamagePrimary = 40
SWEP.DamageSecondary = 3
SWEP.BleedMultiplier = 1.45
SWEP.PainMultiplier = 1.65

SWEP.PenetrationPrimary = 7
SWEP.PenetrationSecondary = 0

SWEP.MaxPenLen = 6

SWEP.PenetrationSizePrimary = 1.5
SWEP.PenetrationSizeSecondary = 0

SWEP.StaminaPrimary = 35
SWEP.StaminaSecondary = 10

SWEP.AttackLen1 = 50
SWEP.AttackLen2 = 35
SWEP.weight = 19

SWEP.ChainsawFuel = 100
SWEP.ChainsawFuelDrainIdle = 0.05
SWEP.ChainsawFuelDrainAttack = 0.35
SWEP.ChainsawStaminaDrainAttack = 15
SWEP.ChainsawAttackDelay = 0.5
SWEP.ChainsawAttackRate = 0.1
SWEP.ChainsawAttackDamage = 11
SWEP.ChainsawAttackLen = 35
SWEP.ChainsawAttackSize = 4
SWEP.ChainsawAttackEndDelay = 0.5
SWEP.ChainsawIdleRestartDelay = 0.6
SWEP.PropDamageMultiplier = 2
SWEP.ChainsawSoundLeadTime = 0
SWEP.ChainsawAttackLoopLeadTime = 0
SWEP.ChainsawTurnOnTime = 1.8
SWEP.ChainsawTurnOnAttemptTime = 1.8
SWEP.ChainsawTurnOffTime = 1
SWEP.ChainsawToggleCooldown = 0.5
SWEP.ChainsawAttemptSoundFirstDelay = 0.5
SWEP.ChainsawAttemptSoundSecondDelay = 1
SWEP.ChainsawStartAttemptSoundDelay = 0.5
SWEP.ChainsawStartSoundDelay = 1
SWEP.ChainsawAttackLoopPitch = 100
SWEP.ChainsawAttackLoopHitPitch = 85
SWEP.ChainsawAttackLoopPitchDownTime = 1
SWEP.ChainsawAttackLoopPitchUpTime = 0.5
SWEP.ChainsawAttackLoopPitchHoldTime = 0.3

SWEP.ChainsawStartSound = "chainsaw/chainsaw_successstart.wav"
SWEP.ChainsawAttemptSound = "chainsaw/chainsaw_failedstart.wav"
SWEP.ChainsawIdleSound = "chainsaw/chainsaw_idleloop.wav"
SWEP.ChainsawIdleSounds = {"chainsaw/chainsaw_idleloop.wav"}
SWEP.ChainsawAttackStartSound = "chainsaw/chainsaw_idletosaw.wav"
SWEP.ChainsawAttackLoopSound = "chainsaw/chainsaw_sawloop.wav"
SWEP.ChainsawAttackLoopSounds = {"chainsaw/chainsaw_sawloop.wav"}
SWEP.ChainsawAttackStopSound = "chainsaw/chainsaw_sawtoidle.wav"
SWEP.ChainsawTurnOffSound = "chainsaw/chainsaw_turnoff.wav"

SWEP.canchargeattack = false
SWEP.ChargeAnimTimeBegin = 1.45
SWEP.ChargeAnimTimeIdle = 1
SWEP.ChargeAnimTimeEnd = 1.65
SWEP.ChargeFullTime = 0.65
SWEP.ChargeAttackTime = 0.41
SWEP.ChargeWaitTime = 2.5
SWEP.ChargeAttackLen = 70
SWEP.ChargeAttackTimeLength = 0.19
SWEP.ChargeAttackRads = 85
SWEP.ChargeSwingAng = -90
SWEP.ChargeStamina = 50
SWEP.ChargePenetration = 8
SWEP.ChargePenetrationSize = 6.5
SWEP.ChargeDamageMul = 1.25
SWEP.ChargeBreakBoneMul = 1.15
SWEP.ChargeTapCancelTime = 1
SWEP.ChargeViewPunch = Angle(12, 0, 0)
SWEP.ChargeHoldPos = Vector(-12, -1, -6)
SWEP.ArteryChance = 1.45

SWEP.BreakBoneMul = 1.1

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

SWEP.ChainsawFleshHitSounds = {
    {"chainsaw/chainsaw_gore_01.wav", 85, {95, 105}},
    {"chainsaw/chainsaw_gore_02.wav", 85, {95, 105}},
    {"chainsaw/chainsaw_gore_03.wav", 85, {95, 105}},
    {"chainsaw/chainsaw_gore_04.wav", 85, {95, 105}},
}

SWEP.ChainsawPlayerHitSounds = {
    {"pocketknife/melee_character_knife_plr_02.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_01.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_03.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_04.ogg", 55, {105, 115}},
    {"pocketknife/melee_character_knife_plr_05.ogg", 55, {105, 115}},
}

SWEP.ChainsawHardHitSound = "snd_jack_hmcd_knifehit.wav"

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {85, 95}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {85, 95}},
}

SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "Shove",
    ["idle_on"] = "IdleOn",
    ["walk_on"] = "WalkOn",
    ["sprint_on"] = "SprintOn",
    ["attack_on"] = "Attack_On",
    ["attack_to_idle"] = "Attack_To_Idle",
    ["idle_to_attack"] = "Idle_To_Attack",
    ["turn_on"] = "TurnOn",
    ["turn_off"] = "TurnOff",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/chainsaw.png")
	SWEP.IconOverride = "vgui/chainsaw.png"
	SWEP.BounceWeaponIcon = false

    local EFFECT = {}

    function EFFECT:Init(data)
        local pos = data:GetOrigin()
        local normal = data:GetNormal()
        local emitter = ParticleEmitter(pos)
        if not emitter then return end

        for i = 1, 5 do
            local particle = emitter:Add("particle/smokestack", pos + normal * math.Rand(0, 2))
            if particle then
                particle:SetVelocity(normal * math.Rand(8, 18) + VectorRand() * 10)
                particle:SetDieTime(math.Rand(0.25, 0.45))
                particle:SetStartAlpha(math.Rand(45, 70))
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(3, 5))
                particle:SetEndSize(math.Rand(9, 14))
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-1, 1))
                particle:SetColor(95, 95, 90)
                particle:SetAirResistance(45)
                particle:SetGravity(Vector(0, 0, math.Rand(4, 10)))
            end
        end

        emitter:Finish()
    end

    function EFFECT:Think()
        return false
    end

    function EFFECT:Render()
    end

    effects.Register(EFFECT, "chainsaw_hardhit_smoke")
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "snd_jack_hmcd_knifehit.wav"
SWEP.Attack2Hit = "snd_jack_hmcd_knifehit.wav"
SWEP.AttackHitFlesh = "weapons/knife/knife_hit1.wav"
SWEP.Attack2HitFlesh = "physics/flesh/flesh_impact_hard1.wav"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft2.wav"

SWEP.AttackPos = Vector(0,0,0)
SWEP.BlockTier = 3
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {145, 155}}

SWEP.BlockDirectionalCharge = "overhead" --left, right, overhead, center, neutral

function SWEP:CanSecondaryAttack()
    return true
end

function SWEP:CanBlock()
    return not self.ChainsawOn and not self.ChainsawStartAttempting
end

function SWEP:CanChargeAttack()
    return not self.ChainsawOn and not self.ChainsawStartAttempting
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_SLASH
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "snd_jack_hmcd_axehit.wav"
    self.AttackHitFlesh = "snd_jack_hmcd_axehit.wav"
    return true
end

function SWEP:InitAdd()
    self.ChainsawFuelCurrent = self.ChainsawFuelCurrent or self.ChainsawFuel
    self.ChainsawStartAttempts = 0
    self.ChainsawNeededAttempts = nil

    util.PrecacheSound(self.ChainsawStartSound)
    util.PrecacheSound(self.ChainsawAttemptSound)
    for _, snd in ipairs(self.ChainsawIdleSounds) do util.PrecacheSound(snd) end
    util.PrecacheSound(self.ChainsawAttackStartSound)
    for _, snd in ipairs(self.ChainsawAttackLoopSounds) do util.PrecacheSound(snd) end
    util.PrecacheSound(self.ChainsawAttackStopSound)
    util.PrecacheSound(self.ChainsawTurnOffSound)
end

function SWEP:GetChainsawFuel()
    return self.ChainsawFuelCurrent or self.ChainsawFuel or 0
end

function SWEP:SetChainsawFuel(fuel)
    self.ChainsawFuelCurrent = math.Clamp(fuel, 0, self.ChainsawFuel or 100)
end

function SWEP:EmitChainsawSound(snd, level, pitch, chan)
    if CLIENT then return end

    local owner = self:GetOwner()
    if IsValid(owner) then
        owner:EmitSound(snd, level or 85, pitch or 100, 1, chan or CHAN_AUTO)
    end
end

function SWEP:PlayChainsawAttemptSounds()
    self.ChainsawSoundToken = (self.ChainsawSoundToken or 0) + 1
    local token = self.ChainsawSoundToken

    timer.Simple(self.ChainsawAttemptSoundFirstDelay or 0.1, function()
        if not IsValid(self) or self.ChainsawSoundToken ~= token then return end
        self:EmitChainsawSound(self.ChainsawAttemptSound, 90, 100, CHAN_WEAPON)
    end)

    timer.Simple(self.ChainsawAttemptSoundSecondDelay or 0.35, function()
        if not IsValid(self) or self.ChainsawSoundToken ~= token then return end
        self:EmitChainsawSound(self.ChainsawAttemptSound, 90, 100, CHAN_WEAPON2)
    end)
end

function SWEP:PlayChainsawStartSounds()
    self.ChainsawSoundToken = (self.ChainsawSoundToken or 0) + 1
    local token = self.ChainsawSoundToken

    timer.Simple(self.ChainsawStartAttemptSoundDelay or 0.1, function()
        if not IsValid(self) or self.ChainsawSoundToken ~= token or not self.ChainsawOn then return end
        self:EmitChainsawSound(self.ChainsawAttemptSound, 90, 100, CHAN_WEAPON)
    end)

    timer.Simple(self.ChainsawStartSoundDelay or 0.2, function()
        if not IsValid(self) or self.ChainsawSoundToken ~= token or not self.ChainsawOn then return end
        self:EmitChainsawSound(self.ChainsawStartSound, 90, 100, CHAN_WEAPON2)
    end)
end

function SWEP:StopChainsawSounds()
    self:StopChainsawIdleLoop()
    self:StopChainsawAttackLoop()
end

function SWEP:BumpChainsawStateToken()
    self.ChainsawStateToken = (self.ChainsawStateToken or 0) + 1
    return self.ChainsawStateToken
end

function SWEP:StopChainsawIdleLoop()
    if self.ChainsawIdleLoop then
        self.ChainsawIdleLoop:Stop()
        self.ChainsawIdleLoop = nil
    end

    self.ChainsawIdleLoopPlaying = false
end

function SWEP:StopChainsawAttackLoop()
    if self.ChainsawAttackLoop then
        self.ChainsawAttackLoop:Stop()
        self.ChainsawAttackLoop = nil
    end

    self.ChainsawAttackLoopCurrentPitch = nil
end

function SWEP:SetChainsawAttackLoopPitch(pitch, time)
    if not self.ChainsawAttackLoop or self.ChainsawAttackLoopCurrentPitch == pitch then return end

    self.ChainsawAttackLoopCurrentPitch = pitch
    self.ChainsawAttackLoop:ChangePitch(pitch, time or 0)
end

function SWEP:DoChainsawHardHitEffect(trace)
    local effectdata = EffectData()
    effectdata:SetOrigin(trace.HitPos + trace.HitNormal * 1.5)
    effectdata:SetNormal(trace.HitNormal)
    util.Effect("chainsaw_hardhit_smoke", effectdata, true, true)
end

function SWEP:PlayChainsawHardHit(trace)
    sound.Play(self.ChainsawHardHitSound, trace.HitPos, 75, math.random(95, 105), 1)
    self:DoChainsawHardHitEffect(trace)
end

function SWEP:DoChainsawHitShake(owner, trace)
    if IsValid(owner) and owner.ScreenShake then
        owner:ScreenShake(trace.HitPos, self.HitScreenShakeAmp or 22, self.HitScreenShakeFreq or 6, self.HitScreenShakeDur or 0.28, self.HitScreenShakeRadius or 110, false)
    end
end

function SWEP:PlayChainsawPlayerHit(trace)
    local snd = table.Random(self.ChainsawPlayerHitSounds)
    if snd then sound.Play(snd[1], trace.HitPos, snd[2] or 55, math.random(snd[3][1], snd[3][2]), 1) end
end

function SWEP:PlayChainsawFleshHit(trace)
    if (self.ChainsawNextFleshHitSound or 0) > CurTime() then return end

    self.ChainsawFleshHitSoundIndex = (self.ChainsawFleshHitSoundIndex or 0) + 1
    if self.ChainsawFleshHitSoundIndex > #self.ChainsawFleshHitSounds then self.ChainsawFleshHitSoundIndex = 1 end

    local gore = self.ChainsawFleshHitSounds[self.ChainsawFleshHitSoundIndex]
    if gore then
        sound.Play(gore[1], trace.HitPos, gore[2] or 85, math.random(gore[3][1], gore[3][2]), 1)
        self.ChainsawNextFleshHitSound = CurTime() + math.max(SoundDuration(gore[1]) or 0, 0.35)
    end
end

function SWEP:PlayChainsawLoop(name)
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if name == "idle" then
        self:StopChainsawAttackLoop()
        if not self.ChainsawIdleLoopPlaying then
            self.ChainsawIdleLoopPlaying = true
            self.ChainsawIdleLoop = CreateSound(self, table.Random(self.ChainsawIdleSounds))

            if self.ChainsawIdleLoop then
                self.ChainsawIdleLoop:Play()
                self.ChainsawIdleLoop:SetSoundLevel(85)
            end
        end
    elseif name == "attack" then
        self:StopChainsawIdleLoop()
        if self.ChainsawAttackLoop then return end
        self.ChainsawAttackLoop = CreateSound(self, table.Random(self.ChainsawAttackLoopSounds))

        if self.ChainsawAttackLoop then
            self.ChainsawAttackLoop:Play()
            self.ChainsawAttackLoop:SetSoundLevel(95)
            self:SetChainsawAttackLoopPitch(self.ChainsawAttackLoopPitch or 100, 0)
        end
    end
end

function SWEP:PlayChainsawFailedStart(attemptTime)
    self.ChainsawAttemptToken = (self.ChainsawAttemptToken or 0) + 1
    local token = self.ChainsawAttemptToken
    local stateToken = self:BumpChainsawStateToken()
    local busyEnd = CurTime() + attemptTime + (self.ChainsawToggleCooldown or 0)

    self.ChainsawOn = false
    self.ChainsawStartAttempting = true
    self.ChainsawAttacking = false
    self.ChainsawAttackStarted = false
    self.ChainsawAttackLoopStarted = false
    self.ChainsawNextHit = nil
    self.ChainsawToggleBusyUntil = busyEnd
    self:StopChainsawSounds()
    self:PlayChainsawAttemptSounds()
    self:PlayAnim("turn_on", attemptTime, false, nil, false, false)

    timer.Simple(attemptTime, function()
        if not IsValid(self) or self.ChainsawAttemptToken ~= token or self.ChainsawStateToken ~= stateToken or self.ChainsawOn then return end
        self:PlayAnim("idle", 10, true, nil, false, false)
    end)

    timer.Simple(busyEnd - CurTime(), function()
        if not IsValid(self) or self.ChainsawAttemptToken ~= token or self.ChainsawStateToken ~= stateToken or self.ChainsawOn then return end
        self.ChainsawStartAttempting = false
    end)
end

function SWEP:GetNeededStartAttempts()
    local fuel = self:GetChainsawFuel()

    if fuel >= 90 then return 1 end
    if fuel >= 60 then return math.random(2, 5) end
    if fuel >= 10 then return math.random(4, 7) end
end

function SWEP:TurnChainsawOn()
    if self.ChainsawOn or (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end
    if self:GetChainsawFuel() < 10 then return end

    local turnOnTime = self.ChainsawTurnOnTime or 1.2
    local stateToken = self:BumpChainsawStateToken()
    self.ChainsawToggleBusyUntil = CurTime() + turnOnTime + (self.ChainsawToggleCooldown or 0)
    self.ChainsawOn = true
    self.ChainsawAttacking = false
    self.ChainsawStartAttempting = false
    self.ChainsawAttackStarted = false
    self.ChainsawAttackLoopStarted = false
    self:SetInAttack(false)
    self.ChainsawStartAttempts = 0
    self.ChainsawNeededAttempts = nil
    self:PlayAnim("turn_on", turnOnTime, false, nil, false, false)

    self:PlayChainsawStartSounds()

    timer.Simple(turnOnTime - self.ChainsawSoundLeadTime, function()
        if not IsValid(self) or self.ChainsawStateToken ~= stateToken or not self.ChainsawOn or self.ChainsawAttacking then return end
        self:PlayChainsawLoop("idle")
    end)

    timer.Simple(turnOnTime, function()
        if not IsValid(self) or self.ChainsawStateToken ~= stateToken or not self.ChainsawOn or self.ChainsawAttacking then return end
        self:PlayAnim("idle_on", 10, true, nil, false, false)
    end)
end

function SWEP:TurnChainsawOff()
    if (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end
    if not self.ChainsawOn or self.ChainsawStartAttempting then return end

    local turnOffTime = self.ChainsawTurnOffTime or 1
    local stateToken = self:BumpChainsawStateToken()
    self.ChainsawToggleBusyUntil = CurTime() + turnOffTime + (self.ChainsawToggleCooldown or 0)
    self.ChainsawOn = false
    self.ChainsawAttacking = false
    self.ChainsawStartAttempting = false
    self.ChainsawAttackStarted = false
    self.ChainsawAttackLoopStarted = false
    self.ChainsawNextHit = nil
    self:StopChainsawSounds()
    self:PlayAnim("turn_off", turnOffTime, false, nil, false, false)
    self:EmitChainsawSound(self.ChainsawTurnOffSound, 90, 100, CHAN_WEAPON)

    timer.Simple(turnOffTime, function()
        if not IsValid(self) or self.ChainsawStateToken ~= stateToken or self.ChainsawOn then return end
        self:PlayAnim("idle", 10, true, nil, false, false)
    end)
end

function SWEP:StartChainsawAttack()
    if not self.ChainsawOn or self.ChainsawAttacking then return end
    if (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end
    if self:GetChainsawFuel() <= 0 then return end

    self:StopChainsawIdleLoop()
    self.ChainsawAttacking = true
    self:BumpChainsawStateToken()
    self.ChainsawAttackStarted = false
    self.ChainsawAttackLoopStarted = false
    self.ChainsawAttackBegin = CurTime() + self.ChainsawAttackDelay
    self.ChainsawNextHit = self.ChainsawAttackBegin
    self:SetInAttack(false)
    self:PlayAnim("idle_to_attack", self.ChainsawAttackDelay, false, nil, false, false)
    self:EmitChainsawSound(self.ChainsawAttackStartSound, 90, 100, CHAN_ITEM)
end

function SWEP:StopChainsawAttack()
    if not self.ChainsawAttacking then return end

    local stateToken = self:BumpChainsawStateToken()
    self.ChainsawAttacking = false
    self.ChainsawAttackStarted = false
    self.ChainsawAttackLoopStarted = false
    self.ChainsawNextHit = nil
    self.ChainsawNextFleshHitSound = nil

    self:StopChainsawAttackLoop()

    self:EmitChainsawSound(self.ChainsawAttackStopSound, 90, 100, CHAN_ITEM)

    if self.ChainsawOn then
        self:PlayAnim("attack_to_idle", self.ChainsawAttackEndDelay, false, nil, false, false)

        timer.Simple(self.ChainsawIdleRestartDelay, function()
            if not IsValid(self) or self.ChainsawStateToken ~= stateToken or not self.ChainsawOn or self.ChainsawAttacking then return end
            self:PlayAnim("idle_on", 10, true, nil, false, false)
            self:PlayChainsawLoop("idle")
        end)
    end
end

function SWEP:ChainsawHit()
    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local ent = hg.GetCurrentCharacter(owner)
    if not IsValid(ent) then return end

    self.HitEnts = {owner, ent}

    owner:LagCompensation(true)
    local eyetr = hg.eyeTrace(owner, (self.ChainsawAttackLen or self.AttackLen1) + math.min(owner:GetVelocity():Length() / 15, 40), ent)
    local trace = eyetr

    if not self:IsEntSoft(eyetr.Entity) then
        local found = IsValid(eyetr.Entity) and eyetr.Entity ~= owner and eyetr.Entity ~= ent

        if not found then
            for i = 1, 9 do
                local ang = owner:EyeAngles()
                ang.yaw = ang.yaw + (i - 5) * 3.75
                ang.pitch = ang.pitch + math.sin(i * 0.5) * 2.5

                local tr = util.TraceLine({
                    start = owner:EyePos(),
                    endpos = owner:EyePos() + ang:Forward() * ((self.ChainsawAttackLen or self.AttackLen1) + math.min(owner:GetVelocity():Length() / 15, 40)),
                    filter = self.HitEnts
                })

                if IsValid(tr.Entity) and tr.Entity ~= owner and tr.Entity ~= ent then
                    trace = tr
                    break
                end
            end
        end
    end

    owner:LagCompensation(false)

    local hitent = trace.Entity
    if trace.HitWorld then
        self.ChainsawAttackLoopPitchHoldUntil = CurTime() + (self.ChainsawAttackLoopPitchHoldTime or 0.15)
        self:SetChainsawAttackLoopPitch(self.ChainsawAttackLoopHitPitch or 78, self.ChainsawAttackLoopPitchDownTime or 0.12)
        self:DoChainsawHitShake(owner, trace)
        self:PlayChainsawHardHit(trace)
        return
    end

    if not IsValid(hitent) or hitent == owner or hitent == ent then return end

    self.ChainsawAttackLoopPitchHoldUntil = CurTime() + (self.ChainsawAttackLoopPitchHoldTime or 0.15)
    self:SetChainsawAttackLoopPitch(self.ChainsawAttackLoopHitPitch or 78, self.ChainsawAttackLoopPitchDownTime or 0.12)
    self:DoChainsawHitShake(owner, trace)

    if hitent:IsPlayer() or hitent:IsRagdoll() then
        self:PlayChainsawPlayerHit(trace)
        self:PlayChainsawFleshHit(trace)
    elseif hitent:IsNPC() or self:IsEntSoft(hitent) then
        self:PlayChainsawFleshHit(trace)
    else
        self:PlayChainsawHardHit(trace)
    end

    if self:IsEntSoft(hitent) then
        util.Decal("Blood", trace.HitPos + trace.HitNormal * 15, trace.HitPos - trace.HitNormal * 15, owner)
        util.Decal("Blood", trace.HitPos + trace.HitNormal * 2, owner:GetPos(), hitent)
    end

    local mul = 1
    if owner.organism then
        mul = mul / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 1.3)
    end

    mul = mul * math.Clamp(ent:GetVelocity():Length() / 250, 0.9, 1.25)
    mul = mul * (ent ~= owner and 0.75 or 1)
    mul = mul * (owner.MeleeDamageMul or 1)

    if owner.organism and owner.organism.superfighter then
        mul = mul * 5
    end

    if owner.organism and (owner.organism.psycheAnger or 0) > 0.2 then
        mul = mul * (1 + 0.1 * math.Clamp((owner.organism.psycheAnger - 0.2) / 0.8, 0, 1))
    end

    local dmg = math.random((self.ChainsawAttackDamage or 15) - 1, (self.ChainsawAttackDamage or 15) + 1) * mul / 1.5

    if not (hitent:IsPlayer() or hitent:IsRagdoll() or hitent:IsNPC()) then
        dmg = dmg * (self.PropDamageMultiplier or 1)
    end

    local dmginfo = DamageInfo()
    dmginfo:SetAttacker(owner)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamage(dmg)
    dmginfo:SetDamageForce(trace.Normal * dmg)
    dmginfo:SetDamageType(DMG_SLASH)
    dmginfo:SetDamagePosition(trace.HitPos)
    hitent:TakeDamageInfo(dmginfo)

    local phys = hitent:GetPhysicsObjectNum(trace.PhysicsBone or 0)
    if IsValid(phys) then
        phys:ApplyForceOffset(trace.Normal * dmg * 100, trace.HitPos)
    end

    self:PrimaryAttackAdd(hitent, trace)
end

function SWEP:PrimaryAttack()
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not self:InUse() then return end
    if self.CanSuicide and owner.suiciding then return end
    if owner:KeyDown(IN_USE) then
        self:ToggleChainsaw()
        return
    end

    if self.ChainsawStartAttempting then return end
    if (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end

    if not self.ChainsawOn then
        local base = weapons.GetStored("weapon_melee")
        if base and base.PrimaryAttack then base.PrimaryAttack(self) end
        return
    end

    self:StartChainsawAttack()
end

function SWEP:ToggleChainsaw()
    if (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end

    if self.ChainsawOn then
        self:TurnChainsawOff()
        return
    end

    if self:GetChainsawFuel() < 10 then
        local attemptTime = self.ChainsawTurnOnAttemptTime or 0.8
        self.ChainsawStartAttempts = 0
        self.ChainsawNeededAttempts = nil
        self:PlayChainsawFailedStart(attemptTime)
        return
    end

    self.ChainsawNeededAttempts = self.ChainsawNeededAttempts or self:GetNeededStartAttempts()
    self.ChainsawStartAttempts = (self.ChainsawStartAttempts or 0) + 1

    if self.ChainsawStartAttempts >= self.ChainsawNeededAttempts then
        self:TurnChainsawOn()
    else
        local attemptTime = self.ChainsawTurnOnAttemptTime or 0.8
        self:PlayChainsawFailedStart(attemptTime)
    end
end

function SWEP:SecondaryAttack()
    if not game.SinglePlayer() and not IsFirstTimePredicted() then return end

    local owner = self:GetOwner()
    if not IsValid(owner) or not self:InUse() then return end
    if not owner:KeyPressed(IN_ATTACK2) then return end
    if (self.ChainsawToggleBusyUntil or 0) > CurTime() then return end
    if self.ChainsawOn or self.ChainsawStartAttempting then return end

    local base = weapons.GetStored("weapon_melee")
    if base and base.SecondaryAttack then base.SecondaryAttack(self) end
end

function SWEP:ThinkAdd()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    local ft = FrameTime()

    if self.ChainsawOn then
        self:SetChainsawFuel(self:GetChainsawFuel() - ft * (self.ChainsawAttacking and self.ChainsawFuelDrainAttack or self.ChainsawFuelDrainIdle))

        if SERVER and self.ChainsawAttacking and owner.organism and owner.organism.stamina then
            owner.organism.stamina[1] = math.max(owner.organism.stamina[1] - ft * (self.ChainsawStaminaDrainAttack or 8), 0)
        end

        if self:GetChainsawFuel() <= 0 then
            self:TurnChainsawOff()
            return
        end
    end

    if self.ChainsawAttacking and not hg.KeyDown(owner, IN_ATTACK) then
        self:StopChainsawAttack()
        return
    end

    if self.ChainsawAttackLoop and self.ChainsawAttackLoopCurrentPitch ~= (self.ChainsawAttackLoopPitch or 100) and CurTime() >= (self.ChainsawAttackLoopPitchHoldUntil or 0) then
        self:SetChainsawAttackLoopPitch(self.ChainsawAttackLoopPitch or 100, self.ChainsawAttackLoopPitchUpTime or 0.35)
    end

    if not self.ChainsawAttacking then return end

    if not self.ChainsawAttackStarted and CurTime() >= (self.ChainsawAttackBegin or 0) then
        self.ChainsawAttackStarted = true
        self.ChainsawAttackLoopStarted = true
        self:PlayAnim("attack_on", 1, true, nil, false, false)
        self:PlayChainsawLoop("attack")
        self.ChainsawNextHit = CurTime() + self.ChainsawAttackRate
    end

    if self.ChainsawAttackStarted and CurTime() >= (self.ChainsawNextHit or 0) then
        self.ChainsawNextHit = CurTime() + self.ChainsawAttackRate
        self:ChainsawHit()
    end

end

function SWEP:Holster(wep)
    self:StopChainsawSounds()
    self.ChainsawOn = false
    self.ChainsawAttacking = false
    self.ChainsawStartAttempting = false
    self.ChainsawAttackStarted = false
    self:BumpChainsawStateToken()
    self:SetInAttack(false)
    self:CancelChargeAttack(false)
    self:ResetCombo()
    return true
end

function SWEP:OnRemove()
    self:StopChainsawSounds()

    local base = weapons.GetStored("weapon_melee")
    if base and base.OnRemove then base.OnRemove(self) end
end

SWEP.AttackTimeLength = 0.1
SWEP.Attack2TimeLength = 0.05

SWEP.AttackRads = 85
SWEP.AttackRads2 = 35

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.MultiDmg1 = true
SWEP.MultiDmg2 = false

function SWEP:SecondaryAttackAdd(ent, trace)
    if trace.Entity:IsPlayer() or trace.Entity:IsNPC() then trace.Entity:SetVelocity(trace.Normal * 70 * (trace.Entity:IsNPC() and 35 or 5)) end
    local phys = trace.Entity:GetPhysicsObjectNum(trace.PhysicsBone or 0)

    if IsValid(phys) then
        phys:ApplyForceOffset(trace.Normal * 42 * 100,trace.HitPos)
    end
end

SWEP.MinSensivity = 0.25
