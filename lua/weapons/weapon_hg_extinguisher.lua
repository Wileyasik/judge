if SERVER then AddCSLuaFile() end
if SERVER then
    util.AddNetworkString("hg_extinguisher_explode_fx")
end

local EXTINGUISHER_CLASS = "weapon_hg_extinguisher"

SWEP.Base = "weapon_melee"
SWEP.PrintName = "Fire Extinguisher"
SWEP.Instructions = "This is a hand-held cylindrical pressure vessel containing an agent that can be discharged to extinguish a fire.\n\nLMB to attack.\nR to change mode.\nRMB to block."
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 0
SWEP.WorldModel = "models/weapons/tfa_nmrih/w_tool_extinguisher.mdl"
SWEP.WorldModelReal = "models/weapons/tfa_nmrih/v_tool_extinguisher.mdl"
SWEP.DontChangeDropped = false
SWEP.ViewModel = ""

SWEP.bloodID = 3

SWEP.HoldType = "revolver"

SWEP.DamageType = DMG_SLASH
SWEP.weight = 4

SWEP.HoldPos = Vector(-15,1,2)
SWEP.HoldAng = Angle()

SWEP.AttackTime = 0.47
SWEP.AnimTime1 = 2
SWEP.WaitTime1 = 1.85
SWEP.ViewPunch1 = Angle(1,2,0)

SWEP.Attack2Time = 0.25
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.8
SWEP.ViewPunch2 = Angle(0,0,-2)

SWEP.attack_ang = Angle(0,0,-15)
SWEP.sprint_ang = Angle(15,0,0)

SWEP.basebone = 93

SWEP.weaponPos = Vector(0,2,0.3)
SWEP.weaponAng = Angle(0,0,0)

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 32
SWEP.DamageSecondary = 15

SWEP.PenetrationPrimary = 5
SWEP.PenetrationSecondary = 4

SWEP.MaxPenLen = 5

SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 1.25

SWEP.StaminaPrimary = 40
SWEP.StaminaSecondary = 15

SWEP.AttackLen1 = 48
SWEP.AttackLen2 = 30

SWEP.BlockTier = 5
SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_solid_impact_hard1.wav", 68, {95, 102}}


SWEP.AnimList = {
    ["idle"] = "Idle",
    ["deploy"] = "Draw",
    ["attack"] = "Attack_Quick",
    ["attack2"] = "HoseSpray",
    ["equip"] = "HoseEquip",
    ["holster"] = "HoseUnquip",
}

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/hud/tfa_nmrih_fext")
	SWEP.IconOverride = "vgui/hud/tfa_nmrih_fext"
	SWEP.BounceWeaponIcon = false
end

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = true

SWEP.AttackHit = "Canister.ImpactHard"
SWEP.Attack2Hit = "Canister.ImpactHard"
SWEP.AttackHitFlesh = "Flesh.ImpactHard"
SWEP.Attack2HitFlesh = "Flesh.ImpactHard"
SWEP.DeploySnd = "physics/metal/metal_grenade_impact_soft1.wav"

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

SWEP.hitsoundplus = {
    {"fireextinguisher/rem_extinhit1.wav", 75, {95, 105}},
    {"fireextinguisher/rem_extinhit2.wav", 75, {95, 105}},
    {"fireextinguisher/rem_extinhit3.wav", 75, {95, 105}},
    {"fireextinguisher/rem_extinhit4.wav", 75, {95, 105}},
}

SWEP.swingsoundextra = {
    {"bat/baseball_swing_1st_layer_01.wav", 60, {80, 95}},
    {"bat/baseball_swing_1st_layer_02.wav", 60, {80, 95}},
    {"bat/baseball_swing_1st_layer_03.wav", 60, {80, 95}},
    {"bat/baseball_swing_1st_layer_04.wav", 60, {80, 95}},
}

