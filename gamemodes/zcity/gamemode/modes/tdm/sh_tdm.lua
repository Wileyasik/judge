local MODE = MODE

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.HMCD_TDM_CT = zb.Points.HMCD_TDM_CT or {}
zb.Points.HMCD_TDM_CT.Color = Color(0,0,150)
zb.Points.HMCD_TDM_CT.Name = "HMCD_TDM_CT"

zb.Points.HMCD_TDM_T = zb.Points.HMCD_TDM_T or {}
zb.Points.HMCD_TDM_T.Color = Color(150,95,0)
zb.Points.HMCD_TDM_T.Name = "HMCD_TDM_T"

MODE.PrintName = "Arena"
MODE.start_time = 25

ARENA_ROUND_OPTIONS = {
	[1] = {rounds = 1, name = "1 ROUND", description = "One decisive Arena round."},
	[2] = {rounds = 2, name = "2 ROUNDS", description = "A short two-round Arena series."},
	[3] = {rounds = 3, name = "3 ROUNDS", description = "A full three-round Arena series."},
}

MODE.ArenaMaxWeight = 60
MODE.ArenaAttachmentWeight = 1
MODE.ArenaAttachmentWeights = {
	ironsight1 = 0, ironsight2 = 0,
	optic2 = 3, optic4 = 2, optic5 = 3, optic7 = 2, optic8 = 3, optic11 = 2, optic12 = 2, optic24 = 5,
	supressor1 = 2, supressor2 = 2, supressor3 = 2, supressor4 = 2, supressor5 = 2, supressor6 = 2,
	supressor7 = 2, supressor8 = 2, supressor9 = 2, supressor11 = 2, supressor12 = 2,
	supressor13 = 2, supressor15 = 2, supressor16 = 2,
	optic3 = 3, optic6 = 4, optic9 = 2, optic14 = 3, optic15 = 5, optic16 = 2,
	optic17 = 6, optic18 = 5, optic19 = 5, optic21 = 4, optic22 = 5, optic23 = 3,
	laser2 = 2, laser3 = 2,
	grip1 = 2, grip2 = 2, grip4 = 2,
	grip3 = 1, grip5 = 1, grip6 = 2, grip7 = 2, grip8 = 1, grip9 = 2,
	grip11 = 2, grip12 = 2, grip13 = 3, grip14 = 3, grip15 = 1,
	mag1 = 3, mag2 = 4, mag3 = 3, mag4 = 6, mag5 = 3, mag6 = 5, mag7 = 6,
	mag8 = -2, mag9 = -2, mag11 = -2,
	stock_akm_std = 0, stock_ak74_std = 0, stock_ak74_plum = 0, stock_ak_zenit_pt3 = 0,
	stock_ak_evo = 1, stock_ak_zhukov_s = 2,
	stock_ar15_ak12_std = 0, stock_ar15_hk_slim_line = 0,
	stock_ar15_dd_enhanced = 1, stock_ar15_fab_defense_gl_core_s = 1,
	stock_ar15_magpul_moe_sl_k = 1, stock_ar15_magpul_moe_carbine = 1,
}

function MODE:GetArenaAttachmentWeight(attachmentId)
	if string.StartWith(attachmentId, "supressor") then return 2 end
	return self.ArenaAttachmentWeights[attachmentId] or self.ArenaAttachmentWeight
