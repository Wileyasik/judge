SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "PB"
SWEP.Author = "TsNIITochMash"
SWEP.Instructions = "A suppressed Soviet pistol chambered in 9x18mm Makarov"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_pb.mdl"
SWEP.FakeBodyGroups = "1111"
SWEP.FakeBodyGroupsPresets = {
	"1111",
}

SWEP.FakePos = Vector(-23, 2.5, 4)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, -0.2)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.MagIndex = nil
SWEP.SetSupressor = true
SWEP.SupressorOnly = true

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 1

SWEP.AnimList = {
	["idle"] = "base_idle",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "look",
}

SWEP.AnimsEvents = {
	["look"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
    ["reload"] = {
        [0.2] = function(self)
            self:EmitSound("weapons/darsu_eft/pm/pm_mag_out.ogg")
            self:EmitSound("arc9_eft_shared/generic_mag_pouch_in1.ogg")
        end,
        [0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
        [0.6] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_in.ogg") end,
    },
    ["reload_empty"] = {
        [0.005] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_slider_out.ogg") end,
		[0.15] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_out.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.48] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_mag_in.ogg") end,
		[0.68] = function(self) self:EmitSound("weapons/darsu_eft/pm/pm_slider_in.ogg") end,
    },
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_pm_8.mdl"
SWEP.ReloadTime = 3

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_pb.png")
SWEP.IconOverride = "entities/arc9_eft_pb.png"
SWEP.WepSelectIcon2box = true

SWEP.CustomShell = "9x18"

SWEP.weight = 1
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x18 mm"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 21
SWEP.Primary.Sound = {"weapons/darsu_eft/pm/pb_silenced_indoor_close1.wav", 65, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/pm/pb_silenced_indoor_close1.wav", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_hammer.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 12
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.PPSMuzzleEffect = "pcf_jack_mf_suppressed"

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(-3, -1.8, 2)
SWEP.RHandPos = Vector(-5, -1.5, 2)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0, -0.01, 0), Angle(-0.01, 0.01, 0)}
SWEP.Ergonomics = 1.1
SWEP.Penetration = 11.5
SWEP.ShockMultiplier = 1
SWEP.punchmul = 1.2
SWEP.punchspeed = 3.5

SWEP.LocalMuzzlePos = Vector(1.95, -1.8, 1.3)
SWEP.LocalMuzzleAng = Angle(0.398, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.WorldPos = Vector(5.5, -2, -1.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0.4, 0, 90)
SWEP.lengthSub = 25
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -3, 2)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.ImmobilizationMul = 1

--local to head
SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
--local to rh
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 3
SWEP.SightSlideOffset = 1.2

SWEP.podkid = 1

function SWEP:DrawPost()
	local wep = self:GetWM()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(54, Vector(0, 1.5 * self.shooanim, 0), false)
	end
end

if CLIENT then
	local vector_origin = Vector(0, 0, 0)
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.10] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(27, vector_origin)
			self:GetWM():ManipulateBoneScale(38, vector_full)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetWM():ManipulateBoneScale(41, vector_origin)
		end,
		[0.35] = function(self, timeMul)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.5 * timeMul, nil, nil, function()
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_full)
				wm:ManipulateBoneScale(39, vector_full)
				end
			end)
		end,
		[0.40] = function(self, timeMul)
			hg.CreateMag( self, Vector(50,10,10), nil, true )
		end,
		[0.70] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(38, vector_origin)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_origin)
				wm:ManipulateBoneScale(39, vector_origin)
				wm:ManipulateBoneScale(40, vector_origin)
				end
			end)
		end,
	}
end


