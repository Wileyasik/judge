local MODE = MODE

MODE.name = "realish"
MODE.PrintName = "Realish"

zb = zb or {}
zb.Points = zb.Points or {}

zb.Points.REALISH_ATLAS = zb.Points.REALISH_ATLAS or {}
zb.Points.REALISH_ATLAS.Color = Color(200, 20, 20)
zb.Points.REALISH_ATLAS.Name = "REALISH_ATLAS"

zb.Points.REALISH_REVENANT = zb.Points.REALISH_REVENANT or {}
zb.Points.REALISH_REVENANT.Color = Color(20, 80, 220)
zb.Points.REALISH_REVENANT.Name = "REALISH_REVENANT"

zb.Points.REALISH_MENU_CAMERA = zb.Points.REALISH_MENU_CAMERA or {}
zb.Points.REALISH_MENU_CAMERA.Color = Color(180, 80, 255)
zb.Points.REALISH_MENU_CAMERA.Name = "REALISH_MENU_CAMERA"

RealishTeams = RealishTeams or {
	[0] = {
		name = "ATLAS",
		color = Color(200, 20, 20)
	},
	[1] = {
		name = "REVENANT",
		color = Color(20, 80, 220)
	}
}

RealishArmorCosts = RealishArmorCosts or {
	None = 0,
	Light = 2,
	Heavy = 4
}

RealishClassOrder = RealishClassOrder or {"Assault", "Medic", "Recon", "Demolition"}

RealishHeroConfig = RealishHeroConfig or {
	lowLivesThreshold = 7,
	overtakeRatio = 1.5,
	duration = 30,
	minRoundTime = 25,
	cooldown = 75,
	maxActivePerTeam = 1,
	heroLives = 3,
}
RealishHeroConfig.heroLives = 3

RealishHeroOrder = RealishHeroOrder or {"Strike"}


RealishHeroes = RealishHeroes or {
	Strike = {
		name = "CAG",
		desc = "OORAAHHH!",
		primary = {name = "M4A1", class = "weapon_m4a1", clips = 5, attachments = {"supressor5", "holo5fur", "optic2"}},
		secondary = {name = "Desert Eagle", class = "weapon_deagle", clips = 4, attachments = {"holo16"}},
		gadget = {name = "Medkit", class = "weapon_medkit_sh", clips = 0},
		grenade = {name = "M67", class = "weapon_hg_grenade_tpik", clips = 0},
		armor = "Heavy",
		walkSpeed = 135,
		runSpeed = 430,
		damageResist = 0.2,
	},
}

hook.Add("HG_MovementCalc_2", "RealishHeroMovementBoost", function(mulTable, ply, cmd, mv)
	if not IsValid(ply) or not ply.RealishIsHero then return end
	mulTable[1] = mulTable[1] * 1.18
end)

RealishHeroSkulls = RealishHeroSkulls or {
	[0] = "vgui/atlaheroskull.png",
	[1] = "vgui/revheroskull.png",
}

RealishKillstreakConfig = RealishKillstreakConfig or {
	maxPicks = 3,
	boxIcon = "icon16/award_star.png"
}

RealishKillstreakOrder = {"Supply", "Radar", "Airstrike", "PhantomRush"}

RealishKillstreaks = {
	Supply = {
		name = "Ammo Crate",
		desc = "A one time use ammo crate that will give you 2 magazines worth of ammo on all of your weapons.",
		kills = 2,
		icon = "spawnicons/models/props_junk/wood_crate001a.png",
		weapon = "weapon_ammocrate",
		clips = 0,
		selectSound = "buttons/button14.wav",
		earnedSound = "buttons/bell1.wav"
	},
	Radar = {
		name = "UAV",
		desc = "Marks enemies on that area for a brief period of time.",
		kills = 3,
		icon = "vgui/uav.png",
		weapon = "weapon_uav",
		clips = 0,
		selectSound = "buttons/button14.wav",
		earnedSound = "buttons/bell1.wav"
	},
	Airstrike = {
		name = "Airstrike",
		desc = "Call in an airstrike that will drop a set of bombs on the target area.",
		kills = 5,
		icon = "vgui/airstrike.png",
		weapon = "weapon_airstrike",
		clips = 0,
		selectSound = "buttons/button14.wav",
		earnedSound = "buttons/bell1.wav"
	},
	PhantomRush = {
		name = "Phantom Rush",
		desc = "Carpet bomb the designated area with B2 Stealth Bombers.",
		kills = 8,
		icon = "vgui/b2bomber.png",
		weapon = "weapon_carpetbomber",
		clips = 0,
		selectSound = "buttons/button14.wav",
		earnedSound = "buttons/bell1.wav"
	},
}

