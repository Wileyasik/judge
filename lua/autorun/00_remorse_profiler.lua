if not SERVER then return end

RemorseProfiler = RemorseProfiler or {}

local RP = RemorseProfiler
local SysTime = SysTime
local tostring = tostring
local type = type
local pairs = pairs
local ipairs = ipairs
local table_insert = table.insert
local table_sort = table.sort
local math_Round = math.Round

RP.entries = RP.entries or {}
RP.sources = RP.sources or {}
RP.generated = RP.generated or setmetatable({}, { __mode = "k" })

local cvEnabled = CreateConVar("rem_profiler_enabled", "0", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 0, 1)
local cvAuto = CreateConVar("rem_profiler_auto", "1", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 0, 1)
local cvInterval = CreateConVar("rem_profiler_interval", "30", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 5, 300)
local cvSpike = CreateConVar("rem_profiler_spike_ms", "80", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 10, 1000)
local cvSpikeCooldown = CreateConVar("rem_profiler_spike_cooldown", "10", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 1, 120)
local cvTop = CreateConVar("rem_profiler_top", "20", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 5, 80)
local cvMin = CreateConVar("rem_profiler_min_ms", "0.05", FCVAR_ARCHIVE, "im falling into despair trying to optimize this shit", 0, 100)

local oldHookAdd = hook.Add
local oldTimerCreate = timer.Create
local oldTimerSimple = timer.Simple
local oldNetReceive = net.Receive
local oldConcommandAdd = concommand.Add

local function sourceOf(fn)
	local ok, info = pcall(debug.getinfo, fn, "S")
	if not ok or not info then return "unknown" end
	local src = info.short_src or info.source or "unknown"
	if string.sub(src, 1, 1) == "@" then src = string.sub(src, 2) end
	return src
end

local function rowFor(tbl, key, kind, name, src)
	local row = tbl[key]
	if row then return row end
	row = { kind = kind, name = name, source = src, total = 0, count = 0, max = 0, window = 0, windowCount = 0, windowMax = 0 }
	tbl[key] = row
	return row
end

local function record(kind, name, src, dt)
	if dt <= 0 then return end
	local key = kind .. "\t" .. name .. "\t" .. src
	local row = rowFor(RP.entries, key, kind, name, src)
	row.total = row.total + dt
	row.count = row.count + 1
	row.window = row.window + dt
	row.windowCount = row.windowCount + 1
	row.last = dt
	if dt > row.max then row.max = dt end
	if dt > row.windowMax then row.windowMax = dt end

	local srcRow = rowFor(RP.sources, src, "file", src, src)
	srcRow.total = srcRow.total + dt
	srcRow.count = srcRow.count + 1
	srcRow.window = srcRow.window + dt
	srcRow.windowCount = srcRow.windowCount + 1
	srcRow.last = dt
	if dt > srcRow.max then srcRow.max = dt end
	if dt > srcRow.windowMax then srcRow.windowMax = dt end
end

local function shouldSkip(kind, name, fn)
	if type(fn) ~= "function" then return true end
	if RP.generated[fn] then return true end
	name = tostring(name or "")
	if string.find(name, "RemorseProfiler", 1, true) then return true end
	return false
end

local function wrap(kind, name, fn)
	if shouldSkip(kind, name, fn) then return fn end
	local src = sourceOf(fn)
	local label = tostring(name or "unknown")
	local wrapped = function(...)
		if not cvEnabled:GetBool() then return fn(...) end
		local started = SysTime()
		local a, b, c, d, e, f, g, h = fn(...)
		record(kind, label, src, SysTime() - started)
		return a, b, c, d, e, f, g, h
	end
	RP.generated[wrapped] = true
	return wrapped
end

local function resetWindow(tbl)
	for _, row in pairs(tbl) do
		row.window = 0
		row.windowCount = 0
		row.windowMax = 0
	end
end

