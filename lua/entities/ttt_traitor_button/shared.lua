ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Traitor Button"
ENT.Category = "ZCity"
ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Delay")
	self:NetworkVar("Float", 1, "NextUseTime")
	self:NetworkVar("Bool", 0, "Locked")
	self:NetworkVar("String", 0, "Description")
	self:NetworkVar("Int", 0, "UsableRange", { KeyName = "UsableRange" })
	self:NetworkVar("Int", 1, "Cost", { KeyName = "Cost" })
end

function ENT:IsUsable()
	return (not self:GetLocked()) and self:GetNextUseTime() < CurTime()
end
