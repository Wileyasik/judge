local CFG = {
    ATTACKER_MODEL = "models/dyinglight/weapons/c_limbs_template.mdl",
    TARGET_MODEL   = "models/dyinglight/bsmodimations_zombie_template.mdl",
    SEQ            = "dyli_back",
    COOLDOWN       = 8,
    DURATION       = 0.8,
    SKIP           = 0.3,
    RATE           = 1.2,
}

WWE.RegisterMove("dl_back", {
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local toPly = (ply:GetPos() - target:GetPos()):GetNormalized()
        if target:GetForward():Dot(toPly) >= 0 then
            ply:ChatPrint("")
            return false
        end

        local seq = CFG.SEQ
        if not WWE.SeqExists(CFG.ATTACKER_MODEL, seq) or not WWE.SeqExists(CFG.TARGET_MODEL, seq) then
            ply:ChatPrint("")
            return false
        end
        local dur = CFG.DURATION
        local effDur = math.max(0.1, dur - CFG.SKIP)

        local pos = target:GetPos() - target:GetForward() * 32
        local ang = target:GetAngles()

        local ragA = WWE.RagdollDown(ply,    CFG.ATTACKER_MODEL, seq, dur, { pos = pos, angles = ang, SkipTime = CFG.SKIP, rate = CFG.RATE })
        local ragT = WWE.RagdollDown(target, CFG.TARGET_MODEL,   seq, dur, { pos = target:GetPos(), angles = target:GetAngles(), SkipTime = CFG.SKIP, rate = CFG.RATE })

        timer.Simple(math.max(0.1, effDur - 0.15), function()
            if IsValid(ragT) then
                hg.BreakNeck(ragT)
            end
        end)

        timer.Simple(math.max(0.1, effDur - 0.15), function() WWE.ApplyMoveDamage(target, ply, 40) end)
        timer.Simple(math.max(0.1, effDur - 0.3), function() WWE.StandUp(ply) end)
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
    end,
})
