local MODE = MODE

MODE.name = "active_shooter"
MODE.PrintName = "Active Shooter"
MODE.Description = "Victims have one minute to hide before the armed shooter is released. Survive until SWAT arrives."
MODE.ROUND_TIME = 420
MODE.Chance = 0.009
MODE.ForBigMaps = false
MODE.randomSpawns = true
MODE.LootSpawn = true

MODE.start_time = 1
MODE.shouldfreeze = true
MODE.hideTime = 60
MODE.swatTime = 180

MODE.LootTable = {
	{95, {
		{8, "weapon_bandage_sh"},
		{5, "weapon_bigbandage_sh"},
		{4, "weapon_tourniquet"},
		{3, "weapon_painkillers_tpik"},
		{2, "weapon_medkit_sh"},
		{5, "weapon_ducttape"},
		{5, "weapon_hg_bottle"},
		{4, "weapon_hammer"},
		{4, "weapon_bat"},
		{3, "weapon_brick"},
		{3, "weapon_pocketknife"},
		{2, "weapon_leadpipe"},
		{1, "ent_armor_vest1"},
		{1, "ent_armor_helmet3"},
	}},
	{5, {
		{5, "weapon_pm"},
		{4, "weapon_glock17"},
		{3, "weapon_cz75"},
		{1, "weapon_mr43_short"},
		{0.5, "weapon_skorpion"},
		{0.15, "weapon_m4a1"},
	}},
}

function MODE:CanLaunch()
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			count = count + 1
		end
	end

	return count >= 2
end

function MODE:SetupChances()
	local savedChance = tonumber(zb.ModesChances[self.name])

	if savedChance == 0.02 or savedChance == 0.005 then
		savedChance = MODE.Chance
	end

	zb.ModesChances[self.name] = savedChance or MODE.Chance
end
