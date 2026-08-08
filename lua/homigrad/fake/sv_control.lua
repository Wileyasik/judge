
local vecZero = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local shadowparams = {}

--[[
local ply = Entity(1)
local tbl = {}
for i = 0,ply:GetBoneCount()-1 do
	local physbone = ply:TranslateBoneToPhysBone(i)
	if physbone != -1 and not tbl[physbone] then
		tbl[physbone] = ply:GetBoneName(i)
	end
end
for i,bon in ipairs(tbl) do
	print("["..i.."] = "..'"'..bon..'"'..",")
end
]]

local defaultBones = {
	[0] = "ValveBiped.Bip01_Pelvis",
	[1] = "ValveBiped.Bip01_Spine2",
	[2] = "ValveBiped.Bip01_R_UpperArm",
	[3] = "ValveBiped.Bip01_L_UpperArm",
	[4] = "ValveBiped.Bip01_L_Forearm",
	[5] = "ValveBiped.Bip01_L_Hand",
	[6] = "ValveBiped.Bip01_R_Forearm",
	[7] = "ValveBiped.Bip01_R_Hand",
	[8] = "ValveBiped.Bip01_R_Thigh",
	[9] = "ValveBiped.Bip01_R_Calf",
	[10] = "ValveBiped.Bip01_Head1",
	[11] = "ValveBiped.Bip01_L_Thigh",
	[12] = "ValveBiped.Bip01_L_Calf",
	[13] = "ValveBiped.Bip01_L_Foot",
	[14] = "ValveBiped.Bip01_R_Foot",
}

local right_arm = {
	["ValveBiped.Bip01_R_UpperArm"] = true,
	["ValveBiped.Bip01_R_Forearm"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
}

local left_arm = {
	["ValveBiped.Bip01_L_UpperArm"] = true,
	["ValveBiped.Bip01_L_Forearm"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
}

local wound_hold_hand_offset = 4
local wound_hold_forearm_offset = 8
local wound_hold_upperarm_offset = 14
local wound_hold_reach_speed = 55
local wound_hold_reach_damp = 14
local wound_hold_arm_speed = 18
local wound_hold_arm_damp = 12
local realPhysNum

local wound_hold_arterial_priority_mul = 14
local wound_hold_arteria_offset = Vector(2, -2.85, 0)
local wound_hold_spineartery_offset = Vector(1.5, 0, 4)
local wound_hold_larmartery_offset = Vector(0.5, 0, 1.5)
local wound_hold_rarmartery_offset = Vector(0.5, 0, 1.5)
local wound_hold_llegartery_offset = Vector(1, 0, 2.5)
local wound_hold_rlegartery_offset = Vector(1, 0, 2.5)
local wound_hold_larmstump_offset = Vector(2, 0, 2.5)
local wound_hold_rarmstump_offset = Vector(2, 0, 2.5)
local wound_hold_llegstump_offset = Vector(2.5, 0, 4)
local wound_hold_rlegstump_offset = Vector(2.5, 0, 4)
local stumpArteries = {
	["ValveBiped.Bip01_L_Forearmartery"] = "larm",
	["ValveBiped.Bip01_R_Forearmartery"] = "rarm",
	["ValveBiped.Bip01_L_Calfartery"] = "lleg",
	["ValveBiped.Bip01_R_Calfartery"] = "rleg"
}

local function setManualWoundHold(ply, org, active, wound, hands, useRight, arterial)
	active = active and wound and true or false
	org.manualHoldWound = active
	org.manualHoldWoundTarget = active and wound or nil
	org.manualHoldWoundHands = active and (hands or 0) or 0
	org.manualHoldWoundUseRight = active and useRight or false
	org.manualHoldWoundArterial = active and arterial or false

	if ply._manualHoldWound ~= active then
		ply._manualHoldWound = active
		ply:SetNWBool("hg_hold_wound_manual", active)
	end

	local twoHanded = active and (hands or 0) >= 2
	if ply._manualHoldWoundTwoHand ~= twoHanded then
		ply._manualHoldWoundTwoHand = twoHanded
		ply:SetNWBool("hg_hold_wound_twohand", twoHanded)
	end

	local rightHandBusy = active and useRight or false
	if ply._manualHoldWoundRight ~= rightHandBusy then
		ply._manualHoldWoundRight = rightHandBusy
		ply:SetNWBool("hg_hold_wound_right", rightHandBusy)
	end
end

local function getHoldWoundPos(ragdoll, wound)
	if not wound then return end

	local bone = ragdoll:LookupBone(wound[4])
	if not bone then return end

	local bonePos, boneAng = ragdoll:GetBonePosition(bone)
	if not bonePos or not boneAng then return end

	local pos = LocalToWorld(wound[2], wound[3], bonePos, boneAng)
	local artery = wound[7]

	if artery == "arteria" then
		return pos + boneAng:Forward() * wound_hold_arteria_offset[1] + boneAng:Right() * wound_hold_arteria_offset[2] + boneAng:Up() * wound_hold_arteria_offset[3]
	elseif artery == "spineartery" then
		return pos + boneAng:Forward() * wound_hold_spineartery_offset[1] + boneAng:Right() * wound_hold_spineartery_offset[2] + boneAng:Up() * wound_hold_spineartery_offset[3]
	elseif artery == "larmartery" then
		return pos + boneAng:Forward() * wound_hold_larmartery_offset[1] + boneAng:Right() * wound_hold_larmartery_offset[2] + boneAng:Up() * wound_hold_larmartery_offset[3]
	elseif artery == "rarmartery" then
		return pos + boneAng:Forward() * wound_hold_rarmartery_offset[1] + boneAng:Right() * wound_hold_rarmartery_offset[2] + boneAng:Up() * wound_hold_rarmartery_offset[3]
	elseif artery == "llegartery" then
		return pos + boneAng:Forward() * wound_hold_llegartery_offset[1] + boneAng:Right() * wound_hold_llegartery_offset[2] + boneAng:Up() * wound_hold_llegartery_offset[3]
	elseif artery == "rlegartery" then
		return pos + boneAng:Forward() * wound_hold_rlegartery_offset[1] + boneAng:Right() * wound_hold_rlegartery_offset[2] + boneAng:Up() * wound_hold_rlegartery_offset[3]
	elseif artery == "ValveBiped.Bip01_L_Forearmartery" then
		return pos + boneAng:Forward() * wound_hold_larmstump_offset[1] + boneAng:Right() * wound_hold_larmstump_offset[2] + boneAng:Up() * wound_hold_larmstump_offset[3]
	elseif artery == "ValveBiped.Bip01_R_Forearmartery" then
		return pos + boneAng:Forward() * wound_hold_rarmstump_offset[1] + boneAng:Right() * wound_hold_rarmstump_offset[2] + boneAng:Up() * wound_hold_rarmstump_offset[3]
	elseif artery == "ValveBiped.Bip01_L_Calfartery" then
		return pos + boneAng:Forward() * wound_hold_llegstump_offset[1] + boneAng:Right() * wound_hold_llegstump_offset[2] + boneAng:Up() * wound_hold_llegstump_offset[3]
	elseif artery == "ValveBiped.Bip01_R_Calfartery" then
		return pos + boneAng:Forward() * wound_hold_rlegstump_offset[1] + boneAng:Right() * wound_hold_rlegstump_offset[2] + boneAng:Up() * wound_hold_rlegstump_offset[3]
	end

	return pos
end

local function isStumpArterialWound(wound)
	return wound and stumpArteries[wound[7]] != nil
end

local function getHoldTarget(pos, phys, offset)
	if not pos or not IsValid(phys) then return pos end

	local dir = pos - phys:GetPos()
	if dir:LengthSqr() <= 0.001 then return pos end

	return pos - dir:GetNormalized() * offset
end

local function getWoundScore(ragdoll, spinePos, spineAng, wound, priorityMul)
	local pos = getHoldWoundPos(ragdoll, wound)
	if not pos then return -math.huge end

	local dir = pos - spinePos
	if dir:LengthSqr() <= 0.001 then return (wound[1] or 0) * (priorityMul or 1) end

	local dot = dir:GetNormalized():Dot(spineAng:Forward())
	return dot * 100 + (wound[1] or 0) * (priorityMul or 1), dot
end

local function chooseFrontWound(ragdoll, wounds, preferred, priorityMul)
	if not IsValid(ragdoll) or not wounds or table.IsEmpty(wounds) then return preferred end

	local spine = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))
	if not IsValid(spine) then return preferred end

	local spinePos = spine:GetPos()
	local spineAng = spine:GetAngles()
	local best, bestScore

	for i, wound in pairs(wounds) do
		local score, dot = getWoundScore(ragdoll, spinePos, spineAng, wound, priorityMul)
		if dot and dot > -0.15 and (not bestScore or score > bestScore) then
			best = wound
			bestScore = score
		end
	end

	if best then return best end

	best = preferred
	bestScore = preferred and select(1, getWoundScore(ragdoll, spinePos, spineAng, preferred, priorityMul)) or nil

	for i, wound in pairs(wounds) do
		local score = select(1, getWoundScore(ragdoll, spinePos, spineAng, wound, priorityMul))
		if not bestScore or score > bestScore then
			best = wound
			bestScore = score
		end
	end

	return best
end

local function getHoldWound(org, ragdoll)
	if not org then return end

	local wound = chooseFrontWound(ragdoll, org.wounds, org.holdWoundArterial and nil or org.holdWound, 1)
	local arterial = chooseFrontWound(ragdoll, org.arterialwounds, org.holdWoundArterial and org.holdWound or nil, wound_hold_arterial_priority_mul)

	if wound and arterial then
		local spine = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))
		if IsValid(spine) then
			local spinePos = spine:GetPos()
			local spineAng = spine:GetAngles()
			local woundScore = select(1, getWoundScore(ragdoll, spinePos, spineAng, wound, 1))
			local arterialScore = select(1, getWoundScore(ragdoll, spinePos, spineAng, arterial, wound_hold_arterial_priority_mul))
			if arterialScore >= woundScore then
				return arterial, true
			end
		end
	end

	return arterial and arterial or wound, arterial ~= nil
end

hg.cachedmodels = hg.cachedmodels or {}

realPhysNum = function(ragdoll, physNumber)
	local bone = defaultBones[physNumber]
	local model = ragdoll:GetModel()
	
	if hg.cachedmodels[model] and hg.cachedmodels[model][bone] then
		return hg.cachedmodels[model][bone]
	else
		hg.cacheModel(ragdoll)
		
		return hg.cachedmodels[model] and hg.cachedmodels[model][bone] or 0
	end
end


