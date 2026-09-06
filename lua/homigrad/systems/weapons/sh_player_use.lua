local hook_Run = hook.Run

hook.Add("PlayerUse", "nouseinfake", function(ply, ent)
	local class = ent:GetClass()

	if class == "momentary_rot_button" then return end
	if ent.dontPickup then return false end
	local ductcount = hgCheckDuctTapeObjects(ent)
	local nailscount = hgCheckBindObjects(ent)
	ply.PickUpCooldown = ply.PickUpCooldown or 0
	if (ductcount and ductcount > 0) or (nailscount and nailscount > 0) then return false end
	if class == "prop_physics" or class == "prop_physics_multiplayer" or class == "func_physbox" then
		local PhysObj = ent:GetPhysicsObject()
		if PhysObj and PhysObj.GetMass and PhysObj:GetMass() > 14 then return false end
	end

	if ply.PickUpCooldown > CurTime() and not IsValid(ply.FakeRagdoll) then return false end

	ply.PickUpCooldown = CurTime() + 0.15
end)

hook.Add("WeaponEquip", "pickupHuy", function(wep, ply)
	timer.Simple(0, function()
		if wep.DontEquipInstantly then wep.DontEquipInstantly = nil return end
		if not ply.noSound and IsValid(wep) then
			local oldwep = ply:GetActiveWeapon()
			timer.Simple(0, function()
				hook.Run("PlayerSwitchWeapon", ply, oldwep, wep)
				ply:SelectWeapon(wep:GetClass())
				ply:SetActiveWeapon(wep)

				if wep.Deploy then
					wep:Deploy()
				end
			end)
		end
	end)
end)

hook.Add("AllowPlayerPickup", "pickupWithWeapons", function(ply, ent)
	if ent:IsPlayerHolding() then return false end
end)

local hullVec = Vector(1, 1, 1)
local checkUse = {
	"player",
	"worldspawn",
	"prop_dynamic"
}

hook.Add("FindUseEntity", "findhguse", function(ply, heldent)
	if IsValid(heldent) and heldent:GetClass() == "button" then return heldent end

	if not ply:KeyDown(IN_USE) then return false end
	local eyetr = hg.eyeTrace(ply, 100, nil, nil, nil, checkUse)

	local ent = eyetr.Entity

	if !IsValid(ent) then
		local tr = {}
		tr.start = eyetr.HitPos
		tr.endpos = eyetr.HitPos
		tr.filter = checkUse
		tr.mins = -hullVec
		tr.maxs = hullVec
		tr.mask = MASK_SOLID + CONTENTS_DEBRIS + CONTENTS_PLAYERCLIP
		tr.ignoreworld = false

		tr = util.TraceHull(tr)
		ent = tr.Entity
	end

	if !IsValid(ent) then
		ent = heldent
	end

	return ent
end)

duplicator.Allow("weapon_base")
duplicator.Allow("homigrad_base")

timer.Simple(5, function()
	hook.Remove("ScaleNPCDamage", "AddHeadshotPuffNPC")
	hook.Remove("ScalePlayerDamage", "AddHeadshotPuffPlayer")
	hook.Remove("EntityTakeDamage", "AddHeadshotPuffRagdoll")
end)
