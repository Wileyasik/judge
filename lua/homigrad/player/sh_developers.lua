DEVELOPERS_LIST = {
	["76561198262308464"] = true,
	["76561198164095903"] = true,
	["76561198123967035"] = true,
	["76561197982525837"] = true,
	["76561198130072232"] = true,
	["76561198325967989"] = true,
}

hook.Add("PlayerInitialSpawn", "Hey! Developer here YAY", function(ply)
	if SERVER and DEVELOPERS_LIST[ply:SteamID64()] then
		PrintMessage(HUD_PRINTTALK, ply:Nick() .. " - zteam dev here!")
	end
end)
