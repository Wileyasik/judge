local Clamp, min, max = math.Clamp, math.min, math.max

resource.AddFile("sound/schizosong1.mp3")
if file.Exists("sound/schizosong2.mp3", "GAME") then resource.AddFile("sound/schizosong2.mp3") end
if file.Exists("sound/schizowhisper.mp3", "GAME") then resource.AddFile("sound/schizowhisper.mp3") end

local lonely_radius = 6000
local lonely_start = 60
local lonely_full = 900
local lonely_gain = 0.002
local decay_time = 1200

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
	org.schizoNextCheck = 0
	org.schizoLonelySince = nil
end)

hook.Add("Org Think", "SchizoThink", function(owner, org, timeValue)
	if not org.isPly then return end
	if org.lastStand then return end
	if not owner:Alive() then return end

	local schizo = org.psycheSchizo or 0
	local now = CurTime()

	if not org.schizoNextCheck or now >= org.schizoNextCheck then
		org.schizoNextCheck = now + 1

		local pos = owner:GetPos()
		local lonely = true
		for _, ent in ipairs(player.GetAll()) do
			if ent ~= owner and ent:Alive() and ent:GetPos():Distance(pos) <= lonely_radius then
				lonely = false
				break
			end
		end

		if lonely then
			org.schizoLonelySince = org.schizoLonelySince or now
		else
			org.schizoLonelySince = nil
		end
	end

	if org.schizoLonelySince then
		local alone = now - org.schizoLonelySince
		local factor = Clamp((alone - lonely_start) / (lonely_full - lonely_start), 0, 1)
		schizo = min(schizo + timeValue * factor * lonely_gain, 1)
	else
		schizo = max(schizo - timeValue / decay_time, 0)
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

	if schizo <= 0.35 then return end

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