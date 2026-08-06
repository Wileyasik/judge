hg.attachments = {}

function hg.GetAK74SightProfile()
	return {
		mountType = {"dovetail", "picatinny"},
		mount = {
			dovetail = Vector(-22, -0.25, 1.8),
			picatinny = Vector(-21, 0, 2.35),
		},
		mountAngle = Angle(0, 0, 90),
	}, {
		mountAngle = Angle(0, 90, 0),
		picatinny = {"mount3", Vector(-22, 0.85, 0.3), {}, mountType = "picatinny"},
		dovetail = {"empty", Vector(0, 0, 0), {}, mountType = "dovetail"},
	}
end

function hg.GetAR15StockProfile(defaultStock)
	local profile = {
		[1] = {"stock_ar15_dd_enhanced", Vector(0, 0, 0), {}},
		[2] = {"stock_ar15_fab_defense_gl_core_s", Vector(0, 0, 0), {}},
		[3] = {"stock_ar15_magpul_moe_sl_k", Vector(0, 0, 0), {}},
		[4] = {"stock_ar15_magpul_moe_carbine", Vector(0, 0, 0), {}},
		mountType = "ar15_stock",
	}
	if defaultStock then profile[5] = {defaultStock, Vector(0, 0, 0), {}} end
	return profile
end

