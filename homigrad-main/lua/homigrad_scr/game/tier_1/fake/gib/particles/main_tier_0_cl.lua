-- "lua\\homigrad_scr\\game\\tier_1\\fake\\gib\\particles\\main_tier_0_cl.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
local fps = 1 / 24
local delay = 0
local math_min = math.min

bloodparticels_hook = bloodparticels_hook or {}

local bloodparticels_hook = bloodparticels_hook

hook.Add("PostDrawOpaqueRenderables", "bloodpartciels", function()
	local time = CurTime()

	if delay <= time then
		delay = time + fps
		bloodparticels_hook[2](fps)
		bloodparticels_hook[4](fps)
	end

	local animpos = math_min((delay - time) / fps, 1)

	bloodparticels_hook[1](animpos)
	bloodparticels_hook[3](animpos)
end)