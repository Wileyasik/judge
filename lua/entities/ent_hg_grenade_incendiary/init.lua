AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:InitAdd()
end

ENT.TrapSettleTime = 1.5
ENT.TrapSettleLen = 40

local clr = Color(50, 40, 0)

local function createSpoon(self)
	local entasd = ents.Create("ent_hg_spoon")
	if not IsValid(entasd) then return end
	entasd:SetModel(self.spoon)
	entasd:SetPos(self:GetPos())
	entasd:SetAngles(self:GetAngles())
	entasd:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	entasd:Spawn()

	if self.spoon == "models/codww2/equipment/mk,ii hand grenade spoon.mdl" then
		entasd:SetMaterial("models/shiny")
		entasd:SetColor(clr)
	end

	entasd:EmitSound("weapons/m67/m67_spooneject.wav",65)
	hg.EmitAISound(self:GetPos(), 256, 5, 8)

	return entasd
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(USE_TOGGLE)
	self:DrawShadow(true)
	self:InitAdd()
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	timer.Simple(0.1,function()
		if not IsValid(self) then return end
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
	end)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(5)
		phys:Wake()
		phys:EnableMotion(true)
	end

	self.CreateTime = CurTime()
	self.Burning = false
	self.FireCheck = 0.5
	self.FireCheckTime = CurTime()
	self.FireRadius = 256
	self.BurnTime = math.random(30, 45)
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	if not self.Burning then
		ply:PickupObject(self)
	else
		self:BurnIdiot(ply, 1, true)
	end
	
	self.owner = ply
end