hg.realPhysNum = realPhysNum
local oldtime
local function isFloppyPhys(ragdoll, physNumber, alreadyReal)
	if not IsValid(ragdoll) or not ragdoll.hg_floppy_bones then return false end

	local real = alreadyReal and physNumber or (realPhysNum(ragdoll, physNumber) or 0)
	local bone = ragdoll:TranslatePhysBoneToBone(real)
	if bone < 0 then return false end

	return ragdoll.hg_floppy_bones[ragdoll:GetBoneName(bone)] == true
end

function hg.ShadowControl(ragdoll, physNumber, ss, ang, maxang, maxangdamp, pos, maxspeed, maxspeeddamp)
	physNumber = realPhysNum(ragdoll, physNumber) or 0
	local phys = ragdoll:GetPhysicsObjectNum(physNumber)
	if not IsValid(phys) then return end
	if isFloppyPhys(ragdoll, physNumber, true) then
		phys:Wake()
		return false
	end

	shadowparams.secondstoarrive = ss
	shadowparams.angle = ang
	shadowparams.maxangular = maxang and maxang * (ragdoll.power or 1)-- * (hg.IdealMassPlayer[physNumber] and hg.IdealMassPlayer[physNumber] / phys:GetMass() or 0)
	shadowparams.maxangulardamp = maxangdamp
	shadowparams.pos = pos
	shadowparams.maxspeed = maxspeed and maxspeed * (ragdoll.power or 1)
	shadowparams.maxspeeddamp = maxspeeddamp
	shadowparams.dampfactor = 0.9

	phys:Wake()
	phys:ComputeShadowControl(shadowparams)
end

local shadowControl = hg.ShadowControl

hook.Add("Fake", "Contorl", function(ply, ragdoll)
	ragdoll.cooldownLH = 0
	ragdoll.cooldownRH = 0
	if ply.otrubCollapseStart then
		ragdoll.otrubCollapseStart = ply.otrubCollapseStart
	end
	
	hg.ClearRagdollSlideState(ragdoll)
	
	local plyVel = ply:GetVelocity()
	ragdoll._slideEntrySpeed = Vector(plyVel.x, plyVel.y, 0):Length()
	ragdoll._slideEntryDir = Vector(plyVel.x, plyVel.y, 0):GetNormalized()
	ragdoll._slideEntryTime = CurTime()
end)

hook.Add("HG_OnOtrub", "OtrubCollapseStart", function(ply)
	ply.otrubCollapseStart = CurTime()
	local ragdoll = ply.FakeRagdoll
	if IsValid(ragdoll) then
		ragdoll.otrubCollapseStart = CurTime()
	end
end)

hook.Add("HG_OnWakeOtrub", "OtrubCollapseEnd", function(ply)
	ply.otrubCollapseStart = nil
	local ragdoll = ply.FakeRagdoll
	if IsValid(ragdoll) then
		ragdoll.otrubCollapseStart = nil
	end
end)

hook.Add("Player Think", "HG_ClearManualWoundHold", function(ply)
	if IsValid(ply.FakeRagdoll) then return end

	if ply._manualHoldWound then
		ply._manualHoldWound = false
		ply:SetNWBool("hg_hold_wound_manual", false)
	end
	if ply._manualHoldWoundTwoHand then
		ply._manualHoldWoundTwoHand = false
		ply:SetNWBool("hg_hold_wound_twohand", false)
	end
	if ply._manualHoldWoundRight then
		ply._manualHoldWoundRight = false
		ply:SetNWBool("hg_hold_wound_right", false)
	end

	if ply.organism then
		ply.organism.manualHoldWound = false
		ply.organism.manualHoldWoundTarget = nil
		ply.organism.manualHoldWoundHands = 0
		ply.organism.manualHoldWoundUseRight = false
		ply.organism.manualHoldWoundArterial = false
	end
end)

local function triggerOtrubCollapse(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if ply.otrubCollapseStart and CurTime() - ply.otrubCollapseStart < 1.5 then return end
	ply.otrubCollapseStart = CurTime()
	local ragdoll = ply.FakeRagdoll
	if IsValid(ragdoll) then
		ragdoll.otrubCollapseStart = CurTime()
	end
end

hook.Add("EntityTakeDamage", "OtrubCollapseDmg", function(ent, dmgInfo)
	if not IsValid(ent) or not ent:IsPlayer() then return end
	if dmgInfo:IsDamageType(DMG_CRUSH + DMG_FALL + DMG_CLUB) and ent:Alive() then
		triggerOtrubCollapse(ent)
	end
end)

local att, trace, ent

local tr = {
	filter = {}
}

local hg_fake_stamina = CreateConVar("hg_fake_stamina", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Enables stamina when ragdolled", 0, 1)

local util_TraceLine, util_TraceHull = util.TraceLine, util.TraceHull
local game_GetWorld = game.GetWorld
local ang, ang2, ang3 = Angle(0, 0, 0), Angle(0, 0, 0),  Angle(0, 0, 0)
local spine, time, rupper, lupper, rforearm, lforearm, rhand, lhand

local height = Vector(0, 0, 72) --28 eye level if crouched
local util_PointContents, bit_band, hook_Run = util.PointContents, bit.band, hook.Run
local forceArm = 600
local forceArm_dump = 450

local models_female = {
	["models/player/group01/female_01.mdl"] = true,
	["models/player/group01/female_02.mdl"] = true,
	["models/player/group01/female_03.mdl"] = true,
	["models/player/group01/female_04.mdl"] = true,
	["models/player/group01/female_05.mdl"] = true,
	["models/player/group01/female_06.mdl"] = true,
	["models/player/group03/female_01.mdl"] = true,
	["models/player/group03/female_02.mdl"] = true,
	["models/player/group03/female_03.mdl"] = true,
	["models/player/group03/female_04.mdl"] = true,
	["models/player/group03/female_05.mdl"] = true,
	["models/player/group03/police_fem.mdl"] = true
}

local vector_zero = Vector(0,0,0)
local vector_usehull = Vector(6, 6, 6)
local fall_cover_mins = Vector(-6, -6, -6)
local fall_cover_maxs = Vector(6, 6, 6)
local fall_cover_offsets = {
	["male09"] = {
		[2] = {ang = Angle(-25.820, -105.490, -100.210)},
		[3] = {ang = Angle(-33.460, -72.240, -70.380)},
		[4] = {ang = Angle(-10.640, 145.920, -34.760)},
		[5] = {ang = Angle(12.380, 127.140, 75.320)},
		[6] = {ang = Angle(-19.720, -33.680, -171.940)},
		[7] = {ang = Angle(-1.960, 35.170, 116.580)}
	},
	["female06"] = {
		[2] = {ang = Angle(-22.610, -99.190, -98.620)},
		[3] = {ang = Angle(-29.870, -78.830, -71.760)},
		[4] = {ang = Angle(-11.430, 139.440, -35.610)},
		[5] = {ang = Angle(11.620, 117.010, 78.940)},
		[6] = {ang = Angle(-20.210, -25.920, -171.180)},
		[7] = {ang = Angle(-4.130, 45.020, 113.260)}
	}
}
local slideFrictionBones = {13, 14, 12, 9}

local hg_shitty_fake = CreateConVar("hg_shitty_fake", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "enable shitty fake", 0, 1)

local speedupbones = {
	["ValveBiped.Bip01_L_Foot"] = true,
	["ValveBiped.Bip01_R_Foot"] = true,
}

local FAKE_LEG_KICK_DAMAGE_MUL = 0.65
local FAKE_LEG_KICK_RAG_FORCE_MUL = 155
local FAKE_LEG_KICK_PROP_FORCE_MUL = 90
local FAKE_LEG_KICK_PLAYER_PUSH = 85
local FAKE_LEG_KICK_FAKE_CHANCE = 0.65
local FAKE_LEG_KICK_TRACE_RANGE = 28
local FAKE_LEG_KICK_TRACE_SIZE = Vector(5, 5, 5)
local FAKE_LEG_KICK_SEGMENT_SIZE = Vector(6, 6, 6)
local FAKE_LEG_KICK_EXTEND_TIME = 0.35
local FAKE_LEG_KICK_VIEWPUNCH = Angle(3, 0, 0)
local FAKE_LEG_KICK_CHARGE_FORWARD_OFFSET = -90
local FAKE_LEG_KICK_CHARGE_THIGH_RIGHT_OFFSET = -22
local FAKE_LEG_KICK_CHARGE_CALF_RIGHT_OFFSET = -10
local FAKE_LEG_KICK_CHARGE_CALF_UP_OFFSET = 220
local FAKE_LEG_KICK_EXTEND_THIGH_UP_OFFSET = 46
local FAKE_LEG_KICK_SHADOW_TIME = 0.001
local FAKE_LEG_KICK_SHADOW_ANG = 170
local FAKE_LEG_KICK_SHADOW_DAMP = 60

local vecfive = Vector(5,5,5)

local function restoreSlideMaterials(ragdoll)
	if not ragdoll._slideMaterialSet then return end

	for _, fNum in ipairs(slideFrictionBones) do
		local phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, fNum))
		if IsValid(phys) and ragdoll._origMaterials and ragdoll._origMaterials[fNum] then
			phys:SetMaterial(ragdoll._origMaterials[fNum])
		end
	end

	ragdoll._origMaterials = nil
	ragdoll._slideMaterialSet = false
end

local function clearSlideState(ragdoll, cooldown)
	restoreSlideMaterials(ragdoll)
	ragdoll._slideActive = false
	ragdoll._slideStartTime = nil
	ragdoll._slideDir = nil
	ragdoll.isSliding = false

	if cooldown then
		ragdoll._slideCooldown = CurTime() + cooldown
	end
end

function hg.ClearRagdollSlideState(ragdoll)
	if not IsValid(ragdoll) then return end
	clearSlideState(ragdoll)
	ragdoll._slideCooldown = nil
	ragdoll.isDropkicking = false
end

local player_GetHumans = player.GetHumans

local function traceFakeLegSegment(ply, ragdoll, startPos, endPos, size)
	return util.TraceHull({
		start = startPos,
		endpos = endPos,
		filter = {ply, ragdoll, hg.GetCurrentCharacter(ply)},
		maxs = size,
		mins = -size,
		mask = MASK_SOLID
	})
end

