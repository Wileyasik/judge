hg.achievements = hg.achievements or {}
hg.achievements.achievements_data = hg.achievements.achievements_data or {}
hg.achievements.achievements_data.player_achievements = hg.achievements.achievements_data.player_achievements or {}
hg.achievements.achievements_data.created_achevements = {}
hg.achievements.achievements_data.rarity = hg.achievements.achievements_data.rarity or {}

local function getRarityName(percent, owners)
    owners = tonumber(owners) or 0
    if owners == 0 then return "Exotic" end
    if owners == 1 or percent < 5 then return "Mythic" end
    if percent < 10 then return "Legendary" end
    if percent < 25 then return "Epic" end
    if percent < 50 then return "Rare" end
    return "Uncommon"
end

function hg.achievements.RefreshRarity()
    if not hg.achievements.SqlActive or hg.achievements.RarityRefreshing then return end

    hg.achievements.RarityRefreshing = true
    local query = mysql:Select("hg_achievements")
        query:Select("achievements")
        query:Callback(function(result)
            hg.achievements.RarityRefreshing = false
            if not istable(result) then return end

            local total = #result
            local owners = {}
            for _, row in ipairs(result) do
                local playerAchievements = util.JSONToTable(row.achievements or "") or {}
                for key, achievement in pairs(playerAchievements) do
                    local info = hg.achievements.GetAchievementInfo(key)
                    if info and istable(achievement) and (tonumber(achievement.value) or info.start_value) >= info.needed_value then
                        owners[key] = (owners[key] or 0) + 1
                    end
                end
            end

            local rarity = {}
            for key in pairs(hg.achievements.GetAchievements()) do
                local count = owners[key] or 0
                local percent = total > 0 and count / total * 100 or 0
                rarity[key] = {
                    name = getRarityName(percent, count),
                    owners = count,
                    total = total,
                    percent = math.Round(percent, 2)
                }
            end

            hg.achievements.achievements_data.rarity = rarity
            hg.achievements.RarityUpdatedAt = CurTime()
        end)
    query:Execute()
end

local function syncPlayerHeadshotAchievements(ply)
    if not IsValid(ply) or not hg.achievements.GetAchievementInfo("gollavo") then return end

    local steamID64 = ply:SteamID64()
    local achievements = hg.achievements.achievements_data.player_achievements[steamID64] or {}
    local headshots = math.max(tonumber(ply:GetPData("Headshots", 0)) or 0, tonumber(achievements.gollavo and achievements.gollavo.value) or 0)

    ply:SetPData("Headshots", headshots)
    ply:SetNWInt("Headshots", headshots)
    hg.achievements.SetPlayerAchievement(ply, "gollavo", headshots)
end

local function updatePlayer(ply)
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not hg.achievements.SqlActive then
        hg.achievements.achievements_data.player_achievements[steamID64] = {}
        return
    end

	local query = mysql:Select("hg_achievements")
		query:Select("achievements")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
            --print(result)
            --PrintTable(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].achievements) then
				local updateQuery = mysql:Update("hg_achievements")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

				local loaded = util.JSONToTable(result[1].achievements) or {}
				local current = hg.achievements.achievements_data.player_achievements[steamID64] or {}
				for key, value in pairs(current) do
					local loadedValue = loaded[key] and tonumber(loaded[key].value)
					local currentValue = istable(value) and tonumber(value.value)
					if not loadedValue or (currentValue and currentValue > loadedValue) then
						loaded[key] = value
					elseif currentValue == loadedValue and istable(value) and value.obtained_at and not loaded[key].obtained_at then
						loaded[key].obtained_at = value.obtained_at
					end
				end
				hg.achievements.achievements_data.player_achievements[steamID64] = loaded
				syncPlayerHeadshotAchievements(ply)

                --PrintTable(hg.achievements.achievements_data.player_achievements[steamID64])
			else
				local current = hg.achievements.achievements_data.player_achievements[steamID64] or {}
				local insertQuery = mysql:Insert("hg_achievements")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("achievements", util.TableToJSON(current))
				insertQuery:Execute()

				hg.achievements.achievements_data.player_achievements[steamID64] = current
				syncPlayerHeadshotAchievements(ply)
			end
		end)
	query:Execute()
