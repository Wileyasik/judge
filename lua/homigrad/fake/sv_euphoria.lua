local hg_euphoria_tension = CreateConVar("hg_euphoria_tension", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria tension on fake ragdolls", 0, 1)
local hg_euphoria_flinch = CreateConVar("hg_euphoria_flinch", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria flinch on hit", 0, 1)
local hg_euphoria_slowmo = CreateConVar("hg_euphoria_slowmo", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria slow-mo on strong hit", 0, 1)
local hg_euphoria_stumble = CreateConVar("hg_euphoria_stumble", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria landing absorb and settle on fake ragdolls", 0, 1)
local hg_euphoria_detail = CreateConVar("hg_euphoria_detail", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "euphoria detail reactions (wound grab, wall grab, get-up)", 0, 1)

local EUPHORIA_TENSION_TIME = 0.6
local EUPHORIA_TENSION_ANG = 12
local EUPHORIA_TENSION_LIN = 3
local EUPHORIA_PROP_BASE = 100
local EUPHORIA_PROP_HEAD_WHIP = 0.9
local EUPHORIA_PROP_FALLOFF = 220
local EUPHORIA_PROP_MIN = 0.35
local EUPHORIA_PROP_SPINE_CURL = 55
local EUPHORIA_LANDING_MIN_SPEED = 180
local EUPHORIA_LANDING_MIN_HS = 110
local EUPHORIA_LANDING_ABSORB = 0.65
local EUPHORIA_LANDING_ABSORB_CONTROL = 0.35
local EUPHORIA_SETTLE_TIME = 1.1
local EUPHORIA_SETTLE_LIN = 3
local EUPHORIA_SETTLE_ANG = 1.8
local EUPHORIA_WOUND_GRAB_TIME = 1.4
local EUPHORIA_WOUND_GRAB_PULL = 700
local EUPHORIA_WOUND_GRAB_MIN_DMG = 12
local EUPHORIA_WALL_GRAB_SPEED = -170
local EUPHORIA_WALL_GRAB_DIST = 130
local EUPHORIA_WALL_GRAB_TIME = 0.9
local EUPHORIA_WALL_GRAB_PULL = 460
local EUPHORIA_WALL_GRAB_COOLDOWN = 1.2
local EUPHORIA_GETUP_TIME = 0.7
local EUPHORIA_GETUP_PUSH = 320
local EUPHORIA_GETUP_ROLL = 130
local EUPHORIA_GETUP_MIN_CONSCIOUSNESS = 0.35
local EUPHORIA_BERSERK_JERK = 160
local EUPHORIA_AMPUTEE_ANGLE = 15
local EUPHORIA_AMPUTEE_STIFFNESS = 4
local EUPHORIA_AMPUTEE_DAMP = 2.5
local EUPHORIA_WALL_MIN_SPEED = 200
local EUPHORIA_WALL_SMEAR_TIME = 0.9
local EUPHORIA_WALL_SMEAR_STICK = 8
local EUPHORIA_WALL_SLIDE_SPEED = 55
local EUPHORIA_WALL_STICK = 20
local EUPHORIA_SLOWMO_TIME = 0.32
local EUPHORIA_SLOWMO_SCALE = 0.45
local EUPHORIA_SLOWMO_RAMP = 0.35
local EUPHORIA_SLOWMO_COOLDOWN = 0.8
local EUPHORIA_CURL_TIME = 2.5
local EUPHORIA_CURL_WINDOW = 1.2
local EUPHORIA_CURL_TRIGGER = 2
local EUPHORIA_CURL_EASE = 0.5

local function isFloppyBone(ragdoll, physNum)
	local floppy = ragdoll.hg_floppy_bones
	if not floppy then return false end
	local bone = ragdoll:TranslatePhysBoneToBone(physNum)
	if bone < 0 then return false end
	return floppy[ragdoll:GetBoneName(bone)] == true
end

local function tensionBones(ragdoll, strength, dtime, allowLinear)
	local angK = math.min(strength * EUPHORIA_TENSION_ANG * dtime, 1)
	local linK = allowLinear and math.min(strength * EUPHORIA_TENSION_LIN * dtime, 0.85) or 0
	if angK <= 0 and linK <= 0 then return end

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		if isFloppyBone(ragdoll, i) then continue end
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if not IsValid(phys) then continue end

		if angK > 0 then
			local av = phys:GetAngleVelocity()
			if av:LengthSqr() > 1 then
				phys:AddAngleVelocity(-av * angK)
			end
		end

		if linK > 0 then
			local lv = phys:GetVelocity()
			if lv:LengthSqr() > 16 then
				phys:AddVelocity(-lv * linK)
			end
		end
	end
end

local function grabHand(ragdoll, org, pos)
	local lArm = not (org and (org.larmamputated or org.larmupamputated))
	local rArm = not (org and (org.rarmamputated or org.rarmupamputated))
	local lHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 5))
	local rHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 7))
	local lValid = lArm and IsValid(lHand)
	local rValid = rArm and IsValid(rHand)
	if lValid and (not rValid or lHand:GetPos():Distance(pos) <= rHand:GetPos():Distance(pos)) then
		return lHand, 4
	end
	if rValid then return rHand, 6 end
	return nil
