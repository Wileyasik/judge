-- giantswing
local CFG = {
    ANIM_ATTACKER = "giantswing_zero",
    ANIM_TARGET   = "giantswing_one",
    COOLDOWN      = 5,
}

WWE.RegisterMove("giantswing", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[WWE] giantswing animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        local originPos = ply:GetPos()
        local originAng = Angle(0, ply:EyeAngles().yaw+180, 0)
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)

        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, { pos = originPos, angles = originAng })
        timer.Simple(math.max(0.2, dur - 0.3), function() WWE.ApplyMoveDamage(target, ply, 45) end)
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
        timer.Simple(dur-0.5, function()
            WWE.StandUp(ply)
            local fwd = originAng:Forward()
            fwd.z = 0
            fwd:Normalize()
            ragT.WWE_FakeVel = Vector(0, 0, 480) + fwd * 420
        end)
        timer.Simple(dur-0.7, function()
            local anmT = IsValid(ragT) and ragT.AnimModule
            if IsValid(anmT) then anmT:Remove() end
        end)
        timer.Simple(dur+1, function()
            if not WWE.OverVoid(target) then
                ragT.WWE_FakeVel = Vector(0, 0, 0)
                return
            end
        end)
        timer.Simple(25, function() ragT.WWE_FakeVel = Vector(0, 0, 0) end)
    end,
})
