local MODE = MODE
MODE.start_time = 1
MODE.end_time = 7
 
MODE.ROUND_TIME = 600
 
MODE.randomSpawns = true

MODE.shouldfreeze = true

MODE.PoliceAllowed = false
MODE.OverrideSpawn = true

MODE.LootSpawn = true
MODE.LootOnTime = true

MODE.Chance = 0.2 -- this is mostly unused
MODE.LootDivTime = 500
MODE.SingleModeStrongLootCategoryMul = 0.35
MODE.SingleModeStrongLootItemMul = 0.45

local function ScaleLootTable(lootTable, categoryMul, itemMul)
	local scaled = {}

	for _, category in ipairs(lootTable or {}) do
		local items = {}

		for _, item in ipairs(category[2] or {}) do
			items[#items + 1] = {item[1] * itemMul, item[2]}
		end

		scaled[#scaled + 1] = {category[1] * categoryMul, items}
	end

	return scaled
end

local function MergeLootTables(...)
	local merged = {}

	for i = 1, select("#", ...) do
		local lootTable = select(i, ...)

		for _, category in ipairs(lootTable or {}) do
			local items = {}

			for _, item in ipairs(category[2] or {}) do
				items[#items + 1] = {item[1], item[2]}
			end

			merged[#merged + 1] = {category[1], items}
		end
	end

	return merged
end

function MODE:SetupChances()
	for name, tbl in pairs(MODE.Types) do
		local savedChance = tonumber(zb.ModesChances[name])

		if name == "suicidelunatic" and (savedChance == 0.2 or savedChance == 0.062 or savedChance == 0.02 or savedChance == 0.005) then
			savedChance = tbl.Chance
		elseif name == "standard" and savedChance == 0.2 then
			savedChance = tbl.Chance
		end

		zb.ModesChances[name] = savedChance or tbl.Chance
	end
end

MODE.LootTable = {
	-- [1] Медицина и расходники — самый частый кат
	{40, {
		{15,"weapon_smallconsumable"},
		{12,"weapon_bigconsumable"},
		{9,"weapon_tourniquet"},
		{9,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers_tpik"},
		{5,"weapon_bloodbag"},
		{4,"weapon_walkie_talkie"},
		{3,"hg_flashlight"},
		{3,"weapon_bigbandage_sh"},
		{2,"weapon_medkit_sh"},
		{1,"weapon_matches"},

		{0.5,"weapon_naloxone"},
		{0.4,"weapon_betablock_tpik"},
		{0.4,"weapon_adrenaline"},
		{0.3,"weapon_midazolam"},
		{0.3,"weapon_thiamine_tpik"},
		{0.2,"weapon_morphine"},
		{0.2,"weapon_mannitol"},
		{0.2,"weapon_defibrillator"},
		{0.1,"weapon_fentanyl"},
		{0.1,"hg_brassknuckles"},
	}},
	-- [2] Мили — слабое чаще, сильное редко (MeleeRare подмешивается ×0.3)
	{26, {
		{14,"weapon_hammer"},
		{11,"weapon_pocketknife"},
		{8,"weapon_brick"},
		{5,"weapon_bat"},
		{4,"weapon_leadpipe"},
		{3,"weapon_hg_extinguisher"},
		{2,"weapon_hg_crowbar"},
		{1.2,"weapon_hatchet"},
		{1,"hg_brassknuckles"},
		{0.7,"weapon_hg_axe"},
		{0.5,"weapon_defibrillator"},

		{0.9,"weapon_chair_leg"},
		{0.9,"weapon_table_leg"},
		{0.8,"weapon_hg_bottle"},
		{0.8,"weapon_hg_mug"},
		{0.7,"weapon_wirebat"},
		{0.6,"weapon_ram"},
		{0.5,"weapon_hg_tonfa"},
		{0.4,"weapon_hg_shuriken"},
		{0.3,"weapon_hg_bottlebroken"},
		{0.3,"weapon_hg_wire"},
	}},
	-- [3] Обвесы и лёгкая броня
	{11, {
		{10,"*sight*"},
		{7,"*barrel*"},

		{6,"ent_armor_helmet7"},
		{4,"ent_armor_vest7"},
		{3,"ent_armor_helmet2"},
	}},
	-- [4] Пистолеты — редкий кат
	{8, {
		{6,"*sight*"},
		{5,"*barrel*"},

		{12,"weapon_mp-80"},
		{7,"weapon_pm"},
		{6,"weapon_p22"},
		{4,"weapon_revolver2"},
		{4,"weapon_px4beretta"},
		{3,"weapon_m1911"},
		{2.5,"weapon_m9beretta"},
		{2,"weapon_fn45"},
	}},
	-- [5] Кобуры покрепче — очень редкий кат
	{4, {
		{7,"weapon_usp"},
		{7,"weapon_glock17"},
		{7,"weapon_cz75"},
		{7,"weapon_px4beretta"},

		{4,"weapon_deagle"},
		{4,"weapon_colt9mm"},

		{2.5,"weapon_flintlock"},
	}},
	-- [6] Средняя и тяжёлая броня — редко
	{5, {
		{4,"ent_armor_vest3"},
		{4,"ent_armor_helmet1"},
		{2,"ent_armor_vest4"},
		{1.5,"ent_armor_helmet5"},
	}},
	-- [7] Длинноствол — самый редкий кат
	{3, {
		{3,"weapon_hg_molotov_tpik"},
		{3,"weapon_hg_pipebomb_tpik"},

		{2.5,"weapon_mp5"},
		{2,"weapon_draco"},
		{2,"weapon_kar98"},
		{1.5,"weapon_m1a1"},
		{1.5,"weapon_sks"},
		{1.5,"weapon_m16a2"},

		{1,"weapon_mp7"},
		{1,"weapon_adar215"},
		{1,"weapon_hk416"},

		{0.8,"weapon_vpo136"},
		{0.8,"weapon_sr25"},
		{0.6,"weapon_musket"},
	}},
}

-- Judge arsenal, вшитый с настроенными множителями: сильный ствол и сильное
-- мили — редкость, броня поделена по тирам (лёгкая чаще, тяжёлая почти не найти).
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.MeleeCommon, 1)
hg.AppendLootPool(MODE.LootTable[2][2], hg.LootPools.MeleeRare, 0.3)
hg.AppendLootPool(MODE.LootTable[3][2], hg.LootPools.ArmorLight, 1)
hg.AppendLootPool(MODE.LootTable[3][2], hg.LootPools.ArmorMedium, 0.45)
hg.AppendLootPool(MODE.LootTable[4][2], hg.LootPools.Sidearms, 0.5)
hg.AppendLootPool(MODE.LootTable[6][2], hg.LootPools.ArmorMedium, 0.5)
hg.AppendLootPool(MODE.LootTable[6][2], hg.LootPools.ArmorHeavy, 0.25)
hg.AppendLootPool(MODE.LootTable[7][2], hg.LootPools.SMGs, 0.35)
hg.AppendLootPool(MODE.LootTable[7][2], hg.LootPools.Shotguns, 0.3)
hg.AppendLootPool(MODE.LootTable[7][2], hg.LootPools.AssaultRifles, 0.22)
hg.AppendLootPool(MODE.LootTable[7][2], hg.LootPools.Marksman, 0.18)
hg.AppendLootPool(MODE.LootTable[7][2], hg.LootPools.LMG, 0.1)

MODE.LootTableStandard = {
	{65, {
		{16,"weapon_smallconsumable"},
		{13,"weapon_bigconsumable"},
		{9,"weapon_tourniquet"},
		{9,"weapon_bandage_sh"},
		{7,"weapon_ducttape"},
		{6,"weapon_painkillers_tpik"},
		{5,"weapon_bloodbag"},
		{4,"hg_flashlight"},
		{1,"weapon_matches"},--for dumbasses
	}},
	{30, {
		{1.4,"weapon_hammer"},
		{1.2,"weapon_pocketknife"},
		{1,"weapon_brick"},
		{0.45,"weapon_bat"},
		{0.35,"weapon_leadpipe"},

		{0.15,"weapon_hg_extinguisher"},
		{0.14,"weapon_hg_crowbar"},

		{0.12,"weapon_hatchet"},
	}},
}

-- LootTableStandard only has medical + melee, so inject a rare gun category too.
-- Здесь всё ещё слабее основного: и стволы, и сильное мили почти не встречаются.
hg.AppendLootPool(MODE.LootTableStandard[2][2], hg.LootPools.MeleeCommon, 1)
hg.AppendLootPool(MODE.LootTableStandard[2][2], hg.LootPools.MeleeRare, 0.35)
MODE.LootTableStandard[3] = {10, {}}
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.Sidearms, 0.4)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.ArmorLight, 0.5)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.SMGs, 0.18)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.Shotguns, 0.15)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.ArmorMedium, 0.3)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.AssaultRifles, 0.12)
hg.AppendLootPool(MODE.LootTableStandard[3][2], hg.LootPools.Marksman, 0.08)