end

local function nearestPhys(ragdoll, pos)
	local best, bestDist
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		if isFloppyBone(ragdoll, i) then continue end
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if not IsValid(phys) then continue end
		local dist = phys:GetPos():Distance(pos)
		if not bestDist or dist < bestDist then
			best, bestDist = phys, dist
		end
	end
	return best
end

local function flinchRagdoll(ragdoll, dmgInfo)
	local dir = dmgInfo:GetDamageForce()
	local len = dir:Length()
	local hitPos = dmgInfo:GetDamagePosition()

	if len <= 1 then
		local root = ragdoll:GetPhysicsObject()
		local base = IsValid(root) and root:GetPos() or ragdoll:GetPos()
		if hitPos and hitPos:Distance(base) > 1 then
			dir = base - hitPos
			len = dir:Length()
		end
	end

	if len <= 1 then
		dir = Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-0.3, 0.6))
		len = dir:Length()
	end

	dir = dir / len
	local mul = ragdoll.power or 1

	local bones = {
		[0] = 0.5, [1] = 0.7, [2] = 0.7, [3] = 0.7, [10] = 1.1,
		[4] = 0.85, [5] = 0.9, [6] = 0.85, [7] = 0.9,
		[8] = 0.75, [9] = 0.65, [11] = 0.75, [12] = 0.65, [13] = 0.6, [14] = 0.6,
	}

	local headPhys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 10))
	local isHeadHit = hitPos and IsValid(headPhys) and headPhys:GetPos():Distance(hitPos) < 70

	for physNum, weight in pairs(bones) do
		local phys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, physNum))
		if not IsValid(phys) then continue end

		local falloff = 1
		if hitPos then
			falloff = math.Clamp(1 - phys:GetPos():Distance(hitPos) / EUPHORIA_PROP_FALLOFF, EUPHORIA_PROP_MIN, 1)
		end

		if physNum == 10 then
			if isHeadHit then
				phys:AddAngleVelocity(dir * EUPHORIA_PROP_BASE * weight * falloff * mul * 1.3 * (0.6 + math.Rand(0, 0.4)))
			else
				phys:AddAngleVelocity(-dir * EUPHORIA_PROP_BASE * weight * falloff * mul * EUPHORIA_PROP_HEAD_WHIP * (0.6 + math.Rand(0, 0.4)))
			end
		else
			phys:AddAngleVelocity(dir * EUPHORIA_PROP_BASE * weight * falloff * mul * (0.6 + math.Rand(0, 0.4)))
		end

		if physNum >= 1 and physNum <= 3 then
			phys:AddAngleVelocity(dir:Cross(Vector(0, 0, 1)) * EUPHORIA_PROP_SPINE_CURL * falloff * mul)
		end
	end

	local root = ragdoll:GetPhysicsObject()
	if IsValid(root) then
		root:AddVelocity(dir * 55 * mul)
	end
end

