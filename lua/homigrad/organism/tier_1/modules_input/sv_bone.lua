--local Organism = hg.organism
local player_crush_amputation_threshold = 7

util.AddNetworkString("hg_play_client_sound_file")

local function isCrush(dmgInfo)
	return (not dmgInfo:IsDamageType(DMG_BULLET + DMG_BUCKSHOT + DMG_BLAST)) or dmgInfo:GetInflictor().RubberBullets
end

local function isMelee(dmgInfo)
	return dmgInfo:IsDamageType(DMG_SLASH + DMG_CLUB + DMG_GENERIC)
end

local halfValue2 = util.halfValue2
local function damageBone(org, bone, dmg, dmgInfo, key, boneindex, dir, hit, ricochet, nodmgchange)
	local crush = isCrush(dmgInfo)
	
	if dmgInfo:IsDamageType(DMG_SLASH) and dmg > 1.5 then
		//crush = false
	end
	
	local breakBoneMul = dmgInfo:GetInflictor().BreakBoneMul or 1
	if dmgInfo:IsDamageType(DMG_CLUB) then breakBoneMul = breakBoneMul * 0.8 end
	dmg = dmg * breakBoneMul
	
	if crush then
		crush = halfValue2(1 - org[key], 1, 0.5)
		dmg = dmg / math.max(6.5 * crush * (bone or 1), 1)
		if dmgInfo:GetInflictor().RubberBullets then dmg = dmg * dmgInfo:GetInflictor().Penetration end
	end

	local val = org[key]
	org[key] = math.min(org[key] + dmg, 1)
	local scale = 1 - (org[key] - val)
	
	if !nodmgchange then dmgInfo:ScaleDamage(1 - (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone))) end

	return (crush and 1 * crush * math.max((1 - org[key]) ^ 0.1, 0.5) or (1 - org[key]) * (bone)), VectorRand(-0.2,0.2) / math.Clamp(dmg,0.4,0.8)
end

local bonefracture_sounds = {
	"bonefracture/rem_bonebreak1.wav",
	"bonefracture/rem_bonebreak2.wav",
	"bonefracture/rem_bonebreak3.wav",
}

local skullfracture_sounds = {
	"skullfracture/SkullFracture-1.wav",
	"skullfracture/SkullFracture-2.wav",
	"skullfracture/SkullFracture-3.wav",
	"skullfracture/SkullFracture-4.wav",
	"skullfracture/SkullFracture-5.wav",
	"skullfracture/SkullFracture-6.wav",
	"skullfracture/SkullFracture-7.wav",
}

