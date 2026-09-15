AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local SHADOW = {
    secondstoarrive  = 0.012,
    maxangular       = 1800,
    maxangulardamp   = 600,
    maxspeed         = 1000,
    maxspeeddamp     = 400,
    dampfactor       = 0.8,
    teleportdistance = 0,
}

-- Дистанция в юнитах которая считается землёй
local FALL_DROP  = 24

local FALL_GRACE = 0.15

function ENT:Initialize()
    self:SetModel("models/error.mdl")
    self:SetNoDraw(true)
    self:DrawShadow(false)
    self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    self.Delta    = CurTime()
    self.CycleEnd = 1
    self.PreviousBonePos = {}
    self.BoneVelocity = {}
end

function ENT:Setup(rag, model, seq, opts)
    opts = opts or {}
    if not IsValid(rag) then self:Remove() return end

    self.Ragdoll  = rag
    self.CycleEnd = opts.cycleEnd or 1
    self.FinishFunc = opts.onFinish

    if model then self:SetModel(model) end

    local basePos = opts.pos or rag:GetPos()
    if opts.PickupFrom then
        self.PickupFrom      = opts.PickupFrom
        self.PickupFromAngles = opts.PickupFromAngles or rag:GetAngles()
        self.PickupToAngles  = opts.angles or rag:GetAngles()
        self.PickupTarget    = basePos
        self.PickupStart     = CurTime()
        self.PickupTime      = opts.PickupTime or 0.18
        basePos = opts.PickupFrom
    end
    self:SetPos(basePos)
    self:SetAngles(opts.angles or rag:GetAngles())
    self.GroundZ = self:GetPos().z   -- начальная высота

    self:ResetSequence(self:LookupSequence(seq))
    self:SetCycle(0)
    if opts.SkipTime then
        local seqDur = self:SequenceDuration()
        if seqDur and seqDur > 0 then
            self:SetCycle(math.min(1, opts.SkipTime / seqDur))
        end
    end
    self:SetPlaybackRate(opts.rate or 1)

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
        end
    end
end

function ENT:DriveRagdoll(rag, dt)
    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(i)
        if not IsValid(phys) then continue end

        local bone = self:LookupBone(rag:GetBoneName(rag:TranslatePhysBoneToBone(i)))
        if not bone then continue end

        local pos, ang = self:GetBonePosition(bone)
        if not pos then continue end

        local tr = util.TraceLine({
            start  = phys:GetPos(),
            endpos = pos,
            filter = { self, rag },
            mask   = MASK_SOLID,
        })
        -- Clamp against walls instead of dropping this bone's update completely.
        -- Feet may still follow poses touching the floor.
        if tr.Hit and tr.HitNormal.z < 0.5 then
            pos = tr.HitPos + tr.HitNormal * 2
        end

        local previous = self.PreviousBonePos[i]
        if previous then self.BoneVelocity[i] = (pos - previous) / math.max(dt, 0.001) end
        self.PreviousBonePos[i] = pos

        phys:Wake()
        phys:ComputeShadowControl({
            secondstoarrive  = SHADOW.secondstoarrive,
            pos              = pos,
            angle            = ang,
            maxangular       = SHADOW.maxangular,
            maxangulardamp   = SHADOW.maxangulardamp,
            maxspeed         = SHADOW.maxspeed,
            maxspeeddamp     = SHADOW.maxspeeddamp,
            dampfactor       = SHADOW.dampfactor,
            teleportdistance = SHADOW.teleportdistance,
            deltatime        = dt,
        })
    end
end

function ENT:OnRemove()
    local rag = self.Ragdoll
    if not IsValid(rag) then return end

    for i = 0, rag:GetPhysicsObjectCount() - 1 do
        local phys = rag:GetPhysicsObjectNum(i)
        if IsValid(phys) then
            phys:EnableMotion(true)
            phys:Wake()
            if self.BoneVelocity and self.BoneVelocity[i] then
                phys:SetVelocity(self.BoneVelocity[i])
            end
        end
    end
end

function ENT:OverVoid()
    local bone = self:LookupBone("ValveBiped.Bip01_Pelvis") or 0
    local bp   = self:GetBonePosition(bone)
    if not bp then return false end

    local tr = util.TraceLine({
        start  = Vector(bp.x, bp.y, self.GroundZ + 24),
        endpos = Vector(bp.x, bp.y, self.GroundZ - FALL_DROP),
        mask   = MASK_SOLID,
        filter = function(e)
            return not e:IsPlayer() and e:GetClass() ~= "prop_ragdoll"
        end,
    })
    return not tr.Hit
end

function ENT:Think()
    local rag = self.Ragdoll
    if not IsValid(rag) then self:Remove() return end

    if self:OverVoid() then
        self.VoidSince = self.VoidSince or CurTime()
        if CurTime() - self.VoidSince > FALL_GRACE then self:Remove() return end
    else
        self.VoidSince = nil
    end

    local dt = CurTime() - self.Delta

    -- плавный "подхват" с пола до точки захвата (ease-out)
    if self.PickupFrom then
        local f = math.min(1, (CurTime() - self.PickupStart) / self.PickupTime)
        local e = 1 - (1 - f) * (1 - f) -- easeOutCubic
        self:SetPos(self.PickupFrom + (self.PickupTarget - self.PickupFrom) * e)
        self:SetAngles(LerpAngle(e, self.PickupFromAngles, self.PickupToAngles))
        self.GroundZ = self:GetPos().z
        if f >= 1 then
            self:SetPos(self.PickupTarget)
            self:SetAngles(self.PickupToAngles)
            self.PickupFrom = nil
        end
    end

    self:DriveRagdoll(rag, dt)

    if self:GetCycle() >= self.CycleEnd then
        if isfunction(self.FinishFunc) then self.FinishFunc(self, rag) end
        self:Remove()
        return
    end

    self.Delta = CurTime()
    self:NextThink(CurTime())
    return true
end
