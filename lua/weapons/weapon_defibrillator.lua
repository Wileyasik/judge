if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "AED"
SWEP.Instructions = "Attach to chest"
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/aed.png")
	SWEP.IconOverride = "vgui/aed.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/weapons/defib/w_eq_defibrillator.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "slam"
SWEP.WorkWithFake = false

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.AttachTime = 1

SWEP.DefaultRHPosOffset = Vector(-0.5,-2,-5)
SWEP.DefaultRHAngOffset = Angle(0,45,-55)

SWEP.DefaultLHPosOffset = Vector(0,-4,-2)
SWEP.DefaultLHAngOffset = Angle(5,0,-35)

SWEP.AttachRHPosOffset = Vector(1,6,-5)
SWEP.AttachRHAngOffset = Angle(0,45,-55)

SWEP.AttachLHPosOffset = Vector(4,-4,-20)
SWEP.AttachLHAngOffset = Angle(65,0,-35)

SWEP.SelfAttachRHPosOffset = Vector(-12,-16,-5)
SWEP.SelfAttachRHAngOffset = Angle(0,45,-55)

SWEP.SelfAttachLHPosOffset = Vector(-6,-4,10)
SWEP.SelfAttachLHAngOffset = Angle(5,0,-35)

SWEP.RHPosOffset = SWEP.DefaultRHPosOffset
SWEP.RHAngOffset = SWEP.DefaultRHAngOffset

SWEP.LHPosOffset = SWEP.DefaultLHPosOffset
SWEP.LHAngOffset = SWEP.DefaultLHAngOffset

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.DefibHandPos = Vector(5,-3,2)
SWEP.DefibHandAng = Angle(40,90,195)
SWEP.AttachDefibHandPos = Vector(5,-3,2)
SWEP.AttachDefibHandAng = Angle(40,90,245)
SWEP.SelfAttachDefibHandPos = Vector(5,-3,2)
SWEP.SelfAttachDefibHandAng = Angle(40,90,45)

SWEP.offsetVec = SWEP.DefibHandPos
SWEP.offsetAng = SWEP.DefibHandAng

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Skin = 1

SWEP.DefibModel = "models/weapons/defib/w_eq_defibrillator.mdl"
SWEP.DefibBone = "ValveBiped.Bip01_Spine2"
SWEP.DefibPos = Vector(-15, 2, 0)
SWEP.DefibAng = Angle(0, 90, 90)
SWEP.DefibFemPos = Vector(-15, 0, 1.1)
SWEP.DefibTime = 5
SWEP.DefibRange = 80
SWEP.DefibUses = 3

local AEDSounds = {
	charging = "defibrilator/rem_aed_charging.mp3",
	asystole = "defibrilator/rem_aed_asystole.wav",
	checkbreathing = "defibrilator/rem_aed_checkforbreathing.mp3",
	checkpulse = "defibrilator/rem_aed_checkforpulse.mp3",
	checkpads = "defibrilator/rem_aed_checkpadsforcontact.mp3",
	deploy = "defibrilator/rem_aed_deploy.wav",
	evaluating = "defibrilator/rem_aed_evaluating.mp3",
	fibrillation = "defibrilator/rem_aed_fibrillation.wav",
	heartbeat = "defibrilator/rem_aed_heartbeat.mp3",
	noshock = "defibrilator/rem_aed_noshockadvised.mp3",
	shockadvised = "defibrilator/rem_aed_shockadvised.mp3",
	shockdelivered = "defibrilator/rem_aed_shockdelivered.mp3",
	shocknotdelivered = "defibrilator/rem_aed_shocknotdelivered.mp3",
	shocksound = "defibrilator/rem_aed_shocksound.mp3",
	standclear = "defibrilator/rem_aed_standclear.mp3",
	startcpr = "defibrilator/rem_aed_startcpr.mp3"
}

local AEDNoSoundCooldown = {
	[AEDSounds.fibrillation] = true,
	[AEDSounds.charging] = true,
	[AEDSounds.shocksound] = true
}

local function GetAEDSoundEmitter(defib)
	if not IsValid(defib) then return end
	return IsValid(defib.AEDSoundEmitter) and defib.AEDSoundEmitter or defib
