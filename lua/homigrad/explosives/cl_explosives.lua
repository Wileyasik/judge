local PropaneExplosionEffect = "cloudmaker_ground"
local ShockwaveMaterial = Material("sprites/physbeama")
local ShockwaveSegments = 18
local ShockwaveLift = 6
local ShockwaveWidthScale = 0.35
local ShockwaveMinWidth = 18
local ShockwaveMaxCount = 24
local ExplosionShockwaves = {}
local effectPerMSec = 0
local effectCDCurTime = 0
local GasTankEffects = {}
local GasTankLeakReceiveCooldown = 0.05
local GasTankMaxVisualLeaks = 1
local math_cos, math_sin, math_pi = math.cos, math.sin, math.pi
local math_max = math.max
local PendingWaveShakes = 0
local MaxPendingWaveShakes = 8
local ShockwaveScratchA = Vector(0, 0, 0)
local ShockwaveScratchB = Vector(0, 0, 0)

local ExplosiveSound = {
	Shockwave = {
		Effect = "pcf_jack_groundsplode_medium",
		ShockwaveColor = Color(255, 225, 180, 50)
	},
	Air = {
		Effect = "pcf_jack_airsplode_medium",
		ShockwaveColor = Color(255, 225, 180, 50)
	},
	Small = {
		Effect = "pcf_jack_airsplode_small3",
		ShockwaveColor = Color(255, 225, 180, 40)
	},
	Breach = {
		Effect = "pcf_jack_groundsplode_small3",
		ShockwaveColor = Color(255, 225, 180, 40)
	},
	None = {
		ShockwaveColor = Color(255, 255, 255, 60)
	},
	IED = {
		Effect = "pcf_jack_groundsplode_medium",
		ShockwaveColor = Color(255, 225, 180, 80)
	},
	Fire = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_incendiary_ground_sm2",
		ShockwaveColor = Color(255, 180, 120, 45)
	},
	PropaneSC500 = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = PropaneExplosionEffect,
		ShockwaveColor = Color(220, 220, 220, 50)
	},
	Sharpnel = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_groundsplode_medium",
		ShockwaveColor = Color(255, 225, 160, 42)
	},
	Normal = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_groundsplode_small",
		ShockwaveColor = Color(255, 215, 155, 38)
	},
	CustomBarrel = {
		Near = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"},
		Far = {"ied/ied_detonate_dist_01.wav", "ied/ied_detonate_dist_02.wav", "ied/ied_detonate_dist_03.wav"},
		Effect = "pcf_jack_incendiary_ground_sm2",
		ShockwaveColor = Color(255, 190, 130, 58)
	}
}

local PendingDelayedSounds = 0
local MaxPendingDelayedSounds = 64
local function PlaySndDist(snd, snd2, pos, isOnWater, watersnd)
	if SERVER then return end
	if PendingDelayedSounds >= MaxPendingDelayedSounds then return end
	PendingDelayedSounds = PendingDelayedSounds + 1
	local view = render.GetViewSetup(true)
	local time = pos:Distance(view.origin) / 13504
	timer.Simple(time, function()
		PendingDelayedSounds = math_max(PendingDelayedSounds - 1, 0)
		local dist = pos:Distance(view.origin)
		local vol = math.Clamp(1 - (dist - 300) / 24000, 0.3, 1)
		local nearVol = vol * (1 - math.Clamp((dist - 1200) / 8000, 0, 1))
		if not isOnWater then
			EmitSound(snd2, pos, 0, CHAN_WEAPON, vol, 110, 0, 175, 0, nil)
			EmitSound(snd, pos, 0, CHAN_AUTO, nearVol, time > 0.6 and 140 or 110, 0, 175, 0, nil)
		else
			EmitSound(watersnd, pos, 0, CHAN_WEAPON, vol, 100, 0, 85, 0, nil)
		end
	end)
end

PrecacheParticleSystem("fire_jet_01")

