local MODE = MODE

util.AddNetworkString("HMCD_BeingVictimOfNeckBreak")	--; А тут я значит рещил без скобок да крутой кодинг стиль вопросы?
util.AddNetworkString("HMCD_BreakingOtherNeck")
util.AddNetworkString("HMCD_BeingVictimOfDisarmament")
util.AddNetworkString("HMCD_DisarmingOther")
util.AddNetworkString("HMCD_UpdateChemicalResistance")
util.AddNetworkString("HMCD_BeingVictimOfChoke")
util.AddNetworkString("HMCD_ChokingOther")
util.AddNetworkString("HMCD_ChokeProgress")

--\\Brawler: melee-only enforcement + fragile from behind
hook.Add("PlayerCanPickupWeapon", "Brawler_MeleeOnly", function(ply, wep)
	if(ply.SubRole ~= "traitor_brawler")then return end
	local class = wep:GetClass()
	if(class == "weapon_hands_sh" or class == "weapon_hg_coolhands")then return end

	local ammo = wep:GetPrimaryAmmoType()
	if(ammo and ammo ~= 0 and ammo ~= "" and ammo ~= "none")then
		wep:SetClip1(0)
		if(wep.SetClip2)then wep:SetClip2(0) end
		ply:SetAmmo(0, ammo)
	end
end)

hook.Add("PlayerSwitchWeapon", "Brawler_MeleeOnly", function(ply, oldw, neww)
	if(ply.BeingVictimOfChoke)then
		return true
	end
end)

hook.Add("EntityTakeDamage", "Brawler_BackKnockdown", function(ent, dmginfo)
	if(not IsValid(ent) or not ent:IsPlayer() or not ent:Alive())then return end
	if(ent.SubRole ~= "traitor_brawler")then return end
	local att = dmginfo:GetAttacker()
	if(not IsValid(att) or not att:IsPlayer() or att == ent)then return end
	local toAtt = (att:GetPos() - ent:GetPos()):GetNormalized()
	if(ent:GetForward():Dot(toAtt) > 0.2)then return end
	if((ent.BrawlerKnockCD or 0) > CurTime())then return end
	ent.BrawlerKnockCD = CurTime() + 2
	hg.LightStunPlayer(ent, 1.2)
end)
--//

--\\Chemical resistance
	function MODE.NetworkChemicalResistanceOfPlayer(ply)
		ply.PassiveAbility_ChemicalAccumulation = ply.PassiveAbility_ChemicalAccumulation or {}
		
		net.Start("HMCD_UpdateChemicalResistance")
		
		for chemical_name, amt in pairs(ply.PassiveAbility_ChemicalAccumulation) do
			net.WriteString(chemical_name)
			net.WriteUInt(math.Round(amt), MODE.NetSize_ChemicalResistanceBits)
		end
		
		net.WriteString("")
		net.Send(ply)
	end
--//

