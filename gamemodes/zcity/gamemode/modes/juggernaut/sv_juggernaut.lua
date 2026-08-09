local MODE = MODE

MODE.name = "juggernaut"
MODE.PrintName = "Juggernaut"
MODE.start_time = 1
MODE.end_time = 7
MODE.grace_time = 0
MODE.ROUND_TIME = 420
MODE.randomSpawns = true
MODE.shouldfreeze = true
MODE.GuiltDisabled = true
MODE.LootSpawn = false

MODE.VariantMinPlayers = 10
MODE.HealthMul = 3.5
MODE.Variant2HealthMul = 5
MODE.StaminaMul = 3.5
MODE.BerserkStrength = 2 / 1.5

util.AddNetworkString("juggernaut_state")

local damageReduction = CreateConVar("zb_jugg_damage_reduction", "0.5", FCVAR_LUA_SERVER, "Juggernaut damage taken multiplier (1 = normal)")
local bleedMul = CreateConVar("zb_jugg_bleed_mul", "0.35", FCVAR_LUA_SERVER, "Juggernaut bleeding multiplier (lower = less blood loss)")
local roundTime = CreateConVar("zb_jugg_round_time", "420", FCVAR_LUA_SERVER, "Juggernaut survival time (seconds)")
local hunterRespawn = CreateConVar("zb_jugg_hunter_respawn", "5", FCVAR_LUA_SERVER, "Hunter respawn delay (seconds)")

MODE.Variants = {
	[1] = {
		name = "Tagilla",
		minPlayers = 0,
		juggernauts = { { class = "tagilla", loadout = "tagilla_v1" } },
		grunt = "runningnail",
	},
	[2] = {
		name = "Tagilla & Killa",
		minPlayers = 10,
		juggernauts = {
			{ class = "tagilla", loadout = "tagilla_v2" },
			{ class = "killa", loadout = "killa" },
		},
		grunt = "usec",
	},
	[3] = {
		name = "Scream",
		minPlayers = 0,
		juggernauts = { { class = "scream", loadout = "scream" } },
		grunt = "victim",
	},
}

MODE.GruntMelee = {
	"weapon_6x5",
	"weapon_bars_a2607",
	"weapon_combatknife",
	"weapon_hammer",
	"weapon_hg_woodaxe",
	"weapon_hg_mpl40",
	"weapon_buck200knife",
	"weapon_brick",
	"weapon_hg_bottle",
	"weapon_leadpipe",
	"weapon_pan",
}

MODE.GruntUsecSMGs = {
	"weapon_mp5",
	"weapon_mp5k",
	"weapon_mp5sd",
}

local function GiveWeapon(ply, class, mags)
	local wep = ply:Give(class)
	if IsValid(wep) and mags and wep.GetMaxClip1 and wep:GetMaxClip1() > 0 then
		ply:GiveAmmo(wep:GetMaxClip1() * mags, wep:GetPrimaryAmmoType(), true)
	end
	return wep
end

local function IsFury(ply)
	return ply.juggClass == "tagilla"
end

local JUGG_NODROP = {
	weapon_hultafors = true,
	weapon_rpk16 = true,
	weapon_saiga12 = true,
}

local function SetMeleeNoDrop(ply)
	for _, wep in ipairs(ply:GetWeapons()) do
		if wep.Base == "weapon_melee" or wep.ismelee2 or JUGG_NODROP[wep:GetClass()] then
			wep.NoDrop = true
			wep.NoHolster = false
		end
	end
end

local function IsJugRound()
	local round = CurrentRound()
	return round and round.name == "juggernaut"
end

function MODE:GetPlayerCount()
	local count = 0
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		count = count + 1
	end
	return count
end

