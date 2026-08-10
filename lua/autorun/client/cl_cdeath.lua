if not CLIENT then return end

local CLICK_SOUND         = "player/dfujiclick.wav"
local STAGE_1_DURATION    = 0
local STAGE_1_MIN_DIST    = 60
local STAGE_1_MAX_DIST    = 120
local STAGE_1_MIN_HEIGHT  = -20
local STAGE_1_MAX_HEIGHT  = 0
local STAGE_1_LOOK_HEIGHT = 15
local BLACK_FADE_DURATION = 7
local BLACK_FADE_OUT_DURATION = 2
local DEATH_TEXT_FADE_IN  = 1
local OPTIONS_FADE_IN     = 1.0
local TRANSITION_DURATION = 0.6
local DOUBLE_CLICK_WINDOW = 0.5

local DEATH_MESSAGES = {
    { title = "Deceased.", desc = "You are no longer a witness to the world." },
    { title = "No Response.", desc = "Your body remains. You do not." },
    { title = "Gone.", desc = "The world continues without your testimony." },
    { title = "Expired.", desc = "All signs of breath has left you." },
    { title = "Terminated.", desc = "Your perspective has been permanently interrupted." },
    { title = "Silenced.", desc = "Nothing answers from inside the body." },
}

local DEATH_SOUNDS = {
    [0] = "death_ost.mp3",
}

local DEATH_COLORS = {
    Color(255, 0, 0),
    Color(255, 70, 0),
    Color(255, 170, 0),
    Color(185, 220, 0),
    Color(0, 210, 90),
    Color(0, 190, 190),
    Color(0, 115, 255),
    Color(95, 65, 255),
    Color(175, 45, 255),
    Color(255, 35, 160),
}

-- server convar values yesss
local cfg_spectator     = true
local cfg_compat        = false
local cfg_options_delay = 4

net.Receive("DeathEffect_Config", function()
    cfg_spectator     = net.ReadBool()
    cfg_compat        = net.ReadBool()
    cfg_options_delay = net.ReadFloat()
end)

-- convars (client)
CreateClientConVar(
    "deatheffect_cam_max_dist", "150",
    true, false,
    "maximum camera follow distance in stage 2",
    40, 2000
)
CreateClientConVar(
    "deatheffect_cam_min_dist", "60",
    true, false,
    "minimum camera follow distance in stage 2",
    0, 2000
)
CreateClientConVar(
    "deatheffect_alt_sound", "0",
    true, false,
    "use the quieter death sound",
    0, 1
)

local cv_cam_max_dist = GetConVar("deatheffect_cam_max_dist")
local cv_cam_min_dist = GetConVar("deatheffect_cam_min_dist")
local cv_alt_sound    = GetConVar("deatheffect_alt_sound")

local cv_enabled = CreateClientConVar("deatheffect_enabled", "1", true, true, "Toggle the cinematic death screen", 0, 1)

surface.CreateFont("DeathEffect_Key", { font = "Roboto", size = 52, weight = 700 })
surface.CreateFont("DeathEffect_Label", { font = "Roboto", size = 22, weight = 400 })
surface.CreateFont("DeathEffect_Hint", { font = "Roboto", size = 17, weight = 300 })

local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or nil
surface.CreateFont("DeathEffect_HG", { font = (hg_font and hg_font:GetString() ~= "" and hg_font:GetString()) or "Lora", size = 52, weight = 400, antialias = true })
surface.CreateFont("DeathEffect_HG_Large", { font = (hg_font and hg_font:GetString() ~= "" and hg_font:GetString()) or "Lora", size = 120, weight = 400, antialias = true })
surface.CreateFont("DeathEffect_HG_Desc", { font = (hg_font and hg_font:GetString() ~= "" and hg_font:GetString()) or "Lora", size = 28, weight = 400, antialias = true })

-- binds
local function LookupKey(binding)
    local key = input.LookupBinding("+" .. binding) or input.LookupBinding(binding)
    if not key or key == "" then return KEY_UNKNOWN, "?" end
    return input.GetKeyCode(key), string.upper(key)
end

local reloadKeyCode, reloadKeyName = LookupKey("reload")
local jumpKeyCode,   jumpKeyName   = LookupKey("jump")
local crouchKeyCode, crouchKeyName = LookupKey("duck")
local sprintKeyCode, sprintKeyName = LookupKey("speed")

