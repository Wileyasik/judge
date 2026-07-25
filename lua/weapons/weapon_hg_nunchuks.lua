if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Nunchucks"
SWEP.Instructions = "A pair of traditional nunchucks—two short sticks connected by a chain—designed for fast, fluid strikes and defensive control. Lightweight and agile, they reward timing and precision over brute force.\n\nLMB to attack.\nRMB to block.\nR + LMB for rapid strikes."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/models/namje/wep/w_nunchucks.mdl"
SWEP.WorldModelReal = "models/models/danguyen/c_nunchucks.mdl"
SWEP.ViewModel = ""

SWEP.HoldType = "melee"

SWEP.HoldPos = Vector(-8.5,2,3)
SWEP.HoldAng = Angle(0,0,0)

SWEP.AttackTime = 0.35
SWEP.AnimTime1 = 0.75
SWEP.WaitTime1 = 0.6
SWEP.ViewPunch1 = Angle(0,2,-2)
SWEP.DrawAnimTime = 1.8
SWEP.BlockAnimTime = 2.25
SWEP.BlockAnimFreezeCycle = 0.08
SWEP.LoopAttackTime = 0.3
SWEP.LoopAnimTime = 0.85
SWEP.LoopWaitTime = 0.1
SWEP.LoopAttackTimeLength = 0.13
SWEP.LoopAttackLen = 42
SWEP.LoopAttackDamage = 11
SWEP.LoopAttackStamina = 8
SWEP.LoopAttackSwingAngle = 60
SWEP.LoopAttackRads = 60
SWEP.LoopAttackSwingAngleLeft = nil
SWEP.LoopAttackSwingAngleRight = nil
SWEP.LoopAttackRadsLeft = nil
SWEP.LoopAttackRadsRight = nil
SWEP.LoopAttackMinStamina = 95
SWEP.LoopAttackStopCooldown = 1.55
SWEP.LoopAttackGraceTime = 0.25
SWEP.LoopAttackAnim = "misscenter3"

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-4)

SWEP.attack_ang = Angle(0,0,0)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 94



SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 14
SWEP.DamageSecondary = 13

SWEP.PenetrationPrimary = 1
SWEP.PenetrationSecondary = 1

SWEP.MaxPenLen = 3

SWEP.PenetrationSizePrimary = 2
SWEP.PenetrationSizeSecondary = 2

SWEP.StaminaPrimary = 10
SWEP.StaminaSecondary = 8

SWEP.AttackLen1 = 40
SWEP.AttackLen2 = 30

SWEP.AnimList = {
    ["idle"] = "idle01",
    ["deploy"] = "draw",
    ["attack"] = "misscenter1",
    ["attack2"] = "jab",
    ["attack_loop"] = "misscenter3",
}


if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/nunchucks.png")
	SWEP.IconOverride = "vgui/nunchucks.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false

SWEP.AttackHit = "Plastic_Box.ImpactHard"
SWEP.Attack2Hit = "Plastic_Box.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "Plastic_Box.ImpactSoft"
SWEP.SwingSoundPitch = 165
SWEP.HitFleshExtra = {
    "fist1.mp3",
    "fist2.mp3",
}

SWEP.BlockTier = 2
SWEP.MeleeMaterial = "metal"
SWEP.BlockImpactSound = "Plastic_Box.ImpactHard"

SWEP.AttackPos = Vector(0,0,0)
--[[
function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    return true
end

function SWEP:CanPrimaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Concrete.ImpactHard"
    self.Attack2Hit = "Concrete.ImpactHard"
    return true
end
]]

function SWEP:CanSecondaryAttack()
    return false
end

function SWEP:PrimaryAttack()
    local owner = self:GetOwner()
    if IsValid(owner) and hg.KeyDown(owner, IN_RELOAD) then return end
    return self.BaseClass.PrimaryAttack(self)
end

