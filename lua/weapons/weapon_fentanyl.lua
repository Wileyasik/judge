if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik_base"
SWEP.PrintName = "Fentanyl"
SWEP.Instructions = "Fentanyl is a highly potent synthetic piperidine opioid primarily used as an analgesic. Fentanyl dose must be strictly observed, as it can quickly lead to opiate overdose. Label says that ~20% is a maximum daily dose. Hold LMB to inject into yourself, hold RMB on someone else to inject them."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.WorldModel = "models/cof/weapons/syringe/w_syringe.mdl"
SWEP.WorldModelReal = "models/cof/weapons/syringe/v_syringe.mdl"
SWEP.WorldModelExchange = false

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/icons/ico_fent.png")
	SWEP.IconOverride = "vgui/icons/ico_fent.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.Slot = 5
SWEP.SlotPos = 1
SWEP.WorkWithFake = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.setlh = true
SWEP.setrh = true

SWEP.healingOther = false

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "HealingOther")
	self:NetworkVar("Float", 0, "Dose")
end

SWEP.HoldPos = Vector(2, -1.5, -2)
SWEP.HoldAng = Angle(0, 0, 0)

SWEP.offsetVec = Vector(0, 0, 0)
SWEP.offsetAng = Angle(0, 0, 0)

SWEP.lpos = Vector(0, 0, 0)
SWEP.lang = Angle(0, 0, 0)

SWEP.handPosOffset = Vector(0, 0, 0)
SWEP.handAngOffset = Angle(0, 0, 0)

SWEP.modeNames = {
	[1] = "analgesic"
}

SWEP.UseSpeed = 3
SWEP.CallbackTimeAdjust = 0.5
SWEP.AnalgesiaPerDose = 6
SWEP.MaxAnalgesia = 6

SWEP.AnimList = {
	["deploy"] = { "deploy", 0.5, false },
	["use"] = { "use", 3, true },
	["idle"] = { "idle", 5, true }
}

SWEP.TimedSoundsSelf = {
	{"weapons/universal/uni_crawl_l_02.wav", 0.3},
	{"snd_jack_hmcd_needleprick.wav", 0.8},
	{"cof/weapons/syringe/syringe_insert.wav", 1.0},
}

SWEP.TimedSoundsOther = {
	{"cof/weapons/syringe/syringe_insert.wav", 0.5},
}

SWEP.modeValuesdef = {
	[1] = {1, true},
}

SWEP.showstats = true
SWEP.FallSnd = ""

SWEP.HoldType = "slam"

sound.Add({
	name = "pshiksnd",
	channel = CHAN_AUTO,
	volume = 0.02,
	level = 65,
	pitch = {5555, 5555},
	sound = "snd_jack_sss.wav",
})

function SWEP:CanPrimaryAttack()
	return true
end

function SWEP:InitAdd()
	self:SetDose(1)
	self.modeValues = {
		[1] = 1
	}
end