MODE.LootTableSingle = MergeLootTables(
	MODE.LootTableStandard,
	ScaleLootTable(MODE.LootTable, MODE.SingleModeStrongLootCategoryMul, MODE.SingleModeStrongLootItemMul)
)

-- MODE.TraitorWords = {
	-- "пистолет",
	-- "трейтор",
	-- "ганмен",
	-- "калаш (винтовка)",
	-- "бомба",
	-- "цианид",
	-- "нож",
	-- "труба",
	-- "топор",
	-- "юсп (пистолет)",
	-- "арка (винтовка)",
	-- "каряк (винтовка)",
	-- "граната",
	-- "улица",
	-- "здание",
	-- "патроны",
	-- "бинт",
	-- "аптечка",
	-- "обезболивающее",
	-- "дробовик",
-- }

MODE.TraitorWordsAdjectives = {
	"pretty",
	"sad",
	"bad",
	"cool",
	"happy",
	"ugly",
	"funny",
	"red",
	"green",
	"blue",
	"yellow",
	"orange",
	"cyan",
	"pink",
	"mesmerizing",
	"",	--; да да
}

MODE.TraitorWords = {
	"crate",
	"death",
	"man",
	"revolver",
	"door",
	"pistol",
	"traitor",
	"gunman",
	"ak rifle",
	"bomb",
	"cyanide",
	"knife",
	"pipe",
	"axe",
	"usp pistol",
	"ar15 rifle",
	"kar98k rifle",
	"grenade",
	"outside",
	"building",
	"ammo",
	"bandage",
	"medkit",
	"painkillers",
	"shotgun",
	"melancholic",
	"poison",
	"murder",
}

MODE.TraitorActions = {
	"punch air or walls",
	"jump",
	"crouch",
	"ragdoll randomly",
	"spin around",
}

SetGlobalBool("RolesPlus_Enable", true)

util.AddNetworkString("HMCDPoliceRole")
util.AddNetworkString("HMCD(StartPlayersRoleSelection)")
util.AddNetworkString("HMCD(EndPlayersRoleSelection)")
util.AddNetworkString("HMCD(SetSubRole)")
util.AddNetworkString("hmcd_announce_traitor_lose")

MODE.Type = MODE.Type or "standard"
MODE.Types = MODE.Types or {}
MODE.Types.standard = {
	Chance = 0.45,
	ChanceFunction = function() return zb.ModesChances["standard"] or zb.modes["hmcd"].Types.standard.Chance end,
	LootTable = MODE.LootTableSingle,
	Messages = {
		[3] = "Everyone died.",
		[1] = "The Executioner has eliminated everyone.",
		[0] = "The Executioner was",
	},
	Message = "The Executioner was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_buck200knife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_shuriken")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison1")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply:Give("weapon_traitor_suit")
		local wep = ply:Give("weapon_zoraki")
		timer.Simple(1,function()
			if IsValid(wep) then wep:ApplyAmmoChanges(2) end
		end)

		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory") or {}
		inv["Weapons"] = inv["Weapons"] or {}
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
		if MODE.ApplyHeroLoadout then
			MODE.ApplyHeroLoadout(ply)
			return
		end
		ply:Give("weapon_px4beretta")
		ply.organism.recoilmul = 1
	end,
	PoliceTime = 220,
	SkillIssue = 4,
	PoliceAllowed = true,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0,1) then
			hg.AddAttachmentForce(ply,gun,"holo16")
		end

		if math.random(0,1) then
			hg.AddAttachmentForce(ply,gun,"laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers_tpik")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")
		
		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
		ply.organism.recoilmul = 0.8

		ply:SetNetVar("CurPluv", "pluvberet")

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))
	end
}
MODE.Types.wildwest = {
	Chance = 0.05,
	ChanceFunction = function() return (zb.GetWorldSize() < ZBATTLE_BIGMAP) and (zb.ModesChances["wildwest"] or zb.modes["hmcd"].Types.wildwest.Chance) or 0 end,
	LootTable = MODE.LootTableStandard,
	Messages = {
		[3] = "The dead silence fills the empty city...",
		[1] = "The town has fallen into the hands of crime.",
		[0] = "The law was settled once again. The bastard is",
	},
	Message = "The criminal was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_sogknife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		local revolver = ply:Give(math.random(2) == 2 and "weapon_musket" or "weapon_revolver2")
		ply:GiveAmmo(revolver:GetMaxClip1() * 1,revolver:GetPrimaryAmmoType(),true)
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_hg_molotov_tpik")
		ply:Give("weapon_hg_smokenade_tpik")

		ply.organism.recoilmul = 1.0
		ply.organism.stamina.range = 220

		ply:SetNetVar("CurPluv", "pluvfancy")

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)
	end,
    /*local tMdl = APmodule.PlayerModels[1][tbl.AModel] or APmodule.PlayerModels[2][tbl.AModel] or tbl.AModel
    ply:SetModel(istable(tMdl) and tMdl.mdl or tMdl)

    local clr = tbl.AColor
    if ply.SetPlayerColor then
        ply:SetPlayerColor(Vector(clr.r / 255,clr.g / 255,clr.b / 255))
    end
    ply:SetNWVector( "PlayerColor", Vector(clr.r / 255,clr.g / 255,clr.b / 255) )

    ply:SetSubMaterial()

    local mats = ply:GetMaterials()
    if istable(tMdl) then
        for k, v in pairs(tMdl.submatSlots) do
            local slot = 1
            for i = 1, #mats do
                if mats[i] == v then slot = i-1 break end
            end
            ply:SetSubMaterial(slot, hg.Appearance.Clothes[tMdl.sex and 2 or 1][tbl.AClothes[k]] )*/

	GunManLoot = function(ply)
		for k,v in player.Iterator() do
			timer.Simple(1,function()
				local Appearance = v:GetNetVar("Accessories",{"none"})
				if istable(Appearance) then
					Appearance[1] = "stetson"
				else
					Appearance = "stetson"
				end
				v:SetNetVar("Accessories", Appearance)
				local sex = ThatPlyIsFemale(v) and 2 or 1
				local tbl = v.CurAppearance
				tbl.AClothes["main"] = "formal"
				tbl.AClothes["pants"] = "formal"
				tbl.AClothes["boots"] = "formal"
				tbl.AColor = Color(1 * 255,0.690196 * 255,0.537255 * 255)
				hg.Appearance.ForceApplyAppearance(v,tbl)
				--v:SetSubMaterial(table.Flip(v:GetMaterials())[hg.Appearance.FuckYouModels[sex][v:GetModel()].submatSlots.main] - 1, hg.Appearance.Clothes[sex]["formal"])
				--v:SetPlayerColor(Vector(1,0.690196,0.537255))
			end)
			if v.isTraitor then continue end
			if v.isGunner then
				v:Give("weapon_musket")
				v:Give("weapon_revolver357")
				v:Give("weapon_handcuffs")
				v:Give("weapon_handcuffs_key")
			else
				local guns = {
					"weapon_musket",
					"weapon_revolver2",
				}

				local weapon = v:Give(guns[math.random(#guns)], true)
				weapon:SetClip1(weapon:GetMaxClip1())
			end

			v:SetNetVar("CurPluv", "pluvfancy")

			local inv = v:GetNetVar("Inventory")
			inv["Weapons"] = inv["Weapons"] or {}
			inv["Weapons"]["hg_sling"] = true
			v:SetNetVar("Inventory",inv)
		end
	end,
	PoliceTime = 220,
	PoliceAllowed = false,
	SkillIssue = 3,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0,1) then
			hg.AddAttachmentForce(ply,gun,"holo16")
		end

		if math.random(0,1) then
			hg.AddAttachmentForce(ply,gun,"laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers_tpik")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")

		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)

		ply:SetNetVar("CurPluv", "pluvberet")

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))
	end
}