end

local function StopAEDSounds(defib)
	if not IsValid(defib) then return end
	local emitter = GetAEDSoundEmitter(defib)

	for _, snd in pairs(AEDSounds) do
		defib:StopSound(snd)
		if IsValid(emitter) and emitter != defib then emitter:StopSound(snd) end
	end
end

local function GetDefibTarget(ent)
	if not IsValid(ent) then return end

	if ent:IsPlayer() then
		local rag = ent.GetRagdollEntity and ent:GetRagdollEntity()
		return IsValid(rag) and rag or ent, ent
	end

	if ent:IsRagdoll() then
		local ply = hg and hg.RagdollOwner and hg.RagdollOwner(ent)
		return ent, IsValid(ply) and ply or nil
	end
end

local function GetCurrentDefibTarget(ply, fallback)
	if IsValid(fallback) and fallback:IsRagdoll() then return fallback end

	if IsValid(ply) then
		local rag = ply.GetRagdollEntity and ply:GetRagdollEntity()
		if IsValid(rag) and (not IsValid(fallback) or not ply:Alive()) then return rag end
	end

	return IsValid(fallback) and fallback or nil
end

local function PositionDefib(defib, target, bone, posOffset, angOffset, femOffset)
	if not IsValid(defib) or not IsValid(target) then return end

	local matrix = target:GetBoneMatrix(bone)
	if not matrix then return end

	local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()
	if femOffset and string.find(string.lower(target:GetModel() or ""), "female") then
		bonePos:Add(boneAng:Forward() * femOffset[1] + boneAng:Up() * femOffset[2] + boneAng:Right() * femOffset[3])
	end

	local pos, ang = LocalToWorld(posOffset, angOffset, bonePos, boneAng)
	defib:SetPos(pos)
	defib:SetAngles(ang)
end

local function GetDefibOrganism(ply, target)
	if IsValid(target) and target:IsRagdoll() and target.organism then return target.organism end
	if IsValid(ply) and ply.organism then return ply.organism end
	if IsValid(target) and target.organism then return target.organism end
end

local function ShouldShock(org)
	if not org or not org.alive or org.heartstop or org.deathStateKilled then return false end
	return org.fibrillation or (org.arrhythmia or 0) > 0.65 or (org.heartbeat or 0) > 200
end

local function IsDefibDead(org)
	if not org or not org.alive or org.deathStateKilled then return true end
	local owner = org.owner
	if IsValid(owner) and owner:IsPlayer() and not owner:Alive() then return true end
	return false
end

local function ShockChest(target, forceMul)
	if not IsValid(target) then return end

	if target:IsPlayer() then
		target:SetVelocity(-vector_up * 180 * forceMul)
		return
	end

	local bone = target:LookupBone("ValveBiped.Bip01_Spine2")
	local physbone = bone and target:TranslateBoneToPhysBone(bone) or 0
	local phys = target:GetPhysicsObjectNum(physbone)
	if not IsValid(phys) then phys = target:GetPhysicsObjectNum(0) end
	local applied

	if IsValid(phys) then
		phys:Wake()
		phys:ApplyForceCenter(-vector_up * 6000 * forceMul)
		applied = true
	end

	for i = 0, target:GetPhysicsObjectCount() - 1 do
		local obj = target:GetPhysicsObjectNum(i)
		if IsValid(obj) and obj != phys then
			obj:Wake()
			obj:ApplyForceCenter(-vector_up * 2500 * forceMul)
			applied = true
		end
	end

	if not applied then return end
end

local function IsShockTarget(ent, target)
	if ent == target then return true end
	if not IsValid(ent) or not IsValid(target) then return false end

	local entTarget = GetDefibTarget(ent)
	return entTarget == target
end

