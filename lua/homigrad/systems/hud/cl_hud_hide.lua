local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudDamageIndicator"] = true,
	["CHudGeiger"] = true,
	["CHudSquadStatus"] = true,
	["CHudTrain"] = true,
	["CHudZoom"] = true,
	["CHudSuitPower"] = true,
	["CHUDQuickInfo"] = true,
	["CHudHistoryResource"] = true,
}

local gordon_hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = true,
	["CHudSuitPower"] = true,
}

hook.Add("HUDShouldDraw", "homigrad", function(name)
	if hide[name] then return false end
	if lply and lply.PlayerClassName == "Gordon" and gordon_hide[name] then
		return false
	end
end)

hook.Add("HUDDrawTargetID", "homigrad", function()
	return false
end)

hook.Add("DrawDeathNotice", "homigrad", function()
	return false
end)

hook.Add("HUDWeaponPickedUp", "HidePickedStuff", function(wep)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end
	return false
end)

hook.Add("HUDAmmoPickedUp", "HidePickedStuff", function(ammoname, amt)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end
	return false
end)

hook.Add("HUDItemPickedUp", "HidePickedStuff", function(itemname)
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end
	return false
end)

hook.Add("HUDDrawPickupHistory", "HidePickedStuff", function()
	if IsValid(lply) and lply.PlayerClassName and lply.PlayerClassName == "Gordon" then
		return
	end
	return false
end)

hook.Add("HUDPaint", "homigrad-dev", function()
	if engine.ActiveGamemode() ~= "sandbox" then return end
	w, h = ScrW(), ScrH()
end)

hook.Add("HUDPaint", "Identifier", function()
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	if lply:GetNetVar("disappearance", nil) then return end

	local trace = hg.eyeTrace(lply)

	if not trace then return end

	local Size = math.max(math.min(1 - trace.Fraction, 1), 0.1)
	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y

	if trace.Hit and (trace.Entity:IsRagdoll() or trace.Entity:IsPlayer()) then
		if trace.Entity.PlayerClassName == "sc_infiltrator" then return end
		if trace.Entity:GetNetVar("disappearance", nil) then return end

		draw.NoTexture()

		local pcol = trace.Entity.GetPlayerColor and trace.Entity:GetPlayerColor()
		local col = pcol and pcol:ToColor() or Color(255, 255, 255)
		col.a = 255 * Size * 1.5

		local coloutline = (col.r < 50 and col.g < 50 and col.b < 50) and Color(100, 100, 100) or Color(0, 0, 0)
		coloutline.a = 255 * Size * 1

		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x + 1, y + 31, coloutline, TEXT_ALIGN_CENTER)
		draw.DrawText(trace.Entity:GetPlayerName() or "", "HomigradFontLarge", x, y + 30, col, TEXT_ALIGN_CENTER)
	end
end)

if game.SinglePlayer() then
	hook.Add("HUDPaint", "Exit the singleplayer", function()
		draw.SimpleText("Z-City is not meant to be played in singleplayer, in map selection menu change SINGLEPLAYER (green button top right corner) to 2 players or any.", "HomigradFontMedium", ScrW() / 2, ScrH() / 2, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("A lot of stuff won't work and we won't provide any fixes to singleplayer EVER", "HomigradFontMedium", ScrW() / 2, ScrH() * 7 / 12, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end
