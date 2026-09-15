local function RegisterMA(id, key, sound, opts)
    opts = opts or {}
    local bodyDmg = opts.damage or 0
    local headDmg = opts.head or 0
    local headTime = opts.headtime or 0.4
    local SKIP = opts.skip or 0.3

    WWE.RegisterMove(id, {
        Cooldown = 8,
        Condition = WWE.IsStanding,
        Execute = function(ply, target)
            local toPly = (ply:GetPos() - target:GetPos()):GetNormalized()
            if target:GetForward():Dot(toPly) >= 0 then return false end

            local aSeq = "execution_" .. key .. "_attacker_stand"
            local vSeq = "execution_" .. key .. "_victim_stand"
			local aId, aDur = ply:LookupSequence(aSeq)
			local tId, tDur = target:LookupSequence(vSeq)
			if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
				ply:ChatPrint("[Martial Artist] " .. id .. " animation (" .. aSeq .. ") not found on this model.")
				return false
			end

            local dur = math.max(aDur, tDur)
            local effDur = math.max(0.1, dur - SKIP)

            local originPos = target:GetPos()
            local originAng = Angle(0, target:EyeAngles().yaw, 0)
            ply:SetPos(originPos)
            ply:SetEyeAngles(originAng + Angle(0, 180, 0))

            local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    aSeq, dur, { pos = originPos, angles = originAng, SkipTime = SKIP })
            local ragT = WWE.RagdollDown(target, target:GetModel(), vSeq, dur, { pos = originPos, angles = originAng, SkipTime = SKIP })
            if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end

            timer.Simple(SKIP + 0.1, function() if IsValid(ply) then ply:EmitSound(sound) end end)

            if bodyDmg > 0 then
                timer.Simple(math.max(0, effDur - 0.15), function()
                    if IsValid(target) and target:Alive() then WWE.ApplyMoveDamage(target, ply, bodyDmg) end
                end)
            end

            if headDmg > 0 then
                timer.Simple(math.max(0, effDur - 0.4), function()
                    if IsValid(target) and target:Alive() then
                        WWE.ApplyMoveDamage(target, ply, headDmg, DMG_CLUB)
                        if IsValid(ragT) then hg.BloodAt(ragT, "ValveBiped.Bip01_Head1") end
                    end
                end)
            end

            timer.Simple(effDur - 0.3, function() WWE.StandUp(ply) end)

            return true
        end,
    })
end

RegisterMA("mw_cagematch", "29", ")tdmg/takedown/execution_031_stand.ogg", { damage = 40, head = 15, headtime = 0.6 })
RegisterMA("mw_sweetdreams", "30", ")tdmg/takedown/execution_101_stand.ogg", { damage = 55 })