function SWEP:CanStartLoopAttack(requireAttackReady, checkCooldown)
    if requireAttackReady == nil then requireAttackReady = true end
    if checkCooldown == nil then checkCooldown = true end

    local owner = self:GetOwner()
    if not IsValid(owner) then return false end
    if self:GetBlocking() then return false end
    if not self:InUse() then return false end
    if requireAttackReady then
        if self:GetInAttack() then return false end
        if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return false end
        if self.lastattack and (self.lastattack + self.attackwait) > CurTime() then return false end
    end
    if checkCooldown and (self.LoopAttackCooldownEnd or 0) > CurTime() then return false end

    local staminaMin = self.LoopAttackMinStamina or 30
    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] and owner.organism.stamina[1] < staminaMin then
        return false
    end

    return true
end

function SWEP:SetLoopAttackOverrides(enable, direction)
    if enable then
        local leftSwing = self.LoopAttackSwingAngleLeft
        if leftSwing == nil then leftSwing = -(self.LoopAttackSwingAngle or 60) end
        local rightSwing = self.LoopAttackSwingAngleRight
        if rightSwing == nil then rightSwing = (self.LoopAttackSwingAngle or 60) end

        local leftRads = self.LoopAttackRadsLeft
        if leftRads == nil then leftRads = -(self.LoopAttackRads or 60) end
        local rightRads = self.LoopAttackRadsRight
        if rightRads == nil then rightRads = (self.LoopAttackRads or 60) end

        local isLeftSwing = (direction or 1) == 1
        local swing = isLeftSwing and leftSwing or rightSwing
        local rads = isLeftSwing and leftRads or rightRads

        if self.LoopAttackOldValues then
            self.SwingAng = swing
            self.AttackRads = rads
            return
        end

        self.LoopAttackOldValues = {
            DamagePrimary = self.DamagePrimary,
            StaminaPrimary = self.StaminaPrimary,
            AttackRads = self.AttackRads,
            SwingAng = self.SwingAng,
            AttackLen1 = self.AttackLen1,
            AttackTimeLength = self.AttackTimeLength
        }

        self.DamagePrimary = self.LoopAttackDamage or self.DamagePrimary
        self.StaminaPrimary = self.LoopAttackStamina or self.StaminaPrimary
        self.AttackRads = rads
        self.SwingAng = swing
        self.AttackLen1 = self.LoopAttackLen or self.AttackLen1
        self.AttackTimeLength = self.LoopAttackTimeLength or self.AttackTimeLength
        return
    end

    if not self.LoopAttackOldValues then return end

    self.DamagePrimary = self.LoopAttackOldValues.DamagePrimary
    self.StaminaPrimary = self.LoopAttackOldValues.StaminaPrimary
    self.AttackRads = self.LoopAttackOldValues.AttackRads
    self.SwingAng = self.LoopAttackOldValues.SwingAng
    self.AttackLen1 = self.LoopAttackOldValues.AttackLen1
    self.AttackTimeLength = self.LoopAttackOldValues.AttackTimeLength
    self.LoopAttackOldValues = nil
end

function SWEP:StartLoopAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not self:CanStartLoopAttack(true, false) then return end

    local direction = self.LoopAttackDirection or 1
    self.LoopAttackDirection = direction == 1 and -1 or 1
    self:SetLoopAttackOverrides(true, direction)

    local mul = 1
    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
        mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)
    end

    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.HitWorld = false
    self:SetNWBool("LoopActive", true)
    self:SetAttackType(1)
    self:SetLastAttack(CurTime() + (self.LoopAttackTime or self.AttackTime) / mul)
    self:SetAttackTime(self:GetLastAttack() + (self.LoopAttackTimeLength or self.AttackTimeLength) / mul)
    self:SetAttackLength(self.LoopAttackLen or self.AttackLen1)
    self:SetAttackWait((self.LoopWaitTime or self.WaitTime1) / mul)
    self:SetInAttack(true)
    self.lastattack = CurTime() + (self.LoopAttackTime or self.AttackTime) / mul
    self.attackwait = (self.LoopWaitTime or self.WaitTime1) / mul
    self.viewpunch = true
end

