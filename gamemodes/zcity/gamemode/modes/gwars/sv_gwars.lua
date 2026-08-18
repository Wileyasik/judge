MODE.name = "gwars"
MODE.PrintName = "Gang Wars"

MODE.ForBigMaps = false
MODE.ROUND_TIME = 180

MODE.Chance = 0.02

MODE.OverideSpawnPos = true
MODE.LootSpawn = false

local GWARS_TEAMS = {
	[0] = {
		name = "The Zoo",
		color = Color(13, 250, 241),
		clothes = {"rama_cl", "miami_cl", "Hawaiian_Shirt", "Security_Officer", "comfy_cl"},
		accessories = {"hotline miami mask"},
		accessoryChance = 1,
	},
	[1] = {
		name = "The Trinity",
		color = Color(255, 129, 0),
		clothes = {"rockmountain_cl", "sport_cl", "warpoint_cl", "winter_cl", "zekee_sport_cl", "sweatshirt_cl"},
		accessories = {"cool glasses", "starglassis", "aviators", "eyeglasses"},
		accessoryChance = 0.4,
		haircuts = {"haircut", "long haircut", "The witcher haircut", "Half haircut", "haircut gorshok", "modcut", "mohawk (dlya daynov)"},
		haircutChance = 0.5,
		hats = {"baseball cap", "fedora", "stetson", "straw hat", "sun hat", "bling cap", "top hat", "ZCity cap", "Usec cap", "pompon", "bomber"},
	},
}

