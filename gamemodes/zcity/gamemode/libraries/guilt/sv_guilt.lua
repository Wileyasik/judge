zb = zb or {}

zb.GuiltTable = zb.GuiltTable or {}
zb.HarmDone = zb.HarmDone or {}
zb.HarmDoneKarma = zb.HarmDoneKarma or {}
zb.HarmReturnedKarma = zb.HarmReturnedKarma or {}
zb.HarmReceivedKarma = zb.HarmReceivedKarma or {}
zb.HarmDoneDetailed = zb.HarmDoneDetailed or {}
zb.HarmAttacked = zb.HarmAttacked or {}
zb.KarmaEarned = zb.KarmaEarned or {}
zb.GuiltSQL = zb.GuiltSQL or {}
zb.GuiltSQL.PlayerInstances = zb.GuiltSQL.PlayerInstances or {}

local hg_developer = ConVarExists("hg_developer") and GetConVar("hg_developer") or CreateConVar("hg_developer",0,FCVAR_SERVER_CAN_EXECUTE,"Toggle developer mode (enables damage traces)",0,1)

util.AddNetworkString("karma_down_sound")

function zb.PlayKarmaSound(ply, pitch)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	net.Start("karma_down_sound")
		net.WriteFloat(pitch or 100)
	net.Send(ply)
end

hook.Add("DatabaseConnected", "GuiltCreateData", function()
	local query

	query = mysql:Create("zb_guilt")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:Create("value", "FLOAT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    zb.GuiltSQL.Active = true
end)

hook.Add( "PlayerInitialSpawn","ZB_GuiltSQL", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

	local query = mysql:Select("zb_guilt")
		query:Select("value")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].value) then
				local updateQuery = mysql:Update("zb_guilt")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

				zb.GuiltSQL.PlayerInstances[steamID64] = {}

                zb.GuiltSQL.PlayerInstances[steamID64].value = tonumber(result[1].value)

                ply.Karma = ply:guilt_GetValue()
                ply:SetNetVar("Karma", ply.Karma)

                if zb.GuiltSQL.PlayerInstances[steamID64].value < 0 then
                    ply:guilt_SetValue( 10 )
                    local karma = ply.Karma

                    ply.Karma = 10
                    ply:SetNetVar("Karma", ply.Karma)

                    timer.Simple(0, function()
                        ply:Ban(5, false)
                        ply:Kick("Your karma is too low: " .. math.Round( karma, 0 ) .. ". Try again in 5 minutes." )
                    end)
                end
			else
				local insertQuery = mysql:Insert("zb_guilt")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("value", 100)
				insertQuery:Execute()

				zb.GuiltSQL.PlayerInstances[steamID64] = {}

				zb.GuiltSQL.PlayerInstances[steamID64].value = 100

                ply.Karma = ply:guilt_GetValue()
                ply:SetNetVar("Karma",ply.Karma)
			end
		end)
	query:Execute()

end)

local plyMeta = FindMetaTable("Player")

function plyMeta:guilt_GetValue()

    return zb.GuiltSQL.PlayerInstances[self:SteamID64()] and zb.GuiltSQL.PlayerInstances[self:SteamID64()].value or 100

end

function plyMeta:guilt_SetValue( zb_guilt )

    local steamID64 = self:SteamID64()
	
	zb.GuiltSQL.PlayerInstances[self:SteamID64()] = zb.GuiltSQL.PlayerInstances[self:SteamID64()] or {}
	zb.GuiltSQL.PlayerInstances[self:SteamID64()].value = zb.GuiltSQL.PlayerInstances[self:SteamID64()].value or 100
	
    zb.GuiltSQL.PlayerInstances[self:SteamID64()].value = zb_guilt

	local updateQuery = mysql:Update("zb_guilt")
		updateQuery:Update("value", zb_guilt)
		updateQuery:Where("steamid", steamID64)
	updateQuery:Execute()
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.8
end

function zb.SelfDefenseFactor(Victim, Attacker)
    if not Victim:IsPlayer() or not IsValid(Attacker) then return 1 end

    local victimWep = IsValid(Victim:GetActiveWeapon()) and Victim:GetActiveWeapon()
    local inMeleeRange = Victim:EyePos():DistToSqr(Attacker:EyePos()) <= (90 * 90)

    if inMeleeRange and victimWep then
        local isMelee = victimWep.ismelee2 or (victimWep:GetClass() == "weapon_hands_sh" and victimWep:GetFists())
        if isMelee then return 0.2 end
    end

    if IsLookingAt(Victim, Attacker:EyePos()) and victimWep then
        if ishgweapon(victimWep) then return 0.5 end
        if (victimWep:GetClass() == "weapon_hands_sh" and victimWep:GetFists() or victimWep.ismelee2) and inMeleeRange then
            return 0.5
        end
    end

    return 1
