if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_melee"
SWEP.PrintName = "Ballistic Shield"
SWEP.Instructions = "Anti-ballistic shield for police entry teams. Passively stops pistol-caliber rounds, shrapnel and melee hits while held. Covers your back when holstered.\n\nLMB/RMB to shove."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 3

SWEP.WorldModel = "models/weapons/arccw_go/v_shield.mdl"
SWEP.WorldModelReal = "models/weapons/arccw_go/v_shield.mdl"
SWEP.WorldModelExchange = false
SWEP.ViewModel = ""
SWEP.HoldType = "melee2"
SWEP.weight = 5

SWEP.setlh = true
SWEP.setrh = true
SWEP.TwoHanded = false
SWEP.CanSuicide = false
SWEP.WorkWithFake = true
SWEP.WepSelectIcon = Material("entities/shit.png")
SWEP.WepSelectIcon2 = Material("entities/shit.png")
SWEP.IconOverride = "entities/shit.png"

SWEP.HoldPos = Vector(5, 1, 2)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.AnimList = {
	["idle"] = "idle",
	["deploy"] = "deploy",
	["attack"] = "bash",
	["attack2"] = "bash",
}

SWEP.AttackTime = 0.3
SWEP.AnimTime1 = 1
SWEP.WaitTime1 = 0.9
SWEP.AttackLen1 = 40
SWEP.ViewPunch1 = Angle(1, 1, 0)

SWEP.Attack2Time = 0.3
SWEP.AnimTime2 = 1
SWEP.WaitTime2 = 0.9
SWEP.AttackLen2 = 40
SWEP.ViewPunch2 = Angle(1, -1, 0)

SWEP.AttackTimeLength = 0.15
SWEP.Attack2TimeLength = 0.15
SWEP.AttackRads = 43
SWEP.AttackRads2 = 43
SWEP.SwingAng = 0
SWEP.SwingAng2 = 0

SWEP.DamageType = DMG_CLUB
SWEP.DamagePrimary = 25
SWEP.DamageSecondary = 15
SWEP.PenetrationPrimary = 1
SWEP.PenetrationSecondary = 1
SWEP.MaxPenLen = 1
SWEP.PenetrationSizePrimary = 3
SWEP.PenetrationSizeSecondary = 3
SWEP.StaminaPrimary = 30
SWEP.StaminaSecondary = 20
SWEP.PainMultiplier = 1.2
SWEP.HeadRagdollChance = 0.08

SWEP.AttackSwing = "weapons/slam/throw.wav"
SWEP.AttackHit = "physics/metal/metal_barrel_impact_hard7.wav"
SWEP.Attack2Hit = "physics/metal/metal_barrel_impact_hard7.wav"
SWEP.AttackHitFlesh = "physics/body/body_medium_break3.wav"
SWEP.Attack2HitFlesh = "physics/body/body_medium_break3.wav"
SWEP.DeploySnd = "physics/metal/metal_canister_impact_soft2.wav"


SWEP.ShieldMaxSpeed = 600

SWEP.ShieldFrontDot = -0.25
SWEP.ShieldBackDot = 0.35

SWEP.BlockMaterial = "metal"
SWEP.BlockSound = {"physics/metal/metal_sheet_impact_hard2.wav", 85, {125, 155}}

SWEP.ShieldHitboxSize = Vector(2.8, 14, 24.5)
SWEP.ShieldHitboxForward = 5
SWEP.ShieldHitboxUp = -16.4
SWEP.ShieldHitboxSide = 0
SWEP.ShieldHitboxFaceDot = -0.2
SWEP.ShieldFakeHandPos = Vector(0, 0, 12)
SWEP.ShieldFakeHandAng = Angle(0, 0, 0)

SWEP.ShieldUseModelBounds = true

SWEP.ShieldBackHitboxSize = Vector(2.8, 14, 24.5)
SWEP.ShieldBackHitboxForward = 5.2
SWEP.ShieldBackHitboxUp = -16.2
SWEP.ShieldBackHitboxSide = 0

