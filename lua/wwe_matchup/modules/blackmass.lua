-- blackmass
local CFG = {
    ANIM_ATTACKER = "blackmass_zero",
    ANIM_TARGET   = "blackmass_one",
    COOLDOWN      = 5,
}

WWE.RegisterMove("blackmass", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsStanding,
    Execute = function(ply, target)
        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[WWE] Blackmass animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        local originPos = ply:GetPos()
        local originAng = Angle(0, ply:EyeAngles().yaw+180, 0)
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)
        
        local ragA = WWE.RagdollDown(ply,    ply:GetModel(), CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, { pos = originPos, angles = originAng })
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
        timer.Simple(dur-2, function()
            if target.organism ~= nil then
            target.organism.pneumothorax = 1
            end
        end)
        timer.Simple(dur, function() WWE.StandUp(ply) end)
        timer.Simple(math.max(0.2, dur - 0.3), function() WWE.ApplyMoveDamage(target, ply, 50) end)

        
    end,
})
