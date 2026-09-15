if SERVER then
	local cv_enable        = CreateConVar("sdd_enable",                  "1",  FCVAR_ARCHIVE, "Enable or disable destructible doors")
	local cv_destroylocked = CreateConVar("sdd_can_destroy_locked_door", "1",  FCVAR_ARCHIVE, "Allow destroying locked doors")
	local cv_debristime    = CreateConVar("sdd_door_debris_fade_time",   "30", FCVAR_ARCHIVE, "How long (seconds) debris lasts before fading. 0 = no debris")
	local cv_respawn       = CreateConVar("sdd_door_respawn",            "0",  FCVAR_ARCHIVE, "Enable door respawning after destruction")
	local cv_respawndelay  = CreateConVar("sdd_door_respawn_delay",      "30", FCVAR_ARCHIVE, "Seconds before a destroyed door respawns")
	local cv_respawnblock  = CreateConVar("sdd_door_respawn_block",      "0",  FCVAR_ARCHIVE, "What to do if a player is in the door on respawn: 0 = wait, 1 = kill player")

	local VALID_DOOR_MODELS = {
		["models/props_c17/door01_left.mdl"]           = true,
		["models/props_c17/door02_double.mdl"]         = true,
		["models/props_doors/door03_slotted_left.mdl"] = true,
		["models/props_c17/door03_left.mdl"]           = true,
	}

	local DAMAGE_MODELS = {
		["models/props_c17/door01_left.mdl"] = {
			stage1 = "models/noob_dev2323/door/door01_left_damege_01.mdl",
			stage2 = "models/noob_dev2323/door/door01_left_damege_02.mdl",
		},
		["models/props_c17/door03_left.mdl"] = {
			stage1 = "models/noob_dev2323/door/door01_left_damege_01.mdl",
			stage2 = "models/noob_dev2323/door/door01_left_damege_02.mdl",
		},
		["models/props_doors/door03_slotted_left.mdl"] = {
			stage1 = "models/noob_dev2323/door/door01_left_damege_01.mdl",
			stage2 = "models/noob_dev2323/door/door01_left_damege_02.mdl",
		},
	}

	local DOOR_MAX_HEALTH = 800
	local DOOR_STAGE1_HEALTH = 600
	local DOOR_STAGE2_HEALTH = 400

	sound.Add({
		name    = "door_destroying",
		channel = CHAN_AUTO,
		volume  = 1,
		level   = 80,
		pitch   = { 95, 110 },
		sound   = {
			"wood_crate_break1.wav",
			"wood_crate_break2.wav",
			"wood_crate_break3.wav",
			"wood_crate_break4.wav",
			"wood_crate_break5.wav",
		}
	})

	local door_debris = {}

	local function SpawnDoorDebris(ent, model, dmginfo)
		local fadetime = cv_debristime:GetFloat()
		if fadetime == 0 then return end
		local debris = ents.Create("prop_physics")
		if not IsValid(debris) then return end

		local ang = ent:GetAngles()
		local forward = ang:Forward()
		local right = ang:Right()
		local offset = forward * (math.random(-5, 15)) + right * (math.random(-10, 10)) + Vector(0, 0, math.random(0, 5))

		debris:SetPos(ent:GetPos() + offset)
		debris:SetAngles(ang + Angle(math.random(-15, 15), math.random(-15, 15), math.random(-15, 15)))
		debris:SetModel(model)
		debris:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		debris:SetSkin(ent:GetSkin())
		debris:Spawn()
		debris:EmitSound("door_destroying")

		local phys = debris:GetPhysicsObject()
		if IsValid(phys) and dmginfo then
			local force = dmginfo:GetDamageForce()
			if force:Length() > 0 then
				phys:ApplyForceCenter(force * 0.5)
			end
		end

		if not door_debris[ent] then door_debris[ent] = {} end
		table.insert(door_debris[ent], debris)

		SafeRemoveEntityDelayed(debris, fadetime)
	end

	local function IsInsideDoor(ent, pos, mins, maxs)
		if not IsValid(ent) then return false end

		local doorPos = ent:GetPos()
		local doorAng = ent:GetAngles()

		if mins and maxs then

			local localMins = WorldToLocal(pos + mins, angle_zero, doorPos, doorAng)
			local localMaxs = WorldToLocal(pos + maxs, angle_zero, doorPos, doorAng)

			local doorMins = ent:OBBMins()
			local doorMaxs = ent:OBBMaxs()

			return (localMins.x < doorMaxs.x and localMaxs.x > doorMins.x) and
			       (localMins.y < doorMaxs.y and localMaxs.y > doorMins.y) and
			       (localMins.z < doorMaxs.z and localMaxs.z > doorMins.z)
		else

			local localPos = WorldToLocal(pos, angle_zero, doorPos, doorAng)
			local mins = ent:OBBMins()
			local maxs = ent:OBBMaxs()
			return localPos.x >= mins.x and localPos.x <= maxs.x and
			       localPos.y >= mins.y and localPos.y <= maxs.y and
			       localPos.z >= mins.z and localPos.z <= maxs.z
		end
	end

	local function IsEntityBlockingDoor(ent, target)
		if not IsValid(target) then return false end

		local pos = target:GetPos()
		local mins, maxs

		if target:IsPlayer() then

			mins, maxs = target:GetHull()
		elseif target:IsNPC() or target:IsNextBot() then
			mins, maxs = target:OBBMins(), target:OBBMaxs()
		else

			mins, maxs = target:OBBMins(), target:OBBMaxs()
		end

		return IsInsideDoor(ent, pos, mins, maxs)
	end

	local function KillInDoorway(ent)
		if not IsValid(ent) then return end
		local doorCenter = ent:GetPos() + ent:OBBCenter()

		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and ply:Alive() and IsEntityBlockingDoor(ent, ply) then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(999999)
				dmginfo:SetAttacker(ent)
				dmginfo:SetInflictor(ent)
				dmginfo:SetDamageType(DMG_CRUSH)
				local flingDir = (ply:GetPos() - doorCenter):GetNormalized()
				flingDir.z = 0.3
				flingDir:Normalize()
				dmginfo:SetDamageForce(flingDir * 80000)
				dmginfo:SetDamagePosition(ply:GetPos())
				ply:TakeDamageInfo(dmginfo)
				ply:SetVelocity(flingDir * 500 + Vector(0, 0, 200))
			end
		end

		for _, e in ipairs(ents.FindInBox(ent:GetPos() + ent:OBBMins(), ent:GetPos() + ent:OBBMaxs())) do
			if IsValid(e) and (e:IsNPC() or e:IsNextBot()) and IsEntityBlockingDoor(ent, e) then
				local dmginfo = DamageInfo()
				dmginfo:SetDamage(999999)
				dmginfo:SetAttacker(ent)
				dmginfo:SetInflictor(ent)
				dmginfo:SetDamageType(DMG_CRUSH)
				local flingDir = (e:GetPos() - doorCenter):GetNormalized()
				flingDir.z = 0.3
				flingDir:Normalize()
				dmginfo:SetDamageForce(flingDir * 60000)
				dmginfo:SetDamagePosition(e:GetPos())
				e:TakeDamageInfo(dmginfo)
			end
		end
	end

	local function DoRespawn(ent)
		if not IsValid(ent) then return end
		if not ent.breck then return end

		if door_debris[ent] then
			for _, debris in ipairs(door_debris[ent]) do
				if IsValid(debris) then
					debris:Remove()
				end
			end
			door_debris[ent] = nil
		end

		ent:SetModel(ent.door_origModel)
		ent.door_Health = DOOR_MAX_HEALTH
		ent.gib         = false
		ent.breck       = false
		ent:RemoveEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
		ent:SetKeyValue("spawnflags", tostring(ent.door_origFlags))
		if ent.door_origLocked then
			ent:Fire("Lock")
		else
			ent:Fire("Unlock")
		end
		ent:Fire("AddOutput", "soundmoveoverride DoorsMove.Null")
		ent:Fire("AddOutput", "soundopenoverride DoorsMove.Null")
		ent:Fire("AddOutput", "soundcloseoverride DoorsMove.Null")
		ent:Fire("Close")

		ent:SetNoDraw(false)
		ent:SetNotSolid(false)

		timer.Simple(0.1, function()
			if not IsValid(ent) then return end
			ent:Fire("AddOutput", "soundmoveoverride " .. (ent.door_origSoundMove   or ""))
			ent:Fire("AddOutput", "soundopenoverride " .. (ent.door_origSoundOpen   or ""))
			ent:Fire("AddOutput", "soundcloseoverride " .. (ent.door_origSoundClose or ""))
			ent:EmitSound("ambient/materials/concrete_break1.wav")
		end)
	end

	local function RespawnDoor(ent, retries)
		if not IsValid(ent) then return end
		if not ent.breck then return end
		retries = retries or 0

		local blocked = false

		local doorMins = ent:GetPos() + ent:OBBMins()
		local doorMaxs = ent:GetPos() + ent:OBBMaxs()

		for _, ply in ipairs(player.GetAll()) do
			if IsValid(ply) and IsEntityBlockingDoor(ent, ply) then
				blocked = true
				break
			end
		end

		if not blocked then
			for _, e in ipairs(ents.FindInBox(doorMins, doorMaxs)) do
				if IsValid(e) and (e:IsNPC() or e:IsNextBot()) and IsEntityBlockingDoor(ent, e) then
					blocked = true
					break
				end
			end
		end

		if blocked then
			if cv_respawnblock:GetBool() then
				KillInDoorway(ent)
				timer.Simple(0.5, function() RespawnDoor(ent, 0) end)
				return
			else
				if retries >= 30 then
					KillInDoorway(ent)
					timer.Simple(0.5, function() RespawnDoor(ent, 0) end)
					return
				else
					timer.Simple(2, function() RespawnDoor(ent, retries + 1) end)
					return
				end
			end
		end

		DoRespawn(ent)
	end

	local function DestroyDoor(ent, dmginfo)
		SpawnDoorDebris(ent, "models/noob_dev2323/door/door_debris_01.mdl", dmginfo)
		SpawnDoorDebris(ent, "models/noob_dev2323/door/door_debris_02.mdl", dmginfo)

		ent:SetNoDraw(true)
		ent:SetNotSolid(true)
		ent:Extinguish()

		ent:Fire("Lock")
		ent:SetKeyValue("spawnflags", tostring(bit.bor(ent.door_origFlags, 32768)))
		ent:AddEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
		ent:Fire("AddOutput", "soundmoveoverride DoorsMove.Null")
		ent:Fire("AddOutput", "soundopenoverride DoorsMove.Null")
		ent:Fire("AddOutput", "soundcloseoverride DoorsMove.Null")

		ent:Fire("Close")

		timer.Simple(0.5, function()
			if IsValid(ent) then
				ent:AddEFlags(EFL_NO_GAME_PHYSICS_SIMULATION)
			end
		end)

		if not cv_respawn:GetBool() then return end

		timer.Simple(cv_respawndelay:GetFloat(), function()
			RespawnDoor(ent, 0)
		end)
	end

	local function SetupDoor(ent)
		if not IsValid(ent) then return false end
		if ent:GetClass() ~= "prop_door_rotating" then return false end

		local model = ent.door_origModel or ent:GetModel()
		if not VALID_DOOR_MODELS[model] then return false end

		ent.door_Health         = ent.door_Health or DOOR_MAX_HEALTH
		ent.door_origModel      = model
		ent.door_origLocked     = ent.door_origLocked or ent:GetInternalVariable("m_bLocked")
		ent.door_origFlags      = ent.door_origFlags or ent:GetSpawnFlags()
		ent.door_origSoundMove  = ent.door_origSoundMove or ent:GetInternalVariable("m_SoundMoving")
		ent.door_origSoundOpen  = ent.door_origSoundOpen or ent:GetInternalVariable("m_SoundOpen")
		ent.door_origSoundClose = ent.door_origSoundClose or ent:GetInternalVariable("m_SoundClose")
		ent.destrutible_door    = true
		ent.gib                 = ent.gib or false
		ent.breck               = ent.breck or false

		return true
	end

	function SDD_AdvanceDoorBreakPhase(ent, dmginfo)
		if not cv_enable:GetBool() then return false end
		if not SetupDoor(ent) then return false end
		if ent.breck then return true end

		if ent:GetInternalVariable("m_bLocked") == true and not cv_destroylocked:GetBool() then
			return true
		end

		local dmgModels = DAMAGE_MODELS[ent.door_origModel]

		if ent.door_Health > DOOR_STAGE1_HEALTH then
			ent.door_Health = DOOR_STAGE1_HEALTH
			if dmgModels and dmgModels.stage1 then
				ent:SetModel(dmgModels.stage1)
			end
			return true
		end

		if ent.door_Health > DOOR_STAGE2_HEALTH then
			ent.door_Health = DOOR_STAGE2_HEALTH
			ent.gib = true
			if dmgModels and dmgModels.stage2 then
				ent:SetModel(dmgModels.stage2)
			end
			ent:EmitSound("door_destroying")
			SpawnDoorDebris(ent, "models/noob_dev2323/door/door_debris_03.mdl", dmginfo)
			return true
		end

		ent.door_Health = 0
		ent.breck = true
		DestroyDoor(ent, dmginfo)

		return true
	end

	function SDD_DamageDoor(ent, damage, dmginfo)
		if not cv_enable:GetBool() then return false end
		if not SetupDoor(ent) then return false end
		if ent.breck then return true end

		if ent:GetInternalVariable("m_bLocked") == true and not cv_destroylocked:GetBool() then
			return true
		end

		ent.door_Health = ent.door_Health - damage

		local dmgModels = DAMAGE_MODELS[ent.door_origModel]

		if ent.door_Health <= DOOR_STAGE1_HEALTH and ent.door_Health > DOOR_STAGE2_HEALTH and not ent.gib then
			if dmgModels and dmgModels.stage1 then
				ent:SetModel(dmgModels.stage1)
			end
		end

		if ent.door_Health <= DOOR_STAGE2_HEALTH and not ent.gib then
			ent.gib = true
			if dmgModels and dmgModels.stage2 then
				ent:SetModel(dmgModels.stage2)
			end
			ent:EmitSound("door_destroying")
			SpawnDoorDebris(ent, "models/noob_dev2323/door/door_debris_03.mdl", dmginfo)
		end

		if ent.door_Health <= 0 then
			ent.breck = true
			DestroyDoor(ent, dmginfo)
		end

		return true
	end

	hook.Add("OnEntityCreated", "SDD_SetupDoor", function(ent)
		if ent:GetClass() ~= "prop_door_rotating" then return end
		if not cv_enable:GetBool() then return end

		timer.Simple(0.01, function()
			SetupDoor(ent)
		end)
	end)

	hook.Add("EntityTakeDamage", "SDD_DoorDamage", function(ent, dmginfo)
		if ent:GetClass() ~= "prop_door_rotating" then return end
		if not ent.destrutible_door then return end
		if ent.breck then return end

		if ent:GetInternalVariable("m_bLocked") == true and not cv_destroylocked:GetBool() then
			return
		end

		local damage = dmginfo:GetDamage()
		if dmginfo:IsDamageType(DMG_BLAST) then
			damage = damage * 21
		end

		ent.door_Health = ent.door_Health - damage

		local dmgModels = DAMAGE_MODELS[ent.door_origModel]

		if ent.door_Health <= DOOR_STAGE1_HEALTH and ent.door_Health > DOOR_STAGE2_HEALTH and not ent.gib then
			if dmgModels and dmgModels.stage1 then
				ent:SetModel(dmgModels.stage1)
			end
		end

		if ent.door_Health <= DOOR_STAGE2_HEALTH and not ent.gib then
			ent.gib = true
			if dmgModels and dmgModels.stage2 then
				ent:SetModel(dmgModels.stage2)
			end
			ent:EmitSound("door_destroying")
			SpawnDoorDebris(ent, "models/noob_dev2323/door/door_debris_03.mdl", dmginfo)
		end

		if ent.door_Health <= 0 then
			ent.breck = true
			DestroyDoor(ent, dmginfo)
		end
	end)

	concommand.Add("sdd_door_respawn_now", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end

		local count = 0
		for _, ent in ipairs(ents.GetAll()) do
			if ent:GetClass() == "prop_door_rotating" and ent.breck then
				RespawnDoor(ent, 0)
				count = count + 1
			end
		end

		if IsValid(ply) then
			ply:ChatPrint("[SDD] Respawned " .. count .. " door(s).")
		else
			print("[SDD] Respawned " .. count .. " door(s).")
		end
	end, nil, "Immediately respawn all destroyed doors. Admin only.")

	concommand.Add("sdd_reset_defaults", function(ply)
		if IsValid(ply) and not ply:IsAdmin() then return end

		RunConsoleCommand("sdd_enable", "1")
		RunConsoleCommand("sdd_can_destroy_locked_door", "0")
		RunConsoleCommand("sdd_door_debris_fade_time", "30")
		RunConsoleCommand("sdd_door_respawn", "1")
		RunConsoleCommand("sdd_door_respawn_delay", "30")
		RunConsoleCommand("sdd_door_respawn_block", "0")

		if IsValid(ply) then
			ply:ChatPrint("[SDD] All settings reset to defaults.")
		else
			print("[SDD] All settings reset to defaults.")
		end
	end, nil, "Reset all SDD convars to default values. Admin only.")
