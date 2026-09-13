local eyeData = {
	l = {
		model = "models/gore/head_eye02.mdl",
		bulge = { offset = Vector(-4.5, 0, -1), angle = Angle(10, 0, 0) },
		hang = { offset = Vector(-4.5, 0, -1), angle = Angle(20, 0, 0) },
	},
	r = {
		model = "models/gore/head_eye01.mdl",
		bulge = { offset = Vector(-4.5, 0.25, -1), angle = Angle(10, 0, 0) },
		hang = { offset = Vector(-4.5, 0.25, -1), angle = Angle(20, 0, 0) },
	},
}

local sides = {"l", "r"}
local modelCache = {}

local function eyeModel(model)
	if modelCache[model] then return modelCache[model] end
	local m = ClientsideModel(model, RENDERGROUP_OPAQUE)
	if IsValid(m) then
		m:SetNoDraw(true)
		modelCache[model] = m
	end
	return m
end

local function eyeValue(org, side)
	return org[side == "l" and "eyeL" or "eyeR"] or 0
end

local function eyePopped(org, side)
	return org[side == "l" and "eyePoppedL" or "eyePoppedR"]
end

local function eachTarget(func)
	for _, rag in ipairs(hg.ragdolls) do
		if IsValid(rag) then
			local org = rag.new_organism or rag.organism
			if org then func(rag, org) end
		end
	end
	for _, ply in player.Iterator() do
		if IsValid(ply) and not IsValid(ply.FakeRagdoll) then
			local org = ply.new_organism or ply.organism
			if org then func(ply, org) end
		end
	end
end

local function hiddenOwnHead(ent)
	local lp = LocalPlayer()
	if not IsValid(lp) or ent ~= hg.GetCurrentCharacter(lp) then return false end
	local head = ent:LookupBone("ValveBiped.Bip01_Head1")
	if not head then return false end
	local scale = ent:GetManipulateBoneScale(head)
	return scale and scale:LengthSqr() < 0.01
end

local function resetFlesh(ent, side)
	local state = ent.hgEyeFlesh
	if not state or not state[side] then return end
	state[side] = nil
	local mats = ent:GetMaterials() or {}
	for i, mat in ipairs(mats) do
		local name = string.lower(mat)
		if string.find(name, "eye") or string.find(name, "pupil") then
			if string.find(name, "%f[%a]" .. side .. "%f[%A]") or string.find(name, "_" .. side) then
				ent:SetSubMaterial(i - 1, "")
			end
		end
	end
end

local function applyFlesh(ent, side)
	local mats = ent:GetMaterials() or {}
	for i, mat in ipairs(mats) do
		local name = string.lower(mat)
		if string.find(name, "eye") or string.find(name, "pupil") then
			if string.find(name, "%f[%a]" .. side .. "%f[%A]") or string.find(name, "_" .. side) then
				ent:SetSubMaterial(i - 1, "models/flesh")
			end
		end
	end
end

local function spawnEye(ent, side)
	local cfg = eyeData[side]
	local attID = ent:LookupAttachment("eyes")
	if not attID or attID <= 0 then return end
	local att = ent:GetAttachment(attID)
	if not att then return end
	local wPos, wAng = LocalToWorld(cfg.bulge.offset, cfg.bulge.angle, att.Pos, att.Ang)
	local prop = ents.CreateClientProp(cfg.model)
	if not IsValid(prop) then return end
	prop:SetPos(wPos)
	prop:SetAngles(wAng)
	prop:Spawn()
	prop:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = prop:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetVelocity(att.Ang:Forward() * math.random(25, 50) + VectorRand(-5, 5))
	end
end

net.Receive("hg_eye_gore_pop", function()
	local ent = net.ReadEntity()
	local side = net.ReadString()
	if not IsValid(ent) or not eyeData[side] then return end
	spawnEye(ent, side)
end)

hook.Add("PostDrawOpaqueRenderables", "hg_eye_gore_draw", function()
	eachTarget(function(ent, org)
		if hiddenOwnHead(ent) or org.headamputated then return end
		local attID = ent:LookupAttachment("eyes")
		if not attID or attID <= 0 then return end
		local att = ent:GetAttachment(attID)
		if not att then return end
		for _, side in ipairs(sides) do
			local v = eyeValue(org, side)
			ent.hgEyeFlesh = ent.hgEyeFlesh or {}
			if v < 1 then
				resetFlesh(ent, side)
			else
				if not ent.hgEyeFlesh[side] then
					ent.hgEyeFlesh[side] = true
					applyFlesh(ent, side)
				end
				if eyePopped(org, side) then continue end
				local cfg = eyeData[side]
				local hanging = v >= 1
				local offset = hanging and cfg.hang.offset or cfg.bulge.offset
				local angle = hanging and cfg.hang.angle or cfg.bulge.angle
				local m = eyeModel(cfg.model)
				if not IsValid(m) then continue end
				local wPos, wAng = LocalToWorld(offset, angle, att.Pos, att.Ang)
				m:SetPos(wPos)
				m:SetAngles(wAng)
				m:SetupBones()
				m:DrawModel()
			end
		end
	end)
end)
