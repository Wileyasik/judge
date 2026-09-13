local max, min, Clamp = math.max, math.min, math.Clamp

util.AddNetworkString("hg_last_stand")
resource.AddFile("sound/laststand.mp3")

local last_stand_time = 60
local last_stand_min_damage = 180
local last_stand_chance_spread = 500
local last_stand_max_chance = 0.3

local function sendLastStand(org, active)
	local owner = org.owner
	if not IsValid(owner) or not owner:IsPlayer() then return end
	owner.fullsend = true
	net.Start("hg_last_stand")
		net.WriteBool(active)
	net.Send(owner)
	hook.Run(active and "HG_LastStand" or "HG_LastStandEnd", owner, org)
end

local function StartLastStand(org)
	if org.lastStand then return end
	org.lastStand = true
	org.lastStandEnd = CurTime() + last_stand_time
	org.lastStandAcc = 0
	org.adrenalineAdd = max(org.adrenalineAdd or 0, 4)
	sendLastStand(org, true)
end

local function StopLastStand(org)
	if not org.lastStand then return end
	org.lastStand = false
	org.lastStandEnd = 0
	org.adrenalineAdd = min(org.adrenalineAdd or 0, 0.5)
	sendLastStand(org, false)
end

hg.organism.StartLastStand = StartLastStand
hg.organism.StopLastStand = StopLastStand

hook.Add("Org Clear", "LastStandInit", function(org)
	org.lastStand = false
	org.lastStandEnd = 0
	org.lastStandAcc = 0
end)

hook.Add("HomigradDamage", "LastStandAccumulate", function(ply, dmgInfo)
	local org = ply and ply.organism
	if not org or not ply:IsPlayer() or not ply:Alive() then return end
	if org.lastStand or org.otrub then return end
	local dmg = dmgInfo:GetDamage()
	if dmg < 5 then return end

	org.lastStandAcc = min(Clamp((org.lastStandAcc or 0) + dmg, 0, last_stand_min_damage + last_stand_chance_spread), last_stand_min_damage + last_stand_chance_spread)
	if org.lastStandAcc < last_stand_min_damage then return end

	local chance = Clamp((org.lastStandAcc - last_stand_min_damage) / last_stand_chance_spread * last_stand_max_chance, 0, last_stand_max_chance)
	if math.random() <= chance then
		StartLastStand(org)
	end
end)

hook.Add("Org Think", "LastStandThink", function(owner, org, timeValue)
	if not org.isPly then return end

	if org.lastStand then
		if not owner:Alive() or CurTime() >= org.lastStandEnd then
			StopLastStand(org)
			return
		end
		org.adrenalineAdd = max(org.adrenalineAdd or 0, 4)
		return
	end

	org.lastStandAcc = max((org.lastStandAcc or 0) - timeValue * 10, 0)
end)

concommand.Add("hg_last_stand", function(ply, cmd, args)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:IsAdmin() or not ply.organism then return end
	if ply.organism.lastStand then
		StopLastStand(ply.organism)
	else
		StartLastStand(ply.organism)
	end
end)