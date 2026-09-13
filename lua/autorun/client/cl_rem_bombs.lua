local particleFiles = {
	"particles/doi_explosion_fx.pcf",
	"particles/gb5_1000lb.pcf",
	"particles/gb5_500lb.pcf",
	"particles/gb5_large_explosion.pcf",
	"particles/gb5_high_explosive.pcf",
	"particles/explosion_fx_ins.pcf",
	"particles/gb_water.pcf"
}
for i = 1, #particleFiles do
	game.AddParticles(particleFiles[i])
end
local particleSystems = {
	"doi_stuka_explosion",
	"1000lb_explosion",
	"ins_water_explosion"
}
for i = 1, #particleSystems do
	PrecacheParticleSystem(particleSystems[i])
end
