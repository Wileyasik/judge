AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.RemoveOnPress = false
ENT.Model = Model("models/weapons/w_bugbait.mdl")

local function IsTraitorPlayer(ply)
	if not IsValid(ply) then return false end
	if ply.isTraitor then return true end
	if ply.roleT then return true end
	if ply.IsActiveTraitor and ply:IsActiveTraitor() then return true end
	return false
end

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetNoDraw(true)
	self:DrawShadow(false)
	self:SetSolid(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)

	self:SetDelay(self.RawDelay or 1)

	if self:GetDelay() < 0 then
		self.RemoveOnPress = true
	end

	if self.RemoveOnPress then
		self:SetDelay(-1)
	end

	if self:GetUsableRange() < 1 then
		self:SetUsableRange(1024)
	end

	local defaultCost = 5
	local costConvar = GetConVar("ttt_activator_default_cost")
	if costConvar then defaultCost = costConvar:GetInt() end
	self:SetCost(self.RawCost ~= nil and self.RawCost or defaultCost)
	self:SetNextUseTime(0)
	self:SetLocked(self:HasSpawnFlags(2048))
	self:SetDescription(self.RawDescription or "Trap")

	self.RawDelay = nil
	self.RawCost = nil
	self.RawDescription = nil
end

function ENT:KeyValue(key, value)
	key = string.lower(key)
	if key == "onpressed" then
		self:StoreOutput("OnPressed", value)
	elseif key == "wait" then
		self.RawDelay = tonumber(value)
	elseif key == "cost" then
		self.RawCost = tonumber(value)
	elseif key == "description" then
		self.RawDescription = tostring(value)
		if #self.RawDescription < 1 then
			self.RawDescription = nil
		end
	elseif key == "removeonpress" then
		self.RemoveOnPress = tobool(value)
	else
		self:SetNetworkKeyValue(key, value)
	end
end

function ENT:AcceptInput(name, activator)
	if name == "Toggle" then
		self:SetLocked(not self:GetLocked())
		return true
	elseif name == "Hide" or name == "Lock" then
		self:SetLocked(true)
		return true
	elseif name == "Unhide" or name == "Unlock" then
		self:SetLocked(false)
		return true
	end
end

function ENT:TraitorUse(ply)
	if not IsTraitorPlayer(ply) then return false end
	if not ZCityActivator or not ZCityActivator.TryUseTrap then return false end

	local ok, reason = ZCityActivator.TryUseTrap(ply, self)
	if ok and util.NetworkStringToID("TTT_ConfirmUseTButton") ~= 0 then
		net.Start("TTT_ConfirmUseTButton")
		net.Send(ply)
	end
	return ok, reason
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

local function TraitorUseCmd(ply, _, args)
	if #args ~= 1 or not IsValid(ply) or not IsTraitorPlayer(ply) then return end

	local idx = tonumber(args[1])
	if not idx then return end

	local ent = Entity(idx)
	if IsValid(ent) and ent:GetClass() == "ttt_traitor_button" and ent.TraitorUse then
		ent:TraitorUse(ply)
	end
end

concommand.Add("ttt_use_tbutton", TraitorUseCmd)
