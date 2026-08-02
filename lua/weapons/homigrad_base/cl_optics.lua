AddCSLuaFile()
--
local delta = 0
local color_red = Color(255, 0, 0)
local thermalWhiteMat = Material("models/debug/debugwhite")
local thermalColorModify = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = -0.55,
	["$pp_colour_contrast"] = 1.05,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local thermalMonochrome = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}
local function GetCorpseHeat(ent)
	local deathTime = ent:GetNWFloat("hgThermalDeathTime", ent:GetCreationTime())
	local age = math.max(CurTime() - deathTime, 0)

	return 1 - math.Clamp(age / 300, 0, 1)
end

local function DrawThermalTargets(owner, view, palette)
	local drawn = {}
	local function drawTarget(ent, heat)
		if not IsValid(ent) or ent == owner or ent:IsDormant() or ent:GetNoDraw() or drawn[ent] then return end

		drawn[ent] = true
		if palette == "blue_red" then
			local cold = 1 - heat
			render.SetColorModulation(heat, cold * 0.03, cold * 0.28)
		else
			render.SetColorModulation(heat, heat, heat)
		end
		ent:DrawModel()
	end

	cam.Start3D(view.origin, view.angles, view.fov, view.x, view.y, view.w, view.h, view.znear, view.zfar)
		render.SuppressEngineLighting(true)
		render.MaterialOverride(thermalWhiteMat)
		render.SetBlend(1)
		render.ResetModelLighting(0.32, 0.32, 0.32)
		render.SetModelLighting(0, 0.7, 0.7, 0.7)
		render.SetModelLighting(1, 0.45, 0.45, 0.45)
		render.SetModelLighting(4, 0.85, 0.85, 0.85)

		for _, ply in ipairs(player.GetAll()) do
			local fakeRagdoll = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply:GetNWEntity("FakeRagdoll")

			if IsValid(fakeRagdoll) then
				drawTarget(fakeRagdoll, ply:Alive() and 1 or GetCorpseHeat(fakeRagdoll))
			elseif ply:Alive() then
				drawTarget(ply, 1)
			end
		end

		for _, ent in ipairs(ents.GetAll()) do
			if ent:IsRagdoll() then
				drawTarget(ent, GetCorpseHeat(ent))
			elseif ent:IsNPC() or ent:IsNextBot() then
				drawTarget(ent, 0.95)
			end
		end

		render.SetColorModulation(1, 1, 1)
		render.MaterialOverride(nil)

		render.SuppressEngineLighting(false)
		render.ResetModelLighting(1, 1, 1)
	cam.End3D()
end

hook.Add("HG.InputMouseApply", "ChangeZoom", function(tbl)
	local ply = LocalPlayer()

	delta = Lerp(FrameTime() * 5, delta, 0)

	if IsAiming(ply) then
		delta = input.WasMousePressed(MOUSE_WHEEL_UP) and delta + 1 * (FrameTime() / engine.TickInterval()) or input.WasMousePressed(MOUSE_WHEEL_DOWN) and delta - 1 * (FrameTime() / engine.TickInterval()) or delta
		//tbl.cmd:SetMouseWheel(0)
		if LocalPlayer():KeyDown(IN_WALK) then
			delta = delta - tbl.y / 24
			tbl.y = 0
		end
	end
end)

function IsAimingNoScope(ply)
	local wep = ply:GetActiveWeapon()

	return IsValid(wep) and ishgweapon(wep) and wep:IsZoom()
end

function IsAiming(ply)
	local wep = ply:GetActiveWeapon()

	return IsValid(wep) and ishgweapon(wep) and wep:IsZoom() and wep.attachments and wep:HasAttachment("sight","optic")
end

local rtsize = 640
local rtmat = GetRenderTargetEx("huy-glass22_640",
	rtsize, rtsize,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SHARED,
	bit.bor(2, 256),
	0,
	IMAGE_FORMAT_BGR888
)
local thermalSourceMat = CreateMaterial("hg_scope_thermal_source_v2", "UnlitGeneric", {
	["$basetexture"] = rtmat:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})
