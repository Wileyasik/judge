local CLASS = player.RegClass("arena_blue")

function CLASS.Off(self)
    if CLIENT then return end
end

local model = "models/css_seb_swat/css_swat.mdl"

function CLASS.On(self)
    if CLIENT then return end

    ApplyAppearance(self, nil, nil, nil, true)
    self:SetPlayerColor(Color(0, 80, 200):ToVector())
    self:SetModel(model)
    self:SetSubMaterial()
    timer.Simple(0, function()
        if not IsValid(self) then return end
        self:SetBodyGroups("00000000000")
    end)

    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance

    if self.organism then
        self.organism.recoilmul = 0.85
    end
end

function CLASS.Guilt(self, Victim)
    if CLIENT then return end

    if IsValid(Victim) and Victim:GetPlayerClass() == self:GetPlayerClass() then
        return 1
    end

    return 1
end

hook.Add("HG_PlayerFootstep", "arena_blue_footsteps", function(ply, pos, foot, sound, volume, rf)
    local ent = hg.GetCurrentCharacter(ply)
    if ply:Alive() and ply.PlayerClassName == "arena_blue" and not (ply:IsWalking() or ply:Crouching()) and ent == ply then
        local snd = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
        if SoundDuration(snd) <= 0 then
            snd = sound
        end

        EmitSound(snd, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95, 105)))
        return true
    end
end)

return CLASS
