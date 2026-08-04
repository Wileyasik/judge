EXHAUSTED_THRESHOLD = 89

hg.bonetohitgroup = {
	["ValveBiped.Bip01_Head1"] = HITGROUP_HEAD,
	["ValveBiped.Bip01_L_UpperArm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Forearm"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_L_Hand"] = HITGROUP_LEFTARM,
	["ValveBiped.Bip01_R_UpperArm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Forearm"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_R_Hand"] = HITGROUP_RIGHTARM,
	["ValveBiped.Bip01_Pelvis"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine2"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine1"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_Spine4"] = HITGROUP_CHEST,
	["ValveBiped.Bip01_Spine"] = HITGROUP_STOMACH,
	["ValveBiped.Bip01_L_Thigh"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Calf"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_L_Foot"] = HITGROUP_LEFTLEG,
	["ValveBiped.Bip01_R_Thigh"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Calf"] = HITGROUP_RIGHTLEG,
	["ValveBiped.Bip01_R_Foot"] = HITGROUP_RIGHTLEG
}

hg.amputeetable = {
	["ValveBiped.Bip01_L_UpperArm"] = "larmup",
	["ValveBiped.Bip01_L_Forearm"] = "larm",
	["ValveBiped.Bip01_L_Hand"] = "lhand",
	["ValveBiped.Bip01_R_UpperArm"] = "rarmup",
	["ValveBiped.Bip01_R_Forearm"] = "rarm",
	["ValveBiped.Bip01_R_Hand"] = "rhand",
	["ValveBiped.Bip01_L_Thigh"] = "llegup",
	["ValveBiped.Bip01_L_Calf"] = "lleg",
	["ValveBiped.Bip01_L_Foot"] = "lleg",
	["ValveBiped.Bip01_R_Thigh"] = "rlegup",
	["ValveBiped.Bip01_R_Calf"] = "rleg",
	["ValveBiped.Bip01_R_Foot"] = "rleg"
}

--[[hg.amputeetable = {
	[HITGROUP_LEFTLEG] = "lleg",
	[HITGROUP_RIGHTLEG] = "rleg",
	[HITGROUP_LEFTARM] = "larm",
	[HITGROUP_RIGHTARM] = "rarm",
	//[HITGROUP_HEAD] = 0.5
}--]]

hook.Add("ScalePlayerDamage", "remove-effects", function(ent, hitgroup, dmgInfo)
	if dmgInfo:IsDamageType(DMG_BUCKSHOT + DMG_BULLET + DMG_SLASH) then
		return true
	end
end)

local min = math.min
local pain_mat = Material("sprites/mat_jack_hmcd_narrow")

local tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

local tabblood = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0,
}

surface.CreateFont("RemDeathStateFont", {
	font = "Lora",
	size = ScreenScale(22),
	weight = 1100,
	outline = true
})

local remDeathStateColor = Color(255, 255, 255, 0)
local remDeathStateStation
local remDeathStateLoading
local remDeathStateSounds = {"rem_deathstatefull.mp3", "incap1.mp3", "incap2.mp3"}
local brainRotStation
local brainRotLoading
local nextBrainRotRoll = 0
local brainRotEnd = 0
local remHeartStopped = false
local remFibrillationStation
local remFibrillationLoading
local remFibrillationStopping
local remHeartStopLoading
local seizureStation
local seizureLoading
local seizureStopping

local MUSIC_VOLUME = 0.75
local BRAINROT_VOLUME = 0.45

local function PlayStationRandom(station, volume)
	station:SetVolume(volume or 1)
	local startTime = 0
	local length
	if station.GetLength and station.SetTime then
		length = station:GetLength()
		if isnumber(length) and length > 3 then
			startTime = math.Rand(0, math.max(length - 1, 0))
			station:SetTime(startTime)
		end
	end
	station:Play()
	return startTime, length
end

local function PlayRemHeartStopSound(uncon)
	if remHeartStopLoading then return end
	remHeartStopLoading = true
	sound.PlayFile("sound/" .. (uncon and "rem_heartstopuncon.wav" or "rem_heartstop.wav"), "noblock noplay", function(station)
		remHeartStopLoading = nil
		if not IsValid(station) then return end
		station:SetVolume(1)
		station:Play()
	end)
end

local function PlayRemDeathStateSound()
	if IsValid(remDeathStateStation) then
		remDeathStateStation:Play()
		return
	end
	if remDeathStateLoading then return end

	remDeathStateLoading = true
	sound.PlayFile("sound/" .. remDeathStateSounds[math.random(#remDeathStateSounds)], "noplay", function(station)
		remDeathStateLoading = nil
		if not IsValid(station) then return end
		if not LocalPlayer():Alive() then station:Stop() return end
		remDeathStateStation = station
		station:EnableLooping(true)
		PlayStationRandom(station, MUSIC_VOLUME)
	end)
end

net.Receive("rem_deathstate_sound", PlayRemDeathStateSound)

local function GetBrainLobeDamage(org)
	return (org.brainFrontal or 0) + (org.brainParietal or 0) + (org.brainTemporal or 0) + (org.brainOccipital or 0)
end

local function TryPlayBrainRotSound(org)
	if not org or GetBrainLobeDamage(org) <= 0 then return end
	if brainRotLoading or IsValid(brainRotStation) then return end
	if CurTime() < nextBrainRotRoll then return end

	nextBrainRotRoll = CurTime() + 30
	if math.random(4) ~= 1 then return end

	brainRotLoading = true
	sound.PlayFile("sound/brainrot.mp3", "noplay", function(station)
		brainRotLoading = nil
		if not IsValid(station) then return end
		local ply = LocalPlayer()
		local currentOrg = IsValid(ply) and ply:Alive() and (ply.new_organism or ply.organism)
		if not currentOrg or GetBrainLobeDamage(currentOrg) <= 0 then station:Stop() return end
		brainRotStation = station
		local startTime, length = PlayStationRandom(station, BRAINROT_VOLUME)
		brainRotEnd = isnumber(length) and CurTime() + math.max(length - startTime, 0) or CurTime() + 180
	end)
end

local function UpdateBrainRotSound(org)
	if not IsValid(brainRotStation) then return end
	if not org or GetBrainLobeDamage(org) <= 0 then
		brainRotStation:Stop()
		brainRotStation = nil
		brainRotEnd = 0
		return
	end
	if brainRotStation.GetState and brainRotStation:GetState() == GMOD_CHANNEL_STOPPED then brainRotStation = nil brainRotEnd = 0 return end
	if brainRotEnd > 0 and CurTime() >= brainRotEnd then brainRotStation = nil brainRotEnd = 0 end
end

local function StartSeizureSound(org)
	if not org or not org.seizureActive then return end
	if IsValid(seizureStation) then
		seizureStopping = nil
		seizureStation:Play()
		if seizureStation.ChangeVolume then seizureStation:ChangeVolume(MUSIC_VOLUME, 0.4) else seizureStation:SetVolume(MUSIC_VOLUME) end
		return
	end
	if seizureLoading then return end

	seizureLoading = true
	sound.PlayFile("sound/seizure.mp3", "noplay", function(station)
		seizureLoading = nil
		if not IsValid(station) then return end
		local ply = LocalPlayer()
		local currentOrg = IsValid(ply) and ply:Alive() and (ply.new_organism or ply.organism)
		if not currentOrg or not currentOrg.seizureActive then station:Stop() return end
		seizureStation = station
		seizureStopping = nil
		station:EnableLooping(true)
		PlayStationRandom(station, MUSIC_VOLUME)
	end)
end

local function StopSeizureSound()
	if not IsValid(seizureStation) or seizureStopping then return end
	seizureStopping = true
	if seizureStation.ChangeVolume then
		seizureStation:ChangeVolume(0, 1)
		timer.Simple(1.05, function()
			if not seizureStopping or not IsValid(seizureStation) then return end
			seizureStation:Stop()
			seizureStation = nil
			seizureStopping = nil
		end)
	else
		seizureStation:Stop()
		seizureStation = nil
		seizureStopping = nil
	end
end

local function StartRemFibrillationSound()
	if IsValid(remFibrillationStation) then
		remFibrillationStopping = nil
		remFibrillationStation:Play()
		if remFibrillationStation.ChangeVolume then remFibrillationStation:ChangeVolume(1, 1) else remFibrillationStation:SetVolume(1) end
		return
	end
	if remFibrillationLoading then return end
	remFibrillationLoading = true
	sound.PlayFile("sound/rem_fibrillation.mp3", "noplay", function(station)
		remFibrillationLoading = nil
		if not IsValid(station) then return end
		local ply = LocalPlayer()
		local org = IsValid(ply) and (ply.new_organism or ply.organism)
		if not IsValid(ply) or not ply:Alive() or not org or not org.fibrillation then station:Stop() return end
		remFibrillationStation = station
		station:EnableLooping(true)
		station:SetVolume(0)
		station:Play()
		if station.ChangeVolume then station:ChangeVolume(1, 1) else station:SetVolume(1) end
	end)
end

local function StopRemFibrillationSound()
	if not IsValid(remFibrillationStation) or remFibrillationStopping then return end
	remFibrillationStopping = true
	if remFibrillationStation.ChangeVolume then
		remFibrillationStation:ChangeVolume(0, 1)
	else
		remFibrillationStation:Stop()
		remFibrillationStation = nil
		remFibrillationStopping = nil
		return
	end
	timer.Simple(1.05, function()
		if not remFibrillationStopping or not IsValid(remFibrillationStation) then return end
		remFibrillationStation:Stop()
		remFibrillationStation = nil
		remFibrillationStopping = nil
	end)
end

hook.Add("Think", "RemCardiacSounds", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local org = ply:Alive() and (ply.new_organism or ply.organism)
	local heartstop = org and org.heartstop or false
	local fibrillation = org and org.fibrillation or false
	if heartstop and not remHeartStopped then PlayRemHeartStopSound(org.otrub) end
	remHeartStopped = heartstop
	if fibrillation then StartRemFibrillationSound() else StopRemFibrillationSound() end
	TryPlayBrainRotSound(org)
	UpdateBrainRotSound(org)
	if org and org.seizureActive then StartSeizureSound(org) else StopSeizureSound() end
end)

hook.Add("Think", "RemDeathStateSoundStop", function()
	local ply = LocalPlayer()
	if not IsValid(ply) or ply:Alive() or not IsValid(remDeathStateStation) then return end
	remDeathStateStation:Stop()
	remDeathStateStation = nil
end)

local k1, k2, k3

local upDir = Vector(0, 0, 1)
local fwdDir = Vector(0, 2.5, 0)
local rightDir = Vector(2.5, 0, 0)

local function plyCommand(ply,cmd)
	local time = CurTime()
	ply.cmdtimer = ply.cmdtimer or time

	if cmd == "soundfade 100 99999" then
		if IsValid(hg.chat) then
			hg.chat:SetRealAlpha(0)

			timer.Create("otrubhuy", 1, 1, function()
				if lply.organism and not lply.organism.otrub then lply:ConCommand("soundfade 0 1") end
				hg.chat:AnimateRealAlpha(255)
			end)
		end
	end

	if ply.cmdtimer < time then
		ply.cmdtimer = time + 0.1

		ply:ConCommand(cmd)
	end
end

local clr_black1 = Color( 0, 0, 0, 255)
local clr_black2 = Color( 0, 0, 0, 255)

local mat1 = Material("vgui/gradient-u")
local mat2 = Material("vgui/gradient-d")

local ang1 = Angle()
local ang2 = Angle()

hook.Add("HUDShouldDraw", "hg.HUDShouldDraw", function(id)
	if (fakeTimer and fakeTimer - 2 > CurTime()) then
		return false
	end
end)

hook.Add("HG_OnOtrub", "adsadsadhuy!!", function(ply)	
	if ply == LocalPlayer() then
		lply:SetDSP(17)
		plyCommand(lply,"soundfade 100 99999")
	end
end)

hook.Add("Player_Death", "adsadsadhuy!!", function(ply)	
	if ply == LocalPlayer() then
		lply:SetDSP(17)
		plyCommand(lply,"soundfade 100 99999")
	end
end)

local alivestart = CurTime()
hg.screens = hg.screens or {}
local screens = hg.screens
local screened = 0
local curscreen = 1
local switch = false
local file_Delete = file.Delete
hg.alivecntr = hg.alivecntr or 0
local nextSeizureMemory = 0
local seizureMemory
local seizureMemoryEnd = 0
local wasSeizureActive = false

local function remove_imgs()
	if file.Exists("dreams", "DATA") then
		local files, _ = file.Find("dreams/*", "DATA")

		for i, file in pairs(files) do
			file_Delete("dreams/"..file)
		end
	end
end

local disorientationLerp = 0
local concLerp = 0
local nauseaLerp = 0
local tinnitusConcLerp = 0

hook.Add("Player Spawn", "screenshot_game", function(ply)
	if OverrideSpawn then return end

	if ply == lply then
		disorientationLerp = 0
		concLerp = 0
		nauseaLerp = 0
		tinnitusConcLerp = 0

		alivestart = CurTime()
		lply.tried_fixing_limb = nil

		hg.alivecntr = hg.alivecntr + 1

		for i, screen in ipairs(hg.screens) do
			hg.screens[i] = nil
		end

		remove_imgs()
	end
end)

hook.Add("InitPostEntity", "removeshits", function()
	remove_imgs()
end)

hook.Add("Player Disconnected", "removeshits", function()
	remove_imgs()
end)

hook.Add("radialOptions", "DislocatedJoint", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
    
    if org.llegdislocation or org.rlegdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				if hg.StartDislocationMinigame then hg.StartDislocationMinigame(1) else RunConsoleCommand("hg_fixdislocation", 1, 0) end
            end,
            "Fix dislocation (leg)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	end

	local ent = hg.eyeTrace(lply).Entity

	if IsValid(ent) and ent.organism and ent.organism != org and (ent.organism.llegdislocation or ent.organism.rlegdislocation) then
		local target = (IsValid(ent:GetNWEntity("ply")) and ent:GetNWEntity("ply")) or (ent.organism and ent.organism.owner) or ent
		local tbl = {
			function()
			lply.tried_fixing_limb = CurTime() + 0.5
			if hg.StartDislocationMinigame then hg.StartDislocationMinigame(1, ent) else RunConsoleCommand("hg_fixdislocation", 1, 1) end
		end,
		"Fix "..(IsValid(target) and target:GetPlayerName() or ent:GetPlayerName()).."'s dislocation (leg)",
		[5] = Material("radialmenu/broken.png", "smooth mips")
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

hook.Add("radialOptions", "DislocatedJoint2", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
	
    if org.larmdislocation or org.rarmdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				if hg.StartDislocationMinigame then hg.StartDislocationMinigame(2) else RunConsoleCommand("hg_fixdislocation", 2, 0) end
            end,
            "Fix dislocation (arm)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	end

	local ent = hg.eyeTrace(lply).Entity

	if IsValid(ent) and ent.organism and ent.organism != org and (ent.organism.larmdislocation or ent.organism.rarmdislocation) then
		local target = (IsValid(ent:GetNWEntity("ply")) and ent:GetNWEntity("ply")) or (ent.organism and ent.organism.owner) or ent
		local tbl = {
			function()
			lply.tried_fixing_limb = CurTime() + 0.5
			if hg.StartDislocationMinigame then hg.StartDislocationMinigame(2, ent) else RunConsoleCommand("hg_fixdislocation", 2, 1) end
		end,
		"Fix "..(IsValid(target) and target:GetPlayerName() or ent:GetPlayerName()).."'s dislocation (arm)",
		[5] = Material("radialmenu/broken.png", "smooth mips")
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

hook.Add("radialOptions", "DislocatedJaw", function()
    if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	if (lply.tried_fixing_limb or 0) > CurTime() then return end
	local org = lply.organism
	if org.pain > 60 then return end
	
    if org.jawdislocation then
        local tbl = {
            function()
				lply.tried_fixing_limb = CurTime() + 0.5
				if hg.StartDislocationMinigame then hg.StartDislocationMinigame(3) else RunConsoleCommand("hg_fixdislocation", 3, 0) end
            end,
            "Fix dislocation (jaw)"
        }
        hg.radialOptions[#hg.radialOptions + 1] = tbl
	end

	local ent = hg.eyeTrace(lply).Entity

	if IsValid(ent) and ent.organism and ent.organism != org and ent.organism.jawdislocation then
		local target = (IsValid(ent:GetNWEntity("ply")) and ent:GetNWEntity("ply")) or (ent.organism and ent.organism.owner) or ent
		local tbl = {
			function()
			lply.tried_fixing_limb = CurTime() + 0.5
			if hg.StartDislocationMinigame then hg.StartDislocationMinigame(3, ent) else RunConsoleCommand("hg_fixdislocation", 3, 1) end
		end,
		"Fix "..(IsValid(target) and target:GetPlayerName() or ent:GetPlayerName()).."'s dislocation (jaw)",
		[5] = Material("radialmenu/broken.png", "smooth mips")
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

hook.Add("PostRender", "screenshot_think", function()
	local org = lply.organism
	
	if not org or not org.brain or org.otrub or !lply:Alive() then return end
	
	local part = CurTime() - alivestart
	//print(part)
	if part % 60 > 59 and (screened != math.Round(part / 60, 0)) then
		screened = math.Round(part / 60, 0)
		//gui.HideGameUI()

		if gui.IsGameUIVisible() or gui.IsConsoleVisible() or IsValid(vgui.GetHoveredPanel()) then return end

		local data = render.Capture( {
			format = "jpeg",
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH(),
			quality = 1,
			//alpha = false
		} )

		if not data then return end

		local name = "dreams/dream"..hg.alivecntr.."_"..(#screens + 1)..".jpeg"
		
		if not file.Exists("dreams", "DATA") then file.CreateDir("dreams") end
		file.Write(name, data)
		
		timer.Simple(1, function()
			screens[#screens + 1] = Material("data/"..name)
		end)
	end
end)

local braindeathstart = CurTime() + 20
local lerpedpart = 0
local lerpedbrain = 0

hook.Add("Post Post Pre Post Processing", "ShowScreens", function()
	local org = lply.organism
	
	if !lply:Alive() then return end
	if not org or not org.brain then return end

	local part = CurTime() - braindeathstart

	local show_multiki = org.brain > 0.1 and org.otrub

	if show_multiki then
		lerpedbrain = LerpFT(0.05, lerpedbrain, org.brain)
		local time = 40 - (lerpedbrain - 0.1) * 20
		if part % time > time / 3 and curscreen <= #screens and screens[curscreen] and !screens[curscreen]:IsError() then
			switch = true
			local part2 = math.ease.InOutSine(math.sin(((part % time) - time / 3) / (time / 3 * 2) * math.pi))
			lerpedpart = LerpFT(0.1, lerpedpart, part2)
			
			surface.SetDrawColor(255, 255, 255, math.Clamp(lerpedpart * 50, 0, 255))
			surface.SetMaterial(screens[curscreen])
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
			
			DrawToyTown(4, ScrH())
		else
			if switch then
				curscreen = curscreen == #screens and 1 or curscreen + 1
				switch = false
			end
		end
	else
		braindeathstart = CurTime()
	end
end)

local blindoverlay = Material("zcity/neurotrauma/blindoverlay.png")

local hg_potatopc
local old = false
local tinnitusSoundFactor
local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like first-person camera view", 0, 1)

local function CaptureMemoryScreen()
	if gui.IsGameUIVisible() or gui.IsConsoleVisible() or IsValid(vgui.GetHoveredPanel()) then return end
	local data = render.Capture({
		format = "jpeg",
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH(),
		quality = 1
	})
	if not data then return end

	local name = "dreams/dream"..hg.alivecntr.."_seizure_"..(#screens + 1)..".jpeg"
	if not file.Exists("dreams", "DATA") then file.CreateDir("dreams") end
	file.Write(name, data)
	timer.Simple(0, function()
		screens[#screens + 1] = Material("data/"..name)
	end)
end

local function DrawSeizureMemory(org)
	if not org or not org.seizureActive or #screens == 0 then
		seizureMemory = nil
		seizureMemoryEnd = 0
		return
	end

	local time = CurTime()
	if (not seizureMemory or time > seizureMemoryEnd) and time >= nextSeizureMemory then
		nextSeizureMemory = time + math.Rand(2.5, 6)
		seizureMemory = screens[math.random(#screens)]
		seizureMemoryEnd = time + math.Rand(0.45, 1.15)
	end

	if not seizureMemory or time > seizureMemoryEnd then return end
	if seizureMemory.IsError and seizureMemory:IsError() then return end

	local life = math.Clamp((seizureMemoryEnd - time) / 1.15, 0, 1)
	local flicker = 0.55 + math.abs(math.sin(time * 34)) * 0.45
	local alpha = math.Clamp(life * 155 * flicker, 0, 180)
	local jitter = 8 * (1 - life)

	surface.SetDrawColor(255, 255, 255, alpha)
	surface.SetMaterial(seizureMemory)
	surface.DrawTexturedRect(-jitter, -jitter, ScrW() + jitter * 2, ScrH() + jitter * 2)
end

local function DrawScreenFillShape(x, y, radius, segments, roughness, timeOffset)
	local poly = {}
	local time = CurTime() + (timeOffset or 0)

	for i = 0, segments do
		local part = i / segments
		local ang = math.rad(part * -360)
		local wave = math.sin(part * math.pi * 5 + time * 1.8) * 0.34 + math.sin(part * math.pi * 9 - time * 1.25) * 0.28 + math.sin(part * math.pi * 15 + time * 2.35) * 0.22 + math.sin(part * math.pi * 23 - time * 1.6) * 0.16
		local edgeRadius = radius * (1 + wave * roughness)
		poly[#poly + 1] = {x = x + math.sin(ang) * edgeRadius, y = y + math.cos(ang) * edgeRadius}
	end

	draw.NoTexture()
	surface.DrawPoly(poly)
end

local function DrawIncapacitatedDeathFade(deathStateEnd)
	local remaining = math.max(deathStateEnd - CurTime(), 0)
	local fade = math.Clamp((25 - remaining) / 25, 0, 1)
	local finalFade = math.Clamp((6 - remaining) / 6, 0, 1)
	local shine = finalFade * (0.65 + math.abs(math.sin(CurTime() * 9)) * 0.35)
	local sw, sh = ScrW(), ScrH()
	local radius = math.ease.InOutSine(fade) * math.sqrt(sw * sw + sh * sh) / 2

	DrawBloom(0.35 + finalFade * 0.45, 0.8 + finalFade * 2.8, 7, 7, 2, 1, 1, 1, 1)
	surface.SetDrawColor(255, 255, 255, math.Clamp((fade ^ 1.35) * 175 + shine * 35, 0, 255))
	DrawScreenFillShape(sw / 2, sh / 2, radius * 1.04, 320, 0.24 * (1 - finalFade * 0.35), 0)
	surface.SetDrawColor(255, 255, 255, math.Clamp((fade ^ 1.35) * 110 + shine * 25, 0, 255))
	DrawScreenFillShape(sw / 2, sh / 2, radius * 0.99, 320, 0.31 * (1 - finalFade * 0.3), 4.7)
	surface.SetDrawColor(255, 255, 255, math.Clamp((fade ^ 1.35) * 80 + shine * 20, 0, 255))
	DrawScreenFillShape(sw / 2, sh / 2, radius * 0.94, 320, 0.38 * (1 - finalFade * 0.25), 9.2)

	if finalFade > 0 then
		surface.SetDrawColor(255, 255, 255, math.Clamp(finalFade * 180 + shine * 75, 0, 255))
		DrawScreenFillShape(sw / 2, sh / 2, radius * (0.88 + shine * 0.12), 320, 0.2 * (1 - finalFade * 0.45), 13.5)
	end
end

local function DrawIncapacitatedDeathText(seconds, deathStateEnd)
	local remaining = math.max(deathStateEnd - CurTime(), 0)
	local fade = math.Clamp((25 - remaining) / 25, 0, 1)
	local radius = math.ease.InOutSine(fade) * math.sqrt(ScrW() * ScrW() + ScrH() * ScrH()) / 2
	local textDark = math.Clamp((radius - 12) / 80, 0, 1)
	local textValue = math.floor(255 * (1 - textDark))
	local textColor = Color(textValue, textValue, textValue, remDeathStateColor.a)

	draw.SimpleText("You are incapacitated, You will die in " .. seconds, "RemDeathStateFont", ScrW() / 2, ScrH() / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("Post Post Pre Post Processing", "organism-effects", function()
	local spect = IsValid(lply:GetNWEntity("spect")) and lply:GetNWEntity("spect")
	local organism = lply:Alive() and lply.organism or (viewmode == 1 and IsValid(spect) and spect.organism) or {}
	local new_organism = lply:Alive() and lply.new_organism or (viewmode == 1 and IsValid(spect) and spect.new_organism) or {}

	//hg.DrawAffliction(0, 0, 100, 100, 1, "pale")

	if organism.owner == LocalPlayer() then
		if new_organism.otrub and !old then
			hook.Run("HG_OnOtrub", new_organism.owner)
		end
		
		old = new_organism.otrub
	end

	--LerpVariables(FrameTime(),organism,new_organism)

	if not organism then return end
	local alive = lply:Alive() or (spect and spect:Alive())

	local health = (lply:Alive() and lply:Health()) or 100

	if not alive or follow then end

	local org = organism
	
	if not org.brain then return end
	
	local adrenaline = org.adrenaline or 0
	local pulse = org.pulse or 70
	local pain = org.pain or 0
	local hurt = org.hurt or 0
	local blood = org.blood or 5000
	local bleed = org.bleed or 0
	local o2 = org.o2 and org.o2[1] or 30
	local brain = org.brain or 0
	local otrub = lply:Alive() and org.otrub or false
	local analgesia = organism.analgesia or 0
	local analgesiaVisual = org.seizureActive and math.max(analgesia * 3, 3) or analgesia
	local health = health
	local disorientation = org.disorientation or 0
	local immobilization = org.immobilization or 0
	local incapacitated = org.incapacitated or new_organism.incapacitated or false
	local critical = org.critical or false
	local concussion = org.concussion or 0
	local concussionNausea = org.nausea or 0
	local concussionTinnitus = org.concussion_tinnitus or 0
	local deathStateEnd = new_organism.deathStateEnd or org.deathStateEnd
	local seizureActive = org.seizureActive or new_organism.seizureActive or false
	if deathStateEnd and deathStateEnd <= 0 then deathStateEnd = nil end
	if seizureActive and not wasSeizureActive then timer.Simple(0, CaptureMemoryScreen) end
	wasSeizureActive = seizureActive
	tinnitusSoundFactor = Lerp(FrameTime()*2.5,tinnitusSoundFactor or 0, math.min(math.max( lply.tinnitus and (lply.tinnitus - CurTime()) or 0, 0)*7.5,120))
	local tinnitusSoundFactor2 = tinnitusSoundFactor + (hook.Run("ModifyTinnitusFactor", tinnitusSoundFactor) or 0)

	if lply:Alive() and (otrub or new_organism.otrub) and incapacitated and deathStateEnd then
		local seconds = math.max(math.ceil(deathStateEnd - CurTime()), 0)
		remDeathStateColor.a = math.Clamp((25 - (deathStateEnd - CurTime())) / 2, 0, 1) * 255
		PlayRemDeathStateSound()
	elseif IsValid(remDeathStateStation) then
		remDeathStateStation:Stop()
		remDeathStateStation = nil
	end

	--print(lply.tinnitus)
	local adrenK = math.min(math.max(1 + adrenaline, 1), 1.2)

	if org.otrub then
		//DrawMotionBlur(0.1, 1., 0.1)
		//lply:ScreenFade( SCREENFADE.IN, clr_black2, 2, 0.5 )
	end
	
	--maybe 56, 30?
	local normaldsp = hg_gopro:GetBool() and 55 or 0
	lply:SetDSP(normaldsp)

	if otrub or ((fakeTimer and fakeTimer - 2 > CurTime()) and GetConVar("hg_deathfadeout"):GetBool()) then
		--if otrub or (fakeTimer and fakeTimer - 2 > CurTime()) then
		clr_black1.a = math.Clamp(pain / 50 * 255, 250, 255)
		//lply:ScreenFade( SCREENFADE.IN, clr_black2, 2, 0.5 )
		--lply:ScreenFade( SCREENFADE.IN, Color(0,0,0,255), 2, 0.5 )
		
		if isnumber(zb.ROUND_STATE) and (zb.ROUND_STATE ~= 1) then
			lply:SetDSP(normaldsp)
			plyCommand(lply,"soundfade "..tinnitusSoundFactor2.." 25")
		elseif lply:Alive() then
			lply:SetDSP(17)
			plyCommand(lply,"soundfade 100 25")
		end
	else
		plyCommand(lply,"soundfade "..tinnitusSoundFactor2.." 25")

		if ((disorientation and disorientation > 3) or (brain and brain > 0.2) or lply.PlayerClassName == "headcrabzombie" or lply:GetNetVar("headcrab")) and lply:Alive() then
			lply:SetDSP(130)
		else
			lply:SetDSP((lply.suiciding and lply:Alive()) and 130 or normaldsp)
		end
	end

	if lply:Alive() and (otrub or new_organism.otrub) and incapacitated and deathStateEnd then
		DrawIncapacitatedDeathFade(deathStateEnd)
	end

	if not alive then
		return false
	end
	
	k1 = Lerp(FrameTime() * 15, k1 or 0, math.min(math.min(adrenaline / 1, 2),1.5))
	k2 = (30 - (o2 or 30)) / 30 + (1 - (consciousnessLerp or 1)) * 1-- + brain * 2
	k3 = ((5000 / math.max(blood, 1000)) - 1) * 1.5

	local stamina = org.stamina and org.stamina[1] or 180
	local k4 = math.Clamp((EXHAUSTED_THRESHOLD - stamina) / EXHAUSTED_THRESHOLD, 0, 1)

	DrawSharpen(k1 * 2, k1 * 1)
	local lowpulse = math.max((70 - pulse) / 70, 0) + math.max(3000 * ((math.cos(CurTime()/2) + 1) / 2 * 0.1 + 1) - (blood * adrenK - 300),0) / 400

	if (lply.PlayerClassName == "headcrabzombie" or lply:GetNetVar("headcrab")) and lply:Alive() then
		disorientation = disorientation + 100
	end

	disorientation = disorientation + amtflashed * 5

	local amount = 1 - math.Clamp(lowpulse + disorientation / 4 + k2 * 2,0,1)

	disorientationLerp = LerpFT(disorientation > disorientationLerp and 1 or 0.15, disorientationLerp, math.max(lply.suiciding and 1.5 or 0, disorientation))

	if (disorientationLerp > 1) and lply:Alive() or brain > 0 then
		local add2 = disorientationLerp - 1
		if not brain_motionblur and lply.PlayerClassName ~= "headcrabzombie" then DrawMotionBlur(0.15 - math.Clamp(add2 / 1, 0, 0.1), add2 * 2, 0.001) end
		if disorientationLerp > 2 then
			local add = (disorientationLerp - 2) * 2
			local time = CurTime() * 3
			local mul = math.Clamp(add / 16, 0, 0.2)

			ang1[1] = math.cos(time) + math.sin(time * 0.5) + math.sin((time - 5) * 1.1)
			ang1[2] = math.sin(time) + math.cos(time * 0.5) + math.sin((time + 1) * 1.1)
			ViewPunch(ang1 * mul * 0.125)
			//ViewPunch2(ang1 * mul * 1 * 0.25)

			//local ang = lply:EyeAngles()
			//lply:SetEyeAngles(ang - ang1 * 0.01)

			ang2[3] = math.Rand(-15,15) * mul
			//SetViewPunchAngles(ang2)
			//ViewPunch(ang1 * mul * 1)
		end
	end


	//pain = math.abs(math.cos(CurTime())) * 40
	if (pain > 0) or (hurt > 0) or (immobilization > 0) or (brain > 0) then
		local k = ((hurt + immobilization / 15) / 2)
		--DrawToyTown(1, k * ScrH())
		local newpain = pain - 10
		if newpain > 0 then
			//surface.SetDrawColor(0, 0, 0, (newpain / 20) * 255 - math.ease.InOutCirc(math.abs(math.cos(CurTime()))) * 50)
			//surface.SetMaterial(pain_mat)
			//surface.DrawTexturedRect(-1, -1, ScrW()+1, ScrH()+1)
			local blur = math.max((newpain / 30 + brain * 10),0) / 30
			if blur > 0 then
				DrawMaterialOverlay( "sprites/mat_jack_hmcd_scope_aberration", blur )
			end
		end
	end
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc
	local potato = hg_potatopc:GetBool()
	if (k1 > 0) or (k2 > 0) or (k3 > 0) or (k4 > 0) or brain > 0 then
		if !potato then
			DrawToyTown(2, (k3 * 3 + k2 * 1 + k4 * 1.5 + brain * 10) * ScrH() / 2)
		else

		end
	end

	--DrawMaterialOverlay( "homigrad/vgui/bloodblur.png", 0)
	local view = render.GetViewSetup()
	--RenderSuperDoF(view.origin,view.angles,0)
	if analgesiaVisual > 1 then
		DrawMaterialOverlay( "particle/warp4_warp_noz", -(analgesiaVisual - 0.5) * math.sin(CurTime()) * 5 / 150 )
	end

	/*

	local amt = (math.cos(addtime) + math.sin(addtime * 3) + math.sin(addtime * 2)) / 90
	local amt2 = (math.sin(addtime) + math.cos(addtime * 5) + math.sin(addtime * 6)) / 90
	surface.SetDrawColor(255,255,255,math.abs(amt * 255 * 30))
	surface.SetMaterial(blindoverlay)

	local mat = Matrix({
		{1 - amt, amt, 0, -amt2 / 2},
		{amt2, 1 - amt2, 0, -amt / 2},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	})
	blindoverlay:SetMatrix("$basetexturetransform", mat)
	surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

	*/

	tabblood["$pp_colour_colour"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_colour"], math.max(0, (blood / 5000) * (potato and (blood / 5000) or 1) - (!org.otrub and potato and k2 or 0) - k4 * 0.5 + (math.max(analgesiaVisual - 1, 0) * math.sin(CurTime()) * 5)))
	//tabblood["$pp_colour_contrast"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_contrast"], health < 80 and math.max(1.5 * ( 1 - math.min(health / 50, 1) ), 1 ) or 1)
	tabblood["$pp_colour_brightness"] = Lerp(FrameTime() * 30, tabblood["$pp_colour_brightness"], (potato and ((blood / 5000 - 1) / 2 - (!org.otrub and k2 / 10 or 0) - k4 / 12) or 0) )
	tabblood["$pp_colour_addb"] = 0
	//tabblood["$pp_colour_addg"] = k2 / 15
	//tabblood["$pp_colour_addr"] = k2 / 15
	--tab["$pp_colour_brightness"] = k1 > 1 and -(k1 - 1) / 20 or 0
	--tab["$pp_colour_contrast"] = k1 > 1 and -(k1 - 1) / 10 + 1 or 1
	--DrawBloom( 0.80, 2, 9, 9, 1, 1, 1, 1, 1 )
	//DrawColorModify(tab)
	
	DrawColorModify(tabblood)

	if concussion > 0 and lply:Alive() then
		concLerp = LerpFT(0.03, concLerp, concussion)
		if concLerp > 1.0 then
			local wobbleTime = CurTime() * 2.5
			local wobbleAmt = math.Clamp((concLerp - 1.0) / 3, 0, 0.4)
			local wobbleAng = Angle(
				math.sin(wobbleTime) * wobbleAmt * 3,
				math.cos(wobbleTime * 0.7) * wobbleAmt * 4,
				math.sin(wobbleTime * 1.3) * wobbleAmt * 2
			)
			ViewPunch(wobbleAng)
		end
		if concLerp > 2.0 then
			local blurAmt = math.Clamp((concLerp - 2.0) / 3, 0, 0.15)
			DrawToyTown(2, blurAmt * ScrH())
		end
	else
		concLerp = LerpFT(0.15, concLerp, 0)
		if concLerp < 0.05 then concLerp = 0 end
	end

	if concussionNausea > 0 and lply:Alive() then
		nauseaLerp = LerpFT(0.02, nauseaLerp, concussionNausea)
		if nauseaLerp > 1.0 then
			local swayTime = CurTime() * 1.8
			local swayAmt = math.Clamp((nauseaLerp - 1.0) / 4, 0, 0.3)
			local swayAng = Angle(
				math.sin(swayTime) * swayAmt * 2,
				math.cos(swayTime * 0.6) * swayAmt * 3,
				0
			)
			ViewPunch(swayAng)
		end
	else
		nauseaLerp = LerpFT(0.15, nauseaLerp, 0)
		if nauseaLerp < 0.05 then nauseaLerp = 0 end
	end

	if concussionTinnitus > 0.1 and lply:Alive() then
		tinnitusConcLerp = LerpFT(0.02, tinnitusConcLerp, concussionTinnitus)
	else
		tinnitusConcLerp = LerpFT(0.15, tinnitusConcLerp, 0)
		if tinnitusConcLerp < 0.05 then tinnitusConcLerp = 0 end
	end

	local ent = IsValid(lply.FakeRagdoll) and lply.FakeRagdoll or lply

	if otrub then
		--[[render.PushFilterMag( TEXFILTER.ANISOTROPIC )
		render.PushFilterMin( TEXFILTER.ANISOTROPIC )

		local textOtrub = "You are unconscious. "
		local textOtrub2 =  
			( critical and "You can't be saved." ) or 
			( incapacitated and "You will not get up without someone's help." ) or 
			( 
				"You will probably wake up in "
				..( 	
					( pain < 50 and "about a minute." ) or 
					( pain < 100 and "about two minutes." ) or 
					"a few minutes."
				) 
			)

		local parsed = markup.Parse( 
			"<font=HomigradFontMedium>"..
			( critical and "You're criticaly injured." or textOtrub )..
			"\n<colour=255,"..( critical and 25 or 255 )..","..( critical and 25 or 255 ) ..",255>"..
			( textOtrub2 ).."</colour></font>" 
		)
		--((critical and "You can not be saved.") or 
		--(incapacitated and "You will not get up without someone's help.") or 
		--( "You will probably wake up in " .. (pain < 50 and "about a minute.") ) or 
		--((pain < 100 and "about two minutes.") or "a few minutes.")) -- WTF???
		
		--surface.SetTextColor(255,255,255,255)
		--surface.SetFont("HomigradFontMedium")
		--local txtSizeX, txtSizeY = surface.GetTextSize(textOtrub)
		--surface.SetTextPos(ScrW()/2 - (txtSizeX/2),ScrH()/1.1 - (txtSizeY/2))
		--surface.DrawText(textOtrub)

		parsed:Draw( ScrW()/2, ScrH()/1.1, TEXT_ALIGN_CENTER, nil, nil, TEXT_ALIGN_CENTER )
		
		render.PopFilterMag()
			render.PopFilterMin()--]]
	end

	DrawSeizureMemory(org)
	
	if IsValid(ent) and ent.Blinking and lply:Alive() then
		surface.SetDrawColor(0,0,0,255)
		if amtflashed and amtflashed > 0.1 and amtflashed < 0.8 and ent.Blinking > 0.1 then
			surface.DrawRect(-1, -1,ScrW() + 1,ScrH() + 1)
			//surface.DrawRect(-1,-1,ScrW()+1,ent.Blinking * ScrH())
			//surface.DrawRect(-1,ScrH() + 1,ScrW()+1,-ent.Blinking * ScrH())
		end
	end
	if lply:Alive() and (otrub or new_organism.otrub) and incapacitated and deathStateEnd then
		local seconds = math.max(math.ceil(deathStateEnd - CurTime()), 0)
		DrawIncapacitatedDeathText(seconds, deathStateEnd)
	end
end)

hook.Add("OnNetVarSet","wounds_netvar",function(index, key, var)
	if key == "wounds" then
		local ent = Entity(index)
		--local ent = hg.RagdollOwner(ent) or ent
		
		if IsValid(ent) then
			if ent.wounds then
				for i = 1, #ent.wounds do
					if !var or !var[i] then continue end
					var[i][5] = ent.wounds[i][5]
				end
			end

			ent.wounds = var
			--PrintTable(ent.wounds)
			local rag = IsValid(ent:GetNWEntity("FakeRagdoll")) and ent:GetNWEntity("FakeRagdoll")-- or IsValid(ent:GetNWEntity("RagdollDeath")) and ent:GetNWEntity("RagdollDeath")
			if IsValid(rag) then
				rag.wounds = var
			end
		end
	end
end)

hook.Add("OnNetVarSet","wounds_netvar2",function(index, key, var)
	if key == "arterialwounds" then
		local ent = Entity(index)
		--local ent = hg.RagdollOwner(ent) or ent
		
		if IsValid(ent) then
			if ent.arterialwounds then
				for i = 1, #ent.arterialwounds do
					if not var[i] then continue end
					var[i][5] = ent.arterialwounds[i][5]
				end
			end

			for i = 1, #var do
				if ent.arterialwounds and ent.arterialwounds[i] then continue end
				hg.queueArterialWoundSound(ent, var[i])
			end

			ent.arterialwounds = var
			local rag = IsValid(ent:GetNWEntity("FakeRagdoll")) and ent:GetNWEntity("FakeRagdoll")-- or IsValid(ent:GetNWEntity("RagdollDeath")) and ent:GetNWEntity("RagdollDeath")
			
			if IsValid(rag) then
				rag.arterialwounds = var
			end
		end
	end
end)

hook.Add("Player Spawn", "removewounds", function(ply)
	if OverrideSpawn then return end

	ply.wounds = {}
	ply.arterialwounds = {}

	local rag = ply:GetNWEntity("FakeRagdoll")
	if IsValid(rag) then
		rag.wounds = {}
		rag.arterialwounds = {}
	end
end)

hook.Add("Fake", "huyhuyhuy235", function(ply,ragdoll)
	if not IsValid(ragdoll) then return end

	ragdoll.wounds = ply.wounds
	ragdoll.arterialwounds = ply.arterialwounds
end)

function hg.applyFountain(pos, ang, mul, mul2, forward, ent)
	if bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER then
		if math.random(2) == 1 then return end
		hg.addBloodPart2(pos, ang:Forward() * forward * 0.5 + VectorRand(-25,25) * mul2, nil, nil, nil, nil, true, nil, ent)
		hg.addBloodPart2(pos + VectorRand(-1,1), ang:Forward() * forward * 0.25 + VectorRand(-10,10) * mul2, nil, nil, nil, nil, true, nil, ent)
		//hg.addBloodPart2(pos + VectorRand(-1,1), ang:Forward() * forward * 0.25 + VectorRand(-10,10) * mul2, nil, nil, nil, nil, true, nil, ent)
	else
		hg.addBloodPart(pos, ang:Forward() * forward * 2 * math.abs(math.sin(CurTime() * 3) + math.cos(CurTime() * 5) + math.sin(CurTime() * 2) + 4) * 0.1 + ang:Right() * 15 * (math.sin(CurTime()) * 1) + ang:Right() * math.sin(CurTime() * 2) * 15 + VectorRand(-3, 3),nil,nil,nil,true)
		hg.addBloodPart(pos + VectorRand(-1,1), ang:Forward() * 55 + VectorRand(-25,25) * mul2,nil,nil,nil,nil, nil, ent)
		//hg.addBloodPart(pos + VectorRand(-1,1), ang:Forward() * 55 + VectorRand(-25,25) * mul2,nil,nil,nil,nil, nil, ent)
	end
end

local hg_old_blood = ConVarExists("hg_old_blood") and GetConVar("hg_old_blood") or CreateClientConVar("hg_old_blood", 0, true, false, "new decals, or old", 0, 1)
local vecTorso = Vector(1, 1, 1)
local checkpulsebones = {
	["ValveBiped.Bip01_Head1"] = true,
	["ValveBiped.Bip01_R_Hand"] = true,
	["ValveBiped.Bip01_L_Hand"] = true,
}
local hg_blood_fps = ConVarExists("hg_blood_fps") and GetConVar("hg_blood_fps") or CreateClientConVar("hg_blood_fps", 24, true, nil, "fps to draw blood", 12, 165)
local arteryDelayedDripSound = "arteryblooddrip/splat-blood"
local arteryDelayedDripCount = 10
local arteryNeckSlitSound = "rem_neckslit.ogg"
local arterySoundDelayMin = 1
local arterySoundDelayMax = 1.25
local arterySoundPitchMin = 95
local arterySoundPitchMax = 110
local arteryBurstCount = 2
local arterySizeMul = 1.35

local pitchAddClasses = {
	["furry"] = 20,
	["headcrabzombie"] = -60
}
local muffedClasses = {
	["headcrabzombie"] = true
}

local function getArterySoundEnt(ent)
	if not IsValid(ent) then return end

	local rag = ent.GetNWEntity and ent:GetNWEntity("FakeRagdoll")
	if IsValid(rag) then return rag end

	rag = ent.GetNWEntity and ent:GetNWEntity("RagdollDeath")
	if IsValid(rag) then return rag end

	return ent
end

local function getArterialWoundPos(ent, wound)
	local target = getArterySoundEnt(ent)
	if not IsValid(target) then return end

	local bone = target:LookupBone(wound[4] or "")
	if bone then
		local mat = target:GetBoneMatrix(bone)
		if mat and wound[2] and wound[3] then
			local bonePos, boneAng = mat:GetTranslation(), mat:GetAngles()
			if bonePos and boneAng then
				return LocalToWorld(wound[2], wound[3], bonePos, boneAng), target
			end
		end
	end

	return target:GetPos(), target
end

local function randomArteryPitch()
	return math.random(arterySoundPitchMin, arterySoundPitchMax)
end

local function isArterySoundAlive(ent)
	if not IsValid(ent) then return false end
	local owner = ent:IsRagdoll() and hg.RagdollOwner(ent) or ent
	if IsValid(owner) and owner:IsPlayer() then
		return owner:Alive() and (not owner.organism or owner.organism.alive ~= false)
	end
	local org = ent.organism
	return org and org.alive ~= false or ent.Health and ent:Health() > 0
end

local function playRandomArteryDrip(ent, wound, vol)
	local pos = getArterialWoundPos(ent, wound)
	if not pos then return end

	sound.Play(arteryDelayedDripSound .. math.random(1, arteryDelayedDripCount) .. ".wav", pos, 70, randomArteryPitch(), vol or 1)
end

function hg.queueArterialWoundSound(ent, wound)
	if not IsValid(ent) or not wound or not isArterySoundAlive(ent) then return end

	local delay = math.Rand(arterySoundDelayMin, arterySoundDelayMax)
	local artery = wound[7]
	local org = ent.organism or {}

	if artery == "arteria" and isArterySoundAlive(ent) and not org.otrub then
		local _, target = getArterialWoundPos(ent, wound)
		if IsValid(target) then
			local snd = CreateSound(target, arteryNeckSlitSound)
			if snd then
				snd:SetSoundLevel(75)
				snd:PlayEx(1, randomArteryPitch())
				snd:ChangeVolume(0, delay)
				timer.Simple(delay + 0.05, function()
					if snd then snd:Stop() end
				end)
			end
		end
	end

	timer.Simple(delay, function()
		if not isArterySoundAlive(ent) then return end
		playRandomArteryDrip(ent, wound, artery == "arteria" and 0.85 or 1)
	end)
end

local hg_heartbeat_volume = ConVarExists("hg_heartbeat_volume") and GetConVar("hg_heartbeat_volume") or CreateClientConVar("hg_heartbeat_volume", 1, true, nil, "heartbeat loudness", 0, 4)

-- Returns a valid bone index or nil. Handles both bone names (string) and
-- bone indices (number) stored in wound data, and protects against invalid
-- bone ids (-1) which would crash the engine via GetBonePosition/GetBoneMatrix.
local function GetValidBone(ent, bone)
	if not IsValid(ent) then return nil end
	local id
	if type(bone) == "number" then
		id = bone
	else
		id = ent:LookupBone(bone or "")
	end
	if not id or id < 0 then return nil end
	return id
end

hook.Add("Player-Ragdoll think", "organism-think-client-blood", function(ply, ent, time)
	--local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
	--print(ply,ent,ply.organism.owner,ply.new_organism.owner)
	local organism = ply.organism
	local new_organism = ply.new_organism
	
	local seen = ent.shouldTransmit-- and not ent.NotSeen
	local wounds = ply.wounds
	local arterialwounds = ply.arterialwounds

	local org = ent.organism

	if !org then return end

	if org and org.pulse and org.o2 and org.o2[1] then
		local pulse = org.heartbeat
		org.pulsethink = org.pulsethink or 0
		local speed = math.Clamp(org.heartbeat / 60, 1, 3.3) * 0.5 * (org.o2[1] < 8 and 0 or 1)
		org.pulsethink = org.pulsethink + (org.heartbeat > 1 and 1 or 0) * (org.holdingbreath and 0 or 1) * FrameTime() * 5.6 * (speed) * (org.lungsfunction and 1 or 0) * ((org.alive and !ent.headexploded) and 1 or 0)
		
		local torso = ent:LookupBone("ValveBiped.Bip01_Spine2")
		--local chest = ent:LookupBone("ValveBiped.Bip01_Spine1")
		
		if torso then
			if ent:GetPos():DistToSqr(lply:GetPos()) > 450 * 450 then return end
			local sin = (math.sin(org.pulsethink) + 1) * 0.5
			local amt = 0.05 * sin * math.max(org.pulse / 70, 0.5)
			
			local size = 1 + amt
			vecTorso[1] = size
			vecTorso[2] = size
			vecTorso[3] = size
			
			ent:ManipulateBoneScale(torso, vecTorso)
			//ent:ManipulateBoneAngles(torso, Angle(0, amt, 0))

			vecTorso[1] = 0
			vecTorso[2] = amt * 2
			vecTorso[3] = 0
			
			if sin < 0.1 and org.analgesia <= 1.5 and not org.breathed then
				org.lastbreathed = CurTime()
				org.breathed = true
				local heartbeat = org.heartbeat or 0
				local muffed
				local pitch = math.Clamp(heartbeat / 200 * 100, 100, 100) * math.Clamp((org.stamina and org.stamina[1] and (1 + (1 - org.stamina[1] / org.stamina.max) * 0.2) or 1), 1, 1.2)
				local vol = math.Remap(heartbeat, 70, 300, 0, 0.25) + (org.stamina and org.stamina[1] and 1 - org.stamina[1] / org.stamina.max or 0)

				if ent.armors then
					muffed = ent.armors["face"] == "mask2" or ent.PlayerClassName == "Combine"
				end

				if ply.PlayerClassName and muffedClasses[ply.PlayerClassName] then
					muffed = muffedClasses[ply.PlayerClassName]
				end

				local pitchadd = 0
				if ply.PlayerClassName and pitchAddClasses[ply.PlayerClassName] then
					pitchadd = pitchAddClasses[ply.PlayerClassName]
				end

				if vol > 1.5 and ply == lply then
					local amta = (vol - 1.5)
					local ang1 = Angle(amta * -0.5, 0, 0)
					local ang2 = Angle(amta * 5, 0, 0)

					--[[ViewPunch4(ang1)
					--ViewPunch(ang1)

					timer.Simple(speed, function()
						ViewPunch4(-ang1)
						--ViewPunch(-ang2)
					end)--]]

				end

				ply:EmitSound("snds_jack_hmcd_breathing/" .. (ThatPlyIsFemale(ent) and "f" or "m") .. math.random(4) .. ".wav", min(heartbeat * 1.0 / ( muffed and 2.5 or 4), 45), pitch + pitchadd + math.Rand(-2, 2), vol, CHAN_AUTO, 0, muffed and 16 or 0)
			elseif org.breathed and sin >= 0.1 then
				org.breathed = false
			end

			--ent:ManipulateBonePosition(torso, vecTorso)

			--local size = 1 - 0.02 * math.sin(org.pulsethink)
			--vecTorso[1] = size
			--vecTorso[2] = size
			--vecTorso[3] = size

			--ent:ManipulateBoneScale(chest, vecTorso)
		end
	end

	ply.pulse_breathe = ply.pulse_breathe or {}
	ent.pulse_breathe = ply.pulse_breathe
	
	hg.LerpVariables(FrameTime() * 10, organism, new_organism)
	
	local org = ent.organism or {}
	local owner = ent
	
	local beatsPerSecond = math.max(min(30 / math.max(org.pulse or 70,2), 4), 0.1) * (!hg_old_blood:GetBool() and 0.3 or 1)
	
	if org.pulse and org.heartbeat > 30 and (org.lastpulse or 0) + (1 / math.Clamp(org.heartbeat, 1, 600)) * 60 < CurTime() then
		org.lastpulse = CurTime()
		local pulse = org.heartbeat or 0
		local pain = org.pain or 0
		
		local dist = owner:GetPos():DistToSqr(lply:GetPos())
		local carryent = lply:GetNetVar("carryent")
		local carrybone = lply:GetNetVar("carrybone")
		local cantcheck = org.CantCheckPulse
		local checkingplayer = (IsValid(carryent) and carryent.organism == ply.organism and !cantcheck and checkpulsebones[carryent:GetBoneName(carryent:TranslateBoneToPhysBone(carrybone))])
		
		if dist < 64 * 64 and ((ply == lply and !checkingplayer) or checkingplayer) then
			local vol = checkingplayer and 2 or ((pain > 60 and ply == lply) and 1 or (pulse > 200 and ((200 - 95) / 50 + 0.12 - (pulse - 200) / 1000) or pulse > 95 and (pulse - 95) / 50 + 0.12 or 0.12))
			if not checkingplayer then
				vol = math.Clamp(vol, 0, 0.7) * hg_heartbeat_volume:GetFloat()
			end

			--ply:EmitSound("heartbeat/heartbeat_single.wav", 55, 60, vol)
			if ent:GetVelocity():LengthSqr() < 10 then
				sound.Play("heartbeat/heartbeat_single.wav", ply:EyePos(), 55, 60, vol * 1.5)
			else
				EmitSound("heartbeat/heartbeat_single.wav", ply:EyePos(), ply:EntIndex(), CHAN_AUTO, vol, 55, nil, 60)
			end
		end
	end

	--why? because
	if org.pulse and (ent.pulse_breathe.lastbreathe or 0) < CurTime() and org.lastbreathed and org.lastbreathed + 5 < CurTime() then
		local heartbeat = org.heartbeat or 0
		ent.pulse_breathe.lastbreathe = CurTime() + (1 / math.Clamp(org.heartbeat + (org.o2[1] - 30) * 1, 1, 120)) * 90 + ( org.o2[1] < 20 and 5 or 0)
		
		if org.analgesia <= 1.5 and org.heartbeat > 1 then
			if (ent:WaterLevel() < 3) then
				local muffed

				if ent.armors then
					muffed = ent.armors["face"] == "mask2" or ent.PlayerClassName == "Combine"
				end
				
				if org.timeValue and org.o2.curregen <= org.timeValue * 0.5 and org.o2[1] < 20 then
					ply:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "fe" or "").."male_wheeze"..math.random(5)..".mp3", 40, nil, nil, nil, nil, 1)
				end
			else
				if org.o2[1] < 15 then
					ply:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "fe" or "").."male_drown"..math.random(5)..".mp3", 60)
				end
			end
		end
	end

	local fountains = GetNetVar("fountains")
	if fountains and fountains[ent] then
		local tbl = fountains[ent]
		if (tbl.time or 0) < CurTime() and org.pulse then
			local mul = 1 / math.max(org.pulse / 40 * 25, 2) * 0.75
			local mul2 = math.max(org.pulse, 1) / 15
			local forward = mul2 * 150
			tbl.time = CurTime() + mul * 0.5
			
			if seen then
				local mat = ent:GetBoneMatrix(tbl.bone)

				if mat then
					local pos, ang = LocalToWorld(tbl.lpos, tbl.lang, mat:GetTranslation(), mat:GetAngles())
					
					hg.applyFountain(pos, ang, mul, mul2, forward, ent)
				end
			else
				local pos, ang = ent:GetPos(), angle_zero
				hg.applyFountain(pos, ang, mul, mul2, forward, ent)
			end
		end
	end
	
	if org and org.blood and org.blood > 10 and wounds and #wounds > 0 then
		if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
			for i, wound in pairs(wounds) do
				local size = math.random(0, 1) * math.max(math.min(wound[1], 1), 0.5)

				if wound[5] + beatsPerSecond < time then
					local boneID = GetValidBone(ent, wound[4])
					if seen and boneID then
						local bone = wound[4]
						local should = !(hg.amputatedlimbs2[bone] and org[hg.amputatedlimbs2[bone].."amputated"])

						if !should then continue end

						local mat = ent:GetBoneMatrix(boneID)
						if not mat then continue end
						local bonePos, boneAng = mat:GetTranslation(), mat:GetAngles()
						if not wound[2] or not wound[3] or not bonePos or not boneAng then continue end
						local pos, ang = LocalToWorld(wound[2], wound[3], bonePos, boneAng)

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							if wound[5] + 1 < time then
								hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
							end
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, false, nil, ent)
						end

						wound[5] = time + (water and 2 or (math.Rand(0, 1) * (!hg_old_blood:GetBool() and 0.5 or 1) / wound[1] * 15))
					else
						local pos = ent:GetPos()

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, false, nil, ent)
						end

						wound[5] = time + (water and 2 or (math.Rand(0, 1) * (!hg_old_blood:GetBool() and 0.5 or 1) / wound[1] * 15))
					end
				end
			end
		end
	end
	
	if org and org.blood and org.blood > 10 and arterialwounds and #arterialwounds > 0 then
		for i, wound in pairs(arterialwounds) do
			local addtime = seen and 1 / math.Clamp(org.pulse or 70, 1,15) * 0.25 or 0.06
			local boneID = GetValidBone(ent, wound[4])
			if wound[5] + addtime < time and boneID then
				local bonePos, ang = ent:GetBonePosition(boneID)
				if not bonePos or not ang then continue end
				if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
					local size = math.random(1, 2) * math.max(math.min(wound[1], 1), 0.5) * arterySizeMul
					if seen and boneID then
						local bone = wound[4]

						local should = !(hg.amputatedlimbs2[bone] and org[hg.amputatedlimbs2[bone].."amputated"])

						if !should then continue end
						
						local mat = ent:GetBoneMatrix(boneID)
						if not mat then continue end
						bonePos, boneAng = mat:GetTranslation(), mat:GetAngles()
						if not wound[2] or not wound[3] or not bonePos or not boneAng then continue end
						local pos = LocalToWorld(wound[2], wound[3], bonePos, boneAng)

						local dir = wound[6]
						local len = dir:Length() * (org.pulse or 70) / 70
						local _, dir = LocalToWorld(vector_origin, dir:Angle(), vector_origin, ang)
						
						dir = -dir:Forward() * len

						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							for _ = 1, arteryBurstCount do
								hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
							end
						else
							local vel = VectorRand(-1, 1) * (org.pulse or 70) / 70 + dir * 5 * (math.abs(math.sin(CurTime() * 2) + math.cos(CurTime() * (5 + i * 2)) + math.sin(CurTime() * (1 + i))) * 0.6 + math.sin(CurTime() * 2) + 4) * 0.1 + dir:Angle():Right() * 25 * math.sin(CurTime() * 2) * math.cos(CurTime() * 4) + ang:Up() * 25 * math.sin(CurTime() * 3) * math.cos(CurTime() * 1) + VectorRand(-1, 1) * (org.pulse or 70) / 70
							hg.addBloodPart(pos, vel, nil, size, size, true, nil, ent)
							for _ = 2, arteryBurstCount do
								hg.addBloodPart(pos, vel * math.Rand(0.65, 1.05) + VectorRand(-3, 3) * (org.pulse or 70) / 70, nil, size * math.Rand(0.85, 1.15), size * math.Rand(0.85, 1.15), true, nil, ent)
							end
						end

						wound[5] = time + (water and 2 or (0.5 * 1 / hg_blood_fps:GetInt()))
					else
						local pos = ent:GetPos()
						
						local water = bit.band(util.PointContents(pos), CONTENTS_WATER) == CONTENTS_WATER
						if water then
							for _ = 1, arteryBurstCount do
								hg.addBloodPart2(pos, VectorRand(-5, 5), nil, nil, nil, nil, true, nil, ent)
							end
						else
							hg.addBloodPart(pos, VectorRand(-15, 15), nil, size, size, true, nil, ent)
							for _ = 2, arteryBurstCount do
								hg.addBloodPart(pos, VectorRand(-15, 15), nil, size * math.Rand(0.85, 1.15), size * math.Rand(0.85, 1.15), true, nil, ent)
							end
						end

						wound[5] = time + (water and 2 or 0)
					end
				end
			end
		end
	end
end)

local grubModels = {
	["lleg"]   = Model("models/limbspartial/thighleft.mdl"),
	["rleg"]   = Model("models/limbspartial/thighright.mdl"),
	["larm"]   = Model("models/limbspartial/elbowleft.mdl"),
	["rarm"]   = Model("models/limbspartial/elbowright.mdl"),
	["lhand"]  = Model("models/limbspartial/kneeleft.mdl"),
	["rhand"]  = Model("models/limbspartial/kneeright.mdl"),
	["llegup"] = Model("models/limbspartial/kneeleft.mdl"),
	["rlegup"] = Model("models/limbspartial/kneeright.mdl"),
	["larmup"] = Model("models/limbspartial/shoulderpartial1.mdl"),
	["rarmup"] = Model("models/limbspartial/shoulderpartial2.mdl"),
	["head"]   = Model("models/limbspartial/elbowleft.mdl"),
}

local grubScale = {
	["lleg"]   = 0.8,
	["rleg"]   = 0.8,
	["larm"]   = 1.0,
	["rarm"]   = 1.2,
	["lhand"]  = 0.8,
	["rhand"]  = 0.7,
	["llegup"] = 1.2,
	["rlegup"] = 1.2,
	["larmup"] = 1,
	["rarmup"] = 1,
	["head"]   = 1.0,
}

local grubPool = {}
local vecalmostzero = Vector(0.01, 0.01, 0.01)

local modelPlacements = {
	[1] = {
		["ValveBiped.Bip01_L_Calf"] = {Vector(19.7, -0.5, -0.2), Angle(-90, 0, 0)},
		["ValveBiped.Bip01_R_Calf"] = {Vector(19.7, -0.5, -0.2), Angle(-90, 0, 0)},
		["ValveBiped.Bip01_R_Forearm"] = {Vector(14, 0.2, 1), Angle(-90, 0, -0.3)},
		["ValveBiped.Bip01_L_Forearm"] = {Vector(14, 0.2, -1), Angle(-90, 0, -0.3)},
		["ValveBiped.Bip01_R_Hand"] = {Vector(13, 0.4, 0.1), Angle(-93, 0, 0.3)},
		["ValveBiped.Bip01_L_Hand"] = {Vector(13, 0.3, -0.1), Angle(-93, 0, 0.3)},
		["ValveBiped.Bip01_L_UpperArm"] = {Vector(6.6, -8.5, 0), Angle(-90, -70, -10)},
		["ValveBiped.Bip01_R_UpperArm"] = {Vector(7.6, -8, 0), Angle(90, 120, 10)},
		["ValveBiped.Bip01_L_Thigh"] = {Vector(2.8, -9, -1), Angle(0, 10, -90)},
		["ValveBiped.Bip01_R_Thigh"] = {Vector(-3, -8, -3), Angle(0, -10, -90)},
	},
	[0] = {
		["ValveBiped.Bip01_L_Calf"] = {Vector(22, -0.5, 0.6), Angle(-90, 0, 0)},
		["ValveBiped.Bip01_R_Calf"] = {Vector(22, -0.5, 0.6), Angle(-90, 0, 0)},
		["ValveBiped.Bip01_R_Forearm"] = {Vector(15, -0.2, 1), Angle(-90, 0, -0.3)},
		["ValveBiped.Bip01_L_Forearm"] = {Vector(15, -0.2, -1), Angle(-90, 0, -0.3)},
		["ValveBiped.Bip01_R_Hand"] = {Vector(15.3, 0, 0.5), Angle(-93, 0, 0.3)},
		["ValveBiped.Bip01_L_Hand"] = {Vector(15.3, 0, -0.6), Angle(-93, 0, 0.3)},
		["ValveBiped.Bip01_L_UpperArm"] = {Vector(6.6, -6, 1), Angle(-90, -70, -10)},
		["ValveBiped.Bip01_R_UpperArm"] = {Vector(7.3, -6, -1), Angle(90, 120, 10)},
		["ValveBiped.Bip01_L_Thigh"] = {Vector(4, -9, -1), Angle(0, 10, -90)},
		["ValveBiped.Bip01_R_Thigh"] = {Vector(-3, -9, -1), Angle(0, -10, -90)},
	}
}

local limbs = {
	["lleg"] = "ValveBiped.Bip01_L_Calf",
	["rleg"] = "ValveBiped.Bip01_R_Calf",
	["larm"] = "ValveBiped.Bip01_L_Forearm",
	["rarm"] = "ValveBiped.Bip01_R_Forearm",
	["lhand"] = "ValveBiped.Bip01_L_Hand",
	["rhand"] = "ValveBiped.Bip01_R_Hand",
	["llegup"] = "ValveBiped.Bip01_L_Thigh",
	["rlegup"] = "ValveBiped.Bip01_R_Thigh",
	["larmup"] = "ValveBiped.Bip01_L_UpperArm",
	["rarmup"] = "ValveBiped.Bip01_R_UpperArm",
	["head"] = "ValveBiped.Bip01_Head1"
}

function hg.amputatedbone(ent, bone)
	if ent.organism and hg.amputatedlimbs2[bone] then
		if ent.organism[hg.amputatedlimbs2[bone].."amputated"] then
			return true
		end
	end
end

hg.amputatedlimbs = limbs

hg.amputatedlimbs2 = {}
for k, v in pairs(limbs) do
	hg.amputatedlimbs2[v] = k
end

local vecFull = Vector(1, 1, 1)

local limbParent = {
	["lleg"] = "llegup",
	["rleg"] = "rlegup",
	["larm"] = "larmup",
	["rarm"] = "rarmup",
	["lhand"] = "larm",
	["rhand"] = "rarm",
}

function hg.GoreCalc(ent, ply)
	local org = ent.new_organism or ent.organism
	if !org then return end

	for bone, nam in pairs(limbs) do
		if !org[bone.."amputated"] then
			local bon = ent:LookupBone(nam)
			if not bon or bon < 0 then continue end

			if !ent:GetManipulateBoneScale(bon):IsEqualTol(vecFull, 0.01) then
				ent:ManipulateBoneScale(bon, vecFull)
			end

			continue
		end
		
		local bon = ent:LookupBone(nam)
		if not bon or bon < 0 then continue end
		local mat = ent:GetBoneMatrix(bon)
		local parentBon = ent:GetBoneParent(bon)
		if not parentBon or parentBon < 0 then continue end
		local mat2 = ent:GetBoneMatrix(parentBon)
		if not mat or not mat2 then continue end
		mat:SetScale(vecalmostzero)
		
		hg.bone_apply_matrix(ent, bon, mat)
		
		if IsValid(ply.OldFakeRagdoll) then
			hg.bone_apply_matrix(ply, bon, mat)
		end

		local parent = limbParent[bone]
		if parent and org[parent.."amputated"] then continue end

		local fem = ThatPlyIsFemale(ent) and 1 or 0
		
		if !modelPlacements[fem][nam] then continue end

		local pos, ang = LocalToWorld(modelPlacements[fem][nam][1], modelPlacements[fem][nam][2], mat2:GetTranslation(), mat2:GetAngles())
		
		local mdlPath = grubModels[bone] or grubModels["larm"]
		
		if !IsValid(grubPool[bone]) then
			grubPool[bone] = ClientsideModel(mdlPath)
			grubPool[bone]:SetNoDraw(true)
			grubPool[bone]:SetModelScale(grubScale[bone] or 1.0)
		end
		
		local stub = grubPool[bone]
		stub:SetRenderOrigin(pos)
		stub:SetRenderAngles(ang)
		stub:SetupBones()
		stub:DrawModel()
	end
end

local prank = {}
local time_troll = 100

local DontCallMe = false
hook.Add("HG.InputMouseApply","zzzzzzzzzzzzbrain_death",function(tbl)
	 

	if lply:Alive() and lply.organism and (lply.organism.brain or 0) > 0.1 then
		if #prank < time_troll then table.insert(prank,1,{tbl.x,tbl.y}) end
		if #prank >= time_troll then table.remove(prank,#prank) end
		
		local amt = lply.organism.brain / 0.3

		local xa = Lerp(1 * amt,tbl.x,prank[#prank][1])// + math.sin(CurTime() / 5) * amt * 10
		local ya = Lerp(1 * amt,tbl.y,prank[#prank][2])// + math.cos(CurTime() / 5) * math.sin(CurTime() / 2) * amt * 10

		tbl.angle.pitch = math.Clamp(tbl.angle.pitch + tbl.y / 100 + ya / 100, -89, 89)
		tbl.angle.yaw = tbl.angle.yaw - tbl.x / 100 - xa / 100
		tbl.override_angle = true
	end

	--[[local actwep = LocalPlayer():GetActiveWeapon()
	if not actwep or not actwep.GetTrace then return end
	local hitpos,pos,ang = actwep:GetTrace()

	local ply = hg.GetCurrentCharacter(Entity(2))
	local dist = ply:EyePos():Distance(LocalPlayer():EyePos())
	ply:SetupBones()
	scr = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Head1")):GetTranslation():ToScreen()

	angle.pitch = math.Clamp(angle.pitch + (scr.y - (pos+ang:Forward() * dist):ToScreen().y) / 50, -89, 89)
	angle.yaw = angle.yaw - (scr.x - (pos+ang:Forward() * dist):ToScreen().x) / 50
	cmd:SetViewAngles(angle)

	return true--]]
end)

local EXHAUSTED_SOUND = "exhaustedloop.ogg"

local exhaustedSoundPatch

local function StopExhaustedSound()
	if exhaustedSoundPatch then
		exhaustedSoundPatch:Stop()
		exhaustedSoundPatch = nil
	end
end

hook.Add("Think", "hg_exhausted_sound", function()
	if not IsValid(lply) or not lply:Alive() or not lply.organism or not lply.organism.stamina then
		StopExhaustedSound()
		return
	end

	local stamina = lply.organism.stamina[1] or 0

	if stamina >= EXHAUSTED_THRESHOLD then
		StopExhaustedSound()
		return
	end

	local vol = math.Clamp((EXHAUSTED_THRESHOLD - stamina) / EXHAUSTED_THRESHOLD, 0, 1)

	if not exhaustedSoundPatch then
		exhaustedSoundPatch = CreateSound(lply, EXHAUSTED_SOUND)
		if not exhaustedSoundPatch then return end
		exhaustedSoundPatch:Play()
	end

	exhaustedSoundPatch:ChangeVolume(vol, 0.25)
end)

hook.Add("LocalPlayerDeath", "hg_exhausted_sound_death", StopExhaustedSound)
hook.Add("ShutDown", "hg_exhausted_sound_shutdown", StopExhaustedSound)

net.Receive("headtrauma_concussion_update", function()
	local severity = net.ReadFloat()
	local concussionLevel = net.ReadFloat()
	if not lply or not lply:Alive() then return end

	local flashAlpha = math.Clamp(severity * 22, 0, 130)
	if flashAlpha > 1 then
		lply:ScreenFade(SCREENFADE.IN, Color(220, 180, 180, flashAlpha), 0.35, 0.45)
	end

	if severity > 0.4 then
		local punch = math.Clamp(severity * 3.5, 1, 22)
		lply:ViewPunch(AngleRand(-punch, punch))
		lply:ViewPunch(Angle(math.Rand(-1, 1) * punch * 0.4, math.Rand(-1, 1) * punch * 0.4, math.Rand(-1, 1) * punch * 0.5))
	end

	if severity > 1.2 then
		local shake = math.Clamp(severity * 2, 2, 16)
		util.ScreenShake(lply:EyePos(), shake, 6, 0.4, 120)
	end
end)
