WWE       = WWE or {}
WWE.moves = WWE.moves or {}

WWE.Config       = WWE.Config or {}
WWE.Config.Reach = 100
WWE.Config.Hull  = 16
WWE.Config.StaminaCost = 35  -- stamina the attacker loses when performing a move
-- эть нахуй бля наёбка 
local ENTITY = FindMetaTable("Entity")
ENTITY.RealGetVelocity = ENTITY.RealGetVelocity or ENTITY.GetVelocity
function ENTITY:GetVelocity()
    return self.WWE_FakeVel or ENTITY.RealGetVelocity(self)
end

function WWE.ResolvePlayer(ent)
    if not IsValid(ent) then return nil end
    if ent:IsPlayer() then return ent end
    local owner = hg.RagdollOwner(ent)
    if IsValid(owner) and owner:IsPlayer() then return owner end
    return nil
end

function WWE.CanGrapple(ply)
    return IsValid(ply)
        and ply:Alive()
        -- and ply:GetEyeTrace().Entity:IsPlayer()
        -- and not hg.GetCurrentCharacter(ply:GetEyeTrace().Entity):IsRagdoll()
        -- and ply.organism.otrub ~= true
        -- and not hg.GetCurrentCharacter(ply):IsRagdoll()
        -- and ply:IsOnGround()
        -- and not ply:Crouching()
        -- and not ply:KeyDown(IN_DUCK)
end

function WWE.IsGrounded(ply)
    return IsValid(ply) and ply:Alive() and hg.GetCurrentCharacter(ply):IsRagdoll()
end

function WWE.IsStanding(ply)
    return IsValid(ply) and ply:Alive() and not hg.GetCurrentCharacter(ply):IsRagdoll()
end

function WWE.OverVoid(ply)
    local plyz = ply:GetPos().z
    local rply = hg.GetCurrentCharacter(ply)
    local bone = rply:LookupBone("ValveBiped.Bip01_Pelvis") or 0
    local bp   = rply:GetBonePosition(bone)
    if not bp then return false end

    local tr = util.TraceLine({
        start  = Vector(bp.x, bp.y, plyz + 24),
        endpos = Vector(bp.x, bp.y, plyz - 24),
        mask   = MASK_SOLID,
        filter = function(e)
            return not e:IsPlayer() and e:GetClass() ~= "prop_ragdoll"
        end,
    })
    return not tr.Hit
end

function WWE.FindTarget(ply, reach, hull)
    reach = reach or WWE.Config.Reach
    hull  = hull  or WWE.Config.Hull
    local eyePos = ply:EyePos()
    local rad    = Vector(hull, hull, hull)
    local tr = util.TraceHull({
        start  = eyePos,
        endpos = eyePos + ply:GetAimVector() * reach,
        filter = { ply, hg.GetCurrentCharacter(ply) },
        mins   = -rad,
        maxs   = rad,
        mask   = MASK_SHOT,
    })
    return WWE.ResolvePlayer(tr.Entity)
end

function WWE.AnimateRagdoll(rag, model, seq, opts)
    if not IsValid(rag) then return nil end

    if IsValid(rag.AnimModule) then rag.AnimModule:Remove() rag.AnimModule = nil end

    local anm = ents.Create("wwe_ragdoll_anim")
    if not IsValid(anm) then return nil end

    anm:Spawn()
    anm:Setup(rag, model, seq, opts)

    rag.AnimModule = anm
    return anm
end

hook.Add("Should Fake Up", "WWE-HoldDown", function(ply)
    if (ply.WWE_HoldDownUntil or 0) > CurTime() then return false end
end)

function WWE.RagdollDown(ply, model, seq, duration, opts)
    if not IsValid(ply) or not ply:Alive() then return nil end
    
    local rag = ply.FakeRagdoll
    if not IsValid(rag) then
        hg.Fake(ply)
        rag = ply.FakeRagdoll
    end
    if not IsValid(rag) then return nil end

    ply.WWE_HoldDownUntil = CurTime() + duration
    WWE.AnimateRagdoll(rag, model or ply:GetModel(), seq, opts)

    -- keep the fighter's own character model visible; the animation itself is driven by
    -- an invisible BSMod anim entity, but the posed body should be the player's own
    if IsValid(rag) and rag:GetModel() ~= ply:GetModel() then
        rag:SetModel(ply:GetModel())
    end

    return rag
end

function WWE.StandUp(ply)
	if not IsValid(ply) then return end
	ply.WWE_HoldDownUntil = nil
	if IsValid(ply.FakeRagdoll) then hg.FakeUp(ply) end
end

