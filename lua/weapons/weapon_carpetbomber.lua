if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("callbomber_carpet_begin")
	util.AddNetworkString("callbomber_carpet_ready")
	util.AddNetworkString("callbomber_carpet_confirm")
end

SWEP.Base = "weapon_callbomber"
SWEP.PrintName = "Carpet Bomber"
SWEP.Instructions = "Primary attack to mark an area, then aim and press primary attack again to set the bombing direction."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.CarpetWeapon = true
SWEP.CarpetRadioTime = 1.5
SWEP.CarpetAreaRadius = 700
SWEP.SecondWaveAngleMin = 15
SWEP.SecondWaveAngleMax = 20
SWEP.SecondWaveDelay = 0

if CLIENT then
local targetPos
local phase = 0
local radioEnd = 0
local whiteMaterial = Material("sprites/white")

net.Receive("callbomber_carpet_ready", function()
	local weapon = net.ReadEntity()
	if weapon ~= LocalPlayer():GetActiveWeapon() then return end

	targetPos = net.ReadVector()
	radioEnd = CurTime() + net.ReadFloat()
	phase = 1
	weapon.RadioActive = true

	timer.Simple(radioEnd - CurTime(), function()
		if IsValid(weapon) and weapon == LocalPlayer():GetActiveWeapon() and phase == 1 then
			phase = 2
			weapon.RadioActive = false
		end
	end)
end)

local function GetDirection(pos)
	local tr = LocalPlayer():GetEyeTrace()
	local direction = tr.HitPos - pos
	direction.z = 0

	if direction:LengthSqr() < 1 then
		direction = LocalPlayer():EyeAngles():Forward()
		direction.z = 0
	end

	if direction:LengthSqr() < 1 then return Vector(1, 0, 0) end
	return direction:GetNormalized()
end

hook.Add("PostDrawTranslucentRenderables", "callbomber_carpet_preview", function()
	local weapon = LocalPlayer():GetActiveWeapon()
	if phase == 0 or not IsValid(weapon) or not weapon.CarpetWeapon or not targetPos then return end

	render.SetMaterial(whiteMaterial)
	local previous = targetPos + Vector(0, 0, 8) + Vector(weapon.CarpetAreaRadius, 0, 0)
	for i = 1, 64 do
		local angle = math.pi * 2 * i / 64
		local point = targetPos + Vector(math.cos(angle) * weapon.CarpetAreaRadius, math.sin(angle) * weapon.CarpetAreaRadius, 8)
		render.DrawBeam(previous, point, 12, 0, 1, Color(80, 255, 100, 120))
		previous = point
	end

	if phase ~= 2 then return end

	local direction = GetDirection(targetPos)
	local arrowStart = targetPos + Vector(0, 0, 18)
	local arrowEnd = arrowStart + direction * weapon.CarpetAreaRadius
	render.DrawBeam(arrowStart, arrowEnd, 24, 0, 1, Color(80, 255, 100, 150))
	render.DrawBeam(arrowEnd, arrowEnd - direction * 140 + direction:Angle():Right() * 80, 24, 0, 1, Color(80, 255, 100, 150))
	render.DrawBeam(arrowEnd, arrowEnd - direction * 140 - direction:Angle():Right() * 80, 24, 0, 1, Color(80, 255, 100, 150))
end)

function SWEP:PrimaryAttack()
	if phase == 0 then
		local tr = LocalPlayer():GetEyeTrace()
		if not tr.Hit then return end

		self:SetNextPrimaryFire(CurTime() + self.CarpetRadioTime + 0.2)
		net.Start("callbomber_carpet_begin")
			net.WriteVector(tr.HitPos)
		net.SendToServer()
		return
	end

	if phase ~= 2 then return end

	self:SetNextPrimaryFire(CurTime() + 1)
	net.Start("callbomber_carpet_confirm")
		net.WriteVector(targetPos)
		net.WriteVector(GetDirection(targetPos))
	net.SendToServer()
	phase = 0
	targetPos = nil
	self.RadioActive = false
end

function SWEP:Holster()
	phase = 0
	targetPos = nil
	self.RadioActive = false
	return true
end
end

if SERVER then
local function IsFiniteVector(value)
	return value.x == value.x and value.y == value.y and value.z == value.z and value.x ~= math.huge and value.x ~= -math.huge and value.y ~= math.huge and value.y ~= -math.huge and value.z ~= math.huge and value.z ~= -math.huge
end

local function GetWeapon(ply)
	local weapon = ply:GetActiveWeapon()
	if not IsValid(weapon) or not weapon.CarpetWeapon then return end
	if not ply:IsAdmin() or not ply:Alive() then return end
	return weapon
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.2)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.2)
end

net.Receive("callbomber_carpet_begin", function(_, ply)
	local weapon = GetWeapon(ply)
	if not IsValid(weapon) or weapon._carpetBusy then return end

	local target = net.ReadVector()
	if not IsFiniteVector(target) then return end
	local trace = ply:GetEyeTrace()
	if not trace.Hit or trace.HitPos:DistToSqr(target) > 128 * 128 then return end

	weapon._carpetBusy = true
	weapon._carpetTarget = trace.HitPos
	weapon._carpetReadyTime = CurTime() + weapon.CarpetRadioTime
	weapon.RadioActive = true

	net.Start("callbomber_carpet_ready")
		net.WriteEntity(weapon)
		net.WriteVector(weapon._carpetTarget)
		net.WriteFloat(weapon.CarpetRadioTime)
	net.Send(ply)

	timer.Simple(weapon.CarpetRadioTime, function()
		if IsValid(weapon) then weapon.RadioActive = false end
	end)
	timer.Simple(weapon.CarpetRadioTime + 10, function()
		if IsValid(weapon) and weapon._carpetBusy then
			weapon._carpetBusy = nil
			weapon._carpetTarget = nil
			weapon._carpetReadyTime = nil
		end
	end)
end)

net.Receive("callbomber_carpet_confirm", function(_, ply)
	local weapon = GetWeapon(ply)
	if not IsValid(weapon) or not weapon._carpetBusy or not weapon._carpetTarget or CurTime() < weapon._carpetReadyTime then return end

	local target = net.ReadVector()
	local direction = net.ReadVector()
	if not IsFiniteVector(target) or not IsFiniteVector(direction) or target:DistToSqr(weapon._carpetTarget) > 1 then return end

	direction.z = 0
	if direction:LengthSqr() < 0.01 then return end

	local radioSound = weapon.RadioCallSound
	if radioSound then
		ply:EmitSound(radioSound, weapon.RadioCallSoundLevel or 80, 100)
	end

	weapon:CallBomber(weapon._carpetTarget, true, direction:GetNormalized())
	ply:DropWeapon(weapon)
	weapon._carpetBusy = nil
	weapon._carpetTarget = nil
	weapon._carpetReadyTime = nil
end)
end