end

hook.Add("DatabaseConnected", "AchievementsCreateData", function()
	local query

	query = mysql:Create("hg_achievements")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
        query:Create("achievements", "TEXT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    hg.achievements.SqlActive = true

    print("Achievements SQL database connected.")

    for i, ply in player.Iterator() do
        updatePlayer(ply)
    end

    timer.Simple(1, hg.achievements.RefreshRarity)
    timer.Create("hg_achievement_rarity_refresh", 300, 0, hg.achievements.RefreshRarity)
end)

hook.Add( "PlayerInitialSpawn","hg_Exp_OnInitSpawn", updatePlayer)
hook.Add("PlayerDisconnected", "savevalues", function(ply)
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end

    hg.achievements.SaveToSQL(ply)
end)

function hg.achievements.SaveToSQL(ply, data)
    if not hg.achievements.SqlActive then return end

    local name = ply:Name()
	local steamID64 = ply:SteamID64()
    local updateQuery = mysql:Update("hg_achievements")
        updateQuery:Update("achievements", util.TableToJSON(data or hg.achievements.GetPlayerAchievements(ply) or {}) )
        updateQuery:Update("steam_name", name)
        updateQuery:Where("steamid", steamID64)
    updateQuery:Execute()
end

function hg.achievements.SavePlayerAchievements()
    if !hg.achievements.SqlActive then print("Tried to save achievement data to SQL, but it is not active.") return end

    for k, ply in player.Iterator() do
        hg.achievements.SaveToSQL(ply)
    end
end

local replacement_img = "homigrad/vgui/models/star.png"

function hg.achievements.CreateAchievementType(key, needed_value, start_value, description, name, img, showpercent)
    img = img or replacement_img
    hg.achievements.achievements_data.created_achevements[key] = {
        start_value = start_value,
        needed_value = needed_value,
        description = description,
        name = name,
        img = img,
        key = key,
        showpercent = showpercent,
    }
end

hg.achievements.CreateAchievementType("gollavo", 333, 0, "Get 333 headshots.", "Sinister", nil, true)


function hg.achievements.GetAchievements()
    return hg.achievements.achievements_data.created_achevements
end


function hg.achievements.GetAchievementInfo(key)
    return hg.achievements.achievements_data.created_achevements[key]
end


function hg.achievements.GetPlayerAchievements(ply)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID]
end


function hg.achievements.GetPlayerAchievement(ply, key)
    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    return hg.achievements.achievements_data.player_achievements[steamID][key] or {}
end

function hg.achievements.IsUnlocked(ply, key)
    local ach = hg.achievements.GetAchievementInfo(key)
    if not ach then return false end
    local playerAch = hg.achievements.GetPlayerAchievement(ply, key)
    return (tonumber(playerAch.value) or tonumber(ach.start_value) or 0) >= tonumber(ach.needed_value)
end


local function isAchievementCompleted(ply, key, val)
    local ach = hg.achievements.achievements_data.created_achevements[key]
    if not ach then return false end

    local oldValue = hg.achievements.achievements_data.player_achievements[ply:SteamID64()][key].value or ach.start_value
    return val >= ach.needed_value and oldValue < ach.needed_value
end

util.AddNetworkString("hg_NewAchievement")