end

hook.Add("HomigradDamage", "GuiltReg", function(ply, dmgInfo, hitgroup, ent, harm) 
    local Attacker, Victim = dmgInfo:GetAttacker(), ply
    
    if not IsValid(Attacker) or not Attacker:IsPlayer() then return end
    if not IsValid(Victim) or not (Victim:IsPlayer() or (Victim.organism.fakePlayer and Victim.organism.alive)) then return end
	if Victim:IsNPC() or Victim:IsNextBot() then return end

    local id = Victim:IsPlayer() and Victim:SteamID() or Victim:EntIndex()
    local id2 = Attacker:IsPlayer() and Attacker:SteamID() or Attacker:EntIndex()
    local maxharm = zb.MaximumHarm
    local damage = dmgInfo:GetDamage()
    harm = tonumber(harm) or 0

    if damage and damage > 0 then
        local damageHarm = math.Clamp(damage / 10, 0, maxharm)
        if hitgroup == HITGROUP_HEAD and damage >= 15 then
            damageHarm = math.max(damageHarm, maxharm * 0.75)
        end

        harm = math.max(harm, damageHarm)
    end

    zb.HarmDone[Victim] = zb.HarmDone[Victim] or {}
    zb.HarmDoneDetailed[id] = zb.HarmDoneDetailed[id] or {}
    zb.HarmDoneKarma[Victim] = zb.HarmDoneKarma[Victim] or {}
    zb.HarmDoneKarma[Victim][Attacker] = zb.HarmDoneKarma[Victim][Attacker] or 0
    
    local oldharmdone = zb.HarmDone[Victim][Attacker] or 0
    zb.HarmDone[Victim][Attacker] = math.Clamp((zb.HarmDone[Victim][Attacker] or 0) + harm, 0, maxharm)
    
    zb.HarmAttacked[Attacker] = zb.HarmAttacked[Attacker] or 0
    zb.HarmAttacked[Attacker] = zb.HarmAttacked[Attacker] + harm

    local newharm = math.min(harm + oldharmdone, maxharm)
    local harm = newharm - oldharmdone
    local amt = (harm / maxharm) ^ 1.12

    if zb and zb.hostage and Victim == zb.hostage then
        zb.hostageLastTouched = Attacker
    end

    local attackerTeam = dmgInfo:GetInflictor().team or (Attacker:IsPlayer() and Attacker:Team()) or Attacker.team
    zb.HarmDoneDetailed[id][id2] = {
        harm = newharm,
        amt = newharm / maxharm,
        teamVictim = Victim:IsPlayer() and Victim:Team() or Victim.team or -1,
        teamAttacker = attackerTeam or -1,
        lasthitgroup = hitgroup,
        lastdmgtype = dmgInfo:GetDamageType(),
        lastattacked = CurTime(),
    }

    if hg_developer:GetBool() then
        Attacker:ChatPrint("This harm done is: "..math.Round(harm,3))
        Attacker:ChatPrint("Overall amt done is: "..math.Round(amt,3))
        Attacker:ChatPrint("Overall harm done is: "..math.Round(newharm,3))
        Attacker:ChatPrint("Guilt done is: "..math.Round(amt * 60,3))
        Attacker:ChatPrint(" ")
    end

    hook.Run("HarmDone", Attacker, Victim, amt)

    Victim = hg.GetCurrentCharacter(Victim) or Victim
    Victim = hg.RagdollOwner(Victim) or Victim

    local rnd, cround = CurrentRound()
    
    if rnd.GuiltDisabled or GetConVar("zb_dev"):GetBool() then return end

    if Attacker == Victim then return end

    local isEnemyKill = newharm >= maxharm and oldharmdone < newharm
    if isEnemyKill then
        local enemyKill
        if rnd.name == "hmcd" then
            enemyKill = Victim.isTraitor and not Attacker.isTraitor
        else
            enemyKill = attackerTeam ~= (Victim:IsPlayer() and Victim:Team() or Victim.team or -1)
        end

        if enemyKill then
            zb.KarmaEarned[Attacker] = zb.KarmaEarned[Attacker] or 0
            if zb.KarmaEarned[Attacker] < zb.KarmaEnemyKillCap then
                zb.KarmaEarned[Attacker] = zb.KarmaEarned[Attacker] + 1
                Attacker.Karma = math.Clamp((Attacker.Karma or 100) + zb.KarmaEnemyKillReward, 0, zb.MaxKarma)
                Attacker:SetNetVar("Karma", Attacker.Karma)
            end
        end
    end

    zb.GuiltTable[Attacker] = zb.GuiltTable[Attacker] or {}
    zb.GuiltTable[Victim] = zb.GuiltTable[Victim] or {}
    zb.HarmDoneKarma[Victim] = zb.HarmDoneKarma[Victim] or {}
    zb.HarmDoneKarma[Victim][Attacker] = zb.HarmDoneKarma[Victim][Attacker] or 0
    
    Attacker.LastAttacked = CurTime()

    if Victim.isTraitor and !Attacker.isTraitor and !zb.IsForce(Attacker) then return end
    if Attacker.isTraitor and !Victim.isTraitor then return end
    
    if rnd.name != "hmcd" and (Attacker.Team and Victim.Team and attackerTeam ~= Victim:Team()) then return end
    if zb.ROUND_STATE != 1 and (rnd.name != "cstrike" or !zb.RoundsLeft) then return end
    if Victim.Guilt and Victim.Guilt > 1 and !zb.IsForce(Attacker) then return end
    if Attacker:IsBerserk() then return end

    amt = amt * 1
        * (Victim:IsPlayer() and math.Clamp(((Victim.Karma or 100) / 100), 1, 1.2) or 1)
        * (Victim:IsPlayer() and zb.SelfDefenseFactor(Victim, Attacker) or 1)

    local add = amt * maxharm * (zb.KarmaGuiltMul or 1)

    add = add * (Victim:IsPlayer() and Attacker:PlayerClassEvent("Guilt", Victim) or 1)
    add = add * 1

    local mul, shouldBanGuilt
    
    if rnd.GuiltCheck then
        mul, shouldBanGuilt = rnd.GuiltCheck(Attacker, Victim, add, harm, amt)

        add = add * (mul or 1)
    end
    
    local guiltadd = amt * 60
    local now = CurTime()
    if (Attacker.karmaKillStreakUntil or 0) < now then
        Attacker.karmaKillStreak = 0
    end
    local isKill = newharm >= maxharm and oldharmdone < newharm
    if isKill then
        Attacker.karmaKillStreak = (Attacker.karmaKillStreak or 0) + 1
        Attacker.karmaKillStreakUntil = now + 90
    end
    local streak = math.max(Attacker.karmaKillStreak or 0, 1)
    local streakMul = math.min(1 + 0.5 * (streak - 1), 3)
    local maxLoss = ((zb.IsForce(Attacker) and 50 or 30) + 15 * (streak - 1)) * (zb.KarmaGuiltMul or 1)
    local karmaDone = zb.HarmDoneKarma[Victim][Attacker]
    zb.HarmReturnedKarma[Attacker] = zb.HarmReturnedKarma[Attacker] or {}
    local karmaReturn = math.max(((zb.HarmDoneKarma[Attacker] and zb.HarmDoneKarma[Attacker][Victim] or 0) * 0.5) - (zb.HarmReturnedKarma[Attacker][Victim] or 0), 0)
    zb.HarmReturnedKarma[Attacker][Victim] = (zb.HarmReturnedKarma[Attacker][Victim] or 0) + karmaReturn
    add = math.Clamp(add * (isKill and streakMul or 1), 0, math.max(maxLoss - karmaDone, 0))

    if Victim:IsPlayer() and add > 0 then
        zb.HarmReceivedKarma[Victim] = zb.HarmReceivedKarma[Victim] or 0
        local victimAdd = math.Clamp(add * zb.KarmaVictimComp, 0, math.max(zb.KarmaVictimCompCap - zb.HarmReceivedKarma[Victim], 0))
        zb.HarmReceivedKarma[Victim] = zb.HarmReceivedKarma[Victim] + victimAdd
        Victim.Karma = math.Clamp((Victim.Karma or 100) + victimAdd, 0, zb.MaxKarma)
        Victim:SetNetVar("Karma", Victim.Karma)
    end

    Attacker.Guilt = (Attacker.Guilt or 0) + guiltadd
    Attacker.Karma = math.Clamp((Attacker.Karma or 100) - add + karmaReturn, -60, zb.MaxKarma)

    local karmaNetLoss = add - karmaReturn
    if karmaNetLoss > 20 then
        zb.PlayKarmaSound(Attacker, 100)
    end

    zb.HarmDoneKarma[Victim][Attacker] = zb.HarmDoneKarma[Victim][Attacker] + add

    if shouldBanGuilt and Attacker.Guilt >= 100 then
        ULib.addBan( Attacker:SteamID(), 15, "Banned for dealing too much team damage.", Attacker:Name(), "System" )

        PrintMessage(HUD_PRINTTALK, "Player "..Attacker:Name().." has been banned for 15 minutes for RDMing in a team based gamemode.")
    end

    Attacker:SetNetVar("Karma", Attacker.Karma)

    local warned = Attacker.karma_warned or 999
    if Attacker.Karma <= 0 and warned > 0 then
        Attacker.karma_warned = 0
        zb.PlayKarmaSound(Attacker, 60)
    elseif Attacker.Karma <= 20 and warned > 20 then
        Attacker.karma_warned = 20
        zb.PlayKarmaSound(Attacker, 80)
    elseif Attacker.Karma <= 35 and warned > 35 then
        Attacker.karma_warned = 35
        zb.PlayKarmaSound(Attacker, 100)
    elseif Attacker.Karma <= 60 and warned > 60 then
        Attacker.karma_warned = 60
        zb.PlayKarmaSound(Attacker, 120)
    end

    zb.GuiltTable[Attacker][Victim] = math.Clamp((zb.GuiltTable[Attacker][Victim] or 0) + guiltadd, 0, 200)

    if Attacker.Karma <= 0 then
        local steamID = Attacker:SteamID()
        local name = Attacker:Name()
        local karma = Attacker.Karma

        Attacker:guilt_SetValue( 10 )

        timer.Create("simplewaitforkarmadrop"..Attacker:EntIndex(), 0, 1, function()
            if IsValid(Attacker) then
                karma = Attacker.Karma
            end

            local time = 25

            ULib.addBan( steamID, time, "Banned for having too low karma.", name, "System" )

            PrintMessage(HUD_PRINTTALK, "Player "..name.." has been banned for "..time.." minutes for having too low karma.")
        end)
    end
end)

