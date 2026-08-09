if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Decompression needle"
SWEP.Instructions = "Needle decompression is used to treat tension pneumothorax. Hold LMB to use on yourself; hold RMB to use on someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cof/weapons/syringe/w_syringe.mdl"
SWEP.WorldModelReal = "models/cof/weapons/syringe/v_syringe.mdl"
SWEP.WorldModelExchange = false
SWEP.modelscale = 0.7
SWEP.modelscale2 = 0.7

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_decompression_needle.png")
	SWEP.IconOverride = "vgui/icons/ico_decompression_needle.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.setlh = true
SWEP.setrh = true
SWEP.healingOther = false

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "HealingOther")
end

SWEP.HoldPos = Vector(2, -1.5, -2)
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.offsetVec = Vector(3, -2.5, -1)
SWEP.offsetAng = Angle(-30, 20, -90)
SWEP.lpos = Vector(0, 0, 0)
SWEP.lang = Angle(0, 0, 0)
SWEP.handPosOffset = Vector(0, 0, 0)
SWEP.handAngOffset = Angle(0, 0, 0)

SWEP.modeNames = {
	[1] = "decompression"
}

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.UseSpeed = 3
SWEP.CallbackTimeAdjust = 0.5
SWEP.AnimList = {
	["deploy"] = {"deploy", 0.5, false},
	["use"] = {"use", 3, false, false, function(self)
		if CLIENT then return end
		if self:GetHealingOther() and IsValid(self.healbuddy) then
			self:Heal(self.healbuddy)
		else
			self:Heal(self:GetOwner())
		end
	end},
	["idle"] = {"idle", 5, true}
}

SWEP.TimedSoundsSelf = {
	{"weapons/universal/uni_crawl_l_02.wav", 0.3},
	{"cof/weapons/syringe/syringe_insert.wav", 1.0},
	{"cof/weapons/syringe/syringe_inject.wav", 1.8}
}

