MODE.name = "tdm"

local MODE = MODE

net.Receive("tdm_start",function()
	if hg.DynaMusic then hg.DynaMusic:Stop() end
	surface.PlaySound("rem_tdm.mp3")
	zb.rtype = net.ReadString()
	zb.RemoveFade()
	MODE.RoundTextTilts = {}
	for i = 1, 8 do
		MODE.RoundTextTilts[i] = (math.random() < 0.5) and 3 or -3
	end
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
	if zb.CROUND == "tdm" and (zb.ROUND_START or 0) + 35 > CurTime() then 
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
    local StartTime = zb.ROUND_START or CurTime()
	if StartTime + 7.5 < CurTime() then return end
    local fade = math.Clamp(StartTime + 7.5 - CurTime(),0,1)

    surface.SetDrawColor(0,0,0,255 * fade)
    surface.DrawRect(-1,-1,ScrW() + 1,ScrH() + 1)
end

function MODE:HUDPaint()
    local StartTime = zb.ROUND_START or CurTime()
	self:AddHudPaint()
	if StartTime + 35 > CurTime() then
		draw.SimpleText( string.FormattedTime(StartTime + 35 - CurTime(), "%02i:%02i:%02i"	), "ZB_HomicideMedium", sw * 0.5, sh * 0.95, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText( "Press F3 to open buymenu", "ZB_HomicideMedium", sw * 0.5, sh * 0.9, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	else
		local time = string.FormattedTime( math.max(StartTime + (zb.ROUND_TIME or 400) - CurTime(), 0), "%02i:%02i:%02i" )
		draw.SimpleText( time, "ZB_HomicideMedium", sw * 0.5, sh * 0.95, ColorObj, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

    if StartTime + 35 < CurTime() then return end
	 
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
		{"Team DeathMatch", "ZB_HomicideMediumLarge", Color(255, 255, 255), sw * 0.5, sh * 0.1, "left", 0, 0.9},
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
    if IsValid(hmcdEndMenu) then
        hmcdEndMenu:Remove()
        hmcdEndMenu = nil
    end
end

surface.CreateFont("ZB_TDM_MENU", {
    font = "Verily Serif Mono",
    size = ScreenScale(12),
    extended = true,
    weight = 400,
    antialias = true
})
surface.CreateFont("ZB_TDM_MENU_BIG", {
    font = "Verily Serif Mono",
    size = ScreenScale(24),
    extended = true,
    weight = 400,
    antialias = true
})
surface.CreateFont("ZB_TDM_DESC", {
    font = "Verily Serif Mono",
    size = ScreenScale(7),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_TDM_CATEGORY", {
    font = "Verily Serif Mono",
    size = ScreenScale(6),
    extended = true,
    weight = 400,
    antialias = true
})

surface.CreateFont("ZB_TDM_DESCSMALL", {
    font = "Verily Serif Mono",
    size = ScreenScale(5),
    extended = true,
    weight = 400,
    antialias = true
})

local function PaintFrame(self,w,h)
	BlurBackground(self)
	surface.SetDrawColor(0, 0, 0, 120)
	surface.DrawRect(0, 0, w, h)
end

local function PaintPanel(self,w,h)
	surface.SetDrawColor(0, 0, 0, 185)
	surface.DrawRect(0, 0, w, h)
	surface.SetDrawColor(255, 255, 255, 145)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

local function tdm_buy(item)
	net.Start("tdm_buyitem")
		net.WriteTable(item)
	net.SendToServer()
end

local function tdm_icon_material(path)
	if not path or path == "" then return end
	if type(path) == "IMaterial" then return path end
	if isstring(path) then return Material(path, "smooth mips") end
end

local tdm_close_icon = Material("radialmenu/redcross.png", "smooth mips")

local function tdm_item_icon(item, weapon, ent)
	if item.Type == "Armor" then
		local armor = string.Replace(item.ItemClass or "", "ent_armor_", "")
		return tdm_icon_material(hg.armorIcons and hg.armorIcons[armor])
	end

	if weapon then
		if weapon.WepSelectIcon2 then return weapon.WepSelectIcon2 end
		return tdm_icon_material(weapon.IconOverride)
	end

	return tdm_icon_material(ent and ent.t and ent.t.IconOverride)
end

local function tdm_weapon_ammo(item, weapon)
	if not weapon then return end
	local ammo = weapon.Primary.Ammo != "none" and weapon.Primary.Ammo or weapon.Ammo or (weapons.GetStored( weapon.Base ) and weapons.GetStored( weapon.Base ).Primary.Ammo)
	if not hg.ammotypeshuy[ammo] then return end
	local ammo2 = "ent_ammo_"..hg.ammotypeshuy[ammo].name
	for name, ammoItem in pairs(MODE.BuyItems["Ammo"] or {}) do
		if istable(ammoItem) and ammoItem.ItemClass == ammo2 then return name, ammoItem, ammo end
	end
end

local function tdm_attach_preview(StartTime)
	if IsValid(TDM_OpenedBuyMenu) then TDM_OpenedBuyMenu:Remove() end
	if not IsValid(MENUPANELHUYHUY) then return end

	TDM_OpenedBuyMenu = vgui.Create("DPanel", MENUPANELHUYHUY)
	local Frame = TDM_OpenedBuyMenu
	Frame:SetSize(ScrW(), ScrH())
	Frame:SetMouseInputEnabled(false)
	Frame:SetKeyboardInputEnabled(false)
	Frame.Paint = function() end

	function Frame:Think()
		if StartTime + 35 < CurTime() and IsValid(MENUPANELHUYHUY) then
			MENUPANELHUYHUY:Close()
		end

		if not LocalPlayer():Alive() or StartTime + 35 < CurTime() or not IsValid(MENUPANELHUYHUY) then
			self:Remove()
			return
		end
	end

	local buytime = vgui.Create("DLabel", Frame)
	buytime:SetPos(ScrW() * 0.02, ScrH() * 0.8)
	buytime:SetSize(ScrW() * 0.22, ScrH() * 0.1)
	buytime:SetFont("ZB_TDM_MENU_BIG")
	buytime:SetContentAlignment(5)
	buytime:SetMouseInputEnabled(false)
	function buytime:Think()
		local timeLeft = math.ceil(math.max(StartTime + 35 - CurTime(), 0))
		local flash = timeLeft <= 5 and math.abs(math.sin(CurTime() * 8)) or 1
		self:SetText(timeLeft)
		self:SetTextColor(Color(255, 255 * flash, 255 * flash))
	end

	local cash = vgui.Create("DLabel", Frame)
	cash:SetPos(ScrW() * 0.02, ScrH() * 0.89)
	cash:SetSize(ScrW() * 0.22, ScrH() * 0.08)
	cash:SetFont("ZB_TDM_MENU_BIG")
	cash:SetTextColor(Color(60, 220, 60))
	cash:SetContentAlignment(5)
	cash:SetMouseInputEnabled(false)
	function cash:Think()
		self:SetText("$"..LocalPlayer():GetNWInt("TDM_Money",0))
	end

	local hint = vgui.Create("DLabel", Frame)
	hint:SetPos(ScrW() * 0.45, ScrH() * 0.91)
	hint:SetSize(ScrW() * 0.52, ScrH() * 0.06)
	hint:SetText("RMB: buy ammo     E: attachments")
	hint:SetFont("ZB_TDM_MENU")
	hint:SetTextColor(Color(235, 235, 235))
	hint:SetContentAlignment(6)
	hint:SetMouseInputEnabled(false)

	Frame:MoveToFront()
end

local function OpenBuyMenu()
	if zb.CROUND ~= "tdm" then return end

	if IsValid(TDM_OpenedBuyMenu) then
		TDM_OpenedBuyMenu:Remove()
		TDM_OpenedBuyMenu = nil
	end

	local StartTime = zb.ROUND_START or CurTime()
	if not LocalPlayer():Alive() or StartTime + 35 < CurTime() then return end
	if not hg.CreateRadialMenu then return end

	local open_radial
	local open_items
	local open_attachments
	local open_main
	local main_options

	local function add_close_option(options)
		options[#options + 1] = {function()
			open_main()
			return -1
		end, "Close", nil, nil, tdm_close_icon}
	end

	open_radial = function(options)
		hg.CreateRadialMenu(options)
		tdm_attach_preview(StartTime)
	end

	open_attachments = function(categoryName, itemName, item)
		local options = {}
		for _, attachName in ipairs(item.Attachments or {}) do
			options[#options + 1] = {function()
				tdm_buy({categoryName, itemName, attachName})
				return -1
			end, attachName, nil, nil, tdm_icon_material(hg.attachmentsIcons and hg.attachmentsIcons[attachName])}
		end
		add_close_option(options)
		open_radial(options)
	end

	open_items = function(categoryName, category)
		local options = {}
		for itemName, item in pairs(category) do
			if itemName == "Priority" then continue end
			if item.TeamBased ~= nil and item.TeamBased ~= LocalPlayer():Team() then continue end
			local weapon = weapons.GetStored(item.ItemClass)
			local ent = scripted_ents.GetStored(item.ItemClass)
			local icon = tdm_item_icon(item, weapon, ent)
			local ammoName, ammoItem = tdm_weapon_ammo(item, weapon)
			local price = "$"..item.Price..(ammoItem and " + ammo $"..ammoItem.Price or "")
			options[#options + 1] = {function(mouseClick)
				if mouseClick == 2 then
					if ammoName then tdm_buy({"Ammo", ammoName}) end
					return -1
				end
				if mouseClick == 3 then
					if weapon and #(item.Attachments or {}) > 0 then open_attachments(categoryName, itemName, item) end
					return -1
				end
			tdm_buy({categoryName, itemName})
			return -1
			end, itemName.."\n"..price, nil, nil, icon}
		end
		add_close_option(options)
		open_radial(options)
	end

	main_options = {}
	for categoryName, category in SortedPairsByMemberValue(MODE.BuyItems, "Priority") do
		if categoryName == "Ammo" then continue end
		local icon
		for itemName, item in pairs(category) do
			if itemName == "Priority" then continue end
			if item.TeamBased ~= nil and item.TeamBased ~= LocalPlayer():Team() then continue end
			icon = tdm_item_icon(item, weapons.GetStored(item.ItemClass), scripted_ents.GetStored(item.ItemClass))
			if icon then break end
		end
		main_options[#main_options + 1] = {function()
			open_items(categoryName, category)
			return -1
		end, categoryName, nil, nil, icon}
	end

	open_main = function()
		open_radial(main_options)
	end

	open_main()

end

local function ToggleBuyMenu()
	if zb.CROUND ~= "tdm" then
		if IsValid(TDM_OpenedBuyMenu) then TDM_OpenedBuyMenu:Remove() end
		return
	end

	if IsValid(MENUPANELHUYHUY) then
		MENUPANELHUYHUY:Close()
		if IsValid(TDM_OpenedBuyMenu) then TDM_OpenedBuyMenu:Remove() end
		return
	end

	OpenBuyMenu()
end

hook.Add("PlayerBindPress", "TDM_ToggleBuyMenu", function(ply, bind, pressed)
	if pressed and bind == "gm_showspare1" and zb.CROUND == "tdm" then
		ToggleBuyMenu()
		return true
	end
end)

local tdm_e_wasdown = false
hook.Add("Think", "TDM_BuyMenuAttachments", function()
	if not IsValid(TDM_OpenedBuyMenu) or not hg.PressRadialMenu then
		tdm_e_wasdown = false
		return
	end

	local down = input.IsKeyDown(KEY_E)
	if down and not tdm_e_wasdown then
		hg.PressRadialMenu(3)
	end
	tdm_e_wasdown = down
end)

net.Receive("tdm_open_buymenu",function()
	if zb.CROUND ~= "tdm" then return end
	ToggleBuyMenu()
end)
TDM_OpenedBuyMenu = TDM_OpenedBuyMenu or nil
