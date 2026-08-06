local Angle, Vector, AngleRand, VectorRand, math, hook, util, game = Angle, Vector, AngleRand, VectorRand, math, hook, util, game
local IsValid, math_Clamp = IsValid, math.Clamp

--\\ Smooth UnRagdoll
	local vecSmall = Vector(0.01, 0.01, 0.01)
	function hg.SmoothUnfake(ent, ply)
		if ply.gettingup and (ply.gettingup + 1 - CurTime()) > 0 and IsValid(ply) then
			for i = 0, ent:GetBoneCount() - 1 do
				local m1 = ent:GetBoneMatrix(i)
				local m2 = ply:GetBoneMatrix(i)

				if not m1 or not m2 then continue end

				local k = math_Clamp(1 - (ply.gettingup + 0.8 - CurTime()) / 0.8, 0, 1)

				local q1 = Quaternion()
				q1:SetMatrix(m1)

				local q2 = Quaternion()
				q2:SetMatrix(m2)

				local q3 = q1:SLerp(q2, k)

				local newmat = Matrix()
				newmat:SetTranslation(LerpVector(k, m1:GetTranslation(), m2:GetTranslation()))
				newmat:SetAngles(q3:Angle())
				newmat:SetScale(m1:GetScale())

				if i == ent:LookupBone("ValveBiped.Bip01_Head1") and lply == GetViewEntity() and lply == ply then
					newmat:SetScale(vecSmall)
					//ply.headm = newmat
				end

				ent:SetBoneMatrix(i, newmat)
				ply:SetBoneMatrix(i, newmat)
			end
		end
	end
