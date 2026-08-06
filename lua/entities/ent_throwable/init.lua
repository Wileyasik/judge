AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(USE_TOGGLE)
	self:DrawShadow(true)
	self:SetModelScale(self.modelscale or 1)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(self.ThrowableMass or 2)
		phys:Wake()
		phys:EnableMotion(true)
	end
	self.created = CurTime()
	SafeRemoveEntityDelayed(self, self.Lifetime or 120)

	timer.Simple(0, function()
		if not IsValid(self) then return end

		self:SetModelScale(self.modelscale or 1)
	end)

	timer.Simple(0.5,function()
		if not IsValid(self) then return end
		
		self:SetOwner()
	end)
end

local physicsProfiles = {
	weapon_brick = {"concrete", "physics/concrete/concrete_impact_hard1.wav", "physics/concrete/concrete_impact_hard2.wav", "physics/concrete/concrete_impact_hard3.wav"},
	weapon_hammer = {"metal", "physics/metal/metal_solid_impact_hard1.wav", "physics/metal/metal_solid_impact_hard4.wav", "physics/metal/metal_solid_impact_hard5.wav"},
	weapon_hg_bottle = {"glass", "physics/glass/glass_impact_hard1.wav", "physics/glass/glass_impact_hard2.wav", "physics/glass/glass_impact_hard3.wav"},
	weapon_hatchet = {"metal", "physics/metal/metal_solid_impact_hard1.wav", "physics/metal/metal_solid_impact_hard4.wav"},
	weapon_hg_glassshard = {"glass", "physics/glass/glass_impact_hard1.wav", "physics/glass/glass_impact_hard2.wav"},
	weapon_hg_glassshard_taped = {"glass", "physics/glass/glass_impact_hard1.wav", "physics/glass/glass_impact_hard2.wav"},
	weapon_hg_woodaxe = {"metal", "physics/metal/metal_solid_impact_hard1.wav", "physics/metal/metal_solid_impact_hard4.wav"},
	weapon_hg_shuriken = {"metal", "physics/metal/metal_solid_impact_hard1.wav", "physics/metal/metal_solid_impact_hard4.wav"},
	weapon_hg_mug = {"pottery", "physics/glass/glass_impact_hard1.wav", "physics/glass/glass_impact_hard2.wav"},
	weapon_hg_spear = {"wood", "physics/wood/wood_solid_impact_hard1.wav", "physics/wood/wood_solid_impact_hard2.wav", "physics/wood/wood_solid_impact_hard3.wav"},
	weapon_hg_spear_knife = {"wood", "physics/wood/wood_solid_impact_hard1.wav", "physics/wood/wood_solid_impact_hard2.wav", "physics/wood/wood_solid_impact_hard3.wav"},
	weapon_hg_spear_pro = {"metal", "physics/metal/metal_solid_impact_hard1.wav", "physics/metal/metal_solid_impact_hard4.wav"},
	weapon_tpik_microphone = {"plastic", "physics/plastic/plastic_box_impact_hard1.wav", "physics/plastic/plastic_box_impact_hard2.wav", "physics/plastic/plastic_box_impact_hard3.wav"},
}

local wallOnlyThrowables = {
	weapon_hg_spear = true,
	weapon_hg_spear_knife = true,
	weapon_hg_spear_pro = true,
}

local neverWorldStickThrowables = {
	weapon_hg_glassshard = true,
	weapon_hg_glassshard_taped = true,
}

local function ApplyPhysicsProfile(ent, phys)
	local profile = physicsProfiles[ent.wep]
	local material = ent.PhysicsMaterial or (profile and profile[1])
	if not material or ent.AppliedPhysicsMaterial == material or not IsValid(phys) then return profile end

	phys:SetMaterial(material)
	ent.AppliedPhysicsMaterial = material
	return profile
end

hook.Add("OnEntityCreated", "ThrowablePhysicsProfile", function(ent)
	if ent:GetClass() ~= "ent_throwable" then return end

	timer.Simple(0, function()
		if not IsValid(ent) then return end
		ApplyPhysicsProfile(ent, ent:GetPhysicsObject())
	end)
end)

