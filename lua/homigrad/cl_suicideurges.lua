local lastPress = 0
local plainUntil = 0
local flashRed = 0
local wasActive = false
local wasSelfHarmActive = false
local urgeSound

local urgeLoopPath = "sound/rem_earsringaswounddeepens.ogg"
local urgeLoop = nil
local urgeLoopLoading = false
local urgeLoopVol = 0
local urgeLoopFadeSpeed = 1.2

local function ensureUrgeLoop()
	if IsValid(urgeLoop) or urgeLoopLoading then return end

	urgeLoopLoading = true
	sound.PlayFile(urgeLoopPath, "noblock noplay", function(station, errCode, errStr)
		urgeLoopLoading = false

		if not IsValid(station) then return end

		station:SetVolume(0)
		station:Play()
		station:EnableLooping(true)
		urgeLoop = station
	end)
end

local function stopUrgeLoop()
	urgeLoopVol = 0

	if IsValid(urgeLoop) then
		urgeLoop:Stop()
	end

	urgeLoop = nil
end

local function updateUrgeLoop(active)
	if active then
		ensureUrgeLoop()
	elseif IsValid(urgeLoop) and urgeLoopVol <= 0.01 then
		stopUrgeLoop()
		return
	end

	if not IsValid(urgeLoop) then return end

	local target = active and 1 or 0
	urgeLoopVol = math.Approach(urgeLoopVol, target, FrameTime() * urgeLoopFadeSpeed)
	urgeLoop:SetVolume(urgeLoopVol)
end

local flashMat = Material("vgui/flash.png")
local flashFade = 0

local function stopUrges()
	if urgeSound then
		urgeSound:Stop()
		urgeSound = nil
	end

	wasActive = false
end

net.Receive("rem_selfharm_end", function()
	flashFade = 1
	surface.PlaySound("rem_enditall.mp3")
end)

net.Receive("rem_urges_end", function()
	flashFade = 1
	surface.PlaySound("rem_enditall.mp3")
end)

hook.Add("PlayerButtonDown", "REM_UrgesPress", function(ply, button)
	if ply ~= LocalPlayer() or button ~= KEY_E then return end

	local selfharmEnd = ply:GetNWFloat("rem_selfharm_wave_end", 0)
	if selfharmEnd > CurTime() then
		lastPress = CurTime()
		plainUntil = CurTime() + 0.1

		net.Start("rem_selfharm_press")
		net.SendToServer()
		return
	end

	if ply:GetNWFloat("rem_urges_end", 0) < CurTime() then return end

	lastPress = CurTime()
	plainUntil = CurTime() + 0.1

	net.Start("rem_urges_press")
	net.SendToServer()
end)

local function drawResistText(text, x, y)
	local pressAmt = math.max(1 - (CurTime() - lastPress) / 0.25, 0)
	local col = Color(255, 255 - 255 * pressAmt, 255 - 255 * pressAmt, 255)

	draw.SimpleText(text, "HomigradFontGigantoNormous", x, y, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("HUDPaint", "REM_SuicideUrges", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then
		stopUrges()
		stopUrgeLoop()
		return
	end

	local now = CurTime()
	local drew = false

	local selfHarmEnd = ply:GetNWFloat("rem_selfharm_wave_end", 0)
	if selfHarmEnd > now then
		drew = true

		if not wasSelfHarmActive then
			wasSelfHarmActive = true
		end

		local text = now < plainUntil and "E FIGHT THE URGE" or ">E< FIGHT THE URGE"
		drawResistText(text, ScrW() / 2 + math.random(-4, 4), ScrH() / 2 + ScrH() * 0.12 + math.random(-3, 3))
	elseif wasSelfHarmActive then
		wasSelfHarmActive = false
		lastPress = 0
	end

	local endT = ply:GetNWFloat("rem_urges_end", 0)
	if endT > now then
		drew = true

		if not wasActive then
			wasActive = true
			flashRed = 1

			if not urgeSound then
				urgeSound = CreateSound(LocalPlayer(), "rem_resisttheurges.mp3")
				urgeSound:Play()
			end
		end

		local text = now < plainUntil and "RESIST THE URGES" or ">E< RESIST THE URGES"
		drawResistText(text, ScrW() / 2 + math.random(-4, 4), ScrH() / 2 + ScrH() * 0.12 + math.random(-3, 3))
	end

	local pendingT = ply:GetNWFloat("rem_selfharm_pending", 0)
	local minigameActive = selfHarmEnd > now or endT > now or pendingT > now

	updateUrgeLoop(minigameActive)

	if not drew then
		stopUrges()
	end

	if flashRed > 0 then
		surface.SetDrawColor(255, 0, 0, 255 * flashRed)
		surface.DrawRect(0, 0, ScrW(), ScrH())
		flashRed = math.max(flashRed - FrameTime() * 3, 0)
	end

	if flashFade > 0 then
		surface.SetDrawColor(255, 255, 255, 255 * flashFade)
		surface.SetMaterial(flashMat)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		flashFade = math.max(flashFade - FrameTime(), 0)
	end
end)
