hg.Appearance = hg.Appearance or {}
hg.Accessories = hg.Accessories or {}

-- File manager

hg.Appearance.SelectedAppearance = ConVarExists("hg_appearance_selected") and GetConVar("hg_appearance_selected") or CreateClientConVar("hg_appearance_selected","appearance",true,false,"the singleton appearance profile")
hg.Appearance.ForcedRandom = ConVarExists("hg_appearance_force_random") and GetConVar("hg_appearance_force_random") or CreateClientConVar("hg_appearance_force_random","0",true,false,"forced appearance random",0,1)

local appearanceFile = "judge/appearance.json"
local legacyAppearanceFile = "judge/appearances/main.json"

local function EnsureAppearanceFile()
	if file.Exists(appearanceFile, "DATA") then return end
	if file.Exists(legacyAppearanceFile, "DATA") then
		file.CreateDir("judge")
		file.Write(appearanceFile, file.Read(legacyAppearanceFile, "DATA"))
	end
end

function hg.Appearance.CreateAppearanceFile(strFile_name, tblAppearance)
	file.CreateDir("judge")
	file.Write(appearanceFile, util.TableToJSON(tblAppearance, true))
end

local function DebugValidateAppearance(tblAppearance)
	if not istable(tblAppearance) then
		MsgN("[Appearance] debug: parsed value is not a table (" .. type(tblAppearance) .. ")")
		return
	end

	for _, key in ipairs({ "AModel", "AClothes", "AName", "AColor", "AAttachments", "AAttachmentColors", "ABodygroups", "AFacemap" }) do
		local fn = hg.Appearance.ValidateFunctions and hg.Appearance.ValidateFunctions[key]
		if not fn then
			MsgN("[Appearance] debug: no validator registered for field " .. key)
			continue
		end

		local ok, err = pcall(fn, tblAppearance[key])
		if not ok then
			MsgN("[Appearance] debug: validator " .. key .. " errored: " .. tostring(err))
		elseif ok == false then
			MsgN("[Appearance] debug: field " .. key .. " is INVALID (value: " .. tostring(tblAppearance[key]) .. ")")
		else
			MsgN("[Appearance] debug: field " .. key .. " OK")
		end
	end

	MsgN("[Appearance] debug: ABodySize=" .. tostring(tblAppearance.ABodySize) .. " (" .. type(tblAppearance.ABodySize) .. "), AHeight=" .. tostring(tblAppearance.AHeight) .. " (" .. type(tblAppearance.AHeight) .. "), resize=" .. tostring(tblAppearance.ABodySizeResizeHead) .. "/" .. tostring(tblAppearance.AHeightResizeHead))
end

function hg.Appearance.LoadAppearanceFile(strFile_name)
	EnsureAppearanceFile()
	if not file.Exists(appearanceFile, "DATA") then return false, "file is not found [data/judge/appearance.json]" end

	local raw = file.Read(appearanceFile, "DATA")
	if not raw then return false, "data/judge/appearance.json could not be read" end

	local tblAppearance = util.JSONToTable(raw)
	if not istable(tblAppearance) then
		MsgN("[Appearance] parse produced a non-table value for data/judge/appearance.json (" .. type(tblAppearance) .. ")")
		return false, "data/judge/appearance.json is invalid"
	end

	local normalized = hg.Appearance.NormalizeAppearanceTable and hg.Appearance.NormalizeAppearanceTable(tblAppearance) or tblAppearance

	if not hg.Appearance.AppearanceValidater(normalized) then
		MsgN("[Appearance] validation failed for data/judge/appearance.json")
		DebugValidateAppearance(tblAppearance)
		return false, "data/judge/appearance.json is invalid"
	end

	tblAppearance = normalized

	if tblAppearance.AAttachments then
		local norm = {"none","none","none","none","none","none"}
		for k,v in pairs(tblAppearance.AAttachments) do
			local idx = tonumber(k)
			if idx and idx >= 1 and idx <= 6 then norm[idx] = v end
		end
		tblAppearance.AAttachments = norm
	end

	return tblAppearance
