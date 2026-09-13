local MODE = MODE

MODE.name = "realish"
MODE.PrintName = "Realish"
MODE.start_time = 12
MODE.end_time = 7
MODE.ROUND_TIME = 1800
MODE.Chance = 0.03
MODE.ForBigMaps = false
MODE.OverrideSpawn = true
MODE.StartLives = 50
MODE.StartCoins = 6
MODE.DeployCooldown = 15
MODE.MaxRoundTime = 1800
MODE.MusicTrackCount = 7

util.AddNetworkString("realish_start")
util.AddNetworkString("realish_open_menu")
util.AddNetworkString("realish_loadout")
util.AddNetworkString("realish_request_spawn")
util.AddNetworkString("realish_deployed")
util.AddNetworkString("realish_end")
util.AddNetworkString("realish_hit_notify")
util.AddNetworkString("realish_hero_notify")
util.AddNetworkString("realish_hero_spawn")
util.AddNetworkString("realish_hero_choice")
util.AddNetworkString("realish_hero_lives_anim")
util.AddNetworkString("realish_killstreak_choice")
util.AddNetworkString("realish_killstreak_earned")

local teamKeys = {
	[0] = "Realish_ATLAS_Lives",
	[1] = "Realish_REVENANT_Lives"
}

local teamRoles = {
	[0] = {"ATLAS", Color(200, 20, 20)},
	[1] = {"REVENANT", Color(20, 80, 220)}
}

local loadouts = {
	Assault = true,
	Medic = true,
	Recon = true,
	Demolition = true
}

local armors = {
	None = true,
	Light = true,
	Heavy = true
}

local loadoutAliases = {
	Rifleman = "Assault",
	Scout = "Recon"
}

local cleanupTimer = "realish_cleanup"
local cleanupInterval = 15
local cleanupRagdollTime = 5
local cleanupWeaponTime = 1
local cleanupFadeTime = 3
local cleanupSteps = 12

local heroCheckTimer = "RealishHeroCheck"
local heroTeamLastTrigger = heroTeamLastTrigger or {[0] = 0, [1] = 0}
local heroActiveCount = heroActiveCount or {[0] = 0, [1] = 0}
local heroPickedThisRound = heroPickedThisRound or {[0] = false, [1] = false}

local RealishHeroScaledDmg = setmetatable({}, {__mode = "k"})

local ResetKillstreakState, ResetKillstreakRound, CheckKillstreaks

RealishHeroConfig = RealishHeroConfig or {}
RealishHeroConfig.heroLives = 3

local function ResetHeroRoundState()
	for teamID = 0, 1 do heroPickedThisRound[teamID] = false end
	for _, ply in player.Iterator() do
		if IsValid(ply) then
			ply.RealishHasBeenHeroThisRound = false
			ply.RealishHeroLives = 0
			ply:SetNWInt("Realish_HeroLives", 0)
		end
	end
end

local function RealishClearSpawnProtect(ply)
	if not IsValid(ply) then return end
	ply.RealishSpawnProtectUntil = 0
	ply:SetNWFloat("RealishSpawnProtectUntil", 0)
	timer.Remove("RealishSpawnProtect_" .. ply:EntIndex())
	if ply.organism then ply.organism.godmode = false end
end

local function RealishApplySpawnProtect(ply)
	if not IsValid(ply) then return end
	local round = CurrentRound()
	if not round or round.name ~= "realish" then return end
	if ply:Team() ~= 0 and ply:Team() ~= 1 then return end
	ply.RealishSpawnProtectUntil = CurTime() + 5
	ply:SetNWFloat("RealishSpawnProtectUntil", ply.RealishSpawnProtectUntil)
	if ply.organism then
		ply.RealishSpawnProtectPrevGod = ply.organism.godmode
		ply.organism.godmode = true
	else
		timer.Simple(0.05, function()
			if IsValid(ply) and ply.organism then
				ply.RealishSpawnProtectPrevGod = ply.organism.godmode
				ply.organism.godmode = true
			end
		end)
	end
	timer.Create("RealishSpawnProtect_" .. ply:EntIndex(), 5, 1, function()
		if not IsValid(ply) then return end
		ply.RealishSpawnProtectUntil = 0
		ply:SetNWFloat("RealishSpawnProtectUntil", 0)
		if ply.organism then
			ply.organism.godmode = ply.RealishSpawnProtectPrevGod or false
			ply.RealishSpawnProtectPrevGod = nil
		end
	end)
end

local function ResetHeroState(ply)
	ply.RealishHeroOfferTeam = nil
	ply.RealishHeroOfferDeadline = 0
	ply.RealishIsHero = false
	ply.RealishHeroChoice = ply.RealishHeroChoice or (RealishHeroOrder and RealishHeroOrder[1]) or "Strike"
	ply.RealishHeroLives = 0
	ply:SetNWFloat("Realish_HeroDeadline", 0)
	ply:SetNWInt("Realish_HeroTeam", -1)
	ply:SetNWBool("Realish_IsHero", false)
	ply:SetNWString("Realish_HeroChoice", ply.RealishHeroChoice)
	ply:SetNWInt("Realish_HeroLives", 0)
end

local function ClearHeroOffer(ply)
	if ply.RealishHeroOfferTeam ~= nil or ply.RealishIsHero then
		ply.RealishHeroOfferTeam = nil
		ply.RealishHeroOfferDeadline = 0
		ply:SetNWFloat("Realish_HeroDeadline", 0)
		ply:SetNWInt("Realish_HeroTeam", -1)
	end
end

local function TeamHasHeroOffer(teamID)
	for _, ply in player.Iterator() do
		if ply:Team() == teamID and ply.RealishHeroOfferTeam == teamID and ply.RealishHeroOfferDeadline > CurTime() then
			return true
		end
	end
	return false
end

local function CountActiveHeroes(teamID)
	local n = 0
	for _, ply in player.Iterator() do
		if ply:Team() == teamID and ply.RealishIsHero then n = n + 1 end
	end
	return n
end