SWEP.ShieldBlockStaminaCost = 25
SWEP.ShieldBlockRegenMul = 0.3
SWEP.ShieldExhaustRagdollTime = 1.5
SWEP.ShieldExhaustCooldown = 4

SWEP.ShieldBlockRifles = true
SWEP.ShieldRifleStaminaDrain = 45
SWEP.ShieldRifleIntegrityMax = 4

SWEP.ShieldKickPushForce = 480
SWEP.ShieldKickRagdollChance = 0.12
SWEP.ShieldKickStandingPushMul = 0.4
SWEP.ShieldKickStandingRagdollChance = 0.08

SWEP.ShieldMeleeBlockSizeAdd = Vector(0, 6, 6)
SWEP.ShieldMeleeFrontDot = 0.5
SWEP.ShieldMeleeBackDot = -0.3

local shieldClass = "weapon_ballistic_shield"

local BackBone = "ValveBiped.Bip01_Spine2"
local BackPos = Vector(15, 0.5, 1)
local BackAng = Angle(0, -90, -90)

local shieldModelBounds = {}

local function GetShieldModelBounds(shield)
	local model = shield.WorldModel or "models/weapons/arccw_go/v_shield.mdl"
	local cached = shieldModelBounds[model]
	if cached then return cached.center, cached.half end

	if util.GetModelBounds then
		local mins, maxs = util.GetModelBounds(model)
		if mins and maxs and (maxs - mins):LengthSqr() > 4 then
			local center = (mins + maxs) * 0.5
			local half = (maxs - mins) * 0.5
			shieldModelBounds[model] = { center = center, half = half }
			return center, half
		end
	end
end

local function GetShieldHitbox(shield, ply)
	local fake = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll
	local pos, ang

	if fake and shield.InUse and not shield:InUse() then
		local handBone = fake:LookupBone("ValveBiped.Bip01_R_Hand")
		local handMatrix = handBone and fake:GetBoneMatrix(handBone)
		if not handMatrix then return end

		pos, ang = LocalToWorld(
			shield.ShieldFakeHandPos or Vector(0, 0, 12),
			shield.ShieldFakeHandAng or Angle(0, 0, 0),
			handMatrix:GetTranslation(),
			handMatrix:GetAngles()
		)
	else
		local eyeTrace = hg.eyeTrace(ply, 40, hg.GetCurrentCharacter(ply))
		if not eyeTrace or not isvector(eyeTrace.StartPos) then return end

		local eyeAng = ply:EyeAngles()
		local hpos = shield.HoldPos or Vector(5, 1, 2)
		local hang = shield.HoldAng or Angle(0, 0, 0)
		pos, ang = LocalToWorld(hpos, hang, eyeTrace.StartPos, eyeAng)
	end

	local size
	if shield.ShieldUseModelBounds ~= false then
		local center, half = GetShieldModelBounds(shield)
		if center then
			pos = LocalToWorld(center, Angle(0, 0, 0), pos, ang)
			size = half
		end
	end
	if not size then
		size = shield.ShieldHitboxSize or Vector(2.8, 14, 24.5)
	end

	local forward = shield.ShieldHitboxForward or 0
	local up = shield.ShieldHitboxUp or 0
	local side = shield.ShieldHitboxSide or 0
	pos = pos + ang:Forward() * forward + ang:Up() * up + ang:Right() * side

	return pos, ang, size
end

local function GetAmmoSpeed(ammoType)
	local ammo = hg.ammotypeshuy and hg.ammotypeshuy[ammoType or ""]
	return ammo and ammo.BulletSettings and ammo.BulletSettings.Speed or 0
end

local function IsRifleRound(shield, ammoType)
	if ammoType == "Metal Debris" then return false end
	return GetAmmoSpeed(ammoType) > (shield.ShieldMaxSpeed or 600)
end

