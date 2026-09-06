local hull = 10
local HullMaxs = Vector(hull, hull, 72)
local HullMins = -Vector(hull, hull, 0)
local HullDuckMaxs = Vector(hull, hull, 36)
local HullDuckMins = -Vector(hull, hull, 0)
local ViewOffset = Vector(0, 0, 64)
local ViewOffsetDucked = Vector(0, 0, 38)

function ActivateNoCollision(target, min)
	if !IsValid(target) then return end

	local oldCollision = target:GetCollisionGroup()
	target:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)

	timer.Simple(min or 0, function()
		if !IsValid(target) then return end
		local i = 1
		local time = 30
		local checkdtime = 0.5
		timer.Create(target:SteamID64() .. "_checkBounds_cycle", checkdtime, math.Round(time / checkdtime), function()
			if !IsValid(target) then return end
			i = i + 1
			local penetrating = (IsValid(target:GetPhysicsObject()) and target:GetPhysicsObject():IsPenetrating()) or false
			local tooNearPlayer = false

			for i, ply in player.Iterator() do
				if ply == target then continue end
				if !ply:Alive() or IsValid(ply.FakeRagdoll) then continue end
				if target:GetPos():DistToSqr(ply:GetPos()) <= (24 * 24) then
					tooNearPlayer = true
				end
			end

			if (!penetrating and !tooNearPlayer) or i >= (math.Round(time / checkdtime) - 1) then
				if target:GetCollisionGroup() == COLLISION_GROUP_PASSABLE_DOOR then
					target:SetCollisionGroup(oldCollision)
				end

				timer.Destroy(target:SteamID64() .. "_checkBounds_cycle")
			end
		end)
	end)
end

