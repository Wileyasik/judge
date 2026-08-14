AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.BlastDis = 680
ENT.BlastDamage = 100
ENT.ShrapnelDis = 500
ENT.ShrapnelDamage = 65
ENT.ConcussionDis = 1365
ENT.ConcussionDamage = 30

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(ONOFF_USE)
	self:DrawShadow(true)
	self.MotionTriggerIsActivated = false
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:EnableMotion(false) 
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.CanBeKnockedOver and data.Speed > 80 then
		phys:EnableMotion(true)
		phys:Wake()

		local force = data.Speed * 0.2
		phys:ApplyForceOffset(data.HitNormal * force * 10, data.HitPos)
	end
end

function ENT:Use(activator)
	if not self.MotionTriggerIsActivated then
		self.MotionTriggerIsActivated = true
		self:EmitSound("snds_jack_gmod/toolbox" .. math.random(1,7) .. ".wav",55,100,1)
		if IsValid(activator) and activator:IsPlayer() then
			activator:ViewPunch(Angle(2,0,0))
		end
	end
end

local vec_huy = Vector(0,0,0)
function ENT:ActivateExplosive()
	if self.Exploded then return end
	self.Exploded = true
	local selfPos = self:GetPos()
	local pos, ang = LocalToWorld(self.offsetPos, self.offsetAng, self:GetPos(), self:GetAngles())
	local num = 700

	local bullet = {}
	bullet.Force = 2
	bullet.Damage = 10
	bullet.AmmoType = "Metal Debris"
	bullet.Attacker = self.owner
	bullet.Distance = 56756
	bullet.Callback = hg.bulletHit
	bullet.IgnoreEntity = self
	bullet.Tracer = 10000
	bullet.DisableLagComp = true
	bullet.Filter = {self}

	local co = coroutine.create(function()
		local LastShrapnel = SysTime()

		for i = 1, num do
			LastShrapnel = SysTime()

			local dir = (ang + Angle(math.Rand(-12, 2), math.Rand(-30, 30), 0)):Forward()
			dir:Normalize()

			local tr = util.TraceLine({
				start = pos,
				endpos = pos + dir * bullet.Distance,
				filter = bullet.Filter,
				mask = MASK_SHOT
			})
			if i > 100 and tr.Entity == game.GetWorld() then util.Decal("ExplosiveGunshot",tr.HitPos+tr.HitNormal,tr.HitPos-tr.HitNormal) continue end

			bullet.Src = pos
			bullet.Dir = dir
			bullet.Penetration = math.Clamp(num / i, 5, 10) * 10
			if not IsValid(self) then return end
			self:FireLuaBullets(bullet,true)

			LastShrapnel = SysTime() - LastShrapnel

			if LastShrapnel > 0.001 then
				coroutine.yield()
			end
		end

		self.ShrapnelDone = true
	end)

	local index = self:EntIndex()
	local timerName = "GrenadeCheck_" .. index
	local function finishShrapnel()
		timer.Remove(timerName)
		timer.Simple(0, function()
			if not IsValid(self) then return end
			util.ScreenShake(selfPos, 20, 20, 1, self.ConcussionDis)
			SafeRemoveEntity(self)
		end)
	end
	local function resumeShrapnel()
		local ok, err = coroutine.resume(co)
		if not ok then
			ErrorNoHalt("[ent_claymore] Shrapnel coroutine failed: " .. tostring(err) .. "\n")
		end
		if not ok or coroutine.status(co) == "dead" or self.ShrapnelDone then
			finishShrapnel()
			return false
		end
		return true
	end

	timer.Create(timerName, 0, 0, function()
		if !IsValid(self) then
			timer.Remove(timerName)
			return
		end
		resumeShrapnel()
	end)
	resumeShrapnel()

	net.Start("projectileFarSound")
		net.WriteString(table.Random(self.Sound))
		net.WriteString(table.Random(self.SoundFar))
		net.WriteVector(selfPos)
		net.WriteEntity(self)
		net.WriteBool(self:WaterLevel() > 0)
		net.WriteString(self.SoundWater)
	net.Broadcast()
	local normal = self:GetAngles():Right()
	local blastdist = self.BlastDis
	local attacker = IsValid(self.owner) and self.owner or Entity(0)
	
	for _, ply in ipairs(ents.FindInSphere(selfPos,self.ConcussionDis)) do
		if not ply:IsPlayer() then continue end
		local tr = hg.ExplosionTrace(selfPos,ply:GetPos(),{self})
		if tr.Entity != ply then continue end
		local dist = ply:GetPos():Distance(selfPos)
		local tinnitusDuration = math.Clamp(10 * (1 - dist/self.ConcussionDis), 2, 10)
		ply:AddTinnitus(math.max(tinnitusDuration,1.5), true)
		if ply.organism then
			local clayConc = math.Clamp(tinnitusDuration * 0.18, 0.15, 1.5)
			hg.organism.module.concussion.AddConcussion(ply.organism, clayConc, tinnitusDuration)
		end
	end
	   
	--util.BlastDamage(self, attacker, selfPos, self.ShrapnelDis, self.BlastDamage)
	hg.BlastDamageWithShockwave(self, attacker, selfPos, self.BlastDis, self.ShrapnelDamage, {Shockwave = false})
	hg.ApplyExplosionShockwave({
		Origin = selfPos,
		Radius = self.ConcussionDis,
		MaxDistance = self.ConcussionDis,
		Damage = self.ConcussionDamage,
		Attacker = attacker,
		Inflictor = self,
		Filter = {self}
	})
	--util.BlastDamage(self, attacker, selfPos, self.ConcussionDis, self.ConcussionDamage)
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() == self then return end
	if dmginfo:IsDamageType(DMG_BLAST + DMG_BULLET + DMG_BUCKSHOT + DMG_BURN) then
		self:ActivateExplosive()
	end
end
