if not SERVER then return end

-- convars
CreateConVar(
    "deatheffect_spectator", "1",
    bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE),
    "allow players to enter spectator mode on the death screen",
    0, 1
)
CreateConVar(
    "deatheffect_compat", "0",
    bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE),
    "remove all cinematic effects before the option screen appears, for better compatibility with other mods",
    0, 1
)
CreateConVar(
    "deatheffect_options_delay", "4",
    bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_ARCHIVE),
    "how many seconds it takes for the respawn/spectator options to show up",
    0, 60
)

-- strings
util.AddNetworkString("DeathEffect_Respawn")
util.AddNetworkString("DeathEffect_UpdateCam")
util.AddNetworkString("DeathEffect_EnterSpectator")
util.AddNetworkString("DeathEffect_CompatUnblock")
util.AddNetworkString("DeathEffect_Config")

local function DeathEffectRoundActive()
    if zb and zb.ROUND_STATE ~= nil then
        return zb.ROUND_STATE == 1
    end

    return true
end

-- respawn block
local function DeathEffect_GetTimerName(ply)
    if not IsValid(ply) then return nil end

    local id = ply:SteamID64()
    if id and id ~= "" then
        return "DeathEffect_AutoUnblock_" .. id
    end
    return "DeathEffect_AutoUnblock_EI" .. ply:EntIndex()
end

local function DeathEffect_ClearBlock(ply, removeTimer)
    if not IsValid(ply) then return end
    ply:SetNWBool("DeathEffect_BlockRespawn", false)
    ply.DeathEffect_DeathTime = nil
    ply.DeathEffectBlockUntil = nil
    if removeTimer ~= false then
        local tname = DeathEffect_GetTimerName(ply)
        if tname then timer.Remove(tname) end
    end
end

hook.Add("PlayerDeathThink", "DeathEffect_BlockRespawn", function(ply)
    if ply:GetNWBool("DeathEffect_BlockRespawn", false) then
        local dt = ply.DeathEffect_DeathTime
        if not dt then
            ply.DeathEffect_DeathTime = CurTime() - 11
            return false
        end
        if (CurTime() - dt) > 12 then
            DeathEffect_ClearBlock(ply, true)
            return
        end
        if (ply.DeathEffectBlockUntil or 0) <= CurTime() or not DeathEffectRoundActive() then
            DeathEffect_ClearBlock(ply, true)
            return
        end
        return false
    else
        if ply.DeathEffect_DeathTime and ply:Alive() then
            ply.DeathEffect_DeathTime = nil
        end
    end
end)

timer.Create("DeathEffect_StuckSweep", 5, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNWBool("DeathEffect_BlockRespawn", false) and not ply:Alive() then
            local dt = ply.DeathEffect_DeathTime
            if not dt then
                ply.DeathEffect_DeathTime = CurTime() - 11
            elseif (CurTime() - dt) > 12 then
                DeathEffect_ClearBlock(ply, true)
            end
        end
    end
end)

hook.Add("PlayerDeath", "DeathEffect_OnDeath", function(ply)
    if ply:IsBot() then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)

        timer.Simple(0, function()
            if IsValid(ply) and not ply:Alive() then
                ply:Spawn()
            end
        end)

        return
    end

    if not DeathEffectRoundActive() then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
        return
    end

    if ply:GetInfoNum("deatheffect_enabled", 1) == 0 then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
        ply.DeathEffectBlockUntil = nil
        return
    end

    local realish = CurrentRound and CurrentRound().name == "realish"

    ply:SetNWBool("DeathEffect_BlockRespawn", true)
    ply.DeathEffect_DeathTime = CurTime()
    ply.DeathEffectBlockUntil = CurTime() + 30

    local failsafeDelay = realish and 3 or 12
    local tname = DeathEffect_GetTimerName(ply)
    if tname then
        timer.Create(tname, failsafeDelay, 1, function()
            if IsValid(ply) and ply:GetNWBool("DeathEffect_BlockRespawn", false) and not ply:Alive() then
                DeathEffect_ClearBlock(ply, false)
            end
        end)
    end

    net.Start("DeathEffect_Config")
        net.WriteBool(not realish and GetConVar("deatheffect_spectator"):GetBool())
        net.WriteBool(GetConVar("deatheffect_compat"):GetBool())
        net.WriteFloat(realish and 0 or GetConVar("deatheffect_options_delay"):GetFloat())
        net.WriteBool(realish)
    net.Send(ply)
end)

hook.Add("PlayerSpawn", "DeathEffect_OnSpawn", function(ply)
    DeathEffect_ClearBlock(ply, true)
end)

hook.Add("PlayerDisconnected", "DeathEffect_Cleanup", function(ply)
    local tname = DeathEffect_GetTimerName(ply)
    if tname then timer.Remove(tname) end
end)

-- client triggers
net.Receive("DeathEffect_Respawn", function(len, ply)
    if IsValid(ply) and not ply:Alive() then
        DeathEffect_ClearBlock(ply, true)
        ply:UnSpectate()
        ply:Spawn()
    end
end)

-- allow respawning because compat mode is on
net.Receive("DeathEffect_CompatUnblock", function(len, ply)
    if IsValid(ply) then
        DeathEffect_ClearBlock(ply, true)
    end
end)

net.Receive("DeathEffect_EnterSpectator", function(len, ply)
    if IsValid(ply) and not ply:Alive() then
        DeathEffect_ClearBlock(ply, true)
        ply.viewmode = 3
        ply:Spectate(OBS_MODE_ROAMING)
        ply:SetMoveType(MOVETYPE_NOCLIP)
    end
end)

-- spectator cam sync
net.Receive("DeathEffect_UpdateCam", function(len, ply)
    if IsValid(ply) and not ply:Alive() and ply:GetNWBool("DeathEffect_BlockRespawn", false) then
        local camPos = net.ReadVector()
        local camAng = net.ReadAngle()
        ply:SetPos(camPos)
        ply:SetEyeAngles(camAng)
    end
end)
