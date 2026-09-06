function hg.spiralGrid(rings)
	local grid = {}
	local col, row

	for ring = 1, rings do
		row = ring
		for col = 1 - ring, ring do
			table.insert(grid, {col, row})
		end

		col = ring
		for row = ring - 1, -ring, -1 do
			table.insert(grid, {col, row})
		end

		row = -ring
		for col = ring - 1, -ring, -1 do
			table.insert(grid, {col, row})
		end

		col = -ring
		for row = 1 - ring, ring do
			table.insert(grid, {col, row})
		end
	end

	return grid
end

local hull = 10
local HullMaxs = Vector(hull, hull, 72)
local HullMins = -Vector(hull, hull, 0)
local HullDuckMaxs = Vector(hull, hull, 36)
local HullDuckMins = -Vector(hull, hull, 0)
local ViewOffset = Vector(0, 0, 64)
local ViewOffsetDucked = Vector(0, 0, 38)
local Pos32 = Vector(0, 0, 32)

local gridsize = 24
local tpGrid = hg.spiralGrid(gridsize)
local cell_size = 50

function hg.tpPlayer(pos, ply, i, yaw, forced)
	if !tpGrid[i] then
		return hg.tpPlayer(pos, ply, math.random(gridsize), yaw, true)
	end

	local c = tpGrid[i][1]
	local r = tpGrid[i][2]

	local yawForward = yaw or 0
	local offset = Vector(r * cell_size, c * cell_size, 0)
	offset:Rotate(Angle(0, yawForward, 0))

	local t = {}
	t.start = pos + Pos32
	t.collisiongroup = COLLISION_GROUP_WEAPON
	t.filter = player.GetAll()
	t.endpos = t.start + offset

	if !IsValid(ply) then
		t.hullmaxs = HullMaxs
		t.hullmins = HullMins
	end

	local tr
	if IsValid(ply) then
		tr = util.TraceEntity(t, ply)
	else
		tr = util.TraceHull(t)
	end

	if !tr.Hit or forced then
		if IsValid(ply) then ply:SetPos(tr.HitPos) end
		return tr.HitPos
	else
		return hg.tpPlayer(pos, ply, i + 1, yaw)
	end
end

function hg.clamp(vecOrAng, val)
	vecOrAng[1] = math.Clamp(vecOrAng[1], -val, val)
	vecOrAng[2] = math.Clamp(vecOrAng[2], -val, val)
	vecOrAng[3] = math.Clamp(vecOrAng[3], -val, val)
	return vecOrAng
end

function hg.RotateAroundPoint(pos, ang, point, offset, offset_ang)
	local v = Vector(0, 0, 0)
	v = v + (point.x * ang:Right())
	v = v + (point.y * ang:Forward())
	v = v + (point.z * ang:Up())

	local newang = Angle()
	newang:Set(ang)

	newang:RotateAroundAxis(ang:Right(), offset_ang.p)
	newang:RotateAroundAxis(ang:Forward(), offset_ang.r)
	newang:RotateAroundAxis(ang:Up(), offset_ang.y)

	v = v + newang:Right() * offset.x
	v = v + newang:Forward() * offset.y
	v = v + newang:Up() * offset.z

	v = v - (point.x * newang:Right())
	v = v - (point.y * newang:Forward())
	v = v - (point.z * newang:Up())

	pos = v + pos

	return pos, newang
end

function hg.RotateAroundPoint2(pos, ang, point, offset, offset_ang)
	local mat = Matrix()
	mat:SetTranslation(pos)
	mat:SetAngles(ang)
	mat:Translate(point)

	local rot_mat = Matrix()
	rot_mat:SetAngles(offset_ang)
	rot_mat:Invert()

	mat:Mul(rot_mat)

	mat:Translate(-point)

	mat:Translate(offset)

	return mat:GetTranslation(), mat:GetAngles()
end

local lend = 3
local vec = Vector(lend, lend, lend)
local traceBuilder = {
	mins = -vec,
	maxs = vec,
	mask = MASK_SOLID,
	collisiongroup = COLLISION_GROUP_DEBRIS
}

local util_TraceHull = util.TraceHull

function hg.hullCheck(startpos, endpos, ply)
	if ply:InVehicle() then return {HitPos = endpos} end
	traceBuilder.start = IsValid(ply.FakeRagdoll) and endpos or startpos
	traceBuilder.endpos = endpos
	traceBuilder.filter = {ply, ply.FakeRagdoll, ply:InVehicle() and ply:GetVehicle(), ply.OldRagdoll}
	local trace = util_TraceHull(traceBuilder)

	ply.cachedhulltrace = trace

	return trace
end

local lpos = Vector(6, 2, 1)
local lang = Angle(0, 0, 0)

function hg.torsoTrace(ply, dist, ent, aim_vector)
	local ent = (IsValid(ent) and ent) or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
	local bon = ent:LookupBone("ValveBiped.Bip01_Spine4")
	if not bon then return end
	local mat = ent:GetBoneMatrix(bon)
	if not mat then return end

	local aim_vector = aim_vector or ply:GetAimVector()

	local pos, ang = LocalToWorld(lpos, lang, mat:GetTranslation(), mat:GetAngles())

	return hg.eyeTrace(ply, dist, ent, aim_vector, pos)
end

function hg.eye(ply, dist, ent, aimvec, startpos)
	if !ply:IsPlayer() then return false end
	local fakeCam = false
	local ent = (IsValid(ent) and ent) or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
	local bon = ent:LookupBone("ValveBiped.Bip01_Neck1")
	if not bon then return end
	if not IsValid(ply) then return end
	if not ply.GetAimVector then return end

	local aim_vector = isvector(aimvec) and aimvec or isangle(aimvec) and aimvec:Forward() or ply:GetAimVector()

	if not bon or not ent:GetBoneMatrix(bon) then
		local tr = {
			start = ply:EyePos(),
			endpos = ply:EyePos() + aim_vector * (dist or 60),
			filter = ply
		}
		return ply:EyePos(), aim_vector * (dist or 60), ply
	end

	local headm = ent:GetBoneMatrix(bon)

	local eyeAng = aim_vector:Angle()
	eyeAng.r = isangle(aimvec) and aimvec.r or ply:EyeAngles().r

	local eyeang2 = aim_vector:Angle()
	eyeang2.r = isangle(aimvec) and aimvec.r or ply:EyeAngles().r

	local pos = startpos or headm:GetTranslation() + (fakeCam and (headm:GetAngles():Forward() * 2 + headm:GetAngles():Up() * -2 + headm:GetAngles():Right() * 3) or (eyeAng:Up() * 2 + headm:GetAngles():Right() * 4 + headm:GetAngles():Up() * 0 + headm:GetAngles():Forward() * (4 + (ply.PlayerClassName == "Combine" and 4 or 0))))

	local trace = hg.hullCheck(ply:EyePos() - vector_up * 10, pos, ply)

	return trace.HitPos, aim_vector * (dist or 60), {ply, ent, ply.OldRagdoll}, trace, headm
end

function hg.eyeTrace(ply, dist, ent, aim_vector, startpos, fFilter)
	local start, aim, filter, trace, headm = hg.eye(ply, dist, ent, aim_vector, startpos)
	if not start then return end

	if not isvector(start) then return end
	ply.cachedeyetrace = util.TraceLine({
		start = start,
		endpos = start + aim,
		filter = fFilter or filter
	})
	return ply.cachedeyetrace, trace, headm
end
