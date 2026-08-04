local MODE = MODE

MODE.name = "tdm"
MODE.BuyTime = 40
MODE.StartMoney = 6500
MODE.ROUND_TIME = 240
MODE.VoteTime = 10

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
util.AddNetworkString("arena_round_start")
util.AddNetworkString("arena_cleanup_start")
util.AddNetworkString("arena_loadout_sync")
util.AddNetworkString("arena_announcer")
util.AddNetworkString("arena_start_vote")
util.AddNetworkString("arena_vote_update")
util.AddNetworkString("arena_vote_result")
util.AddNetworkString("arena_change_vote")

for i = 1, 10 do
	util.PrecacheSound("arena/killz/kill" .. i .. ".mp3")
end

local function BroadcastArenaAnnouncer(eventType, index)
	net.Start("arena_announcer")
		net.WriteUInt(eventType, 2)
		net.WriteUInt(index, 4)
	net.Broadcast()
end

local announcerBags = {}
local announcerLast = {}
local function NextArenaAnnouncerIndex(eventType)
	local bag = announcerBags[eventType]
	if not bag or #bag == 0 then
		bag = {}
		for index = 1, 10 do bag[index] = index end
		table.Shuffle(bag)
		if #bag > 1 and bag[#bag] == announcerLast[eventType] then
			bag[1], bag[#bag] = bag[#bag], bag[1]
		end
		announcerBags[eventType] = bag
	end

	local index = table.remove(bag)
	announcerLast[eventType] = index
	return index
end

hook.Add("Player_Death", "ArenaKillAnnouncer", function(victim)
	local attacker = victim.ArenaLastAttacker
	local attackTime = victim.ArenaLastAttackTime or 0
	victim.ArenaLastAttacker = nil
	victim.ArenaLastAttackTime = nil
	if zb.CROUND ~= "tdm" or zb.ROUND_STATE ~= 1 or CurTime() - attackTime > 20 or not IsValid(attacker) or attacker == victim then return end
	BroadcastArenaAnnouncer(0, NextArenaAnnouncerIndex(0))

	if not MODE.CleanupActive then
		zb.ROUND_TIME = (zb.ROUND_TIME or MODE.ROUND_TIME) + 30
		hg.UpdateRoundTime(zb.ROUND_TIME)
	end
end)

hook.Add("EntityTakeDamage", "ArenaCleanupRoleDamage", function(victim, damageInfo)
	if zb.CROUND ~= "tdm" or not MODE.CleanupActive or not victim:IsPlayer() then return end
	local attacker = damageInfo:GetAttacker()
	if not IsValid(attacker) or not attacker:IsPlayer() then return end

	local sameRole = victim:GetNWBool("ArenaCleanupTarget") and attacker:GetNWBool("ArenaCleanupTarget")
		or victim:GetNWBool("ArenaCleanupCleaner") and attacker:GetNWBool("ArenaCleanupCleaner")
	if sameRole then return true end
end)

hook.Add("HomigradDamage", "ArenaTrackAttacker", function(victim, damageInfo, _, _, harm)
	if zb.CROUND ~= "tdm" or not IsValid(victim) or not victim:IsPlayer() or (harm or 0) <= 0 then return end
	local attacker = damageInfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim then
		victim.ArenaLastAttacker = attacker
		victim.ArenaLastAttackTime = CurTime()
	end
end)

local function RemoveVoteTimers()
	timer.Remove("arena_vote_end")
	timer.Remove("arena_vote_update")
end

function MODE:StartVoting()
	self.VoteInProgress = true
	self.VoteResults = {[1] = 0, [2] = 0, [3] = 0}

	net.Start("arena_start_vote")
		net.WriteFloat(CurTime() + self.VoteTime)
	net.Broadcast()

	timer.Create("arena_vote_end", self.VoteTime, 1, function()
		if CurrentRound() == MODE then MODE:EndVoting() end
	end)
	timer.Create("arena_vote_update", 1, self.VoteTime, function()
		if CurrentRound() ~= MODE or not MODE.VoteInProgress then return end
		net.Start("arena_vote_update")
			net.WriteTable(MODE.VoteResults)
		net.Broadcast()
	end)
end

function MODE:EndVoting()
	RemoveVoteTimers()
	local highestVotes, choices = -1, {}
	for index = 1, 3 do
		local votes = self.VoteResults[index] or 0
		if votes > highestVotes then
			highestVotes = votes
			choices = {index}
		elseif votes == highestVotes then
			choices[#choices + 1] = index
		end
	end

	local selected = highestVotes > 0 and choices[math.random(#choices)] or 2
	self.SeriesTotal = (ARENA_ROUND_OPTIONS[selected] or ARENA_ROUND_OPTIONS[2]).rounds
	self.SeriesLeft = self.SeriesTotal
	self.VoteInProgress = false
	self.RoundSetupTime = CurTime() + 2

	net.Start("arena_vote_result")
		net.WriteUInt(selected, 2)
		net.WriteTable(self.VoteResults)
	net.Broadcast()

	timer.Simple(1, function()
		if CurrentRound() ~= MODE then return end
		MODE.HasAppliedLoadout = false
		MODE:GiveEquipment()
		net.Start("arena_round_start")
			net.WriteBool(true)
		net.Broadcast()
	end)
end

net.Receive("arena_change_vote", function(_, ply)
	if zb.CROUND ~= "tdm" or not MODE.VoteInProgress or ply:Team() == TEAM_SPECTATOR then return end
	if (ply.LastArenaVoteChange or 0) > CurTime() then return end
	ply.LastArenaVoteChange = CurTime() + 0.5

	local oldVote, newVote = net.ReadUInt(2), net.ReadUInt(2)
	if newVote < 1 or newVote > 3 then return end
	if oldVote >= 1 and oldVote <= 3 and ply.ArenaVote == oldVote then
		MODE.VoteResults[oldVote] = math.max((MODE.VoteResults[oldVote] or 0) - 1, 0)
	end
	MODE.VoteResults[newVote] = (MODE.VoteResults[newVote] or 0) + 1
	ply.ArenaVote = newVote

	net.Start("arena_vote_update")
		net.WriteTable(MODE.VoteResults)
	net.Broadcast()
end)

hook.Add("SetupPlayerVisibility", "ArenaCleanupTargets", function(ply)
	if zb.CROUND ~= "tdm" or not MODE.CleanupActive or not ply:GetNWBool("ArenaCleanupCleaner") then return end

	for _, target in player.Iterator() do
		if target:Alive() and target:GetNWBool("ArenaCleanupTarget") then
			local character = hg.GetCurrentCharacter(target)
			AddOriginToPVS(IsValid(character) and character:GetPos() or target:GetPos())
		end
	end
end)

net.Receive("arena_loadout_sync", function(_, ply)
	local raw = net.ReadString()
	if #raw > 4096 then return end
	local ok, parsed = pcall(util.JSONToTable, raw)
	if not ok or not istable(parsed) then return end
	ply.ArenaLoadout = parsed
end)
function MODE:Intermission()
	RemoveVoteTimers()
	self.VoteInProgress = false
	self.RoundSetupTime = nil
	self.HasAppliedLoadout = false
	self.CleanupActive = false
	self.CleanupDeadline = nil
	self.CleanupWinner = nil
	SetGlobalBool("ArenaCleanupActive", false)
	SetGlobalFloat("ArenaCleanupDeadline", 0)

	game.CleanUpMap()

	for i, ply in player.Iterator() do
		ply.ArenaVote = nil
		ply.ArenaLastAttacker = nil
		ply.ArenaLastAttackTime = nil
		ply:SetNWBool("ArenaCleanupTarget", false)
		ply:SetNWBool("ArenaCleanupCleaner", false)
		ply:SetupTeam(ply:Team())
		
	end

	if self.SeriesLeft and self.SeriesLeft > 0 then
		net.Start("arena_round_start")
			net.WriteBool(false)
		net.Broadcast()
	else
		self:StartVoting()
	end
end

function MODE:CheckAlivePlayers()
	return zb:CheckAliveTeams(true)
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
	local selectedArmorIds = {}
	local weight = 0

	for _, weaponId in ipairs(istable(parsed.weapons) and parsed.weapons or {}) do
		local info = MODE.ArenaWeapons[weaponId]
		if not info or usedSlots[info.slot] or weight + info.weight > MODE.ArenaMaxWeight then continue end

		usedSlots[info.slot] = true
		selected[#selected + 1] = weaponId
		weight = weight + info.weight
	end
	if not usedSlots.primary then
		local primary = ply:Team() == 1 and "weapon_m4a1" or "weapon_akm"
		table.insert(selected, 1, primary)
		usedSlots.primary = true
		weight = weight + MODE.ArenaWeapons[primary].weight
	end
	if not usedSlots.secondary then
		selected[#selected + 1] = "weapon_p22"
		usedSlots.secondary = true
		weight = weight + MODE.ArenaWeapons.weapon_p22.weight
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
		if info and info.helmets then continue end
		if not info or usedArmorSlots[info.slot] or weight + info.weight > MODE.ArenaMaxWeight then continue end
		usedArmorSlots[info.slot] = true
		selectedArmor[#selectedArmor + 1] = armorId
		selectedArmorIds[armorId] = true
		weight = weight + info.weight
	end
	for _, armorId in ipairs(istable(parsed.armor) and parsed.armor or {}) do
		local info = MODE.ArenaArmor[armorId]
		if not info or not info.helmets or usedArmorSlots[info.slot] or weight + info.weight > MODE.ArenaMaxWeight then continue end
		local compatible = false
		for helmetId in pairs(info.helmets) do
			if selectedArmorIds[helmetId] then compatible = true break end
		end
		if not compatible then continue end
		usedArmorSlots[info.slot] = true
		selectedArmor[#selectedArmor + 1] = armorId
		selectedArmorIds[armorId] = true
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

function MODE:RoundStartPost()
	if self.SeriesLeft and self.SeriesLeft > 1 then NextRound(self.name, true) end
end

local function ApplyArenaLoadout(ply)
	local selected, attachments, armor, medical, weight = ValidateArenaLoadout(ply)
	local ammoGrants = {}

	for _, weaponId in ipairs(selected) do
		local info = MODE.ArenaWeapons[weaponId]
		local weapon = ply:Give(weaponId)
		if not IsValid(weapon) then continue end
		ammoGrants[weaponId] = info.clips
	end

	timer.Simple(0.5, function()
		if not IsValid(ply) then return end
		for weaponId, clips in pairs(ammoGrants) do
			if not ply:HasWeapon(weaponId) then continue end
			local weapon = ply:GetWeapon(weaponId)
			if not IsValid(weapon) then continue end
			if istable(weapon.attachments) and hg.SetAttachment then
				for _, attachmentId in ipairs(attachments[weaponId] or {}) do
					hg.SetAttachment(weapon.attachments, attachmentId, weapon:GetClass())
				end
				if weapon.UpdateAttachmentModifiers then weapon:UpdateAttachmentModifiers() end
				if weapon.SyncAtts then weapon:SyncAtts() end
			end
			if weapon:GetPrimaryAmmoType() >= 0 and weapon:GetMaxClip1() > 0 then
				ply:GiveAmmo(weapon:GetMaxClip1() * clips, weapon:GetPrimaryAmmoType(), true)
			end
		end
	end)
	if hg.AddArmor then
		for _, armorId in ipairs(armor) do hg.AddArmor(ply, armorId) end
		local blocksHeadphones = false
		for placement, armorId in pairs(ply.armors or {}) do
			local armorData = hg.armor[placement] and hg.armor[placement][armorId]
			if armorData and armorData.blocksHeadphones then blocksHeadphones = true break end
		end
		if not blocksHeadphones then hg.AddArmor(ply, "headphones1") end
	end
	for _, medicalId in ipairs(medical) do ply:Give(medicalId) end

	ply:SetNWInt("ArenaMetaWeight", weight)
end

local cleanupLoadouts = {
	{primary = "weapon_m4a1", secondary = "weapon_glock17", grenade = "weapon_hg_flashbang_tpik", armor = "vest30", helmet = "helmet14"},
	{primary = "weapon_ak12", secondary = "weapon_pl15", grenade = "weapon_hg_rgd_tpik", armor = "vest26", helmet = "helmet14"},
	{primary = "weapon_mp7", secondary = "weapon_fn45", grenade = "weapon_hg_smokenade_tpik", armor = "vest26", helmet = "helmet1"},
	{primary = "weapon_spas12", secondary = "weapon_p226", grenade = "weapon_hg_flashbang_tpik", armor = "vest30", helmet = "helmet1"},
	{primary = "weapon_scarh", secondary = "weapon_hk_usp", grenade = "weapon_hg_smokenade_tpik", armor = "vest1", helmet = "helmet14"},
	{primary = "weapon_m249", secondary = "weapon_cz75", grenade = "weapon_hg_grenade_tpik", armor = "vest30", helmet = "helmet14"},
}

local function ApplyCleanupLoadout(ply)
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetSuppressPickupNotices(true)

	local loadout = cleanupLoadouts[math.random(#cleanupLoadouts)]
	local rifle = ply:Give(loadout.primary)
	local pistol = ply:Give(loadout.secondary)
	ply:Give(loadout.grenade)
	ply:Give("weapon_combatknife")
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")
	ply:Give("weapon_hands_sh")

	for _, weapon in ipairs({rifle, pistol}) do
		if IsValid(weapon) and weapon:GetPrimaryAmmoType() >= 0 and weapon:GetMaxClip1() > 0 then
			ply:GiveAmmo(weapon:GetMaxClip1() * 4, weapon:GetPrimaryAmmoType(), true)
		end
	end

	if hg.AddArmor then
		hg.AddArmor(ply, loadout.armor)
		hg.AddArmor(ply, loadout.helmet)
		hg.AddArmor(ply, "headphones1")
	end

	ply:SetSuppressPickupNotices(false)
	if IsValid(rifle) then ply:SelectWeapon(rifle:GetClass()) end
end

local function IsCleanupRoleAlive(role)
	for _, ply in player.Iterator() do
		if ply:Alive() and ply:GetNWBool(role) then return true end
	end

	return false
end

function MODE:StartCleanup()
	local targets, cleaners = {}, {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if ply:Alive() then
			targets[#targets + 1] = ply
		else
			cleaners[#cleaners + 1] = ply
		end
	end

	if #targets == 0 or #cleaners == 0 then return false end

	local cleanupStart = CurTime()
	self.CleanupActive = true
	self.CleanupDeadline = cleanupStart + 90
	self.CleanupWinner = nil
	hg.UpdateRoundTime(90, cleanupStart, cleanupStart)
	SetGlobalBool("ArenaCleanupActive", true)
	SetGlobalFloat("ArenaCleanupDeadline", self.CleanupDeadline)
	net.Start("arena_cleanup_start")
	net.Broadcast()
	BroadcastArenaAnnouncer(3, NextArenaAnnouncerIndex(3))

	for _, ply in ipairs(targets) do
		ply:SetNWBool("ArenaCleanupTarget", true)
		ply:SetNWBool("ArenaCleanupCleaner", false)
	end

	for _, ply in ipairs(cleaners) do
		ply:Spawn()
		ply:SetTeam(1)
		ply:GetRandomSpawn()
		ply:SetPlayerClass("arena_cleaner")
		ply:SetNWBool("ArenaCleanupTarget", false)
		ply:SetNWBool("ArenaCleanupCleaner", true)
		ply:Freeze(false)
		ply:SetMoveType(MOVETYPE_WALK)

		timer.Simple(0.2, function()
			if not IsValid(ply) or not MODE.CleanupActive or not ply:Alive() then return end
			ply:SetTeam(1)
			ply:SetNWBool("ArenaCleanupTarget", false)
			ply:SetNWBool("ArenaCleanupCleaner", true)
			ply:Freeze(false)
			ply:SetMoveType(MOVETYPE_WALK)
			ApplyCleanupLoadout(ply)
		end)
	end

	return true
end

function MODE:ShouldRoundEnd()
	if self.VoteInProgress or self.RoundSetupTime and CurTime() < self.RoundSetupTime then return false end

	if self.CleanupActive then
		local teamEliminated = zb:CheckWinner(self:CheckAlivePlayers())
		if teamEliminated then
			self.CleanupWinner = nil
			return true
		end

		if not IsCleanupRoleAlive("ArenaCleanupTarget") then
			self.CleanupWinner = "cleaners"
			return true
		end

		if not IsCleanupRoleAlive("ArenaCleanupCleaner") or CurTime() >= self.CleanupDeadline then
			self.CleanupWinner = "targets"
			return true
		end

		return false
	end

	local endround = zb:CheckWinner(self:CheckAlivePlayers())
	if endround then return true end

	local timedOut = (zb.ROUND_START or CurTime()) + (zb.ROUND_TIME or self.ROUND_TIME) <= CurTime()
	if timedOut and self:StartCleanup() then return false end

	return nil
end

-- local giveweapons = CreateConVar("zb_tdm_giveweapon","1",FCVAR_LUA_SERVER,"TDMSPAWNS",0,1)

function MODE:GetPlySpawn(ply)
end

function MODE:GiveEquipment()
	if self.VoteInProgress or self.HasAppliedLoadout then return end
	self.HasAppliedLoadout = true

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
	local _, winner = zb:CheckWinner(self:CheckAlivePlayers())
	local cleanupWinner = self.CleanupWinner
	if not cleanupWinner then
		if winner == 0 then
			BroadcastArenaAnnouncer(1, NextArenaAnnouncerIndex(1))
		elseif winner == 1 then
			BroadcastArenaAnnouncer(2, NextArenaAnnouncerIndex(2))
		end
	end

	for k,ply in player.Iterator() do
		local won = cleanupWinner == "targets" and ply:GetNWBool("ArenaCleanupTarget")
			or cleanupWinner == "cleaners" and ply:GetNWBool("ArenaCleanupCleaner")
			or not cleanupWinner and ply:Team() == winner
		if won then
			ply:GiveExp(math.random(15,30))
			ply:GiveSkill(math.Rand(0.1,0.15))
			--print("give",ply)
		else
			--print("take",ply)
			ply:GiveSkill(-math.Rand(0.05,0.1))
		end
	end

	self.CleanupActive = false
	SetGlobalBool("ArenaCleanupActive", false)

	if self.SeriesLeft then
		self.SeriesLeft = self.SeriesLeft - 1
		if self.SeriesLeft <= 0 or zb.nextround ~= self.name then
			self.SeriesLeft = nil
			self.SeriesTotal = nil
		end
	end
end

function MODE:PlayerDeath(ply)
end
