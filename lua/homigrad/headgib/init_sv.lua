local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag, bone, phys_bone, nohuys)
	if not bone or not phys_bone or phys_bone < 0 then return end
	if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	if not IsValid(phys_obj) then return end
	phys_obj:EnableCollisions(false)
	phys_obj:SetMass(0.1)
	--rag:RemoveInternalConstraint(phys_bone)

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

local VectorRand, ents_Create = VectorRand, ents.Create
local vector_up = Vector(0,0,1)
local function PhysCallback( ent, data )
	--data.HitPos -- data.HitNormal
	if data.DeltaTime < 0.2 then return end
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

	util.Decal("Normal.Blood24", data.HitPos - data.HitNormal * 1, data.HitPos + data.HitNormal * 1, ent)
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
	if istable(spawnEyes) then
		models = spawnEyes
		spawnEyes = false
	end
	models = istable(models) and #models > 0 and models or meatModels
	force = force or Vector(0,0,0)
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

		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity((IsValid(mainent) and mainent:GetVelocity() or vector_origin) + VectorRand(-65,65) + force / 10)
			phys:AddAngleVelocity(VectorRand(-65,65))
		end

		if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
			ent:DrawShadow(false)
			ent:SetModelScale(0, gibRemoveTime)
			SafeRemoveEntityDelayed(ent, gibRemoveTime)
		end

		ent:AddCallback( "PhysicsCollide", PhysCallback )

		local entIndex = ent:EntIndex()
		timer.Simple(0.2, function()
			if not IsValid(ent) then return end
			net.Start("hg_gib_bloodspill")
			net.WriteUInt(entIndex, 16)
			net.WriteFloat(math.Rand(1, 2))
			net.WriteBool(false)
			net.Broadcast()
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

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity((IsValid(mainent) and mainent:GetVelocity() or vector_origin) + VectorRand(-65,65) + force / 10)
				phys:AddAngleVelocity(VectorRand(-65,65))
			end

			if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
				ent:DrawShadow(false)
				ent:SetModelScale(0, gibRemoveTime)
				SafeRemoveEntityDelayed(ent, gibRemoveTime)
			end

			ent:AddCallback( "PhysicsCollide", PhysCallback )
		end
	end
end

local headpos_male, headpos_female, headang = Vector(0,0,7), Vector(-2,0,6), Angle(0,0,0)

util.AddNetworkString("addfountain")
util.AddNetworkString("hg_gib_bloodspill")

hg.fountains = hg.fountains or {}
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
for _, model in ipairs(headModels) do
	util.PrecacheModel(model)
end
for _, model in ipairs(headGibModels) do
	util.PrecacheModel(model)
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
local function sendGibBloodSpill(ent, stump)
	if not IsValid(ent) then return end
	net.Start("hg_gib_bloodspill")
	net.WriteUInt(ent:EntIndex(), 16)
	net.WriteFloat(math.Rand(5, 10))
	net.WriteBool(stump or false)
	net.Broadcast()
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

		gib_ragdols[rag] = true
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

		net.Start("addfountain")
		net.WriteEntity(rag)
		net.WriteVector(force or vector_origin)
		net.Broadcast()

		hg.fountains[rag] = {bone = rag:LookupBone("ValveBiped.Bip01_Neck1"), lpos = ThatPlyIsFemale(rag) and Vector(4,0,0) or Vector(5,0,0),lang = Angle(0,0,0)}

		rag:CallOnRemove("removefountain", function()
			hg.fountains[rag] = nil
			SetNetVar("fountains", hg.fountains)
		end)

		SetNetVar("fountains", hg.fountains)
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

local stomachBoneNames = {"ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis"}

local function getStomachBone(ent)
	for _, name in ipairs(stomachBoneNames) do
		local bone = ent:LookupBone(name)
		if bone then return bone end
	end
	return 0
end

local function setupStomachGoreParent(gore, ent)
	if not IsValid(gore) or not IsValid(ent) then return false end
	local bone = getStomachBone(ent)
	if not bone or bone <= 0 then return false end
	local matrix = ent:GetBoneMatrix(bone)
	if not matrix then return false end
	gore:SetPos(matrix:GetTranslation())
	gore:SetParent(ent, bone)
	gore:SetSolid(SOLID_NONE)
	gore:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
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

function hg.AttachStomachGore(target, force)
	if not IsValid(target) then return end
	local ent = target
	if target:IsPlayer() and IsValid(target.FakeRagdoll) then ent = target.FakeRagdoll end
	if IsValid(ent.StomachGoreEnt) or IsValid(target.StomachGoreEnt) then return end

	local gore = ents_Create("prop_dynamic")
	if not IsValid(gore) then return end
	gore:SetModel(stomachGoreModel)
	local bone = getStomachBone(ent)
	local matrix = ent:GetBoneMatrix(bone)
	local pos = matrix and matrix:GetTranslation() or ent:GetPos()
	gore:SetPos(pos)
	gore:Spawn()
	if not bindStomachGore(gore, ent, target) then gore:Remove() return end
	gore:CallOnRemove("clear_stomach_gore_refs", function() clearStomachGoreRefs(gore) end)

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
