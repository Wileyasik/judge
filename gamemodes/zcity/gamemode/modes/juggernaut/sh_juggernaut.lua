local MODE = MODE

MODE.name = "juggernaut"
MODE.PrintName = "Juggernaut"
MODE.Description = "One or more players become unstoppable Juggernauts with a hardened organism. Everyone else has to bring them down before the timer runs out."
MODE.Chance = 0.09
MODE.randomSpawns = true

function MODE:IsJuggernaut(ply)
	if not IsValid(ply) then return false end
	for _, jugg in ipairs(self.Juggernauts or {}) do
		if jugg == ply then return true end
	end
	return false
end