hg.armor = {}
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

hg.armor.torso = {
	["vest1"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b2.mdl",
		Vector(0, 2.9, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b2.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-2, 0, 1.4),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 11.4,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_bank_robber.mdl",
			nobonemerge = true,
			pos = Vector(-0.15, 2.7, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-2, 0, 1.2),
			scale = 0.91,
			femscale = 0.82
		},
		ScrappersSlot = "Armor"
	},
	["vest2"] = {
		"torso",
		"models/eft_props/gear/armor/ar_paca.mdl",
		Vector(-0, 2.9, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_paca.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1.8, 0, 2),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.5,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_bank_robber.mdl",
			nobonemerge = true,
			pos = Vector(-0.5, 3, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.7, 0, 2),
			scale = 0.91,
			femscale = 0.82
		},
		ScrappersSlot = "Armor"
	},
	["vest3"] = {
		"torso",
		"models/eft_props/gear/armor/ar_untar.mdl",
		Vector(-0.4, 2.6, 0),
		Angle(0, 92, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_untar.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.5,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_bank_robber.mdl",
			nobonemerge = true,
			pos = Vector(-0.6, 2.8, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.4, 0, 1.8),
			scale = 0.90,
			femscale = 0.85
		},
		ScrappersSlot = "Armor"
	},
	["vest4"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_tt_plate_carrier.mdl",
		Vector(-0.6, 3, 0),
		Angle(0, 92, 90),
		protection = 8, // бр 2
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_tt_plate_carrier.mdl",
		nobonemerge = true,
		femAng = Angle(0, 110, 90),
		femPos = Vector(-0.7, 0, 2.5),
		scale = 0.93,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 7.5,
		ScrappersSlot = "Armor"
	},
	["vest5"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b23-1.mdl",
		Vector(-1, 2.8, 0),
		Angle(0, 90, 90),
		protection = 10, // бр 3
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b23-1.mdl",
		nobonemerge = true,
		femAng = Angle(0, 97, 90),
		femPos = Vector(-1.5, 0, 1.2),
		scale = 0.92,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.3,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_zryachii.mdl",
			nobonemerge = true,
			pos = Vector(-0.6, 2.8, 0),
			ang = Angle(0, 90, 90),
			femAng = Angle(-0, 97, 90),
			femPos = Vector(-2, 0, 1.2),
			scale = 0.90,
			femscale = 0.82
		},
		ScrappersSlot = "Armor"
	},
	["vest6"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_6b5_16.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 10, // бр 3
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_6b5_16.mdl",
		nobonemerge = true,
        femAng = Angle(0, 100, 90),
		femPos = Vector(-1.2, 0, 1.8),
		scale = 0.96,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 13.1,
		ScrappersSlot = "Armor"
	},
	["vest7"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_mbss.mdl",
		Vector(-0.3, 3, 0),
		Angle(0, 92, 90),
		protection = 10, // бр 3
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_mbss.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-2.1, 0, 1.8),
		scale = 0.93,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 7.33,
		ScrappersSlot = "Armor"
	},
	["vest8"] = {
		"torso",
		"models/eft_props/gear/armor/ar_otv_ucp.mdl",
		Vector(-1, 2.6, 0),
		Angle(0, 92, 90),
		protection = 10, // бр 3
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_otv_ucp.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1, 0, 1.6),
		scale = 0.93,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_rscr_zulu.mdl",
			nobonemerge = true,
			pos = Vector(-1.35, 2.5, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.1, 0, 1.5),
			scale = 0.96,
			femscale = 0.84
		},
		ScrappersSlot = "Armor"
	},
	["vest9"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b13_digi.mdl",
		Vector(-1, 2.7, 0),
		Angle(0, 90, 90),
		protection = 12, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b13_digi.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-2, 0, 1.7),
		scale = 0.91,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8.8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_mk3.mdl",
			nobonemerge = true,
			pos = Vector(-0.5, 2.5, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.1, 0, 1.5),
			scale = 0.915,
			femscale = 0.825
		},
		ScrappersSlot = "Armor"
	},
	["vest10"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_6b3.mdl",
		Vector(-0.8, 2.9, 0),
		Angle(0, 90, 90),
		protection = 12, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_6b3.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1.3, 0, 1.8),
		scale = 0.91,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 14.2,
		ScrappersSlot = "Armor"
	},
	["vest11"] = {
		"torso",
		"models/eft_props/gear/armor/ar_thor_crv.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 12, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_thor_crv.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1, 0, 1.7),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 7.7,
			extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_bearing.mdl",
			nobonemerge = true,
			pos = Vector(-0.6, 2.9, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.5, 0, 1.8),
			scale = 0.91,
			femscale = 0.82
		},
		ScrappersSlot = "Armor"
	},
	["vest12"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_bae_rbav_af.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 12, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_bae_rbav_af.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1.2, 0, 1.9),
		scale = 0.96,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8.65,
		ScrappersSlot = "Armor"
	},
	["vest13"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b43_body.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 15, // бр 5
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b43_body.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 2),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModels = {
			{
				model = "models/eft_props/gear/armor/ar_6b43_neck.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femAng = Angle(0, 100, 90),
				femPos = Vector(-0.8, 0, 2),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			},
			{
				model = "models/eft_props/gear/armor/ar_6b43_pelvis.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femAng = Angle(0, 100, 90),
				femPos = Vector(-0.8, 0, 2),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			},
			{
				model = "models/eft_props/gear/chestrigs/cr_alpha.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femAng = Angle(0, 100, 90),
				femPos = Vector(-0.8, 0, 2),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest14"] = {
		"torso",
		"models/eft_props/gear/armor/ar_iotv.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 90, 90),
		protection = 15, // бр 5
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_iotv.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModels = {
			{
				model = "models/eft_props/gear/armor/ar_iotv_lower.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 90, 90),
				femAng = Angle(0, 100, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			},
			{
				model = "models/eft_props/gear/chestrigs/cr_lbt_1961_boss.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femAng = Angle(0, 100, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest15"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_bagarii.mdl",
		Vector(-1.1, 2.8, 0),
		Angle(0, 92, 90),
		protection = 15, // бр 5
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_bagarii.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 1.4),
		scale = 1,
		femscale = 0.9,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest16"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_osprey_defence.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 15, // бр 5
		shoulderProtection = 15.5, // бр 4
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_osprey_defence.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModels = {
			{
				model = "models/eft_props/gear/armor/cr/cr_osprey_neck.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			},
			{
				model = "models/eft_props/gear/armor/cr/cr_osprey_shoulder_l.mdl",
				bone = "ValveBiped.Bip01_L_UpperArm",
				pos = Vector(4, 0, -0.8),
				ang = Angle(0, -90, -5),
				femPos = Vector(0, 0, 0),
				scale = 0.9,
				femscale = 0.82,
				nobonemerge = true
			},
			{
				model = "models/eft_props/gear/armor/cr/cr_osprey_shoulder_r.mdl",
				bone = "ValveBiped.Bip01_R_UpperArm",
				pos = Vector(4, 0, 1),
				ang = Angle(180, 90, 5),
				femPos = Vector(0, 0, 0),
				scale = 0.9,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest17"] = {
		"torso",
		"models/eft_props/gear/armor/ar_slick_b.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 17, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_slick_b.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.7,
		extraModels = {
			{
				model = "models/eft_props/gear/chestrigs/cr_commando_b.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest18"] = {
		"torso",
		"models/eft_props/gear/armor/ar_beetle6a.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 17, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_beetle6a.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9,
		extraModels = {
			{
				model = "models/eft_props/gear/chestrigs/cr_sprofi_mk2_ak.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest19"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_black_knight.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 17, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_black_knight.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 9.6,
		ScrappersSlot = "Armor"
	},
	["vest20"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_tv110.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 17, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_tv110.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 10.3,
		ScrappersSlot = "Armor"
	},
	["vest21"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b43_body.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 19, // бр 7
		shoulderProtection = 20.5, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b43_body.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 2),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 20,
		extraModels = {
			{model = "models/eft_props/gear/chestrigs/cr_alpha.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femAng = Angle(0, 100, 90), femPos = Vector(-0.8, 0, 2), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_6b43_neck.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femAng = Angle(0, 100, 90), femPos = Vector(-0.8, 0, 2), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_6b43_pelvis.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femAng = Angle(0, 100, 90), femPos = Vector(-0.8, 0, 2), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_6b43_shoulder_l.mdl", bone = "ValveBiped.Bip01_L_UpperArm", pos = Vector(4, 0, -0.8), ang = Angle(0, -90, -5), femPos = Vector(0, 0, 0), scale = 0.9, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_6b43_shoulder_r.mdl", bone = "ValveBiped.Bip01_R_UpperArm", pos = Vector(4, 0, 1), ang = Angle(180, 90, 5), femPos = Vector(0, 0, 0), scale = 0.9, femscale = 0.82, nobonemerge = true}
		},
		ScrappersSlot = "Armor"
	},
	["vest22"] = {
		"torso",
		"models/eft_props/gear/armor/ar_thor_intcar.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 19, // бр 7
		shoulderProtection = 20.5, // бр 6
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_thor_intcar.mdl",
		nobonemerge = true,
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 18,
		extraModels = {
			{model = "models/eft_props/gear/chestrigs/cr_commando_t.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femPos = Vector(-0.8, 0, 1.4), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_thor_intcar_neck.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femPos = Vector(-0.8, 0, 1.4), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_thor_intcar_pelvis.mdl", pos = Vector(-1.3, 3, 0), ang = Angle(0, 92, 90), femPos = Vector(-0.8, 0, 1.4), scale = 0.95, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_thor_intcar_shoulder_l.mdl", bone = "ValveBiped.Bip01_L_UpperArm", pos = Vector(4, 0, -0.8), ang = Angle(0, -90, -5), femPos = Vector(0, 0, 0), scale = 0.9, femscale = 0.82, nobonemerge = true},
			{model = "models/eft_props/gear/armor/ar_thor_intcar_shoulder_r.mdl", bone = "ValveBiped.Bip01_R_UpperArm", pos = Vector(4, 0, 1), ang = Angle(180, 90, 5), femPos = Vector(0, 0, 0), scale = 0.9, femscale = 0.82, nobonemerge = true}
		},
		ScrappersSlot = "Armor"
	},
	["vest24"] = {
		"torso",
		"models/eft_props/gear/armor/ar_korundvm.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 15,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_korundvm.mdl",
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModels = {
			{
				model = "models/eft_props/gear/chestrigs/cr_triton.mdl",
				pos = Vector(-1.3, 3, 0),
				ang = Angle(0, 92, 90),
				femPos = Vector(-0.8, 0, 1.4),
				scale = 0.95,
				femscale = 0.82,
				nobonemerge = true
			}
		},
		ScrappersSlot = "Armor"
	},
	["vest27"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_precision_bigpipe.mdl",
		Vector(-0.1, 3, 0),
		Angle(0, 92, 90),
		protection = 15,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_precision_bigpipe.mdl",
		femPos = Vector(-0.4, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["vest31"] = {
		"torso",
		"models/parts hl2/medic_kevlar.mdl",
		Vector(-4.75, 3.2, -0.65),
		Angle(0, 90, 90),
		protection = 10,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/parts hl2/medic_kevlar.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/parts hl2/medic_kevlar.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest32"] = {
		"torso",
		"models/parts hl2/hl2_kevlar.mdl",
		Vector(-4.65, 3.7, -1.15),
		Angle(0, 90, 90),
		protection = 10,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/parts hl2/hl2_kevlar.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/parts hl2/hl2_kevlar.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.89,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest33"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_chestplate.mdl",
		Vector(0.2, 3.2, 0),
		Angle(0, 90, 90),
		protection = 17,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_chestplate.mdl",
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/vest/vt_chestplate.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.1, 0, 1.2),
		scale = 0.95,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest_killa"] = {
		"torso",
		"models/eft_props/gear/armor/ar_6b13_killa.mdl",
		Vector(-1, 2.7, 0),
		Angle(0, 90, 90),
		protection = 15, // бр 5
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_6b13_killa.mdl",
		nobonemerge = true,
		femAng = Angle(0, 100, 90),
		femPos = Vector(-2, 0, 1.7),
		scale = 0.91,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8.8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_commando_b.mdl",
			nobonemerge = true,
			pos = Vector(-0.5, 2.5, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-1.1, 0, 1.5),
			scale = 0.915,
			femscale = 0.825
		},
		ScrappersSlot = "Armor"
	},
	["vest_riot"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_stab_vest.mdl",
		Vector(1.5, 3.2, 0),
		Angle(0, 90, 90),
		protection = 2.3,
		meleeProt = 16,
		stabProt = 19,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_stab_vest.mdl",
		femPos = Vector(41.5, 0, 1.5),
		scale = 0.88,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 77,
		mass = 5,
		extraModel = {
			model = "models/gruchk/jmod_dayz/vest/vt_tactical_vest_black.mdl",
			pos = Vector(1.5, 3.2, 0),
			ang = Angle(0, 90, 90),
			femPos = Vector(41.5, 0, 1.5),
			scale = 0.88,
			femscale = 0.8,
			nobonemerge = true
		},
		ScrappersSlot = "Armor",
		nobonemerge = false
	},
	["vest_sobr1"] = {
		"torso",
		"models/eft_props/gear/armor/ar_korundvm.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 12,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_korundvm.mdl",
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_azimut_b.mdl",
			pos = Vector(-1.3, 3, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-0.8, 0, 1.4),
			scale = 0.95,
			femscale = 0.82,
			nobonemerge = true
		},
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest_sobr2"] = {
		"torso",
		"models/eft_props/gear/armor/ar_thor_crv.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 10,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_thor_crv.mdl",
		femAng = Angle(0, 100, 90),
		femPos = Vector(-1, 0, 1.7),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_triton.mdl",
			pos = Vector(-1.3, 3, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-0.8, 0, 1.4),
			scale = 0.95,
			femscale = 0.82,
			nobonemerge = true
		},
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest_sobr3"] = {
		"torso",
		"models/eft_props/gear/armor/ar_kirasa_black.mdl",
		Vector(-1.3, 3, 0),
		Angle(0, 92, 90),
		protection = 10,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_kirasa_black.mdl",
		femAng = Angle(0, 100, 90),
		femPos = Vector(-0.8, 0, 1.4),
		scale = 0.95,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		extraModel = {
			model = "models/eft_props/gear/chestrigs/cr_triton.mdl",
			pos = Vector(-1.3, 3, 0),
			ang = Angle(0, 92, 90),
			femAng = Angle(0, 100, 90),
			femPos = Vector(-0.8, 0, 1.4),
			scale = 0.95,
			femscale = 0.82,
			nobonemerge = true
		},
		ScrappersSlot = "Armor",
		nobonemerge = true
	},
	["vest26"] = {
		"torso",
		"models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl",
		Vector(2.35, 3.2, 0),
		Angle(0, 90, 90),
		protection = 10,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl",
		skins = {"1","2","3","4","5"},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/vest/vt_plate_carrier_tan.mdl", Vector(2.35, 3.2, 0), 0)
		end,
		femPos = Vector(-1.5, 0, 1),
		scale = 0.95,
		femscale = 0.85,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		nobonemerge = false
	},
	["vest28"] = {
		"torso",
		"models/eft_props/gear/armor/ar_paca.mdl",
		Vector(-0.4, 2.9, 0),
		Angle(0, 92, 90),
		protection = 6.4,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/ar_paca.mdl",
		femPos = Vector(-1.5, 0, 1.5),
		scale = 0.9,
		femscale = 0.82,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		Spawnable = false,
	},
	["vest30"] = {
		"torso",
		"models/eft_props/gear/armor/cr/cr_tagilla.mdl",
		Vector(-0.5, 2.8, 0),
		Angle(0, 92, 90),
		protection = 9,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/eft_props/gear/armor/cr/cr_tagilla.mdl",
		femPos = Vector(-1, 0, 0.8),
		scale = 0.95,
		femscale = 0.8,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor"
	},
	["gordon_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 9.7,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["cmb_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 2.9,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_armor"] = {
		"torso",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 0.5,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"torso"},
		nodrop = true,
		Spawnable = false,
	},
	["ego_equalizer"] = {
		"torso",
		"models/monolithservers2/kerry/sswat_armor.mdl",
		Vector(-8, 2.5, 0),
		Angle(0, 92, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/monolithservers2/kerry/sswat_armor.mdl",
		-- material = "models/shiny",
		material = "models/lightvest/accs_diff_000_d_uni", -- "models/props_c17/paper01"
		femPos = Vector(0, 0, 0),
		scale = 0.95,
		femscale = 0.95,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		AdminOnly = true
	},
}
local vectors = {
	[1] = Vector(-2,0,-1.5),
	[2] = Vector(-4,0,0.2),
	[3] = Vector(-5,0,0),
	[4] = Vector(-2,0,0),
	[5] = Vector(-4.5,0,-2)
}
hg.armor.head = {
	["helmet2"] = {
		"head",
		"models/dean/gtaiv/helmet.mdl",
		Vector(2.6, 0, 0),
		Angle(180, 110, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/dean/gtaiv/helmet.mdl",
		femPos = Vector(-1, 0, 0),
		norender = true,
		skins = {0,1,3,7,10,11,14},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/dean/gtaiv/helmet.mdl", vectors[2], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		cantsight = true,
		breakable = true,
		durability = 45,
		breakThreshold = 95,
		absorbMultiplier = 0.2,
		durabilityDamageMul = 5,
		impactProtectionMul = 1.65,
		impactDamageScale = 0.1,
		crushFallProtectionMul = 2.35,
		crushFallDamageScale = 0.04,
		crushFallDisorientPower = 10,
		crushFallDisorientTime = 9,
	},
	["helmet3"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_un.mdl",
		Vector(2, -0.37, 0.15),
		Angle(180, 100, 90),
		protection = 1.5, // бр 1
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_un.mdl",
		femPos = Vector(-0.5, 0, 0.4),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_un.mdl", vectors[2], 24)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		cantsight = true
	},
	["helmet4"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_hops_core_fast.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 1.5, // бр 1
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_hops_core_fast.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_hops_core_fast.mdl", vectors[4], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet5"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_k1c.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 1.5, // бр 1
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_k1c.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_k1c.mdl", vectors[4], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet6"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		Vector(2, -1, 0.15),
		Angle(180, 100, 90),
		protection = 1.5, // бр 1
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_s_sh_68.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_s_sh_68.mdl", vectors[4], 20)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet7"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_6b47_cover.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 4.5, // бр 3
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_6b47_cover.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_6b47_cover.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet8"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_lshz.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 4.5, // бр 3
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_lshz.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_lshz.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet9"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_mich2001.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 4.5, // бр 3
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_mich2001.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_mich2001.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet10"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_galvion_applique.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 4.5, // бр 3
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_galvion_applique.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_galvion_applique.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet11"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_zsh_1_2m_v1.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 6.5, // бр 4
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_zsh_1_2m_v1.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_zsh_1_2m_v1.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet12"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_lshz2dtm_damper.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 6.5, // бр 4
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_lshz2dtm_damper.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_lshz2dtm_damper.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet13"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_team_wendy_exfil_black.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 6.5, // бр 4
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_team_wendy_exfil_black.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_team_wendy_exfil_black.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet14"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_team_wendy_exfil_coyote.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 6.5, // бр 4
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_team_wendy_exfil_coyote.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_team_wendy_exfil_coyote.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet15"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_galvion_caiman.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 6.5, // бр 4
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_galvion_caiman.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_galvion_caiman.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet16"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_diamond_age_bastion_shield.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_diamond_age_bastion_shield.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_diamond_age_bastion_shield.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet17"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ops_core_fast_black_slaap.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ops_core_fast_black_slaap.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_ops_core_fast_black_slaap.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",

	},
	["helmet26"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_ops_core_fast_tan_slaap.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_ops_core_fast_tan_slaap.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_ops_core_fast_tan_slaap.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet27"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_rys_t.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_rys_t.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_rys_t.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet28"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_vulkan_5.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_vulkan_5.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_vulkan_5.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet29"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_maska_1sh.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_maska_1sh.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_maska_1sh.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet_killa"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_maska_1sh_killa.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_maska_1sh_killa.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/eft_props/gear/helmets/helmet_maska_1sh_killa.mdl", vectors[4], 13)
		end,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["helmet18"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl",
		Vector(1.85, -1, 0.1),
		Angle(180, 110, 90),
		protection = 12,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl",
		femPos = Vector(0, 0, -0.5),
		norender = true,
		skins = {1,2,3,4,5,6},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_great_helm.mdl", vectors[2], 0)
		end,
		viewmaterial = false,
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
	},
	["helmet19"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_norsehelm.mdl",
		Vector(1.1, -1.25, 0.1),
		Angle(180, 110, 90),
		protection = 10.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_norsehelm.mdl",
		femPos = Vector(0, 0, 0),
		norender = true,
		skins = {1,2,3,4,5,6},
		viewmaterial = false,
		scale = 0.99,
		femscale = 0.99,
		effect = "Impact",
		surfaceprop = 67,
		mass = 15,
		ScrappersSlot = "Armor",
	},
	["helmet20"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl",
		Vector(0.75, -1, 0.1),
		Angle(180, 110, 90),
		protection = 6,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl",
		femPos = Vector(0, 0, 0),
		material = "sal/hanker",
		norender = true,
		skins = {1,2,3,4,5,6},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet.mdl", vectors[1], 25)
		end,
		viewmaterial = false,
		scale = 0.95,
		femscale = 0.99,
		effect = "Impact",
		surfaceprop = 67,
		mass = 2,
		ScrappersSlot = "Armor",
		breakable = true,
		durability = 76,
		breakThreshold = 180,
		absorbMultiplier = 0.16,
		durabilityDamageMul = 5,
		impactProtectionMul = 1.75,
		impactDamageScale = 0.08,
		crushFallProtectionMul = 2.6,
		crushFallDamageScale = 0.03,
		crushFallDisorientPower = 12,
		crushFallDisorientTime = 10,
		ballisticProtectionMul = 0.85,
		ballisticDamageScale = 0.23
	},
	["helmet25"] = {
		"head",
		"models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl",
		Vector(2.27, -0.7, 0),
		Angle(180, 100, 90),
		protection = 7.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl",
		skins = {1},
		femPos = Vector(-1, 0, 0.1),
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_ballistic_helmet.mdl", vectors[2], 25)
		end,
		viewmaterial = false,
		norender = true,
		effect = "Impact",
		surfaceprop = 67,
		scale = 0.95,
		femscale = 0.95,
		mass = 1,
		ScrappersSlot = "Armor",
		breakable = true,
		durability = 76,
		breakThreshold = 170,
		absorbMultiplier = 0.2,
		durabilityDamageMul = 5,
		impactProtectionMul = 0.75,
		impactDamageScale = 0.3,
		ballisticProtectionMul = 1.2,
		ballisticDamageScale = 0.16
	},
	["helmet_sobr1"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_lshz2dtm_damper.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 4.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_lshz2dtm_damper.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor"
	},
	["helmet_sobr2"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_msa_gallet.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_msa_gallet.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor"
	},
	["helmet_sobr3"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_neosteel.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 8,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_neosteel.mdl",
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor"
	},
	["helmet_riot"] = {
		"head",
		"models/eft_props/gear/helmets/helmet_zsh_1_2m_v2.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 1.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/helmets/helmet_zsh_1_2m_v2.mdl",
		blocksHeadphones = true,
		restricted = {"ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		viewmaterial = false,
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor"
	},
	["gordon_helmet"] = {
		"head",
		"models/dpfilms/props/hev_helmet.mdl",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 8.6,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/dpfilms/props/hev_helmet.mdl",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		whitelistClasses = {
			["Gordon"] = true,
		},
		norender = true,
		AdminOnly = true
	},
	["cmb_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 3.8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["metrocop_helmet"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 3.2,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		nodrop = true,
		Spawnable = false,
	},
	["protovisor"] = {
		"head",
		"",
		Vector(-9, 2.5, 0),
		Angle(0, 92, 90),
		protection = 3.8,
		bone = "ValveBiped.Bip01_Spine2",
		model = "",
		femPos = Vector(0, 0, 0),
		scale = 1,
		femscale = 1,
		effect = "Impact",
		surfaceprop = 67,
		mass = 8,
		ScrappersSlot = "Armor",
		restricted = {"head","ears","face"},
		viewmaterial = false,
		voice_change = false,
		nodrop = true,
		Spawnable = false,
	},
}

hg.armor.ears = {
	["headphones1"] = {
		"ears",
		"models/eft_props/gear/headsets/headset_msa.mdl",
		Vector(2.2, 0, 0),
		Angle(0, 100, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/headsets/headset_msa.mdl",
		femPos = Vector(-0.5, 0, 1),
		norender = true,
		viewmaterial = Material("sprites/mat_jack_hmcd_helmover"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
		scale = 0.9,
		femscale = 0.85,
		SoundlevelAdd = 15,
		VolumeAdd = 0.2,
		NormalizeSnd = {0.75,0.2}
	}
}

local visorPos = Vector(2, -0.45, 0.15)
local visorAng = Angle(180, 100, 90)
local visorFemPos = Vector(-1.2, 0, 0.5)

local function HelmetAccessory(placement, model, protection, helmets, mass, coverage, overlay, toggleable)
	return {
		placement,
		model,
		visorPos,
		visorAng,
		protection = protection,
		meleeProt = protection * 0.4,
		stabProt = protection * 0.3,
		durability = 72 + protection * 7.2,
		breakThreshold = 65,
		absorbMultiplier = 0.2,
		durabilityDamageMul = 5,
		durabilityArmor = true,
		breakDrops = true,
		bone = "ValveBiped.Bip01_Head1",
		model = model,
		femPos = visorFemPos,
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		nobonemerge = true,
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = mass,
		ScrappersSlot = "Armor",
		coverage = coverage,
		blocksHeadphones = coverage and coverage.ears or nil,
		restricted = coverage and coverage.ears and {"ears"} or nil,
		viewmaterial = overlay and Material(overlay) or false,
		toggleableVisor = toggleable or nil,
		defaultLowered = toggleable or nil,
		requireEquipped = {
			placement = "head",
			anyOf = helmets
		}
	}
end

hg.armor.visor = {
	["visor_sobr1"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_lshz2dtm_shield.mdl", 11.5, {helmet_sobr1 = true}, 1, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_sobr2"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_ops_core_handgun_face_shield.mdl", 11.5, {helmet_sobr2 = true}, 1.2, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_riot"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_zsh_1_2m_face_shield.mdl", 11.5, {helmet_riot = true}, 1, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_kolpak"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_k1c_shield.mdl", 11.5, {helmet5 = true}, 1, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_fast"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_ops_core_fast_visor.mdl", 11.5, {helmet8 = true}, 0.32, {eyes = true}, "mask_overlays/dirty_glass", true),
	["visor_zsh"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_zsh_1_2m_face_shield.mdl", 13.5, {helmet11 = true}, 1, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_lshz2dtm"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_lshz2dtm_shield.mdl", 15.5, {helmet12 = true}, 1, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_exfil_black"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_team_wendy_exfil_face_shield_black.mdl", 13.5, {helmet13 = true, helmet14 = true}, 0.8, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_caiman"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_galvioned_arm_visor.mdl", 11.5, {helmet15 = true}, 0.27, {eyes = true}, "mask_overlays/dirty_glass", true),
	["visor_fast_shield"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_ops_core_handgun_face_shield.mdl", 13.5, {helmet17 = true, helmet26 = true}, 1.2, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_heavy_trooper"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_galactac_heavy_gunner.mdl", 11.5, {helmet17 = true, helmet26 = true}, 0.4, {eyes = true, mouth = true}, nil, true),
	["visor_rys_t"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_rys_t_shield.mdl", 18.5, {helmet27 = true}, 1.2, {eyes = true, mouth = true}, "mask_overlays/altyn.png", true),
	["visor_vulkan"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_vulkan_shield.mdl", 15.5, {helmet28 = true}, 1.8, {eyes = true, mouth = true}, "mask_overlays/dirty_glass", true),
	["visor_maska"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_maska_1sh_shield.mdl", 20.5, {helmet29 = true}, 1.1, {eyes = true, mouth = true}, "mats_jack_gmod_sprites/slit_vignette.png", true),
	["visor_killa"] = HelmetAccessory("visor", "models/eft_props/gear/helmets/helmet_maska_1sh_shield_killa.mdl", 18.5, {helmet_killa = true}, 1.1, {eyes = true, mouth = true}, "mats_jack_gmod_sprites/slit_vignette.png", true)
}

hg.armor.helmet_jaw = {
	["mandible_caiman"] = HelmetAccessory("helmet_jaw", "models/eft_props/gear/helmets/helmet_galvion_mandible.mdl", 11.5, {helmet15 = true}, 1.1, {mouth = true}),
	["chops_airframe"] = HelmetAccessory("helmet_jaw", "models/eft_props/gear/helmets/helmet_crye_airframe_chops.mdl", 13.5, {helmet17 = true, helmet26 = true}, 1.45, {mouth = true, ears = true})
}

hg.armor.helmet_ears = {
	["earcovers_exfil_black"] = HelmetAccessory("helmet_ears", "models/eft_props/gear/helmets/helmet_team_wendy_exfil_ear_covers_b.mdl", 13.5, {helmet13 = true, helmet14 = true}, 0.172, {ears = true})
}

function hg.GetArmorItemState(ent, armor, key, default)
	if not IsValid(ent) then return default end
	local states = SERVER and ent.armor_states or ent:GetNetVar("ArmorStates", ent.armor_states or {})
	local state = states and states[armor]
	if not state or state[key] == nil then return default end
	return state[key]
end

function hg.IsVisorLowered(ent, armor, armorData)
	return hg.GetArmorItemState(ent, armor, "lowered", armorData.defaultLowered ~= false)
end

local voiceMufflingArmor = {
	mandible_caiman = true,
	mask2 = true,
	mask4 = true,
	visor_exfil_black = true,
	visor_fast_shield = true,
	visor_heavy_trooper = true,
	visor_kolpak = true,
	visor_lshz2dtm = true,
	visor_killa = true,
	visor_maska = true,
	visor_riot = true,
	visor_rys_t = true,
	visor_sobr1 = true,
	visor_sobr2 = true,
	visor_vulkan = true,
	visor_zsh = true,
}

function hg.IsVoiceMuffled(ent)
	if not IsValid(ent) or not ent.armors then return false end
	for placement, armor in pairs(ent.armors) do
		if not voiceMufflingArmor[armor] then continue end
		local armorData = hg.armor[placement] and hg.armor[placement][armor]
		if not armorData or not armorData.toggleableVisor or hg.IsVisorLowered(ent, armor, armorData) then return true end
	end
	return false
end

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

local function DrawNoise(amt, alpha)
	local W, H = ScrW(), ScrH()

	for i = 0, amt do
		local Bright = math.random(0, 255)
		surface.SetDrawColor(Bright, Bright, Bright, alpha)
		local X, Y = math.random(0, W), math.random(0, H)
		surface.DrawRect(X, Y, 1, 1)
	end
end

local blurMat2, Dynamic2 = Material("pp/blurscreen"), 0

local function BlurScreen(density,alpha)
	local layers, density, alpha = 1, density or .4, alpha or 255
	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(blurMat2)
	local FrameRate, Num, Dark = 1 / FrameTime(), 3, 150

	for i = 1, Num do
		blurMat2:SetFloat("$blur", (i / layers) * density * Dynamic2)
		blurMat2:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
	end

	Dynamic2 = math.Clamp(Dynamic2 + (1 / FrameRate) * 7, 0, 1)
end

local custommat = Material("overlays/nvg_scene_opticf2.png")

sound.Add( {
	name = "breath_normal",
	channel = CHAN_STATIC,
	volume = 0.2,
	level = 55,
	pitch = 100,
	sound = "breath_normal.wav"
} )

local colormodify01 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = 0.01,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 0,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

local colormodify02 = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0.15,
	["$pp_colour_addb"] = 0.17,
	["$pp_colour_brightness"] = -0.1,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hg.armor.face = {
	["helmet31"] = {
		"face",
		"models/eft_props/gear/facecover/facecover_boss_welding_ubey.mdl",
		Vector(2, -0.45, 0.15),
		Angle(180, 100, 90),
		protection = 7.5, // бр 5
		bone = "ValveBiped.Bip01_Head1",
		model = "models/eft_props/gear/facecover/facecover_boss_welding_ubey.mdl",
		blocksHeadphones = true,
		restricted = {"head", "ears"},
		femPos = Vector(-1.2, 0, 0.5),
		scale = 0.95,
		femscale = 0.93,
		norender = true,
		extraModels = {
			{model = "models/eft_props/gear/headwear/cap_boss_tagillacap.mdl", pos = Vector(2, -0.45, 0.15), ang = Angle(180, 100, 90), femPos = Vector(-1.2, 0, 0.5), scale = 0.95, femscale = 0.93, nobonemerge = true}
		},
		viewmaterial = Material("mask_overlays/altyn.png"),
		effect = "Impact",
		surfaceprop = 67,
		mass = 1,
		ScrappersSlot = "Armor",
	},
	["mask1"] = {
		"face", -- "face"
		"models/jmod/ballistic_mask.mdl",
		Vector(4.55, -0.8, 0),
		Angle(180, 90, 90),
		protection = 14,
		meleeProt = 14,
		stabProt = 12,
		durability = 350,
		breakThreshold = 55,
		absorbMultiplier = 0.25,
		durabilityDamageMul = 4,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/jmod/ballistic_mask.mdl",
		restricted = {"head"},
		femPos = Vector(-1.2, 0, 0.15),
		material = {"sal/hanker","griggs/models/ballistic_mask_2011x","griggs/models/ballistic_mask_collector",
					"griggs/models/ballistic_mask_cute","griggs/models/ballistic_mask_golden_guard",
					"griggs/models/ballistic_mask_grunt","griggs/models/ballistic_mask_peace",
					"griggs/models/ballistic_mask_phonky","griggs/models/ballistic_mask_steamhappy",
					"griggs/models/ballistic_mask_z", "griggs/models/ballistic_mask_pluvmaska",
					"griggs/models/ballistic_mask_coolkid_01","griggs/models/ballistic_mask_coolkid_02",
					"sosoda/models/ballistic_mask_manhunt"},
		norender = true,
		scale = 1,
		femscale = 0.97,
		viewmaterial = Material("sprites/mat_jack_hmcd_narrow"),
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask2"] = {
		"face", -- "face"
		"models/gasmasksfix/m40_drop.mdl",
		Vector(3,-2,-0.5),
		Angle(-90, 90, 0),
		protection = 6,
		meleeProt = 6,
		stabProt = 4,
		durability = 220,
		breakThreshold = 45,
		absorbMultiplier = 0.25,
		durabilityDamageMul = 4,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gasmasksfix/m40_fix.mdl",
		femPos = Vector(-1,0,0),
		norender = true,
		scale = 1,
		femscale = 1,
		viewmaterial = Material("overlays/ba_gasmask"),
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask4"] = {
		"face", -- "face"
		"models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl",
		Vector(1,0.2,0),
		Angle(180, 90, 90),
		protection = 1.5,
		femPos = Vector(0,0.1,0.5),
		femscale = 0.98,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl",
		skins = {1,2,3,4,5},
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/helmets/ht_enduro_helmet_mouth.mdl", vectors[4], 25)
		end,
		viewmaterial = false,
		norender = true,
		scale = 1.04,
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		restricted = {"face"},
		requireEquipped = {
			placement = "head",
			armor = "helmet20"
		},
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["mask5"] = {
		"face", -- "face"
		"models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl",
		Vector(2,-2.2, 0.07),
		Angle(180, 90, 90),
		protection = 1.5,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl",
		femPos = Vector(-1,0,0),
		customviewrender = function(ply)
			DrawFirstPersonHelmet(ply, "models/gruchk/jmod_dayz/face/fe_nbc_respirator.mdl", vectors[1], 25)
		end,
		norender = true,
		scale = 0.9,
		femscale = 1,
		viewmaterial = Material("vision_sprites_dayz/gasmask.png"),
		effect = "Impact",
		surfaceprop = 67,
		loopsound = "breath_normal",
		mass = 0.5,
		ScrappersSlot = "Armor",
		voice_change = true,
	},
	["nightvision1"] = {
		"face", -- "face"
		"models/arctic_nvgs/nvg_gpnvg.mdl",
		Vector(1.6, 0.6, 0),
		Angle(0, -90, -90),
		protection = 0,
		bone = "ValveBiped.Bip01_Head1",
		model = "models/arctic_nvgs/nvg_gpnvg.mdl",
		femPos = Vector(-1, 0, 0.5),
		norender = true,
		scale = 0.95,
		femscale = 0.92,
		effect = "MetalSpark",
		surfaceprop = 77,
		mass = 1.5,
		ScrappersSlot = "Armor",
		custommat = Material("overlays/nvg_scene_opticf2.png"),
		NVGRender = function()
			 
			if not IsValid(lply.EZNVGlamp) then
				lply.EZNVGlamp = ProjectedTexture()
				lply.EZNVGlamp:SetTexture("effects/flashlight001")
				lply.EZNVGlamp:SetBrightness(.06)
				lply.EZNVGlamp:SetEnableShadows(false)
				local FoV = lply:GetFOV()
				lply.EZNVGlamp:SetFOV(FoV + 45)
				lply.EZNVGlamp:SetFarZ(500000 / FoV)
				lply.EZNVGlamp:SetConstantAttenuation(.1)
			else
				local Ang = EyeAngles()
				lply.EZNVGlamp:SetPos(lply:EyePos())
				lply.EZNVGlamp:SetAngles(Ang)
				lply.EZNVGlamp:Update()
			end

			BlurScreen(0.2,65)

			DrawColorModify(colormodify01)
			DrawColorModify(colormodify02)

			DrawBloom(0.4, 1, 4, 4, 1, 0, 12, 12, 6)
			DrawNoise(500,25)

			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(custommat or mat)
			local viewpunching = GetViewPunchAngles()
			local w, h = ScrW(), ScrH()
			surface.DrawTexturedRect(-w + (w * 1.5) / 2 - viewpunching.r * 6, -20 - viewpunching.x * 6, w * 1.5, h + 40)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.DrawRect(-w + (w * 1.5) / 2, (h + 20) - viewpunching.x * 6, w * 1.5, h + 40)
			surface.DrawRect(-w + (w * 1.5) / 2, -(h + 40) - viewpunching.x * 6, w * 1.5, h + 40)
		end,
		CustomSnd = "snds_jack_gmod/tinycapcharge.wav",
		AfterPickup = function(ply)
			--timer.Simple(1,function()
			--	if IsValid(ply) and ply:IsPlayer() then
			--		ply:Notify("Enable \\ Disable NVG - С + E",nil,nil,0)
			--	end
			--end)
		end
	}
}

hg.armor.back = {
	["aqualung"] = {
		"back",
		"models/ceejae_scuba/wet_suit.mdl",
		Vector(5.5, 3.2, 0),
		Angle(0, 92, 90),
		protection = 0,
		bone = "ValveBiped.Bip01_Spine2",
		model = "models/ceejae_scuba/wet_suit.mdl",
		femPos = Vector(0, 0, 0),
		scale = 0.91,
		femscale = 0.91,
		effect = "Impact",
		surfaceprop = 67,
		mass = 5,
		ScrappersSlot = "Armor",
	}
}

if CLIENT then
	net.Receive("AddFlash", function()
		local pos = net.ReadVector()
		local time = net.ReadFloat()
		local size = net.ReadInt(20)
		if not IsValid(lply) then return end
		hg.AddFlash(hg.eye(lply), 1, pos, time, size)
	end)
end

local armorNames = {
	["aqualung"] = "Scuba Suit",
	["ego_equalizer"] = "[HE] Equalizer",
	["gordon_helmet"] = "HEV Suit Helmet",
	["headphones1"] = "MSA Sordin Supreme PRO-X/L",
	["nightvision1"] = "NVG GPNVG 18",
	["helmet2"] = "Biker Helmet",
	["helmet3"] = "UNTAR Helmet I",
	["helmet4"] = "Tac-Kek FAST MT I",
	["helmet5"] = "Kolpak-1S I",
	["helmet6"] = "SSh-68 Steel Helmet I",
	["helmet7"] = "6B47 Covered Helmet III",
	["helmet8"] = "LShZ Light Helmet III",
	["helmet9"] = "TC-2001 Helmet III",
	["helmet10"] = "Caiman Applique Helmet III",
	["helmet11"] = "ZSh-1-2M Helmet IV",
	["helmet12"] = "LShZ-2DTM Covered Helmet IV",
	["helmet13"] = "Team Wendy EXFIL Black IV",
	["helmet14"] = "Team Wendy EXFIL Black IV",
	["helmet15"] = "Caiman Helmet IV",
	["helmet16"] = "Bastion Plate Helmet V",
	["helmet17"] = "FAST MT Black SLAAP V",
	["helmet18"] = "Great Helmet",
	["helmet19"] = "Norce Helmet",
	["helmet20"] = "Enduro Helmet",
	["helmet25"] = "Tactical MVD Helmet",
	["helmet26"] = "FAST MT Tan SLAAP V",
	["helmet27"] = "Rys-T Helmet V",
	["helmet28"] = "Vulkan-5 Helmet V",
	["helmet29"] = "Maska-1Sh Helmet V",
	["helmet31"] = "\"Ubey\" Welding Mask",
	["helmet_killa"] = "Killa Maska-1Sh Helmet V",
	["helmet_riot"] = "RIOT ZSh-1-2M Helmet I",
	["helmet_sobr1"] = "SOBR LShZ-2DTM Helmet III",
	["helmet_sobr2"] = "SOBR Gallet TC 800 Helmet II",
	["helmet_sobr3"] = "SOBR NeoSteel Helmet II",
	["mask1"] = "Balistic Mask",
	["mask2"] = "M40 Gas Mask",
	["mask4"] = "Enduro Mask",
	["mask5"] = "Combat GasMask",
	["chops_airframe"] = "Crye AirFrame Chops III",
	["earcovers_exfil_black"] = "Team Wendy EXFIL Ear Covers III",
	["mandible_caiman"] = "Caiman Mandible II",
	["vest1"] = "6B2 Body Armor II",
	["vest2"] = "PACA Body Armor II",
	["vest3"] = "UNTAR Body Armor II",
	["vest4"] = "TT Plate Carrier II",
	["vest5"] = "6B23-1 Body Armor III",
	["vest6"] = "6B5-16 Body Armor III",
	["vest7"] = "MBSS Body Armor III",
	["vest8"] = "OTV UCP Body Armor III",
	["vest9"] = "6B13 Digital Body Armor IV",
	["vest10"] = "6B3 Body Armor IV",
	["vest11"] = "THOR CRV Body Armor IV",
	["vest12"] = "RBAV-AF Body Armor IV",
	["vest13"] = "6B43 Armor Kit V",
	["vest14"] = "IOTV Gen4 Armor Kit V",
	["vest15"] = "Bagariy Armored Rig V",
	["vest16"] = "Osprey MK4A Protection V",
	["vest17"] = "Slick Black Armor VI",
	["vest18"] = "Zhuk-6A Armor VI",
	["vest19"] = "CPC GE Armored Rig VI",
	["vest20"] = "TV-110 Armored Rig VI",
	["vest21"] = "6B43 Armor Kit VII",
	["vest22"] = "THOR Integrated Carrier VII",
	["vest24"] = "Korund-VM Vest",
	["vest26"] = "Plate Carrier Vest III",
	["vest27"] = "PlateFrame GE Vest",
	["vest28"] = "Strandhogg Vest",
	["vest30"] = "\"Tagilla\" CR Vest",
	["vest31"] = "Rebel Medic Vest",
	["vest32"] = "Rebel Vest",
	["vest33"] = "Iron ChestPlate",
	["vest_killa"] = "Killa 6B13 M Body Armor V",
	["vest_riot"] = "MVD RIOT Vest",
	["vest_sobr1"] = "SOBR Korund-VM Armor IV",
	["vest_sobr2"] = "SOBR THOR CRV Armor III",
	["vest_sobr3"] = "SOBR Kora-Kulon Armor III",
	["visor_caiman"] = "Caiman Visor II",
	["visor_exfil_black"] = "Team Wendy EXFIL Face Shield III",
	["visor_fast"] = "FAST MT Visor II",
	["visor_fast_shield"] = "FAST MT Face Shield III",
	["visor_heavy_trooper"] = "Heavy Trooper Face Mask II",
	["visor_killa"] = "Killa Maska-1Sh Face Shield V",
	["visor_kolpak"] = "Kolpak-1S Visor II",
	["visor_lshz2dtm"] = "LShZ-2DTM Face Shield IV",
	["visor_maska"] = "Maska-1Sh Face Shield VI",
	["visor_riot"] = "RIOT ZSh-1-2M Face Shield II",
	["visor_rys_t"] = "Rys-T Face Shield V",
	["visor_sobr1"] = "SOBR LShZ-2DTM Face Shield II",
	["visor_sobr2"] = "SOBR Gallet Face Shield II",
	["visor_vulkan"] = "Vulkan-5 Face Shield IV",
	["visor_zsh"] = "ZSh-1-2M Face Shield III",
}
hg.armorNames = armorNames
local armorIcons = {
	["aqualung"] = "entities/ent_aqualung.png",
	["ego_equalizer"] = "entities/ent_jack_gmod_ezarmor_hazmat.png",
	["headphones1"] = "entities/ent_jack_gmod_ezarmor_sordin.png",
	["nightvision1"] = "vgui/icons/nvg",
	["helmet2"] = "vgui/icons/mothelmet.png",
	["helmet3"] = "entities/ent_jack_gmod_ezarmor_untarhelm.png",
	["helmet4"] = "entities/ent_jack_gmod_ezarmor_tackekfastmt.png",
	["helmet5"] = "entities/ent_jack_gmod_ezarmor_kolpak1s.png",
	["helmet6"] = "entities/ent_jack_gmod_ezarmor_ssh68.png",
	["helmet7"] = "entities/ent_jack_gmod_ezarmor_6b47chehol.png",
	["helmet8"] = "entities/ent_jack_gmod_ezarmor_lshz.png",
	["helmet9"] = "entities/ent_jack_gmod_ezarmor_mich2001.png",
	["helmet10"] = "entities/ent_jack_gmod_ezarmor_caimanapplique.png",
	["helmet11"] = "entities/ent_jack_gmod_ezarmor_zshhelm.png",
	["helmet12"] = "entities/ent_jack_gmod_ezarmor_lshz2dtmcovered.png",
	["helmet13"] = "entities/ent_jack_gmod_ezarmor_twexfilb.png",
	["helmet14"] = "entities/ent_jack_gmod_ezarmor_twexfilc.png",
	["helmet15"] = "entities/ent_jack_gmod_ezarmor_caiman.png",
	["helmet16"] = "entities/ent_jack_gmod_ezarmor_bastionshield.png",
	["helmet17"] = "entities/ent_jack_gmod_ezarmor_fastmtblackslaap.png",
	["helmet18"] = "entities/ent_jack_gmod_ezarmor_greathelm.png",
	["helmet19"] = "entities/ent_jack_gmod_ezarmor_norsehelm.png",
	["helmet20"] = "entities/ent_jack_gmod_ezarmor_enduroblack.png",
	["helmet25"] = "entities/ent_jack_gmod_ezarmor_ballistichelmet.png",
	["helmet26"] = "entities/ent_jack_gmod_ezarmor_fastmttanslaap.png",
	["helmet27"] = "entities/ent_jack_gmod_ezarmor_ryst.png",
	["helmet28"] = "entities/ent_jack_gmod_ezarmor_vulkan5.png",
	["helmet29"] = "entities/ent_jack_gmod_ezarmor_maska1sh.png",
	["helmet31"] = "entities/ent_jack_gmod_ezarmor_weldingkill.png",
	["helmet_killa"] = "entities/ent_jack_gmod_ezarmor_maska1shkilla.png",
	["helmet_riot"] = "entities/ent_jack_gmod_ezarmor_zshhelmv2.png",
	["helmet_sobr1"] = "entities/ent_jack_gmod_ezarmor_lshz2dtmcovered.png",
	["helmet_sobr2"] = "entities/ent_jack_gmod_ezarmor_tc800.png",
	["helmet_sobr3"] = "entities/ent_jack_gmod_ezarmor_neosteel.png",
	["mask1"] = "entities/ent_jack_gmod_ezarmor_ballisticmask.png",
	["mask2"] = "vgui/icons/gasmask",
	["mask4"] = "entities/ent_jack_gmod_ezarmor_enduromouthblack.png",
	["mask5"] = "entities/ent_jack_gmod_ezarmor_nbcgas.png",
	["chops_airframe"] = "entities/ent_jack_gmod_ezarmor_cryeairframechops.png",
	["earcovers_exfil_black"] = "entities/ent_jack_gmod_ezarmor_twexfilearb.png",
	["mandible_caiman"] = "entities/ent_jack_gmod_ezarmor_caimanmandible.png",
	["vest1"] = "entities/ent_jack_gmod_ezarmor_6b2.png",
	["vest2"] = "entities/ent_jack_gmod_ezarmor_paca.png",
	["vest3"] = "entities/ent_jack_gmod_ezarmor_untar.png",
	["vest4"] = "entities/ent_jack_gmod_ezarmor_ttsk.png",
	["vest5"] = "entities/ent_jack_gmod_ezarmor_6b23.png",
	["vest6"] = "entities/ent_jack_gmod_ezarmor_6b516.png",
	["vest7"] = "entities/ent_jack_gmod_ezarmor_eaimbss.png",
	["vest8"] = "entities/ent_jack_gmod_ezarmor_interceptor.png",
	["vest9"] = "entities/ent_jack_gmod_ezarmor_6b13.png",
	["vest10"] = "entities/ent_jack_gmod_ezarmor_6b3tm.png",
	["vest11"] = "entities/ent_jack_gmod_ezarmor_thorcrv.png",
	["vest12"] = "entities/ent_jack_gmod_ezarmor_rbavaf.png",
	["vest13"] = "entities/ent_jack_gmod_ezarmor_6b43vest.png",
	["vest14"] = "entities/ent_jack_gmod_ezarmor_iotvvest.png",
	["vest15"] = "entities/ent_jack_gmod_ezarmor_bagariy.png",
	["vest16"] = "entities/ent_jack_gmod_ezarmor_ospreyprotec.png",
	["vest17"] = "entities/ent_jack_gmod_ezarmor_slickblack.png",
	["vest18"] = "entities/ent_jack_gmod_ezarmor_zhuk6a.png",
	["vest19"] = "entities/ent_jack_gmod_ezarmor_cpcge.png",
	["vest20"] = "entities/ent_jack_gmod_ezarmor_tv110.png",
	["vest21"] = "entities/ent_jack_gmod_ezarmor_6b43vest.png",
	["vest22"] = "entities/ent_jack_gmod_ezarmor_thoricvest.png",
	["vest24"] = "entities/ent_jack_gmod_ezarmor_korundvm.png",
	["vest26"] = "entities/ent_jack_gmod_ezarmor_plateblack.png",
	["vest27"] = "entities/ent_jack_gmod_ezarmor_plateframege.png",
	["vest28"] = "entities/ent_jack_gmod_ezarmor_paca.png",
	["vest30"] = "entities/ent_jack_gmod_ezarmor_tagilla.png",
	["vest31"] = "entities/ent_jack_gmod_ezarmor_rebelmedtorso.png",
	["vest32"] = "entities/ent_jack_gmod_ezarmor_rebeltorso.png",
	["vest33"] = "entities/ent_jack_gmod_ezarmor_chestplate.png",
	["vest_killa"] = "entities/ent_jack_gmod_ezarmor_6b13m.png",
	["vest_riot"] = "entities/ent_jack_gmod_ezarmor_stab.png",
	["vest_sobr1"] = "entities/ent_jack_gmod_ezarmor_korundvm.png",
	["vest_sobr2"] = "entities/ent_jack_gmod_ezarmor_thorcrv.png",
	["vest_sobr3"] = "entities/ent_jack_gmod_ezarmor_kora_kulon_b.png",
	["visor_caiman"] = "entities/ent_jack_gmod_ezarmor_caimanvisor.png",
	["visor_exfil_black"] = "entities/ent_jack_gmod_ezarmor_twexfilshieldb.png",
	["visor_fast"] = "entities/ent_jack_gmod_ezarmor_fastmtvisor.png",
	["visor_fast_shield"] = "entities/ent_jack_gmod_ezarmor_fastmtshield.png",
	["visor_heavy_trooper"] = "entities/ent_jack_gmod_ezarmor_tackekhtrooper.png",
	["visor_killa"] = "entities/ent_jack_gmod_ezarmor_shlemmaskkilla.png",
	["visor_kolpak"] = "entities/ent_jack_gmod_ezarmor_koplak1svisor.png",
	["visor_lshz2dtm"] = "entities/ent_jack_gmod_ezarmor_lshz2dtmshield.png",
	["visor_maska"] = "entities/ent_jack_gmod_ezarmor_shlemmask.png",
	["visor_riot"] = "entities/ent_jack_gmod_ezarmor_zshface.png",
	["visor_rys_t"] = "entities/ent_jack_gmod_ezarmor_rystface.png",
	["visor_sobr1"] = "entities/ent_jack_gmod_ezarmor_lshz2dtmshield.png",
	["visor_sobr2"] = "entities/ent_jack_gmod_ezarmor_fastmtshield.png",
	["visor_vulkan"] = "entities/ent_jack_gmod_ezarmor_vulkan5shield.png",
	["visor_zsh"] = "entities/ent_jack_gmod_ezarmor_zshface.png",
}
hg.armorIcons = armorIcons

-- Balance: give every armor piece durability/absorb suited to its protection
-- class, and give helmets/visors a material ricochet chance instead of pure absorption.
do
	local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

	-- Characteristic durability per ballistic tier. Higher-tier plates and
	-- helmets are tougher and survive more hits before breaking.
	local helmetTier = {
		[0] = {durability = 40, breakThreshold = 90},
		[1.5] = {durability = 55, breakThreshold = 130},
		[3.2] = {durability = 65, breakThreshold = 150},
		[3.8] = {durability = 70, breakThreshold = 160},
		[4.5] = {durability = 80, breakThreshold = 180},
		[6] = {durability = 90, breakThreshold = 200},
		[6.5] = {durability = 95, breakThreshold = 210},
		[7.5] = {durability = 110, breakThreshold = 240},
		[8] = {durability = 120, breakThreshold = 260},
		[8.6] = {durability = 130, breakThreshold = 280},
		[10.5] = {durability = 105, breakThreshold = 235},
		[12] = {durability = 140, breakThreshold = 320},
	}
	local vestTier = {
		[9.9] = {health = 2.3, healthDamageMul = 0.013},
		[11.5] = {health = 2.6, healthDamageMul = 0.012},
		[12.5] = {health = 2.8, healthDamageMul = 0.0115},
		[13.5] = {health = 2.9, healthDamageMul = 0.011},
		[15.5] = {health = 3.2, healthDamageMul = 0.01},
		[18.5] = {health = 3.6, healthDamageMul = 0.009},
		[20.5] = {health = 4.0, healthDamageMul = 0.008},
		[22.5] = {health = 4.4, healthDamageMul = 0.0075},
	}

	for placement, tbl in pairs(hg.armor) do
		for name, data in pairs(tbl) do
			if istable(data) and isnumber(data.protection) then
				local prot = data.protection
				local isDurability = data.durabilityArmor ~= nil and data.durabilityArmor
					or placement == "head" or placement == "face"

				if isDurability then
					local tier = helmetTier[prot]
					data.durability = data.durability or (tier and tier.durability or math.floor(28 + prot * 11))
					data.breakThreshold = data.breakThreshold or (tier and tier.breakThreshold or math.floor(55 + prot * 12))
					data.absorbMultiplier = data.absorbMultiplier or 0.2
					data.durabilityDamageMul = data.durabilityDamageMul or 5
					data.durabilityArmor = true
					-- Ballistic helmets/visors deflect more than they absorb; the
					-- higher the protection class, the higher the ricochet tendency.
					data.ricochetChance = data.ricochetChance or
						(placement == "head" and clamp(0.2 + prot * 0.045, 0.2, 0.68)
							or clamp(0.2 + prot * 0.02, 0.14, 0.4))
				elseif placement == "torso" then
					local tier = vestTier[prot]
					data.health = data.health or (tier and tier.health or (1.25 + prot * 0.12))
					data.healthDamageMul = data.healthDamageMul or (tier and tier.healthDamageMul or 0.012)
				end
			end
		end
	end
end

local entityMeta = FindMetaTable("Entity")
function entityMeta:SyncArmor()
	if self.armors then
		self:SetNetVar("Armor", self.armors)
		self:SetNetVar("ArmorStates", table.Copy(self.armor_states or {}))
		local rag = hg.GetCurrentCharacter(self)
		if IsValid(rag) and rag:IsRagdoll() then
			rag.armors = table.Copy(self.armors)
			rag.armors_shots = table.Copy(self.armors_shots or {})
			rag.armors_health = table.Copy(self.armors_health or {})
			rag.armors_durability = table.Copy(self.armors_durability or {})
			rag.armors_regions = table.Copy(self.armors_regions or {})
			rag.armors_broken = table.Copy(self.armors_broken or {})
			rag.armors_broken_mul = table.Copy(self.armors_broken_mul or {})
			rag.armor_states = table.Copy(self.armor_states or {})
			rag:SetNetVar("Armor", self.armors)
			rag:SetNetVar("ArmorStates", table.Copy(self.armor_states or {}))
			rag:SetNetVar("HideArmorRender", self:GetNetVar("HideArmorRender", false))
		end
	end
end

local function initArmor()
	for possibleArmor, armors in pairs(hg.armor) do
		for armorkey, armorData in pairs(armors) do
			if CLIENT then language.Add(armorkey, armorNames[armorkey] or armorkey) end
			if armorData.inbuilt then continue end
			
			local armor = {}
			armor.Base = "armor_base"
			armor.PrintName = CLIENT and language.GetPhrase(armorkey) or armorkey
			armor.name = armorkey
			armor.Category = "ZCity Armor"
			armor.Spawnable = true
			if armorData.Spawnable != nil then
				armor.Spawnable = false
			end
			if armorData.AdminOnly then
				armor.AdminOnly = true
			end
			armor.Model = armorData[2]
			armor.WorldModel = armorData[2]
			armor.SubMats = armorData[4]
			armor.armor = armorData
			armor.placement = armorData[1]
			armor.IconOverride = armorIcons[armorkey]
			armor.PhysModel = armorData.PhysModel or nil
			armor.PhysPos = armorData.PhysPos or nil
			armor.PhysAng = armorData.PhysAng or nil
			armor.material = armorData.material or nil
			armor.skins = armorData.skins or nil
			scripted_ents.Register(armor, "ent_armor_" .. armorkey)
		end
	end
end

function hg.GetArmorPlacement(armor)
	if istable(armor) then return end
	armor = string.Replace(armor,"ent_armor_","")
	
	local found
	for i,armplc in pairs(hg.armor) do
		for i2,armor2 in pairs(armplc) do
			if i2 == armor then found = i end
		end
	end
	return found
end

local stringToNum = {
	["torso"] = 1,
	["head"] = 2,
	["face"] = 3,
}

function hg.GetArmorPlacementNum(armor)
	return stringToNum[hg.GetArmorPlacement(armor)]
end

initArmor()
hook.Add("Initialize", "init-atts", initArmor)
