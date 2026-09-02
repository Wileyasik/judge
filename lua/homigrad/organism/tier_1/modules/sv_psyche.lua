local Clamp, min, max, Approach = math.Clamp, math.min, math.max, math.Approach

hg.organism.module.psyche = {}
local module = hg.organism.module.psyche

local anger_gain_damage = 0.006
local anger_gain_flat = 0.05
local anger_memory_time = 8
local anger_decay = 60
local anger_decay_fast = 18
local anger_pain_resist = 0.25
local apathy_pain_start = 35
local apathy_pain_speed = 90
local apathy_blood_start = 3400
local apathy_blood_speed = 150
local apathy_otrub_speed = 220
local apathy_fear_start = 0.6
local apathy_fear_speed = 150
local apathy_decay = 180
local apathy_decay_comfort = 60
local apathy_fear_cap = 0.4
local apathy_witness_radius = 700
local apathy_witness_gain = 0.25
local apathy_kill_relief = 0.2
local desens_cap = 20

local anger_phrases = {
	"You feel your blood boiling.",
	"Your hands are shaking with rage.",
	"You want to hurt something. Anything.",
	"A red haze creeps into the edges of your vision.",
	"Your teeth are clenched so hard it hurts.",
	"You can barely think straight anymore.",
	"Every sound they make infuriates you.",
	"You are going to make them pay.",
	"The anger swallowed the fear whole.",
	"Your heartbeat pounds in your ears like a war drum.",
	"You are no longer thinking. Only reacting.",
	"Someone is going to answer for this.",
	"You feel like you could tear a door off its hinges.",
	"It takes everything you have not to scream."
}
local apathy_phrases = {
	"You feel numb inside.",
	"Nothing seems to matter anymore.",
	"The world looks faded, like an old photograph.",
	"You are so tired of all this.",
	"You watch your own hands like they belong to a stranger.",
	"Even the noise sounds muffled and distant.",
	"You can't remember the last time you felt anything.",
	"What's the point of any of this?",
	"Your thoughts are slow and grey like ash.",
	"You just want to sit down and stop.",
	"Hunger, pain, fear — it all blends into one grey hum.",
	"Somewhere inside, you know you should care. You don't.",
	"The light seems weaker than it was yesterday.",
	"You are merely existing, not living."
}
local fear_phrases = {
	"I'm scared...",
	"I'm so scared...",
	"I want to go home...",
	"I don't want to die...",
	"I don't want to die here...",
	"Calm down. Just calm down...",
	"It's fine. It's fine...",
	"It's going to be okay... right?",
	"I can't stop shaking...",
	"Just don't panic. Don't panic...",
	"Please, not me. Not now...",
	"I just want to survive this..."
}
local derealization_phrases = {
	"This doesn't feel real.",
	"The world looks wrong, like a rough sketch of itself.",
	"You are watching yourself from far away.",
	"Your own voice sounds like a stranger's.",
	"Everything is moving too slow, or too fast. You can't tell.",
	"The walls feel like paper. The air feels like water.",
	"You know this place, but it doesn't know you.",
	"Reality is coming apart at the edges.",
	"You are not sure you actually exist right now.",
	"The world feels like a memory of itself."
}
local anger_color = Color(255, 110, 110)
local apathy_color = Color(170, 170, 170)
local fear_color = Color(190, 190, 255)
local derealization_color = Color(180, 160, 255)

local function psycheThought(owner, msg, delay, key, clr)
	if owner:GetInfoNum("hg_newthoughts", 0) > 0 then
		return owner:Thought(msg, delay, key, 0, clr)
	end
	return owner:Notify(msg, delay, key, 0, nil, clr)
end

module[1] = function(org)
	org.psycheAnger = 0
	org.psycheApathy = 0
	org.psycheDesens = 0
	org.psycheAngerLastHit = 0
	org.psychePainMul = 1
end

