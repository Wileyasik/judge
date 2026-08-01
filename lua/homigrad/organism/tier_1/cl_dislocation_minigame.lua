
local matGhost = Material("vgui/dislocationBoneGhost.png", "noclamp smooth")
local matMove = Material("vgui/dislocationBoneMove.png", "noclamp smooth")

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2)

    self.failures = 0
    self.targetPly = nil

    self.boneWidth = 400
    self.boneHeight = 160

    self.isDragging = false
    self.dragOffsetX = 0
    self.dragOffsetY = 0

    self.shakeIntensity = 0
    self.lastMouseX = gui.MouseX()
    self.lastMouseY = gui.MouseY()

    self:SetupDifficulty(1)
    self:ResetBone()
end

-- 1 = leg (easiest), 2 = arm (medium), 3 = jaw (hardest)
function PANEL:SetupDifficulty(limbType)
    self.limbType = limbType or 1

    if self.limbType == 1 then
        self.holdTime = 0.7
        self.winRadius = 26
        self.dragSpeed = 9
        self.ghostXRange = ScrW() * 0.06
        self.ghostYRange = ScrH() * 0.07
        self.ghostXFreq = 0.6
        self.ghostYFreq = 0.8
        self.shakeGain = 55
    elseif self.limbType == 2 then
        self.holdTime = 0.9
        self.winRadius = 22
        self.dragSpeed = 7.5
        self.ghostXRange = ScrW() * 0.09
        self.ghostYRange = ScrH() * 0.10
        self.ghostXFreq = 0.9
        self.ghostYFreq = 1.1
        self.shakeGain = 75
    else
        self.holdTime = 1.1
        self.winRadius = 18
        self.dragSpeed = 6
        self.ghostXRange = ScrW() * 0.11
        self.ghostYRange = ScrH() * 0.12
        self.ghostXFreq = 1.1
        self.ghostYFreq = 1.3
        self.shakeGain = 100
    end

    self.holdProgress = 0
end

function PANEL:SetLimbType(type)
    self:SetupDifficulty(type)
    self:ResetBone()
end

function PANEL:SetTarget(ply)
    self.targetPly = ply
end

function PANEL:ResetBone()
    local cx, cy = ScrW() * 0.5, ScrH() * 0.5
    self.ghostCenterX = cx
    self.ghostCenterY = cy

    self.boneX = cx + math.random(-250, 250)
    self.boneY = cy + math.random(-140, 140)

    self.holdProgress = 0
    self.shakeIntensity = 0
end

function PANEL:GetGhostPos()
    local t = CurTime()
    local x = self.ghostCenterX + math.sin(t * self.ghostXFreq) * self.ghostXRange
    local y = self.ghostCenterY + math.cos(t * self.ghostYFreq) * self.ghostYRange
    return x, y
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 200)
    surface.DrawRect(0, 0, w, h)

    self.ghostX, self.ghostY = self:GetGhostPos()

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

    self:DrawHUD()
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
    if dt <= 0 then dt = 1 / 60 end

    local mouseSpeed = math.sqrt((mx - self.lastMouseX)^2 + (my - self.lastMouseY)^2) / dt
    self.lastMouseX = mx
    self.lastMouseY = my

    local halfW = self.boneWidth / 2
    local halfH = self.boneHeight / 2
    local hovering = mx >= (self.boneX - halfW) and mx <= (self.boneX + halfW) and
                     my >= (self.boneY - halfH) and my <= (self.boneY + halfH)

    -- Input handling
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

        self.boneX = Lerp(dt * self.dragSpeed, self.boneX, targetX)
        self.boneY = Lerp(dt * self.dragSpeed, self.boneY, targetY)

        if mouseSpeed > 150 then
            self.shakeIntensity = math.min(self.shakeIntensity + dt * self.shakeGain, 20)

            if self.shakeIntensity > 10 and math.random() < 0.06 + (self.shakeIntensity - 10) * 0.012 then
                self:Fail()
                return
            end
        else
            self.shakeIntensity = math.max(self.shakeIntensity - dt * 25, 0)
        end

        local dist = math.sqrt((self.boneX - self.ghostX)^2 + (self.boneY - self.ghostY)^2)

        if dist <= self.winRadius and self.shakeIntensity < 6 then
            self.holdProgress = math.min(self.holdProgress + dt / self.holdTime, 1)
        else
            self.holdProgress = math.max(self.holdProgress - dt * 1.5, 0)
        end

        if self.holdProgress >= 1 then
            self:Win()
        end
    else
        self.shakeIntensity = 0
        self.holdProgress = math.max(self.holdProgress - dt * 2, 0)
    end
end

function PANEL:Fail()
    self.isDragging = false
    self.failures = self.failures + 1

    net.Start("hg_dislocation_minigame_pain")
    if IsValid(self.targetPly) then
        net.WriteEntity(self.targetPly)
    else
        net.WriteEntity(LocalPlayer())
    end
    net.SendToServer()

    self.boneX = self.boneX + math.random(-50, 50)
    self.boneY = self.boneY + math.random(-50, 50)
    self.holdProgress = 0
    self.shakeIntensity = 0
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

function PANEL:DrawHUD()
    local w, h = self:GetSize()

    -- Hold progress bar under the movable bone
    local pW = 140
    local pH = 8
    local px = self.boneX - pW * 0.5
    local py = self.boneY + self.boneHeight * 0.5 + 14

    surface.SetDrawColor(0, 0, 0, 160)
    surface.DrawRect(px, py, pW, pH)

    surface.SetDrawColor(110, 200, 255, 235)
    surface.DrawRect(px, py, pW * self.holdProgress, pH)

    surface.SetDrawColor(255, 255, 255, 200)
    surface.DrawOutlinedRect(px, py, pW, pH)
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
--REUSIN MCITY 1 STUFF YAY
