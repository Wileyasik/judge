local ChangedTable = {}

function hg.IsChanged(val, id, meta)
	if (meta == nil) then
		meta = ChangedTable
	end

	if (meta.ChangedTable == nil) then
		meta["ChangedTable"] = {}
	end

	if (meta.ChangedTable[id] == val) then
		return false
	end

	meta.ChangedTable[id] = val
	return true
end

function ishgweapon(wep)
	if not wep or not IsValid(wep) then return false end
	return wep.ishgweapon
end

function hg.isVisible(pos1, pos2, filter, mask)
	return not util.TraceLine({
		start = pos1,
		endpos = pos2,
		filter = filter,
		mask = mask
	}).Hit
end

function hg.GetWorldSize()
	local world = game.GetWorld()
	local worldMin, worldMax = world:GetModelBounds()
	local size = worldMin:Distance(worldMax)
	return size
end

function hg.IsLocal(ent)
	if SERVER then return true end
	return lply:Alive() and (lply == ent) or (lply:GetNWEntity("spect") == ent)
end

local chairclasses = {
	["prop_vehicle_prisoner_pod"] = true,
}

function hg.isdriveablevehicle(veh)
	if not IsValid(veh) then return false end
	if chairclasses[veh:GetClass()] then return false end
	return true
end

function hg.ExplosionTrace(start, endpos, filter)
	return util.TraceLine({
		start = start,
		endpos = endpos,
		filter = filter,
		mask = MASK_SHOT
	})
end

hg.MaxLookX, hg.MinLookX = 55, -55
hg.MaxLookY, hg.MinLookY = 45, -45

function hg.AddForceRag(ent, physbone, force, time)
	if !IsValid(ent) then return end

	local ragdoll = nil

	if ent:IsPlayer() then
		local fakeRagdoll = ent.FakeRagdoll
		local deathRagdoll = ent:GetNWEntity("RagdollDeath")
		ragdoll = IsValid(fakeRagdoll) and fakeRagdoll or IsValid(deathRagdoll) and deathRagdoll or nil

		if not IsValid(ragdoll) then
			ent.AddForceRag = ent.AddForceRag or {}
			ent.AddForceRag[physbone] = ent.AddForceRag[physbone] or {}

			local restforce = math.max(((ent.AddForceRag[physbone][1] or CurTime()) - CurTime()), 0) / 0.25 * (ent.AddForceRag[physbone][2] or vector_origin)
			local resttime = (ent.AddForceRag[physbone][1] or CurTime())

			ent.AddForceRag[physbone][2] = restforce + force
			ent.AddForceRag[physbone][1] = CurTime() + 0.25

			return
		end
	elseif ent:IsRagdoll() then
		ragdoll = ent
	else
		return
	end

	local phys = ragdoll:GetPhysicsObjectNum(physbone)

	if IsValid(phys) then
		phys:ApplyForceCenter(force)
	end
end

function hg.IsOnGround(ent)
	local tr = {}
	tr.start = ent:GetPos()
	tr.endpos = ent:GetPos() - vector_up * 10
	tr.filter = ent
	tr.mask = MASK_PLAYERSOLID
	return util.TraceEntityHull(tr, ent).Hit
end
