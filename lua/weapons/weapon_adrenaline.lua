if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Epinephrine Autoinjector"
SWEP.Instructions = "Adrenaline, also known as epinephrine, is a hormone and medication which is involved in regulating visceral functions. Use this to increase blood pressure and/or stop cardiac arrest. RMB to inject into someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cof/weapons/syringe/w_syringe.mdl"
SWEP.WorldModelReal = "models/cof/weapons/syringe/v_syringe.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_adrenaline")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_adrenaline.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Slot = 5
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

SWEP.offsetVec = Vector(0, 0, 0)
SWEP.offsetAng = Angle(0, 0, 0)

SWEP.lpos = Vector(0, 0, 0)
SWEP.lang = Angle(0, 0, 0)

SWEP.handPosOffset = Vector(0, 0, 0)
SWEP.handAngOffset = Angle(0, 0, 0)

SWEP.modeNames = {
	[1] = "adrenaline"
}

SWEP.UseSpeed = 3
SWEP.CallbackTimeAdjust = 0.5

SWEP.AnimList = {
	["deploy"] = { "deploy", 0.5, false },
	["use"] = { "use", 3, false, false, function(self)
		if CLIENT then return end
		if self:GetHealingOther() and IsValid(self.healbuddy) then
			self:Heal(self.healbuddy)
		else
			self:Heal(self:GetOwner())
		end
	end },
	["idle"] = { "idle", 5, true }
}

SWEP.TimedSoundsSelf = {
	{"weapons/universal/uni_crawl_l_02.wav", 0.3},
	{"snd_jack_hmcd_needleprick.wav", 0.8},
	{"cof/weapons/syringe/syringe_insert.wav", 1.0},
	{"cof/weapons/syringe/syringe_inject.wav", 1.8},
}

SWEP.TimedSoundsOther = {
	{"cof/weapons/syringe/syringe_insert.wav", 0.5},
	{"cof/weapons/syringe/syringe_inject.wav", 1.2},
}

SWEP.modeValuesdef = {
	[1] = 1,
}

SWEP.showstats = false
SWEP.FallSnd = ""

SWEP.HoldType = "slam"

local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)

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
		if SERVER and snd and snd ~= "" and not self._deploySndPlayed and self:GetOwner() and not self:GetOwner().noSound then
			self._deploySndPlayed = true
			self:GetOwner():EmitSound(snd, 65, math.random(95, 105))
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

	if self.healing then
		self.healing = false
		self.callback = nil
		hook.Remove("Think", "AnimCallback" .. self:EntIndex())
		self._wasInUse = false
	end
	return true
end

function SWEP:Think()
	if hg.SWEPEditor_Apply then hg.SWEPEditor_Apply(self) end

	local curTime = CurTime()
	local anim = self.anim

	local inUse = anim == "use" and self.animtime and self.animtime > curTime

	if not IsFirstTimePredicted() then return end

	if inUse ~= self._wasInUse then
		self._wasInUse = inUse
		if inUse then
			self._timedApplied = {}
			self._soundIdx = 1

			self.TimedSounds = self:GetHealingOther() and self.TimedSoundsOther or self.TimedSoundsSelf
			self._timedSndCache = nil

			if self.TimedSounds and #self.TimedSounds > 0 then
				local sorted = {}
				for i, data in ipairs(self.TimedSounds) do
					if data[1] ~= "" then
						sorted[#sorted + 1] = {data[1], data[2]}
					end
				end
				table.sort(sorted, function(a, b) return a[2] < b[2] end)
				self._timedSndCache = sorted
				self._timedSndCount = #sorted
			end
		end
	end

	if inUse and self.animtime and self.animspeed then
		local elapsed = self.animspeed - (self.animtime - curTime)

		if self._timedSndCache then
			local idx = self._soundIdx or 1
			local cache = self._timedSndCache
			local count = self._timedSndCount
			while idx <= count and elapsed >= cache[idx][2] do
				local data = cache[idx]
				idx = idx + 1
				if CLIENT then
					local owner = self:GetOwner()
					if IsValid(owner) then
						owner:EmitSound(data[1], 60, math.random(95, 105), 1, CHAN_STATIC)
					end
				end
			end
			self._soundIdx = idx
		end
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if not self.healing and anim == "deploy" and self.animtime and self.animtime <= curTime then
		if SERVER then
			self:PlayAnim("idle")
		end
	end

	if self.healing and not self._animStarted then
		local buttonHeld = owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)
		if buttonHeld and self.modeValues[1] > 0 then
			self._animStarted = true
			if SERVER then
				self:PlayAnim("use", self.UseSpeed, false, nil, false)
			end
		elseif not buttonHeld then
			self.healing = false
			self:SetHealingOther(false)
			self.setlh = true
		end
	end

	if self.healing and not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2) then
		self.healing = false
		self:SetHealingOther(false)
		self.setlh = true
		self._animStarted = false
		self.callback = nil
		hook.Remove("Think", "AnimCallback" .. self:EntIndex())
		if SERVER then
			if self.modeValues[1] > 0 then
				self.reverseanim = true
			else
				self:PlayAnim("idle")
			end
		end
		if CLIENT then
			if self.modeValues[1] > 0 then
				self.reverseanim = true
			end
		end
	end

	if self.reverseanim and self.animtime and self.animtime <= curTime then
		self.reverseanim = false
		if SERVER then
			self:PlayAnim("idle")
		end
	end
end

function SWEP:SetHandPos(noset)
	if self:GetHealingOther() then
		self.setlh = false
	else
		self.setlh = true
	end

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

if SERVER then
	function SWEP:PrimaryAttack()
		if self.healing then return end
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if self.modeValues[1] <= 0 then return end

		self:SetHealingOther(false)
		self.setlh = true
		self.healing = true
	end

	function SWEP:SecondaryAttack()
		if self.healing then return end
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if self.modeValues[1] <= 0 then return end

		local tr = hg.eyeTrace(owner)
		if not tr then return end

		local ent = tr.Entity
		if not IsValid(ent) then return end

		local chr = hg.GetCurrentCharacter(ent)
		if chr == hg.GetCurrentCharacter(owner) then return end
		if not (ent:IsPlayer() or ent:IsNPC() or hg.RagdollOwner(ent)) then return end

		self.healbuddy = ent
		self:SetHealingOther(true)
		self.setlh = false
		self.healing = true
	end

	function SWEP:Heal(ent)
		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end

		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner

		local mode = self.modeValues and self.modeValues[1] or self.modeValuesdef[1]

		org.adrenalineAdd = math.Approach(org.adrenalineAdd or 0, 4, mode * 4)

		if self.poisoned2 then
			org.poison4 = CurTime()
			self.poisoned2 = nil
		end

		self.healing = false
		self:SetHealingOther(false)
		self.setlh = true

		self.modeValues[1] = 0

		if self.modeValues[1] == 0 then
			owner:DropWeapon(self)
			owner:SelectWeapon("weapon_hg_coolhands")
		end

		return true
	end
end
