local MODE = MODE
MODE.name = "brawl"

local currentStage = 1
local stageTotal = 1
local kills = 0
local currentWeapon = ""
local isFinalStage = false
local roundSeconds = 0
local graceEnd = 0
local graceDuration = 13
local lastMinutePlayed = false
local lastStageBannerUntil = 0
local lastStageName = ""
local uiRevealAt = 0
local uiPulse = 0
local audioGeneration = 0
local finalists = {}

local endPanel
local startStation
local lastMinuteStation
local lastStageStation
local roundLoopStation
local endStingerStation
local roundLoopFile = "loopviolence.MP3"
local roundLoopVol = 0.45

local UI = {
    bg = Color(24, 24, 26, 235),
    bgSoft = Color(34, 34, 37, 220),
    bgRowA = Color(44, 44, 47, 220),
    bgRowB = Color(38, 38, 41, 220),
    border = Color(92, 92, 98, 210),
    borderSoft = Color(62, 62, 66, 220),
    text = Color(240, 240, 242),
    textSoft = Color(188, 188, 194),
    accent = Color(164, 164, 172),
    accentStrong = Color(210, 210, 218)
}

local function DrawPanel(x, y, width, height, fill, border, radius)
    draw.RoundedBox(radius or 8, x, y, width, height, fill)
    surface.SetDrawColor(border or UI.border)
    surface.DrawOutlinedRect(x, y, width, height, 1)
end

local function PrettyWeaponName(class)
    if not isstring(class) or class == "" then return "Unknown" end
    local stored = weapons.GetStored(class)
    if stored and isstring(stored.PrintName) and stored.PrintName ~= "" then return stored.PrintName end
    local name = string.Trim(string.gsub(string.gsub(class, "^weapon_", ""), "_", " "))
    local words = string.Explode(" ", name)
    for index, word in ipairs(words) do
        words[index] = string.upper(string.sub(word, 1, 1)) .. string.sub(word, 2)
    end
    return #words > 0 and table.concat(words, " ") or class
end

local function StopStation(station)
    if IsValid(station) then station:Stop() end
end

local function StopBrawlSounds()
    StopStation(startStation)
    StopStation(lastMinuteStation)
    StopStation(lastStageStation)
    StopStation(roundLoopStation)
    StopStation(endStingerStation)
    startStation = nil
    lastMinuteStation = nil
    lastStageStation = nil
    roundLoopStation = nil
    endStingerStation = nil
end

local function StopBrawlBackground()
    StopStation(startStation)
    StopStation(lastMinuteStation)
    StopStation(lastStageStation)
    StopStation(roundLoopStation)
    startStation = nil
    lastMinuteStation = nil
    lastStageStation = nil
    roundLoopStation = nil
end

local function CleanupBrawlClient()
    audioGeneration = audioGeneration + 1
    StopBrawlSounds()
    if IsValid(endPanel) then endPanel:Remove() end
    endPanel = nil
    finalists = {}
    roundSeconds = 0
    graceEnd = 0
    lastStageBannerUntil = 0
end

local function PlayFilePath(path, volume, looped, callback, generation)
    if not isstring(path) or path == "" then return end
    generation = generation or audioGeneration
    local soundPath = string.StartWith(path, "sound/") and path or "sound/" .. path
    sound.PlayFile(soundPath, "noplay", function(station)
        if generation ~= audioGeneration then StopStation(station) return end
        if not IsValid(station) then
            surface.PlaySound(string.gsub(path, "^sound/", ""))
            return
        end
        station:SetVolume(math.Clamp(volume or 1, 0, 1))
        station:EnableLooping(looped == true)
        station:Play()
        if callback then callback(station) end
    end)
end

local function PlayURL(url, volume, callback, generation)
    if not isstring(url) or (not string.StartWith(url, "http://") and not string.StartWith(url, "https://")) then return false end
    sound.PlayURL(url, "noplay", function(station)
        if generation ~= audioGeneration then StopStation(station) return end
        if not IsValid(station) then return end
        station:SetVolume(math.Clamp(volume or 1, 0, 1))
        station:Play()
        if callback then callback(station) end
    end)
    return true
end

local function StartRoundLoop()
    if next(finalists) then return end
    StopStation(roundLoopStation)
    local generation = audioGeneration
    PlayFilePath(roundLoopFile ~= "" and roundLoopFile or "loopviolence.MP3", roundLoopVol, true, function(station)
        if generation == audioGeneration then roundLoopStation = station end
    end, generation)
end

local function StartFinalStageMusic()
    StopStation(roundLoopStation)
    roundLoopStation = nil
    if IsValid(lastStageStation) then return end
    local generation = audioGeneration
    PlayFilePath("laststage.mp3", 1, true, function(station)
        if generation == audioGeneration then lastStageStation = station end
    end, generation)
end