MODE.Types.gunfreezone = {
	Chance = 0.05,
	ChanceFunction = function() return (zb.GetWorldSize() < ZBATTLE_BIGMAP) and (zb.ModesChances["gunfreezone"] or zb.modes["hmcd"].Types.gunfreezone.Chance) or 0 end,
	LootTable = MODE.LootTableStandard,
	Messages = {
		[3] = "Everyone died.",
		[1] = "The Executioner has eliminated everyone.",
		[0] = "The Executioner was",
	},
	Message = "The Executioner was ",
	TraitorLoot = function(ply)
		ply:Give("weapon_buck200knife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_shuriken")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison1")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply:Give("weapon_traitor_suit")

		local wep = ply:Give("weapon_zoraki")
		timer.Simple(1,function() wep:ApplyAmmoChanges(2) end)

		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
	end,
	PoliceTime = 120,
	PoliceAllowed = true,
	SkillIssue = 4,
	PoliceEquipment = function(ply)
		ply:SetPlayerClass("police")
		local glock = ply:Give("weapon_glock17")
		ply:GiveAmmo(glock:GetMaxClip1() * 3,glock:GetPrimaryAmmoType(),true)
		if math.random(0,1) then
			hg.AddAttachmentForce(ply,glock,"holo16")
		end

		if math.random(0,1) then
			hg.AddAttachmentForce(ply,glock,"laser3")
		end

		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_naloxone")
		ply:Give("weapon_painkillers_tpik")
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
		ply:Give("weapon_hg_tonfa")

		local gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

		hg.AddArmor(ply, {"vest2"})

		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon( hands )

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
		ply.organism.recoilmul = 0.8

		zb.GiveRole(ply, "Police Officer", Color(15,15,255))

		ply:SetNetVar("CurPluv", "pluvberet")
	end
}

MODE.Types.soe = {
	Chance = 0.2,
	ChanceFunction = function() return (zb.GetWorldSize() >= ZBATTLE_BIGMAP) and (zb.ModesChances["soe"] or zb.modes["hmcd"].Types.soe.Chance) or 0 end,
	LootTable = MODE.LootTable,
	Messages = {
		[3] = "Everyone died.",
		[1] = "The traitor has killed everyone.",
		[0] = "The traitor was",
	},
	Message = "The traitor was ",
	TraitorLoot = function(ply)
		local p22 = ply:Give("weapon_p22")
		hg.AddAttachmentForce(ply,p22,"supressor4")
		ply:Give("weapon_sogknife")
		ply:Give("weapon_hg_type59_tpik")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_adrenaline")
		ply:Give("weapon_hg_smokenade_tpik")
		ply:Give("weapon_traitor_ied")
		ply:Give("weapon_traitor_poison2")
		ply:Give("weapon_traitor_poison3")
		ply:Give("weapon_traitor_poison_consumable")
		ply.organism.recoilmul = 1
		ply.organism.stamina.range = 220

		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_flashlight"] = true
		ply:SetNetVar("Inventory",inv)
	end,
	GunManLoot = function(ply)
		local gun = ply:Give("weapon_kar98")
		ply.organism.recoilmul = 1.0
		if gun:GetClass() == "weapon_kar98" then
			hg.AddAttachmentForce(ply,gun,"optic12")
		end
		local inv = ply:GetNetVar("Inventory")
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory",inv)

		ply:SetNetVar("CurPluv", "pluvboss")
	end,
	PoliceTime = 250,
	PoliceAllowed = true,
	SkillIssue = 3,
	PoliceEquipment = function(ply)
		local inv = ply:GetNetVar("Inventory") or {}
		inv["Weapons"] = inv["Weapons"] or {}
		inv["Weapons"]["hg_flashlight"] = true
		inv["Weapons"]["hg_sling"] = true
		ply:SetNetVar("Inventory", inv)
	
		ply:SetPlayerClass("nationalguard")
		local gun = ply:Give("weapon_fn45")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	
		gun = ply:Give("weapon_hk416")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
		hg.AddAttachmentForce(ply, gun, {"holo14", "laser3", "grip3"})
	
		ply:Give("weapon_hg_grenade_tpik")
		ply:Give("weapon_combatknife")
	
		ply:Give("weapon_medkit_sh")
		ply:Give("weapon_bandage_sh")
		ply:Give("weapon_walkie_talkie")
		ply:Give("weapon_painkillers_tpik")
		ply:Give("weapon_morphine")
	
		ply.organism.recoilmul = 0.5
	
		ply:Give("weapon_handcuffs")
		ply:Give("weapon_handcuffs_key")
	
		gun = ply:Give("weapon_taser")
		ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	
		hg.AddArmor(ply, {"vest4", "helmet1"})
	
		local hands = ply:Give("weapon_hands_sh")
		ply:SetActiveWeapon(hands)
	
		zb.GiveRole(ply, "National Guard", Color(55, 85, 0))
		ply:SetNetVar("CurPluv", "pluvberet")
	end,
	PoliceText = "National guards have arrived.",
	PoliceSound = "snd_jack_hmcd_heli2.mp3"
}

MODE.Types.suicidelunatic = {
	PrintName = "Suicide Lunatic",
	Description = "One executioner carries a hidden suicide bomb. Everyone wears the Allah accessory.",
	Chance = 0.009,
	ChanceFunction = function() return zb.ModesChances["suicidelunatic"] or zb.modes["hmcd"].Types.suicidelunatic.Chance end,
	LootTable = MODE.LootTableStandard,
	Messages = {
		[3] = "The blast left nothing behind.",
		[1] = "The lunatic took everyone with him.",
		[0] = "The lunatic was",
	},
	Message = "The lunatic was ",
	TraitorLoot = function(ply)
		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ply:Give("weapon_hg_ritual")
		ply:Give("weapon_apb")
		local iedController = ply:Give("weapon_traitor_ied")
		ply:Give("weapon_hg_pipebomb_tpik")
		ply:Give("weapon_hg_eft_rgn")
		ply:Give("weapon_adrenaline")
		ply.organism.stamina.range = 220

		local wep = ply:Give("weapon_traitor_c4")
		if not IsValid(wep) or not IsValid(iedController) then return end
		ply.HMCD_IEDController = iedController

		timer.Simple(0.5, function()
			if not IsValid(ply) or not ply:Alive() or not IsValid(iedController) or iedController:GetPlanted() then return end

			local charge = ents.Create("prop_physics")
			if not IsValid(charge) then return end

			charge:SetModel("models/saraphines/insurgency explosives/ied/insurgency_ied.mdl")
			charge:SetPos(ply:WorldSpaceCenter() + ply:GetForward() * 8)
			charge:SetAngles(ply:EyeAngles())
			charge:SetModelScale(0.8, 0)
			charge:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			charge:Spawn()
			charge:Activate()
			charge:SetOwner(ply)
			charge:SetNoDraw(true)
			charge:DrawShadow(false)
			charge:SetNotSolid(true)
			charge:SetParent(ply)
			charge:SetLocalPos(Vector(8, 0, 0))
			charge:SetLocalAngles(Angle(0, 90, 90))
			charge:SetMoveType(MOVETYPE_NONE)

			if not iedController:RegisterExternalIEDBomb(charge) then
				charge:Remove()
				return
			end

			ply.HMCD_BombCharge = charge

			ply:ChatPrint("You are the Suicide Lunatic! A bomb is strapped to you. Run into a crowd and detonate it with LMB.")
		end)
	end,
	GunManLoot = function(ply)
		ply:StripWeapons()
		ply:RemoveAllAmmo()
		ply.armors = {}
		if ply.SyncArmor then ply:SyncArmor() end

		if hg and hg.AddArmor then
			hg.AddArmor(ply, {"ent_armor_vest1", "ent_armor_helmet6"})
		end

		local weapon = ply:Give("weapon_vpo136")
		if IsValid(weapon) then
			timer.Simple(0, function()
				if not IsValid(ply) or not ply:Alive() or not IsValid(weapon) then return end

				local ammoType = weapon:GetPrimaryAmmoType()
				weapon:SetClip1(math.min(10, weapon:GetMaxClip1()))
				if ammoType >= 0 then ply:GiveAmmo(10, ammoType, true) end
			end)
		end

		ply.organism.recoilmul = 1
	end,
	PoliceTime = 220,
	SkillIssue = 4,
	PoliceAllowed = false,
}

MODE.Types = {
	standard = MODE.Types.standard,
	suicidelunatic = MODE.Types.suicidelunatic,
}

local modes = {
	"standard",
	"suicidelunatic",
}

util.AddNetworkString("HMCD_RoundStart")
util.AddNetworkString("HMCD_SetNextTraitorRole")

MODE.NextRoundTraitorRoles = MODE.NextRoundTraitorRoles or {}

net.Receive("HMCD_SetNextTraitorRole", function(_, ply)
	if not IsValid(ply) or not ply:IsSuperAdmin() then return end

	local target = net.ReadEntity()
	local role = net.ReadString()
	if not IsValid(target) or not target:IsPlayer() then return end
	if role ~= "traitor" and role ~= "assistant" then return end

	MODE.NextRoundTraitorRoles[target:SteamID()] = role
	ply:ChatPrint(target:Nick() .. " will be " .. (role == "traitor" and "traitor" or "traitor assistant") .. " next round.")
end)

function MODE:GetPlySpawn(ply)
end

function MODE:SubModes()
	return modes
end

local function GetHomicideTraitorCount(player_count)
	if player_count < 2 then return 0 end

	local traitors_needed = 1 + math.min(math.floor(player_count / 10), 2)

	return math.max(0, math.min(player_count - 1, traitors_needed))
end