--//
--\\ DrawPlayerRagdoll
	local hg_ragdollcombat = ConVarExists("hg_ragdollcombat") and GetConVar("hg_ragdollcombat") or CreateConVar("hg_ragdollcombat", 0, FCVAR_REPLICATED, "Toggle ragdoll combat-like ragdoll mode (walking, running in ragdoll, etc.)", 0, 1)
	
	function hg.RagdollCombatInUse(ply)
		return hg_ragdollcombat:GetBool() and IsValid(ply.FakeRagdoll)
	end
	
	local hg_firstperson_ragdoll = ConVarExists("hg_firstperson_ragdoll") and GetConVar("hg_firstperson_ragdoll") or CreateConVar("hg_firstperson_ragdoll", "0", FCVAR_ARCHIVE, "Toggle first-person ragdoll camera view", 0, 1) --!! unused??
	local hg_firstperson_death = { GetBool = function() return false end }
	local hg_thirdperson = ConVarExists("hg_thirdperson") and GetConVar("hg_thirdperson") or CreateConVar("hg_thirdperson", 0, FCVAR_REPLICATED, "Toggle third-person camera view", 0, 1)
	local hg_gopro = ConVarExists("hg_gopro") and GetConVar("hg_gopro") or CreateClientConVar("hg_gopro", "0", true, false, "Toggle GoPro-like camera view", 0, 1)
	local hg_deathfadeout = CreateClientConVar("hg_deathfadeout", "1", true, true, "Toggle screen fade and sound mute on death", 0, 1)

	local vector_full = Vector(1, 1, 1)
	local vector_small = Vector(0.01, 0.01, 0.01)
	local angfuck = Angle()
	local hg_no_camera_in_cars = CreateConVar("hg_no_camera_in_cars","0",FCVAR_ARCHIVE + FCVAR_REPLICATED, "disables camera in cars", 0, 1)

	local bandageBGNames = {
		[0] = "belly",
		[1] = "groin",
		[2] = "belly",
		[3] = "Chest",
		[4] = "HandUpLeft",
		[5] = "HandDownLeft",
		[6] = "HandLeft",
		[7] = "HandUpRight",
		[8] = "HandDownRight",
		[9] = "HandRight",
		[10] = "LegUpLeft",
		[11] = "LegDownLeft",
		[12] = "LegUpRught",
		[13] = "LegDownRught",
	}

	local bandageHandsOnly = "00000010010000"

	function hg.RenderBandageGloves(ent, ply)
		local mdl = ply.PlayerClassName ~= "swat" and ply.PlayerClassName ~= "police" and ply:GetNWString("BandageGlovesMdl", "") or ""
		if mdl == "" then
			if IsValid(ent.bandageGlovesModel) then
				ent.bandageGlovesModel:Remove()
				ent.bandageGlovesModel = nil
			end
			return
		end

		if not IsValid(ent.bandageGlovesModel) or ent.bandageGlovesModel:GetModel() ~= mdl then
			if IsValid(ent.bandageGlovesModel) then ent.bandageGlovesModel:Remove() end
			ent.bandageGlovesModel = ClientsideModel(mdl, RENDERGROUP_BOTH)
			local model = ent.bandageGlovesModel
			ent:CallOnRemove("removebandagegloves", function()
				if IsValid(model) then
					model:Remove()
				end
			end)
		end

		local model = ent.bandageGlovesModel
		model:SetNoDraw(true)
		model:SetPos(ent:GetPos() + vector_up * 1)
		model:SetParent(ent)
		model:AddEffects(EF_BONEMERGE)

		local org = ply.organism or {}
		local amputatedHands = tostring(org.larmupamputated or org.larmamputated or org.lhandamputated) .. tostring(org.rarmupamputated or org.rarmamputated or org.rhandamputated)
		if model.BandageAmputatedHands ~= amputatedHands then
			for i = 0, 13 do
				local charVal = string.byte(bandageHandsOnly, i + 1) - 48
				if i == 6 and (org.larmupamputated or org.larmamputated or org.lhandamputated) then charVal = 0 end
				if i == 9 and (org.rarmupamputated or org.rarmamputated or org.rhandamputated) then charVal = 0 end
				local bgName = bandageBGNames[i]
				if not bgName then continue end
				local bgIdx = model:FindBodygroupByName(bgName)
				if not bgIdx or bgIdx < 0 then bgIdx = model:FindBodygroupByName(bgName .. "-f") end
				if bgIdx and bgIdx >= 0 then model:SetBodygroup(bgIdx, charVal) end
			end
			model.BandageAmputatedHands = amputatedHands
		end

		local clr = ply.CurAppearance and ply.CurAppearance.AColor
			or (ply.GetNWVector and ply:GetNWVector("PlayerColor", nil))
			or (ply.GetPlayerColor and ply:GetPlayerColor())
		if clr then
			if IsColor(clr) then
				render.SetColorModulation(clr.r / 255, clr.g / 255, clr.b / 255)
			elseif isvector(clr) then
				render.SetColorModulation(clr.x, clr.y, clr.z)
			end
		end

		model:DrawModel()

		if clr then
			render.SetColorModulation(1, 1, 1)
		end
	end

	function DrawPlayerRagdoll(ent, ply) --// actually not only ragdoll render but player too
		if ply.prevragdoll_index != nil and ply.prevragdoll_index != ply.ragdoll_index and ply.ragdoll_index == 0 then
			//print(ply.ragdoll_index, ply.prevragdoll_index, Entity(ply.ragdoll_index))

			ply.gettingup = CurTime()
			ply.OldRagdoll = Entity(ply.prevragdoll_index)
			ply.FakeRagdollOld = ply.OldRagdoll
		end
		ply.prevragdoll_index = ply.ragdoll_index

		local wep = ply.GetActiveWeapon and ply:GetActiveWeapon()

		local lkp = ent.LookupBone and ent:LookupBone("ValveBiped.Bip01_Head1")
		if !ent.GetManipulateBoneScale or !lkp then return end

		if IsValid(ply.OldRagdoll) then
			ply:SetupBones()
		end

		hg.RenderWeapons(ent, ply)

		ent:SetupBones()

		if IsValid(wep) and wep.PrepareMeleeWorldModel then
			wep:PrepareMeleeWorldModel()
		end

		hg.MainTPIKFunction(ent, ply, wep)

		if IsValid(ply.OldRagdoll) then
			hg.SmoothUnfake(ent, ply)
		end

		if ply:GetNetVar("handcuffed", false) then hg.CuffedAnim(ent, ply) end

		if IsValid(wep) then
			//if wep.isTPIKBase then hg.RenderTPIKBase(ent, ply, wep) end
			//if wep.ismelee then hg.RenderMelees(ent, ply, wep) end
			if wep.DrawWorldModel2 then wep:DrawWorldModel2() end
		end

		local armors = ply:GetNetVar("Armor") or ent.PredictedArmor
		local hideArmorRender = ply:GetNetVar("HideArmorRender", false) or ent.PredictedHideArmorRender
		if armors and next(armors) and not hideArmorRender then
			RenderArmors(ply, armors, ent)
		end

		if hg.RenderDefibs then hg.RenderDefibs(ent, ply) end

		hg.RenderBandages(ent, ply)

		hg.RenderBandageGloves(ent, ply)

		hg.RenderTourniquets(ent, ply)

		hg.GoreCalc(ent, ply)

		--local current = ent:GetManipulateBoneScale(lkp)
		local fountains = GetNetVar("fountains") or {}
		local wawanted = (GetViewEntity() != ply) and !fountains[ent] and (!(!lply:Alive() and lply:GetNWEntity("spect") == ply and viewmode == 1) and !(hg_firstperson_death:GetBool() and follow == ent)) and vector_full or vector_small
		--print(ent, wawanted, GetViewEntity(), ply, (GetViewEntity() != ply), !fountains[ent], !(!lply:Alive() and lply:GetNWEntity("spect") == ply and viewmode == 1))
		--if !current:IsEqualTol(wawanted, 0.01) then
			--ent:ManipulateBoneScale(lkp, wawanted)
			local mat = ent:GetBoneMatrix(lkp)
			if !(Glide and Glide.Camera and !Glide.Camera.isInFirstPerson and lply == ply and lply:InVehicle() and hg_no_camera_in_cars:GetBool()) then
				if (!hg_thirdperson:GetBool() and !hg_gopro:GetBool() and (ent == ply or (!hg_ragdollcombat:GetBool() or hg_firstperson_ragdoll:GetBool()))) or (hg_firstperson_death:GetBool() and follow == ent) then
					mat:SetScale(wawanted)
				end
			end
			--angfuck[3] = -GetViewPunchAngles2()[2] - GetViewPunchAngles3()[2]

			--local _, ang = LocalToWorld(vector_origin, angfuck, vector_origin, mat:GetAngles())
			--mat:SetAngles(ang)

			hg.bone_apply_matrix(ent, lkp, mat)
		--end

		--hg.CoolGloves(ent, ply, wep)

		hg.ProjectilesDraw(ent, ply)

		if ply:GetNetVar("headcrab") then hg.RenderHeadcrab(ent, ply) end
	end
--//
