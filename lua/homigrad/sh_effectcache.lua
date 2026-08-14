local game, PrecacheParticleSystem = game, PrecacheParticleSystem
local AddParticles = game.AddParticles

local function AddParticlesIfExists(path)
	if file.Exists(path, "GAME") then
		AddParticles(path)
	end
end

local function PrecacheIfExists(system, paths)
	for i = 1, #paths do
		if file.Exists(paths[i], "GAME") then
			PrecacheParticleSystem(system)
			return
		end
	end
end

-- PewPaws!!!
AddParticlesIfExists("particles/muzzleflashes_test.pcf")
AddParticlesIfExists("particles/muzzleflashes_test_b.pcf")
AddParticlesIfExists("particles/pcfs_jack_muzzleflashes.pcf")
AddParticlesIfExists("particles/ar2_muzzle.pcf")
AddParticlesIfExists( "particles/nmrih_extinguisher.pcf" )

local muzzleTestPcf = { "particles/muzzleflashes_test.pcf", "particles/muzzleflashes_test_b.pcf" }
local jackMuzzlePcf = { "particles/pcfs_jack_muzzleflashes.pcf" }
local ar2Pcf = { "particles/ar2_muzzle.pcf" }
local nmrihPcf = { "particles/nmrih_extinguisher.pcf" }

local toPrecache = {
	{ "muzzleflash_SR25", muzzleTestPcf },
	{ "pcf_jack_mf_tpistol", jackMuzzlePcf },
	{ "pcf_jack_mf_mshotgun", jackMuzzlePcf },
	{ "pcf_jack_mf_msmg", jackMuzzlePcf },
	{ "pcf_jack_mf_spistol", jackMuzzlePcf },
	{ "pcf_jack_mf_mrifle2", jackMuzzlePcf },
	{ "pcf_jack_mf_mrifle1", jackMuzzlePcf },
	{ "pcf_jack_mf_mpistol", jackMuzzlePcf },
	{ "pcf_jack_mf_suppressed", jackMuzzlePcf },
	{ "muzzleflash_pistol_rbull", muzzleTestPcf },
	{ "muzzleflash_m24", muzzleTestPcf },
	{ "muzzleflash_m79", muzzleTestPcf },
	{ "muzzleflash_M3", muzzleTestPcf },
	{ "muzzleflash_m14", muzzleTestPcf },
	{ "muzzleflash_g3", muzzleTestPcf },
	{ "muzzleflash_FAMAS", muzzleTestPcf },
	{ "pcf_jack_mf_mrifle1", jackMuzzlePcf },
	{ "muzzleflash_ak47", muzzleTestPcf },
	{ "muzzleflash_mp5", muzzleTestPcf },
	{ "muzzleflash_suppressed", muzzleTestPcf },
	{ "muzzleflash_MINIMI", muzzleTestPcf },
	{ "muzzleflash_svd", muzzleTestPcf },
	{ "new_ar2_muzzle", ar2Pcf },
	{ "NMRIH_EXTINGUISHER", nmrihPcf },
	{ "btm_muzzleflash", muzzleTestPcf }
}

for k, v in ipairs(toPrecache) do
	PrecacheIfExists(v[1], v[2])
end

-- CAAABOOOOMS!
AddParticlesIfExists("particles/pcfs_jack_explosions_large.pcf")
AddParticlesIfExists("particles/pcfs_jack_explosions_medium.pcf")
AddParticlesIfExists("particles/pcfs_jack_explosions_small.pcf")
AddParticlesIfExists("particles/pcfs_jack_nuclear_explosions.pcf")
AddParticlesIfExists("particles/pcfs_jack_moab.pcf")
AddParticlesIfExists("particles/gb5_large_explosion.pcf")
AddParticlesIfExists("particles/gb5_500lb.pcf")
AddParticlesIfExists("particles/gb5_100lb.pcf")
AddParticlesIfExists("particles/gb5_50lb.pcf")
AddParticlesIfExists("particles/pcfs_jack_muzzleflashes.pcf")
AddParticlesIfExists("particles/pcfs_jack_explosions_incendiary2.pcf")
AddParticlesIfExists("particles/lighter.pcf")
AddParticlesIfExists("particles/pfx_redux.pcf")

PrecacheIfExists("[2]sparkle1", { "particles/pfx_redux.pcf" })
PrecacheIfExists("Lighter_flame", { "particles/lighter.pcf" })
PrecacheIfExists("pcf_jack_nuke_ground", { "particles/pcfs_jack_nuclear_explosions.pcf" })
PrecacheIfExists("pcf_jack_nuke_air", { "particles/pcfs_jack_nuclear_explosions.pcf" })
PrecacheIfExists("pcf_jack_moab", { "particles/pcfs_jack_moab.pcf" })
PrecacheIfExists("pcf_jack_moab_air", { "particles/pcfs_jack_moab.pcf" })
PrecacheIfExists("cloudmaker_air", { "particles/pcfs_jack_moab.pcf", "particles/gb5_large_explosion.pcf", "particles/pfx_redux.pcf" })
PrecacheIfExists("cloudmaker_ground", { "particles/pcfs_jack_moab.pcf", "particles/gb5_large_explosion.pcf", "particles/pfx_redux.pcf" })
PrecacheIfExists("500lb_air", { "particles/gb5_500lb.pcf" })
PrecacheIfExists("500lb_ground", { "particles/gb5_500lb.pcf" })
PrecacheIfExists("100lb_air", { "particles/gb5_100lb.pcf" })
PrecacheIfExists("100lb_ground", { "particles/gb5_100lb.pcf" })
PrecacheIfExists("50lb_air", { "particles/gb5_50lb.pcf" })
PrecacheIfExists("50lb_ground", { "particles/gb5_50lb.pcf" })
PrecacheIfExists("pcf_jack_incendiary_ground_sm2", { "particles/pcfs_jack_explosions_incendiary2.pcf" })
PrecacheIfExists("pcf_jack_groundsplode_small3", { "particles/pcfs_jack_explosions_small3.pcf", "particles/pcfs_jack_explosions_small.pcf" })
PrecacheIfExists("pcf_jack_smokebomb3", { "particles/pcfs_jack_explosions_small3.pcf", "particles/pcfs_jack_explosions_small.pcf" })
PrecacheIfExists("pcf_jack_groundsplode_medium", { "particles/pcfs_jack_explosions_medium.pcf" })
PrecacheIfExists("pcf_jack_groundsplode_large", { "particles/pcfs_jack_explosions_large.pcf" })
PrecacheIfExists("pcf_jack_airsplode_medium", { "particles/pcfs_jack_explosions_medium.pcf" })
PrecacheIfExists("pcf_jack_airsplode_large", { "particles/pcfs_jack_explosions_large.pcf" })

-- Impacts
AddParticlesIfExists("particles/impact_fx.pcf")
AddParticlesIfExists("particles/water_impact.pcf")

PrecacheIfExists("impact_concrete", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_metal", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_computer", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_grass", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_dirt", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_wood", { "particles/impact_fx.pcf" })
PrecacheIfExists("impact_glass", { "particles/impact_fx.pcf" })

--// Fix for homigrad content breaking impact decals (bruh)
if CLIENT then
	RunConsoleCommand("cl_new_impact_effects", "1")
end