SWEP.AttackPos = Vector(0,0,0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.01

SWEP.AttackRads = 60
SWEP.AttackRads2 = 0

SWEP.SwingAng = -30
SWEP.SwingAng2 = 0

SWEP.BulletBlockExplodeChance = 0.2
SWEP.DroppedExplodeChance = 0.5
SWEP.BulletBlockFrontDot = 0.12
SWEP.BulletBlockTraceDist = 32
SWEP.ExplosionRadius = 140
SWEP.ExplosionDamage = 2
SWEP.ExplosionFireOutRadius = 140

SWEP.SprayTickInterval = 0.05
SWEP.SprayDrainPerSecond = 6
SWEP.SprayRange = 256
SWEP.SprayHullSize = 14
SWEP.SprayForceRampTime = 0.7
SWEP.SpraySelfForce = 3625
SWEP.SpraySelfMaxSpeed = 290
SWEP.SpraySelfStandingPush = 15
SWEP.SpraySelfRagdollChance = 0.45
SWEP.SpraySelfRagdollDelay = 4.5
SWEP.SpraySelfLightStunTime = 0.75
SWEP.SprayStandingPush = 41
SWEP.SprayStandingMaxSpeed = 220
SWEP.SprayKnockdownTime = 2
SWEP.SprayKnockdownForce = 5500
SWEP.SprayRagdollForce = 2800
SWEP.SprayRagdollMaxSpeed = 275
SWEP.SprayPropForce = 10250
SWEP.SprayPropMaxSpeed = 320
SWEP.SprayKnockdownCooldown = 6
SWEP.SprayContactGrace = 0.15
SWEP.SprayLightStunTime = 1.25

local function GetSprayPlayer(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return ent end
    return hg.RagdollOwner and hg.RagdollOwner(ent) or nil
end

local function ApplySprayForce(ragdoll, direction, force, maxSpeed, dt)
    if not IsValid(ragdoll) or not isvector(direction) or direction:LengthSqr() <= 0 then return end

    local physics = {}
    for _, bone in ipairs({0, 1}) do
        local phys = ragdoll:GetPhysicsObjectNum(bone)
        if IsValid(phys) then physics[#physics + 1] = phys end
    end
    if #physics == 0 then return end

    for _, phys in ipairs(physics) do
        if not maxSpeed or phys:GetVelocity():Dot(direction) < maxSpeed then
            phys:Wake()
            phys:ApplyForceCenter(direction * force * (dt or 0.05) / 0.05 / #physics)
        end
    end
end

local function GetSprayDirection(owner, reverse)
    local direction = owner:GetAimVector()
    if direction:LengthSqr() <= 0 then return end
    direction:Normalize()
    return reverse and -direction or direction
end

local function GetHorizontalSprayDirection(owner, reverse)
    local direction = GetSprayDirection(owner, reverse)
    if not direction then return end
    direction.z = 0
    if direction:LengthSqr() <= 0 then return end
    return direction:GetNormalized()
end

local function GetSprayForceScale(exposure, rampTime)
    local fraction = math.Clamp((exposure or 0) / (rampTime or 0.7), 0, 1)
    return fraction * fraction * (3 - 2 * fraction)
end

local function GetExtinguisherSprayTrace(owner, range, hullSize)
    local startPos, aim, filter = hg.eye(owner, range)
    if not isvector(startPos) or not isvector(aim) then return end

    local hull = Vector(hullSize, hullSize, hullSize)
    return util.TraceHull({
        start = startPos,
        endpos = startPos + aim,
        mins = -hull,
        maxs = hull,
        filter = filter,
        mask = MASK_SHOT
    })
end

local function PushStandingPlayer(ply, direction, amount, maxSpeed, dt)
    if not IsValid(ply) or not isvector(direction) or direction:LengthSqr() <= 0 then return end
    direction = direction:GetNormalized()

    local speedLimit = maxSpeed or amount or 10
    local speedAlongPush = ply:GetVelocity():Dot(direction)
    local impulse = math.min((amount or 10) * (dt or 0.05) / 0.05 * 0.35, speedLimit - speedAlongPush)
    if impulse <= 0 then return end

    -- Player:SetVelocity adds to the current velocity; passing it back here causes exponential acceleration.
    ply:SetVelocity(direction * impulse)
end

local function PushPhysicalEntity(ent, direction, force, maxSpeed, hitPos, dt)
    if not IsValid(ent) or not isvector(direction) then return end
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) or phys:GetVelocity():Dot(direction) >= maxSpeed then return end

    local massScale = math.Clamp(phys:GetMass() / 50, 0.5, 2)
    phys:Wake()
    phys:ApplyForceOffset(direction * force * massScale * (dt or 0.05) / 0.05, hitPos or phys:GetPos())
end

local function GetExtinguisherImpactPos(ent, dmginfo)
    local pos = dmginfo.GetDamagePosition and dmginfo:GetDamagePosition() or vector_origin

    if isvector(pos) and pos ~= vector_origin then
        return pos
    end

    local attacker = dmginfo:GetAttacker()

    if IsValid(attacker) then
        local attackPos = attacker.GetShootPos and attacker:GetShootPos() or attacker.WorldSpaceCenter and attacker:WorldSpaceCenter() or attacker:GetPos()

        if isvector(attackPos) then
            return ent:NearestPoint(attackPos)
        end
    end

    return ent.WorldSpaceCenter and ent:WorldSpaceCenter() or ent:GetPos()
end

local function GetExtinguisherAttackPos(ent, dmginfo, hitPos)
    local attacker = dmginfo:GetAttacker()

    if IsValid(attacker) then
        return attacker.GetShootPos and attacker:GetShootPos() or attacker.WorldSpaceCenter and attacker:WorldSpaceCenter() or attacker:GetPos()
    end

    local force = dmginfo.GetDamageForce and dmginfo:GetDamageForce() or vector_origin

    if isvector(force) and force:LengthSqr() > 0.001 then
        return hitPos - force:GetNormalized() * 128
    end

    return hitPos - ent:GetForward() * 64
end

local function ExtinguishExplosionTarget(ent)
    if not IsValid(ent) then return end

    local class = ent:GetClass()

    if class == "vfire" or class == "vfire_ball" then
        if ent.ChangeLife then
            ent:ChangeLife(0)
        else
            ent:Remove()
        end

        return
    end

    if class == "vfire_cluster" then
        if ent.fires then
            for fire in pairs(ent.fires) do
                if IsValid(fire) then
                    fire:Remove()
                end
            end
        end

        return
    end

    if ent.fires or ent:IsOnFire() then
        ent:Extinguish()
    end
end

local function ExtinguishNearbyFires(pos, radius)
    for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
        if not IsValid(ent) then continue end

        local class = ent:GetClass()

        if class == "vfire" or class == "vfire_ball" or class == "vfire_cluster" or ent.fires or ent:IsOnFire() then
            ExtinguishExplosionTarget(ent)
        end
    end
end

local function SendExtinguisherExplosionFx(pos)
    if not SERVER then return end

    net.Start("hg_extinguisher_explode_fx")
    net.WriteVector(pos)
    net.Broadcast()
end

local function ExplodeExtinguisher(wep, attacker, pos)
    if not SERVER or not IsValid(wep) or wep.ExtinguisherExploded then return end

    wep.ExtinguisherExploded = true

    local owner = wep.GetOwner and wep:GetOwner() or nil
    local explodePos = pos or wep.WorldSpaceCenter and wep:WorldSpaceCenter() or wep:GetPos()
    local blastRadius = wep.ExplosionRadius or 140
    local blastDamage = wep.ExplosionDamage or 85
    local fireRadius = wep.ExplosionFireOutRadius or 220

    if wep.StopLoopingSound and wep.sound then
        wep:StopLoopingSound(wep.sound)
    end

    if IsValid(wep.particleeffect) then
        wep.particleeffect:StopEmission()
    end

    if wep.SetBlocking then
        wep:SetBlocking(false)
    end

    sound.Play("rem_extinguisherexp.mp3", explodePos, 95, math.random(115, 125), 0.8)
    sound.Play("physics/metal/metal_barrel_impact_hard5.wav", explodePos, 85, math.random(85, 95), 0.9)
    util.ScreenShake(explodePos, 18, 80, 0.6, 360)
    SendExtinguisherExplosionFx(explodePos)
    ExtinguishNearbyFires(explodePos, fireRadius)
    hg.BlastDamageWithShockwave(wep, IsValid(attacker) and attacker or IsValid(owner) and owner or wep, explodePos, blastRadius, blastDamage, {
        Force = 12000,
        RagdollThreshold = 1.1
    })

    if IsValid(wep) then
        wep:Remove()
    end
end

local function GetExtinguisherDefender(target)
    local defender = hg.RagdollOwner(target) or target

    if IsValid(defender) and defender:IsPlayer() then return defender end

    for _, ply in player.Iterator() do
        if IsValid(ply) and ply:Alive() and (ply.FakeRagdoll == target or hg.GetCurrentCharacter(ply) == target) then
            return ply
        end
    end
end

local function CanBlockBulletWithExtinguisher(wep, defender, hitEnt, dmginfo)
    if not IsValid(wep) or not IsValid(defender) or not wep.GetBlocking or not wep:GetBlocking() then return false end

    local hitPos = GetExtinguisherImpactPos(hitEnt, dmginfo)
    local attackPos = GetExtinguisherAttackPos(hitEnt, dmginfo, hitPos)
    local eyePos, aimVec = hg.eye(defender)

    if not eyePos or not aimVec then return false end

    local toAttacker = attackPos - eyePos

    if toAttacker:LengthSqr() <= 0.001 then return false end

    toAttacker:Normalize()

    if aimVec:GetNormalized():Dot(toAttacker) < (wep.BulletBlockFrontDot or 0.12) then
        return false
    end

    local trace = {
        HitPos = hitPos,
        HitNormal = (hitPos - attackPos):GetNormalized(),
        Entity = hitEnt,
        HGPreventHeadRagdoll = true,
    }

    if util.DistanceToLine(eyePos + aimVec * 100, eyePos, hitPos) > (wep.BulletBlockTraceDist or 32) then
        return false
    end

    return true, trace, hitPos
end

local function TryExtinguisherBulletBlock(target, dmginfo)
    local defender = GetExtinguisherDefender(target)

    if not IsValid(defender) or not defender:IsPlayer() or not dmginfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) then return false end

    local wep = defender:GetActiveWeapon()

    if not IsValid(wep) or wep:GetClass() ~= EXTINGUISHER_CLASS then return false end

    local blocked, trace, hitPos = CanBlockBulletWithExtinguisher(wep, defender, target, dmginfo)

    if not blocked then return false end

    dmginfo:SetDamage(0)
    dmginfo:SetDamageForce(vector_origin)

    wep:PlayBlockImpactEffect(trace, wep, "block")

    if wep.SetLastBlocked then
        wep:SetLastBlocked(CurTime())
    end

    if math.Rand(0, 1) <= (wep.BulletBlockExplodeChance or 0.5) then
        ExplodeExtinguisher(wep, dmginfo:GetAttacker(), hitPos)
    end

    return true
end

if SERVER then
    hg.TryExtinguisherBulletBlock = TryExtinguisherBulletBlock

    hook.Add("EntityTakeDamage", "hg_extinguisher_damage_logic", function(target, dmginfo)
        if not IsValid(target) or not dmginfo or (dmginfo.GetDamage and dmginfo:GetDamage() <= 0) then return end

        if TryExtinguisherBulletBlock(target, dmginfo) then
            return true
        end

        if target:GetClass() ~= EXTINGUISHER_CLASS or IsValid(target:GetOwner()) or target.ExtinguisherExploded then return end
        if not (dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_BLAST) or dmginfo:IsDamageType(DMG_BURN) or dmginfo:IsDamageType(DMG_DIRECT)) then return end

        if math.Rand(0, 1) <= (target.DroppedExplodeChance or 0.5) then
            ExplodeExtinguisher(target, dmginfo:GetAttacker(), GetExtinguisherImpactPos(target, dmginfo))
        end
    end)
elseif CLIENT then
    net.Receive("hg_extinguisher_explode_fx", function()
        local pos = net.ReadVector()
        local emitter = ParticleEmitter(pos)

        if not emitter then return end

        for i = 1, 28 do
            local smoke = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 6)

            if smoke then
                local dir = (VectorRand() + vector_up * math.Rand(0.45, 0.95)):GetNormalized()
                smoke:SetVelocity(dir * math.Rand(90, 220) + VectorRand() * 55)
                smoke:SetDieTime(math.Rand(1.6, 2.7))
                smoke:SetStartAlpha(math.random(220, 245))
                smoke:SetEndAlpha(0)
                smoke:SetStartSize(math.Rand(14, 26))
                smoke:SetEndSize(math.Rand(60, 110))
                smoke:SetRoll(math.Rand(0, 360))
                smoke:SetRollDelta(math.Rand(-1.2, 1.2))
                smoke:SetAirResistance(150)
                smoke:SetGravity(VectorRand() * 20 + Vector(0, 0, math.Rand(45, 110)))
                smoke:SetColor(240, 240, 240)
                smoke:SetCollide(true)
                smoke:SetBounce(0.05)
            end
        end

        for i = 1, 14 do
            local puff = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), pos + VectorRand() * 10)

            if puff then
                puff:SetVelocity(VectorRand() * math.Rand(70, 170) + Vector(0, 0, math.Rand(25, 90)))
                puff:SetDieTime(math.Rand(0.65, 1.15))
                puff:SetStartAlpha(math.random(180, 220))
                puff:SetEndAlpha(0)
                puff:SetStartSize(math.Rand(8, 14))
                puff:SetEndSize(math.Rand(28, 46))
                puff:SetRoll(math.Rand(0, 360))
                puff:SetRollDelta(math.Rand(-1.8, 1.8))
                puff:SetAirResistance(120)
                puff:SetGravity(Vector(0, 0, math.Rand(40, 90)))
                puff:SetColor(255, 255, 255)
            end
        end

        emitter:Finish()
    end)
