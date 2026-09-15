if !CLIENT then return end

local IsValid, CurTime = IsValid, CurTime

local tpik = CreateClientConVar("mh_tpik", "1", true, false,
	"Hide Z-City hands (TPIK) while a kill plays")

local fov = CreateClientConVar("mh_fov", "100", true, false,
	"FoV while your own execution plays (0 = leave it alone)")

local myfov

net.Receive("mh_close_sound", function()
	local snd = net.ReadString()
	local pitch = net.ReadUInt(8)

	surface.PlaySound(snd)
	if IsValid(LocalPlayer()) then
		LocalPlayer():EmitSound(snd, 85, pitch, 1, CHAN_AUTO)
	end
end)

hook.Add("CreateMove", "manhunt_kills_lock", function(cmd)
	local ply = LocalPlayer()
	if !IsValid(ply) or ply:GetNWFloat("MH_Kill", 0) < CurTime() then return end

	cmd:ClearButtons()
	cmd:ClearMovement()
end)

hook.Add("InitPostEntity", "manhunt_kills_tpik", function()
	if !istable(hg) or !isfunction(hg.ShouldTPIK) or hg.MH_TPIK then return end
	hg.MH_TPIK = hg.ShouldTPIK

	function hg.ShouldTPIK(ply)
		if tpik:GetBool() and IsValid(ply) and ply:GetNWFloat("MH_Kill", 0) > CurTime() then
			ply.cachedval = false
			ply.cachedtpik = CurTime() + 0.1
			ply.MH_WasOff = true
			return false
		end

		if ply.MH_WasOff then
			ply.MH_WasOff = nil
			ply.cachedtpik = 0
		end

		return hg.MH_TPIK(ply)
	end
end)

local function gripOf(wep)
	if !IsValid(wep) or !istable(MH) then return end
	local class = wep:GetClass()
	local own = MH.GripClass and MH.GripClass[class]

	local fams = (MH.ByWeapon and MH.ByWeapon[class]) or (MH.GuessFams and MH.GuessFams(class))
	local fam = fams and fams[1]

	if !fam then
		local only = MH.KillsFor and MH.KillsFor[class]
		fam = only and only[1] and string.match(only[1], "^(%a+)_")
	end

	return own or (fam and MH.Grip and MH.Grip[fam]), fam
end

function MH.HoldGrip(wep, g)
	wep.MH_Saved = wep.MH_Saved or
		{ wep.WorldPos, wep.WorldAng, wep.weaponPos, wep.weaponAng, wep.WorldModelExchange }
	wep.MH_Gripped = true

	if g.pos then wep.WorldPos, wep.WorldAng = g.pos, g.ang end
	if !g.pos2 then return end

	wep.weaponPos, wep.weaponAng = g.pos2, g.ang2

	if !wep.WorldModelExchange then wep.WorldModelExchange = wep.WorldModel end
end

local function back(was, i, def, name)
	local v = was and was[i]
	if v == nil then v = def and def[name] end
	return v
end

function MH.DropGrip(wep)
	local was, def = wep.MH_Saved, weapons.Get(wep:GetClass())
	wep.WorldPos = back(was, 1, def, "WorldPos")
	wep.WorldAng = back(was, 2, def, "WorldAng")
	wep.weaponPos = back(was, 3, def, "weaponPos")
	wep.weaponAng = back(was, 4, def, "weaponAng")
	wep.WorldModelExchange = back(was, 5, def, "WorldModelExchange")
	wep.MH_Saved, wep.MH_Gripped = nil, nil
end

hook.Add("Think", "manhunt_kills_fov", function()
	local ply = LocalPlayer()
	if !IsValid(ply) then return end

	local hg_fov = GetConVar("hg_fov")
	if !hg_fov or fov:GetInt() <= 0 then return end

	local on = ply:GetNWFloat("MH_Kill", 0) > CurTime()

	if on and !myfov then
		myfov = hg_fov:GetInt()
		RunConsoleCommand("hg_fov", math.Clamp(fov:GetInt(), 75, 130))
	elseif !on and myfov then
		RunConsoleCommand("hg_fov", myfov)
		myfov = nil
	end
end)

hook.Add("Think", "manhunt_kills_grip", function()
	for _, ply in ipairs(player.GetAll()) do
		local wep = ply:GetActiveWeapon()
		if !IsValid(wep) then continue end

		local on = ply:GetNWFloat("MH_Kill", 0) > CurTime()
		if on and !wep.MH_Gripped then
			local g = gripOf(wep)
			if g then MH.HoldGrip(wep, g) end
		elseif !on and wep.MH_Gripped then
			MH.DropGrip(wep)
		end
	end
end)