function zb.IsForce(Attacker)
    return Attacker.PlayerClassName == "police" or Attacker.PlayerClassName == "nationalguard" or Attacker.PlayerClassName == "swat"
end

local function IsLookingAt(ply, targetVec)
    if not IsValid(ply) or not ply:IsPlayer() then return false end
    local diff = targetVec - ply:GetShootPos()
    return true
end

function zb.ForcesAttackedInnocent(self, Victim)
    local victimWep = Victim:IsPlayer() and IsValid(Victim:GetActiveWeapon()) and Victim:GetActiveWeapon()

    return 1 * ((!Victim.LastAttacked or (Victim.LastAttacked + 10 > CurTime())) and 0 or 1) + 1 * (Victim:IsPlayer() and ((IsLookingAt(Victim, self:EyePos()) and (victimWep and (ishgweapon(victimWep) or ((victimWep:GetClass() == "weapon_hands_sh" and victimWep:GetFists() or victimWep.ismelee2) and Victim:GetPos():DistanceSqr(self:GetPos()) <= (72 * 72))))) and 0 or 1) or 1)
end

function zb.GetDowner(victim)
	if not IsValid(victim) then return end

	local harms = zb.HarmDone[victim]
	if not harms then return end

	local best, bestHarm
	for ent, harm in pairs(harms) do
		if IsValid(ent) and ent:IsPlayer() and harm and harm > 0 and (!best or harm > bestHarm) then
			best, bestHarm = ent, harm
		end
	end

	return best