local function PlayPhysicsImpact(ent, data, phys)
	local profile = ApplyPhysicsProfile(ent, phys)
	if not profile or (ent.NextPhysicsImpactSound or 0) > CurTime() then return end

	local speed = isnumber(data.Speed) and data.Speed or 0
	if speed < (ent.MinImpactSoundSpeed or 45) then return end

	ent.NextPhysicsImpactSound = CurTime() + 0.08
	local soundName = profile[math.random(2, #profile)]
	local volume = math.Clamp(speed / 500, 0.2, 1)
	ent:EmitSound(soundName, 60 + volume * 15, math.random(94, 106), volume, CHAN_BODY)
end

local function FindAnchorBone(ent, hitPos, trace)
	if not IsValid(ent) then return end

	if ent:IsRagdoll() and trace and trace.Entity == ent and trace.PhysicsBone ~= nil then
		local modelBone = ent:TranslatePhysBoneToBone(trace.PhysicsBone)
		local matrix = modelBone and modelBone >= 0 and ent:GetBoneMatrix(modelBone)
		if matrix then return modelBone, ent:GetBoneName(modelBone), trace.PhysicsBone, matrix end
	end

	local wantedHitGroup = trace and trace.HitGroup
	local function FindNearestBone(filterHitGroup)
		local bestBone, bestMatrix, bestDistance
		for modelBone = 0, ent:GetBoneCount() - 1 do
			local boneName = ent:GetBoneName(modelBone)
			if not filterHitGroup or not hg.bonetohitgroup or hg.bonetohitgroup[boneName] == filterHitGroup then
				local matrix = ent:GetBoneMatrix(modelBone)
				if matrix then
					local distance = hitPos:DistToSqr(matrix:GetTranslation())
					if not bestDistance or distance < bestDistance then
						bestBone, bestMatrix, bestDistance = modelBone, matrix, distance
					end
				end
			end
		end
		return bestBone, bestMatrix
	end

	local filteredHitGroup = wantedHitGroup and wantedHitGroup ~= HITGROUP_GENERIC and wantedHitGroup or nil
	local bestBone, bestMatrix = FindNearestBone(filteredHitGroup)
	if not bestBone and filteredHitGroup then bestBone, bestMatrix = FindNearestBone() end
	if not bestBone then return end
	local physBone = ent:TranslateBoneToPhysBone(bestBone)
	return bestBone, ent:GetBoneName(bestBone), physBone and physBone >= 0 and physBone or nil, bestMatrix
end

local function GetEmbeddedTransform(ent, hitPos, hitNormal, direction, depth)
	local ang = ent:GetAngles()
	local tipOffset = ent.BodyStickPoint
	depth = math.max(depth or 0, 0)

	local inward = isvector(hitNormal) and -hitNormal:GetNormalized() or direction
	if not isvector(inward) or inward:LengthSqr() < 0.01 then inward = ang:Forward() end
	if isvector(direction) and direction:LengthSqr() > 0.01 then
		direction = direction:GetNormalized()
		if direction:Dot(inward) > 0.5 then inward = (inward + direction):GetNormalized() end
		-- Lodged visuals must use the impact direction instead of their last
		-- physics-spin angle. Individual models can opt out when needed.
		if ent.BodyStickAlignToImpact ~= false then ang = direction:Angle() end
	end

	local pos = hitPos + inward * depth
	if isvector(tipOffset) then
		-- Models with a verified tip can place that tip at the impact point.
		local rotatedTip = LocalToWorld(tipOffset * ent:GetModelScale(), angle_zero, vector_origin, ang)
		pos = pos - rotatedTip
	end

	-- Without a model-specific tip, keep the visual projectile at the actual
	-- contact point. Using its flying origin here makes spinning models float.
	return pos, ang
end

local function StickToWorld(ent, hitPos, hitNormal, hitVel)
	if not isvector(hitVel) or hitVel:LengthSqr() < 1 then
		local physObj = ent:GetPhysicsObject()
		hitVel = IsValid(physObj) and physObj:GetVelocity() or vector_origin
	end
	if hitVel:LengthSqr() < 1 then hitVel = ent:GetAngles():Forward() end

	local ang = hitVel:Angle()
	local forward = ang:Forward()
	local tipOffset = ent:OBBMaxs().x * ent:GetModelScale()
	local tipTarget = hitPos - hitNormal * (ent.StickDepth or 5)
	local pos = tipTarget - forward * tipOffset

	-- A nearly flat shuriken can touch a floor with its face before its +X tip.
	-- In that narrow case, keep its origin at contact instead of burying the star.
	if ent.ProtectFlatWorldStick and isvector(hitNormal) and hitNormal:LengthSqr() > 0.01 then
		local normal = hitNormal:GetNormalized()
		local incidence = math.abs(forward:Dot(normal))
		if math.abs(normal.z) >= 0.7 and incidence <= (ent.FlatWorldStickIncidence or 0.35) then
			pos = tipTarget
		end
	end
	local physObj = ent:GetPhysicsObject()
	if IsValid(physObj) then
		-- Disable the active contact before teleporting the hull into its stuck pose.
		physObj:EnableCollisions(false)
	end
	ent:SetAngles(ang)
	ent:SetPos(pos)

	if IsValid(physObj) then
		physObj:SetAngles(ang)
		physObj:SetPos(pos)
		physObj:SetVelocity(vector_origin)
		physObj:SetAngleVelocity(vector_origin)
		physObj:EnableMotion(false)

		if ent.StickPhysics ~= false then
			timer.Simple(0, function()
				if not IsValid(ent) or not ent.Stuck then return end
				local stuckPhys = ent:GetPhysicsObject()
				if IsValid(stuckPhys) then stuckPhys:EnableCollisions(true) end
			end)
		end
	end

	if IsValid(ent.StuckSurface) and ent.StuckSurface:GetMoveType() == MOVETYPE_PUSH then ent:SetParent(ent.StuckSurface) end

	if ent.StickPhysics == false then
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	end

	ent.Stuck = true

	ent:EmitSound(ent.AttackHit or "Canister.ImpactHard", 65, 100, 1, CHAN_BODY)

	util.Decal("ManhackCut", hitPos + hitNormal, hitPos - hitNormal)
	return true
end

hook.Add("PhysgunPickup", "ThrowableUnstick", function(ply, ent)
	if not IsValid(ent) or ent:GetClass() ~= "ent_throwable" or not ent.Stuck then return end

	ent:SetParent(nil)
	local physObj = ent:GetPhysicsObject()
	if IsValid(physObj) then
		physObj:EnableCollisions(true)
		physObj:EnableMotion(true)
		physObj:Wake()
	end

	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	ent.StuckSurface = nil
	ent.Stuck = false
	ent.Stress = 0
	ent:EmitSound("physics/wood/wood_plank_impact_hard3.wav", 65, math.random(110, 130))
end)

function ENT:Think()
	if not IsValid(self:GetPhysicsObject()) then
		self:Remove()
		return
	end
	if self.Stuck then
		self.Stress = (self.Stress or 0) - FrameTime() * 20
		if self.Stress < 0 then self.Stress = 0 end

		if (self.Stress or 0) > 500 then
			self:SetParent(nil)
			local physObj = self:GetPhysicsObject()
			if IsValid(physObj) then
				physObj:EnableCollisions(true)
				physObj:EnableMotion(true)
				physObj:Wake()
			end
			self:SetCollisionGroup(COLLISION_GROUP_NONE)
			self.StuckSurface = nil
			self.Stuck = false
			self.Stress = 0
			self:EmitSound("physics/wood/wood_plank_impact_hard3.wav", 75, math.random(90, 110))
			self:NextThink(CurTime() + 0.1)
			return true
		elseif (self.Stress or 0) > 300 and not self.CreakPlayed then
			self.CreakPlayed = true
			self:EmitSound("physics/wood/wood_plank_impact_hard2.wav", 45, math.random(130, 150))
		elseif (self.Stress or 0) <= 300 then
			self.CreakPlayed = false
		end

		self:NextThink(CurTime() + 0.1)
		return true
	end
	local speed = self:GetPhysicsObject():GetVelocity():LengthSqr()
	ApplyPhysicsProfile(self, self:GetPhysicsObject())

	if self.constrained then return end
	if self.AeroDrag then
		AeroDrag(self, self:GetAngles():Forward(), 10)
	end
	if not self.StickInWorld then
		local collisionGroup = speed < 220000 and COLLISION_GROUP_WEAPON or COLLISION_GROUP_NONE
		if self:GetCollisionGroup() ~= collisionGroup then
			self:SetCollisionGroup(collisionGroup)
		end
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.removed then return end
	local hitEnt = data.HitEntity
	local validHitEnt = IsValid(hitEnt)
	local isWorld = hitEnt == game.GetWorld() or (validHitEnt and hitEnt:IsWorld())
	local isMapGeometry = isWorld or (validHitEnt and hitEnt:GetSolid() == SOLID_BSP)
	local isSharp = (self.DamageType or DMG_SLASH) == DMG_SLASH
	local hitNormal = data.HitNormal
	local isWall = isvector(hitNormal) and math.abs(hitNormal:GetNormalized().z) < 0.7
	local canStickToSurface = not neverWorldStickThrowables[self.wep]
		and (self.StickAnywhere or not wallOnlyThrowables[self.wep] or isWall)
	local canBreakHere = isMapGeometry or (validHitEnt and not self.BreakOnWorldImpact)
	if self.BreakOnImpact and canBreakHere and data.Speed >= (self.BreakSpeed or 0) then
		if self.func then self.func(data) end
		return
	end

	if not self.Stuck and not self.noStuck and isMapGeometry and canStickToSurface and (self.StickInWorld or isSharp) then
		self.StuckSurface = hitEnt
		local hitVelocity = data.OurOldVelocity
		if not isvector(hitVelocity) or hitVelocity:LengthSqr() < 1 then
			hitVelocity = IsValid(phys) and phys:GetVelocity() or self:GetAngles():Forward() * math.max(data.Speed or 0, 1)
		end
		if StickToWorld(self, data.HitPos, data.HitNormal, hitVelocity) then
			if self.hitworldfunc then self.hitworldfunc(self, data) end
			return
		end
		self.StuckSurface = nil
	end
	PlayPhysicsImpact(self, data, phys)

	if not validHitEnt then return end

	if self.Stuck then
		local hitEnt = data.HitEntity
		if IsValid(hitEnt) and hitEnt:GetClass() ~= "worldspawn" then
			local hitPhys = hitEnt:GetPhysicsObject()
			local hitMass = IsValid(hitPhys) and hitPhys:GetMass() or 1
			if (self.NextStressImpact or 0) <= CurTime() then
				self.Stress = (self.Stress or 0) + data.Speed * hitMass * 0.01
				self.NextStressImpact = CurTime() + 0.1
			end
		end
		return
	end

	if data.Speed < (self.MinDamageSpeed or 400) then return end
	if self.DamageSpent then return end

	-- resolve ragdoll to real player
	local ragdollOwner = IsValid(hitEnt) and hitEnt:GetNWEntity("ply")
	if not IsValid(ragdollOwner) and hitEnt:GetClass() == "prop_ragdoll" then
		return
	end
	local target = IsValid(ragdollOwner) and ragdollOwner or hitEnt
	if not IsValid(target) then return end
	if self.NoDismemberment then
		-- Direct hits can launch a ragdoll into another surface after this entity
		-- is gone. Keep that body exempt from physics gibs for its lifetime.
		hitEnt.NoDismembermentPhysics = true
		target.NoDismembermentPhysics = true
		if IsValid(target.FakeRagdoll) then target.FakeRagdoll.NoDismembermentPhysics = true end
		if target.organism then target.organism.NoDismembermentPhysics = true end
	end
	local targetOrganism = target.organism

	-- Recover hitgroup and physics-bone metadata around the authoritative
	-- PhysicsCollide contact without allowing the trace to replace its target.
	local hitVelocity = data.OurOldVelocity
	if not isvector(hitVelocity) or hitVelocity:LengthSqr() < 1 then
		hitVelocity = IsValid(phys) and phys:GetVelocity() or self:GetAngles():Forward()
	end
	local hitDirection = hitVelocity:GetNormalized()
	local headTrace = util.TraceHull({
		start = data.HitPos - hitDirection * 12,
		endpos = data.HitPos + hitDirection * 12,
		mins = Vector(-2, -2, -2),
		maxs = Vector(2, 2, 2),
		mask = MASK_SHOT,
		filter = self,
	})

	local traceMatchesTarget = headTrace.Entity == hitEnt or headTrace.Entity == target
	local isHeadshot = targetOrganism and traceMatchesTarget and headTrace.HitGroup == HITGROUP_HEAD
	local anchorBone, anchorBoneName, anchorPhysBone, anchorMatrix
	if targetOrganism and (self.DamageType or DMG_SLASH) == DMG_SLASH then
		local anchorTrace = headTrace.Entity == hitEnt and headTrace or nil
		anchorBone, anchorBoneName, anchorPhysBone, anchorMatrix = FindAnchorBone(hitEnt, data.HitPos, anchorTrace)
	end
	local lodgedEntry
	if anchorMatrix then
		local anchorPos = anchorMatrix:GetTranslation()
		local anchorAng = anchorMatrix:GetAngles()
		local embedDepth = self.BodyStickDepth or self.uglublenie or 5
		local projectilePos, projectileAng = GetEmbeddedTransform(self, data.HitPos, data.HitNormal, hitDirection, embedDepth)
		local lpos, lang = WorldToLocal(projectilePos, projectileAng, anchorPos, anchorAng)
		lodgedEntry = {
			PhysBoneID = anchorPhysBone,
			BoneName = anchorBoneName,
			OffsetPos = lpos,
			OffsetAng = lang,
			model = self:GetModel(),
			modelscale = self:GetModelScale(),
			takeent = self.wep,
		}
	end

	local maxSpeed = math.max(self.MaxSpeed or 1500, 1)
	local speedFraction = math.Clamp(data.Speed / maxSpeed, 0, 1)
	self.Penetration = (self.penetration or 1) * speedFraction
	self.PenetrationSize = self.PenetrationSize or math.max((self.penetration or 1) * 0.5, 1)

	local baseDmg = (self.damage or 20) * speedFraction
	if isHeadshot then
		baseDmg = baseDmg * (self.HeadshotMultiplier or 1.3)
	end

	local dmginfo = DamageInfo()
	local attacker = IsValid(self.owner) and self.owner or game.GetWorld()
	local damageType = self.DamageType or DMG_SLASH
	self.NoGoreDamage = true
	dmginfo:SetAttacker(attacker)
	dmginfo:SetInflictor(self)
	dmginfo:SetDamage(baseDmg)
	dmginfo:SetDamageForce(data.OurOldVelocity)
	dmginfo:SetDamageType(damageType)
	dmginfo:SetDamagePosition(data.HitPos)
	self.DamageSpent = true
	target:TakeDamageInfo(dmginfo)

	if targetOrganism then
		self:EmitSound(self.AttackHitFlesh, 65)

		if (self.DamageType or DMG_SLASH) == DMG_SLASH then
			util.Decal("Blood", data.HitPos + data.HitNormal * 2, data.HitPos - data.HitNormal * 2, hitEnt)
			util.Decal("Blood", data.HitPos + data.HitNormal * 2, data.HitPos - data.HitNormal * 2)
		elseif (self.DamageType or DMG_SLASH) == DMG_CLUB then
			if hitEnt:IsPlayer() then
				hg.ApplyBruiseTo(hitEnt, hitEnt, data.HitPos, data.HitNormal)
			elseif hitEnt:GetClass() == "prop_ragdoll" then
				local ragOwner = hg.RagdollOwner(hitEnt)
				if IsValid(ragOwner) and ragOwner:IsPlayer() then
					hg.ApplyBruiseTo(hitEnt, ragOwner, data.HitPos, data.HitNormal)
				end
			end
		end
	end

	-- headshot ragdoll trigger
	if isHeadshot and target:IsPlayer() and target:Alive() and not IsValid(target.FakeRagdoll) then
		if math.random() <= 0.55 then
			timer.Simple(0, function()
				if IsValid(target) and target:Alive() and not IsValid(target.FakeRagdoll) then
					hg.Fake(target)
				end
			end)
		end
	end

	if targetOrganism and isSharp then
		if not self.noStuck and lodgedEntry then
			local org = targetOrganism
			org.LodgedEntities = org.LodgedEntities or {}
			local maxLodged = self.MaxLodgedEntities or 8
			while #org.LodgedEntities >= maxLodged do
				table.remove(org.LodgedEntities, 1)
			end
			org.LodgedEntities[#org.LodgedEntities + 1] = lodgedEntry

			net.Start("organism_send")

			local tbl = {}
			tbl.LodgedEntities = org.LodgedEntities
			tbl.owner = org.owner
		
			net.WriteTable(tbl)
			net.WriteBool(true)
			net.WriteBool(false)
			net.WriteBool(false)
			net.WriteBool(true)
			net.Broadcast()

		end

		-- Sharp throwables are consumed even if a custom model has no usable bone.
		-- This prevents a damaging projectile from ricocheting off a body.
		self.removed = true
		self:Remove()
		return
	end

	if self.func and not self.BreakOnImpact then self.func(data) end
end

function ENT:Use(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if self.created + 0.5 > CurTime() then return end
	if self.removed then return end
	if IsValid(ply.FakeRagdoll) then return end
	if self.wep then
		self.removed = true

		if self.Stuck then
			self:EmitSound(self.UnstickSnd or "physics/wood/wood_plank_impact_hard3.wav", 65, math.random(110, 130))
		end

		local wep = ents.Create(self.wep)
		if not IsValid(wep) then
			self.removed = false
			return
		end
		wep:Spawn()
		wep:SetPos(self:GetPos())
		wep:SetAngles(self:GetAngles())
		wep.poisoned2 = self.poisoned2

		if not hook.Run("PlayerCanPickupWeapon",ply,wep) then wep.IsSpawned = true wep.init = true wep:Remove() self:Remove() return end

		local tbl = constraint.FindConstraint(self, "Weld")
		local weldedEnt, weldedBone
		if tbl then
			if tbl.Ent1 == self then
				weldedEnt, weldedBone = tbl.Ent2, tbl.Bone2
			elseif tbl.Ent2 == self then
				weldedEnt, weldedBone = tbl.Ent1, tbl.Bone1
			end
		end
		if IsValid(weldedEnt) then
			if weldedEnt:IsPlayer() or weldedEnt:IsRagdoll() then
				local dmginfo = DamageInfo()
				dmginfo:SetAttacker(IsValid(self.owner) and self.owner or game.GetWorld())
				dmginfo:SetInflictor(self)
				dmginfo:SetDamage(self.returndamage or 10)
				dmginfo:SetDamagePosition(self:GetPos())
				dmginfo:SetDamageType(DMG_SLASH)
				self.PainMultiplier = 0.5
				weldedEnt:TakeDamageInfo(dmginfo)
				hg.organism.AddWoundManual(weldedEnt,self.returnblood or 10,vector_origin,angle_zero,weldedBone or 0,CurTime())
			end
		end

		self:Remove()
		ply:PickupWeapon(wep)
	end
end
