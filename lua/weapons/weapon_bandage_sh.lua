if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Bandage"
SWEP.Instructions = "A wad of gauze bandage, can help stop light bleeding. Since the bandage is not in its packaging, there is little chance that it is sterilized. RMB to use on someone else."
SWEP.Category = "ZCity Medicine"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "slam"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/bandages.mdl"
if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_bandage")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_bandage.png"
	SWEP.BounceWeaponIcon = false
end

SWEP.ScrappersSlot = "Medicine"

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 3
SWEP.SlotPos = 1

SWEP.WorkWithFake = true
SWEP.BandageTPIK = true
SWEP.BandageUseTime = 3.2
SWEP.BandageMinUseTime = 1.2
SWEP.BandageSequenceTime = 139 / 30
SWEP.BandageAnimStart = 0.5
SWEP.BandageAnimEndTrim = 0.7
SWEP.AnimBlendTime = 0.3
SWEP.AnimBlendHands = false
SWEP.AnimBlendMeshes = false
SWEP.BandageTransitionCycleWidth = 0.075
SWEP.BandageTransitionDown = 18
SWEP.BandageTransitionIn = 8
SWEP.BandageTPIKWorldModel = "models/weapons/nmrih/items/bandage/w_bandages.mdl"
SWEP.BandageTPIKViewModel = "models/weapons/nmrih/items/bandage/v_item_bandages.mdl"
SWEP.BandageTPIKAnimList = {
	["deploy"] = {"draw", 1, false},
	["use"] = {"bandage", 3.2, false},
	["idle"] = {"idle", 10, true},
}
SWEP.BandageTPIKHiddenBonesIdle = {}
for boneIndex = 53, 82 do
	SWEP.BandageTPIKHiddenBonesIdle[#SWEP.BandageTPIKHiddenBonesIdle + 1] = boneIndex
end
SWEP.BandageTPIKHiddenBonesUse = {83}
SWEP.HideMeshOnlyScale = {}
for _, bone in ipairs(SWEP.BandageTPIKHiddenBonesIdle) do
	SWEP.HideMeshOnlyScale[bone] = true
end
SWEP.offsetVec = Vector(4, -3.5, 0)
SWEP.offsetAng = Angle(90, 90, 0)

local hg_healanims = CreateConVar("hg_healanims", 0, FCVAR_REPLICATED + FCVAR_ARCHIVE, "Toggle heal/food animations", 0, 1)

modelshuy = modelshuy or {}

function SWEP:DrawWorldModel()
	if self.BandageTPIK then
		local base = weapons.GetStored("weapon_tpik_base")
		if base and base.DrawWorldModel then return base.DrawWorldModel(self) end
	end

	if not IsValid(self:GetOwner()) then
		self:DrawWorldModel2()
	end
end

function SWEP:DrawWorldModel2(nodraw)
	if self.BandageTPIK then
		local base = weapons.GetStored("weapon_tpik_base")
		if base and base.DrawWorldModel2 then return base.DrawWorldModel2(self) end
	end

	if self.Color then
		render.SetColorModulation(self.Color.r/255,self.Color.g/255,self.Color.b/255)
	end

	local mdl = self.Model or self.WorldModel
	modelshuy[mdl] = IsValid(modelshuy[mdl]) and modelshuy[mdl] or ClientsideModel(mdl)
	modelshuy[mdl]:SetNoDraw(true)
	local WorldModel = modelshuy[mdl]
	local owner = self:GetOwner()
	owner = hg.GetCurrentCharacter(owner)
	if not IsValid(WorldModel) then return end

	for i = 1, #self:GetBodyGroups() do
		WorldModel:SetBodygroup(i, self:GetBodygroup(i))
	end

	if self.ModelScale then
		WorldModel:SetModelScale(self.ModelScale or 1)
	end
	if self.Color then
		WorldModel:SetColor(self.Color or color_white)
	end
	
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not ( owner.organism and owner.organism.larmamputated ))) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:SetupBones()

	if self.AfterDrawModel then
		self:AfterDrawModel(WorldModel,nodraw)
	end
	
	if not nodraw then WorldModel:DrawModel() end

	if self.Color then
		render.SetColorModulation(1,1,1)
	end
end

function SWEP:OnRemove()
	if self.BandageTPIK then
		self:CancelBandageTPIK(false)
		local base = weapons.GetStored("weapon_tpik_base")
		if base and base.OnRemove then return base.OnRemove(self) end
	end

	if SERVER then return end
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:SetupDataTables()
    self:NetworkVar("Float",0,"Holding")
	if self.SetupDataTablesAdd then
		self:SetupDataTablesAdd()
	end
end

local bone, name
function SWEP:BoneSet(lookup_name, vec, ang)
	local owner = self:GetOwner()
	if not IsValid(owner) or not owner:IsPlayer() then return end
	hg.bone.Set(owner, lookup_name, vec, ang, "bandage", 0.01)
end

local lang1, lang2 = Angle(0, -10, 0), Angle(0, 10, 0)
function SWEP:Animation()
	local owner = self:GetOwner()
	local aimvec = self:GetOwner():GetAimVector()
	local hold = self:GetHolding()
	if (owner.zmanipstart ~= nil and not ( owner.organism and owner.organism.larmamputated )) then return end
	self:BoneSet("r_upperarm", vector_origin, Angle(30 - hold / 4, -30 + hold / 2 + 20 * aimvec[3], 5 - hold / 3.5))
    self:BoneSet("r_forearm", vector_origin, Angle(hold / 10, -hold / 2.5, 35 -hold/1.5))
end

SWEP.usetime = 2
local math = math
function SWEP:Think()
	if self.BandageTPIK then return self:BandageTPIKThink() end

	self:SetHold(self.HoldType)

	if self:GetClass() == "weapon_bandage_sh" then
		self.ModelScale = math.Clamp(self.modeValues[1] / (self.modeValuesdef[1][1] * 0.8), 0.5, 1)
	end

	if not self:GetOwner():KeyDown(IN_ATTACK) and hg_healanims:GetBool() then
		self:SetHolding(math.max(self:GetHolding() - 12, 0))
	end

	--[[if self.modeValuesdef[self.mode][2] then
		local time = CurTime()
		local ply = self:GetOwner()
		local entownr = hg.GetCurrentCharacter(ply)

		if not self.attack and ply:KeyPressed(IN_ATTACK) then
			self.startedheal = CurTime()
			self.healsubject = ply
			self.attack = 1
		end

		if self.attack == 1 and ply:KeyReleased(IN_ATTACK) then
			self.endheal = CurTime()
		end

		if not self.attack and ply:KeyPressed(IN_ATTACK2) then
			self.startedheal = CurTime()
			self.healsubject = hg.eyeTrace(self:GetOwner()).Entity
			self.attack = 2
		end

		if self.attack == 2 and ply:KeyReleased(IN_ATTACK2) then
			self.endheal = CurTime()
		end

		if self.startheal and (self.endheal or (self.startheal + self.usetime <= CurTime())) then
			self.endheal = self.endheal or self.startheal + self.usetime
			local usedmuch = (self.endheal - self.startheal) / self.usetime

			self:Heal(self.healsubject, self.mode, usedmuch)
			self.startheal = nil 
			self.endheal = nil 
			self.attack = nil 
			self.healsubject = nil
		end
	end--]]
end
SWEP.net_cooldown2 = 0
function SWEP:PrimaryAttack()
	if self.BandageTPIK then return self:StartBandageTPIK(self:GetOwner(), IN_ATTACK) end

	if SERVER then--and not self.modeValuesdef[self.mode][2] then

		self.healbuddy = self:GetOwner()
		local done = self:Heal(self.healbuddy, self.mode)
		
		if(done and self.PostHeal)then
			self:PostHeal(self.healbuddy, self.mode)
		end

		if self.net_cooldown2 < CurTime() then
			self:SetNetVar("modeValues",self.modeValues)
			--self.net_cooldown2 = CurTime() + 0.1
		end
	end