function hg.achievements.SetPlayerAchievement(ply, key, val)
    --print("Triggered achievement for player " .. ply:Name() .. " ; " .. ply:SteamID() .. ": " .. (key or "none") .. ", value " .. (val or "none"))
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    local ach = hg.achievements.GetAchievementInfo(key)
    if not ach then
        ErrorNoHalt("Unknown achievement key: " .. tostring(key) .. "\n")
        return false
    end

    val = tonumber(val)
    if not val then return false end

    local steamID = ply:SteamID64()
    hg.achievements.achievements_data.player_achievements[steamID] = hg.achievements.achievements_data.player_achievements[steamID] or {}
    local playerAchievements = hg.achievements.achievements_data.player_achievements[steamID]
    playerAchievements[key] = playerAchievements[key] or {}

    local completedNow = isAchievementCompleted(ply, key, val)
    playerAchievements[key].value = val

    if completedNow then
        local wasObtainedBefore = playerAchievements[key].obtained_at ~= nil
        playerAchievements[key].obtained_at = playerAchievements[key].obtained_at or os.time()
        local rarity = hg.achievements.achievements_data.rarity[key] or {owners = 0, total = 0, percent = 0}
        local unlockRarityName = getRarityName(tonumber(rarity.percent) or 0, tonumber(rarity.owners) or 0)
        rarity.owners = math.min((tonumber(rarity.owners) or 0) + (wasObtainedBefore and 0 or 1), math.max(tonumber(rarity.total) or 0, 1))
        rarity.total = math.max(tonumber(rarity.total) or 0, 1)
        rarity.percent = math.Round(rarity.owners / rarity.total * 100, 2)
        rarity.name = getRarityName(rarity.percent, rarity.owners)
        hg.achievements.achievements_data.rarity[key] = rarity

        net.Start("hg_NewAchievement")
            net.WriteString(ach.name)
            net.WriteString(ach.img)
            net.WriteString(unlockRarityName)
        net.Send(ply)

        hg.achievements.SaveToSQL(ply, playerAchievements)
        timer.Simple(3, hg.achievements.RefreshRarity)
    end

    return true
end

function hg.achievements.AddPlayerAchievement(ply, key, val)
    if not IsValid(ply) or not ply:IsPlayer() then return false end

    val = tonumber(val)
    if not val or val < 0 then return false end

    local ach_info = hg.achievements.GetAchievementInfo(key)
    if not ach_info then
        ErrorNoHalt("Unknown achievement key: " .. tostring(key) .. "\n")
        return false
    end

    local ach = hg.achievements.GetPlayerAchievement(ply, key)

    return hg.achievements.SetPlayerAchievement(ply, key, math.Approach(ach.value or ach_info.start_value, ach_info.needed_value, val))
end

util.AddNetworkString("req_ach")

net.Receive("req_ach", function(len, ply)
    if (ply.ach_cooldown or 0) > CurTime() then return end
    ply.ach_cooldown = CurTime() + 2
    net.Start("req_ach")
        net.WriteTable(hg.achievements.GetAchievements())
        net.WriteTable(hg.achievements.GetPlayerAchievements(ply))
        net.WriteTable(hg.achievements.achievements_data.rarity)
    net.Send(ply)

    if (hg.achievements.RarityUpdatedAt or 0) + 300 < CurTime() then
        hg.achievements.RefreshRarity()
    end
end)

