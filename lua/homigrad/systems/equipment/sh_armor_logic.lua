function hg.GetArmorItemState(ent, armor, key, default)
	if not IsValid(ent) then return default end
	local states = SERVER and ent.armor_states or ent:GetNetVar("ArmorStates", ent.armor_states or {})
	local state = states and states[armor]
	if not state or state[key] == nil then return default end
	return state[key]
end

function hg.IsVisorLowered(ent, armor, armorData)
	return hg.GetArmorItemState(ent, armor, "lowered", armorData.defaultLowered ~= false)
end

local voiceMufflingArmor = {
	mandible_caiman = true,
	mask2 = true,
	mask4 = true,
	visor_exfil_black = true,
	visor_fast_shield = true,
	visor_heavy_trooper = true,
	visor_kolpak = true,
	visor_lshz2dtm = true,
	visor_killa = true,
	visor_maska = true,
	visor_riot = true,
	visor_rys_t = true,
	visor_sobr1 = true,
	visor_sobr2 = true,
	visor_vulkan = true,
	visor_zsh = true,
}

function hg.IsVoiceMuffled(ent)
	if not IsValid(ent) or not ent.armors then return false end
	for placement, armor in pairs(ent.armors) do
		if not voiceMufflingArmor[armor] then continue end
		local armorData = hg.armor[placement] and hg.armor[placement][armor]
		if not armorData or not armorData.toggleableVisor or hg.IsVisorLowered(ent, armor, armorData) then return true end
	end
	return false
end
local entityMeta = FindMetaTable("Entity")
function entityMeta:SyncArmor()
	if self.armors then
		self:SetNetVar("Armor", self.armors)
		self:SetNetVar("ArmorStates", table.Copy(self.armor_states or {}))
		local rag = hg.GetCurrentCharacter(self)
		if IsValid(rag) and rag:IsRagdoll() then
			rag.armors = table.Copy(self.armors)
			rag.armors_shots = table.Copy(self.armors_shots or {})
			rag.armors_health = table.Copy(self.armors_health or {})
			rag.armors_durability = table.Copy(self.armors_durability or {})
			rag.armors_regions = table.Copy(self.armors_regions or {})
			rag.armors_broken = table.Copy(self.armors_broken or {})
			rag.armors_broken_mul = table.Copy(self.armors_broken_mul or {})
			rag.armor_states = table.Copy(self.armor_states or {})
			rag:SetNetVar("Armor", self.armors)
			rag:SetNetVar("ArmorStates", table.Copy(self.armor_states or {}))
			rag:SetNetVar("HideArmorRender", self:GetNetVar("HideArmorRender", false))
		end
	end
end

local function initArmor()
	for possibleArmor, armors in pairs(hg.armor) do
		for armorkey, armorData in pairs(armors) do
			if CLIENT then language.Add(armorkey, (hg.armorNames or {})[armorkey] or armorkey) end
			if armorData.inbuilt then continue end
			
			local armor = {}
			armor.Base = "armor_base"
			armor.PrintName = CLIENT and language.GetPhrase(armorkey) or armorkey
			armor.name = armorkey
			armor.Category = "ZCity Armor"
			armor.Spawnable = true
			if armorData.Spawnable != nil then
				armor.Spawnable = false
			end
			if armorData.AdminOnly then
				armor.AdminOnly = true
			end
			armor.Model = armorData[2]
			armor.WorldModel = armorData[2]
			armor.SubMats = armorData[4]
			armor.armor = armorData
			armor.placement = armorData[1]
			armor.IconOverride = (hg.armorIcons or {})[armorkey]
			armor.PhysModel = armorData.PhysModel or nil
			armor.PhysPos = armorData.PhysPos or nil
			armor.PhysAng = armorData.PhysAng or nil
			armor.material = armorData.material or nil
			armor.skins = armorData.skins or nil
			scripted_ents.Register(armor, "ent_armor_" .. armorkey)
		end
	end
end

function hg.GetArmorPlacement(armor)
	if istable(armor) then return end
	armor = string.Replace(armor,"ent_armor_","")
	
	local found
	for i,armplc in pairs(hg.armor) do
		for i2,armor2 in pairs(armplc) do
			if i2 == armor then found = i end
		end
	end
	return found
end

local stringToNum = {
	["torso"] = 1,
	["head"] = 2,
	["face"] = 3,
}

function hg.GetArmorPlacementNum(armor)
	return stringToNum[hg.GetArmorPlacement(armor)]
end

initArmor()
hook.Add("Initialize", "init-atts", initArmor)
