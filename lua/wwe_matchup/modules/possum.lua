-- possum
local CFG = {
    ANIM_ATTACKER = "possum_zero",
    ANIM_TARGET   = "possum_one",
    COOLDOWN      = 5,
}

WWE.RegisterMove("possum", {
    Cooldown = CFG.COOLDOWN,
    Condition = WWE.IsGrounded,
    Execute = function(ply, target)

        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[WWE] Possum animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        local originPos = hg.GetCurrentCharacter(ply):GetPos() -- ply:GetPos()
        originPos.Z = originPos.Z - 5
        local originAng = Angle(0, ply:EyeAngles().yaw, 0)
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)

        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, { pos = originPos, angles = originAng })

        timer.Simple(3, function()
            if ragA:LookupBone("ValveBiped.Bip01_R_Finger01") then ragA:ManipulateBoneAngles(ragA:LookupBone("ValveBiped.Bip01_R_Finger01"), Angle(30, 90, 0)) end
            for i = 4, 1, -1 do
                if not ragA:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1") then continue end
                ragA:ManipulateBoneAngles(ragA:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, -90, 0))
            end
        end)

        timer.Simple(dur-3, function()
            WWE.StandUp(ply)
            if target.organism ~= nil then
                target.organism.disorientation = 2
        end end)

        timer.Simple(math.max(0.2, dur - 0.3), function() WWE.ApplyMoveDamage(target, ply, 40) end)
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end
    end,
})
