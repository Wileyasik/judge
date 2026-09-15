include("shared.lua")

ENT.CRISP = true

local SHADOW = {
	secondstoarrive = 0.01,
	maxangular = 5000,
	maxangulardamp = 1000,
	maxspeed = 3000,
	maxspeeddamp = 1000,
	dampfactor = 0.9,
	teleportdistance = 0
}

function ENT:Initialize()
	self:SetModel(MH.MODEL)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:DrawShadow(false)
	self.Last = CurTime()
	self.Prev, self.Vel = {}, {}
end

function ENT:Play(seq)
	local id = self:LookupSequence(seq)
	if !id or id < 0 then return false end

	self:ResetSequence(id)
	self:SetCycle(0)
	self:SetPlaybackRate(1)
	return true
end

function ENT:Drive(rag)
	self.Rag = rag
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			phys:EnableMotion(!self.CRISP)
			phys:Wake()
			phys:SetDamping(0, 0)
		end
	end
end

function ENT:Release()
	local rag = self.Rag
	if !IsValid(rag) then return end

	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if IsValid(phys) then
			phys:EnableMotion(true)
			phys:Wake()
			if self.Vel[i] then phys:SetVelocity(self.Vel[i]) end
		end
	end
end

function ENT:OnRemove()
	self:Release()
end

function ENT:HitsAt(marks, fn)
	local d = self:SequenceDuration()
	self.Hits, self.OnHit = {}, fn
	if d <= 0 then return end

	for _, m in ipairs(marks) do
		self.Hits[#self.Hits + 1] = { c = m.t / d, swing = m.swing, bone = m.bone, ev = m.ev }
	end
	table.sort(self.Hits, function(a, b) return a.c < b.c end)
end

function ENT:ClothAt(ranges, fn)
	local d = self:SequenceDuration()
	self.Cloth, self.OnCloth, self.NextCloth = {}, fn, 0
	if d <= 0 then return end

	for _, r in ipairs(ranges) do
		self.Cloth[#self.Cloth + 1] = { a = r[1] / d, b = r[2] / d }
	end
end

function ENT:Think()
	local rag = self.Rag
	if !IsValid(rag) then self:Remove() return end

	local cycle = self:GetCycle()

	while self.Hits and self.Hits[1] and cycle >= self.Hits[1].c do
		local m = table.remove(self.Hits, 1)
		if self.OnHit then self.OnHit(self, m.swing, m.bone, m.ev) end
	end

	if self.Cloth and CurTime() >= self.NextCloth then
		for _, r in ipairs(self.Cloth) do
			if cycle >= r.a and cycle <= r.b then
				self.NextCloth = CurTime() + math.Rand(0.18, 0.4)
				self.OnCloth(self)
				break
			end
		end
	end

	local dt = math.max(CurTime() - self.Last, 0.001)
	for i = 0, rag:GetPhysicsObjectCount() - 1 do
		local phys = rag:GetPhysicsObjectNum(i)
		if !IsValid(phys) then continue end

		local b = self:LookupBone(rag:GetBoneName(rag:TranslatePhysBoneToBone(i)) or "")
		if !b then continue end

		local pos, ang = self:GetBonePosition(b)
		if !pos then continue end

		if self.CRISP then
			if self.Prev[i] then self.Vel[i] = (pos - self.Prev[i]) / dt end
			self.Prev[i] = pos
			phys:SetPos(pos)
			phys:SetAngles(ang)
		else
			phys:Wake()
			phys:ComputeShadowControl({
				secondstoarrive = SHADOW.secondstoarrive,
				pos = pos,
				angle = ang,
				maxangular = SHADOW.maxangular,
				maxangulardamp = SHADOW.maxangulardamp,
				maxspeed = SHADOW.maxspeed,
				maxspeeddamp = SHADOW.maxspeeddamp,
				dampfactor = SHADOW.dampfactor,
				teleportdistance = SHADOW.teleportdistance,
				deltatime = dt
			})
		end
	end

	self.Last = CurTime()
	self:NextThink(CurTime())
	return true
end
