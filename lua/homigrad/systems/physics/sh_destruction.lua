hook.Add("OnEntityCreated", "DragDisabler", function(v)
	timer.Simple(0, function()
		if IsValid(v) then
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetDragCoefficient(0.2)

				local physcount = v:GetPhysicsObjectCount()
				if physcount > 1 then
					for i = 0, physcount - 1 do
						local b = v:GetPhysicsObjectNum(i)
						b:SetDragCoefficient(0.2)
					end
				end
			end
		end
	end)
end)

local badmats = {
	["paper"] = true,
	["cardboard"] = true,
	["plastic"] = true,
	["popcan"] = true,
	["glassbottle"] = true,
}

hook.Add("OnEntityCreated", "PropMassFix", function(v)
	timer.Simple(0, function()
		if IsValid(v) and IsValid(v:GetPhysicsObject()) and v:GetClass() ~= "prop_ragdoll" then
			local phys = v:GetPhysicsObject()
			local rad = v:GetModelRadius()
			if rad == nil then return end

			if phys:GetMass() <= 1 and (!badmats[phys:GetMaterial()] or rad > 32) then
				phys:SetMass(rad or 2)
			end
		end
	end)
end)

local WreckBlacklist = {"gmod_lamp", "gmod_cameraprop", "gmod_light", "ent_jack_gmod_nukeflash"}

function hgWreckBuildings(blaster, pos, power, range, ignoreVisChecks)
	local origPower = power
	power = power * 1
	local maxRange = 250 * power * (range or 1)
	local maxMassToDestroy = 10 * power ^ .8
	local masMassToLoosen = 30 * power
	local allProps = ents.FindInSphere(pos, maxRange)

	local co = coroutine.create(function()
		local LastProcess = SysTime()

		for k, prop in ipairs(allProps) do
			LastProcess = SysTime()
			if not IsValid(prop) then continue end
			if not (table.HasValue(WreckBlacklist, prop:GetClass()) or hook.Run("hg_CanDestroyProp", prop, blaster, pos, power, range, ignoreVisChecks) == false or prop.ExplProof == true) then
				if not IsValid(prop) then continue end
				local physObj = prop:GetPhysicsObject()
				if not IsValid(physObj) then continue end
				local propPos = prop:LocalToWorld(prop:OBBCenter())
				local DistFrac = 1 - propPos:Distance(pos) / maxRange
				local myDestroyThreshold = DistFrac * maxMassToDestroy
				local myLoosenThreshold = DistFrac * masMassToLoosen

				if DistFrac >= .85 then
					myDestroyThreshold = myDestroyThreshold * 7
					myLoosenThreshold = myLoosenThreshold * 7
				end

				if prop ~= blaster then
					local mass, proceed = physObj:GetMass(), ignoreVisChecks

					if not proceed then
						local tr = util.QuickTrace(pos, propPos - pos, blaster)
						proceed = IsValid(tr.Entity) and (tr.Entity == prop)
					end

					if proceed then
						if mass <= myDestroyThreshold then
							if prop:GetClass() == "prop_ragdoll" or prop:IsNPC() then
								physObj:EnableMotion(true)
							else
								SafeRemoveEntity(prop)
							end
						elseif mass <= myLoosenThreshold then
							physObj:EnableMotion(true)
							constraint.RemoveAll(prop)
							physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 200 * DistFrac * power * mass, propPos + VectorRand() * 10)
						else
							physObj:ApplyForceOffset((propPos - pos):GetNormalized() * 200 * DistFrac * origPower * mass, propPos + VectorRand() * 10)
						end
					end
				end
			end

			LastProcess = SysTime() - LastProcess

			if LastProcess > 0.001 then
				coroutine.yield()
			end
		end
	end)
	local index = blaster:EntIndex()
	local timerName = "ProcessCheck_" .. index
	timer.Create(timerName, 0, 0, function()
		if coroutine.status(co) == "dead" then
			timer.Remove(timerName)
			return
		end
		local ok, err = coroutine.resume(co)
		if not ok then
			timer.Remove(timerName)
			ErrorNoHalt("[hgWreckBuildings] Coroutine failed: " .. tostring(err) .. "\n")
		end
	end)
end

function hgIsDoor(ent)
	local Class = ent:GetClass()
	return (Class == "prop_door") or (Class == "prop_door_rotating") or (Class == "func_door") or (Class == "func_door_rotating")
end

function hgBlastDoors(blaster, pos, power, range, ignoreVisChecks)
	for k, door in pairs(ents.FindInSphere(pos, 40 * power * (range or 1))) do
		if hgIsDoor(door) and hook.Run("hg_CanDestroyDoor", door, blaster, pos, power, range, ignore) ~= false then
			local proceed = ignoreVisChecks

			if not proceed then
				local tr = util.QuickTrace(pos, door:LocalToWorld(door:OBBCenter()) - pos, blaster)
				proceed = IsValid(tr.Entity) and (tr.Entity == door)
			end

			if proceed then
				hgBlastThatDoor(door, (door:LocalToWorld(door:OBBCenter()) - pos):GetNormalized() * 1000)
			end
		end
		if door:GetClass() == "func_breakable_surf" then
			door:Fire("Break")
		end
	end
end

function DoorIsOpen2(door)
	local doorClass = door:GetClass()

	if (doorClass == "func_door" or doorClass == "func_door_rotating") then
		return door:GetInternalVariable("m_toggle_state") == 0
	elseif (doorClass == "prop_door_rotating") then
		return door:GetInternalVariable("m_eDoorState") ~= 0
	else
		return false
	end
end

function hgBlastThatDoor(ent, vel)
	local meleeHit = ent.SDD_LastMeleeHit and ent.SDD_LastMeleeHit > CurTime() - 0.1
	if SDD_DamageDoor and (meleeHit or math.random(100) <= 60) and SDD_DamageDoor(ent, math.random(20, 45)) then return end
	if SDD_AdvanceDoorBreakPhase and SDD_AdvanceDoorBreakPhase(ent) then return end

	local Moddel, Pozishun, Ayngul, Muteeriul, Skin = ent:GetModel(), ent:GetPos(), ent:GetAngles(), ent:GetMaterial(), ent:GetSkin()
	sound.Play("Wood_Crate.Break", Pozishun, 60, 100)
	sound.Play("Wood_Furniture.Break", Pozishun, 60, 100)
	ent:Fire("unlock", "", 0)
	ent:Fire("open", "", 0)
	ent:SetNoDraw(true)
	ent:SetNotSolid(true)

	for _, portal in ipairs(ents.FindByClass("func_areaportal")) do
		if (portal:GetInternalVariable("target") == ent:GetName()) then
			portal:Fire("Open")
			portal:SetSaveValue("target", "")
		end
	end

	if Moddel and Pozishun and Ayngul then
		local Replacement = ents.Create("prop_physics")
		Replacement:SetModel(Moddel)
		Replacement:SetPos(Pozishun + Vector(0, 0, 1))
		Replacement:SetAngles(Ayngul)

		if Muteeriul then
			Replacement:SetMaterial(Muteeriul)
		end

		if Skin then
			Replacement:SetSkin(Skin)
		end

		Replacement:SetModelScale(.9, 0)
		Replacement:Spawn()
		Replacement:Activate()

		if vel then
			Replacement:GetPhysicsObject():SetVelocity(vel)

			timer.Simple(0, function()
				if IsValid(Replacement) then
					Replacement:GetPhysicsObject():ApplyForceCenter(vel * 100)
				end
			end)
		end

		timer.Simple(5, function()
			if IsValid(Replacement) then
				Replacement:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end)
	end
end