end

if CLIENT then
	local function SDD_BuildMenu(panel)
		panel:ClearControls()

		panel:Help("-- Main Options --")
		panel:CheckBox("Enable destructible doors", "sdd_enable")
		panel:CheckBox("Allow destroying locked doors", "sdd_can_destroy_locked_door")
		panel:NumSlider("Debris fade time (seconds, 0 = no debris)", "sdd_door_debris_fade_time", 0, 1000, 0)

		panel:Help("-- Respawn Options --")
		panel:CheckBox("Enable door respawn", "sdd_door_respawn")
		panel:NumSlider("Respawn delay (seconds)", "sdd_door_respawn_delay", 1, 600, 0)
		panel:CheckBox("Kill players in door on respawn (off = wait)", "sdd_door_respawn_block")

		if LocalPlayer():IsAdmin() then
			panel:Help("-- Admin --")
			local btn = panel:Button("Respawn All Doors Now")
			btn.DoClick = function()
				RunConsoleCommand("sdd_door_respawn_now")
			end
			local btn2 = panel:Button("Reset to Defaults")
			btn2.DoClick = function()
				RunConsoleCommand("sdd_reset_defaults")
			end
		end
	end

	hook.Add("PopulateToolMenu", "SDD_AddSettings", function()
		spawnmenu.AddToolMenuOption(
			"Options",
			"Simple_Destructable_Doors",
			"Simple_Destructable_Doors",
			"Simple Destructible Doors",
			"", "",
			SDD_BuildMenu
		)
	end)
end