end

hook.Add("HG_OnOtrub", "KarmaTrackOtrubDowner", function(ply)
	if not IsValid(ply) or not ply:IsPlayer() then return end

	ply.otrubDowner = zb.GetDowner(ply)
end)

hook.Add("HG_OnWakeOtrub", "KarmaClearOtrubDowner", function(ply)
	if IsValid(ply) then ply.otrubDowner = nil end
end)

hook.Add("Player Spawn", "KarmaClearOtrubDownerSpawn", function(ply)
	if IsValid(ply) then ply.otrubDowner = nil end
end)

hook.Add("PlayerDeath", "KarmaRefundOnSelfKill", function(victim, inflictor, attacker)
    if not IsValid(victim) then return end

    local selfInflicted = attacker == victim or inflictor == victim
    if not selfInflicted then return end

    local downer = IsValid(victim.otrubDowner) and victim.otrubDowner
    victim.otrubDowner = nil

    local downerKeep
    if IsValid(downer) then
        local now = CurTime()
        if (downer.karmaKillStreakUntil or 0) < now then downer.karmaKillStreak = 0 end

        local streak = math.max(downer.karmaKillStreak or 0, 1)
        local maxLoss = (zb.IsForce(downer) and 50 or 30) + 15 * (streak - 1)
        downerKeep = maxLoss * zb.OtrubSuicidePenalty
    end

    local harmed = zb.HarmDoneKarma[victim]
    if harmed then
        for ent, harm in pairs(harmed) do
            if IsValid(ent) and ent:IsPlayer() and harm and harm > 0 then
                local refund = harm
                if ent == downer then
                    refund = math.max(harm - downerKeep, 0)
                end

                ent.Karma = math.Clamp((ent.Karma or 100) + refund, 0, zb.MaxKarma)
                ent:SetNetVar("Karma", ent.Karma)
                harmed[ent] = 0
            end
        end
    end

    if zb.HarmDone[victim] then
        for ent in pairs(zb.HarmDone[victim]) do
            zb.HarmDone[victim][ent] = 0
        end
    end
end)