local function getFakeLegKickTrace(ply, ragdoll, dir)
	local thigh = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 8))
	local calf = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 9))
	local foot = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 14))
	if not IsValid(thigh) or not IsValid(calf) or not IsValid(foot) then return end

	local thighPos = thigh:GetPos()
	local calfPos = calf:GetPos()
	local footPos = foot:GetPos()
	local traces = {
		traceFakeLegSegment(ply, ragdoll, thighPos, calfPos, FAKE_LEG_KICK_SEGMENT_SIZE),
		traceFakeLegSegment(ply, ragdoll, calfPos, footPos, FAKE_LEG_KICK_SEGMENT_SIZE),
		traceFakeLegSegment(ply, ragdoll, footPos, footPos + dir * FAKE_LEG_KICK_TRACE_RANGE, FAKE_LEG_KICK_TRACE_SIZE)
	}

	for i = 1, #traces do
		local tr = traces[i]
		if tr.Hit and IsValid(tr.Entity) then return tr, footPos end
	end

	return traces[#traces], footPos
end

local function fakeLegKickHit(ply, ragdoll, state)
	local org = ply.organism
	if not org then return end

	local tr = getFakeLegKickTrace(ply, ragdoll, state.dir)
	if not tr then return end

	if org.rleg == 1 or org.rlegdislocation then
		org.painadd = org.painadd + 20
	end

	ply:EmitSound("player/shove_0" .. math.random(1,5) .. ".wav", 65)

	if tr.Hit then
		if org.rleg == 1 or org.rlegdislocation then
			org.painadd = org.painadd + 20
		end

		ply:EmitSound("weapons/melee/blunt_light" .. math.random(1,8) .. ".wav")
	end

	local ent = tr.Entity
	if not IsValid(ent) or ent == ply or ent == ragdoll or ent == hg.GetCurrentCharacter(ply) then return end

	local phys = ent:GetPhysicsObjectNum(tr.PhysicsBone or 0)
	if !ent:IsPlayer() and not IsValid(phys) then return end

	local dmginfo = DamageInfo()
	dmginfo:SetAttacker(ply)
	dmginfo:SetInflictor(IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() or ply)
	dmginfo:SetDamage(state.dmg)
	dmginfo:SetDamageForce(state.dir * state.dmg * FAKE_LEG_KICK_RAG_FORCE_MUL)
	dmginfo:SetDamageType((ent:GetClass() == "func_breakable_surf") and DMG_SLASH or DMG_CLUB)
	dmginfo:SetDamagePosition(tr.HitPos)

	PenetrationGlobal = 1
	MaxPenLenGlobal = 1
	if hg.AddForceRag then hg.AddForceRag(ent, tr.PhysicsBone or 0, state.dir * state.dmg * FAKE_LEG_KICK_RAG_FORCE_MUL, 0.25) end
	ent:TakeDamageInfo(dmginfo)

	if IsValid(phys) then
		phys:ApplyForceOffset(state.dir * state.dmg * FAKE_LEG_KICK_PROP_FORCE_MUL, tr.HitPos)
	end

	if ent:IsPlayer() or ent:GetClass() == "prop_ragdoll" then
		ent:EmitSound("physics/body/body_medium_impact_hard" .. math.random(6) .. ".wav", 60, math.random(85, 105), 0.6)
	end

	if ent:IsPlayer() then
		if math.Rand(0, 1) <= FAKE_LEG_KICK_FAKE_CHANCE then
			timer.Simple(0, function()
				if IsValid(ent) then hg.Fake(ent) end
			end)
		end

		ent:SetVelocity(state.dir * FAKE_LEG_KICK_PLAYER_PUSH)
	end

	if hgIsDoor and hgIsDoor(ent) and !ent:GetNoDraw() then
		ent.HP = ent.HP or 200
		ent.HP = ent.HP - state.dmg * (tr.MatType == MAT_METAL and 1 or 2)
		ent:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(1,4) .. ".wav")
		if ent.HP <= 0 and hgBlastThatDoor then hgBlastThatDoor(ent, state.dir * 125) end
	end
end

function hg.FakeLegAttack(ply)
	local ragdoll = ply.FakeRagdoll
	local org = ply.organism
	if not ply:Alive() or not IsValid(ragdoll) or not org or not org.canmove then return end
	if ply.InLegKick and ply.InLegKick > CurTime() then return end
	if ply:GetNWFloat("InLegKick", 0) > CurTime() then return end
	if hook.Run("PlayerCanLegAttack", ply) == false then return end

	ply:EmitSound("player/clothes_generic_foley_0" .. math.random(1,5) .. ".wav", 65)
	org.stamina.subadd = org.stamina.subadd + 20 / (org.superfighter and 2 or 1)

	local speedmul = (2 - (org.stamina[1] / org.stamina.max))
	local speed = 1.5 * speedmul
	local animstopAdjust = 0.3 * speedmul
	local duration = speed - animstopAdjust
	local dmg = 10 * (2 - speedmul)
	dmg = dmg * (ply:IsBerserk() and org.berserk * 5 or 1)
	dmg = dmg * (org.legstrength or 1)
	dmg = dmg * FAKE_LEG_KICK_DAMAGE_MUL

	local ang = ply:EyeAngles()
	ang[1] = 0

	hook.Run("HomigradLegKick", ply)
	ply.InLegKick = CurTime() + duration
	ply:SetNWFloat("InLegKick", CurTime() + duration)
	ragdoll.fakeLegKick = {
		start = CurTime(),
		finish = CurTime() + duration,
		hitTime = CurTime() + duration * 0.55,
		dmg = dmg,
		dir = ang:Forward(),
		hit = false
	}
end

