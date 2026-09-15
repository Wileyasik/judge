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
util.AddNetworkString("hg_fullbody_bloodmist")

hg.fountains = hg.fountains or {}
local headboom_mdl = Model("models/gleb/zcity/headboom.mdl")
local zippyHeadGoreModels = {
	Model("models/headpartial/headpartial1.mdl"),
	Model("models/headpartial/headpartial2.mdl"),
	Model("models/headpartial/headpartial3.mdl"),
	Model("models/headpartial/headpartial4.mdl"),
	Model("models/headpartial/headpartial5.mdl"),
}
local eyeRModel = Model("models/gore/head_eye01.mdl")
local eyeLModel = Model("models/gore/head_eye02.mdl")

local zippyHeadGibModels = {
	Model("models/gore/head_headbitfrontleft.mdl"),
	Model("models/gore/head_headbitfrontright.mdl"),
	Model("models/gore/head_headbitbackleft.mdl"),
	Model("models/gore/head_headbitbackright.mdl"),
	Model("models/gore/head_headbittopleft.mdl"),
	Model("models/gore/head_headbittopright.mdl"),
	eyeRModel,
	eyeLModel,
	Model("models/gore/head_jawlo.mdl"),
}

function hg.HeadGibModels(org)
	if not org or not (org.eyePoppedL or org.eyePoppedR) then return zippyHeadGibModels end
	local models = {}
	for i, mdl in ipairs(zippyHeadGibModels) do
		if mdl == eyeRModel and org.eyePoppedR then continue end
		if mdl == eyeLModel and org.eyePoppedL then continue end
		models[#models + 1] = mdl
	end
	return models
end
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
	rleg = {
		Model("models/gore/rleg_meatbit001r.mdl"),
	},
	lleg = {
		Model("models/gore/lleg_meatbit001l.mdl"),
	},
	larm = {
		Model("models/gore/larm_armgorehandl.mdl"),
		Model("models/gore/larm_armgoreupperl.mdl"),
	},
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
for _, models in pairs(fullBodyGibModels) do
	for _, mdl in ipairs(models) do
		util.PrecacheModel(mdl)
	end
end

for _, snd in ipairs(sounds) do
	util.PrecacheSound(snd)
end
for _, snd in ipairs(fullBodySounds) do
	util.PrecacheSound(snd)
end
util.PrecacheSound(fullBodyMainSound)

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
		SpawnMeatGore(rag.zippyHeadGore, rag.zippyHeadGore:GetPos(), 3, VectorRand(-120, 120), 0.45, hg.HeadGibModels(rag.organism))
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
	SpawnMeatGore(ent, ent:GetPos(), 3, VectorRand(-120, 120), 0.45, hg.HeadGibModels(rag.organism))

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

		SpawnMeatGore(ent, pos, nil, force, nil, hg.HeadGibModels(rag.organism)) --модельки поменять и будет эпик

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
		return true
	end

	if org and (org.otrub or org.alive == false or (org.consciousness or 1) <= 0.1) then return true end
	if IsValid(owner) and (owner.Removed or not owner:Alive()) then return true end
	return false
end

local function spawnFullBodyGib(mainent, pos, force, model, scale)
	local ent = ents_Create("prop_physics")
	ent:SetModel(model)
	ent:SetPos(pos + VectorRand(-8, 8))
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetModelScale(scale or math.Rand(0.95, 1.15))
	ent:SetAngles(AngleRand(-180, 180))
	ent:Activate()
	ent:Spawn()

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		local baseVel = IsValid(mainent) and mainent:GetVelocity() or isvector(mainent) and mainent or vector_origin
		phys:SetVelocity(baseVel + VectorRand(-260, 260) + (force or vector_origin) / 7)
		phys:AddAngleVelocity(VectorRand(-320, 320))
	end

	ent:AddCallback("PhysicsCollide", PhysCallback)
	SafeRemoveEntityDelayed(ent, gibRemoveTime)

	timer.Simple(0.2, function()
		if not IsValid(ent) then return end
		net.Start("hg_gib_bloodspill")
		net.WriteUInt(ent:EntIndex(), 16)
		net.WriteFloat(math.Rand(4, 8))
		net.WriteBool(false)
		net.Broadcast()
	end)

	return ent
end

local function fullBodyBloodMist(pos, force)
	net.Start("hg_fullbody_bloodmist")
	net.WriteVector(pos)
	net.WriteVector(force or vector_origin)
	net.WriteUInt(70, 8)
	net.Broadcast()
end

local function spawnFullBodyGroup(ent, pos, force, models)
	for _, mdl in ipairs(models) do
		spawnFullBodyGib(ent, pos, force, mdl)
	end
end

local function spawnFullBodyMeat(ent, pos, count, force, scale, models)
	models = models or meatModels
	for i = 1, count do
		local gib = spawnFullBodyGib(ent, pos, force, models[math.random(#models)], scale)
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

	if not (org and org.stomachgibbed) then
		spawnFullBodyGroup(velocity, pos, force, fullBodyGibModels.stomach)
		spawnFullBodyMeat(velocity, pos, 6, force, 0.55, intestineChunkModels)
	end

	for _, limb in ipairs({"lleg", "rleg", "larm"}) do
		if not (org and org[limb.."amputated"]) then
			spawnFullBodyGroup(velocity, pos, force, fullBodyGibModels[limb])
			spawnFullBodyMeat(velocity, pos, 4, force, 0.65)
		end
	end

	if not (org and org.rarmamputated) then
		spawnFullBodyMeat(velocity, pos, 5, force, 0.65)
	end

	if not (org and org.headamputated) then
		spawnFullBodyMeat(velocity, pos, 8, force, 0.8, hg.HeadGibModels(org))
	end

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

function hg.FullBodyExplode(target, force, dmgInfo)
	if not IsValid(target) or target.fullbodyexploded then return end

	if target:IsPlayer() then
		local ply = target
		local rag = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply:GetNWEntity("RagdollDeath")
		if IsValid(rag) then return hg.FullBodyExplode(rag, force, dmgInfo) end
		if ply:Alive() then
			if not hg.CanFullBodyGib(ply, ply.organism, ply) then return end
			ply.fullbodyexploded = true
			local wasRemoved = ply.Removed
			ply.Removed = true
			ply:Kill()
			timer.Simple(0, function()
				if IsValid(ply) then ply.Removed = wasRemoved end
			end)
			timer.Simple(0, function()
				if not IsValid(ply) then return end
				local rag = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply:GetNWEntity("RagdollDeath")
				if IsValid(rag) then hg.FullBodyExplode(rag, force, dmgInfo) end
			end)
		end
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

	local pos = getFullBodyPos(ent)
	force = force or vector_origin
	fullBodyExplodeAt(pos, force, ent:GetVelocity(), org, ent, owner, dmgInfo)

	if IsValid(ent.zippyHeadGore) then ent.zippyHeadGore:Remove() end
	if IsValid(ent.StomachGoreEnt) then ent.StomachGoreEnt:Remove() end
	ent:Remove()
	return true
end

local fullBodyRemoveTrack = {}

hook.Add("PreCleanupMap", "HG_BlockFullBodyCleanupGib", function()
	hg.CleaningUpMap = true
end)

hook.Add("PostCleanupMap", "HG_BlockFullBodyCleanupGib", function()
	timer.Simple(0, function()
		hg.CleaningUpMap = nil
	end)
end)

function hg.TrackFullBodyRagdollRemove(rag)
	if not IsValid(rag) or not rag:IsRagdoll() or rag.hg_fullbody_remove_track then return end
	rag.hg_fullbody_remove_track = true
	fullBodyRemoveTrack[rag] = {
		pos = getFullBodyPos(rag),
		vel = rag:GetVelocity(),
		org = rag.organism,
		owner = IsValid(rag.ply) and rag.ply or rag:GetNWEntity("ply"),
	}

	rag:CallOnRemove("HG_FullBodyRemoveGib", function(ent)
		local data = fullBodyRemoveTrack[ent]
		fullBodyRemoveTrack[ent] = nil
		if hg.CleaningUpMap then return end
		if ent.fullbodyexploded or ent.override or ent.hg_no_fullbody_remove_gib then return end

		local org = data and data.org or ent.organism
		if org and (org.godmode or org.fullbodyexploded) then return end
		local owner = data and data.owner
		if not hg.CanFullBodyGib(ent, org, owner, true) then return end

		local pos = data and data.pos or IsValid(ent) and ent:GetPos() or vector_origin
		local vel = data and data.vel or IsValid(ent) and ent:GetVelocity() or vector_origin
		if IsValid(ent) then
			pos = getFullBodyPos(ent)
			vel = ent:GetVelocity()
		end

		fullBodyExplodeAt(pos, vel, vel, org, nil, owner)
	end)
end

hook.Add("Ragdoll_Create", "HG_TrackFullBodyRemoveGib", function(ply, rag)
	hg.TrackFullBodyRagdollRemove(rag)
end)

hook.Add("RagdollDeath", "HG_TrackFullBodyRemoveDeathGib", function(ply, rag)
	hg.TrackFullBodyRagdollRemove(rag)
end)

hook.Add("Think", "HG_UpdateFullBodyRemoveTrack", function()
	for rag, data in pairs(fullBodyRemoveTrack) do
		if not IsValid(rag) then fullBodyRemoveTrack[rag] = nil continue end
		data.pos = getFullBodyPos(rag)
		data.vel = rag:GetVelocity()
		data.org = rag.organism or data.org
		data.owner = IsValid(rag.ply) and rag.ply or data.owner
	end
end)

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
