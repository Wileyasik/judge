-- пошла поехала ебатория
if !SERVER then return end

MH = MH or {}

AddCSLuaFile("autorun/manhunt_kills_data.lua")
AddCSLuaFile("autorun/client/cl_manhunt_kills.lua")
AddCSLuaFile("entities/mh_anim/shared.lua")
AddCSLuaFile("entities/mh_anim/cl_init.lua")
util.AddNetworkString("mh_close_sound")

local IsValid, CurTime, random = IsValid, CurTime, math.random

local gore_cv = CreateConVar("mh_gore", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
	"Let heads come off (0 keeps them on)")

local debug_cv = CreateConVar("mh_debug", "0", FCVAR_ARCHIVE,
	"Print which execution started")

local npc_cv = CreateConVar("mh_npc", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY,
	"Allow executions on NPCs")

local RANGE = 200
local BEHIND = -0.4		-- бууэээ
local live = {}

local FLESH = {
	"physics/flesh/flesh_squishy_impact_hard1.wav",
	"physics/flesh/flesh_squishy_impact_hard2.wav",
	"physics/flesh/flesh_squishy_impact_hard3.wav",
	"physics/flesh/flesh_squishy_impact_hard4.wav",
	"weapons/knife/knife_hit1.wav",
	"weapons/knife/knife_hit2.wav",
	"weapons/knife/knife_hit3.wav",
	"weapons/knife/knife_hit4.wav"
}

local BLUNT = {
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav"
}

MH.Sounds = {
	Cleaver = { impacts = { FLESH[1], FLESH[2], FLESH[3], FLESH[4], "physics/flesh/flesh_bloody_break.wav" } },
	Knife = { impacts = { FLESH[1], FLESH[2], FLESH[3], FLESH[4] } },
	IceAxe = { impacts = { "weapons/iceaxe/iceaxe_impact1.wav", FLESH[2], "physics/flesh/flesh_bloody_break.wav" } },
	Bat = { impacts = { BLUNT[1], BLUNT[2], BLUNT[3], BLUNT[4], "physics/flesh/flesh_bloody_break.wav" } },
	Hammer = { impacts = { BLUNT[2], BLUNT[3], "physics/flesh/flesh_bloody_break.wav" } },
	Crowbar = { impacts = { "weapons/crowbar/crowbar_impact1.wav", "weapons/crowbar/crowbar_impact2.wav", BLUNT[1] } },
	BlackJack = { impacts = { BLUNT[1], BLUNT[2] } },
	fcnd = { impacts = { FLESH[1], FLESH[2], FLESH[3], FLESH[4] } }
}