local function GetShieldIntegrity(shield)
	local max = shield.ShieldRifleIntegrityMax or 4
	local integ = shield.ShieldRifleIntegrity
	if integ == nil then integ = max end
	return integ
end

local function ShieldCanBlockAmmo(shield, ammoType)
	if ammoType == "Metal Debris" then return true end
	if GetAmmoSpeed(ammoType) <= (shield.ShieldMaxSpeed or 600) then return true end
	if shield.ShieldBlockRifles == false then return false end
	return GetShieldIntegrity(shield) > 0
end

local function ApplyRifleBlockConsequences(shield, ply, ammoType)
	if not SERVER or not IsRifleRound(shield, ammoType) then return end

	local org = ply.organism
	if org and org.stamina then
		local stam = org.stamina
		stam[1] = math.max(0, stam[1] - (shield.ShieldRifleStaminaDrain or 45))
		stam.subadd = (stam.subadd or 0) + 1.5
		stam.regenMul = math.min(stam.regenMul or 1, 0.5)
	end

	local integ = GetShieldIntegrity(shield)
	shield.ShieldRifleIntegrity = math.max(0, integ - 1)
end

local function ShieldBlockImpact(data, hitPos)
	if SERVER or IsFirstTimePredicted() then
		local fx = EffectData()
		fx:SetOrigin(hitPos)
		fx:SetNormal(-(data.Trace.Normal or Vector(0, 0, 1)))
		util.Effect("StunstickImpact", fx)
	end

	if SERVER then
		sound.Play("physics/metal/metal_solid_impact_bullet" .. math.random(2, 4) .. ".wav", hitPos, 80, math.random(90, 110))
	end

	return false
end

function SWEP:CanBlock()
	return false
end

local function GetBackShieldHitbox(shield, ply)
	local ragdoll = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll
		or (IsValid(ply.OldRagdoll) and ply.OldRagdoll:IsRagdoll() and ply.OldRagdoll)
	local body = ragdoll or ply

	local boneId = body:LookupBone(BackBone)
	if not boneId then return end
	local matrix = body:GetBoneMatrix(boneId)
	if not matrix then return end

	local pos, ang = LocalToWorld(BackPos, BackAng, matrix:GetTranslation(), matrix:GetAngles())

	local size
	if shield.ShieldUseModelBounds ~= false then
		local center, half = GetShieldModelBounds(shield)
		if center then
			pos = LocalToWorld(center, Angle(0, 0, 0), pos, ang)
			size = half
		end
	end
	if not size then
		size = shield.ShieldBackHitboxSize or shield.ShieldHitboxSize or Vector(2.8, 14, 24.5)
	end

	local forward = shield.ShieldBackHitboxForward or 0
	local up = shield.ShieldBackHitboxUp or 0
	local side = shield.ShieldBackHitboxSide or 0
	pos = pos + ang:Forward() * forward + ang:Up() * up + ang:Right() * side

	return pos, ang, size
end

local function ShieldBoxHit(pos, ang, size, from, to, faceForward, faceDot)
	local dir = to - from
	if dir:LengthSqr() <= 0 then return end

	if faceForward then
		local dirNorm = dir:GetNormalized()
		if dirNorm:Dot(faceForward) > faceDot then return end
	end

	local fromLocal = WorldToLocal(from, Angle(0, 0, 0), pos, ang)
	local toLocal = WorldToLocal(to, Angle(0, 0, 0), pos, ang)

	local d = toLocal - fromLocal
	local tmin, tmax = 0, 1
	for i = 1, 3 do
		local axis = i == 1 and "x" or i == 2 and "y" or "z"
		local dv = d[axis]
		local ov = fromLocal[axis]
		local mn, mx = -size[axis], size[axis]
		if math.abs(dv) < 1e-8 then
			if ov < mn or ov > mx then return end
		else
			local inv = 1 / dv
			local t1 = (mn - ov) * inv
			local t2 = (mx - ov) * inv
			if t1 > t2 then t1, t2 = t2, t1 end
			tmin = math.max(tmin, t1)
			tmax = math.min(tmax, t2)
			if tmin > tmax then return end
		end
	end

	local t = math.Clamp(tmin, 0, 1)
	local hitLocal = fromLocal + d * t
	return LocalToWorld(hitLocal, Angle(0, 0, 0), pos, ang)
