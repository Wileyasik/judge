util.AddNetworkString("HGNotificate")
util.AddNetworkString("HGNotificateBerserk")
util.AddNetworkString("HGThought")

--local hg_old_notificate = ConVarExists("hg_old_notificate") and GetConVar("hg_old_notificate") or CreateConVar("hg_old_notificate",0,FCVAR_SERVER_CAN_EXECUTE,"enable old notifications (chatprints)",0,1)
local hev_color = Color(255,125,0)
local CreateThought
local thoughtMessages = {
    panicattack_start = "You are experiencing a panic attack.",
    panicattack_heartstop = "Your heart stopped.",
    wake = "You regained consciousness.",
    dislocations_unlucky = "The joint is back in place.",
    painfromjawspeak = "Your jaw hurts when you speak.",
    arteria = "Your carotid artery is gushing out blood.",
    take_gasmask = "The gas mask is suffocating you.",
    take_gasmask2 = "The gas mask is suffocating you.",
    oxygen_lowintake = "You are not getting enough air.",
    lowoxy = "You are low on oxygen.",
    lowoxy2 = "You are low on oxygen.",
    drugged = "You are drugged.", 
    pneumothorax1 = "Something is filling your lungs.",
    pneumothorax2 = "It is getting harder to breathe.",
    pneumothorax3 = "You are struggling to breathe.",
    brain = "Your brain is damaged.",
    blood2 = "You are close to fainting.",
    internalbleed = "You are bleeding internally.",
    hungry = "You are hungry.",
    heart = "You feel a sharp pain from your chest.",
    heartstop = "Your heart stopped.",
    painfrommoving = "Your leg hurts when you move.",
    painfromjaw = "Your jaw hurts.",
    painfromribs = "Your broken ribs make it painful to breathe.",
}

local scpcbHitgroupToCat = {
    [HITGROUP_HEAD] = "head",
    [HITGROUP_CHEST] = "chest",
    [HITGROUP_STOMACH] = "stomach",
    [HITGROUP_LEFTARM] = "leftarm",
    [HITGROUP_RIGHTARM] = "rightarm",
    [HITGROUP_LEFTLEG] = "leftleg",
    [HITGROUP_RIGHTLEG] = "rightleg",
    [HITGROUP_GENERIC] = "generic",
    [8] = "pelvis"
}