hook.Add("PlayerPostThink", "HMCD_SubRoles_Abilities", function(ply)
	if(MODE.RoleChooseRoundTypes[MODE.Type])then
		if(ply:Alive() and ply.organism and not ply.organism.otrub)then
			if(ply.SubRole == "traitor_infiltrator" or ply.SubRole == "traitor_infiltrator_soe")then
				if(ply:KeyDown(IN_WALK))then
					if(ply:KeyPressed(IN_RELOAD))then
						local aim_ent, other_ply = hg.eyeTrace(ply,85).Entity
						other_ply = hg.RagdollOwner(aim_ent) or aim_ent
						
						if(IsValid(aim_ent) and aim_ent:IsRagdoll())then	--; REDO
							local other_appearance = aim_ent.CurAppearance
							local your_appearance = ply.CurAppearance

							local aMdl1,aMdl2 = your_appearance.AModel,other_appearance.AModel
							
							other_appearance.AModel = aMdl1
							your_appearance.AModel = aMdl2

							local aFace1,aFace2 = your_appearance.AFacemaps,other_appearance.AFacemaps

							other_appearance.AFacemaps = aFace1
							your_appearance.AFacemaps = aFace2

							hg.Appearance.ForceApplyAppearance(ply, other_appearance, true)
							local char = hg.GetCurrentCharacter(ply)
							if char:IsRagdoll() then
								hg.Appearance.ForceApplyAppearance(char, other_appearance, true)
							end
							ply:EmitSound("snd_jack_hmcd_disguise.wav",35,math.random(90,110),0.5)

							--local duplicator_data = duplicator.CopyEntTable(ply)
							--duplicator.DoGeneric(aim_ent, duplicator_data)
							aim_ent.CurAppearance = your_appearance

							hg.Appearance.ForceApplyAppearance(aim_ent, your_appearance, true)
							
							if other_ply:IsPlayer() and other_ply:Alive() then
								hg.Appearance.ForceApplyAppearance(other_ply, your_appearance, true)
							end
						end
					end
					
					if(ply:KeyPressed(IN_USE))then
						if(WWE and WWE.RunMove)then WWE.RunMove(ply, "dl_back") end
					end
				else
					MODE.StopBreakingOtherNeck(ply)
				end
			end
			
			if(ply.SubRole == "traitor_assasin" or ply.SubRole == "traitor_assasin_soe")then
				if(ply:KeyDown(IN_WALK))then
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply, trace = MODE.GetPlayerTraceToOther(ply, nil, MODE.DisarmReach)
						
						if(IsValid(aim_ent))then
							if(other_ply and MODE.CanPlayerDisarmOther(ply, aim_ent, MODE.DisarmReach) and MODE.CanPlayerDisarmOtherPly(ply, other_ply, MODE.DisarmReach))then
								MODE.StartDisarmingOther(ply, other_ply)
							end
						end
					elseif(ply:KeyDown(IN_USE))then
						if(ply.Ability_Disarm)then
							MODE.ContinueDisarmingOther(ply)
						end
					end
					
					if(ply:KeyReleased(IN_USE))then
						MODE.StopDisarmingOther(ply)
					end
				else
					MODE.StopDisarmingOther(ply)
				end
			end
			
			if(ply.SubRole == "traitor_brawler")then
				local w = ply:GetActiveWeapon()
				local cls = IsValid(w) and w:GetClass() or ""
				local hasHands = (cls == "weapon_hands_sh" or cls == "weapon_hg_coolhands")
				local wstore = IsValid(w) and weapons.GetStored(cls)
				local hasMelee = IsValid(w) and not hasHands and (cls == "weapon_hg_fists" or (wstore and wstore.Category == "Weapons - Melee"))

				if(IsValid(w) and cls ~= "weapon_matches")then
					local ammo = wstore and wstore.Primary and wstore.Primary.Ammo or "none"
					if(ammo ~= "none")then
						local clip = w:Clip1()
						if(ply._brawlerLastWep ~= cls)then
							ply._brawlerLastClip = clip
							ply._brawlerLastWep = cls
						end
						local reserve = ply:GetAmmoCount(w:GetPrimaryAmmoType())
						local prev = ply._brawlerLastClip or 0
						if(prev > 0 and clip == 0 and reserve == 0)then
							ply:DropWeapon(w)
							ply._brawlerLastClip = nil
							ply._brawlerLastWep = nil
						end
					else
						ply._brawlerLastClip = nil
						ply._brawlerLastWep = nil
					end
				else
					ply._brawlerLastClip = nil
					ply._brawlerLastWep = nil
				end

				if(ply:KeyDown(IN_WALK))then
					if(hasHands)then
						if(ply:KeyPressed(IN_USE))then
							local aim_ent, other_ply = MODE.GetPlayerTraceToOther(ply, nil, 100)

							if(IsValid(aim_ent) and other_ply and MODE.CanPlayerChokeOther(ply, aim_ent))then
								MODE.StartChokingOther(ply, other_ply)
							end
						elseif(ply:KeyDown(IN_USE))then
							if(ply.Ability_Choke)then
								MODE.ContinueChokingOther(ply)
							end
						end

						if(ply:KeyReleased(IN_USE))then
							MODE.StopChokingOther(ply)
						end
					elseif(hasMelee)then
					if(ply:KeyPressed(IN_USE))then
						local aim_ent, other_ply = MODE.GetPlayerTraceToOther(ply, nil, 160)

						if(IsValid(other_ply) and other_ply:IsPlayer() and other_ply:Alive()
							and not (IsValid(other_ply.FakeRagdoll) or IsValid(other_ply:GetNWEntity("FakeRagdoll"))))then

							local behindVec = ply:GetPos() - other_ply:GetPos()
							behindVec.z = 0
							local isBehind = behindVec:LengthSqr() > 1 and behindVec:GetNormalized():Dot(Angle(0, other_ply:EyeAngles().yaw, 0):Forward()) <= -0.4

							if(isBehind)then
								local name = (MH and MH.PickKill) and MH.PickKill(ply) or nil

								if(name)then
									local ok, err = MH.Play(ply, other_ply, name)

									if(not ok and IsValid(ply))then
										ply:ChatPrint("[Manhunt] " .. tostring(err or "execution failed"))
									end
								end
							end
						end
					end
					end
				else
					MODE.StopChokingOther(ply)
				end
			end

			if(ply.SubRole == "traitor_martialartist")then
				if(ply:KeyDown(IN_WALK) and ply:KeyPressed(IN_USE))then
					if(ply.Ability_Choke)then return end

					-- aimed at a ragdoll lying on the floor? pick it up with a giantswing
					if(WWE and WWE.moves and WWE.moves.mw_giantswing)then
						if(MODE.RunMartialArtistMove(ply, "mw_giantswing"))then return end
					end

					-- pick a move suited to our position relative to the target (front / back)
					local wantDir = "back"
					local action_ent, action_ply = MODE.GetPlayerTraceToOther(ply, nil, 160)
					if(IsValid(action_ply) and action_ply:IsPlayer() and action_ply:Alive())then
						local behindVec = ply:GetPos() - action_ply:GetPos()
						behindVec.z = 0
						local isBehind = behindVec:LengthSqr() > 1 and behindVec:GetNormalized():Dot(Angle(0, action_ply:EyeAngles().yaw, 0):Forward()) <= -0.4
						wantDir = isBehind and "back" or "front"
					end

					local moves = {}
					for _, m in ipairs(MODE.MAMoves and MODE.MAMoves or {}) do
						if(m.dir == wantDir)then moves[#moves + 1] = m.id end
					end
					if(#moves == 0)then return end

					local moveId = moves[math.random(#moves)]
					if(WWE and WWE.RunMove)then MODE.RunMartialArtistMove(ply, moveId, action_ply) end
				end
			end

			if(ply.SubRole == "traitor_zombie")then
				if(ply:KeyDown(IN_WALK))then
					
				end
			end

			if(ply.SubRole == "traitor_chemist")then
				DegradeChemicalsOfPlayer(ply)
				
				if(!ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime or ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime <= CurTime())then
					MODE.NetworkChemicalResistanceOfPlayer(ply)

					ply.PassiveAbility_ChemicalAccumulation_NextNetworkTime = CurTime() + 1
				end
			end
		end
	end
end)
