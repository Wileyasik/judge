ENT.Type = "point"
ENT.Base = "base_point"

ENT.Credits = 0

function ENT:KeyValue(key, value)
	if key == "OnSuccess" or key == "OnFail" then
		self:StoreOutput(key, value)
	elseif key == "credits" then
		self.Credits = tonumber(value) or 0
	end
end

function ENT:AcceptInput(name, activator)
	if name == "TakeCredits" then
		if IsValid(activator) and activator:IsPlayer() then
			if GetConVar("ttt_activator_debug"):GetBool() then
				Msg(string.format("[TTT Activator] %q:TakeCredits(credits=%d) passthrough -> OnSuccess\n", self:GetName(), self.Credits))
			end
			self:TriggerOutput("OnSuccess", activator)
		end
		return true
	end
end
