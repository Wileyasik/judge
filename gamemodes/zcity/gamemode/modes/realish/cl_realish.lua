MODE.name = "realish"

local MODE = MODE
local menu
local deployUntil = 0
local selectedLoadout = "Assault"
local selectedArmor = "Light"
local selectedSlot = "primary"
local selectedWeapons = {}
local selectedAttachments = {}
local selectedHero = "Strike"
local selectedKillstreaks = {}
local iconCache = {}
local attachmentIconCache = {}
local killstreakIconCache = {}
local killstreakBoxMat
local descriptionCache = {}
local red = Color(200, 20, 20)
local blue = Color(20, 80, 220)
local dark = Color(0, 0, 0)
local white = Color(245, 245, 245)
local yellow = Color(255, 245, 55)
local locked = Color(80, 80, 80, 235)
local orange = Color(255, 95, 0)
local teal = Color(100, 255, 230)
local realishFont = "Bahnschrift"
local gradientLeft = surface.GetTextureID("vgui/gradient-l")
local gradientRight = surface.GetTextureID("vgui/gradient-r")
local hudWhite = Color(245, 245, 245)
local hudDark = Color(0, 0, 0)
local heroSkullMats = {
	[0] = Material("vgui/atlaheroskull.png", "smooth mips"),
	[1] = Material("vgui/revheroskull.png", "smooth mips")
}
local livesAlpha = 0
local livesAtlasPrev = 50
local livesRevenantPrev = 50
local livesAtlasFlash = 0
local livesRevenantFlash = 0
local livesVisibleUntil = 0
local livesY = -120
local deployFlashRed = 0

local introStartTime = -math.huge
local introEndTime = -math.huge
local introDuration = 10
local introSound = nil
local introPulseAngles = {}
local introTextTilts = {}

local roundMusicSound = nil
local roundMusicTimer = "RealishMusicLoop"
local roundMusicStarted = false
local roundMusicPath = nil

local heroMusicSound = nil
local heroMusicTimer = "RealishHeroMusicLoop"
local heroMusicActive = false
local heroMusicPath = "realishgamemode/rem_herovshero.mp3"
local musicMix = 0
local lastHeroAliveTime = 0

local musicVolumeCVar = CreateClientConVar("realish_music_volume", "1", true, false)
local musicMutedCVar = CreateClientConVar("realish_music_muted", "0", true, false)
local musicVolume = 1
local musicMuted = false

local function RefreshMusicSettings()
	if musicVolumeCVar then
		musicVolume = math.Clamp(musicVolumeCVar:GetFloat(), 0, 1)
	end
	if musicMutedCVar then
		musicMuted = musicMutedCVar:GetBool()
	end
end

RefreshMusicSettings()

local function GetMusicVolume()
	if musicMuted then return 0 end
	return musicVolume
end

local function ApplyMusicVolume()
	local vol = GetMusicVolume() * 0.55
	if roundMusicSound then
		roundMusicSound:ChangeVolume(vol * (1 - musicMix), 0)
	end
	if heroMusicSound then
		heroMusicSound:ChangeVolume(vol * musicMix, 0)
	end
end

local function SetMusicVolume(v)
	musicVolume = math.Clamp(v, 0, 1)
	RunConsoleCommand("realish_music_volume", tostring(math.Round(musicVolume, 3)))
	if musicVolume > 0 then
		musicMuted = false
		RunConsoleCommand("realish_music_muted", "0")
	end
	ApplyMusicVolume()
end

local function ToggleMute()
	musicMuted = not musicMuted
	RunConsoleCommand("realish_music_muted", musicMuted and "1" or "0")
	ApplyMusicVolume()
end

local speakerIconMat = Material("icon16/sound.png", "smooth mips")
local muteIconMat = Material("icon16/sound_mute.png", "smooth mips")

surface.CreateFont("RealishIntroTitle", {
	font = "Lora",
	size = ScreenScale(45),
	weight = 400,
	antialias = true
})

surface.CreateFont("RealishIntroTeam", {
	font = "Lora",
	size = ScreenScale(25),
	weight = 400,
	antialias = true
})

surface.CreateFont("RealishIntroSub", {
	font = "Lora",
	size = ScreenScale(15),
	weight = 400,
	antialias = true
})

local function IsIntroActive()
	return CurTime() < introEndTime
end

local function StartIntro()
	if introSound then
		introSound:Stop()
		introSound = nil
	end

	introStartTime = CurTime()
	introEndTime = CurTime() + introDuration

	introPulseAngles = {}
	for i = 1, math.ceil(introDuration / 0.89) + 4 do
		introPulseAngles[i] = (math.random() < 0.5) and 12 or -12
	end

	introTextTilts = {}
	for i = 1, 64 do
		introTextTilts[i] = (math.random() < 0.5) and 3 or -3
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	introSound = CreateSound(ply, "realishgamemode/rem_realishstart.mp3")
	if introSound then
		introSound:PlayEx(1, 100)
	end
end

local function StopIntroSound()
	if introSound then
		introSound:Stop()
		introSound = nil
	end
end

local function StopRoundMusic()
	if roundMusicSound then
		roundMusicSound:Stop()
		roundMusicSound = nil
	end
	timer.Remove(roundMusicTimer)
	roundMusicPath = nil
end

local function StartRoundMusic()
	StopRoundMusic()

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local track = math.Clamp(GetGlobalInt("Realish_MusicTrack", 0), 1, 7)
	if track < 1 then track = math.random(1, 7) end

	roundMusicPath = "realishgamemode/rem_realishtrack" .. track .. ".mp3"
	roundMusicSound = CreateSound(ply, roundMusicPath)
	if roundMusicSound then
		roundMusicSound:PlayEx(GetMusicVolume() * 0.55, 100)
	end

	local dur = SoundDuration(roundMusicPath)
	if not dur or dur <= 0 then dur = 180 end

	timer.Create(roundMusicTimer, dur, 0, function()
		if not roundMusicSound then return end
		roundMusicSound:Stop()
		roundMusicSound:PlayEx(GetMusicVolume() * 0.55, 100)
	end)
end

local function StopHeroMusicSound()
	timer.Remove(heroMusicTimer)
	if heroMusicSound then
		heroMusicSound:Stop()
		heroMusicSound = nil
	end
end

local function StartHeroMusic()
	StopHeroMusicSound()

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	heroMusicSound = CreateSound(ply, heroMusicPath)
	if heroMusicSound then
		heroMusicSound:PlayEx(0, 100)
	end

	local dur = SoundDuration(heroMusicPath)
	if not dur or dur <= 0 then dur = 200 end

	timer.Create(heroMusicTimer, dur, 0, function()
		if not heroMusicSound then return end
		heroMusicSound:Stop()
		heroMusicSound:PlayEx(0, 100)
	end)
end

local function SetHeroMusicMode(active)
	if active == heroMusicActive then return end
	heroMusicActive = active

	if active then
		timer.Remove(roundMusicTimer)
		StartHeroMusic()
	else
		timer.Remove(heroMusicTimer)
		if zb.CROUND == "realish" and zb.ROUND_STATE == 1 then
			StartRoundMusic()
		end
	end
end

local function UpdateMusicMix()
	if not heroMusicActive and musicMix <= 0 then
		if roundMusicSound then
			roundMusicSound:ChangeVolume(GetMusicVolume() * 0.55, 0)
		end
		return
	end

	musicMix = math.Approach(musicMix, heroMusicActive and 1 or 0, FrameTime() / 2.5)

	local vol = GetMusicVolume() * 0.55
	if roundMusicSound and musicMix < 1 then
		roundMusicSound:ChangeVolume(vol * (1 - musicMix), 0)
	end
	if heroMusicSound then
		heroMusicSound:ChangeVolume(vol * musicMix, 0)
		if musicMix <= 0 and not heroMusicActive then
			StopHeroMusicSound()
		end
	end
end

hook.Add("Think", "RealishHeroMusicMix", function()
	if zb.CROUND ~= "realish" or zb.ROUND_STATE ~= 1 then
		if heroMusicActive then
			heroMusicActive = false
			musicMix = 0
			StopHeroMusicSound()
		end
		return
	end

	local ct = CurTime()
	local heroCount = 0
	for _, ply in player.Iterator() do
		if not IsValid(ply) then continue end
		if ply:GetNWBool("Realish_IsHero", false) and ply:Alive() then heroCount = heroCount + 1 end
	end

	if heroCount >= 2 then
		lastHeroAliveTime = ct
		SetHeroMusicMode(true)
	elseif heroMusicActive and ct - lastHeroAliveTime > 3 then
		SetHeroMusicMode(false)
	end

	UpdateMusicMix()
end)

local function DrawPulsingText(text, font, x, y, color, xalign, yalign, appear, slideX, slideY, baseTilt, triggerT)
	local t = CurTime() - introStartTime
	local pulseDur = 0.95
	local copyGrow = 0.45
	local hitScale = 1.3

	local drawX = x + (slideX or 0)
	local drawY = y + (slideY or 0)

	if t < 0 or not appear or appear <= 0 then
		return
	end

	local function pushMatrix(scale, rot, drawColor)
		local m = Matrix()
		m:Translate(Vector(drawX, drawY, 0))
		m:Rotate(Angle(0, rot, 0))
		m:Scale(Vector(scale, scale, 1))
		m:Translate(Vector(-drawX, -drawY, 0))
		cam.PushModelMatrix(m)
		draw.SimpleText(text, font, drawX, drawY, drawColor, xalign, yalign)
		cam.PopModelMatrix()
	end

	local tilt = baseTilt or 0

	-- Shared pulse trigger: every element uses the same triggerT so they wobble in sync.
	local trigger = triggerT or 0
	local relPulseT = t - trigger

	if relPulseT < 0 then
		-- Still sliding in: no pulse tilt/scale wobble, just the growing base tilt.
		pushMatrix(1, tilt, color)
		return
	end

	local pulseStart = math.floor(relPulseT / pulseDur)
	if pulseStart < 0 then
		pushMatrix(1, tilt, color)
		return
	end

	if pulseStart * pulseDur + pulseDur > (introDuration - trigger) + 0.01 then
		pushMatrix(1, tilt, color)
		return
	end

	local phase = (relPulseT - pulseStart * pulseDur) / pulseDur
	if phase < 0 or phase > 1 then
		return
	end

	local ease = phase * phase * (3 - 2 * phase)
	local hitAngle = introPulseAngles[pulseStart + 1] or 0

	local mainScale = 1 + (hitScale - 1) * (1 - ease)
	local rotation = (hitAngle * (1 - ease)) + tilt

	local copyScale = 1 + ease * copyGrow
	local copyAlpha = (1 - ease) * 220

	local colorAlpha = color.a or 255
	copyAlpha = math.min(copyAlpha, colorAlpha)

	pushMatrix(mainScale, rotation, color)
	pushMatrix(copyScale, rotation, Color(color.r, color.g, color.b, copyAlpha))
end

local realishFontSizes = {
	RealishLivesSmall = ScreenScale(12),
	RealishSmall = ScreenScale(15),
	RealishMedium = ScreenScale(15),
	RealishMediumLarge = ScreenScale(25),
	RealishTiny = ScreenScale(11),
	RealishMicro = ScreenScale(8),
	RealishInterfaceLarge = ScreenScale(20)
}

for fontName, fontSize in pairs(realishFontSizes) do
	surface.CreateFont(fontName, {
		font = realishFont,
		size = fontSize,
		weight = 400,
		antialias = true
	})
end

local fitLargeFonts = {"RealishMediumLarge", "RealishMedium", "RealishTiny", "RealishMicro"}
local fitMediumFonts = {"RealishMedium", "RealishTiny", "RealishMicro"}
local fitSmallFonts = {"RealishSmall", "RealishTiny", "RealishMicro"}
local textSizeCache = {}
local createdFitFonts = {}
local fitResultCache = {}
local minFontSize = 6

local function GetTextSize(text, font)
	text = tostring(text)
	local key = font .. "|" .. text
	local cached = textSizeCache[key]
	if cached then return cached[1], cached[2] end

	surface.SetFont(font)
	local w, h = surface.GetTextSize(text)
	textSizeCache[key] = {w, h}

	return w, h
end

local function CreateFitFont(font, size)
	local name = font .. "_" .. size
	if createdFitFonts[name] then return name end

	surface.CreateFont(name, {
		font = realishFont,
		size = size,
		weight = 400,
		antialias = true
	})

	createdFitFonts[name] = true

	return name
