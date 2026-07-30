SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "Glock 17"
SWEP.Author = "Glock GmbH"
SWEP.Instructions = "Glock is a brand of polymer-framed, short recoil-operated, striker-fired, locked-breech semi-automatic pistols designed and produced by Austrian manufacturer Glock Ges.m.b.H. Thats version of Glock is 17 chambered in 9x19 ammo."
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_glock18.mdl"
SWEP.WorldModelFake = "models/weapons/c_glock.mdl"

SWEP.UseARC9Parts = true
SWEP.ARC9Parts = {
	magazine = {
		model = "models/weapons/mods/mag_glock_std_17.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
	frontsight = {
		model = "models/weapons/mods/glock_fs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(-0, -0, 0.04),
		ang = Angle(0, -90, 0),
	},
	rearsight = {
		model = "models/weapons/mods/glock_rs.mdl",
		bonemerge = false,
		bone = "mod_reciever",
		pos = Vector(0, 0, 0),
		ang = Angle(0, -90, 0),
	},
}

SWEP.FakePos = Vector(-22, 2.34, 4.32)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(0.2,0,-6.5)
SWEP.AttachmentAng = Angle(0,0,0)
SWEP.FakeAttachment = "1"
SWEP.FakeBodyGroups = "1150000000"


SWEP.FakeEjectBrassBone = "shellport"

SWEP.FakeVPShouldUseHand = true

SWEP.stupidgun = true

SWEP.CantFireFromCollision = true // 2 спусковых крючка все дела

SWEP.AnimList = {
	["inspect"] = "inspect",
	["reload"] = "reload0",
	["reload_empty"] = "reload_empty0_0",
	["idle"] = "idle",
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_UpperArm"
SWEP.ViewPunchDiv = 40

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("weapons/universal/uni_crawl_l_03.wav") end,
	},
	["reload"] = {
		[0.1] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.6] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
	},
	["reload_empty"] = {
		[0.015] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_out_fast.ogg") end,
		[0.065] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_in_fast.ogg") end,
	},
}


SWEP.lmagpos = Vector(1.8,0,-0.3)
SWEP.lmagang = Angle(-10,0,0)
SWEP.lmagpos2 = Vector(0,3.5,0.3)
SWEP.lmagang2 = Angle(0,0,-110)

SWEP.GunCamPos = Vector(2.2,-17,-3)
SWEP.GunCamAng = Angle(180,0,-90)

SWEP.MagModel = "models/weapons/mods/mag_glock_std_17.mdl"

if CLIENT then
	SWEP.FakeReloadEvents = {
		[0.15] = function( self, timeMul )
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
			else
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.3] = function( self )
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(0,55,-55) )
			end
		end,
		[0.9] = function( self, timeMul )
			if self:Clip1() >= 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end
	}
end

SWEP.FakeMagDropBone = "mod_magazine"

SWEP.WepSelectIcon2 = Material("vgui/hud/rc9_eft_glock17.png")
SWEP.IconOverride = "entities/arc9_eft_glock17.png"

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(0,0,0)
SWEP.EjectAng = Angle(-0,-180,0)

SWEP.weight = 1

SWEP.ScrappersSlot = "Secondary"

SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 17
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/glock/glock17_close.wav", 75, 90, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/glock/glock17_close_silenced.ogg", 65, 90, 100}
SWEP.Primary.SoundEmpty = {"zcitysnd/sound/weapons/makarov/handling/makarov_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 25
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.ReloadTime = 3
SWEP.ReloadSoundes = {
	"none",
	"none",
	"pwb/weapons/fnp45/clipout.wav",
	"none",
	"none",
	"none",
	"pwb/weapons/fnp45/clipin.wav",
	"pwb/weapons/fnp45/sliderelease.wav",
	"none",
	"none",
	"none",
	"none"
}
SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -1.9464, 1.9824)
--SWEP.RHandPos = Vector(-13.5,0,4)
SWEP.RHandPos = Vector(-4, 0, -3)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.03, -0.03, 0), Angle(-0.05, 0.03, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 7

SWEP.punchmul = 1.5
SWEP.punchspeed = 3
--SWEP.WorldPos = Vector(13,0,3.5)
--SWEP.WorldAng = Angle(0,0,0)
SWEP.WorldPos = Vector(2.9, -1.2, -2.8)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(0, -0, 6.5)
SWEP.attAng = Angle(0, -0.2, 0)
SWEP.lengthSub = 25
SWEP.DistSound = "m9/m9_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 1)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0, 0.0, 0), {}},
		[2] = {"supressor1", Vector(0, 0.0, 0), {}},
		["mount"] = Vector(-0.5, 0, -0.05),
		["mountAngle"] = Angle(0, 0, 180),
	},
	magwell = {
		["mountType"] = "glock_mag",
	},
	sight = {
		["mountType"] = "pistolmount",
		["mountBone"] = "mod_reciever",
		["mount"] = Vector(1, 0.5, 0.3),
		["mountAngle"] = Angle(0,-90,90),
	},
	underbarrel = {
		["mount"] = Vector(12.5, -0.35, -1),
		["mountAngle"] = Angle(0, -0.6, 90),
		["mountType"] = "picatinny_small"
	},
}

