local CurTime, IsValid = CurTime, IsValid
local min, max, clamp, rand, random = math.min, math.max, math.Clamp, math.Rand, math.random

hook.Remove("Should Fake Up", "BrainfuckFencing")
hook.Remove("Fake", "BrainfuckFencing")
hook.Remove("HG_OnOtrub", "BrainfuckFencing")
hook.Remove("RagdollDeath", "BrainfuckStart")
hook.Remove("Org Clear", "BrainfuckClear")
hook.Remove("HomigradDamage", "DecorticateTrigger")
hook.Remove("HomigradDamage", "BrainfuckFencing")
hook.Remove("EntityTakeDamage", "BrainfuckRagdollDamage")
hook.Remove("CanControlFake", "BrainfuckFencing")

hg.applyFencingToPlayer = nil
hg.applyDecorticateToPlayer = nil
hg.applyLazarusToPlayer = nil
hg.applyCushingToPlayer = nil

local CHANCE = 0.8
local POSTURE_DURATION = {5, 10}
local DECORTICATE_START, DECEREBRATE_START = 0.12, 0.45
local POSTURE_FADE_DURATION, POSTURE_FADE_BLEND = 3, 0.45

util.AddNetworkString("hg_brainfuck_posture_maker")
concommand.Add("hg_posture_maker", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end
	net.Start("hg_brainfuck_posture_maker")
	net.Send(ply)
end)

local function pose(angles)
	local out = {reference = 0, male09 = {}, female06 = {}}
	local bones = {
		"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_R_UpperArm", "ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm", "ValveBiped.Bip01_L_Hand", "ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Calf",
		"ValveBiped.Bip01_Head1", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Calf",
		"ValveBiped.Bip01_L_Foot", "ValveBiped.Bip01_R_Foot"
	}
	for i = 1, #bones do
		local ang = angles[i] or angle_zero
		out.male09[i] = {bone = bones[i], ang = ang}
		out.female06[i] = {bone = bones[i], ang = Angle(ang.p, ang.y, ang.r)}
	end
	return out
end

local decerebrateOffsets = pose({
	Angle(0, -14.173, 0), Angle(-31.181, -14.173, 0), Angle(31.181, -8.504, 0),
	Angle(39.685, -34.016, 0), Angle(-25.512, -56.693, -31.181), Angle(-36.850, -31.181, 0),
	Angle(8.504, -82.205, 0), Angle(), Angle(), Angle(0, 31.181, 0), Angle(2.835, 0, 0),
	Angle(), Angle(0, 50, 0), Angle(0, 50, 0)
})
local decorticateOffsets = {pose({
	Angle(0, -11.339, 0), Angle(11.339, -59.528, -96.378), Angle(-19.843, -56.693, 0),
	Angle(22.677, -180, -39.685), Angle(0, -99.213, 180), Angle(-14.173, 180, 56.693),
	Angle(180, 87.874, 39.685), Angle(-2.835, 0, 0), Angle(), Angle(0, 14.173, 0),
	Angle(2.835, 0, 0), Angle(), Angle(-8.504, 50, 0), Angle(0, 50, 0)
})}
local fencingOffsets = pose({
	Angle(), Angle(17.008, -82.205, -25.512), Angle(2.835, -28.346, 2.835),
	Angle(-17.008, -119.055, 0), Angle(-2.835, -138.898, 141.732), Angle(11.339, -133.228, 0),
	Angle(99.213, 76.535, 79.370), Angle(), Angle(), Angle(0, 11.339, 0), Angle(), Angle(),
	Angle(0, 36.850, 0), Angle(0, 51.024, 0)
})

local postureBoneFade = {[10] = 0, [1] = 0.15, [2] = 0.35, [3] = 0.35, [4] = 0.45, [6] = 0.45, [5] = 0.55, [7] = 0.55, [8] = 0.7, [11] = 0.7, [9] = 0.85, [12] = 0.85, [13] = 1, [14] = 1}

local function getBrainLobeSeverity(org)
	return min(org.brainFrontal or 0, 0.2) + min(org.brainParietal or 0, 0.2) + min(org.brainTemporal or 0, 0.2) + min(org.brainOccipital or 0, 0.2)
end