end

local function GetFittedFont(font, text, maxW, maxH)
	local baseSize = realishFontSizes[font]
	if not baseSize then return font end

	local w, h = GetTextSize(text, font)
	local scale = 1

	if maxW > 0 and w > maxW then scale = math.min(scale, maxW / w) end
	if maxH > 0 and h > maxH then scale = math.min(scale, maxH / h) end
	if scale >= 1 then return font end

	local size = math.max(minFontSize, math.floor(baseSize * scale))
	local name = CreateFitFont(font, size)
	local fw, fh = GetTextSize(text, name)

	while ((maxW > 0 and fw > maxW) or (maxH > 0 and fh > maxH)) and size > minFontSize do
		size = size - 1
		name = CreateFitFont(font, size)
		fw, fh = GetTextSize(text, name)
	end

	return name
end

local function DrawAutoText(text, font, x, y, color, xalign, yalign, maxW, maxH)
	text = tostring(text)
	maxW = math.floor(maxW or 0)
	maxH = math.floor(maxH or 0)

	local key = font .. "|" .. text .. "|" .. maxW .. "|" .. maxH
	local fitted = fitResultCache[key]

	if not fitted then
		fitted = GetFittedFont(font, text, maxW, maxH)
		fitResultCache[key] = fitted
	end

	draw.SimpleText(text, fitted, x, y, color, xalign, yalign)
end

