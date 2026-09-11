local rouseUntil = 0

net.Receive("hg_otrub_rouse", function()
	rouseUntil = CurTime() + 2.5
	local ply = LocalPlayer()
	if IsValid(ply) then
		sound.PlayFile("sound/rem_heartstopuncon.wav", "noblock noplay", function(station)
			if not IsValid(station) then return end
			station:SetVolume(0.6)
			station:Play()
		end)
	end
end)

hook.Add("HUDPaint", "hg_otrub_rouse_pulse", function()
	if rouseUntil <= CurTime() then return end
	local ply = LocalPlayer()
	local org = IsValid(ply) and (ply.new_organism or ply.organism)
	if not org or not org.otrub then return end
	local t = 1 - math.Clamp((rouseUntil - CurTime()) / 2.5, 0, 1)
	local a = math.sin(t * math.pi) * 90
	if a <= 1 then return end
	surface.SetDrawColor(255, 255, 255, a)
	surface.DrawRect(0, 0, ScrW(), ScrH())
end)