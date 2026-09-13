util.AddNetworkString("hg_eye_gore_pop")

local EYE_POP_CHANCE = 20
local SKULL_EYE_CHANCE = 30

local function charEnt(org)
	local owner = org and org.owner
	if not IsValid(owner) then return end
	return hg.GetCurrentCharacter(owner)
end

local function resolveEye(org, ent, eyeKey, side, poppedKey, hangKey)
	if (org[eyeKey] or 0) < 1 then return end
	if org[poppedKey] or org[hangKey] then return end

	if math.random(100) <= EYE_POP_CHANCE then
		org[poppedKey] = true
		net.Start("hg_eye_gore_pop")
		net.WriteEntity(ent)
		net.WriteString(side)
		net.Broadcast()
	else
		org[hangKey] = true
	end
end

hook.Add("Org Think", "hg_eye_gore", function(owner, org)
	if not org then return end

	local skull = org.skull or 0
	local lastSkull = org.eyeGoreSkull or 0
	if skull >= 1 and lastSkull < 1 and math.random(100) <= SKULL_EYE_CHANCE then
		org[math.random(2) == 1 and "eyeL" or "eyeR"] = 1
	end
	org.eyeGoreSkull = skull

	if (org.eyeL or 0) < 1 and (org.eyeR or 0) < 1 then return end
	local ent = charEnt(org)
	if not IsValid(ent) or not ent:LookupAttachment("eyes") then return end

	resolveEye(org, ent, "eyeL", "l", "eyePoppedL", "eyeHangL")
	resolveEye(org, ent, "eyeR", "r", "eyePoppedR", "eyeHangR")
end)

hook.Add("Org Clear", "hg_eye_gore", function(org)
	org.eyePoppedL = nil
	org.eyePoppedR = nil
	org.eyeHangL = nil
	org.eyeHangR = nil
	org.eyeGoreSkull = nil
end)
