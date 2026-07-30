SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "FN40GL"
SWEP.Author = "FN Herstal"
SWEP.Instructions = "Standalone 40mm grenade launcher"
SWEP.Category = "Weapons - Grenade Launchers"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_fn40gl.mdl"
SWEP.CanCustomize = true
SWEP.CustomizeCategory = "FN40GL"

SWEP.FakePos = Vector(-18, 2.5, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(-0.5, 0, -6.5)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "11"

SWEP.FakeVPShouldUseHand = true
SWEP.CantFireFromCollision = true

SWEP.StartAtt = {"14"}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 40

SWEP.AnimList = {
	["deploy"] = { "draw", 1.1, false },
	["idle"] = "idle",
	["reload"] = "reload",
	["reload_empty"] = "reload",
	["inspect"] = "look",
}

SWEP.AnimsEvents = {
	["reload"] = {
		[0.10] = function(self) self:EmitSound("weapons/darsu_eft/fn40/fn40gl_tube_button.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/fn40/fn40gl_tube_open.ogg") end,
		[0.25] = function(self) self:EmitSound("weapons/darsu_eft/fn40/fn40gl_grenade_remove.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/fn40/fn40gl_grenade_insert.ogg") end,
		[0.75] = function(self) self:EmitSound("weapons/darsu_eft/fn40/fn40gl_tube_close.ogg") end,
	},
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.weaponInvCategory = 1
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 2
SWEP.Primary.Ammo = "40mm Grenade M381"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/fn40/fn40gl_fire_close.ogg", 100, 50, 50}
SWEP.SupressedSound = {"weapons/darsu_eft/fn40/fn40gl_fire_close.ogg", 100, 50, 50}
SWEP.Primary.Force = 25
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.8, 4)
SWEP.RHandPos = Vector(0, 0, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1
SWEP.Penetration = 7

SWEP.weight = 3
SWEP.ScrappersSlot = "Primary"

SWEP.punchmul = 8
SWEP.punchspeed = 6
SWEP.podkid = 1
SWEP.Supressor = true
SWEP.SetSupressor = true
SWEP.CanEpicRun = true
SWEP.EpicRunPos = Vector(5, 3, -5)

SWEP.WorldPos = Vector(1, -1.2, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 6.5)
SWEP.attAng = Angle(0, -0.2, 0)
SWEP.lengthSub = 25
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(5, 0, -6)
SWEP.holsteredAng = Angle(0, 0, 0)
SWEP.shouldntDrawHolstered = false

SWEP.RHPos = Vector(12, -4.5, 3)
SWEP.RHAng = Angle(0, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)

SWEP.ShootAnimMul = 3

SWEP.LocalMuzzlePos = Vector(9, -1.7, -0.88)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.WepSelectIcon2 = Material("entities/weapon_hg_eft_fn40gl.png")
SWEP.IconOverride = "entities/weapon_hg_eft_fn40gl.png"

SWEP.StartAtt = {"holo14"}
SWEP.availableAttachments = {
	sight = {
		["mountType"] = "picatinny",
		["mount"] = {picatinny = Vector(-13, 3.65, 0.05)},
	},
	underbarrel = {
		["mount"] = {["picatinny_small"] = Vector(6, 2.5, -2)},
		["mountAngle"] = {["picatinny_small"] = Angle(-1, -0.3, -180)},
		["mountType"] = {"picatinny_small"},
	}
}

SWEP.CustomShell = ""
SWEP.ShellEject = nil
SWEP.OpenBolt = true
SWEP.AutomaticDraw = false
SWEP.drawBullet = true

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:ModelCreated(model)
	if not CLIENT then return end
	if not IsValid(model) then return end
	if not self.FakeBodyGroups then return end

	model:SetBodyGroups(self.FakeBodyGroups)

	for i = 0, #model:GetMaterials() - 1 do
		model:SetSubMaterial(i, "")
	end
end

function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() ~= LocalPlayer() and not override then return false end

	local primary = self.Primary
	if not self.drawBullet then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		return false
	end

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end
	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic

	local gun = self:GetWeaponEntity()
	local tr, pos, ang = self:GetTrace(true)
	self:TakePrimaryAmmo(1)

	local owner = self:GetOwner()
	if SERVER then
		local projectile = ents.Create("ent_40x46_m381")
		projectile.owner = owner
		projectile:SetPos(pos + ang:Forward() * 0 + ang:Right() * 1.5 + ang:Up() * 0)
		projectile:SetAngles(ang)
		local owncheck = IsValid(owner) and (owner:IsNPC() and owner or owner:InVehicle() and owner:GetVehicle())
		projectile:SetOwner(IsValid(owner) and (owncheck or owner) or self)
		projectile:Spawn()
		projectile.Penetration = -(-self.Penetration)

		local phys = projectile:GetPhysicsObject()
		if IsValid(phys) then
			local initialVelocity = owner:GetVelocity() + ang:Forward() * 2992
			phys:SetVelocity(initialVelocity)
			phys:EnableGravity(false)
			timer.Simple(0, function()
				if IsValid(projectile) and IsValid(phys) then
					phys:EnableGravity(true)
				end
			end)
		end
	end

	self:EmitShoot()
	self:PrimarySpread()

	self.drawBullet = false
	if self.AutomaticDraw then self:Draw() end
end

function SWEP:PrimaryShootPost()
	self.drawBullet = true

	if not CLIENT then return end
	if self.reload then return end
	if not self:ShouldUseFakeModel() then return end

	local worldModel = self:GetWM()
	if not IsValid(worldModel) then return end

	local selectedSequence
	for _, sequenceName in ipairs({"fire"}) do
		local sequenceID = worldModel:LookupSequence(sequenceName)
		if sequenceID ~= nil and sequenceID >= 0 then
			selectedSequence = sequenceName
			break
		end
	end

	if not selectedSequence then return end

	self:PlayAnim(selectedSequence, 0.15, false)

	timer.Create("BC_FireAnimation_" .. self:EntIndex(), 0.15, 1, function()
		if not IsValid(self) or self.reload then return end
		if self.Primary and (self.Primary.Next or 0) > CurTime() then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end

SWEP.InspectAnimWepAng = {
	Angle(0, 0, 0),
	Angle(4, 4, 15),
	Angle(10, 15, 25),
	Angle(10, 15, 25),
	Angle(10, 15, 25),
	Angle(-6, -15, -15),
	Angle(1, 15, -45),
	Angle(15, 25, -55),
	Angle(15, 25, -55),
	Angle(15, 25, -55),
	Angle(0, 0, 0),
	Angle(0, 0, 0)
}