SWEP.Base = "homigrad_base"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "Henchman's Pistol"
SWEP.Author = "Henchman"
SWEP.Instructions = "Pistol chambered in 9x19 mm"
SWEP.Category = "Weapons - Pistols"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_pist_deagle.mdl"
SWEP.WorldModelFake = "models/weapons/c_usp.mdl"


SWEP.ModularParts = {
	magazine = {
		model = "models/weapons/mods/mag_hk_usp_tactical.mdl",
		bonemerge = false,
		bone = "mod_magazine",
		pos = Vector(0, -1.2, -1.25),
		ang = Angle(0, -90, 0)
	},
}
SWEP.HeldMagOffsetPos = Vector(0, 0, 0)
SWEP.HeldMagOffsetAng = Angle(0, -90, 0)

SWEP.FakePos = Vector(-21, 2, 3.22)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.AttachmentPos = Vector(1, 0, -0)
SWEP.AttachmentAng = Angle(0, 0, 90)
SWEP.FakeAttachment = "1"
SWEP.FakeEjectBrassATT = "2"
SWEP.FakeBodyGroups = "11112202"

SWEP.FakeVPShouldUseHand = true
SWEP.FakeViewBobBone = "ValveBiped.Bip01_R_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_R_Forearm"
SWEP.ViewPunchDiv = 1

SWEP.AnimList = {
	["idle"] = "base_idle",
	["idle_empty"] = "idle_empty",
	["reload"] = "reload",
	["reload_empty"] = "reload_empty0",
	["inspect"] = "inspect",
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
	["reload"] = {
		[0.1] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.2] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_in1.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.6] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
	},
	["reload_empty"] = {
		[0.015] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_out_fast.ogg") end,
		[0.065] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_out.ogg") end,
		[0.23] = function(self) self:EmitSound("arc9_eft_shared/generic_mag_pouch_out1.ogg") end,
		[0.45] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_mag_in.ogg") end,
		[0.65] = function(self) self:EmitSound("weapons/darsu_eft/57/fiveseven_slider_in_fast.ogg") end,
	},
}

function SWEP:AllowedInspect()
	if not self:CanUse() then return end
	if self.isReloading then return end
	if self:Clip1() < self.Primary.ClipSize then return end
	if self.drawBullet == false then return end
	return true
end

function SWEP:PrimaryShootPost()
	if self:Clip1() > 0 then return end
	self:PlayAnim("idle_empty", 1, true)
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

SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_hk_usp_tactical.mdl"

SWEP.ReloadTime = 2


SWEP.lmagpos = Vector(2, 0, 0)
SWEP.lmagang = Angle(-10, 0, 0)
SWEP.lmagpos2 = Vector(0, -1.5, 0.7)
SWEP.lmagang2 = Angle(0, 0, 0)

if CLIENT then
	local vector_full = Vector(1, 1, 1)

	SWEP.FakeReloadEvents = {
		[0.15] = function(self, timeMul)
			if self:Clip1() < 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1.5 * timeMul)
			else
				self:GetWM():ManipulateBoneScale(49, vector_full)
				self:GetWM():ManipulateBoneScale(50, vector_origin)
				self:GetWM():ManipulateBoneScale(51, vector_origin)
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 0.5 * timeMul)
			end
		end,
		[0.3] = function(self)
			if self:Clip1() < 1 then
				hg.CreateMag(self, Vector(0, 0, -50))
				self:GetWM():ManipulateBoneScale(49, vector_origin)
				self:GetWM():ManipulateBoneScale(50, vector_origin)
				self:GetWM():ManipulateBoneScale(51, vector_origin)
			else
				self:GetWM():ManipulateBoneScale(50, vector_full)
				self:GetWM():ManipulateBoneScale(51, vector_full)
			end
		end,
		[0.45] = function(self)
			if self:Clip1() < 1 then
				self:GetWM():ManipulateBoneScale(50, vector_full)
				self:GetWM():ManipulateBoneScale(51, vector_full)
			end
		end,
		[0.8] = function(self, timeMul)
			if self:Clip1() >= 1 then
				self:GetOwner():PullLHTowards("ValveBiped.Bip01_L_Thigh", 1 * timeMul)
			end
		end,
		[0.9] = function(self)
			self:GetWM():ManipulateBoneScale(53, vector_origin)
		end,
	}
