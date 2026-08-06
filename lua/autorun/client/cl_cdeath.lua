if not CLIENT then return end

-- config. maybe i'll make more of these customizable soon?
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
    { title = "No Responce.", desc = "Your body remains. You do not." },
    { title = "Gone.", desc = "The world continues without your testimony." },
    { title = "Expired.", desc = "All signs of breath has left you." },
    { title = "Terminated.", desc = "Your perspective has been permanently interrupted." },
    { title = "Silenced.", desc = "Nothing answers from inside the body." },
}

local DEATH_SOUNDS = {
    [0] = "death_ost.mp3",
}

-- server convar values yesss
local cfg_spectator     = true
local cfg_compat        = false
local cfg_options_delay = 4

local deathColors = { Color(255, 0, 0) }
local colorRandom  = true
local colorIndex   = 1

net.Receive("DeathEffect_Config", function()
    cfg_spectator     = net.ReadBool()
    cfg_compat        = net.ReadBool()
    cfg_options_delay = net.ReadFloat()

    local count = net.ReadUInt(8)
    local palette = {}
    for _ = 1, count do
        local r = net.ReadUInt(8)
        local g = net.ReadUInt(8)
        local b = net.ReadUInt(8)
        palette[#palette + 1] = Color(r, g, b)
    end
    if #palette == 0 then palette = { Color(255, 0, 0) } end
    deathColors = palette
    colorRandom = net.ReadBool()
end)

local function NextDeathColor()
    if colorRandom then
        return deathColors[math.random(#deathColors)]
    end
    colorIndex = (colorIndex % #deathColors) + 1
    return deathColors[colorIndex]
end

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
CreateClientConVar(
    "deatheffect_enabled", "1",
    true, true,
    "enable the cinematic death screen",
    0, 1
)

local cv_cam_max_dist = GetConVar("deatheffect_cam_max_dist")
local cv_cam_min_dist = GetConVar("deatheffect_cam_min_dist")
local cv_alt_sound    = GetConVar("deatheffect_alt_sound")
local cv_enabled      = GetConVar("deatheffect_enabled")

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

local hasSpawned    = false
local isDead        = false
local stage2Started = false
local deathTime     = 0
local stage2Time    = 0
local autoCompatTriggered = false
local deathCamPos   = Vector(0, 0, 0)
local deathCamAng   = Angle(0, 0, 0)
local deathPos      = Vector(0, 0, 0)
local ragdollEnt    = nil
local nextRagdollSearch = 0
local deathMessage  = DEATH_MESSAGES[1]
local deathColor    = Color(255, 0, 0)
local matWhite      = Material("models/debug/debugwhite")

local deathSoundChannels = {}
local deathSoundGeneration = 0
local keepSoundAlive = false

local inTransition        = false
local transitionStartTime = 0
local transitionCallback  = nil
local transitionFired     = false

local prevReloadDown = false
local prevJumpDown   = false
local prevSkipDown   = false

local compatActive     = false
local compatActiveTime = 0
local compatTriggered  = false

local inSpectator         = false
local freecamPos          = Vector(0, 0, 0)
local freecamAng          = Angle(0, 0, 0)
local lastReloadPressTime = 0
local prevSpecReloadDown  = false
local nextCamSync         = 0
local nextSoundfade       = 0

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
    if zcity_RenderScene then
        local hooks = hook.GetTable()
        if not hooks["RenderScene"] or not hooks["RenderScene"]["jopa"] then
            hook.Add("RenderScene", "jopa", zcity_RenderScene)
        end
        zcity_RenderScene = nil
    end
    if zcity_CalcView then
        local hooks = hook.GetTable()
        if not hooks["CalcView"] or not hooks["CalcView"]["homigrad-view"] then
            hook.Add("CalcView", "homigrad-view", zcity_CalcView)
        end
        zcity_CalcView = nil
    end
end

local function DeathEffectRoundActive()
    if zb and zb.ROUND_STATE ~= nil then
        return zb.ROUND_STATE == 1
    end

    return true
end


local function PlayClick()
    sound.PlayFile("sound/" .. CLICK_SOUND, "noplay", function(ch)
        if IsValid(ch) then ch:Play() end
    end)
end

local function DoRespawn()
    net.Start("DeathEffect_Respawn")
    net.SendToServer()
end

local function StopDeathSounds()
    deathSoundGeneration = deathSoundGeneration + 1

    for _, station in ipairs(deathSoundChannels) do
        if IsValid(station) then
            station:Stop()
        end
    end
    deathSoundChannels = {}
    keepSoundAlive = false
end

local function RestoreRagdoll()
    if IsValid(ragdollEnt) then
        ragdollEnt:SetNoDraw(false)
        local headBone = ragdollEnt:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            ragdollEnt:ManipulateBoneScale(headBone, Vector(1, 1, 1))
        end
    end
end

local function GetRagdollHeadPos(ent)
    if not IsValid(ent) then return deathPos + Vector(0, 0, STAGE_1_LOOK_HEIGHT) end

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
            local dist = ent:GetPos():DistToSqr(deathPos)
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

    isDead = false
    hasSpawned = false
    stage2Started = false
    inTransition = false
    inSpectator = false
    autoCompatTriggered = false
    compatActive = false
    compatTriggered = false
    RestoreRagdoll()
    ragdollEnt = nil
    ply:SetDSP(0)
    ply:ConCommand("soundfade 0 1")
    StopDeathSounds()
    ReleaseAuthority()
    net.Start("DeathEffect_CompatUnblock")
    net.SendToServer()
end

local function EnterSpectator()
    inSpectator  = true
    freecamPos   = Vector(deathCamPos.x, deathCamPos.y, deathCamPos.z)
    freecamAng   = Angle(deathCamAng.pitch, deathCamAng.yaw, deathCamAng.roll)
    nextCamSync  = 0
    inTransition = false
    LocalPlayer():SetDSP(0)
    LocalPlayer():ConCommand("soundfade 0 1")
    net.Start("DeathEffect_EnterSpectator")
    net.SendToServer()
end

local function ActivateCompatMode()
    compatActive     = true
    compatActiveTime = CurTime()
    inTransition     = false
    LocalPlayer():SetDSP(0)
    LocalPlayer():ConCommand("soundfade 0 1")
    ReleaseAuthority() 
    net.Start("DeathEffect_CompatUnblock")
    net.SendToServer()
end

local function BeginTransition(callback)
    inTransition        = true
    transitionStartTime = CurTime()
    transitionCallback  = callback
    transitionFired     = false
    PlayClick()
end

-- state tracking and init
local function CinematicDeathTracker()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    if cv_enabled and not cv_enabled:GetBool() then
        if isDead then
            SkipDeathScene()
        end

        hasSpawned = ply:Alive()
        prevSkipDown = false
        return
    end

    if not DeathEffectRoundActive() then
        hasSpawned = ply:Alive()

        if isDead then
            isDead = false
            stage2Started = false
            keepSoundAlive = false
            inTransition = false
            inSpectator = false
            autoCompatTriggered = false
            compatActive = false
            ReleaseAuthority()

            RestoreRagdoll()
            ragdollEnt = nil

            ply:SetDSP(0)
            ply:ConCommand("soundfade 0 1")
            StopDeathSounds()
        end

        return
    end

    local skipDown = input.IsButtonDown(KEY_BACKSPACE) or SafeKeyDown(jumpKeyCode)
    if isDead and skipDown and not prevSkipDown then
        SkipDeathScene()
        prevSkipDown = true
        return
    end
    prevSkipDown = skipDown

    if ply:Alive() and not hasSpawned then
        hasSpawned = true
    end

    if not ply:Alive() and not isDead and hasSpawned then
        isDead           = true
        TakeAuthority() 
        stage2Started    = false
        keepSoundAlive   = true
        inTransition     = false
        inSpectator      = false
        autoCompatTriggered = false
        compatActive     = false
        compatActiveTime = 0
        compatTriggered  = false
        deathTime        = CurTime()
        ragdollEnt       = nil
        nextRagdollSearch = 0
        prevReloadDown   = false
        prevJumpDown     = false
        prevSkipDown     = input.IsButtonDown(KEY_BACKSPACE) or SafeKeyDown(jumpKeyCode)
        prevSpecReloadDown = false
        deathMessage     = DEATH_MESSAGES[math.random(#DEATH_MESSAGES)]
        deathColor       = NextDeathColor()

        local plyPos = ply:GetPos()
        deathPos     = plyPos
        ragdollEnt   = FindDeathRagdoll(ply)
        MakeRagdollHeadVisible(ragdollEnt)

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

        deathCamPos = tr.HitPos + tr.HitNormal * 5
        deathCamAng = (plyPos + Vector(0, 0, STAGE_1_LOOK_HEIGHT) - deathCamPos):Angle()

        StopDeathSounds()
        keepSoundAlive = true
        local soundGeneration = deathSoundGeneration
        for _, deathSound in pairs(DEATH_SOUNDS) do
            sound.PlayFile("sound/" .. deathSound, "noplay", function(station)
                if not IsValid(station) then return end

                if soundGeneration ~= deathSoundGeneration or not isDead then
                    station:Stop()
                    return
                end

                deathSoundChannels[#deathSoundChannels + 1] = station
                station:Play()
            end)
        end

    elseif ply:Alive() and isDead then
        isDead         = false
        stage2Started  = false
        keepSoundAlive = false
        inTransition   = false
        inSpectator    = false
        autoCompatTriggered = false
        compatActive   = false
        ReleaseAuthority() 
        
        RestoreRagdoll()
        ragdollEnt = nil

        ply:SetDSP(0)
        ply:ConCommand("soundfade 0 1")
        StopDeathSounds()
    end

    if isDead and not stage2Started then
        if (CurTime() - deathTime) >= STAGE_1_DURATION then
            stage2Started = true
            stage2Time    = CurTime()
            LocalPlayer():SetDSP(17)
            LocalPlayer():ConCommand("soundfade 100 99999")
        end
    end

    -- bypass loop
    if isDead and not compatActive then
        ply:SetViewPunchAngles(Angle(0,0,0))
        ply:ScreenFade(SCREENFADE.IN, Color(0,0,0,0), 0.1, 0)
        
        if stage2Started and not inSpectator then
            ply:SetDSP(17)
            -- keep re-applying the sound muting so it can't be bypassed
            if CurTime() >= nextSoundfade then
                nextSoundfade = CurTime() + 0.5
                ply:ConCommand("soundfade 100 99999")
            end
        end
    end

    if isDead and keepSoundAlive then
        local t = CurTime() - deathTime
        local anyPlaying = false
        for _, station in ipairs(deathSoundChannels) do
            if IsValid(station) and t < station:GetLength() then
                anyPlaying = true
                if station:GetState() ~= 1 then
                    station:Play()
                    station:SetTime(t, false)
                end
            end
        end
        if #deathSoundChannels > 0 and not anyPlaying then
            keepSoundAlive = false
        end
    end

    if isDead and not IsValid(ragdollEnt) and CurTime() >= nextRagdollSearch then
        nextRagdollSearch = CurTime() + 0.2
        ragdollEnt = FindDeathRagdoll(ply)
        MakeRagdollHeadVisible(ragdollEnt)
    end

    if inTransition and not transitionFired then
        if (CurTime() - transitionStartTime) >= TRANSITION_DURATION then
            transitionFired = true
            PlayClick()
            if transitionCallback then
                transitionCallback()
                transitionCallback = nil
            end
        end
    end

    if isDead and stage2Started and not autoCompatTriggered then
        if (CurTime() - stage2Time) >= (BLACK_FADE_DURATION + BLACK_FADE_OUT_DURATION) then
            autoCompatTriggered = true
            ActivateCompatMode()
        end
    end

    if inSpectator and not inTransition then
        local reloadDown = SafeKeyDown(reloadKeyCode)

        if reloadDown and not prevSpecReloadDown then
            local now = CurTime()
            if (now - lastReloadPressTime) <= DOUBLE_CLICK_WINDOW then
                BeginTransition(DoRespawn)
            else
                lastReloadPressTime = now
            end
        end

        prevSpecReloadDown = reloadDown

        local timeNow = CurTime()
        if timeNow >= nextCamSync then
            nextCamSync = timeNow + 0.05
            net.Start("DeathEffect_UpdateCam")
                net.WriteVector(freecamPos)
                net.WriteAngle(freecamAng)
            net.SendToServer()
        end
    end
end
hook.Add("Think", "CinematicDeathTracker", CinematicDeathTracker)

-- mouse tracking
local function CinematicDeathFreecamLook(cmd)
    if not inSpectator then return end
    local mX = cmd:GetMouseX()
    local mY = cmd:GetMouseY()
    freecamAng.pitch = math.Clamp(freecamAng.pitch + mY * m_pitch:GetFloat(), -89, 89)
    freecamAng.yaw   = freecamAng.yaw - mX * m_yaw:GetFloat()
    freecamAng.roll  = 0
    cmd:SetViewAngles(freecamAng)
end
hook.Add("CreateMove", "CinematicDeathFreecamLook", CinematicDeathFreecamLook)

-- cam view shit. so you can spawn things in spectator
local function BuildDeathView(fov)
    if compatActive then 
        return {
            origin     = LocalPlayer():EyePos(),
            angles     = LocalPlayer():EyeAngles(),
            fov        = fov,
            drawviewer = false,
        }
    end

    if inSpectator then
        local dt        = FrameTime()
        local speedMult = SafeKeyDown(sprintKeyCode) and 3 or 1
        local speed     = 200 * dt * speedMult
        local fwd       = freecamAng:Forward()
        local right     = freecamAng:Right()
        local up        = Vector(0, 0, 1)

        if input.IsButtonDown(KEY_W) then freecamPos = freecamPos + fwd   * speed end
        if input.IsButtonDown(KEY_S) then freecamPos = freecamPos - fwd   * speed end
        if input.IsButtonDown(KEY_A) then freecamPos = freecamPos - right * speed end
        if input.IsButtonDown(KEY_D) then freecamPos = freecamPos + right * speed end
        if SafeKeyDown(jumpKeyCode)   then freecamPos = freecamPos + up   * speed end
        if SafeKeyDown(crouchKeyCode) then freecamPos = freecamPos - up   * speed end

        return { origin = freecamPos, angles = freecamAng, fov = fov, drawviewer = false }
    end

    local elapsed = CurTime() - deathTime
    local view = { origin = deathCamPos, fov = fov, drawviewer = false }

    if elapsed < STAGE_1_DURATION then
        local intensity = (1 - (elapsed / STAGE_1_DURATION)) * 15
        view.angles = deathCamAng + Angle(
            math.sin(CurTime() * 30) * intensity,
            math.cos(CurTime() * 35) * intensity,
            math.sin(CurTime() * 40) * intensity
        )
    else
        if IsValid(ragdollEnt) then
            local targetPos = GetRagdollHeadPos(ragdollEnt)
            local targetAng = (targetPos - deathCamPos):Angle()
            deathCamAng = LerpAngle(FrameTime() * 4, deathCamAng, targetAng)

            local dist = deathCamPos:Distance(targetPos)
            if dist > 0 then
                local dir    = (targetPos - deathCamPos):GetNormalized()
                local maxDist = cv_cam_max_dist and cv_cam_max_dist:GetFloat() or 150
                local minDist = cv_cam_min_dist and cv_cam_min_dist:GetFloat() or 40
                if dist > maxDist then
                    deathCamPos = LerpVector(FrameTime() * 2, deathCamPos, targetPos - dir * maxDist)
                elseif dist < minDist then
                    deathCamPos = LerpVector(FrameTime() * 2, deathCamPos, targetPos - dir * minDist)
                end
            end
        end
        view.origin = deathCamPos
        view.angles = deathCamAng
    end

    return view
end

-- calcview mm
local function CinematicDeathCamera(ply, pos, angles, fov)
    if not isDead then return end
    return BuildDeathView(fov)
end
hook.Add("CalcView", "CinematicDeathCamera", CinematicDeathCamera)

local function CinematicDeathHGCalcView(ply, origin, angles, fov, znear, zfar)
    if not isDead then return end
    return BuildDeathView(fov)
end
hook.Add("HG_CalcView", "CinematicDeathHGOverride", CinematicDeathHGCalcView)

-- audio and visual overrides
local function CinematicDeathMute()
    if isDead and stage2Started and not inSpectator and not compatActive then
        return false
    end
end
hook.Add("EntityEmitSound", "CinematicDeathMute", CinematicDeathMute)

local function CinematicDeathHideRagdoll()
    if not isDead or not IsValid(ragdollEnt) or compatActive then return end
    
    if (CurTime() - deathTime) < STAGE_1_DURATION then
        ragdollEnt:SetNoDraw(true)
    else
        ragdollEnt:SetNoDraw(false)
    end
end
hook.Add("PreDrawOpaqueRenderables", "CinematicDeathHideRagdoll", CinematicDeathHideRagdoll)

local function CinematicDeathBackground()
    if not isDead or compatActive then return end

    local sw, sh  = ScrW(), ScrH()
    local elapsed = CurTime() - deathTime

    if inTransition then
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawRect(0, 0, sw, sh)
        return
    end

    if inSpectator then
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
        local intensity = math.floor((1 - fadeProgress) * 255)
        surface.SetDrawColor(deathColor.r * intensity / 255, deathColor.g * intensity / 255, deathColor.b * intensity / 255, overlayAlpha)
        surface.DrawRect(0, 0, sw, sh)

        if fadeProgress < 1 and IsValid(ragdollEnt) then
            cam.Start3D(deathCamPos, deathCamAng)
            cam.IgnoreZ(true)
            render.SuppressEngineLighting(true)
            render.MaterialOverride(matWhite)
            render.SetColorModulation(0, 0, 0)
            render.SetBlend(1)

            local ok, err = pcall(ragdollEnt.DrawModel, ragdollEnt)

            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)
            render.MaterialOverride(nil)
            render.SuppressEngineLighting(false)
            cam.IgnoreZ(false)
            cam.End3D()

            if not ok then
                ErrorNoHaltWithStack(tostring(err))
            end
        end

        local textFadeIn = math.Clamp(stageElapsed / DEATH_TEXT_FADE_IN, 0, 1)
        local textAlpha = math.floor(textFadeIn * overlayAlpha * (1 - fadeProgress))
        local shake = 5 * (1 - textFadeIn)
        local text = deathMessage.title
        local desc = deathMessage.desc
        local slide = 1 - ((1 - textFadeIn) ^ 3)
        local textX = Lerp(slide, -650, 70) + math.sin(CurTime() * 95) * shake
        local textY = sh / 2 - 60 + math.cos(CurTime() * 110) * shake
        draw.SimpleText(text, "DeathEffect_HG_Large", textX, textY, Color(deathColor.r, deathColor.g, deathColor.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(desc, "DeathEffect_HG_Desc", textX + 6, textY + 85, Color(deathColor.r, deathColor.g, deathColor.b, textAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local hint = "press [SPACE] or [BACKSPACE] to skip"
        local hintAlpha = math.floor(textFadeIn * overlayAlpha * 0.45)
        draw.SimpleText(hint, "DeathEffect_Hint", sw / 2, sh - 36, Color(deathColor.r, deathColor.g, deathColor.b, hintAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

end
hook.Add("DrawOverlay", "CinematicDeathBackground", CinematicDeathBackground)

local function HideDefaultDamage(name)
    if isDead and name == "CHudDamageIndicator" then return false end
end
hook.Add("HUDShouldDraw", "HideDefaultDamage", HideDefaultDamage)