function ENT:BurnIdiot(ply, intensity, touched_grenade)
	intensity = intensity or 1

	local org = ply.organism
	if !org or intensity <= 0 then return end

	local attacker = self.owner or self
	if touched_grenade then attacker = ply end

	local pain = 20
	if touched_grenade then pain = 100 end

	pain = pain * intensity

	local dmg = DamageInfo()
	dmg:SetDamage(pain * 5)
	dmg:SetAttacker(attacker)
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_BURN)

	ply:TakeDamageInfo(dmg)

	if touched_grenade then
		local stupid = {
			"OUGHH! FUCK!! I SHOULDN'T HAVE TOUCHED THAT..",
			"OH GOD- WHY'D I TOUCH THAT?!..",
			"I-IT'S TOO HOT!!",
			"AUGUGAHHH!! I'M SO FUCKING STUPID!!"
		}

		ply:Notify(stupid[math.random(#stupid)], 0, "touched_hot_thing", 0.2)
	end

	if intensity > 0.5 then
		ply:Ignite()
	end

	org.painadd = org.painadd + pain
end

function ENT:Arm(time,vel)
	local vel = vel or Vector(0,0,0)
	time = time or CurTime()
	if not self.NotSpoon then
		createSpoon(self)
	end

	self:SetModel("models/weapons/floppa/incendiary/w_m18_thrown.mdl")

	self.timer = time
	if self.lpos then
		local wpos = self.ent:LocalToWorld(self.lpos)
		
		if IsValid(self.cons2) then
			self.cons2:Remove()
		end

		timer.Simple(0.1,function()
			if wpos and IsValid(self) then
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetVelocity((wpos - self:GetPos()):GetNormalized())
				end
			end
		end)

		if IsValid(self.cons) then
			self.cons:Remove()
		end
		if IsValid(self.ent2) then
			self.ent2:Remove()
		end
		if IsValid(self.peg) then
			self.peg:Remove()
		end
		if IsValid(self.peg2) then
			self.peg2:Remove()
		end
		self.ent = nil
		self.lpos = nil
	end
end

function ENT:Think()
	if CLIENT then return end

	self:NextThink(CurTime())

	if self.Burning and CurTime() - self.FireStart > self.BurnTime then
		self.Burning = false

		self:SetNW2Bool("FireEffect", false)
		self:SetNW2Bool("Extinguished", true)

		if self.loop then
			self:StopLoopingSound(self.loop)
		end

		self:EmitSound("floppa.incendiary.burn.stoploop", 75, 100)
		self:StopSound("floppa.incendiary.burn.start")

		SafeRemoveEntityDelayed(self, 600)
	else
		if self.Burning and CurTime() - self.FireCheckTime > self.FireCheck then
			self:Burn()
			self.FireCheckTime = CurTime()
		end
	end

	if not self.timer then
		if self.Disarmed then return true end

		local settling = ( CurTime() - ( self.trapSetTime or CurTime() ) ) < ( self.TrapSettleTime or 1.5 )

		if IsValid(self.ent) or self.ent == Entity(0) then
			if not self.trapSetTime then
				self.trapSetTime = CurTime()
			end

			local ent,lpos,origlen = self.ent,self.lpos,self.origlen
			
			local wpos = ent:LocalToWorld(lpos)
			local dist = wpos:Distance(self:GetPos())

			if settling then
				if dist > origlen + ( self.TrapSettleLen or 40 ) then
					self:DisarmTrap()
				end
			else
				if dist > origlen + 20 then
					self:Arm(CurTime() - self.timeToBoom + 1)
				end

				local tr = {}
				tr.start = self:GetPos()
				tr.endpos = wpos
				tr.filter = {self,self.ent2,self.ent,self.peg}
				local trace = util.TraceLine(tr)
				if IsValid(trace.Entity) and trace.Entity != self.ent and trace.Entity != self.peg then
					self:Arm(CurTime() - self.timeToBoom + 1,trace.Entity:GetVelocity())
				end
			end
		end

		if not IsValid(self.cons2) then
			if settling then
				self:DisarmTrap()
			else
				self:Arm(CurTime() - self.timeToBoom + 1,0)
			end
		end

		return true
	end

	if (CurTime() - self.timer) < self.timeToBoom then hg.EmitAISound(self:GetPos(), 256, 2, 8) end
	if (CurTime() - self.timer) > self.timeToBoom and not self.Exploded then self:Explode() end

	return true
end

function ENT:DisarmTrap()
	if self.Disarmed then return end
	self.Disarmed = true
	if IsValid(self.cons) then self.cons:Remove() end
	if IsValid(self.ent2) then self.ent2:Remove() end
	if IsValid(self.cons2) then self.cons2:Remove() end
	if IsValid(self.peg) then self.peg:Remove() end
	if IsValid(self.peg2) then self.peg2:Remove() end
	self.ent = nil
	self.lpos = nil
	self.origlen = nil
end

function ENT:Burn()
	hg.EmitAISound(self:GetPos(), 512, 5, 8)

	local water_level = self:WaterLevel()

	if CurTime() - self.FireStart > self.FireCheck * 1.5 then
		for _, radius_entity in pairs(ents.FindInSphere(self:GetPos(), self.FireRadius)) do
			if radius_entity:IsPlayer() or radius_entity:IsRagdoll() then
				local tracePos = radius_entity:IsPlayer() and (radius_entity:GetPos() + radius_entity:OBBCenter()) or radius_entity:GetPos()
				local tr = hg.ExplosionTrace(self:GetPos(), tracePos, {self})
				local can = tr.Entity == radius_entity

				local dist = tracePos:Distance(self:GetPos())
				local perc = math.Clamp((1 - (dist / self.FireRadius) ^ 2), 0, 1)

				if can then
					self:BurnIdiot(radius_entity, perc, false)
					
					local rand_thing_idk = math.Round(math.Clamp(4 * (1 - perc), 1, 4))
					if math.random(rand_thing_idk) == 1 and water_level == 0 and perc < 0.5 then
						CreateVFireBall((5 * perc), (50 * perc), tracePos, Vector(0, 0, 0) + VectorRand() * (4 * perc), self.owner or self)
					end
				end
			elseif radius_entity:GetClass() == "prop_physics" or radius_entity:IsWeapon() then
				local tracePos = radius_entity:GetPos()
				local tr = hg.ExplosionTrace(self:GetPos(), tracePos, {self})
				local can = tr.Entity == radius_entity

				local dist = tracePos:Distance(self:GetPos())
				local perc = math.Clamp((1 - (dist / self.FireRadius) ^ 3), 0, 1)

				if can then
					local dmg = DamageInfo()
					dmg:SetDamage(800 * perc)
					dmg:SetDamageType(DMG_BURN + DMG_DISSOLVE)
					dmg:SetAttacker(self.owner or self)
					dmg:SetInflictor(self)
					dmg:SetDamageForce(Vector(0, 0, 0))

					radius_entity:TakeDamageInfo(dmg)

					local rand_thing_idk = math.Round(math.Clamp(4 * (1 - perc), 2, 4))

					if math.random(rand_thing_idk) == 1 and water_level == 0 then
						radius_entity:Ignite()
						-- CreateVFireBall((5 * perc), (50 * perc), tracePos, Vector(0, 0, 0) + VectorRand() * (4 * perc), self.owner or self)
					end
					
					local physics = radius_entity:GetPhysicsObject()
					if IsValid(physics) then
						if perc > 0.9 and math.random(5) == 1 and physics:GetMass() < 100 then
							radius_entity:Dissolve(3)
						end
					end
				end
			elseif radius_entity:IsNPC() then
				local tracePos = radius_entity:GetPos() + radius_entity:OBBCenter()
				local tr = hg.ExplosionTrace(self:GetPos(), tracePos, {self})
				local can = tr.Entity == radius_entity

				if can then
					local dmg = DamageInfo()
					dmg:SetDamage(80)
					dmg:SetDamageType(DMG_BURN)
					dmg:SetAttacker(self.owner or self)
					dmg:SetInflictor(self)
					dmg:SetDamageForce(Vector(0, 0, 0))
					
					radius_entity:TakeDamageInfo(dmg)
					radius_entity:Ignite()
				end
			end
		end
	end

	if water_level == 0 and math.random(2) == 1 then
		local vel = self:GetVelocity()
		CreateVFireBall(10, 50, self:GetPos(), (vel / 2) - vector_up + VectorRand() * 150, self.owner or self)
	end
end

local vecCone = Vector(0, 0, 0)

function ENT:PoopBomb()
	return math.random(1, 100) == 1
end

function ENT:Explode()
	if self.Exploded or self.Burning then return end

	if (!self.shouldBoom and !IsValid(self.owner)) then
		self:EmitSound("weapons/p99/slideback.wav", 75)
		self.Exploded = true
		return
	end

	hg.EmitAISound(self:GetPos(), 512, 16, 1)
	
	self.owner = self.owner or Entity(0)

	local SelfPos, Owner = self:LocalToWorld(self:OBBCenter()), self:GetOwner() or self
	self.FireStart = CurTime()

	self.Exploded = true
	self.Burning = true
	self:SetNW2Bool("FireEffect", true)

	for i = 1, math.random(5, 20) do
		local vel = self:GetVelocity()
		CreateVFireBall(0.5 / i, 10 / i, SelfPos, vel / 5 - vector_up + VectorRand() * 150, self.owner or self)
	end

	timer.Simple(.05, function()
		if not IsValid(self) then return end
		sound.Play("snd_jack_firebomb.wav", SelfPos, 80, 100)
		
		timer.Simple(0.1, function()
			if not IsValid(self) then return end
			self.loop = self:StartLoopingSound("floppa.incendiary.burn.loop")
		end)

		self:EmitSound("floppa.incendiary.burn.start", 75, 100)
	end)
end

function ENT:PhysicsCollide(phys, deltaTime)
	if phys.Speed > 20 then self:EmitSound("physics/metal/metal_grenade_impact_hard" .. math.random(3) .. ".wav", 65, math.random(95, 105)) end
end