local function landingReaction(ragdoll, ply, hSpeed)
	local org = ply.organism
	local conscious = org and org.consciousness or 1
	local pain = org and org.pain or 0
	local shock = org and org.shock or 0
	local berserk = math.min(org and org.berserk or 0, 3)

	local controlling = org and org.canmove ~= false and (
		hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
		hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT)
	)

	local absorb = EUPHORIA_LANDING_ABSORB * math.min(hSpeed / EUPHORIA_LANDING_MIN_HS, 1)
	if controlling then absorb = absorb * EUPHORIA_LANDING_ABSORB_CONTROL end
	absorb = math.Clamp(absorb * (0.5 + conscious * 0.5) * (1 - berserk * 0.12), 0.15, 0.9)

	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		if isFloppyBone(ragdoll, i) then continue end
		local phys = ragdoll:GetPhysicsObjectNum(i)
		if not IsValid(phys) then continue end
		local v = phys:GetVelocity()
		if v:LengthSqr() > 16 then
			phys:AddVelocity(Vector(-v.x * absorb, -v.y * absorb, 0))
		end
	end

	ragdoll.hgSettleUntil = SysTime() + EUPHORIA_SETTLE_TIME * (controlling and 0.4 or 1) * (1 - berserk * 0.2)
	ragdoll.hgSettleStrength = 1

	local awareness = conscious * (1 - math.min(shock / 60, 1)) * (1 - math.min(math.max(pain - 30, 0) / 70, 1))

	if awareness > 0.25 and not controlling then
		local flail = (70 + 90 * math.min(hSpeed / 700, 1)) * awareness
		local rHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 7))
		local lHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 5))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		local flailV = Vector(0, 0, 1) * flail
		if IsValid(rHand) then rHand:AddAngleVelocity(flailV) end
		if IsValid(lHand) then lHand:AddAngleVelocity(-flailV) end
		if IsValid(spine) then spine:AddAngleVelocity(-flailV * 0.4) end
	end

	if IsValid(ply) and ply:Alive() and awareness > 0.1 then
		ply:ViewPunch(Angle(-3 - 4 * math.min(hSpeed / 700, 1) * awareness, math.Rand(-2, 2), math.Rand(-1.5, 1.5)))
	end
end

local function startGetUp(ragdoll, ply)
	if not hg_euphoria_detail:GetBool() then return end
	if not IsValid(ply) or not ply:Alive() then return end
	local org = ply.organism
	if not org or not org.canmove then return end
	if (org.consciousness or 0) < EUPHORIA_GETUP_MIN_CONSCIOUSNESS then return end
	if ragdoll.hgGetUp then return end

	local berserk = math.min(org.berserk or 0, 3)
	local dur = EUPHORIA_GETUP_TIME * (1 - berserk * 0.2)
	ragdoll.hgGetUp = { untilT = SysTime() + dur, dur = dur, berserk = berserk }
end

local slowmoUntil = 0
local slowmoLast = 0
local slowmoActive = false

local function slowmoThink()
	local now = SysTime()

	if now < slowmoUntil then
		game.SetTimeScale(EUPHORIA_SLOWMO_SCALE)
		return
	end

	local left = slowmoUntil + EUPHORIA_SLOWMO_RAMP - now
	if left <= 0 then
		game.SetTimeScale(1)
		slowmoActive = false
		hook.Remove("Think", "HG_EuphoriaSlowmo")
		return
	end

	game.SetTimeScale(Lerp(left / EUPHORIA_SLOWMO_RAMP, EUPHORIA_SLOWMO_SCALE, 1))
end

local function triggerSlowmo()
	local now = SysTime()
	if now - slowmoLast < EUPHORIA_SLOWMO_COOLDOWN then return end

	slowmoLast = now
	slowmoUntil = math.max(slowmoUntil, now + EUPHORIA_SLOWMO_TIME)

	if slowmoActive then return end
	slowmoActive = true
	hook.Add("Think", "HG_EuphoriaSlowmo", slowmoThink)
end