local function sortedRows(tbl, field)
	local rows = {}
	for _, row in pairs(tbl) do
		if row[field] and row[field] > 0 then rows[#rows + 1] = row end
	end
	table_sort(rows, function(a, b) return (a[field] or 0) > (b[field] or 0) end)
	return rows
end

local function fmtMs(sec)
	return tostring(math_Round(sec * 1000, 3)) .. "ms"
end

local function printRows(title, rows, limit, minMs)
	print("[RemorseProfiler] " .. title)
	local printed = 0
	for _, row in ipairs(rows) do
		local totalMs = row.window * 1000
		if totalMs >= minMs then
			printed = printed + 1
			local avg = row.windowCount > 0 and row.window / row.windowCount or 0
			print("[RemorseProfiler] #" .. printed .. " " .. fmtMs(row.window) .. " total | " .. tostring(row.windowCount) .. " calls | " .. fmtMs(avg) .. " avg | " .. fmtMs(row.windowMax) .. " max | " .. row.kind .. " | " .. row.name .. " | " .. row.source)
			if printed >= limit then break end
		end
	end
	if printed == 0 then print("[RemorseProfiler] no rows over " .. tostring(minMs) .. "ms") end
end

function RP.Report(reason, keepWindow)
	local limit = cvTop:GetInt()
	local minMs = cvMin:GetFloat()
	print("[RemorseProfiler] report: " .. tostring(reason or "manual"))
	printRows("top callbacks", sortedRows(RP.entries, "window"), limit, minMs)
	printRows("top files", sortedRows(RP.sources, "window"), limit, minMs)
	if not keepWindow then
		resetWindow(RP.entries)
		resetWindow(RP.sources)
	end
end

function RP.Reset()
	RP.entries = {}
	RP.sources = {}
	print("[RemorseProfiler] reset")
end

local function wrapExistingHooks()
	local hooks = hook.GetTable and hook.GetTable() or {}
	for event, tbl in pairs(hooks) do
		if istable(tbl) then
			for name, fn in pairs(tbl) do
				if not shouldSkip("hook:" .. tostring(event), name, fn) then
					tbl[name] = wrap("hook:" .. tostring(event), name, fn)
				end
			end
		end
	end
end

local function wrapExistingTimers()
	local timers = timer.GetTable and timer.GetTable() or {}
	for name, data in pairs(timers) do
		if istable(data) then
			local fn = data.Func or data.func
			if not shouldSkip("timer", name, fn) then
				local wrapped = wrap("timer", name, fn)
				data.Func = wrapped
				data.func = wrapped
			end
		end
	end
end

local function wrapExistingNet()
	if not net.Receivers then return end
	for name, fn in pairs(net.Receivers) do
		if not shouldSkip("net", name, fn) then
			net.Receivers[name] = wrap("net", name, fn)
		end
	end
end

hook.Add = function(event, name, fn)
	return oldHookAdd(event, name, wrap("hook:" .. tostring(event), name, fn))
end

timer.Create = function(name, delay, reps, fn)
	return oldTimerCreate(name, delay, reps, wrap("timer", name, fn))
end

timer.Simple = function(delay, fn)
	return oldTimerSimple(delay, wrap("timer.Simple", tostring(delay), fn))
end

net.Receive = function(name, fn)
	return oldNetReceive(name, wrap("net", name, fn))
end

concommand.Add = function(name, fn, autocomplete, help, flags)
	return oldConcommandAdd(name, wrap("concommand", name, fn), autocomplete, help, flags)
end

concommand.Add("rem_profiler_report", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	RP.Report("manual", true)
end)

concommand.Add("rem_profiler_reset", function(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	RP.Reset()
end)

local nextAuto = SysTime() + cvInterval:GetFloat()
local lastFrame = SysTime()
local lastSpike = 0

oldHookAdd("Think", "RemorseProfiler_FrameWatch", function()
	local now = SysTime()
	local frameMs = (now - lastFrame) * 1000
	lastFrame = now

	if not cvEnabled:GetBool() then return end

	if cvAuto:GetBool() and frameMs >= cvSpike:GetFloat() and now - lastSpike >= cvSpikeCooldown:GetFloat() then
		lastSpike = now
		RP.Report("spike " .. tostring(math_Round(frameMs, 3)) .. "ms")
		return
	end

	if cvAuto:GetBool() and now >= nextAuto then
		nextAuto = now + cvInterval:GetFloat()
		RP.Report("interval")
	end
end)

oldTimerSimple(0, function()
	wrapExistingHooks()
	wrapExistingTimers()
	wrapExistingNet()
	print("[RemorseProfiler] loaded")
end)
