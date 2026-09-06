local hint
local hg_hints = ConVarExists("hg_hints") and GetConVar("hg_hints") or CreateClientConVar("hg_hints", "1", true, false, "Toggle UI hints")

local HintBackgroundColor = Color( 0, 0, 0, 200 )

hook.Add("HUDPaint","EntHints",function()
	if not hg_hints:GetBool() then return end 
	if HGSuppressEntityHints then return end
	if lply.organism and lply.organism.otrub then return end
	if !lply:Alive() then return end
	
	local trace = hg.eyeTrace(lply)

	if not trace then return end

	HintBackgroundColor.a = LerpFT(0.1, HintBackgroundColor.a, (IsValid(trace.Entity) and trace.Entity.HudHintMarkup) and 200 or 0)

	hg.BasicHudHint(trace.Entity, trace, hint)
end)

function hg.BasicHudHint(ent, trace)
	hint = (IsValid(ent) and ent.HudHintMarkup) or hint

	if not hint then return end

	local x, y = trace.HitPos:ToScreen().x, trace.HitPos:ToScreen().y
	y = y + 145 + -45

	draw.RoundedBox(2, x - hint:GetWidth() / 2 - 2.5, y - 2.5, hint:GetWidth() + 5, hint:GetHeight() + 5, HintBackgroundColor)
	
	hint:Draw(x, y, TEXT_ALIGN_CENTER, nil, 175 * (HintBackgroundColor.a / 200), TEXT_ALIGN_CENTER)

	if ent.AdditionalInfoFunc then
		local str = ent.AdditionalInfoFunc()

		local w, h = surface.GetTextSize(str)
		surface.SetFont("ZCity_Tiny")
		surface.SetTextColor(color_white)
		surface.SetTextPos(x - w * 0.5, y + hint:GetHeight() + h)
		surface.DrawText(str)
	end
end