local scpcbThoughts = {
    head = {
        "A {weapon} struck your head, killing you instantly.",
        "A {weapon} hit your head, killing you instantly.",
        "A {weapon} pierced your skull, ending your life instantly.",
        "A {weapon} struck your temple, killing you instantly.",
        "A {weapon} shattered your cranium, killing you instantly.",
        "A {weapon} tore through your brain, killing you instantly.",
        "A {weapon} hit your forehead, ending your life instantly.",
        "A {weapon} struck your head, causing immediate brain death.",
        "A {weapon} shattered your head, ending it all instantly."
    },
    pelvis = {
        "The {weapon} pierces your pelvis, narrowly missing your nads.",
        "A {weapon} strikes your waist, causing severe pain.",
        "A {weapon} hits your pelvis, making you cringe.",
        "A {weapon} grazes your groin, narrowly missing your nads.",
        "A {weapon} shatters your hip, making you stumble."
    },
    pelvis_lethal = {
        "A {weapon} destroyed your pelvis, causing fatal blood loss.",
        "A {weapon} tore through your waist, severing an artery.",
        "A {weapon} shattered your pelvis, killing you from shock."
    },
    head_nonlethal = {
        "A {weapon} hit your head, causing severe pain.",
        "A {weapon} struck your head.",
        "A {weapon} hit your skull, making you dizzy.",
        "A {weapon} grazed your head, leaving a laceration.",
        "A {weapon} struck your skull, leaving you dazed.",
        "A {weapon} hit your head, making you gasp."
    },
    chest = {
        "A {weapon} hit your chest, making you gasp.",
        "A {weapon} struck your chest, making you gasp.",
        "A {weapon} hit your ribs, causing severe pain.",
        "A {weapon} struck your chest. Breathing becomes difficult.",
        "A {weapon} penetrated your chest.",
        "A {weapon} hit your chest, causing pain."
    },
    chest_lethal = {
        "A {weapon} struck your chest, causing fatal internal injuries.",
        "A {weapon} hit your chest, destroying your heart.",
        "A {weapon} tore through your lung, drowning you in blood.",
        "A {weapon} struck your chest, killing you instantly.",
        "A {weapon} shattered your ribcage, puncturing your heart."
    },
    stomach = {
        "A {weapon} hit your stomach, making you gasp.",
        "A {weapon} struck your gut, causing severe pain.",
        "A {weapon} hit your abdomen.",
        "A {weapon} struck your stomach, causing pain.",
        "A {weapon} penetrated your stomach."
    },
    stomach_lethal = {
        "A {weapon} struck your stomach, causing fatal internal bleeding.",
        "A {weapon} tore through your gut, killing you.",
        "A {weapon} hit your liver, causing massive bleeding.",
        "A {weapon} destroyed your stomach, ending your life."
    },
    leftarm = {
        "A {weapon} hit your left arm.",
        "A {weapon} struck your left arm.",
        "A {weapon} hit your left shoulder.",
        "A {weapon} struck your left forearm.",
        "A {weapon} pierced your left arm."
    },
    leftarm_lethal = {
        "A {weapon} severed your left arm, causing fatal blood loss.",
        "A {weapon} tore through your left arm, hitting an artery.",
        "A {weapon} shattered your left shoulder, killing you from shock.",
        "A {weapon} destroyed your left arm, causing you to bleed out."
    },
    rightarm = {
        "A {weapon} hit your right arm.",
        "A {weapon} struck your right arm.",
        "A {weapon} hit your right shoulder.",
        "A {weapon} struck your right forearm.",
        "A {weapon} pierced your right arm."
    },
    rightarm_lethal = {
        "A {weapon} severed your right arm, causing fatal blood loss.",
        "A {weapon} tore through your right arm, hitting an artery.",
        "A {weapon} shattered your right shoulder, killing you from shock.",
        "A {weapon} destroyed your right arm, causing you to bleed out."
    },
    leftleg = {
        "A {weapon} hit your left leg.",
        "A {weapon} struck your left leg.",
        "A {weapon} hit your left thigh.",
        "A {weapon} struck your left calf.",
        "A {weapon} hit your left knee.",
        "A {weapon} pierced your left leg."
    },
    leftleg_lethal = {
        "A {weapon} severed your left leg, causing fatal blood loss.",
        "A {weapon} tore through your left thigh, severing the femoral artery.",
        "A {weapon} shattered your left leg, killing you from shock.",
        "A {weapon} destroyed your left leg, causing you to bleed out."
    },
    rightleg = {
        "A {weapon} hit your right leg.",
        "A {weapon} struck your right leg.",
        "A {weapon} hit your right thigh.",
        "A {weapon} struck your right calf.",
        "A {weapon} hit your right knee.",
        "A {weapon} pierced your right leg."
    },
    rightleg_lethal = {
        "A {weapon} severed your right leg, causing fatal blood loss.",
        "A {weapon} tore through your right thigh, severing the femoral artery.",
        "A {weapon} shattered your right leg, killing you from shock.",
        "A {weapon} destroyed your right leg, causing you to bleed out."
    },
    generic = {
        "A {weapon} hit you.",
        "A {weapon} struck you.",
        "A {weapon} hit your body.",
        "A {weapon} struck your torso.",
        "A {weapon} hit you, causing pain."
    },
    generic_lethal = {
        "A {weapon} hit you, killing you instantly.",
        "A {weapon} struck you, causing fatal trauma.",
        "A {weapon} hit your body, ending your life.",
        "A {weapon} tore through you, causing fatal damage."
    },
    near_miss = {
        "A {weapon} barely missed you.",
        "A {weapon} whizzed past your head.",
        "A {weapon} flew by your ear.",
        "A {weapon} narrowly missed you.",
        "A {weapon} grazed past you.",
        "A {weapon} passed within inches of your head.",
        "A {weapon} went past you.",
        "A {weapon} missed you, but barely."
    },
    armor_full = {
        "A {weapon} hit your chest. The vest absorbed most of the damage.",
        "A {weapon} hit your chest. The vest absorbed some of the damage.",
        "A {weapon} struck your vest. Armor absorbed the impact.",
        "A {weapon} hit your vest.",
        "A {weapon} struck your vest."
    },
    armor_partial = {
        "A {weapon} hit your chest. The vest absorbed some of the damage.",
        "A {weapon} struck your chest. Vest compromised.",
        "A {weapon} hit your chest. Plating cracked but stopped the impact.",
        "A {weapon} struck your vest, partially penetrating.",
        "A {weapon} hit your chest. Armor slowed the strike, but it still hit you."
    }
}

