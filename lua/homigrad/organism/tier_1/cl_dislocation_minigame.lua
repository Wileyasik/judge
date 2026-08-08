
local matGhost = Material("vgui/dislocationBoneGhost.png", "noclamp smooth")
local matMove = Material("vgui/dislocationBoneMove.png", "noclamp smooth")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)
    
    self.limbType = 1
    self.failures = 0
    self.targetPly = nil
    self.holdProgress = 0
    self.dangerTime = 0
    self.failCooldown = 0
    self.targetMoveTime = math.Rand(0, math.pi * 2)
    
    self.ghostX = ScrW() * 0.5
    self.ghostY = ScrH() * 0.5
    
    self.boneX = ScrW() * 0.5
    self.boneY = ScrH() * 0.5
    
    self.isDragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0
    
    self.shakeIntensity = 0
    self.lastMouseX = gui.MouseX()
    self.lastMouseY = gui.MouseY()
    
    self.boneWidth = 400
    self.boneHeight = 160
    
    self.boneX = self.boneX + math.random(-200, 200)
    self.boneY = self.boneY + math.random(-100, 100)
end

function PANEL:SetLimbType(type)
    self.limbType = type
end

function PANEL:SetTarget(ply)
    self.targetPly = ply
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    surface.SetDrawColor(255, 255, 255, 180) 
    surface.SetMaterial(matGhost)
    surface.DrawTexturedRectRotated(self.ghostX, self.ghostY, self.boneWidth, self.boneHeight, 0)
    
    self:Logic()
    
    local drawX, drawY = self.boneX, self.boneY
    
    if self.shakeIntensity > 0 then
        drawX = drawX + math.random(-self.shakeIntensity, self.shakeIntensity)
        drawY = drawY + math.random(-self.shakeIntensity, self.shakeIntensity)
    end
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(matMove)
    surface.DrawTexturedRectRotated(drawX, drawY, self.boneWidth, self.boneHeight, 0)

    local barW, barH = 260, 10
    surface.SetDrawColor(50, 50, 50, 230)
    surface.DrawRect(w * 0.5 - barW * 0.5, h * 0.15, barW, barH)
    surface.SetDrawColor(180, 220, 180, 255)
    surface.DrawRect(w * 0.5 - barW * 0.5, h * 0.15, barW * math.Clamp(self.holdProgress / 2, 0, 1), barH)
end

function PANEL:Logic()
    if not LocalPlayer():Alive() or (LocalPlayer().organism and LocalPlayer().organism.otrub) then
        self:Close()
        return
    end
    
    if input.IsMouseDown(MOUSE_RIGHT) then
        self:Close()
        return
    end

    local mx, my = gui.MouseX(), gui.MouseY()
    local dt = FrameTime()
    self.failCooldown = math.max(self.failCooldown - dt, 0)
    self.targetMoveTime = self.targetMoveTime + dt

    local moveWidth = math.max(ScrW() * 0.18, 90)
    local moveHeight = math.max(ScrH() * 0.13, 50)
    self.ghostX = ScrW() * 0.5 + math.sin(self.targetMoveTime * 0.36) * moveWidth
    self.ghostY = ScrH() * 0.5 + math.sin(self.targetMoveTime * 0.48) * moveHeight
    
    local mouseSpeed = math.sqrt((mx - self.lastMouseX)^2 + (my - self.lastMouseY)^2) / dt
    self.lastMouseX = mx
    self.lastMouseY = my
    
    local halfW = self.boneWidth / 2
    local halfH = self.boneHeight / 2
    local hovering = mx >= (self.boneX - halfW) and mx <= (self.boneX + halfW) and
                     my >= (self.boneY - halfH) and my <= (self.boneY + halfH)
                     
    if input.IsMouseDown(MOUSE_LEFT) then
        if not self.isDragging and hovering then
            self.isDragging = true
            self.dragOffsetX = self.boneX - mx
            self.dragOffsetY = self.boneY - my
        end
    else
        self.isDragging = false
    end
    
    if self.isDragging then
        local targetX = mx + self.dragOffsetX
        local targetY = my + self.dragOffsetY
        
        self.boneX = Lerp(dt * 10, self.boneX, targetX)
        self.boneY = Lerp(dt * 10, self.boneY, targetY)
        
        if mouseSpeed > 260 then
            self.shakeIntensity = math.min(self.shakeIntensity + dt * 45, 20)
            self.dangerTime = self.dangerTime + dt

            if self.dangerTime > 0.45 and self.failCooldown <= 0 then
                self:Fail()
                return
            end
        else
            self.shakeIntensity = math.max(self.shakeIntensity - dt * 15, 0)
            self.dangerTime = math.max(self.dangerTime - dt * 2, 0)
        end
        
        local dist = math.sqrt((self.boneX - self.ghostX)^2 + (self.boneY - self.ghostY)^2)
        if dist < 40 then
            self.holdProgress = self.holdProgress + dt
            if self.holdProgress >= 2 then
                self:Win()
            end
        else
            if self.holdProgress > 0 and self.failCooldown <= 0 then
                self:Fail()
                return
            end
            self.holdProgress = math.max(self.holdProgress - dt * 2, 0)
        end
    else
        self.shakeIntensity = math.max(self.shakeIntensity - dt * 25, 0)
        self.dangerTime = 0
        self.holdProgress = math.max(self.holdProgress - dt * 2, 0)
    end
end

function PANEL:Fail()
    self.isDragging = false
    self.failures = self.failures + 1
    self.holdProgress = 0
    self.dangerTime = 0
    self.failCooldown = 0.5
    
    net.Start("hg_dislocation_minigame_pain")
    if IsValid(self.targetPly) then
        net.WriteEntity(self.targetPly)
    else
        net.WriteEntity(LocalPlayer())
    end
    net.SendToServer()
    
    self.boneX = self.boneX + math.random(-50, 50)
    self.boneY = self.boneY + math.random(-50, 50)
end

function PANEL:Win()
    net.Start("hg_dislocation_minigame_success")
    if IsValid(self.targetPly) then
        net.WriteEntity(self.targetPly)
    else
        net.WriteEntity(LocalPlayer())
    end
    net.WriteInt(self.limbType, 4)
    net.WriteInt(self.failures, 16)
    net.SendToServer()
    
    self:Close()
end

function PANEL:Close()
    self:Remove()
    gui.EnableScreenClicker(false)
end

vgui.Register("HG_DislocationMinigame", PANEL, "DPanel")

function hg.StartDislocationMinigame(limbType, targetPly)
    if IsValid(HG_DISLOCATION_PANEL) then HG_DISLOCATION_PANEL:Remove() end
    
    HG_DISLOCATION_PANEL = vgui.Create("HG_DislocationMinigame")
    HG_DISLOCATION_PANEL:SetLimbType(limbType)
    if targetPly then
        HG_DISLOCATION_PANEL:SetTarget(targetPly)
    end
    gui.EnableScreenClicker(true)
end