local ExplosionVignetteMat = Material("effects/shaders/zb_vignette")
hook.Add("Post Post Pre Post Processing", "hg_explosion_vignette", function()
	local vig = hg.GetExplosionVignette and hg.GetExplosionVignette() or 0
	if vig <= 0.001 then return end
	render.UpdateScreenEffectTexture()
	ExplosionVignetteMat:SetFloat("$c2_x", CurTime() + 10000)
	ExplosionVignetteMat:SetFloat("$c0_z", vig * 1.5)
	ExplosionVignetteMat:SetFloat("$c1_y", vig * 3.5)
	render.SetMaterial(ExplosionVignetteMat)
	render.DrawScreenQuad()
end)

hook.Add("PostDrawTranslucentRenderables", "hg_explosion_shockwaves", function(_, skybox)
	if skybox then return end
	local time = CurTime()
	local step = math_pi * 2 / ShockwaveSegments
	render.SetMaterial(ShockwaveMaterial)

	for i = #ExplosionShockwaves, 1, -1 do
		local wave = ExplosionShockwaves[i]
		local radius = (time - wave.StartTime) * wave.Speed
		if radius >= wave.Radius then
			table.remove(ExplosionShockwaves, i)
			continue
		end

		local frac = 1 - radius / wave.Radius
		local drawColor = wave.DrawColor
		drawColor.a = wave.Alpha * frac

		local width = math_max(ShockwaveMinWidth, wave.Thickness * ShockwaveWidthScale) * (0.45 + frac * 0.55)
		local pos = wave.Pos
		local z = pos.z + ShockwaveLift
		local prev = ShockwaveScratchA
		prev:SetUnpacked(pos.x + radius, pos.y, z)

		for segment = 1, ShockwaveSegments do
			local ang = segment * step
			local nextPos = prev == ShockwaveScratchA and ShockwaveScratchB or ShockwaveScratchA
			nextPos:SetUnpacked(pos.x + math_cos(ang) * radius, pos.y + math_sin(ang) * radius, z)
			render.DrawBeam(prev, nextPos, width, 0, 1, drawColor)
			prev = nextPos
		end
	end
end)

net.Receive("hg_booom", function()
	local pos = net.ReadVector()
	local type = net.ReadString()
	local radius = net.ReadFloat()
	local speed = net.ReadFloat()
	local thickness = net.ReadFloat()
	local data = ExplosiveSound[type]
	if not data then return end

	if radius ~= radius or math.abs(radius) == math.huge or radius <= 0 then radius = 100 end
	if speed ~= speed or math.abs(speed) == math.huge or speed <= 0 then speed = 1000 end
	if thickness ~= thickness or math.abs(thickness) == math.huge or thickness <= 0 then thickness = 100 end
	radius = math.Clamp(radius, 1, 50000)
	speed = math.Clamp(speed, 0.001, 50000)
	thickness = math.Clamp(thickness, 0.1, 10000)

	if effectCDCurTime < CurTime() then
		effectPerMSec = 0
	end

	if effectPerMSec < 10 then
		if data.Effect then ParticleEffect(data.Effect, pos, vector_up:Angle()) end
		effectPerMSec = effectPerMSec + 1
		effectCDCurTime = CurTime() + 0.2
	end

	if #ExplosionShockwaves >= ShockwaveMaxCount then
		table.remove(ExplosionShockwaves, 1)
	end

	ExplosionShockwaves[#ExplosionShockwaves + 1] = {
		Pos = pos,
		Radius = radius,
		Speed = speed,
		Thickness = thickness,
		StartTime = CurTime(),
		Alpha = data.ShockwaveColor.a,
		DrawColor = Color(data.ShockwaveColor.r, data.ShockwaveColor.g, data.ShockwaveColor.b, data.ShockwaveColor.a)
	}

	if data.Near and data.Far then PlaySndDist(table.Random(data.Near), table.Random(data.Far), pos, false, "huy") end

	local ply = LocalPlayer()
	if IsValid(ply) and ply:Alive() then
		local dist = ply:EyePos():Distance(pos)
		local arrive = dist / speed
		if dist > radius and arrive > 0.15 and arrive < 10 and PendingWaveShakes < MaxPendingWaveShakes then
			PendingWaveShakes = PendingWaveShakes + 1
			timer.Simple(arrive, function()
				PendingWaveShakes = math_max(PendingWaveShakes - 1, 0)
				local p = LocalPlayer()
				if IsValid(p) and p:Alive() then
					hg.AddWaveShake(14, 0.6)
				end
			end)
		end
	end
end)

