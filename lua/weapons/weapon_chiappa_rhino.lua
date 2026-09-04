--made by lazzy https://steamcommunity.com/id/TimeToFuckinDie
SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Chiappa Rhino"
SWEP.Author = "Chiappa Firearms"
SWEP.Instructions = "A unique Italian revolver chambered in .357 Magnum"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10

SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_chiappa_rhino.mdl"

SWEP.FakePos = Vector(-24, 2, 5)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0, 0, -0.2)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "13112111111"
SWEP.FakeBodyGroupsPresets = {
	"13112111111",
}

SWEP.FakeVPShouldUseHand = false
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 1
SWEP.ReloadTime = 3

SWEP.ModularParts = {
	frontsight = {
		model = "models/weapons/mods/rhino_fs.mdl",
		bonemerge = false,
		bone = "mod_sight_front",
		pos = Vector(-0, -3.9, 0.05),
		ang = Angle(0, -90, 0),
	},
	rearsight = {
		model = "models/weapons/mods/rhino_rs.mdl",
		bonemerge = false,
		bone = "mod_sight_rear",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
}

SWEP.AnimList = {
	["idle"] = "idle",
	["reload"] = "speedloader_reload__0",
	["reload_empty"] = "speedloader_reload__0",
	["inspect"] = "look__0",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
    ["reload"] = {
        [0.025] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_out.ogg") end,
		[0.2] = function(self)
			self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_purge_all.ogg")
			self:EmitSound("arc9_eft_shared/generic_mag_pouch_in1.ogg")
		end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.56] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_extractor.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_in.ogg") end,
    },
    ["reload_empty"] = {
        [0.025] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_out.ogg") end,
		[0.2] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_purge_all.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.56] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_extractor.ogg") end,
		[0.7] = function(self) self:EmitSound("weapons/darsu_eft/rhino/rhino_drum_in.ogg") end,
    },
}

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".357 Magnum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/rhino/rhino_fire_indoor_close.wav", 75, 75, 70}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_hammer.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = 0.25

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.3501, 3.6926)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.15, -0.15, 0), Angle(-0.2, 0.15, 0)}
SWEP.Ergonomics = 1.1
SWEP.Penetration = 13.5
SWEP.ShockMultiplier = 2
SWEP.punchmul = 4
SWEP.punchspeed = 1
SWEP.weight = 1.2
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_357"
SWEP.CustomShell = "357"

SWEP.LocalMuzzlePos = Vector(3.9, -2.35, 2.1)
SWEP.LocalMuzzleAng = Angle(0.398, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 90)

SWEP.WorldPos = Vector(4, -1.5, -1)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, 0, 0)
SWEP.attAng = Angle(0, 0, 90)
SWEP.lengthSub = 20
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 5
SWEP.AnimShootMul = 4

SWEP.podkid = 2

SWEP.FakeMagDropBone = "magazine"
SWEP.MagModel = "models/weapons/upgrades/w_magazine_m45_8.mdl"

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_cr50ds.png")
SWEP.IconOverride = "entities/arc9_eft_cr50ds.png"
SWEP.WepSelectIcon2box = true