//if !hg.init_ach then
    -- braindeath
    hg.achievements.CreateAchievementType("brain",1,0,"Die from hypoxia.","I will definitely survive...", nil, false)
    -- death from drugs
    hg.achievements.CreateAchievementType("drugs",1,0,"Die from opioids overdose.","Overstimulated", nil, false)
    -- TERMINATOR
    hg.achievements.CreateAchievementType("illbeback",3,0,"Get shot in the head and get up alive.","I'll be back", nil, true)
    -- kill everyone
    hg.achievements.CreateAchievementType("killemall",1,0,"Kill everyone being a traitor and win the round\nplayers on the server should be more than 9.","Kill Em All", nil, false)
    -- russian roulette
    hg.achievements.CreateAchievementType("deadlygambling",10,0,"Pull the trigger of an empty revolver 10 times in one life.","Deadly Gambling", nil, true)
    -- lobotomized kill
    hg.achievements.CreateAchievementType("lobotomygaming",1,0,"Kill the traitor while having brain damage","Hydrogen bomb vs Lobotomized patient", nil, false)
    -- hot potato
    hg.achievements.CreateAchievementType("hotpotato",1,0,"Kill the traitor using his own grenade","Hot Potato", nil, false)
    -- please calm down
    hg.achievements.CreateAchievementType("bking", 1, 0, "Something terrible happened on that plane...", "Sir please calm down", nil, false)
    hg.achievements.CreateAchievementType("deadinside", 100, 0, "Die 100 times.", "Dead Inside", nil, true)
    hg.achievements.CreateAchievementType("socialite", 250, 0, "Send 250 chat messages.", "Socialite", nil, true)
    hg.achievements.CreateAchievementType("wakeupcall", 25, 0, "Wake up from unconscious state 25 times.", "Wake Up Call", nil, true)
    hg.achievements.CreateAchievementType("headmagnet", 50, 0, "Take 50 hits to the head and survive long enough to count them.", "Head Magnet", nil, true)
    hg.achievements.CreateAchievementType("veteran", 100, 0, "Finish 100 rounds.", "Veteran", nil, true)
    hg.achievements.CreateAchievementType("meet_wiley", 1, 0, "Meet player with SteamID STEAM_0:0:601135498.", "Meet Wiley", nil, false)
    hg.achievements.CreateAchievementType("meet_lazzy", 1, 0, "Meet player with SteamID STEAM_0:1:458217437.", "Meet Lazzy", nil, false)
    hg.achievements.CreateAchievementType("slayersword_pickup", 1, 0, "Pick up weapon_hg_slayersword.", "How did you pick it up..", nil, false)
    hg.achievements.CreateAchievementType("whole_team_is_here", 1, 0, "Meet all of Wiley's best friends on the server at the same time.", "Whole team is here!", nil, false)
    hg.achievements.CreateAchievementType("butterfingers", 4, 0, "Lose 4 limbs. Apparently they were optional.", "Nick Vujicic", nil, true)
    hg.achievements.CreateAchievementType("human_bowling", 10, 0, "Knock 10 people down with flying ragdolls.", "Human Bowling", nil, true)
    hg.achievements.CreateAchievementType("professional_looter", 50, 0, "Check 50 inventories that do not belong to you. Evidence is temporary.", "Professional Looter", nil, true)
    hg.achievements.CreateAchievementType("this_is_fine", 10, 0, "Catch fire 10 times. Remain optimistic.", "Bacon", nil, true)
    hg.achievements.CreateAchievementType("dying_light", 25, 0, "Dropkick 25 people. Kyle Crane would be proud.", "Dying Light", nil, true)
    hg.achievements.CreateAchievementType("git_gud", 1, 0, "Kill yourself with your own grenade.", "Git Gud", nil, false)
    hg.achievements.CreateAchievementType("london", 28, 0, "Take 28 knife wounds in one life. OI! Where are you going mate?", "London", nil, true)
    hg.achievements.CreateAchievementType("john_wicks_heir", 439, 0, "Deliver 439 fatal pistol headshots. The Baba Yaga returns.", "John Wick's Heir", nil, true)
    -- Splinter Cell: unlocks weapon_sam_fisher_glock
    hg.achievements.CreateAchievementType("samfisher", 10, 0, "Kill 10 enemies with a silenced weapon.", "Splinter Cell", "entities/sam.png", true)

    //hg.init_ach = true
//end

local roundply = 0
local roundInnocents = 0

hook.Add("ZB_StartRound","hg_killemall_Acchivment",function()
    roundply = 0
	roundInnocents = 0
	for _, ply in player.Iterator() do
		ply.TraitorKills = 0
		if ply:Alive() then
			roundply = roundply + 1
			if not ply.isTraitor then roundInnocents = roundInnocents + 1 end
		end
	end
end)

hook.Add("ZB_TraitorWinOrNot","hg_killemall_Acchivment",function(ply,winner)
    --if gmod.GetGamemode() ~= "zcity" then return end

    if IsValid(ply) and winner == 1 and (ply.TraitorKills or 0) >= roundInnocents and roundply >= 10 then
        hg.achievements.SetPlayerAchievement(ply,"killemall",1)
    end
end)

