local MODE = MODE
MODE.name = "juggernaut"

local juggernaut = nil
local surviveUntil = 0
local isJug = false

net.Receive("juggernaut_state", function()
	local ent = net.ReadEntity()
	surviveUntil = net.ReadFloat()
	juggernaut = ent
	isJug = IsValid(ent) and ent == LocalPlayer()
end)

hook.Add("RoundInfoCalled", "juggernaut_cleanup", function(nextMode)
	if nextMode == "juggernaut" then return end
	juggernaut = nil
	surviveUntil = 0
	isJug = false
end)

local function FormatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end

local colJug = Color(190, 20, 20)
local colHunt = Color(220, 220, 220)

function MODE:HUDPaint()
	local round = CurrentRound()
	if not round or round.name ~= "juggernaut" then return end
	if not IsValid(juggernaut) then return end

	local remaining = surviveUntil - CurTime()
	local w, h = ScrW(), ScrH()

	local title = isJug and "YOU ARE THE JUGGERNAUT" or ("Juggernaut: " .. juggernaut:Nick())
	draw.SimpleText(title, "ZB_InterfaceLarge", w * 0.5, h * 0.08, isJug and colJug or colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	draw.SimpleText("Survive: " .. FormatTime(remaining), "ZB_InterfaceMedium", w * 0.5, h * 0.08 + 32, Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	local barW, barH = 360, 18
	local barX, barY = w * 0.5 - barW * 0.5, h * 0.08 + 58
	local hp = math.max(0, juggernaut:Health())
	local maxHp = math.max(1, juggernaut:GetMaxHealth())
	local frac = math.Clamp(hp / maxHp, 0, 1)

	draw.RoundedBox(4, barX, barY, barW, barH, Color(30, 30, 30, 200))
	draw.RoundedBox(4, barX + 2, barY + 2, (barW - 4) * frac, barH - 4, isJug and Color(60, 200, 60) or colJug)
	surface.SetDrawColor(0, 0, 0, 120)
	surface.DrawOutlinedRect(barX, barY, barW, barH)

	draw.SimpleText(math.ceil(hp) .. " / " .. math.ceil(maxHp), "ZB_InterfaceMedium", w * 0.5, barY + barH * 0.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	if isJug then
		draw.SimpleText("Survive and don't let them bring you down!", "ZB_InterfaceMedium", w * 0.5, barY + barH + 24, colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		draw.SimpleText("Bring the Juggernaut down before the timer ends!", "ZB_InterfaceMedium", w * 0.5, barY + barH + 24, colHunt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end
