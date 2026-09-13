if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "Ammo Crate"
SWEP.Instructions = "Press LMB to take ammo for your weapons"
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

if CLIENT then
	SWEP.WepSelectIcon = Material("spawnicons/models/props_junk/wood_crate001a.png")
	SWEP.IconOverride = "spawnicons/models/props_junk/wood_crate001a.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.5

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/Items/item_item_crate.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "slam"
SWEP.WorkWithFake = false

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.DefaultRHPosOffset = Vector(-0.5,-2,-5)
SWEP.DefaultRHAngOffset = Angle(0,45,-55)

SWEP.DefaultLHPosOffset = Vector(0,-4,-2)
SWEP.DefaultLHAngOffset = Angle(5,0,-35)

SWEP.RHPosOffset = SWEP.DefaultRHPosOffset
SWEP.RHAngOffset = SWEP.DefaultRHAngOffset

SWEP.LHPosOffset = SWEP.DefaultLHPosOffset
SWEP.LHAngOffset = SWEP.DefaultLHAngOffset

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(3,-2,2)
SWEP.offsetAng = Angle(0,0,115)

SWEP.ModelScale = 0.2
SWEP.DropScale = 0.5

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Magazines = 2

local function ResizeCratePhysics(wep)
	local scale = wep.DropScale or wep.ModelScale or 1
	wep:SetModelScale(scale)
	if scale == 1 then return end

	local mins, maxs = wep:OBBMins() * scale, wep:OBBMaxs() * scale
	if mins.x >= maxs.x or mins.y >= maxs.y or mins.z >= maxs.z then return end

	wep:SetCollisionBounds(mins, maxs)
	wep:PhysicsInitBox(mins, maxs)

	local phys = wep:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetMass(15)
		phys:Wake()
	end
end

function SWEP:Initialize()
	ResizeCratePhysics(self)
end

function SWEP:OnDrop()
	if (self.DropScale or self.ModelScale or 1) == 1 then return end
	timer.Simple(0, function()
		if not IsValid(self) then return end
		ResizeCratePhysics(self)
	end)
end

local function GetWeaponAmmoInfo(wep, magazines)
	local clip = wep.GetMaxClip1 and wep:GetMaxClip1() or -1
	if not clip or clip <= 0 then return end

	local ammo = wep.Primary and wep.Primary.Ammo or "none"
	if not ammo or ammo == "none" then ammo = wep.Ammo end
	if not ammo or ammo == "none" then return end

	local ammotype = hg.ammotypeshuy[ammo]
	if not ammotype then return end

	return clip * magazines, ammo, ammotype.maxcarry
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() or not owner:Alive() then return end
	if (self.UseCD or 0) > CurTime() then return end
	self.UseCD = CurTime() + self.Primary.Delay

	local given = false
	for _, wep in ipairs(owner:GetWeapons()) do
		local count, ammo, maxcarry = GetWeaponAmmoInfo(wep, self.Magazines)
		if count and owner:GetAmmoCount(ammo) < (maxcarry or math.huge) then
			owner:GiveAmmo(count, ammo, true)
			given = true
		end
	end

	if not given then return end

	owner:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(80, 90), 1, CHAN_ITEM)
	owner:ViewPunch(Angle(5, 0, 0))

	local class = self:GetClass()
	timer.Simple(0, function()
		if IsValid(owner) then owner:StripWeapon(class) end
	end)
end

function SWEP:SecondaryAttack()
end

if CLIENT then
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end

		local x, y = ScrW() / 2, ScrH() / 2 + 65
		local text = "Press LMB to take ammo"
		draw.SimpleText(text, "HomigradFont", x + 3, y + 2, color_black, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "HomigradFont", x, y, color_white, TEXT_ALIGN_CENTER)
	end
end
