SWEP.Base = "weapon_ptrd"
SWEP.Spawnable = true
SWEP.AdminOnly = true
SWEP.PrintName = "PTRD-41 Fun Auto"
SWEP.Category = "Weapons - Sniper Rifles"
SWEP.holsteredBone = "ValveBiped.Bip01_Spine2"
SWEP.holsteredPos = Vector(4, 6, -6)
SWEP.holsteredAng = Angle(220, 0, 180)

SWEP.WepSelectIcon2 = Material("vgui/wep_jack_hmcd_ptrd")
SWEP.IconOverride = "vgui/wep_jack_hmcd_ptrd"

SWEP.Primary.Wait = 0.15
SWEP.Primary.ClipSize = 1000
SWEP.Primary.DefaultClip = 1000
SWEP.Primary.Automatic = true
SWEP.AutomaticDraw = true

function SWEP:PrimaryShootPost()
	if CLIENT then return end
	if self:IsResting() then return end

	local owner = self:GetOwner()
	local char = hg.GetCurrentCharacter(owner)
	if not char:IsRagdoll() then
		hg.AddForceRag(owner, 2, owner:EyeAngles():Forward() * -10000, 0.5)
		hg.AddForceRag(owner, 0, owner:EyeAngles():Forward() * -10000, 0.5)

		hg.LightStunPlayer(owner,1)
	end
	
	char:GetPhysicsObjectNum(0):SetVelocity(char:GetVelocity() + owner:EyeAngles():Forward() * -1000)
end
