--ByLazzy
SWEP.Base = "homigrad_base"
SWEP.ARC9ActionLHIKFadeOutTime = 0.1
SWEP.ARC9ActionLHIKFadeInTime = 0.5
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.PrintName = "AK-50"
SWEP.Author = "Brandon Herrera"
SWEP.Instructions = "Sniper rifle chambered in .50 BMG"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.Slot = 2
SWEP.SlotPos = 10
SWEP.ViewModel = ""
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl" -- Оставил как есть
SWEP.WorldModelFake = "models/weapons/c_ak50.mdl"
SWEP.WorldModelReal = "models/weapons/c_ak50.mdl"

SWEP.FakePos = Vector(-24, 2, 9)
SWEP.FakeAng = Angle(0, 0, 0)
SWEP.FakeAttachment = "1"
SWEP.AttachmentPos = Vector(1,-2,-0.05)
SWEP.AttachmentAng = Angle(0,0,0)

SWEP.FakeBodyGroups = "0111111"
SWEP.CantFireFromCollision = true

SWEP.FakeBodyGroupsPresets = {
    "0111111"
}

SWEP.FakeViewBobBone = "ValveBiped.Bip01_L_Hand"
SWEP.FakeViewBobBaseBone = "ValveBiped.Bip01_L_UpperArm"
SWEP.ViewPunchDiv = 1


SWEP.FakeMagDropBone = 50
SWEP.MagModel = "models/weapons/mods/mag_barret10.mdl"

if CLIENT then
	local vector_full = Vector(1, 1, 1)
	SWEP.FakeReloadEvents = {
		[0.10] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(27, vector_origin)
			self:GetWM():ManipulateBoneScale(38, vector_full)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetWM():ManipulateBoneScale(41, vector_origin)
		end,
		[0.35] = function(self, timeMul)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 0.5 * timeMul, nil, nil, function()
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_full)
				wm:ManipulateBoneScale(39, vector_full)
				end
			end)
		end,
		[0.40] = function(self, timeMul)
			if self:Clip1() < 1 then
				hg.CreateMag( self, Vector(50,10,10), nil, true )
			end
			self:GetWM():ManipulateBoneScale(57, vector_origin)
			self:GetWM():ManipulateBoneScale(58, vector_origin)
		end,
		[0.70] = function(self, timeMul)
			self:GetWM():ManipulateBoneScale(38, vector_origin)
			self:GetWM():ManipulateBoneScale(39, vector_origin)
			self:GetWM():ManipulateBoneScale(40, vector_origin)
			self:GetOwner():PullLHTowards("ValveBiped.Bip01_Spine2", 1 * timeMul, nil, nil, function()
				local wm = self:GetWM()
				if IsValid(wm) then
				wm:ManipulateBoneScale(38, vector_origin)
				wm:ManipulateBoneScale(39, vector_origin)
				wm:ManipulateBoneScale(40, vector_origin)
				end
			end)
		end,
	}
end

SWEP.FakeVPShouldUseHand = false

SWEP.HeldPistolgripModel = "models/weapons/mods/ak_pgrip_ak74_bakelit.mdl"
SWEP.HeldPistolgripBone = "weapon"
SWEP.HeldPistolgripOffsetPos = Vector(0, -12.3, -1.3)
SWEP.HeldPistolgripOffsetAng = Angle(0, 0, 0)

if CLIENT then
	function SWEP:DrawPost()
		local wm = self:GetWM()
		if not IsValid(wm) then return end

		if not IsValid(self.HeldPistolgripCSModel) then
			self.HeldPistolgripCSModel = ClientsideModel(self.HeldPistolgripModel, RENDERGROUP_BOTH)
			if not IsValid(self.HeldPistolgripCSModel) then return end
			self.HeldPistolgripCSModel:SetNoDraw(true)
		end

		local bone = wm:LookupBone(self.HeldPistolgripBone)
		local matrix = bone and wm:GetBoneMatrix(bone)
		if not matrix then return end

		local pos, ang = LocalToWorld(self.HeldPistolgripOffsetPos, self.HeldPistolgripOffsetAng, matrix:GetTranslation(), matrix:GetAngles())
		self.HeldPistolgripCSModel:SetRenderOrigin(pos)
		self.HeldPistolgripCSModel:SetRenderAngles(ang)
		self.HeldPistolgripCSModel:SetupBones()
		self.HeldPistolgripCSModel:DrawModel()
	end

	function SWEP:OnRemove()
		if IsValid(self.HeldPistolgripCSModel) then self.HeldPistolgripCSModel:Remove() end
	end