local function playBoneFractureSound(ent)
	if not IsValid(ent) then return end
	local org = ent.organism
	local soundEnt = org and IsValid(org.forcedBoneBreakSoundEnt) and org.forcedBoneBreakSoundEnt or ent
	local recipient = org and org.forcedBoneBreakRecipient
	local filter
	if IsValid(recipient) and recipient:IsPlayer() then
		filter = RecipientFilter()
		filter:AddPAS(soundEnt:GetPos())
		filter:AddPlayer(recipient)
	end
	soundEnt:EmitSound(bonefracture_sounds[math.random(#bonefracture_sounds)], 75, math.random(135, 155), 1, CHAN_AUTO, 0, 0, filter)
end

local function playSkullFractureSound(ent)
	if not IsValid(ent) then return end
	ent:EmitSound(skullfracture_sounds[math.random(#skullfracture_sounds)], 75, math.random(90, 110), 1, CHAN_AUTO)
end

local huyasd = {
	["spine1"] = "I don't feel anything below my hips.",
	["spine2"] = "I cant't feel or move anything below my torso.",
	["spine3"] = "I can't move at all. I can barely even breathe.",
	["skull"] = "My head is aching.",
}

local broke_arm = {
	"AAAAH OH GOD, IT'S BROKEN! MY ARM! IT'S BROKEN!",
	"FUCK MY FUCKING ARM IS BROKEN!",
	"NONONO MY ARM IS BENT ALL WRONG!",
	"IT'S.. MY ARM.. SNAPPED- I HEARD IT SNAP!",
	"MY ARM IS NOT SUPPOSED TO BEND IN HALF!",
}

local dislocated_arm = {
	"MY ARM- GOD, IT'S POPPED OUT OF THE SOCKET!",
	"FUCK- THE SHOULDER'S JUST- HANGING LOOSE!",
	"MY ARM..! IT'S DISLOCATED! I CAN SEE THE BULGE WHERE IT'S WRONG!",
	"THE ARM'S JUST- DEAD WEIGHT- IT'S NOT ATTACHED RIGHT!",
	"SHIT! I CAN FEEL THE BONE OUT OF PLACE!",
}

local broke_leg = {
	"MY LEG- FUCK, IT'S BROKEN- I HEARD THE SNAP!",
	"FUCK! THE SHIN'S SNAPPED CLEAN THROUGH!",
	"THE KNEE'S WRONG- THE WHOLE LEG'S TWISTED WRONG!",
	"MY LEG..! IT'S JUST- HANGING BY MUSCLE AND SKIN!",
	"THE PAIN'S SHOOTING UP TO MY HIP- FUCK, IT'S BAD!",
	"I CAN'T MOVE MY FOOT- THE ANKLE'S BROKEN TOO!",
}

local dislocated_leg = {
	"MY LEG- FUCK, IT'S DISLOCATED AT THE KNEE!",
	"I CAN SEE THE KNEECAP IN THE WRONG PLACE!",
	"AGHH- THE HIP'S POPPED OUT- IT'S STUCK OUTWARD!",
	"IT'S BENT BACKWARD- THE KNEE SHOULDN'T BEND THIS WAY!",
	"FUCK! THE HIP'S DISLOCATED!",
	"THE ANKLE'S TWISTED- BUT THE KNEE'S THE REAL PROBLEM!",
}

local limbName = {
	rleg = "right leg",
	lleg = "left leg",
	rarm = "right arm",
	larm = "left arm",
}

local function sendThought(org, msg, key, delay, clr)
	if org.isPly and IsValid(org.owner) and org.owner.Thought then
		org.owner:Thought(msg, delay or 1, key, 0, clr)
	end
end

local function doDislocate(org, key, dmg, segment)
	org[key.."dislocation"] = true
	if hg.fakeBoneFlop then
		hg.fakeBoneFlop.SetLimbSegmentState(org, key, segment, not org[key.."stabilized"])
	end

	local stabilized = org[key.."stabilized"]
	if not stabilized then
		org.painadd = org.painadd + 35
		org.immobilization = org.immobilization + dmg * 10
	else
		org.painadd = org.painadd + 10
		org.immobilization = org.immobilization + dmg * 3
	end
	org.owner:AddNaturalAdrenaline(0.5)
	org.fearadd = org.fearadd + 0.5

	sendThought(org, "Your " .. limbName[key] .. " is dislocated.", "thought_dislocated" .. key, 1, Color(255, 220, 220))

	timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
	playBoneFractureSound(org.owner)
	if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 1) end
end

local function hasNewThoughts(org)
	return org.isPly and IsValid(org.owner) and org.owner:GetInfoNum("hg_newthoughts", 0) > 0
end

local function legs(org, bone, dmg, dmgInfo, key, segment, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 2.5
	local amputateThreshold = org.isPly and player_crush_amputation_threshold or 4

	if not org.NoDismembermentPhysics and dmgInfo:IsDamageType(DMG_CRUSH) and dmg > amputateThreshold and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]

	org[key] = org[key] * 0.5

	if dmg < 0.5 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then
		if math.Rand(0, 1) >= 0.5 then return 0 end
		doDislocate(org, key, dmg, segment)
		hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 2, "Legs bone damage harm")
		return result, vecrand
	end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end

	local stabilized = org[key.."stabilized"]
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1
		if hg.fakeBoneFlop then
			hg.fakeBoneFlop.SetLimbSegmentState(org, key, segment, not stabilized)
		end

		if not stabilized then
			org.painadd = org.painadd + 55
			org.immobilization = org.immobilization + dmg * 25
		else
			org.painadd = org.painadd + 10
			org.immobilization = org.immobilization + dmg * 5
		end
		org.owner:AddNaturalAdrenaline(1)
		org.fearadd = org.fearadd + 0.5

		sendThought(org, "Your " .. limbName[key] .. " is broken.", "thought_broke" .. key, 1, Color(255, 210, 210))

		timer.Simple(0, function() hg.LightStunPlayer(org.owner,2) end)
		playBoneFractureSound(org.owner)
		if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 1.35) end
	else
		doDislocate(org, key, dmg, segment)
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 2, "Legs bone damage harm")

	return result, vecrand
end

local function arms(org, bone, dmg, dmgInfo, key, segment, boneindex, dir, hit, ricochet)
	local oldDmg = org[key]
	local dmg = dmg * 2.5
	local amputateThreshold = org.isPly and player_crush_amputation_threshold or 4
	
	if not org.NoDismembermentPhysics and dmgInfo:IsDamageType(DMG_CRUSH) and dmg > amputateThreshold and !org[key.."amputated"] then
		hg.organism.AmputateLimb(org, key)

		return 0
	end

	if org[key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, key, boneindex, dir, hit, ricochet)
	
	local dmg = org[key]
	
	org[key] = org[key] * 0.5

	if dmg < 0.5 then return 0 end
	if dmg < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then
		if math.Rand(0, 1) >= 0.5 then return 0 end
		doDislocate(org, key, dmg, segment)
		hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 1.5, "Arms bone damage harm")
		return result, vecrand
	end

	if org.isPly and !org[key.."amputated"] then org.just_damaged_bone = CurTime() end

	local stabilized = org[key.."stabilized"]
	
	if dmg >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[key] = 1
		if hg.fakeBoneFlop then
			hg.fakeBoneFlop.SetLimbSegmentState(org, key, segment, not stabilized)
		end

		if not stabilized then
			org.painadd = org.painadd + 55
			org.immobilization = org.immobilization + dmg * 25
		else
			org.painadd = org.painadd + 10
			org.immobilization = org.immobilization + dmg * 5
		end
		org.owner:AddNaturalAdrenaline(1)
		org.fearadd = org.fearadd + 0.5

		sendThought(org, "Your " .. limbName[key] .. " is broken.", "thought_broke" .. key, 1, Color(255, 210, 210))

		playBoneFractureSound(org.owner)
		if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 1.35) end
	else
		doDislocate(org, key, dmg, segment)
	end

	hg.AddHarmToAttacker(dmgInfo, (org[key] - oldDmg) * 1.5, "Arms bone damage harm")

	if org[key] == 1 and key == "rarm" and org.isPly then
		local wep = org.owner.GetActiveWeapon and org.owner:GetActiveWeapon()
		
		/*if IsValid(wep) then
			local inv = org.owner:GetNetVar("Inventory",{})
			if not (inv["Weapons"] and inv["Weapons"]["hg_sling"] and ishgweapon(wep) and not wep:IsPistolHoldType()) then
				hg.drop(org.owner)
			else
				org.owner:SetActiveWeapon(org.owner:GetWeapon("weapon_hands_sh"))
			end
		end*/
	end

	return result, vecrand
