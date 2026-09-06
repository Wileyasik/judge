hook.Add("PlayerSwitchFlashlight", "removeflashlights", function(ply, enabled)
	if ply.PlayerClassName == "Combine" or ply.PlayerClassName == "furry" then return false end

	local wep = ply:GetActiveWeapon()

	local flashlightwep

	if IsValid(wep) then
		local laser = wep.attachments and wep.attachments.underbarrel
		local attachmentData
		if (laser and not table.IsEmpty(laser)) or wep.laser then
			if laser and not table.IsEmpty(laser) then
				attachmentData = hg.attachments.underbarrel[laser[1]]
			else
				attachmentData = wep.laserData
			end
		end

		if attachmentData then flashlightwep = attachmentData.supportFlashlight end
	end

	if not flashlightwep then
		if IsValid(wep) and (wep.IsPistolHoldType and not wep:IsPistolHoldType() and ply.PlayerClassName ~= "Gordon") then return end

		local inv = ply:GetNetVar("Inventory", {})
		if inv and inv["Weapons"] and inv["Weapons"]["hg_flashlight"] and enabled and hg.CanUseLeftHand(ply) then
			local flashvar = ply:GetNetVar("flashlight")

			hg.GetCurrentCharacter(ply):EmitSound("items/flashlight1.wav", 65, flashvar and 110 or 130)
			ply:SetNetVar("flashlight", not flashvar)
			if IsValid(ply.flashlight) then ply.flashlight:Remove() end
		else
			ply:SetNetVar("flashlight", false)
		end
		return false
	end
end)
