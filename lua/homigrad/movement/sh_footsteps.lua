local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local hook_Run = hook.Run
local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like camera view", 0, 1)
local hg_coolcamera = ConVarExists("hg_coolcamera") and GetConVar("hg_coolcamera") or CreateConVar("hg_coolcamera", 0, FCVAR_ARCHIVE + FCVAR_REPLICATED, "Cool camera movement", 0, 1)

--\\ custom footsteps
	local EmitSound, SoundDuration, hg, ViewPunch, CurTime, math, net, RecipientFilter = EmitSound, SoundDuration, hg, ViewPunch, CurTime, math, net, RecipientFilter
	local math_max = math.max
	local footstepNet = "hg_footstep_snd"
	local serverOnlyFootsteps = {
		headcrabzombie = true,
		Combine = true
	}

	local function PlayFootstepSound(snd, pos, ply, volume, soundLevel, pitch)
		EmitSound(snd, pos, IsValid(ply) and ply:EntIndex() or 0, CHAN_AUTO, volume or 1, soundLevel or 75, nil, pitch or 100)
	end

	if SERVER then
		util.AddNetworkString(footstepNet)
	end

	function hg.EmitFootstepSound(snd, pos, ply, volume, soundLevel, pitch)
		if SERVER then
			local rf = RecipientFilter()
			rf:AddAllPlayers()
			if IsValid(ply) and ply:IsPlayer() then rf:RemovePlayer(ply) end

			net.Start(footstepNet)
				net.WriteString(snd)
				net.WriteVector(pos)
				net.WriteEntity(ply)
				net.WriteFloat(volume or 1)
				net.WriteFloat(soundLevel or 75)
				net.WriteFloat(pitch or 100)
			net.Send(rf)
		else
			PlayFootstepSound(snd, pos, ply, volume, soundLevel, pitch)
		end
	end

	if CLIENT then
		net.Receive(footstepNet, function()
			PlayFootstepSound(net.ReadString(), net.ReadVector(), net.ReadEntity(), net.ReadFloat(), net.ReadFloat(), net.ReadFloat())
		end)
	end

	hook.Add("PlayerStepSoundTime", "hguhuy", function(ply, type, walking)
		return 1
	end)

	hook.Add("PlayerFootstep", "CustomFootstep2sad", function(ply, pos, foot, sound, volume, rf)
		if (ply.lastStepTime or 0) > CurTime() then return true end
		local vel = ply:GetVelocity()
		local len = vel:Length()
		local ent = hg.GetCurrentCharacter(ply)
		
		local sprint = hg.KeyDown(ply, IN_SPEED)
		local speed_mul = 1
		if ply.hg_isSprinting then
			speed_mul = 1.5
		elseif ply.hg_isJogging then
			speed_mul = 1.15
		end
		
		ply.lastStepTime = CurTime() + 0.7 * speed_mul * (1 / math_max(len, sprint and 200 or 150)) * 100

		if ply.PlayerClassName == "furry" then
			local wep = ply:GetActiveWeapon()
			if sprint and hg.KeyDown(ply, IN_WALK) and IsValid(wep) and wep:GetClass() == "weapon_hands_sh" then
				ply.lastStepTime = CurTime() + 0.4 * speed_mul * (1 / math_max(len, sprint and 200 or 150)) * 100
			end
		end

		hook_Run("HG_PlayerFootstep_Notify", ply, pos, foot, sound, volume, rf)	--; Do not return anything from this _Notify hook
		
		if CLIENT and ply == lply and ply.move then
			footcl = (footcl == nil and -1 or footcl) + 1
			if footcl > 1 then
				footcl = -1
			elseif footcl == 0 then
				footcl = 1
			end
			local mul = 1 * len / 300 * math_max((350 - ply.move) / 50, 0.4)
			local legsDamaged = ply.organism.rleg + ply.organism.lleg
			local mul2 = ((ply.organism.lleg or 0) * 3 + 1) * ((ply.organism.rleg or 0) * 3 + 1) * (hg_coolcamera:GetBool() and legsDamaged < 0.2 and 1.5 or 0.5)

			ViewPunch(Angle((hg_gopro:GetBool() and 5 or 1) * len / 200 * math_max((350 - ply.move) / 50, 1) * mul2, footcl * mul * mul2, footcl * mul * mul2))
		end

		if SERVER and ply.organism then
			local org = ply.organism
			org.painadd = org.painadd + ((org.lleg or 0) > 0.75 and (org.lleg - 0.75) or 0) + ((org.rleg or 0) > 0.75 and (org.rleg - 0.75) or 0)
		end

		if CLIENT and ply == lply then
			if serverOnlyFootsteps[ply.PlayerClassName] then return true end

			local Hook = hook_Run("HG_PlayerFootstep", ply, pos, foot, sound, volume, rf)
			if Hook then return true end

			if !(ply:IsWalking() or ply:Crouching()) and ent == ply then
				local snd
				if ply.PlayerClassName == "furry" then
					snd = "zbattle/footstep/hardbarefoot" .. math.random(1, 5) .. ".ogg"
				else
					snd = sound
				end
				if SoundDuration(snd) <= 0 or ply.PlayerClassName == "Gordon" then
					snd = sound
				end
				hg.EmitFootstepSound(snd, pos, ply, volume, 75, changePitch(math.random(95,105)))
			end
		end

		if SERVER then
			if ply:GetNetVar("Armor", {})["torso"] then
				EmitSound("arc9_eft_shared/weapon_generic_rifle_spin"..math.random(9)..".ogg", pos, ply:EntIndex(), CHAN_AUTO, changePitch(math.min(len / 100, 0.89)), 80)
			end

			local Hook = hook_Run("HG_PlayerFootstep", ply, pos, foot, sound, volume, rf)
			if Hook then return Hook end

			if !(ply:IsWalking() or ply:Crouching()) and ent == ply then
				local snd
				if ply.PlayerClassName == "furry" then
					snd = "zbattle/footstep/hardbarefoot" .. math.random(1, 5) .. ".ogg"
				else
					snd = sound
				end
				if SoundDuration(snd) <= 0 or ply.PlayerClassName == "Gordon" then
					snd = sound
				end
				hg.EmitFootstepSound(snd, pos, ply, volume, 75, changePitch(math.random(95,105)) )
			end
		end

		return true
	end)
--//
