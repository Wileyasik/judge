function TauntCamera()
	local CAM = {}
	CAM.ShouldDrawLocalPlayer = function(self, ply, on)
		return
	end
	CAM.CalcView = function(self, view, ply, on)
		return
	end
	CAM.CreateMove = function(self, cmd, ply, on)
		return
	end

	return CAM
end

local player_default = baseclass.Get("player_default")

player_default.TauntCam = TauntCamera()

player_manager.RegisterClass("player_default", player_default, nil)

local taunt_function_start = {
	[ACT_GMOD_TAUNT_CHEER] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_TAUNT_LAUGH] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_TAUNT_MUSCLE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_TAUNT_DANCE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_TAUNT_PERSISTENCE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_GESTURE_TAUNT_ZOMBIE] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_GESTURE_BOW] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_TAUNT_ROBOT] = function(ply) ply:SetNWBool("TauntStopMoving", true) ply:SetNWBool("TauntHolsterWeapons", true) end,
	[ACT_GMOD_GESTURE_AGREE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_SIGNAL_HALT] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_GMOD_GESTURE_BECON] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_GMOD_GESTURE_DISAGREE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_GMOD_TAUNT_SALUTE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_GMOD_GESTURE_WAVE] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_SIGNAL_FORWARD] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
	[ACT_SIGNAL_GROUP] = function(ply) ply:SetNWBool("TauntLeftHand", true) end,
}

local function stop_taunt(ply)
	ply:SetNWBool("TauntStopMoving", false)
	ply:SetNWBool("TauntLeftHand", false)
	ply:SetNWBool("TauntHolsterWeapons", false)
	ply:SetNWBool("IsTaunting", false)

	if timer.Exists("TauntHG" .. ply:EntIndex()) then
		timer.Remove("TauntHG" .. ply:EntIndex())
	end

	ply.CurrentActivity = nil
end

hook.Add("Player Getup", "TauntEndHG", function(ply, act, length)
	stop_taunt(ply)
end)

hook.Add("Fake", "TauntEndHG", function(ply)
	stop_taunt(ply)
end)

hook.Add("PlayerStartTaunt", "TauntRecordHG", function(ply, act, length)
	if not taunt_function_start[act] then return end

	taunt_function_start[act](ply, act, length)
	ply:SetNWBool("IsTaunting", true)
	ply:SetNWFloat("StartTaunt", CurTime())

	ply.CurrentActivity = act

	timer.Create("TauntHG" .. ply:EntIndex(), length - 0.3, 1, function()
		if not ply:GetNWBool("IsTaunting", false) then return end

		stop_taunt(ply)

		ply:SetNWBool("IsTaunting", false)
	end)
end)
