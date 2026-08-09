if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_fentanyl"
SWEP.PrintName = "Desomorphine"
SWEP.Instructions = "A destructive opioid that provides strong analgesia while poisoning the body. A full dose guarantees paralysis of a random limb; a partial dose can cause it as well. Hold LMB to inject yourself, hold RMB on someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_fent.png")
	SWEP.IconOverride = "vgui/icons/ico_fent.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Slot = 5
SWEP.SlotPos = 2
SWEP.AnalgesiaPerDose = 2.5
SWEP.MaxAnalgesia = 4

SWEP.modeNames = {
	[1] = "desomorphine"
}

local limbs = {"larm", "rarm", "lleg", "rleg"}

local function paralyzeRandomLimb(org)
	org.desomorphineParalyzedLimbs = org.desomorphineParalyzedLimbs or {}

	local available = {}
	for _, limb in ipairs(limbs) do
		if not org.desomorphineParalyzedLimbs[limb]
			and not org[limb .. "amputated"]
			and not org[limb .. "upamputated"] then
			available[#available + 1] = limb
		end
	end

	if #available == 0 then return end

	local limb = available[math.random(#available)]
	org.desomorphineParalyzedLimbs[limb] = true
	org[limb] = 1

	if (limb == "larm" or limb == "rarm") and hg.fakeBoneFlop then
		hg.fakeBoneFlop.SetLimbSegmentState(org, limb, "up", true)
		hg.fakeBoneFlop.SetLimbSegmentState(org, limb, "down", true)

		local owner = org.owner
		if IsValid(owner) and IsValid(owner.FakeRagdoll) then
			hg.fakeBoneFlop.ScheduleRebuild(owner)
		end
	end

	org.immobilization = math.max(org.immobilization or 0, 20)

	local owner = org.owner
	if IsValid(owner) and owner.Notify then
		owner:Notify("One of my limbs has gone numb and stopped responding.", 4, "desomorphine_paralysis", 5)
	end
end

function SWEP:InitAdd()
	local base = weapons.GetStored(self.Base)
	if base and base.InitAdd then base.InitAdd(self) end

	self.DesomorphineRecipients = {}
end

function SWEP:Think()
	local owner = self:GetOwner()
	local recipient
	if SERVER and IsValid(owner) then
		recipient = self:GetHealingOther() and IsValid(self.healbuddy) and self.healbuddy or owner
	end

	local doseBefore = SERVER and self:GetDose() or 0
	local base = weapons.GetStored(self.Base)
	if base and base.Think then base.Think(self) end
	if not SERVER or not IsValid(self) then return end

	local injected = math.max(doseBefore - self:GetDose(), 0)
	if injected <= 0 or not IsValid(recipient) or not recipient.organism then return end

	local org = recipient.organism
	self.DesomorphineRecipients = self.DesomorphineRecipients or {}
	local state = self.DesomorphineRecipients[org]
	if not state or state.life ~= org.desomorphineLife then
		state = {injected = 0, life = org.desomorphineLife}
		self.DesomorphineRecipients[org] = state
	end
	state.injected = state.injected + injected
	org.desomorphineToxicity = math.min((org.desomorphineToxicity or 0) + injected, 2)

	-- Partial injections build toward a 30% paralysis chance over one full dose.
	if not state.paralyzed and math.Rand(0, 1) <= 1 - math.pow(0.7, injected) then
		state.paralyzed = true
		paralyzeRandomLimb(org)
	end

	if not state.paralyzed and state.injected >= 0.99 then
		state.paralyzed = true
		paralyzeRandomLimb(org)
	end
end

if SERVER then
	hook.Add("Org Think", "desomorphine_toxicity", function(owner, org, timeValue)
		local toxicity = org.desomorphineToxicity or 0
		local active = org.desomorphineActive or 0
		local target = toxicity > 0 and toxicity or 0
		org.desomorphineActive = math.Approach(active, target, timeValue / (target > active and 120 or 180))
		active = org.desomorphineActive

		if toxicity > 0 then
			org.desomorphineToxicity = math.max(toxicity - timeValue / 300, 0)
		end

		if active > 0 and org.alive then

			local tissueDamage = active * timeValue
			org.lungsL[1] = math.min(org.lungsL[1] + tissueDamage / 180, 1)
			org.lungsR[1] = math.min(org.lungsR[1] + tissueDamage / 180, 1)
			org.liver = math.min((org.liver or 0) + tissueDamage / 300, 1)
			org.heart = math.min((org.heart or 0) + tissueDamage / 480, 1)
			org.internalBleed = math.min((org.internalBleed or 0) + tissueDamage / 48, 12)

			-- Acute opioid respiratory depression makes oxygen loss outpace recovery.
			if org.o2 then
				org.o2[1] = math.max(org.o2[1] - tissueDamage * 0.11, 0)
			end
			if hg.organism.AddCardiacStress then
				hg.organism.AddCardiacStress(org, tissueDamage / 1300)
			end
		end

		for limb in pairs(org.desomorphineParalyzedLimbs or {}) do
			if not org[limb .. "amputated"] and not org[limb .. "upamputated"] then
				org[limb] = 1
			end
		end
	end)

	hook.Add("Org Clear", "desomorphine_clear", function(org)
		org.desomorphineToxicity = nil
		org.desomorphineActive = nil
		org.desomorphineParalyzedLimbs = nil
		org.desomorphineLife = (org.desomorphineLife or 0) + 1
	end)
end
