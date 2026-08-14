AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local CUSTOM_EXPLOSION_SOUNDS = {
	"explosions/explode3.wav",
	"explosions/explode4.wav",
	"explosions/explode5.wav"
}
local CUSTOM_EXPLOSION_PITCH_MIN = 110
local CUSTOM_EXPLOSION_PITCH_MAX = 120
local CUSTOM_EXPLOSION_VOLUME = 1
local CUSTOM_EXPLOSION_LEVEL = 140
local GRENADE_BLAST_RADIUS_MULT = 2.2
local GRENADE_BLAST_DAMAGE = 40
local GRENADE_DISORIENTATION_RADIUS = 15
local GRENADE_KNOCKBACK_FORCE = 16500
local GRENADE_LIFT_FORCE = 35000
local GRENADE_LIFT_FRAC = 0.85

function ENT:InitAdd()
end

ENT.LegacyInDoorSound = false

ENT.TrapSettleTime = 1.5
ENT.TrapSettleLen = 40

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
end

function ENT:Use(ply)
	if self:IsPlayerHolding() then return end

	ply:PickupObject(self)
	self.owner = ply
end

function ENT:Think()
	if CLIENT then return end
	local curTime = CurTime()
	self:NextThink(curTime)

	if self.AddThink then
		self:AddThink()
	end

	if (curTime - ( self.CreateTime or 0 )) >= 90 and self.owner ~= nil then
		self:SetOwner(nil)
		self.owner = nil
		self.shouldBoom = true
	end

	if not self.timer then
		if self.Disarmed then return true end

		local settling = ( curTime - ( self.trapSetTime or curTime ) ) < ( self.TrapSettleTime or 1.5 )

		if IsValid(self.ent) or self.ent == Entity(0) then
			if not self.trapSetTime then
				self.trapSetTime = curTime
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
					self:Arm(curTime - self.timeToBoom + 1)
				end

				local tr = {}
				tr.start = self:GetPos()
				tr.endpos = wpos
				tr.filter = {self,self.ent2,self.ent,self.peg}
				local trace = util.TraceLine(tr)
				if IsValid(trace.Entity) and trace.Entity != self.ent and trace.Entity != self.peg then
					self:Arm(curTime - self.timeToBoom + 1,trace.Entity:GetVelocity())
				end
			end
		end
		if not IsValid(self.cons2) then
			if settling then
				self:DisarmTrap()
			else
				self:Arm(curTime - self.timeToBoom + 1,0)
			end
		end
		return true
	end

	local time = curTime - self.timer
	if time < self.timeToBoom then hg.EmitAISound(self:GetPos(), 256, 2, 8) end
	if time > self.timeToBoom and not self.Exploded then self:Explode() end
	
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

local clr = Color(50, 40, 0)
local function createSpoon(self)
	local entasd = ents.Create("ent_hg_spoon")
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

function ENT:Arm(time,vel)
	local vel = vel or Vector(0,0,0)
	time = time or CurTime()
	if not self.NotSpoon then
		createSpoon(self)
	end
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

local vecCone = Vector(0, 0, 0)

function ENT:PoopBomb()
	return math.random(1, 100) == 1
end

