
local PREFIX = "rem_timer"

util.AddNetworkString("rem_timer_start")
util.AddNetworkString("rem_timer_pause")
util.AddNetworkString("rem_timer_resume")
util.AddNetworkString("rem_timer_off")

local function IsAllowed(ply)
	if not IsValid(ply) then return true end 
	return ply:IsAdmin() or ply:IsSuperAdmin()
end

local function DenyMsg(ply)
	if IsValid(ply) then
		ply:ChatPrint("[rem_timer] Управлять таймером могут только админы/суперадмины.")
	end
end

concommand.Add(PREFIX, function(ply, cmd, args)
	if not IsAllowed(ply) then
		DenyMsg(ply)
		return
	end

	local duration = tonumber(args[1])
	if not duration then
		local msg = "[rem_timer] Usage: rem_timer <seconds> [reason] [sound.mp3]"
		if IsValid(ply) then ply:ChatPrint(msg) else print(msg) end
		return
	end

	local soundFile = nil
	local reasonParts = {}

	if #args >= 2 then
		local last = args[#args]
		local lastLower = string.lower(last)
		if string.match(lastLower, "%.mp3$") or string.match(lastLower, "%.wav$") or string.match(lastLower, "%.ogg$") then
			soundFile = last
			for i = 2, #args - 1 do
				table.insert(reasonParts, args[i])
			end
		else
			for i = 2, #args do
				table.insert(reasonParts, args[i])
			end
		end
	end

	local reason = table.concat(reasonParts, " ")
	print("[rem_timer] duration=" .. duration .. " reason='" .. reason .. "' sound=" .. tostring(soundFile) .. " by=" .. (IsValid(ply) and ply:Nick() or "console"))

	net.Start("rem_timer_start")
		net.WriteFloat(duration)
		net.WriteString(reason)
		net.WriteString(soundFile or "")
	net.Broadcast()
end, nil, "Show a countdown reminder timer for the whole server (admin/superadmin only). Usage: rem_timer <seconds> [reason] [sound file]")

concommand.Add(PREFIX .. "pause", function(ply)
	if not IsAllowed(ply) then
		DenyMsg(ply)
		return
	end
	net.Start("rem_timer_pause")
	net.Broadcast()
end, nil, "Pause the currently running rem_timer for everyone (admin/superadmin only)")

concommand.Add(PREFIX .. "resume", function(ply)
	if not IsAllowed(ply) then
		DenyMsg(ply)
		return
	end
	net.Start("rem_timer_resume")
	net.Broadcast()
end, nil, "Resume the currently paused rem_timer for everyone (admin/superadmin only)")

concommand.Add(PREFIX .. "off", function(ply)
	if not IsAllowed(ply) then
		DenyMsg(ply)
		return
	end
	net.Start("rem_timer_off")
	net.Broadcast()
end, nil, "Turn off the currently running rem_timer for everyone (admin/superadmin only)")

