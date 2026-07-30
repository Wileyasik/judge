local net, hg, pairs, Vector, ents, IsValid, util = net, hg, pairs, Vector, ents, IsValid, util

local vecZero = Vector(0,0,0)
local vecInf = Vector(0,0,0) / 0

local function removeBone(rag, bone, phys_bone, nohuys)
	if !nohuys then rag:ManipulateBoneScale(bone, vecZero) end
	--rag:ManipulateBonePosition(bone,vecInf) -- Thanks Rama (only works on certain graphics cards!)

	if rag.gibRemove[phys_bone] then return end

	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
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
	Model("models/props_junk/watermelon01_chunk02a.mdl"),
}
local gibRemoveTime = 60 --120
function SpawnMeatGore(mainent, pos, count, force, scale, models)
	force = force or Vector(0,0,0)
	models = models or meatModels
	for i = 1, (count or math.random(8, 10)) do
		local ent = ents_Create("prop_physics")
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
			phys:SetVelocity(mainent:GetVelocity() + VectorRand(-65,65) + force / 10)
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
end

local headpos_male, headpos_female, headang = Vector(0,0,7), Vector(-2,0,6), Angle(0,0,-0)

util.AddNetworkString("addfountain")
util.AddNetworkString("hg_gib_bloodspill")

