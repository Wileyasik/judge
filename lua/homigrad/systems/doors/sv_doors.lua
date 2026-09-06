local entMeta = FindMetaTable("Entity")
local string_find = string.find

function entMeta:StealthOpenDoor(user)
	self.oldspeed = self.oldspeed or self:GetInternalVariable("Speed")
	self.oldsnd = self.oldsnd or self:GetInternalVariable("noise1")
	self.oldsnd2 = self.oldsnd2 or self:GetInternalVariable("noise2")
	self.oldsnd3 = self.oldsnd3 or self:GetInternalVariable("soundcloseoverride")
	self.oldsnd4 = self.oldsnd4 or self:GetInternalVariable("soundlockedoverride")
	self.oldsnd5 = self.oldsnd5 or self:GetInternalVariable("soundmoveoverride")
	self.oldsnd6 = self.oldsnd6 or self:GetInternalVariable("soundopenoverride")
	self.oldsnd7 = self.oldsnd7 or self:GetInternalVariable("soundunlockedoverride")

	self.firstOpen = 0
	local amt = 1 - math.min(math.abs(user:EyeAngles().p) / 60, 1)

	self.openang = self.openang or self:GetInternalVariable("m_angRotationOpenBack")
	self.openang2 = self.openang2 or self:GetInternalVariable("m_angRotationOpenForward")
	self.openang3 = self.openang3 or self:GetInternalVariable("m_vecAngle1")
	self.openang4 = self.openang4 or self:GetInternalVariable("m_vecAngle2")

	if self.openang then
		self:SetSaveValue("m_angRotationOpenBack", (self.firstOpen == 0) and self.openang * amt or self.openang)
		self:SetSaveValue("m_angRotationOpenForward", (self.firstOpen == 0) and self.openang2 * amt or self.openang2)
	end

	if self.openang3 then
		self:SetSaveValue("m_vecAngle1", (self.firstOpen == 0) and self.openang3 * amt or self.openang3)
		self:SetSaveValue("m_vecAngle2", (self.firstOpen == 0) and self.openang4 * amt or self.openang4)
	end

	self:SetSaveValue("Speed", self.oldspeed / 2)
	self:SetSaveValue("noise1", "")
	self:SetSaveValue("noise2", "")
	self:SetSaveValue("soundcloseoverride", "")
	self:SetSaveValue("soundlockedoverride", "")
	self:SetSaveValue("soundmoveoverride", "")
	self:SetSaveValue("soundopenoverride", "")
	self:SetSaveValue("soundunlockedoverride", "")

	hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, 2, {self})
end

hook.Add("StartCommand", "kolesiko", function(ply, cmd)
	local whl = cmd:GetMouseWheel()
	if ply:KeyDown(IN_WALK) and math.abs(whl) > 0 then
		local old_amt = ply:GetNWInt("door_open_amt", 0)
		ply:SetNWInt("door_open_amt", math.Clamp(old_amt + whl, -90, 90))
	end
end)

function entMeta:NormalOpenDoor(user)
	if self.oldspeed then
		self:SetSaveValue("Speed", self.oldspeed)
	end

	self.firstOpen = -1

	if self.openang then
		self:SetSaveValue("m_angRotationOpenBack", self.openang)
		self:SetSaveValue("m_angRotationOpenForward", self.openang2)
	end

	if self.openang3 then
		self:SetSaveValue("m_vecAngle1", self.openang3)
		self:SetSaveValue("m_vecAngle2", self.openang4)
	end

	if self.oldsnd or self.oldsnd3 then
		self:SetSaveValue("noise1", self.oldsnd)
		self:SetSaveValue("noise2", self.oldsnd2)
		self:SetSaveValue("soundcloseoverride", self.oldsnd3)
		self:SetSaveValue("soundlockedoverride", self.oldsnd4)
		self:SetSaveValue("soundmoveoverride", self.oldsnd5)
		self:SetSaveValue("soundopenoverride", self.oldsnd6)
		self:SetSaveValue("soundunlockedoverride", self.oldsnd7)
	end

	hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, nil, {self})
end

local vpang = Angle(2, 0, 0)
function entMeta:FastOpenDoor(user, mul, noanim, forceBack)
	self.oldspeed = self.oldspeed or self:GetInternalVariable("Speed")

	self.firstOpen = -1

	local openBack, openForward = self.openang, self.openang2
	local openVec1, openVec2 = self.openang3, self.openang4

	if forceBack ~= nil then
		if forceBack then
			openBack, openForward = self.openang2, self.openang
			openVec1, openVec2 = self.openang4, self.openang3
		end
	end

	if openBack then
		self:SetSaveValue("m_angRotationOpenBack", openBack)
		self:SetSaveValue("m_angRotationOpenForward", openForward)
	end

	if openVec1 then
		self:SetSaveValue("m_vecAngle1", openVec1)
		self:SetSaveValue("m_vecAngle2", openVec2)
	end

	if self.oldsnd or self.oldsnd3 then
		self:SetSaveValue("noise1", self.oldsnd)
		self:SetSaveValue("noise2", self.oldsnd2)
		self:SetSaveValue("soundcloseoverride", self.oldsnd3)
		self:SetSaveValue("soundlockedoverride", self.oldsnd4)
		self:SetSaveValue("soundmoveoverride", self.oldsnd5)
		self:SetSaveValue("soundopenoverride", self.oldsnd6)
		self:SetSaveValue("soundunlockedoverride", self.oldsnd7)
	end

	self:SetSaveValue("Speed", self.oldspeed * math.min(math.max(user:GetVelocity():Length() / 50, 1.5), 3) * (mul or 1))
	user:ViewPunch(vpang)
	if !noanim then
		hg.RunZManipAnim(user, !DoorIsOpen2(self) and "door_open_forward" or "door_open_back", nil, nil, {self})
	end
	if user.organism then
		user.organism.stamina.subadd = user.organism.stamina.subadd + 5
	end
	if user:GetVelocity():Length() < 50 then
		user:SetVelocity(user:GetVelocity() + user:GetAimVector() * 100)
	end
