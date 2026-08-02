local GP25_ATTACHMENT = "gp25"
local GP25_AMMO = "VOG-25 Grenade"
local GP25_RELOAD_TIME = 2.2
local GP25_LOAD_TIME = 0.4
local GP25_FIRE_TIME = 0.8
local GP25_SWITCH_TIME = 0.7

SWEP.GP25MuzzlePos = Vector(-7, 0, -2)
SWEP.GP25MuzzleAng = Angle(0, 0, 0)
SWEP.GP25ClipSize = 1
SWEP.GP25AimTransitionSpeed = 0.04
SWEP.GP25ViewPunch = Angle(-2, 0, 0)
SWEP.GP25CameraKickDistance = 0.7
SWEP.GP25CameraKickDuration = 0.22
SWEP.GP25ShakeAmplitude = 1.5
SWEP.GP25ShakeFrequency = 8
SWEP.GP25ShakeDuration = 0.25
SWEP.GP25ShakeRadius = 128

local GP25_WEAPONS = {
	["weapon_ak12"] = true,
	["weapon_ak74"] = true,
	["weapon_akm"] = true,
	["weapon_akmz"] = true,
	["weapon_akz"] = true,
	["weapon_vpo136"] = true,
	["weapon_vpo209"] = true,
	["weapon_sag_ak545"] = true,
}

function SWEP:SetupGP25AttachmentSlot()
	if not GP25_WEAPONS[string.lower(self:GetClass())] then return end

	self.availableAttachments = self.availableAttachments or {}
	local slot = self.availableAttachments.gp25 or {}
	self.availableAttachments.gp25 = slot
	slot.gp25 = {GP25_ATTACHMENT, Vector(0, 0, 0), {}, mountType = "ak_gp25"}
	slot.mount = slot.mount or Vector(3, -1, -1)
	slot.mountAngle = slot.mountAngle or Angle(0, -0.75, 90)

	if istable(slot.mountType) then
		if not table.HasValue(slot.mountType, "ak_gp25") then table.insert(slot.mountType, "ak_gp25") end
	elseif slot.mountType then
		slot.mountType = {slot.mountType, "ak_gp25"}
	else
		slot.mountType = "ak_gp25"
	end
end

function SWEP:HasGP25()
	return self:HasAttachment("gp25", GP25_ATTACHMENT)
end

function SWEP:IsGP25Active()
	return self:HasGP25() and self:GetNW2Bool("GP25Active", false)
end

if CLIENT then
	function SWEP:PlayGP25ModelAnimation(sequence, duration, looping)
		self.GP25ModelSequence = sequence
		self.GP25ModelDuration = duration or 1
		self.GP25ModelLooping = looping or false
		self.GP25ModelAnimationStart = CurTime()
		if sequence == "fire" then self.GP25CameraKickStart = CurTime() end

		local model = self:GetAttachmentModel("gp25")
		if not IsValid(model) then return end

		local sequenceID = model:LookupSequence(sequence)
		if not sequenceID or sequenceID < 0 then return end

		model:ResetSequence(sequenceID)
		model:SetCycle(0)
		model.HGGP25Sequence = sequence
	end

	function SWEP:GetGP25CameraKick()
		if not self.GP25CameraKickStart then return 0 end

		local duration = math.max(self.GP25CameraKickDuration or 0.22, 0.01)
		local fraction = (CurTime() - self.GP25CameraKickStart) / duration
		if fraction >= 1 then
			self.GP25CameraKickStart = nil
			return 0
		end

		return -math.sin(fraction * math.pi * 2) * (1 - fraction) * (self.GP25CameraKickDistance or 0.7)
	end

	function SWEP:ApplyGP25LHIK(target)
		if not self:HasGP25() or not self.ApplyARC9GripPose then return end

		local owner = self:GetOwner()
		local reloadLHIKWeight = self:GetARC9ReloadLHIKWeight()
		local actionActive = self.reload
		local usePose = IsValid(owner)
			and not owner.suiciding
			and self.lhandik
			and hg.CanUseLeftHand(owner)
			and (not actionActive or reloadLHIKWeight > 0)
		self.GP25LHIKWeight = LerpFT(self.ARC9LHIKTransitionSpeed or 0.04, self.GP25LHIKWeight or 0, usePose and 1 or 0)
		if actionActive then self.GP25LHIKWeight = math.max(self.GP25LHIKWeight, reloadLHIKWeight) end

		local model = self:GetAttachmentModel("gp25")
		if not IsValid(model) then return end

		local sequence = self.GP25ModelSequence or "idle_armed"
		if model.HGGP25Sequence ~= sequence then
			self:PlayGP25ModelAnimation(sequence, self.GP25ModelDuration, self.GP25ModelLooping)
		end

		local duration = math.max(self.GP25ModelDuration or 1, 0.01)
		local cycle = (CurTime() - (self.GP25ModelAnimationStart or CurTime())) / duration
		if self.GP25ModelLooping then
			cycle = cycle % 1
		else
			cycle = math.min(cycle, 1)
		end
		model:SetCycle(cycle)

		if self.GP25LHIKWeight <= 0.001 then return end
		self:ApplyARC9GripPose(target, model, actionActive and reloadLHIKWeight or self.GP25LHIKWeight)
	end
