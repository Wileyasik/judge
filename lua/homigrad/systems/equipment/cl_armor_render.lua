local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like first-person camera view", 0, 1)

local vecAdjust2 = Vector(0, -0, -0)
local function DrawFirstPersonHelmet(ply, strModel, vecAdjust, fFov, setMat)
	if ply:GetNetVar("headcrab") then return end
	if not ply:Alive() then return end
	if ply.organism and ply.organism.otrub then return end

	if not IsValid(ply.FirstPersonHelmetModel) then
		ply.FirstPersonHelmetModel = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel:SetNoDraw(true)
		return
	end

	if not IsValid(ply.FirstPersonHelmetModel2) then
		ply.FirstPersonHelmetModel2 = ClientsideModel(strModel)
		ply.FirstPersonHelmetModel2:SetNoDraw(true)
		ply.FirstPersonHelmetModel2:SetModelScale(1.05)
		return
	end

	local mdl = ply.FirstPersonHelmetModel
	local mdl2 = ply.FirstPersonHelmetModel2

	if mdl:GetModel() != strModel then
		mdl:SetModel(strModel)
	end

	if mdl2:GetModel() != strModel then
		mdl2:SetModel(strModel)
	end
	
	if setMat and !mdl.matseted1 then
		mdl:SetSubMaterial(0,setMat)
		mdl.matseted = false
		mdl.matseted1 = true
		--print('huy')
	elseif !setMat and !mdl.matseted then
		--print("huy")
		mdl:SetSubMaterial(0,nil)
		mdl.matseted = true
		mdl.matseted1 = false
	end

	local gp = hg_gopro:GetBool()

	local view = render.GetViewSetup()
	cam.Start3D(view.origin,view.angles,view.fov + fFov,nil,nil,nil,nil,1,10)
		--cam.IgnoreZ(true)
		local viewpunching = GetViewPunchAngles() / 2
		local ang = view.angles + viewpunching
		mdl:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
		mdl:SetRenderAngles(ang)
		mdl2:SetRenderOrigin(view.origin + ang:Forward() * (vecAdjust.x + (gp and vecAdjust2.x or 0)) + ang:Right() * (vecAdjust.y + (gp and vecAdjust2.y or 0)) + ang:Up() * (vecAdjust.z + (gp and vecAdjust2.z or 0)))
		mdl2:SetRenderAngles(ang)
		mdl:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
		render.SetColorModulation(1,1,1)
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
				mdl2:DrawModel()
			render.SetBlend(1)
			render.SetStencilCompareFunction( STENCIL_EQUAL )
			mdl:DrawModel()
			if not hg.ConVars.potatopc:GetBool() then
				DrawBokehDOF(8,0.9,15)
			end
			-- Let everything render normally again
			render.SetStencilEnable( false )
		render.SetColorModulation(1,1,1)
		--cam.IgnoreZ(false)
	cam.End3D()
end

hg.DrawFirstPersonHelmet = DrawFirstPersonHelmet

if CLIENT then
	local hearingMufflingHelmets = {
		helmet11 = true,
		helmet12 = true,
		helmet27 = true,
		helmet28 = true,
		helmet29 = true,
		helmet_riot = true,
	}

	hook.Add("EntityEmitSound", "ArmorHelmetHearingMuffle", function(soundData)
		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() or not ply.armors or not hearingMufflingHelmets[ply.armors.head] then return end
		soundData.Volume = (soundData.Volume or 1) * 0.82
		return true
	end)
end
if CLIENT then
	net.Receive("AddFlash", function()
		local pos = net.ReadVector()
		local time = net.ReadFloat()
		local size = net.ReadInt(20)
		if not IsValid(lply) then return end
		hg.AddFlash(hg.eye(lply), 1, pos, time, size)
	end)
end