hg.attachments.sight = {
	["empty"] = {"sight", "", Angle(0, 0, 0), {}},
	["holo0"] = {
		"sight", -- integrated
		"",
		Angle(0, 0, 0),
		{}
	},
	["holo1"] = {
		"sight",
		"models/weapons/tfa_ins2/upgrades/phy_optic_eotech.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.5, 0, 9),
		{
			--[1] = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass"
		},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_eotech_xps3-2_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1,
		holo_lum = 0.1,
		valid = true,
	},
	["holo2"] = {
		"sight",
		"models/weapons/mods/scope_all_aksion_ekp_8_18.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.7, -0.03, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/scope_all_ekb_okp7_true_marks.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_sig_romeo_8t.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.45, -0.03, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_sig_romeo_8t_lod0_mark.png"),
		holo_size = CLIENT and ScreenScale(0.45) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo4"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_walther_mrs.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.02, -0.05),
		offsetView = Vector(-1.4, -0.03, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_walther_mrs_mark_001.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo5"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_ekb_okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.2, 0.1, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_ekb_okp7_true_marks.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo5fur"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_ekb_okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.2, 0.1, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/reticles/okp.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo6"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2, 0.25, 0.2),
		offsetView = Vector(-0.75, 0.2, 6),
		{},
		mountType = "dovetail",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_ekb_okp7_true_marks.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 2),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo6fur"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/okp7.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2, 0.25, 0.2),
		offsetView = Vector(-0.75, 0.2, 6),
		{},
		mountType = "dovetail",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/reticles/okp.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 2),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo7"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_belomo_pk_06.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, -0.05),
		offsetView = Vector(-1.1, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_belomo_pk_06_mark_000.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo8"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_holosun_hs401g5.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-1.4, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_aimpoint_micro_h1_high_marks.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		holo_lum = 0.1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo9"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_leapers_utg_38_ita_1x30.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-1, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_leapers_utg_38_ita_1x30_mark2.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo11"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_trijicon_srs_02.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.1, 0),
		offsetView = Vector(-1.5, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_aimpoint_micro_h1_high_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo12"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_1p87.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-2, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("zcity/holo/1p87_ret_b_ca.png"),
		holo_size = CLIENT and ScreenScale(1.1) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo13"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_krechet.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.1, 0),
		offsetView = Vector(-2.35, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("zcity/holo/1p87_ret_a_ca.png"),
		holo_size = CLIENT and ScreenScale(1.5) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo14"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/eft_optic_xps3_0.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.05),
		offsetView = Vector(-1.45, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_eotech_xps3-4_marks.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo15"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_base_sig_romeo_4.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0.8, -0.05),
		offsetView = Vector(-0.75, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_sig_romeo_4_base_weaver.mdl",
		mountVec = Vector(0.2, 0, -0.78),
		mountAng = Angle(0, 0, 0),

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_sig_romeo_4_mark.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo16"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_base_trijicon_rmr.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 1, 0.35),
		offsetView = Vector(-0.55, 0, 10),
		{},
		mountType = "pistolmount",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_dovetail_belomo_pk_aa_mark.png"),
		holo_size = CLIENT and ScreenScale(0.6) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),

		mount = "models/weapons/mods/mount_all_trijicon_rm33.mdl",
		mountVec = Vector(-0, 0, -0.2),
		mountAng = Angle(0, 0, 0),

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
			if self.availableAttachments.sight.mountBone then return end
			vecadd:Add(ang:Forward() * -(self.shooanim or 0) * (self.SightSlideOffset or 1))
		end,
		valid = true,
	},
	["holo17"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/steiner_r1x.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.2, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "effects/arc9/rt",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_leupold_deltapoint_marks.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1, --size of the holo
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["optic0"] = {
		stablereticle = true,
		"sight", --встроенный
		"",
		Angle(0, 0, 0),
		{},
	},
	["optic2"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_fullfield_tac30.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.025),
		offsetView = Vector(0, 0, 13),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_burris_fullfield_tac30_1_4x24_marks.png"),
		localScopePos = Vector(2, 0, 0),
		scope_blackout = 2000,
		rot = 0,
		FOVMin = 6,
		FOVMax = 28,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 2200,
		perekrestieSize = true,
		stableReticle = true,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_geissele_super_precision.mdl",
		mountVec = Vector(-3, 0, -1.5),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_all_valday_ps320.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, -0.02),
		offsetView = Vector(-1.5, 0, 8.5),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("decals/perekrestie11.png"),
		localScopePos = Vector(2, 0, 1.5),
		scope_blackout = 1400,
		rot = 0,
		FOVMin = 3,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 3548,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		perekrestieSize = false,
		stableReticle = true,

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic4"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/pso1m2.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-2, 0, 0.3),
		offsetView = Vector(-0.8, 0.56, 7.5),
		mountType = "dovetail",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_dovetail_belomo_pso_1_4x24_marks_0.png"),
		localScopePos = Vector(12, 0.56, 0.8),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 12,
		FOVMax = 12,
		FOVScoped = 40,
		blackoutsize = 4200,
		sizeperekrestie = 2000,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		perekrestieSize = true,
		stableReticle = true,

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic5"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_razor_hd.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.03),
		offsetView = Vector(0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_razor_hd_gen_2_1_6x24_mark.png"),
		localScopePos = Vector(2, 0, 0),
		scope_blackout = 2000,
		rot = 0,
		FOVMin = 6,
		FOVMax = 28,
		FOVScoped = 20,
		blackoutsize = 3700,
		sizeperekrestie = 3200,
		perekrestieSize = true,
		stableReticle = true,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_geissele_super_precision.mdl",
		mountVec = Vector(-3, 0, -1.6),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic6"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_leupold_mark4.mdl",
		Angle(0, 0, -90),
		offset = Vector(2, 1.5, -0.03),
		offsetView = Vector(0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/adjustable/scope_35mm_leupold_mark_5hd_5_25x56_mark_f.png"),
		localScopePos = Vector(0, 0, 0),
		scope_blackout = 3400,
		rot = 0,
		FOVMin = 2,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 3800,
		sizeperekrestie = 2000,
		perekrestieSize = false,
		stableReticle = true,
		mount = "models/weapons/arc9/darsu_eft/mods/mount_all_lobaev_dvl.mdl",
		mountVec = Vector(-1.8, 0, -1.5),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic7"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_sig_bravo4.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.35, 0, 9),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_sig_bravo4_4x30_marks.png"),
		localScopePos = Vector(0, 0, 1.36),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 11,
		FOVMax = 11,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 2100,
		perekrestieSize = true,
		stableReticle = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic8"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_leupold_mark4_hamr.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.025),
		offsetView = Vector(-1.65, 0, 8),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_leupold_mark4_hamr_marks.png"),
		localScopePos = Vector(7, 0, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 16,
		FOVMax = 16,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 2500,
		perekrestieSize = false,
		stableReticle = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_walther_mrs_mark_001.png"),
		holo_size = CLIENT and ScreenScale(0.45) or 1, --size of the holo

		holomodel = "models/weapons/arc9/darsu_eft/mods/scope_base_burris_fast_fire_3.mdl",
		addholovec = Vector(0.4,0,2.3),
		addholoang = Angle(0,0,0),
		drawFunction = function(self,model) -- in swep:drawattachment
			if not IsValid(self) then return end

			self.modelAtt["addholo"] = IsValid(self.modelAtt["addholo"]) and self.modelAtt["addholo"] or ClientsideModel(hg.attachments.sight["optic8"].holomodel)
			local addholo = self.modelAtt["addholo"]

			addholo:DrawModel()
			addholo:SetNoDraw(model:GetNoDraw())

			local model2 = addholo.model
			if not IsValid(model2) then
				model2 = ClientsideModel(hg.attachments.sight["optic8"].holomodel)
				addholo.model = model2
				
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
			if not addholo.submat then
				addholo:SetSubMaterial(0,"null")
				addholo:SetSubMaterial(1,"white")
		
				model2:SetSubMaterial(0,"")
				model2:SetSubMaterial(1,"null")
				addholo.submat = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		viewFunction = function(self,model,pos)
			if self:KeyDown(IN_ATTACK2) then
				if (IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_JUMP)) or (!IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_USE)) then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_"..(self.viewmode1 and "in" or "out").."_0"..math.random(4)..".wav",35,math.random(95,105))
					end
				else
					self.keypr = false
				end
			end

			local ang = model:GetAngles()

			if self.viewmode1 then
				self.upview = Lerp(FrameTime()*12, self.upview or 0, 1.3)
			else
				self.upview = Lerp(FrameTime()*4, self.upview or 0, 0)
			end

			pos = pos + ang:Up() * self.upview

			return pos
		end,

		transformFunction = function(self,model,pos,ang) -- in transformfunction
			if not IsValid(self) then return end
			self.modelAtt["addholo"] = self.modelAtt["addholo"] or ClientsideModel(hg.attachments.sight["optic8"].holomodel)
			local addholo = self.modelAtt["addholo"]
			local inf = hg.attachments.sight["optic8"]
			local pos,ang = LocalToWorld(inf.addholovec,inf.addholoang,pos,ang)
			if not IsValid(addholo) then return end
			addholo:SetRenderOrigin(pos)
			addholo:SetRenderAngles(ang)
			addholo:SetModelScale(1.2)
			addholo:SetupBones()

			if IsValid(addholo.model) then
				addholo.model:SetRenderOrigin(pos)
				addholo.model:SetRenderAngles(ang)
				addholo.model:SetModelScale(1.2)
				addholo.model:SetupBones()
			end
		end,
		valid = true,
	},
	["optic9"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/scope/eft_scope_ta01.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0.3, -0.03),
		offsetView = Vector(-1.35, 0, 9),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/eft_reticle_ta01.png"),
		localScopePos = Vector(0, 0, 1.35),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 7,
		FOVMax = 7,
		FOVScoped = 40,
		blackoutsize = 4700,
		sizeperekrestie = 4500,
		perekrestieSize = true,
		stableReticle = true,

		mount = "models/weapons/arc9/darsu_eft/mods/mount_vulcan_gen3.mdl",
		mountVec = Vector(-0.9, 0, -0.3),
		mountAng = Angle(0, -180, 0),

		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic11"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/optic/dovetail/pso1m2.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-2, 0, 0.3),
		offsetView = Vector(-0.8, 0.56, 7.5),
		mountType = "dovetail",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_dovetail_belomo_pso_1m2_1_4x24_marks_0.png"),
		localScopePos = Vector(12, 0.56, 0.8),
		scope_blackout = 1500,
		rot = 0,
		FOVMin = 12,
		FOVMax = 12,
		FOVScoped = 40,
		blackoutsize = 4200,
		sizeperekrestie = 2000,
		stableReticle = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),


		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic12"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/scope_eotech_vudu.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(2.5, 0.2, 0),
		offsetView = Vector(0, 0, 14),
		mountType = "kar98mount",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_25_4mm_vomz_pilad_4x32m_mark.png"),
		localScopePos = Vector(-0, 0, 0),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 8,
		FOVMax = 8,
		FOVScoped = 40,
		blackoutsize = 3500,
		sizeperekrestie = 5000,
		perekrestieSize = false,
		stableReticle = true,

		mount = "models/weapons/arc9_eft_shared/atts/mounts/mount_dovetail_sag_bit_bracket.mdl",
		mountVec = Vector(-2, 1, -1.5),
		mountAng = Angle(15, 90, 0),

		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
		end,

		viewFunction = function(self,model,pos)
			do return pos end

			if self:KeyDown(IN_ATTACK2) then
				if (IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_JUMP)) or (!IsValid(self:GetOwner().FakeRagdoll) and self:KeyDown(IN_USE)) then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_"..(self.viewmode1 and "in" or "out").."_0"..math.random(4)..".wav",35,math.random(95,105))
					end
				else
					self.keypr = false
				end
			end

			local ang = model:GetAngles()

			if self.viewmode1 then
				self.upview = Lerp(FrameTime()*7, self.upview or 0, -0.97)
			else
				self.upview = Lerp(FrameTime()*4, self.upview or 0, 0)
			end

			pos = pos + ang:Up() * self.upview

			return pos
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
		valid = true,
	},
	["optic13"] = {
		"sight",
		"models/escape from tarkov/static/weapons/npz pag-17.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		offsetView = Vector(-25.5,3.1,9),
		mountType = "agsmount",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_base_kmz_1p59_3_10x_mark_3x.png"),
		localScopePos = Vector(0,3.1,25.5),
		scope_blackout = 2200,
		rot = 0,
		FOVMin = 9,
		FOVMax = 9,
		FOVScoped = 40,
		blackoutsize = 2200,
		sizeperekrestie = 6000,
		perekrestieSize = true,
		stableReticle = true,

		drawFunction = function(self,model) -- in swep:drawattachment
			if not model.submated then
				model:SetSubMaterial(1,"effects/arc9/rt")
				model.submated = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["optic14"] = {
		"sight",
		"models/weapons/mods/scope_elcan_specter.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.25, -0.04),
		offsetView = Vector(-1.65, 0, 8),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_elcan_specter_dr_marks.png"),
		localScopePos = Vector(7, 0, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 16,
		FOVMax = 26,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 4500,
		perekrestieSize = false,
		stableReticle = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(2,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["optic15"] = {
		"sight",
		"models/weapons/mods/optic_reapir.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0, -0.04),
		offsetView = Vector(-1.65, 0, 7),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/reap_ir_reticle.png"),
		localScopePos = Vector(14, 0, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 10,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 4000,
		sizeperekrestie = 1650,
		perekrestieSize = false,
		stableReticle = true,
		thermal = true,
		mount = "models/weapons/mods/mount_reapir.mdl",
		mountVec = Vector(-0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(2,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["holo18"] = {
		"sight",
		"models/weapons/mods/scope_elcan_specter_hco.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.75, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_elcan_specter_hco_lod0_mark.png"),
		holo_size = CLIENT and ScreenScale(0.45) or 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo19"] = {
		"sight",
		"models/weapons/mods/scope_all_vortex_razor_amg_uh-1.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, 0.01),
		offsetView = Vector(-1.75, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_vortex_razor_amg_uh-1_marks.png"),
		holo_size = CLIENT and ScreenScale(0.35) or 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["holo_boss"] = {
		"sight",
		"models/weapons/mods/scope_wilcox_boss.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.8, 0, 9),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",

		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_all_wilcox_boss_xe_hp_mark_001.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["optic16"] = {
		"sight",
		"models/weapons/mods/scope_monstrum_compact_prism.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 0, -0.02),
		offsetView = Vector(-1.5, 0, 9),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_monstrum_compact_prism_scope_2x32_mark_1.png"),
		localScopePos = Vector(7, 0, 1.45),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 10,
		FOVMax = 10,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 3000,
		perekrestieSize = false,
		stableReticle = true,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(2,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["optic17"] = {
		"sight",
		"models/weapons/mods/scope_armasight_zeus_pro.mdl",
		Angle(0, 0, -90),
		offset = Vector(1, -0.0, -0),
		offsetView = Vector(-2, 0, 10),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_base_armasight_zeus_pro_640_2_16x50_30hz_lod0_mark_00.png"),
		localScopePos = Vector(50, -0.04, 2),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 3,
		FOVMax = 20,
		FOVScoped = 40,
		blackoutsize = 5000,
		sizeperekrestie = 2100,
		perekrestieSize = true,
		stableReticle = true,
		thermal = true,
		mount = "models/weapons/mods/mount_zeus_pro.mdl",
		mountVec = Vector(-1.5, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(3,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self,model,vecadd,ang) -- in transformfunction
		end,
	},
	["optic18"] = {
		"sight",
		"models/weapons/mods/scope_sig_sauer_echo1.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, -0.25, -0.05),
		offsetView = Vector(-2, 0, 10),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_all_sig_sauer_echo1_thermal_reflex_sight_1_2x_30hz_lod0_mark_00.png"),
		localScopePos = Vector(120, -0.5, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 12,
		FOVMax = 20,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 4000,
		perekrestieSize = false,
		stableReticle = true,
		thermal = true,
		thermalPalette = "blue_red",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(3,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,
		transformFunction = function(self, model, vecadd, ang)
		end,
		valid = true,
	},
	["optic19"] = {
		"sight",
		"models/weapons/mods/scope_nightforce_atacr.mdl",
		Angle(0, 0, -90),
		offset = Vector(0, 1.3, -0.04),
		offsetView = Vector(-0, 0, 12),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_34mm_nightforce_atacr_7_35x56_marks.png"),
		localScopePos = Vector(0, 0, 0),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 2,
		FOVMax = 22,
		FOVScoped = 55,
		blackoutsize = 4500,
		sizeperekrestie = 4500,
		perekrestieSize = false,
		stableReticle = true,
		mount = "models/weapons/mods/mount_all_jp_enterprises_ftsm.mdl",
		mountVec = Vector(-1, 0, -1.4),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(3,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self, model, vecadd, ang)
		end,
		valid = true,
	},
	["optic21"] = {
		"sight",
		"models/weapons/mods/scope_sb_pm_ii_1_8x24.mdl",
		Angle(0, 0, -90),
		offset = Vector(3, 1.3, -0.04),
		offsetView = Vector(-0, 0, 15),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/adjustable/pm_ii_1-8x24_mark_q.png"),
		localScopePos = Vector(12, 0, 0),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 4,
		FOVMax = 22,
		FOVScoped = 40,
		blackoutsize = 3600,
		sizeperekrestie = 5500,
		perekrestieSize = false,
		stableReticle = true,
		mount = "models/weapons/mods/mount_all_jp_enterprises_ftsm.mdl",
		mountVec = Vector(-2.3, 0, -1.4),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_sig_romeo_4_mark.png"),
		holo_size = CLIENT and ScreenScale(0.8) or 1,
		holomodel = "models/weapons/mods/scope_trijicon_sro.mdl",
		addholovec = Vector(0.9, 0, 1),
		addholoang = Angle(0, 0, 0),
		addholoview = 1.8,

		drawFunction = function(self,model) -- in swep:drawattachment
			model:SetSubMaterial(2,"hg/scope_lens")
			if not IsValid(self) then return end

			local inf = hg.attachments.sight["optic21"]
			self.modelAtt["addholo"] = IsValid(self.modelAtt["addholo"]) and self.modelAtt["addholo"] or ClientsideModel(inf.holomodel)
			local addholo = self.modelAtt["addholo"]
			if not IsValid(addholo) then return end

			addholo:DrawModel()
			addholo:SetNoDraw(model:GetNoDraw())

			local model2 = addholo.model
			if not IsValid(model2) then
				model2 = ClientsideModel(inf.holomodel)
				if not IsValid(model2) then return end

				model2:SetNoDraw(true)
				addholo.model = model2
				self.holomodels = self.holomodels or {}
				local holomodels = self.holomodels
				holomodels[model2] = true

				model:CallOnRemove("removeoptic21holo", function()
					holomodels[model2] = nil
					if IsValid(model2) then model2:Remove() end
				end)
			end

			if not addholo.submat then
				addholo:SetSubMaterial(0,"")
				addholo:SetSubMaterial(1,"null")
				model2:SetSubMaterial(0,"null")
				model2:SetSubMaterial(1,"white")
				addholo.submat = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		viewFunction = function(self, model, pos)
			if self:KeyDown(IN_ATTACK2) then
				local owner = self:GetOwner()
				local switchKey = IsValid(owner.FakeRagdoll) and self:KeyDown(IN_JUMP) or self:KeyDown(IN_USE)
				if switchKey then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_" .. (self.viewmode1 and "in" or "out") .. "_0" .. math.random(4) .. ".wav", 35, math.random(95, 105))
					end
				else
					self.keypr = false
				end
			end

			local inf = hg.attachments.sight["optic21"]
			self.upview = Lerp(FrameTime() * (self.viewmode1 and 12 or 4), self.upview or 0, self.viewmode1 and inf.addholoview or 0)

			return pos + model:GetAngles():Up() * self.upview
		end,

		transformFunction = function(self, model, vecadd, ang)
			if not IsValid(self) then return end

			local inf = hg.attachments.sight["optic21"]
			self.modelAtt["addholo"] = IsValid(self.modelAtt["addholo"]) and self.modelAtt["addholo"] or ClientsideModel(inf.holomodel)
			local addholo = self.modelAtt["addholo"]
			if not IsValid(addholo) then return end

			local pos, holoang = LocalToWorld(inf.addholovec, inf.addholoang, vecadd, ang)
			addholo:SetRenderOrigin(pos)
			addholo:SetRenderAngles(holoang)
			addholo:SetModelScale(1.2)
			addholo:SetupBones()

			if IsValid(addholo.model) then
				addholo.model:SetRenderOrigin(pos)
				addholo.model:SetRenderAngles(holoang)
				addholo.model:SetModelScale(1.2)
				addholo.model:SetupBones()
			end
		end,
		valid = true,
	},
	["optic23"] = {
		"sight",
		"models/weapons/mods/scope_sig_tango6t.mdl",
		Angle(0, 0, -90),
		offset = Vector(3, 1.3, -0.04),
		offsetView = Vector(0, 0, 13),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_30mm_sig_tango6t_1_6x24_lod0_mark_6.png"),
		localScopePos = Vector(12, 0, 0),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 5,
		FOVMax = 22,
		FOVScoped = 40,
		blackoutsize = 3600,
		sizeperekrestie = 4500,
		perekrestieSize = false,
		stableReticle = true,
		mount = "models/weapons/mods/mount_all_jp_enterprises_ftsm.mdl",
		mountVec = Vector(-2.3, 0, -1.4),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_trijicon_rmr_mark.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1,
		holomodel = "models/weapons/mods/scope_swampfox_justice.mdl",
		addholovec = Vector(0.9, 0, 1),
		addholoang = Angle(0, 0, 0),
		addholoview = 1.7,

		drawFunction = function(self, model)
			model:SetSubMaterial(2, "hg/scope_lens")
			if not IsValid(self) then return end

			local inf = hg.attachments.sight["optic23"]
			self.modelAtt["addholo23"] = IsValid(self.modelAtt["addholo23"]) and self.modelAtt["addholo23"] or ClientsideModel(inf.holomodel)
			local addholo = self.modelAtt["addholo23"]
			if not IsValid(addholo) then return end

			addholo:DrawModel()
			addholo:SetNoDraw(model:GetNoDraw())

			local model2 = addholo.model
			if not IsValid(model2) then
				model2 = ClientsideModel(inf.holomodel)
				if not IsValid(model2) then return end

				model2:SetNoDraw(true)
				addholo.model = model2
				self.holomodels = self.holomodels or {}
				local holomodels = self.holomodels
				holomodels[model2] = true

				model:CallOnRemove("removeoptic23holo", function()
					holomodels[model2] = nil
					if IsValid(model2) then model2:Remove() end
				end)
			end

			if not addholo.submat then
				addholo:SetSubMaterial(0, "")
				addholo:SetSubMaterial(1, "null")
				model2:SetSubMaterial(0, "null")
				model2:SetSubMaterial(1, "white")
				addholo.submat = true
			end
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		viewFunction = function(self, model, pos)
			if self:KeyDown(IN_ATTACK2) then
				local owner = self:GetOwner()
				local switchKey = IsValid(owner.FakeRagdoll) and self:KeyDown(IN_JUMP) or self:KeyDown(IN_USE)
				if switchKey then
					if not self.keypr then
						self.viewmode1 = not self.viewmode1
						self.keypr = true
						self:EmitSound("universal/uni_lean_" .. (self.viewmode1 and "in" or "out") .. "_0" .. math.random(4) .. ".wav", 35, math.random(95, 105))
					end
				else
					self.keypr = false
				end
			end

			local inf = hg.attachments.sight["optic23"]
			self.upview = Lerp(FrameTime() * (self.viewmode1 and 12 or 4), self.upview or 0, self.viewmode1 and inf.addholoview or 0)
			return pos + model:GetAngles():Up() * self.upview
		end,

		transformFunction = function(self, model, vecadd, ang)
			if not IsValid(self) then return end

			local inf = hg.attachments.sight["optic23"]
			self.modelAtt["addholo23"] = IsValid(self.modelAtt["addholo23"]) and self.modelAtt["addholo23"] or ClientsideModel(inf.holomodel)
			local addholo = self.modelAtt["addholo23"]
			if not IsValid(addholo) then return end

			local pos, holoang = LocalToWorld(inf.addholovec, inf.addholoang, vecadd, ang)
			addholo:SetRenderOrigin(pos)
			addholo:SetRenderAngles(holoang)
			addholo:SetModelScale(1.2)
			addholo:SetupBones()

			if IsValid(addholo.model) then
				addholo.model:SetRenderOrigin(pos)
				addholo.model:SetRenderAngles(holoang)
				addholo.model:SetModelScale(1.2)
				addholo.model:SetupBones()
			end
		end,
		valid = true,
	},
	["holo21"] = {
		"sight",
		"models/weapons/mods/scope_trijicon_sro.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1.5, 0, -0.05),
		offsetView = Vector(-0.8, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_aimpoint_acro_p1_mark.png"),
		holo_size = CLIENT and ScreenScale(0.3) or 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/mods/mount_all_trijicon_rm33.mdl",
		mountVec = Vector(-0, 0, -0),
		mountAng = Angle(0, 0, 0),
		valid = true,
	},
	["holo22"] = {
		"sight",
		"models/weapons/mods/scope_swampfox_justice.mdl",
		Angle(0, 0, -90),
			offset = Vector(-1.5, -0, -0.05),	
		offsetView = Vector(-0.7, 0, 8),
		{},
		mountType = "picatinny",
		holotex = "models/weapons/arc9_eft_shared/atts/optic/transparent_glass",
		holo = Material("vgui/arc9_eft_shared/reticles/new/scope_base_trijicon_rmr_mark.png"),
		holo_size = CLIENT and ScreenScale(0.4) or 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(0, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/mods/mount_all_trijicon_rm33.mdl",
		mountVec = Vector(-0, 0, -0),
		mountAng = Angle(0, 0, 0),
		valid = true,
	},
	["optic22"] = {
		"sight",
		"models/weapons/mods/scope_vulcan_mg35x.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0.4, -0.05),
		offsetView = Vector(-1.6, 0, 10),
		{},
		mountType = "picatinny",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/scope_base_armasight_vulcan_gen3_bravo_mg_35x_marks.png"),
		localScopePos = Vector(7, 0, 1.6),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 15,
		FOVMax = 15,
		FOVScoped = 40,
		blackoutsize = 4500,
		sizeperekrestie = 3000,
		perekrestieSize = true,
		stableReticle = true,
		nightvision = true,
		nightvisionResolution = {160, 120},
		mount = "models/weapons/mods/mount_zeus_pro.mdl",
		mountVec = Vector(0.7, 0, -0.3),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		drawFunction = function(self,model)
			model:SetSubMaterial(2,"hg/scope_lens")
		end,

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self, model, vecadd, ang)
		end,
		valid = true,
	},
	["optic24"] = {
		"sight",
		"models/weapons/mods/scope_torrey_t12w.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-1, 0.9, 0),
		offsetView = Vector(-1, 0, 10),
		mountType = "pistolmount",
		scopemat = Material("decals/scope.png"),
		mat = Material("effects/arc9/rt"),
		perekrestie = Material("vgui/arc9_eft_shared/reticles/grid.png"),
		localScopePos = Vector(7, 0, 1.65),
		scope_blackout = 1200,
		rot = 0,
		FOVMin = 20,
		FOVMax = 20,
		FOVScoped = 40,
		blackoutsize = 40000,
		sizeperekrestie = 1600,
		perekrestieSize = false,
		stableReticle = true,
		thermal = true,
		thermalPalette = "blue_red",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),

		sightFunction = function(self)
			self:DoRT()
		end,

		transformFunction = function(self, model, vecadd, ang)
		end,
		valid = true,
	},
	["ironsight1"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_mbus.mdl",
		Angle(0, 0, -90),
		offset = Vector(-1, 0, 0),
		offsetView = Vector(-1.4, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/arc9_eft_shared/atts/ironsight/eft_frontsight_mbus.mdl",
		mountVec = Vector(11.5, 0, 0),
		mountAng = Angle(0, 180, 0),
		valid = true,
	},
	["ironsight2"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_a2.mdl",
		Angle(0, 0, -90),
		offset = Vector(-4.3, 0, -0.05),
		offsetView = Vector(-1.39, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["ironsight3"] = {
		"sight",
		"models/weapons/arc9/darsu_eft/mods/fs_a2.mdl",
		Angle(0, 0, -90),
		offset = Vector(8, 0, 0),
		offsetView = Vector(-1.5, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		valid = true,
	},
	["ironsight4"] = {
		"sight",
		"models/weapons/arc9_eft_shared/atts/ironsight/eft_rearsight_mbus.mdl",
		Angle(0, 0, -90),
		offset = Vector(-2.5, 0, 0),
		offsetView = Vector(-1.4, 0, 12),
		{},
		mountType = "ironsight",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(0, 90, 0),
		mount = "models/weapons/arc9_eft_shared/atts/ironsight/eft_frontsight_mbus.mdl",
		mountVec = Vector(10, 0, 0),
		mountAng = Angle(0, 180, 0),
		valid = true,
	},
}

function hg.attachmentFunc(self, attachmentData)
	self.size = attachmentData.size or self.size
	self.holo_pos = attachmentData.holo_pos or self.holo_pos
	self.scale = attachmentData.scale or self.scale
	self.holo = attachmentData.holo or self.holo
	self.holo_size = attachmentData.holo_size or self.holo_size
	self.holo_lum = attachmentData.holo_lum or self.holo_lum
	--self.holo_view = curAtt[4] or self.holo_view
	if attachmentData.perekrestieSize ~= nil then
		self.perekrestieSize = attachmentData.perekrestieSize
	end
	self.mat = attachmentData.mat or self.mat
	self.scopemat = attachmentData.scopemat or self.scopemat
	self.perekrestie = attachmentData.perekrestie or self.perekrestie
	self.localScopePos = attachmentData.localScopePos or self.localScopePos
	self.scope_blackout = attachmentData.scope_blackout or self.scope_blackout
	self.rot = attachmentData.rot or self.rot
	self.FOVMin = attachmentData.FOVMin or self.FOVMin
	self.FOVMax = attachmentData.FOVMax or self.FOVMax
	self.FOVScoped = attachmentData.FOVScoped or self.FOVScoped
	self.blackoutsize = attachmentData.blackoutsize or self.blackoutsize
	self.sizeperekrestie = attachmentData.sizeperekrestie or self.sizeperekrestie
	if attachmentData.thermal ~= nil then
		self.thermal = attachmentData.thermal
	end
	self.nightvision = attachmentData.nightvision or false
end

hg.attachments.mount = {
	["empty"] = {"mount", "", Angle(0, 0, 0), {}},
	["mount1"] = {
		"mount",
		"models/wystan/attachments/akrailmount.mdl",
		Angle(90, -0, -90),
		{
			[0] = "pwb/models/weapons/w_akm/akm"
		}
	},
	["mount2"] = {"mount", "models/weapons/arc9/darsu_eft/mods/mount_all_larue_picatinny_raiser_qd_lt101.mdl", Angle(0, -0, -90), {}},
	["mount3"] = {"mount", "models/weapons/mods/mount_dovetail_caa_xd_rgl.mdl", Angle(0, 0, -0), {}},
	["mount4"] = {"mount", "models/weapons/arc9/darsu_eft/mods/tac_pistol_um3.mdl", Angle(0, 0, 90), {}}
}

hg.attachments.barrel = {
	["empty"] = {"barrel", "", Angle(0, 0, 0), {}},
	["supressor0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"barrel", -- integrated
		"",
		Angle(0, 0, 0),
		{}
	},
	-- 9x19
	["supressor1"] = {
		"barrel", "models/weapons/mods/silencer_all_aac_illusion_9_9x19.mdl",
		Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor2"] = {
		"barrel", "models/weapons/mods/silencer_all_sig_srd_9_9x19.mdl",
		Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- 5.45x39
	["supressor3"] = {
		"barrel", "models/weapons/mods/silencer_ak74_spectehnika_tgpa_545x39.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor4"] = {
		"barrel", "models/weapons/mods/silencer_aks74u_tochmash_pbs-4_545x39.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.4),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- 5.56x45
	["supressor5"] = {
		"barrel", "models/weapons/mods/silencer_socom_surefire_socom556_monster_556x45.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mount = "models/weapons/mods/muzzle_ar15_surefire_sf3p_flash_hider_556x45.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor6"] = {
		"barrel", "models/weapons/mods/silencer_sdqd_griffin_m4sd_k_silencer_556x45.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0.5, 0, 0),
		mount = "models/weapons/mods/muzzle_ar15_griffin_gatelok_hammer_comp_556x45.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- 7.62x39
	["supressor7"] = {
		"barrel", "models/weapons/mods/silencer_akm_tochmash_pbs-1_762x39.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor8"] = {
		"barrel", "models/weapons/mods/silencer_ak_hexagon_dtkp_762x39.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- 7.62x51
	["supressor9"] = {
		"barrel", "models/weapons/mods/silencer_base_sig_srd_762_qd_762x51.mdl",
		Angle(0, 0, 0),
		{},
		modelscale = 1,
		offset = Vector(-1.5,0.1,0),
		mount = "models/weapons/mods/muzzle_all_sig_qd_muzzle_base_762x51.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor16"] = {
		"barrel", "models/weapons/mods/silencer_qdc_kac_prs_qdc_762x51.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mount = "models/weapons/mods/muzzle_ar15_kac_qd_compensator_556x45.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- .338 Lapua
	["supressor11"] = {
		"barrel", "models/weapons/mods/silencer_hekate_dt_338.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- 12/70
	["supressor12"] = {
		"barrel", "models/weapons/mods/silencer_12g_hexagon_12k.mdl",
		Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		mount = "models/weapons/mods/muzzle_12g_silencerco_salvo_adaper_12g.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	["supressor13"] = {
		"barrel", "models/weapons/mods/silencer_base_silencerco_salvo_12g.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		mount = "models/weapons/mods/muzzle_12g_silencerco_salvo_adaper_12g.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},
	-- other
	["supressor14"] = {"barrel", "models/weapons/csgo/atts/silencer_clothwrapped.mdl", Angle(-90, 0, 0), {}, modelscale = 3, offset = Vector(11.5,-0.5,-0.1),},
	["supressor15"] = {
		"barrel", "models/weapons/mods/silencer_wave_dd_wave_qd_supressor_multi.mdl",
		Angle(0, 0, 0),
		{},
		modelscale = 1,
		offset = Vector(-1.5,0.1,0),
		mount = "models/weapons/mods/muzzle_ar15_awc_psr_muzzle_brake_556x45.mdl",
		mountVec = Vector(0, 0, 0),
		mountAng = Angle(0, 0, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0.35),
		PhysAng = Angle(0, 0, 0),
		valid = true,
	},

	-- Standard muzzle devices
	["muzzle_std_545"] = {
		"barrel", "models/weapons/mods/muzzle_ak74_izhmash_ak74m_std_545x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, standard = true,
	},
	["muzzle_std_762x39"] = {
		"barrel", "models/weapons/mods/muzzle_ak_izhmash_akml_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, standard = true,
	},
	["muzzle_std_556"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_colt_usgi_a2_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, standard = true,
	},
	["muzzle_std_762x51"] = {
		"barrel", "models/weapons/mods/muzzle_ar10_cmmg_sv_brake_compensator_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, standard = true,
	},

	-- 5.45x39 muzzle devices
	["muzzle_545_recoil_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak74_jmac_rrd_4c_multi.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, recoilMul = 0.8, ergonomicsMul = 0.9,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_545_recoil_2"] = {
		"barrel", "models/weapons/mods/muzzle_ak_zenit_dtk1_762x39_545x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, recoilMul = 0.84, ergonomicsMul = 0.93,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_545_ergo_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak74_srvv_mbr_jet_545_545x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, recoilMul = 1.08, ergonomicsMul = 1.08,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_545_ergo_2"] = {
		"barrel", "models/weapons/mods/muzzle_ak_hexagon_reactor_muzzle_brake_545x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, recoilMul = 1.12, ergonomicsMul = 1.1,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_545_flash_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak74_arsenal_4_piece_flash_hider_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, ergonomicsMul = 0.92, muzzleFlashMul = 0.25, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_545_flash_2"] = {
		"barrel", "models/weapons/mods/muzzle_ak_srvv_mbrfhmb_762_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["545"] = true }, ergonomicsMul = 0.95, muzzleFlashMul = 0.35, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},

	-- 7.62x39 and .366 TKM muzzle devices
	["muzzle_762x39_recoil_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak_jmac_rrd_4c_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, recoilMul = 0.8, ergonomicsMul = 0.9,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x39_recoil_2"] = {
		"barrel", "models/weapons/mods/muzzle_ak_vector_vr_05t_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, recoilMul = 0.84, ergonomicsMul = 0.93,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x39_ergo_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak_spike_tactical_ak_dynacomp_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, recoilMul = 1.08, ergonomicsMul = 1.08,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x39_ergo_2"] = {
		"barrel", "models/weapons/mods/muzzle_base_lantac_blast_mitigation_device_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, recoilMul = 1.12, ergonomicsMul = 1.1,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x39_flash_1"] = {
		"barrel", "models/weapons/mods/muzzle_ak74_arsenal_4_piece_flash_hider_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, ergonomicsMul = 0.92, muzzleFlashMul = 0.25, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x39_flash_2"] = {
		"barrel", "models/weapons/mods/muzzle_ak_srvv_mbrfhmb_762_762x39.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x39"] = true }, ergonomicsMul = 0.95, muzzleFlashMul = 0.35, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},

	-- 5.56x45 muzzle devices
	["muzzle_556_recoil_1"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_alientech_gubich_muzzle_brake_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, recoilMul = 0.8, ergonomicsMul = 0.9,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_556_recoil_2"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_allen_engineering_spr_brake_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, recoilMul = 0.84, ergonomicsMul = 0.93,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_556_ergo_1"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_nordic_corvette_compensator_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, recoilMul = 1.08, ergonomicsMul = 1.08,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_556_ergo_2"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_bulletec_st_6012_muzzle_brake_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, recoilMul = 1.12, ergonomicsMul = 1.1,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_556_flash_1"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_noveske_kx3_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, ergonomicsMul = 0.92, muzzleFlashMul = 0.25, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_556_flash_2"] = {
		"barrel", "models/weapons/mods/muzzle_ar15_bulletec_st_6012_muzzle_brake_556x45.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["556"] = true }, ergonomicsMul = 0.95, muzzleFlashMul = 0.35, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},

	-- 7.62x51, 7.62x54 and .300 Blackout muzzle devices
	["muzzle_762x51_recoil_1"] = {
		"barrel", "models/weapons/mods/muzzle_ar10_2a_x3_titanium_compensator_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, recoilMul = 0.8, ergonomicsMul = 0.9,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x51_recoil_2"] = {
		"barrel", "models/weapons/mods/muzzle_ar10_fortis_red_brake_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, recoilMul = 0.84, ergonomicsMul = 0.93,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x51_ergo_1"] = {
		"barrel", "models/weapons/mods/muzzle_ar10_odin_works_atlas_7_muzzle_brake_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, recoilMul = 1.08, ergonomicsMul = 1.08,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x51_ergo_2"] = {
		"barrel", "models/weapons/mods/muzzle_ar10_surefire_warden_direct_thread_blast_regulator_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, recoilMul = 1.12, ergonomicsMul = 1.1,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x51_flash_1"] = {
		"barrel", "models/weapons/mods/muzzle_base_lantac_blast_mitigation_device_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, ergonomicsMul = 0.92, muzzleFlashMul = 0.25, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	},
	["muzzle_762x51_flash_2"] = {
		"barrel", "models/weapons/mods/muzzle_sa58_ds_arms_3_prong_trident_flash_hider_762x51.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0), calibers = { ["762x51"] = true }, ergonomicsMul = 0.95, muzzleFlashMul = 0.35, reducedMuzzleEffect = true,
		PhysModel = "models/hunter/plates/plate025.mdl", PhysPos = Vector(1, 0, 0.35), PhysAng = Angle(0, 0, 0), valid = true,
	}
	}

hg.attachments.grip = {
	["grip1"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_rk2.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-16.9, -1.3, -0.15),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-2.3,1.8,-3.2),
		LHandAng = Angle(-20,-15,14),
		arc9LHIK = true,
		hold = "grip_hold",
		valid = true,
	}, -- models/weapons/arc9/darsu_eft/mods/fg_ash12.mdl
	["grip2"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_ash12.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-17, -1.4, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3,1.8,-3.2),
		LHandAng = Angle(-20,-15,14),
		hold = "grip_hold",
		valid = true,
	},
	["grip3"] = {
		"grip",
		"models/weapons/arc9/darsu_eft/mods/fg_afg.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-18, -1.6, 0),
		holdtype = "ar2",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.8,0.5,-1.7),
		LHandAng = Angle(20,0,-15),
		valid = true,
		hold = "grip_hold",
	},
	["grip4"] = {
		"grip", "models/weapons/mods/fg_kac.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-2.4, 2, -3.2),
		LHandAng = Angle(-20, -15, 14),
		hold = "grip_hold",
		valid = true,
	},
	["grip5"] = {
		"grip", "models/weapons/mods/fg_mlok_afg.mdl", Angle(180, 180, 90), {},
		offset = Vector(-18, -1.6, 0),
		holdtype = "ar2",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-2, 1.5, -1.2),
		LHandAng = Angle(0, 0, -15),
		hold = "grip_hold",
		valid = true,
	},
	["grip6"] = {
		"grip", "models/weapons/mods/fg_rvg.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.6, 1.3, -2.5),
		LHandAng = Angle(-0, -0, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip7"] = {
		"grip", "models/weapons/mods/fg_sturmgriff.mdl", Angle(90, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.5, 1.2, -2.8),
		LHandAng = Angle(0, -0, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip8"] = {
		"grip", "models/weapons/mods/fg_cobra.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.8, 1.3, -2.7),
		LHandAng = Angle(0, -0, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip9"] = {
		"grip", "models/weapons/mods/fg_pillau_p2.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "ar2",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.5, 1, -2.3),
		LHandAng = Angle(0, 0, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip11"] = {
		"grip", "models/weapons/mods/fg_osovets_p2.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3, 1, -2.5),
		LHandAng = Angle(0, 00, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip12"] = {
		"grip", "models/weapons/mods/fg_vtacuvg.mdl", Angle(180, 180, 90), {},
		offset = Vector(-17, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.5,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.4, 1, -2.5),
		LHandAng = Angle(0, -0, 0),
		hold = "grip_hold",
		valid = true,
	},
	["grip13"] = {
		"grip", "models/weapons/mods/fg_heracqr.mdl", Angle(180, 180, 90), {},
		offset = Vector(-18, -1.2, 0),
		holdtype = "ar2",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.4, 1, -2),
		LHandAng = Angle(30, 0, -0),
		hold = "grip_hold",
		valid = true,
	},
	["grip14"] = {
		"grip", "models/weapons/mods/fg_b25u.mdl", Angle(180, 180, 90), {},
		offset = Vector(-18, -1.3, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-3.6, 4, -1.5),
		LHandAng = Angle(-5, -10, 50),
		arc9LHIK = true,
		hold = "grip_hold",
		valid = true,
	},
	["grip15"] = {
		"grip", "models/weapons/mods/fg_starkse5.mdl", Angle(180, 180, 90), {},
		offset = Vector(-19, -1.6, 0),
		holdtype = "smg",
		mountType = "picatinny",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(-4.6, 1.5, -2.5),
		LHandAng = Angle(5, 0, -0),
		arc9LHIK = true,
		hold = "grip_hold",
		valid = true,
	},
	["grip_ak740"] = {
		"grip",
		"models/weapons/ins/upgrades/a_standard_ak74.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak74",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
	["grip1_ak740"] = {
		"grip",
		"models/weapons/ins/upgrades/a_woodgrips_ak74.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak74",
		recoilReduction = 0.8,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		bBonemerge = true,
		norenderWhenDrop = true,
		hold = "grip_hold",
	},
	["grip_ak120"] = {
		"grip",
		"models/weapons/zcity/upgrades/a_standard_ak12u.mdl",
		Angle(180, 0, 90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "ak12",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(15,-1.2,-3),
		LHandAng = Angle(20,30,20),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
	["grip_akm0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"grip",
		"models/weapons/upgrades/a_standard_akm.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(0, 0, 0),
		holdtype = "ar2",
		mountType = "akm",
		recoilReduction = 1,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		LHandPos = Vector(0,0,0),
		LHandAng = Angle(0,0,0),
		ShouldtUseLHand = true,
		bBonemerge = true,
		norenderWhenDrop = true,
	},
}

hg.attachments.gp25 = {
	["gp25"] = {
		"gp25",
		"models/weapons/mods/gp25.mdl",
		Angle(0, 0, -90),
		{},
		offset = Vector(-19, 1.1, -0.8),
		offsetView = Vector(-3.2, 2.5, 0),
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		mountType = "ak_gp25",
		restrictatt = "grip",
		arc9LHIK = true,
		ShouldtUseLHand = false,
		valid = true,
		PrintName = "GP-25 Kostyor",
		Icon = "entities/gp25real.png",
	},
}

hg.attachments.underbarrel = {
	["lasertaser0"] = { -- with 0 key attachment can't be seen in menus, removed, etc.
		"underbarrel", -- integrated
		(CLIENT and "models/hunter/plates/plate.mdl") or "",
		Angle(0, -8, 0),
		{
			[0] = "null"
		},
		offset = Vector(-2, 1.9, 0.2),
		offsetPos = Vector(0, -0, 0),
		color = Color(255, 0, 0, 250),
		supportFlashlight = true,
		mat = nil,
		farZ = 300,
		size = 40,
		brightness = 20,
		brightness2 = 0,
		shouldalwaysdraw = true,
	},
	["laser1"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_ncstar_tbl.mdl",
		Angle(180, 180, -180),
		{},
		offset = Vector(-13.8, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		offsetAng = Angle(1, 0, 0),
		mountType = "picatinny_small",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(75, 0, 146, 90),
		shouldalwaysdraw = true,
		valid = true,
	},
	["laser2"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_kleh2.mdl",
		Angle(180, 180, -180),
		{},
		offset = Vector(-13.9, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		offsetAng = Angle(1, 0, 0),
		mountType = "picatinny_small",
		supportFlashlight = true,
		mat = nil,
		farZ = 1600,
		size = 50,
		brightness = 100,
		brightness2 = 0.2,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 90),
		shouldalwaysdraw = true,
		valid = true,
	},
	["laser3"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_baldr_pro.mdl",
		Angle(180, 180,180),
		{},
		offset = Vector(-13.9, 0.2, 1),
		offsetPos = Vector(0, -0, 0.73),
		mountType = "picatinny_small",
		supportFlashlight = true,
		mat = nil,
		farZ = 1600,
		size = 50,
		brightness = 70,
		brightness2 = 0.3,
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(0, 0, 0, 0),
		shouldalwaysdraw = true,
		valid = true,
	},

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
		end models/weapons/upgrades/a_laser_rail.mdl
	--]]

	["laser4"] = {
		"underbarrel",
		"models/weapons/arc9/darsu_eft/mods/tac_anpeq2.mdl",
		Angle(180, 180, 90),
		{},
		offset = Vector(-16.9, 1, -0.05),
		offsetPos = Vector(0, -0.6, 0.6),
		offsetAng = Angle(0.5, 0, 0),
		offsetView = Vector(-1.5,0,0),
		supportFlashlight = true,
		nvgFlashlight = true,
		mat = nil,
		farZ = 15000,
		size = 90,
		brightness = 0.1,
		brightness2 = 0.05,
		mountType = "picatinny",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 90),
		shouldalwaysdraw = true,
		valid = true,
	},

	["laser5"] = {
		"underbarrel",
		"models/weapons/upgrades/a_laser_rail.mdl",
		Angle(180, 180, 0),
		{},
		offset = Vector(-14, 0, 0.8),
		offsetPos = Vector(0, 0, 0),
		offsetAng = Angle(-1, 0, 0),
		mountType = "picatinny_small",
		PhysModel = "models/hunter/plates/plate025.mdl",
		PhysPos = Vector(1, 0, 0),
		PhysAng = Angle(180, 180, 90),
		color = Color(255, 0, 0, 200),
		shouldalwaysdraw = true,
		valid = true,
	},

	["laserrpg0"] = {
		"underbarrel", -- integrated
		(CLIENT and "models/hunter/plates/plate.mdl") or "",
		Angle(0, 0, 0),
		{
			[0] = "null"
		},
		offset = Vector(0, 0, 0),
		offsetPos = Vector(0, 0, 0),
		color = Color(255, 0, 0, 255),
		supportFlashlight = false,
		mat = nil,
		farZ = 300,
		size = 40,
		laserSize = 3,
		brightness = 20,
		brightness2 = 0,
		shouldalwaysdraw = true,
	},
}
hg.attachments.magwell = {
	["mag1"] = {
		"magwell",
		"models/weapons/mods/mag_glock_drum_50.mdl",
		Angle(0, -90, 0),
		{},
		mountType = "glock_mag",
		capacity = 50,
		ammotype = "9x19 mm Parabellum",
		reload = "reload3",
		reload_empty = "reload_empty3_0",
		weaponManagedModel = true,
		valid = true,
	},
	["mag2"] = {
		"magwell",
		"models/weapons/mods/mag_stanag_magpul_pmag_d-60_556x45_60.mdl",
		Angle(0, -90, 0),
		{},
		mountType = "stanag_556_60",
		capacity = 60,
		ammotype = "5.56x45 mm",
		reload = "reload5",
		reload_empty = "reload_empty5",
		weaponManagedModel = true,
		valid = true,
	},
	["mag3"] = {
		"magwell",
		"models/weapons/mods/mag_ak74_izhmash_6l31_545x39_60.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_545_60",
		capacity = 60,
		ammotype = "5.45x39 mm",
		reload = "reload60rnd",
		reload_empty = "reload60rnd_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag4"] = {
		"magwell",
		"models/weapons/mods/mag_ak_izhmash_rpk16_drum_545x39_95.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_545",
		capacity = 95,
		ammotype = "5.45x39 mm",
		reload = "reloadbigdrum",
		reload_empty = "reloadbigdrum_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag5"] = {
		"magwell",
		"models/weapons/mods/mag_ak_x_products_x_47_drum_762x39_50.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_762",
		capacity = 50,
		ammotype = "7.62x39 mm",
		reload = "reloadsmalldrum",
		reload_empty = "reloadsmalldrum_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag6"] = {
		"magwell",
		"models/weapons/mods/mag_ak_molot_rpk_drum_762x39_75.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_762_75",
		capacity = 75,
		ammotype = "7.62x39 mm",
		reload = "reloadbigdrum",
		reload_empty = "reloadbigdrum_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag7"] = {
		"magwell",
		"models/weapons/mods/mag_stanag_beta_c_mag_556x45_100.mdl",
		Angle(0, -90, 0),
		{},
		mountType = "stanag_556_100",
		capacity = 100,
		ammotype = "5.56x45 mm",
		reload = "reload7",
		reload_empty = "reload_empty7_l",
		weaponManagedModel = true,
		valid = true,
	},
	["mag8"] = {
		"magwell",
		"models/weapons/mods/mag_ak74_izhmash_saiga_545_std_545x39_10.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_545_60",
		capacity = 10,
		ammotype = "5.45x39 mm",
		reload = "reload10rnd",
		reload_empty = "reload10rnd_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag9"] = {
		"magwell",
		"models/weapons/mods/mag_ak_custom_sawed_off_762x39_10.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_762",
		capacity = 10,
		ammotype = "7.62x39 mm",
		reload = "reload10rnd",
		reload_empty = "reload10rnd_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag11"] = {
		"magwell",
		"models/weapons/mods/mag_stanag_magpul_pmag_gen_m3_556x45_10.mdl",
		Angle(0, -90, 0),
		{},
		mountType = "stanag_556_60",
		capacity = 10,
		ammotype = "5.56x45 mm",
		reload = "reload6",
		reload_empty = "reload_empty6",
		weaponManagedModel = true,
		valid = true,
	},
	["mag12"] = {
		"magwell",
		"models/weapons/mods/mag_ak74_deltatech_saiga_mk_545_20.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_545_60",
		capacity = 20,
		ammotype = "5.45x39 mm",
		reload = "reload545",
		reload_empty = "reload545_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag13"] = {
		"magwell",
		"models/weapons/mods/mag_ak_magpul_pmag_20_ak_akm_gen_m3_762x39.mdl",
		Angle(0, 0, 0),
		{},
		mountType = "ak_762",
		capacity = 20,
		ammotype = "7.62x39 mm",
		reload = "reload762",
		reload_empty = "reload762_empty",
		weaponManagedModel = true,
		valid = true,
	},
	["mag14"] = {
		"magwell",
		"models/weapons/mods/mag_stanag_magpul_pmag_gen_m3_556x45_20.mdl",
		Angle(0, -90, 0),
		{},
		mountType = "stanag_556_60",
		capacity = 20,
		ammotype = "5.56x45 mm",
		reload = "reload8",
		reload_empty = "reload_empty8",
		weaponManagedModel = true,
		valid = true,
	},
}
hg.attachments.stock = {
	["stock_ar15_dd_enhanced"] = {
		"stock", "models/weapons/mods/stock_ar15_dd_enhanced.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		mountType = "ar15_stock", weaponManagedModel = true, recoilMul = 1.08, ergonomicsMul = 1.1, valid = true,
	},
	["stock_ar15_fab_defense_gl_core_s"] = {
		"stock", "models/weapons/mods/stock_ar15_fab_defense_gl_core_s.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		mountType = "ar15_stock", weaponManagedModel = true, recoilMul = 1.08, ergonomicsMul = 1.1, valid = true,
	},
	["stock_ar15_magpul_moe_sl_k"] = {
		"stock", "models/weapons/mods/stock_ar15_magpul_moe_sl_k.mdl", Angle(0, 0, 0), {},
		offset = Vector(-1, 0, 0),
		mountType = "ar15_stock", weaponManagedModel = true, recoilMul = 0.85, ergonomicsMul = 0.92, valid = true,
	},
	["stock_ar15_magpul_moe_carbine"] = {
		"stock", "models/weapons/mods/stock_ar15_magpul_moe_carbine.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		mountType = "ar15_stock", weaponManagedModel = true, recoilMul = 0.85, ergonomicsMul = 0.92, valid = true,
	},
	["stock_ar15_hk_slim_line"] = {
		"stock", "models/weapons/mods/stock_ar15_hk_slim_line.mdl", Angle(0, 0, 0), {},
		offset = Vector(0, 0, 0),
		mountType = "ar15_stock", weaponManagedModel = true, recoilMul = 0.9, ergonomicsMul = 1.05, standard = true, valid = true,
	},
	["stock_akm_std"] = {
		"stock",
		"models/weapons/mods/ak_stock_ak74_std_wood.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 0.9,
		ergonomicsMul = 1.05,
		standard = true,
		valid = true,
	},
	["stock_ak_zenit_pt3"] = {
		"stock",
		"models/weapons/mods/stock_ak_zenit_pt3.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		stockMountModel = "models/weapons/mods/ak_stock_zenit_pt1_lock.mdl",
		weaponManagedModel = true,
		recoilMul = 0.9,
		ergonomicsMul = 1.05,
		standard = true,
		valid = true,
	},
	["stock_ak74_std"] = {
		"stock",
		"models/weapons/mods/ak_stock_ak74_std_plastic.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 0.9,
		ergonomicsMul = 1.05,
		standard = true,
		valid = true,
	},
	["stock_ak_evo"] = {
		"stock",
		"models/weapons/mods/ak_stock_evo.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 1.08,
		ergonomicsMul = 1.12,
		valid = true,
	},
	["stock_ak_zhukov_s"] = {
		"stock",
		"models/weapons/mods/ak_stock_zhukov_s.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 0.82,
		ergonomicsMul = 0.9,
		valid = true,
	},
	["stock_ak_opfor_aa47"] = {
		"stock",
		"models/weapons/mods/ak_stock_opfor_aa47.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 0.85,
		ergonomicsMul = 0.92,
		valid = true,
	},
	["stock_ak_zenit_pt1"] = {
		"stock",
		"models/weapons/mods/stock_ak_zenit_pt1.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		stockMountModel = "models/weapons/mods/ak_stock_zenit_pt1_lock.mdl",
		weaponManagedModel = true,
		recoilMul = 1.05,
		ergonomicsMul = 1.08,
		valid = true,
	},
	["stock_aks74u_std"] = {
		"stock",
		"models/weapons/mods/ak_stock_aks74u_std.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ak_stock",
		weaponManagedModel = true,
		recoilMul = 0.9,
		ergonomicsMul = 1.05,
		standard = true,
		valid = true,
	},
	["stock_ak12_std"] = {
		"stock",
		"models/weapons/mods/stock_ar15_izhmash_ak12_std.mdl",
		Angle(0, 0, 0),
		{},
		offset = Vector(0, 0, 0),
		mountType = "ar15_stock",
		weaponManagedModel = true,
		recoilMul = 0.9,
		ergonomicsMul = 1.05,
		standard = true,
		valid = true,
	},
}
hg.attachments.agsmag = {
	["agsmag0"] = {
		"agsmag",
		"models/escape from tarkov/static/weapons/magazine.mdl",
		Angle(180, 180, 90),
		{},
		offsetPos = Vector(0, 0, 0),
		capacity = 50,
		ammotype = "Grenade 30x29mm",
	}
}

local suppressorErgonomics = {
	supressor1 = 0.94, supressor2 = 0.93, supressor3 = 0.9, supressor4 = 0.91,
	supressor5 = 0.86, supressor6 = 0.9, supressor7 = 0.87, supressor8 = 0.89,
	supressor9 = 0.86, supressor11 = 0.8, supressor12 = 0.84, supressor13 = 0.78,
	supressor14 = 0.82, supressor15 = 0.84, supressor16 = 0.87,
}
for id, ergonomicsMul in pairs(suppressorErgonomics) do
	local data = hg.attachments.barrel[id]
	if data then
		data.ergonomicsMul = ergonomicsMul
		data.recoilMul = nil
	end
end

for id, data in pairs(hg.attachments.sight) do
	if data.valid then
		if string.StartWith(id, "optic") then
			data.ergonomicsMul = data.thermal and 0.9 or data.nightvision and 0.91 or 0.93
		elseif string.StartWith(id, "holo") then
			data.ergonomicsMul = 0.98
		elseif string.StartWith(id, "ironsight") then
			data.ergonomicsMul = 0.995
		else
			data.ergonomicsMul = 0.97
		end
	end
end

local gripBalance = {
	grip1 = {1.16, 0.8},   -- RK-2
	grip2 = {0.92, 0.86},  -- ASH-12
	grip3 = {1.1, 1.08},   -- AFG
	grip4 = {0.91, 0.86},  -- KAC
	grip5 = {1.12, 1.1},   -- M-LOK AFG
	grip6 = {0.9, 0.84},   -- RVG
	grip7 = {0.88, 0.82},  -- Sturmgriff
	grip8 = {1.08, 1.06},  -- Cobra
	grip9 = {0.92, 0.87},  -- Pillau
	grip11 = {0.9, 0.84},  -- Osovets
	grip12 = {0.93, 0.88}, -- UVG
	grip13 = {1.18, 0.78}, -- Hera CQR
	grip14 = {1.16, 0.76}, -- B-25U
	grip15 = {1.1, 1.07},  -- SE-5
}
for id, balance in pairs(gripBalance) do
	local data = hg.attachments.grip[id]
	if data then
		data.ergonomicsMul = balance[1]
		data.recoilMul = balance[2]
		data.recoilReduction = nil
	end
end

local gp25 = hg.attachments.gp25.gp25
gp25.ergonomicsMul = 0.62
gp25.recoilMul = 0.55

local magazineBalance = {
	mag1 = {0.9, 1.2},  -- 50 rounds
	mag2 = {0.82, 1.32}, -- 60 rounds
	mag3 = {0.82, 1.32}, -- 60 rounds
	mag4 = {0.68, 1.58}, -- 95 rounds
	mag5 = {0.9, 1.2},  -- 50 rounds
	mag6 = {0.75, 1.45}, -- 75 rounds
	mag7 = {0.65, 1.65}, -- 100 rounds
	mag8 = {1.12, 0.8}, -- 10 rounds
	mag9 = {1.12, 0.8}, -- 10 rounds
	mag11 = {1.12, 0.8}, -- 10 rounds
	mag12 = {1.06, 0.9}, -- 20 rounds
	mag13 = {1.06, 0.9}, -- 20 rounds
	mag14 = {1.06, 0.9}, -- 20 rounds
}
for id, balance in pairs(magazineBalance) do
	local data = hg.attachments.magwell[id]
	if data then
		data.ergonomicsMul = balance[1]
		data.reloadTimeMul = balance[2]
	end
end

hg.validattachments = {}
for placement, tbl in pairs(hg.attachments) do
	for att, attTbl in pairs(tbl) do
		if attTbl.valid then
			hg.validattachments[placement] = hg.validattachments[placement] or {}
			hg.validattachments[placement][att] = attTbl
		end
	end
end

local attNames = {
	-- Suppressors
	["stock_ar15_dd_enhanced"] = "Daniel Defense Enhanced stock",
	["stock_ar15_fab_defense_gl_core_s"] = "FAB Defense GL-CORE S stock",
	["stock_ar15_magpul_moe_sl_k"] = "Magpul MOE SL-K stock",
	["stock_ar15_magpul_moe_carbine"] = "Magpul MOE Carbine stock",
	["stock_ar15_hk_slim_line"] = "HK Slim Line stock",
	["stock_akm_std"] = "Стандартный деревянный приклад АКМ",
	["stock_ak_zenit_pt3"] = "Приклад Зенит ПТ-3",
	["stock_ak74_std"] = "Стандартный приклад АК-74",
	["stock_ak_evo"] = "Эргономичный приклад AK-EVO",
	["stock_ak_zhukov_s"] = "Приклад Magpul Zhukov-S",
	["stock_ak_opfor_aa47"] = "Приклад OPFOR AA-47",
	["stock_ak_zenit_pt1"] = "Приклад Зенит ПТ-1",
	["stock_aks74u_std"] = "Стандартный приклад АКС-74У",
	["stock_ak12_std"] = "Стандартный приклад АК-12",
	["supressor1"] = "KAC AAC Illusion 9 9x19",
	["supressor2"] = "SIG SRD-9 9x19",
	["supressor3"] = "Спектехника ТГПА 5.45x39",
	["supressor4"] = "ПБС-4 Точмаш 5.45x39",
	["supressor5"] = "SureFire SOCOM556 Monster 5.56x45",
	["supressor6"] = "Griffin M4SD-K 5.56x45",
	["supressor7"] = "ПБС-1 Точмаш 7.62x39",
	["supressor8"] = "Hexagon ДТКП 7.62x39",
	["supressor9"] = "SIG SRD762-QD 7.62x51",
	["supressor11"] = "Hekate DT .338 Lapua",
	["supressor12"] = "Hexagon 12K 12/70",
	["supressor13"] = "SilencerCo Salvo 12G 12/70",
	["supressor14"] = "Homemade Suppressor",
	["supressor15"] = "SilencerCo Hybrid 46 Multi",
	["supressor16"] = "KAC QDC/PRS 7.62x51",
	["muzzle_std_545"] = "Ижмаш 6П20 0-20 5.45x39",
	["muzzle_std_762x39"] = "Ижмаш АКМЛ 7.62x39",
	["muzzle_std_556"] = "Colt USGI A2 5.56x45",
	["muzzle_std_762x51"] = "CMMG SV 7.62x51",
	["muzzle_545_recoil_1"] = "JMac RRD-4C 5.45x39",
	["muzzle_545_recoil_2"] = "Зенит ДТК-1 5.45x39",
	["muzzle_545_ergo_1"] = "SRVV MBR Jet 5.45x39",
	["muzzle_545_ergo_2"] = "Hexagon Reactor 5.45x39",
	["muzzle_545_flash_1"] = "Arsenal 4-Piece 5.45x39",
	["muzzle_545_flash_2"] = "SRVV MBR FHMB 5.45x39",
	["muzzle_762x39_recoil_1"] = "JMac RRD-4C 7.62x39",
	["muzzle_762x39_recoil_2"] = "Vector VR-05T 7.62x39",
	["muzzle_762x39_ergo_1"] = "Spike Tactical Dynacomp 7.62x39",
	["muzzle_762x39_ergo_2"] = "Lantac BMD 7.62x39",
	["muzzle_762x39_flash_1"] = "Arsenal 4-Piece 7.62x39",
	["muzzle_762x39_flash_2"] = "SRVV MBR FHMB 7.62x39",
	["muzzle_556_recoil_1"] = "AlienTech Gubich 5.56x45",
	["muzzle_556_recoil_2"] = "Allen Engineering SPR 5.56x45",
	["muzzle_556_ergo_1"] = "Nordic Corvette 5.56x45",
	["muzzle_556_ergo_2"] = "Bulletec ST-6012 5.56x45",
	["muzzle_556_flash_1"] = "Noveske KX3 5.56x45",
	["muzzle_556_flash_2"] = "Bulletec ST-6012 Flash 5.56x45",
	["muzzle_762x51_recoil_1"] = "2A X3 Titanium 7.62x51",
	["muzzle_762x51_recoil_2"] = "Fortis RED 7.62x51",
	["muzzle_762x51_ergo_1"] = "Odin Works Atlas-7 7.62x51",
	["muzzle_762x51_ergo_2"] = "SureFire Warden 7.62x51",
	["muzzle_762x51_flash_1"] = "Lantac BMD 7.62x51",
	["muzzle_762x51_flash_2"] = "DS Arms Trident 7.62x51",

	-- Holographic sights
	["holo1"] = "EOTech 552",
	["holo2"] = "KOBRA ЭКП-8-18",
	["holo3"] = "ROMEO8T",
	["holo4"] = "Walther \"MRS\"",
	["holo5"] = "\"ОКП-7\"",
	["holo5fur"] = "\"ОКП-7\" Furry",
	["holo6"] = "\"ОКП-7\" Dovetail",
	["holo6fur"] = "\"ОКП-7\" Dovetail Furry",
	["holo7"] = "BelOMO PK-06",
	["holo8"] = "Holosun \"HS401G5\"",
	["holo9"] = "Leapers \"UTG\"",
	["holo11"] = "Trijicon\"SRS-02\"",
	["holo12"] = "Valday PK-120",
	["holo13"] = "Valday Krechet",
	["holo14"] = "EOTech \"XPS3-0\"",
	["holo15"] = "SIG Sauer \"ROMEO4\"",
	["holo16"] = "Trijicon \"RMR\"",
	["holo17"] = "Aimpoint COMP M2",
	["holo18"] = "Elcan Specter HCO",
	["holo19"] = "Vortex Razor AMG UH-1",
	["holo21"] = "Trijicon SRO",
	["holo22"] = "Swampfox Justice",
	["holo_boss"] = "Wilcox Boss",

	-- Optical sights
	["optic2"] = "Fullfield TAC 30",
	["optic3"] = "Валдай ПС-320 1x/6x",
	["optic4"] = "ПСО-1",
	["optic5"] = "Vortex Razor HD Gen.2 1-6x24",
	["optic6"] = "Leupold Mark 4 LR 6.5-20x50",
	["optic7"] = "SIG Sauer \"BRAVO4 4X30\"",
	["optic8"] = "Leupold \"Mark 4 HAMR 4x24mm DeltaPoint\"",
	["optic9"] = "Trijicon \"ACOG TA01NSN 4x32\"",
	["optic11"] = "ПСО-1М2",
	["optic12"] = "Sight for kar98k",
	["optic13"] = "PAG-17 optical sight",
	["optic14"] = "Elcan SpecterDR 1x/4x",
	["optic15"] = "REAP-IR thermal scope",
	["optic16"] = "Monstrum Compact Prism",
	["optic17"] = "Armasight Zeus Pro 640 2-16x50 Thermal",
	["optic18"] = "SIG Sauer ECHO1 1-2x Thermal Reflex Sight",
	["optic19"] = "Nightforce ATACR 7-35x56",
	["optic21"] = "Schmidt & Bender PM II 1-8x24",
	["optic22"] = "Armasight Vulcan MG35x NV",
	["optic23"] = "SIG Sauer TANGO6T 1-6x24",
	["optic24"] = "Torrey Pines Logic T12W Thermal Reflex Sight",

	-- Iron sights
	["ironsight1"] = "MBUS backiron and foreiron",
	["ironsight2"] = "M4A1 Iron Sights",
	["ironsight3"] = "M4A1 Foreiron",

	-- Lasers
	["laser1"] = "TBL Blue Laser",
	["laser2"] = "Klesch Laser + Flashlight",
	["laser3"] = "Olight \"Baldr Pro\"",
	["laser4"] = "TAC ANPEQ2",
	["laser5"] = "AccuBow Laser",

	-- Grips
	["grip1"] = "RK-2",
	["grip2"] = "ASh-12 Vertical Grip",
	["grip3"] = "Magpul AFG Tactical Grip",
	["grip4"] = "KAC Vertical Grip",
	["grip5"] = "Magpul M-LOK AFG",
	["grip6"] = "Magpul RVG",
	["grip7"] = "Sturmgriff Vertical Grip",
	["grip8"] = "Strike Industries Cobra",
	["grip9"] = "Pillau P-2",
	["grip11"] = "Osovets P-2",
	["grip12"] = "VTCA Uvg",
	["grip13"] = "HERA CQR Front Grip",
	["grip14"] = "Zenit B-25U",
	["grip15"] = "Stark SE-5",
	["grip_ak74"] = "Standart Handle AK-74",
	["grip1_ak74"] = "Grip Handle AK-74",
	["gp25"] = "GP-25 Kostyor",

	-- Magazines
	["mag1"] = "Glock 9x19 50-round drum",
	["mag2"] = "Magpul PMAG D-60 5.56x45 60-round drum",
	["mag3"] = "Izhmash 6L31 5.45x39 60-round magazine",
	["mag4"] = "Izhmash RPK-16 5.45x39 95-round drum",
	["mag5"] = "X Products X-47 7.62x39 50-round drum",
	["mag6"] = "Molot RPK 7.62x39 75-round drum",
	["mag7"] = "Beta C-Mag 5.56x45 100-round drum",
	["mag8"] = "Izhmash Saiga 5.45x39 10-round magazine",
	["mag9"] = "Custom AK 7.62x39 10-round magazine",
	["mag11"] = "Magpul PMAG Gen M3 5.56x45 10-round magazine",
	["mag12"] = "Delta-Tech Saiga MK 5.45x39 20-round magazine",
	["mag13"] = "Magpul PMAG AK/AKM Gen M3 7.62x39 20-round magazine",
	["mag14"] = "Magpul PMAG Gen M3 5.56x45 20-round magazine",
}

local attachmentsIcons = {
	-- Suppressors
	-- 9x19
	["supressor1"] = "entities/eft_attachments/muzzles/illusion.png",
	["supressor2"] = "entities/eft_attachments/muzzles/srd9.png",
	-- 5.45x39
	["supressor3"] = "entities/eft_ak_attachments/muzzle/tgpa.png",
	["supressor4"] = "entities/eft_ak_attachments/muzzle/pbs4.png",
	-- 5.56x45
	["supressor5"] = "entities/eft_ar15_attachments/muzzle/surefire_socom556monster_556x45_sound_suppressor.png",
	["supressor6"] = "entities/eft_ar15_attachments/muzzle/ar15_griffin_armament_m4sdk_556x45_sound_suppressor.png",
	-- 7.62x39
	["supressor7"] = "entities/eft_ak_attachments/muzzle/pbs1.png",
	["supressor8"] = "entities/eft_ak_attachments/muzzle/hexa.png",
	-- 7.62x51
	["supressor9"] = "entities/eft_ar10_attachments/srdqd.png",
	["supressor16"] = "entities/eft_ar10_attachments/prsqdc.png",
	-- .338
	["supressor11"] = "entities/eft_axmc_attachments/cgs_hekate_dt_338_lm_sound_suppressor.png",
	-- 12/70
	["supressor12"] = "entities/eft_attachments/muzzles/hexa12k.png",
	["supressor13"] = "entities/eft_attachments/muzzles/salvo12.png",
	-- other
	["supressor14"] = "scrappers/homemadesuppressor.png",
	["supressor15"] = "entities/eft_attachments/muzzles/hybridslinecer.png",

	-- Muzzle devices
	["muzzle_std_545"] = "entities/eft_ak_attachments/muzzle/74.png",
	["muzzle_std_762x39"] = "entities/eft_ak_attachments/muzzle/akml.png",
	["muzzle_std_556"] = "entities/eft_ar15_attachments/muzzle/ar15_colt_usgi_a2_556x45_flash_hider.png",
	["muzzle_std_762x51"] = "entities/eft_ar10_attachments/cmmgbrake.png",
	["muzzle_545_recoil_1"] = "entities/eft_ak_attachments/muzzle/rrd4c.png",
	["muzzle_545_recoil_2"] = "entities/eft_ak_attachments/muzzle/dtk1.png",
	["muzzle_545_ergo_1"] = "entities/eft_ak_attachments/muzzle/srvvakm.png",
	["muzzle_545_ergo_2"] = "entities/eft_ak_attachments/muzzle/reactor.png",
	["muzzle_545_flash_1"] = "entities/eft_ar15_attachments/muzzle/ar15_noveske_kx3_556x45_flash_hider.png",
	["muzzle_545_flash_2"] = "entities/eft_ak_attachments/muzzle/srvv.png",
	["muzzle_762x39_recoil_1"] = "entities/eft_ak_attachments/muzzle/rrd4c.png",
	["muzzle_762x39_recoil_2"] = "entities/eft_ak_attachments/muzzle/vr.png",
	["muzzle_762x39_ergo_1"] = "entities/eft_ak_attachments/muzzle/dynacomp.png",
	["muzzle_762x39_ergo_2"] = "entities/eft_ar10_attachments/bmd762.png",
	["muzzle_762x39_flash_1"] = "entities/eft_ar15_attachments/muzzle/ar15_noveske_kx3_556x45_flash_hider.png",
	["muzzle_762x39_flash_2"] = "entities/eft_ak_attachments/muzzle/srvvakm.png",
	["muzzle_556_recoil_1"] = "entities/eft_ar15_attachments/muzzle/alien.png",
	["muzzle_556_recoil_2"] = "entities/eft_ar15_attachments/muzzle/ar15_thunder_beast_arms_223cb_556x45_muzzle_brake.png",
	["muzzle_556_ergo_1"] = "entities/eft_ar15_attachments/muzzle/ar15_nordic_components_corvette_556x45_compensator.png",
	["muzzle_556_ergo_2"] = "entities/eft_ar15_attachments/muzzle/ar15_bulletec_st6012_556x45_muzzle_brake.png",
	["muzzle_556_flash_1"] = "entities/eft_ar15_attachments/muzzle/ar15_noveske_kx3_556x45_flash_hider.png",
	["muzzle_556_flash_2"] = "entities/eft_ar15_attachments/muzzle/ar15_bulletec_st6012_556x45_muzzle_brake.png",
	["muzzle_762x51_recoil_1"] = "entities/eft_ar10_attachments/x3.png",
	["muzzle_762x51_recoil_2"] = "entities/eft_ar10_attachments/fortis.png",
	["muzzle_762x51_ergo_1"] = "entities/eft_ar10_attachments/atlas.png",
	["muzzle_762x51_ergo_2"] = "entities/eft_ar10_attachments/dgn762b.png",
	["muzzle_762x51_flash_1"] = "entities/eft_ar10_attachments/bmd762.png",
	["muzzle_762x51_flash_2"] = "entities/eft_ar10_attachments/war.png",

	-- Holographic sights
	["holo1"] = "entities/553.png",
	["holo2"] = "entities/cobra1.png",
	["holo3"] = "entities/eft_attachments/scopes/romeo8t.png",
	["holo4"] = "entities/eft_attachments/scopes/mrs.png",
	["holo5"] = "entities/eft_attachments/scopes/okp7.png",
	["holo5fur"] = "entities/eft_attachments/scopes/okp7.png",
	["holo6"] = "entities/eft_attachments/scopes/s_okp.png",
	["holo6fur"] = "entities/eft_attachments/scopes/s_okp.png",
	["holo7"] = "entities/eft_attachments/scopes/pk06.png",
	["holo8"] = "entities/eft_attachments/scopes/hs401g5.png",
	["holo9"] = "entities/eft_attachments/scopes/utg.png",
	["holo11"] = "entities/eft_attachments/scopes/srs02.png",
	["holo12"] = "entities/eft_attachments/scopes/pk120.png",
	["holo13"] = "entities/eft_attachments/scopes/krechet.png",
	["holo14"] = "entities/eft_attachments/scopes/xps3.png",
	["holo15"] = "entities/eft_attachments/scopes/romeo4.png",
	["holo16"] = "entities/eft_attachments/scopes/rmr.png",
	["holo17"] = "entities/eft_attachments/scopes/compm4.png",
	["holo18"] = "entities/hco.png",
	["holo19"] = "entities/uh1.png",
	["holo21"] = "entities/SRO.png",
	["holo22"] = "entities/Justice.png",
	["holo_boss"] = "entities/boss.png",

	-- Optical sights
	["optic2"] = "entities/eft_attachments/scopes/30mmtac30.png",
	["optic3"] = "entities/eft_attachments/scopes/ps320.png",
	["optic4"] = "entities/eft_attachments/scopes/s_pso1m2.png",
	["optic5"] = "entities/eft_attachments/scopes/30mmrazor.png",
	["optic6"] = "entities/eft_attachments/scopes/30mmmark4.png",
	["optic7"] = "entities/eft_attachments/scopes/bravo4.png",
	["optic8"] = "entities/eft_attachments/scopes/hamr.png",
	["optic9"] = "entities/eft_attachments/scopes/ta01nsn.png",
	["optic11"] = "entities/eft_attachments/scopes/s_pso1m2.png",
	["optic12"] = "entities/eft_attachments/scopes/30mmvudu.png",
	["optic13"] = "entities/ent_jack_gmod_ezarmor_pvs14nvm.png",
	["optic14"] = "entities/spectrdrtan.png",
	["optic15"] = "entities/reapir.png",
	["optic16"] = "entities/compact25.png",
	["optic17"] = "entities/zeus.png",
	["optic18"] = "entities/echo.png",
	["optic19"] = "entities/30mmmarch.png",
	["optic21"] = "entities/34mpmii312x50.png",
	["optic22"] = "entities/vulcan.png",
	["optic23"] = "entities/tango.png",
	["optic24"] = "entities/t12w.png",

	-- Iron sights
	["ironsight1"] = "entities/eft_attachments/ironsights/mbus.png",

	-- Lasers
	["laser1"] = "entities/eft_attachments/tactical/tbl.png",
	["laser2"] = "entities/eft_attachments/tactical/k2iks.png",
	["laser3"] = "entities/eft_attachments/tactical/baldr.png",
	["laser4"] = "vgui/icons/laser_long",
	["laser5"] = "entities/laser.png",

	-- Grips
	["grip1"] = "entities/rk1.png",
	["grip2"] = "entities/ash12.png",
	["grip3"] = "entities/afg.png",
	["grip4"] = "entities/kac.png",
	["grip5"] = "entities/mlokafg.png",
	["grip6"] = "entities/rvg.png",
	["grip7"] = "entities/sturm.png",
	["grip8"] = "entities/cobra.png",
	["grip9"] = "entities/pillau2.png",
	["grip11"] = "entities/oso.png",
	["grip12"] = "entities/uvg.png",
	["grip13"] = "entities/cqr.png",
	["grip14"] = "entities/b25u.png",
	["grip15"] = "entities/se5.png",

	-- Magazines
	["mag1"] = "entities/drum.png",
	["mag2"] = "entities/556x45_magpul_pmag_d60_stanag_60round_magazine.png",
	["mag3"] = "entities/5456l31.png",
	["mag4"] = "entities/545drum.png",
	["mag5"] = "entities/762x47.png",
	["mag6"] = "entities/762molot75.png",
	["mag7"] = "entities/balls.png",
	["mag8"] = "entities/545saiga.png",
	["mag9"] = "entities/76210rnd.png",
	["mag11"] = "entities/556x45_magpul_pmag_10_gen_m3_stanag_10round_magazine.png",
	["mag12"] = "entities/saiga20.png",
	["mag13"] = "entities/pmag20.png",
	["mag14"] = "entities/556x45_magpul_pmag_20_gen_m3_stanag_20round_magazine.png",
	["gp25"] = "entities/gp25real.png",
	["stock_ar15_dd_enhanced"] = "entities/dde.png",
	["stock_ar15_fab_defense_gl_core_s"] = "entities/glr.png",
	["stock_ar15_magpul_moe_sl_k"] = "entities/slk.png",
	["stock_ar15_magpul_moe_carbine"] = "entities/moe.png",
	["stock_ar15_hk_slim_line"] = "entities/slim.png",
	["stock_ak_evo"] = "entities/evo.png",
	["stock_ak_zhukov_s"] = "entities/zhu.png",
	["stock_ak_opfor_aa47"] = "entities/aa47.png",
	["stock_ak_zenit_pt1"] = "entities/pt1.png",
	["stock_akm_std"] = "entities/akmstock.png",
	["stock_ak_zenit_pt3"] = "entities/pt3.png",
	["stock_aks74u_std"] = "entities/aksu.png",
	["stock_ak12_std"] = "entities/ak12.png",
	["stock_ak74_std"] = "entities/74plum.png",
}

local attCategoryNames = {
	["sight"] = "Sights",
	["barrel"] = "Muzzles",
	["underbarrel"] = "Underbarrel",
	["magwell"] = "Magwells",
	["stock"] = "Stocks",
	["mount"] = "Mounts",
	["grip"] = "Grips"
}
hg.attachmentslaunguage = attNames
hg.attachmentsIcons = attachmentsIcons
local function initAttachments()
	for possibleAtt, attachments in pairs(hg.attachments) do
		for attachment, attData in pairs(attachments) do
			if CLIENT then language.Add(attachment, attNames[attachment] or attachment) end
			local att = {}
			att.Base = "attachment_base"
			att.PrintName = CLIENT and language.GetPhrase(attachment) or attachment
			att.name = attachment
			att.Category = "ZCity Attachments " .. (attCategoryNames[possibleAtt] or "")
			att.Spawnable = not (string.find(attachment, "0") or string.find(attachment, "empty") or string.find(attachment, "mount"))
			att.Model = attData[2]
			att.WorldModel = attData[2]
			att.SubMats = attData[4]
			att.attachment = attData
			att.PhysModel = attData.PhysModel or nil
			att.PhysPos = attData.PhysPos or nil
			att.PhysAng = attData.PhysAng or nil
			att.IconOverride = attachmentsIcons[attachment]
			scripted_ents.Register(att, "ent_att_" .. attachment)
		end
	end
end

function hg.GetAttachmentTab(att)
	local found

	for ia,attPos in pairs(hg.attachments) do
		for i,fatt in pairs(attPos) do
			if i == att then found = ia end
		end
	end

	return found
end

function hg.GiveAttachment(ply,att)
	local att = string.Replace(att,"ent_att_","")
	local inv = ply:GetNetVar("Inventory",{})

	inv["Attachments"] = inv["Attachments"] or {}

	--if not table.HasValue(inv["Attachments"],att) then
	inv["Attachments"][#inv["Attachments"] + 1] = att

	ply:SetNetVar("Inventory",inv)
	--end
end

function hg.NotValidAtt(att)
	local att = isstring(att) and att or istable(att) and isstring(att[1]) and att[1]
	
	if att then
		local att = string.Replace(att,"ent_att_","")

		local valid = false
		for atta, tbl in pairs(hg.validattachments) do
			if tbl[att] and tbl[att].valid then
				valid = true
			end
		end
		
		return not valid
	end

	return true
end

function hg.IsValidAtt(att)
	return not hg.NotValidAtt(att)
end

initAttachments()
hook.Add("Initialize", "init-atts", initAttachments)
