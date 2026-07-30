include("shared.lua")

ENT.began_particles = false

ENT.particle_list = {
	"ins_thermite_burst", 
	"ins_thermite_burst_glow", 
	"ins_thermite_flame_c", 
	"ins_thermite_flame", 
	"ins_thermite_flame_b", 
	"ins_thermite_flame_e", 
	"ins_thermite_flame_sparks", 
	"ins_thermite_smoke_b", 
	"ins_thermite_sparks_b", 
	"ins_thermite_sparks_bouncing", 
	"ins_thermite_sparks_bouncing_c",
	"molotov_glow",
	"molotov_trail"
}

ENT.active_particles = {}

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	if self:GetNW2Bool("FireEffect") and !self:GetNW2Bool("Extinguished") and !self.began_particles then
		self.began_particles = true

		self.active_particles.flame = CreateParticleSystem( self, "vFire_Flames_Small", PATTACH_ABSORIGIN_FOLLOW, 1 )

		for _, v in pairs(self.particle_list) do
			local effect = CreateParticleSystem( self, v, PATTACH_ABSORIGIN_FOLLOW, 1 )
			self.active_particles[v] = effect
		end
	elseif self.began_particles and self:GetNW2Bool("Extinguished") then
		for i, v in pairs(self.active_particles) do
			if not IsValid(v) then continue end
			v:StopEmission()
			self.active_particles[i] = nil
		end

		self.began_particles = false
	end
end

function ENT:Initialize()
	self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>Grenade\n<colour=200,0,0>RUN IDIOT!</colour></font>",450)
end