local function getBrainFactor(org)
	return clamp(((org.brain or 0) * 1.2) + ((org.skull or 0) * 0.9) + getBrainLobeSeverity(org) * 0.7, 0, 1)
end

local function startFencing(org, dur)
	if not org then return end
	if dur ~= nil and not isnumber(dur) then dur = nil end
	local time = CurTime()
	if org.fencingEnd and time < org.fencingEnd then
		local extra = dur or rand(2.5, 4.5)
		org.fencingEnd = org.fencingEnd + extra
		org.fencingDur = (org.fencingDur or 3.8) + extra
		return
	end
	dur = dur or rand(6, 12)
	org.fencingStart, org.fencingEnd, org.fencingDur = time, time + dur, dur
end

hg.applyFencingToPlayer = function(ply, dur)
	if IsValid(ply) and ply.organism then startFencing(ply.organism, dur) end
end

local function getPostureState(org)
	local time = CurTime()
	if org.fencingEnd then
		if time < org.fencingEnd then return "fencing", max(org.brain or 0, getBrainLobeSeverity(org)), 1 end
		org.fencingStart, org.fencingEnd, org.fencingDur = nil, nil, nil
	end
	if org.postureSpasmEnd and time < org.postureSpasmEnd then
		return org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale or 1
	end
	org.postureSpasmType, org.postureSpasmEnd, org.postureSpasmStart, org.postureSpasmDur = nil, nil, nil, nil
	org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale = nil, nil, nil
end

local function processPosture(rag, postureType, scale)
	if not IsValid(rag) then return end
	local reference = rag:GetPhysicsObjectNum(0)
	if not IsValid(reference) then return end
	local org = rag.organism
	local posture = postureType == "fencing" and fencingOffsets or postureType == "decorticate" and decorticateOffsets[org and org.decorticateVariant or 1] or decerebrateOffsets
	local offsets = string.find(string.lower(rag:GetModel() or ""), "female", 1, true) and posture.female06 or posture.male09
	local referenceAng = reference:GetAngles()
	local pulseScale = clamp(((org and org.pulse) or 70) / 70, 0.55, 1.25)
	rag.postureBase = rag.postureBase or {}
	for physBone, offset in pairs(offsets) do
		local realPhysBone = hg.realPhysNum and hg.realPhysNum(rag, physBone) or physBone
		local phys = rag:GetPhysicsObjectNum(realPhysBone)
		if not IsValid(phys) then continue end
		if not rag.postureBase[physBone] then
			local _, localAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), reference:GetPos(), referenceAng)
			rag.postureBase[physBone] = localAng
		end
		local start = org and (org.postureDeathStart or org.postureSpasmStart or org.fencingStart)
		local delay = (postureBoneFade[physBone] or 0) * (POSTURE_FADE_DURATION - POSTURE_FADE_BLEND)
		local fade = start and clamp((CurTime() - start - delay) / POSTURE_FADE_BLEND, 0, 1) or 1
		local _, baseAng = LocalToWorld(vector_origin, rag.postureBase[physBone], vector_origin, referenceAng)
		local _, localAng = LocalToWorld(vector_origin, offset.ang, vector_origin, rag.postureBase[physBone])
		local _, targetAng = LocalToWorld(vector_origin, localAng, vector_origin, referenceAng)
		hg.ShadowControl(rag, physBone, 0.01, LerpAngle(fade, baseAng, targetAng), 1800 * pulseScale * (scale or 1) * fade, 120 * pulseScale, vector_origin, 0, 0)
	end
end

function hg.applySeizurePostureToRagdoll(rag, org, scale)
	if not IsValid(rag) then return end
	rag.organism = rag.organism or org
	processPosture(rag, "decorticate", scale or 1)
end

