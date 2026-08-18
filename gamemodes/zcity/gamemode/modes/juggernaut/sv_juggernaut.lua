local MODE = MODE

MODE.name = "juggernaut"
MODE.PrintName = "Juggernaut"
MODE.start_time = 6.0
MODE.end_time = 7
MODE.grace_time = 0
MODE.ROUND_TIME = 420
MODE.randomSpawns = true
MODE.shouldfreeze = false
MODE.GuiltDisabled = true
MODE.LootSpawn = false

MODE.VariantMinPlayers = 10
MODE.HealthMul = 2.0
MODE.Variant2HealthMul = 5.0
MODE.Variant3HealthMul = 3.5
MODE.StaminaMul = 3.5
MODE.BerserkStrength = 0

util.AddNetworkString("juggernaut_state")
util.AddNetworkString("juggernaut_variant")
util.AddNetworkString("juggernaut_end")

local damageReduction = CreateConVar("zb_jugg_damage_reduction", "1.0", FCVAR_LUA_SERVER, "Juggernaut damage taken multiplier (1 = normal)")
local bleedMul = CreateConVar("zb_jugg_bleed_mul", "0.7", FCVAR_LUA_SERVER, "Juggernaut bleeding multiplier (lower = less blood loss)")
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
	[4] = {
		name = "Jacket",
		minPlayers = 0,
		juggernauts = { { class = "jacket", loadout = "jacket" } },
		grunt = "runningnail",
	},
}