-- Deal organism damage from a WWE move.
-- The victim is ragdolled (FakeRagdoll) during the move; hitting the FakeRagdoll
-- routes through the Homigrad damage hook straight to the player's organism.
function WWE.ApplyMoveDamage(target, attacker, amount, dmgtype)
	amount = amount or 0
	if amount <= 0 then return end
	if not IsValid(target) or not target:Alive() then return end

	local rag = (IsValid(target.FakeRagdoll) and target.FakeRagdoll) or target
	if not IsValid(rag) then return end

	local att = IsValid(attacker) and attacker or target
	local dmgInfo = DamageInfo()
	dmgInfo:SetAttacker(att)
	dmgInfo:SetInflictor(att)
	dmgInfo:SetDamage(amount)
	dmgInfo:SetDamageType(dmgtype or DMG_CLUB)
	dmgInfo:SetDamagePosition(rag:GetPos())
	rag:TakeDamageInfo(dmgInfo)

	-- Manhunt-style execution feedback: a dense body hit plus a quieter flesh layer.
	local hitPos = rag:GetPos() + Vector(0, 0, 42)
	local blunt = {
		"physics/body/body_medium_impact_hard1.wav",
		"physics/body/body_medium_impact_hard3.wav",
		"physics/body/body_medium_impact_hard5.wav",
		"physics/body/body_medium_impact_hard6.wav",
	}
	local flesh = {
		"physics/flesh/flesh_squishy_impact_hard1.wav",
		"physics/flesh/flesh_squishy_impact_hard2.wav",
		"physics/flesh/flesh_squishy_impact_hard3.wav",
		"physics/flesh/flesh_squishy_impact_hard4.wav",
	}
	sound.Play(blunt[math.random(#blunt)], hitPos, 85, math.random(94, 106), 1)
	sound.Play(flesh[math.random(#flesh)], hitPos, 78, math.random(96, 108), 0.65)

	-- Blunt (DMG_CLUB) barely registers pain through the standard path and
	-- never triggers a pain scream, so guarantee the victim feels it directly.
	local org = target.organism
	if org and amount > 0 then
		org.painadd = (org.painadd or 0) + amount * 1.5
		org.lasthit = CurTime()
		org.immobilization = math.min((org.immobilization or 0) + amount * 0.4, 30)
		if hg.QueuePainScream then hg.QueuePainScream(target, math.Clamp(amount / 25, 0.75, 1.5)) end
	end
end

-- Validate that a model contains a sequence (used for custom killmove models).
-- Caches results so we don't create entities on every move use.
local seqCache = {}
function WWE.SeqExists(model, seq)
	local key = model .. "|" .. seq
	if seqCache[key] ~= nil then return seqCache[key] end

	local ok = false
	local ent = ents.Create("prop_dynamic")
	if IsValid(ent) then
		ent:SetModel(model)
		ent:Spawn()
		ent:Activate()

		-- LookupSequence can be unreliable on a fresh entity; double-check by name
		local id = ent:LookupSequence(seq)
		if id and id >= 0 then
			ok = true
		else
			for i = 0, ent:GetSequenceCount() - 1 do
				if ent:GetSequenceName(i) == seq then ok = true break end
			end
		end
		ent:Remove()
	end

	seqCache[key] = ok
	return ok
end

local seqDurCache = {}
function WWE.SeqDuration(model, seq)
	local key = model .. "|" .. seq
	if seqDurCache[key] ~= nil then return seqDurCache[key] end

	local dur = 0
	local ent = ents.Create("prop_dynamic")
	if IsValid(ent) then
		ent:SetModel(model)
		ent:Spawn()
		ent:Activate()

		local id = ent:LookupSequence(seq)
		if id and id >= 0 then
			ent:ResetSequence(id)
			dur = ent:SequenceDuration() or 0
		end
		ent:Remove()
	end

	seqDurCache[key] = dur
	return dur
end

--  Move registry
--  def = {
--    Condition  = function(ply)          -- extra attacker gate (e.g. sprinting)
--    Cooldown   = number                 -- seconds, per attacker per move
--    FindTarget = function(ply)          -- override target search (optional)
--    Execute    = function(ply, target)  -- do the move; return false to abort
--  }

function WWE.RegisterMove(name, def)
    def.name = name
    WWE.moves[name] = def
end

function WWE.RunMove(ply, name)
    local move = WWE.moves[name]
    if not move then return false end
    if not WWE.CanGrapple(ply) then return false end
    if move.Condition and not move.Condition(ply) then return false end

    ply.WWE_Cooldowns = ply.WWE_Cooldowns or {}
    if (ply.WWE_Cooldowns[name] or 0) > CurTime() then return false end

    if (ply.WWE_HoldDownUntil or 0) > CurTime() then return false end

    local finder = move.FindTarget or WWE.FindTarget
    local target = finder(ply)
    if not IsValid(target) or target == ply then return false end
    if hg.GetCurrentCharacter(target):IsRagdoll() and not move.AllowDowned then return false end
    if not WWE.CanGrapple(target) then return false end
    ply.WWE_LastTarget = target

    if move.Execute(ply, target) == false then return false end

    -- rebalance: performing a move drains the attacker's stamina only when it connects
    if ply.organism and ply.organism.stamina then
        ply.organism.stamina.subadd = ply.organism.stamina.subadd + (WWE.Config.StaminaCost or 35)
    end

    if move.Cooldown then
        ply.WWE_Cooldowns[name] = CurTime() + move.Cooldown
    end
    return true
end

--  wwe_move <name>
--  wwe_move rainmaker

concommand.Add("wwe_move", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then ply:ChatPrint("damn something's wrong") return end
    local name = args[1]
    if not name or name == "" then
        ply:ChatPrint("[WWE] Usage: wwe_move <move>")
        return
    end
    if not WWE.moves[name] then
        ply:ChatPrint("[WWE] Unknown move: " .. name)
        return
    end
    WWE.RunMove(ply, name)
end)

concommand.Add("wwe_taunt", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then ply:ChatPrint("damn something's wrong") return end
    local name = args[1]
    if not name or name == "" then
        ply:ChatPrint("[WWE] Usage: wwe_taunt <taunt>")
        return
    end
    if not ply:LookupSequence(name) then
        ply:ChatPrint("[WWE] Unknown sequence: " .. name)
        return
    end
    if hg.GetCurrentCharacter(ply):IsRagdoll() then return end
    if !ply:IsOnGround() then return end
    ply:PlayCustomAnims(name, true, nil, true)
end)

local mods = file.Find("wwe_matchup/modules/*.lua", "LUA")
for _, f in ipairs(mods) do
    include("wwe_matchup/modules/" .. f)
    print("[WWE Matchup] loaded move module: " .. f)
end

include("wwe_matchup/mw_martialartist.lua")
