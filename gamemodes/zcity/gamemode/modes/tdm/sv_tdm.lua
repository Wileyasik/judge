local MODE = MODE

MODE.name = "tdm"
MODE.BuyTime = 40
MODE.StartMoney = 6500
MODE.ROUND_TIME = 240

MODE.Chance = 0.04

function MODE.GuiltCheck(Attacker, Victim, add, harm, amt)
	return 1, true--returning true so guilt bans
end

function MODE:CanLaunch()
	return true
	--[[local points = zb.GetMapPoints( "HMCD_TDM_T" )
	local points2 = zb.GetMapPoints( "HMCD_TDM_CT" )
    return (#points > 0) and (#points2 > 0)]] -- can work without them
end

MODE.ForBigMaps = true

util.AddNetworkString("tdm_start")
util.AddNetworkString("arena_loadout_sync")

net.Receive("arena_loadout_sync", function(_, ply)
	local raw = net.ReadString()
	if #raw > 4096 then return end
	local ok, parsed = pcall(util.JSONToTable, raw)
	if not ok or not istable(parsed) then return end
	ply.ArenaLoadout = parsed
end)
function MODE:Intermission()
	game.CleanUpMap()

	for i, ply in player.Iterator() do
		ply:SetupTeam(ply:Team())
		
	end

	net.Start("tdm_start")
	net.Broadcast()
end

function MODE:CheckAlivePlayers()
	return zb:CheckAliveTeams(true)
end

function MODE:ShouldRoundEnd()
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())
	return endround
end

function MODE:RoundStart()
	for k,ply in player.Iterator() do
		ply:Freeze(false)
	end
end

local tblweps = {
	[0] = {
		"weapon_akm",
	},
	[1] = {
		"weapon_m4a1",
	},
}

local tblatts = {
	[0] = {
		{""},
	},
	[1] = {
		{"holo14","laser2","grip3"},
	},
}

local tblarmors = {
	[0] = {
		{"vest4","helmet1"},
	},
	[1] = {
		{"vest4","helmet1"},
	},
}

local function ParseArenaLoadout(ply)
	if istable(ply.ArenaLoadout) then return ply.ArenaLoadout end
	local raw = ply:GetInfo("zcity_arena_loadout")
	if not isstring(raw) or raw == "" or #raw > 4096 then return {} end

	local ok, parsed = pcall(util.JSONToTable, raw)
	return ok and istable(parsed) and parsed or {}
end

local function ValidateArenaLoadout(ply)
	local parsed = ParseArenaLoadout(ply)
	local selected, usedSlots, selectedAttachments = {}, {}, {}
	local selectedArmor, selectedMedical, usedArmorSlots = {}, {}, {}
	local weight = 0

	for _, weaponId in ipairs(istable(parsed.weapons) and parsed.weapons or {}) do
		local info = MODE.ArenaWeapons[weaponId]
		if not info or usedSlots[info.slot] or weight + info.weight > MODE.ArenaMaxWeight then continue end

		usedSlots[info.slot] = true
		selected[#selected + 1] = weaponId
		weight = weight + info.weight
	end
	if #selected == 0 then
		selected = {ply:Team() == 1 and "weapon_m4a1" or "weapon_akm", "weapon_p22"}
		weight = MODE.ArenaWeapons[selected[1]].weight + MODE.ArenaWeapons[selected[2]].weight
	end

	local requestedAttachments = istable(parsed.attachments) and parsed.attachments or {}
	for _, weaponId in ipairs(selected) do
		local info = MODE.ArenaWeapons[weaponId]
		local allowed = {}
		for _, attachmentId in ipairs(info.attachments or {}) do allowed[attachmentId] = true end

		local usedPlacements = {}
		for _, attachmentId in ipairs(istable(requestedAttachments[weaponId]) and requestedAttachments[weaponId] or {}) do
			local placement
			for placementId, definitions in pairs(hg.attachments or {}) do
				if definitions[attachmentId] then placement = placementId break end
			end
			if not allowed[attachmentId] or not placement or usedPlacements[placement] then continue end
			local attachmentWeight = MODE:GetArenaAttachmentWeight(attachmentId)
			if weight + attachmentWeight > MODE.ArenaMaxWeight then continue end

			usedPlacements[placement] = true
			selectedAttachments[weaponId] = selectedAttachments[weaponId] or {}
			selectedAttachments[weaponId][#selectedAttachments[weaponId] + 1] = attachmentId
			weight = weight + attachmentWeight
		end
	end

	for _, armorId in ipairs(istable(parsed.armor) and parsed.armor or {}) do
		local info = MODE.ArenaArmor[armorId]
		if not info or usedArmorSlots[info.slot] or weight + info.weight > MODE.ArenaMaxWeight then continue end
		usedArmorSlots[info.slot] = true
		selectedArmor[#selectedArmor + 1] = armorId
		weight = weight + info.weight
	end

	local usedMedical = {}
	for _, medicalId in ipairs(istable(parsed.medical) and parsed.medical or {}) do
		local info = MODE.ArenaMedical[medicalId]
		if not info or usedMedical[medicalId] or weight + info.weight > MODE.ArenaMaxWeight then continue end
		usedMedical[medicalId] = true
		selectedMedical[#selectedMedical + 1] = medicalId
		weight = weight + info.weight
	end

	return selected, selectedAttachments, selectedArmor, selectedMedical, weight
end

local function ApplyArenaLoadout(ply)
	local selected, attachments, armor, medical, weight = ValidateArenaLoadout(ply)
	local function ApplyWeaponAttachments(weapon, attachmentIds, attemptsLeft, onDone)
		if not IsValid(weapon) then return end
		if not istable(weapon.attachments) or not istable(weapon.availableAttachments) then
			if attemptsLeft > 0 then timer.Simple(0.05, function() ApplyWeaponAttachments(weapon, attachmentIds, attemptsLeft - 1, onDone) end) end
			return
		end

		local complete = true
		for _, attachmentId in ipairs(attachmentIds or {}) do
			local placement
			for placementId, definitions in pairs(hg.attachments or {}) do
				if definitions[attachmentId] then placement = placementId break end
			end
			if placement and (not weapon.attachments[placement] or weapon.attachments[placement][1] ~= attachmentId) then
				complete = false
				if hg.AddAttachmentForce then hg.AddAttachmentForce(ply, weapon, attachmentId) end
			end
		end

		if not complete and attemptsLeft > 0 then
			timer.Simple(0.05, function() ApplyWeaponAttachments(weapon, attachmentIds, attemptsLeft - 1, onDone) end)
			return
		end
		if weapon.SyncAtts then weapon:SyncAtts() end
		if onDone then onDone() end
	end

	for _, weaponId in ipairs(selected) do
		local info = MODE.ArenaWeapons[weaponId]
		local weapon = ply:Give(weaponId)
		if not IsValid(weapon) then continue end
		local givenWeapon = weapon
		local givenInfo = info
		local givenAttachments = attachments[weaponId]

		timer.Simple(0.05, function()
			if not IsValid(ply) or not IsValid(givenWeapon) then return end
			ApplyWeaponAttachments(givenWeapon, givenAttachments, 10, function()
				if not IsValid(ply) or not IsValid(givenWeapon) then return end
				if givenWeapon:GetPrimaryAmmoType() >= 0 and givenWeapon:GetMaxClip1() > 0 then
					ply:GiveAmmo(givenWeapon:GetMaxClip1() * givenInfo.clips, givenWeapon:GetPrimaryAmmoType(), true)
				end
			end)
		end)
	end
	if hg.AddArmor then
		for _, armorId in ipairs(armor) do hg.AddArmor(ply, armorId) end
		hg.AddArmor(ply, "headphones1")
	end
	for _, medicalId in ipairs(medical) do ply:Give(medicalId) end

	ply:SetNWInt("ArenaMetaWeight", weight)
end

-- local giveweapons = CreateConVar("zb_tdm_giveweapon","1",FCVAR_LUA_SERVER,"TDMSPAWNS",0,1)

function MODE:GetPlySpawn(ply)
end

function MODE:GiveEquipment()
	timer.Simple(0.1,function()
		local mrand = math.random(#tblweps[0])

		for _, ply in player.Iterator() do
			if not ply:Alive() then continue end
			
			local inv = ply:GetNetVar("Inventory")
			inv["Weapons"]["hg_sling"] = true
			ply:SetNetVar("Inventory",inv)

			ply:SetSuppressPickupNotices(true)
			ply.noSound = true

			if ply:Team() == 1 then
				ply:SetPlayerClass("swat")
				zb.GiveRole(ply, "Counter Terrorist", Color(0,0,190))
				ply:SetNetVar("CurPluv", "pluvberet")
			else
				ply:SetPlayerClass("terrorist")
				zb.GiveRole(ply, "Terrorist", Color(190,0,0))
				ply:SetNetVar("CurPluv", "pluvboss")
			end

			ApplyArenaLoadout(ply)

			--[[if giveweapons:GetBool() then
				local gun = ply:Give(tblweps[ply:Team()][mrand])
				ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)
				
				hg.AddAttachmentForce(ply,gun,tblatts[ply:Team()][mrand])
				hg.AddArmor(ply, tblarmors[ply:Team()][mrand])


				ply:Give("weapon_hg_rgd_tpik")
				ply:Give("weapon_walkie_talkie")
				ply:Give("weapon_bandage_sh")
				ply:Give("weapon_tourniquet")
			end--]]

			//ply:Give("weapon_combatknife")

			ply:Give("weapon_combatknife")
			ply.organism.allowholster = true

			local Radio = ply:Give("weapon_walkie_talkie")
			Radio.Frequency = (ply:Team() == 1 and math.Round(math.Rand(88,95),1)) or math.Round(math.Rand(100,108),1)
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
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_T" )), zb.TranslatePointsToVectors(zb.GetMapPoints( "HMCD_TDM_CT" ))
end

function MODE:CanSpawn()
end

util.AddNetworkString("tdm_roundend")
function MODE:EndRound()
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
