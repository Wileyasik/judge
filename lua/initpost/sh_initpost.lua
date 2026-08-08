
if CLIENT then lply = LocalPlayer() end

hg.Binds = hg.Binds or {}
hg.Binds.CurrentBinds = hg.Binds.CurrentBinds or {}
hg.Binds.StandartBinds = hg.Binds.StandartBinds or {}
hg.Binds.Names = hg.Binds.Names or {}
hg.Binds.Commands = hg.Binds.Commands or {}

local PLAYERMETA = FindMetaTable("Player")

function hg.Binds:CreateBind(type_bind, key, key2, type_std, name, command)
    self.CurrentBinds[type_bind] = self.CurrentBinds[type_bind] or {key, key2}
    self.Names[type_bind] = name or self.Names[type_bind] or string.Replace(string.lower(type_bind), "_", " ")
    self.Commands[type_bind] = command or self.Commands[type_bind]

    if type_std then
        self.StandartBinds[type_bind] = {key, key2}
    end
end

function hg.Binds.GetButton(bind_name, ply)
    if SERVER then
        return ((ply.binds or {})[bind_name] or false)
    end

    return (hg.Binds.CurrentBinds[bind_name] or false)
end

function PLAYERMETA:IsBindPressed(bind_name)
    local bind = hg.Binds.GetButton(bind_name, self)
    if not bind then return false end

    local buttons = self.downedbuttons or {}
    local key1 = bind[1]
    local key2 = bind[2]

    if not key1 or key1 == -999 or key1 == KEY_NONE then return false end

    if key2 and key2 ~= KEY_NONE and key2 ~= -999 then
        return buttons[key1] and buttons[key2] or false
    end

    return buttons[key1] or false
end

function hg.Binds.CheckBinds(buttons, ply)
    local activated = {}
    buttons = buttons or ply.downedbuttons or {}

    local binds = CLIENT and ply == LocalPlayer() and hg.Binds.CurrentBinds or (ply.binds or {})

    for bind_name, bind in pairs(binds) do
        local key1 = bind[1]
        local key2 = bind[2]

        if not key1 or key1 == -999 or key1 == KEY_NONE then continue end

        if key2 and key2 ~= KEY_NONE and key2 ~= -999 then
            if buttons[key1] and buttons[key2] then activated[bind_name] = true end
        elseif buttons[key1] then
            activated[bind_name] = true
        end
    end

    return activated
end

hook.Add("PlayerButtonDown", "zcity_keybinds_down", function(ply, button)
    ply.downedbuttons = ply.downedbuttons or {}
    ply.downedbuttons[button] = true

    if CLIENT and ply == LocalPlayer() then return end

    local binds = hg.Binds.CheckBinds(ply.downedbuttons, ply)
    for bind_name in pairs(binds) do
        hook.Run("BindActivated_" .. bind_name, ply)
    end
end)

hook.Add("PlayerButtonUp", "zcity_keybinds_up", function(ply, button)
    ply.downedbuttons = ply.downedbuttons or {}
    ply.downedbuttons[button] = nil

    if CLIENT and ply == LocalPlayer() then return end
end)

if SERVER then
    util.AddNetworkString("Bullshit_binds")

    net.Receive("Bullshit_binds", function(_, ply)
        ply.binds = net.ReadTable() or {}
    end)