end

local function spine(org, bone, dmg, dmgInfo, number, boneindex, dir, hit, ricochet)
	if dmgInfo:IsDamageType(DMG_BLAST) then dmg = dmg / 3 end

	local name = "spine" .. number
	local name2 = "fake_spine" .. number
	if org[name] >= hg.organism[name2] then return 0 end
	local oldDmg = org[name]

	local result, vecrand = damageBone(org, 0.1, dmgInfo:IsDamageType(DMG_SLASH) and dmg * 0.6 or dmg * 0.4, dmgInfo, name, boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 5, "Spine bone damage harm")
	
	if (name == "spine3" || name == "spine2") then
		hg.AddHarmToAttacker(dmgInfo, (org[name] - oldDmg) * 8, "Broken spine harm")
	end

	if org[name] >= hg.organism[name2] and org.isPly then
		playBoneFractureSound(org.owner)
		if hg.QueuePainScream then hg.QueuePainScream(org.owner, 1.1) end
		if org.owner:IsPlayer() and !hasNewThoughts(org) then
			org.owner:Notify(huyasd[name], true, name, 2)
		end
		sendThought(org, "Your spine is broken.", "thought_" .. name, 4, Color(255, 210, 210))
		org.painadd = org.painadd + 25
	end
	
	if dmg > 0.2 then
		--org.owner:Notify("Your spinal cord is damaged.",true,"spinalcord",4)
	end

	org.painadd = org.painadd + dmg * 2
	timer.Simple(0, function() hg.LightStunPlayer(org.owner) end)
	org.shock = org.shock + dmg * 5
	return result,vecrand
end

local jaw_broken_msg = {
	"I FEEL PIECES OF MY JAW... FUCK-FUCK-FUCK",
	"MY JAW IS FUCKING FLOATING IN MY HEAD",
	"MY JAW... OHH IT HURTS REALLY BAD... I FEEL PIECES OF IT MOVING",
}

local jaw_dislocated_msg = {
	"I CAN'T CLOSE MY JAW... IT FUCKING HURTS",
	"MY JAW... ITS JUST STUCK THERE-- OH ITS PAINING",
	"I CANT MOVE MY JAW AT ALL... AND ITS REALLY ACHING",
	//"I CANT EVEN SPEAK, I NEED TO PUNCH IT BACK IN PLACE... BUT IT HURTS REAL BAD",
}

local function shouldTriggerTinnitus(dmgInfo, damage, hasHelmet)
	if damage < 0.1 then return false end
	local chance = 30
	if dmgInfo:IsDamageType(DMG_CLUB) then
		chance = hasHelmet and 12 or 50
	elseif dmgInfo:IsDamageType(DMG_SLASH) then
		chance = hasHelmet and 8 or 20
	end
	return math.random(100) <= chance
end

local function manageTinnitusSound(org, targetPlayer)
	if not IsValid(targetPlayer) or not targetPlayer:IsPlayer() then return end
	if org.skull >= 0.6 then
		if not org.tinnitusLongPlaying then
			org.tinnitusLongPlaying = true
			targetPlayer:PlayCustomTinnitus("tinnituslong.wav")
			local timerName = "TinnitusCheck_" .. targetPlayer:SteamID64()
			timer.Create(timerName, 8.0, 0, function()
				if not IsValid(targetPlayer) or not targetPlayer:Alive() or org.skull < 0.6 then
					timer.Remove(timerName)
					org.tinnitusLongPlaying = false
					targetPlayer:StopCustomTinnitus()
					return
				end
				targetPlayer:PlayCustomTinnitus("tinnituslong.wav")
			end)
		end
	else
		if org.tinnitusLongPlaying then
			org.tinnitusLongPlaying = false
			local timerName = "TinnitusCheck_" .. targetPlayer:SteamID64()
			timer.Remove(timerName)
			targetPlayer:StopCustomTinnitus()
		end
	end
end

hook.Add("Org Think", "TinnitusDisorientation", function(owner, org, timeValue)
	if not org or not org.tinnitusLongPlaying then return end
	if not owner:IsPlayer() or not owner:Alive() or org.skull < 0.6 then return end
	local hasHelmet = owner.armors and owner.armors["head"] != nil
	local rate = (hasHelmet and 0.02 or 0.06) * timeValue * 10
	org.disorientation = math.min(org.disorientation + rate, 1.5)
end)

