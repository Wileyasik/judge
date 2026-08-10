ENT.Type = "point"
ENT.Base = "base_point"

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "onpressed" then
		self.RawOutputs = self.RawOutputs or {}
		table.insert(self.RawOutputs, value)
	elseif key == "cost" then
		self.Cost = tonumber(value)
	elseif key == "wait" then
		self.Wait = tonumber(value)
	elseif key == "active" then
		self.Active = tobool(value)
	elseif key == "removeontrigger" then
		self.RemoveOnTrigger = tobool(value)
	elseif key == "description" then
		self.Description = tostring(value)
	end
end

function ENT:Think()
	if not self.Replaced then
		self:CreateReplacement()
		self:Remove()
	end
end

function ENT:CreateReplacement()
	local tgt = ents.Create("ttt_traitor_button")
	if not IsValid(tgt) then return end

	self.Replaced = true
	tgt:SetPos(self:GetPos())
	tgt:SetKeyValue("targetname", self:GetName())

	if not self.Active then
		tgt:SetKeyValue("spawnflags", "2048")
	end

	if self.Description and self.Description ~= "" then
		tgt:SetKeyValue("description", self.Description)
	end

	if self.Cost ~= nil then
		tgt:SetKeyValue("cost", tostring(self.Cost))
	end

	if self.Wait ~= nil then
		tgt:SetKeyValue("wait", tostring(self.Wait))
	elseif self.Cost ~= nil then
		tgt:SetKeyValue("wait", tostring(self.Cost))
	end

	if self.RemoveOnTrigger then
		tgt:SetKeyValue("removeonpress", "1")
	end

	if self.RawOutputs then
		for _, v in pairs(self.RawOutputs) do
			tgt:SetKeyValue("onpressed", tostring(v))
		end
	end

	tgt:Spawn()
end
