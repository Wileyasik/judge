local CFG = {
    ANIM_ATTACKER = "execution_mw3_101_attacker_stand",
    ANIM_TARGET   = "execution_mw3_101_victim_stand",
    COOLDOWN      = 8,
    SOUND         = ")tdmg/takedown/execution_101_stand.ogg",
    SKIP          = 0.3,
    RATE          = 1.2,
}

WWE.RegisterMove("mw_necktrauma", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local toPly = (ply:GetPos() - target:GetPos()):GetNormalized()
        if target:GetForward():Dot(toPly) >= 0 then
            return false
        end

        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[Martial Artist] Neck Trauma animation not found on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)
        local effDur = math.max(0.1, dur - CFG.SKIP)

        -- anchor to the target so the victim is not dragged across the floor
        local originPos = target:GetPos()
        local originAng = Angle(0, target:EyeAngles().yaw, 0)
        ply:SetPos(originPos)
        ply:SetEyeAngles(originAng + Angle(0, 180, 0))

        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng, SkipTime = CFG.SKIP, rate = CFG.RATE })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, { pos = originPos, angles = originAng, SkipTime = CFG.SKIP, rate = CFG.RATE })
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end

        timer.Simple(CFG.SKIP + 0.1, function()
            if IsValid(ply) then ply:EmitSound(CFG.SOUND) end
        end)

        timer.Simple(CFG.SKIP + dur * 0.35, function() if IsValid(ragT) then hg.BloodAt(ragT, "ValveBiped.Bip01_Head1") end end)
        timer.Simple(CFG.SKIP + dur * 0.55, function() if IsValid(ragT) then hg.BloodAt(ragT, "ValveBiped.Bip01_Spine2") end end)
        timer.Simple(CFG.SKIP + dur * 0.75, function() if IsValid(ragT) then hg.BloodAt(ragT, "ValveBiped.Bip01_R_Calf") end end)

        timer.Simple(math.max(0, effDur - 0.15), function()
            if not IsValid(ragT) then return end
            hg.BloodAt(ragT, "ValveBiped.Bip01_Head1")
            WWE.ApplyMoveDamage(target, ply, 55)
        end)

        timer.Simple(math.max(0.1, effDur - 0.3), function() WWE.StandUp(ply) end)

        return true
    end,
})
