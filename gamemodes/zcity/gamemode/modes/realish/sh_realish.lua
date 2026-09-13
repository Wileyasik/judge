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
		primary = {name = "M4A1", class = "weapon_m4a1", clips = 5, attachments = {"supressor2", "holo5fur", "optic2", "grip2", "laser2"}},
		secondary = {name = "Desert Eagle", class = "weapon_deagle", clips = 4, attachments = {"holo5fur"}},
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
			{name = "M4A1", class = "weapon_m4a1", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "HK416", class = "weapon_hk416", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "AK-74", class = "weapon_ak74", clips = 3, attachments = {"supressor1", "supressor8", "holo6fur", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_ak740", "grip_akdong", "grip1_ak740"}},
			{name = "AKM", class = "weapon_akm", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "AK-47", class = "weapon_ak47", clips = 3, attachments = {"supressor1", "supressor6"}},
			{name = "AK-200", class = "weapon_ak200", clips = 3, attachments = {"supressor1", "supressor8", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "AK-203", class = "weapon_ak203", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "AKS-74U", class = "weapon_ak74u", clips = 3, attachments = {"supressor1", "supressor8", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
		    --{name = "ASH-12", class = "weapon_ash12", clips = 3, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "AS Val", class = "weapon_asval", clips = 3, attachments = {"holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "M16A1", class = "weapon_m16a1", clips = 3, attachments = {"holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "M16A1 30", class = "weapon_m16a1_30", clips = 3, attachments = {"holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "M16A2", class = "weapon_m16a2", clips = 3, attachments = {"holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "AR-15", class = "weapon_ar15", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "Ruger AC-556", class = "weapon_ac556", clips = 3},
			{name = "SG 552", class = "weapon_sg552", clips = 3, attachments = {"supressor2", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Type 56-1", class = "weapon_type56", clips = 3, attachments = {"supressor1", "supressor6"}},
			{name = "VPO-136", class = "weapon_vpo136", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "VPO-209", class = "weapon_vpo209", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "Underground AKM", class = "weapon_akmwreked", clips = 3, attachments = {"supressor1", "supressor6"}},
		},
		secondary = {
			{name = "Colt M45A1", class = "weapon_m45", clips = 2, attachments = {"supressor4"}},
			{name = "Colt M1911", class = "weapon_m1911", clips = 2, attachments = {"supressor4"}},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "Glock 17 Burst", class = "weapon_glock17b", clips = 2, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "Glock 18C", class = "weapon_glock18c", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "Beretta M9", class = "weapon_m9beretta", clips = 2, attachments = {"supressor4", "supressor6", "laser1", "laser2", "laser3", "laser5"}},
			{name = "Browning Hi-Power", class = "weapon_browninghp", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "HK USP", class = "weapon_hk_usp", clips = 2, attachments = {"supressor3", "supressor4", "supressor6", "laser1", "laser2", "laser3", "laser5"}},
			{name = "PL-15", class = "weapon_pl15", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "TEC-9", class = "weapon_tec9", clips = 2},
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
			{name = "MP5A5", class = "weapon_mp5a5", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "MP5", class = "weapon_mp5", clips = 3, attachments = {"supressor4", "supressor6"}},
			{name = "MP5K", class = "weapon_mp5k", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "MP5SD6", class = "weapon_mp5sd6", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "MP5 Custom", class = "weapon_mp5_custom", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5"}},
			{name = "MP5SD6 Custom", class = "weapon_mp5sd6_custom", clips = 3, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5"}},
			{name = "MP5/40", class = "weapon_mp540", clips = 3, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5"}},
			{name = "MP7", class = "weapon_mp7", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "FN P90", class = "weapon_p90", clips = 3, attachments = {"supressor1", "supressor8", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "KRISS Vector", class = "weapon_vector", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Uzi", class = "weapon_uzi", clips = 3},
			{name = "MAC-11", class = "weapon_mac11", clips = 3, attachments = {"supressor4"}},
			{name = "Steyr TMP", class = "weapon_tmp", clips = 3, attachments = {"supressor4", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "laser1", "laser2", "laser3", "laser5"}},
			{name = "RO-635", class = "weapon_ro635", clips = 3, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Colt 9mm SMG", class = "weapon_colt9mm", clips = 3},
			{name = "Skorpion vz. 61", class = "weapon_skorpion", clips = 3},
			{name = "Ruger 10/22", class = "weapon_ruger", clips = 3},
		},
		secondary = {
			{name = "Colt M1911", class = "weapon_m1911", clips = 2, attachments = {"supressor4"}},
			{name = "FNX-45", class = "weapon_fn45", clips = 2, attachments = {"supressor4", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "laser1", "laser2", "laser3", "laser5"}},
			{name = "Beretta PX4", class = "weapon_px4beretta", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "Glock 26", class = "weapon_glock26", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "Makarov", class = "weapon_makarov", clips = 2},
			{name = "Walther P22", class = "weapon_p22", clips = 2, attachments = {"supressor4", "supressor6", "laser1", "laser2", "laser3", "laser5"}},
			{name = "TT-33", class = "weapon_tokarev", clips = 2, attachments = {"supressor4"}},
			{name = "Zoraki M906", class = "weapon_zoraki", clips = 2},
		},
		gadget = {
			{name = "Medkit", class = "weapon_medkit_sh", clips = 0},
			{name = "Painkillers", class = "weapon_painkillers", clips = 0},
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
			{name = "Mini-14", class = "weapon_mini14", clips = 3},
			{name = "SKS", class = "weapon_sks", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "Kar98k", class = "weapon_kar98", clips = 2, attachments = {"supressor7", "optic12"}},
			{name = "Mosin-Nagant", class = "weapon_mosin", clips = 2, attachments = {"supressor1", "supressor7", "optic12"}},
			{name = "SVD", class = "weapon_svd", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "SR25", class = "weapon_sr25", clips = 3, attachments = {"supressor7", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "Barrett M98B", class = "weapon_m98b", clips = 2, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Beowulf", class = "weapon_50beowulf", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser4"}},
			{name = "Winchester 1894", class = "weapon_winchester", clips = 2},
			{name = "Long Land Pattern", class = "weapon_musket", clips = 2},
			{name = "PTRD-41", class = "weapon_ptrd", clips = 1},
			{name = "VPO-136", class = "weapon_vpo136", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "VPO-209", class = "weapon_vpo209", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "Vepr SOK-94", class = "weapon_sok94", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11", "grip_akm0", "laser4"}},
			{name = "AR-15", class = "weapon_ar15", clips = 3, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser4", "laser5"}},
			{name = "Ruger 10/22", class = "weapon_ruger", clips = 3},
		},
		secondary = {
			{name = "MR-96", class = "weapon_revolver2", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "Desert Eagle", class = "weapon_deagle", clips = 2, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Desert Eagle Comp", class = "weapon_deagle_c", clips = 2, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "laser1", "laser2", "laser3", "laser5"}},
			{name = "Colt King Cobra", class = "weapon_revolver357", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "Glock 17 LB", class = "weapon_glock17lb", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "CZ 75", class = "weapon_cz75", clips = 2, attachments = {"supressor3", "supressor4", "supressor6"}},
			{name = "CZ 75-A", class = "weapon_cz75a", clips = 2, attachments = {"supressor3", "supressor4", "supressor6"}},
			{name = "PB-4 Osa", class = "weapon_osapb", clips = 2},
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
			{name = "M870", class = "weapon_m870", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "M590A1", class = "weapon_m590a1", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Benelli M4 Sport", class = "weapon_m4sport", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Benelli M4", class = "weapon_m4super", clips = 3},
			{name = "Benelli M4 Tactical", class = "weapon_m4tac", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5"}},
			{name = "XM-1014", class = "weapon_xm1014", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "XM-1014 Short", class = "weapon_m4short", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "SPAS-12", class = "weapon_spas12", clips = 3, attachments = {"supressor5", "supressor6"}},
			{name = "SPAS-12 Folded", class = "weapon_spas12_folded", clips = 3, attachments = {"supressor5", "supressor6"}},
			{name = "SPAS-12 Short", class = "weapon_spas12_short", clips = 3, attachments = {"supressor5", "supressor6"}},
			{name = "SPAS-12M", class = "weapon_spas12_modern", clips = 3, attachments = {"supressor5", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Saiga-12", class = "weapon_saiga12", clips = 3},
			{name = "Remington 870", class = "weapon_remington870", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Remington 870 Long", class = "weapon_remington870_long", clips = 3, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Remington 870 Sawed", class = "weapon_remington870_sawed_off", clips = 3, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "M870 MCS", class = "weapon_m870mcs", clips = 3, attachments = {"supressor5", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "IZh-43", class = "weapon_doublebarrel", clips = 3},
			{name = "Sawed-off IZh-43", class = "weapon_doublebarrel_short", clips = 3},
			{name = "KS-23", class = "weapon_ks23", clips = 3},
			{name = "TOZ-106", class = "weapon_toz106", clips = 3, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
		},
		secondary = {
			{name = "Colt M45A1", class = "weapon_m45", clips = 2, attachments = {"supressor4"}},
			{name = "Glock 17", class = "weapon_glock17", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "MR-96", class = "weapon_revolver2", clips = 2, attachments = {"supressor4", "supressor6"}},
			{name = "Desert Eagle", class = "weapon_deagle", clips = 2, attachments = {"holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "AR Pistol", class = "weapon_ar_pistol", clips = 2, attachments = {"supressor2", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9"}},
			{name = "Micro Draco", class = "weapon_draco", clips = 2, attachments = {"supressor1", "supressor8", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "VSKA Draco", class = "weapon_dracovska", clips = 2, attachments = {"supressor1", "supressor6", "holo5fur", "holo6fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo6", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo17", "optic2", "optic3", "optic4", "optic5", "optic6", "optic7", "optic8", "optic9", "optic11"}},
			{name = "PM-9", class = "weapon_pm9", clips = 2, attachments = {"supressor4", "supressor6", "holo5fur", "holo1", "holo2", "holo3", "holo4", "holo5", "holo7", "holo8", "holo9", "holo11", "holo12", "holo13", "holo14", "holo15", "holo16", "holo17", "optic2", "optic3", "optic5", "optic6", "optic7", "optic8", "optic9", "grip1", "grip2", "grip3", "laser1", "laser2", "laser3", "laser5", "mag1"}},
			{name = "MP-80", class = "weapon_mp-80", clips = 2},
		},
		gadget = {
			{name = "SLAM", class = "weapon_hg_slam", clips = 0},
			{name = "Pipe Bomb", class = "weapon_hg_pipebomb_tpik", clips = 0},
			{name = "Battering Ram", class = "weapon_ram", clips = 0},
		},
		grenade = 		{
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


