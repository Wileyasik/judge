MODE.name = "tdm"

local MODE = MODE

local voteEndTime = 0
local selectedVote = 0
local voteResults = {[1] = 0, [2] = 0, [3] = 0}
local gradientRight = Material("vgui/gradient-r")
local gradientLeft = Material("vgui/gradient-l")
local gradientDown = Material("vgui/gradient-d")

local function GetVoteTotal()
	return (voteResults[1] or 0) + (voteResults[2] or 0) + (voteResults[3] or 0)
end

local function OpenArenaVoteMenu()
	if IsValid(ArenaVoteMenu) then ArenaVoteMenu:Remove() end

	ArenaVoteMenu = vgui.Create("DFrame")
	ArenaVoteMenu:SetSize(ScrW(), ScrH())
	ArenaVoteMenu:SetPos(0, 0)
	ArenaVoteMenu:SetTitle("")
	ArenaVoteMenu:ShowCloseButton(false)
	ArenaVoteMenu:SetDraggable(false)
	ArenaVoteMenu:MakePopup()
	ArenaVoteMenu.OpenTime = CurTime()
	ArenaVoteMenu.Paint = function(self, w, h)
		local elapsed = CurTime() - self.OpenTime
		local titleFrac = math.Clamp(elapsed / 0.4, 0, 1)
		local timerLeft = math.max(math.ceil(voteEndTime - CurTime()), 0)
		local pulse = 0.5 + math.sin(CurTime() * 4) * 0.5
		local timerColor = timerLeft <= 5 and Color(255, 120 + pulse * 80, 120 + pulse * 80) or Color(225, 225, 225)

		hg.DrawBlur(self, 5)
		draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 19, 235))
		surface.SetDrawColor(18, 18, 18, 65)
		surface.SetMaterial(gradientRight)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetMaterial(gradientLeft)
		surface.DrawTexturedRect(0, 0, w, h)
		surface.SetMaterial(gradientDown)
		surface.DrawTexturedRect(0, 0, w, h)
		draw.SimpleText("ARENA ROUNDS", "ZCity_Menu_Small", w * 0.5, h * 0.12, Color(225, 225, 225, 255 * titleFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("Vote for the series length", "ZCity_Menu_Settings_Small", w * 0.5, h * 0.16, Color(200, 200, 200, 255 * titleFrac), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText("TIME LEFT: " .. timerLeft, "ZCity_Menu_Small", w * 0.5, h * 0.86, timerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	ArenaVoteMenu.Think = function()
		if CurTime() >= voteEndTime and IsValid(ArenaVoteMenu) then ArenaVoteMenu:Remove() end
	end

	for i = 1, 3 do
		local data = ARENA_ROUND_OPTIONS[i]
		local button = vgui.Create("DButton", ArenaVoteMenu)
		button:SetSize(ScrW() * 0.7, ScrH() * 0.16)
		button.TargetX = ScrW() * 0.15
		button.TargetY = ScrH() * (0.25 + (i - 1) * 0.18)
		button:SetPos((i % 2 == 0) and ScrW() + 120 or -button:GetWide() - 120, button.TargetY)
		button:SetText("")
		button.OpenTime = CurTime() + (i - 1) * 0.08
		button.HoverFrac = 0
		button.SelectFrac = 0
		button.Think = function(self)
			local x = self:GetX()
			local intro = math.Clamp((CurTime() - self.OpenTime) / 0.35, 0, 1)
			self.HoverFrac = Lerp(FrameTime() * 10, self.HoverFrac, self:IsHovered() and 1 or 0)
			self.SelectFrac = Lerp(FrameTime() * 10, self.SelectFrac, selectedVote == i and 1 or 0)
			self:SetPos(Lerp(FrameTime() * 10, x, self.TargetX + self.HoverFrac * 10), self.TargetY - (1 - intro) * 4 - self.HoverFrac * 6)
		end
		button.Paint = function(self, w, h)
			local total = GetVoteTotal()
			local votes = voteResults[i] or 0
			local percent = total > 0 and math.floor(votes / total * 100) or 0
			local glow = math.max(self.HoverFrac, self.SelectFrac)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 190 + glow * 35))
			surface.SetDrawColor(225, 225, 225, 120 + glow * 80)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			draw.SimpleText(data.name, "ZCity_Menu_Small", 24 + self.HoverFrac * 6, h * 0.32, Color(225, 225, 225), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(data.description, "ZCity_Menu_Settings_Small", 24 + self.HoverFrac * 6, h * 0.7, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
			draw.SimpleText(percent .. "%", "ZCity_Menu_Small", w - 24, h * 0.32, Color(225, 225, 225), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			draw.SimpleText(votes .. " votes", "ZCity_Menu_Settings_Small", w - 24, h * 0.7, Color(210, 210, 210), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end
		button.DoClick = function()
			local oldVote = selectedVote
			selectedVote = i
			surface.PlaySound("ui/rem_select.wav")
			net.Start("arena_change_vote")
				net.WriteUInt(oldVote, 2)
				net.WriteUInt(i, 2)
			net.SendToServer()
		end
	end
end

net.Receive("arena_start_vote", function()
	voteEndTime = net.ReadFloat()
	selectedVote = 0
	voteResults = {[1] = 0, [2] = 0, [3] = 0}
	OpenArenaVoteMenu()
end)

net.Receive("arena_vote_update", function()
	voteResults = net.ReadTable() or {[1] = 0, [2] = 0, [3] = 0}
end)

net.Receive("arena_vote_result", function()
	selectedVote = net.ReadUInt(2)
	voteResults = net.ReadTable() or voteResults
	if IsValid(ArenaVoteMenu) then ArenaVoteMenu:Remove() end
	surface.PlaySound("ui/buttonclickrelease.wav")
end)

local function StartArenaIntro()
	if hg.DynaMusic then hg.DynaMusic:Stop() end
	surface.PlaySound("rem_tdm" .. math.random(1, 5) .. ".mp3")
	zb.RemoveFade()
	MODE.RoundTextTilts = {}
	for i = 1, 8 do
		MODE.RoundTextTilts[i] = (math.random() < 0.5) and 3 or -3
	end
end

net.Receive("arena_round_start",function()
	local showIntro = net.ReadBool()
	MODE.ShowRoundIntro = showIntro
	if showIntro then StartArenaIntro() end
end)

net.Receive("tdm_start",function()
	zb.rtype = net.ReadString()
	StartArenaIntro()
end)

net.Receive("arena_announcer", function()
	local eventType = net.ReadUInt(2)
	local index = net.ReadUInt(4)
	if index < 1 or index > 10 then return end

	local path
	if eventType == 0 then path = "arena/killz/kill" .. index .. ".mp3" end
	if eventType == 1 then path = "arena/wins/red" .. index .. ".mp3" end
	if eventType == 2 then path = "arena/wins/blue" .. index .. ".mp3" end
	if eventType == 3 then path = "arena/cleaning/zachistka" .. index .. ".mp3" end
	if not path then return end

	for copy = 1, 2 do
		sound.PlayFile("sound/" .. path, "noplay", function(channel)
			if not IsValid(channel) then
				if copy == 1 then surface.PlaySound(path) end
				return
			end
			channel:SetVolume(1)
			channel:Play()
		end)
	end
end)

hook.Add("PreDrawHalos", "ArenaCleanupTargets", function()
	if zb.CROUND ~= "tdm" or not GetGlobalBool("ArenaCleanupActive") then return end
	local localPlayer = LocalPlayer()
	if not IsValid(localPlayer) or not localPlayer:GetNWBool("ArenaCleanupCleaner") then return end

	local targets = {}
	for _, ply in player.Iterator() do
		if ply:Alive() and ply:GetNWBool("ArenaCleanupTarget") then
			targets[#targets + 1] = ply
		end
	end

	if #targets > 0 then halo.Add(targets, Color(255, 35, 20), 2, 2, 1, true, true) end
end)

local teams = {
	[0] = {
		objective = "",
		name = "a Terrorist",
		color1 = Color(190,0,0),
		color2 = Color(190,0,0)
	},
	[1] = {
		objective = "",
		name = "a Counter Terrorist",
		color1 = Color(0,120,190),
		color2 = Color(0,120,190)
	},
}

hook.Add( "StartCommand", "TDM_DisallowMoveOrShoting", function( ply, mv )
	--; BLYAT NY NAXUA PISAT VSE V ODNY LINIY BLYAAA
	if zb.CROUND == "tdm" and (zb.ROUND_START or 0) + MODE.start_time > CurTime() then 
		mv:RemoveKey(IN_ATTACK)
		mv:RemoveKey(IN_ATTACK2)
		mv:RemoveKey(IN_FORWARD)
		mv:RemoveKey(IN_BACK)
		mv:RemoveKey(IN_MOVELEFT)
		mv:RemoveKey(IN_MOVERIGHT)
	end
end)

local function tdm_ease_out(x)
	return 1 - (1 - x) ^ 3
end

local function tdm_draw_text(text, fontname, x, y, col, a, ang, xalign, yalign)
	local m = Matrix()
	m:Translate(Vector(x, y, 0))
	m:Rotate(Angle(0, ang, 0))
	m:Translate(Vector(-x, -y, 0))

	cam.PushModelMatrix(m)
		draw.SimpleText(text, fontname, x, y, Color(col.r, col.g, col.b, a), xalign, yalign)
	cam.PopModelMatrix()
end

function MODE:RenderScreenspaceEffects()
	if self.ShowRoundIntro == false then return end
    local StartTime = zb.ROUND_START or CurTime()
	if StartTime + 7.5 < CurTime() then return end
    local fade = math.Clamp(StartTime + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
    local StartTime = zb.ROUND_START or CurTime()
	self:AddHudPaint()
	if GetGlobalBool("ArenaCleanupActive") then
		local time = string.FormattedTime(math.max(GetGlobalFloat("ArenaCleanupDeadline") - CurTime(), 0), "%02i:%02i:%02i")
		local objective = lply:GetNWBool("ArenaCleanupCleaner") and "ELIMINATE THE SURVIVORS" or "SURVIVE THE CLEANUP"
		draw.SimpleText(time, "ZB_HomicideMedium", sw * 0.5, sh * 0.92, Color(230, 45, 35), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(objective, "ZB_HomicideMedium", sw * 0.5, sh * 0.96, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	elseif StartTime + self.start_time > CurTime() then
		draw.SimpleText( string.FormattedTime(StartTime + self.start_time - CurTime(), "%02i:%02i:%02i"	), "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local time = string.FormattedTime( math.max(StartTime + (zb.ROUND_TIME or 400) - CurTime(), 0), "%02i:%02i:%02i" )
		draw.SimpleText( time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if self.ShowRoundIntro == false then return end
    if StartTime + self.start_time < CurTime() then return end
	 
	if not lply:Alive() then return end
	zb.RemoveFade()
	local t = CurTime() - StartTime
	local out_fade = math.Clamp((10.5 - t) / 1.5, 0, 1)
	local team_ = lply:Team()
    local Rolename = teams[team_].name
    local ColorRole = teams[team_].color1
    local Objective = teams[team_].objective
    local ColorObj = teams[team_].color2
	local elements = {
		{"Arena", "ZB_HomicideMediumLarge", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9},
		{"You are "..Rolename, "ZB_HomicideMediumLarge", ColorRole, sw * 0.5, sh * 0.5, "right", 0.7, 1.1},
		{Objective, "ZB_HomicideMedium", ColorObj, sw * 0.5, sh * 0.9, "bottom", 1.4, 1.3, true}
	}

	for i, el in ipairs(elements) do
		if el[1] == "" then continue end
		local appear = tdm_ease_out(math.Clamp((t - el[7]) / 2, 0, 1))
		local a = 255 * appear * out_fade
		if a <= 1 then continue end
		local slide = 1 - appear
		local x, y = el[4], el[5]
		if el[6] == "left" then
			x = x - slide * ScreenScale(220)
		elseif el[6] == "right" then
			x = x + slide * ScreenScale(220)
		elseif el[6] == "bottom" then
			y = y + slide * ScreenScale(120)
		end
		tdm_draw_text(el[1], el[2], x, y, el[3], a, el[9] and 0 or ((self.RoundTextTilts or {})[i] or 3) * appear, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	if hg.PluvTown.Active then
		surface.SetMaterial(hg.PluvTown.PluvMadness)
		surface.SetDrawColor(255, 255, 255, math.random(175, 255) * out_fade / 2)
		surface.DrawTexturedRect(sw * 0.25, sh * 0.44 - ScreenScale(15), sw / 2, ScreenScale(30))

		draw.SimpleText("SOMEWHERE IN PLUVTOWN", "ZB_ScrappersLarge", sw / 2, sh * 0.44 - ScreenScale(2), Color(0, 0, 0, 255 * out_fade), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function MODE:AddHudPaint()
end

local CreateEndMenu

net.Receive("tdm_roundend",function()
    CreateEndMenu()
end)



local colGray = Color(85,85,85,255)
local colRed = Color(130,10,10)
local colRedUp = Color(160,30,30)

local colBlue = Color(10,10,160)
local colBlueUp = Color(40,40,160)
local col = Color(255,255,255,255)

local colSpect1 = Color(75,75,75,255)
local colSpect2 = Color(255,255,255)

local colorBG = Color(55,55,55,255)
local colorBGBlacky = Color(40,40,40,255)

local blurMat = Material("pp/blurscreen")
local Dynamic = 0

BlurBackground = BlurBackground or hg.DrawBlur

if IsValid(hmcdEndMenu) then
    hmcdEndMenu:Remove()
    hmcdEndMenu = nil
end

CreateEndMenu = function()
	if IsValid(hmcdEndMenu) then
		hmcdEndMenu:Remove()
		hmcdEndMenu = nil
	end
	Dynamic = 0
	hmcdEndMenu = vgui.Create("ZFrame")

    surface.PlaySound("ambient/alarms/warningbell1.wav")

	local sizeX,sizeY = ScrW() / 2.5 ,ScrH() / 1.2
	local posX,posY = ScrW() / 1.3 - sizeX / 2,ScrH() / 2 - sizeY / 2

	hmcdEndMenu:SetPos(posX,posY)
	hmcdEndMenu:SetSize(sizeX,sizeY)
	--hmcdEndMenu:SetBackgroundColor(colGray)
	hmcdEndMenu:MakePopup()
	hmcdEndMenu:SetKeyboardInputEnabled(false)
	hmcdEndMenu:ShowCloseButton(false)

	local closebutton = vgui.Create("DButton",hmcdEndMenu)
	closebutton:SetPos(5,5)
	closebutton:SetSize(ScrW() / 20,ScrH() / 30)
	closebutton:SetText("")
	
	closebutton.DoClick = function()
		if IsValid(hmcdEndMenu) then
			hmcdEndMenu:Close()
			hmcdEndMenu = nil
		end
	end

	closebutton.Paint = function(self,w,h)
		surface.SetDrawColor( 122, 122, 122, 255)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
		surface.SetFont( "ZB_InterfaceMedium" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Close")
		surface.SetTextPos( lengthX - lengthX/1.1, 4)
		surface.DrawText("Close")
	end

    hmcdEndMenu.Paint = function(self,w,h)
		BlurBackground(self)

		surface.SetFont( "ZB_InterfaceMediumLarge" )
		surface.SetTextColor(col.r,col.g,col.b,col.a)
		local lengthX, lengthY = surface.GetTextSize("Players:")
		surface.SetTextPos(w / 2 - lengthX/2,20)
		surface.DrawText("Players:")

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end
	-- PLAYERS
	local DScrollPanel = vgui.Create("DScrollPanel", hmcdEndMenu)
	DScrollPanel:SetPos(10, 80)
	DScrollPanel:SetSize(sizeX - 20, sizeY - 90)
	function DScrollPanel:Paint( w, h )
		BlurBackground(self)

		surface.SetDrawColor( 255, 0, 0, 128)
        surface.DrawOutlinedRect( 0, 0, w, h, 2.5 )
	end

	for i, ply in player.Iterator() do
		if ply:Team() == TEAM_SPECTATOR then continue end
		local but = vgui.Create("DButton",DScrollPanel)
		but:SetSize(100,50)
		but:Dock(TOP)
		but:DockMargin( 8, 6, 8, -1 )
		but:SetText("")
		but.Paint = function(self,w,h)
            local col1 = (ply:Alive() and colRed) or colGray
            local col2 = (ply:Alive() and colRedUp) or colSpect1
			surface.SetDrawColor(col1.r,col1.g,col1.b,col1.a)
			surface.DrawRect(0,0,w,h)
			surface.SetDrawColor(col2.r,col2.g,col2.b,col2.a)
			surface.DrawRect(0,h/2,w,h/2)

            local col = ply:GetPlayerColor():ToColor()
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			
			surface.SetTextColor(0,0,0,255)
			surface.SetTextPos(w / 2 + 1,h/2 - lengthY/2 + 1)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

			surface.SetTextColor(col.r,col.g,col.b,col.a)
			surface.SetTextPos(w / 2,h/2 - lengthY/2)
			surface.DrawText(ply:GetPlayerName() or "He quited...")

            
			local col = colSpect2
			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:GetPlayerName() or "He quited..." )
			surface.SetTextPos(15,h/2 - lengthY/2)
			surface.DrawText((ply:Name() .. (not ply:Alive() and " - died" or "")) or "He quited...")

			surface.SetFont( "ZB_InterfaceMediumLarge" )
			surface.SetTextColor(col.r,col.g,col.b,col.a)
			local lengthX, lengthY = surface.GetTextSize( ply:Frags() or "He quited..." )
			surface.SetTextPos(w - lengthX -15,h/2 - lengthY/2)
			surface.DrawText(ply:Frags() or "He quited...")
		end

		function but:DoClick()
			if ply:IsBot() then chat.AddText(Color(255,0,0), "no, you can't") return end
			gui.OpenURL("https://steamcommunity.com/profiles/"..ply:SteamID64())
		end

		DScrollPanel:AddItem(but)
	end

	return true
end

function MODE:RoundStart()
	if IsValid(ArenaVoteMenu) then ArenaVoteMenu:Remove() end
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end