MODE.GruntMelee = {
	"weapon_6x5",
	"weapon_bars_a2607",
	"weapon_combatknife",
	"weapon_hammer",
	"weapon_hg_woodaxe",
	"weapon_hg_mpl40",
	"weapon_brick",
	"weapon_hg_bottle",
	"weapon_leadpipe",
	"weapon_pan",
	"weapon_bat",
	"weapon_hatchet",
	"weapon_hg_axe",
	"weapon_hg_bottlebroken",
	"weapon_hg_crowbar",
	"weapon_hg_machete",
	"weapon_hg_shovel",
	"weapon_hg_sledgehammer",
	"weapon_metalbat",
	"weapon_pocketknife",
	"weapon_sogknife",
	"weapon_wirebat",
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
	weapon_uzi = true,
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
	local mul = MODE.HealthMul
	if MODE.variant == 2 then mul = MODE.Variant2HealthMul
	elseif MODE.variant == 3 then mul = MODE.Variant3HealthMul end
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

	if IsFury(ply) then
		org.berserk = MODE.BerserkStrength
		org.silentBerserk = true
	else
		org.silentBerserk = nil
	end

	if MODE.variant == 2 then
		org.armorMul = 6
		org.painToleranceMul = 4
		org.blood = 7500
		org.NoKnockdown = true
	elseif MODE.variant == 3 then
		org.armorMul = 5
		org.painToleranceMul = 5
		org.blood = 6000
		org.NoKnockdown = true
		org.boneStrengthMul = 4
	else
		org.armorMul = nil
		org.painToleranceMul = nil
		org.NoKnockdown = true
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
		local saiga = GiveWeapon(ply, "weapon_saiga12", 2)
		if IsValid(saiga) and hg.AddAttachmentForce then
			hg.AddAttachmentForce(ply, saiga, "supressor13")
			hg.AddAttachmentForce(ply, saiga, "holo19")
		end
		GiveWeapon(ply, "weapon_morphine")
	elseif loadout == "killa" then
		hg.AddArmor(ply, "vest_killa")
		hg.AddArmor(ply, "helmet_killa")
		hg.AddArmor(ply, "visor_killa")
		local rpk = GiveWeapon(ply, "weapon_rpk16", 2)
		if IsValid(rpk) and hg.AddAttachmentForce then
			hg.AddAttachmentForce(ply, rpk, "holo14")
			hg.AddAttachmentForce(ply, rpk, "grip1")
			hg.AddAttachmentForce(ply, rpk, "muzzle_545_recoil_1")
		end
		GiveWeapon(ply, "weapon_hg_smokenade")
		GiveWeapon(ply, "weapon_morphine")
	elseif loadout == "scream" then
		GiveWeapon(ply, "weapon_chainsaw")
		GiveWeapon(ply, "weapon_buck200knife")
		GiveWeapon(ply, "weapon_hg_wire")
		GiveWeapon(ply, "weapon_adrenaline")
		GiveWeapon(ply, "weapon_midazolam")
		GiveWeapon(ply, "weapon_taser")
	elseif loadout == "jacket" then
		GiveWeapon(ply, "weapon_bat")
		GiveWeapon(ply, "weapon_uzi", 10)
	end

	SetMeleeNoDrop(ply)
end

function MODE:ApplyJuggPersona(ply)
	if not IsValid(ply) then return end
	if MODE.variant ~= 3 then return end

	local mdl = "models/distac/player/ghostface.mdl"

	local identity = {
		AName = "Ghostface",
		AClothes = {},
		AModel = mdl,
		AColor = Color(255, 255, 255),
		AAttachments = {}
	}

	if hg.Appearance and hg.Appearance.ForceApplyAppearance then
		hg.Appearance.ForceApplyAppearance(ply, identity)
	else
		ply:SetModel(mdl)
	end
end

function MODE:GiveGruntLoadout(ply, grunt)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	local hands = GiveWeapon(ply, "weapon_hands_sh")
	ply:SelectWeapon("weapon_hands_sh")

	if grunt == "runningnail" then
		local melee = self.GruntMelee[math.random(#self.GruntMelee)]
		local wep = GiveWeapon(ply, melee)
		if IsValid(wep) then
			wep.NoDrop = true
			wep.MaxOneHandedWeapons = 99
		end
		ply:SelectWeapon(melee)
	elseif grunt == "usec" then
		hg.AddArmor(ply, "vest7")
		local smg = GiveWeapon(ply, "weapon_mp5k", 2)
		if IsValid(smg) then ply:SelectWeapon("weapon_mp5k") end
	end
end

function MODE:CanLaunch()
	return self:GetPlayerCount() >= 2
end

function MODE:PreselectJuggernauts()
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
	end

	MODE.Juggernauts = juggs
	MODE.Juggernaut = juggs[1]
	MODE._juggNames = table.concat(names, ", ")

	net.Start("juggernaut_state")
		net.WriteInt(variant, 8)
		net.WriteFloat(0)
		net.WriteUInt(#juggs, 4)
		for _, jugg in ipairs(juggs) do
			net.WriteEntity(jugg)
		end
	net.Broadcast()
end

function MODE:Intermission()
	MODE.Juggernauts = {}
	MODE.Juggernaut = nil
	MODE._huntersWon = nil
	MODE._juggernautSurvived = nil
	MODE._juggNames = nil
	MODE._loadoutsGiven = nil
	game.CleanUpMap()

	self.ROUND_TIME = math.max(60, roundTime:GetInt())
	if hg.UpdateRoundTime then hg.UpdateRoundTime(self.ROUND_TIME) end

	self.variant = self:PickVariant()

	net.Start("juggernaut_variant")
		net.WriteInt(self.variant or 1, 8)
	net.Broadcast()

	self:PreselectJuggernauts()

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		if not ply.IsJuggernaut then
			ply.juggClass = nil
			ply.juggLoadout = nil
		end
		ClearJuggBuffs(ply)
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end
end

function MODE:GiveJuggernautLoadouts()
	local variant = self.variant or 1
	local cfg = self.Variants[variant]
	if not cfg then return end

	local juggs = MODE.Juggernauts or {}

	MODE._loadoutsGiven = true

	if #juggs > 0 then
		for _, ply in ipairs(juggs) do
			if not IsValid(ply) then continue end
			ply.IsJuggernaut = true
			ApplyJuggernautBuffs(ply)
			self:GiveJuggLoadout(ply, ply.juggLoadout or cfg.juggernauts[1].loadout)
			self:ApplyJuggPersona(ply)
		end
	end

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

end

function MODE:RoundStart()
	local variant = self.variant or 1
	local cfg = self.Variants[variant]
	if not cfg then return end

	local juggs = MODE.Juggernauts or {}

	if #juggs == 0 then
		MODE.Juggernaut = nil
		return
	end

	MODE.Juggernaut = juggs[1]

	self:GiveJuggernautLoadouts()
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
		timer.Simple(0, function()
			if not IsValid(ply) or not ply:Alive() then return end
			if zb.ROUND_STATE ~= 1 then return end
			self:GiveGruntLoadout(ply, self:GetActiveGruntType())
		end)
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

	if MODE.variant == 3 then
		local gruntsAlive = false
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			if self:IsJuggernaut(ply) then continue end
			if ply:Alive() then
				gruntsAlive = true
				break
			end
		end
		if not gruntsAlive then
			self._juggernautSurvived = true
			return true
		end
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
		if self.variant == 3 then
			PrintMessage(HUD_PRINTTALK, "The Ghostface " .. jName .. " eliminated everyone!")
		else
			PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " SURVIVED! Juggernaut wins!")
		end
		for _, jugg in ipairs(self.Juggernauts or {}) do
			if IsValid(jugg) then
				jugg:GiveExp(math.random(40, 70))
				if jugg.GiveSkill then jugg:GiveSkill(math.Rand(0.15, 0.3)) end
			end
		end
	else
		if self.variant == 3 then
			PrintMessage(HUD_PRINTTALK, "The Ghostface " .. jName .. " has been eliminated!")
		else
			PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " has been eliminated! Hunters win!")
		end
	end

	net.Start("juggernaut_end")
		net.WriteInt(self.variant, 8)
		net.WriteBool(self._juggernautSurvived or false)
		net.WriteString(jName)
	net.Broadcast()

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

	local mul = math.max(0.05, damageReduction:GetFloat())
	if MODE.variant == 2 then mul = mul * 0.5 end

	hook_info.dmg = (hook_info.dmg or dmg) * mul
end)

local function JuggernautThink(owner, org, timeValue)
	if not MODE:IsJuggernaut(owner) or not IsJugRound() then return end
	if not MODE._loadoutsGiven then return end

	if IsFury(owner) then org.berserk = MODE.BerserkStrength end
	ApplyStaminaBuff(org)

	local healMul = MODE.variant == 3 and 0.3 or 1.0
	local tv = timeValue * healMul

	org.blood = math.Approach(org.blood, 5000, tv * 5)

	for i, wound in pairs(org.wounds or {}) do
		wound[1] = math.max(wound[1] - tv * 0.5, 0)
	end
	for i, wound in pairs(org.arterialwounds or {}) do
		wound[1] = math.max(wound[1] - tv * 0.5, 0)
	end
	org.internalBleed = math.max((org.internalBleed or 0) - tv * 0.5, 0)

	org.pain = math.Approach(org.pain or 0, 0, tv * 0.5)
	org.painadd = math.Approach(org.painadd or 0, 0, tv * 0.5)
	org.avgpain = math.Approach(org.avgpain or 0, 0, tv * 0.5)
	org.shock = math.Approach(org.shock or 0, 0, tv * 0.5)
	org.immobilization = math.Approach(org.immobilization or 0, 0, tv * 0.5)
	org.fear = math.Approach(org.fear or 0, 0, tv * 0.5)
	org.heartStrain = math.max((org.heartStrain or 0) - tv * 0.1, 0)

	org.disorientation = math.Approach(org.disorientation or 0, 0, timeValue * 1.5)
	org.panicattackadd = math.Approach(org.panicattackadd or 0, 0, timeValue * 1.5)
	org.panicattack = math.Approach(org.panicattack or 0, 0, timeValue * 1.5)
	org.concussion = math.Approach(org.concussion or 0, 0, timeValue * 0.5)
	org.concussion_onset = math.Approach(org.concussion_onset or 0, 0, timeValue * 0.5)
	org.concussion_post = math.Approach(org.concussion_post or 0, 0, timeValue * 0.4)
	org.concussion_tinnitus = math.Approach(org.concussion_tinnitus or 0, 0, timeValue * 0.5)
	org.nausea = math.Approach(org.nausea or 0, 0, timeValue * 0.5)
	org.nausea_target = math.Approach(org.nausea_target or 0, 0, timeValue * 0.5)
	org.nausea_pending = math.Approach(org.nausea_pending or 0, 0, timeValue * 0.5)
end

hook.Add("Org Think", "juggernaut_regen", function(owner, org, timeValue)
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	JuggernautThink(owner, org, timeValue)
end)

hook.Add("PlayerDeath", "juggernaut_kill_heal", function(victim, inflictor, attacker)
	if not IsJugRound() or zb.ROUND_STATE ~= 1 then return end
	if not IsValid(attacker) or attacker == victim then return end
	if not MODE:IsJuggernaut(attacker) then return end
	if not attacker:Alive() then return end

	local org = attacker.organism
	if not org then return end

	attacker:SetHealth(math.min(attacker:Health() + 30, attacker:GetMaxHealth()))
	org.blood = math.min(org.blood + 500, 5000)
	org.pain = math.max((org.pain or 0) - 15, 0)
	org.shock = math.max((org.shock or 0) - 15, 0)
	org.heartStrain = math.max((org.heartStrain or 0) - 2, 0)

	org.bleed = 0
	org.internalBleed = 0
	if org.arterialwounds then
		for i = #org.arterialwounds, 1, -1 do
			table.remove(org.arterialwounds, i)
		end
		hg.organism.MarkArterialWoundsNetDirty(org)
	end
	if org.wounds then
		for _, wound in pairs(org.wounds) do
			if wound then wound[1] = 0 end
		end
		hg.organism.MarkWoundsNetDirty(org, true)
	end

	if org.stamina then
		org.stamina[1] = math.min((org.stamina[1] or 0) + 50, org.stamina.range or org.stamina[1] + 50)
	end

	if org.o2 then
		org.o2[1] = math.min((org.o2[1] or 0) + 10, org.o2.range or 30)
	end
end)

MsgC(Color(0, 255, 0), "[JUGG] sv_juggernaut.lua loaded. CanLaunch=" .. tostring(MODE.CanLaunch) .. ", RoundStart=" .. tostring(MODE.RoundStart) .. "\n")