end

if SERVER then
	util.AddNetworkString("hg_gp25_toggle")
	util.AddNetworkString("hg_gp25_model_anim")

	function SWEP:SendGP25ModelAnimation(sequence, duration, looping)
		net.Start("hg_gp25_model_anim")
			net.WriteEntity(self)
			net.WriteString(sequence)
			net.WriteFloat(duration or 1)
			net.WriteBool(looping or false)
		net.Broadcast()
	end

	function SWEP:PlayGP25WeaponAnimation(sequence, duration, looping, reverse)
		self:PlayAnim(sequence, duration, looping, nil, reverse, true)
	end

	function SWEP:SetGP25Idle()
		if not self:IsGP25Active() then return end
		self:PlayGP25WeaponAnimation("gp34_idle", 1, true)
		self:SendGP25ModelAnimation("idle_armed", 1, true)
	end

	function SWEP:GP25Reload()
		if not self:IsGP25Active() then return false end
		if (self.GP25NextAction or 0) > CurTime() then return false end
		local clip = self:GetNW2Int("GP25Clip", 0)
		local clipSize = self.GP25ClipSize or 1
		if clip >= clipSize then return false end

		local owner = self:GetOwner()
		if not IsValid(owner) or owner:GetAmmoCount(GP25_AMMO) < 1 then return false end
		local loadCount = math.min(clipSize - clip, owner:GetAmmoCount(GP25_AMMO))

		self.GP25ActionSerial = (self.GP25ActionSerial or 0) + 1
		local serial = self.GP25ActionSerial
		self.GP25NextAction = CurTime() + GP25_RELOAD_TIME
		self:PlayGP25WeaponAnimation("gp34_reload", GP25_RELOAD_TIME, false)
		self:SendGP25ModelAnimation("reload", GP25_RELOAD_TIME, false)

		timer.Simple(GP25_LOAD_TIME, function()
			if not IsValid(self) or self.GP25ActionSerial ~= serial or not self:HasGP25() then return end
			if not IsValid(owner) or self:GetOwner() ~= owner or owner:GetAmmoCount(GP25_AMMO) < loadCount then return end

			owner:RemoveAmmo(loadCount, GP25_AMMO)
			self:SetNW2Int("GP25Clip", clip + loadCount)
			self:EmitSound("weapons/darsu_eft/ak/gp34/gp_25_vog_in.ogg", 65, 100)
		end)

		timer.Simple(GP25_RELOAD_TIME, function()
			if not IsValid(self) or self.GP25ActionSerial ~= serial then return end
			self:SetGP25Idle()
		end)
		return true
	end

	function SWEP:GP25PrimaryAttack()
		if not self:IsGP25Active() then return false end
		if (self.GP25NextAction or 0) > CurTime() then return false end
		if self.CanUse and not self:CanUse() then return false end

		local owner = self:GetOwner()
		if not IsValid(owner) then return false end
		if self.GP25TriggerHeld then return false end
		self.GP25TriggerHeld = true

		if self:GetNW2Int("GP25Clip", 0) < 1 then
			if owner:GetAmmoCount(GP25_AMMO) > 0 then return self:GP25Reload() end

			self.GP25NextAction = CurTime() + 0.35
			local emptySound = istable(self.Primary.SoundEmpty) and self.Primary.SoundEmpty[1] or self.Primary.SoundEmpty
			self:EmitSound(emptySound or "weapons/pistol/pistol_empty.wav", 65, 100)
			return false
		end

		local weaponMuzzlePos, weaponMuzzleAng = self:GetTrace(true, nil, nil, true)
		if not weaponMuzzlePos or not weaponMuzzleAng then return false end

		local shootPos = LocalToWorld(
			self.GP25MuzzlePos or vector_origin,
			self.GP25MuzzleAng or angle_zero,
			weaponMuzzlePos,
			weaponMuzzleAng
		)
		local eyePos = owner:GetShootPos()
		local gun = self:GetWeaponEntity()
		local fake = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or nil
		local traceFilter = {owner, self, gun, fake}
		local aimTrace = util.TraceLine({
			start = eyePos,
			endpos = eyePos + owner:EyeAngles():Forward() * 8000,
			filter = traceFilter,
			mask = MASK_SHOT,
		})
		local aimDirection = (aimTrace.HitPos - shootPos):GetNormalized()
		local muzzleTrace = util.TraceHull({
			start = shootPos - aimDirection * 2,
			endpos = shootPos + aimDirection * 2,
			mins = Vector(-1, -1, -1),
			maxs = Vector(1, 1, 1),
			filter = traceFilter,
			mask = MASK_SHOT_HULL,
		})
		if muzzleTrace.StartSolid or muzzleTrace.Hit then return false end
		local projectile = ents.Create("ent_vog25")
		if not IsValid(projectile) then return false end

		projectile.owner = owner
		projectile:SetOwner(owner)
		projectile:SetPos(shootPos)
		projectile:SetAngles(aimDirection:Angle())
		projectile:Spawn()

		local phys = projectile:GetPhysicsObject()
		if not IsValid(phys) then
			projectile:Remove()
			return false
		end

		phys:SetVelocity(owner:GetVelocity() + aimDirection * 4000)
		self:SetNW2Int("GP25Clip", math.max(self:GetNW2Int("GP25Clip", 1) - 1, 0))
		self:SetLastShootTime(CurTime())
		self.GP25ActionSerial = (self.GP25ActionSerial or 0) + 1
		local serial = self.GP25ActionSerial
		self.GP25NextAction = CurTime() + GP25_FIRE_TIME
		self:PlayGP25WeaponAnimation("gp34_fire", GP25_FIRE_TIME, false)
		self:SendGP25ModelAnimation("fire", GP25_FIRE_TIME, false)
		sound.Play("weapons/darsu_eft/ak/gp34/gp_25_grenade_fire_outdoor_close.ogg", shootPos, 111, 100, 1)
		owner:ViewPunch(self.GP25ViewPunch or Angle(-2, 0, 0))
		util.ScreenShake(
			shootPos,
			self.GP25ShakeAmplitude or 1.5,
			self.GP25ShakeFrequency or 8,
			self.GP25ShakeDuration or 0.25,
			self.GP25ShakeRadius or 128
		)

		timer.Simple(GP25_FIRE_TIME, function()
			if not IsValid(self) or self.GP25ActionSerial ~= serial then return end
			self:SetGP25Idle()
		end)
		return true
	end

	net.Receive("hg_gp25_toggle", function(_, ply)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.ishgwep or not wep.HasGP25 or not wep:HasGP25() then return end
		if wep.reload or (wep.GP25NextAction or 0) > CurTime() then return end

		if not wep:GetNW2Bool("GP25Initialized", false) then
			wep:SetNW2Bool("GP25Initialized", true)
			wep:SetNW2Int("GP25Clip", 0)
		end

		local active = not wep:GetNW2Bool("GP25Active", false)
		wep:SetNW2Bool("GP25Active", active)
		wep.GP25ActionSerial = (wep.GP25ActionSerial or 0) + 1
		local serial = wep.GP25ActionSerial
		wep.GP25NextAction = CurTime() + GP25_SWITCH_TIME
		wep:PlayGP25WeaponAnimation("gp34_switch", GP25_SWITCH_TIME, false, not active)

		timer.Simple(GP25_SWITCH_TIME, function()
			if not IsValid(wep) or wep.GP25ActionSerial ~= serial then return end
			if active then
				wep:SetGP25Idle()
			else
				wep:PlayGP25WeaponAnimation("idle", 1, not wep.NoIdleLoop)
			end
		end)
	end)

	hook.Add("KeyRelease", "hg_gp25_release_trigger", function(ply, key)
		if key ~= IN_ATTACK then return end
		local wep = ply:GetActiveWeapon()
		if IsValid(wep) then wep.GP25TriggerHeld = nil end
	end)
