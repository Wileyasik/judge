local MODE = MODE
MODE.NetSize_ChemicalResistanceBits = 8

local ChokeVictimSounds = {
	"painSounds/fiberWire1.mp3",
	"painSounds/fiberWire2.mp3",
}

if(SERVER)then
	-- во время удушения жертва не может встать сама (только выбраться борьбой)
	hook.Add("Should Fake Up", "HMCD_ChokeBlockGetUp", function(ply)
		if(ply.BeingVictimOfChoke)then return true end
	end)

	-- регдолл жертвы не сталкивается с душащим игроком:
	-- иначе на высокой скорости он сбивает его с ног (hg.LightStunPlayer)
	hook.Add("ShouldCollide", "HMCD_ChokeNoCollideAttacker", function(ent1, ent2)
		if(not IsValid(ent1) or not IsValid(ent2))then return end

		local rag, ply
		if(ent1:IsRagdoll() and ent2:IsPlayer())then
			rag, ply = ent1, ent2
		elseif(ent2:IsRagdoll() and ent1:IsPlayer())then
			rag, ply = ent2, ent1
		else
			return
		end

		local data = ply.Ability_Choke
		if(data and data.Victim and data.Victim.FakeRagdoll == rag)then
			return false
		end
	end)
end
local chemical_degrade_speeds = {
	["HCN"] = 1,
	["KCN"] = 0.5,
}

MODE.DisarmReach = 90
MODE.NoDisarmWeapons = {
	["weapon_hands_sh"] = true,
}

--\\
function MODE.GetPlayerTraceToOtherVictim(ply, victim, dist)
	if(IsValid(victim))then
		local ragdoll = victim.FakeRagdoll or victim:GetNWEntity("RagdollDeath", victim.FakeRagdoll)
		
		if(IsValid(ragdoll))then
			--
		else
			ragdoll = victim
		end
		
		local bone_id = ragdoll:LookupBone("ValveBiped.Bip01_Spine2")
		
		if(bone_id)then
			local bone_matrix = ragdoll:GetBoneMatrix(bone_id)
			
			if(bone_matrix)then
				local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
				local ply_offset_normal = pos - ply:GetShootPos()
				local ply_aim_normal = ply:GetAimVector()
					
				ply_offset_normal:Normalize()
				ply_aim_normal:Normalize()
				
				local ang_diff = -(math.deg(math.acos(ply_aim_normal:DotProduct(-ply_offset_normal))) - 180)
				
				if(ang_diff < 80)then
					local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply, ply_offset_normal, dist)
					
					if(IsValid(aim_ent))then
						return aim_ent, other_ply, trace
					else
						return MODE.GetPlayerTraceToOther(ply, dist)
					end
				else
					return MODE.GetPlayerTraceToOther(ply, dist)
				end
			end
		end
	end
end
--//

--\\Neck Break
function MODE.CanPlayerBreakOtherNeck(ply, aim_ent)
	if(aim_ent:IsRagdoll())then
		local bone_id = aim_ent:LookupBone("ValveBiped.Bip01_Head1")
		
		if(bone_id)then
			local bone_matrix = aim_ent:GetBoneMatrix(bone_id)
			
			if(bone_matrix)then
				local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
				local other_normal = -ang:Right()
				local ply_normal = pos - ply:GetShootPos()
				local dist_z = math.abs(pos.z - ply:GetShootPos().z)
				
				if(dist_z < 50) then
					ply_normal:Normalize()
					
					local ang_diff = -(math.deg(math.acos(ply_normal:DotProduct(other_normal))) - 180)
					
					if(ang_diff < 100)then
						return true
					end
				end
			end
		end
	elseif(aim_ent:IsPlayer())then
		local other_angle = aim_ent:EyeAngles()[2]
		local ply_angle = (aim_ent:GetPos() - ply:GetPos()):Angle()[2] --ply:EyeAngles()[2]
		local ang_diff = math.abs(math.AngleDifference(other_angle, ply_angle))
		
		if(ang_diff < 100)then
			return true
		end
	end
	
	return false
