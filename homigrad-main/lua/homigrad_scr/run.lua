-- "lua\\homigrad_scr\\run.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
AddCSLuaFile()

print("Loading homigrad_scr.")

local start = SysTime()

hg.includeDir("homigrad_scr/")

print("homigrad_scr loaded! Time taken: " .. math.Round(SysTime() - start, 4) .. "s")

hook.Run("HomigradRun")