local input_list = hg.organism.input_list
local toothModel = Model("models/phobias/general/tooth/tooth.mdl")
local toothFallbackModel = Model("models/grub_nugget_small.mdl")

local function SpawnTeeth(org, count, hitPos, forceDir)
	local owner = org.owner
	if not IsValid(owner) then return end

	local character = hg.GetCurrentCharacter(owner)
	if not IsValid(character) then character = owner end

	local pos = isvector(hitPos) and hitPos or nil
	if not pos then
		local headBone = character:LookupBone("ValveBiped.Bip01_Head1")
		pos = headBone and character:GetBonePosition(headBone) or character:WorldSpaceCenter()
	end

	local direction = isvector(forceDir) and forceDir:GetNormalized() or character:GetForward()
	local baseVelocity = character:GetVelocity()
	local model = util.IsValidModel(toothModel) and toothModel or toothFallbackModel

	for _ = 1, math.min(count, 6) do
		local tooth = ents.Create("prop_physics")
		if not IsValid(tooth) then continue end

		tooth:SetModel(model)
		tooth:SetPos(pos + VectorRand(-1.5, 1.5))
		tooth:SetAngles(AngleRand())
		tooth:SetModelScale(math.Rand(0.85, 1.1), 0)
		tooth:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		tooth:Spawn()
		tooth:Activate()

		local phys = tooth:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetMass(0.05)
			phys:SetVelocity(baseVelocity + direction * math.Rand(90, 180) + VectorRand(-55, 55) + vector_up * math.Rand(20, 70))
			phys:AddAngleVelocity(VectorRand(-500, 500))
		end

		tooth:AddCallback("PhysicsCollide", function(ent, data)
			if ent.toothLanded or data.Speed < 45 then return end
			ent.toothLanded = true
			ent:EmitSound("physics/plaster/drywall_impact_hard" .. math.random(3) .. ".wav", 45, math.random(145, 165), 0.25)
		end)

		timer.Simple(18, function()
			if IsValid(tooth) then tooth:SetModelScale(0, 2) end
		end)
		SafeRemoveEntityDelayed(tooth, 20)
	end

	local effect = EffectData()
	effect:SetOrigin(pos)
	effect:SetNormal(direction)
	util.Effect("BloodImpact", effect, true, true)
end

