--
hg = hg or {}
hg.WeaponSelector = hg.WeaponSelector or {}
local WS = hg.WeaponSelector
local WS_FALLBACK_ACCENT = Color(55, 55, 55, 255)
local WS_FALLBACK_PANEL = Color(10, 10, 10, 255)
local WS_BOX_COLOR = Color(10, 10, 10, 0)
local WS_BADGE_PANEL_COLOR = Color(10, 10, 10, 0)
local WS_BADGE_TEXT_COLOR = Color(100, 100, 100, 0)
local WS_NAME_COLOR = Color(160, 160, 160, 0)

function WS.GetPrintName( self )
    local class = self:GetClass()
    local phrase = language.GetPhrase(class)
    if phrase ~= class and phrase ~= "" then return phrase end
    local printName = self:GetPrintName()
    return isstring(printName) and printName ~= "" and printName or class
end

WS.Show = 0
WS.Transparent = 0
WS.LastSelectedSlot = 0
WS.LastSelectedSlotPos = 0

WS.SelectedSlot = 0
WS.SelectedSlotPos = 0

function WS.DrawText(text, font, posX, posY, color, textAlign)
    local t = tostring(text or "")
    draw.DrawText( t, font, posX + 1, posY + 1, Color(10, 10, 10, 200), textAlign )
    draw.DrawText( t, font, posX, posY, color, textAlign )
end

function WS.GetSelectedWeapon(Weapons)
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end
    Weapons = Weapons or WS.GetWeaponTable(ply)
    local slotTbl = Weapons and Weapons[WS.SelectedSlot]
    local wep = slotTbl and slotTbl[WS.SelectedSlotPos]
    return IsValid(wep) and wep or nil
end