end

SWEP.WepSelectIcon2 = Material("entities/arc9_eft_ak50.png")
SWEP.IconOverride = "entities/arc9_eft_ak50.png"

SWEP.LocalMuzzlePos = Vector(23, -1.3, 5.9)
SWEP.LocalMuzzleAng = Angle(0,-0.029,0)
SWEP.WeaponEyeAngles = Angle(0,0,0)

SWEP.CustomShell = ".338Lapua"
SWEP.weight = 5
SWEP.ScrappersSlot = "Primary"
SWEP.weaponInvCategory = 1
SWEP.ShellEject = "RifleShellEject"
SWEP.AutomaticDraw = false
SWEP.AnimDraw = 0.4
SWEP.reloadCoolDown = 0
SWEP.RHPos = Vector(3, -5, 3)
SWEP.RHAng = Angle(0, -5, 90)
SWEP.LHPos = Vector(15, -1, -3)
SWEP.LHAng = Angle(-110, -90, -90)
SWEP.UseCustomWorldModel = true
SWEP.ViewPunchDiv = 1

-- Характеристики
SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ".50 BMG Slap"
SWEP.Primary.Damage = 180
SWEP.Primary.Force = 60
SWEP.Primary.Cone = 0
SWEP.Primary.Spread = 0
-- Звуки выстрела (AK50)
SWEP.Primary.Sound = {"weapons/darsu_eft/ak50/ak50_outdoor_close.ogg", 85, 100, 100}
SWEP.SupressedSound = {"weapons/darsu_eft/ak50/ak50_outdoor_close.ogg", 65, 100, 100} -- Глушителя у AK50 вроде нет, но пусть будет тот же
SWEP.Primary.SoundEmpty = {"arc9_eft_shared/weap_trigger_empty.wav", 75, 100, 105, CHAN_WEAPON, 2}
SWEP.Primary.Wait = 0.25 
SWEP.NumBullet = 1

SWEP.availableAttachments = {
	sight = {
		["mountType"] = {"picatinny"},
		["mount"] = {["picatinny"] = Vector(-34, 2.7, 0.05)},
	},
	barrel = false,
	underbarrel = false,
	grip = false,
	magwell = false,
}

SWEP.StartAtt = {"optic19"}

SWEP.AnimShootMul = 1
SWEP.AnimShootHandMul = 3
SWEP.DeploySnd = {"homigrad/weapons/draw_hmg.mp3", 55, 100, 110}
SWEP.HolsterSnd = {"homigrad/weapons/hmg_holster.mp3", 55, 100, 110}
SWEP.HoldType = "rpg"
SWEP.ZoomPos = Vector(0, -1.2888, 9.0264)
SWEP.RHandPos = Vector(-12, -2, 4)
SWEP.LHandPos = Vector(6, 1, -2)
SWEP.Ergonomics = 0.75
SWEP.Penetration = 35
SWEP.WorldPos = Vector(14, -1, 3.5)
SWEP.WorldAng = Angle(0, 0, 0)
SWEP.attPos = Vector(0,2,0)
SWEP.attAng = Angle(0,0,0)
SWEP.lengthSub = 5

SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(2, 8, -12)
SWEP.holsteredAng = Angle(210, 0, 180)

