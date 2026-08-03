if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_hg_grenade_tpik"
SWEP.PrintName = "EFT Grenade Base"
SWEP.Spawnable = false
SWEP.AdminOnly = false

SWEP.Category = "Weapons - Explosive"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.HoldType = "camera"
SWEP.ViewModel = ""
SWEP.WorkWithFake = true
SWEP.WorldModelExchange = false
SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.spoon = "models/weapons/m67_skoba.mdl"

SWEP.AnimsEvents = {
	["draw"] = {
		[0.1] = function(self)
			self:EmitSound("weapons/darsu_eft/grenades/rgd_draw.ogg", 65)
		end,
	},
	["fire_start"] = {
		[0.31] = function(self)
			self:EmitSound("weapons/darsu_eft/grenades/rgd_pin.ogg", 65)
		end,
	},
}

function SWEP:ConsumeThrownGrenade()
	timer.Simple(0.6, function()
		if not IsValid(self) then return end

		self.count = self.count - 1
		if self.count < 1 then
			local owner = self:GetOwner()
			if IsValid(owner) and owner:IsPlayer() then owner:SelectWeapon("weapon_hands_sh") end
			self:Remove()
			return
		end

		self:PlayAnim("idle")
		self:SetShowSpoon(true)
		self:SetShowGrenade(true)
		self:SetShowPin(true)
	end)
end

function SWEP:ThrowHigh()
	if CLIENT then return end

	self:Throw(1200, self.SpoonTime or CurTime(), nil, Vector(2, 4, 0), Angle(-40, 0, 0))
	self.InThrowing = false
	self.ReadyToThrow = false
	self.SpoonTime = false
	self.Spoon = true
	self:ConsumeThrownGrenade()
end

function SWEP:ThrowLow()
	if CLIENT then return end

	self:Throw(600, self.SpoonTime or CurTime(), nil, Vector(0, 4, -6), Angle(40, 0, 0))
	self.InThrowing = false
	self.ReadyToThrow = false
	self.IsLowThrow = false
	self.SpoonTime = false
	self.Spoon = true
	self:ConsumeThrownGrenade()
end

SWEP.AnimList = {
	["deploy"] = {"draw", 1.1, false},
	["attack"] = {"fire1", 1, false, false, function(self) self:ThrowHigh() end, 0.65},
	["attack2"] = {"fire2", 0.8, false, false, function(self) self:ThrowLow() end, 0.6},
	["pullbackhigh"] = {"fire_start", 1.5, false, false, function(self)
		self:SetShowPin(false)
		self.ReadyToThrow = true
	end, 0.8},
	["pullbacklow"] = {"fire_start", 1.5, false, false, function(self)
		self:SetShowPin(false)
		self.IsLowThrow = true
		self.ReadyToThrow = true
	end, 0.8},
	["revers_pullbackhigh"] = {"fire_abort", 1, false},
	["revers_pullbacklow"] = {"fire_abort", 1, false},
	["trapplace"] = {"mine_fire", 1.8, false, false, function(self)
		self.ReadyToTrap = true
	end},
	["idle"] = {"fire_idle", 1, true},
}

SWEP.HoldPos = Vector(-2, -1, -1.5)
SWEP.HoldAng = Angle(0, 0, 0)
SWEP.NoTrap = false
SWEP.ViewBobCamBase = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewBobCamBone = "ValveBiped.Bip01_R_Hand"
SWEP.ViewPunchDiv = 1500
SWEP.CallbackTimeAdjust = 0.1
SWEP.traceLen = 5
SWEP.ItemsBones = {
	["Grenade"] = {88},
	["Pin"] = {92},
}
SWEP.CoolDown = 0
SWEP.SpoonSounds = {
	[1] = {"snd_jack_spoonfling.ogg", 65},
	[2] = {"weapons/darsu_eft/grenades/gren_fuze1.ogg", 70, 200, true},
}
