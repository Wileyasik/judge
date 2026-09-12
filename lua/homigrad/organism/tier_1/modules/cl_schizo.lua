local Clamp = math.Clamp

local vignetteMat = Material("effects/shaders/zb_vignette")

local darknessBoost = 0
local lastDarknessCheck = 0
local fogVis = 0

local function episodeFrac(org)
	if not org or (org.schizoEpisodeEnd or 0) <= CurTime() then return 0 end
	local timeLeft = org.schizoEpisodeEnd - CurTime()
	if timeLeft <= 0 then return 0 end
	return Clamp(timeLeft / 3, 0, 1)
end

local SCHIZO_SOUND = "schizosong1.mp3"
local schizoSound
local schizoReplayAt
local schizoLength = SoundDuration(SCHIZO_SOUND) or 0

local function updateSchizoSound(lply, ep, schizo)
	local should = ep > 0.05 or schizo > 0.5
	local vol = Clamp(0.15 + schizo * 0.35 + ep * 0.2, 0.12, 0.65)
	if should and not schizoSound then
		schizoSound = CreateSound(lply, SCHIZO_SOUND)
		if schizoSound then
			schizoSound:ChangeVolume(vol, 0)
			schizoSound:Play()
			if schizoLength > 0 then schizoReplayAt = CurTime() + schizoLength end
		end
	elseif should and schizoSound then
		if schizoLength > 0 and schizoReplayAt and CurTime() >= schizoReplayAt then
			schizoSound:Stop()
			schizoSound:Play()
			schizoReplayAt = CurTime() + schizoLength
		end
		schizoSound:ChangeVolume(vol, 1)
	elseif not should and schizoSound then
		schizoSound:Stop()
		schizoSound = nil
		schizoReplayAt = nil
	end
end

hook.Add("Think", "hg_schizo_sound", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then
		if schizoSound then schizoSound:Stop() schizoSound = nil schizoReplayAt = nil end
		fogVis = 0
		return
	end
	local org = lply.organism
	local schizo = Clamp(org.psycheSchizo or 0, 0, 1)
	local ep = episodeFrac(org)
	updateSchizoSound(lply, ep, schizo)

	local targetFog = Clamp((schizo * 0.8 + ep * 0.4) * (1 + darknessBoost * 0.3), 0, 1)
	local fogRate = fogVis < targetFog and 2.5 or 0.6
	fogVis = fogVis + (targetFog - fogVis) * (1 - math.exp(-FrameTime() * fogRate))

	local t = CurTime()
	if t >= lastDarknessCheck then
		lastDarknessCheck = t + 0.5
		local tr = util.TraceLine({start = lply:GetPos() + Vector(0, 0, 80), endpos = lply:GetPos() + Vector(0, 0, 3000), filter = lply})
		darknessBoost = tr.HitWorld and 1 or 0
	end
end)

local figures = {}
local figuresActive = false
local lookShock = 0

local schizoScream = "schizosong2.mp3"
local sndScreamAvailable = file.Exists("sound/" .. schizoScream, "GAME")
local schizoWhisper = "schizowhisper.mp3"
local sndWhisperAvailable = file.Exists("sound/" .. schizoWhisper, "GAME")
local whisperAt = 0

local function pickFigureSpot(seed, behind)
	local ply = LocalPlayer()
	if not IsValid(ply) then return nil end
	local origin = ply:EyePos()
	local fwd = ply:EyeAngles():Forward()
	for i = 1, 7 do
		local ang = (seed + i) * 2.399963229728653
		local dist = math.Rand(320, 720)
		local pos = origin + Vector(math.cos(ang) * dist, math.sin(ang) * dist, 0)
		if behind then
			local dir = (pos - origin):GetNormalized()
			if fwd:Dot(dir) > -0.2 then continue end
		end
		local tr = util.TraceLine({start = pos + Vector(0, 0, 240), endpos = pos - Vector(0, 0, 120), filter = ply})
		if tr.Hit then
			pos = tr.HitPos
			local eye = tr.HitPos + Vector(0, 0, 70)
			local distToPly = tr.HitPos:DistToSqr(ply:GetPos())
			if distToPly > 14400 then
				return pos, (ply:EyePos() - eye):Angle()
			end
		end
	end
	return nil
end

local function idleSequenceFor(fig)
	local idx = fig:LookupSequence("idle_all_01")
	if idx then fig:ResetSequence(idx) end
end

local function applyPlayerAppearance(fig)
	local lply = LocalPlayer()
	local mdl = lply:GetModel()
	fig:SetModel(mdl)
	fig:SetSkin(lply:GetSkin())
	for _, bg in ipairs(lply:GetBodyGroups()) do
		fig:SetBodygroup(bg.id, lply:GetBodygroup(bg.id))
	end
	fig.appModel = mdl
	idleSequenceFor(fig)
end

