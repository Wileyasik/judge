if(SERVER)then
	AddCSLuaFile()
end

SWEP.Base = "weapon_base"
SWEP.PrintName = "Admin Bomber"
SWEP.Instructions = "Primary attack to mark a point and call a B2 bomber strike."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 8
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/sirgibs/ragdoll/css/terror_arctic_radio.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_walkietalkie")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_walkietalkie.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Slot = 5
SWEP.SlotPos = 5
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(6, 5.5, -41)
SWEP.offsetAng = Angle(180, 160, 180)

SWEP.BomberModel = "models/b2/b2.mdl"
SWEP.BombModel = "models/gbombs/250lbgp.mdl"
SWEP.BomberHeight = 4096
SWEP.MinBomberHeight = 900
SWEP.BomberSkyClearance = 350
SWEP.BomberDistance = 12000
SWEP.BomberSpeed = 1800
SWEP.BomberScale = 0.87
SWEP.BombDropHeight = 900
SWEP.BombScale = 1.35
SWEP.BlastDamage = 2500
SWEP.BlastRadius = 3500
SWEP.NukeBombClass = "rem_bomb_2000"
SWEP.CarpetBombClass = "rem_bomb_500"
SWEP.CarpetBombPairs = 8
SWEP.CarpetBombInterval = 0.5
SWEP.CarpetBombRowSpacing = 220
SWEP.BombDownVelocity = -1500
SWEP.BombBlockedVelocity = -2800
SWEP.AmbientSounds = {
	"jet/jet_far_001.wav",
	"jet/jet_far_002.wav"
}
SWEP.FlybySound = "jet/jet_flyby4.wav"

if SERVER then
	util.AddNetworkString("callbomber_b2_start")
	util.AddNetworkString("callbomber_b2_stop")
	util.AddNetworkString("callbomber_nuke_explode")
end

if CLIENT then
	local activeBombers = {}
	local nukeFlashEnd = 0

	net.Receive("callbomber_b2_start", function()
		local id = net.ReadUInt(16)
		local startPos = net.ReadVector()
		local endPos = net.ReadVector()
		local startTime = net.ReadFloat()
		local travelTime = net.ReadFloat()
		local ambientSound = net.ReadString()
		local snd = CreateSound(LocalPlayer(), ambientSound)

		if snd then
			snd:PlayEx(0, 100)
		end

		activeBombers[id] = {
			startPos = startPos,
			endPos = endPos,
			startTime = startTime,
			travelTime = travelTime,
			snd = snd,
			flyby = false
		}
	end)

	net.Receive("callbomber_b2_stop", function()
		local id = net.ReadUInt(16)

		if activeBombers[id] then
			activeBombers[id].stopTime = CurTime() + 3
		end
	end)

	net.Receive("callbomber_nuke_explode", function()
		nukeFlashEnd = CurTime() + 1
		surface.PlaySound("rem_nuke.ogg")
		surface.PlaySound("rem_blast.mp3")
	end)

	hook.Add("HUDPaint", "callbomber_nuke_flash", function()
		if nukeFlashEnd <= CurTime() then return end

		local alpha = math.Clamp((nukeFlashEnd - CurTime()) * 255, 0, 255)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end)

	hook.Add("Think", "callbomber_b2_sounds", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		for id, data in pairs(activeBombers) do
			local progress = math.Clamp((CurTime() - data.startTime) / data.travelTime, 0, 1)
			local remaining = math.max((data.startTime + data.travelTime) - CurTime(), 0)
			local volume = math.min((CurTime() - data.startTime) / 3, remaining / 3, 1)

			if data.stopTime then
				volume = math.min(volume, math.max((data.stopTime - CurTime()) / 3, 0))
			end

			if data.snd then
				data.snd:ChangeVolume(math.Clamp(volume, 0, 1), 0)
			end

			if not data.flyby and CurTime() >= data.startTime + data.travelTime * 0.5 - 2 then
				data.flyby = true
				ply:EmitSound("jet/jet_flyby4.mp3", 0, 65)
			end

			if progress >= 1 and volume <= 0 or data.stopTime and CurTime() >= data.stopTime then
				if data.snd then
					data.snd:Stop()
				end

				activeBombers[id] = nil
			end
		end
	end)
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
end

function SWEP:DrawWorldModel()
	if !self:GetOwner():IsPlayer() then
		self:DrawModel()
	end
end

function SWEP:DrawWorldModel2()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = hg.GetCurrentCharacter(self:GetOwner())

	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale or 1)

	if(IsValid(owner))then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")

		if(not boneid)then
			return
		end

		local matrix = owner:GetBoneMatrix(boneid)

		if(not matrix)then
			return
		end

		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
		WorldModel:DrawModel()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
		WorldModel:DrawModel()
	end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:BoneSet(lookup_name, vec, ang)
	local owner = self:GetOwner()
	if IsValid(owner) and !owner:IsPlayer() then return end
	hg.bone.Set(owner, lookup_name, vec, ang, "walkietalkie", 0.01)
