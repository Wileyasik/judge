local CLASS = player.RegClass("arena_red")

function CLASS.Off(self)
    if CLIENT then return end
end

local masks = {
    "arctic_balaclava",
    "phoenix_balaclava",
    "bandana"
}

function CLASS.On(self)
    if CLIENT then return end

    ApplyAppearance(self, nil, nil, nil, true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AColor = Color(200, 30, 30)
    self.CurAppearance = Appearance
    hg.Appearance.SyncAppearanceColor(self)

    timer.Simple(0.1, function()
        if not IsValid(self) then return end
        local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()

        Appearance.AAttachments = {
            masks[math.random(#masks)],
            "terrorist_band"
        }
        self:SetNetVar("Accessories", Appearance.AAttachments or "none")

        self.CurAppearance = Appearance
    end)

    if self.organism then
        self.organism.stamina.max = 260
    end
end

function CLASS.Guilt(self, victim)
    if CLIENT then return end

    if IsValid(victim) and victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end

    return 1
end

hook.Add("HG_PlayerFootstep", "arena_red_footsteps", function(ply, pos, foot, sound, volume, rf)
    local ent = hg.GetCurrentCharacter(ply)
    if ply:Alive() and ply.PlayerClassName == "arena_red" and not (ply:IsWalking() or ply:Crouching()) and ent == ply then
        local snd = "homigrad/" .. sound
        if SoundDuration(snd) <= 0 then
            snd = sound
        end

        EmitSound("homigrad/player/footsteps/new/bass_0" .. math.random(9) .. ".wav", pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95, 105)))
        EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95, 105)))
    end
end)

return CLASS
