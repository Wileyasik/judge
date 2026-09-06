hook.Add("OnEntityCreated", "SniperShit", function(ent)
	timer.Simple(0, function()
		if not IsValid(ent) then return end
		if ent:GetClass() ~= "npc_sniper" then return end

		ent:SetKeyValue("misses", "0")
		ent:SetKeyValue("PaintInterval", "0.1")
		ent:SetKeyValue("PaintIntervalVariance", "0")

		local flags = 65536 + 1048576 + 2097152
		ent:SetKeyValue("spawnflags", tostring(flags))

		ent.LastSeenEnemy = nil
		ent.LastSeenPos = nil
		ent.LastSeenTime = 0
		ent.SuppressionShots = 0
		ent.NextSuppressionCheck = 0
		ent.WasVisible = false
	end)
end)

hook.Add("OnEntityCreated", "HelicopterGunshipInit", function(ent)
	timer.Simple(0.1, function()
		if not IsValid(ent) then return end

		local class = ent:GetClass()
		if class ~= "npc_helicopter" and class ~= "npc_combinegunship" then return end

		ent.IsCustomDamageSystem = true
	end)
end)

timer.Create("Dumalkasniper", 0.1, 0, function()
	local time = CurTime()
	for _, sniper in ipairs(ents.FindByClass("npc_sniper")) do
		if not IsValid(sniper) then continue end

		if (sniper.NextSuppressionCheck or 0) > time then continue end
		sniper.NextSuppressionCheck = time + 0.1

		local enemy = sniper:GetEnemy()

		if IsValid(enemy) then
			local tr = util.TraceLine({
				start = sniper:GetPos() + Vector(0, 0, 50),
				endpos = enemy:EyePos(),
				filter = {sniper, sniper.SuppressionTarget},
				mask = MASK_SHOT
			})

			local canSee = (tr.Entity == enemy or not tr.Hit)

			if canSee then
				sniper.LastSeenEnemy = enemy
				sniper.LastSeenPos = enemy:GetPos()
				sniper.LastSeenVel = enemy:GetVelocity()
				sniper.LastSeenTime = time
				sniper.WasVisible = true

				if IsValid(sniper.SuppressionTarget) then
					SafeRemoveEntity(sniper.SuppressionTarget)
					sniper.SuppressionTarget = nil
				end
			else
				if sniper.WasVisible and sniper.LastSeenEnemy == enemy then
					local timeSinceSeen = CurTime() - sniper.LastSeenTime

					if timeSinceSeen < 2 and sniper.SuppressionShots < 3 and not IsValid(sniper.SuppressionTarget) then
						local vel = sniper.LastSeenVel or Vector(0, 0, 0)
						local predictedPos = sniper.LastSeenPos + vel:GetNormalized() * 100

						local bullseye = ents.Create("npc_bullseye")
						if IsValid(bullseye) then
							bullseye:SetPos(predictedPos + Vector(0, 0, 50))
							bullseye:Spawn()
							bullseye:Activate()
							bullseye:SetHealth(999999)
							bullseye:SetKeyValue("spawnflags", "65536")

							sniper.SuppressionTarget = bullseye
							sniper.SuppressionShots = sniper.SuppressionShots + 1
							sniper.WasVisible = false

							timer.Simple(0.05, function()
								if IsValid(sniper) and IsValid(bullseye) then
									sniper:SetEnemy(bullseye)
								end
							end)

							timer.Simple(1.2, function()
								if IsValid(bullseye) then
									SafeRemoveEntity(bullseye)
								end
								if IsValid(sniper) then
									sniper.SuppressionTarget = nil
								end
							end)
						end
					elseif timeSinceSeen >= 3 then
						sniper.SuppressionShots = 0
						sniper.WasVisible = false
					end
				end
			end
		else
			sniper.SuppressionShots = 0
			sniper.LastSeenEnemy = nil
			sniper.WasVisible = false
			if IsValid(sniper.SuppressionTarget) then
				SafeRemoveEntity(sniper.SuppressionTarget)
				sniper.SuppressionTarget = nil
			end
		end
	end
end)

hook.Add("EntityTakeDamage", "HL2Shit", function(target, dmginfo)
	if not IsValid(target) then return end

	local class = target:GetClass()
	if class ~= "npc_helicopter" and class ~= "npc_combinegunship" and class ~= "npc_strider" then return end

	if not target.AccumulatedDamage then
		target.AccumulatedDamage = 0
		target.IsDying = false

		if class == "npc_helicopter" then
			target.DamageThreshold = 2000
		elseif class == "npc_combinegunship" then
			target.DamageThreshold = 2500
		elseif class == "npc_strider" then
			target.DamageThreshold = 3000
		end
	end

	if target.IsDying then return true end

	local damage = dmginfo:GetDamage()
	local dmgType = dmginfo:GetDamageType()
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()

	local function DestroyVehicle(reason)
		if target.IsDying then return end
		target.IsDying = true

		local pos = target:GetPos()

		local explosion = ents.Create("env_explosion")
		if IsValid(explosion) then
			explosion:SetPos(pos)
			explosion:SetKeyValue("iMagnitude", "200")
			explosion:SetKeyValue("spawnflags", "1")
			explosion:Spawn()
			explosion:Fire("Explode", "", 0)
		end
		hg.BlastDamageWithShockwave(target, IsValid(attacker) and attacker or target, pos, 200, 200)

		if class == "npc_helicopter" then
			target:SetHealth(0)
			target:Fire("SelfDestruct", "", 0)
			dmginfo:SetDamage(999999)

			timer.Simple(0.1, function()
				if IsValid(target) then
					for i = 1, 3 do
						local chunk = ents.Create("helicopter_chunk")
						if IsValid(chunk) then
							chunk:SetPos(pos + VectorRand() * 100)
							chunk:Spawn()
						end
					end
					target:Remove()
				end
			end)
		elseif class == "npc_strider" then
			target:SetHealth(0)
			target:Fire("Break", "", 0)
			dmginfo:SetDamage(999999)
		else
			target:SetHealth(0)
			target:Fire("SelfDestruct", "", 0)
			dmginfo:SetDamage(999999)
		end
	end

	if bit.band(dmgType, DMG_BLAST) == DMG_BLAST then
		DestroyVehicle("explosion")
		return true
	end

	if bit.band(dmgType, DMG_BULLET) == DMG_BULLET or
		bit.band(dmgType, DMG_ENERGYBEAM) == DMG_ENERGYBEAM or
		bit.band(dmgType, DMG_AIRBOAT) == DMG_AIRBOAT then

		target.AccumulatedDamage = target.AccumulatedDamage + damage
		if target.AccumulatedDamage >= target.DamageThreshold then
			DestroyVehicle("accumulated damage: " .. math.Round(target.AccumulatedDamage))
		end

		return false
	end
end)
