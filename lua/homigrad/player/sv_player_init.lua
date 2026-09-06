local realismMode = CreateConVar("hg_fullrealismmode", "1", FCVAR_SERVER_CAN_EXECUTE, "Toggle first-person camera view", 0, 1)

cvars.AddChangeCallback("hg_fullrealismmode", function(convar_name, value_old, value_new)
	SetGlobalBool("FullRealismMode", realismMode:GetBool())
end)

SetGlobalBool("FullRealismMode", true)

hook.Add("Player_Death", "notarget_removebull", function(ply)
	if IsValid(ply.bull) then
		ply.bull:Remove()
		ply.bull = nil
	end
	ply:AddFlags(FL_NOTARGET)
end)

hook.Add("Player Think", "homigrad-dropholstered", function(ply)
	local time = CurTime()
	if (ply.thinkdropwep or 0) > time then return end
	ply.thinkdropwep = time + 0.1
	if ply.organism and ply.organism.allowholster then return end

	local activewep = ply:GetActiveWeapon()
	local weps = ply:GetWeapons()
	local wep
	for i = 1, #weps do
		wep = weps[i]

		if wep.NoHolster and activewep ~= wep and wep.picked then
			ply:DropWeapon(wep)
		end
	end
end)

local plymeta = FindMetaTable("Player")

local flags = bit.bor(FCVAR_REPLICATED, FCVAR_NOTIFY, FCVAR_SERVER_CAN_EXECUTE, FCVAR_NEVER_AS_STRING)
local hg_sync = CreateConVar("hg_sync", 0, flags, "Toggle death synchronized (kick player on death)", 0, 1)

local reasons = {
	"Goodbye.",
	"Better luck next time.",
	"Error",
	"Something wrong"
}

function plymeta:SyncDeath()
	local SyncLastMessage = table.Random(reasons)
	if !self:IsSuperAdmin() then
		self:Kick(SyncLastMessage)
	end
end

hook.Add("PlayerDeath", "I_Feel_Death", function(ply)
	if hg_sync:GetBool() then
		ply:SyncDeath()
	end
end)

oldGetUseEntity = oldGetUseEntity or plymeta.GetUseEntity

function plymeta:GetUseEntity()
	local ent = oldGetUseEntity(self)
	if IsValid(ent) and ent:GetParent() != NULL and ent:IsWeapon() then return end
	return ent
end

hook.Add("Player_Death", "FLASHLIGHTHUY", function(ply)
	ply:SetNetVar("flashlight", false)
end)