local function DropDefib(defib, target, uses, snd)
	if not IsValid(defib) then return end
	if defib.AEDDropped then return end

	defib.AEDDropped = true
	defib.AEDFinalized = true
	defib.AEDState = "dropped"
	StopAEDSounds(defib)

	local pos = defib:GetPos()
	local ang = defib:GetAngles()
	local playedSound

	if uses > 0 then
		local pickup = ents.Create("prop_physics")
		if IsValid(pickup) then
			pickup:SetModel("models/weapons/defib/w_eq_defibrillator.mdl")
			pickup:SetPos(pos + Vector(0, 0, 4))
			pickup:SetAngles(ang)
			pickup:SetUseType(SIMPLE_USE)
			pickup:Spawn()
			pickup:Activate()
			pickup:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			local phys = pickup:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity(vector_origin)
				phys:SetAngleVelocity(vector_origin)
			end
			if snd then pickup:EmitSound(snd, 75, 100) playedSound = true end
			pickup.IsDroppedDefib = true
			pickup.DefibUses = uses
			pickup.Use = function(ent, activator)
				if not IsValid(activator) or not activator:IsPlayer() then return end

				local wep = activator:Give("weapon_defibrillator")
				if IsValid(wep) then wep:SetNWInt("DefibUses", ent.DefibUses or 1) end
				ent:Remove()
			end
		end
	end
	if snd and not playedSound then sound.Play(snd, pos, 75, 100) end

	defib:Remove()
end

if SERVER then
	hook.Add("PlayerUse", "DefibrillatorPickupUse", function(ply, ent)
		if not IsValid(ent) or not ent.IsDroppedDefib then return end

		local wep = ply:Give("weapon_defibrillator")
		if IsValid(wep) then wep:SetNWInt("DefibUses", ent.DefibUses or 1) end
		ent:Remove()
		return false
	end)
end

local function PlayAEDSound(defib, snd, level, pitch, cd)
	if not IsValid(defib) then return end
	local emitter = GetAEDSoundEmitter(defib)
	if not IsValid(emitter) then return end

	if not AEDNoSoundCooldown[snd] then
		cd = snd == AEDSounds.asystole and 4 or cd or 2
		defib.AEDSoundCD = defib.AEDSoundCD or {}
		if (defib.AEDSoundCD[snd] or 0) > CurTime() then return end
		defib.AEDSoundCD[snd] = CurTime() + cd
	end

	emitter:EmitSound(snd, level or 75, pitch or 100)
end

local function StartAEDLoop(defib, snd, patch)
	if not IsValid(defib) then return patch end
	if patch then return patch end

	local loop = {
		soundEntity = GetAEDSoundEmitter(defib),
		timerName = "AEDLoop" .. defib:EntIndex() .. snd
	}
	loop.patch = CreateSound(loop.soundEntity, snd)

	local function playLoop()
		if not IsValid(defib) then timer.Remove(loop.timerName) return end
		local emitter = GetAEDSoundEmitter(defib)
		if loop.soundEntity != emitter then
			if loop.patch then loop.patch:Stop() end
			loop.soundEntity = emitter
			loop.patch = CreateSound(emitter, snd)
		end
		if loop.patch then loop.patch:Stop() loop.patch:PlayEx(1, 100) end
	end

	playLoop()
	timer.Create(loop.timerName, math.max(SoundDuration(snd) - 0.05, 0.1), 0, playLoop)
	return loop
end

local function StopAEDLoop(patch)
	if not patch then return end
	if patch.timerName then timer.Remove(patch.timerName) end
	if patch.patch then patch.patch:Stop() return end
	patch:Stop()
end

local function SetAEDState(defib, state)
	if not IsValid(defib) then return false end
	if defib.AEDDropped or defib.AEDFinalized then return false end

	defib.AEDState = state
	return true
end

local function IsAEDState(defib, state)
	return IsValid(defib) and not defib.AEDDropped and defib.AEDState == state
end

local function ApplyAEDShock(org)
	if not org then return end

	org.fibrillation = false
	org.arrhythmia = 0
	org.heartStrain = math.max((org.heartStrain or 0) - 0.2, 0)

	if math.random(100) <= 22 then
		org.heartstop = false
		org.heartbeat = math.Clamp(org.heartbeat or 70, 55, 90)
		org.pulse = math.max(org.pulse or 0, 45)
		org.bloodPressure = math.max(org.bloodPressure or 0, 65)
		org.myocardialOxygen = math.max(org.myocardialOxygen or 0, 0.35)
	else
		org.heartstop = true
		org.heartbeat = 0
		org.pulse = 0
		org.bloodPressure = math.max(org.bloodPressure or 0, 35)
		org.myocardialOxygen = math.max(org.myocardialOxygen or 0, 0.2)
	end

	org.deathStateKilled = nil
	org.defibDeathGrace = CurTime() + 45
	org.deathStateEnd = math.max(org.deathStateEnd or 0, org.defibDeathGrace)
