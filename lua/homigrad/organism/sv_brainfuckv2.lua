hg = hg or {}

local disabledHooks = {
	{"Should Fake Up", "BrainfuckFencing"},
	{"Fake", "BrainfuckFencing"},
	{"HG_OnOtrub", "BrainfuckFencing"},
	{"RagdollDeath", "BrainfuckStart"},
	{"Org Clear", "BrainfuckClear"},
	{"HomigradDamage", "DecorticateTrigger"},
	{"HomigradDamage", "BrainfuckFencing"},
	{"EntityTakeDamage", "BrainfuckRagdollDamage"},
	{"CanControlFake", "BrainfuckFencing"},
	{"Org Think", "BrainfuckThink"},
	{"Org Clear", "BrainfuckV2"},
	{"Should Fake Up", "BrainfuckV2"},
	{"CanControlFake", "BrainfuckV2"},
	{"Org Think", "BrainfuckV2"},
	{"RagdollDeath", "BrainfuckV2"}
}

for i = 1, #disabledHooks do
	local hookData = disabledHooks[i]
	hook.Remove(hookData[1], hookData[2])
end

hg.applyFencingToPlayer = nil
hg.applyDecorticateToPlayer = nil
hg.applyLazarusToPlayer = nil
hg.applyCushingToPlayer = nil
hg.applySeizurePostureToRagdoll = nil
hg.getRandomSpasm = nil
hg.applySpasm = nil
hg.brainfuckv2 = {
	postures = {
		decorticate = {
			threshold = 0.12,
			priority = 1,
			variants = {
				[1] = {
					reference = 0,
					male09 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, 0.000, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-8.504, -56.693, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-22.677, -62.362, 8.504)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(53.858, -170.079, -62.362)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(161.575, 124.724, -36.850)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-68.031, -180.000, 25.512)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(-8.504, -42.520, -161.575)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 14.173, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 59.528, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 51.024, 0.000)}
					},
					female06 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, 0.000, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-8.504, -56.693, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-22.677, -62.362, 8.504)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(53.858, -170.079, -62.362)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(161.575, 124.724, -36.850)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-68.031, -180.000, 25.512)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(-8.504, -42.520, -161.575)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 14.173, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 59.528, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 51.024, 0.000)}
					}
				},
				[2] = {
					reference = 0,
					male09 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -8.504, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-25.512, -19.843, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(22.677, -19.843, 0.000)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(14.173, -104.882, -8.504)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-172.913, 8.504, -76.535)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-14.173, -99.213, -31.181)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(11.339, -102.047, -99.213)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 11.339, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 15.000, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 15.000, 0.000)}
					},
					female06 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -8.504, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-25.512, -19.843, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(22.677, -19.843, 0.000)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(14.173, -104.882, -8.504)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-172.913, 8.504, -76.535)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-14.173, -99.213, -31.181)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(11.339, -102.047, -99.213)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 11.339, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 15.000, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 15.000, 0.000)}
					}
				},
			},
			fix = {
				male09 = {
					[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -11.339, 0.000)},
					[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(17.008, -70.866, 0.000)},
					[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-14.173, -42.520, 0.000)},
					[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(-59.528, -127.559, 0.000)},
					[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-17.008, 180.000, -180.000)},
					[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(99.213, 28.346, 130.394)},
					[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(0.000, 158.740, 180.000)},
					[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
					[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
					[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, -25.512, 0.000)},
					[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
					[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
					[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 0.000, 0.000)},
					[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 0.000, 0.000)}
				},
				female06 = {
					[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -11.339, 0.000)},
					[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(17.008, -70.866, 0.000)},
					[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(-14.173, -42.520, 0.000)},
					[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(-59.528, -127.559, 0.000)},
					[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(-17.008, 180.000, -180.000)},
					[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(99.213, 28.346, 130.394)},
					[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(0.000, 158.740, 180.000)},
					[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
					[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
					[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, -25.512, 0.000)},
					[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
					[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
					[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 0.000, 0.000)},
					[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 0.000, 0.000)}
				}
			}
		},
		decerebrate = {
			threshold = 0.45,
			priority = 2,
			variants = {
				[1] = {
					reference = 0,
					male09 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -14.173, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-25.512, -53.858, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(25.512, -36.850, 0.000)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(39.685, -45.354, 0.000)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(48.189, -19.843, 51.024)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-34.016, -28.346, 0.000)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(-25.512, -59.528, -85.039)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 17.008, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(15.000, 15.000, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(-15.000, 15.000, 0.000)}
					},
					female06 = {
						[1] = {bone = "ValveBiped.Bip01_Spine2", ang = Angle(0.000, -14.173, 0.000)},
						[2] = {bone = "ValveBiped.Bip01_R_UpperArm", ang = Angle(-25.512, -31.181, 0.000)},
						[3] = {bone = "ValveBiped.Bip01_L_UpperArm", ang = Angle(14.173, -36.850, 0.000)},
						[4] = {bone = "ValveBiped.Bip01_L_Forearm", ang = Angle(39.685, -56.693, 0.000)},
						[5] = {bone = "ValveBiped.Bip01_L_Hand", ang = Angle(48.189, -17.008, 51.024)},
						[6] = {bone = "ValveBiped.Bip01_R_Forearm", ang = Angle(-17.008, -48.189, 0.000)},
						[7] = {bone = "ValveBiped.Bip01_R_Hand", ang = Angle(-25.512, -59.528, -85.039)},
						[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[10] = {bone = "ValveBiped.Bip01_Head1", ang = Angle(0.000, 17.008, 0.000)},
						[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, 0.000, 0.000)},
						[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 0.000, 0.000)},
						[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(15.000, 15.000, 0.000)},
						[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(-15.000, 15.000, 0.000)}
					}
				}
			},
			fallback = "decorticate"
		}
	},
	legVariants = {
		[1] = {
			male09 = {
				[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, -82.205, 0.000)},
				[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(-2.835, 17.008, 0.000)},
				[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(-5.669, -82.205, -22.677)},
				[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 11.339, 0.000)},
				[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 36.850, -28.346)},
				[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 25.512, 0.000)}
			},
			female06 = {
				[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(0.000, -82.205, 0.000)},
				[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(-2.835, 17.008, 0.000)},
				[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(-5.669, -82.205, -22.677)},
				[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 11.339, 0.000)},
				[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(0.000, 36.850, -28.346)},
				[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 25.512, 0.000)}
			}
		},
		[2] = {
			male09 = {
				[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(-5.669, -53.858, 34.016)},
				[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(-5.669, 79.370, 0.000)},
				[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, -65.197, 0.000)},
				[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 68.031, 0.000)},
				[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(36.850, 116.220, 0.000)},
				[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 65.197, 0.000)}
			},
			female06 = {
				[8] = {bone = "ValveBiped.Bip01_R_Thigh", ang = Angle(-5.669, -53.858, 34.016)},
				[9] = {bone = "ValveBiped.Bip01_R_Calf", ang = Angle(-5.669, 79.370, 0.000)},
				[11] = {bone = "ValveBiped.Bip01_L_Thigh", ang = Angle(0.000, -65.197, 0.000)},
				[12] = {bone = "ValveBiped.Bip01_L_Calf", ang = Angle(0.000, 68.031, 0.000)},
				[13] = {bone = "ValveBiped.Bip01_L_Foot", ang = Angle(36.850, 116.220, 0.000)},
				[14] = {bone = "ValveBiped.Bip01_R_Foot", ang = Angle(0.000, 65.197, 0.000)}
			}
		}
	},
	triggers = {
		brain_damage = {
			threshold = 0.12,
			get = function(org)
				return math.Clamp(org.brain or 0, 0, 1)
			end
		}
	}
}