hook.Add("EntityTakeDamage", "HG_EuphoriaHit", function(ent, dmgInfo)
	if not IsValid(ent) then return end

	local ply, ragdoll
	if ent:IsPlayer() then
		if not ent:Alive() then return end
		ragdoll = ent.FakeRagdoll
		if not IsValid(ragdoll) then return end
		ply = ent
	elseif ent:IsRagdoll() then
		ply = hg.RagdollOwner(ent)
		if not IsValid(ply) then return end
		ragdoll = ent
	else
		return
	end

	local dmgType = dmgInfo:GetDamageType()
	if bit.band(dmgType, DMG_FALL + DMG_CRUSH + DMG_BURN + DMG_POISON + DMG_DROWN) ~= 0 then return end

	local dmg = dmgInfo:GetDamage()

	local now = SysTime()
	if ragdoll.hgBeat and now > ragdoll.hgBeat.untilT then
		ragdoll.hgBeat = nil
	end
	if not ragdoll.hgBeat then
		ragdoll.hgBeat = { count = 0, untilT = now + EUPHORIA_CURL_WINDOW }
	end
	ragdoll.hgBeat.count = ragdoll.hgBeat.count + 1
	if ragdoll.hgBeat.count >= EUPHORIA_CURL_TRIGGER and not ragdoll.hgCurl and not ragdoll.hgGetUp and hg_euphoria_detail:GetBool() then
		ragdoll.hgBeat = nil
		ragdoll.hgWoundGrab = nil
		ragdoll.hgCurl = { untilT = now + EUPHORIA_CURL_TIME, dur = EUPHORIA_CURL_TIME }
	end

	if dmg < 8 then return end

	local strength = math.Clamp(dmg / 30, 0.4, 1.4)

	if ragdoll.hgGetUp then
		local fForce = dmgInfo:GetDamageForce()
		local fDir = Vector(fForce.x, fForce.y, 0)
		if fDir:LengthSqr() > 1 then
			ragdoll.hgStagger = { dir = fDir:GetNormalized(), untilT = SysTime() + 0.35, dur = 0.35 }
		end
	end

	if hg_euphoria_tension:GetBool() then
		ragdoll.hgTensionUntil = SysTime() + EUPHORIA_TENSION_TIME * strength
		ragdoll.hgTensionStrength = strength
		ragdoll.hgTensionLinear = true
	end

	if dmg >= 12 then
		if hg_euphoria_flinch:GetBool() then
			flinchRagdoll(ragdoll, dmgInfo)
		end

		if hg_euphoria_slowmo:GetBool() then
			triggerSlowmo()
		end

		if hg_euphoria_detail:GetBool() then
			local hitPos = dmgInfo:GetDamagePosition()
			local rootPhys = ragdoll:GetPhysicsObject()
			local rootPos = IsValid(rootPhys) and rootPhys:GetPos() or ragdoll:GetPos()
			local woundPos
			if hitPos and hitPos:Distance(rootPos) < 200 then
				woundPos = hitPos
			else
				local force = dmgInfo:GetDamageForce()
				local fDir = force:Length() > 1 and force:GetNormalized() or Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-0.3, 0.6)):GetNormalized()
				woundPos = rootPos + fDir * 25
			end
			local handPhys, forearm = grabHand(ragdoll, ply.organism, woundPos)
			local bonePhys = nearestPhys(ragdoll, woundPos)
			if handPhys and bonePhys then
				ragdoll.hgWoundGrab = { hand = handPhys, forearm = forearm, bone = bonePhys, untilT = SysTime() + EUPHORIA_WOUND_GRAB_TIME, dur = EUPHORIA_WOUND_GRAB_TIME }
			end
		end
	end
end)

hook.Add("Ragdoll Collide", "HG_EuphoriaLanding", function(ragdoll, data)
	if not hg_euphoria_stumble:GetBool() then return end
	if not IsValid(ragdoll) then return end
	if ragdoll.isSliding or ragdoll.isDropkicking then return end
	if not IsValid(data.HitEntity) or not data.HitEntity:IsWorld() then return end
	if (data.HitNormal.z or 0) < 0.7 then return end

	local vel = data.OurOldVelocity
	if not vel then return end

	local speed = vel:Length()
	if speed < EUPHORIA_LANDING_MIN_SPEED then return end

	local hSpeed = Vector(vel.x, vel.y, 0):Length()

	local ply = hg.RagdollOwner(ragdoll)
	if not IsValid(ply) then return end

	landingReaction(ragdoll, ply, hSpeed)
end)

hook.Add("Think", "HG_EuphoriaSettle", function()
	if not hg_euphoria_stumble:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		local untilT = ragdoll.hgSettleUntil
		if not untilT then continue end

		if untilT <= now or ragdoll.isSliding or ragdoll.isDropkicking then
			ragdoll.hgSettleUntil = nil
			continue
		end

		if hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
			hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT) then
			startGetUp(ragdoll, ply)
			ragdoll.hgSettleUntil = nil
			continue
		end

		if hg.KeyDown(ply, IN_USE) or hg.KeyDown(ply, IN_ATTACK) or hg.KeyDown(ply, IN_ATTACK2) then
			ragdoll.hgSettleUntil = nil
			continue
		end

		local dtime = (now - (ragdoll.hgSettleLast or now)) * game.GetTimeScale()
		ragdoll.hgSettleLast = now
		if dtime <= 0 then continue end

		local strength = ragdoll.hgSettleStrength or 1
		local linK = math.min(EUPHORIA_SETTLE_LIN * dtime * strength, 1)
		local angK = math.min(EUPHORIA_SETTLE_ANG * dtime * strength, 1)

		local pelvis = hg.realPhysNum(ragdoll, 0)
		local spine = hg.realPhysNum(ragdoll, 1)
		local spine1 = hg.realPhysNum(ragdoll, 2)
		local spine2 = hg.realPhysNum(ragdoll, 3)

		for j = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			if isFloppyBone(ragdoll, j) then continue end
			local phys = ragdoll:GetPhysicsObjectNum(j)
			if not IsValid(phys) then continue end

			local v = phys:GetVelocity()
			if v:LengthSqr() > 16 then
				phys:AddVelocity(Vector(-v.x * linK, -v.y * linK, 0))
			end

			if j == pelvis or j == spine or j == spine1 or j == spine2 then
				local av = phys:GetAngleVelocity()
				if av:LengthSqr() > 1 then
					phys:AddAngleVelocity(-av * angK)
				end
			end
		end
	end