end

function SWEP:Reload()
    if SERVER then
        local owner = self:GetOwner()
        if IsValid(owner) and owner:KeyPressed(IN_RELOAD) then
            local sprayMode = not self:GetNetVar("extinguishermode")
            self:SetNetVar("extinguishermode", sprayMode)
            --self:GetOwner():ChatPrint("Changed extinguishermode to "..(self:GetNetVar("extinguishermode") and "spray." or "attack."))
            self:PlayAnim(sprayMode and "equip" or "unequip", 1, false, nil, false, true)
        end--anim,time,cycling,callback,reverse,sendtoclient
    end
end

hook.Add("OnNetVarSet", "AsdGuilt",function(index, key, var)
    if key == "extinguishermode" then
        local self = Entity(index)
        if not IsValid(self) or not self.AnimList then return end
        self.AnimList["deploy"] = var and "HoseEquip" or "Draw"
        if CLIENT and self:GetOwner() == LocalPlayer() then
            self:PlayAnim(var and "equip" or "unequip", 1, false, nil, false)
        end
    end
end)

function SWEP:ModelAnimAdd(model, pos, ang)
    self.CustomLerpMode = LerpFT(0.1,self.CustomLerpMode or 0, self:GetNetVar("extinguishermode") and 1 or 0)
    pos = pos + ((ang:Up() * -11 + ang:Forward() * -5 + ang:Right() * 3) * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Forward(), -5 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Up(), 3 * self.CustomLerpMode)
    ang:RotateAroundAxis(ang:Right(), 10 * self.CustomLerpMode)

    return pos, ang
