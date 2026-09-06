local npcs = {
	["npc_strider"] = {multi = 5, snd = "npc/strider/strider_minigun.wav", force = 5, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10, noricochet = true},
	["npc_combinegunship"] = {multi = 5, snd = "npc/strider/strider_minigun.wav", force = 3, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10},
	["npc_helicopter"] = {multi = 4, force = 2, AmmoType = "14.5x114mm BZTM", PenetrationMul = 10},
	["lunasflightschool_ah6"] = {multi = 20, AmmoType = "14.5x114mm BZTM"},
	["npc_turret_floor"] = {multi = 1.25, AmmoType = "9x19 mm Parabellum"},
	["npc_sniper"] = {multi = 3, AmmoType = "14.5x114mm BZTM", PenetrationMul = 4},
	["npc_hunter"] = {multi = 4, AmmoType = "12/70 RIP", PenetrationMul = 1},
	["npc_turret_ceiling"] = {multi = 1.25, AmmoType = "9x19 mm QuakeMaker"},
}

hook.Add("EntityFireBullets", "NPC_Boolets", function(ent, bullet)
	if IsValid(ent) and npcs[ent:GetClass()] and not bullet.NpcShoot then
		local tbl = npcs[ent:GetClass()]
		if ent:GetClass() == "npc_turret_floor" and IsValid(ent:GetEnemy()) and ent:GetEnemy():GetClass() == "npc_bullseye" and IsValid(ent:GetEnemy().rag) then
			bullet.Dir = (ent:GetEnemy().rag:GetBonePosition(ent:GetEnemy().rag:LookupBone("ValveBiped.Bip01_Spine1")) + VectorRand(-20, 20) - bullet.Src):GetNormalized()
		end
		bullet.AmmoType = tbl.AmmoType or bullet.AmmoType
		if bullet.AmmoType then
			bullet.Damage = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Damage or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType)))
			bullet.Force = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Force or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType))) * (npcs[ent:GetClass()].force or 1)
			bullet.Penetration = (hg.ammotypeshuy[bullet.AmmoType] and hg.ammotypeshuy[bullet.AmmoType].BulletSettings.Penetration or game.GetAmmoPlayerDamage(game.GetAmmoID(bullet.AmmoType))) * (npcs[ent:GetClass()].PenetrationMul or 1)
		end
		bullet.Filter = {ent}
		bullet.Attacker = ent
		bullet.penetrated = 0
		bullet.noricochet = tbl.noricochet
		ent.weapon = ent

		bullet.IgnoreEntity = ent

		bullet.Filter = {ent}
		bullet.Inflictor = ent

		if (!GetGlobalBool("PhysBullets_ReplaceDefault", false)) and not bullet.NpcShoot then
			local oldcallback = bullet.Callback
			function bullet.Callback(i1, i2, i3)
				hg.bulletHit(i1, i2, i3, bullet, ent)
			end

			if npcs[ent:GetClass()].snd then
				ent:EmitSound(tbl.snd, 85, 100, 1, CHAN_AUTO)
			end

			bullet.NpcShoot = true
			ent:FireLuaBullets(bullet)
			bullet.Damage = 0
			bullet.Callback = oldcallback
			return true
		end
	end
end)