hook.Add("Think", "Fake", function()
	hg.humans_cached = player_GetHumans()

	//for ply, ragdoll in pairs(hg.ragdollFake) do
	for i, ply in player.Iterator() do
		local ragdoll = hg.ragdollFake[ply]//ply.FakeRagdoll
		if not IsValid(ragdoll) then
			//hg.ragdollFake[ply] = nil
			continue
		end

		local torso = ragdoll:LookupBone("ValveBiped.Bip01_Spine2")
		if torso then
			local torsopos, ang = ragdoll:GetBonePosition(torso)

			if IsValid(ragdoll.bull) and (ragdoll.bull.lastposset or 0) < CurTime() then
				ragdoll.bull.lastposset = CurTime() + 0.5
				
				ragdoll.bull:SetPos(torsopos + vector_up * 5)
				--ragdoll.bull:Remove()
				--if ply.FakeRagdoll == ragdoll then ply:SetPos(ragdoll:GetPos()) end
			end
		end

		if hook_Run("CanControlFake", ply, ragdoll) ~= nil then
			ply.lastFake = 0
			//ply:SetNetVar("lastFake",0)
			continue
		end

		ragdoll.dtime = (SysTime() - (ragdoll.lastCallTime or SysTime())) * game.GetTimeScale()
		ragdoll.lastCallTime = SysTime()

		local vellen = ragdoll:GetPhysicsObject():GetVelocity():Length()

		local org = ply.organism
		local wep = ply:GetActiveWeapon()
		local floppyBones = ragdoll.hg_floppy_bones or org.fake_floppy_bones
		local leftArmFloppy = floppyBones and (floppyBones["ValveBiped.Bip01_L_UpperArm"] or floppyBones["ValveBiped.Bip01_L_Forearm"])
		local rightArmFloppy = floppyBones and (floppyBones["ValveBiped.Bip01_R_UpperArm"] or floppyBones["ValveBiped.Bip01_R_Forearm"])

		if leftArmFloppy and IsValid(ragdoll.ConsLH) then
			ragdoll.ConsLH:Remove()
			ragdoll.ConsLH = nil
		end

		if rightArmFloppy and IsValid(ragdoll.ConsRH) then
			ragdoll.ConsRH:Remove()
			ragdoll.ConsRH = nil
		end

		local tr = {}
		tr.start = ply:GetPos()
		tr.endpos = ply:GetPos() - vector_up * 10
		tr.filter = {ply,ragdoll}
		local tracehuy = util.TraceLine(tr)
		
		local power = org.pain and ((org.pain > 50 or org.blood < 2900 or org.o2[1] < 5) and 0.3) or ((org.pain > 20 or org.blood < 4200 or org.o2[1] < 10) and 0.5) or 1
		power = power * org.consciousness
		ragdoll.power = power

		local inmove = false
		
		local ragdollcombat = hg.RagdollCombatInUse(ply)
		if !ragdollcombat and ragdoll == ply.FakeRagdoll then
			hg.SetFreemove(ply, false)
		end

		if (org.lightstun < CurTime()) and (tracehuy.Hit or ply.FakeRagdoll ~= ragdoll) and org.spine1 < hg.organism.fake_spine1 and org.canmove and ((ply.lastFake and (ply.lastFake) > CurTime()) or ply.FakeRagdoll ~= ragdoll) and !ply.jumpedfake then
			local power = 1
			inmove = true
			
			local ragbonecount = ragdoll:GetPhysicsObjectCount()
			for i = 0, ragbonecount - 1 do
				local bone = ragdoll:TranslatePhysBoneToBone(i)
				local bonepos, boneang = ply:GetBonePosition(bone)
				if bonepos and boneang then
					local physobj = ragdoll:GetPhysicsObjectNum(i)
					local mass = physobj:GetMass() / 5
					
					local name = ragdoll:GetBoneName(bone)

					if IsValid(physobj) then
						local bone_impulse = ply.HitBones and ply.HitBones[name] or CurTime()
						local amt_impulse = (2 - math.Clamp(bone_impulse - CurTime(),0,2)) / 2
						
						local p = {}
						p.secondstoarrive = 0.01
						p.pos = bonepos
						p.angle = boneang
						p.maxangular = 250 * (ragdollcombat and 1 or 0.25) * mass * power * amt_impulse
						p.maxangulardamp = 100 * (ragdollcombat and 1 or 0.75) * mass * power * amt_impulse
						p.maxspeed = 250 * (ragdollcombat and 1 or 0.25) * mass * power * amt_impulse
						p.maxspeeddamp = 100 * (ragdollcombat and 1 or 0.75) * mass * amt_impulse
						p.teleportdistance = 0

						physobj:Wake()
						
						if hg.RagdollCombatInUse(ply) and ply:KeyDown(IN_JUMP) then
							if !ply.jumpedfake then
								ply.jumpedfake = true

								physobj:ApplyForceCenter(vector_up * 15000)
							end
						else
							ply.jumpedfake = nil
							if not isFloppyPhys(ragdoll, i, true) then
								physobj:ComputeShadowControl(p)
							end
						end
					end
				end
			end

			if ply.FakeRagdoll ~= ragdoll then continue end
		elseif ply:Alive() then			
			local pos = ragdoll:GetBoneMatrix(ragdoll:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation()		
			
			if !ply:KeyDown(IN_JUMP) then
				ply.jumpedfake = nil
			end

			if ragdollcombat then
				hg.SetFreemove(ply, true)
			end

			if ply:InVehicle() then
				ply:SetPos(vector_origin)
			else
				ply:SetPos(pos)
				--ply:SetVelocity(vector_origin)
			end
		end

		local angles = ply:EyeAngles()
		local att = ragdoll:GetAttachment(ragdoll:LookupAttachment("eyes"))
		--ragdoll:SetFlexWeight(9, 0)
		local vecpos = angles:Forward() * 10000
		local dist = (angles:Forward() * 10000):Distance(vecpos)
		local distmod = math.Clamp(1 - (dist / 20000), 0.35, 1)
		local lookat = LerpVector(distmod, att.Ang:Forward() * 10000, vecpos)
		local LocalPos, LocalAng = WorldToLocal(lookat, angles, att.Pos, att.Ang)
		LocalAng[1] = math.Clamp(LocalAng[1], -30, 30)
		LocalAng[2] = math.Clamp(LocalAng[2], -30, 30)
		
		if ragdoll.organism and not ragdoll.organism.otrub then
			ragdoll.LastAng = LocalAng
		else
			LocalAng = ragdoll.LastAng or LocalAng
		end

		ragdoll:SetEyeTarget(LocalAng:Forward() * 10000)

		local model = ragdoll:GetModel()
		ang:Set(angles)
		
		if ishgweapon(wep) and !wep:IsPistolHoldType() then
			ang:RotateAroundAxis(ang:Up(), 30)
		end

		local fakeKick = ragdoll.fakeLegKick
		local fakeKickActive = fakeKick and CurTime() < fakeKick.finish and org.canmove

		if (!ply:InVehicle() && (ply:KeyDown(IN_USE) || ((ishgweapon(wep)) && (ply:KeyDown(IN_ATTACK2) || (wep.IsResting and wep:IsResting()))) || (wep.ismelee && (ply:KeyDown(IN_ATTACK2) || ply:KeyDown(IN_ATTACK))))) || (ply:InVehicle() && not ply:KeyDown(IN_USE)) or ragdollcombat then
			if org.canmove and (!((ply:KeyDown(IN_MOVELEFT) or ply:KeyDown(IN_MOVERIGHT)) and ragdoll:IsOnFire()) or ply:InVehicle()) then
				local angl = angZero
				angl:Set(ang)
				if ply:KeyDown(IN_DUCK) and not fakeKickActive then
					angl:RotateAroundAxis(angl:Right(), ishgweapon(wep) and 30 or 30)
				end
				--angl:RotateAroundAxis(angl:Right(), -90)
				angl:RotateAroundAxis(angl:Forward(), 90)
				angl:RotateAroundAxis(angl:Up(), 90)
				angl:RotateAroundAxis(angl:Forward(), ishgweapon(wep) and not wep:IsPistolHoldType() and 120 or 180)
				angl:RotateAroundAxis(angl:Up(), ishgweapon(wep) and wep:IsResting() and 50 - ply:EyeAngles().p or 0)
				shadowControl(ragdoll, 1, 0.1, angl, 110, 20)
			end

			if org.canmovehead then
				--ang2 = Angle(-90,ang[2] - 90,0)
				local angl = angZero
				angl:Set(ang)
				if ply:KeyDown(IN_DUCK) and not fakeKickActive then
					angl:RotateAroundAxis(angl:Right(), -90)
				end
				angl:RotateAroundAxis(angl:Forward(), 90)
				angl:RotateAroundAxis(angl:Up(), 90)
				shadowControl(ragdoll, 10, 0.1, angl, 100, 60) --,Vector(0,0,0),1000,1000)	
			end
		end

		spine = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,1))
		rupper = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,2))
		lupper = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,3))
		lforearm = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,4))
		rhand = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7))
		rforearm = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,6))
		lhand = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5))
		ang = spine:GetAngles()
		local fallCoverActive = false
		if org.alive and org.canmove and IsValid(spine) then
			local vel = ragdoll:GetVelocity()
			local fallSpeed = -vel.z
			fallCoverActive = vel:LengthSqr() > 1000000

			if not fallCoverActive and fallSpeed > 350 then
				local fallTr = util.TraceHull({
					start = spine:GetPos(),
					endpos = spine:GetPos() - vector_up * fallSpeed,
					mins = fall_cover_mins,
					maxs = fall_cover_maxs,
					filter = {ply, ragdoll},
					mask = MASK_SOLID,
				})

				if fallTr.Hit and not fallTr.HitSky and fallTr.Fraction <= 1 then
					fallCoverActive = true
				end
			end

			if fallCoverActive then
				inmove = true
				if IsValid(ragdoll.ConsLH) then ragdoll.ConsLH:Remove() ragdoll.ConsLH = nil end
				if IsValid(ragdoll.ConsRH) then ragdoll.ConsRH:Remove() ragdoll.ConsRH = nil end

				local reference = ragdoll:GetPhysicsObjectNum(0)
				if IsValid(reference) then
					local offsets = string.find(string.lower(ragdoll:GetModel() or ""), "female", 1, true) and fall_cover_offsets.female06 or fall_cover_offsets.male09
					local referenceAng = reference:GetAngles()
					local coverForce = 1600 * ragdoll.power
					local coverDamp = 900 * ragdoll.power

					for physBone, offset in pairs(offsets) do
						local canUseArm = ((physBone == 2 or physBone == 6 or physBone == 7) and not org.rarmamputated) or ((physBone == 3 or physBone == 4 or physBone == 5) and not org.larmamputated)
						if canUseArm then
							local _, targetAng = LocalToWorld(vector_origin, offset.ang, vector_origin, referenceAng)
							shadowControl(ragdoll, physBone, 0.04, targetAng, coverForce, coverDamp, vector_origin, 0, 0)
						end
					end
				end
			end
		end
		local holdWound, holdWoundArterial = getHoldWound(org, ragdoll)
		local wantsManualHold = (holdWound and org.canmove and hg.KeyDown(ply, IN_USE) and hg.KeyDown(ply, IN_JUMP)) or (org.neckslit and not org.otrub and holdWoundArterial and org.canmove)
		local canHoldLeft = IsValid(lupper) and IsValid(lforearm) and IsValid(lhand) and not org.larmamputated and not org.larmupamputated
		local canHoldRight = IsValid(rupper) and IsValid(rforearm) and IsValid(rhand) and not org.rarmamputated and not org.rarmupamputated
		local hasBothArms = canHoldLeft and canHoldRight
		local canUseTwoHandHold = not IsValid(wep) or wep:GetClass() == "weapon_hands_sh"
		local manualUseLeft = false
		local manualUseRight = false

		if wantsManualHold and hasBothArms then
			if holdWoundArterial then
				if canUseTwoHandHold then
					manualUseLeft = canHoldLeft
					manualUseRight = canHoldRight
					if not manualUseLeft or not manualUseRight then
						if isStumpArterialWound(holdWound) then
							manualUseLeft = canHoldLeft
							manualUseRight = canHoldRight
						else
							manualUseLeft = false
							manualUseRight = false
						end
					end
				elseif canHoldLeft then
					manualUseLeft = true
				elseif canHoldRight then
					manualUseRight = true
				end
			elseif canUseTwoHandHold and canHoldLeft and canHoldRight then
				manualUseLeft = true
				manualUseRight = true
			elseif canHoldLeft then
				manualUseLeft = true
			elseif canHoldRight then
				manualUseRight = true
			end
		end

		local manualHoldHands = (manualUseLeft and 1 or 0) + (manualUseRight and 1 or 0)
		local manualHoldWound = wantsManualHold and manualHoldHands > 0
		setManualWoundHold(ply, org, manualHoldWound, holdWound, manualHoldHands, manualUseRight, holdWoundArterial)

		if org.alive and IsValid(spine) and ragdoll.otrubCollapseStart and (CurTime() - ragdoll.otrubCollapseStart) < 1.5 then
			inmove = true

			local t = (CurTime() - ragdoll.otrubCollapseStart) / 1.5
			local strength = 1 - t

			local otrub_ss = 0.4
			local otrub_maxang = 15 * strength
			local otrub_maxangdamp = 8 * strength
			local otrub_maxspeed = 15 * strength
			local otrub_maxspeeddamp = 8 * strength

			local jitterA = AngleRand(-2, 2)
			local jitterV = VectorRand() * 2

			local sPos = spine:GetPos()
			local sAng = spine:GetAngles()
			local fetalPos = sPos + sAng:Up() * -10 + sAng:Forward() * 10 + jitterV
			local armHoldPos = sPos + sAng:Up() * 15 + sAng:Forward() * 5 + jitterV

			shadowControl(ragdoll, 1, otrub_ss, Angle(sAng.p + 30, sAng.y, 0) + jitterA, otrub_maxang, otrub_maxangdamp)
			shadowControl(ragdoll, 10, otrub_ss, Angle(sAng.p + 40, sAng.y, 0) + jitterA, otrub_maxang, otrub_maxangdamp)

			shadowControl(ragdoll, 8, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)
			shadowControl(ragdoll, 11, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)
			shadowControl(ragdoll, 9, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)
			shadowControl(ragdoll, 12, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)
			shadowControl(ragdoll, 13, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)
			shadowControl(ragdoll, 14, otrub_ss, nil, nil, nil, fetalPos, otrub_maxspeed, otrub_maxspeeddamp)

			if not fallCoverActive and ((org.larm or 0) > 0 or org.larmdislocation) then
				shadowControl(ragdoll, 3, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
				shadowControl(ragdoll, 4, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
				shadowControl(ragdoll, 5, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
			end
			if not fallCoverActive and ((org.rarm or 0) > 0 or org.rarmdislocation) then
				shadowControl(ragdoll, 2, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
				shadowControl(ragdoll, 6, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
				shadowControl(ragdoll, 7, otrub_ss, nil, nil, nil, armHoldPos, otrub_maxspeed, otrub_maxspeeddamp)
			end

			if manualHoldWound then
				local wPos = getHoldWoundPos(ragdoll, holdWound)
				if wPos then
					if manualUseLeft then
						shadowControl(ragdoll, 3, otrub_ss, nil, nil, nil, getHoldTarget(wPos, lupper, wound_hold_upperarm_offset), wound_hold_arm_speed * strength, wound_hold_arm_damp * strength)
						shadowControl(ragdoll, 4, otrub_ss, nil, nil, nil, getHoldTarget(wPos, lforearm, wound_hold_forearm_offset), wound_hold_reach_speed * strength, wound_hold_reach_damp * strength)
						shadowControl(ragdoll, 5, otrub_ss, nil, nil, nil, getHoldTarget(wPos, lhand, wound_hold_hand_offset), wound_hold_reach_speed * strength, wound_hold_reach_damp * strength)
					end
					if manualUseRight then
						shadowControl(ragdoll, 2, otrub_ss, nil, nil, nil, getHoldTarget(wPos, rupper, wound_hold_upperarm_offset), wound_hold_arm_speed * strength, wound_hold_arm_damp * strength)
						shadowControl(ragdoll, 6, otrub_ss, nil, nil, nil, getHoldTarget(wPos, rforearm, wound_hold_forearm_offset), wound_hold_reach_speed * strength, wound_hold_reach_damp * strength)
						shadowControl(ragdoll, 7, otrub_ss, nil, nil, nil, getHoldTarget(wPos, rhand, wound_hold_hand_offset), wound_hold_reach_speed * strength, wound_hold_reach_damp * strength)
					end
				end
			end
		end

		local angles2 = -(-angles)
		angles2:RotateAroundAxis(angles2:Right(),30)

		local forward = ply:KeyDown(IN_FORWARD)
		local back = ply:KeyDown(IN_BACK)
		time = CurTime()

		if fakeKick then
			if time >= fakeKick.finish or not org.canmove then
				ragdoll.fakeLegKick = nil
				fakeKickActive = false
			else
				fakeKickActive = true
				inmove = true

				local duration = fakeKick.finish - fakeKick.start
				local phase = math.Clamp((time - fakeKick.start) / duration, 0, 1)
				local kickExtend = phase >= FAKE_LEG_KICK_EXTEND_TIME
				local angle = -(-angles2)
				angle:RotateAroundAxis(angle:Forward(), FAKE_LEG_KICK_CHARGE_FORWARD_OFFSET)

				if kickExtend then
					angle:RotateAroundAxis(angle:Up(), FAKE_LEG_KICK_EXTEND_THIGH_UP_OFFSET)
				end

				angle:RotateAroundAxis(angle:Right(), FAKE_LEG_KICK_CHARGE_THIGH_RIGHT_OFFSET)
				shadowControl(ragdoll, 8, FAKE_LEG_KICK_SHADOW_TIME, angle, FAKE_LEG_KICK_SHADOW_ANG, FAKE_LEG_KICK_SHADOW_DAMP)

				if kickExtend then
					angle:RotateAroundAxis(angle:Up(), -FAKE_LEG_KICK_EXTEND_THIGH_UP_OFFSET)
				end

				angle:RotateAroundAxis(angle:Right(), FAKE_LEG_KICK_CHARGE_CALF_RIGHT_OFFSET)
				if !kickExtend then
					angle:RotateAroundAxis(angle:Up(), FAKE_LEG_KICK_CHARGE_CALF_UP_OFFSET)
				end
				shadowControl(ragdoll, 9, FAKE_LEG_KICK_SHADOW_TIME, angle, FAKE_LEG_KICK_SHADOW_ANG, FAKE_LEG_KICK_SHADOW_DAMP)

				if not fakeKick.hit and time >= fakeKick.hitTime then
					fakeKick.hit = true
					ply:ViewPunch(FAKE_LEG_KICK_VIEWPUNCH)
					fakeLegKickHit(ply, ragdoll, fakeKick)
				end
			end
		end
		
		if manualHoldWound and org.canmove then
			local tr = {}
			tr.start = ragdoll:GetPos()
			tr.endpos = ragdoll:GetPos() - vector_up * 60
			tr.filter = {ply,ragdoll}
			local tracehuy = util.TraceLine(tr)

			if tracehuy.Hit then
				local pos = getHoldWoundPos(ragdoll, holdWound)
				if pos then
					if manualUseLeft then
						shadowControl(ragdoll, 3, 0.03, nil, nil, nil, getHoldTarget(pos, lupper, wound_hold_upperarm_offset), wound_hold_arm_speed, wound_hold_arm_damp)
						shadowControl(ragdoll, 4, 0.03, nil, nil, nil, getHoldTarget(pos, lforearm, wound_hold_forearm_offset), wound_hold_reach_speed, wound_hold_reach_damp)
						shadowControl(ragdoll, 5, 0.03, nil, nil, nil, getHoldTarget(pos, lhand, wound_hold_hand_offset), wound_hold_reach_speed, wound_hold_reach_damp)
					end
					if manualUseRight then
						shadowControl(ragdoll, 2, 0.03, nil, nil, nil, getHoldTarget(pos, rupper, wound_hold_upperarm_offset), wound_hold_arm_speed, wound_hold_arm_damp)
						shadowControl(ragdoll, 6, 0.03, nil, nil, nil, getHoldTarget(pos, rforearm, wound_hold_forearm_offset), wound_hold_reach_speed, wound_hold_reach_damp)
						shadowControl(ragdoll, 7, 0.03, nil, nil, nil, getHoldTarget(pos, rhand, wound_hold_hand_offset), wound_hold_reach_speed, wound_hold_reach_damp)
					end
				end
			end
		end
		
		if not wep.RagdollFunc then
			local force = math.max(1 - org.larm / 1.3, 0)
			if not fallCoverActive and not manualHoldWound and (!IsValid(ragdoll.ConsLH) and (ply:KeyDown(IN_ATTACK) and !ishgweapon(wep)) or (((ishgweapon(wep) and (!wep:IsResting() or ply:KeyDown(IN_FORWARD) or ply:KeyDown(IN_BACK))) or wep.ismelee2) and (ply:KeyDown(IN_USE) or ply:KeyDown(IN_ATTACK2)))) then// || ply:InVehicle() then
				if org.canmove then
					//if !ply:InVehicle() then
						ang2:Set(angles)
						local lower = (ishgweapon(wep) and (ply:KeyDown(IN_USE) or ply:KeyDown(IN_ATTACK2)))
						ang2:RotateAroundAxis(angles:Right(), lower and -20 or 0)
						ang2:RotateAroundAxis(angles:Up(), lower and 20 or 10)
						ang2:RotateAroundAxis(angles:Forward(), -45)
						

						shadowControl(ragdoll, 3, 0.002, ang2, forceArm * force, forceArm_dump)
						shadowControl(ragdoll, 4, 0.002, ang2, forceArm * force, forceArm_dump)
						ang2:RotateAroundAxis(ang2:Forward(), 135)
						ang2:RotateAroundAxis(ang2:Up(), 20)
						shadowControl(ragdoll, 5, 0.001, ang2, forceArm * 2, forceArm_dump, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5)):GetPos() + ang2:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), 500, 50)
						if ply:WaterLevel() == 1 then shadowControl(ragdoll, 1, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,5)):GetPos(), 5, 0) end
					/*else
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), 0)
						ang2:RotateAroundAxis(angles:Right(), 0)
						ang2:RotateAroundAxis(angles:Forward(), -0)
						shadowControl(ragdoll, 5, 0.001, ang2, forceArm * 2, forceArm_dump * 2, ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_L_Hand")):GetTranslation() + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Up() * 4 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Forward() * -3 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Right() * 5 + ragdoll:GetVelocity() / 20, 5550, 1550)
					end*/
				end
			end

			local on_ground = util.TraceLine({
					start = spine:GetPos(),
					endpos = spine:GetPos() - vector_up * 58,
					filter = {ply, ragdoll},
					mask = MASK_SOLID,
				}).Hit
			
			if not fallCoverActive and forward then
				if IsValid(ragdoll.ConsRH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsRH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = force * 2000 * math.max((hand:GetPos() - torso:GetPos()):GetNormalized():Dot(angles2:Forward()) + 0.1, 0) * ragdoll.dtime / 0.015 * ragdoll.power
					
					force = force * 1 / math.max(torso:GetVelocity():Dot(angles2:Forward()) / 25, 1)

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.rarm == 1 or org.rarmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end

					if hg_fake_stamina:GetBool() then
						org.stamina.subadd = org.stamina.subadd + 0.05 * (ragdoll.staminaRightModifyer or 0.5) * (on_ground and 0.25 or 1)
					end
				end

				if IsValid(ragdoll.ConsLH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsLH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = force * 2000 * math.max((hand:GetPos() - torso:GetPos()):GetNormalized():Dot(angles2:Forward()) + 0.1, 0) * ragdoll.dtime / 0.015 * ragdoll.power
					
					force = force * 1 / math.max(torso:GetVelocity():Dot(angles2:Forward()) / 25, 1)

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.larm == 1 or org.larmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end

					if hg_fake_stamina:GetBool() then
						org.stamina.subadd = org.stamina.subadd + 0.05 * (ragdoll.staminaLeftModifyer or 0.5) * (on_ground and 0.25 or 1)
					end
				end
			end

			if not fallCoverActive and back then
				if IsValid(ragdoll.ConsRH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsRH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = -force * 1200 * math.min(10 / (hand:GetPos() - torso:GetPos()):Length(), 1) * ragdoll.dtime / 0.015 * ragdoll.power

					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.rarm == 1 or org.rarmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end
				end

				if IsValid(ragdoll.ConsLH) then
					local hand = ragdoll:GetPhysicsObjectNum(ragdoll.ConsLH.Bone1)
					local torso = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))

					local force = angles2:Forward()
					force:Normalize()
					force = -force * 1200 * math.min(10 / (hand:GetPos() - torso:GetPos()):Length(), 1) * ragdoll.dtime / 0.015 * ragdoll.power
					
					hand:ApplyForceCenter(-force)
					torso:ApplyForceCenter(force)

					if org.larm == 1 or org.larmdislocation then
						org.painadd = org.painadd + ragdoll.dtime * 5
					end
				end
			end

			local force = math.max(1 - org.rarm / 1.3, 0)

			if not fallCoverActive and (!IsValid(ragdoll.ConsRH) and ply:KeyDown(IN_ATTACK2) or ((ishgweapon(wep) or wep.ismelee2) and ply:KeyDown(IN_USE))) then// || ply:InVehicle() then
				if org.canmove then
					--if org.shock > 1 and not ply:KeyDown(IN_ATTACK2) then angles = spine:GetAngles() end
					//if !ply:InVehicle() then
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), ishgweapon(wep) and -10 or 0)
						ang2:RotateAroundAxis(angles:Right(), ishgweapon(wep) and 10 or 0)
						ang2:RotateAroundAxis(angles:Forward(), -90)

						//if !ishgweapon(wep) then
							shadowControl(ragdoll, 2, 0.001, ang2, forceArm * force, forceArm_dump)
							shadowControl(ragdoll, 6, 0.001, ang2, forceArm * force, forceArm_dump)
						//end

						ang2:RotateAroundAxis(ang2:Forward(), 135)
						ang2:RotateAroundAxis(ang2:Up(), ishgweapon(wep) and 1 or 20)
						ang2:RotateAroundAxis(ang2:Forward(), ishgweapon(wep) and 120 or 0)
						shadowControl(ragdoll, 7, 0.001, ang2, forceArm * 2, forceArm_dump, ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7)):GetPos() + ang2:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), ishgweapon(wep) and 500 or 500, ishgweapon(wep) and 50 or 50)
						if ply:WaterLevel() == 1 then shadowControl(ragdoll, 1, 0.001, nil, nil, nil, ragdoll:GetPhysicsObjectNum(7):GetPos(), 5, 0) end
					/*else
						ang2:Set(angles)
						ang2:RotateAroundAxis(angles:Up(), 0)
						ang2:RotateAroundAxis(angles:Right(), 0)
						ang2:RotateAroundAxis(angles:Forward(), 180)
						shadowControl(ragdoll, 7, 0.001, ang2, forceArm * 2, forceArm_dump * 2, ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetTranslation() + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Up() * 5 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Forward() * -1 + ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_R_Hand")):GetAngles():Right() * 2 + ragdoll:GetVelocity() / 20, 5550, 1550)
					end*/
				end
			end
			
			local choking = (IsValid(ragdoll.ConsRH) and IsValid(ragdoll.ConsRH.choking) and ragdoll.ConsRH.choking) or (IsValid(ragdoll.ConsLH) and IsValid(ragdoll.ConsLH.choking) and ragdoll.ConsLH.choking)
			local chokinghead = false

			if not fallCoverActive and ply:KeyDown(IN_SPEED) and ply:KeyDown(IN_WALK) then
				local trace
				tr.start = lhand:GetPos() + lhand:GetAngles():Forward() * 5
				tr.endpos = rhand:GetPos() + lhand:GetAngles():Forward() * 5
				tr.filter = ragdoll
				trace = util_TraceLine(tr)
	
				ent = trace.Entity
				
				if IsValid(ent) and ent:IsRagdoll() and trace.PhysicsBone == realPhysNum(ent, 10) then -- Отрубил чтобы ошибок не было пока...
					choking = ent
					local head = ent:GetPhysicsObjectNum(realPhysNum(ent, 10))
					chokinghead = head

					if IsValid(ragdoll.ConsRH) and not IsValid(ragdoll.ConsRH.choking) then
						rhand:SetPos(head:GetPos())
						ragdoll.cooldownLH = nil
						ragdoll.ConsRH:Remove()
						ragdoll.ConsRH = nil
					end
	
					if IsValid(ragdoll.ConsLH) and not IsValid(ragdoll.ConsLH.choking) then
						lhand:SetPos(head:GetPos())
						ragdoll.cooldownRH = nil
						ragdoll.ConsLH:Remove()
						ragdoll.ConsLH = nil
					end
				end
			end

			if org.stamina[1] < 2 then
				ply.HandsStun = CurTime() + 2
				--ply:Notify(math.random(1,2) == 1 and "SHIT!" or "OH NOO!", 2, "ragdoll_fall", 0, nil, Color(255, 0, 0))
			end

			if org.stamina[1] < 50 and (IsValid(ragdoll.ConsRH) or IsValid(ragdoll.ConsLH)) then
				ply:Notify( math.random(1,2) == 1 and "I'm at my limits here!" or "I can't hold much longer...", 25, "ragdoll_almostfall", 0, nil, Color(200, 55, 55))
			end

			if ply:KeyDown(IN_SPEED) and org.canmove and !org.larmamputated and !org.larmupamputated and (!ply.HandsStun or ply.HandsStun < CurTime()) then
				if IsValid(ragdoll.ConsLH) then
					if hg_fake_stamina:GetBool() then
						org.stamina.subadd = org.stamina.subadd + 0.06 * (ragdoll.staminaLeftModifyer or 0.5) * ( IsValid(ragdoll.ConsRH) and 0.35 or 1.25) * (on_ground and 0.25 or 1)
					end
					
					local ent2 = ragdoll.ConsLH.Ent2
					local ply2 = hg.RagdollOwner(ent2) or ent2

					if ply.PlayerClassName == "furry" and ply2.PlayerClassName != "furry" and IsValid(ent2) and ent2.organism then
						ent2.organism.assimilated = math.Approach(ent2.organism.assimilated, 1, ragdoll.dtime / 6)
						ent2.organism.lightstun = CurTime() + 1
					end
				end

				local wepinreload = wep and wep.reload
				phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 5))
				if (ragdoll.cooldownLH or 0) < time and not IsValid(ragdoll.ConsLH) and not wepinreload then

					--\\ Find Use Entity in ragdoll
						local usetrace = util_TraceHull({
							start = phys:GetPos(),
							endpos = phys:GetPos(),
							maxs = vector_usehull,
							mins = -vector_usehull,
							filter = {ragdoll, game.GetWorld()},
							mask = MASK_SOLID
						})

						local useent = (IsValid(usetrace.Entity) and usetrace.Entity) or false
						if useent and not useent:IsVehicle() and hook.Run("PlayerUse", ply, useent) then useent:Use(ply) end
						local wep = useent and useent:IsWeapon() and useent or false
						ply.force_pickup = true
						if IsValid(wep) and hook.Run("PlayerCanPickupWeapon", ply, wep) then ply:PickupWeapon(wep) end
						ply.force_pickup = nil
					--//

					local trace
					for i = 1,3 do
						if trace and trace.Hit and not trace.HitSky then continue end
						tr.start = phys:GetPos()
						tr.endpos = phys:GetPos() + phys:GetAngles():Right() * 6 + phys:GetAngles():Up() * (i - 2) * 3
						tr.filter = ragdoll
						tr.mask = MASK_SOLID
						trace = util_TraceLine(tr)
					end

					if IsValid(choking) or (trace.Hit and not trace.HitSky) then
						ent = IsValid(choking) and choking or trace.Entity
						ragdoll.staminaLeftModifyer = 1.5 - trace.HitNormal.z

						if IsValid(choking) and chokinghead then
							lhand:SetPos(chokinghead:GetPos(), true)
						end

						local cons = constraint.Weld(ragdoll, ent, realPhysNum(ragdoll, 5), IsValid(choking) and realPhysNum(choking, 10) or trace.PhysicsBone, ent:IsWorld() and 10000 or 0, false, false)
						if IsValid(cons) then
							ragdoll.cooldownLH = time + 0.5
							ragdoll.ConsLH = cons

							cons:CallOnRemove("fingersback", function()
								for i = 1, 4 do
									if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
									ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
								end
							end)

							cons.choking = choking

							ragdoll:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 50, math.random(95, 105))
							
							for i = 1, 4 do
								if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
								ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, -45, 0))
							end
						end
					end
				end
			else
				if IsValid(ragdoll.ConsLH) then
					ragdoll.ConsLH:Remove()
					ragdoll.ConsLH = nil
					for i = 1, 4 do
						if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
						ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
					end
				end
			end

			if ply:KeyDown(IN_WALK) and org.canmove and !(ishgweapon(wep) or wep.ismelee2) and !org.rarmamputated and !org.rarmupamputated and (!ply.HandsStun or ply.HandsStun < CurTime()) then
				if IsValid(ragdoll.ConsRH) then
					if hg_fake_stamina:GetBool() then
						org.stamina.subadd = org.stamina.subadd + 0.06 * (ragdoll.staminaRightModifyer or 1) * ( IsValid(ragdoll.ConsLH) and 0.35 or 1.25) * (on_ground and 0.25 or 1)
					end
					
					local ent2 = ragdoll.ConsRH.Ent2
					local ply2 = hg.RagdollOwner(ent2) or ent2

					if ply.PlayerClassName == "furry" and ply2.PlayerClassName != "furry" and IsValid(ent2) and ent2.organism then
						ent2.organism.assimilated = math.Approach(ent2.organism.assimilated, 1, ragdoll.dtime / 6)
						ent2.organism.lightstun = CurTime() + 1
					end
				end

				phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 7))

				if (ragdoll.cooldownRH or 0) < time and not IsValid(ragdoll.ConsRH) then
					
					--\\ Find Use Entity in ragdoll
						local usetrace = util_TraceHull({
							start = phys:GetPos(),
							endpos = phys:GetPos(),
							maxs = vector_usehull,
							mins = -vector_usehull,
							filter = {ragdoll, game.GetWorld()},
							mask = MASK_SOLID
						})

						local useent = (IsValid(usetrace.Entity) and usetrace.Entity) or false
						if useent and not useent:IsVehicle() and hook.Run("PlayerUse", ply, useent) then useent:Use(ply) end
						local wep = useent and useent:IsWeapon() and useent or false
						ply.force_pickup = true
						if IsValid(wep) and hook.Run("PlayerCanPickupWeapon", ply, wep) then ply:PickupWeapon(wep) end
						ply.force_pickup = nil
					--//

					local trace
					for i = 1,3 do
						if trace and trace.Hit and not trace.HitSky then continue end
						tr.start = phys:GetPos()
						tr.endpos = phys:GetPos() + phys:GetAngles():Right() * 6 + phys:GetAngles():Up() * (i - 2) * 3
						tr.filter = ragdoll
						trace = util_TraceLine(tr)
					end
					
					if IsValid(choking) or (trace.Hit and not trace.HitSky) then
						ent = IsValid(choking) and choking or trace.Entity
						ragdoll.staminaRightModifyer = 1.5 - trace.HitNormal.z
						
						if IsValid(choking) and chokinghead then
							rhand:SetPos(chokinghead:GetPos(), true)
						end
						
						local cons = constraint.Weld(ragdoll, ent, realPhysNum(ragdoll, 7), IsValid(choking) and realPhysNum(choking, 10) or trace.PhysicsBone, ent:IsWorld() and 10000 or 0, false, false)
						if IsValid(cons) then
							ragdoll.cooldownRH = time + 0.5
							ragdoll.ConsRH = cons

							cons:CallOnRemove("fingersback", function()
								for i = 1, 4 do
									if not ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1") then continue end
									ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
								end
							end)

							cons.choking = choking

							ragdoll:EmitSound("physics/body/body_medium_impact_soft" .. math.random(1, 7) .. ".wav", 55, math.random(95, 105))
							
							for i = 1, 4 do
								if not ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1") then continue end
								ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, -45, 0))
							end
						end
					end
				end
			else
				if IsValid(ragdoll.ConsRH) then
					ragdoll.ConsRH:Remove()
					ragdoll.ConsRH = nil
					for i = 1, 4 do
						if not ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1") then continue end
						ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
					end
				end
			end
		else
			if not fallCoverActive and ply:KeyDown(IN_ATTACK2) and org.canmove then
				if wep.RagdollFunc then
					wep:RagdollFunc(ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll,7)):GetPos() + angles:Forward() * 15 + ((vellen > 150 and ragdoll:GetPhysicsObject():GetVelocity() / 224) or vector_zero), angles, ragdoll)
				end
			end
		end
		-- Zavtra yje
		if IsValid(ragdoll.ConsLH) and IsValid(ragdoll.ConsRH) and IsValid(ragdoll.ConsLH.choking) and ragdoll.ConsLH.choking == ragdoll.ConsRH.choking then
			local choking1 = ragdoll.ConsLH.choking
			local head = choking1:GetPhysicsObjectNum(realPhysNum(choking1, 10))
			--lhand:SetPos(head:GetPos())
			--rhand:SetPos(head:GetPos())
			local org = choking1.organism
			if org then
				org.choking = true
				if zb then
					local dmgInfo = DamageInfo()
					dmgInfo:SetAttacker(ply)
					hook.Run("HomigradDamage", org.owner, dmgInfo, HITGROUP_RIGHTARM, hg.GetCurrentCharacter(org.owner), ragdoll.dtime * ((zb.MaximumHarm or 10) / 50) )
				end

				if org.otrub then
					ply:Notify("They seem unresponsive.", 60, "choked"..(org.owner:EntIndex()))
				end
			end
			--print("huy")
		end

		local keyLeft = false
		local keyRight = false
		local isNeckSlitRolling = false

		if org.neckslit and not org.otrub and ply:Alive() and not ply:InVehicle() then
			local phase = (CurTime() * 1.5) % 4
			if phase < 1 then
				keyLeft = true
				isNeckSlitRolling = true
			elseif phase >= 2 and phase < 3 then
				keyRight = true
				isNeckSlitRolling = true
			end
	else
		keyLeft = ply:KeyDown(IN_ALT1)
		keyRight = ply:KeyDown(IN_ALT2)
	end

	ply.lean = ply:KeyDown(IN_ALT1) and 1 or ply:KeyDown(IN_ALT2) and -1 or 0

	if keyLeft and not inmove and !ply:InVehicle() and (isNeckSlitRolling or not ply:KeyDown(IN_USE)) then
			if org.canmove then
				local angle = spine:GetAngles()
				angle[3] = angle[3] - 20 * (ragdoll:IsOnFire() and 1.5 or 1)
				shadowControl(ragdoll, 1, 0.001, angle, 490, 90)
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))

				if math.random(100) == 1 and ragdoll:IsOnFire() then
					local key, fire = next(ragdoll.fires)

					if ragdoll:IsOnFire() then
						shadowControl(ragdoll, 5, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
						shadowControl(ragdoll, 7, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
					end

					if key then 
						ragdoll.fires[key] = nil

						if IsValid(key) then
							key:Remove()
						end
					end
				end
			end
		end

		if keyRight and not inmove and !ply:InVehicle() and (isNeckSlitRolling or not ply:KeyDown(IN_USE)) then
			if org.canmove and not org.otrub then
				local angle = spine:GetAngles()
				angle[3] = angle[3] + 20 * (ragdoll:IsOnFire() and 1.5 or 1)
				shadowControl(ragdoll, 1, 0.001, angle, 490, 90)
				local head = ragdoll:GetPhysicsObject(ragdoll:TranslateBoneToPhysBone(ragdoll:LookupBone("ValveBiped.Bip01_Head1")))

				if ragdoll:IsOnFire() then
					shadowControl(ragdoll, 5, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
					shadowControl(ragdoll, 7, 0.001, angle, 0, 0, head:GetPos() - head:GetAngles():Right() * 10, 5050, 100)
				end

				if math.random(100) == 1 and ragdoll:IsOnFire() then
					local key, fire = next(ragdoll.fires)
					
					if key then 
						ragdoll.fires[key] = nil

						if IsValid(key) then
							key:Remove()
						end
					end
				end
			end
		end

	local rollLeft = ply:KeyDown(IN_MOVELEFT)
	local rollRight = ply:KeyDown(IN_MOVERIGHT)

	if (rollLeft or rollRight) and not inmove and !ply:InVehicle() and org.canmove then
		local onground = util.TraceLine({
			start = spine:GetPos(),
			endpos = spine:GetPos() - vector_up * 36,
			filter = {ply, ragdoll},
			mask = MASK_SOLID,
		}).Hit

		if onground then
			local dir = rollLeft and -1 or 1
			local axis = spine:GetAngles():Forward()
			local rollPhys = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}

			for _, physNum in ipairs(rollPhys) do
				if isFloppyPhys(ragdoll, physNum, true) then continue end

				local phys = ragdoll:GetPhysicsObjectNum(physNum)
				if IsValid(phys) then
					local cur = phys:GetAngleVelocity():Dot(axis)
					phys:AddAngleVelocity(axis * math.Clamp(dir * 6 * (ragdoll.power or 1) - cur, -2, 2))
				end
			end

			if hg_fake_stamina:GetBool() and ply.organism then
				ply.organism.stamina.subadd = ply.organism.stamina.subadd + 0.04
			end
		end
	end

	if org.canmove and ply.FakeRagdoll == ragdoll then
		if ply:KeyDown(IN_DUCK) and !ply:InVehicle() then
				local lthigh = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 11))
				local rthigh = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 8))

				if lthigh and rthigh then
					local legAng1 = Angle(0, 0, 0)
					local legAng2 = Angle(0, 0, 0)

					legAng1:Set(angles)
					legAng1:RotateAroundAxis(angles:Right(), 80)
					legAng1:RotateAroundAxis(angles:Forward(), -40)
					legAng1:RotateAroundAxis(angles:Up(), -70)

					legAng2:Set(angles)
					legAng2:RotateAroundAxis(angles:Right(), 65)
					legAng2:RotateAroundAxis(angles:Forward(), -40)
					legAng2:RotateAroundAxis(angles:Up(), -70)

					shadowControl(ragdoll, 11, 0.001, legAng1, 200, 10)
					shadowControl(ragdoll, 8, 0.001, legAng2, 200, 10)

					local calfAng1 = Angle(0, 0, 0)
					local calfAng2 = Angle(0, 0, 0)

					calfAng1:Set(legAng1)
					calfAng1:RotateAroundAxis(angles:Right(), -90)

					calfAng2:Set(legAng2)
					calfAng2:RotateAroundAxis(angles:Right(), -90)

					shadowControl(ragdoll, 12, 0.001, calfAng1, 150, 10)
					shadowControl(ragdoll, 9, 0.001, calfAng2, 150, 10)

				local slideMinStartSpeed = 150
				local slideMinKeepSpeed = 40
				local slideMaxDuration = 4
				local slideCooldown = 3
				local slideSlopeMult = 30

				local curVel = spine:GetVelocity()
				local curSpeed = curVel:Length()
				local horizontalVel = Vector(curVel.x, curVel.y, 0)
				local horizontalSpeed = horizontalVel:Length()

				local groundTrace = util.TraceLine({
					start = spine:GetPos(),
					endpos = spine:GetPos() - vector_up * 40,
					filter = {ply, ragdoll},
					mask = MASK_SOLID,
				})
				local onGround = groundTrace.Hit
				local groundNormal = groundTrace.HitNormal or vector_up

				if ragdoll._slideCooldown and CurTime() >= ragdoll._slideCooldown then
					ragdoll._slideCooldown = nil
				end

				local entrySpeed = 0
				local entryDir = vector_up
				if ragdoll._slideEntryTime and CurTime() - ragdoll._slideEntryTime < 0.1 then
					entrySpeed = ragdoll._slideEntrySpeed or 0
					entryDir = ragdoll._slideEntryDir or vector_up
				end

				local plyVel = ply:GetVelocity()
				local playerHorizontalSpeed = Vector(plyVel.x, plyVel.y, 0):Length()

				local checkSpeed = math.max(playerHorizontalSpeed, entrySpeed)

				if ragdoll._slideActive then
					local slideTime = CurTime() - ragdoll._slideStartTime
					local falling = curVel.z < -80

					local dirDot = 0
					if ragdoll._slideDir and horizontalSpeed > 1 then
						dirDot = ragdoll._slideDir:GetNormalized():Dot(horizontalVel:GetNormalized())
					end

					if horizontalSpeed < slideMinKeepSpeed or slideTime > slideMaxDuration or not onGround or falling or dirDot < -0.1 then
						clearSlideState(ragdoll, slideCooldown)
					end
				end

				if not ragdoll._slideActive and checkSpeed >= slideMinStartSpeed and not ragdoll._slideCooldown and onGround then
					ragdoll._slideActive = true
					ragdoll._slideStartTime = CurTime()
					local eyeForward = angles:Forward()
					local fallbackDir = Vector(eyeForward.x, eyeForward.y, 0)
					if fallbackDir:LengthSqr() <= 1 then fallbackDir = Vector(1, 0, 0) end
					local dir = horizontalVel:LengthSqr() > 1 and horizontalVel:GetNormalized() or (entryDir:LengthSqr() > 1 and entryDir:GetNormalized() or fallbackDir:GetNormalized())
					ragdoll._slideDir = dir

					ragdoll.isSliding = true

					local legAng1 = Angle(0, 0, 0)
					local legAng2 = Angle(0, 0, 0)

					legAng1:Set(angles)
					legAng1:RotateAroundAxis(angles:Right(), 80)
					legAng1:RotateAroundAxis(angles:Forward(), -40)
					legAng1:RotateAroundAxis(angles:Up(), -70)

					legAng2:Set(angles)
					legAng2:RotateAroundAxis(angles:Right(), 65)
					legAng2:RotateAroundAxis(angles:Forward(), -40)
					legAng2:RotateAroundAxis(angles:Up(), -70)

					shadowControl(ragdoll, 11, 0.001, legAng1, 500, 150)
					shadowControl(ragdoll, 8, 0.001, legAng2, 500, 150)

					local calfAng1 = Angle(0, 0, 0)
					local calfAng2 = Angle(0, 0, 0)

					calfAng1:Set(legAng1)
					calfAng1:RotateAroundAxis(angles:Right(), -90)

					calfAng2:Set(legAng2)
					calfAng2:RotateAroundAxis(angles:Right(), -90)

					shadowControl(ragdoll, 12, 0.001, calfAng1, 400, 120)
					shadowControl(ragdoll, 9, 0.001, calfAng2, 400, 120)
				end

				if ragdoll._slideActive then
					ragdoll.isSliding = true

					local slidePhys = {0, 1}

					if not ragdoll._slideMaterialSet then
						ragdoll._origMaterials = {}
						for _, fNum in ipairs(slideFrictionBones) do
							local phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, fNum))
							if IsValid(phys) then
								ragdoll._origMaterials[fNum] = phys:GetMaterial()
								phys:SetMaterial("ice")
							end
						end
						ragdoll._slideMaterialSet = true
					end

					local slideDir = ragdoll._slideDir

					local slideForce = 1700 * (ragdoll.power or 1) * ragdoll.dtime / 0.015

					for _, physNum in ipairs(slidePhys) do
						local phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, physNum))
						if IsValid(phys) then
							phys:Wake()
							phys:ApplyForceCenter(slideDir * slideForce / #slidePhys)
						end
					end

					local dragForce = curVel * -2 * ragdoll.dtime / 0.015

					for _, physNum in ipairs(slidePhys) do
						local phys = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, physNum))
						if IsValid(phys) then
							phys:ApplyForceCenter(dragForce / #slidePhys)
						end
					end

					local pelvis = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 0))
					if IsValid(pelvis) then
						pelvis:ApplyForceCenter(vector_up * -800 * ragdoll.dtime / 0.015)
					end

					local spine1 = ragdoll:GetPhysicsObjectNum(realPhysNum(ragdoll, 1))
					if IsValid(spine1) then
						local spineAng = spine1:GetAngles()
						shadowControl(ragdoll, 1, 0.4, spineAng, 30, 5)
					end

					if hg_fake_stamina:GetBool() then
						org.stamina.subadd = org.stamina.subadd + 0.08
					end
				else
					restoreSlideMaterials(ragdoll)
					
					if ragdoll._slideActive then
						clearSlideState(ragdoll)
					end
					
					ragdoll.isSliding = false

					local slidePending = checkSpeed >= slideMinStartSpeed and onGround and not ragdoll._slideCooldown

					local isDropkicking = ply:KeyDown(IN_ATTACK) and ply:KeyDown(IN_ATTACK2) and not slidePending and not onGround
					if isDropkicking and not ragdoll.isDropkicking then
						ragdoll.dropkickAchievementHit = false
					end
					ragdoll.isDropkicking = isDropkicking

					if isDropkicking and hgIsDoor then
						local kickDir = angles:Forward()
						kickDir = Vector(kickDir.x, kickDir.y, 0)
						if kickDir:LengthSqr() <= 0.001 then kickDir = angles:Forward() end
						kickDir:Normalize()

						local kickTr = getFakeLegKickTrace(ply, ragdoll, kickDir)
						if kickTr and kickTr.Hit and IsValid(kickTr.Entity) and hgIsDoor(kickTr.Entity) and not kickTr.Entity:GetNoDraw() then
							local doorEnt = kickTr.Entity
							if not (ragdoll._dropkickDoorCd and ragdoll._dropkickDoorCd > CurTime()) then
								ragdoll._dropkickDoorCd = CurTime() + 0.3

								if DoorIsOpen(doorEnt) and not DoorIsOpen2(doorEnt) then
									doorEnt:EmitSound("physics/wood/wood_crate_impact_hard" .. math.random(1, 4) .. ".wav")
									doorEnt:EmitSound("physics/wood/wood_box_impact_hard3.wav")

									doorEnt:FastOpenDoor(ply, 5, true)
									local oldname = doorEnt:GetName()
									local kickerName = ply:GetName()
									if doorEnt:GetClass() == "func_door_rotating" then
										doorEnt:Fire("open", kickerName, 0, ply, ply)
									elseif doorEnt:GetClass() == "prop_door_rotating" then
										doorEnt:Fire("openawayfrom", kickerName, 0, ply, ply)
									end
									doorEnt:SetName(oldname)
								end
							end
						end
					end

					if isDropkicking then
						legAng1:Set(angles)
						legAng1:RotateAroundAxis(angles:Right(), 75)
						legAng1:RotateAroundAxis(angles:Forward(), -100)
						legAng1:RotateAroundAxis(angles:Up(), -70)

						legAng2:Set(angles)
						legAng2:RotateAroundAxis(angles:Right(), 75)
						legAng2:RotateAroundAxis(angles:Forward(), -100)
						legAng2:RotateAroundAxis(angles:Up(), -70)

						calfAng1:Set(legAng1)
						calfAng1:RotateAroundAxis(angles:Right(), 20)

						calfAng2:Set(legAng2)
						calfAng2:RotateAroundAxis(angles:Right(), 20)

						local foot1 = Angle(0, 0, 0)
						local foot2 = Angle(0, 0, 0)

						foot1:Set(calfAng1)
						foot1:RotateAroundAxis(angles:Right(), 90)

						foot2:Set(calfAng2)
						foot2:RotateAroundAxis(angles:Right(), 90)

						shadowControl(ragdoll, 11, 0.001, legAng1, 600, 200)
						shadowControl(ragdoll, 8, 0.001, legAng2, 600, 200)

						shadowControl(ragdoll, 13, 0.001, foot1, 600, 200)
						shadowControl(ragdoll, 14, 0.001, foot2, 600, 200)

						shadowControl(ragdoll, 12, 0.001, calfAng1, 600, 200)
						shadowControl(ragdoll, 9, 0.001, calfAng2, 600, 200)
					end
				end

					if org.lleg >= 1 or org.rleg >= 1 then
						org.painadd = org.painadd + ragdoll.dtime * 2 * (org.lleg + org.rleg)
					end
				end
			else
				if IsValid(ragdoll) then
					clearSlideState(ragdoll)
					ragdoll.isDropkicking = false
				end
			end
		end
		local vel = ragdoll:GetVelocity()
		local vellen = vel:Length()
		if org.canmove and vellen > 700 and !ply:InVehicle() then
			local mul = (vellen - 700) / 750
			local maxangdamp = 500 * mul
			local maxangspeed = 950 *  mul
			local rand = 360 * mul
			shadowControl(ragdoll, 2, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 3, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 4, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 5, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 6, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 7, 0.001, AngleRand(-rand,rand), maxangspeed * 2, maxangdamp)
			shadowControl(ragdoll, 8, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 9, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 10, 0.001, AngleRand(-rand,rand), maxangspeed / 4, maxangdamp)
			shadowControl(ragdoll, 11, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
			shadowControl(ragdoll, 12, 0.001, AngleRand(-rand,rand), maxangspeed, maxangdamp)
		end

	end
end)

