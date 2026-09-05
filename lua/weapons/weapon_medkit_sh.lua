if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_bandage_sh"
SWEP.BandageTPIK = false
SWEP.PrintName = "Medkit"
SWEP.Instructions = "A military medkit. Contains some usefull medicine ig?."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/w_models/weapons/w_eq_medkit.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_medkit")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_medkit.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.offsetVec = Vector(4, -0.5, -3)
SWEP.offsetAng = Angle(-30, 20, 90)
SWEP.modes = 1
SWEP.modeNames = {
	[1] = "open",
}
SWEP.showstats = false
SWEP.ofsV = Vector(-2,-10,8)
SWEP.ofsA = Angle(90,-90,90)
function SWEP:InitializeAdd()
	self:SetHold(self.HoldType)

	self.modeValues = {
		[1] = 1,
	}
end

SWEP.modeValuesdef = {
	[1] = {1,false},
}
SWEP.ShouldDeleteOnFullUse = true

local math = math
local hg_healanims = ConVarExists("hg_healanims") and GetConVar("hg_healanims") or CreateConVar("hg_healanims", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)
function SWEP:Think()
	if not self:GetOwner():KeyDown(IN_ATTACK) and hg_healanims:GetBool() then
		self:SetHolding(math.max(self:GetHolding() - 12, 0))
	end
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local owner = self:GetOwner()
	if (owner.zmanipstart ~= nil and not ( owner.organism and owner.organism.larmamputated )) then return end

	local aimvec = owner:GetAimVector()
	if not aimvec then return end

	local hold = self:GetHolding()
	local ducking = owner:IsFlagSet(FL_ANIMDUCKING)

    self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 5, -30 + hold / 2 + 20 * aimvec[3] * (ducking and -3 or -1), 5 - hold / 4))
    self:BoneSet("r_forearm", vector_origin, Angle(hold / 25, -hold / 2.5, 35 -hold / 1.4))

    self:BoneSet("l_upperarm", vector_origin, lang1)
    self:BoneSet("l_forearm", vector_origin, lang2)
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:SpawnGarbage()
		self:NPCHeal(owner, 0.6, "snd_jack_hmcd_bandage.wav")
	end
end

if SERVER then
	SWEP.MedkitLootPool = {
		{weight = 30, class = "weapon_bigbandage_sh"},
		{weight = 25, class = "weapon_painkillers_tpik"},
		{weight = 18, class = "weapon_tourniquet"},
		{weight = 12, class = "weapon_adrenaline"},
		{weight = 10, class = "weapon_betablock_tpik"},
		{weight = 7, class = "weapon_morphine"},
		{weight = 7, class = "weapon_mannitol"},
		{weight = 6, class = "weapon_naloxone"},
		{weight = 6, class = "weapon_midazolam"},
		{weight = 5, class = "weapon_bloodbag"},
		{weight = 5, class = "weapon_thiamine_tpik"},
	}

	function SWEP:PickMedkitLoot()
		local total = 0
		for _, item in ipairs(self.MedkitLootPool) do total = total + item.weight end

		local roll = math.random(total)
		for _, item in ipairs(self.MedkitLootPool) do
			roll = roll - item.weight
			if roll <= 0 then return item.class end
		end

		return self.MedkitLootPool[1].class
	end

	function SWEP:DropMedkitLoot(class)
		local owner = self:GetOwner()
		local pos = owner:EyePos() + owner:GetAimVector() * 40

		local wep = ents.Create(class)
		if not IsValid(wep) then return end

		wep:Spawn()
		wep:SetPos(pos)
		wep:SetAngles(AngleRand(-180, 180))
		wep.IsSpawned = true

		local phys = wep:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(owner:GetAimVector() * 100 + VectorRand(-30, 30))
		end
	end

	function SWEP:OpenMedkit()
		if self.opened then return end
		self.opened = true

		local owner = self:GetOwner()
		if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then self:Remove() return end

		local loot = {}
		loot[#loot + 1] = "weapon_bandage_sh"
		loot[#loot + 1] = "weapon_needle"

		local extra = math.random(1, 2)
		for i = 1, extra do
			loot[#loot + 1] = self:PickMedkitLoot()
		end

		local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		entOwner:EmitSound("items/suit_power_up.wav", 40, math.random(95, 105))

		for _, class in ipairs(loot) do
			if owner:HasWeapon(class) then
				self:DropMedkitLoot(class)
			else
				owner:Give(class)
			end
		end

		owner:SelectWeapon("weapon_hands_sh")
		self:Remove()
	end

	function SWEP:PrimaryAttack()
		self:OpenMedkit()
	end

	function SWEP:SecondaryAttack()
		self:OpenMedkit()
	end

	function SWEP:Reload()
	end
end