end

function SWEP:CanSecondaryAttack()
    self.DamageType = DMG_CLUB
    self.AttackHit = "Canister.ImpactHard"
    self.Attack2Hit = "Canister.ImpactHard"
    if not self.allowsec then return end
    
    if self:GetNWFloat("amountspray", 100) <= 0 then return end
    
    if CLIENT then
        self:PlayAnim("attack2",1,false,nil,false)
        self.animtime = CurTime() + CurTime() % 1

        if not IsValid(self.particleeffect) then
            local att = self:GetAttachment(1)
            local tr = hg.eyeTrace(self:GetOwner())
            self.particleeffect = CreateParticleSystem(self:GetWM(), "NMRIH_EXTINGUISHER", PATTACH_POINT_FOLLOW, 1)
            self.particleeffect:StartEmission()
        else
            if self.particleeffect:IsFinished() then
                self.particleeffect:StartEmission()
            end
        end

        if (self.waitDecal or 0) < CurTime() then
            self.waitDecal = CurTime() + 0.02
            local tr = hg.eyeTrace(self:GetOwner(), 256)
            
            if tr.Hit then
                local norm = tr.HitNormal
                local add = 70 * tr.Fraction * tr.Fraction
                local pos = tr.HitPos + norm:Angle():Right() * math.Rand(-add,add) + norm:Angle():Up() * math.Rand(-add,add)

                util.Decal("Splash.Large", pos + norm, pos - norm)
            end

            if self:GetOwner() != GetViewEntity() then
                local view = render.GetViewSetup(true)

                local dot = view.angles:Forward():Dot(tr.Normal)
                
                local pos = tr.StartPos:ToScreen()
                
                if dot < -0.99 and pos.x > 0 and pos.x < ScrW() and pos.y > 0 and pos.y < ScrH() and hg.isVisible(LocalPlayer():EyePos(), tr.StartPos, {LocalPlayer(), self}, MASK_VISIBLE) then
                    //amtflashed2 = amtflashed2 + (FrameTime() * 2)
                end//покачто
            end
        end

        self.sound = self:StartLoopingSound("fire_extinguisher/fire_extinguisger_startloop.wav")
        
        timer.Create("extinguisher"..self:EntIndex(), 0.1, 1, function()
            if IsValid(self) then
                if self.sound then
                    self:StopLoopingSound(self.sound)
                end

                if IsValid(self.particleeffect) then
                    self.particleeffect:StopEmission()
                end
            end
        end)
    else
        if (self.lasttimeused or 0) > CurTime() then return false end
        local now = CurTime()
        local owner = self:GetOwner()
        if not IsValid(owner) or owner:GetActiveWeapon() ~= self then return false end

        local tickInterval = self.SprayTickInterval or 0.05
        local elapsed = now - (self.lastSprayTime or now)
        local sprayInterrupted = elapsed > (self.SprayContactGrace or 0.15)
        local dt = sprayInterrupted and tickInterval or math.min(elapsed, tickInterval * 2)
        self.lasttimeused = now + tickInterval
        self.lastSprayTime = now

        local tr = GetExtinguisherSprayTrace(owner, self.SprayRange or 256, self.SprayHullSize or 14)
        if not tr then return false end
        self.sprayamt = self.sprayamt or 100
        self.sprayamt = math.max(0, self.sprayamt - (self.SprayDrainPerSecond or 7) * dt)
        self:SetNWFloat("amountspray", self.sprayamt)

        local selfRagdoll = hg.GetCurrentCharacter and hg.GetCurrentCharacter(owner)
        if IsValid(selfRagdoll) and selfRagdoll ~= owner then
            self.SpraySelfExposure = sprayInterrupted and dt or (self.SpraySelfExposure or 0) + dt
            local backward = GetSprayDirection(owner, true)
            if backward then
                local forceScale = GetSprayForceScale(self.SpraySelfExposure, self.SprayForceRampTime)
                ApplySprayForce(selfRagdoll, backward, (self.SpraySelfForce or 3625) * forceScale, self.SpraySelfMaxSpeed or 290, dt)
            end
        else
            self.SpraySelfExposure = sprayInterrupted and dt or (self.SpraySelfExposure or 0) + dt
            local backward = GetHorizontalSprayDirection(owner, true)
            if backward then
                local forceScale = GetSprayForceScale(self.SpraySelfExposure, self.SprayForceRampTime)
                PushStandingPlayer(owner, backward, (self.SpraySelfStandingPush or 15) * forceScale, 90, dt)
            end

            if not self.SpraySelfRagdollRolled and self.SpraySelfExposure >= (self.SpraySelfRagdollDelay or 0.35) then
                self.SpraySelfRagdollRolled = true
                if math.Rand(0, 1) < (self.SpraySelfRagdollChance or 0.6) then
                    hg.LightStunPlayer(owner, self.SpraySelfLightStunTime or 0.75)
                    self.SpraySelfExposure = 0
                end
            end
        end
        if sprayInterrupted then
            self.SpraySelfRagdollRolled = nil
        end

        self.SprayContacts = self.SprayContacts or {}
        self.SprayKnockdownCooldowns = self.SprayKnockdownCooldowns or {}
        local target = GetSprayPlayer(tr.Entity)
        if target == owner or not IsValid(target) or not target:Alive() then target = nil end

        for ply, contact in pairs(self.SprayContacts) do
            if not IsValid(ply) or not ply:Alive() or ply ~= target and now - contact.lastHit > (self.SprayContactGrace or 0.15) then
                self.SprayContacts[ply] = nil
            end
        end
        for ply, cooldown in pairs(self.SprayKnockdownCooldowns) do
            if not IsValid(ply) or cooldown <= now then self.SprayKnockdownCooldowns[ply] = nil end
        end

        if target then
            self.SprayPropContact = nil
            local contact = self.SprayContacts[target] or {exposure = 0}
            if contact.lastHit and now - contact.lastHit > (self.SprayContactGrace or 0.15) then
                contact.exposure = 0
                contact.knocked = nil
            end
            contact.exposure = contact.exposure + dt
            contact.lastHit = now
            self.SprayContacts[target] = contact

            local direction = GetSprayDirection(owner)
            local ragdoll = hg.GetCurrentCharacter and hg.GetCurrentCharacter(target)
            local targetIsFake = IsValid(ragdoll) and ragdoll ~= target
            if targetIsFake then
                contact.wasFake = true
            elseif contact.wasFake then
                contact.exposure = dt
                contact.knocked = nil
                contact.wasFake = nil
            end
            local forceScale = GetSprayForceScale(contact.exposure, self.SprayForceRampTime)
            if direction and targetIsFake then
                ApplySprayForce(ragdoll, direction, (self.SprayRagdollForce or 2500) * forceScale, self.SprayRagdollMaxSpeed or 275, dt)
            elseif direction then
                PushStandingPlayer(target, direction, (self.SprayStandingPush or 41) * forceScale, self.SprayStandingMaxSpeed or 220, dt)
            end

            if contact.exposure >= (self.SprayKnockdownTime or 2) and not IsValid(target.FakeRagdoll) and now >= (self.SprayKnockdownCooldowns[target] or 0) then
                contact.knocked = true
                self.SprayKnockdownCooldowns[target] = now + (self.SprayKnockdownCooldown or 6)
                hg.LightStunPlayer(target, self.SprayLightStunTime or 1.25)

                ragdoll = hg.GetCurrentCharacter and hg.GetCurrentCharacter(target)
                if direction and IsValid(ragdoll) and ragdoll ~= target then
                    ApplySprayForce(ragdoll, direction, self.SprayKnockdownForce or 5500)
                end
            end
        elseif IsValid(tr.Entity) and tr.Entity:GetMoveType() == MOVETYPE_VPHYSICS then
            local direction = GetSprayDirection(owner)
            if direction then
                local propContact = self.SprayPropContact
                if not propContact or propContact.entity ~= tr.Entity or now - propContact.lastHit > (self.SprayContactGrace or 0.15) then
                    propContact = {entity = tr.Entity, exposure = dt}
                else
                    propContact.exposure = propContact.exposure + dt
                end
                propContact.lastHit = now
                self.SprayPropContact = propContact

                local forceScale = GetSprayForceScale(propContact.exposure, self.SprayForceRampTime)
                PushPhysicalEntity(tr.Entity, direction, (self.SprayPropForce or 10250) * forceScale, self.SprayPropMaxSpeed or 320, tr.HitPos, dt)
            end
        else
            self.SprayPropContact = nil
        end

        local sprayedPlayers = {}
        for k, ent in ipairs(ents.FindInSphere(tr.HitPos,32)) do
            local sprayedPlayer = GetSprayPlayer(ent)
            if IsValid(sprayedPlayer) and sprayedPlayer:Alive() and sprayedPlayer != owner and not sprayedPlayers[sprayedPlayer] then
                sprayedPlayers[sprayedPlayer] = true
                local org = sprayedPlayer.organism
                if org and org.o2 and not org.holdingbreath then
                    org.o2[1] = math.max(0, (org.o2[1] or 0) - 0.5 * (dt / 0.25))
                    org.is_sprayed_at = true
                    if not org.otrub and math.Rand(0, 1) < 1.25 * dt then
                        sprayedPlayer:Notify("", 5, "coughing", nil, function() hg.organism.module.random_events.TriggerRandomEvent(sprayedPlayer,"Cough") end, color_white)
                    end
                end
            end

            if ent:GetClass() == "vfire" then
                ent.life = (ent.life or 0 ) - 40 * (dt / 0.25)
                if ent.life < 2 then
                    ent:Remove()
                end
            end
        end
    end

    return false
end

function SWEP:CanPrimaryAttack()
    if IsValid(self:GetOwner()) and hg.KeyDown(self:GetOwner(), IN_RELOAD) then return end
    if not self:GetNetVar("extinguishermode") then
        return true
    else
        self.allowsec = true
        self:SecondaryAttack(true)
        self.allowsec = nil
        return false
    end
end

function SWEP:CustomBlockAnim(addPosLerp, addAngLerp)
    addPosLerp.z = addPosLerp.z + (self:GetBlocking() and -5 or 0)
    addPosLerp.x = addPosLerp.x + (self:GetBlocking() and 0 or 0)
    addPosLerp.y = addPosLerp.y + (self:GetBlocking() and -5 or 0)
    addAngLerp.y = addAngLerp.y + (self:GetBlocking() and 30 or 0)
    addAngLerp.r = addAngLerp.r + (self:GetBlocking() and -60 or 0)

    return true
end

SWEP.NoHolster = true
SWEP.MinSensivity = 0.75
