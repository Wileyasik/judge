AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetSolid(SOLID_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(self.Mass or 500)
		phys:Wake()
	end
	self:SetSkin(0)
	self.CurLife = self.Life or 50
	self.Armed = false
	self.Arming = false
	self.Exploded = false
	self.Attacker = IsValid(self.GBOWNER) and self.GBOWNER or self
end
function ENT:Arm()
	if self.Exploded or self.Armed or self.Arming then return end
	self.Arming = true
	if self.ArmDelay and self.ArmDelay > 0 then
		timer.Simple(self.ArmDelay, function()
			if IsValid(self) then
				self:ArmInternal()
			end
		end)
	else
		self:ArmInternal()
	end
end
function ENT:ArmInternal()
	if self.Exploded or self.Armed then
		self.Arming = false
		return
	end
	self.Armed = true
	self.Arming = false
	if isstring(self.ArmSound) and self.ArmSound ~= "" then
		self:EmitSound(self.ArmSound)
	end
end
function ENT:BuildProfile()
	local function pick(value)
		if istable(value) then return table.Random(value) end
		return value
	end
	return {
		Decal = self.Decal,
		Trace = self.TraceLength,
		Effect = self.Effect,
		EffectAir = self.EffectAir,
		EffectWater = self.EffectWater,
		Sound = pick(self.ExplosionSound),
		FarSound = pick(self.FarExplosionSound),
		WaterSound = pick(self.WaterSound),
		WaterFarSound = pick(self.WaterFarSound),
		Force = self.PhysForce,
		Lift = self.PhysLift
	}
end
function ENT:Explode(pos)
	if self.Exploded then return end
	self.Exploded = true
	local epos = isvector(pos) and Vector(pos) or self:GetPos()
	if not util.IsInWorld(epos) then
		self:Remove()
		return
	end
	local owner = IsValid(self.Attacker) and self.Attacker or self
	if rem_QueueExplosion then
		rem_QueueExplosion({Pos = epos, Radius = self.ExplosionRadius, Damage = self.ExplosionDamage, Owner = owner, Ent = self, Profile = self:BuildProfile()})
	else
		util.BlastDamage(self, owner, epos, self.ExplosionRadius, self.ExplosionDamage)
		self:Remove()
		return
	end
	self:SetNoDraw(true)
	self:SetNotSolid(true)
	self:SetMoveType(MOVETYPE_NONE)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
end
function ENT:PhysicsCollide(data, phys)
	if self.Exploded then return end
	if not data or (data.Speed or 0) < (self.ImpactSpeed or 200) then return end
	if not self.Armed then
		if not self.Arming then
			self:Arm()
		end
		return
	end
	if self.ShouldExplodeOnImpact then
		self:Explode(data.HitPos)
	end
end
function ENT:OnTakeDamage(dmginfo)
	if self.Exploded then return end
	local inflictor = dmginfo:GetInflictor()
	if IsValid(inflictor) and inflictor.IsRemBomb then return end
	self:TakePhysicsDamage(dmginfo)
	if not self.Armed then
		if not self.Arming then
			self:Arm()
		end
		return
	end
	self.CurLife = (self.CurLife or 50) - dmginfo:GetDamage()
	if self.CurLife <= 0 then
		self.CurLife = self.Life or 50
		timer.Simple(math.Rand(0.05, 0.25), function()
			if IsValid(self) and not self.Exploded then
				self:Explode()
			end
		end)
	end
end
function ENT:Use(activator, caller)
	if self.Exploded or self.Armed or self.Arming then return end
	if IsValid(activator) and activator:IsPlayer() then
		self:Arm()
	end
end
function ENT:OnRemove()
	self:StopParticles()
end
