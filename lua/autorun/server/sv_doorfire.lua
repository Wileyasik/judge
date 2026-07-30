if CLIENT then return end

local handleRadius = 2
local handleRadiusSqr = handleRadius ^ 2

local ironHits = {
    "lock_break/unlock.wav",
    "lock_break/unlock.wav",
    "lock_break/unlock.wav"
}

hook.Add("EntityTakeDamage", "ShootToUnlockDoor", function(target, dmginfo)
    if not IsValid(target) or target:GetClass() ~= "prop_door_rotating" then return end
    if target.breck then return end

    if (target.LockedDoor and target.LockedDoor > 0) or target.LockedDoorNail then
        if dmginfo:IsBulletDamage() then
            target:EmitSound("fire_extinguisher/fire_extinguisger_lever.wav", 70, 80)
        end
        return 
    end

    if not dmginfo:IsBulletDamage() and not dmginfo:IsDamageType(DMG_BUCKSHOT) then return end

    local hitPos = dmginfo:GetDamagePosition()
    local lockPos = nil

    local attID = target:LookupAttachment("handle")
    if attID > 0 then
        local att = target:GetAttachment(attID)
        if att then lockPos = att.Pos end
    end

    if not lockPos then
        local obbMax = target:OBBMaxs()
        local obbMin = target:OBBMins()
        local isXWide = (obbMax.x - obbMin.x) > (obbMax.y - obbMin.y)
        local localLockPos = Vector(0, 0, 0)

        if isXWide then
            localLockPos.x = math.abs(obbMax.x) > math.abs(obbMin.x) and (obbMax.x - 5) or (obbMin.x + 5)
            localLockPos.y = (obbMax.y + obbMin.y) / 2
        else
            localLockPos.y = math.abs(obbMax.y) > math.abs(obbMin.y) and (obbMax.y - 5) or (obbMin.y + 5)
            localLockPos.x = (obbMax.x + obbMin.x) / 2
        end
        localLockPos.z = obbMin.z + ((obbMax.z - obbMin.z) * 0.45)
        lockPos = target:LocalToWorld(localLockPos)
    end

    if lockPos and hitPos:DistToSqr(lockPos) <= handleRadiusSqr then
        target:Fire("Unlock")
        if target.destrutible_door then
            target.door_origLocked = false
        end
        target:EmitSound(table.Random(ironHits), 75, math.random(90, 110), 1, CHAN_ITEM)
        target:EmitSound("lock_break/unlock.wav", 70, math.random(110, 130), 0.8, CHAN_AUTO)

        local effect = EffectData()
        effect:SetOrigin(hitPos)
        effect:SetNormal(dmginfo:GetDamageForce():GetNormalized())
        effect:SetMagnitude(2)
        effect:SetScale(1)
        util.Effect("MetalSpark", effect)
    end
end)