local function hasPosture(data)
	if not istable(data) then return false end
	if data.taser then return true end
	if istable(data.variants) then return next(data.variants) ~= nil end
	return istable(data.offsets) and next(data.offsets) ~= nil
end

function hg.brainfuckv2.GetPosture(name)
	local checked = {}
	local data

	while name and not checked[name] do
		checked[name] = true
		data = hg.brainfuckv2.postures[name]
		if hasPosture(data) then return data, name end
		name = data and data.fallback
	end
end

local function getRequestedPosture(severity)
	local selected
	local selectedData

	for name, data in pairs(hg.brainfuckv2.postures) do
		if severity >= (data.threshold or 0) and (not selectedData or data.priority > selectedData.priority or data.priority == selectedData.priority and name < selected) then
			selected = name
			selectedData = data
		end
	end

	return selected
end

local function getPostureState(org)
	local selected
	local selectedSeverity
	local selectedData

	for _, trigger in pairs(hg.brainfuckv2.triggers) do
		local severity = trigger.get(org)
		if not isnumber(severity) or severity < (trigger.threshold or 0) then continue end

		local requested = trigger.posture or getRequestedPosture(severity)
		local data, posture = hg.brainfuckv2.GetPosture(requested)
		local requestedData = requested and hg.brainfuckv2.postures[requested]
		if data and requestedData and (not selectedData or requestedData.priority > selectedData.priority or requestedData.priority == selectedData.priority and severity > selectedSeverity) then
			selected = posture
			selectedSeverity = severity
			selectedData = requestedData
		end
	end

	if selected == "decerebrate" then
		local latched = org.brainfuckv2Severe
		if latched ~= "decerebrate" and latched ~= "decorticate" then
			latched = math.Rand(0, 1) < 0.5 and "decorticate" or "decerebrate"
			org.brainfuckv2Severe = latched
		end
		selected = latched
	else
		org.brainfuckv2Severe = nil
	end

	if selected == nil then
		org.brainfuckv2Allowed = nil
	else
		if org.brainfuckv2Allowed == nil then
			org.brainfuckv2Allowed = math.Rand(0, 1) < (postureChance or 0.85)
		end
		if not org.brainfuckv2Allowed then
			selected = nil
			selectedSeverity = nil
		end
	end

	return selected, selectedSeverity
