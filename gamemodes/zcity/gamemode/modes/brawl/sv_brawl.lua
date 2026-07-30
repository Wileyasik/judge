local MODE = MODE

MODE.name = "brawl"
MODE.PrintName = "Brawl"
MODE.start_time = 13
MODE.ROUND_TIME = 1260
MODE.end_time = 10
MODE.grace_time = 0
MODE.GuiltDisabled = true

local networkStrings = {
    "brawl_start", "brawl_progress", "brawl_final", "brawl_end", "brawl_grace",
    "brawl_music", "brawl_loop_music", "brawl_laststage_start",
    "brawl_laststage_stop", "brawl_round_end"
}
for _, name in ipairs(networkStrings) do util.AddNetworkString(name) end

local respawnDelay = CreateConVar("zb_brawl_respawn_delay", "3", FCVAR_LUA_SERVER, "Brawl respawn delay")
local rewardHP = CreateConVar("zb_brawl_kill_reward_hp", "25", FCVAR_LUA_SERVER, "Brawl kill reward HP")
local roundDuration = CreateConVar("zb_brawl_round_time", "600", FCVAR_LUA_SERVER, "Brawl round duration")
local stageCount = CreateConVar("zb_brawl_stage_count", "16", FCVAR_LUA_SERVER, "Total brawl progression stages")
local startMusicFile = CreateConVar("zb_brawl_start_file", "brawlstart.MP3", FCVAR_LUA_SERVER, "Local sound file to play at brawl start")
local startMusicURL = CreateConVar("zb_brawl_start_url", "", FCVAR_LUA_SERVER, "Music URL to play at brawl start (optional)")
local startMusicVol = CreateConVar("zb_brawl_start_vol", "0.35", FCVAR_LUA_SERVER, "Start music volume (0-1)")
local loopMusicFile = CreateConVar("zb_brawl_loop_file", "loopviolence.MP3", FCVAR_LUA_SERVER, "Local round loop music file")
local loopMusicVol = CreateConVar("zb_brawl_loop_vol", "0.45", FCVAR_LUA_SERVER, "Round loop music volume (0-1)")
local incapKillTime = CreateConVar("zb_brawl_incap_kill_time", "15", FCVAR_LUA_SERVER, "Kill player if incapacitated for this many seconds")

local ANNOUNCE_TIMER = "brawl_top3_announce"
local GRACE_TIMER = "brawl_grace_give"
local CLAIM_WINDOW = 20
local lastHit = {}
local warnedFinalFallback = false

MODE.PlayerProgress = {}
MODE.DamageLog = {}
MODE._generation = MODE._generation or 0
MODE._respawnDue = {}
MODE._granting = {}
MODE._finalPlayers = {}
MODE._incapSince = {}

local function IsBrawlGeneration(generation, activeOnly)
    local round = CurrentRound()
    return generation == MODE._generation and round and round.name == "brawl"
        and (not activeOnly or zb.ROUND_STATE == 1)
end

