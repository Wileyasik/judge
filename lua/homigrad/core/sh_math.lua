local math_Clamp = math.Clamp
local Lerp = Lerp
local LerpVector = LerpVector
local LerpAngle = LerpAngle
local FrameTime = FrameTime
local host_timescale = game.GetTimeScale

function qerp(delta, a, b)
	local qdelta = -(delta ^ 2) + (delta * 2)
	qdelta = math_Clamp(qdelta, 0, 1)
	return Lerp(qdelta, a, b)
end

FrameTimeClamped = 1/66
ftlerped = 1/66

hook.Add("Think", "Mul lerp", function()
	local ft = FrameTime()
	ftlerped = Lerp(0.5, ftlerped, math_Clamp(ft, 0.001, 0.1))
end)

function hg.FrameTimeClamped(ft)
	return math_Clamp(1 - math.exp(-0.5 * (ft or ftlerped) * host_timescale()), 0.000, 0.02)
end

local FrameTimeClamped_ = hg.FrameTimeClamped

local function lerpFrameTime(lerp, frameTime)
	return math_Clamp(1 - lerp ^ (frameTime or ftlerped), 0, 1)
end

local function lerpFrameTime2(lerp, frameTime)
	if lerp == 1 then return 1 end
	return math_Clamp(lerp * FrameTimeClamped_(frameTime or ftlerped) * 150, 0, 1)
end

hg.lerpFrameTime2 = lerpFrameTime2
hg.lerpFrameTime = lerpFrameTime

function LerpFT(lerp, source, set)
	return Lerp(lerpFrameTime2(lerp), source, set)
end

function LerpVectorFT(lerp, source, set)
	return LerpVector(lerpFrameTime2(lerp), source, set)
end

function LerpAngleFT(lerp, source, set)
	return LerpAngle(lerpFrameTime2(lerp), source, set)
end

local max, min = math.max, math.min

function util.halfValue(value, maxvalue, k)
	k = maxvalue * k
	return max(value - k, 0) / k
end

function util.halfValue2(value, maxvalue, k)
	k = maxvalue * k
	return min(value / k, 1)
end

function util.safeDiv(a, b)
	if a == 0 and b == 0 then
		return 0
	else
		return a / b
	end
end