hook.Add("PlayerDisconnected","GuiltSaveOnDisconect",function(ply)
    ply:guilt_SetValue( ply.Karma or 100 )
end)

hook.Add("Player Spawn","SlowlyRestoreKarma",function(ply)
    if OverrideSpawn then return end

    ply.lastwarning = nil
    ply.Karma = ply.Karma or 100
    ply:SetNetVar("Karma",ply.Karma)

    ply.Guilt = 0

    ply.karma_warned = math.min(ply.karma_warned or 999,
        ply.Karma <= 20 and 0 or ply.Karma <= 35 and 35 or ply.Karma <= 60 and 60 or 999)
end)

hook.Add("Player Think", "karmagain", function(ply)
    if (ply.KarmaGainThink or 0) > CurTime() then return end
    ply.KarmaGainThink = CurTime() + 120

    ply.Karma = math.Clamp(ply.Karma + (ply.Karma > 100 and zb.KarmaRegenHigh or (ply.KarmaGain or zb.KarmaRegen)), 0, zb.MaxKarma)

    ply:SetNetVar("Karma", ply.Karma)
end)

hook.Add("Org Clear","removekarmashaking",function(org)
    org.start_shaking = nil
end)

hook.Add("Should Fake Up", "karma", function(ply)
    if ply.organism and ply.organism.start_shaking then return false end
end)

hook.Add("Org Think", "Its_Karma_Bro",function(owner, org, timeValue)
    if not owner or not owner:IsPlayer() or org.otrub or not org.isPly then return end
    if not owner:IsPlayer() or not owner:Alive() then return end
    
    local ply = owner
    
    org.start_shaking = nil

    if (ply.Karma or 100) < 35 then
        if math.random(2000) == 1 then
            hg.organism.Vomit(owner)
        end
    end
end)

hook.Add("ZB_EndRound","savevalues",function()
    for i,ply in player.Iterator() do
        ply:guilt_SetValue( ply.Karma or 100 )
    end
end)

hook.Add("ZB_StartRound","NO_HARM",function()
    for i,ply in player.Iterator() do
        if (ply.Guilt or 0) < 1 then
            ply.KarmaGain = math.Clamp((ply.KarmaGain or zb.KarmaRegen) + 0.25, zb.KarmaRegen, zb.KarmaRegen + zb.KarmaRegenCleanBonus)
        else
            ply.KarmaGain = zb.KarmaRegen
        end

    end
    
    zb.HarmDone = {}
    zb.HarmDoneKarma = {}
    zb.HarmReturnedKarma = {}
    zb.HarmReceivedKarma = {}
    zb.KarmaEarned = {}
end)

