MODE.name = "gwars"
local MODE = MODE

local ended

local MusicVolume = GetConVar("snd_musicvolume")

net.Receive("gwars_start", function()
	local teamID = LocalPlayer():Team()
	if teamID == 0 then
		surface.PlaySound("zoo.MP3")
	elseif teamID == 1 then
		surface.PlaySound("trinity.MP3")
	else
		surface.PlaySound("zbattle/nigshit.mp3")
	end
	zb.RemoveFade()
	ended = nil

	sound.PlayFile("sound/rumble.mp3", "noblock noplay", function(station)
		if IsValid(station) then
			GWARS_LoopStation = station
			station:SetVolume(1 * MusicVolume:GetFloat())
			station:EnableLooping(true)
		end
	end)

	sound.PlayFile("sound/rumble.mp3", "noblock noplay", function(station)
		if IsValid(station) then
			GWARS_LoopStation2 = station
			station:SetVolume(1 * MusicVolume:GetFloat())
			station:EnableLooping(true)
		end
	end)

	
end)

local teams = {
	[0] = {
		objective = "Kill all Trinity members.",
		name = "a The Zoo Member",
		phrase = "We're not to be reckoned with.",
		color1 = Color(13, 250, 241),
		color2 = Color(13, 250, 241)
	},
	[1] = {
		objective = "Kill all Zoo animals.",
		name = "a The Trinity Member",
		phrase = "Prove them wrong.",
		color1 = Color(255, 129, 0),
		color2 = Color(255, 129, 0)
	},
}
local lerpsnd = 0.3
function MODE:RenderScreenspaceEffects()
	zb.RemoveFade()
	hg.RoundStart.Fade({startTime = zb.ROUND_START, duration = 10})
end

surface.CreateFont("timer_Font2", {
	font = "Courier Prime", 
	size = ScreenScale(12), 
	extended = true, 
	weight = 650,
	antialias = true,
	italic = false
})

function MODE:HUDPaint()
	//if !lply.organism or !lply.organism.fear then return end

	local timeBeforeSWAT = (zb.ROUND_START - CurTime() + 120)
	if timeBeforeSWAT > 0 and zb.ROUND_START + 10.5 < CurTime() then
		local time = string.FormattedTime(timeBeforeSWAT, "%02i:%02i:%02i")
		local text = "00:00:00"
		surface.SetFont("timer_Font2")
		surface.SetDrawColor(255, 255, 255, 255)
		local w, h = surface.GetTextSize(text)
		local w2, h2 = surface.GetTextSize("11:11:11 time left before reinforcements arrive!")
		local y = sh * 0.9
		surface.SetTextPos(sw * 0.5 - w2 / 2, y)
		surface.DrawText(time)
		surface.SetTextPos(sw * 0.5 - w2 / 2 + w, y)
		surface.DrawText("time left before reinforcements arrive!")
		//draw.SimpleText(" left before SWAT arrives!", "timer_Font2", sw * 0.432, sh * 0.05, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		//draw.SimpleText(time, "timer_Font2", sw * 0.36, sh * 0.05, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end

	if zb.ROUND_START + 8 < CurTime() then
		lerpsnd = LerpFT(0.01, lerpsnd, !ended and (lply:Alive() and lply.organism and !lply.organism.otrub and lply.organism.fear and math.Clamp(lply.organism.fear + 0.3 + (timeBeforeSWAT <= 0 and 2 or 0), 0, 1) or 0.3) or 0)
		
		if zb.ROUND_START + 12 < CurTime() then
			if IsValid(GWARS_LoopStation) then
				GWARS_LoopStation:SetVolume(lerpsnd * MusicVolume:GetFloat())
				GWARS_LoopStation:Play()
				
				if IsValid(GWARS_LoopStation2) then
					GWARS_LoopStation2:SetVolume(0)
					GWARS_LoopStation2:Play()
				end
			end
		end

		if IsValid(GWARS_LoopStation) and GWARS_LoopStation:GetState() == GMOD_CHANNEL_PLAYING then
			GWARS_LoopStation:SetVolume(lerpsnd * MusicVolume:GetFloat())
		end
	
		if timeBeforeSWAT <= 0 then
			if IsValid(GWARS_LoopStation2) then
				GWARS_LoopStation2:SetVolume(lerpsnd * MusicVolume:GetFloat())
			end
			
			if IsValid(GWARS_LoopStation) then
				GWARS_LoopStation:SetVolume(0)
			end
		end
	end

	if zb.ROUND_START + 10 < CurTime() then return end

	local info = teams[lply:Team()]
	if not info then return end

	local fade = math.Clamp(zb.ROUND_START + 10 - CurTime(), 0, 1)

	hg.RoundStart.DrawTitle({
		header = "Gang Wars",
		lines = {
			{text = "You are " .. info.name, color = info.color1, font = "ZB_HomicideMediumLarge"},
			{text = info.phrase, color = info.color1, font = "ZB_HomicideMedium"}
		},
		objective = info.objective,
		color = info.color1
	}, {startTime = zb.ROUND_START, duration = 10})

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

net.Receive("gwars_roundend", function()
	ended = true
end)

function MODE:RoundStart()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
end
