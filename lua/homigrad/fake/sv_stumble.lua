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

local hg_euphoria_fall_stumble = CreateConVar("hg_euphoria_fall_stumble", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria stumble-on-fall while moving (RAGD-style)", 0, 1)

local FALL_STUMBLE_MIN_SPEED = 40
local FALL_STUMBLE_START_UPRIGHT = 45
local FALL_STUMBLE_END_UPRIGHT = 28
local FALL_STUMBLE_TIME = 2.2
local FALL_STUMBLE_DRIVE = 320
local FALL_STUMBLE_HIP_UP = 90
local FALL_STUMBLE_HIP_DOWN = 22
local FALL_STUMBLE_SPRING_K = 35
local FALL_STUMBLE_FOOT_PULL = 850
local FALL_STUMBLE_FOOT_FORWARD = 20
local FALL_STUMBLE_FOOT_SEP = 7
local FALL_STUMBLE_COOLDOWN = 3

hook.Add("Think", "HG_EuphoriaFallStumble", function()
	if not hg_euphoria_fall_stumble:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end
		if not ply:Alive() then continue end
		if ragdoll.hgGetUp or ragdoll.hgCurl or ragdoll.hgWallSmear or ragdoll.hgStumbleActive or
			ragdoll.isSliding or ragdoll.isDropkicking then continue end

		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		local head = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 10))
		if not IsValid(pelvis) or not IsValid(spine) or not IsValid(head) then continue end

		local pelvisPos = pelvis:GetPos()
		local pelvisVel = pelvis:GetVelocity()
		local headPos = head:GetPos()
		if not pelvisPos or not pelvisVel or not headPos then continue end
		local headDiff = math.abs(pelvisPos.z - headPos.z)

		if (now - (ragdoll.hgFallDbgLast or 0)) > 0.4 then
			ragdoll.hgFallDbgLast = now
			local hvel = Vector(pelvisVel.x, pelvisVel.y, 0)
			local activeNow = ragdoll.hgFallStumble ~= nil
			local skip = "none"
			if not activeNow then
				if ragdoll.hgControlled then skip = "controlled"
				elseif headDiff < FALL_STUMBLE_START_UPRIGHT then skip = string.format("headDiff %.0f", headDiff)
				elseif hvel:Length() < FALL_STUMBLE_MIN_SPEED then skip = string.format("speed %.0f", hvel:Length())
				elseif ragdoll.hgFallStumbleCooldown and now < ragdoll.hgFallStumbleCooldown then skip = "cooldown"
				end
			end
			local balanceNow = activeNow and (math.Clamp((ragdoll.hgFallStumble.untilT - now) / FALL_STUMBLE_TIME, 0, 1) * math.Clamp((headDiff - FALL_STUMBLE_END_UPRIGHT) / 30, 0, 1)) or 0
			print(string.format("[fallstumble] %s controlled=%s headDiff=%.0f hSpeed=%.0f active=%s skip=%s bal=%.2f", ply:Nick(), tostring(ragdoll.hgControlled), headDiff, hvel:Length(), tostring(activeNow), skip, balanceNow))
			ply:PrintMessage(HUD_PRINTTALK, string.format("[fallstumble] headDiff=%.0f hSpeed=%.0f active=%s skip=%s", headDiff, hvel:Length(), tostring(activeNow), skip))
		end

		local active = ragdoll.hgFallStumble

		if not active then
			if ragdoll.hgControlled then continue end
			if headDiff < FALL_STUMBLE_START_UPRIGHT then continue end
			local horizVel = Vector(pelvisVel.x, pelvisVel.y, 0)
			if horizVel:Length() < FALL_STUMBLE_MIN_SPEED then continue end
			if ragdoll.hgFallStumbleCooldown and now < ragdoll.hgFallStumbleCooldown then continue end

			active = { untilT = now + FALL_STUMBLE_TIME, last = now, dir = horizVel:GetNormalized() }
			ragdoll.hgFallStumble = active
			pelvis:AddVelocity(active.dir * 70 + Vector(0, 0, 80))
			ply:PrintMessage(HUD_PRINTTALK, "[euphoria] fall stumble start")
		end

		if now >= active.untilT or headDiff < FALL_STUMBLE_END_UPRIGHT or ragdoll.hgControlled then
			ragdoll.hgFallStumble = nil
			ragdoll.hgFallStumbleCooldown = now + FALL_STUMBLE_COOLDOWN
			continue
		end

		local dtime = (now - active.last) * game.GetTimeScale()
		active.last = now
		if dtime <= 0 then continue end

		local horizVel = Vector(pelvisVel.x, pelvisVel.y, 0)
		if horizVel:Length() > 40 then active.dir = horizVel:GetNormalized() end
		local dir = active.dir

		local fallFrac = math.Clamp((active.untilT - now) / FALL_STUMBLE_TIME, 0, 1)
		local uprightFrac = math.Clamp((headDiff - FALL_STUMBLE_END_UPRIGHT) / 30, 0, 1)
		local balance = fallFrac * uprightFrac
		if balance <= 0 then
			ragdoll.hgFallStumble = nil
			ragdoll.hgFallStumbleCooldown = now + FALL_STUMBLE_COOLDOWN
			continue
		end

		local drive = dir * FALL_STUMBLE_DRIVE * dtime * balance
		pelvis:AddVelocity(drive * 0.7)
		spine:AddVelocity(drive)

		local groundTr = util.TraceLine({
			start = Vector(pelvisPos.x, pelvisPos.y, pelvisPos.z + 10),
			endpos = Vector(pelvisPos.x, pelvisPos.y, pelvisPos.z - 170),
			filter = {ply, ragdoll},
			mask = MASK_SOLID_BRUSHONLY,
		})
		if not groundTr.Hit or groundTr.HitSky then
			ragdoll.hgFallStumble = nil
			ragdoll.hgFallStumbleCooldown = now + FALL_STUMBLE_COOLDOWN
			continue
		end
		local groundZ = groundTr.HitPos.z

		local hipZ = Lerp(balance, groundZ + FALL_STUMBLE_HIP_DOWN, groundZ + FALL_STUMBLE_HIP_UP)
		local velErr = (hipZ - pelvisPos.z) * FALL_STUMBLE_SPRING_K - pelvisVel.z
		pelvis:AddVelocity(Vector(0, 0, 1) * velErr * dtime * balance)
		spine:AddVelocity(Vector(0, 0, 1) * velErr * dtime * 0.5 * balance)

		local perp = Vector(-dir.y, dir.x, 0)
		local side = -1
		for k = 1, 2 do
			side = -side
			local footPhys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 12 + k))
			if not IsValid(footPhys) then continue end

			local plant = pelvisPos + dir * FALL_STUMBLE_FOOT_FORWARD + perp * (FALL_STUMBLE_FOOT_SEP * side)
			plant = Vector(plant.x, plant.y, groundZ)

			local footPos = footPhys:GetPos()
			if not footPos then continue end
			local toTarget = plant - footPos
			local dist = toTarget:Length()
			if dist > 4 then
				footPhys:AddVelocity(toTarget / dist * FALL_STUMBLE_FOOT_PULL * dtime)
			end
		end
	end
end)