-- chokeslam against a wall
local CFG = {
    ANIM_ATTACKER = "fencechokeslam_zero",
    ANIM_TARGET   = "fencechokeslam_one",
    COOLDOWN      = 5,
}

WWE.RegisterMove("fencechokeslam", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[WWE] fchokeslam animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        local originPos = ply:GetPos()
        local originAng = Angle(0, ply:EyeAngles().yaw+180, 0)
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)
        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, { pos = originPos, angles = originAng })
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
        ragT.WWE_FakeVel = Vector(0, 0, 351)
        timer.Simple(2.67, function()
            WWE.StandUp(ply)
            
        end)
        timer.Simple(2.15, function()
            local anmT = IsValid(ragT) and ragT.AnimModule
            if IsValid(anmT) then anmT:Remove() end
        end)
        timer.Simple(dur+1, function()
            if not WWE.OverVoid(target) then
                ragT.WWE_FakeVel = Vector(0, 0, 0) return
            end
        end)
        timer.Simple(math.max(0.2, dur - 0.3), function() WWE.ApplyMoveDamage(target, ply, 55) end)
        timer.Simple(15, function() ragT.WWE_FakeVel = Vector(0, 0, 0) end)

    end,
})
