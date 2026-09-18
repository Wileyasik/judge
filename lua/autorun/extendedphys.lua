--[[
    Extended & Restored Physics Sounds
    Featuring:
    - Unique impact sounds for certain props
    - Restored strain, shake, and roll sounds
    - Overrides certain props' properties to be more logical
    - Custom break sounds for certain props that lack them
    - Custom sounds when NPCs or players are killed by props or vehicles
    - Special sawblade / trap-propeller sounds
    - Energy dissolve, fire ignite, and extinguish sounds

    All features are toggleable and configurable via the spawnmenu Options tab.
    Settings are intended for server owners / administrators.
]]

---------------------------------------------------------------------------
-- ConVars
---------------------------------------------------------------------------

local function CreatePhysFXConVar(name, default, help)
    return CreateConVar(name, tostring(default), FCVAR_ARCHIVE + FCVAR_REPLICATED + FCVAR_NOTIFY, help)
end

local CV = {
    impacts = CreatePhysFXConVar("physfx_enable_impacts",          "1", "Enable custom impact sounds"),
    strain = CreatePhysFXConVar("physfx_enable_strain",           "1", "Enable strain sounds"),
    shake = CreatePhysFXConVar("physfx_enable_shake",            "1", "Enable shake sounds"),
    roll = CreatePhysFXConVar("physfx_enable_roll",             "1", "Enable roll sounds"),
    surfaces = CreatePhysFXConVar("physfx_enable_surfaces",         "1", "Enable surface-property overrides"),
    mattpipe = CreatePhysFXConVar("physfx_enable_mattpipe",         "1", "Enable funny"),
    cardboard_shake = CreatePhysFXConVar("physfx_enable_cardboard_shake",  "1", "Enable shake sounds for cardboard boxes"),
    health_sounds = CreatePhysFXConVar("physfx_enable_health_sounds",    "1", "Enable custom health kit/vial impact and shake sounds"),
    slosh_roll = CreatePhysFXConVar("physfx_enable_slosh_roll",       "1", "Enable liquid slosh layer while explosive barrels roll"),
    ["break"] = CreatePhysFXConVar("physfx_enable_break",            "1", "Enable custom break sounds"),
    paint_splash = CreatePhysFXConVar("physfx_enable_paint_splash",     "1", "Enable paint can splash sounds"),
    phys_kill = CreatePhysFXConVar("physfx_enable_phys_kill",        "1", "Enable physics damage/kill sounds"),
    sawblade = CreatePhysFXConVar("physfx_enable_sawblade",         "1", "Enable gravity-gun sawblade/propeller spin, ricochet, stuck, and pickup sounds"),
    dissolve = CreatePhysFXConVar("physfx_enable_dissolve",         "1", "Enable entity dissolve sounds"),
    ignite = CreatePhysFXConVar("physfx_enable_ignite",           "1", "Enable entity ignite/extinguish sounds"),
    min_impact_speed = CreatePhysFXConVar("physfx_min_impact_speed",      180,   "Minimum speed for impact sounds"),
    hard_impact_speed = CreatePhysFXConVar("physfx_hard_impact_speed",     380,   "Speed threshold for hard impact sounds"),
    impact_cooldown = CreatePhysFXConVar("physfx_impact_cooldown",       0.12,  "Cooldown between impact sounds"),
    strain_duration = CreatePhysFXConVar("physfx_strain_duration",       0.9,   "Strain sound cooldown"),
    strain_buildup = CreatePhysFXConVar("physfx_strain_buildup",        0.35,  "Sustained contact time a prop counts as being strained"),
    strain_cooldown = CreatePhysFXConVar("physfx_strain_cooldown",       0.12,  "Heavy strain sound cooldown"),
    max_concurrent_strain = CreatePhysFXConVar("physfx_max_concurrent_strain", 4,     "Maximum strain sounds that can play at once"),
    high_vel_strain = CreatePhysFXConVar("physfx_high_vel_strain",       1000,  "Heavy strain threshold"),
    min_metal_mass = CreatePhysFXConVar("physfx_min_metal_mass",        35,   "Minimum prop mass for metal straining sounds to play"),
    shake_cooldown = CreatePhysFXConVar("physfx_shake_cooldown",        0.09,  "Shake sound cooldown"),
    shake_min_jerk = CreatePhysFXConVar("physfx_shake_min_jerk",        400,   "Minimum force for shake sounds"),
    shake_min_jerk_barrel = CreatePhysFXConVar("physfx_shake_min_jerk_barrel", 525,   "Minimum force for barrel shake sounds"),
    orbit_limit = CreatePhysFXConVar("physfx_orbit_limit",           6,     "How many samples to take in order to prevent shake sounds playing when spinning a prop around yourself"),
    max_concurrent_shake = CreatePhysFXConVar("physfx_max_concurrent_shake",  5,     "Maximum shake sounds that can play at once"),
    mattpipe_chance = CreatePhysFXConVar("physfx_mattpipe_chance",       0.0025,"Funny chance"),
    health_impact_vol = CreatePhysFXConVar("physfx_health_impact_vol",     0.22,  "Custom healthkit/vial impact volume"),
    health_shake_base = CreatePhysFXConVar("physfx_health_shake_base",     0.10,  "Custom healthkit/vial shake volume"),
    health_shake_scale = CreatePhysFXConVar("physfx_health_shake_scale",    0.22,  "How much custom healthkit/vial shake sounds should scale in volume from velocity"),
}

---------------------------------------------------------------------------
-- "Sounds Replaced With My Voice" Workshop addon (2036162332) path prefixing
---------------------------------------------------------------------------

local HAS_MYVOICE = false
do
    local ok, addons = pcall(engine.GetAddons)
    if ok and istable(addons) then
        for _, addon in ipairs(addons) do
            -- Only when subscribed AND enabled (mounted).
            if tostring(addon.wsid or "") == "2036162332" and addon.mounted then
                HAS_MYVOICE = true
                break
            end
        end
    end
end

if HAS_MYVOICE then
    print('[Extended Physics Sounds] "My Voice" mod detected and enabled, swapping sound sets')
end

local function MV(path)
    if not HAS_MYVOICE or not isstring(path) then return path end
    if string.sub(path, 1, 11) == "npc/strider" then return path end
    if string.sub(path, 1, 8) == "myvoice/" then return path end
    if not string.find(path, "/", 1, true) then return path end
    if string.find(path, "physics/items/health_", 1, true) then return path end
    if path == "physics/metal/metalpipe.wav" then return path end
    return "myvoice/" .. path
end

local function MVTable(tbl)
    if not HAS_MYVOICE or not istable(tbl) then return tbl end
    for k, v in pairs(tbl) do
        if isstring(v) then
            tbl[k] = MV(v)
        elseif istable(v) then
            MVTable(v)
        end
    end
    return tbl
end

---------------------------------------------------------------------------
-- Surface overrides
---------------------------------------------------------------------------

local SURFACE_OVERRIDES = {
    ["item_rpg_round"]           = "Metal_Box",
    ["item_ammo_crossbow"]       = "Metal",
    ["item_box_buckshot"]        = "Cardboard",
    ["item_ammo_357"]            = "Cardboard",
    ["item_ammo_357_large"]      = "Cardboard",
    ["item_ammo_pistol"]         = "Metal",
    ["item_ammo_pistol_large"]   = "Metal",
    ["item_ammo_smg1"]           = "Metal",
    ["item_ammo_smg1_large"]     = "Metal",
}

local MODEL_OVERRIDES = {
    ["models/weapons/w_missile_launch.mdl"]     = "Metal_Box",
    ["models/weapons/w_missile.mdl"]            = "Metal_Box",
    ["models/weapons/w_missile_closed.mdl"]     = "Metal_Box",
    ["models/items/crossbowrounds.mdl"]         = "Metal",
    ["models/items/boxbuckshot.mdl"]            = "Cardboard",
    ["models/items/357ammo.mdl"]                = "Cardboard",
    ["models/items/boxsrounds.mdl"]             = "Metal",
    ["models/items/boxmrounds.mdl"]             = "Metal",
    ["models/props_canal/mattpipe.mdl"]         = "Crowbar",
    ["models/weapons/w_suitcase_passenger.mdl"] = "Wood_Furniture",
    ["models/weapons/w_package.mdl"]            = "Flesh",
    ["models/props_junk/propane_tank001a.mdl"]  = "canister",
    ["models/gibs/fast_zombie_torso.mdl"]       = "Zombieflesh",
    ["models/gibs/fast_zombie_legs.mdl"]        = "Zombieflesh",
    ["models/props_wasteland/prison_sink001a.mdl"] = "porcelain",
    ["models/props_wasteland/prison_sink001b.mdl"] = "porcelain",
    ["models/props_c17/furnituresink001a.mdl"]     = "porcelain",
    ["models/props_combine/breenbust.mdl"]         = "concrete",
    ["models/gibs/hgibs.mdl"]                        = "gmod_silent",
    ["models/gibs/hgibs_rib.mdl"]                    = "gmod_silent",
    ["models/gibs/hgibs_scapula.mdl"]                = "gmod_silent",
    ["models/gibs/hgibs_spine.mdl"]                  = "gmod_silent",
    ["models/player/skeleton.mdl"]                  = "gmod_silent",
    ["models/skeleton/skeleton_arm.mdl"]            = "gmod_silent",
    ["models/skeleton/skeleton_arm_l.mdl"]          = "gmod_silent",
    ["models/skeleton/skeleton_arm_l_noskins.mdl"]  = "gmod_silent",
    ["models/skeleton/skeleton_arm_noskins.mdl"]    = "gmod_silent",
    ["models/skeleton/skeleton_leg.mdl"]            = "gmod_silent",
    ["models/skeleton/skeleton_leg_l.mdl"]          = "gmod_silent",
    ["models/skeleton/skeleton_leg_l_noskins.mdl"]  = "gmod_silent",
    ["models/skeleton/skeleton_leg_noskins.mdl"]    = "gmod_silent",
    ["models/skeleton/skeleton_torso.mdl"]          = "gmod_silent",
    ["models/skeleton/skeleton_torso2.mdl"]         = "gmod_silent",
    ["models/skeleton/skeleton_torso2_noskins.mdl"] = "gmod_silent",
    ["models/skeleton/skeleton_torso3.mdl"]         = "gmod_silent",
    ["models/skeleton/skeleton_torso3_noskins.mdl"] = "gmod_silent",
    ["models/skeleton/skeleton_torso_noskins.mdl"]  = "gmod_silent",
    ["models/skeleton/skeleton_whole.mdl"]          = "gmod_silent",
    ["models/skeleton/skeleton_whole_noskins.mdl"]  = "gmod_silent",
    ["models/bots/skeleton_sniper/skeleton_sniper.mdl"]           = "gmod_silent",
    ["models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl"] = "gmod_silent",
}

local GRENADE_SOURCE_SURFACES = {
    ["weapon"] = true, ["metal"] = true, ["plastic"] = true,
    ["item"] = true, ["plastic_box"] = true,
}

-- Apply surface material once the physics object(s) exist.
-- Map-spawned and many mod-spawned props often receive a valid PhysicsObject
-- after the first OnEntityCreated / InitPostEntity pass; retry briefly so
-- overrides are not silently skipped.
local function ApplySurface(ent, surfaceName, attemptsLeft)
    if not IsValid(ent) or not surfaceName then return end
    attemptsLeft = attemptsLeft or 8

    local applied = false
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMaterial(surfaceName)
        applied = true
    end

    if ent:GetClass() == "prop_ragdoll" then
        local count = ent:GetPhysicsObjectCount() or 0
        if count > 0 then
            for i = 0, count - 1 do
                local bonePhys = ent:GetPhysicsObjectNum(i)
                if IsValid(bonePhys) then
                    bonePhys:SetMaterial(surfaceName)
                    applied = true
                end
            end
        end
    end

    if applied then return end

    -- Physics not ready yet (common for map/mod props). Retry a few times.
    if attemptsLeft > 1 then
        timer.Simple(0.05, function()
            ApplySurface(ent, surfaceName, attemptsLeft - 1)
        end)
    end
end

---------------------------------------------------------------------------
-- Realistic Leaking Barrels detection + model lists
---------------------------------------------------------------------------
-- Detect via workshop mount status (same pattern as HAS_MYVOICE).
-- ConVarExists alone is unreliable: autorun load order means those cvars
-- often do not exist yet when this file runs, so non-explosive oil drums
-- never receive slosh impact/shake/roll sounds.

local HAS_LEAKING_BARRELS = false
do
    local ok, addons = pcall(engine.GetAddons)
    if ok and istable(addons) then
        for _, addon in ipairs(addons) do
            -- Only when subscribed AND enabled (mounted).
            if tostring(addon.wsid or "") == "2896381916" and addon.mounted then
                HAS_LEAKING_BARRELS = true
                break
            end
        end
    end
    -- Fallback if GetAddons fails or the addon registers its cvars early.
    if not HAS_LEAKING_BARRELS then
        HAS_LEAKING_BARRELS = ConVarExists("real_barrels_drainchance")
                            or ConVarExists("real_barrels_firelife")
                            or ConVarExists("real_barrels_fullchance")
                            or ConVarExists("real_barrels_leaktime")
    end
end

if HAS_LEAKING_BARRELS then
    print("[Extended Physics Sounds] Realistic Leaking Barrels detected and mounted — enabling barrel slosh sounds")
end

---------------------------------------------------------------------------
-- Realistic Breaking Crates detection (same pattern as leaking barrels)
---------------------------------------------------------------------------
local HAS_BREAKING_CRATES = false
do
    local ok, addons = pcall(engine.GetAddons)
    if ok and istable(addons) then
        for _, addon in ipairs(addons) do
            if tostring(addon.wsid or "") == "2899507067" and addon.mounted then
                HAS_BREAKING_CRATES = true
                break
            end
        end
    end
    if not HAS_BREAKING_CRATES then
        HAS_BREAKING_CRATES = ConVarExists("real_crates_fadetime")
                            or ConVarExists("real_crates_fullchance")
                            or ConVarExists("real_crates_maxgibs")
                            or ConVarExists("real_crates_useCustomProps")
    end
end

if HAS_BREAKING_CRATES then
    print("[Extended Physics Sounds] Realistic Breaking Crates detected and mounted — enabling crate supplycrate shake/impact sounds")
end

local ALWAYS_EXPLOSIVE_BARREL = {
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
}

local LEAKING_ONLY_MODELS = {
    ["models/props_c17/oildrum001.mdl"]                              = "explosive_barrel",
    ["models/props_phx/facepunch_barrel.mdl"]                        = "explosive_barrel",
    ["models/props_phx/oildrum001.mdl"]                              = "explosive_barrel",
    ["models/betaprops/arctic/barrel.mdl"]                           = "explosive_barrel",
    ["models/betaprops/city17/small_barrel.mdl"]                     = "explosive_barrel",
    ["models/props_c17/barrel01a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel02a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel03a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel04a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel05a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel06a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel07a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel08a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel09a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel10a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel11a.mdl"]                               = "explosive_barrel",
    ["models/props_c17/barrel12a.mdl"]                               = "explosive_barrel",
    ["models/props_blackmesa/barrel01.mdl"]                          = "explosive_barrel",
    ["models/props_junk/metalgascan.mdl"]                            = "gascan",
    ["models/biohazard/oildrum001_explosive.mdl"]                    = "explosive_barrel",
    ["models/bnb_ebarrel/bnb_ebarrel.mdl"]                           = "explosive_barrel",
    ["models/bnb_oildrum/bnb_oildrum001_explosive.mdl"]              = "explosive_barrel",
    ["models/bnb_oildrum002_explosive/bnb_oildrum002_explosive.mdl"] = "explosive_barrel",
    ["models/ebarrel/ebarrel.mdl"]                                   = "explosive_barrel",
    ["models/jessev92/fear/props/barrel_explosive.mdl"]              = "explosive_barrel",
    ["models/lantlers/cubedrum.mdl"]                                 = "explosive_barrel",
    ["models/oildrum/oildrum001_explosive.mdl"]                      = "explosive_barrel",
    ["models/predatorcz/starshiptroopers/props/explosives/bio_barrel.mdl"]   = "explosive_barrel",
    ["models/predatorcz/starshiptroopers/props/explosives/flame_barrel.mdl"] = "explosive_barrel",
    ["models/props_blackmesa/barrel01_explosive.mdl"]                = "explosive_barrel",
    ["models/props_brl/oildrum001_explosive.mdl"]                    = "explosive_barrel",
    ["models/props_c17/oildrumzg_flammable.mdl"]                     = "explosive_barrel",
    ["models/props_dcr/oildrum001_explosive.mdl"]                    = "explosive_barrel",
    ["models/swarmprops/barrelsandcrates/swarm_toxicbarrelmesh.mdl"] = "explosive_barrel",
    ["models/props_c17/oildrum001b_dynamic.mdl"]                     = "explosive_barrel",
    ["models/props_c17/oildrum002_explosive.mdl"]                    = "explosive_barrel",
}

-- Wood crates that get supplycrate sounds when Realistic Breaking Crates is mounted (no ammo overlays, pitch -10)
local BREAKING_CRATE_MODELS = {
    ["models/props_junk/wood_crate001a.mdl"]              = true,
    ["models/props_junk/wood_crate001a_damaged.mdl"]      = true,
    ["models/props_junk/wood_crate001b.mdl"]              = true,
    ["models/props_junk/wood_crate002a.mdl"]              = true,
    ["models/props_junk/wood_crate003a.mdl"]              = true,
    ["models/props_blackmesa/tarp_crate.mdl"]             = true,
    ["models/props_generic/crate_48x48.mdl"]              = true,
    ["models/props_generic/crate_64x96.mdl"]              = true,
    ["models/props_junk/storage_crate01.mdl"]             = true,
    ["models/props_junk/wood_crate001a_damaged_old.mdl"]  = true,
    ["models/props_junk/wood_crate002a_old.mdl"]          = true,
}

-- Wood suitcases: always use supplycrate_shake at +10 pitch (no ammo overlays)
local WOOD_SUITCASE_MODELS = {
    ["models/props_c17/suitcase001a.mdl"]                = true,
    ["models/props_c17/suitcase_passenger_physics.mdl"]  = true,
    ["models/weapons/w_suitcase_passenger.mdl"]          = true,
}

-- Cloth briefcases / luggage: suitcase_shake soundset
local CLOTH_SUITCASE_MODELS = {
    ["models/props_c17/BriefCase001a.mdl"]                       = 100,
    ["models/props_unique/airport/luggage1.mdl"]                 = 100,
    ["models/props_unique/airport/luggage1_floating.mdl"]       = 100,
    ["models/props_unique/airport/luggage2.mdl"]                 = 100,
    ["models/props_unique/airport/luggage2_floating.mdl"]       = 100,
    ["models/props_unique/airport/luggage3.mdl"]                 = 100,
    ["models/props_unique/airport/luggage3_floating.mdl"]       = 100,
    ["models/props_unique/airport/luggage4.mdl"]                 = 100,
    ["models/props_unique/airport/luggage4_floating.mdl"]       = 100,
    ["models/props/gg_handling/bh_luggage_rack144_01.mdl"]      = 80,  -- -20
    ["models/props/gg_handling/bh_luggage_rack144_02.mdl"]      = 80,  -- -20
    ["models/props/gg_handling/luggage_stack_01.mdl"]            = 90,  -- -10
    ["models/props/gg_handling/luggage_stack_02.mdl"]            = 90,  -- -10
    ["models/props_unique/airport/luggage_pile1.mdl"]           = 85,  -- -15
}

-- Dumpsters: metal_sodamachine_shake at -25 (or -15 for scrapyard ones)
local DUMPSTER_MODELS = {
    ["models/props_junk/trashdumpster01a.mdl"]                                           = 75,
    ["models/props_frontline/dumpster.mdl"]                                              = 75,
    ["models/props_industrial/dumpsterconstruction01.mdl"]                               = 75,
    ["models/props_junk/dumpster.mdl"]                                                   = 75,
    ["models/props_junk/dumpster_03.mdl"]                                                = 75,
    ["models/props_junk/dumpster_2.mdl"]                                                 = 75,
    ["models/props_lab/scrapyarddumpster.mdl"]                                           = 85,  -- -15
    ["models/props_lab/scrapyarddumpster_static.mdl"]                                    = 85,  -- -15
    ["models/props/de_vertigo/scrapyarddumpster.mdl"]                                    = 85,  -- -15
    ["models/props/de_train/hr_t/dumpster_a/dumpster_a.mdl"]                             = 75,
    ["models/props/de_dust/hr_dust/dust_garbage_container/dust_garbage_container.mdl"]   = 75,
    ["models/props/de_dust/hr_dust/dust_garbage_container/dust_garbage_dumpster.mdl"]    = 75,
    ["models/props_vehicles/airport_baggage_cart2.mdl"]                                  = 75,
}

---------------------------------------------------------------------------
-- Custom impact sounds
---------------------------------------------------------------------------

local CUSTOM_SOUNDS = {
    smg = {
        hard = {
            "physics/items/ammobox_smg_impact_hard1.wav",
            "physics/items/ammobox_smg_impact_hard2.wav",
            "physics/items/ammobox_smg_impact_hard3.wav",
            "physics/items/ammobox_smg_impact_hard4.wav",
            "physics/items/ammobox_smg_impact_hard5.wav",
            "physics/items/ammobox_smg_impact_hard6.wav",
        },
        soft = {
            "physics/items/ammobox_smg_impact_soft1.wav",
            "physics/items/ammobox_smg_impact_soft2.wav",
            "physics/items/ammobox_smg_impact_soft3.wav",
            "physics/items/ammobox_smg_impact_soft4.wav",
            "physics/items/ammobox_smg_impact_soft5.wav",
        },
    },
    pistol = {
        hard = {
            "physics/items/ammobox_pistol_impact_hard1.wav",
            "physics/items/ammobox_pistol_impact_hard2.wav",
            "physics/items/ammobox_pistol_impact_hard3.wav",
        },
        soft = {
            "physics/items/ammobox_pistol_impact_soft1.wav",
            "physics/items/ammobox_pistol_impact_soft2.wav",
            "physics/items/ammobox_pistol_impact_soft3.wav",
        },
    },
    ammo357 = {
        hard = {
            "physics/items/ammobox_357_impact_bullets1.wav",
            "physics/items/ammobox_357_impact_bullets2.wav",
            "physics/items/ammobox_357_impact_bullets3.wav",
            "physics/items/ammobox_357_impact_bullets4.wav",
            "physics/items/ammobox_357_impact_bullets5.wav",
        },
        soft = {
            "physics/items/ammobox_357_impact_bullets1.wav",
            "physics/items/ammobox_357_impact_bullets2.wav",
            "physics/items/ammobox_357_impact_bullets3.wav",
            "physics/items/ammobox_357_impact_bullets4.wav",
            "physics/items/ammobox_357_impact_bullets5.wav",
        },
    },
    shotgun = {
        hard = {
            "physics/items/ammobox_shotgun_impact_hard1.wav",
            "physics/items/ammobox_shotgun_impact_hard2.wav",
        },
        soft = {
            "physics/items/ammobox_shotgun_impact_soft1.wav",
            "physics/items/ammobox_shotgun_impact_soft2.wav",
            "physics/items/ammobox_shotgun_impact_soft3.wav",
        },
    },
    health = {
        hard = {
            "physics/items/health_impact_slosh1.wav",
            "physics/items/health_impact_slosh2.wav",
            "physics/items/health_impact_slosh3.wav",
            "physics/items/health_impact_slosh4.wav",
        },
        soft = {},
    },
    paintcan = {
        hard = {
            "physics/metal/metal_paintcan_shake1.wav",
            "physics/metal/metal_paintcan_shake2.wav",
            "physics/metal/metal_paintcan_shake3.wav",
            "physics/metal/metal_paintcan_shake4.wav",
            "physics/metal/metal_paintcan_shake5.wav",
            "physics/metal/metal_paintcan_shake6.wav",
            "physics/metal/metal_paintcan_shake7.wav",
            "physics/metal/metal_paintcan_shake8.wav",
        },
        soft = {
            "physics/metal/metal_paintcan_shake1.wav",
            "physics/metal/metal_paintcan_shake2.wav",
            "physics/metal/metal_paintcan_shake3.wav",
            "physics/metal/metal_paintcan_shake4.wav",
            "physics/metal/metal_paintcan_shake5.wav",
            "physics/metal/metal_paintcan_shake6.wav",
            "physics/metal/metal_paintcan_shake7.wav",
            "physics/metal/metal_paintcan_shake8.wav",
        },
    },
    explosive_barrel = {
        hard = {
            "physics/metal/metal_barrel_impact_slosh1.wav",
            "physics/metal/metal_barrel_impact_slosh2.wav",
            "physics/metal/metal_barrel_impact_slosh3.wav",
            "physics/metal/metal_barrel_impact_slosh4.wav",
            "physics/metal/metal_barrel_impact_slosh5.wav",
            "physics/metal/metal_barrel_impact_slosh6.wav",
            "physics/metal/metal_barrel_impact_slosh7.wav",
            "physics/metal/metal_barrel_impact_slosh8.wav",
            "physics/metal/metal_barrel_impact_slosh9.wav",
            "physics/metal/metal_barrel_impact_slosh10.wav",
        },
        soft = {
            "physics/metal/metal_barrel_impact_slosh1.wav",
            "physics/metal/metal_barrel_impact_slosh2.wav",
            "physics/metal/metal_barrel_impact_slosh3.wav",
            "physics/metal/metal_barrel_impact_slosh4.wav",
            "physics/metal/metal_barrel_impact_slosh5.wav",
            "physics/metal/metal_barrel_impact_slosh6.wav",
            "physics/metal/metal_barrel_impact_slosh7.wav",
            "physics/metal/metal_barrel_impact_slosh8.wav",
            "physics/metal/metal_barrel_impact_slosh9.wav",
            "physics/metal/metal_barrel_impact_slosh10.wav",
        },
    },
    gascan = {
        hard = {
            "physics/metal/metal_gascan_slosh1.wav",
            "physics/metal/metal_gascan_slosh2.wav",
        },
        soft = {
            "physics/metal/metal_gascan_slosh1.wav",
            "physics/metal/metal_gascan_slosh2.wav",
        },
    },
    supplycrate = {
        hard = {
            "physics/items/supplycrate_shake1.wav",
            "physics/items/supplycrate_shake2.wav",
            "physics/items/supplycrate_shake3.wav",
            "physics/items/supplycrate_shake4.wav",
            "physics/items/supplycrate_shake5.wav",
            "physics/items/supplycrate_shake6.wav",
        },
        soft = {},
    },
    sodamachine = {
        hard = {
            "physics/metal/metal_sodamachine_shake1.wav",
            "physics/metal/metal_sodamachine_shake2.wav",
            "physics/metal/metal_sodamachine_shake3.wav",
            "physics/metal/metal_sodamachine_shake4.wav",
        },
        soft = {},
    },
    -- Crate / wood suitcase share supplycrate sounds (no overlay); dumpster shares sodamachine
    crate = {
        hard = {
            "physics/items/supplycrate_shake1.wav",
            "physics/items/supplycrate_shake2.wav",
            "physics/items/supplycrate_shake3.wav",
            "physics/items/supplycrate_shake4.wav",
            "physics/items/supplycrate_shake5.wav",
            "physics/items/supplycrate_shake6.wav",
        },
        soft = {},
    },
    wood_suitcase = {
        hard = {
            "physics/items/supplycrate_shake1.wav",
            "physics/items/supplycrate_shake2.wav",
            "physics/items/supplycrate_shake3.wav",
            "physics/items/supplycrate_shake4.wav",
            "physics/items/supplycrate_shake5.wav",
            "physics/items/supplycrate_shake6.wav",
        },
        soft = {},
    },
    suitcase = {
        hard = {
            "physics/items/suitcase_shake1.wav",
            "physics/items/suitcase_shake2.wav",
            "physics/items/suitcase_shake3.wav",
            "physics/items/suitcase_shake4.wav",
            "physics/items/suitcase_shake5.wav",
        },
        soft = {},
    },
    dumpster = {
        hard = {
            "physics/metal/metal_sodamachine_shake1.wav",
            "physics/metal/metal_sodamachine_shake2.wav",
            "physics/metal/metal_sodamachine_shake3.wav",
            "physics/metal/metal_sodamachine_shake4.wav",
        },
        soft = {},
    },
    bone = {
        hard = {
            "physics/bone/bone_impact_hard1.wav",
            "physics/bone/bone_impact_hard2.wav",
            "physics/bone/bone_impact_hard3.wav",
        },
        soft = {
            "physics/bone/bone_impact_soft1.wav",
            "physics/bone/bone_impact_soft2.wav",
            "physics/bone/bone_impact_soft3.wav",
        },
        bullet = {
            "physics/bone/bone_impact_bullet1.wav",
            "physics/bone/bone_impact_bullet2.wav",
            "physics/bone/bone_impact_bullet3.wav",
        },
    },
}