end

function hg.Appearance.GetAppearanceList()
	EnsureAppearanceFile()
	return {"appearance"}
end

-- Send from client...
net.Receive("Get_Appearance", function()
	local forced_random = hg.Appearance.ForcedRandom:GetBool()
    net.Start("Get_Appearance")
		local tbl,reason

		if not forced_random then
			tbl,reason = hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString())
		end
		
        net.WriteTable(tbl and tbl or {})
        net.WriteBool(not tbl)
    net.SendToServer()

	if not tbl and not forced_random and reason then lply:ChatPrint("[Appearance] file load failed - " .. reason) end
end)

local function OnlyGetAppearance()
	local forced_random = hg.Appearance.ForcedRandom:GetBool()
    net.Start("OnlyGet_Appearance")
		local tbl,reason

		if not forced_random then 
			tbl,reason = hg.Appearance.LoadAppearanceFile(hg.Appearance.SelectedAppearance:GetString())
		end

        net.WriteTable(tbl or {})
        net.WriteBool(true)

    net.SendToServer()

	if not tbl and not forced_random then lply:ChatPrint("[Appearance] file load failed - " .. (reason or "unknown error")) end
end

net.Receive("OnlyGet_Appearance", OnlyGetAppearance)

-- Render things

local whitelist = {
    weapon_physgun = true,
    gmod_tool = true,
    gmod_camera = true,
    weapon_crowbar = true,
    weapon_pistol = true,
    weapon_crossbow = true
}

local islply

local hg_firstperson_death = { GetBool = function() return false end }

function RenderAccessories(ply, accessories, setup)

	if not IsValid(ply) or not accessories then return end

	if accessories == "none" then return end

	local wep = ply:IsPlayer() and ply:GetActiveWeapon()

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	ent = IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() and ply.OldRagdoll or ent

	islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer())) and GetViewEntity() == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer()))
	
	local fountains = GetNetVar("fountains") or {}
	if ent == follow and hg_firstperson_death:GetBool() and !fountains[ent] then islply = true end

	if islply and IsValid(wep) and whitelist[wep:GetClass()] then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if not ent.shouldTransmit or ent.NotSeen then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if istable(accessories) then
		for k = 1, #accessories do
			local accessoriess = accessories[k]
			if not accessoriess or accessoriess == "none" then continue end
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if accessData.needcoolRender then continue end

			DrawAccesories(ply, ent, accessoriess, accessData, islply, nil, setup)
		end
	else
		local accessData = hg.Accessories[accessories]
		if not accessData then return end
		if accessData.needcoolRender then return end

		DrawAccesories(ply, ent, accessories, accessData, islply, nil, setup)
	end
end

local huy_addvec = Vector(0.4,0,0.4)

local function NormalizeAppearanceColor(colorValue)
	if IsColor(colorValue) then return colorValue end
	if isvector(colorValue) then
		return Color(colorValue.x * 255, colorValue.y * 255, colorValue.z * 255, 255)
	end
	if istable(colorValue) and colorValue.r and colorValue.g and colorValue.b then
		return Color(colorValue.r, colorValue.g, colorValue.b, colorValue.a or 255)
	end
	if istable(colorValue) and colorValue[1] and colorValue[2] and colorValue[3] then
		return Color(colorValue[1], colorValue[2], colorValue[3], colorValue[4] or 255)
	end
end


local function NormalizeAppearanceVector(colorValue)
	if isvector(colorValue) then return colorValue end

	local clr = NormalizeAppearanceColor(colorValue)
	if not clr then return end

	return Vector(clr.r / 255, clr.g / 255, clr.b / 255)
end


local function GetAppearanceModelData(ply, ent)
	local appearance = ent and ent.CurAppearance or ply.CurAppearance
	if not appearance or not appearance.AModel then return end

	return hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel]
end






