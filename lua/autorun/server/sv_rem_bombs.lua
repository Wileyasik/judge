rem_BombQueue = rem_BombQueue or {}
util.AddNetworkString("projectileFarSound")
local queue = rem_BombQueue
local processing = false
local maxPerTick = 2
local maxTargets = 96
local batchSize = 16
local upOffset = Vector(0, 0, 16)
local downAngle = Angle(-90, 0, 0)
local upVector = Vector(0, 0, 1)

local function ApplyForceBatch(list, index)
	if not list or index > #list then return end
	local last = math.min(index + batchSize - 1, #list)
	for i = index, last do
		local entry = list[i]
		if entry and IsValid(entry[1]) then
			entry[1]:ApplyForceCenter(entry[2])
		end
	end
	if last < #list then
		local next = last + 1
		timer.Simple(0, function()
			ApplyForceBatch(list, next)
		end)
	end
end

local function ProcessJob(job)
	if not istable(job) then return end
	local pos = job.Pos
	if not isvector(pos) then return end
	if not util.IsInWorld(pos) then
		if IsValid(job.Ent) then job.Ent:Remove() end
		return
	end
	local radius = math.Clamp(tonumber(job.Radius) or 500, 50, 2000)
	local damage = math.Clamp(tonumber(job.Damage) or 100, 10, 800)
	local owner = IsValid(job.Owner) and job.Owner or game.GetWorld()
	local ent = IsValid(job.Ent) and job.Ent or nil
	local inflictor = ent or owner
	local prof = istable(job.Profile) and job.Profile or {}
	local decal = isstring(prof.Decal) and prof.Decal or "Scorch"
	local traceLen = math.Clamp(tonumber(prof.Trace) or 400, 0, 1000)
	local effect = isstring(prof.Effect) and prof.Effect or ""
	local effectAir = isstring(prof.EffectAir) and prof.EffectAir or effect
	local waterEffect = isstring(prof.EffectWater) and prof.EffectWater or "ins_water_explosion"
	local sound = isstring(prof.Sound) and prof.Sound or ""
	local farSound = isstring(prof.FarSound) and prof.FarSound or ""
	local waterSound = isstring(prof.WaterSound) and prof.WaterSound or ""
	local waterFarSound = isstring(prof.WaterFarSound) and prof.WaterFarSound or ""
	local forceMul = tonumber(prof.Force) or 50000
	local liftMul = tonumber(prof.Lift) or 20000
	local inWater = bit.band(util.PointContents(pos), CONTENTS_WATER) ~= 0
	if inWater then
		if waterEffect ~= "" then
			ParticleEffect(waterEffect, pos, downAngle, nil)
		end
	else
		util.Decal(decal, pos + upOffset, pos - Vector(0, 0, traceLen))
		local groundTrace = util.TraceLine({start = pos, endpos = pos - Vector(0, 0, traceLen), mask = MASK_SOLID_BRUSHONLY})
		local fx = groundTrace.HitWorld and effect or effectAir
		if fx ~= "" then
			ParticleEffect(fx, pos, downAngle, nil)
		end
	end
	local baseIndex = IsValid(inflictor) and inflictor:EntIndex() or 0
	if inWater then
		if waterSound ~= "" then
			EmitSound(waterSound, pos, baseIndex + 100, CHAN_WEAPON, 1, 140, 0, 100)
		end
		if waterFarSound ~= "" and waterFarSound ~= waterSound then
			EmitSound(waterFarSound, pos, baseIndex + 101, CHAN_AUTO, 1, 140, 0, 100)
		end
	else
		if sound ~= "" then
			EmitSound(sound, pos, baseIndex + 100, CHAN_WEAPON, 1, 140, 0, 100)
		end
		if farSound ~= "" then
			EmitSound(farSound, pos, baseIndex + 101, CHAN_AUTO, 1, 140, 0, 100)
		end
	end
	if hg and hg.PlayExtraExplosionSound then
		hg.PlayExtraExplosionSound(pos, baseIndex, 1)
	end
	local farPos = inWater and waterFarSound or farSound
	local nearPos = inWater and waterSound or sound
	if nearPos ~= "" or farPos ~= "" then
		net.Start("projectileFarSound")
			net.WriteString(nearPos)
			net.WriteString(farPos)
			net.WriteVector(pos)
			net.WriteEntity(ent or game.GetWorld())
			net.WriteBool(inWater)
			net.WriteString(waterSound)
		net.Broadcast()
	end
	util.ScreenShake(pos, 20, 150, 1.5, radius * 2)
	util.BlastDamage(inflictor, owner, pos, radius, damage)
	local found = ents.FindInSphere(pos, radius)
	local count = 0
	local pending = {}
	for i = 1, #found do
		if count >= maxTargets then break end
		local v = found[i]
		if not IsValid(v) then continue end
		if v == ent then continue end
		if v.IsRemBomb then continue end
		local vpos = v:IsPlayer() and (v:GetPos() + v:OBBCenter()) or v:GetPos()
		if vpos:DistToSqr(pos) > radius * radius then continue end
		local dist = vpos:Distance(pos)
		local los = util.TraceLine({start = pos, endpos = vpos, mask = MASK_SOLID_BRUSHONLY})
		local frac = math.Clamp((radius - dist) / radius, 0, 1)
		if los.HitWorld then
			frac = frac * 0.2
		end
		if frac <= 0.01 then continue end
		count = count + 1
		local dir = vpos - pos
		if dir:LengthSqr() < 1 then
			dir = Vector(upVector)
		else
			dir:Normalize()
		end
		local force = dir * (frac * forceMul)
		force.z = force.z + frac * liftMul
		if v.organism and hg and hg.ExplosionDisorientation and IsValid(v.organism.owner) and v.organism.owner:IsPlayer() then
			hg.ExplosionDisorientation(v, 5 * frac, 6 * frac)
		end
		if v:IsPlayer() then
			if hg and hg.AddForceRag then
				hg.AddForceRag(v, 0, force * 0.5, 0.5)
				hg.AddForceRag(v, 1, force * 0.5, 0.5)
			end
			if hg and hg.LightStunPlayer then
				hg.LightStunPlayer(v)
			end
		else
			local phys = v:GetPhysicsObject()
			if IsValid(phys) and not IsValid(v:GetParent()) then
				pending[#pending + 1] = {phys, force}
			end
		end
	end
	if #pending > 0 then
		ApplyForceBatch(pending, 1)
	end
	if IsValid(ent) then
		ent:Remove()
	end
end

function rem_QueueExplosion(job)
	if not istable(job) or not isvector(job.Pos) then return end
	queue[#queue + 1] = job
	if processing and not timer.Exists("rem_bomb_queue") then
		processing = false
	end
	if processing then return end
	processing = true
	timer.Create("rem_bomb_queue", 0.05, 0, function()
		if #queue == 0 then
			timer.Remove("rem_bomb_queue")
			processing = false
			return
		end
		for i = 1, maxPerTick do
			local job = table.remove(queue, 1)
			if not job then break end
			ProcessJob(job)
		end
	end)
end

local particleFiles = {
	"particles/doi_explosion_fx.pcf",
	"particles/gb5_1000lb.pcf",
	"particles/gb5_500lb.pcf",
	"particles/gb5_large_explosion.pcf",
	"particles/gb5_high_explosive.pcf",
	"particles/explosion_fx_ins.pcf",
	"particles/gb_water.pcf"
}
for i = 1, #particleFiles do
	game.AddParticles(particleFiles[i])
end
local particleSystems = {
	"doi_stuka_explosion",
	"1000lb_explosion",
	"ins_water_explosion"
}
for i = 1, #particleSystems do
	PrecacheParticleSystem(particleSystems[i])
end
local precacheSounds = {
	"ied/ied_detonate_01.wav",
	"ied/ied_detonate_02.wav",
	"ied/ied_detonate_03.wav",
	"ied/ied_detonate_dist_01.wav",
	"ied/ied_detonate_dist_02.wav",
	"ied/ied_detonate_dist_03.wav",
	"iedins/water/ied_water_detonate_01.wav"
}
for i = 1, #precacheSounds do
	util.PrecacheSound(precacheSounds[i])
end
game.AddDecal("scorch_big", "decals/scorch_big")
