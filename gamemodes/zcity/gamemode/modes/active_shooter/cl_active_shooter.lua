local MODE = MODE

local isShooter = false
local releaseAt = 0
local swatAt = 0
local briefingEnds = 0
local swatArrivalShown = false
local swatEnds = 0

local musicSnd = nil
local roundStartSnd = nil

surface.CreateFont("ZB_ActiveShooterTimer", {
	font = "Remingtoned Type",
	size = ScreenScale(30),
	weight = 700,
	antialias = true,
})

surface.CreateFont("ZB_ActiveShooterBriefing", {
	font = "Mx437 IBM PS/55 re.",
	size = ScreenScale(25),
	weight = 400,
	antialias = true,
})

surface.CreateFont("ZB_ActiveShooterBriefingSmall", {
	font = "Mx437 IBM PS/55 re.",
	size = ScreenScale(15),
	weight = 400,
	antialias = true,
})

local function StopMusic()
	if musicSnd then
		musicSnd:Stop()
		musicSnd = nil
	end
end

local function FadeOutMusic(fadeTime)
	if musicSnd then
		local snd = musicSnd
		musicSnd = nil
		fadeTime = fadeTime or 3
		snd:FadeOut(fadeTime)
		timer.Simple(fadeTime + 0.1, function()
			if snd then
				snd:Stop()
			end
		end)
	end
end

local function StopRoundStartSound()
	if roundStartSnd then
		roundStartSnd:Stop()
		roundStartSnd = nil
	end
end

local function PlayRoundStartSound()
	StopRoundStartSound()

	sound.PlayFile("sound/shooterround.mp3", "noplay noblock", function(audio)
		if IsValid(audio) then
			audio:EnableLooping(true)
			audio:Play()
			roundStartSnd = audio
		end
	end)
end

net.Receive("active_shooter_start", function()
	isShooter = net.ReadBool()
	MODE.LocalIsShooter = isShooter
	releaseAt = net.ReadFloat()
	swatAt = net.ReadFloat()
	local playRoundSounds = net.ReadBool()
	if briefingEnds <= CurTime() then
		briefingEnds = CurTime() + 8
		PlayRoundStartSound()
	end
	swatArrivalShown = false
	swatEnds = 0

	StopMusic()

	if playRoundSounds then
		local musicVolume = GetConVar("snd_musicvolume"):GetFloat()
		musicSnd = CreateSound(LocalPlayer(), "theyouthinmyblood.mp3")
		if musicSnd then
			musicSnd:PlayEx(0.6 * musicVolume, 100)
		end
	end
end)

net.Receive("active_shooter_end", function()
	local winner = net.ReadUInt(2)
	FadeOutMusic(3)
	StopRoundStartSound()
end)

function MODE:Think()
	if roundStartSnd and briefingEnds > 0 and CurTime() >= briefingEnds then
		StopRoundStartSound()
	end
end

function MODE:RenderScreenspaceEffects()
	local blackUntil = isShooter and releaseAt or briefingEnds
	if CurTime() >= blackUntil then return end

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end

function MODE:HUDPaint()
	local now = CurTime()
	local width, height = ScrW(), ScrH()

	if now < briefingEnds then
		local fade = math.Clamp(briefingEnds - now, 0, 1)
		local roleColor = isShooter and Color(210, 35, 35, 255 * fade) or Color(55, 150, 225, 255 * fade)
		local role = isShooter and "You are the Active Shooter" or "You are a Victim"
		local objective = isShooter and "Wait for release, then eliminate every victim before SWAT arrives." or "Hide and survive until SWAT arrives."

		draw.SimpleText("ACTIVE SHOOTER", "ZB_ActiveShooterBriefing", width * 0.5, height * 0.12, Color(220, 220, 220, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(role, "ZB_ActiveShooterBriefing", width * 0.5, height * 0.5, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(objective, "ZB_ActiveShooterBriefingSmall", width * 0.5, height * 0.88, roleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if now >= briefingEnds and now < releaseAt then
		local seconds = math.max(math.ceil(releaseAt - now), 0)
		if isShooter then
			draw.SimpleText(string.FormattedTime(seconds, "%02i:%02i"), "ZB_ActiveShooterTimer", width * 0.5, height * 0.5, Color(255, 40, 40), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText(string.FormattedTime(seconds, "%02i:%02i"), "ZB_ActiveShooterTimer", width * 0.03, height * 0.94, Color(255, 40, 40), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	elseif now >= releaseAt and swatAt > now then
		local seconds = math.max(math.ceil(swatAt - now), 0)
		local pulse = (math.sin(now * 3) + 1) * 0.5
		local swatCountdownColor = Color(Lerp(pulse, 255, 25), 25, Lerp(pulse, 25, 255), 255)
		draw.SimpleText("SWAT arrives in: " .. string.FormattedTime(seconds, "%02i:%02i"), "ZB_HomicideMedium", width * 0.03, height * 0.94, swatCountdownColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	if swatAt > 0 and now >= swatAt and not swatArrivalShown then
		swatArrivalShown = true
		swatEnds = now + 8
	end

	if swatArrivalShown and now < swatEnds then
		draw.SimpleText("SWAT HAS ARRIVED", "ZB_HomicideMediumLarge", width * 0.5, height * 0.3, Color(255, 170, 50), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