local function GetAppearanceBaseColor(ply, ent)
	local previewColor = ent and ent.PreviewAppearanceColor
	if previewColor then
		return NormalizeAppearanceColor(previewColor)
	end

	local appearance = ent and ent.CurAppearance or ply.CurAppearance
	if appearance and appearance.AColor then
		return NormalizeAppearanceColor(appearance.AColor)
	end

	if ply then
		if ply.GetNWVector then
			local pc = ply:GetNWVector("PlayerColor", nil)
			if pc then return NormalizeAppearanceColor(pc) end
		end
		if ply.GetPlayerColor then
			local pc = ply:GetPlayerColor()
			if pc then return NormalizeAppearanceColor(pc) end
		end
	end

	return color_white
end

local function GetAccessoryColorOverride(ply, ent, accessoryKey)
	local previewColors = ent and ent.PreviewAccessoryColors
	local previewColor = previewColors and previewColors[accessoryKey]
	if previewColor then
		return NormalizeAppearanceColor(previewColor)
	end

	local appearance = ent and ent.CurAppearance or ply.CurAppearance
	local storedColor = appearance and appearance.AAttachmentColors and appearance.AAttachmentColors[accessoryKey]
	if storedColor then
		return NormalizeAppearanceColor(storedColor)
	end

	local netColors = (ent and ent.GetNetVar and ent:GetNetVar("AccessoryColors", nil)) or (ply.GetNetVar and ply:GetNetVar("AccessoryColors", nil))
	local netColor = netColors and netColors[accessoryKey]
	if netColor then
		return NormalizeAppearanceColor(netColor)
	end
end

local AccessoryBlockedByArmorSlot = {
	["head1"] = "head",
	["spine"] = "torso",
}

local function IsAccessoryBlockedByArmor(ply, accessData)
	if not ply.armors then return false end
	local placement = accessData["placement"]
	if not placement then return false end

	local blockSlot = AccessoryBlockedByArmorSlot[placement] or placement

	return ply.armors[blockSlot] ~= nil
end

