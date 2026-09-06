--\\Silk
HGAmmo_MaxKeyBits = 13

if(SERVER)then
	util.AddNetworkString("HGAmmo(TranslateSilkToEntity)")
else
	HGAmmo_PhysSilkTranslationExpectedEntitiesTable = HGAmmo_PhysSilkTranslationExpectedEntitiesTable or {}
	HGAmmo_PhysSilkTranslationTable = HGAmmo_PhysSilkTranslationTable or {}
	
	local function translate_silk_to_ent(ent, bullet_key)
		local translation_info = HGAmmo_PhysSilkTranslationTable[bullet_key]
		
		if(translation_info)then
			if(ent.Silks)then
				for key, silk in pairs(ent.Silks) do
					silk:Die()
				end
			end
		
			for key, silk in pairs(translation_info.Silks) do
				silk.Entity = ent
			end
		
			ent.Silks = translation_info.Silks
			HGAmmo_PhysSilkTranslationTable[bullet_key] = nil
		end
	end
	
	hook.Add("Think", "HGAmmo_PhysSilkTranslationTable", function()
		for bullet_key, translation_info in pairs(HGAmmo_PhysSilkTranslationTable) do
			if(translation_info.DeathTime <= CurTime())then
				for key, silk in pairs(translation_info.Silks) do
					silk:Die()
				end
				
				HGAmmo_PhysSilkTranslationTable[bullet_key] = nil
			end
		end
	end)
	
	hook.Add("NotifyShouldTransmit", "HGAmmo_PhysSilkTranslationTable", function(ent, state)
		if(state == true)then
			local ent_id = ent:EntIndex()
			
			if(HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id])then
				translate_silk_to_ent(ent, HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id])
				
				HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id] = nil
			end
		end
	end)
	
	net.Receive("HGAmmo(TranslateSilkToEntity)", function(len, ply)
		-- Entity(1):ChatPrint(12312)
		local bullet_key = net.ReadUInt(hg.PhysBullet.MaxKeyBits)
		local ent_id = net.ReadUInt(HGAmmo_MaxKeyBits)
		local ent = Entity(ent_id)
		
		if(IsValid(ent))then
			translate_silk_to_ent(ent, bullet_key)
		else
			HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id] = bullet_key
		end
	end)
end
--//

--\\Common Function Overrides
local function scrape_blood(self, trace, len, len_before)
	if(SERVER)then
		if(trace and !trace.HitSky)then
			if(trace.Entity.organism)then
				local hit_organism = trace.Entity.organism
				hit_organism.pain = (hit_organism.pain or 0) + 60
				hit_organism.disorientation = (hit_organism.disorientation or 0) + 5
			else--if(trace.Entity:IsNPC() or trace.Entity:IsNextBot())then
				local dmg = DamageInfo()
				
				if(IsValid(self.Shooter))then
					dmg:SetAttacker(self.Shooter)
				else
					dmg:SetAttacker(game.GetWorld())
				end
				
				dmg:SetDamageType(DMG_DISSOLVE)
				dmg:SetDamage(80)
				trace.Entity:TakeDamageInfo(dmg)
			end
			
			local effect_data = EffectData()
			
			effect_data:SetOrigin(trace.HitPos)
			util.Effect("BloodImpact", effect_data)
		end
	end
	
	-- self:Die()
end

local function onstopped_blood(self, last_unsure_penetration_pos, reason, trace)
	scrape_blood(self, trace, len, len_before)
end

local function postricochet_blood(self, new_vel_normal, len, ricochet, ang_diff, len_before, trace)
	scrape_blood(self, trace, len, len_before)
end

local function postpenetration_blood(self, new_vel_normal, len, ricochet, ang_diff, len_before, trace)
	scrape_blood(self, trace, len, len_before)
end


