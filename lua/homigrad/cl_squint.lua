local LerpFT = LerpFT or Lerp

local vignetteMat = Material("effects/shaders/zb_vignette")

squintLerp = 0

local colorTab = {
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

local function opticZoomActive(wep)
	return IsValid(wep) and wep.IsZoom and wep:IsZoom() and wep.HasAttachment and wep:HasAttachment("sight", "optic") and not wep.viewmode1
end

local function wantsSquint()
	local lply = LocalPlayer()
	if not IsValid(lply) or not lply:Alive() then return false end
	if GetViewEntity() ~= lply then return false end
	if not zooming then return false end

	local wep = lply:GetActiveWeapon()
	if opticZoomActive(wep) then return false end

	return true
end

hook.Add("HG_CalcView", "HG_SquintOpticKill", function(ply)
	if not zooming then return end
	local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()
	if opticZoomActive(wep) then
		lerpfovadd2 = 0
	end
end)

hook.Add("RenderScreenspaceEffects", "HG_SquintVignette", function()
	local target = wantsSquint() and 1 or 0
	squintLerp = LerpFT(target > squintLerp and 0.10 or 0.045, squintLerp, target)
	if squintLerp < 0.02 then return end

	local shaped = squintLerp * squintLerp * (3 - 2 * squintLerp)
	DrawSharpen(shaped * 0.3, 0.4)

	colorTab["$pp_colour_contrast"] = 1 + shaped * 0.03
	colorTab["$pp_colour_brightness"] = -shaped * 0.02
	DrawColorModify(colorTab)

	local force = shaped * 4.5
	render.UpdateScreenEffectTexture()

	vignetteMat:SetFloat("$c2_x", CurTime() + 10000)
	vignetteMat:SetFloat("$c0_z", force / 4)
	vignetteMat:SetFloat("$c1_y", force / 20)

	render.SetMaterial(vignetteMat)
	render.DrawScreenQuad()
end)

hook.Add("hg_AdjustMouseSensitivity", "HG_SquintSens", function()
	if squintLerp < 0.02 then return end

	return Lerp(squintLerp ^ 1.5, 1, 0.75)
end)

local function applySquintVPWrap()
	if HG_SquintWrappedVP then return end
	if not ViewPunch then return end

	HG_SquintWrappedVP = true
	HG_SquintOrigViewPunch = ViewPunch
	_G.ViewPunch = function(angle)
		return HG_SquintOrigViewPunch(angle * (1 - squintLerp * 0.4))
	end
end
hook.Add("HomigradRun", "HG_SquintVPWrap", applySquintVPWrap)
applySquintVPWrap()