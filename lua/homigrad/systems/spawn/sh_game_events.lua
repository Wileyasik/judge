gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "hg-disconnect", function(data)
	hook.Run("Player Disconnected", data)
end)

gameevent.Listen("player_activate")
hook.Add("player_activate", "player_activatehg", function(data)
	local ply = Player(data.userid)
	if not IsValid(ply) then return end

	hook.Run("Player Activate", ply)
	if SERVER and ply.SyncVars then ply:SyncVars() end
end)

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "homigrad-death", function(data)
	local ply = Entity(data.entindex_killed)
	if not IsValid(ply) or not ply:IsPlayer() then return end
	hook.Run("Player_Death", ply)
end)