local function CreateThermalSensor(name, width, height, refreshRate)
	local target = GetRenderTargetEx("hg_scope_thermal_" .. name,
		width, height,
		RT_SIZE_NO_CHANGE,
		MATERIAL_RT_DEPTH_NONE,
		bit.bor(2, 256),
		0,
		IMAGE_FORMAT_BGR888
	)
	return {
		width = width,
		height = height,
		interval = refreshRate and 1 / refreshRate or 0,
		nextUpdate = 0,
		target = target,
		material = CreateMaterial("hg_scope_thermal_mat_" .. name, "UnlitGeneric", {
			["$basetexture"] = target:GetName()
		})
	}
end

local thermalSensors = {
	optic15 = CreateThermalSensor("optic15_640x480_60hz", 640, 480, 60),
	optic17 = CreateThermalSensor("optic17_640x512_30hz", 640, 512, 30),
	optic18 = CreateThermalSensor("optic18_206x156", 206, 156),
	optic24 = CreateThermalSensor("optic24_64x64_10hz", 64, 64, 10)
}

concommand.Add("hg_t12w_materials", function()
	local model = ClientsideModel("models/weapons/arc9/darsu_eft/mods/scope_torrey_t12w.mdl")
	if not IsValid(model) then
		print("[T12W] Failed to load model")
		return
	end

	print("[T12W] Material slots (SetSubMaterial indices):")
	for index, materialName in ipairs(model:GetMaterials()) do
		print(string.format("[T12W] [%d] %s", index - 1, materialName))
	end

	model:Remove()
end)
local nightVisionWidth = 160
local nightVisionHeight = 120
local nightVisionRT = GetRenderTargetEx("hg_scope_nightvision_160x120", nightVisionWidth, nightVisionHeight,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_NONE,
	bit.bor(2, 256),
	0,
	IMAGE_FORMAT_BGR888
)
local nightVisionSourceMat = CreateMaterial("hg_scope_nightvision_source_v2", "UnlitGeneric", {
	["$basetexture"] = rtmat:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1
})
local nightVisionBloomMat = CreateMaterial("hg_scope_nightvision_bloom_v1", "UnlitGeneric", {
	["$basetexture"] = rtmat:GetName(),
	["$vertexcolor"] = 1,
	["$vertexalpha"] = 1,
	["$additive"] = 1
})
local nightVisionMat = CreateMaterial("hg_scope_nightvision_mat_160x120", "UnlitGeneric", {
	["$basetexture"] = nightVisionRT:GetName()
})
local nightVisionLight

local function DrawThermalSensor(size, sensor, update)
	if update then
		render.PushRenderTarget(sensor.target, 0, 0, sensor.width, sensor.height)
			render.Clear(0, 0, 0, 255)
			cam.Start2D()
				surface.SetDrawColor(255, 255, 255, 255)
				surface.SetMaterial(thermalSourceMat)
				surface.DrawTexturedRect(0, 0, sensor.width, sensor.height)
			cam.End2D()
		render.PopRenderTarget()
	end

	cam.Start2D()
		render.PushFilterMin(TEXFILTER.POINT)
		render.PushFilterMag(TEXFILTER.POINT)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(sensor.material)
		surface.DrawTexturedRect(0, 0, size, size)
		render.PopFilterMin()
		render.PopFilterMag()
	cam.End2D()
end

-- Existing SWEP instances can retain the old DoRT function after a Lua refresh.
function PixelateThermalView(size)
	local wep = RENDERING_SCOPE
	local sight = IsValid(wep) and wep:HasAttachment("sight", "optic")
	local sensor = sight and thermalSensors[sight[1]]
	if not sensor then return end

	DrawThermalSensor(size, sensor, true)
end

