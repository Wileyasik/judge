SWEP.ShotgunTubeReload = false

local SG_READY = 0
local SG_NEEDS_CYCLE = 1
local SG_CYCLING = 2
local SG_RELOAD_START = 3
local SG_RELOAD_INSERT = 4
local SG_RELOAD_FINISH = 5
local SG_EMPTY = 6

function SWEP:GetShotgunState()
	local fallback = self:Clip1() > 0 and self.drawBullet and SG_READY or SG_EMPTY
	return self:GetNW2Int("HGShotgunState", fallback)
end

function SWEP:IsShotgunBusy()
	local state = self:GetShotgunState()
	return state == SG_CYCLING or state == SG_RELOAD_START or state == SG_RELOAD_INSERT or state == SG_RELOAD_FINISH
end

function SWEP:ShotgunSetState(state, duration)
	if not SERVER then return end

	self:SetNW2Int("HGShotgunState", state)
	self:SetNW2Float("HGShotgunStateEnd", duration and CurTime() + duration or 0)
	self:SetNetVar("shootgunReload", self:IsShotgunBusy() and self:GetNW2Float("HGShotgunStateEnd", 0) or 0)
end

function SWEP:ShotgunInvalidateCallbacks()
	self._ShotgunToken = (self._ShotgunToken or 0) + 1
	if SERVER then self:SetNW2Int("HGShotgunToken", self._ShotgunToken) end
	timer.Remove("AnimCallback" .. self:EntIndex())
	return self._ShotgunToken
end

function SWEP:ShotgunSetChambered(chambered)
	if not SERVER then return end

	self.drawBullet = chambered and self:Clip1() > 0 or false
	net.Start("hgwep draw")
		net.WriteEntity(self)
		net.WriteBool(self.drawBullet)
		net.WriteFloat(CurTime())
	net.Broadcast()
end

function SWEP:Initialize_Shotgun()
	if not self.ShotgunTubeReload or not SERVER then return end

	self._ShotgunToken = 0
	self._ShotgunInserted = 0
	self._ShotgunReloadInterrupt = false
	self._ShotgunReloadHeld = false
	self:ShotgunSetState(self:Clip1() > 0 and self.drawBullet and SG_READY or SG_EMPTY)
end

function SWEP:ShotgunPlay(state, animation, duration, callback)
	if not SERVER then return end

	duration = duration or 0
	local token = self:ShotgunInvalidateCallbacks()
	local owner = self:GetOwner()
	self:ShotgunSetState(state, duration)

	local function finished(wep)
		if not IsValid(wep) or wep._ShotgunToken ~= token then return end
		if wep:GetShotgunState() ~= state then return end
		if not IsValid(owner) or wep:GetOwner() ~= owner or owner:GetActiveWeapon() ~= wep then return end
		callback(wep)
	end

	if not animation or duration <= 0 then
		finished(self)
		return
	end

	self:PlayAnim(animation, duration, false, finished, false, true)
end

function SWEP:ShotgunCanInsert()
	local owner = self:GetOwner()
	return IsValid(owner)
		and self:Clip1() < self.Primary.ClipSize
		and owner:GetAmmoCount(self:GetPrimaryAmmoType()) > 0
end