input_list.jaw = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.jaw
	local incomingDmg = dmg
	local rawDamageType = dmgInfo:GetDamageType()

	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "jaw", boneindex, dir, hit, ricochet)
	local jawDelta = math.max(org.jaw - oldDmg, 0)
	org.teethLost = math.Clamp(org.teethLost or 0, 0, 32)

	if jawDelta > 0 and incomingDmg >= 0.12 and org.teethLost < 32 then
		local typeMul = 0.35
		if bit.band(rawDamageType, DMG_CLUB) ~= 0 then
			typeMul = 1.35
		elseif bit.band(rawDamageType, DMG_CRUSH) ~= 0 or bit.band(rawDamageType, DMG_FALL) ~= 0 then
			typeMul = 1.15
		elseif bit.band(rawDamageType, DMG_BUCKSHOT) ~= 0 then
			typeMul = 1
		elseif bit.band(rawDamageType, DMG_BULLET) ~= 0 then
			typeMul = 0.75
		elseif bit.band(rawDamageType, DMG_BLAST) ~= 0 then
			typeMul = 0.55
		elseif bit.band(rawDamageType, DMG_SLASH) ~= 0 then
			typeMul = 0.25
		end

		local severity = math.Clamp(incomingDmg * 0.55 + jawDelta * 1.6, 0, 2)
		local chance = math.Clamp((severity - 0.12) * 0.42 * typeMul, 0, 0.85)
		if math.Rand(0, 1) < chance then
			local lost = math.random(1, math.Clamp(math.ceil(severity * 3.5 * typeMul), 1, 8))
			if (org.jaw == 1 and oldDmg < 1) or severity > 1.25 then
				lost = lost + math.random(1, 4)
			end

			lost = math.min(lost, 32 - org.teethLost)
			org.teethLost = org.teethLost + lost
			SpawnTeeth(org, lost, hit, dir)
			org.painadd = math.min((org.painadd or 0) + 4 + lost * 3, 150)
			org.shock = math.min((org.shock or 0) + 1 + lost * 1.5, 95)
			hg.AddHarmToAttacker(dmgInfo, lost * 0.08, "Teeth loss harm")

			if IsValid(org.owner) and hg.organism.AddWoundManual then
				hg.organism.AddWoundManual(org.owner, math.min(4 + lost * 2, 18), Vector(1, -3, 0), angle_zero, "ValveBiped.Bip01_Head1", CurTime())
				org.owner:EmitSound("physics/flesh/flesh_bloody_impact_hard1.wav", 65, math.random(105, 120), 0.7)
			end

			if org.isPly then
				local message = lost == 1 and "You lost a tooth." or ("You lost " .. lost .. " teeth.")
				if !hasNewThoughts(org) then org.owner:Notify(message, true, "teeth", 2) end
				sendThought(org, message, "thought_teeth", 3, Color(255, 210, 210))
			end
		end
	end

	hg.AddHarmToAttacker(dmgInfo, (org.jaw - oldDmg) * 3, "Jaw bone damage harm")

	if org.jaw == 1 and (org.jaw - oldDmg) > 0 and org.isPly then
		if !hasNewThoughts(org) then org.owner:Notify(jaw_broken_msg[math.random(#jaw_broken_msg)], true, "jaw", 2) end
		sendThought(org, "Your jaw is broken.", "thought_jaw", 4, Color(255, 210, 210))
	end

	local dislocated = (org.jaw - oldDmg) > math.Rand(0.1, 0.3)

	if org.jaw == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then
			playBoneFractureSound(org.owner)
			if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 1) end
		end
	end

	org.shock = org.shock + dmg * 3

	if dislocated then
		org.shock = org.shock + dmg * 20
		org.avgpain = org.avgpain + dmg * 20
		
		if !org.jawdislocation then
			playBoneFractureSound(org.owner)
			if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 0.85) end
		end

		org.jawdislocation = true

		if org.isPly then
			if !hasNewThoughts(org) then org.owner:Notify(jaw_dislocated_msg[math.random(#jaw_dislocated_msg)], true, "jaw", 2) end
			sendThought(org, "Your jaw is dislocated.", "thought_jawdislocated", 4, Color(255, 220, 220))
		end
	end

	if dmg > 0.2 then
		if org.isPly then timer.Simple(0, function() hg.LightStunPlayer(org.owner,1 + dmg) end) end
	end

	if (org.jaw - oldDmg) > 0.15 then
		local disorientationAdd = dmg * 0.5
		org.disorientation = math.min(org.disorientation + disorientationAdd, 1.5)

		if org.isPly and disorientationAdd > 0.1 and shouldTriggerTinnitus(dmgInfo, dmg, false) then
			local targetPlayer = org.owner
			if IsValid(org.owner.FakeRagdoll) then
				local ragdoll = org.owner.FakeRagdoll
				if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
			end
			if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
				targetPlayer:PlayCustomTinnitus("tinnitus.wav")
			end
		end
	end

	return result, vecrand
end

hook.Add("CanListenOthers", "CantHaveShitInDetroit", function(output, input, isChat, teamonly, text)
	if IsValid(output) and (output.organism.jaw == 1 or output.organism.jawdislocation) and output:Alive() and (output:IsSpeaking() or isChat) then
		-- and !isChat and output:IsSpeaking()
		output.organism.painadd = output.organism.painadd + 2 * (output:IsSpeaking() and 1 or (isChat and 5 or 0))
		if output:GetInfoNum("hg_newthoughts", 0) <= 0 then output:Notify("My jaw is really hurting when I speak.", 60, "painfromjawspeak", 0, nil, Color(255, 210, 210)) end
	end
end)

input_list.skull = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet, impact)
	local oldDmg = org.skull
	
	local result, vecrand = damageBone(org, 0.25, dmg, dmgInfo, "skull", boneindex, dir, hit, ricochet)
	local inflictor = dmgInfo:GetInflictor()
	local rawDamageType = impact and impact.rawDamageType or dmgInfo:GetDamageType()
	local isStab = bit.band(rawDamageType, DMG_SLASH) != 0 and not (IsValid(inflictor) and inflictor.slash)
	local helmet = org.owner.armors and org.owner.armors["head"]
	local functionalHelmet = helmet and hg.armor.head and hg.armor.head[helmet]
		and not (org.owner.armors_broken and org.owner.armors_broken[helmet])
	local helmetApplied = (org.lastHeadArmorMitigation or 1) < 1

	if isStab and functionalHelmet and helmetApplied then
		org.skull = oldDmg
	end
	if isMelee(dmgInfo) and oldDmg < 1 and org.skull < 1 and dmg > 0.3 and dmg < 1.35 then result = 1 end

	hg.AddHarmToAttacker(dmgInfo, (org.skull - oldDmg) * 4, "Skull bone damage harm")

	if org.skull == 1 then
		org.shock = org.shock + dmg * 40
		org.avgpain = org.avgpain + dmg * 30

		if oldDmg != 1 then
			playSkullFractureSound(org.owner)
			sendThought(org, "Your skull is broken.", "thought_skull", 4, Color(255, 180, 180))
		end
	end

	org.shock = org.shock + dmg * 3

	local rnd = math.random(10) == 1 or dmgInfo:IsDamageType(DMG_CRUSH)
	org.consciousness = math.Approach(org.consciousness, 0, rnd and dmg * 2 or 0)

	org.brain = math.min(org.brain + (rnd and dmg * 0.05 or 0), 1)

	if math.random(1, 4) == 1 then
		local eye_dmg = dmg * math.Rand(0.8, 1.5)
		if math.random(1, 2) == 1 then
			if hg.organism.input_list.eyeL then hg.organism.input_list.eyeL(org, bone, eye_dmg, dmgInfo) end
		else
			if hg.organism.input_list.eyeR then hg.organism.input_list.eyeR(org, bone, eye_dmg, dmgInfo) end
		end
	end

	if (org.skull - oldDmg) > 0.6 then
		org.brain = math.min(org.brain + 0.1, 1)
	end

	if org.brain >= 0.01 and math.random(3) == 1 and (rnd or (org.skull - oldDmg) > 0.6) then
		org.shock = 70
	end

	if dmg > 0.4 then
		if org.isPly then
			timer.Simple(0, function()
				hg.LightStunPlayer(org.owner,1 + dmg)
			end)
		end
	end
	
	org.shock = org.shock + (dmg > 1 and 50 or dmg * 10)

	if org.skull == 1 then
		if org.isPly then
			//org.owner:Notify(huyasd["skull"],true,"skull",4)
		end

		--[[if dir then
			net.Start("hg_bloodimpact")
			net.WriteVector(dmgInfo:GetDamagePosition())
			net.WriteVector(dir / 10)
			net.WriteFloat(3)
			net.WriteInt(1,8)
			net.Broadcast()
		end--]]
	end

	org.disorientation = math.min(org.disorientation + (isCrush(dmgInfo) and dmg * 1 or dmg * 1), 1.5)

	-- Realistic head trauma:
	--  - A helmet diffuses the blow: most of a weak/glancing hit is soaked up, so it
	--    mostly just rings (tinnitus) and barely concusses. You need a really solid
	--    impact to get through it.
	--  - A bare head is the dangerous case: the same hit reaches the skull directly and
	--    concusses far more easily and severely.
	--  - A light tap on the head (weak melee) is not a concussion either way.
	local hasHelmet = org.owner.armors and org.owner.armors["head"] != nil
	local effectiveDmg = hasHelmet and dmg * 0.3 or dmg
	local isBlunt = dmgInfo:IsDamageType(DMG_CLUB + DMG_CRUSH)

	-- Blunt melee (DMG_CLUB/DMG_CRUSH) is the classic cause of real concussions:
	-- a club, baton or fist to the head rattles the brain without breaking the
	-- skull. It concusses at a much lower threshold and higher chance than a
	-- bullet/blast would, because the force is transferred over a wider area.
	-- Bullets/explosions keep the old, harder threshold (effectiveDmg > 7).
	local concThreshold = isBlunt and 3 or 7
	if effectiveDmg > concThreshold then
		local baseChance, intensity
		if isBlunt then
			-- blunt: generous chance even at moderate blows, lower ceiling
			baseChance = math.Clamp((effectiveDmg - 3) / 18, 0.2, 0.95)
			intensity = math.Clamp(effectiveDmg * 0.4, 0.4, hasHelmet and 1.5 or 3.0)
		else
			-- chance + severity grow with how hard the (post-helmet) impact is
			baseChance = math.Clamp((effectiveDmg - 7) / 30, 0.12, 0.97)
			intensity = math.Clamp(effectiveDmg * 0.32, 0.5, hasHelmet and 1.2 or 4.0)
		end

		if math.random() < baseChance then
			hg.organism.module.concussion.AddConcussion(org, intensity, math.Clamp(intensity * 6, 6, 50))

			if org.isPly then
				local targetPlayer = org.owner
				if IsValid(org.owner.FakeRagdoll) then
					local ragdoll = org.owner.FakeRagdoll
					if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
				end
				if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
					targetPlayer:PlayCustomTinnitus("headhit.mp3")

					net.Start("headtrauma_concussion_update")
						net.WriteFloat(math.Clamp(intensity * 1.5, 1, 6))
						net.WriteFloat(org.concussion or 0)
					net.Send(targetPlayer)
				end
			end
		end
	else
		-- Light blow: no real concussion. Helmet just rings, bare head a tiny daze.
		if org.isPly then
			local targetPlayer = org.owner
			if IsValid(org.owner.FakeRagdoll) then
				local ragdoll = org.owner.FakeRagdoll
				if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
			end
			if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
				if hasHelmet then
					targetPlayer:PlayCustomTinnitus("headhit.mp3")
				else
					org.disorientation = math.min(org.disorientation + math.Clamp(effectiveDmg * 0.08, 0, 0.25), 1.5)
				end
			end
		end
	end

	if not isStab and dmg > 0.05 and not org.NoKnockdown then
		local headDmg = hasHelmet and dmg * 0.3 or dmg
		org.disorientation = math.min(org.disorientation + math.min(headDmg * 0.15, 1.5), 1.5)
		if headDmg > 0.5 and org.consciousness and org.consciousness < 0.85 then
			local fallChance = math.Clamp((headDmg - 0.5) * 0.04, 0.08, 0.55)
			if math.Rand(0, 1) < fallChance then
				org.needfake = true
			end
		end
	end

	if org.isPly and dmg > 0.3 then
		local targetPlayer = org.owner
		if IsValid(org.owner.FakeRagdoll) then
			local ragdoll = org.owner.FakeRagdoll
			if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
		end
		if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
			local impactSeverity = math.Clamp(dmg * 1.5, 0.5, 6)
			net.Start("headtrauma_concussion_update")
				net.WriteFloat(impactSeverity)
				net.WriteFloat(org.concussion or 0)
			net.Send(targetPlayer)
		end
	end

	if (org.skull - oldDmg) > 0.02 then
		local disorientationAdd = math.min(dmg * 1.5, 2.0)
		local hasHelmet = org.owner.armors and org.owner.armors["head"] != nil
		local effectiveDisorient = hasHelmet and disorientationAdd * 0.3 or disorientationAdd
		org.disorientation = math.min(org.disorientation + effectiveDisorient, 1.5)

		if org.isPly and effectiveDisorient > 0.05 then
			local targetPlayer = org.owner
			if IsValid(org.owner.FakeRagdoll) then
				local ragdoll = org.owner.FakeRagdoll
				if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
			end
			if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
				targetPlayer:PlayCustomTinnitus("headhit.mp3")
				if not hasHelmet or (org.skull - oldDmg) > 0.15 then
					manageTinnitusSound(org, targetPlayer)
				end
			end
		end

		if org.isPly and effectiveDisorient > 0.05 and shouldTriggerTinnitus(dmgInfo, dmg, hasHelmet) then
			local targetPlayer = org.owner
			if IsValid(org.owner.FakeRagdoll) then
				local ragdoll = org.owner.FakeRagdoll
				if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
			end
			if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
				targetPlayer:PlayCustomTinnitus("tinnitus.wav")
			end
		end
	elseif org.isPly then
		local targetPlayer = org.owner
		if IsValid(org.owner.FakeRagdoll) then
			local ragdoll = org.owner.FakeRagdoll
			if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
		end
		if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
			manageTinnitusSound(org, targetPlayer)
		end
	end

	if org.isPly and (org.brain - 0) > 0 and dmg > 0.5 then
		local targetPlayer = org.owner
		if IsValid(org.owner.FakeRagdoll) then
			local ragdoll = org.owner.FakeRagdoll
			if IsValid(ragdoll.ply) then targetPlayer = ragdoll.ply end
		end
		if IsValid(targetPlayer) and targetPlayer:IsPlayer() then
			local idx = math.random(1, 4)
			local snd = "concussion" .. idx .. ".mp3"
			net.Start("hg_play_client_sound_file")
				net.WriteString(snd)
			net.Send(targetPlayer)
		end
	end

	return result,vecrand
end

local ribs = {
	"MY CHEST... SNAPPED",
	"SOMETHING SNAPPED IN MY TORSO",
	"THERE'S SOMETHING SHARP IN MY CHEST...",
	"I FEEL SOMETHING SHARP IN MY TORSO",
}

input_list.chest = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)	
	local oldDmg = org.chest

	if dmgInfo:IsDamageType(DMG_SLASH+DMG_BULLET+DMG_BUCKSHOT) and math.random(5) == 1 then return 0, vector_origin end --random chance it passed through ribs

	local result, vecrand = damageBone(org, 0.1, dmg / 4, dmgInfo, "chest", boneindex, dir, hit, ricochet, true)
	
	hg.AddHarmToAttacker(dmgInfo, (org.chest - oldDmg) * 3, "Ribs bone damage harm")

	org.painadd = org.painadd + dmg * 1.5
	org.shock = org.shock + dmg * 1.5

	if org.isPly and (not org.brokenribs or (org.brokenribs ~= math.Round(org.chest * 3))) then
		org.brokenribs = math.Round(org.chest * 3)
		
		if org.brokenribs > 0 then
			//org.owner:Notify(ribs[math.random(#ribs)], 5, "ribs", 4)
			sendThought(org, "You broke " .. org.brokenribs .. " ribs.", "thought_ribs", 3, Color(255, 210, 210))

			playBoneFractureSound(org.owner)
			if hg.QueuePainScream then hg.QueuePainScream(org.owner, 0.8) end

			return math.min(0, result)
		end
	end

	return result * 0.5, vecrand
end

input_list.pelvis = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet)
	local oldDmg = org.pelvis
	org.painadd = org.painadd + dmg * 1
	org.shock = org.shock + dmg * 1

	local result = damageBone(org, 0.15, dmg * 0.5, dmgInfo, "pelvis", boneindex, dir, hit, ricochet)
	
	hg.AddHarmToAttacker(dmgInfo, (org.pelvis - oldDmg) / 2, "Pelvis bone damage harm")

	if org.isPly and org.pelvis == 1 then
		//org.owner:Notify("My pelvis is agonizingly hurting.", true, "pelvis", 4)
		sendThought(org, "Your pelvis is broken.", "thought_pelvis", 4, Color(255, 210, 210))
	end

	return result
end

local function upper_limb(org, bone, dmg, dmgInfo, amputate_key, limb_key, segment, boneindex, dir, hit, ricochet)
	local oldDmg = org[limb_key]
	local dmg = dmg * 2.0
	local amputateThreshold = org.isPly and player_crush_amputation_threshold or 4

	if dmgInfo:IsDamageType(DMG_CRUSH) and dmg > amputateThreshold and !org[amputate_key.."amputated"] then
		hg.organism.AmputateLimb(org, amputate_key)
		return 0
	end

	if org[limb_key] == 1 then return 0 end

	local result, vecrand = damageBone(org, 0.3, dmg, dmgInfo, limb_key, boneindex, dir, hit, ricochet)

	local d = org[limb_key]
	org[limb_key] = org[limb_key] * 0.5

	if d < 0.5 then return 0 end
	if d < 1 and !dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) then
		if math.Rand(0, 1) >= 0.5 then return 0 end
		doDislocate(org, limb_key, d, segment)
		return result, vecrand
	end

	if org.isPly and !org[amputate_key.."amputated"] then org.just_damaged_bone = CurTime() end

	local stabilized = org[limb_key.."stabilized"]

	if d >= 1 and (!dmgInfo:IsDamageType(DMG_CLUB+DMG_CRUSH+DMG_FALL) or math.random(3) != 1) then
		org[limb_key] = 1
		if hg.fakeBoneFlop then
			hg.fakeBoneFlop.SetLimbSegmentState(org, limb_key, segment, not stabilized)
		end

		if not stabilized then
			org.painadd = org.painadd + 55
			org.immobilization = org.immobilization + d * 25
		else
			org.painadd = org.painadd + 10
			org.immobilization = org.immobilization + d * 5
		end
		org.owner:AddNaturalAdrenaline(1)
		org.fearadd = org.fearadd + 0.5

		playBoneFractureSound(org.owner)
		if org.isPly and hg.QueuePainScream then hg.QueuePainScream(org.owner, 1.35) end
	else
		doDislocate(org, limb_key, d, segment)
	end

	hg.AddHarmToAttacker(dmgInfo, (org[limb_key] - oldDmg) * 1.5, "Upper limb bone damage harm")

	return result, vecrand