end

local function BeginAEDShock(defib, ply, getTarget, uses)
	if not SetAEDState(defib, "charging") then return end
	if defib.AEDCharging or defib.AEDShocked then return end

	defib.AEDCharging = true
	defib.AEDNoShockWarnings = false
	PlayAEDSound(defib, AEDSounds.shockadvised)
	PlayAEDSound(defib, AEDSounds.charging)
	timer.Simple(1.5, function()
		if IsAEDState(defib, "charging") then PlayAEDSound(defib, AEDSounds.standclear) end
	end)

	timer.Simple(5, function()
		if not IsAEDState(defib, "charging") or defib.AEDShocked then return end

		defib.AEDCharging = false
		local target = GetCurrentDefibTarget(ply, getTarget())
		if not IsValid(target) then return end
		local org = GetDefibOrganism(ply, target)
		if IsDefibDead(org) or org.heartstop then
			if org and org.heartstop then PlayAEDSound(defib, AEDSounds.asystole, 75, 100, 2) end
			PlayAEDSound(defib, AEDSounds.shocknotdelivered, 75, 100, 2)
			DropDefib(defib, target, uses)
			return
		end

		defib.AEDState = "shocked"
		defib.AEDFinalized = true
		defib.AEDShocked = true
		PlayAEDSound(defib, AEDSounds.shocksound, 85, 100, 2)
		PlayAEDSound(defib, AEDSounds.shockdelivered, 75, 100, 3)
		ShockChest(target, 2)
		ApplyAEDShock(org)

		if org then
			org.painadd = (org.painadd or 0) + 150
			org.shock = (org.shock or 0) + 150
		end

		for _, otherPly in ipairs(player.GetAll()) do
			if not otherPly:Alive() then continue end
			local isTouching = false

			if IsShockTarget(otherPly:GetNetVar("carryent"), target) or IsShockTarget(otherPly:GetNetVar("carryent2"), target) then
				isTouching = true
			end

			local fakeRag = otherPly.FakeRagdoll
			if not isTouching and IsValid(fakeRag) then
				if (IsValid(fakeRag.ConsLH) and (IsShockTarget(fakeRag.ConsLH.Ent2, target) or IsShockTarget(fakeRag.ConsLH.choking, target))) or
				   (IsValid(fakeRag.ConsRH) and (IsShockTarget(fakeRag.ConsRH.Ent2, target) or IsShockTarget(fakeRag.ConsRH.choking, target))) then
					isTouching = true
				end
			end

			if isTouching then
				local otherOrg = otherPly.organism
				if otherOrg then
					otherOrg.painadd = (otherOrg.painadd or 0) + 150
					otherOrg.shock = (otherOrg.shock or 0) + 150
					
					if hg and hg.StunPlayer then
						hg.StunPlayer(otherPly, 2)
					end
				end
			end
		end

		timer.Simple(5, function()
			if not IsValid(defib) then return end
			PlayAEDSound(defib, AEDSounds.startcpr, 75, 100, 3)
			DropDefib(defib, target, uses - 1)
		end)
	end)
end

