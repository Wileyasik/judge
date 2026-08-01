if SERVER then AddCSLuaFile() end

SWEP.Base = "weapon_combatknife"
SWEP.PrintName = "BARS A-2607"
SWEP.Category = "Weapons - Melee"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/weapons/arc9/darsu_eft/w_melee_bars_a2607.mdl"
SWEP.WorldModelExchange = "models/weapons/arc9/darsu_eft/w_melee_bars_a2607.mdl"
SWEP.DroppedWorldModel = "models/weapons/arc9/darsu_eft/w_melee_bars_a2607.mdl"
SWEP.modelscale = 1.15
SWEP.basebone = 76
SWEP.weaponPos = Vector(2.4, 1, 3)
SWEP.weaponAng = Angle(-18, 180, 180)

function SWEP:Reload()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if owner:KeyDown(IN_ATTACK) then
        self.InspectPending = false

        if SERVER and owner:KeyPressed(IN_ATTACK) then
            self:SetNetVar("mode", not self:GetNetVar("mode"))
            owner:ChatPrint("Changed mode to "..(self:GetNetVar("mode") and "slash." or "stab."))
        end

        return
    end

    if owner:KeyPressed(IN_RELOAD) then
        self.InspectPending = true
    end
end

function SWEP:Think()
    weapons.GetStored("weapon_melee").CustomThink(self)

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if self.InspectPending and owner:KeyDown(IN_ATTACK) then
        self.InspectPending = false
        return
    end

    if not self.InspectPending or not owner:KeyReleased(IN_RELOAD) then return end
    self.InspectPending = false
    if (self:GetLastAttack() + self:GetAttackWait()) > CurTime() then return end

    local inspectTime = self.InspectTime or 2.5
    self.InspectStart = CurTime()
    self.InspectEnd = CurTime() + inspectTime
    self:SetLastAttack(CurTime())
    self:SetAttackWait(inspectTime)
    self.lastattack = CurTime()
    self.attackwait = inspectTime
    self:PlayAnim("inspect", inspectTime, false, nil, false, true)
end

if CLIENT then
	SWEP.WepSelectIcon = Material("entities/arc9_eft_melee_a2607.png")
	SWEP.IconOverride = "entities/arc9_eft_melee_a2607.png"
	SWEP.BounceWeaponIcon = false
end
