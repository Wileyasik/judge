if SERVER then AddCSLuaFile() end

local netName = "hg_discord_announcement"
local timerName = "hg_discord_announcement_timer"
local discordURL = "https://discord.gg/J9eCr9xHnu"

if SERVER then
	util.AddNetworkString(netName)

	local function ScheduleAnnouncement()
		timer.Create(timerName, math.random(600, 900), 1, function()
			net.Start(netName)
			net.Broadcast()
			ScheduleAnnouncement()
		end)
	end

	timer.Remove(timerName)
	ScheduleAnnouncement()

	concommand.Add("hg_test_discord_announcement", function(ply)
		if not IsValid(ply) or not ply:IsAdmin() then return end

		net.Start(netName)
		net.Send(ply)
	end)
else
	net.Receive(netName, function()
		chat.AddText(
			Color(83, 83, 83),
			"[Judge] ",
			color_white,
			"Join our discord community server:\n",
			discordURL
		)
	end)
end
