--ByLAZZY
SWEP.Base = "weapon_m4super"
SWEP.ShotgunTubeReload = true
SWEP.ShotgunManualCycle = false
SWEP.ShotgunReloadStartAnim = "start"
SWEP.ShotgunReloadStartTime = 1.0
SWEP.ShotgunReloadInsertAnim = "insert"
SWEP.ShotgunReloadInsertTime = 1.0
SWEP.ShotgunReloadFinishAnim = "finish"
SWEP.ShotgunReloadFinishTime = 1.0
SWEP.ShotgunEmptyReloadNeedsCycle = false
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "MR-153"
SWEP.Author = "Baikal"
SWEP.Instructions = "Automatic shotgun chambered in 12/70"
SWEP.Category = "Weapons - Shotguns"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.WorldModelFake = "models/weapons/c_mr153.mdl"
SWEP.WorldModelReal = "models/weapons/c_mr153.mdl"

SWEP.FakePos = Vector(-11, 3.6, 6.2)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(-0.4, 0.2, 0)
SWEP.AttachmentAng = Angle(0, 0, 0)
SWEP.FakeBodyGroups = "11100410010"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "011100410010"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 1

SWEP.FakeReloadEvents = {}

SWEP.FakeVPShouldUseHand = false

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_mr153.png")
SWEP.IconOverride = "entities/arc9_eft_mr153.png"

SWEP.LocalMuzzlePos = Vector(32.2, -0.66, 4.45)
SWEP.LocalMuzzleAng = Angle(0, -0.0, 0)
SWEP.WeaponEyeAngles = Angle(-0.7, 0.1, 0)
SWEP.PPSMuzzleEffect = "pcf_jack_mf_mshotgun"

SWEP.CustomShell = "12x70"
SWEP.ReloadSound = "weapons/remington_870/870_shell_in_1.wav"
SWEP.CockSound = "weapons/darsu_eft/m870/rem870_pump_in.ogg"
SWEP.weight = 4
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "ShotgunShellEject"
SWEP.AutomaticDraw = false
SWEP.UseCustomWorldModel = true

SWEP.Primary.ClipSize = 7
SWEP.Primary.DefaultClip = 7
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "12/70 gauge"
SWEP.Primary.Damage = 16 * 8
SWEP.Primary.Force = 12
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0.04
SWEP.Primary.NumShots = 8

local path = "weapons/darsu_eft/mr133/"
SWEP.Primary.Sound = {path .. "mr153_fire_close2.ogg", 85, 100, 100}
SWEP.SupressedSound = {path .. "mr153_fire_silenced_indoor_close.wav", 65, 100, 100}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_hammer.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.25
SWEP.NumBullet = 8

SWEP.availableAttachments = {
    barrel = {
        [1] = {"supressor13", Vector(0, 0, 0), {}},
        [2] = {"supressor12", Vector(0, 0, 0), {}},
        ["mount"] = Vector(-0.5, -0, 0.1),
        ["mountAngle"] = Angle(0, -0, 90),
    },
    sight = {
        ["mountType"] = "picatinny",
        ["mount"] = Vector(-26.5, 0.05, 0.9),
        ["mountAngle"] = Angle(0, 0, 90),
    },
}

SWEP.AnimShootMul = 3
SWEP.AnimShootHandMul = 10
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -0.6725, 5.376)
SWEP.RHandPos = Vector(0, 0, -1)
SWEP.LHandPos = Vector(7, 0, -2)
SWEP.Ergonomics = 0.9
SWEP.Penetration = 7
SWEP.WorldPos = Vector(-1, -0.5, 1.2)
SWEP.WorldAng = Angle(0.7, -0.1, 0)
SWEP.attPos = Vector(0.4, -0.15, 0)
SWEP.attAng = Angle(0, 0.2, 0)
SWEP.lengthSub = 20

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 8, -6)
SWEP.holsteredAng = Angle(210, 0, 180)

-- ============================================
-- ANIMATIONS
-- ============================================

SWEP.AnimList = {
    ["idle"] = "idle",
    ["draw"] = "draw",
    ["holster"] = "holster",
    ["ready"] = "ready0",
    ["fire"] = "fire",
    ["cycle"] = "idle",

    ["start"] = "reload_start2",
    ["insert"] = "reload_loop2",
    ["finish"] = "reload_end",
    ["inspect"] = "look",
}

