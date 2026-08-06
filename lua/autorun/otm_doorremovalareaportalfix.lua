if (CLIENT) then return end;
local otm_tempdoortypeslist = {["func_door"] = true,["func_door_rotating"] = true, ["prop_door_rotating"] = true,["func_movelinear"] = true};

local otm_ismapbeingcleanedup_for_areaportaldooraddon = false;
//hook.Add("PreCleanupMap","otm_door_removal_pairedareaportal_cleanup_variable_1",function() otm_ismapbeingcleanedup_for_areaportaldooraddon = true end);
//hook.Add("PostCleanupMap","otm_door_removal_pairedareaportal_cleanup_variable_2",function() otm_ismapbeingcleanedup_for_areaportaldooraddon = false end);



local meta = FindMetaTable("Entity");
meta.otmsetnodraworiginalcopyjank = meta.SetNoDraw;

function meta:DefaultSetNoDraw(b)
	self:otmsetnodraworiginalcopyjank(b)
end

function meta:SetNoDraw(b)
	if !b and (self:GetClass() == "prop_door_rotating") then
		for _, otm_i in ipairs(ents.FindByClass("func_areaportal")) do
			if (otm_i:GetInternalVariable("target") == self:GetName()) then
				otm_i:Fire("Open");
				break;
			end
		end
	end
	self:otmsetnodraworiginalcopyjank(b);
end



hook.Add("EntityRemoved","otm_door_removal_pairedareaportal_activation",function(ent,clh)
	
	if (!otm_ismapbeingcleanedup_for_areaportaldooraddon) then
		//Check if the entity being removed is a linkable door.
		if otm_tempdoortypeslist[ent:GetClass()] then
			//if it is, loop through the list of func_areaportal's and see if it shares the id of a currently-linked door.
			//Not the best to link performance to areaportal count like this, perhaps doors could be given a link as well, but let's just see if this is good.
			//Okay, since the areaportal has its target removed once found, we can safely break the for-loop once the match is found, a little better. 
			if (ent:GetName() ~= "") then
				for _, otm_i in ipairs(ents.FindByClass("func_areaportal")) do
					//Check each func_areaportal's "target" internal variable and if it matches the removed door, turn it on and set target to "" in case of double doors.
					//print("yikes")
					if (otm_i:GetInternalVariable("target") == ent:GetName()) then
						//print("Areaportal match has been found.")
						otm_i:Fire("Open");
						otm_i:SetSaveValue("target","");
						break;
					end
				end
			end
		end
	end
end)
