local vignette = Material("effects/shaders/zb_vignette")
local color = {
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
local strength = 0
local theme
local themeLoading = false

local function getFogState()
	local ply = LocalPlayer()
	local org = IsValid(ply) and ply:Alive() and (ply.new_organism or ply.organism)
	if not org or org.otrub or (org.cotard or 0) <= 0 then return end
	local strength = math.Clamp(org.cotard or 0, 0, 1)
	local pulse = (math.sin(CurTime() * 0.8) + 1) * 0.5
	local density = strength * (0.55 + pulse * 0.3)
	local kind = org.cotardType or 0
	local distance = 260 - density * (kind == 1 and 190 or 130)
	local fogColor = kind == 1 and Color(155, 185, 200) or kind == 2 and Color(175, 165, 190) or Color(165, 165, 160)
	return math.max(distance, 45), fogColor, density
end

local function clear()
	strength = 0
	if IsValid(theme) then
		theme:Stop()
	end
	theme = nil
	themeLoading = false
end

hook.Add("RenderScreenspaceEffects", "CotardEffects", function()
	local ply = LocalPlayer()
	local org = IsValid(ply) and ply:Alive() and (ply.new_organism or ply.organism)
	local target = org and math.Clamp(org.cotard or 0, 0, 1) or 0
	strength = math.Approach(strength, target, FrameTime() * (target > strength and 2 or 0.8))
	if strength <= 0.001 or not org or org.otrub then
		clear()
		return
	end

	local kind = org.cotardType or 0
	local pulse = (math.sin(CurTime() * (kind == 1 and 1.35 or 0.8)) + 1) * 0.5
	local tunnel = strength * (0.48 + pulse * 0.38)
	local vision = kind == 1 and strength * (0.72 + pulse * 0.2) or strength * 0.35
	local blur = kind == 1 and 4 + vision * 12 or 2 + vision * 5

	if not IsValid(theme) and not themeLoading and strength > 0.2 then
		themeLoading = true
		sound.PlayFile("sound/border.mp3", "noblock noplay", function(channel)
			themeLoading = false
			if not IsValid(channel) then return end
			local current = IsValid(ply) and ply:Alive() and (ply.new_organism or ply.organism)
			if not current or current.otrub or (current.cotard or 0) <= 0 then
				channel:Stop()
				return
			end
			theme = channel
			theme:EnableLooping(true)
			theme:SetVolume(0)
			theme:Play()
		end)
	end
	if IsValid(theme) then theme:SetVolume(math.Clamp(strength * 0.55, 0, 0.55)) end

	DrawBloom(0.025 * vision, 0.1 * vision, blur, 0, 1, 0.2, 0.65, 0.75, 1)
	color["$pp_colour_brightness"] = kind == 3 and -0.1 * tunnel or -0.04 * tunnel
	color["$pp_colour_contrast"] = kind == 2 and 1 - 0.24 * tunnel or 1 - 0.16 * tunnel
	color["$pp_colour_colour"] = 1 - (kind == 3 and 0.88 or kind == 2 and 0.55 or 0.42) * tunnel
	color["$pp_colour_addr"] = kind == 2 and pulse * 0.025 * vision or kind == 3 and 0.008 * vision or 0
	color["$pp_colour_addg"] = kind == 2 and 0.006 * vision or 0
	color["$pp_colour_addb"] = kind == 1 and 0.035 * vision or kind == 2 and 0.02 * vision or 0
	color["$pp_colour_mulr"] = kind == 3 and 0.015 * vision or 0
	color["$pp_colour_mulg"] = kind == 2 and 0.01 * vision or 0
	color["$pp_colour_mulb"] = kind == 1 and 0.025 * vision or kind == 2 and 0.015 * vision or 0
	DrawColorModify(color)

	vignette:SetFloat("$c0_z", math.Clamp(tunnel * 0.92, 0, 0.92))
	vignette:SetFloat("$c1_y", math.Clamp(tunnel * 1.05, 0, 1.05))
	DrawToyTown(2, ScrH() * math.Clamp(0.04 + tunnel * 0.22, 0.04, 0.28))
	render.SetMaterial(vignette)
	render.DrawScreenQuad()
	DrawSharpen(1, math.Clamp(0.08 + tunnel * 0.75, 0, 0.8))
end)

hook.Add("SetupWorldFog", "CotardWorldFog", function()
	local distance, fogColor, density = getFogState()
	if not distance then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(distance)
	render.FogMaxDensity(math.Clamp(0.2 + density * 0.65, 0.2, 0.85))
	render.FogColor(fogColor.r, fogColor.g, fogColor.b)
	return true
end)

hook.Add("SetupSkyboxFog", "CotardSkyboxFog", function(scale)
	local distance, fogColor, density = getFogState()
	if not distance then return end
	render.FogMode(MATERIAL_FOG_LINEAR)
	render.FogStart(0)
	render.FogEnd(distance * (scale or 1))
	render.FogMaxDensity(math.Clamp(0.2 + density * 0.65, 0.2, 0.85))
	render.FogColor(fogColor.r, fogColor.g, fogColor.b)
	return true
end)

hook.Add("HG_OrganismClientReset", "CotardReset", function(ply)
	if ply == LocalPlayer() then clear() end
end)
