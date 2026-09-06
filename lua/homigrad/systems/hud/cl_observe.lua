local observe_state = {
	active = false,
	stage = 1,
	stage_start = 0,
	target = nil,
	data_target = nil,
	last_health = 0,
	last_hurt = 0,
	last_painadd = 0,
	was_alive = true,
	require_admire_reset = false
}
local observe_parts = {"Head", "Arms", "Torso", "Legs"}
local observe_stage_time = 4.5
local observe_text_delay = 1.8
local observe_type_speed = 28
local observe_line_color = Color(0, 0, 0, 255)
local observe_box_color = Color(0, 0, 0, 220)
local observe_text_color = Color(255, 255, 255, 255)
local observe_line_screen = 50
local observe_line_screen_up = 22
local observe_font = "ZCity_Veteran"

local observe_bone_sets = {
	Head = {
		{
			label = "Head",
			bones = {"ValveBiped.Bip01_Head1"},
			side = 1,
			offset = 4,
			fracture_keys = {"skull", "jaw"},
			dis_key = "jawdislocation",
			teeth = true,
			hitgroups = {
				[HITGROUP_HEAD] = true
			}
		}
	},
	Arms = {
		{
			label = "Left Arm",
			bones = {"ValveBiped.Bip01_L_Forearm"},
			side = -1,
			offset = 12,
			fracture_keys = {"larm"},
			dis_key = "larmdislocation",
			hitgroups = {
				[HITGROUP_LEFTARM] = true
			}
		},
		{
			label = "Right Arm",
			bones = {"ValveBiped.Bip01_R_Forearm"},
			side = 1,
			offset = 12,
			fracture_keys = {"rarm"},
			dis_key = "rarmdislocation",
			hitgroups = {
				[HITGROUP_RIGHTARM] = true
			}
		},
		{
			label = "Left Wrist",
			bones = {"ValveBiped.Bip01_L_Wrist", "ValveBiped.Bip01_L_Hand"},
			side = -1,
			offset = 8,
			fracture_keys = {"lwrist"},
			dis_key = "lwristdislocation",
			hitgroups = {
				[HITGROUP_LEFTARM] = true
			}
		},
		{
			label = "Right Wrist",
			bones = {"ValveBiped.Bip01_R_Wrist", "ValveBiped.Bip01_R_Hand"},
			side = 1,
			offset = 8,
			fracture_keys = {"rwrist"},
			dis_key = "rwristdislocation",
			hitgroups = {
				[HITGROUP_RIGHTARM] = true
			}
		}
	},
	Torso = {
		{
			label = "Torso",
			bones = {"ValveBiped.Bip01_Spine2", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Pelvis"},
			side = 1,
			offset = 12,
			fracture_keys = {"chest", "spine1", "spine2", "spine3", "pelvis", "brokenribs"},
			hitgroups = {
				[HITGROUP_CHEST] = true,
				[HITGROUP_STOMACH] = true,
				[HITGROUP_GENERIC] = true
			}
		}
	},
	Legs = {
		{
			label = "Left Leg",
			bones = {"ValveBiped.Bip01_L_Calf", "ValveBiped.Bip01_L_Thigh", "ValveBiped.Bip01_L_Foot"},
			side = -1,
			fracture_keys = {"lleg"},
			dis_key = "llegdislocation",
			hitgroups = {
				[HITGROUP_LEFTLEG] = true
			}
		},
		{
			label = "Right Leg",
			bones = {"ValveBiped.Bip01_R_Calf", "ValveBiped.Bip01_R_Thigh", "ValveBiped.Bip01_R_Foot"},
			side = 1,
			fracture_keys = {"rleg"},
			dis_key = "rlegdislocation",
			hitgroups = {
				[HITGROUP_RIGHTLEG] = true
			}
		}
	}
}

local function get_observe_target(ply, admiring)
	local fake = (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or (IsValid(ply:GetNWEntity("FakeRagdoll")) and ply:GetNWEntity("FakeRagdoll"))
	if IsValid(fake) then
		return fake, ply
	end
	local wep = ply:GetActiveWeapon()
	if IsValid(wep) and wep.CarryEnt and IsValid(wep.CarryEnt) then
		if wep.CarryEnt:IsRagdoll() then
			local owner = hg.RagdollOwner(wep.CarryEnt)
			return wep.CarryEnt, (IsValid(owner) and owner or wep.CarryEnt)
		end
		if wep.CarryEnt:IsPlayer() then
			return wep.CarryEnt, wep.CarryEnt
		end
	end
	local carry = ply:GetNetVar("carryent")
	if IsValid(carry) then
		if carry:IsRagdoll() then
			local owner = hg.RagdollOwner(carry)
			return carry, (IsValid(owner) and owner or carry)
		end
		if carry:IsPlayer() then
			if IsValid(carry.FakeRagdoll) then
				return carry.FakeRagdoll, carry
			end
			return carry, carry
		end
	end
	local tr = hg.eyeTrace(ply, 120)
	if tr and IsValid(tr.Entity) then
		local ent = tr.Entity
		if ent:IsRagdoll() then
			local owner = hg.RagdollOwner(ent)
			return ent, (IsValid(owner) and owner or ent)
		end
		if ent:IsPlayer() then
			if IsValid(ent.FakeRagdoll) then
				return ent.FakeRagdoll, ent
			end
			return ent, ent
		end
	end
	if admiring then
		return ply, ply
	end
end

local function get_hitgroup(ent, bone)
	if not bone then return end
	if not hg or not hg.bonetohitgroup then return end
	local bonename = bone
	if isnumber(bone) and IsValid(ent) then
		bonename = ent:GetBoneName(bone)
	end
	return bonename and hg.bonetohitgroup[bonename] or nil
end

local function count_wounds_for_groups(ent, wounds, groups)
	local count = 0
	if wounds then
		for i = 1, #wounds do
			local bone = wounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function count_arterial_for_groups(ent, arterialwounds, groups)
	local count = 0
	if arterialwounds then
		for i = 1, #arterialwounds do
			local bone = arterialwounds[i][4]
			local hitgroup = get_hitgroup(ent, bone)
			if hitgroup and groups[hitgroup] then
				count = count + 1
			end
		end
	end
	return count
end

local function has_fracture(org, keys)
	for i = 1, #keys do
		local key = keys[i]
		if key == "brokenribs" then
			if org.brokenribs and org.brokenribs > 0 then
				return true
			end
		else
			local v = org[key]
			if v then
				local threshold = 1
				if hg and hg.organism then
					local fake_key = hg.organism["fake_" .. key]
					if fake_key then
						threshold = fake_key
					end
				end
				if v >= threshold then
					return true
				end
			end
		end
	end
	return false
end

local function get_bleeding_label(count)
	if count <= 0 then return nil end
	if count == 1 then return "Minor bleeding" end
	if count <= 3 then return "Bleeding" end
	return "Intense bleeding"
end

local function get_bone_pos(ent, bones)
	ent:SetupBones()
	for i = 1, #bones do
		local id = ent:LookupBone(bones[i])
		if id then
			local pos = ent:GetBonePosition(id)
			if isvector(pos) then
				return pos
			end
		end
	end
	local center = ent:OBBCenter()
	if isvector(center) then
		return ent:LocalToWorld(center)
	end
end

local function build_observe_text(entry, ent)
	if not IsValid(ent) then
		return entry.label .. ": No target"
	end
	local org = ent.organism or ent.new_organism or {}
	local wounds = ent.wounds or ent:GetNetVar("wounds") or {}
	local arterialwounds = ent.arterialwounds or ent:GetNetVar("arterialwounds") or {}
	if not ent.organism and not ent.new_organism then
		return entry.label .. ": No data"
	end

	local amputated = false
	if entry.label == "Left Arm" and (org.larmamputated or org.lhandamputated or org.larmupamputated) then
		amputated = true
	elseif entry.label == "Right Arm" and (org.rarmamputated or org.rhandamputated or org.rarmupamputated) then
		amputated = true
	elseif entry.label == "Left Leg" and (org.llegamputated or org.llegupamputated) then
		amputated = true
	elseif entry.label == "Right Leg" and (org.rlegamputated or org.rlegupamputated) then
		amputated = true
	elseif entry.label == "Head" and org.headamputated then
		amputated = true
	end

	if amputated then
		return entry.label .. ": Amputated"
	end

	local fracture = has_fracture(org, entry.fracture_keys or {})
	local dislocation = entry.dis_key and (org[entry.dis_key] or false) or false
	local teethLost = entry.teeth and math.Clamp(org.teethLost or 0, 0, 32) or 0
	local woundcount = count_wounds_for_groups(ent, wounds, entry.hitgroups or {})
	local arterialcount = count_arterial_for_groups(ent, arterialwounds, entry.hitgroups or {})
	if not fracture and not dislocation and teethLost <= 0 and woundcount <= 0 and arterialcount <= 0 then
		return entry.label .. ": All fine."
	end
	local parts = {}
	if fracture then parts[#parts + 1] = "Fracture" end
	if dislocation then parts[#parts + 1] = "Dislocated" end
	if teethLost == 32 then
		parts[#parts + 1] = "No teeth"
	elseif teethLost == 1 then
		parts[#parts + 1] = "1 missing tooth"
	elseif teethLost > 1 then
		parts[#parts + 1] = teethLost .. " missing teeth"
	end
	local bleeding = get_bleeding_label(woundcount)
	if bleeding then parts[#parts + 1] = bleeding end
	if arterialcount > 0 then parts[#parts + 1] = "Arterial bleeding" end
	return entry.label .. ": " .. table.concat(parts, ", ")
end

hook.Add("HUDPaint", "mcd_admire_observe", function()
	local ply = LocalPlayer()
	if not IsValid(ply) then return end
	local alive = ply:Alive() and ply:Health() > 0 and not (ply.organism and ply.organism.alive == false) and not IsValid(ply:GetNWEntity("spect"))
	local view_ent = GetViewEntity()
	local function reset_observe(require_reset)
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		observe_state.stage = 1
		observe_state.stage_start = 0
		observe_state.last_health = 0
		observe_state.last_hurt = 0
		observe_state.last_painadd = 0
		if require_reset then
			observe_state.require_admire_reset = true
			ply.mcd_admire_local_cancel = true
			if ply:GetNWBool("mcd_admiring", false) then
				RunConsoleCommand("mcd_admire", "cancel")
			end
		end
	end
	if observe_state.was_alive and not alive then
		reset_observe(true)
	end
	if not observe_state.was_alive and alive then
		reset_observe(false)
	end
	observe_state.was_alive = alive
	if not alive then
		reset_observe(false)
		return
	end
	if view_ent ~= ply then
		reset_observe(true)
		return
	end
	local in_fake = IsValid(ply.FakeRagdoll) or IsValid(ply:GetNWEntity("FakeRagdoll")) or IsValid(ply:GetNWEntity("FakeRagdollOld")) or IsValid(ply:GetNWEntity("RagdollDeath")) or IsValid(ply.RagdollDeath)
	if in_fake then
		reset_observe(true)
		return
	end
	if not ply:OnGround() then
		reset_observe(true)
		return
	end
	local org = ply.organism or ply.new_organism
	local hurt = org and org.hurt or 0
	local painadd = org and org.painadd or 0
	if observe_state.last_painadd and painadd > observe_state.last_painadd + 0.01 then
		reset_observe(true)
		observe_state.last_painadd = painadd
		return
	end
	observe_state.last_painadd = painadd
	if observe_state.last_hurt and hurt > observe_state.last_hurt + 0.01 then
		reset_observe(true)
		observe_state.last_hurt = hurt
		return
	end
	observe_state.last_hurt = hurt
	local health = ply:Health()
	if observe_state.last_health and health < observe_state.last_health then
		reset_observe(true)
		observe_state.last_health = health
		return
	end
	observe_state.last_health = health
	local admiring = ply:GetNWBool("mcd_admiring", false)
	if observe_state.require_admire_reset then
		if admiring then return end
		observe_state.require_admire_reset = false
		ply.mcd_admire_local_cancel = false
	end
	if not admiring then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		ply.mcd_admire_local_cancel = false
		return
	end
	local draw_ent, data_ent = get_observe_target(ply, admiring)
	if not admiring and not IsValid(draw_ent) then
		observe_state.active = false
		observe_state.target = nil
		observe_state.data_target = nil
		return
	end

	if observe_state.target ~= draw_ent or not observe_state.active then
		observe_state.active = true
		observe_state.target = draw_ent
		observe_state.data_target = data_ent
		observe_state.stage = 1
		observe_state.stage_start = CurTime()
		observe_state.last_health = ply:Health()
	end

	local elapsed = CurTime() - observe_state.stage_start
	if elapsed >= observe_stage_time then
		observe_state.stage = observe_state.stage + 1
		if observe_state.stage > #observe_parts then
			observe_state.stage = 1
		end
		observe_state.stage_start = CurTime()
		elapsed = 0
	end

	local part = observe_parts[observe_state.stage]
	local entries = observe_bone_sets[part]
	if not entries or not IsValid(draw_ent) then return end
	local t = math.Clamp(elapsed / observe_stage_time, 0, 1)
	local fade = t <= 0.5 and (t * 2) or ((1 - t) * 2)
	local fade_alpha = math.Clamp(fade, 0, 1)
	if fade_alpha <= 0 then return end

	local offscreen_count = 0
	for i = 1, #entries do
		local entry = entries[i]
		local bone_pos = get_bone_pos(draw_ent, entry.bones)
		if bone_pos then
			if entry.offset and entry.offset ~= 0 then
				bone_pos = bone_pos + draw_ent:GetForward() * entry.offset
			end
			local screen = bone_pos:ToScreen()
			local is_offscreen = not screen.visible or screen.x < 0 or screen.x > ScrW() or screen.y < 0 or screen.y > ScrH()
			
			local end_x, end_y
			if is_offscreen then
				offscreen_count = offscreen_count + 1
				end_x = ScrW() * 0.5
				end_y = ScrH() - 20 - (offscreen_count * 40)
			else
				end_x = screen.x + observe_line_screen * (entry.side or 1)
				end_y = screen.y - observe_line_screen_up
				surface.SetDrawColor(observe_line_color.r, observe_line_color.g, observe_line_color.b, math.floor(255 * fade_alpha))
				surface.DrawLine(screen.x, screen.y, end_x, end_y)
			end

			local full_text
			local type_elapsed
			if elapsed < observe_text_delay then
				full_text = entry.label .. ": Observing..."
				type_elapsed = elapsed
			else
				full_text = build_observe_text(entry, observe_state.data_target or draw_ent)
				type_elapsed = elapsed - observe_text_delay
			end
			local max_chars = math.floor(type_elapsed * observe_type_speed)
			local text = string.sub(full_text, 1, math.Clamp(max_chars, 0, #full_text))

			surface.SetFont(observe_font)
			local tw, th = surface.GetTextSize(text)
			local pad = 6
			local box_w = tw + pad * 2
			local box_h = th + pad * 2
			local box_x = end_x - box_w * 0.5
			local box_y = end_y - box_h * 0.5
			draw.RoundedBox(0, box_x, box_y, box_w, box_h, Color(observe_box_color.r, observe_box_color.g, observe_box_color.b, math.floor(observe_box_color.a * fade_alpha)))
			draw.SimpleText(text, observe_font, end_x, end_y, Color(observe_text_color.r, observe_text_color.g, observe_text_color.b, math.floor(observe_text_color.a * fade_alpha)), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
	end
end)