end

function SWEP:Deploy()
	net.Start("HenchmanUSP_StopMusic")
	net.Send(self:GetOwner())

	local result = self.BaseClass.Deploy(self)

	if SERVER then
		timer.Simple(0.3, function()
			if IsValid(self) and IsValid(self:GetOwner()) then
				net.Start("HenchmanUSP_PlayMusic")
				net.Send(self:GetOwner())
			end
		end)
	end

	if SERVER and IsValid(self:GetOwner()) then
		local ply = self:GetOwner()
		ply.posture = 8
		net.Start("change_posture")
		net.WriteEntity(ply)
		net.WriteInt(8, 9)
		net.Broadcast()
	end

	return result
end

function SWEP:StopHenchmanMusic()
	if SERVER and IsValid(self:GetOwner()) then
		net.Start("HenchmanUSP_StopMusic")
		net.Send(self:GetOwner())
	end
end

function SWEP:Holster()
	self:StopHenchmanMusic()
	return self.BaseClass.Holster(self)
end

function SWEP:Think()
	self.BaseClass.Think(self)

	if SERVER and IsValid(self:GetOwner()) then
		local ply = self:GetOwner()
		if ply.posture ~= 8 then
			ply.posture = 8
			net.Start("change_posture")
			net.WriteEntity(ply)
			net.WriteInt(8, 9)
			net.Broadcast()
		end
	end
end

SWEP.WepSelectIcon2 = Material("entities/hACH.png")
SWEP.IconOverride = "entities/hACH.png"

SWEP.CustomShell = "9x19"
SWEP.EjectPos = Vector(4.5, 3, -21.5)
SWEP.EjectAng = Angle(0, 0, 0)

SWEP.weight = 1
SWEP.ScrappersSlot = "Secondary"
SWEP.weaponInvCategory = 2
SWEP.ShellEject = "EjectBrass_9mm"
SWEP.Primary.ClipSize = 15
SWEP.Primary.DefaultClip = 15
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "9x19 mm Parabellum"
SWEP.Primary.Cone = 0
SWEP.Primary.Damage = 25
SWEP.Primary.Sound = {"weapons/darsu_eft/usp/H_shot.wav", 95, 95, 105}
SWEP.SupressedSound = {"weapons/darsu_eft/usp/H_shot.wav", 95, 95, 105}
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_hammer.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Force = 22
SWEP.Primary.Wait = PISTOLS_WAIT
SWEP.SupressorOnly = true
SWEP.PPSMuzzleEffect = "pcf_jack_mf_suppressed"

SWEP.DeploySnd = {"homigrad/weapons/draw_pistol.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/holster_pistol.mp3", 55, 100, 110}
SWEP.HoldType = "revolver"
SWEP.ZoomPos = Vector(0, -2.2867, 1.2432)
SWEP.RHandPos = Vector(-3, -1, 0)
SWEP.LHandPos = false
SWEP.SprayRand = {Angle(-0.02, -0.02, 0), Angle(-0.03, 0.02, 0)}
SWEP.Ergonomics = 1.2
SWEP.Penetration = 11.5
SWEP.ShockMultiplier = 1
SWEP.punchmul = 1.5
SWEP.punchspeed = 3

SWEP.LocalMuzzlePos = Vector(5, -2.25, 0.6)
SWEP.LocalMuzzleAng = Angle(0, 0, 0)
SWEP.WeaponEyeAngles = Angle(0, 0, 0)