hook.Add("PlayerDeath", "hg_killemall_Acchivment", function(ply, inflictor, attacker)
    hg.achievements.AddPlayerAchievement(ply, "deadinside", 1)

    local london = hg.achievements.GetPlayerAchievement(ply, "london")
    if (london.value or 0) < 28 then
        hg.achievements.SetPlayerAchievement(ply, "london", 0)
    end

    if IsValid(inflictor) and inflictor.ishggrenade then
        local grenadeOwner = IsValid(inflictor.owner) and inflictor.owner or inflictor.owner2
        if attacker == ply or grenadeOwner == ply then
            hg.achievements.SetPlayerAchievement(ply, "git_gud", 1)
        end
    end

    local ach = hg.achievements.GetPlayerAchievement(ply,"deadlygambling")
    if ach["value"] ~= 10 and ach["value"] ~= 0 then
        hg.achievements.SetPlayerAchievement(ply, "deadlygambling", 0)
    end

    if ply.isTraitor then
        if IsValid(attacker) and attacker:IsPlayer() and ply ~= attacker then
            if attacker:Alive() and attacker.organism and attacker.organism.brain >= 0.1 then
                hg.achievements.SetPlayerAchievement(attacker, "lobotomygaming", 1)
            end

            if IsValid(inflictor) and inflictor.ishggrenade and inflictor.owner2 == ply and IsValid(inflictor.owner) and inflictor.owner ~= ply then
                hg.achievements.SetPlayerAchievement(inflictor.owner, "hotpotato", 1)
            end
        end

        ply.TraitorKills = 0

        return
    end

    if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply and attacker.isTraitor then
        attacker.TraitorKills = (attacker.TraitorKills or 0) + 1
    end
end)

hook.Add("HomigradDamage", "hg_git_gud_track", function(victim, dmgInfo)
    if not IsValid(victim) or not victim:IsPlayer() then return end

    local grenade = dmgInfo:GetInflictor()
    if IsValid(grenade) and grenade.ishggrenade then
        local grenadeOwner = IsValid(grenade.owner) and grenade.owner or grenade.owner2
        if dmgInfo:GetAttacker() == victim or grenadeOwner == victim then
            victim.GitGudLastHit = CurTime()
            return
        end
    end

    if dmgInfo:GetDamage() > 0 then victim.GitGudLastHit = nil end
end)

hook.Add("Player_Death", "hg_git_gud_achievement", function(victim)
    local hitTime = victim.GitGudLastHit
    victim.GitGudLastHit = nil
    if hitTime and CurTime() - hitTime <= 30 then
        hg.achievements.SetPlayerAchievement(victim, "git_gud", 1)
    end
end)

hook.Add("PlayerSilentDeath","hg_killemall_Acchivment",function(ply)
    local london = hg.achievements.GetPlayerAchievement(ply, "london")
    if (london.value or 0) < 28 then hg.achievements.SetPlayerAchievement(ply, "london", 0) end
    if ply.isTraitor then ply.TraitorKills = 0 return end
end)

hook.Add("PlayerSpawn", "hg_london_reset", function(ply)
    ply.LondonLastKnifeHits = nil
    ply.JohnWickLastHit = nil
    ply.GitGudLastHit = nil
    local london = hg.achievements.GetPlayerAchievement(ply, "london")
    if (london.value or 0) < 28 then hg.achievements.SetPlayerAchievement(ply, "london", 0) end
end)

hook.Add("HomigradDamage","hg_illbeback_Acchivment",function(ply, dmgInfo, hitgroup, ent, harm, hitBoxs)
    --if gmod.GetGamemode() ~= "zcity" then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not dmgInfo:IsDamageType(DMG_BULLET) or hitgroup ~= HITGROUP_HEAD then return end

    timer.Simple(0, function()
        if IsValid(ply) and ply:Alive() then
            hg.achievements.AddPlayerAchievement(ply, "headmagnet", 1)
        end
    end)

    local value = hg.achievements.GetPlayerAchievement(ply, "illbeback").value or 0
    if value == 0 then
        hg.achievements.SetPlayerAchievement(ply, "illbeback", 1)
        ply.illbeback = CurTime() + 10
    end
end)