function SWEP:ShotgunGetInsertAnimation()
	local animations = self.ShotgunReloadInsertAnims
	if not animations then return self.ShotgunReloadInsertAnim or "insert" end

	local index = math.Clamp((self._ShotgunInserted or 0) + 1, 1, #animations)
	return animations[index]
end

function SWEP:ShotgunStartCycle()
	if not SERVER or not self.ShotgunTubeReload or self:Clip1() <= 0 then return end

	self:ShotgunSetChambered(false)
	self:ShotgunPlay(SG_CYCLING, self.ShotgunCycleAnim or "cycle", self.ShotgunCycleTime or 1, function(wep)
		wep:ShotgunSetChambered(true)
		wep:ShotgunSetState(SG_READY)
		wep.Primary.Next = CurTime()
	end)
end

function SWEP:ShotgunStartFinish()
	if not SERVER then return end

	self:ShotgunPlay(SG_RELOAD_FINISH, self.ShotgunReloadFinishAnim or "finish", self.ShotgunReloadFinishTime or 1, function(wep)
		if wep._ShotgunWasEmpty and wep:Clip1() > 0 and wep.ShotgunEmptyReloadNeedsCycle then
			wep:ShotgunStartCycle()
			return
		end

		wep:ShotgunSetChambered(wep:Clip1() > 0)
		wep:ShotgunSetState(wep:Clip1() > 0 and SG_READY or SG_EMPTY)
		wep.Primary.Next = CurTime()
	end)
end

function SWEP:ShotgunStartInsert()
	if not SERVER then return end
	if not self:ShotgunCanInsert() then return self:ShotgunStartFinish() end

	local animation = self:ShotgunGetInsertAnimation()
	self:ShotgunPlay(SG_RELOAD_INSERT, animation, self.ShotgunReloadInsertTime or 1, function(wep)
		if not wep:ShotgunCanInsert() then return wep:ShotgunStartFinish() end

		wep:InsertAmmo(1)
		wep._ShotgunInserted = (wep._ShotgunInserted or 0) + 1

		local owner = wep:GetOwner()
		if wep._ShotgunReloadInterrupt or owner:KeyDown(IN_ATTACK) or not wep:ShotgunCanInsert() then
			wep:ShotgunStartFinish()
			return
		end

		wep:ShotgunStartInsert()
	end)
end

function SWEP:ShotgunStartReload()
	if not SERVER or not self:ShotgunCanInsert() then return end

	self._ShotgunWasEmpty = not self.drawBullet
	self._ShotgunInserted = 0
	self._ShotgunReloadInterrupt = false
	self:ShotgunPlay(SG_RELOAD_START, self.ShotgunReloadStartAnim or "start", self.ShotgunReloadStartTime or 1, function(wep)
		if wep.ShotgunReloadStartLoadsShell and wep:ShotgunCanInsert() then
			wep:InsertAmmo(1)
			wep._ShotgunInserted = 1
		end

		if wep._ShotgunReloadInterrupt then
			wep:ShotgunStartFinish()
		else
			wep:ShotgunStartInsert()
		end
	end)
end

function SWEP:ShotgunReload()
	if not self.ShotgunTubeReload or not SERVER then return end
	if not self:CanUse() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if self._ShotgunReloadHeld then return end
	self._ShotgunReloadHeld = true
	if owner.organism and (owner.organism.larmamputated or owner.organism.rarmamputated) then return end

	local state = self:GetShotgunState()
	if state == SG_RELOAD_START or state == SG_RELOAD_INSERT then
		self._ShotgunReloadInterrupt = true
		return
	end
	if state == SG_CYCLING or state == SG_RELOAD_FINISH then return end

	if state == SG_READY and (self:Clip1() <= 0 or not self.drawBullet) and self:ShotgunCanInsert() then
		self:ShotgunStartReload()
		return
	end

	if (state == SG_NEEDS_CYCLE or state == SG_EMPTY) and self:Clip1() > 0 and not self:ShotgunCanInsert() then
		self:ShotgunStartCycle()
		return
	end
	if state == SG_NEEDS_CYCLE then
		self:ShotgunStartCycle()
		return
	end

	self:ShotgunStartReload()
end

function SWEP:ShotgunAfterShot()
	if not self.ShotgunTubeReload or not SERVER then return end

	self:ShotgunInvalidateCallbacks()
	if self:Clip1() <= 0 then
		self:ShotgunSetChambered(false)
		self:ShotgunSetState(SG_EMPTY)
	elseif self.ShotgunManualCycle then
		self:ShotgunSetChambered(false)
		self:ShotgunSetState(SG_NEEDS_CYCLE)
	else
		self:ShotgunSetChambered(true)
		self:ShotgunSetState(SG_READY)
	end
end

function SWEP:ShotgunCanPrimaryAttack()
	if not self.ShotgunTubeReload then return true end
	return self:GetShotgunState() == SG_READY and self.drawBullet and self:Clip1() > 0
end

function SWEP:Step_Shotgun()
	if not self.ShotgunTubeReload or not SERVER then return end

	local owner = self:GetOwner()
	if IsValid(owner) and not owner:KeyDown(IN_RELOAD) then self._ShotgunReloadHeld = false end
	if not self:IsShotgunBusy() then return end
	if not IsValid(owner) or owner:GetActiveWeapon() ~= self then
		self:ShotgunInvalidateCallbacks()
		self:ShotgunSetState(self:Clip1() <= 0 and SG_EMPTY or (self.drawBullet and SG_READY or SG_NEEDS_CYCLE))
		return
	end

	local state = self:GetShotgunState()
	if (state == SG_RELOAD_START or state == SG_RELOAD_INSERT) and owner:KeyDown(IN_ATTACK) then
		self._ShotgunReloadInterrupt = true
	end
end

function SWEP:ShotgunCancel()
	if not self.ShotgunTubeReload then return end
	self:ShotgunInvalidateCallbacks()
end

function SWEP:ShotgunResetForUnload()
	if not self.ShotgunTubeReload or not SERVER then return end
	self:ShotgunInvalidateCallbacks()
	self:ShotgunSetState(SG_EMPTY)
end

function SWEP:ShotgunCanInspect()
	if not self.ShotgunTubeReload then return true end
	return self:GetShotgunState() == SG_READY
end