local function placeFigure(fig, behind)
	local t = CurTime()
	local pos, ang = pickFigureSpot(fig.seed + (fig.stirs or 0), behind)
	if pos then
		fig:SetPos(pos)
		fig:SetAngles(Angle(0, ang.y, 0))
		fig.figPos = pos
		fig.stirs = (fig.stirs or 0) + 1
	end
	fig.reposAt = t + math.Rand(8, 14)
end

local function createFigures()
	for i = 1, 3 do
		local fig = ClientsideModel(LocalPlayer():GetModel(), RENDERGROUP_OPAQUE)
		if not IsValid(fig) then continue end
		fig:SetMoveType(MOVETYPE_NONE)
		fig:SetNoDraw(true)
		fig:SetColor(Color(0, 0, 0))
		fig:SetRenderMode(RENDERMODE_TRANSALPHA)
		fig.seed = math.random(100000)
		applyPlayerAppearance(fig)
		idleSequenceFor(fig)
		figures[i] = fig
	end
	figuresActive = true
end

local function destroyFigures()
	for i, fig in ipairs(figures) do
		if IsValid(fig) then fig:Remove() end
	end
	figures = {}
	figuresActive = false
end

local function destroyFigure(fig)
	if IsValid(fig) then fig:Remove() end
	for i, f in ipairs(figures) do
		if f == fig then
			table.remove(figures, i)
			break
		end
	end
	if #figures == 0 then figuresActive = false end
end

hook.Add("Think", "hg_schizo_figures_think", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then
		if figuresActive then destroyFigures() end
		return
	end
	local episode = episodeFrac(lply.organism)
	if episode > 0 and not figuresActive then
		createFigures()
	elseif episode <= 0 and figuresActive then
		destroyFigures()
	end
	if not figuresActive then return end

	local t = CurTime()
	local plyMdl = lply:GetModel()
	for i, fig in ipairs(figures) do
		if not IsValid(fig) then continue end
		if fig.appModel ~= plyMdl then
			applyPlayerAppearance(fig)
		end
		if t >= (fig.reposAt or 0) then
			placeFigure(fig)
		end
	end

	local fwd = lply:EyeAngles():Forward()
	local eyes = lply:EyePos()
	for i, fig in ipairs(figures) do
		if not IsValid(fig) then continue end
		local reactReady = t >= (fig.lookReactAt or 0)

		local toFig = fig:GetPos() + Vector(0, 0, 62) - eyes
		local distSqr = toFig:LengthSqr()
		if distSqr < 40000 then
			if reactReady then
				fig.lookReactAt = t + math.Rand(2.5, 4)
				lookShock = 0.5
				if sndWhisperAvailable then
					sound.Play(schizoWhisper, lply:GetPos() + Vector(0, 0, 55), 70, 100)
				end
				placeFigure(fig, true)
			end
			continue
		end
		if not reactReady then continue end
		if distSqr < 160000 then
			local dot = fwd:Dot(toFig:GetNormalized())
			if dot > 0.94 then
				fig.lookReactAt = t + math.Rand(2.5, 4)
				lookShock = 1
				if sndScreamAvailable then
					sound.Play(schizoScream, eyes + toFig:GetNormalized() * 120, 100, 100)
				end
				placeFigure(fig)
			end
		end
	end

	if episode > 0 and sndWhisperAvailable and t >= whisperAt then
		whisperAt = t + math.Rand(8, 16)
		local side = math.random() < 0.5 and 1 or -1
		local wPos = lply:EyePos() + lply:EyeAngles():Right() * side * math.Rand(90, 180) + Vector(0, 0, math.Rand(-30, 40))
		sound.Play(schizoWhisper, wPos, 55, math.random(90, 110))
	end

	local aim = lply:EyePos()
	for i, fig in ipairs(figures) do
		if not IsValid(fig) then continue end
		local dir = aim - fig:GetPos()
		dir.z = 0
		if dir:LengthSqr() > 1 then
			fig:SetAngles(Angle(0, dir:Angle().y, 0))
		end
	end
end)

hook.Add("PostDrawOpaqueRenderables", "hg_schizo_figures_draw", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then return end
	local episode = episodeFrac(lply.organism)
	if episode <= 0.05 or not figuresActive then return end

	for i, fig in ipairs(figures) do
		if not IsValid(fig) then continue end

		render.SetColorModulation(0.02, 0.02, 0.02)
		render.SuppressEngineLighting(true)
		fig:DrawModel()
		render.SuppressEngineLighting(false)
		render.SetColorModulation(1, 1, 1)
	end
end)

local function playerSightLoss(ply)
	local schizo = Clamp((ply.organism and ply.organism.psycheSchizo) or 0, 0, 1)
	local episode = episodeFrac(ply.organism)
	return Clamp((schizo + episode * 0.5) / 1.2, 0, 1)
end

hook.Add("PrePlayerDraw", "hg_schizo_players_black", function(ply)
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism or ply == lply then return end
	local black = playerSightLoss(lply)
	if black <= 0.02 then return end
	render.SuppressEngineLighting(true)
	local b = 1 - black * 0.98
	render.SetColorModulation(b, b, b)
	ply.schizoBlack = black
end)

