local hg_limp_style = CreateConVar("hg_limp_style", "1", {FCVAR_ARCHIVE}, "0=off, 1=zombie walk strong, 2=zombie walk mild, 3=bone only")

local limpActivities = {
	[1] = ACT_HL2MP_WALK_ZOMBIE_06,
	[2] = ACT_HL2MP_WALK_ZOMBIE_01,
}

local brokenBoneTbl = {
	["ValveBiped.Bip01_L_Thigh"] = {key = "lleg", ang = Angle(0, 14, 0)},
	["ValveBiped.Bip01_R_Thigh"] = {key = "rleg", ang = Angle(0, -14, 0)},
	["ValveBiped.Bip01_L_Calf"] = {key = "lleg", ang = Angle(0, 0, 24)},
	["ValveBiped.Bip01_R_Calf"] = {key = "rleg", ang = Angle(0, 0, -24)},
	["ValveBiped.Bip01_L_Foot"] = {key = "lleg", ang = Angle(0, 0, 26)},
	["ValveBiped.Bip01_R_Foot"] = {key = "rleg", ang = Angle(0, 0, -26)},
	["ValveBiped.Bip01_L_UpperArm"] = {key = "larm", ang = Angle(0, 0, 10)},
	["ValveBiped.Bip01_R_UpperArm"] = {key = "rarm", ang = Angle(0, 0, -10)},
	["ValveBiped.Bip01_L_Forearm"] = {key = "larm", ang = Angle(0, 0, -26)},
	["ValveBiped.Bip01_R_Forearm"] = {key = "rarm", ang = Angle(0, 0, 26)},
	["ValveBiped.Bip01_L_Hand"] = {key = "larm", ang = Angle(0, 0, -16)},
	["ValveBiped.Bip01_R_Hand"] = {key = "rarm", ang = Angle(0, 0, 16)},
}

local zeroAng = Angle(0, 0, 0)

local function applyBoneVisuals(ply, org)
	ply.hg_BrokenLimbBones = ply.hg_BrokenLimbBones or {}
	local applied = {}
	for boneName, data in pairs(brokenBoneTbl) do
		local key = data.key
		if org[key] == 1 and not org[key .. "amputated"] then
			local bid = ply:LookupBone(boneName)
			if bid then
				ply:ManipulateBoneAngles(bid, data.ang)
				applied[bid] = true
				ply.hg_BrokenLimbBones[bid] = true
			end
		end
	end
	for bid in pairs(ply.hg_BrokenLimbBones) do
		if not applied[bid] then
			ply:ManipulateBoneAngles(bid, zeroAng)
			ply.hg_BrokenLimbBones[bid] = nil
		end
	end
end

hook.Add("CalcMainActivity", "hgBrokenLimbVisuals", function(ply, vel)
	if not IsValid(ply) or not ply:Alive() then return end
	local org = ply.organism
	if not org then return end

	local brokenLeg = org.lleg == 1 or org.rleg == 1 or org.llegdislocation or org.rlegdislocation
	local brokenArm = org.larm == 1 or org.rarm == 1
	if not brokenLeg and not brokenArm then
		if ply.hg_LimpSpine then
			ply:ManipulateBoneAngles(ply.hg_LimpSpine, zeroAng)
			ply.hg_LimpSpine = nil
		end
		if ply.hg_BrokenLimbBones then
			for bid in pairs(ply.hg_BrokenLimbBones) do
				ply:ManipulateBoneAngles(bid, zeroAng)
			end
			ply.hg_BrokenLimbBones = nil
		end
		return
	end

	applyBoneVisuals(ply, org)

	local style = hg_limp_style:GetInt()
	local limping = brokenLeg and not ply:Crouching() and not ply:InVehicle() and ply:IsOnGround() and vel and vel:Length() > 60
	if limping then
		local spineBid = ply:LookupBone("ValveBiped.Bip01_Spine")
		if spineBid then
			ply:ManipulateBoneAngles(spineBid, Angle(0, 10, 0))
			ply.hg_LimpSpine = spineBid
		end
		if style == 1 or style == 2 then
			return limpActivities[style], 0
		end
	elseif ply.hg_LimpSpine then
		ply:ManipulateBoneAngles(ply.hg_LimpSpine, zeroAng)
		ply.hg_LimpSpine = nil
	end
end)