local function DrawNightVisionView(size)
	render.PushRenderTarget(nightVisionRT, 0, 0, nightVisionWidth, nightVisionHeight)
		render.Clear(0, 7, 0, 255)
		cam.Start2D()
			render.PushFilterMin(TEXFILTER.POINT)
			render.PushFilterMag(TEXFILTER.POINT)
			surface.SetDrawColor(75, 255, 90, 255)
			surface.SetMaterial(nightVisionSourceMat)
			surface.DrawTexturedRect(0, 0, nightVisionWidth, nightVisionHeight)

			-- Image intensifiers bloom around bright objects and the IR illuminator.
			surface.SetDrawColor(35, 165, 42, 225)
			surface.SetMaterial(nightVisionBloomMat)
			surface.DrawTexturedRect(0, 0, nightVisionWidth, nightVisionHeight)

			render.PopFilterMin()
			render.PopFilterMag()

		cam.End2D()
	render.PopRenderTarget()

	cam.Start2D()
		render.PushFilterMin(TEXFILTER.POINT)
		render.PushFilterMag(TEXFILTER.POINT)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(nightVisionMat)
		surface.DrawTexturedRect(0, 0, size, size)
		render.PopFilterMin()
		render.PopFilterMag()
	cam.End2D()
end

local function UpdateNightVisionLight(owner, view)
	if not IsValid(nightVisionLight) then
		nightVisionLight = ProjectedTexture()
		nightVisionLight:SetTexture("effects/flashlight001")
		nightVisionLight:SetEnableShadows(false)
		nightVisionLight:SetConstantAttenuation(0.1)
		nightVisionLight:SetFarZ(5000)
	end

	nightVisionLight:SetPos(owner:EyePos())
	nightVisionLight:SetAngles(view.angles)
	nightVisionLight:SetFOV(math.Clamp(view.fov + 20, 30, 120))
	nightVisionLight:SetBrightness(1.8)
	nightVisionLight:Update()
end

local function DisableNightVisionLight()
	if not IsValid(nightVisionLight) then return end

	nightVisionLight:SetBrightness(0)
	nightVisionLight:Update()
end
local mat = Material("huy-glass")
local mat2 = Material("huy-glass")
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie3.png")
local limit = 1
local vecVel = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
SWEP.localScopePos = Vector(-21, 3.95, -0.2)
SWEP.scope_blackout = 400
SWEP.maxzoom = 3.5
SWEP.rot = 37
SWEP.FOVMin = 3.5
SWEP.FOVMax = 10
SWEP.blackoutsize = 2500
function surface.DrawTexturedRectRotatedHuy(x, y, w, h, rot, offsetX, offsetY, rotHuy)
	rotHuy = rotHuy or 0
	local newX = x + offsetX * math.sin(math.rad(rot))
	local newY = x + offsetX * math.cos(math.rad(rot))
	local newX = newX + offsetY * math.cos(math.rad(rot))
	local newY = newY - offsetY * math.sin(math.rad(rot))
	surface.DrawTexturedRectRotated(newX, newY, w, h, rot + rotHuy)
end

function surface.DrawTexturedRectRotatedPoint(x, y, w, h, rot, x0, y0)
	local c = math.cos(math.rad(rot))
	local s = math.sin(math.rad(rot))
	local newx = y0 * s - x0 * c
	local newy = y0 * c + x0 * s
	surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
end

local addmat_r = Material("CA/add_r")
local addmat_g = Material("CA/add_g")
local addmat_b = Material("CA/add_b")
local vgbm = Material("vgui/black")
local function DrawCA(rx, gx, bx, ry, gy, by, mater)
	render.UpdateScreenEffectTexture()
	addmat_r:SetTexture("$basetexture", mater)
	addmat_g:SetTexture("$basetexture", mater)
	addmat_b:SetTexture("$basetexture", mater)
	local w, h = ScrW(), ScrH()
	render.SetMaterial(vgbm)
	render.DrawScreenQuad()
	render.SetMaterial(addmat_r)
	render.DrawScreenQuadEx(-rx / 2, -ry / 2, w + rx, h + ry)
	render.SetMaterial(addmat_g)
	render.DrawScreenQuadEx(-gx / 2, -gy / 2, w + gx, h + gy)
	render.SetMaterial(addmat_b)
	render.DrawScreenQuadEx(-bx / 2, -by / 2, w + bx, h + by)