SWEP.AnimsEvents = {
    ["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
    },
    ["ready0"] = {
        [0.01] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
        [0.63] = function(self) self:EmitSound(path .. "mr133_pump_in_fast.ogg") end,
        [0.87] = function(self) self:EmitSound(path .. "mr133_pump_out_fast.ogg") end,
    },
    ["draw"] = {
        [0.01] = function(self) self:EmitSound(path .. "mr133_draw.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound(path .. "mr133_trigger.wav") end,
    },
    ["reload_start2"] = {
        [0.2] = function(self) self:EmitSound(path .. "mr133_shell_pickup.ogg") end,
        [0.8] = function(self) self:EmitSound(path .. "mr133_magcover.ogg") end,
        [1.0] = function(self) self:EmitSound(path .. "mr133_shell_in_port.ogg") end,
    },
    ["reload_loop2"] = {
        [0.2] = function(self) self:EmitSound(path .. "mr133_shell_pickup.ogg") end,
        [0.6] = function(self) self:EmitSound(path .. "mr133_magcover.ogg") end,
        [0.71] = function(self) self:EmitSound(path .. "mr133_shell_in_port.ogg") end,
    },
    ["reload_end"] = {
        [0.1] = function(self) self:EmitSound(path .. "mr133_magcover.ogg") end,
    },
}

SWEP.stupidgun = true

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "011100410010") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end self:GetWM():SetBodyGroups(new) end

function SWEP:InitializePost()
    local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end
    self.AnimStart_Insert = 0
    self.AnimStart_Draw = 0
    self.isReloading = false
end

function SWEP:AnimationPost()
    local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1)
    local sin = 1 - animpos
    if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end
    sin = sin * 2
    sin = math.ease.InOutSine(sin)
    if sin > 0 then
        self.LHPos[1] = 18 - sin * 6
        self.RHPos[1] = 1 - sin * 4
        self.inanim = true
    else
        self.inanim = nil
    end
    local wep = self:GetWeaponEntity()
    if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end
end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

-- ============================================
-- RELOAD (FISTFUL-STYLE, SEMI-AUTO)
-- ============================================

SWEP.isReloading = false

local function finishReload(self)
    self:PlayAnim(self.AnimList["finish"], 1.0, false, function()
        if self:Clip1() > 0 then
            self.drawBullet = true
            net.Start("hgwep draw")
                net.WriteEntity(self)
                net.WriteBool(true)
                net.WriteFloat(CurTime() - 10)
            net.Broadcast()
        end

        self:SetNetVar("shootgunReload", 0)
        self.isReloading = false
    end, false, true)
end

local function reloadLoop(self, inserted, needed)
    if not SERVER then return end

    if inserted >= needed or self:GetOwner():KeyDown(IN_ATTACK) or self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType()) <= 0 then
        finishReload(self)
        return
    end

    self:SetNetVar("shootgunReload", CurTime() + 0.8)

    self:PlayAnim(self.AnimList["insert"], 1.0, false, function()
        if not IsValid(self) then return end

        self:InsertAmmo(1)
        reloadLoop(self, inserted + 1, needed)
    end, false, true)
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:IsShotgunBusy() then return end
    local ply = self:GetOwner()
    if ply.organism and (ply.organism.larmamputated or ply.organism.rarmamputated) then return end

    if not self:CanReload() then return end
    if self:Clip1() >= self.Primary.ClipSize then return end

    if SERVER then
        self.isReloading = true
        local needed = self.Primary.ClipSize - self:Clip1()
        self:SetNetVar("shootgunReload", CurTime() + 1.2)

        self:PlayAnim(self.AnimList["start"], 1.0, false, function()
            reloadLoop(self, 0, needed)
        end, false, true)
    end
end

function SWEP:CanPrimaryAttack()
    return not self.isReloading
end

function SWEP:ReloadEnd() end

-- ============================================
-- INSPECT
-- ============================================

function SWEP:AllowedInspect()
    if not self:CanUse() then return end
    if self.isReloading then return end
    if self:Clip1() < self.Primary.ClipSize then return end
    if self.drawBullet == false then return end
    return true
end

--========================================================
-- FIRE ANIMATION
--========================================================

SWEP.FireAnimTime = 0.15
SWEP.FireAnimCandidates = {"fire", "fire1"}

function SWEP:PrimaryShootPost()
	self.drawBullet = true

	if not CLIENT then return end
	if self.reload then return end
	if not self:ShouldUseFakeModel() then return end

	local worldModel = self:GetWM()
	if not IsValid(worldModel) then return end

	local selectedSequence
	for _, sequenceName in ipairs(self.FireAnimCandidates) do
		local sequenceID = worldModel:LookupSequence(sequenceName)
		if sequenceID ~= nil and sequenceID >= 0 then
			selectedSequence = sequenceName
			break
		end
	end

	if not selectedSequence then return end

	self.AnimList.fire = selectedSequence
	self:PlayAnim("fire", self.FireAnimTime, false)

	local timerName = "BC_FireAnimation_" .. self:EntIndex()
	timer.Create(timerName, self.FireAnimTime, 1, function()
		if not IsValid(self) or self.reload then return end
		if self.Primary and (self.Primary.Next or 0) > CurTime() then return end
		self:PlayAnim("idle", 1, not self.NoIdleLoop)
	end)
end

function SWEP:Reload()
    self:ShotgunReload()
end

function SWEP:CanPrimaryAttack()
    return self:ShotgunCanPrimaryAttack()
end