SWEP.availableAttachments = {
	underbarrel = {
		["mount"] = Vector(9, 1, -1),
		["mountAngle"] = Angle(0, -0.75, -90),
		["mountType"] = "picatinny_small"
	},
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:DrawPost()
	local wep = self:GetWM()
	if CLIENT and IsValid(wep) then
		self.shooanim = LerpFT(0.4, self.shooanim or 0, (self:Clip1() > 0 or self.reload) and 0 or 1)
		wep:ManipulateBonePosition(54, Vector(0, 1.5 * self.shooanim, 0), false)
		wep:ManipulateBoneScale(97, self.reload and Vector(1, 1, 1) or Vector(0, 0, 0))
		if self.Drum then
			self.DrumAng = LerpFT(0.05, self.DrumAng or 0, self:GetNWInt("drumroll", 0))
			wep:ManipulateBoneAngles(43, Angle(0, 0, -(360 / 6) * (self.reload and 0 or self.DrumAng)))
		end
	end
	self:DrawModularParts()
end

function SWEP:ModelCreated(model)
	if CLIENT and IsValid(model) then
		model:ManipulateBoneScale(97, Vector(0, 0, 0))
	end
end

function SWEP:GetModularPartModel(partName, fallback, role)
	return fallback
end

function SWEP:DrawModularParts()
	local wm = self:GetWM()
	if not IsValid(wm) then return end

	local parts = self.ModularParts
	if not istable(parts) then return end

	self.ModularHeldPartModels = self.ModularHeldPartModels or {}
	self.ModularHeldPartPaths = self.ModularHeldPartPaths or {}
	local positioned = {}

	local function positionPart(partName)
		if positioned[partName] then return positioned[partName] end
		local partData = parts[partName]
		if not istable(partData) then return end

		local modelPath = self:GetModularPartModel(partName, partData.model, "held")
		local model = self.ModularHeldPartModels[partName]
		if not isstring(modelPath) or modelPath == "" then
			if IsValid(model) then model:Remove() end
			self.ModularHeldPartModels[partName] = nil
			self.ModularHeldPartPaths[partName] = nil
			return
		end
		if IsValid(model) and self.ModularHeldPartPaths[partName] ~= modelPath then
			model:Remove()
			model = nil
		end
		if not IsValid(model) then
			model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
			if not IsValid(model) then return end
			model:SetNoDraw(true)
			self.ModularHeldPartModels[partName] = model
			self.ModularHeldPartPaths[partName] = modelPath
		end

		local basePos, baseAng
		if partData.parent then
			local parent = positionPart(partData.parent)
			if not IsValid(parent) then return end
			basePos, baseAng = parent:GetPos(), parent:GetAngles()
		else
			local boneID = wm:LookupBone(partData.bone or "")
			local matrix = boneID and wm:GetBoneMatrix(boneID)
			if not matrix then return end
			basePos, baseAng = matrix:GetTranslation(), matrix:GetAngles()
		end

		local pos, ang = LocalToWorld(partData.pos or vector_origin, partData.ang or angle_zero, basePos, baseAng)
		pos, ang = self:ApplyManagedStockPartOffset(partName, pos, ang)
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetPos(pos)
		model:SetAngles(ang)
		if partData.skin ~= nil then model:SetSkin(partData.skin) end
		if isstring(partData.bodygroups) then model:SetBodyGroups(partData.bodygroups) end
		model:SetupBones()
		positioned[partName] = model
		return model
	end

	for partName in pairs(parts) do positionPart(partName) end
	for partName in pairs(parts) do
		local model = positioned[partName]
		if IsValid(model) then model:DrawModel() end
	end
end

function SWEP:InitializePost()
	self.Drum = {
		[1] = 1,
		[2] = 1,
		[3] = 1,
		[4] = 1,
		[5] = 1,
		[6] = 1
	}
	self:RevolverPostInit()
end

function SWEP:RevolverPostInit()
end

function SWEP:ShiftDrum(val)
	val = math.Round(val % 6)
	if val == 0 then val = 1 end

	local drumCopy = table.Copy(self.Drum)

	for i = 1,#self.Drum do
		local nextval = i + val

		local setval = nextval < 1 and #self.Drum - nextval or nextval > 6 and nextval - 6 or nextval

		self.Drum[i] = drumCopy[setval]
	end

	local stringythingy = ""
	for i = 1,#self.Drum do
		stringythingy = stringythingy..tostring(self.Drum[i]).." "
	end

	self:SetNWInt("drumroll",self:GetNWInt("drumroll",0) + val)
	self:SetNWString("drum",stringythingy)
end

function SWEP:GetDrum()
	local drumtbl = string.Split(self:GetNWString("drum","1 1 1 1 1 1")," ")

	if (self.DrumLastPredicted or 0) < CurTime() then
		for i = 1,#self.Drum do
			self.Drum[i] = tonumber(drumtbl[i])
		end
	end

	return self.Drum
end

function SWEP:SetDrum(drum)
	self.Drum = drum
	self.DrumLastPredicted = CurTime() + 1
end

function SWEP:Unload()
	if CLIENT then return end

	if self.SendDrum then
		for i = 1,#self.Drum do
			self.Drum[i] = 0
		end
		self:SendDrum()
	end
end

if SERVER then
	function SWEP:SendDrum()
		local stringythingy = ""
		for i = 1,#self.Drum do
			stringythingy = stringythingy..tostring(self.Drum[i]).." "
		end

		self:SetNWString("drum",stringythingy)
	end
end

local phrases = {
	"Didn't fire...",
	"Lucky me...",
	"I thought that was it...",
	"Still not dead...",
	"I knew it wasn't there! I really did!..",
	"FUCK- Thought it would fire...",
	"HELL YEAH!",
	"Luck is on my side!",
}

local clr_notify = Color(122, 0, 0)
function SWEP:Shoot(override)
	if not self:CanPrimaryAttack() then return false end
	if self:KeyDown(IN_USE) and !IsValid(self:GetOwner().FakeRagdoll) then return false end
	if not self:CanUse() then return false end
	if CLIENT and self:GetOwner() != LocalPlayer() and not override then return false end
	local primary = self.Primary

	if primary.Next > CurTime() then return false end
	if (primary.NextFire or 0) > CurTime() then return false end

	self.Drum = SERVER and self.Drum or CLIENT and self:GetDrum()

	if self.Drum[1] != 1 then
		self.LastPrimaryDryFire = CurTime()
		self:PrimaryShootEmpty()
		primary.Automatic = false
		self:ShiftDrum(1)
		self.shooanim = 1

		local ply = self:GetOwner()
		if SERVER and IsValid(ply) and ply:IsPlayer() and ply.organism and self.Rolled and self:Clip1() > 0 and ply.suiciding and ply:GetNWFloat("willsuicide") < CurTime() then
			ply.organism.adrenalineAdd = ply.organism.adrenalineAdd + self:Clip1()
			ply.organism.fearadd = ply.organism.fearadd + 0.5
			ply:Notify(phrases[math.random(#phrases)], 1, "suicide", nil, nil, clr_notify)
		end

		return false
	end

	self.Drum[1] = -1
	self:ShiftDrum(1)

	primary.Next = CurTime() + primary.Wait
	self:SetLastShootTime(CurTime())
	primary.Automatic = weapons.Get(self:GetClass()).Primary.Automatic
	self:PrimaryShoot()
	self:PrimaryShootPost()
end

function SWEP:InsertAmmo(need)
	local owner = self:GetOwner()
	local primaryAmmo = self:GetPrimaryAmmoType()
	if !owner.GetAmmoCount then self:SetClip1(self:GetMaxClip1()) return end

	if SERVER then
		owner:GiveAmmo(self:Clip1(), primaryAmmo, true)
		self:SetClip1(0)
	end

	local primaryAmmoCount = owner:GetAmmoCount(primaryAmmo)
	need = self:GetMaxClip1()
	need = math.min(primaryAmmoCount, need)
	need = math.min(need, self:GetMaxClip1())
	self:SetClip1(need)

	for i = 1, 6 do
		self.Drum[i] = 0
	end

	for i = 1, math.min(need,6) do
		self.Drum[i] = 1
	end

	if SERVER then
		self:SendDrum()
	end

	owner:SetAmmo(primaryAmmoCount - need, primaryAmmo)
end
