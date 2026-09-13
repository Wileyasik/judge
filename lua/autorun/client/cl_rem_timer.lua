--client

local COL_BG        = Color(10, 10, 11, 255)
local COL_BG_DARK   = Color(3, 3, 4, 255)
local COL_BORDER    = Color(255, 255, 255, 255)
local COL_TEXT      = Color(245, 245, 245, 255)
local COL_MUTED     = Color(200, 200, 200, 255)
local COL_SHADOW    = Color(0, 0, 0, 140)
local COL_DANGER    = Color(235, 60, 60, 255)
local COL_FLASH_BG  = Color(120, 10, 10, 255)

local DANGER_THRESHOLD = 10  
local FLASH_DURATION   = 4 
local CANCEL_HOLD      = 1.3 
local FADE_IN_TIME     = 1.5 
local FADE_OUT_TIME    = 2.5 
local REVEAL_DURATION  = 0.9 
local BLINK_RATE       = 4  
local FINISH_BEEP_RATE = 1.5 
local FINISH_VOLUME    = 0.45 

local SND_REVEAL  = "keljoy/texttt.wav"        --text
local SND_PAUSE   = "buttons/button14.wav"  -- pause
local SND_FINISH  = "ambient/alarms/warningbell1.wav" -- end
local SND_CANCEL  = "keljoy/goodbye.mp3"       --deceased
local gradient_d = surface.GetTextureID("vgui/gradient-d")
surface.CreateFont("RemTimer_Digits", {
	font = "Lora",
	size = 54,
	weight = 800,
	antialias = true,
})
surface.CreateFont("RemTimer_Reason", {
	font = "Lora",
	size = 27,
	weight = 700,
	antialias = true,
})
surface.CreateFont("RemTimer_Label", {
	font = "Lora",
	size = 15,
	weight = 700,
	antialias = true,
})
surface.CreateFont("RemTimer_Cancel", {
	font = "Lora",
	size = 38,
	weight = 800,
	antialias = true,
})

--  util

local function EaseOutCubic(t)
	return 1 - (1 - t) ^ 3
end

local function EaseInCubic(t)
	return t * t * t
end

local function FormatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	local m = math.floor(seconds / 60)
	local s = seconds % 60
	return string.format("%02d:%02d", m, s)
end

