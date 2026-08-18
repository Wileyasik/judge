local MODE = MODE
MODE.name = "criresp"
local submode = "sobr"
local swatDeploymentTime = 0
local modeSound
local introDuration = 10
local victoryDuration = 6
local victoryScreenDuration = victoryDuration
local soundGeneration = 0
local introChannel
local introReady = false
local introPending = false
local introGeneration = 0

local function StopIntro()
	introGeneration = introGeneration + 1
	introReady = false
	introPending = false
	if IsValid(introChannel) then
		introChannel:Stop()
		introChannel = nil
	end
end

local function StartIntro()
	local channel = introChannel
	if not IsValid(channel) then
		PreloadIntro(true)
		return
	end
	if not introReady then
		introPending = true
		return
	end

	channel:SetTime(0)
	channel:Play()
	local gen = introGeneration
	local trackDuration = channel:GetLength()
	if not isnumber(trackDuration) or trackDuration <= 0 then
		trackDuration = introDuration
	end
	timer.Simple(trackDuration, function()
		if gen ~= introGeneration then return end
		if introChannel == channel and IsValid(channel) then
			channel:Stop()
			introChannel = nil
			introReady = false
		end
	end)
end

local function PreloadIntro(autoPlay)
	introGeneration = introGeneration + 1
	local gen = introGeneration
	introReady = false
	if IsValid(introChannel) then
		introChannel:Stop()
		introChannel = nil
	end
	introPending = autoPlay or introPending

	sound.PlayFile("sound/Crirespstart.mp3", "noplay noblock", function(channel)
		if gen ~= introGeneration then
			if IsValid(channel) then channel:Stop() end
			return
		end
		if not IsValid(channel) then
			introPending = false
			return
		end

		introChannel = channel
		introReady = true
		if introPending then
			introPending = false
			StartIntro()
		end
	end)
end

local function PlayModeSound(path, duration, playToEnd, onReady)
	soundGeneration = soundGeneration + 1
	local generation = soundGeneration
	if IsValid(modeSound) then modeSound:Stop() end

	sound.PlayFile("sound/" .. path, "noplay noblock", function(channel)
		if generation ~= soundGeneration then
			if IsValid(channel) then channel:Stop() end
			return
		end
		if not IsValid(channel) then return end

		modeSound = channel
		channel:Play()
		local fileDuration = channel:GetLength()
		if not isnumber(fileDuration) or fileDuration <= 0 then fileDuration = duration end
		if onReady then onReady(fileDuration) end

		timer.Simple(playToEnd and fileDuration or duration, function()
			if modeSound ~= channel then return end
			if not playToEnd and IsValid(channel) then channel:Stop() end
			modeSound = nil
		end)
	end)
end

net.Receive("criresp_start", function()
	submode = net.ReadString() or "sobr"
	swatDeploymentTime = CurTime() + net.ReadUInt(7)
	StopIntro()
	PreloadIntro()
end)

local function TeamInfo(team_)
	if team_ == 1 then
		return {
			objective = "This is my fucking house, bitches, I can do what I want.",
			name = submode == "us" and "an Armed Robber" or "a Chechen Terrorist",
			color1 = Color(228, 49, 49),
			color2 = Color(228, 49, 49)
		}
	end
	return {
		objective = "Negotiations failed, eliminate the threat. 10-4",
		name = submode == "sobr" and "an SOBR Operator" or "a US Special Forces Operator",
		color1 = Color(68, 10, 255),
		color2 = Color(68, 10, 255)
	}
end

function MODE:RenderScreenspaceEffects()
	zb.RemoveFade()
	hg.RoundStart.Fade({startTime = zb.ROUND_START, duration = introDuration})
end

local endWinner = nil
local endStart = 0

net.Receive("cri_roundend", function()
	endWinner = net.ReadBool() and 1 or 0
	endStart = CurTime()
	swatDeploymentTime = 0
	victoryScreenDuration = victoryDuration
	PlayModeSound("Crirespwin.mp3", victoryDuration, true, function(fileDuration)
		victoryScreenDuration = math.max(victoryDuration, fileDuration)
	end)
end)

surface.CreateFont("ZB_CrirespHeader", {
	font = "ITC Avant Garde Gothic",
	size = math.floor(ScrH() * 0.08),
	weight = 700,
	antialias = true,
	extended = true
})

surface.CreateFont("ZB_CrirespMediumLarge", {
	font = "ITC Avant Garde Gothic",
	size = math.floor(ScrH() * 0.04),
	weight = 700,
	antialias = true,
	extended = true
})

function MODE:HUDPaint()
	local preparationLeft = math.max(math.ceil(swatDeploymentTime - CurTime()), 0)
	local introFinished = CurTime() >= (zb.ROUND_START or 0) + introDuration
	if introFinished and preparationLeft > 0 and IsValid(lply) and lply:Team() ~= TEAM_SPECTATOR then
		local label = lply:Team() == 1 and "PREPARE FOR THE ASSAULT" or "DEPLOYMENT IN"
		draw.SimpleText(label .. ": " .. string.FormattedTime(preparationLeft, "%02i:%02i"), "ZB_CrirespMediumLarge", ScrW() * 0.5, ScrH() * 0.12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if zb.ROUND_START + introDuration > CurTime() then
		if IsValid(lply) and lply:Team() ~= TEAM_SPECTATOR then
			local info = TeamInfo(lply:Team())
			hg.RoundStart.DrawTitle({
				header = "Crisis Response",
				lines = {
					{text = "You are " .. info.name, color = info.color1, font = "ZB_HomicideMediumLarge"}
				},
				objective = info.objective
			}, {startTime = zb.ROUND_START, duration = introDuration})
		end
	end

	if endStart > 0 then
		local t = CurTime() - endStart
		if t < victoryScreenDuration then
			local ina = math.Clamp(t / 0.4, 0, 1)
			local outa = math.Clamp((victoryScreenDuration - t) / 0.6, 0, 1)
			local a = 255 * ina * outa
			local title, titleCol, teamName
			if endWinner == 1 then
				title = "CRIMINALS WIN"
				titleCol = Color(228, 49, 49, a)
				teamName = submode == "us" and "ARMED ROBBERS" or "CHECHEN TERRORISTS"
			else
				title = "SWAT VICTORY"
				titleCol = Color(68, 10, 255, a)
				teamName = submode == "us" and "US SPECIAL FORCES" or "SOBR OPERATORS"
			end
			draw.SimpleText(title, "ZB_CrirespHeader", sw * 0.5, sh * 0.3, titleCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText(teamName, "ZB_CrirespMediumLarge", sw * 0.5, sh * 0.3 + ScreenScale(45), Color(255, 255, 255, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		else
			endStart = 0
		end
	end

	if hg.PluvTown.Active then
		local fade = math.Clamp(zb.ROUND_START + 10 - CurTime(), 0, 1)
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function MODE:RoundStart()
	endStart = 0
	endWinner = nil
	StartIntro()
end
