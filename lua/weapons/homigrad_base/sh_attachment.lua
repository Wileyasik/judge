AddCSLuaFile()
local angFull = Angle(-30, 30, 30)
local angZero = Angle(0, 0, 0)
hg.attachments = hg.attachments or {}
SWEP.availableAttachments = {}
local hg_random_atts = ConVarExists("hg_random_atts") and GetConVar("hg_random_atts") or CreateConVar("hg_random_atts", 0, FCVAR_SERVER_CAN_EXECUTE, "Toggle random attachments on weapon spawn", 0, 1)

local function muzzleCalibersForWeapon(wep)
	local ammo = wep.Primary and wep.Primary.Ammo
	local calibers = {}
	if ammo == "5.45x39 mm" then calibers["545"] = true end
	if ammo == "7.62x39 mm" or (isstring(ammo) and string.find(ammo, ".366", 1, true)) then calibers["762x39"] = true end
	if ammo == "5.56x45 mm" then calibers["556"] = true end
	if ammo == "7.62x51 mm" or ammo == "7.62x54 mm" or ammo == "7.62x54R mm" or ammo == ".300 Blackout" then calibers["762x51"] = true end
	local class = wep.GetClass and wep:GetClass() or wep.ClassName
	if class == "weapon_nl545" then calibers["556"] = true end
	if class == "weapon_mk47" then calibers["762x51"] = true end
	return calibers
end