RealishLoadoutSlots = RealishLoadoutSlots or {
	{id = "primary", name = "Primary"},
	{id = "secondary", name = "Secondary"},
	{id = "gadget", name = "Gadget"},
	{id = "gadget2", name = "Gadget 2"},
	{id = "grenade", name = "Grenade"}
}


RealishClasses = RealishClasses or {
	Assault = {
		primary = {
			{name = "M4A1", class = "weapon_m4a1", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","ironsight3","optic19","ironsight1","optic22","ironsight4","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","ironsight2","holo14","mag14","mag7","mag11","mag2"}},
			{name = "HK416", class = "weapon_hk416", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag14","mag7","mag11","mag2"}},
			{name = "AK-74", class = "weapon_ak74", clips = 3, attachments = {"supressor3","supressor4","supressor15","muzzle_545_flash_1","muzzle_545_ergo_1","muzzle_545_flash_2","muzzle_545_recoil_2","muzzle_545_ergo_2","muzzle_545_recoil_1","muzzle_std_545","mag12","mag3","mag8","mag4"}},
			{name = "AKM", class = "weapon_akm", clips = 3, attachments = {"supressor7","supressor8","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","mag5","mag9","mag6","mag13"}},
			{name = "RD-704", class = "weapon_rd704", clips = 3, attachments = {"supressor8","supressor7","supressor16","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag5","mag9","mag6","mag13"}},
			{name = "AK-100", class = "weapon_ak100", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "AK-12", class = "weapon_ak12", clips = 3, attachments = {"supressor3","supressor4","supressor15","muzzle_545_flash_1","muzzle_545_ergo_1","muzzle_545_flash_2","muzzle_545_recoil_2","muzzle_545_ergo_2","muzzle_545_recoil_1","muzzle_std_545","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag12","mag3","mag8","mag4"}},
			{name = "AKS-74U", class = "weapon_ak74u", clips = 3, attachments = {"supressor3","supressor4","supressor15","muzzle_545_flash_1","muzzle_545_ergo_1","muzzle_545_flash_2","muzzle_545_recoil_2","muzzle_545_ergo_2","muzzle_545_recoil_1","muzzle_std_545","holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14","mag12","mag3","mag8","mag4"}},
			{name = "AS Val", class = "weapon_asval", clips = 3, attachments = {"holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "M4A1 Mod3", class = "weapon_m4a1mod3", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","ironsight3","optic19","ironsight1","optic22","ironsight4","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","ironsight2","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag14","mag7","mag11","mag2"}},
			{name = "SIG MCX", class = "weapon_mcx", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag14","mag11","mag2"}},
			{name = "M16A2", class = "weapon_m16a2", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","mag14","mag7","mag11","mag2"}},
			{name = "TX-15", class = "weapon_tx15", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag14","mag7","mag11","mag2"}},
			{name = "Steyr AUG", class = "weapon_aug", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","laser3","laser1","laser5","laser2"}},
			{name = "HK G36", class = "weapon_g36", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag14","mag11","mag2"}},
			{name = "AKM Zenit", class = "weapon_akmz", clips = 3, attachments = {"supressor7","supressor8","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2","mag5","mag9","mag6","mag13"}},
			{name = "VPO-136", class = "weapon_vpo136", clips = 3, attachments = {"supressor7","supressor8","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","mag5","mag9","mag6","mag13"}},
			{name = "VPO-209", class = "weapon_vpo209", clips = 3, attachments = {"supressor3","supressor4","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","mag5","mag9","mag6","mag13"}},
			{name = "AVT-40", class = "weapon_avt40", clips = 3, attachments = {"holo6","optic4","optic11","holo6fur"}},
		},
		secondary = {
			{name = "Berreta M9A3", class = "weapon_m9a3", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "Colt M1911", class = "weapon_m1911", clips = 2, attachments = {"supressor4"}},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2","mag1"}},
			{name = "Glock 18C", class = "weapon_glock18c", clips = 2},
			{name = "Beretta M9", class = "weapon_m9beretta", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "Browning Hi-Power", class = "weapon_browninghp", clips = 2, attachments = {"supressor6","supressor4"}},
			{name = "HK USP", class = "weapon_usp", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "PL-15", class = "weapon_pl15", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "Sam Fisher Glock", class = "weapon_sam_fisher_glock", clips = 2, attachments = {"optic24","holo16","laser3","laser1","laser5","laser2","mag1"}},
		},
		gadget = {
			{name = "Ballistic Shield", class = "weapon_ballistic_shield", clips = 0},
			{name = "Taser X26", class = "weapon_taser", clips = 2},
			{name = "Battering Ram", class = "weapon_ram", clips = 0},
			{name = "M7 Bayonet", class = "weapon_combatknife", clips = 0},
		},
		grenade = {
			{name = "M67", class = "weapon_hg_grenade_tpik", clips = 0},
			{name = "F1", class = "weapon_hg_f1_tpik", clips = 0},
			{name = "RGD-5", class = "weapon_hg_rgd_tpik", clips = 0},
			{name = "Flashbang", class = "weapon_hg_flashbang_tpik", clips = 0},
			{name = "Smoke", class = "weapon_hg_smokenade_tpik", clips = 0},
		},
	},
	Medic = {
		primary = {
			{name = "HK MP5SD", class = "weapon_mp5sd", clips = 3, attachments = {"holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7"}},
			{name = "MP5", class = "weapon_mp5", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "MP5K", class = "weapon_mp5k", clips = 3},
			{name = "SIG MPX", class = "weapon_mpx", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2"}},
			{name = "B&T MP9", class = "weapon_mp9", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","laser3","laser1","laser5","laser2"}},
			{name = "PP-19-01 Vityaz", class = "weapon_pp1901", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7"}},
			{name = "UMP .45", class = "weapon_ump45", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7"}},
			{name = "MP7", class = "weapon_mp7", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","laser3","laser1","laser5","laser2"}},
			{name = "FN P90", class = "weapon_p90", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "KRISS Vector", class = "weapon_vector", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","mag1"}},
			{name = "Uzi", class = "weapon_uzi", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "MAC-11", class = "weapon_mac11", clips = 3, attachments = {"supressor1","supressor2"}},
			{name = "PP-91 Kedr", class = "weapon_kedr", clips = 3},
			{name = "STM-9", class = "weapon_stm9", clips = 3, attachments = {"supressor2","supressor1","supressor15","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2"}},
			{name = "Colt 9mm SMG", class = "weapon_colt9mm", clips = 3},
			{name = "Skorpion vz. 61", class = "weapon_skorpion", clips = 3},
			{name = "Springfield M1A1", class = "weapon_m1a1", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
		},
		secondary = {
			{name = "Colt M1911", class = "weapon_m1911", clips = 2, attachments = {"supressor4"}},
			{name = "FNX-45", class = "weapon_fn45", clips = 2, attachments = {"supressor1","supressor2","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","optic24","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","holo16","optic16","holo14","laser5","laser3","laser1","laser2"}},
			{name = "Beretta PX4", class = "weapon_px4beretta", clips = 2, attachments = {"supressor6","supressor4"}},
			{name = "Glock 26", class = "weapon_glock26", clips = 2},
			{name = "PM", class = "weapon_pm", clips = 2, attachments = {"supressor2","supressor1","laser3","laser1","laser5","laser2"}},
			{name = "Walther P22", class = "weapon_p22", clips = 2, attachments = {"supressor1","supressor2","laser3","laser1","laser5","laser2"}},
		},
		gadget = {
			{name = "Medkit", class = "weapon_medkit_sh", clips = 0},
			{name = "Painkillers", class = "weapon_painkillers_tpik", clips = 0},
			{name = "Defibrillator", class = "weapon_defibrillator", clips = 0},
			{name = "Big Bandage", class = "weapon_bigbandage_sh", clips = 0},
			{name = "Morphine", class = "weapon_morphine", clips = 0},
			{name = "Epinephrine", class = "weapon_adrenaline", clips = 0},
			{name = "Mannitol", class = "weapon_mannitol", clips = 0},
		},
		grenade = {
			{name = "Smoke", class = "weapon_hg_smokenade_tpik", clips = 0},
			{name = "Flashbang", class = "weapon_hg_flashbang_tpik", clips = 0},
			{name = "M67", class = "weapon_hg_grenade_tpik", clips = 0},
			{name = "Type-59", class = "weapon_hg_type59_tpik", clips = 0},
		},
	},
	Recon = {
		primary = {
			{name = "VPO-215", class = "weapon_vpo215", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "SKS", class = "weapon_sks", clips = 3, attachments = {"supressor7","supressor8","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "Kar98k", class = "weapon_kar98", clips = 2, attachments = {"supressor7","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","optic12"}},
			{name = "Mosin", class = "weapon_mosinnagant", clips = 2, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","optic12"}},
			{name = "SVD", class = "weapon_svd", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "SR25", class = "weapon_sr25", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","grip2","grip4","grip11","grip1","grip6","grip13","grip3","grip5","grip15","grip12","grip14","grip9","grip8","grip7","laser3","laser1","laser5","laser2"}},
			{name = "AI AXMC", class = "weapon_axmc", clips = 2, attachments = {"supressor11","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "SV-98", class = "weapon_sv98", clips = 2, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "Long Land Pattern", class = "weapon_musket", clips = 2},
			{name = "PTRD-41", class = "weapon_ptrd", clips = 1},
			{name = "VPO-136", class = "weapon_vpo136", clips = 3, attachments = {"supressor7","supressor8","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","mag5","mag9","mag6","mag13"}},
			{name = "VPO-209", class = "weapon_vpo209", clips = 3, attachments = {"supressor3","supressor4","supressor15","muzzle_762x39_flash_2","muzzle_762x39_recoil_1","muzzle_762x39_ergo_2","muzzle_762x39_flash_1","muzzle_762x39_ergo_1","muzzle_762x39_recoil_2","muzzle_std_762x39","mag5","mag9","mag6","mag13"}},
			{name = "VPO-101", class = "weapon_vpo101", clips = 3, attachments = {"supressor9","supressor16","supressor15","muzzle_762x51_flash_1","muzzle_762x51_ergo_1","muzzle_762x51_recoil_1","muzzle_762x51_recoil_2","muzzle_762x51_flash_2","muzzle_762x51_ergo_2","muzzle_std_762x51","holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "ADAR 2-15", class = "weapon_adar215", clips = 3, attachments = {"supressor5","supressor6","supressor15","muzzle_556_recoil_1","muzzle_556_ergo_2","muzzle_556_recoil_2","muzzle_556_flash_1","muzzle_556_flash_2","muzzle_std_556","muzzle_556_ergo_1","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14","mag14","mag7","mag11","mag2"}},
			{name = "SVT-40", class = "weapon_svt", clips = 3, attachments = {"holo6","optic4","optic11","holo6fur"}},
		},
		secondary = {
			{name = "MR-96", class = "weapon_revolver2", clips = 2, attachments = {"supressor4","supressor6"}},
			{name = "Desert Eagle", class = "weapon_deagle", clips = 2, attachments = {"optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "SIG Sauer P226", class = "weapon_p226", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "Colt King Cobra", class = "weapon_revolver357", clips = 2},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2","mag1"}},
			{name = "Glock 19x", class = "weapon_glock26", clips = 2},
			{name = "CZ 75", class = "weapon_cz75", clips = 2, attachments = {"supressor1","supressor2"}},
			{name = "CZ 75-A", class = "weapon_cz75a", clips = 2},
		},
		gadget = {
			{name = "Taser X26", class = "weapon_taser", clips = 2},
			{name = "SOG SEAL 2000", class = "weapon_sogknife", clips = 0},
		},
		grenade = {
			{name = "Smoke", class = "weapon_hg_smokenade_tpik", clips = 0},
			{name = "Flashbang", class = "weapon_hg_flashbang_tpik", clips = 0},
			{name = "M67", class = "weapon_hg_grenade_tpik", clips = 0},
			{name = "Molotov", class = "weapon_hg_molotov_tpik", clips = 0},
		},
	},
	Demolition = {
		primary = {
			{name = "M3 Super 90", class = "weapon_m3super", clips = 3, attachments = {"supressor13","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "M590A1", class = "weapon_m590a1", clips = 3},
			{name = "Benelli M4", class = "weapon_m4super", clips = 3},
			{name = "USAS-12", class = "weapon_usas12", clips = 3, attachments = {"supressor6","supressor5","grip_ak740","grip1_ak740"}},
			{name = "AA-12", class = "weapon_aa12", clips = 3, attachments = {"supressor13"}},
			{name = "XM-1014", class = "weapon_xm1014", clips = 3, attachments = {"supressor5","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "MR-43 Short", class = "weapon_mr43_short", clips = 3},
			{name = "SPAS-12", class = "weapon_spas12", clips = 3, attachments = {"supressor6","supressor5"}},
			{name = "MR-133", class = "weapon_mp133", clips = 3, attachments = {"supressor13","supressor12"}},
			{name = "MR-153", class = "weapon_mp153", clips = 3, attachments = {"supressor13","supressor12","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "MTs-255", class = "weapon_mts255", clips = 3},
			{name = "Saiga-12", class = "weapon_saiga12", clips = 3, attachments = {"supressor13","supressor12","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "Remington 870", class = "weapon_remington870", clips = 3, attachments = {"supressor5","holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "Remington 870 Long", class = "weapon_remington870_long", clips = 3, attachments = {"holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "Remington 870 Sawed", class = "weapon_remington870_sawed_off", clips = 3, attachments = {"holo5fur","holo22","optic19","optic22","optic5","holo4","optic18","holo7","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo18","optic14","holo21","optic2","optic16","holo14"}},
			{name = "MR-43", class = "weapon_mr43", clips = 3},
			{name = "M870", class = "weapon_870", clips = 3},
			{name = "KS-23", class = "weapon_ks23", clips = 3},
			{name = "TOZ-106", class = "weapon_toz106", clips = 3, attachments = {"holo5fur","holo22","optic19","optic22","holo6","optic5","holo4","optic18","holo7","optic4","holo3","optic23","holo5","optic6","holo12","holo_boss","optic21","optic8","holo9","optic11","optic15","holo2","holo19","optic7","holo13","optic17","optic3","optic9","holo11","holo8","holo6fur","holo18","optic14","holo21","optic2","optic16","holo14"}},
		},
		secondary = {
			{name = "FN Five-seveN", class = "weapon_fn57", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2"}},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor2","supressor1","optic24","holo16","laser3","laser1","laser5","laser2","mag1"}},
			{name = "MR-96", class = "weapon_revolver2", clips = 2, attachments = {"supressor4","supressor6"}},
			{name = "Desert Eagle", class = "weapon_deagle", clips = 2, attachments = {"optic24","holo16","laser3","laser1","laser5","laser2"}},
		},
		gadget = {
			{name = "SLAM", class = "weapon_hg_slam", clips = 0},
			{name = "Pipe Bomb", class = "weapon_hg_pipebomb_tpik", clips = 0},
			{name = "Battering Ram", class = "weapon_ram", clips = 0},
		},
		grenade = {
			{name = "RGD-5", class = "weapon_hg_rgd_tpik", clips = 0},
			{name = "Incendiary", class = "weapon_hg_grenade_incendiary_tpik", clips = 0},
			{name = "Molotov", class = "weapon_hg_molotov_tpik", clips = 0},
			{name = "Pipe Bomb", class = "weapon_hg_pipebomb_tpik", clips = 0},
			{name = "IED", class = "weapon_traitor_ied", clips = 0},
			{name = "Type-59", class = "weapon_hg_type59_tpik", clips = 0},
		},
	},
}

RealishClasses.Medic.gadget2 = RealishClasses.Medic.gadget


