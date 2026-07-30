local CurTime, IsValid = CurTime, IsValid
local math_min, math_max, math_clamp, math_rand, math_random = math.min, math.max, math.Clamp, math.Rand, math.random

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
local posturingDur = {5, 10}
local DECORTICATE_START, DECEREBRATE_START = 0.12, 0.45
local POSTURE_FADE_DURATION, POSTURE_FADE_BLEND = 3, 0.45
local FENCING_DURATION, FENCING_RECENT_DAMAGE = 3.8, 1.5

util.AddNetworkString("hg_brainfuck_posture_maker")

concommand.Add("hg_posture_maker", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	net.Start("hg_brainfuck_posture_maker")
	net.Send(ply)
end)

local decerebrateOffsets = {
	reference = 0,
	["male09"] = {
		[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -14.173, 0.000)},
		[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-31.181, -14.173, 0.000)},
		[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(31.181, -8.504, 0.000)},
		[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(39.685, -34.016, 0.000)},
		[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-25.512, -56.693, -31.181)},
		[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-36.850, -31.181, 0.000)},
		[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(8.504, -82.205, 0.000)},
		[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 31.181, 0.000)},
		[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(2.835, 0.000, 0.000)},
		[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 50.000, 0.000)},
		[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 50.000, 0.000)},
	},
	["female06"] = {
		[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -14.173, 0.000)},
		[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-31.181, -14.173, 0.000)},
		[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(31.181, -8.504, 0.000)},
		[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(39.685, -34.016, 0.000)},
		[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-25.512, -56.693, -31.181)},
		[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-36.850, -31.181, 0.000)},
		[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(8.504, -82.205, 0.000)},
		[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 31.181, 0.000)},
		[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(2.835, 0.000, 0.000)},
		[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 50.000, 0.000)},
		[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 50.000, 0.000)},
	}
}

local decorticateOffsets = {
	[1] = {
		reference = 0,
		["male09"] = {
			[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -11.339, 0.000)},
			[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(11.339, -59.528, -96.378)},
			[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-19.843, -56.693, 0.000)},
			[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(22.677, -180.000, -39.685)},
			[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(0.000, -99.213, 180.000)},
			[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-14.173, 180.000, 56.693)},
			[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(180.000, 87.874, 39.685)},
			[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(-2.835, 0.000, 0.000)},
			[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
			[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 14.173, 0.000)},
			[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(2.835, 0.000, 0.000)},
			[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
			[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(-8.504, 50.000, 0.000)},
			[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 50.000, 0.000)},
		},
		["female06"] = {
			[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -11.339, 0.000)},
			[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(11.339, -59.528, -96.378)},
			[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-19.843, -56.693, 0.000)},
			[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(22.677, -180.000, -39.685)},
			[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(0.000, -99.213, 180.000)},
			[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-14.173, 180.000, 56.693)},
			[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(180.000, 87.874, 39.685)},
			[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(-2.835, 0.000, 0.000)},
			[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
			[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 14.173, 0.000)},
			[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(2.835, 0.000, 0.000)},
			[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
			[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(-8.504, 50.000, 0.000)},
			[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 50.000, 0.000)},
		}
	}
}

local fencingOffsets = {
	reference = 0,
	["male09"] = {
		[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, 0.000, 0.000)},
		[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(17.008, -82.205, -25.512)},
		[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(2.835, -28.346, 2.835)},
		[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(-17.008, -119.055, 0.000)},
		[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-2.835, -138.898, 141.732)},
		[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(11.339, -133.228, 0.000)},
		[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(99.213, 76.535, 79.370)},
		[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 11.339, 0.000)},
		[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 36.850, 0.000)},
		[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 51.024, 0.000)}
	},
	["female06"] = {
		[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, 0.000, 0.000)},
		[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(0.000, 0.000, 0.000)},
		[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(0.000, 0.000, 0.000)},
		[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(0.000, 0.000, 0.000)},
		[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(0.000, 0.000, 0.000)},
		[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(0.000, 0.000, 0.000)},
		[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(0.000, 0.000, 0.000)},
		[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 0.000, 0.000)},
		[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
		[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
		[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 0.000, 0.000)},
		[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 0.000, 0.000)}
	}
}