end

local function getRagdoll(owner, org)
	if IsValid(owner) and owner:IsPlayer() then
		local rag = owner.FakeRagdoll
		if IsValid(rag) then return rag end

		rag = owner:GetNWEntity("RagdollDeath")
		if IsValid(rag) then return rag end
	end

	if IsValid(owner) and owner:IsRagdoll() then return owner end
	if org and IsValid(org.owner) and org.owner:IsRagdoll() then return org.owner end
end

local function getOffsets(data, org)
	local variants = data.variants
	local variant = org and org.brainfuckv2Variant or 1
	if variants then return variants[variant] or variants[1] end
	return data.offsets
end

local shadowParams = {}
local brainfuckv2Rev = 10
local poseFadeTime = 8
local taserPhaseTime = 0.5
local skipChance = 0.25
local flopChance = 0.25
local flopSpeed = 55
local postureChance = 0.85
local legChance = 0.3
local slowTime = 3
local legBones = {[8] = true, [9] = true, [11] = true, [12] = true, [13] = true, [14] = true}
local taserBones = {2, 3, 4, 5, 6, 7, 8, 9, 11, 12}

local function dbgPrint(msg)
	local dev = GetConVar("developer")
	if not dev or dev:GetInt() < 1 then return end
	if not ConVarExists("hg_developer") then return end
	local hgdev = GetConVar("hg_developer")
	if hgdev and hgdev:GetBool() then print(msg) end
end

local function printPose(rag, posture, phase, fade, mul)
	if (rag.brainfuckv2NextPrint or 0) > CurTime() then return end
	rag.brainfuckv2NextPrint = CurTime() + 2
	dbgPrint("[BrainfuckV2] apply " .. tostring(posture) .. " " .. phase .. " fade " .. math.Round(fade * 100) .. " mul " .. math.Round(mul))
end

local function driveBone(rag, phys, physBone, targetAng, mul, damp, brake, ss)
	local pos = vector_origin
	local maxspeed = 0
	local maxspeeddamp = 0
	if brake then
		pos = phys:GetPos()
		maxspeed = brake[1]
		maxspeeddamp = brake[2]
	end
	if hg.ShadowControl then
		hg.ShadowControl(rag, physBone, ss, targetAng, mul, damp, pos, maxspeed, maxspeeddamp)
		return
	end
	shadowParams.secondstoarrive = ss
	shadowParams.angle = targetAng
	shadowParams.maxangular = mul * (rag.power or 1)
	shadowParams.maxangulardamp = damp
	shadowParams.pos = pos
	shadowParams.maxspeed = maxspeed
	shadowParams.maxspeeddamp = maxspeeddamp
	shadowParams.dampfactor = 0.9
	phys:Wake()
	phys:ComputeShadowControl(shadowParams)
end