end

local function ShieldHitboxTest(shield, ply, from, to, inflate)
	local pos, ang, size = GetShieldHitbox(shield, ply)
	if not pos then return end
	if inflate then size = size + inflate end
	if IsValid(ply.FakeRagdoll) and shield.InUse and not shield:InUse() then
		return ShieldBoxHit(pos, ang, size, from, to)
	end
	return ShieldBoxHit(pos, ang, size, from, to, ang:Forward(), shield.ShieldHitboxFaceDot or -0.2)
end

local function ShieldBackHitboxTest(shield, ply, from, to, inflate)
	local pos, ang, size = GetBackShieldHitbox(shield, ply)
	if not pos then return end
	if inflate then size = size + inflate end
	return ShieldBoxHit(pos, ang, size, from, to)
end

local function ShieldFrontalBlock(shield, ply, attackerFrom)
	local fromPos = isvector(attackerFrom) and attackerFrom or ply:WorldSpaceCenter()
	local flatDir = fromPos - ply:WorldSpaceCenter()
	flatDir.z = 0
	if flatDir:LengthSqr() <= 0.0001 then return end
	flatDir:Normalize()

	local flatAng = ply:EyeAngles()
	flatAng.p = 0
	flatAng.r = 0
	local flatFwd = flatAng:Forward()

	if ply:GetActiveWeapon() == shield then
		return flatDir:Dot(flatFwd) > (shield.ShieldMeleeFrontDot or 0.5)
	end
	return flatDir:Dot(flatFwd) < (shield.ShieldMeleeBackDot or -0.3)
end

hook.Add("PostEntityFireBullets", "hg_shield_block", function(shooter, data)
	local ply = data.Trace.Entity

	if IsValid(ply) and not ply:IsPlayer() and ply.IsRagdoll and ply:IsRagdoll() then
		local owner = hg.RagdollOwner and hg.RagdollOwner(ply)
		if IsValid(owner) and owner:IsPlayer() then ply = owner end
	end

	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() then return end

	local shield = ply:GetWeapon(shieldClass)
	if not IsValid(shield) then return end

	if not ShieldCanBlockAmmo(shield, data.AmmoType) then return end

	local hitPos
	if ply:GetActiveWeapon() == shield then
		hitPos = ShieldHitboxTest(shield, ply, data.Trace.StartPos, data.Trace.HitPos)
	else
		hitPos = ShieldBackHitboxTest(shield, ply, data.Trace.StartPos, data.Trace.HitPos)
	end
	if not hitPos then return end

	ApplyRifleBlockConsequences(shield, ply, data.AmmoType)
	return ShieldBlockImpact(data, hitPos)
end)