local function onstopped_silk(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local normal = self.Vel:GetNormalized()
			local projectile = ents.Create(self.FunctionInfo.Ent)
			projectile:SetPos(self.Pos)
			projectile:SetAngles(normal:Angle())
			projectile:Spawn()
			self.SpawnedEntity = projectile

			if(trace)then
				projectile:Hit(trace.Entity, trace.HitPos - normal * 10, trace.PhysicsBone, normal)
			end
		end
	end
end

local function arrow_hit(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local normal = -self.Vel:GetNormalized()
			local projectile = ents.Create(self.FunctionInfo.Ent)
			projectile:SetPos(self.Pos)
			projectile:SetAngles(normal:Angle())
			projectile:Spawn()
			self.SpawnedEntity = projectile
			
			if(trace)then
				projectile:Hit(trace.Entity, trace.HitPos + normal * -4, trace.PhysicsBone, normal)
			end
		end
	end
end

--=\\Scheduled explosions
APScheduledExplosions = APScheduledExplosions or {}

hook.Add("Think", "APScheduledExplosions", function()	--; AimPoint Mr.Point
	for id, coroutine_example in pairs(APScheduledExplosions) do
		if(!coroutine.resume(coroutine_example))then
			APScheduledExplosions[id] = nil
		end
	end
end)
--=//

--=\\Explosive Projectile
local function draw_explosive(self)
	if(IsValid(self.Draw_Model))then
		--
	else
		local model_ent = ClientsideModel(self.FunctionInfo.Model)
		self.Draw_Model = model_ent
	end
	
	local model_ent = self.Draw_Model
	local vel_ang = self.Vel:Angle()
	
	model_ent:SetPos(self.Pos)
	model_ent:SetAngles(vel_ang)
end

local function preremove_explosive(self)
	if(IsValid(self.Draw_Model))then
		self.Draw_Model:Remove()
	end
end

local function onstopped_explosive(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local attacker = self.Shooter
			local pos = self.Pos - self.Vel:GetNormalized() * 2
			local vec_cone = Vector(0, 0, 0)
			local shrapnel_coroutine_id = #APScheduledExplosions + 1
			
			util.ScreenShake(self.Pos, 35, 1, 1, 3000)

			net.Start("projectileFarSound")
				net.WriteString("m67/m67_detonate_01.wav")
				net.WriteString("m67/m67_detonate_far_dist_03.wav")
				net.WriteVector(pos)
				net.WriteEntity(Entity(0))
				net.WriteBool(false)
				net.WriteString("")
			net.Broadcast()
			
			hg.BlastDamageWithShockwave(Entity(0), IsValid(attacker) and attacker or Entity(0), self.Pos, 100, 50, { ExplosionType = "Small" })
			hg.ExplosionEffect(self.Pos, 1500 / 0.01905, 250)

			--local effectdata = EffectData()
			--effectdata:SetOrigin(selfPos)
			--effectdata:SetScale(0.9)
			--util.Effect("eff_jack_fragsplosion", effectdata)
	
			timer.Simple(.15,function()
				local coroutine_antilag = coroutine.create(function()
					local last_shrapnel = SysTime()

					for i = 1, 600 do
						last_shrapnel = SysTime()
						local dir = VectorRand(-1, 1)
						
						dir:Normalize()
						
						dir[3] = dir[3] > 0 and math.abs(dir[3] - 0.5) or -math.abs(dir[3] + 0.5)
						
						dir:Normalize()
						
						local bullet = {}
						bullet.Src = pos
						bullet.Spread = vec_cone
						bullet.Force = 4
						bullet.Damage = 40
						bullet.AmmoType = "Metal Debris"
						bullet.Attacker = game.GetWorld()
						bullet.Inflictor = attacker
						bullet.Distance = 567
						bullet.DisableLagComp = true
						bullet.Dir = dir
						
						game.GetWorld():FireLuaBullets(bullet, true)

						last_shrapnel = SysTime() - last_shrapnel

						if(last_shrapnel > 0.001)then
							coroutine.yield()
						end
					end
					
					APScheduledExplosions[shrapnel_coroutine_id] = nil
				end)

				APScheduledExplosions[shrapnel_coroutine_id] = coroutine_antilag
				
				coroutine.resume(coroutine_antilag)
			end)
			util.ScreenShake( self.Pos, 35, 1, 1, 1000, true )
		end
	end
end
