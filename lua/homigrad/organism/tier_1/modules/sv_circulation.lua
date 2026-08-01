local min, max, Round, halfValue2 = math.min, math.max, math.Round, util.halfValue2
hg.organism.module.pulse = {}
local module = hg.organism.module.pulse
local Clamp, Approach, Remap = math.Clamp, math.Approach, math.Remap
local CurTime = CurTime

local function getBloodVolume(org)
	return Clamp((org.blood - 900) / 4100, 0, 1)
end

local function getHeartEfficiency(org)
	local heart = Clamp(1 - org.heart, 0, 1)
	local ischemia = Clamp(1 - (org.myocardialOxygen or 1), 0, 1)
	local strain = Clamp(org.heartStrain or 0, 0, 1)
	return Clamp(heart - ischemia * 0.35 - strain * 0.25, 0, 1)
end

function hg.organism.AddCardiacStress(org, amount)
	if not org or not isnumber(amount) or amount <= 0 then return 0 end
	org.arrhythmia = Clamp((org.arrhythmia or 0) + amount, 0, 1)
	org.nextArrhythmiaRoll = math.min(org.nextArrhythmiaRoll or CurTime(), CurTime() + 4)
	org.heartStrain = Clamp((org.heartStrain or 0) + amount * 0.45, 0, 1)
	return org.arrhythmia
end

module[1] = function(org)
	org.heart = 0
	org.heartstop = false
	org.pulse = 70
	org.heartbeat = 70
	org.bloodPressure = 90
	org.systolic = 120
	org.diastolic = 80
	org.cardiacOutput = 1
	org.arrhythmia = 0
	org.fibrillation = false
	org.fibrillationStart = 0
	org.myocardialOxygen = 1
	org.heartStrain = 0
	org.hypertension = 0
	org.hypotension = 0
	org.nextArrhythmiaRoll = 0
	org.lastCardiacPain = 0
	org.tempchanging = 0
	org.heatbuff = 30
	org.needed_temp = 36.7
