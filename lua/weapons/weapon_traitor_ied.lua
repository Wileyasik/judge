if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Improvised Explosive Device"
SWEP.Instructions = "A handmade C4 explosive put in a small cardboard box. The detonator is an old nokia phone. Put the bomb in different objects for shrapnel or fire. LMB to place in an object, RMB to simply place the bomb. LMB to activate it after it's put."
SWEP.Category = "Weapons - Explosive"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/ied.png")
	SWEP.IconOverride = "vgui/ied.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 4
SWEP.SlotPos = 1
SWEP.WorkWithFake = true
SWEP.ViewModel = ""
SWEP.WorldModel = "models/saraphines/insurgency explosives/ied/insurgency_ied.mdl"
SWEP.WorldModelReal = "models/weapons/v_ied_ins.mdl"
SWEP.WorldModelExchange = false
SWEP.FakeScale = 1
SWEP.setlh = true
SWEP.setrh = true
SWEP.HoldPos = Vector(2, 0.2, -1.5)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.traceLen = 5

function SWEP:SetupDataTables()

	self:NetworkVar( "Bool", 0, "Planted" )
	self:NetworkVar( "Bool", 1, "Dialing" )
	self:NetworkVar( "Bool", 2, "Destroyed" )
	self:NetworkVar( "Bool", 3, "Detonating" )
	self:NetworkVar( "Float", 0, "DetonateAt" )
	if SERVER then
		self:SetPlanted(false)
		self:SetDialing(false)
		self:SetDestroyed(false)
		self:SetDetonating(false)
		self:SetDetonateAt(0)
	end
end

SWEP.AnimList = {
	["idle"] = {"idle", 1, true},
	["plant"] = {"plant", 1.5, false, false, function(self)
		if SERVER then self:FinishIEDPlant() end
		self:PlayAnim("det_draw")
	end},
	["det_draw"] = {"det_draw", 1, false, false, function(self)
		self:PlayAnim("det_idle")
	end},
	["det_idle"] = {"det_idle", 1, true},
	["det_detonate"] = {"det_detonate", 1, false}
}

SWEP.AnimsEvents = {
	["plant"] = {
		[0.05] = function(self)
			self:EmitSound("weapons/c4/handling/c4_plant_armmovement.wav", 65)
		end,
		[0.85] = function(self)
			self:EmitSound("weapons/c4/handling/c4_plant_place.wav", 65)
		end
	}
}

if CLIENT then
	local hiddenBoneScale = Vector(0.0001, 0.0001, 0.0001)
	local visibleBoneScale = Vector(1, 1, 1)
	local bombBones = {
		"INSEXP",
		"INS_EXP_Wire_A_0",
		"INS_EXP_Wire_A_01",
		"INS_EXP_Wire_A_02",
		"INS_EXP_Wire_A_03",
		"INS_EXP_Wire_A_04",
		"INS_EXP_Wire_A_05",
		"INS_EXP_Wire_B_02",
		"INS_EXP_Wire_B_03",
		"INS_EXP_Wire_B_04"
	}
	local phoneAnimations = {
		det_draw = true,
		det_idle = true,
		det_detonate = true
	}

	function SWEP:SetHandPos()
		local ply = self:GetOwner()
		local model = self:GetWM()
		if not IsValid(ply) or not IsValid(model) then return end
		if not ply.shouldTransmit or ply.NotSeen then return end

		local ent = hg.GetCurrentCharacter(ply)
		if not IsValid(ent) then return end

		self.rhandik = self.setrh
		self.lhandik = self.setlh and not phoneAnimations[self.anim] and (ply:GetTable().ChatGestureWeight < 0.1)

		local canUseRight = self.rhandik and hg.CanUseRightHand(ply)
		local canUseLeft = self.lhandik and hg.CanUseLeftHand(ply)
		local rightBones = hg.TPIKBonesRHDict
		local leftBones = hg.TPIKBonesLHDict
		local bombScale = self:GetPlanted() and hiddenBoneScale or visibleBoneScale

		for _, boneName in ipairs(bombBones) do
			local bone = model:LookupBone(boneName)
			if bone then model:ManipulateBoneScale(bone, bombScale) end
		end

		local detonatorBone = model:LookupBone("INS_DET")
		if detonatorBone then
			model:ManipulateBoneScale(detonatorBone, self.anim == "idle" and hiddenBoneScale or visibleBoneScale)
		end

		for modelBone = 0, model:GetBoneCount() - 1 do
			local modelBoneName = model:GetBoneName(modelBone)
			local playerBoneName = rightBones[modelBoneName] or leftBones[modelBoneName]
			if not playerBoneName then continue end
			if rightBones[modelBoneName] and not canUseRight then continue end
			if leftBones[modelBoneName] and not canUseLeft then continue end

			local modelMatrix = model:GetBoneMatrix(modelBone)
			local playerBone = ent:LookupBone(playerBoneName)
			if not modelMatrix or not playerBone then continue end

			ent:SetBoneMatrix(playerBone, modelMatrix)
		end
	end