local function DrawFittedText(text, fonts, x, y, color, xalign, yalign, maxW, maxH)
	text = tostring(text)

	for _, font in ipairs(fonts) do
		local w, h = GetTextSize(text, font)
		if (not maxW or maxW <= 0 or w <= maxW) and (not maxH or maxH <= 0 or h <= maxH) then
			draw.SimpleText(text, font, x, y, color, xalign, yalign)
			return
		end
	end

	DrawAutoText(text, fonts[#fonts], x, y, color, xalign, yalign, maxW, maxH)
end

local palettes = {
	[0] = {
		bg = Color(55, 18, 20, 205),
		panel = Color(105, 32, 36, 220),
		selected = Color(175, 45, 52, 240),
		accent = Color(255, 105, 95),
		deploy = Color(185, 55, 60, 240)
	},
	[1] = {
		bg = Color(18, 28, 55, 205),
		panel = Color(34, 62, 115, 220),
		selected = Color(62, 125, 205, 240),
		accent = Color(85, 190, 255),
		deploy = Color(70, 140, 220, 240)
	}
}

local function GetPalette()
	local ply = LocalPlayer()
	if not IsValid(ply) or not ply.Team then return palettes[0] end
	local ok, teamID = pcall(ply.Team, ply)
	if not ok or teamID == nil then return palettes[0] end
	return palettes[teamID] or palettes[0]
end

local function GetArmorCost(armor)
	return RealishArmorCosts and RealishArmorCosts[armor] or 0
end

local function GetClass(loadout)
	return RealishClasses and RealishClasses[loadout]
end

local function GetOptions(loadout, slotID)
	local class = GetClass(loadout)
	return class and class[slotID]
end

local function GetDefaultChoice(loadout, slotID)
	local options = GetOptions(loadout, slotID)
	local option = options and options[1]
	return option and option.class or ""
end

local function GetSelectedClass(loadout, slotID)
	selectedWeapons[loadout] = selectedWeapons[loadout] or {}
	selectedWeapons[loadout][slotID] = selectedWeapons[loadout][slotID] or GetDefaultChoice(loadout, slotID)
	return selectedWeapons[loadout][slotID]
end

local function GetSelectedOption(loadout, slotID)
	local className = GetSelectedClass(loadout, slotID)

	for _, option in ipairs(GetOptions(loadout, slotID) or {}) do
		if option.class == className then return option end
	end
end

local function GetSlotOption(loadout, slotID, className)
	for _, option in ipairs(GetOptions(loadout, slotID) or {}) do
		if option.class == className then return option end
	end
end

local function GetFirstFreeChoice(loadout, slotID, taken)
	local options = GetOptions(loadout, slotID)
	if not options then return "" end

	for _, option in ipairs(options) do
		if not taken[option.class] then return option.class end
	end

	return ""
end

local function IsWeaponTaken(loadout, slotID, className)
	if not className or className == "" then return false end

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		if slot.id ~= slotID then
			local chosen = selectedWeapons[loadout] and selectedWeapons[loadout][slot.id]
			if chosen == className then return true end
		end
	end

	return false
end

local weaponDataCache = {}

local function GetWeaponData(option)
	if not option then return end
	local class = option.class
	if weaponDataCache[class] ~= nil then return weaponDataCache[class] end

	local weapon = weapons.GetStored(class)
	if not weapon then
		weaponDataCache[class] = false
		return false
	end

	local chain = {weapon}
	local seen = {}
	seen[weapon] = true

	local base = weapon.Base and weapons.GetStored(weapon.Base)
	while base and not seen[base] do
		seen[base] = true
		chain[#chain + 1] = base
		local nextBase = base.Base
		base = nextBase and weapons.GetStored(nextBase) or nil
	end

	local mergedPrimary = {}
	for i = #chain, 1, -1 do
		local w = chain[i]
		if w.Primary then
			for k, v in pairs(w.Primary) do
				mergedPrimary[k] = v
			end
		end
	end

	local data = {}
	for k, v in pairs(weapon) do
		data[k] = v
	end
	data.Primary = mergedPrimary

	weaponDataCache[class] = data
	return data
end

local function HasAttachments(option)
	return option and option.attachments and #option.attachments > 0
end

local function GetSelectedAttachments(loadout, slotID)
	selectedAttachments[loadout] = selectedAttachments[loadout] or {}
	selectedAttachments[loadout][slotID] = selectedAttachments[loadout][slotID] or {}
	return selectedAttachments[loadout][slotID]
end

local function HasSelectedAttachment(loadout, slotID, att)
	return table.HasValue(GetSelectedAttachments(loadout, slotID), att)
end

local attCategoryMap = nil

local function GetAttachmentCategory(att)
	if attCategoryMap == nil then
		attCategoryMap = {}
		for category, list in pairs(hg.attachments or {}) do
			if istable(list) then
				for id in pairs(list) do
					attCategoryMap[id] = category
				end
			end
		end
	end

	return attCategoryMap[att] or "other"
end

local attCategoryLabels = {
	sight = "Sights",
	barrel = "Muzzles & Suppressors",
	grip = "Grips",
	underbarrel = "Underbarrel / Lasers",
	magwell = "Magazines",
	stock = "Stocks",
	mount = "Mounts",
	other = "Other",
}

local attCategoryOrder = {"sight", "barrel", "grip", "underbarrel", "magwell", "stock", "mount", "other"}

local function ToggleAttachment(loadout, slotID, att)
	local attachments = GetSelectedAttachments(loadout, slotID)

	if table.HasValue(attachments, att) then
		table.RemoveByValue(attachments, att)
		return
	end

	local category = GetAttachmentCategory(att)
	for i = #attachments, 1, -1 do
		if GetAttachmentCategory(attachments[i]) == category then
			table.remove(attachments, i)
		end
	end

	attachments[#attachments + 1] = att
end

local function GetAttachmentIcon(att)
	if attachmentIconCache[att] ~= nil then return attachmentIconCache[att] end

	local icon = hg.attachmentsIcons and hg.attachmentsIcons[att]
	if isstring(icon) then icon = Material(icon, "smooth mips") end
	if type(icon) ~= "IMaterial" then icon = false end
	attachmentIconCache[att] = icon

	return icon
end

local function FormatStat(value, fallback)
	if value == nil then return fallback or "N/A" end
	if isnumber(value) then return math.Round(value, 2) end
	return value
end

local function GetWeaponType(weapon)
	local category = weapon and weapon.Category or "other"
	category = string.Replace(category, "Weapons - ", "")
	category = string.Replace(category, "ZCity ", "")
	return string.lower(category)
end

local function GetDescription(option)
	local weapon = GetWeaponData(option)
	local desc = weapon and weapon.Instructions or option and option.desc or ""
	if not isstring(desc) then return "" end
	local clean = string.gsub(desc, "%s+", " ")
	return string.Trim(clean)
end

local function GetDescriptionLines(option, font, width)
	local desc = GetDescription(option)
	local key = (option and option.class or "") .. font .. width .. desc
	if descriptionCache[key] then return descriptionCache[key] end

	surface.SetFont(font)
	local lines = {}
	local line = ""

	for word in string.gmatch(desc, "%S+") do
		local text = line == "" and word or line .. " " .. word
		local textW = surface.GetTextSize(text)

		if textW > width and line ~= "" then
			lines[#lines + 1] = line
			line = word
		else
			line = text
		end
	end

	if line ~= "" then lines[#lines + 1] = line end
	descriptionCache[key] = lines

	return lines
end

local function WrapText(text, font, width)
	surface.SetFont(font)
	local lines = {}
	local line = ""
	for word in string.gmatch(text or "", "%S+") do
		local t = line == "" and word or line .. " " .. word
		if surface.GetTextSize(t) > width and line ~= "" then
			lines[#lines + 1] = line
			line = word
		else
			line = t
		end
	end
	if line ~= "" then lines[#lines + 1] = line end
	return lines
end

local function GetStatLines(option)
	local weapon = GetWeaponData(option)
	local primary = weapon and weapon.Primary or {}
	local clip = primary.ClipSize or primary.DefaultClip
	local wait = primary.Wait
	local damage = primary.Damage or weapon and (weapon.Damage or weapon.DamagePrimary or weapon.ChainsawAttackDamage or weapon.BlastDamage)
	local cone = primary.Cone or primary.Spread

	if clip and clip > 0 then
		local mode = primary.Automatic and "Auto" or "Semi-Auto"
		local firerate = wait and math.Round(60 / wait) or "N/A"
		local accuracy = type(cone) == "Vector" and math.max(cone.x, cone.y, cone.z) or cone
		accuracy = isnumber(accuracy) and math.Clamp(math.Round((1 - accuracy) * 100), 0, 100) .. "%" or "N/A"

		return {
			{"Mode", mode},
			{"Type", GetWeaponType(weapon)},
			{"Damage", FormatStat(damage)},
			{"Ammo", clip .. "/" .. (clip * (option.clips or 2))},
			{"Firerate", firerate},
			{"Accuracy", accuracy},
			{"Reload", weapon and weapon.ReloadTime or "standard"}
		}
	end

	if damage then
		return {
			{"Type", GetWeaponType(weapon)},
			{"Damage", FormatStat(damage)},
			{"Range", weapon and weapon.AttackDistance or "Close"}
		}
	end

	return {
		{"Type", GetWeaponType(weapon)},
		{"Ammo", clip and clip > 0 and clip or "N/A"},
		{"Attachments", HasAttachments(option) and #option.attachments or "None"}
	}
end

local function SelectWeapon(loadout, slotID, className)
	if IsWeaponTaken(loadout, slotID, className) then return false end
	selectedWeapons[loadout] = selectedWeapons[loadout] or {}
	local changed = selectedWeapons[loadout][slotID] ~= className
	selectedWeapons[loadout][slotID] = className
	selectedAttachments[loadout] = selectedAttachments[loadout] or {}
	if changed then selectedAttachments[loadout][slotID] = {} end
	return true
end

local function EnsureLoadout(loadout)
	selectedWeapons[loadout] = selectedWeapons[loadout] or {}
	selectedAttachments[loadout] = selectedAttachments[loadout] or {}

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		selectedWeapons[loadout][slot.id] = selectedWeapons[loadout][slot.id] or GetDefaultChoice(loadout, slot.id)
		selectedAttachments[loadout][slot.id] = selectedAttachments[loadout][slot.id] or {}
	end

	local taken = {}
	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		local className = selectedWeapons[loadout][slot.id]
		if not className or className == "" or taken[className] or not GetSlotOption(loadout, slot.id, className) then
			className = GetFirstFreeChoice(loadout, slot.id, taken)
			selectedWeapons[loadout][slot.id] = className
		end
		if className ~= "" then taken[className] = true end
	end
end

local function EnsureSelectedSlot(loadout)
	if GetOptions(loadout, selectedSlot) then return end

	for _, slot in ipairs(RealishLoadoutSlots or {}) do
		if GetOptions(loadout, slot.id) then
			selectedSlot = slot.id
			return
		end
	end

	selectedSlot = "primary"
end

local function GetWeaponIcon(className)
	if iconCache[className] ~= nil then return iconCache[className] end

	local weapon = weapons.GetStored(className)
	local icon = weapon and (weapon.WepSelectIcon2 or weapon.IconOverride)
	if isstring(icon) then icon = Material(icon, "smooth mips") end
	if type(icon) ~= "IMaterial" then icon = false end
	iconCache[className] = icon

	return icon
end

local function PaintWeaponIcon(option, x, y, w, h, alpha)
	local icon = option and GetWeaponIcon(option.class)

	if icon then
		surface.SetMaterial(icon)
		surface.SetDrawColor(255, 255, 255, alpha or 235)
		surface.DrawTexturedRect(x, y, w, h)
	else
		DrawFittedText(option and option.name or "None", fitMediumFonts, x + w * 0.5, y + h * 0.5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, w - 8, h - 8)
	end
end

local function CanDeploy()
	return zb.ROUND_STATE == 1 and CurTime() >= GetGlobalFloat("Realish_DeployTime", 0)
end

local function SendLoadout(loadout, armor)
	EnsureLoadout(loadout)

	net.Start("realish_loadout")
		net.WriteString(loadout)
		net.WriteString(armor)
		net.WriteUInt(#(RealishLoadoutSlots or {}), 4)

		for _, slot in ipairs(RealishLoadoutSlots or {}) do
			net.WriteString(slot.id)
			net.WriteString(selectedWeapons[loadout][slot.id] or "")

			local attachments = GetSelectedAttachments(loadout, slot.id)
			net.WriteUInt(#attachments, 4)

			for _, att in ipairs(attachments) do
				net.WriteString(att)
			end
		end
	net.SendToServer()
end

local function GetKillstreakMaxPicks()
	return RealishKillstreakConfig and RealishKillstreakConfig.maxPicks or 3
end

local function IsKillstreakSelected(id)
	return table.HasValue(selectedKillstreaks, id)
end

local function GetKillstreakBoxMat()
	if killstreakBoxMat == nil then
		killstreakBoxMat = Material(RealishKillstreakConfig and RealishKillstreakConfig.boxIcon or "icon16/award_star.png", "smooth mips")
	end
	return killstreakBoxMat
end

local killstreakLetterFonts = {}

local function GetKillstreakLetterFont(size)
	size = math.max(8, math.floor(size))
	local name = "RealishKillstreakK_" .. size
	if killstreakLetterFonts[name] then return name end

	surface.CreateFont(name, {
		font = realishFont,
		size = size,
		weight = 800,
		antialias = true
	})

	killstreakLetterFonts[name] = true

	return name
end

local function DrawKillstreakIcon(x, y, w, h, alpha)
	draw.SimpleText("K", GetKillstreakLetterFont(math.min(w, h) * 0.62), x + w * 0.5, y + h * 0.5, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function GetKillstreakIcon(id)
	if killstreakIconCache[id] ~= nil then return killstreakIconCache[id] end

	local data = RealishKillstreaks and RealishKillstreaks[id]
	local icon = data and data.icon
	if isstring(icon) then icon = Material(icon, "smooth mips") end
	if type(icon) ~= "IMaterial" then icon = false end
	killstreakIconCache[id] = icon

	return icon
end

local function GetKillstreakWeaponName(data)
	local class = data and data.weapon
	if not class or class == "" then return "None" end

	local wep = weapons.GetStored(class)
	local printName = wep and wep.PrintName
	if isstring(printName) and printName ~= "" then
		return language.GetPhrase(printName)
	end

	return class
end

local claimedCacheStr = nil
local claimedCache = {}

local function GetClaimedKillstreaks()
	local done = LocalPlayer():GetNWString("Realish_KillstreakDone", "")

	if done ~= claimedCacheStr then
		claimedCacheStr = done
		claimedCache = {}

		for id in string.gmatch(done, "[^,]+") do
			claimedCache[id] = true
		end
	end

	return claimedCache
end

local function GetNextKillstreakTarget()
	local claimed = GetClaimedKillstreaks()
	local best

	for _, id in ipairs(selectedKillstreaks) do
		local data = RealishKillstreaks and RealishKillstreaks[id]
		if data and not claimed[id] then
			local kills = data.kills or 5
			if not best or kills < best then best = kills end
		end
	end

	return best
end

local function SendKillstreakChoices()
	net.Start("realish_killstreak_choice")
		net.WriteUInt(math.min(#selectedKillstreaks, 15), 4)

		for _, id in ipairs(selectedKillstreaks) do
			net.WriteString(id)
		end
	net.SendToServer()
end

local function CloseMenu()
	if IsValid(menu) then
		menu:Remove()
		menu = nil
	end
end

local function AddChoice(parent, x, y, w, h, text, getSelected, selectFunc, subtitle, font, palette, rightFunc)
	local button = vgui.Create("DButton", parent)
	button:SetPos(x, y)
	button:SetSize(w, h)
	button:SetText("")
	button.DoClick = selectFunc
	if rightFunc then button.DoRightClick = rightFunc end
	button.Paint = function(self, bw, bh)
		surface.SetDrawColor(getSelected() == text and palette.selected or palette.panel)
		surface.DrawRect(0, 0, bw, bh)
		surface.SetDrawColor(255, 255, 255, 65)
		surface.DrawOutlinedRect(0, 0, bw, bh, 2)
		DrawFittedText(text, font and fitMediumFonts or fitLargeFonts, bw * 0.5, subtitle and bh * 0.42 or bh * 0.5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, subtitle and bh * 0.55 or bh - 12)

		if subtitle then
			DrawFittedText(subtitle, fitMediumFonts, bw * 0.5, bh * 0.78, palette.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, bh * 0.4)
		end
	end

	return button
end

local function OpenMenu(force, customize, attachmentPage, heroMode, streakMode)
	if zb.CROUND ~= "realish" then return end
	if not IsValid(LocalPlayer()) then return end
	customize = customize or false
	attachmentPage = attachmentPage or false
	heroMode = heroMode or false
	streakMode = streakMode or false

	if IsValid(menu) then
		if not force and LocalPlayer():Alive() then CloseMenu() end
		if IsValid(menu) and (menu.RealishCustomize ~= customize or menu.RealishAttachments ~= attachmentPage or menu.RealishHeroMode ~= heroMode or menu.RealishStreakMode ~= streakMode) then CloseMenu() end
		if not IsValid(menu) then return OpenMenu(force, customize, attachmentPage, heroMode, streakMode) end
		return
	end

	local palette = GetPalette()
	EnsureLoadout(selectedLoadout)
	EnsureSelectedSlot(selectedLoadout)

	local frame = vgui.Create("ZFrame")
	if not IsValid(frame) then frame = vgui.Create("DFrame") end

	menu = frame
	frame.RealishDead = not LocalPlayer():Alive()
	frame.RealishCustomize = customize
	frame.RealishAttachments = attachmentPage
	frame.RealishHeroMode = heroMode
	frame.RealishStreakMode = streakMode
	frame:SetSize(ScrW(), ScrH())
	frame:SetPos(0, 0)
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame.Paint = function(self, w, h)
		local coins = LocalPlayer():GetNWInt("Realish_Coins", 0)
		local cost = GetArmorCost(selectedArmor)
		surface.SetDrawColor(0, 0, 0, 95)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(palette.bg)
		surface.DrawRect(0, 0, w, 56)
		surface.SetDrawColor(palette.bg)
		surface.DrawRect(0, h - 112, w, 112)

		local title = "Select Class"
		local subtitle = "Select a class and deploy when ready. Press RMB on a class to edit loadout."
		if streakMode then
			title = "Select Killstreaks"
			subtitle = "Pick up to " .. GetKillstreakMaxPicks() .. " killstreaks. Streaks grow with kills and reset on death."
		elseif heroMode then
			title = "Select Hero"
			subtitle = "Pick a hero. Press RMB on the hero box to edit selection."
		elseif customize then
			title = selectedLoadout .. (attachmentPage and " Attachments" or " Customization")
			subtitle = "Select weapons and attachments for this class."
		end

		draw.SimpleText(title, "RealishMediumLarge", w * 0.5, 28, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(subtitle, "RealishMedium", w * 0.5, h - 152, palette.accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		if not heroMode and not streakMode then
			draw.SimpleText("Armor Cost: " .. cost .. " Coins | Coins: " .. coins, "RealishMedium", w * 0.5, h - 126, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end

	local w = frame:GetWide()
	local h = frame:GetTall()
	local leftX = w * 0.02
	local topY = 72
	local leftW = w * 0.32
	local midX = w * 0.37
	local midW = w * 0.30
	local rightX = w * 0.70
	local rightW = w * 0.28
	local panelH = h - 206
	local buttonW = w * 0.14
	local gap = w * 0.02
	local classStartX = (w - buttonW * 4 - gap * 3) * 0.5
	local classY = h - 98
	local rebuildSlots
	local rebuildItems

	if streakMode then
		local streakListPanel = vgui.Create("DPanel", frame)
		local streakDetailPanel = vgui.Create("DPanel", frame)
		local back = vgui.Create("DButton", frame)
		local detailStreak = RealishKillstreakOrder and RealishKillstreakOrder[1] or nil

		back:SetPos(18, h - 52)
		back:SetSize(104, 40)
		back:SetText("")
		back.DoClick = function()
			CloseMenu()
			OpenMenu(true, false, false, false, false)
			surface.PlaySound("buttons/button14.wav")
		end
		back.Paint = function(self, bw, bh)
			surface.SetDrawColor(palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, 80)
			surface.DrawOutlinedRect(0, 0, bw, bh, 2)
			DrawAutoText("Back", "RealishMediumLarge", bw * 0.5, bh * 0.5, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, bh - 8)
		end

		streakListPanel:SetPos(leftX, topY)
		streakListPanel:SetSize(leftW, panelH)
		streakListPanel.Paint = function(self, bw, bh)
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			DrawAutoText("Killstreaks " .. #selectedKillstreaks .. "/" .. GetKillstreakMaxPicks(), "RealishMedium", bw * 0.5, 18, teal, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 16, 30)
		end

		streakDetailPanel:SetPos(rightX, topY)
		streakDetailPanel:SetSize(rightW, panelH)
		streakDetailPanel.Paint = function(self, bw, bh)
			local data = detailStreak and RealishKillstreaks[detailStreak]
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			if not data then return end

			DrawFittedText(data.name or detailStreak, fitLargeFonts, bw * 0.5, 28, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 16)

			local icon = GetKillstreakIcon(detailStreak) or GetKillstreakBoxMat()
			if icon then
				surface.SetMaterial(icon)
				surface.SetDrawColor(255, 255, 255, 235)
				surface.DrawTexturedRect(bw * 0.18, 66, bw * 0.64, bh * 0.30)
			end

			local descY = bh * 0.45
			for i, line in ipairs(WrapText(data.desc, "RealishMedium", bw * 0.84)) do
				if i > 8 then break end
				draw.SimpleText(line, "RealishMedium", bw * 0.08, descY + (i - 1) * 18, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end

			draw.SimpleText("Kills required: " .. (data.kills or 5), "RealishMedium", bw * 0.08, bh * 0.70, palette.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("Reward: " .. GetKillstreakWeaponName(data), "RealishMedium", bw * 0.08, bh * 0.70 + 26, palette.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText("LMB to toggle selection", "RealishMedium", bw * 0.5, bh - 34, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local cardH = 96
		local cardW = leftW - 24
		local cardGap = 14

		for i, streakID in ipairs(RealishKillstreakOrder or {}) do
			local data = RealishKillstreaks[streakID]
			if not data then continue end

			local card = vgui.Create("DButton", streakListPanel)
			card:SetPos(12, 44 + (i - 1) * (cardH + cardGap))
			card:SetSize(cardW, cardH)
			card:SetText("")
			card.DoClick = function()
				detailStreak = streakID

				if IsKillstreakSelected(streakID) then
					table.RemoveByValue(selectedKillstreaks, streakID)
					SendKillstreakChoices()
					surface.PlaySound("buttons/button14.wav")
					return
				end

				if #selectedKillstreaks >= GetKillstreakMaxPicks() then
					surface.PlaySound("ui/rem_selectbad.wav")
					return
				end

				selectedKillstreaks[#selectedKillstreaks + 1] = streakID
				SendKillstreakChoices()

				if isstring(data.selectSound) and data.selectSound ~= "" then
					surface.PlaySound(data.selectSound)
				else
					surface.PlaySound("buttons/button14.wav")
				end
			end
			card.Paint = function(self, bw, bh)
				local isSelected = IsKillstreakSelected(streakID)
				surface.SetDrawColor(isSelected and palette.selected or Color(20, 20, 20, 210))
				surface.DrawRect(0, 0, bw, bh)
				surface.SetDrawColor(isSelected and orange or Color(255, 255, 255, 80))
				surface.DrawOutlinedRect(0, 0, bw, bh, isSelected and 2 or 1)

				local icon = GetKillstreakIcon(streakID) or GetKillstreakBoxMat()
				if icon then
					surface.SetMaterial(icon)
					surface.SetDrawColor(255, 255, 255, isSelected and 255 or 160)
					surface.DrawTexturedRect(8, 8, bh - 16, bh - 16)
				end

				DrawFittedText(data.name or streakID, fitLargeFonts, bh, bh * 0.4, yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, bw - bh - 48, bh * 0.45)
				DrawFittedText((data.kills or 5) .. " kills", fitMediumFonts, bh, bh * 0.72, palette.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, bw - bh - 48, bh * 0.35)

				if isSelected then
					local idx = 0
					for n, id in ipairs(selectedKillstreaks) do
						if id == streakID then
							idx = n
							break
						end
					end

					DrawAutoText(tostring(idx), "RealishMediumLarge", bw - 26, bh * 0.5, orange, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 36, bh - 12)
				end
			end
		end

		return
	end

	if heroMode then
		local heroListPanel = vgui.Create("DPanel", frame)
		local heroDetailPanel = vgui.Create("DPanel", frame)
		local back = vgui.Create("DButton", frame)

		back:SetPos(18, h - 52)
		back:SetSize(104, 40)
		back:SetText("")
		back.DoClick = function()
			CloseMenu()
			OpenMenu(true, false, false, false)
			surface.PlaySound("buttons/button14.wav")
		end
		back.Paint = function(self, bw, bh)
			surface.SetDrawColor(palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, 80)
			surface.DrawOutlinedRect(0, 0, bw, bh, 2)
			DrawAutoText("Back", "RealishMediumLarge", bw * 0.5, bh * 0.5, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, bh - 8)
		end

		heroListPanel:SetPos(leftX, topY)
		heroListPanel:SetSize(leftW, panelH)
		heroListPanel.Paint = function(self, bw, bh)
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			draw.SimpleText("Heroes", "RealishMedium", bw * 0.5, 18, teal, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		heroDetailPanel:SetPos(rightX, topY)
		heroDetailPanel:SetSize(rightW, panelH)
		heroDetailPanel.Paint = function(self, bw, bh)
			local hero = RealishHeroes and selectedHero and RealishHeroes[selectedHero]
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			if not hero then return end

			DrawFittedText(hero.name, fitLargeFonts, bw * 0.5, 28, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 16)

			local teamID = LocalPlayer():Team()
			local skullMat = heroSkullMats[teamID] or heroSkullMats[0]
			if skullMat and skullMat ~= false then
				surface.SetMaterial(skullMat)
				surface.SetDrawColor(255, 255, 255, 235)
				surface.DrawTexturedRect(bw * 0.18, 66, bw * 0.64, bh * 0.30)
			end

			local descY = bh * 0.45
			for i, line in ipairs(WrapText(hero.desc, "RealishMedium", bw * 0.84)) do
				if i > 8 then break end
				draw.SimpleText(line, "RealishMedium", bw * 0.08, descY + (i - 1) * 18, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end
		end

		local heroCardH = 96
		local heroCardW = leftW - 24
		local heroCardGap = 14
		for i, heroID in ipairs(RealishHeroOrder or {}) do
			local hero = RealishHeroes and RealishHeroes[heroID]
			if not hero then continue end

			local card = vgui.Create("DButton", heroListPanel)
			card:SetPos(12, 44 + (i - 1) * (heroCardH + heroCardGap))
			card:SetSize(heroCardW, heroCardH)
			card:SetText("")
			card.DoClick = function()
				selectedHero = heroID
				net.Start("realish_hero_choice")
					net.WriteString(heroID)
				net.SendToServer()
				surface.PlaySound("buttons/button14.wav")
			end
			card.Paint = function(self, bw, bh)
				local isSelected = selectedHero == heroID
				surface.SetDrawColor(isSelected and palette.selected or Color(20, 20, 20, 210))
				surface.DrawRect(0, 0, bw, bh)
				surface.SetDrawColor(isSelected and orange or Color(255, 255, 255, 80))
				surface.DrawOutlinedRect(0, 0, bw, bh, isSelected and 2 or 1)

				local skullMat = heroSkullMats[LocalPlayer():Team()] or heroSkullMats[0]
				if skullMat and skullMat ~= false then
					surface.SetMaterial(skullMat)
					surface.SetDrawColor(255, 255, 255, isSelected and 255 or 160)
					surface.DrawTexturedRect(8, 8, bh - 16, bh - 16)
				end

				DrawFittedText(hero.name, fitLargeFonts, bh, bh * 0.4, yellow, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, bw - bh - 12, bh * 0.45)
				local sub = ""
				if hero.teamHighlight then sub = "Giant • Team glow" end
				if hero.meleeMult and hero.meleeMult > 1 then sub = sub .. (sub ~= "" and " • " or "") .. "Melee x" .. hero.meleeMult end
				if hero.speedMult and hero.speedMult > 1 then sub = sub .. (sub ~= "" and " • " or "") .. "Speed x" .. hero.speedMult end
				if sub == "" then sub = "WIP!!!" end
				DrawFittedText(sub, fitMediumFonts, bh, bh * 0.72, palette.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, bw - bh - 12, bh * 0.35)
			end
		end

		return
	end

	if customize then
		local slotPanel = vgui.Create("DPanel", frame)
		local itemsPanel = vgui.Create("DScrollPanel", frame)
		local detailPanel = vgui.Create("DPanel", frame)
		local back = vgui.Create("DButton", frame)

		back:SetPos(18, h - 52)
		back:SetSize(104, 40)
		back:SetText("")
		back.DoClick = function()
			CloseMenu()
			OpenMenu(true, attachmentPage, false)
			surface.PlaySound("buttons/button14.wav")
		end
		back.Paint = function(self, bw, bh)
			surface.SetDrawColor(palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, 80)
			surface.DrawOutlinedRect(0, 0, bw, bh, 2)
			DrawAutoText("Back", "RealishMediumLarge", bw * 0.5, bh * 0.5, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, bh - 8)
		end

		slotPanel:SetPos(leftX, topY)
		slotPanel:SetSize(leftW, panelH)
		slotPanel.Paint = function(self, bw, bh) end

		itemsPanel:SetPos(midX, topY)
		itemsPanel:SetSize(midW, panelH)
		itemsPanel.Paint = function(self, bw, bh)
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			draw.SimpleText(attachmentPage and "Attachments" or (selectedSlot or "") .. " weapons", "RealishMedium", bw * 0.5, 18, teal, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		detailPanel:SetPos(rightX, topY)
		detailPanel:SetSize(rightW, panelH)
		detailPanel.Paint = function(self, bw, bh)
			local option = GetSelectedOption(selectedLoadout, selectedSlot)
			surface.SetDrawColor(0, 0, 0, 185)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			if not option then return end
			DrawFittedText(option.name, fitLargeFonts, bw * 0.5, 28, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 16)
			PaintWeaponIcon(option, bw * 0.18, 66, bw * 0.64, bh * 0.30, 235)

			local descY = bh * 0.43
			for i, line in ipairs(GetDescriptionLines(option, "RealishMedium", bw * 0.84)) do
				if i > 5 then break end
				draw.SimpleText(line, "RealishMedium", bw * 0.08, descY + (i - 1) * 18, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
			end

			local lines = GetStatLines(option)
			for i, stat in ipairs(lines) do
				local x = bw * 0.08
				local y = bh * 0.61 + (i - 1) * 24
				draw.SimpleText(stat[1] .. ": " .. stat[2], "RealishMedium", x, y, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			end

			draw.SimpleText(attachmentPage and "LMB to toggle attachments" or HasAttachments(option) and "RMB to add attachments" or "No attachments available", "RealishMedium", bw * 0.5, bh - 34, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		rebuildSlots = function()
			for _, child in ipairs(slotPanel:GetChildren()) do child:Remove() end
			local cardW = (leftW - 14) * 0.5
			local slots = {}
			for _, slot in ipairs(RealishLoadoutSlots or {}) do
				if GetOptions(selectedLoadout, slot.id) then slots[#slots + 1] = slot end
			end
			local rows = math.max(1, math.ceil(#slots * 0.5))
			local cardH = math.min((panelH - (rows - 1) * 18) / rows, 150)

			for i, slot in ipairs(slots) do
				local option = GetSelectedOption(selectedLoadout, slot.id)
				local x = ((i - 1) % 2) * (cardW + 14)
				local y = math.floor((i - 1) / 2) * (cardH + 18)
				local button = vgui.Create("DButton", slotPanel)
				button:SetPos(x, y)
				button:SetSize(cardW, cardH)
				button:SetText("")
				button.DoClick = function()
					selectedSlot = slot.id
					attachmentPage = false
					rebuildSlots()
					rebuildItems()
					surface.PlaySound("buttons/button14.wav")
				end
				button.Paint = function(self, bw, bh)
					local selected = selectedSlot == slot.id
					surface.SetDrawColor(selected and palette.selected or Color(0, 0, 0, 185))
					surface.DrawRect(0, 0, bw, bh)
					surface.SetDrawColor(selected and orange or palette.accent)
					surface.DrawOutlinedRect(0, 0, bw, bh, selected and 2 or 1)
					DrawFittedText(slot.name .. ": " .. (option and option.name or "None"), fitMediumFonts, 8, 16, white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, bw - 16, bh * 0.2)
					if option then PaintWeaponIcon(option, bw * 0.18, 34, bw * 0.64, bh - 54, 235) end
					if selected or HasAttachments(option) then
						surface.SetDrawColor(orange)
						draw.NoTexture()
						surface.DrawPoly({{x = bw - 28, y = bh - 8}, {x = bw - 8, y = bh - 8}, {x = bw - 8, y = bh - 34}})
					end
				end
			end
		end

		rebuildItems = function()
			local canvas = itemsPanel.GetCanvas and itemsPanel:GetCanvas() or itemsPanel.pnlCanvas
			if not IsValid(canvas) then return end
			for _, child in ipairs(canvas:GetChildren()) do child:Remove() end
			local margin = 12
			local columns = math.max(1, math.floor((midW - margin) / 100))
			local cell = math.floor((midW - margin * (columns + 1)) / columns)
			local yOffset = 44
			local option = GetSelectedOption(selectedLoadout, selectedSlot)

			if attachmentPage and option then
				local grouped = {}
				for _, att in ipairs(option.attachments or {}) do
					local category = GetAttachmentCategory(att)
					grouped[category] = grouped[category] or {}
					grouped[category][#grouped[category] + 1] = att
				end

				local yPos = yOffset

				for _, category in ipairs(attCategoryOrder) do
					local list = grouped[category]
					if list then
						local header = vgui.Create("DButton", canvas)
						header:SetPos(margin, yPos)
						header:SetSize(midW - margin * 2, 22)
						header:SetText("")
						header.DoClick = function() end
						header.Paint = function(self, bw, bh)
							surface.SetDrawColor(0, 0, 0, 230)
							surface.DrawRect(0, 0, bw, bh)
							surface.SetDrawColor(palette.accent)
							surface.DrawOutlinedRect(0, 0, bw, bh, 1)
							draw.SimpleText(attCategoryLabels[category] or category, "RealishMedium", 6, bh * 0.5, category == "other" and locked or teal, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
						end
						yPos = yPos + 28

						for i, att in ipairs(list) do
							local x = margin + ((i - 1) % columns) * (cell + margin)
							local y = yPos + math.floor((i - 1) / columns) * (cell + margin)
							local button = vgui.Create("DButton", canvas)
							button:SetPos(x, y)
							button:SetSize(cell, cell)
							button:SetText("")
							button.DoClick = function()
								ToggleAttachment(selectedLoadout, selectedSlot, att)
								SendLoadout(selectedLoadout, selectedArmor)
								rebuildItems()
								surface.PlaySound("buttons/button14.wav")
							end
							button.Paint = function(self, bw, bh)
								local selected = HasSelectedAttachment(selectedLoadout, selectedSlot, att)
								local icon = GetAttachmentIcon(att)
								surface.SetDrawColor(selected and Color(45, 115, 95, 230) or Color(20, 20, 20, 210))
								surface.DrawRect(0, 0, bw, bh)
								surface.SetDrawColor(selected and orange or Color(255, 255, 255, 80))
								surface.DrawOutlinedRect(0, 0, bw, bh, selected and 2 or 1)
								if icon then
									surface.SetMaterial(icon)
									surface.SetDrawColor(255, 255, 255, 235)
									surface.DrawTexturedRect(bw * 0.18, bh * 0.14, bw * 0.64, bh * 0.52)
								end
								DrawFittedText((hg.attachmentslaunguage and hg.attachmentslaunguage[att]) or att, fitSmallFonts, bw * 0.5, bh - 14, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 8, bh * 0.35)
							end
						end
						yPos = yPos + math.ceil(#list / columns) * (cell + margin)
					end
				end
				return
			end

			for i, item in ipairs(GetOptions(selectedLoadout, selectedSlot) or {}) do
				local x = margin + ((i - 1) % columns) * (cell + margin)
				local y = yOffset + math.floor((i - 1) / columns) * (cell + margin)
				local taken = IsWeaponTaken(selectedLoadout, selectedSlot, item.class)
				local button = vgui.Create("DButton", canvas)
				button:SetPos(x, y)
				button:SetSize(cell, cell)
				button:SetText("")
				button.DoClick = function(self)
					if taken then
						surface.PlaySound("ui/rem_selectbad.wav")
						return
					end

					local mx, my = self:LocalCursorPos()
					if HasAttachments(item) and mx >= cell - 34 and my >= cell - 40 then
						SelectWeapon(selectedLoadout, selectedSlot, item.class)
						attachmentPage = true
						rebuildSlots()
						rebuildItems()
						surface.PlaySound("buttons/button14.wav")
						return
					end

					SelectWeapon(selectedLoadout, selectedSlot, item.class)
					SendLoadout(selectedLoadout, selectedArmor)
					rebuildSlots()
					rebuildItems()
					surface.PlaySound("buttons/button14.wav")
				end
				button.DoRightClick = function()
					if taken or not HasAttachments(item) then return end
					SelectWeapon(selectedLoadout, selectedSlot, item.class)
					attachmentPage = true
					rebuildSlots()
					rebuildItems()
					surface.PlaySound("buttons/button14.wav")
				end
				button.Paint = function(self, bw, bh)
					local selected = GetSelectedClass(selectedLoadout, selectedSlot) == item.class
					surface.SetDrawColor(selected and Color(45, 115, 95, 230) or Color(20, 20, 20, 210))
					surface.DrawRect(0, 0, bw, bh)
					surface.SetDrawColor(selected and orange or Color(255, 255, 255, 80))
					surface.DrawOutlinedRect(0, 0, bw, bh, selected and 2 or 1)
					PaintWeaponIcon(item, bw * 0.12, bh * 0.16, bw * 0.76, bh * 0.56, 235)
					DrawFittedText(item.name, fitSmallFonts, bw * 0.5, bh - 14, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 8, bh * 0.35)
					if HasAttachments(item) then
						surface.SetDrawColor(orange)
						draw.NoTexture()
						surface.DrawPoly({{x = bw - 28, y = bh - 8}, {x = bw - 8, y = bh - 8}, {x = bw - 8, y = bh - 34}})
					end
					if taken then
						surface.SetDrawColor(0, 0, 0, 140)
						surface.DrawRect(0, 0, bw, bh)
					end
				end
			end
		end

		rebuildSlots()
		rebuildItems()
	end

	for i, className in ipairs(RealishClassOrder or {}) do
		AddChoice(frame, classStartX + (buttonW + gap) * (i - 1), classY, buttonW, 36, className, function() return selectedLoadout end, function()
			selectedLoadout = className
			EnsureLoadout(selectedLoadout)
			EnsureSelectedSlot(selectedLoadout)
			attachmentPage = false
			SendLoadout(selectedLoadout, selectedArmor)
			if rebuildSlots then rebuildSlots() end
			if rebuildItems then rebuildItems() end
			surface.PlaySound("buttons/button14.wav")
		end, nil, nil, palette, function()
			selectedLoadout = className
			EnsureLoadout(selectedLoadout)
			EnsureSelectedSlot(selectedLoadout)
			CloseMenu()
			OpenMenu(true, true, false)
			surface.PlaySound("buttons/button14.wav")
		end)
	end

	local armorW = 68
	local armorX = w * 0.62

	if not customize then
		local heroBoxSize = 76
		local heroBoxX = w * 0.006
		local heroBoxY = h - heroBoxSize - 18

		local heroCountdown = vgui.Create("DPanel", frame)
		heroCountdown:SetPos(heroBoxX, heroBoxY - 30)
		heroCountdown:SetSize(heroBoxSize, 26)
		heroCountdown.Paint = function(self, pw, ph)
			local teamID = LocalPlayer():Team()
			local deadline = LocalPlayer():GetNWFloat("Realish_HeroDeadline", 0)
			local hasOffer = deadline > CurTime() and LocalPlayer():GetNWInt("Realish_HeroTeam", -1) == teamID
			if not hasOffer then return end
			local remaining = math.max(0, math.ceil(deadline - CurTime()))
			DrawAutoText(tostring(remaining), "RealishMedium", pw * 0.5, ph * 0.5, Color(255, 90, 90, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, pw - 4, ph - 2)
		end

		local heroBtn = vgui.Create("DButton", frame)
		heroBtn:SetPos(heroBoxX, heroBoxY)
		heroBtn:SetSize(heroBoxSize, heroBoxSize)
		heroBtn:SetText("")
		heroBtn.Paint = function(self, bw, bh)
			local teamID = LocalPlayer():Team()
			local skullMat = heroSkullMats[teamID] or heroSkullMats[0]
			local deadline = LocalPlayer():GetNWFloat("Realish_HeroDeadline", 0)
			local hasOffer = deadline > CurTime() and LocalPlayer():GetNWInt("Realish_HeroTeam", -1) == teamID

			surface.SetDrawColor(palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, hasOffer and 120 or 60)
			surface.DrawOutlinedRect(0, 0, bw, bh, 2)

			if skullMat and skullMat ~= false then
				surface.SetMaterial(skullMat)
				local skullAlpha = hasOffer and 255 or 130
				surface.SetDrawColor(255, 255, 255, skullAlpha)
				surface.DrawTexturedRect(8, 8, bw - 16, bh - 16)
			end
		end
		heroBtn.DoClick = function()
			if not CanDeploy() then
				surface.PlaySound("buttons/button10.wav")
				return
			end

			local teamID = LocalPlayer():Team()
			local deadline = LocalPlayer():GetNWFloat("Realish_HeroDeadline", 0)
			local hasOffer = deadline > CurTime() and LocalPlayer():GetNWInt("Realish_HeroTeam", -1) == teamID

			if not hasOffer then
				deployFlashRed = CurTime() + 1
				surface.PlaySound("ui/rem_selectbad.wav")
				return
			end

			deployUntil = CurTime() + 2
			net.Start("realish_hero_choice")
				net.WriteString(selectedHero or "Strike")
			net.SendToServer()
			net.Start("realish_hero_spawn")
			net.SendToServer()
		end
		heroBtn.DoRightClick = function()
			selectedHero = LocalPlayer():GetNWString("Realish_HeroChoice", "Strike")
			if not RealishHeroes[selectedHero] then selectedHero = RealishHeroOrder and RealishHeroOrder[1] or "Strike" end
			CloseMenu()
			OpenMenu(true, false, false, true)
			surface.PlaySound("buttons/button14.wav")
		end

		local streakBoxSize = 56
		local streakBtn = vgui.Create("DButton", frame)
		streakBtn:SetPos(w * 0.5 - 86 - 14 - streakBoxSize, h - 60)
		streakBtn:SetSize(streakBoxSize, streakBoxSize)
		streakBtn:SetText("")
		streakBtn.Paint = function(self, bw, bh)
			local hasPicks = #selectedKillstreaks > 0

			surface.SetDrawColor(palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, hasPicks and 120 or 60)
			surface.DrawOutlinedRect(0, 0, bw, bh, 2)

			DrawKillstreakIcon(8, 8, bw - 16, bh - 16, hasPicks and 255 or 150)

			DrawAutoText(#selectedKillstreaks .. "/" .. GetKillstreakMaxPicks(), "RealishMicro", bw * 0.5, bh - 8, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 60, 14)
		end
		streakBtn.DoClick = function()
			CloseMenu()
			OpenMenu(true, false, false, false, true)
			surface.PlaySound("buttons/button14.wav")
		end
		streakBtn.DoRightClick = streakBtn.DoClick
	end
	AddChoice(frame, armorX, h - 50, armorW, 34, "None", function() return selectedArmor end, function()
		selectedArmor = "None"
		SendLoadout(selectedLoadout, selectedArmor)
		surface.PlaySound("buttons/button14.wav")
		end, nil, "RealishMedium", palette)

	AddChoice(frame, armorX + 78, h - 50, armorW, 34, "Light", function() return selectedArmor end, function()
		selectedArmor = "Light"
		SendLoadout(selectedLoadout, selectedArmor)
		surface.PlaySound("buttons/button14.wav")
		end, nil, "RealishMedium", palette)

	AddChoice(frame, armorX + 156, h - 50, armorW, 34, "Heavy", function() return selectedArmor end, function()
		selectedArmor = "Heavy"
		SendLoadout(selectedLoadout, selectedArmor)
		surface.PlaySound("buttons/button14.wav")
		end, nil, "RealishMedium", palette)

	local spawn = vgui.Create("DButton", frame)
	spawn:SetPos(w * 0.5 - 86, h - 52)
	spawn:SetSize(172, 40)
	spawn:SetText("")
	spawn.Paint = function(self, bw, bh)
		local canDeploy = CanDeploy()
		local deployTime = GetGlobalFloat("Realish_DeployTime", 0)
		local text = "Deploy"

		if zb.ROUND_STATE ~= 1 then
			text = "Waiting"
		elseif not canDeploy then
			text = "Deploy in " .. math.ceil(deployTime - CurTime())
		end

		local flashAmt = math.max(0, deployFlashRed - CurTime())
		local baseR = canDeploy and palette.deploy or locked
		local bg = Color(
			baseR.r + (255 - baseR.r) * flashAmt,
			baseR.g + (40 - baseR.g) * flashAmt,
			baseR.b + (40 - baseR.b) * flashAmt,
			baseR.a
		)
		surface.SetDrawColor(bg)
		surface.DrawRect(0, 0, bw, bh)
		surface.SetDrawColor(255, 255, 255, 80)
		surface.DrawOutlinedRect(0, 0, bw, bh, 2)
		DrawAutoText(text, "RealishMediumLarge", bw * 0.5, bh * 0.5, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 12, bh - 8)
	end
	spawn.DoClick = function()
		if not CanDeploy() then
			surface.PlaySound("buttons/button10.wav")
			return
		end

		local cost = GetArmorCost(selectedArmor)
		local coins = LocalPlayer():GetNWInt("Realish_Coins", 0)
		if cost > 0 and coins < cost then
			deployFlashRed = CurTime() + 1
			surface.PlaySound("ui/rem_selectbad.wav")
			return
		end

		deployUntil = CurTime() + 2
		SendLoadout(selectedLoadout, selectedArmor)
		net.Start("realish_request_spawn")
		net.SendToServer()
	end

	local speakerBtn = vgui.Create("DButton", frame)
	speakerBtn:SetPos(12, 8)
	speakerBtn:SetSize(40, 40)
	speakerBtn:SetText("")
	speakerBtn.Paint = function(self, bw, bh)
		surface.SetDrawColor(palette.panel)
		surface.DrawRect(0, 0, bw, bh)
		surface.SetDrawColor(255, 255, 255, 80)
		surface.DrawOutlinedRect(0, 0, bw, bh, 1)
		local iconMat = (musicMuted or musicVolume <= 0) and muteIconMat or speakerIconMat
		if iconMat then
			surface.SetMaterial(iconMat)
			surface.SetDrawColor(255, 255, 255, 235)
			surface.DrawTexturedRect(8, 8, bw - 16, bh - 16)
		end
	end

	local speakerPopup
	speakerBtn.DoClick = function()
		if IsValid(speakerPopup) then
			speakerPopup:Remove()
			speakerPopup = nil
			surface.PlaySound("buttons/button14.wav")
			return
		end

		speakerPopup = vgui.Create("DPanel", frame)
		speakerPopup:SetSize(220, 98)
		speakerPopup:SetPos(12, 54)
		speakerPopup.Paint = function(self, pw, ph)
			surface.SetDrawColor(0, 0, 0, 235)
			surface.DrawRect(0, 0, pw, ph)
			surface.SetDrawColor(palette.accent)
			surface.DrawOutlinedRect(0, 0, pw, ph, 1)
			local pct = math.floor(GetMusicVolume() * 100 + 0.5)
			DrawAutoText("Music Volume: " .. pct .. "%", "RealishMedium", pw * 0.5, 10, yellow, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, pw - 12, 20)
		end

		local slider = vgui.Create("DPanel", speakerPopup)
		slider:SetPos(14, 34)
		slider:SetSize(192, 20)
		local sliderDragging = false
		local function sliderUpdate()
			local mx = slider:LocalCursorPos()
			SetMusicVolume(mx / slider:GetWide())
		end
		slider.OnMousePressed = function(self, mc)
			if mc ~= MOUSE_LEFT then return end
			sliderDragging = true
			sliderUpdate()
			self:MouseCapture(true)
		end
		slider.OnMouseReleased = function(self, mc)
			if mc ~= MOUSE_LEFT then return end
			sliderDragging = false
			self:MouseCapture(false)
		end
		slider.Think = function(self)
			if sliderDragging then sliderUpdate() end
		end
		slider.Paint = function(self, pw, ph)
			surface.SetDrawColor(0, 0, 0, 220)
			surface.DrawRect(0, ph * 0.5 - 3, pw, 6)
			local fillW = pw * musicVolume
			surface.SetDrawColor(palette.accent)
			surface.DrawRect(0, ph * 0.5 - 3, fillW, 6)
			surface.SetDrawColor(255, 255, 255, 245)
			surface.DrawRect(math.Clamp(fillW - 5, 0, pw - 10), 0, 10, ph)
		end

		local muteBtn = vgui.Create("DButton", speakerPopup)
		muteBtn:SetPos(14, 64)
		muteBtn:SetSize(192, 24)
		muteBtn:SetText("")
		muteBtn.Paint = function(self, bw, bh)
			surface.SetDrawColor(musicMuted and Color(140, 40, 40, 240) or palette.panel)
			surface.DrawRect(0, 0, bw, bh)
			surface.SetDrawColor(255, 255, 255, 60)
			surface.DrawOutlinedRect(0, 0, bw, bh, 1)
			DrawAutoText(musicMuted and "Muted (click to unmute)" or "Mute", "RealishMedium", bw * 0.5, bh * 0.5, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, bw - 8, bh - 4)
		end
		muteBtn.DoClick = function()
			ToggleMute()
			surface.PlaySound("buttons/button14.wav")
		end

		surface.PlaySound("buttons/button14.wav")
	end

	frame.OnKeyCodePressed = function(self, key)
		if key == KEY_BACKSPACE and customize and attachmentPage then
			CloseMenu()
			OpenMenu(true, true, false)
			return
		end

		if key == KEY_BACKSPACE and customize then
			CloseMenu()
			OpenMenu(true, false, false)
			return
		end

		if key == KEY_ENTER then
			SendLoadout(selectedLoadout, selectedArmor)
			surface.PlaySound("buttons/button14.wav")
		end
	end
end

local reviveIconMat = Material("vgui/reviveme.png", "smooth mips")
local deadIconMat = Material("vgui/dead.png", "smooth mips")
local reviveIconRange = 900
local reviveIconFadeStart = 250
local reviveDeathStateDuration = 25
local spawnOrbMat = Material("hmcd_dmzone")
local spawnOrbRadius = 54

local heroNotifStart = -math.huge
local heroNotifDeadline = 0
local heroNotifTeam = -1
local heroNotifShakeAngles = {}
local heroNotifSound = nil
local heroNotifFlashStart = -math.huge
local heroLivesAnimFrom = 3
local heroLivesAnimTo = 2
local heroLivesAnimStart = -math.huge
local heroLivesAnimDur = 2.2
local heroLivesAnimSoundPlayed = false

surface.CreateFont("RealishHeroCount", {
	font = realishFont,
	size = ScreenScale(28),
	weight = 700,
	antialias = true
})

surface.CreateFont("RealishHeroLabel", {
	font = realishFont,
	size = ScreenScale(20),
	weight = 700,
	antialias = true
})

surface.CreateFont("RealishHeroLives", {
	font = realishFont,
	size = ScreenScale(32),
	weight = 800,
	antialias = true
})

local function StartHeroNotifShake()
	heroNotifShakeAngles = {}
	for i = 1, 128 do
		heroNotifShakeAngles[i] = math.Rand(-24, 24)
	end
end

local function StartHeroNotif(teamID, deadline)
	heroNotifStart = CurTime()
	heroNotifDeadline = deadline
	heroNotifTeam = teamID
	heroNotifFlashStart = CurTime()
	StartHeroNotifShake()

	if heroNotifSound then
		heroNotifSound:Stop()
		heroNotifSound = nil
	end

	local ply = LocalPlayer()
	if IsValid(ply) then
		heroNotifSound = CreateSound(ply, "realishgamemode/rem_heroawakens.mp3")
		if heroNotifSound then
			heroNotifSound:PlayEx(1, 100)
		end
	end
end

local function StopHeroNotif()
	heroNotifStart = -math.huge
	heroNotifDeadline = 0
	heroNotifTeam = -1
	heroNotifFlashStart = -math.huge
	if heroNotifSound then
		heroNotifSound:Stop()
		heroNotifSound = nil
	end
end

local function DrawHeroLivesAnim(sw, sh)
	if heroLivesAnimStart == -math.huge then return end
	local t = CurTime() - heroLivesAnimStart
	if t < 0 or t > heroLivesAnimDur then
		if t > heroLivesAnimDur then heroLivesAnimStart = -math.huge end
		return
	end
	local p = t / heroLivesAnimDur
	if p >= 0.5 and not heroLivesAnimSoundPlayed then
		heroLivesAnimSoundPlayed = true
		surface.PlaySound("rem_newroundreveal.wav")
	end
	local fadeOutStart = 0.85
	local blackAlpha = 255
	if p > fadeOutStart then blackAlpha = 255 * (1 - (p - fadeOutStart) / (1 - fadeOutStart)) end
	surface.SetDrawColor(0, 0, 0, blackAlpha)
	surface.DrawRect(0, 0, sw, sh)
	local displayLives = p < 0.5 and heroLivesAnimFrom or heroLivesAnimTo
	local text = "Lives: " .. displayLives
	local colR = 255
	local colG = math.floor(255 * (1 - p) + 40 * p)
	local colB = math.floor(255 * (1 - p) + 40 * p)
	local textFadeStart = 0.6
	local textAlpha = 255
	if p > textFadeStart then textAlpha = 255 * (1 - (p - textFadeStart) / (1 - textFadeStart)) end
	textAlpha = math.Clamp(textAlpha, 0, 255)
	local cx = sw * 0.5
	local cy = sh * 0.5
	draw.SimpleText(text, "RealishHeroLives", cx, cy, Color(colR, colG, colB, textAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function DrawHeroFlash(sw, sh)
	local flashT = CurTime() - heroNotifFlashStart
	local flashDur = 1.1
	if heroNotifFlashStart < 0 or flashT >= flashDur then return end

	local p = flashT / flashDur
	local alpha = (1 - p) * (1 - p) * 190
	if alpha <= 1 then return end

	local col = (heroNotifTeam == 1) and Color(20, 80, 220, alpha) or Color(200, 20, 20, alpha)
	surface.SetDrawColor(col)
	surface.DrawRect(0, 0, sw, sh)
end

local function DrawHeroNotification(sw, sh)
	local deadline = LocalPlayer():GetNWFloat("Realish_HeroDeadline", 0)
	if deadline <= 0 then
		if heroNotifDeadline ~= 0 then StopHeroNotif() end
		return
	end

	if CurTime() >= deadline then
		if heroNotifDeadline ~= 0 then StopHeroNotif() end
		return
	end

	if deadline ~= heroNotifDeadline then
		local teamID = LocalPlayer():GetNWInt("Realish_HeroTeam", -1)
		StartHeroNotif(teamID, deadline)
	end

	local remaining = math.max(0, deadline - CurTime())
	local wholeSecs = math.ceil(remaining)
	local t = CurTime() - heroNotifStart

	local skullMat = heroSkullMats[heroNotifTeam] or heroSkullMats[0]
	if skullMat == nil or skullMat == false then return end

	local appearDur = 0.55
	local appear = math.Clamp(t / appearDur, 0, 1)
	local appearEase = appear * appear * (3 - 2 * appear)

	local shakeDur = 2.6
	local shakeFade = 1 - math.Clamp(t / shakeDur, 0, 1)
	local shakeFadeEase = shakeFade * shakeFade

	local shakeRoll = math.sin(t * 52) * math.sin(t * 31.7) * 28 * shakeFadeEase
	local shakeX = math.sin(t * 47.3) * math.cos(t * 38.1) * 8 * shakeFadeEase
	local shakeY = math.sin(t * 41.2) * math.cos(t * 55.7) * 8 * shakeFadeEase

	local bob = math.sin(CurTime() * 2.4) * 6

	local skullSize = ScreenScale(46)
	local padX = ScreenScale(8)
	local textW = ScreenScale(120)
	local totalW = skullSize + padX + textW
	local totalH = skullSize

	local anchorX = ScreenScale(14)
	local anchorY = sh * 0.5 + bob

	local alpha = 255 * appearEase

	local skullCX = anchorX + shakeX + skullSize * 0.5
	local skullCY = anchorY + shakeY + skullSize * 0.5

	if skullMat then
		surface.SetMaterial(skullMat)
		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawTexturedRectRotated(skullCX, skullCY, skullSize, skullSize, shakeRoll)
	end

	local textX = anchorX + skullSize + padX + shakeX
	local textY = anchorY + totalH * 0.5 + shakeY

	local textMat = Matrix()
	textMat:Translate(Vector(textX, textY, 0))
	textMat:Rotate(Angle(0, 0, shakeRoll))
	textMat:Translate(Vector(-textX, -textY, 0))
	cam.PushModelMatrix(textMat)
		draw.SimpleText("HERO - " .. tostring(wholeSecs), "RealishHeroLabel", textX, textY, Color(255, 245, 245, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	cam.PopModelMatrix()
end

local function IsIncapacitatedRag(rag, ply)
	if not IsValid(rag) then return false end
	local org = rag.new_organism or (IsValid(ply) and ply.new_organism)
	if not org then return false end
	if org.otrub == nil or org.incapacitated == nil then return false end
	return org.otrub and org.incapacitated
end

function MODE:PostDrawTranslucentRenderables(bDepth, bSkybox, isDraw3DSkybox)
	if bSkybox or isDraw3DSkybox then return end
	if zb.CROUND ~= "realish" then return end
	if reviveIconMat == false or reviveIconMat == nil then return end

	local lply = LocalPlayer()
	if not IsValid(lply) then return end

	local eyePos = lply:EyePos()
	local ct = CurTime()
	local lplyTeam = lply:Team()

	for _, ply in player.Iterator() do
		if not IsValid(ply) or ply == lply or not ply:Alive() then continue end
		if ply:Team() ~= lplyTeam then continue end
		if ply:Team() ~= 0 and ply:Team() ~= 1 then continue end

		local rag = ply:GetNWEntity("FakeRagdoll")
		if not IsValid(rag) then continue end
		if not IsIncapacitatedRag(rag, ply) then continue end
		if IsValid(rag.DefibModelEnt) or rag.DefibInProgress then continue end

		local ragPos = rag:WorldSpaceCenter()
		if not ragPos then ragPos = rag:GetPos() end
		local dist = eyePos:DistToSqr(ragPos)
		if dist > reviveIconRange * reviveIconRange then continue end

		local distFlat = math.sqrt(dist)

		local headBone = rag:LookupBone("ValveBiped.Bip01_Head1")
		local bonePos
		if headBone then
			local matrix = rag:GetBoneMatrix(headBone)
			if matrix then bonePos = matrix:GetTranslation() end
		end
		if not bonePos then bonePos = ragPos end

		local pos = bonePos + Vector(0, 0, 34)

		local pulse = 1 + math.sin(ct * 4) * 0.06
		local scale = 0.24 * pulse

		local ang = (pos - eyePos):Angle()
		ang = Angle(0, ang.y, 0)
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 90)

		local alpha = math.Clamp(1 - (distFlat - reviveIconFadeStart) / (reviveIconRange - reviveIconFadeStart), 0, 1)
		if alpha <= 0 then continue end

		local revivedAlready = ply:GetNWBool("Realish_RevivedAlready", false)
		local iconMat = revivedAlready and (deadIconMat ~= false and deadIconMat) or (reviveIconMat ~= false and reviveIconMat)
		if not iconMat then continue end

		local org = rag.new_organism or ply.new_organism
		local deathStateEnd = org and org.deathStateEnd or 0
		local drawR, drawG, drawB = 255, 90, 90
		if deathStateEnd and deathStateEnd > 0 then
			local remaining = math.max(deathStateEnd - ct, 0)
			local progress = math.Clamp(1 - remaining / reviveDeathStateDuration, 0, 1)
			progress = progress * progress * (3 - 2 * progress)
			drawR = 255 - (255 - 130) * progress
			drawG = 90 - 90 * progress
			drawB = 90 - 90 * progress
		end

		cam.Start3D2D(pos, ang, scale)
			surface.SetMaterial(iconMat)
			surface.SetDrawColor(drawR, drawG, drawB, 255 * alpha)
			surface.DrawTexturedRect(-48, -48, 96, 96)
		cam.End3D2D()
	end
	for _, ply in player.Iterator() do
		if not IsValid(ply) or not ply:Alive() then continue end
		local protectUntil = ply:GetNWFloat("RealishSpawnProtectUntil", 0)
		local remaining = protectUntil - ct
		if remaining <= 0 then continue end
		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		if not IsValid(ent) then continue end
		local pos = ent:WorldSpaceCenter()
		if not pos then continue end
		local frac = math.Clamp(remaining / 5, 0, 1)
		local eased = frac * frac
		render.SetMaterial(spawnOrbMat)
		render.SetColorModulation(1, 0.15, 0.15)
		render.SetBlend(0.45 * eased)
		render.DrawSphere(pos, spawnOrbRadius, 30, 30, color_white)
		render.SetBlend(1)
		render.SetColorModulation(1, 1, 1)
	end
	for _, ply in player.Iterator() do
		if not IsValid(ply) then continue end
		if not ply:GetNWBool("Realish_IsHero", false) then continue end
		if ply == lply then continue end
		if ply:Team() ~= 0 and ply:Team() ~= 1 then continue end
		local isAlive = ply:Alive()
		local ent = nil
		if isAlive then
			ent = ply
		else
			ent = ply:GetNWEntity("FakeRagdoll")
			if not IsValid(ent) and IsValid(ply.FakeRagdoll) then ent = ply.FakeRagdoll end
			if not IsValid(ent) then continue end
		end
		local center = ent:WorldSpaceCenter()
		if not center then center = ent:GetPos() end
		local dist = eyePos:DistToSqr(center)
		if dist > reviveIconRange * reviveIconRange then continue end
		local distFlat = math.sqrt(dist)
		local bonePos
		local headBone = ent:LookupBone("ValveBiped.Bip01_Head1")
		if headBone then
			local matrix = ent:GetBoneMatrix(headBone)
			if matrix then bonePos = matrix:GetTranslation() end
		end
		if not bonePos then bonePos = center end
		local pos = bonePos + Vector(0, 0, 34)
		local pulse = 1 + math.sin(ct * 4) * 0.06
		local scale = 0.24 * pulse
		local ang = (pos - eyePos):Angle()
		ang = Angle(0, ang.y, 0)
		ang:RotateAroundAxis(ang:Up(), -90)
		ang:RotateAroundAxis(ang:Forward(), 90)
		local alpha = math.Clamp(1 - (distFlat - reviveIconFadeStart) / (reviveIconRange - reviveIconFadeStart), 0, 1)
		if alpha <= 0 then continue end
		local teamID = ply:Team()
		local skullMat = heroSkullMats[teamID] or heroSkullMats[0]
		if not skullMat or skullMat == false then continue end
		cam.Start3D2D(pos, ang, scale)
			surface.SetMaterial(skullMat)
			surface.SetDrawColor(255, 255, 255, 255 * alpha)
			surface.DrawTexturedRect(-48, -48, 96, 96)
		cam.End3D2D()
	end
end

local streakBoxX = nil
local streakKillsPrev = 0
local streakClaimedPrev = nil
local streakBoxVisibleUntil = 0

local function DrawKillstreakHUD(alpha)
	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	local ct = CurTime()
	local kills = ply:GetNWInt("Realish_Killstreak", 0)

	if kills > streakKillsPrev then
		streakBoxVisibleUntil = math.max(streakBoxVisibleUntil, ct + 4)
	end
	streakKillsPrev = kills

	local picks = {}
	for _, id in ipairs(selectedKillstreaks) do
		if RealishKillstreaks and RealishKillstreaks[id] then picks[#picks + 1] = id end
	end

	local claimed = GetClaimedKillstreaks()
	if claimedCacheStr ~= streakClaimedPrev then
		streakClaimedPrev = claimedCacheStr
		if #picks > 0 then streakBoxVisibleUntil = math.max(streakBoxVisibleUntil, ct + 4) end
	end

	local boxW = 60
	local boxGap = 8
	local barW = 10
	local pad = 10
	local panelW = pad * 3 + barW + boxW
	local panelH = #picks > 0 and (pad * 2 + #picks * boxW + (#picks - 1) * boxGap) or 0
	local visibleX = ScrW() - panelW - 20
	local hiddenX = ScrW() + 10
	local panelY = ScrH() * 0.5 - panelH * 0.5

	if streakBoxX == nil then streakBoxX = hiddenX end
	streakBoxX = math.Approach(streakBoxX, (#picks > 0 and ct < streakBoxVisibleUntil) and visibleX or hiddenX, FrameTime() * 600)

	hudDark.a = alpha
	draw.SimpleTextOutlined(tostring(kills), "RealishMediumLarge", math.min(streakBoxX - 10, ScrW() - 10), panelY + panelH * 0.5, yellow, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, hudDark)

	if #picks == 0 or streakBoxX >= ScrW() then return end

	surface.SetDrawColor(8, 8, 10, alpha * 0.82)
	surface.DrawRect(streakBoxX, panelY, panelW, panelH)
	surface.SetDrawColor(255, 255, 255, alpha * 0.08)
	surface.DrawOutlinedRect(streakBoxX, panelY, panelW, panelH, 1)

	local nextTarget = GetNextKillstreakTarget()
	local barX = streakBoxX + pad
	local barY = panelY + pad
	local barH = panelH - pad * 2

	surface.SetDrawColor(0, 0, 0, alpha * 0.6)
	surface.DrawRect(barX, barY, barW, barH)

	local frac = nextTarget and math.Clamp(kills / nextTarget, 0, 1) or 1
	local fillH = math.floor(barH * frac)
	if fillH > 0 then
		surface.SetDrawColor(orange.r, orange.g, orange.b, alpha * 0.9)
		surface.DrawRect(barX, barY + barH - fillH, barW, fillH)
	end

	local boxX = barX + barW + pad

	for i, id in ipairs(picks) do
		local isClaimed = claimed[id] == true
		local data = RealishKillstreaks and RealishKillstreaks[id]
		local icon = GetKillstreakIcon(id) or GetKillstreakBoxMat()
		local by = barY + (i - 1) * (boxW + boxGap)
		local bcx = boxX + boxW * 0.5
		local iconA = math.floor((isClaimed and 255 or 140) * (alpha / 255))

		if icon then
			surface.SetMaterial(icon)
			surface.SetDrawColor(255, 255, 255, iconA)
			surface.DrawTexturedRect(bcx - 16, by + 5, 32, 32)
		end

		surface.SetDrawColor(orange.r, orange.g, orange.b, isClaimed and iconA or math.floor(70 * (alpha / 255)))
		surface.DrawOutlinedRect(boxX, by, boxW, boxW, isClaimed and 2 or 1)

		local label = isClaimed and "DONE" or tostring(math.max(((data and data.kills) or 0) - kills, 0))
		draw.SimpleTextOutlined(label, "RealishMicro", bcx, by + boxW - 12, isClaimed and teal or hudWhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, hudDark)
	end
end

function MODE:HUDPaint()
	local ply = LocalPlayer()
	DrawHeroLivesAnim(ScrW(), ScrH())
	if heroLivesAnimStart ~= -math.huge then return end

	if CurTime() < introEndTime then
		if introSound and CurTime() >= introEndTime - 0.05 then
			StopIntroSound()
		end

		local sw, sh = ScrW(), ScrH()
		local t = CurTime() - introStartTime
		local outFade = math.Clamp((introDuration - t) / 1.5, 0, 1)

		if introSound then
			introSound:ChangeVolume(outFade, 0)
		end

		local bgFade = math.min((introDuration - t) / 2.5, 1)
		surface.SetDrawColor(0, 0, 0, 255 * bgFade)
		surface.DrawRect(0, 0, sw, sh)

		local teamID = IsValid(ply) and ply:Team() or 0
		if teamID ~= 0 and teamID ~= 1 then teamID = 0 end
		local teamInfo = RealishTeams and RealishTeams[teamID] or RealishTeams[0]
		local teamName = teamInfo and teamInfo.name or "ATLAS"
		local teamColor = teamInfo and teamInfo.color or red
		local modeName = MODE.PrintName or "Realish"

		local function ease_out(x)
			return 1 - (1 - x) ^ 3
		end

local tilts = introTextTilts or {}

	local slideInDur = 0.89
	-- Last element (sub) starts at delay 1.4, so all share this trigger once it is fully in.
	local pulseTriggerT = 1.4 + slideInDur

	local function drawElement(text, font, col, x, y, dir, delay, scale, tilt)
		local appear = ease_out(math.Clamp((t - delay) / slideInDur, 0, 1))
		if appear <= 0 then return end

		local a = 255 * appear * outFade
		if a <= 1 then return end

		local slide = 1 - appear
		local dx, dy = 0, 0

		if dir == "left" then
			dx = -slide * ScreenScale(scale)
		elseif dir == "right" then
			dx = slide * ScreenScale(scale)
		elseif dir == "bottom" then
			dy = slide * ScreenScale(scale)
		elseif dir == "top" then
			dy = -slide * ScreenScale(scale)
		end

		local tiltAccum = (tilt or 0) * appear

		DrawPulsingText(text, font, x, y, Color(col.r, col.g, col.b, a), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, appear, dx, dy, tiltAccum, pulseTriggerT)
	end

		drawElement(modeName, "RealishIntroTitle", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 220, tilts[1] or 3)
		drawElement("You are on " .. teamName, "RealishIntroTeam", teamColor, sw * 0.5, sh * 0.5, "right", 0.7, 220, tilts[2] or -3)
		drawElement("Eliminate the enemy team to win!!!!!!!", "RealishIntroSub", Color(255, 255, 255), sw * 0.5, sh * 0.9, "bottom", 1.4, 120, 0)

		return
	end

	if introSound then
		StopIntroSound()
	end

	DrawHeroFlash(ScrW(), ScrH())
	DrawHeroNotification(ScrW(), ScrH())

	local org = IsValid(ply) and (ply.new_organism or ply.organism)
	local targetAlpha = IsValid(ply) and ply:Alive() and not IsValid(menu) and not (org and org.otrub) and 255 or 0
	livesAlpha = math.Approach(livesAlpha, targetAlpha, FrameTime() * 510)
	if livesAlpha <= 1 then return end

	local alpha = math.floor(livesAlpha)
	DrawKillstreakHUD(alpha)
	local w = ScrW()
	local atlas = GetGlobalInt("Realish_ATLAS_Lives", 50)
	local revenant = GetGlobalInt("Realish_REVENANT_Lives", 50)
	local ct = CurTime()
	local ft = FrameTime()

	if atlas < livesAtlasPrev then
		livesAtlasFlash = ct + 1.4
		livesVisibleUntil = math.max(livesVisibleUntil, ct + 3)
	end
	if revenant < livesRevenantPrev then
		livesRevenantFlash = ct + 1.4
		livesVisibleUntil = math.max(livesVisibleUntil, ct + 3)
	end
	livesAtlasPrev = atlas
	livesRevenantPrev = revenant

	local lowLives = atlas < 5 or revenant < 5
	local visible = lowLives or ct < livesVisibleUntil
	local barH = 26
	local livesTargetY = visible and 20 or -(barH + 40)
	livesY = math.Approach(livesY, livesTargetY, ft * 600)

	if not visible and livesY <= livesTargetY + 2 then return end

	local x = 20
	local barW = w - 40
	local halfW = barW * 0.5
	local y = livesY
	local atlasW = halfW * math.Clamp(atlas / 50, 0, 1)
	local revenantW = halfW * math.Clamp(revenant / 50, 0, 1)
	local atlasBarX = x + halfW - atlasW
	local revenantBarX = x + halfW

	surface.SetDrawColor(8, 8, 10, alpha * 0.82)
	surface.DrawRect(x, y, barW, barH)
	surface.SetDrawColor(255, 255, 255, alpha * 0.08)
	surface.DrawOutlinedRect(x, y, barW, barH, 1)

	surface.SetDrawColor(red.r, red.g, red.b, alpha * 0.9)
	surface.DrawRect(atlasBarX, y, atlasW, barH)
	surface.SetTexture(gradientRight)
	surface.SetDrawColor(255, 255, 255, alpha * 0.18)
	surface.DrawTexturedRect(atlasBarX, y, atlasW, barH)

	surface.SetDrawColor(blue.r, blue.g, blue.b, alpha * 0.9)
	surface.DrawRect(revenantBarX, y, revenantW, barH)
	surface.SetTexture(gradientLeft)
	surface.SetDrawColor(255, 255, 255, alpha * 0.18)
	surface.DrawTexturedRect(revenantBarX, y, revenantW, barH)

	surface.SetDrawColor(255, 255, 255, alpha * 0.5)
	surface.DrawRect(x + halfW - 1, y - 3, 2, barH + 6)

	local atlasFlashAmt = math.max(0, livesAtlasFlash - ct)
	local revenantFlashAmt = math.max(0, livesRevenantFlash - ct)
	local pulse = (math.sin(ct * 6) + 1) * 0.5
	local atlasPulseAmt = atlas < 5 and (pulse * 0.65 + 0.35) or 0
	local revenantPulseAmt = revenant < 5 and (pulse * 0.65 + 0.35) or 0

	local atlasMix = math.max(atlasFlashAmt, atlasPulseAmt)
	local revenantMix = math.max(revenantFlashAmt, revenantPulseAmt)
	local atlasColor = Color(
		hudWhite.r + (255 - hudWhite.r) * atlasMix,
		hudWhite.g + (40 - hudWhite.g) * atlasMix,
		hudWhite.b + (40 - hudWhite.b) * atlasMix,
		alpha
	)
	local revenantColor = Color(
		hudWhite.r + (255 - hudWhite.r) * revenantMix,
		hudWhite.g + (40 - hudWhite.g) * revenantMix,
		hudWhite.b + (40 - hudWhite.b) * revenantMix,
		alpha
	)

	hudDark.a = alpha
	draw.SimpleTextOutlined("ATLAS  " .. atlas, "RealishLivesSmall", atlasBarX + 12, y + barH * 0.5, atlasColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 1, hudDark)
	draw.SimpleTextOutlined(revenant .. "  REVENANT", "RealishLivesSmall", revenantBarX + revenantW - 12, y + barH * 0.5, revenantColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 1, hudDark)

	local endTime = GetGlobalFloat("Realish_RoundEndTime", 0)
	if endTime > 0 then
		local remaining = math.max(0, endTime - CurTime())
		local mins = math.floor(remaining / 60)
		local secs = math.floor(remaining % 60)
		local timeText = string.format("%02d:%02d", mins, secs)

		local timerBarW = 132
		local timerBarH = 22
		local timerBarX = x + halfW - timerBarW * 0.5
		local timerBarY = y + barH + 5

		surface.SetDrawColor(8, 8, 10, alpha * 0.82)
		surface.DrawRect(timerBarX, timerBarY, timerBarW, timerBarH)
		surface.SetDrawColor(255, 255, 255, alpha * 0.08)
		surface.DrawOutlinedRect(timerBarX, timerBarY, timerBarW, timerBarH, 1)

		local lowTime = remaining < 60
		local timerColor = lowTime and Color(255, 60, 60, alpha) or Color(245, 245, 245, alpha)
		if lowTime then
			local pulse = (math.sin(ct * 6) + 1) * 0.5
			timerColor = Color(255, 60 + pulse * 40, 60 + pulse * 40, alpha)
		end

		draw.SimpleTextOutlined(timeText, "RealishLivesSmall", timerBarX + timerBarW * 0.5, timerBarY + timerBarH * 0.5, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, hudDark)
	end
end

function MODE:CalcView(ply, pos, ang, fov)
	if not IsValid(menu) then return end

	local camPos = GetGlobalVector("Realish_MenuCamPos", vector_origin)
	if camPos == vector_origin then return end

	local camAng = GetGlobalAngle("Realish_MenuCamAng", angle_zero)
	local wave = math.sin(CurTime() * 0.45)
	local viewAng = Angle(camAng.p, camAng.y, camAng.r + wave * 2.5)

	return {
		origin = camPos + viewAng:Right() * wave * 70,
		angles = viewAng,
		fov = fov or 75,
		drawviewer = true
	}
end

hook.Add("Think", "Realish_DeathMenu", function()
	if zb.CROUND ~= "realish" then
		deployUntil = 0
		StopIntroSound()
		StopRoundMusic()
		StopHeroMusicSound()
		roundMusicStarted = false
		heroMusicActive = false
		musicMix = 0
		introEndTime = -math.huge
		StopHeroNotif()
		CloseMenu()
		return
	end

	local ply = LocalPlayer()
	if not IsValid(ply) then return end

	if CurTime() < introEndTime then return end

	if zb.ROUND_STATE == 1 and not roundMusicStarted then
		roundMusicStarted = true
		StartRoundMusic()
	end

	if not ply:Alive() then
		if deployUntil > CurTime() then
			CloseMenu()
			return
		end
		if ply:GetNWBool("Realish_IsHero", false) and ply:GetNWInt("Realish_HeroLives", 0) > 0 then
			CloseMenu()
			return
		end
		if heroLivesAnimStart ~= -math.huge and CurTime() - heroLivesAnimStart < heroLivesAnimDur then
			CloseMenu()
			return
		end

		if not IsValid(menu) then OpenMenu(true) end
	else
		deployUntil = 0

		if IsValid(menu) and menu.RealishDead then
			CloseMenu()
		end
	end
end)

net.Receive("realish_open_menu", function()
	deployUntil = 0
	if heroLivesAnimStart ~= -math.huge and CurTime() - heroLivesAnimStart < heroLivesAnimDur then
		timer.Simple(heroLivesAnimStart + heroLivesAnimDur - CurTime() + 0.05, function() OpenMenu(true) end)
		return
	end
	OpenMenu(true)
end)

net.Receive("realish_start", function()
	deployUntil = 0
	CloseMenu()
	StopRoundMusic()
	StopHeroMusicSound()
	roundMusicStarted = false
	heroMusicActive = false
	musicMix = 0
	StartIntro()
	zb.RemoveFade()
end)

net.Receive("realish_end", function()
	StopRoundMusic()
	roundMusicStarted = false
	StopHeroMusicSound()
	heroMusicActive = false
	musicMix = 0
	StopHeroNotif()
end)

net.Receive("realish_deployed", function()
	CloseMenu()
	livesVisibleUntil = math.max(livesVisibleUntil, CurTime() + 5)
	streakBoxVisibleUntil = math.max(streakBoxVisibleUntil, CurTime() + 5)
end)

local realishNotifs = {}
local realishNotifH = 36
local realishNotifGap = 8
local realishNotifInDur = 0.45
local realishNotifHold = 2.6
local realishNotifOutDur = 0.6
local realishNotifSlideSpeed = 2400

local function RealishAddHitNotif(kind, victimName)
	if not isstring(victimName) or victimName == "" then return end

	local prefix = "Killed"
	if kind == "takedown" then
		prefix = "Taken Down"
	elseif kind == "assist" then
		prefix = "Assist"
	elseif kind == "hero_denied" then
		prefix = "Hero not available"
	end

	realishNotifs[#realishNotifs + 1] = {
		kind = kind,
		text = prefix .. " (" .. victimName .. ")",
		start = CurTime(),
		curY = ScrH() + 80,
	}
end

local function RealishAddStreakNotif(streakID)
	local data = RealishKillstreaks and RealishKillstreaks[streakID]
	if not data then return end

	if isstring(data.earnedSound) and data.earnedSound ~= "" then
		surface.PlaySound(data.earnedSound)
	end

	realishNotifs[#realishNotifs + 1] = {
		kind = "streak",
		text = "KILLSTREAK: " .. (data.name or streakID),
		icon = GetKillstreakIcon(streakID),
		hold = 3.4,
		start = CurTime(),
		curY = ScrH() + 80,
	}
end

net.Receive("realish_hit_notify", function()
	RealishAddHitNotif(net.ReadString(), net.ReadString())
end)

net.Receive("realish_killstreak_earned", function()
	RealishAddStreakNotif(net.ReadString())
end)

net.Receive("realish_hero_notify", function()
	local teamID = net.ReadInt(4)
	local deadline = net.ReadFloat()
	StartHeroNotif(teamID, deadline)
end)

net.Receive("realish_hero_lives_anim", function()
	heroLivesAnimFrom = net.ReadInt(4)
	heroLivesAnimTo = net.ReadInt(4)
	heroLivesAnimStart = CurTime()
	heroLivesAnimSoundPlayed = false
end)

hook.Add("HUDPaint", "RealishHitNotifications", function()
	if zb.CROUND ~= "realish" then
		if #realishNotifs > 0 then realishNotifs = {} end
		return
	end

	local w, h = ScrW(), ScrH()
	local ft = FrameTime()
	local bottomY = h * 0.72
	for i = #realishNotifs, 1, -1 do
		local n = realishNotifs[i]
		if CurTime() - n.start > realishNotifInDur + (n.hold or realishNotifHold) + realishNotifOutDur then
			table.remove(realishNotifs, i)
		end
	end

	for i, n in ipairs(realishNotifs) do
		local hold = n.hold or realishNotifHold
		local t = CurTime() - n.start
		local phase, p

		if t < realishNotifInDur then
			phase = "in"
			p = t / realishNotifInDur
		elseif t < realishNotifInDur + hold then
			phase = "hold"
			p = 0
		else
			phase = "out"
			p = (t - realishNotifInDur - hold) / realishNotifOutDur
		end

		local fromBottom = #realishNotifs - i
		local visibleY = bottomY - fromBottom * (realishNotifH + realishNotifGap)
		local targetY = (phase == "out") and (h + 80) or visibleY
		n.curY = math.Approach(n.curY, targetY, ft * realishNotifSlideSpeed)

		local alpha
		if phase == "in" then
			alpha = p * p * (3 - 2 * p)
		elseif phase == "hold" then
			alpha = 1
		else
			alpha = 1 - p
		end
		alpha = math.Clamp(alpha, 0, 1)
		if alpha <= 0.01 then continue end

		surface.SetFont("RealishMedium")
		local tw = surface.GetTextSize(n.text)
		local isStreak = n.kind == "streak"
		local iconPad = n.icon and 26 or 0
		local notifW = math.max(220, tw + 48 + iconPad)
		local x = w * 0.5 - notifW * 0.5
		local y = n.curY

		surface.SetDrawColor(isStreak and 60 or 40, isStreak and 40 or 40, isStreak and 10 or 40, 200 * alpha)
		surface.DrawRect(x, y, notifW, realishNotifH)
		surface.SetDrawColor(orange.r, orange.g, orange.b, (isStreak and 140 or 30) * alpha)
		surface.DrawOutlinedRect(x, y, notifW, realishNotifH, 1)

		local textX = w * 0.5
		if n.icon then
			surface.SetMaterial(n.icon)
			surface.SetDrawColor(255, 255, 255, 255 * alpha)
			surface.DrawTexturedRect(x + 14, y + (realishNotifH - 24) * 0.5, 24, 24)
			textX = textX + iconPad * 0.5 + 2
		end

		draw.SimpleText(n.text, "RealishMedium", textX, y + realishNotifH * 0.5, Color(245, 245, 245, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end)