end

lodset = false

local hg_optimise_scopes = GetConVar("hg_optimise_scopes") or CreateClientConVar("hg_optimise_scopes", "1", true, false, "Enable this if scoping makes your fps cry (1 - lowers quality of props around you, 2 - \"disables\" main render)", 0, 2)
local hg_show_hitposmuzzle = ConVarExists("hg_show_hitposmuzzle") and GetConVar("hg_show_hitposmuzzle") or CreateClientConVar("hg_show_hitposmuzzle", "0", false, false, "shows weapons crosshair, work only ведьма admin rank or sv_cheats 1")

local angaddhuy = Angle(0,0,0)
local scrw, scrh = ScrW(), ScrH() --retarded
function SWEP:DoRT()
	LOW_RENDER = nil
	
	local gun = self:GetWeaponEntity()
	local att = self:GetMuzzleAtt(gun, true)
	local owner = self:GetOwner()
	
	if not att then return end
	if not self.sizeperekrestie then return end
	
	self.isscoping = true

	local pos, ang = self:GetTrace(true, nil, nil, true)
	
	local optic
	local sight, foundatt = self:HasAttachment("sight", "optic")
	local thermal = foundatt and foundatt.thermal
	local nightvision = foundatt and foundatt.nightvision
	local thermalSensor = thermal and sight and thermalSensors[sight[1]]
	local thermalUpdate = thermalSensor and RealTime() >= thermalSensor.nextUpdate
	local stabilizedScope = foundatt and foundatt.stableReticle
	local digitalThermal = thermalSensor ~= nil

	if thermalUpdate then
		thermalSensor.nextUpdate = RealTime() + thermalSensor.interval
	end
	
	if foundatt and self.modelAtt and IsValid(self.modelAtt.sight) then
		pos = self.modelAtt.sight:GetPos()
		optic = true
	end
	
	local localPos = vecZero
	localPos:Set(self.localScopePos)
	localPos:Rotate(ang)
	pos:Add(localPos)
	--debugoverlay.Cross(pos,5,1)
	local view = render.GetViewSetup(true)
	local diff, point = util.DistanceToLine(view.origin, view.origin + ang:Forward() * 50, pos)
	local scope_pos = WorldToLocal(point, angle_zero, pos, view.angles)
	local mat = self.mat or mat2
	
	mat:SetTexture("$basetexture", rtmat)
	
	if hg_show_hitposmuzzle:GetBool() then
		//cam.Start3D()
			render.DrawLine(pos,point, Color( 255, 255, 255 ))
		//cam.End3D()
	end

	local firstPerson = lply == GetViewEntity()

	local localhuy = pos - view.origin
	local anghuy = localhuy:Angle()
	local dist = pos:Distance(view.origin)
	--ang[3] = ang[3] - 90--lply:EyeAngles()[3] + self.AdditionalAng[3]
	//ang[3] = ang//lply:EyeAngles()[3] //+ self.AdditionalAng[3]
	--ang[3] = view.angles[3]
	
	local mul = 4 * self.ZoomFOV / 7 * (self.scopedef and 400 / self.scope_blackout or 1)
	angaddhuy[1] = scope_pos[3] * mul
	angaddhuy[2] = -scope_pos[2] * mul
	
	local ang2 = ang + angaddhuy
	local pos2 = pos-- + ang2:Right() * -scope_pos[2] + ang2:Up() * scope_pos[3]

	local tr = util.QuickTrace(owner:EyePos(), (pos2 - owner:EyePos()) + (pos2 - owner:EyePos()):GetNormalized() * 5, {owner, owner.FakeRagdoll})

	local rt = {
		x = 0,
		y = 0,
		w = rtsize,
		h = rtsize,
		angles = ang2 + angle_difference2 * -0,
		origin = owner:InVehicle() and pos2 or tr.HitPos - (pos2 - owner:EyePos()):GetNormalized() * 5,
		drawviewmodel = false,
		fov = math.max(self.ZoomFOV,0.5) / dist * 12,
		znear = 1,
		zfar = zfar,
		bloomtone = false,
		dopostprocess = false
	}

	if stabilizedScope then
		rt.origin = view.origin
		rt.angles = ang
		rt.fov = math.max(self.ZoomFOV, 0.5)
	end
	--debugoverlay.Axis(rt.origin,rt.angles,5,1)
	--render.RenderView(rt)

	local scr1 = pos:ToScreen()
	local scr2 = point:ToScreen()
	local diffa = Vector((scr1.x-scr2.x) / scrw,(scr1.y-scr2.y) / scrh)

	render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
	RENDERING_SCOPE = self
	render.Clear(1, 1, 1, 255)
	render.SetWriteDepthToDestAlpha( false )

	local old = DisableClipping(true)

	diffa[1] = diffa[1] * ScrW() * 2
	diffa[2] = diffa[2] * ScrH() * 2

	local eyeReliefLimit = 10000.0 * (rtsize / 512) / (self.scope_blackout / 400)
	local insideEyeRelief = digitalThermal or diffa:LengthSqr() < eyeReliefLimit

	if insideEyeRelief then
		if hg_optimise_scopes:GetInt() >= 2 then
			--LOW_RENDER = true
			--render.UpdateScreenEffectTexture()
			--render.UpdateFullScreenDepthTexture()
			--local screen = render.GetScreenEffectTexture()

			--render.CopyTexture( screen, rtmat )

			--render.DrawTextureToScreen(rtmat_spare)
    		--render.UpdateFullScreenDepthTexture()
		end
		
		if nightvision then
			UpdateNightVisionLight(owner, rt)
		end

		if not thermal then
			render.RenderView(rt)
		end

		if nightvision then
			DisableNightVisionLight()
		end

		cam.Start3D()
			local aimWay = (ang:Forward()) * 10000000000
			local toscreen = aimWay:ToScreen()
			local x, y = toscreen.x, toscreen.y
			local hitPos
			if hg_show_hitposmuzzle:GetBool() then
				hitPos = self:GetTrace(true).HitPos:ToScreen()
			end
		cam.End3D()
		
		local cocking = self:GetNetVar("shootgunReload", 0) > CurTime()
		
		if cocking then
			local val = (CurTime() - self:GetNetVar("shootgunReload", 0)) * 1024
			--x = x + val
			--diffa[1] = diffa[1] - val
			--y = y - 0
		end

		local distMul = math.min(15, 1.2 * 2.5 * (15 / self.ZoomFOV))
		
		local dist = math.sqrt(((x - scrw / 2) * distMul)^2 + ((y - scrh / 2) * distMul)^2)
		
		if dist > 2048 then
			render.Clear(0, 0, 0, 255)
		end

		if thermal then
			if thermalUpdate then
				render.Clear(0, 0, 0, 255)
				RENDERING_THERMAL_SCOPE = true
				render.RenderView(rt)
				RENDERING_THERMAL_SCOPE = false
				cam.Start2D()
					DrawColorModify(thermalColorModify)
					if foundatt.thermalPalette == "blue_red" then
						surface.SetDrawColor(0, 8, 70, 235)
						surface.DrawRect(0, 0, rtsize, rtsize)
					end
				cam.End2D()
				DrawThermalTargets(owner, rt, foundatt.thermalPalette)
				if foundatt.thermalPalette ~= "blue_red" then
					cam.Start2D()
						-- Model decals and wound overlays are rendered after the model material.
						DrawColorModify(thermalMonochrome)
					cam.End2D()
				end
			end
			DrawThermalSensor(rtsize, thermalSensor, thermalUpdate)
		elseif nightvision then
			DrawNightVisionView(rtsize)
		end

		local scopeFilter = (thermal or nightvision) and TEXFILTER.POINT or TEXFILTER.ANISOTROPIC
		render.PushFilterMin(scopeFilter)
		render.PushFilterMag(scopeFilter)
		cam.Start2D()
			if hg_show_hitposmuzzle:GetBool() then
				draw.RoundedBox(0, hitPos.x / (scrw / ScrW()) - 2, hitPos.y / (scrh / ScrH()) - 2, 4, 4, color_red)
			end
			local blackout = self.blackoutsize * 0.75
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.perekrestie)
			local stableReticle = foundatt and foundatt.stableReticle
			local reticleX, reticleY
			if stableReticle then
				reticleX = rtsize / 2
				reticleY = rtsize / 2
			else
				reticleX = x / (scrw / ScrW())
				reticleY = y / (scrh / ScrH())
			end
			surface.DrawTexturedRectRotatedHuy(0, 0, (self.sizeperekrestie * rtsize / 512) / ((self.perekrestieSize and 4 ) or self.ZoomFOV / 3), (self.sizeperekrestie * rtsize / 512) / ((self.perekrestieSize and 4 ) or self.ZoomFOV / 3), 0, reticleY, reticleX, self.rot)

			surface.SetDrawColor(100, 100, 100)
			surface.SetMaterial(self.scopemat)
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * rtsize / 512 * 2 + 512, blackout * rtsize / 512 * 2 + 512, 0, (ScrH() - y / (scrh / ScrH()) - rtsize / 2) * distMul * 1 + rtsize / 2, (ScrW() - x / (scrw / ScrW()) - rtsize / 2) * distMul * 1 + rtsize / 2)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetMaterial(self.scopemat)
			local x1 = x * math.atan(math.rad(math.cos(CurTime()) * 1))
			local y1 = y * math.atan(math.rad(math.sin(CurTime()) * 1))
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * 0.75 * rtsize / 512 + 512, blackout * rtsize / 512 * 0.75 + 512, 0, (y1 * 1 / (scrh / ScrH())) * distMul + rtsize / 2, (x1 * 1 / (scrw / ScrW()) * distMul) + rtsize / 2)
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * 0.75 * rtsize / 512 + 512, blackout * rtsize / 512 * 0.75 + 512, 0, -diffa[2] * 2 * distMul + rtsize / 2, -diffa[1] * 2 * distMul + rtsize / 2)
			if self.SightDrawFunc then self:SightDrawFunc() end
			if optic and foundatt.SightDrawFunc then foundatt.SightDrawFunc(self) end
			--surface.DrawTexturedRectRotatedHuy(rtsize / 2, rtsize / 2, blackout * rtsize / 512 + 100, blackout * rtsize / 512 + 100, self.rot, -scope_pos[3] * (self.scope_blackout * blackout / 4000), -scope_pos[2] * (self.scope_blackout * blackout / 4000))
		cam.End2D()
		render.PopFilterMin()
		render.PopFilterMag()
	end

	DisableClipping(old)
	RENDERING_SCOPE = false
	render.PopRenderTarget()

	--surface.SetDrawColor(255, 255, 255, 255)
	--surface.SetMaterial(mat)
	--surface.DrawTexturedRect(0, 0, 255, 255)

	--if self.k > 0.5 then
	--	DrawCA(10, -10, 50, 20, -10, 5, rtmat)
	--end