local function SafeKeyDown(code)
    if not code or code == KEY_UNKNOWN then return false end
    return input.IsButtonDown(code)
end

local m_pitch = GetConVar("m_pitch")
local m_yaw   = GetConVar("m_yaw")

local CDeath = {}

CDeath.hasSpawned    = false
CDeath.isDead        = false
CDeath.stage2Started = false
CDeath.deathTime     = 0
CDeath.stage2Time    = 0
CDeath.autoCompatTriggered = false
CDeath.deathCamPos   = Vector(0, 0, 0)
CDeath.deathCamAng   = Angle(0, 0, 0)
CDeath.deathPos      = Vector(0, 0, 0)
CDeath.ragdollEnt    = nil
CDeath.deathMessage  = DEATH_MESSAGES[1]
CDeath.deathColor    = DEATH_COLORS[1]

local matWhite      = Material("models/debug/debugwhite")

CDeath.deathSoundChannels = {}
CDeath.keepSoundAlive    = false
CDeath.deathSoundGeneration = 0

CDeath.inTransition        = false
CDeath.transitionStartTime = 0
CDeath.transitionCallback  = nil
CDeath.transitionFired     = false

CDeath.prevReloadDown = false
CDeath.prevJumpDown   = false
CDeath.prevSkipDown   = false

CDeath.compatActive     = false
CDeath.compatActiveTime = 0
CDeath.compatTriggered  = false

CDeath.inSpectator         = false
CDeath.freecamPos          = Vector(0, 0, 0)
CDeath.freecamAng          = Angle(0, 0, 0)
CDeath.lastReloadPressTime = 0
CDeath.prevSpecReloadDown  = false
CDeath.nextCamSync         = 0
CDeath.nextSoundfade       = 0
CDeath.nextRagdollSearch   = 0
CDeath.disabledUnblocked   = false

-- z-city bypassing
local zcity_RenderScene = nil
local zcity_CalcView = nil

local function TakeAuthority()
    local hooks = hook.GetTable()
    if hooks["RenderScene"] and hooks["RenderScene"]["jopa"] then
        zcity_RenderScene = hooks["RenderScene"]["jopa"]
        hook.Remove("RenderScene", "jopa")
    end
    if hooks["CalcView"] and hooks["CalcView"]["homigrad-view"] then
        zcity_CalcView = hooks["CalcView"]["homigrad-view"]
        hook.Remove("CalcView", "homigrad-view")
    end
end

local function ReleaseAuthority()
    local hooks = hook.GetTable()
    if zcity_RenderScene and not (hooks.RenderScene and hooks.RenderScene.jopa) then
        hook.Add("RenderScene", "jopa", zcity_RenderScene)
    end
    if zcity_CalcView and not (hooks.CalcView and hooks.CalcView["homigrad-view"]) then
        hook.Add("CalcView", "homigrad-view", zcity_CalcView)
    end
    zcity_RenderScene = nil
    zcity_CalcView = nil
end

local function DeathEffectRoundActive()
    if zb and zb.ROUND_STATE ~= nil then
        return zb.ROUND_STATE == 1
    end

    return true
end


local function PlayClick()
    local generation = CDeath.deathSoundGeneration
    sound.PlayFile("sound/" .. CLICK_SOUND, "noplay", function(ch)
        if not IsValid(ch) then return end
        if generation ~= CDeath.deathSoundGeneration then
            ch:Stop()
            return
        end
        ch:Play()
    end)
end

local function DoRespawn()
    net.Start("DeathEffect_Respawn")
    net.SendToServer()
end

local function StopDeathSounds()
    CDeath.deathSoundGeneration = CDeath.deathSoundGeneration + 1
    for _, station in ipairs(CDeath.deathSoundChannels) do
        if IsValid(station) then
            station:Stop()
        end
    end
    CDeath.deathSoundChannels = {}
    CDeath.keepSoundAlive = false
end

local function RestoreRagdoll()
    if IsValid(CDeath.ragdollEnt) then
        CDeath.ragdollEnt:SetNoDraw(false)
        local headBone = CDeath.ragdollEnt:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            CDeath.ragdollEnt:ManipulateBoneScale(headBone, Vector(1, 1, 1))
        end
    end