function SWEP:SetupMuzzleAttachments()
	local slot = self.availableAttachments and self.availableAttachments.barrel
	if not istable(slot) or not hg.attachments.barrel then return end
	if self.DisableMuzzleDevices then return end

	local calibers = muzzleCalibersForWeapon(self)
	local present = {}
	for _, entry in pairs(slot) do
		if istable(entry) and isstring(entry[1]) then present[entry[1]] = true end
	end

	local standard
	for id, definition in pairs(hg.attachments.barrel) do
		if not istable(definition.calibers) then continue end
		local compatible
		for caliber in pairs(calibers) do
			if definition.calibers[caliber] then compatible = true break end
		end
		if not compatible then continue end
		if definition.standard and not standard then standard = id end
		if not definition.standard and not present[id] then
			slot[#slot + 1] = {id, Vector(0, 0, 0), {}}
			present[id] = true
		end
	end

	if standard then slot.empty = {standard, Vector(0, 0, 0), {}} end
end

function SWEP:UpdateAttachmentModifiers()
	self.BaseErgonomics = self.BaseErgonomics or self.Ergonomics or 1
	local barrel = self:GetAttachmentInfo("barrel")
	self.Ergonomics = self.BaseErgonomics * (barrel and barrel.ergonomicsMul or 1)
end

function SWEP:GetAttachmentRecoilMul()
	local barrel = self:GetAttachmentInfo("barrel")
	return barrel and barrel.recoilMul or 1
end

function SWEP:ClearAttachments()
	self:SetupMuzzleAttachments()
	self.attachments = {
		barrel = {},
		sight = {},
		mount = {},
		grip = {},
		underbarrel = {},
		gp25 = {},
		magwell = {},
	}

	if SERVER then
		if self.attachments and table.IsEmpty(self.attachments.barrel) then self.attachments.barrel = self.availableAttachments.barrel and self.availableAttachments.barrel["empty"] or {} end
		if self.attachments and table.IsEmpty(self.attachments.sight) then self.attachments.sight = self.availableAttachments.sight and self.availableAttachments.sight["empty"] or {} end
		if self.attachments and table.IsEmpty(self.attachments.mount) then self.attachments.mount = self.availableAttachments.mount and self.availableAttachments.mount["empty"] or {} end
	end

	if self.StartAtt then
		for i,att in ipairs(self.StartAtt) do
			hg.SetAttachment(self.attachments,att,self:GetClass())
		end
	end
	self:UpdateAttachmentModifiers()

	if SERVER then timer.Simple(0.2, function() self:SetNetVar("attachments",self.attachments) end) end
	self:CallOnRemove("removeAtt", function()
		self.attachments = nil
		if self.modelAtt then
			for atta, model in pairs(self.modelAtt) do
				if not atta then continue end
				if IsValid(model) then model:Remove() end
				self.modelAtt[atta] = nil
			end
		end
	end)

	return self.attachments
end

function hg.ClearAttachments(wep)
	local self = weapons.Get(wep)
	local tbl = {}
	if self.SetupMuzzleAttachments then self:SetupMuzzleAttachments() end

	tbl.attachments = {
		barrel = {},
		sight = {},
		mount = {},
		grip = {},
		underbarrel = {},
		gp25 = {},
		magwell = {},
	}

	if SERVER then
		if tbl.attachments and table.IsEmpty(tbl.attachments.barrel) then tbl.attachments.barrel = self.availableAttachments.barrel and self.availableAttachments.barrel["empty"] or {} end
		if tbl.attachments and table.IsEmpty(tbl.attachments.sight) then tbl.attachments.sight = self.availableAttachments.sight and self.availableAttachments.sight["empty"] or {} end
		if tbl.attachments and table.IsEmpty(tbl.attachments.mount) then tbl.attachments.mount = self.availableAttachments.mount and self.availableAttachments.mount["empty"] or {} end
	end

	if self.StartAtt then
		for i,att in ipairs(self.StartAtt) do
			hg.SetAttachment(tbl.attachments,att,wep)
		end
	end
	
	return tbl.attachments
end

function hg.SetAttachment(tbl,att,wep)
	if not wep then return end
	local wep = weapons.Get(wep)
	if not wep then return end
	local placement = nil

	for plc, tbl in pairs(hg.attachments) do
		placement = tbl[att] and tbl[att][1] or placement
	end

	if not placement then return end

	local i
	if wep.availableAttachments[placement] then
		for n, atta in pairs(wep.availableAttachments[placement]) do
			i = istable(atta) and atta[1] == att and n or i
		end
	end
	
	tbl[placement] = i and wep.availableAttachments[placement][i] or {att, {}}
end

function SWEP:HasAttachment(whereabouts, attachment)
	if whereabouts == "sight" and attachment == "optic" and self.scopedef then return true, false end
	if not self.attachments then return false end
	local has = self.attachments[whereabouts]
	if not has or table.IsEmpty(has) then return false end
	if attachment then
		has = string.find(has[1], attachment) and true
	else
		has = has[1] ~= "empty"
	end
	
	return has and self.attachments[whereabouts], has and hg.attachments[whereabouts][self.attachments[whereabouts][1]]
end

function SWEP:GetAttachmentModel(whereabouts, attachment)
	if self:HasAttachment(whereabouts,attachment) and self.modelAtt and self.modelAtt[whereabouts] then
		return self.modelAtt[whereabouts]
	end
end

function SWEP:GetAttachmentInfo(whereabouts, attachment)
	local att,attdata = self:HasAttachment(whereabouts,attachment)

	return attdata
end

function SWEP:GetActiveMagazineModel(fallback, role)
	local data = self:GetAttachmentInfo("magwell")
	if not data then return fallback end

	local roleModel = role and data[role .. "Model"]
	return roleModel or data[2] or fallback
end

function SWEP:GetMagazineReloadAnimation(empty)
	local attachment, data = self:HasAttachment("magwell")
	if not attachment or not data then return end

	local animations = self.MagazineReloadAnimations and self.MagazineReloadAnimations[attachment[1]]
	if animations then return animations[empty and 2 or 1] end

	return empty and data.reload_empty or data.reload
end

function SWEP:ThinkAtt()
end

local colBlackTransparent = Color(0, 0, 0, 125)
local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
function SWEP:ThinkAtt()
	if true then return end
	if SERVER then return end
	local att = self:GetMuzzleAtt()
	local owner = self:GetOwner()
	if not self:IsLocal() then return end
end


local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
local vecadd = Vector(0,0,0)
local hg_attachment_draw_distance = ConVarExists("hg_attachment_draw_distance") and GetConVar("hg_attachment_draw_distance") or CreateClientConVar("hg_attachment_draw_distance", 0, true, nil, "distance to draw attachments", 0, 4096)

function SWEP:DrawAttachments()
	local owner = self:GetOwner()
	self.attacments = self:GetNetVar("attachments",{})
	//self.Supressor = (self:HasAttachment("barrel", "supressor") and true) or self.SetSupressor
	local magwell, magwellData = self:HasAttachment("magwell")
	self.BaseMagazineCapacity = self.Primary.DefaultClip or self.BaseMagazineCapacity or self.Primary.ClipSize
	self.Primary.ClipSize = magwellData and magwellData.capacity or self.BaseMagazineCapacity
	if SERVER and self:Clip1() > self.Primary.ClipSize then
		self:SetClip1(self.Primary.ClipSize)
	end
	
	if SERVER then return end

	local gun = self:GetWeaponEntity()
	local att = self:GetMuzzleAtt(self:GetWM(), true)
	if not att then return end
	local pos, ang = att.Pos, att.Ang
	
	local available = self.availableAttachments

	if not IsValid(gun) or not att then return end
	
	if self.attachments == nil and CLIENT then
		self:SyncAtts()
		return
	end
	

	if self.availableAttachments.mount then
		if self.availableAttachments.mount then
			if not self.attachments then return end
			local data = self.attachments["sight"] and self.attachments["sight"][1] and hg.attachments.sight[self.attachments["sight"][1]] or self.attachments["underbarrel"] and self.attachments["underbarrel"][1] and hg.attachments.underbarrel[self.attachments["underbarrel"][1]]
			if data then
				self.attachments.mount = self.availableAttachments.mount[data.mountType]
			end
		end
	end
	

	self.modelAtt = self.modelAtt or {}
	local flagRemovehuy = false
	for plc,att in pairs(self.attachments) do
		local attachmentGroup = hg.attachments[plc]
		local attdata = attachmentGroup and attachmentGroup[att[1]]
		if not attdata then continue end
		if attdata and attdata.weaponManagedModel then continue end
		
		local tblhuy = self:HasAttachment(plc) and available[plc] and ((available[plc][att[1]] and istable(available[plc][att[1]]) and available[plc][att[1]][2]) or (istable(available[plc]["removehuy"]) and available[plc]["removehuy"][attdata.mountType] or available[plc]["removehuy"]))
		if tblhuy then flagRemovehuy = true end
		
		if not tblhuy and not flagRemovehuy then tblhuy = att[2] end
		
		if istable(tblhuy) and not table.IsEmpty(tblhuy) then
			for index, mat in pairs(tblhuy) do
				local submat = gun:GetSubMaterial(index)
				--submat = #submat > 0 and submat or gun:GetMaterials()[index]
				
				if submat ~= (mat or "null") then gun:SetSubMaterial(index, mat or "null") end
			end
		end
		--print(att[1])
		if not self:HasAttachment(plc,att[1]) then continue end

		local model = self.modelAtt[plc]
		
		if owner ~= LocalPlayer() and hg_attachment_draw_distance:GetInt() ~= 0 and (hg_attachment_draw_distance:GetInt() ^ 2) < ((LocalPlayer():GetPos() - gun:GetPos()):LengthSqr()) and not attdata.shouldalwaysdraw then if IsValid(model) then model:Remove() end continue end
		
		if not IsValid(model) and attdata[2] and attdata[2] ~= "" then
			self.modelAtt[plc] = ClientsideModel(attdata[2])
			model = self.modelAtt[plc]
			model:SetNoDraw(true)
		end
		
		if not IsValid(model) then continue end

		if attdata[4] and not table.IsEmpty(attdata[4]) then
			for index, mat in pairs(attdata[4]) do
				local submat = model:GetSubMaterial(index)
				submat = #submat > 0 and submat or model:GetMaterials()[index]

				if submat ~= (mat or "null") then model:SetSubMaterial(index, mat or "null") end
			end
		end

		self:Attachment_Transform(model,pos,ang,plc,att,attdata,available)

		local previewFrame = hg.attachmentsMenuPanel
		if attdata.drawFunction and not (IsValid(previewFrame) and previewFrame.previewPlacement == plc) then
			attdata.drawFunction(self,model)
		end

		hg.attachmentFunc(self, attdata)
	end
end

if CLIENT then
	local vec = Vector()
	local addPos = Vector()
	local vecZero = Vector()
	local posa = Vector()
	local newview = Vector()
	function SWEP:GetCameraOverride(view, baseZoomPos)
		local info
		local hasGP25 = self.HasGP25 and self:HasGP25()
		local gp25Active = hasGP25 and self:IsGP25Active()
		if hasGP25 then
			self.GP25AimWeight = LerpFT(self.GP25AimTransitionSpeed or 0.04, self.GP25AimWeight or 0, gp25Active and 1 or 0)
		end
		if gp25Active or hasGP25 and (self.GP25AimWeight or 0) > 0.001 then
			info = self:GetAttachmentInfo("gp25", "gp25")
		end
		info = info or self:GetAttachmentInfo("sight")
		local sight = info and info.offsetView
		if not info and not (self.HasGP25 and self:HasGP25()) then
			info = self:GetAttachmentInfo("underbarrel")
			sight = info and info.offsetView
		end
		if sight then
			newview[1] = -sight[3]
			newview[2] = -sight[1]
			newview[3] = -sight[2]
			local model = self:GetAttachmentModel(info[1])
			if not IsValid(model) then return view.origin end
			local ang = select(3,self:GetTrace())
			ang:RotateAroundAxis(ang:Forward(),90)
			local pos = LocalToWorld(newview,angle_zero,model:GetPos(),ang)
			
			if info.viewFunction then
				pos = info.viewFunction(self,model,pos)
			end
			
			if info[1] == "gp25" and hasGP25 and baseZoomPos then
				return LerpVector(self.GP25AimWeight or 0, baseZoomPos, pos)
			end
			return pos
		end
		return false
	end
end

local mount3ScopeCorrections = {
	optic2 = Vector(0, -1.5, 1.4),
	optic5 = Vector(0, -1.5, 1.4),
	optic6 = Vector(0, -1.5, 1.4),
	optic19 = Vector(0, -1.3, 1.4),
	optic21 = Vector(0, -1.3, 1.4),
	optic23 = Vector(0, -1.3, 1.4),
}

function SWEP:Attachment_Transform(model,pos,ang,plc,att,attdata,available)
	local slot = available[plc]
	local overrides = self.HGAttachmentTransformOverrides
	local override = overrides and overrides[plc] and overrides[plc][att[1]]
	local mountBone = override and override.bone or not override and slot and slot["mountBone"]
	if mountBone then
		local weaponModel = self:GetWM()
		local bone = IsValid(weaponModel) and weaponModel:LookupBone(mountBone)
		local matrix = bone and weaponModel:GetBoneMatrix(bone)
		if matrix then
			pos = matrix:GetTranslation()
			ang = matrix:GetAngles()
		end
	end

	local entryOffset = override and override.offset or att[2]
	local mountOffset = override and override.mount
	if not isvector(mountOffset) and slot then
		mountOffset = isvector(slot.mount) and slot.mount or istable(slot.mount) and slot.mount[attdata.mountType]
	end
	local slotAngle = override and override.ang
	if not isangle(slotAngle) and slot then
		slotAngle = isangle(slot.mountAngle) and slot.mountAngle or istable(slot.mountAngle) and slot.mountAngle[attdata.mountType]
	end

	local mountPos = Vector(0, 0, 0)
	if isvector(entryOffset) then mountPos:Add(entryOffset) end
	if isvector(mountOffset) then mountPos:Add(mountOffset) end
	mountPos:Rotate(ang)
	mountPos:Add(pos)

	vecadd:Zero()
	if isvector(entryOffset) then vecadd:Add(entryOffset) end
	local activeMount = self.attachments and self.attachments.mount
	local dovetail = attdata.mountType == "dovetail" or istable(activeMount) and activeMount.mountType == "dovetail"
	if plc == "sight" and not dovetail and isnumber(att.sightSlide) then vecadd.x = vecadd.x + math.Clamp(att.sightSlide, -1, 3) end
	if isvector(mountOffset) then vecadd:Add(mountOffset) end
	if attdata.offset and isvector(attdata.offset) then vecadd:Add(attdata.offset) end
	local mount3Correction = plc == "sight"
		and istable(activeMount)
		and activeMount[1] == "mount3"
		and mount3ScopeCorrections[att[1]]
	if mount3Correction then vecadd:Add(mount3Correction) end
	local addAng = attdata[3] + (slotAngle or angZero)

	vecadd:Rotate(ang)
	vecadd:Add(pos)

	local _, ang = LocalToWorld(vecZero, addAng, vecZero, ang)

	if attdata.transformFunction then
		attdata.transformFunction(self,model,vecadd,ang)
	end

	self.attachmentMenuTransforms = self.attachmentMenuTransforms or {}
	self.attachmentMenuTransforms[plc] = {
		id = att[1],
		frame = FrameNumber(),
		mountPos = Vector(mountPos.x, mountPos.y, mountPos.z),
		pos = Vector(vecadd.x, vecadd.y, vecadd.z),
		ang = Angle(ang.p, ang.y, ang.r)
	}

	if attdata.bBonemerge and not model.bBonemerged then
		model:SetParent(self:GetWM())
		model:AddEffects(EF_BONEMERGE)
		model.bBonemerged = true
	end

	if attdata.fScale and not model.bScaled then
		model:SetModelScale(attdata.fScale,0)
	end
	--model:SetParent(self:GetWM())
	model:SetRenderOrigin(vecadd)
	model:SetRenderAngles(ang)

	model:SetPos(vecadd)
	model:SetAngles(ang)
	
	model:SetupBones()
	local addred = string.find(att[1], "supressor") and 5 * self.dmgStack2 / 30 or 0
	render.SetColorModulation(1 + addred,1,1)
	local previewFrame = hg.attachmentsMenuPanel
	local hiddenByPreview = IsValid(previewFrame) and (previewFrame.previewPlacement == plc or plc == "mount" and IsValid(previewFrame.previewAdapter))
	if not hiddenByPreview and ((IsValid(self:GetOwner()) and attdata.norenderWhenDrop) or not attdata.norenderWhenDrop) then
		model:DrawModel()
	end
	render.SetColorModulation(1,1,1)

	local mountKey = "mountex_" .. plc
	local mount = self.modelAtt[mountKey]
	if IsValid(mount) and (not attdata.mount or mount:GetModel() != attdata.mount) then
		mount:Remove()
		self.modelAtt[mountKey] = nil
		mount = nil
	end

	if attdata.mount then
		if not IsValid(mount) then
			mount = ClientsideModel(attdata.mount)
			mount:SetNoDraw(true)
			self.modelAtt[mountKey] = mount
		end

		local pos = vecZero
		pos:Set(attdata.mountVec or vector_origin)
		pos:Rotate(model:GetAngles())
		pos:Add(model:GetPos())
		local _, ang = LocalToWorld(vecZero, attdata.mountAng or angle_zero, vecZero, model:GetAngles())
		mount:SetRenderOrigin(pos)
		mount:SetRenderAngles(ang)
		mount:SetPos(pos)
		mount:SetAngles(ang)
		mount:SetupBones()
		if not hiddenByPreview then mount:DrawModel() end
	end

	if attdata.holotex then--just create a second model with only glass for stencil (why cant i render just the glass bruuh)
		local model2 = model.model
		if not IsValid(model2) then
			model2 = ClientsideModel(attdata[2])
			model2:SetNoDraw(true)
			model.model = model2
			
			self.holomodels = self.holomodels or {}
			self.holomodels[model2] = true

			model:CallOnRemove("removeshithole",function()
				self.holomodels = self.holomodels or {}
				
				if self.holomodels then
					self.holomodels[model2] = nil
				end

				if IsValid(model2) then
					model2:Remove()
				end
			end)

		end
		
		if not model2.submats then
			model2:SetSubMaterial(0,"null")
			model2:SetSubMaterial(1,"white")

			model:SetSubMaterial(0,"")
			model:SetSubMaterial(1,"null")
			for i,mat in pairs(model:GetMaterials()) do
				if mat != attdata.holotex or mat != attdata.mat then continue end
				model:SetSubMaterial(i,"null")
			end
			model2.submats = true
		end

		model2:SetRenderOrigin(vecadd)
		model2:SetRenderAngles(ang)

		model2:SetPos(vecadd)
		model2:SetAngles(ang)

		model2:SetupBones()
		model2:SetModelScale(attdata.modelscale or 1)
		//model2:DrawModel()
	end
end

if SERVER then
	util.AddNetworkString("hmcd_togglelaser")
	local laserThingies = {
		[0] = 1,
		[1] = 0,
		[2] = 3,
		[3] = 2,
	}

	concommand.Add("hmcd_togglelaser", function(ply, cmd, args)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.attachments then return end
		if not wep:HasAttachment("underbarrel") then return end
		wep.lasertoggle = laserThingies[wep.lasertoggle or 0]
		ply:EmitSound("weapons/ump45/ump45_fireselect.wav", 65)
		net.Start("hmcd_togglelaser")
		net.WriteEntity(wep)
		net.WriteInt(wep.lasertoggle, 5)
		net.Broadcast()
	end)

	local flashlightThingies = {
		[0] = 2,
		[2] = 0,
		[1] = 3,
		[3] = 1,
	}

	hook.Add("PlayerSwitchFlashlight", "flashlightHuy", function(ply)
		local wep = ply:GetActiveWeapon()
		if not IsValid(wep) or not wep.attachments then return end
		if not wep:HasAttachment("underbarrel") then return false end
		wep.lasertoggle = flashlightThingies[wep.lasertoggle or 0]
		ply:EmitSound("weapons/ump45/ump45_fireselect.wav", 65)
		net.Start("hmcd_togglelaser")
		net.WriteEntity(wep)
		net.WriteInt(wep.lasertoggle, 5)
		net.Broadcast()
		return false
	end)
else
	net.Receive("hmcd_togglelaser", function()
		local wep = net.ReadEntity()
		local turn = net.ReadInt(5)
		wep.lasertoggle = turn
	end)
end

if CLIENT then
	local function removeFlashlights(self)
		if self.flashlight and self.flashlight:IsValid() then
			self.flashlight:Remove()
			self.flashlight = nil
		end
	end

	local vecZero, angZero = Vector(0, 0, 0), Angle(0, 0, 0)
	local mat = Material("sprites/rollermine_shock")
	local mat2 = Material("sprites/light_glow02_add_noz")
	local mat3 = Material("effects/flashlight/soft")
	local mat4 = Material("sprites/light_ignorez", "alphatest")
	local colorTransparent = Color(0,0,0,0)
	function SWEP:DrawLaser()
		if not self.shouldTransmit then return end
		local laser = self.attachments.underbarrel
		if not laser or table.IsEmpty(laser) and not self.laser then return end
		local attachmentData
		if laser and not table.IsEmpty(laser) then
			attachmentData = hg.attachments.underbarrel[laser[1]]
		else
			attachmentData = self.laserData
		end

		if not self.modelAtt then
			self.modelAtt = {}
			return
		end
		
		local model = self.modelAtt["underbarrel"] or self:GetWeaponEntity()
		if not IsValid(model) then return end
		local pos, anga = model:GetPos(), model:GetAngles()
		local pos, ang = LocalToWorld(attachmentData.offsetPos or vecZero, attachmentData.offsetAng or angZero, pos, anga)
		//local tr, _, _ = self:GetTrace()
		
		//if not IsValid(self:GetOwner()) or not self:GetOwner():IsPlayer() then ang = anga end

		--[[
			if not IsValid(lply.EZNVGlamp) then
				lply.EZNVGlamp = ProjectedTexture()
				lply.EZNVGlamp:SetTexture("effects/flashlight001")
				lply.EZNVGlamp:SetBrightness(.05)
			else
				local Ang = EyeAngles()
				lply.EZNVGlamp:SetPos(lply:EyePos())
				lply.EZNVGlamp:SetEnableShadows(false)
				lply.EZNVGlamp:SetAngles(Ang)
				lply.EZNVGlamp:SetConstantAttenuation(.1)
				local FoV = lply:GetFOV()
				lply.EZNVGlamp:SetFOV(FoV+45)
				lply.EZNVGlamp:SetFarZ(150000 / FoV)
				lply.EZNVGlamp:Update()
			end
		--]]

		if (self.lasertoggle == 2 or self.lasertoggle == 3) and attachmentData.supportFlashlight and (not attachmentData.nvgFlashlight or (lply.NVGEnabled)) then
			self.flashlight = self.flashlight or ProjectedTexture()
			local tr = util.TraceLine({
				start = pos + ang:Forward() * 10,
				endpos = pos + ang:Forward() * 400 ,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_VISIBLE
			})
			if tr.Hit then
				--local dlight = DynamicLight( self:EntIndex() )
				--if ( dlight ) then
				--	local frac = (1 - tr.Fraction)
				--	if (1 - tr.Fraction) > 0.96 then
				--		frac = 0
				--	end
				--	self.DynmanicFlashlightLerpFrac = LerpFT(0.05,self.DynmanicFlashlightLerpFrac or frac, frac)
				--	dlight.pos = tr.HitPos + tr.HitNormal * 30
				--	dlight.r = 255
				--	dlight.g = 255
				--	dlight.b = 255
				--	dlight.brightness = 1 * self.DynmanicFlashlightLerpFrac
				--	dlight.decay = 200
				--	dlight.size = 556 * self.DynmanicFlashlightLerpFrac
				--	dlight.dietime = CurTime() + 0.1
				--end
			end
			if self.flashlight and self.flashlight:IsValid() then
				self.flashlight:SetTexture((attachmentData.mat or mat3):GetTexture("$basetexture"))
				self.flashlight:SetFarZ(attachmentData.farZ or 1500)
				self.flashlight:SetHorizontalFOV(attachmentData.size or 50)
				self.flashlight:SetVerticalFOV(attachmentData.size or 50)
				self.flashlight:SetConstantAttenuation(attachmentData.brightness2 or 1)
				self.flashlight:SetLinearAttenuation(attachmentData.brightness or 50)
				self.flashlight:SetPos(pos + ang:Forward() * 10)
				self.flashlight:SetAngles(ang)
				if (self.flashlightupdate or 0) < CurTime() then 
					self.flashlightupdate = CurTime() + 0.01
					self.flashlight:Update()
				end
				local view = render.GetViewSetup(true)
				local deg = ang:Forward():Dot(view.angles:Forward())
				
				local chekvisible = util.TraceLine({
					start = pos + ang:Forward() * 10,
					endpos = view.origin,
					filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
					mask = MASK_VISIBLE
				})
				if deg < 0 and not chekvisible.Hit then
					render.SetMaterial(mat2)
					render.DrawSprite(pos + ang:Forward() * 0.5, 200 * math.min(deg, 0), 20 * math.min(deg, 0), color_white)
					render.DrawSprite(pos + ang:Forward() * 0.5, 50 * math.min(deg, 0), 150 * math.min(deg, 0), color_white)
				end
			end
		else
			removeFlashlights(self)
		end

		if self.lasertoggle == 1 or self.lasertoggle == 3 then
			local tr = util.TraceLine({
				start = pos,
				endpos = pos + ang:Forward() * 10000,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_SHOT
			})

			render.SetMaterial(mat)
			render.DrawBeam(pos, tr.HitPos, 5, 0, 800, ColorAlpha(attachmentData.color,20))
			--local view = render.GetViewSetup(true)
			--[[local chekvisible = util.TraceLine({
				start = tr.HitPos,
				endpos = view.origin,
				filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
				mask = MASK_VISIBLE
			})--]]
			--if not tr.Hit then
				local distance = pos:Distance(tr.HitPos)
				distance = math.max(distance/300,0.2)
				render.SetStencilWriteMask( 0xFF )
				render.SetStencilTestMask( 0xFF )
				render.SetStencilReferenceValue( 0 )
				render.SetStencilCompareFunction( STENCIL_ALWAYS )
				render.SetStencilPassOperation( STENCIL_KEEP )
				render.SetStencilFailOperation( STENCIL_KEEP )
				render.SetStencilZFailOperation( STENCIL_KEEP )
				render.ClearStencil()
				
				-- Enable stencils
				render.SetStencilEnable( true )
				-- Set everything up everything draws to the stencil buffer instead of the screen
				render.SetStencilReferenceValue( 1 )
				render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
				render.SetStencilPassOperation( STENCIL_REPLACE )
				render.SetStencilFailOperation( STENCIL_KEEP )
				render.SetStencilZFailOperation( STENCIL_KEEP )

				render.SetColorMaterial()
				render.DrawSphere(tr.HitPos,math.min(5 * (attachmentData.laserSize or 1) * distance,20),20,20,colorTransparent)

				render.SetStencilCompareFunction( STENCIL_EQUAL )

				--render.ClearBuffersObeyStencil(128,128,128,128,false)
				
				render.SetMaterial(mat2)
				local bLPly = self:GetOwner() == LocalPlayer()
				if bLPly then
					distance = distance * 1.5
				end
				local div = distance/(bLPly and 6 or 2.5) * (attachmentData.laserSize ~= nil and (attachmentData.laserSize / 10) or 1)
				local colore = Color(attachmentData.color.r/(div),attachmentData.color.g/(div),attachmentData.color.b/(div))		
				local fSize = math.min(5 * (attachmentData.laserSize or 1) * distance,bLPly and 120 or 30)
				render.DrawSprite(tr.HitPos, fSize, fSize, colore)

				--render.DrawQuadEasy( tr.HitPos, tr.HitNormal, math.min(5 * distance,20), math.min(5 * distance,20), colore, 0 )

				render.SetStencilEnable( false )

				local view = render.GetViewSetup(true)
				local deg = ang:Forward():Dot(view.angles:Forward())
				deg = math.ease.InBack(-deg-0.355)*40
				deg = -deg
				local distance = math.min(pos:Distance(view.origin)/200,3)
				local chekvisible = util.TraceLine({
					start = pos + ang:Forward() * 10,
					endpos = view.origin,
					filter = {self, self:GetOwner(), self:GetWeaponEntity(), model, LocalPlayer()},
					mask = MASK_VISIBLE
				})
				if deg < 0 and not chekvisible.Hit then
					render.SetMaterial(mat2)
					render.DrawSprite(pos + ang:Forward() * 3, 125 * math.min(deg, 0)*math.max(distance,1), 55 * math.min(deg, 0)*math.max(distance,1), attachmentData.color)
					render.DrawSprite(pos + ang:Forward() * 3, 55 * math.min(deg, 0)*math.max(distance,1), 125 * math.min(deg, 0)*math.max(distance,1), attachmentData.color)
				end
			--end
		end
	end
end

function SWEP:AttachAnim()
	self:SetNWFloat("addAttachment",CurTime())
end

function SWEP:SyncAtts()
	--net.Start("sync_atts")
	--net.WriteEntity(self)
	--net.SendToServer()
end-- ХD

if CLIENT then
	concommand.Add("ZB_AttachAdd", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachAdd")
		net.WriteString(att)
		net.SendToServer()
	end)

	concommand.Add("ZB_AttachRemove", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachRemove")
		net.WriteString(att)
		net.SendToServer()
	end)

	concommand.Add("ZB_AttachDrop", function(ply, cmd, args)
		local att = args[1]
		net.Start("ZB_AttachDrop")
		net.WriteString(att)
		net.SendToServer()
	end)

	local CreateMenu
	local menuPanel
	local function dropAttachment(att)
		RunConsoleCommand("ZB_AttachDrop", att)
	end

	local function removeAttachment(att)
		RunConsoleCommand("ZB_AttachRemove", att)
		/*timer.Simple(0.6,function()
			if IsValid(menuPanel) then
				CreateMenu()
			end
		end)*/
	end

	local function addAttachment(att)
		RunConsoleCommand("ZB_AttachAdd", att)
		/*timer.Simple(0.6,function()
			if IsValid(menuPanel) then
				CreateMenu()
			end
		end)*/
	end

	surface.CreateFont("AttachFONT", {
		font = "Courier Prime",
		size = ScreenScale(5),
		extended = true,
		weight = 500,
		antialias = true
	})

	local plyAttachments = {}
	local weaponAttachments = {}
	local drop = false
	local gray = Color(200, 200, 200)
	local red = Color(75,25,25)
	local redselected = Color(150,0,0)
	local blue = Color(200, 200, 255)
	local black = Color(24,24,24)
	local whitey = Color(255, 255, 255)
	local chosen2
	local doubleclick

	local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
	
	local function refreshtbl()
		local tblcpy = {}

		local inv = lply:GetNetVar("Inventory")
		if inv == nil then return end

		local tbl = inv["Attachments"]
		local wep = lply:GetActiveWeapon()
		local achtbl = {}
		if IsValid(wep) and ishgweapon(wep) then
			achtbl = lply:GetActiveWeapon():GetNetVar("attachments")
		end
		
		for i, att in pairs(tbl) do
			if !att then continue end
			table.insert(tblcpy, {att, false})
		end

		if achtbl then
			for i, att in pairs(achtbl) do
				if !att or !next(att) then continue end
				table.insert(tblcpy, {att[1], true})
			end
		end

		return tblcpy
	end

	hg.GetAttachmentsInv = refreshtbl

	hook.Add("OnNetVarSet", "attachmentPanelRefresh", function(index, key, var)
		if key == "Inventory" or key == "attachments" and Entity(index) == lply:GetActiveWeapon() then
			if IsValid(hg.attachmentsMenuPanel) and hg.attachmentsMenuPanel.RefreshTbl then
				hg.attachmentsMenuPanel:RefreshTbl()
			end
		end
	end)

	local mat = Material("homigrad/vgui/gradient_left.png")
	local clr_blackalpha = Color(0, 0, 0, 100)

	-- Styling shared with the ammo drop / armor menus (see sh_ammostuff.lua / sh_inventory.lua)
	local attMenuOutline     = Color(255, 255, 255, 255)
	local attMenuFill        = Color(0, 0, 0, 245)
	local attMenuGradient    = Color(40, 40, 40, 55)
	local attMenuButtonIdle  = Color(20, 20, 20, 235)
	local attMenuButtonHover = Color(34, 34, 34, 235)
	local attMenuEquipIdle   = Color(20, 20, 20, 235)
	local attMenuEquipHover  = Color(34, 34, 34, 235)
	local attMenuDropIdle    = Color(50, 20, 20, 235)
	local attMenuDropHover   = Color(75, 28, 28, 235)

	local gradient_u = Material("vgui/gradient-u")
	local gradient_d = Material("vgui/gradient-d")

	local function PaintInnerFrame(self, w, h)
		hg.DrawBlur(self)
		surface.SetDrawColor(attMenuFill)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(attMenuGradient)
		surface.SetMaterial(gradient_d)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(attMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintButton(self, w, h)
		local hovered = self:IsHovered()
		surface.SetDrawColor(hovered and (self.equipped and attMenuEquipHover or attMenuButtonHover) or (self.equipped and attMenuEquipIdle or attMenuButtonIdle))
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(attMenuGradient)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetDrawColor(attMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintDropButton(self, w, h)
		surface.SetDrawColor(self:IsHovered() and attMenuDropHover or attMenuDropIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(attMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintCloseButton(self, w, h)
		surface.SetDrawColor(self:IsHovered() and attMenuButtonHover or attMenuButtonIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(attMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		draw.SimpleText(self:GetText(), "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local function PaintScrollBar(self, w, h)
		surface.SetDrawColor(16, 16, 16, 220)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(attMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintScrollGrip(self, w, h)
		self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.3, self:IsHovered() and 0.5 or 0.3)
		local col = 255 * self.lerpcolor
		surface.SetDrawColor(col, col, col, 255)
		surface.DrawRect(0, 0, w, h)
	end

	-- Builds and styles a scroll panel that matches the ammo/armor menus
	local function makeScroll(frame)
		local scroll = vgui.Create("DScrollPanel", frame)
		scroll:Dock(FILL)
		scroll:DockMargin(8, 40, 8, 6)
		scroll.Paint = PaintInnerFrame
		frame.scroll = scroll

		local sbar = scroll:GetVBar()
		sbar:SetHideButtons(true)
		sbar.Paint = PaintScrollBar
		sbar.btnGrip.Paint = PaintScrollGrip

		return scroll
	end

	local slotOrder = {"sight", "barrel", "underbarrel", "grip", "magwell"}
	local slotNames = {
		sight = "SCOPES",
		barrel = "MUZZLE",
		underbarrel = "UNDERBARREL",
		grip = "FOREGRIP",
		magwell = "MAGAZINE"
	}
	local slotSides = {sight = 1, barrel = -1, underbarrel = -1, grip = -1, magwell = -1}
	local slotRows = {sight = 0.3, underbarrel = 0.14, barrel = 0.345, grip = 0.55, magwell = 0.755}
	local slotAnchorBones = {
		magwell = {"mod_magazine"}
	}
	-- Value from 0 to 1: 0.5 pauses inspect at 50%, 0.2 at 20%, and so on.
	local inspectFreezeFraction = 0.3
<<<<<<< HEAD
	local inspectOpenSound = "arc9_eft_shared/weap_handon.ogg"
	local inspectCloseSound = "arc9_eft_shared/weapon_generic_spin6.ogg"
	local menuAccent = Color(210, 225, 230)
	local menuMuted = Color(145, 155, 160)
	local menuPanelColor = Color(10, 13, 15, 238)
=======
	local fallbackAccent = Color(55, 55, 55)
	local fallbackPanel = Color(10, 10, 10)
	local menuText = Color(235, 235, 235)
	local menuMuted = Color(145, 150, 152)
	local attachmentLineColor = Color(255, 255, 255)
	local attachmentFont = "Mx437 IBM PS/55 re."

	local function getMenuAccent()
		return hg.theme and hg.theme.c.accent or fallbackAccent
	end

	local function getMenuPanel(alpha)
		local panel = hg.theme and hg.theme.c.panel or fallbackPanel
		return Color(panel.r, panel.g, panel.b, alpha or 212)
	end

	local function drawAttachmentText(text, font, x, y, color, alignX, alignY)
		draw.SimpleText(text, font, x + 1, y + 1, Color(10, 10, 10, 200), alignX, alignY)
		draw.SimpleText(text, font, x, y, color, alignX, alignY)
	end

	local function drawSelectorCorners(x, y, w, h, color, alpha)
		local inset = 4
		local length = math.min(13, math.floor(math.min(w, h) * 0.24))
		surface.SetDrawColor(color.r, color.g, color.b, alpha or 190)
		surface.DrawRect(x + inset, y + inset, length, 1)
		surface.DrawRect(x + inset, y + inset, 1, length)
		surface.DrawRect(x + w - inset - length, y + h - inset - 1, length, 1)
		surface.DrawRect(x + w - inset - 1, y + h - inset - length, 1, length)
	end

	local function drawAttachmentLink(x1, y1, x2, y2, x3, y3, color, phase)
		surface.SetDrawColor(0, 0, 0, 190)
		for offset = -1, 1 do
			surface.DrawLine(x1 + offset, y1, x2 + offset, y2)
			surface.DrawLine(x2, y2 + offset, x3, y3 + offset)
		end

		surface.SetDrawColor(color.r, color.g, color.b, 125)
		surface.DrawLine(x1, y1, x2, y2)
		surface.DrawLine(x2, y2, x3, y3)

		local firstLength = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
		local secondLength = math.sqrt((x3 - x2) ^ 2 + (y3 - y2) ^ 2)
		local totalLength = firstLength + secondLength
		if totalLength > 0 then
			local distance = phase * totalLength
			local pulseX, pulseY
			if distance <= firstLength and firstLength > 0 then
				local fraction = distance / firstLength
				pulseX = Lerp(fraction, x1, x2)
				pulseY = Lerp(fraction, y1, y2)
			elseif secondLength > 0 then
				local fraction = (distance - firstLength) / secondLength
				pulseX = Lerp(fraction, x2, x3)
				pulseY = Lerp(fraction, y2, y3)
			end
			if pulseX then
				surface.SetDrawColor(color.r, color.g, color.b, 230)
				surface.DrawRect(pulseX - 2, pulseY - 2, 4, 4)
			end
		end
	end

	local scrambleCharacters = {"?", "%", "#", "*", "!", "/", "+", "-"}
	local function getScrambledText(text, startedAt, duration)
		text = tostring(text or "")
		local progress = math.Clamp((RealTime() - startedAt) / duration, 0, 1)
		local revealed = math.floor(#text * progress)
		if revealed >= #text then return text end

		local output = string.sub(text, 1, revealed)
		for index = revealed + 1, #text do
			local character = string.sub(text, index, index)
			output = output .. (character == " " and " " or scrambleCharacters[math.random(#scrambleCharacters)])
		end
		return output
	end
>>>>>>> aef1d8b07196f7efa7cb44de1af1e52c4f7695fb

	surface.CreateFont("HG_Attachment_Title", {
		font = attachmentFont,
		size = 28,
		weight = 700,
		antialias = true,
		extended = true
	})
	surface.CreateFont("HG_Attachment_Label", {
		font = attachmentFont,
		size = 17,
		weight = 600,
		antialias = true,
		extended = true
	})
	surface.CreateFont("HG_Attachment_Small", {
		font = attachmentFont,
		size = 13,
		weight = 500,
		antialias = true,
		extended = true
	})
	surface.CreateFont("HG_Attachment_Card", {
		font = attachmentFont,
		size = 11,
		weight = 600,
		antialias = true,
		extended = true
	})
	surface.CreateFont("HG_Attachment_Micro", {
		font = attachmentFont,
		size = 10,
		weight = 600,
		antialias = true,
		extended = true
	})
	surface.CreateFont("HG_Attachment_Count", {
		font = "Courier Prime",
		size = 13,
		weight = 400,
		italic = true,
		antialias = true,
		extended = true
	})

	local function getAttachmentDefinition(id)
		local placement = hg.GetAttachmentTab(id)
		return placement, placement and hg.attachments[placement] and hg.attachments[placement][id]
	end

	local function getInventoryCounts()
		local counts = {}
		local inv = lply:GetNetVar("Inventory", {})
		for _, id in pairs(inv.Attachments or {}) do
			counts[id] = (counts[id] or 0) + 1
		end
		return counts
	end

	local function getWeaponAttachments(wep)
		return wep:GetNetVar("attachments", wep.attachments or {}) or {}
	end

	local function findExplicitEntry(slot, id)
		for _, entry in pairs(slot or {}) do
			if istable(entry) and entry[1] == id then return entry end
		end
	end

	local function mountTypesMatch(slotType, attachmentType)
		if not slotType or not attachmentType then return false end
		if istable(slotType) then return table.HasValue(slotType, attachmentType) end
		return slotType == attachmentType
	end

	local function isCompatible(wep, placement, id, definition)
		if not definition or definition[1] != placement then return false end
		local slot = wep.availableAttachments and wep.availableAttachments[placement]
		if not slot then return false end
		local explicit = findExplicitEntry(slot, id) != nil
		local adapter = placement == "sight" and wep.availableAttachments.mount and wep.availableAttachments.mount[definition.mountType]
		if adapter then return true end
		if not slot.mountType and not definition.mountType then return explicit end
		return mountTypesMatch(slot.mountType, definition.mountType)
	end

	local function getEmptySlotReference(wep, placement, slot)
		for index = 1, #slot do
			local entry = slot[index]
			local id = istable(entry) and entry[1]
			local _, definition = getAttachmentDefinition(id)
			if id and definition and isCompatible(wep, placement, id, definition) then
				return entry, definition
			end
		end

		local ids = {}
		for id, definition in pairs(hg.attachments[placement] or {}) do
			if isCompatible(wep, placement, id, definition) then ids[#ids + 1] = id end
		end
		table.sort(ids)
		if not ids[1] then return end
		return nil, hg.attachments[placement][ids[1]]
	end

	local function finiteNumber(value)
		return isnumber(value) and value == value and value > -math.huge and value < math.huge
	end

	local function projectForView(worldPos, view, panelW, panelH)
		if not isvector(worldPos) or not istable(view) or not isvector(view.origin) or not isangle(view.angles) then return end
		local viewportW = view.width or view.w or ScrW()
		local viewportH = view.height or view.h or ScrH()
		if not finiteNumber(viewportW) or not finiteNumber(viewportH) or viewportW <= 0 or viewportH <= 0 then return end

		local aspect = view.aspect or view.aspectratio or viewportW / viewportH
		local horizontalFov = view.fov
		if not finiteNumber(aspect) or aspect <= 0 or not finiteNumber(horizontalFov) or horizontalFov <= 0 or horizontalFov >= 180 then return end

		local delta = worldPos - view.origin
		local depth = delta:Dot(view.angles:Forward())
		local tanHalfFov = math.tan(math.rad(horizontalFov) * 0.5)
		if not finiteNumber(depth) or depth <= 0.001 or not finiteNumber(tanHalfFov) or tanHalfFov <= 0 then return end

		local normalizedX = delta:Dot(view.angles:Right()) / (depth * tanHalfFov)
		local normalizedY = delta:Dot(view.angles:Up()) * aspect / (depth * tanHalfFov)
		if not finiteNumber(normalizedX) or not finiteNumber(normalizedY) or math.abs(normalizedX) > 1 or math.abs(normalizedY) > 1 then return end
		if view.inverted then normalizedX = -normalizedX end

		local viewportX = finiteNumber(view.x) and view.x or 0
		local viewportY = finiteNumber(view.y) and view.y or 0
		local screenX = viewportX + (normalizedX + 1) * viewportW * 0.5
		local screenY = viewportY + (1 - normalizedY) * viewportH * 0.5
		local x = screenX * panelW / ScrW()
		local y = screenY * panelH / ScrH()
		if not finiteNumber(x) or not finiteNumber(y) then return end
		return x, y
	end

	local function getSlotAnchor(wep, placement, previewID, previewModel)
		local slot = wep.availableAttachments and wep.availableAttachments[placement]
		if not slot then return end
		local installed = getWeaponAttachments(wep)[placement]
		if previewID then installed = findExplicitEntry(slot, previewID) or {previewID} end
		local installedID = installed and installed[1]
		local hasInstalledAttachment = installedID and installedID != "empty"
		local wm = wep:GetWM()
		if not IsValid(wm) then return end
		wm:SetupBones()
		local _, definition = getAttachmentDefinition(installedID)
		local referenceEntry
		if not previewID and not hasInstalledAttachment and (placement == "grip" or placement == "underbarrel") then
			referenceEntry, definition = getEmptySlotReference(wep, placement, slot)
		end
		local rendered = wep.attachmentMenuTransforms and wep.attachmentMenuTransforms[placement]
		if not previewID and definition and rendered and rendered.id == installedID and rendered.frame >= FrameNumber() - 1 then
			local anchor = definition.uiAnchor
			if isvector(anchor) then
				local anchorPos = LocalToWorld(anchor, angle_zero, rendered.pos, rendered.ang)
				return anchorPos, rendered.ang
			end
			return rendered.pos, rendered.ang
		end

		local pos, ang
		if slot.mountBone then
			local bone = wm:LookupBone(slot.mountBone)
			local matrix = bone and wm:GetBoneMatrix(bone)
			if matrix then
				pos = matrix:GetTranslation()
				ang = matrix:GetAngles()
			end
		end
		if not pos then
			for _, boneName in ipairs(slotAnchorBones[placement] or {}) do
				local bone = wm:LookupBone(boneName)
				local matrix = bone and wm:GetBoneMatrix(bone)
				if matrix then
					pos = matrix:GetTranslation()
					ang = matrix:GetAngles()
					break
				end
			end
		end
		if placement == "magwell" and not previewID then return pos, ang end

		if not pos then
			local attachmentName = wep:ShouldUseFakeModel() and wep.FakeAttachment or "muzzle"
			local attachmentIndex = wm:LookupAttachment(attachmentName)
			local raw = attachmentIndex and attachmentIndex > 0 and wm:GetAttachment(attachmentIndex)
			if not raw then
				attachmentIndex = wm:LookupAttachment("muzzle_flash")
				raw = attachmentIndex and attachmentIndex > 0 and wm:GetAttachment(attachmentIndex)
			end

			if raw and isvector(raw.Pos) and isangle(raw.Ang) then
				pos = Vector(raw.Pos.x, raw.Pos.y, raw.Pos.z)
				ang = Angle(raw.Ang.p, raw.Ang.y, raw.Ang.r)
				pos, ang = LocalToWorld(wep.attPos or vector_origin, wep.attAng or angle_zero, pos, ang)
				ang:RotateAroundAxis(ang:Forward(), wep.rotatehuy or 0)
			else
				pos = Vector(wm:GetPos().x, wm:GetPos().y, wm:GetPos().z)
				ang = Angle(wm:GetAngles().p, wm:GetAngles().y, wm:GetAngles().r)
				ang:RotateAroundAxis(ang:Forward(), 90)
				local _, adjustedAng = LocalToWorld(vector_origin, wep.attAng or angle_zero, vector_origin, ang)
				ang = adjustedAng
				local attPos = wep.attPos or vector_origin
				pos:Add(ang:Up() * attPos[1] + ang:Right() * attPos[2] + ang:Forward() * attPos[3])
			end

			if wep:ShouldUseFakeModel() then
				pos, ang = LocalToWorld(wep.AttachmentPos or vector_origin, wep.AttachmentAng or angle_zero, pos, ang)
			end
		end

		local offset = Vector(0, 0, 0)
		if hasInstalledAttachment and installed and isvector(installed[2]) then offset:Add(installed[2]) end
		if not hasInstalledAttachment and referenceEntry and isvector(referenceEntry[2]) then offset:Add(referenceEntry[2]) end
		if isvector(slot.mount) then
			offset:Add(slot.mount)
		elseif istable(slot.mount) then
			local mountType = definition and definition.mountType or (istable(slot.mountType) and slot.mountType[1] or slot.mountType)
			if mountType and isvector(slot.mount[mountType]) then
				offset:Add(slot.mount[mountType])
			end
		end
		if definition and isvector(definition.offset) then offset:Add(definition.offset) end

		offset:Rotate(ang)
		pos:Add(offset)

		if not definition then return pos, ang end
		local mountAngle = angle_zero
		if isangle(slot.mountAngle) then
			mountAngle = slot.mountAngle
		elseif istable(slot.mountAngle) and definition.mountType and isangle(slot.mountAngle[definition.mountType]) then
			mountAngle = slot.mountAngle[definition.mountType]
		end
		local definitionAngle = isangle(definition[3]) and definition[3] or angle_zero
		local _, finalAngle = LocalToWorld(vector_origin, definitionAngle + mountAngle, vector_origin, ang)
		local model = IsValid(previewModel) and previewModel or wep.modelAtt and wep.modelAtt[placement]
		if not previewID and definition.transformFunction then definition.transformFunction(wep, model, pos, finalAngle) end
		if isvector(definition.uiAnchor) then pos = LocalToWorld(definition.uiAnchor, angle_zero, pos, finalAngle) end

		return pos, finalAngle
	end

	local function getCardNameLines(id, maxWidth)
		local name = string.upper(hg.attachmentslaunguage[id] or id)
		surface.SetFont("HG_Attachment_Card")
		local words = string.Explode(" ", name, false)
		local lines = {""}
		for _, word in ipairs(words) do
			local line = lines[#lines]
			local candidate = line == "" and word or line .. " " .. word
			if surface.GetTextSize(candidate) <= maxWidth then
				lines[#lines] = candidate
			elseif #lines < 2 then
				lines[#lines + 1] = word
			else
				lines[2] = lines[2] .. " " .. word
			end
		end

		for index = 1, #lines do
			while #lines[index] > 1 and surface.GetTextSize(lines[index] .. (index == 2 and "..." or "")) > maxWidth do
				lines[index] = string.sub(lines[index], 1, -2)
			end
		end
		if #lines == 2 and table.concat(lines, " ") != name then lines[2] = lines[2] .. "..." end
		return lines
	end

	local function updatePreviewTransform(frame)
		if not IsValid(frame) or not IsValid(frame.previewModel) or not frame.previewPlacement or not frame.previewID then return end
		local pos, ang = getSlotAnchor(frame.weapon, frame.previewPlacement, frame.previewID, frame.previewModel)
		if not pos or not ang then return end
		frame.previewModel:SetPos(pos)
		frame.previewModel:SetAngles(ang)
		frame.previewModel:SetupBones()
		if IsValid(frame.previewAdapter) and frame.previewAdapterID then
			local adapterPos, adapterAng = getSlotAnchor(frame.weapon, "mount", frame.previewAdapterID, frame.previewAdapter)
			if adapterPos and adapterAng then
				frame.previewAdapter:SetPos(adapterPos)
				frame.previewAdapter:SetAngles(adapterAng)
				frame.previewAdapter:SetupBones()
			end
		end

		local _, definition = getAttachmentDefinition(frame.previewID)
		if IsValid(frame.previewMount) and definition then
			local mountPos, mountAng = LocalToWorld(definition.mountVec or vector_origin, definition.mountAng or angle_zero, pos, ang)
			frame.previewMount:SetPos(mountPos)
			frame.previewMount:SetAngles(mountAng)
			frame.previewMount:SetupBones()
		end

		if IsValid(frame.previewHolo) and definition then
			local holoPos, holoAng = LocalToWorld(definition.addholovec or vector_origin, definition.addholoang or angle_zero, pos, ang)
			frame.previewHolo:SetPos(holoPos)
			frame.previewHolo:SetAngles(holoAng)
			frame.previewHolo:SetupBones()
		end
	end

	hook.Add("PreDrawHalos", "HG_AttachmentMenuPreview", function()
		local frame = hg.attachmentsMenuPanel
		if not IsValid(frame) or not IsValid(frame.previewModel) then return end
		local models = {frame.previewModel}
		if IsValid(frame.previewAdapter) then models[#models + 1] = frame.previewAdapter end
		if IsValid(frame.previewMount) then models[#models + 1] = frame.previewMount end
		if IsValid(frame.previewHolo) then models[#models + 1] = frame.previewHolo end
		halo.Add(models, color_white, 1, 1, 1, true, true)
	end)

	CreateMenu = function()
		if IsValid(hg.attachmentsMenuPanel) then hg.attachmentsMenuPanel:Remove() end

		local wep = lply:GetActiveWeapon()
		if not IsValid(wep) or not ishgweapon(wep) or not wep.availableAttachments then return end

		local frame = vgui.Create("DFrame")
		hg.attachmentsMenuPanel = frame
		frame.weapon = wep
		frame:SetTitle("")
		frame:SetSize(ScrW(), ScrH())
		frame:SetPos(0, 0)
		frame:SetDraggable(false)
		frame:ShowCloseButton(false)
		frame:MakePopup()
		frame:SetKeyboardInputEnabled(true)
		frame.slotButtons = {}
		frame.slotSections = {}
		frame.pendingUntil = 0
		frame.availableSlots = {}
		frame.openedAt = RealTime()
		frame.escapeWasDown = input.IsKeyDown(KEY_ESCAPE)
		for _, placement in ipairs(slotOrder) do
			if wep.availableAttachments[placement] or placement == "underbarrel" and wep.availableAttachments.gp25 then
				frame.availableSlots[#frame.availableSlots + 1] = placement
			end
		end

		local inspectSequence = wep.AnimList and wep.AnimList.inspect
		local wm = wep:GetWM()
		if inspectSequence and IsValid(wm) and wm:LookupSequence(inspectSequence) >= 0 then
			frame.inspectDuration = 5
			frame.inspectStarted = CurTime()
			wep.SuppressAnimEvents = true
			wep:PlayAnim("inspect", frame.inspectDuration, false)
			wep.SuppressAnimEvents = nil
			wep:EmitSound(inspectOpenSound)
			frame.inspectSequence = inspectSequence
		end

		function frame:Paint(w, h)
			surface.SetDrawColor(0, 0, 0, 105)
			surface.DrawRect(0, 0, w, h)

			drawAttachmentText("LMB  EQUIP / REMOVE     RMB  DROP FROM INVENTORY", "HG_Attachment_Small", w * 0.5, h * 0.95, menuMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			local view = hg.LastMainRenderView or render.GetViewSetup(true)
			local minX, minY = 4, 4
			local maxX, maxY = w - 5, h - 5

			render.SetScissorRect(0, 0, w, h, true)
			for placement, button in pairs(self.slotButtons) do
				if not IsValid(button) then continue end
				local worldPos = getSlotAnchor(self.weapon, placement)
				local screenX, screenY = projectForView(worldPos, view, w, h)
				if not screenX or screenX < minX or screenX > maxX or screenY < minY or screenY > maxY then continue end
				local bx, by = button.section:GetPos()
				local targetX = math.Clamp(bx + (button.side == 1 and 0 or button:GetWide()), minX, maxX)
				local targetY = math.Clamp(by + button:GetTall() * 0.5, minY, maxY)
				local elbowX = math.Clamp(targetX + (button.side == 1 and -45 or 45), minX, maxX)
				drawAttachmentLink(screenX, screenY, elbowX, targetY, targetX, targetY, attachmentLineColor, (RealTime() * 0.7 + screenX * 0.001) % 1)
				surface.SetDrawColor(0, 0, 0, 210)
				surface.DrawOutlinedRect(screenX - 9, screenY - 9, 18, 18, 2)
				drawSelectorCorners(screenX - 10, screenY - 10, 20, 20, attachmentLineColor, 220)
				surface.SetDrawColor(255, 255, 255, 210)
				surface.DrawLine(screenX - 4, screenY, screenX + 4, screenY)
				surface.DrawLine(screenX, screenY - 4, screenX, screenY + 4)
				surface.DrawRect(targetX - 2, targetY - 2, 4, 4)
			end
			render.SetScissorRect(0, 0, 0, 0, false)
		end

		function frame:UpdateSlotLayout(immediate)
			local panelW, panelH = self:GetSize()
			local marginX = math.Clamp(panelW * 0.035, 24, 68)
			for placement, section in pairs(self.slotSections) do
				if not IsValid(section) then continue end
				local side = section.slotButton.side
				local targetX = side == 1 and panelW - marginX - section:GetWide() or marginX
				local targetY = math.Clamp(panelH * (slotRows[placement] or 0.5), 72, panelH - section:GetTall() - 48)
				local openProgress = math.Clamp((RealTime() - self.openedAt - section.animationDelay) / 0.35, 0, 1)
				openProgress = 1 - (1 - openProgress) ^ 3
				local startX = side == 1 and panelW + 20 or -section:GetWide() - 20
				section:SetPos(immediate and targetX or Lerp(openProgress, startX, targetX), targetY)
			end
		end

		local closeButton = vgui.Create("DButton", frame)
		closeButton:SetText("")
		closeButton:SetSize(42, 42)
		closeButton:SetPos(ScrW() - 66, 24)
		closeButton.Paint = function(self, w, h)
			local accent = getMenuAccent()
			self.hover = Lerp(FrameTime() * 12, self.hover or 0, self:IsHovered() and 1 or 0)
			surface.SetDrawColor(getMenuPanel(132 + self.hover * 80))
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(accent.r, accent.g, accent.b, 70 + self.hover * 80)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			if self.hover > 0.05 then drawSelectorCorners(0, 0, w, h, accent, self.hover * 180) end
			drawAttachmentText("X", "HG_Attachment_Label", w * 0.5, h * 0.5, menuText, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
		closeButton.DoClick = function() frame:Close() end

		function frame:RunAttachmentAction(action, id)
			if CurTime() < self.pendingUntil then return end
			self.pendingUntil = CurTime() + 1.1
			if action == "add" then addAttachment(id)
			elseif action == "remove" then removeAttachment(id)
			elseif action == "drop" then dropAttachment(id) end
		end

		function frame:ClearPreview()
			if IsValid(self.hiddenMagazineModel) then
				self.hiddenMagazineModel:SetModelScale(self.hiddenMagazineScale or 1, 0)
				self.hiddenMagazineModel:SetColor(self.hiddenMagazineColor or color_white)
				self.hiddenMagazineModel:SetRenderMode(self.hiddenMagazineRenderMode or RENDERMODE_NORMAL)
			end
			self.hiddenMagazineModel = nil
			self.hiddenMagazineScale = nil
			self.hiddenMagazineColor = nil
			self.hiddenMagazineRenderMode = nil
			if IsValid(self.previewModel) then self.previewModel:Remove() end
			if IsValid(self.previewAdapter) then self.previewAdapter:Remove() end
			if IsValid(self.previewMount) then self.previewMount:Remove() end
			if IsValid(self.previewHolo) then self.previewHolo:Remove() end
			self.previewModel = nil
			self.previewAdapter = nil
			self.previewAdapterID = nil
			self.previewMount = nil
			self.previewHolo = nil
			self.previewPlacement = nil
			self.previewID = nil
		end

		function frame:SetPreview(placement, id)
			if self.previewPlacement == placement and self.previewID == id and IsValid(self.previewModel) then return end
			self:ClearPreview()
			local _, definition = getAttachmentDefinition(id)
			if not definition or not isstring(definition[2]) or definition[2] == "" then return end

			local model = ClientsideModel(definition[2])
			if not IsValid(model) then return end
			model:SetNoDraw(false)
			if definition.fScale then model:SetModelScale(definition.fScale, 0) end
			if definition[4] then
				for index, material in pairs(definition[4]) do model:SetSubMaterial(index, material or "null") end
			end
			if definition.bBonemerge and IsValid(self.weapon:GetWM()) then
				model:SetParent(self.weapon:GetWM())
				model:AddEffects(EF_BONEMERGE)
			end
			if placement == "sight" and definition.mountType then
				local adapterEntry = self.weapon.availableAttachments.mount and self.weapon.availableAttachments.mount[definition.mountType]
				local adapterID = istable(adapterEntry) and adapterEntry[1]
				local adapterDefinition = adapterID and hg.attachments.mount and hg.attachments.mount[adapterID]
				if adapterDefinition and isstring(adapterDefinition[2]) and adapterDefinition[2] != "" then
					self.previewAdapter = ClientsideModel(adapterDefinition[2])
					if IsValid(self.previewAdapter) then
						self.previewAdapter:SetNoDraw(false)
						self.previewAdapterID = adapterID
					end
				end
			end
			if isstring(definition.mount) and definition.mount != "" then
				self.previewMount = ClientsideModel(definition.mount)
				if IsValid(self.previewMount) then self.previewMount:SetNoDraw(false) end
			end
			if isstring(definition.holomodel) and definition.holomodel != "" then
				self.previewHolo = ClientsideModel(definition.holomodel)
				if IsValid(self.previewHolo) then
					self.previewHolo:SetNoDraw(false)
					self.previewHolo:SetModelScale(definition.holoscale or 1.2, 0)
				end
			end

			self.previewModel = model
			self.previewPlacement = placement
			self.previewID = id
			updatePreviewTransform(self)
			self:UpdateManagedMagazineVisibility()
		end

		function frame:UpdateManagedMagazineVisibility()
			local magazine = self.previewPlacement == "magwell" and self.weapon.HeldMagCSModel
			if magazine != self.hiddenMagazineModel then
				if IsValid(self.hiddenMagazineModel) then
					self.hiddenMagazineModel:SetModelScale(self.hiddenMagazineScale or 1, 0)
					self.hiddenMagazineModel:SetColor(self.hiddenMagazineColor or color_white)
					self.hiddenMagazineModel:SetRenderMode(self.hiddenMagazineRenderMode or RENDERMODE_NORMAL)
				end
				self.hiddenMagazineModel = IsValid(magazine) and magazine or nil
				if IsValid(self.hiddenMagazineModel) then
					self.hiddenMagazineScale = self.hiddenMagazineModel:GetModelScale()
					self.hiddenMagazineColor = self.hiddenMagazineModel:GetColor()
					self.hiddenMagazineRenderMode = self.hiddenMagazineModel:GetRenderMode()
				end
			end

			if IsValid(self.hiddenMagazineModel) then
				self.hiddenMagazineModel:SetModelScale(0.001, 0)
				self.hiddenMagazineModel:SetRenderMode(RENDERMODE_TRANSCOLOR)
				self.hiddenMagazineModel:SetColor(Color(255, 255, 255, 0))
			end
		end

		function frame:BuildSlotCards(placement)
			if self.previewPlacement == placement or placement == "underbarrel" and self.previewPlacement == "gp25" then self:ClearPreview() end
			local section = self.slotSections[placement]
			if not IsValid(section) then return end
			if IsValid(section.cards) then section.cards:Remove() end
			if IsValid(section.sightSlider) then section.sightSlider:Remove() end
			if self.weapon.SetupMuzzleAttachments then self.weapon:SetupMuzzleAttachments() end
			local attachments = getWeaponAttachments(self.weapon)
			local installed = attachments[placement]
			local installedID = installed and installed[1]
			local installedDefinition = installedID and hg.attachments[placement] and hg.attachments[placement][installedID]
			local activeMount = attachments.mount
			local dovetail = installedDefinition and installedDefinition.mountType == "dovetail" or istable(activeMount) and activeMount.mountType == "dovetail"
			local hasSight = placement == "sight" and installedID and installedID != "empty" and not dovetail

			local scroll = vgui.Create("DScrollPanel", section)
			section.cards = scroll
			scroll:SetPos(0, hasSight and 72 or 44)
			scroll:SetSize(section:GetWide(), section:GetTall() - (hasSight and 72 or 44))
			local scrollBar = scroll:GetVBar()
			scrollBar:SetWide(4)
			scrollBar:SetHideButtons(true)
			scrollBar.Paint = function(_, w, h) surface.SetDrawColor(10, 10, 10, 132) surface.DrawRect(0, 0, w, h) end
			scrollBar.btnGrip.Paint = function(self, w, h)
				local accent = getMenuAccent()
				surface.SetDrawColor(accent.r, accent.g, accent.b, self:IsHovered() and 160 or 80)
				surface.DrawRect(0, 0, w, h)
			end
			local cards = vgui.Create("DIconLayout", scroll)
			cards:Dock(TOP)
			cards:SetWide(section:GetWide() - 12)
			cards:SetSpaceX(8)
			cards:SetSpaceY(8)

			local slot = self.weapon.availableAttachments[placement]
			local cardPlacements = placement == "underbarrel" and self.weapon.availableAttachments.gp25
				and {"underbarrel", "gp25"} or {placement}

			if hasSight then
				local slider = vgui.Create("DNumSlider", section)
				section.sightSlider = slider
				slider:SetPos(4, 43)
				slider:SetSize(section:GetWide() - 8, 28)
				slider:SetText("Sight X")
				slider:SetMinMax(-1, 3)
				slider:SetDecimals(1)
				slider:SetValue(math.Clamp(tonumber(installed.sightSlide) or 0, -1, 3))
				if IsValid(slider.Label) then
					slider.Label:SetFont("HG_Attachment_Small")
					slider.Label:SetTextColor(menuText)
				end
				if IsValid(slider.TextArea) then
					slider.TextArea:SetFont("HG_Attachment_Small")
					slider.TextArea:SetTextColor(menuText)
				end
				slider.OnValueChanged = function(_, value)
					value = math.Clamp(value, -1, 3)
					installed.sightSlide = value
					frame.pendingSightSlide = value
					frame.pendingSightSlideAt = RealTime() + 0.15
				end
			end

			local function addCard(id, count, isInstalled, cardPlacement)
				cardPlacement = cardPlacement or placement
				local cardSlot = self.weapon.availableAttachments[cardPlacement]
				local cannotRemove = cardSlot and cardSlot.cannotremove
				local cardInstalled = attachments[cardPlacement]
				local cardInstalledID = cardInstalled and cardInstalled[1]
				local card = cards:Add("DButton")
				card:SetSize(74, 74)
				card:SetText("")
				card.nameLines = getCardNameLines(id, 68)
				card.Paint = function(button, w, h)
					local accent = getMenuAccent()
					button.hover = Lerp(FrameTime() * 14, button.hover or 0, button:IsHovered() and 1 or 0)
					surface.SetDrawColor(getMenuPanel(isInstalled and 235 or 205 + button.hover * 30))
					surface.DrawRect(0, 0, w, h)
					surface.SetDrawColor(accent.r, accent.g, accent.b, isInstalled and 190 or 65 + button.hover * 65)
					surface.DrawOutlinedRect(0, 0, w, h, isInstalled and 2 or 1)
					if isInstalled or button.hover > 0.05 then
						drawSelectorCorners(0, 0, w, h, accent, isInstalled and 185 or button.hover * 150)
					end
					if isInstalled then
						drawAttachmentText("ACTIVE", "HG_Attachment_Micro", 5, 5, menuMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
					elseif count and count > 1 then
						drawAttachmentText("x" .. count, "HG_Attachment_Micro", w - 5, 5, menuMuted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
					end
					local lineCount = #button.nameLines
					for lineIndex, line in ipairs(button.nameLines) do
						drawAttachmentText(line, "HG_Attachment_Card", w * 0.5, h - 4 - (lineCount - lineIndex) * 10, menuText, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					end
				end
				card.OnCursorEntered = function(button)
					frame.previewCard = button
					frame:SetPreview(cardPlacement, id)
				end
				card.OnCursorExited = function(button)
					if frame.previewCard != button then return end
					frame.previewCard = nil
					frame:ClearPreview()
				end

				local iconPath = hg.attachmentsIcons[id]
				if isstring(iconPath) and iconPath ~= "" then
					local icon = vgui.Create("DImage", card)
					icon:SetImage(iconPath)
					icon:SetKeepAspect(true)
					icon:SetSize(46, 30)
					icon:SetPos(22, 10)
					icon:SetMouseInputEnabled(false)
				end

				if isInstalled then
					card:SetTooltip(cannotRemove and "This module cannot be removed" or "LMB: remove")
					card.DoClick = function()
						if not cannotRemove then frame:RunAttachmentAction("remove", id) end
					end
				else
					card:SetTooltip("LMB: equip  |  RMB: drop")
					card.DoClick = function()
						if not cardInstalledID or cardInstalledID == "empty" then frame:RunAttachmentAction("add", id) end
					end
					card.DoRightClick = function() frame:RunAttachmentAction("drop", id) end
				end
			end

			local installedCount = 0
			for _, cardPlacement in ipairs(cardPlacements) do
				local cardInstalled = attachments[cardPlacement]
				local cardInstalledID = cardInstalled and cardInstalled[1]
				if cardInstalledID and cardInstalledID != "empty" then
					installedCount = installedCount + 1
					addCard(cardInstalledID, nil, true, cardPlacement)
				end
			end

			local choices = {}
			local choiceIDs = {}
			local inventory = getInventoryCounts()
			local sandbox = engine.ActiveGamemode() == "sandbox"
			for _, cardPlacement in ipairs(cardPlacements) do
				local cardInstalled = attachments[cardPlacement]
				local cardInstalledID = cardInstalled and cardInstalled[1]
				local candidates = sandbox and hg.attachments[cardPlacement] or inventory
				for id in pairs(candidates or {}) do
					local candidatePlacement, definition = getAttachmentDefinition(id)
					if definition and not definition.standard and id != cardInstalledID and candidatePlacement == cardPlacement and isCompatible(self.weapon, cardPlacement, id, definition) then
						choices[#choices + 1] = {id = id, count = sandbox and nil or inventory[id], placement = cardPlacement}
						choiceIDs[id] = true
					end
				end
				for id, definition in pairs(hg.attachments[cardPlacement] or {}) do
					if definition.standard and id != cardInstalledID and not choiceIDs[id] and isCompatible(self.weapon, cardPlacement, id, definition) then
						choices[#choices + 1] = {id = id, placement = cardPlacement}
					end
				end
			end
			table.sort(choices, function(a, b)
				return (hg.attachmentslaunguage[a.id] or a.id) < (hg.attachmentslaunguage[b.id] or b.id)
			end)
			for _, choice in ipairs(choices) do addCard(choice.id, choice.count, false, choice.placement) end
			local slotButton = self.slotButtons[placement]
			if IsValid(slotButton) then slotButton.moduleCount = #choices + installedCount end

			cards:InvalidateLayout(true)
			cards:SizeToChildren(false, true)
		end

		function frame:RefreshTbl()
			self.pendingUntil = 0
			local attachments = getWeaponAttachments(self.weapon)
			for placement, button in pairs(self.slotButtons) do
				local installed = attachments[placement]
				button.installedID = installed and installed[1]
				self:BuildSlotCards(placement)
			end
		end

		for index, placement in ipairs(frame.availableSlots) do
			local section = vgui.Create("DPanel", frame)
			frame.slotSections[placement] = section
			local button = vgui.Create("DPanel", section)
			section.slotButton = button
			section.animationDelay = (index - 1) * 0.07
			section.scrambleStarted = frame.openedAt + section.animationDelay
			frame.slotButtons[placement] = button
			button.section = section
			button.side = slotSides[placement] or (index % 2 == 0 and -1 or 1)
			local sectionWidth = math.Clamp(ScrW() * 0.235, 290, 450)
			local sectionHeight = math.Clamp(ScrH() * 0.195, 185, 225)
			section:SetSize(sectionWidth, sectionHeight)
			section:SetPos(button.side == 1 and ScrW() + 20 or -sectionWidth - 20, ScrH() * 0.5)
			section.Paint = function(_, w, h)
				local accent = getMenuAccent()
				surface.SetDrawColor(0, 0, 0, 100)
				surface.DrawRect(4, 4, w, h)
				surface.SetDrawColor(getMenuPanel(218))
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(255, 255, 255, 9)
				surface.SetMaterial(gradient_d)
				surface.DrawTexturedRect(0, 38, w, h - 38)
				surface.SetDrawColor(accent.r, accent.g, accent.b, 52)
				surface.DrawOutlinedRect(0, 0, w, h, 1)
				surface.SetDrawColor(255, 255, 255, 16)
				surface.DrawOutlinedRect(2, 2, w - 4, h - 4, 1)
			end
			button:SetSize(sectionWidth, 38)
			button:SetPos(0, 0)
			button.Paint = function(self, w, h)
				local accent = getMenuAccent()
				surface.SetDrawColor(getMenuPanel(240))
				surface.DrawRect(0, 0, w, h)
				surface.SetDrawColor(accent.r, accent.g, accent.b, 75)
				surface.DrawRect(0, h - 1, w, 1)
				surface.DrawRect(self.side == 1 and 0 or w - 3, 0, 3, h)
				drawSelectorCorners(0, 0, w, h, accent, 130)
				local title = slotNames[placement] or string.upper(placement)
				title = getScrambledText(title, section.scrambleStarted, 0.65)
				drawAttachmentText(title, "HG_Attachment_Label", 10, h * 0.5, menuText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
				drawAttachmentText((self.moduleCount or 0) .. " MODULES", "HG_Attachment_Count", w - 10, h * 0.5, menuMuted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
		end

		frame:RefreshTbl()

		function frame:SendPendingSightSlide()
			if self.pendingSightSlide == nil then return end
			local value = self.pendingSightSlide
			self.pendingSightSlide = nil
			self.pendingSightSlideAt = nil
			net.Start("ZB_AttachSightSlide")
			net.WriteFloat(value)
			net.SendToServer()
		end

		function frame:Think()
			if not IsValid(self.weapon) or lply:GetActiveWeapon() != self.weapon or not lply:Alive() then
				self:Close()
				return
			end

			local escapeDown = input.IsKeyDown(KEY_ESCAPE)
			if escapeDown and not self.escapeWasDown then
				self:Close()
				return
			end
			self.escapeWasDown = escapeDown

			if self.inspectSequence and self.weapon.seq == self.inspectSequence and CurTime() >= self.inspectStarted + self.inspectDuration * inspectFreezeFraction then
				self.weapon.animtime = CurTime() + self.inspectDuration * (1 - inspectFreezeFraction)
				self.weapon.animspeed = self.inspectDuration
				self.weapon.cycling = false
				self.weapon.reverseanim = false
				local model = self.weapon:GetWM()
				if IsValid(model) then model:SetCycle(inspectFreezeFraction) end
			end
			self:UpdateSlotLayout(false)
			updatePreviewTransform(self)
			self:UpdateManagedMagazineVisibility()
			if self.pendingSightSlideAt and RealTime() >= self.pendingSightSlideAt then self:SendPendingSightSlide() end

		end

		function frame:OnKeyCodePressed(key)
			if key == KEY_ESCAPE then self:Close() end
		end

		function frame:OnRemove()
			self:SendPendingSightSlide()
			self:ClearPreview()
			if hg.attachmentsMenuPanel == self then hg.attachmentsMenuPanel = nil end
			if IsValid(self.weapon) and self.inspectSequence and self.weapon.seq == self.inspectSequence and not self.weapon.reload then
				local weapon = self.weapon
				weapon:EmitSound(inspectCloseSound)
				local model = weapon:GetWM()
				if IsValid(model) then model:SetCycle(inspectFreezeFraction) end
				weapon.animtime = CurTime() + inspectFreezeFraction * self.inspectDuration
				weapon.animspeed = self.inspectDuration
				weapon.cycling = false
				weapon.reverseanim = true
				weapon.callback = function(currentWeapon)
					if IsValid(currentWeapon) and not currentWeapon.reload then
						currentWeapon:PlayAnim("idle", 1, not currentWeapon.NoIdleLoop)
					end
				end
			end
		end
	end

	concommand.Add("hg_get_attachments", function(ply, cmd, args)
		CreateMenu()
	end)
end