function SWEP:StartTapSecondaryAttack()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self:GetBlocking() then return end
    if not self:InUse() then return end
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end
    if self.lastattack and (self.lastattack + self.attackwait) > CurTime() then return end

    local mul = 1
    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
        mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)
    end

    self.HitEnts = nil
    self.FirstAttackTick = false
    self.AttackHitPlayed = false
    self.HitWorld = false
    self:PlayAnim("attack2", self.AnimTime2 / mul, false, nil, false, true)
    self:SetAttackType(2)
    self:SetLastAttack(CurTime() + self.Attack2Time / mul)
    self:SetAttackTime(self:GetLastAttack() + (self.Attack2TimeLength / mul))
    self:SetAttackLength(self.AttackLen2)
    self:SetAttackWait(self.WaitTime2 / mul)
    self:SetInAttack(true)
    self.lastattack = CurTime() + self.Attack2Time / mul
    self.attackwait = self.WaitTime2 / mul
    self.viewpunch = true
end

function SWEP:ThinkAdd()
    if CLIENT then
        local blocking = self:GetBlocking()
        local blockAnimTime = self.BlockAnimTime or self.DrawAnimTime or 1.25

        if self.LastBlockingState == nil then
            self.LastBlockingState = blocking
        else
            if blocking and self.BlockAnimFreezeAt and CurTime() >= self.BlockAnimFreezeAt then
                self.BlockAnimHolding = true
                self.BlockAnimFreezeAt = nil
            end

            if blocking and self.BlockAnimHolding then
                self.reverseanim = true
                self.cycling = false
                self.animspeed = blockAnimTime
                self.animtime = CurTime() + blockAnimTime * (self.BlockAnimFreezeCycle or 0.08)
            end

            if blocking ~= self.LastBlockingState then
                if blocking then
                    self.BlockAnimHolding = false
                    self.BlockAnimFreezeAt = CurTime() + blockAnimTime * (1 - (self.BlockAnimFreezeCycle or 0.08))
                    self:PlayAnim("deploy", blockAnimTime, false, nil, true, true)
                else
                    self.BlockAnimHolding = false
                    self.BlockAnimFreezeAt = nil
                    self:PlayAnim("deploy", blockAnimTime, false, nil, false, true)
                end

                self.LastBlockingState = blocking
            end
        end

        if self:IsLocal() then
            local inAttack = self:GetInAttack()
            if inAttack and not self._clWasInAttack and self:GetAttackType() == 1 then
                local loopActive = self:GetNWBool("LoopActive", false)
                if loopActive then
                    local mul = 1
                    local owner = self:GetOwner()
                    if IsValid(owner) and owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
                        mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)
                    end
                    self:PlayAnim(self.LoopAttackAnim or "attack_loop", (self.LoopAnimTime or self.AnimTime1) / mul, false, nil, false, true)
                else
                    timer.Simple(0.05, function()
                        if not IsValid(self) then return end
                        local stillInAttack = self:GetInAttack()
                        local loopNow = self:GetNWBool("LoopActive", false)
                        if stillInAttack and loopNow and self:GetAttackType() == 1 then
                            local mul = 1
                            local owner = self:GetOwner()
                            if IsValid(owner) and owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
                                mul = 1 / math.Clamp((180 - owner.organism.stamina[1]) / 90, 1, 2)
                            end
                            self:PlayAnim(self.LoopAttackAnim or "attack_loop", (self.LoopAnimTime or self.AnimTime1) / mul, false, nil, false, true)
                        end
                    end)
                end
            end
            self._clWasInAttack = inAttack
        end
    end

    if CLIENT then return end

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self.LoopAttackOldValues and not self:GetInAttack() then
        self:SetLoopAttackOverrides(false)
    end

    local staminaReady = true
    local staminaMin = self.LoopAttackMinStamina or 30
    if owner.organism and owner.organism.stamina and owner.organism.stamina[1] then
        staminaReady = owner.organism.stamina[1] >= staminaMin
    end

    local inputDown = hg.KeyDown(owner, IN_RELOAD) and hg.KeyDown(owner, IN_ATTACK) and not hg.KeyDown(owner, IN_ATTACK2)

    local wantLoop = inputDown and staminaReady
    local canStartLoopState = self:CanStartLoopAttack(false, true)
    local canStayLoopState = self:CanStartLoopAttack(false, false)
    local now = CurTime()

    if self.LoopAttackPendingUntil then
        if not inputDown then
            self.LoopAttackPendingUntil = nil
            self:StartTapSecondaryAttack()
        elseif now >= self.LoopAttackPendingUntil then
            self.LoopAttackPendingUntil = nil
            if canStartLoopState then
                self.LoopInputState = true
                self:SetNWBool("LoopActive", true)
                self:PlayAnim(self.LoopAttackAnim or "attack_loop", self.LoopAnimTime or self.AnimTime1, true, nil, false, true)
            end
        end
    end

    if wantLoop and not self.LoopInputState and not self.LoopAttackPendingUntil and canStartLoopState then
        self.LoopAttackPendingUntil = now + (self.LoopAttackGraceTime or 0.25)
    elseif self.LoopInputState and (not wantLoop or not canStayLoopState) then
        self.LoopInputState = false
        self.LoopAttackPendingUntil = nil
        self.LoopAttackCooldownEnd = CurTime() + (self.LoopAttackStopCooldown or 1)
        self:SetNWBool("LoopActive", false)
        self:PlayAnim(self.LoopAttackAnim or "attack_loop", self.LoopAnimTime or self.AnimTime1, false, nil, false, true)
    end

    if self.LoopInputState and self:CanStartLoopAttack(true, false) then
        self:StartLoopAttack()
    end
