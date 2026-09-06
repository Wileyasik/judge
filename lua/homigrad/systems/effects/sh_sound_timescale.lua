local cheats = GetConVar("sv_cheats")
local timeScale = GetConVar("host_timescale")

function changePitch(p)
	if (game.GetTimeScale() ~= 1) then
		p = p * game.GetTimeScale()
	end

	if (timeScale:GetFloat() ~= 1 and cheats:GetBool()) then
		p = p * timeScale:GetFloat()
	end

	if (CLIENT and engine.GetDemoPlaybackTimeScale() ~= 1) then
		p = math.Clamp(p * engine.GetDemoPlaybackTimeScale(), 0, 255)
	end

	return p
end

hook.Add("EntityEmitSound", "TimeWarpSounds", function(t)
	local p = changePitch(t.Pitch)

	if (p ~= t.Pitch) then
		t.Pitch = math.Clamp(p, 0, 255)
		return true
	end
end)

hook.Add("PlayerDeathSound", "removesound", function() return true end)