function MODE:PickVariant()
	local count = self:GetPlayerCount()
	local pool = count >= self.VariantMinPlayers and { 1, 2, 3 } or { 1, 3 }
	return pool[math.random(#pool)]
end

function MODE:GetActiveGruntType()
	local variant = self.variant or 1
	local cfg = self.Variants[variant]
	return cfg and cfg.grunt or "runningnail"
end

local function ApplyHealthBuff(ply)
	if not ply.JuggBaseHealth then ply.JuggBaseHealth = math.max(1, ply:GetMaxHealth()) end
	local mul = (MODE.variant == 2) and MODE.Variant2HealthMul or MODE.HealthMul
	local hp = math.ceil(ply.JuggBaseHealth * mul)
	ply:SetMaxHealth(math.max(100, hp))
	ply:SetHealth(ply:GetMaxHealth())
end

local function ApplyStaminaBuff(org)
	local s = org.stamina
	if not s or s.baseRange then return end
	s.baseRange = s.range
	s.range = s.baseRange * MODE.StaminaMul
	s[1] = s.range
end

local function ClearJuggBuffs(ply)
	if not IsValid(ply) then return end
	ply.JuggBaseHealth = nil
	local org = ply.organism
	if not org then return end
	org.silentBerserk = nil
	org.armorMul = nil
	org.painToleranceMul = nil
	org.NoKnockdown = nil
	org.berserk = 0
	local s = org.stamina
	if s and s.baseRange then
		s.range = s.baseRange
		s.baseRange = nil
		s[1] = math.min(s[1] or s.range, s.range)
	end
end

local function ApplyJuggernautBuffs(ply)
	local org = ply.organism
	if not org then return end

	org.blood = 5000
	org.bleedingmul = math.max(0.1, bleedMul:GetFloat())
	org.recoilmul = 0.6
	org.legstrength = 1.1
	org.meleespeed = 1.15
	org.NoKnockdown = true

	if IsFury(ply) then
		org.berserk = MODE.BerserkStrength
		org.silentBerserk = true
	else
		org.silentBerserk = nil
	end

	if MODE.variant == 2 then
		org.armorMul = 3
		org.painToleranceMul = 2
	else
		org.armorMul = nil
		org.painToleranceMul = nil
	end

	ApplyHealthBuff(ply)
	ApplyStaminaBuff(org)
end

function MODE:GiveJuggLoadout(ply, loadout)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	GiveWeapon(ply, "weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	if loadout == "tagilla_v1" then
		hg.AddArmor(ply, "vest30")
		hg.AddArmor(ply, "helmet31")
		GiveWeapon(ply, "weapon_hultafors")
		GiveWeapon(ply, "weapon_hg_eft_f1")
		GiveWeapon(ply, "weapon_hg_eft_rgd5")
		GiveWeapon(ply, "weapon_morphine")
	elseif loadout == "tagilla_v2" then
		hg.AddArmor(ply, "vest30")
		hg.AddArmor(ply, "helmet31")
		GiveWeapon(ply, "weapon_hg_eft_zarya")
		GiveWeapon(ply, "weapon_saiga12", 2)
		GiveWeapon(ply, "weapon_morphine")
	elseif loadout == "killa" then
		hg.AddArmor(ply, "vest_killa")
		hg.AddArmor(ply, "helmet_killa")
		hg.AddArmor(ply, "visor_killa")
		GiveWeapon(ply, "weapon_rpk16", 2)
		GiveWeapon(ply, "weapon_hg_smokenade")
		GiveWeapon(ply, "weapon_morphine")
	elseif loadout == "scream" then
		GiveWeapon(ply, "weapon_chainsaw")
		GiveWeapon(ply, "weapon_buck200knife")
		GiveWeapon(ply, "weapon_hg_wire")
		GiveWeapon(ply, "weapon_adrenaline")
		GiveWeapon(ply, "weapon_midazolam")
		GiveWeapon(ply, "weapon_taser")
	end

	SetMeleeNoDrop(ply)
end

function MODE:ApplyJuggPersona(ply)
	if not IsValid(ply) then return end
	if MODE.variant ~= 3 then return end

	local mdl = "models/distac/player/ghostface.mdl"
	if not util.IsValidModel(mdl) then return end

	ply:SetModel(mdl)
	if istable(ply.CurAppearance) then ply.CurAppearance.AModel = mdl end
	if istable(ply.CachedAppearance) then ply.CachedAppearance.AModel = mdl end
end

function MODE:GiveGruntLoadout(ply, grunt)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	local hands = GiveWeapon(ply, "weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	if grunt == "runningnail" then
		local melee = self.GruntMelee[math.random(#self.GruntMelee)]
		GiveWeapon(ply, melee)
		ply:SelectWeapon(melee)
	elseif grunt == "usec" then
		hg.AddArmor(ply, "vest7")
		GiveWeapon(ply, "weapon_6x5")
		local smg = self.GruntUsecSMGs[math.random(#self.GruntUsecSMGs)]
		GiveWeapon(ply, smg, 2)
		ply:SelectWeapon(smg)
	end
end

function MODE:CanLaunch()
	return self:GetPlayerCount() >= 2
end

function MODE:Intermission()
	MODE.Juggernauts = {}
	MODE.Juggernaut = nil
	MODE._huntersWon = nil
	MODE._juggernautSurvived = nil
	MODE._juggNames = nil
	game.CleanUpMap()

	self.ROUND_TIME = math.max(60, roundTime:GetInt())
	if hg.UpdateRoundTime then hg.UpdateRoundTime(self.ROUND_TIME) end

	self.variant = self:PickVariant()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply.IsJuggernaut = nil
		ply.juggClass = nil
		ply.juggLoadout = nil
		ClearJuggBuffs(ply)
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end
end

function MODE:RoundStart()
	local variant = self.variant or 1
	local cfg = self.Variants[variant]
	if not cfg then return end

	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
		candidates[#candidates + 1] = ply
	end

	if #candidates < #cfg.juggernauts then
		candidates = {}
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			candidates[#candidates + 1] = ply
		end
	end

	if #candidates == 0 then
		MODE.Juggernauts = {}
		MODE.Juggernaut = nil
		return
	end

	local juggs = {}
	local taken = {}
	local names = {}
	for i, juggClass in ipairs(cfg.juggernauts) do
		local idx = math.random(#candidates)
		local tries = 0
		while taken[idx] and tries < #candidates do
			idx = math.random(#candidates)
			tries = tries + 1
		end
		taken[idx] = true

		local ply = candidates[idx]
		if not IsValid(ply) then continue end
		ply.IsJuggernaut = true
		ply.juggClass = juggClass.class
		ply.juggLoadout = juggClass.loadout
		juggs[#juggs + 1] = ply
		names[#names + 1] = ply:Nick()

		ApplyJuggernautBuffs(ply)
		self:GiveJuggLoadout(ply, juggClass.loadout)
		self:ApplyJuggPersona(ply)
	end

	MODE.Juggernauts = juggs
	MODE.Juggernaut = juggs[1]
	MODE._juggNames = table.concat(names, ", ")

	local grunt = cfg.grunt
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or ply.IsJuggernaut then continue end
		self:GiveGruntLoadout(ply, grunt)
	end

	for _, jugg in ipairs(juggs) do
		zb.GiveRole(jugg, "Juggernaut", Color(190, 20, 20))
	end

	local surviveUntil = CurTime() + self.ROUND_TIME
	net.Start("juggernaut_state")
		net.WriteInt(self.variant or 1, 8)
		net.WriteFloat(surviveUntil)
		net.WriteUInt(#juggs, 4)
		for _, jugg in ipairs(juggs) do
			net.WriteEntity(jugg)
		end
	net.Broadcast()

	PrintMessage(HUD_PRINTTALK, "JUGGERNAUT (" .. cfg.name .. "): " .. MODE._juggNames .. " must survive for " .. math.ceil(self.ROUND_TIME) .. " seconds!")
	PrintMessage(HUD_PRINTTALK, "Everyone else: hunt the Juggernaut down!")
end

function MODE:GiveEquipment()
end

function MODE:PlayerSpawn(ply)
	if not IsValid(ply) or ply:Team() == TEAM_SPECTATOR or zb.ROUND_STATE ~= 1 then return end

	if self:IsJuggernaut(ply) then
		ply.juggClass = ply.juggClass or "tagilla"
		ApplyJuggernautBuffs(ply)
		local variant = self.variant or 1
		self:GiveJuggLoadout(ply, ply.juggLoadout or (self.Variants[variant].juggernauts[1].loadout))
		self:ApplyJuggPersona(ply)
		if IsFury(ply) and MODE.variant ~= 3 then
			ply:SetModel("")
		end
	else
		self:GiveGruntLoadout(ply, self:GetActiveGruntType())
	end
end

function MODE:PlayerDeath(victim, inflictor, attacker)
	if not IsJugRound() or zb.ROUND_STATE ~= 1 then return end
	if not IsValid(victim) then return end

	if self:IsJuggernaut(victim) then
		local newJuggs = {}
		for _, ply in ipairs(self.Juggernauts or {}) do
			if ply ~= victim then newJuggs[#newJuggs + 1] = ply end
		end
		self.Juggernauts = newJuggs
		victim.IsJuggernaut = nil
		ClearJuggBuffs(victim)
		if #newJuggs == 0 then self._huntersWon = true end
		return
	end

	local respawnIn = math.max(1, hunterRespawn:GetFloat())
	timer.Simple(respawnIn, function()
		if not IsValid(victim) or victim:Alive() or victim:Team() == TEAM_SPECTATOR then return end
		if not IsJugRound() or zb.ROUND_STATE ~= 1 then return end
		victim:Spawn()
	end)
end

hook.Add("PlayerDisconnected", "juggernaut_disconnect", function(ply)
	local newJuggs = {}
	local count = 0
	for _, jugg in ipairs(MODE.Juggernauts or {}) do
		if jugg ~= ply then
			newJuggs[#newJuggs + 1] = jugg
			count = count + 1
		end
	end
	MODE.Juggernauts = newJuggs
	MODE.Juggernaut = newJuggs[1]
	if count == 0 then MODE._huntersWon = true end
end)

function MODE:ShouldRoundEnd()
	local anyAlive = false
	for _, jugg in ipairs(self.Juggernauts or {}) do
		if IsValid(jugg) and jugg:Alive() then
			anyAlive = true
			break
		end
	end
	if not anyAlive then
		self._huntersWon = true
		return true
	end
	return nil
end

function MODE:BoringRoundFunction()
	for _, jugg in ipairs(self.Juggernauts or {}) do
		if IsValid(jugg) and jugg:Alive() then
			self._juggernautSurvived = true
			break
		end
	end
end

function MODE:EndRound()
	local names = {}
	for _, jugg in ipairs(self.Juggernauts or {}) do
		if IsValid(jugg) then names[#names + 1] = jugg:Nick() end
	end
	local jName = #names > 0 and table.concat(names, ", ") or (self._juggNames or "The Juggernaut")

	if self._juggernautSurvived then
		PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " SURVIVED! Juggernaut wins!")
		for _, jugg in ipairs(self.Juggernauts or {}) do
			if IsValid(jugg) then
				jugg:GiveExp(math.random(40, 70))
				if jugg.GiveSkill then jugg:GiveSkill(math.Rand(0.15, 0.3)) end
			end
		end
	else
		PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " has been eliminated! Hunters win!")
	end

	self.Juggernauts = {}
	self.Juggernaut = nil
end

function MODE:CanSpawn()
end

function MODE:GetPlySpawn(ply)
end

hook.Add("PreTraceOrganBulletDamage", "juggernaut_resist", function(org, bone, dmg, dmgInfo, box, dir, hit, ricochet, organ, hook_info)
	if not hook_info then return end
	local owner = org and org.owner
	if not IsValid(owner) or not MODE:IsJuggernaut(owner) then return end

	hook_info.dmg = (hook_info.dmg or dmg) * math.max(0.05, damageReduction:GetFloat())
end)

local function JuggernautThink(owner, org, timeValue)
	if not MODE:IsJuggernaut(owner) or not IsJugRound() then return end

	if IsFury(owner) then org.berserk = MODE.BerserkStrength end
	ApplyStaminaBuff(org)

	org.blood = math.Approach(org.blood, 5000, timeValue * 40)

	for i, wound in pairs(org.wounds or {}) do
		wound[1] = math.max(wound[1] - timeValue * 4, 0)
	end
	for i, wound in pairs(org.arterialwounds or {}) do
		wound[1] = math.max(wound[1] - timeValue * 4, 0)
	end
	org.internalBleed = math.max((org.internalBleed or 0) - timeValue * 4, 0)

	local heal = timeValue * 4
	org.pain = math.Approach(org.pain or 0, 0, heal)
	org.painadd = math.Approach(org.painadd or 0, 0, heal)
	org.avgpain = math.Approach(org.avgpain or 0, 0, heal)
	org.shock = math.Approach(org.shock or 0, 0, heal)
	org.immobilization = math.Approach(org.immobilization or 0, 0, heal)
	org.fear = math.Approach(org.fear or 0, 0, heal)
	org.heartStrain = math.max((org.heartStrain or 0) - timeValue, 0)
end

hook.Add("Org Think", "juggernaut_regen", function(owner, org, timeValue)
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	JuggernautThink(owner, org, timeValue)
end)

MsgC(Color(0, 255, 0), "[JUGG] sv_juggernaut.lua loaded. CanLaunch=" .. tostring(MODE.CanLaunch) .. ", RoundStart=" .. tostring(MODE.RoundStart) .. "\n")