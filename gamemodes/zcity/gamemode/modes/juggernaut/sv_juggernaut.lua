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
MODE.LootSpawn = true

util.AddNetworkString("juggernaut_state")

local damageReduction = CreateConVar("zb_jugg_damage_reduction", "0.5", FCVAR_LUA_SERVER, "Juggernaut damage taken multiplier (1 = normal)")
local bleedMul = CreateConVar("zb_jugg_bleed_mul", "0.35", FCVAR_LUA_SERVER, "Juggernaut bleeding multiplier (lower = less blood loss)")
local maxHealth = CreateConVar("zb_jugg_health", "250", FCVAR_LUA_SERVER, "Juggernaut max health")
local roundTime = CreateConVar("zb_jugg_round_time", "420", FCVAR_LUA_SERVER, "Juggernaut survival time (seconds)")
local hunterRespawn = CreateConVar("zb_jugg_hunter_respawn", "5", FCVAR_LUA_SERVER, "Hunter respawn delay (seconds)")

local function IsJugRound()
	local round = CurrentRound()
	return round and round.name == "juggernaut"
end

local function ApplyJuggernautBuffs(ply)
	local org = ply.organism
	if not org then return end

	org.blood = 5000
	org.bleedingmul = math.max(0.1, bleedMul:GetFloat())
	org.recoilmul = 0.6
	org.legstrength = 1.1
	org.meleespeed = 1.15

	ply:SetMaxHealth(math.max(100, maxHealth:GetInt()))
	ply:SetHealth(ply:GetMaxHealth())
end

