local SUMMARY_MAX = 3
local SUMMARY_CLEAR_DELAY = 4
local SUMMARY_LIFETIME = 16
local SUMMARY_POST_ROUND = SUMMARY_CLEAR_DELAY + 10.75
local SUMMARY_MEDAL_XP = 10
local SUMMARY_MVP_XP_MULT = 5

if SERVER then
	util.AddNetworkString("rem_roundsummary")

	local function SyncHeadshots(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply:SetNWInt("Headshots", tonumber(ply:GetPData("Headshots", 0)) or 0)
	end

	hook.Add("PlayerInitialSpawn", "rem_headshots_load", function(ply)
		timer.Simple(0, function() SyncHeadshots(ply) end)
	end)

	local MELEE = {
		["weapon_hammer"] = true,
		["weapon_brick"] = true,
		["weapon_pocketknife"] = true,
		["weapon_bat"] = true,
		["weapon_leadpipe"] = true,
		["weapon_hg_extinguisher"] = true,
		["weapon_hg_crowbar"] = true,
		["weapon_hatchet"] = true,
		["weapon_hg_axe"] = true,
		["weapon_hg_machete"] = true,
		["weapon_hg_sledgehammer"] = true,
		["hg_brassknuckles"] = true,
		["weapon_hg_spear"] = true,
		["weapon_hg_spear_pro"] = true,
		["weapon_hands_sh"] = true,
	}

	local function IsMeleeKill(ply)
		local wep = IsValid(ply) and ply:GetActiveWeapon()
		if not IsValid(wep) then return false end
		if MELEE[wep:GetClass()] then return true end
		if wep.ismelee2 then return true end
		if wep.Base == "weapon_melee" then return true end
		return false
	end

	local function WeaponType(ply)
		local wep = IsValid(ply) and ply:GetActiveWeapon()
		if not IsValid(wep) then return "bare hands" end
		local class = string.lower(wep:GetClass() or "")
		local category = string.lower(wep.Category or "")
		local printName = string.lower(wep.PrintName or "")
		local ammo = string.lower((wep.Primary and wep.Primary.Ammo) or "")
		local info = class .. " " .. category .. " " .. printName .. " " .. ammo
		if class == "weapon_hands" or class == "weapon_hands_sh" or class == "weapon_hg_coolhands" then return "bare hands" end
		if MELEE[class] or wep.ismelee2 or wep.Base == "weapon_melee" then return "melee" end
		if wep.IsPistolHoldType and wep:IsPistolHoldType() then return "pistol" end
		if info:find("shotgun", 1, true) or info:find("gauge", 1, true) or info:find("m590", 1, true) or info:find("spas", 1, true) then return "shotgun" end
		if info:find("lmg", 1, true) or info:find("machine gun", 1, true) or info:find("m249", 1, true) or info:find("rpk", 1, true) then return "lmg" end
		if info:find("smg", 1, true) or info:find("submachine", 1, true) or info:find("mp5", 1, true) or info:find("ump", 1, true) or info:find("vector", 1, true) then return "smg" end
		if info:find("pistol", 1, true) or info:find("revolver", 1, true) or info:find("glock", 1, true) or info:find("deagle", 1, true) or info:find("usp", 1, true) or info:find("9x19", 1, true) or info:find(".45 acp", 1, true) or info:find(".50 action", 1, true) then return "pistol" end
		if info:find("rifle", 1, true) or info:find("sniper", 1, true) or info:find("ak", 1, true) or info:find("ar", 1, true) or info:find("m4", 1, true) or info:find("m16", 1, true) or info:find("fal", 1, true) or info:find("scar", 1, true) or info:find("aug", 1, true) then return "rifle" end
		return "other"
	end

	local NewStats

	local function AddWeaponUse(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply.RSStats = ply.RSStats or NewStats()
		local wt = WeaponType(ply)
		ply.RSStats.weaponCounts[wt] = (ply.RSStats.weaponCounts[wt] or 0) + 1
	end

	local function AddShotFired(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		local ct = CurTime()
		if ply.RSLastShotTrack and ct - ply.RSLastShotTrack < 0.01 then return end
		ply.RSLastShotTrack = ct
		ply.RSStats = ply.RSStats or NewStats()
		ply.RSStats.shotsFired = ply.RSStats.shotsFired + 1
		AddWeaponUse(ply)
	end

	local function AddConsumable(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply.RSStats = ply.RSStats or NewStats()
		ply.RSStats.consumablesConsumed = ply.RSStats.consumablesConsumed + 1
	end

	local function UpdateKarmaStats(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply.RSStats = ply.RSStats or NewStats()
		local cur = tonumber(ply.Karma or (ply.guilt_GetValue and ply:guilt_GetValue()) or 100) or 100
		ply.RSStats.karmaEarned = ply.RSStats.karmaEarned or 0
		ply.RSStats.karmaLost = ply.RSStats.karmaLost or 0
		if ply.RSStats.karmaLast == nil then
			ply.RSStats.karmaStart = cur
			ply.RSStats.karmaLast = cur
			ply.RSStats.karmaCurrent = cur
			return
		end
		local last = tonumber(ply.RSStats.karmaLast or cur) or cur
		local delta = cur - last
		if delta > 0 then
			ply.RSStats.karmaEarned = ply.RSStats.karmaEarned + delta
		elseif delta < 0 then
			ply.RSStats.karmaLost = ply.RSStats.karmaLost - delta
		end
		ply.RSStats.karmaLast = cur
		ply.RSStats.karmaCurrent = cur
	end

	function NewStats()
		return {
			kills = 0,
			headshotKills = 0,
			meleeKills = 0,
			rangedKills = 0,
			traitorKills = 0,
			damageDealt = 0,
			damageTaken = 0,
			headshotHits = 0,
			firstHurtTime = 0,
			deaths = 0,
			diedTime = 0,
			survived = true,
			killedBy = "",
			shotsFired = 0,
			shotsHit = 0,
			kicks = 0,
			buttstockShoves = 0,
			pushes = 0,
			windowsBroken = 0,
			consumablesConsumed = 0,
			karmaStart = nil,
			karmaLast = nil,
			karmaCurrent = nil,
			karmaEarned = 0,
			karmaLost = 0,
			weaponCounts = {},
		}
	end

	local function ResetStats()
		zb.RSRoundStart = CurTime()
		zb.RSSummaryXPDone = false
		zb.RSDeathOrder = {}
		zb.RSKilledMain = nil
		for _, ply in player.Iterator() do
			ply.RSStats = NewStats()
			local karma = tonumber(ply.Karma or (ply.guilt_GetValue and ply:guilt_GetValue()) or 100) or 100
			ply.RSStats.karmaStart = karma
			ply.RSStats.karmaLast = karma
			ply.RSStats.karmaCurrent = karma
			ply.RSLastHit = nil
		end
	end

	hook.Add("ZB_StartRound", "rem_roundsummary_reset", ResetStats)

	hook.Add("HomigradDamage", "rem_roundsummary_dmg", function(victim, dmgInfo, hitgroup, ent, harm)
		if not IsValid(victim) or not victim:IsPlayer() then return end
		local attacker = dmgInfo and dmgInfo:GetAttacker()
		if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

		attacker.RSStats = attacker.RSStats or NewStats()
		victim.RSStats = victim.RSStats or NewStats()

		harm = math.max(harm or 0, 0)
		attacker.RSStats.damageDealt = attacker.RSStats.damageDealt + harm
		victim.RSStats.damageTaken = victim.RSStats.damageTaken + harm
		local wt = WeaponType(attacker)
		local ranged = wt ~= "melee" and wt ~= "bare hands"
		if ranged then
			attacker.RSStats.shotsHit = attacker.RSStats.shotsHit + 1
		end
		AddWeaponUse(attacker)
		if harm > 0 and attacker.RSStats.firstHurtTime <= 0 then attacker.RSStats.firstHurtTime = CurTime() end

		local head = hitgroup == HITGROUP_HEAD
		if head then
			attacker.RSStats.headshotHits = attacker.RSStats.headshotHits + 1
			if ranged then
				local headshots = (tonumber(attacker:GetNWInt("Headshots", attacker:GetPData("Headshots", 0))) or 0) + 1
				attacker:SetPData("Headshots", headshots)
				attacker:SetNWInt("Headshots", headshots)
			end
		end

		victim.RSLastHit = { att = attacker, head = head, melee = IsMeleeKill(attacker), t = CurTime() }
		timer.Simple(0, function()
			UpdateKarmaStats(attacker)
			UpdateKarmaStats(victim)
		end)
	end)

	hook.Add("Player Think", "rem_roundsummary_karma", function(ply)
		if (ply.RSNextKarmaTrack or 0) > CurTime() then return end
		ply.RSNextKarmaTrack = CurTime() + 1
		UpdateKarmaStats(ply)
	end)

	hook.Add("Player_Death", "rem_roundsummary_death", function(victim)
		if not IsValid(victim) or not victim:IsPlayer() then return end

		victim.RSStats = victim.RSStats or NewStats()
		victim.RSStats.deaths = victim.RSStats.deaths + 1
		victim.RSStats.diedTime = CurTime()
		victim.RSStats.survived = false

		zb.RSDeathOrder = zb.RSDeathOrder or {}
		if victim:Team() ~= TEAM_SPECTATOR then
			zb.RSDeathOrder[#zb.RSDeathOrder + 1] = victim
		end

		local lh = victim.RSLastHit
		local killer, head, melee

		if lh and IsValid(lh.att) and lh.att:IsPlayer() and (CurTime() - lh.t) < 20 then
			killer, head, melee = lh.att, lh.head, lh.melee
		else
			local most = 0
			for att, dmg in pairs(zb.HarmDone and zb.HarmDone[victim] or {}) do
				if IsValid(att) and att:IsPlayer() and att ~= victim and dmg > most then
					most, killer = dmg, att
				end
			end
		end

		if IsValid(killer) and killer:IsPlayer() and killer ~= victim then
			victim.RSStats.killedBy = killer.Nick and killer:Nick() or "Unknown"
			killer.RSStats = killer.RSStats or NewStats()
			killer.RSStats.kills = killer.RSStats.kills + 1
			if head then
				killer.RSStats.headshotKills = killer.RSStats.headshotKills + 1
			end
			if melee then
				killer.RSStats.meleeKills = killer.RSStats.meleeKills + 1
			else
				killer.RSStats.rangedKills = killer.RSStats.rangedKills + 1
			end
			if victim.isTraitor then
				killer.RSStats.traitorKills = killer.RSStats.traitorKills + 1
			end
			if victim.MainTraitor then
				zb.RSKilledMain = killer
			end
		end
	end)

	hook.Add("EntityFireBullets", "rem_roundsummary_shots", function(ent, bullet)
		local ply = IsValid(ent) and (ent:IsPlayer() and ent or ent:GetOwner())
		AddShotFired(ply)
	end)

	hook.Add("EntityTakeDamage", "rem_roundsummary_misc", function(ent, dmgInfo)
		local attacker = dmgInfo and dmgInfo:GetAttacker()
		if not IsValid(attacker) or not attacker:IsPlayer() then return end
		attacker.RSStats = attacker.RSStats or NewStats()
		local class = IsValid(ent) and ent:GetClass() or ""
		if class == "func_breakable_surf" or (class == "func_breakable" and ent:GetMaterialType() == MAT_GLASS) then
			ent.RSWindowBreaker = attacker
		end
	end)

	hook.Add("EntityRemoved", "rem_roundsummary_windows", function(ent)
		local class = IsValid(ent) and ent:GetClass() or ""
		if class ~= "func_breakable_surf" and not (class == "func_breakable" and ent:GetMaterialType() == MAT_GLASS) then return end
		local ply = ent.RSWindowBreaker
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply.RSStats = ply.RSStats or NewStats()
		ply.RSStats.windowsBroken = ply.RSStats.windowsBroken + 1
	end)

	local function PatchPushTracker()
		local stored = weapons.GetStored("weapon_hg_coolhands")
		if not stored or stored.RSRoundSummaryPushPatch or not stored.ShoveFront then return end
		local old = stored.ShoveFront
		stored.RSRoundSummaryPushPatch = true
		stored.ShoveFront = function(self, ...)
			local owner = IsValid(self) and self:GetOwner()
			if IsValid(owner) and owner:IsPlayer() then
				owner.RSStats = owner.RSStats or NewStats()
				owner.RSStats.pushes = owner.RSStats.pushes + 1
			end
			return old(self, ...)
		end
	end

	hook.Add("HomigradLegKick", "rem_roundsummary_kicks", function(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end
		ply.RSStats = ply.RSStats or NewStats()
		ply.RSStats.kicks = ply.RSStats.kicks + 1
	end)

	local function PatchConsumableTracker(class)
		local stored = weapons.GetStored(class)
		if not stored or stored.RSRoundSummaryConsumePatch or not stored.Heal then return end
		local old = stored.Heal
		stored.RSRoundSummaryConsumePatch = true
		stored.Heal = function(self, ent, ...)
			local owner = IsValid(self) and self:GetOwner()
			local before = self.Eating or 0
			local ret = old(self, ent, ...)
			if ret and IsValid(owner) and owner:IsPlayer() and before <= 5 and (self.Eating or 0) > 5 then
				AddConsumable(owner)
			end
			return ret
		end
	end

	local function PatchGunBaseTracker()
		local stored = weapons.GetStored("homigrad_base")
		if not stored or stored.RSRoundSummaryGunPatch then return end
		stored.RSRoundSummaryGunPatch = true
		if stored.PrimaryShoot then
			local oldShoot = stored.PrimaryShoot
			stored.PrimaryShoot = function(self, ...)
				local owner = IsValid(self) and self:GetOwner()
				if SERVER then AddShotFired(owner) end
				return oldShoot(self, ...)
			end
		end
		if stored.Think then
			local oldThink = stored.Think
			stored.Think = function(self, ...)
				local owner = IsValid(self) and self:GetOwner()
				local before = self.GetButtstockAttack and self:GetButtstockAttack() or 0
				local ret = oldThink(self, ...)
				local after = self.GetButtstockAttack and self:GetButtstockAttack() or 0
				if SERVER and IsValid(owner) and owner:IsPlayer() and after ~= before and math.abs(after - CurTime()) < 0.08 and (owner.RSLastButtstockTrack or 0) ~= after then
					owner.RSLastButtstockTrack = after
					owner.RSStats = owner.RSStats or NewStats()
					owner.RSStats.buttstockShoves = owner.RSStats.buttstockShoves + 1
				end
				return ret
			end
		end
	end

	hook.Add("InitPostEntity", "rem_roundsummary_push_patch", function()
		PatchPushTracker()
		PatchConsumableTracker("weapon_bigconsumable")
		PatchConsumableTracker("weapon_smallconsumable")
		PatchGunBaseTracker()
	end)
	timer.Simple(0, function()
		PatchPushTracker()
		PatchConsumableTracker("weapon_bigconsumable")
		PatchConsumableTracker("weapon_smallconsumable")
		PatchGunBaseTracker()
	end)

	local function ActivePlayers()
		local t = {}
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			ply.RSStats = ply.RSStats or NewStats()
			t[#t + 1] = ply
		end
		return t
	end

	local function BestBy(plys, fn)
		local best, bestv
		for _, ply in ipairs(plys) do
			local v = fn(ply)
			if v and (not bestv or v > bestv) then
				bestv, best = v, ply
			end
		end
		return best, bestv
	end

        local function BestByValue(plys, fn)
                local best, bestv
                for _, ply in ipairs(plys) do
                        local v = fn(ply)
                        if v ~= nil and (bestv == nil or v > bestv) then
                                bestv, best = v, ply
                        end
                end
                return best, bestv
        end

        local function BestByValueExcept(plys, used, fn)
                local best, bestv
                for _, ply in ipairs(plys) do
                        if used[ply] then continue end
                        local v = fn(ply)
                        if v ~= nil and (bestv == nil or v > bestv) then
                                bestv, best = v, ply
                        end
                end
                return best, bestv
        end

	local AWARDS = {
		{ "mvp", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local sc = s.kills * 100 + s.traitorKills * 120 + s.headshotKills * 30 + math.floor(s.damageDealt)
				return sc > 0 and sc or nil
			end)
		end },
		{ "executioner", function()
			if IsValid(zb.RSKilledMain) and zb.RSKilledMain:IsPlayer() then return zb.RSKilledMain, 1 end
		end },
		{ "headhunter", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.headshotKills return v >= 1 and v or nil end)
		end },
		{ "serialkiller", function(plys)
			return BestBy(plys, function(p)
				if not p.isTraitor then return end
				local v = p.RSStats.kills return v >= 2 and v or nil
			end)
		end },
		{ "hero", function(plys)
			return BestBy(plys, function(p)
				if p.isTraitor then return end
				local v = p.RSStats.traitorKills return v >= 1 and v or nil
			end)
		end },
		{ "melee", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.meleeKills return v >= 1 and v or nil end)
		end },
		{ "unstoppable", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.survived and s.kills >= 4 then return s.kills end
			end)
		end },
		{ "berserker", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.kills return v >= 2 and v or nil end)
		end },
		{ "sharpshooter", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.rangedKills return v >= 2 and v or nil end)
		end },
		{ "deadeye", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.kills < 2 or s.headshotKills < 1 then return end
				local v = math.floor((s.headshotKills / s.kills) * 100)
				return v >= 75 and v or nil
			end)
		end },
		{ "untouchable", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.survived and s.kills >= 1 and s.damageTaken <= 0 then return s.kills end
			end)
		end },
		{ "gunslinger", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.rangedKills return v >= 3 and v or nil end)
		end },
		{ "stalker", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.meleeKills return v >= 2 and v or nil end)
		end },
		{ "headhunter2", function(plys)
			return BestBy(plys, function(p) local v = p.RSStats.headshotHits return v >= 3 and v or nil end)
		end },
		{ "bloodthirsty", function(plys)
			return BestBy(plys, function(p) local v = math.floor(p.RSStats.damageDealt) return v >= 80 and v or nil end)
		end },
		{ "warrior", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local v = math.floor(s.damageDealt)
				if s.survived and v >= 120 then return v end
			end)
		end },
		{ "glasscannon", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local v = math.floor(s.damageDealt)
				if v >= 120 and s.damageTaken <= 20 then return v end
			end)
		end },
		{ "punchingbag", function(plys)
			return BestBy(plys, function(p) local v = math.floor(p.RSStats.damageTaken) return v >= 120 and v or nil end)
		end },
		{ "laststand", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				if s.survived and s.kills >= 1 and s.damageTaken >= 80 then return math.floor(s.damageTaken) end
			end)
		end },
		{ "revenant", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local v = math.floor(s.damageDealt)
				if not s.survived and v >= 100 then return v end
			end)
		end },
		{ "savior", function(plys)
			return BestBy(plys, function(p)
				if p.isTraitor then return end
				local v = p.RSStats.traitorKills return v >= 2 and v or nil
			end)
		end },
		{ "menace", function(plys)
			return BestBy(plys, function(p)
				if not p.isTraitor then return end
				local v = p.RSStats.kills return v >= 3 and v or nil
			end)
		end },
		{ "firstblood", function()
			local v = zb.RSDeathOrder and zb.RSDeathOrder[1]
			if IsValid(v) and v:IsPlayer() then return v, 1 end
		end },
		{ "pacifist", function(plys)
			return BestBy(plys, function(p)
				local s = p.RSStats
				local start = zb.RSRoundStart or 0
				if s.survived and s.kills == 0 and s.damageDealt < 1 and CurTime() - start >= 60 and (s.firstHurtTime <= 0 or s.firstHurtTime - start >= 60) then return 1 end
			end)
		end },
	}

	local function MedalXP(key)
		return SUMMARY_MEDAL_XP * (key == "mvp" and SUMMARY_MVP_XP_MULT or 1)
	end

	local function ApplyMedalXP(featured)
		if zb.RSSummaryXPDone then return end
		zb.RSSummaryXPDone = true
		for _, f in ipairs(featured) do
			local ply = f.ply
			f.xpbonus = MedalXP(f.key)
			if IsValid(ply) then
				local instance = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[ply:SteamID64()]
				f.expstart = math.floor(tonumber((instance and instance.experience) or ply.exp or -1) or -1)
				if ply.GiveExp then ply:GiveExp(f.xpbonus) end
			end
		end
	end

	local function NameOf(ply)
		if not IsValid(ply) then return "Unknown" end
		local name = ply.Nick and ply:Nick() or ""
		if (name == "" or name == "Unknown") and ply.GetPlayerName then
			name = ply:GetPlayerName() or name
		end
		if name == "" then name = "Unknown" end
		return name
	end

	local ROLE_MAIN    = Color(225, 30, 30)
	local ROLE_TRAITOR = Color(190, 0, 0)
	local ROLE_HERO    = Color(158, 0, 190)
	local ROLE_POLICE  = Color(45, 90, 255)
	local ROLE_INNO    = Color(0, 120, 190)

	local function RoleFor(ply)
		if ply.MainTraitor then return "Main Murderer", ROLE_MAIN end
		if ply.isTraitor then return "Murderer", ROLE_TRAITOR end
		if ply.isGunner then return "Hero", ROLE_HERO end
		if ply.isPolice then return "Police Officer", ROLE_POLICE end
		return "Bystander", ROLE_INNO
	end

	-- Mirror of MODE:CheckAlivePlayers: traitors win when they are the only
	-- side left standing.
	local function TraitorsWon()
		local tAlive, iAlive = false, false
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			if not ply:Alive() then continue end
			if ply.isTraitor then
				if ply:GetNetVar("handcuffed", false) then continue end
				tAlive = true
			elseif not ply.isPolice then
				if ply.organism and ply.organism.incapacitated then continue end
				iAlive = true
			end
		end
		return tAlive and not iAlive
	end

	local function ComputeFeatured()
		local plys = ActivePlayers()
		local featured, used = {}, {}

                local round = CurrentRound and CurrentRound()
                if round and round.name == "dm" then
                        local dmUsed = {}
                        local winner = BestByValue(plys, function(p)
                                if p:Alive() and not (p.organism and p.organism.incapacitated) then return 1 end
                        end)
                        local topKills, topKillsValue
                        local topHeadshots, topHeadshotsValue

                        if not IsValid(winner) then
                                winner = BestByValue(plys, function(p)
                                        return p.RSStats.kills or 0
                                end)
                        end

                        if IsValid(winner) then
                                dmUsed[winner] = true
                                featured[#featured + 1] = { ply = winner, key = "dm_winner", value = winner.RSStats.kills or 0 }
                        end

                        topKills, topKillsValue = BestByValueExcept(plys, dmUsed, function(p)
                                return p.RSStats.kills or 0
                        end)
                        if IsValid(topKills) then
                                dmUsed[topKills] = true
                                featured[#featured + 1] = { ply = topKills, key = "dm_kills", value = math.floor(topKillsValue or 0) }
                        end

                        topHeadshots, topHeadshotsValue = BestByValueExcept(plys, dmUsed, function(p)
                                return p.RSStats.headshotKills or 0
                        end)
                        if IsValid(topHeadshots) then
                                featured[#featured + 1] = { ply = topHeadshots, key = "dm_headshots", value = math.floor(topHeadshotsValue or 0) }
                        end

                        return featured, NameOf, RoleFor
                end

		-- Traitor victory: the MVP is automatically the traitor with the most kills.
		local haveMVP = false
		if TraitorsWon() then
			local best = BestBy(plys, function(p)
				if not p.isTraitor then return end
				return p.RSStats.kills * 1000 + math.floor(p.RSStats.damageDealt) + 1
			end)
			if IsValid(best) then
				used[best] = true
				haveMVP = true
				featured[#featured + 1] = { ply = best, key = "mvp", value = best.RSStats.kills or 0 }
			end
		end

		for _, award in ipairs(AWARDS) do
			if #featured >= SUMMARY_MAX then break end
			if award[1] == "mvp" and haveMVP then continue end
			local ply, value = award[2](plys)
			if IsValid(ply) and not used[ply] then
				used[ply] = true
				featured[#featured + 1] = { ply = ply, key = award[1], value = math.floor(value or 0) }
			end
		end

		if #featured == 0 then
			for _, ply in ipairs(plys) do
				if #featured >= SUMMARY_MAX then break end
				featured[#featured + 1] = { ply = ply, key = "participant", value = ply.RSStats.kills or 0 }
			end
		end

		return featured, NameOf, RoleFor
	end

	local function PreferredWeapon(stats)
		local best, bestv = "other", -1
		for k, v in pairs(stats.weaponCounts or {}) do
			if v > bestv then
				best, bestv = k, v
			end
		end
		return best
	end

	local function MapHasWindows()
		if #ents.FindByClass("func_breakable_surf") > 0 then return true end
		for _, ent in ipairs(ents.FindByClass("func_breakable")) do
			if ent:GetMaterialType() == MAT_GLASS then return true end
		end
		return false
	end

	local function WriteStats(ply)
		local s = ply.RSStats or NewStats()
		UpdateKarmaStats(ply)
		net.WriteString(s.killedBy or "")
		net.WriteUInt(math.Clamp(s.kills or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.headshotHits or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.kicks or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.buttstockShoves or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.pushes or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.shotsHit or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.shotsFired or 0, 0, 65535), 16)
		net.WriteString(PreferredWeapon(s))
		net.WriteUInt(math.Clamp(s.windowsBroken or 0, 0, 65535), 16)
		net.WriteUInt(math.Clamp(s.consumablesConsumed or 0, 0, 65535), 16)
		net.WriteFloat(tonumber(s.karmaCurrent or ply.Karma or 100) or 100)
		net.WriteFloat(tonumber(s.karmaEarned or 0) or 0)
		net.WriteFloat(tonumber(s.karmaLost or 0) or 0)
	end

	hook.Add("ZB_EndRound", "rem_roundsummary_send", function()
		local featured, NameOf, RoleFor = ComputeFeatured()
		if #featured == 0 then return end
		local first = { featured[1] }
		ApplyMedalXP(first)

		if zb.nextround ~= "coop" then
			local want = CurTime() + math.max(SUMMARY_POST_ROUND, CurrentRound().end_time or 5)
			zb.END_TIME = math.max(zb.END_TIME or 0, want)
		end

		for _, receiver in player.Iterator() do
			receiver.RSStats = receiver.RSStats or NewStats()
			net.Start("rem_roundsummary")
				net.WriteUInt(#first, 4)
				for _, f in ipairs(first) do
				local ply = f.ply
				local model = ""
				local steamid = "0"
				local spec = true

				if IsValid(ply) then
					model = ply:GetModel() or ""
					steamid = ply:IsBot() and "0" or (ply:SteamID64() or "0")
					spec = ply:Team() == TEAM_SPECTATOR
				end
				local hasAppearance = IsValid(ply) and istable(ply.CurAppearance) and ply.CurAppearance.AModel ~= nil
				local exp, skill = -1, 0
				if IsValid(ply) then
					local instance = zb.Experience and zb.Experience.PlayerInstances and zb.Experience.PlayerInstances[ply:SteamID64()]
					exp = math.floor(tonumber(f.expstart or (instance and instance.experience) or ply.exp or -1) or -1)
					skill = tonumber((instance and instance.skill) or ply.skill or 0) or 0
				end

				net.WriteEntity(ply)
				net.WriteString(model)
				net.WriteString(NameOf(ply))
				net.WriteString(steamid)
				net.WriteString(f.key)
				net.WriteUInt(math.Clamp(f.value, 0, 65535), 16)
				net.WriteBool(spec)
				net.WriteTable(hasAppearance and table.Copy(ply.CurAppearance) or {})
				net.WriteString(IsValid(ply) and (ply.PlayerClassName or "") or "")
				net.WriteInt(math.Clamp(exp, -1, 2147483647), 32)
				net.WriteFloat(skill)
				net.WriteInt(math.Clamp(math.floor(f.xpbonus or 0), 0, 2147483647), 32)
				net.WriteBool(hasAppearance)
			end
				net.WriteBool(MapHasWindows())
				WriteStats(receiver)

			net.Send(receiver)
		end
	end)

	return
end

hg = hg or {}
hg.RoundSummaryEnabled = true

surface.CreateFont("Rem_Sum_AwardBig", { font = "ITC Avant Garde Gothic", size = ScreenScale(23), weight = 800, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Award", { font = "ITC Avant Garde Gothic", size = ScreenScale(21), weight = 800, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_NameBig", { font = "ITC Avant Garde Gothic", size = ScreenScale(17), weight = 700, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Name", { font = "ITC Avant Garde Gothic", size = ScreenScale(16), weight = 700, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_DescBig", { font = "ITC Avant Garde Gothic", size = ScreenScale(20), weight = 500, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Desc", { font = "ITC Avant Garde Gothic", size = ScreenScale(16), weight = 500, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_XPBig", { font = "ITC Avant Garde Gothic", size = ScreenScale(17), weight = 600, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_XP", { font = "ITC Avant Garde Gothic", size = ScreenScale(14), weight = 600, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Stat", { font = "ITC Avant Garde Gothic", size = ScreenScale(21), weight = 800, antialias = true, extended = true })
surface.CreateFont("Rem_Sum_Countdown", { font = "ITC Avant Garde Gothic", size = ScreenScale(23), weight = 800, antialias = true, extended = true })

local AWARD_INFO = {
	mvp          = { title = "MVP OF THE ROUND", color = Color(232, 190, 70),  desc = function(v) return "Best player around" end },
    dm_winner    = { title = "MVP OF THE ROUND", color = Color(232, 190, 70),  desc = function(v) return "Deathmatch round winner" end },
    dm_kills     = { title = "MOST KILLS",       color = Color(210, 80, 80),   desc = function(v) return v .. " kill" .. (v == 1 and "" or "s") end },
    dm_headshots = { title = "MOST HEADSHOTS",   color = Color(215, 95, 70),   desc = function(v) return v .. " headshot" .. (v == 1 and "" or "s") end },
	executioner  = { title = "THE EXECUTIONER",  color = Color(150, 20, 20),   desc = function(v) return "Killed the main traitor" end },
	headhunter   = { title = "HEAD HUNTER",      color = Color(200, 55, 55),   desc = function(v) return v .. " headshot kill" .. (v == 1 and "" or "s") end },
	serialkiller = { title = "SERIAL KILLER",    color = Color(170, 25, 25),   desc = function(v) return v .. " victims" end },
	hero         = { title = "THE HERO",         color = Color(70, 130, 220),  desc = function(v) return "Slayed a traitor" end },
	melee        = { title = "BRAWLER", color = Color(210, 120, 40), desc = function(v) return v .. " melee kill" .. (v == 1 and "" or "s") end },
	unstoppable  = { title = "UNSTOPPABLE",      color = Color(230, 120, 45),  desc = function(v) return v .. " kills and survived" end },
	berserker    = { title = "BERSERKER",        color = Color(190, 45, 45),   desc = function(v) return v .. " kills" end },
	sharpshooter = { title = "SHARPSHOOTER",     color = Color(60, 170, 170),  desc = function(v) return v .. " gun kills" end },
	deadeye      = { title = "DEADEYE",          color = Color(232, 190, 70),  desc = function(v) return v .. "% headshots" end },
	untouchable  = { title = "UNTOUCHABLE",      color = Color(90, 200, 220),  desc = function(v) return "Not a scratch" end },
	gunslinger   = { title = "GUNSLINGER",       color = Color(80, 180, 210),  desc = function(v) return v .. " gun kills" end },
	stalker      = { title = "STALKER",          color = Color(160, 80, 45),   desc = function(v) return v .. " melee kills" end },
	headhunter2  = { title = "CRACK SHOT",       color = Color(215, 80, 60),   desc = function(v) return v .. " headshots landed" end },
	bloodthirsty = { title = "BLOODTHIRSTY",     color = Color(150, 20, 20),   desc = function(v) return v .. " damage dealt" end },
	warrior      = { title = "WARRIOR",          color = Color(200, 90, 50),   desc = function(v) return v .. " damage and survived" end },
	glasscannon  = { title = "GLASS CANNON",     color = Color(235, 160, 70),  desc = function(v) return v .. " damage, barely touched" end },
	punchingbag  = { title = "DEMOLISHED",     color = Color(130, 130, 130), desc = function(v) return v .. " damage taken" end },
	laststand    = { title = "LAST STAND",       color = Color(180, 70, 40),   desc = function(v) return v .. " damage taken and lived" end },
	revenant     = { title = "REVENANT",         color = Color(120, 70, 150),  desc = function(v) return v .. " damage before death" end },
	savior       = { title = "SAVIOR",           color = Color(70, 150, 240),  desc = function(v) return v .. " traitors killed" end },
	menace       = { title = "MENACE",           color = Color(190, 35, 35),   desc = function(v) return v .. " victims" end },
	firstblood   = { title = "FIRST TO FALL",    color = Color(120, 120, 120), desc = function(v) return "Died first" end },
	pacifist     = { title = "THE PACIFIST",     color = Color(220, 220, 220), desc = function(v) return "Harmed no one" end },
	participant  = { title = "PARTICIPANT",      color = Color(140, 140, 140), desc = function(v) return "Stood their ground" end },
}

local RS_GradD = Material("vgui/gradient-d")
local RS_GradU = Material("vgui/gradient-u")
local RS_GradR = surface.GetTextureID("vgui/gradient-r")
local RS_GradL = surface.GetTextureID("vgui/gradient-l")
local RS_GradDTex = surface.GetTextureID("vgui/gradient-d")
local RS_BGColor = Color(10, 10, 19, 235)
local RS_BGRight = Color(18, 18, 18, 65)
local RS_BGTop = Color(100, 100, 100, 35)
local RS_FallbackBand = { icon = Material("vgui/mats_jack_awards/10") }
local RS_FallbackMedal = { icon = Material("vgui/mats_jack_awards/pt") }


local POSES = {
	{ seqs = { "idle_all_angry", "idle_all_02", "idle_all_01" },       ang = Angle(0, 0, 0),   cam = Vector(68, 0, 37),  fov = 36, target = Vector(0, 0, 38), hy = 0,    hp = 0 },
	{ seqs = { "idle_suitcase", "idle_all_01", "idle_all_02" },        ang = Angle(0, -16, 0), cam = Vector(70, 7, 35),  fov = 33, target = Vector(0, 0, 37), hy = -0.45, hp = 0 },
	{ seqs = { "idle_all_scared", "idle_all_angry", "idle_all_01" },   ang = Angle(0, 24, 0),  cam = Vector(63, -12, 34), fov = 40, target = Vector(0, 0, 35), hy = 0.25, hp = 0.15 },
	{ seqs = { "idle_all_angry", "idle_all_01", "idle_all_02" },       ang = Angle(0, -9, 0),  cam = Vector(68, 11, 36), fov = 35, target = Vector(0, 0, 38), hy = -0.3, hp = -0.05 },
}

local RS_Container
local RS_Sound

local function StopSummarySound()
	if IsValid(RS_Sound) then RS_Sound:Stop() end
	RS_Sound = nil
end

local function ApplyAppearance(ent, ply)
	if not IsValid(ent) or not IsValid(ply) then return end
	ent:SetSkin(ply:GetSkin())
	if not ply.PlayerClassName or ply.PlayerClassName == "" then
		ent:SetSubMaterial()
		local mats = ply:GetMaterials()
		for i = 1, #mats do
			local sm = ply:GetSubMaterial(i - 1)
			if sm and sm ~= "" then ent:SetSubMaterial(i - 1, sm) end
		end
	end
	for _, bg in ipairs(ent:GetBodyGroups()) do
		ent:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
	end
	local pc = ply.GetPlayerColor and ply:GetPlayerColor() or ply:GetNWVector("PlayerColor", Vector(1, 1, 1))
	ent:SetNWVector("PlayerColor", pc)
	ent.RSapplied = true
end

local function GetAppearanceModelData(appearance)
	if not istable(appearance) or not hg or not hg.Appearance or not hg.Appearance.PlayerModels then return end
	return hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel]
end

local function GetFallbackAppearance()
	if hg and hg.Appearance and istable(hg.Appearance.FallbackAppearanceTable) then
		return table.Copy(hg.Appearance.FallbackAppearanceTable)
	end
	return { AModel = "Male 09", AClothes = { main = "normal", pants = "normal", boots = "normal", hands = "normal" }, AColor = Color(0, 0, 0), AAttachments = {}, ABodygroups = {}, AFacemap = "Default" }
end

local function FindMaterialSlot(mats, mat)
	if not mat then return end
	local want = string.lower(mat)
	for i = 1, #mats do
		if string.lower(mats[i] or "") == want then return i - 1 end
	end
end

local function GetClothesMaterial(modelData, clothes, key)
	local sexID = modelData.sex and 2 or 1
	local clothesSet = hg.Appearance.Clothes and hg.Appearance.Clothes[sexID]
	if not clothesSet then return end
	return clothesSet[clothes[key] or "normal"] or clothesSet.normal
end

local function ApplyAppearanceClothes(ent, modelData, appearance, mats)
	local clothes = istable(appearance.AClothes) and appearance.AClothes or {}
	for key, mat in SortedPairs(modelData.submatSlots or {}) do
		local slot = FindMaterialSlot(mats, mat)
		local clothMat = slot and GetClothesMaterial(modelData, clothes, key)
		if clothMat then ent:SetSubMaterial(slot, clothMat) end
	end
end

local function ApplyAppearanceFacemap(ent, modelData, appearance, mats)
	if not hg.Appearance.FacemapsSlots then return end
	local facemapSlot = hg.Appearance.FacemapsModels and hg.Appearance.FacemapsModels[modelData.mdl]
	if not facemapSlot then return end
	for i = 1, #mats do
		local facemapSet = hg.Appearance.FacemapsSlots[mats[i]]
		local facemap = facemapSet and facemapSet[appearance.AFacemap]
		if facemap then ent:SetSubMaterial(i - 1, facemap) end
	end
end

local function ApplyAppearanceBodygroups(ent, modelData, appearance)
	if not hg.Appearance.Bodygroups then return end
	local bodygroups = istable(appearance.ABodygroups) and appearance.ABodygroups or {}
	for _, bg in ipairs(ent:GetBodyGroups()) do
		local selected = bodygroups[bg.name]
		if not selected then continue end
		local bodygroupData = hg.Appearance.Bodygroups[bg.name]
		local bodygroupSet = bodygroupData and bodygroupData[modelData.sex and 2 or 1] and bodygroupData[modelData.sex and 2 or 1][selected]
		if not bodygroupSet then continue end
		for i = 0, #bg.submodels do
			if bodygroupSet[1] == bg.submodels[i] then
				ent:SetBodygroup(bg.id, i)
				break
			end
		end
	end
end

local function ApplyAppearanceData(ent, ply, appearance, playerClassName)
	if not IsValid(ent) then return false end
	local modelData = GetAppearanceModelData(appearance)
	if not modelData and (not playerClassName or playerClassName == "") then return false end

	local clr = appearance.AColor or color_white
	ent:SetNWVector("PlayerColor", Vector((clr.r or 255) / 255, (clr.g or 255) / 255, (clr.b or 255) / 255))

	if playerClassName and playerClassName ~= "" and not modelData then
		if IsValid(ply) then
			ent:SetSkin(ply:GetSkin())
			ent:SetSubMaterial()
			local mats = ply:GetMaterials()
			for i = 1, #mats do
				local sm = ply:GetSubMaterial(i - 1)
				if sm and sm ~= "" then
					ent:SetSubMaterial(i - 1, sm)
				end
			end
			for _, bg in ipairs(ent:GetBodyGroups()) do
				ent:SetBodygroup(bg.id, ply:GetBodygroup(bg.id))
			end
			local pc = ply.GetPlayerColor and ply:GetPlayerColor() or ply:GetNWVector("PlayerColor", Vector(1, 1, 1))
			ent:SetNWVector("PlayerColor", pc)
		end
		return true
	end

	if ent:GetModel() ~= modelData.mdl then
		ent:SetModel(modelData.mdl)
	end
	ent:SetSubMaterial()

	local mats = ent:GetMaterials()
	ApplyAppearanceClothes(ent, modelData, appearance, mats)
	ApplyAppearanceFacemap(ent, modelData, appearance, mats)
	ApplyAppearanceBodygroups(ent, modelData, appearance)

	return true
end

local function SetupModel(mp, ply, model, pose, spec, appearance, playerClassName)
	local mdl
	if spec then
		mdl = "models/player/group01/male_09.mdl"
	else
		local modelData = GetAppearanceModelData(appearance)
		if not modelData then
			appearance = GetFallbackAppearance()
			modelData = GetAppearanceModelData(appearance)
			mp.RSFallback = true
			playerClassName = ""
		end
		mdl = modelData and modelData.mdl
		if not mdl or not util.IsValidModel(mdl) then return end
	end
	local look = (pose.target - pose.cam):Angle()
	mp:SetModel(mdl)
	mp:SetFOV(pose.fov)
	mp:SetCamPos(pose.cam)
	mp:SetLookAng(look)
	mp:SetAmbientLight(Color(90, 90, 100))
	mp:SetDirectionalLight(BOX_FRONT, Color(200, 200, 205))
	mp:SetDirectionalLight(BOX_TOP, Color(160, 160, 170))
	mp:SetDirectionalLight(BOX_RIGHT, Color(120, 120, 130))
	mp:SetDirectionalLight(BOX_LEFT, Color(110, 110, 125))
	mp:SetDirectionalLight(BOX_BACK, Color(80, 80, 100))

	function mp:LayoutEntity(ent)
		if not spec and not self.RSApplied then
			if ApplyAppearanceData(ent, ply, appearance, playerClassName) then
				self.RSApplied = true
			elseif IsValid(ply) and not ent.RSapplied then
				ApplyAppearance(ent, ply)
				self.RSApplied = true
			end
		end
		if self.RSFallback then
			ent:SetMaterial("models/debug/debugwhite")
			ent:SetColor(color_black)
		end
		ent:SetAngles(pose.ang)
		if not self.RSIdleSeq then
			local seq = -1
			for _, name in ipairs(pose.seqs) do
				local s = ent:LookupSequence(name)
				if s and s >= 0 then seq = s break end
			end
			if seq < 0 then seq = ent:LookupSequence("idle_all_01") or 0 end
			self.RSIdleSeq = seq
			self.RSWalkSeq = ent:LookupSequence("walk_all")
			if not self.RSWalkSeq or self.RSWalkSeq < 0 then
				self.RSWalkSeq = ent:LookupSequence("walk_all_moderate")
			end
			if not self.RSWalkSeq or self.RSWalkSeq < 0 then
				self.RSWalkSeq = self.RSIdleSeq
			end
		end
		local parent = self:GetParent()
		if IsValid(parent) and IsValid(parent.RSCard) then parent = parent.RSCard end
		local walkFrac = 1
		if IsValid(parent) and parent.RSWalkStart then
			walkFrac = math.Clamp((CurTime() - parent.RSWalkStart) / math.max(parent.RSWalkTime or 1, 0.001), 0, 1)
			ent:SetPos(Vector(0, (1 - walkFrac) * (parent.RSWalkDistance or 130), 0))
		else
			ent:SetPos(vector_origin)
		end
		local targetSeq = IsValid(parent) and parent.RSSettled and self.RSIdleSeq or self.RSWalkSeq
		if self.RSActiveSeq ~= targetSeq then
			ent:ResetSequence(targetSeq)
			self.RSActiveSeq = targetSeq
		end
		ent:FrameAdvance(RealFrameTime())
		ent:SetPoseParameter("head_yaw", pose.hy)
		ent:SetPoseParameter("head_pitch", pose.hp)
		if walkFrac < 1 then
			ent:SetPoseParameter("move_x", 1)
			ent:SetPoseParameter("move_y", 0)
		end
		self:SetFOV(pose.fov)
		self:SetCamPos(pose.cam)
		self:SetLookAng(look)
	end

	if spec then
		-- Spectators who somehow got featured show as a solid black silhouette.
		function mp:PreDrawModel()
			render.SuppressEngineLighting(true)
			render.SetColorModulation(0, 0, 0)
		end
		function mp:PostDrawModel()
			render.SetColorModulation(1, 1, 1)
			render.SuppressEngineLighting(false)
		end
		return
	end

	function mp:PreDrawModel()
		if self.RSFallback then
			render.SuppressEngineLighting(true)
			render.SetColorModulation(0, 0, 0)
		end
	end

	function mp:PostDrawModel(ent)
		if self.RSFallback then
			render.SetColorModulation(1, 1, 1)
			render.SuppressEngineLighting(false)
			return
		end
		local acc = IsValid(ply) and ply.GetNetVar and ply:GetNetVar("Accessories") or (istable(appearance) and appearance.AAttachments)
		if istable(acc) and hg and hg.Accessories and DrawAccesories then
			for _, a in ipairs(acc) do
				local d = hg.Accessories[a]
				if d then DrawAccesories(ent, ent, a, d, false, true) end
			end
		end
		ent:SetupBones()
	end
end

local function GetProfileState(ply, expOverride, skillOverride)
	local exp = math.floor(tonumber((expOverride and expOverride >= 0 and expOverride) or (IsValid(ply) and ply.exp) or 0) or 0)
	local skill = tonumber(skillOverride or (IsValid(ply) and ply.skill) or 0) or 0
	local band, medal = RS_FallbackBand, RS_FallbackMedal
	if zb and zb.Experience and zb.Experience.GetAwards then
		local b, m = zb.Experience.GetAwards({ exp = exp, skill = skill })
		band = b or band
		medal = m or medal
	end
	return exp .. " XP", band, medal
end

local function BuildCard(parent, data, slot)
	local sw, sh = ScrW(), ScrH()
	local big = slot == 1
	local pose = POSES[slot] or POSES[1]

	local refW, refH = math.min(sw, 1920), math.min(sh, 1080)
	local scale = math.min(refW / 1920, refH / 1080)
	local w = big and math.floor(refW * 0.29) or math.floor(refW * 0.235)
	local h = big and math.floor(refH * 0.9) or math.floor(refH * 0.82)
	w = math.min(w, math.floor((refW - math.max(math.floor(refW * 0.03), 16) * 2) * (big and 0.38 or 0.31)))
	h = math.min(h, math.floor(sh - math.max(36, 58 * scale)))
	local infoH = big and math.floor(h * 0.34) or math.floor(h * 0.33)

	local info = AWARD_INFO[data.key] or AWARD_INFO.participant
	local accent = info.color

	local card = vgui.Create("DPanel", parent)
	card:SetSize(w, h)
	card:SetAlpha(0)
	card:SetPaintBackground(false)
	card.RSInfo = 0
	card.RSReveal = false
	card.RSSettled = false
	card.Think = function(self)
		local target = self.RSReveal and 1 or 0
		self.RSInfo = Lerp(FrameTime() * 6, self.RSInfo, target)
	end

	card.Paint = function(self, cw, ch)
		surface.SetDrawColor(0, 0, 0, big and 26 or 18)
		surface.DrawRect(0, 0, cw, ch)
		surface.SetDrawColor(255, 255, 255, 110)
		surface.DrawOutlinedRect(0, 0, cw, ch, 1)

		local rise = math.floor(infoH * self.RSInfo)
		if rise > 0 then
			local texH = math.min(ch, math.floor(rise * 2.15))
			local y = ch - texH
			surface.SetDrawColor(4, 4, 6, big and 78 or 64)
			surface.DrawRect(0, ch - rise, cw, rise)
			surface.SetMaterial(RS_GradD)
			surface.SetDrawColor(accent.r, accent.g, accent.b, big and 88 or 74)
			surface.DrawTexturedRect(0, y, cw, texH)
		end
	end

	local modelWrap = vgui.Create("DPanel", card)
	modelWrap:SetSize(w, h)
	modelWrap:SetPos(0, 0)
	modelWrap:SetMouseInputEnabled(false)
	modelWrap.RSCard = card
	modelWrap.Paint = function() end

	local mp = vgui.Create("DModelPanel", modelWrap)
	mp:SetSize(w, h)
	mp:SetPos(0, 0)
	mp:SetMouseInputEnabled(false)
	SetupModel(mp, data.ply, data.model, pose, data.spec, data.appearance, data.playerclass)

	local titleFont = big and "Rem_Sum_AwardBig" or "Rem_Sum_Award"
	local descFont = big and "Rem_Sum_DescBig" or "Rem_Sum_Desc"
	local nameFont = big and "Rem_Sum_NameBig" or "Rem_Sum_Name"
	local xpFont = big and "Rem_Sum_XPBig" or "Rem_Sum_XP"

	local titleWrap = vgui.Create("DPanel", card)
	titleWrap:SetPos(0, math.floor(h * 0.04))
	titleWrap:SetSize(w, math.floor(h * 0.12))
	titleWrap:SetAlpha(0)
	titleWrap.Paint = function(self, tw, th)
		local a = self:GetAlpha()
		draw.SimpleTextOutlined(info.title, titleFont, tw / 2, 0, Color(accent.r, accent.g, accent.b, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 2, Color(0, 0, 0, math.min(230, a)))
		draw.SimpleTextOutlined(string.upper(info.desc(data.value)), descFont, tw / 2, math.floor(th * 0.52), Color(240, 240, 240, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, math.min(210, a)))
	end

	local infoWrap = vgui.Create("DPanel", card)
	infoWrap:SetPos(0, h - infoH)
	infoWrap:SetSize(w, infoH)
	infoWrap:SetAlpha(0)
	infoWrap.Paint = function() end

	local avS = big and math.floor(w * 0.19) or math.floor(w * 0.205)
	local av = vgui.Create("AvatarImage", infoWrap)
	av:SetSize(avS, avS)
	av:SetPos(math.floor(w / 2 - avS / 2), math.floor(infoH * 0.1))
	av:SetMouseInputEnabled(false)
	av:SetSteamID(data.steamid, 64)
	av.PaintOver = function(self, aw, ah)
		surface.SetDrawColor(accent.r, accent.g, accent.b, 255)
		surface.DrawOutlinedRect(0, 0, aw, ah, 2)
	end

	local name = vgui.Create("DLabel", infoWrap)
	name:SetFont(nameFont)
	name:SetTextColor(Color(245, 245, 245))
	name:SetContentAlignment(5)
	name:SetExpensiveShadow(1, Color(0, 0, 0, 230))
	name:SetText(data.name)
	name:SizeToContents()

	local medal = vgui.Create("DPanel", infoWrap)
	medal:SetSize(big and math.floor(w * 0.105) or math.floor(w * 0.12), big and math.floor(w * 0.105) or math.floor(w * 0.12))
	medal.Band = RS_FallbackBand
	medal.Medal = RS_FallbackMedal
	medal.Paint = function(this, mw, mh)
		if this.Band and this.Band.icon then
			surface.SetMaterial(this.Band.icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, mw, mh)
		end
		if this.Medal and this.Medal.icon then
			surface.SetMaterial(this.Medal.icon)
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawTexturedRect(0, 0, mw, mh)
		end
	end

	local xp = vgui.Create("DLabel", infoWrap)
	xp:SetFont(xpFont)
	xp:SetTextColor(Color(220, 220, 220))
	xp:SetContentAlignment(4)
	xp:SetExpensiveShadow(1, Color(0, 0, 0, 225))

	local gainXP = vgui.Create("DLabel", infoWrap)
	gainXP:SetFont(xpFont)
	gainXP:SetTextColor(Color(120, 220, 120))
	gainXP:SetContentAlignment(4)
	gainXP:SetExpensiveShadow(1, Color(0, 0, 0, 225))

	local lastXP, lastSkill = "", nil
	infoWrap.Think = function(self)
		local bonus = math.floor(data.xpbonus or 0)
		local expOverride = data.exp
		local gainAlpha = bonus > 0 and 255 or 0
		if bonus > 0 and data.exp and data.exp >= 0 then
			if self:GetAlpha() > 10 and not self.RSXPStart then self.RSXPStart = CurTime() end
			local elapsed = self.RSXPStart and CurTime() - self.RSXPStart or 0
			local frac = math.Clamp(elapsed / 2.2, 0, 1)
			gainAlpha = 255 * (1 - math.Clamp((elapsed - 2.2) / 0.75, 0, 1))
			frac = 1 - (1 - frac) * (1 - frac)
			expOverride = data.exp + math.floor(bonus * frac)
		end
		local xpText, band, med = GetProfileState(data.ply, expOverride, data.skill)
		local gainText = bonus > 0 and "+" .. bonus or ""
		local skill = tonumber(data.skill or (IsValid(data.ply) and data.ply.skill or 0)) or 0
		if xp:GetText() ~= xpText then
			xp:SetText(xpText)
			xp:SizeToContents()
		end
		if gainXP:GetText() ~= gainText then
			gainXP:SetText(gainText)
			gainXP:SizeToContents()
		end
		gainXP:SetAlpha(gainAlpha)
		if lastXP ~= xpText or lastSkill ~= skill then
			medal.Band = band or RS_FallbackBand
			medal.Medal = med or RS_FallbackMedal
			lastXP = xpText
			lastSkill = skill
		end
		name:SetWide(w - 20)
		name:SetPos(10, av:GetY() + av:GetTall() + math.floor(infoH * 0.06))
		name:SetWrap(false)
		name:SetAutoStretchVertical(false)
		name:SetContentAlignment(5)
		local _, nameH = name:GetContentSize()
		name:SetTall(nameH)
		local medalY = infoH - medal:GetTall() - math.floor(infoH * 0.16)
		local gainGap = gainXP:GetAlpha() > 0 and math.floor(w * 0.015) or 0
		local totalW = medal:GetWide() + math.floor(w * 0.025) + xp:GetWide() + gainGap + (gainXP:GetAlpha() > 0 and gainXP:GetWide() or 0)
		local startX = math.floor(w / 2 - totalW / 2)
		medal:SetPos(startX, medalY)
		xp:SetPos(startX + medal:GetWide() + math.floor(w * 0.025), medalY + math.floor((medal:GetTall() - xp:GetTall()) / 2))
		gainXP:SetPos(xp:GetX() + xp:GetWide() + gainGap, medalY + math.floor((medal:GetTall() - gainXP:GetTall()) / 2))
	end

	card.RSTitle = titleWrap
	card.RSInfoWrap = infoWrap

	return card, w, h
end

local function CloseSummary()
	timer.Remove("rem_roundsummary_show")
	StopSummarySound()
	gui.EnableScreenClicker(false)
	if IsValid(RS_Container) then
		local cont = RS_Container
		for _, card in ipairs(cont.Cards or {}) do
			if IsValid(card) then
				card:MoveTo(card.OffX, card.OffY, 0.6, 0, 0.4)
				card:AlphaTo(0, 0.5, 0)
			end
		end
		cont:AlphaTo(0, 0.65, 0, function()
			if IsValid(cont) then cont:Remove() end
		end)
	end
	RS_Container = nil
end

local function IsRTVActive()
	return zb and zb.IsRTVActive and zb.IsRTVActive()
end

local function ShowSummary(featured)
	if IsRTVActive() then return end

	if IsValid(RS_Container) then RS_Container:Remove() end

	local sw, sh = ScrW(), ScrH()
	local data = featured[1]
	if not data then return end

	local container = vgui.Create("DPanel")
	container:SetSize(sw, sh)
	container:SetPos(0, 0)
	container:SetPaintBackground(false)
	container:SetMouseInputEnabled(false)
	container:SetKeyboardInputEnabled(false)
	container.Cards = {}
	container.OnRemove = function() gui.EnableScreenClicker(false) end
	RS_Container = container
	container:MakePopup()
	container.StartTime = CurTime()
	container.RevealedStats = 0
	container.CountdownStart = 0
	container.LastCountdown = -1
	container.CountPunch = 0

	local bg = vgui.Create("DPanel", container)
	bg:SetSize(sw, sh)
	bg:SetPos(0, 0)
	bg:SetMouseInputEnabled(false)
	bg.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h)
	end
	bg:SetAlpha(0)
	bg:AlphaTo(255, 0.8, 0)
	container.BG = bg

	local stats = data.stats or {}
	local rows = {}
	if stats.killedBy and stats.killedBy ~= "" then rows[#rows + 1] = "killed by: " .. stats.killedBy end
	rows[#rows + 1] = "kills: " .. (stats.kills or 0)
	rows[#rows + 1] = "headshots: " .. (stats.headshots or 0)
	rows[#rows + 1] = "kicks: " .. (stats.kicks or 0)
	rows[#rows + 1] = "buttstock shoves: " .. (stats.buttstockShoves or 0)
	rows[#rows + 1] = "pushes: " .. (stats.pushes or 0)
	local acc = (stats.shotsFired or 0) > 0 and math.floor(((stats.shotsHit or 0) / stats.shotsFired) * 100) or 0
	rows[#rows + 1] = "accuracy: " .. acc .. "%"
	rows[#rows + 1] = "shots fired: " .. (stats.shotsFired or 0)
	rows[#rows + 1] = "preferred weapon type: " .. (stats.weaponType or "other")
	if data.mapHasWindows then rows[#rows + 1] = "windows broken: " .. (stats.windowsBroken or 0) end
	rows[#rows + 1] = "consumables consumed: " .. (stats.consumablesConsumed or 0)
	rows[#rows + 1] = "current karma: " .. math.Round(stats.karmaCurrent or 100, 1)
	rows[#rows + 1] = "karma earned: " .. math.Round(stats.karmaEarned or 0, 1)
	rows[#rows + 1] = "karma lost: " .. math.Round(stats.karmaLost or 0, 1)

	local statPanel = vgui.Create("DPanel", container)
	statPanel:SetPos(math.floor(sw * 0.055), math.floor(sh * 0.08))
	statPanel:SetSize(math.floor(sw * 0.5), math.floor(sh * 0.82))
	statPanel:SetPaintBackground(false)
	statPanel.Rows = rows
	statPanel.Paint = function(self, w, h)
		local now = CurTime()
		local reveal = math.Clamp(math.floor((now - container.StartTime - 0.7) / 0.3) + 1, 0, #self.Rows)
		if reveal > container.RevealedStats then
			container.RevealedStats = reveal
			surface.PlaySound("ui/rem_tik.wav")
		end
		for i = 1, reveal do
			local y = (i - 1) * ScreenScale(21)
			local a = math.Clamp((now - container.StartTime - 0.7 - (i - 1) * 0.3) / 0.18, 0, 1) * 255
			draw.SimpleText(string.upper(self.Rows[i]), "Rem_Sum_Stat", 0, y, Color(235, 235, 235, a), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	local modelFrameW = math.floor(sw * 0.31)
	local modelFrameH = math.floor(sh * 0.88)
	local modelFrame = vgui.Create("DPanel", container)
	modelFrame:SetSize(modelFrameW, modelFrameH)
	modelFrame:SetPos(sw - modelFrameW - math.floor(sw * 0.04), math.floor(sh * 0.06))
	modelFrame:SetAlpha(0)
	modelFrame:SetPaintBackground(false)
	modelFrame.RSSettled = false
	modelFrame.RSWalkStart = CurTime() + 0.2
	modelFrame.RSWalkTime = 1.35
	modelFrame.RSWalkDistance = 145
	modelFrame.Paint = function() end
	modelFrame:AlphaTo(255, 0.35, 0.15)
	timer.Simple(1.55, function()
		if IsValid(modelFrame) then modelFrame.RSSettled = true end
	end)

	local mvpText = vgui.Create("DPanel", modelFrame)
	mvpText:SetSize(modelFrameW, math.floor(sh * 0.13))
	mvpText:SetPos(0, 0)
	mvpText:SetAlpha(0)
	mvpText.Paint = function(self, w, h)
		local a = self:GetAlpha()
		draw.SimpleTextOutlined("MVP OF THE ROUND", "Rem_Sum_Award", w / 2, 0, Color(232, 190, 70, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, a))
		draw.SimpleTextOutlined(string.upper(data.name or "Unknown"), "Rem_Sum_Name", w / 2, ScreenScale(20), Color(245, 245, 245, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 1, Color(0, 0, 0, a))
	end
	mvpText:AlphaTo(255, 0.4, 1.3)

	local modelHolder = vgui.Create("DPanel", modelFrame)
	modelHolder:SetSize(modelFrameW, modelFrameH - math.floor(sh * 0.1))
	modelHolder:SetPos(0, math.floor(sh * 0.08))
	modelHolder:SetPaintBackground(false)
	modelHolder.RSCard = modelFrame

	local mp = vgui.Create("DModelPanel", modelHolder)
	mp:SetSize(modelHolder:GetWide(), modelHolder:GetTall())
	mp:SetPos(0, 0)
	mp:SetMouseInputEnabled(false)
	SetupModel(mp, data.ply, data.model, POSES[1], data.spec, data.appearance, data.playerclass)

	local countdown = vgui.Create("DPanel", container)
	countdown:SetSize(math.floor(sw * 0.34), math.floor(sh * 0.12))
	countdown:SetPos(sw - countdown:GetWide() - math.floor(sw * 0.035), sh - countdown:GetTall() - math.floor(sh * 0.04))
	countdown:SetPaintBackground(false)
	countdown.Paint = function(self, w, h)
		if container.CountdownStart <= 0 then return end
		local left = math.max(0, 6 - math.floor(CurTime() - container.CountdownStart))
		if left ~= container.LastCountdown then
			container.LastCountdown = left
			container.CountPunch = 1
		end
		container.CountPunch = Lerp(FrameTime() * 8, container.CountPunch, 0)
		local scale = 1 + container.CountPunch * 0.08
		local x, y = w, h / 2
		local old = Matrix()
		old:Translate(Vector(x, y, 0))
		old:Scale(Vector(scale, scale, 1))
		old:Translate(Vector(-x, -y, 0))
		cam.PushModelMatrix(old)
		draw.SimpleText("next round in: " .. left, "Rem_Sum_Countdown", w, h / 2, Color(245, 245, 245), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		cam.PopModelMatrix()
	end

	timer.Simple(4, function()
		if not IsValid(container) then return end
		container.CountdownStart = CurTime()
		container.CountPunch = 1
		surface.PlaySound("ui/rem_success.wav")
	end)

	local endFade = vgui.Create("DPanel", container)
	endFade:SetSize(sw, sh)
	endFade:SetPos(0, 0)
	endFade:SetAlpha(0)
	endFade:SetMouseInputEnabled(false)
	endFade.Paint = function(self, w, h)
		surface.SetDrawColor(0, 0, 0, self:GetAlpha())
		surface.DrawRect(0, 0, w, h)
	end
	timer.Simple(10, function()
		if IsValid(endFade) then 
			endFade:AlphaTo(255, 0.75, 0, function()
				if IsValid(statPanel) then statPanel:Remove() end
				if IsValid(modelFrame) then modelFrame:Remove() end
				if IsValid(countdown) then countdown:Remove() end
			end)
		end
	end)

	timer.Create("rem_roundsummary_close", SUMMARY_LIFETIME, 1, function()
		if IsValid(RS_Container) and RS_Container == container then
			CloseSummary()
		end
	end)
end

net.Receive("rem_roundsummary", function()
	local count = net.ReadUInt(4)
	local featured = {}
	for i = 1, count do
		local ply = net.ReadEntity()
		local model = net.ReadString()
		local name = net.ReadString()
		local steamid = net.ReadString()
		local key = net.ReadString()
		local value = net.ReadUInt(16)
		local spec = net.ReadBool()
		local appearance = net.ReadTable()
		local playerclass = net.ReadString()
		local exp = net.ReadInt(32)
		local skill = net.ReadFloat()
		local xpbonus = net.ReadInt(32)
		local hasAppearance = net.ReadBool()
		featured[i] = { ply = ply, model = model, name = name, steamid = steamid, key = key, value = value, spec = spec, appearance = appearance, playerclass = playerclass, exp = exp, skill = skill, xpbonus = xpbonus, hasAppearance = hasAppearance }
	end
	local mapHasWindows = net.ReadBool()
	local stats = {
		killedBy = net.ReadString(),
		kills = net.ReadUInt(16),
		headshots = net.ReadUInt(16),
		kicks = net.ReadUInt(16),
		buttstockShoves = net.ReadUInt(16),
		pushes = net.ReadUInt(16),
		shotsHit = net.ReadUInt(16),
		shotsFired = net.ReadUInt(16),
		weaponType = net.ReadString(),
		windowsBroken = net.ReadUInt(16),
		consumablesConsumed = net.ReadUInt(16),
		karmaCurrent = net.ReadFloat(),
		karmaEarned = net.ReadFloat(),
		karmaLost = net.ReadFloat(),
	}
	for _, data in ipairs(featured) do
		data.stats = stats
		data.mapHasWindows = mapHasWindows
	end

	if count == 0 then return end
	if IsRTVActive() then return end

	timer.Create("rem_roundsummary_show", SUMMARY_CLEAR_DELAY, 1, function()
		if IsRTVActive() then return end
		ShowSummary(featured)
	end)
end)

hook.Add("RoundInfoCalled", "rem_roundsummary_close", function(rnd)
	timer.Simple(0, function()
		if zb and zb.ROUND_STATE == 1 then
			CloseSummary()
		end
	end)
end)

hook.Add("ZB_StartRound", "rem_roundsummary_close_start", CloseSummary)