end)

hook.Add("Think", "HG_EuphoriaWound", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		local grab = ragdoll.hgWoundGrab
		if not grab then continue end

		if now >= grab.untilT or not ply:Alive() or
			hg.KeyDown(ply, IN_USE) then
			ragdoll.hgWoundGrab = nil
			continue
		end

		local dtime = (now - (ragdoll.hgWoundLast or now)) * game.GetTimeScale()
		ragdoll.hgWoundLast = now
		if dtime <= 0 then continue end

		local handPhys = grab.hand
		local bonePhys = grab.bone
		if not IsValid(handPhys) or not IsValid(bonePhys) then
			ragdoll.hgWoundGrab = nil
			continue
		end

		local forearmPhys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, grab.forearm))

		local frac = (grab.untilT - now) / grab.dur
		local handPos = handPhys:GetPos()
		local target = bonePhys:GetPos()

		local toTarget = target - handPos
		local dist = toTarget:Length()
		if dist > 1 then
			local pull = toTarget / dist * EUPHORIA_WOUND_GRAB_PULL * frac * dtime
			handPhys:AddVelocity(pull)
			if IsValid(forearmPhys) then
				forearmPhys:AddVelocity(pull * 0.6)
			end
		end

		local p = {}
		p.secondstoarrive = 0.04
		p.pos = target
		p.angle = handPhys:GetAngles()
		p.maxangular = 0
		p.maxangulardamp = 0
		p.maxspeed = 340
		p.maxspeeddamp = 90
		p.teleportdistance = 0
		handPhys:ComputeShadowControl(p)

		if IsValid(forearmPhys) then
			local fp = {}
			fp.secondstoarrive = 0.06
			fp.pos = target + (forearmPhys:GetPos() - handPos)
			fp.angle = forearmPhys:GetAngles()
			fp.maxangular = 0
			fp.maxangulardamp = 0
			fp.maxspeed = 240
			fp.maxspeeddamp = 70
			fp.teleportdistance = 0
			forearmPhys:ComputeShadowControl(fp)
		end
	end
end)

local function legRestShadow(phys, target, speed, damp)
	local p = {}
	p.secondstoarrive = 0.2
	p.pos = target
	p.angle = phys:GetAngles()
	p.maxangular = 0
	p.maxangulardamp = 0
	p.maxspeed = speed
	p.maxspeeddamp = damp
	p.teleportdistance = 0
	phys:ComputeShadowControl(p)
end

hook.Add("Think", "HG_EuphoriaLegRest", function()
	if not hg_euphoria_detail:GetBool() then return end

	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end
		if not ply:Alive() then continue end

		if ragdoll.hgGetUp or ragdoll.hgCurl or ragdoll.hgFallStumble or ragdoll.hgStumbleActive or
			ragdoll.isSliding or ragdoll.isDropkicking or ragdoll.hgWallSmear then continue end

		if hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
			hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT) then continue end

		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local head = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 10))
		if not IsValid(pelvis) or not IsValid(head) then continue end
		local pelvisPos = pelvis:GetPos()
		local headPos = head:GetPos()
		if not pelvisPos or not headPos then continue end
		if math.abs(pelvisPos.z - headPos.z) >= 45 then continue end

		local root = ragdoll:GetPhysicsObject()
		if not IsValid(root) then continue end
		if root:GetVelocity():Length() > 70 then continue end

		local lFoot = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 13))
		local rFoot = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 14))
		if not IsValid(lFoot) or not IsValid(rFoot) then continue end

		local lFootPos = lFoot:GetPos()
		local rFootPos = rFoot:GetPos()
		if not lFootPos or not rFootPos then continue end

		local mid = (lFootPos + rFootPos) / 2
		local target = mid + Vector(0, 0, 5)
		local dir = lFootPos - rFootPos
		local right
		if dir:LengthSqr() > 0.01 then
			right = dir:GetNormalized()
		else
			right = Vector(1, 0, 0)
		end

		legRestShadow(lFoot, target - right * 3, 150, 70)
		legRestShadow(rFoot, target + right * 3, 150, 70)
	end