local function SCPCBThoughtDamageType(dmginfo, target)
    if dmginfo:IsBulletDamage() or dmginfo:IsDamageType(DMG_BUCKSHOT) then return "bullet" end
    if dmginfo:IsDamageType(DMG_SLASH) then return "slash" end
    if dmginfo:IsDamageType(DMG_CLUB) or dmginfo:IsDamageType(DMG_CRUSH) then return "blunt" end

    local inflictor = dmginfo:GetInflictor()
    local attacker = dmginfo:GetAttacker()
    local wep = IsValid(inflictor) and inflictor or (IsValid(attacker) and attacker.GetActiveWeapon and attacker:GetActiveWeapon())

    if IsValid(wep) then
        if wep:GetClass() == "weapon_melee" or wep.Base == "weapon_melee" or wep.DamageType then
            return wep.DamageType == DMG_SLASH and "slash" or "blunt"
        end

        if wep.Base == "homigrad_base" or wep.Primary and wep.Primary.Ammo then
            return "bullet"
        end
    end

    if dmginfo:GetDamage() >= target:Health() then return "generic" end
end

local function SCPCBThoughtHitgroup(target, dmgType, dmginfo, hitPos)
    if dmgType == "generic" then return HITGROUP_GENERIC end

    hitPos = hitPos or dmginfo:GetDamagePosition()
    local plyPos = target:GetPos() + Vector(0, 0, target:OBBMins().z)
    local height = target:OBBMaxs().z - target:OBBMins().z
    local hitHeight = hitPos.z - plyPos.z

    if hitHeight > height * 0.85 then return HITGROUP_HEAD end

    local right = target:GetRight()
    local toHit = hitPos - plyPos
    toHit.z = 0
    toHit:Normalize()

    if hitHeight > height * 0.4 then
        local rightDot = right:Dot(toHit)

        if math.abs(rightDot) > 0.7 and hitHeight > height * 0.5 then
            return rightDot > 0 and HITGROUP_RIGHTARM or HITGROUP_LEFTARM
        end

        if hitHeight > height * 0.6 then return HITGROUP_CHEST end
        if hitHeight > height * 0.5 then return HITGROUP_STOMACH end
        return 8
    end

    return right:Dot(toHit) > 0 and HITGROUP_RIGHTLEG or HITGROUP_LEFTLEG
end

local function SCPCBArmorProtection(ent, ply, hitgroup)
    local placement

    if hitgroup == HITGROUP_CHEST or hitgroup == HITGROUP_STOMACH or hitgroup == HITGROUP_GENERIC or hitgroup == 8 then
        placement = "torso"
    else
        return 0
    end

    local armors = (IsValid(ent) and ent.armors) or ply.armors
    if not armors then return 0 end

    local armor = armors[placement]
    local armorData = armor and hg.armor and hg.armor[placement] and hg.armor[placement][armor]
    if not armorData then return 0 end

    local broken = ((IsValid(ent) and ent.armors_broken) or ply.armors_broken or {})[armor]
    return broken and 0 or (armorData.protection or 0)