end

function SWEP:ChangeFOV()
	self.ZoomFOV = math.Clamp(self.ZoomFOV - (delta / 10 or 0), self.FOVMin, self.FOVMax)
end

--
local vecZero = Vector(0, 0, 0)
local function WorldToScreen(vWorldPos, vPos, vScale, aRot, verticalScale)
	local vWorldPos = vWorldPos - vPos
	vWorldPos:Rotate(Angle(0, -aRot.y, 0))
	vWorldPos:Rotate(Angle(-aRot.p, 0, 0))
	vWorldPos:Rotate(Angle(0, 0, -aRot.r))
	return vWorldPos.x / vScale, (-vWorldPos.y) / (vScale * verticalScale)
end

SWEP.size = 0.0007
SWEP.holo_pos = Vector(-0.82, 3.48, 25)
SWEP.holo = Material("holo/huy-holo2.png")
SWEP.holo_lum = 1
SWEP.scale = Vector(1, 1.3, 1)

local anghuy = Angle(0,0,0)
local vechuy = Vector(0,0,0)

local exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

local customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
	["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
	["$translucent"] = 1,
		["$vertexcolor"] = 1
} )

local mat_Mul = Material("pp/mul")
local mat_Add = Material("pp/add")
mat_Add:SetTexture("$basetexture", exampleRT)
mat_Add:SetVector("$color2", Vector(10, 10, 10))

