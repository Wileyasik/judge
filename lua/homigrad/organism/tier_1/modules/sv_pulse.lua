local min, max, Round, halfValue2 = math.min, math.max, math.Round, util.halfValue2
--local Organism = hg.organism
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

local function addArrhythmia(org, amount)
	org.arrhythmia = Clamp((org.arrhythmia or 0) + amount, 0, 1)
	org.nextArrhythmiaRoll = math.min(org.nextArrhythmiaRoll or CurTime(), CurTime() + 4)
end

function hg.organism.AddCardiacStress(org, amount)
	if not org or not isnumber(amount) or amount <= 0 then return 0 end
	addArrhythmia(org, amount)
	org.heartStrain = Clamp((org.heartStrain or 0) + amount * 0.45, 0, 1)
	return org.arrhythmia
end

function hg.organism.StartFibrillation(org)
	if not org or org.heartstop then return end
	org.fibrillation = true
	org.arrhythmia = math.max(org.arrhythmia or 0, 0.8)
	org.fibrillationStart = CurTime()
end

module[1] = function(org)
	org.heart = 0
	org.heartstop = false
	org.pulse = 70 -- that's the blood pressure
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
	org.heatbuff = 30 -- seconds of heat supply
	org.needed_temp = 36.7
end

function hg.organism.should_gain_fear(org)
	return ((org.pain > 30) or (org.blood < 3000) or (org.bleed > 1))// + (org.just_damaged_bone and ((org.just_damaged_bone + 10 - CurTime()) >= 10) and 10 or 0)
end

module[2] = function(owner, org, timeValue)
	if not org.heartstop and not org.fibrillation and (org.arrhythmia or 0) < 0.25 and (org.myocardialOxygen or 1) > 0.55 then
		org.heartStrain = Approach(org.heartStrain or 0, 0, timeValue / 45)
	end

	local heart = getHeartEfficiency(org)
	local brain = math.Clamp(1 - org.brain * 1.5,0,1)
	local o2 = org.o2
	local o2 = halfValue2(o2[1], o2.range, o2.k)

	//if org.isPly and not org.otrub and (heart == 0) then org.owner:Notify("My torso hurts.",true,"heart",6) end
	//if org.isPly and not org.otrub and org.heartstop then org.owner:Notify("",true,"heartstop",6) end

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
	org.pulse = Approach(org.pulse, org.bloodPressure, heart == 0 and timeValue * 10 or timeValue * 5)
	org.systolic = Round(Clamp(org.bloodPressure * 1.38 + (org.heartbeat or 70) * 0.12, 0, 240))
	org.diastolic = Round(Clamp(org.bloodPressure * 0.88, 0, 160))
	org.cardiacOutput = org.heartstop and (defibGrace and Clamp((org.pulse or org.bloodPressure) / 70 * 0.35, 0, 0.45) or 0) or Clamp((org.bloodPressure / 90) * heart * rhythmMul, 0, 1.5)
	if not org.heartstop and not org.fibrillation and (org.arrhythmia or 0) < 0.25 and (org.myocardialOxygen or 1) > 0.65 and org.bloodPressure > 55 then
		org.cardiacOutput = Approach(org.cardiacOutput, Clamp(getBloodVolume(org) * heart, 0, 1), timeValue / 20)
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
	heartbeat = heartbeat - (org.myocardialOxygen and (1 - org.myocardialOxygen) or 0) * 35
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
	-- less time to start fearing, more time to become calm again
	-- if no fear, in 3 minutes become slightly talkative, so would say random phrases to calm themselves in a current situation
	local gainfear = hg.organism.should_gain_fear(org)
	org.fearadd = math.Approach(org.fearadd, 0, gainfear and timeValue or timeValue / 4.9) -- 15 seconds to stop fearing something and start to calm down
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

	-- temperature
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
			//org.owner:Notify("I'm feeling dizzy...", true, "heartstop", 10)
		end
	else
		if org.isPly then
			//org.owner:ResetNotification("heartstop")
		end
		org.heartstoptime = nil
	end

	if org.alive and org.heartstoptime and org.heartstoptime + 30 < CurTime() and (org.lastsoundtime or 0) < CurTime() and org.otrub then
		org.owner:EmitSound("breathing/agonalbreathing_"..math.random(13)..".wav", 60)
		--org.owner:EmitSound("breathing/agonalbreathing_"..math.random(13)..".wav", 50)
		
		org.lastsoundtime = CurTime() + math.random(25,35)
	end
end

--if org.heartstop then org.needotrub = true end --не совсем...
util.AddNetworkString("pulse")
function hg.organism.Pulse(owner, org, timeValue)
	local stamina = org.stamina
	if org.o2[1] > 1 and org.alive and org.heart < 1 and org.brain < 0.6 then
		--org.brain = max(org.brain - timeValue / 30, 0) --regen
	end--brain damage is usually permanent

	if owner:IsPlayer() and owner:Alive() then
		net.Start("pulse")
		net.Send(owner)
	end
end