local function StartNoShockWarnings(defib, ply, getTarget, uses)
	if not SetAEDState(defib, "no_shock") then return end
	if defib.AEDNoShockWarnings or defib.AEDCharging or defib.AEDShocked then return end

	defib.AEDNoShockWarnings = true
	local org = GetDefibOrganism(ply, getTarget())
	if IsDefibDead(org) then
		PlayAEDSound(defib, AEDSounds.shocknotdelivered, 75, 100, 2)
		DropDefib(defib, getTarget(), uses)
		return
	end
	if org and org.heartstop then PlayAEDSound(defib, AEDSounds.asystole, 75, 100, 2) end
	PlayAEDSound(defib, AEDSounds.noshock)

	timer.Simple(4.5, function()
		if not IsAEDState(defib, "no_shock") or not defib.AEDNoShockWarnings then return end
		local org = GetDefibOrganism(ply, getTarget())
		if ShouldShock(org) then BeginAEDShock(defib, ply, getTarget, uses) return end
		PlayAEDSound(defib, AEDSounds.checkpulse)
	end)

	timer.Simple(9, function()
		if not IsAEDState(defib, "no_shock") or not defib.AEDNoShockWarnings then return end
		local org = GetDefibOrganism(ply, getTarget())
		if ShouldShock(org) then BeginAEDShock(defib, ply, getTarget, uses) return end
		PlayAEDSound(defib, AEDSounds.checkbreathing)
	end)

	timer.Simple(13.5, function()
		if not IsAEDState(defib, "no_shock") or not defib.AEDNoShockWarnings then return end
		local org = GetDefibOrganism(ply, getTarget())
		if ShouldShock(org) then BeginAEDShock(defib, ply, getTarget, uses) return end
		DropDefib(defib, getTarget(), uses)
	end)
end

local function StartAEDSequence(defib, ply, getTarget, uses)
	if not SetAEDState(defib, "evaluating") then return end

	PlayAEDSound(defib, AEDSounds.evaluating)

	timer.Simple(8, function()
		if not IsAEDState(defib, "evaluating") then return end

		defib.AEDEvaluated = true
		local target = getTarget()
		local org = GetDefibOrganism(ply, target)
		if IsDefibDead(org) then
			PlayAEDSound(defib, AEDSounds.shocknotdelivered, 75, 100, 2)
			DropDefib(defib, target, uses)
			return
		end

		if not ShouldShock(org) then
			StartNoShockWarnings(defib, ply, getTarget, uses)
			return
		end

		BeginAEDShock(defib, ply, getTarget, uses)
	end)
end

local function TraceDefibTarget(owner, range)
	local tr = util.TraceLine({
		start = owner:GetShootPos(),
		endpos = owner:GetShootPos() + owner:GetAimVector() * range,
		filter = owner,
		mask = MASK_SHOT_HULL
	})

	local target, ply = GetDefibTarget(tr.Entity)
	return target, ply
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + 0.05)
	if CLIENT then return end
	if self.DefibApplying then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local target, ply = TraceDefibTarget(owner, self.DefibRange)
	if not IsValid(target) or target == owner or ply == owner then return end
	if IsValid(target.DefibModelEnt) or target.DefibInProgress then return end

	self.DefibApplying = {
		target = target,
		ply = ply,
		start = CurTime(),
		finish = CurTime() + self.AttachTime,
		attack = IN_ATTACK
	}
	self:SetNWFloat("DefibAttachStart", self.DefibApplying.start)
	self:SetNWFloat("DefibAttachFinish", self.DefibApplying.finish)
	self:SetNWBool("DefibAttachSelf", false)
end

