local MODE = MODE
MODE.name = "juggernaut"

local MODE_VARIANT = 0
local juggernauts = {}
local juggernaut = nil
local surviveUntil = 0
local isJug = false
local StartTime = 0
local JUG_ScreenDuration = 9

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
	StartTime = CurTime()

	isJug = false
	for _, ent in ipairs(list) do
		if ent == LocalPlayer() then
			isJug = true
			break
		end
	end
end)

hook.Add("RoundInfoCalled", "juggernaut_cleanup", function(nextMode)
	if nextMode == "juggernaut" then return end
	MODE_VARIANT = 0
	juggernauts = {}
	juggernaut = nil
	surviveUntil = 0
	isJug = false
	StartTime = 0
end)

local function FormatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local colJug = Color(190, 20, 20)
local colHunt = Color(220, 220, 220)
local colWhite = Color(255, 255, 255)

local VARIANT_NAMES = {
	[1] = "Tagilla",
	[2] = "Tagilla & Killa",
	[3] = "Scream",
}

local OBJ_JUG = "Survive until the timer runs out. Don't let the hunters bring you down!"
local OBJ_HUNT = "Bring the Juggernaut down before the timer ends!"

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
	local t = CurTime() - StartTime
	if t <= 0 or t > JUG_ScreenDuration then return end

	zb.RemoveFade()

	local fade = math.min((JUG_ScreenDuration - t) / 2.5, 1)

	surface.SetDrawColor(0, 0, 0, 255 * fade)
	surface.DrawRect(-1, -1, ScrW() + 1, ScrH() + 1)
end

function MODE:HUDPaint()
	local lply = LocalPlayer()
	if not IsValid(lply) then return end
	if lply:Team() == TEAM_SPECTATOR and not isJug then return end

	local round = CurrentRound()
	if not round or round.name ~= "juggernaut" then return end

	local t = CurTime() - StartTime
	if t <= 0 then return end

	if t <= JUG_ScreenDuration then
		local w, h = ScrW(), ScrH()
		local sw, sh = ScrW(), ScrH()

		local out_fade = math.Clamp((JUG_ScreenDuration - t) / 1.5, 0, 1)

		local cox = Lerp(FrameTime() * 6, 0, (gui.MouseX() - sw * 0.5) / (sw * 0.5))
		local coy = Lerp(FrameTime() * 6, 0, (gui.MouseY() - sh * 0.5) / (sh * 0.5))
		local cursor_reach = ScreenScale(7)
		cox = math.Clamp(cox, -1, 1) * cursor_reach
		coy = math.Clamp(coy, -1, 1) * cursor_reach

		local variantName = VARIANT_NAMES[MODE_VARIANT] or ""
		local rollColor = isJug and colJug or colHunt
		local roleName = isJug and "You are the Juggernaut" or "You are a Grunt"
		local objective = isJug and OBJ_JUG or OBJ_HUNT

		local elements = {}
		local function add(text, fontname, col, x, y, dir, delay, plx, notilt)
			elements[#elements + 1] = {
				text = text,
				font = fontname,
				r = col.r, g = col.g, b = col.b,
				x = x, y = y,
				dir = dir, delay = delay, plx = plx or 1,
				notilt = notilt,
			}
		end

		add("JUGGERNAUT", "ZB_JuggernautHeader", colWhite, w * 0.5, h * 0.12, "left", 0, 0.9)
		if variantName ~= "" then
			add(variantName, "ZB_JuggernautMediumLarge", rollColor, w * 0.5, h * 0.30, "right", 0.4, 1.1)
		end
		add(roleName, "ZB_JuggernautMediumLarge", rollColor, w * 0.5, h * 0.45, "right", 0.7, 1.1)

		local nameStr = "?"
		local names = {}
		for _, ent in ipairs(juggernauts) do
			if IsValid(ent) then names[#names + 1] = ent:Nick() end
		end
		if #names > 0 then nameStr = table.concat(names, ", ") end

		if not isJug then
			add("Juggernaut: " .. nameStr, "ZB_JuggernautMedium", colWhite, w * 0.5, h * 0.45 + ScreenScale(22), "right", 0.95, 1.05)
		end

		add(objective, "ZB_JuggernautMedium", colWhite, w * 0.5, h * 0.87, "bottom", 1.3, 1.3, true)

		for i, el in ipairs(elements) do
			local appear = ease_out(math.Clamp((t - el.delay) / 1.6, 0, 1))
			local a = 255 * appear * out_fade

			if a > 1 then
				local slide = 1 - appear
				local x, y = el.x, el.y

				if el.dir == "left" then
					x = x - slide * ScreenScale(220)
				elseif el.dir == "right" then
					x = x + slide * ScreenScale(220)
				elseif el.dir == "bottom" then
					y = y + slide * ScreenScale(120)
				end

				x = x + cox * el.plx
				y = y + coy * el.plx

				local tilt = el.notilt and 0 or (((i * 3) % 2 == 0 and 3 or -3) * appear)

				draw_text(el.text, el.font, x, y, el.r, el.g, el.b, a, tilt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		return
	end

	if not IsValid(juggernaut) and #juggernauts == 0 then return end

	local remaining = surviveUntil - CurTime()
	local w, h = ScrW(), ScrH()

	local names = {}
	for _, ent in ipairs(juggernauts) do
		if IsValid(ent) then names[#names + 1] = ent:Nick() end
	end
	local nameStr = #names > 0 and table.concat(names, ", ") or "?"

	local title = isJug and "YOU ARE THE JUGGERNAUT" or ("Juggernaut: " .. nameStr)
	draw.SimpleText(title, "ZB_InterfaceLarge", w * 0.5, h * 0.08, isJug and colJug or colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local variantName = VARIANT_NAMES[MODE_VARIANT] or ""
	if variantName ~= "" then
		draw.SimpleText(variantName, "ZB_InterfaceSmall", w * 0.5, h * 0.08 + 18, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	draw.SimpleText("Survive: " .. FormatTime(remaining), "ZB_InterfaceMedium", w * 0.5, h * 0.08 + 32, Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if isJug then
		draw.SimpleText("Survive and don't let them bring you down!", "ZB_InterfaceMedium", w * 0.5, h * 0.08 + 60, colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Bring the Juggernaut down before the timer ends!", "ZB_InterfaceMedium", w * 0.5, h * 0.08 + 60, colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end