end

function MODE.BreakOtherNeck(ply, other_ply, aim_ent)
	if(other_ply:Alive())then
		other_ply:ViewPunch(Angle(0, 0, -10))
		hg.BreakNeck(aim_ent, ply, aim_ent)
	end
end

function MODE.StartBreakingOtherNeck(ply, other_ply)
	ply.Ability_NeckBreak = {
		Victim = other_ply,
		Progress = 0,
	}
	other_ply.BeingVictimOfNeckBreak = true
	
	if(SERVER)then
		other_ply:ViewPunch(Angle(0, -10, -10))
		
		net.Start("HMCD_BeingVictimOfNeckBreak")
			net.WriteBool(true)
		net.Send(other_ply)
		
		net.Start("HMCD_BreakingOtherNeck")
			net.WriteBool(true)
			net.WriteEntity(ply)
			net.WriteEntity(other_ply)
		net.SendPVS(ply:GetShootPos())
	end
end

function MODE.StopBreakingOtherNeck(ply)
	if(ply.Ability_NeckBreak and IsValid(ply.Ability_NeckBreak.Victim))then
		ply.Ability_NeckBreak.Victim.BeingVictimOfNeckBreak = false
	end
	
	if(SERVER and ply.Ability_NeckBreak and IsValid(ply.Ability_NeckBreak.Victim))then
		net.Start("HMCD_BeingVictimOfNeckBreak")
			net.WriteBool(false)
		net.Send(ply.Ability_NeckBreak.Victim)

		net.Start("HMCD_BreakingOtherNeck")
			net.WriteBool(false)
			net.WriteEntity(ply)
		net.SendPVS(ply:GetShootPos())
	end
	
	ply.Ability_NeckBreak = nil
end

function MODE.ContinueBreakingOtherNeck(ply)
	local break_data = ply.Ability_NeckBreak
	local victim = break_data.Victim
	local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOtherVictim(ply, victim)
	
	if(IsValid(aim_ent) and (aim_ent:IsPlayer() or aim_ent:IsRagdoll()))then
		if(IsValid(victim) and victim:Alive() and MODE.CanPlayerBreakOtherNeck(ply, aim_ent) and other_ply == victim)then
			break_data.Progress = break_data.Progress + FrameTime() * 300
			
			if(break_data.Progress >= 100)then
				if(SERVER)then
					MODE.BreakOtherNeck(ply, break_data.Victim, aim_ent)
				end
				
				
				MODE.StopBreakingOtherNeck(ply)
			end
		else
			MODE.StopBreakingOtherNeck(ply)
		end
	else
		MODE.StopBreakingOtherNeck(ply)
	end
end

hook.Add("HG_MovementCalc_2", "HMCD_SubRole_Abilities", function(mul, ply, cmd)
	if(ply.BeingVictimOfNeckBreak or ply.BeingVictimOfDisarmament or ply.BeingVictimOfChoke)then
		mul[1] = mul[1] * 0.3
	end
end)
--//

--\\Choke
function MODE.CanPlayerChokeOther(ply, aim_ent)
	-- душить можно только вплотную: отойти чуть дальше — захват срывается
	if(IsValid(ply) and IsValid(aim_ent) and ply:GetPos():DistToSqr(aim_ent:GetPos()) > 75 * 75)then
		return false
	end

	-- уже в фэйке / без сознания (но жив) — можно душить с любой стороны
	if(aim_ent:IsRagdoll() and IsValid(aim_ent.ply) and aim_ent.ply:Alive())then return true end

	if(aim_ent:IsPlayer())then
		local other_angle = aim_ent:EyeAngles()[2]
		local ply_angle = (aim_ent:GetPos() - ply:GetPos()):Angle()[2]
		local ang_diff = math.abs(math.AngleDifference(other_angle, ply_angle))

		if(ang_diff < 120)then
			return true
		end
	end

	return false
end

