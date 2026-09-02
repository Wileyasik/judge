local hg_euphoria_getup_stumble = CreateConVar("hg_euphoria_getup_stumble", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria stagger balance while getting up (ARTragdoll-style)", 0, 1)

local STUMBLE_UPRIGHT_Z = 0.4
local STUMBLE_HIP_HEIGHT = 55
local STUMBLE_SPRING_K = 30
local STUMBLE_LATERAL_K = 8
local STUMBLE_FOOT_SEP = 7
local STUMBLE_FOOT_TRIGGER = 15
local STUMBLE_FOOT_STEP_TIME = 0.32
local STUMBLE_STEP_HEIGHT = 9
local STUMBLE_PREDICT = 0.25
local STUMBLE_PREDICT_MAX = 45
local STUMBLE_FOOT_PULL = 600
local STUMBLE_STAGGER_PULL = 220

local FOOT_BONES = { [1] = 13, [2] = 14 }
local FOOT_SIDE = { [1] = 1, [2] = -1 }

hook.Add("Think", "HG_EuphoriaStumble", function()
	if not hg_euphoria_getup_stumble:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		ragdoll.hgStumbleActive = nil

		if not ragdoll.hgGetUp then continue end
		if not ply:Alive() then continue end

		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		if not IsValid(pelvis) or not IsValid(spine) then continue end

		local spineAng = spine:GetAngles()
		if type(spineAng) ~= "Angle" or spineAng.Up().z < STUMBLE_UPRIGHT_Z then continue end
		local upZ = spineAng.Up().z
		local balanceMul = math.Clamp((upZ - STUMBLE_UPRIGHT_Z) / 0.4, 0, 1)

		ragdoll.hgStumbleActive = true

		local dtime = (now - (ragdoll.hgStumbleLast or now)) * game.GetTimeScale()
		ragdoll.hgStumbleLast = now
		if dtime <= 0 then continue end

		local pelvisPos = pelvis:GetPos()
		local pelvisAng = pelvis:GetAngles()
		if type(pelvisAng) ~= "Angle" then continue end
		local pelvisVel = pelvis:GetVelocity()

		local groundTr = util.TraceLine({
			start = Vector(pelvisPos.x, pelvisPos.y, pelvisPos.z + 10),
			endpos = Vector(pelvisPos.x, pelvisPos.y, pelvisPos.z - 160),
			filter = {ply, ragdoll},
			mask = MASK_SOLID_BRUSHONLY,
		})

		if not groundTr.Hit or groundTr.HitSky then continue end
		local groundZ = groundTr.HitPos.z

		local horizVel = Vector(pelvisVel.x, pelvisVel.y, 0)
		if horizVel:Length() > STUMBLE_PREDICT_MAX then
			horizVel = horizVel:GetNormalized() * STUMBLE_PREDICT_MAX
		end

		ragdoll.hgStumbleFeet = ragdoll.hgStumbleFeet or { {}, {} }

		local feetSum = Vector(0, 0, 0)
		local feetValid = 0

		for k = 1, 2 do
			local footPhys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, FOOT_BONES[k]))
			if not IsValid(footPhys) then continue end

			local plant = LocalToWorld(Vector(FOOT_SIDE[k] * STUMBLE_FOOT_SEP, 0, 0), Angle(0, 0, 0), pelvisPos, pelvisAng)

			local ft = util.TraceLine({
				start = Vector(plant.x, plant.y, pelvisPos.z + 10),
				endpos = Vector(plant.x, plant.y, pelvisPos.z - 160),
				filter = {ply, ragdoll},
				mask = MASK_SOLID_BRUSHONLY,
			})

			local ghost
			if ft.Hit and not ft.HitSky then
				ghost = ft.HitPos + horizVel * STUMBLE_PREDICT
			else
				ghost = Vector(plant.x, plant.y, groundZ)
			end

			local data = ragdoll.hgStumbleFeet[k]
			local footPos = footPhys:GetPos()

			if not data.stepping then
				data.target = ghost
				if footPos:DistToSqr(ghost) > STUMBLE_FOOT_TRIGGER * STUMBLE_FOOT_TRIGGER and
					not ragdoll.hgStumbleFeet[(k == 1) and 2 or 1].stepping and
					(now - (data.lastStep or 0)) > STUMBLE_FOOT_STEP_TIME * 2 then
					data.stepping = true
					data.start = footPos
					data.t = 0
				end
			else
				data.target = ghost
				data.t = data.t + dtime / STUMBLE_FOOT_STEP_TIME
				if data.t >= 1 then
					data.stepping = false
					data.lastStep = now
					footPos = data.target
				else
					local step = LerpVector(data.t, data.start, data.target)
					step.z = step.z + math.sin(data.t * math.pi) * STUMBLE_STEP_HEIGHT
					footPos = step
				end
			end

			local toTarget = footPos - footPhys:GetPos()
			local dist = toTarget:Length()
			if dist > 3 then
				footPhys:AddVelocity(toTarget / dist * STUMBLE_FOOT_PULL * dtime)
			end

			feetSum = feetSum + footPos
			feetValid = feetValid + 1
		end

		local targetZ = groundZ + STUMBLE_HIP_HEIGHT
		local diffZ = targetZ - pelvisPos.z
		local velErr = diffZ * STUMBLE_SPRING_K - pelvisVel.z
		spine:AddVelocity(Vector(0, 0, 1) * velErr * dtime * 0.5 * balanceMul)
		pelvis:AddVelocity(Vector(0, 0, 1) * velErr * dtime * balanceMul)

		if feetValid > 0 then
			local feetMid = feetSum / feetValid
			local lateral = pelvisPos - feetMid
			lateral.z = 0
			if lateral:Length() > 2 then
				pelvis:AddVelocity(lateral * -STUMBLE_LATERAL_K * dtime)
			end
		end

		local stagger = ragdoll.hgStagger
		if stagger and now < stagger.untilT then
			local frac = (stagger.untilT - now) / stagger.dur
			local lurch = stagger.dir * STUMBLE_STAGGER_PULL * frac * dtime
			pelvis:AddVelocity(lurch)
			spine:AddVelocity(lurch * 0.5)
		end
	end
end)