hook.Add("PostPlayerDraw", "hg_schizo_players_black", function(ply)
	if not ply.schizoBlack then return end
	ply.schizoBlack = nil
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)
end)

hook.Add("PostDrawOpaqueRenderables", "hg_schizo_ragdolls_black", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then return end
	local black = playerSightLoss(lply)
	if black <= 0.02 then return end
	local b = 1 - black * 0.98
	local seen = {}

	local function drawBlack(rag)
		if not IsValid(rag) or rag:IsPlayer() or seen[rag] then return end
		seen[rag] = true
		render.SuppressEngineLighting(true)
		render.SetColorModulation(b, b, b)
		rag:DrawModel()
		render.SetColorModulation(1, 1, 1)
		render.SuppressEngineLighting(false)
	end

	for i, ply in ipairs(player.GetAll()) do
		if ply == lply then continue end
		drawBlack(ply:GetRagdollEntity())
		drawBlack(ply.FakeRagdoll)
	end

	for i, rag in ipairs(hg.ragdolls or {}) do
		if rag.ply == lply then continue end
		drawBlack(rag)
	end
end)

local schizo_color_tab = {
	["$pp_colour_addr"] = 0,
	["$pp_colour_addg"] = 0,
	["$pp_colour_addb"] = 0,
	["$pp_colour_brightness"] = 0,
	["$pp_colour_contrast"] = 1,
	["$pp_colour_colour"] = 1,
	["$pp_colour_mulr"] = 0,
	["$pp_colour_mulg"] = 0,
	["$pp_colour_mulb"] = 0
}

hook.Add("RenderScreenspaceEffects", "hg_schizo_effects", function()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then return end
	local org = lply.organism
	local schizo = Clamp(org.psycheSchizo or 0, 0, 1)
	local episode = episodeFrac(org)
	local dark = 1 + darknessBoost * 0.7
	local total = Clamp((schizo + episode * 0.5) * dark, 0, 1.3)
	if total < 0.2 then return end

	schizo_color_tab["$pp_colour_brightness"] = -0.06 * total
	schizo_color_tab["$pp_colour_contrast"] = 1 + 0.08 * total
	schizo_color_tab["$pp_colour_colour"] = 1 - 0.5 * total
	DrawColorModify(schizo_color_tab)

	local t = CurTime()
	local vignette = total * (0.5 + (episode > 0 and (0.5 + 0.5 * math.sin(t * 14)) or 0))
	if lookShock > 0 then
		lookShock = math.max(0, lookShock - 0.08)
		vignette = vignette + lookShock
	end
	if vignette > 0.02 then
		render.UpdateScreenEffectTexture()
		vignetteMat:SetFloat("$c2_x", t + 10000)
		vignetteMat:SetFloat("$c0_z", vignette * 0.35)
		vignetteMat:SetFloat("$c1_y", vignette * 1.3)
		render.SetMaterial(vignetteMat)
		render.DrawScreenQuad()
	end
	if lookShock > 0 then
		surface.SetDrawColor(0, 0, 0, lookShock * 200)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end)

hook.Add("PostHGCalcView", "hg_schizo_view", function(ply, view)
	if ply ~= LocalPlayer() or not ply.organism then return end
	local schizo = Clamp(ply.organism.psycheSchizo or 0, 0, 1)
	local episode = episodeFrac(ply.organism)
	if schizo < 0.25 and episode <= 0 then return end

	local t = CurTime()
	local amp = (schizo * 0.006 + episode * 0.02) * (1 + darknessBoost * 0.7)
	local p = math.sin(t * (9 + schizo * 21)) * amp * 2
	local y = math.cos(t * (7 + schizo * 14)) * amp * 2
	local r = episode > 0 and math.sin(t * 13) * amp * 6 or 0
	view.angles:Add(Angle(p, y, r))

	if lookShock > 0 then
		view.angles:Add(Angle(math.sin(t * 55) * 0.07 * lookShock, math.cos(t * 45) * 0.07 * lookShock, math.sin(t * 65) * 0.05 * lookShock))
	end
end)

local function schizoFogState()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() or not lply.organism then return end
	local fog = fogVis
	if fog < 0.02 then return end
	return 260 + (1 - fog) * 800, Color(0, 0, 0), fog
end

hook.Add("SetupWorldFog", "SchizoWorldFog", function()
	local distance, fogColor, density = schizoFogState()
	if not distance then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(distance)
	render.FogMaxDensity(Clamp(0.6 + density * 0.4, 0.55, 0.98))
	render.FogColor(fogColor.r, fogColor.g, fogColor.b)
	return true
end)

hook.Add("SetupSkyboxFog", "SchizoSkyboxFog", function(scale)
	local distance, fogColor, density = schizoFogState()
	if not distance then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(distance * (scale or 1))
	render.FogMaxDensity(Clamp(0.6 + density * 0.4, 0.55, 0.98))
	render.FogColor(fogColor.r, fogColor.g, fogColor.b)
	return true
end)