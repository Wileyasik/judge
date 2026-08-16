local MODE = MODE
MODE.name = "juggernaut"

local MODE_VARIANT = 0
local juggernauts = {}
local juggernaut = nil
local surviveUntil = 0
local isJug = false
local DataReady = false
local InJugg = false
local IntroStart = 0
local MusicPlayedFor = nil
local JUG_ScreenDuration = 3
local JUG_TeaserExitDur = 0.8
local JUG_RevealDuration = 2.5
local JUG_EndDuration = 5

local EndStart = 0
local EndJuggWon = false
local EndNames = ""
local EndDataReady = false

local sf_font = "Lora"

surface.CreateFont("ZB_JuggernautHeader", {
	font = sf_font,
	size = ScreenScale(45),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_JuggernautMediumLarge", {
	font = sf_font,
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("ZB_JuggernautMedium", {
	font = sf_font,
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

net.Receive("juggernaut_state", function()
	local variant = net.ReadInt(8)
	local survive = net.ReadFloat()
	local count = net.ReadUInt(4)

	local list = {}
	for i = 1, count do
		local ent = net.ReadEntity()
		if IsValid(ent) then list[#list + 1] = ent end
	end

	MODE_VARIANT = variant
	surviveUntil = survive
	juggernauts = list
	juggernaut = list[1]
	InJugg = true
	DataReady = true

	if IntroStart == 0 then
		IntroStart = CurTime()
	end

	isJug = false
	for _, ent in ipairs(list) do
		if ent == LocalPlayer() then
			isJug = true
			break
		end
	end
end)

net.Receive("juggernaut_variant", function()
	MODE_VARIANT = net.ReadInt(8)
end)

net.Receive("juggernaut_end", function()
	MODE_VARIANT = net.ReadInt(8)
	EndJuggWon = net.ReadBool()
	EndNames = net.ReadString()
	EndStart = CurTime()
	EndDataReady = true
end)

hook.Add("RoundInfoCalled", "juggernaut_cleanup", function(nextMode)
	if nextMode ~= "juggernaut" then
		MODE_VARIANT = 0
		juggernauts = {}
		juggernaut = nil
		surviveUntil = 0
		isJug = false
		DataReady = false
		InJugg = false
		IntroStart = 0
		EndStart = 0
		EndJuggWon = false
		EndNames = ""
		EndDataReady = false
		return
	end

	InJugg = true
end)

hook.Add("Think", "juggernaut_music", function()
	if not InJugg then return end

	local rs = zb.ROUND_START or 0
	if MusicPlayedFor == rs then return end

	local t = CurTime() - rs
	if t >= 0 and t <= 20 then
		MusicPlayedFor = rs
		surface.PlaySound("brawlstart.mp3")
	end
end)

local function FormatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function IntroFadeEnd()
	local revealEnd = JUG_ScreenDuration + JUG_TeaserExitDur + JUG_RevealDuration
	local roundStart = zb.ROUND_START or 0
	local roundBegin = (zb.ROUND_BEGIN or roundStart) - roundStart
	local holdEnd = math.max(revealEnd, roundBegin)
	return holdEnd
end

local colJug = Color(190, 20, 20)
local colHunt = Color(220, 220, 220)
local colWhite = Color(255, 255, 255)

local VARIANT_NAMES = {
	[1] = "Tagilla",
	[2] = "Tagilla & Killa",
	[3] = "Scream",
	[4] = "Jacket",
}

local function ease_out(x)
	return 1 - (1 - x) ^ 3
end

local function draw_text(text, fontname, x, y, r, g, b, a, ang, xalign, yalign)
	local m = Matrix()
	m:Translate(Vector(x, y, 0))
	m:Rotate(Angle(0, ang, 0))
	m:Translate(Vector(-x, -y, 0))

	cam.PushModelMatrix(m)
		draw.SimpleText(text, fontname, x, y, Color(r, g, b, a), xalign, yalign)
	cam.PopModelMatrix()
end

function MODE:RenderScreenspaceEffects()
	if not InJugg then return end
	local lply = LocalPlayer()
	if not IsValid(lply) then return end

	local t = CurTime() - (IntroStart > 0 and IntroStart or (zb.ROUND_START or 0))
	local fadeEnd = IntroFadeEnd()

	if t <= 0 or t > fadeEnd then return end

	local fade = math.Clamp((fadeEnd - t) / 1.5, 0, 1)
	if fade <= 0.01 then return end

	zb.RemoveFade()

	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

local function DrawIntro(t)
	local w, h = ScrW(), ScrH()

	local teaserEnd = JUG_ScreenDuration + JUG_TeaserExitDur
	local revealStart = teaserEnd
	local revealEnd = revealStart + JUG_RevealDuration
	local fadeEnd = IntroFadeEnd()

	local out_fade = math.Clamp((fadeEnd - t) / 1.5, 0, 1)

	local cox = Lerp(FrameTime() * 6, 0, (gui.MouseX() - w * 0.5) / (w * 0.5))
	local coy = Lerp(FrameTime() * 6, 0, (gui.MouseY() - h * 0.5) / (h * 0.5))
	local cursor_reach = ScreenScale(7)
	cox = math.Clamp(cox, -1, 1) * cursor_reach
	coy = math.Clamp(coy, -1, 1) * cursor_reach

	local variantName = VARIANT_NAMES[MODE_VARIANT] or ""

	local elements = {}
	local function add(text, fontname, col, x, y, dir, delay, plx, notilt, outAt, outDur, fromReveal)
		elements[#elements + 1] = {
			text = text,
			font = fontname,
			r = col.r, g = col.g, b = col.b,
			x = x, y = y,
			dir = dir, delay = delay, plx = plx or 1,
			notilt = notilt, outAt = outAt, outDur = outDur,
			fromReveal = fromReveal,
		}
	end

	add("JUGGERNAUT", "ZB_JuggernautHeader", colWhite, w * 0.5, h * 0.12, "left", 0, 0.9, false, JUG_ScreenDuration, JUG_TeaserExitDur)
	if variantName ~= "" then
		add(variantName, "ZB_JuggernautMediumLarge", colWhite, w * 0.5, h * 0.30, "right", 0.4, 1.1, false, JUG_ScreenDuration, JUG_TeaserExitDur)
	end
	add("Who will be the Juggernaut?", "ZB_JuggernautMediumLarge", colWhite, w * 0.5, h * 0.45, "right", 0.7, 1.1, false, JUG_ScreenDuration, JUG_TeaserExitDur)
	add("The round begins in a moment!", "ZB_JuggernautMedium", colWhite, w * 0.5, h * 0.87, "bottom", 1.3, 1.3, true, JUG_ScreenDuration, JUG_TeaserExitDur)

	if DataReady and t >= revealStart then
		local rollColor = isJug and colJug or colHunt
		local roleName = isJug and "YOU ARE THE JUGGERNAUT" or "YOU ARE A GRUNT"

		add(roleName, "ZB_JuggernautHeader", rollColor, w * 0.5, h * 0.5, "up", 0, 0.9, false, nil, nil, true)
		if variantName ~= "" then
			add(variantName, "ZB_JuggernautMediumLarge", colWhite, w * 0.5, h * 0.5 + ScreenScale(40), "up", 0.15, 1.1, false, nil, nil, true)
		end
		if not isJug then
			local names = {}
			for _, ent in ipairs(juggernauts) do
				if IsValid(ent) then names[#names + 1] = ent:Nick() end
			end
			local nameStr = #names > 0 and table.concat(names, ", ") or "?"
			add("Juggernaut: " .. nameStr, "ZB_JuggernautMedium", colWhite, w * 0.5, h * 0.5 + ScreenScale(64), "up", 0.3, 1.3, false, nil, nil, true)
		end
	end

	for i, el in ipairs(elements) do
		local appear
		if el.fromReveal then
			appear = ease_out(math.Clamp((t - revealStart - el.delay) / 0.6, 0, 1))
		else
			appear = ease_out(math.Clamp((t - el.delay) / 1.6, 0, 1))
		end

		local exit_fade = 1
		if el.outAt then
			exit_fade = ease_out(math.Clamp((el.outAt + el.outDur - t) / el.outDur, 0, 1))
		end

		local a = 255 * appear * exit_fade * out_fade

		if a > 1 then
			local slide = 1 - appear
			local exitSlide = el.outAt and (1 - exit_fade) or 0
			local x, y = el.x, el.y

			if el.dir == "left" then
				x = x - slide * ScreenScale(220)
			elseif el.dir == "right" then
				x = x + slide * ScreenScale(220)
			elseif el.dir == "bottom" or el.dir == "up" then
				y = y + slide * ScreenScale(120)
			end

			y = y - exitSlide * ScreenScale(90)

			x = x + cox * el.plx
			y = y + coy * el.plx

			local tilt = el.notilt and 0 or (((i * 3) % 2 == 0 and 3 or -3) * appear)

			draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end

local function DrawEndScreen(t)
	local w, h = ScrW(), ScrH()

	local fadeEnd = JUG_EndDuration
	local inFade = ease_out(math.Clamp(t / 0.6, 0, 1))
	local outFade = ease_out(math.Clamp((fadeEnd - t) / 1.5, 0, 1))
	local a = 255 * inFade * outFade

	local title = EndJuggWon and "JUGGERNAUT WINS" or "HUNTERS WIN"
	local titleCol = EndJuggWon and colJug or colHunt
	local variantName = VARIANT_NAMES[MODE_VARIANT] or ""

	draw_text(title, "ZB_JuggernautHeader", w * 0.5, h * 0.40, titleCol.r, titleCol.g, titleCol.b, a, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	if variantName ~= "" then
		draw_text(variantName, "ZB_JuggernautMediumLarge", w * 0.5, h * 0.40 + ScreenScale(45), colWhite.r, colWhite.g, colWhite.b, a, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	if EndNames ~= "" then
		draw_text(EndNames, "ZB_JuggernautMedium", w * 0.5, h * 0.40 + ScreenScale(70), colWhite.r, colWhite.g, colWhite.b, a, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function MODE:HUDPaint()
	local lply = LocalPlayer()
	if not IsValid(lply) then return end
	if lply:Team() == TEAM_SPECTATOR and not isJug then return end

	if not InJugg then return end

	local round = CurrentRound()
	if not round or round.name ~= "juggernaut" then return end

	local t = CurTime() - (IntroStart > 0 and IntroStart or (zb.ROUND_START or 0))
	local fadeEnd = IntroFadeEnd()

	if t > 0 and t <= fadeEnd then
		DrawIntro(t)
		return
	end

	if EndDataReady then
		local te = CurTime() - EndStart
		if te >= 0 and te <= JUG_EndDuration then
			DrawEndScreen(te)
			return
		end
	end

	if not IsValid(juggernaut) and #juggernauts == 0 then return end

	local remaining = surviveUntil - CurTime()
	local w, h = ScrW(), ScrH()

	local names = {}
	for _, ent in ipairs(juggernauts) do
		if IsValid(ent) then names[#names + 1] = ent:Nick() end
	end
	local nameStr = #names > 0 and table.concat(names, ", ") or "?"

	local timeColor = isJug and colJug or colHunt
	local roleStr = isJug and "JUGGERNAUT" or ("Juggernaut: " .. nameStr)

	draw.SimpleText(roleStr, "ZB_JuggernautMediumLarge", w * 0.5, h * 0.06, timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(FormatTime(remaining), "ZB_JuggernautMedium", w * 0.5, h * 0.06 + ScreenScale(18), timeColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function MODE:EndRound()
	surface.PlaySound("brawlwin.mp3")
end