end

function entMeta:SDOIsDoor()
	return self:GetClass() == "prop_door_rotating" or self:GetClass() == "func_door_rotating"
end

hook.Add("AcceptInput", "StealthOpenDoors", function(ent, inp, act, ply, val)
	if inp == "Use" and ent:SDOIsDoor() then
		if IsValid(ply) and ply.DoorBashCD and ply.DoorBashCD > CurTime() then return false end
		local func = ((ply:KeyDown(IN_SPEED) and "FastOpenDoor") or (ply:KeyDown(IN_WALK) and "StealthOpenDoor") or "NormalOpenDoor")
		ent[func](ent, ply)
		if ent:GetInternalVariable("slavename") then
			for k, v in pairs(ents.FindByName(ent:GetInternalVariable("slavename"))) do
				v[func](v, ply)
			end
		end

		for k, v in pairs(ents.FindByClass(ent:GetClass())) do
			if ent == v:GetInternalVariable("m_hMaster") then
				v[func](v, ply)
			end
		end
		if ent:GetInternalVariable("m_hMaster") and IsValid(ent:GetInternalVariable("m_hMaster")) and ent:GetInternalVariable("m_hMaster"):SDOIsDoor() then
			ent:GetInternalVariable("m_hMaster")[func](ent:GetInternalVariable("m_hMaster"), ply)
		end
	end
end)

hook.Add("PlayerUse", "DoorClose", function(ply, ent)
	local getdoor = ply:GetUseEntity()
	if string_find(tostring(getdoor), "prop_door_rotating") and getdoor:GetInternalVariable("m_eDoorState") == 2 then
		if getdoor:GetInternalVariable("m_hMaster") != NULL then
			getdoor:GetInternalVariable("m_hMaster"):Fire("close")
			hg.RunZManipAnim(ply, "door_open_back", nil, 2, {self})
			return false
		else
			getdoor:Fire("close")
			hg.RunZManipAnim(ply, "door_open_back", nil, 2, {self})
			return false
		end
	end
end)

hook.Add("PlayerUse", "DoorBashOnRun", function(ply, ent)
	if IsValid(ply.FakeRagdoll) or not ply:Alive() then return end
	if not IsValid(ent) or not ent:SDOIsDoor() then return end
	if not ply:KeyDown(IN_SPEED) then return end

	local vel = ply:GetVelocity():Length()
	if vel < 250 then return end

	local cd = ply.DoorBashCD or 0
	if cd > CurTime() then return end

	local door = ent
	local doorForward = door:GetForward()
	local hitFromBack = ply:GetVelocity():Dot(doorForward) > 0
	local forceBack = not hitFromBack

	door:FastOpenDoor(ply, 1.5, true, forceBack)

	if door:GetInternalVariable("slavename") then
		for k, v in pairs(ents.FindByName(door:GetInternalVariable("slavename"))) do
			v:FastOpenDoor(ply, 1.5, true, forceBack)
		end
	end

	for k, v in pairs(ents.FindByClass(door:GetClass())) do
		if door == v:GetInternalVariable("m_hMaster") then
			v:FastOpenDoor(ply, 1.5, true, forceBack)
		end
	end

	if door:GetInternalVariable("m_hMaster") and IsValid(door:GetInternalVariable("m_hMaster")) and door:GetInternalVariable("m_hMaster"):SDOIsDoor() then
		door:GetInternalVariable("m_hMaster"):FastOpenDoor(ply, 1.5, true, forceBack)
	end

	ply.DoorBashCD = CurTime() + 1

	door:EmitSound("physics/wood/wood_crate_impact_hard3.wav", 80, math.Rand(90, 110))

	local ragdoll = hg.Ragdoll_Create(ply)
	if IsValid(ragdoll) then
		ragdoll:SetVelocity(ply:GetVelocity() * 0.5 + Vector(0, 0, 100))
		for i = 0, ragdoll:GetPhysicsObjectCount() - 1 do
			local phys = ragdoll:GetPhysicsObjectNum(i)
			if IsValid(phys) then
				phys:AddVelocity(ply:GetVelocity() * 0.3)
			end
		end
		hg.Fake(ply, ragdoll)
	end

	return false
end)

hook.Add("KeyPress", "snowballs_pickup", function(ply, key)
	if IsValid(ply.FakeRagdoll) then return end
	ply.SnowBallPickupCD = ply.SnowBallPickupCD or 0
	if ply.SnowBallPickupCD > CurTime() then return end

	if (key == IN_USE) then
		local tr = hg.eyeTrace(ply, 120)
		if tr.MatType == MAT_SNOW then
			ply:EmitSound("player/footsteps/snow1.wav", 65, math.Rand(90, 110))
			ply.SnowBallPickupCD = CurTime() + 1
			ply:Give("weapon_hg_snowball")
		end
	end
end)