local function driveTaser(rag, skip, legs, referenceAng, mul, damp, brake, ss)
	local spine = rag:GetPhysicsObjectNum(hg.realPhysNum and hg.realPhysNum(rag, 1) or 1)
	if not IsValid(spine) then return end
	local ang = spine:GetAngles()
	ang:Add(AngleRand(-5, 5))
	ang:RotateAroundAxis(ang:Up(), 180)
	for i = 1, #taserBones do
		local physBone = taserBones[i]
		if skip[physBone] then continue end
		local realPhysBone = hg.realPhysNum and hg.realPhysNum(rag, physBone) or physBone
		local phys = rag:GetPhysicsObjectNum(realPhysBone)
		if not IsValid(phys) then continue end
		local targetAng = ang
		local legOffset = legs and legBones[physBone] and legs[physBone]
		if legOffset and legOffset.ang then
			local base = (rag.brainfuckv2Base or {})[physBone]
			if base then
				local _, localAng = LocalToWorld(vector_origin, legOffset.ang, vector_origin, base)
				_, targetAng = LocalToWorld(vector_origin, localAng, vector_origin, referenceAng)
			end
		end
		driveBone(rag, phys, physBone, targetAng, mul, damp, brake, ss)
	end
end

local function driveStatic(rag, skip, modelOffsets, legs, referenceAng, mul, damp, brake, ss)
	local baseTbl = rag.brainfuckv2Base or {}
	local worst = 0
	for physBone, offset in pairs(modelOffsets) do
		if not offset.ang then continue end
		if skip[physBone] then continue end
		if legs and legBones[physBone] then
			local legOffset = legs[physBone]
			if legOffset and legOffset.ang then offset = legOffset end
		end
		local base = baseTbl[physBone]
		if not base then continue end
		local realPhysBone = hg.realPhysNum and hg.realPhysNum(rag, physBone) or physBone
		local phys = rag:GetPhysicsObjectNum(realPhysBone)
		if not IsValid(phys) then continue end
		local _, localAng = LocalToWorld(vector_origin, offset.ang, vector_origin, base)
		local _, targetAng = LocalToWorld(vector_origin, localAng, vector_origin, referenceAng)
		local cur = phys:GetAngles()
		local err = math.abs(targetAng.p - cur.p) + math.abs(((targetAng.y - cur.y + 180) % 360) - 180) + math.abs(targetAng.r - cur.r)
		if err > worst then worst = err end
		driveBone(rag, phys, physBone, targetAng, mul, damp, brake, ss)
	end
	return worst
end

local function getNeutralBase(rag)
	hg.brainfuckv2.neutralBase = hg.brainfuckv2.neutralBase or {}
	local model = string.lower(rag:GetModel() or "")
	local cached = hg.brainfuckv2.neutralBase[model]
	if istable(cached) then return cached end
	local probe = ents.Create("prop_ragdoll")
	if not IsValid(probe) then return nil end
	probe:SetModel(rag:GetModel())
	probe:SetPos(rag:GetPos())
	probe:Spawn()
	local refProbe = probe:GetPhysicsObjectNum(hg.realPhysNum and hg.realPhysNum(probe, 0) or 0)
	if not IsValid(refProbe) then probe:Remove() return nil end
	local refAng = refProbe:GetAngles()
	local neutral = {}
	for physBone = 1, 14 do
		local realPhysBone = hg.realPhysNum and hg.realPhysNum(probe, physBone) or physBone
		local phys = probe:GetPhysicsObjectNum(realPhysBone)
		if not IsValid(phys) then continue end
		local _, base = WorldToLocal(vector_origin, phys:GetAngles(), vector_origin, refAng)
		neutral[physBone] = base
	end
	probe:Remove()
	hg.brainfuckv2.neutralBase[model] = neutral
	return neutral
end

local function getLegOffsets(rag, female)
	local idx = rag.brainfuckv2Legs
	local variants = hg.brainfuckv2.legVariants
	local variant = idx and variants and variants[idx]
	if not variant then return nil end
	return female and variant.female06 or variant.male09
end

