hg.PhysBullet = hg.PhysBullet or {}
local PLUGIN = hg.PhysBullet
PLUGIN.NetMaxCreateBullet = 250
PLUGIN.NetMaxUpdateBullet = 300
PLUGIN.NetCDCreateBullet = 0.1
PLUGIN.NetCDUpdateBullet = 1
PLUGIN.NetCDRemoveBullet = 0.1 --; Unused

PLUGIN.PlayerNetUsage = PLUGIN.PlayerNetUsage or {}
PLUGIN.PlayerNetCreateUsage = PLUGIN.PlayerNetCreateUsage or {}

util.AddNetworkString("HG.Plugin[bullet](CreateBullet)")
util.AddNetworkString("HG.Plugin[bullet](UpdateBullet)")
util.AddNetworkString("HG.Plugin[bullet](RemoveBullet)")

function PLUGIN.NetworkWriteBulletsTable(bullet, net_table)
	for _, info in ipairs(net_table) do
		local key = info[1]
		local write = info[2]
		
		if(write(bullet[key]) == false)then
			return false
		end
	end
end

function PLUGIN.NetworkBulletUpdate(bullet, ply, forced)
	local recipients
	if ply then
		recipients = ply
	else
		recipients = RecipientFilter(true)
		recipients:AddPVS(bullet.Pos)
	end

	local targetPlayers = istable(recipients) and recipients or (recipients.GetPlayers and recipients:GetPlayers()) or {}

	for _, targetPly in ipairs(targetPlayers) do
		if not IsValid(targetPly) then continue end

		local steamID = targetPly:SteamID()
		PLUGIN.PlayerNetUsage[steamID] = PLUGIN.PlayerNetUsage[steamID] or {usage = 0, lastReset = CurTime()}
		local data = PLUGIN.PlayerNetUsage[steamID]

		if CurTime() - data.lastReset >= 1 then
			data.usage = 0
			data.lastReset = CurTime()
		end

		if not forced and data.usage >= PLUGIN.NetMaxUpdateBullet then
			continue
		end

		data.usage = data.usage + 1
	end

	net.Start("HG.Plugin[bullet](UpdateBullet)", true)
	if PLUGIN.NetworkWriteBulletsTable(bullet, PLUGIN.NetworkTableUpdate) == false then
		net.Abort()
		return false
	end

	if ply then
		net.Send(ply)
	else
		net.Send(recipients)
	end
end

function PLUGIN.NetworkBulletFull(bullet, ply, forced)
	local recipients
	if ply then
		recipients = ply
	else
		recipients = RecipientFilter(true)
		recipients:AddPVS(bullet.Pos)
	end

	local targetPlayers = istable(recipients) and recipients or (recipients.GetPlayers and recipients:GetPlayers()) or {}

	for _, targetPly in ipairs(targetPlayers) do
		if not IsValid(targetPly) then continue end

		local steamID = targetPly:SteamID()
		PLUGIN.PlayerNetCreateUsage[steamID] = PLUGIN.PlayerNetCreateUsage[steamID] or {usage = 0, lastReset = CurTime()}
		local data = PLUGIN.PlayerNetCreateUsage[steamID]

		if CurTime() - data.lastReset >= 1 then
			data.usage = 0
			data.lastReset = CurTime()
		end

		if not forced and data.usage >= PLUGIN.NetMaxCreateBullet then
			continue
		end

		data.usage = data.usage + 1
	end

	net.Start("HG.Plugin[bullet](CreateBullet)", true)
	if PLUGIN.NetworkWriteBulletsTable(bullet, PLUGIN.NetworkTableFull) == false then
		net.Abort()
		return false
	end

	if ply then
		net.Send(ply)
	else
		net.Send(recipients)
	end
end

function PLUGIN.NetworkBulletRemove(bullet, ply)
	net.Start("HG.Plugin[bullet](RemoveBullet)", true)
		PLUGIN.net_writekey(bullet.Key)
	
	if(ply)then
		net.Send(ply)
	else
		net.SendPVS(bullet.Pos)
	end
end

net.Receive("HG.Plugin[bullet](CreateBullet)", function(len, ply)
	if not IsValid(ply) then return end

	local steamID = ply:SteamID()
	PLUGIN.PlayerNetCreateUsage[steamID] = PLUGIN.PlayerNetCreateUsage[steamID] or {usage = 0, lastReset = CurTime()}
	local data = PLUGIN.PlayerNetCreateUsage[steamID]

	if CurTime() - data.lastReset >= 1 then
		data.usage = 0
		data.lastReset = CurTime()
	end

	if data.usage >= PLUGIN.NetMaxCreateBullet then return end
	data.usage = data.usage + 1

	local bullet_key = PLUGIN.net_readkey()
	local bullet = PLUGIN.BulletsTable[bullet_key]

	if bullet then
		PLUGIN.NetworkBulletFull(bullet, ply)
	end
end)

hook.Add("PlayerDisconnected", "HG_PhysBullet_CleanupNetUsage", function(ply)
	local steamID = ply:SteamID()
	PLUGIN.PlayerNetUsage[steamID] = nil
	PLUGIN.PlayerNetCreateUsage[steamID] = nil
end)