MODE.name = "criresp"
MODE.PrintName = "Crisis Response"
MODE.end_time = 15

MODE.ForBigMaps = false
MODE.ROUND_TIME = 480

MODE.Chance = 0.05

function MODE:OverrideBalance()
	return true
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function shuffle(tbl)
	local len = #tbl
	for i = len, 2, -1 do
	  local j = math.random(i)
	  tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

function MODE:AssignTeams()
	local players = {}
	for _, ply in player.Iterator() do
		if ply:Team() ~= TEAM_SPECTATOR then
			players[#players + 1] = ply
		end
	end
	local numPlayers = #players
	local numSWAT = 1

	if numPlayers <= 4 then
		numSWAT = 1
	elseif numPlayers == 5 then
		numSWAT = 2
	elseif numPlayers == 6 then
		numSWAT = 2
	elseif numPlayers == 7 then
		numSWAT = 3
	elseif numPlayers >= 8 then -- возвращение великой elseif таблицы
		numSWAT = 4
	end

	shuffle(players)

	for i = 1, numSWAT do
		if IsValid(players[i]) then 
			players[i]:SetTeam(0)
		end
	end

	for i = numSWAT + 1, numPlayers do
		if IsValid(players[i]) then 
			players[i]:SetTeam(1)
		end
	end
end

util.AddNetworkString("criresp_start")
function MODE:Intermission()
	game.CleanUpMap()
    
    self:AssignTeams()

	self.submode = math.random(2) == 1 and "sobr" or "us"
	self.swatDeployed = false
	self.preparationActive = true
	self.preparationTime = self.submode == "us" and 60 or 30
	
	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if ply:Team() == 0 then
			ply:KillSilent()
			continue
		end

		ply.crirespDeploying = true
		ply:Spawn()
		ply.crirespDeploying = nil
		ply:SetupTeam(1)
	end

	net.Start("criresp_start")
	net.WriteString(self.submode)
	net.WriteUInt(self.preparationTime, 7)
	net.Broadcast()

end

function MODE:CheckAlivePlayers()
	local swatPlayers = {}
	local banditPlayers = {}

	for _, ply in ipairs(team.GetPlayers(0)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(swatPlayers, ply)
		end
	end

	for _, ply in ipairs(team.GetPlayers(1)) do
		if ply:Alive() and not ply:GetNetVar("handcuffed", false) then
			table.insert(banditPlayers, ply)
		end
	end

	return {[0] = swatPlayers, [1] = banditPlayers}
end





function MODE:ShouldRoundEnd()
	if not self.swatDeployed then return end
	local aliveTeams = self:CheckAlivePlayers()
	local endround, winner = zb:CheckWinner(aliveTeams)
	return endround
end



function MODE:RoundStart()
    
end

local SWAT_PRESETS = {
	sobr = {
		{ name = "Light Medic",
			primary = "weapon_pp1901", atts = {"holo2", "supressor1"},
			secondary = "weapon_pl15",
			armor = {"ent_armor_vest_sobr3", "ent_armor_helmet_sobr3"},
			items = {"weapon_medkit_sh", "weapon_morphine", "weapon_adrenaline", "weapon_bigbandage_sh", "weapon_bandage_sh", "weapon_tourniquet"} },
		{ name = "Breacher",
			primary = "weapon_sr2", atts = {"holo7", "supressor1"},
			secondary = "weapon_pl15",
			armor = {"ent_armor_vest_sobr2", "ent_armor_helmet_sobr2", "ent_armor_visor_sobr2"},
			items = {"weapon_ram", "weapon_hg_smokenade", "weapon_hg_eft_zarya"},
			nodrop = {"weapon_ram"} },
		{ name = "Heavy",
			primary = "weapon_akz", atts = {"muzzle_545_recoil_2", "holo12", "stock_ak_evo"},
			secondary = "weapon_pl15",
			armor = {"ent_armor_vest_sobr1", "ent_armor_helmet_sobr2"},
			items = {"weapon_hg_eft_zarya", "weapon_hg_eft_rgd5"} },
		{ name = "Shield",
			primary = "weapon_ballistic_shield",
			secondary = "weapon_pl15",
			armor = {"ent_armor_vest_sobr1", "ent_armor_helmet_sobr1", "ent_armor_visor_sobr1"},
			items = {} },
	},
	us = {
		{ name = "Light Medic",
			primary = "weapon_mp5sd", atts = {"holo14"},
			secondary = "weapon_glock17",
			armor = {"ent_armor_vest8", "ent_armor_helmet10"},
			items = {"weapon_medkit_sh", "weapon_morphine", "weapon_adrenaline", "weapon_bigbandage_sh", "weapon_bandage_sh", "weapon_tourniquet"} },
		{ name = "Breacher",
			primary = "weapon_tx15", atts = {"holo8", "muzzle_556_recoil_1", "grip6"},
			secondary = "weapon_glock17",
			armor = {"ent_armor_vest12", "ent_armor_helmet15", "ent_armor_visor_caiman", "ent_armor_mandible_caiman"},
			items = {"weapon_ram", "weapon_hg_smokenade", "weapon_hg_eft_m67"},
			nodrop = {"weapon_ram"} },
		{ name = "Heavy",
			primary = "weapon_m4a1", atts = {"optic14", "stock_ar15_dd_enhanced", "supressor5"},
			secondary = "weapon_glock17",
			armor = {"ent_armor_helmet13", "ent_armor_vest11"},
			items = {"weapon_hg_eft_m67", "weapon_hg_eft_m7920"} },
		{ name = "Shield",
			primary = "weapon_ballistic_shield",
			secondary = "weapon_glock18c",
			armor = {"ent_armor_vest17", "ent_armor_helmet13", "ent_armor_visor_exfil_black", "ent_armor_earcovers_exfil_black"},
			items = {},
			noheadphones = true },
	},
}

local CRIM_PRESETS = {
	sobr = {
		{ name = "Medic",
			armor = {"ent_armor_vest5", "ent_armor_mask5"},
			items = {"weapon_medkit_sh", "weapon_morphine", "weapon_adrenaline", "weapon_bigbandage_sh", "weapon_bandage_sh", "weapon_tourniquet"} },
		{ name = "Medium",
			armor = {"ent_armor_vest9"},
			items = {} },
		{ name = "Heavy",
			primary = "weapon_akm", atts = {"mag6"}, nostock = true,
			armor = {"ent_armor_helmet29", "ent_armor_visor_maska", "ent_armor_vest10"},
			items = {"weapon_hg_pipebomb_tpik"} },
	},
	us = {
		{ name = "Medic",
			armor = {"ent_armor_vest2", "ent_armor_helmet20", "ent_armor_mask5"},
			items = {"weapon_medkit_sh", "weapon_morphine", "weapon_adrenaline", "weapon_bigbandage_sh", "weapon_bandage_sh", "weapon_tourniquet"} },
		{ name = "Standard",
			armor = {"ent_armor_vest26"},
			items = {} },
		{ name = "Heavy",
			primary = "weapon_m3super",
			armor = {"ent_armor_mask5", "ent_armor_vest26"},
			items = {"weapon_hg_type59_tpik"} },
	},
}

local CRIM_RANDOM_PRIMARIES_SOBR = {
	"weapon_ak74", "weapon_vpo136", "weapon_vpo209", "weapon_svt",
	"weapon_toz106", "weapon_m590a1", "weapon_mp5", "weapon_mp5k",
	"weapon_mp9", "weapon_uzi", "weapon_p90", "weapon_skorpion"
}

local CRIM_RANDOM_SECONDARIES_SOBR = {
	"weapon_pb", "weapon_zoraki", "weapon_p22", "weapon_px4beretta",
	"weapon_revolver2", "weapon_revolver357", "weapon_glock17"
}

local CRIM_RANDOM_PRIMARIES_US = {
	"weapon_adar215", "weapon_vpo101", "weapon_sks", "weapon_stm9",
	"weapon_vpo136", "weapon_m590a1", "weapon_870", "weapon_kedr",
	"weapon_uzi", "weapon_mp5k", "weapon_mp9"
}

local CRIM_RANDOM_SECONDARIES_US = {
	"weapon_glock17", "weapon_glock18c", "weapon_glock26",
	"weapon_m9beretta", "weapon_colt9mm"
}

local CRIM_SHARED_ITEMS = {
	"weapon_combatknife", "weapon_bandage_sh", "weapon_painkillers_tpik", "weapon_ducttape"
}

local function ShuffleIndexes(count)
	local t = {}
	for i = 1, count do t[i] = i end
	shuffle(t)
	return t
end

function MODE:GiveWeaponWithAmmo(ply, class, ammoMul, attachments)
	local gun = ply:Give(class)
	if IsValid(gun) and gun.GetMaxClip1 then
		if attachments and #attachments > 0 then
			hg.AddAttachmentForce(ply, gun, attachments)
		end
		ply:GiveAmmo(gun:GetMaxClip1() * ammoMul, gun:GetPrimaryAmmoType(), true)
	end
	return gun
end

function MODE:CanLaunch()
	local points = zb.GetMapPoints( "HMCD_CRI_CT" )
	local points2 = zb.GetMapPoints( "HMCD_CRI_T" )
	local plramount = zb:CheckPlaying()
    return (#points > 3) and (#points2 > 0) and (#plramount > 5)
end

function MODE:GiveEquipment()
	timer.Simple(0.5,function()
		local submode = self.submode or "sobr"
		local swatPresets = SWAT_PRESETS[submode]
		local swatIdx = ShuffleIndexes(#swatPresets)
		local swatCount = 0
		local crimPresets = CRIM_PRESETS[submode]
		local crimIdx = ShuffleIndexes(#crimPresets)
		local crimCount = 0
		local randPrimaries = submode == "us" and CRIM_RANDOM_PRIMARIES_US or CRIM_RANDOM_PRIMARIES_SOBR
		local randSecondaries = submode == "us" and CRIM_RANDOM_SECONDARIES_US or CRIM_RANDOM_SECONDARIES_SOBR

		for i, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end

			if ply:Team() == 0 then
				local preset = swatPresets[swatIdx[(swatCount % #swatIdx) + 1]]
				swatCount = swatCount + 1

				if !IsValid(ply) or ply:Team() == TEAM_SPECTATOR then continue end
				local timerName = "SWATSpawn" .. ply:EntIndex()
				local preparationTime = self.preparationTime or (submode == "us" and 60 or 30)
				timer.Create(timerName, preparationTime, 1, function()
					if not IsValid(ply) or CurrentRound() ~= self or self.submode ~= submode or ply:Team() ~= 0 then return end

					ply.crirespDeploying = true
					ply:Spawn()
					ply.crirespDeploying = nil
					ply:SetSuppressPickupNotices(true)
					ply.noSound = true
					ply:SetupTeam(0)
					ply:SetPlayerClass("swat")

					local inv = ply:GetNetVar("Inventory", {})
					inv["Weapons"] = inv["Weapons"] or {}
					inv["Weapons"]["hg_sling"] = true
					ply:SetNetVar("Inventory", inv)

					hg.AddArmor(ply, preset.armor)
					if not preset.noheadphones then
						hg.AddArmor(ply, "headphones1")
					end

					zb.GiveRole(ply, submode == "sobr" and "SOBR" or "US Special Forces", submode == "sobr" and Color(0,0,190) or Color(0,90,190))

					if preset.primary then
						self:GiveWeaponWithAmmo(ply, preset.primary, 3, preset.atts)
					end

					if preset.secondary then
						self:GiveWeaponWithAmmo(ply, preset.secondary, 2)
					end

					for _, item in ipairs(preset.items) do
						local w = ply:Give(item)
						if preset.nodrop and table.HasValue(preset.nodrop, item) and IsValid(w) then
							w.NoDrop = true
							w.bigNoDrop = true
						end
					end

					if submode == "us" and not ply:HasWeapon("weapon_medkit_sh") then
						ply:Give("weapon_medkit_sh")
					end

					ply:Give("weapon_hands_sh")
					ply:SetSuppressPickupNotices(false)
					ply.noSound = false
					self.swatDeployed = true
					self.preparationActive = false
				end)
			else
				local preset = crimPresets[crimIdx[(crimCount % #crimIdx) + 1]]
				crimCount = crimCount + 1

				local roleName, roleColor = "Chechen Terrorist", Color(190,0,0)
				if submode == "us" then
					roleName, roleColor = "Armed Robber", Color(190,80,0)
				end

				ply:SetSuppressPickupNotices(true)
				ply.noSound = true

				ply:SetPlayerClass("terrorist")

				zb.GiveRole(ply, roleName, roleColor)

				if preset.primary then
					local gun = self:GiveWeaponWithAmmo(ply, preset.primary, 3, preset.atts)
					if preset.nostock and IsValid(gun) then
						gun.attachments = gun.attachments or {}
						gun.attachments.stock = {}
						if gun.UpdateAttachmentModifiers then
							gun:UpdateAttachmentModifiers()
						end
					end
				else
					self:GiveWeaponWithAmmo(ply, randPrimaries[math.random(#randPrimaries)], 3)
					self:GiveWeaponWithAmmo(ply, randSecondaries[math.random(#randSecondaries)], 2)
				end

				if preset.armor then
					hg.AddArmor(ply, preset.armor)
				end

				for _, item in ipairs(CRIM_SHARED_ITEMS) do
					ply:Give(item)
				end

				for _, item in ipairs(preset.items) do
					ply:Give(item)
				end

				local hands = ply:Give("weapon_hands_sh")

				ply:SetSuppressPickupNotices(false)
				ply.noSound = false
			end

			timer.Simple(0.5,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:RoundThink()
end

function MODE:GetTeamSpawn()
	return {zb:GetRandomSpawn()}, {zb:GetRandomSpawn()}
end

function MODE:CanSpawn()
end

util.AddNetworkString("cri_roundend")
function MODE:EndRound()
	self.preparationActive = false
	self.swatDeployed = false

	if zb.SKIP_END_PRESENTATION then
		zb.SKIP_END_PRESENTATION = false
		zb.SHOULD_FADE = true
		zb.END_TIME = nil
	end

	for k,ply in player.Iterator() do
		if timer.Exists("SWATSpawn"..ply:EntIndex()) then
			timer.Remove("SWATSpawn"..ply:EntIndex())
		end
	end

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	-- Criminals defend the map, so they win if time expires or both teams are eliminated.
	if winner ~= 0 and winner ~= 1 then winner = 1 end

	net.Start("cri_roundend")
		net.WriteBool(winner == 1)
	net.Broadcast()

	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
		else
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

function MODE:PlayerDeath(ply)
end

function MODE:PlayerSpawn(ply)
	if not self.preparationActive or ply:Team() ~= 0 or self.swatDeployed or ply.crirespDeploying then return end

	timer.Simple(0, function()
		if IsValid(ply) and ply:Alive() and CurrentRound() == self and not self.swatDeployed then
			ply:KillSilent()
		end
	end)
end
