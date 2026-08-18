local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local GIB_MAX_SPEED = 3000
local GIB_MAX_SPEED_SQR = GIB_MAX_SPEED * GIB_MAX_SPEED

local function ClampGibVelocity(vel)
	if vel:LengthSqr() > GIB_MAX_SPEED_SQR then
		return vel:GetNormalized() * GIB_MAX_SPEED
	end
	return vel
end

local function removeBone(rag, bone, phys_bone, nohuys)
	if not bone or not phys_bone or phys_bone < 0 then return end
	if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	if not IsValid(phys_obj) then return end
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)
	phys_obj:SetVelocity(vecZero)
	phys_obj:SetAngleVelocity(vecZero)

	constraint.RemoveAll(phys_obj)
	rag.gibRemove[phys_bone] = phys_obj
end

local function recursive_bone(rag, bone, list)
	for i,bone in pairs(rag:GetChildBones(bone)) do
		if bone == 0 then continue end

		list[#list + 1] = bone

		recursive_bone(rag, bone, list)
	end
end

function Gib_RemoveBone(rag, bone, phys_bone, nohuys)
	rag.gibRemove = rag.gibRemove or {}

	removeBone(rag, bone, phys_bone, nohuys)

	local list = {}
	recursive_bone(rag, bone, list)
	for i, bone in pairs(list) do
		removeBone(rag, bone, rag:TranslateBoneToPhysBone(bone), nohuys)
	end
end

gib_ragdols = gib_ragdols or {}
local gib_ragdols = gib_ragdols

local activeGibCount = 0
local MAX_ACTIVE_GIBS = CreateConVar("hg_max_active_gibs", "512", FCVAR_ARCHIVE, "Maximum number of active gib physics entities at once", 8, 2048)

local VectorRand, ents_Create = VectorRand, ents.Create
local vector_up = Vector(0,0,1)
local networkOriginLimit = 16000
local function isSafeNetworkPos(pos)
	if not isvector(pos) then return false end
	return pos.x == pos.x and pos.y == pos.y and pos.z == pos.z
		and math.abs(pos.x) < networkOriginLimit
		and math.abs(pos.y) < networkOriginLimit
		and math.abs(pos.z) < networkOriginLimit
end

local function PhysCallback(ent, data)
	--data.HitPos -- data.HitNormal
	if not IsValid(ent) or not data or not isnumber(data.Speed) or data.Speed < 80 then return end
	local now = CurTime()
	if (ent.hgGoreNextImpact or 0) > now then return end
	ent.hgGoreNextImpact = now + 0.4
	ent.hgGoreImpactSounds = (ent.hgGoreImpactSounds or 0) + 1
	ent:EmitSound("physics/flesh/flesh_squishy_impact_hard"..math.random(4)..".wav")
	-- if !data.HitEntity:IsPlayer() and !data.HitEntity:IsRagdoll() and math.abs(data.HitNormal.z) < 0.75 then
	-- 	ent:SetMoveType(MOVETYPE_NONE)
	-- 	ent:SetSolid(SOLID_NONE)

	-- 	local tr = util.QuickTrace(data.HitPos - data.HitNormal * 1, data.HitNormal)
	-- 	ent:SetPos(tr.HitPos)
	-- 	local entindex = ent:EntIndex()
	-- 	local speed = math.Rand(0.2,0.4)
	-- 	local randspeed = math.Rand(-0.3,0.3)
	-- 	local needDecal = CurTime() + 1
	-- 	ent:SetModelScale(0, 10)
	-- 	SafeRemoveEntityDelayed(ent, 10)
	-- 	timer.Create("meatMove"..entindex, 0.1, 0, function()
	-- 		if !IsValid(ent) then timer.Remove("meatMove"..entindex) return end
	-- 		local tr = util.QuickTrace(ent:GetPos(), -data.HitNormal:Angle():Up())
	-- 		if math.abs(tr.HitNormal.z) > 0.75 then timer.Remove("meatMove"..entindex) return end
	-- 		local ang = data.HitNormal:Angle()
	-- 		ent:SetPos(ent:GetPos() - ang:Up() * speed + ang:Right() * randspeed)
	-- 		randspeed = LerpFT(0.05,randspeed, 0)
	-- 		if needDecal < CurTime() then
	-- 			needDecal = CurTime() + math.Rand(1,3)
	-- 			util.Decal("Normal.Blood24", ent:GetPos() - data.HitNormal * 1, ent:GetPos() + data.HitNormal * 1, ent)
	-- 		end
	-- 	end)
	-- end

	if not ent.hgGoreImpactDecal and isvector(data.HitPos) and isvector(data.HitNormal) then
		ent.hgGoreImpactDecal = true
		util.Decal("Normal.Blood24", data.HitPos - data.HitNormal, data.HitPos + data.HitNormal, ent)
	end

	if ent.hgGoreImpactSounds >= 2 and ent.hgGoreCallbackID then
		ent:RemoveCallback("PhysicsCollide", ent.hgGoreCallbackID)
		ent.hgGoreCallbackID = nil
	end
end

local function AddGorePhysicsCallback(ent)
	ent.hgGoreCallbackID = ent:AddCallback("PhysicsCollide", PhysCallback)
end

local grub, mat, gamemod = Model("models/grub_nugget_small.mdl"), "models/flesh", engine.ActiveGamemode()
local meatModels = {
	Model("models/gore/debris_goredebris01.mdl"),
	Model("models/gore/debris_goredebris02.mdl"),
	Model("models/gore/debris_goredebris03.mdl"),
	Model("models/gore/debris_goredebris04.mdl"),
}
local eyeModels = {
	Model("models/gore/head_eye01.mdl"),
	Model("models/gore/head_eye02.mdl"),
}
for _, mdl in ipairs(meatModels) do util.PrecacheModel(mdl) end
for _, mdl in ipairs(eyeModels) do util.PrecacheModel(mdl) end
local gibRemoveTime = 60 --120
function SpawnMeatGore(mainent, pos, count, force, scale, spawnEyes, models)
	if activeGibCount >= MAX_ACTIVE_GIBS:GetInt() then return end
	if istable(spawnEyes) then
		models = spawnEyes
		spawnEyes = false
	end
	models = istable(models) and #models > 0 and models or meatModels
	force = force or Vector(0,0,0)
	models = models or meatModels
	for i = 1, (count or math.random(8, 10)) do
		local ent = ents_Create("prop_physics")
		if not IsValid(ent) then continue end
		ent:SetModel(models[math.random(#models)])
		if models == meatModels then ent:SetSubMaterial(0, mat) end
		ent:SetPos(pos)
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetModelScale(math.Rand(0.8,1.1) * (scale or 1))
		ent:SetAngles(AngleRand(-180,180))
		ent:Activate()
		ent:Spawn()
		ent.dontPickup = true

		activeGibCount = activeGibCount + 1
		ent:CallOnRemove("hg_gib_counter", function()
			activeGibCount = math.max(activeGibCount - 1, 0)
		end)

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(ClampGibVelocity((IsValid(mainent) and mainent:GetVelocity() or vector_origin) + VectorRand(-65,65) + force / 10))
			phys:AddAngleVelocity(VectorRand(-65,65))
		end

		if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
			ent:DrawShadow(false)
			ent:SetModelScale(0, gibRemoveTime)
		end
		SafeRemoveEntityDelayed(ent, gibRemoveTime)

		AddGorePhysicsCallback(ent)

		local entIndex = ent:EntIndex()
		timer.Simple(0.2, function()
			if not IsValid(ent) then return end
			net.Start("hg_gib_bloodspill")
			net.WriteUInt(entIndex, 16)
			net.WriteFloat(math.Rand(1, 2))
			net.WriteBool(false)
			net.WriteBool(false)
			net.SendPVS(ent:GetPos())
		end)
	end

	if spawnEyes then
		for i = 1, math.random(1, 2) do
			local ent = ents_Create("prop_physics")
			if not IsValid(ent) then continue end
			ent:SetModel(eyeModels[math.random(#eyeModels)])
			ent:SetSubMaterial(0, mat)
			ent:SetPos(pos)
			ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
			ent:SetModelScale(math.Rand(0.8,1.1) * (scale or 1))
			ent:SetAngles(AngleRand(-180,180))
			ent:Activate()
			ent:Spawn()
			ent.dontPickup = true

			activeGibCount = activeGibCount + 1
			ent:CallOnRemove("hg_gib_counter", function()
				activeGibCount = math.max(activeGibCount - 1, 0)
			end)

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(ClampGibVelocity((IsValid(mainent) and mainent:GetVelocity() or vector_origin) + VectorRand(-65,65) + force / 10))
				phys:AddAngleVelocity(VectorRand(-65,65))
			end

			if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
				ent:DrawShadow(false)
				ent:SetModelScale(0, gibRemoveTime)
			end
			SafeRemoveEntityDelayed(ent, gibRemoveTime)

			AddGorePhysicsCallback(ent)
		end
	end
end

local headpos_male, headpos_female, headang = Vector(0,0,5), Vector(-2,0,4), Angle(0,0,0)

util.AddNetworkString("addfountain")
util.AddNetworkString("hg_gib_bloodspill")
util.AddNetworkString("hg_fullbody_gibspill")
util.AddNetworkString("hg_fullbody_bloodmist")

-- Remove the obsolete whole-table fountain snapshot after a hot reload.
timer.Simple(0, function()
	for ent in pairs(hg.fountains or {}) do
		if IsValid(ent) then
			ent:SetNW2Bool("hg_fountain", true)
			if ent.RemoveCallOnRemove then ent:RemoveCallOnRemove("removefountain") end
		end
	end
	if zb and zb.net and zb.net.globals then zb.net.globals.fountains = nil end
	hg.fountains = nil
end)

local headModels = {
	Model("models/headpartial/headpartial1.mdl"),
	Model("models/headpartial/headpartial2.mdl"),
	Model("models/headpartial/headpartial3.mdl"),
	Model("models/headpartial/headpartial4.mdl"),
	Model("models/headpartial/headpartial5.mdl"),
}
local headGibModels = {
	Model("models/gore/head_headbitfrontleft.mdl"),
	Model("models/gore/head_headbitfrontright.mdl"),
	Model("models/gore/head_headbitbackleft.mdl"),
	Model("models/gore/head_headbitbackright.mdl"),
	Model("models/gore/head_headbittopleft.mdl"),
	Model("models/gore/head_headbittopright.mdl"),
	Model("models/gore/head_eye01.mdl"),
	Model("models/gore/head_eye02.mdl"),
	Model("models/gore/head_jawlo.mdl"),
}
local fullBodySounds = {
	Sound("fullbodyexplode/rem_fullbodygib1.wav"),
	Sound("fullbodyexplode/rem_fullbodygib2.wav"),
	Sound("fullbodyexplode/rem_fullbodygib3.wav"),
}
local fullBodyMainSound = Sound("fullbodyexplode/rem_fullbodygibmain.mp3")
local fullBodyGibModels = {
	stomach = {
		Model("models/gore/pelvis.mdl"),
		Model("models/gore/uppertorso.mdl"),
	},
	rleg = {Model("models/gore/rleg_meatbit001r.mdl")},
	lleg = {Model("models/gore/lleg_meatbit001l.mdl")},
	larm = {
		Model("models/gore/larm_armgorehandl.mdl"),
		Model("models/gore/larm_armgoreupperl.mdl"),
	},
}
for _, model in ipairs(headModels) do
	util.PrecacheModel(model)
end
for _, model in ipairs(headGibModels) do
	util.PrecacheModel(model)
end
for _, models in pairs(fullBodyGibModels) do
	for _, model in ipairs(models) do util.PrecacheModel(model) end
end
local sounds = {
	Sound("player/zombie_head_explode_01.wav"),
	Sound("player/zombie_head_explode_02.wav"),
	Sound("player/zombie_head_explode_03.wav"),
	Sound("player/zombie_head_explode_04.wav"),
	Sound("player/zombie_head_explode_05.wav"),
	Sound("player/zombie_head_explode_06.wav")
}
for _, snd in ipairs(sounds) do
	util.PrecacheSound(snd)
end
for _, snd in ipairs(fullBodySounds) do util.PrecacheSound(snd) end
util.PrecacheSound(fullBodyMainSound)
local function sendGibBloodSpill(ent, stump, trail)
	if not IsValid(ent) then return end
	net.Start("hg_gib_bloodspill")
	net.WriteUInt(ent:EntIndex(), 16)
	net.WriteFloat(math.Rand(5, 10))
	net.WriteBool(stump or false)
	net.WriteBool(trail or false)
	net.SendPVS(ent:GetPos())
end

local function getHeadGoreStage(damage)
	return math.Clamp(math.ceil(math.max((damage or 0) - 175, 0) / 5), 1, 5)
end

local function getInitialHeadGoreStage(damage)
	return math.min(getHeadGoreStage(damage), table.Random({1,1,1,1,2,2,2,3,4,5}))
end

local function setupHeadGore(ent, rag, stage)
	if not IsValid(ent) or not IsValid(rag) or not headModels[stage] then return end
	ent:SetModel(headModels[stage])
	local att = rag:GetAttachment(3)
	local pos, ang
	if att then
		pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and headpos_female or headpos_male, headang, att.Pos, att.Ang)
	else
		local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
		local matrix = headBone and rag:GetBoneMatrix(headBone)
		pos = matrix and matrix:GetTranslation() or rag:GetPos()
		ang = matrix and matrix:GetAngles() or rag:GetAngles()
	end
	ent:SetPos(pos)
	ent:SetAngles(ang)
	if att then ent:SetParent(rag, 3) else ent:SetParent(rag) end
	return pos
end

function Gib_UpdateHeadGoreStage(rag, damage)
	if not IsValid(rag) or not rag.headexploded then return end
	local stage = getHeadGoreStage(damage)
	if (rag.headGoreStage or 0) >= stage then return end

	rag.headGoreStage = stage
	if IsValid(rag.headGore) then
		rag.headGore:SetModel(headModels[stage])
		sendGibBloodSpill(rag.headGore, true)
		SpawnMeatGore(rag.headGore, rag.headGore:GetPos(), 3, VectorRand(-120, 120), 0.45, false, headGibModels)
		return
	end

	local gore = ents_Create("prop_dynamic")
	if not IsValid(gore) then return end
	local pos = setupHeadGore(gore, rag, stage)
	if not pos then gore:Remove() return end
	gore:Spawn()
	rag.headGore = gore
	sendGibBloodSpill(gore, true)
	SpawnMeatGore(gore, pos, 3, VectorRand(-120, 120), 0.45, false, headGibModels)
	rag:CallOnRemove("remove_head_gore", function()
		if IsValid(gore) then gore:Remove() end
	end)
end

function Gib_Input(rag, bone, force, damage)
	if not IsValid(rag) then return end
	if not bone then return end
	
	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove
	end

	if not gib_ragdols[rag] then
		gib_ragdols[rag] = true
		rag:CallOnRemove("cleanup_gib_ragdols", function(ent)
			gib_ragdols[ent] = nil
		end)
	end
	
	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	if phys_bone < 0 or not IsValid(phys_obj) then return end
	
	if (not gibRemove[phys_bone]) and (bone == rag:LookupBone("ValveBiped.Bip01_Head1")) then
		--sound.Emit(rag,"player/headshot" .. math.random(1, 2) .. ".wav")
		--sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		--sound.Emit(rag,"physics/body/body_medium_break3.wav")
		--sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav", 90, 50, 2)
		rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(115, 125), 2)

		Gib_RemoveBone(rag, bone, phys_bone)
		
		--rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Neck1"),vecZero)
		local neckBone = rag:LookupBone("ValveBiped.Bip01_Neck1")
		if neckBone then rag:ManipulateBonePosition(neckBone, Vector(-1,0,0)) end

		local stage = getInitialHeadGoreStage(damage)
		local headVis = ents_Create("prop_dynamic")
		if not IsValid(headVis) then return end
		local pos = setupHeadGore(headVis, rag, stage)
		if not pos then headVis:Remove() return end
		headVis:Spawn()
		rag.headGore = headVis
		rag.headGoreStage = stage
		sendGibBloodSpill(headVis, true)

		SpawnMeatGore(headVis, pos, nil, force, nil, false, headGibModels)
		rag:CallOnRemove("remove_head_gore", function()
			if IsValid(headVis) then headVis:Remove() end
		end)

		local armors = rag:GetNetVar("Armor",{})

		if armors["head"] and hg.armor["head"] and hg.armor["head"][armors["head"]] and !hg.armor["head"][armors["head"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["head"])
			if IsValid(ent) then ent:SetPos(phys_obj:GetPos()) end
		end
		
		if armors["face"] and hg.armor["face"] and hg.armor["face"][armors["face"]] and !hg.armor["face"][armors["face"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["face"])
			if IsValid(ent) then ent:SetPos(phys_obj:GetPos()) end
		end

		rag.noHead = true
		rag:SetNWString("PlayerName", "Beheaded body")

		rag:SetNW2Bool("hg_fountain", true)

		net.Start("addfountain")
		net.WriteEntity(rag)
		net.WriteUInt(rag:EntIndex(), 16)
		net.WriteVector(force or vector_origin)
		net.SendPVS(rag:GetPos())

	end
end

local stomachGoreModel = Model("models/noob_dev2323/gib/intestine.mdl")
local intestineChunkModels = {
	Model("models/mosi/fnv/props/gore/meatbit02.mdl"),
	Model("models/mosi/fnv/props/gore/meatbit03.mdl"),
	Model("models/mosi/fnv/props/gore/meatbit01.mdl"),
	Model("models/mosi/fnv/props/gore/goreintestine.mdl"),
}
util.PrecacheModel(stomachGoreModel)
for _, model in ipairs(intestineChunkModels) do util.PrecacheModel(model) end

local function getStomachBone(ent)
	return ent:LookupBone("ValveBiped.Bip01_Spine1") or ent:LookupBone("ValveBiped.Bip01_Spine") or ent:LookupBone("ValveBiped.Bip01_Pelvis") or 0
end

local function setupStomachGoreParent(gore, ent)
	if not IsValid(gore) or not IsValid(ent) then return false end
	gore:SetParent(ent)
	gore:AddEffects(EF_BONEMERGE)
	gore:SetSolid(SOLID_NONE)
	return true
end

local function clearStomachGoreRefs(gore)
	if IsValid(gore.StomachGoreHost) and gore.StomachGoreHost.StomachGoreEnt == gore then gore.StomachGoreHost.StomachGoreEnt = nil end
	if IsValid(gore.StomachGoreOwner) and gore.StomachGoreOwner.StomachGoreEnt == gore then gore.StomachGoreOwner.StomachGoreEnt = nil end
end

local function bindStomachGore(gore, host, owner)
	local oldHost = gore.StomachGoreHost
	if IsValid(oldHost) and oldHost.RemoveCallOnRemove then oldHost:RemoveCallOnRemove("remove_stomach_gore") end
	if IsValid(oldHost) and oldHost.StomachGoreEnt == gore then oldHost.StomachGoreEnt = nil end
	if not setupStomachGoreParent(gore, host) then return false end

	gore.StomachGoreHost = host
	gore.StomachGoreOwner = owner
	host.StomachGoreEnt = gore
	if IsValid(owner) then owner.StomachGoreEnt = gore end
	host:CallOnRemove("remove_stomach_gore", function()
		if IsValid(gore) then gore:Remove() end
	end)
	return true
end

local function getFullBodyPos(ent)
	local pos, count = vector_origin, 0
	for _, name in ipairs({"ValveBiped.Bip01_Pelvis", "ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Head1"}) do
		local bone = ent:LookupBone(name)
		local physBone = bone and ent:TranslateBoneToPhysBone(bone)
		local phys = physBone and physBone >= 0 and ent:GetPhysicsObjectNum(physBone)
		if IsValid(phys) then
			pos = pos + phys:GetPos()
			count = count + 1
		end
	end

	if count > 0 then return pos / count end
	return ent:WorldSpaceCenter()
end

local function getFullBodyOwner(ent)
	if not IsValid(ent) then return end
	if ent:IsPlayer() then return ent end
	return ent:IsRagdoll() and hg.RagdollOwner(ent) or IsValid(ent.ply) and ent.ply or ent:GetNWEntity("ply")
end

function hg.CanFullBodyGib(target, org, owner, removed)
	if not IsValid(target) then return false end
	org = org or target.organism
	owner = owner or getFullBodyOwner(target)
	if org and (org.godmode or org.fullbodyexploded) then return false end
	if org and not org.isPly and not IsValid(owner) then return true end
	if removed then
		if IsValid(owner) and owner:IsPlayer() then return owner.Removed or not owner:Alive() end
		return org and (org.alive == false or org.headamputated) or false
	end
	if org and (org.otrub or org.alive == false or org.headamputated or (org.consciousness or 1) <= 0.1) then return true end
	if IsValid(owner) and (owner.Removed or not owner:Alive()) then return true end
	-- Живых игроков можно разорвать (взрывом/ударом), godmode отсекается выше.
	return true
end

hg.fullBodyGibGroups = hg.fullBodyGibGroups or {}
local fullBodyGibGroups = hg.fullBodyGibGroups
hg.fullBodyGibGroupSerial = hg.fullBodyGibGroupSerial or 0
local fullBodyGibMaxGroups = CreateConVar("hg_fullbody_gib_max_groups", "8", FCVAR_ARCHIVE, "Maximum full-body gib groups before old distant groups are removed", 1, 64)
local fullBodyGibCleanupAge = CreateConVar("hg_fullbody_gib_cleanup_age", "12", FCVAR_ARCHIVE, "Minimum age of a distant full-body gib group eligible for pressure cleanup", 0, 60)
local fullBodyGibSafeDistance = CreateConVar("hg_fullbody_gib_safe_distance", "2500", FCVAR_ARCHIVE, "Player protection radius for full-body gib pressure cleanup", 0, 16000)

local function createFullBodyGibGroup(pos)
	repeat
		hg.fullBodyGibGroupSerial = hg.fullBodyGibGroupSerial % 2147483647 + 1
	until not fullBodyGibGroups[hg.fullBodyGibGroupSerial]
	local group = {
		id = hg.fullBodyGibGroupSerial,
		created = CurTime(),
		pos = pos,
		gibs = {},
		spillGibs = {},
		liveCount = 0
	}
	fullBodyGibGroups[group.id] = group
	return group
end

local function registerFullBodyGib(group, gib, bloodSpill)
	if not group or not IsValid(gib) then return end
	group.gibs[#group.gibs + 1] = gib
	group.liveCount = group.liveCount + 1
	if bloodSpill then group.spillGibs[#group.spillGibs + 1] = gib end
	gib:SetNW2Int("hg_fullbody_gib_group", group.id)

	gib:CallOnRemove("hg_fullbody_gib_group_"..group.id, function()
		group.liveCount = math.max(group.liveCount - 1, 0)
		if group.liveCount == 0 then fullBodyGibGroups[group.id] = nil end
	end)
end

local function removeFullBodyGibGroup(group)
	if not group or group.removing then return end
	group.removing = true
	for _, gib in ipairs(group.gibs) do
		if IsValid(gib) then gib:Remove() end
	end
	if group.liveCount == 0 then fullBodyGibGroups[group.id] = nil end
end

local function cleanupFullBodyGibGroups()
	local count = table.Count(fullBodyGibGroups)
	local maxGroups = fullBodyGibMaxGroups:GetInt()
	if count <= maxGroups then return end

	local now = CurTime()
	local safeDistanceSqr = fullBodyGibSafeDistance:GetFloat() ^ 2
	while count > maxGroups do
		local candidate
		for _, group in pairs(fullBodyGibGroups) do
			if group.removing or now - group.created < fullBodyGibCleanupAge:GetFloat() then continue end

			local protected = false
			for _, ply in player.Iterator() do
				if IsValid(ply) and group.pos:DistToSqr(ply:GetPos()) <= safeDistanceSqr then
					protected = true
					break
				end
			end
			if protected then continue end
			if not candidate or group.created < candidate.created then candidate = group end
		end

		if not candidate then return end
		removeFullBodyGibGroup(candidate)
		count = count - 1
	end
end

local function sendFullBodyGibSpills(group)
	if not group or group.removing then return end
	local valid = {}
	for _, gib in ipairs(group.spillGibs) do
		if IsValid(gib) then valid[#valid + 1] = gib end
	end
	if #valid == 0 then return end

	net.Start("hg_fullbody_gibspill")
	net.WriteUInt(group.id, 32)
	net.WriteUInt(#valid, 8)
	for _, gib in ipairs(valid) do net.WriteUInt(gib:EntIndex(), 16) end
	local recipients = RecipientFilter()
	for _, gib in ipairs(valid) do recipients:AddPVS(gib:GetPos()) end
	net.Send(recipients)
end

local function spawnFullBodyGib(mainent, pos, force, model, scale, bloodSpill, group)
	if activeGibCount >= MAX_ACTIVE_GIBS:GetInt() then return end
	local ent = ents_Create("prop_physics")
	if not IsValid(ent) then return end
	ent:SetModel(model)
	ent:SetPos(pos + VectorRand(-8, 8))
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetModelScale(scale or math.Rand(0.95, 1.15))
	ent:SetAngles(AngleRand(-180, 180))
	ent:Activate()
	ent:Spawn()
	ent.dontPickup = true

	activeGibCount = activeGibCount + 1
	ent:CallOnRemove("hg_gib_counter", function()
		activeGibCount = math.max(activeGibCount - 1, 0)
	end)

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local baseVel = IsValid(mainent) and mainent:GetVelocity() or isvector(mainent) and mainent or vector_origin
		phys:SetVelocity(ClampGibVelocity(baseVel + VectorRand(-260, 260) + (force or vector_origin) / 7))
		phys:AddAngleVelocity(VectorRand(-320, 320))
	end

	AddGorePhysicsCallback(ent)
	SafeRemoveEntityDelayed(ent, gibRemoveTime)
	registerFullBodyGib(group, ent, bloodSpill)
	return ent
end

local function fullBodyBloodMist(pos, force)
	net.Start("hg_fullbody_bloodmist")
	net.WriteVector(pos)
	net.WriteVector(force or vector_origin)
	net.WriteUInt(48, 8)
	net.SendPVS(pos)
end

local function spawnFullBodyGroup(ent, pos, force, models, group)
	for _, model in ipairs(models) do
		spawnFullBodyGib(ent, pos, force, model, nil, true, group)
	end
end

local function spawnFullBodyMeat(ent, pos, count, force, scale, models, group)
	models = models or meatModels
	for _ = 1, count do
		local gib = spawnFullBodyGib(ent, pos, force, models[math.random(#models)], scale, false, group)
		if models == meatModels and IsValid(gib) then gib:SetSubMaterial(0, mat) end
	end
end

local function fullBodyExplodeAt(pos, force, velocity, org, soundEnt, owner, dmgInfo)
	force = force or vector_origin
	velocity = velocity or vector_origin

	if IsValid(soundEnt) then
		soundEnt:EmitSound(fullBodySounds[math.random(#fullBodySounds)], 85, math.random(95, 105), 1.4)
		soundEnt:EmitSound(fullBodyMainSound, 90, math.random(96, 104), 1)
	else
		sound.Play(fullBodySounds[math.random(#fullBodySounds)], pos, 85, math.random(95, 105), 1.4)
		sound.Play(fullBodyMainSound, pos, 90, math.random(96, 104), 1)
	end

	fullBodyBloodMist(pos, force)
	util.ScreenShake(pos, 19.8, 10, 1.5, 500, false, nil, 1.5, true, true, true)
	local gibGroup = createFullBodyGibGroup(pos)
	if not (org and org.stomachgibbed) then
		spawnFullBodyGroup(velocity, pos, force, fullBodyGibModels.stomach, gibGroup)
		spawnFullBodyMeat(velocity, pos, 6, force, 0.55, intestineChunkModels, gibGroup)
	end

	for _, limb in ipairs({"lleg", "rleg", "larm"}) do
		if not (org and org[limb.."amputated"]) then
			spawnFullBodyGroup(velocity, pos, force, fullBodyGibModels[limb], gibGroup)
			spawnFullBodyMeat(velocity, pos, 4, force, 0.65, nil, gibGroup)
		end
	end

	if not (org and org.rarmamputated) then spawnFullBodyMeat(velocity, pos, 5, force, 0.65, nil, gibGroup) end
	if not (org and org.headamputated) then spawnFullBodyMeat(velocity, pos, 8, force, 0.8, headGibModels, gibGroup) end

	if gibGroup.liveCount > 0 then
		timer.Simple(0.2, function() sendFullBodyGibSpills(gibGroup) end)
	else
		fullBodyGibGroups[gibGroup.id] = nil
	end
	cleanupFullBodyGibGroups()

	if IsValid(owner) then
		owner.fullbodyexploded = true
		owner:SetNWEntity("FakeRagdoll", NULL)
		owner:SetNWEntity("RagdollDeath", NULL)
		owner.FakeRagdoll = nil
		if owner:Alive() then
			local wasRemoved = owner.Removed
			owner.Removed = true
			owner:Kill()
			timer.Simple(0, function()
				if IsValid(owner) then owner.Removed = wasRemoved end
			end)
		end
	end

	if org then org.fullbodyexploded = true end
	hook.Run("OnFullBodyExplode", soundEnt, org, owner, dmgInfo)
end

timer.Create("HG_FullBodyGibPressureCleanup", 5, 0, cleanupFullBodyGibGroups)

function hg.FullBodyExplode(target, force, dmgInfo)
	if not IsValid(target) or target.fullbodyexploded then return end

	if target:IsPlayer() then
		local ply = target
		local function getBody()
			local fake = ply.FakeRagdoll
			if IsValid(fake) then return fake end

			local death = ply:GetNWEntity("RagdollDeath")
			if IsValid(death) then return death end
		end

		local rag = getBody()
		if IsValid(rag) then return hg.FullBodyExplode(rag, force, dmgInfo) end
		if not ply:Alive() or not hg.CanFullBodyGib(ply, ply.organism, ply) then return end
		if ply.hgFullBodyExplodePending then return true end

		ply.hgFullBodyExplodePending = true
		local deadline = CurTime() + 0.5
		local function acquireBody()
			if not IsValid(ply) or not ply:Alive() or ply.fullbodyexploded then
				if IsValid(ply) then ply.hgFullBodyExplodePending = nil end
				return
			end

			local body = getBody()
			if IsValid(body) then
				ply.hgFullBodyExplodePending = nil
				hg.FullBodyExplode(body, force, dmgInfo)
				return
			end

			if CurTime() >= deadline then
				ply.hgFullBodyExplodePending = nil
				return
			end

			if not ply.hgRagdollCreating and (ply.hgRagdollCreateRetry or 0) <= CurTime() then
				local moveType = ply:GetMoveType()
				if moveType == MOVETYPE_NONE then ply:SetMoveType(MOVETYPE_WALK) end
				hg.Fake(ply, nil, true, true)
				if IsValid(ply) and moveType == MOVETYPE_NONE then ply:SetMoveType(moveType) end
			end
			timer.Simple(0.05, acquireBody)
		end

		acquireBody()
		return true
	end

	local ent = target
	local org = ent.organism
	local owner = ent:IsRagdoll() and hg.RagdollOwner(ent) or nil
	if not org and IsValid(owner) then org = owner.organism end
	if org and org.godmode then return end
	if not hg.CanFullBodyGib(ent, org, owner) then return end

	ent.fullbodyexploded = true
	if org then org.fullbodyexploded = true end
	force = force or vector_origin
	local explodePos = getFullBodyPos(ent)
	if isSafeNetworkPos(explodePos) then
		fullBodyExplodeAt(explodePos, force, ent:GetVelocity(), org, ent, owner, dmgInfo)
	else
		if IsValid(owner) then
			owner.fullbodyexploded = true
			owner:SetNWEntity("FakeRagdoll", NULL)
			owner:SetNWEntity("RagdollDeath", NULL)
			owner.FakeRagdoll = nil
			if owner:Alive() then
				local wasRemoved = owner.Removed
				owner.Removed = true
				owner:Kill()
				timer.Simple(0, function()
					if IsValid(owner) then owner.Removed = wasRemoved end
				end)
			end
		end
		hook.Run("OnFullBodyExplode", ent, org, owner, dmgInfo)
	end

	if IsValid(ent.headGore) then ent.headGore:Remove() end
	if IsValid(ent.zippyHeadGore) then ent.zippyHeadGore:Remove() end
	if IsValid(ent.StomachGoreEnt) then ent.StomachGoreEnt:Remove() end
	ent:Remove()
	return true
end

function hg.AttachStomachGore(target, force)
	if not IsValid(target) then return end
	local ent = target
	if target:IsPlayer() and IsValid(target.FakeRagdoll) then ent = target.FakeRagdoll end
	if IsValid(ent.StomachGoreEnt) or IsValid(target.StomachGoreEnt) then return end

	local gore = ents_Create("prop_dynamic")
	if not IsValid(gore) then return end
	gore:SetModel(stomachGoreModel)
	if not bindStomachGore(gore, ent, target) then gore:Remove() return end
	gore:Spawn()
	gore:CallOnRemove("clear_stomach_gore_refs", function() clearStomachGoreRefs(gore) end)

	local bone = getStomachBone(ent)
	local matrix = ent:GetBoneMatrix(bone)
	local pos = matrix and matrix:GetTranslation() or ent:GetPos()
	ent:SetNWBool("NoVomitView", true)
	if target ~= ent then target:SetNWBool("NoVomitView", true) end
	ent:EmitSound(sounds[math.random(#sounds)], 70, math.random(95, 105), 1)
	sendGibBloodSpill(gore, true)
	SpawnMeatGore(ent, pos, 4, force, 0.7)
	SpawnMeatGore(ent, pos, 6, force or VectorRand(-120, 120), 0.55, false, intestineChunkModels)

	local owner = target:IsPlayer() and target or ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
	if ent.organism then ent.organism.stomachgibbed = true end
	if target.organism then target.organism.stomachgibbed = true end
	if IsValid(owner) and owner.organism then
		local org = owner.organism
		org.stomachgibbed = true
		hg.organism.AddWoundManual(owner, 160, vector_origin, Angle(0,0,0), bone, CurTime())
		org.internalBleed = (org.internalBleed or 0) + 3
		org.bleed = math.max(org.bleed or 0, 1.2)
		org.painadd = (org.painadd or 0) + 25
		org.shock = math.min((org.shock or 0) + 12, 70)
	end
end

local function reparentStomachGore(fromEnt, toEnt)
	if not IsValid(fromEnt) or not IsValid(toEnt) then return end
	local gore = fromEnt.StomachGoreEnt
	if not IsValid(gore) then return end
	bindStomachGore(gore, toEnt, IsValid(gore.StomachGoreOwner) and gore.StomachGoreOwner or toEnt)
end

hook.Add("Player Spawn", "HG_ClearStomachGoreOnSpawn", function(ply)
	if IsValid(ply.StomachGoreEnt) then ply.StomachGoreEnt:Remove() end
	ply.StomachGoreEnt = nil
	ply:SetNWBool("NoVomitView", false)
end)
hook.Add("Fake", "HG_ReparentStomachGoreToRag", function(ply, rag) reparentStomachGore(ply, rag) end)
hook.Add("Fake Up", "HG_ReparentStomachGoreToPlayer", function(ply, rag) reparentStomachGore(rag, ply) end)
hook.Add("Player Getup", "HG_ReparentStomachGorePlayerGetup", function(ply)
	if IsValid(ply) and IsValid(ply.FakeRagdoll) then reparentStomachGore(ply.FakeRagdoll, ply) end
end)
hook.Add("RagdollDeath", "HG_StomachGoreDeathRag", function(ply, rag) reparentStomachGore(ply, rag) end)

-- Fullgib при падении в пропасть / триггер смерти (за пределы мира или kill-trigger)
local voidFallMinVelocity = CreateConVar("hg_void_fall_min_velocity", "700", FCVAR_ARCHIVE, "Vertical fall speed (units/s) at/above which falling off the map triggers fullgib", 0, 100000)

local function isFallingOutOfWorld(ply)
	if not IsValid(ply) then return false end

	local vel = ply:GetVelocity()
	if vel.z > -voidFallMinVelocity:GetFloat() then return false end

	-- Падаем вниз с большой скоростью. Если прямо под игроком нет мира (пустота/пропасть),
	-- считаем что он падает из мира. Трассируем глубоко вниз и проверяем, что земли нет.
	local pos = ply:GetPos()
	local tr = util.TraceLine({
		start = pos,
		endpos = pos + Vector(0, 0, -30000),
		mask = MASK_SOLID,
		filter = function(e) return e ~= ply end,
	})
	if tr.Hit or tr.HitWorld or tr.HitNonWorld then return false end

	return true
end

hook.Add("PlayerDeath", "HG_FullGibOnVoidFall", function(ply)
	if not isFallingOutOfWorld(ply) then return end
	ply.hgVoidFall = true
end)

hook.Add("PostPlayerDeath", "HG_FullGibOnVoidFallRag", function(ply)
	if not ply.hgVoidFall then return end
	ply.hgVoidFall = nil

	if not IsValid(ply) or not ply.organism then return end
	local org = ply.organism
	if org and (org.godmode or org.fullbodyexploded) then return end

	-- Если уже есть death-регдолл - рвём его. Иначе ставим на следующий тик,
	-- когда движок создаст регдолл смерти.
	local function explodeDeathRag()
		local rag = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply:GetNWEntity("RagdollDeath")
		if not IsValid(rag) then return end
		if not hg.CanFullBodyGib(rag, rag.organism, hg.RagdollOwner(rag)) then return end
		hg.FullBodyExplode(rag, ply:GetVelocity() or vector_origin, nil)
	end

	if IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("RagdollDeath")) then
		explodeDeathRag()
	else
		timer.Simple(0, explodeDeathRag)
	end
end)
