local Clamp, min, max = math.Clamp, math.min, math.max

resource.AddFile("sound/schizosong1.mp3")
if file.Exists("sound/schizosong2.mp3", "GAME") then resource.AddFile("sound/schizosong2.mp3") end
if file.Exists("sound/schizowhisper.mp3", "GAME") then resource.AddFile("sound/schizowhisper.mp3") end

local stress_gain = 0.004
local brain_gain = 0.0025
local drug_gain = 0.006
local decay_time = 1200
local schizo_ramp_speed = 0.01

local schizo_phrases = {
	"Someone is watching you.",
	"They're out there. Waiting.",
	"You saw something move in the shadows.",
	"They know what you did.",
	"That sound didn't come from nowhere.",
	"They're talking about you.",
	"Behind you.",
	"You should not be here alone.",
	"Did you hear them breathing?",
	"They are not who they say they are.",
	"Don't look back. Don't look.",
	"The walls have eyes."
}
local schizo_color = Color(170, 160, 210)

local function schizoThought(owner, msg, delay, key, clr)
	if owner:GetInfoNum("hg_newthoughts", 0) > 0 then
		return owner:Thought(msg, delay, key, 0, clr)
	end
	return owner:Notify(msg, delay, key, 0, nil, clr)
end

local fearGainBase = hg.organism.should_gain_fear
if fearGainBase then
	function hg.organism.should_gain_fear(org)
		if org and (org.psycheSchizo or 0) > 0.35 then return false end
		return fearGainBase(org)
	end
else
	function hg.organism.should_gain_fear(org)
		if org and (org.psycheSchizo or 0) > 0.35 then return false end
		return org and ((org.pain or 0) > 30 or (org.blood or 5000) < 3000 or (org.bleed or 0) > 1)
	end
end

concommand.Add("hg_schizo_test", function(ply, _, args)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:IsAdmin() or not ply.organism then return end

	local org = ply.organism
	if args[1] then
		local val = tonumber(args[1])
		if val then org.psycheSchizo = Clamp(val, 0, 1) end
	end
	local schizo = org.psycheSchizo or 0
	if schizo > 0.35 then
		org.schizoTimer = 0
		org.schizoEpisodeEnd = CurTime() + 6 + schizo * 10
		schizoThought(ply, schizo_phrases[math.random(#schizo_phrases)], math.Rand(12, 18), "psyche_schizo", schizo_color)
	end
	ply.fullsend = true
end)

hook.Add("Org Clear", "SchizoInit", function(org)
	org.psycheSchizo = 0
	org.schizoTimer = 0
	org.schizoEpisodeEnd = 0
	org.schizoLastPhrase = 0
	org.schizoVoiceAt = 0
	org.schizoRelapseAt = CurTime() + math.Rand(480, 900)
	org.schizoRampTarget = nil
end)

local function stressFactor(org)
	local f = 0
	local fear = Clamp(org.fear or 0, 0, 1)
	if fear > 0.6 then f = f + (fear - 0.6) / 0.4 end
	local panic = org.panicattack or 0
	if panic > 0.4 then f = f + Clamp((panic - 0.4) / 0.6, 0, 1) end
	local pain = org.pain or 0
	if pain > 40 then f = f + Clamp((pain - 40) / 60, 0, 1) end
	return Clamp(f, 0, 1)
end

local function brainFactor(org)
	local brain = org.brain or 0
	local o2frac = 0
	if org.o2 and org.o2.range then
		local low = org.o2.range * 0.75
		if org.o2[1] < low then o2frac = Clamp((low - org.o2[1]) / low, 0, 1) end
	end
	local concussion = Clamp((org.concussion or 0) / 2, 0, 1)
	return Clamp(brain * 0.9 + o2frac * 0.7 + concussion * 0.5, 0, 1)
end

local function drugFactor(org)
	if (org.analgesia or 0) > 1.5 or (org.painkiller or 0) > 2.4 then return 1 end
	return 0
end

hook.Add("Org Think", "SchizoThink", function(owner, org, timeValue)
	if not org.isPly then return end
	if org.lastStand then return end

	local schizo = org.psycheSchizo or 0
	local gain = timeValue * (stressFactor(org) * stress_gain + brainFactor(org) * brain_gain + drugFactor(org) * drug_gain)
	schizo = min(schizo + gain, 1)

	local active = (org.fear or 0) > 0.6 or (org.panicattack or 0) > 0.4 or (org.pain or 0) > 40 or (org.brain or 0) > 0.1 or (org.concussion or 0) > 0.5 or (org.o2 and org.o2[1] < org.o2.range * 0.75) or (org.analgesia or 0) > 1.5 or (org.painkiller or 0) > 2.4
	if not active then
		schizo = max(schizo - timeValue / decay_time, 0)
	end

	local rampTarget = org.schizoRampTarget
	if rampTarget then
		schizo = min(schizo + timeValue * schizo_ramp_speed, rampTarget)
		if schizo >= rampTarget then org.schizoRampTarget = nil end
	end
	org.psycheSchizo = schizo

	if schizo > 0.35 then
		if org.stamina then
			org.stamina.regenMul = math.min(org.stamina.regenMul or 1, 1 - schizo * 0.5)
			org.stamina.subadd = (org.stamina.subadd or 0) + schizo * 2 * timeValue
		end
		org.psycheApathy = 0
		org.fearadd = 0
		org.fear = max(0, (org.fear or 0) - timeValue * 2)
	end

	if schizo <= 0.35 then
		if CurTime() >= (org.schizoRelapseAt or 0) then
			org.schizoEpisodeEnd = CurTime() + math.Rand(8, 14)
			org.schizoRampTarget = 0.5 + math.random() * 0.25
			org.schizoTimer = 0
			org.schizoRelapseAt = CurTime() + math.Rand(300, 700)
			schizoThought(owner, "It never really left.", math.Rand(10, 15), "psyche_schizo", schizo_color)
		end
		return
	end

	org.schizoTimer = (org.schizoTimer or 0) + timeValue
	local interval = 120 - schizo * 70
	if org.schizoTimer < interval then return end
	org.schizoTimer = 0
	org.schizoEpisodeEnd = CurTime() + 6 + schizo * 10
	if schizo > 0.45 and CurTime() > (org.schizoLastPhrase or 0) then
		org.schizoLastPhrase = CurTime() + math.Rand(25, 40)
		schizoThought(owner, schizo_phrases[math.random(#schizo_phrases)], math.Rand(12, 18), "psyche_schizo", schizo_color)
	end

	if schizo > 0.6 and CurTime() > (org.schizoVoiceAt or 0) then
		org.schizoVoiceAt = CurTime() + math.Rand(30, 55)
		schizoThought(owner, schizo_phrases[math.random(#schizo_phrases)], math.Rand(10, 15), "psyche_schizo", schizo_color)
	end
end)