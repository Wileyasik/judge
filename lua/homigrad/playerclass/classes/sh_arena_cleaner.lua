local CLASS = player.RegClass("arena_cleaner")

local model = "models/css_seb_swat/css_swat.mdl"

function CLASS.Off(self)
	if CLIENT then return end
end

function CLASS.On(self)
	if CLIENT then return end

	ApplyAppearance(self, nil, nil, nil, true)
	self:SetPlayerColor(Color(35, 35, 35):ToVector())
	self:SetModel(model)
	self:SetSubMaterial()
	self:SetBodyGroups("00000000000")

	local appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
	appearance.AAttachments = ""
	appearance.AColthes = ""
	self:SetNetVar("Accessories", "")
	self.CurAppearance = appearance
	self:SetNWString("PlayerName", "CLEANER " .. appearance.AName)
end

function CLASS.Guilt()
	return 1
end

hook.Add("HG_PlayerFootstep", "arena_cleaner_footsteps", function(ply, pos, _, sound, volume)
	if not ply:Alive() or ply.PlayerClassName ~= "arena_cleaner" then return end
	if ply:IsWalking() or ply:Crouching() or hg.GetCurrentCharacter(ply) ~= ply then return end

	local militarySound = "zcitysnd/" .. string.Replace(sound, "player/footsteps", "player/footsteps_military/")
	if SoundDuration(militarySound) <= 0 then militarySound = sound end
	EmitSound(militarySound, pos, ply:EntIndex(), CHAN_AUTO, volume, 75, nil, changePitch(math.random(95, 105)))

	return true
end)

return CLASS