end)

local function curlTarget(ragdoll, physNum, target, speed, damp)
	local phys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, physNum))
	if not IsValid(phys) then return end
	local p = {}
	p.secondstoarrive = 0.12
	p.pos = target
	p.angle = phys:GetAngles()
	p.maxangular = 0
	p.maxangulardamp = 0
	p.maxspeed = speed
	p.maxspeeddamp = damp
	p.teleportdistance = 0
	phys:ComputeShadowControl(p)
end

hook.Add("Think", "HG_EuphoriaCurl", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end
		if not ply:Alive() then continue end

		local curl = ragdoll.hgCurl
		if not curl then continue end

		if now >= curl.untilT or ragdoll.hgGetUp or
			hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
			hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT) or
			hg.KeyDown(ply, IN_USE) then
			ragdoll.hgCurl = nil
			continue
		end

		local frac = (curl.untilT - now) / curl.dur
		local ease = math.Clamp(frac / EUPHORIA_CURL_EASE, 0, 1)

		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		if not IsValid(pelvis) or not IsValid(spine) then
			ragdoll.hgCurl = nil
			continue
		end

		local pelvisPos = pelvis:GetPos()
		local pelvisAng = pelvis:GetAngles()
		if type(pelvisAng) ~= "Angle" then
			ragdoll.hgCurl = nil
			continue
		end
		local chestPos = spine:GetPos()

		local speed = 240 * ease
		local damp = 70

		local up = pelvisAng:Up()
		local fwd = pelvisAng:Forward()
		local right = pelvisAng:Right()

		curlTarget(ragdoll, 12, pelvisPos + up * 20 + fwd * 8, speed, damp)
		curlTarget(ragdoll, 13, pelvisPos + up * 16 + fwd * 6, speed, damp)
		curlTarget(ragdoll, 9, pelvisPos + up * 20 + fwd * 8, speed, damp)
		curlTarget(ragdoll, 14, pelvisPos + up * 16 + fwd * 6, speed, damp)
		curlTarget(ragdoll, 5, chestPos + up * 10 - right * 10, speed, damp)
		curlTarget(ragdoll, 4, chestPos + up * 12 - right * 15, speed, damp)
		curlTarget(ragdoll, 7, chestPos + up * 10 + right * 10, speed, damp)
		curlTarget(ragdoll, 6, chestPos + up * 12 + right * 15, speed, damp)
		curlTarget(ragdoll, 10, chestPos + up * 4, speed, damp)
	end
end)