function ENT:Explode()
	if self:PoopBomb() or (!self.shouldBoom and !IsValid(self.owner)) then
		self:EmitSound("weapons/p99/slideback.wav", 75)
		self.Exploded = true
		return
	end
	hg.EmitAISound(self:GetPos(), 512, 16, 1)
	
	self.owner = self.owner or Entity(0)

	local selfPos = self:GetPos() + self:OBBCenter()

	self.Exploded = true

	local indoors = false
	

	local hits = 0
	local total = 4 
	
	local traceUp = util.TraceLine({
		start = selfPos,
		endpos = selfPos + Vector(0, 0, 1000),
		mask = MASK_SOLID,
		filter = self
	})
	
	if traceUp.Hit and not traceUp.HitSky then
		hits = hits + 1
	end
	

	for i = 1, 3 do
		local dir = VectorRand()
		dir.z = math.abs(dir.z) * 1.5 
		dir:Normalize()
		
		local traceAngled = util.TraceLine({
			start = selfPos,
			endpos = selfPos + dir * 700,
			mask = MASK_SOLID_BRUSHONLY,
			filter = self
		})
		
		if traceAngled.Hit and not traceAngled.HitSky then
			hits = hits + 1
		end
	end
	
	indoors = hits / total >= 0.5 

	if self:WaterLevel() == 0 then
		local line = util.TraceLine(
			{
				start = self:GetPos(),
				endpos = self:GetPos() - vector_up * 25,
				mask = MASK_SHOT,
				filter = self
			})
		--if line.Hit then
		--	ParticleEffect("pcf_jack_groundsplode_small3",selfPos,-vector_up:Angle())
		--else
		--end
	else
		local effectdata = EffectData()
		effectdata:SetOrigin(selfPos)
		effectdata:SetScale(self.BlastDis/2.5)
		effectdata:SetNormal(-self:GetAngles():Forward())
		util.Effect("eff_jack_genericboom", effectdata)
	end

	net.Start("projectileFarSound")
		net.WriteString(self.Sound[math.random(#self.Sound)])
		net.WriteString(self.SoundFar[math.random(#self.SoundFar)])
		net.WriteVector(self:GetPos())
		net.WriteEntity(self)
		net.WriteBool(self:WaterLevel() > 0)
		net.WriteString(self.SoundWater[math.random(#self.SoundWater)])
	hg.SendNetToPlayersWithin(self:GetPos(), 25000)

	if self:WaterLevel() > 0 then
		self:EmitSound(self.SoundWater, 140, 85, 1, CHAN_WEAPON)
		self:EmitSound(self.SoundBass[math.random(#self.SoundBass)], 150, 70, 0.8, CHAN_AUTO)
	else
		self:EmitSound(self.Sound[math.random(#self.Sound)], 145, 85, 1, CHAN_WEAPON)
		self:EmitSound(self.SoundFar[math.random(#self.SoundFar)], 140, 85, 0.9, CHAN_WEAPON)
		
		timer.Simple(0.05, function() 
			if IsValid(self) then
				self:EmitSound(self.SoundBass[math.random(#self.SoundBass)], 150, 70, 0.95, CHAN_AUTO) 
			end
		end)

		timer.Simple(0.1, function() 
			if IsValid(self) then
				self:EmitSound(self.SoundBass[math.random(#self.SoundBass)], 155, 60, 0.9, CHAN_BODY) 
			end
		end)
	end

	EmitSound(self.Sound[math.random(#self.Sound)], self:GetPos(), self:EntIndex() + 100, CHAN_STATIC, 1, 140, nil, math.random(75, 85))
	EmitSound(table.Random(CUSTOM_EXPLOSION_SOUNDS), self:GetPos(), self:EntIndex() + 104, CHAN_STATIC, CUSTOM_EXPLOSION_VOLUME, CUSTOM_EXPLOSION_LEVEL, nil, math.random(CUSTOM_EXPLOSION_PITCH_MIN, CUSTOM_EXPLOSION_PITCH_MAX))

	if self:WaterLevel() > 0 then
		self:EmitSound(self.SoundWater, 100, 100, 1, CHAN_WEAPON)
	else
		self:EmitSound(self.Sound[math.random(#self.Sound)], 100, 100, 1, CHAN_WEAPON)
		self:EmitSound(self.SoundFar[math.random(#self.SoundFar)], 95, 100, 0.8, CHAN_WEAPON)
	end


	if indoors and self.LegacyInDoorSound then

		if not util.TraceLine({start = self:GetPos(), endpos = self:GetPos() + Vector(0,0,500), filter = self,mask = MASK_SOLID_BRUSHONLY}).HitSky then
			for i = 1, 3 do
				local debris_sound = self.DebrisSounds[math.random(#self.DebrisSounds)]
				timer.Simple(i * 0.15, function()
					if IsValid(self) then
						self:EmitSound(debris_sound, 90, math.random(95, 105), 1, CHAN_AUTO)
					end
				end)
			end
		end
		
		EmitSound(self.DebrisSounds[math.random(#self.DebrisSounds)], self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 80)
	end

	hg.BlastDamageWithShockwave(self, IsValid(self.owner) and self.owner or self, selfPos, self.BlastDis / 0.01905 * GRENADE_BLAST_RADIUS_MULT, GRENADE_BLAST_DAMAGE, {
		Force = GRENADE_KNOCKBACK_FORCE,
		ExplosionType = "Small"
	})

	--;; Расскажу вам тайну но у нас трассировка делалась просто ужасно
	local dis = self.BlastDis / 0.01905 * GRENADE_BLAST_RADIUS_MULT
	local disorientation_dis = GRENADE_DISORIENTATION_RADIUS / 0.01905
	local entsCount = 0
	local propForces = {}
	for i, enta in ipairs(ents.FindInSphere(selfPos, disorientation_dis)) do
		local entPos = enta:GetPos()
		local phys = enta:GetPhysicsObject()
		if IsValid(phys) then
			entsCount = entsCount + 1
		end

		local force = entPos - selfPos
		local len = force:Length()
		local frac = math.Clamp((disorientation_dis - len) / disorientation_dis, 0.1, 1)
		local tracePos = enta:IsPlayer() and (entPos + enta:OBBCenter()) or entPos
		local tr = hg.ExplosionTrace(selfPos, tracePos, {self})

		if enta.organism then
			if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() then
				if not enta.organism.owner.organism or not enta.organism.owner.organism.godmode then
					local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
					local div = behindwall and hg.GetBlastWallAttenuation(tr) or 1
					hg.ExplosionDisorientation(enta, 5 * frac / div, 6 * frac / div)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end
		end

	end

	if entsCount > 10 and not self.LegacyInDoorSound then
		for i = 1, 3 do
			local debris_sound = self.DebrisSounds[math.random(#self.DebrisSounds)]
			timer.Simple(i * 0.15, function()
				if IsValid(self) then
					self:EmitSound(debris_sound, 90, math.random(95, 105), 1, CHAN_AUTO)
				end
			end)
		end

		EmitSound(self.DebrisSounds[math.random(#self.DebrisSounds)], self:GetPos(), self:EntIndex(), CHAN_AUTO, 1, 80)
	end
	
	local Poof=EffectData()
	Poof:SetOrigin(selfPos)
	Poof:SetScale(1.2)
	util.Effect("eff_jack_hmcd_shrapnel",Poof,true,true)

	timer.Simple(0, function()
		if not IsValid(self) then return end
		util.ScreenShake( selfPos, 35, 200, 1, 1000, false, nil, 2 )

		local ammo = "Metal Debris"
		local ammotype = hg.ammotypeshuy[ammo].BulletSettings

		local co = coroutine.create(function()

			local LastShrapnel = SysTime()
			local filter = {self}
			local penetration = (ammotype.Penetration or (-(-self.Penetration))) * (self.PenetrationMultiplier or 1)
			local diameter = ammotype.Diameter or 1
			local bullet = {
				Speed = ammotype.Speed,
				Distance = 56756,
				MaxPenLen = 100,
				Diameter = diameter,
				Src = selfPos,
				Spread = vecCone,
				Force = 20,
				Damage = 40,
				AmmoType = ammo,
				Attacker = self.owner,
				Inflictor = self,
				DisableLagComp = true,
				Filter = filter,
				Callback = hg.bulletHit
			}

			for i = 1, self.Fragmentation do
					LastShrapnel = SysTime()

					local dir = VectorRand(-1,1):GetNormalized()--vector_up
					dir[3] = dir[3] > 0 and math.abs(dir[3] - 0.5) or -math.abs(dir[3] + 0.5)
					dir:Normalize()

					local Tr = util.QuickTrace(selfPos, dir * 10000, self)

					if Tr.Hit and !Tr.HitSky and !Tr.HitWorld then
						if not IsValid(self) then return end
						bullet.penetrated = 0
						bullet.Penetration = penetration
						bullet.Diameter = diameter
						bullet.Dir = dir

						self:FireLuaBullets(bullet, true)
					end

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
				if IsValid(self) then SafeRemoveEntity(self) end
			end)
		end
		local function resumeShrapnel()
			local ok, err = coroutine.resume(co)
			if not ok then
				ErrorNoHalt("[ent_hg_grenade] Shrapnel coroutine failed: " .. tostring(err) .. "\n")
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
		if self.ExplodeAdd then
			self:ExplodeAdd()
		end
	end)
	util.ScreenShake( selfPos, 35, 1, 1, 1000, true )
	hg.EmitAISound(self:GetPos(), 300, 3, bit.bor(1, 33554432)) -- надеюсь буде работать
end

--;; Салат если ты подумаешь что это чатговноти то это послание вам - FUCK YOU!
local vec10 = Vector(0, 0, 10)
function ENT:PlaySndExplosion(snd, server, chan, vol, pitch, entity, tripleaffirmative)
	if SERVER and not server then return end
	
	vol = vol or 1.2 
	pitch = pitch or 85 
	chan = chan or CHAN_WEAPON
	local rand = math.random(-5, 5)

	EmitSound(snd, self:GetPos(), (entity or self:EntIndex()), chan, vol, 140, nil, pitch + rand)

	if not string.find(snd:lower(), "water") then
		timer.Simple(0.05, function()
			if IsValid(self) then
				EmitSound(self.SoundBass[math.random(#self.SoundBass)], self:GetPos(), (entity or self:EntIndex()) + 50, CHAN_AUTO, vol * 0.8, 140, nil, 70)
			end
		end)
	end

	if tripleaffirmative then
		EmitSound(snd, self:GetPos() - vec10, (entity or self:EntIndex()) + 1, chan, vol, 140, nil, pitch + rand - 5)
		EmitSound(snd, self:GetPos() + vec10, (entity or self:EntIndex()) + 2, chan, vol * 0.9, 140, nil, pitch + rand + 5)

		timer.Simple(0.1, function()
			if IsValid(self) then
				EmitSound(self.SoundBass[math.random(#self.SoundBass)], self:GetPos(), (entity or self:EntIndex()) + 3, CHAN_BODY, vol * 0.7, 140, nil, 60)
			end
		end)
	end
end

-- дека это че
--[[function ENT:PlaySndExplosion(snd, server, chan, vol, pitch, entity, tripleaffirmative)
	if SERVER and not server then return end
	
	vol = vol or 1
	pitch = pitch or 100
	chan = chan or CHAN_WEAPON
	local rand = math.random(-5, 5)
	
	EmitSound(snd, self:GetPos(), (entity or self:EntIndex()), chan, vol, 75, nil, pitch + rand)
	
	if tripleaffirmative then
		EmitSound(snd, self:GetPos() - Vector(0, 0, 10), (entity or self:EntIndex()) + 1, chan, vol, 75, nil, pitch + rand - 2)
		EmitSound(snd, self:GetPos() + Vector(0, 0, 10), (entity or self:EntIndex()) + 2, chan, vol * 0.9, 75, nil, pitch + rand + 2)
	end
end]] -- омнипроджект кодинг возвращение

function ENT:PlaySndDebris(snd, vol, pitch)
	vol = vol or 1
	pitch = pitch or 100

	local indoors = not util.TraceLine({start = self:GetPos(), endpos = self:GetPos() + Vector(0,0,500), filter = self}).HitSky
	
	if indoors then
		self:EmitSound(snd, 75, pitch, vol)
		EmitSound(snd, self:GetPos(), self:EntIndex(), CHAN_AUTO, vol, 80, nil, pitch)
	end
end

function ENT:PhysicsCollide(phys, deltaTime)
	if phys.Speed > 20 then self:EmitSound("physics/metal/metal_grenade_impact_hard" .. math.random(3) .. ".wav", 65, math.random(95, 105)) end
end
