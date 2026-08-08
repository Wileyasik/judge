local MODE = MODE

MODE.name = "juggernaut"
MODE.PrintName = "Juggernaut"
MODE.Description = "One player becomes an unstoppable Juggernaut with a hardened organism. Everyone else has to bring them down before the timer runs out."
MODE.Chance = 0.04
MODE.randomSpawns = true

function MODE:IsJuggernaut(ply)
	return IsValid(ply) and self.Juggernaut == ply
end