local function getDamageWeapon(dmgInfo)
    local inflictor = dmgInfo:GetInflictor()
    if IsValid(inflictor) and IsValid(inflictor.weapon) then inflictor = inflictor.weapon end
    if IsValid(inflictor) and inflictor:IsWeapon() then return inflictor end

    local attacker = dmgInfo:GetAttacker()
    local activeWeapon = IsValid(attacker) and attacker:IsPlayer() and attacker:GetActiveWeapon()
    return IsValid(activeWeapon) and activeWeapon or nil
end

local function isKnifeWeapon(wep)
    if not IsValid(wep) or not (wep.ismelee2 or wep.Base == "weapon_melee") then return false end
    if wep.IsKnifeWeapon then return wep:IsKnifeWeapon() end

    local class = string.lower(wep:GetClass())
    return class:find("knife", 1, true) ~= nil or class:find("bayonet", 1, true) ~= nil
end

local function isPistolWeapon(wep)
    if not IsValid(wep) or wep.ismelee2 or wep.Base == "weapon_melee" then return false end
    if wep.IsPistol ~= nil then return wep.IsPistol == true end
    if wep.IsPistolHoldType and wep:IsPistolHoldType() and (wep:GetMaxClip1() or 0) <= 20 then return true end

    local info = string.lower(wep:GetClass() .. " " .. tostring(wep.Category or "") .. " " .. tostring(wep.PrintName or ""))
    return info:find("pistol", 1, true) ~= nil or info:find("revolver", 1, true) ~= nil or info:find("glock", 1, true) ~= nil or info:find("deagle", 1, true) ~= nil or info:find("usp", 1, true) ~= nil
end

hook.Add("HomigradDamage", "hg_london_achievement", function(ply, dmgInfo)
    if not IsValid(ply) or not ply:IsPlayer() or not dmgInfo:IsDamageType(DMG_SLASH) then return end

    local wep = getDamageWeapon(dmgInfo)
    if not isKnifeWeapon(wep) or (tonumber(dmgInfo:GetDamage()) or 0) <= 0 then return end
    if wep.ShouldAttackOnce and wep.attackedOnce then return end

    local attacker = dmgInfo:GetAttacker()
    local hitKey = tostring(IsValid(attacker) and attacker:EntIndex() or 0) .. ":" .. tostring(wep:EntIndex())
    ply.LondonLastKnifeHits = ply.LondonLastKnifeHits or {}
    if ply.LondonLastKnifeHits[hitKey] == engine.TickCount() then return end
    ply.LondonLastKnifeHits[hitKey] = engine.TickCount()

    hg.achievements.AddPlayerAchievement(ply, "london", 1)
end)

hook.Add("HomigradDamage", "hg_john_wicks_heir_track", function(victim, dmgInfo, hitgroup)
    if not IsValid(victim) or not victim:IsPlayer() then return end

    victim.JohnWickLastHit = nil

    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end

    local wep = getDamageWeapon(dmgInfo)
    if hitgroup == HITGROUP_HEAD and dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT) and isPistolWeapon(wep) then
        victim.JohnWickLastHit = {attacker = attacker, time = CurTime()}
    else
        victim.JohnWickLastHit = nil
    end
end)

hook.Add("Player_Death", "hg_john_wicks_heir_achievement", function(victim)
    local hit = victim.JohnWickLastHit
    victim.JohnWickLastHit = nil
    if not hit or CurTime() - hit.time > 1 or not IsValid(hit.attacker) then return end

    hg.achievements.AddPlayerAchievement(hit.attacker, "john_wicks_heir", 1)
end)

hook.Add("HG_OnOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if not IsValid(ply) then return end
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 1 and (ply.illbeback or 0) > CurTime() then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",2)
    end
end)

hook.Add("PlayerDeath","hg_illbeback_Acchivment",function(ply)
    local val = hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"]
    if val ~= 3 and val ~= 0 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback", 0)
    end
end)

hook.Add("PlayerSilentDeath","hg_illbeback_Acchivment",function(ply)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] ~= 3 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",0)
    end
end)