function SWEP:Think()
	if CLIENT then
		local attachTime = self.AttachTime or 1.5
		local startTime = self:GetNWFloat("DefibAttachStart", 0)
		local finishTime = self:GetNWFloat("DefibAttachFinish", 0)
		local targetProgress = 0

		if startTime > 0 and finishTime > CurTime() then
			targetProgress = math.Clamp((CurTime() - startTime) / attachTime, 0, 1)
			self.DefibAttachSelfMode = self:GetNWBool("DefibAttachSelf", false)
		end

		self.DefibAttachProgress = math.Approach(self.DefibAttachProgress or 0, targetProgress, FrameTime() / attachTime)

		local progress = self.DefibAttachProgress
		if progress <= 0 then self.DefibAttachSelfMode = false end
		local selfAttach = self.DefibAttachSelfMode or false
		local rhPos = selfAttach and self.SelfAttachRHPosOffset or self.AttachRHPosOffset
		local rhAng = selfAttach and self.SelfAttachRHAngOffset or self.AttachRHAngOffset
		local lhPos = selfAttach and self.SelfAttachLHPosOffset or self.AttachLHPosOffset
		local lhAng = selfAttach and self.SelfAttachLHAngOffset or self.AttachLHAngOffset
		local handPos = selfAttach and self.SelfAttachDefibHandPos or self.AttachDefibHandPos
		local handAng = selfAttach and self.SelfAttachDefibHandAng or self.AttachDefibHandAng

		self.RHPosOffset = LerpVector(progress, self.DefaultRHPosOffset, rhPos)
		self.RHAngOffset = LerpAngle(progress, self.DefaultRHAngOffset, rhAng)
		self.LHPosOffset = LerpVector(progress, self.DefaultLHPosOffset, lhPos)
		self.LHAngOffset = LerpAngle(progress, self.DefaultLHAngOffset, lhAng)
		self.offsetVec = LerpVector(progress, self.DefibHandPos, handPos)
		self.offsetAng = LerpAngle(progress, self.DefibHandAng, handAng)
		return
	end

	if not SERVER then return end

	local apply = self.DefibApplying
	if not apply then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:KeyDown(apply.attack) then
		self.DefibApplying = nil
		self:SetNWFloat("DefibAttachStart", 0)
		self:SetNWFloat("DefibAttachFinish", 0)
		self:SetNWBool("DefibAttachSelf", false)
		return
	end

	if apply.finish > CurTime() then return end

	local target, ply
	if apply.selfUse then
		target = owner
		ply = owner
	else
		target, ply = TraceDefibTarget(owner, self.DefibRange)
	end

	if target != apply.target then
		self.DefibApplying = nil
		self:SetNWFloat("DefibAttachStart", 0)
		self:SetNWFloat("DefibAttachFinish", 0)
		self:SetNWBool("DefibAttachSelf", false)
		return
	end

	self.DefibApplying = nil
	self:SetNWFloat("DefibAttachStart", 0)
	self:SetNWFloat("DefibAttachFinish", 0)
	self:SetNWBool("DefibAttachSelf", false)
	self:AttachDefib(owner, target, ply)
end