end

local handAng1, handAng2 = Angle(-15, -10, 10), Angle(5, -65, -60)
local actAng1, actAng2 = Angle(0, -40, -18), Angle(-5, -5, -70)
function SWEP:Step()
	local owner = self:GetOwner()
	local active = owner:KeyDown(IN_ATTACK) or self.RadioActive

	if active then
		self:SetHold(self.HoldType)
	elseif self:GetHoldType() ~= "normal" then
		self:SetHold("normal")
	end

	if owner:OnGround() and owner:GetVelocity():LengthSqr() <= 1000 and not owner:IsTyping() and not owner:IsFlagSet(FL_ANIMDUCKING) then
		self:BoneSet("l_upperarm", vector_origin, handAng1)
		self:BoneSet("l_forearm", vector_origin, handAng2)
		self:BoneSet("r_upperarm", vector_origin, active and actAng1 or angle_zero)
		self:BoneSet("r_forearm", vector_origin, active and actAng2 or angle_zero)
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Wait)

	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsAdmin() then return end

	local tr = owner:GetEyeTrace()
	if not tr.Hit then return end

	self:CallBomber(tr.HitPos)
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Primary.Wait)

	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsAdmin() then return end

	local tr = owner:GetEyeTrace()
	if not tr.Hit then return end

	self:CallBomber(tr.HitPos, true)
end

function SWEP:Reload()
end