SWEP.TimedSoundsOther = {
	{"cof/weapons/syringe/syringe_insert.wav", 0.5},
	{"cof/weapons/syringe/syringe_inject.wav", 1.2}
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""
SWEP.FallSnd = ""
SWEP.HoldType = "slam"
SWEP.showstats = false

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:InitAdd()
	self.modeValues = {
		[1] = 1
	}
end

function SWEP:Deploy()
	if self.DeploySounds and #self.DeploySounds > 0 then
		self.DeploySnd = self.DeploySounds[math.random(#self.DeploySounds)]
	end

	local snd = self.DeploySnd
	self.DeploySnd = ""
	local base = weapons.GetStored(self.Base)
	if base and base.Deploy then
		local ret = base.Deploy(self)
		local owner = self:GetOwner()
		if SERVER and snd and snd ~= "" and not self._deploySndPlayed and IsValid(owner) and not owner.noSound then
			self._deploySndPlayed = true
			owner:EmitSound(snd, 65, math.random(95, 105))
		end
		return ret
	end

	return true
end


function SWEP:Holster()
	self._deploySndPlayed = false
	self:SetHealingOther(false)
	self.setlh = true
	self._animStarted = false
	self.reverseanim = false
	self.healing = false
	self.callback = nil
	self.healbuddy = nil
	self.healingButton = nil
	self._wasInUse = false
	hook.Remove("Think", "AnimCallback" .. self:EntIndex())
	return true
end

function SWEP:Think()
	self:SetBodyGroups("11")
	if hg.SWEPEditor_Apply then hg.SWEPEditor_Apply(self) end

	local curTime = CurTime()
	local anim = self.anim
	local inUse = anim == "use" and self.animtime and self.animtime > curTime

	if not IsFirstTimePredicted() then return end

	if inUse ~= self._wasInUse then
		self._wasInUse = inUse
		if inUse then
			self._soundIdx = 1
			self.TimedSounds = self:GetHealingOther() and self.TimedSoundsOther or self.TimedSoundsSelf
			self._timedSndCache = nil

			if self.TimedSounds and #self.TimedSounds > 0 then
				local sorted = {}
				for _, data in ipairs(self.TimedSounds) do
					if data[1] ~= "" then sorted[#sorted + 1] = {data[1], data[2]} end
				end
				table.sort(sorted, function(a, b) return a[2] < b[2] end)
				self._timedSndCache = sorted
				self._timedSndCount = #sorted
			end
		end
	end

	if inUse and self.animtime and self.animspeed and self._timedSndCache then
		local elapsed = self.animspeed - (self.animtime - curTime)
		local idx = self._soundIdx or 1
		while idx <= self._timedSndCount and elapsed >= self._timedSndCache[idx][2] do
			local data = self._timedSndCache[idx]
			idx = idx + 1
			if CLIENT then
				local owner = self:GetOwner()
				if IsValid(owner) then owner:EmitSound(data[1], 60, math.random(95, 105), 1, CHAN_STATIC) end
			end
		end
		self._soundIdx = idx
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if not self.healing and anim == "deploy" and self.animtime and self.animtime <= curTime and SERVER then
		self:PlayAnim("idle")
	end

	if self.healing and not self._animStarted then
		local buttonHeld = self.healingButton and owner:KeyDown(self.healingButton)
		if buttonHeld and self.modeValues[1] > 0 then
			self._animStarted = true
			if SERVER then self:PlayAnim("use", self.UseSpeed, false, nil, false) end
		else
			self.healing = false
			self:SetHealingOther(false)
			self.setlh = true
		end
	end

	if self.healing and (not self.healingButton or not owner:KeyDown(self.healingButton)) then
		self.healing = false
		self:SetHealingOther(false)
		self.setlh = true
		self._animStarted = false
		self.callback = nil
		self.healbuddy = nil
		self.healingButton = nil
		hook.Remove("Think", "AnimCallback" .. self:EntIndex())
		if self.modeValues[1] > 0 then
			if SERVER then self:ReverseAnimToIdle("use") end
		elseif SERVER then
			self:PlayAnim("idle")
		end
	end

	self:ThinkReverseAnimToIdle(curTime)
end

function SWEP:SetHandPos(noset)
	self.setlh = not self:GetHealingOther()
	return self.BaseClass.SetHandPos(self, noset)
end

function SWEP:PostSetHandPos()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local ent = hg.GetCurrentCharacter(ply)
	if not IsValid(ent) then return end

	local rhBone = ent:LookupBone("ValveBiped.Bip01_R_Hand")
	if rhBone then
		local mat = ent:GetBoneMatrix(rhBone)
		if mat then
			local pos = mat:GetTranslation() + self.handPosOffset
			local ang = mat:GetAngles()
			ang.p = ang.p + self.handAngOffset.p
			ang.y = ang.y + self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(rhBone, mat)
		end
	end

	if not self.lhandik then return end

	local lhBone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
	if lhBone then
		local mat = ent:GetBoneMatrix(lhBone)
		if mat then
			local pos = mat:GetTranslation()
			local offset = self.handPosOffset
			pos.x = pos.x - offset.x
			pos.y = pos.y - offset.y
			pos.z = pos.z + offset.z
			local ang = mat:GetAngles()
			ang.p = ang.p - self.handAngOffset.p
			ang.y = ang.y - self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(lhBone, mat)
		end
	end
end

function SWEP:NPCHeal(npc, mul, snd)
	npc = npc or self:GetOwner()
	if not IsValid(npc) or not npc:IsNPC() then return end

	self:SetHold("melee")
	mul = mul or 0.3
	npc:SetHealth(math.Clamp(npc:Health() + npc:GetMaxHealth() * mul, 0, npc:GetMaxHealth() * math.Clamp(2 * mul, 2, 100)))
	npc:EmitSound(snd or "snd_jack_hmcd_bandage.wav", 75, math.random(95, 105))
	if SERVER then self:Remove() end
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:SpawnGarbage(nil, nil, nil, nil, "2211")
		self:NPCHeal(owner, 0.1, "snd_jack_hmcd_bandage.wav")
		return
	end

	local base = weapons.GetStored(self.Base)
	if base and base.OwnerChanged then base.OwnerChanged(self) end
end

if SERVER then
	function SWEP:PrimaryAttack()
		if self.healing then return end
		local owner = self:GetOwner()
		if not IsValid(owner) or self.modeValues[1] <= 0 then return end

		self:SetHealingOther(false)
		self.setlh = true
		self.healingButton = IN_ATTACK
		self.healing = true
	end

	function SWEP:SecondaryAttack()
		if self.healing then return end
		local owner = self:GetOwner()
		if not IsValid(owner) or self.modeValues[1] <= 0 then return end

		local tr = hg.eyeTrace(owner)
		if not tr or not IsValid(tr.Entity) then return end

		local ent = tr.Entity
		if hg.GetCurrentCharacter(ent) == hg.GetCurrentCharacter(owner) then return end
		if not (ent:IsPlayer() or ent:IsNPC() or hg.RagdollOwner(ent)) then return end

		self.healbuddy = ent
		self:SetHealingOther(true)
		self.setlh = false
		self.healingButton = IN_ATTACK2
		self.healing = true
	end

	function SWEP:Heal(ent)
		if ent:IsNPC() then
			self:SpawnGarbage(nil, nil, nil, nil, "2211")
			self:NPCHeal(ent, 0.1, "snd_jack_hmcd_bandage.wav")
			return true
		end

		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local patient = IsValid(org.owner) and org.owner or ent
		local entOwner = IsValid(patient.FakeRagdoll) and patient.FakeRagdoll or patient
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))
		org.needle = 1

		if not (org.lungsR[2] == 1 or org.lungsL[2] == 1) then
			if math.random(2) == 1 then
				org.lungsR[2] = 1
			else
				org.lungsL[2] = 1
			end
		end

		self.healing = false
		self:SetHealingOther(false)
		self.setlh = true
		self.healingButton = nil
		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()
			self.poisoned2 = nil
		end

		owner:SelectWeapon("weapon_hands_sh")
		self:SpawnGarbage(nil, nil, nil, nil, "2211")
		self:Remove()
		return true
	end
end
