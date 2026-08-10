if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("ZCity_ActivatorUseTrap")
	util.AddNetworkString("ZCity_ActivatorConfirm")
	util.AddNetworkString("ZCity_ActivatorDenied")
	util.AddNetworkString("ZCity_ActivatorPoints")
	resource.AddSingleFile("resource/fonts/courierprime-regular.ttf")
end

CreateConVar("ttt_activator_start_points", "30", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Starting trap activator points")
CreateConVar("ttt_activator_points_per_kill", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Points awarded per kill")
CreateConVar("ttt_activator_max_points", "30", FCVAR_ARCHIVE + FCVAR_NOTIFY + FCVAR_REPLICATED, "Maximum points a player can have")
CreateConVar("ttt_activator_assistant_chance", "0.3", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Chance to give the activator to a traitor's assistant (0-1)", 0, 1)
CreateConVar("ttt_activator_default_cost", "5", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Default trap cost if the map does not set the Cost keyvalue")
CreateConVar("ttt_activator_traitoronly", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "1 = only traitors can activate traps", 0, 1)
CreateConVar("ttt_activator_hold_pos", "2.5 0 -3", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Phone model position in hands (x y z)")
CreateConVar("ttt_activator_hold_ang", "0 0 0", FCVAR_ARCHIVE + FCVAR_REPLICATED, "Phone model angle in hands (p y r)")
CreateConVar("ttt_activator_debug", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "1 = print activation failure reasons to the server console")

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Trap Activator"
SWEP.Author = "Judge"
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Instructions = "Aim at a trap and press LMB or E to activate it.\nPoints are spent to activate traps and are earned from kills."

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.UseHands = true
SWEP.HoldType = "normal"
SWEP.WorldModel = "models/cof/weapons/mobile/w_mobile.mdl"
SWEP.WorldModelReal = "models/cof/weapons/mobile/v_mobile.mdl"
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.WorkWithFake = true
SWEP.setlh = false
SWEP.setrh = true
SWEP.Slot = 4
SWEP.SlotPos = 1

SWEP.ActivatorUseRange = 1096
SWEP.HoldPos = Vector(4, 1, -2)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.weaponPos = Vector(0.25, 1, -6)
SWEP.weaponAng = Angle(0, -0, 0)

SWEP.AnimList = {
	deploy = { "idle_flash", 1.0, false, nil, function(self) self:PlayAnim("idle") end },
	idle = { "idle_flash", 2.0, true },
	use = { "flashtosms", 0.9, false, nil, function(self) self:ReverseAnimToIdle("use") end },
}

local TTTAct = {}

local ACTIVATOR_CLASS = "weapon_ttt_activator"

ZCityActivator = ZCityActivator or {}

function ZCityActivator.GetWep(ply)
	if not IsValid(ply) then return nil end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep:GetClass() == ACTIVATOR_CLASS then return wep end
end

function ZCityActivator.HasActivator(ply)
	if not IsValid(ply) then return false end
	for _, wep in pairs(ply:GetWeapons()) do
		if wep:GetClass() == ACTIVATOR_CLASS then return true end
	end
	return false
end

function ZCityActivator.StartPoints()
	return GetConVar("ttt_activator_start_points"):GetInt()
end

function ZCityActivator.MaxPoints()
	return GetConVar("ttt_activator_max_points"):GetInt()
end

function ZCityActivator.GetPoints(ply)
	return ply:GetNWInt("ttt_activator_points", ZCityActivator.StartPoints())
end

function ZCityActivator.SetPoints(ply, n)
	ply:SetNWInt("ttt_activator_points", math.max(0, n))
	ply:SetNWInt("ttt_activator_max_points", ZCityActivator.MaxPoints())
end

function ZCityActivator.TryUseTrap(ply, trap)
	if not IsValid(ply) or not ply:Alive() then return false, "denied" end
	if not IsValid(trap) or trap:GetClass() ~= "ttt_traitor_button" then return false, "denied" end
	local wep = ZCityActivator.GetWep(ply)
	if not IsValid(wep) then return false, "denied" end
	if GetConVar("ttt_activator_traitoronly"):GetBool() and not ply.isTraitor then return false, "traitoronly" end
	if not (trap.IsUsable and trap:IsUsable()) then return false, "unusable" end
	if ply:GetPos():Distance(trap:GetPos()) > (wep.ActivatorUseRange or 4096) then return false, "toofar" end

	local cost = tonumber(trap.GetCost and trap:GetCost() or 0) or 0
	if cost < 0 then cost = 0 end
	if cost > 0 and ZCityActivator.GetPoints(ply) < cost then return false, "nopoints" end

	local use, message = hook.Run("TTTCanUseTraitorButton", trap, ply)
	if use == false then return false, message or "denied" end

	if cost > 0 then
		ZCityActivator.SetPoints(ply, ZCityActivator.GetPoints(ply) - cost)
	end

	trap:TriggerOutput("OnPressed", ply)
	if trap.RemoveOnPress then
		trap:SetLocked(true)
		trap:Remove()
	else
		local delay = tonumber(trap.GetDelay and trap:GetDelay() or 1) or 1
		trap:SetNextUseTime(CurTime() + math.max(delay, 0))
	end

	hook.Run("TTTTraitorButtonActivated", trap, ply)
	return true
end

	if SERVER then
		local function LogResult(ply, ok, reason, extra)
			if not GetConVar("ttt_activator_debug"):GetBool() then return end
			Msg(string.format("[TTT Activator] %s -> %s %s\n", IsValid(ply) and ply:Nick() or "?", ok and "OK" or ("FAIL(" .. (reason or "denied") .. ")"), extra or ""))
		end

		net.Receive("ZCity_ActivatorUseTrap", function(_, ply)
			if not IsValid(ply) or not ply:Alive() then return end
			local trap = Entity(net.ReadUInt(16))
			local ok, reason = ZCityActivator.TryUseTrap(ply, trap)
			LogResult(ply, ok, reason)
			if ok then
				local wep = ZCityActivator.GetWep(ply)
				if IsValid(wep) and wep.PlayAnim then wep:PlayAnim("use") end
				net.Start("ZCity_ActivatorConfirm")
				net.Send(ply)
			else
				net.Start("ZCity_ActivatorDenied")
				net.WriteString(reason or "denied")
				net.Send(ply)
			end
		end)

		hook.Add("PostCleanupMap", "TTT_Activator_ResetPoints", function()
			local start = ZCityActivator.StartPoints()
			local max = ZCityActivator.MaxPoints()
			for _, ply in player.Iterator() do
				ply:SetNWInt("ttt_activator_points", start)
				ply:SetNWInt("ttt_activator_max_points", max)
			end
		end)

		hook.Add("Player_Death", "TTT_Activator_KillPoints", function(victim)
			timer.Simple(0.1, function()
				if not IsValid(victim) then return end
				local best, bestHarm = nil, 0
				for attacker, harm in pairs(zb.HarmDone[victim] or {}) do
					if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim and harm > bestHarm then
						best, bestHarm = attacker, harm
					end
				end
				if not IsValid(best) or not best:Alive() then return end
				if not ZCityActivator.HasActivator(best) then return end

				local per = GetConVar("ttt_activator_points_per_kill"):GetInt()
				local max = GetConVar("ttt_activator_max_points"):GetInt()
				if per <= 0 then return end
				local cur = ZCityActivator.GetPoints(best)
				if cur >= max then return end
				ZCityActivator.SetPoints(best, math.min(max, cur + per))

				net.Start("ZCity_ActivatorPoints")
				net.WriteInt(per, 16)
				net.Send(best)
			end)
		end)
	end

function SWEP:Deploy()
	if SERVER then
		local ply = self:GetOwner()
		if IsValid(ply) and ply:GetNWInt("ttt_activator_points") == nil then
			ply:SetNWInt("ttt_activator_points", ZCityActivator.StartPoints())
		end
	end

	if CLIENT then
		local pos = GetConVar("ttt_activator_hold_pos"):GetString()
		local px, py, pz = pos:match("([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)")
		if px then self.HoldPos = Vector(tonumber(px), tonumber(py), tonumber(pz)) end
		local ang = GetConVar("ttt_activator_hold_ang"):GetString()
		local pa, ya, ra = ang:match("([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)")
		if pa then self.HoldAng = Angle(tonumber(pa), tonumber(ya), tonumber(ra)) end

		TTTAct.CacheMarkers()
		TTTAct.markersNext = CurTime() + 1
		self._useHeld = false
		self._attackHeld = false
	end

	self:PlayAnim("deploy")
	self:SetHold(self.HoldType)
	return true
end

function SWEP:ThinkAdd()
	if SERVER then
		self:ThinkReverseAnimToIdle(CurTime())
	end
end

if CLIENT then
	function SWEP:Think()
		local ply = self:GetOwner()
		if not IsValid(ply) or ply ~= LocalPlayer() then return end

		self:SetHold(self.HoldType)
		self:ThinkReverseAnimToIdle(CurTime())

		if not TTTAct.OwnsActivator() then return end

		local useDown = ply:KeyDown(IN_USE)
		if useDown and not self._useHeld then TTTAct.TryUseFocused() end
		self._useHeld = useDown

		local atkDown = ply:KeyDown(IN_ATTACK)
		if atkDown and not self._attackHeld then TTTAct.TryUseFocused() end
		self._attackHeld = atkDown
	end
end

if CLIENT then
	local confirmSnd = Sound("buttons/button24.wav")
	local deniedSnd = Sound("buttons/button3.wav")

	surface.CreateFont("TTT_Act_Title", {
		font = "Courier Prime",
		size = 16,
		weight = 700,
		antialias = true,
	})
	surface.CreateFont("TTT_Act_Text", {
		font = "Courier Prime",
		size = 15,
		weight = 500,
		antialias = true,
	})
	surface.CreateFont("TTT_Act_Words", {
		font = "Courier Prime",
		size = 28,
		weight = 700,
		antialias = true,
	})
	surface.CreateFont("TTT_Act_Small", {
		font = "Courier Prime",
		size = 13,
		weight = 400,
		antialias = true,
	})

	local colBg = Color(15, 15, 15, 225)
	local colBorder = Color(255, 255, 255, 90)
	local colTitle = Color(255, 255, 255, 255)
	local colWords = Color(230, 230, 230, 255)
	local colDim = Color(150, 150, 150, 255)

	TTTAct.markers = {}
	TTTAct.markersNext = 0

	function TTTAct.CacheMarkers()
		TTTAct.markers = {}
		for _, ent in ipairs(ents.FindByClass("ttt_traitor_button")) do
			if IsValid(ent) then TTTAct.markers[#TTTAct.markers + 1] = ent end
		end
	end

	function TTTAct.OwnsActivator()
		local ply = LocalPlayer()
		return IsValid(ply) and ply:HasWeapon("weapon_ttt_activator")
	end

	local function ActiveActivator()
		local ply = LocalPlayer()
		if not IsValid(ply) then return nil end
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) and wep:GetClass() == "weapon_ttt_activator" then return wep end
	end

	local function GetPoints()
		local ply = LocalPlayer()
		return ply:GetNWInt("ttt_activator_points", 0)
	end

	local focusEnt, focusStick = nil, 0

	local function ClearFocus()
		focusEnt = nil
		focusStick = 0
	end

	local function TrapUsable(trap)
		return IsValid(trap) and (not trap.IsUsable or trap:IsUsable())
	end

	function TTTAct.TryUseFocused()
		local trap = focusEnt
		if not TrapUsable(trap) then return end
		local wep = ActiveActivator()
		if not IsValid(wep) then return end
		local ply = LocalPlayer()
		if ply:GetPos():Distance(trap:GetPos()) > (wep.ActivatorUseRange or 4096) then return end

		net.Start("ZCity_ActivatorUseTrap")
		net.WriteUInt(trap:EntIndex(), 16)
		net.SendToServer()
		ClearFocus()
	end

	local deniedMsg, deniedUntil = "", 0
	local gainedMsg, gainedUntil = "", 0

	local deniedText = {
		nopoints = "Not enough points",
		toofar = "Too far",
		unusable = "Trap unavailable",
		traitoronly = "Traitors only",
		denied = "Unavailable",
	}

	net.Receive("ZCity_ActivatorConfirm", function()
		surface.PlaySound(confirmSnd)
		TTTAct.CacheMarkers()
	end)

	net.Receive("ZCity_ActivatorDenied", function()
		local reason = net.ReadString()
		deniedMsg = deniedText[reason] or reason
		deniedUntil = CurTime() + 2.5
		surface.PlaySound(deniedSnd)
	end)

	net.Receive("ZCity_ActivatorPoints", function()
		gainedMsg = "+" .. net.ReadInt(16) .. " points"
		gainedUntil = CurTime() + 2
	end)

	local function DrawPointsPanel()
		local w, h = 150, 54
		local x = ScrW() - w - 20
		local y = ScrH() * 0.18

		local pts = GetPoints()

		draw.RoundedBox(2, x, y, w, h, colBg)
		surface.SetDrawColor(colBorder)
		surface.DrawOutlinedRect(x, y, w, h, 1)

		draw.SimpleText("POINTS", "TTT_Act_Small", x + w / 2, y + 13, colDim, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(tostring(pts), "TTT_Act_Words", x + w / 2, y + 33, colWords, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		local msgY = y + h + 8
		if gainedUntil >= CurTime() then
			draw.SimpleText(gainedMsg, "TTT_Act_Small", x + w, msgY, colWords, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			msgY = msgY + 18
		end
		if deniedUntil >= CurTime() then
			draw.SimpleText(deniedMsg, "TTT_Act_Small", x + w, msgY, colDim, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
	end

	local function DrawMarkers()
		local ply = LocalPlayer()
		local wep = ActiveActivator()
		if not IsValid(wep) then return end

		local useRange = wep.ActivatorUseRange or 4096
		local plypos = ply:GetPos()
		local mx, my = ScrW() / 2, ScrH() / 2
		local size, mid, focusRange = 24, 12, 70
		local pts = GetPoints()

		local focus = nil
		local fd = 0

		for _, but in ipairs(TTTAct.markers) do
			if not IsValid(but) then continue end

			local usable = TrapUsable(but)
			local spos = but:GetPos():ToScreen()
			if spos.x < -size or spos.y < -size or spos.x > ScrW() + size or spos.y > ScrH() + size then continue end

			local d = (but:GetPos() - plypos):LengthSqr() / (useRange * useRange)
			if d >= 1 then continue end

			local cost = but.GetCost and but:GetCost() or 0
			local sx, sy = math.abs(spos.x - mx), math.abs(spos.y - my)
			local isFocus = false

			if sx < focusRange and sy < focusRange and d > fd then
				focus = but
				fd = d
				isFocus = true
			end

			local alpha = math.floor(200 * (1 - d))

			if isFocus then
				draw.RoundedBox(2, spos.x - mid, spos.y - mid, size, size, Color(20, 20, 20, 235))
				surface.SetDrawColor(Color(255, 255, 255, 255))
				surface.DrawOutlinedRect(spos.x - mid, spos.y - mid, size, size, 2)
				draw.SimpleText("!", "TTT_Act_Text", spos.x, spos.y, colWords, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

				local label = (but.GetDescription and but:GetDescription() or "Trap") or "Trap"
				local costLine = cost > 0 and ("Cost: " .. cost .. " pts") or "Free"
				local stateTxt, stateCol
				if not usable then
					stateTxt, stateCol = "Recharging", colDim
				elseif cost > 0 and pts < cost then
					stateTxt, stateCol = "Not enough points", colWords
				else
					stateTxt, stateCol = "Press [E] or LMB", Color(210, 210, 210, 255)
				end

				local lines = { { label, colTitle }, { costLine, colDim }, { stateTxt, stateCol } }
				local lh, pad = 18, 6
				local boxW = 0
				surface.SetFont("TTT_Act_Text")
				for _, ln in ipairs(lines) do
					boxW = math.max(boxW, surface.GetTextSize(ln[1]))
				end
				boxW = boxW + pad * 2
				local boxH = #lines * lh + pad * 2
				local bx = spos.x + size + 8
				local by = spos.y - boxH / 2

				draw.RoundedBox(2, bx, by, boxW, boxH, Color(15, 15, 15, 240))
				surface.SetDrawColor(colBorder)
				surface.DrawOutlinedRect(bx, by, boxW, boxH, 1)

				local ty = by + pad
				for _, ln in ipairs(lines) do
					draw.SimpleText(ln[1], "TTT_Act_Text", bx + pad, ty, ln[2], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
					ty = ty + lh
				end
			else
				surface.SetDrawColor(Color(255, 255, 255, math.floor(alpha * 0.5)))
				surface.DrawOutlinedRect(spos.x - mid, spos.y - mid, size, size, 1)
				draw.SimpleText("!", "TTT_Act_Text", spos.x, spos.y, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end
		end

		if IsValid(focus) then
			focusEnt = focus
			focusStick = CurTime() + 0.2
		else
			ClearFocus()
		end
	end

	hook.Add("HUDPaint", "TTT_Activator_HUD", function()
		if not ActiveActivator() then return end

		if CurTime() >= TTTAct.markersNext then
			TTTAct.CacheMarkers()
			TTTAct.markersNext = CurTime() + 3
		end

		DrawPointsPanel()
		DrawMarkers()
	end, HOOK_HIGH)
end
