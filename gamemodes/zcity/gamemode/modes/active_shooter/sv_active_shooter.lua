local MODE = MODE

util.AddNetworkString("active_shooter_start")
util.AddNetworkString("active_shooter_end")

local shooterColor = Color(190, 25, 25)
local victimColor = Color(40, 135, 210)
local swatColor = Color(30, 30, 100)

local primaryWeapons = {
	"weapon_akAfgan",
	"weapon_vpo101",
	"weapon_vpo101",
	"weapon_svt",
	"weapon_m1a1",
	"weapon_m590a1",
	"weapon_mr43",
	"weapon_mts255",
	"weapon_mp5",
	"weapon_pp1901",
	"weapon_kedr",
	"weapon_uzi",
}

local secondaryWeapons = {
	"weapon_glock17",
	"weapon_m9a3",
	"weapon_deagle",
	"weapon_sr1mp",
	"weapon_pm",
	"weapon_m1911",
	"weapon_p226",
	"weapon_fn57",
	"weapon_fn45",
	"weapon_p22",
}

local grenadeWeapons = {
	"weapon_hg_eft_f1",
	"weapon_hg_molotov_tpik",
	"weapon_hg_pipebomb_tpik",
}

local reserveClips = {
	weapon_akAfgan = 2,
	weapon_vpo101 = 3,
	weapon_svt = 3,
	weapon_m1a1 = 2,
	weapon_m590a1 = 3,
	weapon_mr43 = 6,
	weapon_mts255 = 4,
	weapon_mp5 = 3,
	weapon_pp1901 = 3,
	weapon_kedr = 4,
	weapon_uzi = 3,
}