hook.Add("InitPostEntity","zc_huyhuy",function()
	exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

	customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
		["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
		["$translucent"] = 1,
		["$vertexcolor"] = 1
	} )

	mat_Mul = Material("pp/mul")
	mat_Add = Material("pp/add")
	mat_Add:SetTexture("$basetexture", exampleRT)
	mat_Add:SetVector("$color2", Vector(10, 10, 10))

end)


gameevent.Listen( "OnRequestFullUpdate" )
hook.Add( "OnRequestFullUpdate", "RT_shits", function( data )
	exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

	customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
		["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
		["$translucent"] = 1,
		["$vertexcolor"] = 1
	} )

	mat_Mul = Material("pp/mul")
	mat_Add = Material("pp/add")
	mat_Add:SetTexture("$basetexture", exampleRT)
	mat_Add:SetVector("$color2", Vector(10, 10, 10))
end )

function SWEP:DoHolo()
end

local blured
// ПОЙНТ ТЫ НУБ ПОЛНЫЙ
--local hg_blur_holo = GetConVar("hg_blur_holo") or CreateClientConVar("hg_blur_holo", "1", true, false, "Disable this if holo blur makes your fps cry.", 0, 1)

local invcolor = Color(0,0,0,0)
hook.Add("PostDrawTranslucentRenderables","stencil-test-holo2",function()
	local ply = not LocalPlayer():Alive() and LocalPlayer():GetNWEntity("spect",LocalPlayer()) or LocalPlayer()
	if not IsValid(ply) then return end
	local self = ply.GetActiveWeapon and ply:GetActiveWeapon() or nil
	if not IsValid(self) or not self.ishgwep or not self.GetWeaponEntity or not IsValid(self:GetWeaponEntity()) then return end

	local models = self.holomodels
	if not models and not self.internalholo then return end
	local tr, pos, ang = self:GetTrace()
	local view = render.GetViewSetup()
	local eyePos = view.origin
	local hitPos = eyePos + ang:Forward() * 2624
	
	if blured ~= self.holo then
		// МОЙ ДРУГ ТОЛЬКО С ПРОЦЕССОРОМ НЕ МОГ ИГРАТЬ НОРМАЛЬНО С ГОЛОГРАФАМИ!!!!
		// ТЫ ОЧЕНЬ ПЛОХОЙ!!! И НУЫЫЫЫЫ																							|\_/|
		// Короче я пофиксил какашку, теперь блюр один раз на изменение текстуры, теперь смешных приколов фпс падений не будет. |'.'|
		// ПЛЫВ ПЛЫВ ПЛЫВ																										|	|
		// ЭТО САМЫЙ БОЛЬШОЙ КОМЕНТАРИЙ ХЕХЕХЕХЕХЕЕХ																		   	|___|
		render.PushRenderTarget( exampleRT )
			render.OverrideAlphaWriteEnable( true, true )

			render.ClearDepth()
			render.Clear( 0, 0, 0, 0 )	

			DisableClipping(true)

				cam.Start2D()
					surface.SetDrawColor(255, 255, 255, 150)
					surface.SetMaterial(self.holo)
					surface.DrawTexturedRect(0, 0, 1024, 1024)
					render.BlurRenderTarget(exampleRT, 1, 1, 6)

					for i = 1, 2 do
						render.SetMaterial(mat_Add)
						render.DrawScreenQuad()
					end--]]
				cam.End2D()

			DisableClipping(false)

			render.OverrideAlphaWriteEnable( false )
		render.PopRenderTarget()

		blured = self.holo
	end

	if models or self.internalholo then
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

		render.SetBlend(0)
		local mdl
		if models then
			for model in pairs(models) do
				if not IsValid(model) then continue end
				model:DrawModel()
				mdl = model
			end
		else
			local zoom, anga = self:GetZoomPos(vector_origin, view, view.origin)
			local sightpos, _ = LocalToWorld(self.internalholo, angle_zero, zoom, anga)
			
			render.SetColorMaterial()
			render.DrawSphere(sightpos, self.internalholosize, 5, 5, invcolor)
		end

		render.SetBlend(1)

		render.SetStencilCompareFunction( STENCIL_EQUAL )
		--render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)

		cam.Start2D()
			local x,y = hitPos:ToScreen().x,hitPos:ToScreen().y
			local m = Matrix()
			local w,h = ScrW(),ScrH()
			vechuy[1] = w / 2
			vechuy[2] = h / 2
			local center = vechuy

			m:Translate( center )
			anghuy[2] = ang[3] - 0 - view.angles[3]
			m:Rotate( anghuy )
			m:Translate( -center )

			local size = 18
			local distToSight = IsValid(mdl) and mdl:GetPos():Distance(view.origin) or 1
			--print(distToSight)
			size = size * math.Remap(view.fov,0,100,1.8,1)
			size = size * math.Remap(distToSight,6,14,1.2,0.9)
			--size = size * 
			--render.OverrideBlend( true,BLEND_DST_COLOR,BLEND_ONE,BLENDFUNC_ADD )
			--	surface.SetDrawColor(255,255,255,15)
			--	surface.SetMaterial(customMaterial)
			--	surface.DrawTexturedRectRotatedPoint(x,y,size * 2 * self.holo_size,size * 2 * self.holo_size,-anghuy[2],-0,0)
			--render.OverrideBlend( false )

			surface.SetDrawColor(self.colorholo or color_white)
			surface.SetMaterial(self.holo)
			surface.DrawTexturedRectRotatedPoint(x,y,size * 2 * self.holo_size,size * 2 * self.holo_size,-anghuy[2],-0,0)

		cam.End2D()
		render.PopFilterMag()
		render.PopFilterMin()

		-- Let everything render normally again
		render.SetStencilEnable( false )

	end

