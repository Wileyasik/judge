if SERVER then
    util.AddNetworkString( "drop_ammo" )

    net.Receive( "drop_ammo", function( len, ply )
        if !ply:Alive() or ply.organism.otrub or !ply.organism.canmove then return end
        local ammotype = net.ReadFloat()
        local count = net.ReadFloat()
        local pos = ply:EyePos()+ply:EyeAngles():Forward()*15
        if ply:GetAmmoCount(ammotype)-count < 0 then ply:ChatPrint(((math.random(1,100) == 100 or 1) and "I need mor booolets!!!" ) or "You don't have enogh ammo") return end
        if count < 1 then ply:ChatPrint("You can't drop zero ammo") return end
			--if not ammolistent[ammotype] then ply:ChatPrint("Invalid entitytype...") return end
			--print(game.GetAmmoName(ammotype))
		
        local AmmoEnt = ents.Create( "ent_ammo_"..string.lower( string.Replace(game.GetAmmoName(ammotype)," ", "") ) )
		if not IsValid(AmmoEnt) then
			ply:ChatPrint("Invalid entitytype...")
		else
			AmmoEnt:SetPos( pos )
			AmmoEnt:Spawn()
			AmmoEnt.AmmoCount = count
			local phys = AmmoEnt:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass((game.GetAmmoForce(ammotype) * count) / 1500)
			end
		end
        ply:SetAmmo(ply:GetAmmoCount(ammotype)-count,ammotype)
        ply:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(80,90), 1, CHAN_ITEM )
		ply.inventory.Ammo = ply:GetAmmo()
		ply:SetNetVar("Inventory",ply.inventory)
    end)
end