function SWEP:AttachDefib(owner, target, ply)
	if not IsValid(owner) or not IsValid(target) then return end
	if IsValid(target.DefibModelEnt) or target.DefibInProgress then return end

	local bone = target:LookupBone(self.DefibBone)
	if not bone then return end

	local matrix = target:GetBoneMatrix(bone)
	if not matrix then return end

	local uses = self:GetNWInt("DefibUses", self.DefibUses)
	if uses <= 0 then return end

	local defib = ents.Create("prop_dynamic")
	if not IsValid(defib) then return end

	defib:SetModel(self.DefibModel)
	defib:SetNoDraw(true)
	defib:SetSolid(SOLID_NONE)
	defib:Spawn()
	defib:SetMoveType(MOVETYPE_NONE)
	defib.AEDSoundEmitter = target
	PositionDefib(defib, target, bone, self.DefibPos, self.DefibAng, self.DefibFemPos)

	target.DefibModelEnt = defib
	target.DefibInProgress = true
	target:SetNetVar("DefibAttached", true)
	if IsValid(ply) then ply:SetNetVar("DefibAttached", true) end
	PlayAEDSound(defib, AEDSounds.deploy)
	owner:ViewPunch(Angle(5, 0, 0))

	local timerName = "DefibFollow" .. defib:EntIndex()
	local activeTarget = target
	local defibBone = self.DefibBone
	local defibPos = self.DefibPos
	local defibAng = self.DefibAng
	local defibFemPos = self.DefibFemPos
	local nextHeartbeat = 0
	local movingSince
	local fibrillationLoop
	local asystolePlayed
	local fibrillationStop

	defib:CallOnRemove("DefibCleanup", function()
		timer.Remove(timerName)
		if fibrillationLoop then StopAEDLoop(fibrillationLoop) end
		defib.AEDSoundEmitter = nil
		if IsValid(activeTarget) then
			activeTarget.DefibModelEnt = nil
			activeTarget.DefibInProgress = nil
			activeTarget:SetNetVar("DefibAttached", false)
		end
		if IsValid(ply) then ply:SetNetVar("DefibAttached", false) end
	end)

	timer.Create(timerName, 0, 0, function()
		if not IsValid(defib) then
			timer.Remove(timerName)
			return
		end

		local currentTarget = GetCurrentDefibTarget(ply, activeTarget)
		if not IsValid(currentTarget) then
			defib:Remove()
			return
		end
		defib.AEDSoundEmitter = currentTarget

		if currentTarget != activeTarget then
			if IsValid(activeTarget) then
				activeTarget.DefibModelEnt = nil
				activeTarget.DefibInProgress = nil
				activeTarget:SetNetVar("DefibAttached", false)
			end

			activeTarget = currentTarget
			activeTarget.DefibModelEnt = defib
			activeTarget.DefibInProgress = true
			activeTarget:SetNetVar("DefibAttached", true)
			if IsValid(ply) then ply:SetNetVar("DefibAttached", true) end
		end

		local currentBone = activeTarget:LookupBone(defibBone)
		if not currentBone then return end

		PositionDefib(defib, activeTarget, currentBone, defibPos, defibAng, defibFemPos)

		local org = GetDefibOrganism(ply, activeTarget)
		if org and org.heartstop then
			if fibrillationLoop and not fibrillationStop then fibrillationStop = CurTime() + 0.4 end
			if not asystolePlayed then
				PlayAEDSound(defib, AEDSounds.asystole, 75, 100)
				asystolePlayed = true
			end
		elseif org and org.fibrillation then
			fibrillationStop = nil
			asystolePlayed = nil
			fibrillationLoop = StartAEDLoop(defib, AEDSounds.fibrillation, fibrillationLoop)
		elseif org then
			asystolePlayed = nil
			if fibrillationLoop and not fibrillationStop then fibrillationStop = CurTime() + 0.4 end
		end

		if fibrillationStop and fibrillationStop < CurTime() then
			StopAEDLoop(fibrillationLoop)
			fibrillationLoop = nil
			fibrillationStop = nil
		end

		if defib.AEDEvaluated and ShouldShock(org) and IsAEDState(defib, "no_shock") and not defib.AEDCharging and not defib.AEDShocked then
			BeginAEDShock(defib, ply, function() return activeTarget end, uses)
		end

		if org and not org.fibrillation and not org.heartstop and (org.heartbeat or 0) > 0 and nextHeartbeat < CurTime() then
			nextHeartbeat = CurTime() + 60 / math.Clamp(org.heartbeat, 30, 220)
			PlayAEDSound(defib, AEDSounds.heartbeat, 55, 100)
		end

		if activeTarget:GetVelocity():LengthSqr() > 160 * 160 then
			movingSince = movingSince or CurTime()
			if movingSince + 1.25 < CurTime() then DropDefib(defib, activeTarget, uses, AEDSounds.checkpads) end
		else
			movingSince = nil
		end
	end)

	StartAEDSequence(defib, ply, function() return activeTarget end, uses)
	owner:StripWeapon(self:GetClass())
end

function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + 0.05)
	if CLIENT then return end
	if self.DefibApplying then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if IsValid(owner.DefibModelEnt) or owner.DefibInProgress then return end

	self.DefibApplying = {
		target = owner,
		ply = owner,
		start = CurTime(),
		finish = CurTime() + self.AttachTime,
		attack = IN_ATTACK2,
		selfUse = true
	}
	self:SetNWFloat("DefibAttachStart", self.DefibApplying.start)
	self:SetNWFloat("DefibAttachFinish", self.DefibApplying.finish)
	self:SetNWBool("DefibAttachSelf", true)
end

if CLIENT then
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end

		local x, y = ScrW() / 2, ScrH() / 2 + 65
		local text = "Hold RMB to place AED on yourself"
		draw.SimpleText(text, "HomigradFont", x + 3, y + 26, color_black, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "HomigradFont", x, y + 24, color_white, TEXT_ALIGN_CENTER)

		local target, ply = TraceDefibTarget(LocalPlayer(), self.DefibRange)
		if not IsValid(target) or target == LocalPlayer() or ply == LocalPlayer() then return end

		draw.SimpleText("Hold LMB to place AED", "HomigradFont", x + 3, y + 2, color_black, TEXT_ALIGN_CENTER)
		draw.SimpleText("Hold LMB to place AED", "HomigradFont", x, y, color_white, TEXT_ALIGN_CENTER)
	end
end