else
    local activeBinds = {}

    local function IsBindDown(bind)
        local key1 = bind and bind[1]
        local key2 = bind and bind[2]

        if not key1 or key1 == -999 or key1 == KEY_NONE then return false end
        if key2 and key2 ~= -999 and key2 ~= KEY_NONE then
            return input.IsButtonDown(key1) and input.IsButtonDown(key2)
        end

        return input.IsButtonDown(key1)
    end

    hook.Add("Think", "zcity_keybinds_client_think", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        ply.downedbuttons = ply.downedbuttons or {}

        if vgui.CursorVisible() or gui.IsGameUIVisible() then
            activeBinds = {}
            return
        end

        for bind_name, bind in pairs(hg.Binds.CurrentBinds or {}) do
            local key1 = bind[1]
            local key2 = bind[2]
            local down = IsBindDown(bind)
            local wasDown = activeBinds[bind_name]

            if key1 and key1 ~= KEY_NONE and key1 ~= -999 then ply.downedbuttons[key1] = input.IsButtonDown(key1) or nil end
            if key2 and key2 ~= KEY_NONE and key2 ~= -999 then ply.downedbuttons[key2] = input.IsButtonDown(key2) or nil end

            if down and not wasDown then
                activeBinds[bind_name] = true
                hook.Run("BindActivated_" .. bind_name, ply)

                local command = hg.Binds.Commands[bind_name]
                if command then RunConsoleCommand(command) end
            elseif not down and wasDown then
                activeBinds[bind_name] = nil

                local command = hg.Binds.Commands[bind_name]
                if command and string.StartWith(command, "+") then
                    RunConsoleCommand("-" .. string.sub(command, 2))
                end
            end
        end
    end)

    function hg.Binds.SaveThem()
        local json_table = util.TableToJSON(hg.Binds.CurrentBinds)

        file.CreateDir("zcity/binds")
        file.Write("zcity/binds/main.json", json_table)

        net.Start("Bullshit_binds")
        net.WriteTable(hg.Binds.CurrentBinds)
        net.SendToServer()
    end

    function hg.Binds.LoadBinds()
        if not file.Exists("zcity/binds/main.json", "DATA") then hg.Binds.SaveThem() return true end

        local content = file.Read("zcity/binds/main.json", "DATA")
        local saved = content and util.JSONToTable(content)
        if not saved then return hg.Binds.SaveThem() end

        for bind_name, keys in pairs(saved) do
            if hg.Binds.CurrentBinds[bind_name] then
                hg.Binds.CurrentBinds[bind_name] = keys
            end
        end
    end
end

local function RemoveOldBinds()
    hg.Binds.CurrentBinds.CLOSE_BUTTON = nil
    hg.Binds.CurrentBinds.STRONG_KICK = nil
    hg.Binds.StandartBinds.CLOSE_BUTTON = nil
    hg.Binds.StandartBinds.STRONG_KICK = nil
    hg.Binds.Names.CLOSE_BUTTON = nil
    hg.Binds.Names.STRONG_KICK = nil
    hg.Binds.Commands.CLOSE_BUTTON = nil
    hg.Binds.Commands.STRONG_KICK = nil
end

RemoveOldBinds()

hg.Binds:CreateBind("hg_kick", KEY_NONE, nil, true, "Kick", "hg_kick")
hg.Binds:CreateBind("hmcd_togglelaser", KEY_NONE, nil, true, "Toggle weapon laser", "hmcd_togglelaser")
hg.Binds:CreateBind("+alt1", KEY_NONE, nil, true, "Lean left", "+alt1")
hg.Binds:CreateBind("+alt2", KEY_NONE, nil, true, "Lean right", "+alt2")
hg.Binds:CreateBind("+hmcd_holdbreath", KEY_NONE, nil, true, "Hold breath", "+hmcd_holdbreath")
hg.Binds:CreateBind("+altlook", KEY_NONE, nil, true, "Look around", "+altlook")
hg.Binds:CreateBind("+hg_zoom", KEY_NONE, nil, true, "Zoom camera", "+hg_zoom")
hg.Binds:CreateBind("hg_drop", KEY_NONE, nil, true, "Drop weapon", "drop")

if CLIENT then
    hg.Binds.LoadBinds()
    RemoveOldBinds()
    hg.Binds.SaveThem()
end

function GAMEMODE:PlayerShouldTaunt( ply, actid )
    return true
end

function GAMEMODE:HandlePlayerLanding( ply, velocity, WasOnGround )
    if SERVER then return end
    if ply == LocalPlayer() and ply == GetViewEntity() then return end

    if ( ply:GetMoveType() == MOVETYPE_NOCLIP ) then return end

    if ( ply:IsOnGround() && !WasOnGround ) then
        ply:AnimRestartGesture( GESTURE_SLOT_JUMP, ACT_LAND, true )
    end
end

function GAMEMODE:GrabEarAnimation(ply)
    hg.earanim(ply)
end

