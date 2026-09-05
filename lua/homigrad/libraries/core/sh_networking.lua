zb = zb or {}

if (CLIENT) then
    local entityMeta = FindMetaTable("Entity")
    local playerMeta = FindMetaTable("Player")

    zb.net = zb.net or {}
    zb.net.globals = zb.net.globals or {}

    net.Receive("zbGlobalVarSet", function()
        local key, var = net.ReadString(), net.ReadType()

    	zb.net.globals[key] = var

        hook.Run("OnGlobalVarSet", key, var)
    end)

    net.Receive("zbNetVarSet", function()
        local index = net.ReadUInt(16)

		local key = net.ReadString()
    	local var = net.ReadType()
		
        zb.net[index] = zb.net[index] or {}
        zb.net[index][key] = var

		-- print(index, key)
		
		if IsValid(Entity(index)) then
			hook.Run("OnNetVarSet", index, key, var)
		else
			zb.net[index].waiting = true
		end
    end)
	
    net.Receive("zbNetVarDelete", function()
    	zb.net[net.ReadUInt(16)] = nil
    end)

    net.Receive("zbLocalVarSet", function()
    	local key = net.ReadString()
    	local var = net.ReadType()

    	zb.net[LocalPlayer():EntIndex()] = zb.net[LocalPlayer():EntIndex()] or {}
    	zb.net[LocalPlayer():EntIndex()][key] = var

    	hook.Run("OnLocalVarSet", key, var)
    end)

    net.Receive("ZB_fullsync", function()
        local count = net.ReadUInt(16)
        for i = 1, count do
            local scope = net.ReadUInt(2)
            if scope == 0 then
                local index = net.ReadUInt(16)
                local key = net.ReadString()
                local var = net.ReadType()

                zb.net[index] = zb.net[index] or {}
                zb.net[index][key] = var

                if IsValid(Entity(index)) then
                    hook.Run("OnNetVarSet", index, key, var)
                else
                    zb.net[index].waiting = true
                end
            elseif scope == 1 then
    	        local key = net.ReadString()
    	        local var = net.ReadType()

    	        zb.net.globals[key] = var

    	        hook.Run("OnGlobalVarSet", key, var)
            else
    	        local key = net.ReadString()
    	        local var = net.ReadType()

    	        zb.net[LocalPlayer():EntIndex()] = zb.net[LocalPlayer():EntIndex()] or {}
    	        zb.net[LocalPlayer():EntIndex()][key] = var

    	        hook.Run("OnLocalVarSet", key, var)
            end
        end
    end)

    function GetNetVar(key, default) -- luacheck: globals GetNetVar
    	local value = zb.net.globals[key]

    	return value != nil and value or default
    end

    function entityMeta:GetNetVar(key, default)
    	local index = self:EntIndex()

    	if (zb.net[index] and zb.net[index][key] != nil) then
    		return zb.net[index][key]
    	end

    	return default
    end

    playerMeta.GetLocalVar = entityMeta.GetNetVar

	hook.Add("InitPostEntity", "OnRequestFullUpdate_zb", function()
		LocalPlayer():SyncVars()
	end)

	function playerMeta:SyncVars()
		net.Start("ZB_request_fullupdate")
		net.SendToServer()
	end