hook.Add("hg_MeleeShieldBlock", "hg_shield_melee_block", function(attackerWep, ent, attacktype, trace)
	if not IsValid(ent) or not ent:IsPlayer() or not ent:Alive() then return end

	local shield = ent:GetWeapon(shieldClass)
	if not IsValid(shield) then return end

	local owner = attackerWep and attackerWep:GetOwner()
	if not IsValid(owner) then return end

	local from = owner:EyePos()
	if not from or not trace or not trace.HitPos then return end

	local hitPos
	local inflate = shield.ShieldMeleeBlockSizeAdd
	if ent:GetActiveWeapon() == shield then
		hitPos = ShieldHitboxTest(shield, ent, from, trace.HitPos, inflate)
	else
		hitPos = ShieldBackHitboxTest(shield, ent, from, trace.HitPos, inflate)
	end
	if not hitPos and not IsValid(ent.FakeRagdoll) and ShieldFrontalBlock(shield, ent, from) then
		hitPos = trace.HitPos
	end
	if not hitPos then return end

	trace.HGPreventHeadRagdoll = true

	if attackerWep.PlayBlockImpactEffect then
		attackerWep:PlayBlockImpactEffect(trace, shield, "block")
	else
		if trace.HitNormal then
			sound.Play("physics/metal/metal_sheet_impact_hard2.wav", trace.HitPos, 85, math.random(125, 155))
		end
		if SERVER and trace.HitNormal then
			net.Start("hg_melee_block_fx")
			net.WriteVector(trace.HitPos)
			net.WriteVector(trace.HitNormal)
			net.WriteString("metal")
			net.WriteString("block")
			net.Broadcast()

			net.Start("hg_melee_block_shake")
			net.WriteEntity(shield)
			net.WriteVector(trace.HitNormal)
			net.WriteString("block")
			net.Send(ent)
		end
	end

	if SERVER then
		local org = ent.organism
		if org and org.stamina then
			local stam = org.stamina
			local cost = shield.ShieldBlockStaminaCost or 25
			local before = stam[1]
			stam[1] = math.max(0, before - cost)
			stam.regenMul = math.min(stam.regenMul or 1, shield.ShieldBlockRegenMul or 0.3)
			stam.subadd = (stam.subadd or 0) + 1

			if before <= 0.5 then
				local now = CurTime()
				if now >= (shield.ShieldExhaustUntil or 0) then
					shield.ShieldExhaustUntil = now + (shield.ShieldExhaustCooldown or 4)
					hg.LightStunPlayer(ent, shield.ShieldExhaustRagdollTime or 1.5)
				end
			end
		end
	end

	return true
end)

hook.Add("hg_ShieldKickBlock", "hg_shield_kick_block", function(defender, attacker, attackerWep, from, to)
	if not IsValid(defender) or not defender:IsPlayer() or not defender:Alive() then return end
	if not IsValid(attacker) then return end

	local shield = defender:GetWeapon(shieldClass)
	if not IsValid(shield) then return end

	local hitPos
	local inflate = shield.ShieldMeleeBlockSizeAdd
	if defender:GetActiveWeapon() == shield then
		hitPos = ShieldHitboxTest(shield, defender, from, to, inflate)
	else
		hitPos = ShieldBackHitboxTest(shield, defender, from, to, inflate)
	end
	if not hitPos and not IsValid(defender.FakeRagdoll) and ShieldFrontalBlock(shield, defender, from) then
		hitPos = to
	end
	if not hitPos then return end

	if SERVER then
		local normal = (from - to):GetNormalized()
		if attackerWep and attackerWep.PlayBlockImpactEffect then
			attackerWep:PlayBlockImpactEffect({HitPos = hitPos, HitNormal = normal}, shield, "block")
		else
			sound.Play("physics/metal/metal_sheet_impact_hard2.wav", hitPos, 85, math.random(125, 155))
			net.Start("hg_melee_block_fx")
			net.WriteVector(hitPos)
			net.WriteVector(normal)
			net.WriteString("metal")
			net.WriteString("block")
			net.Broadcast()
		end

		local isFake = IsValid(defender.FakeRagdoll)

		local dir = defender:WorldSpaceCenter() - attacker:WorldSpaceCenter()
		dir.z = 0
		if dir:LengthSqr() > 0.0001 then
			dir:Normalize()
			local force = shield.ShieldKickPushForce or 480
			if not isFake then
				force = force * (shield.ShieldKickStandingPushMul or 0.4)
			end
			local ragdoll = isFake and defender.FakeRagdoll or nil
			if IsValid(ragdoll) then
				for i = 0, 1 do
					local phys = ragdoll:GetPhysicsObjectNum(i)
					if IsValid(phys) then
						phys:ApplyForceCenter(dir * force * 18)
					end
				end
			else
				defender:SetVelocity(dir * force)
			end
		end

		local chance = shield.ShieldKickRagdollChance or 0.12
		if not isFake then
			chance = shield.ShieldKickStandingRagdollChance or 0.08
		end
		if math.Rand(0, 1) < chance then
			timer.Simple(0, function()
				if IsValid(defender) and defender:IsPlayer() and defender:Alive() and not IsValid(defender.FakeRagdoll) then
					hg.Fake(defender)
				end
			end)
		end
	end

	return true
end)