end
local internalbleed_phrases = {
	"That's... that's blood I just vomited...",
	"Oh, that's blood...",
	"Fuck, I just puked blood...",
	"Oh shit... I don't feel good...",
	"God... there's blood in my mouth...",
	"I just puked... and it was red...",
	"That tastes like iron...",
	"Something inside is torn... I can feel it...",
	"I'm coughing up blood... that's not good...",
	"There's copper in my throat...",
	"Did I just swallow blood...?",
	"My guts... I think I'm bleeding inside...",
}
local about_to_puke = {
	"I feel like I'm gonna puke any second now...",
	"Not feeling good...",
	"Gonna puke right now...",
	"I want to vomit...",
	"My stomach's churning...",
	"I think I'm about to be sick...",
	"Ugh... my stomach...",
	"Here it comes... I'm gonna puke...",
	"I feel sick to my stomach...",
	"Don't... don't make me move... I'll puke...",
	"The nausea is hitting me...",
	"Gonna hurl... oh no...",
}
local bloodloss_light = {
	"I'm bleeding... I need to stop it...",
	"I need to patch this up...",
	"Blood's flowing... shit...",
	"Gotta find something to wrap this with...",
	"I think I got nicked...",
	"That's a lot of red...",
	"Damn... I'm leaking...",
	"Better wrap this up...",
	"I can feel the warmth running down...",
	"Gotta apply pressure...",
}
local bloodloss_moderate = {
	"I'm losing too much blood...",
	"I can feel myself getting weaker...",
	"The blood won't stop... I need help...",
	"I'm getting dizzy from the blood loss...",
	"Need to stop the bleeding... now...",
	"Too much blood... too fast...",
	"I'm starting to feel lightheaded...",
	"This wound won't close...",
	"My shirt's soaked... shit...",
	"My blood pressure's dropping...",
	"The floor's getting slippery with my blood...",
	"I'm soaked in it...",
	"Where's the medic...? I'm bleeding out...",
}
local bloodloss_severe = {
	"I can't... I'm losing so much blood...",
	"My vision is going dark...",
	"I feel so cold... so weak...",
	"Please... someone help me...",
	"I can't feel my fingers...",
	"I'm leaving a trail of blood...",
	"I can barely stand...",
	"Somebody... the bleeding won't stop...",
	"I'm getting colder... slower...",
	"I'm about to pass out... too much blood...",
	"The world is getting grey...",
	"I can hear my heartbeat slowing down...",
	"Someone... please... I'm bleeding too fast...",
}
local bloodloss_critical = {
	"I'm dying... I know it...",
	"Everything's fading away...",
	"I can't... hold on...",
	"Tell them... I tried...",
	"So... cold...",
	"This is it... I'm going to bleed out...",
	"Too late... I can already feel it...",
	"Darkness... I'm slipping...",
	"Tell them... it wasn't their fault...",
	"I can't feel my pulse anymore...",
	"It's over... I've bled too much...",
	"Cold... everything is cold...",
	"Goodbye... everyone...",
}
local tachycardia_phrases = {
	"My heart is racing...",
	"I can feel my heartbeat in my ears...",
	"Why is my heart pounding so hard...",
	"I can hear my own heartbeat...",
	"My chest is pounding...",
	"My heart won't slow down...",
	"Thump... thump... I can't calm down...",
	"My pulse is out of control...",
	"Something's wrong with my heartbeat...",
	"My heart is trying to jump out of my chest...",
	"Ba-boom ba-boom... I can't calm it...",
	"Why won't my heart slow down...?",
	"I can feel every single heartbeat...",
}
local cardiac_arrest_phrases = {
	"My heart... it's stopping...",
	"I can't... feel my pulse...",
	"Something's wrong with my heart...",
	"I'm fading... I can feel it...",
	"My chest... it's tightening...",
	"I can't feel my heart anymore...",
	"No... not now... my heart...",
	"Everything's stopping...",
	"My heart... skipped...",
	"I can't... my chest is crushing...",
	"The beat... it's stopping...",
	"Is this... a heart attack...?",
}
local hypothermia_mild = {
	"I'm getting cold...",
	"Chilly out here...",
	"Need to warm up...",
	"My fingers are numb...",
	"Shivering...",
	"I've got goosebumps...",
	"It's getting cold out here...",
	"I can't warm up...",
	"Cold's starting to bite...",
	"I'm getting goosebumps...",
	"It's freezing...",
	"Cold seeping into my bones...",
	"I need a jacket...",
}
local hypothermia_moderate = {
	"I can't stop shaking...",
	"So cold... can't feel my hands...",
	"Need warmth... now...",
	"My body won't stop trembling...",
	"I'm freezing...",
	"I can't stop shivering...",
	"My teeth are chattering...",
	"Too cold... my fingers won't bend...",
	"I need a fire... now...",
	"Can't feel my feet anymore...",
	"Hypothermia's setting in...",
	"I'm trembling so hard I can't aim...",
	"Warmth... I need warmth...",
}
local hypothermia_severe = {
	"I can't... feel anything...",
	"So... tired... just want to sleep...",
	"The cold is... numbing everything...",
	"I'm so sleepy...",
	"Can't... move...",
	"I don't feel the cold anymore...",
	"My hands are useless...",
	"Everything's numb...",
	"Just want to close my eyes...",
	"I'm beyond shivering now...",
	"The cold has taken my muscles...",
	"I can't feel my fingers... or my toes...",
	"Just a little sleep... just a little...",
}
local hypothermia_critical = {
	"Everything's... going dark...",
	"So... cold...",
	"I can't... feel my body...",
	"Sleep... just... sleep...",
	"Am I... still breathing...?",
	"The cold... it's taking me...",
	"I can't... move my arms...",
	"So... tired...",
	"It's... peaceful... being this cold...",
	"Can't... hold my eyes open...",
	"The cold is... finished with me...",
	"Nothing... left...",
}
local hyperthermia_mild = {
	"It's too hot...",
	"I'm sweating so much...",
	"Need water... need shade...",
	"I'm overheating...",
	"Can't take this heat...",
	"I'm drenched in sweat...",
	"Feels like a sauna in here...",
	"Too hot... way too hot...",
	"I'm roasting...",
	"I'm sweating buckets...",
	"Too warm... way too warm...",
	"The heat is starting to get to me...",
	"I'm cooking in this...",
}
local hyperthermia_moderate = {
	"I'm burning up...",
	"Everything's spinning from the heat...",
	"Can't... think straight... too hot...",
	"I need to cool down...",
	"My head is pounding from the heat...",
	"Can't cool down... no matter what...",
	"The heat is frying my brain...",
	"I feel like I'm about to pass out from the heat...",
	"My skin is burning...",
	"The heatstroke is coming...",
	"I can't think through the heat...",
	"Everything is hot and sticky...",
	"I'm gonna pass out from the heat...",
}
local hyperthermia_severe = {
	"I can't... breathe in this heat...",
	"Everything's... blurring...",
	"Need... water...",
	"I'm going to collapse...",
	"I'm going down from this heat...",
	"Everything's throbbing... it's so hot...",
	"Need... to get out of the sun...",
	"I can't take much more of this heat...",
	"Everything's swimming in the heat...",
	"The heat is cooking my brain...",
	"I need to cool down... or I'm done...",
	"Too hot... can't... breathe...",
}
local hyperthermia_critical = {
	"Can't... take it...",
	"Everything's... fading...",
	"Too... hot...",
	"The heat's... shutting me down...",
	"I can't... it's too... hot...",
	"Everything's... burning...",
	"Going... to... collapse...",
	"The heat... has taken me...",
	"Can't... move... burning...",
	"No more... heat...",
	"Cool... I need... cool...",
}
function hg.organism.should_gain_fear(org)
	return ((org.pain > 30) or (org.blood < 3000) or (org.bleed > 1))
