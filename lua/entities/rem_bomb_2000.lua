AddCSLuaFile()
DEFINE_BASECLASS("rem_bomb_base")
ENT.Base = "rem_bomb_base"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.PrintName = "Rem 2000Lb"
ENT.Author = "Remorse"
ENT.Category = "ZCity Other"
ENT.Model = "models/gbombs/an_m66.mdl"
ENT.Effect = "1000lb_explosion"
ENT.EffectAir = "1000lb_explosion"
ENT.EffectWater = "ins_water_explosion"
ENT.ExplosionSound = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"}
ENT.FarExplosionSound = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"}
ENT.WaterSound = "iedins/water/ied_water_detonate_01.wav"
ENT.WaterFarSound = "iedins/water/ied_water_detonate_01.wav"
ENT.ExplosionDamage = 600
ENT.ExplosionRadius = 1800
ENT.TraceLength = 600
ENT.ImpactSpeed = 200
ENT.Mass = 1000
ENT.Life = 50
ENT.ArmDelay = 0.1
ENT.Decal = "scorch_big"
ENT.PhysForce = 90000
ENT.PhysLift = 35000
function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	if IsValid(ply) and not ply:IsAdmin() then return end
	self.GBOWNER = ply
	local ent = ents.Create("rem_bomb_2000")
	if not IsValid(ent) then return end
	ent.GBOWNER = ply
	ent:SetPos(tr.HitPos + tr.HitNormal * 16)
	ent:SetAngles(Angle(0, 90, 0))
	ent:Spawn()
	ent:Activate()
	if IsValid(ply) then
		ent:SetPhysicsAttacker(ply)
	end
	return ent
end
