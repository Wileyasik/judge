local CFG = {
    ATTACKER_MODEL = "models/dyinglight/weapons/c_limbs_template.mdl",
    TARGET_MODEL   = "models/dyinglight/bsmodimations_zombie_template.mdl",
    COOLDOWN       = 8,
    RATE           = 1.2,
    SEQS = {
        dyli_front1 = {
            sound = { { 0.2, "dyli_sfx/dlkm_elbow1.wav" }, { 1.0, "dyli_sfx/dlkm_elbow2.wav" } },
            hitTime = 1.3,
        },
        dyli_front3 = {
            sound = { { 0.3, "dyli_sfx/dlkm_twist1.wav" }, { 1.5, "dyli_sfx/dlkm_twist2.wav" } },
            hitTime = 1.5,
        },
        dyli_front4 = {
            sound = { { 0.2, "dyli_sfx/dlkm_necksnap.wav" } },
            hitTime = 0.3,
        },
    },
}

WWE.RegisterMove("mw_dyli_front", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local toPly = (ply:GetPos() - target:GetPos()):GetNormalized()
        if target:GetForward():Dot(toPly) <= 0 then
            ply:ChatPrint(".")
            return false
        end

        local names = {}
        for k in pairs(CFG.SEQS) do names[#names + 1] = k end
        local seq = names[math.random(#names)]
        local seqCfg = CFG.SEQS[seq]

        if not WWE.SeqExists(CFG.ATTACKER_MODEL, seq) or not WWE.SeqExists(CFG.TARGET_MODEL, seq) then
            ply:ChatPrint("no anim")
            return false
        end

        local dur = math.max(WWE.SeqDuration(CFG.ATTACKER_MODEL, seq), WWE.SeqDuration(CFG.TARGET_MODEL, seq))
        if dur <= 0 then dur = 1.6 end
        local effDur = math.max(0.1, dur / CFG.RATE)


        local targetAng = target:GetAngles() + Angle(0, 180, 0)
        local pos = target:GetPos() - targetAng:Forward() * 32

        local ragA = WWE.RagdollDown(ply,    CFG.ATTACKER_MODEL, seq, dur, { pos = pos, angles = targetAng, rate = CFG.RATE })
        local ragT = WWE.RagdollDown(target, CFG.TARGET_MODEL,   seq, dur, { pos = target:GetPos(), angles = targetAng, rate = CFG.RATE })
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end

        for _, s in ipairs(seqCfg.sound) do
            timer.Simple(s[1] / CFG.RATE, function()
                if IsValid(ply) then ply:EmitSound(s[2]) end
            end)
        end

        timer.Simple(math.min(seqCfg.hitTime / CFG.RATE, effDur - 0.1), function()
            if IsValid(target) and target:Alive() then WWE.ApplyMoveDamage(target, ply, 55) end
            local rag = IsValid(target) and target.FakeRagdoll or nil
            if IsValid(rag) then hg.BloodAt(rag, "ValveBiped.Bip01_Head1") end
        end)

        timer.Simple(math.max(0.2, effDur - 0.2), function() WWE.StandUp(ply) end)

        return true
    end,
})

util.PrecacheSound("dyli_sfx/dlkm_necksnap.wav")
util.PrecacheSound("dyli_sfx/dlkm_elbow1.wav")
util.PrecacheSound("dyli_sfx/dlkm_elbow2.wav")
util.PrecacheSound("dyli_sfx/dlkm_knee1.wav")
util.PrecacheSound("dyli_sfx/dlkm_knee2.wav")
util.PrecacheSound("dyli_sfx/dlkm_knee3.wav")
util.PrecacheSound("dyli_sfx/dlkm_twist1.wav")
util.PrecacheSound("dyli_sfx/dlkm_twist2.wav")
util.PrecacheModel(CFG.ATTACKER_MODEL)
util.PrecacheModel(CFG.TARGET_MODEL)