function WS.GetWeaponTable( ply )
    if not IsValid( ply ) or not ply:Alive() then return end
    local currentWeapons = ply:GetWeapons()
    local cache = WS.WeaponTableCache
    local validCount = 0
    local cacheValid = cache and cache.ply == ply

    for _, wep in ipairs(currentWeapons) do
        if not IsValid(wep) then continue end
        validCount = validCount + 1
        if cacheValid then
            local cached = cache.meta[wep]
            local slot = tonumber(wep.Slot) or 0
            local slotPos = tonumber(wep.SlotPos) or 0
            if not cached or cached.slot ~= slot or cached.slotPos ~= slotPos or cached.class ~= wep:GetClass() then
                cacheValid = false
            end
        end
    end
    if cacheValid and cache.count == validCount then return cache.formatted end

    local WeaponsGet = {}
    for _, wep in ipairs(currentWeapons) do
        if IsValid(wep) then WeaponsGet[#WeaponsGet + 1] = wep end
    end
    local FormatedTable = {}
    for slot = 0, 5 do
        FormatedTable[slot] = {count = 0}
    end

    table.sort(WeaponsGet, function(a, b)
        local slotA, slotB = tonumber(a.Slot) or 0, tonumber(b.Slot) or 0
        if slotA ~= slotB then return slotA < slotB end
        local posA, posB = tonumber(a.SlotPos) or 0, tonumber(b.SlotPos) or 0
        if posA ~= posB then return posA < posB end
        local classA, classB = a:GetClass(), b:GetClass()
        if classA ~= classB then return classA < classB end
        return a:EntIndex() < b:EntIndex()
    end)

    for _, wep in ipairs(WeaponsGet) do
        if not IsValid(wep) then continue end
        local tTbl = FormatedTable[tonumber(wep.Slot) or 0]
        if not tTbl then continue end
        tTbl[tTbl.count] = wep
        tTbl.count = tTbl.count + 1
    end

    local meta = {}
    for _, wep in ipairs(WeaponsGet) do
        meta[wep] = {
            slot = tonumber(wep.Slot) or 0,
            slotPos = tonumber(wep.SlotPos) or 0,
            class = wep:GetClass()
        }
    end
    WS.WeaponTableCache = {
        ply = ply,
        count = validCount,
        meta = meta,
        formatted = FormatedTable
    }
    return FormatedTable
end

local function WS_FindWeapon(Weapons, target)
    if not IsValid(target) then return end
    for slot = 0, 5 do
        local slotTbl = Weapons[slot]
        for pos = 0, slotTbl.count - 1 do
            if slotTbl[pos] == target then return slot, pos end
        end
    end
end

local function WS_SelectFallback(Weapons, ply)
    local slot, pos = WS_FindWeapon(Weapons, ply:GetActiveWeapon())
    if slot then
        WS.SelectedSlot, WS.SelectedSlotPos = slot, pos
        return Weapons[slot][pos]
    end

    for fallbackSlot = 0, 5 do
        if Weapons[fallbackSlot].count > 0 then
            WS.SelectedSlot, WS.SelectedSlotPos = fallbackSlot, 0
            return Weapons[fallbackSlot][0]
        end
    end
end

local function WS_GetFontFace()
    local cv = ConVarExists("hg_font") and GetConVar("hg_font") or nil
    if cv then
        local v = tostring(cv:GetString() or "")
        if v ~= "" then return v end
    end

    return "x14y24pxHeadUpDaisy"
end

surface.CreateFont("WS_CourierNew", {
    font = WS_GetFontFace(),
    size = ScreenScale(8),
    weight = 500,
    antialias = true,
})

surface.CreateFont("WS_WeaponName", {
    font = WS_GetFontFace(),
    size = ScreenScale(7),
    weight = 500,
    antialias = true,
})

surface.CreateFont("WS_WeaponNameSmall", {
    font = WS_GetFontFace(),
    size = ScreenScale(5.5),
    weight = 500,
    antialias = true,
})

surface.CreateFont("WS_SlotBadge", {
    font = WS_GetFontFace(),
    size = math.floor(ScreenScale(6) + 0.5),
    weight = 700,
    antialias = true,
})

local SLOT_BADGE_TEXT_OFFSET_X = 0
local SLOT_BADGE_TEXT_OFFSET_Y = -2
local WS_ICON_INFO_CACHE = setmetatable({}, {__mode = "k"})
local WS_NUMERIC_ICON_INFO_CACHE = {}

local function WS_GetCornerMetrics()
    local lineWidth = math.max(1, math.floor(ScreenScale(0.5) + 0.5))
    local cornerLength = math.max(lineWidth * 3, math.floor(ScreenScale(5) + 0.5))
    local inset = math.max(2, math.floor(ScreenScale(1) + 0.5))
    local opticalGap = math.max(1, math.floor(ScreenScale(0.5) + 0.5))

    return lineWidth, cornerLength, inset, inset + cornerLength + opticalGap
end

local function WS_DrawBoxCorners( x, y, wide, tall, alpha, accentColor, flash )
    local lineWidth, cornerLength, inset = WS_GetCornerMetrics()
    local maxLength = math.floor(math.min(wide, tall) / 2) - inset
    local cornerExtension = math.floor(ScreenScale(1.75) * (flash or 0) + 0.5)
    cornerLength = math.min(cornerLength + cornerExtension, maxLength)
    if cornerLength <= lineWidth then return end

    local left = math.floor(x + inset + 0.5)
    local top = math.floor(y + inset + 0.5)
    local right = math.floor(x + wide - inset - lineWidth + 0.5)
    local bottom = math.floor(y + tall - inset - lineWidth + 0.5)

    local whiteMix = (flash or 0) * 0.18
    local red = Lerp(whiteMix, accentColor.r, 255)
    local green = Lerp(whiteMix, accentColor.g, 255)
    local blue = Lerp(whiteMix, accentColor.b, 255)
    local cornerAlpha = Lerp(flash or 0, 160, 198)
    surface.SetDrawColor(red, green, blue, alpha * cornerAlpha)
    surface.DrawRect(left, top, cornerLength, lineWidth)
    surface.DrawRect(left, top, lineWidth, cornerLength)
    surface.DrawRect(right - cornerLength + lineWidth, bottom, cornerLength, lineWidth)
    surface.DrawRect(right, bottom - cornerLength + lineWidth, lineWidth, cornerLength)
end

local function WS_DrawSlotBadge( slot, x, y, wide, alpha, accentColor )
    local badgeSize = math.floor(ScreenScale(7) + 0.5)
    if badgeSize % 2 ~= 0 then badgeSize = badgeSize + 1 end

    local badgeGap = math.floor(ScreenScale(1.5) + 0.5)
    local badgeX = math.floor(x + (wide - badgeSize) / 2 + 0.5)
    local badgeY = math.floor(y - badgeGap - badgeSize + 0.5)
    local panelColor = hg.theme and hg.theme.c.panel or WS_FALLBACK_PANEL

    WS_BADGE_PANEL_COLOR.r = panelColor.r
    WS_BADGE_PANEL_COLOR.g = panelColor.g
    WS_BADGE_PANEL_COLOR.b = panelColor.b
    WS_BADGE_PANEL_COLOR.a = alpha * 205
    draw.RoundedBox(0, badgeX, badgeY, badgeSize, badgeSize, WS_BADGE_PANEL_COLOR)
    surface.SetDrawColor(accentColor.r, accentColor.g, accentColor.b, alpha * 80)
    surface.DrawOutlinedRect(badgeX, badgeY, badgeSize, badgeSize, 1)

    -- Pixel fonts sit optically high even when their line box is mathematically centered.
    local textX = badgeX + badgeSize / 2 + SLOT_BADGE_TEXT_OFFSET_X
    local textY = badgeY + badgeSize / 1.85 + SLOT_BADGE_TEXT_OFFSET_Y
    WS_BADGE_TEXT_COLOR.a = alpha * 255
    draw.SimpleText(slot, "WS_SlotBadge", textX, textY, WS_BADGE_TEXT_COLOR, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

local function WS_GetUsableIcon( icon )
    if not icon then return end
    local cache = isnumber(icon) and WS_NUMERIC_ICON_INFO_CACHE or WS_ICON_INFO_CACHE
    local cached = cache[icon]
    if cached then return icon, cached[1], cached[2] end

    local iconWide, iconTall
    if isnumber(icon) then
        iconWide, iconTall = surface.GetTextureSize(icon)
    else
        if not isfunction(icon.Width) or not isfunction(icon.Height) or not isfunction(icon.IsError) or icon:IsError() then return end
        local iconName = isfunction(icon.GetName) and string.lower(icon:GetName() or "") or ""
        if iconName == "null" or iconName == "__error" then return end
        iconWide = icon:Width()
        iconTall = icon:Height()
    end
    if not isnumber(iconWide) or not isnumber(iconTall) or iconWide <= 0 or iconTall <= 0 then return end

    cache[icon] = {iconWide, iconTall}
    return icon, iconWide, iconTall
end

local function WS_DrawInactiveIcon( wep, x, y, wide, tall, alpha )
    local icon, iconWide, iconTall = WS_GetUsableIcon(wep.WepSelectIcon2)
    if not icon then
        icon, iconWide, iconTall = WS_GetUsableIcon(wep.WepSelectIcon)
    end
    if not icon then return end

    local padding = math.max(2, math.floor(ScreenScale(1.5) + 0.5))
    local maxWide = wide - padding * 2
    local maxTall = tall - padding * 2
    if maxWide <= 0 or maxTall <= 0 then return end
    local scale = math.min(maxWide / iconWide, maxTall / iconTall)
    local drawWide = iconWide * scale
    local drawTall = iconTall * scale

    render.SetScissorRect(math.ceil(x), math.ceil(y), math.floor(x + wide), math.floor(y + tall), true)
    surface.SetDrawColor(190, 190, 190, alpha)
    if isnumber(icon) then
        surface.SetTexture( icon )
    else
        surface.SetMaterial( icon )
    end
    surface.DrawTexturedRect(x + (wide - drawWide) / 2, y + (tall - drawTall) / 2, drawWide, drawTall)
    render.SetScissorRect(0, 0, 0, 0, false)
end

local function WS_DrawFittedIcon( wep, x, y, wide, tall, alpha )
    if wide <= 0 or tall <= 0 then return false end

    local icon, iconWide, iconTall = WS_GetUsableIcon(wep.WepSelectIcon2)
    if not icon then
        icon, iconWide, iconTall = WS_GetUsableIcon(wep.WepSelectIcon)
    end
    if not icon then return false end

    local iconScale = tonumber(wep.WSIconScale) or 1.05
    if wep.WepSelectIcon2box and wep.WSIconScale == nil then iconScale = iconScale * 1.02 end
    iconScale = math.Clamp(iconScale, 0.75, 1.15)
    local offsetX = math.Clamp(tonumber(wep.WSIconOffsetX) or 0, -0.2, 0.2) * wide
    local offsetY = math.Clamp(tonumber(wep.WSIconOffsetY) or -0.035, -0.2, 0.2) * tall
    local scale = math.min(wide / iconWide, tall / iconTall) * iconScale
    local drawWide = iconWide * scale
    local drawTall = iconTall * scale
    local drawX = x + (wide - drawWide) / 2 + offsetX
    local drawY = y + (tall - drawTall) / 2 + offsetY

    render.PushFilterMag(TEXFILTER.ANISOTROPIC)
    render.PushFilterMin(TEXFILTER.ANISOTROPIC)
    surface.SetDrawColor(255, 255, 255, alpha)
    if isnumber(icon) then
        surface.SetTexture(icon)
    else
        surface.SetMaterial(icon)
    end
    surface.DrawTexturedRect(drawX, drawY, drawWide, drawTall)
    render.PopFilterMin()
    render.PopFilterMag()

    return true
end

local function WS_FitWeaponName( text, maxWide )
    local font = "WS_WeaponName"
    surface.SetFont(font)
    local textWide, textTall = surface.GetTextSize(text)
    if textWide <= maxWide then return text, font, textWide, textTall end

    font = "WS_WeaponNameSmall"
    surface.SetFont(font)
    textWide, textTall = surface.GetTextSize(text)
    if textWide <= maxWide then return text, font, textWide, textTall end

    local suffix = "..."
    local suffixWide = surface.GetTextSize(suffix)
    if suffixWide > maxWide then return "", font, 0, textTall end
    local boundaries = {0}
    for byteIndex = 2, #text do
        local byte = string.byte(text, byteIndex)
        if byte < 128 or byte >= 192 then
            boundaries[#boundaries + 1] = byteIndex - 1
        end
    end
    boundaries[#boundaries + 1] = #text

    local low, high, best = 1, #boundaries, 1
    while low <= high do
        local middle = math.floor((low + high) / 2)
        local candidate = string.sub(text, 1, boundaries[middle])
        local candidateWide = surface.GetTextSize(candidate)

        if candidateWide + suffixWide <= maxWide then
            best = middle
            low = middle + 1
        else
            high = middle - 1
        end
    end

    local fitted = string.TrimRight(string.sub(text, 1, boundaries[best])) .. suffix
    textWide, textTall = surface.GetTextSize(fitted)
    return fitted, font, textWide, textTall
end

local function WS_GetUTF8Length( text )
    local length = 0
    for byteIndex = 1, #text do
        local byte = string.byte(text, byteIndex)
        if byte < 128 or byte >= 192 then length = length + 1 end
    end
    return length
end

local function WS_GetUTF8Prefix( text, characterCount )
    if characterCount <= 0 then return "" end

    local length = 0
    for byteIndex = 1, #text do
        local byte = string.byte(text, byteIndex)
        if byte < 128 or byte >= 192 then
            length = length + 1
            if length > characterCount then
                return string.sub(text, 1, byteIndex - 1)
            end
        end
    end

    return text
end

local function WS_GetFittedName( text, maxWide )
    local cache = WS.NameFitCache
    if cache and cache.source == text and cache.maxWide == maxWide then
        return cache.text, cache.font, cache.width, cache.height, cache.length
    end

    local fitted, font, width, height = WS_FitWeaponName(text, maxWide)
    local length = WS_GetUTF8Length(fitted)
    cache = cache or {}
    cache.source = text
    cache.maxWide = maxWide
    cache.text = fitted
    cache.font = font
    cache.width = width
    cache.height = height
    cache.length = length
    WS.NameFitCache = cache
    return fitted, font, width, height, length
end

function WS.HookWeapon(wep)
    if not IsValid(wep) or wep.IsScrambledHooked then return end

    local oldPrint = wep.PrintWeaponInfo

    wep.PrintWeaponInfo = function(self, x, y, alpha)
        local oldInst = self.Instructions
        local oldPurp = self.Purpose
        local oldDesc = self.Description
        local oldAuth = self.Author
        
        -- Scramble
        self.Instructions = WS.Scramble(self.Instructions)
        self.Purpose = WS.Scramble(self.Purpose)
        self.Description = WS.Scramble(self.Description)
        self.Author = WS.Scramble(self.Author)
        
        -- Call original
        if oldPrint then
            oldPrint(self, x, y, alpha)
        elseif isfunction(self.DrawWeaponInfoBox) then
            self:DrawWeaponInfoBox(x, y, alpha)
        end
        
        -- Restore
        self.Instructions = oldInst
        self.Purpose = oldPurp
        self.Description = oldDesc
        self.Author = oldAuth
    end
    
    wep.IsScrambledHooked = true
end

function WS.WeaponSelectorDraw( ply )
    if not IsValid( ply ) or not ply:Alive() then return end
    local now = CurTime()
    if WS.Show < now then
        WS.BoxAnim = nil
        WS.NameAnimWeapon = nil
        WS.CornerFlashWeapon = nil
        WS.SelectedSlot = WS.LastSelectedSlot 
        WS.SelectedSlotPos = -1
        WS.Transparent = 0
        return
    end

    local scrW, scrH = ScrW(), ScrH()
    local AcsentColor = hg.theme and hg.theme.c.accent or WS_FALLBACK_ACCENT -- colors.presetBorder

    local Weapons = WS.GetWeaponTable( ply )
    local SelectedWep = WS.GetSelectedWeapon(Weapons)
    if not IsValid(SelectedWep) then
        SelectedWep = WS_SelectFallback(Weapons, ply)
    end
    if not IsValid(SelectedWep) then return end
    WS.Transparent = LerpFT(0.2, WS.Transparent, math.min(WS.Show - now, 1))
    local AmmoutSlots = 0
    WS.BoxAnim = WS.BoxAnim or {}
    WS.SlotBadgeAnim = WS.SlotBadgeAnim or {}
    for i = 0, 5 do
        local slotTbl = Weapons[i]
        if slotTbl.count < 1 then continue end
        AmmoutSlots = AmmoutSlots + 1
    end
    local columnIndex = 0
    local sizeX = scrW * 0.085
    local columnGap = math.max(2, math.floor(ScreenScale(2) + 0.5))
    local rowGap = math.max(1, math.floor(ScreenScale(1) + 0.5))
    local groupWide = AmmoutSlots * sizeX + math.max(0, AmmoutSlots - 1) * columnGap
    local groupX = (scrW - groupWide) / 2
    local firstRowY = scrH * 0.05
    local compactH = scrH * 0.025
    local selectedH = scrH * 0.12

    for i = 0, 5 do
        local slotTbl = Weapons[i]
        if slotTbl.count < 1 then continue end
        local position = groupX + columnIndex * (sizeX + columnGap)
        local rowY = firstRowY
        local badgeTarget = i == WS.SelectedSlot and 1 or 0
        WS.SlotBadgeAnim[i] = LerpFT(0.18, WS.SlotBadgeAnim[i] or 0, badgeTarget)

        if WS.SlotBadgeAnim[i] > 0.001 then
            local badgeFade = WS.SlotBadgeAnim[i] * WS.SlotBadgeAnim[i] * (3 - 2 * WS.SlotBadgeAnim[i])
            WS_DrawSlotBadge(i + 1, position, firstRowY, sizeX, WS.Transparent * badgeFade, AcsentColor)
        end

        for Id = 0, slotTbl.count - 1 do
            local wepId = Id
            local wep = slotTbl[wepId]
            if not wep then continue end
            local isSelected = SelectedWep == wep
            local targetH = isSelected and selectedH or compactH
            WS.BoxAnim[wep] = WS.BoxAnim[wep] or {h = compactH}
            WS.BoxAnim[wep].h = LerpFT(0.18, WS.BoxAnim[wep].h, targetH)

            local drawX, drawY, drawW, drawH = position, rowY, sizeX, WS.BoxAnim[wep].h
            local panelColor = hg.theme and hg.theme.c.panel or WS_FALLBACK_PANEL
            WS_BOX_COLOR.r = panelColor.r
            WS_BOX_COLOR.g = panelColor.g
            WS_BOX_COLOR.b = panelColor.b
            WS_BOX_COLOR.a = WS.Transparent * (isSelected and 212 or 132)
            draw.RoundedBox(
                0,
                drawX,
                drawY,
                drawW,
                drawH, 
                WS_BOX_COLOR -- colors.secondary
            )

            if isSelected then
                local showName = WS.Scramble(WS.GetPrintName(wep))
                local _, _, _, cornerSafe = WS_GetCornerMetrics()
                local namePad = math.max(3, math.floor(ScreenScale(3) + 0.5))
                local nameLift = math.max(1, math.floor(ScreenScale(1) + 0.5))
                local titleH = math.max(ScreenScale(8), compactH)
                local nameMaxWide = math.max(0, drawW - cornerSafe * 2)
                local nameFont
                local textW, textH
                local characterCount
                showName, nameFont, textW, textH, characterCount = WS_GetFittedName(showName, nameMaxWide)
                if WS.NameAnimWeapon ~= wep then
                    WS.NameAnimWeapon = wep
                    WS.NameAnimStarted = nil
                end
                local titleY = drawY + drawH - titleH
                local nameY = titleY + math.max(0, (titleH - textH) / 2) - nameLift
                local nameX = math.floor(drawX + (drawW - textW) / 2 + 0.5)
                local nameRoom = titleY - drawY - cornerSafe

                if nameRoom > 0 then
                    local nameReveal = math.Clamp(nameRoom / math.max(1, ScreenScale(3)), 0, 1)
                    if nameReveal >= 0.65 then
                        WS.NameAnimStarted = WS.NameAnimStarted or now
                    end
                    local typeDuration = math.Clamp(characterCount * 0.02, 0.14, 0.27)
                    local visibleCharacters = 0
                    if characterCount > 0 and WS.NameAnimStarted then
                        visibleCharacters = math.min(
                            characterCount,
                            math.floor((now - WS.NameAnimStarted) / typeDuration * characterCount)
                        )
                    end
                    local visibleName = WS_GetUTF8Prefix(showName, visibleCharacters)
                    surface.SetDrawColor(AcsentColor.r, AcsentColor.g, AcsentColor.b, WS.Transparent * nameReveal * 50)
                    surface.DrawRect(
                        math.floor(drawX + namePad + 0.5),
                        math.floor(titleY + 0.5),
                        math.max(0, math.floor(drawW - namePad * 2 + 0.5)),
                        1
                    )

                    render.SetScissorRect(
                        math.ceil(drawX + cornerSafe),
                        math.ceil(titleY),
                        math.floor(drawX + drawW - cornerSafe),
                        math.floor(drawY + drawH - nameLift),
                        true
                    )
                    WS_NAME_COLOR.a = WS.Transparent * nameReveal * 255
                    draw.DrawText(visibleName, nameFont, nameX, nameY, WS_NAME_COLOR, TEXT_ALIGN_LEFT)
                    render.SetScissorRect(0, 0, 0, 0, false)
                end
            else
                WS_DrawInactiveIcon( wep, drawX, drawY, drawW, drawH, WS.Transparent * 95 )
            end

            if isSelected then
                local titleH = math.max(ScreenScale(8), compactH)
                local _, _, _, cornerSafe = WS_GetCornerMetrics()
                local iconNameGap = math.max(2, math.floor(ScreenScale(1.25) + 0.5))
                local titleY = drawY + drawH - titleH
                local iconLeft = math.ceil(drawX + cornerSafe)
                local iconTop = math.ceil(drawY + cornerSafe)
                local iconRight = math.floor(drawX + drawW - cornerSafe)
                local iconBottom = math.floor(titleY - iconNameGap)
                local iconW = iconRight - iconLeft
                local iconH = iconBottom - iconTop
                local minimumIconH = math.max(16, math.floor(ScreenScale(7) + 0.5))
                if iconW > 1 and iconH >= minimumIconH then
                    local iconReveal = math.Clamp((iconH - minimumIconH) / math.max(1, ScreenScale(4)), 0, 1)
                    iconReveal = iconReveal * iconReveal * (3 - 2 * iconReveal)
                    render.SetScissorRect(
                        iconLeft,
                        iconTop,
                        iconRight,
                        iconBottom,
                        true
                    )
                    local iconDrawn = WS_DrawFittedIcon(
                        wep,
                        iconLeft,
                        iconTop,
                        iconW,
                        iconH,
                        WS.Transparent * iconReveal * 255
                    )

                    if not iconDrawn and wep.DrawWeaponSelection then
                        -- Common SWEP bases derive icon height from width instead of the supplied height.
                        local customWide = math.min(iconW, iconH * 1.95)
                        local customX = iconLeft + (iconW - customWide) / 2
                        WS.HookWeapon(wep)
                        wep:DrawWeaponSelection(
                            customX,
                            iconTop,
                            customWide,
                            iconH,
                            WS.Transparent * iconReveal * 230
                        )
                    end
                    render.SetScissorRect(0, 0, 0, 0, false)
                end
            end
            if isSelected then
                if WS.CornerFlashWeapon ~= wep then
                    WS.CornerFlashWeapon = wep
                    WS.CornerFlashStarted = now
                end
                local flashAge = now - (WS.CornerFlashStarted or 0)
                local flash = 0
                if flashAge >= 0.06 and flashAge < 0.1 then
                    local progress = (flashAge - 0.06) / 0.04
                    flash = 1 - (1 - progress) * (1 - progress)
                elseif flashAge >= 0.1 and flashAge < 0.16 then
                    flash = 1
                elseif flashAge >= 0.16 and flashAge < 0.34 then
                    local progress = math.Clamp((flashAge - 0.16) / 0.18, 0, 1)
                    flash = 1 - progress * progress * (3 - 2 * progress)
                end
                WS_DrawBoxCorners(drawX, drawY, drawW, drawH, WS.Transparent, AcsentColor, flash)
            end

            rowY = rowY + drawH + rowGap
        end
        columnIndex = columnIndex + 1
    end
end

-- Changer
local tAcceptKeys = {
    ["slot1"] = 1,
    ["slot2"] = 2,
    ["slot3"] = 3,
    ["slot4"] = 4,
    ["slot5"] = 5,
    ["slot6"] = 6,
}

local function WS_StepSelection(Weapons, direction, useCurrentSelection)
    local ordered = {}
    local currentIndex
    local selected = useCurrentSelection and WS.GetSelectedWeapon(Weapons) or nil

    for slot = 0, 5 do
        local slotTbl = Weapons[slot]
        for pos = 0, slotTbl.count - 1 do
            ordered[#ordered + 1] = {wep = slotTbl[pos], slot = slot, pos = pos}
            if slotTbl[pos] == selected then currentIndex = #ordered end
        end
    end

    if #ordered < 1 then return false end
    if not currentIndex then
        local activeSlot, activePos = WS_FindWeapon(Weapons, LocalPlayer():GetActiveWeapon())
        for index, entry in ipairs(ordered) do
            if entry.slot == activeSlot and entry.pos == activePos then
                currentIndex = index
                break
            end
        end
    end

    currentIndex = currentIndex or (direction > 0 and 0 or 1)
    local nextIndex = ((currentIndex - 1 + direction) % #ordered) + 1
    local entry = ordered[nextIndex]
    WS.SelectedSlot, WS.SelectedSlotPos = entry.slot, entry.pos
    return true
end

local function get_active_tool(ply, tool)
    local activeWep = ply:GetActiveWeapon()
    if not IsValid(activeWep) or activeWep:GetClass() ~= "gmod_tool" or activeWep.Mode ~= tool then return end
    return activeWep:GetToolObject(tool)
end

local function canUseSelector(ply)
    local wep = ply:GetActiveWeapon()
    local tool = get_active_tool(ply, "submaterial")
    if tool and IsValid(ply:GetEyeTraceNoCursor().Entity) then
        return true
    end

    return IsAiming(ply) or (IsValid(wep) and wep:GetClass() == "weapon_physgun" and ply:KeyDown(IN_ATTACK))
 end

local lastSelectorBind
local lastSelectorBindCode
local lastSelectorBindTime = 0
local SELECTOR_BIND_DEBOUNCE = 0.075

function WS.ChangeSelectionWep( ply, key, pressed, code )
    if pressed == false then return end
    if not IsValid( ply ) or not ply:Alive() then return end
    if ply.organism and ply.organism.otrub then return end
    if canUseSelector( ply ) then return end

    key = string.lower(string.Trim(tostring(key or "")))
    key = string.match(key, "^([^%s;]+)") or key
    local bindTime = SysTime()
    local iPos = tAcceptKeys[key]
    if iPos and key == lastSelectorBind and code == lastSelectorBindCode and bindTime - lastSelectorBindTime < SELECTOR_BIND_DEBOUNCE then
        return true
    end

    if iPos or key == "invnext" or key == "invprev" or key == "lastinv" then

        local Weapons = WS.GetWeaponTable( ply )
        if iPos then
            local slotTbl = Weapons[iPos - 1]
            if not slotTbl or slotTbl.count < 1 then return true end
        end
        if key == "lastinv" and not IsValid(WS.LastInv) then return end

        lastSelectorBind = key
        lastSelectorBindCode = code
        lastSelectorBindTime = bindTime
        local selectorWasOpen = WS.Show > CurTime()

        WS.Show = CurTime() + 4
        surface.PlaySound("arc9_eft_shared/weapon_generic_rifle_spin"..math.random(10)..".ogg")
        if iPos then
            iPos = iPos - 1
            local slotTbl = Weapons[iPos]
            local continueSlot = selectorWasOpen and WS.SelectedSlot == iPos and WS.SelectedSlotPos >= 0
            WS.SelectedSlotPos = continueSlot and (WS.SelectedSlotPos + 1) % slotTbl.count or 0
            WS.SelectedSlot = iPos
        elseif key == "invprev" then
            WS_StepSelection(Weapons, -1, selectorWasOpen)
        elseif key == "invnext" then
            WS_StepSelection(Weapons, 1, selectorWasOpen)
        elseif key == "lastinv" and IsValid(WS.LastInv) then
            WS.Show = 0
            local oldwep = ply:GetActiveWeapon()
            input.SelectWeapon( WS.LastInv )
            WS.LastInv = oldwep
        end

        return true
    end
end

function WS.SetActuallyWeapon( ply, cmd )
    if not IsValid( ply ) or not ply:Alive() then return end
    if (cmd:KeyDown( IN_ATTACK ) or cmd:KeyDown( IN_ATTACK2 )) and WS.Show > CurTime() then

        if WS.Selected and WS.Selected > CurTime() then 
            cmd:RemoveKey(IN_ATTACK) 
            cmd:RemoveKey(IN_ATTACK2) 
        else
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2) 
            
            local target = WS.GetSelectedWeapon()
            local active = ply:GetActiveWeapon()
            if IsValid(target) then
                if target ~= active then
                    WS.LastInv = IsValid(active) and active or nil
                end
                input.SelectWeapon(target)
            end
            cmd:RemoveKey(IN_ATTACK)
            cmd:RemoveKey(IN_ATTACK2) 

            WS.LastSelectedSlot = WS.SelectedSlot
            WS.LastSelectedSlotPos = WS.SelectedSlotPos
            WS.Selected = CurTime() + 0.2
            WS.Show = CurTime() + 0.2
            surface.PlaySound("arc9_eft_shared/weapon_generic_spin"..math.random(1,10)..".ogg")
        end
    end
end

hook.Add( "PlayerBindPress", "WeaponSelector_PlayerBindPress", WS.ChangeSelectionWep )

hook.Add( "HUDPaint", "WeaponSelector_Draw", function()
    WS.WeaponSelectorDraw( LocalPlayer() )
end)

hook.Add( "StartCommand", "WeaponSelector_StartCommand", WS.SetActuallyWeapon )

local tHideElements = {
    ["CHudWeaponSelection"] = true
}

hook.Add("HUDShouldDraw", "WeaponSelector_HUDShouldDraw", function(sElementName)
    if tHideElements[sElementName] then return false end
end)

function WS.Scramble(target)
    target = tostring(target or "")
    local ply = LocalPlayer()
    if ply.organism and ply.organism.brain and ply.organism.brain > 0.05 then
        local len = #target
        local scrambled = {}
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?"
        for i = 1, len do
            if string.sub(target, i, i) == " " then
                scrambled[i] = " "
            else
                local r = math.random(1, #chars)
                scrambled[i] = string.sub(chars, r, r)
            end
        end
        return table.concat(scrambled)
    end
    return target
end