hook.Add("Think", "HG_EuphoriaWallGrab", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end
		if not ply:Alive() then continue end
		local org = ply.organism
		if not org or not org.canmove then continue end

		local rootPhys = ragdoll:GetPhysicsObject()
		if not IsValid(rootPhys) then continue end

		local grab = ragdoll.hgWallGrab
		if grab then
			if now >= grab.untilT or rootPhys:GetVelocity().z > -60 then
				ragdoll.hgWallGrab = nil
				ragdoll.hgWallGrabCooldown = now + EUPHORIA_WALL_GRAB_COOLDOWN
				continue
			end

			local dtime = (now - (ragdoll.hgWallGrabLast or now)) * game.GetTimeScale()
			ragdoll.hgWallGrabLast = now
			if dtime <= 0 then continue end

			local handPhys = grab.hand
			if IsValid(handPhys) then
				local toWall = grab.pos - handPhys:GetPos()
				local dist = toWall:Length()
				if dist > 1 then
					handPhys:AddVelocity(toWall / dist * EUPHORIA_WALL_GRAB_PULL * ((grab.untilT - now) / grab.dur) * dtime)
				end
			end
			continue
		end

		if ragdoll.hgWallGrabCooldown and now < ragdoll.hgWallGrabCooldown then continue end

		local vel = rootPhys:GetVelocity()
		if vel.z > EUPHORIA_WALL_GRAB_SPEED then continue end
		if not (hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT)) then continue end

		local angles = ply:EyeAngles()
		local moveDir
		if hg.KeyDown(ply, IN_FORWARD) then
			moveDir = angles:Forward()
		elseif hg.KeyDown(ply, IN_BACK) then
			moveDir = -angles:Forward()
		elseif hg.KeyDown(ply, IN_MOVELEFT) then
			moveDir = -angles:Right()
		elseif hg.KeyDown(ply, IN_MOVERIGHT) then
			moveDir = angles:Right()
		end
		moveDir.z = 0
		moveDir = moveDir:GetNormalized()

		local spinePhys = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		local start = IsValid(spinePhys) and spinePhys:GetPos() or ragdoll:GetPos()

		local tr = util.TraceLine({
			start = start,
			endpos = start + moveDir * EUPHORIA_WALL_GRAB_DIST,
			filter = {ply, ragdoll},
			mask = MASK_SOLID,
		})
		if not tr.Hit or tr.HitSky then continue end
		if tr.Normal.z > 0.6 then continue end

		local handPhys, forearm = grabHand(ragdoll, org, tr.HitPos)
		if not handPhys then continue end
		ragdoll.hgWallGrab = { hand = handPhys, forearm = forearm, pos = tr.HitPos, untilT = now + EUPHORIA_WALL_GRAB_TIME, dur = EUPHORIA_WALL_GRAB_TIME }
	end
end)

hook.Add("Think", "HG_EuphoriaGetUp", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		local getup = ragdoll.hgGetUp
		if not getup then continue end

		if now >= getup.untilT or not ply:Alive() then
			ragdoll.hgGetUp = nil
			continue
		end

		if not (hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
			hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT)) then
			ragdoll.hgGetUp = nil
			continue
		end

		local dtime = (now - (ragdoll.hgGetUpLast or now)) * game.GetTimeScale()
		ragdoll.hgGetUpLast = now
		if dtime <= 0 then continue end

		local frac = (getup.untilT - now) / getup.dur
		local boost = 1 + getup.berserk * 0.3
		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		if not IsValid(pelvis) or not IsValid(spine) then
			ragdoll.hgGetUp = nil
			continue
		end

		local push = EUPHORIA_GETUP_PUSH * frac * boost * dtime * (ragdoll.hgStumbleActive and 0.25 or 1)
		pelvis:AddVelocity(Vector(0, 0, 1) * push)
		spine:AddVelocity(Vector(0, 0, 1) * push * 0.5)

		local spineAng = spine:GetAngles()
		if type(spineAng) ~= "Angle" then continue end
		local up = spineAng:Up()
		if up.z > 0.3 then
			local axis = up:Cross(Vector(0, 0, -1))
			if axis:LengthSqr() < 0.01 then
				axis = spineAng:Forward()
			else
				axis = axis:GetNormalized()
			end
			local roll = EUPHORIA_GETUP_ROLL * frac * boost * dtime
			pelvis:AddAngleVelocity(axis * roll)
			spine:AddAngleVelocity(axis * roll * 0.5)
		end

		if getup.berserk > 1 and math.random() < 0.6 then
			local jitter = EUPHORIA_BERSERK_JERK * frac * getup.berserk * dtime
			local rHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 7))
			local lHand = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 5))
			if IsValid(rHand) then rHand:AddAngleVelocity(VectorRand() * jitter) end
			if IsValid(lHand) then lHand:AddAngleVelocity(VectorRand() * jitter) end
		end
	end
end)

hook.Add("Think", "HG_EuphoriaTension", function()
	if not hg_euphoria_tension:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		local untilT = ragdoll.hgTensionUntil
		if not untilT or untilT <= now then
			ragdoll.hgTensionUntil = nil
			continue
		end
		if ragdoll.hgWallSmear then continue end

		local dt = (SysTime() - (ragdoll.hgEuphoriaLast or SysTime())) * game.GetTimeScale()
		ragdoll.hgEuphoriaLast = SysTime()
		tensionBones(ragdoll, ragdoll.hgTensionStrength or 1, dt, ragdoll.hgTensionLinear ~= false)
	end
end)

