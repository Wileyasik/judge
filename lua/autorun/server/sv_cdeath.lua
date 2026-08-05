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
hook.Add("PlayerDeathThink", "DeathEffect_BlockRespawn", function(ply)
    if ply:GetNWBool("DeathEffect_BlockRespawn", false) then
        return false
    end
end)

hook.Add("PlayerDeath", "DeathEffect_OnDeath", function(ply)
    if ply:IsBot() then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)

        timer.Simple(0, function()
            if IsValid(ply) and not ply:Alive() and ply.CanSpawn and ply:CanSpawn() then
                ply:Spawn()
            end
        end)

        return
    end

    if ply:GetInfoNum("deatheffect_enabled", 1) == 0 then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
        return
    end

    if not DeathEffectRoundActive() then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
        return
    end

    ply:SetNWBool("DeathEffect_BlockRespawn", true)

    net.Start("DeathEffect_Config")
        net.WriteBool(GetConVar("deatheffect_spectator"):GetBool())
        net.WriteBool(GetConVar("deatheffect_compat"):GetBool())
        net.WriteFloat(GetConVar("deatheffect_options_delay"):GetFloat())
    net.Send(ply)
end)

hook.Add("PlayerSpawn", "DeathEffect_OnSpawn", function(ply)
    ply:SetNWBool("DeathEffect_BlockRespawn", false)
end)

-- client triggers
net.Receive("DeathEffect_Respawn", function(len, ply)
    if IsValid(ply) and not ply:Alive() then
        if not ply.CanSpawn or not ply:CanSpawn() then return end
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
        ply:UnSpectate()
        ply:Spawn()
    end
end)

-- allow respawning because compat mode is on
net.Receive("DeathEffect_CompatUnblock", function(len, ply)
    if IsValid(ply) then
        ply:SetNWBool("DeathEffect_BlockRespawn", false)
    end
end)

net.Receive("DeathEffect_EnterSpectator", function(len, ply)
    if IsValid(ply) and not ply:Alive() then
        ply:Spectate(OBS_MODE_ROAMING)
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