end
module[2] = function(owner, org, timeValue)
	if not org.heartstop and not org.fibrillation and (org.arrhythmia or 0) < 0.25 and (org.myocardialOxygen or 1) > 0.55 then
		org.heartStrain = Approach(org.heartStrain or 0, 0, timeValue / 45)
	end

	local heart = getHeartEfficiency(org)
	local brain = math.Clamp(1 - org.brain * 1.5,0,1)
	local o2 = org.o2
	local o2 = halfValue2(o2[1], o2.range, o2.k)
	local stamina = org.stamina
	local bloodVolume = getBloodVolume(org)
	local oxygenation = Clamp(o2, 0, 1)
	local vascularTone = Clamp(1 + min(org.adrenaline, 3) * 0.12 + max(org.fear, 0) * 0.08 + Clamp(org.shock, 0, 45) / 360, 0.65, 1.55)
	local pressureBase = 92 * bloodVolume * heart * vascularTone * Clamp(Remap(org.temperature, 28, 36.7, 0.55, 1), 0.45, 1.1)
	local rhythmMul = org.fibrillation and 0.18 or Clamp(1 - (org.arrhythmia or 0) * 0.22, 0.5, 1)
	local defibGrace = (org.defibDeathGrace or 0) > CurTime()
	local arrestPressure = defibGrace and 45 or 0
	local pressure = org.alive and (org.heartstop and arrestPressure or pressureBase * rhythmMul) or 0
	local pressureFallSpeed = defibGrace and 4 or 18
	org.bloodPressure = Approach(org.bloodPressure or pressure, pressure, pressure > (org.bloodPressure or 0) and timeValue * 12 or timeValue * pressureFallSpeed)
	org.pulse = Approach(org.pulse or 0, org.bloodPressure, heart == 0 and timeValue * 10 or timeValue * 5)
	org.systolic = Round(Clamp(org.bloodPressure * 1.38 + (org.heartbeat or 70) * 0.12, 0, 240))
	org.diastolic = Round(Clamp(org.bloodPressure * 0.88, 0, 160))
	org.cardiacOutput = org.heartstop and (defibGrace and Clamp((org.pulse or org.bloodPressure) / 70 * 0.35, 0, 0.45) or 0) or Clamp((org.bloodPressure / 90) * heart * rhythmMul, 0, 1.5)
	if not org.heartstop and not org.fibrillation and (org.arrhythmia or 0) < 0.25 and (org.myocardialOxygen or 1) > 0.65 and org.bloodPressure > 55 then
		org.cardiacOutput = Approach(org.cardiacOutput, Clamp(bloodVolume * heart, 0, 1), timeValue / 20)
	end
	local myocardialTarget = Clamp(oxygenation * bloodVolume * Clamp(org.bloodPressure / 70, 0, 1.2), 0, 1)
	if org.heartstop and defibGrace then myocardialTarget = math.max(myocardialTarget, 0.25) end
	org.myocardialOxygen = Approach(org.myocardialOxygen or 1, myocardialTarget, timeValue / 8)
	org.hypotension = Approach(org.hypotension or 0, Clamp(Remap(org.bloodPressure, 55, 20, 0, 1), 0, 1), timeValue / 8)
	org.hypertension = Approach(org.hypertension or 0, Clamp(Remap(org.bloodPressure, 115, 155, 0, 1), 0, 1), timeValue / 20)
	org.fearadd = math.Clamp(org.fearadd, 0, 3)
	local heartbeat = org.bloodPressure < 70 and 70 + (70 - org.bloodPressure) * 3 or 70
	local runnin_or_exhausted = org.analgesia < 1 and (org.stamina.sub > 0 or org.stamina[1] < (org.stamina.max * 0.66))
	org.heartbeat = math.Approach(org.heartbeat, math.max(heartbeat - 10, runnin_or_exhausted and ((1 - math.min(1, org.stamina[1] / (org.stamina.max * 1))) * 110 + 90) or 60), !runnin_or_exhausted and timeValue * 2 or timeValue * 15)
	heartbeat = heartbeat + (owner.suiciding and 50 or 0)
	heartbeat = heartbeat + 40 * math.max(0, org.fear)
	heartbeat = heartbeat + math.Clamp(org.shock, 0, 40)
	heartbeat = heartbeat + math.Clamp(org.pain, 40, 80) - 40
	heartbeat = heartbeat + 40 * math.min(org.adrenaline, 3)
	heartbeat = heartbeat - 40 * math.min(org.analgesia / 2.5, 1)
	heartbeat = heartbeat + 100 * math.Clamp(math.Remap(org.temperature, 40, 42, 0, 1), 0, 1)
	heartbeat = heartbeat - 160 * (1 - math.Clamp(math.Remap(org.temperature, 28, 36.7, 0, 1), 0, 1))
	heartbeat = heartbeat + (org.hypotension or 0) * 55
	heartbeat = heartbeat - (1 - (org.myocardialOxygen or 1)) * 35
	if (org.arrhythmia or 0) > 0.05 and not org.fibrillation then heartbeat = heartbeat + math.Rand(-70, 90) * org.arrhythmia end
	if org.fibrillation then heartbeat = math.Rand(180, 360) end
	org.heartbeat = math.Approach(org.heartbeat, heartbeat, heartbeat > org.heartbeat and timeValue * 5 or timeValue * 3)
	local ischemia = Clamp(1 - (org.myocardialOxygen or 1), 0, 1)
	local stress = Clamp((org.heart or 0) * 0.9 + ischemia * 0.8 + (org.hypertension or 0) * 0.35 + (org.hypotension or 0) * 0.3 + Clamp(org.shock, 0, 80) / 180 + max(org.pain - 60, 0) / 220 + max(org.heartbeat - 165, 0) / 190, 0, 2)
	org.arrhythmia = Approach(org.arrhythmia or 0, Clamp(stress * 0.42, 0, 1), stress > (org.arrhythmia or 0) and timeValue / 25 or timeValue / 90)
	if stress > 0.65 and CurTime() >= (org.nextArrhythmiaRoll or 0) then
		org.nextArrhythmiaRoll = CurTime() + Clamp(Remap(stress, 0.65, 1.6, 14, 3), 3, 14)
		if math.Rand(0, 1) < Clamp((stress - 0.65) * 0.12, 0.01, 0.18) then hg.organism.StartFibrillation(org) end
	end
	if org.heartbeat > 300 then
		hg.organism.StartFibrillation(org)
	end
	if org.fibrillation then
		org.consciousness = math.min(org.consciousness, Clamp(org.bloodPressure / 55, 0, 1))
		org.o2[1] = max(org.o2[1] - timeValue * 1.8, 0)
		if (org.fibrillationStart or CurTime()) + 24 < CurTime() or org.bloodPressure < 8 then org.heartstop = true end
	end
	if org.hypertension > 0.35 then org.heartStrain = Clamp((org.heartStrain or 0) + timeValue * org.hypertension / 360, 0, 1) end
	if ischemia > 0.35 then org.heartStrain = Clamp((org.heartStrain or 0) + timeValue * ischemia / 260, 0, 1) end
	if ischemia > 0.45 and org.isPly and not org.otrub and (org.lastCardiacPain or 0) < CurTime() then
		org.lastCardiacPain = CurTime() + math.Rand(14, 24)
		org.painadd = org.painadd + math.Rand(4, 9) * ischemia
		org.shock = math.max(org.shock, 10 + ischemia * 22)
	end
	if org.hypotension > 0.2 then org.consciousness = math.min(org.consciousness, Clamp(Remap(org.bloodPressure, 20, 65, 0, 1), 0, 1)) end
	if org.heartstop then
		org.heartbeat = 0
		local arrestFallSpeed = defibGrace and 4 or 35
		org.bloodPressure = Approach(org.bloodPressure or 0, arrestPressure, timeValue * arrestFallSpeed)
		org.pulse = Approach(org.pulse or 0, arrestPressure, timeValue * arrestFallSpeed)
		org.fibrillation = false
		org.arrhythmia = 0
	end
	org.fear = math.Approach(org.fear, (org.otrub and 0 or (org.fearadd > 0 and 1 or -1)), org.otrub and timeValue * 0.5 or (org.fearadd > 0 and (org.fear < 0 and timeValue * 5 * org.fearadd or timeValue / 5 * org.fearadd) or (org.fear <= 0 and timeValue / 240 or timeValue / 50)))
	local gainfear = hg.organism.should_gain_fear(org)
	org.fearadd = math.Approach(org.fearadd, 0, gainfear and timeValue or timeValue / 4.9)
	org.fearadd = math.Approach(org.fearadd, 1, gainfear and timeValue / 5 or 0)
	local adrenK = max(1 + org.adrenaline, 1)
	local adren = org.adrenaline
	if org.pulse < 10 or org.brain >= 0.6 then org.heartstop = true end
	if org.temperature < 28 or org.temperature > 42 then org.heartstop = true end
	if org.heartstop then
		org.fibrillation = false
		org.arrhythmia = 0
	end
	if org.temperature < 34 or org.temperature > 38 or org.blood < 4000 or org.pain > 20 then
		org.fear = math.max(org.fear, 0)
	end
	local needed_temp = math.min(math.max(37 * (org.pulse / 45), 35), 36.7)
	local changeRate = timeValue / 60
	changeRate = changeRate * (org.temperature < needed_temp and math.Clamp(org.heatbuff / 60, 1, 2) or 1)
	if math.abs(org.tempchanging) < changeRate then
		org.temperature = math.Approach(org.temperature, needed_temp, changeRate)
	else
		org.needed_temp = needed_temp
	end
	if not org.heartstop then
		org.last_heartbeat = CurTime()
	end
	if org.heartstop and adren > 0 and (org.adrenaline_try or 0) < CurTime() then
		local chance = math.Clamp(adren * 25,0,25)
		local rand = math.random(100)
		org.adrenaline_try = CurTime() + 0.1
		if chance > rand then org.heartstop = false end
	end
	if org.heartstop then
		org.heartstoptime = org.heartstoptime or CurTime()
		if org.isPly then
		end
	else
		if org.isPly then
		end
		org.heartstoptime = nil
	end
	if org.alive and org.heartstoptime and org.heartstoptime + 30 < CurTime() and (org.lastsoundtime or 0) < CurTime() and org.otrub then
		org.owner:EmitSound("breathing/agonalbreathing_"..math.random(13)..".wav", 60)
		org.lastsoundtime = CurTime() + math.random(25,35)
	end

	if org.isPly and not org.otrub and org.temperature then
		if org.temperature < 35 and org.temperature >= 33 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hypothermia_mild[math.random(#hypothermia_mild)], 12, "hypothermia_mild", 0)
				org.nextTempPhrase = CurTime() + math.Rand(25, 40)
			end
		elseif org.temperature < 33 and org.temperature >= 30 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hypothermia_moderate[math.random(#hypothermia_moderate)], 12, "hypothermia_moderate", 0)
				org.nextTempPhrase = CurTime() + math.Rand(15, 25)
			end
		elseif org.temperature < 30 and org.temperature >= 28 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hypothermia_severe[math.random(#hypothermia_severe)], 12, "hypothermia_severe", 0)
				org.nextTempPhrase = CurTime() + math.Rand(10, 18)
			end
		elseif org.temperature < 28 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hypothermia_critical[math.random(#hypothermia_critical)], 12, "hypothermia_critical", 0)
				org.nextTempPhrase = CurTime() + math.Rand(8, 14)
			end
		elseif org.temperature > 38 and org.temperature <= 40 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hyperthermia_mild[math.random(#hyperthermia_mild)], 12, "hyperthermia_mild", 0)
				org.nextTempPhrase = CurTime() + math.Rand(20, 35)
			end
		elseif org.temperature > 40 and org.temperature <= 41 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hyperthermia_moderate[math.random(#hyperthermia_moderate)], 12, "hyperthermia_moderate", 0)
				org.nextTempPhrase = CurTime() + math.Rand(12, 22)
			end
		elseif org.temperature > 41 and org.temperature <= 42 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hyperthermia_severe[math.random(#hyperthermia_severe)], 12, "hyperthermia_severe", 0)
				org.nextTempPhrase = CurTime() + math.Rand(8, 16)
			end
		elseif org.temperature > 42 then
			if not org.nextTempPhrase or org.nextTempPhrase < CurTime() then
				org.owner:Notify(hyperthermia_critical[math.random(#hyperthermia_critical)], 12, "hyperthermia_critical", 0)
				org.nextTempPhrase = CurTime() + math.Rand(6, 12)
			end
		end
	end
end
util.AddNetworkString("pulse")
function hg.organism.Pulse(owner, org, timeValue)
	local stamina = org.stamina
	if org.o2[1] > 1 and org.alive and org.heart < 1 and org.brain < 0.6 then
	end--brain damage is usually permanent
	if owner:IsPlayer() and owner:Alive() then
		net.Start("pulse")
		net.Send(owner)
	end
end
local CurTime = CurTime
local time
local max, min, Round = math.max, math.min, math.Round
hg.organism.module.blood = {}
local module = hg.organism.module.blood
hg.organism.bloodtypes = {
	["o-"] = {["o-"] = true,["o+"] = true,["a-"] = true,["a+"] = true,["b-"] = true,["b+"] = true,["ab-"] = true,["ab+"] = true},
	["o+"] = {["o+"] = true,["a+"] = true,["b+"] = true,["ab+"] = true},
	["a-"] = {["a+"] = true,["a-"] = true,["ab+"] = true,["ab-"] = true},
	["a+"] = {["a+"] = true,["ab+"] = true},
	["b-"] = {["b+"] = true,["b-"] = true,["ab+"] = true,["ab-"] = true},
	["b+"] = {["b+"] = true,["ab+"] = true},
	["ab-"] = {["ab+"] = true,["ab-"] = true},
	["ab+"] = {["ab+"] = true},
	["c-"] = {["c-"] = true,["o-"] = true,["o+"] = true,["a-"] = true,["a+"] = true,["b-"] = true,["b+"] = true,["ab-"] = true,["ab+"] = true},
}
module[1] = function(org)
	org.blood = 5000
	org.bleed = 0
	org.internalBleed = 0
	org.internalBleedHeal = 0
	org.arteria = 0
	org.rarmartery = 0
	org.larmartery = 0
	org.rlegartery = 0
	org.llegartery = 0
	org.spineartery = 0
	org.bleedStart = 0
	org.wounds = {}
	org.arterialwounds = {}
	org.bleedSources = {}
	org.internalBleedSources = {}
	org.nextBleedSourceID = 0
	org.holdWound = nil
	org.holdWoundArterial = nil
	org.wantToVomit = 0
	org.vomitInThroat = nil
	org.bloodtype = table.GetKeys(hg.organism.bloodtypes)[math.random(8)]
	if org.bloodtype == "c-" then
		org.bloodtype = "o-"
	end
	org.hemotransfusionshock = 0
	org.survivalchance = 1
end

function hg.organism.AddBleedSource(org, kind, rate, organ, bone, wound)
	if not org or rate <= 0 then return end
	org.bleedSources = org.bleedSources or {}
	org.internalBleedSources = org.internalBleedSources or {}
	org.nextBleedSourceID = (org.nextBleedSourceID or 0) + 1

	local source = {
		id = org.nextBleedSourceID,
		kind = kind,
		rate = rate,
		organ = organ,
		bone = bone,
		created = CurTime(),
		wound = wound
	}
	org.bleedSources[source.id] = source
	if kind == "internal" then org.internalBleedSources[source.id] = source end
	if wound then wound[8] = source.id end

	return source
end
local vecZero = Vector(0, 0, 0)
local hold_wound_size_threshold = 4
local hold_wound_pain_threshold = 72
local hold_wound_painadd_threshold = 8
local hold_wound_bleed_threshold = 0.35
local hold_wound_bleed_slow_mul = 0.72
local hold_wound_bleed_slow_twohand_mul = 0.55
local hold_wound_arterial_slow_mul = 0.2
local function hasWound(wounds, target)
	if not target or not wounds then return false end
	for i, wound in pairs(wounds) do
		if wound == target then
			return true
		end
	end
	return false
end
local function getLargestWound(wounds)
	local best
	local bestSize = 0
	for i, wound in pairs(wounds or {}) do
		local size = wound[1] or 0
		if size > bestSize then
			best = wound
			bestSize = size
		end
	end
	return best, bestSize
end
local function updateHoldWound(org)
	local arteryWound = getLargestWound(org.arterialwounds)
	if arteryWound then
		org.holdWound = arteryWound
		org.holdWoundArterial = true
		return
	end
	if org.holdWoundArterial then
		org.holdWound = nil
		org.holdWoundArterial = nil
	end
	if org.holdWound and hasWound(org.wounds, org.holdWound) then
		return
	end
	org.holdWound = nil
	org.holdWoundArterial = nil
	local wound, woundSize = getLargestWound(org.wounds)
	if not wound then return end
	local intensePain = org.pain >= hold_wound_pain_threshold or org.painadd >= hold_wound_painadd_threshold
	local profuseBleeding = org.bleed >= hold_wound_bleed_threshold
	if woundSize >= hold_wound_size_threshold and (intensePain or profuseBleeding) then
		org.holdWound = wound
		org.holdWoundArterial = false
	end
end
local function getHeldWoundBleedMul(org, wound)
	if not org.manualHoldWound or org.manualHoldWoundTarget != wound then return 1 end
	if org.manualHoldWoundArterial then
		return hold_wound_arterial_slow_mul
	end
	if (org.manualHoldWoundHands or 0) >= 2 then
		return hold_wound_bleed_slow_twohand_mul
	end
	return hold_wound_bleed_slow_mul
end
module[2] = function(owner, org, mulTime)
	local adrenaline = math.min(org.adrenaline, 2)
	if org.vomitInThroat then
		local ent = hg.GetCurrentCharacter(owner)
		local bon = "ValveBiped.Bip01_Head1"
		local bone = ent:LookupBone(bon)
		local mat = ent:GetBoneMatrix(bone)
		if mat and mat:GetAngles():Right()[3] < 0.25 then
			org.vomitInThroat = nil
			net.Start("bloodsquirt2")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
			net.Broadcast()
			ent:EmitSound("vomit/vomit5.mp3")
		end
	end
	if org.isPly and not org.otrub and org.blood < 2900 then org.owner:Notify(math.random(2) == 1 and "I cant feel anything..." or (math.random(2) == 1 and "I think I'm gonna faint right now...") or "I dont feel so good...",60,"blood2",0) end
	if org.isPly and not org.otrub and org.blood < 4000 and org.blood >= 3000 then
		if not org.nextBloodPhrase or org.nextBloodPhrase < CurTime() then
			org.owner:Notify(bloodloss_light[math.random(#bloodloss_light)], 15, "bloodloss_light", 0)
			org.nextBloodPhrase = CurTime() + math.Rand(20, 40)
		end
	end
	if org.isPly and not org.otrub and org.blood < 3000 and org.blood >= 2000 then
		if not org.nextBloodPhrase or org.nextBloodPhrase < CurTime() then
			org.owner:Notify(bloodloss_moderate[math.random(#bloodloss_moderate)], 15, "bloodloss_moderate", 0)
			org.nextBloodPhrase = CurTime() + math.Rand(15, 30)
		end
	end
	if org.isPly and not org.otrub and org.blood < 2000 and org.blood >= 1200 then
		if not org.nextBloodPhrase or org.nextBloodPhrase < CurTime() then
			org.owner:Notify(bloodloss_severe[math.random(#bloodloss_severe)], 15, "bloodloss_severe", 0)
			org.nextBloodPhrase = CurTime() + math.Rand(10, 20)
		end
	end
	if org.isPly and not org.otrub and org.blood < 1200 then
		if not org.nextBloodPhrase or org.nextBloodPhrase < CurTime() then
			org.owner:Notify(bloodloss_critical[math.random(#bloodloss_critical)], 15, "bloodloss_critical", 0)
			org.nextBloodPhrase = CurTime() + math.Rand(8, 15)
		end
	end
	if org.isPly and not org.otrub and org.pulse > 120 and org.pulse < 160 then
		if not org.nextPulsePhrase or org.nextPulsePhrase < CurTime() then
			org.owner:Notify(tachycardia_phrases[math.random(#tachycardia_phrases)], 10, "tachycardia", 0)
			org.nextPulsePhrase = CurTime() + math.Rand(15, 25)
		end
	end
	if org.isPly and not org.otrub and org.heartstop then
		if not org.nextCardiacPhrase or org.nextCardiacPhrase < CurTime() then
			org.owner:Notify(cardiac_arrest_phrases[math.random(#cardiac_arrest_phrases)], 10, "cardiac_arrest", 0)
			org.nextCardiacPhrase = CurTime() + math.Rand(5, 12)
		end
	end
	if org.internalBleed < 0.5 and org.bleed < 0.05 and org.pulse > 5 then
		org.blood = min(org.blood + mulTime * 5 * (adrenaline * 1.5 + 1) * (org.satiety / 100 + 1) * org.pulse / 70, 5000)
	end
	if org.hemotransfusionshock > 0 then
		org.hemotransfusionshock = math.max(org.hemotransfusionshock - mulTime / 200,0)
		org.internalBleed = org.internalBleed + mulTime / 30
	end
	if org.arteria == 1 then
		org.o2[1] = math.max(org.o2[1] - mulTime * 5,0)
	end
	org.consciousness = math.min(org.consciousness, math.min(org.blood / 3000, 1) * math.Clamp(((org.temperature < 30 and org.temperature - 30 or 0) * 0.25 + 1), 0.25, 1))
	local beatsPerSecond = max(min(60 / math.max(org.pulse,2) / (org.bleed / 15), 7), 0.3)
	time = CurTime()
	local coagulatespeed = 0
	local bleedoutspeed = 0
	if #org.wounds > 0 then
		local ent = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
		for i, wound in pairs(org.wounds) do
			local rand1 = math.Rand(4, 10) * 1
			local rand2 = math.Rand(0.5, 1) * 1
			local bleed = rand1 * wound[1] * mulTime * math.max(org.pulse, 20) / 70 * 2.0 * (1 - math.min(adrenaline / 6, 0.5)) * org.bleedingmul * 0.02
			bleed = bleed * getHeldWoundBleedMul(org, wound)
			local coagulate = 2 * mulTime * rand2 * (adrenaline * 0.1 + 1) * 0.04-- / #org.wounds
			bleedoutspeed = bleedoutspeed + bleed / rand1 * 3--we pray for the luck of it being in the center
			coagulatespeed = coagulatespeed + coagulate / rand2 * 1
			local rand = math.Rand(0, 2) * 2
				wound[5] = time
				org.blood = max(org.blood - bleed, 1)
				if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
					hg.organism.BloodDroplet2(owner, org, wound, ent:GetVelocity() + VectorRand(-15, 15), false)
					wound[1] = max(wound[1] - coagulate, 0)
				end
				local source = org.bleedSources and org.bleedSources[wound[8]]
				if source then source.rate = wound[1] end
				if wound[1] == 0 then
					if source then org.bleedSources[source.id] = nil end
					table.remove(org.wounds, i)
					owner:SetNetVar("wounds",org.wounds)
				end
		end
	end
	if org.heart == 1 then
		org.blood = math.max(org.blood - mulTime * 100 * org.pulse / 70,0)
		bleedoutspeed = bleedoutspeed + mulTime * 100 * org.pulse / 70
	end
	if org.liver > 0.5 then
	end
	bleedoutspeed = bleedoutspeed / (beatsPerSecond + 2)
	local bleedoutspeed2 = 0
	local next_arterypump = 1 / math.max(org.pulse, 10)
	local ent = owner:IsPlayer() and IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
	for i, wound in pairs(org.arterialwounds) do
		local arterialBleed = wound[1] * mulTime * 0.2 * math.max(org.pulse, 20) / 80
		arterialBleed = arterialBleed * getHeldWoundBleedMul(org, wound)
		bleedoutspeed2 = bleedoutspeed2 + arterialBleed
		if wound[5] + next_arterypump * 2 < time then
			local pos, ang = ent:GetBonePosition(ent:LookupBone(wound[4]))
			wound[5] = time
			local pumpBleed = wound[1] * mulTime * 4.5 * math.max(org.pulse, 20) / 80
			pumpBleed = pumpBleed * getHeldWoundBleedMul(org, wound)
			org.blood = max(org.blood - pumpBleed, 1)
			if (owner:IsPlayer() and owner:Alive()) or not owner:IsPlayer() then
				local dir = wound[6]
				local len = dir:Length()
				local _, dir = LocalToWorld(vecZero, dir:Angle(), vecZero, ang)
				dir = -dir:Forward() * len
				hg.organism.BloodDroplet2(owner, org, wound, owner:GetVelocity() + VectorRand(-10, 10) + dir, true)
			end
			if wound[1] == 0 then
				local source = org.bleedSources and org.bleedSources[wound[8]]
				if source then org.bleedSources[source.id] = nil end
				table.remove(org.arterialwounds, i)
				owner:SetNetVar("arterialwounds", org.arterialwounds)
				org[wound[7]] = 0
			end
		end
	end
	bleedoutspeed2 = bleedoutspeed2 / next_arterypump
	if org.blood < (2400 / (adrenaline / 3 + 1)) * ((math.cos(CurTime()/2) + 1) / 2 * 0.1 + 1) then org.needotrub = true end
	local bleed = org.internalBleed / 14
	org.internalBleed = math.Approach(org.internalBleed, 0, org.internalBleedHeal > 0 and mulTime / 2 or mulTime / 55)
	local internalSourceTotal = 0
	for _, source in pairs(org.internalBleedSources or {}) do
		internalSourceTotal = internalSourceTotal + source.rate
	end
	if internalSourceTotal > 0 then
		local sourceMul = math.Clamp(org.internalBleed / internalSourceTotal, 0, 1)
		for id, source in pairs(org.internalBleedSources) do
			source.rate = source.rate * sourceMul
			if source.rate <= 0.001 then
				org.internalBleedSources[id] = nil
				org.bleedSources[id] = nil
			end
		end
	end
	coagulatespeed = coagulatespeed + mulTime
	org.internalBleedHeal = math.Approach(org.internalBleedHeal, 0, mulTime / 2)
	if bleed > 0 then org.blood = max(org.blood - bleed * mulTime * 10 * org.pulse / 70, 1) end
	if (org.internalBleed > 1 or org.pneumothorax > 0) and org.blood > 2000 and org.o2[1] > 0 then
		org.wantToVomit = org.wantToVomit or 0
		org.wantToVomit = org.wantToVomit + math.Rand(0, org.internalBleed / 1000 + org.pneumothorax / 200) * mulTime * 5
		if org.wantToVomit > 0.90 then
		end
	end
	if org.wantToVomit > 1 then
		org.wantToVomit = 0
		if org.isPly then owner:Notify(internalbleed_phrases[math.random(#internalbleed_phrases)], 15, "internalbleed") end
		hg.organism.Vomit(owner)
	end
	org.bleed = (bleedoutspeed + bleedoutspeed2 + bleed)
	local timetouncon = (org.blood - 2500) / org.bleed
	local bleeding_will_stop = (timetouncon ~= timetouncon) or ((coagulatespeed * timetouncon - org.bleed) > 0)
	local canwakeup_pain = ((org.pain - 5) / (org.painlessen)) < timetouncon
	org.timetouncon = (timetouncon ~= timetouncon) and timetouncon or Lerp(hg.lerpFrameTime2(0.01,mulTime), org.timetouncon or 10000, timetouncon)
	if org.otrub and ((not bleeding_will_stop and not (canwakeup_pain and org.blood > 3000)) or (org.brain > 0.4) or (org.pulse < 15) or (org.o2[1] < 5) or (org.trachea >= 0.5) or org.heartstop or (org.spine3 >= hg.organism.fake_spine3) or (org.spine2 >= hg.organism.fake_spine2)) then
		org.incapacitated = true
	else
		org.incapacitated = false
	end
	if (org.brain > 0.4) or (org.heart > 0.6) or (org.trachea >= 0.6) then
		org.critical = true
	else
		org.critical = false
	end
	org.bleed = (bleedoutspeed + bleedoutspeed2)
	updateHoldWound(org)
end
util.AddNetworkString("bloodsquirt2")
util.AddNetworkString("vomitConcussionMouth")
function hg.organism.Vomit(owner, snd)
	if !hg.IsValidPlayer(owner) then return end
	local org = owner.organism
	org.blood = math.max(org.blood - 200, 0)
	local ent = hg.GetCurrentCharacter(owner)
	local bon = "ValveBiped.Bip01_Head1"
	local bone = ent:LookupBone(bon)
	local mat = ent:GetBoneMatrix(bone)
	if not mat then return end
	local on_spine = mat:GetAngles():Right()[3] > 0.25
	if on_spine then
		org.vomitInThroat = true
	end
	owner:SetNetVar("vomiting", CurTime() + 1.5)
	ent:EmitSound(snd or "zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "female" or "male").."_cough"..math.random(4)..".mp3")
	if !on_spine then ent:EmitSound("vomit/vomit5.mp3") end
	if owner.armors and owner.armors.face and hg.armor.face[owner.armors.face].voice_change then
		owner:SetNetVar("zableval_masku", true)
	else
		if !on_spine then
			net.Start("bloodsquirt2")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
			net.Broadcast()
		end
	end
end
function hg.organism.VomitConcussion(owner)
	if not hg.IsValidPlayer(owner) then return end
	local org = owner.organism
	local ent = hg.GetCurrentCharacter(owner)
	if not IsValid(ent) then return end
	local bon = "ValveBiped.Bip01_Head1"
	local bone = ent:LookupBone(bon)
	if not bone then return end
	local mat = ent:GetBoneMatrix(bone)
	if not mat then return end
	local on_spine = mat:GetAngles():Right()[3] > 0.25
	if on_spine then
		org.vomitInThroat = true
		return
	end
	owner:SetNetVar("vomiting", CurTime() + 1.5)
	ent:EmitSound("zcitysnd/real_sonar/"..(ThatPlyIsFemale(ent) and "female" or "male").."_cough"..math.random(4)..".mp3")
	if !on_spine then ent:EmitSound("vomit/vomit5.mp3") end
	if owner.armors and owner.armors.face and hg.armor.face[owner.armors.face].voice_change then
		owner:SetNetVar("zableval_masku", true)
	else
		net.Start("vomitConcussionMouth")
			net.WriteEntity(ent)
			net.WriteString(bon)
			net.WriteMatrix(mat)
			net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
			net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
		net.Broadcast()
	end
end
function hg.organism.CoughBlood(org)
	local ply = org.owner
	local phr = "zcitysnd/real_sonar/" .. (ThatPlyIsFemale(ply) and "female" or "male") .. "_cough" .. math.random(4) .. ".mp3"
	ply:EmitSound(phr)
	ply.phrCld = CurTime() + 2
	ply.lastPhr = phr
	if math.random(5) == 1 then
		org.vomitInThroat = nil
		net.Start("bloodsquirt2")
		net.WriteEntity(ent)
		net.WriteString(bon)
		net.WriteMatrix(mat)
		net.WriteVector(mat:GetTranslation() + mat:GetAngles():Right() * 6 + mat:GetAngles():Forward() * 1)
		net.WriteVector(mat:GetAngles():Right() * 2 * math.Clamp(org.pulse / 70, 0.4, 1))
		net.Broadcast()
		ent:EmitSound("vomit/vomit5.mp3")
	end
end
function hg.organism.BloodDroplet2(owner, org, wound, dir, artery)
	hook.Run("HG_BloodParticleStartedDropping", owner, org, wound, dir, artery)
end
