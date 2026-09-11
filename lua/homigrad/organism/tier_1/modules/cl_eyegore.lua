local applied = {}
local scanTime
local sideList = {"L", "R"}

local eyeProtrudeData = {
	L = {"models/gore/head_eye02.mdl", Vector(-4, 0, -2), Angle(10, 0, 0)},
	R = {"models/gore/head_eye01.mdl", Vector(-4, 0.25, -2), Angle(10, 0, 0)}
}
local eyeModels = {}

local function ApplySocket(body, side)
	if not IsValid(body) then return end
	local mats = body:GetMaterials() or {}
	local appliedAny = false
	for i, matname in ipairs(mats) do
		local name = string.lower(matname)
		if string.find(name, "eye") or string.find(name, "pupil") then
			body:SetSubMaterial(i - 1, "models/flesh")
			appliedAny = true
		end
	end
	applied[body] = applied[body] or {}
	applied[body][side] = 2
	return appliedAny
end

local function ShouldSocket(body, side)
	local cur = body:GetNWInt("hg_eyegore_" .. side, 0)
	if cur < 2 then return end
	local done = applied[body]
	if done and done[side] == cur then return end
	return cur
end

hook.Add("Think", "hg_eyegore_scan", function()
	if not scanTime or CurTime() >= scanTime then
		scanTime = CurTime() + 0.5

		for _, ply in ipairs(player.GetAll()) do
			if not IsValid(ply) then continue end
			for _, side in ipairs(sideList) do
				if ShouldSocket(ply, side) then ApplySocket(ply, side) end
			end
		end

		for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
			if not IsValid(rag) then continue end
			for _, side in ipairs(sideList) do
				if ShouldSocket(rag, side) then ApplySocket(rag, side) end
			end
		end

		for ent in pairs(applied) do
			if not IsValid(ent) then applied[ent] = nil end
		end
	end
end)

local function DrawProtrudingEye(body, side)
	if body:GetNWInt("hg_eyegore_" .. side, 0) ~= 1 then return end
	if body:GetNW2Bool("hg_nohead") then return end

	local headIndex = body:LookupBone("ValveBiped.Bip01_Head1")
	if not headIndex or headIndex <= 0 then return end

	local attId = body:LookupAttachment("eyes")
	if not attId or attId <= 0 then return end
	local att = body:GetAttachment(attId)
	if not att then return end

	local data = eyeProtrudeData[side]
	local mdl = data[1]
	local ent = eyeModels[mdl]
	if not IsValid(ent) then
		ent = ClientsideModel(mdl, RENDERGROUP_OPAQUE)
		if IsValid(ent) then ent:SetNoDraw(true) end
		eyeModels[mdl] = ent
	end
	if not IsValid(ent) then return end

	local wPos, wAng = LocalToWorld(data[2], data[3], att.Pos, att.Ang)
	ent:SetPos(wPos)
	ent:SetAngles(wAng)
	ent:SetupBones()
	ent:DrawModel()
end

hook.Add("PostDrawOpaqueRenderables", "hg_eyegore_protrude", function()
	local lp = LocalPlayer()
	local thirdpersonCvar = GetConVar("hg_thirdperson")
	local thirdperson = thirdpersonCvar and thirdpersonCvar:GetBool() or false

	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) then continue end
		if ply == lp and ply:Alive() and not thirdperson then continue end
		for _, side in ipairs(sideList) do
			DrawProtrudingEye(ply, side)
		end
	end

	for _, rag in ipairs(ents.FindByClass("prop_ragdoll")) do
		if not IsValid(rag) then continue end
		for _, side in ipairs(sideList) do
			DrawProtrudingEye(rag, side)
		end
	end
end)
--MEDIC SPASIBO TEBE DRYG