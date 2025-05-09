-- "gamemodes\\homigradcom\\entities\\weapons\\weapon_m4a1.lua"
-- Retrieved by https://github.com/lewisclark/glua-steal
SWEP.Base = "weapon_ar15"

if CLIENT then
	SWEP.PrintName = language.GetPhrase("hg.m4a1.name")
	SWEP.Author = "homigradcom"
	SWEP.Instructions = language.GetPhrase("hg.m4a1.inst")
	SWEP.Category = language.GetPhrase("hg.category.weapons")
end

SWEP.Primary.Automatic = true

SWEP.ShootWait = 0.07