local fencingArmBones = {[2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [7] = true}
local fencingSpineBones = {[1] = 0.18}
local postureBoneFade = {[10] = 0, [1] = 0.15, [2] = 0.35, [3] = 0.35, [4] = 0.45, [6] = 0.45, [5] = 0.55, [7] = 0.55, [8] = 0.7, [11] = 0.7, [9] = 0.85, [12] = 0.85, [13] = 1, [14] = 1}

local function getPostureFade(org, physBone)
	if not org then return 1 end
	local start = org.postureDeathStart or org.postureSpasmStart or org.fencingStart
	if not start then return 1 end

	local delay = (postureBoneFade[physBone] or 0) * (POSTURE_FADE_DURATION - POSTURE_FADE_BLEND)
	return math_clamp((CurTime() - start - delay) / POSTURE_FADE_BLEND, 0, 1)
end

local function getBrainLobeSeverity(org)
	return math_min(org.brainFrontal or 0, 0.2)
		+ math_min(org.brainParietal or 0, 0.2)
		+ math_min(org.brainTemporal or 0, 0.2)
		+ math_min(org.brainOccipital or 0, 0.2)
end

local function getBrainFactor(org)
	local brain = org and org.brain or 0
	local skull = org and org.skull or 0
	return math_clamp((brain * 1.2) + (skull * 0.9) + getBrainLobeSeverity(org or {}) * 0.7, 0, 1)
end

local function getPosturingIntensity(org)
	local brain = org and org.brain or 0
	local lobes = getBrainLobeSeverity(org or {})
	return math_clamp(0.65 + math_clamp((brain * 1.2) + lobes * 0.7, 0, 1) * 0.35, 0.65, 1)
end

local function startFencing(org, dur)
	if not org then return end
	if dur ~= nil and not isnumber(dur) then dur = nil end
	local time = CurTime()
	if org.fencingEnd and time < org.fencingEnd then
		local extra = dur or math_rand(2.5, 4.5)
		org.fencingEnd = org.fencingEnd + extra
		org.fencingDur = (org.fencingDur or FENCING_DURATION) + extra
		return
	end
	dur = dur or math_rand(6, 12)
	org.fencingStart = time
	org.fencingEnd = time + dur
	org.fencingDur = dur
end

local function applyFencingToPlayer(ply, dur)
	if not IsValid(ply) or not ply.organism then return end
	startFencing(ply.organism, dur)
end

hg.applyFencingToPlayer = applyFencingToPlayer

local function getFencingScale(org)
	if not org.fencingEnd then return end
	local time = CurTime()
	if time >= org.fencingEnd then
		org.fencingStart, org.fencingEnd = nil, nil
		return
	end

	return math_clamp((org.fencingEnd - time) / (org.fencingDur or FENCING_DURATION), 0.1, 1)
end

local function getPostureState(org)
	local fencingScale = getFencingScale(org)
	if fencingScale then return "fencing", math_max(org.brain or 0, getBrainLobeSeverity(org)), 1 end

	local time = CurTime()
	if org.postureSpasmEnd and time < org.postureSpasmEnd then
		return org.postureSpasmPostureType, org.postureSpasmSeverity or getBrainFactor(org), org.postureSpasmScale or 1
	end

	org.postureSpasmType, org.postureSpasmEnd, org.postureSpasmStart, org.postureSpasmDur, org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale = nil, nil, nil, nil, nil, nil, nil
end

local function processPosture(rag, postureType, scale)
	if not IsValid(rag) then return end

	local reference = rag:GetPhysicsObjectNum(0)
	if not IsValid(reference) then return end

	local model = string.lower(rag:GetModel() or "")
	local org = rag.organism
	local postureOffsets = postureType == "fencing" and fencingOffsets or postureType == "decorticate" and decorticateOffsets or decerebrateOffsets
	if postureType == "decorticate" then postureOffsets = postureOffsets[org and org.decorticateVariant or 1] or postureOffsets[1] end
	local offsets = string.find(model, "female", 1, true) and postureOffsets.female06 or postureOffsets.male09
	local referenceAng = reference:GetAngles()
	local pulseScale = math_clamp(((org and org.pulse) or 70) / 70, 0.55, 1.25)
	local force = 1800 * pulseScale * (scale or 1)
	local damp = 120 * pulseScale
	rag.postureBase = rag.postureBase or {}

	for physBone, offset in pairs(offsets) do
		local ang = offset.ang
		local realPhysBone = hg.realPhysNum and hg.realPhysNum(rag, physBone) or physBone
		local phys = rag:GetPhysicsObjectNum(realPhysBone)
		if not IsValid(phys) then continue end
		if not rag.postureBase[physBone] then
			local _, localAng = WorldToLocal(phys:GetPos(), phys:GetAngles(), reference:GetPos(), reference:GetAngles())
			rag.postureBase[physBone] = localAng
		end

		local fade = getPostureFade(org, physBone)
		local _, baseAng = LocalToWorld(vector_origin, rag.postureBase[physBone], vector_origin, referenceAng)
		local _, localAng = LocalToWorld(vector_origin, ang, vector_origin, rag.postureBase[physBone])
		local _, targetAng = LocalToWorld(vector_origin, localAng, vector_origin, referenceAng)
		targetAng = LerpAngle(fade, baseAng, targetAng)
		hg.ShadowControl(rag, physBone, 0.01, targetAng, force * fade, damp, vector_origin, 0, 0)
	end
end

function hg.applySeizurePostureToRagdoll(rag, org, scale)
	if not IsValid(rag) then return end
	rag.organism = rag.organism or org
	processPosture(rag, "decorticate", scale or 1)
end

local function getPosturePlayer(owner, rag, org)
	if IsValid(owner) and owner:IsPlayer() then return owner end
	if IsValid(rag) and IsValid(rag.ply) and rag.ply:IsPlayer() then return rag.ply end
	org = org or {}
	if IsValid(org.owner) and org.owner:IsPlayer() then return org.owner end
end

local function printPostureDebug(owner, rag, org, postureType, severity, scale)
	if not postureType or org.postureDebugLastType == postureType then return end
	local developer = GetConVar("developer")
	if not developer or developer:GetInt() < 1 then return end

	local ply = getPosturePlayer(owner, rag, org)
	if not IsValid(ply) or not (ply:IsAdmin() or ply:IsBot()) then return end

	local time = CurTime()
	if time < (org.postureDebugNext or 0) then return end
	org.postureDebugNext = time + 1.5
	org.postureDebugLastType = postureType

	PrintMessage(HUD_PRINTTALK, string.format("[posture] %s triggered %s (severity %.2f, scale %.2f)", ply:Nick(), postureType, severity or 0, scale or 0))
end

local function printSpasmDebug(rag, stype, dur)
	local developer = GetConVar("developer")
	if not developer or developer:GetInt() < 1 then return end

	local org = IsValid(rag) and rag.organism
	local ply = getPosturePlayer(nil, rag, org)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	local time = CurTime()
	if time < (rag.spasmDebugNext or 0) then return end
	rag.spasmDebugNext = time + 1.5

	PrintMessage(HUD_PRINTTALK, string.format("[posture] %s triggered spasm:%s (duration %.1f)", ply:Nick(), stype or "unknown", dur or 0))
end

local spasmTypes = {{"posturing", 33}}

local function getRandomSpasm()
	local total = 0
	for i = 1, #spasmTypes do total = total + spasmTypes[i][2] end
	local roll, cur = math_random(1, total), 0
	for i = 1, #spasmTypes do
		cur = cur + spasmTypes[i][2]
		if roll <= cur then return spasmTypes[i][1] end
	end
	return "posturing"
end

hg.getRandomSpasm = getRandomSpasm

local function applySpasm(rag, stype, useFencing)
	if not IsValid(rag) then return end
	local org = rag.organism
	if not org then return end

	local dur = math_rand(posturingDur[1], posturingDur[2])
	if useFencing then
		startFencing(org, dur)
		return
	end

	local severity = math_max(getBrainFactor(org), DECORTICATE_START)
	local postureType = severity >= DECEREBRATE_START and "decerebrate" or "decorticate"
	local time = CurTime()
	org.postureSpasmType = stype or "posturing"
	org.postureSpasmStart = time
	org.postureSpasmEnd = time + dur
	org.postureSpasmDur = dur
	org.postureSpasmPostureType = postureType
	org.postureSpasmSeverity = severity
	org.postureSpasmScale = getPosturingIntensity(org)
	org.decorticateVariant = math_random(1, #decorticateOffsets)
	printSpasmDebug(rag, postureType, dur)
end

hg.applySpasm = applySpasm

local function clearSpasm(rag)
	local org = rag.organism
	if org then
		org.postureSpasmType, org.postureSpasmEnd, org.postureSpasmStart, org.postureSpasmDur, org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale = nil, nil, nil, nil, nil, nil, nil
	end
end

hook.Add("Org Clear", "BrainfuckClear", function(org)
	org.fencingStart, org.fencingEnd, org.fencingBrainDamage = nil, nil, nil
	org.fencingDur = nil
	org.postureSpasmType, org.postureSpasmEnd, org.postureSpasmStart, org.postureSpasmDur, org.postureSpasmPostureType, org.postureSpasmSeverity, org.postureSpasmScale = nil, nil, nil, nil, nil, nil, nil
	org.postureDeathStart, org.postureDeadDone, org.postureDeadDoneSeverity = nil, nil, nil
	org.postureDeathSeverity, org.postureDeathType = nil, nil
	org.postureDebugLastType, org.postureDebugNext = nil, nil
end)

hook.Add("RagdollDeath", "BrainfuckStart", function(ply, rag)
	timer.Simple(0.1, function()
		if not IsValid(ply) or not IsValid(rag) then return end
		local org = ply.organism
		if not org then return end
		org.postureDeathStart, org.postureDeadDone, org.postureDeadDoneSeverity = nil, nil, nil
		org.postureDeathSeverity, org.postureDeathType = nil, nil
		local lobeDamage = getBrainLobeSeverity(org)
		local hadBrainDamage = (org.brain and org.brain > 0) or lobeDamage > 0
		local hadHeadDamage = org.dmgstack and org.dmgstack[HITGROUP_HEAD] and (org.dmgstack[HITGROUP_HEAD][1] or 0) > 0
		local recentHeadshot = org.lastHeadshot and (CurTime() - org.lastHeadshot) < 1.5
		local recentClubHit = org.lastClubHit and (CurTime() - org.lastClubHit) < 1.5
		local recentBulletHit = org.lastBulletHit and (CurTime() - org.lastBulletHit) < 1.5
		local forceFencingPosturing = false
		local headshot = hadBrainDamage or hadHeadDamage or recentHeadshot
		local brainFactor = getBrainFactor(org)
		local chance = math_clamp(CHANCE + brainFactor * 0.6, 0, 1)
		if not headshot and not forceFencingPosturing and (rag.noHead or org.noHead or ply.noHead) then return end
		if (headshot and (recentHeadshot or hadHeadDamage or math_random() < chance)) or forceFencingPosturing then
			local stype = forceFencingPosturing and "posturing" or getRandomSpasm()
			applySpasm(rag, stype, forceFencingPosturing)
		end
	end)
end)

hook.Add("HomigradDamage", "BrainfuckFencing", function(ply, dmgInfo, hitgroup)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	local org = ply.organism
	if not org then return end
	if dmgInfo and dmgInfo.IsDamageType and dmgInfo:IsDamageType(DMG_CLUB) then org.lastClubHit = CurTime() end
	if dmgInfo and dmgInfo.IsDamageType and dmgInfo:IsDamageType(DMG_BULLET) then org.lastBulletHit = CurTime() end
	if hitgroup ~= HITGROUP_HEAD then return end
	org.lastHeadshot = CurTime()
	org.fencingBrainDamage = CurTime()
end)

hook.Add("CanControlFake", "BrainfuckFencing", function(ply, rag)
	local org = IsValid(rag) and rag.organism or IsValid(ply) and ply.organism
	if org and org.posturing then return false end
end)

hook.Add("Org Think", "BrainfuckThink", function(owner)
	if not IsValid(owner) then return end
	local deathRag = owner:IsPlayer() and owner:GetNWEntity("RagdollDeath")
	local rag = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or IsValid(deathRag) and deathRag or (owner:IsRagdoll() and owner or nil)
	local org = (IsValid(rag) and rag.organism) or owner.organism
	if not org then return end
	local time = CurTime()
	if org.postureThinkStamp == time then return end
	org.postureThinkStamp = time
	local postureType, postureSeverity, postureScale = getPostureState(org)
	local ply = IsValid(org.owner) and org.owner or owner
	deathRag = IsValid(ply) and ply:IsPlayer() and ply:GetNWEntity("RagdollDeath") or deathRag
	local dead = org.postureDeathStart ~= nil or deathRag == rag or owner:IsRagdoll() and (not IsValid(ply) or not ply:IsPlayer() or not ply:Alive())
	if dead and postureType then
		if not org.postureDeathStart or org.postureDeathType ~= postureType or (postureSeverity or 0) > (org.postureDeathSeverity or 0) + 0.05 then
			org.postureDeathStart = CurTime()
		end
		org.postureDeathSeverity, org.postureDeathType = postureSeverity or 0, postureType
	elseif not dead then
		org.postureDeathStart, org.postureDeathSeverity, org.postureDeathType, org.postureDeadActive = nil, nil, nil, nil
	end
	org.posturing = postureType ~= nil
	org.postureType = postureType
	org.postureSeverity = postureSeverity
	org.postureScale = postureScale
	org.postureDeadActive = dead and postureType ~= nil or nil
	if not postureType then
		org.postureDebugLastType = nil
		return
	end
	if not IsValid(rag) then return end
	printPostureDebug(owner, rag, org, postureType, postureSeverity, postureScale)
	processPosture(rag, postureType, postureScale)
end)