function GWARS_ApplyTeamAppearance(ply)
	if not IsValid(ply) then return end

	local teamData = GWARS_TEAMS[ply:Team()]
	if not teamData then return end

	if not ply.GWARS_Clothes then
		ply.GWARS_Clothes = teamData.clothes[math.random(#teamData.clothes)]
	end
	if #teamData.accessories > 0 and ply.GWARS_Accessory == nil then
		if math.random() <= teamData.accessoryChance then
			ply.GWARS_Accessory = teamData.accessories[math.random(#teamData.accessories)]
		else
			ply.GWARS_Accessory = false
		end
	end
	if #(teamData.haircuts or {}) > 0 and ply.GWARS_Haircut == nil then
		if math.random() <= (teamData.haircutChance or 0) then
			ply.GWARS_Haircut = teamData.haircuts[math.random(#teamData.haircuts)]
		else
			ply.GWARS_Haircut = false
		end
	end
	if #(teamData.hats or {}) > 0 and ply.GWARS_Hat == nil then
		ply.GWARS_Hat = teamData.hats[math.random(#teamData.hats)]
	end

	local appearance = ply.CurAppearance
	if not istable(appearance) and hg.Appearance and hg.Appearance.GetRandomAppearance then
		appearance = hg.Appearance.GetRandomAppearance()
	end
	local tbl = istable(appearance) and table.Copy(appearance) or {}

	tbl.AColor = teamData.color

	if hg.Appearance and hg.Appearance.PlayerModels and tbl.AModel and hg.Appearance.PlayerModels[2][tbl.AModel] then
		if not ply.GWARS_MaleModel then
			local maleKeys = {}
			for k in pairs(hg.Appearance.PlayerModels[1]) do
				table.insert(maleKeys, k)
			end
			if #maleKeys > 0 then
				ply.GWARS_MaleModel = maleKeys[math.random(#maleKeys)]
			end
		end
		if ply.GWARS_MaleModel then
			tbl.AModel = ply.GWARS_MaleModel
		end
	end

	local clothes = istable(tbl.AClothes) and tbl.AClothes or {}
	tbl.AClothes = table.Copy(clothes)
	tbl.AClothes.main = ply.GWARS_Clothes

	local attachments = {}
	if #teamData.accessories > 0 and ply.GWARS_Accessory then
		attachments[#attachments + 1] = ply.GWARS_Accessory
	end
	if ply.GWARS_Hat then
		attachments[#attachments + 1] = ply.GWARS_Hat
	end
	if ply.GWARS_Haircut then
		attachments[#attachments + 1] = ply.GWARS_Haircut
	end
	tbl.AAttachments = attachments

	if hg.Appearance and hg.Appearance.ForceApplyAppearance then
		hg.Appearance.ForceApplyAppearance(ply, tbl)
	end
end

hook.Add("PlayerSpawn", "GWARS_TeamLook", function(ply)
	if not IsValid(ply) then return end
	if zb.CROUND ~= "gwars" then return end
	if not GWARS_TEAMS[ply:Team()] then return end

	local team = ply:Team()
	for _, delay in ipairs({0, 0.15, 0.4, 0.8, 1.5}) do
		timer.Simple(delay, function()
			if not IsValid(ply) or not ply:Alive() then return end
			if zb.CROUND ~= "gwars" then return end
			if ply:Team() ~= team then return end
			GWARS_ApplyTeamAppearance(ply)
		end)
	end
end)

function MODE:CanLaunch()
	return true
	--[[local points = zb.GetMapPoints( "HMCD_TDM_T" )
	local points2 = zb.GetMapPoints( "HMCD_TDM_CT" )
    return (#points > 0) and (#points2 > 0)--]]
end

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

util.AddNetworkString("gwars_start")
function MODE:Intermission()
	game.CleanUpMap()

	self.CTPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_CT" ),self.CTPoints)
	self.TPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_T" ),self.TPoints)
	
	for i, ply in player.Iterator() do
		ply:SetupTeam(ply:Team())
		ply.GWARS_Clothes = nil
		ply.GWARS_Accessory = nil
		ply.GWARS_Haircut = nil
		ply.GWARS_Hat = nil
		ply.GWARS_MaleModel = nil
	end

	net.Start("gwars_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	return zb:CheckAliveTeams(true)
end

function MODE:ShouldRoundEnd()
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	return endround or boringround
end

function MODE:BoringRoundFunction()		
	timer.Simple(2, function()
		//PrintMessage(HUD_PRINTTALK, "IT IS A GANG SHOOTOUT FFS...")
	end)
end

local swatSpawned = false

function MODE:RoundStart()
    swatSpawned = false 
    self.nextTeamLook = CurTime() + 6
end

local tblweps = {
	[0] = {
		"weapon_cz75",
		"weapon_deagle",
		"weapon_glock17",
		"weapon_glock18c",
		"weapon_revolver2",
		"weapon_hk_usp",
		"weapon_p22",
		"weapon_doublebarrel_short",
		"weapon_mac11",
	},
	[1] = {
		"weapon_cz75",
		"weapon_deagle",
		"weapon_glock17",
		"weapon_glock18c",
		"weapon_revolver2",
		"weapon_hk_usp",
		"weapon_p22",
		"weapon_doublebarrel_short",
		"weapon_mac11",
	}
}

local tblweps2 = {
	[0] = {
		"weapon_mr43",
		"weapon_mr43_short",
		"weapon_kedr",
		"weapon_pp1901",
		"weapon_sks",
		"weapon_m1a1",
		"weapon_svt",
		"weapon_vpo136",
		"weapon_vpo215",
		"weapon_toz106",
		"weapon_mp-80",
		"weapon_skorpion",
		"weapon_mp5",
		"weapon_mp5k",
		"weapon_mp5sd",
		"weapon_mp7",
		"weapon_mp9",
		"weapon_p90",
		"weapon_ump45",
		"weapon_uzi",
		"weapon_uzip",
		"weapon_vector",
		"weapon_vector45",
	},
	[1] = {
		"weapon_mr43",
		"weapon_mr43_short",
		"weapon_kedr",
		"weapon_pp1901",
		"weapon_sks",
		"weapon_m1a1",
		"weapon_svt",
		"weapon_vpo136",
		"weapon_vpo215",
		"weapon_toz106",
		"weapon_mp-80",
		"weapon_skorpion",
		"weapon_mp5",
		"weapon_mp5k",
		"weapon_mp5sd",
		"weapon_mp7",
		"weapon_mp9",
		"weapon_p90",
		"weapon_ump45",
		"weapon_uzi",
		"weapon_uzip",
		"weapon_vector",
		"weapon_vector45",
	}
}

local tblweps3 = {
	[0] = {
		"weapon_ak74u",
		"weapon_akm",
		"weapon_ak74",
		"weapon_ak12",
		"weapon_ak100",
	},
	[1] = {
		"weapon_ak74u",
		"weapon_akm",
		"weapon_ak74",
		"weapon_ak12",
		"weapon_ak100",
	}
}


--[[local tblatts = {
	[0] = {
		{"optic4"},
	},
	[1] = {
		{"holo14","laser2","grip3"}
	}
}]]

local tblarmors = {
	[0] = {
		{"ent_armor_vest26"}
	},
	[1] = {
		{"ent_armor_vest26"}
	}
}

function MODE:GetPlySpawn(ply)
end

function MODE:GiveEquipment()
	self.CTPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_CT" ),self.CTPoints)
	self.TPoints = {}
	table.CopyFromTo(zb.GetMapPoints( "HMCD_TDM_T" ),self.TPoints)
	timer.Simple(0.1,function()
		local teamArmorCount = { [0] = 0, [1] = 0 } 

		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end
			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			local teamData = GWARS_TEAMS[ply:Team()]
			if teamData then
				zb.GiveRole(ply, teamData.name, teamData.color)
				GWARS_ApplyTeamAppearance(ply)
			end

			if ply:Team() == 0 then
				ply:SetNetVar("CurPluv", "pluvred")
			else
				ply:SetNetVar("CurPluv", "pluvgreen")
			end

			local tbl = tblweps[ply:Team()]
			local wep = ply:Give(tbl[math.random(#tbl)])
			if IsValid(wep) and wep.GetMaxClip1 then
				ply:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType())
			end

			if math.random() <= 0.5 then
				local tbl2 = (math.random() <= 0.1) and tblweps3[ply:Team()] or tblweps2[ply:Team()]
				local wep2 = ply:Give(tbl2[math.random(#tbl2)])
				if IsValid(wep2) and wep2.GetMaxClip1 then
					ply:GiveAmmo(wep2:GetMaxClip1(), wep2:GetPrimaryAmmoType())
				end
			end

			if wep.SetDeagleSkin then
				//wep:SetDeagleSkin(4)
				//wep:SetDeagleBodygroup(1)
			end

			local armorSet = tblarmors[ply:Team()]
			if armorSet and #armorSet > 0 and math.random() <= 0.5 then
				for _, ent in ipairs(armorSet[math.random(#armorSet)]) do
					hg.AddArmor(ply, ent)
				end
			end

			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:Give("weapon_painkillers_tpik")

			local hands = ply:Give("weapon_hands_sh")
			ply:SelectWeapon("weapon_hands_sh")

			timer.Simple(0.1,function()
				ply.noSound = false
			end)

			ply:SetSuppressPickupNotices(false)
		end
	end)
end

function MODE:RoundThink()
	if self.nextTeamLook and CurTime() > self.nextTeamLook then
		self.nextTeamLook = CurTime() + 3
		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end
			if GWARS_TEAMS[ply:Team()] then
				GWARS_ApplyTeamAppearance(ply)
			end
		end
	end

	if not swatSpawned and (CurTime() - zb.ROUND_BEGIN) >= 120 then
		local teamCount = { [0] = 0, [1] = 0 }
		for _, ply in player.Iterator() do
			if ply:Team() == 0 or ply:Team() == 1 then
				teamCount[ply:Team()] = teamCount[ply:Team()] + 1
			end
		end

		local waveTeam = (teamCount[0] <= teamCount[1]) and 0 or 1
		local teamData = GWARS_TEAMS[waveTeam]

		local deadPlayers = {}
		for _, ply in player.Iterator() do
			if not ply:Alive() and ply:Team() != TEAM_SPECTATOR then
				table.insert(deadPlayers, ply)
			end
		end

		local startpos = self.TPoints and #self.TPoints > 0 and self.TPoints[1].pos or zb:GetRandomSpawn()

		for i = 1, math.min(4, #deadPlayers) do
			local ply = deadPlayers[i]
			local oldTeam = ply:Team()

			ply:Spawn()
			ply:SetTeam(waveTeam)
			if !startpos then
				startpos = ply:GetPos()
			else
				hg.tpPlayer(startpos, ply, i, 0)
			end

			if oldTeam != waveTeam then
				ply.GWARS_Clothes = nil
				ply.GWARS_Accessory = nil
				ply.GWARS_Haircut = nil
				ply.GWARS_Hat = nil
			end

			ply:SetNetVar("CurPluv", waveTeam == 0 and "pluvred" or "pluvgreen")

			if teamData then
				zb.GiveRole(ply, teamData.name, teamData.color)
				GWARS_ApplyTeamAppearance(ply)
			end

			local tbl = tblweps[waveTeam]
			local wep = ply:Give(tbl[math.random(#tbl)])
			if IsValid(wep) and wep.GetMaxClip1 then
				ply:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType())
			end

			if math.random() <= 0.5 then
				local tbl2 = (math.random() <= 0.1) and tblweps3[waveTeam] or tblweps2[waveTeam]
				local wep2 = ply:Give(tbl2[math.random(#tbl2)])
				if IsValid(wep2) and wep2.GetMaxClip1 then
					ply:GiveAmmo(wep2:GetMaxClip1(), wep2:GetPrimaryAmmoType())
				end
			end

			local armorSet = tblarmors[waveTeam]
			if armorSet and #armorSet > 0 and math.random() <= 0.5 then
				for _, ent in ipairs(armorSet[math.random(#armorSet)]) do
					hg.AddArmor(ply, ent)
				end
			end

			ply:Give("weapon_bandage_sh")
			ply:Give("weapon_tourniquet")
			ply:Give("weapon_painkillers_tpik")

			local hands = ply:Give("weapon_hands_sh")
			ply:SelectWeapon("weapon_hands_sh")
		end

		swatSpawned = true
	end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("gwars_roundend")
function MODE:EndRound()
	timer.Simple(2,function()
		net.Start("gwars_roundend")
		net.Broadcast()
	end)

	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	for k,ply in player.Iterator() do
		if ply:Team() == winner then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
			--print("give",ply)
		else
			--print("take",ply)
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end
end

function MODE:PlayerDeath(ply)
end