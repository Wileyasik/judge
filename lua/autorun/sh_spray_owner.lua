if SERVER then AddCSLuaFile() end

CreateConVar("hg_spray_owner_debug", "0", FCVAR_REPLICATED)

local netName = "hg_spray_owner"

if SERVER then
	util.AddNetworkString(netName)

	hook.Add("PlayerSpray", "hg_spray_owner", function(ply)
		local trace = util.GetPlayerTrace(ply, ply:EyeAngles():Forward())
		trace.mask = MASK_SOLID_BRUSHONLY
		trace = util.TraceLine(trace)
		if not trace.Hit then
			if GetConVar("hg_spray_owner_debug"):GetBool() then
				MsgC(Color(88, 101, 242), "[spray] " .. ply:Nick() .. " sprayed, but trace missed\n")
			end
			return
		end

		if GetConVar("hg_spray_owner_debug"):GetBool() then
			MsgC(Color(88, 101, 242), "[spray] " .. ply:Nick() .. " sprayed at " .. tostring(trace.HitPos) .. "\n")
		end

		net.Start(netName)
		net.WriteString(ply:SteamID())
		net.WriteString(ply:Nick())
		net.WriteVector(trace.HitPos)
		net.WriteVector(trace.HitNormal)
		net.Broadcast()
	end)
	return
end

local sprays = {}
local altWasDown = false
local copiedSteamID
local copiedUntil = 0
local lastHoverSteamID

surface.CreateFont("hg_spray_owner", {
	font = "Lora",
	size = ScreenScale(7),
	weight = 200,
	antialias = true
})

surface.CreateFont("hg_spray_action", {
	font = "Lora",
	size = ScreenScale(6.5),
	weight = 200,
	antialias = true
})

net.Receive(netName, function()
	local steamID = net.ReadString()
	local name = net.ReadString()
	local position = net.ReadVector()
	local normal = net.ReadVector()
	local angle = normal:Angle()
	position = position + angle:Up() * 4
	local radius = 32

	sprays[#sprays + 1] = {
		steamID = steamID,
		name = name,
		position = position,
		normal = normal,
		min = position - (angle:Right() + angle:Up()) * radius,
		max = position + (angle:Right() + angle:Up()) * radius
	}

	if GetConVar("hg_spray_owner_debug"):GetBool() then
		MsgC(Color(88, 101, 242), "[spray] tracked " .. name .. " (" .. steamID .. ")\n")
	end
end)

local function WithinBox(position, min, max)
	return position.x >= math.min(min.x, max.x) and position.x <= math.max(min.x, max.x)
		and position.y >= math.min(min.y, max.y) and position.y <= math.max(min.y, max.y)
		and position.z >= math.min(min.z, max.z) and position.z <= math.max(min.z, max.z)
end

local function GetLookedAtSpray()
	local sprayOwnerRange = 180
	local trace = LocalPlayer():GetEyeTraceNoCursor()
	local rangeSqr = sprayOwnerRange * sprayOwnerRange
	local closest, closestDistance
	for _, spray in ipairs(sprays) do
		if trace.HitPos:DistToSqr(trace.StartPos) <= rangeSqr and spray.normal:Dot(trace.HitNormal) > 0.99 and WithinBox(trace.HitPos, spray.min, spray.max) then
			local distance = trace.HitPos:DistToSqr(spray.position)
			if not closestDistance or distance < closestDistance then
				closest = spray
				closestDistance = distance
			end
		end
	end
	return closest
end

local function DrawOutlinedText(text, font, x, y, color)
	surface.SetFont(font)
	local curX = x
	for i = 1, #text do
		local ch = text:sub(i, i)
		local w = surface.GetTextSize(ch)
		surface.SetTextColor(0, 0, 0, color.a)
		for _, offset in ipairs({
			{ -1, -1 }, { 0, -1 }, { 1, -1 },
			{ -1, 0 }, { 1, 0 },
			{ -1, 1 }, { 0, 1 }, { 1, 1 },
			{ 0, -2 }, { -2, 0 }, { 2, 0 }, { 0, 2 },
		}) do
			surface.SetTextPos(curX + offset[1], y + offset[2])
			surface.DrawText(ch)
		end
		surface.SetTextColor(color)
		surface.SetTextPos(curX, y)
		surface.DrawText(ch)
		curX = curX + w + 1
	end
end

hook.Add("InitPostEntity", "hg_spray_owner_replace_spraymon_hud", function()
	hook.Remove("HUDPaint", "spraymon")
end)

hook.Add("HUDPaint", "hg_spray_owner", function()
	local spray = GetLookedAtSpray()
	local hoveredSteamID = spray and spray.steamID
	if hoveredSteamID ~= lastHoverSteamID then
		lastHoverSteamID = hoveredSteamID
		if GetConVar("hg_spray_owner_debug"):GetBool() and spray then
			MsgC(Color(88, 101, 242), "[spray] hovering " .. spray.name .. " (" .. spray.steamID .. ")\n")
		end
	end

	local altDown = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)
	if spray and altDown and not altWasDown then
		SetClipboardText(spray.steamID)
		sound.Play("ui/hint.wav", LocalPlayer():GetPos(), 75, 100, 0.5)
		copiedSteamID = spray.steamID
		copiedUntil = CurTime() + 1.5
	end
	altWasDown = altDown
	if not spray then return end

	local title = "SPRAYED BY " .. string.upper(spray.name)
	local copied = copiedSteamID == spray.steamID and CurTime() < copiedUntil
	local action = copied and ("COPIED " .. spray.steamID) or "ALT: COPY STEAMID"

	local x = ScreenScale(3)
	local y = ScrH() * 0.5 - ScreenScale(8)

	DrawOutlinedText(title, "hg_spray_owner", x, y, Color(235, 235, 235, 185))
	DrawOutlinedText(action, "hg_spray_action", x, y + ScreenScale(12), copied and Color(255, 255, 255, 210) or Color(225, 225, 225, 200))
end)