net.Receive("hg_gastank_leak", function()
	local ent = net.ReadEntity()
	local localHolePos = net.ReadVector()
	local localNormal = net.ReadVector()
	local mode = net.ReadString()
	if not IsValid(ent) then return end

	local idx = ent:EntIndex()
	local data = GasTankEffects[idx]
	if not data then
		data = {Entity = ent, Leaks = {}, NextReceiveAt = 0}
		GasTankEffects[idx] = data
	end

	if CurTime() < (data.NextReceiveAt or 0) then return end
	data.NextReceiveAt = CurTime() + GasTankLeakReceiveCooldown

	if mode == "fire" and not data.FireSound then
		data.FireSound = CreateSound(ent, "rem_tankfire.mp3")
		if data.FireSound then
			data.FireSound:SetSoundLevel(70)
			data.FireSound:Play()
			data.FireSound:ChangePitch(108, 0)
		end
	end

	if mode == "smoke" and not data.SmokeSound then
		data.SmokeSound = CreateSound(ent, "ambient/gas/cannister_loop.wav")
		if data.SmokeSound then
			data.SmokeSound:SetSoundLevel(65)
			data.SmokeSound:Play()
			data.SmokeSound:ChangePitch(130, 0)
		end
	end

	local holePosWorld = ent:LocalToWorld(localHolePos)
	local normalWorld = (ent:LocalToWorld(localHolePos + localNormal) - holePosWorld):GetNormalized()
	local leakCount = #data.Leaks
	if leakCount >= GasTankMaxVisualLeaks then
		local oldLeak = data.Leaks[1]
		if oldLeak and oldLeak.Dummy and IsValid(oldLeak.Dummy) then
			oldLeak.Dummy:Remove()
		end
		table.remove(data.Leaks, 1)
	end

	local dummy = ClientsideModel("models/props_junk/PopCan01a.mdl", RENDERGROUP_NONE)
	if not IsValid(dummy) then return end
	dummy:SetPos(holePosWorld)
	dummy:SetAngles(normalWorld:Angle())
	dummy:SetParent(ent)
	dummy:SetRenderMode(RENDERMODE_TRANSCOLOR)
	dummy:SetColor(Color(0, 0, 0, 0))

	if mode == "fire" then
		dummy.FireJet = CreateParticleSystem(dummy, "fire_jet_01", PATTACH_ABSORIGIN_FOLLOW, 0)
	end

	table.insert(data.Leaks, {Dummy = dummy, Mode = mode})
end)

net.Receive("hg_gastank_stop", function()
	local entIndex = net.ReadUInt(16)
	local data = GasTankEffects[entIndex]
	if not data then return end
	if data.FireSound then data.FireSound:Stop() end
	if data.SmokeSound then data.SmokeSound:Stop() end
	if istable(data.Leaks) then
		for _, leak in ipairs(data.Leaks) do
			if leak.Dummy and IsValid(leak.Dummy) then
				leak.Dummy:Remove()
			end
		end
	end
	GasTankEffects[entIndex] = nil
end)

hook.Add("Think", "hg_gastank_client_cleanup", function()
	for idx, data in pairs(GasTankEffects) do
		if IsValid(data.Entity) then continue end
		if data.FireSound then data.FireSound:Stop() end
		if data.SmokeSound then data.SmokeSound:Stop() end
		if istable(data.Leaks) then
			for _, leak in ipairs(data.Leaks) do
				if leak.Dummy and IsValid(leak.Dummy) then
					leak.Dummy:Remove()
				end
			end
		end
		GasTankEffects[idx] = nil
	end
end)