function SWEP:Deploy()
	if self.DeploySounds and #self.DeploySounds > 0 then
		self.DeploySnd = self.DeploySounds[math.random(#self.DeploySounds)]
	end
	local snd = self.DeploySnd
	self.DeploySnd = ""
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.Deploy then
		local ret = base.Deploy(self)
		if SERVER and snd and snd ~= "" and not self._deploySndPlayed and self:GetOwner() and not self:GetOwner().noSound then
			self._deploySndPlayed = true
			self:GetOwner():EmitSound(snd, 65, math.random(95, 105))
		end
		return ret
	end
	return true
end

function SWEP:Holster()
	self._deploySndPlayed = false
	self:SetHealingOther(false)
	self.setlh = true
	self.healing = false
	self.callback = nil
	hook.Remove("Think", "AnimCallback" .. self:EntIndex())
	self._wasInUse = false
	self._injectStartTime = nil
	self._slowed = false
	self._animStarted = false
	return true
end

function SWEP:Think()
	if hg.SWEPEditor_Apply then hg.SWEPEditor_Apply(self) end

	local curTime = CurTime()
	local anim = self.anim

	local inUse = anim == "use" and self.animtime and self.animtime > curTime

	if not IsFirstTimePredicted() then return end

	if inUse ~= self._wasInUse then
		self._wasInUse = inUse
		if inUse then
			self._timedApplied = {}
			self._soundIdx = 1

			self.TimedSounds = self:GetHealingOther() and self.TimedSoundsOther or self.TimedSoundsSelf
			self._timedSndCache = nil

			if self.TimedSounds and #self.TimedSounds > 0 then
				local sorted = {}
				for i, data in ipairs(self.TimedSounds) do
					if data[1] ~= "" then
						sorted[#sorted + 1] = {data[1], data[2]}
					end
				end
				table.sort(sorted, function(a, b) return a[2] < b[2] end)
				self._timedSndCache = sorted
				self._timedSndCount = #sorted
			end
		else
			self._slowed = false
		end
	end

	if inUse and self.animtime and self.animspeed then
		local elapsed = self.animspeed - (self.animtime - curTime)

		if self._timedSndCache then
			local idx = self._soundIdx or 1
			local cache = self._timedSndCache
			local count = self._timedSndCount
			while idx <= count and elapsed >= cache[idx][2] do
				local data = cache[idx]
				idx = idx + 1
				if CLIENT then
					local owner = self:GetOwner()
					if IsValid(owner) then
						owner:EmitSound(data[1], 60, math.random(95, 105), 1, CHAN_STATIC)
					end
				end
			end
			self._soundIdx = idx
		end
	end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if not self.healing and anim == "deploy" and self.animtime and self.animtime <= curTime then
		if SERVER then
			self:PlayAnim("idle")
		end
	end

	if self.healing and not self._animStarted then
		local buttonHeld = owner:KeyDown(IN_ATTACK) or owner:KeyDown(IN_ATTACK2)
		if buttonHeld and self.modeValues[1] > 0 then
			self._animStarted = true
			self._injectStartTime = curTime
			self._slowed = false
			if SERVER then
				self:PlayAnim("use", self.UseSpeed, true, nil, false)
			end
		elseif not buttonHeld then
			self.healing = false
			self:SetHealingOther(false)
			self.setlh = true
		end
	end

	if self.healing and not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2) then
		self.healing = false
		self:SetHealingOther(false)
		self.setlh = true
		self._injectStartTime = nil
		self._slowed = false
		self._animStarted = false
		self.callback = nil
		hook.Remove("Think", "AnimCallback" .. self:EntIndex())
		if SERVER then
			if self.modeValues[1] > 0 then
				self:ReverseAnimToIdle("use")
			else
				self:PlayAnim("idle")
			end
		end
	end

	if self.healing and self._injectStartTime then
		local timeSinceStart = curTime - self._injectStartTime

		if timeSinceStart >= 1 then
			if not self._slowed then
				self._slowed = true
				if SERVER then
					self.animspeed = self.animspeed * 2
					self.animtime = curTime + (self.animtime - curTime) * 2
				end
			end

			local ent = self:GetHealingOther() and IsValid(self.healbuddy) and self.healbuddy or owner
			local org = ent.organism
			if org and self.modeValues[1] > 0 then
				local injected = math.min(FrameTime() * 1, self.modeValues[1])
				org.analgesiaAdd = math.min(org.analgesiaAdd + injected * self.AnalgesiaPerDose, self.MaxAnalgesia)
				self.modeValues[1] = math.max(self.modeValues[1] - injected, 0)
				self:SetDose(self.modeValues[1])

				owner.injectedinto = owner.injectedinto or {}
				owner.injectedinto[org.owner] = owner.injectedinto[org.owner] or 0
				owner.injectedinto[org.owner] = owner.injectedinto[org.owner] + injected

				if owner.injectedinto[org.owner] > 1 and injected > 0 then
					local dmgInfo = DamageInfo()
					dmgInfo:SetAttacker(owner)
					hook.Run("HomigradDamage", org.owner, dmgInfo, HITGROUP_RIGHTARM, hg.GetCurrentCharacter(org.owner), injected * (zb and zb.MaximumHarm or 1))
				end

				if SERVER then
					local entOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
					entOwner:EmitSound("pshiksnd")
				end

				if self.modeValues[1] <= 0 then
					self.healing = false
					self:SetHealingOther(false)
					self.setlh = true
					self._injectStartTime = nil
					self._slowed = false
					self._animStarted = false
					self.callback = nil
					hook.Remove("Think", "AnimCallback" .. self:EntIndex())
					if SERVER then
						owner:DropWeapon(self)
						owner:SelectWeapon("weapon_hg_coolhands")
					end
					return
				end
			end
		end
	end

	self:ThinkReverseAnimToIdle(curTime)
end

function SWEP:SetHandPos(noset)
	if self:GetHealingOther() then
		self.setlh = false
	else
		self.setlh = true
	end

	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.SetHandPos then return base.SetHandPos(self, noset) end
end

function SWEP:PostSetHandPos()
	local ply = self:GetOwner()
	if not IsValid(ply) then return end

	local ent = hg.GetCurrentCharacter(ply)
	if not IsValid(ent) then return end

	local rhBone = ent:LookupBone("ValveBiped.Bip01_R_Hand")
	if rhBone then
		local mat = ent:GetBoneMatrix(rhBone)
		if mat then
			local pos = mat:GetTranslation() + self.handPosOffset
			local ang = mat:GetAngles()
			ang.p = ang.p + self.handAngOffset.p
			ang.y = ang.y + self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(rhBone, mat)
		end
	end

	if not self.lhandik then return end

	local lhBone = ent:LookupBone("ValveBiped.Bip01_L_Hand")
	if lhBone then
		local mat = ent:GetBoneMatrix(lhBone)
		if mat then
			local pos = mat:GetTranslation()
			local offset = self.handPosOffset
			pos.x = pos.x - offset.x
			pos.y = pos.y - offset.y
			pos.z = pos.z + offset.z
			local ang = mat:GetAngles()
			ang.p = ang.p - self.handAngOffset.p
			ang.y = ang.y - self.handAngOffset.y
			ang.r = ang.r + self.handAngOffset.r
			mat:SetTranslation(pos)
			mat:SetAngles(ang)
			ent:SetBoneMatrix(lhBone, mat)
		end
	end
end

if CLIENT then
	local colWhite = Color(255, 255, 255, 255)
	local colGray = Color(200, 200, 200, 200)
	local lerpthing = 1
	local colBrown = Color(40,40,40)
	SWEP.showstats = true
	local vector_one = Vector(1,1,1)
	function SWEP:DrawHUD()
		local owner = self:GetOwner()
		if !owner:IsPlayer() then return end
		if GetViewEntity() ~= owner then return end
		if owner:InVehicle() then return end
		local Tr = hg.eyeTrace(owner)
		if !Tr then return end
		local Size = math.max(math.min(1 - Tr.Fraction, 0.5), 0.1)
		local x, y = Tr.HitPos:ToScreen().x, Tr.HitPos:ToScreen().y
		if Tr.Hit then
			lerpthing = Lerp(0.1, lerpthing, 1)
			colWhite.a = 255 * Size
			surface.SetDrawColor(colGray)
			draw.NoTexture()
			surface.SetDrawColor(colWhite)
			draw.NoTexture()
			surface.DrawRect(x - 25 * lerpthing, y - 2.5, 50 * lerpthing, 5)
			surface.DrawRect(x - 2.5, y - 25 * lerpthing, 5, 50 * lerpthing)
			local col = Tr.Entity:GetPlayerColor():ToColor()
			local coloutline = (col.r < 50 and col.g < 50 and col.b < 50) and Color(255,255,255) or Color(0,0,0)
			coloutline.a = 255 * Size * 2
			draw.DrawText(Tr.Entity:IsPlayer() and Tr.Entity:GetPlayerName() or Tr.Entity:IsRagdoll() and Tr.Entity:GetPlayerName() or "", "HomigradFontLarge", x + 1, y + 31, coloutline, TEXT_ALIGN_CENTER)
			draw.DrawText(Tr.Entity:IsPlayer() and Tr.Entity:GetPlayerName() or Tr.Entity:IsRagdoll() and Tr.Entity:GetPlayerName() or "", "HomigradFontLarge", x, y + 30, col, TEXT_ALIGN_CENTER)
		end
		self:DrawWorldModel2(true)
		if self.showstats and self.modeValues and istable(self.modeValues) then
			render.PushFilterMag( TEXFILTER.LINEAR )
			render.PushFilterMin( TEXFILTER.LINEAR )
			local m = Matrix()
			m:Translate( Vector(  ScrW() / 2-ScreenScale(60), ScrH() / 2 + ScreenScaleH(125), 0 ) )
			m:Scale( vector_one * 0.5 )

			cam.PushModelMatrix( m, true )
				local dose = self:GetDose() or 0
				local maxDose = self.modeValuesdef and self.modeValuesdef[1] and self.modeValuesdef[1][1] or 1
				local val = math.Round(dose / maxDose * 100)
				local x,y = 0, ScrH() / 20
				local reveal = 1
				colBrown.a = reveal * 185
				draw.RoundedBox(2,x,y,x + ScreenScale(210) + ScrW() / 10,ScrH() / 25,colBrown)
				surface.SetFont("ZCity_Small")
				surface.SetTextPos(x,y)
				surface.SetTextColor(255,255,255,255 * reveal)
				local txt = string.NiceName(tostring(self.modeNames[1]))
				local w, h = surface.GetTextSize(txt)
				colBrown.a = reveal * 255
				draw.SimpleTextOutlined(txt, "ZCity_Small", x, y, Color(255,50,50, 255 * reveal), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5, colBrown)

				surface.SetDrawColor(0,100,0,255 * reveal)
				surface.DrawRect(x + ScreenScale(210),y,ScrW() / 10 * val / 100,ScrH() / 25)
				surface.SetDrawColor(0,0,0,255 * reveal)
				surface.DrawOutlinedRect(x + ScreenScale(210),y,ScrW() / 10,ScrH() / 25, 4)
			cam.PopModelMatrix()

			render.PopFilterMag()
			render.PopFilterMin()
		end
	end
end

if SERVER then
	function SWEP:PrimaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if self.modeValues[1] <= 0 then return end
		if self.healing then return end

		self:SetHealingOther(false)
		self.setlh = true
		self.healing = true
	end

	function SWEP:SecondaryAttack()
		local owner = self:GetOwner()
		if not IsValid(owner) then return end
		if self.modeValues[1] <= 0 then return end
		if self.healing then return end

		local tr = hg.eyeTrace(owner)
		if not tr then return end

		local ent = tr.Entity
		if not IsValid(ent) then return end

		local chr = hg.GetCurrentCharacter(ent)
		if chr == hg.GetCurrentCharacter(owner) then return end
		if not (ent:IsPlayer() or ent:IsNPC() or hg.RagdollOwner(ent)) then return end

		self.healbuddy = ent
		self:SetHealingOther(true)
		self.setlh = false
		self.healing = true
	end
end