end

local SCPCBCreateThought

local function SCPCBHitThought(ply, target, dmgType, dmg, hitPos, dmginfo)
    if not dmg or dmg <= 0 then return end

    local isLethal = dmg >= ply:Health()
    local hitgroup = SCPCBThoughtHitgroup(target, dmgType, dmginfo, hitPos)
    local category = scpcbHitgroupToCat[hitgroup] or "generic"

    ply.scpcbThoughtHitTime = CurTime() + 0.25

    if !isLethal and SCPCBArmorProtection(target, ply, hitgroup) > 0 then
        category = dmg > SCPCBArmorProtection(target, ply, hitgroup) and "armor_partial" or "armor_full"
    elseif !isLethal and hitgroup == HITGROUP_HEAD then
        category = "head_nonlethal"
    end

    SCPCBCreateThought(ply, category, dmgType, isLethal)
end

SCPCBCreateThought = function(ply, category, dmgType, isLethal)
    if not CreateThought or not IsValid(ply) or not ply:IsPlayer() then return end
    if ply:GetInfoNum("hg_newthoughts", 0) <= 0 then return end
    if isLethal then return end

    local curTime = CurTime()
    ply.scpcbThoughtNext = ply.scpcbThoughtNext or 0

    if !isLethal and ply.scpcbThoughtNext > curTime then return end

    local targetCategory = category
    if isLethal and category != "head" and category != "near_miss" and category != "armor_full" and category != "armor_partial" then
        targetCategory = category .. "_lethal"
    end

    local options = scpcbThoughts[targetCategory] or scpcbThoughts.generic
    if not options then return end

    local weaponStr = "bullet"
    if dmgType == "blunt" then weaponStr = "blunt object" end
    if dmgType == "slash" then weaponStr = "sharp object" end
    if dmgType == "generic" then weaponStr = "impact" end

    local msg = string.gsub(options[math.random(1, #options)], "{weapon}", weaponStr)
    local delay = isLethal and 1 or (category == "near_miss" and 12 or 8)

    if CreateThought(ply, msg, delay, "scpcb_damage_" .. targetCategory, 0, color_white) then
        ply.scpcbThoughtNext = curTime + (isLethal and 1 or (category == "near_miss" and 6 or 4))
    end
end

local function SCPCBThoughtOwner(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return ent end

    if hg and hg.RagdollOwner then
        local ply = hg.RagdollOwner(ent)
        if IsValid(ply) then return ply end
    end

    local ply = ent.ply
    if IsValid(ply) and ply:IsPlayer() then return ply end

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply.FakeRagdoll) and ply.FakeRagdoll == ent then return ply end
        if hg and hg.GetCurrentCharacter and hg.GetCurrentCharacter(ply) == ent then return ply end
    end
end

local function CreateNotification(ply, msg, delay, msgKey, showTime, func, clr)
    if ply.organism and ply.organism.otrub then return end
    if ply.PlayerClassName and ply.PlayerClassName == "Gordon" and clr != hev_color then return end
    if msg == "" then return end
    if not IsValid(ply) or not ply:IsPlayer() then error("player is not valid!") return false end
    if not msg or not isstring(msg) then error("no message or message is invalid!") return false end
    msgKey = msgKey or msg

    if ply:GetInfoNum("hg_newthoughts", 0) > 0 and thoughtMessages[msgKey] and CreateThought then
        return CreateThought(ply, thoughtMessages[msgKey], delay, "thought_" .. msgKey, showTime, clr)
    end

    ply.msgs = ply.msgs or {}
    if msgKey and ply.msgs[msgKey] then
        if isnumber(ply.msgs[msgKey]) then
            if ply.msgs[msgKey] > CurTime() then
                return false
            end
        else
            return false
        end
    end

    delay = delay or 5

    if msgKey then ply.msgs[msgKey] = delay and (not isnumber(delay) or CurTime() + delay) or nil end
    --показывать один раз за промежуток времени
    --(если delay не номерок то оно пинганет в следующей жизни)

    if ply.organism and ply.organism.brain > 0.1 then
        for i = 1, utf8.len(msg) do
            if math.random(3) == 1 and msg[i] != "?" and msg[i] != "." then
                msg = hg.replace_by_index(msg, i, (math.random(1,2) > 1 and "m" or "b") )
            end
        end
    end
    
    showTime = showTime or 0

    local clr = clr or color_white
    local clr2 = Color(clr.r, clr.g, clr.b, 255)

    timer.Simple(showTime, function()
        if !IsValid(ply) then return end
        if !ply.msgs[msgKey] then return end

        if (ply.organism and ply.organism.otrub) or !ply:Alive() then
            return
        end

        if ply.organism and ply.organism.pain > 60 and (!clr or clr.g > 250) then
            return
        end

        if func and isfunction(func) then
            if func(ply) then return end
        end

        net.Start("HGNotificate")
        net.WriteString(msg)
        //net.WriteFloat(showTime or 3)
        net.WriteColor(clr2)
        net.Send(ply)
    end)

    return true
end

//erm it's ass but i don't care enough
local function CreateNotificationBerserk(ply, msg, delay, msgKey, showTime, func, clr)
    if ply.organism and ply.organism.otrub then return end
    if ply.PlayerClassName and ply.PlayerClassName == "Gordon" and clr != hev_color then return end
    if msg == "" then return end
    if not IsValid(ply) or not ply:IsPlayer() then error("player is not valid!") return false end
    if not msg or not isstring(msg) then error("no message or message is invalid!") return false end
    msgKey = msgKey or msg
    ply.msgs = ply.msgs or {}
    if msgKey and ply.msgs[msgKey] then
        if isnumber(ply.msgs[msgKey]) then
            if ply.msgs[msgKey] > CurTime() then
                return false
            end
        else
            return false
        end
    end

    delay = delay or 0

    if msgKey then ply.msgs[msgKey] = delay and (not isnumber(delay) or CurTime() + delay) or nil end
    --показывать один раз за промежуток времени
    --(если delay не номерок то оно пинганет в следующей жизни)
    if func and isfunction(func) then
        func(ply)
    end

    if ply.organism and ply.organism.brain > 0.1 then
        for i = 1, utf8.len(msg) do
            if math.random(3) == 1 and msg[i] != "?" and msg[i] != "." then
                msg = hg.replace_by_index(msg, i, (math.random(1,2) > 1 and "m" or "b") )
            end
        end
    end
    
    showTime = showTime or 0

    local clr = clr or color_white
    local clr2 = Color(clr.r, clr.g, clr.b, 255)

    timer.Simple(showTime, function()
        if !IsValid(ply) then return end
        if !ply.msgs[msgKey] then return end

        if (ply.organism and ply.organism.otrub) or !ply:Alive() then
            return
        end

        if ply.organism and ply.organism.pain > 60 and (!clr or clr.g > 250) then
            return
        end

        net.Start("HGNotificateBerserk")
        net.WriteString(msg)
        //net.WriteFloat(showTime or 3)
        net.WriteColor(clr2)
        net.Send(ply)
    end)

    return true
end

local function ResetNotification(ply, key)
    if not ply.msgs or not ply.msgs[key] then return end
    ply.msgs[key] = nil
end

CreateThought = function(ply, msg, delay, msgKey, showTime, clr)
    if ply.organism and ply.organism.otrub then return end
    if msg == "" then return end
    if not IsValid(ply) or not ply:IsPlayer() then error("player is not valid!") return false end
    if not msg or not isstring(msg) then error("no message or message is invalid!") return false end
    if ply:GetInfoNum("hg_newthoughts", 0) <= 0 then return false end

    msgKey = msgKey or msg
    ply.thoughtmsgs = ply.thoughtmsgs or {}
    if msgKey and ply.thoughtmsgs[msgKey] then
        if isnumber(ply.thoughtmsgs[msgKey]) then
            if ply.thoughtmsgs[msgKey] > CurTime() then
                return false
            end
        else
            return false
        end
    end

    delay = delay or 0

    if msgKey then ply.thoughtmsgs[msgKey] = delay and (not isnumber(delay) or CurTime() + delay) or nil end

    showTime = showTime or 0
    local clr = clr or color_white
    local clr2 = Color(clr.r, clr.g, clr.b, 255)

    timer.Simple(showTime, function()
        if !IsValid(ply) then return end
        if !ply.thoughtmsgs[msgKey] then return end
        if (ply.organism and ply.organism.otrub) or !ply:Alive() then return end

        net.Start("HGThought")
        net.WriteString(msg)
        net.WriteColor(clr2)
        net.Send(ply)
    end)

    return true
end

hg.CreateNotification = CreateNotification

hook.Add("Player Spawn","removeNotifications",function(ply)
    ply.msgs = {}
    ply.thoughtmsgs = {}
end)

hook.Add("HG_OnOtrub","removeNotifications",function(ply)
    ply.msgs = {}
    ply.thoughtmsgs = {}
end)

hook.Add("Player_Death","removeNotifications",function(ply)
    ply.msgs = {}
    ply.thoughtmsgs = {}
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:Notify(...)
    return CreateNotification(self, ...)
end

function PLAYER:NotifyBerserk(...)
    return CreateNotificationBerserk(self, ...)
end

function PLAYER:Thought(...)
    return CreateThought(self, ...)
end

function PLAYER:ResetNotification(key)
    ResetNotification(self,key)
end

hook.Add("EntityTakeDamage", "SCPCB_HGThoughtDamage", function(target, dmginfo)
    if not dmginfo or dmginfo:GetDamage() <= 0 then return end

    local ply = SCPCBThoughtOwner(target)
    if not IsValid(ply) then return end
    if dmginfo:IsDamageType(DMG_FALL) or dmginfo:IsDamageType(DMG_CRUSH) then return end

    local dmgType = SCPCBThoughtDamageType(dmginfo, ply)
    if not dmgType then return end

    SCPCBHitThought(ply, target, dmgType, dmginfo:GetDamage(), nil, dmginfo)
end)

hook.Add("EntityFireBullets", "SCPCB_HGThoughtNearMiss", function(entity, data)
    if not IsValid(entity) then return end
    if (data.limit_ricochet or 0) > 0 or (data.penetrated or 0) > 0 then return end

    local oldCallback = data.Callback
    local shooter = IsValid(data.Attacker) and data.Attacker or (entity.GetOwner and entity:GetOwner() or entity)

    data.Callback = function(attacker, tr, dmginfo)
        shooter = IsValid(attacker) and attacker or shooter
        local hitPly = SCPCBThoughtOwner(tr.Entity)
        local blocked = false

        if IsValid(hitPly) and hitPly != shooter then
            blocked = hg.TryExtinguisherBulletBlock and hg.TryExtinguisherBulletBlock(tr.Entity, dmginfo)
            SCPCBHitThought(hitPly, tr.Entity, "bullet", dmginfo:GetDamage(), tr.HitPos, dmginfo)
        end

        local src = data.Src
        local hitPos = tr.HitPos
        local dir = hitPos - src
        local length = dir:Length()

        if length > 0 then
            dir:Normalize()

            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:Alive() and ply != shooter and ply != entity and ply != hitPly and not blocked and (ply.scpcbThoughtHitTime or 0) < CurTime() then
                    local plyPos = ply:GetPos() + Vector(0, 0, 50)
                    local projection = math.Clamp((plyPos - src):Dot(dir), 0, length)
                    local closestPoint = src + dir * projection

                    if plyPos:Distance(closestPoint) < 125 then
                        SCPCBCreateThought(ply, "near_miss", "bullet", false)
                    end
                end
            end
        end

        if oldCallback then return oldCallback(attacker, tr, dmginfo) end
    end

end)