function MODE:Intermission()
	game.CleanUpMap()

	local _, CROUND = CurrentRound()

	if CROUND == "hmcd" then
		local subtypeChances = {}
		local totalChance = 0

		for _, subtype in ipairs(modes) do
			local chance = math.max(0, zb.GetChance(subtype) or 0)
			subtypeChances[subtype] = chance
			totalChance = totalChance + chance
		end

		CROUND = totalChance > 0 and zb.WeightedChanceMode(subtypeChances) or "standard"
	elseif not table.HasValue(modes, CROUND) then
		CROUND = "standard"
	end

	self.Type = CROUND
	local player_count = 0

	for k, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		ply:KillSilent()

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil

		ply:SetupTeam(0)

		ply.organism.recoilmul = DefaultSkillIssue
		player_count = player_count + 1
	end

	MODE.TraitorFrequency = nil
	MODE.TraitorWord = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	MODE.TraitorWordSecond = MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]

	local traitors_needed = self.Type == "suicidelunatic" and math.min(player_count, 1) or GetHomicideTraitorCount(player_count)
	local main_traitor = nil
	local traitors = {}
	local forced_main
	local forced_assistants = {}

	for _, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end

		local forced_role = MODE.NextRoundTraitorRoles and MODE.NextRoundTraitorRoles[ply:SteamID()]
		if forced_role == "traitor" and not IsValid(forced_main) then
			forced_main = ply
		elseif forced_role == "assistant" and #forced_assistants < 2 then
			forced_assistants[#forced_assistants + 1] = ply
		end
	end

	local max_traitors = self.Type == "suicidelunatic" and player_count or player_count - 1
	traitors_needed = math.min(max_traitors, math.max(traitors_needed, #forced_assistants + (IsValid(forced_main) and 1 or (#forced_assistants > 0 and 1 or 0))))
	MODE.TraitorExpectedAmt = traitors_needed

	if IsValid(forced_main) and traitors_needed > 0 then
		forced_main.isTraitor = true
		forced_main.MainTraitor = true
		main_traitor = forced_main
		traitors_needed = traitors_needed - 1
		traitors[#traitors + 1] = forced_main
	end

	for _, ply in ipairs(forced_assistants) do
		if traitors_needed <= 0 then break end
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

		ply.isTraitor = true
		traitors_needed = traitors_needed - 1
		traitors[#traitors + 1] = ply
	end

	MODE.NextRoundTraitorRoles = {}

	-- local players = {}
	-- for i, ply in player.Iterator() do
	-- 	if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

	-- 	players[#players + 1] = {ply, ply.Karma}
	-- end
	
	-- -- potom
	
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		if math.random(100) > (ply.Karma or 100) then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply

			if not main_traitor then
				main_traitor = ply
				ply.MainTraitor = true
			end
		end
	end

	//MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}
	for i, ply in RandomPairs(player.GetAll()) do
		if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end
		//if not MODE.NextRoundMainTraitors[ply:SteamID()] then continue end

		if traitors_needed > 0 then
			ply.isTraitor = true
			traitors_needed = traitors_needed - 1
			traitors[#traitors + 1] = ply
			
			if not main_traitor then
				main_traitor = ply
				ply.MainTraitor = true
			end
		end
	end

	if traitors_needed > 0 then
		for i, ply in RandomPairs(player.GetAll()) do
			if ply.isTraitor or ply:Team() == TEAM_SPECTATOR then continue end

			if traitors_needed > 0 then
				ply.isTraitor = true
				traitors_needed = traitors_needed - 1
				traitors[#traitors + 1] = ply

				if not main_traitor then
					main_traitor = ply
					ply.MainTraitor = true
				end
			end
		end
	end

	self.saved.PoliceTime = CurTime() + math.min(self.Types[self.Type].PoliceTime * (#player.GetAll() / 4),self.Types[self.Type].PoliceTime * 2.2)
	self.PoliceSpawned = false
	self.PoliceAllowed = self.Types[self.Type].PoliceAllowed

	for k, ply in player.Iterator() do
		if(MODE.ShouldStartRoleRound())then
			net.Start("HMCD_RoundStart")	--; TODO Structure description
				net.WriteBool(ply.isTraitor)	--; Is Traitor
				net.WriteBool(ply.isGunner)	--; Is Gunner
				net.WriteString(self.Type)	--; Round Type
				net.WriteBool(false)	--; Round Started
				net.WriteString("")	--; SubRole
				net.WriteBool(ply.MainTraitor == true)	--; MainTraitor

				if(ply.isTraitor)then
					net.WriteString(MODE.TraitorWord)
					net.WriteString(MODE.TraitorWordSecond)
					net.WriteUInt(MODE.TraitorExpectedAmt, MODE.TraitorExpectedAmtBits)
				else
					net.WriteString("")
					net.WriteString("")
					net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
				end
				
				net.WriteString("")	--; Profession
			net.Send(ply)

			local role = self.Roles[self.Type][(ply.isTraitor and "traitor") or (ply.isGunner and "gunner") or "innocent"]

			zb.GiveRole(ply, role.name, role.color)
		end
	end

	--local pts = zb.GetMapPoints( "RandomSpawns" )
	
	local ent = ents.Create("prop_ragdoll")
	local appearance = hg.Appearance.GetRandomAppearance()
	
	local tMdl = hg.Appearance.PlayerModels[1][appearance.AModel] or hg.Appearance.PlayerModels[2][appearance.AModel] or appearance.AModel
	local mdl = istable(tMdl) and tMdl.mdl or tMdl
	
	ent:SetModel(mdl)
	
	for i, ply in RandomPairs(player.GetAll()) do
		ent:SetPos(ply:EyePos() + vector_up * 72)
	end

	--[[local forced = false
	local cntr = 32
	for i, point in RandomPairs(pts) do
		cntr = cntr - 1
		if cntr < 0 then forced = true end

		local pos = point.pos
		local tr = {}
		tr.start = pos
		tr.endpos = pos
		tr.mins = Vector(-16, -16, 0)
		tr.maxs = Vector(16, 16, 16)
		tr.collisiongroup = COLLISION_GROUP_WORLD

		local trace = util.TraceHull(tr)
		if !trace.Hit or forced then
			ent:SetPos(pos)
			
			break
		end
	end--]]

	ent:SetAngles(AngleRand(-180, 180))
	ent:Spawn()
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	hg.organism.Add(ent)
	hg.organism.Clear(ent.organism)
	ent.organism.fakePlayer = true
	hg.Appearance.ForceApplyAppearance(ent, appearance)
	ent.organism.alive = false
	ent.organism.o2[1] = 0
	ent.organism.pulse = 0

	for physNum = 0, ent:GetPhysicsObjectCount() - 1 do
		local phys = ent:GetPhysicsObjectNum(physNum)
		local bone = ent:TranslatePhysBoneToBone(physNum)
		if bone < 0 then continue end
		
		phys:SetMass(hg.IdealMassPlayer[ent:GetBoneName(bone)] or 4)
		phys:SetPos(ent:GetPos() + VectorRand(-32, 32))
	end

	if self.Type == "wildwest" then
		local Appearance = ent:GetNetVar("Accessories", {"none"})

		if istable(Appearance) then
			Appearance[1] = "stetson"
		else
			Appearance = "stetson"
		end
	
		ent:SetNetVar("Accessories", Appearance)
		local sex = ThatPlyIsFemale(ent) and 2 or 1
		local tbl = ent.CurAppearance
		tbl.AClothes["main"] = "formal"
		tbl.AClothes["pants"] = "formal"
		tbl.AClothes["boots"] = "formal"
		tbl.AColor = Color(1 * 255,0.690196 * 255,0.537255 * 255)
		hg.Appearance.ForceApplyAppearance(ent, tbl)

		for i = 1, 5 do
			hg.organism.AddWoundManual(ent, 50, vector_origin, angle_zero,"ValveBiped.Bip01_Head1", CurTime() + 2)
		end
	end
end

--[[concommand.Add("hmcd_call_police", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("loh.")
        return
    end

    if not MODE or not MODE.saved then
        print("fake")
        return
    end

    MODE.saved.PoliceTime = CurTime() - 1
    print("true")
end)--]]

function MODE:CheckAlivePlayers()
	local AlivePlyTbl = {
		[0] = {},
		[1] = {}
	}
	
	for _, ply in player.Iterator() do
		if(not ply:Alive())then
			continue
		end
		
		if(ply.organism and ply.organism.incapacitated)then
			continue
		end
		
		if ply.isTraitor and not ply:GetNetVar("handcuffed",false) then
			--print(ply)
			AlivePlyTbl[1][#AlivePlyTbl[1] + 1] = ply
		elseif(not ply.isPolice)then
			AlivePlyTbl[0][#AlivePlyTbl[0] + 1] = ply
		end
	end
	
	return AlivePlyTbl
end
	
local deadPoliceCount = 0
local swatDeployed = false

function MODE:GetActivePlayers()
	local valid = {}

	for _, ply in player.Iterator() do
		if ply:Alive() then continue end                        
		if ply:Team() == TEAM_SPECTATOR then continue end       
		if ply.afkTime2 and ply.afkTime2 > 60 then continue end 

		valid[#valid + 1] = ply
	end

	return valid
end


MODE.deadPoliceCount = MODE.deadPoliceCount or 0
MODE.swatDeployed = MODE.swatDeployed or false
MODE.spawnedPoliceCount = MODE.spawnedPoliceCount or 0
MODE.roundStartType = MODE.roundStartType or nil

function MODE:RoundThink()
	if not self.PoliceAllowed then return end

	if self.Type ~= "soe" and not self.PoliceSpawned and self.saved.PoliceTime < CurTime() then
		if not self.Types[self.Type] or not self.Types[self.Type].PoliceAllowed then return end
		
		local available = self:GetActivePlayers()
		local max = math.min(#available, 4)
	
		if max > 0 then
			local spawned = self:SpawnForce("police", max)
			self.spawnedPoliceCount = spawned
	
			if spawned > 0 then
				self.PoliceSpawned = true
				PrintMessage(HUD_PRINTTALK, "Police have arrived.")
				EmitSound("snd_jack_hmcd_policesiren.wav", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
			end
		end
	end
	

	if self.Type ~= "soe" and not self.swatDeployed and self.deadPoliceCount >= (self.spawnedPoliceCount or 4) and self.spawnedPoliceCount > 0 then
		if not self.Types[self.Type] or not self.Types[self.Type].PoliceAllowed then return end
		
		self.swatDeployed = true
		local currentType = self.Type 
		
		timer.Create("HMCDSpawnSWAT", 60, 1, function()
			if zb.ROUND_STATE ~= 1 or not MODE or MODE.Type ~= currentType then return end 
			
			if not MODE.Types[MODE.Type] or not MODE.Types[MODE.Type].PoliceAllowed then return end
			
			local available = MODE:GetActivePlayers()
			local count = math.min(#available, 5)
	
			if count > 0 then
				PrintMessage(HUD_PRINTTALK, "SWAT team incoming!")
				EmitSound("snd_jack_hmcd_heli2.mp3", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
				MODE:SpawnForce("swat", count)
			end
		end)
	end
	
	if self.Type == "soe" and not self.PoliceSpawned and self.saved.PoliceTime < CurTime() then
		local available = self:GetActivePlayers()
		local count = math.min(#available, 6)
	
		if count > 0 then
			local spawned = self:SpawnForce("nationalguard", count)
			if spawned > 0 then
				self.PoliceSpawned = true
				PrintMessage(HUD_PRINTTALK, self.Types[self.Type].PoliceText or "National Guard have arrived.")
				EmitSound(self.Types[self.Type].PoliceSound or "snd_jack_hmcd_heli2.mp3", vector_origin, 0, CHAN_AUTO, 1, 125, 0, 100)
			end
		end
	end
end

function MODE:SpawnForce(teamtype, count)
    local spawned = 0
    local basepos = nil

    for i, ply in RandomPairs(player.GetAll()) do
        if ply:Alive() or ply.isTraitor or ply:Team() == TEAM_SPECTATOR or ply.afkTime2 > 60 then continue end
        if spawned >= count then break end

        ply.isPolice = true
        ply.isTraitor = false
        ply.isGunner = false
        ply:Spawn()

        if not basepos then
            basepos = zb:GetRandomSpawn()            
			ply:SetPos(basepos)
		else
			hg.tpPlayer(basepos, ply, i)
		end

        if teamtype == "police" then
            self.Types[self.Type].PoliceEquipment(ply)
        elseif teamtype == "swat" then
            self:EquipSWAT(ply, spawned + 1)
        elseif teamtype == "nationalguard" then
            self:EquipNationalGuard(ply, spawned + 1)
        end

        spawned = spawned + 1
    end

    return spawned
end

local function tbl_Random(tbl) -- when you can't even say
	return tbl[math.random(#tbl)] -- my name
end
function MODE:EquipSWAT(ply, index)
    ply:SetPlayerClass("swat")
    
    local classes = {
        [1] = function() return tbl_Random({"weapon_m4a1", "weapon_hk416"}) end, --;; Team Leader
        [2] = function() ply:Give("weapon_ram") return tbl_Random({"weapon_m590a1"}) end, --;; Breacher
        [3] = function() return "weapon_mp5" end, --;; Pointman
        [4] = function() return "weapon_sr25" end, --;; Marksman
        [5] = function()
            ply:Give("weapon_medkit_sh")
            ply:Give("weapon_painkillers_tpik")
            ply:Give("weapon_adrenaline")
            ply:Give("weapon_needle")
            ply:Give("weapon_bigbandage_sh")
            ply:Give("weapon_bandage_sh")
            ply:Give("weapon_mannitol")
            return "weapon_m4a1"
        end
    }

    local mainWep = classes[index] and classes[index]() or "weapon_m4a1"
    local pistol = ply:Give("weapon_glock17")
	ply:GiveAmmo(pistol:GetMaxClip1() * 3, pistol:GetPrimaryAmmoType(), true)
    local gun = ply:Give(mainWep)
    ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)

    ply:Give("weapon_combatknife")
    ply:Give("weapon_handcuffs")
    ply:Give("weapon_handcuffs_key")
    ply:Give("weapon_hg_flashbang_tpik")

	local gun = ply:Give("weapon_taser")
	ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(),true)

	hg.AddArmor(ply, {"helmet6", "vest8", tbl_Random({"mask1", "mask2", "nightvision1"})})

    local inv = ply:GetNetVar("Inventory") or {}
    inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_sling"] = true
    inv["Weapons"]["hg_flashlight"] = true
    ply:SetNetVar("Inventory", inv)
	ply:SetNetVar("flashlight", false)

    ply.organism.recoilmul = 0.6

    ply:SetNetVar("CurPluv", "pluvberet")
    local hands = ply:Give("weapon_hands_sh")
    ply:SetActiveWeapon(hands)

    zb.GiveRole(ply, "SWAT Operative", Color(30, 30, 100))
end

function MODE:EquipNationalGuard(ply, index)
    ply:SetPlayerClass("nationalguard")
    local gun

    if index == 1 then
        gun = ply:Give("weapon_m249")
    else
        gun = ply:Give("weapon_m4a1")
    end

    ply:GiveAmmo(gun:GetMaxClip1() * 3, gun:GetPrimaryAmmoType(), true)
	local pistol = ply:Give("weapon_m9beretta")
	ply:GiveAmmo(pistol:GetMaxClip1() * 3, pistol:GetPrimaryAmmoType(), true)
    ply:Give("weapon_combatknife")
    ply:Give("weapon_handcuffs")
    ply:Give("weapon_handcuffs_key")
    ply:Give("weapon_walkie_talkie")
    ply:Give("weapon_bandage_sh")
    ply:Give("weapon_medkit_sh")

	local gun = ply:Give("weapon_taser")
	ply:GiveAmmo(gun:GetMaxClip1() * 3,gun:GetPrimaryAmmoType(),true)

    hg.AddArmor(ply, {"vest4", "helmet1"})

	local inv = ply:GetNetVar("Inventory") or {}
	inv["Weapons"] = inv["Weapons"] or {}
	inv["Weapons"]["hg_flashlight"] = true
	inv["Weapons"]["hg_sling"] = true
	ply:SetNetVar("Inventory", inv)

	ply:SetNetVar("CurPluv", "pluvberet")
    local hands = ply:Give("weapon_hands_sh")
    ply:SetActiveWeapon(hands)
    zb.GiveRole(ply, "National Guard", Color(60, 90, 0))
end

--\\
MODE.ChoosingPlayersList = MODE.ChoosingPlayersList or {}

local gaymaps = {
	["zs_shelter"] = true,
	["gm_sirenmine_v2"] = true,
}

function MODE.StartPlayersRoleSelection()
	MODE.RoleChooseRound = true
	MODE.StartRoundTime = MODE.StartRoundTime + MODE.RoleChooseRoundStartTime

	for _, ply in player.Iterator() do
		if(ply.isTraitor and ply.MainTraitor)then	--; REDO
			net.Start("HMCD(StartPlayersRoleSelection)")
				net.WriteString("Traitor")
			net.Send(ply)

			MODE.ChoosingPlayersList[ply] = true
		end
	end
end

net.Receive("HMCD(StartPlayersRoleSelection)", function(len, ply)
	if(MODE.ChoosingPlayersList[ply])then
		MODE.ChoosingPlayersList[ply] = nil

		if(table.IsEmpty(MODE.ChoosingPlayersList))then
			MODE.StartRoundTime = 0
		end
	end
end)
// ...


util.AddNetworkString("HMCD_TraitorDeathState")
util.AddNetworkString("HMCD_RequestTraitorStatuses")


function MODE:SendTraitorDeathState(traitor, is_alive)
    if not traitor.CurAppearance then return end
    local name = traitor.CurAppearance.AName
    

    local recipients = {}
    for _, ply in player.Iterator() do
        if ply.isTraitor then
            table.insert(recipients, ply)
        end
    end
    
    net.Start("HMCD_TraitorDeathState")
    net.WriteString(name)
    net.WriteBool(is_alive)
    net.Send(recipients)
end


hook.Add("PlayerDeath", "HMCD_TraitorDeathTracking", function(ply, _)
    if ply.isTraitor then
        MODE:SendTraitorDeathState(ply, false)
    end
end)


hook.Add("PlayerSpawn", "HMCD_TraitorSpawnTracking", function(ply)
    if ply.isTraitor then
        MODE:SendTraitorDeathState(ply, true)
    end
end)

hook.Add("PlayerCanPickupWeapon", "HMCD_TraitorRadioPickup", function( ply, weapon )
    if ply.isTraitor and weapon:GetClass() == "weapon_walkie_talkie" then
        if ply:HasWeapon("weapon_walkie_talkie") then
            weapon:Remove()
			ply:SetActiveWeapon("weapon_walkie_talkie")
			ply:ChatPrint("You hide the additional walkie talkie.")
        end
    end
end)

net.Receive("HMCD_RequestTraitorStatuses", function(len, ply)
    if not ply.isTraitor then return end
    

    for _, other_ply in player.Iterator() do
        if other_ply.isTraitor and other_ply.CurAppearance then
            local is_alive = other_ply:Alive() and (not other_ply.organism or not other_ply.organism.incapacitated)
            
            net.Start("HMCD_TraitorDeathState")
            net.WriteString(other_ply.CurAppearance.AName)
            net.WriteBool(is_alive)
            net.Send(ply)
        end
    end
end)
// ...

function MODE.ShouldStartRoleRound()
	do return false end
	return MODE.RoleChooseRoundTypes[MODE.Type] and GetGlobalBool("RolesPlus_Enable", false)
end
--//

function MODE:ShouldRoundEnd()
	if(MODE.StartRoundTime and not MODE.RoleChooseRound and CurTime() - MODE.StartRoundTime < 10)then
		return false
	end

	if(MODE.StartRoundTime and MODE.RoleChooseRound)then
		if(MODE.StartRoundTime > CurTime())then
			return false
		else
			MODE.StartRoundTime = nil

			net.Start("HMCD(EndPlayersRoleSelection)")
			net.Broadcast()
			MODE.SpawnPlayers(true)
		end
	else
		local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

		if(endround)then
			MODE.ChoosingPlayersList = {}
		end

		return endround
	end
end

function MODE:RoundStart()
	local roles_choose = MODE.ShouldStartRoleRound()
	MODE.StartRoundTime = CurTime()
	MODE.RoleChooseRound = false

	MODE.TraitorWord = MODE.TraitorWord or MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	MODE.TraitorWordSecond = MODE.TraitorWordSecond or MODE.TraitorWords[math.random(1, #MODE.TraitorWords)]
	

	self.roundStartType = self.Type
	

	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	

	timer.Remove("HMCDSpawnSWAT")
	
	if(roles_choose)then
		MODE.StartPlayersRoleSelection()
		PrintMessage(HUD_PRINTTALK, "Traitor is choosing roles for " .. MODE.RoleChooseRoundStartTime ..  " seconds")
	else
		MODE.ChoosingPlayersList = {}

		MODE.SpawnPlayers(true)
	end
end

function MODE:GiveEquipment()
end

function MODE:CanSpawn()
end

util.AddNetworkString("hmcd_roundend")

function MODE:EndRound()
	timer.Remove("HMCDSpawnSWAT")
	timer.Remove("SpawnAdditionalPolice")
    timer.Remove("SpawnAdditionalNationalGuard")
	

	self.deadPoliceCount = 0
	self.swatDeployed = false
	self.spawnedPoliceCount = 0
	self.roundStartType = nil

	local traitors, gunners = {}, {}
	local players_alive = 0
	local endround, winner = zb:CheckWinner(self:CheckAlivePlayers())

	-- for _, ply in player.Iterator() do	--; Extreme optimization
		-- ply.SubRole = nil
	-- end

	for i, ply in player.Iterator() do
		if ply.isTraitor and ply:Team() ~= TEAM_SPECTATOR then
			traitors[#traitors + 1] = ply
		end
		
		if ply.isGunner and ply:Team() ~= TEAM_SPECTATOR then
			gunners[#gunners + 1] = ply
		end
		
		if(ply:Alive() and ply.organism and !ply.organism.incapacitated)then
			players_alive = players_alive + 1
		end

		ply.isPolice = false
		ply.isTraitor = false
		ply.isGunner = false
		ply.MainTraitor = false
		ply.SubRole = nil
		ply.Profession = nil
	end
	
	if(not winner)then
		net.Start("hmcd_roundend")
			net.WriteUInt(#traitors, MODE.TraitorExpectedAmtBits)
			
			for _, traitor in ipairs(traitors) do
				net.WriteEntity(traitor)
			end
			
			net.WriteUInt(#gunners, MODE.TraitorExpectedAmtBits)
			
			for _, gunner in ipairs(gunners) do
				net.WriteEntity(gunner)
			end
		net.Broadcast()
		
		return
	end

	if self.Type then
		if(MODE.RoleChooseRound)then
			if(winner ~= 1)then
				PrintMessage(HUD_PRINTTALK, "All traitors were stopped.")
				
				for _, traitor in ipairs(traitors) do
					net.Start("hmcd_announce_traitor_lose")
						net.WriteEntity(traitor)
						net.WriteBool(traitor:Alive())
					net.Broadcast()
					
					hook.Run("ZB_TraitorWinOrNot", traitor, winner)
				end

				for _, traitor in ipairs(traitors) do
					traitor:GiveSkill( -math.Rand(0.05,0.15) )
				end
			else
				for _, traitor in ipairs(traitors) do
					traitor:GiveExp( math.random(25,40) )
					traitor:GiveSkill( math.Rand(0.1,0.3) )
					traitor:SetPData("zb_hmcd_t_wins",traitor:GetPData("zb_hmcd_t_wins",0) + 1)
					hook.Run("ZB_TraitorWinOrNot", traitor, winner)
				end
				PrintMessage(HUD_PRINTTALK, "Every innocent was murdered.")
			end
			
			timer.Simple(2, function()
				if(players_alive == 0)then
					PrintMessage(HUD_PRINTTALK, "No one survived.")
				else
					if(players_alive == 1)then
						PrintMessage(HUD_PRINTTALK, "Only 1 survivor left in the city.")
					else
						PrintMessage(HUD_PRINTTALK, players_alive .. " survivors left in the city.")
					end
				end
			end)
		else
			if traitor and IsValid(traitor) then
				--local CheckAlive = #self:CheckAlivePlayers()[1]
				PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Messages[winner]..(winner == 0 and (traitor:Alive() and " neutralized." or " killed.") or ""))
				
				timer.Simple(2, function()
					PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Message..traitor:Name())
				end)

				if winner == 1 then
					traitor:GiveExp( math.Rand(30,50) )
					traitor:GiveSkill( math.Rand(0.15,0.3) )
					traitor:SetPData("zb_hmcd_t_wins",traitor:GetPData("zb_hmcd_t_wins",0) + 1)
				else
					traitor:GiveSkill( -math.Rand(0.05,0.1) )
				end
				
				hook.Run("ZB_TraitorWinOrNot", traitor, winner)
			else
				PrintMessage(HUD_PRINTTALK, self.Types[self.Type].Messages[winner]..(winner == 0 and (" killed.") or ""))
				for _, traitor in ipairs(traitors) do
					net.Start("hmcd_announce_traitor_lose")
						net.WriteEntity(traitor)
						net.WriteBool(traitor:Alive())
					net.Broadcast()

					hook.Run("ZB_TraitorWinOrNot", traitor, winner)
				end
			end
		end
	end

	timer.Simple(2,function()
		net.Start("hmcd_roundend")
			net.WriteUInt(#traitors, MODE.TraitorExpectedAmtBits)
			
			for _, traitor in ipairs(traitors) do
				net.WriteEntity(traitor)
			end
			
			net.WriteUInt(#gunners, MODE.TraitorExpectedAmtBits)
			
			for _, gunner in ipairs(gunners) do
				net.WriteEntity(gunner)
			end
		net.Broadcast()
	end)
end

-- hook.Add("Player_Death", "HMCD_PlayerDeath", function(_, ply)
hook.Add("Player_Death", "HMCD_PlayerDeath", function(ply, _)
	local most_harm,biggest_attacker = 0,nil
	local last_attacker = nil

	if ply.isPolice then
		MODE.deadPoliceCount = (MODE.deadPoliceCount or 0) + 1
	end

	timer.Simple(.1,function()
		for attacker,attacker_harm in pairs(zb.HarmDone[ply] or {}) do
			if not IsValid(attacker) then continue end
			if most_harm < attacker_harm then
				most_harm = attacker_harm
				biggest_attacker = attacker:Name()
				last_attacker = attacker
			end
		end
		

		if ply.isTraitor then
			--local Appearance = ply.CurAppearance
			--
			--if(!Appearance)then
			--	-- Appearance = GetRandomAppearance(ply)
			--	PrintMessage(HUD_PRINTTALK, "Some traitor died.")
			--else
			--	local character_name = Appearance.AName or "error"
			--	
			--	PrintMessage(HUD_PRINTTALK, "Traitor " .. character_name .. " died.")
			--end
		
			if biggest_attacker then
				if biggest_attacker == ply:Name() then
					--timer.Simple(1,function()
					--	if not IsValid(ply) then return end
					--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e suicided."
					--	PrintMessage(3,msg)
					--end)
				else
					last_attacker:GiveExp( math.random(10,15) )
					last_attacker:GiveSkill( math.Rand(0.025,0.075) )
					last_attacker:SetPData("zb_hmcd_ino_t_kills", last_attacker:GetPData("zb_hmcd_ino_t_kills",0) + 1)
					--timer.Simple(1,function()
					--	if not IsValid(ply) then return end
					--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e was killed by "..biggest_attacker.."."
					--	PrintMessage(3,msg)
					--end)
				end
			else
				--timer.Simple(1,function()
				--	if not IsValid(ply) then return end
				--	local msg = (ThatPlyIsFemale(ply) and "Sh" or "H").."e died in mysterious circumstances."
				--	PrintMessage(3,msg)
				--end)
			end
		else
			if not biggest_attacker or not IsValid(ply) then return end
			
			if biggest_attacker == ply:Name() then
				ply:ChatPrint("You suicided.")
			elseif not biggest_attacker then
				ply:ChatPrint("You have died.")
			else
				ply:ChatPrint("You were killed by "..biggest_attacker..".")
			end
		end
	end)
end)

function MODE:CanLaunch()
	return true
end

util.AddNetworkString("hmcd_roundend")

MODE.NextRoundMainTraitors = MODE.NextRoundMainTraitors or {}

concommand.Add("hmcd_request_main_traitor", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    

    if zb.ROUND_STATE == 1 then
        ply:ChatPrint("when round end")
        return
    end
    

    MODE.NextRoundMainTraitors[ply:SteamID()] = true
    ply:ChatPrint("true")
end)

hook.Add("RoundStateChange", "ResetNextRoundMainTraitors", function(old, new)
    if new == 2 then 
        MODE.NextRoundMainTraitors = {}
    end
end)

util.AddNetworkString("HMCD_UpdateTraitorAssistants")

local TraitorAssistantStarterItems = {
	"weapon_painkillers_tpik",
	"weapon_taser",
	"weapon_hammer",
	"weapon_ducttape",
	"weapon_bigbandage_sh",
	"weapon_bandage_sh",
	"weapon_pocketknife",
}

local function GiveTraitorAssistantStarterItem(ply)
	local item = TraitorAssistantStarterItems[math.random(#TraitorAssistantStarterItems)]
	ply:Give(item)

	if item == "weapon_taser" and ply:HasWeapon(item) then
		local taser = ply:GetWeapon(item)
		if IsValid(taser) and taser:GetPrimaryAmmoType() >= 0 then
			ply:GiveAmmo(taser:GetMaxClip1(), taser:GetPrimaryAmmoType(), true)
		end
	end
end

local function GetTraitorAssociatesFor(ply)
	local traitor_associates = {}

	for _, other_ply in player.Iterator() do
		if other_ply == ply or not other_ply.isTraitor or not other_ply.CurAppearance then continue end

		local appearance = other_ply.CurAppearance
		local color = appearance.AColor or color_white
		local name = appearance.AName or other_ply:Nick()

		if not IsColor(color) then
			color = Color(color.r, color.g, color.b)
		end

		traitor_associates[#traitor_associates + 1] = {color, name, other_ply, other_ply:GetModel() or "", table.Copy(appearance), other_ply.PlayerClassName or ""}
	end

	return traitor_associates
end

function MODE.SpawnPlayers(spawn_with_subroles)
    local gunner_found = false

    for i, ply in RandomPairs(player.GetAll()) do
        if ply.isTraitor or ply.isGunner or ply:Team() == TEAM_SPECTATOR then continue end
        if math.random(100) > (ply.Karma or 100) then continue end

        ply.isGunner = true
        gunner_found = true
        break
    end

    if(not gunner_found)then
        for i,ply in RandomPairs(player.GetAll()) do
            if ply.isTraitor or ply.isGunner or ply:Team() == TEAM_SPECTATOR then continue end

            ply.isGunner = true
            break
        end
    end

    local player_count = 0
    for i, ply in player.Iterator() do
        if(ply:Team() != TEAM_SPECTATOR)then
            player_count = player_count + 1
        end
    end

    --= Профессии
    local professions = {}
    if(spawn_with_subroles and MODE.ProfessionsRoundTypes[MODE.Type] and MODE.ProfessionsPool)then
        local professions_possible_pre = MODE.ProfessionsPool

        if(professions_possible_pre)then
            local professions_possible = {}
            local professions_count_to_satisfy = math.ceil(player_count / 2)

            for profession, profession_info in pairs(professions_possible_pre) do
                professions_possible[#professions_possible + 1] = {profession_info.Chance, profession}
            end

            for _, ply in RandomPairs(player.GetAll()) do
                if(ply:Team() != TEAM_SPECTATOR)then
                    if((math.random(100) <= (ply.Karma or 100)) and (math.random(1, 3) == 1 or (!ply.isTraitor and !ply.isGunner)))then
                        local profession_key, profession = hg.WeightedRandomSelect(professions_possible)
                        professions_possible[profession_key][1] = professions_possible[profession_key][1] / 2
                        ply.Profession = profession
                        professions_count_to_satisfy = professions_count_to_satisfy - 1
                        
                        if(professions_count_to_satisfy == 0)then
                            break
                        end
                    end
                end
            end
            

            if(professions_count_to_satisfy > 0)then
                for _, ply in RandomPairs(player.GetAll()) do
                    if(ply:Team() != TEAM_SPECTATOR and !ply.Profession)then
                        local profession_key, profession = hg.WeightedRandomSelect(professions_possible)
                        professions_possible[profession_key][1] = professions_possible[profession_key][1] / 2
                        ply.Profession = profession
                        professions_count_to_satisfy = professions_count_to_satisfy - 1
                        
                        if(professions_count_to_satisfy == 0)then
                            break
                        end
                    end
                end
            end
        end
    end


    local all_players = player.GetAll()
    for idx, current_ply in player.Iterator() do
        if(current_ply:Team() != TEAM_SPECTATOR)then
            current_ply.SubRole = nil

            ApplyAppearance(current_ply,nil,nil,nil,true)
            current_ply:Spawn()
            current_ply:GetRandomSpawn()

            if(!current_ply:Alive())then
                continue
            end

            current_ply:SetSuppressPickupNotices(true)
            current_ply.noSound = true

            if(MODE.Type == "supermario")then
                MODE.Types.supermario.CustomJump(current_ply)
            end

            if(MODE.Type == "suicidelunatic")then
				local appearance = table.Copy(current_ply.CurAppearance or {})
				local oldAccessories = appearance.AAttachments or {}
				local accessories = {}

				for i = 1, 6 do
					accessories[i] = oldAccessories[i] or "none"
				end

				for i = 1, 6 do
					local accessory = hg.Accessories and hg.Accessories[accessories[i]]
					if i ~= 5 and (accessories[i] == "Allah" or (accessory and accessory.placement == "face2")) then
						accessories[i] = "none"
					end
				end

				accessories[5] = "Allah"
				appearance.AAttachments = accessories

				if hg.Appearance and hg.Appearance.ForceApplyAppearance and current_ply.CurAppearance then
					hg.Appearance.ForceApplyAppearance(current_ply, appearance, true)
				else
					current_ply:SetNetVar("Accessories", accessories)
				end
            end

            local sub_role = nil
            if(spawn_with_subroles and MODE.RoleChooseRoundTypes[MODE.Type])then
                if(current_ply.isTraitor)then
                    local sub_role_id = current_ply:GetInfo(MODE.ConVarName_SubRole_Traitor) or "traitor_custom"
					sub_role = sub_role_id
                end

                if(current_ply.isGunner)then
                    if MODE.ApplyHeroLoadout then
                        MODE.ApplyHeroLoadout(current_ply)
                    else
                        MODE.Types[MODE.Type].GunManLoot(current_ply)
                    end
                end

                if(sub_role)then
                    if(current_ply.isGunner)then

                    elseif(current_ply.isTraitor)then
                        local role_info = MODE.SubRoles[sub_role]
                        if(!role_info or !MODE.RoleChooseRoundTypes[MODE.Type].Traitor[sub_role])then
                            sub_role = MODE.RoleChooseRoundTypes[MODE.Type].TraitorDefaultRole or "traitor_custom"
                            role_info = MODE.SubRoles[sub_role]
                        end

                        if(current_ply.MainTraitor)then
                            local spawn_func = role_info.SpawnFunction
                            current_ply.SubRole = sub_role
                            spawn_func(current_ply)
                        end
                    end
                end
            else
                if(current_ply.isTraitor and current_ply.MainTraitor)then
                    MODE.Types[MODE.Type].TraitorLoot(current_ply)
                end

                if(current_ply.isGunner)then
                    MODE.Types[MODE.Type].GunManLoot(current_ply)
                end
            end
            
            if(MODE.Type == "soe")then
                if(current_ply.isTraitor)then
                    local walkie_talkie = current_ply:Give("weapon_walkie_talkie")
					if walkie_talkie.Frequencies then
						MODE.TraitorFrequency = MODE.TraitorFrequency or math.random(1, #walkie_talkie.Frequencies)
						walkie_talkie.Frequency = MODE.TraitorFrequency
						current_ply:ChatPrint("Walkie-Talkie Frequency = " .. walkie_talkie.Frequencies[MODE.TraitorFrequency])
					end
                end
            end

            if(gaymaps[game.GetMap()])then
                local inv = current_ply:GetNetVar("Inventory") or {}
                inv["Weapons"] = inv["Weapons"] or {}
                inv["Weapons"]["hg_flashlight"] = true
                current_ply:SetNetVar("Inventory", inv)
            end

			if current_ply.isTraitor and not current_ply.MainTraitor then
				GiveTraitorAssistantStarterItem(current_ply)
			end

			if current_ply.isTraitor then
				local giveActivator = current_ply.MainTraitor
				if not giveActivator then
					local chanceConvar = GetConVar("ttt_activator_assistant_chance")
					local chance = chanceConvar and chanceConvar:GetFloat() or 0
					giveActivator = chance > 0 and math.random() <= chance
				end
				if giveActivator then
					local activator = current_ply:Give("weapon_ttt_activator")
					if IsValid(activator) then
						local startConvar = GetConVar("ttt_activator_start_points")
						current_ply:SetNWInt("ttt_activator_points", startConvar and startConvar:GetInt() or 30)
						local maxConvar = GetConVar("ttt_activator_max_points")
						current_ply:SetNWInt("ttt_activator_max_points", maxConvar and maxConvar:GetInt() or 30)
					end
				end
			end

            if current_ply.Profession then
                local profession_info = MODE.Professions[current_ply.Profession]
                if profession_info and profession_info.SpawnFunction then
                    profession_info.SpawnFunction(current_ply)
                end
            end

            local hands = current_ply:Give("weapon_hands_sh")
            current_ply:SetActiveWeapon(hands)
            current_ply:SetNetVar("flashlight", false)

            local this_player = current_ply
            
            timer.Simple(0.1, function() 
                if IsValid(this_player) then
                    this_player.noSound = false
                    this_player:SetSuppressPickupNotices(false)
                end
            end)

            timer.Simple(0.2 * idx, function()
                if not IsValid(this_player) then return end

                local traitor_amt = 0
                local traitor_associates = {}
                
                if (this_player.isTraitor) then
                    for _, other_ply in player.Iterator() do
                        if (other_ply.isTraitor) then
                            traitor_amt = traitor_amt + 1
                        end
                    end

					traitor_associates = GetTraitorAssociatesFor(this_player)
                end
                

                net.Start("HMCD_RoundStart")
                    net.WriteBool(this_player.isTraitor)
                    net.WriteBool(this_player.isGunner)
                    net.WriteString(MODE.Type)
                    net.WriteBool(true)
                    net.WriteString(this_player.SubRole or "")
                    net.WriteBool(this_player.MainTraitor == true)
                    
                    if (this_player.isTraitor) then
                        net.WriteString(MODE.TraitorWord)
                        net.WriteString(MODE.TraitorWordSecond)
                        net.WriteUInt(traitor_amt, MODE.TraitorExpectedAmtBits)
						net.WriteUInt(math.min(#traitor_associates, 15), 4)

						for i = 1, math.min(#traitor_associates, 15) do
							local traitor_info = traitor_associates[i]
							net.WriteColor(traitor_info[1], false)
							net.WriteString(traitor_info[2])
							net.WriteEntity(traitor_info[3])
							net.WriteString(traitor_info[4])
							net.WriteTable(traitor_info[5])
							net.WriteString(traitor_info[6])
						end
                    else
                        net.WriteString("")
                        net.WriteString("")
                        net.WriteUInt(0, MODE.TraitorExpectedAmtBits)
                    end
                    
                    timer.Simple(0.5, function()
                        if IsValid(this_player) and this_player.isTraitor then
                            net.Start("HMCD_UpdateTraitorAssistants")
                                net.WriteUInt(#traitor_associates, 8)
                                
                                for _, info in ipairs(traitor_associates) do
                                    net.WriteColor(info[1])
                                    net.WriteString(info[2])
									net.WriteString(IsValid(info[3]) and (info[3]:SteamID() or "") or "")
                                end
                            net.Send(this_player)
                        end
                    end)
                    
                    net.WriteString(this_player.Profession or "")
                net.Send(this_player)
                
                local role = MODE.Roles[MODE.Type][(this_player.isTraitor and "traitor") or (this_player.isGunner and "gunner") or "innocent"]
                if role then
                    zb.GiveRole(this_player, role.name, role.color)
                end
            end)
        end
    end
end

hook.Add("PlayerSpawn", "HMCD_UpdateTraitorsList", function(ply)
	if not ply.isTraitor then return end
	
	timer.Simple(0.5, function()
		for _, traitor_ply in player.Iterator() do
			if IsValid(traitor_ply) and traitor_ply.isTraitor then
				local traitor_assistants = {}
				
				for _, other_ply in player.Iterator() do
					if other_ply.isTraitor and other_ply ~= traitor_ply then
						local Appearance = other_ply.CurAppearance
						if Appearance then
							local color = Appearance.AColor or color_white
							local name = Appearance.AName or "error"
							local steamID = other_ply:SteamID() or ""
							
							if not IsColor(color) then
								color = Color(color.r, color.g, color.b)
							end
							
							table.insert(traitor_assistants, {color, name, steamID})
						end
					end
				end
				
				net.Start("HMCD_UpdateTraitorAssistants")
				net.WriteUInt(#traitor_assistants, 8)
				
				for _, info in ipairs(traitor_assistants) do
					net.WriteColor(info[1])
					net.WriteString(info[2])
					net.WriteString(info[3])
				end
				
				net.Send(traitor_ply)
			end
		end
	end)
end)

hook.Add("PlayerDeath", "HMCD_UpdateTraitorsList", function(ply)
	if not ply.isTraitor then return end
	
	timer.Simple(0.1, function()
		if IsValid(ply) and ply.CurAppearance then
			MODE:SendTraitorDeathState(ply, false)
		end
		
		timer.Simple(0.4, function()
			for _, traitor_ply in player.Iterator() do
				if IsValid(traitor_ply) and traitor_ply.isTraitor then
					local traitor_assistants = {}
					
					for _, other_ply in player.Iterator() do
						if other_ply.isTraitor and other_ply ~= traitor_ply then
							local Appearance = other_ply.CurAppearance
							if Appearance then
								local color = Appearance.AColor or color_white
								local name = Appearance.AName or "error"
								local steamID = other_ply:SteamID() or ""
								
								if not IsColor(color) then
									color = Color(color.r, color.g, color.b)
								end
								
								table.insert(traitor_assistants, {color, name, steamID})
							end
						end
					end
					
					net.Start("HMCD_UpdateTraitorAssistants")
					net.WriteUInt(#traitor_assistants, 8)
					
					for _, info in ipairs(traitor_assistants) do
						net.WriteColor(info[1])
						net.WriteString(info[2])
						net.WriteString(info[3])
					end
					
					net.Send(traitor_ply)
				end
			end
		end)
	end)
end)

hook.Add("PlayerDeath", "HMCD_SuicideLunaticDetonate", function(ply)
	if not IsValid(ply) or not ply.isTraitor then return end
	if MODE.Type ~= "suicidelunatic" then return end

	local iedController = ply.HMCD_IEDController
	if IsValid(iedController) and iedController.DetonateExternalIED then
		ply.HMCD_BombCharge = nil
		ply.HMCD_IEDController = nil
		iedController:DetonateExternalIED()
	end
end)