hook.Add("Ragdoll Collide", "HG_EuphoriaWallSmear", function(ragdoll, data)
	if not hg_euphoria_detail:GetBool() then return end
	if not IsValid(ragdoll) then return end
	if ragdoll.isSliding or ragdoll.isDropkicking then return end
	if not IsValid(data.HitEntity) or not data.HitEntity:IsWorld() then return end
	local normal = data.HitNormal
	if not normal or normal.z >= 0.6 then return end

	local vel = data.OurOldVelocity
	if not vel then return end
	if Vector(vel.x, vel.y, 0):Length() < EUPHORIA_WALL_MIN_SPEED then return end

	local ply = hg.RagdollOwner(ragdoll)
	if not IsValid(ply) then return end

	ragdoll.hgWallSmear = { normal = normal, untilT = SysTime() + EUPHORIA_WALL_SMEAR_TIME }
end)

hook.Add("Think", "HG_EuphoriaWallSmear", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end

		local smear = ragdoll.hgWallSmear
		if not smear then continue end

		if ragdoll.hgWallGrab then continue end

		local rootPhys = ragdoll:GetPhysicsObject()
		if IsValid(rootPhys) and rootPhys:GetVelocity().z < -20 then
			smear.untilT = math.max(smear.untilT, now + 0.25)
		end

		if now >= smear.untilT then
			ragdoll.hgWallSmear = nil
			continue
		end

		local dtime = (now - (ragdoll.hgWallSmearLast or now)) * game.GetTimeScale()
		ragdoll.hgWallSmearLast = now
		if dtime <= 0 then continue end

		local k = math.min(EUPHORIA_WALL_SMEAR_STICK * dtime, 1)
		local n = smear.normal
		for j = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			if isFloppyBone(ragdoll, j) then continue end
			local phys = ragdoll:GetPhysicsObjectNum(j)
			if not IsValid(phys) then continue end
			local v = phys:GetVelocity()
			local into = v:Dot(n)
			if into > 0 then
				phys:AddVelocity(-n * into * k)
			end
			phys:AddVelocity(-n * EUPHORIA_WALL_STICK * dtime)
			phys:AddVelocity(Vector(0, 0, -EUPHORIA_WALL_SLIDE_SPEED) * dtime)
		end
	end
end)

hook.Add("Think", "HG_EuphoriaAmputee", function()
	if not hg_euphoria_detail:GetBool() then return end

	local now = SysTime()
	for i, ply in player.Iterator() do
		local ragdoll = ply.FakeRagdoll
		if not IsValid(ragdoll) then continue end
		if not ply:Alive() then continue end
		local org = ply.organism
		if not org then continue end

		local side = 0
		if org.larmamputated or org.larmupamputated then side = side - 1 end
		if org.rarmamputated or org.rarmupamputated then side = side + 1 end
		if org.llegamputated or org.llegupamputated or org.lleg == 1 or org.llegdislocation then side = side - 1 end
		if org.rlegamputated or org.rlegupamputated or org.rleg == 1 or org.rlegdislocation then side = side + 1 end
		if side == 0 then continue end

		if hg.KeyDown(ply, IN_FORWARD) or hg.KeyDown(ply, IN_BACK) or
			hg.KeyDown(ply, IN_MOVELEFT) or hg.KeyDown(ply, IN_MOVERIGHT) or
			hg.KeyDown(ply, IN_USE) or hg.KeyDown(ply, IN_ATTACK) or hg.KeyDown(ply, IN_ATTACK2) then
			continue
		end

		local dtime = (now - (ragdoll.hgAmputeeLast or now)) * game.GetTimeScale()
		ragdoll.hgAmputeeLast = now
		if dtime <= 0 then continue end

		local pelvis = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 0))
		local spine = ragdoll:GetPhysicsObjectNum(hg.realPhysNum(ragdoll, 1))
		if not IsValid(pelvis) or not IsValid(spine) then continue end

		local ang = spine:GetAngles()
		if type(ang) ~= "Angle" then continue end
		if math.abs(ang.p) > 55 then continue end

		local fwd = ang:Forward()
		local roll = math.asin(math.Clamp(ang:Right().z, -1, 1)) * 57.2958
		local target = -side * EUPHORIA_AMPUTEE_ANGLE
		local rollVel = spine:GetAngleVelocity():Dot(fwd)

		local correction = math.Clamp((target - roll) * EUPHORIA_AMPUTEE_STIFFNESS - rollVel * EUPHORIA_AMPUTEE_DAMP, -20, 20)
		if math.abs(correction) < 0.5 then continue end

		local rot = fwd * correction * dtime
		pelvis:AddAngleVelocity(rot)
		spine:AddAngleVelocity(rot * 0.7)
	end
end)