end

function SWEP:ThinkAdd()
	if SERVER and IsValid(self.HaveTheBomb) then
		self.LastBombPos = self.HaveTheBomb:GetPos() + self.HaveTheBomb:OBBCenter()
		self.LastBombModel = self.HaveTheBomb:GetModel()
	end

	if SERVER and self:GetPlanted() and not self:GetDialing() and not self:GetDetonating() and not self.KABOOM and not self.PlantedOnSelf then
		if not IsValid(self.HaveTheBomb) then
			MarkIEDDestroyed(self)
		elseif not IsValid(self.HaveTheBomb:GetPhysicsObject()) then
			ExplodeTheItem(self, self.HaveTheBomb)
		end
	end
end

function SWEP:GetEyeTrace()
	return hg.eyeTrace(self:GetOwner())
end

SWEP.BlastDis = 20
SWEP.BlastDamage = 600
SWEP.CallStartDelay = 1
SWEP.MaxDialTime = 10
SWEP.MaxDialDistance = 3000
SWEP.CallSound = "rem_iedcall.mp3"
SWEP.CallSoundLevel = 100
SWEP.DisorientationRange = 15
SWEP.FireEntForceBonus = 70
SWEP.AttachedBombModel = "models/saraphines/insurgency explosives/ied/insurgency_ied.mdl"
SWEP.AttachedBombScale = 0.8
SWEP.ExplosionSounds = {
	"explosions/explode3.wav",
	"explosions/explode4.wav",
	"explosions/explode5.wav"
}
SWEP.ExplosionSoundLevel = 100
SWEP.ExplosionSoundPitchMin = 85
SWEP.ExplosionSoundPitchMax = 90
SWEP.KABOOM = false

SWEP.SoundFar = {"iedins/ied_detonate_dist_01.wav","ied/ied_detonate_dist_02.wav","ied/ied_detonate_dist_03.wav"}
SWEP.Sound = {"ied/ied_detonate_01.wav", "ied/ied_detonate_02.wav", "ied/ied_detonate_03.wav"}
SWEP.SoundWater = "iedins/water/ied_water_detonate_01.wav"

local FireEnts = {
	["models/props_c17/oildrum001_explosive.mdl"] = true,
	["models/props_junk/gascan001a.mdl"] = true,
	["models/props_junk/propane_tank001a.mdl"] = true,
	["models/props_c17/canister02a.mdl"] = true,
	["models/props_c17/canister_propane01a.mdl"] = true,
	["models/props_c17/canister_propane01a.mdl"] = true,
	["models/props_junk/PropaneCanister001a.mdl"] = true
}