end

input_list.rarmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return upper_limb(org, bone * 1.25, dmg, dmgInfo, "rarmup", "rarm", "up", boneindex, dir, hit, ricochet) end
input_list.rarmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "rarm", "down", boneindex, dir, hit, ricochet) end
input_list.larmup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return upper_limb(org, bone * 1.25, dmg, dmgInfo, "larmup", "larm", "up", boneindex, dir, hit, ricochet) end
input_list.larmdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return arms(org, bone, dmg, dmgInfo, "larm", "down", boneindex, dir, hit, ricochet) end
input_list.rlegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return upper_limb(org, bone, dmg * 1.25, dmgInfo, "rlegup", "rleg", "up", boneindex, dir, hit, ricochet) end
input_list.rlegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "rleg", "down", boneindex, dir, hit, ricochet) end
input_list.llegup = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return upper_limb(org, bone, dmg * 1.25, dmgInfo, "llegup", "lleg", "up", boneindex, dir, hit, ricochet) end
input_list.llegdown = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return legs(org, bone, dmg, dmgInfo, "lleg", "down", boneindex, dir, hit, ricochet) end
input_list.spine1 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 1, boneindex, dir, hit, ricochet) end
input_list.spine2 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 2, boneindex, dir, hit, ricochet) end
input_list.spine3 = function(org, bone, dmg, dmgInfo, boneindex, dir, hit, ricochet) return spine(org, bone, dmg, dmgInfo, 3, boneindex, dir, hit, ricochet) end