module[2] = function(owner, org, timeValue)
	local anger = org.psycheAnger or 0
	local apathy = org.psycheApathy or 0
	local now = CurTime()

	if now - (org.psycheAngerLastHit or 0) > anger_memory_time then
		anger = Approach(anger, 0, timeValue / anger_decay_fast)
	else
		anger = Approach(anger, 0, timeValue / anger_decay)
	end

	if org.pain > apathy_pain_start then
		apathy = min(apathy + timeValue / apathy_pain_speed * Clamp((org.pain - apathy_pain_start) / 60, 0, 1), 1)
	end
	if (org.blood or 5000) < apathy_blood_start then
		apathy = min(apathy + timeValue / apathy_blood_speed, 1)
	end
	if org.otrub then
		apathy = min(apathy + timeValue / apathy_otrub_speed, 1)
	end
	local fearLevel = Clamp(org.fear or 0, 0, 1)
	if fearLevel > apathy_fear_start then
		apathy = min(apathy + timeValue / apathy_fear_speed * Clamp((fearLevel - apathy_fear_start) / (1 - apathy_fear_start), 0, 1), 1)
	end

	local comfort = (org.satiety or 0) > 500 and org.pain < 20 and (org.blood or 0) > 4500
	local apathyDecayTime = comfort and apathy_decay_comfort or apathy_decay
	if anger > 0.5 then apathyDecayTime = min(apathyDecayTime, apathy_decay_comfort) end
	apathy = Approach(apathy, 0, timeValue / apathyDecayTime)

	org.psycheAnger = anger
	org.psycheApathy = apathy
	org.psychePainMul = 1 - anger_pain_resist * anger
	org.fear = min(org.fear, 1 - apathy_fear_cap * apathy)

	if org.isPly and owner:Alive() then
		local panic = org.panicattack or 0
		if panic >= 0.55 then
			psycheThought(owner, derealization_phrases[math.random(#derealization_phrases)], math.Rand(18, 28), "psyche_derealization", derealization_color)
		end
		if fearLevel > 0.5 and panic < 0.55 then
			psycheThought(owner, fear_phrases[math.random(#fear_phrases)], math.Rand(15, 25), "psyche_fear", fear_color)
		end
		if anger > 0.55 then
			psycheThought(owner, anger_phrases[math.random(#anger_phrases)], math.Rand(20, 35), "psyche_anger", anger_color)
		end
		if apathy > 0.55 then
			psycheThought(owner, apathy_phrases[math.random(#apathy_phrases)], math.Rand(30, 50), "psyche_apathy", apathy_color)
		end
	end
end

hook.Add("HomigradDamage", "PsycheAngerDamage", function(ply, dmgInfo)
	local org = ply and ply.organism
	if not org then return end
	local owner = org.owner
	if not IsValid(owner) or not owner:IsPlayer() then return end
	if dmgInfo:IsDamageType(DMG_FALL + DMG_CRUSH + DMG_BURN + DMG_POISON + DMG_DROWN) then return end
	local dmg = dmgInfo:GetDamage()
	if dmg < 5 then return end
	local attacker = dmgInfo:GetAttacker()
	local pvp = IsValid(attacker) and (attacker:IsPlayer() or attacker:IsNPC()) and attacker ~= owner
	if pvp then
		org.psycheAngerLastHit = CurTime()
	end
	if org.otrub then return end
	if pvp then
		org.psycheAnger = min((org.psycheAnger or 0) + dmg * anger_gain_damage + anger_gain_flat, 1)
	elseif dmg >= 20 then
		org.psycheAnger = min((org.psycheAnger or 0) + anger_gain_flat * 0.6, 1)
	end
end)

hook.Add("PlayerDeath", "PsycheApathyWitness", function(victim, inflictor, attacker)
	local pos = victim:GetPos()
	for i, ply in player.Iterator() do
		if ply == victim or not ply:Alive() then continue end
		local org = ply.organism
		if not org then continue end
		if ply:GetPos():DistToSqr(pos) > apathy_witness_radius * apathy_witness_radius then continue end
		local desens = org.psycheDesens or 0
		org.psycheDesens = min(desens + 1, desens_cap)
		org.psycheApathy = min((org.psycheApathy or 0) + apathy_witness_gain / (1 + desens * 0.35), 1)
	end
	if IsValid(attacker) and attacker:IsPlayer() and attacker ~= victim and attacker.organism then
		local org = attacker.organism
		org.psycheDesens = min((org.psycheDesens or 0) + 1, desens_cap)
		org.psycheApathy = max((org.psycheApathy or 0) - apathy_kill_relief, 0)
	end
end)