function GAMEMODE:MouthMoveAnimation(ply)
    hg.mouthmove(ply)
end

if CLIENT then
    local entities = ents.FindByClass("prop_ragdoll")
    table.Add(entities, player.GetAll())

    for i, ply in ipairs(entities) do
        ply.RenderOverride = function(self, flags)
            if not IsValid(self) then return end
            local ent = self.FakeRagdoll
            if IsValid(ent) then return end
            
            hg.renderOverride(self, ent, flags)
        end
    end
end

local band = bit.band
local bor = bit.bor
local rshift = bit.rshift
local lshift = bit.lshift

local function estimate(file)
	local position = file:seek()

	local function readByte()
		return string.byte(file:read(1))
	end
	local reader = {
		readStr = function(len)
			local str = assert(file:read(len), 'Could not read '..len..'-byte string.')
			return unpad(str)
		end,
		readByte = readByte,
		readInt = function(size, mult)
			mult = mult or 256
			local n = readByte()
			for i=2, size do
				n = n*mult + readByte()
			end
			return n
		end,
		position = function() return file:seek() end,
		skip = function(offset) file:seek('cur', offset) end
	}

	-- Skip v3 header if it exists
	file:seek("set", 0)
	local header = file:read(3)
	local id3_offset = 0
	if header == "ID3" then
		local major = reader.readByte()
		local minor = reader.readByte()
		local flags = reader.readByte()

		local footer_present = band(flags, 0x10) == 0x10

		local z0, z1, z2, z3 = reader.readByte(), reader.readByte(), reader.readByte(), reader.readByte()

		if band(z0, 0x80) == 0 and band(z1, 0x80) == 0 and band(z2, 0x80) == 0 and band(z3, 0x80) == 0 then
			local tag_size = (band(z0, 0x7f) * 2097152) + (band(z1, 0x7f) * 16384) + (band(z2, 0x7f) * 128) + band(z3, 0x7f)
			local footer_size = footer_present and 10 or 0

			id3_offset = 3 + tag_size + footer_size
			reader.skip(tag_size + footer_size)
		end
	end

	local bitrates = {
		[1] = {
			[1] = { 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448 },
			[2] = { 32, 48, 56, 64,  80,  96,  112, 128, 160, 192, 224, 256, 320, 384 },
			[3] = { 32, 40, 48, 56,  64,  80,  96,  112, 128, 160, 192, 224, 256, 320 }
		},
		[2] = {
			[1] = { 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256 },
			[2] = { 8,  16, 24, 32, 40, 48, 56,  64,  80,  96,  112, 128, 144, 160 },
			[3] = { 8,  16, 24, 32, 40, 48, 56,  64,  80,  96,  112, 128, 144, 160 }
		},
	}

	-- Support free bitrates
	for v=1,2 do
		for l=1,3 do
			bitrates[v][l][0] = 0
		end
	end

	local samplerates = {
		[1]  = { [0] = 44100, [1] = 48000, [2] = 32000 },
		[2]  = { [0] = 22050, [1] = 24000, [2] = 16000 },
		[2.5]= { [0] = 11025, [1] = 12000, [2] = 8000  },
	}

	local samplecounts = {
		[1] = { [1] = 384, [2] = 1152, [3] = 1152}, -- MPEGv1
		[2] = { [1] = 384, [2] = 1152, [3] = 576},  -- MPEGv2
	}

	local mpegversion = {
		[3] = 1,
		[2] = 2,
		[0] = 2.5
	}

	local function try_parse_frame()
		local first_half = reader.readInt(2)
		local second_half = reader.readInt(2)

		local has_sync = band(first_half, 0xFFE0) == 0xFFE0
		local valid_ver = band(first_half, 0x18) ~= 0x8
		local valid_layer = band(first_half, 0x6) ~= 0x0

		if has_sync and valid_ver and valid_layer then

			local valid_bitrate = band(second_half, 0xF000) ~= 0xF000
			local valid_sample = band(second_half, 0xC00) ~= 0xC00

			if valid_bitrate and valid_sample then

				local version = mpegversion[band(rshift(first_half, 3), 0x3)]
				local simple_version = version == 2.5 and 2 or version

				local layer = (4 - band(rshift(first_half, 1), 0x3)) % 4
				local padding = band(rshift(second_half, 9), 0x1)

				local samplerate = samplerates[version][band(rshift(second_half, 10), 0x3)] or 0
				local bitrate = bitrates[math.floor(version)][layer][rshift(second_half, 12)]

				if not bitrate then
					print("Unknown bitrate (v", version, " l", layer, " brateidx", rshift(second_half, 12), ")")
				end

				local samples = samplecounts[simple_version][layer]

				local framesize
				if layer == 1 then
					framesize = math.floor(((12 * (bitrate * 1000) / samplerate) + padding) * 4)
				else
					framesize = math.floor((144 * (bitrate * 1000) / samplerate) + padding)
				end

				return {
					framesize = framesize,
					samples = samples,
					samplerate = samplerate
				}
			end
		end
	end

	local duration = 0
	local framesParsed = 0

	local function try_parse()
		local tag = file:read(3)
		file:seek("cur", -3)
		if tag == "TAG" then
			reader.skip(128)
		else
			local frame = try_parse_frame()
			if frame then
				-- Free bitrate makes framesize zero, so we need to make sure we dont seek backwards
				file:seek("cur", math.max(frame.framesize - 4, 0))

				duration = duration + (frame.samples / frame.samplerate)

				framesParsed = framesParsed + 1
			else
				-- try_parse_frame always reads 4 bytes, we need to go back by 3 to make sure we didnt miss anything
				file:seek("cur", -3)
			end
		end
	end

	local l = 0
	while file:remaining() >= 4 do
		try_parse()
		l = l + 1
		if l > (5*1e6) then print("[MediaLib MP3Duration] Terminating infinite loop or extremely big mp3 size (", framesParsed, " frames were parsed)") break end
	end

	return duration