else
	local gp25ZoomActive = false
	hook.Add("Think", "hg_gp25_zoom", function()
		local owner = LocalPlayer()
		local wep = IsValid(owner) and owner:GetActiveWeapon()
		local active = IsValid(wep) and wep.IsGP25Active and wep:IsGP25Active() or false
		if active == gp25ZoomActive then return end

		gp25ZoomActive = active
		RunConsoleCommand(active and "+hg_zoom" or "-hg_zoom")
	end)

	hook.Add("PlayerButtonDown", "hg_gp25_toggle", function(ply, button)
		if ply ~= LocalPlayer() or button ~= KEY_G then return end
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.ishgwep or not wep.HasGP25 or not wep:HasGP25() then return end

		net.Start("hg_gp25_toggle")
		net.SendToServer()
	end)

	net.Receive("hg_gp25_model_anim", function()
		local wep = net.ReadEntity()
		local sequence = net.ReadString()
		local duration = net.ReadFloat()
		local looping = net.ReadBool()
		if IsValid(wep) and wep.PlayGP25ModelAnimation then
			wep:PlayGP25ModelAnimation(sequence, duration, looping)
		end
	end)
end

local basePrimaryAttack = SWEP.PrimaryAttack
function SWEP:PrimaryAttack(...)
	if (self.GP25NextAction or 0) > CurTime() then return end
	if self:IsGP25Active() then
		if CLIENT then return end
		return self:GP25PrimaryAttack()
	end
	return basePrimaryAttack(self, ...)
end

local baseReload = SWEP.Reload
function SWEP:Reload(...)
	if (self.GP25NextAction or 0) > CurTime() then return end
	if self:IsGP25Active() then
		if CLIENT then return end
		return self:GP25Reload()
	end
	return baseReload(self, ...)
end
