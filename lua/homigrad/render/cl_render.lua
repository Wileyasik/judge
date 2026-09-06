function hg.addbonecallback(ent)
	for i, callback in pairs(ent:GetCallbacks("BuildBonePositions")) do
		ent:RemoveCallback("BuildBonePositions", i)
	end

	ent:AddCallback("BuildBonePositions", hg.build_bone_positions)
end

function hg.build_bone_positions(self, count)
	local ply, ent

	if self:IsRagdoll() then
		ply = self:GetNWEntity("ply")
		ent = self
	else
		ply = self
		ent = IsValid(self.FakeRagdoll) and self.FakeRagdoll or self
	end

	if IsValid(ply.FakeRagdollOld) then ent = ply.FakeRagdollOld end

	DrawPlayerRagdoll(ent, ply)
end

hg.renderOverride = function(self, ent, flags)
	if bit.band(flags, STUDIO_RENDER) != STUDIO_RENDER then return end
	if IsValid(RENDERING_SCOPE) and self == RENDERING_SCOPE:GetOwner() then return end

	ent = IsValid(ent) and ent or self
	if ent.shouldTransmit == false then return end

	if ent:GetMaterial() == "NULL" then ent:DrawShadow(false) return end
	if not IsValid(ent) then return end

	DrawPlayerRagdoll(ent, self)
	if RenderAccessoriesCool then RenderAccessoriesCool(ent, self) end
	hook.Run("CoolPostDrawAppearance", ent, self)

	if IsValid(self.OldRagdoll) then if DrawAppearance then DrawAppearance(ent, self, true) end end
	if !hg.converging[self] then
		local gasWet = self:GetNWFloat("GasolineWet", 0)
		if gasWet > 0 then
			local k = math.Clamp(gasWet / 100, 0, 1)
			render.SetColorModulation(1 - 0.18 * k, 1 - 0.22 * k, 1 - 0.38 * k)
		end

		ent:DrawModel()

		if gasWet > 0 then render.SetColorModulation(1, 1, 1) end
	else
		DrawConversion(ent, self)
	end
	if DrawAppearance then
		DrawAppearance(ent, self)
	end

	hook.Run("PostDrawAppearance", ent, self)
end

if CLIENT then
	oldlean = oldlean or 0
	lean_lerp = lean_lerp or 0
	curlean = curlean or 0
	unmodified_angle = unmodified_angle or 0
	local time = SysTime() - 0.01
	hook.Add("HUDPaint", "leanin", function()
		local ply = LocalPlayer()
		local angles = ply:EyeAngles()

		local dtime = SysTime() - time
		time = SysTime()

		local lean = (ply.lean or 0)
		lean_lerp = LerpFT(hg.lerpFrameTime2(0.08, dtime), lean_lerp, lean)
	end)
end
