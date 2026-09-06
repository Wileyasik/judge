local PLAYER = FindMetaTable("Player")

function hg.IsValidPlayer(ply)
	return IsValid(ply) and ply:IsPlayer() and ply:Alive() and ply.organism
end

function player.GetListByName(name)
	local list = {}
	if name == "^" then
		return
	elseif name == "*" then
		return player.GetAll()
	end

	for i, ply in player.Iterator() do
		if string.find(string.lower(ply:Name()), string.lower(name)) then list[#list + 1] = ply end
	end
	return list
end

local function replace_by_index(str, index, char)
	return utf8.sub(str, 1, index - 1) .. char .. utf8.sub(str, index + 1)
end

local function utf8_reverse(codes, len)
	local characters = {}
	local characters2 = {}
	local curlen = 1

	for i, code in codes do
		characters[curlen] = utf8.char(code)
		curlen = curlen + 1
	end

	for i = 1, #characters do
		characters2[#characters - i + 1] = characters[i]
	end

	return table.concat(characters2)
end

hg.replace_by_index = replace_by_index
hg.utf8_reverse = utf8_reverse

if CLIENT then
	net.Receive("ZB_KeyDown2", function(len)
		local key = net.ReadInt(26)
		local down = net.ReadBool()
		local ply = net.ReadEntity()
		if not IsValid(ply) then return end
		ply.keydown = ply.keydown or {}
		ply.keydown[key] = down
		if ply.keydown[key] == false then ply.keydown[key] = nil end
	end)
end

function hg.KeyDown(owner, key)
	if not IsValid(owner) then return false end
	owner.keydown = owner.keydown or {}
	local localKey
	if CLIENT then
		if owner == LocalPlayer() then
			localKey = owner.organism and owner:KeyDown(key) or false
		else
			localKey = owner.keydown[key]
		end
	end
	return SERVER and owner:IsPlayer() and owner:KeyDown(key) or CLIENT and localKey
end

function hg.WeightedRandomSelect(tab, mul)
	if not tab or not istable(tab) then return end
	mul = mul or 1
	local total_weight = 0

	for i = 1, #tab do
		total_weight = total_weight + tab[i][1]
	end
	local total_weight_with_mul = total_weight * (mul - 1)
	local random_weight = math.Rand(math.min(total_weight_with_mul, math.Rand(total_weight_with_mul / 2, total_weight)), math.min(total_weight * mul, total_weight))
	local current_weight = 0

	for i = 1, #tab do
		current_weight = current_weight + tab[i][1]
		if (current_weight >= random_weight) then
			return i, tab[i][2]
		end
	end
end

function IsLookingAt(ply, targetVec, floatDiff)
	if not IsValid(ply) or not ply:IsPlayer() then return false end
	local diff = targetVec - ply:GetShootPos()
	local val = ply:GetAimVector():Dot(diff) / diff:Length()
	return val >= (floatDiff or 0.8), val
end