-- СПИСОК АНИМАЦИЙ
SWEP.AnimList = {
    ["idle"] = "idle",
    ["idle_empty"] = "idle", -- У AK50 обычно нет idle_empty, затвор закрывается?
    ["draw"] = "draw",
    ["draw_empty"] = "draw",
    ["holster"] = "holster",
    ["holster_empty"] = "holster",
    ["ready"] = "ready",
    ["fire"] = "fire",
    ["fire_empty"] = "fire",
    ["dryfire"] = "fire_dry",
    ["dryfire_empty"] = "fire_dry",
    ["cycle"] = "bolt0", -- Если нужно, но тут полуавтомат
    ["reload"] = "reload", 
    ["reload_empty"] = "reload_empty", 
    ["inspect"] = "inspect0", -- В конфиге inspect1
    ["inspect_empty"] = "inspect0",
    ["toggle"] = "mod_switch",
}

-- ПУТЬ К ЗВУКАМ (AK50)
local path = "weapons/darsu_eft/ak50/"

SWEP.AnimsSounds = {
    ["ready"] = {
        [0.15] = function(self) self:EmitSound(path .. "ak50_gunflip_1.ogg") end,
        [1.39] = function(self) self:EmitSound(path .. "ak50_bolt_out.ogg") end,
        [1.74] = function(self) self:EmitSound(path .. "ak50_bolt_in.ogg") end,
        [2.10] = function(self) self:EmitSound(path .. "ak50_gunflip_3.ogg") end,
    },
    ["draw"] = {
        [0] = function(self) self:EmitSound("arc9_eft_shared/weap_in.ogg") end,
    },
    ["fire"] = {
        [0] = function(self) self:EmitSound(path .. "ak50_hammer_in.ogg") end, -- Звук механизма
    },
}

SWEP.AnimsEvents = {
	["inspect"] = {
		[0.01] = function(self) self:EmitSound("arc9_eft_shared/weap_handon.ogg") end,
		[0.4] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin9.ogg") end,
		[0.8] = function(self) self:EmitSound("arc9_eft_shared/weapon_generic_spin6.ogg") end,
	},
}

SWEP.stupidgun = true

function SWEP:AllowedInspect()
	return self:Clip1() >= self.Primary.ClipSize
end

function SWEP:AnimHoldPost() end
function SWEP:ModelCreated(model) model:SetBodyGroups(self:GetRandomBodygroups() or "0111111") end
function SWEP:PostSetupDataTables() self:NetworkVar("String", 0, "RandomBodygroups"); if CLIENT then self:NetworkVarNotify("RandomBodygroups", self.OnVarChanged) end end
function SWEP:OnVarChanged(name, old, new) if not IsValid(self:GetWM()) then return end if istable(new) then local normalized = {}; for i = 1, #new do normalized[i] = tostring(new[i]) end; new = table.concat(normalized, "") elseif not isstring(new) then return end self:GetWM():SetBodyGroups(new) end
function SWEP:InitializePost() local randomPreset = table.Random(self.FakeBodyGroupsPresets); if istable(randomPreset) then randomPreset = table.Random(randomPreset) end; if isstring(randomPreset) then self:SetRandomBodygroups(randomPreset) end; self.AnimStart_Insert = 0; self.AnimStart_Draw = 0 end
function SWEP:AnimationPost() local animpos = math.Clamp(self:GetAnimPos_Draw(CurTime()), 0, 1); local sin = 1 - animpos; if sin >= 0.5 then sin = 1 - sin else sin = sin * 1 end; sin = sin * 2; sin = math.ease.InOutSine(sin); if sin > 0 then self.LHPos[1] = 18 - sin * 6; self.RHPos[1] = 1 - sin * 4; self.inanim = true else self.inanim = nil end; local wep = self:GetWeaponEntity(); if CLIENT and IsValid(wep) then wep:ManipulateBonePosition(4, Vector(0, 0, sin * -3), false) end end
function SWEP:GetAnimPos_Insert(time) return 0 end
function SWEP:GetAnimPos_Draw(time) return 0 end

SWEP.GunCamPos = Vector(6, -12, -5)
SWEP.GunCamAng = Angle(190, -5, -95)
local vector_full = Vector(1, 1, 1)
SWEP.FakeEjectBrassATT = "2"

