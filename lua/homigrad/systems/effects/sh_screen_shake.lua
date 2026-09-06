if SERVER then
	util.AddNetworkString("util.ScreenShake")
end

hg.OldScreenShake = hg.OldScreenShake or util.ScreenShake

local hgExplosionGlares = {}
local hgExplosionFlash = 0
local hgExplosionFlashSmooth = 0

if CLIENT then
	local flareMat = Material("sprites/orangeflare1_gmod")
	local flareGlowMat = Material("sprites/glow04_noz")
	hook.Add("Post Post Pre Post Processing", "hg_ExplosionFlash", function()
		local now = CurTime()

		if hgExplosionFlash > 0.001 then
			hgExplosionFlash = math.max(0, hgExplosionFlash - FrameTime() * 5)
		end
		if hgExplosionFlashSmooth > 0.001 or hgExplosionFlash > 0.001 then
			hgExplosionFlashSmooth = LerpFT(hgExplosionFlash > hgExplosionFlashSmooth and 18 or 8, hgExplosionFlashSmooth, hgExplosionFlash)
			if hgExplosionFlashSmooth <= 0.001 then hgExplosionFlashSmooth = 0 end
			local s = hgExplosionFlashSmooth
			s = s * s * (3 - 2 * s)
			local alpha = math.floor(s * 150 + 0.5)
			if alpha > 0 then
				surface.SetDrawColor(255, 255, 255, alpha)
				surface.DrawRect(0, 0, ScrW(), ScrH())
			end
		end

		for i = #hgExplosionGlares, 1, -1 do
			local g = hgExplosionGlares[i]
			local anim = (now - g.born) / g.dur
			if anim >= 1 then
				table.remove(hgExplosionGlares, i)
				continue
			end
			local scr = g.pos:ToScreen()
			if not scr.visible then continue end
			local fade = (1 - anim) * (1 - anim)
			local size = g.size * (1 - anim * 0.5)
			local alpha = math.floor(g.alpha * fade + math.Rand(-12, 12) * fade + 0.5)
			if alpha > 0 then
				surface.SetMaterial(flareMat)
				surface.SetDrawColor(255, 255, 255, alpha)
				surface.DrawTexturedRect(scr.x - size / 2, scr.y - size / 2, size, size)
				surface.SetMaterial(flareGlowMat)
				surface.DrawTexturedRect(scr.x - size / 2, scr.y - size / 2, size, size)
			end
		end
	end)
end

local ScreenShakers = {}

function util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter, rotBoost, noMotionBlur, noVignette, noFovKick)
	if SERVER then
		vPos = vPos or Vector(0, 0, 0)
		nRadius = nRadius or (nAmplitude * 100)
		local crf = crfFilter or RecipientFilter()
		if not crfFilter then
			local tEnts = ents.FindInSphere(vPos, nRadius)
			for i = 1, #tEnts do
				local ent = tEnts[i]
				if IsValid(ent) and ent:IsPlayer() then crf:AddPlayer(ent) end
			end
		end

		net.Start("util.ScreenShake")
			net.WriteVector(vPos)
			net.WriteFloat(nAmplitude)
			net.WriteFloat(nFrequency)
			net.WriteFloat(nDuration or 1)
			net.WriteFloat(nRadius)
			net.WriteBool(bAirshake)
			net.WriteFloat(rotBoost or 1)
			net.WriteBool(noMotionBlur or false)
			net.WriteBool(noVignette or false)
			net.WriteBool(noFovKick or false)
		net.Send(crf)
	elseif CLIENT then
		nRadius = nRadius or (nAmplitude * 100)
		ScreenShakers[#ScreenShakers + 1] = {
			pos = vPos,
			amplitude = nAmplitude,
			frequency = math.max(nFrequency, 1),
			duration = nDuration or 1,
			radius = nRadius,
			airshake = bAirshake,
			created = CurTime(),
			nextSample = 0,
			target = vector_origin,
			offset = Vector(0, 0, 0),
			angTarget = Angle(0, 0, 0),
			angOffset = Angle(0, 0, 0),
			rotBoost = math.Clamp(rotBoost or 1, 0.1, 4),
			noMotionBlur = noMotionBlur or false,
			noVignette = noVignette or false,
			noFovKick = noFovKick or false
		}
		if hgExplosionGlares and not bAirshake and (nAmplitude or 0) >= 20 and (nRadius or 0) >= 300 then
			local ply = LocalPlayer()
			if IsValid(ply) and ply:Alive() and isvector(vPos) then
				local eyePos = ply:EyePos()
				local dir = vPos - eyePos
				local dist = dir:Length()
				if dist > 1 and dist < 5000 then
					local dot = ply:EyeAngles():Forward():Dot(dir:GetNormalized())
					if dot > 0.1 then
						local tr = util.TraceLine({start = eyePos, endpos = vPos, filter = ply})
						if tr.HitPos:Distance(vPos) < 64 then
							hgExplosionFlash = math.max(hgExplosionFlash, math.Clamp((nAmplitude or 0) / 50 * (1 - math.min(dist, 5000) / 5000), 0.2, 1))
							if #hgExplosionGlares < 8 then
								local size = math.Clamp((nAmplitude * 3) / math.max(dist / 120, 1), 36, 300)
								local alpha = math.Clamp(nAmplitude * 1.8, 120, 220)
								hgExplosionGlares[#hgExplosionGlares + 1] = {pos = vPos, born = CurTime(), dur = 0.3, size = size, alpha = alpha}
							end
						end
					end
				end
			end
		end
		hg.OldScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter)
	end