hook.Add("HG_OnWakeOtrub","hg_illbeback_Acchivment",function(ply)
    if ply:IsRagdoll() then
        ply = hg.RagdollOwner(ply)
    end
    if not IsValid(ply) then return end
    hg.achievements.AddPlayerAchievement(ply, "wakeupcall", 1)
    if hg.achievements.GetPlayerAchievement(ply,"illbeback")["value"] == 2 then
        hg.achievements.SetPlayerAchievement(ply,"illbeback",3)
    end
end)

local tblToFind_bking = {
    {"sir","sir"},
    {"сэр","sir"},
    {"please","please"},
    {"пожалуйста","please"},
    {"calm down","calm down"},
	{"успокойтесь","calm down"}
}
hook.Add("HG_PlayerChatSent","burgerking",function(ply, txt)
    hg.achievements.AddPlayerAchievement(ply, "socialite", 1)
    local bking = {
        ["sir"] = false,
        ["please"] = false,
        ["calm down"] = false
    }
    for _, v in ipairs(tblToFind_bking) do
        local found = string.find( txt:lower(), v[1] )
        --print(found)
        if found then
            bking[v[2]] = true
        end
    end

    if bking["sir"] and bking["please"] and bking["calm down"] then
        hg.achievements.SetPlayerAchievement(ply,"bking",1)
		if ply.PS_AddItem then ply:PS_AddItem("burger king crown") end
    end
end)

hook.Add("ZB_EndRound", "hg_roundsplayed_achievement", function()
    for _, target in player.Iterator() do
        if IsValid(target) then
            hg.achievements.AddPlayerAchievement(target, "veteran", 1)
        end
    end
end)

local WILEY_STEAM_ID = "STEAM_0:0:601135498"
local LAZZY_STEAM_ID = "STEAM_0:1:458217437"
local WILEY_FRIENDS_STEAM_IDS = {
    ["STEAM_0:1:460477593"] = true,
    ["STEAM_0:1:458217437"] = true,
    ["STEAM_0:1:466499179"] = true
}

local function TryGiveMeetWileyAchievement(ply)
    if not IsValid(ply) then return end
    if ply:SteamID() == WILEY_STEAM_ID then return end

    for _, target in player.Iterator() do
        if IsValid(target) and target ~= ply and target:SteamID() == WILEY_STEAM_ID then
            hg.achievements.SetPlayerAchievement(ply, "meet_wiley", 1)
            return
        end
    end
end

local function TryGiveMeetLazzyAchievement(ply)
    if not IsValid(ply) then return end
    if ply:SteamID() == LAZZY_STEAM_ID then return end

    for _, target in player.Iterator() do
        if IsValid(target) and target ~= ply and target:SteamID() == LAZZY_STEAM_ID then
            hg.achievements.SetPlayerAchievement(ply, "meet_lazzy", 1)
            return
        end
    end
end

local function AreAllWileyFriendsOnline()
    local found = {
        ["STEAM_0:1:460477593"] = false,
        ["STEAM_0:1:458217437"] = false,
        ["STEAM_0:1:466499179"] = false
    }

    for _, target in player.Iterator() do
        if IsValid(target) and WILEY_FRIENDS_STEAM_IDS[target:SteamID()] then
            found[target:SteamID()] = true
        end
    end

    return found["STEAM_0:1:460477593"] and found["STEAM_0:1:458217437"] and found["STEAM_0:1:466499179"]
end

local function TryGiveWholeTeamIsHereAchievement()
    if not AreAllWileyFriendsOnline() then return end

    for _, target in player.Iterator() do
        if IsValid(target) then
            hg.achievements.SetPlayerAchievement(target, "whole_team_is_here", 1)
        end
    end
end

hook.Add("PlayerInitialSpawn", "hg_meet_wiley_achievement", function(ply)
    timer.Simple(2, function()
        if not IsValid(ply) then return end
        TryGiveMeetWileyAchievement(ply)
        TryGiveMeetLazzyAchievement(ply)
        TryGiveWholeTeamIsHereAchievement()

        if ply:SteamID() == WILEY_STEAM_ID then
            for _, target in player.Iterator() do
                if IsValid(target) and target ~= ply then
                    hg.achievements.SetPlayerAchievement(target, "meet_wiley", 1)
                end
            end
        end

        if ply:SteamID() == LAZZY_STEAM_ID then
            for _, target in player.Iterator() do
                if IsValid(target) and target ~= ply then
                    hg.achievements.SetPlayerAchievement(target, "meet_lazzy", 1)
                end
            end
        end
    end)
end)