function SWEP:PrimaryShootPost()
    self.drawBullet = true

    local owner = self:GetOwner()
    if not IsValid(owner) then return end

    if math.random() <= 0.15 then
        if CLIENT then return end

        local pos = owner:GetShootPos()
        local wepClass = self:GetClass()

        util.BlastDamage(self, owner, pos, 200, 80)

        hg.ExplosionEffect(pos, 200, 80)

        local effect = EffectData()
        effect:SetOrigin(pos)
        effect:SetScale(1)
        effect:SetNormal(owner:EyeAngles():Forward())
        util.Effect("Explosion", effect)

        timer.Simple(0.1, function()
            if IsValid(owner) and owner:HasWeapon(wepClass) then
                owner:StripWeapon(wepClass)
            end
        end)
    end
end

function SWEP:Reload(time)
    if self.AnimStart_Draw > CurTime() - 0.5 then return end
    if not self:CanUse() then return end
    if self.reloadCoolDown > CurTime() then return end
    if self.Primary.Next > CurTime() then return end
    if self:GetNetVar("shootgunReload", 0) > CurTime() then return end

    if self:Clip1() >= self.Primary.ClipSize then return end

    local ammoType = self:GetPrimaryAmmoType()
    if self:GetOwner():GetAmmoCount(ammoType) <= 0 then return end

    if SERVER then
        local isEmpty = self:Clip1() <= 0
        local animName = isEmpty and "reload_empty" or "reload"
        
        -- СКОРОСТЬ АНИМАЦИИ: 5
        local animSpeed = 5
        
        -- ТАЙМИНГИ (умноженные на 5)
        -- reload: ~3.7 * 
        -- reload_empty: ~4.2 * 
        local reloadTime = isEmpty and 5 or 4.5
        
        self:SetNetVar("shootgunReload", CurTime() + reloadTime)
        self.reloadCoolDown = CurTime() + reloadTime
        
        local wep = self
        
        self:PlayAnim(self.AnimList[animName] or animName, animSpeed, false, function()
            if not IsValid(wep) or not IsValid(wep:GetOwner()) then return end
            
            local ammoType = wep:GetPrimaryAmmoType()
            local currentClip = wep:Clip1()
            local maxClip = wep.Primary.ClipSize
            local neededAmmo = maxClip - currentClip
            local availableAmmo = wep:GetOwner():GetAmmoCount(ammoType)
            local ammoToLoad = math.min(neededAmmo, availableAmmo)
            
            if ammoToLoad > 0 then
                wep:GetOwner():RemoveAmmo(ammoToLoad, ammoType)
                wep:SetClip1(currentClip + ammoToLoad)
            end
            
            wep:SetNetVar("shootgunReload", 0)
            
            wep.drawBullet = true
            if isEmpty then
                net.Start("hgwep draw")
                    net.WriteEntity(wep)
                    net.WriteBool(true)
                    net.WriteFloat(CurTime() - 10) 
                net.Broadcast()
            end
        end, false, true)
        
               -- Звуки (Без умножения на 5, чтобы влезть в reloadTime)
        if isEmpty then
            -- reload_empty (всего 5.0 сек)
            timer.Simple(0.03, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_1.ogg") end end)
            timer.Simple(0.53, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_mag_out_fast.ogg") end end)
            timer.Simple(1.40, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_2.ogg") end end)
            timer.Simple(2.28, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_mag_in.ogg") end end)
            timer.Simple(2.64, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_3.ogg") end end)
            -- Болт
            timer.Simple(3.60, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_bolt_out.ogg") end end)
            timer.Simple(3.92, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_bolt_in.ogg") end end)
            timer.Simple(4.26, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_look_3.ogg") end end)
        else
            -- reload (всего 4.5 сек)
            timer.Simple(0.10, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_1.ogg") end end)
            timer.Simple(1.58, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_mag_out.ogg") end end)
            timer.Simple(2.40, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_2.ogg") end end)
            timer.Simple(3.32, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_mag_in.ogg") end end)
            timer.Simple(3.74, function() if IsValid(wep) then wep:EmitSound(path .. "ak50_gunflip_3.ogg") end end)
        end
    end
end

function SWEP:CanPrimaryAttack()
    return not (self:GetNetVar("shootgunReload", 0) > CurTime())
end

