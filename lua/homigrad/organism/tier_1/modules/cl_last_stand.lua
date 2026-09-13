local lastStandStation
local lastStandLoading
local lastStandFlag = false
local LAST_STAND_VOLUME = 0.75

function hg.LastStandActive()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply:Alive() then return false end
	local org = ply.new_organism or ply.organism
	if not org then return lastStandFlag end
	return (org.lastStand or lastStandFlag) and (not org.lastStandEnd or CurTime() < org.lastStandEnd)
end

local function StopLastStandSound()
	if not IsValid(lastStandStation) then return end
	if lastStandStation.ChangeVolume then
		lastStandStation:ChangeVolume(0, 0.5)
		timer.Simple(0.55, function()
			if IsValid(lastStandStation) then lastStandStation:Stop() end
			lastStandStation = nil
		end)
	else
		lastStandStation:Stop()
		lastStandStation = nil
	end
end

local function StartLastStandSound()
	local ply = LocalPlayer()
	print("[laststand] StartLastStandSound: IsValid(station)=", IsValid(lastStandStation), "loading=", lastStandLoading, "Alive=", IsValid(ply) and ply:Alive(), "Active=", hg.LastStandActive())
	if IsValid(lastStandStation) then return end
	if lastStandLoading then return end
	if not IsValid(ply) or not ply:Alive() then return end
	if not lastStandFlag then return end

	lastStandLoading = true
	sound.PlayFile("sound/laststand.mp3", "noplay", function(station, errCode, errStr)
		print("[laststand] callback: IsValid=", IsValid(station), "errCode=", tostring(errCode), "errStr=", tostring(errStr))
		lastStandLoading = nil
		if not IsValid(station) then return end
		if not lastStandFlag then station:Stop() return end
		lastStandStation = station
		station:EnableLooping(true)
		station:SetVolume(LAST_STAND_VOLUME)
		station:Play()
	end)
end

net.Receive("hg_last_stand", function()
	lastStandFlag = net.ReadBool()
	print("[laststand] net received, flag=", lastStandFlag)
	if lastStandFlag then
		StartLastStandSound()
	else
		StopLastStandSound()
	end
end)

concommand.Add("hg_last_stand_debug", function()
	local ply = LocalPlayer()
	local org = IsValid(ply) and (ply.new_organism or ply.organism)
	print("[laststand] debug: Alive=", IsValid(ply) and ply:Alive(), "org=", tostring(org), "otrub=", org and tostring(org.otrub), "lastStand=", org and tostring(org.lastStand), "lastStandEnd=", org and tostring(org.lastStandEnd), "flag=", lastStandFlag)
	lastStandFlag = true
	StartLastStandSound()
end)

hook.Add("Think", "HGLastStandSoundEnd", function()
	if not lastStandFlag then
		StopLastStandSound()
	end
end)