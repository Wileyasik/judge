hook.Add("Player Think", "Berserk", function(ply, time, dtime)
    if !ply:IsBerserk() or ply:GetMoveType() == MOVETYPE_NOCLIP then return end
    local velocity = ply:GetVelocity():Length2DSqr()
    if velocity > 100000 then
        local plyPos = ply:GetPos()
        for _, v in ipairs(ents.FindInSphere(plyPos, 64)) do
            if v == ply then continue end
            local isPlayer = v:IsPlayer()
            local Phys = isPlayer and v:GetPhysicsObject() or v:GetPhysicsObjectNum(0)

            if isPlayer then
                v:ViewPunch(Angle(-5,0,0))
            end

            local AimVec = (v:GetPos() - plyPos):GetNormalized()
            local force = velocity / 800000

            if IsValid(Phys) then
                if isPlayer then v:SetVelocity(AimVec * 500 * force) end
                Phys:ApplyForceOffset(AimVec * 500 * force, plyPos)

                v:SetPhysicsAttacker(ply, 5)
            end
        end
    end
end)