function DrawAccesories(ply, ent, accessories,accessData, islply, force, setup)
	if not accessories then return end
	if not accessData then return end
	if ent.hgGettingUpView and follow == ent and accessData["bone"] == "ValveBiped.Bip01_Head1" then return end

	ply.modelAccess = ply.modelAccess or {}

	local fem = ThatPlyIsFemale(ent)
	if not IsValid(ply.modelAccess[accessories]) then
		if not accessData["model"] then return end
		ply.modelAccess[accessories] = ClientsideModel(fem and accessData["femmodel"] or accessData["model"], RENDERGROUP_BOTH)

		local model = ply.modelAccess[accessories]
		model:SetNoDraw(true)
		model:SetModelScale( accessData[fem and "fempos" or "malepos"][3] )
		model:SetSkin( isfunction(accessData["skin"]) and accessData["skin"](ent) or accessData["skin"] )
		model:SetBodyGroups( accessData["bodygroups"] or "" )
		model:SetParent(ent, ent:LookupBone(accessData["bone"]))
		if accessData.bonemerge then
			model:AddEffects(EF_BONEMERGE)
		end
		if accessData["bSetColor"] then
			local accessoryColor = GetAccessoryColorOverride(ply, ent, accessories)
			model:SetColor(accessoryColor or GetAppearanceBaseColor(ply, ent))
		end

		if accessData["SubMat"] then
			model:SetSubMaterial(0,accessData["SubMat"])
		end

		ply:CallOnRemove("RemoveAccessories"..accessories,function() 
			if ply.modelAccess and IsValid(model) then
				model:Remove()
				model = nil
			end
		end)
		ent:CallOnRemove("RemoveAccessories2"..accessories,function() 
			if ply.modelAccess and IsValid(model) then
				model:Remove()
				model = nil
			end
		end)
	end

	local model = ply.modelAccess[accessories]
	--print(ent:GetModel(),ent)
	local mdl = string.Split(string.sub(ent:GetModel(),1,-5),"/")[#string.Split(string.sub(ent:GetModel(),1,-5),"/")]
	if mdl and model:GetFlexIDByName(mdl) then
		model:SetFlexWeight(model:GetFlexIDByName(mdl),1)
	end
	--if model:GetFlexIDByName(ThatPlyIsFemale(ply) and "F" or "M") then
	--	model:SetFlexWeight(model:GetFlexIDByName(ThatPlyIsFemale(ply) and "F" or "M"),1)
	--end
	model:SetSkin( isfunction(accessData["skin"]) and accessData["skin"](ent) or accessData["skin"] )

	if not IsValid(model) then ply.modelAccess[accessories] = nil return end

	if IsAccessoryBlockedByArmor(ply, accessData) then

		return
	end

	if not force and ((ent.NotSeen or not ent.shouldTransmit) or (ply:IsPlayer() and not ply:Alive())) then

		return
	end

	if islply and accessData.hideWhenAim and ply:IsPlayer() and ply:KeyDown(IN_ATTACK2) then
		return
	end

	if ply.organism and hg.amputatedlimbs2[accessData["bone"]] and ent.organism and ent.organism[hg.amputatedlimbs2[accessData["bone"]].."amputated"] then return end

	local bone
	if setup != false then
		bone = ent:LookupBone(accessData["bone"])
		if not bone then return end
		if ent:GetManipulateBoneScale(bone):LengthSqr() < 0.1 then return end
		local matrix = ent:GetBoneMatrix(bone)
		if not matrix then return end

		local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()

		local addvec = ((ent:GetModel() == "models/player/group01/male_06.mdl") and ((accessData.placement == "head") or (accessData.placement == "face"))) and huy_addvec or vector_origin

		local pos, ang = LocalToWorld(accessData[fem and "fempos" or "malepos"][1], accessData[fem and "fempos" or "malepos"][2], bonePos, boneAng)
		local pos = LocalToWorld(addvec, angle_zero, pos, ang)
		
		--model:SetupBones()
		model:SetRenderOrigin(pos)
		model:SetRenderAngles(ang)
	end

	if model:GetParent() != ent then model:SetParent(ent, bone) end
	if !(islply and accessData.norender) and (!setup or accessData.bonemerge) then
		if accessData["bSetColor"] then
			local colorDraw = NormalizeAppearanceColor(GetAccessoryColorOverride(ply, ent, accessories) or accessData["vecColorOveride"] or GetAppearanceBaseColor(ply, ent))
			render.SetColorModulation( colorDraw.r / 255, colorDraw.g / 255, colorDraw.b / 255 )
		end
		
		model:DrawModel()
		
		if accessData["bSetColor"] then
			render.SetColorModulation( 1, 1, 1 )
		end
	end
end

local flpos,flang = Vector(4,-1,0),Angle(0,0,0)

local offsetVec,offsetAng = Vector(1,0,0),Angle(100,90,0)

local mat2 = Material("sprites/light_glow02_add_noz")
local mat3 = Material("effects/flashlight/soft")

function DrawAppearance(ent, ply, setup)
    local Access = ent:GetNetVar("Accessories") or ent.PredictedAccessories
	
	if IsValid(ent) and Access then
		RenderAccessories(ply, Access, setup)
	end
	
	if setup then return end
	
	if not ply:IsPlayer() then return end
	
	local inv = ply:GetNetVar("Inventory",{})
	if not inv["Weapons"] or not inv["Weapons"]["hg_flashlight"] then
		if ply.flashlight then
			ply.flashlight:Remove()
			ply.flashlight = nil
		end
		if ply.flmodel then
			ply.flmodel:Remove()
			ply.flmodel = nil
		end
		return
	end

	local wep = ply:GetActiveWeapon()
	local flashlightwep

	if IsValid(wep) then
		local laser = wep.attachments and wep.attachments.underbarrel
		local attachmentData
		if ( laser and !table.IsEmpty(laser) ) or wep.laser then
			if laser and !table.IsEmpty(laser) then
				attachmentData = hg.attachments.underbarrel[laser[1]]
			else
				attachmentData = wep.laserData
			end
		end

		if attachmentData then flashlightwep = attachmentData.supportFlashlight end
	end

	if IsValid(ply.flmodel) then
		ply.flmodel:SetNoDraw(!(ply:GetNetVar("flashlight") and (!wep.IsPistolHoldType or wep:IsPistolHoldType())) or wep.reload or flashlightwep)
	end

	if ply:GetNetVar("flashlight") and not flashlightwep and (!wep.IsPistolHoldType or wep:IsPistolHoldType() or ply.PlayerClassName == "Gordon") and not wep.reload then
		local hand = ent:LookupBone("ValveBiped.Bip01_L_Hand")
		if not hand then return end

		local handmat = ent:GetBoneMatrix(hand)
		if not handmat then return end

		local pos,ang = handmat:GetTranslation(),handmat:GetAngles()--ply:EyeAngles()--(ply:GetEyeTrace().HitPos - ply:EyePos()):Angle()
		local pos,ang = LocalToWorld(offsetVec,offsetAng,pos,ang)

		ply.flmodel = IsValid(ply.flmodel) and ply.flmodel or ClientsideModel("models/runaway911/props/item/flashlight.mdl")
		ply.flmodel:SetModelScale(0.75)

		if ent ~= ply then pos = handmat:GetTranslation() end

		local pos,_ = LocalToWorld(flpos,flang,pos,handmat:GetAngles())

		if IsValid(ply.flmodel) then
			ply.flmodel:SetRenderOrigin(pos)
			ply.flmodel:SetRenderAngles(ply:EyeAngles())
		end

		ply.flmodel:DrawModel()

		if not IsValid(ply.flashlight) then
			ply.flashlight = ProjectedTexture()
			ply.flashlight:SetTexture(mat3:GetTexture("$basetexture"))
			ply.flashlight:SetFarZ(1500)
			ply.flashlight:SetHorizontalFOV(60)
			ply.flashlight:SetVerticalFOV(60)
			ply.flashlight:SetConstantAttenuation(0.1)
			ply.flashlight:SetLinearAttenuation(50)
		end
		
		if ply.flashlight and ply.flashlight:IsValid() then
			ply.flashlight:SetPos(ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * 8)
			ply.flashlight:SetAngles(ply.flmodel:GetAngles())
			ply.flashlight:Update()
		end

		local view = render.GetViewSetup(true)
		local deg = ply.flmodel:GetAngles():Forward():Dot(view.angles:Forward())
		deg = math.ease.InBack(-deg + 0.05) * 2
		deg = -deg
		local chekvisible = util.TraceLine({
			start = ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * 6,
			endpos = view.origin,
			filter = {ply, ent, ply.flmodel, LocalPlayer()},
			mask = MASK_VISIBLE
		})

		if deg < 0 and not chekvisible.Hit then
			render.SetMaterial(mat2)
			render.DrawSprite(ply.flmodel:GetPos() + ply.flmodel:GetAngles():Forward() * 5 + ply.flmodel:GetAngles():Right() * -0.5, 50 * math.min(deg, 0), 50 * math.min(deg, 0), color_white)
		end
	else
		if ply.flashlight and IsValid(ply.flashlight) then
			ply.flashlight:Remove()
			ply.flashlight = nil
		end
	end
end

hook.Add("RenderScreenspaceEffects","AppearanceShitty",function()
	if (not LocalPlayer():Alive()) or LocalPlayer():GetViewEntity() ~= LocalPlayer() then return end
	local ply = LocalPlayer()
	local acsses = ply:GetNetVar("Accessories", "none")

	if istable(acsses) then
		for k = 1, #acsses do
			local accessoriess = acsses[k]
			if not accessoriess or accessoriess == "none" then continue end
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if IsAccessoryBlockedByArmor(ply, accessData) then continue end
			if accessData.ScreenSpaceEffects then
				accessData.ScreenSpaceEffects()
			end
		end
	elseif acsses then
		local accessData = hg.Accessories[acsses]
		if not accessData then return end
		if IsAccessoryBlockedByArmor(ply, accessData) then return end
		if accessData.ScreenSpaceEffects then
			accessData.ScreenSpaceEffects()
		end
	end
end)

function CoolRenderAccessories(ply, accessories)

	if not IsValid(ply) or not accessories then return end

	if accessories == "none" then return end

	local wep = ply:IsPlayer() and ply:GetActiveWeapon()

	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

	islply = ((ply:IsRagdoll() and hg.RagdollOwner(ply)) or ply) == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer())) and GetViewEntity() == (LocalPlayer():Alive() and LocalPlayer() or LocalPlayer():GetNWEntity("spect",LocalPlayer()))

	if islply and IsValid(wep) and whitelist[wep:GetClass()] then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if not ent.shouldTransmit or ent.NotSeen then
		if not ent.modelAccess then return end
		for k,v in ipairs(ent.modelAccess) do
			if IsValid(v) then
				v:Remove()
				v = nil
			end
		end
		return
	end

	if istable(accessories) then
		for k = 1, #accessories do
			local accessoriess = accessories[k]
			if not accessoriess or accessoriess == "none" then continue end
			local accessData = hg.Accessories[accessoriess]
			if not accessData then continue end
			if not accessData.needcoolRender then continue end

			DrawAccesories(ply,ent,accessoriess,accessData,islply)
		end
	else
		local accessData = hg.Accessories[accessories]
		if not accessData then return end
		if not accessData.needcoolRender then return end

		DrawAccesories(ply,ent,accessories,accessData,islply)
	end
