SWEP.Base = "weapon_mxlr"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Sako TRG-42"
SWEP.Author = "Sako"
SWEP.Instructions = "Bolt-action sniper rifle chambered in .338 Lapua Magnum"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_sako_trg.mdl"
SWEP.WorldModelReal = "models/weapons/c_sako_trg.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_sako_trg.png")
SWEP.IconOverride = "entities/arc9_eft_sako_trg.png"

SWEP.FakePos = Vector(-10, 2.6, 6)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(3, 0, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "1111121111"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "1111121111"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 30


SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_sako_86x70_8.mdl"

if CLIENT then
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
				self:GetWM():ManipulateBoneScale(38, vector_full)
				self:GetWM():ManipulateBoneScale(39, vector_full)
			end)
		end,
		[0.40] = function(self, timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(50,10,10), nil, true )
			end
			self:GetWM():ManipulateBoneScale(57, vector_origin)
			self:GetWM():ManipulateBoneScale(58, vector_origin)
		end,
		[0.70] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(38, vector_origin)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
				self:GetWM():ManipulateBoneScale(38, vector_origin)
				self:GetWM():ManipulateBoneScale(39, vector_origin)
				self:GetWM():ManipulateBoneScale(40, vector_origin)
			end)
		end,
	}
end

SWEP.FakeVPShouldUseHand = false

SWEP.LocalMuzzlePos = Vector(33.5, -1.66, 3.2)
SWEP.LocalMuzzleAng = Angle(0, -0, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)

SWEP.CustomShell = ".338 Lapua Magnum"
SWEP.weight = 4.8
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

SWEP.Primary.ClipSize = 10
SWEP.Primary.DefaultClip = 10
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".338 Lapua Magnum"
SWEP.Primary.Damage = 110
SWEP.Primary.Force = 110
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
SWEP.Primary.Sound = {"weapons/darsu_eft/sako/sako_fire_outdoor_close.ogg", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/sako/sako_fire_outdoor_silenced_distant.ogg", 65, 100, 100}
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 1

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor11", Vector(0, 0, 0), {}},
        ["mount"] = Vector(-1.4, 0.2, 0)
    },
    sight = {
        ["mountType"] = {"picatinny"},
        ["mount"] = {picatinny = Vector(-25.5, 1.7, 0)}
    }
}

SWEP.StartAtt = {"optic9"}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.632, 4.6129)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 20
SWEP.WorldPos = Vector(0.2, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle_empty",
    ["draw"] = "draw",
    ["draw_empty"] = "draw_empty",
    ["holster"] = "holster",
    ["holster_empty"] = "holster_empty",
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry",
    ["cycle"] = "bolt0",
    ["reload"] = "reload",
    ["reload_empty"] = "reload_empty",
    ["inspect"] = "inspect0",
    ["inspect_empty"] = "inspect0",
    ["toggle"] = "mod_switch",
    ["toggle_empty"] = "mod_switch_empty",
}

local path = "weapons/darsu_eft/axmc/"

SWEP.AnimsSounds = {
    ["ready0"] = {
        [0.72] = function(self) self:EmitSound(path .. "sako_bolt_out.ogg") end,
        [1.21] = function(self) self:EmitSound(path .. "sako_bolt_in.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["draw_empty"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["holster"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_out.ogg") end,
    },
    ["holster_empty"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_out.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.ogg") end,
    },
    ["fire_dry"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_trigger_hammer.ogg") end,
    },
    ["bolt0"] = {
        [0.26] = function(self) self:EmitSound(path .. "sako_bolt_out.ogg") end,
        [0.69] = function(self) self:EmitSound(path .. "sako_bolt_in.ogg") end,
    },
    ["reload0t"] = {
        [0.55] = function(self) self:EmitSound(path .. "sako_mag_out.ogg") end,
        [2.38] = function(self) self:EmitSound(path .. "sako_mag_in.ogg") end,
    },
    ["reload_empty0"] = {
        [0.26] = function(self) self:EmitSound(path .. "sako_mag_out.ogg") end,
        [0.9] = function(self) self:EmitSound(path .. "sako_mag_in.ogg") end,
        [1.1] = function(self) self:EmitSound(path .. "sako_bolt_out.ogg") end,
        [1.3] = function(self) self:EmitSound(path .. "sako_bolt_in.ogg") end,
    },
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize and self.drawBullet == true
end

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "1111121111") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end self:GetWM():SetBodyGroups(new) end

