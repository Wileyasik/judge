hg = hg or {}
hg.ConVars = hg.ConVars or {}

function hg.GetCurrentCharacter(ply)
	if not IsValid(ply) then return end
	return (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
end

local legacyWeaponClasses = {
	weapon_thiamine = "weapon_thiamine_tpik",
	weapon_painkillers = "weapon_painkillers_tpik",
	weapon_betablock = "weapon_betablock_tpik",
}

function hg.CanonicalWeaponClass(class)
	return legacyWeaponClasses[class] or class
end

function hg.MigrateLegacyWeaponInventory(inventory)
	local weapons = istable(inventory) and inventory.Weapons
	if not istable(weapons) then return false end

	local changed = false
	for oldClass, newClass in pairs(legacyWeaponClasses) do
		if weapons[oldClass] ~= nil then
			if weapons[newClass] == nil then weapons[newClass] = weapons[oldClass] end
			weapons[oldClass] = nil
			changed = true
		end
	end

	return changed
end

DEFAULT_JUMP_POWER = 200

function hg.CalculateWeight(ply, maxweight)
	local weight = 0

	local weps = ply:GetWeapons()
	for i, wep in ipairs(weps) do
		weight = weight + (wep.weight or 1)
	end

	weight = math.max(weight - 1, 0)

	local ammo = ply:GetAmmo()
	for id, count in pairs(ammo) do
		weight = weight + (game.GetAmmoForce(id) * count) / 1500
	end

	ply.armors = ply:GetNetVar("Armor", {})
	for plc, arm in pairs(ply.armors) do
		if hg.armor[plc] and hg.armor[plc][arm] then
			weight = weight + (hg.armor[plc][arm].mass or 1)
		end
	end

	local weightmul = (1 / (weight / maxweight + 1))
	return weightmul
end

hg.IdealMassPlayer = {
	["ValveBiped.Bip01_Pelvis"] = 12.775918006897,
	["ValveBiped.Bip01_Spine1"] = 24.36336517334,
	["ValveBiped.Bip01_Spine2"] = 24.36336517334,
	["ValveBiped.Bip01_R_UpperArm"] = 3.4941370487213,
	["ValveBiped.Bip01_L_UpperArm"] = 3.441034078598,
	["ValveBiped.Bip01_L_Forearm"] = 1.7655730247498,
	["ValveBiped.Bip01_L_Hand"] = 1.0779889822006,
	["ValveBiped.Bip01_R_Forearm"] = 1.7567429542542,
	["ValveBiped.Bip01_R_Hand"] = 1.0214320421219,
	["ValveBiped.Bip01_R_Thigh"] = 10.212161064148,
	["ValveBiped.Bip01_R_Calf"] = 4.9580898284912,
	["ValveBiped.Bip01_Head1"] = 5.169750213623,
	["ValveBiped.Bip01_L_Thigh"] = 10.213202476501,
	["ValveBiped.Bip01_L_Calf"] = 4.9809679985046,
	["ValveBiped.Bip01_L_Foot"] = 2.3848159313202,
	["ValveBiped.Bip01_R_Foot"] = 2.3848159313202
}
