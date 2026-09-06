function hg.CanUseLeftHand(ply)
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

	if IsValid(ply.FakeRagdoll) and ply:GetNWBool("hg_hold_wound_manual", false) then
		if hg.DebugTPIK then hg.DebugTPIK(ply, "lh_off", "wound_manual") end
		return false
	end

	if ent.organism and (ent.organism.larmamputated or ent.organism.lhandamputated or ent.organism.larmupamputated) then
		if hg.DebugTPIK then hg.DebugTPIK(ply, "lh_off", "amputated") end
		return false
	end

	local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon()
	local Car = (ply.GetSimfphys and IsValid(ply:GetSimfphys()) and ply:GetSimfphys()) or (ply.GlideGetVehicle and IsValid(ply:GlideGetVehicle()) and ply:GlideGetVehicle()) or ply:GetVehicle()

	if (IsValid(Car) and hg.GetCarSteering(Car)) then
		holdingwheel = hg.GetCarSteering(Car) > 0
	end

	local deploying = wep and (wep.deploy and (wep.deploy - CurTime()) > (wep.CooldownDeploy / 2) or wep.holster and (wep.holster - CurTime()) < (wep.CooldownHolster / 2))

	local chatgesture = (ply:GetTable().ChatGestureWeight or 0) > 0.1
	local tauntleft = ply:GetNWBool("TauntLeftHand", false) and ply:GetNWFloat("StartTaunt", 0) + 0.1 < CurTime()
	local flashlight = IsValid(ply.flashlight)
	local nothandcuffed = !ply:GetNetVar("handcuffed")
	local notreload = wep and not wep.reload
	local fingerpose = ent != ply and math.abs(ent:GetManipulateBoneAngles(ent:LookupBone("ValveBiped.Bip01_L_Finger11"))[2]) > 5 and !ply:InVehicle()
	local vehiclenowep = (ply:InVehicle() and (wep and not IsValid(wep)) and not wep.reload) and hg.isdriveablevehicle(ply:GetVehicle())

	if not ply.zmanipstart and hg.DebugTPIK then
		local reasons = {}
		if (chatgesture or tauntleft or flashlight) and nothandcuffed and notreload then
			if chatgesture then reasons[#reasons + 1] = "chat" end
			if tauntleft then reasons[#reasons + 1] = "taunt" end
			if flashlight then reasons[#reasons + 1] = "flashlight" end
		end
		if deploying then
			local detail = "deploy"
			if wep and wep.deploy then detail = detail .. " d=" .. math.Round(wep.deploy - CurTime(), 2) end
			if wep and wep.holster then detail = detail .. " h=" .. math.Round(wep.holster - CurTime(), 2) end
			reasons[#reasons + 1] = detail
		end
		if fingerpose then reasons[#reasons + 1] = "fingerpose" end
		if vehiclenowep then reasons[#reasons + 1] = "vehicle" end
		if #reasons > 0 then
			hg.DebugTPIK(ply, "lh_off", table.concat(reasons, ", "))
		end
	end

	return (not (((chatgesture or tauntleft or flashlight) and nothandcuffed and notreload) or (deploying) or (fingerpose) or (vehiclenowep))) or ply.zmanipstart
end

function hg.CanUseRightHand(ply)
	local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply

	if IsValid(ply.FakeRagdoll) and ply:GetNWBool("hg_hold_wound_right", false) then
		if hg.DebugTPIK then hg.DebugTPIK(ply, "rh_off", "wound_right") end
		return false
	end

	if ent.organism and (ent.organism.rarmamputated or ent.organism.rhandamputated or ent.organism.rarmupamputated) then
		if hg.DebugTPIK then hg.DebugTPIK(ply, "rh_off", "amputated") end
		return false
	end

	return true
end

function hg.earanim(ply)
	local plyTable = ply:GetTable()

	plyTable.ChatGestureWeight = plyTable.ChatGestureWeight || 0

	if (ply:IsPlayingTaunt()) then return end

	local wep = ply:GetActiveWeapon()

	if (ply:IsTyping()) or (ply:GetNetVar("flashlight", false) and (!wep.IsPistolHoldType or wep:IsPistolHoldType() or ply.PlayerClassName == "Gordon")) then
		plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 1, FrameTime() * 3.0)
	else
		plyTable.ChatGestureWeight = math.Approach(plyTable.ChatGestureWeight, 0, FrameTime() * 3.0)
	end

	if (plyTable.ChatGestureWeight > 0) then
		ply:AnimRestartGesture(GESTURE_SLOT_VCD, ACT_GMOD_IN_CHAT, true)
		ply:AnimSetGestureWeight(GESTURE_SLOT_VCD, plyTable.ChatGestureWeight)
	end
end