end

local function GetRagdollHeadPos(ent)
    if not IsValid(ent) then return CDeath.deathPos + Vector(0, 0, STAGE_1_LOOK_HEIGHT) end

    local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
    if headBone then
        local matrix = ent:GetBoneMatrix(headBone)
        if matrix then
            return matrix:GetTranslation()
        end
    end

    return ent:GetPos() + Vector(0, 0, 45)
end

local function MakeRagdollHeadVisible(ent)
    if not IsValid(ent) then return end

    local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
    if headBone then
        ent:ManipulateBoneScale(headBone, Vector(1, 1, 1))
    end
end

local function FindDeathRagdoll(ply)
    if not IsValid(ply) then return nil end

    if IsValid(ply.FakeRagdoll) then
        return ply.FakeRagdoll
    end

    local nwRagdoll = ply.GetNWEntity and ply:GetNWEntity("RagdollDeath") or nil
    if IsValid(nwRagdoll) then
        return nwRagdoll
    end

    local deathRagdoll = ply:GetRagdollEntity()
    if IsValid(deathRagdoll) then
        return deathRagdoll
    end

    local bestRagdoll = nil
    local bestDist = math.huge
    for _, ent in ipairs(ents.FindByClass("prop_ragdoll")) do
        if ent:GetModel() == ply:GetModel() then
            local dist = ent:GetPos():DistToSqr(CDeath.deathPos)
            if dist < 100000 and dist < bestDist then
                bestRagdoll = ent
                bestDist = dist
            end
        end
    end

    return bestRagdoll
end

local function SkipDeathScene()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    CDeath.isDead = false
    CDeath.hasSpawned = false
    CDeath.stage2Started = false
    CDeath.inTransition = false
    CDeath.inSpectator = false
    CDeath.autoCompatTriggered = false
    CDeath.compatActive = false
    CDeath.compatTriggered = false
    RestoreRagdoll()
    CDeath.ragdollEnt = nil
    ply:SetDSP(0)
    ply:ConCommand("soundfade 0 1")
    StopDeathSounds()
    ReleaseAuthority()
    net.Start("DeathEffect_CompatUnblock")
    net.SendToServer()
end

local function EnterSpectator()
    CDeath.inSpectator  = true
    CDeath.freecamPos   = Vector(CDeath.deathCamPos.x, CDeath.deathCamPos.y, CDeath.deathCamPos.z)
    CDeath.freecamAng   = Angle(CDeath.deathCamAng.pitch, CDeath.deathCamAng.yaw, CDeath.deathCamAng.roll)
    CDeath.nextCamSync  = 0
    CDeath.inTransition = false
    LocalPlayer():SetDSP(0)
    LocalPlayer():ConCommand("soundfade 0 1")
    net.Start("DeathEffect_EnterSpectator")
    net.SendToServer()
end

local function ActivateCompatMode()
    CDeath.compatActive     = true
    CDeath.compatActiveTime = CurTime()
    CDeath.inTransition     = false
    LocalPlayer():SetDSP(0)
    LocalPlayer():ConCommand("soundfade 0 1")
    ReleaseAuthority() 
    net.Start("DeathEffect_CompatUnblock")
    net.SendToServer()
end

local function BeginTransition(callback)
    CDeath.inTransition        = true
    CDeath.transitionStartTime = CurTime()
    CDeath.transitionCallback  = callback
    CDeath.transitionFired     = false
    PlayClick()
end

