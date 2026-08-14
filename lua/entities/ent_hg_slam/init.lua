AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.WorldModel)
	self:SetBodygroup(0,1)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)  -- Фурри
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE) 
	self:DrawShadow(true)
	self:SetBodygroup(1, 1)
	self.Safety = CurTime() + 3
	self:SetNWFloat("Safety", self.Safety)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(true)
		--phys:Sleep()
	end
	
	
	if IsValid(phys) then
		phys:SetMass(20)
	end

end


function ENT:Use(activator, caller)
	return false
end


function ENT:PhysgunPickup(ply, ent)
   -- return false
end

function ENT:ActivateExplosive()
	if self.Exploded then return end
	self.Exploded = true
	local selfPos = self:GetPos()
	local pos, ang = LocalToWorld(self.offsetPos, self.offsetAng, self:GetPos(), self:GetAngles())

	local bullet = {}
	bullet.Src = pos
	bullet.Penetration = 300
	bullet.Dir = ang:Forward()
	bullet.Force = 350
	bullet.Damage = 450
	bullet.Speed = 3000
	bullet.AmmoType = "14.5x114mm B32" 
	bullet.Attacker = self.owner
	bullet.Distance = 56756
	bullet.Callback = hg.bulletHit
	bullet.Tracer = 10000
	bullet.DisableLagComp = true
	bullet.Filter = {self}
	bullet.HullSize = Vector(5,5,5)

	local num = 120

	local co = coroutine.create(function()
		local LastShrapnel = SysTime()

		for i = 1, num do
			LastShrapnel = SysTime()
			local vecCone = Vector(
				(i / num) ^ 4 / 5 * 5 * 5 + (math.random(0, 1) and math.random(100) / 100),
				(i / num) ^ 4 / 2 * 5 + (math.random(0, 1) and math.random(100) / 100),
				0
			)
			bullet.Spread = vecCone
			bullet.Penetration = math.Clamp(num / i, 5, 10) * 10
			-- for i2 = 1, 5 do
				--if not IsValid(self) then return end
			if not IsValid(self) then return end
			self:FireLuaBullets(bullet,true)

			LastShrapnel = SysTime() - LastShrapnel

			if LastShrapnel > 0.001 then
				coroutine.yield()
			end

			--end
		end
		self.ShrapnelDone = true
	end)

	local index = self:EntIndex()
	local timerName = "GrenadeCheck_" .. index
	local function finishShrapnel()
		timer.Remove(timerName)
		timer.Simple(0.01, function()
			if not IsValid(self) then return end
			util.ScreenShake(selfPos, 20, 20, 1, 500)
			SafeRemoveEntity(self)
		end)
	end
	local function resumeShrapnel()
		local ok, err = coroutine.resume(co)
		if not ok then
			ErrorNoHalt("[ent_hg_slam] Shrapnel coroutine failed: " .. tostring(err) .. "\n")
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

	hg.ExplosionEffect(selfPos, self.BlastDis, 5)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		hg.BlastDamageWithShockwave(self, Entity(0), selfPos, self.BlastDis / 0.01905, self.BlastDamage * 1, { ExplosionType = "Small" })
	end)
end

function ENT:OnTakeDamage(dmginfo)
	if dmginfo:GetInflictor() == self then return end
	if dmginfo:IsDamageType(DMG_BLAST + DMG_BULLET + DMG_BUCKSHOT + DMG_BURN) then
		self:ActivateExplosive()
	end
end