local function applyPosture(rag, posture)
	if not IsValid(rag) then return end

	local data = hg.brainfuckv2.postures[posture]
	if not data then return end

	local org = rag.organism or {}
	local referenceNumber = hg.realPhysNum and hg.realPhysNum(rag, 0) or 0
	local reference = rag:GetPhysicsObjectNum(referenceNumber)
	if not IsValid(reference) then return end

	local start = rag.brainfuckv2PoseStart
	local skip = rag.brainfuckv2Skip
	if not start or not istable(skip) then
		start = CurTime()
		rag.brainfuckv2PoseStart = start
		skip = {}
		local skipped = {}
		for i = 1, 14 do
			if math.Rand(0, 1) < (skipChance or 0.25) then
				skip[i] = true
				skipped[#skipped + 1] = i
			end
		end
		rag.brainfuckv2Skip = skip
		local flop = math.Rand(0, 1) < (flopChance or 0.35)
		rag.brainfuckv2Flop = flop
		if flop then
			for i = 0, rag:GetPhysicsObjectCount() - 1 do
				local phys = rag:GetPhysicsObjectNum(i)
				if IsValid(phys) then phys:AddVelocity(Vector(0, 0, -flopSpeed)) end
			end
		end
		local legCount = hg.brainfuckv2.legVariants and #hg.brainfuckv2.legVariants or 0
		if legCount > 0 and math.Rand(0, 1) < (legChance or 0.3) then
			rag.brainfuckv2Legs = math.random(1, legCount)
		else
			rag.brainfuckv2Legs = nil
		end
		rag.brainfuckv2Base = getNeutralBase(rag)
		if not istable(rag.brainfuckv2Base) then
			rag.brainfuckv2Base = {}
			local initPos = reference:GetPos()
			local initAng = reference:GetAngles()
			for physBone = 1, 14 do
				local realPhysBone = hg.realPhysNum and hg.realPhysNum(rag, physBone) or physBone
				local phys = rag:GetPhysicsObjectNum(realPhysBone)
				if not IsValid(phys) then continue end
				local _, base = WorldToLocal(vector_origin, phys:GetAngles(), initPos, initAng)
				rag.brainfuckv2Base[physBone] = base
			end
		end
		rag.brainfuckv2RefAng = reference:GetAngles()
	end

	local elapsed = CurTime() - start
	local pulseMul = 1500
	local damp = 50
	local brake = nil
	local brakeOwner = org.owner
	if (org.brainfuckv2SlowUntil or 0) > CurTime() and not rag.brainfuckv2Flop and IsValid(brakeOwner) and brakeOwner:IsPlayer() and brakeOwner:Alive() then
		brake = data.taser and {160, 25} or {40, 60}
	end

	local fade = math.Clamp(1 - elapsed / poseFadeTime, 0, 1)
	if elapsed > poseFadeTime + 10 then return end
	if (rag.brainfuckv2PoseError or 0) > 25 then fade = math.max(fade, 0.4) end
	if fade <= 0 then return end

	local dampNow = 10 + 40 * fade
	local ssNow = 0.001 + (1 - fade) * 0.4

	local female = string.find(string.lower(rag:GetModel() or ""), "female", 1, true) ~= nil
	local legs = getLegOffsets(rag, female)

	local fixData = data.fix
	if not fixData and data.taser then
		local decorticate = hg.brainfuckv2.postures.decorticate
		fixData = decorticate and decorticate.fix
	end

	if elapsed < taserPhaseTime and fixData then
		local fixOffsets = female and fixData.female06 or fixData.male09
		if fixOffsets then
			rag.brainfuckv2PoseError = driveStatic(rag, skip, fixOffsets, legs, rag.brainfuckv2RefAng or reference:GetAngles(), pulseMul * fade, dampNow, brake, ssNow)
			return
		end
	end

	if data.taser then
		rag.brainfuckv2PoseError = 0
		driveTaser(rag, skip, legs, reference:GetAngles(), pulseMul * fade, dampNow, brake, ssNow)
		return
	end

	local offsets = getOffsets(data, org)
	if not offsets then return end

	local modelOffsets = female and offsets.female06 or offsets.male09
	if not modelOffsets then return end

	rag.brainfuckv2PoseError = driveStatic(rag, skip, modelOffsets, legs, reference:GetAngles(), pulseMul * fade, dampNow, brake, ssNow)
end

local function setPosture(org, posture, severity, rag)
	local oldPosture = org.brainfuckv2Posture
	local lastSeverity = org.brainfuckv2LastSeverity or 0
	if oldPosture ~= posture then
		org.brainfuckv2Posture = posture
		org.brainfuckv2Severity = severity
		local data = posture and hg.brainfuckv2.postures[posture]
		org.brainfuckv2Variant = data and data.variants and math.max(#data.variants, 1) > 1 and math.random(#data.variants) or 1
		if IsValid(rag) then
			local smooth = (oldPosture == "decorticate" and posture == "decerebrate") or (oldPosture == "decerebrate" and posture == "decorticate")
			if smooth then
				rag.brainfuckv2PoseStart = CurTime() - poseFadeTime * 0.4
			else
				rag.brainfuckv2Base = nil
				rag.brainfuckv2PoseStart = nil
				rag.brainfuckv2Skip = nil
				rag.brainfuckv2Flop = nil
				rag.brainfuckv2Legs = nil
			end
		end
	elseif posture then
		org.brainfuckv2Severity = severity
		if (severity or 0) - lastSeverity > 0.15 and IsValid(rag) then
			rag.brainfuckv2Base = nil
			rag.brainfuckv2PoseStart = nil
			rag.brainfuckv2Skip = nil
			rag.brainfuckv2Flop = nil
			rag.brainfuckv2Legs = nil
		end
	end

	if posture then
		org.brainfuckv2LastSeverity = severity
	else
		org.brainfuckv2LastSeverity = nil
	end

	if posture and IsValid(rag) then
		rag.organism = rag.organism or org
		applyPosture(rag, posture)
	end
end

local function forceFake(ply, org)
	if not IsValid(ply) or not ply:IsPlayer() or not ply:Alive() or IsValid(ply.FakeRagdoll) or ply:InVehicle() then return end

	local time = CurTime()
	if (org.brainfuckv2NextFake or 0) > time then return end
	org.brainfuckv2NextFake = time + 1

	timer.Simple(0, function()
		if not IsValid(ply) or ply.organism ~= org or not ply:Alive() or IsValid(ply.FakeRagdoll) or not org.brainfuckv2Posture then return end
		dbgPrint("[BrainfuckV2] forcefake " .. tostring(ply))
		if hg.Fake then hg.Fake(ply, nil, true) end
	end)
end

hook.Add("Org Clear", "BrainfuckV2", function(org)
	if not org then return end

	org.brainfuckv2Posture = nil
	org.brainfuckv2Severity = nil
	org.brainfuckv2Variant = nil
	org.brainfuckv2NextFake = nil
	org.brainfuckv2SlowUntil = nil
	org.brainfuckv2Severe = nil
	org.brainfuckv2LastSeverity = nil
	org.brainfuckv2Allowed = nil
end)

hook.Add("Should Fake Up", "BrainfuckV2", function(ply)
	local org = IsValid(ply) and ply.organism
	if org and org.brainfuckv2Posture then return false end
end)

hook.Add("CanControlFake", "BrainfuckV2", function(ply, rag)
	local org = IsValid(rag) and rag.organism or IsValid(ply) and ply.organism
	if org and org.brainfuckv2Posture then return false end
end)

hook.Add("Org Think", "BrainfuckV2", function(owner, org)
	if not IsValid(owner) or not org then return end

	local posture, severity = getPostureState(org)
	local rag = getRagdoll(owner, org)
	if posture or (org.brain or 0) > 0 then
		dbgPrint("[BrainfuckV2] think " .. tostring(owner) .. " brain " .. tostring(org.brain) .. " posture " .. tostring(posture) .. " severity " .. tostring(severity) .. " ragvalid " .. tostring(IsValid(rag)))
	end
	setPosture(org, posture, severity, rag)

	if posture and owner:IsPlayer() and owner:Alive() and not IsValid(rag) then
		org.brainfuckv2SlowUntil = CurTime() + slowTime
		forceFake(owner, org)
	end
end)

hook.Add("RagdollDeath", "BrainfuckV2", function(ply, rag)
	if not IsValid(rag) then return end

	local org = rag.organism or IsValid(ply) and ply.organism
	if not org then return end

	timer.Simple(0.1, function()
		if not IsValid(rag) then return end
		rag.organism = rag.organism or org
		local posture, severity = getPostureState(rag.organism)
		dbgPrint("[BrainfuckV2] death " .. tostring(rag) .. " brain " .. tostring(rag.organism.brain) .. " posture " .. tostring(posture) .. " severity " .. tostring(severity))
		setPosture(rag.organism, posture, severity, rag)
	end)
end)

util.AddNetworkString("hg_brainfuck_posture_maker")

concommand.Add("hg_posture_maker", function(ply)
	if not IsValid(ply) or not ply:IsAdmin() then return end

	net.Start("hg_brainfuck_posture_maker")
	net.Send(ply)
end)

dbgPrint("[BrainfuckV2] loaded rev " .. brainfuckv2Rev)