end

function SWEP:CustomBlockAnim()
    return self:GetBlocking()
end

function SWEP:Feint()
    return
end

SWEP.AttackTimeLength = 0.155
SWEP.Attack2TimeLength = 0.1

SWEP.AttackRads = 85
SWEP.AttackRads2 = 0

SWEP.SwingAng = -60
SWEP.SwingAng2 = 0

if CLIENT then
    function SWEP:PlaySwingSound(owner, attacktype)
        if attacktype == 2 then return end

        local pitch = self.SwingSoundPitch or 100
        local volume = 0.6

        if self.LoopInputState then
            pitch = pitch + math.random(-8, 8)
            volume = 0.45
        end

        sound.Play("weapons/melee/whoosh.wav", owner:GetShootPos(), 75, pitch, volume)

        if self.LoopInputState then
            sound.Play("physics/metal/metal_chain_impact_soft1.wav", owner:GetShootPos(), 70, math.random(120, 140), 0.3)
        end
    end
end

function SWEP:PrimaryAttackAdd(ent, trace)
    if CLIENT then
        local hitPos = trace.HitPos
        local hitNormal = trace.HitNormal or Vector(0, 0, 1)

        if ent:IsPlayer() or (ent:IsNPC() and ent:Health() > 0) then
            local fx = EffectData()
            fx:SetOrigin(hitPos)
            fx:SetNormal(hitNormal)
            fx:SetMagnitude(1)
            fx:SetScale(0.4)
            util.Effect("BloodImpact", fx)
        end

        if self.LoopInputState then
            self:GetOwner():ViewPunch(Angle(math.Rand(-1.5, 1.5), math.Rand(-2, 2), math.Rand(-0.5, 0.5)))
        else
            self:GetOwner():ViewPunch(Angle(math.Rand(-0.8, 0.8), math.Rand(-1, 1), math.Rand(-0.3, 0.3)))
        end
    end

    if SERVER then
        local hitPos = trace.HitPos

        if ent:IsPlayer() or (ent:IsNPC() and ent:Health() > 0) then
            if self.LoopInputState then
                sound.Play("physics/body/body_medium_impact_hard" .. math.random(1, 5) .. ".wav", hitPos, 75, math.random(105, 120))
            else
                sound.Play("physics/body/body_medium_impact_hard" .. math.random(1, 5) .. ".wav", hitPos, 70, math.random(95, 108))
            end
        else
            if self.LoopInputState then
                sound.Play("physics/wood/wood_solid_impact_hard" .. math.random(1, 5) .. ".wav", hitPos, 75, math.random(110, 125))
            else
                sound.Play("physics/wood/wood_solid_impact_hard" .. math.random(1, 5) .. ".wav", hitPos, 70, math.random(100, 112))
            end
        end
    end
end
