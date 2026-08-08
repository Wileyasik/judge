if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "C4"
SWEP.Instructions = "LMB - throw C4 / detonate placed C4. RMB - plant C4 on a nearby surface."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 4
SWEP.SlotPos = 2

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/weapon_insurgencyc4clicker.png")
	SWEP.IconOverride = "entities/weapon_insurgencyc4clicker.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/insurgency/w_c4.mdl"
SWEP.WorldModelReal = "models/weapons/insurgency/v_c4_sec.mdl"
SWEP.WorldModelExchange = false
SWEP.WorkWithFake = true
SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldPos = Vector(2, 0.2, -1.5)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.PlantDistance = 100
SWEP.PlantTime = 1.5 * 0.85
SWEP.PlantAnglePitch = 90
SWEP.PlantAngleYaw = 90
SWEP.PlantAngleRoll = 0
SWEP.ThrowForce = 550
SWEP.BlastRadius = 650
SWEP.BlastDamage = 450
SWEP.DoorBlastRange = 2.5

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "ChargePlaced")
	self:NetworkVar("Bool", 1, "Busy")
end

SWEP.AnimList = {
	["base_idle"] = {"base_idle", 1, true},
	["base_throw"] = {"base_throw", 1, false, false, function(self)
		if SERVER then
			self:FinishC4Throw()
			self:SetBusy(false)
		end
		self:PlayAnim("det_draw")
	end},
	["base_plant"] = {"base_plant", 1.5, false, false, function(self)
		if SERVER then
			self:FinishC4Plant()
			self:SetBusy(false)
		end
		self:PlayAnim("det_draw")
	end},
	["det_draw"] = {"det_draw", 1, false, false, function(self)
		self:PlayAnim("det_idle")
	end},
	["det_idle"] = {"det_idle", 1, true},
	["det_detonate"] = {"det_detonate", 1, false, false, function(self)
		if SERVER then self:DetonateC4() end
	end}
}

SWEP.AnimsEvents = {
	["base_throw"] = {
		[0.35] = function(self)
			self:EmitSound("c4_throw", 65)
		end
	},
	["base_plant"] = {
		[0.05] = function(self)
			self:EmitSound("weapons/c4/handling/c4_plant_armmovement.wav", 65)
		end,
		[0.85] = function(self)
			self:EmitSound("weapons/c4/handling/c4_plant_place.wav", 65)
		end
	}
}

if CLIENT then
	local hiddenBoneScale = Vector(0.0001, 0.0001, 0.0001)
	local visibleBoneScale = Vector(1, 1, 1)
	local detonatorBones = {
		"SEC_DET",
		"SEC_DET_Cap01",
		"SEC_DET_Cap02",
		"SEC_DET_Cap03",
		"SEC_DET_ARM",
		"SEC_DET_SAFE"
	}
	local detonatorAnimations = {
		det_draw = true,
		det_idle = true,
		det_detonate = true
	}

	function SWEP:SetHandPos()
		local ply = self:GetOwner()
		local model = self:GetWM()
		if not IsValid(ply) or not IsValid(model) then return end
		if not ply.shouldTransmit or ply.NotSeen then return end

		local ent = hg.GetCurrentCharacter(ply)
		if not IsValid(ent) then return end

		local holdingDetonator = detonatorAnimations[self.anim] or false
		self.rhandik = self.setrh
		self.lhandik = self.setlh and not holdingDetonator
		local canUseRight = self.rhandik and hg.CanUseRightHand(ply)
		local canUseLeft = self.lhandik and hg.CanUseLeftHand(ply)
		local rightBones = hg.TPIKBonesRHDict
		local leftBones = hg.TPIKBonesLHDict
		local throwReleased = self.anim == "base_throw" and CurTime() >= self.animtime - self.animspeed * 0.85
		local chargeBone = model:LookupBone("SECEXP")
		if chargeBone then
			model:ManipulateBoneScale(chargeBone, (holdingDetonator or throwReleased) and hiddenBoneScale or visibleBoneScale)
		end

		local detonatorScale = holdingDetonator and visibleBoneScale or hiddenBoneScale
		for _, boneName in ipairs(detonatorBones) do
			local bone = model:LookupBone(boneName)
			if bone then model:ManipulateBoneScale(bone, detonatorScale) end
		end

		for modelBone = 0, model:GetBoneCount() - 1 do
			local modelBoneName = model:GetBoneName(modelBone)
			local playerBoneName = rightBones[modelBoneName] or leftBones[modelBoneName]
			if not playerBoneName then continue end
			if rightBones[modelBoneName] and not canUseRight then continue end
			if leftBones[modelBoneName] and not canUseLeft then continue end

			local modelMatrix = model:GetBoneMatrix(modelBone)
			local playerBone = ent:LookupBone(playerBoneName)
			if not modelMatrix or not playerBone then continue end

			pcall(function()
				ent:SetBoneMatrix(playerBone, modelMatrix)
			end)
		end
	end
end

function SWEP:InitAdd()
	if SERVER then
		self:SetChargePlaced(false)
		self:SetBusy(false)
	end
	self:PlayAnim("base_idle")
end

function SWEP:Deploy()
	self:SetHold(self.HoldType)
	self:PlayAnim(self:GetChargePlaced() and "det_draw" or "base_idle")
	return true
end

function SWEP:GetClosePlantTrace()
	return hg.eyeTrace(self:GetOwner(), self.PlantDistance)
end