local function RevealText(text, progress)
	progress = math.Clamp(progress, 0, 1)

	local maskableIdx = {}
	for i = 1, #text do
		local ch = string.sub(text, i, i)
		if not string.match(ch, "[:%s]") then
			table.insert(maskableIdx, i)
		end
	end

	local numRevealed = math.floor(progress * #maskableIdx + 0.0001)
	local revealedSet = {}
	for i = 1, numRevealed do
		revealedSet[maskableIdx[i]] = true
	end

	local out = {}
	for i = 1, #text do
		local ch = string.sub(text, i, i)
		if string.match(ch, "[:%s]") or revealedSet[i] then
			table.insert(out, ch)
		else
			table.insert(out, "#")
		end
	end

	return table.concat(out)
end

local function DrawBottomGradient(w, h)
	local gradH = h * 0.45
	surface.SetTexture(gradient_d)
	surface.SetDrawColor(255, 255, 255, 7)
	surface.DrawTexturedRect(0, h - gradH, w, gradH)
end

local PANEL = {}

local PANEL_W = 380
local PANEL_H = 210
local RIGHT_MARGIN = 24
local TOP_MARGIN = 24

function PANEL:Init()
	self:SetSize(PANEL_W, PANEL_H)
	self.startTime = CurTime()
	self.slideIn = 0.5
	self.slideOut = 0.4
	self.slideOutBegun = false
	self.slideOutStartTime = nil

	self.paused = false
	self.frozenElapsed = 0
	self.pauseRealTime = 0
	self.musicChannel = nil
	self.lastRevealedCount = 0

	self.finished = false
	self.finishTime = nil
	self.blinkState = false
	self.lastBeepState = false

	self.cancelled = false
	self.cancelTime = nil

	self:SetPos(ScrW() - PANEL_W - RIGHT_MARGIN, -self:GetTall() - 10)
	self:SetMouseInputEnabled(true)
end

function PANEL:SetupTimer(duration, reason, soundFile)
	self.duration = math.max(1, duration)
	self.reason = reason or ""
	self.hold = self.duration
	self.totalTime = self.slideIn + self.hold + self.slideOut

	-- music: exaple of wokr (some shit liek rem_timer 43 reason music.mp3 plesae test ti)
	if soundFile and soundFile ~= "" then
		local musicPath = "sound/" .. soundFile
		sound.PlayFile(musicPath, "noplay", function(channel, errID, errName)
			if not IsValid(self) then return end
			if channel then
				channel:SetVolume(0)
				self.musicChannel = channel
				channel:Play()
			else
				print("[rem_timer] Could not play '" .. musicPath .. "' - " .. tostring(errName or errID or "unknown error"))
				print("[rem_timer] Make sure the file exists at garrysmod/sound/" .. soundFile)
			end
		end)
	end
end

--paus
function PANEL:Pause()
	if self.paused or self.cancelled or self.finished then return end
	self.paused = true
	self.frozenElapsed = CurTime() - self.startTime
	self.pauseRealTime = CurTime()

	if IsValid(self.musicChannel) then
		self.musicChannel:Pause()
	end

	surface.PlaySound(SND_PAUSE)
end

-- resume (music also contineus )
function PANEL:Resume()
	if not self.paused then return end
	local pausedFor = CurTime() - self.pauseRealTime
	self.startTime = self.startTime + pausedFor
	self.paused = false

	if IsValid(self.musicChannel) then
		self.musicChannel:Play()
	end
end

-- kkkkkkk
-- turn 
function PANEL:CancelTimer()
	if self.cancelled or self.finished then return end
	self.cancelled = true
	self.cancelTime = CurTime()

	if IsValid(self.musicChannel) then
		self.musicChannel:Stop()
	end

	surface.PlaySound(SND_CANCEL)

	timer.Simple(CANCEL_HOLD, function()
		if IsValid(self) then self:BeginSlideOut() end
	end)
end

function PANEL:BeginSlideOut()
	if self.slideOutBegun then return end
	self.slideOutBegun = true
	self.slideOutStartTime = CurTime()

	timer.Simple(self.slideOut, function()
		if IsValid(self) then self:Remove() end
	end)
end

function PANEL:GetElapsed()
	if self.paused then
		return self.frozenElapsed
	end
	return CurTime() - self.startTime
end

function PANEL:OnRemove()
	if IsValid(self.musicChannel) then
		self.musicChannel:Stop()
	end
	if IsValid(self.finishSound) then
		self.finishSound:Stop()
	end
end

function PANEL:OnMousePressed()
	-- sob
end

function PANEL:Think()
	local elapsed = self:GetElapsed()
	local h = self:GetTall()
	local targetY = TOP_MARGIN
	local hiddenY = -h - 10
	local y

	if elapsed < self.slideIn then
		local frac = EaseOutCubic(elapsed / self.slideIn)
		y = Lerp(math.Clamp(frac, 0, 1), hiddenY, targetY)
	elseif self.slideOutBegun then
		local outElapsed = CurTime() - self.slideOutStartTime
		local frac = EaseInCubic(math.Clamp(outElapsed / self.slideOut, 0, 1))
		y = Lerp(frac, targetY, hiddenY)
	else
		y = targetY
	end

	self:SetPos(ScrW() - PANEL_W - RIGHT_MARGIN, y)

	
	if not self.cancelled then
		local revealProgress = math.Clamp(elapsed / REVEAL_DURATION, 0, 1)
		local revealedCount = math.floor(revealProgress * 4 + 0.0001)
		if revealedCount > self.lastRevealedCount then
			for _ = self.lastRevealedCount + 1, revealedCount do
				surface.PlaySound(SND_REVEAL)
			end
			self.lastRevealedCount = revealedCount
		end
	end

	
	if not self.cancelled and not self.finished and not self.paused then
		local remaining = self.duration - math.max(0, elapsed - self.slideIn)
		if remaining <= 0 then
			self.finished = true
			self.finishTime = CurTime()
			timer.Simple(FLASH_DURATION, function()
				if IsValid(self) then self:BeginSlideOut() end
			end)
		end
	end

	
	if self.finished and not self.slideOutBegun then
		local blinkOn = math.floor((CurTime() - self.finishTime) * BLINK_RATE) % 2 == 0
		self.blinkState = blinkOn

		local beepOn = math.floor((CurTime() - self.finishTime) * FINISH_BEEP_RATE) % 2 == 0
		if beepOn and not self.lastBeepState then
			if not IsValid(self.finishSound) then
				self.finishSound = CreateSound(LocalPlayer(), SND_FINISH)
			end
			self.finishSound:PlayEx(FINISH_VOLUME, 100)
		end
		self.lastBeepState = beepOn
	end

	-- fade 
	if IsValid(self.musicChannel) and not self.paused then
		local remaining = self.duration - math.max(0, elapsed - self.slideIn)
		local volIn = math.Clamp(elapsed / FADE_IN_TIME, 0, 1)
		local volOut = math.Clamp(remaining / FADE_OUT_TIME, 0, 1)
		self.musicChannel:SetVolume(math.min(volIn, volOut))
	end
end

function PANEL:Paint(w, h)
	local elapsed = self:GetElapsed()
	local remaining = self.duration - math.max(0, elapsed - self.slideIn)
	remaining = math.Clamp(remaining, 0, self.duration)

	
	local blinkOn = false
	if self.finished then
		blinkOn = math.floor((CurTime() - self.finishTime) * BLINK_RATE) % 2 == 0
	end

	local bgCol = blinkOn and COL_FLASH_BG or COL_BG
	local bgDarkCol = blinkOn and COL_FLASH_BG or COL_BG_DARK
	local borderCol = blinkOn and COL_DANGER or COL_BORDER

	-- shadow
	surface.SetDrawColor(COL_SHADOW)
	surface.DrawRect(-3, 4, w, h)

	-- background
	draw.RoundedBox(0, 0, 0, w, h, bgCol)
	draw.RoundedBoxEx(0, 0, h * 0.6, w, h * 0.4, bgDarkCol, false, false, true, true)

	-- shitty gradient
	DrawBottomGradient(w, h)

	-- frame
	surface.SetDrawColor(borderCol)
	surface.DrawOutlinedRect(0, 0, w, h, 2)

	-- ?????????
	local labelText = "TIMER"
	if self.paused then labelText = "PAUSED" end
	if self.finished then labelText = "TIME'S UP" end
	draw.SimpleText(labelText, "RemTimer_Label", 18, 14, COL_MUTED, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

	if self.cancelled then
		-- tu
		-- cacnel
		-- DUMBASS
		draw.SimpleText("CANCELLED", "RemTimer_Cancel", 18, 74, COL_DANGER, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
	else
		local revealProgress = elapsed / REVEAL_DURATION

		local isDanger = (not self.paused) and (not self.finished) and remaining <= DANGER_THRESHOLD and remaining > 0
		local digitColor = COL_TEXT
		local shakeX, shakeY = 0, 0

		if self.finished then
			digitColor = blinkOn and Color(255, 255, 255, 255) or COL_DANGER
		elseif isDanger then
			local urgency = 1 - (remaining / DANGER_THRESHOLD)
			digitColor = Color(
				Lerp(urgency, COL_TEXT.r, COL_DANGER.r),
				Lerp(urgency, COL_TEXT.g, COL_DANGER.g),
				Lerp(urgency, COL_TEXT.b, COL_DANGER.b),
				255
			)
			local shakeAmount = urgency * 4
			shakeX = math.Rand(-shakeAmount, shakeAmount)
			shakeY = math.Rand(-shakeAmount, shakeAmount)
		end

		local digitsText = RevealText(FormatTime(remaining), revealProgress)
		draw.SimpleText(digitsText, "RemTimer_Digits", 18 + shakeX, 56 + shakeY, digitColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

		-- причина таймера - тоже "расшифровывается" при старте
		if self.reason ~= "" then
			local reasonText = RevealText(self.reason, revealProgress)
			draw.SimpleText(reasonText, "RemTimer_Reason", 18, h - 44, COL_MUTED, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	if self.paused then
		surface.SetDrawColor(0, 0, 0, 150)
		surface.DrawRect(0, 0, w, h)

		local pulse = 0.5 + 0.5 * math.sin(CurTime() * 3)
		local iconAlpha = Lerp(pulse, 165, 255)
		local iconScale = Lerp(pulse, 0.92, 1.06)

		local barW, barH = 16 * iconScale, 68 * iconScale
		local gap = 13 * iconScale
		local cx, cy = w / 2, h / 2 + 6
		local barCol = Color(255, 255, 255, iconAlpha)

		draw.RoundedBox(3, cx - gap - barW, cy - barH / 2, barW, barH, barCol)
		draw.RoundedBox(3, cx + gap, cy - barH / 2, barW, barH, barCol)

		local ringSize = Lerp(pulse, 116, 130)
		surface.SetDrawColor(255, 255, 255, Lerp(pulse, 40, 90))
		surface.DrawOutlinedRect(cx - ringSize / 2, cy - ringSize / 2, ringSize, ringSize, 1)
	end

	return true
end

vgui.Register("RemTimerPanel", PANEL, "Panel")

local currentPanel

local function StartRemTimer(duration, reason, soundFile)
	if IsValid(currentPanel) then
		currentPanel:Remove()
	end

	currentPanel = vgui.Create("RemTimerPanel")
	currentPanel:SetupTimer(duration, reason, soundFile)
end


net.Receive("rem_timer_start", function()
	local duration = net.ReadFloat()
	local reason = net.ReadString()
	local soundFile = net.ReadString()
	if soundFile == "" then soundFile = nil end
	StartRemTimer(duration, reason, soundFile)
end)

net.Receive("rem_timer_pause", function()
	if IsValid(currentPanel) then
		currentPanel:Pause()
	end
end)

net.Receive("rem_timer_resume", function()
	if IsValid(currentPanel) then
		currentPanel:Resume()
	end
end)

net.Receive("rem_timer_off", function()
	if IsValid(currentPanel) then
		currentPanel:CancelTimer()
	end
end)
