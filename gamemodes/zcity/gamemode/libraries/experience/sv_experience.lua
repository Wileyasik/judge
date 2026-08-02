--
zb = zb or {}

zb.Experience = zb.Experience or {}
zb.Experience.PlayerInstances = zb.Experience.PlayerInstances or {}
zb.Experience.Active = zb.Experience.Active or false

hook.Add("DatabaseConnected", "ExperienceCreateData", function()
	local query

	query = mysql:Create("zb_experience")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:Create("skill", "FLOAT NOT NULL")
		query:Create("experience", "INT NOT NULL") -- Надо перевести в большие числа INT НЕ ХВАТАЕТ!!! - хватает просто кое-кто придурок да салат?
        query:Create("deaths", "INT NOT NULL")
        query:Create("kills", "INT NOT NULL")
        query:Create("suicides", "INT NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    zb.Experience.Active = true
end)

--local query = mysql:Drop("zb_experience")
--query:Execute()

hook.Add( "PlayerInitialSpawn","ZB_Exp_OnInitSpawn", function( ply )
    local name = ply:Name()
	local steamID64 = ply:SteamID64()

    if not zb.Experience.Active then
        zb.Experience.PlayerInstances[steamID64] = {}
        return
    end 

	local query = mysql:Select("zb_experience")
		query:Select("skill")
		query:Select("experience")
        query:Select("deaths")
        query:Select("kills")
        query:Select("suicides")
		query:Where("steamid", steamID64)
		query:Callback(function(result)
			if (IsValid(ply) and istable(result) and #result > 0 and result[1].experience) then
				local updateQuery = mysql:Update("zb_experience")
					updateQuery:Update("steam_name", name)
					updateQuery:Where("steamid", steamID64)
				updateQuery:Execute()

				zb.Experience.PlayerInstances[steamID64] = {}

                zb.Experience.PlayerInstances[steamID64].skill = tonumber(result[1].skill)
                zb.Experience.PlayerInstances[steamID64].experience = tonumber(result[1].experience)
                zb.Experience.PlayerInstances[steamID64].deaths = tonumber(result[1].deaths)
                zb.Experience.PlayerInstances[steamID64].kills = tonumber(result[1].kills)
                zb.Experience.PlayerInstances[steamID64].suicides = tonumber(result[1].suicides)

			else
				local insertQuery = mysql:Insert("zb_experience")
					insertQuery:Insert("steamid", steamID64)
					insertQuery:Insert("steam_name", name)
					insertQuery:Insert("skill", 0)
		            insertQuery:Insert("experience", 0)
                    insertQuery:Insert("deaths", 0)
		            insertQuery:Insert("kills", 0)
                    insertQuery:Insert("suicides", 0)
				insertQuery:Execute()

				zb.Experience.PlayerInstances[steamID64] = {}

				zb.Experience.PlayerInstances[steamID64].skill = 0
                zb.Experience.PlayerInstances[steamID64].experience = 0
                zb.Experience.PlayerInstances[steamID64].deaths = 0
                zb.Experience.PlayerInstances[steamID64].kills = 0
                zb.Experience.PlayerInstances[steamID64].suicides = 0

			end
		end)
	query:Execute()

end)

local plyMeta = FindMetaTable("Player")

local function EnsureExperienceInstance(ply)
    local steamID64 = ply:SteamID64()
    zb.Experience.PlayerInstances[steamID64] = zb.Experience.PlayerInstances[steamID64] or {}

    local exp = zb.Experience.PlayerInstances[steamID64]
    exp.skill = tonumber(exp.skill) or 0
    exp.experience = tonumber(exp.experience) or 0
    exp.deaths = tonumber(exp.deaths) or 0
    exp.kills = tonumber(exp.kills) or 0
    exp.suicides = tonumber(exp.suicides) or 0

    return exp
end

local function SaveExperienceInstance(ply)
    if not zb.Experience.Active then return end

    local steamID64 = ply:SteamID64()
    local exp = EnsureExperienceInstance(ply)

    local insertQuery = mysql:InsertIgnore("zb_experience")
        insertQuery:Insert("steamid", steamID64)
        insertQuery:Insert("steam_name", ply:Name())
        insertQuery:Insert("skill", exp.skill)
        insertQuery:Insert("experience", exp.experience)
        insertQuery:Insert("deaths", exp.deaths)
        insertQuery:Insert("kills", exp.kills)
        insertQuery:Insert("suicides", exp.suicides)
    insertQuery:Execute()

	local updateQuery = mysql:Update("zb_experience")
		updateQuery:Update("steam_name", ply:Name())
		updateQuery:Update("skill", exp.skill)
		updateQuery:Update("experience", exp.experience)
		updateQuery:Update("deaths", exp.deaths)
		updateQuery:Update("kills", exp.kills)
		updateQuery:Update("suicides", exp.suicides)
		updateQuery:Where("steamid", steamID64)
	updateQuery:Execute()
end

function plyMeta:GetExp()

    return math.Round(EnsureExperienceInstance(self).experience) or 0

end

function plyMeta:GiveExp( ammout )

    local steamID64 = self:SteamID64()

    if !zb.Experience or !zb.Experience.PlayerInstances then return end

    local exp = EnsureExperienceInstance(self)
    exp.experience = math.max((exp.experience or 0) + ammout, 0)

    SaveExperienceInstance(self)

    local points = math.min(ammout / 5, 10) * (1 + (self.EA_HasAccess and self:EA_HasAccess() and 2 or 0))
    local mul = math.min(player.GetCount() / 10, 1)
    self:PS_AddPoints(math.Round(points * mul,0))
    --self:SetNWInt( "experience", exp + ammout )
end


function plyMeta:GetSkill()

    return EnsureExperienceInstance(self).skill or 0

end

function plyMeta:GiveSkill( ammout )

    local steamID64 = self:SteamID64()

    local exp = EnsureExperienceInstance(self)
    exp.skill = math.max(exp.skill + ammout, 0)

    SaveExperienceInstance(self)
    --self:SetNWFloat( "skill", skill + ammout )
    
end

function plyMeta:GetDeaths()

    return EnsureExperienceInstance(self).deaths or 0

end

function plyMeta:GiveDeaths( ammout )

    local steamID64 = self:SteamID64()

    local exp = EnsureExperienceInstance(self)
    exp.deaths = math.max(exp.deaths + ammout, 0)

    SaveExperienceInstance(self)
    --self:SetNWInt( "experience", exp + ammout )
end

function plyMeta:GetKills()

    return EnsureExperienceInstance(self).kills or 0

end

function plyMeta:GiveKills( ammout )

    local steamID64 = self:SteamID64()

    local exp = EnsureExperienceInstance(self)
    exp.kills = math.max(exp.kills + ammout, 0)

    SaveExperienceInstance(self)
    --self:SetNWInt( "experience", exp + ammout )
end


function plyMeta:GetSuicides( ammout )

    return EnsureExperienceInstance(self).suicides or 0

end

function plyMeta:GiveSuicides( ammout )

    local steamID64 = self:SteamID64()

    local exp = EnsureExperienceInstance(self)
    exp.suicides = math.max(exp.suicides + ammout, 0)

    SaveExperienceInstance(self)
    --self:SetNWInt( "experience", exp + ammout )
end


util.AddNetworkString("zb_xp_get")
util.AddNetworkString("zb_sql_leaderboard")

net.Receive("zb_xp_get",function(len,ply)

    local steamID64 = ply:SteamID64()

    if not zb.Experience.Active then
        zb.Experience.PlayerInstances[steamID64] = {}
        return
    end 

    local get_ply = net.ReadEntity()

    if not IsValid(get_ply) or not get_ply.GetSkill or not get_ply.GetExp then
        return
    end

    net.Start("zb_xp_get")
        --print( ply:GetExp() )
        net.WriteEntity( get_ply )
        net.WriteFloat( get_ply:GetSkill() )
        net.WriteUInt( math.Clamp(get_ply:GetExp(), 0, 4294967295), 32 )
    net.Send(ply)

end)

net.Receive("zb_sql_leaderboard", function(_, ply)
    if not zb.Experience.Active then return end

    local limit = math.Clamp(net.ReadUInt(8) or 10, 1, 10)

    local query = mysql:Select("zb_experience")
        query:Select("steamid")
        query:Select("steam_name")
        query:Select("skill")
        query:Select("experience")
        query:Select("deaths")
        query:Select("kills")
        query:Select("suicides")
        query:Callback(function(result)
            if not IsValid(ply) then return end

            local rows = {}
            for _, data in ipairs(result or {}) do
                local kills = tonumber(data.kills) or 0
                local deaths = math.max((tonumber(data.deaths) or 0) - (tonumber(data.suicides) or 0), 0)
                local xp = math.floor(tonumber(data.experience) or 0)

                rows[#rows + 1] = {
                    steamid = tostring(data.steamid or ""),
                    name = tostring(data.steam_name or "Unknown"),
                    skill = tonumber(data.skill) or 0,
                    xp = xp,
                    kills = kills,
                    deaths = deaths,
                    kd = kills / math.max(deaths, 1)
                }
            end

            table.sort(rows, function(a, b)
                if a.xp == b.xp then
                    if a.kd == b.kd then return a.name:lower() < b.name:lower() end
                    return a.kd > b.kd
                end
                return a.xp > b.xp
            end)

            local count = math.min(#rows, limit)
            net.Start("zb_sql_leaderboard")
                net.WriteUInt(count, 8)
                for i = 1, count do
                    local row = rows[i]
                    net.WriteString(row.steamid)
                    net.WriteString(row.name)
                    net.WriteFloat(row.skill)
                    net.WriteUInt(math.Clamp(row.xp, 0, 4294967295), 32)
                    net.WriteUInt(math.Clamp(row.kills, 0, 65535), 16)
                    net.WriteUInt(math.Clamp(row.deaths, 0, 65535), 16)
                    net.WriteFloat(row.kd)
                end
            net.Send(ply)
        end)
    query:Execute()
end)


--hook.Add( "ZB_EndRound", "ZB_Exp_Give", function()
--    local exp = ply.RoundEXP or 0
--    local skill = ply.RoundSkill or 0
--
--    ply:SetPData( "zb_experience", exp )
--    ply:SetPData( "zb_skill", skill )
--
--    ply:SetNWInt( "experience", exp )
--    ply:SetNWFloat( "skill", skill )
--
--    ply.RoundEXP = 0
--    ply.RoundSkill = 0
--end)
