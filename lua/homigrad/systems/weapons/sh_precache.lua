function hg.PrecacheSoundsSWEP(self)
	if self.HolsterSnd and self.HolsterSnd[1] then util.PrecacheSound(self.HolsterSnd[1]) end
	if self.DeploySnd and self.DeploySnd[1] then util.PrecacheSound(self.DeploySnd[1]) end
	if self.Primary.Sound and self.Primary.Sound[1] then util.PrecacheSound(self.Primary.Sound[1]) end
	if self.DistSound then util.PrecacheSound(self.DistSound) end
	if self.SupressedSound and self.SupressedSound[1] then util.PrecacheSound(self.SupressedSound[1]) end
	if self.CockSound then util.PrecacheSound(self.CockSound) end
	if self.ReloadSound then util.PrecacheSound(self.ReloadSound) end
end

local function AddParticlesIfExists(path)
	if file.Exists(path, "GAME") then
		game.AddParticles(path)
	end
end

local function PrecacheIfExists(path, system)
	if file.Exists(path, "GAME") then
		PrecacheParticleSystem(system)
	end
end

AddParticlesIfExists("particles/gf2_trails_firework_rocket_01.pcf")
PrecacheIfExists("particles/gf2_trails_firework_rocket_01.pcf", "gf2_firework_trail_main")

AddParticlesIfExists("particles/gf2_large_rocket_01.pcf")
AddParticlesIfExists("particles/gf2_large_rocket_02.pcf")
AddParticlesIfExists("particles/gf2_large_rocket_03.pcf")
AddParticlesIfExists("particles/gf2_large_rocket_04.pcf")
AddParticlesIfExists("particles/gf2_large_rocket_05.pcf")
AddParticlesIfExists("particles/gf2_large_rocket_06.pcf")

PrecacheIfExists("particles/gf2_large_rocket_01.pcf", "gf2_rocket_large_explosion_01")
PrecacheIfExists("particles/gf2_large_rocket_02.pcf", "gf2_rocket_large_explosion_02")
PrecacheIfExists("particles/gf2_large_rocket_03.pcf", "gf2_rocket_large_explosion_03")
PrecacheIfExists("particles/gf2_large_rocket_04.pcf", "gf2_rocket_large_explosion_04")
PrecacheIfExists("particles/gf2_large_rocket_05.pcf", "gf2_rocket_large_explosion_05")
PrecacheIfExists("particles/gf2_large_rocket_06.pcf", "gf2_rocket_large_explosion_06")

AddParticlesIfExists("particles/gf2_battery_generals.pcf")
AddParticlesIfExists("particles/gf2_battery_01_effects.pcf")
AddParticlesIfExists("particles/gf2_battery_02_effects.pcf")
AddParticlesIfExists("particles/gf2_battery_03_effects.pcf")
AddParticlesIfExists("particles/gf2_battery_mine_01_effects.pcf")

AddParticlesIfExists("particles/gf2_cake_01_effects.pcf")

AddParticlesIfExists("particles/gf2_firecracker_m80.pcf")

AddParticlesIfExists("particles/gf2_misc_neighborhater.pcf")
AddParticlesIfExists("particles/gf2_matchhead_light.pcf")

AddParticlesIfExists("particles/gf2_fountain_01_effects.pcf")
AddParticlesIfExists("particles/gf2_fountain_02_effects.pcf")
AddParticlesIfExists("particles/gf2_fountain_03_effects.pcf")
AddParticlesIfExists("particles/gf2_fountain_04_effects.pcf")
AddParticlesIfExists("particles/gf2_fountain_05_effects.pcf")

AddParticlesIfExists("particles/gf2_mortar_shells_effects.pcf")
AddParticlesIfExists("particles/gf2_mortar_shells_big_01.pcf")
AddParticlesIfExists("particles/gf2_mortar_shells_big_02.pcf")
AddParticlesIfExists("particles/gf2_mortar_shells_big_03.pcf")

AddParticlesIfExists("particles/gf2_wheel_01.pcf")

AddParticlesIfExists("particles/gf2_flare_multicoloured_effects.pcf")

AddParticlesIfExists("particles/gf2_gigantic_rocket_01.pcf")
AddParticlesIfExists("particles/gf2_gigantic_rocket_02.pcf")

AddParticlesIfExists("particles/gf2_romancandle_01_effect.pcf")
AddParticlesIfExists("particles/gf2_romancandle_02_effect.pcf")
AddParticlesIfExists("particles/gf2_romancandle_03_effect.pcf")

AddParticlesIfExists("particles/gf2_firework_small_01.pcf")