local function GiveJuggernautLoadout(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	local hands = ply:Give("weapon_hands_sh")
	ply:SelectWeapon(hands)

	local gun = ply:Give("weapon_hk416")
	if IsValid(gun) then
		ply:GiveAmmo(gun:GetMaxClip1() * 4, gun:GetPrimaryAmmoType(), true)
		if hg.AddAttachmentForce then
			hg.AddAttachmentForce(ply, gun, {"holo14", "laser3", "grip3"})
		end
	end
	ply:Give("weapon_combatknife")
	ply:Give("weapon_adrenaline")
	ply:Give("weapon_medkit_sh")
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_painkillers_tpik")

	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	ply:SetNetVar("Inventory", inv)
end

local function GiveHunterLoadout(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	local hands = ply:Give("weapon_hands_sh")
	ply:SelectWeapon(hands)

	local pistol = ply:Give("weapon_glock17")
	if IsValid(pistol) then
		ply:GiveAmmo(pistol:GetMaxClip1() * 2, pistol:GetPrimaryAmmoType(), true)
	end
	ply:Give("weapon_pocketknife")
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_painkillers_tpik")
end

function MODE:CanLaunch()
	local count = 0
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		count = count + 1
	end
	return count >= 2
end

function MODE:Intermission()
	MODE.Juggernaut = nil
	MODE._huntersWon = nil
	MODE._juggernautSurvived = nil
	game.CleanUpMap()

	self.ROUND_TIME = math.max(60, roundTime:GetInt())
	if hg.UpdateRoundTime then hg.UpdateRoundTime(self.ROUND_TIME) end

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply.IsJuggernaut = nil
		ApplyAppearance(ply)
		ply:SetupTeam(0)
	end
end

function MODE:RoundStart()
	local candidates = {}
	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR or not ply:Alive() then continue end
		candidates[#candidates + 1] = ply
	end

	if #candidates < 2 then
		candidates = {}
		for _, ply in player.Iterator() do
			if ply:Team() == TEAM_SPECTATOR then continue end
			candidates[#candidates + 1] = ply
		end
	end

	if #candidates == 0 then
		MODE.Juggernaut = nil
		return
	end

	local juggernaut = candidates[math.random(#candidates)]
	MODE.Juggernaut = juggernaut
	juggernaut.IsJuggernaut = true

	ApplyJuggernautBuffs(juggernaut)
	GiveJuggernautLoadout(juggernaut)

	for _, ply in player.Iterator() do
		if ply == juggernaut or ply:Team() == TEAM_SPECTATOR then continue end
		GiveHunterLoadout(ply)
	end

	zb.GiveRole(juggernaut, "Juggernaut", Color(190, 20, 20))

	local surviveUntil = CurTime() + self.ROUND_TIME
	net.Start("juggernaut_state")
		net.WriteEntity(juggernaut)
		net.WriteFloat(surviveUntil)
	net.Broadcast()

	PrintMessage(HUD_PRINTTALK, "JUGGERNAUT: " .. juggernaut:Nick() .. " must survive for " .. math.ceil(self.ROUND_TIME) .. " seconds!")
	PrintMessage(HUD_PRINTTALK, "Everyone else: hunt the Juggernaut down!")
end

function MODE:GiveEquipment()
end

function MODE:PlayerSpawn(ply)
	if not IsValid(ply) or ply:Team() == TEAM_SPECTATOR or zb.ROUND_STATE ~= 1 then return end

	if ply == MODE.Juggernaut then
		ApplyJuggernautBuffs(ply)
		GiveJuggernautLoadout(ply)
	else
		GiveHunterLoadout(ply)
	end
end

function MODE:PlayerDeath(victim, inflictor, attacker)
	if not IsJugRound() or zb.ROUND_STATE ~= 1 then return end
	if not IsValid(victim) then return end

	if victim == MODE.Juggernaut then
		MODE._huntersWon = true
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
	if ply == MODE.Juggernaut then
		MODE.Juggernaut = nil
	end
end)

function MODE:ShouldRoundEnd()
	local j = MODE.Juggernaut
	if not IsValid(j) or not j:Alive() then
		MODE._huntersWon = true
		return true
	end
	return nil
end

function MODE:BoringRoundFunction()
	local j = MODE.Juggernaut
	if IsValid(j) and j:Alive() then
		MODE._juggernautSurvived = true
	end
end

function MODE:EndRound()
	local j = MODE.Juggernaut
	local jName = IsValid(j) and j:Nick() or "The Juggernaut"

	if MODE._juggernautSurvived then
		PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " SURVIVED! Juggernaut wins!")
		if IsValid(j) then
			j:GiveExp(math.random(40, 70))
			if j.GiveSkill then j:GiveSkill(math.Rand(0.15, 0.3)) end
		end
	else
		PrintMessage(HUD_PRINTTALK, "The Juggernaut " .. jName .. " has been eliminated! Hunters win!")
	end

	MODE.Juggernaut = nil
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

hook.Add("Org Think", "juggernaut_regen", function(owner, org, timeValue)
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	if not MODE:IsJuggernaut(owner) then return end
	if not IsJugRound() then return end

	org.blood = math.Approach(org.blood, 5000, timeValue * 40)

	for i, wound in pairs(org.wounds or {}) do
		wound[1] = math.max(wound[1] - timeValue * 4, 0)
	end
	for i, wound in pairs(org.arterialwounds or {}) do
		wound[1] = math.max(wound[1] - timeValue * 4, 0)
	end
	org.internalBleed = math.max((org.internalBleed or 0) - timeValue * 4, 0)

	local heal = timeValue * 4
	org.pain = math.Approach(org.pain, 0, heal)
	org.painadd = math.Approach(org.painadd, 0, heal)
	org.avgpain = math.Approach(org.avgpain, 0, heal)
	org.shock = math.Approach(org.shock, 0, heal)
	org.immobilization = math.Approach(org.immobilization, 0, heal)
	org.fear = math.Approach(org.fear, 0, heal)
	org.heartStrain = math.max((org.heartStrain or 0) - timeValue, 0)

	if (org.healthRegen or 0) < CurTime() then
		org.healthRegen = CurTime() + 3
		owner:SetHealth(math.min(owner:GetMaxHealth(), owner:Health() + 15))
	end
end)