function MODE.StartChokingOther(ply, other_ply)
	if(not other_ply.organism)then return false end
	if(ply.Ability_Choke)then return false end

	-- "прибит к полу" (уже лежит в рагдолле) / заклеен скотчем — выбраться будет тяжелее
	local wasDown = IsValid(other_ply.FakeRagdoll)
	local taped = other_ply:GetNetVar("ducttaped_hands", false) or other_ply:GetNetVar("ducttaped_legs", false)

	ply.Ability_Choke = {
		Victim = other_ply,
		Progress = 0,
		Struggle = 0,
		Pinned = wasDown or false,
		Taped = taped or false,
	}
	other_ply.BeingVictimOfChoke = true

if(SERVER)then
			if(not IsValid(other_ply.FakeRagdoll))then hg.Fake(other_ply) end
			local rag = other_ply.FakeRagdoll
			if(IsValid(rag))then
				rag.StrangleLocked = true
				rag._brawler_old_collision = rag._fiberwire_spawn_colgroup or rag:GetCollisionGroup()
				rag:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				if(other_ply.organism and other_ply.organism.o2)then
					other_ply._brawler_o2regen = other_ply.organism.o2.regen
					other_ply.organism.o2.regen = 0
					other_ply.organism.o2.curregen = 0
				end
			end
		hg.SetFreemove(other_ply, false)
		other_ply:ViewPunch(Angle(0, -10, -10))

		net.Start("HMCD_BeingVictimOfChoke")
			net.WriteBool(true)
		net.Send(other_ply)

		net.Start("HMCD_ChokingOther")
			net.WriteBool(true)
			net.WriteEntity(ply)
			net.WriteEntity(other_ply)
		net.SendPVS(ply:GetShootPos())
	end
end

function MODE.StopChokingOther(ply)
	local data = ply.Ability_Choke
	if(data and IsValid(data.Victim))then
		local victim = data.Victim
		victim.BeingVictimOfChoke = false

		if(SERVER)then
			local rag = victim.FakeRagdoll
			if(IsValid(rag))then
				rag.StrangleLocked = nil
				if(rag._brawler_old_collision)then
					rag:SetCollisionGroup(rag._brawler_old_collision)
					rag._brawler_old_collision = nil
				end
			end
			if(victim.organism and victim.organism.o2)then
				victim.organism.o2.regen = victim._brawler_o2regen or victim.organism.o2.regen
				victim.organism.o2.curregen = victim.organism.o2.regen
			end
			victim._brawler_o2regen = nil
			hg.SetFreemove(victim, true)
			-- жертва остаётся лежать в регдолле: встаёт сама клавишей (FakeUp)
			--if(victim:Alive())then hg.FakeUp(victim) end

			net.Start("HMCD_BeingVictimOfChoke")
				net.WriteBool(false)
			net.Send(victim)

			net.Start("HMCD_ChokingOther")
				net.WriteBool(false)
				net.WriteEntity(ply)
			net.SendPVS(ply:GetShootPos())
		end
	end

	ply.Ability_Choke = nil
end

