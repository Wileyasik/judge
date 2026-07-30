if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.PrintName = "Midazolam Autoinjector"
SWEP.Instructions = "Stops seizures. Must be administered to someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl"
SWEP.Model = "models/weapons/w_models/w_jyringe_jroj.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/seizurestopper.png")
	SWEP.IconOverride = "vgui/seizurestopper.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(5, -1.5, -2.5)
SWEP.offsetAng = Angle(90, 00, -90)
SWEP.modeNames = {
	[1] = "midazolam"
}

function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	self.modeValues = {
		[1] = 1
	}
end

SWEP.modeValuesdef = {
	[1] = 1
}

SWEP.DeploySnd = ""
SWEP.HolsterSnd = ""

SWEP.showstats = false

local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)

function SWEP:Think()
	if not self:GetOwner():KeyDown(IN_ATTACK) and hg_healanims:GetBool() then
		self:SetHolding(math.max(self:GetHolding() - 4, 0))
	end
end

function SWEP:Animation()
	local hold = self:GetHolding()
    self:BoneSet("r_upperarm", vector_origin, Angle(0, -hold + (100 * (hold / 100)), 0))
    self:BoneSet("r_forearm", vector_origin, Angle(-hold / 6, -hold * 2, -15))
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:SpawnGarbage("models/bloocobalt/l4d/items/w_eq_adrenaline.mdl", nil, nil, nil, "2211")
		self:NPCHeal(owner, 0.1, "snd_jack_hmcd_needleprick.wav")
	end
end

if SERVER then
	util.AddNetworkString("rem_midazolam_seizure")

	function SWEP:Heal(ent, mode)
		local org = ent.organism
		if not org then return end

		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if not IsValid(org.owner) or not org.owner:IsPlayer() then return end
		if org.owner == owner then return end

		local victim = org.owner
		local victimDeaths = victim:Deaths()

		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 4, 100))

			if self:GetHolding() < 100 then return end
		end

		local entOwner = IsValid(org.owner.FakeRagdoll) and org.owner.FakeRagdoll or org.owner
		entOwner:EmitSound("snd_jack_hmcd_needleprick.wav", 60, math.random(95, 105))

		if org.seizureActive then
			org.seizureEnd = math.max(org.seizureEnd or 0, CurTime() + 16)
			net.Start("rem_midazolam_seizure")
			net.Send(victim)

			timer.Simple(15, function()
				if not IsValid(victim) or not victim:Alive() or victim:Deaths() ~= victimDeaths or victim.organism ~= org then return end
				org.seizure = 0
				org.seizureActive = false
				org.seizureStart = 0
				org.seizureEnd = 0
				org.nextSeizureSpasm = 0
				org.consciousness = 0
				victim.fakecd = 0
				victim.fullsend = true
				if hg.send_organism then hg.send_organism(org, victim) end
			end)
		else
			for i = 1, 12 do
				timer.Simple(i * 2, function()
					if not IsValid(victim) or not victim:Alive() or victim:Deaths() ~= victimDeaths or victim.organism ~= org then return end
					local frac = i / 12
					org.bloodPressure = math.min(org.bloodPressure or 90, Lerp(frac, 90, 18))
					org.pulse = math.min(org.pulse or 70, Lerp(frac, 70, 18))
					org.hypotension = math.max(org.hypotension or 0, frac)
					if org.o2 then org.o2[1] = math.min(org.o2[1] or 30, Lerp(frac, 30, 4)) end
					if i == 12 and hg.organism.StartFibrillation then hg.organism.StartFibrillation(org) end
				end)
			end
		end

		self.modeValues[1] = 0

		if self.poisoned2 then
			org.poison4 = CurTime()

			self.poisoned2 = nil
		end

		if self.modeValues[1] == 0 then
			owner:SelectWeapon("weapon_hands_sh")
			--!! self:SpawnGarbage() add this when port dayz models
			self:Remove()
		end
	end
end

if CLIENT then
	local midazolamSnd

	net.Receive("rem_midazolam_seizure", function()
		if REM_MidazolamSeizureFade then REM_MidazolamSeizureFade(15) end

		if IsValid(midazolamSnd) then midazolamSnd:Stop() end
		midazolamSnd = CreateSound(LocalPlayer(), "rem_youarebetteroffdead.mp3")
		midazolamSnd:PlayEx(0, 100)
		midazolamSnd:ChangeVolume(1, 15)

		LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(255, 255, 255, 255), 15, 1)
	end)
end
