local hg_font_default = "Lora"

if CLIENT then
	local hg_font = ConVarExists("hg_font") and GetConVar("hg_font") or CreateClientConVar("hg_font", hg_font_default, true, false, "Change UI text font")

	if hg_font:GetString() != hg_font_default then
		RunConsoleCommand("hg_font", hg_font_default)
	end

	local font = function()
		return hg_font_default
	end

	surface.CreateFont("HomigradFont", {
		font = font(),
		size = ScreenScale(10),
		weight = 1100,
		outline = false
	})

	surface.CreateFont("ScoreboardPlayer", {
		font = font(),
		size = ScreenScale(7),
		weight = 1100,
		outline = false
	})

	surface.CreateFont("HomigradFontBig", {
		font = font(),
		size = ScreenScale(12),
		weight = 1100,
		outline = false,
		shadow = true
	})

	surface.CreateFont("HomigradFontMedium", {
		font = font(),
		size = ScreenScale(8),
		weight = 1100,
		outline = false,
	})

	surface.CreateFont("HomigradFontRadialOld", {
		font = font(),
		size = ScreenScale(11),
		weight = 1100,
		outline = false,
	})

	surface.CreateFont("HomigradFontRadialCenter", {
		font = font(),
		size = ScreenScale(14),
		weight = 1100,
		outline = false,
	})

	surface.CreateFont("HomigradFontLarge", {
		font = font(),
		size = ScreenScale(15),
		weight = 1100,
		outline = false
	})

	surface.CreateFont("HomigradFontGigantoNormous", {
		font = font(),
		size = ScreenScale(25),
		weight = 1100,
		outline = false,
		shadow = false
	})

	surface.CreateFont("HomigradFontSmall", {
		font = font(),
		size = 17,
		weight = 1100,
		outline = false
	})

	surface.CreateFont("HomigradFontVSmall", {
		font = font(),
		size = 12,
		weight = 400,
		outline = false
	})

	surface.CreateFont("ZCity_Veteran", {
		font = "x14y24pxHeadUpDaisy",
		size = ScreenScale(10),
		weight = 500,
		outline = false
	})

	surface.CreateFont("HG_font", {
		font = "Arial",
		extended = false,
		size = 50,
		weight = 500,
		outline = true
	})
end
