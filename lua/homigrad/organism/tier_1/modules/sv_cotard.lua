local Clamp, max, min = math.Clamp, math.max, math.min

local function chooseType(org)
	local lungs = max(org.pneumothorax or 0, (org.lungsL[1] or 0) * 0.7, (org.lungsR[1] or 0) * 0.7)
	local brain = max(org.brain or 0, (org.disorientation or 0) / 8)
	local blood = 1 - Clamp((org.blood or 5000) / 5000, 0, 1)

	if lungs >= 0.35 and lungs >= brain * 0.8 then return 1 end
	if brain >= 0.18 then return 2 end
	if blood >= 0.35 then return 3 end
	return 2
end

concommand.Add("hg_cotard_test", function(ply, _, args)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:IsAdmin() or not ply.organism then return end

	local type = math.Clamp(tonumber(args[1]) or chooseType(ply.organism), 0, 3)
	if type == 0 then
		ply.organism.cotard = 0
		ply.organism.cotardType = 0
		ply.organism.cotardStarted = 0
		ply.organism.cotardTest = false
	else
		ply.organism.cotard = 1
		ply.organism.cotardType = type
		ply.organism.cotardStarted = CurTime()
		ply.organism.cotardTest = true
		if hg.StopPainScream then hg.StopPainScream(ply, 0.2) end
	end

	ply.organism.cotardWasUnconscious = false
	ply.organism.cotardUnconTimer = 0
	ply.fullsend = true
end)

hook.Add("Org Clear", "CotardInit", function(org)
	org.cotard = 0
	org.cotardType = 0
	org.cotardStarted = 0
	org.cotardWasUnconscious = false
	org.cotardUnconTimer = 0
	org.cotardTest = false
end)

hook.Add("Org Think", "CotardThink", function(owner, org, timeValue)
	if not org.isPly then return end

	if org.otrub then
		org.cotardWasUnconscious = true
		org.cotardUnconTimer = (org.cotardUnconTimer or 0) + timeValue
		return
	end

	if not org.cotardWasUnconscious then return end
	org.cotardWasUnconscious = false

	local unconsciousTime = org.cotardUnconTimer or 0
	org.cotardUnconTimer = 0
	if unconsciousTime < 18 then return end
	if (org.cotard or 0) > 0 then return end

	org.cotard = Clamp(unconsciousTime / 90, 0.35, 1)
	org.cotardType = chooseType(org)
	org.cotardStarted = CurTime()
	if hg.StopPainScream then hg.StopPainScream(owner, 0.2) end

	if org.cotardType == 1 then
		owner:Notify("You wake up gasping for air.", 6, "cotard_wake", 0, nil, Color(180, 220, 255))
	elseif org.cotardType == 2 then
		owner:Notify("You are awake, but nothing makes sense.", 6, "cotard_wake", 0, nil, Color(200, 190, 255))
	else
		owner:Notify("You are alive. You do not understand how.", 6, "cotard_wake", 0, "", Color(190, 190, 190))
	end
end)

hook.Add("Org Think", "CotardDecay", function(owner, org, timeValue)
	if not org.isPly or (org.cotard or 0) <= 0 or org.otrub or org.cotardTest then return end

	local stable = (org.blood or 0) > 4200 and (org.o2 and org.o2[1] or 0) > 20 and (org.pain or 0) < 25
	local rate = stable and 240 or 900
	org.cotard = max(org.cotard - timeValue / rate, 0)
	if org.cotard <= 0.001 then
		org.cotard = 0
		org.cotardType = 0
		org.cotardStarted = 0
	end
end)