local function GetStageCount(pool)
    local configured = math.Clamp(stageCount:GetInt(), 3, 64)
    return math.Clamp(configured > 0 and configured or (MODE.DefaultStageCount or 16), 3, #pool + 1)
end

local function ResetProgress()
    MODE.PlayerProgress = {}
    MODE.DamageLog = {}
    MODE._winner = nil
    MODE._leaderboard = nil
    MODE._respawnDue = {}
    MODE._granting = {}
    MODE._finalPlayers = {}
    MODE._incapSince = {}
    MODE._graceEnd = 0
    MODE._startGiven = false
    MODE._roundStartWeapon = nil
    MODE._roundPool = nil
    MODE._roundFinalWeapon = nil
    MODE._roundStagesTotal = 1
    timer.Remove(ANNOUNCE_TIMER)
    timer.Remove(GRACE_TIMER)
end

local function InitPlayer(ply)
    local startWeapon = MODE._roundStartWeapon or (MODE._roundPool and MODE._roundPool[1])
    if not startWeapon then return end

    MODE.PlayerProgress[ply] = {
        stage = 1,
        kills = 0,
        unlocked = {startWeapon},
        finalWeapon = MODE._roundFinalWeapon,
        stagesTotal = MODE._roundStagesTotal
    }
end

local function SyncHUD(ply)
    local progress = MODE.PlayerProgress[ply]
    if not IsValid(ply) or not progress then return end

    local class = progress.unlocked[progress.stage]
    if progress.stage >= progress.stagesTotal then class = progress.finalWeapon end

    net.Start("brawl_progress")
        net.WriteUInt(progress.stage, 12)
        net.WriteUInt(progress.stagesTotal or 1, 12)
        net.WriteUInt(progress.kills or 0, 16)
        net.WriteString(class or progress.unlocked[#progress.unlocked] or "")
        net.WriteBool(progress.stage >= (progress.stagesTotal or 1))
    net.Send(ply)
end

local function IsAllowedWeaponClass(class)
    if class == "weapon_hands_sh" or class == MODE._roundFinalWeapon then return true end
    for _, allowed in ipairs(MODE._roundPool or {}) do
        if class == allowed then return true end
    end
    return false
end

local function LimitFinalAmmo(ply, weapon, loadRound)
    if not IsValid(ply) or not IsValid(weapon) then return end
    if weapon:GetClass() ~= MODE._roundFinalWeapon then return end

    if weapon:GetMaxClip1() > 0 then
        weapon:SetClip1(loadRound and 1 or math.min(1, math.max(0, weapon:Clip1())))
    end
    local ammoType = weapon:GetPrimaryAmmoType()
    if ammoType and ammoType ~= -1 then
        local reserve = ply:GetAmmoCount(ammoType)
        if reserve > 0 then ply:RemoveAmmo(reserve, ammoType) end
    end
end

local function GiveProgressWeapon(ply, class)
    if not IsValid(ply) or not ply:Alive() or not class or not weapons.GetStored(class) then return false end

    MODE._granting[ply] = true
    ply:StripWeapons()
    local handsClass = hg.GetHandsWeaponClass and hg.GetHandsWeaponClass(ply) or "weapon_hands_sh"
    local hands = ply:Give(handsClass)
    local weapon = ply:Give(class)

    -- Shadow NoHolster on this entity only; changing weapons.GetStored would affect every mode.
    if IsValid(weapon) and weapon.NoHolster then weapon.NoHolster = false end
    if IsValid(weapon) then
        ply:SelectWeapon(class)
    elseif IsValid(hands) then
        ply:SelectWeapon(handsClass)
    end
    MODE._granting[ply] = nil

    if IsValid(weapon) and class == MODE._roundFinalWeapon then
        local generation = MODE._generation
        timer.Simple(0, function()
            if not IsBrawlGeneration(generation, true) then return end
            LimitFinalAmmo(ply, weapon, true)
        end)
    end
    return IsValid(weapon)
end

local function SetFinalStage(ply, enabled)
    if not ply or not ply.EntIndex then return end
    local index = ply:EntIndex()
    if index < 0 then return end
    if enabled and MODE._finalPlayers[index] then return end
    if not enabled and not MODE._finalPlayers[index] then return end

    MODE._finalPlayers[index] = enabled and true or nil
    net.Start(enabled and "brawl_laststage_start" or "brawl_laststage_stop")
        net.WriteUInt(index, 13)
    net.Broadcast()
end

local function EnterFinalStage(ply, progress)
    if not IsValid(ply) or not ply:Alive() then return end
    progress.stage = progress.stagesTotal
    if not table.HasValue(progress.unlocked, progress.finalWeapon) then
        progress.unlocked[#progress.unlocked + 1] = progress.finalWeapon
    end

    GiveProgressWeapon(ply, progress.finalWeapon)
    SyncHUD(ply)
    SetFinalStage(ply, true)

    net.Start("brawl_final")
        net.WriteEntity(ply)
        net.WriteString(progress.finalWeapon)
    net.Broadcast()
end

local function AddRandomUnlock(ply)
    local progress = MODE.PlayerProgress[ply]
    if not progress or not ply:Alive() then return end
    if progress.stage >= progress.stagesTotal - 1 then
        EnterFinalStage(ply, progress)
        return
    end

    local owned = {}
    for _, class in ipairs(progress.unlocked) do owned[class] = true end
    local candidates = {}
    for _, class in ipairs(MODE._roundPool or {}) do
        if not owned[class] and class ~= progress.finalWeapon then candidates[#candidates + 1] = class end
    end

    if #candidates == 0 then
        EnterFinalStage(ply, progress)
        return
    end

    local class = candidates[math.random(#candidates)]
    progress.unlocked[#progress.unlocked + 1] = class
    progress.stage = #progress.unlocked
    GiveProgressWeapon(ply, class)
    SyncHUD(ply)
end

local function BuildLeaderboard()
    local ranks = {}
    for ply, progress in pairs(MODE.PlayerProgress) do
        if IsValid(ply) then ranks[#ranks + 1] = {ply = ply, kills = progress.kills or 0} end
    end
    table.sort(ranks, function(a, b) return a.kills > b.kills end)
    MODE._leaderboard = ranks
end

local function RewardKill(victim, attacker)
    if MODE._winner or not IsValid(victim) or not victim:IsPlayer() then return end
    local bestAttacker, bestWeapon, maxDamage
    maxDamage = 0
    for candidate, data in pairs(MODE.DamageLog[victim] or {}) do
        if IsValid(candidate) and candidate:IsPlayer() and data.damage > maxDamage then
            bestAttacker, bestWeapon, maxDamage = candidate, data.weapon, data.damage
        end
    end

    local killClass = ""
    if IsValid(bestAttacker) then
        attacker, killClass = bestAttacker, bestWeapon
    elseif IsValid(attacker) and attacker:IsPlayer() then
        local hit = lastHit[victim]
        if hit and hit.attacker == attacker and CurTime() - hit.time <= CLAIM_WINDOW then killClass = hit.class end
    end

    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end
    if killClass == "" or not IsAllowedWeaponClass(killClass) then return end
    local progress = MODE.PlayerProgress[attacker]
    if not progress or (killClass == progress.finalWeapon and progress.stage < progress.stagesTotal) then return end

    progress.kills = (progress.kills or 0) + 1
    local organism = attacker.organism
    if organism then
        if organism.stamina and organism.stamina[1] and organism.stamina.max then
            organism.stamina[1] = math.min(organism.stamina.max, organism.stamina[1] + math.max(20, organism.stamina.max * 0.45))
        end
        if organism.bleed then organism.bleed = math.max(organism.bleed - 10, 0) end
        if organism.internalBleed then organism.internalBleed = math.max(organism.internalBleed - 5, 0) end
    end
    local maxHealth = attacker:GetMaxHealth() > 0 and attacker:GetMaxHealth() or 100
    attacker:SetHealth(math.min(maxHealth, attacker:Health() + math.max(0, rewardHP:GetInt())))

    if progress.stage >= progress.stagesTotal then
        if killClass == progress.finalWeapon then MODE._winner = attacker end
    else
        AddRandomUnlock(attacker)
    end
    SyncHUD(attacker)
end

local function MakeDissolver(entity, attacker)
    if not IsValid(entity) then return end
    local dissolver = ents.Create("env_entity_dissolver")
    if not IsValid(dissolver) then return end
    dissolver.Target = "brawl_dissolve_" .. entity:EntIndex()
    dissolver:SetKeyValue("dissolvetype", 0)
    dissolver:SetKeyValue("magnitude", 0)
    dissolver:SetPos(entity:GetPos())
    if IsValid(attacker) and attacker:IsPlayer() then dissolver:SetPhysicsAttacker(attacker) end
    dissolver:Spawn()
    entity:SetName(dissolver.Target)
    dissolver:Fire("Dissolve", dissolver.Target, 0)
    dissolver:Fire("Kill", "", 0.1)
end

function MODE:CanLaunch()
    local pool = self:GetWeaponPool()
    local final = self:GetFinalWeapon()
    return #pool >= 2 and final ~= nil
end

function MODE:Intermission()
    self._generation = self._generation + 1
    ResetProgress()
    game.CleanUpMap()

    self.ROUND_TIME = math.max(120, roundDuration:GetInt())
    if hg.UpdateRoundTime then hg.UpdateRoundTime(self.ROUND_TIME) end

    local pool = self:GetWeaponPool()
    local final, usingFallback = self:GetFinalWeapon()
    if #pool < 2 or not final then
        ErrorNoHalt("[Brawl] Intermission reached without a viable weapon pool; ending safely.\n")
        self._winner = NULL
        return
    end
    if usingFallback and not warnedFinalFallback then
        warnedFinalFallback = true
        ErrorNoHalt("[Brawl] weapon_brawl_revolver357 is unavailable; using Judge's weapon_revolver357 as a one-shot final weapon.\n")
    end

    self._roundPool = pool
    self._roundFinalWeapon = final
    self._roundStagesTotal = GetStageCount(pool)
    self._roundStartWeapon = pool[math.random(#pool)]

    for _, ply in player.Iterator() do
        if ply:Team() == TEAM_SPECTATOR then continue end
        ApplyAppearance(ply)
        ply:SetupTeam(0)
        InitPlayer(ply)
        zb.GiveRole(ply, "Brawler", Color(190, 60, 60))
    end

    net.Start("brawl_start")
        net.WriteUInt(self.ROUND_TIME, 16)
    net.Broadcast()
end

function MODE:RoundStart()
    local generation = self._generation
    for _, ply in player.Iterator() do
        ply:Freeze(false)
        if ply:Team() ~= TEAM_SPECTATOR then
            ApplyAppearance(ply)
            zb.GiveRole(ply, "Brawler", Color(190, 60, 60))
        end
    end

    timer.Create(ANNOUNCE_TIMER, 60, 0, function()
        if not IsBrawlGeneration(generation, true) or MODE._winner then return end
        BuildLeaderboard()
        for index = 1, math.min(3, #(MODE._leaderboard or {})) do
            local rank = MODE._leaderboard[index]
            PrintMessage(HUD_PRINTTALK, string.format("TOP %d: %s - %d Kills", index, rank.ply:Nick(), rank.kills))
        end
    end)

    net.Start("brawl_music")
        local hasGrace = (self.grace_time or 0) > 0
        net.WriteString(hasGrace and startMusicFile:GetString() or "")
        net.WriteString(hasGrace and startMusicURL:GetString() or "")
        net.WriteFloat(hasGrace and math.Clamp(startMusicVol:GetFloat(), 0, 1) or 0)
        net.WriteFloat(math.max(0, self.grace_time or 0))
    net.Broadcast()

    self._graceEnd = CurTime() + math.max(0, self.grace_time or 0)
    net.Start("brawl_grace") net.WriteFloat(self._graceEnd) net.Broadcast()

    local function StartCombat()
        if not IsBrawlGeneration(generation, true) or MODE._startGiven then return end
        for _, ply in player.Iterator() do
            local progress = MODE.PlayerProgress[ply]
            if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR and progress then
                progress.unlocked[1] = MODE._roundStartWeapon
                progress.stage = 1
                GiveProgressWeapon(ply, MODE._roundStartWeapon)
                SyncHUD(ply)
            end
        end
        net.Start("brawl_loop_music")
            net.WriteString(loopMusicFile:GetString())
            net.WriteFloat(math.Clamp(loopMusicVol:GetFloat(), 0, 1))
        net.Broadcast()
        MODE._startGiven = true
    end

    if (self.grace_time or 0) <= 0 then StartCombat() else timer.Create(GRACE_TIMER, self.grace_time, 1, StartCombat) end
end

function MODE:GiveEquipment()
    for _, ply in player.Iterator() do
        if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then continue end
        ply:StripWeapons()
        local handsClass = hg.GetHandsWeaponClass and hg.GetHandsWeaponClass(ply) or "weapon_hands_sh"
        ply:Give(handsClass)
        ply:SelectWeapon(handsClass)
    end
end

function MODE:RoundThink()
    local now = CurTime()
    local threshold = math.max(1, incapKillTime:GetFloat())
    for _, ply in player.Iterator() do
        if not ply:Alive() or ply:Team() == TEAM_SPECTATOR then self._incapSince[ply] = nil continue end
        local organism = ply.organism
        if organism and organism.incapacitated then self._incapSince[ply] = nil ply:Kill() continue end
        if not (organism and organism.otrub) then self._incapSince[ply] = nil continue end
        self._incapSince[ply] = self._incapSince[ply] or now
        if now - self._incapSince[ply] >= threshold then self._incapSince[ply] = nil ply:Kill() end
    end
end

function MODE:ShouldRoundEnd()
    return self._winner and true or nil
end

function MODE:EndRound()
    local generation = self._generation
    BuildLeaderboard()
    local fallback = self._leaderboard and self._leaderboard[1] and self._leaderboard[1].ply
    local winner = IsValid(self._winner) and self._winner or (IsValid(fallback) and fallback or NULL)
    local top = {}
    for index, rank in ipairs(self._leaderboard or {}) do
        top[index] = {name = IsValid(rank.ply) and rank.ply:Nick() or "", kills = rank.kills}
    end

    if IsValid(winner) and hg.achievements and hg.achievements.SetPlayerAchievement then
        local info = hg.achievements.GetAchievementInfo and hg.achievements.GetAchievementInfo("brawler")
        if info then hg.achievements.SetPlayerAchievement(winner, "brawler", 1) end
    end

    timer.Remove(ANNOUNCE_TIMER)
    timer.Remove(GRACE_TIMER)
    timer.Simple(2, function()
        if not IsBrawlGeneration(generation, false) then return end
        net.Start("brawl_end")
            net.WriteEntity(winner)
            net.WriteUInt(math.min(#top, 127), 7)
            for index = 1, math.min(#top, 127) do
                net.WriteString(top[index].name)
                net.WriteUInt(top[index].kills, 16)
            end
        net.Broadcast()
        net.Start("brawl_round_end") net.Broadcast()
    end)
end

function MODE:PlayerCanPickupWeapon(ply, weapon)
    if not IsValid(ply) or not IsValid(weapon) then return false end
    local class = weapon:GetClass()
    local handsClass = hg.GetHandsWeaponClass and hg.GetHandsWeaponClass(ply) or "weapon_hands_sh"
    if class == handsClass or self._granting[ply] or weapon:GetOwner() == ply then return true end
    return IsAllowedWeaponClass(class) and ply:KeyDown(IN_USE)
end

function MODE:PlayerCanDropWeapon()
    return false
end

function MODE:PlayerSpawn(ply)
    if not IsValid(ply) then return end
    self._incapSince[ply] = nil
    local progress = self.PlayerProgress[ply]

    if not progress and ply:Team() ~= TEAM_SPECTATOR then
        InitPlayer(ply)
        progress = self.PlayerProgress[ply]
        zb.GiveRole(ply, "Brawler", Color(190, 60, 60))
    end
    if not progress then return end

    local isRespawn = self._respawnDue[ply]
    if isRespawn then self._respawnDue[ply] = nil end
    local generation = self._generation
    timer.Simple(0, function()
        if not IsBrawlGeneration(generation, true) or not IsValid(ply) or not ply:Alive() then return end
        if isRespawn then
            -- SetupTeam is Judge's generic randomSpawns path; do not reposition again in this mode.
            ply:SetupTeam(0)
            ApplyAppearance(ply)
        end
        GiveProgressWeapon(ply, progress.stage >= progress.stagesTotal and progress.finalWeapon or progress.unlocked[progress.stage])
        SyncHUD(ply)
    end)
end

function MODE:PlayerDeath(victim, inflictor, attacker)
    if not IsBrawlGeneration(self._generation, true) or self._winner then return end
    if not IsValid(victim) or not victim:IsPlayer() then return end
    self._incapSince[victim] = nil
    RewardKill(victim, attacker)

    local progress = self.PlayerProgress[victim]
    if not progress then return end
    self._respawnDue[victim] = true
    local generation = self._generation
    local deathPos = victim:GetPos()

    if progress.stage >= progress.stagesTotal then
        progress.stage = math.max(math.min(progress.stagesTotal - 1, #progress.unlocked - 1), 1)
        SetFinalStage(victim, false)
        -- The victim is dead here. The downgraded weapon is granted by PlayerSpawn instead.
        SyncHUD(victim)
    end

    timer.Simple(0.05, function()
        if not IsBrawlGeneration(generation, true) then return end
        for _, entity in ipairs(ents.FindInSphere(deathPos, 96)) do
            if entity:IsWeapon() and not IsValid(entity:GetOwner()) then entity:Remove() end
        end
        if IsValid(victim.FakeRagdoll) then MakeDissolver(victim.FakeRagdoll, attacker) end
    end)

    timer.Simple(math.max(0, respawnDelay:GetFloat()), function()
        if not IsBrawlGeneration(generation, true) or not IsValid(victim) or victim:Alive() then return end
        victim:Spawn()
    end)
end

hook.Add("StartCommand", "brawl_grace_block", function(ply, command)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" or CurTime() >= (MODE._graceEnd or 0) then return end
    command:ClearButtons()
    command:ClearMovement()
end)

local function TrackDamage(victim, attacker, damage, class)
    if damage <= 0 or not IsAllowedWeaponClass(class) then return end
    lastHit[victim] = {attacker = attacker, class = class, time = CurTime()}
    MODE.DamageLog[victim] = MODE.DamageLog[victim] or {}
    local entry = MODE.DamageLog[victim][attacker] or {damage = 0, weapon = ""}
    entry.damage = entry.damage + damage
    entry.weapon = class
    MODE.DamageLog[victim][attacker] = entry
end

hook.Add("EntityTakeDamage", "brawl_track_damage", function(victim, damageInfo)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" or not victim:IsPlayer() then return end
    local attacker = damageInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    local weapon = attacker:GetActiveWeapon()
    if not IsValid(weapon) then return end
    TrackDamage(victim, attacker, damageInfo:GetDamage(), weapon:GetClass())
end)

hook.Add("HomigradDamage", "brawl_track_homigrad_damage", function(victim, damageInfo, hitgroup, entity, harm)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" then return end
    local attacker = damageInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() or not IsValid(victim) then return end
    local weapon = attacker:GetActiveWeapon()
    if not IsValid(weapon) then return end
    TrackDamage(victim, attacker, harm or 0, weapon:GetClass())
end)

hook.Add("PlayerSpawn", "brawl_clear_damage_claim", function(ply)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" then return end
    lastHit[ply] = nil
    MODE.DamageLog[ply] = nil
end)

hook.Add("PlayerDisconnected", "brawl_cleanup_player", function(ply)
    if MODE._finalPlayers[ply:EntIndex()] then SetFinalStage(ply, false) end
    MODE.PlayerProgress[ply] = nil
    MODE.DamageLog[ply] = nil
    MODE._respawnDue[ply] = nil
    MODE._granting[ply] = nil
    MODE._incapSince[ply] = nil
    lastHit[ply] = nil
end)

hook.Add("EntityFireBullets", "brawl_final_one_bullet", function(entity)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" then return end
    local owner = entity:IsPlayer() and entity or entity:GetOwner()
    local weapon = entity:IsWeapon() and entity or (IsValid(owner) and owner:GetActiveWeapon())
    if not IsValid(owner) or not IsValid(weapon) or weapon:GetClass() ~= MODE._roundFinalWeapon then return end
    local generation = MODE._generation
    timer.Simple(0, function()
        if IsBrawlGeneration(generation, true) then LimitFinalAmmo(owner, weapon) end
    end)
end)

hook.Add("PlayerSwitchWeapon", "brawl_final_switch_check", function(ply, oldWeapon, newWeapon)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" or not IsValid(newWeapon) then return end
    if newWeapon:GetClass() ~= MODE._roundFinalWeapon then return end
    local generation = MODE._generation
    timer.Simple(0, function()
        if IsBrawlGeneration(generation, true) then LimitFinalAmmo(ply, newWeapon) end
    end)
end)

hook.Add("PlayerPickupAmmo", "brawl_block_final_ammo", function(ply)
    local round = CurrentRound()
    if not round or round.name ~= "brawl" then return end
    local progress = MODE.PlayerProgress[ply]
    if progress and progress.stage >= progress.stagesTotal then return false end
end)