else
	util.AddNetworkString("ZB_request_fullupdate")

	net.Receive("ZB_request_fullupdate",function(len,ply)
		ply.cooldown_sendnet = ply.cooldown_sendnet or 0
		if ply.cooldown_sendnet < CurTime() then
			ply.cooldown_sendnet = CurTime() + 1

			ply:SyncVars()
		end
	end)

	gameevent.Listen( "OnRequestFullUpdate" )
	hook.Add("OnRequestFullUpdate", "OnRequestFullUpdate_zb", function(data)
		local id = data.userid
		local ply = Player(id)
		
		ply:SyncVars()
	end)
	
	
    local entityMeta = FindMetaTable("Entity")
    local playerMeta = FindMetaTable("Player")

    zb.net = zb.net or {}
    zb.net.list = zb.net.list or {}
    zb.net.locals = zb.net.locals or {}
    zb.net.globals = zb.net.globals or {}

    util.AddNetworkString("zbGlobalVarSet")
    util.AddNetworkString("zbLocalVarSet")
    util.AddNetworkString("zbNetVarSet")
    util.AddNetworkString("zbNetVarDelete")
    util.AddNetworkString("ZB_fullsync")

    local function CheckBadType(name, object)
		return false
    	--[[if (isfunction(object)) then
    		ErrorNoHalt("Net var '" .. name .. "' contains a bad object type!")

    		return true
    	elseif (istable(object)) then
    		for k, v in pairs(object) do
    			if (CheckBadType(name, k) or CheckBadType(name, v)) then
    				return true
    			end
    		end
    	end--]]
    end

	local function isScalarNetValue(value)
		local valueType = type(value)
		return valueType == "number" or valueType == "string" or valueType == "boolean"
	end

    function GetNetVar(key, default)
    	local value = zb.net.globals[key]

    	return value != nil and value or default
    end

    function SetNetVar(key, value, receiver, unreliable)
		if (CheckBadType(key, value)) then return end
		if receiver == nil and not unreliable and isScalarNetValue(value) and zb.net.globals[key] == value then return end
		
    	zb.net.globals[key] = value

    	net.Start("zbGlobalVarSet", unreliable)
    	net.WriteString(key)
    	net.WriteType(value)

    	if (receiver == nil) then
    		net.Broadcast()
    	else
    		net.Send(receiver)
    	end
    end
	
    function playerMeta:SyncVars()
    	local SYNC_CHUNK = 32

    	local entries = {}
    	local n = 0

    	for k, v in pairs(zb.net.globals) do
    		n = n + 1
    		entries[n] = {1, 0, k, v}
    	end

    	for k, v in pairs(zb.net.locals[self] or {}) do
    		n = n + 1
    		entries[n] = {2, 0, k, v}
    	end

    	for entity, data in pairs(zb.net.list) do
    		if (IsValid(entity)) then
    			local index = entity:EntIndex()

    			for k, v in pairs(data) do
    				n = n + 1
    				entries[n] = {0, index, k, v}
    			end
    		else
    			zb.net.list[entity] = nil
    		end
    	end

    	for i = 1, n, SYNC_CHUNK do
    		local count = math.min(SYNC_CHUNK, n - i + 1)

    		net.Start("ZB_fullsync")
    		net.WriteUInt(count, 16)

    		for j = i, i + count - 1 do
    			local entry = entries[j]
    			net.WriteUInt(entry[1], 2)
    			if entry[1] == 0 then
    				net.WriteUInt(entry[2], 16)
    			end
    			net.WriteString(entry[3])
    			net.WriteType(entry[4])
    		end

    		net.Send(self)
    	end
    end
	
    function playerMeta:GetLocalVar(key, default)
    	if (zb.net.locals[self] and zb.net.locals[self][key] != nil) then
    		return zb.net.locals[self][key]
    	end

    	return default
    end

    function playerMeta:SetLocalVar(key, value)
		if (CheckBadType(key, value)) then return end

		zb.net.locals[self] = zb.net.locals[self] or {}
		if isScalarNetValue(value) and zb.net.locals[self][key] == value then return end
		zb.net.locals[self][key] = value

    	net.Start("zbLocalVarSet")
    		net.WriteString(key)
    		net.WriteType(value)
    	net.Send(self)
    end

    function entityMeta:GetNetVar(key, default)
    	if (zb.net.list[self] and zb.net.list[self][key] != nil) then
    		return zb.net.list[self][key]
    	end

    	return default
    end

    function entityMeta:SetNetVar(key, value, receiver)
		if (CheckBadType(key, value)) then return end

		zb.net.list[self] = zb.net.list[self] or {}
		if receiver == nil and isScalarNetValue(value) and zb.net.list[self][key] == value then return end

    	if (zb.net.list[self][key] != value) then
    		zb.net.list[self][key] = value 
    	end
		
		self:SendNetVar(key, receiver)
	end

    function entityMeta:SendNetVar(key, receiver)
    	net.Start("zbNetVarSet")
    	net.WriteUInt(self:EntIndex(), 16)
    	net.WriteString(key)
    	net.WriteType(zb.net.list[self] and zb.net.list[self][key])

    	if (receiver == nil) then
    		net.Broadcast()
    	else
    		net.Send(receiver)
    	end
    end

    function entityMeta:ClearNetVars(receiver)
    	zb.net.list[self] = nil
    	zb.net.locals[self] = nil

    	net.Start("zbNetVarDelete")
    	net.WriteUInt(self:EntIndex(), 16)

    	if (receiver == nil) then
    		net.Broadcast()
    	else
    		net.Send(receiver)
    	end
    end
	
	hook.Add("EntityRemoved","ZB_clear_net",function(ent,fullUpdate)
		ent:ClearNetVars()
	end)

	hook.Add("PlayerDisconnected","ZB_clear_net",function(ply)
		ply:ClearNetVars()
	end)
end