SWEP.WorldPos = Vector(2.9, -1.2, -2.2)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.UseCustomWorldModel = true
SWEP.attPos = Vector(-0.7, -0.1, 0)
SWEP.attAng = Angle(0, 0, 0)
SWEP.lengthSub = 22
SWEP.DistSound = "zcitysnd/sound/weapons/makarov/makarov_dist.wav"
SWEP.holsteredBone = "ValveBiped.Bip01_R_Thigh"
SWEP.holsteredPos = Vector(0, -2, 0)
SWEP.holsteredAng = Angle(0, 20, 30)
SWEP.shouldntDrawHolstered = true

SWEP.RHPos = Vector(12, -4.5, 3.5)
SWEP.RHAng = Angle(5, -5, 90)
SWEP.LHPos = Vector(-1.2, -1.4, -2.8)
SWEP.LHAng = Angle(5, 9, -100)
SWEP.ShootAnimMul = 4
SWEP.AnimShootMul = 3

SWEP.podkid = 1

SWEP.StartAtt = {"holo16", "supressor2"}
SWEP.availableAttachments = {
	barrel = {
		[1] = {"supressor2", Vector(0, 0.0, 0), {}},
		[2] = {"supressor1", Vector(0, 0.0, 0), {}},
		["mount"] = Vector(-0.5, 0, -0.05),
		["mountAngle"] = Angle(0, 0, 180),
	},
	sight = {
		["mountType"] = "pistolmount",
		["mountBone"] = "mod_reciever",
		["mount"] = Vector(1, 1, 0.6),
		["mountAngle"] = Angle(900, 90, -90),
	},
	underbarrel = {
		["mount"] = Vector(12.55, -0.2, -0.09),
		["mountAngle"] = Angle(0, 0, 0),
		["mountType"] = "picatinny_small"
	},
}

function SWEP:GetModularPartModel(partName, fallback, role)
	if partName == "magazine" then
		return self:GetActiveMagazineModel(fallback, role)
	end
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

		local partPos, partAng = partData.pos or vector_origin, partData.ang or angle_zero
		if partName == "magazine" and self.HeldMagOffsetPos then
			partPos, partAng = self.HeldMagOffsetPos, self.HeldMagOffsetAng or partAng
		end
		local pos, ang = LocalToWorld(partPos, partAng, basePos, baseAng)
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

	self.HeldMagCSModel = positioned.magazine
end

function SWEP:DrawPost()
	local wep = self:GetWeaponEntity()
	if not IsValid(wep) then return end

	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if not self:ShouldUseFakeModel() then return end

	self:DrawModularParts()
end

SWEP.WorldPartsOffsetPos = Vector(-20, 5, 10)
SWEP.WorldPartsOffsetAng = Angle(0, 0, 0)

SWEP.WorldMagazineBoneOverride = "weapon"
SWEP.WorldMagazineOffsetPos = Vector(0, -17.3, -0.55)
SWEP.WorldMagazineOffsetAng = Angle(0, 0, 0)