function SWEP:InitializePost()
    self:SetRandomBodygroups(table.Random(self.FakeBodyGroupsPresets))
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
    self.BlockReload = 0
end

function SWEP:AnimationPost() local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1); local sin = 1 - animpos; if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end; sin = sin * 2; sin = math.ease.InOutSine(sin); if sin > 0 then self.LHPos[1] = 18 - sin * 6; self.RHPos[1] = 1 - sin * 4; self.inanim = true else self.inanim = nil end; local wep = self:GetWeaponEntity(); if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

local function cock(self, time)
    if SERVER then
        self:Draw(true)
    end

    if self:Clip1() == 0 then
        self.drawBullet = nil
    end

    if CLIENT and LocalPlayer() == self:GetOwner() then return end

    net.Start("hgwep draw")
        net.WriteEntity(self)
        net.WriteBool(self.drawBullet)
        net.WriteFloat(CurTime())
    net.Broadcast()

    self.Primary.Next = CurTime() + self.AnimDraw + self.Primary.Wait
    self.reloadCoolDown = CurTime() + time
end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end

    if self:GetNextPrimaryFire() > CurTime() then return end
    if self.BlockReload and self.BlockReload > CurTime() then return end

    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    if self:Clip1() >= self.Primary.ClipSize then return end

    if self.drawBullet == false and SERVER then
        self:PlayAnim(self.AnimList["cycle"] or "bolt0", 1, false, nil, false, true)

        local boltTime = 1.3
        self.reloadCoolDown = CurTime() + boltTime
        self.BlockReload = CurTime() + boltTime
        self:SetNextPrimaryFire(CurTime() + boltTime)

        cock(self, boltTime)

        local wep = self
        timer.Simple(0.26, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_bolt_out.ogg") end end)
        timer.Simple(0.69, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_bolt_in.ogg") end end)
        return
    end

    if not self:CanReload() then return end

    if SERVER then
        local isEmpty = self:Clip1() == 0
        local animName = isEmpty and "reload_empty" or "reload"

        local animSpeed = 4
        local reloadTime = isEmpty and 2.6 or 1.3

        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        self.BlockReload = CurTime() + reloadTime
        self:SetNextPrimaryFire(CurTime() + reloadTime)

        local wep = self

        self:PlayAnim(self.AnimList[animName] or animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end

            local ammoType = wep:GetPrimaryAmmoType()
            local currentClip = wep:Clip1()
            local maxClip = wep.Primary.ClipSize
            local neededAmmo = maxClip - currentClip
            local availableAmmo = wep:GetOwner():GetAmmoCount(ammoType)
            local ammoToLoad = math.min(neededAmmo, availableAmmo)

            if ammoToLoad > 0 then
                wep:GetOwner():RemoveAmmo(ammoToLoad, ammoType)
                wep:SetClip1(currentClip + ammoToLoad)
            end

            wep:SetNetVar("shootgunReload", 0)

            if wep:Clip1() > 0 then
                wep.drawBullet = true
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10)
                net.Broadcast()
            end
        end, false, true)

        if isEmpty then
            timer.Simple(0.26, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_magout_fast.ogg") end end)
            timer.Simple(1.5, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_magin.ogg") end end)
            timer.Simple(2.4, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_bolt_out.ogg") end end)
            timer.Simple(3, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_bolt_in.ogg") end end)
        else
            timer.Simple(0.55, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_magout.ogg") end end)
            timer.Simple(2.38, function() if IsValid(wep) then wep:EmitSound(path .. "aiax_magin.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end