end

function RenderAccessoriesCool(ent,ply)
	if IsValid(ent) and ent:GetNetVar("Accessories") then
		CoolRenderAccessories(ent, ent:GetNetVar("Accessories", "none"))
	end
end

local posesDir = "judge/appearances/"
local posesFile = posesDir .. "poses.json"

function hg.Appearance.SavePoses()
	local data = {}
	for key, acc in pairs(hg.Accessories) do
		if acc._poseModified then
			data[key] = {
				malepos = {
					{acc.malepos[1].x, acc.malepos[1].y, acc.malepos[1].z},
					{acc.malepos[2].p, acc.malepos[2].y, acc.malepos[2].r},
					acc.malepos[3]
				},
				fempos = {
					{acc.fempos[1].x, acc.fempos[1].y, acc.fempos[1].z},
					{acc.fempos[2].p, acc.fempos[2].y, acc.fempos[2].r},
					acc.fempos[3]
				}
			}
		end
	end
	file.CreateDir(posesDir)
	file.Write(posesFile, util.TableToJSON(data, true))
end

function hg.Appearance.LoadPoses()
	if not file.Exists(posesFile, "DATA") then return end
	local data = util.JSONToTable(file.Read(posesFile, "DATA"))
	if not data then return end
	for key, saved in pairs(data) do
		local acc = hg.Accessories[key]
		if not acc then continue end
		if saved.malepos then
			acc.malepos = {
				Vector(saved.malepos[1][1], saved.malepos[1][2], saved.malepos[1][3]),
				Angle(saved.malepos[2][1], saved.malepos[2][2], saved.malepos[2][3]),
				saved.malepos[3]
			}
		end
		if saved.fempos then
			acc.fempos = {
				Vector(saved.fempos[1][1], saved.fempos[1][2], saved.fempos[1][3]),
				Angle(saved.fempos[2][1], saved.fempos[2][2], saved.fempos[2][3]),
				saved.fempos[3]
			}
		end
		acc._poseModified = true
	end
end

hook.Add("InitPostEntity", "HG_LoadAccessoryPoses", function()
	timer.Simple(1, function() hg.Appearance.LoadPoses() end)
end)