if CLIENT then
	local MOD_VECTOR_ZERO = Vector(0, 0, 0)
	local MOD_ANGLE_ZERO = Angle(0, 0, 0)

	function SWEP:ModularCreateDroppedFakeModel()
		if not self.WorldModelFake then return end
		if IsValid(self.ModularDroppedFakeWorldModel) then return end

		local model = ClientsideModel(self.WorldModelFake, RENDERGROUP_BOTH)
		if not IsValid(model) then return end

		model:SetNoDraw(true)
		model:DrawShadow(true)

		if self.FakeScale then
			model:SetModelScale(self.FakeScale, 0)
		end

		if self.FakeBodyGroups then
			model:SetBodyGroups(self.FakeBodyGroups)
		end
		if self.FakeSkin ~= nil then model:SetSkin(self.FakeSkin) end

		if self.ModelCreated then
			self:ModelCreated(model)
		end

		self.ModularDroppedFakeWorldModel = model
	end

	function SWEP:ModularCreateDroppedModels()
		local parts = self.ModularParts
		if not istable(parts) then return end

		self.ModularDroppedPartModels = self.ModularDroppedPartModels or {}
		self.ModularDroppedPartPaths = self.ModularDroppedPartPaths or {}

		for partName, partData in pairs(parts) do
			if not istable(partData) or not isstring(partData.model) or partData.model == "" then
				continue
			end
			local modelPath = self:GetModularPartModel(partName, partData.model, "world")

			local model = self.ModularDroppedPartModels[partName]
			local oldPath = self.ModularDroppedPartPaths[partName]
			if not isstring(modelPath) or modelPath == "" then
				if IsValid(model) then model:Remove() end
				self.ModularDroppedPartModels[partName] = nil
				self.ModularDroppedPartPaths[partName] = nil
				continue
			end

			if IsValid(model) and oldPath ~= modelPath then
				model:Remove()
				model = nil
			end

			if not IsValid(model) then
				model = ClientsideModel(modelPath, RENDERGROUP_BOTH)
				if IsValid(model) then
					model:SetNoDraw(true)
					model:DrawShadow(true)
					self.ModularDroppedPartModels[partName] = model
					self.ModularDroppedPartPaths[partName] = modelPath
				end
			end
		end
	end

	function SWEP:ModularRemoveDroppedModels()
		if self.ModularDroppedPartModels then
			for partName, model in pairs(self.ModularDroppedPartModels) do
				if IsValid(model) then model:Remove() end
			end
		end
		self.ModularDroppedPartModels = nil
		self.ModularDroppedPartPaths = nil

		if IsValid(self.ModularDroppedFakeWorldModel) then
			self.ModularDroppedFakeWorldModel:Remove()
		end
		self.ModularDroppedFakeWorldModel = nil
	end

	local function ModularApplyPartAppearance(model, partData)
		if not IsValid(model) or not istable(partData) then return end

		if partData.skin ~= nil then
			model:SetSkin(partData.skin)
		end

		if istable(partData.bodygroups) then
			for bodygroupID, value in pairs(partData.bodygroups) do
				model:SetBodygroup(tonumber(bodygroupID) or bodygroupID, tonumber(value) or 0)
			end
		end

		if istable(partData.submaterials) then
			for materialID, materialPath in pairs(partData.submaterials) do
				model:SetSubMaterial(tonumber(materialID) or materialID, materialPath or "")
			end
		end
	end

	function SWEP:ModularDrawDroppedModel()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end

		if not IsValid(self.ModularDroppedFakeWorldModel) then
			self:ModularCreateDroppedFakeModel()
		end

		self:ModularCreateDroppedModels()

		local basePosition, baseAngles = LocalToWorld(
			self.WorldPartsOffsetPos or MOD_VECTOR_ZERO,
			self.WorldPartsOffsetAng or MOD_ANGLE_ZERO,
			self:GetPos(),
			self:GetAngles()
		)

		local fake = self.ModularDroppedFakeWorldModel
		local parts = self.ModularParts

		if IsValid(fake) then
			fake:SetRenderOrigin(basePosition)
			fake:SetRenderAngles(baseAngles)
			fake:SetPos(basePosition)
			fake:SetAngles(baseAngles)
			fake:SetupBones()
		end

		if istable(parts) and istable(self.ModularDroppedPartModels) then
			local positioned = {}
			local function positionPart(partName)
				if positioned[partName] then return positioned[partName] end
				local partData = parts[partName]
				local model = self.ModularDroppedPartModels[partName]
				if not IsValid(model) or not istable(partData) then return end

				local boneName = partData.bone or ""
				local extraPosition = MOD_VECTOR_ZERO
				local extraAngles = MOD_ANGLE_ZERO

				if partName == "magazine" and self.WorldMagazineBoneOverride then
					boneName = self.WorldMagazineBoneOverride
					extraPosition = self.WorldMagazineOffsetPos or MOD_VECTOR_ZERO
					extraAngles = self.WorldMagazineOffsetAng or MOD_ANGLE_ZERO
				end

				local partBasePosition, partBaseAngles = basePosition, baseAngles

				if partData.parent then
					local parent = positionPart(partData.parent)
					if not IsValid(parent) then return end
					partBasePosition, partBaseAngles = parent:GetPos(), parent:GetAngles()
				elseif IsValid(fake) and isstring(boneName) and boneName ~= "" then
					local boneID = fake:LookupBone(boneName)
					if boneID ~= nil then
						local boneMatrix = fake:GetBoneMatrix(boneID)
						if boneMatrix then
							partBasePosition = boneMatrix:GetTranslation()
							partBaseAngles = boneMatrix:GetAngles()
						end
					end
				end

				local localPosition = (partData.pos or MOD_VECTOR_ZERO) + extraPosition
				local localAngles = Angle(
					(partData.ang or MOD_ANGLE_ZERO).p,
					(partData.ang or MOD_ANGLE_ZERO).y,
					(partData.ang or MOD_ANGLE_ZERO).r
				)
				localAngles:Add(extraAngles)

				local position, angles = LocalToWorld(localPosition, localAngles, partBasePosition, partBaseAngles)
				position, angles = self:ApplyManagedStockPartOffset(partName, position, angles)

				model:SetRenderOrigin(position)
				model:SetRenderAngles(angles)
				model:SetPos(position)
				model:SetAngles(angles)
				model:SetupBones()

				ModularApplyPartAppearance(model, partData)
				positioned[partName] = model
				return model
			end

			for partName in pairs(parts) do
				positionPart(partName)
			end
		end

		if IsValid(fake) then
			fake:DrawModel()
		end

		if istable(parts) and istable(self.ModularDroppedPartModels) then
			for partName, partData in pairs(parts) do
				local model = self.ModularDroppedPartModels[partName]
				if IsValid(model) then
					model:DrawModel()
				end
			end
		end

		local originalWorldModel = self.worldModel
		self.worldModel = fake
		self:DrawAttachments()
		self.worldModel = originalWorldModel
	end

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:ModularDrawDroppedModel()
	end

	function SWEP:DrawWorldModelTranslucent()
		local owner = self:GetOwner()
		if IsValid(owner) and owner:IsPlayer() then return end
		self:ModularDrawDroppedModel()
	end

	function SWEP:OnRemove()
		self:ModularRemoveDroppedModels()
		self:CleanupARC9DefaultLHIKSource()
		for _, model in pairs(self.ModularHeldPartModels or {}) do
			if IsValid(model) then model:Remove() end
		end
		self.ModularHeldPartModels = nil
		self.ModularHeldPartPaths = nil
		self.HeldMagCSModel = nil
	end
end

if SERVER then
	util.AddNetworkString("HenchmanUSP_StopMusic")
	util.AddNetworkString("HenchmanUSP_PlayMusic")

	hook.Add("PlayerDeath", "HenchmanUSP_StopMusic", function(ply)
		net.Start("HenchmanUSP_StopMusic")
		net.Send(ply)
	end)
end

if CLIENT then
	net.Receive("HenchmanUSP_PlayMusic", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		if ply.HenchmanMusic then
			ply.HenchmanMusic:Stop()
		end

		ply.HenchmanMusic = CreateSound(ply, "weapons/darsu_eft/usp/Remorse.ogg")
		ply.HenchmanMusic:ChangeVolume(0.5, 0)
		ply.HenchmanMusic:Play()
	end)

	net.Receive("HenchmanUSP_StopMusic", function()
		local ply = LocalPlayer()
		if not IsValid(ply) then return end

		if ply.HenchmanMusic then
			ply.HenchmanMusic:Stop()
			ply.HenchmanMusic = nil
		end
	end)
end