end

local function estimate_data(data)
    if !isstring(data) then return 0 end
	-- Simulated file handle
	local sfh = {pos = 0, data = data}
	function sfh:seek(whence, offset)
		offset = offset or 0

		if whence == "set" then
			self.pos = offset + 0
		elseif whence == "cur" then
			self.pos = offset + self.pos
		elseif whence == "end" then
			self.pos = offset + #self.data-1
		end
		return self.pos
	end
	function sfh:remaining()
		return #self.data - self.pos
	end
	function sfh:read(bytes)
		local subData = string.sub(self.data, self.pos+1, self.pos+bytes)
		self.pos = self.pos + bytes
		return subData
	end

	return estimate(sfh)
end

//if CLIENT then
    hg.precachedsounds = {}

    function hg.PrecacheSound(name)
        if hg.precachedsounds[name] then return end

        game.GetWorld():EmitSound(name, 75, 100, 1, CHAN_AUTO, SND_STOP)
        local dur = estimate_data(file.Read("sound/"..name, "GAME"))
        
        //print(SoundDuration(name), dur, name)

        hg.precachedsounds[name] = dur
    end

    hg.ghetto_phrases = {}
    local ghetto = "ground_control/radio/ghetto/"
    for i, file in ipairs(file.Find("sound/"..ghetto.."*", "GAME")) do
        hg.PrecacheSound(ghetto..file)
        hg.ghetto_phrases[#hg.ghetto_phrases + 1] = ghetto..file
    end

	hg.ghetto_phrases = {
		"ground_control/radio/ghetto/move1.mp3",
		"ground_control/radio/ghetto/move2.mp3",
		"ground_control/radio/ghetto/move3.mp3",
		"ground_control/radio/ghetto/move4.mp3",
		"ground_control/radio/ghetto/move5.mp3",
		"ground_control/radio/ghetto/move6.mp3",
		"ground_control/radio/ghetto/negative1.mp3",
		"ground_control/radio/ghetto/negative2.mp3",
		"ground_control/radio/ghetto/negative3.mp3",
		"ground_control/radio/ghetto/negative4.mp3",
		"ground_control/radio/ghetto/negative5.mp3",
		"ground_control/radio/ghetto/negative6.mp3",
		"ground_control/radio/ghetto/wait1.mp3",
		"ground_control/radio/ghetto/wait2.mp3",
		"ground_control/radio/ghetto/wait3.mp3",
		"ground_control/radio/ghetto/wait4.mp3",
		"ground_control/radio/ghetto/affirmative1.mp3",
		"ground_control/radio/ghetto/affirmative2.mp3",
		"ground_control/radio/ghetto/affirmative3.mp3",
		"ground_control/radio/ghetto/affirmative4.mp3",
		"ground_control/radio/ghetto/affirmative5.mp3",
		"ground_control/radio/ghetto/affirmative6.mp3",
		"ground_control/radio/ghetto/suppress1.mp3",
		"ground_control/radio/ghetto/suppress2.mp3",
		"ground_control/radio/ghetto/suppress3.mp3",
		"ground_control/radio/ghetto/suppress4.mp3",
		"ground_control/radio/ghetto/thanks1.mp3",
		"ground_control/radio/ghetto/thanks2.mp3",
		"ground_control/radio/ghetto/thanks3.mp3",
		"ground_control/radio/ghetto/thanks4.mp3",
		"ground_control/radio/ghetto/thanks5.mp3",
	}

	//PrintTable(hg.ghetto_phrases)
//end

--// Don't allow dx8 users to play, because we are using shaders and other stuff that requires dx9
if CLIENT then
    local fuckyo = render.GetDXLevel()

    if fuckyo < 90 then
		local function noYouDont()
			if SERVER then return end
			surface.SetDrawColor(30,0,0,255)
			surface.DrawRect(0, 0, ScrW(), ScrH())

			surface.SetTextPos(ScrW() / 4, ScrH() / 2)
			surface.SetTextColor(255, 0, 0, 255)
			surface.SetFont("DermaLarge")
			surface.DrawText("Please set your DirectX to 9 or higher and restart your game to play, or leave this server.")
		end
		
		hook.Add("HUDPaint", "noYouDon't", noYouDont)
		hook.Add("HUDPaint", "noYouDon't", noYouDont)
		hook.Add("HUDPaintBackground", "noYouDon't", noYouDont)
		hook.Add("PreDrawHUD", "noYouDon't", noYouDont)
		hook.Add("PostDrawHUD", "noYouDon't", noYouDont)
    end
end

if CLIENT then
	function SDOIsDoor(self)
		return self:GetClass() == "prop_door_rotating" or self:GetClass() == "func_door_rotating"
	end
	
	hook.Add("OnEntityCreated", "doorInstructions", function(ent)
		if SDOIsDoor(ent) then
			if CLIENT then
				local use = input.LookupBinding("+use") or "BIND YOUR +USE KEY PLEASE. WRITE \"bind e +use\" IN CONSOLE FOR THE LOVE OF GOD"
				local walk = input.LookupBinding("+walk") or "BIND YOUR +WALK KEY PLEASE. WRITE \"bind alt +walk\" IN CONSOLE FOR THE LOVE OF GOD"
				local speed = input.LookupBinding("+speed") or "BIND YOUR +SPEED KEY PLEASE. WRITE \"bind shift +speed\" IN CONSOLE FOR THE LOVE OF GOD"
				
				ent.HowToUseInstructions = 
				"<font=ZCity_Tiny>"..string.upper( use ).." open normally</font>\n"..
				"<font=ZCity_Tiny>"..string.upper( walk ).." + ".. string.upper( use ) .." open slower</font>\n"..
				"<font=ZCity_Tiny>"..string.upper( speed ).." + ".. string.upper( use ) .." open faster</font>\n"

				ent.HudHintMarkup = markup.Parse("<font=ZCity_Tiny>".. "Door" .."</font>\n<font=ZCity_SuperTiny><colour=125,125,125>".. ent.HowToUseInstructions .."</colour></font>", 450)
				ent.AdditionalInfoFunc = function()
					return lply:KeyDown(IN_WALK) and "Open door for "..math.Round(100 - math.min(math.abs(lply:EyeAngles().p) / 60, 1) * 100).."%" or ""--lply:GetNWInt("door_open_amt", 0)
				end
			end
		end
	end)
end
