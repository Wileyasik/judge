-- tacklecounter
local CFG = {
    ANIM_ATTACKER = "tacklecounter_one",
    ANIM_TARGET   = "tacklecounter_zero",
    COOLDOWN      = 5,
}

WWE.RegisterMove("tacklecounter", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[WWE] Tacklecounter animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        local originPos = ply:GetPos()
        local originAng = Angle(0, ply:EyeAngles().yaw, 0)
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)

        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng })
        if IsValid(ragA) then ragA:SetNotSolid(true) end
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur-2, { pos = originPos - Vector(0, 0, 5), angles = originAng })
        ragT.WWE_FakeVel = Vector(351, 0, 0)
        timer.Simple(dur-3, function()
            WWE.StandUp(ply)
            ragT.WWE_FakeVel = Vector(0, 0, 0)
            end)

        timer.Simple(math.max(0.2, dur - 0.3), function() WWE.ApplyMoveDamage(target, ply, 55) end)
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
    end,
})
