function hg.GetGasolineWet(ent)
		if not IsValid(ent) then return 0 end
		return ent:GetNWFloat("GasolineWet", 0) or 0
	end

	function hg.SetGasolineWet(ent, value)
		if SERVER and IsValid(ent) then
			local v = math.max(0, math.min(100, value or 0))
			ent:SetNWFloat("GasolineWet", v)

			if ent:IsPlayer() and IsValid(ent.FakeRagdoll) then
				ent.FakeRagdoll:SetNWFloat("GasolineWet", v)
			end
		end
	end

	function hg.AddGasolineWet(ent, amount)
		if SERVER and IsValid(ent) then
			hg.SetGasolineWet(ent, hg.GetGasolineWet(ent) + amount)
		end
	end

if SERVER then
	local nextDry, nextSoak = CurTime(), CurTime()

	hook.Add("Think", "GasolineWetThink", function()
		if nextDry < CurTime() then
			nextDry = CurTime() + 0.1

			for _, ply in ipairs(player.GetAll()) do
				if not IsValid(ply) then continue end

				local wet = hg.GetGasolineWet(ply)
				if wet <= 0 then continue end

				if ply:Alive() then
					local char = hg.GetCurrentCharacter(ply)
					if IsValid(char) and char:WaterLevel() >= 2 then
						hg.SetGasolineWet(ply, wet - 20)
					else
						hg.SetGasolineWet(ply, wet - 0.15)
					end
					-- //
				else
					hg.SetGasolineWet(ply, 0)
				end
			end
		end

		if nextSoak < CurTime() then
			nextSoak = CurTime() + 0.5

			for _, ply in ipairs(player.GetAll()) do
				if not IsValid(ply) or not ply:Alive() then continue end

				local char = hg.GetCurrentCharacter(ply)
				if not IsValid(char) then continue end

				local pos = char:GetPos()

				for i, tbl in ipairs(hg.gasolinePath or {}) do
					if (pos - tbl[1]):LengthSqr() < 36 * 36 then
						hg.AddGasolineWet(ply, 1.5)
						break
					end
				end
			end
		end
	end)
end