-- state tracking and init
local function CinematicDeathTracker()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if not cv_enabled:GetBool() then
        if not ply:Alive() then
            if not CDeath.disabledUnblocked then
                CDeath.disabledUnblocked = true
                net.Start("DeathEffect_CompatUnblock")
                net.SendToServer()
            end
        else
            CDeath.disabledUnblocked = false
        end

        if CDeath.isDead or CDeath.inTransition or CDeath.inSpectator or CDeath.compatActive then
            CDeath.isDead           = false
            CDeath.stage2Started    = false
            CDeath.inTransition     = false
            CDeath.inSpectator      = false
            CDeath.autoCompatTriggered = false
            CDeath.compatActive     = false
            CDeath.keepSoundAlive   = false
            RestoreRagdoll()
            CDeath.ragdollEnt = nil
            ply:SetDSP(0)
            ply:ConCommand("soundfade 0 1")
            StopDeathSounds()
            ReleaseAuthority()
        end
        CDeath.hasSpawned = ply:Alive()
        CDeath.prevSkipDown = false
        return
    end

    CDeath.disabledUnblocked = false

    if not DeathEffectRoundActive() then
        CDeath.hasSpawned = ply:Alive()

        if CDeath.isDead then
            CDeath.isDead = false
            CDeath.stage2Started = false
            CDeath.keepSoundAlive = false
            CDeath.inTransition = false
            CDeath.inSpectator = false
            CDeath.autoCompatTriggered = false
            CDeath.compatActive = false
            ReleaseAuthority()

            RestoreRagdoll()
            CDeath.ragdollEnt = nil

            ply:SetDSP(0)
            ply:ConCommand("soundfade 0 1")
            StopDeathSounds()
            net.Start("DeathEffect_CompatUnblock")
            net.SendToServer()
        end

        return
    end

    local skipDown = input.IsButtonDown(KEY_BACKSPACE) or SafeKeyDown(jumpKeyCode)
    if CDeath.isDead and skipDown and not CDeath.prevSkipDown then
        SkipDeathScene()
        CDeath.prevSkipDown = true
        return
    end
    CDeath.prevSkipDown = skipDown

    if ply:Alive() and not CDeath.hasSpawned then
        CDeath.hasSpawned = true
    end

    if not ply:Alive() and not CDeath.isDead and CDeath.hasSpawned then
        CDeath.isDead           = true
        TakeAuthority() 
        CDeath.stage2Started    = false
        CDeath.keepSoundAlive   = true
        CDeath.inTransition     = false
        CDeath.inSpectator      = false
        CDeath.autoCompatTriggered = false
        CDeath.compatActive     = false
        CDeath.compatActiveTime = 0
        CDeath.compatTriggered  = false
        CDeath.deathTime        = CurTime()
        CDeath.nextRagdollSearch = 0
        CDeath.ragdollEnt       = ply:GetRagdollEntity()
        CDeath.prevReloadDown   = false
        CDeath.prevJumpDown     = false
        CDeath.prevSkipDown     = input.IsButtonDown(KEY_BACKSPACE) or SafeKeyDown(jumpKeyCode)
        CDeath.prevSpecReloadDown = false
        CDeath.deathMessage     = DEATH_MESSAGES[math.random(#DEATH_MESSAGES)]
        CDeath.deathColor       = DEATH_COLORS[math.random(#DEATH_COLORS)]
        MakeRagdollHeadVisible(CDeath.ragdollEnt)

        local plyPos = ply:GetPos()
        CDeath.deathPos     = plyPos

        local randYaw  = math.random(0, 360)
        local randDist = math.random(STAGE_1_MIN_DIST, STAGE_1_MAX_DIST)
        local offset   = Vector(
            math.cos(math.rad(randYaw)) * randDist,
            math.sin(math.rad(randYaw)) * randDist,
            math.random(STAGE_1_MIN_HEIGHT, STAGE_1_MAX_HEIGHT)
        )

        local traceStart = plyPos + Vector(0, 0, 40)
        
        local tr = util.TraceLine({
            start  = traceStart,
            endpos = traceStart + offset,
            mask   = MASK_SOLID_BRUSHONLY
        })

        CDeath.deathCamPos = tr.HitPos + tr.HitNormal * 5
        CDeath.deathCamAng = (plyPos + Vector(0, 0, STAGE_1_LOOK_HEIGHT) - CDeath.deathCamPos):Angle()

        StopDeathSounds()
        CDeath.keepSoundAlive = true
        local soundGeneration = CDeath.deathSoundGeneration
        for _, deathSound in pairs(DEATH_SOUNDS) do
            sound.PlayFile("sound/" .. deathSound, "noplay", function(station)
                if not IsValid(station) then return end
                if soundGeneration ~= CDeath.deathSoundGeneration or not CDeath.isDead then
                    station:Stop()
                    return
                end
                CDeath.deathSoundChannels[#CDeath.deathSoundChannels + 1] = station
                station:Play()
            end)
        end

    elseif ply:Alive() and CDeath.isDead then
        CDeath.isDead         = false
        CDeath.stage2Started  = false
        CDeath.keepSoundAlive = false
        CDeath.inTransition   = false
        CDeath.inSpectator    = false
        CDeath.autoCompatTriggered = false
        CDeath.compatActive   = false
        ReleaseAuthority() 
        
        RestoreRagdoll()
        CDeath.ragdollEnt = nil

        ply:SetDSP(0)
        ply:ConCommand("soundfade 0 1")
        StopDeathSounds()
    end

    if CDeath.isDead and not CDeath.stage2Started then
        if (CurTime() - CDeath.deathTime) >= STAGE_1_DURATION then
            CDeath.stage2Started = true
            CDeath.stage2Time    = CurTime()
            LocalPlayer():SetDSP(17)
            LocalPlayer():ConCommand("soundfade 100 99999")
        end
    end

    -- bypass loop
    if CDeath.isDead and not CDeath.compatActive then
        ply:SetViewPunchAngles(Angle(0,0,0))
        ply:ScreenFade(SCREENFADE.IN, Color(0,0,0,0), 0.1, 0)
        
        if CDeath.stage2Started and not CDeath.inSpectator then
            ply:SetDSP(17)
            -- keep re-applying the sound muting so it can't be bypassed
            if CurTime() >= CDeath.nextSoundfade then
                CDeath.nextSoundfade = CurTime() + 0.5
                ply:ConCommand("soundfade 100 99999")
            end
        end
    end

    if CDeath.isDead and CDeath.keepSoundAlive then
        local t = CurTime() - CDeath.deathTime
        local anyPlaying = false
        for _, station in ipairs(CDeath.deathSoundChannels) do
            if IsValid(station) and t < station:GetLength() then
                anyPlaying = true
                if station:GetState() ~= 1 then
                    station:Play()
                    station:SetTime(t, false)
                end
            end
        end
        if #CDeath.deathSoundChannels > 0 and not anyPlaying then
            CDeath.keepSoundAlive = false
        end
    end

    if CDeath.isDead and not IsValid(CDeath.ragdollEnt) and CurTime() >= (CDeath.nextRagdollSearch or 0) then
        CDeath.nextRagdollSearch = CurTime() + 0.2
        CDeath.ragdollEnt = FindDeathRagdoll(ply)
        MakeRagdollHeadVisible(CDeath.ragdollEnt)
    end

    if CDeath.inTransition and not CDeath.transitionFired then
        if (CurTime() - CDeath.transitionStartTime) >= TRANSITION_DURATION then
            CDeath.transitionFired = true
            PlayClick()
            if CDeath.transitionCallback then
                CDeath.transitionCallback()
                CDeath.transitionCallback = nil
            end
        end
    end

    if CDeath.isDead and CDeath.stage2Started and not CDeath.autoCompatTriggered then
        if (CurTime() - CDeath.stage2Time) >= (BLACK_FADE_DURATION + BLACK_FADE_OUT_DURATION) then
            CDeath.autoCompatTriggered = true
            ActivateCompatMode()
        end
    end

    if CDeath.inSpectator and not CDeath.inTransition then
        local reloadDown = SafeKeyDown(reloadKeyCode)

        if reloadDown and not CDeath.prevSpecReloadDown then
            local now = CurTime()
            if (now - CDeath.lastReloadPressTime) <= DOUBLE_CLICK_WINDOW then
                BeginTransition(DoRespawn)
            else
                CDeath.lastReloadPressTime = now
            end
        end

        CDeath.prevSpecReloadDown = reloadDown

        local timeNow = CurTime()
        if timeNow >= CDeath.nextCamSync then
            CDeath.nextCamSync = timeNow + 0.05
            net.Start("DeathEffect_UpdateCam")
                net.WriteVector(CDeath.freecamPos)
                net.WriteAngle(CDeath.freecamAng)
            net.SendToServer()
        end
    end
end
hook.Add("Think", "CinematicDeathTracker", CinematicDeathTracker)

-- mouse tracking
local function CinematicDeathFreecamLook(cmd)
    if not CDeath.inSpectator then return end
    local mX = cmd:GetMouseX()
    local mY = cmd:GetMouseY()
    CDeath.freecamAng.pitch = math.Clamp(CDeath.freecamAng.pitch + mY * m_pitch:GetFloat(), -89, 89)
    CDeath.freecamAng.yaw   = CDeath.freecamAng.yaw - mX * m_yaw:GetFloat()
    CDeath.freecamAng.roll  = 0
    cmd:SetViewAngles(CDeath.freecamAng)
end
hook.Add("CreateMove", "CinematicDeathFreecamLook", CinematicDeathFreecamLook)

-- cam view shit. so you can spawn things in spectator
local function BuildDeathView(fov)
    if CDeath.compatActive then 
        return {
            origin     = LocalPlayer():EyePos(),
            angles     = LocalPlayer():EyeAngles(),
            fov        = fov,
            drawviewer = false,
        }
    end

    if CDeath.inSpectator then
        local dt        = FrameTime()
        local speedMult = SafeKeyDown(sprintKeyCode) and 3 or 1
        local speed     = 200 * dt * speedMult
        local fwd       = CDeath.freecamAng:Forward()
        local right     = CDeath.freecamAng:Right()
        local up        = Vector(0, 0, 1)

        if input.IsButtonDown(KEY_W) then CDeath.freecamPos = CDeath.freecamPos + fwd   * speed end
        if input.IsButtonDown(KEY_S) then CDeath.freecamPos = CDeath.freecamPos - fwd   * speed end
        if input.IsButtonDown(KEY_A) then CDeath.freecamPos = CDeath.freecamPos - right * speed end
        if input.IsButtonDown(KEY_D) then CDeath.freecamPos = CDeath.freecamPos + right * speed end
        if SafeKeyDown(jumpKeyCode)   then CDeath.freecamPos = CDeath.freecamPos + up   * speed end
        if SafeKeyDown(crouchKeyCode) then CDeath.freecamPos = CDeath.freecamPos - up   * speed end

        return { origin = CDeath.freecamPos, angles = CDeath.freecamAng, fov = fov, drawviewer = false }
    end

    local elapsed = CurTime() - CDeath.deathTime
    local view = { origin = CDeath.deathCamPos, fov = fov, drawviewer = false }

    if elapsed < STAGE_1_DURATION then
        local intensity = (1 - (elapsed / STAGE_1_DURATION)) * 15
        view.angles = CDeath.deathCamAng + Angle(
            math.sin(CurTime() * 30) * intensity,
            math.cos(CurTime() * 35) * intensity,
            math.sin(CurTime() * 40) * intensity
        )
    else
        if IsValid(CDeath.ragdollEnt) then
            local targetPos = GetRagdollHeadPos(CDeath.ragdollEnt)
            local targetAng = (targetPos - CDeath.deathCamPos):Angle()
            CDeath.deathCamAng = LerpAngle(FrameTime() * 4, CDeath.deathCamAng, targetAng)

            local dist = CDeath.deathCamPos:Distance(targetPos)
            if dist > 0 then
                local dir    = (targetPos - CDeath.deathCamPos):GetNormalized()
                local maxDist = cv_cam_max_dist and cv_cam_max_dist:GetFloat() or 150
                local minDist = cv_cam_min_dist and cv_cam_min_dist:GetFloat() or 40
                if dist > maxDist then
                    CDeath.deathCamPos = LerpVector(FrameTime() * 2, CDeath.deathCamPos, targetPos - dir * maxDist)
                elseif dist < minDist then
                    CDeath.deathCamPos = LerpVector(FrameTime() * 2, CDeath.deathCamPos, targetPos - dir * minDist)
                end
            end
        end
        view.origin = CDeath.deathCamPos
        view.angles = CDeath.deathCamAng
    end

    return view
end

-- calcview mm
local function CinematicDeathCamera(ply, pos, angles, fov)
    if not CDeath.isDead then return end
    return BuildDeathView(fov)
end
hook.Add("CalcView", "CinematicDeathCamera", CinematicDeathCamera)

local function CinematicDeathHGCalcView(ply, origin, angles, fov, znear, zfar)
    if not CDeath.isDead then return end
    return BuildDeathView(fov)
end
hook.Add("HG_CalcView", "CinematicDeathHGOverride", CinematicDeathHGCalcView)

-- audio and visual overrides
local function CinematicDeathMute()
    if CDeath.isDead and CDeath.stage2Started and not CDeath.inSpectator and not CDeath.compatActive then
        return false
    end
end
hook.Add("EntityEmitSound", "CinematicDeathMute", CinematicDeathMute)

local function CinematicDeathHideRagdoll()
    if not CDeath.isDead or not IsValid(CDeath.ragdollEnt) or CDeath.compatActive then return end
    
    if (CurTime() - CDeath.deathTime) < STAGE_1_DURATION then
        CDeath.ragdollEnt:SetNoDraw(true)
    else
        CDeath.ragdollEnt:SetNoDraw(false)
    end
end
hook.Add("PreDrawOpaqueRenderables", "CinematicDeathHideRagdoll", CinematicDeathHideRagdoll)

local function CinematicDeathBackground()
    if not CDeath.isDead or CDeath.compatActive then return end

    local sw, sh  = ScrW(), ScrH()
    local elapsed = CurTime() - CDeath.deathTime

    if CDeath.inTransition then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, sw, sh)
        return
    end

    if CDeath.inSpectator then
        local hint = "double click [" .. reloadKeyName .. "] to respawn"
        surface.SetFont("DeathEffect_Hint")
        local hw = surface.GetTextSize(hint)
        surface.SetTextColor(Color(180, 180, 180, 140))
        surface.SetTextPos(sw / 2 - hw / 2, 20)
        surface.DrawText(hint)
        return
    end

    if elapsed >= STAGE_1_DURATION then
        local stageElapsed = elapsed - STAGE_1_DURATION
        local fadeProgress = math.Clamp(stageElapsed / BLACK_FADE_DURATION, 0, 1)
        local fadeOutProgress = math.Clamp((stageElapsed - BLACK_FADE_DURATION) / BLACK_FADE_OUT_DURATION, 0, 1)
        local overlayAlpha = math.floor((1 - fadeOutProgress) * 255)
        local colorFade = 1 - fadeProgress
        local deathColor = CDeath.deathColor
        surface.SetDrawColor(
            math.floor(deathColor.r * colorFade),
            math.floor(deathColor.g * colorFade),
            math.floor(deathColor.b * colorFade),
            overlayAlpha
        )
        surface.DrawRect(0, 0, sw, sh)

        if fadeProgress < 1 and IsValid(CDeath.ragdollEnt) then
            cam.Start3D(CDeath.deathCamPos, CDeath.deathCamAng)
            cam.IgnoreZ(true)
            render.SuppressEngineLighting(true)
            render.MaterialOverride(matWhite)
            render.SetColorModulation(0, 0, 0)
            render.SetBlend(1)

            local ok, err = pcall(CDeath.ragdollEnt.DrawModel, CDeath.ragdollEnt)

            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
            render.MaterialOverride(nil)
            render.SuppressEngineLighting(false)
            cam.IgnoreZ(false)
            cam.End3D()

            if not ok then ErrorNoHaltWithStack(tostring(err)) end
        end

        local textFadeIn = math.Clamp(stageElapsed / DEATH_TEXT_FADE_IN, 0, 1)
        local textAlpha = math.floor(textFadeIn * overlayAlpha * (1 - fadeProgress))
        local shake = 5 * (1 - textFadeIn)
        local text = CDeath.deathMessage.title
        local desc = CDeath.deathMessage.desc
        local slide = 1 - ((1 - textFadeIn) ^ 3)
        local textX = Lerp(slide, -650, 70) + math.sin(CurTime() * 95) * shake
        local textY = sh / 2 - 60 + math.cos(CurTime() * 110) * shake
        draw.SimpleText(text, "DeathEffect_HG_Large", textX, textY, Color(0, 0, 0, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(desc, "DeathEffect_HG_Desc", textX + 6, textY + 85, Color(0, 0, 0, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local hint = "press [SPACE] or [BACKSPACE] to skip"
        local hintAlpha = math.floor(textFadeIn * overlayAlpha * 0.45)
        draw.SimpleText(hint, "DeathEffect_Hint", sw / 2, sh - 36, Color(0, 0, 0, hintAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

end
hook.Add("DrawOverlay", "CinematicDeathBackground", CinematicDeathBackground)

local function HideDefaultDamage(name)
    if CDeath.isDead and name == "CHudDamageIndicator" then return false end
end
hook.Add("HUDShouldDraw", "HideDefaultDamage", HideDefaultDamage)
