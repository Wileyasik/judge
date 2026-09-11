hg.eyegore = hg.eyegore or {}
local eyegore = hg.eyegore

eyegore.EYE_MODELS = {
	L = "models/gore/head_eye02.mdl",
	R = "models/gore/head_eye01.mdl"
}

local function GetBody(ply)
	if not IsValid(ply) then return nil end
	if ply:IsPlayer() then
		local fake = ply.FakeRagdoll
		if IsValid(fake) then return fake end
		if ply:Alive() then return ply end
		return ply:GetNWEntity("RagdollDeath")
	end
	return ply
end

local function GetHeadData(body)
	if not IsValid(body) then return body:GetPos(), body:GetAngles() end
	local id = body:LookupAttachment("eyes")
	if id and id > 0 then
		local att = body:GetAttachment(id)
		if att then return att.Pos, att.Ang end
	end
	local bone = body:LookupBone("ValveBiped.Bip01_Head1")
	if bone and bone >= 0 then
		local pos, ang = body:GetBonePosition(bone)
		if pos then return pos, ang end
	end
	return body:GetPos(), body:GetAngles()
end

function eyegore.PopEye(org, side, dropProp)
	if not org or not org.alive then return end
	local owner = org.owner
	if not IsValid(owner) then return end

	local key = "hg_eyegore_" .. side
	if owner:GetNWInt(key, 0) >= 1 then return end
	owner:SetNWInt(key, 2)

	local body = GetBody(owner)
	local pos, ang = GetHeadData(body)
	if pos then
		if dropProp == nil then dropProp = true end
		if dropProp then
			local mdl = eyegore.EYE_MODELS[side]
			local eye = ents.Create("prop_physics")
			if IsValid(eye) then
				eye:SetModel(mdl)
				eye:SetPos(pos)
				eye:SetAngles(ang)
				eye:Spawn()
				eye:Activate()
				eye:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
				local phys = eye:GetPhysicsObject()
				if IsValid(phys) then
					phys:Wake()
					local dir = ang:Forward()
					phys:SetVelocity(dir * math.Rand(60, 130) + Vector(0, 0, -50) + VectorRand(-20, 20))
					phys:SetAngleVelocity(VectorRand(-90, 90))
				end
				timer.Simple(45, function()
					if IsValid(eye) then eye:Remove() end
				end)
			end
		end
	end

	if owner:IsPlayer() and owner:Alive() then
		owner:Notify(side == "L" and "Your left eye is ruined..." or "Your right eye is ruined...", 8, "eye_destroyed", 0, Color(255, 120, 120))
	end
end

local sideList = {"L", "R"}

local function SyncRagdoll(ply, rag)
	if not IsValid(ply) or not IsValid(rag) then return end
	for _, side in ipairs(sideList) do
		local v = ply:GetNWInt("hg_eyegore_" .. side, 0)
		if v > 0 then rag:SetNWInt("hg_eyegore_" .. side, v) end
	end
end

hook.Add("Ragdoll_Create", "hg_eyegore_sync", SyncRagdoll)
hook.Add("RagdollDeath", "hg_eyegore_sync_death", SyncRagdoll)

concommand.Add("hg_test_eyegore", function(ply, cmd, args)
	if ply and not (ply:IsSuperAdmin() or ply:IsAdmin()) then return end
	local target = ply
	if args[1] and args[1] ~= "" then
		local wanted = string.lower(args[1])
		for _, p in ipairs(player.GetAll()) do
			if string.find(string.lower(p:Nick()), wanted, 1, true) then
				target = p
				break
			end
		end
	end
	if not IsValid(target) or not (target:IsPlayer() and target.organism) then return end
	local org = target.organism
	local side = string.upper(args[2] or "R"):sub(1, 1)
	if side ~= "L" and side ~= "R" then side = "R" end
	local state = string.lower(args[3] or "onmodel")
	local val = 1
	if state == "remove" or state == "socket" or state == "prop" then val = 2 end
	if org.alive then
		org[side == "L" and "eyeL" or "eyeR"] = 1
		if state == "prop" then
			eyegore.PopEye(org, side, true)
		else
			org.owner:SetNWInt("hg_eyegore_" .. side, val)
		end
	else
		local body = GetBody(target)
		if IsValid(body) then body:SetNWInt("hg_eyegore_" .. side, val) end
	end
	if ply then ply:Notify("Eye gore (" .. side .. ", " .. state .. ") applied to " .. target:Nick(), 5, "hg_test_eyegore") end
end)