local CLOTH = {}
for i = 1, 8 do
	CLOTH[#CLOTH + 1] = string.format("fzk/cloth_movement_sneak_%02d.wav", i)
	CLOTH[#CLOTH + 1] = string.format("fzk/cloth_movement_walk_%02d.wav", i)
end
for i = 1, 5 do
	CLOTH[#CLOTH + 1] = string.format("fzk/me_cloth_sidestep%d.wav", i)
end

local BLADE = { Knife = true, Cleaver = true, IceAxe = true, fcnd = true }

local function famOf(name)
	return string.match(name, "^(%a+)_") or "Bat"
end

local HEAVY = 3
local EXTRA = 0.15
local EXEC_CD = 20		-- откат казней бравлера, сек

local function costOf(ply, wep, k)
	local per = (IsValid(wep) and wep.StaminaPrimary) or 10
	local cost = per * HEAVY * (1 + EXTRA * (#k.blows - 1))

	local org = ply.organism
	local max = org and org.stamina and org.stamina.max
	return max and math.min(cost, max * 0.75) or cost
end

local function stamina(ply)
	local org = ply.organism
	return org and org.stamina and org.stamina[1]
end

local function drain(ply, cost)
	local org = ply.organism
	if !org or !org.stamina then return end
	org.stamina.subadd = (org.stamina.subadd or 0) + cost
end

hook.Add("Should Fake Up", "manhunt_kills_hold", function(ply)
	if (ply.MH_HoldUntil or 0) > CurTime() then return false end
end)

hook.Add("CanControlFake", "manhunt_kills_hold", function(ply)
	if (ply.MH_HoldUntil or 0) > CurTime() then return false end
end)

hook.Add("StartCommand", "manhunt_kills_lock", function(ply, cmd)
	if (ply.MH_HoldUntil or 0) > CurTime() then cmd:ClearButtons() end
end)

local function busy(ent)
	if !IsValid(ent) then return false end

	local ply = ent
	if !ent:IsPlayer() then
		ply = (isfunction(hg.RagdollOwner) and hg.RagdollOwner(ent)) or ent.ply
	end
	return IsValid(ply) and (ply.MH_HoldUntil or 0) > CurTime()
end

hook.Add("ZB_CanLootInventory", "manhunt_kills_noloot", function(ply, ent, canloot)
	if busy(ply) or busy(ent) then return ply, ent, false end
end)

hook.Add("PlayerUse", "manhunt_kills_nouse", function(ply, ent)
	if busy(ply) or busy(ent) then return false end
end)

-- посреди казни парочку не расстрелять :P
hook.Add("EntityTakeDamage", "manhunt_kills_nodamage", function(target, dmginfo)
	if !IsValid(target) then return end
	local ply = target:IsPlayer() and target or (IsValid(target.ply) and target.ply) or target
	if IsValid(ply) and (ply.MH_HoldUntil or 0) > CurTime() then
		local scene = live[ply] or live[target]
		if scene and scene.finishing then return end
		return true
	end
end)

local function validSound(s)
	if !isstring(s) or s == "" then return end
	if file.Exists("sound/" .. s, "GAME") or file.Exists(s, "GAME") then return s end
	if string.find(s, "/") or string.find(s, "hmcd") then return s end
	if isfunction(sound.GetProperties) then
		local ok, p = pcall(sound.GetProperties, s)
		if ok and p then return s end
	end
end

local function pickSound(tbl)
	if istable(tbl) then
		for i = 1, #tbl do
			local s = validSound(tbl[i])
			if s then return s end
		end
		return
	end
	return validSound(tbl)
end

local function hitSound(wep, fam)
	if IsValid(wep) then
		local s = pickSound(wep.AttackHitFlesh) or pickSound(wep.AttackHit)
		if s then return s end
	end
	local set = MH.Sounds[fam] and MH.Sounds[fam].impacts
	if set then return set[random(#set)] end
	return (BLADE[fam] and FLESH or BLUNT)[random(#set or BLUNT)]
end

local function close(scene, snd, pitch)
	local who = {}
	if IsValid(scene.killer) then who[#who + 1] = scene.killer end
	if IsValid(scene.victim) and scene.victim:IsPlayer() then who[#who + 1] = scene.victim end
	if #who == 0 then return end

	net.Start("mh_close_sound")
		net.WriteString(snd)
		net.WriteUInt(pitch or 100, 8)
	net.Send(who)
end

local function rustle(scene)
	local ent = IsValid(scene.vbody) and scene.vbody or scene.victim
	if !IsValid(ent) then return end

	local snd, pitch = CLOTH[random(#CLOTH)], random(95, 105)
	close(scene, snd, pitch)
	sound.Play(snd, ent:GetPos() + Vector(0, 0, 40), 95, pitch, 1)
end

-- голоса жертв: painSounds из аддона judge. Подбор как в sv_phrases:
-- пол через ThatPlyIsFemale, питч через VoicePitch, канал CHAN_VOICE.
local VOICES = {
	male = { "painSounds/bigPain1.mp3", "painSounds/bigPain2.mp3", "painSounds/bigPain3.mp3",
		"painSounds/bigPain4.mp3", "painSounds/bigPain5.mp3", "painSounds/bigPain6.mp3", "painSounds/bigPain7.mp3" },
	female = { "painSounds/bigFemalePain1.mp3", "painSounds/bigFemalePain2.mp3",
		"painSounds/bigFemalePain3.mp3", "painSounds/bigFemalePain4.mp3" },
	choke = { "painSounds/choking1.mp3", "painSounds/choking2.mp3", "painSounds/choking3.mp3",
		"painSounds/choking4.mp3", "painSounds/choking5.mp3", "painSounds/choking6.mp3",
		"painSounds/choking7.mp3", "painSounds/choking8.mp3", "painSounds/choking9.mp3",
		"painSounds/choking10.mp3", "painSounds/choking11.mp3", "painSounds/choking12.mp3",
		"painSounds/choking13.mp3", "painSounds/choking14.mp3" },
	fiber = { "painSounds/fiberWire1.mp3", "painSounds/fiberWire2.mp3" }
}

local function voiceAt(scene, set, level, cutoff)
	local v = scene.victim
	if !IsValid(v) or !v:IsPlayer() then return end
	if (v.MH_NextVoice or 0) > CurTime() then return end

	local snd = validSound(set[random(#set)])
	if !snd then return end

	local pitch = math.Clamp((v.VoicePitch or 100) + random(-3, 3), 85, 115)
	local ent = IsValid(scene.vbody) and scene.vbody or v
	ent:EmitSound(snd, level or 80, pitch, 1, CHAN_VOICE)
	close(scene, snd, pitch)

	if cutoff then
		timer.Simple(cutoff, function()
			if IsValid(ent) then ent:StopSound(snd) end
		end)
	end

	v.MH_NextVoice = CurTime() + 0.9
end

-- крик от удара; cutoff обрывает его (шею свернули - крик оборвался)
local function scream(scene, cutoff)
	local v = scene.victim
	if !IsValid(v) or !v:IsPlayer() then return end

	local set = (isfunction(ThatPlyIsFemale) and ThatPlyIsFemale(v)) and VOICES.female or VOICES.male
	voiceAt(scene, set, 80, cutoff)
end

-- артериальный фонтан из раны
local function jet(scene, bone, dur, scale)
	local v = scene.victim
	if !IsValid(v) then return end

	local t = "mh_jet_" .. v:EntIndex()
	timer.Create(t, 0.12, math.max(math.ceil(dur / 0.12), 1), function()
		local ent = IsValid(scene.vbody) and scene.vbody or scene.victim
		if !IsValid(ent) then return end

		local b = ent:LookupBone("ValveBiped.Bip01_" .. (bone or "Neck1"))
		local at = (b and ent:GetBonePosition(b)) or (ent:GetPos() + Vector(0, 0, 55))

		local ed = EffectData()
		ed:SetOrigin(at)
		ed:SetNormal(Vector(random(-15, 15), random(-15, 15), 60):GetNormalized())
		ed:SetScale(scale or 5)
		ed:SetFlags(3)
		util.Effect("BloodImpact", ed)
	end)
	scene.timers[#scene.timers + 1] = t
end

local NECK_SND = "bones/bone7.mp3"
local BONES = {}
for i = 1, 8 do BONES[i] = "bones/bone" .. i .. ".mp3" end

local BLUNT_FAM = { Hammer = true }

local function orgOf(scene)
	return IsValid(scene.victim) and scene.victim.organism
end

local function spot(scene, bone)
	local ent = IsValid(scene.vbody) and scene.vbody or scene.victim
	if !IsValid(ent) then return end

	local b = ent:LookupBone("ValveBiped.Bip01_" .. (bone or "Head1"))
	return (b and ent:GetBonePosition(b)) or (ent:GetPos() + Vector(0, 0, 55)), ent
end

local function snap(scene, bone, snd)
	local at, ent = spot(scene, bone)
	if !at then return end

	local pitch = random(94, 102)
	snd = snd or BONES[random(#BONES)]
	sound.Play(snd, at, 100, pitch, 1)
	ent:EmitSound(snd, 100, pitch, 1, CHAN_ITEM)
	close(scene, snd, pitch)

	local k = IsValid(scene.killer) and scene.killer:GetActiveWeapon()
	if IsValid(k) then sound.Play(hitSound(k, famOf(scene.name)), at, 90, random(94, 102), 1) end
end

local function gore(scene, bone, scale)
	local at, ent = spot(scene, bone)
	if !at then return end

	local ed = EffectData()
	ed:SetOrigin(at)
	ed:SetScale(scale or 4)
	ed:SetFlags(3)
	util.Effect("BloodImpact", ed)
	util.Decal("Blood", at, at - Vector(random(-20, 20), random(-20, 20), 80), ent)
end

local function hurt(scene, amount, dtype, bone)
	local body, victim = scene.vbody, scene.victim
	if !IsValid(body) or !IsValid(victim) or !victim:Alive() then return end

	local into = victim:IsPlayer() and body or victim

	if !victim:IsPlayer() then amount = math.min(amount, math.max(victim:Health() - 1, 0)) end

	local killer = scene.killer
	local dmg = DamageInfo()
	dmg:SetAttacker(IsValid(killer) and killer or game.GetWorld())
	dmg:SetInflictor(IsValid(killer) and killer or game.GetWorld())
	dmg:SetDamage(amount)
	dmg:SetDamageType(dtype or DMG_CLUB)
	dmg:SetDamagePosition(spot(scene, bone) or body:GetPos())

	scene.letpass = true
	into:TakeDamageInfo(dmg)
	scene.letpass = nil
end

local function doom(scene)
	scene.doomed = true
end

local KNOCK = { weapon_hg_sledgehammer = true }

local function knockout(scene)
	local org = orgOf(scene)
	if !org then return end

	org.otrub = true
	org.disorientation = math.max(org.disorientation or 0, 15)
end

local function wound(scene, bone)
	local victim = scene.victim
	if !IsValid(victim) or !victim.organism then return end

	local org = victim.organism
	local fam = famOf(scene.name)
	local blade = BLADE[fam]

	if !BLUNT_FAM[fam] and isfunction(hg.organism.AddWoundManual) then
		hg.organism.AddWoundManual(victim, blade and random(60, 120) or random(15, 30),
			vector_origin, angle_zero, "ValveBiped.Bip01_" .. bone, CurTime())
	end

	if org then
		org.painadd = math.min((org.painadd or 0) + (blade and 12 or 20), 150)
		org.shock = math.min((org.shock or 0) + (blade and 4 or 6), 95)
	end

	hurt(scene, blade and 25 or 35, blade and DMG_SLASH or DMG_CLUB, bone)
end

local EV = {}

EV.stun = knockout

EV.kill = doom

-- шею свернули :(
EV.neck = function(scene)
	snap(scene, "Neck1", NECK_SND)

	local org = orgOf(scene)
	if org then org.spine1 = 1 end

	knockout(scene)
	doom(scene)
end

EV.behead = function(scene)
	snap(scene, "Neck1")
	snap(scene, "Neck1", "physics/flesh/flesh_bloody_break.wav")
	gore(scene, "Neck1", 14)

	local org = orgOf(scene)
	if org then org.spine1 = 1 end

	knockout(scene)
	doom(scene)
end

EV.gib = function(scene)
	local v = scene.victim
	if !IsValid(v) or v.noHead or !isfunction(hg.ExplodeHead) then return end
	if !gore_cv:GetBool() then knockout(scene) return end

	hg.ExplodeHead(v)
	snap(scene, "Head1", "physics/flesh/flesh_bloody_break.wav")
	gore(scene, "Head1", 12)
end

EV.skull = function(scene)
	snap(scene, "Head1")
	snap(scene, "Head1", "physics/flesh/flesh_bloody_break.wav")
	gore(scene, "Head1", 6)

	-- лом сидит в мозгах, тут уже не организм решает, а лом))
	local org = orgOf(scene)
	if org then
		org.skull = 1
		org.brain = 1
	end

	knockout(scene)
	doom(scene)
end

EV.jaw = function(scene)
	snap(scene, "Head1")

	local org = orgOf(scene)
	if org then org.jaw = 1 end
	hurt(scene, 20, DMG_CLUB, "Head1")
end

EV.spine = function(scene)
	snap(scene, "Spine2")

	local org = orgOf(scene)
	if org then org.spine2 = 1 end

	knockout(scene)
	hurt(scene, 25, DMG_CLUB, "Spine2")
end

EV.chest = function(scene)
	snap(scene, "Spine2")

	local org = orgOf(scene)
	if org then
		org.chest = 1
		if random(2) == 1 then org.spine2 = 1 end		-- иногда прилет и по хребту
	end

	hurt(scene, 30, DMG_CLUB, "Spine2")
end

EV.gut = function(scene)
	local org = orgOf(scene)
	if org then org.internalBleed = (org.internalBleed or 0) + 12 end

	hurt(scene, 20, DMG_CLUB, "Spine1")
end

EV.bleed = function(scene, ev)
	local bone = ev.bone or "Neck1"
	local v = scene.victim
	if IsValid(v) and v.organism and isfunction(hg.organism.AddWoundManual) then
		hg.organism.AddWoundManual(v, random(70, 110), vector_origin, angle_zero,
			"ValveBiped.Bip01_" .. bone, CurTime())
	end

	sound.Play(FLESH[random(4)], spot(scene, bone) or vector_origin, 85, random(90, 105), 1)
	gore(scene, bone, 8)
end

-- вскрытая шея (carotid). Идёт "насквозь", как при реальном порезе.
EV.neckslit = function(scene)
	local v = scene.victim
	if !IsValid(v) or !v.organism then return end

	local org = v.organism

	local bone = "Neck1"
	snap(scene, bone, "snd_jack_hmcd_knifestab.wav")
	gore(scene, bone, 14)

	-- фейк-кровь/порез как в organism: carotid артерия "артерия" на шее
	org.neckslit = true
	org.needfake = true

	if isfunction(hg.organism.AddWoundManual) then
		hg.organism.AddWoundManual(v, random(80, 120), vector_origin, angle_zero,
			"ValveBiped.Bip01_" .. bone, CurTime() + 3)
	end

	-- реальная артериальная рана шеи (Чтобы организм разгонял кровопотерю сам)
	if isfunction(hg.organism.AddBleedSource) then
		local wound = { 14, vector_origin, angle_zero, "ValveBiped.Bip01_" .. bone, CurTime(), Vector(0, 0, -1), "arteria" }
		org.arterialwounds = org.arterialwounds or {}
		table.insert(org.arterialwounds, wound)
		hg.organism.AddBleedSource(org, "arterial", 14, "arteria", "ValveBiped.Bip01_" .. bone, wound)
		v:SetNetVar("arterialwounds", org.arterialwounds)
	end

	-- Текущий персонаж (рагдолл жертвы) насильно фейкается, чтобы neckslit-логика работала
	if isfunction(hg.Fake) and v:IsPlayer() and IsValid(v) and v:Alive() then
		if !IsValid(v.FakeRagdoll) then hg.Fake(v) end
	end

	hurt(scene, 30, DMG_SLASH, bone)
	doom(scene)
end

EV.tear = function(scene, ev)
	local bone = ev.bone or "Neck1"
	local dur = math.max((ev.till or 0) - ev.t, 0.3)
	local t = "mh_tear_" .. scene.killer:EntIndex()

	timer.Create(t, 0.25, math.max(math.ceil(dur / 0.25), 1), function()
		local v = scene.victim
		if !IsValid(v) or !v.organism then timer.Remove(t) return end

		if isfunction(hg.organism.AddWoundManual) then
			hg.organism.AddWoundManual(v, random(25, 45), vector_origin, angle_zero,
				"ValveBiped.Bip01_" .. bone, CurTime())
		end

		sound.Play(FLESH[random(#FLESH)], spot(scene, bone) or vector_origin, 80,
			random(85, 100), 0.9)
		gore(scene, bone, 5)
	end)

	scene.timers[#scene.timers + 1] = t
end

EV.choke = function(scene, ev)
	local org = orgOf(scene)
	if !org or !org.o2 then return end

	local from = org.o2[1] or 0
	local dur = math.max((ev.till or 0) - ev.t, 0.5)
	local start = CurTime()
	local t = "mh_choke_" .. scene.killer:EntIndex()

	timer.Create(t, 0.1, math.ceil(dur / 0.1) + 1, function()
		local o = orgOf(scene)
		if !o or !o.o2 then timer.Remove(t) return end

		local f = math.Clamp((CurTime() - start) / dur, 0, 1)
		o.o2[1] = math.min(o.o2[1] or from, from * (1 - f))
		o.o2.regen = 0
		o.o2.curregen = 0
	end)

	scene.timers[#scene.timers + 1] = t
end

local function fire(scene, ev)
	if ev.chance and math.Rand(0, 1) > ev.chance then
		local alt = ev.alt and EV[ev.alt]
		if alt then alt(scene, ev) end
		return
	end

	local f = EV[ev.k]
	if f then f(scene, ev) end
end

local function thud(scene, swing, bone, ev)
	if ev then fire(scene, ev) return end

	local ent = IsValid(scene.vbody) and scene.vbody or scene.victim
	if !IsValid(ent) then return end

	local pos = ent:GetPos() + Vector(0, 0, 45)
	local b = ent:LookupBone("ValveBiped.Bip01_" .. (bone or "Spine2"))
	if b then pos = ent:GetBonePosition(b) or pos end

	local wep = IsValid(scene.killer) and scene.killer:GetActiveWeapon()
	local fam = famOf(scene.name)

	if swing then
		local snd = (IsValid(wep) and (validSound(wep.AttackSwing) or validSound(wep.SwingSound))) or "weapons/iceaxe/iceaxe_swing1.wav"
		sound.Play(snd, pos, 70, random(95, 105), 1)
		return
	end

	local snd = hitSound(wep, fam)
	sound.Play(snd, pos, 85, random(92, 108), 1)
	ent:EmitSound(snd, 85, random(92, 108), 1, CHAN_AUTO)

	if BLADE[fam] then
		sound.Play(FLESH[random(#FLESH)], pos, 80, random(90, 110), 0.9)
	end

	if !BLUNT_FAM[fam] then gore(scene, bone or "Spine2", 2) end

	wound(scene, bone or "Spine2")
	if scene.knock then knockout(scene) end

end

local function loose(rag, on)
	if !IsValid(rag) then return end

	-- ТЫ ЧЕ ОБОСРАЛСЯ ЧТО-ЛИ МУДАК БЛЯТЬ, НАЧАЛЬНИК ОН ОБОСРАЛСЯ
	rag.LootingDisabled = on or nil

	if on then
		rag.MH_Group = rag.MH_Group or rag:GetCollisionGroup()
		rag:SetCollisionGroup(COLLISION_GROUP_WORLD)
	else
		rag:SetCollisionGroup(rag.MH_Group or COLLISION_GROUP_WEAPON)
		rag.MH_Group = nil
	end
end

-- начальник, я обосрался
local function down(ply, pos, ang, dur)
	ply:SetPos(pos)
	ply:SetEyeAngles(ang)
	ply.illbeback = ply.illbeback or 0

	if !IsValid(ply.FakeRagdoll) then hg.Fake(ply) end
	ply.MH_HoldUntil = CurTime() + dur
	ply:SetNWFloat("MH_Kill", CurTime() + dur)

	if isfunction(hg.SetFreemove) then
		hg.SetFreemove(ply, false)
	else
		ply:SetMoveType(MOVETYPE_NOCLIP)
	end
	loose(ply.FakeRagdoll, true)

	return ply.FakeRagdoll
end

local function humanoid(ent)
	return IsValid(ent) and ent:IsNPC() and ent:LookupBone("ValveBiped.Bip01_Spine") != nil
end

local function downNPC(npc, pos, ang, dur)
	local rag = ents.Create("prop_ragdoll")
	if !IsValid(rag) then return end

	rag:SetModel(npc:GetModel())
	rag:SetSkin(npc:GetSkin())
	rag:SetPos(pos)
	rag:SetAngles(ang)
	rag:Spawn()

	for i = 0, #rag:GetBodyGroups() - 1 do
		rag:SetBodygroup(i, npc:GetBodygroup(i))
	end

	npc.MH_HoldUntil = CurTime() + dur
	npc:SetNoDraw(true)
	npc:SetSolid(SOLID_NONE)
	npc:SetMoveType(MOVETYPE_NONE)
	npc:AddFlags(FL_NOTARGET)
	if npc.SetSchedule then npc:SetSchedule(SCHED_NONE) end

	loose(rag, true)
	return rag
end

local function animator(pos, ang, seq, rag, model)
	local e = ents.Create("mh_anim")
	e:SetPos(pos)
	e:SetAngles(ang)
	e:Spawn()
	if model then
		util.PrecacheModel(model)
		e:SetModel(model)
	end
	if !e:Play(seq) then e:Remove() return end
	e:Drive(rag)
	return e
end

local function finish(scene, kill)
	scene.finishing = true

	for _, e in ipairs(scene.anims) do
		if IsValid(e) then e:Remove() end
	end
	if IsValid(scene.nocollide) then scene.nocollide:Remove() end
	for _, t in ipairs(scene.timers) do timer.Remove(t) end
	for who, s in pairs(live) do
		if s == scene then live[who] = nil end
	end

	local killer = scene.killer
	if IsValid(killer) then
		killer.MH_HoldUntil = nil
		killer:SetNWFloat("MH_Kill", 0)
		loose(scene.kbody, false)

		if killer:Alive() then
			local want, was = scene.ang, killer.LastFakeUp
			hg.FakeUp(killer)

			local t = "mh_face_" .. killer:EntIndex()
			timer.Create(t, 0.05, 40, function()
				if !IsValid(killer) then timer.Remove(t) return end
				if killer.LastFakeUp != was then
					killer:SetEyeAngles(want)
					timer.Remove(t)
				end
			end)
		end
	end

	local victim = scene.victim
	if !IsValid(victim) then return end
	victim.MH_HoldUntil = nil

	if !victim:IsPlayer() then
		loose(scene.vbody, false)
		if !kill then
			if IsValid(scene.vbody) then scene.vbody:Remove() end
			victim:SetNoDraw(false)
			victim:SetSolid(SOLID_BBOX)
			victim:SetMoveType(MOVETYPE_STEP)
			victim:RemoveFlags(FL_NOTARGET)
			return
		end

		local wep = IsValid(killer) and killer:GetActiveWeapon()
		local dmg = DamageInfo()
		dmg:SetAttacker(IsValid(killer) and killer or game.GetWorld())
		dmg:SetInflictor(IsValid(wep) and wep or (IsValid(killer) and killer or game.GetWorld()))
		dmg:SetDamage(1000)
		dmg:SetDamageType(DMG_SLASH)
		dmg:SetDamagePosition(IsValid(scene.vbody) and scene.vbody:GetPos() or victim:GetPos())

		scene.letpass = true
		victim:TakeDamageInfo(dmg)
		scene.letpass = nil

		local own = victim.GetRagdollEntity and victim:GetRagdollEntity()
		if IsValid(own) then own:Remove() end
		if IsValid(victim) then victim:Remove() end
		return
	end

	victim:SetNWFloat("MH_Kill", 0)
	loose(scene.vbody, false)

	if !kill then
		if victim:Alive() then hg.FakeUp(victim) end
		return
	end

	local body, parts = scene.vbody, MH.Kills[scene.name] and MH.Kills[scene.name].parts
	local blade = BLADE[famOf(scene.name)]

	timer.Simple(0.1, function()
		if !IsValid(victim) or !victim:Alive() or !IsValid(body) then return end

		local wep = IsValid(killer) and killer:GetActiveWeapon()
		local dmg = DamageInfo()
		dmg:SetAttacker(IsValid(killer) and killer or game.GetWorld())
		dmg:SetInflictor(IsValid(wep) and wep or (IsValid(killer) and killer or game.GetWorld()))
		dmg:SetDamage(1000)
		dmg:SetDamageType(blade and DMG_SLASH or DMG_CLUB)

		local last = parts and parts[#parts] or "Neck1"
		local b = body:LookupBone("ValveBiped.Bip01_" .. last)
		dmg:SetDamagePosition(b and body:GetBonePosition(b) or body:GetPos())

		-- решает организм
		body:TakeDamageInfo(dmg)
	end)
end

hook.Add("PlayerDeath", "manhunt_kills_dead", function(ply)
	local scene = live[ply]
	if !scene then return end

	timer.Simple(0.05, function()
		if live[ply] != scene then return end

		local ours = scene.victim == ply and scene.vbody or scene.kbody
		local now = isfunction(hg.GetCurrentCharacter) and hg.GetCurrentCharacter(ply)
		if IsValid(now) and IsValid(ours) and now != ours then finish(scene, false) end
	end)
end)

function MH.Play(killer, victim, name)
	-- подроль traitor_brawler определяется в аддоне judge, казни доступны только ей
	if killer.SubRole != "traitor_brawler" then return false, "only the brawler can do executions" end
	if (killer.MH_ExecCD or 0) > CurTime() then return false, "execution is on cooldown (" .. math.ceil(killer.MH_ExecCD - CurTime()) .. "s)" end

	local k = MH.Kills[name]
	if !k then return false, "no such kill: " .. tostring(name) end
	if live[killer] then return false, "already busy with someone" end
	if !isfunction(hg.Fake) then return false, "this gamemode has no hg.Fake" end

	for _, s in pairs(live) do
		if s.victim == victim then return false, "he is already being executed" end
	end

	local wep = killer:GetActiveWeapon()
	local cost = costOf(killer, wep, k)
	local have = stamina(killer)
	if have and have < cost then return false, "out of breath" end

	local ang = Angle(0, killer:EyeAngles().yaw, 0)
	local pos = killer:GetPos()
	local dur = k.len + 0.5

	local kbody = down(killer, pos, ang, dur)
	local vbody = victim:IsPlayer() and down(victim, pos, ang, dur)
		or downNPC(victim, pos, ang, dur)
	if !IsValid(kbody) or !IsValid(vbody) then return false, "could not put them down" end

	local nocollide = constraint.NoCollide(kbody, vbody, 0, 0)
	local amodel = k.amodel or MH.MODEL
	local vmodel = k.vmodel or MH.MODEL
	local vseq = (k.bsmod and name) or ("Damage_" .. name)
	local ka = animator(pos, ang, name, kbody, amodel)
	local va = animator(pos, ang, vseq, vbody, vmodel)

	if !ka or !va then
		if IsValid(nocollide) then nocollide:Remove() end
		if IsValid(ka) then ka:Remove() end
		if IsValid(va) then va:Remove() end
		return false, "no sequences in " .. MH.MODEL
	end

	local id = killer:EntIndex()
	local scene = {
		killer = killer, victim = victim,
		kbody = kbody, vbody = vbody,
		anims = { ka, va }, nocollide = nocollide,
		name = name, ang = ang,
		knock = KNOCK[IsValid(wep) and wep:GetClass() or ""],
		timers = { "mh_hit_" .. id, "mh_end_" .. id }
	}

	-- хрупкое оружие (бутылка/осколок/кружка) ломается при казни, а осколок режет руку исполнителя
	local glassClass = IsValid(wep) and (wep:GetClass() == "weapon_hg_bottlebroken" or wep:GetClass() == "weapon_hg_glassshard" or wep:GetClass() == "weapon_hg_mug" or wep:GetClass() == "weapon_hg_bottle") and wep:GetClass() or nil
	if(glassClass)then
		scene.glassWeapon = wep
		scene.glassClass = glassClass
	end

	live[killer] = scene
	live[victim] = scene
	drain(killer, cost)

	timer.Create(scene.timers[1], k.hit, 1, function()
		if IsValid(va) and not k.bsmod then va:Play("Die_" .. name) end

		if scene.glassWeapon then
			local gw = scene.glassWeapon
			if(IsValid(gw))then
				gw:PrecacheGibs()

				local owner = gw:GetOwner()
				local origin = IsValid(owner) and owner:GetPos() or (IsValid(vbody) and vbody:GetPos() or vector_origin)

				gw:GibBreakServer(Vector(0, 0, -100))
				sound.Play("physics/glass/glass_pottery_break" .. math.random(1, 4) .. ".wav", origin, 80, math.random(95, 105), 1)

				-- осколок впивается в руку атакующего
				if(scene.glassClass == "weapon_hg_glassshard" and IsValid(owner) and owner.organism and isfunction(hg.organism.AddWoundManual))then
					hg.organism.AddWoundManual(owner, 20, vector_origin, angle_zero,
						"ValveBiped.Bip01_R_Hand", CurTime() + 1800)
					if(owner.Notify)then owner:Notify("The glass shard cut my hand!..", 30) end
				end

				gw:Remove()
			end
			scene.glassWeapon = nil
		end
	end)
	timer.Create(scene.timers[2], k.len, 1, function() finish(scene, true) end)

	local marks = {}
	for i, at in ipairs(k.blows) do
		local bone = k.parts and k.parts[i] or "Spine2"
		marks[#marks + 1] = { t = math.max(at - 0.15, 0.05), swing = true, bone = bone }
		marks[#marks + 1] = { t = at, swing = false, bone = bone }
	end
	for _, ev in ipairs(k.events or {}) do
		marks[#marks + 1] = { t = ev.t, ev = ev }
	end

	ka:HitsAt(marks, function(_, swing, bone, ev) thud(scene, swing, bone, ev) end)
	if k.cloth then ka:ClothAt(k.cloth, function() rustle(scene) end) end

	killer.MH_ExecCD = CurTime() + EXEC_CD

	return true
end

local function pick(ply, want)
	if want and want != "" then
		if MH.Kills[want] then return want end
		for _, n in ipairs(table.GetKeys(MH.Kills)) do
			if string.find(string.lower(n), string.lower(want), 1, true) then return n end
		end
		return nil, "no kill matching " .. want
	end

	local wep = ply:GetActiveWeapon()
	if !IsValid(wep) then return nil, "nothing in your hands" end

	local cls = wep:GetClass()
	local set = {}

	for _, n in ipairs((MH.KillsFor and MH.KillsFor[cls]) or {}) do
		if MH.Kills[n] then set[#set + 1] = n end
	end

	if #set == 0 then
		local fams = MH.ByWeapon[cls] or (MH.GuessFams and MH.GuessFams(cls))
		if !fams then return nil, "you cannot finish anyone with that" end

		for _, fam in ipairs(fams) do
			for n in pairs(MH.Kills) do
				if string.StartWith(n, fam .. "_") then set[#set + 1] = n end
			end
		end
	end
	if #set == 0 then return nil, "no kills compiled for that weapon" end

	local have = stamina(ply)
	if have then
		local can = {}
		for _, n in ipairs(set) do
			if costOf(ply, wep, MH.Kills[n]) <= have then can[#can + 1] = n end
		end
		if #can == 0 then return nil, "out of breath" end
		set = can
	end

	return set[random(#set)]
end

-- способность Бравлера в judge вызывает MH.PickKill
MH.PickKill = pick

local function aimAt(ply)
	local function whois(e)
		if !IsValid(e) then return end
		if !e:IsPlayer() and isfunction(hg.RagdollOwner) then e = hg.RagdollOwner(e) or e end
		if IsValid(e) and e != ply and (e:IsPlayer() or humanoid(e)) then return e end
	end

	local hit = whois(ply:GetEyeTrace().Entity)
	if hit then return hit end

	local eye, aim = ply:EyePos(), ply:GetAimVector()
	local best, dot = nil, 0.75

	for _, e in ipairs(ents.FindInSphere(eye, RANGE)) do
		local who = whois(e)
		if who then
			local d = who:WorldSpaceCenter() - eye
			local len = d:Length()
			if len > 1 and aim:Dot(d / len) > dot then best, dot = who, aim:Dot(d / len) end
		end
	end

	return best
end

concommand.Add("mh_kill", function(ply, _, args)
	if !IsValid(ply) or !ply:Alive() then return end

	local w = ply:GetActiveWeapon()
	local cls = IsValid(w) and w:GetClass() or ""
	local wstore = IsValid(w) and weapons.GetStored(cls)
	local melee = IsValid(w) and (cls == "weapon_hg_fists" or (wstore and wstore.Category == "Weapons - Melee"))
	if !melee then ply:ChatPrint("need a melee weapon") return end

	local target = aimAt(ply)
	if !IsValid(target) then ply:ChatPrint("aim at a player") return end

	local isnpc = humanoid(target)
	if isnpc and !npc_cv:GetBool() then ply:ChatPrint("NPC executions are off") return end
	if target == ply or target:GetPos():Distance(ply:GetPos()) > RANGE then
		ply:ChatPrint("too far")
		return
	end

	-- лежачего не бьют, суки!
	local org = target.organism
	if !target:Alive() or (org and org.otrub) then
		ply:ChatPrint("he is out cold already")
		return
	end

	local behind = ply:GetPos() - target:GetPos()
	behind.z = 0
	if behind:LengthSqr() > 1 and behind:GetNormalized():Dot(Angle(0, target:EyeAngles().yaw, 0):Forward()) > BEHIND then
		ply:ChatPrint("get behind him")
		return
	end

	local name, why = pick(ply, args[1])
	if !name then ply:ChatPrint(why or "no kill") return end

	local ok, err = MH.Play(ply, target, name)
	if !ok then ply:ChatPrint(err) return end
	if debug_cv:GetBool() then ply:ChatPrint(name) end
end)

concommand.Add("mh_kill_list", function(ply)
	for _, n in ipairs(table.GetKeys(MH.Kills)) do
		if IsValid(ply) then ply:PrintMessage(HUD_PRINTCONSOLE, n) else print(n) end
	end
end)

hook.Add("Initialize", "manhunt_kills_check", function()
	if !file.Exists(MH.MODEL, "GAME") then
		ErrorNoHalt("[manhunt] missing " .. MH.MODEL .. " - addon is not mounted, check the models folder\n")
	end
end)

hook.Add("PlayerDisconnected", "manhunt_kills_cleanup", function(ply)
	for killer, scene in pairs(live) do
		if killer == ply or scene.victim == ply then finish(scene, false) end
	end
end)