local function applySpasm(rag, stype, useFencing)
	if not IsValid(rag) or not rag.organism then return end
	local org = rag.organism
	local dur = rand(POSTURE_DURATION[1], POSTURE_DURATION[2])
	if useFencing then startFencing(org, dur) return end
	local severity = max(getBrainFactor(org), DECORTICATE_START)
	org.postureSpasmType = stype or "posturing"
	org.postureSpasmStart, org.postureSpasmEnd, org.postureSpasmDur = CurTime(), CurTime() + dur, dur
	org.postureSpasmPostureType = severity >= DECEREBRATE_START and "decerebrate" or "decorticate"
	org.postureSpasmSeverity = severity
	org.postureSpasmScale = clamp(0.65 + clamp((org.brain or 0) * 1.2 + getBrainLobeSeverity(org) * 0.7, 0, 1) * 0.35, 0.65, 1)
	org.decorticateVariant = random(1, #decorticateOffsets)
end

hg.getRandomSpasm = function() return "posturing" end
hg.applySpasm = applySpasm

hook.Add("Org Clear", "BrainfuckClear", function(org)
	org.fencingStart, org.fencingEnd, org.fencingBrainDamage, org.fencingDur = nil, nil, nil, nil
	org.postureSpasmType, org.postureSpasmEnd, org.postureSpasmStart, org.postureSpasmDur = nil, nil, nil, nil
	org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale = nil, nil, nil
	org.postureDeathStart, org.postureDeathSeverity, org.postureDeathType = nil, nil, nil
end)

hook.Add("RagdollDeath", "BrainfuckStart", function(ply, rag)
	timer.Simple(0.1, function()
		if not IsValid(ply) or not IsValid(rag) or not ply.organism then return end
		local org = ply.organism
		local hadDamage = (org.brain or 0) > 0 or getBrainLobeSeverity(org) > 0 or org.dmgstack and org.dmgstack[HITGROUP_HEAD] and (org.dmgstack[HITGROUP_HEAD][1] or 0) > 0
		local recentHeadshot = org.lastHeadshot and CurTime() - org.lastHeadshot < 1.5
		if (rag.noHead or org.noHead or ply.noHead) and not hadDamage and not recentHeadshot then return end
		if hadDamage and (recentHeadshot or random() < clamp(CHANCE + getBrainFactor(org) * 0.6, 0, 1)) then applySpasm(rag, "posturing") end
	end)
end)

hook.Add("HomigradDamage", "BrainfuckFencing", function(ply, dmgInfo, hitgroup)
	if not IsValid(ply) or not ply:IsPlayer() or not ply.organism then return end
	if dmgInfo:IsDamageType(DMG_CLUB) then ply.organism.lastClubHit = CurTime() end
	if dmgInfo:IsDamageType(DMG_BULLET) then ply.organism.lastBulletHit = CurTime() end
	if hitgroup == HITGROUP_HEAD then
		ply.organism.lastHeadshot = CurTime()
		ply.organism.fencingBrainDamage = CurTime()
	end
end)

hook.Add("CanControlFake", "BrainfuckFencing", function(ply, rag)
	local org = IsValid(rag) and rag.organism or IsValid(ply) and ply.organism
	if org and org.posturing then return false end
end)

hook.Add("Org Think", "BrainfuckThink", function(owner)
	if not IsValid(owner) then return end
	local deathRag = owner:IsPlayer() and owner:GetNWEntity("RagdollDeath")
	local rag = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or IsValid(deathRag) and deathRag or owner:IsRagdoll() and owner
	local org = IsValid(rag) and rag.organism or owner.organism
	if not org then return end
	local time = CurTime()
	if org.postureThinkStamp == time then return end
	org.postureThinkStamp = time
	local postureType, severity, scale = getPostureState(org)
	local ply = IsValid(org.owner) and org.owner or owner
	deathRag = IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("RagdollDeath") or deathRag
	local dead = org.postureDeathStart ~= nil or deathRag == rag or owner:IsRagdoll() and (not IsValid(ply) or not ply:IsPlayer() or not ply:Alive())
	if dead and postureType then
		if not org.postureDeathStart or org.postureDeathType != postureType or (severity or 0) > (org.postureDeathSeverity or 0) + 0.05 then org.postureDeathStart = time end
		org.postureDeathSeverity, org.postureDeathType = severity or 0, postureType
	elseif not dead then
		org.postureDeathStart, org.postureDeathSeverity, org.postureDeathType = nil, nil, nil
	end
	org.posturing, org.postureType, org.postureSeverity, org.postureScale = postureType ~= nil, postureType, severity, scale
	org.postureDeadActive = dead and postureType ~= nil or nil
	if postureType and IsValid(rag) then processPosture(rag, postureType, scale) end
end)
