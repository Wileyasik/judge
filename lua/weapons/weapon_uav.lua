if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("rem_uav_mark_request")
	util.AddNetworkString("rem_uav_mark_data")
	util.AddNetworkString("rem_uav_sound")
end

SWEP.Base = "weapon_airstrike"
SWEP.PrintName = "UAV"
SWEP.Instructions = "Primary attack to mark an area. Every player inside will be marked over the head for 30 seconds."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.CarpetWeapon = false
SWEP.UAVWeapon = true
SWEP.UAVRadius = 700
SWEP.UAVMarkTime = 30

if CLIENT then
local marks = {}
local whiteMaterial = Material("sprites/white")

	SWEP.WepSelectIcon = Material("vgui/uav.png")
	SWEP.IconOverride = "vgui/uav.png"
	SWEP.BounceWeaponIcon = false

net.Receive("rem_uav_sound", function()
	surface.PlaySound("rem_uavabove.ogg")

	local dur = SoundDuration("rem_uavabove.ogg")
	timer.Simple(dur and dur > 0 and dur + 0.2 or 2, function()
		surface.PlaySound("rem_uavabove.ogg")
	end)
end)

net.Receive("rem_uav_mark_data", function()
	marks = {}

	local hasEnemies = net.ReadBool()
	local endTime = net.ReadFloat()
	local count = net.ReadUInt(6)

	for _ = 1, count do
		local ent = net.ReadEntity()
		local team = net.ReadUInt(8)

		if IsValid(ent) then
			marks[ent] = {endTime = endTime, team = team}
		end
	end

	if hasEnemies then
		surface.PlaySound("rem_uavfoundpeople.ogg")
	end
end)

local function GetMarkColor(teamID)
	if zb and zb.CROUND == "realish" then
		local team = RealishTeams and RealishTeams[teamID]
		if team and team.color then return team.color end
	end

	return Color(255, 40, 40)
end

hook.Add("PostDrawTranslucentRenderables", "rem_uav_marks", function(_, bSky)
	if bSky then return end

	local now = CurTime()
	local dirty = false

	for ent, mark in pairs(marks) do
		if now >= mark.endTime or not IsValid(ent) then
			marks[ent] = nil
			dirty = true
		end
	end

	if not next(marks) then
		if dirty then marks = {} end
		return
	end

	cam.IgnoreZ(true)
	render.SetColorMaterial()

	for ent, mark in pairs(marks) do
		if ent.Alive and not ent:Alive() then continue end

		local target = ent
		local rag = ent.FakeRagdoll or ent:GetNWEntity("FakeRagdoll")
		if IsValid(rag) then target = rag end

		local headPos
		local bone = target:LookupBone("ValveBiped.Bip01_Head1")

		if bone then
			local matrix = target:GetBoneMatrix(bone)
			if matrix then headPos = matrix:GetTranslation() end
		end

		headPos = headPos or target:GetPos() + Vector(0, 0, 72)
		local drawPos = headPos + Vector(0, 0, 16)
		local size = 7
		local dir = drawPos - EyePos()

		if dir:LengthSqr() < 1 then continue end

		local right = dir:Angle():Right() * size
		local up = Vector(0, 0, size)
		local color = GetMarkColor(mark.team)

		render.DrawQuad(drawPos + up, drawPos + right, drawPos - up, drawPos - right, color)
		render.DrawQuad(drawPos + up, drawPos - right, drawPos - up, drawPos + right, color)
	end

	cam.IgnoreZ(false)
end)

hook.Add("PostDrawTranslucentRenderables", "rem_uav_preview", function(_, bSky)
	if bSky then return end

	local ply = LocalPlayer()
	local weapon = ply:GetActiveWeapon()

	if not IsValid(weapon) or not weapon.UAVWeapon then return end

	local tr = ply:GetEyeTrace()
	if not tr.Hit then return end

	local radius = weapon.UAVRadius or 700
	render.SetMaterial(whiteMaterial)

	local previous = tr.HitPos + Vector(0, 0, 8) + Vector(radius, 0, 0)

	for i = 1, 64 do
		local angle = math.pi * 2 * i / 64
		local point = tr.HitPos + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 8)
		render.DrawBeam(previous, point, 10, 0, 1, Color(80, 180, 255, 90))
		previous = point
	end
end)

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() then return end

	local tr = LocalPlayer():GetEyeTrace()
	if not tr.Hit then return end

	self:SetNextPrimaryFire(CurTime() + 1)
	net.Start("rem_uav_mark_request")
		net.WriteVector(tr.HitPos)
	net.SendToServer()
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.5)
end

function SWEP:Holster()
	return true
end
end

if SERVER then
local function IsFiniteVector(value)
	return value.x == value.x and value.y == value.y and value.z == value.z and value.x ~= math.huge and value.x ~= -math.huge and value.y ~= math.huge and value.y ~= -math.huge and value.z ~= math.huge and value.z ~= -math.huge
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

local function IsRealishRound()
	local round = CurrentRound()
	return round and round.name == "realish"
end

net.Receive("rem_uav_mark_request", function(_, ply)
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) or not weapon.UAVWeapon then return end
	if not ply:Alive() or weapon._uavBusy then return end

	local target = net.ReadVector()
	if not IsFiniteVector(target) then return end

	local trace = ply:GetEyeTrace()
	if not trace.Hit or trace.HitPos:DistToSqr(target) > 128 * 128 then return end

	weapon._uavBusy = true
	weapon:SetNextPrimaryFire(CurTime() + 1)

	local isRealish = IsRealishRound()
	local callerTeam = ply:Team()
	local radius = math.Clamp(weapon.UAVRadius or 700, 50, 4000)
	local radiusSqr = radius * radius
	local marked = {}

	for _, other in player.Iterator() do
		if not IsValid(other) or not other:Alive() or other == ply then continue end

		local delta = other:GetPos() + Vector(0, 0, 16) - target
		if delta:DotProduct(delta) <= radiusSqr then
			marked[#marked + 1] = other
		end
	end

	local receivers = {}

	if isRealish and (callerTeam == 0 or callerTeam == 1) then
		for _, other in player.Iterator() do
			if other:IsBot() then continue end
			if other:Team() == callerTeam then receivers[#receivers + 1] = other end
		end
	end

	if #receivers == 0 then
		if not ply:IsBot() then receivers[1] = ply end
	end

	local hasEnemies = false

	for _, other in ipairs(marked) do
		if not isRealish or other:Team() ~= callerTeam then
			hasEnemies = true
			break
		end
	end

	local endTime = CurTime() + (weapon.UAVMarkTime or 30)

	for _, recv in ipairs(receivers) do
		net.Start("rem_uav_mark_data")
			net.WriteBool(hasEnemies)
			net.WriteFloat(endTime)
			net.WriteUInt(#marked, 6)

			for _, other in ipairs(marked) do
				net.WriteEntity(other)
				net.WriteUInt(other:Team(), 8)
			end
		net.Send(recv)
	end

	net.Start("rem_uav_sound")
	net.Broadcast()

	timer.Simple(1, function()
		if IsValid(weapon) then weapon._uavBusy = nil end
	end)

	ply:DropWeapon(weapon)
end)
end