function MODE.ContinueChokingOther(ply)
	local ability_data = ply.Ability_Choke
	local victim = ability_data.Victim

	if(IsValid(victim) and victim:Alive() and IsValid(victim.FakeRagdoll) and ply:GetPos():DistToSqr(victim.FakeRagdoll:GetPos()) <= 85 * 85)then
		if(SERVER)then
			local org = victim.organism
			if(org and org.o2)then
				org.o2.regen = 0
				org.o2.curregen = 0

				-- удушение медленнее: кислород уходит дольше, но и выбраться сложнее
				local drainMul = 0.5 + (ability_data.Pinned and 0.2 or 0) + (ability_data.Taped and 0.2 or 0)
				org.o2[1] = math.max(org.o2[1] - FrameTime() * ((org.o2.range or 30) / 16) * drainMul, 0)
				ability_data.Progress = 100 * (1 - math.Clamp(org.o2[1] / (org.o2.range or 30), 0, 1))
			end

			local rag = victim.FakeRagdoll
			if(IsValid(rag))then
				-- как в weapon_hg_wire: жёстко держим только голову у хвата,
				-- а тело просто висит/обвисает — без паразитных вращений
				local grip
				if(ability_data.Pinned)then
					grip = ply:GetPos() + ply:GetForward() * 20 + Vector(0, 0, 32)
				else
					grip = ply:GetPos() + ply:GetForward() * 8 + Vector(0, 0, 52)
				end

				local headPhysNum = hg.realPhysNum and hg.realPhysNum(rag, 10)
				local headPhys = headPhysNum and rag:GetPhysicsObjectNum(headPhysNum)
				if(IsValid(headPhys))then
					local headAng = ply:EyeAngles()
					headAng.pitch = headAng.pitch - 10
					headPhys:SetPos(grip)
					headPhys:SetAngles(headAng)
					headPhys:SetVelocity(vector_origin)

					-- изредка лёгкое подрагивание рук (борьба), как ShadowControl в wire
					local strugg = ability_data.Progress < 85
					local lh = hg.realPhysNum and hg.realPhysNum(rag, 5)
					local rh = hg.realPhysNum and hg.realPhysNum(rag, 7)
					local lHand = lh and rag:GetPhysicsObjectNum(lh)
					local rHand = rh and rag:GetPhysicsObjectNum(rh)
					if(IsValid(lHand) and IsValid(rHand))then
						local sway = math.sin(CurTime() * 2) * 2
						if(not strugg)then sway = 0 end
						lHand:SetPos(headPhys:GetPos() + ply:GetRight() * -3 + Vector(0, 0, -6) + Vector(sway, -sway, 0))
						rHand:SetPos(headPhys:GetPos() + ply:GetRight() * 3 + Vector(0, 0, -6) + Vector(-sway, sway, 0))
						lHand:SetVelocity(vector_origin)
						rHand:SetVelocity(vector_origin)
				end

				if(not rag._hmcd_choke_sound or rag._hmcd_choke_sound < CurTime())then
					rag:EmitSound(ChokeVictimSounds[math.random(#ChokeVictimSounds)], 72, math.Clamp(victim.VoicePitch or 100, 85, 115), 0.9, CHAN_VOICE)
					rag._hmcd_choke_sound = CurTime() + 1.5
				end
			end

			-- выбраться тем сложнее, чем больше жертва не может сопротивляться
			local escapeMul = 1
			if(ability_data.Taped)then escapeMul = escapeMul * 0.4 end
			if(ability_data.Pinned)then escapeMul = escapeMul * 0.5 end

			if(victim:KeyDown(IN_USE) or victim:KeyDown(IN_JUMP))then
				ability_data.Struggle = ability_data.Struggle + FrameTime() * 40 * escapeMul
			else
				ability_data.Struggle = math.max(ability_data.Struggle - FrameTime() * 60, 0)
			end

			net.Start("HMCD_ChokeProgress")
				net.WriteFloat(ability_data.Progress)
			net.Send(ply)

			if(ability_data.Struggle >= 100)then
				MODE.StopChokingOther(ply)
				return
			end
		end
	else
		MODE.StopChokingOther(ply)
	end
end
--\\Disarm
function MODE.CanPlayerDisarmOtherPly(ply, other_ply)
	--[[if(other_ply and IsValid(other_ply:GetActiveWeapon()))then
		if(MODE.NoDisarmWeapons[other_ply:GetActiveWeapon():GetClass()])then
			return false
		end
	else
		return false
	end--]]

	if(IsValid(other_ply) and other_ply:IsPlayer() and other_ply.SubRole == "traitor_martialartist")then
		return false
	end

	return true
end

function MODE.CanPlayerDisarmOther(ply, aim_ent)
	if(aim_ent:IsRagdoll())then
		local bone_id = aim_ent:LookupBone("ValveBiped.Bip01_Spine2")
		
		if(bone_id)then
			local bone_matrix = aim_ent:GetBoneMatrix(bone_id)
			
			if(bone_matrix)then
				local pos, ang = bone_matrix:GetTranslation(), bone_matrix:GetAngles()
				local other_normal = ang:Right()
				local ply_normal = pos - ply:GetShootPos()
				local dist_z = math.abs(pos.z - ply:GetShootPos().z)
				
				if(dist_z < 50) then
					ply_normal:Normalize()
					
					local ang_diff = -(math.deg(math.acos(ply_normal:DotProduct(other_normal))) - 180)
					
					if(ang_diff < 90)then
						return 2
					else
						return 1.5
					end
				end
			end
		end
	elseif(aim_ent:IsPlayer())then
		local other_angle = aim_ent:EyeAngles()[2]
		local ply_angle = (aim_ent:GetPos() - ply:GetPos()):Angle()[2] --ply:EyeAngles()[2]
		local ang_diff = math.abs(math.AngleDifference(other_angle, ply_angle))
		
		if(ang_diff < 70)then
			return 2
		else
			return 1.5
		end
	end
	
	return false
end

function MODE.DisarmOther(ply, other_ply, aim_ent)
	if(IsValid(other_ply) and other_ply.SubRole == "traitor_martialartist")then return end

	if(other_ply:Alive())then
		local weapon = other_ply:GetActiveWeapon()

		if(IsValid(weapon) and !weapon.NoDrop)then
			other_ply:DropWeapon(weapon)
			ply:PickupWeapon(weapon, false)
		end

		hg.LightStunPlayer(other_ply)
		timer.Simple(0,function()
			local rag = hg.GetCurrentCharacter(other_ply)
			if IsValid(rag) and rag ~= other_ply then
				local bon = rag:LookupBone("ValveBiped.Bip01_Head1")
				local physnum = rag:TranslateBoneToPhysBone(bon)
				local phys = rag:GetPhysicsObjectNum(physnum)
				local dist = 25--phys:GetPos():Distance(ply:EyePos())
				
				hg.SetCarryEnt2(ply, rag, bon, phys:GetMass(), Vector(-2,0,0), ply:GetAimVector() * dist + ply:EyeAngles():Up() * 5 + ply:EyeAngles():Right() * -5 + ply:GetShootPos(), ply:EyeAngles() + Angle(-90, 90, 0))
			end
		end)
	end
end

function MODE.StartDisarmingOther(ply, other_ply)
	ply.Ability_Disarm = {
		Victim = other_ply,
		Progress = 0,
	}
	other_ply.BeingVictimOfDisarmament = true
	
	if(SERVER)then
		-- other_ply:ViewPunch(Angle(0, -10, -10))
		
		net.Start("HMCD_BeingVictimOfDisarmament")
			net.WriteBool(true)
		net.Send(other_ply)
		
		net.Start("HMCD_DisarmingOther")
			net.WriteBool(true)
			net.WriteEntity(other_ply)
		net.Send(ply)
	end
end

function MODE.StopDisarmingOther(ply)
	if(ply.Ability_Disarm and IsValid(ply.Ability_Disarm.Victim))then
		ply.Ability_Disarm.Victim.BeingVictimOfDisarmament = false
	end
	
	if(SERVER and ply.Ability_Disarm and IsValid(ply.Ability_Disarm.Victim))then
		net.Start("HMCD_BeingVictimOfDisarmament")
			net.WriteBool(false)
		net.Send(ply.Ability_Disarm.Victim)

		net.Start("HMCD_DisarmingOther")
			net.WriteBool(false)
		net.Send(ply)
	end
	
	ply.Ability_Disarm = nil
end

function MODE.ContinueDisarmingOther(ply)
	local ability_data = ply.Ability_Disarm
	local victim = ability_data.Victim
	local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOtherVictim(ply, victim, MODE.DisarmReach)
	
	if(IsValid(aim_ent) and (aim_ent:IsPlayer() or aim_ent:IsRagdoll()))then
		local disarm_strength = MODE.CanPlayerDisarmOther(ply, aim_ent)
		
		if(IsValid(victim) and victim:Alive() and disarm_strength and other_ply == victim and MODE.CanPlayerDisarmOtherPly(ply, other_ply))then
			ability_data.Progress = ability_data.Progress + FrameTime() * 250 * disarm_strength
			
			if(ability_data.Progress >= 100)then
				if(SERVER)then
					MODE.DisarmOther(ply, victim, aim_ent)
				end
				
				
				MODE.StopDisarmingOther(ply)
			end
		else
			MODE.StopDisarmingOther(ply)
		end
	else
		MODE.StopDisarmingOther(ply)
	end
end

hook.Add("PlayerSwitchWeapon", "HMCD_SubRole_Abilities", function(ply)
	if(ply.BeingVictimOfDisarmament)then
		return true
	end
end)

MODE.MAMoves = {
    { id = "mw_giantswing", name = "Floor Giantswing", dir = "floor" },
    { id = "mw_dyli_front", name = "Dying Light Front", dir = "front" },
    { id = "mw_suplex",    name = "Suplex Deluxe", dir = "back" },
    { id = "mw_necktrauma", name = "Neck Trauma",   dir = "back" },
    { id = "mw_cagematch", name = "Cage Match", dir = "back" },
    { id = "mw_sweetdreams", name = "Sweet Dreams", dir = "back" },
}

if SERVER then
	local maMoveCategories = {
		mw_dyli_front = "disarm",
		mw_suplex = "knockdown",
		mw_necktrauma = "knockdown",
		mw_cagematch = "knockdown",
		mw_sweetdreams = "knockdown"
	}
	local maCooldowns = {
		disarm = 8,
		knockdown = 8
	}
	local maLimbNames = {
		larm = "left arm",
		rarm = "right arm",
		lleg = "left leg",
		rleg = "right leg"
	}

	function MODE.MAForceUncon(target, duration)
		if not IsValid(target) or not target:Alive() or not target.organism then return end
		local org = target.organism
		org.consciousness = 0
		org.needotrub = true
		org.needfake = true
		org.disorientation = math.min((org.disorientation or 0) + 10, 10)
		org.immobilization = math.min((org.immobilization or 0) + 40, 90)
		org.painadd = math.min((org.painadd or 0) + 30, 150)
		if not IsValid(target.FakeRagdoll) then hg.Fake(target, nil, true) end
		timer.Simple(duration or 6, function()
			if not IsValid(target) or not target:Alive() or not target.organism then return end
			local org = target.organism
			org.consciousness = 1
			org.needotrub = false
			org.needfake = false
			org.disorientation = math.min((org.disorientation or 0) + 8, 10)
			org.immobilization = math.min((org.immobilization or 0) + 30, 90)
		end)
	end

	hook.Add("EntityTakeDamage", "MMA_MoveProtection", function(ent, dmg)
		if not IsValid(ent) then return end
		local ply = ent:IsPlayer() and ent or (IsValid(ent.ply) and ent.ply)
		if not IsValid(ply) or ply.SubRole ~= "traitor_martialartist" then return end
		if (ply.WWE_HoldDownUntil or 0) > CurTime() then
			dmg:SetDamage(0)
			return true
		end
	end, 0.5)

	local function dislocateMALimb(target)
		if not IsValid(target) or not target:Alive() or not target.organism or target.organism.superfighter then return end

		local available = {}
		for limb in pairs(maLimbNames) do
			if not target.organism[limb .. "dislocation"] and not target.organism[limb .. "amputated"] then
				available[#available + 1] = limb
			end
		end
		if #available == 0 then return end

		local limb = available[math.random(#available)]
		local org = target.organism
		org[limb .. "dislocation"] = true
		org.painadd = math.min((org.painadd or 0) + 25, 150)
		org.shock = math.min((org.shock or 0) + 8, 95)
		target:EmitSound("physics/body/body_medium_break" .. math.random(2, 4) .. ".wav", 70, math.random(90, 105))
		target:Notify("Your " .. maLimbNames[limb] .. " was dislocated by the takedown.", true, "ma_dislocation", 3)
	end

	function MODE.RunMartialArtistMove(ply, moveId, target)
		if not IsValid(ply) or not ply:Alive() or ply.SubRole ~= "traitor_martialartist" then return false end
		if not (WWE and WWE.moves and WWE.moves[moveId]) then return false end

		local category = maMoveCategories[moveId]
		if moveId ~= "mw_giantswing" and not category then return false end

		ply.MACooldowns = ply.MACooldowns or {}
		if category and (ply.MACooldowns[category] or 0) > CurTime() then return false end

		local success = WWE.RunMove(ply, moveId)
		if not success then return false end

		if not IsValid(target) then
			target = ply.WWE_LastTarget
		end

		if category then
			ply.MACooldowns[category] = CurTime() + maCooldowns[category]
		end

		if IsValid(target) then
			if moveId == "mw_giantswing" then
				local org = target.organism
				if org then
					org.disorientation = math.min((org.disorientation or 0) + 8, 10)
					org.immobilization = math.min((org.immobilization or 0) + 25, 90)
					org.painadd = math.min((org.painadd or 0) + 20, 150)
					if not IsValid(target.FakeRagdoll) then hg.Fake(target, nil, true) end
				end
			else
				MODE.MAForceUncon(target, 8)
			end
		end

		if category == "knockdown" and IsValid(target) and math.Rand(0, 1) < 0.6 then
			timer.Simple(0.8, function()
				dislocateMALimb(target)
			end)
		end

		return true
	end

    util.AddNetworkString("HMCD_MA_Move")
    util.AddNetworkString("HMCD_MA_MoveList")
    util.AddNetworkString("HMCD_MA_RequestList")

    -- Push the list of Martial Artist moves (id + display name) to the client.
    function MODE.SendMAMoveList(ply)
        local list = {}
        for _, m in ipairs(MODE.MAMoves) do
            if WWE and WWE.moves and WWE.moves[m.id] then
                list[#list + 1] = m
            end
        end
        net.Start("HMCD_MA_MoveList")
        net.WriteUInt(#list, 8)
        for _, m in ipairs(list) do
            net.WriteString(m.id)
            net.WriteString(m.name)
            net.WriteString(m.dir)
        end
        net.Send(ply)
    end

    hook.Add("PlayerSpawn", "HMCD_MA_SendMoveList", function(ply)
		ply.MACooldowns = nil
        if ply.SubRole == "traitor_martialartist" then
            MODE.SendMAMoveList(ply)
        end
    end)

    -- Respond to a client request (covers any spawn-timing edge cases)
    net.Receive("HMCD_MA_RequestList", function(len, ply)
        if ply.SubRole == "traitor_martialartist" then
            MODE.SendMAMoveList(ply)
        end
    end)

    -- Execute a z_wwe move on behalf of the Martial Artist.
    -- WWE.RunMove resolves the target via the attacker's aim and runs the move.
    net.Receive("HMCD_MA_Move", function(len, ply)
        if ply.SubRole ~= "traitor_martialartist" then return end
        if not ply:Alive() then return end

        local moveId = net.ReadString()
		local _, target = MODE.GetPlayerTraceToOther(ply, nil, 160)
		MODE.RunMartialArtistMove(ply, moveId, target)
    end)
end

if CLIENT then
    MODE.WWEMoveList = MODE.WWEMoveList or {}

    net.Receive("HMCD_MA_MoveList", function()
        local n = net.ReadUInt(8)
        MODE.WWEMoveList = {}
        for i = 1, n do
            MODE.WWEMoveList[#MODE.WWEMoveList + 1] = {
                id = net.ReadString(),
                name = net.ReadString(),
                dir = net.ReadString(),
            }
        end
    end)

    -- returns the nearby living player we could perform a move on (or nil)
    local function MA_GetTarget()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return nil end
        local reach = 110
        local tr = util.TraceHull({
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:EyeAngles():Forward() * reach,
            mins = Vector(-14, -14, -14),
            maxs = Vector(14, 14, 14),
            filter = ply,
            mask = MASK_SHOT_HULL,
        })
        local ent = tr.Entity
        if IsValid(ent) and ent:IsPlayer() and ent ~= ply and ent:Alive() then
            return ent
        end
        return nil
    end

    -- MA moves are now triggered directly with Alt+E (see sv_subrole_abilities). Radial menu removed.
end
--//