local CLASS_TO_SOUND = {
    ["item_ammo_smg1"]         = "smg",
    ["item_ammo_smg1_large"]   = "smg",
    ["item_ammo_pistol"]      = "pistol",
    ["item_ammo_pistol_large"] = "pistol",
    ["item_ammo_357"]          = "ammo357",
    ["item_ammo_357_large"]    = "ammo357",
    ["item_box_buckshot"]      = "shotgun",
    ["item_healthkit"]         = "health",
    ["item_healthvial"]        = "health",
    ["item_item_crate"]        = "supplycrate",
}

local MODEL_TO_SOUND = {
    ["models/items/boxmrounds.mdl"]               = "smg",
    ["models/items/boxsrounds.mdl"]               = "pistol",
    ["models/items/357ammo.mdl"]                  = "ammo357",
    ["models/items/boxbuckshot.mdl"]              = "shotgun",
    ["models/items/healthkit.mdl"]                = "health",
    ["models/healthvial.mdl"]                     = "health",
    ["models/props_c17/oildrum001_explosive.mdl"] = "explosive_barrel",
    ["models/props_phx/oildrum001_explosive.mdl"] = "explosive_barrel",
    ["models/props_junk/gascan001a.mdl"]          = "gascan",
    ["models/props_junk/metal_paintcan001a.mdl"]  = "paintcan",
    ["models/props_junk/metal_paintcan001b.mdl"]  = "paintcan",
    ["models/props_junk/paintcan001a.mdl"]        = "paintcan",
    ["models/items/item_item_crate.mdl"]          = "supplycrate",
    ["models/items/item_beacon_crate.mdl"]        = "supplycrate",
    ["models/props_interiors/vendingmachinesoda01a.mdl"] = "sodamachine",
    ["models/props_office/vending_machine01.mdl"]       = "sodamachine",
    ["models/props/cs_office/vending_machine.mdl"]      = "sodamachine",
    ["models/props/cs_office/vending_machine_dark.mdl"] = "sodamachine",
    ["models/props/de_nuke/hr_nuke/nuke_vending_machine/nuke_snack_machine.mdl"] = "sodamachine",
    ["models/gibs/hgibs.mdl"]                        = "bone",
    ["models/gibs/hgibs_rib.mdl"]                    = "bone",
    ["models/gibs/hgibs_scapula.mdl"]                = "bone",
    ["models/gibs/hgibs_spine.mdl"]                  = "bone",
    ["models/player/skeleton.mdl"]                  = "bone",
    ["models/skeleton/skeleton_arm.mdl"]            = "bone",
    ["models/skeleton/skeleton_arm_l.mdl"]          = "bone",
    ["models/skeleton/skeleton_arm_l_noskins.mdl"]  = "bone",
    ["models/skeleton/skeleton_arm_noskins.mdl"]    = "bone",
    ["models/skeleton/skeleton_leg.mdl"]            = "bone",
    ["models/skeleton/skeleton_leg_l.mdl"]          = "bone",
    ["models/skeleton/skeleton_leg_l_noskins.mdl"]  = "bone",
    ["models/skeleton/skeleton_leg_noskins.mdl"]    = "bone",
    ["models/skeleton/skeleton_torso.mdl"]          = "bone",
    ["models/skeleton/skeleton_torso2.mdl"]         = "bone",
    ["models/skeleton/skeleton_torso2_noskins.mdl"] = "bone",
    ["models/skeleton/skeleton_torso3.mdl"]         = "bone",
    ["models/skeleton/skeleton_torso3_noskins.mdl"] = "bone",
    ["models/skeleton/skeleton_torso_noskins.mdl"]  = "bone",
    ["models/skeleton/skeleton_whole.mdl"]          = "bone",
    ["models/skeleton/skeleton_whole_noskins.mdl"]  = "bone",
    ["models/bots/skeleton_sniper/skeleton_sniper.mdl"]           = "bone",
    ["models/bots/skeleton_sniper_boss/skeleton_sniper_boss.mdl"] = "bone",
}

if HAS_LEAKING_BARRELS then
    for model, key in pairs(LEAKING_ONLY_MODELS) do
        MODEL_TO_SOUND[model] = key
    end
end

if HAS_BREAKING_CRATES then
    for model, _ in pairs(BREAKING_CRATE_MODELS) do
        MODEL_TO_SOUND[model] = "crate"
    end
end

for model, _ in pairs(WOOD_SUITCASE_MODELS) do
    MODEL_TO_SOUND[model] = "wood_suitcase"
end

for model, _ in pairs(CLOTH_SUITCASE_MODELS) do
    MODEL_TO_SOUND[model] = "suitcase"
end

for model, _ in pairs(DUMPSTER_MODELS) do
    MODEL_TO_SOUND[model] = "dumpster"
end

---------------------------------------------------------------------------
-- Rolling / strain / shake tables
---------------------------------------------------------------------------

local ROLL_SOUNDS = {
    ["canister"]                = "Canister.Roll",
    ["metal_barrel"]            = "Metal_Barrel.Roll",
    ["floating_metal_barrel"]   = "Metal_Barrel.Roll",
    ["paintcan"]                = "Paintcan.Roll",
    ["plastic_barrel"]          = "Plastic_Barrel.Roll",
    ["plastic_barrel_buoyant"]  = "Plastic_Barrel.Roll",
    ["grenade"]                 = "Grenade.Roll",
}

local STRAIN_SOUNDS = {
    ["cardboard"]               = "Cardboard.Strain",
    ["paper"]                   = "Cardboard.Strain",
    ["papercup"]                = "Cardboard.Strain",
    ["plastic_barrel"]          = "Plastic_Barrel.Strain",
    ["plastic_barrel_buoyant"]  = "Plastic_Barrel.Strain",
    ["plastic_box"]             = "Plastic_Box.Strain",
    ["plastic"]                 = "Plastic_Box.Strain",
    ["rubber_tire"]             = "Rubber_Tire.Strain",
    ["rubber"]                  = "Rubber_Tire.Strain",
    ["wood"]                    = "Wood.Strain",
    ["wood_lowdensity"]         = "Wood.Strain",
    ["wood_box"]                = "Wood_Box.Strain",
    ["wood_crate"]              = "Wood_Crate.Strain",
    ["wood_plank"]              = "Wood_Plank.Strain",
    ["wood_solid"]              = "Wood_Solid.Strain",
    ["wood_furniture"]          = "Wood_Furniture.Strain",
    ["wood_panel"]              = "Wood_Panel.Strain",
    ["metal_box"]               = "Metal_Box.Strain",
    ["solidmetal"]              = "SolidMetal.Strain",
    ["metal"]                   = "SolidMetal.Strain",
    ["slipperymetal"]           = "SolidMetal.Strain",
    ["metal_bouncy"]            = "SolidMetal.Strain",
    ["metal_barrel"]            = "Metal_Barrel.Strain",
    ["floating_metal_barrel"]   = "Metal_Barrel.Strain",
    ["canister"]                = "Metal_Barrel.Strain",
    ["glass"]                   = "Glass.Strain",
    ["ice"]                     = "Glass.Strain",
    ["flesh"]                   = "Flesh.Strain",
    ["bloodyflesh"]             = "Flesh.Strain",
    ["alienflesh"]              = "Flesh.Strain",
    ["watermelon"]              = "watermelon",
    ["zombieflesh"]             = "zombieflesh",
    ["strider"]                 = "strider",
    ["bone"]                    = "bone",
}

local STRAIN_SOUND_POOLS = {
    watermelon = {
        "physics/flesh/flesh_squishy_strain1.wav",
        "physics/flesh/flesh_squishy_strain2.wav",
        "physics/flesh/flesh_squishy_strain3.wav",
        "physics/flesh/flesh_squishy_strain4.wav",
    },
    zombieflesh = {
        "physics/flesh/flesh_squishy_strain1.wav",
        "physics/flesh/flesh_squishy_strain2.wav",
        "physics/flesh/flesh_squishy_strain3.wav",
        "physics/flesh/flesh_squishy_strain4.wav",
    },
    strider = {
        "npc/strider/creak1.wav",
        "npc/strider/creak2.wav",
        "npc/strider/creak3.wav",
        "npc/strider/creak4.wav",
        "npc/strider/strider_legstretch1.wav",
        "npc/strider/strider_legstretch2.wav",
        "npc/strider/strider_legstretch3.wav",
    },
    bone = {
        "npc/barnacle/neck_snap1.wav",
        "npc/barnacle/neck_snap2.wav",
        "physics/body/body_medium_break2.wav",
        "physics/body/body_medium_break3.wav",
        "physics/body/body_medium_break4.wav",
    },
}

-- Last raw-path pool sound per owner+category (avoids consecutive repeats).
-- Defined before ResolveStrainSound so the local is in scope.
local lastRawPoolSound = {}