end
MODE.ArenaWeapons = {
	weapon_akm = {name = "AKM", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor7", "supressor8", "supressor15", "holo6", "holo6fur", "optic4", "optic11", "mag5", "mag6", "mag9", "stock_akm_std", "stock_ak_zenit_pt3", "stock_ak_evo", "stock_ak_zhukov_s"}},
	weapon_ak74 = {name = "AK-74", category = "Assault Rifles", slot = "primary", weight = 9, clips = 3, attachments = {"supressor3", "supressor4", "supressor15", "holo6", "holo6fur", "optic4", "optic11", "mag3", "mag4", "mag8", "stock_ak74_std", "stock_ak_zenit_pt3", "stock_ak_evo", "stock_ak74_plum"}},
	weapon_m4a1 = {name = "M4A1", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "holo1", "holo2", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "ironsight1", "ironsight2", "mag2", "mag7", "mag11"}},
	weapon_mp5 = {name = "MP5", category = "SMGs", slot = "primary", weight = 7, clips = 4, attachments = {"supressor2", "supressor1", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8"}},
	weapon_mp7 = {name = "MP7", category = "SMGs", slot = "primary", weight = 8, clips = 4, attachments = {"supressor2", "supressor1", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8", "laser1", "laser2", "laser3", "laser5"}},
	weapon_uzi = {name = "Uzi", category = "SMGs", slot = "primary", weight = 6, clips = 4, attachments = {"supressor2", "supressor1", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5"}},
	weapon_vector = {name = "KRISS Vector", category = "SMGs", slot = "primary", weight = 8, clips = 4, attachments = {"supressor2", "supressor1", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8", "mag1"}},
	weapon_p90 = {name = "FN P90", category = "SMGs", slot = "primary", weight = 8, clips = 4, attachments = {"supressor2", "supressor1", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8"}},
	weapon_skorpion = {name = "Skorpion vz. 61", category = "SMGs", slot = "primary", weight = 5, clips = 4, attachments = {}},
	weapon_scorpion = {name = "CZ Scorpion EVO 3", category = "SMGs", slot = "primary", weight = 8, clips = 3, attachments = {"supressor1", "supressor2"}},
	weapon_stm9 = {name = "STM-9", category = "SMGs", slot = "primary", weight = 6, clips = 4, attachments = {"supressor1", "supressor2", "supressor15"}},
	weapon_hk416 = {name = "HK416", category = "Assault Rifles", slot = "primary", weight = 11, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "holo1", "holo2", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5", "laser1", "laser2", "laser3", "laser5", "mag2", "mag7", "mag11"}},
	weapon_ak12 = {name = "AK-12", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor3", "supressor4", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5", "laser1", "laser2", "laser3", "laser5", "mag3", "mag4", "mag8", "mag12"}},
	weapon_m4a1mod3 = {name = "M4A1 Mod3", category = "Assault Rifles", slot = "primary", weight = 11, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "mag2", "mag7", "mag11", "mag14"}},
	weapon_mcx = {name = "SIG MCX", category = "Assault Rifles", slot = "primary", weight = 11, clips = 3, attachments = {"supressor9", "supressor16", "supressor15", "mag2", "mag11", "mag14"}},
	weapon_spear = {name = "SIG MCX SPEAR", category = "Assault Rifles", slot = "primary", weight = 13, clips = 3, attachments = {"supressor9", "supressor16", "supressor15"}},
	weapon_sa58fal = {name = "SA58 FAL", category = "Assault Rifles", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15"}},
	weapon_asval_mod4 = {name = "AS VAL MOD4", category = "Assault Rifles", slot = "primary", weight = 11, clips = 4, attachments = {}},
	weapon_ash12 = {name = "ASH-12", category = "Assault Rifles", slot = "primary", weight = 14, clips = 3, attachments = {}},
	weapon_mk47 = {name = "CMMG Mk47 Mutant", category = "Assault Rifles", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15", "mag6"}},
	weapon_nl545 = {name = "CGNL 545", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "mag3", "mag4", "mag8", "mag12"}},
	weapon_mdr = {name = "Desert Tech MDR", category = "Assault Rifles", slot = "primary", weight = 11, clips = 3, attachments = {"supressor5", "supressor6", "supressor15"}},
	weapon_sa58dsa = {name = "DSA SA58", category = "Assault Rifles", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15"}},
	weapon_aek971 = {name = "AEK-971", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor3", "supressor4", "supressor15", "mag3", "mag8", "mag12"}},
	weapon_sag_ak545 = {name = "SAG AK-545", category = "Marksman", slot = "primary", weight = 9, clips = 3, attachments = {"supressor3", "supressor4", "supressor15", "mag3", "mag4", "mag8", "mag12"}},
	weapon_aug = {name = "Steyr AUG", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "laser1", "laser2", "laser3", "laser5"}},
	weapon_scarl = {name = "SCAR-L", category = "Assault Rifles", slot = "primary", weight = 10, clips = 3, attachments = {"supressor5", "supressor6", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5", "laser1", "laser2", "laser3", "laser5", "mag2", "mag7", "mag11"}},
	weapon_scarh = {name = "SCAR-H", category = "Assault Rifles", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic2", "optic5", "optic7", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5", "laser1", "laser2", "laser3", "laser5"}},
	weapon_pp1901 = {name = "PP-19-01 Vityaz", category = "SMGs", slot = "primary", weight = 7, clips = 4, attachments = {"supressor1", "supressor2", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5"}},
	weapon_ump45 = {name = "UMP .45", category = "SMGs", slot = "primary", weight = 7, clips = 4, attachments = {"supressor1", "supressor2", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5"}},
	weapon_sr2 = {name = "SR-2M Veresk", category = "SMGs", slot = "primary", weight = 7, clips = 4, attachments = {"supressor1", "supressor2", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8"}},
	weapon_vector45 = {name = "KRISS Vector .45", category = "SMGs", slot = "primary", weight = 8, clips = 4, attachments = {"supressor1", "supressor2", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8"}},
	weapon_spas12 = {name = "SPAS-12", category = "Shotguns", slot = "primary", weight = 9, clips = 3, attachments = {"supressor6", "supressor5"}},
	weapon_m590a1 = {name = "M590A1", category = "Shotguns", slot = "primary", weight = 8, clips = 3, attachments = {}},
	weapon_remington870 = {name = "Remington 870", category = "Shotguns", slot = "primary", weight = 8, clips = 4, attachments = {"supressor5", "holo1", "holo2", "holo14", "holo15", "holo16"}},
	weapon_xm1014 = {name = "XM-1014", category = "Shotguns", slot = "primary", weight = 10, clips = 3, attachments = {"supressor5", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15"}},
	weapon_saiga12 = {name = "Saiga-12K", category = "Shotguns", slot = "primary", weight = 12, clips = 3, attachments = {"supressor12", "supressor13", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic8"}},
	weapon_mr43_short = {name = "MR-43 Short", category = "Shotguns", slot = "primary", weight = 5, clips = 6, attachments = {}},
	weapon_mr43 = {name = "MR-43", category = "Shotguns", slot = "primary", weight = 6, clips = 6, attachments = {}},
	weapon_mts255 = {name = "MTs-255", category = "Shotguns", slot = "primary", weight = 8, clips = 4, attachments = {}},
	weapon_sks = {name = "SKS", category = "Marksman", slot = "primary", weight = 10, clips = 3, attachments = {"supressor7", "supressor8", "supressor15", "holo6", "holo6fur", "optic4", "optic11"}},
	weapon_svd = {name = "SVD", category = "Marksman", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15", "holo6", "holo6fur", "optic4", "optic11"}},
	weapon_kar98 = {name = "Karabiner 98k", category = "Marksman", slot = "primary", weight = 9, clips = 4, attachments = {"optic12", "supressor7"}},
	weapon_sr25 = {name = "SR-25", category = "Marksman", slot = "primary", weight = 13, clips = 3, attachments = {"supressor9", "supressor16", "supressor15", "holo1", "holo2", "holo14", "holo15", "optic2", "optic5", "optic7", "optic8", "grip1", "grip2", "grip3", "grip4", "grip5", "laser1", "laser2", "laser3", "laser5"}},
	weapon_sv98 = {name = "SV-98", category = "Marksman", slot = "primary", weight = 11, clips = 4, attachments = {"supressor9", "supressor16", "supressor15", "holo1", "holo2", "holo14", "holo15", "optic2", "optic5", "optic7", "optic8"}},
	weapon_vss = {name = "VSS Vintorez", category = "Marksman", slot = "primary", weight = 11, clips = 4, attachments = {"holo6", "holo6fur", "optic4", "optic11", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic2", "optic5", "optic7", "optic8"}},
	weapon_mxlr = {name = "MXLR", category = "Marksman", slot = "primary", weight = 12, clips = 4, attachments = {}},
	weapon_mk11 = {name = "MK11 Taupe", category = "Marksman", slot = "primary", weight = 13, clips = 3, attachments = {}},
	weapon_rfb = {name = "RFB", category = "Marksman", slot = "primary", weight = 12, clips = 3, attachments = {"supressor9", "supressor16", "supressor15"}},
	weapon_g28 = {name = "G28", category = "Marksman", slot = "primary", weight = 14, clips = 3, attachments = {}},
	weapon_vpo101 = {name = "VPO-101", category = "Marksman", slot = "primary", weight = 9, clips = 4, attachments = {"supressor9", "supressor16", "supressor15"}},
	weapon_glock17 = {name = "Glock 17", category = "Sidearms", slot = "secondary", weight = 4, clips = 3, attachments = {"supressor2", "supressor1", "holo16", "optic24", "laser1", "laser2", "laser3", "laser5", "mag1"}},
	weapon_sam_fisher_glock = {name = "Sam Fisher Glock", category = "Sidearms", slot = "secondary", weight = 5, clips = 3, attachments = {"holo16", "optic24", "laser1", "laser2", "laser3", "laser5", "mag1"}, unlock = "samfisher"},
	weapon_px4beretta = {name = "Beretta PX4", category = "Sidearms", slot = "secondary", weight = 3, clips = 3, attachments = {}},
	weapon_hk_usp = {name = "HK USP", category = "Sidearms", slot = "secondary", weight = 4, clips = 3, attachments = {"holo16", "optic24", "laser1", "laser2", "laser3", "laser5"}},
	weapon_p22 = {name = "Walther P22", category = "Sidearms", slot = "secondary", weight = 2, clips = 4, attachments = {"laser1", "laser2", "laser3", "laser5"}},
	weapon_fn45 = {name = "FNX-45", category = "Sidearms", slot = "secondary", weight = 4, clips = 3, attachments = {"holo16", "optic24", "laser1", "laser2", "laser3", "laser5"}},
	weapon_cz75 = {name = "CZ 75", category = "Sidearms", slot = "secondary", weight = 3, clips = 3, attachments = {"supressor1", "supressor2"}},
	weapon_deagle = {name = "Desert Eagle", category = "Sidearms", slot = "secondary", weight = 5, clips = 3, attachments = {"holo16", "optic24", "laser1", "laser2", "laser3", "laser5"}},
	weapon_m1911 = {name = "Colt M1911", category = "Sidearms", slot = "secondary", weight = 3, clips = 3, attachments = {}},
	weapon_pl15 = {name = "PL-15", category = "Sidearms", slot = "secondary", weight = 3, clips = 3, attachments = {"supressor1", "supressor2", "holo16", "optic24", "laser1", "laser2", "laser3", "laser5"}},
	weapon_p226 = {name = "SIG Sauer P226", category = "Sidearms", slot = "secondary", weight = 3, clips = 3, attachments = {"supressor1", "supressor2", "holo16", "optic24", "laser1", "laser2", "laser3", "laser5"}},
	weapon_revolver2 = {name = "Manurhin MR-96", category = "Sidearms", slot = "secondary", weight = 4, clips = 4, attachments = {}},
	weapon_m249 = {name = "M249", category = "Heavy", slot = "primary", weight = 16, clips = 2, attachments = {"supressor5", "supressor6", "supressor15", "holo1", "holo2", "holo3", "holo4", "holo14", "holo15", "optic5", "optic7", "optic8", "laser1", "laser2", "laser3", "laser5"}},
	weapon_hg_smokenade_tpik = {name = "Smoke Bomb", category = "Grenades", slot = "grenade", weight = 2, clips = 0, attachments = {}},
	weapon_hg_grenade_tpik = {name = "M67 Frag Grenade", category = "Grenades", slot = "grenade", weight = 5, clips = 0, attachments = {}},
	weapon_hg_eft_v40 = {name = "V40 Frag Grenade", category = "Grenades", slot = "grenade", weight = 4, clips = 0, attachments = {}},
}

local picatinnySights = {
	"holo1", "holo2", "holo3", "holo4", "holo5", "holo5fur", "holo7", "holo8", "holo9",
	"holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "holo18", "holo19",
	"holo21", "holo22", "holo_boss", "optic2", "optic3", "optic5", "optic6", "optic7",
	"optic8", "optic9", "optic14", "optic15", "optic16", "optic17", "optic18", "optic19",
	"optic21", "optic22", "optic23",
}
local picatinnyGrips = {"grip1", "grip2", "grip3", "grip4", "grip5", "grip6", "grip7", "grip8", "grip9", "grip11", "grip12", "grip13", "grip14", "grip15"}
local smallTactical = {"laser1", "laser2", "laser3", "laser5"}
local arStocks = {"stock_ar15_dd_enhanced", "stock_ar15_fab_defense_gl_core_s", "stock_ar15_magpul_moe_sl_k", "stock_ar15_magpul_moe_carbine"}
local ironSights = {"ironsight1", "ironsight2", "ironsight3", "ironsight4"}
local dovetailSights = {"holo6", "holo6fur", "optic4", "optic11"}
local muzzleFamilies = {
	["545"] = {"muzzle_545_recoil_1", "muzzle_545_recoil_2", "muzzle_545_ergo_1", "muzzle_545_ergo_2", "muzzle_545_flash_1", "muzzle_545_flash_2"},
	["762x39"] = {"muzzle_762x39_recoil_1", "muzzle_762x39_recoil_2", "muzzle_762x39_ergo_1", "muzzle_762x39_ergo_2", "muzzle_762x39_flash_1", "muzzle_762x39_flash_2"},
	["556"] = {"muzzle_556_recoil_1", "muzzle_556_recoil_2", "muzzle_556_ergo_1", "muzzle_556_ergo_2", "muzzle_556_flash_1", "muzzle_556_flash_2"},
	["762x51"] = {"muzzle_762x51_recoil_1", "muzzle_762x51_recoil_2", "muzzle_762x51_ergo_1", "muzzle_762x51_ergo_2", "muzzle_762x51_flash_1", "muzzle_762x51_flash_2"},
}

local function AddArenaAttachments(weaponIds, attachmentIds)
	for _, weaponId in ipairs(weaponIds) do
		local weapon = MODE.ArenaWeapons[weaponId]
		if not weapon then continue end
		for _, attachmentId in ipairs(attachmentIds) do
			if not table.HasValue(weapon.attachments, attachmentId) then weapon.attachments[#weapon.attachments + 1] = attachmentId end
		end
	end
end

AddArenaAttachments({"weapon_akm", "weapon_ak74", "weapon_m4a1", "weapon_hk416", "weapon_ak12", "weapon_aug", "weapon_scarl", "weapon_scarh", "weapon_mp5", "weapon_mp7", "weapon_uzi", "weapon_vector", "weapon_p90", "weapon_pp1901", "weapon_ump45", "weapon_sr2", "weapon_vector45", "weapon_remington870", "weapon_xm1014", "weapon_saiga12", "weapon_sks", "weapon_svd", "weapon_sr25", "weapon_sv98", "weapon_vss", "weapon_m249"}, picatinnySights)
AddArenaAttachments({"weapon_hk416", "weapon_ak12", "weapon_scarl", "weapon_scarh", "weapon_pp1901", "weapon_ump45", "weapon_sr25"}, picatinnyGrips)
AddArenaAttachments({"weapon_hk416", "weapon_ak12", "weapon_aug", "weapon_scarl", "weapon_scarh", "weapon_mp7", "weapon_sr25", "weapon_m249"}, smallTactical)
AddArenaAttachments({"weapon_m4a1", "weapon_hk416", "weapon_ak12", "weapon_sr25"}, arStocks)
AddArenaAttachments({"weapon_ak74", "weapon_ak12"}, muzzleFamilies["545"])
AddArenaAttachments({"weapon_akm", "weapon_sks"}, muzzleFamilies["762x39"])
AddArenaAttachments({"weapon_m4a1", "weapon_hk416", "weapon_aug", "weapon_scarl", "weapon_m249"}, muzzleFamilies["556"])
AddArenaAttachments({"weapon_scarh", "weapon_kar98", "weapon_sr25", "weapon_sv98"}, muzzleFamilies["762x51"])

local requestedPicatinny = {"weapon_m4a1mod3", "weapon_mcx", "weapon_spear", "weapon_asval_mod4", "weapon_ash12", "weapon_mk47", "weapon_nl545", "weapon_mdr", "weapon_sa58dsa", "weapon_aek971", "weapon_ak12", "weapon_mxlr", "weapon_mk11", "weapon_rfb", "weapon_g28", "weapon_sv98"}
local requestedGrips = {"weapon_m4a1mod3", "weapon_mcx", "weapon_spear", "weapon_asval_mod4", "weapon_mk47", "weapon_nl545", "weapon_mdr", "weapon_sa58dsa", "weapon_aek971", "weapon_ak12", "weapon_mk11", "weapon_g28"}
local requestedTactical = {"weapon_m4a1mod3", "weapon_mcx", "weapon_spear", "weapon_asval_mod4", "weapon_ash12", "weapon_mk47", "weapon_nl545", "weapon_mdr", "weapon_sa58dsa", "weapon_aek971", "weapon_ak12", "weapon_mk11", "weapon_g28"}
AddArenaAttachments(requestedPicatinny, picatinnySights)
AddArenaAttachments({"weapon_m4a1mod3"}, ironSights)
AddArenaAttachments({"weapon_asval_mod4", "weapon_aek971"}, dovetailSights)
AddArenaAttachments(requestedGrips, picatinnyGrips)
AddArenaAttachments(requestedTactical, smallTactical)
AddArenaAttachments({"weapon_m4a1mod3", "weapon_mk47", "weapon_nl545"}, arStocks)
AddArenaAttachments({"weapon_ak12"}, {"stock_ak12_std"})
AddArenaAttachments({"weapon_m4a1mod3", "weapon_nl545", "weapon_mdr"}, muzzleFamilies["556"])
AddArenaAttachments({"weapon_aek971", "weapon_ak12"}, muzzleFamilies["545"])
AddArenaAttachments({"weapon_mk47"}, muzzleFamilies["762x39"])
AddArenaAttachments({"weapon_mcx", "weapon_spear", "weapon_sa58fal", "weapon_sa58dsa", "weapon_rfb"}, muzzleFamilies["762x51"])
AddArenaAttachments({"weapon_scorpion", "weapon_stm9", "weapon_sag_ak545"}, picatinnySights)
AddArenaAttachments({"weapon_sag_ak545", "weapon_stm9"}, picatinnyGrips)
AddArenaAttachments({"weapon_sag_ak545", "weapon_stm9"}, smallTactical)
AddArenaAttachments({"weapon_sag_ak545"}, arStocks)
AddArenaAttachments({"weapon_sag_ak545"}, {"stock_ak12_std"})
AddArenaAttachments({"weapon_stm9"}, {"stock_ar15_hk_slim_line"})
AddArenaAttachments({"weapon_vpo101"}, {"optic4", "optic11"})
AddArenaAttachments({"weapon_sag_ak545"}, muzzleFamilies["545"])
AddArenaAttachments({"weapon_vpo101"}, muzzleFamilies["762x51"])

for _, attachmentIds in pairs(muzzleFamilies) do
	for _, attachmentId in ipairs(attachmentIds) do
		MODE.ArenaAttachmentWeights[attachmentId] = string.find(attachmentId, "_recoil_", 1, true) and 2 or 1
	end
end

MODE.ArenaArmor = {
	vest1 = {name = "6B2 Body Armor II", slot = "vest", weight = 5},
	vest4 = {name = "TT Plate Carrier II", slot = "vest", weight = 5},
	vest5 = {name = "6B23-1 Body Armor III", slot = "vest", weight = 8},
	vest7 = {name = "MBSS Body Armor III", slot = "vest", weight = 8},
	vest8 = {name = "OTV UCP Body Armor III", slot = "vest", weight = 9},
	vest9 = {name = "6B13 Digital Body Armor IV", slot = "vest", weight = 12},
	vest11 = {name = "THOR CRV Body Armor IV", slot = "vest", weight = 12},
	vest12 = {name = "RBAV-AF Body Armor IV", slot = "vest", weight = 13},
	vest13 = {name = "6B43 Armor Kit V", slot = "vest", weight = 17},
	vest15 = {name = "Bagariy Armored Rig V", slot = "vest", weight = 17},
	vest16 = {name = "Osprey MK4A Protection V", slot = "vest", weight = 19},
	vest17 = {name = "Slick Black Armor VI", slot = "vest", weight = 22},
	vest18 = {name = "Zhuk-6A Armor VI", slot = "vest", weight = 23},
	vest21 = {name = "6B43 Armor Kit VII", slot = "vest", weight = 29},
	vest22 = {name = "THOR Integrated Carrier VII", slot = "vest", weight = 28},
	helmet3 = {name = "UNTAR Helmet I", slot = "helmet", weight = 2},
	helmet4 = {name = "Tac-Kek FAST MT I", slot = "helmet", weight = 2},
	helmet5 = {name = "Kolpak-1S I", slot = "helmet", weight = 3},
	helmet_riot = {name = "ZSh-1-2M I", slot = "helmet", weight = 3},
	helmet20 = {name = "Enduro Helmet I", slot = "helmet", weight = 2},
	helmet25 = {name = "Tactical MVD Helmet II", slot = "helmet", weight = 4},
	helmet_sobr2 = {name = "Gallet TC 800 II", slot = "helmet", weight = 5},
	helmet_sobr3 = {name = "NeoSteel II", slot = "helmet", weight = 4},
	helmet7 = {name = "6B47 Covered Helmet III", slot = "helmet", weight = 6},
	helmet8 = {name = "LShZ Light Helmet III", slot = "helmet", weight = 7},
	helmet9 = {name = "TC-2001 Helmet III", slot = "helmet", weight = 6},
	helmet_sobr1 = {name = "LShZ-2DTM III", slot = "helmet", weight = 7},
	helmet11 = {name = "ZSh-1-2M IV", slot = "helmet", weight = 10},
	helmet12 = {name = "LShZ-2DTM Covered IV", slot = "helmet", weight = 10},
	helmet13 = {name = "Team Wendy EXFIL Black IV", slot = "helmet", weight = 10},
	helmet14 = {name = "Team Wendy EXFIL Coyote IV", slot = "helmet", weight = 10},
	helmet15 = {name = "Caiman Helmet IV", slot = "helmet", weight = 10},
	helmet16 = {name = "Bastion Plate Helmet V", slot = "helmet", weight = 13},
	helmet17 = {name = "FAST MT Black SLAAP V", slot = "helmet", weight = 14},
	helmet26 = {name = "FAST MT Tan SLAAP V", slot = "helmet", weight = 14},
	helmet27 = {name = "Rys-T V", slot = "helmet", weight = 13},
	helmet28 = {name = "Vulkan-5 V", slot = "helmet", weight = 14},
	helmet29 = {name = "Maska-1Sh V", slot = "helmet", weight = 14},
	mask4 = {name = "Enduro Mask", slot = "visor", weight = 1, helmets = {helmet20 = true}},
	visor_fast = {name = "FAST MT Visor II", slot = "visor", weight = 3, helmets = {helmet8 = true}},
	mandible_caiman = {name = "Caiman Mandible II", slot = "visor", weight = 3, helmets = {helmet15 = true}},
	visor_caiman = {name = "Caiman Visor II", slot = "visor", weight = 3, helmets = {helmet15 = true}},
	visor_fast_shield = {name = "FAST MT Face Shield III", slot = "visor", weight = 7, helmets = {helmet17 = true, helmet26 = true}},
	visor_heavy_trooper = {name = "Heavy Trooper Face Mask II", slot = "visor", weight = 4, helmets = {helmet17 = true, helmet26 = true}},
	visor_lshz2dtm = {name = "LShZ-2DTM Face Shield IV", slot = "visor", weight = 8, helmets = {helmet12 = true}},
	visor_kolpak = {name = "Kolpak-1S Visor II", slot = "visor", weight = 3, helmets = {helmet5 = true}},
	visor_maska = {name = "Maska-1Sh Face Shield VI", slot = "visor", weight = 10, helmets = {helmet29 = true}},
	visor_riot = {name = "ZSh-1-2M Face Shield II", slot = "visor", weight = 3, helmets = {helmet_riot = true}},
	visor_rys_t = {name = "Rys-T Face Shield V", slot = "visor", weight = 10, helmets = {helmet27 = true}},
	visor_sobr2 = {name = "Gallet Face Shield II", slot = "visor", weight = 3, helmets = {helmet_sobr2 = true}},
	visor_sobr1 = {name = "LShZ-2DTM Face Shield II", slot = "visor", weight = 3, helmets = {helmet_sobr1 = true}},
	visor_vulkan = {name = "Vulkan-5 Face Shield IV", slot = "visor", weight = 8, helmets = {helmet28 = true}},
	visor_zsh = {name = "ZSh-1-2M Face Shield III", slot = "visor", weight = 6, helmets = {helmet11 = true}},
	visor_exfil_black = {name = "Team Wendy EXFIL Face Shield III", slot = "visor", weight = 6, helmets = {helmet13 = true, helmet14 = true}},
}

MODE.ArenaMedical = {
	weapon_bandage_sh = {name = "Bandage", weight = 1},
	weapon_tourniquet = {name = "Tourniquet", weight = 1},
	weapon_bigbandage_sh = {name = "Large Bandage", weight = 2},
	weapon_medkit_sh = {name = "Medkit", weight = 4},
	weapon_painkillers_tpik = {name = "Painkillers", weight = 1},
	weapon_morphine = {name = "Morphine", weight = 2},
	weapon_adrenaline = {name = "Epinephrine", weight = 2},
	weapon_bloodbag = {name = "Blood Bag", weight = 3},
	weapon_needle = {name = "Decompression Needle", weight = 1},
	weapon_betablock_tpik = {name = "Beta Blocker", weight = 1},
	weapon_thiamine_tpik = {name = "Thiamine", weight = 1},
}

MODE.ArenaCategoryOrder = {"Grenades", "Assault Rifles", "SMGs", "Shotguns", "Marksman", "Heavy", "Sidearms"}

function MODE:HG_MovementCalc_2( mul, ply, cmd, mv )
	local cleanupActive = GetGlobalBool("ArenaCleanupActive") or IsValid(ply) and (ply:GetNWBool("ArenaCleanupCleaner") or ply:GetNWBool("ArenaCleanupTarget"))
	if not cleanupActive and (zb.ROUND_START or 0) + self.start_time > CurTime() and cmd then
        cmd:RemoveKey(IN_ATTACK)
        cmd:RemoveKey(IN_FORWARD)
        cmd:RemoveKey(IN_BACK)
        cmd:RemoveKey(IN_MOVELEFT)
        cmd:RemoveKey(IN_MOVERIGHT)

        if mv then
            mv:RemoveKey(IN_ATTACK)
            mv:RemoveKey(IN_FORWARD)
            mv:RemoveKey(IN_BACK)
            mv:RemoveKey(IN_MOVELEFT)
            mv:RemoveKey(IN_MOVERIGHT)
        end

        if IsValid(ply) and IsValid(ply:GetWeapon("weapon_hands_sh")) then
            cmd:SelectWeapon(ply:GetWeapon("weapon_hands_sh"))
            if SERVER then ply:SelectWeapon("weapon_hands_sh") end
        end
        
        mul[1] = 0
    end
end

function MODE:PlayerCanLegAttack( ply )
	if zb.CROUND == "tdm" and not GetGlobalBool("ArenaCleanupActive") and (zb.ROUND_START or 0) + self.start_time > CurTime() then
		return false
	end
end