local primaryAttachments = {
	weapon_akAfgan = {"supressor3", "supressor4", "supressor15"},
	weapon_vpo101 = {"supressor9", "supressor16", "supressor15", "optic4", "optic11"},
	weapon_svt = {"optic4", "optic11"},
	weapon_m1a1 = {"supressor9", "supressor16", "supressor15", "holo2", "holo3", "holo4", "holo14", "optic5", "optic8"},
	weapon_mp5 = {"supressor2", "supressor1", "supressor15", "holo2", "holo3", "holo4", "holo14", "optic5", "optic8"},
	weapon_pp1901 = {"supressor1", "supressor2", "supressor15", "holo2", "holo3", "holo4", "holo14", "optic5", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5"},
	weapon_uzi = {"supressor2", "supressor1", "supressor15", "holo2", "holo3", "holo4", "holo14", "optic5"},
}

local function IsActivePlayer(ply)
	return IsValid(ply) and ply:Team() ~= TEAM_SPECTATOR
end

local function GiveReserveAmmo(ply, gun, clips)
	if not IsValid(gun) then return end

	local ammoType = gun:GetPrimaryAmmoType()
	local clipSize = gun:GetMaxClip1()
	if ammoType < 0 or clipSize <= 0 then return end

	ply:GiveAmmo(clipSize * clips, ammoType, true)
end

local function EquipShooter(ply)
	if not IsValid(ply) or not ply:Alive() then return end

	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetSuppressPickupNotices(true)
	ply.armors = {}
	if ply.SyncArmor then ply:SyncArmor() end

	local vest = table.Random({"vest4", "vest1", "vest2", "vest26"})
	hg.AddArmor(ply, vest)
	local helmet = table.Random({"helmet4", "helmet20", "helmet5"})
	hg.AddArmor(ply, helmet)
	if helmet == "helmet20" and math.random(2) == 1 then
		hg.AddArmor(ply, "mask4")
	elseif helmet == "helmet5" and math.random(2) == 1 then
		hg.AddArmor(ply, "visor_kolpak")
	end

	local hands = ply:Give("weapon_hands_sh")
	ply:Give("weapon_bars_a2607")

	local primaryClass = table.Random(primaryWeapons)
	local primary = ply:Give(primaryClass)
	GiveReserveAmmo(ply, primary, reserveClips[primaryClass] or 3)

	local attachments = primaryAttachments[primaryClass]
	if IsValid(primary) and attachments and math.random() <= 0.65 then
		local attachment = table.Random(attachments)
		hg.AddAttachmentForce(ply, primary, attachment)
	end

	local secondaryClass = table.Random(secondaryWeapons)
	local secondary = ply:Give(secondaryClass)
	GiveReserveAmmo(ply, secondary, 2)

	ply:Give("weapon_painkillers_tpik")
	ply:Give("weapon_bigbandage_sh")
	ply:Give("weapon_traitor_ied")
	local grenadeClass = table.Random(grenadeWeapons)
	ply:Give(grenadeClass)

	if IsValid(hands) then
		ply:SetActiveWeapon(hands)
	end

	ply:SetSuppressPickupNotices(false)
end

local function SendStartState(ply, shooterLookup, releaseAt, swatAt, playRoundSounds)
	net.Start("active_shooter_start")
		net.WriteBool(shooterLookup[ply] == true)
		net.WriteFloat(releaseAt)
		net.WriteFloat(swatAt or 0)
		net.WriteBool(playRoundSounds == true)
	net.Send(ply)
end

local function PickCommonLoot()
	local pool = (MODE.LootTable and MODE.LootTable[1] and MODE.LootTable[1][2]) or {}
	if #pool == 0 then return end

	local total = 0
	for _, item in ipairs(pool) do
		total = total + item[1]
	end

	local roll = math.random() * total
	for _, item in ipairs(pool) do
		roll = roll - item[1]
		if roll <= 0 then
			return item[2]
		end
	end

	return pool[#pool][2]
end

local function GiveLootItem(ply, item)
	if not IsValid(ply) or not item then return end

	if string.find(item, "ent_armor_") then
		if hg.AddArmor then
			hg.AddArmor(ply, string.Replace(item, "ent_armor_", ""))
		end
	else
		ply:Give(item)
	end
end

function MODE:OverrideBalance()
	return true
end

function MODE:PrepareIntermission()
	local players = {}
	for _, ply in player.Iterator() do
		if IsActivePlayer(ply) then
			players[#players + 1] = ply
		end
	end
	if #players < 2 then return end

	table.Shuffle(players)
	local shooterCount = math.Clamp(1 + math.floor(#players / 14), 1, math.min(3, #players - 1))
	local shooters = {}
	local shooterLookup = {}
	local expectedReleaseAt = CurTime() + (self.start_time or 5) + MODE.hideTime
	local expectedSwatAt = expectedReleaseAt + MODE.swatTime

	for index = 1, shooterCount do
		local shooter = players[index]
		shooters[#shooters + 1] = shooter
		shooterLookup[shooter] = true
	end

	self.PreparedPlayers = players
	self.PreparedShooters = shooters
	self.PreparedShooterLookup = shooterLookup

	for _, ply in ipairs(players) do
		SendStartState(ply, shooterLookup, expectedReleaseAt, expectedSwatAt, false)
	end
end

function MODE:Intermission()
	game.CleanUpMap()

	local players = self.PreparedPlayers or {}
	local shooters = self.PreparedShooters or {}
	local shooterLookup = self.PreparedShooterLookup or {}
	local expectedReleaseAt = CurTime() + (self.start_time or 5) + MODE.hideTime

	self.saved.Shooters = shooters
	self.saved.ShooterLookup = shooterLookup
	self.saved.ReleaseAt = expectedReleaseAt
	self.saved.SWATAt = expectedReleaseAt + MODE.swatTime
	self.saved.ShootersReleased = false
	self.saved.SWATArrived = false

	for _, ply in ipairs(players) do
		local isShooter = shooterLookup[ply] == true
		ApplyAppearance(ply)
		ply:SetupTeam(isShooter and 1 or 0)
		zb.GiveRole(ply, isShooter and "Active Shooter" or "Victim", isShooter and shooterColor or victimColor)
	end

	for _, shooter in ipairs(shooters) do
		if IsValid(shooter) and shooter:Alive() then
			shooter:KillSilent()
		end
	end

	self.PreparedPlayers = nil
	self.PreparedShooters = nil
	self.PreparedShooterLookup = nil
end

function MODE:GiveEquipment()
	for _, ply in player.Iterator() do
		if not IsActivePlayer(ply) or not ply:Alive() then continue end

		ply:StripWeapons()
		ply:RemoveAllAmmo()
		local hands = ply:Give("weapon_hands_sh")
		if IsValid(hands) then ply:SetActiveWeapon(hands) end

		if not (self.saved.ShooterLookup or {})[ply] then
			GiveLootItem(ply, PickCommonLoot())
		end
	end
end

function MODE:RoundStart()
	self.saved.ReleaseAt = CurTime() + MODE.hideTime
	self.saved.SWATAt = self.saved.ReleaseAt + MODE.swatTime
	self.saved.ShootersReleased = false
	self.saved.SWATArrived = false
	local shooters = table.Copy(self.saved.Shooters or {})
	local shooterLookup = self.saved.ShooterLookup or {}
	local releaseAt = self.saved.ReleaseAt
	local swatAt = self.saved.SWATAt

	for _, ply in player.Iterator() do
		if IsActivePlayer(ply) then
			SendStartState(ply, shooterLookup, releaseAt, swatAt, true)
		end
	end

	timer.Simple(MODE.hideTime, function()
		if zb.ROUND_STATE ~= 1 or CurrentRound() ~= self then return end
		if self.saved.ReleaseAt ~= releaseAt then return end

		for _, shooter in ipairs(shooters) do
			if not IsActivePlayer(shooter) or not shooterLookup[shooter] then continue end

			if not shooter:Alive() then shooter:Spawn() end
			shooter:SetupTeam(1)
			ApplyAppearance(shooter)
			zb.GiveRole(shooter, "Active Shooter", shooterColor)
			EquipShooter(shooter)
		end

		self.saved.ShootersReleased = true

		timer.Simple(MODE.swatTime, function()
			if zb.ROUND_STATE ~= 1 or CurrentRound() ~= self then return end
			if self.saved.ReleaseAt ~= releaseAt then return end
			if not self.saved.ShootersReleased or self.saved.SWATArrived then return end

			self.saved.SWATArrived = true
			self:SpawnSWAT()
		end)
	end)
end

function MODE:EquipSWAT(ply, index)
	ply:SetPlayerClass("swat")
	ply:StripWeapons()
	ply:RemoveAllAmmo()
	ply:SetSuppressPickupNotices(true)

	local classes = {
		"weapon_m4a1",
		"weapon_m590a1",
		"weapon_mp5",
		"weapon_sr25",
	}
	local primary = ply:Give(classes[((index - 1) % #classes) + 1])
	local pistol = ply:Give("weapon_glock17")

	if IsValid(primary) and primary:GetPrimaryAmmoType() >= 0 and primary:GetMaxClip1() > 0 then
		ply:GiveAmmo(primary:GetMaxClip1() * 3, primary:GetPrimaryAmmoType(), true)
	end
	if IsValid(pistol) and pistol:GetPrimaryAmmoType() >= 0 and pistol:GetMaxClip1() > 0 then
		ply:GiveAmmo(pistol:GetMaxClip1() * 3, pistol:GetPrimaryAmmoType(), true)
	end

	ply:Give("weapon_combatknife")
	ply:Give("weapon_handcuffs")
	ply:Give("weapon_handcuffs_key")
	ply:Give("weapon_hg_flashbang_tpik")
	ply:Give("weapon_taser")
	ply:Give("weapon_bigbandage_sh")
	ply:Give("weapon_bandage_sh")
	ply:Give("weapon_tourniquet")
	ply:Give("weapon_painkillers_tpik")

	if hg.AddArmor then hg.AddArmor(ply, {"helmet6", "vest8"}) end

	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	ply.organism.recoilmul = 0.6
	ply:SetNetVar("CurPluv", "pluvberet")

	local hands = ply:Give("weapon_hands_sh")
	if IsValid(hands) then ply:SetActiveWeapon(hands) end

	ply:SetSuppressPickupNotices(false)
	zb.GiveRole(ply, "SWAT", swatColor)
end

function MODE:SpawnSWAT()
	local shooterLookup = self.saved.ShooterLookup or {}
	local spawned = 0

	for _, ply in player.Iterator() do
		if not IsActivePlayer(ply) then continue end
		if shooterLookup[ply] then continue end
		if ply:Alive() then continue end

		spawned = spawned + 1
		ply:Spawn()
		ply:SetTeam(0)
		ApplyAppearance(ply)
		ply.ActiveShooterSWAT = true
		self:EquipSWAT(ply, spawned)
	end

	if spawned > 0 then
		PrintMessage(HUD_PRINTTALK, "SWAT has arrived! Fallen victims have been redeployed.")
		EmitSound("snd_jack_hmcd_heli2.mp3", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
	end
end

function MODE:StartCommand(ply, cmd)
	if not (self.saved.ShooterLookup or {})[ply] then return end
	if CurTime() >= (self.saved.ReleaseAt or math.huge) then return end

	cmd:ClearMovement()
	cmd:ClearButtons()
end

function MODE:EntityTakeDamage(target, dmgInfo)
	if CurTime() >= (self.saved.ReleaseAt or math.huge) then return end

	local shooters = self.saved.ShooterLookup or {}
	if shooters[target] or shooters[dmgInfo:GetAttacker()] then return true end
end

function MODE:CheckAlivePlayers()
	local alive = {[0] = {}, [1] = {}}
	local shooters = self.saved.ShooterLookup or {}

	for _, ply in player.Iterator() do
		if not IsActivePlayer(ply) or not ply:Alive() then continue end
		if ply.organism and ply.organism.incapacitated then continue end

		local group = shooters[ply] and 1 or 0
		alive[group][#alive[group] + 1] = ply
	end

	return alive
end

function MODE:ShouldRoundEnd()
	if table.Count(self.saved.ShooterLookup or {}) == 0 then return true end
	if not self.saved.ShootersReleased then return false end

	local ended = zb:CheckWinner(self:CheckAlivePlayers())
	return ended
end

function MODE:EndRound()
	local ended, winner = zb:CheckWinner(self:CheckAlivePlayers())
	if not ended then winner = 0 end

	net.Start("active_shooter_end")
		net.WriteUInt(winner or 3, 2)
	net.Broadcast()
end

function MODE:PlayerDisconnected(ply)
	local shooters = self.saved.ShooterLookup or {}
	if not shooters[ply] then return end

	shooters[ply] = nil
	table.RemoveByValue(self.saved.Shooters or {}, ply)
end