hook.Add("WeaponEquip", "hg_slayersword_pickup_achievement", function(wep, ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not IsValid(wep) then return end
    if wep:GetClass() ~= "weapon_hg_slayersword" then return end

    hg.achievements.SetPlayerAchievement(ply, "slayersword_pickup", 1)
end)

hook.Add("HG_RussianRouletteSurvived", "hg_deadlygambling_achievement", function(ply)
    hg.achievements.AddPlayerAchievement(ply, "deadlygambling", 1)
end)

hook.Add("OnAmputateLimb", "hg_butterfingers_achievement", function(org)
    local ply = org and org.owner
    if IsValid(ply) and ply:IsPlayer() then
        hg.achievements.AddPlayerAchievement(ply, "butterfingers", 1)
    end
end)

hook.Add("ZC_SomeoneGetFallBy", "hg_human_bowling_achievement", function(attacker, victim)
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) and attacker ~= victim and (victim.achievementBowledAt or 0) < CurTime() then
        victim.achievementBowledAt = CurTime() + 2
        hg.achievements.AddPlayerAchievement(attacker, "human_bowling", 1)
    end
end)

hook.Add("ZB_InventoryChecked", "hg_professional_looter_achievement", function(ply, ent)
    if IsValid(ply) and ply:IsPlayer() and IsValid(ent) and ent ~= ply and not ply.keypressed and ent:GetNetVar("Inventory") then
        hg.achievements.AddPlayerAchievement(ply, "professional_looter", 1)
    end
end)

hook.Add("HG_PlayerDropkicked", "hg_dying_light_achievement", function(attacker, victim)
    if IsValid(attacker) and attacker:IsPlayer() and IsValid(victim) and victim:IsPlayer() and attacker ~= victim then
        hg.achievements.AddPlayerAchievement(attacker, "dying_light", 1)
    end
end)

hook.Add("vFireEntityStartedBurning", "hg_this_is_fine_achievement", function(ent)
    local ply = IsValid(ent) and ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
    if IsValid(ply) and ply:IsPlayer() then
        hg.achievements.AddPlayerAchievement(ply, "this_is_fine", 1)
    end
end)

-- Splinter Cell: kill 10 enemies with a silenced weapon to unlock weapon_sam_fisher_glock.
local function isSilencedWeapon(wep)
    if not IsValid(wep) or not wep.HasAttachment or not wep.attachments then return false end
    if not wep:HasAttachment("barrel", "supressor") then return false end

    local id = wep.attachments.barrel and wep.attachments.barrel[1]
    if not isstring(id) or id == "supressor0" or id == "empty" then return false end

    return true
end

hook.Add("HomigradDamage", "hg_splinter_cell_track", function(victim, dmgInfo)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not (dmgInfo:IsDamageType(DMG_BULLET) or dmgInfo:IsDamageType(DMG_BUCKSHOT)) then return end

    victim.SamFisherLastHit = nil

    local attacker = dmgInfo:GetAttacker()
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker == victim then return end
    if (tonumber(dmgInfo:GetDamage()) or 0) <= 0 then return end

    local wep = getDamageWeapon(dmgInfo)
    if isSilencedWeapon(wep) then
        victim.SamFisherLastHit = {attacker = attacker, time = CurTime()}
    end
end)

hook.Add("Player_Death", "hg_splinter_cell_achievement", function(victim)
    local hit = victim.SamFisherLastHit
    victim.SamFisherLastHit = nil
    if not hit or CurTime() - hit.time > 1 or not IsValid(hit.attacker) then return end

    hg.achievements.AddPlayerAchievement(hit.attacker, "samfisher", 1)
end)