if CLIENT then
	local colWhite = Color(255, 255, 255, 255)
	local colblue = Color(40,40,160)
	local colred = Color(160,40,40)
	local lerpthing = 0
	function SWEP:DrawHUD()
		if GetViewEntity() ~= LocalPlayer() then return end
		if LocalPlayer():InVehicle() then return end
		local tr = self:GetEyeTrace()

		if not tr then return end
		local toScreen = tr.HitPos:ToScreen()
		local Size = math.max(math.min(1 - (tr and tr.Fraction or 0), 1), 0.1)
		local x, y = tr.HitPos:ToScreen().x, tr.HitPos:ToScreen().y
	
		lerpthing = Lerp(0.1, lerpthing, tr.Hit and 1 or 0)
		colWhite.a = 255 * Size * lerpthing
		surface.SetDrawColor(colWhite)
		surface.DrawRect(x - 25 * lerpthing * 0.1, y - 2.5, 50 * lerpthing * 0.1, 5)
		surface.DrawRect(x - 2.5, y - 25 * lerpthing * 0.1, 5, 50 * lerpthing * 0.1)

		if self:GetDestroyed() then
			local xrand,yrand = math.random(-1,1),math.random(-1,1)
			draw.SimpleText( "IED destroyed", "HomigradFontMedium", toScreen.x + 2 + xrand, toScreen.y + 26 + yrand, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "IED destroyed", "HomigradFontMedium", toScreen.x + xrand, toScreen.y + 25 + yrand, color_red, TEXT_ALIGN_CENTER )
		elseif self:GetDetonating() then
			local xrand,yrand = math.random(-1,1),math.random(-1,1)
			draw.SimpleText( "Detonating..", "HomigradFontMedium", toScreen.x + 2 + xrand, toScreen.y + 26 + yrand, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Detonating..", "HomigradFontMedium", toScreen.x + xrand, toScreen.y + 25 + yrand, color_red, TEXT_ALIGN_CENTER )
		elseif self:GetDialing() then
			local xrand,yrand = math.random(-1,1),math.random(-1,1)
			local timeText = "Time: " .. math.Round(math.max(self:GetDetonateAt() - CurTime(), 0), 1) .. "s"
			draw.SimpleText( "Dialing...", "HomigradFontMedium", toScreen.x + 2 + xrand, toScreen.y + 26 + yrand, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Dialing...", "HomigradFontMedium", toScreen.x + xrand, toScreen.y + 25 + yrand, color_red, TEXT_ALIGN_CENTER )
			draw.SimpleText( timeText, "HomigradFont", toScreen.x + 2 + xrand, toScreen.y + 56 + yrand, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( timeText, "HomigradFont", toScreen.x + xrand, toScreen.y + 55 + yrand, color_white, TEXT_ALIGN_CENTER )
		elseif IsValid(tr.Entity) and not tr.Entity:IsPlayer() and not tr.Entity:IsRagdoll() and not self:GetPlanted() then
			local min, max = tr.Entity:GetModelBounds()
			local minmaxs = (max - min)
			local size = minmaxs[1] + minmaxs[2] + minmaxs[3]
			if size <= 15 then return end

			if tr.MatType == MAT_METAL then
				draw.SimpleText( "It will explode with shrapnel.", "HomigradFont", toScreen.x+3, toScreen.y + 25 + 32, color_black, TEXT_ALIGN_CENTER )
				draw.SimpleText( "It will explode with shrapnel.", "HomigradFont", toScreen.x, toScreen.y + 25 + 30, colblue, TEXT_ALIGN_CENTER )
			end

			if FireEnts[tr.Entity:GetModel()] then
				draw.SimpleText( "It will explode creating a fire.", "HomigradFont", toScreen.x+3, toScreen.y + 25 + 62, color_black, TEXT_ALIGN_CENTER )
				draw.SimpleText( "It will explode creating a fire.", "HomigradFont", toScreen.x, toScreen.y + 25 + 60, colred, TEXT_ALIGN_CENTER )
			end
			draw.SimpleText( "Plant onto Object.", "HomigradFont", toScreen.x + 3, toScreen.y + 27, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Plant onto Object.", "HomigradFont", toScreen.x, toScreen.y + 25, color_white, TEXT_ALIGN_CENTER )
		elseif self:GetPlanted() then		
			local xrand,yrand = math.random(-1,1),math.random(-1,1)
			draw.SimpleText( "LMB to explode.", "HomigradFontMedium", toScreen.x + 2 + xrand, toScreen.y + 26 + yrand, color_black, TEXT_ALIGN_CENTER )
			draw.SimpleText( "LMB to explode.", "HomigradFontMedium", toScreen.x + xrand, toScreen.y + 25 + yrand, color_red, TEXT_ALIGN_CENTER )
		end
	end
end

function hg.ExplosionDisorientation(enta, tinnitus, disorientation)
	local owner = enta.organism and enta.organism.owner
	local hasHeadphones = IsValid(owner) and owner.armors and owner.armors["ears"] == "headphones1"

	-- дизориентация (мотание экрана) — полная, как было
	enta.organism.disorientation = enta.organism.disorientation + disorientation

	if hasHeadphones then
		-- активные наушники (броня headphones1): тинитуса нет вообще, мотание экрана остаётся
	else
		-- без активных наушников — полный/громкий тинитус и контузия
		if IsValid(owner) then owner:AddTinnitus(tinnitus) end
		hg.organism.module.concussion.AddConcussion(enta.organism, math.Clamp(tinnitus * 0.1, 0.1, 2.0), tinnitus)
	end

	net.Start("organism_send") // отправляем только дизориентацию (чтобы не нагружать нет), и сразу
	local tbl = {}
	tbl.disorientation = enta.organism.disorientation
	tbl.shock = enta.organism.shock
	tbl.owner = enta.organism.owner
	net.WriteTable(tbl)
	net.WriteBool(true)
	net.WriteBool(false)
	net.WriteBool(false)
	net.WriteBool(true) // вот эта шняга отвечает за то чтобы оно просто мерджнуло и всё
	net.Send(enta.organism.owner)
end

function SWEP:CreateFake() end

local ExplodeTheItem
local RemoveAttachedBombVisual

local function MarkIEDDestroyed(self)
	if not IsValid(self) then return end

	self:SetDialing(false)
	self:SetDetonateAt(0)
	self:SetDestroyed(true)
	self:SetDetonating(false)
	self:SetPlanted(false)
	self.HaveTheBomb = nil
	RemoveAttachedBombVisual(self)
end

RemoveAttachedBombVisual = function(self)
	if IsValid(self.AttachedBombVisual) then
		self.AttachedBombVisual:Remove()
	end

	self.AttachedBombVisual = nil
end

local function CreateAttachedBombVisual(self, ent, tr)
	if not IsValid(ent) or not tr then return end

	RemoveAttachedBombVisual(self)

	local visual = ents.Create("prop_dynamic")
	if not IsValid(visual) then return end

	visual:SetModel(self.AttachedBombModel)
	visual:SetModelScale(self.AttachedBombScale, 0)
	visual:SetSolid(SOLID_NONE)
	visual:SetMoveType(MOVETYPE_NONE)
	visual:SetCollisionGroup(COLLISION_GROUP_WORLD)
	visual:Spawn()
	visual:Activate()

	local ang = tr.HitNormal:Angle()
	ang:RotateAroundAxis(ang:Right(), 90)
	ang:RotateAroundAxis(ang:Up(), 90)

	visual:SetParent(ent)
	visual:SetLocalPos(ent:WorldToLocal(tr.HitPos + tr.HitNormal * 4))
	visual:SetLocalAngles(ent:WorldToLocalAngles(ang))

	ent:DeleteOnRemove(visual)
	self:DeleteOnRemove(visual)
	self.AttachedBombVisual = visual
end

local function RegisterIEDBomb(self, ent, tr)
	if not IsValid(ent) then return end

	self.HaveTheBomb = ent
	self:SetDestroyed(false)
	self:SetDetonating(false)
	self:SetPlanted(true)
	ent.bombowner = self
	ent.IEDOwner = self
	ent.IEDBlastBonus = self.FireEntForceBonus
	ent:CallOnRemove("ied_destroy_" .. self:EntIndex(), function(removedEnt)
		if IsValid(self) and not self.KABOOM then
			if IsValid(removedEnt) then
				ExplodeTheItem(self, removedEnt)
			else
				MarkIEDDestroyed(self)
			end
		end
	end)

	if tr then
		CreateAttachedBombVisual(self, ent, tr)
	end
end

local function GetIEDDialDelay(self, ent)
	local owner = self:GetOwner()
	local entPos = IsValid(ent) and (ent:GetPos() + ent:OBBCenter()) or vector_origin
	local ownerPos = IsValid(owner) and owner:GetPos() or entPos
	local distance = ownerPos:Distance(entPos)
	return Lerp(math.Clamp(distance / self.MaxDialDistance, 0, 1), self.CallStartDelay, self.MaxDialTime)
end

local function PlayIEDExplosionSound(self, ent)
	if IsValid(ent) then
		ent:EmitSound(table.Random(self.ExplosionSounds), self.ExplosionSoundLevel, math.random(self.ExplosionSoundPitchMin, self.ExplosionSoundPitchMax), 1, CHAN_AUTO)
	else
		sound.Play(table.Random(self.ExplosionSounds), self.LastBombPos or self:GetPos(), self.ExplosionSoundLevel, math.random(self.ExplosionSoundPitchMin, self.ExplosionSoundPitchMax), 1)
	end
end

local function StartIEDDetonation(self, ent)
	if self:GetDialing() then return end

	local delay = GetIEDDialDelay(self, ent)

	self:SetDialing(true)
	self:SetDestroyed(false)
	self:SetDetonating(false)
	self:SetDetonateAt(CurTime() + delay)
	self:EmitSound("keypad"..math.random(1,3)..".mp3",55)

	timer.Simple(self.CallStartDelay, function()
		if not IsValid(ent) then return end
		ent:EmitSound(self.CallSound, self.CallSoundLevel, 100, 1, CHAN_AUTO)
	end)

	timer.Simple(delay, function()
		if not IsValid(self) then return end

		self:SetDialing(false)
		self:SetDetonateAt(0)
		self:SetDetonating(true)

		if self.KABOOM then return end

		if self.PlantedOnSelf then
			ExplodeTheItem(self, self:GetOwner())
		else
			ExplodeTheItem(self, self.HaveTheBomb)
		end

		self.HaveTheBomb = nil
	end)
end

ExplodeTheItem = function(self,ent)
	local ent = ent
	local entValid = IsValid(ent)
	local EntPos = entValid and (ent:GetPos() + ent:OBBCenter()) or self.LastBombPos
	if not EntPos then self:Remove() return end

	local entModel = entValid and ent:GetModel() or self.LastBombModel
	local entWaterLevel = entValid and ent:WaterLevel() or 0
	local entAngles = entValid and ent:GetAngles() or angle_zero
	local mat = entValid and ent:GetMaterialType() or nil

	self.KABOOM = true
	self:SetDialing(false)
	self:SetDetonateAt(0)
	self:SetDestroyed(false)
	self:SetDetonating(true)
	RemoveAttachedBombVisual(self)
	if entValid then
		ent:StopSound(self.CallSound)
	end
	local BlastDamage = self.BlastDamage
	local BlastDis = self.BlastDis
	local owner = self:GetOwner()

	if entValid and hg and hg.GasTank and hg.GasTank.ActiveTanks and hg.GasTank.ActiveTanks[ent:EntIndex()] and hg.GasTankDetonate then
		hg.GasTankDetonate(ent)
		self.HaveTheBomb = nil
		if IsValid(self) then
			self:Remove()
		end
		return
	end

	local fireData = entModel and hg and hg.expItems and hg.expItems[entModel]
	if entValid and fireData and hg and hg.PropExplosion then
		local phys = ent:GetPhysicsObject()
		local mass = IsValid(phys) and phys:GetMass() or 10
		ent.IEDBlastBonus = nil
		ent.IEDOwner = nil
		hg.PropExplosion(ent, fireData.ExpType, ((ent.Volume or fireData.Force) * 2) + self.FireEntForceBonus, mass, fireData)
		self.HaveTheBomb = nil
		if IsValid(self) then
			self:Remove()
		end
		return
	end

	timer.Simple(0.4,function()
		timer.Simple(0.1,function()
			PlayIEDExplosionSound(self, ent)
			net.Start("projectileFarSound")
				net.WriteString(table.Random(self.Sound))
				net.WriteString(table.Random(self.SoundFar))
				net.WriteVector(EntPos)
				net.WriteEntity(entValid and ent or Entity(0))
				net.WriteBool(entWaterLevel > 0)
				net.WriteString(self.SoundWater)
			net.Broadcast()

			if entWaterLevel == 0 then
				ParticleEffect("pcf_jack_groundsplode_medium",EntPos,-vector_up:Angle())
			else
				local effectdata = EffectData()
				effectdata:SetOrigin(EntPos)
				effectdata:SetScale(5)
				effectdata:SetNormal(-entAngles:Forward())
				util.Effect("eff_jack_genericboom", effectdata)
			end
			hg.ExplosionEffect(EntPos, BlastDis / 0.12, 80)

			if mat == MAT_METAL then
				local Poof=EffectData()
				Poof:SetOrigin(EntPos)
				Poof:SetScale(1)
				util.Effect("eff_jack_hmcd_shrapnel",Poof,true,true)
			end
		end)

		timer.Simple(0.2,function()
			util.BlastDamage(self, IsValid(self:GetOwner()) and self:GetOwner() or self, EntPos, BlastDis / 0.01905, BlastDamage * 0.1) -- эта функция полное говно кстати. бьет сковзь любые пропы...
			
			local dis = BlastDis / 0.01905
			local disorientation_dis = self.DisorientationRange / 0.01905
			for _, enta in ipairs(ents.FindInSphere(EntPos, disorientation_dis)) do
				local tracePos = enta:IsPlayer() and (enta:GetPos() + enta:OBBCenter()) or enta:GetPos()
				local tr = hg.ExplosionTrace(EntPos, tracePos, {ent})

				local phys = enta:GetPhysicsObject()
				local force = (enta:GetPos() - EntPos)
				local len = force:Length()
				force:Div(len)
				local frac = math.Clamp((disorientation_dis - len) / disorientation_dis, 0.1, 1)  
				local physics_frac = math.Clamp((dis - len) / dis, 0.5, 1)  
				local forceadd = force * physics_frac * 50000  

			if enta.organism then
				local behindwall = tr.Entity != enta and tr.MatType != MAT_GLASS
				if IsValid(enta.organism.owner) and enta.organism.owner:IsPlayer() then
					local div = behindwall and hg.GetBlastWallAttenuation(tr) or 1
					hg.ExplosionDisorientation(enta, 5 * frac * 1.5 / div, 6 * frac * 1.5 / div)
					hg.RunZManipAnim(enta.organism.owner, "shieldexplosion")
				end
			end

				if len > dis then continue end
				if tr.Entity != enta then 					
					if IsValid(phys) then
						phys:ApplyForceCenter((forceadd/20) + vector_up * math.random(500,550))
					end

					continue
				end

				if enta:IsPlayer() then
					hg.AddForceRag(enta, 0, forceadd * 0.5, 0.5)
					hg.AddForceRag(enta, 1, forceadd * 0.5, 0.5)

					hg.LightStunPlayer(enta)
				end

				if not IsValid(phys) then continue end
				phys:ApplyForceCenter(forceadd)
			end

			--hgWreckBuildings(ent, EntPos, BlastDamage / 400, BlastDis/8, false)
			hgBlastDoors(entValid and ent or self, EntPos, BlastDamage / 400, BlastDis/8, false)
			util.ScreenShake( EntPos, 45, 225, 2.5, 3000 )

			if FireEnts[entModel] then
				local Tr = util.QuickTrace(EntPos, -vector_up*500, {EntPos})
				local fire = CreateVFire(game.GetWorld(), Tr.HitPos, Tr.HitNormal, 300, IsValid(owner) and owner or self)
				if IsValid(fire) then
					fire:ChangeLife(300)
				end
			end

			if mat == MAT_METAL and entValid and IsValid(ent:GetPhysicsObject()) then
				local co = coroutine.create(function()
					local LastShrapnel = SysTime()

					for i = 1, math.Round(ent:GetPhysicsObject():GetMass() * 50) do
							LastShrapnel = SysTime()

							local dir = VectorRand(-1,1):GetNormalized()--vector_up
							dir[3] = dir[3] > 0 and math.abs(dir[3] - 0.5) or -math.abs(dir[3] + 0.5)
							dir:Normalize()

							local Tr = util.QuickTrace(EntPos, dir * 205, ent)

							if Tr.Hit and !Tr.HitSky and !Tr.HitWorld then
								local bullet = {}
								bullet.Dir = dir
								bullet.Src = EntPos
								bullet.Force = 0.01
								bullet.Damage = BlastDamage
								bullet.AmmoType = "Metal Debris"
								bullet.Attacker = self:GetOwner()
								bullet.Distance = 205
								bullet.DisableLagComp = true
								bullet.Filter = {ent}
								bullet.Penetration = 4
								--bullet.Spread = vecCone * i / self.Fragmentation
								ent:FireLuaBullets(bullet, true)
							end

							LastShrapnel = SysTime() - LastShrapnel

							if LastShrapnel > 0.001 then
								coroutine.yield()
							end
					end

					ent.ShrapnelDone = true
				end)

				coroutine.resume(co)

				local index = ent:EntIndex()

				if IsValid(self) then
					self:Remove()
				end

				timer.Create("IEDCheck_" .. index, 0, 0, function()
					if not IsValid(ent) then
						timer.Remove("IEDCheck_" .. index)
						return
					end

					coroutine.resume(co)
					if ent.ShrapnelDone then
						ent:Remove()
						timer.Remove("IEDCheck_" .. index)
					end
				end)
			end

			if IsValid(self) then
				self:Remove()
			end

			if mat != MAT_METAL and IsValid(ent) then
				ent:Remove()
			end
		end)
	end)
end

function SWEP:CanSecondaryAttack()
	return not self.IEDPlantPending and IsValid(self:GetOwner()) and not hg.GetCurrentCharacter(self:GetOwner()):IsRagdoll()
end

function SWEP:BeginIEDPlant(mode, tr)
	if self.IEDPlantPending or self:GetPlanted() then return end

	self.IEDPlantPending = true
	self.IEDPlantMode = mode
	self.IEDPlantEntity = tr.Entity
	self.IEDPlantPos = tr.HitPos
	self.IEDPlantNormal = tr.HitNormal
	self:PlayAnim("plant")
end

function SWEP:FinishIEDPlant()
	if not self.IEDPlantPending or self:GetPlanted() then return end

	local owner = self:GetOwner()
	local mode = self.IEDPlantMode
	local bomb

	if mode == "attached" then
		bomb = self.IEDPlantEntity
		if not IsValid(bomb) or not IsValid(bomb:GetPhysicsObject()) then
			self.IEDPlantPending = false
			self:PlayAnim("idle")
			return
		end
	else
		bomb = ents.Create("prop_physics")
		if not IsValid(bomb) then
			self.IEDPlantPending = false
			self:PlayAnim("idle")
			return
		end

		bomb:SetModel("models/saraphines/insurgency explosives/ied/insurgency_ied.mdl")
		bomb:SetPos(self.IEDPlantPos + self.IEDPlantNormal * 4)
		bomb:SetModelScale(0.8)
		bomb:Spawn()
		bomb:Activate()

		if IsValid(bomb:GetPhysicsObject()) then
			bomb:GetPhysicsObject():SetMass(20)
		end
	end

	self.Planted = true
	RegisterIEDBomb(self, bomb, mode == "attached" and {
		HitPos = self.IEDPlantPos,
		HitNormal = self.IEDPlantNormal
	} or nil)
	owner:EmitSound("snd_jack_hmcd_bombrig.wav", mode == "attached" and 50 or 60, 100, 1, CHAN_AUTO)
	self:SetNextPrimaryFire(CurTime() + 2)
	self.nextattackhuy = CurTime() + 2
	self:SetPlanted(true)
	self.IEDPlantPending = false
	self.IEDPlantMode = nil
	self.IEDPlantEntity = nil
end

function SWEP:SecondaryAttack(calledFrom)
	if SERVER then
		if not calledFrom then
			if not self:CanSecondaryAttack() then
				return
			end
		end
		if not self.Planted then
			self:BeginIEDPlant("free", self:GetEyeTrace())
		end
	end
end

function SWEP:InitAdd()
	self.Planted = false
	self.HaveTheBomb = false
	self.IEDPlantPending = false
	self:PlayAnim("idle")
end

function SWEP:Deploy()
	self:SetHold(self.HoldType)
	self:PlayAnim(self:GetPlanted() and "det_draw" or "idle")
	return true
end

if SERVER then
	function SWEP:OnRemove()
		RemoveAttachedBombVisual(self)
	end
end

if CLIENT then
	function SWEP:PrimaryAttack()
	end
end

if SERVER then
	util.AddNetworkString("ied_primary_attack")
	SWEP.nextattackhuy = 0
	SWEP.PlantedOnSelf = false

	function SWEP:PrimaryAttack()
		self:AttackHuy()
	end
	function SWEP:AttackHuy()
		if self.IEDPlantPending then return end
		if not (self.Planted or self.HaveTheBomb or self.PlantedOnSelf) then
			local Owner = self:GetOwner()
			local Tr = self:GetEyeTrace()

			if IsValid(Tr.Entity) and IsValid(Tr.Entity:GetPhysicsObject()) and Tr.Entity:GetPhysicsObject():GetMass() < 500 then
				local min, max = Tr.Entity:GetModelBounds()
				local minmaxs = (max - min)
				local size = minmaxs[1] + minmaxs[2] + minmaxs[3]
				if size <= 15 then return end
				self:BeginIEDPlant("attached", Tr)
				return
			elseif hg.GetCurrentCharacter(Owner):IsRagdoll() then
				self:SecondaryAttack(true)
				return
			end
		end

		if (self.nextattackhuy or 0) <= CurTime() and (self.Planted or self.HaveTheBomb or self.PlantedOnSelf) and not self.KABOOM and not self:GetDialing() then
			self:PlayAnim("det_detonate")
			self:EmitSound("weapons/ied/handling/ied_trigger_ins.wav", 65)
			if self.PlantedOnSelf then
				StartIEDDetonation(self, self:GetOwner())
			else
				StartIEDDetonation(self, self.HaveTheBomb)
			end
		end
	end


	function SWEP:Reload() -- hell nah
		--if not self.Planted and not self.PlantedOnSelf then
		--	local Owner = self:GetOwner()
--
		--	self.PlantedOnSelf = true
--
--
		--	self.WorldModel = "models/saraphines/insurgency explosives/ied/insurgency_ied_phone.mdl"
--
		--	net.Start("ied_have_the_bomb")
		--	net.WriteEntity(self)
		--	net.Broadcast()
--
		--	Owner:EmitSound("snd_jack_hmcd_bombrig.wav",50,100,1,CHAN_AUTO)
--
		--	self.Planted = true
--
--
		--	timer.Simple(5, function()
		--		if IsValid(self) and IsValid(Owner) and self.PlantedOnSelf then
		--			ExplodeTheItem(self, Owner)
		--		end
		--	end)
--
		--	self:SetNextPrimaryFire(CurTime() + 2)
		--end
	end
end
