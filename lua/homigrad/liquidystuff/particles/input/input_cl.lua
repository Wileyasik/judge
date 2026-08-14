local mats = {}
for i = 1, 3 do
	mats[i] = Material("homigrad/decals/bld" .. i + 3)
end

gasparticles = gasparticles or {}
local vecZero = Vector(0, 0, 0)
local GAS_PARTICLE_TTL = 6
local GAS_PARTICLE_MAX = 2048
function addGasPart(pos, vel, mat, w, h, ent)
	if #gasparticles >= GAS_PARTICLE_MAX then
		table.remove(gasparticles, 1)
	end
	local mat = mats[math.random(#mats)]
	pos = pos + vecZero
	vel = vel + vecZero
	local pos2 = Vector()
	pos2:Set(pos)
	gasparticles[#gasparticles + 1] = {pos, pos2, vel, mat, w, h, ent, CurTime() + GAS_PARTICLE_TTL}
end

net.Receive("gas particle", function() addGasPart(net.ReadVector(), net.ReadVector(), mats[math.random(#mats)], math.random(5, 8), math.random(5, 8), net.ReadEntity()) end)
--[[
hook.Add("Think","liquid_drum_pour",function()
	for i = 1, #drums do
		if not IsValid(drums[i]) then table.remove(drums,i) continue end
		

	end
end)

hook.Add("OnNetVarSet","liquid_drum",function(index, key, var)
	if key == "pouring" then
		local ent = Entity(index)
		if IsValid(ent) then
			
		end
	end
end)
--]]