end)

hook.Add("RenderScreenspaceEffects","stencil-test-holo2",function()
	--[[local ply = not LocalPlayer():Alive() and LocalPlayer():GetNWEntity("spect",LocalPlayer()) or LocalPlayer()
	local self = ply.GetActiveWeapon and ply:GetActiveWeapon() or nil
	if not IsValid(self) or not self.GetWeaponEntity or not IsValid(self:GetWeaponEntity()) then return end

	local att = self:GetMuzzleAtt(nil,true,false)
	local models = self.holomodels
	if not models then return end
	local view = render.GetViewSetup()
	local eyePos = view.origin
	local hitPos = eyePos + att.Ang:Forward() * 2624

	if models then
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
		
		for model in pairs(models) do
			if not IsValid(model) then continue end
			model:DrawModel()
		end

		render.SetStencilCompareFunction( STENCIL_EQUAL )

		render.SetStencilEnable( false )

	end--]]

end)

hook.Add("PostDrawOpaqueRenderables","stencil-test-holo",function()
	--wtf teplak??!???
	if true then return end
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
	-- Set the reference value to 1. This is what the compare function tests against
	render.SetStencilReferenceValue( 1 )
	-- Always draw everything
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.SetStencilPassOperation( STENCIL_REPLACE )

	-- Draw our entities. They will draw as normal
	for _, ent in player.Iterator() do
		ent:DrawModel()
	end
	
	-- Now, only draw things that have their pixels set to 1. This is the hidden parts of the stencil tests.
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	-- Flush the screen. This will draw teal over all hidden sections of the stencil tests
	
	render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )

	-- Let everything render normally again
	render.SetStencilEnable( false )

end)