end

local plyMeta = FindMetaTable("Player")
function plyMeta:ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake)
	if SERVER then
		local crfFilter = RecipientFilter()
		crfFilter:AddPlayer(self)
		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, crfFilter)
	elseif CLIENT and self == lply then
		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake)
	end
end

if CLIENT then
	local explosionMotionBlur = 0

	function hg.GetExplosionMotionBlur()
		local ply = LocalPlayer()
		if not IsValid(ply) then return 0 end
		if #ScreenShakers == 0 and explosionMotionBlur == 0 then return 0 end

		local lastView = hg.LastMainRenderView
		local viewPos = lastView and lastView.origin or ply:EyePos()
		local now = CurTime()
		local target = 0
		for i = #ScreenShakers, 1, -1 do
			local shake = ScreenShakers[i]
			if shake.noMotionBlur then continue end
			local elapsed = now - shake.created
			if elapsed >= shake.duration then
				table.remove(ScreenShakers, i)
				continue
			end

			local distanceMul = 1 - math.Clamp(viewPos:Distance(shake.pos) / math.max(shake.radius, 1), 0, 1)
			local timeMul = 1 - elapsed / shake.duration
			local amplitudeMul = math.Clamp(shake.amplitude / 40, 0, 1)
			target = math.max(target, distanceMul * timeMul * amplitudeMul * 0.03)
		end

		explosionMotionBlur = LerpFT(0.06, explosionMotionBlur, target)
		if explosionMotionBlur < 0.0001 then explosionMotionBlur = 0 end
		return explosionMotionBlur
	end

	local explosionVignette = 0

	function hg.GetExplosionVignette()
		local ply = LocalPlayer()
		if not IsValid(ply) then return 0 end
		if #ScreenShakers == 0 and explosionVignette == 0 then return 0 end

		local lastView = hg.LastMainRenderView
		local viewPos = lastView and lastView.origin or ply:EyePos()
		local now = CurTime()
		local target = 0
		for i = #ScreenShakers, 1, -1 do
			local shake = ScreenShakers[i]
			if shake.noKick or shake.noVignette then continue end
			local elapsed = now - shake.created
			if elapsed >= shake.duration then
				table.remove(ScreenShakers, i)
				continue
			end

			local distanceMul = 1 - math.Clamp(viewPos:Distance(shake.pos) / math.max(shake.radius, 1), 0, 1)
			local timeMul = 1 - elapsed / shake.duration
			local amplitudeMul = math.Clamp(shake.amplitude / 40, 0, 1)
			target = math.max(target, distanceMul * timeMul * amplitudeMul)
		end

		explosionVignette = LerpFT(0.06, explosionVignette, target)
		if explosionVignette < 0.001 then explosionVignette = 0 end
		return explosionVignette
	end

	local explosionFovKick = 0
	local ExplosionFovPunchMax = 5
	local ExplosionFovWaveMax = 3

	function hg.GetExplosionFovKick()
		local ply = LocalPlayer()
		if not IsValid(ply) then return 0 end
		if #ScreenShakers == 0 and explosionFovKick == 0 then return 0 end

		local lastView = hg.LastMainRenderView
		local viewPos = lastView and lastView.origin or ply:EyePos()
		local now = CurTime()
		local narrow = 0
		local widen = 0
		for i = #ScreenShakers, 1, -1 do
			local shake = ScreenShakers[i]
			local elapsed = now - shake.created
			if elapsed >= shake.duration then
				table.remove(ScreenShakers, i)
				continue
			end
			if shake.noFovKick then continue end

			local distanceMul = 1 - math.Clamp(viewPos:Distance(shake.pos) / math.max(shake.radius, 1), 0, 1)
			local timeMul = 1 - elapsed / shake.duration
			local amplitudeMul = math.Clamp(shake.amplitude / 40, 0, 1)
			local strength = distanceMul * timeMul * amplitudeMul

			if shake.noKick then
				widen = math.max(widen, strength)
			else
				narrow = math.max(narrow, strength)
			end
		end

		local target = widen * ExplosionFovWaveMax - narrow * ExplosionFovPunchMax
		if math.abs(target) > math.abs(explosionFovKick) then
			explosionFovKick = LerpFT(0.08, explosionFovKick, target)
		else
			explosionFovKick = LerpFT(0.06, explosionFovKick, target)
		end
		if math.abs(explosionFovKick) < 0.01 then explosionFovKick = 0 end

		return explosionFovKick
	end

	hook.Add("HG_CalcView", "hg_explosion_fov_kick", function(ply, origin, angles, fova)
		if not istable(fova) then return end
		fova[1] = fova[1] + hg.GetExplosionFovKick()
	end)

	function hg.ApplyScreenShakes(view, ply, isFake)
		if not istable(view) or not isvector(view.origin) or not isangle(view.angles) then return view end
		if #ScreenShakers == 0 then return view end

		local now = CurTime()
		local rotScale = 1 * 0.1
		local orgScale = 0
		local totalOffset = Vector(0, 0, 0)
		local totalAng = Angle(0, 0, 0)
		for i = #ScreenShakers, 1, -1 do
			local shake = ScreenShakers[i]
			local elapsed = now - shake.created
			if elapsed >= shake.duration then
				table.remove(ScreenShakers, i)
				continue
			end

			if not shake.airshake and not isFake and not ply:IsOnGround() then continue end

			local distanceMul = 1 - math.Clamp(view.origin:Distance(shake.pos) / math.max(shake.radius, 1), 0, 1)
			if distanceMul <= 0 then continue end

			if now >= shake.nextSample then
				shake.nextSample = now + 1 / shake.frequency
				shake.target = VectorRand(-1, 1)
				shake.angTarget = AngleRand(-1, 1)
			end

			local sampleLerp = math.Clamp(FrameTime() * shake.frequency, 0, 1)
			shake.offset = LerpVector(sampleLerp, shake.offset, shake.target)
			shake.angOffset = LerpAngle(sampleLerp, shake.angOffset, shake.angTarget)
			local timeMul = 1 - elapsed / shake.duration

			if orgScale > 0 then
				totalOffset:Add(shake.offset * (shake.amplitude / 5) * distanceMul * timeMul * orgScale)
			end

			if rotScale > 0 then
				local shakeRotScale = rotScale * shake.rotBoost
				totalAng:Add(shake.angOffset * (shake.amplitude / 5) * distanceMul * timeMul * shakeRotScale)

				if not shake.noKick and not shake.noFovKick then
					local toBlast = shake.pos - view.origin
					local dist = toBlast:Length()
					if dist > 1 then
						local dirAng = (toBlast / dist):Angle()
						local kickMul = (shake.amplitude / 40) * distanceMul * timeMul * shakeRotScale
						totalAng.p = totalAng.p + math.Clamp(math.AngleDifference(view.angles.p, dirAng.p) * kickMul, -6, 6)
						totalAng.y = totalAng.y + math.Clamp(math.AngleDifference(view.angles.y, dirAng.y) * kickMul, -8, 8)
					end
				end
			end
		end

		view.origin:Add(totalOffset)
		view.angles:Add(totalAng)
		return view
	end

	function hg.AddWaveShake(amplitude, duration)
		local ply = LocalPlayer()
		if not IsValid(ply) then return end
		ScreenShakers[#ScreenShakers + 1] = {
			pos = ply:EyePos(),
			amplitude = amplitude or 12,
			frequency = 12,
			duration = duration or 0.5,
			radius = 100000,
			airshake = false,
			created = CurTime(),
			nextSample = 0,
			target = vector_origin,
			offset = Vector(0, 0, 0),
			angTarget = Angle(0, 0, 0),
			angOffset = Angle(0, 0, 0),
			rotBoost = 1,
			noKick = true
		}
	end

	net.Receive("util.ScreenShake", function()
		local vPos = net.ReadVector()
		local nAmplitude = net.ReadFloat()
		local nFrequency = net.ReadFloat()
		local nDuration = net.ReadFloat()
		local nRadius = net.ReadFloat()
		local bAirshake = net.ReadBool()
		local rotBoost = net.ReadFloat()
		local noMotionBlur = net.ReadBool()
		local noVignette = net.ReadBool()
		local noFovKick = net.ReadBool()

		util.ScreenShake(vPos, nAmplitude, nFrequency, nDuration, nRadius, bAirshake, nil, rotBoost, noMotionBlur, noVignette, noFovKick)
	end)
end