-- Giantswing: pulls a victim that is already lying on the floor (faked ragdoll)
-- off the ground and swings them away. Only usable when aiming at a downed body.
WWE.RegisterMove("mw_giantswing", {
    Cooldown = 8,
    Condition = WWE.IsStanding,
    AllowDowned = true,
    FindTarget = function(ply)
        local eyePos = ply:EyePos()
        local rad = Vector(18, 18, 18)
        local tr = util.TraceHull({
            start = eyePos,
            endpos = eyePos + ply:GetAimVector() * 100,
            filter = { ply, hg.GetCurrentCharacter(ply) },
            mins = -rad,
            maxs = rad,
            mask = MASK_SHOT,
        })
        local hit = tr.Entity
        if IsValid(hit) and hit:IsRagdoll() then
            local owner = hg.RagdollOwner(hit)
            if IsValid(owner) and owner:IsPlayer() and owner:Alive() then return owner end
        end
        return nil
    end,
    Execute = function(ply, target)
        local CFG = {
            ANIM_ATTACKER = "giantswing_zero",
            ANIM_TARGET   = "giantswing_one",
        }
        local aId, aDur = ply:LookupSequence(CFG.ANIM_ATTACKER)
        local tId, tDur = target:LookupSequence(CFG.ANIM_TARGET)
        if not aId or aId < 0 or aDur <= 0 or not tId or tId < 0 or tDur <= 0 then
            ply:ChatPrint("[Martial Artist] giantswing animations are not loaded on this model.")
            return false
        end

        local dur = math.max(aDur, tDur)

        -- skip the first 0.3s of the swing animation and shift events to match
        local skip = 0.3
        local dur2 = math.max(0.1, dur - skip)

        local originPos = ply:GetPos()
        local originAng = Angle(0, ply:EyeAngles().yaw + 180, 0)

        -- the victim is already down: smoothly lift the ragdoll off the floor to the grab point
        local pickFrom, pickAng
        if IsValid(target.FakeRagdoll) then
            pickFrom = target.FakeRagdoll:GetPos()
            pickAng  = target.FakeRagdoll:GetAngles()
        else
            pickFrom = originPos
            pickAng  = originAng
        end
        target:SetPos(originPos)
        target:SetEyeAngles(originAng)

        local ragA = WWE.RagdollDown(ply,    ply:GetModel(),    CFG.ANIM_ATTACKER, dur, { pos = originPos, angles = originAng, SkipTime = skip })
        local ragT = WWE.RagdollDown(target, target:GetModel(), CFG.ANIM_TARGET,   dur, {
            pos = originPos,
            angles = originAng,
            SkipTime = skip,
            PickupFrom = pickFrom,
            PickupFromAngles = pickAng,
            PickupTime = 0.22,
        })
        if IsValid(ragA) and IsValid(ragT) then constraint.NoCollide(ragA, ragT, 0, 0) end

		local hitBySwing = {}
		local sweepTimer = "WWE_GiantSwingSweep_" .. ply:EntIndex() .. "_" .. math.floor(CurTime() * 1000)
		timer.Create(sweepTimer, 0.12, math.max(1, math.ceil(dur2 / 0.12)), function()
			if not IsValid(ply) or not IsValid(ragA) then
				timer.Remove(sweepTimer)
				return
			end

			local center = ragA:WorldSpaceCenter()
			for _, nearby in ipairs(ents.FindInSphere(center, 105)) do
				if not IsValid(nearby) or not nearby:IsPlayer() or nearby == ply or nearby == target or not nearby:Alive() or hitBySwing[nearby] then continue end
				if IsValid(nearby.FakeRagdoll) or IsValid(nearby:GetNWEntity("FakeRagdoll")) then continue end

				local trace = util.TraceLine({
					start = center,
					endpos = nearby:WorldSpaceCenter(),
					filter = {ply, target, ragA, ragT},
					mask = MASK_SOLID_BRUSHONLY
				})
				if trace.Hit then continue end

				local victim = nearby
				local impactCenter = Vector(center)
				hitBySwing[victim] = true
				hg.LightStunPlayer(victim, 1.5)
				victim:EmitSound("physics/body/body_medium_impact_hard" .. math.random(1, 6) .. ".wav", 70, math.random(90, 110))

				timer.Simple(0, function()
					if not IsValid(victim) then return end
					local rag = hg.GetCurrentCharacter(victim)
					if not IsValid(rag) or rag == victim then return end

					local push = rag:WorldSpaceCenter() - impactCenter
					push.z = 0
					if push:LengthSqr() <= 1 then push = originAng:Right() end
					push:Normalize()
					rag.WWE_FakeVel = push * 260 + Vector(0, 0, 120)
				end)
			end
		end)

        timer.Simple(math.max(0.2, dur2 - 0.3), function()
            if IsValid(target) and target:Alive() then WWE.ApplyMoveDamage(target, ply, 55) end
        end)
        timer.Simple(math.max(0.1, dur2 - 0.5), function()
            WWE.StandUp(ply)
            if IsValid(ragT) then
                local fwd = originAng:Forward()
                fwd.z = 0
                fwd:Normalize()
                ragT.WWE_FakeVel = Vector(0, 0, 480) + fwd * 420
            end
        end)
        timer.Simple(math.max(0.1, dur2 - 1.3), function()
            local anmT = IsValid(ragT) and ragT.AnimModule
            if IsValid(anmT) then anmT:Remove() end
        end)
        timer.Simple(dur2 + 0.8, function()
            if not WWE.OverVoid(target) and IsValid(ragT) then
                ragT.WWE_FakeVel = Vector(0, 0, 0)
            end
        end)
        timer.Simple(15, function()
            if IsValid(ragT) then ragT.WWE_FakeVel = Vector(0, 0, 0) end
        end)

        return true
    end,
})

util.PrecacheSound(")tdmg/takedown/execution_031_stand.ogg")
util.PrecacheSound(")tdmg/takedown/execution_101_stand.ogg")