hook.Add("Org Think", "homigrad_bone_stabilization", function(owner, org, timeValue)
	if not org.alive then return end

	org._zsh_stab_prev = org._zsh_stab_prev or {}

	for _, info in ipairs({
		{key = "larm", segs = {"up", "down"}},
		{key = "rarm", segs = {"up", "down"}},
		{key = "lleg", segs = {"up", "down"}},
		{key = "rleg", segs = {"up", "down"}},
	}) do
		local key = info.key
		local stabilized = org[key .. "stabilized"]
		local broke = (org[key] or 0) >= 0.95 or org[key .. "dislocation"]

		if not stabilized or not broke then
			org._zsh_stab_prev[key] = false
		else
			local prev = org._zsh_stab_prev[key]
			if not prev then
				if hg.fakeBoneFlop then
					for _, seg in ipairs(info.segs) do
						hg.fakeBoneFlop.SetLimbSegmentState(org, key, seg, false)
					end
				end
				org.painadd = math.max(org.painadd - 25, 0)
				org.immobilization = math.max(org.immobilization - (broke and 100 or 40), 0)
			end

			org.painadd = math.Approach(org.painadd, 0, timeValue * 5)
			org.immobilization = math.Approach(org.immobilization, 0, timeValue * 10)

			org._zsh_stab_prev[key] = true
		end
	end
end)

hook.Add("PlayerDisconnected", "CleanupTinnitusSounds", function(ply)
	if IsValid(ply) then
		local timerName = "TinnitusCheck_" .. ply:SteamID64()
		timer.Remove(timerName)
		if ply.organism then
			ply.organism.tinnitusLongPlaying = false
		end
	end
end)

hook.Add("PlayerDeath", "CleanupTinnitusOnDeath", function(ply)
	if IsValid(ply) then
		local timerName = "TinnitusCheck_" .. ply:SteamID64()
		timer.Remove(timerName)
		ply:StopCustomTinnitus()
		if ply.organism then
			ply.organism.tinnitusLongPlaying = false
		end
	end
end)