local function PickHeroForTeam(teamID, skip)
	if heroPickedThisRound[teamID] then return end
	local cfg = RealishHeroConfig or {}
	local candidates = {}

	for _, ply in player.Iterator() do
		if not IsValid(ply) or ply:IsBot() then continue end
		if ply:Team() ~= teamID then continue end
		if ply.RealishIsHero then continue end
		if ply.RealishHasBeenHeroThisRound then continue end
		if skip and ply == skip then continue end
		if ply.RealishHeroOfferTeam == teamID and ply.RealishHeroOfferDeadline > CurTime() then continue end
		candidates[#candidates + 1] = ply
	end

	if #candidates == 0 then return end

	local ply = candidates[math.random(#candidates)]
	local deadline = CurTime() + (cfg.duration or 30)

	ply.RealishHeroOfferTeam = teamID
	ply.RealishHeroOfferDeadline = deadline
	ply:SetNWFloat("Realish_HeroDeadline", deadline)
	ply:SetNWInt("Realish_HeroTeam", teamID)

	heroTeamLastTrigger[teamID] = CurTime()

	net.Start("realish_hero_notify")
		net.WriteInt(teamID, 4)
		net.WriteFloat(deadline)
	net.Send(ply)
end

local function GetArmorCost(armor)
	return RealishArmorCosts and RealishArmorCosts[armor] or 0
end

local function GetClassName(loadout)
	loadout = loadoutAliases[loadout] or loadout
	return loadouts[loadout] and loadout or "Assault"
end

local function GetSlotOption(loadout, slotID, className)
	local class = RealishClasses and RealishClasses[loadout]
	local options = class and class[slotID]
	if not options then return end

	for _, option in ipairs(options) do
		if option.class == className then return option end
	end
end

local function GetFirstFreeChoice(loadout, slotID, taken)
	local class = RealishClasses and RealishClasses[loadout]
	local options = class and class[slotID]
	if not options then return "" end

	for _, option in ipairs(options) do
		if not taken[option.class] then return option.class end
	end

	return ""
end

local function SanitizeChoices(loadout, choices)
	local sanitized = {}
	local taken = {}

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		local className = choices and choices[slot.id]
		if not className or className == "" or taken[className] or not GetSlotOption(loadout, slot.id, className) then
			className = GetFirstFreeChoice(loadout, slot.id, taken)
		end
		sanitized[slot.id] = className
		if className ~= "" then taken[className] = true end
	end

	return sanitized
end

local function HasAttachment(option, att)
	for _, attachment in ipairs(option and option.attachments or {}) do
		if attachment == att then return true end
	end
end

local function SanitizeAttachments(loadout, choices, attachments)
	local sanitized = {}

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		local option = GetSlotOption(loadout, slot.id, choices and choices[slot.id])
		sanitized[slot.id] = {}

		for _, att in ipairs(attachments and attachments[slot.id] or {}) do
			if HasAttachment(option, att) and not table.HasValue(sanitized[slot.id], att) then
				sanitized[slot.id][#sanitized[slot.id] + 1] = att
			end
		end
	end

	return sanitized
end

local function CanDeployNow(ply, round)
	if zb.ROUND_STATE ~= 1 then return false end
	if not ply:IsBot() and CurTime() < GetGlobalFloat("Realish_DeployTime", 0) then return false end

	local teamID = ply:Team()
	if teamID ~= 0 and teamID ~= 1 then return false end
	if ply:Alive() and not ply.RealishDeployed then return true end

	return not ply:Alive() and round:GetLives(teamID) > 0
end

local function OpenDeployMenu(ply)
	if ply:IsBot() then return end

	net.Start("realish_open_menu")
	net.Send(ply)
end

local function TryBuyArmor(ply)
	local armor = ply.RealishArmor or "Light"
	local cost = GetArmorCost(armor)
	if cost <= 0 then return true end

	local coins = ply:GetNWInt("Realish_Coins", 0)
	if coins < cost then
		ply:ChatPrint("Not enough coins for armor.")
		return false
	end

	ply:SetNWInt("Realish_Coins", coins - cost)
	return true
end

local function IsRealishRound()
	local round = CurrentRound()
	return round and round.name == "realish"
end

local function EvaluateHeroTrigger()
	if not IsRealishRound() then return end
	if zb.ROUND_STATE ~= 1 then return end

	local round = CurrentRound()
	local cfg = RealishHeroConfig or {}
	local minTime = cfg.minRoundTime or 25
	local deployTime = GetGlobalFloat("Realish_DeployTime", 0)
	if CurTime() < deployTime + minTime then return end

	for teamID = 0, 1 do
		if heroPickedThisRound[teamID] then continue end
		for _, ply in player.Iterator() do
			if ply:Team() ~= teamID then continue end
			if ply.RealishHeroOfferTeam ~= teamID then continue end
			if ply.RealishHeroOfferDeadline > CurTime() then continue end

			ply.RealishHeroOfferTeam = nil
			ply.RealishHeroOfferDeadline = 0
			ply:SetNWFloat("Realish_HeroDeadline", 0)
			ply:SetNWInt("Realish_HeroTeam", -1)
			heroTeamLastTrigger[teamID] = 0

			PickHeroForTeam(teamID, ply)
			if not TeamHasHeroOffer(teamID) then PickHeroForTeam(teamID) end
		end
	end

	for teamID = 0, 1 do
		if heroPickedThisRound[teamID] then continue end
		local otherID = teamID == 0 and 1 or 0
		local lives = round:GetLives(teamID)
		local otherLives = round:GetLives(otherID)
		if lives <= 0 then continue end

		local lowLives = lives < (cfg.lowLivesThreshold or 7)
		local overtake = false
		if otherLives > 0 and lives < otherLives then
			local ratio = otherLives / math.max(lives, 1)
			overtake = ratio >= (cfg.overtakeRatio or 1.5)
		end

		if not (lowLives or overtake) then continue end
		if CurTime() < (heroTeamLastTrigger[teamID] or 0) + (cfg.cooldown or 75) then continue end
		if CountActiveHeroes(teamID) >= (cfg.maxActivePerTeam or 1) then continue end
		if TeamHasHeroOffer(teamID) then continue end

		PickHeroForTeam(teamID)
	end
end

timer.Create(heroCheckTimer, 1, 0, EvaluateHeroTrigger)

local function GetBalancedRealishTeam(skip)
	local atlas = 0
	local revenant = 0

	for _, ply in player.Iterator() do
		if ply == skip then continue end

		local teamID = ply:Team()
		if teamID == 0 then
			atlas = atlas + 1
		elseif teamID == 1 then
			revenant = revenant + 1
		end
	end

	return atlas <= revenant and 0 or 1
end

local function AssignLateJoiner(ply)
	if not IsValid(ply) then return end
	if not IsRealishRound() then return end
	if ply.RealishInitialized and (ply:Team() == 0 or ply:Team() == 1) then return end

	ply:SetupTeam(GetBalancedRealishTeam(ply))
	ply.RealishInitialized = true
	ply:SetNWInt("Realish_Coins", MODE.StartCoins)
	ply.RealishLoadout = GetClassName(ply.RealishLoadout)
	ply.RealishChoices = SanitizeChoices(ply.RealishLoadout, ply.RealishChoices)
	ply.RealishAttachments = SanitizeAttachments(ply.RealishLoadout, ply.RealishChoices, ply.RealishAttachments)
	ply.RealishArmor = ply.RealishArmor or "Light"
	ply.RealishDeployed = false
	ply.RealishSpawnRequested = false
	ply:SetNWBool("RealishNoLoadoutWeight", false)
	ply:SetNWBool("Realish_RevivedAlready", false)
	ResetHeroState(ply)
	ply.RealishKillstreakChoices = ply.RealishKillstreakChoices or {}
	ResetKillstreakRound(ply)
	ply:StripWeapons()
	ply:KillSilent()
	ply:Spectate(OBS_MODE_ROAMING)
	ply.viewmode = 3

	ply:ConCommand("r_cleardecals")

	timer.Simple(0.3, function()
		if not IsValid(ply) then return end
		OpenDeployMenu(ply)
	end)
end

hook.Add("PlayerInitialSpawn", "Realish_AssignLateJoiner", function(ply)
	if not IsRealishRound() then return end

	timer.Simple(0, function()
		AssignLateJoiner(ply)
	end)
end)

hook.Add("PlayerSpawn", "Realish_AssignLateJoinerSpawn", function(ply)
	if not IsRealishRound() then return end

	timer.Simple(0, function()
		AssignLateJoiner(ply)
	end)
end)

local function FadeRemove(ent)
	if not IsValid(ent) or ent.RealishCleanupRemoving then return end

	ent.RealishCleanupRemoving = true
	ent.hg_no_fullbody_remove_gib = true
	ent.override = true
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent:SetColor(Color(255, 255, 255, 255))
	ent:SetNotSolid(true)

	local timerName = "realish_fade_" .. ent:EntIndex()
	timer.Create(timerName, cleanupFadeTime / cleanupSteps, cleanupSteps, function()
		if not IsValid(ent) then timer.Remove(timerName) return end

		local reps = timer.RepsLeft(timerName)
		local alpha = math.floor(255 * reps / cleanupSteps)
		ent:SetColor(Color(255, 255, 255, alpha))

		if reps <= 0 then
			ent:Remove()
		end
	end)
end

local function IsActiveFakeRagdoll(ent)
	if hg and hg.ragdollFake then
		for ply, ragdoll in pairs(hg.ragdollFake) do
			if ragdoll == ent and IsValid(ply) and ply:Alive() then return true end
		end
	end

	local ply = ent.ply or ent:GetNWEntity("ply")
	return IsValid(ply) and ply:Alive() and ply.FakeRagdoll == ent
end

local function CleanupEntities()
	if not IsRealishRound() then return end

	local time = CurTime()

	for _, ply in player.Iterator() do
		ply:ConCommand("r_cleardecals")
	end

	for _, ent in ents.Iterator() do
		if not IsValid(ent) or ent.RealishCleanupRemoving then continue end

		local age = time - (ent.RealishCleanupSpawnTime or ent:GetCreationTime())
		if ent:IsRagdoll() then
			if age >= cleanupRagdollTime and not IsActiveFakeRagdoll(ent) then
				FadeRemove(ent)
			end
		elseif ent:IsWeapon() and age >= cleanupWeaponTime and not IsValid(ent:GetOwner()) then
			FadeRemove(ent)
		end
	end
end

hook.Add("OnEntityCreated", "realish_cleanup", function(ent)
	timer.Simple(0, function()
		if IsValid(ent) then ent.RealishCleanupSpawnTime = CurTime() end
	end)
end)

hook.Add("PlayerDisconnected", "RealishSpawnProtectCleanup", function(ply)
	timer.Remove("RealishSpawnProtect_" .. ply:EntIndex())
end)

hook.Add("ZB_CanLootInventory", "realish_no_player_loot", function(ply, ent, canloot)
	if IsRealishRound() and IsValid(ent) and ent:IsPlayer() then
		return ply, ent, false
	end
end)

local function BlockDrop(ply, wep, newWeapon, vel)
	if IsRealishRound() then return end
	if hg and hg.drop then return hg.drop(ply, wep, newWeapon, vel) end
end

local function RegisterDropBlock()
	concommand.Add("drop", BlockDrop)
	concommand.Add("dropweapon", BlockDrop)
	concommand.Add("-drop", BlockDrop)
	concommand.Add("-dropweapon", BlockDrop)
end

timer.Simple(0, function()
	RegisterDropBlock()
end)

local function RealishHeroOwner(org)
	local owner = org and org.owner
	return IsValid(owner) and owner:IsPlayer() and owner.RealishIsHero and owner or nil
end

local function ApplyRealishSpineBlock(retries)
	if not hg or not hg.organism or not hg.organism.input_list then
		if (retries or 0) < 100 then
			timer.Simple(0.1, function() ApplyRealishSpineBlock((retries or 0) + 1) end)
		end
		return
	end

	local input_list = hg.organism.input_list
	if input_list._realishSpineWrapped then return end
	input_list._realishSpineWrapped = true

	local originalSpine1 = input_list.spine1
	local originalSpine2 = input_list.spine2

	input_list.spine1 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
		if IsRealishRound() then return 0 end
		return originalSpine1(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	end

	input_list.spine2 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
		if IsRealishRound() then return 0 end
		return originalSpine2(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	end

	local arteryFuncs = {"rarmartery", "larmartery", "rlegartery", "llegartery", "spineartery", "arteria"}
	input_list._realishOriginalArteries = input_list._realishOriginalArteries or {}
	for _, name in ipairs(arteryFuncs) do
		local original = input_list[name]
		if original then
			input_list._realishOriginalArteries[name] = original
			input_list[name] = function(org, bone, dmg, dmgInfo, boneindex, dir, hit)
				if IsRealishRound() and RealishHeroOwner(org) then return 0 end
				return original(org, bone, dmg, dmgInfo, boneindex, dir, hit)
			end
		end
	end
end

timer.Simple(0, function()
	ApplyRealishSpineBlock()
end)

local function GiveWeapon(ply, class, clips, noSelect)
	local previous = noSelect and IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() or nil
	local wep = ply:Give(class)
	if noSelect and IsValid(wep) then wep.DontEquipInstantly = true end
	if IsValid(wep) and wep.GetPrimaryAmmoType then
		local maxClip = wep:GetMaxClip1()
		if maxClip > 0 then
			wep:SetClip1(maxClip)
			ply:GiveAmmo(maxClip * (clips or 2), wep:GetPrimaryAmmoType(), true)
		end
	end

	if previous and IsValid(previous) and previous ~= wep then
		ply:SelectWeapon(previous:GetClass())
	end

	return wep
end

function ResetKillstreakState(ply)
	if not IsValid(ply) then return end

	ply.RealishKillstreak = 0
	ply.RealishKillstreakClaimed = {}
	ply.RealishKillstreakPending = nil
	ply:SetNWInt("Realish_Killstreak", 0)
	ply:SetNWString("Realish_KillstreakDone", "")
end

function ResetKillstreakRound(ply)
	if not IsValid(ply) then return end

	ResetKillstreakState(ply)
	ply.RealishKillstreakBest = 0
	ply:SetNWInt("Realish_KillstreakBest", 0)
end

local function SyncKillstreakClaimed(ply)
	if not IsValid(ply) then return end

	local claimed = ply.RealishKillstreakClaimed
	if not claimed then return end

	local parts = {}
	for streakID in pairs(claimed) do
		parts[#parts + 1] = streakID
	end

	ply:SetNWString("Realish_KillstreakDone", table.concat(parts, ","))
end

local function GrantKillstreakReward(ply, streakID)
	local data = RealishKillstreaks and RealishKillstreaks[streakID]
	if not data then return end

	ply.RealishKillstreakClaimed = ply.RealishKillstreakClaimed or {}
	if ply.RealishKillstreakClaimed[streakID] then return end
	ply.RealishKillstreakClaimed[streakID] = true
	SyncKillstreakClaimed(ply)

	if data.weapon and data.weapon ~= "" then
		if ply:Alive() then
			GiveWeapon(ply, data.weapon, data.clips or 0, true)
		else
			ply.RealishKillstreakPending = ply.RealishKillstreakPending or {}
			ply.RealishKillstreakPending[#ply.RealishKillstreakPending + 1] = streakID
		end
	end

	if not ply:IsBot() then
		net.Start("realish_killstreak_earned")
			net.WriteString(streakID)
		net.Send(ply)
	end
end

function CheckKillstreaks(ply)
	local choices = ply.RealishKillstreakChoices
	if not choices or #choices == 0 then return end

	local kills = ply.RealishKillstreak or 0
	ply.RealishKillstreakClaimed = ply.RealishKillstreakClaimed or {}

	for _, streakID in ipairs(choices) do
		local data = RealishKillstreaks[streakID]
		if data and not ply.RealishKillstreakClaimed[streakID] and kills >= (data.kills or 5) then
			GrantKillstreakReward(ply, streakID)
		end
	end
end

function MODE:SetLives(teamID, lives)
	SetGlobalInt(teamKeys[teamID], math.max(lives, 0))
end

function MODE:GetLives(teamID)
	return GetGlobalInt(teamKeys[teamID], self.StartLives)
end

function MODE:SyncMenuCamera()
	local points = zb.GetMapPoints("REALISH_MENU_CAMERA")
	local point = points and points[1]

	if point then
		SetGlobalVector("Realish_MenuCamPos", point.pos)
		SetGlobalAngle("Realish_MenuCamAng", point.ang)
	else
		SetGlobalVector("Realish_MenuCamPos", vector_origin)
		SetGlobalAngle("Realish_MenuCamAng", angle_zero)
	end
end

function MODE:CanLaunch()
	return false
end

function MODE:GuiltCheck()
	return 1, true
end

function MODE:Intermission()
	game.CleanUpMap()

	self:SetLives(0, self.StartLives)
	self:SetLives(1, self.StartLives)
	self:SyncMenuCamera()
	ResetHeroRoundState()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		if not ply:IsBot() then
			net.Start("OnlyGet_Appearance")
			net.Send(ply)
		end

		ply.RealishCanRespawn = false
		ply.RealishInitialized = true
		ply.RealishDeployed = false
		ply.RealishSpawnRequested = false
		ply:SetNWBool("RealishNoLoadoutWeight", false)
		ply:SetNWBool("Realish_RevivedAlready", false)
		ply.RealishLoadout = GetClassName(ply.RealishLoadout)
		ply.RealishChoices = SanitizeChoices(ply.RealishLoadout, ply.RealishChoices)
		ply.RealishAttachments = SanitizeAttachments(ply.RealishLoadout, ply.RealishChoices, ply.RealishAttachments)
		ply.RealishArmor = ply.RealishArmor or "Light"
		ply:SetNWInt("Realish_Coins", self.StartCoins)
		ply:SetupTeam(ply:Team() == 0 and 0 or 1)
		ply:StripWeapons()
		ResetHeroState(ply)
		ply.RealishHasBeenHeroThisRound = false
		ResetKillstreakRound(ply)

		if not ply:IsBot() then
			ply:KillSilent()
			ply:Spectate(OBS_MODE_ROAMING)
			ply.viewmode = 3
		end
	end

	SetGlobalFloat("Realish_DeployTime", 0)
	SetGlobalInt("Realish_MusicTrack", math.random(1, self.MusicTrackCount))

	net.Start("realish_start")
	net.Broadcast()
end

function MODE:RoundStart()
	RegisterDropBlock()
	timer.Create(cleanupTimer, cleanupInterval, 0, CleanupEntities)
	SetGlobalFloat("Realish_DeployTime", CurTime() + self.DeployCooldown)
	SetGlobalFloat("Realish_RoundEndTime", CurTime() + self.MaxRoundTime)
	for teamID = 0, 1 do heroPickedThisRound[teamID] = false end

	for _, ply in player.Iterator() do
		if ply:IsBot() then
			ply.RealishDeployed = true
			ply.RealishSpawnRequested = true
			ply:Spawn()
		else
			ply:Freeze(not ply.RealishDeployed)
		end
	end
end

function MODE:GetTeamSpawn()
	return zb.TranslatePointsToVectors(zb.GetMapPoints("REALISH_ATLAS")), zb.TranslatePointsToVectors(zb.GetMapPoints("REALISH_REVENANT"))
end

local function RealishSanitizeAppearance(ply, appearance)
	if not hg.Appearance or not hg.PointShop or not hg.PointShop.Items then return end
	if hg.Appearance.GetAccessToAll(ply) then return end

	local items = hg.PointShop.Items
	local accessories = appearance.AAttachments
	if istable(accessories) then
		for i = 1, #accessories do
			local uid = accessories[i]
			local data = hg.Accessories and hg.Accessories[uid]
			if not data or data.disallowinappearance or (items[uid] and not ply:PS_HasItem(uid)) then
				accessories[i] = ""
			end
		end
	else
		appearance.AAttachments = {}
	end

	local bodygroups = appearance.ABodygroups
	if not istable(bodygroups) then
		appearance.ABodygroups = {}
		return
	end

	local tMdl = hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel] or {}
	for key, value in pairs(bodygroups) do
		local genderList = hg.Appearance.Bodygroups[key]
		genderList = genderList and genderList[tMdl.sex and 2 or 1]
		local bodygroup = genderList and genderList[value]
		if not bodygroup or (bodygroup[2] and bodygroup.ID and items[bodygroup.ID] and not ply:PS_HasItem(bodygroup.ID)) then
			bodygroups[key] = nil
		end
	end
end

local function RealishGetOwnAppearance(ply)
	if not hg.Appearance then return nil end

	local function TrySource(tbl)
		if not istable(tbl) or tbl.RealishForced then return nil end
		if not hg.Appearance.AppearanceValidater(tbl) then return nil end
		local copy = table.Copy(tbl)
		ply.RealishOwnAppearance = copy
		return table.Copy(copy)
	end

	local appearance = TrySource(ply.CachedAppearance)
		or TrySource(ply.RealishOwnAppearance)
		or TrySource(ply.CurAppearance)

	if not appearance then
		appearance = hg.Appearance.GetRandomAppearance()
		ply.RealishOwnAppearance = table.Copy(appearance)
	end

	if not ply:IsBot() and not istable(ply.CachedAppearance) then
		net.Start("OnlyGet_Appearance")
		net.Send(ply)
	end

	return appearance
end

function MODE:ApplyAppearance(ply)
	local role = teamRoles[ply:Team()] or teamRoles[0]
	local appearance = RealishGetOwnAppearance(ply) or {}

	if not (hg.Appearance and hg.Appearance.ForceApplyAppearance) then
		ply:SetPlayerColor(Vector(role[2].r / 255, role[2].g / 255, role[2].b / 255))
		return
	end

	RealishSanitizeAppearance(ply, appearance)
	appearance.AName = appearance.AName or ply:GetNWString("PlayerName", ply:Nick())
	appearance.AAttachments = istable(appearance.AAttachments) and appearance.AAttachments or {}
	appearance.ABodygroups = istable(appearance.ABodygroups) and appearance.ABodygroups or {}
	appearance.AFacemap = appearance.AFacemap or "Default"
	appearance.AClothes = {
		main = "worker",
		pants = "worker",
		boots = "worker",
		hands = "worker"
	}
	appearance.AColor = Color(role[2].r, role[2].g, role[2].b, role[2].a)
	appearance.RealishForced = true

	hg.Appearance.ForceApplyAppearance(ply, appearance)
end

function MODE:GivePlayerEquipment(ply)
	if not IsValid(ply) or not ply:Alive() then return end
	if ply:Team() ~= 0 and ply:Team() ~= 1 then return end
	if not ply.RealishDeployed then return end

	local teamID = ply:Team()
	local loadout = GetClassName(ply.RealishLoadout)
	local choices = SanitizeChoices(loadout, ply.RealishChoices)
	local attachments = SanitizeAttachments(loadout, choices, ply.RealishAttachments)
	local armor = ply.RealishArmor or "Light"
	local role = teamRoles[teamID]
	ply.RealishLoadout = loadout
	ply.RealishChoices = choices
	ply.RealishAttachments = attachments
	ply:SetNWBool("RealishNoLoadoutWeight", true)

	if ply.RealishIsHero then
		local hero = RealishHeroes and ply.RealishHeroChoice and RealishHeroes[ply.RealishHeroChoice]
		if hero then
			armor = hero.armor or "Heavy"
		end
		if not ply.RealishHeroLives or ply.RealishHeroLives <= 0 then
			ply.RealishHeroLives = RealishHeroConfig.heroLives or 3
		end
		ply:SetNWBool("Realish_IsHero", true)
		ply:SetNWString("Realish_HeroChoice", ply.RealishHeroChoice or "Strike")
		ply:SetNWInt("Realish_HeroLives", ply.RealishHeroLives)
	end

	self:ApplyAppearance(ply)
	ply:SetPlayerClass()
	zb.GiveRole(ply, role[1], role[2])

	ply:SetSuppressPickupNotices(true)
	ply.noSound = true

	if ply.RealishKillstreakPending then
		local pending = ply.RealishKillstreakPending
		ply.RealishKillstreakPending = nil

		for _, streakID in ipairs(pending) do
			local data = RealishKillstreaks and RealishKillstreaks[streakID]
			if data and data.weapon and data.weapon ~= "" then
				GiveWeapon(ply, data.weapon, data.clips or 0, true)
			end
		end
	end

	if ply.RealishIsHero and RealishHeroes and RealishHeroes[ply.RealishHeroChoice] then
		local hero = RealishHeroes[ply.RealishHeroChoice]
		for _, slot in ipairs(RealishLoadoutSlots or {}) do
			local option = hero[slot.id]
			if option then
				local wep = GiveWeapon(ply, option.class, option.clips)
				if hg.AddAttachmentForce and option.attachments then
					for _, att in ipairs(option.attachments) do
						hg.AddAttachmentForce(ply, wep, att)
					end
				end
			end
		end

		ply:Give("weapon_bandage_sh")
		ply:Give("weapon_tourniquet")

		if hg.AddArmor then
			hg.AddArmor(ply, {"vest1", "nightvision1", "helmet1"})
		end

		ply:SetWalkSpeed(hero.walkSpeed or 110)
		ply:SetRunSpeed(hero.runSpeed or 380)

		ply:Give("weapon_hands_sh")
		ply:SelectWeapon("weapon_hands_sh")

		timer.Simple(0.1, function()
			if not IsValid(ply) then return end
			ply.noSound = false
			ply:SetSuppressPickupNotices(false)
		end)

		return
	end

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		local option = GetSlotOption(loadout, slot.id, choices[slot.id])
		if option then
			local wep = GiveWeapon(ply, option.class, option.clips)
			if hg.AddAttachmentForce then
				for _, att in ipairs(attachments[slot.id] or {}) do
					hg.AddAttachmentForce(ply, wep, att)
				end
			end
		end
	end

	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")

	if hg.AddArmor then
		if armor == "Light" then
			hg.AddArmor(ply, {"vest3"})
		elseif armor == "Heavy" then
			hg.AddArmor(ply, {"vest4", "helmet1"})
		end
	end

	ply:SetWalkSpeed(100)
	ply:SetRunSpeed(350)

	ply:Give("weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	timer.Simple(0.1, function()
		if not IsValid(ply) then return end
		ply.noSound = false
		ply:SetSuppressPickupNotices(false)
	end)
end

function MODE:GiveEquipment()
	timer.Simple(0.1, function()
		for _, ply in player.Iterator() do
			if ply.RealishDeployed then self:GivePlayerEquipment(ply) end
		end
	end)
end

function MODE:PlayerSpawn(ply)
	if zb.ROUND_STATE ~= 1 then return end

	ply.RealishLoadout = GetClassName(ply.RealishLoadout)
	ply.RealishChoices = SanitizeChoices(ply.RealishLoadout, ply.RealishChoices)
	ply.RealishAttachments = SanitizeAttachments(ply.RealishLoadout, ply.RealishChoices, ply.RealishAttachments)
	ply.RealishArmor = ply.RealishArmor or "Light"
	if ply:GetNWInt("Realish_Coins", -1) < 0 then ply:SetNWInt("Realish_Coins", self.StartCoins) end

	if ply:Team() ~= 0 and ply:Team() ~= 1 then
		ply:SetupTeam(GetBalancedRealishTeam(ply))
	else
		ply:SetupTeam(ply:Team())
	end

	if not ply.RealishDeployed then
		if not ply.RealishSpawnRequested then
			ply:KillSilent()
			ply:Spectate(OBS_MODE_ROAMING)
			ply.viewmode = 3
			OpenDeployMenu(ply)
			return
		end

		ply.RealishCanRespawn = false
		ply:StripWeapons()
		ply:Freeze(true)
		ply:SetNWBool("RealishNoLoadoutWeight", false)

		timer.Simple(0.1, function()
			if not IsValid(ply) or CurrentRound().name ~= "realish" then return end

			OpenDeployMenu(ply)
		end)

		return
	end

	ply.RealishCanRespawn = false
	ply.RealishSpawnRequested = false
	ply:SetNWBool("RealishNoLoadoutWeight", true)
	ply:SetNWBool("Realish_RevivedAlready", false)

	timer.Simple(0.1, function()
		if CurrentRound().name ~= "realish" then return end
		if not IsValid(ply) then return end
		self:GivePlayerEquipment(ply)
		RealishApplySpawnProtect(ply)
	end)
end

function MODE:PlayerDeath(ply)
	if zb.ROUND_STATE ~= 1 then return end

	local teamID = ply:Team()
	if teamID ~= 0 and teamID ~= 1 then return end

	if ply.RealishIsHero then
		local cur = ply.RealishHeroLives
		if not isnumber(cur) or cur <= 0 then cur = ply:GetNWInt("Realish_HeroLives", 0) end
		if not isnumber(cur) or cur <= 0 then cur = RealishHeroConfig.heroLives or 3 end
		if cur > 1 then
			local old = cur
			local nxt = cur - 1
			ply.RealishHeroLives = nxt
			ply:SetNWInt("Realish_HeroLives", nxt)
			net.Start("realish_hero_lives_anim")
				net.WriteInt(old, 4)
				net.WriteInt(nxt, 4)
			net.Send(ply)
			ply.RealishDeployed = true
			ply.RealishSpawnRequested = true
			ply.RealishCanRespawn = true
			ply:SetNWBool("RealishNoLoadoutWeight", true)
			ClearHeroOffer(ply)
			local rag = ply:GetNWEntity("RagdollDeath")
			if not IsValid(rag) and IsValid(ply.RagdollDeath) then rag = ply.RagdollDeath end
			if not IsValid(rag) then rag = ply:GetNWEntity("FakeRagdoll") end
			if not IsValid(rag) and IsValid(ply.FakeRagdoll) then rag = ply.FakeRagdoll end
			if not IsValid(rag) and hg and hg.ragdollFake and hg.ragdollFake[ply] and IsValid(hg.ragdollFake[ply]) then rag = hg.ragdollFake[ply] end
			local respawnPos = IsValid(rag) and rag:GetPos() or ply:GetPos()
			local respawnAng = IsValid(rag) and rag:GetAngles() or ply:GetAngles()
			respawnPos = respawnPos + Vector(0, 0, 8)
			ply.RealishHeroRespawnPos = respawnPos
			ply.RealishHeroRespawnAng = respawnAng
			ply.RealishHeroRespawnRag = rag
			timer.Simple(0.15, function()
				if not IsValid(ply) then return end
				if CurrentRound().name ~= "realish" then return end
				if ply:Alive() then return end
				local savedPos = ply.RealishHeroRespawnPos
				local savedAng = ply.RealishHeroRespawnAng
				local savedRag = ply.RealishHeroRespawnRag
				if not IsValid(savedRag) then
					savedRag = ply:GetNWEntity("RagdollDeath")
					if not IsValid(savedRag) and IsValid(ply.RagdollDeath) then savedRag = ply.RagdollDeath end
					if not IsValid(savedRag) then savedRag = ply:GetNWEntity("FakeRagdoll") end
					if not IsValid(savedRag) and IsValid(ply.FakeRagdoll) then savedRag = ply.FakeRagdoll end
				end
				if IsValid(savedRag) then savedPos = savedRag:GetPos() + Vector(0, 0, 8) end
				ply:UnSpectate()
				ply:Spawn()
				if savedPos then
					timer.Simple(0.05, function()
						if IsValid(ply) and ply:Alive() then
							ply:SetPos(savedPos)
							if savedAng then ply:SetAngles(Angle(0, savedAng.y, 0)) end
						end
						if IsValid(savedRag) then
							if savedRag:GetNWEntity("ply") == ply then savedRag:SetNWEntity("ply", NULL) end
							if ply.RagdollDeath == savedRag then ply.RagdollDeath = nil end
							if ply:GetNWEntity("RagdollDeath") == savedRag then ply:SetNWEntity("RagdollDeath", NULL) end
							savedRag.hg_no_fullbody_remove_gib = true
							savedRag.override = true
							savedRag:Remove()
						else
							local lateRag = ply:GetNWEntity("RagdollDeath")
							if IsValid(lateRag) then
								if lateRag:GetNWEntity("ply") == ply then lateRag:SetNWEntity("ply", NULL) end
								lateRag.hg_no_fullbody_remove_gib = true
								lateRag.override = true
								lateRag:Remove()
							end
						end
						if IsValid(ply) then
							ply.RealishHeroRespawnPos = nil
							ply.RealishHeroRespawnAng = nil
							ply.RealishHeroRespawnRag = nil
						end
					end)
				end
			end)
			return
		else
			local old = cur
			ply.RealishHeroLives = 0
			ply:SetNWInt("Realish_HeroLives", 0)
			net.Start("realish_hero_lives_anim")
				net.WriteInt(old, 4)
				net.WriteInt(0, 4)
			net.Send(ply)
			ply.RealishIsHero = false
			ply:SetNWBool("Realish_IsHero", false)
		end
	end

	ResetKillstreakState(ply)

	local lives = self:GetLives(teamID)
	if lives <= 0 then
		ply.RealishCanRespawn = false
		return
	end

	lives = lives - 1
	self:SetLives(teamID, lives)
	ply.RealishCanRespawn = lives > 0
	ply.RealishDeployed = false
	ply.RealishSpawnRequested = false
	ply:SetNWBool("RealishNoLoadoutWeight", false)

	if ply.RealishIsHero then
		ply.RealishIsHero = false
		ply:SetNWBool("Realish_IsHero", false)
		ply:SetNWInt("Realish_HeroLives", 0)
		ply.RealishHeroLives = 0
	end

	RealishClearSpawnProtect(ply)

	timer.Simple(0.1, function()
		if not IsValid(ply) or CurrentRound().name ~= "realish" then return end

		OpenDeployMenu(ply)
	end)
end

function MODE:CanSpawn(ply)
	if zb.ROUND_STATE ~= 1 then return end
	if not IsValid(ply) then return end

	local teamID = ply:Team()
	if teamID ~= 0 and teamID ~= 1 then return end

	return ply.RealishSpawnRequested and self:GetLives(teamID) > 0
end

function MODE:GetAliveCount(teamID)
	local count = 0

	for _, ply in player.Iterator() do
		if ply:Team() == teamID and ply:Alive() and ply.RealishDeployed then
			count = count + 1
		end
	end

	return count
end

function MODE:ShouldRoundEnd()
	if self:GetLives(0) <= 0 and self:GetAliveCount(0) <= 0 then return true end
	if self:GetLives(1) <= 0 and self:GetAliveCount(1) <= 0 then return true end
	if CurTime() >= GetGlobalFloat("Realish_RoundEndTime", math.huge) then return true end
end

function MODE:EndRound(forcedWinner)
	timer.Remove(cleanupTimer)
	for _, ply in player.Iterator() do
		RealishClearSpawnProtect(ply)
	end

	local atlasDead = self:GetLives(0) <= 0 and self:GetAliveCount(0) <= 0
	local revenantDead = self:GetLives(1) <= 0 and self:GetAliveCount(1) <= 0
	local timedOut = CurTime() >= GetGlobalFloat("Realish_RoundEndTime", math.huge)
	local winner = forcedWinner or (atlasDead and 1 or revenantDead and 0 or nil)

	if not forcedWinner and timedOut and not atlasDead and not revenantDead then
		winner = nil
	end

	for _, ply in player.Iterator() do
		ply.RealishCanRespawn = false
		ply.RealishInitialized = false
		ply.RealishDeployed = false
		ply.RealishSpawnRequested = false
		ply:SetNWBool("RealishNoLoadoutWeight", false)
		ResetHeroState(ply)
		ply.RealishHasBeenHeroThisRound = false
		ResetKillstreakRound(ply)

		if winner ~= nil and ply:Team() == winner then
			ply:GiveExp(math.random(15, 30))
			ply:GiveSkill(math.Rand(0.1, 0.15))
		elseif winner ~= nil then
			ply:GiveSkill(-math.Rand(0.05, 0.1))
		end
	end
	for teamID = 0, 1 do heroPickedThisRound[teamID] = false end

	SetGlobalFloat("Realish_RoundEndTime", 0)

	net.Start("realish_end")
	net.Broadcast()
end

local function ForceWin(ply, _, _, teamID)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	if zb.ROUND_STATE ~= 1 then return end
	if not IsRealishRound() then return end

	CurrentRound():EndRound(teamID)
end

concommand.Add("realish_atlaswin", function(ply, _, args)
	ForceWin(ply, _, args, 0)
end)

concommand.Add("realish_revenantwin", function(ply, _, args)
	ForceWin(ply, _, args, 1)
end)

concommand.Add("realish_testhero", function(ply, _, args)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end
	if not IsRealishRound() then return end
	if zb.ROUND_STATE ~= 1 then return end

	local teamID = tonumber(args[1])
	if teamID ~= 0 and teamID ~= 1 then teamID = ply:Team() end
	if teamID ~= 0 and teamID ~= 1 then teamID = 0 end

	heroTeamLastTrigger[teamID] = 0
	heroPickedThisRound[teamID] = false
	if TeamHasHeroOffer(teamID) then return end

	PickHeroForTeam(teamID)
end)

hook.Add("DefibCanTarget", "RealishDefibTeamCheck", function(owner, target, ply)
	if not IsRealishRound() then return end
	if not IsValid(owner) or not owner:IsPlayer() then return end

	local victim = IsValid(ply) and ply or (IsValid(target) and hg.RagdollOwner and hg.RagdollOwner(target)) or nil
	if not IsValid(victim) or not victim:IsPlayer() then return end

	local ownerTeam = owner:Team()
	if ownerTeam ~= 0 and ownerTeam ~= 1 then return end
	if victim:Team() ~= ownerTeam then return false end
	if victim:GetNWBool("Realish_RevivedAlready", false) then return false end
end)

hook.Add("DefibOnAttached", "RealishReviveIncapacitated", function(defib, owner, target, ply, getTarget, uses)
	if not IsRealishRound() then return end

	local victimPly = IsValid(ply) and ply or nil
	if not IsValid(victimPly) and IsValid(target) then
		victimPly = hg.RagdollOwner and hg.RagdollOwner(target) or nil
	end
	if IsValid(victimPly) and victimPly:GetNWBool("Realish_RevivedAlready", false) then return end

	local org
	if IsValid(target) and target:IsRagdoll() and target.organism then
		org = target.organism
	elseif IsValid(ply) and ply.organism then
		org = ply.organism
	elseif IsValid(target) and target.organism then
		org = target.organism
	end
	if not org then return end
	if not org.incapacitated then return end

	if hg and hg.DefibReviveIncapacitated then
		hg.DefibReviveIncapacitated(defib, owner, ply, getTarget, uses)
		if IsValid(victimPly) then victimPly:SetNWBool("Realish_RevivedAlready", true) end
		return true
	end
end)

local function SendHitNotify(ply, kind, victimName)
	if not IsValid(ply) or not ply:IsPlayer() or ply:IsBot() then return end

	net.Start("realish_hit_notify")
		net.WriteString(kind)
		net.WriteString(victimName or "")
	net.Send(ply)
end

local function GetVictimName(victim)
	if not IsValid(victim) then return "" end
	return victim:GetNWString("PlayerName", victim:Nick())
end

local function GetTopRealishDamager(victim)
	local damageBy = victim.RealishDamageBy
	if not damageBy then return end

	local topPly
	local topAmt = 0

	for att, amt in pairs(damageBy) do
		if IsValid(att) and att:IsPlayer() and att ~= victim and att:Team() ~= victim:Team() and amt > topAmt then
			if att:Team() == 0 or att:Team() == 1 then
				topAmt = amt
				topPly = att
			end
		end
	end

	return topPly
end

hook.Add("HomigradDamage", "RealishTrackDamage", function(victim, dmgInfo)
	if not IsRealishRound() then return end

	local vply
	if IsValid(victim) and victim:IsPlayer() then
		vply = victim
	elseif IsValid(victim) and victim:IsRagdoll() and hg and hg.RagdollOwner then
		vply = hg.RagdollOwner(victim)
	end
	if not IsValid(vply) or not vply:IsPlayer() then return end
	if vply:Team() ~= 0 and vply:Team() ~= 1 then return end

	local att = dmgInfo:GetAttacker()
	if not IsValid(att) or not att:IsPlayer() then
		att = vply:GetPhysicsAttacker()
	end
	if not IsValid(att) or not att:IsPlayer() then return end
	if att == vply then return end
	if att:Team() ~= 0 and att:Team() ~= 1 then return end

	vply.RealishDamageBy = vply.RealishDamageBy or {}
	vply.RealishDamageBy[att] = (vply.RealishDamageBy[att] or 0) + dmgInfo:GetDamage()
end)

hook.Add("PlayerSpawn", "RealishResetDamageTracker", function(ply)
	if not IsValid(ply) then return end
	ply.RealishDamageBy = {}
	ply.RealishWasIncap = false
	ply.RealishTakedownSent = false
end)

local function RealishPartialHealHero(ply)
	if not IsValid(ply) or not ply:Alive() then return end
	if not ply.RealishIsHero then return end

	local org = ply.organism or ply.new_organism
	if not org then return end

	local healFrac = 0.35
	local function reduce(val)
		if not isnumber(val) then return val end
		return math.max(val - val * healFrac, 0)
	end

	org.spine1 = reduce(org.spine1 or 0)
	org.spine2 = reduce(org.spine2 or 0)
	org.spine3 = reduce(org.spine3 or 0)
	org.skull = reduce(org.skull or 0)
	org.chest = reduce(org.chest or 0)
	org.pelvis = reduce(org.pelvis or 0)
	org.brain = reduce(org.brain or 0)
	org.brainFrontal = reduce(org.brainFrontal or 0)
	org.brainParietal = reduce(org.brainParietal or 0)
	org.brainTemporal = reduce(org.brainTemporal or 0)
	org.brainOccipital = reduce(org.brainOccipital or 0)
	org.brainHemorrhage = reduce(org.brainHemorrhage or 0)
	org.brainBleedRate = reduce(org.brainBleedRate or 0)
	org.eyeL = reduce(org.eyeL or 0)
	org.eyeR = reduce(org.eyeR or 0)
	org.liver = reduce(org.liver or 0)
	org.intestines = reduce(org.intestines or 0)
	org.heart = reduce(org.heart or 0)
	org.stomach = reduce(org.stomach or 0)

	org.lungsR = org.lungsR or {0, 0}
	org.lungsL = org.lungsL or {0, 0}
	org.lungsR[1] = reduce(org.lungsR[1] or 0)
	org.lungsL[1] = reduce(org.lungsL[1] or 0)
	org.lungsR[2] = reduce(org.lungsR[2] or 0)
	org.lungsL[2] = reduce(org.lungsL[2] or 0)

	org.lleg = reduce(org.lleg or 0)
	org.rleg = reduce(org.rleg or 0)
	org.larm = reduce(org.larm or 0)
	org.rarm = reduce(org.rarm or 0)

	org.pain = reduce(org.pain or 0)
	org.painadd = reduce(org.painadd or 0)
	org.avgpain = reduce(org.avgpain or 0)
	org.shock = reduce(org.shock or 0)
	org.disorientation = reduce(org.disorientation or 0)
	org.bleed = reduce(org.bleed or 0)
	org.internalBleed = reduce(org.internalBleed or 0)

	org.rarmartery = reduce(org.rarmartery or 0)
	org.larmartery = reduce(org.larmartery or 0)
	org.rlegartery = reduce(org.rlegartery or 0)
	org.llegartery = reduce(org.llegartery or 0)
	org.spineartery = reduce(org.spineartery or 0)
	org.arteria = reduce(org.arteria or 0)

	if isnumber(org.blood) then
		org.blood = math.min((org.blood or 5000) + (5000 - (org.blood or 5000)) * healFrac, 5000)
	end

	ply:SetHealth(math.Clamp(ply:Health() + 25, 0, 100))
end

hook.Add("Org Think", "RealishHeroDisorientationRecovery", function(owner, org, timeValue)
	if not IsRealishRound() then return end
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not owner.RealishIsHero then return end
	if not org then return end
	org.disorientation = 0
	org.pain = 0
	org.avgpain = 0
	org.painadd = 0
	org.shock = 0
	org.immobilization = 0
	org.nearpainlimit = false
	org.hurtadd = 0
	org.painlessen = 0
end, HOOK_MONITOR_LOW)

hook.Add("PreTraceOrganBulletDamage", "RealishHeroBoneHardness", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
	local owner = org and org.owner
	if not IsValid(owner) or not owner:IsPlayer() or not owner.RealishIsHero then return end
	if not IsRealishRound() then return end
	hook_info.dmg = hook_info.dmg * 0.12
end)

local function ApplyRealishHeroBoneResistance(retries)
	if not hg or not hg.organism or not hg.organism.input_list then
		if (retries or 0) < 100 then
			timer.Simple(0.1, function() ApplyRealishHeroBoneResistance((retries or 0) + 1) end)
		end
		return
	end
	local input_list = hg.organism.input_list
	if input_list._realishHeroBoneWrapped then return end
	input_list._realishHeroBoneWrapped = true
	local boneFuncs = {"rarmup","rarmdown","larmup","larmdown","rlegup","rlegdown","llegup","llegdown","spine1","spine2","spine3","skull","jaw","chest","pelvis"}
	for _, name in ipairs(boneFuncs) do
		local orig = input_list[name]
		if orig then
			input_list[name] = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
				if RealishHeroOwner(org) then
					dmg = dmg * 0.14
					if math.random() < 0.92 then
						return 0, VectorRand(-0.2,0.2) / math.Clamp(math.max(dmg,0.4),0.4,0.8)
					end
				end
				return orig(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
			end
		end
	end
end

timer.Simple(0, function() ApplyRealishHeroBoneResistance() end)

hook.Add("PreHomigradDamage", "RealishHeroToughness", function(ply, dmgInfo, hitgroup, ent, harm)
	if not IsRealishRound() then return end
	if not IsValid(ply) or not ply:IsPlayer() then return end
	if not ply.RealishIsHero then return end

	dmgInfo:ScaleDamage(0.5)
end)

hook.Add("PlayerDeath", "RealishKillNotify", function(victim, inflictor, attacker)
	if not IsRealishRound() then return end
	if not IsValid(victim) or not victim:IsPlayer() then return end
	if victim:Team() ~= 0 and victim:Team() ~= 1 then return end

	local damageBy = victim.RealishDamageBy or {}
	victim.RealishWasIncap = false
	victim.RealishTakedownSent = false

	local killer = GetTopRealishDamager(victim)
	if not IsValid(killer) then
		if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim and attacker:Team() ~= victim:Team() and (attacker:Team() == 0 or attacker:Team() == 1) then
			killer = attacker
		end
	end

	if not IsValid(killer) then
		victim.RealishDamageBy = {}
		return
	end

	SendHitNotify(killer, "kill", GetVictimName(victim))

	killer:SetNWInt("Realish_Coins", killer:GetNWInt("Realish_Coins", 0) + 2)

	killer.RealishKillstreak = (killer.RealishKillstreak or 0) + 1
	killer:SetNWInt("Realish_Killstreak", killer.RealishKillstreak)

	if killer.RealishKillstreak > (killer.RealishKillstreakBest or 0) then
		killer.RealishKillstreakBest = killer.RealishKillstreak
		killer:SetNWInt("Realish_KillstreakBest", killer.RealishKillstreakBest)
	end

	killer.RealishKillstreakClaimed = killer.RealishKillstreakClaimed or {}
	CheckKillstreaks(killer)

	if killer.RealishIsHero then
		RealishPartialHealHero(killer)
	end

	for att, _ in pairs(damageBy) do
		if IsValid(att) and att:IsPlayer() and att ~= killer and att:Team() == killer:Team() then
			SendHitNotify(att, "assist", GetVictimName(victim))
		end
	end

	victim.RealishDamageBy = {}
end)

timer.Create("RealishIncapCheck", 0.25, 0, function()
	if not IsRealishRound() then return end

	for _, ply in player.Iterator() do
		if not IsValid(ply) or not ply:Alive() then continue end
		if ply:Team() ~= 0 and ply:Team() ~= 1 then continue end

		local org = ply.organism or ply.new_organism
		if not org then continue end

		local isIncap = org.incapacitated == true
		ply.RealishWasIncap = ply.RealishWasIncap or false

		if isIncap and not ply.RealishWasIncap and not ply.RealishTakedownSent then
			local topPly = GetTopRealishDamager(ply)
			if IsValid(topPly) then
				SendHitNotify(topPly, "takedown", GetVictimName(ply))
			end
			ply.RealishTakedownSent = true
		elseif not isIncap then
			ply.RealishTakedownSent = false
		end

		ply.RealishWasIncap = isIncap
	end
end)

local function RealishShouldBlockDamage(ent, dmgInfo)
	if not IsRealishRound() then return false end

	local att = dmgInfo:GetAttacker()
	if not IsValid(att) or not att:IsPlayer() then return false end
	if att:Team() ~= 0 and att:Team() ~= 1 then return false end

	local vply = ent
	if IsValid(vply) and vply:IsRagdoll() and hg and hg.RagdollOwner then
		vply = hg.RagdollOwner(vply)
	elseif not (IsValid(vply) and vply:IsPlayer()) then
		return false
	end

	if not IsValid(vply) or not vply:IsPlayer() then return false end
	if vply:Team() ~= 0 and vply:Team() ~= 1 then return false end
	if att == vply then return false end

	return att:Team() == vply:Team()
end

hook.Add("EntityTakeDamage", "RealishSpawnProtect", function(ent, dmgInfo)
	if not IsRealishRound() then return end
	local vply = ent
	if IsValid(vply) and vply:IsRagdoll() and hg and hg.RagdollOwner then
		vply = hg.RagdollOwner(vply)
	elseif not (IsValid(vply) and vply:IsPlayer()) then
		return
	end
	if not IsValid(vply) or not vply:IsPlayer() then return end
	if (vply.RealishSpawnProtectUntil or 0) > CurTime() then
		dmgInfo:SetDamage(0)
		return true
	end
	local att = dmgInfo:GetAttacker()
	if IsValid(att) and att:IsPlayer() and (att.RealishSpawnProtectUntil or 0) > CurTime() then
		dmgInfo:SetDamage(0)
		return true
	end
end, -15)

hook.Add("EntityTakeDamage", "RealishBlockTeamDamage", function(ent, dmgInfo)
	if RealishShouldBlockDamage(ent, dmgInfo) then
		dmgInfo:SetDamage(0)
		return true
	end
end, -10)

hook.Add("EntityTakeDamage", "RealishHeroResistance", function(ent, dmgInfo)
	if not IsRealishRound() then return end
	if RealishHeroScaledDmg[dmgInfo] then return end

	local vply = ent
	if IsValid(vply) and vply:IsRagdoll() and hg and hg.RagdollOwner then
		vply = hg.RagdollOwner(vply)
	elseif not (IsValid(vply) and vply:IsPlayer()) then
		return
	end

	if not IsValid(vply) or not vply:IsPlayer() then return end
	if not vply.RealishIsHero then return end

	local hero = RealishHeroes and vply.RealishHeroChoice and RealishHeroes[vply.RealishHeroChoice]
	if not hero or not hero.damageResist then return end

	dmgInfo:ScaleDamage(hero.damageResist)
	RealishHeroScaledDmg[dmgInfo] = true
end, -20)

net.Receive("realish_loadout", function(_, ply)
	if CurrentRound().name ~= "realish" then return end

	local loadout = net.ReadString()
	local armor = net.ReadString()
	local choices = {}
	local attachments = {}
	local count = net.ReadUInt(4)

	for i = 1, count do
		local slotID = net.ReadString()
		choices[slotID] = net.ReadString()
		attachments[slotID] = {}

		for j = 1, net.ReadUInt(4) do
			attachments[slotID][#attachments[slotID] + 1] = net.ReadString()
		end
	end

	loadout = GetClassName(loadout)
	choices = SanitizeChoices(loadout, choices)
	if not armors[armor] then return end

	ply.RealishLoadout = loadout
	ply.RealishChoices = choices
	ply.RealishAttachments = SanitizeAttachments(loadout, choices, attachments)
	ply.RealishArmor = armor
end)

net.Receive("realish_hero_choice", function(_, ply)
	if CurrentRound().name ~= "realish" then return end
	local heroID = net.ReadString()
	if not RealishHeroes or not RealishHeroes[heroID] then return end

	ply.RealishHeroChoice = heroID
	ply:SetNWString("Realish_HeroChoice", heroID)
end)

net.Receive("realish_killstreak_choice", function(_, ply)
	if CurrentRound().name ~= "realish" then return end
	if ply.RealishKillstreakNextChoice and CurTime() < ply.RealishKillstreakNextChoice then return end
	ply.RealishKillstreakNextChoice = CurTime() + 0.25

	local count = math.min(net.ReadUInt(4), RealishKillstreakConfig and RealishKillstreakConfig.maxPicks or 3)
	local choices = {}

	for i = 1, count do
		local streakID = net.ReadString()
		if RealishKillstreaks[streakID] and not table.HasValue(choices, streakID) then
			choices[#choices + 1] = streakID
		end
	end

	ply.RealishKillstreakChoices = choices
	CheckKillstreaks(ply)
end)

net.Receive("realish_request_spawn", function(_, ply)
	local round = CurrentRound()
	if round.name ~= "realish" then return end
	if not CanDeployNow(ply, round) then return end
	if not TryBuyArmor(ply) then return end

	ply.RealishDeployed = true
	ply.RealishSpawnRequested = true
	ply:Freeze(false)

	if ply:Alive() then
		round:GivePlayerEquipment(ply)
	else
		ply:UnSpectate()
		ply:Spawn()
	end

	net.Start("realish_deployed")
	net.Send(ply)

	timer.Simple(1, function()
		if not IsValid(ply) or not ply:Alive() then return end
		if CurrentRound().name ~= "realish" then return end

		for _, wep in ipairs(ply:GetWeapons()) do
			if wep.ishgweapon and wep.attachments and wep.SyncAtts then
				wep:SyncAtts()
			end
		end
	end)
end)

local function PlayerHasActiveHeroOffer(ply)
	if not IsValid(ply) then return false end
	if ply.RealishHeroOfferTeam ~= ply:Team() then return false end
	if ply.RealishHeroOfferDeadline <= CurTime() then return false end
	return true
end

net.Receive("realish_hero_spawn", function(_, ply)
	local round = CurrentRound()
	if round.name ~= "realish" then return end
	if not IsRealishRound() then return end
	if not PlayerHasActiveHeroOffer(ply) then
		net.Start("realish_hit_notify")
			net.WriteString("hero_denied")
			net.WriteString("")
		net.Send(ply)
		return
	end
	if not CanDeployNow(ply, round) then return end
	local teamID = ply:Team()
	if heroPickedThisRound[teamID] then
		net.Start("realish_hit_notify")
			net.WriteString("hero_denied")
			net.WriteString("")
		net.Send(ply)
		return
	end
	if CountActiveHeroes(teamID) >= (RealishHeroConfig.maxActivePerTeam or 1) then
		net.Start("realish_hit_notify")
			net.WriteString("hero_denied")
			net.WriteString("")
		net.Send(ply)
		return
	end
	if ply.RealishHasBeenHeroThisRound then
		net.Start("realish_hit_notify")
			net.WriteString("hero_denied")
			net.WriteString("")
		net.Send(ply)
		return
	end

	ply.RealishIsHero = true
	ply.RealishHeroOfferTeam = nil
	ply.RealishHeroOfferDeadline = 0
	ply:SetNWFloat("Realish_HeroDeadline", 0)
	ply:SetNWInt("Realish_HeroTeam", -1)
	ply:SetNWBool("Realish_IsHero", true)
	ply:SetNWString("Realish_HeroChoice", ply.RealishHeroChoice or "Strike")
	ply.RealishHeroLives = RealishHeroConfig.heroLives or 3
	ply:SetNWInt("Realish_HeroLives", ply.RealishHeroLives)
	ply.RealishHasBeenHeroThisRound = true
	heroPickedThisRound[teamID] = true

	ply.RealishDeployed = true
	ply.RealishSpawnRequested = true
	ply:Freeze(false)

	if ply:Alive() then
		round:GivePlayerEquipment(ply)
	else
		ply:UnSpectate()
		ply:Spawn()
	end

	net.Start("realish_deployed")
	net.Send(ply)

	timer.Simple(1, function()
		if not IsValid(ply) or not ply:Alive() then return end
		if CurrentRound().name ~= "realish" then return end

		for _, wep in ipairs(ply:GetWeapons()) do
			if wep.ishgweapon and wep.attachments and wep.SyncAtts then
				wep:SyncAtts()
			end
		end
	end)
end)