function SWEP:BeginC4Action(animation, tr)
	if self:GetBusy() or self:GetChargePlaced() then return end

	self.PendingPlantTrace = tr
	self:SetBusy(true)
	self:PlayAnim(animation)

	if SERVER and animation == "base_throw" then
		timer.Simple(0.35, function()
			if IsValid(self) then self:FinishC4Throw(true) end
		end)
	elseif SERVER and animation == "base_plant" then
		timer.Simple(self.PlantTime, function()
			if IsValid(self) and self.anim == "base_plant" then self:FinishC4Plant(true) end
		end)
	end
end

function SWEP:CreateC4Charge(pos, ang)
	local charge = ents.Create("prop_physics")
	if not IsValid(charge) then return end

	charge:SetModel(self.WorldModel)
	charge:SetPos(pos)
	charge:SetAngles(ang)
	charge:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	charge:Spawn()
	charge:Activate()
	charge:SetOwner(self:GetOwner())
	return charge
end

function SWEP:FinishC4Throw(keepBusy)
	if not self:GetBusy() or self:GetChargePlaced() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local ang = owner:EyeAngles()
	local charge = self:CreateC4Charge(owner:EyePos() + ang:Forward() * 12 + ang:Right() * 4 - ang:Up() * 4, ang)
	if not IsValid(charge) then self:SetBusy(false) return end

	local phys = charge:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(owner:GetVelocity() + ang:Forward() * self.ThrowForce + ang:Up() * 80)
		phys:AddAngleVelocity(VectorRand() * 150)
	end

	self.C4Charge = charge
	self:SetChargePlaced(true)
	if not keepBusy then self:SetBusy(false) end
end

function SWEP:FinishC4Plant(keepBusy)
	if not self:GetBusy() or self:GetChargePlaced() then return end

	local tr = self.PendingPlantTrace
	self.PendingPlantTrace = nil
	if not tr or not tr.Hit or tr.HitPos:DistToSqr(self:GetOwner():EyePos()) > self.PlantDistance ^ 2 then
		self:SetBusy(false)
		self:PlayAnim("base_idle")
		return
	end

	local ang = tr.HitNormal:Angle()
	local surfaceForward = ang:Forward()
	local surfaceRight = ang:Right()
	local surfaceUp = ang:Up()
	ang:RotateAroundAxis(surfaceRight, self.PlantAnglePitch)
	ang:RotateAroundAxis(surfaceUp, self.PlantAngleYaw)
	ang:RotateAroundAxis(surfaceForward, self.PlantAngleRoll)
	local charge = self:CreateC4Charge(tr.HitPos + tr.HitNormal * 1.5, ang)
	if not IsValid(charge) then self:SetBusy(false) return end

	local hitEntity = tr.Entity
	if IsValid(hitEntity) and not hitEntity:IsWorld() then
		charge:SetParent(hitEntity)
		charge:SetMoveType(MOVETYPE_NONE)
	else
		local phys = charge:GetPhysicsObject()
		if IsValid(phys) then phys:EnableMotion(false) end
	end

	self.C4Charge = charge
	self:SetChargePlaced(true)
	if not keepBusy then self:SetBusy(false) end
end

function SWEP:PrimaryAttack()
	if not IsFirstTimePredicted() or self:GetBusy() then return end

	if self:GetChargePlaced() then
		self:SetBusy(true)
		self:PlayAnim("det_detonate")
		self:EmitSound("weapons/c4/handling/c4_trigger_security.wav", 65)
	else
		self:BeginC4Action("base_throw")
	end
end

function SWEP:SecondaryAttack()
	if not IsFirstTimePredicted() or self:GetBusy() or self:GetChargePlaced() then return end

	local tr = self:GetClosePlantTrace()
	if not tr or not tr.Hit or tr.HitSky then return end
	if tr.HitPos:DistToSqr(self:GetOwner():EyePos()) > self.PlantDistance ^ 2 then return end

	self:BeginC4Action("base_plant", tr)
end

function SWEP:DetonateC4()
	if self.C4Detonating then return end
	self.C4Detonating = true

	local owner = self:GetOwner()
	local iedController = self.IEDController
	if IsValid(iedController) and iedController.DetonateExternalIED then
		self.C4Charge = nil
		self:SetChargePlaced(false)
		if IsValid(owner) then
			if owner.HMCD_BombWep == self then owner.HMCD_BombWep = nil end
			owner.HMCD_BombCharge = nil
		end

		iedController:DetonateExternalIED()
		self:SetBusy(false)
		self:Remove()
		return
	end

	local charge = self.C4Charge
	if not IsValid(charge) then
		self.C4Detonating = nil
		self:SetBusy(false)
		self:SetChargePlaced(false)
		return
	end

	local pos = charge:WorldSpaceCenter()
	self.C4Charge = nil
	self:SetChargePlaced(false)
	if IsValid(owner) then
		if owner.HMCD_BombWep == self then owner.HMCD_BombWep = nil end
		if owner.HMCD_BombCharge == charge then owner.HMCD_BombCharge = nil end
	end

	charge:SetNoDraw(true)
	charge:SetNotSolid(true)
	hgBlastDoors(charge, pos, self.BlastDamage / 400, self.DoorBlastRange, false)
	util.ScreenShake(pos, 45, 225, 2.5, 3000)
	ParticleEffect("pcf_jack_groundsplode_medium", pos, -vector_up:Angle())
	charge:EmitSound("ied/ied_detonate_01.wav", 100, math.random(90, 105))
	charge:Remove()

	util.BlastDamage(self, IsValid(owner) and owner or self, pos, self.BlastRadius, self.BlastDamage)
	self:SetBusy(false)
	self:Remove()
end

function SWEP:ThinkAdd()
	if SERVER and self:GetChargePlaced() and not IsValid(self.C4Charge) then
		self:SetChargePlaced(false)
		self:SetBusy(false)
	end
end