local function StopFinalStageMusic()
    if next(finalists) then return end
    local station = lastStageStation
    lastStageStation = nil
    if not IsValid(station) then StartRoundLoop() return end

    local generation = audioGeneration
    local startVolume = station:GetVolume()
    for index = 1, 10 do
        timer.Simple(index * 0.1, function()
            if generation ~= audioGeneration or not IsValid(station) then return end
            station:SetVolume(math.max(0, startVolume * (1 - index / 10)))
            if index == 10 then station:Stop() StartRoundLoop() end
        end)
    end
end

local function CreateEndPanel(winner, list)
    if IsValid(endPanel) then endPanel:Remove() end
    endPanel = vgui.Create("DFrame")
    local width, height = math.min(ScrW() * 0.56, 920), math.min(ScrH() * 0.76, 800)
    endPanel:SetSize(width, height)
    endPanel:Center()
    endPanel:SetTitle("")
    endPanel:ShowCloseButton(true)
    endPanel:SetDraggable(true)
    endPanel:MakePopup()

    function endPanel:Paint(w, h)
        DrawPanel(0, 0, w, h, UI.bg, UI.border, 10)
        draw.SimpleText("BRAWL RESULTS", "ZB_InterfaceMediumLarge", w / 2, ScreenScale(11), UI.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Winner: " .. (IsValid(winner) and winner:Nick() or "Nobody"), "ZB_InterfaceMedium", w / 2, ScreenScale(31), UI.accentStrong, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", endPanel)
    scroll:SetSize(width - 24, height - ScreenScale(58))
    scroll:SetPos(12, ScreenScale(44))
    for index, result in ipairs(list) do
        local line = vgui.Create("DPanel", scroll)
        line:SetTall(ScreenScale(22))
        line:Dock(TOP)
        line:DockMargin(0, 0, 0, 4)
        function line:Paint(w, h)
            local top = index <= 3
            DrawPanel(0, 0, w, h, index % 2 == 0 and UI.bgRowA or UI.bgRowB, top and UI.accent or UI.borderSoft, 6)
            draw.SimpleText("#" .. index, "ZB_InterfaceMedium", 10, h / 2, top and UI.accentStrong or UI.textSoft, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(result.name ~= "" and result.name or "Unknown", "ZB_InterfaceMedium", ScreenScale(28), h / 2, UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(result.kills .. " kills", "ZB_InterfaceMedium", w - 10, h / 2, UI.textSoft, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end

net.Receive("brawl_start", function()
    CleanupBrawlClient()
    roundSeconds = net.ReadUInt(16)
    currentStage, stageTotal, kills = 1, 1, 0
    currentWeapon, isFinalStage = "", false
    lastMinutePlayed = false
    lastStageName = ""
    uiRevealAt = math.huge
    chat.AddText(Color(255, 200, 120), "Get kills to unlock the next weapon.")
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("brawl_grace", function()
    graceEnd = net.ReadFloat()
    graceDuration = math.max(graceEnd - CurTime(), 1)
end)

net.Receive("brawl_music", function()
    local filePath, url = net.ReadString(), net.ReadString()
    local volume, duration = math.Clamp(net.ReadFloat(), 0, 1), math.max(0, net.ReadFloat())
    local generation = audioGeneration
    uiRevealAt = CurTime() + duration
    if duration <= 0 and filePath == "" and url == "" then return end

    local playedURL = PlayURL(url, volume, function(station) startStation = station end, generation)
    if not playedURL then
        PlayFilePath(filePath ~= "" and filePath or "brawlstart.MP3", volume, false, function(station) startStation = station end, generation)
    else
        timer.Simple(1.2, function()
            if generation ~= audioGeneration or IsValid(startStation) then return end
            PlayFilePath(filePath ~= "" and filePath or "brawlstart.MP3", volume, false, function(station) startStation = station end, generation)
        end)
    end
    timer.Simple(duration, function()
        if generation ~= audioGeneration then return end
        StopStation(startStation)
        startStation = nil
    end)
end)

net.Receive("brawl_progress", function()
    currentStage = net.ReadUInt(12)
    stageTotal = net.ReadUInt(12)
    kills = net.ReadUInt(16)
    currentWeapon = net.ReadString()
    isFinalStage = net.ReadBool()
    surface.PlaySound("items/itempickup.wav")
end)

net.Receive("brawl_final", function()
    local ply = net.ReadEntity()
    net.ReadString()
    lastStageName = IsValid(ply) and ply:Nick() or "Unknown"
    lastStageBannerUntil = CurTime() + 5
    chat.AddText(color_white, "[BRAWL] " .. lastStageName .. " reached the FINAL STAGE")
    surface.PlaySound("buttons/button15.wav")
end)

net.Receive("brawl_loop_music", function()
    roundLoopFile = net.ReadString()
    roundLoopVol = math.Clamp(net.ReadFloat(), 0, 1)
    StartRoundLoop()
end)

net.Receive("brawl_laststage_start", function()
    finalists[net.ReadUInt(13)] = true
    StartFinalStageMusic()
end)

net.Receive("brawl_laststage_stop", function()
    finalists[net.ReadUInt(13)] = nil
    StopFinalStageMusic()
end)

net.Receive("brawl_end", function()
    local winner = net.ReadEntity()
    local list = {}
    for index = 1, net.ReadUInt(7) do
        list[index] = {name = net.ReadString(), kills = net.ReadUInt(16)}
    end
    audioGeneration = audioGeneration + 1
    StopBrawlSounds()
    local generation = audioGeneration
    PlayFilePath("brawlwin.mp3", 1, false, function(station) endStingerStation = station end, generation)
    CreateEndPanel(winner, list)
end)

net.Receive("brawl_round_end", StopBrawlBackground)

hook.Add("RoundInfoCalled", "brawl_cleanup_on_round_info", function(nextMode)
    timer.Simple(0, function()
        if nextMode ~= "brawl" or zb.ROUND_STATE == 0 then CleanupBrawlClient() end
    end)
end)

function MODE:HUDPaint()
    uiPulse = uiPulse + FrameTime()
    local uiUnlocked = CurTime() >= uiRevealAt
    if uiUnlocked and roundSeconds > 0 then
        local remaining = math.max(0, (zb.ROUND_START or 0) + roundSeconds - CurTime())
        if remaining <= 60 and not lastMinutePlayed then
            local generation = audioGeneration
            PlayFilePath("lastminute.mp3", 0.35, false, function(station) lastMinuteStation = station end, generation)
            lastMinutePlayed = true
        end
        local text = string.FormattedTime(remaining, "%02i:%02i")
        surface.SetFont("ZB_InterfaceMedium")
        local textWidth, textHeight = surface.GetTextSize(text)
        local width, height = textWidth + ScreenScale(28), textHeight + ScreenScale(8)
        DrawPanel(ScrW() / 2 - width / 2, ScreenScale(4), width, height, UI.bg, UI.border, 6)
        draw.SimpleText(text, "ZB_InterfaceMedium", ScrW() / 2, ScreenScale(4) + height / 2, UI.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if CurTime() < graceEnd then
        local pulse = 0.82 + math.abs(math.sin(uiPulse * 3)) * 0.18
        draw.SimpleText("Prepare to Brawl - " .. math.ceil(graceEnd - CurTime()) .. "s", "ZB_InterfaceMediumLarge", ScrW() / 2, ScrH() * 0.45, Color(210 * pulse, 210 * pulse, 218 * pulse), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    if uiUnlocked and currentWeapon ~= nil then
        local width, height = math.min(ScrW() * 0.38, 520), ScreenScale(42)
        local x, y = ScreenScale(2), ScreenScale(4)
        DrawPanel(x, y, width, height, UI.bg, UI.border, 8)
        local progress = math.Clamp(stageTotal > 0 and currentStage / stageTotal or 0, 0, 1)
        draw.RoundedBox(4, x + 8, y + height - ScreenScale(9), width - 16, ScreenScale(5), Color(58, 58, 62))
        draw.RoundedBox(4, x + 8, y + height - ScreenScale(9), (width - 16) * progress, ScreenScale(5), UI.accent)
        draw.SimpleText(string.format("Stage %d/%d", currentStage, stageTotal), "ZB_InterfaceMedium", x + 10, y + ScreenScale(6), UI.accentStrong, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Kills: " .. kills, "ZB_InterfaceMedium", x + width - 10, y + ScreenScale(6), UI.textSoft, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Weapon: " .. PrettyWeaponName(currentWeapon), "ZB_InterfaceMedium", x + 10, y + ScreenScale(16), isFinalStage and UI.accentStrong or UI.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if lastStageBannerUntil > CurTime() and lastStageName ~= "" then
        local alpha = math.Clamp((lastStageBannerUntil - CurTime()) / 5, 0, 1)
        local width, height = math.min(ScrW() * 0.58, 760), ScreenScale(17)
        local x, y = ScrW() / 2 - width / 2, ScreenScale(44)
        DrawPanel(x, y, width, height, Color(24, 24, 26, 180 * alpha), Color(92, 92, 98, 170 * alpha), 8)
        draw.SimpleText(lastStageName .. " reached the FINAL STAGE", "ZB_InterfaceMedium", ScrW() / 2, y + height / 2, Color(210, 210, 218, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function MODE:RenderScreenspaceEffects()
    if CurTime() >= graceEnd or graceEnd <= 0 then return end
    local amount = math.Clamp((graceEnd - CurTime()) / graceDuration, 0, 1)
    DrawColorModify({
        ["$pp_colour_addr"] = 0, ["$pp_colour_addg"] = 0, ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = -0.05 * amount,
        ["$pp_colour_contrast"] = 1 - 0.5 * amount,
        ["$pp_colour_colour"] = 1 - amount,
        ["$pp_colour_mulr"] = 0, ["$pp_colour_mulg"] = 0, ["$pp_colour_mulb"] = 0
    })
end

function MODE:RoundStart()
    if IsValid(endPanel) then endPanel:Remove() end
    endPanel = nil
end

function MODE:EndRound()
    StopBrawlSounds()
end