end

if CLIENT then
	local colWhite = Color(255, 255, 255, 255)
	local colGray = Color(200, 200, 200, 200)
	local lerpthing = 1
	local colBrown = Color(40,40,40)
	SWEP.showstats = true
	SWEP.ofsV = Vector(10,-2,1)
	SWEP.ofsA = Angle(-90,-40,270)
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
		if self.showstats and self.modeValues and istable(self.modeValues) then
			//cam.Start3D()
				//cam.Start3D2D(pos,ang,0.01)
				render.PushFilterMag( TEXFILTER.LINEAR )
				render.PushFilterMin( TEXFILTER.LINEAR )
				local m = Matrix()
				m:Translate( Vector(  ScrW() / 2-ScreenScale(60), ScrH() / 2 + ScreenScaleH(125), 0 ) )
				m:Scale( vector_one * 0.5 )

				cam.PushModelMatrix( m, true )
					for i, val in ipairs(self.modeValues) do
						if not isnumber(i) or not val or not self.modeValuesdef or not self.modeValuesdef[i][1] then continue end
						local val = math.Round(val / self.modeValuesdef[i][1] * 100)
						local x,y = 0, i * ScrH() / 20
						local reveal = 1//math.Clamp(lply:EyeAngles()[1] / 90 - 0.25, 0, 1) * 4 / 3
						colBrown.a = reveal * 185
						draw.RoundedBox(2,x,y,x + ScreenScale(210) + ScrW() / 10,ScrH() / 25 + (#self.modeValues > 0 and 0 or 0),colBrown)
						surface.SetFont("ZCity_Small")
						surface.SetTextPos(x,y)
						surface.SetTextColor(255,255,255,255 * reveal)
						local txt = string.NiceName(tostring(self.modeNames[i]))
						local w, h = surface.GetTextSize(txt)
						--surface.DrawText(tostring(self.modeNames[i]))
						colBrown.a = reveal * 255
						draw.SimpleTextOutlined(txt, "ZCity_Small", x, y, Color(255,i == self.mode and 0 or 255,i == self.mode and 0 or 255, 255 * reveal), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1.5, colBrown)
					
						surface.SetDrawColor(0,100,0,255 * reveal)
						surface.DrawRect(x + ScreenScale(210),y,ScrW() / 10 * val / 100,ScrH() / 25)
						surface.SetDrawColor(0,0,0,255 * reveal)
						surface.DrawOutlinedRect(x + ScreenScale(210),y,ScrW() / 10,ScrH() / 25, 4)
					end
				cam.PopModelMatrix()

				render.PopFilterMag()
				render.PopFilterMin()
				//cam.End3D2D()
			//cam.End3D()
		end
	end
end

SWEP.mode = 1
SWEP.modes = 1
SWEP.modeNames = {
	[1] = "bandaging"
}

function SWEP:InitializeAdd()
	self.ModelScale = 0.9
end

SWEP.DeploySnd = "physics/body/body_medium_impact_soft5.wav"
SWEP.HolsterSnd = ""
SWEP.FallSnd = "physics/body/body_medium_impact_soft5.wav"

if CLIENT then
	SWEP.HowToUseInstructions = "<font=ZCity_Tiny>"..string.upper( (input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD") ).." to pickup</font>"
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)

	self.modeValues = {
		[1] = 40,
	}

	if CLIENT then
		self.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. self.PrintName .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. self.HowToUseInstructions .."</colour></font>", 450)
	end

	util.PrecacheSound(self.DeploySnd)
	util.PrecacheSound(self.HolsterSnd)
	util.PrecacheSound(self.FallSnd)
	util.PrecacheSound("snd_jack_hmcd_needleprick.wav")
	
	self:AddCallback("PhysicsCollide",function(ent,data)
		if data.Speed > 200 then
			ent:EmitSound(self.FallSnd or self.DeploySnd,65,math.random(90,110))
		end
	end)

	self:InitializeAdd()
end

SWEP.modeValuesdef = {
	[1] = {40,true},
}

function SWEP:GetInfo()
	if not IsValid(self) then
		local modevalues = {}
		for i,val in ipairs(self.modeValuesdef) do
			modevalues[i] = istable(val) and val[1] or val
		end
		return modevalues
	end
	return self.modeValues
end

function SWEP:SetInfo(info)
	self:SetNetVar("modeValues",info)
	self.modeValues = info
end

function SWEP:SecondaryAttack()
	if self.BandageTPIK then
		if IsValid(self:GetNWEntity("fakeGun")) then return end
		local ent = hg.eyeTrace(self:GetOwner()).Entity
		if not IsValid(ent) then return end
		if hg.GetCurrentCharacter(ent) == hg.GetCurrentCharacter(self:GetOwner()) then return end
		return self:StartBandageTPIK(ent, IN_ATTACK2)
	end

	--self:SetHolding(math.min(self:GetHolding() + 9, 100))
	if SERVER then
		if IsValid(self:GetNWEntity("fakeGun")) then return end
		local ent = hg.eyeTrace(self:GetOwner()).Entity
		self.healbuddy = ent
		if !IsValid(self.healbuddy) then return end
		if hg.GetCurrentCharacter(self.healbuddy) == hg.GetCurrentCharacter(self:GetOwner()) then return end
		local done = self:Heal(self.healbuddy, self.mode)
		if(done and self.PostHeal)then
			self:PostHeal(self.healbuddy, self.mode)
		end		

		if self.net_cooldown2 < CurTime() then
			self:SetNetVar("modeValues",self.modeValues)
			--self.net_cooldown2 = CurTime() + 0.1 * game.GetTimeScale()
		end
	end
end

if SERVER then
	util.AddNetworkString("select_mode")
else
	net.Receive("select_mode",function()
		net.ReadEntity().mode = net.ReadInt(4)
	end)
end

function SWEP:Reload()
	if SERVER and self:GetOwner():KeyPressed(IN_RELOAD) and #self.modeValuesdef > 1 then
		self.mode = ((self.mode + 1) > self.modes) and 1 or (self.mode + 1)
		--self:GetOwner():ChatPrint("You have chosen the " .. self.modeNames[self.mode] .. " mode")
		net.Start("select_mode")
		net.WriteEntity(self)
		net.WriteInt(self.mode,4)
		net.Broadcast()
	end
end
if CLIENT then
	hook.Add("OnNetVarSet","bandage-net-var",function(index,key,var)
		if key == "modeValues" then
			local ent = Entity(index)

			ent.modeValues = var
		end
	end)
end

local function PhysCallback(ent, data)
	if data.DeltaTime < 0.2 then return end
	ent:EmitSound(Sound(ent.FallSnd))
end

local ents_Create, gamemod, clr_garbage = ents.Create, engine.ActiveGamemode(), Color(200, 200, 200)
local gibRemoveTime = 60
function SWEP:SpawnGarbage(mdl_custom, skin_custom, snd_custom, clr_custom, bgs_custom)
	if CLIENT then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local boneid
	if IsValid(owner) then
		if owner:IsPlayer() then
			local chr = hg.GetCurrentCharacter(owner)
			boneid = chr:LookupBone(((owner.organism and owner.organism.rarmamputated) or (owner.zmanipstart ~= nil and owner.zmanipseq == "interact" and not ( owner.organism and owner.organism.larmamputated ))) and "ValveBiped.Bip01_L_Hand" or "ValveBiped.Bip01_R_Hand")
		else
			boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand") or 1
		end
	end

	if not boneid then return end
	local matrix = owner:GetBoneMatrix(boneid)
	if not matrix then return end

	local ent = ents_Create("prop_physics")
	ent:SetModel(Model((mdl_custom and mdl_custom ~= "" and mdl_custom ~= nil and isstring(mdl_custom)) and mdl_custom or self.WorldModel))

	if skin_custom and skin_custom ~= nil and isnumber(skin_custom) then
		ent:SetSkin(skin_custom or 0)
	end

	ent:SetPos(matrix:GetTranslation())
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	ent:SetAngles(AngleRand(-180, 180))
	ent:Activate()
	ent:Spawn()
	ent:SetOwner(owner)
	ent.FallSnd = Sound((snd_custom and snd_custom ~= nil) and snd_custom or self.FallSnd)

	if clr_custom and clr_custom ~= nil and IsColor(clr_custom) then
		ent:SetColor(clr_custom)
	else
		ent:SetColor(clr_garbage)
	end

	if bgs_custom and bgs_custom ~= nil and isstring(bgs_custom) then
		ent:SetBodyGroups(bgs_custom)
	end

	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
		phys:SetVelocity(self:GetVelocity() + (owner:GetAimVector() * 200) + VectorRand(-50, 50))
		phys:AddAngleVelocity(VectorRand(-100, 100))
	end

	ent:AddCallback("PhysicsCollide", PhysCallback)

	if zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" then
		ent:DrawShadow(false)
		ent:SetModelScale(0.5, gibRemoveTime)
		SafeRemoveEntityDelayed(ent, gibRemoveTime)
	end
end

-- WoundTBL = {dmgBlood / 2, localPos, localAng, bone, time}
SWEP.ShouldDeleteOnFullUse = true
if SERVER then
	function SWEP:Bandage(ent, bone)
		local org = ent.organism
		local owner = self:GetOwner()
		if not org then return end
		
		-- Если растрелять труп а потом его взорвать гранатой, после перевязать - крашнет сервер why?
		if self.modeValues[1] <= 0 or not (#org.wounds > 0 or org.lleg == 1 or org.rleg == 1 or org.skull >= 0.6 or org.chest == 1 or org.rarm == 1 or org.larm == 1) then return end
		table.sort(org.wounds, function(a, b) return a[1] > b[1] end)
		
		local done = false
		local bandaged = false
		
		if not bone then
			--print(#org.wounds)
			for i = 1, #org.wounds do
				if self.modeValues[1] > 0 and #org.wounds > 0 then
					local biggestWound = org.wounds[1][1]
					local healedWound = math.max(biggestWound - self.modeValues[1], 0)
					local woundHeal = self.modeValues[1] - (biggestWound - healedWound)-- * ((owner.Profession == "doctor") and 0.33 or 1)
					org.bleed = math.max(org.bleed - (biggestWound - healedWound), 0)
					org.wounds[1][1] = healedWound
					self.modeValues[1] = woundHeal > 0.1 and woundHeal or 0
					
					if (biggestWound - healedWound) > 0.1 then
						bandaged = true
					end

					local owner = self:GetOwner()
					if owner.Karma then
						--owner.Karma = math.Clamp(owner.Karma + 0.25,0,zb.MaxKarma)
					end
					ent.bandaged_limbs = ent.bandaged_limbs or {}
					local bone_name = org.wounds[1][4]
					if not ent.bandaged_limbs[bone_name] then
						ent.bandaged_limbs[bone_name] = true
						done = true
					end
					if org.wounds[1][1] == 0 then table.remove(org.wounds, 1) end
				end
			end
		else
			local bonewounds = {}
			
			for i, tbl in pairs(org.wounds) do
				if ent:GetBoneName(ent:LookupBone(tbl[4])) == bone then
					table.insert(bonewounds,i)
				end
			end
			
			for i = 1, #bonewounds do
				if self.modeValues[1] ~= 0 and #bonewounds > 0 then
					if org.wounds[bonewounds[1]] then
						local biggestWound = org.wounds[bonewounds[1]][1]
						local healedWound = math.max(biggestWound - self.modeValues[1], 0)
						local woundHeal = self.modeValues[1] - (biggestWound - healedWound)
						org.bleed = math.max(org.bleed - (biggestWound - healedWound), 0)
						org.wounds[bonewounds[1]][1] = healedWound
						self.modeValues[1] = woundHeal

						org.pain = math.max(org.pain - (biggestWound - healedWound) / 4, 0)

						if (biggestWound - healedWound) > 0.1 then
							bandaged = true
						end

						ent.bandaged_limbs = ent.bandaged_limbs or {}
						local bone_name = ent:GetBoneName(ent:LookupBone(org.wounds[bonewounds[1]][4]))
						
						if not ent.bandaged_limbs[bone_name] then
							ent.bandaged_limbs[bone_name] = true
							done = true
						end

						if org.wounds[bonewounds[1]][1] == 0 then table.remove(org.wounds, bonewounds[1]) end
					end
					table.remove(bonewounds, 1)
				end
			end
		end
		org.owner:SetNetVar("wounds",org.wounds)
		timer.Create("bandage_limbs"..ent:EntIndex(),0.1,1,function()
			ent:SetNetVar("bandaged_limbs",ent.bandaged_limbs)
			if ent:IsRagdoll() and hg.RagdollOwner(ent) and hg.RagdollOwner(ent):Alive() then
				hg.RagdollOwner(ent):SetNetVar("bandaged_limbs",ent.bandaged_limbs)
			end
		end)

		local who = (self:GetOwner() == org.owner) and "You" or ((owner.Profession == "doctor") and "A doctor" or "Someone")
		local mul = ((owner.Profession == "doctor") and 0.2 or 1)
		local amt = 25 * mul
		if org.skull >= 0.6 and self.modeValues[1] >= amt then
			org.skull = 0.59
			self.modeValues[1] = self.modeValues[1] - amt
			org.bandagedskull = true
			org.pain = math.max(org.pain - 7, 0)
			ent.bandaged_limbs = ent.bandaged_limbs or {}
			ent.bandaged_limbs["ValveBiped.Bip01_Head1"] = true
			done = true
		end

		if org.chest == 1 and self.modeValues[1] >= amt then
			org.chest = org.chest - 0.05
			self.modeValues[1] = self.modeValues[1] - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if org.lleg == 1 and self.modeValues[1] >= amt and !org.llegamputated then
			org.lleg = org.lleg - 0.05
			self.modeValues[1] = self.modeValues[1] - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if org.rleg == 1 and self.modeValues[1] >= amt and !org.rlegamputated then
			org.rleg = org.rleg - 0.05
			self.modeValues[1] = self.modeValues[1] - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if org.rarm == 1 and self.modeValues[1] >= amt and !org.rarmamputated then
			org.rarm = org.rarm - 0.05
			self.modeValues[1] = self.modeValues[1] - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if org.larm == 1 and self.modeValues[1] >= amt and !org.larmamputated then
			org.larm = org.larm - 0.05
			self.modeValues[1] = self.modeValues[1] - amt
			org.avgpain = math.max(org.avgpain - 7, 0)
			done = true
		end

		if done then
			if not self.BandageTPIK then
			owner:EmitSound("snd_jack_hmcd_bandage.wav", 60, math.random(95, 105))
			end

			if self.poisoned2 then
				org.poison4 = CurTime()

				self.poisoned2 = nil
			end
		end

		return done
	end

	function SWEP:Heal(ent, mode, bone)
		if ent:IsNPC() then
			self:NPCHeal(ent, 0.15, "snd_jack_hmcd_bandage.wav")
		end

		local org = ent.organism
		if not org then return end
	
		local owner = self:GetOwner()
		if ent == hg.GetCurrentCharacter(owner) and hg_healanims:GetBool() then
			self:SetHolding(math.min(self:GetHolding() + 10, 100))

			if self:GetHolding() < 100 then return end
		end

		local done = self:Bandage(ent, bone)
		if self.modeValues[1] <= 0 and self.ShouldDeleteOnFullUse then
			owner:SelectWeapon("weapon_hands_sh")
			self:Remove()
		end
		
		return done
	end
	
	function SWEP:PostHeal(ent, mode)
		local org = ent.organism
		
		if(org and IsValid(org.owner))then
			local organism_owner = org.owner
			
			if(organism_owner.SubRole == "traitor_chemist")then
				if(self.FoodModelsKCNNeutralizers and self.FoodModelsKCNNeutralizers[self:GetModel()])then
					self.ConsumePoisoned_KCN = math.max(self.ConsumePoisoned_KCN or 0 - self.FoodModelsKCNNeutralizers[self:GetModel()], 0)
				end
				
				if((self.ConsumePoisoned_KCN or 0) > 0)then
					local ply_kcn_accumulated = AddChemicalToPlayer(organism_owner, "KCN", 50 * (self.ConsumePoisoned_KCN or 0))
					
					if(ply_kcn_accumulated > 100)then
						self:PoisonKCNOrganism(org)
					end
					
					NetworkChemicalResistanceOfPlayer(organism_owner)
					
					organism_owner.PassiveAbility_ChemicalAccumulation_NextNetworkTime = CurTime() + 1
				end
			else
				if(self.FoodModelsKCNNeutralizers and self.FoodModelsKCNNeutralizers[self:GetModel()])then
					self.ConsumePoisoned_KCN = math.max(self.ConsumePoisoned_KCN or 0 - self.FoodModelsKCNNeutralizers[self:GetModel()], 0)
				end
				
				if((self.ConsumePoisoned_KCN or 0) > 0)then
					self:PoisonKCNOrganism(org)
				end
			end
		end
	end
	
	function SWEP:PoisonKCNOrganism(org)
		if(org and self.ConsumePoisoned_KCN)then
			org.Poison_KCN = org.Poison_KCN or {}
			org.Poison_KCN.StartTime = org.Poison_KCN.StartTime or CurTime()
			org.Poison_KCN.Potency = (org.Poison_KCN.Potency or 0) + self.ConsumePoisoned_KCN
			self.ConsumePoisoned_KCN = nil
		end
	end

	function SWEP:SetFakeGun(ent)
		self:SetNWEntity("fakeGun", ent)
		self.fakeGun = ent
	end

	function SWEP:RemoveFake()
		if not IsValid(self.fakeGun) then return end
		self.fakeGun:Remove()
		self:SetFakeGun()
	end

	local function GetPhysBoneNum(ent,string)
		if not IsValid(ent) then return 7 end
		return ent:TranslateBoneToPhysBone(ent:LookupBone(string))
	end
	
	function SWEP:CreateFake(ragdoll)
		if IsValid(self:GetNWEntity("fakeGun")) then return end
		local ent = ents.Create("prop_physics")
		local physbonelh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_L_Hand")
		local physbonerh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_R_Hand")
		local lh = ragdoll:GetPhysicsObjectNum(physbonelh)
		local rh = ragdoll:GetPhysicsObjectNum(physbonerh)
		--rh:SetPos(rh:GetPos() + self:GetOwner():EyeAngles():Forward() * 20)
		--rh:SetAngles(self:GetOwner():EyeAngles() + Angle(0, 0, -90))
		--lh:SetPos(rh:GetPos())
		ent:SetModel(self.WorldModel)
		ent:SetPos(rh:GetPos())
		ent:SetAngles(rh:GetAngles() + Angle(0, 0, 180))
		ent:Spawn()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent:SetOwner(ragdoll)
		ent:GetPhysicsObject():SetMass(0)
		ent:SetModel(self.Model or self.WorldModel)
		ent:SetNoDraw(true)
		ent.dontPickup = true
		ent.fakeOwner = self
		ragdoll:DeleteOnRemove(ent)
		ragdoll.fakeGun = ent
		if IsValid(ragdoll.ConsRH) then ragdoll.ConsRH:Remove() end
		self:SetFakeGun(ent)
		ent:CallOnRemove("homigrad-swep", self.RemoveFake, self)
		local vec = Vector(0, 0, 0)
		vec:Set(self.RHandPos or vector_origin)
		vec:Rotate(ent:GetAngles())
		--rh:SetPos(ent:GetPos() + vec)
		constraint.Weld( ragdoll, ent, physbonerh, 0, 0, false, false )
	end

	function SWEP:RagdollFunc(pos, angles, ragdoll)
		local physbonelh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_L_Hand")
		local physbonerh = GetPhysBoneNum(ragdoll,"ValveBiped.Bip01_R_Hand")
		shadowControl = shadowControl or hg.ShadowControl
		local fakeGun = ragdoll.fakeGun
		pos:Add(angles:Forward() * 20)
		--shadowControl(fakeGun, 0, 0.001, angles, 100, 90, pos, 1000, 900)
		angles:RotateAroundAxis(angles:Forward(), 180)
		shadowControl(ragdoll, 7, 0.001, angles, 500, 30, pos, 500, 50)
	end
end


hg.TourniquetGuys = hg.TourniquetGuys or {}

if SERVER then
	util.AddNetworkString("send_tourniquets")
	local tourniqet_bones = {
		["ValveBiped.Bip01_L_UpperArm"] = {
			["ValveBiped.Bip01_L_Forearm"] = true,
			["ValveBiped.Bip01_L_Hand"] = true
		},
		["ValveBiped.Bip01_L_Forearm"] = {
			["ValveBiped.Bip01_L_Hand"] = true
		},

		["ValveBiped.Bip01_R_UpperArm"] = {
			["ValveBiped.Bip01_R_Forearm"] = true,
			["ValveBiped.Bip01_R_Hand"] = true
		},
		["ValveBiped.Bip01_R_Forearm"] = {
			["ValveBiped.Bip01_R_Hand"] = true
		},

		["ValveBiped.Bip01_L_Thigh"] = {
			["ValveBiped.Bip01_L_Calf"] = true,
			["ValveBiped.Bip01_L_Foot"] = true
		},
		["ValveBiped.Bip01_L_Calf"] = {
			["ValveBiped.Bip01_L_Foot"] = true
		},

		["ValveBiped.Bip01_R_Thigh"] = {
			["ValveBiped.Bip01_R_Calf"] = true,
			["ValveBiped.Bip01_R_Foot"] = true
		},
		["ValveBiped.Bip01_R_Calf"] = {
			["ValveBiped.Bip01_R_Foot"] = true
		},
	}
	local amputationArteryGroups = {}
	for _, group in ipairs({
		{"ValveBiped.Bip01_L_UpperArmartery", "ValveBiped.Bip01_L_Forearmartery", "ValveBiped.Bip01_L_Handartery"},
		{"ValveBiped.Bip01_R_UpperArmartery", "ValveBiped.Bip01_R_Forearmartery", "ValveBiped.Bip01_R_Handartery"},
		{"ValveBiped.Bip01_L_Thighartery", "ValveBiped.Bip01_L_Calfartery"},
		{"ValveBiped.Bip01_R_Thighartery", "ValveBiped.Bip01_R_Calfartery"},
	}) do
		for _, artery in ipairs(group) do amputationArteryGroups[artery] = group end
	end
	function SWEP:Tourniquet(ent, bone)
		local org = ent.organism
		if not org then return end
		if #org.arterialwounds > 0 then
			local ent = org.isPly and org.owner or ent
			ent.tourniquets = ent.tourniquets or {}

			local pw
			local bonewounds = {}
			if not bone then
				for i,wound in pairs(org.arterialwounds) do
					if wound[7] != "arteria" then 
						pw = i 
						for i1,tbl in pairs(org.wounds) do
							if !tbl or !tbl[4] or !ent:LookupBone(tbl[4]) then continue end
							local bonename = ent:GetBoneName(ent:LookupBone(tbl[4]))
							local sec_bonename = ent:GetBoneName(ent:LookupBone(wound[4]))
							--print(1,bonename,sec_bonename)
							if bonename == sec_bonename or (tourniqet_bones[sec_bonename] and tourniqet_bones[sec_bonename][bonename]) then
								--print(2,bonename,sec_bonename)
								table.insert(bonewounds,i1)
							end
						end
						--PrintTable(bonewounds)
					break end
				end
				
			else
				for i,wound in pairs(org.arterialwounds) do
					if ent:GetBoneName(ent:LookupBone(wound[4])) == bone then pw = i break end
				end
				for i,tbl in pairs(org.wounds) do
					local bonename = ent:GetBoneName(ent:LookupBone(tbl[4]))
					if bonename == bone or (tourniqet_bones[bone] and tourniqet_bones[bone][bonename]) then
						table.insert(bonewounds,i)
					end
				end
			end		
			pw = pw or math.random(#org.arterialwounds)

			local wound = org.arterialwounds[pw]
			if not wound then return false end
			
			ent.tourniquets[#ent.tourniquets + 1] = {wound[2], wound[3], wound[4]}
			local arteryGroup = amputationArteryGroups[wound[7]]
			local fullLimbAmputation = arteryGroup and (
				(arteryGroup[1] == "ValveBiped.Bip01_L_UpperArmartery" and org.larmupamputated) or
				(arteryGroup[1] == "ValveBiped.Bip01_R_UpperArmartery" and org.rarmupamputated) or
				(arteryGroup[1] == "ValveBiped.Bip01_L_Thighartery" and org.llegupamputated) or
				(arteryGroup[1] == "ValveBiped.Bip01_R_Thighartery" and org.rlegupamputated)
			)
			if not fullLimbAmputation then arteryGroup = nil end
			if arteryGroup then
				local groupedArteries = {}
				for _, artery in ipairs(arteryGroup) do groupedArteries[artery] = true end
				for i = #org.arterialwounds, 1, -1 do
					local artery = org.arterialwounds[i][7]
					if groupedArteries[artery] then
						org[artery] = 0
						table.remove(org.arterialwounds, i)
					end
				end
			else
				org[wound[7]] = 0
				table.remove(org.arterialwounds, pw)
			end

			if wound[7] == "arteria" then org.o2.regen = 0 end

			org.owner:SetNetVar("arterialwounds",org.arterialwounds)

			for i = 1, #bonewounds do
				if org.wounds[bonewounds[i]] then
					--print(org.wounds[bonewounds[i]], bonewounds[i])
					org.wounds[bonewounds[i]][1] = 0
				end
			end
			for i = 1, #bonewounds do
				if org.wounds[bonewounds[i]] then
					table.remove(org.wounds, bonewounds[i])
				end
			end

			org.owner:SetNetVar("wounds",org.wounds)

			ent:SetNetVar("Tourniquets",ent.tourniquets)
			if IsValid(ent.FakeRagdoll) then
				ent.FakeRagdoll:SetNetVar("Tourniquets",ent.tourniquets)
			end
			
			if not table.HasValue(hg.TourniquetGuys,ent) then
				table.insert(hg.TourniquetGuys,ent)
			end

			for i,ent in ipairs(hg.TourniquetGuys) do
				if not IsValid(ent) or not ent.tourniquets or table.IsEmpty(ent.tourniquets) then table.remove(hg.TourniquetGuys,i) end
			end

			SetNetVar("TourniquetGuys",hg.TourniquetGuys)

			self:GetOwner():EmitSound("snd_jack_hmcd_bandage.wav", 65, math.random(95, 105))
			return true
		end
	end

	hook.Add("Player Spawn", "remove-tourniquets", function(ply)
		if OverrideSpawn then return end
		ply:SetNetVar("Tourniquets",{})
		ply.tourniquets = {}
	end)

	hook.Add("Player_Death", "remove-tourniquetshuy", function(ply)
		if IsValid(ply.FakeRagdoll) then
			ply.FakeRagdoll.tourniquets = table.Copy(ply.tourniquets)
			ply.FakeRagdoll:SetNetVar("Tourniquets",ply.FakeRagdoll.tourniquets)
		end
		ply:SetNetVar("Tourniquets",{})
		ply.tourniquets = {}
	end)

	hook.Add("Player Spawn", "remove-bandages", function(ply)
		if OverrideSpawn then return end
		ply:SetNetVar("bandaged_limbs",{})
		ply.bandaged_limbs = {}
	end)

	hook.Add("Player_Death", "remove-bandageshuy", function(ply)
		if IsValid(ply.FakeRagdoll) then
			ply.FakeRagdoll.bandaged_limbs = table.Copy(ply.bandaged_limbs)
			ply.FakeRagdoll:SetNetVar("bandaged_limbs",ply:GetNetVar("bandaged_limbs",ply.FakeRagdoll.bandaged_limbs))
		end
		ply:SetNetVar("bandaged_limbs",{})
		ply.bandaged_limbs = {}
	end)
	

	hook.Add("Fake", "rtourniquetsss", function(ply,ragdoll)
		if not IsValid(ragdoll) then return end	
		
		ragdoll.tourniquets = table.Copy(ply.tourniquets)
		ply:SetNetVar("Tourniquets",ply.tourniquets)
		ragdoll:SetNetVar("Tourniquets",ragdoll.tourniquets)
	end)

	hook.Add("Fake", "bandages-setfake", function(ply,ragdoll)
		if not IsValid(ragdoll) then return end	
		
		ragdoll.bandaged_limbs = table.Copy(ply.bandaged_limbs)
		ply:SetNetVar("bandaged_limbs",ply.bandaged_limbs)
		ragdoll:SetNetVar("bandaged_limbs",ragdoll.bandaged_limbs)
	end)
	
else
	local boneScale = {
		["ValveBiped.Bip01_Head1"] = 1,
		["ValveBiped.Bip01_Neck1"] = 1,
		["ValveBiped.Bip01_L_UpperArm"] = 0.9,
		["ValveBiped.Bip01_L_Forearm"] = 0.8,
		["ValveBiped.Bip01_R_UpperArm"] = 0.9,
		["ValveBiped.Bip01_R_Forearm"] = 0.8,
		["ValveBiped.Bip01_L_Thigh"] = 1.4,
		["ValveBiped.Bip01_L_Calf"] = 1.1,
		["ValveBiped.Bip01_R_Thigh"] = 1.2,
		["ValveBiped.Bip01_R_Calf"] = 1.2,
	}

	local boneOffset = {
		["ValveBiped.Bip01_Neck1"] = {Vector(2, -2, -2.9), Angle(90, 80, 70)},
		["ValveBiped.Bip01_L_UpperArm"] = {Vector(5, -0.5, -3.2), Angle(90, 90, 90)},
		["ValveBiped.Bip01_L_Forearm"] = {Vector(5, -0.1, -2.8), Angle(90, 90, 90)},
		["ValveBiped.Bip01_R_UpperArm"] = {Vector(7, -0.1, -1.5), Angle(90, 90, 90)},
		["ValveBiped.Bip01_R_Forearm"] = {Vector(5, -0.2, -1.5), Angle(90, 90, 90)},
		["ValveBiped.Bip01_L_Thigh"] = {Vector(13, 0, -4.2), Angle(90, -90, 90)},
		["ValveBiped.Bip01_L_Calf"] = {Vector(5, 0.2, -3.2), Angle(90, -90, 90)},
		["ValveBiped.Bip01_R_Thigh"] = {Vector(13, -0.3, -2.6), Angle(90, -90, 90)},
		["ValveBiped.Bip01_R_Calf"] = {Vector(5, 0.3, -3.1), Angle(90, -90, 90)},
	}

	local function remove_tourniquets(ent)
		if not ent.tourniquetsM then return end
		
		for i,model in pairs(ent.tourniquetsM) do
			if IsValid(model) then
				model:Remove()
				ent.tourniquetsM[i] = nil
			end
		end
	end

	hook.Add("OnNetVarSet","tourniquetnisser",function(index, key, var)
		if not IsValid(Entity(index)) then return end
		if key == "Tourniquets" then
			local ent = Entity(index)
			
			remove_tourniquets(ent)
			
			ent.tourniquets = var
			
			ent:CallOnRemove("remove_tourniquets",function()
				remove_tourniquets(ent)
			end)
		end
	end)

	hook.Add("Fake","gsdgsdgsdgsdsdgTURNIKET",function(ply,ragdoll)
		remove_tourniquets(ply)
		if IsValid(ragdoll) then
			remove_tourniquets(ragdoll)
		end
	end)

	hook.Add("Player_Death","huyhuyhuyFuckyou",function(ply)
		remove_tourniquets(ply)
	end)

	--hook.Add("PostDrawPlayerRagdoll", "draw_tourniquets", function(ent,ply)
	function hg.RenderTourniquets(ent, ply)
		if !ply.tourniquets or !next(ply.tourniquets) then return end
		for i, wound in ipairs(ply.tourniquets) do
			ply.tourniquetsM = ply.tourniquetsM or {}
			ply.tourniquetsM[i] = IsValid(ply.tourniquetsM[i]) and ply.tourniquetsM[i] or ClientsideModel("models/tourniquet/tourniquet_put.mdl")
			local model = ply.tourniquetsM[i]
			model:SetNoDraw(true)

			if not IsValid(model) then return end
			
			local boneName = wound[3]
			local limb = hg.amputatedlimbs2 and hg.amputatedlimbs2[boneName]
			if limb and ply.organism and ply.organism[limb.."amputated"] then
				continue
			end
			
			local matrix = ent:GetBoneMatrix(ent:LookupBone(wound[3]))
			if not matrix then
				model:SetNoDraw(true)
				return
			end
			
			local bonePos, boneAng = matrix:GetTranslation(), matrix:GetAngles()
			
			local tourniquetOffset = -wound[1]:GetNegated()
			tourniquetOffset[2] = 0
			tourniquetOffset[3] = 0
			tourniquetOffset[1] = 0

			if not boneOffset[ent:GetBoneName(ent:LookupBone(wound[3]))] then continue end

			local offset = boneOffset[ent:GetBoneName(ent:LookupBone(wound[3]))][1] + tourniquetOffset
			local offset2 = boneOffset[ent:GetBoneName(ent:LookupBone(wound[3]))][2]
			local pos, ang = LocalToWorld(offset, offset2, bonePos, boneAng)
			model:SetRenderOrigin(pos)
			model:SetRenderAngles(ang)
			model:SetModelScale(boneScale[ent:GetBoneName(ent:LookupBone(wound[3]))])
			model:SetupBones()
			model:DrawModel()
		end
	end
	--end)

	

	function remove_bandages(ent)
		if IsValid(ent.bandagesModel) then
			ent.bandagesModel:Remove()
		end
		ent.bandagesModel = nil
		if IsValid(ent.bandagesHeadModel) then
			ent.bandagesHeadModel:Remove()
		end
		ent.bandagesHeadModel = nil
		ent.bandagesSoak = nil
	end

	hook.Add("OnNetVarSet","bandage_netvar",function(index, key, var)
		if key == "bandaged_limbs" then
			local ent = Entity(index)
	
			if IsValid(ent) then
	
				remove_bandages(ent)

				ent.bandaged_limbs = var

				local oldSoak = ent.bandagesSoak
				ent.bandagesSoak = {}
				for bone in pairs(ent.bandaged_limbs) do
					ent.bandagesSoak[bone] = (oldSoak and oldSoak[bone]) or 0
				end

				ent:CallOnRemove("remove_bandages",function()
					remove_bandages(ent)
				end)
			end
		end
	end)

	local BadagesModelMale = "models/distac/newbandage.mdl"
	local BadagesModelFemale = "models/distac/newbandage_f.mdl"

	local HeadBandageModelMale = "models/distac/newbandage-head.mdl"
	local HeadBandageModelFemale = "models/distac/newbandage-head.mdl"
	local HeadBandageOffsetMale = {Vector(0, 0, -0.2), Angle(0, 0, 0)}
	local HeadBandageOffsetFemale = {Vector(0, 0, -0.6), Angle(0, 0, 0)}
	local BodyGroupsMale = {
		["ValveBiped.Bip01_Pelvis"] = "belly",
		["ValveBiped.Bip01_Spine"] = "groin",
		["ValveBiped.Bip01_Spine1"] = "belly",
		["ValveBiped.Bip01_Spine2"] = "Chest",
		["ValveBiped.Bip01_L_UpperArm"] = "HandUpLeft",
		["ValveBiped.Bip01_L_Forearm"] = "HandDownLeft",
		["ValveBiped.Bip01_L_Hand"] = "HandLeft",
		["ValveBiped.Bip01_R_UpperArm"] = "HandUpRight",
		["ValveBiped.Bip01_R_Forearm"] = "HandDownRight",
		["ValveBiped.Bip01_R_Hand"] = "HandRight",
		["ValveBiped.Bip01_L_Thigh"] = "LegUpLeft",
		["ValveBiped.Bip01_L_Calf"] = "LegDownLeft",
		["ValveBiped.Bip01_R_Thigh"] = "LegUpRught",
		["ValveBiped.Bip01_R_Calf"] = "LegDownRught",
	}

	local BodyGroupsFemale = {
		["ValveBiped.Bip01_Pelvis"] = "belly-f",
		["ValveBiped.Bip01_Spine"] = "groin-f",
		["ValveBiped.Bip01_Spine1"] = "belly-f",
		["ValveBiped.Bip01_Spine2"] = "Chest-f",
		["ValveBiped.Bip01_L_UpperArm"] = "HandUpLeft-f",
		["ValveBiped.Bip01_L_Forearm"] = "HandDownLeft-f",
		["ValveBiped.Bip01_L_Hand"] = "HandLeft-f",
		["ValveBiped.Bip01_R_UpperArm"] = "HandUpRight-f",
		["ValveBiped.Bip01_R_Forearm"] = "HandDownRight-f",
		["ValveBiped.Bip01_R_Hand"] = "HandRight-f",
		["ValveBiped.Bip01_L_Thigh"] = "LegUpLeft-f",
		["ValveBiped.Bip01_L_Calf"] = "LegDownLeft-f",
		["ValveBiped.Bip01_R_Thigh"] = "LegUpRught-f",
		["ValveBiped.Bip01_R_Calf"] = "LegDownRught-f",
	}

	--hook.Add("PostDrawPlayerRagdoll", "draw_bandages", function(ent,ply)
	local function GetBandageSoakRate(org)
		if not org then return 0.0015 end

		local rate = 0.0015
		rate = rate + math.Clamp((org.bleed or 0) / 0.6, 0, 1) * 0.03
		rate = rate + math.Clamp((5000 - (org.blood or 5000)) / 5000, 0, 1) * 0.006

		return rate
	end
	local function GetBandageSoakColor(soak)
		if not soak or soak <= 0 then return Color(255, 255, 255, 255) end

		return Color(255 - math.floor(255 * soak * 0.12), 255 - math.floor(255 * soak * 0.85), 255 - math.floor(255 * soak * 0.9), 255)
	end

	function hg.RenderBandages(ent, ply)
		--PrintTable(ent.bandaged_limbs)
		if not ent.bandaged_limbs then return end
		if !next(ent.bandaged_limbs) then return end

		if not ent.bandagesSoak then
			ent.bandagesSoak = {}
			for bone in pairs(ent.bandaged_limbs) do ent.bandagesSoak[bone] = 0 end
		end

		local org = ent and ent.organism or (IsValid(ply) and ply.organism)
		local soak = 0
		for bone, v in pairs(ent.bandagesSoak) do
			if ent.bandaged_limbs[bone] then
				ent.bandagesSoak[bone] = math.min((ent.bandagesSoak[bone] or 0) + GetBandageSoakRate(org) * FrameTime(), 1)
				soak = math.max(soak, ent.bandagesSoak[bone])
			end
		end

		if not IsValid( ent.bandagesModel ) then
			ent.bandagesModel = (ThatPlyIsFemale(ent) and ClientsideModel(BadagesModelFemale) or ClientsideModel(BadagesModelMale))
			local model = ent.bandagesModel
			ent:CallOnRemove("removebandages",function()
				if IsValid(model) then
					model:Remove()
					model = nil
				end
			end)
		end
		
		local model = ent.bandagesModel
		model:SetNoDraw(true)
		model:SetPos(ent:GetPos() + vector_up * 1)
		model:SetParent(ent)
		model:AddEffects(EF_BONEMERGE)
		model:SetColor(GetBandageSoakColor(soak))
		local dontmakehands = false
		if !hg.Appearance.FuckYouModels[1][ent:GetModel()] and !hg.Appearance.FuckYouModels[2][ent:GetModel()] then dontmakehands = true end
		
		if not model.BodygroupsApplied then 
			for k, v in pairs(ent.bandaged_limbs) do
				if k == "ValveBiped.Bip01_Head1" then continue end -- head uses separate model
				if dontmakehands and (k == "ValveBiped.Bip01_L_Hand" or k == "ValveBiped.Bip01_R_Hand") then continue end -- ez
				model:SetBodygroup(model:FindBodygroupByName( ThatPlyIsFemale(ent) and BodyGroupsFemale[k] or BodyGroupsMale[k] or ""), 1)
			end

			for k, v in pairs(hg.amputatedlimbs2) do
				local children = hg.get_children(ent, k)
				table.insert(children, k)
				
				for k2, v2 in ipairs(children) do
					if ent.bandaged_limbs[v2] and ent.organism and ent.organism[hg.amputatedlimbs2[v2].."amputated"] then
						model:SetBodygroup(model:FindBodygroupByName( ThatPlyIsFemale(ent) and BodyGroupsFemale[v2] or BodyGroupsMale[v2] or ""), 0)
					end
				end
			end

			model.BodygroupsApplied = true
		end
		model:DrawModel()

		if ent.bandaged_limbs["ValveBiped.Bip01_Head1"] and not (ply == LocalPlayer() and GetViewEntity() == LocalPlayer()) then
			local female = ThatPlyIsFemale(ent)
			local mdlpath = female and HeadBandageModelFemale or HeadBandageModelMale
			if not IsValid(ent.bandagesHeadModel) or ent.bandagesHeadModel:GetModel() ~= mdlpath then
				if IsValid(ent.bandagesHeadModel) then ent.bandagesHeadModel:Remove() end
				ent.bandagesHeadModel = ClientsideModel(mdlpath)
				ent:CallOnRemove("removebandageshead", function()
					if IsValid(ent.bandagesHeadModel) then
						ent.bandagesHeadModel:Remove()
						ent.bandagesHeadModel = nil
					end
				end)
			end
			local headmodel = ent.bandagesHeadModel
			headmodel:SetNoDraw(true)
			headmodel:SetPos(ent:GetPos() + vector_up * 1)
			headmodel:SetParent(ent)
			headmodel:AddEffects(EF_BONEMERGE)
			headmodel:SetupBones()

			local offset = female and HeadBandageOffsetFemale or HeadBandageOffsetMale
			if offset[1] ~= vector_origin or offset[2] ~= angle_zero then
				local nb = headmodel:GetBoneCount()
				for i = 0, nb - 1 do
					local p, a = headmodel:GetBonePosition(i)
					headmodel:SetBonePosition(i, p + offset[1], a + offset[2])
				end
			end

			headmodel:SetColor(GetBandageSoakColor(soak))
			headmodel:DrawModel()
		end
	end
	--end)
end

function SWEP:IsLocal()
	return CLIENT and self:GetOwner() == LocalPlayer()
end

function SWEP:Holster(wep)
	if self.BandageTPIK then
		self:CancelBandageTPIK(false)
		return true
	end

	if not IsValid(wep) or wep == self then return true end

	if SERVER or CLIENT and self:IsLocal() then
		self:EmitSound(self.HolsterSnd,50)
	end

	return true
end

function SWEP:NPCHeal(npc, mul, snd)
	if not npc then
		npc = self:GetOwner()
	end

	if npc:IsNPC() then
		self:SetHold("melee")
		if not mul then
			mul = 0.3
		end
		npc:SetHealth(math.Clamp(npc:Health() + (npc:GetMaxHealth() * 1 * mul), 0, npc:GetMaxHealth() * math.Clamp(2 * mul, 2, 100)))
		npc:EmitSound(snd or "snd_jack_hmcd_bandage.wav", 75, math.random(95, 105))

		if SERVER then
			self:Remove()
		end
	end
end

function SWEP:OwnerChanged()
	local owner = self:GetOwner()
	if IsValid(owner) and owner:IsNPC() then
		self:NPCHeal(owner, 0.15, "snd_jack_hmcd_bandage.wav")
	end
end

function SWEP:Deploy()
	if self.BandageTPIK then
		self:CancelBandageTPIK(false)
		self._idleScheduled = nil
		local base = weapons.GetStored("weapon_tpik_base")
		if base and base.Deploy then base.Deploy(self) end
		if SERVER then
			local timerName = "bandage_deploy_" .. self:EntIndex()
			timer.Create(timerName, 1, 1, function()
				if IsValid(self) and self.anim == "deploy" then
					self:PlayAnim("idle")
				end
			end)
		end
		return true
	end

	if SERVER or CLIENT and self:IsLocal() then
		self:EmitSound(self.DeploySnd, 50, math.random(90, 110))
	end

	if self.DeployAdd then self:DeployAdd() end

	return true
end

function SWEP:EnableBandageTPIK()
	self.BandageTPIK = true
	self.supportTPIK = true
	self.isTPIKBase = true
	self.WorldModel = self.BandageTPIKWorldModel
	self.WorldModelReal = self.BandageTPIKViewModel
	self.WorldModelExchange = false
	self.AnimList = self.BandageTPIKAnimList
	self.HoldPos = Vector(1, 0, 0)
	self.HoldAng = Angle(0, 0, 0)
	self.sprint_pos = Vector(0, 0, 0)
	self.sprint_ang = Angle(20, 0, 0)
	self.setlh = true
	self.setrh = true
	self.modelscale = 1
	self.modelscale2 = 1
	self.CallbackTimeAdjust = 0
	self.animtime = 0
	self.animspeed = 1
	self.cycling = false
	self.reverseanim = false
end

function SWEP:GetBandageTPIKUseTime(target)
	local org = IsValid(target) and target.organism
	if not org then return self.BandageUseTime end

	local required = 0
	for _, wound in ipairs(org.wounds or {}) do
		required = required + math.max(wound[1] or 0, 0)
	end

	local owner = self:GetOwner()
	local treatmentCost = 25 * (IsValid(owner) and owner.Profession == "doctor" and 0.2 or 1)
	if (org.skull or 0) >= 0.6 then required = required + treatmentCost end
	if org.chest == 1 then required = required + treatmentCost end
	if org.lleg == 1 and not org.llegamputated then required = required + treatmentCost end
	if org.rleg == 1 and not org.rlegamputated then required = required + treatmentCost end
	if org.larm == 1 and not org.larmamputated then required = required + treatmentCost end
	if org.rarm == 1 and not org.rarmamputated then required = required + treatmentCost end

	local used = math.min(required, self.modeValues and self.modeValues[1] or 0)
	return math.Clamp(1.2 + used / 40 * 2.2, 1.2, 6)
end

function SWEP:CanBandageTPIK(target)
	local org = IsValid(target) and target.organism
	local available = self.modeValues and self.modeValues[1] or 0
	if not org or available <= 0 then return false end

	for _, wound in ipairs(org.wounds or {}) do
		if (wound[1] or 0) > 0.1 then return true end
	end

	local owner = self:GetOwner()
	local treatmentCost = 25 * (IsValid(owner) and owner.Profession == "doctor" and 0.2 or 1)
	if available < treatmentCost then return false end
	if (org.skull or 0) >= 0.6 or org.chest == 1 then return true end
	if org.lleg == 1 and not org.llegamputated then return true end
	if org.rleg == 1 and not org.rlegamputated then return true end
	if org.larm == 1 and not org.larmamputated then return true end
	if org.rarm == 1 and not org.rarmamputated then return true end

	return false
end

function SWEP:StartBandageTPIK(target, button)
	if not SERVER or self.bandageTPIKUsing or self.bandageTPIKAwaitRelease or self._reverseToIdle then return end
	if not self:CanBandageTPIK(target) then return end

	self.bandageTPIKUsing = true
	self.bandageTPIKAwaitRelease = true
	self.bandageTPIKTarget = target
	self.bandageTPIKButton = button
	self.bandageTPIKStart = CurTime()
	self._idleScheduled = nil
	local fullUseTime = self:GetBandageTPIKUseTime(target)
	local endCycle = 1 - self.BandageAnimEndTrim / self.BandageSequenceTime
	local visibleFraction = endCycle
	self.bandageTPIKUseTime = math.max(fullUseTime * visibleFraction, self.BandageMinUseTime)
	self.bandageTPIKEndTime = CurTime() + self.bandageTPIKUseTime
	self.bandageTPIKSounds = 0
	self:SetNextPrimaryFire(self.bandageTPIKEndTime)
	self:SetNextSecondaryFire(self.bandageTPIKEndTime)
	self:PlayAnim("use", self.bandageTPIKUseTime, false, nil, false, nil,
		0,
		endCycle,
		self.bandageTPIKEndTime)

	local timerName = "bandage_finish_" .. self:EntIndex()
	timer.Create(timerName, self.bandageTPIKUseTime, 1, function()
		if IsValid(self) and self.bandageTPIKUsing then
			self:FinishBandageTPIK()
		end
	end)
end

function SWEP:CancelBandageTPIK(reverse)
	local wasUsing = self.bandageTPIKUsing
	self.bandageTPIKUsing = nil
	self.bandageTPIKTarget = nil
	self.bandageTPIKButton = nil
	self.bandageTPIKStart = nil
	self.bandageTPIKUseTime = nil
	self.bandageTPIKEndTime = nil
	self.bandageTPIKSounds = nil
	if SERVER then
		local timerName = "bandage_finish_" .. self:EntIndex()
		timer.Remove(timerName)
		local deployTimerName = "bandage_deploy_" .. self:EntIndex()
		timer.Remove(deployTimerName)
	end
	if reverse and wasUsing and SERVER then
		self:ReverseAnimToIdle("use", 0)
	end
end

function SWEP:FinishBandageTPIK()
	if not SERVER or not self.bandageTPIKUsing then return end

	local timerName = "bandage_finish_" .. self:EntIndex()
	timer.Remove(timerName)

	local target = self.bandageTPIKTarget
	self:CancelBandageTPIK(false)
	if not IsValid(target) then
		self:PlayAnim("idle")
		return
	end

	if hg.GetCurrentCharacter(target) == hg.GetCurrentCharacter(self:GetOwner()) then
		self:SetHolding(100)
	end
	local done = self:Heal(target, self.mode)
	if done and self.PostHeal then self:PostHeal(target, self.mode) end
	if IsValid(self) then
		self:SetNetVar("modeValues", self.modeValues)
		self:PlayAnim("idle")
	end
end

function SWEP:BandageTPIKThink()
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.ThinkReverseAnimToIdle then base.ThinkReverseAnimToIdle(self, CurTime()) end
	if CLIENT then
		if self.anim == "use" and not self.reverseanim and not self._reverseToIdle and not self._idleScheduled and self.animtime and self.animtime <= CurTime() then
			self._idleScheduled = true
			self.animtime = nil
			self:PlayAnim("idle")
		end
		if self.anim == "deploy" and not self.reverseanim and not self._reverseToIdle and not self._idleScheduled and self.animtime and self.animtime <= CurTime() then
			self._idleScheduled = true
			self.animtime = nil
			self:PlayAnim("idle")
		end
		if self.anim == "idle" then
			self._idleScheduled = nil
		end
		return
	end
	local owner = self:GetOwner()
	if self.bandageTPIKAwaitRelease and IsValid(owner)
		and not owner:KeyDown(IN_ATTACK) and not owner:KeyDown(IN_ATTACK2) then
		self.bandageTPIKAwaitRelease = nil
	end
	if not self.bandageTPIKUsing then
		if not self._reverseToIdle and self.anim == "deploy" and self.animtime and self.animtime <= CurTime() then
			self:PlayAnim("idle")
		end
		return
	end

	if not IsValid(owner) or not self.bandageTPIKButton or not owner:KeyDown(self.bandageTPIKButton) then
		self:CancelBandageTPIK(true)
		return
	end

	local elapsed = CurTime() - self.bandageTPIKStart
	local useTime = self.bandageTPIKUseTime or self.BandageUseTime
	local sndOwner = IsValid(owner.FakeRagdoll) and owner.FakeRagdoll or owner
	if self.bandageTPIKSounds < 1 and elapsed >= useTime * 0.08 then
		self.bandageTPIKSounds = 1
		sndOwner:EmitSound("weapons/nmrih/items/bandage/bandage_unravel_0" .. math.random(1, 2) .. ".wav", 60, 100)
	end
	if self.bandageTPIKSounds < 2 and elapsed >= useTime * 0.47 then
		self.bandageTPIKSounds = 2
		sndOwner:EmitSound("weapons/nmrih/items/bandage/bandage_apply_0" .. math.random(1, 2) .. ".wav", 60, 100)
	end

	if self.bandageTPIKEndTime and CurTime() >= self.bandageTPIKEndTime then self:FinishBandageTPIK() end
end

function SWEP:Camera(eyePos, eyeAng, view, vellen)
	if not self.BandageTPIK then return end
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.Camera then return base.Camera(self, eyePos, eyeAng, view, vellen) end
end

function SWEP:SetHandPos(noset)
	if not self.BandageTPIK then return end
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.SetHandPos then return base.SetHandPos(self, noset) end
end

function SWEP:GetWM()
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.GetWM then return base.GetWM(self) end
end

function SWEP:GetHideMeshBones()
	if not self.BandageTPIK then return self.HideMeshBones end
	if self.anim == "idle" then return self.BandageTPIKHiddenBonesIdle end
	if self.anim == "use" then
		local cycle = self:GetCurrentAnimCycle()
		if cycle < self.BandageAnimStart / self.BandageSequenceTime then
			return self.BandageTPIKHiddenBonesIdle
		end
		return self.BandageTPIKHiddenBonesUse
	end
	if self.anim == "deploy" then return self.BandageTPIKHiddenBonesIdle end
end

function SWEP:GetHideMeshCollapseBone()
end

function SWEP:GetTPIKHoldPos(holdPos)
	if not self.BandageTPIK or self.anim ~= "use" then return holdPos end

	local switchCycle = self.BandageAnimStart / self.BandageSequenceTime
	local distance = math.abs(self:GetCurrentAnimCycle() - switchCycle)
	local amount = 1 - math.Clamp(distance / self.BandageTransitionCycleWidth, 0, 1)
	if amount <= 0 then return holdPos end
	amount = amount * amount * (3 - 2 * amount)

	return holdPos + Vector(
		-self.BandageTransitionIn * amount,
		0,
		-self.BandageTransitionDown * amount
	)
end

function SWEP:PlayAnim(...)
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.PlayAnim then return base.PlayAnim(self, ...) end
end

function SWEP:GetCurrentAnimCycle(...)
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.GetCurrentAnimCycle then return base.GetCurrentAnimCycle(self, ...) end
	return 0
end

function SWEP:ReverseAnimToIdle(...)
	local base = weapons.GetStored("weapon_tpik_base")
	if base and base.ReverseAnimToIdle then return base.ReverseAnimToIdle(self, ...) end
end


SWEP:EnableBandageTPIK()

function SWEP:CanBePickedUpByNPCs()
	return true
end

function SWEP:GetNPCRestTimes()
	return 0.1, 0.1
end
