local MODE = MODE

MODE.name = "superfighters"
MODE.PrintName = "Superfighters 3D"
MODE.LootSpawn = true
MODE.GuiltDisabled = true
MODE.randomSpawns = true
MODE.noBoxes = true

MODE.GuiltDisabled = true
MODE.ForBigMaps = false
MODE.Chance = 0.04

local radius = nil
local mapsize = 7500
-- MODE.MapSize = mapsize

util.AddNetworkString("supfight_start")
util.AddNetworkString("supfight_end")

function MODE:CanLaunch()
    return true//(zb.GetWorldSize() >= ZBATTLE_BIGMAP)
end

function MODE:Intermission()
	game.CleanUpMap()

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then
			continue
		end
		
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end

	local rndpoints = zb.GetMapPoints("RandomSpawns")
	zonepoint = table.Random(rndpoints)

	net.Start("supfight_start")
		net.WriteVector(zonepoint.pos)
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
	}
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end
		AlivePlyTbl[#AlivePlyTbl + 1] = ply
	end
	return AlivePlyTbl
end

function MODE:ShouldRoundEnd()
	return (#zb:CheckAlive(true) <= 1)
end

function MODE:RoundStart()
	for _, ply in player.Iterator() do
		if not ply:Alive() then continue end
		ply:SetSuppressPickupNotices(true)
		ply.noSound = true
		local hands = ply:Give("weapon_hands_sh")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)

		ply:Give("weapon_walkie_talkie")

		ply:SelectWeapon("weapon_hands_sh")

		if ply.organism then
			ply.organism.recoilmul = 0.25
			ply.organism.superfighter = true
		end

		timer.Simple(0.1,function()
			ply.noSound = false
		end)

		ply:SetSuppressPickupNotices(false)
		zb.GiveRole(ply, "Superfighter", Color(190,15,15))
	end
end

function MODE:GiveWeapons()
end

function MODE:GiveEquipment()
end

MODE.LootTable = {
	{34, {
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_crowbar"},
		{2,"weapon_tomahawk"},
		{2,"weapon_hatchet"},
		{1,"weapon_hg_axe"},
		{1,"weapon_hg_crossbow"},
	}},
	{46, {
		{9,"*ammo*"},
		{8,"weapon_hk_usp"},
		{7,"weapon_revolver357"},
		{7,"weapon_deagle"},
		{7,"weapon_doublebarrel_short"},
		{7,"weapon_doublebarrel"},
		{6,"weapon_m590a1"},
		{5,"weapon_saiga12"},
		{4,"weapon_aa12"},
		{4,"weapon_mp7"},
		{4,"weapon_sks"},

		{6,"ent_armor_vest3"},
		{5,"ent_armor_helmet1"},
		{5,"ent_armor_vest4"},
		{4,"ent_armor_vest5"},

		{5,"weapon_hg_molotov_tpik"},
		{5,"weapon_hg_pipebomb_tpik"},
		{4,"weapon_claymore"},
		{4,"weapon_hg_f1_tpik"},
		{3,"weapon_traitor_ied"},
		{3,"weapon_hg_slam"},
		{3,"weapon_hg_legacy_grenade_shg"},
		{3,"weapon_hg_grenade_tpik"},

		{3,"weapon_akm"},
		{3,"weapon_m98b"},
		{3,"weapon_sr25"},
		{2,"weapon_ptrd"},
		{2,"weapon_hg_rpg"},
	}},
}

hg.AppendLootPool(MODE.LootTable[1][2], hg.LootPools.MeleeCommon, 1)
hg.AppendLootPool(MODE.LootTable[1][2], hg.LootPools.MeleeRare, 0.7)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.Sidearms, 0.6)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.SMGs, 0.4)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.Shotguns, 0.4)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.AssaultRifles, 0.3)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.Marksman, 0.25)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.LMG, 0.2)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.ArmorMedium, 0.5)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.ArmorHeavy, 0.4)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.Explosives, 0.5)

function MODE:RoundThink()
	if (self.nextBoxesThink or 0) < CurTime() then
		self.nextBoxesThink = CurTime() + 2

		hook.Run("Boxes Think")
	end
end

function MODE:PlayerDeath(ply)
end

function MODE:CanSpawn()
end

function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("supfight_end")
		local ent = zb:CheckAlive(true)[1]
		net.WriteEntity(IsValid(ent) and ent:Alive() and ent or NULL)
		net.Broadcast()
	end)
end