local function PickNonRepeating(pool, last)
    if not pool or #pool == 0 then return nil end
    if #pool == 1 then return pool[1] end
    local idx = math.random(#pool)
    local snd = pool[idx]
    if last and snd == last then
        idx = (idx % #pool) + 1
        snd = pool[idx]
    end
    return snd
end

local function NextPoolSound(pool, owner, category)
    if not pool or #pool == 0 then return nil end
    category = category or "default"
    if owner ~= nil then
        local t = lastRawPoolSound[owner]
        if not t then
            t = {}
            lastRawPoolSound[owner] = t
        end
        local snd = PickNonRepeating(pool, t[category])
        if snd then t[category] = snd end
        return snd
    end
    local key = "g:" .. category
    local snd = PickNonRepeating(pool, lastRawPoolSound[key])
    if snd then lastRawPoolSound[key] = snd end
    return snd
end

local function ResolveStrainSound(key, owner)
    if not key then return nil end
    local pool = STRAIN_SOUND_POOLS[key]
    if pool then
        return NextPoolSound(pool, owner, "strain_" .. key) or pool[1]
    end
    return key -- default soundscript name, not a raw path pool
end

local METAL_STRAIN_MATERIALS = {
    ["metal"] = true, ["solidmetal"] = true, ["metal_box"] = true,
    ["metal_barrel"] = true, ["floating_metal_barrel"] = true,
    ["slipperymetal"] = true, ["metal_bouncy"] = true, ["canister"] = true,
}

local FLESH_MATERIALS = {
    ["flesh"] = true, ["bloodyflesh"] = true, ["alienflesh"] = true,
    ["zombieflesh"] = true, ["watermelon"] = true,
}

local EXTRA_RAGDOLL_STRAIN_MATERIALS = {
    ["strider"] = true,
}

local function IsBoneModel(ent)
    if not IsValid(ent) then return false end
    return MODEL_TO_SOUND[string.lower(ent:GetModel() or "")] == "bone"
end

local function GetStrainKeyForEntity(ent, mat)
    local strainKey = STRAIN_SOUNDS[mat]
    if strainKey then return strainKey end
    if CV.surfaces:GetBool() and IsBoneModel(ent) then return "bone" end
    return nil
end

local STRAIN_EXCLUDE_MODELS = {
    ["models/headcrabclassic.mdl"] = true,
    ["models/headcrab.mdl"]        = true,
    ["models/headcrabblack.mdl"]   = true,
    ["models/lamarr.mdl"]          = true,
    ["models/pigeon.mdl"]          = true,
    ["models/crow.mdl"]            = true,
    ["models/seagull.mdl"]         = true,
}

local function IsStrainExcluded(ent)
    if not IsValid(ent) then return true end
    local model = string.lower(ent:GetModel() or "")
    return STRAIN_EXCLUDE_MODELS[model] == true
end

local METAL_BARREL_MODELS = {
    ["models/props_c17/oildrum001.mdl"]           = true,
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
}

local SIDEWAYS_ONLY_MODELS = {
    ["models/props_borealis/bluebarrel001.mdl"]   = true,
    ["models/props_c17/oildrum001.mdl"]           = true,
    ["models/props_c17/oildrum001_explosive.mdl"] = true,
    ["models/props_phx/oildrum001_explosive.mdl"] = true,
}

local PAINTCAN_MODELS = {
    ["models/props_junk/metal_paintcan001a.mdl"] = true,
    ["models/props_junk/metal_paintcan001b.mdl"] = true,
    ["models/props_junk/paintcan001a.mdl"]       = true,
}

local SHAKE_SOUNDS = {
    health = {
        "physics/items/health_shake1.wav",
        "physics/items/health_shake2.wav",
        "physics/items/health_shake3.wav",
        "physics/items/health_shake4.wav",
        "physics/items/health_shake5.wav",
        "physics/items/health_shake6.wav",
        "physics/items/health_shake7.wav",
        "physics/items/health_shake8.wav",
    },
    cardboard = {
        "physics/cardboard/cardboard_box_shake_sep1.wav",
        "physics/cardboard/cardboard_box_shake_sep2.wav",
        "physics/cardboard/cardboard_box_shake_sep3.wav",
        "physics/cardboard/cardboard_box_shake_sep4.wav",
        "physics/cardboard/cardboard_box_shake_sep5.wav",
        "physics/cardboard/cardboard_box_shake_sep6.wav",
        "physics/cardboard/cardboard_box_shake_sep7.wav",
        "physics/cardboard/cardboard_box_shake_sep8.wav",
        "physics/cardboard/cardboard_box_shake_sep9.wav",
        "physics/cardboard/cardboard_box_shake_sep10.wav",
        "physics/cardboard/cardboard_box_shake_sep11.wav",
        "physics/cardboard/cardboard_box_shake_sep12.wav",
        "physics/cardboard/cardboard_box_shake_sep13.wav",
        "physics/cardboard/cardboard_box_shake_sep14.wav",
        "physics/cardboard/cardboard_box_shake_sep15.wav",
        "physics/cardboard/cardboard_box_shake_sep16.wav",
        "physics/cardboard/cardboard_box_shake_sep17.wav",
    },
    explosive_barrel = {
        "physics/metal/metal_barrel_shake1.wav",
        "physics/metal/metal_barrel_shake2.wav",
        "physics/metal/metal_barrel_shake3.wav",
        "physics/metal/metal_barrel_shake4.wav",
        "physics/metal/metal_barrel_shake5.wav",
        "physics/metal/metal_barrel_shake6.wav",
    },
    gascan = {
        "physics/metal/metal_gascan_shake1.wav",
        "physics/metal/metal_gascan_shake2.wav",
        "physics/metal/metal_gascan_shake3.wav",
        "physics/metal/metal_gascan_shake4.wav",
        "physics/metal/metal_gascan_shake5.wav",
        "physics/metal/metal_gascan_shake6.wav",
        "physics/metal/metal_gascan_shake7.wav",
        "physics/metal/metal_gascan_shake8.wav",
        "physics/metal/metal_gascan_shake9.wav",
        "physics/metal/metal_gascan_shake10.wav",
        "physics/metal/metal_gascan_shake11.wav",
    },
    paintcan = {
        "physics/metal/metal_paintcan_shake1.wav",
        "physics/metal/metal_paintcan_shake2.wav",
        "physics/metal/metal_paintcan_shake3.wav",
        "physics/metal/metal_paintcan_shake4.wav",
        "physics/metal/metal_paintcan_shake5.wav",
        "physics/metal/metal_paintcan_shake6.wav",
        "physics/metal/metal_paintcan_shake7.wav",
        "physics/metal/metal_paintcan_shake8.wav",
    },
    smg = {
        "physics/items/ammobox_smg_shake1.wav",
        "physics/items/ammobox_smg_shake2.wav",
        "physics/items/ammobox_smg_shake3.wav",
        "physics/items/ammobox_smg_shake4.wav",
        "physics/items/ammobox_smg_shake5.wav",
        "physics/items/ammobox_smg_shake6.wav",
    },
    pistol = {
        "physics/items/ammobox_smg_shake1.wav",
        "physics/items/ammobox_smg_shake2.wav",
        "physics/items/ammobox_smg_shake3.wav",
        "physics/items/ammobox_smg_shake4.wav",
        "physics/items/ammobox_smg_shake5.wav",
        "physics/items/ammobox_smg_shake6.wav",
    },
    ammo357 = {
        "physics/items/ammobox_357_shake1.wav",
        "physics/items/ammobox_357_shake2.wav",
        "physics/items/ammobox_357_shake3.wav",
        "physics/items/ammobox_357_shake4.wav",
        "physics/items/ammobox_357_shake5.wav",
    },
    shotgun = {
        "physics/items/ammobox_shotgun_shake1.wav",
        "physics/items/ammobox_shotgun_shake2.wav",
        "physics/items/ammobox_shotgun_shake3.wav",
        "physics/items/ammobox_shotgun_shake4.wav",
        "physics/items/ammobox_shotgun_shake5.wav",
        "physics/items/ammobox_shotgun_shake6.wav",
        "physics/items/ammobox_shotgun_shake7.wav",
    },
    supplycrate = {
        "physics/items/supplycrate_shake1.wav",
        "physics/items/supplycrate_shake2.wav",
        "physics/items/supplycrate_shake3.wav",
        "physics/items/supplycrate_shake4.wav",
        "physics/items/supplycrate_shake5.wav",
        "physics/items/supplycrate_shake6.wav",
    },
    sodamachine = {
        "physics/metal/metal_sodamachine_shake1.wav",
        "physics/metal/metal_sodamachine_shake2.wav",
        "physics/metal/metal_sodamachine_shake3.wav",
        "physics/metal/metal_sodamachine_shake4.wav",
    },
    crate = {
        "physics/items/supplycrate_shake1.wav",
        "physics/items/supplycrate_shake2.wav",
        "physics/items/supplycrate_shake3.wav",
        "physics/items/supplycrate_shake4.wav",
        "physics/items/supplycrate_shake5.wav",
        "physics/items/supplycrate_shake6.wav",
    },
    wood_suitcase = {
        "physics/items/supplycrate_shake1.wav",
        "physics/items/supplycrate_shake2.wav",
        "physics/items/supplycrate_shake3.wav",
        "physics/items/supplycrate_shake4.wav",
        "physics/items/supplycrate_shake5.wav",
        "physics/items/supplycrate_shake6.wav",
    },
    suitcase = {
        "physics/items/suitcase_shake1.wav",
        "physics/items/suitcase_shake2.wav",
        "physics/items/suitcase_shake3.wav",
        "physics/items/suitcase_shake4.wav",
        "physics/items/suitcase_shake5.wav",
    },
    dumpster = {
        "physics/metal/metal_sodamachine_shake1.wav",
        "physics/metal/metal_sodamachine_shake2.wav",
        "physics/metal/metal_sodamachine_shake3.wav",
        "physics/metal/metal_sodamachine_shake4.wav",
    },
}

local SUPPLYCRATE_OVERLAY = {
    "physics/items/ammobox_smg_shake1.wav",
    "physics/items/ammobox_smg_shake2.wav",
    "physics/items/ammobox_smg_shake3.wav",
    "physics/items/ammobox_smg_shake4.wav",
    "physics/items/ammobox_smg_shake5.wav",
    "physics/items/ammobox_smg_shake6.wav",
    "physics/items/ammobox_357_shake1.wav",
    "physics/items/ammobox_357_shake2.wav",
    "physics/items/ammobox_357_shake3.wav",
    "physics/items/ammobox_357_shake4.wav",
    "physics/items/ammobox_357_shake5.wav",
    "physics/items/ammobox_shotgun_shake1.wav",
    "physics/items/ammobox_shotgun_shake2.wav",
    "physics/items/ammobox_shotgun_shake3.wav",
    "physics/items/ammobox_shotgun_shake4.wav",
    "physics/items/ammobox_shotgun_shake5.wav",
    "physics/items/ammobox_shotgun_shake6.wav",
    "physics/items/ammobox_shotgun_shake7.wav",
}
local SUPPLYCRATE_OVERLAY_CHANCE = 0.40

MVTable(CUSTOM_SOUNDS)
MVTable(SHAKE_SOUNDS)
MVTable(STRAIN_SOUND_POOLS)
MVTable(SUPPLYCRATE_OVERLAY)

if HAS_MYVOICE then
    CUSTOM_SOUNDS.gascan = {
        hard = CUSTOM_SOUNDS.explosive_barrel.hard,
        soft = CUSTOM_SOUNDS.explosive_barrel.soft,
    }
    SHAKE_SOUNDS.gascan = SHAKE_SOUNDS.explosive_barrel

    CUSTOM_SOUNDS.paintcan = {
        hard = {
            "physics/items/health_impact_slosh1.wav",
            "physics/items/health_impact_slosh2.wav",
            "physics/items/health_impact_slosh3.wav",
            "physics/items/health_impact_slosh4.wav",
        },
        soft = {
            "physics/items/health_impact_slosh1.wav",
            "physics/items/health_impact_slosh2.wav",
            "physics/items/health_impact_slosh3.wav",
            "physics/items/health_impact_slosh4.wav",
        },
    }
    SHAKE_SOUNDS.paintcan = {
        "physics/items/health_shake1.wav",
        "physics/items/health_shake2.wav",
        "physics/items/health_shake3.wav",
        "physics/items/health_shake4.wav",
        "physics/items/health_shake5.wav",
        "physics/items/health_shake6.wav",
        "physics/items/health_shake7.wav",
        "physics/items/health_shake8.wav",
    }
end

local PAINTCAN_SPLASH_SOUNDS = {
    "physics/metal/metal_paintcan_splash1.wav",
    "physics/metal/metal_paintcan_splash2.wav",
    "physics/metal/metal_paintcan_splash3.wav",
}
MVTable(PAINTCAN_SPLASH_SOUNDS)

local SHAKE_CLASS = {
    ["item_healthkit"]         = "health",
    ["item_healthvial"]        = "health",
    ["item_ammo_smg1"]         = "smg",
    ["item_ammo_smg1_large"]   = "smg",
    ["item_ammo_pistol"]      = "pistol",
    ["item_ammo_pistol_large"] = "pistol",
    ["item_ammo_357"]          = "ammo357",
    ["item_ammo_357_large"]    = "ammo357",
    ["item_box_buckshot"]      = "shotgun",
    ["item_item_crate"]        = "supplycrate",
}

local SHAKE_MODEL = {
    ["models/items/healthkit.mdl"]                = "health",
    ["models/healthvial.mdl"]                     = "health",
    ["models/items/boxmrounds.mdl"]               = "smg",
    ["models/items/boxsrounds.mdl"]               = "pistol",
    ["models/items/357ammo.mdl"]                  = "ammo357",
    ["models/items/boxbuckshot.mdl"]              = "shotgun",
    ["models/props_c17/oildrum001_explosive.mdl"] = "explosive_barrel",
    ["models/props_phx/oildrum001_explosive.mdl"] = "explosive_barrel",
    ["models/props_junk/gascan001a.mdl"]          = "gascan",
    ["models/props_junk/metal_paintcan001a.mdl"]  = "paintcan",
    ["models/props_junk/metal_paintcan001b.mdl"]  = "paintcan",
    ["models/props_junk/paintcan001a.mdl"]        = "paintcan",
    ["models/items/item_item_crate.mdl"]          = "supplycrate",
    ["models/items/item_beacon_crate.mdl"]        = "supplycrate",
    ["models/props_interiors/vendingmachinesoda01a.mdl"] = "sodamachine",
    ["models/props_office/vending_machine01.mdl"]       = "sodamachine",
    ["models/props/cs_office/vending_machine.mdl"]      = "sodamachine",
    ["models/props/cs_office/vending_machine_dark.mdl"] = "sodamachine",
    ["models/props/de_nuke/hr_nuke/nuke_vending_machine/nuke_snack_machine.mdl"] = "sodamachine",
}

if HAS_LEAKING_BARRELS then
    for model, key in pairs(LEAKING_ONLY_MODELS) do
        SHAKE_MODEL[model] = key
    end
end

if HAS_BREAKING_CRATES then
    for model, _ in pairs(BREAKING_CRATE_MODELS) do
        SHAKE_MODEL[model] = "crate"
    end
end

for model, _ in pairs(WOOD_SUITCASE_MODELS) do
    SHAKE_MODEL[model] = "wood_suitcase"
end

for model, _ in pairs(CLOTH_SUITCASE_MODELS) do
    SHAKE_MODEL[model] = "suitcase"
end

for model, _ in pairs(DUMPSTER_MODELS) do
    SHAKE_MODEL[model] = "dumpster"
end

local CARDBOARD_SHAKE_MODELS = {
    ["models/props_junk/cardboard_box001a.mdl"]             = 100,
    ["models/props_junk/cardboard_box001b.mdl"]             = 100,
    ["models/props_junk/cardboard_box002a.mdl"]             = 100,
    ["models/props_junk/cardboard_box002b.mdl"]             = 100,
    ["models/props_junk/cardboard_box003a.mdl"]             = 110,
    ["models/props_junk/cardboard_box003b.mdl"]             = 110,
    ["models/props_junk/cardboard_box004a.mdl"]             = 125,
    ["models/props_junk/cardboard_box03.mdl"]               = 100,
    ["models/props_junk/cardboard_box03_static.mdl"]        = 100,
    ["models/props_junk/cardboard_box04.mdl"]               = 100,
    ["models/props_junk/cardboard_box04_static.mdl"]        = 100,
    ["models/props_junk/cardboard_box05.mdl"]               = 110,
    ["models/props_junk/cardboard_box05_static.mdl"]        = 110,
    ["models/props_junk/cardboard_box07.mdl"]               = 125,
    ["models/props_junk/cardboard_box07_static.mdl"]        = 125,
    ["models/props_junk/cardboardbox01a.mdl"]               = 125,
    ["models/props_junk/cardboardbox02.mdl"]                = 108,
    ["models/props_junk/cardboardbox03.mdl"]                = 128,
    ["models/props_junk/cardboardbox04.mdl"]                = 108,
    ["models/props_junk/cardboardbox05.mdl"]                = 110,
    ["models/props_junk/cardboardbox06.mdl"]                = 115,
    ["models/props_junk/cardboardbox07.mdl"]                = 110,
    ["models/props_junk/cardboardbox08a.mdl"]               = 100,
    ["models/props_manor/cardboard_box_set_01.mdl"]         = 85,
    ["models/props_manor/cardboard_box_set_02.mdl"]         = 85,
    ["models/props/cs_assault/cardboardbox_single.mdl"]     = 75,
    ["models/props/cs_assault/moneypallet_washerdryer.mdl"] = 50,
    ["models/props/cs_assault/washer_box2.mdl"]             = 70,
    ["models/props/cs_assault/dryer_box.mdl"]               = 70,
}

---------------------------------------------------------------------------
-- OPTIMIZATION: Pre-lowercase all model keys + model cache
---------------------------------------------------------------------------

local function LowerKeys(tbl)
    local out = {}
    for k, v in pairs(tbl) do
        out[string.lower(k)] = v
    end
    return out
end

MODEL_OVERRIDES        = LowerKeys(MODEL_OVERRIDES)
MODEL_TO_SOUND         = LowerKeys(MODEL_TO_SOUND)
SHAKE_MODEL            = LowerKeys(SHAKE_MODEL)
CARDBOARD_SHAKE_MODELS = LowerKeys(CARDBOARD_SHAKE_MODELS)
METAL_BARREL_MODELS   = LowerKeys(METAL_BARREL_MODELS)
SIDEWAYS_ONLY_MODELS = LowerKeys(SIDEWAYS_ONLY_MODELS)
PAINTCAN_MODELS       = LowerKeys(PAINTCAN_MODELS)
STRAIN_EXCLUDE_MODELS = LowerKeys(STRAIN_EXCLUDE_MODELS)
ALWAYS_EXPLOSIVE_BARREL = LowerKeys(ALWAYS_EXPLOSIVE_BARREL)
LEAKING_ONLY_MODELS  = LowerKeys(LEAKING_ONLY_MODELS)
BREAKING_CRATE_MODELS  = LowerKeys(BREAKING_CRATE_MODELS)
WOOD_SUITCASE_MODELS   = LowerKeys(WOOD_SUITCASE_MODELS)
CLOTH_SUITCASE_MODELS  = LowerKeys(CLOTH_SUITCASE_MODELS)
DUMPSTER_MODELS        = LowerKeys(DUMPSTER_MODELS)

-- Per-entity model cache (cleared on EntityRemoved).
-- Empty model strings are not cached: map/mod props often report "" on the
-- first tick before the model is assigned.
local modelCache = {}

local function GetCachedModel(ent)
    local m = modelCache[ent]
    if m ~= nil and m ~= "" then return m end
    m = string.lower(ent:GetModel() or "")
    if m ~= "" then
        modelCache[ent] = m
    end
    return m
end

---------------------------------------------------------------------------
-- OPTIMIZATION: Candidate tracking sets
---------------------------------------------------------------------------

local rollCandidates    = {}  -- [ent] = true
local ragdollCandidates = {}  -- [ent] = true
local shakeCandidates   = {}  -- [ent] = true  (props that can rattle: cardboard, ammo, barrels, etc.)
local heldProps         = {}  -- [ent] = true  (currently held by any player – for orbit suppression)

local function GetShakeKey(ent)
    local class = ent:GetClass()
    if SHAKE_CLASS[class] then return SHAKE_CLASS[class] end
    local model = GetCachedModel(ent)
    if SHAKE_MODEL[model] then return SHAKE_MODEL[model] end
    if CARDBOARD_SHAKE_MODELS[model] then return "cardboard" end
    return nil
end

local function UsesExplosiveBarrelSounds(ent)
    local model = GetCachedModel(ent)
    local key = MODEL_TO_SOUND[model] or SHAKE_MODEL[model]
    return key == "explosive_barrel"
end

local function IsGrenadeEntity(ent)
    local class = ent:GetClass()
    if class == "npc_grenade_frag" or class == "npc_grenade_helicopter" then return true end
    local model = GetCachedModel(ent)
    if string.find(model, "grenade", 1, true) then return true end
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) and string.lower(phys:GetMaterial() or "") == "grenade" then return true end
    return false
end

local function GetRollSoundForEntity(ent)
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return nil end
    local mat   = string.lower(phys:GetMaterial() or "")
    local model = GetCachedModel(ent)
    if HAS_MYVOICE then
        local gkey = MODEL_TO_SOUND[model] or SHAKE_MODEL[model]
        if gkey == "gascan"
        or model == "models/props_junk/gascan001a.mdl"
        or model == "models/props_junk/metalgascan.mdl" then
            return nil
        end
    end
    if model == "models/props/cs_assault/barrelwarning.mdl"
    or model == "models/props_silo/barrelwarning.mdl"
    or model == "models/props_borealis/bluebarrel001.mdl" then
        return "Plastic_Barrel.Roll"
    end
    if METAL_BARREL_MODELS[model] then return "Metal_Barrel.Roll" end
    if IsGrenadeEntity(ent) then return "Grenade.Roll" end
    return ROLL_SOUNDS[mat]
end

local function RegisterCandidates(ent)
    if not IsValid(ent) then return end
    local class = ent:GetClass()

    if class == "prop_ragdoll" then
        if not IsStrainExcluded(ent) then
            ragdollCandidates[ent] = true
        end
        return
    end

    if class == "prop_physics" or class == "prop_physics_multiplayer" or class == "npc_grenade_frag" then
        if GetRollSoundForEntity(ent) then
            rollCandidates[ent] = true
        end
    end

    -- Any entity that has a dedicated shake sound pool is a shake candidate
    -- (cardboard boxes, ammo boxes, health kits, barrels, paintcans, supply crates, etc.)
    if GetShakeKey(ent) then
        shakeCandidates[ent] = true
    end
end

---------------------------------------------------------------------------
-- Impact helpers
---------------------------------------------------------------------------

local lastCustomImpact = {}

-- Impact speed into the surface normal (scrapes / slides have a low value).
local function GetImpactNormalSpeed(colData)
    local vel = colData and colData.OurOldVelocity
    local n = colData and colData.HitNormal
    if not vel or not n then
        return (colData and colData.Speed) or 0
    end
    return math.abs(vel:Dot(n))
end

local function IsSoftSurface(surfacePropID)
    if not surfacePropID or surfacePropID < 0 then return false end
    local data = util.GetSurfaceData(surfacePropID)
    if not data then return false end
    if (data.hardnessFactor or 1) < 0.45 then return true end
    local name = string.lower(data.name or "")
    if name == "flesh" or name == "bloodyflesh" or name == "alienflesh"
    or name == "rubber" or name == "rubbertruck" or name == "rubberboat"
    or name == "glass" or name == "glassbottle" or name == "item"
    or name == "cardboard" or name == "paper" or name == "popcan" then
        return true
    end
    return false
end

-- Skybox detection for PhysicsCollide: surfaceprop alone is unreliable, so also
-- confirmatory-trace from the contact point for HitSky / SURF_SKY / sky materials.
local function IsSkySurface(surfacePropID, colData)
    if surfacePropID and surfacePropID >= 0 then
        local data = util.GetSurfaceData(surfacePropID)
        if data then
            local name = string.lower(data.name or "")
            if name == "default_silent" or name == "sky" or name == "sky_surface"
            or name == "nodraw" or name == "defaultsilent" then
                return true
            end
        end
        if util.GetSurfacePropName then
            local propName = util.GetSurfacePropName(surfacePropID)
            if isstring(propName) then
                propName = string.lower(propName)
                if propName == "default_silent" or propName == "sky" or propName == "sky_surface"
                or propName == "nodraw" or propName == "defaultsilent" then
                    return true
                end
            end
        end
    end

    if not colData then return false end

    local hitPos = colData.HitPos
    if not hitPos then return false end

    local dirs = {}
    local hitNormal = colData.HitNormal
    if hitNormal and hitNormal:LengthSqr() > 0.01 then
        local n = hitNormal:GetNormalized()
        dirs[#dirs + 1] = n
        dirs[#dirs + 1] = -n
    end
    dirs[#dirs + 1] = Vector(0, 0, 1)
    dirs[#dirs + 1] = Vector(0, 0, -1)

    -- Do not filter the world – we need to hit the sky brush itself.
    for i = 1, #dirs do
        local dir = dirs[i]
        local tr = util.TraceLine({
            start  = hitPos - dir * 2,
            endpos = hitPos + dir * 24,
            filter = function(ent)
                if not IsValid(ent) then return false end
                if ent:IsWorld() then return false end
                return true
            end,
            mask   = MASK_SOLID_BRUSHONLY,
        })
        if tr.HitSky then return true end
        if tr.Hit and tr.SurfaceFlags then
            if bit.band(tr.SurfaceFlags, SURF_SKY) ~= 0 then return true end
            if SURF_SKY2D and bit.band(tr.SurfaceFlags, SURF_SKY2D) ~= 0 then return true end
        end
        local tex = tr.HitTexture and string.lower(tostring(tr.HitTexture)) or ""
        if tex ~= "" and (
            string.find(tex, "sky", 1, true)
            or string.find(tex, "toolsskybox", 1, true)
            or tex == "**sky**"
            or tex == "tools/toolsskybox"
            or tex == "tools/toolsskybox2d"
        ) then
            return true
        end
    end

    return false
end

local break_SOUND = "physics/flesh/flesh_squishy_break1.wav"
local WATERMELON_IMPACT_HARD = {
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav",
}
MVTable(WATERMELON_IMPACT_HARD)

local CONCRETE_BREAK_MATERIALS = {
    ["concrete"]  = true,
    ["rock"]      = true,
    ["boulder"]   = true,
    ["porcelain"] = true,
}

local DIRT_BREAK_MATERIALS = {
    ["dirt"] = true,
}

local function PlayFleshBreakSounds(ent, modelOverride)
    if not IsValid(ent) and not modelOverride then return end
    local pos = IsValid(ent) and ent:GetPos() or vector_origin
    sound.Play(MV(break_SOUND), pos, 75, 100, 0.85)
    if #WATERMELON_IMPACT_HARD > 0 then
        local snd = NextPoolSound(WATERMELON_IMPACT_HARD, ent, "break_watermelon")
        if snd then
            sound.Play(snd, pos, 100, 100, 0.70)
        end
    end
end

local function PlayEngineBreakSound(ent, soundName)
    if not IsValid(ent) then return end
    ent:EmitSound(soundName, 75, 100, 0.90, CHAN_AUTO)
end

local function PlayWatermelonBreakSounds(ent, modelOverride)
    if not CV["break"]:GetBool() then return end
    PlayFleshBreakSounds(ent, modelOverride)
end

local function PlayCustomImpact(ent, colData)
    if not IsValid(ent) then return end

    -- Fully suppress custom impact / slosh / paint-splash against the skybox
    if IsSkySurface(colData and colData.TheirSurfaceProps, colData) then return end

    local key = CLASS_TO_SOUND[ent:GetClass()]
             or MODEL_TO_SOUND[GetCachedModel(ent)]
    if not key then return end
    local set = CUSTOM_SOUNDS[key]
    if not set then return end

    -- Bone impacts are gated only by surface overrides (not the general impacts toggle)
    if key == "bone" then
        if not CV.surfaces:GetBool() then return end
        local speed = (colData.OurOldVelocity and colData.OurOldVelocity:Length()) or colData.Speed or 0
        if speed < CV.min_impact_speed:GetFloat() then return end
        if colData.DeltaTime and colData.DeltaTime < 0.2 then return end
        -- Sliding / scraping: high tangential speed, little motion into the surface.
        local normalSpeed = GetImpactNormalSpeed(colData)
        if normalSpeed < 90 then return end
        if normalSpeed < speed * 0.28 and normalSpeed < 160 then return end
        local now = CurTime()
        if lastCustomImpact[ent] and (now - lastCustomImpact[ent]) < CV.impact_cooldown:GetFloat() then return end
        if ent:GetClass() == "prop_ragdoll" and IsValid(colData.HitEntity) and colData.HitEntity == ent then
            return
        end
        local forceSoft = IsSoftSurface(colData.TheirSurfaceProps)
        local isHard    = (not forceSoft) and (speed >= CV.hard_impact_speed:GetFloat())
        local pool = isHard and set.hard or set.soft
        local snd = NextPoolSound(pool, ent, isHard and "bone_hard" or "bone_soft")
        if not snd then return end
        lastCustomImpact[ent] = now
        local minSpd = CV.min_impact_speed:GetFloat()
        local hardSpd = CV.hard_impact_speed:GetFloat()
        local vol
        if isHard then
            local t = math.Clamp((speed - hardSpd) / 600, 0, 1)
            vol = 0.40 + t * 0.35
        else
            local t = math.Clamp((speed - minSpd) / math.max(1, hardSpd - minSpd), 0, 1)
            vol = 0.18 + t * 0.30
        end
        local pos = (colData.HitPos) or ent:GetPos()
        sound.Play(snd, pos, 75, 100, vol)
        return
    end

    if not CV.impacts:GetBool() then return end

    local speed = (colData.OurOldVelocity and colData.OurOldVelocity:Length()) or colData.Speed or 0
    if speed < CV.min_impact_speed:GetFloat() then return end
    if colData.DeltaTime and colData.DeltaTime < 0.2 then return end

    local now = CurTime()
    if lastCustomImpact[ent] and (now - lastCustomImpact[ent]) < CV.impact_cooldown:GetFloat() then return end

    if key == "health" then
        if not CV.health_sounds:GetBool() then return end
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local snd = NextPoolSound(set.hard, ent, "impact_health")
        if snd then
            ent:EmitSound(snd, 70, 100, CV.health_impact_vol:GetFloat(), CHAN_BODY)
        end
        return
    end

    if key == "paintcan" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local snd = NextPoolSound(set.hard, ent, "impact_paintcan")
        if snd then
            if HAS_MYVOICE then
                ent:EmitSound(snd, 70, 118, CV.health_impact_vol:GetFloat() + 0.08, CHAN_BODY)
            else
                ent:EmitSound(snd, 70, 100, 0.45, CHAN_BODY)
            end
        end

        if ent._PhysFXPaintFirstImpact then
            ent._PhysFXPaintFirstImpact = nil
            if CV.paint_splash:GetBool() and #PAINTCAN_SPLASH_SOUNDS > 0 then
                local splash = NextPoolSound(PAINTCAN_SPLASH_SOUNDS, ent, "paint_splash")
                if splash then
                    ent:EmitSound(splash, 100, 100, 0.55, CHAN_AUTO)
                end
            end
        end
        return
    end

    if key == "supplycrate" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local pos = ent:GetPos()
        local primary = NextPoolSound(CUSTOM_SOUNDS.supplycrate.hard, ent, "impact_supplycrate")
        if primary then
            sound.Play(primary, pos, 75, 100, 0.50)
        end
        if math.random() < SUPPLYCRATE_OVERLAY_CHANCE and #SUPPLYCRATE_OVERLAY > 0 then
            local overlay = NextPoolSound(SUPPLYCRATE_OVERLAY, ent, "impact_supplycrate_overlay")
            if overlay then
                sound.Play(overlay, pos, 70, 100, 0.30)
            end
        end
        return
    end

    -- Crate (Breaking Crates addon): supplycrate sounds, pitch -10, no ammo overlay
    if key == "crate" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local pos = ent:GetPos()
        local primary = NextPoolSound(CUSTOM_SOUNDS.crate.hard, ent, "impact_crate")
        if primary then
            sound.Play(primary, pos, 75, 90, 0.50)
        end
        return
    end

    -- Wood suitcase: supplycrate sounds, pitch +10, no overlay
    if key == "wood_suitcase" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local pos = ent:GetPos()
        local primary = NextPoolSound(CUSTOM_SOUNDS.wood_suitcase.hard, ent, "impact_wood_suitcase")
        if primary then
            sound.Play(primary, pos, 75, 110, 0.50)
        end
        return
    end

    -- Cloth suitcase / luggage: suitcase_shake sounds
    if key == "suitcase" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local pos = ent:GetPos()
        local model = GetCachedModel(ent)
        local pitch = CLOTH_SUITCASE_MODELS[model] or 100
        local primary = NextPoolSound(CUSTOM_SOUNDS.suitcase.hard, ent, "impact_suitcase")
        if primary then
            sound.Play(primary, pos, 75, pitch, 0.50)
        end
        return
    end

    -- Dumpster: sodamachine sounds with pitch offset
    if key == "dumpster" then
        if speed < CV.hard_impact_speed:GetFloat() then return end
        lastCustomImpact[ent] = now
        local pos = ent:GetPos()
        local model = GetCachedModel(ent)
        local pitch = DUMPSTER_MODELS[model] or 75
        local primary = NextPoolSound(CUSTOM_SOUNDS.dumpster.hard, ent, "impact_dumpster")
        if primary then
            sound.Play(primary, pos, 75, pitch, 0.50)
        end
        return
    end

    if key == "explosive_barrel" or key == "gascan" then
        local isHard = speed >= CV.hard_impact_speed:GetFloat()
        local pool   = set.hard
        local volume = isHard and 0.55 or 0.18
        local pitch = (HAS_MYVOICE and key == "gascan") and 118 or 100
        local snd = NextPoolSound(pool, ent, "impact_" .. key)
        if not snd then return end
        lastCustomImpact[ent] = now
        ent:EmitSound(snd, 75, pitch, volume, CHAN_BODY)
        return
    end

    local forceSoft = IsSoftSurface(colData.TheirSurfaceProps)
    local isHard    = (not forceSoft) and (speed >= CV.hard_impact_speed:GetFloat())
    local pool      = isHard and set.hard or set.soft
    local snd = NextPoolSound(pool, ent, "impact_" .. key .. (isHard and "_hard" or "_soft"))
    if not snd then return end
    lastCustomImpact[ent] = now
    ent:EmitSound(snd, 75, 100, 0.4, CHAN_BODY)
end

---------------------------------------------------------------------------
-- Funny (mattpipe)
---------------------------------------------------------------------------

local MATTPIPE_MODEL = "models/props_canal/mattpipe.mdl"
local mattpipeSoundPatches = {}
local MATTPIPE_ANGVEL_SOFT_CAP = 12000
local MATTPIPE_GROUND_GRACE = 1.0

local function StopMattpipeSound(ent)
    local data = mattpipeSoundPatches[ent]
    if not data then
        if IsValid(ent) then ent._PhysFXMattpipeFlight = nil end
        return
    end
    if data.timerName then
        timer.Remove(data.timerName)
        data.timerName = nil
    end
    if data.patch then data.patch:Stop() end
    mattpipeSoundPatches[ent] = nil
    if IsValid(ent) then
        ent._PhysFXMattpipeFlight = nil
    end
end

local function IsMattpipeInGrace(ent)
    local data = mattpipeSoundPatches[ent]
    if not data or data.ending then return false end
    return CurTime() < (data.graceUntil or 0)
end

local function EndMattpipeFlight(ent, fade)
    local data = mattpipeSoundPatches[ent]
    if not data then
        if IsValid(ent) then ent._PhysFXMattpipeFlight = nil end
        return
    end
    if data.ending then return end
    if CurTime() < (data.graceUntil or 0) then return end
    data.ending = true
    if data.timerName then timer.Remove(data.timerName) end

    if fade and data.patch then
        data.patch:ChangeVolume(0, 0.18)
        local e = ent
        timer.Simple(0.22, function()
            StopMattpipeSound(e)
        end)
    else
        StopMattpipeSound(ent)
    end
end

local function ClosestPlayerDistance(pos)
    local best = math.huge
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local d = pos:Distance(ply:EyePos())
            if d < best then best = d end
        end
    end
    if best == math.huge then return 0 end
    return best
end

local function StartMattpipeWarble(ent)
    if not IsValid(ent) then return end
    StopMattpipeSound(ent)

    local patch = CreateSound(ent, "physics/metal/metalpipe.wav")
    if not patch then return end

    local timerName = "PhysFX_MattpipeWarble_" .. ent:EntIndex()
    local startTime = CurTime()
    local phys0 = ent:GetPhysicsObject()
    local spinDir = Vector(
        (math.random() * 2 - 1),
        (math.random() * 2 - 1),
        (math.random() * 2 - 1) * 0.7
    )
    if IsValid(phys0) then
        local av = phys0:GetAngleVelocity()
        if av:Length() > 50 then
            spinDir = av:GetNormalized()
        end
    end
    if spinDir:Length() < 0.01 then spinDir = Vector(1, 0.3, 0.2) end
    spinDir:Normalize()

    ent._PhysFXMattpipeFlight = true
    mattpipeSoundPatches[ent] = {
        patch = patch,
        timerName = timerName,
        start = startTime,
        graceUntil = startTime + MATTPIPE_GROUND_GRACE,
        spinDir = spinDir,
        ending = false,
    }

    patch:PlayEx(0.55, 95)

    timer.Create(timerName, 0.05, 0, function()
        if not IsValid(ent) then
            StopMattpipeSound(ent)
            return
        end
        local data = mattpipeSoundPatches[ent]
        if not data or not data.patch or data.ending then
            return
        end

        local phys = ent:GetPhysicsObject()
        local inGrace = CurTime() < (data.graceUntil or 0)

        if not IsValid(phys) then
            if not inGrace then
                EndMattpipeFlight(ent, true)
            end
            return
        end
        if not phys:IsMotionEnabled() and not inGrace then
            EndMattpipeFlight(ent, true)
            return
        end

        local elapsed = CurTime() - data.start
        local angVel = IsValid(phys) and phys:GetAngleVelocity() or vector_origin
        local angSpeed = angVel:Length()

        if IsValid(phys) and phys:IsMotionEnabled() and angSpeed < MATTPIPE_ANGVEL_SOFT_CAP then
            local boost = 35 + elapsed * 28
            local dir = data.spinDir
            if angSpeed > 80 then
                dir = (data.spinDir * 0.65 + angVel:GetNormalized() * 0.35)
                if dir:Length() > 0.01 then dir:Normalize() end
            end
            phys:AddAngleVelocity(dir * boost)
            angSpeed = phys:GetAngleVelocity():Length()
        end

        local speedFactor = math.Clamp(angSpeed / 4500, 0, 1.35)
        local phase = elapsed * 8.5 + angSpeed * 0.0012
        local warble = math.sin(phase) * (10 + math.min(speedFactor, 1) * 24)
        warble = warble + math.sin(phase * 2.1) * (3 + math.min(speedFactor, 1) * 7)

        local pitch = 82 + speedFactor * 55 + warble

        local dist = ClosestPlayerDistance(ent:GetPos())
        local distDrop = math.Clamp(dist / 28, 0, 48)
        pitch = math.Clamp(pitch - distDrop, 55, 185)

        local volume = math.Clamp(0.30 + math.min(speedFactor, 1) * 0.48, 0.25, 0.82)

        if not data.patch:IsPlaying() then
            data.patch:PlayEx(volume, pitch)
        else
            data.patch:ChangePitch(pitch, 0.05)
            data.patch:ChangeVolume(volume, 0.05)
        end
    end)
end

local function TryMattpipeBounce(ent, colData)
    if not SERVER then return end
    if not CV.mattpipe:GetBool() then return end
    if not IsValid(ent) then return end
    if GetCachedModel(ent) ~= MATTPIPE_MODEL then return end

    if ent._PhysFXMattpipeFlight or mattpipeSoundPatches[ent] then
        if IsMattpipeInGrace(ent) then return end
        EndMattpipeFlight(ent, true)
    end

    local hn = colData.HitNormal
    if not hn or math.abs(hn.z) < 0.5 then return end

    local ourVel = colData.OurOldVelocity
    if ourVel and ourVel.z > 80 then return end

    local chance = CV.mattpipe_chance:GetFloat()
    chance = math.Clamp(chance, 0, 1)
    if chance < 1 and math.random() > chance then return end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    if not phys:IsMotionEnabled() then return end

    local mass = phys:GetMass()
    local forceZ = math.max(400, mass * 25)
    timer.Simple(0, function()
        if not IsValid(ent) then return end
        local p = ent:GetPhysicsObject()
        if not IsValid(p) or not p:IsMotionEnabled() then return end
        p:ApplyForceCenter(Vector(0, 0, forceZ))

        local tScale = math.max(8000, mass * 500)
        local torque = Vector(
            (math.random() * 2 - 1) * tScale,
            (math.random() * 2 - 1) * tScale,
            (math.random() * 2 - 1) * tScale * 0.6
        )
        p:ApplyTorqueCenter(torque)
        p:AddAngleVelocity(Vector(
            (math.random() * 2 - 1) * 1200,
            (math.random() * 2 - 1) * 1200,
            (math.random() * 2 - 1) * 800
        ))

        StartMattpipeWarble(ent)
    end)
end

---------------------------------------------------------------------------
-- Strain
---------------------------------------------------------------------------

local strainPlaying      = {}
local strainContactStart = {}
local lastStrainTime     = {}
local activeStrainCount  = {}
local lastDamageStrain   = {}

-- Ragdoll strain intensity:
--   1 = crushed / squashed / weighted by a prop (Flesh.Strain – rubbery creak)
--   2 = heavy constrained thrash into a surface (Flesh.Strain, may multi-layer)
--   3 = classic Source freakout / crushing-mass candidate (Flesh.Break)
--
-- Never fire for:
--   • Limb rubbing against the same ragdoll's body (self-collision)
--   • Mid-air flail with no external geometry
--   • Floor sliding / resting (arm or foot alone is not "on ground")
--   • Brief constraint snap-backs (limb forced back into a valid pose)
--
-- Prop-mass pressure sounds play ONCE when weight first settles on the torso.
local HIGH_VELOCITY_FLESH_SOUNDS = { "Flesh.Strain", "Flesh.Break" }

local RAGDOLL_BREAK_SUSTAIN = 0.45

-- Prop mass on torso (Source mass ≈ kg).
-- < 75 kg  : Strain only, and only with notable impact velocity.
-- 75–250 kg: Strain when resting; Break only with notable velocity.
-- ≥ 250 kg : Break on real contact (one-shot).
local RAGDOLL_PRESSURE_LIGHT_MASS   = 75
local RAGDOLL_PRESSURE_BREAK_MASS   = 250
local RAGDOLL_PRESSURE_STRAIN_SPEED = 160
local RAGDOLL_PRESSURE_BREAK_SPEED  = 280
-- Short upward contact gap – hovering props must not count.
local RAGDOLL_PRESSURE_TRACE_DIST   = 10
-- Props moving upward faster than this are being lifted off, not pressing down.
local RAGDOLL_PRESSURE_LIFT_VZ      = 5

local RAGDOLL_TORSO_BONE_NAMES = {
    "ValveBiped.Bip01_Pelvis",
    "ValveBiped.Bip01_Spine",
    "ValveBiped.Bip01_Spine1",
    "ValveBiped.Bip01_Spine2",
    "ValveBiped.Bip01_Spine4",
}

local function SafeIsPlayerHolding(ent)
    if not IsValid(ent) then return false end
    if not ent.IsPlayerHolding then return false end
    local ok, result = pcall(ent.IsPlayerHolding, ent)
    return ok and result
end

local function IsOtherRagdoll(e, self)
    if not IsValid(e) or e == self then return false end
    return e:GetClass() == "prop_ragdoll"
end

-- True for world / solid entities that can actually support or block a ragdoll.
-- Noclip players, observers, and non-solid brushes/entities do not count.
local function IsSolidSupportEntity(e)
    if not IsValid(e) then return true end -- world (trace hit with no entity)
    if e:IsWorld() then return true end
    if not e:IsSolid() then return false end
    if e:IsPlayer() then
        local mt = e:GetMoveType()
        if mt == MOVETYPE_NOCLIP or mt == MOVETYPE_OBSERVER then
            return false
        end
    end
    -- Pass-through / debris / weapon collision groups are not reliable ground.
    local cg = e:GetCollisionGroup()
    if cg == COLLISION_GROUP_DEBRIS
        or cg == COLLISION_GROUP_DEBRIS_TRIGGER
        or cg == COLLISION_GROUP_WEAPON
        or cg == COLLISION_GROUP_IN_VEHICLE
        or cg == COLLISION_GROUP_DISSOLVING then
        return false
    end
    return true
end

-- Cache: model → list of physics-object indices for torso bones (or false).
local torsoPhysIndexCache = {}

-- Shared trace filter state (avoids allocating a new closure every call).
-- Returns true = "this entity can stop the trace", false = pass through.
local _ragdollTraceSelf = nil
local function RagdollTraceFilter(e)
    if not IsValid(e) then return true end -- world
    if e == _ragdollTraceSelf then return false end
    if e:GetClass() == "prop_ragdoll" then return false end
    if not IsSolidSupportEntity(e) then return false end
    return true
end

local RAGDOLL_SIDE_DIRS = {
    Vector(0, 0, 1),
    Vector(1, 0, 0), Vector(-1, 0, 0),
    Vector(0, 1, 0), Vector(0, -1, 0),
}

-- Torso world positions from the ragdoll's physics objects.
-- GetBonePosition is unreliable on server-side prop_ragdolls; phys objects are authoritative.
local function GetRagdollTorsoPositions(ent)
    if not IsValid(ent) then return nil end
    local model = string.lower(ent:GetModel() or "")
    local cached = torsoPhysIndexCache[model]
    if cached == false then return nil end

    if cached == nil then
        local physIndices = {}
        local seen = {}
        for i = 1, #RAGDOLL_TORSO_BONE_NAMES do
            local bone = ent:LookupBone(RAGDOLL_TORSO_BONE_NAMES[i])
            if bone then
                local physIdx = ent:TranslateBoneToPhysBone(bone)
                if physIdx and physIdx >= 0 and not seen[physIdx] then
                    seen[physIdx] = true
                    physIndices[#physIndices + 1] = physIdx
                end
            end
        end
        if #physIndices == 0 then
            torsoPhysIndexCache[model] = false
            return nil
        end
        torsoPhysIndexCache[model] = physIndices
        cached = physIndices
    end

    local positions = {}
    for i = 1, #cached do
        local phys = ent:GetPhysicsObjectNum(cached[i])
        if IsValid(phys) then
            positions[#positions + 1] = phys:GetPos()
        end
    end
    if #positions == 0 then return nil end
    return positions
end

-- Average of torso positions, or root phys pos fallback.
local function GetRagdollTorsoCenter(ent, torsoPositions)
    if torsoPositions and #torsoPositions > 0 then
        local sx, sy, sz, n = 0, 0, 0, #torsoPositions
        for i = 1, n do
            local p = torsoPositions[i]
            sx, sy, sz = sx + p.x, sy + p.y, sz + p.z
        end
        return Vector(sx / n, sy / n, sz / n)
    end
    local rootPhys = ent:GetPhysicsObject()
    if IsValid(rootPhys) then return rootPhys:GetPos() end
    return ent:WorldSpaceCenter() or ent:GetPos()
end

-- floorHit / sideHit / anyHit.
-- Floor contact uses torso phys-objects only (a foot or hand on the ground does not count).
-- Optional precomputed torsoPositions avoids a second bone scan in the same think tick.
local function RagdollContactInfo(ent, torsoPositions)
    if not IsValid(ent) then return false, false, false end

    _ragdollTraceSelf = ent
    local filter = RagdollTraceFilter

    local floorHit, sideHit = false, false
    if torsoPositions == nil then
        torsoPositions = GetRagdollTorsoPositions(ent)
    end

    if torsoPositions then
        -- Cap floor probes to 3 torso points (pelvis + a couple spines is enough).
        local limit = math.min(#torsoPositions, 3)
        for i = 1, limit do
            local pos = torsoPositions[i]
            local tr = util.TraceLine({
                start  = pos,
                endpos = pos + Vector(0, 0, -20),
                filter = filter,
                mask   = MASK_SOLID,
            })
            if tr.Hit and tr.Entity ~= ent and IsSolidSupportEntity(tr.Entity) then
                floorHit = true
                break
            end
        end
    else
        local pos = GetRagdollTorsoCenter(ent, nil)
        local tr = util.TraceLine({
            start  = pos,
            endpos = pos + Vector(0, 0, -20),
            filter = filter,
            mask   = MASK_SOLID,
        })
        if tr.Hit and tr.Entity ~= ent and IsSolidSupportEntity(tr.Entity) then
            floorHit = true
        end
    end

    -- Single side/ceiling origin: torso average (never limbs).
    local origin = GetRagdollTorsoCenter(ent, torsoPositions)
    for d = 1, #RAGDOLL_SIDE_DIRS do
        local tr = util.TraceLine({
            start  = origin,
            endpos = origin + RAGDOLL_SIDE_DIRS[d] * 28,
            filter = filter,
            mask   = MASK_SOLID,
        })
        if tr.Hit and tr.Entity ~= ent and IsSolidSupportEntity(tr.Entity) then
            sideHit = true
            break
        end
    end

    _ragdollTraceSelf = nil
    return floorHit, sideHit, (floorHit or sideHit)
end

local function RagdollHasExternalSupport(ent)
    local _, _, any = RagdollContactInfo(ent)
    return any
end

-- True torso contact only. Returns mass, speed (0, 0 if nothing is pressing down).
-- Uses a single upward trace from the torso center (not one per bone).
-- Optional precomputed torsoPositions shares work with contact checks in the same tick.
local function GetRagdollTopPressureInfo(ent, torsoPositions)
    if not IsValid(ent) then return 0, 0 end

    if torsoPositions == nil then
        torsoPositions = GetRagdollTorsoPositions(ent)
    end
    local origin = GetRagdollTorsoCenter(ent, torsoPositions)

    _ragdollTraceSelf = ent
    local dist = RAGDOLL_PRESSURE_TRACE_DIST
    local tr = util.TraceLine({
        start  = origin + Vector(0, 0, 1),
        endpos = origin + Vector(0, 0, 1 + dist),
        filter = RagdollTraceFilter,
        mask   = MASK_SOLID,
    })
    _ragdollTraceSelf = nil

    if not tr.Hit or (tr.Fraction or 1) >= 0.95 then
        return 0, 0
    end

    local hitEnt = tr.Entity
    if not IsValid(hitEnt) or hitEnt == ent then return 0, 0 end
    if not IsSolidSupportEntity(hitEnt) then return 0, 0 end
    if hitEnt:GetClass() == "prop_ragdoll" then return 0, 0 end

    local class = hitEnt:GetClass() or ""
    if not (class == "prop_physics" or class == "prop_physics_multiplayer"
        or class == "prop_physics_respawnable"
        or (string.sub(class, 1, 5) == "prop_" and class ~= "prop_ragdoll")) then
        return 0, 0
    end

    local phys = hitEnt:GetPhysicsObject()
    if not IsValid(phys) then return 0, 0 end
    local mass = phys:GetMass() or 0
    if mass <= 0 then return 0, 0 end

    local vel = phys:GetVelocity()
    if vel.z > RAGDOLL_PRESSURE_LIFT_VZ then return 0, 0 end

    return mass, vel:Length()
end

-- One-shot mass-pressure tracking: [ent] = 1 (strain played) or 2 (break played).
-- Cleared when weight lifts off so a new drop can fire again.
local ragdollPressurePlayed = {}

-- Entity-collision timestamps for freakout detection (last ~1 s per ragdoll).
-- Only collisions with other entities (props, doors, moving brushes, etc.) count –
-- pure world hits from natural tumbling are ignored.
-- A rate above boneCount * RAGDOLL_FREAKOUT_COL_FACTOR in one second → Break.
local RAGDOLL_FREAKOUT_COL_FACTOR = 2.5
local RAGDOLL_FREAKOUT_COL_WINDOW = 1.0
local RAGDOLL_COL_TIMES_MAX = 64  -- hard cap; prune older entries when exceeded
local ragdollColTimes = {}  -- [ent] = { t1, t2, ... }

local function PruneRagdollColTimes(t, now)
    local cutoff = (now or CurTime()) - RAGDOLL_FREAKOUT_COL_WINDOW
    local write = 1
    for i = 1, #t do
        if t[i] >= cutoff then
            t[write] = t[i]
            write = write + 1
        end
    end
    for i = write, #t do
        t[i] = nil
    end
    return write - 1
end

local function RecordRagdollSurfaceCollision(ent, data)
    if not IsValid(ent) then return end
    -- Sleeping ragdolls cannot be mid-freakout; skip recording entirely.
    local root = ent:GetPhysicsObject()
    if IsValid(root) and root:IsAsleep() then return end

    local hit = data and data.HitEntity
    -- Must be colliding with a solid entity (prop, door, solid brush entity, etc.).
    -- World-only contacts from tumbling, noclip players, and non-solid brushes do not count.
    if not IsValid(hit) then return end
    if hit:IsWorld() then return end
    if hit == ent then return end
    if hit:GetClass() == "prop_ragdoll" then return end
    if not IsSolidSupportEntity(hit) then return end

    local now = CurTime()
    local t = ragdollColTimes[ent]
    if not t then
        t = {}
        ragdollColTimes[ent] = t
    end
    t[#t + 1] = now
    if #t > RAGDOLL_COL_TIMES_MAX then
        PruneRagdollColTimes(t, now)
        -- If still over after prune (extreme spam), drop oldest half.
        if #t > RAGDOLL_COL_TIMES_MAX then
            local drop = #t - RAGDOLL_COL_TIMES_MAX
            for i = 1, RAGDOLL_COL_TIMES_MAX do
                t[i] = t[i + drop]
            end
            for i = RAGDOLL_COL_TIMES_MAX + 1, #t do
                t[i] = nil
            end
        end
    end
end

local function CountRagdollSurfaceCollisions(ent)
    local t = ragdollColTimes[ent]
    if not t or #t == 0 then return 0 end
    return PruneRagdollColTimes(t)
end

-- Returns motion-based severity (1–3) or nil. Does NOT include mass pressure
-- (mass is handled as a one-shot event in the stretch think).
-- Optional floorHit/sideHit/anyHit avoid a second contact scan in the same think tick.
local function RagdollGetStrainSeverity(ent, floorHit, sideHit, anyHit)
    if not IsValid(ent) or ent:GetClass() ~= "prop_ragdoll" then return nil end
    local boneCount = ent:GetPhysicsObjectCount()
    if boneCount < 2 then return nil end

    -- Collision-rate freakout against another entity (not world tumbling):
    -- more than 2.5× bone count entity hits in 1 second → Break candidate.
    local colCount = CountRagdollSurfaceCollisions(ent)
    if colCount > boneCount * RAGDOLL_FREAKOUT_COL_FACTOR then
        return 3
    end

    local frozenBones, thrashingBones = 0, 0
    local maxAng, maxLin, totalLin, totalHoriz, valid = 0, 0, 0, 0, 0

    for i = 0, boneCount - 1 do
        local phys = ent:GetPhysicsObjectNum(i)
        if not IsValid(phys) then continue end
        valid = valid + 1
        local vel = phys:GetVelocity()
        local lin = vel:Length()
        local ang = phys:GetAngleVelocity():Length()
        totalLin = totalLin + lin
        totalHoriz = totalHoriz + math.sqrt(vel.x * vel.x + vel.y * vel.y)
        maxLin = math.max(maxLin, lin)
        maxAng = math.max(maxAng, ang)

        if not phys:IsMotionEnabled() or lin < 12 then
            frozenBones = frozenBones + 1
        end
        if lin > 160 or ang > 650 then
            thrashingBones = thrashingBones + 1
        end
    end

    if valid < 2 then return nil end
    local avgLin   = totalLin / valid
    local avgHoriz = totalHoriz / valid
    local held     = SafeIsPlayerHolding(ent)
    if anyHit == nil then
        floorHit, sideHit, anyHit = RagdollContactInfo(ent)
    end

    if not anyHit then
        return nil
    end

    if floorHit and not sideHit and not held then
        local isSliding    = avgHoriz > 35 and maxAng < 1200 and thrashingBones < 3
        local isResting    = avgLin < 45 and maxAng < 550
        local isMildTwitch = thrashingBones <= 1 and maxAng < 1000 and avgLin < 100
        if isSliding or isResting or isMildTwitch then
            return nil
        end
        if not (frozenBones >= 2 and thrashingBones >= 2 and maxAng > 1100) then
            return nil
        end
    end

    if floorHit and not sideHit and held then
        if thrashingBones < 2 and maxAng < 1100 then
            return nil
        end
    end

    local crushed = anyHit and frozenBones >= 1 and thrashingBones >= 1 and maxAng > 800
    local squashed = anyHit and maxAng > 1400 and avgLin < 65 and thrashingBones >= 2
    local physgunShove = held and anyHit and (thrashingBones >= 2 or maxAng > 1000)
    local violent = anyHit and thrashingBones >= 3 and maxAng > 1300

    if not (crushed or squashed or physgunShove or violent) then
        return nil
    end

    local freakout = anyHit
        and thrashingBones >= 2
        and maxAng > 2200
        and (
            (held and (sideHit or frozenBones >= 1))
            or (frozenBones >= 2 and (maxLin > 500 or avgLin > 220))
            or (sideHit and thrashingBones >= 3 and maxAng > 2800)
        )

    if freakout then
        return 3
    end

    local score = 0
    if crushed then score = score + 1 end
    if squashed then score = score + 1 end
    if physgunShove then score = score + 1 end
    if violent then score = score + 1 end
    if maxAng > 1900 then score = score + 1 end
    if maxLin > CV.high_vel_strain:GetFloat() then score = score + 1 end

    if score >= 3 then return 2 end
    return 1
end

local function RagdollIsBeingStretched(ent)
    return RagdollGetStrainSeverity(ent) ~= nil
end

-- Continuous severity-3 time for motion-based Flesh.Break sustain gate.
local ragdollBreakAccum = {}

-- Strain audible range: must be in a player's PVS and within this distance
local STRAIN_MAX_DIST = 2700
local STRAIN_MAX_DIST_SQR = STRAIN_MAX_DIST * STRAIN_MAX_DIST
-- High-velocity multi-layer ragdoll strain is tighter
local HIGH_VEL_STRAIN_MAX_DIST = 2300
local HIGH_VEL_STRAIN_MAX_DIST_SQR = HIGH_VEL_STRAIN_MAX_DIST * HIGH_VEL_STRAIN_MAX_DIST
-- Very close = always audible (skip TestPVS)
local PVS_SKIP_DIST_SQR = 512 * 512
-- Shake discovery radius
local SHAKE_HEAR_DIST_SQR = 2000 * 2000

-- Per-tick player snapshot so we don't call player.GetAll + GetPos repeatedly
local _plyCache = {}
local _plyCacheTime = -1

local function GetPlayerCache()
    local now = CurTime()
    if _plyCacheTime == now then return _plyCache end
    _plyCacheTime = now
    local n = 0
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            n = n + 1
            local slot = _plyCache[n]
            if slot then
                slot.ply = ply
                slot.pos = ply:GetPos()
            else
                _plyCache[n] = { ply = ply, pos = ply:GetPos() }
            end
        end
    end
    for i = n + 1, #_plyCache do
        _plyCache[i] = nil
    end
    return _plyCache
end

-- Distance-first, then PVS. skipPVS = true does a pure distance check (for the
-- tighter high-vel gate after a full PVS check already passed).
local function CanHearStrain(ent, maxDistSqr, skipPVS)
    if not IsValid(ent) then return false end
    maxDistSqr = maxDistSqr or STRAIN_MAX_DIST_SQR
    local pos = ent:GetPos()
    local players = GetPlayerCache()
    local count = #players
    if count == 0 then return false end

    for i = 1, count do
        local pd = players[i]
        local d = pd.pos:DistToSqr(pos)
        if d > maxDistSqr then continue end
        if skipPVS or d <= PVS_SKIP_DIST_SQR then return true end
        local ply = pd.ply
        if not ply.TestPVS or ply:TestPVS(ent) then return true end
    end
    return false
end

local function PlayStrainSound(ent, colData)
    if not CV.strain:GetBool() then return end
    if not IsValid(ent) then return end
    if IsStrainExcluded(ent) then return end
    if not CanHearStrain(ent) then return end

    local isRagdoll = ent:GetClass() == "prop_ragdoll"
    if isRagdoll and IsValid(colData.HitEntity) and colData.HitEntity == ent then return end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end

    local mat = string.lower(phys:GetMaterial() or "")
    local strainKey = GetStrainKeyForEntity(ent, mat)
    if not strainKey then return end

    local isFleshMat = FLESH_MATERIALS[mat] == true
    local isMetalMat = METAL_STRAIN_MATERIALS[mat] == true
    local isExtraRagdoll = EXTRA_RAGDOLL_STRAIN_MATERIALS[mat] == true or strainKey == "bone"
    if isRagdoll and not isFleshMat and not isMetalMat and not isExtraRagdoll then return end
    if not isRagdoll and isMetalMat and phys:GetMass() < CV.min_metal_mass:GetFloat() then return end

    local now = CurTime()
    local speed    = (colData.OurOldVelocity and colData.OurOldVelocity:Length()) or colData.Speed or 0
    local hitSpeed = colData.HitSpeed and colData.HitSpeed:Length() or 0
    local isHeld   = SafeIsPlayerHolding(ent)
    local sustained = false
    -- High-velocity multi-layer strain within hear distance (distance-only; full PVS already passed above).
    local allowMulti = isRagdoll and speed >= CV.high_vel_strain:GetFloat()
        and CanHearStrain(ent, HIGH_VEL_STRAIN_MAX_DIST_SQR, true)

    if isRagdoll then
        if speed >= 600 and hitSpeed > 350 and (not colData.DeltaTime or colData.DeltaTime < 0.07) then
            sustained = true
        end
    else
        if isHeld and speed < 150 and hitSpeed > 60 and colData.DeltaTime and colData.DeltaTime < 0.1 then
            if not strainContactStart[ent] then strainContactStart[ent] = now end
            if (now - strainContactStart[ent]) >= CV.strain_buildup:GetFloat() then sustained = true end
        elseif speed >= 300 and colData.DeltaTime and colData.DeltaTime < 0.1 then
            if not strainContactStart[ent] then strainContactStart[ent] = now end
            if (now - strainContactStart[ent]) >= CV.strain_buildup:GetFloat() then sustained = true end
        else
            strainContactStart[ent] = nil
        end
    end
    if not sustained then return end

    if not allowMulti then
        if strainPlaying[ent] and now < strainPlaying[ent] then return end
    else
        local count = activeStrainCount[ent] or 0
        if count >= CV.max_concurrent_strain:GetInt() then
            if lastStrainTime[ent] and (now - lastStrainTime[ent]) < 0.05 then return end
        end
        if lastStrainTime[ent] and (now - lastStrainTime[ent]) < CV.strain_cooldown:GetFloat() then return end
    end

    local forceFactor = math.Clamp(math.max(speed, hitSpeed) / 600, 0.15, 1)
    local volume = 0.12 + forceFactor * 0.22
    if isRagdoll then
        if speed < 800 then volume = 0.06 + forceFactor * 0.08
        else volume = 0.18 + forceFactor * 0.25 end
    end

    local soundToPlay
    if allowMulti and isFleshMat then
        -- Collide-path multi strain stays on Flesh.Strain only.
        -- Flesh.Break is reserved for extreme constrained crush (stretch-think severity 3).
        soundToPlay = "Flesh.Strain"
    else
        soundToPlay = ResolveStrainSound(strainKey, ent)
    end

    lastStrainTime[ent] = now
    if allowMulti then
        activeStrainCount[ent] = (activeStrainCount[ent] or 0) + 1
        timer.Simple(0.70, function()
            if activeStrainCount[ent] then
                activeStrainCount[ent] = math.max(0, (activeStrainCount[ent] or 1) - 1)
            end
        end)
    else
        strainPlaying[ent] = now + CV.strain_duration:GetFloat()
    end
    strainContactStart[ent] = nil
    if strainKey == "bone" then
        sound.Play(soundToPlay, ent:GetPos(), 70, 100, volume)
    else
        ent:EmitSound(soundToPlay, 70, 100, volume, CHAN_BODY)
    end
end

-- Custom break detection
local FLESH_BREAK_MODELS = {
    ["models/props_junk/watermelon01.mdl"] = true,
    ["models/props_outland/pumpkin01.mdl"]  = true,
    ["models/props/cs_italy/orange.mdl"]    = true,
}
FLESH_BREAK_MODELS = LowerKeys(FLESH_BREAK_MODELS)

local BANANA_BREAK_MODELS = {
    ["models/props/cs_italy/bananna.mdl"]       = true,
    ["models/props/cs_italy/bananna_bunch.mdl"] = true,
    ["models/props/cs_italy/banannagib1.mdl"]   = true,
    ["models/props/cs_italy/banannagib2.mdl"]   = true,
}
BANANA_BREAK_MODELS = LowerKeys(BANANA_BREAK_MODELS)

local function PlayBananaBreakSound(ent)
    if not IsValid(ent) then return end
    local pos = ent:GetPos()
    sound.Play(MV(break_SOUND), pos, 75, 100, 0.85)
end

local function GetCustomBreakType(ent)
    if not IsValid(ent) then return nil end
    if ent:GetClass() ~= "prop_physics" and ent:GetClass() ~= "prop_physics_multiplayer" then
        return nil
    end
    local model = GetCachedModel(ent)
    if BANANA_BREAK_MODELS[model] then return "banana" end
    if FLESH_BREAK_MODELS[model] then return "flesh" end
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return nil end
    local mat = string.lower(phys:GetMaterial() or "")
    if mat == "watermelon" then return "flesh" end
    if CONCRETE_BREAK_MATERIALS[mat] then return "concrete" end
    if DIRT_BREAK_MATERIALS[mat] then return "dirt" end
    return nil
end

---------------------------------------------------------------------------
(function()
-- Dissolve & Ignite / Extinguish sounds
---------------------------------------------------------------------------

local DISSOLVE_SOUND = "physics/entity_energy_dissolve.wav"
local IGNITE_SOUNDS = {
    "physics/entity_fire_ignite_1.wav",
    "physics/entity_fire_ignite_2.wav",
    "physics/entity_fire_ignite_3.wav",
}
local EXTINGUISH_SOUNDS = {
    "physics/entity_fire_ignite_2.wav",
    "physics/entity_fire_exting_1.wav",
}

-- Entities that recently ignited; used to detect natural burnout.
local fireCandidates = {}

-- Active dissolve sound patches so we can stop them on EntityRemoved.
local dissolveSoundPatches = {} -- [ent] = { patch = CSoundPatch, timerName = string }

---------------------------------------------------------------------------
-- Combine-ball gib mode (coordinate with MMod Physics FX)
-- When mmod_physfxcombineball exists and is enabled, that addon dissolves
-- every gib from a destroyed prop / death. We only want ONE dissolve sound
-- for the whole event, not one per gib.
---------------------------------------------------------------------------
local function IsCombineBallGibMode()
    local cv = GetConVar("mmod_physfxcombineball")
    return cv ~= nil and cv:GetBool()
end

local function IsLikelyDissolveGib(ent)
    if not IsValid(ent) then return true end
    -- Flag set by MMod when it starts dissolving a gib
    if ent._mmod_physfxNoTrail then return true end

    local class = string.lower(ent:GetClass() or "")
    if class == "gib" or class == "prop_gib" then return true end
    if string.find(class, "gib", 1, true) then return true end

    local age = CurTime() - (ent.GetCreationTime and ent:GetCreationTime() or 0)
    if age < 0.85 then
        local model = string.lower(ent:GetModel() or "")
        if string.find(model, "gib", 1, true)
            or string.find(model, "chunk", 1, true)
            or string.find(model, "hgibs", 1, true) then
            return true
        end
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) and (phys:GetMass() or 0) > 0 and phys:GetMass() < 35 then
            if class == "prop_physics" or class == "prop_physics_multiplayer"
                or class == "prop_physics_respawnable" then
                return true
            end
        end
    end
    return false
end

-- Positional throttle so a storm of dissolving gibs still only makes one sound.
local recentDissolveClusters = {} -- { pos, t }

local function InRecentDissolveCluster(pos, radius, window)
    radius = radius or 140
    window = window or 0.45
    local now = CurTime()
    local rSqr = radius * radius
    for i = #recentDissolveClusters, 1, -1 do
        local c = recentDissolveClusters[i]
        if (now - c.t) > window then
            table.remove(recentDissolveClusters, i)
        elseif c.pos:DistToSqr(pos) <= rSqr then
            return true
        end
    end
    return false
end

local function MarkDissolveCluster(pos)
    recentDissolveClusters[#recentDissolveClusters + 1] = { pos = pos, t = CurTime() }
end

local function StopDissolveSound(ent)
    local data = dissolveSoundPatches[ent]
    if not data then return end
    if data.timerName then timer.Remove(data.timerName) end
    if data.patch then data.patch:Stop() end
    dissolveSoundPatches[ent] = nil
end

local function IsExplosiveDissolveProp(ent)
    if not IsValid(ent) then return false end
    local model = string.lower(ent:GetModel() or "")
    if ALWAYS_EXPLOSIVE_BARREL[model] then return true end
    if LEAKING_ONLY_MODELS[model] == "explosive_barrel" then return true end
    if MODEL_TO_SOUND[model] == "explosive_barrel" then return true end
    if string.find(model, "explosive", 1, true) then return true end
    if string.find(model, "oildrum001_explosive", 1, true) then return true end
    -- Common blast props
    local class = string.lower(ent:GetClass() or "")
    if class == "prop_physics" or class == "prop_physics_multiplayer" then
        if string.find(model, "oildrum", 1, true) and string.find(model, "explosive", 1, true) then
            return true
        end
    end
    return false
end

local function PlayDissolveSound(ent)
    if not CV.dissolve:GetBool() then return end
    if not IsValid(ent) then return end
    if ent._PhysFXDissolveSoundPlayed then return end
    -- Exploding barrels / similar props should not play dissolve audio
    if IsExplosiveDissolveProp(ent) then return end

    local pos = ent:GetPos()

    -- When MMod combine-ball gib dissolve is active, suppress per-gib spam:
    -- skip likely gibs, and collapse any remaining nearby dissolves into one sound.
    if IsCombineBallGibMode() then
        if IsLikelyDissolveGib(ent) then
            return
        end
        if InRecentDissolveCluster(pos) then
            ent._PhysFXDissolveSoundPlayed = true
            return
        end
    end

    ent._PhysFXDissolveSoundPlayed = true
    MarkDissolveCluster(pos)

    -- EmitSound is entity-attached and networked, so the audio follows the
    -- dissolving entity instead of staying fixed at the point the effect began.
    ent:EmitSound(DISSOLVE_SOUND, 75, 100, 0.85, CHAN_AUTO)
end

local function PlayIgniteSound(ent)
    if not CV.ignite:GetBool() then return end
    if not IsValid(ent) then return end
    if ent:GetClass() == "env_fire" then return end
    if ent._PhysFXIgniteSoundPlayed then return end
    -- Skip if already on fire (re-ignite / duration refresh)
    if ent.IsOnFire and ent:IsOnFire() then return end
    ent._PhysFXIgniteSoundPlayed = true
    local snd = IGNITE_SOUNDS[math.random(#IGNITE_SOUNDS)]
    if snd then
        ent:EmitSound(snd, 75, 100, 0.80, CHAN_AUTO)
    end
    -- Track for natural extinguish detection
    ent._PhysFXWasOnFire = true
    fireCandidates[ent] = true
    -- Clear the anti-spam flag after a short window so a later
    -- re-ignition (after the entity has been extinguished) can play again.
    timer.Simple(1.0, function()
        if IsValid(ent) then
            ent._PhysFXIgniteSoundPlayed = nil
        end
    end)
end

local function PlayExtinguishSound(ent)
    if not CV.ignite:GetBool() then return end
    if not IsValid(ent) then return end
    if ent:GetClass() == "env_fire" then return end
    if ent.Health and isfunction(ent.Health) then
        local hp = ent:Health()
        if isnumber(hp) and hp <= 0 then return end
    end
    if ent._PhysFXExtinguishSoundPlayed then return end
    ent._PhysFXExtinguishSoundPlayed = true
    local snd = EXTINGUISH_SOUNDS[math.random(#EXTINGUISH_SOUNDS)]
    if snd then
        ent:EmitSound(snd, 75, 100, 0.75, CHAN_AUTO)
    end
    timer.Simple(1.0, function()
        if IsValid(ent) then
            ent._PhysFXExtinguishSoundPlayed = nil
        end
    end)
end

-- Apply (and re-apply) method wraps. Re-application on InitPostEntity / delayed
-- timers ensures we still intercept calls from other addons (e.g. Extended
-- Properties "Disintegrate" which does ent:Dissolve(0, 100)), even if load
-- order varies or another script temporarily replaced the meta method.
local function PhysFX_ApplyEntityWraps()
    local meta = FindMetaTable("Entity")
    if not meta then return end

    -- Always (re)install our Dissolve wrapper so context-menu / other addons
    -- (e.g. Extended Properties Disintegrate → ent:Dissolve(0, 100)) cannot
    -- silently bypass it after a later meta overwrite.
    if meta.Dissolve then
        local current = meta.Dissolve
        if not meta._PhysFXDissolveWrapped or meta._PhysFXDissolveImpl ~= current then
            -- Chain to whatever is currently installed (engine or another addon).
            local previous = current
            local function wrappedDissolve(self, ...)
                if IsValid(self) then
                    self._PhysFXDissolving = true
                    fireCandidates[self] = nil
                    PlayDissolveSound(self)
                end
                return previous(self, ...)
            end
            meta.Dissolve = wrappedDissolve
            meta._PhysFXDissolveImpl = wrappedDissolve
            meta._PhysFXDissolveWrapped = true
        end
    end

    if meta.Ignite and not meta._PhysFXIgniteWrapped then
        meta._PhysFXIgniteWrapped = true
        local oldIgnite = meta.Ignite
        function meta:Ignite(...)
            PlayIgniteSound(self)
            return oldIgnite(self, ...)
        end
    end

    if meta.Extinguish and not meta._PhysFXExtinguishWrapped then
        meta._PhysFXExtinguishWrapped = true
        local oldExtinguish = meta.Extinguish
        function meta:Extinguish(...)
            local wasOnFire = self.IsOnFire and self:IsOnFire()
            local result = oldExtinguish(self, ...)
            if wasOnFire then
                local dead = false
                if self.Health and isfunction(self.Health) then
                    local hp = self:Health()
                    dead = isnumber(hp) and hp <= 0
                end
                if not dead then
                    PlayExtinguishSound(self)
                end
                self._PhysFXWasOnFire = nil
                fireCandidates[self] = nil
            end
            return result
        end
    end
end

PhysFX_ApplyEntityWraps()
hook.Add("InitPostEntity", "PhysicsSounds_ApplyEntityWraps", PhysFX_ApplyEntityWraps)
timer.Simple(0, PhysFX_ApplyEntityWraps)
timer.Simple(1, PhysFX_ApplyEntityWraps)
timer.Simple(3, PhysFX_ApplyEntityWraps)

-- Hammer I/O / ent_fire "Dissolve" input (and common variants)
hook.Add("AcceptInput", "PhysicsSounds_DissolveInput", function(ent, input, activator, caller, value)
    if not IsValid(ent) then return end
    local name = string.lower(tostring(input or ""))
    if name == "dissolve" or name == "dissolvetype" or name == "startdissolving"
        or name == "dissolvetarget" then
        ent._PhysFXDissolving = true
        fireCandidates[ent] = nil
        PlayDissolveSound(ent)
    end
end)

-- DMG_DISSOLVE damage path.
-- Only play when the hit is actually destroying the entity (lethal), so a
-- Combine Ball grazing non-level geometry does not spam dissolve sounds.
-- Props with Health() <= 0 still qualify on the first dissolve damage tick;
-- subsequent gibs are filtered by PlayDissolveSound when MMod combine-ball
-- gib dissolve is enabled.
-- True if the entity is allowed to take damaging dissolve (not invulnerable).
local function EntityAllowsDissolveDamage(ent)
    if not IsValid(ent) then return false end
    if ent:IsWorld() then return false end
    -- DAMAGE_NO = 0, DAMAGE_EVENTS_ONLY = 1, DAMAGE_YES = 2
    if ent.GetInternalVariable then
        local td = ent:GetInternalVariable("m_takedamage")
        if td ~= nil and tonumber(td) == 0 then
            return false
        end
    end
    return true
end

-- True once the engine has actually started dissolving this entity.
local function EntityIsDissolvingNow(ent)
    if not IsValid(ent) then return false end
    if ent._PhysFXDissolving then return true end
    if ent.IsFlagSet and FL_DISSOLVING and ent:IsFlagSet(FL_DISSOLVING) then
        return true
    end
    if ent.GetInternalVariable then
        local v = ent:GetInternalVariable("m_bDissolving")
            or ent:GetInternalVariable("m_nDissolveType")
        if v and v ~= 0 and v ~= false then
            return true
        end
    end
    return false
end

-- DMG_DISSOLVE path: only play if the entity can be damaged AND is actually
-- destroyed or enters a dissolving state. Indestructible props that merely
-- receive dissolve damage (e.g. Combine Ball hits) must stay silent.
hook.Add("EntityTakeDamage", "PhysicsSounds_DissolveSound", function(ent, dmginfo)
    if not IsValid(ent) then return end
    local dtype = dmginfo:GetDamageType() or 0
    if bit.band(dtype, DMG_DISSOLVE) == 0 then return end
    if not EntityAllowsDissolveDamage(ent) then return end

    local health = ent:Health() or 0
    local damage = dmginfo:GetDamage() or 0
    if health > 0 and damage < health then
        -- Non-lethal dissolve chip – do not play
        return
    end

    -- Defer one tick: only play if the entity is truly dissolving, or was
    -- destroyed and actually spawned gibs. Props that vanish with no gibs stay silent.
    if ent._PhysFXDissolveDamagePending then return end
    -- Snapshot identity before the entity may be removed this tick
    if IsExplosiveDissolveProp(ent) then return end
    ent._PhysFXDissolveDamagePending = true
    -- Mark immediately so EntityRemoved paths know this entity is dissolving
    -- even if it is removed this tick (before the deferred check).
    ent._PhysFXDissolving = true
    fireCandidates[ent] = nil
    local pos = ent:GetPos()
    local ref = ent
    local modelSnap = string.lower(ent:GetModel() or "")
    timer.Simple(0, function()
        if IsValid(ref) then
            ref._PhysFXDissolveDamagePending = nil
            if EntityIsDissolvingNow(ref) then
                ref._PhysFXDissolving = true
                fireCandidates[ref] = nil
                PlayDissolveSound(ref)
            end
            -- Still alive and not dissolving → indestructible / ignored; stay silent
            return
        end

        -- Exploding barrels / similar: never play dissolve on death
        if ALWAYS_EXPLOSIVE_BARREL[modelSnap]
            or LEAKING_ONLY_MODELS[modelSnap] == "explosive_barrel"
            or MODEL_TO_SOUND[modelSnap] == "explosive_barrel"
            or string.find(modelSnap, "explosive", 1, true) then
            return
        end

        -- Entity was removed this tick. Only play if break gibs actually appeared.
        -- A short extra defer lets PropBreak gibs spawn before we scan.
        timer.Simple(0.05, function()
            if not CV.dissolve:GetBool() then return end

            local hasGibs = false
            for _, e in ipairs(ents.FindInSphere(pos, 160)) do
                if not IsValid(e) then continue end
                local age = CurTime() - (e.GetCreationTime and e:GetCreationTime() or 0)
                if age > 0.2 then continue end
                local class = string.lower(e:GetClass() or "")
                if class == "prop_physics" or class == "prop_physics_multiplayer"
                    or class == "prop_physics_respawnable" or class == "prop_ragdoll"
                    or class == "gib" or class == "prop_gib"
                    or string.find(class, "gib", 1, true) then
                    hasGibs = true
                    break
                end
                local model = string.lower(e:GetModel() or "")
                if string.find(model, "gib", 1, true) or string.find(model, "chunk", 1, true) then
                    hasGibs = true
                    break
                end
            end
            if not hasGibs then return end

            if IsCombineBallGibMode() and InRecentDissolveCluster(pos) then return end
            MarkDissolveCluster(pos)
            sound.Play(DISSOLVE_SOUND, pos, 75, 100, 0.85)
        end)
    end)
end)

-- Natural burnout detection for entities we previously saw ignite.
timer.Create("PhysicsSounds_ExtinguishThink", 0.35, 0, function()
    if not CV.ignite:GetBool() then
        if next(fireCandidates) then
            for ent in pairs(fireCandidates) do
                fireCandidates[ent] = nil
            end
        end
        return
    end

    for ent in pairs(fireCandidates) do
        if not IsValid(ent) then
            fireCandidates[ent] = nil
            continue
        end
        local onFire = ent.IsOnFire and ent:IsOnFire()
        if onFire then
            ent._PhysFXWasOnFire = true
        elseif ent._PhysFXWasOnFire then
            -- Transitioned from on-fire -> extinguished (duration expired or extinguished externally).
            -- Dissolving or already-dead entities stay silent.
            if not ent._PhysFXDissolving then
                local dead = false
                if ent.Health and isfunction(ent.Health) then
                    local hp = ent:Health()
                    dead = isnumber(hp) and hp <= 0
                end
                if not dead then
                    PlayExtinguishSound(ent)
                end
            end
            ent._PhysFXWasOnFire = nil
            fireCandidates[ent] = nil
        else
            fireCandidates[ent] = nil
        end
    end
end)

-- Local cleanup so these tables/functions need not be main-chunk locals.
hook.Add("EntityRemoved", "PhysicsSounds_DissolveIgniteCleanup", function(ent)
    fireCandidates[ent] = nil
    StopDissolveSound(ent)
end)
end)()


local function PlayCustomBreakForEntity(ent)
    if not CV["break"]:GetBool() then return end
    if IsValid(ent) and ent._PhysFXDissolving then return end
    local breakType = GetCustomBreakType(ent)
    if not breakType then return end
    if breakType == "flesh" then
        PlayFleshBreakSounds(ent)
    elseif breakType == "banana" then
        PlayBananaBreakSound(ent)
    elseif breakType == "concrete" then
        PlayEngineBreakSound(ent, "Breakable.Concrete")
    elseif breakType == "dirt" then
        PlayEngineBreakSound(ent, "Wood_Furniture.Break")
    end
end

-- Catch dissolve via damage (e.g. Dissolver beams) when Entity:Dissolve() was not used.

hook.Add("EntityTakeDamage", "PhysicsSounds_CustomBreak", function(ent, dmginfo)
    local breakType = GetCustomBreakType(ent)
    if not breakType then return end
    if ent._PhysFXDissolving then return end
    local dtype = dmginfo:GetDamageType() or 0
    if bit.band(dtype, DMG_DISSOLVE) ~= 0 then
        ent._PhysFXDissolving = true
        return
    end

    local health = ent:Health()
    if health <= 0 then return end
    if dmginfo:GetDamage() < health then return end

    if ent._PhysFXCustomBreakPlayed then return end
    ent._PhysFXCustomBreakPlayed = true

    -- Defer one tick: only play if the prop actually broke (removed / no longer valid).
    -- Avoids break sounds on props that absorb lethal damage without breaking.
    local pos = ent:GetPos()
    local btype = breakType
    timer.Simple(0, function()
        if IsValid(ent) and ent:Health() > 0 then
            -- Still alive – was not actually broken
            ent._PhysFXCustomBreakPlayed = nil
            return
        end
        -- Prop is gone or health depleted; play at last known position if needed
        if IsValid(ent) then
            PlayCustomBreakForEntity(ent)
        else
            -- Entity already removed – play world-space at saved pos for flesh/banana
            if not CV["break"]:GetBool() then return end
            if btype == "flesh" then
                sound.Play(MV(break_SOUND), pos, 75, 100, 0.85)
                if #WATERMELON_IMPACT_HARD > 0 then
                    local snd = NextPoolSound(WATERMELON_IMPACT_HARD, nil, "break_watermelon")
                    if snd then
                        sound.Play(snd, pos, 100, 100, 0.70)
                    end
                end
            elseif btype == "banana" then
                sound.Play(MV(break_SOUND), pos, 75, 100, 0.85)
            elseif btype == "concrete" then
                sound.Play("Breakable.Concrete", pos, 75, 100, 0.90)
            elseif btype == "dirt" then
                sound.Play("Wood_Furniture.Break", pos, 75, 100, 0.90)
            end
        end
    end)
end)

hook.Add("PropBreak", "PhysicsSounds_CustomPropBreak", function(attacker, ent)
    if not IsValid(ent) then return end
    if ent._PhysFXDissolving then return end
    if not GetCustomBreakType(ent) then return end
    if ent._PhysFXCustomBreakPlayed then return end
    ent._PhysFXCustomBreakPlayed = true
    PlayCustomBreakForEntity(ent)
end)

---------------------------------------------------------------------------
-- Phys death sounds (prop / vehicle kills)
---------------------------------------------------------------------------

local BODY_IMPACT_SOUNDS = {
    "physics/body/body_medium_impact_object1.wav",
    "physics/body/body_medium_impact_object2.wav",
    "physics/body/body_medium_impact_object3.wav",
    "physics/body/body_medium_impact_object4.wav",
    "physics/body/body_medium_impact_object5.wav",
    "physics/body/body_medium_impact_object6.wav",
    "physics/body/body_medium_impact_object7.wav",
}
local BODY_BONEBREAK_SOUNDS = {
    "physics/body/body_medium_bonebreak1.wav",
    "physics/body/body_medium_bonebreak2.wav",
    "physics/body/body_medium_bonebreak3.wav",
    "physics/body/body_medium_bonebreak4.wav",
    "physics/body/body_medium_bonebreak5.wav",
    "physics/body/body_medium_bonebreak6.wav",
}
local BODY_GORE_SOUNDS = {
    "physics/body/body_medium_gore1.wav",
    "physics/body/body_medium_gore2.wav",
    "physics/body/body_medium_gore3.wav",
}
MVTable(BODY_IMPACT_SOUNDS)
MVTable(BODY_BONEBREAK_SOUNDS)
MVTable(BODY_GORE_SOUNDS)

local SLICER_KILLER_MODELS = {
    ["models/props_junk/sawblade001a.mdl"]         = true,
    ["models/props_c17/trappropeller_blade.mdl"]   = true,
}
SLICER_KILLER_MODELS = LowerKeys(SLICER_KILLER_MODELS)

local phys_kill_FLESH_MATERIALS = {
    ["flesh"]       = true,
    ["bloodyflesh"] = true,
    ["alienflesh"]  = true,
    ["zombieflesh"] = true,
    ["antlion"]     = true,
    ["hunter"]      = true,
    ["strider"]     = true,
}

local phys_kill_ANTLION_MATERIALS = {
    ["antlion"] = true,
}

local phys_kill_MAT_TYPES = {
    [65] = true,
    [66] = true,
    [70] = true,
    [72] = true,
}
if MAT_ANTLION then phys_kill_MAT_TYPES[MAT_ANTLION] = true end
if MAT_BLOODYFLESH then phys_kill_MAT_TYPES[MAT_BLOODYFLESH] = true end
if MAT_FLESH then phys_kill_MAT_TYPES[MAT_FLESH] = true end
if MAT_ALIENFLESH then phys_kill_MAT_TYPES[MAT_ALIENFLESH] = true end

-- util.GetModelInfo + full KV walk is expensive. Cache per model path.
-- BodyImpactHurt used to call this on every physics-damage tick (ragdoll lag source).
local modelSurfacePropCache = {}

local function GetModelSurfaceProps(model)
    if not isstring(model) or model == "" then return nil end
    local cached = modelSurfacePropCache[model]
    if cached ~= nil then
        return cached ~= false and cached or nil
    end

    local ok, info = pcall(util.GetModelInfo, model)
    if not ok or not istable(info) then
        modelSurfacePropCache[model] = false
        return nil
    end

    local found = {}
    local function consider(val)
        if isstring(val) and val ~= "" then
            found[#found + 1] = string.lower(val)
        end
    end

    local function walk(tbl, depth)
        if not istable(tbl) or (depth or 0) > 12 then return end
        for k, v in pairs(tbl) do
            local key = isstring(k) and string.lower(k) or nil
            if key == "surfaceprop" then
                consider(v)
            elseif istable(v) then
                local ek = v.Key or v.key
                local ev = v.Value or v.value
                if isstring(ek) and string.lower(ek) == "surfaceprop" then
                    consider(ev)
                end
                walk(v, (depth or 0) + 1)
            end
        end
    end

    if isstring(info.KeyValues) then
        local ok2, kv = pcall(util.KeyValuesToTable, info.KeyValues)
        if ok2 then walk(kv, 0) end
        local ok3, kv2 = pcall(util.KeyValuesToTablePreserveOrder, info.KeyValues)
        if ok3 then walk(kv2, 0) end
    elseif istable(info.KeyValues) then
        walk(info.KeyValues, 0)
    end

    consider(info.SurfaceProp)
    consider(info.surfaceprop)

    if #found == 0 then
        modelSurfacePropCache[model] = false
        return nil
    end
    modelSurfacePropCache[model] = found
    return found
end

local function IsPropOrVehicleKiller(ent)
    if not IsValid(ent) then return false end
    if ent:IsVehicle() then return true end
    local class = ent:GetClass()
    -- Combine balls are prop_* but must not trigger body impact / kill sounds.
    if class == "prop_combine_ball" then return false end
    if class == "prop_physics" or class == "prop_physics_multiplayer"
    or class == "prop_ragdoll" or class == "prop_physics_respawnable" then
        return true
    end
    if string.sub(class, 1, 5) == "prop_" then return true end
    if string.find(class, "vehicle", 1, true) then return true end
    return false
end

local function IsSlicerKiller(ent)
    if not IsValid(ent) then return false end
    return SLICER_KILLER_MODELS[GetCachedModel(ent)] == true
end

-- Per-entity cache: full material/model probe only once per victim.
local victimAllowsBodySoundsCache = {}

local function VictimAllowsBodyDeathSounds(victim)
    if not IsValid(victim) then return false end
    if victim:IsPlayer() then return true end

    local cached = victimAllowsBodySoundsCache[victim]
    if cached ~= nil then return cached end

    local okMat, matType = pcall(function() return victim:GetMaterialType() end)
    if okMat and matType and phys_kill_MAT_TYPES[matType] then
        victimAllowsBodySoundsCache[victim] = true
        return true
    end

    local phys = victim:GetPhysicsObject()
    if IsValid(phys) then
        local mat = string.lower(phys:GetMaterial() or "")
        if phys_kill_FLESH_MATERIALS[mat] then
            victimAllowsBodySoundsCache[victim] = true
            return true
        end
    end
    if victim.GetPhysicsObjectNum and victim.GetPhysicsObjectCount then
        local count = math.min(victim:GetPhysicsObjectCount() or 0, 8)
        for i = 0, count - 1 do
            local bonePhys = victim:GetPhysicsObjectNum(i)
            if IsValid(bonePhys) then
                local mat = string.lower(bonePhys:GetMaterial() or "")
                if phys_kill_FLESH_MATERIALS[mat] then
                    victimAllowsBodySoundsCache[victim] = true
                    return true
                end
            end
        end
    end

    local model = victim:GetModel()
    local props = GetModelSurfaceProps(model)
    if props then
        for _, sp in ipairs(props) do
            if phys_kill_FLESH_MATERIALS[sp] then
                victimAllowsBodySoundsCache[victim] = true
                return true
            end
        end
    end

    local class = string.lower(victim:GetClass() or "")
    if class == "npc_hunter" or string.find(class, "hunter", 1, true) then
        victimAllowsBodySoundsCache[victim] = true
        return true
    end

    victimAllowsBodySoundsCache[victim] = false
    return false
end

local function IsVehicleKiller(ent)
    if not IsValid(ent) then return false end
    if ent:IsVehicle() then return true end
    local class = ent:GetClass() or ""
    if string.find(class, "vehicle", 1, true) then return true end
    return false
end

local function IsAntlionWorker(victim)
    if not IsValid(victim) then return false end
    local class = string.lower(victim:GetClass() or "")
    if class == "npc_antlion_worker" then return true end
    if string.find(class, "antlion", 1, true) and string.find(class, "worker", 1, true) then
        return true
    end
    if string.find(class, "antlion", 1, true) and victim.GetSpawnFlags then
        local sf = victim:GetSpawnFlags() or 0
        if bit.band(sf, 262144) ~= 0 then return true end
    end
    return false
end

local function IsAntlionVictim(victim)
    if not IsValid(victim) then return false end
    local class = string.lower(victim:GetClass() or "")
    if string.find(class, "antlion", 1, true) then return true end

    local okMat, matType = pcall(function() return victim:GetMaterialType() end)
    if okMat and matType and ((MAT_ANTLION and matType == MAT_ANTLION) or matType == 65) then
        return true
    end

    local phys = victim:GetPhysicsObject()
    if IsValid(phys) then
        local mat = string.lower(phys:GetMaterial() or "")
        if phys_kill_ANTLION_MATERIALS[mat] then return true end
    end

    local props = GetModelSurfaceProps(victim:GetModel())
    if props then
        for _, sp in ipairs(props) do
            if phys_kill_ANTLION_MATERIALS[sp] then return true end
        end
    end
    return false
end

local function ShouldAntlionGib(ent, dmginfo)
    if not IsValid(ent) or not dmginfo then return false end
    local dtype = dmginfo:GetDamageType() or 0

    if bit.band(dtype, DMG_NEVERGIB) ~= 0 or bit.band(dtype, DMG_DISSOLVE) ~= 0 then
        return false
    end

    if bit.band(dtype, DMG_ALWAYSGIB) ~= 0 or bit.band(dtype, DMG_BLAST) ~= 0 then
        return true
    end

    local predicted = ent:Health() - dmginfo:GetDamage()
    if predicted < -20 then
        return true
    end

    return false
end

hook.Add("EntityTakeDamage", "PhysicsSounds_AntlionGibMark", function(ent, dmginfo)
    if not IsValid(ent) or not IsAntlionVictim(ent) then return end
    if IsAntlionWorker(ent) then
        ent._PhysFXAntlionWillGib = false
        return
    end
    local health = ent:Health()
    if health <= 0 then return end

    local dtype = dmginfo:GetDamageType() or 0
    local damage = dmginfo:GetDamage() or 0
    local lethal = damage >= health
        or bit.band(dtype, DMG_ALWAYSGIB) ~= 0
        or bit.band(dtype, DMG_BLAST) ~= 0
    if not lethal then return end

    if ShouldAntlionGib(ent, dmginfo) then
        ent._PhysFXAntlionWillGib = true
        ent._PhysFXAntlionGibInflictor = dmginfo:GetInflictor()
        ent._PhysFXAntlionGibAttacker = dmginfo:GetAttacker()
    else
        ent._PhysFXAntlionWillGib = false
    end
end)

local function PlayAntlionGibSound(victim)
    if not IsValid(victim) then return end
    if IsAntlionWorker(victim) then return end
    local pos = victim:GetPos()
    sound.Play("NPC_Antlion.RunOverByVehicle", pos, 85, 100, 1.0)
end

local function IsHunterVictim(victim)
    if not IsValid(victim) then return false end
    local class = string.lower(victim:GetClass() or "")
    if class == "npc_hunter" or string.find(class, "hunter", 1, true) then return true end
    local model = string.lower(victim:GetModel() or "")
    if string.find(model, "hunter", 1, true) then return true end
    local phys = victim:GetPhysicsObject()
    if IsValid(phys) then
        local mat = string.lower(phys:GetMaterial() or "")
        if mat == "hunter" or mat == "strider" then return true end
    end
    local props = GetModelSurfaceProps(victim:GetModel())
    if props then
        for _, sp in ipairs(props) do
            if sp == "hunter" or sp == "strider" then return true end
        end
    end
    return false
end

local function IsZombieVictim(victim)
    if not IsValid(victim) then return false end
    local class = string.lower(victim:GetClass() or "")
    local model = string.lower(victim:GetModel() or "")
    if string.find(class, "zombie", 1, true) then return true end
    if string.find(model, "zombie", 1, true) then return true end
    return false
end

local function IsGravGunLaunchedSlicer(ent)
    if not IsValid(ent) then return false end
    return ent._PhysFXGravGunLaunched == true and IsSlicerKiller(ent)
end

local function PlayBodyDeathSounds(victim, inflictor, attacker)
    if not CV.phys_kill:GetBool() then return end
    if not IsValid(victim) then return end
    if not VictimAllowsBodyDeathSounds(victim) then return end

    local isAntlion = IsAntlionVictim(victim)
    local isHunter = IsHunterVictim(victim)
    local isVehicleKill = IsVehicleKiller(inflictor) or IsVehicleKiller(attacker)

    if isHunter and isVehicleKill then return end

    if isAntlion then
        if isVehicleKill then return end
        if victim._PhysFXAntlionWillGib then
            PlayAntlionGibSound(victim)
            return
        end
    end

    local pos = victim:GetPos()
    local useSlicer = IsSlicerKiller(inflictor) or IsSlicerKiller(attacker)

    local suppressSlicer = useSlicer and IsZombieVictim(victim)
        and (IsGravGunLaunchedSlicer(inflictor) or IsGravGunLaunchedSlicer(attacker))

    local function isFunnyPipe(ent)
        if not IsValid(ent) then return false end
        return GetCachedModel(ent) == MATTPIPE_MODEL
    end
    local killPitch = (isFunnyPipe(inflictor) or isFunnyPipe(attacker)) and 50 or 100

    if useSlicer and not suppressSlicer then
        sound.Play("d1_town.Slicer", pos, 85, killPitch, 0.90)
    elseif not useSlicer then
        local snd = NextPoolSound(BODY_IMPACT_SOUNDS, victim, "body_impact")
        if snd then
            sound.Play(snd, pos, 80, killPitch, 0.85)
        end
    end

    if isAntlion then
        sound.Play("FX_AntlionImpact.ShellImpact", pos, 75, killPitch, 0.75)
    else
        local snd = NextPoolSound(BODY_BONEBREAK_SOUNDS, victim, "body_bonebreak")
        if snd then
            sound.Play(snd, pos, 75, killPitch, 0.75)
        end
    end

    -- Gore only on insta-kill (prop/vehicle damage >= health), and only if the victim
    -- was above 15% of max health – finishing off a nearly-dead target stays dry.
    if victim._PhysFXInstaKill then
        local snd = NextPoolSound(BODY_GORE_SOUNDS, victim, "body_gore")
        if snd then
            sound.Play(snd, pos, 75, killPitch, 0.70)
        end
    end
end

local lastBodyImpactHurt = {}
hook.Add("EntityTakeDamage", "PhysicsSounds_BodyImpactHurt", function(ent, dmginfo)
    if not CV.phys_kill:GetBool() then return end
    if not IsValid(ent) then return end
    if not (ent:IsNPC() or ent:IsPlayer()) then return end
    if not VictimAllowsBodyDeathSounds(ent) then return end

    local inflictor = dmginfo:GetInflictor()
    local attacker = dmginfo:GetAttacker()
    if not (IsPropOrVehicleKiller(inflictor) or IsPropOrVehicleKiller(attacker)) then return end

    local damage = dmginfo:GetDamage() or 0
    local health = ent:Health() or 0

    -- Mark insta-kills so death sounds can layer gore.
    -- Skip gore flag when the victim is already at or below 15% of max health.
    if health > 0 and damage >= health then
        local maxHealth = ent:GetMaxHealth() or 0
        if maxHealth <= 0 then maxHealth = health end
        if health > maxHealth * 0.15 then
            ent._PhysFXInstaKill = true
        else
            ent._PhysFXInstaKill = false
        end
    end

    -- Only non-lethal hits below this point
    if health <= 0 or damage >= health then return end

    local isSlicer = IsSlicerKiller(inflictor) or IsSlicerKiller(attacker)
    local isVehicle = IsVehicleKiller(inflictor) or IsVehicleKiller(attacker)

    if IsHunterVictim(ent) and isVehicle and not isSlicer then return end

    local now = CurTime()
    if lastBodyImpactHurt[ent] and (now - lastBodyImpactHurt[ent]) < 0.15 then return end
    lastBodyImpactHurt[ent] = now

    -- Light taps (<= 10 damage) play the impact layer pitched up
    local hitPitch = (damage <= 10) and 115 or 100

    local pos = ent:WorldSpaceCenter() or ent:GetPos()
    if isSlicer then
        sound.Play("Weapon_Knife.Hit", pos, 75, hitPitch, 0.85)
    elseif IsAntlionVictim(ent) then
        sound.Play("FX_AntlionImpact.ShellImpact", pos, 75, hitPitch, 0.70)
    else
        local snd = NextPoolSound(BODY_IMPACT_SOUNDS, ent, "body_impact")
        if snd then
            sound.Play(snd, pos, 75, hitPitch, 0.70)
        end
    end
end)

hook.Add("EntityRemoved", "PhysicsSounds_BodyImpactHurtCleanup", function(ent)
    lastBodyImpactHurt[ent] = nil
    victimAllowsBodySoundsCache[ent] = nil
end)

hook.Add("PlayerDeath", "PhysicsSounds_BodyDeathPlayer", function(victim, inflictor, attacker)
    if IsPropOrVehicleKiller(inflictor) or IsPropOrVehicleKiller(attacker) then
        PlayBodyDeathSounds(victim, inflictor, attacker)
    end
end)

hook.Add("OnNPCKilled", "PhysicsSounds_BodyDeathNPC", function(npc, attacker, inflictor)
    if IsAntlionVictim(npc) and npc._PhysFXAntlionWillGib then
        local gibInf = npc._PhysFXAntlionGibInflictor or inflictor
        local gibAtk = npc._PhysFXAntlionGibAttacker or attacker
        if not (IsVehicleKiller(gibInf) or IsVehicleKiller(gibAtk) or IsVehicleKiller(inflictor) or IsVehicleKiller(attacker)) then
            if CV.phys_kill:GetBool() then
                PlayAntlionGibSound(npc)
            end
        end
        return
    end

    if IsPropOrVehicleKiller(inflictor) or IsPropOrVehicleKiller(attacker) then
        PlayBodyDeathSounds(npc, inflictor, attacker)
    end
end)

local function IsPaintcanEntity(ent)
    if not IsValid(ent) then return false end
    local model = GetCachedModel(ent)
    return PAINTCAN_MODELS[model] == true
        or MODEL_TO_SOUND[model] == "paintcan"
        or GetShakeKey(ent) == "paintcan"
end

---------------------------------------------------------------------------
-- Sawblade / trap-propeller spin, ricochet, stuck & pickup sounds
---------------------------------------------------------------------------

-- Mono water impacts (avoid stereo Underwater.BulletImpact spatial issues).
local SAWBLADE_WATER_IMPACT_SOUNDS = {
    "physics/metal/metal_sawblade_impact_water1.wav",
    "physics/metal/metal_sawblade_impact_water2.wav",
    "physics/metal/metal_sawblade_impact_water3.wav",
}
MVTable(SAWBLADE_WATER_IMPACT_SOUNDS)

local SAWBLADE_RICOCHET_SOUNDS = {
    "physics/metal/ricmono1.wav",
    "physics/metal/ricmono2.wav",
    "physics/metal/ricmono3.wav",
    "physics/metal/ricmono4.wav",
    "physics/metal/ricmono5.wav",
}
MVTable(SAWBLADE_RICOCHET_SOUNDS)
local function PlayRicochetSound(pos, level, pitch, volume)
    level  = level  or 85
    pitch  = pitch  or 100
    volume = volume or 0.90
    local snd = NextPoolSound(SAWBLADE_RICOCHET_SOUNDS, nil, "sawblade_ricochet")
    if snd then
        sound.Play(snd, pos, level, pitch, volume)
    end
end

-- MetalGrate.BulletImpact volume scales with impact speed.
-- Soft floor ~0.35 around 150, full ~0.95 by ~800+.
local function MetalGrateImpactVolume(speed)
    local t = math.Clamp((speed - 150) / 650, 0, 1)
    return 0.35 + t * 0.60
end

local function PlayMetalGrateBulletImpact(pos, impactSpeed)
    local vol = MetalGrateImpactVolume(impactSpeed or 0)
    local level = 70 + math.floor(vol * 15)  -- 70..85
    sound.Play("MetalGrate.BulletImpact", pos, level, 100, vol)
end

local SB = {
    SAWBLADE_SPIN_SND = MV("physics/metal/metal_sawblade_spin_loop1.wav"),
    SAWBLADE_STUCK_PICKUP_SND = "Town.d1_town_03_blade_out",
    SAWBLADE_MILD_VEL = 80,  -- below this the post-bounce wobble loop ends
    SAWBLADE_WOBBLE_MAX_DUR = 5.0,
    SAWBLADE_STOP_VEL = 12,  -- treated as "lost all velocity" on impact
    SAWBLADE_CONTACT_FADE_AFTER = 1.0,  -- continuous surface contact before forced wobble fade
    SAWBLADE_CONTACT_FADE_TIME = 0.45,  -- slower than the normal 0.25s wobble end fade
    PROPELLER_SPIN_STOP = 120,  -- angVel length below this (sustained) => propeller spin ends
    PROPELLER_XY_WOBBLE_MIN = 180,  -- combined |angVel.x|+|angVel.y| to use wobble sound
    PROPELLER_VIOLENT_RICO_SPEED = 520,  -- post-impact speed for violent mono ricochet (ricmono1-5)
    PROPELLER_RICO_BOOST_MIN = 180,  -- min speed gain from impact to count as a ricochet boost
    PROPELLER_RICO_DIR_DOT = 0.20,  -- max old·new dir dot (lower = sharper turn) for ricochet
}

local SAWBLADE_MODELS = {
    ["models/props_junk/sawblade001a.mdl"] = true,
}
local PROPELLER_MODELS = {
    ["models/props_c17/trappropeller_blade.mdl"] = true,
}
SAWBLADE_MODELS  = LowerKeys(SAWBLADE_MODELS)
PROPELLER_MODELS = LowerKeys(PROPELLER_MODELS)

local function IsSawbladeEntity(ent)
    if not IsValid(ent) then return false end
    return SAWBLADE_MODELS[GetCachedModel(ent)] == true
end

local function IsPropellerEntity(ent)
    if not IsValid(ent) then return false end
    return PROPELLER_MODELS[GetCachedModel(ent)] == true
end

local sawbladeSoundPatches = {}  -- [ent] = { patch, mode, start, timerName, isPropeller }

-- Props often report WaterLevel() == 0 even when submerged. Sample several points
-- with PointContents so shallow water / skimming still counts.
local function IsEntityInWater(ent)
    if not IsValid(ent) then return false end

    local wl = ent.WaterLevel and ent:WaterLevel()
    if isnumber(wl) and wl > 0 then return true end

    local function pointInWater(pos)
        if not pos then return false end
        local c = util.PointContents(pos)
        return bit.band(c, CONTENTS_WATER) ~= 0
            or bit.band(c, CONTENTS_SLIME) ~= 0
    end

    local center = ent:WorldSpaceCenter() or ent:GetPos()
    if pointInWater(center) then return true end
    if pointInWater(ent:GetPos()) then return true end
    if pointInWater(center + Vector(0, 0, -12)) then return true end

    local mins = ent:OBBMins()
    if mins then
        local bottom = ent:LocalToWorld(Vector(0, 0, mins.z + 4))
        if pointInWater(bottom) then return true end
    end

    return false
end

local function StopSawbladeSpinSound(ent, fadeTime)
    local data = sawbladeSoundPatches[ent]
    if not data then
        if IsValid(ent) then
            ent._PhysFXSawbladeSpinning = nil
            ent._PhysFXSawbladeWobbling = nil
        end
        return
    end
    -- Always kill the think timer immediately so a removed entity cannot keep ticking.
    if data.timerName then
        timer.Remove(data.timerName)
        data.timerName = nil
    end

    fadeTime = fadeTime or 0
    -- Force-stop path: entity removed, water disarm, or interrupt of an in-progress fade.
    if fadeTime <= 0 or data.fading or not IsValid(ent) then
        if data.patch then data.patch:Stop() end
        sawbladeSoundPatches[ent] = nil
        if IsValid(ent) then
            ent._PhysFXSawbladeSpinning = nil
            ent._PhysFXSawbladeWobbling = nil
        end
        return
    end

    if data.patch then
        data.patch:ChangeVolume(0, fadeTime)
        local e = ent
        timer.Simple(fadeTime + 0.05, function()
            local d = sawbladeSoundPatches[e]
            if not d then return end
            if d.patch then d.patch:Stop() end
            sawbladeSoundPatches[e] = nil
            if IsValid(e) then
                e._PhysFXSawbladeSpinning = nil
                e._PhysFXSawbladeWobbling = nil
            end
        end)
        data.fading = true
        return
    end

    sawbladeSoundPatches[ent] = nil
    if IsValid(ent) then
        ent._PhysFXSawbladeSpinning = nil
        ent._PhysFXSawbladeWobbling = nil
    end
end

-- Stop spin/wobble and clear launch state when a punted blade enters water.
-- Returns true if a disarm happened (plays mono water impact once).
local function DisarmSawbladeInWater(ent)
    if not IsValid(ent) then return false end
    if not IsEntityInWater(ent) then return false end

    local hasSpin = sawbladeSoundPatches[ent] ~= nil
    local wasLaunched = ent._PhysFXGravGunLaunched == true
    if not hasSpin and not wasLaunched then return false end

    local waterSnd = NextPoolSound(SAWBLADE_WATER_IMPACT_SOUNDS, ent, "sawblade_water")
    if waterSnd then
        sound.Play(waterSnd, ent:GetPos(), 75, 100, 0.90)
    end
    StopSawbladeSpinSound(ent, 0)
    ent._PhysFXGravGunLaunched = nil
    ent._PhysFXSawbladeStuck = nil
    ent._PhysFXSawbladeFirstImpactDone = nil
    ent._PhysFXPropellerRicoAt = nil
    ent._PhysFXPropellerImpactAt = nil
    ent._PhysFXSawbladeImpactAt = nil
    return true
end

local function StartSawbladeSpinSound(ent, mode)
    if not CV.sawblade:GetBool() then return end
    if not IsValid(ent) then return end
    StopSawbladeSpinSound(ent, 0)

    local patch = CreateSound(ent, SB.SAWBLADE_SPIN_SND)
    if not patch then return end

    local isPropeller = IsPropellerEntity(ent)
    local timerName = "PhysFX_SawbladeSpin_" .. ent:EntIndex()
    local startTime = CurTime()
    sawbladeSoundPatches[ent] = {
        patch       = patch,
        mode        = mode or "spin",  -- "spin" (mid-air) or "wobble" (post-bounce)
        start       = startTime,
        timerName   = timerName,
        fading      = false,
        isPropeller = isPropeller,
    }

    if mode == "wobble" then
        -- Used after first bounce, and when re-punting an already-armed blade.
        ent._PhysFXSawbladeWobbling = true
        ent._PhysFXSawbladeSpinning = nil
        -- Propellers sit lower; sawblade wobble starts around 95.
        patch:PlayEx(isPropeller and 0.50 or 0.55, isPropeller and 70 or 95)
    else
        ent._PhysFXSawbladeSpinning = true
        ent._PhysFXSawbladeWobbling = nil
        -- Propellers spin lower pitched than sawblades
        patch:PlayEx(0.60, isPropeller and 78 or 100)
        if isPropeller then
            sawbladeSoundPatches[ent].mode = "spin"
        end
    end

    timer.Create(timerName, 0.06, 0, function()
        if not IsValid(ent) then
            StopSawbladeSpinSound(ent, 0)
            return
        end
        local data = sawbladeSoundPatches[ent]
        if not data or not data.patch or data.fading then return end

        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) then
            StopSawbladeSpinSound(ent, 0.08)
            return
        end

        -- Instantly stop sounds when submerged in water (sawblade and propeller).
        if DisarmSawbladeInWater(ent) then
            return
        end

        local linVel = phys:GetVelocity():Length()
        local angVec = phys:GetAngleVelocity()
        local angVel = angVec:Length()
        local elapsed = CurTime() - data.start

        ------------------------------------------------------------------
        -- Propeller: spin while rotating; wobble when X/Y rotation is high;
        -- stop when nearly still.
        ------------------------------------------------------------------
        if data.isPropeller then
            local spin = angVec:Length()
            local xySpin = math.abs(angVec.x) + math.abs(angVec.y)
            local shouldStop = false

            if not phys:IsMotionEnabled() or phys:IsAsleep() then
                shouldStop = true
            elseif spin < SB.PROPELLER_SPIN_STOP then
                if not data.lowSpinSince then
                    data.lowSpinSince = CurTime()
                elseif (CurTime() - data.lowSpinSince) >= 0.35 then
                    shouldStop = true
                end
            else
                data.lowSpinSince = nil
            end

            if not shouldStop and linVel < 25 and spin < (SB.PROPELLER_SPIN_STOP * 2.5) then
                if not data.settleSince then
                    data.settleSince = CurTime()
                elseif (CurTime() - data.settleSince) >= 0.50 then
                    shouldStop = true
                end
            else
                if spin >= (SB.PROPELLER_SPIN_STOP * 2.5) or linVel >= 25 then
                    data.settleSince = nil
                end
            end

            if shouldStop then
                StopSawbladeSpinSound(ent, 0.35)
                if IsValid(ent) then
                    ent._PhysFXGravGunLaunched = nil
                end
                return
            end

            -- Strong X/Y rotation => wobble character; otherwise pure spin.
            if xySpin >= SB.PROPELLER_XY_WOBBLE_MIN then
                if data.mode ~= "wobble" then
                    data.mode = "wobble"
                    ent._PhysFXSawbladeWobbling = true
                    ent._PhysFXSawbladeSpinning = nil
                end
            elseif data.mode == "wobble" then
                data.mode = "spin"
                ent._PhysFXSawbladeWobbling = nil
                ent._PhysFXSawbladeSpinning = true
            end

            local pitch, vol
            if data.mode == "wobble" then
                local phase = elapsed * 11.5 + angVel * 0.0015
                local wobble = math.sin(phase) * (6 + math.min(angVel / 800, 1) * 12)
                wobble = wobble + math.sin(phase * 2.3) * (2 + math.min(angVel / 900, 1) * 5)
                local speedFactor = math.Clamp(math.max(linVel, angVel * 0.12) / 900, 0, 1.15)
                -- Propeller wobble sits lower than sawblade wobble
                pitch = math.Clamp(62 + speedFactor * 28 + wobble, 48, 105)
                vol   = math.Clamp(0.28 + speedFactor * 0.38, 0.22, 0.70)
            else
                local speedFactor = math.Clamp(spin / 1200, 0, 1.25)
                -- Propeller spin is naturally lower pitched than sawblade spin
                pitch = math.Clamp(70 + speedFactor * 28, 62, 110)
                vol   = math.Clamp(0.32 + speedFactor * 0.42, 0.28, 0.80)
            end

            if not data.patch:IsPlaying() then
                data.patch:PlayEx(vol, pitch)
            else
                data.patch:ChangePitch(pitch, 0.05)
                data.patch:ChangeVolume(vol, 0.05)
            end
            return
        end

        if data.mode == "spin" then
            -- Pure mid-air spin: keep looping until we collide (handled in PhysicsCollide).
            local speedFactor = math.Clamp(math.max(linVel, angVel * 0.15) / 1200, 0, 1.2)
            local pitch = math.Clamp(92 + speedFactor * 28, 85, 130)
            local vol   = math.Clamp(0.35 + speedFactor * 0.40, 0.30, 0.78)
            if not data.patch:IsPlaying() then
                data.patch:PlayEx(vol, pitch)
            else
                data.patch:ChangePitch(pitch, 0.05)
                data.patch:ChangeVolume(vol, 0.05)
            end
            return
        end

        -- Sawblade wobble mode: end after 5 s, mild velocity, or 1s continuous surface contact.
        local onSurface = false
        do
            local tr = util.TraceLine({
                start  = ent:GetPos(),
                endpos = ent:GetPos() - Vector(0, 0, 24),
                filter = ent,
                mask   = MASK_SOLID,
            })
            onSurface = tr.Hit == true
            if not onSurface and linVel < 40 and angVel < 120 then
                onSurface = true
            end
        end

        if onSurface then
            if not data.contactSince then
                data.contactSince = CurTime()
            end
        else
            data.contactSince = nil
        end

        local contactDur = data.contactSince and (CurTime() - data.contactSince) or 0
        if contactDur >= SB.SAWBLADE_CONTACT_FADE_AFTER then
            StopSawbladeSpinSound(ent, SB.SAWBLADE_CONTACT_FADE_TIME)
            return
        end

        if elapsed >= SB.SAWBLADE_WOBBLE_MAX_DUR or (linVel < SB.SAWBLADE_MILD_VEL and angVel < 200) then
            StopSawbladeSpinSound(ent, 0.25)
            return
        end

        local phase = elapsed * 11.5 + angVel * 0.0015
        local wobble = math.sin(phase) * (8 + math.min(angVel / 800, 1) * 18)
        wobble = wobble + math.sin(phase * 2.3) * (3 + math.min(angVel / 900, 1) * 6)
        local speedFactor = math.Clamp(math.max(linVel, angVel * 0.12) / 900, 0, 1.15)
        local pitch = math.Clamp(78 + speedFactor * 35 + wobble, 55, 140)
        local vol   = math.Clamp(0.28 + speedFactor * 0.38, 0.22, 0.70)
        if not data.patch:IsPlaying() then
            data.patch:PlayEx(vol, pitch)
        else
            data.patch:ChangePitch(pitch, 0.05)
            data.patch:ChangeVolume(vol, 0.05)
        end
    end)
end

local function HandleSawbladeCollide(ent, colData)
    if not CV.sawblade:GetBool() then return end
    if not IsValid(ent) then return end
    if not ent._PhysFXGravGunLaunched then return end
    if not IsSlicerKiller(ent) then return end

    -- No impact / ricochet / stuck classification against the skybox
    if IsSkySurface(colData and colData.TheirSurfaceProps, colData) then return end

    -- Instant disarm if already in water on impact
    if DisarmSawbladeInWater(ent) then
        return
    end

    local isPropeller = IsPropellerEntity(ent)

    -- While sawblade is wobbling, refresh continuous-contact tracking on every collide.
    if not isPropeller then
        local spinData = sawbladeSoundPatches[ent]
        if spinData and spinData.mode == "wobble" and not spinData.fading then
            if not spinData.contactSince then
                spinData.contactSince = CurTime()
            end
        end
    end

    local alreadyHit = ent._PhysFXSawbladeFirstImpactDone == true
    -- Capture pre-impact velocity for propeller boost / direction-change checks.
    local preVel = (colData and colData.OurOldVelocity) or vector_origin
    local preSpeed = preVel:Length()

    timer.Simple(0, function()
        if not IsValid(ent) then return end
        if not CV.sawblade:GetBool() then return end
        if not ent._PhysFXGravGunLaunched then return end
        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) then return end

        local velAfter   = phys:GetVelocity()
        local speedAfter = velAfter:Length()
        local angAfter   = phys:GetAngleVelocity():Length()
        local stopped    = speedAfter < SB.SAWBLADE_STOP_VEL and angAfter < 40
        local hitPos     = (colData and colData.HitPos) or ent:GetPos()

        ------------------------------------------------------------------
        -- Shared ricochet-style impact classification (boost / sharp turn).
        -- Used for propeller ricochet and for subsequent MetalGrate hits
        -- on both propellers and sawblades.
        ------------------------------------------------------------------
        local boost = speedAfter - preSpeed
        local significantBoost = boost >= SB.PROPELLER_RICO_BOOST_MIN

        local sharpTurn = false
        if preSpeed > 60 and speedAfter > 60 then
            local dirDot = preVel:GetNormalized():Dot(velAfter:GetNormalized())
            sharpTurn = dirDot <= SB.PROPELLER_RICO_DIR_DOT
        elseif preSpeed > 60 and speedAfter > 40 and boost > 0 then
            -- Coming in fast, leaving slower but redirected
            local dirDot = preVel:GetNormalized():Dot(velAfter:GetNormalized())
            sharpTurn = dirDot <= 0
        end

        local shouldRico = (not stopped) and (significantBoost or sharpTurn)

        ------------------------------------------------------------------
        -- Propeller: MetalGrate.BulletImpact guaranteed on first non-stuck
        -- post-punt hit; later only under the same conditions as ricochet.
        -- Volume scales with impact speed. Ricochet is propeller-only.
        ------------------------------------------------------------------
        if isPropeller then
            local function PlayPropellerRicochet(violent)
                local pos = ent:GetPos()
                if violent then
                    local snd = NextPoolSound(SAWBLADE_RICOCHET_SOUNDS, ent, "sawblade_ricochet")
                    if snd then
                        sound.Play(snd, pos, 90, 100, 0.95)
                    end
                else
                    PlayRicochetSound(pos, 85, 100, 0.90)
                end
            end

            local violent = shouldRico and (
                (speedAfter >= SB.PROPELLER_VIOLENT_RICO_SPEED)
                or (boost >= (SB.PROPELLER_RICO_BOOST_MIN * 2.2))
                or (angAfter >= 900 and speedAfter >= (SB.PROPELLER_VIOLENT_RICO_SPEED * 0.55))
            )

            if not alreadyHit then
                ent._PhysFXSawbladeFirstImpactDone = true
                if not stopped then
                    PlayMetalGrateBulletImpact(hitPos, preSpeed)
                end
                if shouldRico then
                    PlayPropellerRicochet(violent)
                end
            else
                -- Subsequent: MetalGrate only under the same gate as ricochet
                if shouldRico and angAfter > SB.PROPELLER_SPIN_STOP then
                    local now = CurTime()
                    if not ent._PhysFXPropellerImpactAt or (now - ent._PhysFXPropellerImpactAt) > 0.12 then
                        ent._PhysFXPropellerImpactAt = now
                        PlayMetalGrateBulletImpact(hitPos, preSpeed)
                    end
                    if not ent._PhysFXPropellerRicoAt or (now - ent._PhysFXPropellerRicoAt) > 0.15 then
                        ent._PhysFXPropellerRicoAt = now
                        PlayPropellerRicochet(violent)
                    end
                end
            end
            return
        end

        ------------------------------------------------------------------
        -- Sawblade: stuck / wall-impact / wobble classification.
        -- MetalGrate.BulletImpact guaranteed on first non-stuck post-punt
        -- hit; later only under the same boost/sharp-turn restrictions as
        -- ricochet. Volume scales with impact speed.
        ------------------------------------------------------------------
        if not alreadyHit then
            ent._PhysFXSawbladeFirstImpactDone = true

            if stopped then
                StopSawbladeSpinSound(ent, 0.08)
                ent._PhysFXSawbladeStuck = true
                ent._PhysFXGravGunLaunched = nil
            else
                PlayMetalGrateBulletImpact(hitPos, preSpeed)
                StartSawbladeSpinSound(ent, "wobble")
            end
            return
        end

        if stopped then
            StopSawbladeSpinSound(ent, 0.08)
            ent._PhysFXGravGunLaunched = nil
        else
            -- Subsequent non-stuck contacts: only under ricochet-style conditions
            if shouldRico then
                local now = CurTime()
                if not ent._PhysFXSawbladeImpactAt or (now - ent._PhysFXSawbladeImpactAt) > 0.12 then
                    ent._PhysFXSawbladeImpactAt = now
                    PlayMetalGrateBulletImpact(hitPos, preSpeed)
                end
            end
        end
    end)
end

local function PlaySawbladeStuckPickup(ent)
    if not CV.sawblade:GetBool() then return end
    if not IsValid(ent) then return end
    -- Propellers never stick – no pickup cue.
    if IsPropellerEntity(ent) then return end
    if not ent._PhysFXSawbladeStuck then return end
    ent._PhysFXSawbladeStuck = nil
    -- No pitch override – let the soundscript define pitch (engine default 100 = unmodified)
    sound.Play(SB.SAWBLADE_STUCK_PICKUP_SND, ent:GetPos(), 75, 100, 0.85)
end

-- Only actual gravity-gun PUNTS trigger paint splash / slicer spin.
local function MarkGravGunPunted(ent)
    if not IsValid(ent) then return end

    if IsPaintcanEntity(ent) then
        ent._PhysFXPaintFirstImpact = true
    end

    if IsSlicerKiller(ent) then
        -- Already submerged: never arm launch state or spin/ricochet/stuck sounds.
        if IsEntityInWater(ent) then
            StopSawbladeSpinSound(ent, 0)
            ent._PhysFXGravGunLaunched = nil
            ent._PhysFXSawbladeFirstImpactDone = nil
            ent._PhysFXSawbladeStuck = nil
            ent._PhysFXPropellerRicoAt = nil
            ent._PhysFXPropellerImpactAt = nil
            ent._PhysFXSawbladeImpactAt = nil
            return
        end

        -- Re-punt while still armed (mid-flight / still spinning or wobbling):
        -- switch to wobble instead of restarting a pure mid-air spin.
        local alreadyArmed = ent._PhysFXGravGunLaunched
            or ent._PhysFXSawbladeSpinning
            or ent._PhysFXSawbladeWobbling
            or (sawbladeSoundPatches[ent] ~= nil)

        ent._PhysFXGravGunLaunched = true
        ent._PhysFXSawbladeFirstImpactDone = nil
        ent._PhysFXSawbladeStuck = nil
        ent._PhysFXPropellerRicoAt = nil
        ent._PhysFXPropellerImpactAt = nil
        ent._PhysFXSawbladeImpactAt = nil
        if CV.sawblade:GetBool() then
            StartSawbladeSpinSound(ent, alreadyArmed and "wobble" or "spin")
        end
    end
end

hook.Add("GravGunPunt", "PhysicsSounds_GravGunPuntEffects", function(ply, ent)
    -- Mark immediately so collide logic works the same frame.
    MarkGravGunPunted(ent)
    if IsValid(ent) then
        ent._PhysFXWasPunted = true
    end
end)

-- Attack2 / soft release: GravGunOnDropped fires for both punt and drop.
-- Disarm only when this was NOT a punt (no _PhysFXWasPunted, low launch speed).
hook.Add("GravGunOnDropped", "PhysicsSounds_GravGunGentleDrop", function(ply, ent)
    if not IsValid(ent) then return end

    timer.Simple(0, function()
        if not IsValid(ent) then return end

        if ent._PhysFXWasPunted then
            ent._PhysFXWasPunted = nil
            return
        end

        -- Soft drop: no paint splash, no spin/ricochet/stuck.
        ent._PhysFXPaintFirstImpact = nil
        ent._PhysFXGravGunLaunched = nil
        ent._PhysFXSawbladeFirstImpactDone = nil
        ent._PhysFXSawbladeStuck = nil
        ent._PhysFXPropellerRicoAt = nil
        ent._PhysFXPropellerImpactAt = nil
        ent._PhysFXSawbladeImpactAt = nil
        StopSawbladeSpinSound(ent, 0.08)
    end)
end)

-- Stuck-blade pickup cue (gravity gun or +use). Also stop any residual spin loop.
hook.Add("GravGunOnPickedUp", "PhysicsSounds_SawbladeStuckPickup", function(ply, ent)
    StopSawbladeSpinSound(ent, 0.06)
    PlaySawbladeStuckPickup(ent)
end)

hook.Add("OnPlayerPhysicsPickup", "PhysicsSounds_SawbladeStuckPickupPhys", function(ply, ent)
    StopSawbladeSpinSound(ent, 0.06)
    PlaySawbladeStuckPickup(ent)
end)

-- Physgun grab of a sawblade stuck in a wall: Combine mine close-hooks cue.
hook.Add("OnPhysgunPickup", "PhysicsSounds_SawbladeStuckPhysgun", function(ply, ent)
    if not CV.sawblade:GetBool() then return end
    if not IsValid(ent) then return end
    if not IsSawbladeEntity(ent) then return end
    if not ent._PhysFXSawbladeStuck then return end
    ent._PhysFXSawbladeStuck = nil
    StopSawbladeSpinSound(ent, 0.06)
    sound.Play("NPC_CombineMine.CloseHooks", ent:GetPos(), 75, 100, 0.90)
end)

hook.Add("EntityTakeDamage", "PhysicsSounds_StrainOnPhysDamage", function(ent, dmginfo)
    if not CV.strain:GetBool() then return end
    if not IsValid(ent) then return end
    if IsStrainExcluded(ent) then return end
    if ent:GetClass() == "prop_ragdoll" then return end
    if not CanHearStrain(ent) then return end

    local dtype = dmginfo:GetDamageType()
    if bit.band(dtype, DMG_CRUSH) == 0 and bit.band(dtype, DMG_VEHICLE) == 0
       and bit.band(dtype, DMG_FALL) == 0 and bit.band(dtype, DMG_PHYSGUN) == 0 then
        return
    end
    if bit.band(dtype, DMG_BLAST) ~= 0 or bit.band(dtype, DMG_BURN) ~= 0
       or bit.band(dtype, DMG_BULLET) ~= 0 or bit.band(dtype, DMG_CLUB) ~= 0
       or bit.band(dtype, DMG_SLASH) ~= 0 or bit.band(dtype, DMG_SONIC) ~= 0 then
        return
    end

    local attacker = dmginfo:GetAttacker()
    if IsValid(attacker) and (attacker:IsPlayer() or attacker:IsNPC()) then return end

    local health = ent:Health()
    if health > 0 and dmginfo:GetDamage() >= health then return end

    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    local mat = string.lower(phys:GetMaterial() or "")
    local strainKey = GetStrainKeyForEntity(ent, mat)
    if not strainKey then return end

    local isMetalMat = METAL_STRAIN_MATERIALS[mat] == true
    if isMetalMat and phys:GetMass() < CV.min_metal_mass:GetFloat() then return end

    local now = CurTime()
    if lastDamageStrain[ent] and (now - lastDamageStrain[ent]) < 0.35 then return end
    if strainPlaying[ent] and now < strainPlaying[ent] then return end

    lastDamageStrain[ent] = now
    strainPlaying[ent] = now + CV.strain_duration:GetFloat()
    local vol = math.Clamp(0.10 + dmginfo:GetDamage() / 80, 0.10, 0.35)
    local snd = ResolveStrainSound(strainKey, ent)
    if not snd then return end
    if strainKey == "bone" then
        sound.Play(snd, ent:GetPos(), 70, 100, vol)
    else
        ent:EmitSound(snd, 70, 100, vol, CHAN_BODY)
    end
end)

-- Bone bullet/melee/pickup sounds: gated by surface overrides
local lastBoneBulletImpact = {}
hook.Add("EntityTakeDamage", "PhysicsSounds_BoneBulletImpact", function(ent, dmginfo)
    if not CV.surfaces:GetBool() then return end
    if not IsValid(ent) then return end

    local model = GetCachedModel(ent)
    if MODEL_TO_SOUND[model] ~= "bone" then return end

    local dtype = dmginfo:GetDamageType()
    local isBullet = bit.band(dtype, DMG_BULLET) ~= 0
    local isMelee  = bit.band(dtype, DMG_CLUB) ~= 0 or bit.band(dtype, DMG_SLASH) ~= 0
    if not isBullet and not isMelee then return end

    local now = CurTime()
    if lastBoneBulletImpact[ent] and (now - lastBoneBulletImpact[ent]) < CV.impact_cooldown:GetFloat() then return end
    lastBoneBulletImpact[ent] = now

    local set = CUSTOM_SOUNDS.bone
    if not set or not set.bullet or #set.bullet == 0 then return end
    local snd = NextPoolSound(set.bullet, ent, "bone_bullet")
    if not snd then return end
    local dmg = dmginfo:GetDamage() or 10
    local vol = math.Clamp(0.25 + dmg / 80, 0.25, 0.70)
    sound.Play(snd, ent:GetPos(), 75, 100, vol)
end)

hook.Add("EntityRemoved", "PhysicsSounds_BoneBulletCleanup", function(ent)
    lastBoneBulletImpact[ent] = nil
end)

hook.Add("OnPlayerPhysicsPickup", "PhysicsSounds_BoneUsePickup", function(ply, ent)
    if not CV.surfaces:GetBool() then return end
    if not IsValid(ent) or not IsBoneModel(ent) then return end

    local set = CUSTOM_SOUNDS.bone
    if not set or not set.soft or #set.soft == 0 then return end

    local snd = NextPoolSound(set.soft, ent, "bone_soft")
    if snd then
        sound.Play(snd, ent:GetPos(), 70, 100, 0.35)
    end
end)

---------------------------------------------------------------------------
-- OPTIMIZED Ragdoll stretch think (candidate set only)
---------------------------------------------------------------------------

timer.Create("PhysicsSounds_RagdollStretchThink", 0.20, 0, function()
    if not CV.strain:GetBool() then return end
    if not next(ragdollCandidates) then return end

    local now = CurTime()
    local thinkInterval = 0.20

    for ent in pairs(ragdollCandidates) do
        if not IsValid(ent) then
            ragdollCandidates[ent] = nil
            ragdollBreakAccum[ent] = nil
            ragdollPressurePlayed[ent] = nil
            ragdollColTimes[ent] = nil
            continue
        end
        if IsStrainExcluded(ent) then
            ragdollBreakAccum[ent] = nil
            continue
        end

        local rootPhys = ent:GetPhysicsObject()
        if not IsValid(rootPhys) then
            ragdollBreakAccum[ent] = nil
            continue
        end

        if not CanHearStrain(ent) then
            ragdollBreakAccum[ent] = nil
            continue
        end

        local mat = string.lower(rootPhys:GetMaterial() or "")
        local strainKey = GetStrainKeyForEntity(ent, mat)
        if not strainKey then
            ragdollBreakAccum[ent] = nil
            continue
        end
        local isFleshMat = FLESH_MATERIALS[mat] == true
        local isMetalMat = METAL_STRAIN_MATERIALS[mat] == true
        local isExtraRagdoll = EXTRA_RAGDOLL_STRAIN_MATERIALS[mat] == true or strainKey == "bone"
        if not isFleshMat and not isMetalMat and not isExtraRagdoll then
            ragdollBreakAccum[ent] = nil
            continue
        end

        -- Shared torso sample for pressure + contact in this tick.
        local torsoPositions = GetRagdollTorsoPositions(ent)

        ------------------------------------------------------------------
        -- One-shot prop-mass pressure (true contact, not hover / lift-off):
        --   ≥ 250 kg : Break on first contact
        --   75–250 kg: Strain when resting; Break if impact speed is high
        --   < 75 kg  : Strain only with notable impact speed
        -- Props moving upward (lifted off) are ignored entirely.
        -- Single upward trace from torso center (shared torso sample).
        ------------------------------------------------------------------
        local topMass, topSpeed = GetRagdollTopPressureInfo(ent, torsoPositions)
        if topMass <= 0 then
            ragdollPressurePlayed[ent] = nil
        else
            local played = ragdollPressurePlayed[ent] or 0
            local wantLevel = 0

            if topMass >= RAGDOLL_PRESSURE_BREAK_MASS then
                wantLevel = 2
            elseif topMass >= RAGDOLL_PRESSURE_LIGHT_MASS then
                if topSpeed >= RAGDOLL_PRESSURE_BREAK_SPEED then
                    wantLevel = 2
                else
                    wantLevel = 1
                end
            else
                if topSpeed >= RAGDOLL_PRESSURE_STRAIN_SPEED then
                    wantLevel = 1
                end
            end

            if wantLevel > played then
                local soundToPlay, vol
                if isFleshMat then
                    if wantLevel >= 2 then
                        soundToPlay = "Flesh.Break"
                        vol = 0.22
                    else
                        soundToPlay = ResolveStrainSound(strainKey, ent)
                        if not soundToPlay or soundToPlay == "" then
                            soundToPlay = "Flesh.Strain"
                        end
                        vol = 0.14
                    end
                else
                    soundToPlay = ResolveStrainSound(strainKey, ent)
                    vol = 0.12
                end
                if soundToPlay then
                    if strainKey == "bone" then
                        sound.Play(soundToPlay, ent:GetPos(), 70, 100, vol)
                    else
                        ent:EmitSound(soundToPlay, 70, 100, vol, CHAN_BODY)
                    end
                end
                ragdollPressurePlayed[ent] = wantLevel
            end
        end

        -- Motion-based strain is skipped while fully asleep (mass handled above).
        if rootPhys:IsAsleep() then
            ragdollBreakAccum[ent] = nil
            continue
        end

        -- One contact scan shared into severity (avoids a second full probe set).
        local floorHit, sideHit, anyHit = RagdollContactInfo(ent, torsoPositions)
        local severity = RagdollGetStrainSeverity(ent, floorHit, sideHit, anyHit)
        if not severity then
            ragdollBreakAccum[ent] = nil
            continue
        end

        ------------------------------------------------------------------
        -- Flesh.Break sustain gate for motion freakouts (not mass – mass is
        -- one-shot above). Brief constraint snap-backs never accumulate.
        ------------------------------------------------------------------
        local playBreak = false
        if severity >= 3 then
            local accum = (ragdollBreakAccum[ent] or 0) + thinkInterval
            ragdollBreakAccum[ent] = accum
            if accum >= RAGDOLL_BREAK_SUSTAIN then
                playBreak = true
            end
        else
            ragdollBreakAccum[ent] = nil
        end

        local effectiveSeverity = severity
        if severity >= 3 and not playBreak then
            effectiveSeverity = 2
        end

        local allowMulti = effectiveSeverity >= 2
            and CanHearStrain(ent, HIGH_VEL_STRAIN_MAX_DIST_SQR, true)

        if not allowMulti then
            if strainPlaying[ent] and now < strainPlaying[ent] then continue end
        else
            local count = activeStrainCount[ent] or 0
            if count >= CV.max_concurrent_strain:GetInt() then
                if lastStrainTime[ent] and (now - lastStrainTime[ent]) < 0.05 then continue end
            end
            local cd = CV.strain_cooldown:GetFloat()
            if playBreak then cd = cd * 0.75 end
            if lastStrainTime[ent] and (now - lastStrainTime[ent]) < cd then continue end
        end

        lastStrainTime[ent] = now
        if allowMulti then
            activeStrainCount[ent] = (activeStrainCount[ent] or 0) + 1
            timer.Simple(0.70, function()
                if activeStrainCount[ent] then
                    activeStrainCount[ent] = math.max(0, (activeStrainCount[ent] or 1) - 1)
                end
            end)
        else
            strainPlaying[ent] = now + CV.strain_duration:GetFloat()
        end

        local soundToPlay
        if isFleshMat then
            if playBreak then
                soundToPlay = "Flesh.Break"
            else
                soundToPlay = ResolveStrainSound(strainKey, ent)
                if not soundToPlay or soundToPlay == "" then
                    soundToPlay = "Flesh.Strain"
                end
            end
        else
            soundToPlay = ResolveStrainSound(strainKey, ent)
        end

        local vol = 0.08
        if playBreak then
            vol = 0.22
        elseif effectiveSeverity >= 2 then
            vol = 0.15
        end

        if strainKey == "bone" then
            sound.Play(soundToPlay, ent:GetPos(), 70, 100, vol)
        else
            ent:EmitSound(soundToPlay, 70, 100, vol, CHAN_BODY)
        end
    end
end)

---------------------------------------------------------------------------
-- Shake
---------------------------------------------------------------------------

local lastShakeTime    = {}
local prevVelocity     = {}
local orbitYawHistory  = {}
local activeShakeCount = {}
local lastSuitcaseStep = {}  -- footstep rattle cooldown for citizens holding suitcase weapons

local function PlayShakeSound(ent, jerk, isBarrel)
    if not IsValid(ent) then return end

    local key = GetShakeKey(ent)
    if not key then return end

    if key == "cardboard" then
        if not CV.cardboard_shake:GetBool() then return end
    else
        if not CV.shake:GetBool() then return end
        if key == "health" and not CV.health_sounds:GetBool() then return end
    end

    local pool = SHAKE_SOUNDS[key]
    if not pool or #pool == 0 then return end

    local now = CurTime()
    local minJerk = isBarrel and CV.shake_min_jerk_barrel:GetFloat() or CV.shake_min_jerk:GetFloat()
    if jerk < minJerk then return end

    local count = activeShakeCount[ent] or 0
    if count >= CV.max_concurrent_shake:GetInt() then
        if lastShakeTime[ent] and (now - lastShakeTime[ent]) < 0.04 then return end
    end
    if lastShakeTime[ent] and (now - lastShakeTime[ent]) < CV.shake_cooldown:GetFloat() then return end
    lastShakeTime[ent] = now

    activeShakeCount[ent] = count + 1
    timer.Simple(0.60, function()
        if activeShakeCount[ent] then
            activeShakeCount[ent] = math.max(0, (activeShakeCount[ent] or 1) - 1)
        end
    end)

    local intensity = math.Clamp((jerk - minJerk) / 500, 0, 1)
    local volume = 0.20 + intensity * 0.45
    local pitch  = 100

    if key == "health" then
        volume = CV.health_shake_base:GetFloat() + intensity * CV.health_shake_scale:GetFloat()
    elseif key == "paintcan" then
        if HAS_MYVOICE then
            volume = CV.health_shake_base:GetFloat() + intensity * CV.health_shake_scale:GetFloat()
            pitch = 90
        else
            volume = 0.22 + intensity * 0.40
            pitch = 100
        end
    elseif key == "pistol" then
        pitch = 118
    elseif key == "gascan" and HAS_MYVOICE then
        pitch = 118
    elseif key == "cardboard" then
        local model = GetCachedModel(ent)
        pitch = CARDBOARD_SHAKE_MODELS[model] or 100
    elseif key == "crate" then
        pitch = 90
    elseif key == "wood_suitcase" then
        pitch = 110
    elseif key == "suitcase" then
        local model = GetCachedModel(ent)
        pitch = CLOTH_SUITCASE_MODELS[model] or 100
    elseif key == "dumpster" then
        local model = GetCachedModel(ent)
        pitch = DUMPSTER_MODELS[model] or 75
    end

    if key == "supplycrate" then
        local pos = ent:GetPos()
        local primary = NextPoolSound(SHAKE_SOUNDS.supplycrate, ent, "shake_supplycrate")
        if primary then
            sound.Play(primary, pos, 70, pitch, volume)
        end
        if math.random() < SUPPLYCRATE_OVERLAY_CHANCE and #SUPPLYCRATE_OVERLAY > 0 then
            local overlay = NextPoolSound(SUPPLYCRATE_OVERLAY, ent, "shake_supplycrate_overlay")
            if overlay then
                sound.Play(overlay, pos, 65, pitch, volume * 0.55)
            end
        end
        return
    end

    -- Crate / wood_suitcase: supplycrate pool, no ammo overlay (handled via pitch above)
    if key == "crate" or key == "wood_suitcase" then
        local pos = ent:GetPos()
        local primary = NextPoolSound(SHAKE_SOUNDS[key], ent, "shake_" .. key)
        if primary then
            sound.Play(primary, pos, 70, pitch, volume)
        end
        return
    end

    local snd = NextPoolSound(pool, ent, "shake_" .. key)
    if snd then
        sound.Play(snd, ent:GetPos(), 70, pitch, volume)
    end

    if key == "shotgun" or key == "ammo357" then
        local overlay = NextPoolSound(SHAKE_SOUNDS.cardboard, ent, "shake_cardboard_overlay")
        if overlay then
            sound.Play(overlay, ent:GetPos(), 65, 110, volume * 0.45)
        end
    end
end

-- Track held props (orbit suppression only – shake works for free-moving props too)
hook.Add("OnPlayerPhysicsPickup", "PhysicsSounds_TrackHeld", function(ply, ent)
    if IsValid(ent) then
        heldProps[ent] = true
    end
end)

hook.Add("OnPlayerPhysicsDrop", "PhysicsSounds_TrackHeldDrop", function(ply, ent)
    if IsValid(ent) then
        heldProps[ent] = nil
        orbitYawHistory[ent] = nil
        -- Keep prevVelocity so tumbling after drop continues to rattle smoothly
    end
end)

hook.Add("GravGunOnPickedUp", "PhysicsSounds_TrackHeldGrav", function(ply, ent)
    if IsValid(ent) then
        heldProps[ent] = true
    end
end)

hook.Add("GravGunOnDropped", "PhysicsSounds_TrackHeldGravDrop", function(ply, ent)
    if IsValid(ent) then
        heldProps[ent] = nil
        orbitYawHistory[ent] = nil
    end
end)

-- Hybrid shake think:
--   1. Fast path for currently-held props (responsive when the player shakes them)
--   2. PVS scan around every player so free-moving / tumbling props (boxes down stairs,
--      rolling barrels, etc.) also produce rattle sounds when someone is nearby enough
--      to potentially hear them. Props with no players in PVS are ignored (cheap + natural).
timer.Create("PhysicsSounds_ShakeThink", 0.12, 0, function()
    if not CV.shake:GetBool() and not CV.cardboard_shake:GetBool() then return end

    local players = GetPlayerCache()
    if #players == 0 then return end

    -- Collect unique shake-relevant entities this tick (held + anything near a player)
    local toCheck = {}

    -- 1) Held props always get checked (even if somehow outside PVS)
    for ent in pairs(heldProps) do
        if IsValid(ent) then
            toCheck[ent] = true
        else
            heldProps[ent] = nil
            prevVelocity[ent] = nil
            orbitYawHistory[ent] = nil
            activeShakeCount[ent] = nil
        end
    end

    -- 2) Discovery for free-tumbling candidates:
    --    DistToSqr first (cheap), TestPVS only for nearby candidates, skip PVS when very close.
    if next(shakeCandidates) then
        local plyCount = #players
        for ent in pairs(shakeCandidates) do
            if not IsValid(ent) then
                shakeCandidates[ent] = nil
                continue
            end
            if toCheck[ent] then continue end

            local epos = ent:GetPos()
            for i = 1, plyCount do
                local pd = players[i]
                local d = epos:DistToSqr(pd.pos)
                if d > SHAKE_HEAR_DIST_SQR then continue end

                if d <= PVS_SKIP_DIST_SQR then
                    toCheck[ent] = true
                    break
                end

                local ply = pd.ply
                if not ply.TestPVS or ply:TestPVS(ent) then
                    toCheck[ent] = true
                    break
                end
            end
        end
    end

    if not next(toCheck) then return end

    for ent in pairs(toCheck) do
        if not IsValid(ent) then
            shakeCandidates[ent] = nil
            heldProps[ent] = nil
            prevVelocity[ent] = nil
            orbitYawHistory[ent] = nil
            activeShakeCount[ent] = nil
            continue
        end

        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) or not phys:IsMotionEnabled() then
            prevVelocity[ent] = nil
            continue
        end

        -- Skip fully asleep physics – no motion means no shake
        if phys:IsAsleep() then
            prevVelocity[ent] = nil
            continue
        end

        local vel  = phys:GetVelocity()
        local prev = prevVelocity[ent]
        local isHeld = heldProps[ent] == true

        -- Orbit suppression only applies while a player is actively holding the prop
        local isOrbiting = false
        if isHeld then
            local epos = ent:GetPos()
            local nearPos = nil
            for i = 1, #players do
                local pd = players[i]
                if epos:DistToSqr(pd.pos) < (250 * 250) then
                    nearPos = pd.pos
                    break
                end
            end
            if nearPos then
                local toEnt = epos - nearPos
                local yaw   = math.atan2(toEnt.y, toEnt.x)
                local hist  = orbitYawHistory[ent]
                if hist then
                    local delta = math.AngleDifference(math.deg(yaw), math.deg(hist.lastYaw))
                    if math.abs(delta) > 2 then
                        local dir = delta > 0 and 1 or -1
                        if dir == hist.lastDir then
                            hist.consistent = hist.consistent + 1
                        else
                            hist.consistent = 1
                            hist.lastDir = dir
                        end
                        if hist.consistent >= CV.orbit_limit:GetInt() then
                            isOrbiting = true
                        end
                    end
                    hist.lastYaw = yaw
                else
                    orbitYawHistory[ent] = { lastYaw = yaw, lastDir = 0, consistent = 0 }
                end
            end
        end

        if prev and not isOrbiting then
            local jerk = (vel - prev):Length()
            local model = GetCachedModel(ent)
            local isBarrel = UsesExplosiveBarrelSounds(ent)
                          or model == "models/props_junk/gascan001a.mdl"
                          or (HAS_LEAKING_BARRELS and LEAKING_ONLY_MODELS[model] ~= nil)
            PlayShakeSound(ent, jerk, isBarrel)
        end
        prevVelocity[ent] = vel
    end

    -- Prune velocity history for entities that left every player's consideration
    -- (prevents unbounded growth if many candidates exist far away)
    for ent in pairs(prevVelocity) do
        if not toCheck[ent] then
            prevVelocity[ent] = nil
            orbitYawHistory[ent] = nil
        end
    end
end)

---------------------------------------------------------------------------
-- Rolling (OPTIMIZED – candidate set only)
---------------------------------------------------------------------------

local rollData = {}

local function IsLyingOnSide(ent)
    local model = GetCachedModel(ent)
    if not SIDEWAYS_ONLY_MODELS[model] then return true end
    local up = ent:GetAngles():Up()
    local threshold = METAL_BARREL_MODELS[model] and 0.72 or 0.55
    return math.abs(up.z) < threshold
end

local function IsGrounded(ent)
    local mins, maxs = ent:GetCollisionBounds()
    local center = ent:GetPos()
    local tr = util.TraceHull({
        start = center, endpos = center - Vector(0, 0, 14),
        mins = mins * 0.55, maxs = maxs * 0.55, filter = ent, mask = MASK_SOLID,
    })
    return tr.Hit
end

local function IsNearFloor(ent, maxDist)
    maxDist = maxDist or 20
    local tr = util.TraceLine({
        start = ent:GetPos(), endpos = ent:GetPos() - Vector(0, 0, maxDist),
        filter = ent, mask = MASK_SOLID,
    })
    return tr.Hit
end

local function IsOnSoftSurface(ent)
    local tr = util.TraceLine({
        start = ent:GetPos(),
        endpos = ent:GetPos() - Vector(0, 0, 24),
        filter = ent,
        mask = MASK_SOLID,
    })
    if not tr.Hit then return false end
    return IsSoftSurface(tr.SurfaceProps)
end

local function StartRollSound(ent, sndName, allowMainRoll)
    if allowMainRoll == nil then allowMainRoll = true end
    local data = rollData[ent]
    if data and not data.fading then
        local mainOk = (allowMainRoll and data.patch and data.patch:IsPlaying())
                    or ((not allowMainRoll) and (not data.patch or not data.patch:IsPlaying()))
        local wantSlosh = CV.slosh_roll:GetBool() and UsesExplosiveBarrelSounds(ent)
        local sloshOk = (not wantSlosh and not data.sloshPatch)
                     or (wantSlosh and data.sloshPatch and data.sloshPatch:IsPlaying())
        if mainOk and sloshOk then return end
    end
    if data and data.patch then data.patch:Stop() end
    if data and data.sloshPatch then data.sloshPatch:Stop() end

    local patch = nil
    if allowMainRoll then
        patch = CreateSound(ent, sndName)
        if patch then patch:PlayEx(0.05, 100) end
    end

    local sloshPatch = nil
    if CV.slosh_roll:GetBool() and UsesExplosiveBarrelSounds(ent) then
        sloshPatch = CreateSound(ent, MV("physics/metal/metal_barrel_sloshroll_loop.wav"))
        if sloshPatch then
            sloshPatch:PlayEx(0.04, 100)
        end
    end

    if not patch and not sloshPatch then
        rollData[ent] = nil
        return
    end
    rollData[ent] = { patch = patch, sloshPatch = sloshPatch, snd = sndName, fading = false }
end

local function FadeOutRollSound(ent)
    local data = rollData[ent]
    if not data or data.fading then return end
    data.fading = true
    local patch = data.patch
    local slosh = data.sloshPatch
    local steps, stepTime = 8, 0.045
    for i = 1, steps do
        timer.Simple(i * stepTime, function()
            if not IsValid(ent) or not rollData[ent] then return end
            local vol = 0.4 * (1 - (i / steps))
            if vol <= 0.02 then
                if patch then patch:Stop() end
                if slosh then slosh:Stop() end
                if rollData[ent] and rollData[ent].patch == patch then rollData[ent] = nil end
            else
                if patch then patch:ChangeVolume(vol, 0) end
                if slosh then slosh:ChangeVolume(vol * 0.7, 0) end
            end
        end)
    end
end

local function StopRollSoundImmediate(ent)
    local data = rollData[ent]
    if data then
        if data.patch then data.patch:Stop() end
        if data.sloshPatch then data.sloshPatch:Stop() end
        data.fading = true -- abort any in-flight FadeOutRollSound steps
    end
    rollData[ent] = nil
end

local function UpdateRollSound(ent, angVel, linVel)
    local data = rollData[ent]
    if not data or data.fading then return end
    local speedFactor = math.Clamp((angVel - 55) / 650, 0, 1)
    speedFactor = speedFactor * 0.65 + math.Clamp(linVel / 400, 0, 1) * 0.35
    local pitch = math.Clamp(85 + speedFactor * 40, 85, 125)
    local vol   = math.Clamp(0.08 + speedFactor * 0.45, 0.08, 0.55)
    if data.patch then
        data.patch:ChangePitch(pitch, 0.1)
        data.patch:ChangeVolume(vol, 0.1)
    end
    if data.sloshPatch then
        data.sloshPatch:ChangePitch(pitch, 0.1)
        data.sloshPatch:ChangeVolume(vol * 0.65, 0.1)
    end
end

timer.Create("PhysicsSounds_RollThink", 0.18, 0, function()
    if not CV.roll:GetBool() then
        for ent, data in pairs(rollData) do
            if data.patch then data.patch:Stop() end
            if data.sloshPatch then data.sloshPatch:Stop() end
            rollData[ent] = nil
        end
        return
    end

    if not next(rollCandidates) then return end

    for ent in pairs(rollCandidates) do
        if not IsValid(ent) then
            rollCandidates[ent] = nil
            StopRollSoundImmediate(ent)
            continue
        end

        local class = ent:GetClass()
        if class == "prop_ragdoll" then
            FadeOutRollSound(ent)
            continue
        end

        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) or not phys:IsMotionEnabled() then
            FadeOutRollSound(ent)
            continue
        end

        -- Skip sleeping physics objects
        if phys:IsAsleep() then
            FadeOutRollSound(ent)
            continue
        end

        local rollSnd = GetRollSoundForEntity(ent)
        if not rollSnd then
            FadeOutRollSound(ent)
            continue
        end

        local isFragGrenade = (class == "npc_grenade_frag")
        local isMetalBarrel = METAL_BARREL_MODELS[GetCachedModel(ent)]
        local angVel        = phys:GetAngleVelocity():Length()
        local linVel        = phys:GetVelocity():Length()
        local model         = GetCachedModel(ent)
        local isRolling     = false

        if isFragGrenade then
            if IsNearFloor(ent, 32) and linVel > 40 and linVel < 900 then isRolling = true end
        elseif isMetalBarrel then
            if not IsNearFloor(ent, 18) or not IsLyingOnSide(ent) then
                FadeOutRollSound(ent)
                continue
            end
            isRolling = angVel > 50 and linVel > 18 and linVel < 700
        else
            if not IsGrounded(ent) or not IsLyingOnSide(ent) then
                FadeOutRollSound(ent)
                continue
            end
            if PAINTCAN_MODELS[model] then
                isRolling = angVel > 140 and linVel > 40 and linVel < 500
                            and math.abs(phys:GetAngleVelocity().z) > 60
            else
                isRolling = angVel > 80 and linVel > 25 and linVel < 650
            end
        end

        if isRolling then
            local allowMain = not IsOnSoftSurface(ent)
            local allowSlosh = CV.slosh_roll:GetBool() and UsesExplosiveBarrelSounds(ent)
            if allowMain or allowSlosh then
                StartRollSound(ent, rollSnd, allowMain)
                if isFragGrenade then
                    UpdateRollSound(ent, angVel * 0.4 + linVel * 0.8, linVel)
                else
                    UpdateRollSound(ent, angVel, linVel)
                end
            else
                FadeOutRollSound(ent)
            end
        else
            FadeOutRollSound(ent)
        end
    end
end)

---------------------------------------------------------------------------
-- Entity processing (OPTIMIZED – selective PhysicsCollide)
---------------------------------------------------------------------------

local function NeedsCustomImpact(ent)
    local class = ent:GetClass()
    -- Ragdolls must NOT get a PhysicsCollide callback just for strain.
    -- A single hard impact fires one contact per bone (10–15+ callbacks), which is the
    -- cyan net_graph microstutter even when strain is disabled / early-outs.
    -- Ragdoll strain is handled by PhysicsSounds_RagdollStretchThink (+ damage path).
    local isRagdoll = (class == "prop_ragdoll")

    if CLASS_TO_SOUND[class] then return true end
    local model = GetCachedModel(ent)
    local soundKey = MODEL_TO_SOUND[model]
    -- Bone/skeleton impacts: only when surface overrides are enabled
    -- (playback is also surfaces-gated inside PlayCustomImpact).
    if soundKey == "bone" then
        return CV.surfaces:GetBool()
    end
    if soundKey then return true end
    if model == MATTPIPE_MODEL then return true end
    if SLICER_KILLER_MODELS[model] then return true end
    -- Non-ragdoll props: strain can also fire from collide
    if not isRagdoll then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            local mat = string.lower(phys:GetMaterial() or "")
            if STRAIN_SOUNDS[mat] then return true end
        end
    end
    return false
end

local function ProcessEntity(ent, surfaceRetry)
    if not IsValid(ent) then return end
    local class = ent:GetClass()
    local model = GetCachedModel(ent)

    -- Model not assigned yet (common for some map/mod spawns). Retry once shortly.
    if model == "" and not surfaceRetry then
        timer.Simple(0.1, function()
            if IsValid(ent) then ProcessEntity(ent, true) end
        end)
        -- Still register candidates / callbacks below with whatever we have.
    end

    if CV.surfaces:GetBool() then
        if model == "models/props/cs_assault/barrelwarning.mdl"
        or model == "models/props_silo/barrelwarning.mdl"
        or model == "models/props_borealis/bluebarrel001.mdl" then
            ApplySurface(ent, "Plastic_Barrel")
        elseif METAL_BARREL_MODELS[model] then
            ApplySurface(ent, "metal_barrel")
        end
        local override = SURFACE_OVERRIDES[class] or MODEL_OVERRIDES[model]
        if override then ApplySurface(ent, override) end
        -- Grenade surface: defer material check until physics exists (ApplySurface retries).
        if model ~= "" and string.find(model, "grenade", 1, true) then
            local function TryGrenadeSurface(attemptsLeft)
                if not IsValid(ent) then return end
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then
                    local current = string.lower(phys:GetMaterial() or "")
                    if GRENADE_SOURCE_SURFACES[current] then
                        ApplySurface(ent, "Grenade")
                    end
                    return
                end
                if (attemptsLeft or 0) > 1 then
                    timer.Simple(0.05, function()
                        TryGrenadeSurface((attemptsLeft or 8) - 1)
                    end)
                end
            end
            TryGrenadeSurface(8)
        end
    end

    -- Register for candidate thinks
    RegisterCandidates(ent)

    -- Lightweight entity-collision counter for ALL ragdolls (freakout rate detection).
    -- Counts only hits against other entities, not world. Does not play audio.
    if class == "prop_ragdoll" and not ent._PhysFXColCountCB then
        ent._PhysFXColCountCB = true
        ent:AddCallback("PhysicsCollide", function(e, data)
            if not IsValid(e) then return end
            RecordRagdollSurfaceCollision(e, data)
        end)
    end

    -- Only attach expensive PhysicsCollide when the entity can actually produce custom sounds
    if not ent._CustomImpactCB and NeedsCustomImpact(ent) then
        ent._CustomImpactCB = true
        ent:AddCallback("PhysicsCollide", function(e, data)
            if not IsValid(e) then return end

            -- Ragdolls fire PhysicsCollide once per bone contact. A single hard impact can
            -- produce a dozen near-simultaneous callbacks; running full sound logic for each
            -- causes the cyan net_graph microstutters. Coalesce to one deferred pass per ent.
            local isRagdoll = e:GetClass() == "prop_ragdoll"
            if isRagdoll and e._PhysFXColPending then
                -- Keep the strongest impact sample for the pending pass.
                local pending = e._PhysFXColData
                local newSpd = (data.OurOldVelocity and data.OurOldVelocity:Length()) or data.Speed or 0
                local oldSpd = 0
                if pending then
                    oldSpd = (pending.OurOldVelocity and pending.OurOldVelocity:Length()) or pending.Speed or 0
                end
                if newSpd > oldSpd then
                    e._PhysFXColData = {
                        OurOldVelocity    = data.OurOldVelocity,
                        Speed             = data.Speed,
                        HitSpeed          = data.HitSpeed,
                        DeltaTime         = data.DeltaTime,
                        HitEntity         = data.HitEntity,
                        HitPos            = data.HitPos,
                        TheirSurfaceProps = data.TheirSurfaceProps,
                        HitNormal         = data.HitNormal,
                    }
                end
                return
            end

            local col = {
                OurOldVelocity    = data.OurOldVelocity,
                Speed             = data.Speed,
                HitSpeed          = data.HitSpeed,
                DeltaTime         = data.DeltaTime,
                HitEntity         = data.HitEntity,
                HitPos            = data.HitPos,
                TheirSurfaceProps = data.TheirSurfaceProps,
                HitNormal         = data.HitNormal,
            }

            if isRagdoll then
                e._PhysFXColPending = true
                e._PhysFXColData = col
                timer.Simple(0, function()
                    if not IsValid(e) then return end
                    e._PhysFXColPending = nil
                    local c = e._PhysFXColData
                    e._PhysFXColData = nil
                    if not c then return end
                    -- Impact-only for ragdolls that need it (e.g. bone models).
                    -- Strain is owned by RagdollStretchThink to avoid collide spam.
                    PlayCustomImpact(e, c)
                end)
            else
                -- Non-ragdolls: still defer off the physics callback, but no coalesce needed.
                timer.Simple(0, function()
                    if not IsValid(e) then return end
                    PlayCustomImpact(e, col)
                    PlayStrainSound(e, col)
                    TryMattpipeBounce(e, col)
                    HandleSawbladeCollide(e, col)
                end)
            end
        end)
    end
end

hook.Add("OnEntityCreated", "PhysicsSounds_Items_Override", function(ent)
    -- First pass next tick; second pass covers map/mod props whose model or
    -- physics object is not ready on the initial creation frame.
    timer.Simple(0, function()
        if IsValid(ent) then ProcessEntity(ent) end
    end)
    timer.Simple(0.15, function()
        if IsValid(ent) then ProcessEntity(ent, true) end
    end)
end)

hook.Add("InitPostEntity", "PhysicsSounds_Items_Override_Existing", function()
    for _, ent in ipairs(ents.GetAll()) do
        ProcessEntity(ent)
    end
    -- Late pass for map entities whose physics initialize after InitPostEntity.
    timer.Simple(0.5, function()
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) then ProcessEntity(ent, true) end
        end
    end)
end)

if CLIENT then
    hook.Add("OnEntityCreated", "PhysicsSounds_Items_Override_Client", function(ent)
        timer.Simple(0.05, function()
            if IsValid(ent) then ProcessEntity(ent) end
        end)
        timer.Simple(0.2, function()
            if IsValid(ent) then ProcessEntity(ent, true) end
        end)
    end)
end

hook.Add("EntityRemoved", "PhysicsSounds_Cleanup", function(ent)
    -- Force-stop all looping CreateSound patches and their named timers first.
    StopRollSoundImmediate(ent)
    StopMattpipeSound(ent)
    StopSawbladeSpinSound(ent, 0) -- fadeTime 0 = hard stop, even mid-fade

    -- Candidate / tracking sets
    modelCache[ent]         = nil
    rollCandidates[ent]     = nil
    ragdollCandidates[ent]  = nil
    shakeCandidates[ent]    = nil
    heldProps[ent]          = nil

    -- Impact / strain / shake state
    lastCustomImpact[ent]   = nil
    lastRawPoolSound[ent]   = nil
    strainPlaying[ent]      = nil
    strainContactStart[ent] = nil
    lastStrainTime[ent]     = nil
    activeStrainCount[ent]  = nil
    ragdollBreakAccum[ent]  = nil
    ragdollPressurePlayed[ent] = nil
    ragdollColTimes[ent]    = nil
    lastShakeTime[ent]      = nil
    prevVelocity[ent]       = nil
    orbitYawHistory[ent]    = nil
    activeShakeCount[ent]   = nil
    lastDamageStrain[ent]   = nil
    lastSuitcaseStep[ent]   = nil

    -- Other per-ent tables (also cleared by their own hooks; belt-and-suspenders)
    if lastBoneBulletImpact then lastBoneBulletImpact[ent] = nil end
    if lastBodyImpactHurt then lastBodyImpactHurt[ent] = nil end
    if victimAllowsBodySoundsCache then victimAllowsBodySoundsCache[ent] = nil end
end)

---------------------------------------------------------------------------
-- Citizen suitcase footstep rattle
-- When a player or NPC holds weapon_citizensuitcase (or common variants),
-- play wood-suitcase shake sounds on each step. Volume scales with horizontal
-- velocity (running = max). Slightly quieter than prop shakes overall.
---------------------------------------------------------------------------

local SUITCASE_WEAPON_CLASSES = {
    ["weapon_citizensuitcase"] = true,
    ["weapon_suitcase"]        = true,
}

local SUITCASE_STEP_MIN_SPEED = 50
local SUITCASE_STEP_MAX_SPEED = 250  -- ~running speed for full volume

-- Players: only when the suitcase is the *active* weapon (pass activeOnly = true).
-- NPCs: broader checks (inventory / children / owner) because scripted citizens
-- often don't report the suitcase as GetActiveWeapon().
local function IsHoldingCitizenSuitcase(ent, activeOnly)
    if not IsValid(ent) then return false end

    local wep = ent.GetActiveWeapon and ent:GetActiveWeapon()
    if IsValid(wep) and SUITCASE_WEAPON_CLASSES[string.lower(wep:GetClass() or "")] then
        return true
    end

    if activeOnly then return false end

    -- NPC weapon inventory
    if ent.GetWeapons then
        local weapons = ent:GetWeapons()
        if istable(weapons) then
            for _, w in ipairs(weapons) do
                if IsValid(w) and SUITCASE_WEAPON_CLASSES[string.lower(w:GetClass() or "")] then
                    return true
                end
            end
        end
    end

    -- Child entities (common for scripted citizens)
    for _, child in ipairs(ent:GetChildren()) do
        if IsValid(child) and SUITCASE_WEAPON_CLASSES[string.lower(child:GetClass() or "")] then
            return true
        end
    end

    -- Owned weapon entities
    for _, w in ipairs(ents.FindByClass("weapon_citizensuitcase")) do
        if IsValid(w) and w:GetOwner() == ent then return true end
    end
    for _, w in ipairs(ents.FindByClass("weapon_suitcase")) do
        if IsValid(w) and w:GetOwner() == ent then return true end
    end

    return false
end

local function PlaySuitcaseStepSound(ent, speed)
    if not CV.shake:GetBool() then return end
    local pool = SHAKE_SOUNDS.wood_suitcase
    if not pool or #pool == 0 then return end

    local t = math.Clamp((speed - SUITCASE_STEP_MIN_SPEED) / math.max(1, SUITCASE_STEP_MAX_SPEED - SUITCASE_STEP_MIN_SPEED), 0, 1)
    -- Slightly reduced volume; max ~0.40 when sprinting
    local volume = 0.12 + t * 0.28
    local pitch  = 110  -- same +10 as wood suitcase prop shakes

    local snd = NextPoolSound(pool, ent, "suitcase_step")
    if snd then
        sound.Play(snd, ent:GetPos(), 65, pitch, volume)
    end
end

-- Players: exact footstep timing — only when suitcase is the active weapon
hook.Add("PlayerFootstep", "PhysicsSounds_CitizenSuitcaseStep", function(ply, pos, foot, soundName, volume, filter)
    if not IsValid(ply) or not IsHoldingCitizenSuitcase(ply, true) then return end
    local speed = ply:GetVelocity():Length2D()
    if speed < SUITCASE_STEP_MIN_SPEED then return end
    PlaySuitcaseStepSound(ply, speed)
end)

-- NPCs: fire on their real footstep sounds so the rattle stays perfectly in sync
hook.Add("EntityEmitSound", "PhysicsSounds_CitizenSuitcaseNPCStep", function(data)
    if not CV.shake:GetBool() then return end
    local ent = data.Entity
    if not IsValid(ent) or not ent:IsNPC() then return end

    local name = string.lower(data.SoundName or data.OriginalSoundName or "")
    if not (string.find(name, "footstep", 1, true)
         or string.find(name, "stepleft", 1, true)
         or string.find(name, "stepright", 1, true)
         or string.find(name, ".step", 1, true)) then
        return
    end

    if not IsHoldingCitizenSuitcase(ent) then return end

    local speed = ent:GetVelocity():Length2D()
    if speed < SUITCASE_STEP_MIN_SPEED then
        speed = SUITCASE_STEP_MIN_SPEED  -- still give a quiet rattle on slow scripted walks
    end

    local now = CurTime()
    if lastSuitcaseStep[ent] and (now - lastSuitcaseStep[ent]) < 0.18 then return end
    lastSuitcaseStep[ent] = now

    PlaySuitcaseStepSound(ent, speed)
end)

-- Fallback velocity sampler for citizens whose footsteps don't emit a detectable sound name
timer.Create("PhysicsSounds_SuitcaseNPCStep", 0.16, 0, function()
    if not CV.shake:GetBool() then return end

    for _, ent in ipairs(ents.FindByClass("npc_citizen")) do
        if not IsValid(ent) then continue end
        if not IsHoldingCitizenSuitcase(ent) then continue end
        if not ent.OnGround or not ent:OnGround() then continue end

        local speed = ent:GetVelocity():Length2D()
        if speed < SUITCASE_STEP_MIN_SPEED then continue end

        local now = CurTime()
        local interval = math.Clamp(0.50 - (speed / 700), 0.22, 0.50)
        if lastSuitcaseStep[ent] and (now - lastSuitcaseStep[ent]) < interval then continue end

        lastSuitcaseStep[ent] = now
        PlaySuitcaseStepSound(ent, speed)
    end
end)

---------------------------------------------------------------------------
-- Spawnmenu
---------------------------------------------------------------------------

if CLIENT then
    local function AddHeader(panel, text)
        local lbl = panel:Help(text)
        lbl:SetTextColor(Color(255, 200, 100))
        return lbl
    end

    local PRESETS = {
        ["Default"] = {
            physfx_enable_impacts         = "1",
            physfx_enable_strain          = "1",
            physfx_enable_shake           = "1",
            physfx_enable_roll            = "1",
            physfx_enable_surfaces        = "1",
            physfx_enable_mattpipe        = "1",
            physfx_enable_cardboard_shake = "1",
            physfx_enable_health_sounds   = "1",
            physfx_enable_slosh_roll      = "1",
            physfx_enable_break           = "1",
            physfx_enable_paint_splash    = "1",
            physfx_enable_phys_kill       = "1",
            physfx_enable_sawblade        = "1",
            physfx_enable_dissolve        = "1",
            physfx_enable_ignite          = "1",
            physfx_min_impact_speed       = "180",
            physfx_hard_impact_speed      = "380",
            physfx_impact_cooldown        = "0.12",
            physfx_strain_duration        = "0.9",
            physfx_strain_buildup         = "0.35",
            physfx_strain_cooldown        = "0.12",
            physfx_max_concurrent_strain  = "4",
            physfx_high_vel_strain        = "1000",
            physfx_min_metal_mass         = "35",
            physfx_shake_cooldown         = "0.09",
            physfx_shake_min_jerk         = "400",
            physfx_shake_min_jerk_barrel  = "525",
            physfx_orbit_limit            = "6",
            physfx_max_concurrent_shake   = "5",
            physfx_mattpipe_chance        = "0.0025",
            physfx_health_impact_vol      = "0.22",
            physfx_health_shake_base      = "0.10",
            physfx_health_shake_scale     = "0.22",
        },
        ["Real Beta"] = {
            physfx_enable_impacts         = "0",
            physfx_enable_strain          = "1",
            physfx_enable_shake           = "0",
            physfx_enable_roll            = "1",
            physfx_enable_surfaces        = "0",
            physfx_enable_mattpipe        = "1",
            physfx_enable_cardboard_shake = "1",
            physfx_enable_health_sounds   = "0",
            physfx_enable_slosh_roll      = "0",
            physfx_enable_break           = "0",
            physfx_enable_paint_splash    = "0",
            physfx_enable_phys_kill       = "0",
            physfx_enable_sawblade        = "0",
            physfx_enable_dissolve        = "0",
            physfx_enable_ignite          = "0",
            physfx_min_impact_speed       = "180",
            physfx_hard_impact_speed      = "380",
            physfx_impact_cooldown        = "0.12",
            physfx_strain_duration        = "0.9",
            physfx_strain_buildup         = "0.35",
            physfx_strain_cooldown        = "0.12",
            physfx_max_concurrent_strain  = "4",
            physfx_high_vel_strain        = "1000",
            physfx_min_metal_mass         = "35",
            physfx_shake_cooldown         = "0.09",
            physfx_shake_min_jerk         = "400",
            physfx_shake_min_jerk_barrel  = "525",
            physfx_orbit_limit            = "6",
            physfx_max_concurrent_shake   = "5",
            physfx_mattpipe_chance        = "0.0025",
            physfx_health_impact_vol      = "0.22",
            physfx_health_shake_base      = "0.10",
            physfx_health_shake_scale     = "0.22",
        },
    }

    local function ApplyPreset(name)
        local preset = PRESETS[name]
        if not preset then return end
        for k, v in pairs(preset) do
            RunConsoleCommand(k, v)
        end
        local ply = LocalPlayer()
        if IsValid(ply) then
            ply:ChatPrint("[Extended Physics Sounds] Applied preset: " .. name)
        end
    end

    hook.Add("PopulateToolMenu", "PhysicsSounds_OptionsMenu", function()
        spawnmenu.AddToolMenuOption("Options", "Concon's Mods", "PhysicsSounds_Settings", "Extended Phys Sounds", "", "", function(panel)
            panel:ClearControls()
            panel:Help("Extended & Restored Physics Sounds settings")

            AddHeader(panel, "Presets")
            local combo = vgui.Create("DComboBox")
            combo:SetTall(24)
            combo:SetValue("Select a preset…")
            combo:AddChoice("Default")
            combo:AddChoice("Real Beta")
            combo.OnSelect = function(_, _, value)
                ApplyPreset(value)
            end
            panel:AddItem(combo)
            panel:ControlHelp("Default: all features on.  Real Beta: only the restored roll, strain, and cardboard shake sounds on.")

            panel:ControlHelp("")
            AddHeader(panel, "Toggles")
            panel:CheckBox("Impact Sounds", "physfx_enable_impacts")
            panel:ControlHelp("Custom extra sounds when certain props hit things.")
            panel:CheckBox("Shake Sounds", "physfx_enable_shake")
            panel:ControlHelp("Custom sounds when certain props are shaken (ammo boxes, barrels, etc.).")
            panel:CheckBox("Cardboard Box Shakes", "physfx_enable_cardboard_shake")
            panel:ControlHelp("Toggle cardboard box shaking sounds, in case it bothers you that cardboard boxes are empty, yet make rattling sounds. Also seperate from the global shake sounds toggle, in case you ONLY want cardboard boxes to make shaking sounds, just like Gaben intended.")
            panel:CheckBox("Health Kit / Vial Sounds", "physfx_enable_health_sounds")
            panel:ControlHelp("Toggle health item impact and shake sounds. Disable if a replacement medkit model should not sound like liquid.")
            panel:CheckBox("Rolling Sounds", "physfx_enable_roll")
            panel:ControlHelp("Custom sounds when certain props roll across the ground.")
            panel:CheckBox("Barrel Slosh-Roll Layer", "physfx_enable_slosh_roll")
            panel:ControlHelp("Toggle extra liquid slosh sound layered on explosive barrels while they roll.")
            panel:CheckBox("Strain Sounds", "physfx_enable_strain")
            panel:ControlHelp("Creaking when certain props are strained, crushed, thrown around, etc.")
            panel:CheckBox("Surface Material Overrides", "physfx_enable_surfaces")
            panel:ControlHelp("Forces more realistic physics materials on certain props.")
            panel:CheckBox("Custom Break Sounds", "physfx_enable_break")
            panel:ControlHelp("Toggle custom break sounds for certain props that lack them.")
            panel:CheckBox("Paint Can Splash Sounds", "physfx_enable_paint_splash")
            panel:ControlHelp("Toggle sound for paint cans splattering paint")
            panel:CheckBox("Physics Damage Sounds", "physfx_enable_phys_kill")
            panel:ControlHelp("Toggle impact sounds when a prop or vehicle hurts/kills an NPC or player.")
            panel:CheckBox("Sawblade / Propeller Sounds", "physfx_enable_sawblade")
            panel:ControlHelp("Toggle custom sound system for Gravity Gun-punted sawblades/propellers.")
            panel:CheckBox("Dissolve Sounds", "physfx_enable_dissolve")
            panel:ControlHelp("Toggle disintegration sounds.")
            panel:CheckBox("Ignite Sounds", "physfx_enable_ignite")
            panel:ControlHelp("Toggle ignite and extinguish sounds.")
            panel:Help("Type  find physfx_  in the console for more advanced options.")
            panel:Help("")
        end)
    end)
end

print("[Extended Physics Sounds] loaded")