util.AddNetworkString("get_karma")
net.Receive("get_karma",function(len, ply)
    if not ply:IsAdmin() then return end

    local tbl = {}

    for i,pl in player.Iterator() do
        tbl[pl:UserID()] = pl.Karma
    end

    net.Start("get_karma")
    net.WriteTable(tbl)
    net.Send(ply)
end)

concommand.Add("hg_setkarma",function(ply,cmd,args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end
    
    local lenargs = #args
    local newply = player.GetListByName(lenargs > 1 and args[1] or ply:Name())[1]
	if not IsValid(newply) then return end
	local karma = tonumber(lenargs > 1 and args[2] or args[1])
	if not karma then return end

	newply.Karma = math.Clamp(karma, 0, zb.MaxKarma or 100)
	newply:SetNetVar("Karma",newply.Karma)
end)

util.AddNetworkString("open_guilt_menu")
util.AddNetworkString("forgive_player")

net.Receive("open_guilt_menu",function(len, ply)
    if ply:Alive() then return end
    local tbl = zb.HarmDoneKarma[ply] or {}
    net.Start("open_guilt_menu")
    net.WriteFloat(ply.Karma or 100)
    net.WriteTable(tbl)
    net.Send(ply)
end)

net.Receive("forgive_player", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or not zb.HarmDoneKarma[ply] then return end
    local harm = zb.HarmDoneKarma[ply][ent]
    if not harm then return end

    ent.Karma = math.Clamp(ent.Karma + harm, 0, zb.MaxKarma)
    ent:SetNetVar("Karma",ent.Karma)
    if ply.GiveExp then ply:GiveExp(math.Round(harm)) end

    zb.HarmDone[ply][ent] = 0
    zb.HarmDoneKarma[ply][ent] = 0
    net.Start("open_guilt_menu")
    net.WriteFloat(ply.Karma or 100)
    net.WriteTable(zb.HarmDoneKarma[ply])
    net.Send(ply)
end)

hook.Add("Player Spawn", "GuiltKnown",function(ply)
    if ply.Karma then
        ply:ChatPrint("Your current karma is "..tostring(math.Round(ply.Karma)).."")
    end
end)

hook.Add("ZC_SomeoneGetFallBy","IdiotsMustBeKilled",function(Attacker,Victim)
    local rnd = CurrentRound()
    
    if rnd.GuiltDisabled or GetConVar("zb_dev"):GetBool() then return end
   
    if Attacker == Victim then return end

    if Victim.isTraitor and !Attacker.isTraitor and !zb.IsForce(Attacker) then return end
    if Attacker.isTraitor and !Victim.isTraitor then return end
    if rnd.name != "hmcd" and (Attacker.Team and Victim.Team and Attacker:Team() ~= Victim:Team()) then return end
    if zb.ROUND_STATE != 1 and (rnd.name != "cstrike" or !zb.RoundsLeft) then return end
    if Victim.Guilt and Victim.Guilt > 1 then return end

    Attacker.Guilt = Attacker.Guilt or 0
    Attacker.Guilt = Attacker.Guilt < 4 and 5 or Attacker.Guilt 
end)

-- Punish the "kill" console command with a partial karma penalty (part of the punishment)
local function punishKillCommand(ply)
    if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end
    if not zb.KarmaSuicideLoss then return end

    ply.Karma = math.Clamp((ply.Karma or 100) - zb.KarmaSuicideLoss, -60, zb.MaxKarma)
    ply:SetNetVar("Karma", ply.Karma)

    local warned = ply.karma_warned or 999
    if ply.Karma <= 0 and warned > 0 then
        ply.karma_warned = 0
        zb.PlayKarmaSound(ply, 60)
    elseif ply.Karma <= 20 and warned > 20 then
        ply.karma_warned = 20
        zb.PlayKarmaSound(ply, 80)
    elseif ply.Karma <= 35 and warned > 35 then
        ply.karma_warned = 35
        zb.PlayKarmaSound(ply, 100)
    elseif ply.Karma <= 60 and warned > 60 then
        ply.karma_warned = 60
        zb.PlayKarmaSound(ply, 120)
    end

    ply:Notify("You lost " .. zb.KarmaSuicideLoss .. " karma for using the kill command.", 2, "karma")
end

concommand.Add("kill", function(ply, cmd, args)
    punishKillCommand(ply)

    if IsValid(ply) and ply:Alive() then
        ply:Kill()
    end
end)
