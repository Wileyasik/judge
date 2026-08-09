include("shared.lua")

local laserMaterial = CreateMaterial("tripmine_laser", "UnlitGeneric", {
	["$basetexture"] = "sprites/laserbeam",
	["$additive"] = "1",
	["$vertexcolor"] = "1",
	["$vertexalpha"] = "1",
	["$nocull"] = "1",
	["$brightness"] = "64",
	["$textureScrollRate"] = "25.6",
})
local laserColor = Color(255, 55, 52, 64)

function ENT:CreateLaserHook()
	self.HookAdded = true
	local hookName = "SlamRender" .. self:EntIndex()
	hook.Add("PostDrawOpaqueRenderables", hookName, function(depth, skybox, skybox3D)
		if not IsValid(self) then
			hook.Remove("PostDrawOpaqueRenderables", hookName)
			return
		end
		if depth or skybox or skybox3D then return end
		if not self.TraceStart or not self.TraceHitPos then return end

		render.SetMaterial(laserMaterial)
		render.DrawBeam(
			self.TraceStart,
			self.TraceHitPos,
			0.35,
			0,
			1,
			laserColor
		)
	end)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:OnRemove()
	hook.Remove("PostDrawOpaqueRenderables", "SlamRender" .. self:EntIndex())
end