--local to head
SWEP.RHPos = Vector(12,-4.5,3)
SWEP.RHAng = Angle(0,-5,90)
--local to rh
SWEP.LHPos = Vector(-1.2,-1.4,-2.8)
SWEP.LHAng = Angle(5,9,-100)

SWEP.ShootAnimMul = 3
SWEP.SightSlideOffset = 1.2

function SWEP:ModelCreated(model)
	if not IsValid(model) then return end
	model:SetBodyGroups(self.FakeBodyGroups)
end

SWEP.HeldMagModel = "models/weapons/mods/mag_glock_std_17.mdl"
SWEP.HeldMagBone = "mod_magazine"
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)
SWEP.HeldFrontSightModel = "models/weapons/mods/glock_fs.mdl"
SWEP.HeldFrontSightBone = "mod_reciever"
SWEP.HeldFrontSightOffsetPos = Vector(-0, -0, 0.04)
SWEP.HeldFrontSightOffsetAng = Angle(0, -90, 0)
SWEP.HeldRearSightModel = "models/weapons/mods/glock_rs.mdl"
SWEP.HeldRearSightBone = "mod_reciever"
SWEP.HeldRearSightOffsetPos = Vector(0, 0.05, 0)
SWEP.HeldRearSightOffsetAng = Angle(0, -90, 0)

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local zeroVector = Vector(0, 0, 0)
	local zeroAngle = Angle(0, 0, 0)

	local function drawPartOnBone(self, wm, modelField, pathField, modelPath, boneName, offsetPos, offsetAng)
		if not isstring(modelPath) or modelPath == "" then return end
		local model = self[modelField]
		if IsValid(model) and self[pathField] ~= modelPath then
			model:Remove()
			model = nil
		end
		if not IsValid(model) then
			model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
			self[modelField] = model
			self[pathField] = modelPath
			if IsValid(model) then model:SetNoDraw(true) end
		end
		if not IsValid(model) then return end

		local boneID = wm:LookupBone(boneName)
		if boneID == nil then return end
		local matrix = wm:GetBoneMatrix(boneID)
		if not matrix then return end
		local pos, ang = LocalToWorld(offsetPos or zeroVector, offsetAng or zeroAngle, matrix:GetTranslation(), matrix:GetAngles())
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
		model:SetPos(pos)
		model:SetAngles(ang)
		model:SetupBones()
		model:DrawModel()
	end

	function SWEP:DrawPost()
		local wm = self:GetWM()
		if not IsValid(wm) or not self:ShouldUseFakeModel() then return end
		drawPartOnBone(self, wm, "HeldMagCSModel", "HeldMagCSModelPath", self:GetActiveMagazineModel(self.HeldMagModel, "held"), self.HeldMagBone, self.HeldMagOffsetPos, self.HeldMagOffsetAng)
		drawPartOnBone(self, wm, "HeldFrontSightCSModel", "HeldFrontSightCSModelPath", self.HeldFrontSightModel, self.HeldFrontSightBone, self.HeldFrontSightOffsetPos, self.HeldFrontSightOffsetAng)
		drawPartOnBone(self, wm, "HeldRearSightCSModel", "HeldRearSightCSModelPath", self.HeldRearSightModel, self.HeldRearSightBone, self.HeldRearSightOffsetPos, self.HeldRearSightOffsetAng)
	end

	function SWEP:CreateDroppedGlockModels()
		if not IsValid(self.DroppedGlockModel) then
			self.DroppedGlockModel = ClientsideModel(self.WorldModelFake, RENDERGROUP_BOTH)
			if IsValid(self.DroppedGlockModel) then
				self.DroppedGlockModel:SetNoDraw(true)
				self.DroppedGlockModel:DrawShadow(true)
				self:ModelCreated(self.DroppedGlockModel)
			end
		end
		self.DroppedGlockParts = self.DroppedGlockParts or {}
		self.DroppedGlockPartPaths = self.DroppedGlockPartPaths or {}
		for name, data in pairs(self.ARC9Parts or {}) do
			if not istable(data) or not isstring(data.model) or data.model == "" then continue end
			local path = name == "magazine" and self:GetActiveMagazineModel(data.model, "world") or data.model
			local model = self.DroppedGlockParts[name]
			if IsValid(model) and self.DroppedGlockPartPaths[name] ~= path then
				model:Remove()
				model = nil
			end
			if not IsValid(model) then
				model = ClientsideModel(path, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.DroppedGlockParts[name] = model
					self.DroppedGlockPartPaths[name] = path
				end
			end
		end
	end

	function SWEP:RemoveGlockModels()
		for _, model in pairs(self.DroppedGlockParts or {}) do
			if IsValid(model) then model:Remove() end
		end
		self.DroppedGlockParts = nil
		self.DroppedGlockPartPaths = nil
		if IsValid(self.DroppedGlockModel) then self.DroppedGlockModel:Remove() end
		self.DroppedGlockModel = nil
		for _, field in ipairs({"HeldMagCSModel", "HeldFrontSightCSModel", "HeldRearSightCSModel"}) do
			if IsValid(self[field]) then self[field]:Remove() end
			self[field] = nil
		end
	end

	function SWEP:DrawDroppedGlock()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:CreateDroppedGlockModels()
		local fake = self.DroppedGlockModel
		if not IsValid(fake) then return end
		local basePos, baseAng = LocalToWorld(self.WorldPartsOffsetPos or zeroVector, self.WorldPartsOffsetAng or zeroAngle, self:GetPos(), self:GetAngles())
		fake:SetRenderOrigin(basePos)
		fake:SetRenderAngles(baseAng)
		fake:SetPos(basePos)
		fake:SetAngles(baseAng)
		fake:SetupBones()
		fake:DrawModel()

		for name, data in pairs(self.ARC9Parts or {}) do
			local model = self.DroppedGlockParts and self.DroppedGlockParts[name]
			if not IsValid(model) or not istable(data) then continue end
			local partPos, partAng = basePos, baseAng
			local boneID = fake:LookupBone(data.bone or "")
			if boneID ~= nil then
				local matrix = fake:GetBoneMatrix(boneID)
				if matrix then partPos, partAng = matrix:GetTranslation(), matrix:GetAngles() end
			end
			local pos, ang = LocalToWorld(data.pos or zeroVector, data.ang or zeroAngle, partPos, partAng)
			model:SetRenderOrigin(pos)
			model:SetRenderAngles(ang)
			model:SetPos(pos)
			model:SetAngles(ang)
			model:SetupBones()
			if data.skin ~= nil then model:SetSkin(data.skin) end
			if istable(data.bodygroups) then
				for id, value in pairs(data.bodygroups) do model:SetBodygroup(tonumber(id) or id, tonumber(value) or 0) end
			end
			if istable(data.submaterials) then
				for id, path in pairs(data.submaterials) do model:SetSubMaterial(tonumber(id) or id, path or "") end
			end
			model:DrawModel()
		end

		local originalWorldModel = self.worldModel
		self.worldModel = fake
		self:DrawAttachments()
		self.worldModel = originalWorldModel
	end

	function SWEP:DrawWorldModel()
		self:DrawDroppedGlock()
	end

	function SWEP:DrawWorldModelTranslucent()
		self:DrawDroppedGlock()
	end

	function SWEP:OnRemove()
		self:RemoveGlockModels()
	end
end

SWEP.LocalMuzzlePos = Vector(3.3, -1.95, 1.38)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0,0,0)