hg.fountains = hg.fountains or {}
local headboom_mdl = Model("models/gleb/zcity/headboom.mdl")
local zippyHeadGoreModels = {
	Model("models/headpartial/headpartial1.mdl"),
	Model("models/headpartial/headpartial2.mdl"),
	Model("models/headpartial/headpartial3.mdl"),
	Model("models/headpartial/headpartial4.mdl"),
	Model("models/headpartial/headpartial5.mdl"),
}
local zippyHeadGibModels = {
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

local sounds = {
	Sound("player/zombie_head_explode_01.wav"),
	Sound("player/zombie_head_explode_02.wav"),
	Sound("player/zombie_head_explode_03.wav"),
	Sound("player/zombie_head_explode_04.wav"),
	Sound("player/zombie_head_explode_05.wav"),
	Sound("player/zombie_head_explode_06.wav")
}
util.PrecacheModel(headboom_mdl)
for _, mdl in ipairs(zippyHeadGoreModels) do
	util.PrecacheModel(mdl)
end
for _, mdl in ipairs(zippyHeadGibModels) do
	util.PrecacheModel(mdl)
end

for _, snd in ipairs(sounds) do
	util.PrecacheSound(snd)
end

local function getHeadGoreStage(damage)
	return math.Clamp(math.ceil(math.max((damage or 0) - 175, 0) / 5), 1, 5)
end

local function getInitialHeadGoreStage(damage)
	return math.min(getHeadGoreStage(damage), table.Random({1,1,1,1,2,2,2,3,4,5}))
end

local function setupZippyHeadGore(ent, rag, stage)
	ent:SetModel(zippyHeadGoreModels[stage])
	local att = rag:GetAttachment(3)
	local pos, ang = LocalToWorld(ThatPlyIsFemale(rag) and headpos_female or headpos_male, headang, att.Pos, att.Ang)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:SetParent(rag, 3)
	return pos
end

local function copyHeadAppearance(from, to)
	local ply = IsValid(from:GetNWEntity("ply")) and from:GetNWEntity("ply") or hg.RagdollOwner and hg.RagdollOwner(from)
	if IsValid(ply) and ApplyAppearanceRagdoll then ApplyAppearanceRagdoll(to, ply) end
	to:SetNWEntity("ply", IsValid(ply) and ply or from:GetNWEntity("ply"))
	to:SetNWString("PlayerName", from:GetNWString("PlayerName", ""))
	to:SetNetVar("Accessories", from:GetNetVar("Accessories", IsValid(ply) and ply:GetNetVar("Accessories", "") or ""))
	to:SetSkin(from:GetSkin())
	to:SetMaterial(from:GetMaterial())
	for i = 0, #from:GetBodyGroups() do
		to:SetBodygroup(i, from:GetBodygroup(i))
	end
	for i = 0, #from:GetMaterials() - 1 do
		to:SetSubMaterial(i, from:GetSubMaterial(i))
	end
	to:SetRenderMode(RENDERMODE_NORMAL)
	to:SetColor(Color(255, 255, 255, 255))
	to:SetNWVector("PlayerColor", from:GetNWVector("PlayerColor", vector_origin))
end

local function hideNonHeadBones(ent, headBone)
	local headPhysBone = ent:TranslateBoneToPhysBone(headBone)
	for i = 0, ent:GetBoneCount() - 1 do
		if i == headBone then continue end
		ent:ManipulateBoneScale(i, vecZero)
		local physBone = ent:TranslateBoneToPhysBone(i)
		if physBone == -1 or physBone == headPhysBone then continue end
		local phys = ent:GetPhysicsObjectNum(physBone)
		if IsValid(phys) then
			phys:EnableCollisions(false)
			phys:SetMass(0.1)
			ent:RemoveInternalConstraint(physBone)
		end
	end
	ent:RemoveInternalConstraint(headPhysBone)
end







function Gib_UpdateHeadGoreStage(rag, damage)
	if not IsValid(rag) or not rag.headexploded then return end
	local stage = getHeadGoreStage(damage)
	if (rag.zippyHeadGoreStage or 0) >= stage then return end

	rag.zippyHeadGoreStage = stage
	if IsValid(rag.zippyHeadGore) then
		rag.zippyHeadGore:SetModel(zippyHeadGoreModels[stage])
		net.Start("hg_gib_bloodspill")
		net.WriteUInt(rag.zippyHeadGore:EntIndex(), 16)
		net.WriteFloat(math.Rand(5, 10))
		net.WriteBool(true)
		net.Broadcast()
		SpawnMeatGore(rag.zippyHeadGore, rag.zippyHeadGore:GetPos(), 3, VectorRand(-120, 120), 0.45, zippyHeadGibModels)
		return
	end

	local ent = ents_Create("prop_dynamic")
	setupZippyHeadGore(ent, rag, stage)
	ent:Spawn()
	rag.zippyHeadGore = ent
	net.Start("hg_gib_bloodspill")
	net.WriteUInt(ent:EntIndex(), 16)
	net.WriteFloat(math.Rand(5, 10))
	net.WriteBool(true)
	net.Broadcast()
	SpawnMeatGore(ent, ent:GetPos(), 3, VectorRand(-120, 120), 0.45, zippyHeadGibModels)

	rag:CallOnRemove("remove_zippy_head_gore", function()
		if IsValid(ent) then ent:Remove() end
	end)
end

function Gib_Input(rag, bone, force, damage)
	if not IsValid(rag) then return end
	
	local gibRemove = rag.gibRemove

	if not gibRemove then
		rag.gibRemove = {}
		gibRemove = rag.gibRemove

		gib_ragdols[rag] = true
	end

	local phys_bone = rag:TranslateBoneToPhysBone(bone)
	local phys_obj = rag:GetPhysicsObjectNum(phys_bone)
	
	if (not gibRemove[phys_bone]) and (bone == rag:LookupBone("ValveBiped.Bip01_Head1")) then
		--sound.Emit(rag,"player/headshot" .. math.random(1, 2) .. ".wav")
		--sound.Emit(rag,"physics/flesh/flesh_squishy_impact_hard" .. math.random(2, 4) .. ".wav")
		--sound.Emit(rag,"physics/body/body_medium_break3.wav")
		--sound.Emit(rag,"physics/glass/glass_sheet_step" .. math.random(1,4) .. ".wav", 90, 50, 2)
		rag:EmitSound(sounds[math.random(#sounds)], 70, math.random(115, 125), 2)

		Gib_RemoveBone(rag, bone, phys_bone)
		
		--rag:ManipulateBoneScale(rag:LookupBone("ValveBiped.Bip01_Neck1"),vecZero)
		rag:ManipulateBonePosition(rag:LookupBone("ValveBiped.Bip01_Neck1"),Vector(-1,0,0))

		local stage = getInitialHeadGoreStage(damage)
		local ent = ents_Create("prop_dynamic")
		local pos = setupZippyHeadGore(ent, rag, stage)
		ent:Spawn()
		rag.zippyHeadGore = ent
		rag.zippyHeadGoreStage = stage
		net.Start("hg_gib_bloodspill")
		net.WriteUInt(ent:EntIndex(), 16)
		net.WriteFloat(math.Rand(5, 10))
		net.WriteBool(true)
		net.Broadcast()

		SpawnMeatGore(ent, pos, nil, force, nil, zippyHeadGibModels) --модельки поменять и будет эпик

		local armors = rag:GetNetVar("Armor",{})

		if armors["head"] and !hg.armor["head"][armors["head"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["head"])
			ent:SetPos(phys_obj:GetPos())
		end
		
		if armors["face"] and !hg.armor["face"][armors["face"]].nodrop then
			local ent = hg.DropArmorForce(rag, armors["face"])
			ent:SetPos(phys_obj:GetPos())
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
for _, mdl in ipairs(intestineChunkModels) do
	util.PrecacheModel(mdl)
end

local function getStomachBone(ent)
	return ent:LookupBone("ValveBiped.Bip01_Spine1") or ent:LookupBone("ValveBiped.Bip01_Spine") or ent:LookupBone("ValveBiped.Bip01_Pelvis") or 0
end

local function setupStomachGoreParent(gore, ent)
	gore:SetParent(ent)
	local attachments = ent:GetAttachments()
	local attachment
	for _, att in pairs(attachments) do
		attachment = att.name
	end
	if attachment then gore:Fire("SetParentAttachment", attachment) end
	gore:AddEffects(EF_BONEMERGE)
	gore:SetSolid(SOLID_NONE)
end

local function SpawnIntestineChunks(ent, pos, force)
	SpawnMeatGore(ent, pos, 6, force or VectorRand(-120, 120), 0.55, intestineChunkModels)
end

function hg.AttachStomachGore(target, force)
	if not IsValid(target) then return end

	local ent = target
	if ent:IsPlayer() and IsValid(ent.FakeRagdoll) then ent = ent.FakeRagdoll end
	if IsValid(ent.StomachGoreEnt) or IsValid(target.StomachGoreEnt) then return end

	local gore = ents_Create("prop_dynamic")
	gore:SetModel(stomachGoreModel)
	setupStomachGoreParent(gore, ent)
	gore:Spawn()

	local bone = getStomachBone(ent)
	local pos = ent:GetBonePosition(bone) or ent:GetPos()
	ent.StomachGoreEnt = gore
	target.StomachGoreEnt = gore
	ent:SetNWBool("NoVomitView", true)
	if target ~= ent then target:SetNWBool("NoVomitView", true) end
	ent:EmitSound(sounds[math.random(#sounds)], 70, math.random(95, 105), 1)
	net.Start("hg_gib_bloodspill")
	net.WriteUInt(gore:EntIndex(), 16)
	net.WriteFloat(math.Rand(5, 10))
	net.WriteBool(true)
	net.Broadcast()
	SpawnMeatGore(ent, pos, 4, force, 0.7)
	SpawnIntestineChunks(ent, pos, force)

	local owner = target:IsPlayer() and target or ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
	if ent.organism then ent.organism.stomachgibbed = true end
	if target.organism then target.organism.stomachgibbed = true end
	if IsValid(owner) and owner.organism then
		owner.organism.stomachgibbed = true
		hg.organism.AddWoundManual(owner, 160, vector_origin, Angle(0,0,0), bone, CurTime())
		owner.organism.internalBleed = (owner.organism.internalBleed or 0) + 3
		owner.organism.bleed = math.max(owner.organism.bleed or 0, 1.2)
		owner.organism.painadd = (owner.organism.painadd or 0) + 25
		owner.organism.shock = math.min((owner.organism.shock or 0) + 12, 70)
	end
end

local function ReparentStomachGore(fromEnt, toEnt)
	if not IsValid(fromEnt) or not IsValid(toEnt) then return end
	local gore = fromEnt.StomachGoreEnt
	if not IsValid(gore) then return end

	setupStomachGoreParent(gore, toEnt)
	toEnt.StomachGoreEnt = gore
	if fromEnt ~= toEnt then fromEnt.StomachGoreEnt = nil end
end

hook.Add("Player Spawn", "HG_ClearStomachGoreOnSpawn", function(ply)
	if IsValid(ply.StomachGoreEnt) then ply.StomachGoreEnt:Remove() end
	ply.StomachGoreEnt = nil
end)

hook.Add("Fake", "HG_ReparentStomachGoreToRag", function(ply, rag)
	if IsValid(ply) and IsValid(rag) and IsValid(ply.StomachGoreEnt) then ReparentStomachGore(ply, rag) end
end)

hook.Add("Fake Up", "HG_ReparentStomachGoreToPlayer", function(ply, rag)
	if IsValid(ply) and IsValid(rag) and IsValid(rag.StomachGoreEnt) then ReparentStomachGore(rag, ply) end
end)

hook.Add("Player Getup", "HG_ReparentStomachGorePlayerGetup", function(ply)
	local rag = IsValid(ply) and ply.FakeRagdoll
	if IsValid(ply) and IsValid(rag) and IsValid(rag.StomachGoreEnt) then ReparentStomachGore(rag, ply) end
end)

hook.Add("RagdollDeath", "HG_StomachGoreDeathRag", function(ply, rag)
	if IsValid(ply) and IsValid(rag) and IsValid(ply.StomachGoreEnt) then ReparentStomachGore(ply, rag) end
end)
