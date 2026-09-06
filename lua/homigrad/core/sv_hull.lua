if SERVER then
	util.AddNetworkString("SyncHullSize")

	local function SetHullSize(ply)
		if IsValid(ply) then
			ply:SetHull(Vector(-8, -8, 0), Vector(8, 8, 72))
			ply:SetHullDuck(Vector(-8, -8, 0), Vector(8, 8, 36))

			net.Start("SyncHullSize")
			net.WriteEntity(ply)
			net.Send(ply)
		end
	end

	hook.Add("PlayerInitialSpawn", "Server_SetHull_Initial", function(ply)
		timer.Simple(2, function()
			SetHullSize(ply)
		end)
	end)

	hook.Add("PlayerSpawn", "Server_SetHull", function(ply)
		timer.Simple(0.1, function()
			SetHullSize(ply)
		end)
	end)
end

if CLIENT then
	net.Receive("SyncHullSize", function()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			ply:SetHull(Vector(-8, -8, 0), Vector(8, 8, 72))
			ply:SetHullDuck(Vector(-8, -8, 0), Vector(8, 8, 36))
		end
	end)
end
