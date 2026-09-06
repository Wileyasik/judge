if CLIENT then
    local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
	local red = Color(75,25,25)
	local panclr = Color( 0, 0, 0, 140)
	local ammoMenuOutline = Color(255, 255, 255, 255)
	local ammoMenuFill = Color(0, 0, 0, 245)
	local ammoMenuGradient = Color(40, 40, 40, 55)
	local ammoMenuButtonIdle = Color(20, 20, 20, 235)
	local ammoMenuButtonHover = Color(34, 34, 34, 235)

	local gradient_u = Material("vgui/gradient-u")
	local gradient_d = Material("vgui/gradient-d")
	BlurBackground = hg.DrawBlur

	local function PaintInnerFrame(self,w,h)
		BlurBackground(self)
		surface.SetDrawColor(ammoMenuFill)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(ammoMenuGradient)
		surface.SetMaterial(gradient_d)
		surface.DrawTexturedRect( 0, 0, w, h )
		surface.SetDrawColor(ammoMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintButton(self,w,h)
		surface.SetDrawColor(self:IsHovered() and ammoMenuButtonHover or ammoMenuButtonIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(ammoMenuGradient)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect( 0, 0, w, h )
		surface.SetDrawColor(ammoMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
	end

	local function PaintCloseButton(self, w, h)
		surface.SetDrawColor(self:IsHovered() and ammoMenuButtonHover or ammoMenuButtonIdle)
		surface.DrawRect(0, 0, w, h)
		surface.SetDrawColor(ammoMenuOutline)
		surface.DrawOutlinedRect(0, 0, w, h, 1)
		draw.SimpleText(self:GetText(), "ZCity_Menu_Settings_Small", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

	local function PaintCountSlider(self, w, h, frac)
		local trackY = h / 2 - 1
		surface.SetDrawColor(20, 20, 20, 230)
		surface.DrawRect(0, trackY, w, 2)
		surface.SetDrawColor(255, 255, 255, 220)
		surface.DrawRect(0, trackY, w * frac, 2)
		local knobX = math.Clamp(w * frac - 3, 0, w - 6)
		draw.RoundedBox(2, knobX, h / 2 - 4, 6, 8, Color(245, 245, 245))
	end

    function AmmoMenu(ply)
        local ammodrop = 0
        if !ply:Alive() then return end
        local Frame = vgui.Create( "ZFrame" )
        Frame:SetTitle( "" ) -- "Ammunition"
        Frame:SetSize( 250,360 )
        Frame:Center()			
        Frame:MakePopup()
		Frame:SetVisible(false)
		Frame:SetColorBG(ammoMenuFill)
		Frame:SetColorBR(ammoMenuOutline)
		if IsValid(Frame.btnClose) then
			Frame.btnClose:SetVisible(false)
			Frame.btnClose:SetMouseInputEnabled(false)
		end

		local CloseButton = Frame:Add("DButton")
		CloseButton:SetPos(Frame:GetWide() - 38, 10)
		CloseButton:SetSize(28, 28)
		CloseButton:SetText("X")
		CloseButton.Paint = PaintCloseButton
		CloseButton.DoClick = function()
			Frame:Close()
		end

		local Title = vgui.Create("DLabel", Frame)
		Title:SetPos(14, 12)
		Title:SetTextColor(color_white)
		Title:SetText("ammo")
		Title:SetFont("ZCity_Menu_Settings_Small")
		Title:SizeToContents()

        local DPanel = vgui.Create( "DScrollPanel", Frame )
        DPanel:SetPos( 10, 46 )
        DPanel:SetSize( 230, 230 )
        DPanel.Paint = function( self, w, h )
			PaintInnerFrame(self, w, h)
        end

		local sbar = DPanel:GetVBar()
		sbar:SetHideButtons(true)

		function sbar:Paint(w, h)
			surface.SetDrawColor(16, 16, 16, 220)
			surface.DrawRect(0, 0, w, h)
			surface.SetDrawColor(ammoMenuOutline)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
		end

		function sbar.btnGrip:Paint(w, h)
			self.lerpcolor = Lerp(FrameTime() * 10, self.lerpcolor or 0.3, self:IsHovered() and 0.5 or 0.3)
			local col = 255 * self.lerpcolor
			surface.SetDrawColor(col, col, col, 255)
			surface.DrawRect(0, 0, w, h)
		end

		local countLabel = vgui.Create( "DLabel", Frame )
		countLabel:SetPos( 25, 293 )
		countLabel:SetTextColor(color_white)
		countLabel:SetText( "Count:" )
		countLabel:SetFont("HomigradFontSmall")
		countLabel:SizeToContents()

		local sliderMin, sliderMax = 0, 60
		local sliderFrac = 0
		local sliderValue = vgui.Create("DLabel", Frame)
		sliderValue:SetPos(220, 309)
		sliderValue:SetSize(20, 20)
		sliderValue:SetText("")
		sliderValue.Paint = function(self, w, h)
			draw.SimpleText(tostring(ammodrop), "HomigradFontSmall", w, h * 0.5, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		end

		local sliderBg = vgui.Create("DButton", Frame)
		sliderBg:SetPos(74, 309)
		sliderBg:SetSize(132, 24)
		sliderBg:SetText("")

		local function UpdateAmmoSlider(frac)
			sliderFrac = math.Clamp(frac, 0, 1)
			ammodrop = math.Round(sliderMin + sliderFrac * (sliderMax - sliderMin))
		end

		local isDragging = false

		function sliderBg:Paint(w, h)
			PaintCountSlider(self, w, h, sliderFrac)
		end

		function sliderBg:OnMousePressed(mouseCode)
			if mouseCode == MOUSE_LEFT then
				isDragging = true
				self:MouseCapture(true)
				local x = self:CursorPos()
				UpdateAmmoSlider(x / self:GetWide())
			end
		end

		function sliderBg:OnMouseReleased(mouseCode)
			if mouseCode == MOUSE_LEFT then
				isDragging = false
				self:MouseCapture(false)
			end
		end

		function sliderBg:OnCursorMoved(x, y)
			if isDragging then
				UpdateAmmoSlider(x / self:GetWide())
			end
		end

        local ammos = LocalPlayer():GetAmmo()

        for k,v in pairs(ammos) do
            local DermaButton = vgui.Create( "DButton", DPanel ) 
            DermaButton:SetText( game.GetAmmoName( k )..": "..v )	
            DermaButton:SetTextColor( Color(255,255,255) )	
			DermaButton:SetFont("HomigradFontVSmall")
            DermaButton:SetPos( 0, 0 )	
            DermaButton:Dock( TOP )
            DermaButton:DockMargin( 4, 4, 4, 0 )	
            DermaButton:SetSize( 120, 28 )

            DermaButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				PaintButton(self, w, h)
            end				
            DermaButton.DoClick = function()
                --print( math.min(ammodrop,v),game.GetAmmoName( k ))				
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(ammodrop,v) )
                net.SendToServer()
                Frame:Close()
            end

            DermaButton.DoRightClick = function()
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(v,v) )
                net.SendToServer()
                Frame:Close()
            end
        end
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 10, 338 )
		DLabel:SetTextColor(color_white)
        DLabel:SetText( "LMB - Drop count\nRMB - Drop all" )
		DLabel:SetFont("HomigradFontVSmall")
        DLabel:SizeToContents()
		Frame:SlideDown(0.5)
    end

    concommand.Add( "hg_ammomenu", function( ply, cmd, args )
        AmmoMenu(ply)
    end )

	hook.Add("radialOptions", "hg-ammomenu", function()
		local organism = LocalPlayer().organism or {}
		if not organism.otrub and table.Count(LocalPlayer():GetAmmo()) > 0 then
			hg.radialOptions[#hg.radialOptions + 1] = {
				function()
					RunConsoleCommand("hg_ammomenu")

					return 0
				end,
				"Drop Ammo"
			}
		end
	end)
end