if CLIENT then
	local backModels = {}

	local function DrawBackShield(ply)
		local csmdl = backModels[ply]

		if not IsValid(ply) or not ply:Alive() then
			if IsValid(csmdl) then csmdl:SetNoDraw(true) end
			return
		end

		local wep = ply.GetWeapon and ply:GetWeapon(shieldClass)
		if not IsValid(wep) or ply:GetActiveWeapon() == wep then
			if IsValid(csmdl) then csmdl:SetNoDraw(true) end
			return
		end

		local ent = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or ply
		local boneId = ent:LookupBone(BackBone)
		if not boneId then return end

		local matrix = ent:GetBoneMatrix(boneId)
		if not matrix then return end

		if not IsValid(csmdl) then
			csmdl = ClientsideModel(wep.WorldModel)
			if not IsValid(csmdl) then return end
			csmdl:SetNoDraw(true)
			backModels[ply] = csmdl
		end

		local pos, ang = LocalToWorld(BackPos, BackAng, matrix:GetTranslation(), matrix:GetAngles())

		csmdl:SetRenderOrigin(pos)
		csmdl:SetRenderAngles(ang)
		csmdl:SetupBones()
		csmdl:DrawModel()
	end

	hook.Add("PostPlayerDraw", "hg_shield_back", function(ply)
		if IsValid(ply.FakeRagdoll) then return end
		DrawBackShield(ply)
	end)

	hook.Add("PostDrawTranslucentRenderables", "hg_shield_back_fake", function(bDepth, bSkybox)
		if bSkybox then return end

		for _, ply in player.Iterator() do
			if IsValid(ply.FakeRagdoll) then
				DrawBackShield(ply)
			end
		end
	end)

	timer.Create("hg_shield_back_cleanup", 5, 0, function()
		for ply, csmdl in pairs(backModels) do
			if not IsValid(ply) then
				if IsValid(csmdl) then csmdl:Remove() end
				backModels[ply] = nil
			end
		end
	end)

	CreateClientConVar("hg_show_shield_hitbox", "0", true, false)

	net.Receive("hg_shield_hitbox_toggle", function()
		local convar = GetConVar("hg_show_shield_hitbox")
		RunConsoleCommand("hg_show_shield_hitbox", convar:GetBool() and "0" or "1")
	end)

	hook.Add("PostDrawTranslucentRenderables", "hg_shield_hitbox_debug", function(bDepth, bSkybox)
		if bSkybox then return end
		if not GetConVar("hg_show_shield_hitbox"):GetBool() then return end

		for _, ply in player.Iterator() do
			if IsValid(ply) and ply:IsPlayer() and ply:Alive() then
				local shield = ply:GetWeapon(shieldClass)
				if IsValid(shield) then
					if ply:GetActiveWeapon() == shield then
						local pos, ang, size = GetShieldHitbox(shield, ply)
						if pos then
							render.DrawWireframeBox(pos, ang, -size, size, Color(255, 80, 80, 200))
						end
					else
						local pos, ang, size = GetBackShieldHitbox(shield, ply)
						if pos then
							render.DrawWireframeBox(pos, ang, -size, size, Color(80, 120, 255, 200))
						end
					end
				end
			end
		end
	end)

end

if SERVER then
	util.AddNetworkString("hg_shield_hitbox_toggle")

	concommand.Add("hg_test_shield_hitbox", function(ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end

		net.Start("hg_shield_hitbox_toggle")
		net.Send(ply)
	end)
end
