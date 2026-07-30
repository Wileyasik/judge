local MODE = MODE

MODE.name = "brawl"
MODE.PrintName = "Brawl"
MODE.Description = "Free-for-all melee progression. Get kills to unlock new melee and win with the final weapon."
MODE.Chance = 0.04
MODE.randomSpawns = true
MODE.DefaultStageCount = 16

MODE.DefaultWeaponPool = {
    "weapon_leadpipe",
    "weapon_hammer",
    "weapon_pocketknife",
    "weapon_pan",
    "weapon_hg_shovel",
    "weapon_bat",
    "weapon_batmetal",
    "weapon_hg_axe",
    "weapon_hg_cleaver",
    "weapon_hg_crowbar",
    "weapon_hg_machete",
    "weapon_hg_sledgehammer",
    "weapon_hg_spear",
    "weapon_hg_spear_pro",
    "weapon_tomahawk",
    "weapon_fireaxe",
    "weapon_hatchet",
    "weapon_golfclub",
    "weapon_barbedbat",
    "weapon_kitchenknife",
    "weapon_dagger",
    "weapon_hg_tonfa",
    "weapon_hg_stunstick",
    "weapon_hg_bottlebroken",
    "weapon_hg_spear_knife",
    "weapon_hg_slayersword"
}

MODE.FinalWeaponDefault = "weapon_brawl_revolver357"
MODE.FinalWeaponFallback = "weapon_revolver357"

function MODE:GetWeaponPool()
    local pool = {}
    local seen = {}

    for _, class in ipairs(self.DefaultWeaponPool) do
        if not seen[class] and weapons.GetStored(class) then
            seen[class] = true
            pool[#pool + 1] = class
        end
    end

    return pool
end

function MODE:GetFinalWeapon()
    if weapons.GetStored(self.FinalWeaponDefault) then
        return self.FinalWeaponDefault, false
    end

    if weapons.GetStored(self.FinalWeaponFallback) then
        return self.FinalWeaponFallback, true
    end

    return nil, true
end
