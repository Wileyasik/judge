function hg.StunPlayer(ply, time)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	if !IsValid(ply.FakeRagdoll) then hg.Fake(ply) end

	ply.organism.stun = CurTime() + (time or 1)
end

function hg.LightStunPlayer(ply, time)
	if !IsValid(ply) or !ply:IsPlayer() then return end
	if !IsValid(ply.FakeRagdoll) then hg.Fake(ply, nil, true) end

	ply.organism.lightstun = CurTime() + (time or 1)
	ply:SetLocalVar("stun", ply.organism.lightstun)
end

if SERVER then
	util.AddNetworkString("DoPlayerFlinch")
end

hook.Add("ScalePlayerDamage", "FlinchPlayersOnHit", function(ply, grp)
	if !SERVER then return end
	if IsValid(ply) and ply:Alive() then
		local function sequenceActivity(name, fallback)
			local sequence = ply:LookupSequence(name)
			if sequence and sequence >= 0 then
				local activity = ply:GetSequenceActivity(sequence)
				if activity and activity >= 0 then return activity end
			end
			return fallback
		end

		local variants = {
			[HITGROUP_HEAD] = {ACT_FLINCH_HEAD, ACT_FLINCH_PHYSICS},
			[HITGROUP_CHEST] = {ACT_FLINCH_CHEST, ACT_FLINCH_STOMACH, ACT_FLINCH_PHYSICS},
			[HITGROUP_STOMACH] = {ACT_FLINCH_STOMACH, ACT_FLINCH_CHEST, ACT_FLINCH_PHYSICS},
			[HITGROUP_LEFTARM] = {sequenceActivity("flinch_shoulder_l", ACT_FLINCH_LEFTARM), ACT_FLINCH_LEFTARM, ACT_FLINCH_PHYSICS},
			[HITGROUP_RIGHTARM] = {sequenceActivity("flinch_shoulder_r", ACT_FLINCH_RIGHTARM), ACT_FLINCH_RIGHTARM, ACT_FLINCH_PHYSICS},
			[HITGROUP_LEFTLEG] = {sequenceActivity("flinch_01", ACT_FLINCH_LEFTLEG), ACT_FLINCH_LEFTLEG, ACT_FLINCH_PHYSICS},
			[HITGROUP_RIGHTLEG] = {sequenceActivity("flinch_02", ACT_FLINCH_RIGHTLEG), ACT_FLINCH_RIGHTLEG, ACT_FLINCH_PHYSICS}
		}
		local choices = variants[grp] or {ACT_FLINCH_PHYSICS, ACT_FLINCH_STOMACH}
		local group = choices[math.random(#choices)] or ACT_FLINCH_PHYSICS

		net.Start("DoPlayerFlinch")
			net.WriteInt(group, 32)
			net.WriteEntity(ply)
		net.Broadcast()
	end
end)

oldEmitSound = oldEmitSound or EmitSound
local host_timescale = game.GetTimeScale

function host_timescale()
	return game.GetTimeScale()
end

local entMeta = FindMetaTable("Entity")
function EmitSound(soundName, position, entity, channel, volume, soundLevel, soundFlags, pitch, dsp, filter)
	soundName = soundName or ""
	position = position or vectorZero
	entity = entity or 0
	volume = volume or 1
	soundLevel = soundLevel or 75
	soundFlags = soundFlags or 0
	pitch = pitch or 100
	pitch = pitch * host_timescale()
	dsp = dsp or 0
	filter = filter or nil
	oldEmitSound(soundName, position, entity, channel, volume, soundLevel, soundFlags, pitch, dsp, filter)
end

oldEntEmitSound = oldEntEmitSound or entMeta.EmitSound
function entMeta.EmitSound(self, soundName, soundLevel, pitch, volume, channel, soundFlags, dsp, filter)
	soundName = soundName or ""
	position = position or vectorZero
	entity = entity or 0
	volume = volume or 1
	soundLevel = soundLevel or 75
	soundFlags = soundFlags or 0
	pitch = pitch or 100
	pitch = pitch * host_timescale()
	dsp = dsp or 0
	filter = filter or nil
	if IsValid(self) then
		oldEntEmitSound(self, soundName, soundLevel, pitch, volume, channel, soundFlags, dsp, filter)
	end
end

util.AddNetworkString("add_supression")
util.AddNetworkString("hg_bullet_nearmiss")

function hg.ExplosionEffect(pos, dis, dmg)
	net.Start("add_supression")
	net.WriteVector(pos)
	local crf = RecipientFilter()
	for _, ply in ipairs(ents.FindInSphere(pos, 800)) do
		if ply:IsPlayer() then crf:AddPlayer(ply) end
	end
	net.Send(crf)

	local radius = math.Clamp((dis or 0) * 1.5, 300, 4000)
	for _, ply in ipairs(ents.FindInSphere(pos, radius)) do
		if not ply:IsPlayer() or not ply:Alive() or not ply.organism or ply.organism.otrub then continue end

		local center = ply:WorldSpaceCenter()
		local tr = util.TraceLine({
			start = pos,
			endpos = center,
			filter = {ply, hg.GetCurrentCharacter(ply)},
			mask = MASK_SHOT
		})

		local dist = pos:Distance(center)
		if tr.Hit and dist > radius * 0.35 then continue end

		local amount = math.Clamp((1 - dist / radius) * 0.55 + (dmg or 0) / 1200, 0.08, 0.55)
		hg.organism.AddPanicAttack(ply.organism, amount, true)
	end
end

local nearMissShots = {}
function hg.ProcessBulletNearMiss(data)
	local startPos, endPos = data.StartPos, data.EndPos
	local shooter = data.Shooter
	if not isvector(startPos) or not isvector(endPos) or not IsValid(shooter) then return end
	if not shooter:IsPlayer() and IsValid(shooter:GetOwner()) then shooter = shooter:GetOwner() end
	if not shooter:IsPlayer() then return end
	if (data.Speed or 0) <= 340 or startPos:DistToSqr(endPos) < 256 then return end

	local hitPlayer = data.HitEntity
	if IsValid(hitPlayer) and not hitPlayer:IsPlayer() then hitPlayer = hg.RagdollOwner(hitPlayer) end
	local shotPlayers = data.NearMissPlayers
	if not shotPlayers and data.ShotID then
		shotPlayers = nearMissShots[data.ShotID] or {}
		nearMissShots[data.ShotID] = shotPlayers
	end
	local shooterCharacter = hg.GetCurrentCharacter(shooter)
	local traceFilter = {data.Inflictor, nil, nil, shooter, shooterCharacter}
	local traceData = {filter = traceFilter, mask = MASK_SHOT}

	for i, ply in player.Iterator() do
		if ply == shooter or ply == hitPlayer or shotPlayers and shotPlayers[ply] then continue end
		if !ply:Alive() then continue end
		local eyePos = ply:EyePos()
		local dist, pos = util.DistanceToLine(startPos, endPos, eyePos)
		local org = ply.organism
		if not org then continue end
		if dist > 120 then continue end

		traceData.start = pos
		traceData.endpos = eyePos
		traceFilter[2] = ply
		traceFilter[3] = hg.GetCurrentCharacter(ply)
		local isVisible = !util.TraceLine(traceData).Hit

		if !isVisible then continue end

		if !org.otrub then
			local strength = math.Clamp((1 - dist / 120) * (data.Damage or 25) / 45, 0.08, 1)
			ply:AddNaturalAdrenaline(0.035 * strength)
			org.fearadd = org.fearadd + 0.4 * strength
			org.fear = math.max(org.fear, 0.25 + 0.45 * strength)
			hg.organism.AddPanicAttack(org, 0.0004 + strength * 0.0025, true)
			net.Start("hg_bullet_nearmiss")
				net.WriteVector(pos)
				net.WriteFloat(strength)
			net.Send(ply)
			if shotPlayers then shotPlayers[ply] = true end
		end
	end
end

hook.Add("PostEntityFireBullets", "bulletsuppression", function(ent, bullet)
	if ent == Entity(0) or !IsValid(ent) then return end
	local tr = bullet.Trace
	local shooter = IsValid(bullet.Attacker) and bullet.Attacker or ent:GetOwner()
	hg.ProcessBulletNearMiss({
		StartPos = tr.StartPos,
		EndPos = tr.HitPos,
		Shooter = shooter,
		Inflictor = ent,
		HitEntity = tr.Entity,
		Speed = bullet.Speed,
		Damage = bullet.Damage,
		ShotID = bullet.NearMissShotID
	})
end)

timer.Create("hg_nearmiss_cleanup", 1, 0, function()
	table.Empty(nearMissShots)
end)