hook.Add("Ragdoll Collide", "SlideDamage", function(ragdoll, data)
	if not ragdoll.isSliding and not ragdoll.isDropkicking then return end

	local hitEnt = data.HitEntity
	if not IsValid(hitEnt) or hitEnt == game.GetWorld() then return end
	if hitEnt == ragdoll then return end

	local physObj = data.PhysObject
	if not IsValid(physObj) then return end

	local physBone = -1
	for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
		if ragdoll:GetPhysicsObjectNum(i) == physObj then
			physBone = i
			break
		end
	end
	if physBone < 0 then return end

	local bone = ragdoll:TranslatePhysBoneToBone(physBone)
	if bone < 0 then return end

	local boneName = ragdoll:GetBoneName(bone)
	if not boneName then return end

	local hitBones = {
		["ValveBiped.Bip01_L_Foot"] = true,
		["ValveBiped.Bip01_R_Foot"] = true,
		["ValveBiped.Bip01_L_Calf"] = true,
		["ValveBiped.Bip01_R_Calf"] = true,
		["ValveBiped.Bip01_L_Thigh"] = true,
		["ValveBiped.Bip01_R_Thigh"] = true,
	}

	if not hitBones[boneName] then return end

	local ply = hg.RagdollOwner(ragdoll)
	if not IsValid(ply) or not ply:Alive() then return end

	local isDropkick = ragdoll.isDropkicking

	if isDropkick then
		ragdoll.dropkickHits = ragdoll.dropkickHits or {}
		if (ragdoll.dropkickCd or 0) > CurTime() then return end
		if (ragdoll.dropkickHits[hitEnt] or 0) > CurTime() then return end
		ragdoll.dropkickHits[hitEnt] = CurTime() + 0.5
		ragdoll.dropkickCd = CurTime() + 0.8
	else
		ragdoll.slideHits = ragdoll.slideHits or {}
		if (ragdoll.slideCd or 0) > CurTime() then return end
		if (ragdoll.slideHits[hitEnt] or 0) > CurTime() then return end
		ragdoll.slideHits[hitEnt] = CurTime() + 0.5
		ragdoll.slideCd = CurTime() + 1
	end

	local speed = data.OurOldVelocity:Length()
	local attackerPhys = ragdoll:GetPhysicsObject()
	local attackerSpeed = IsValid(attackerPhys) and attackerPhys:GetVelocity():Length() or ragdoll:GetVelocity():Length()

	if isDropkick then
		speed = math.max(speed, attackerSpeed)
		if speed < 260 then return end
	end

	local dmg = isDropkick and math.Clamp((speed - 180) / 8, 12, 60) or math.Clamp(speed / 25, 2, 20)

	local targetPly = hg.RagdollOwner(hitEnt) or (hitEnt:IsPlayer() and hitEnt)
	if isDropkick and not ragdoll.dropkickAchievementHit and IsValid(targetPly) and targetPly:IsPlayer() and targetPly:Alive() and targetPly ~= ply then
		ragdoll.dropkickAchievementHit = true
		hook.Run("HG_PlayerDropkicked", ply, targetPly)
	end
	if not IsValid(targetPly) then
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(dmg)
		dmgInfo:SetDamageType(DMG_CLUB)
		dmgInfo:SetAttacker(ply)
		dmgInfo:SetInflictor(ragdoll)
		dmgInfo:SetDamagePosition(physObj:GetPos())
		dmgInfo:SetDamageForce(data.OurOldVelocity:GetNormalized() * dmg * 50)
		hitEnt:TakeDamageInfo(dmgInfo)
	else
		local dmgInfo = DamageInfo()
		dmgInfo:SetDamage(dmg)
		dmgInfo:SetDamageType(DMG_CLUB)
		dmgInfo:SetAttacker(ply)
		dmgInfo:SetInflictor(ragdoll)
		dmgInfo:SetDamagePosition(physObj:GetPos())
		dmgInfo:SetDamageForce(data.OurOldVelocity:GetNormalized() * dmg * 50)

		local hitgroup = HITGROUP_GENERIC
		if boneName:find("R_Foot") or boneName:find("R_Calf") or boneName:find("R_Thigh") then
			hitgroup = HITGROUP_RIGHTLEG
		elseif boneName:find("L_Foot") or boneName:find("L_Calf") or boneName:find("L_Thigh") then
			hitgroup = HITGROUP_LEFTLEG
		end

		-- Dropkicks hit hard but are cheap movement tech: pass harm normalized to the
		-- 0..maxharm scale (like real weapons) so they don't rack up RDM-karma like a kill.
		hook.Run("HomigradDamage", targetPly, dmgInfo, hitgroup, hg.GetCurrentCharacter(targetPly), dmg * 0.1)

		if isDropkick and targetPly.organism then
			local speedMul = math.Clamp((speed - 260) / 420, 0, 1)
			targetPly.organism.painadd = targetPly.organism.painadd + 8 + speedMul * 22
			targetPly.organism.shock = math.min((targetPly.organism.shock or 0) + 8 + speedMul * 32, 95)
		end
	end

	if hg_fake_stamina:GetBool() and ply.organism then
		ply.organism.stamina.subadd = ply.organism.stamina.subadd + (isDropkick and 12 or 26)
	end

	ragdoll:EmitSound("kickland" .. math.random(1, 2) .. ".mp3", 75, math.random(95, 110))
end)

hook.Add("PlayerDeath", "homigrad-fake-control", function(ply)
	local ragdoll = ply.FakeRagdoll
	if not IsValid(ragdoll) then return end
	if IsValid(ragdoll.ConsLH) then
		ragdoll.ConsLH:Remove()
		ragdoll.ConsLH = nil
		for i = 1, 4 do
			ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_L_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
		end
	end

	if IsValid(ragdoll.ConsRH) then
		ragdoll.ConsRH:Remove()
		ragdoll.ConsRH = nil
		for i = 1, 4 do
			ragdoll:ManipulateBoneAngles(ragdoll:LookupBone("ValveBiped.Bip01_R_Finger" .. tostring(i) .. "1"), Angle(0, 0, 0))
		end
	end
end)
