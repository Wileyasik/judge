hg = hg or {}

local hg_proc_limbs = CreateConVar("hg_proc_limbs", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "procedural limb adaptation while moving (terrain + gait)", 0, 1)
local hg_proc_gait = CreateConVar("hg_proc_gait", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "procedural crawl gait for legs while moving", 0, 1)

local PROC_LIFT = 2
local GAIT_STRIDE = 12
local GAIT_LIFT = 6
local GAIT_SPEED = 3.2
local GAIT_BONE_PHASE = { Thigh = 0, Calf = 0.8, Foot = 1.6 }

local function isLimbBone(name)
	if string.find(name, "Hand", 1, true) or string.find(name, "Foot", 1, true) or
		string.find(name, "Forearm", 1, true) or string.find(name, "Calf", 1, true) or
		string.find(name, "UpperArm", 1, true) or string.find(name, "Thigh", 1, true) then
		return true
	end
	return false
end

local function isLegBone(name)
	if string.find(name, "Thigh", 1, true) or string.find(name, "Calf", 1, true) or string.find(name, "Foot", 1, true) then
		return true
	end
	return false
end

function hg.ProcLimb(ragdoll, ply, physIndex, name, bonepos, boneang)
	if not hg_proc_limbs:GetBool() then return bonepos, boneang end
	if not isLimbBone(name) then return bonepos, boneang end

	local rootPhys = ragdoll:GetPhysicsObject()
	local rootZ = IsValid(rootPhys) and rootPhys:GetPos().z or bonepos.z

	if bonepos.z < rootZ + 8 then
		local tr = util.TraceLine({
			start = Vector(bonepos.x, bonepos.y, rootZ + 10),
			endpos = Vector(bonepos.x, bonepos.y, rootZ - 96),
			filter = {ply, ragdoll},
			mask = MASK_SOLID,
		})
		if tr.Hit and not tr.HitSky and tr.HitNormal.z > 0.35 and tr.HitPos.z + PROC_LIFT > bonepos.z then
			bonepos.z = tr.HitPos.z + PROC_LIFT
		end
	end

	if isLegBone(name) and hg_proc_gait:GetBool() and ragdoll.hgProcMove and not ragdoll.hgStumbleActive and not ragdoll.hgGetUp then
		local phys = ragdoll:GetPhysicsObjectNum(physIndex)
		local base = IsValid(phys) and phys:GetPos() or bonepos

		local side = string.find(name, "_L_", 1, true) and 1 or -1
		local bonePhase = 0
		for boneType, phase in pairs(GAIT_BONE_PHASE) do
			if string.find(name, boneType, 1, true) then bonePhase = phase break end
		end

		local axis = Vector(1, 0, 0)
		if IsValid(rootPhys) then
			local rootAng = rootPhys:GetAngles()
			if type(rootAng) == "Angle" then
				axis = rootAng:Forward()
				axis.z = 0
				if axis:LengthSqr() < 0.01 then axis = Vector(1, 0, 0) else axis = axis:GetNormalized() end
			end
		end

		local cyc = CurTime() * GAIT_SPEED + bonePhase + (side == 1 and 0 or math.pi)
		local s = math.sin(cyc)
		local lift = math.max(0, math.sin(cyc + 0.6))

		bonepos = base + axis * (GAIT_STRIDE * s)
		bonepos.z = bonepos.z + GAIT_LIFT * lift
	end

	return bonepos, boneang
end