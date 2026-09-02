local Clamp = math.Clamp

local FEAR_SOUND = "stare.ogg"
local APATHY_SOUND = "nothingless.mp3"
local FEAR_THRESHOLD = 0.35
local APATHY_THRESHOLD = 0.45
local FEAR_VOLUME = 0.65
local APATHY_VOLUME = 0.5
local FEAR_FALLBACK = 6
local APATHY_FALLBACK = 45

local fearSound, apathySound
local fearReplayAt, apathyReplayAt
local fearLength = SoundDuration(FEAR_SOUND) or 0
local apathyLength = SoundDuration(APATHY_SOUND) or 0

local function stopPsycheSounds()
	if fearSound then fearSound:Stop() fearSound = nil end
	if apathySound then apathySound:Stop() apathySound = nil end
	fearReplayAt, apathyReplayAt = nil, nil
end

local function updateLoop(snd, replayAt, path, length, fallback, vol)
	if not snd then
		snd = CreateSound(LocalPlayer(), path)
		if not snd then return nil, nil end
		snd:Play()
		if length > 0 then
			replayAt = CurTime() + length
		end
	elseif length > 0 and replayAt and CurTime() >= replayAt then
		snd:Stop()
		snd:Play()
		replayAt = CurTime() + length
	end
	if vol <= 0 then
		snd:Stop()
		return nil, nil
	end
	snd:ChangeVolume(vol, 0.5)
	return snd, replayAt
end

hook.Add("Think", "hg_psyche_effects", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then
		stopPsycheSounds()
		return
	end
	local org = lply.organism
	local fear = Clamp(org.fear or 0, 0, 1)
	local apathy = Clamp(org.psycheApathy or 0, 0, 1)

	local fearVol = fear > FEAR_THRESHOLD and Clamp((fear - FEAR_THRESHOLD) / (1 - FEAR_THRESHOLD), 0, 1) * FEAR_VOLUME or 0
	local apathyVol = apathy > APATHY_THRESHOLD and Clamp((apathy - APATHY_THRESHOLD) / (1 - APATHY_THRESHOLD), 0, 1) * APATHY_VOLUME or 0

	if fearVol > 0 then
		fearSound, fearReplayAt = updateLoop(fearSound, fearReplayAt, FEAR_SOUND, fearLength, FEAR_FALLBACK, fearVol)
	elseif fearSound then
		fearSound:Stop()
		fearSound, fearReplayAt = nil, nil
	end

	if apathyVol > 0 then
		apathySound, apathyReplayAt = updateLoop(apathySound, apathyReplayAt, APATHY_SOUND, apathyLength, APATHY_FALLBACK, apathyVol)
	elseif apathySound then
		apathySound:Stop()
		apathySound, apathyReplayAt = nil, nil
	end
end)

hook.Add("Player_Death", "hg_psyche_sound_stop", function(ply)
	if ply == LocalPlayer() then stopPsycheSounds() end
end)

local vignetteMat = Material("effects/shaders/zb_vignette")
local PANIC_THRESHOLD = 0.45

local psyche_color_tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
hook.Add("RenderScreenspaceEffects", "hg_psyche_color", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then return end
	local org = lply.organism
	local apathy = Clamp(org.psycheApathy or 0, 0, 1)
	local anger = Clamp(org.psycheAnger or 0, 0, 1)
	local fear = Clamp(org.fear or 0, 0, 1)
	local panic = Clamp(org.panicattack or 0, 0, 1)
	local angerFrac = Clamp((anger - 0.5) / 0.5, 0, 1)
	local fearFrac = Clamp((fear - 0.3) / 0.7, 0, 1)
	local panicFrac = Clamp((panic - PANIC_THRESHOLD) / (1 - PANIC_THRESHOLD), 0, 1)
	if apathy < 0.05 and angerFrac <= 0 and fearFrac <= 0 and panicFrac <= 0 then return end

	psyche_color_tab["$pp_colour_addr"] = 0.07 * angerFrac
	psyche_color_tab["$pp_colour_addg"] = 0
	psyche_color_tab["$pp_colour_addb"] = 0.025 * fearFrac
	psyche_color_tab["$pp_colour_brightness"] = -0.05 * apathy - 0.02 * fearFrac - 0.03 * panicFrac
	psyche_color_tab["$pp_colour_contrast"] = 1 - 0.06 * apathy + 0.05 * fearFrac + 0.03 * panicFrac
	psyche_color_tab["$pp_colour_colour"] = 1 - 0.45 * apathy - 0.15 * fearFrac - 0.25 * panicFrac
	DrawColorModify(psyche_color_tab)

	local vignette = fearFrac * 0.8 + panicFrac * 1.8 + apathy * 0.5
	if vignette > 0.02 then
		render.UpdateScreenEffectTexture()
		vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
		vignetteMat:SetFloat("$c0_z", vignette * 0.3)
		vignetteMat:SetFloat("$c1_y", vignette * 1.2)
		render.SetMaterial(vignetteMat)
		render.DrawScreenQuad()
	end

	if panicFrac > 0 then
		local potato = hg.ConVars and hg.ConVars.potatopc and hg.ConVars.potatopc:GetBool() or false
		if not potato then
			DrawToyTown(2, panicFrac * ScrH())
		end
	end
end)