if SERVER then
	local function GetBomberHeight(ctx, targetPos)
		local tr = util.TraceLine({
			start = targetPos + Vector(0, 0, 64),
			endpos = targetPos + Vector(0, 0, ctx.bomberHeight + ctx.skyClearance),
			mask = MASK_SOLID_BRUSHONLY
		})

		if tr.Hit then
			return math.Clamp(tr.HitPos.z - targetPos.z - ctx.skyClearance, ctx.minHeight, ctx.bomberHeight)
		end

		return ctx.bomberHeight
	end

	local function BombKick(ctx)
		local kick = ctx.downVelocity or 0

		if kick > 0 then
			kick = -kick
		end

		return kick
	end

	local function BombBlockedKick(ctx)
		local kick = ctx.blockedVelocity or ctx.downVelocity or 0

		if kick > 0 then
			kick = -kick
		end

		return kick
	end

	local function CorridorBlocked(ctx, targetPos, direction, height)
		local gravity = physenv.GetGravity():Length()

		if gravity <= 0 then
			gravity = 600
		end

		local kick = BombKick(ctx)
		local fallTime = (kick + math.sqrt(kick * kick + 2 * gravity * math.max(height, 0))) / gravity
		local release = targetPos - direction * (ctx.bomberSpeed * fallTime) + Vector(0, 0, height)
		local vel = direction * ctx.bomberSpeed + Vector(0, 0, kick)
		local previous = release

		for i = 1, 2 do
			local t = fallTime * i / 3
			local pos = release + vel * t + Vector(0, 0, -0.5 * gravity * t * t)
			local tr = util.TraceLine({start = previous, endpos = pos, mask = MASK_SOLID_BRUSHONLY})

			if tr.Hit then
				return true
			end

			previous = pos
		end

		local tr = util.TraceLine({start = previous, endpos = targetPos + Vector(0, 0, 32), mask = MASK_SOLID_BRUSHONLY})
		return tr.Hit
	end

	local RunBomber

	function SWEP:CallBomber(targetPos, carpetBomb, chosenDirection, isSecondRun)
		if not isvector(targetPos) then return end

		local direction = isvector(chosenDirection) and Vector(chosenDirection) or VectorRand()
		direction.z = 0

		if direction:IsZero() then
			direction = Vector(1, 0, 0)
		end

		direction:Normalize()

		local waveMin = self.SecondWaveAngleMin or 15
		local waveMax = self.SecondWaveAngleMax or 20

		if waveMax < waveMin then waveMin, waveMax = waveMax, waveMin end

		local waveDelay = self.SecondWaveDelay or 0

		if waveDelay < 0 then waveDelay = 0 end

		RunBomber({
			owner = self:GetOwner(),
			carpet = carpetBomb,
			carpetWeapon = self.CarpetWeapon,
			bomberModel = self.BomberModel,
			bomberScale = self.BomberScale,
			bomberAngleOffset = self.BomberAngleOffset or angle_zero,
			bomberDistance = self.BomberDistance,
			bomberSpeed = self.BomberSpeed,
			bomberHeight = self.BomberHeight,
			minHeight = self.MinBomberHeight,
			skyClearance = self.BomberSkyClearance,
			downVelocity = self.BombDownVelocity,
			blockedVelocity = self.BombBlockedVelocity,
			carpetPairs = self.CarpetBombPairs,
			carpetInterval = self.CarpetBombInterval,
			carpetCount = self.CarpetBombCount,
			carpetClass = self.CarpetBombClass,
			nukeClass = self.NukeBombClass,
			rowSpacing = self.CarpetBombRowSpacing,
			ambientSounds = self.AmbientSounds,
			waveMin = waveMin,
			waveMax = waveMax,
			waveDelay = waveDelay
		}, Vector(targetPos), direction, isSecondRun)
	end

	local function NukeExplode(pos)
		net.Start("callbomber_nuke_explode")
		net.Broadcast()

		for i, ply in player.Iterator() do
			if IsValid(ply) and ply:Alive() then
				ply:Kill()
			end
		end
	end

	local function DropGredBomb(ctx, kick, dropPos, direction)
		local owner = ctx.owner
		local bomb = ents.Create(ctx.carpetClass)

		if not IsValid(bomb) then return end

		bomb.IsOnPlane = true
		bomb.GBOWNER = owner
		bomb.Owner = owner
		bomb:SetPos(dropPos)
		bomb:SetAngles(direction:Angle() + Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		if IsValid(owner) then
			bomb:SetPhysicsAttacker(owner)
		end

		local phys = bomb:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(direction * ctx.bomberSpeed + Vector(0, 0, kick))
		end

		if bomb.Arm then
			bomb:Arm()
		end
	end

	local function DropCarpetBombPair(ctx, kick, dropPos, direction)
		local right = direction:Angle():Right()

		if ctx.carpetCount == 1 then
			DropGredBomb(ctx, kick, dropPos, direction)
			return
		end

		if ctx.carpetCount == 3 then
			DropGredBomb(ctx, kick, dropPos - right * ctx.rowSpacing, direction)
			DropGredBomb(ctx, kick, dropPos, direction)
			DropGredBomb(ctx, kick, dropPos + right * ctx.rowSpacing, direction)
			return
		end

		DropGredBomb(ctx, kick, dropPos + right * ctx.rowSpacing * 0.5, direction)
		DropGredBomb(ctx, kick, dropPos - right * ctx.rowSpacing * 0.5, direction)
	end

	local function DropNukeBomb(ctx, kick, dropPos, direction)
		local owner = ctx.owner
		local bomb = ents.Create(ctx.nukeClass)

		if not IsValid(bomb) then return end

		bomb.IsOnPlane = true
		bomb.GBOWNER = owner
		bomb.Owner = owner
		bomb:SetPos(dropPos)
		bomb:SetAngles(direction:Angle() + Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		if IsValid(owner) then
			bomb:SetPhysicsAttacker(owner)
		end

		local phys = bomb:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
			phys:SetVelocity(direction * ctx.bomberSpeed + Vector(0, 0, kick))
		end

		local oldExplode = bomb.Explode

		bomb.Explode = function(ent, pos)
			if not ent.CallBomberNuked then
				ent.CallBomberNuked = true
				NukeExplode(pos or ent:GetPos())
			end

			if oldExplode then
				return oldExplode(ent, pos)
			end
		end

		if bomb.Arm then
			bomb:Arm()
		end
	end

	local function RotateDirection(ctx, direction)
		local offset = math.Rand(ctx.waveMin, ctx.waveMax)

		if math.random(0, 1) == 0 then offset = -offset end

		local rot = direction:Angle()
		rot:RotateAroundAxis(vector_up, offset)
		local newDir = rot:Forward()
		newDir.z = 0

		if newDir:LengthSqr() < 0.01 then return Vector(direction) end

		newDir:Normalize()
		return newDir
	end

	function RunBomber(ctx, targetPos, direction, isSecond)
		local bomberHeight = GetBomberHeight(ctx, targetPos)
		local startPos = targetPos - direction * ctx.bomberDistance + Vector(0, 0, bomberHeight)
		local endPos = targetPos + direction * ctx.bomberDistance + Vector(0, 0, bomberHeight)
		local bomber = ents.Create("prop_dynamic")

		if not IsValid(bomber) then return end

		bomber:SetModel(ctx.bomberModel)
		bomber:SetModelScale(ctx.bomberScale, 0)
		bomber:SetPos(startPos)
		bomber:SetAngles((-direction):Angle() + ctx.bomberAngleOffset)
		bomber:SetSolid(SOLID_NONE)
		bomber:SetMoveType(MOVETYPE_NOCLIP)
		bomber:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		bomber:Spawn()

		local dropped = false
		local carpetIndex = 0
		local travelDistance = startPos:Distance(endPos)
		local startTime = CurTime()
		local travelTime = travelDistance / ctx.bomberSpeed
		local gravity = physenv.GetGravity():Length()

		if gravity <= 0 then
			gravity = 600
		end

		local kick = BombKick(ctx)

		if CorridorBlocked(ctx, targetPos, direction, bomberHeight) then
			kick = BombBlockedKick(ctx)
		end

		local fallTime = (kick + math.sqrt(kick * kick + 2 * gravity * math.max(bomberHeight, 0))) / gravity
		local carpetStartTime = startTime + travelTime * 0.5 - fallTime - (ctx.carpetPairs - 1) * ctx.carpetInterval * 0.5
		local dropTime = startTime + travelTime * 0.5 - fallTime
		local timerName = "b2_bomber_" .. bomber:EntIndex()
		local ambientSound = ctx.ambientSounds[math.random(1, #ctx.ambientSounds)]

		net.Start("callbomber_b2_start")
			net.WriteUInt(bomber:EntIndex(), 16)
			net.WriteVector(startPos)
			net.WriteVector(endPos)
			net.WriteFloat(startTime)
			net.WriteFloat(travelTime)
			net.WriteString(ambientSound)
		net.Broadcast()

		bomber:CallOnRemove(timerName, function()
			timer.Remove(timerName)

			net.Start("callbomber_b2_stop")
				net.WriteUInt(bomber:EntIndex(), 16)
			net.Broadcast()
		end)

		timer.Create(timerName, 0, 0, function()
			if not IsValid(bomber) then timer.Remove(timerName) return end

			local progress = math.Clamp((CurTime() - startTime) / travelTime, 0, 1)
			local pos = LerpVector(progress, startPos, endPos)
			bomber:SetPos(pos)

			if ctx.carpet then
				while carpetIndex < ctx.carpetPairs and CurTime() >= carpetStartTime + carpetIndex * ctx.carpetInterval do
					DropCarpetBombPair(ctx, kick, pos, direction)
					carpetIndex = carpetIndex + 1
				end
			elseif not dropped and CurTime() >= dropTime then
				dropped = true
				DropNukeBomb(ctx, kick, pos, direction)
			end

			if progress >= 1 then
				local wantSecond = ctx.carpet and not isSecond and ctx.carpetWeapon
				local secondTarget = wantSecond and Vector(targetPos) or nil
				local newDir = wantSecond and RotateDirection(ctx, direction) or nil
				bomber:Remove()

				if wantSecond then
					timer.Simple(ctx.waveDelay, function()
						RunBomber(ctx, secondTarget, newDir, true)
					end)
				end
			end
		end)
	end

	function SWEP:DropBomb(targetPos, dropPos)
		local bomb = ents.Create("prop_physics")

		if not IsValid(bomb) then return end

		bomb:SetModel(self.BombModel)
		bomb:SetModelScale(self.BombScale, 0)
		bomb:SetPos(dropPos)
		bomb:SetAngles(Angle(90, 0, 0))
		bomb:Spawn()
		bomb:Activate()

		local phys = bomb:GetPhysicsObject()
		if IsValid(phys) then
			phys:Wake()
			phys:SetMass(500)
			phys:SetVelocity(Vector(0, 0, -1200))
		end

		local weapon = self
		bomb.PhysicsCollide = function(ent, data)
			if not IsValid(ent) or ent.Exploded then return end
			ent.Exploded = true
			weapon:LodgeBomb(ent, data)
			weapon:DetonateBomb(ent, data.HitPos or targetPos)
		end
	end

	function SWEP:LodgeBomb(bomb, data)
		local phys = bomb:GetPhysicsObject()
		local hitPos = data.HitPos or bomb:GetPos()
		local hitNormal = data.HitNormal or vector_up

		bomb:SetPos(hitPos - hitNormal * 18)
		bomb:SetMoveType(MOVETYPE_NONE)
		bomb:SetCollisionGroup(COLLISION_GROUP_WORLD)

		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end

	function SWEP:DetonateBomb(bomb, targetPos)
		local pos = IsValid(bomb) and bomb:GetPos() or targetPos
		if not isvector(pos) or not util.IsInWorld(pos) then return end
		local owner = IsValid(self:GetOwner()) and self:GetOwner() or self
		if rem_QueueExplosion then
			rem_QueueExplosion({Pos = Vector(pos), Radius = 1000, Damage = 300, Owner = owner, Ent = bomb, Profile = {Decal = "scorch_big", Trace = 400, Effect = "doi_stuka_explosion", EffectAir = "doi_stuka_explosion", Sound = "ied/ied_detonate_01.wav", FarSound = "ied/ied_detonate_dist_01.wav", WaterSound = "iedins/water/ied_water_detonate_01.wav", WaterFarSound = "iedins/water/ied_water_detonate_01.wav", Force = 50000, Lift = 20000}})
			return
		end
		util.BlastDamage(self, owner, pos, 1000, 300)
		util.ScreenShake(pos, 20, 150, 1.5, 2000)
	end
end