if CLIENT then
	function hg.InstallPlayerRenderOverride(ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end

		ply.RenderOverride = function(self, flags)
			if not IsValid(self) or self:IsDormant() then return end
			if IsValid(self.FakeRagdoll) then return end

			hg.renderOverride(self, nil, flags)
		end
	end

	hook.Add("NetworkEntityCreated", "HG.InstallPlayerRenderOverride", function(ent)
		if ent:IsPlayer() then hg.InstallPlayerRenderOverride(ent) end
	end)

	hook.Add("InitPostEntity", "HG.InstallLocalPlayerRenderOverride", function()
		timer.Simple(0, function()
			local ply = LocalPlayer()
			if IsValid(ply) then hg.InstallPlayerRenderOverride(ply) end
		end)
	end)
end

gameevent.Listen("player_spawn")

local music_packs = {
	"mirrors_edge",
	"swat4",
	"splinter_cell",
}
local hg_sandboxmusic = ConVarExists("hg_sandboxmusic") and GetConVar("hg_sandboxmusic") or CreateConVar("hg_sandboxmusic", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle dynamic music in sandbox gamemode", 0, 1)
local gamemod = engine.ActiveGamemode()

hook.Add("player_spawn", "homigrad-spawn3", function(data)
	local ply = Player(data.userid)
	if not IsValid(ply) then return end

	if CLIENT and ply == LocalPlayer() then
		vp_punch_angle = Angle()
		vp_punch_angle_last = Angle()
		vp_punch_angle2 = Angle()
		vp_punch_angle_last2 = Angle()
	end

	timer.Simple(0, function()
		if not IsValid(ply) then return end

		ply:SetWalkSpeed(100)
		ply:SetRunSpeed(350)
		ply:SetJumpPower(DEFAULT_JUMP_POWER)

		ply:SetHull(HullMins, HullMaxs)
		ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
		ply:SetViewOffset(ViewOffset)
		ply:SetViewOffsetDucked(ViewOffsetDucked)

		ply:SetSlowWalkSpeed(60)
		ply:SetLadderClimbSpeed(150)
		ply:SetCrouchedWalkSpeed(60)
		ply:SetDuckSpeed(0.4)
		ply:SetUnDuckSpeed(0.4)
		ply:AddEFlags(EFL_NO_DAMAGE_FORCES)
	end)

	if SERVER then
		ply:SetNetVar("carryent", nil)
		ply:SetNetVar("carrybone", nil)
		ply:SetNetVar("carrymass", nil)
		ply:SetNetVar("carrypos", nil)

		ply:SetNetVar("carryent2", nil)
		ply:SetNetVar("carrybone2", nil)
		ply:SetNetVar("carrymass2", nil)
		ply:SetNetVar("carrypos2", nil)
	end

	ply:SetNWEntity("spect", NULL)

	ply:SetHull(HullMins, HullMaxs)
	ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
	ply:SetViewOffset(ViewOffset)
	ply:SetViewOffsetDucked(ViewOffsetDucked)

	ply:DrawShadow(true)
	ply:SetRenderMode(RENDERMODE_NORMAL)

	ply:RemoveFlags(FL_NOTARGET)

	if CLIENT then hg.InstallPlayerRenderOverride(ply) end

	hook.Run("Player Getup", ply)

	local override = (CLIENT and hg.override and hg.override[ply]) or (SERVER and OverrideSpawn)

	if eightbit and eightbit.EnableEffect and ply.UserID then
		eightbit.EnableEffect(ply:UserID(), ply.PlayerClassName == "furry" and eightbit.EFF_PROOT or 0)
	end

	if not override then
		hook.Run("Player Spawn", ply)

		if CLIENT and not ply:IsLocal() and gamemod == "sandbox" then
			if hg.DynaMusic then
				if hg_sandboxmusic:GetBool() then
					hg.DynaMusic:Stop()
					hg.DynaMusic:Start(music_packs[math.random(#music_packs)])
				else
					hg.DynaMusic:Stop()
				end
			end
		end

		if SERVER then
			timer.Simple(0, function() ActivateNoCollision(ply, 5) end)
		end

		if SERVER then
			ply.organism.lightstun = 0
			ply:SetLocalVar("stun", ply.organism.lightstun)
			ply.suiciding = false
		end

		ply.posture = 0
	end

	if IsValid(ply) and ply:Alive() and not IsValid(ply.bull) and SERVER then
		timer.Simple(1, function()
			if not IsValid(ply) or not ply:Alive() then return end
			ply.bull = ents.Create("npc_bullseye")
			local bull = ply.bull
			local bon = ply:LookupBone("ValveBiped.Bip01_Head1")
			local mat = bon and ply:GetBoneMatrix(bon)
			local pos = mat and mat:GetTranslation() or ply:EyePos()
			local ang = mat and mat:GetAngles() or ply:EyeAngles()
			bull:SetPos(pos)
			bull:SetAngles(ang)
			bull:SetMoveType(MOVETYPE_OBSERVER)
			bull:SetKeyValue("targetname", "Bullseye")
			bull:SetParent(ply, ply:LookupBone("ValveBiped.Bip01_Head1"))
			bull:SetKeyValue("health", "9999")
			bull:SetKeyValue("spawnflags", "256")
			bull:Spawn()
			bull:Activate()
			bull:SetNotSolid(true)

			bull.ply = ply
			for i, ent in ipairs(ents.FindByClass("npc_*")) do
				if not IsValid(ent) or not ent.AddEntityRelationship then continue end
				ent:AddEntityRelationship(bull, ent:Disposition(ply))
			end
		end)
	end
end)

hook.Add("Player Spawn", "default-thingies", function(ply)
	if OverrideSpawn then return false end
end)

hook.Add("Player Activate", "SetHull", function(ply)
	ply:SetHull(HullMins, HullMaxs)
	ply:SetHullDuck(HullDuckMins, HullDuckMaxs)
	ply:SetViewOffset(ViewOffset)
	ply:SetViewOffsetDucked(ViewOffsetDucked)
end)

hook.Add("Player Spawn", "SetHull", function(ply)
	ply:SetNWEntity("FakeRagdoll", NULL)
	ply:SetObserverMode(OBS_MODE_NONE)
end)
